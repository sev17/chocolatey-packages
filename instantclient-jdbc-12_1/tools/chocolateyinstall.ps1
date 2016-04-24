$ErrorActionPreference = 'Stop'
$packageName = 'instantclient-jdbc-12_1'
$version = '12.1.0.2'
$versionFolder = 'instantclient_12_1'
$parentPackageName = 'instantclient'
$filename = 'instantclient-jdbc-nt-12.1.0.2.0.zip'
$filename64 = 'instantclient-jdbc-windows.x64-12.1.0.2.0.zip'
$checksum = 'ad07e0a267adf41e745c2e0cda0bace6'
$checksum64 = 'd5936f27f5a19cc0b1708d56f7571468'
$checksumType = 'md5'
$FROM_LOCATION = "$env:Temp"
$PROD_HOME = "$env:ChocolateyInstall\lib\$parentPackageName"
$machine = $false
$url = ''
$pathType = 'User'

$packageParameters = $env:chocolateyPackageParameters

if ($packageParameters) { 
    
    $packageParameters = (ConvertFrom-StringData $packageParameters.Replace("\","\\").Replace("'","").Replace('"','').Replace(";","`n"))
    
    if ($packageParameters.ContainsKey("FROM_LOCATION")) { $FROM_LOCATION = $packageParameters.FROM_LOCATION }

    if ($packageParameters.ContainsKey("PROD_HOME")) { $PROD_HOME = $packageParameters.PROD_HOME }

    if ($packageParameters.ContainsKey("MACHINE")) { $machine = [System.Convert]::ToBoolean($($packageParameters.MACHINE)) }
}

if ($machine) { $pathType = 'Machine' }

if ((Get-ProcessorBits 64) -and !$env:chocolateyForceX86) {
    $checksum = $checksum64
    $filename = $filename64
}

if ($FROM_LOCATION.Contains('/')) { $url = "$FROM_LOCATION/$filename" }
else  { $url = "$FROM_LOCATION\$filename" }

write-host "url: $url"

Install-ChocolateyZipPackage -packageName $packageName -url "$url" -unzipLocation "$PROD_HOME" -checksum $checksum -checksumType $checksumType

#Setting path variable instead of using shims. Generate .ignore files for unwanted .exe files
$files = get-childitem "$PROD_HOME\$versionFolder" -include *.exe -recurse
foreach ($file in $files) {
    New-Item "$file.ignore" -type file -force | Out-Null
}

Install-ChocolateyPath -pathToInstall $(join-path $PROD_HOME $versionFolder) -pathType $pathType

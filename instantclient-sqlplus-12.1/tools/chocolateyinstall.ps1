$ErrorActionPreference = 'Stop'
$packageName = 'instantclient-sqlplus-12.1'
$version = '12.1.0.2'
$versionFolder = 'instantclient_12_1'
$parentPackageName = 'instantclient'
$filename = 'instantclient-sqlplus-nt-12.1.0.2.0.zip'
$filename64 = 'instantclient-sqlplus-windows.x64-12.1.0.2.0.zip'
$checksum = '239370f05403bf8b3fadacbaac0cb39a'
$checksum64 = 'eb6f5e4b316082743375b9ce2d134bb3'
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

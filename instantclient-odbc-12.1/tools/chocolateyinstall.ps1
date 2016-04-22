$ErrorActionPreference = 'Stop'
$packageName = 'instantclient-odbc-12.1'
$version = '12.1.0.2'
$versionFolder = 'instantclient_12_1'
$parentPackageName = 'instantclient'
$filename = 'instantclient-odbc-nt-12.1.0.2.0.zip'
$filename64 = 'instantclient-odbc-windows.x64-12.1.0.2.0.zip'
$checksum = 'ca12f847f886a4b0b007827c3cb5b0ae'
$checksum64 = 'd1f1d3a588783451a19e20586ccc8137'
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

write-host "...push-location $(join-path $PROD_HOME $versionFolder)"
push-location "$(join-path $PROD_HOME $versionFolder)"

write-host "...install odbc..."
& ".\odbc_install.exe"

if ($LASTEXITCODE -ne 0) {
    throw "Failed $$."
}

write-host "...pop-location"
pop-location

Install-ChocolateyPath -pathToInstall $(join-path $PROD_HOME $versionFolder) -pathType $pathType

$ErrorActionPreference = 'Stop'
$packageName = 'oracle-sqldeveloper'
$version = '4.1.3'
$packageFolder = 'sqldeveloper'
$filename = 'sqldeveloper-4.1.3.20.78-no-jre.zip'
$filename64 = 'sqldeveloper-4.1.3.20.78-x64.zip'
$checksum = '6e0794531f0391d8c436d08f224fd791'
$checksum64 = '25d1f87fb7f523216bc83a28e231aa79'
$checksumType = 'md5'
$FROM_LOCATION = "$env:Temp"
$PROD_HOME = "$env:ChocolateyPackageFolder"
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

#SQL Developer 32-bit requires JDK 8 32-bit while SQL Developer 64-bit includes a bundled JRE server. Since we 
#can't specify dependency for only 32-bit with params for a dependency i.e. <dependency>jdk8 -params "i586=true" </dependency>
#check if 32-bit installation specified and if JDK8 32-bit installed, throw error if not installed.
if ((Get-ProcessorBits 32) -or $env:chocolateyForceX86) {

    if ((Get-ProcessorBits 64) -and !(test-path 'HKLM:\SOFTWARE\Wow6432Node\JavaSoft\Java Development Kit\1.8*')) {
            throw "Missing JDK 8 or higher. Run choco install jdk8 -params `"i586=true`"" 
    }

    if ((Get-ProcessorBits 32) -and !(test-path 'HKLM:\SOFTWARE\JavaSoft\Java Development Kit\1.8*')) {
            throw "Missing JDK 8 or higher. Run choco install jdk8 -params `"i586=true`"" 
    }
}
else {
    $checksum = $checksum64
    $filename = $filename64
}

if ($FROM_LOCATION.Contains('/')) { $url = "$FROM_LOCATION/$filename" }
else  { $url = "$FROM_LOCATION\$filename" }

write-host "url: $url"

Install-ChocolateyZipPackage -packageName $packageName -url "$url" -unzipLocation "$PROD_HOME" -checksum $checksum -checksumType $checksumType

#Setting path variable instead of using shims. Generate .ignore files for unwanted .exe files
$files = get-childitem "$PROD_HOME\$packageFolder" -include *.exe -recurse
foreach ($file in $files) {
    New-Item "$file.ignore" -type file -force | Out-Null
}

#Workaround for msvcr100.dll issue https://community.oracle.com/thread/3897502
if ($filename -eq $filename64) {
    copy-item "$PROD_HOME\$packageFolder\jdk\jre\bin\msvcr100.dll" -Destination "$PROD_HOME\$packageFolder\sqldeveloper\bin"
}

Install-ChocolateyPath -pathToInstall $(join-path $PROD_HOME $packageFolder) -pathType $pathType

Install-ChocolateyDesktopLink -targetFilePath "$PROD_HOME\$packageFolder\sqldeveloper.exe"

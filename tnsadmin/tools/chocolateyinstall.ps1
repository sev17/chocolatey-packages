$ErrorActionPreference = "Stop"
$packageName = 'tnsadmin'
$version = "0.1.0"
$packageParameters = $env:chocolateyPackageParameters
$FROM_LOCATION = "$env:Temp"
$TNS_ADMIN = "$env:ChocolateyPackageFolder"
$tempDir = "$env:Temp\chocolatey\$packageName"
$machine = $false
$pathType = 'User'

$packageParameters = $env:chocolateyPackageParameters

if ($packageParameters) { 
    
    $packageParameters = (ConvertFrom-StringData $packageParameters.Replace("\","\\").Replace("'","").Replace('"','').Replace(";","`n"))
    
    if ($packageParameters.ContainsKey("FROM_LOCATION")) { $FROM_LOCATION = $packageParameters.FROM_LOCATION }

    if ($packageParameters.ContainsKey("TNS_ADMIN")) { $TNS_ADMIN = $packageParameters.TNS_ADMIN }
    
    if ($packageParameters.ContainsKey("MACHINE")) { $pathType = [System.Convert]::ToBoolean($($packageParameters.MACHINE)) }
}

if ($machine) { $pathType = 'Machine' }

if (!(Test-Path "$TNS_ADMIN")) {
  write-host "Create $TNS_ADMIN..."
  new-item "$TNS_ADMIN" -type directory
}

if ([System.IO.Path]::GetExtension("$FROM_LOCATION") -eq ".zip") {
  $file = Join-Path $tempDir $([System.IO.Path]::GetFileName($FROM_LOCATION))
    
  Get-ChocolateyWebFile -packageName $packageName -fileFullPath "$file" -url "$FROM_LOCATION"
  Get-ChocolateyUnzip -fileFullPath "$file" -TNS_ADMIN $tempDir -packageName $packageName
  copy-item -Path "$tempDir\*" -Destination "$TNS_ADMIN" -force  -Exclude '*.zip'
}
elseif ((get-item "$FROM_LOCATION" -ErrorAction "SilentlyContinue") -is [System.IO.DirectoryInfo]) {
  copy-item -Path "$FROM_LOCATION\*" -Destination "$TNS_ADMIN" -force
}
else {throw "TNS_ADMIN and FROM_LOCATION specified: $FROM_LOCATION isn't a zip file or directory."}  

Install-ChocolateyEnvironmentVariable -variableName "TNS_ADMIN" -variableValue "$TNS_ADMIN" -variableType $pathType

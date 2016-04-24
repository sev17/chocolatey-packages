$ErrorActionPreference = 'Stop'
$script_path = $(Split-Path -parent $MyInvocation.MyCommand.Definition)
$packageName = 'odac-x86_32-12_1'
$version = '12.1.0.24'
$versionFolder = 'odac_12_1'
#http://download.oracle.com/otn/other/ole-oo4o/ODAC121024Xcopy_32bit.zip
$filename = 'ODAC121024Xcopy_32bit.zip'
#http://download.oracle.com/otn/other/ole-oo4o/ODAC121024Xcopy_x64.zip
$filename64 = 'ODAC121024Xcopy_x64.zip'
$systemDir = "$env:SystemRoot\system32"
$systemDir64 = "$env:SystemRoot\SysWOW64"
$checksum = '24e229315410b70f5197d0a89b04c8d1'
$checksum64 = '1aa998bb373e7d62e731a7ee52802c52'
$checksumType = 'md5'
$FROM_LOCATION = "$env:Temp"
$PROD_HOME = "$env:ChocolateyPackageFolder"
$COMPONENT_LIST = @('all')
$machine = $true
$dependent = $true
$link_path = $false
$url = ''
$pathType = 'Machine'
$components = @("all","asp.net2","asp.net4","basic","odp.net2","odp.net4","oledb","oramts")

$common = $(Join-Path $script_path "common.ps1")
. $common

function invoke-install {
  param($component_name, $oracle_home_path, $oracle_home_name, $install_dependents, $machine_wide_configuration)

  write-host "...install $component_name..."
  & ".\install.bat" "$component_name" "$oracle_home_path" "$oracle_home_name" "$install_dependents" "$machine_wide_configuration"

  if ($LASTEXITCODE -ne 0) {
    throw "Failed $$."
  }

}

if (!(Test-ProcessAdminRights)) { throw "Please run install with admin priviliges" }

$packageParameters = $env:chocolateyPackageParameters

if ($packageParameters) { 
    
    $packageParameters = (ConvertFrom-StringData $packageParameters.Replace("\","\\").Replace("'","").Replace('"','').Replace(";","`n"))
    
    if ($packageParameters.ContainsKey("FROM_LOCATION")) { $FROM_LOCATION = $packageParameters.FROM_LOCATION }

    if ($packageParameters.ContainsKey("PROD_HOME")) { $PROD_HOME = $packageParameters.PROD_HOME }

    if ($packageParameters.ContainsKey("COMPONENT_LIST")) { $COMPONENT_LIST = $packageParameters.COMPONENT_LIST -split "," }

    if ($packageParameters.ContainsKey("MACHINE")) { $machine = [System.Convert]::ToBoolean($($packageParameters.MACHINE)) }

    if ($packageParameters.ContainsKey("DEPENDENT")) { $dependent = [System.Convert]::ToBoolean($($packageParameters.DEPENDENT)) }

    if ($packageParameters.ContainsKey("LINK_PATH")) { $link_path = [System.Convert]::ToBoolean($($packageParameters.LINK_PATH)) }
}

$invalids = $null
Compare-Object -ReferenceObject $components -DifferenceObject ($COMPONENT_LIST | Sort-Object) | 
where {$_.SideIndicator -eq "=>"} | foreach {$invalids +=,$_.InputObject}

if ($invalids -ne $null) {
  throw "Invalid COMPONENT_LIST specified: $(invalids -join ','). Valid COMPONENT_LIST = $(components -join ',')"
}

$oracle_home_path = $(join-path $PROD_HOME $versionFolder)
$oracle_home_name = $versionFolder
$machine = $machine.ToString()
$dependent = $dependent.ToString()

if ($packageName -notmatch 32) {
    $checksum = $checksum64
    $filename = $filename64
}

if ($FROM_LOCATION.Contains('/')) { $url = "$FROM_LOCATION/$filename" }
else  { $url = "$FROM_LOCATION\$filename" }

write-host "url: $url"

Install-ChocolateyZipPackage -packageName $packageName -url "$url" -unzipLocation "$env:ChocolateyPackageFolder" -checksum $checksum -checksumType $checksumType

#Setting path variable instead of using shims. Generate .ignore files for unwanted .exe files
$files = get-childitem "$env:ChocolateyPackageFolder" -include *.exe -recurse
foreach ($file in $files) {
    New-Item "$file.ignore" -type file -force | Out-Null
}

if (!(Test-Path "$oracle_home_path")) {
  write-host "Creating $oracle_home_path."
  new-item "$oracle_home_path" -type directory
}

write-host "...push-location $env:ChocolateyPackageFolder"
push-location "$env:ChocolateyPackageFolder"

write-host "Installing ODAC check $oracle_home_path\install.log for more details."
if ($component -contains "all") { invoke-install "all" "$oracle_home_path" "$oracle_home_name" "$dependent" "$machine"}
  else {
    foreach ($component in $COMPONENT_LIST) {
      invoke-install "$component" "$oracle_home_path" "$oracle_home_name" "$dependent" "$machine"
    }
  }

#Setting path variable instead of using shims. Generate .ignore files for unwanted .exe files
$files = get-childitem "$oracle_home_path" -include *.exe -recurse
foreach ($file in $files) {
    New-Item "$file.ignore" -type file -force | Out-Null
}

write-host "...pop-location"
pop-location

if ($link_path) {
  if ($packageName -match 32 -and (Get-ProcessorBits 64)) { 
    remove-link "$systemDir64\$versionFolder"
    new-link "$systemDir64\$versionFolder" "$oracle_home_path" 
  }
  else {
    remove-link "$systemDir\$versionFolder"
    new-link "$systemDir\$versionFolder" "$oracle_home_path" 
  }
  Install-ChocolateyPath -pathToInstall "$systemDir\$versionFolder" -pathType $pathType
  Install-ChocolateyPath -pathToInstall "$systemDir\$versionFolder\bin" -pathType $pathType
 
}
else {
  Install-ChocolateyPath -pathToInstall "$oracle_home_path" -pathType $pathType
  Install-ChocolateyPath -pathToInstall "$oracle_home_path\bin" -pathType $pathType
}

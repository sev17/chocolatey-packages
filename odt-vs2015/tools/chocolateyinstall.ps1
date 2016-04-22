$ErrorActionPreference = 'Stop'
$script_path = $(Split-Path -parent $MyInvocation.MyCommand.Definition)
$packageName = 'odt-vs2015'
$version = '12.1.0.24'
$filename = 'SetupODTforVS2015.exe'
$checksum = 'f1de24fa8b30f7abf57c3c58e88154e7'
$checksumType = 'md5'
$FROM_LOCATION = "$env:Temp"
$installerType = 'exe'
$silentArgs = "/s /f1`"$script_path\SetupODTforVS2015.iss`""
$validExitCodes = @(0, 3010)
$LINK_TNS = $false
$url = ''

$common = $(Join-Path $script_path "common.ps1")
. $common

if (!(Test-ProcessAdminRights)) { throw "Please run install with admin priviliges" }

# By default PowerShell does not have HKEY_CLASSES_ROOT defined so we have to define it
if ($(Get-PSDrive HKCR -ErrorAction SilentlyContinue) -eq $null) {New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT > $null}
if (!(Test-Path HKCR:\VisualStudio.DTE.14.0)) { throw 'VisualStudio 2015 NOT FOUND!' }
    
$packageParameters = $env:chocolateyPackageParameters

if ($packageParameters) { 
    
    $packageParameters = (ConvertFrom-StringData $packageParameters.Replace("\","\\").Replace("'","").Replace('"','').Replace(";","`n"))
    
    if ($packageParameters.ContainsKey("FROM_LOCATION")) { $FROM_LOCATION = $packageParameters.FROM_LOCATION }

    if ($packageParameters.ContainsKey("LINK_TNS")) { $LINK_TNS = [System.Convert]::ToBoolean($($packageParameters.LINK_TNS)) }
}

if ($FROM_LOCATION.Contains('/')) { $url = "$FROM_LOCATION/$filename" }
else  { $url = "$FROM_LOCATION\$filename" }

write-host "url: $url"

Install-ChocolateyPackage -packageName $packageName -url $url -checksum $checksum -checksumType $checksumType -installerType $installerType -silentArgs $silentArgs -validExitCodes $validExitCodes

if ($env:TNS_ADMIN -and $LINK_TNS) {
  #ODT uses ${env:ProgramFiles(x86)}\Oracle Developer Tools for VS2015\network\admin which you can't seem to change
  #to another location. The Managed ODP.NET doesnt' support IFILE syntax. If environment variable TNS_ADMIN
  #exists and /LINK_TNS switch specified, symlink admin directory TNS_ADMIN directory
  Write-Host "Removing ${env:ProgramFiles(x86)}\Oracle Developer Tools for VS2015\network\admin.."
  if (Test-ReparsePoint "${env:ProgramFiles(x86)}\Oracle Developer Tools for VS2015\network\admin") {
    remove-link "${env:ProgramFiles(x86)}\Oracle Developer Tools for VS2015\network\admin"
  }
  else {
      remove-item -Recurse -Force "${env:ProgramFiles(x86)}\Oracle Developer Tools for VS2015\network\admin"
  }
  
  new-link "${env:ProgramFiles(x86)}\Oracle Developer Tools for VS2015\network\admin" "$env:TNS_ADMIN"

}

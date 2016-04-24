$ErrorActionPreference = 'Stop'
$script_path = $(Split-Path -parent $MyInvocation.MyCommand.Definition)
$packageName = 'oracle-sqldeveloper'
$version = '4.1.3'
$packageFolder = 'sqldeveloper'
$PROD_HOME = "$env:ChocolateyPackageFolder"
$SQLDEVELOPER_PATH = ''
$machine = $false
$pathType = 'User'

$common = $(Join-Path $script_path "common.ps1")
. $common

$packageParameters = $env:chocolateyPackageParameters

if ($packageParameters) { 
    
    $packageParameters = (ConvertFrom-StringData $packageParameters.Replace("\","\\").Replace("'","").Replace('"','').Replace(";","`n"))
    
    if ($packageParameters.ContainsKey("SQLDEVELOPER_PATH")) { $SQLDEVELOPER_PATH = $packageParameters.SQLDEVELOPER_PATH }

    if ($packageParameters.ContainsKey("MACHINE")) { $pathType = [System.Convert]::ToBoolean($($packageParameters.MACHINE)) }
}

if ($machine) { $pathType = 'Machine' }

if ($SQLDEVELOPER_PATH -eq '') { $SQLDEVELOPER_PATH = $(Join-Path $PROD_HOME $packageFolder) }

Uninstall-Path -pathToUnInstall $SQLDEVELOPER_PATH -pathType $pathType

if (Test-Path "$SQLDEVELOPER_PATH") {
  Write-Host "Removing $SQLDEVELOPER_PATH..."
  remove-item -Recurse -Force "$SQLDEVELOPER_PATH"
}

if (Test-Path "$env:USERPROFILE\Desktop\sqldeveloper.exe.lnk") {
  Write-Host "Removing $env:USERPROFILE\Desktop\sqldeveloper.exe.lnk..."
  remove-item "$env:USERPROFILE\Desktop\sqldeveloper.exe.lnk"
}

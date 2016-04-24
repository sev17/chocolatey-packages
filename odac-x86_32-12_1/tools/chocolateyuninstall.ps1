$ErrorActionPreference = 'Stop'
$script_path = $(Split-Path -parent $MyInvocation.MyCommand.Definition)
$packageName = 'odac-x86_32-12_1'
$version = '12.1.0.24'
$versionFolder = 'odac_12_1'
$systemDir = "$env:SystemRoot\system32"
$systemDir64 = "$env:SystemRoot\SysWOW64"
$PROD_HOME = "$env:ChocolateyPackageFolder"
$machine = $true
$pathType = 'Machine'
$logfile ="$env:TEMP\ODACUninstall$(get-date -f yyyy-MM-dd_HH-MM-ss).log"

$common = $(Join-Path $script_path "common.ps1")
. $common

if (!(Test-ProcessAdminRights)) { throw "Please run uninstall with admin priviliges" }

$packageParameters = $env:chocolateyPackageParameters

if ($packageParameters) { 
    
    $packageParameters = (ConvertFrom-StringData $packageParameters.Replace("\","\\").Replace("'","").Replace('"','').Replace(";","`n"))
    
    if ($packageParameters.ContainsKey("ORACLE_HOME_PATH")) { $ORACLE_HOME_PATH = $packageParameters.ORACLE_HOME_PATH }

    if ($packageParameters.ContainsKey("MACHINE")) { $pathType = [System.Convert]::ToBoolean($($packageParameters.MACHINE)) }
}

$machine = $machine.ToString()

if ($ORACLE_HOME_PATH -eq '') { $ORACLE_HOME_PATH = $(Join-Path $PROD_HOME $versionFolder) }

#uninstall.bat component_name oracle_home_path [machine_wide_unconfiguration]
Write-Host "...push-location $ORACLE_HOME_PATH"
push-location "$ORACLE_HOME_PATH"

write-host "Uninstalling ODAC check $logfile for more details."
& ".\uninstall.bat" "all" "$ORACLE_HOME_PATH" "$machine"

if (Test-Path "$ORACLE_HOME_PATH\uninstall.log") { copy-item "$ORACLE_HOME_PATH\uninstall.log" "$logfile" }

if ($LASTEXITCODE -ne 0) {
    throw "Failed $$."
}

Write-Host "...pop-location"
pop-location

remove-link "$systemDir\$versionFolder"
remove-link "$systemDir64\$versionFolder"

Uninstall-Path -pathToUnInstall "$ORACLE_HOME_PATH" -pathType $pathType
Uninstall-Path -pathToUnInstall "$ORACLE_HOME_PATH\bin" -pathType $pathType
Uninstall-Path -pathToUnInstall "$systemDir\$versionFolder" -pathType $pathType
Uninstall-Path -pathToUnInstall "$systemDir\$versionFolder\bin" -pathType $pathType

if (Test-Path "$ORACLE_HOME_PATH") {
  Write-Host "Removing $ORACLE_HOME_PATH..."
  remove-item -Recurse -Force "$ORACLE_HOME_PATH"
}

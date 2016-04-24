$ErrorActionPreference = 'Stop'
$script_path = $(Split-Path -parent $MyInvocation.MyCommand.Definition)
$packageName = 'instantclient-12_1'
$version = '12.1.0.2'
$versionFolder = 'instantclient_12_1'
$parentPackageName = $packageName
$PROD_HOME = "$env:ChocolateyInstall\lib\$parentPackageName"
$INSTANT_CLIENT_PATH = ''
$machine = $false
$pathType = 'User'

$common = $(Join-Path $script_path "common.ps1")
. $common

$packageParameters = $env:chocolateyPackageParameters

if ($packageParameters) { 
    
    $packageParameters = (ConvertFrom-StringData $packageParameters.Replace("\","\\").Replace("'","").Replace('"','').Replace(";","`n"))
    
    if ($packageParameters.ContainsKey("INSTANT_CLIENT_PATH")) { $INSTANT_CLIENT_PATH = $packageParameters.INSTANT_CLIENT_PATH }

    if ($packageParameters.ContainsKey("MACHINE")) { $pathType = [System.Convert]::ToBoolean($($packageParameters.MACHINE)) }
}

if ($machine) { $pathType = 'Machine' }

if ($INSTANT_CLIENT_PATH -eq '') { $INSTANT_CLIENT_PATH = $(Join-Path $PROD_HOME $versionFolder) }

if (Test-Path $(join-path $INSTANT_CLIENT_PATH "odbc_uninstall.exe")) {
    write-host "Uninstall odbc..."
    write-host "...push-location $INSTANT_CLIENT_PATH"
    push-location "$INSTANT_CLIENT_PATH"
    & ".\odbc_uninstall.exe"

    if ($LASTEXITCODE -ne 0) {
        throw "Failed $$."
    }

    write-host "...pop-location"
    pop-location
}

Uninstall-Path -pathToUnInstall $INSTANT_CLIENT_PATH -pathType $pathType

if (Test-Path "$INSTANT_CLIENT_PATH") {
  Write-Host "Removing $INSTANT_CLIENT_PATH..."
  remove-item -Recurse -Force "$INSTANT_CLIENT_PATH"
}

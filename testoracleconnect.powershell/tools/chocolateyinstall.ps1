$ErrorActionPreference = "Stop"
$packageName = 'testoracleconnect.powershell'
$version = "0.1.0"

$psFile = Join-Path $(Split-Path -parent $MyInvocation.MyCommand.Definition) "test-oracleconnect.ps1" 
Install-ChocolateyPowershellCommand $packageName $psFile
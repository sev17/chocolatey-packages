$ErrorActionPreference = 'Stop'
$script_path = $(Split-Path -parent $MyInvocation.MyCommand.Definition)
$packageName = 'instantclient-tnsping-12_1'
$version = '12.1.0.2'
$versionFolder = 'instantclient_12_1'
$parentPackageName = 'instantclient-12_1'
$filename = $(join-path $script_path 'instantclient-tnsping-x86_32-12_1.zip')
$filename64 = $(join-path $script_path 'instantclient-tnsping-12_1.zip')
$PROD_HOME = "$env:ChocolateyInstall\lib\$parentPackageName"
$machine = $false
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
    $filename = $filename64
}
    
Get-ChocolateyUnzip -fileFullPath $filename -destination $(join-path $PROD_HOME $versionFolder) -packageName $packageName

Install-ChocolateyPath -pathToInstall $(join-path $PROD_HOME $versionFolder) -pathType $pathType
  
Install-ChocolateyEnvironmentVariable -variableName "ORACLE_HOME" -variableValue $(join-path $PROD_HOME $versionFolder) -variableType $pathType
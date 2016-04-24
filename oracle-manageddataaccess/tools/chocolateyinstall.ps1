$ErrorActionPreference = 'Stop'
$packageName = 'oracle-manageddataaccess'
$version = '12.1.2400'
$filename = 'https://www.nuget.org/packages/Oracle.ManagedDataAccess/'
$PROD_HOME = "$env:ChocolateyInstall\lib\$packageName"

$packageParameters = $env:chocolateyPackageParameters

if ($packageParameters) { 
    
    $packageParameters = (ConvertFrom-StringData $packageParameters.Replace("\","\\").Replace("'","").Replace('"','').Replace(";","`n"))
    
    if ($packageParameters.ContainsKey("PROD_HOME")) { $PROD_HOME = $packageParameters.PROD_HOME }

}

#choco install nuget.commandline
nuget install Oracle.ManagedDataAccess -o $PROD_HOME -version $version
  if ($LASTEXITCODE -ne 0) {
    throw "Failed $$."
}
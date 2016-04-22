function Uninstall-Path {
param(
  [string]$pathToUnInstall,
  [System.EnvironmentVariableTarget]$pathType = [System.EnvironmentVariableTarget]::User
)
  Write-Debug "Running 'Uninstall-Path' with pathToUninstall:`'$pathToUninstall`'"
  
  #Get the PATH variable
  Update-SessionEnvironment
  $envPath = Get-EnvironmentVariable -Name 'Path' -Scope $pathType
  
if ($envPath.ToLower().Contains($PathToUninstall.ToLower())) {
  Write-Debug "INFO: envPath=$envPath"
  Write-Host "PATH environment variable has $PathToUninstall in it. Removing..."

  $newPath = $envPath -replace [Regex]::Escape($pathToUninstall)
  $newPath = $newPath -replace ";+",";" -replace "^;"

  if ($pathType -eq [System.EnvironmentVariableTarget]::Machine) {
    if (Test-ProcessAdminRights) { Set-EnvironmentVariable -Name 'Path' -Value "$newPath" -Scope 'Machine' }
    else {
        $psArgs = "Set-EnvironmentVariable -Name `'Path`' -Value `'$newPath`' -Scope `'Machine`'"
        Start-ChocolateyProcessAsAdmin "$psArgs"
    }
  }
  else { Set-EnvironmentVariable -Name 'Path' -Value "$newPath" -Scope 'User' }

    #remove it from the session path as well 
    $envPSPath = $env:PATH
    $envPSPath = $envPSPath -replace [Regex]::Escape($pathToUninstall)
    $envPSPath = $envPSPath -replace ";+",";" -replace "^;"
    $env:Path = $envPSPath
  }
}

function Test-ReparsePoint {
param([string]$path)
  $file = Get-Item $path -Force -ea 0
  return [bool]($file.Attributes -band [IO.FileAttributes]::ReparsePoint)
}

function New-Link {
param(
  [string]$link,
  [string]$target
)

  write-host "Create symlink $link <<===>> $target"
  & cmd /c "mklink /D `"$link`" `"$target`""
  if ($LASTEXITCODE -ne 0) { throw "Failed $$." }
}

function Remove-Link {
param([string]$link)

  if (test-path $link) {
    if (Test-ReparsePoint $link) {
      write-host "rmdir $link"
      & cmd /c "rmdir `"$link`""
      if ($LASTEXITCODE -ne 0) { throw "Failed $$." }
    }
    else { throw "$link is not a ReparsePoint" }
  }
}
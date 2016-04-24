# Manual build
# choco pack
git clone https://github.com/sev17/chocolatey-packages.git

get-childitem "C:\orainstall\chocolatey-packages" -Recurse | move-item -destination "C:\orainstall"

rmdir c:\orainstall\chocolatey-packages -force

Get-ChildItem -Filter "*.DS_Store" -Force -Recurse | remove-item -force

Get-ChildItem  -recurse | where {($_.psiscontainer) -and @('tools','icons','packages.config') -notcontains $_.name} | select -expandproperty FullName | foreach { write-output "pushd $_; choco pack" }

#execute output above
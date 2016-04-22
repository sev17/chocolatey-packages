# Manual build
# choco pack
Get-ChildItem -Filter "*.DS_Store" -Force -Recurse | remove-item -force

Get-ChildItem  -recurse | where {($_.psiscontainer) -and $_.name -ne 'tools'} | select -expandproperty FullName | foreach { write-output "pushd $_; choco pack" }

#execute output above
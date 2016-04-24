#######################
<#
.SYNOPSIS
Tests Oracle Connections using odp.net2, odp.net4, oledb, odbc, odp.netmanaged, ldap, or all
.DESCRIPTION
The test-oracleConnect.ps1 tests Oracle connections using odp.net2, odp.net4, oledb, odbc, odp.netmanaged, ldap or all
.EXAMPLE
./test-oracleconnect.ps1 -UserId scott -Password tiger - DataSource HR -Test all
.NOTES
Version History
v1.0   - Chad Miller - 11/27/2015 - Initial release
v2.0   - Chad Miller - 03/30/2016 - Added LDAPServer param/Remove ManagedDriverdll path
#>
[CmdletBinding()]
    param(
    [Parameter(Mandatory=$true)]
    [string]$UserId,
    [Parameter(Mandatory=$true)]
    [string]$Password,
    [Parameter(Mandatory=$true)]
    [string]$DataSource,
    [Parameter(Mandatory=$false)] 
    [ValidateSet("all","odp.net2","odp.net4","oledb","odbc","odp.netmanaged","ldap")]
    [string[]]$Test = ("all","odp.net2","odp.net4","oledb","odbc","odp.netmanaged","ldap"),
    #Full Path to Oracle.ManagedDataAccess.dll
    [Parameter(Mandatory=$false)]
    [string]$ManagedDriverDll,
    [Parameter(Mandatory=$false)]
    #LDAPServer:portnumber
    [string[]]$LDAPServer
)


$all = @("odp.net2","odp.net4","oledb","odbc","odp.netmanaged","ldap")

#######################
function Test-odp.net2 {

    try {
        add-type -AssemblyName "Oracle.DataAccess, Version=2.121.2.0, Culture=neutral, PublicKeyToken=89b483f429c47342"
        $conn = New-Object Oracle.DataAccess.Client.OracleConnection("User Id=$UserId;Password=$Password;Data Source=$DataSource")
        $conn.open()
        New-Object psobject -property @{Test="Test-odp.net2";Args="$DataSource";Result=$true;Message=$null}
    }
    catch { new-object psobject -property @{Test="Test-odp.net2";Args="$DataSource";Result=$false;Message="$($_.ToString())"} }
    finally { $conn.Dispose() }

} #Test-odp.net2

#######################
function Test-odp.net4 {

    try {
        add-type -AssemblyName "Oracle.DataAccess, Version=4.121.2.0, Culture=neutral, PublicKeyToken=89b483f429c47342"
        $conn = New-Object Oracle.DataAccess.Client.OracleConnection("User Id=$UserId;Password=$Password;Data Source=$DataSource")
        $conn.open()
        New-Object psobject -property @{Test="Test-odp.net4";Args="$DataSource";Result=$true;Message=$null}
    }
    catch { new-object psobject -property @{Test="Test-odp.net4";Args="$DataSource";Result=$false;Message="$($_.ToString())"} }
    finally { $conn.Dispose() }

} #Test-odp.net4

#######################
function Test-oledb {

    try {
        $conn = New-Object System.Data.OleDb.OleDbConnection("User Id=$UserId;Password=$Password;Data Source=$DataSource;Provider=OraOLEDB.Oracle")
        $conn.open()
        New-Object psobject -property @{Test="Test-oledb";Args="$DataSource";Result=$true;Message=$null}
    }
    catch { new-object psobject -property @{Test="Test-oledb";Args="$DataSource";Result=$false;Message="$($_.ToString())"} }
    finally { $conn.Dispose() }

} #Test-oledb

#######################
function Test-odbc {

    try {
        $conn = New-Object System.Data.Odbc.OdbcConnection("DRIVER={Oracle ODBC Driver};UID=$UserId;PWD=$Password;DBQ=$DataSource;DBA=R;")
        $conn.open()
        New-Object psobject -property @{Test="Test-odbc";Args="$DataSource";Result=$true;Message=$null}
    }
    catch { new-object psobject -property @{Test="Test-odbc";Args="$DataSource";Result=$false;Message="$($_.ToString())"} }
    finally { $conn.Dispose() }

} #Test-odbc

#######################
function Test-odp.netmanaged {

    try {
        Add-Type -Path "$ManagedDriverDll"
        $conn = New-Object Oracle.ManagedDataAccess.Client.OracleConnection("User Id=$UserId;Password=$Password;Data Source=$DataSource")
        $conn.open()
        New-Object psobject -property @{Test="Test-odp.netmanaged";Args="$DataSource";Result=$true;Message=$null}
    }
    catch { new-object psobject -property @{Test="Test-odp.netmanaged";Args="$DataSource";Result=$false;Message="$($_.ToString())"} }
    finally { $conn.Dispose() }

} #Test-odp.netmanaged

#######################
function Test-ldap {

    try { 
        Add-Type -AssemblyName System.DirectoryServices.Protocols

        #Use LDAP servers from ldap.ora if LDAPServer param not specified
        if ($LDAPServer -eq $null) {
            $ht = gc "$((get-itemproperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' -Name TNS_ADMIN).TNS_ADMIN)\ldap.ora" |
            foreach { $_ -replace '\(|\)' } | ConvertFrom-StringData
            $LDAPServer = $ht.DIRECTORY_SERVERS -replace ' ' -split ','
        } 
    
        $LDAPServer | foreach {
                try {
                    $name=$_; $conn = New-Object System.DirectoryServices.Protocols.LdapConnection($name)
                    $conn.AuthType = [System.DirectoryServices.Protocols.AuthType]::Anonymous
                    $conn.Bind()
                    new-object psobject -property @{Test="Test-ldap";Args="$name";Result=$true;Message=$null}
                }
                catch { new-object psobject -property @{Test="$($PSCmdlet.MyInvocation.MyCommand.Name)";Args="$name";Result=$false;Message="$($_.ToString())"}  }
                finally { $conn.Dispose() }
        }
    }
    catch { new-object psobject -property @{Test="Test-ldap";Args=$null;Result=$false;Message="$($_.ToString())"}  }

} #Test-ldap

#######################
# Run Tests 
#######################

if ($Test -contains "all") {
     $all | foreach { invoke-expression "Test-$_" }
}
else {
    foreach ($t in $Test) {
        invoke-expression "Test-$t"
    }
}

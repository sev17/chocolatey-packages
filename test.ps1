#Manual tests
#Take VM snapshots before installing odac or odbc components to reset after each test. 
#The remaining packages don't mess with registry or .NET so no need

choco install tnsadmin -packageParameters "FROM_LOCATION=http://choco.local:8080/tnsadmin.zip;TNS_ADMIN=C:\Oracle\Tnsadmin" -s "$pwd" --force
choco install tnsadmin -packageParameters "FROM_LOCATION='\\vmware-host\Shared Folders\Desktop\rj-tnsadmin\Tnsadmin';TNS_ADMIN=C:\Oracle\Tnsadmin" -s "$pwd" --force

choco uninstall instantclient-jdbc-12_1
choco uninstall instantclient-sqlplus-12_1
choco uninstall instantclient-sqlplus-12_1 instantclient-jdbc-12_1 instantclient-12_1 -packageParameters "INSTANT_CLIENT_PATH=C:\Oracle\product\instantclient_12_1"

choco install instantclient-12_1 -packageParameters "FROM_LOCATION=\\vmware-host\Shared Folders\Desktop\oracle\windows\instantclient\120120;PROD_HOME=C:\Oracle\product" -s "$pwd" --force

choco install instantclient-jdbc-12_1 -packageParameters "FROM_LOCATION=\\vmware-host\Shared Folders\Desktop\oracle\windows\instantclient\120120;PROD_HOME=C:\Oracle\product" -s "$pwd;C:\orainstall\instantclient" --force

choco install instantclient-12_1 instantclient-sqlplus-12_1 instantclient-jdbc-12_1 -packageParameters "FROM_LOCATION=\\vmware-host\Shared Folders\Desktop\oracle\windows\instantclient\120120;PROD_HOME=C:\Oracle\product" -s "$pwd;C:\orainstall\instantclient-jdbc-12_1;C:\orainstall\instantclient-sqlplus-12_1" --force

choco install instantclient-odbc-12_1 -packageParameters "FROM_LOCATION=\\vmware-host\Shared Folders\Desktop\oracle\windows\instantclient\120120;PROD_HOME=C:\Oracle\product" -s "$pwd" -y --force

choco install oracle-sqldeveloper -packageParameters "FROM_LOCATION=\\vmware-host\Shared Folders\Desktop\oracle\windows\sqldeveloper;PROD_HOME=C:\Oracle\product\x86" -s "$pwd" --force --x86

choco install odac-12_1 -packageParameters "FROM_LOCATION=\\vmware-host\Shared Folders\Desktop\oracle\windows\odac;PROD_HOME=C:\Oracle\product;COMPONENT_LIST=odp.net4" -s "$pwd" --force

choco install odt-vs2015 -packageParameters "FROM_LOCATION=\\vmware-host\Shared Folders\Desktop\oracle\windows\odt;LINK_TNS=true" -s "$pwd"

choco install odac-x86_32-12_1 -packageParameters "FROM_LOCATION=\\vmware-host\Shared Folders\Desktop\oracle\windows\odac;PROD_HOME=C:\Oracle\product\x86;COMPONENT_LIST=odp.net4" -s "$pwd" --force

choco uninstall odac-x86_32-12_1 -packageParameters "ORACLE_HOME_PATH=C:\Oracle\x86\product\odac_12_1"

choco install C:\orainstall\packages.config\oracle-clienttools.config -y --force

choco install C:\orainstall\packages.config\odac-custom-x64x86.config -y --force

choco install oracle-manageddataaccess -s "https://chocolatey.org/api/v2/;$pwd"


#Manual tests
#Take VM snapshots before installing odac or odbc components to reset after each test. 
#The remaining packages don't mess with registry or .NET so no need

choco install tnsadmin -packageParameters "FROM_LOCATION=http://choco.local:8080/tnsadmin.zip;TNS_ADMIN=C:\Oracle\Tnsadmin" -s "$pwd" --force
choco install tnsadmin -packageParameters "FROM_LOCATION='\\vmware-host\Shared Folders\Desktop\rj-tnsadmin\Tnsadmin';TNS_ADMIN=C:\Oracle\Tnsadmin" -s "$pwd" --force

choco uninstall instantclient-jdbc-12.1
choco uninstall instantclient-sqlplus-12.1
choco uninstall instantclient-sqlplus-12.1 instantclient-jdbc-12.1 instantclient-12.1 -packageParameters "INSTANT_CLIENT_PATH=C:\Oracle\product\instantclient_12_1"

choco install instantclient-12.1 -packageParameters "FROM_LOCATION=\\vmware-host\Shared Folders\Desktop\oracle\windows\instantclient\120120;PROD_HOME=C:\Oracle\product" -s "$pwd" --force

choco install instantclient-jdbc-12.1 -packageParameters "FROM_LOCATION=\\vmware-host\Shared Folders\Desktop\oracle\windows\instantclient\120120;PROD_HOME=C:\Oracle\product" -s "$pwd;C:\orainstall\instantclient" --force

choco install instantclient-12.1 instantclient-sqlplus-12.1 instantclient-jdbc-12.1 -packageParameters "FROM_LOCATION=\\vmware-host\Shared Folders\Desktop\oracle\windows\instantclient\120120;PROD_HOME=C:\Oracle\product" -s "$pwd;C:\orainstall\instantclient-jdbc;C:\orainstall\instantclient-sqlplus" --force

choco install instantclient-odbc-12.1 -packageParameters "FROM_LOCATION=\\vmware-host\Shared Folders\Desktop\oracle\windows\instantclient\120120;PROD_HOME=C:\Oracle\product" -s "$pwd" -y --force

choco install sqldeveloper -packageParameters "FROM_LOCATION=\\vmware-host\Shared Folders\Desktop\oracle\windows\sqldeveloper;PROD_HOME=C:\Oracle\product\x86" -s "$pwd" --force --x86

choco install odac-12.1 -packageParameters "FROM_LOCATION=\\vmware-host\Shared Folders\Desktop\oracle\windows\odac;PROD_HOME=C:\Oracle\product;COMPONENT_LIST=odp.net4" -s "$pwd" --force

choco install odt-vs2015 -packageParameters "FROM_LOCATION=\\vmware-host\Shared Folders\Desktop\oracle\windows\odt;LINK_TNS=true" -s "$pwd"

choco install odac-x86_32-12.1 -packageParameters "FROM_LOCATION=\\vmware-host\Shared Folders\Desktop\oracle\windows\odac;PROD_HOME=C:\Oracle\product\x86;COMPONENT_LIST=odp.net4" -s "$pwd" --force

choco uninstall odac-x86_32-12.1 -packageParameters "ORACLE_HOME_PATH=C:\Oracle\product\x86\odac_12_1"

choco install C:\orainstall\packages.config\oracleclienttools.config -y --force


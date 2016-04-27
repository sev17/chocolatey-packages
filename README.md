Chocolatey Packages (sev17)
==================================

This repository contains chocolatey packages maintained by Chad Miller.

Variables to change to customize pacakges for your environment:


instantclient*

```
$FROM_LOCATION 
$PROD_HOME = "$env:ChocolateyInstall\lib\$parentPackageName"
$pathType = 'User'
```
  
odac*

```
$FROM_LOCATION 
$PROD_HOME = "$env:ChocolateyInstall\lib\$parentPackageName"
```
  
odt-vs2015

```
$FROM_LOCATION
$LINK_TNS
```
  
oracle-manageddataaccess

```
$PROD_HOME
```
  
oracle-sqldeveloper

```
$FROM_LOCATION 
$PROD_HOME = "$env:ChocolateyInstall\lib\$parentPackageName"
$pathType = 'User'
```
  
tnsadmin

```
$FROM_LOCATION = "$env:Temp"
$TNS_ADMIN = "$env:ChocolateyPackageFolder"
$pathType = 'User'
```
#We can't redistribute the custom client tnsping.exe and dlls, so you'll to create a zip archive from an existing
#custom client install and make package available in your environment. This script copies the needed files and 
#zips them up to be placed under instantclient-tnsping-12_1\tools

#You'll need both 64-bit and 32-bit binaries. Uncomment zipFileName to create 2nd archive
#Change value to your environment
$client = 'C:\Oracle\x86\product\12.1.0\client_1'
#Change value to your environment
#$tnspingTempDir = 'Z:\Desktop\Oracle\windows\instantclient-tnsping-12_1'
#$tnspingTempDir = 'Z:\Desktop\Oracle\windows\instantclient-tnsping-x86_32-12_1'
$tnspingTempDir = 'C:\orainstall\tnspingTempDir'
$zipFileName = "C:\orainstall\instantclient-tnsping-12_1\tools\instantclient-tnsping-12_1.zip"
#$zipFileName = "C:\orainstall\instantclient-tnsping-12_1\tools\instantclient-tnsping-x86_32-12_1.zip"
$tnsPingFiles = @('msvcp100.dll','msvcr100.dll','oraasmclnt12.dll','oracell12.dll','oraclient12.dll','oraclsce12.dll','oracommon12.dll','oracore12.dll','orageneric12.dll','orahasgen12.dll','oraldapclnt12.dll','oran12.dll','orancds12.dll','orancrypt12.dll','oranhost12.dll','oranl12.dll','oranldap12.dll','oranls12.dll','oranro12.dll','orantcp12.dll','orantns12.dll','oraocr12.dll','oraocrb12.dll','oraocrutl12.dll','oraplp12.dll','orapls12.dll','ORASLAX12.DLL','orasnls12.dll','oraunls12.dll','orauts.dll','oravsn12.dll','orawsec12.dll','oraxml12.dll','orazt12.dll','oraztkg12.dll','tnsping.exe')
$nlsFiles =@('lx00001.nlb', 'lx10001.nlb', 'lx1boot.nlb', 'lx20001.nlb', 'lx200b2.nlb', 'lx20369.nlb', 'lx40011.nlb')

if (!(test-path $tnspingTempDir)) {
    mkdir $tnspingTempDir
}

if (!(test-path "$tnspingTempDir\bin")) {
    mkdir "$tnspingTempDir\bin"
}

if (!(test-path "$tnspingTempDir\ldap\mesg")) {
    mkdir "$tnspingTempDir\ldap\mesg"
}

if (!(test-path "$tnspingTempDir\network\mesg")) {
    mkdir "$tnspingTempDir\network\mesg"
}

if (!(test-path "$tnspingTempDir\oracore\mesg")) {
    mkdir "$tnspingTempDir\oracore\mesg"
}

if (!(test-path "$tnspingTempDir\nls\data")) {
    mkdir "$tnspingTempDir\nls\data"
}

#Copy files

copy-item "$client\ldap\mesg\ldapus.msb" -destination "$tnspingTempDir\ldap\mesg\ldapus.msb"
copy-item "$client\network\mesg\tnsus.msb" -destination "$tnspingTempDir\network\mesg\tnsus.msb"
copy-item "$client\oracore\mesg\lrmus.msb" -destination "$tnspingTempDir\oracore\mesg\lrmus.msb"

pushd "$client\nls\data"
copy-item  $nlsFiles -Destination "$tnspingTempDir\nls\data"

pushd "$client\bin"
copy-item "orantcp12.dll" -destination "$tnspingTempDir\bin\orantcp12.dll"
copy-item $tnsPingFiles -Destination $tnspingTempDir

#Zip up tnsping for packaging
 &"$env:ChocolateyInstall\tools\7za.exe" a -r "$zipFileName" "$tnspingTempDir\*"

 #Now Run build.ps1 under chocolatey-packages directory to choco pack all packages

#We can't redistribute the custom client tnsping.exe and dlls, so you'll to create a zip archive from an existing
#custom client install and make package available in your environment. This script copies the needed files and 
#zips them up to be placed under instantclient-tnsping-12_1\tools

#You'll need both 64-bit and 32-bit binaries. Uncomment zipFileName to create 2nd archive
#Change value to your environment
$client_network = 'C:\Oracle\x86\product\12.1.0\client_1\network\mesg'
$systemDir = "$env:SystemRoot\system32"
#$systemDir64 = "$env:SystemRoot\SysWOW64"
#Change value to your environment
$client_bin= 'C:\Oracle\x86\product\12.1.0\client_1\bin'
#Change value to your environment
$tnspingTempDir = 'C:\orainstall\tnspingTempDir'
$zipFileName = "C:\orainstall\instantclient-tnsping-12_1\tools\instantclient-tnsping-12_1.zip"
#$zipFileName = "C:\orainstall\instantclient-tnsping-x86_32-12_1\tools\instantclient-tnsping-x86_32-12_1.zip"
$pathList = @('oraasmclnt12.dll','oracell12.dll','oraclient12.dll','oraclsce12.dll','oracommon12.dll','oracore12.dll','orageneric12.dll','orahasgen12.dll','oraldapclnt12.dll','oran12.dll','orancds12.dll','orancrypt12.dll','oranhost12.dll','oranl12.dll','oranldap12.dll','oranls12.dll','oranro12.dll','orantcp12.dll','orantns12.dll','oraocr12.dll','oraocrb12.dll','oraocrutl12.dll','oraplp12.dll','orapls12.dll','ORASLAX12.DLL','orasnls12.dll','oraunls12.dll','orauts.dll','oravsn12.dll','orawsec12.dll','oraxml12.dll','orazt12.dll','oraztkg12.dll','tnsping.exe')

if (!(test-path $tnspingTempDir)) {
    mkdir $tnspingTempDir
}

#Grab C++ redistributable dll's if applicable.
#@('msvcp100.dll','msvcr100.dll') | % { copy-item "$systemDir\$_" -destination $tnspingTempDir -whatif }
#@('msvcp100.dll','msvcr100.dll') | % { copy-item "$systemDir64\$_" -destination $tnspingTempDir -whatif }

#Copy mesg folder and directory structure
copy-item $client_network -destination "$destination\network\mesg" -Recurse

#Copy required dll's and tnsping.exe
pushd $client_bin
copy-item $pathList -Destination $tnspingTempDir -Recurse

#$tnspingTempDir = 'Z:\Desktop\Oracle\windows\instantclient-tnsping-12_1'
#$tnspingTempDir = 'Z:\Desktop\Oracle\windows\instantclient-tnsping-x86_32-12_1'
#Zip up tnsping for packaging
 &"$env:ChocolateyInstall\tools\7za.exe" a -r "$zipFileName" "$tnspingTempDir\*"

 #Now Run build.ps1 under chocolatey-packages directory to choco pack all packages

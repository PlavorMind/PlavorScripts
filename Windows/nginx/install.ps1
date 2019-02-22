#nginx installer
#Installs nginx.

param([string]$dir="C:/nginx",[string]$version="1.15.8")

."${PSScriptRoot}/../../modules/OSDetectorDebug.ps1"
."${PSScriptRoot}/../../modules/SetTempDir.ps1"

if (!($isWindows))
{"Your operating system is not supported."
exit}

"Downloading Configurations repository archive"
Invoke-WebRequest "https://github.com/PlavorMind/Configurations/archive/Main.zip" -OutFile "${tempdir}/Configurations.zip"
if (Test-Path "${tempdir}/Configurations.zip")
{"Extracting"
Expand-Archive "${tempdir}/Configurations.zip" $env:temp -Force
"Deleting a temporary file"
Remove-Item "${tempdir}/Configurations.zip" -Force}
else
{"Configurations repository archive download is failed!"
exit}

"Downloading nginx archive"
Invoke-WebRequest "http://nginx.org/download/nginx-${version}.zip" -OutFile "${tempdir}/nginx.zip"
if (Test-Path "${tempdir}/nginx.zip")
{"Extracting"
Expand-Archive "${tempdir}/nginx.zip" $tempdir -Force
"Deleting a temporary file"
Remove-Item "${tempdir}/nginx.zip" -Force
"Renaming nginx directory"
Move-Item "${tempdir}/nginx-*" "${tempdir}/nginx" -Force}
else
{"nginx archive download is failed!"
exit}

."${env:temp}\nginx\fetch_nginx_conf.ps1"

"Configuring default web directory"
New-Item "${env:temp}\nginx\web" -Force -ItemType Directory
Move-Item "${env:temp}\nginx\html" "${env:temp}\nginx\web\Main" -Force
Move-Item "${env:temp}\Configurations-Main\Web\*" "${env:temp}\nginx\web\Main\" -Force
"Deleting a temporary directory"
Remove-Item "${env:temp}\Configurations-Main" -Force -Recurse

"Deleting unnecessary files"
"Warning: This will remove documentations and license notices that are unnecessary for running."
Remove-Item "${env:temp}\nginx\contrib" -Force -Recurse
Remove-Item "${env:temp}\nginx\docs" -Force -Recurse
Remove-Item "${env:temp}\nginx\web\Main\50x.html" -Force

."${PSScriptRoot}\uninstall.ps1" -dir "${env:temp}\nginx" -soft

if (Test-Path $dir)
{"Renaming existing nginx directory"
Move-Item $dir "${dir}_old" -Force}

"Moving nginx directory"
Move-Item "${env:temp}\nginx" $dir -Force

."${dir}\create_service.ps1"

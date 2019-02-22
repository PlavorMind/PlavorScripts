#nginx installer
#Installs nginx.

param([string]$dir="C:/nginx",[string]$version="1.15.8")

."${PSScriptRoot}/../../modules/OSDetectorDebug.ps1"
."${PSScriptRoot}/../../modules/SetTempDir.ps1"

if (!($isWindows))
{"Your operating system is not supported."
exit}

"Downloading nginx archive"
Invoke-WebRequest "http://nginx.org/download/nginx-${version}.zip" -OutFile "${tempdir}/nginx.zip"
if (Test-Path "${tempdir}/nginx.zip")
{"Extracting"
Expand-Archive "${tempdir}/nginx.zip" $tempdir -Force
"Deleting a temporary file"
Remove-Item "${env:temp}\nginx.zip" -Force
"Renaming nginx directory"
Move-Item "${env:temp}\nginx-*" "${env:temp}\nginx" -Force}
else
{"nginx archive download is failed!"
exit}

"Downloading Configurations repository archive"
Invoke-WebRequest "https://github.com/PlavorMind/Configurations/archive/Main.zip" -OutFile "${env:temp}\Configurations.zip"
if (Test-Path "${env:temp}\Configurations.zip")
{"Extracting"
Expand-Archive "${env:temp}\Configurations.zip" $env:temp -Force
"Deleting a temporary file"
Remove-Item "${env:temp}\Configurations.zip" -Force}
else
{"Configurations repository archive download is failed!"
exit}

"Downloading create_service.ps1 file"
Invoke-WebRequest "https://raw.githubusercontent.com/PlavorSeol/Scripts/Main/Windows/nginx/install_data/create_service.ps1" -OutFile "${env:temp}\nginx\create_service.ps1"
if (!(Test-Path "${env:temp}\nginx\create_service.ps1"))
{"create_service.ps1 file download is failed!"
exit}

"Downloading fetch_nginx_conf.ps1 file"
Invoke-WebRequest "https://raw.githubusercontent.com/PlavorSeol/Scripts/Main/Windows/nginx/install_data/fetch_nginx_conf.ps1" -OutFile "${env:temp}\nginx\fetch_nginx_conf.ps1"
if (!(Test-Path "${env:temp}\nginx\fetch_nginx_conf.ps1"))
{"fetch_nginx_conf.ps1 file download is failed!"
exit}

"Downloading remove_service.ps1 file"
Invoke-WebRequest "https://raw.githubusercontent.com/PlavorSeol/Scripts/Main/Windows/nginx/install_data/remove_service.ps1" -OutFile "${env:temp}\nginx\remove_service.ps1"
if (!(Test-Path "${env:temp}\nginx\remove_service.ps1"))
{"remove_service.ps1 file download is failed!"
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

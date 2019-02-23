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
Remove-Item "${tempdir}/nginx.zip" -Force
"Renaming nginx directory"
Move-Item "${tempdir}/nginx-*" "${tempdir}/nginx" -Force}
else
{"nginx archive download is failed!"
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

"Configuring default web directory"
New-Item "${tempdir}/nginx/web" -Force -ItemType Directory
Copy-Item "${tempdir}/Configurations-Main/Web" "${tempdir}/nginx/web/Main" -Force -Recurse
Move-Item "${tempdir}/nginx/html/index.html" "${tempdir}/nginx/web/Main/" -Force
Remove-Item "${tempdir}/nginx/html" -Force -Recurse
Copy-Item "${tempdir}/Configurations-Main/Web" "${tempdir}/nginx/web/Wiki" -Force -Recurse
"Deleting a temporary directory"
Remove-Item "${tempdir}/Configurations-Main" -Force -Recurse

."${PSScriptRoot}/../../filter_nginx_conf.ps1" -savepath "${tempdir}/nginx/conf/nginx.conf"
if (!($fnc_success))
{"Cannot filter nginx.conf file."
exit}

"Deleting unnecessary files"
"Warning: This will remove documentations and license notices that are unnecessary for running."
Remove-Item "${tempdir}/nginx/contrib" -Force -Recurse
Remove-Item "${tempdir}/nginx/docs" -Force -Recurse
Remove-Item "${tempdir}/nginx/web/Main/50x.html" -Force

"Stopping nginx"
Stop-Process -Force -Name "nginx"
"Stopping PHP FastCGI"
Stop-Process -Force -Name "php-cgi"

if (Test-Path $dir)
{"Renaming existing nginx directory"
Move-Item $dir "${dir}_old" -Force}

"Moving nginx directory"
Move-Item "${tempdir}/nginx" $dir -Force
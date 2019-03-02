#nginx installer
#Installs nginx.

param
([string]$dir="C:/nginx", #Directory to install nginx
[string]$version="1.15.9") #Version to install

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
{"Cannot download nginx archive."
exit}

"Configuring nginx directories"
New-Item "${tempdir}/nginx/logs/Main" -Force -ItemType Directory
New-Item "${tempdir}/nginx/logs/Wiki" -Force -ItemType Directory

$dir_temp=$dir
."${PSScriptRoot}/../../config_web_dir.ps1" -dir "${tempdir}/nginx/web"
if ($cwd_success)
{Remove-Item "${tempdir}/nginx/html" -Force -Recurse}
else
{"Cannot configure web server directories."
exit}
$dir=$dir_temp

"Copying additional files"
Copy-Item "${PSScriptRoot}/install_data/start.ps1" "${tempdir}/nginx/" -Force
Copy-Item "${PSScriptRoot}/install_data/stop.ps1" "${tempdir}/nginx/" -Force

if (Test-Path "${PSScriptRoot}/private")
{"Copying private directory"
Copy-Item "${PSScriptRoot}/private" "${tempdir}/nginx/conf/" -Force -Recurse}

."${PSScriptRoot}/../../filter_nginx_conf.ps1" -savepath "${tempdir}/nginx/conf/nginx.conf"
if (!($fnc_success))
{"Cannot filter nginx.conf file."
exit}

"Deleting unnecessary files"
"Warning: This will remove documentations and license notices that are unnecessary for running."
Remove-Item "${tempdir}/nginx/contrib" -Force -Recurse
Remove-Item "${tempdir}/nginx/docs" -Force -Recurse

if (Get-Process "nginx" -ErrorAction Ignore)
{"Stopping nginx"
Stop-Process -Force -Name "nginx"}
#if (Get-Process "php-cgi" -ErrorAction Ignore)
#{"Stopping PHP CGI/FastCGI"
#Stop-Process -Force -Name "php-cgi"}

if (Test-Path $dir)
{"Renaming existing nginx directory"
Move-Item $dir "${dir}_old" -Force}

"Moving nginx directory"
Move-Item "${tempdir}/nginx" $dir -Force

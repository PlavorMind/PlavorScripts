#nginx installer
#Installs nginx.

param
([string]$adminer_version="4.7.1", #Adminer version to download
[string]$dir="C:/nginx", #Directory to install nginx
[string]$version="1.17.0") #nginx version to install

."${PSScriptRoot}/../../init_script.ps1"

if (!$IsWindows)
{"Your operating system is not supported."
exit}

"Downloading Configurations repository archive"
Invoke-WebRequest "https://github.com/PlavorMind/Configurations/archive/Main.zip" -DisableKeepAlive -OutFile "${tempdir}/Configurations.zip"
if (Test-Path "${tempdir}/Configurations.zip")
{"Extracting"
Expand-Archive "${tempdir}/Configurations.zip" $tempdir -Force
"Deleting a temporary file"
Remove-Item "${tempdir}/Configurations.zip" -Force}
else
{"Cannot download Configurations repository archive."
exit}

"Downloading nginx archive"
Invoke-WebRequest "http://nginx.org/download/nginx-${version}.zip" -DisableKeepAlive -OutFile "${tempdir}/nginx.zip"
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

"Copying configuration files"
Copy-Item "${tempdir}/Configurations-Main/nginx/*" "${tempdir}/nginx/conf/" -Force -Recurse
."${PSScriptRoot}/../../filter_nginx_conf.ps1" -destpath "${tempdir}/nginx/conf/nginx.conf" -path "${tempdir}/Configurations-Main/nginx/nginx.conf"

"Copying web directory"
Copy-Item "${tempdir}/Configurations-Main/Web" "${tempdir}/nginx/web" -Force -Recurse
Move-Item "${tempdir}/nginx/html/index.html" "${tempdir}/nginx/web/main/" -Force
New-Item "${tempdir}/nginx/web/public" -Force -ItemType Directory
"<!DOCTYPE html>" > "${tempdir}/nginx/web/public/index.html"
New-Item "${tempdir}/nginx/web/wiki" -Force -ItemType Directory

"Downloading Adminer"
Invoke-WebRequest "https://github.com/vrana/adminer/releases/download/v${adminer_version}/adminer-${adminer_version}-en.php" -DisableKeepAlive -OutFile "${tempdir}/nginx/web/main/adminer.php"

"Creating log directories"
New-Item "${tempdir}/nginx/logs/main" -Force -ItemType Directory
New-Item "${tempdir}/nginx/logs/public" -Force -ItemType Directory
New-Item "${tempdir}/nginx/logs/wiki" -Force -ItemType Directory

"Copying install data"
Copy-Item "${PSScriptRoot}/install_data/start.ps1" "${tempdir}/nginx/" -Force
Copy-Item "${PSScriptRoot}/install_data/stop.ps1" "${tempdir}/nginx/" -Force

if (Test-Path "${PSScriptRoot}/additional_files")
{"Copying additional files"
Copy-Item "${PSScriptRoot}/additional_files/*" "${tempdir}/nginx/" -Force -Recurse}

"Deleting a temporary directory"
Remove-Item "${tempdir}/Configurations-Main" -Force -Recurse

"Deleting unnecessary files"
"Warning: This will remove documentations and license notices that are unnecessary for running."
Remove-Item "${tempdir}/nginx/contrib" -Force -Recurse
Remove-Item "${tempdir}/nginx/docs" -Force -Recurse

if (Get-Process "nginx" -ErrorAction Ignore)
{"Stopping nginx"
Stop-Process -Force -Name "nginx"}

if (Test-Path $dir)
{"Renaming existing nginx directory"
Move-Item $dir "${dir}_old" -Force}

"Moving nginx directory"
Move-Item "${tempdir}/nginx" $dir -Force

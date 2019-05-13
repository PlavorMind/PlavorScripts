#nginx installer
#Installs nginx.

param
([string]$dir="C:/nginx", #Directory to install nginx
[string]$version="1.16.0") #Version to install

."${PSScriptRoot}/../../init_script.ps1"

if (!$isWindows)
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

if (Test-Path "${PSScriptRoot}/private")
{"Copying private directory"
Copy-Item "${PSScriptRoot}/private" "${tempdir}/nginx/conf/" -Force -Recurse}

"Copying web directory"
Copy-Item "${tempdir}/Configurations-Main/Web" "${tempdir}/nginx/web" -Force -Recurse

"Creating log directories"
New-Item "${tempdir}/nginx/logs/main" -Force -ItemType Directory
New-Item "${tempdir}/nginx/logs/public" -Force -ItemType Directory
New-Item "${tempdir}/nginx/logs/wiki" -Force -ItemType Directory

"Copying additional files"
Copy-Item "${PSScriptRoot}/install_data/start.ps1" "${tempdir}/nginx/" -Force
Copy-Item "${PSScriptRoot}/install_data/stop.ps1" "${tempdir}/nginx/" -Force

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

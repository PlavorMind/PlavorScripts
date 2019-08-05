#nginx installer
#Installs nginx.

param
([string]$dir="C:/plavormind/nginx", #Directory to install nginx
[string]$version="1.17.2", #nginx version to install
[string]$web_dir="C:/plavormind/web") #Web server directory

if (Test-Path "${PSScriptRoot}/../../init_script.ps1")
{."${PSScriptRoot}/../../init_script.ps1"}
else
{"Cannot find initialize script."
exit}

if (!$IsWindows)
{"Your operating system is not supported."
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

$dir_temp=$dir
."${PSScriptRoot}/../../filter_nginx_config.ps1" -dir "${tempdir}/nginx/conf"
$dir=$dir_temp
if (!(Test-Path "${tempdir}/nginx/conf/nginx.conf"))
{exit}

if (Test-Path $web_dir)
{[System.Collections.ArrayList]$virtual_hosts=Get-ChildItem $web_dir -Directory -Force -Name
$virtual_hosts.Remove("global")
"Creating log directories"
foreach ($virtual_host in $virtual_hosts)
  {New-Item "${tempdir}/nginx/logs/${virtual_host}" -Force -ItemType Directory}
}

"Copying install data"
Copy-Item "${PSScriptRoot}/install_data/start.ps1" "${tempdir}/nginx/" -Force
Copy-Item "${PSScriptRoot}/install_data/stop.ps1" "${tempdir}/nginx/" -Force

if (Test-Path "${PSScriptRoot}/additional_files")
{"Copying additional files"
Copy-Item "${PSScriptRoot}/additional_files/*" "${tempdir}/nginx/" -Force -Recurse}

"Deleting unnecessary files"
"Warning: This will remove documentations and license notices that are unnecessary for running."
Remove-Item "${tempdir}/nginx/contrib" -Force -Recurse
Remove-Item "${tempdir}/nginx/docs" -Force -Recurse
Remove-Item "${tempdir}/nginx/html" -Force -Recurse

if (Get-Process "nginx" -ErrorAction Ignore)
{"Stopping nginx"
Stop-Process -Force -Name "nginx"}

if (Test-Path $dir)
{"Renaming existing nginx directory"
Move-Item $dir "${dir}_old" -Force}

"Moving nginx directory"
Move-Item "${tempdir}/nginx" $dir -Force

if (Test-AdminPermission)
{."${PSScriptRoot}/create_task.ps1" -path "${dir}/start.ps1"}

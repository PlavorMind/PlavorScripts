#nginx upgrader
#Upgrades nginx.

param
([string]$dir="C:/nginx", #Directory that nginx is installed
[string]$version="1.17.0") #Version to upgrade

."${PSScriptRoot}/../../init_script.ps1"

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

if (Get-Process "nginx" -ErrorAction Ignore)
{"Stopping nginx"
Stop-Process -Force -Name "nginx"}

"Moving nginx.exe file"
Move-Item "${tempdir}/nginx/nginx.exe" $dir -Force

"Deleting a temporary directory"
Remove-Item "${tempdir}/nginx" -Force -Recurse

"Starting nginx"
Start-Process "${dir}/nginx.exe" -WorkingDirectory $dir

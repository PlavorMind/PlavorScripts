#Copys additional files for install.ps1 script

Param([Parameter(Position=0)][string]$apache_httpd_dir="C:/plavormind/apache-httpd") #Apache HTTP Server directory

if (Test-Path "${PSScriptRoot}/../../init-script.ps1")
{."${PSScriptRoot}/../../init-script.ps1"}
else
{Write-Error "Cannot find initialize script." -Category ObjectNotFound
exit}

if (!$IsWindows)
{Write-Error "Your operating system is not supported."
exit}

if (!(Test-Path $apache_httpd_dir))
{Write-Error "Cannot find Apache HTTP Server." -Category NotInstalled
exit}
#End of preconditions

if (Test-Path "${PSScriptRoot}/additional-files")
{Move-Item "${PSScriptRoot}/additional-files" "${PSScriptRoot}/additional-files-old" -Force}
New-Item "${PSScriptRoot}/additional-files" -Force -ItemType Directory

if (Test-Path "${apache_httpd_dir}/conf/private")
{New-Item "${PSScriptRoot}/additional-files/conf" -Force -ItemType
Copy-Item "${apache_httpd_dir}/conf/private" "${PSScriptRoot}/additional-files/conf/" -Force -Recurse}

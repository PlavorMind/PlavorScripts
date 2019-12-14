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

if (Test-Path "${PSScriptRoot}/additional-files")
{Write-Warning "Renaming existing directory for additional files"
Move-Item "${PSScriptRoot}/additional-files" "${PSScriptRoot}/additional-files-old" -Force}
Write-Verbose "Creating a directory for additioanl files"
New-Item "${PSScriptRoot}/additional-files" -Force -ItemType Directory

if (Test-Path "${apache_httpd_dir}/conf/private")
{Write-Verbose "Creating conf directory"
New-Item "${PSScriptRoot}/additional-files/conf" -Force -ItemType Directory
Write-Verbose "Copying conf/private directory"
Copy-Item "${apache_httpd_dir}/conf/private" "${PSScriptRoot}/additional-files/conf/" -Force -Recurse}

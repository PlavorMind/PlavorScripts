#Installs PHP with some other software depends on it.

Param
([string]$apcu_archive="https://windows.php.net/downloads/pecl/releases/apcu/5.1.19/php_apcu-5.1.19-7.4-ts-vc15-x64.zip", #File path or URL of APCu archive
[Parameter(Position=0)][string]$dir, #Directory to install PHP
[string]$php_archive="https://windows.php.net/downloads/releases/php-7.4.13-Win32-vc15-x64.zip", #File path or URL of PHP archive
[switch]$portable) #Install in portable mode

if (Test-Path "${PSScriptRoot}/../../init-script.ps1")
{if (!(."${PSScriptRoot}/../../init-script.ps1"))
  {exit}
}
else
{Write-Error "Cannot find init-script.ps1 file." -Category ObjectNotFound
exit}

if (!$IsWindows)
{Write-Error "Your operating system is not supported."
exit}

if (!$dir)
{$dir="${PlaScrDefaultBaseDirectory}/php"}

if (!($portable -or (Test-AdminPermission)))
{Write-Error "This script must be run as administrator unless you install in portable mode." -Category PermissionDenied
exit}

if (Test-Path "${PlaScrDirectory}/filter-php-ini.ps1")
{."${PlaScrDirectory}/filter-php-ini.ps1" -destpath "${PlaScrTempDirectory}/filtered-php.ini"
if (!(Test-Path "${PlaScrTempDirectory}/filtered-php.ini"))
  {exit}
}
else
{Write-Error "Cannot find filter-php-ini.ps1 file." -Category ObjectNotFound
exit}

Expand-ArchiveSmart $php_archive "${PlaScrTempDirectory}/php"
if (!(Test-Path "${PlaScrTempDirectory}/php"))
{Write-Error "Cannot download or find PHP." -Category ObjectNotFound
exit}

Expand-ArchiveSmart $apcu_archive "${PlaScrTempDirectory}/apcu"
if (Test-Path "${PlaScrTempDirectory}/apcu")
{Write-Verbose "Moving APCu extension"
Move-Item "${PlaScrTempDirectory}/apcu/php_apcu.dll" "${PlaScrTempDirectory}/php/ext/" -Force
Write-Verbose "Deleting a temporary directory"
Remove-Item "${PlaScrTempDirectory}/apcu" -Force -Recurse}
else
{Write-Error "Cannot download or find APCu extension." -Category ObjectNotFound}

Write-Verbose "Moving php.ini file"
Move-Item "${PlaScrTempDirectory}/filtered-php.ini" "${PlaScrTempDirectory}/php/php.ini" -Force

Write-Verbose "Creating data directory"
New-Item "${PlaScrTempDirectory}/php/data" -Force -ItemType Directory

Write-Verbose "Downloading CA certificate"
Invoke-WebRequest "https://curl.haxx.se/ca/cacert.pem" -DisableKeepAlive -OutFile "${PlaScrTempDirectory}/php/data/cacert.pem"
if (!(Test-Path "${PlaScrTempDirectory}/php/data/cacert.pem"))
{Write-Error "Cannot download CA certificate." -Category ConnectionError}

Write-Verbose "Copying install data"
Copy-Item "${PSScriptRoot}/install-data/start.ps1" "${PlaScrTempDirectory}/php/" -Force
Copy-Item "${PSScriptRoot}/install-data/stop.ps1" "${PlaScrTempDirectory}/php/" -Force

Write-Verbose "Deleting files and a directory that are unnecessary for running"
Remove-Item "${PlaScrTempDirectory}/php/license.txt" -Force
Remove-Item "${PlaScrTempDirectory}/php/news.txt" -Force
Remove-Item "${PlaScrTempDirectory}/php/php.ini-development" -Force
Remove-Item "${PlaScrTempDirectory}/php/php.ini-production" -Force
Remove-Item "${PlaScrTempDirectory}/php/README.md" -Force
Remove-Item "${PlaScrTempDirectory}/php/readme-redist-bins.txt" -Force
Remove-Item "${PlaScrTempDirectory}/php/snapshot.txt" -Force

if (Test-Path $dir)
{Write-Warning "Uninstalling existing PHP"
if ($portable)
  {."${PSScriptRoot}/uninstall.ps1" $dir -portable}
else
  {."${PSScriptRoot}/uninstall.ps1" $dir}
}
Write-Verbose "Moving PHP directory to destination directory"
Move-Item "${PlaScrTempDirectory}/php" $dir -Force

if (!$portable)
{if (!(Test-Path "${PlaScrDefaultBaseDirectory}/path"))
  {Write-Verbose "Creating a directory for PATH"
  New-Item "${PlaScrDefaultBaseDirectory}/path" -Force -ItemType Directory}
Write-Verbose "Creating a script for PATH"
"@echo off" > "${PlaScrDefaultBaseDirectory}/path/php.cmd"
"`"${dir}/php.exe`" %*" >> "${PlaScrDefaultBaseDirectory}/path/php.cmd"

."${PSScriptRoot}/scheduled-task.ps1" -dir $dir}

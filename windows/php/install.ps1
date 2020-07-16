#Installs PHP with some other software depends on it.

Param
([string]$apcu_archive="https://windows.php.net/downloads/pecl/releases/apcu/5.1.18/php_apcu-5.1.18-7.4-ts-vc15-x64.zip", #File path or URL of APCu archive
[Parameter(Position=0)][string]$dir="C:/plavormind/php-ts", #Directory to install PHP
[string]$php_archive="https://windows.php.net/downloads/snaps/php-7.4/r27bb0d9/php-7.4-ts-windows-vc15-x64-r27bb0d9.zip", #File path or URL of PHP archive
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

if (!($portable -or (Test-AdminPermission)))
{Write-Error "This script must be run as administrator unless you install in portable mode." -Category PermissionDenied
exit}

if (Test-Path "${PSScriptRoot}/../../filter-php-ini.ps1")
{."${PSScriptRoot}/../../filter-php-ini.ps1" -destpath "${PlaScrTempDirectory}/filtered-php.ini"
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

Write-Verbose "Downloading Composer"
Invoke-WebRequest "https://getcomposer.org/composer.phar" -DisableKeepAlive -OutFile "${PlaScrTempDirectory}/php/data/composer.phar"
if (!(Test-Path "${PlaScrTempDirectory}/php/data/composer.phar"))
{Write-Error "Cannot download Composer." -Category ConnectionError}

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
Remove-Item "${PlaScrTempDirectory}/php/logs" -Force -Recurse

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
{Write-Verbose "Creating a scheduled task for starting PHP CGI/FastCGI automatically"
if (Test-Path "C:/Program Files/PowerShell/7-preview/pwsh.exe")
  {$action=New-ScheduledTaskAction "C:/Program Files/PowerShell/7-preview/pwsh.exe" "-ExecutionPolicy Bypass `"${path}`""}
else
  {$action=New-ScheduledTaskAction "powershell" "-ExecutionPolicy Bypass `"${path}`""}
$principal=New-ScheduledTaskPrincipal "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$settings=New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -Compatibility Win8 -DontStopIfGoingOnBatteries -DontStopOnIdleEnd -ExecutionTimeLimit 0
$trigger=New-ScheduledTaskTrigger -AtStartup
Register-ScheduledTask "PHP CGI FastCGI" -Action $action -Description "Starts PHP CGI/FastCGI" -Force -Principal $principal -Settings $settings -Trigger $trigger}

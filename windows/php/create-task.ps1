#Creates task for starting PHP CGI/FastCGI automatically.

Param([Parameter(Position=0)][string]$path="C:/plavormind/php-ts/start.ps1") #Path to start.ps1 file

if (Test-Path "${PSScriptRoot}/../../init-script.ps1")
{."${PSScriptRoot}/../../init-script.ps1"}
else
{Write-Error "Cannot find initialize script." -Category ObjectNotFound
exit}

if (!(Test-AdminPermission))
{Write-Error "This script must be run as administrator on Windows." -Category PermissionDenied
exit}

Write-Verbose "Creating task for starting PHP CGI/FastCGI automatically"
if (Test-Path "C:/Program Files/PowerShell/7-preview/pwsh.exe")
{$action=New-ScheduledTaskAction "C:/Program Files/PowerShell/7-preview/pwsh.exe" "-ExecutionPolicy Bypass `"${path}`""}
else
{$action=New-ScheduledTaskAction "powershell" "-ExecutionPolicy Bypass `"${path}`""}
$principal=New-ScheduledTaskPrincipal "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$settings=New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -Compatibility Win8 -DontStopIfGoingOnBatteries -DontStopOnIdleEnd -ExecutionTimeLimit 0
$trigger=New-ScheduledTaskTrigger -AtStartup
Register-ScheduledTask "PHP-CGI" -Action $action -Description "Start PHP CGI/FastCGI" -Force -Principal $principal -Settings $settings -Trigger $trigger

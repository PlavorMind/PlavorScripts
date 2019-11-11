#Creates task to start PHP CGI/FastCGI automatically.

Param([Parameter(Position=0)][string]$path="C:/plavormind/php-nts/start.ps1") #Path to start.ps1 file

if (Test-Path "${PSScriptRoot}/../../init_script.ps1")
{."${PSScriptRoot}/../../init_script.ps1"}
else
{"Cannot find initialize script."
exit}

if (!(Test-AdminPermission))
{"This script must be run as administrator on Windows."
exit}

"Creating a task"
if (Test-Path "C:/Program Files/PowerShell/7-preview/pwsh.exe")
{$action=New-ScheduledTaskAction "C:/Program Files/PowerShell/7-preview/pwsh.exe" "-ExecutionPolicy Bypass `"${path}`""}
else
{$action=New-ScheduledTaskAction "powershell" "-ExecutionPolicy Bypass `"${path}`""}
$principal=New-ScheduledTaskPrincipal "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$settings=New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -Compatibility Win8 -DontStopIfGoingOnBatteries -DontStopOnIdleEnd -ExecutionTimeLimit 0
$trigger=New-ScheduledTaskTrigger -AtStartup
Register-ScheduledTask "PHP-CGI" -Action $action -Description "Start PHP CGI/FastCGI" -Force -Principal $principal -Settings $settings -Trigger $trigger

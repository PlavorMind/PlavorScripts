#Creates task to start nginx automatically.

Param([Parameter(Position=0)][string]$path="C:/plavormind/nginx/start.ps1") #Path to start.ps1 file

if (Test-Path "${PSScriptRoot}/../../init-script.ps1")
{."${PSScriptRoot}/../../init-script.ps1"}
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
Register-ScheduledTask "nginx" -Action $action -Description "Start nginx" -Force -Principal $principal -Settings $settings -Trigger $trigger
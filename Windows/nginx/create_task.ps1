#Create nginx autostart task
#Creates task to start nginx automatically.

param([string]$path="C:/nginx/start.ps1") #Path to start.ps1 file

."${PSScriptRoot}/../../init_script.ps1"

if (!$isWindows)
{"Your operating system is not supported."
exit}

"Creating a task"
if (Test-Path "C:/Program Files/PowerShell/6-preview/pwsh.exe")
{$action=New-ScheduledTaskAction "C:/Program Files/PowerShell/6-preview/pwsh.exe" "`"${path}`" -ExecutionPolicy Bypass"}
else
{$action=New-ScheduledTaskAction "powershell" "`"${path}`" -ExecutionPolicy Bypass"}
$principal=New-ScheduledTaskPrincipal "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$settings=New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -Compatibility Win8 -DontStopIfGoingOnBatteries -DontStopOnIdleEnd -ExecutionTimeLimit 0
$trigger=New-ScheduledTaskTrigger -AtStartup
Register-ScheduledTask "nginx" -Action $action -Description "Start nginx" -Force -Principal $principal -Settings $settings -Trigger $trigger

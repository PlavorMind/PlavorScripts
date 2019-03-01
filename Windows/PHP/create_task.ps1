#Create PHP CGI/FastCGI autostart task
#Creates task to start PHP CGI/FastCGI automatically.

param([string]$path="C:/PHP/start.ps1") #Path to start.ps1 file

."${PSScriptRoot}/../../modules/OSDetectorDebug.ps1"

if (!($isWindows))
{"Your operating system is not supported."
exit}

"Creating task"
$action=New-ScheduledTaskAction "powershell" "`"${path}`" -ExecutionPolicy Bypass"
$principal=New-ScheduledTaskPrincipal "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$settings=New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -Compatibility Win8 -DontStopIfGoingOnBatteries -DontStopOnIdleEnd -ExecutionTimeLimit 0
$trigger=New-ScheduledTaskTrigger -AtStartup
Register-ScheduledTask "PHP-CGI" -Action $action -Description "Start PHP CGI/FastCGI" -Force -Principal $principal -Settings $settings -Trigger $trigger

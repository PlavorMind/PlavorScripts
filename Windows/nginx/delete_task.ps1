#Delete nginx autostart task
#Deletes task to start nginx automatically.

if (Test-Path "${PSScriptRoot}/../../init_script.ps1")
{."${PSScriptRoot}/../../init_script.ps1"}
else
{"Cannot find initialize script."
exit}

if (!$IsWindows)
{"Your operating system is not supported."
exit}

"Deleting a task"
Unregister-ScheduledTask "nginx" -Confirm:$false

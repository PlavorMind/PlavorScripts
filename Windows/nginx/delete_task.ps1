#Delete nginx autostart task
#Deletes task to start nginx automatically.

."${PSScriptRoot}/../../init_script.ps1"

if (!$isWindows)
{"Your operating system is not supported."
exit}

"Deleting a task"
Unregister-ScheduledTask "nginx" -Confirm:$false

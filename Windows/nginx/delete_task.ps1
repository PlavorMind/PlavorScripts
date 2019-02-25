#Delete nginx autostart task
#Deletes task to start nginx automatically.

."${PSScriptRoot}/../../modules/OSDetectorDebug.ps1"

if (!($isWindows))
{"Your operating system is not supported."
exit}

"Deleting task"
Unregister-ScheduledTask "nginx" -Confirm:$false

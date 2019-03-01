#Delete PHP CGI/FastCGI autostart task
#Deletes task to start PHP CGI/FastCGI automatically.

."${PSScriptRoot}/../../modules/OSDetectorDebug.ps1"

if (!($isWindows))
{"Your operating system is not supported."
exit}

"Deleting task"
Unregister-ScheduledTask "PHP-CGI" -Confirm:$false

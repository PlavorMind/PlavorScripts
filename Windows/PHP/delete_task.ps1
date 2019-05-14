#Delete PHP CGI/FastCGI autostart task
#Deletes task to start PHP CGI/FastCGI automatically.

."${PSScriptRoot}/../../init_script.ps1"

if (!$IsWindows)
{"Your operating system is not supported."
exit}

"Deleting a task"
Unregister-ScheduledTask "PHP-CGI" -Confirm:$false
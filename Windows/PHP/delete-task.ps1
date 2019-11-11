#Deletes task to start PHP CGI/FastCGI automatically.

if (Test-Path "${PSScriptRoot}/../../init_script.ps1")
{."${PSScriptRoot}/../../init_script.ps1"}
else
{"Cannot find initialize script."
exit}

if (!(Test-AdminPermission))
{"This script must be run as administrator on Windows."
exit}

"Deleting a task"
Unregister-ScheduledTask "PHP-CGI" -Confirm:$false

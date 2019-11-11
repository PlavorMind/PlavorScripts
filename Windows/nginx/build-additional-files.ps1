#Copys additional files for install.ps1 script.

Param([Parameter(Position=0)][string]$dir="C:/plavormind/nginx") #Directory that nginx is installed

if (Test-Path "${PSScriptRoot}/../../init-script.ps1")
{."${PSScriptRoot}/../../init-script.ps1"}
else
{"Cannot find initialize script."
exit}

if (!$IsWindows)
{"Your operating system is not supported."
exit}

if (Test-Path "${PSScriptRoot}/additional-files")
{"Renaming existing directory for additional files"
Move-Item "${PSScriptRoot}/additional-files" "${PSScriptRoot}/additional-files-old" -Force}
"Creating a directory for additioanl files"
New-Item "${PSScriptRoot}/additional-files" -Force -ItemType Directory

if (Test-Path "${dir}/conf/private")
{"Creating conf directory"
New-Item "${PSScriptRoot}/additional-files/conf" -Force -ItemType Directory
"Copying conf/private directory"
Copy-Item "${dir}/conf/private" "${PSScriptRoot}/additional-files/conf/" -Force -Recurse}
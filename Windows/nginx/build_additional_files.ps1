#Build additional files
#Builds additional files for nginx installer script.

Param([Parameter(Position=0)][string]$dir="C:/plavormind/nginx") #Directory that nginx is installed

if (Test-Path "${PSScriptRoot}/../../init_script.ps1")
{."${PSScriptRoot}/../../init_script.ps1"}
else
{"Cannot find initialize script."
exit}

if (!$IsWindows)
{"Your operating system is not supported."
exit}

if (Test-Path "${PSScriptRoot}/additional_files")
{"Renaming existing directory for additional files"
Move-Item "${PSScriptRoot}/additional_files" "${PSScriptRoot}/additional_files_old" -Force}

"Creating a directory for additioanl files"
New-Item "${PSScriptRoot}/additional_files" -Force -ItemType Directory

if (Test-Path "${dir}/conf/private")
{"Creating conf directory"
New-Item "${PSScriptRoot}/additional_files/conf" -Force -ItemType Directory
"Copying conf/private directory"
Copy-Item "${dir}/conf/private" "${PSScriptRoot}/additional_files/conf/" -Force -Recurse}

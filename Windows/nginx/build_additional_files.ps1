#Build additional files
#Builds additional files for nginx installer script.

param([string]$dir="C:/nginx") #Directory that nginx is installed

."${PSScriptRoot}/../../init_script.ps1"

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

if (Test-Path "${dir}/web/main/error/shinil_yghmrd.jpg")
{"Creating web directory"
New-Item "${PSScriptRoot}/additional_files/web" -Force -ItemType Directory
"Creating web/main directory"
New-Item "${PSScriptRoot}/additional_files/web/main" -Force -ItemType Directory
"Creating web/main/error directory"
New-Item "${PSScriptRoot}/additional_files/web/main/error" -Force -ItemType Directory
"Copying web/main/error/shinil_yghmrd.jpg file"
Copy-Item "${dir}/web/main/error/shinil_yghmrd.jpg" "${PSScriptRoot}/additional_files/web/main/error/" -Force}

if (Test-Path "${dir}/web/main/favicon.ico")
{"Creating web directory"
New-Item "${PSScriptRoot}/additional_files/web" -Force -ItemType Directory
"Creating web/main directory"
New-Item "${PSScriptRoot}/additional_files/web/main" -Force -ItemType Directory
"Copying web/main/favicon.ico file"
Copy-Item "${dir}/web/main/favicon.ico" "${PSScriptRoot}/additional_files/web/main/" -Force}
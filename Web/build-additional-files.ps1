#Copys additional files for configure-dir.ps1 script.

Param([Parameter(Position=0)][string]$dir) #Web server directory

if (Test-Path "${PSScriptRoot}/../init_script.ps1")
{."${PSScriptRoot}/../init_script.ps1"}
else
{"Cannot find initialize script."
exit}

if (!$dir)
{if ($IsLinux)
  {$dir="/plavormind/web"}
elseif ($IsWindows)
  {$dir="C:/plavormind/web"}
else
  {"Cannot detect default directory."
  exit}
}

if (Test-Path "${PSScriptRoot}/additional-files")
{"Renaming existing directory for additional files"
Move-Item "${PSScriptRoot}/additional-files" "${PSScriptRoot}/additional-files-old" -Force}
"Creating a directory for additioanl files"
New-Item "${PSScriptRoot}/additional-files" -Force -ItemType Directory

if (Test-Path "${dir}/default")
{"Creating default directory"
New-Item "${PSScriptRoot}/additional-files/default" -Force -ItemType Directory

if (Test-Path "${dir}/default/favicon.ico")
  {"Copying default/favicon.ico file"
  Copy-Item "${dir}/default/favicon.ico" "${PSScriptRoot}/additional-files/default/"}
}

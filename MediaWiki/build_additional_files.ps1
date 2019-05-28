#Build additional files
#Builds additional files for MediaWiki installer script.

param([string]$dir) #Directory that MediaWiki is installed

."${PSScriptRoot}/../init_script.ps1"

if (!$dir)
{if ($IsLinux)
  {$dir="/web/wiki/mediawiki"}
elseif ($IsWindows)
  {$dir="C:/nginx/web/wiki/mediawiki"}
else
  {"Cannot detect default directory."
  exit}
}

$wikis=@("exit")

if (Test-Path "${PSScriptRoot}/additional_files")
{"Renaming existing directory for additional files"
Move-Item "${PSScriptRoot}/additional_files" "${PSScriptRoot}/additional_files_old" -Force}

"Creating a directory for additioanl files"
New-Item "${PSScriptRoot}/additional_files" -Force -ItemType Directory

foreach ($wiki in $wikis)
{if (Test-Path "${dir}/data/${wiki}/logo.png")
  {"Creating data directory"
  New-Item "${PSScriptRoot}/additional_files/data" -Force -ItemType Directory
  "Creating data/${wiki} directory"
  New-Item "${PSScriptRoot}/additional_files/data/${wiki}" -Force -ItemType Directory
  "Copying data/${wiki}/logo.png file"
  Copy-Item "${dir}/data/${wiki}/logo.png" "${PSScriptRoot}/additional_files/data/${wiki}/" -Force -Recurse}
}

if (Test-Path "${dir}/private_data")
{"Copying private_data directory"
Copy-Item "${dir}/private_data" "${PSScriptRoot}/additional_files/" -Force -Recurse}
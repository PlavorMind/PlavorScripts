#Copys additional files for init-dir.ps1 script.

Param
([Parameter(Position=0)][string]$mediawiki_dir, #Directory that MediaWiki is installed
[string]$private_data_dir) #Directory that contains private data for PlavorMind wikis

if (Test-Path "${PSScriptRoot}/../init-script.ps1")
{."${PSScriptRoot}/../init-script.ps1"}
else
{"Cannot find initialize script."
exit}

if (!$mediawiki_dir)
{if ($IsLinux)
  {$mediawiki_dir="/plavormind/web/public/wiki/mediawiki"}
elseif ($IsWindows)
  {$mediawiki_dir="C:/plavormind/web/public/wiki/mediawiki"}
else
  {"Cannot detect default directory."
  exit}
}

if (!$private_data_dir)
{if ($IsLinux)
  {$private_data_dir="/plavormind/web/data/mediawiki"}
elseif ($IsWindows)
  {$private_data_dir="C:/plavormind/web/data/mediawiki"}
else
  {"Cannot detect default directory."
  exit}
}

if (Test-Path "${PSScriptRoot}/additional-files")
{"Renaming existing directory for additional files"
Move-Item "${PSScriptRoot}/additional-files" "${PSScriptRoot}/additional-files-old" -Force}
"Creating a directory for additioanl files"
New-Item "${PSScriptRoot}/additional-files" -Force -ItemType Directory

if (Test-Path "${mediawiki_dir}/data")
{"Creating data directory"
New-Item "${PSScriptRoot}/additional-files/data" -Force -ItemType Directory

$wikis=Get-ChildItem "${mediawiki_dir}/data" -Directory -Force -Name
foreach ($wiki in $wikis)
  {if (Test-Path "${mediawiki_dir}/data/${wiki}/logo.*")
    {"Creating data/${wiki} directory"
    New-Item "${PSScriptRoot}/additional-files/data/${wiki}" -Force -ItemType Directory
    "Copying data/${wiki}/logo.* file"
    Copy-Item "${mediawiki_dir}/data/${wiki}/logo.*" "${PSScriptRoot}/additional-files/data/${wiki}/" -Force -Recurse}
  }
}

if (Test-Path $private_data_dir)
{"Copying private data directory"
Copy-Item $private_data_dir "${PSScriptRoot}/additional-files/private-data" -Force -Recurse}

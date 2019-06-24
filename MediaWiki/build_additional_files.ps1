#Build additional files
#Builds additional files for Configure MediaWiki script.

param
([string]$data_dir="__DEFAULT__", #Directory that contains data for PlavorMind wikis
[string]$private_data_dir="__DEFAULT__") #Directory that contains private data for PlavorMind wikis

if (Test-Path "${PSScriptRoot}/../init_script.ps1")
{."${PSScriptRoot}/../init_script.ps1"}
else
{"Cannot find initialize script."
exit}

if ($data_dir -eq "__DEFAULT__")
{if ($IsLinux)
  {$data_dir="/plavormind/web/wiki/mediawiki/data"}
elseif ($IsWindows)
  {$data_dir="C:/plavormind/web/wiki/mediawiki/data"}
else
  {"Cannot detect default directory."
  exit}
}

if ($private_data_dir -eq "__DEFAULT__")
{if ($IsLinux)
  {$private_data_dir="/plavormind/web/wiki/mediawiki/private_data"}
elseif ($IsWindows)
  {$private_data_dir="C:/plavormind/web/wiki/mediawiki/private_data"}
else
  {"Cannot detect default directory."
  exit}
}

if (Test-Path "${PSScriptRoot}/additional_files")
{"Renaming existing directory for additional files"
Move-Item "${PSScriptRoot}/additional_files" "${PSScriptRoot}/additional_files_old" -Force}

"Creating a directory for additioanl files"
New-Item "${PSScriptRoot}/additional_files" -Force -ItemType Directory

if (Test-Path $data_dir)
{"Creating data directory"
New-Item "${PSScriptRoot}/additional_files/data" -Force -ItemType Directory

$wikis=Get-ChildItem $data_dir -Directory -Force -Name
foreach ($wiki in $wikis)
  {if (Test-Path "${data_dir}/${wiki}/logo.*")
    {"Creating data/${wiki} directory"
    New-Item "${PSScriptRoot}/additional_files/data/${wiki}" -Force -ItemType Directory

    "Copying data/${wiki}/logo.* file"
    Copy-Item "${data_dir}/${wiki}/logo.*" "${PSScriptRoot}/additional_files/data/${wiki}/" -Force -Recurse}
  }
}
else
{"Cannot find data directory."}

if (Test-Path $private_data_dir)
{"Copying private_data directory"
Copy-Item $private_data_dir "${PSScriptRoot}/additional_files/private_data" -Force -Recurse}
else
{"Cannot find private_data directory."}

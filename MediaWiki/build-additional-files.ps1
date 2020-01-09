#Copys additional files for init-dir.ps1 script.

Param
([Parameter(Position=0)][string]$mediawiki_dir, #Directory that MediaWiki is installed
[string]$private_data_dir) #Directory that contains private data for PlavorMind wikis

if (Test-Path "${PSScriptRoot}/../init-script.ps1")
{."${PSScriptRoot}/../init-script.ps1"}
else
{Write-Error "Cannot find initialize script." -Category ObjectNotFound
exit}

if (!$mediawiki_dir)
{if ($IsLinux)
  {$mediawiki_dir="/plavormind/web/public/wiki/mediawiki"}
elseif ($IsWindows)
  {$mediawiki_dir="C:/plavormind/web/public/wiki/mediawiki"}
else
  {Write-Error "Cannot detect default directory." -Category NotSpecified
  exit}
}

if (!$private_data_dir)
{if ($IsLinux)
  {$private_data_dir="/plavormind/web/data/mediawiki"}
elseif ($IsWindows)
  {$private_data_dir="C:/plavormind/web/data/mediawiki"}
else
  {Write-Error "Cannot detect default directory." -Category NotSpecified
  exit}
}

if (Test-Path "${PSScriptRoot}/additional-files")
{Write-Warning "Renaming existing directory for additional files"
Move-Item "${PSScriptRoot}/additional-files" "${PSScriptRoot}/additional-files-old" -Force}
Write-Verbose "Creating a directory for additioanl files"
New-Item "${PSScriptRoot}/additional-files" -Force -ItemType Directory

if (Test-Path "${mediawiki_dir}/data")
{Write-Verbose "Creating data directory"
New-Item "${PSScriptRoot}/additional-files/data" -Force -ItemType Directory

foreach ($wiki in Get-ChildItem "${mediawiki_dir}/data" -Directory -Force -Name)
  {if (Test-Path "${mediawiki_dir}/data/${wiki}/logo.*")
    {Write-Verbose "Creating data/${wiki} directory"
    New-Item "${PSScriptRoot}/additional-files/data/${wiki}" -Force -ItemType Directory
    Write-Verbose "Copying data/${wiki}/logo.* file"
    Copy-Item "${mediawiki_dir}/data/${wiki}/logo.*" "${PSScriptRoot}/additional-files/data/${wiki}/" -Force -Recurse}
  }
}

if (Test-Path $private_data_dir)
{Write-Verbose "Copying private data directory"
Copy-Item $private_data_dir "${PSScriptRoot}/additional-files/private-data" -Force -Recurse}

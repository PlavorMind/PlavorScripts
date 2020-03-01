#Copys additional files for init-dir.ps1 script.

Param
([Parameter(Position=0)][string]$mediawiki_dir, #MediaWiki directory
[string]$private_data_dir) #Private data directory

if (Test-Path "${PSScriptRoot}/../init-script.ps1")
{if (!(."${PSScriptRoot}/../init-script.ps1"))
  {exit}
}
else
{Write-Error "Cannot find init-script.ps1 file." -Category ObjectNotFound
exit}

if (!$mediawiki_dir)
{$mediawiki_dir="${PlaScrDefaultBaseDirectory}/web/public/wiki/mediawiki"}
if (!$private_data_dir)
{$private_data_dir="${PlaScrDefaultBaseDirectory}/web/data/mediawiki"}

if (Test-Path "${PSScriptRoot}/additional-files")
{Write-Warning "Renaming existing directory for additional files"
Move-Item "${PSScriptRoot}/additional-files" "${PSScriptRoot}/additional-files-old" -Force}
Write-Verbose "Creating a directory for additioanl files"
New-Item "${PSScriptRoot}/additional-files" -Force -ItemType Directory

if (Test-Path "${mediawiki_dir}/data")
{Write-Verbose "Creating data directory"
New-Item "${PSScriptRoot}/additional-files/data" -Force -ItemType Directory

foreach ($wiki in Get-ChildItem "${mediawiki_dir}/data" -Directory -Force -Name)
  {if (Test-Path "${mediawiki_dir}/data/${wiki}/logos")
    {Write-Verbose "Creating data/${wiki} directory"
    New-Item "${PSScriptRoot}/additional-files/data/${wiki}" -Force -ItemType Directory
    Write-Verbose "Copying data/${wiki}/logos directory"
    Copy-Item "${mediawiki_dir}/data/${wiki}/logos" "${PSScriptRoot}/additional-files/data/${wiki}/" -Force -Recurse}
  }
}

if (Test-Path $private_data_dir)
{Write-Verbose "Copying private data directory"
Copy-Item $private_data_dir "${PSScriptRoot}/additional-files/private-data" -Force -Recurse}

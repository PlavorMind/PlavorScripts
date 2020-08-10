#Copys additional files for init-dir.ps1 script.

Param
([string]$data_dir, #Data directory
[Parameter(Position=0)][string]$mediawiki_dir) #MediaWiki directory

if (Test-Path "${PSScriptRoot}/../init-script.ps1")
{if (!(."${PSScriptRoot}/../init-script.ps1"))
  {exit}
}
else
{Write-Error "Cannot find init-script.ps1 file." -Category ObjectNotFound
exit}

if (!$data_dir)
{$data_dir="${PlaScrDefaultBaseDirectory}/web/data/mediawiki"}
if (!$mediawiki_dir)
{$mediawiki_dir="${PlaScrDefaultBaseDirectory}/web/public/wiki/mediawiki"}

if (!(Test-Path $mediawiki_dir))
{Write-Error "Cannot find MediaWiki directory." -Category NotInstalled
exit}

if (Test-Path "${PSScriptRoot}/additional-files")
{Write-Warning "Renaming existing directory for additional files"
Move-Item "${PSScriptRoot}/additional-files" "${PSScriptRoot}/additional-files-old" -Force}
Write-Verbose "Creating a directory for additioanl files"
New-Item "${PSScriptRoot}/additional-files" -Force -ItemType Directory

if (Test-Path "${data_dir}/private")
{Write-Verbose "Creating data directory"
New-Item "${PSScriptRoot}/additional-files/data" -Force -ItemType Directory
Write-Verbose "Copying data/private directory"
Copy-Item "${data_dir}/private" "${PSScriptRoot}/additional-files/data/" -Force -Recurse}

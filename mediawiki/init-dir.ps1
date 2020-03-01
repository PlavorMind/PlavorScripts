#Initializes directories for MediaWiki.

Param
([string]$composer_path, #Path to Composer
[string]$core_branch, #Branch for MediaWiki core
[string]$extra_branch="master", #Branch for extensions and skins
[Parameter(Position=0)][string]$mediawiki_dir, #Directory to initialize for MediaWiki
[string]$php_path, #Path to PHP
[string]$private_data_dir) #Directory to initialize for private data

if (Test-Path "${PSScriptRoot}/../init-script.ps1")
{if (!(."${PSScriptRoot}/../init-script.ps1"))
  {exit}
}
else
{Write-Error "Cannot find init-script.ps1 file." -Category ObjectNotFound
exit}

if (!$composer_path)
{if ($IsLinux)
  {$composer_path="${PlaScrDefaultBaseDirectory}/composer.phar"}
elseif ($IsWindows)
  {$composer_path="${PlaScrDefaultBaseDirectory}/php-ts/data/composer.phar"}
else
  {Write-Error "Cannot detect default Composer path." -Category NotSpecified
  exit}
}
if (!$mediawiki_dir)
{$mediawiki_dir="${PlaScrDefaultBaseDirectory}/web/public/wiki/mediawiki"}
if (!$php_path)
{$php_path=$PlaScrDefaultPHPPath}
if (!$private_data_dir)
{$private_data_dir="${PlaScrDefaultBaseDirectory}/web/data/mediawiki"}

if (!(Test-Path $composer_path))
{Write-Error "Cannot find Composer." -Category NotInstalled
exit}
if (!(Test-Path $php_path))
{Write-Error "Cannot find PHP." -Category NotInstalled
exit}

if (!$core_branch)
{$wikimedia_mediawiki_version=Invoke-RestMethod "https://noc.wikimedia.org/conf/wikiversions.json" -DisableKeepAlive
if ($wikimedia_mediawiki_version)
  {$core_branch=($wikimedia_mediawiki_version."mediawikiwiki").Replace("php-","wmf/")}
else
  {Write-Error "Cannot detect branch for MediaWiki core."
  exit}
}

Get-ConfigFromArchive "mediawiki" "${PlaScrTempDirectory}/mediawiki-config"
if (!(Test-Path "${PlaScrTempDirectory}/mediawiki-config"))
{exit}

."${PSScriptRoot}/download.ps1" "${tempdir}/mw-install" -composer_local_json "${tempdir}/mediawiki-config/composer.local.json" -composer_path $composer_path -core_branch $core_branch -extensions_branch $extra_branch -php_path $php_path -skins_branch $extra_branch
Move-Item "${tempdir}/mw-install" "${tempdir}/mediawiki" -Force

Write-Verbose "Applying configurations"
Move-Item "${tempdir}/mediawiki-config/*" "${tempdir}/mediawiki/" -Force
Remove-Item "${tempdir}/mediawiki-config" -Force -Recurse
Write-Verbose "Deleting cache directory"
Remove-Item "${tempdir}/mediawiki/cache" -Force -Recurse
Write-Verbose "Deleting images directory"
Remove-Item "${tempdir}/mediawiki/images" -Force -Recurse

if (Test-Path "${PSScriptRoot}/additional-files/data")
{Write-Verbose "Copying additional files for data directory"
Copy-Item "${PSScriptRoot}/additional-files/data/*" "${tempdir}/mediawiki/data/" -Force -Recurse}

if (Test-Path $mediawiki_dir)
{Write-Warning "Renaming existing MediaWiki directory"
Move-Item $mediawiki_dir "${mediawiki_dir}-old" -Force}
if (Test-Path $private_data_dir)
{Write-Warning "Renaming existing private data directory"
Move-Item $private_data_dir "${private_data_dir}-old" -Force}
Write-Verbose "Moving MediaWiki directory to destination directory"
Move-Item "${tempdir}/mediawiki" $mediawiki_dir -Force
#Copy additional files for private data here because this is just copying entire directory to seperated location from MediaWiki directory.
if (Test-Path "${PSScriptRoot}/additional-files/private-data")
{Write-Verbose "Copying additional files for private data directory"
Copy-Item "${PSScriptRoot}/additional-files/private-data" $private_data_dir -Force -Recurse}

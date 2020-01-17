#Upgrades MediaWiki.

Param
([string]$composer_path, #Path to Composer
[string]$core_branch, #Branch for MediaWiki core
[string]$extra_branch="master", #Branch for extensions and skins
[Parameter(Position=0)][string]$mediawiki_dir, #Directory that MediaWiki is installed
[string]$php_path, #Path to PHP
[string]$private_data_dir) #Directory that contains private data for PlavorMind wikis

if (Test-Path "${PSScriptRoot}/../init-script.ps1")
{."${PSScriptRoot}/../init-script.ps1"}
else
{Write-Error "Cannot find initialize script." -Category ObjectNotFound
exit}

if (!$composer_path)
{if ($IsLinux)
  {$composer_path="/plavormind/composer.phar"}
elseif ($IsWindows)
  {$composer_path="C:/plavormind/php-ts/data/composer.phar"}
else
  {Write-Error "Cannot detect default Composer path." -Category NotSpecified
  exit}
}

if (!$mediawiki_dir)
{if ($IsLinux)
  {$mediawiki_dir="/plavormind/web/public/wiki/mediawiki"}
elseif ($IsWindows)
  {$mediawiki_dir="C:/plavormind/web/public/wiki/mediawiki"}
else
  {Write-Error "Cannot detect default MediaWiki directory." -Category NotSpecified
  exit}
}

if (!$php_path)
{if ($IsWindows)
  {$php_path="C:/plavormind/php-ts/php.exe"}
else
  {Write-Error "Cannot detect default PHP path." -Category NotSpecified
  exit}
}

if (!$private_data_dir)
{if ($IsLinux)
  {$private_data_dir="/plavormind/web/data/mediawiki"}
elseif ($IsWindows)
  {$private_data_dir="C:/plavormind/web/data/mediawiki"}
else
  {Write-Error "Cannot detect default private data directory." -Category NotSpecified
  exit}
}

if (!(Test-Path $composer_path))
{Write-Error "Cannot find Composer." -Category NotInstalled
exit}
if (!(Test-Path $php_path))
{Write-Error "Cannot find PHP." -Category NotInstalled
exit}

if (!$core_branch)
{$core_branch=(((Invoke-WebRequest "https://noc.wikimedia.org/conf/wikiversions.json" -DisableKeepAlive)."Content" | ConvertFrom-Json)."mediawikiwiki").Replace("php-","wmf/")}
."${PSScriptRoot}/download.ps1" "${tempdir}/mw-upgrade" -composer_path $composer_path -core_branch $core_branch -extensions_branch $extra_branch -php_path $php_path -skins_branch $extra_branch
Move-Item "${tempdir}/mw-upgrade" "${tempdir}/mediawiki" -Force

if (Test-Path "${mediawiki_dir}/data")
{Write-Verbose "Copying existing data directory"
Copy-Item "${mediawiki_dir}/data" "${tempdir}/mediawiki/" -Force -Recurse}
if (Test-Path "${mediawiki_dir}/LocalSettings.php")
{Write-Verbose "Copying existing LocalSettings.php file"
Copy-Item "${mediawiki_dir}/LocalSettings.php" "${tempdir}/mediawiki/" -Force}
Write-Verbose "Deleting cache directory"
Remove-Item "${tempdir}/mediawiki/cache" -Force -Recurse
Write-Verbose "Deleting images directory"
Remove-Item "${tempdir}/mediawiki/images" -Force -Recurse

if (Test-Path $mediawiki_dir)
{Write-Warning "Renaming existing MediaWiki directory"
Move-Item $mediawiki_dir "${mediawiki_dir}-old" -Force}
Write-Verbose "Moving MediaWiki directory from temporary directory to destination directory"
Move-Item "${tempdir}/mediawiki" $mediawiki_dir -Force

."${PSScriptRoot}/run-maintenance.ps1" $mediawiki_dir -php_path $php_path -update

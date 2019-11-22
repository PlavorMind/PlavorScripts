#Upgrades MediaWiki.

Param
([string]$composer_path, #Path to Composer
[string]$core_branch="wmf/1.35.0-wmf.5", #Branch for MediaWiki core
[string]$extra_branch="master", #Branch for extensions and skins
[Parameter(Position=0)][string]$mediawiki_dir, #Directory that MediaWiki is installed
[string]$php_path, #Path to PHP
[string]$private_data_dir) #Directory that contains private data for PlavorMind wikis

if (Test-Path "${PSScriptRoot}/../init-script.ps1")
{."${PSScriptRoot}/../init-script.ps1"}
else
{"Cannot find initialize script."
exit}

if (!$composer_path)
{if ($IsLinux)
  {$composer_path="/plavormind/composer.phar"}
elseif ($IsWindows)
  {$composer_path="C:/plavormind/php-nts/data/composer.phar"}
else
  {"Cannot detect default Composer path."
  exit}
}

if (!$mediawiki_dir)
{if ($IsLinux)
  {$mediawiki_dir="/plavormind/web/public/wiki/mediawiki"}
elseif ($IsWindows)
  {$mediawiki_dir="C:/plavormind/web/public/wiki/mediawiki"}
else
  {"Cannot detect default directory."
  exit}
}

if (!$php_path)
{if ($IsWindows)
  {$php_path="C:/plavormind/php-nts/php.exe"}
else
  {"Cannot detect default PHP path."
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

if (!(Test-Path $composer_path))
{"Cannot find Composer."
exit}
if (!(Test-Path $php_path))
{"Cannot find PHP."
exit}

."${PSScriptRoot}/download.ps1" "${tempdir}/mw-upgrade" -core_branch $core_branch -extensions_branch $extra_branch -skins_branch $extra_branch
Move-Item "${tempdir}/mw-upgrade" "${tempdir}/mediawiki" -Force

if (Test-Path "${mediawiki_dir}/data")
{"Copying existing data directory"
Copy-Item "${mediawiki_dir}/data" "${tempdir}/mediawiki/" -Force -Recurse}
if (Test-Path "${mediawiki_dir}/LocalSettings.php")
{"Copying existing LocalSettings.php file"
Copy-Item "${mediawiki_dir}/LocalSettings.php" "${tempdir}/mediawiki/" -Force}
"Deleting core cache directory"
Remove-Item "${tempdir}/mediawiki/cache" -Force -Recurse
"Deleting core images directory"
Remove-Item "${tempdir}/mediawiki/images" -Force -Recurse

if (Test-Path $mediawiki_dir)
{"Renaming existing MediaWiki directory"
Move-Item $mediawiki_dir "${mediawiki_dir}-old" -Force}
"Moving MediaWiki directory"
Move-Item "${tempdir}/mediawiki" $mediawiki_dir -Force

#NEEDS REVIEW
."${PSScriptRoot}/run_script_globally.ps1" -dir $mediawiki_dir -script "update.php --doshared --quick"
."${PSScriptRoot}/maintain.ps1" -mediawiki_dir $mediawiki_dir -private_data_dir $private_data_dir

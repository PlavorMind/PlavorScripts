#Initializes directories for MediaWiki.

Param
([string]$composer_path, #Path to Composer
[string]$core_branch="wmf/1.35.0-wmf.5", #Branch for MediaWiki core
[string]$extra_branch="master", #Branch for extensions and skins
[Parameter(Position=0)][string]$mediawiki_dir, #Directory to configure for MediaWiki
[string]$php_path, #Path to PHP
[string]$private_data_dir) #Directory to configure for private data

if (Test-Path "${PSScriptRoot}/../init-script.ps1")
{."${PSScriptRoot}/../init-script.ps1"}
else
{"Cannot find initialize script."
exit}

if (!$composer_path)
{if ($IsLinux)
  {$composer_path="/plavormind/composer.phar"}
elseif ($IsWindows)
  {$composer_path="C:/plavormind/php-ts/data/composer.phar"}
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
  {$php_path="C:/plavormind/php-ts/php.exe"}
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

"Downloading Configurations repository archive"
Invoke-WebRequest "https://github.com/PlavorMind/Configurations/archive/Main.zip" -DisableKeepAlive -OutFile "${tempdir}/Configurations.zip"
if (Test-Path "${tempdir}/Configurations.zip")
{"Extracting"
Expand-Archive "${tempdir}/Configurations.zip" $tempdir -Force
"Deleting a temporary file"
Remove-Item "${tempdir}/Configurations.zip" -Force}
else
{"Cannot download Configurations repository archive."
exit}

."${PSScriptRoot}/download.ps1" "${tempdir}/mw-install" -composer_path $composer_path -core_branch $core_branch -extensions_branch $extra_branch -php_path $php_path -skins_branch $extra_branch
Move-Item "${tempdir}/mw-install" "${tempdir}/mediawiki" -Force

"Moving configuration files"
Move-Item "${tempdir}/Configurations-Main/MediaWiki/*" "${tempdir}/mediawiki/" -Force
"Deleting core cache directory"
Remove-Item "${tempdir}/mediawiki/cache" -Force -Recurse
"Deleting core images directory"
Remove-Item "${tempdir}/mediawiki/images" -Force -Recurse

if (Test-Path "${PSScriptRoot}/additional-files/data")
{"Copying additional files for data directory"
Copy-Item "${PSScriptRoot}/additional-files/data/*" "${tempdir}/mediawiki/data/" -Force -Recurse}

if (Test-Path $mediawiki_dir)
{"Renaming existing MediaWiki directory"
Move-Item $mediawiki_dir "${mediawiki_dir}-old" -Force}
if (Test-Path $private_data_dir)
{"Renaming existing private data directory"
Move-Item $private_data_dir "${private_data_dir}-old" -Force}
"Moving MediaWiki directory"
Move-Item "${tempdir}/mediawiki" $mediawiki_dir -Force
#Copy additional files for private data here because this is just copying a entire directory to seperated location from MediaWiki directory.
if (Test-Path "${PSScriptRoot}/additional-files/private-data")
{"Copying additional files for private data directory"
Copy-Item "${PSScriptRoot}/additional-files/private-data" $private_data_dir -Force -Recurse}

"Deleting a temporary directory"
Remove-Item "${tempdir}/Configurations-Main" -Force -Recurse

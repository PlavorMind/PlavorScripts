#MediaWiki downloader
#Downloads MediaWiki.

param
([string]$core_branch="wmf/1.33.0-wmf.25", #Branch for MediaWiki core
[string]$dir="/web/Wiki/mediawiki", #Directory to download MediaWiki
[string]$extensions_branch="master", #Branch for extensions
[switch]$plavormind, #Configure wiki directories based on PlavorMind configurations if this parameter is set
[string]$skins_branch="master", #Branch for skins
[switch]$upgrade) #Use upgrade mode if this parameter is set

."${PSScriptRoot}/../modules/OSDetectorDebug.ps1"
."${PSScriptRoot}/../modules/SetTempDir.ps1"

$composer_extensions=@("AbuseFilter","AntiSpoof")
$extensions=
@("AbuseFilter",
"AccountInfo",
"AntiSpoof",
"CentralNotice",
"ChangeAuthor",
"CheckUser",
"Cite",
"CodeEditor",
"ConfirmEdit",
"DeletePagesForGood",
"GlobalUserPage",
"Highlightjs_Integration",
"MinimumNameLength",
"MultimediaViewer",
"Nuke",
"PageImages",
"Popups",
"Renameuser",
"SimpleMathJax",
"StaffPowers",
"SyntaxHighlight_GeSHi",
"TextExtracts",
"TitleBlacklist",
"TwoColConflict",
"UserMerge",
"UserPageEditProtection",
"WikiEditor",

"PlavorMindTweaks")
$skins=@("Liberty","PlavorMindView","Timeless","Vector")

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

"Downloading MediaWiki archive"
Invoke-WebRequest "https://github.com/wikimedia/mediawiki/archive/${core_branch}.zip" -DisableKeepAlive -OutFile "${tempdir}/MediaWiki.zip"
if (Test-Path "${tempdir}/MediaWiki.zip")
{"Extracting"
Expand-Archive "${tempdir}/MediaWiki.zip" $tempdir -Force
"Deleting a temporary file"
Remove-Item "${tempdir}/MediaWiki.zip" -Force
"Renaming MediaWiki directory"
Move-Item "${tempdir}/mediawiki-*" "${tempdir}/MediaWiki" -Force}
else
{"Cannot download MediaWiki archive."
exit}

"Updating dependencies"
composer update --no-dev --working-dir="${tempdir}/MediaWiki"

"Emptying extensions and skins directory"
Remove-Item "${tempdir}/MediaWiki/extensions/*" -Force -Recurse
Remove-Item "${tempdir}/MediaWiki/skins/*" -Force -Recurse

foreach ($extension_name in $extensions)
{"Downloading ${extension_name} extension archive"
switch ($extension_name)
  {"DiscordNotifications"
    {Invoke-WebRequest "https://github.com/kulttuuri/DiscordNotifications/archive/master.zip" -DisableKeepAlive -OutFile "${tempdir}/${extension_name}.zip"}
  "Highlightjs_Integration"
    {Invoke-WebRequest "https://github.com/Nicolas01/Highlightjs_Integration/archive/master.zip" -DisableKeepAlive -OutFile "${tempdir}/${extension_name}.zip"}
  "PlavorMindTweaks"
    {Invoke-WebRequest "https://github.com/PlavorMind/PlavorMindTweaks/archive/Main.zip" -DisableKeepAlive -OutFile "${tempdir}/${extension_name}.zip"}
  "SimpleMathJax"
    {Invoke-WebRequest "https://github.com/jmnote/SimpleMathJax/archive/master.zip" -DisableKeepAlive -OutFile "${tempdir}/${extension_name}.zip"}
  default
    {Invoke-WebRequest "https://github.com/wikimedia/mediawiki-extensions-${extension_name}/archive/${extensions_branch}.zip" -DisableKeepAlive -OutFile "${tempdir}/${extension_name}.zip"}
  }
if (Test-Path "${tempdir}/${extension_name}.zip")
  {"Extracting"
  Expand-Archive "${tempdir}/${extension_name}.zip" "${tempdir}/MediaWiki/extensions/" -Force
  "Deleting a temporary file"
  Remove-Item "${tempdir}/${extension_name}.zip" -Force
  "Renaming ${extension_name} extension directory"
  switch ($extension_name)
    {"DiscordNotifications"
      {Move-Item "${tempdir}/MediaWiki/extensions/DiscordNotifications-master" "${tempdir}/MediaWiki/extensions/${extension_name}" -Force}
    "Highlightjs_Integration"
      {Move-Item "${tempdir}/MediaWiki/extensions/Highlightjs_Integration-master" "${tempdir}/MediaWiki/extensions/${extension_name}" -Force}
    "PlavorMindTweaks"
      {Move-Item "${tempdir}/MediaWiki/extensions/PlavorMindTweaks-Main" "${tempdir}/MediaWiki/extensions/${extension_name}" -Force}
    "SimpleMathJax"
      {Move-Item "${tempdir}/MediaWiki/extensions/SimpleMathJax-master" "${tempdir}/MediaWiki/extensions/${extension_name}" -Force}
    default
      {Move-Item "${tempdir}/MediaWiki/extensions/mediawiki-extensions-${extension_name}-*" "${tempdir}/MediaWiki/extensions/${extension_name}" -Force}
    }
  }
else
  {"Cannot download ${extension_name} extension archive."}
}

foreach ($extension_name in $composer_extensions)
{if (Test-Path "${tempdir}/MediaWiki/extensions/${extension_name}")
  {"Updating dependencies for ${extension_name} extension"
  composer update --no-dev --working-dir="${tempdir}/MediaWiki/extensions/${extension_name}"}
}

foreach ($skin_name in $skins)
{"Downloading ${skin_name} skin archive"
switch ($skin_name)
  {"Liberty"
    {Invoke-WebRequest "https://gitlab.com/librewiki/Liberty-MW-Skin/-/archive/master/Liberty-MW-Skin-master.zip" -DisableKeepAlive -OutFile "${tempdir}/${skin_name}.zip"}
  "PlavorMindView"
    {Invoke-WebRequest "https://github.com/PlavorMind/PlavorMindView/archive/Main.zip" -DisableKeepAlive -OutFile "${tempdir}/${skin_name}.zip"}
  default
    {Invoke-WebRequest "https://github.com/wikimedia/mediawiki-skins-${skin_name}/archive/${skins_branch}.zip" -DisableKeepAlive -OutFile "${tempdir}/${skin_name}.zip"}
  }
if (Test-Path "${tempdir}/${skin_name}.zip")
  {"Extracting"
  Expand-Archive "${tempdir}/${skin_name}.zip" "${tempdir}/MediaWiki/skins/" -Force
  "Deleting a temporary file"
  Remove-Item "${tempdir}/${skin_name}.zip" -Force
  "Renaming ${skin_name} skin directory"
  switch ($skin_name)
    {"Liberty"
      {Move-Item "${tempdir}/MediaWiki/skins/Liberty-MW-Skin-master" "${tempdir}/MediaWiki/skins/${skin_name}" -Force}
    "PlavorMindView"
      {Move-Item "${tempdir}/MediaWiki/skins/PlavorMindView-Main" "${tempdir}/MediaWiki/skins/${skin_name}" -Force}
    default
      {Move-Item "${tempdir}/MediaWiki/skins/mediawiki-skins-${skin_name}-*" "${tempdir}/MediaWiki/skins/${skin_name}" -Force}
    }
  }
else
  {"Cannot download ${skin_name} skin archive."}
}

if ($upgrade)
{if ($plavormind)
  {if (Test-Path "${dir}/data")
    {"Copying existing data directory"
    Copy-Item "${dir}/data" "${tempdir}/MediaWiki/data" -Force -Recurse}
  if (Test-Path "${dir}/private_data")
    {"Copying existing private_data directory"
    Copy-Item "${dir}/private_data" "${tempdir}/MediaWiki/private_data" -Force -Recurse}
  "Deleting core cache directory"
  Remove-Item "${tempdir}/MediaWiki/cache" -Force -Recurse
  "Deleting core images directory"
  Remove-Item "${tempdir}/MediaWiki/images" -Force -Recurse}
elseif (Test-Path "${dir}/images")
  {"Deleting core images directory"
  Remove-Item "${tempdir}/MediaWiki/images" -Force -Recurse
  "Copying existing images directory"
  Copy-Item "${dir}/images" "${tempdir}/MediaWiki/images" -Force -Recurse}
if (Test-Path "${dir}/LocalSettings.php")
  {"Copying existing LocalSettings.php file"
  Copy-Item "${dir}/LocalSettings.php" "${tempdir}/MediaWiki/LocalSettings.php" -Force}
"Running update script"
php "${tempdir}/MediaWiki/maintenance/update.php" --doshared --quick}
elseif ($plavormind)
{"Moving additional files"
Move-Item "${tempdir}/Configurations-Main/MediaWiki/*" "${tempdir}/MediaWiki/" -Force
if (Test-Path "${PSScriptRoot}/data")
  {"Copying files in data directory"
  Copy-Item "${PSScriptRoot}/data/*" "${tempdir}/MediaWiki/data/" -Force -Recurse}
if (Test-Path "${PSScriptRoot}/private_data")
  {"Copying files in private_data directory"
  Copy-Item "${PSScriptRoot}/private_data" "${tempdir}/MediaWiki/" -Force -Recurse}
"Deleting core images directory"
Remove-Item "${tempdir}/MediaWiki/images" -Force -Recurse}

"Deleting a temporary directory"
Remove-Item "${tempdir}/Configurations-Main" -Force -Recurse

"Deleting unnecessary files"
"Warning: This will remove documentations and license notices that are unnecessary for running."
Remove-Item "${tempdir}/MediaWiki/docs" -Force -Recurse
Remove-Item "${tempdir}/MediaWiki/CODE_OF_CONDUCT.md" -Force
Remove-Item "${tempdir}/MediaWiki/CREDITS" -Force
Remove-Item "${tempdir}/MediaWiki/FAQ" -Force
Remove-Item "${tempdir}/MediaWiki/HISTORY" -Force
Remove-Item "${tempdir}/MediaWiki/INSTALL" -Force
Remove-Item "${tempdir}/MediaWiki/README" -Force
Remove-Item "${tempdir}/MediaWiki/RELEASE-NOTES-*" -Force
Remove-Item "${tempdir}/MediaWiki/SECURITY" -Force
Remove-Item "${tempdir}/MediaWiki/UPGRADE" -Force

#if ($isWindows)
#{if (Get-Process "php-cgi" -ErrorAction Ignore)
  #{"Stopping PHP CGI/FastCGI"
  #Stop-Process -Force -Name "php-cgi"}
#}

if (Test-Path $dir)
{"Renaming existing MediaWiki directory"
Move-Item $dir "${dir}_old" -Force}

"Moving MediaWiki directory"
Move-Item "${tempdir}/MediaWiki" $dir -Force

if ($isLinux)
{"Changing ownership of MediaWiki directory"
chown "www-data" $dir -R
"Changing permissions of MediaWiki directory"
chmod 755 $dir -R
chmod 700 "${dir}/private_data" -R}

param
([string]$core_branch="wmf/1.33.0-wmf.19",
[string]$dir="/web/Wiki/mediawiki",
[string]$extensions_branch="master",
[string]$skins_branch="master",
[switch]$upgrade,
[string]$wiki_code)

."${PSScriptRoot}/../../modules/OSDetectorDebug.ps1"
."${PSScriptRoot}/../../modules/SetTempDir.ps1"

$composer_extensions=@("AntiSpoof")
$extensions=
@("AntiSpoof",
"CheckUser",
"ConfirmEdit",
"DeletePagesForGood",
"GoToShell",
"Highlightjs_Integration",
"MultimediaViewer",
"Nuke",
"PageImages",
"Popups",
"Renameuser",
"SyntaxHighlight_GeSHi",
"StaffPowers",
"TextExtracts",
"TorBlock",
"UserMerge",

"PlavorMindTweaks",
"TwoColConflict",
#PlavorEXITBeta (exit)
"UserPageEditProtection")
$skins=@("Liberty","PlavorMindView","Timeless","Vector")

"Downloading Configurations repository archive"
Invoke-WebRequest "https://github.com/PlavorMind/Configurations/archive/Main.zip" -OutFile "${tempdir}/Configurations.zip"
if (Test-Path "${tempdir}/Configurations.zip")
{"Extracting"
Expand-Archive "${tempdir}/Configurations.zip" $tempdir -Force
"Deleting a temporary file"
Remove-Item "${tempdir}/Configurations.zip" -Force}
else
{"Cannot download Configurations repository archive."
exit}

"Downloading MediaWiki archive"
Invoke-WebRequest "https://github.com/wikimedia/mediawiki/archive/${core_branch}.zip" -OutFile "${tempdir}/MediaWiki.zip"
if (Test-Path "${tempdir}/MediaWiki.zip")
{"Extracting"
Expand-Archive "${tempdir}/MediaWiki.zip" $tempdir
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
  {"PlavorMindTweaks"
    {Invoke-WebRequest "https://github.com/PlavorMind/PlavorMindTweaks/archive/Main.zip" -OutFile "${tempdir}/${extension_name}.zip"}
  default
    {Invoke-WebRequest "https://github.com/wikimedia/mediawiki-extensions-${extension_name}/archive/${extensions_branch}.zip" -OutFile "${tempdir}/${extension_name}.zip"}
  }
if (Test-Path "${tempdir}/${extension_name}.zip")
  {"Extracting"
  Expand-Archive "${tempdir}/${extension_name}.zip" "${tempdir}/MediaWiki/extensions/" -Force
  "Deleting a temporary file"
  Remove-Item "${tempdir}/${extension_name}.zip" -Force
  "Renaming ${extension_name} extension directory"
  switch ($extension_name)
    {"PlavorMindTweaks"
      {Move-Item "${tempdir}/MediaWiki/extensions/PlavorMindTweaks-Main" "${tempdir}/MediaWiki/extensions/${extension_name}" -Force}
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
    {Invoke-WebRequest "https://gitlab.com/librewiki/Liberty-MW-Skin/-/archive/REL1_31/Liberty-MW-Skin-REL1_31.zip" -OutFile "${tempdir}/${skin_name}.zip"}
  "PlavorMindView"
    {Invoke-WebRequest "https://github.com/PlavorMind/PlavorMindView/archive/Main.zip" -OutFile "${tempdir}/${skin_name}.zip"}
  default
    {Invoke-WebRequest "https://github.com/wikimedia/mediawiki-skins-${skin_name}/archive/${skins_branch}.zip" -OutFile "${tempdir}/${skin_name}.zip"}
  }
if (Test-Path "${tempdir}/${skin_name}.zip")
  {"Extracting"
  Expand-Archive "${tempdir}/${skin_name}.zip" "${tempdir}/MediaWiki/skins/" -Force
  "Deleting a temporary file"
  Remove-Item "${tempdir}/${skin_name}.zip" -Force
  "Renaming ${skin_name} skin directory"
  switch ($skin_name)
    {"Liberty"
      {Move-Item "/tmp/MediaWiki/skins/Liberty-MW-Skin-REL1_31" "/tmp/MediaWiki/skins/${skin_name}" -Force}
    "PlavorMindView"
      {Move-Item "/tmp/MediaWiki/skins/PlavorMindView-Main" "/tmp/MediaWiki/skins/${skin_name}" -Force}
    default
      {Move-Item "/tmp/MediaWiki/skins/mediawiki-skins-${skin_name}-*" "/tmp/MediaWiki/skins/${skin_name}" -Force}
    }
  }
else
  {"${skin_name} skin archive download is failed!"}
}

if ($upgrade)
{if (Test-Path "${dir}/data")
  {"Copying existing data directory"
  Copy-Item "${dir}/data" "/tmp/MediaWiki/data" -Force -Recurse}
if (Test-Path "${dir}/images")
  {"Deleting core images directory"
  Remove-Item "/tmp/MediaWiki/images" -Force -Recurse
  "Copying existing images directory"
  Copy-Item "${dir}/images" "/tmp/MediaWiki/images" -Force -Recurse}
if (Test-Path "${dir}/private_data")
  {"Copying existing private_data directory"
  Copy-Item "${dir}/private_data" "/tmp/MediaWiki/private_data" -Force -Recurse}
if (Test-Path "${dir}/LocalSettings.php")
  {"Copying existing LocalSettings.php file"
  Copy-Item "${dir}/LocalSettings.php" "/tmp/MediaWiki/LocalSettings.php" -Force}
"Running update script"
php "/tmp/MediaWiki/maintenance/update.php" --doshared --quick}
elseif ($wiki_code)
{"Deleting core images directory"
Remove-Item "/tmp/MediaWiki/images" -Force -Recurse
"Creating additional directories"
New-Item "/tmp/MediaWiki/data" -Force -ItemType Directory
New-Item "/tmp/MediaWiki/data/${wiki_code}" -Force -ItemType Directory
New-Item "/tmp/MediaWiki/private_data" -Force -ItemType Directory
New-Item "/tmp/MediaWiki/private_data/databases" -Force -ItemType Directory
New-Item "/tmp/MediaWiki/private_data/${wiki_code}" -Force -ItemType Directory
New-Item "/tmp/MediaWiki/private_data/${wiki_code}/cache" -Force -ItemType Directory
New-Item "/tmp/MediaWiki/private_data/${wiki_code}/deleted_files" -Force -ItemType Directory
New-Item "/tmp/MediaWiki/private_data/${wiki_code}/files" -Force -ItemType Directory
"Moving additional files"
Move-Item "/tmp/Configurations-Main/MediaWiki/*" "/tmp/MediaWiki/" -Force
if (Test-Path "${PSScriptRoot}/private")
  {"Copying private files"
  Copy-Item "${PSScriptRoot}/private/*" "/tmp/MediaWiki/private_data/" -Force -Recurse}
}

"Deleting a temporary directory"
Remove-Item "/tmp/Configurations-Main" -Force -Recurse

"Deleting unnecessary files"
"Warning: This will remove documentations and license notices that are unnecessary for running."
Remove-Item "/tmp/MediaWiki/docs" -Force -Recurse
Remove-Item "/tmp/MediaWiki/CODE_OF_CONDUCT.md" -Force
Remove-Item "/tmp/MediaWiki/CREDITS" -Force
Remove-Item "/tmp/MediaWiki/FAQ" -Force
Remove-Item "/tmp/MediaWiki/HISTORY" -Force
Remove-Item "/tmp/MediaWiki/INSTALL" -Force
Remove-Item "/tmp/MediaWiki/README" -Force
Remove-Item "/tmp/MediaWiki/RELEASE-NOTES-*" -Force
Remove-Item "/tmp/MediaWiki/SECURITY" -Force
Remove-Item "/tmp/MediaWiki/UPGRADE" -Force

if (Test-Path $dir)
{"Renaming existing MediaWiki folder"
Move-Item $dir "${dir}_old" -Force}

"Moving MediaWiki folder"
Move-Item "/tmp/MediaWiki" $dir -Force

"Changing ownership of MediaWiki directory"
chown "www-data" $dir -R
"Changing permissions of MediaWiki directory"
chmod 755 $dir -R
chmod 700 "${dir}/private_data" -R

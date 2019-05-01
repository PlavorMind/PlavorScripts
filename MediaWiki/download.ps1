#MediaWiki downloader
#Downloads MediaWiki with some extensions and skins.

param
([string]$core_branch="wmf/1.34.0-wmf.3", #Branch for MediaWiki core
[string]$dir="/web/wiki/mediawiki", #Directory to download MediaWiki
[switch]$extension_DeleteUserPages, #Download DeleteUserPages extension if this parameter is set
[string]$extensions_branch="master", #Branch for extensions
[string]$skins_branch="master") #Branch for skins

."${PSScriptRoot}/../modules/SetTempDir.ps1"

$composer_extensions=@("AbuseFilter","AntiSpoof")
$extensions=
@("AbuseFilter",
"AccountInfo",
"AntiSpoof",
"ApprovedRevs",
#"CentralNotice",
"ChangeAuthor",
"CheckUser",
"Cite",
"CodeEditor",
"CollapsibleVector",
"CommonsMetadata",
"ConfirmEdit",
"DeletePagesForGood",
#"GlobalUserPage",
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
  {"Highlightjs_Integration"
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
    {"Highlightjs_Integration"
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

if ($extension_DeleteUserPages)
{."${PSScriptRoot}/../modules/ExtractArchive.ps1" -path "https://gerrit.wikimedia.org/r/plugins/gitiles/mediawiki/extensions/DeleteUserPages/+archive/${extensions_branch}.tar.gz" -type "tar.gz"
if ($ea_output)
  {"Moving DeleteUserPages extension directory"
  Move-Item $ea_output "${tempdir}/MediaWiki/extensions/DeleteUserPages" -Force}
else
  {"Cannot download DeleteUserPages extension archive."}
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

"Deleting unnecessary files"
"Warning: This will remove documentations and license notices that are unnecessary for running."
Remove-Item "${tempdir}/MediaWiki/docs" -Force -Recurse
Remove-Item "${tempdir}/MediaWiki/resources/assets/file-type-icons/COPYING" -Force
Remove-Item "${tempdir}/MediaWiki/resources/assets/licenses/public-domain.png" -Force
Remove-Item "${tempdir}/MediaWiki/resources/assets/licenses/README" -Force
Remove-Item "${tempdir}/MediaWiki/CODE_OF_CONDUCT.md" -Force
Remove-Item "${tempdir}/MediaWiki/CREDITS" -Force
Remove-Item "${tempdir}/MediaWiki/FAQ" -Force
Remove-Item "${tempdir}/MediaWiki/HISTORY" -Force
Remove-Item "${tempdir}/MediaWiki/INSTALL" -Force
Remove-Item "${tempdir}/MediaWiki/README" -Force
Remove-Item "${tempdir}/MediaWiki/RELEASE-NOTES-*" -Force
Remove-Item "${tempdir}/MediaWiki/SECURITY" -Force
Remove-Item "${tempdir}/MediaWiki/UPGRADE" -Force

if (Test-Path $dir)
{"Renaming existing MediaWiki directory"
Move-Item $dir "${dir}_old" -Force}

"Moving MediaWiki directory"
Move-Item "${tempdir}/MediaWiki" $dir -Force

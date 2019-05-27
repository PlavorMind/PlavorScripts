#MediaWiki downloader
#Downloads MediaWiki with some extensions and skins.

param
([string]$core_branch="master", #Branch for MediaWiki core
[string]$dir, #Directory to download MediaWiki
[string]$extensions_branch="master", #Branch for extensions
[string]$skins_branch="master") #Branch for skins

."${PSScriptRoot}/../init_script.ps1"

if (!$dir)
{if ($IsLinux)
  {$dir="/web/wiki/mediawiki"}
elseif ($IsWindows)
  {$dir="C:/nginx/web/wiki/mediawiki"}
else
  {"Cannot detect default directory."
  exit}
}

$composer_extensions=@("AbuseFilter","AntiSpoof")
$extensions=
@("AbuseFilter",
"AntiSpoof",
"ApprovedRevs",
"Babel",
#"CentralNotice",
"ChangeAuthor",
"CheckUser",
"Cite",
"CodeEditor",
"CodeMirror",
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
"PlavorMindTools",
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
"WikiEditor")
$skins=@("Liberty","Timeless","Vector")

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

foreach ($extension in $extensions)
{"Downloading ${extension} extension archive"
switch ($extension)
  {"Highlightjs_Integration"
    {Invoke-WebRequest "https://github.com/Nicolas01/Highlightjs_Integration/archive/master.zip" -DisableKeepAlive -OutFile "${tempdir}/${extension}.zip"}
  "PlavorMindTools"
    {Invoke-WebRequest "https://github.com/PlavorMind/PlavorMindTools/archive/Main.zip" -DisableKeepAlive -OutFile "${tempdir}/${extension}.zip"}
  "SimpleMathJax"
    {Invoke-WebRequest "https://github.com/jmnote/SimpleMathJax/archive/master.zip" -DisableKeepAlive -OutFile "${tempdir}/${extension}.zip"}
  default
    {Invoke-WebRequest "https://github.com/wikimedia/mediawiki-extensions-${extension}/archive/${extensions_branch}.zip" -DisableKeepAlive -OutFile "${tempdir}/${extension}.zip"}
  }
if (Test-Path "${tempdir}/${extension}.zip")
  {"Extracting"
  Expand-Archive "${tempdir}/${extension}.zip" "${tempdir}/MediaWiki/extensions/" -Force
  "Deleting a temporary file"
  Remove-Item "${tempdir}/${extension}.zip" -Force
  "Renaming ${extension} extension directory"
  switch ($extension)
    {"Highlightjs_Integration"
      {Move-Item "${tempdir}/MediaWiki/extensions/Highlightjs_Integration-master" "${tempdir}/MediaWiki/extensions/${extension}" -Force}
    "PlavorMindTools"
      {Move-Item "${tempdir}/MediaWiki/extensions/PlavorMindTools-Main" "${tempdir}/MediaWiki/extensions/${extension}" -Force}
    "SimpleMathJax"
      {Move-Item "${tempdir}/MediaWiki/extensions/SimpleMathJax-master" "${tempdir}/MediaWiki/extensions/${extension}" -Force}
    default
      {Move-Item "${tempdir}/MediaWiki/extensions/mediawiki-extensions-${extension}-*" "${tempdir}/MediaWiki/extensions/${extension}" -Force}
    }
  }
else
  {"Cannot download ${extension} extension archive."}
}

foreach ($extension in $composer_extensions)
{if (Test-Path "${tempdir}/MediaWiki/extensions/${extension}")
  {"Updating dependencies for ${extension} extension"
  composer update --no-dev --working-dir="${tempdir}/MediaWiki/extensions/${extension}"}
}

foreach ($skin in $skins)
{"Downloading ${skin} skin archive"
switch ($skin)
  {"Liberty"
    {Invoke-WebRequest "https://gitlab.com/librewiki/Liberty-MW-Skin/-/archive/master/Liberty-MW-Skin-master.zip" -DisableKeepAlive -OutFile "${tempdir}/${skin}.zip"}
  default
    {Invoke-WebRequest "https://github.com/wikimedia/mediawiki-skins-${skin}/archive/${skins_branch}.zip" -DisableKeepAlive -OutFile "${tempdir}/${skin}.zip"}
  }
if (Test-Path "${tempdir}/${skin}.zip")
  {"Extracting"
  Expand-Archive "${tempdir}/${skin}.zip" "${tempdir}/MediaWiki/skins/" -Force
  "Deleting a temporary file"
  Remove-Item "${tempdir}/${skin}.zip" -Force
  "Renaming ${skin} skin directory"
  switch ($skin)
    {"Liberty"
      {Move-Item "${tempdir}/MediaWiki/skins/Liberty-MW-Skin-master" "${tempdir}/MediaWiki/skins/${skin}" -Force}
    default
      {Move-Item "${tempdir}/MediaWiki/skins/mediawiki-skins-${skin}-*" "${tempdir}/MediaWiki/skins/${skin}" -Force}
    }
  }
else
  {"Cannot download ${skin} skin archive."}
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

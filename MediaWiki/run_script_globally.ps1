#Run script globally
#Runs a MediaWiki maintenance script for all PlavorMind wikis.

param
([string]$arguments="", #Arguments to append when running script
[string]$dir="__DEFAULT__", #Directory that MediaWiki is installed
[string]$script) #Script to run

if (Test-Path "${PSScriptRoot}/../init_script.ps1")
{."${PSScriptRoot}/../init_script.ps1"}
else
{"Cannot find initialize script."
exit}

if ($dir -eq "__DEFAULT__")
{if ($IsLinux)
  {$dir="/plavormind/web/wiki/mediawiki"}
elseif ($IsWindows)
  {$dir="C:/plavormind/web/wiki/mediawiki"}
else
  {"Cannot detect default directory."
  exit}
}

if (Test-Path "${dir}/maintenance/${script}.php")
{$wikis=Get-ChildItem "${dir}/data" -Directory -Force -Name
foreach ($wiki in $wikis)
  {"Running ${script}.php for ${wiki}"
  php "${dir}/maintenance/${script}.php" $arguments --wiki $wiki}
}
else
{"Cannot find maintenance script."}
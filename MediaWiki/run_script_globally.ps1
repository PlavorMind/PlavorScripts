#Run script globally
#Runs a MediaWiki maintenance script for all PlavorMind wikis.

param
([string]$dir="__DEFAULT__", #Directory that MediaWiki is installed
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

if (Test-Path $dir)
{$wikis=Get-ChildItem "${dir}/data" -Directory -Force -Name
foreach ($wiki in $wikis)
  {"Running ${script} for ${wiki}"
  #Workaround to fix argument bug
  Start-Process "php" -ArgumentList "${dir}/maintenance/${script} --wiki ${wiki}" -Wait}
}
else
{"Cannot find MediaWiki directory."}

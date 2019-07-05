#Maintenance scripts for initialize
#Runs some maintenance scripts to initialize MediaWiki.

param
([string]$dir="__DEFAULT__", #Directory that MediaWiki is installed
[string]$steward, #User to add to the steward group
[string]$wiki) #Specify wiki to run scripts otherwise will run globally

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
{$scripts=@("update.php --doshared --quick")
if ($steward)
  {$scripts+=@("createAndPromote.php `"${steward}`" --custom-groups=steward --force")}
$scripts+=
@("emptyUserGroup.php interface-admin",
"emptyUserGroup.php sysop")
if (Test-Path "${dir}/extensions/AntiSpoof/maintenance/batchAntiSpoof.php")
  {$scripts+=@("runScripts.php ${dir}/extensions/AntiSpoof/maintenance/batchAntiSpoof.php")}
if (Test-Path "${dir}/extensions/Flow")
  {$scripts+=
  @("populateContentModel.php --ns=all --table=archive",
  "populateContentModel.php --ns=all --table=page",
  "populateContentModel.php --ns=all --table=revision")}
$scripts+=@("runJobs.php")

foreach ($script in $scripts)
  {if ($wiki)
    {"Running ${script} for ${wiki}"
    #Workaround to fix argument bug
    Start-Process "php" -ArgumentList "${dir}/maintenance/${script} --wiki ${wiki}" -Wait}
  else
    {$wiki_temp=$wiki #run_script_globally.ps1 defines $wiki variable itself
    ."${PSScriptRoot}/run_script_globally.ps1" -dir $dir -script $script
    $wiki=$wiki_temp}
  }
}
else
{"Cannot find MediaWiki directory."}

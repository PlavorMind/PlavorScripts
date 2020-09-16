#Creates a wiki.

#Parameter names should not contain "cred" or "password" to avoid warnings
Param
([Parameter(Mandatory=$true)][string]$cre_json, #JSON file containing credentials
[string]$data_dir, #Data directory
[Parameter(Position=0)][string]$mediawiki_dir, #MediaWiki directory
[string]$php_path, #Path of PHP
[Parameter(Mandatory=$true,Position=1)][string]$wiki) #Wiki ID

if (Test-Path "${PSScriptRoot}/../init-script.ps1")
{if (!(."${PSScriptRoot}/../init-script.ps1"))
  {exit}
}
else
{Write-Error "Cannot find init-script.ps1 file." -Category ObjectNotFound
exit}

if (!$data_dir)
{$data_dir="${PlaScrDefaultBaseDirectory}/web/data/mediawiki"}
if (!$mediawiki_dir)
{$mediawiki_dir="${PlaScrDefaultBaseDirectory}/web/public/wiki/mediawiki"}
if (!$php_path)
{$php_path=$PlaScrDefaultPHPPath}

if (!(Test-Path $cre_json))
{Write-Error "Cannot find JSON file containing credentials." -Category ObjectNotFound
exit}
if (!(Test-Path $mediawiki_dir))
{Write-Error "Cannot find MediaWiki directory." -Category NotInstalled
exit}
if (!(Test-Path $php_path))
{Write-Error "Cannot find PHP." -Category NotInstalled
exit}

$credentials=Get-Content $cre_json -Force | ConvertFrom-Json
$database_username=$credentials."database"."username"
$database_password=$credentials."database"."password"
$wiki_username=$credentials."wiki"."username"
$wiki_password=$credentials."wiki"."password"

Write-Verbose "Creating data directory"
New-Item $data_dir -Force -ItemType Directory
Write-Verbose "Creating per-wiki data directory"
New-Item "${data_dir}/per-wiki" -Force -ItemType Directory
Write-Verbose "Creating data directory of ${wiki}"
New-Item "${data_dir}/per-wiki/${wiki}" -Force -ItemType Directory
Write-Verbose "Creating private data directory"
New-Item "${data_dir}/private" -Force -ItemType Directory
Write-Verbose "Creating per-wiki private data directory"
New-Item "${data_dir}/private/per-wiki" -Force -ItemType Directory
Write-Verbose "Creating private data directory of ${wiki}"
New-Item "${data_dir}/private/per-wiki/${wiki}" -Force -ItemType Directory
Write-Verbose "Creating a directory for files that will be deleted on ${wiki}"
New-Item "${data_dir}/private/per-wiki/${wiki}/deleted-files" -Force -ItemType Directory
Write-Verbose "Creating a directory for files that will be uploaded to ${wiki}"
New-Item "${data_dir}/private/per-wiki/${wiki}/files" -Force -ItemType Directory

if (Test-Path "${mediawiki_dir}/LocalSettings.php")
{Write-Warning "Renaming LocalSettings.php file temporarily"
Move-Item "${mediawiki_dir}/LocalSettings.php" "${mediawiki_dir}/LocalSettings-temp.php" -Force}

Write-Verbose "Running installation script"
.$php_path "${mediawiki_dir}/maintenance/install.php" $wiki_username --confpath "${data_dir}/private/per-wiki/${wiki}" --dbname "${wiki}wiki" --dbpath "${data_dir}/private/databases" --installdbpass $database_password --installdbuser $database_username --pass $wiki_password

if (Test-Path "${mediawiki_dir}/LocalSettings-temp.php")
{Write-Warning "Restoring LocalSettings.php file"
Move-Item "${mediawiki_dir}/LocalSettings-temp.php" "${mediawiki_dir}/LocalSettings.php" -Force}

."${PSScriptRoot}/maintenance.ps1" $mediawiki_dir -data_dir $data_dir -init -php_path $php_path -wiki $wiki

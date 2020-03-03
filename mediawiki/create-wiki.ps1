#Creates a wiki.

#Parameter names should not contain "cred" or "password" to avoid warnings
Param
([Parameter(Mandatory=$true)][string]$cre_json, #JSON file containing credentials
[Parameter(Position=0)][string]$mediawiki_dir, #MediaWiki directory
[string]$php_path, #Path of PHP
[string]$private_data_dir, #Private data directory
[Parameter(Mandatory=$true,Position=1)][string]$wiki) #Wiki ID

if (Test-Path "${PSScriptRoot}/../init-script.ps1")
{if (!(."${PSScriptRoot}/../init-script.ps1"))
  {exit}
}
else
{Write-Error "Cannot find init-script.ps1 file." -Category ObjectNotFound
exit}

if (!$mediawiki_dir)
{$mediawiki_dir="${PlaScrDefaultBaseDirectory}/web/public/wiki/mediawiki"}
if (!$php_path)
{$php_path=$PlaScrDefaultPHPPath}
if (!$private_data_dir)
{$private_data_dir="${PlaScrDefaultBaseDirectory}/web/data/mediawiki"}

if (!(Test-Path $cre_json))
{Write-Error "Cannot find JSON file containing credentials." -Category ObjectNotFound
exit}
if (!(Test-Path $php_path))
{Write-Error "Cannot find PHP." -Category NotInstalled
exit}

$credentials=Get-Content $cre_json -Force | ConvertFrom-Json
$database_username=$credentials."database"."username"
$database_password=$credentials."database"."password"
$wiki_username=$credentials."wiki"."username"
$wiki_password=$credentials."wiki"."password"

if (Test-Path $mediawiki_dir)
{Write-Verbose "Creating data directory"
New-Item "${mediawiki_dir}/data" -Force -ItemType Directory
Write-Verbose "Creating data directory of ${wiki}"
New-Item "${mediawiki_dir}/data/${wiki}" -Force -ItemType Directory
Write-Verbose "Creating private data directory"
New-Item $private_data_dir -Force -ItemType Directory
Write-Verbose "Creating private data directory of ${wiki}"
New-Item "${private_data_dir}/${wiki}" -Force -ItemType Directory
Write-Verbose "Creating a directory for files that will be deleted on ${wiki}"
New-Item "${private_data_dir}/${wiki}/deleted-files" -Force -ItemType Directory
Write-Verbose "Creating a directory for files that will be uploaded to ${wiki}"
New-Item "${private_data_dir}/${wiki}/files" -Force -ItemType Directory

if (Test-Path "${mediawiki_dir}/LocalSettings.php")
  {Write-Warning "Renaming LocalSettings.php file temporarily"
  Move-Item "${mediawiki_dir}/LocalSettings.php" "${mediawiki_dir}/LocalSettings-temp.php" -Force}

Write-Verbose "Running installation script"
.$php_path "${mediawiki_dir}/maintenance/install.php" $wiki_username --confpath "${private_data_dir}/${wiki}" --dbname "${wiki}wiki" --dbpath "${private_data_dir}/databases" --installdbpass $database_password --installdbuser $database_username --pass $wiki_password

if (Test-Path "${mediawiki_dir}/LocalSettings-temp.php")
  {Write-Warning "Restoring LocalSettings.php file"
  Move-Item "${mediawiki_dir}/LocalSettings-temp.php" "${mediawiki_dir}/LocalSettings.php" -Force}

."${PSScriptRoot}/maintenance.ps1" $mediawiki_dir -init -php_path $php_path -private_data_dir $private_data_dir -wiki $wiki}
else
{Write-Error "Cannot find MediaWiki directory." -Category NotInstalled}

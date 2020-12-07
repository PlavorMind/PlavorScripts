#Downloads extensions and skins for MediaWiki.

Param
([string]$composer_local_json, #File path or URL of composer.local.json file
[string]$composer_path, #Path of Composer
[string]$extension_branch="master", #Branch for extensions
[Parameter(Position=1)][string]$extras_json="${HOME}/OneDrive/Documents/extras.json", #File path or URL of JSON file for downloading extensions and skins
[Parameter(Position=0)][string]$mediawiki_dir, #MediaWiki directory
[string]$php_path, #Path of PHP
[string]$skin_branch="master") #Branch for skins

if (Test-Path "${PSScriptRoot}/../init-script.ps1")
{if (!(."${PSScriptRoot}/../init-script.ps1"))
  {exit}
}
else
{Write-Error "Cannot find init-script.ps1 file." -Category ObjectNotFound
exit}

if (!$composer_path)
{if ($IsLinux)
  {$composer_path="${PlaScrDefaultBaseDirectory}/composer.phar"}
elseif ($IsWindows)
  {$composer_path="${PlaScrDefaultBaseDirectory}/php/data/composer.phar"}
else
  {Write-Error "Cannot detect default Composer path." -Category NotSpecified
  exit}
}
if (!$mediawiki_dir)
{$mediawiki_dir="${PlaScrDefaultBaseDirectory}/web/public/wiki/mediawiki"}
if (!$php_path)
{$php_path=$PlaScrDefaultPHPPath}

if (!(Test-Path $composer_path))
{Write-Error "Cannot find Composer." -Category NotInstalled
exit}
if (!(Test-Path $mediawiki_dir))
{Write-Error "Cannot find MediaWiki directory." -Category NotInstalled
exit}
if (!(Test-Path $php_path))
{Write-Error "Cannot find PHP." -Category NotInstalled
exit}

$output=Get-FilePathFromURL $extras_json
if ($output)
{$extras_json_object=Get-Content $output -Force | ConvertFrom-Json

foreach ($extra_type in @("extensions","skins"))
  {$extras=(Get-Member -InputObject $extras_json_object.$extra_type -MemberType Properties)."Name"

  foreach ($extra in $extras)
    {$extra_object=$extras_json_object.$extra_type.$extra
    switch ($extra_type)
      {"extensions"
        {$composer_updating="Updating dependencies for ${extra} extension with Composer"
        $default_branch=$extension_branch
        $download_failed="Cannot download ${extra} extension."
        $downloading="Downloading ${extra} extension"}
      "skins"
        {$composer_updating="Updating dependencies for ${extra} skin with Composer"
        $default_branch=$skin_branch
        $download_failed="Cannot download ${extra} skin."
        $downloading="Downloading ${extra} skin"}
      }

    if (!($extra_object."disabled"))
      {if ($extra_object."force-branch")
        {$branch=$extra_object."force-branch"}
      else
        {$branch=$default_branch}

      switch ($extra_object."source")
        {"bitbucket"
          {$download_url="https://bitbucket.org/"+$extra_object."git-service-username"+"/"+$extra_object."git-service-repository"+"/get/${branch}.zip"}
        "custom"
          {$download_url=$extra_object."custom-download-url"}
        "github"
          {$download_url="https://github.com/"+$extra_object."git-service-username"+"/"+$extra_object."git-service-repository"+"/archive/${branch}.zip"}
        "gitlab"
          {$download_url="https://gitlab.com/"+$extra_object."git-service-username"+"/"+$extra_object."git-service-repository"+"/-/archive/${branch}/"+$extra_object."git-service-repository"+"-${branch}.zip"}
        Default
          {$download_url="https://github.com/wikimedia/mediawiki-${extra_type}-${extra}/archive/${branch}.zip"}
        }

      Write-Verbose $downloading
      Expand-ArchiveSmart $download_url "${mediawiki_dir}/${extra_type}/${extra}"
      if (Test-Path "${mediawiki_dir}/${extra_type}/${extra}")
        {if ($extra_object."require-composer")
          {Write-Verbose $composer_updating
          .$php_path $composer_path update --no-cache --no-dev --working-dir="${mediawiki_dir}/${extra_type}/${extra}"}
        }
      else
        {Write-Error $download_failed -Category ConnectionError}
      }
    }
  }
}
else
{Write-Error "Cannot download or find JSON file for downloading extensions and skins." -Category ObjectNotFound}

$output=Get-FilePathFromURL $composer_local_json
if ($output)
{if ($output -like "${PlaScrTempDirectory}*")
  {Write-Verbose "Moving composer.local.json file"
  Move-Item $output "${mediawiki_dir}/composer.local.json" -Force}
else
  {Write-Verbose "Copying composer.local.json file"
  Copy-Item $output "${mediawiki_dir}/composer.local.json" -Force}
Write-Verbose "Updating dependencies with Composer"
.$php_path $composer_path update --no-cache --no-dev --working-dir=$mediawiki_dir}
else
{Write-Error "Cannot download or find composer.local.json file." -Category ObjectNotFound}

#Copys additional files for init-dir.ps1 script.

Param([Parameter(Position=0)][string]$web_dir) #Web directory

if (Test-Path "${PSScriptRoot}/../init-script.ps1")
{if (!(."${PSScriptRoot}/../init-script.ps1"))
  {exit}
}
else
{Write-Error "Cannot find init-script.ps1 file." -Category ObjectNotFound
exit}

if (!$web_dir)
{$web_dir="${PlaScrDefaultBaseDirectory}/web"}

if (!(Test-Path $web_dir))
{Write-Error "Cannot find web directory." -Category ObjectNotFound
exit}

if (Test-Path "${PSScriptRoot}/additional-files")
{Write-Warning "Renaming existing directory for additional files"
Move-Item "${PSScriptRoot}/additional-files" "${PSScriptRoot}/additional-files-old" -Force}
Write-Verbose "Creating a directory for additioanl files"
New-Item "${PSScriptRoot}/additional-files" -Force -ItemType Directory

if (Test-Path "${web_dir}/default")
{Write-Verbose "Creating default directory"
New-Item "${PSScriptRoot}/additional-files/default" -Force -ItemType Directory

if (Test-Path "${web_dir}/default/favicon.ico")
  {Write-Verbose "Copying default/favicon.ico file"
  Copy-Item "${web_dir}/default/favicon.ico" "${PSScriptRoot}/additional-files/default/" -Force}
}

if (Test-Path "${web_dir}/public/wiki/resources")
{Write-Verbose "Creating public directory"
New-Item "${PSScriptRoot}/additional-files/public" -Force -ItemType Directory
Write-Verbose "Creating public/wiki directory"
New-Item "${PSScriptRoot}/additional-files/public/wiki" -Force -ItemType Directory
Write-Verbose "Copying public/wiki/resources directory"
Copy-Item "${web_dir}/public/wiki/resources" "${PSScriptRoot}/additional-files/public/wiki/" -Force -Recurse}

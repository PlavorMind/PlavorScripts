#Copys additional files for init-dir.ps1 script.

Param([Parameter(Position=0)][string]$web_dir) #Web server directory

if (Test-Path "${PSScriptRoot}/../init-script.ps1")
{."${PSScriptRoot}/../init-script.ps1"}
else
{Write-Error "Cannot find initialize script." -Category ObjectNotFound
exit}

if (!$web_dir)
{if ($IsLinux)
  {$web_dir="/plavormind/web"}
elseif ($IsWindows)
  {$web_dir="C:/plavormind/web"}
else
  {Write-Error "Cannot detect default directory." -Category NotSpecified
  exit}
}

if (!(Test-Path $web_dir))
{Write-Error "Cannot find web server directory." -Category ObjectNotFound
exit}

if (Test-Path "${PSScriptRoot}/additional-files")
{Write-Warning "Renaming existing directory for additional files"
Move-Item "${PSScriptRoot}/additional-files" "${PSScriptRoot}/additional-files-old" -Force}
Write-Verbose "Creating a directory for additioanl files"
New-Item "${PSScriptRoot}/additional-files" -Force -ItemType Directory

if (Test-Path "${dir}/default")
{Write-Verbose "Creating default directory"
New-Item "${PSScriptRoot}/additional-files/default" -Force -ItemType Directory

if (Test-Path "${dir}/default/favicon.ico")
  {Write-Verbose "Copying default/favicon.ico file"
  Copy-Item "${dir}/default/favicon.ico" "${PSScriptRoot}/additional-files/default/"}
}

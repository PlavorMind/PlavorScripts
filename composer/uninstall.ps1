#Uninstalls Composer.

Param([Parameter(Position=0)][string]$dir) #Composer directory

if (Test-Path "${PSScriptRoot}/../init-script.ps1")
{if (!(."${PSScriptRoot}/../init-script.ps1"))
  {exit}
}
else
{Write-Error "Cannot find init-script.ps1 file." -Category ObjectNotFound
exit}

if (!$dir)
{$dir="${PlaScrDefaultBaseDirectory}/composer"}

if (!(Test-Path $dir))
{Write-Error "Cannot find Composer." -Category NotInstalled
exit}

if ($IsWindows)
{$path_script="${PlaScrDefaultBaseDirectory}/path/composer.cmd"}
else
{$path_script="${PlaScrDefaultBaseDirectory}/path/composer"}
if (Test-Path $path_script)
{Write-Verbose "Deleting the script for PATH"
Remove-Item $path_script -Force}

if ($IsWindows)
{if (Test-Path "${Env:APPDATA}/Composer")
  {Write-Verbose "Deleting Composer home directory"
  Remove-Item "${Env:APPDATA}/Composer" -Force -Recurse}
if (Test-Path "${Env:LOCALAPPDATA}/Composer")
  {Write-Verbose "Deleting Composer cache directory"
  Remove-Item "${Env:LOCALAPPDATA}/Composer" -Force -Recurse}
}
else
{if (Test-Path "${Env:XDG_CONFIG_HOME}/composer")
  {Write-Verbose "Deleting Composer home directory"
  Remove-Item "${Env:XDG_CONFIG_HOME}/composer" -Force -Recurse}
elseif (Test-Path "${HOME}/composer")
  {Write-Verbose "Deleting Composer home directory"
  Remove-Item "${HOME}/composer" -Force -Recurse}
}

Write-Verbose "Deleting Composer directory"
Remove-Item $dir -Force -Recurse

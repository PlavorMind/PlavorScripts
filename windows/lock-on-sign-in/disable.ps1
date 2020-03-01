#Disables locking when a user signs in.

Param([Parameter()][switch]$allusers) #Apply to all users

if (Test-Path "${PSScriptRoot}/../../init-script.ps1")
{if (!(."${PSScriptRoot}/../../init-script.ps1"))
  {exit}
}
else
{Write-Error "Cannot find init-script.ps1 file." -Category ObjectNotFound
exit}

if (!$IsWindows)
{Write-Error "Your operating system is not supported."
exit}

if ($allusers)
{if (!(Test-AdminPermission))
  {Write-Error "This script must be run as administrator to apply to all users." -Category PermissionDenied
  exit}
$path="C:/ProgramData/Microsoft/Windows/Start Menu/Programs/Startup/Lock.lnk"}
else
{$path="${Env:APPDATA}/Microsoft/Windows/Start Menu/Programs/Startup/Lock.lnk"}

if (Test-Path $path)
{Write-Verbose "Disabling Lock on Sign In"
Remove-Item $path -Force}
else
{Write-Error "Lock on Sign In is not enabled." -Category NotEnabled}

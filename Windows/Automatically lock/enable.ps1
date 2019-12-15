#Enables automatically lock when signing in. Useful when using automatic login.

Param([Parameter()][switch]$allusers) #Apply to all users if this parameter is set

if (Test-Path "${PSScriptRoot}/../../init-script.ps1")
{."${PSScriptRoot}/../../init-script.ps1"}
else
{Write-Error "Cannot find initialize script." -Category ObjectNotFound
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
{Write-Error "Automatically lock is already enabled."}
else
{Write-Verbose "Enabling automatically lock"
New-Shortcut $path "C:/Windows/System32/rundll32.exe" -Arguments "user32.dll,LockWorkStation"}

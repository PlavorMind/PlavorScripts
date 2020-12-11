#Manages firewall rule for allowing connections to nginx.

Param
([Parameter(Position=0)][string]$action, #Action to run
[string]$dir) #nginx directory

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

if (!$dir)
{$dir="${PlaScrDefaultBaseDirectory}/nginx"}

if (!(Test-AdminPermission))
{Write-Error "This script must be run as administrator." -Category PermissionDenied
exit}

if ($action)
{if (Get-NetFirewallRule -ErrorAction Ignore -Name "nginx")
  {switch ($action)
    {"delete"
      {Write-Verbose "Deleting the firewall rule"
      Remove-NetFirewallRule -Name "nginx"}
    "disable"
      {Write-Verbose "Disabling the firewall rule"
      Disable-NetFirewallRule -Name "nginx"}
    }
  }
else
  {Write-Error "Cannot find the firewall rule." -Category ObjectNotFound}
}
else
{if (Get-NetFirewallRule -ErrorAction Ignore -Name "nginx")
  {Write-Verbose "Enabling the firewall rule"
  Enable-NetFirewallRule -Name "nginx"}
elseif (Test-Path "${dir}/nginx.exe")
  {Write-Verbose "Creating a firewall rule"
  $path="${dir}/nginx.exe".Replace("/","\")
  New-NetFirewallRule -Action Allow -Description "Allows connections to nginx" -DisplayName "nginx" -Name "nginx" -Program $path}
else
  {Write-Error "Cannot find nginx." -Category NotInstalled}
}

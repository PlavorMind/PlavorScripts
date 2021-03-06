#Manages firewall rule for allowing connections to Apache HTTP Server.

Param
([Parameter(Position=0)][string]$action, #Action to run
[string]$dir) #Apache HTTP Server directory

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
{$dir="${PlaScrDefaultBaseDirectory}/apache-httpd"}

if (!(Test-AdminPermission))
{Write-Error "This script must be run as administrator." -Category PermissionDenied
exit}

if ($action)
{if (Get-NetFirewallRule -ErrorAction Ignore -Name "apache-httpd")
  {switch ($action)
    {"delete"
      {Write-Verbose "Deleting the firewall rule"
      Remove-NetFirewallRule -Name "apache-httpd"}
    "disable"
      {Write-Verbose "Disabling the firewall rule"
      Disable-NetFirewallRule -Name "apache-httpd"}
    }
  }
else
  {Write-Error "Cannot find the firewall rule." -Category ObjectNotFound}
}
else
{if (Get-NetFirewallRule -ErrorAction Ignore -Name "apache-httpd")
  {Write-Verbose "Enabling the firewall rule"
  Enable-NetFirewallRule -Name "apache-httpd"}
elseif (Test-Path "${dir}/bin/httpd.exe")
  {Write-Verbose "Creating a firewall rule"
  $path="${dir}/bin/httpd.exe".Replace("/","\")
  New-NetFirewallRule -Action Allow -Description "Allows connections to Apache HTTP Server" -DisplayName "Apache HTTP Server" -Name "apache-httpd" -Program $path}
else
  {Write-Error "Cannot find Apache HTTP Server." -Category NotInstalled}
}

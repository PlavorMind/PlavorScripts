#Creates a firewall rule for blocking IP addresses

Param
([string]$display_name="IP address blacklist",
[string]$name="ip-blacklist",
[Parameter(Mandatory=$true,Position=0)][array]$sources) #Array of file paths or URLs of IP address blacklist sources

if (Test-Path "${PSScriptRoot}/../init-script.ps1")
{if (!(."${PSScriptRoot}/../init-script.ps1"))
  {exit}
}
else
{Write-Error "Cannot find init-script.ps1 file." -Category ObjectNotFound
exit}

if (!(Test-AdminPermission))
{Write-Error "This script must be run as administrator on Windows." -Category PermissionDenied
exit}

if (Test-Path "${PSScriptRoot}/../create-ip-blacklist.ps1")
{$blacklisted_ips=."${PSScriptRoot}/../create-ip-blacklist.ps1" $sources
if ($blacklisted_ips)
  {if (Get-NetFirewallRule -ErrorAction Ignore -Name $name)
    {Write-Verbose "Updating existing firewall rule"
    Set-NetFirewallRule -Name $name -RemoteAddress $blacklisted_ips}
  else
    {Write-Verbose "Creating a firewall rule"
    New-NetFirewallRule -Action Block -Description "Blocks some IP addresses" -DisplayName $display_name -Name $name -RemoteAddress $blacklisted_ips}
  }
}
else
{Write-Error "Cannot find create-ip-blacklist.ps1 file." -Category ObjectNotFound
exit}

#Creates an IP address blacklist for specific platform.

Param
([Parameter(Position=1)][string]$destpath, #Destination path to save created IP address blacklist
[Parameter(Position=0)][string]$path="${PSScriptRoot}/additional-files/blacklist.txt", #File path or URL to an IP address blacklist source
[string]$platform="apache-httpd") #Target platform

if (Test-Path "${PSScriptRoot}/init-script.ps1")
{."${PSScriptRoot}/init-script.ps1"}
else
{Write-Error "Cannot find initialize script." -Category ObjectNotFound
exit}

switch ($platform)
{"apache-httpd"
  {if (!$destpath)
    {if ($IsWindows)
      {$destpath="C:/plavormind/apache-httpd/conf/private/blacklist.conf"}
    else
      {Write-Error "Cannot detect default destination path." -Category NotSpecified
      exit}
    }
  }
"firewall"
  {if ($IsWindows)
    {if (!(Test-AdminPermission))
      {Write-Error "This script must be run as administrator to create a firewall rule on Windows." -Category PermissionDenied
      exit}
    }
  else
    {Write-Error "Your operating system is not supported."
    exit}
  }
"nginx"
  {if (!$destpath)
    {if ($IsWindows)
      {$destpath="C:/plavormind/nginx/conf/private/blacklist.conf"}
    else
      {Write-Error "Cannot detect default destination path." -Category NotSpecified
      exit}
    }
  }
}

$output=Get-FilePathFromUri $path
if ($output)
{$blacklist=((Get-Content $output -Force) -replace "#.*","").Trim()  | Where-Object {$PSItem -ne ""}
if ($output -like "${tempdir}*")
  {Write-Verbose "Deleting a file that is no longer needed"
  Remove-Item $output -Force}

switch ($platform)
  {"apache-httpd"
    {Write-Verbose "Creating IP address blacklist for Apache HTTP Server"
    $result="Require not ip "
    foreach ($blacklisted_ip in $blacklist)
      {$result+="`"${blacklisted_ip}`" "}
    $result > $destpath}
  "firewall"
    {if ($IsWindows)
      {if (Get-NetFirewallRule -ErrorAction Ignore -Name "ip-blacklist")
        {Write-Verbose "Updating existing firewall rule with IP address blacklist source"
        Set-NetFirewallRule -Name "ip-blacklist" -RemoteAddress $blacklist}
      else
        {Write-Verbose "Creating a firewall rule with IP address blacklist source"
        New-NetFirewallRule -Action Block -Description "Blocks some IP addresses" -DisplayName "IP address blacklist" -Name "ip-blacklist" -RemoteAddress $blacklist}
      }
    }
  "nginx"
    {Write-Verbose "Creating IP address blacklist for nginx"
    Out-Null > $destpath
    foreach ($blacklisted_ip in $blacklist)
      {"deny `"${blacklisted_ip}`";" >> $destpath}
    }
  }
}
else
{Write-Error "Cannot download or find IP address blacklist." -Category ObjectNotFound}

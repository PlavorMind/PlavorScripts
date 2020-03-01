#Creates an IP address blacklist for specific platform.

Param
([Parameter(Position=1)][string]$destpath, #Destination path or file name of firewall rule to save created IP address blacklist
[Parameter(Mandatory=$true,Position=0)][string]$path, #File path or URL to an IP address blacklist source
[Parameter(Mandatory=$true)][string]$platform) #Target platform

if (Test-Path "${PSScriptRoot}/init-script.ps1")
{if (!(."${PSScriptRoot}/init-script.ps1"))
  {exit}
}
else
{Write-Error "Cannot find init-script.ps1 file." -Category ObjectNotFound
exit}

switch ($platform)
{"apache-httpd"
  {if (!$destpath)
    {if ($IsWindows)
      {$destpath="${PlaScrDefaultBaseDirectory}/apache-httpd/conf/private/blacklist-soft.conf"}
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

    if (!$destpath)
      {$destpath="ip-blacklist"}
    }
  else
    {Write-Error "Your operating system is not supported."
    exit}
  }
"nginx"
  {if (!$destpath)
    {if ($IsWindows)
      {$destpath="${PlaScrDefaultBaseDirectory}/nginx/conf/private/blacklist.conf"}
    else
      {Write-Error "Cannot detect default destination path." -Category NotSpecified
      exit}
    }
  }
}

$output=Get-FilePathFromURL $path
if ($output)
{$blacklist=((Get-Content $output -Force) -replace "#.*","").Trim() | Where-Object {$PSItem -ne ""}
if ($output -like "${PlaScrTempDirectory}*")
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
      {if (Get-NetFirewallRule -ErrorAction Ignore -Name $destpath)
        {Write-Verbose "Updating existing firewall rule with IP address blacklist source"
        Set-NetFirewallRule -Name $destpath -RemoteAddress $blacklist}
      else
        {Write-Verbose "Creating a firewall rule with IP address blacklist source"
        New-NetFirewallRule -Action Block -Description "Blocks some IP addresses" -DisplayName "IP address blacklist" -Name $destpath -RemoteAddress $blacklist}
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

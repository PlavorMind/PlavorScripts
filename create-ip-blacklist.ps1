#Creates an IP address blacklist in specific type.

Param
([Parameter(Mandatory=$true,Position=0)][array]$sources, #Array of file paths or URLs of IP address blacklist sources
[Parameter(Position=1)][string]$path, #Path to save IP address blacklist
[string]$type) #Type for IP address blacklist

if (Test-Path "${PSScriptRoot}/init-script.ps1")
{if (!(."${PSScriptRoot}/init-script.ps1"))
  {exit}
}
else
{Write-Error "Cannot find init-script.ps1 file." -Category ObjectNotFound
exit}

if (!$path -and $type)
{switch ($type)
  {"apache-httpd"
    {if ($IsWindows)
      {$path="${PlaScrDefaultBaseDirectory}/apache-httpd/conf/private/blacklist-soft.conf"}
    else
      {Write-Error "Cannot detect default path." -Category NotSpecified
      exit}
    }
  "nginx"
    {if ($IsWindows)
      {$path="${PlaScrDefaultBaseDirectory}/nginx/conf/private/blacklist-soft.conf"}
    else
      {Write-Error "Cannot detect default path." -Category NotSpecified
      exit}
    }
  }
}

$blacklists=@()
foreach ($source in $sources)
{$output=Get-FilePathFromURL $source
if ($output)
  {$blacklists+=$output}
else
  {Write-Error "Cannot download or find ${source} IP address blacklist source." -Category ObjectNotFound}
}
if ($blacklists.Count -lt 1)
{exit}

$blacklisted_ips=@()
foreach ($blacklist in $blacklists)
{$blacklisted_ips+=((Get-Content $blacklist -Force) -replace "#.*","").Trim() | Where-Object {$PSItem -ne ""}
#Delete a temporary file here because it should be read before deleting.
if ($blacklist -like "${PlaScrTempDirectory}*")
  {Write-Verbose "Deleting a temporary file"
  Remove-Item $output -Force}
}

switch ($type)
{"apache-httpd"
  {Write-Verbose "Creating IP address blacklist for Apache HTTP Server"
  $result="Require not ip "
  foreach ($blacklisted_ip in $blacklisted_ips)
    {$result+="`"${blacklisted_ip}`" "}
  $result > $path}
"nginx"
  {Write-Verbose "Creating IP address blacklist for nginx"
  Out-Null > $path
  foreach ($blacklisted_ip in $blacklisted_ips)
    {"deny `"${blacklisted_ip}`";" >> $path}
  }
Default
  {$blacklisted_ips}
}

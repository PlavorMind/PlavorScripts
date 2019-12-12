#Creates an IP address blacklist for specific platform.

Param
([Parameter(Position=1)][string]$destpath, #Destination path to save created IP address blacklist
[Parameter(Position=0)][string]$path, #File path or URL to an IP address blacklist source
[string]$platform="apache-httpd") #Target platform

if (Test-Path "${PSScriptRoot}/init-script.ps1")
{."${PSScriptRoot}/init-script.ps1"}
else
{Write-Error "Cannot find initialize script." -Category ObjectNotFound
exit}

if (!$destpath)
{if ($IsWindows)
  {$destpath="C:/plavormind/apache-httpd/conf/private/blacklist.conf"}
else
  {Write-Error "Cannot detect default destination path." -Category NotSpecified
  exit}
}

if (!$path)
{if ($IsLinux)
  {$path="/home/pseol2190/Documents/blacklist.txt"}
elseif ($IsWindows)
  {$path="${Env:USERPROFILE}/OneDrive/Documents/blacklist.txt"}
else
  {Write-Error "Cannot detect default path." -Category NotSpecified
  exit}
}

$output=Get-FilePathFromUri $path
if ($output)
{$blacklist=(Get-Content $output -Force).Trim() -replace "#.*","" | Where-Object {$PSItem -ne ""}

if ($output -like "${tempdir}*")
  {Write-Verbose "Deleting files that are no longer needed"
  Remove-Item $output -Force}

switch ($platform)
  {"apache-httpd"
    {Write-Verbose "Creating IP address blacklist for Apache HTTP Server"
    "<RequireAll>" > $destpath
    "Require all granted" >> $destpath
    $result="Require not ip "
    foreach ($blacklisted_ip in $blacklist)
      {$result+="`"${blacklisted_ip}`" "}
    $result >> $destpath
    "</RequireAll>" >> $destpath}
  "nginx"
    {Write-Verbose "Creating IP address blacklist for nginx"
    $null > $destpath
    foreach ($blacklisted_ip in $blacklist)
      {"deny `"${blacklisted_ip}`";" >> $destpath}
    }
  }
}
else
{Write-Error "Cannot download or find IP address blacklist." -Category ObjectNotFound}

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

if (!$destpath)
{if ($IsWindows)
  {$destpath="C:/plavormind/apache-httpd/conf/private/blacklist.conf"}
else
  {Write-Error "Cannot detect default destination path." -Category NotSpecified
  exit}
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

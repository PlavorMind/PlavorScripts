#Filters web server logs.

Param
([Parameter(Position=1)][string]$destdir="${PSScriptRoot}/filtered-logs", #Destination directory to save filtered logs
[Parameter(Position=0)][string]$dir) #Logs directory to filter

if (Test-Path "${PSScriptRoot}/init-script.ps1")
{if (!(."${PSScriptRoot}/init-script.ps1"))
  {exit}
}
else
{Write-Error "Cannot find init-script.ps1 file." -Category ObjectNotFound
exit}

if (!$dir)
{if ($IsWindows)
  {$dir="${PlaScrDefaultBaseDirectory}/apache-httpd/logs"}
else
  {Write-Error "Cannot detect default directory." -Category NotSpecified
  exit}
}

if (!(Test-Path $dir))
{Write-Error "Cannot find logs directory." -Category ObjectNotFound
exit}

if (Test-Path $destdir)
{Write-Warning "Renaming existing directory for filtered logs"
Move-Item $destdir "${destdir}-old" -Force}
Write-Verbose "Creating a directory for filtered logs"
New-Item $destdir -Force -ItemType Directory

foreach ($log_directory in Get-ChildItem $dir -Directory -Force -Name)
{Write-Verbose "Creating ${log_directory} directory"
New-Item "${destdir}/${log_directory}" -Force -ItemType Directory}

foreach ($log_file in Get-ChildItem $dir -File -Force -Name -Recurse)
{Write-Verbose "Filtering ${log_file} file"
Select-String "^(127\.0\.0\.\d+|192\.168\.35\.1|::1 )|`"GET login\.cgi HTTP\/1\.1`" 400 \d+ `"-`" `"-`"$" "${dir}/${log_file}" -NotMatch -Raw > "${destdir}/${log_file}"

if ($log_file -notlike "*.pid")
  {Write-Verbose "Blanking original file"
  #$null > "${dir}/${log_file}" should not be used because of a bug on Windows.
  Set-Content "${dir}/${log_file}" $null -Encoding utf8 -Force}
}

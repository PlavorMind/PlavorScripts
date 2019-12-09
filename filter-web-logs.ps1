#Filters web server logs.

Param
([Parameter(Position=1)][string]$destdir="${PSScriptRoot}/filtered-logs", #Destination directory to save filtered logs
[Parameter(Position=0)][string]$dir) #Logs directory to filter

if (Test-Path "${PSScriptRoot}/init-script.ps1")
{."${PSScriptRoot}/init-script.ps1"}
else
{Write-Error "Cannot find initialize script." -Category ObjectNotFound
exit}

if (!$dir)
{if ($IsWindows)
  {$dir="C:/plavormind/apache-httpd/logs"}
else
  {Write-Error "Cannot detect default directory."
  exit}
}

if (!(Test-Path $dir))
{Write-Error "Cannot find logs directory." -Category ObjectNotFound
exit}
#End of preconditions

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
Select-String "(^(127\.0\.0\.[0-9]+|192\.168\.219\.30|::1 ).*|.*GET login\.cgi.*400 150.*)" "${dir}/${log_file}" -NotMatch | Select-Object -ExpandProperty Line > "${destdir}/${log_file}"

if ($log_file -notlike "*.pid")
  {Write-Verbose "Blanking original file"
  #$null > "${dir}/${log_file}" should not be used because of a bug on Windows.
  Set-Content "${dir}/${log_file}" $null -Encoding utf8 -Force}
}

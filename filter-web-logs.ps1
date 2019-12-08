#Filters web server logs.

Param
([Parameter(Position=1)][string]$destdir="${PSScriptRoot}/filtered-logs", #Destination directory to save filtered web server logs
[Parameter(Position=0)][string]$dir) #Web server logs directory to filter

if (Test-Path "${PSScriptRoot}/init-script.ps1")
{."${PSScriptRoot}/init-script.ps1"}
else
{Write-Error "Cannot find initialize script." -Category ObjectNotFound
exit}

if (!$dir)
{if ($IsLinux)
  {$dir="/etc/nginx/logs"}
elseif ($IsWindows)
  {$dir="C:/plavormind/nginx/logs"}
else
  {Write-Error "Cannot detect default directory."
  exit}
}

if (!(Test-Path $dir))
{"Cannot find web server logs directory."
exit}

if (Test-Path $destdir)
{"Renaming existing directory for filtered logs"
Move-Item $destdir "${destdir}-old" -Force}
"Creating a directory for filtered logs"
New-Item $destdir -Force -ItemType Directory

$log_directories=Get-ChildItem $dir -Directory -Force -Name
foreach ($log_directory in $log_directories)
{"Creating ${log_directory} directory"
New-Item "${destdir}/${log_directory}" -Force -ItemType Directory}

$log_files=Get-ChildItem $dir -File -Force -Name -Recurse
foreach ($log_file in $log_files)
{"Filtering ${log_file} file"
Select-String "(^(127\.0\.0\.[0-9]+|192\.168\.219\.30|::1 ).*|.*GET login\.cgi.*400 150.*)" "${dir}/${log_file}" -NotMatch | Select-Object -ExpandProperty Line > "${destdir}/${log_file}"

if ($log_file -like "*error.log")
  {"Blanking original file"
  #$null > "${dir}/${log_file}" should not be used because of a bug on Windows.
  Set-Content "${dir}/${log_file}" $null -Encoding utf8 -Force}
elseif ($log_file -ne "nginx.pid")
  {"Deleting original file"
  Remove-Item "${dir}/${log_file}" -Force}
}

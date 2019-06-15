#Filter web logs
#Filters web server logs.

param
([string]$destdir="${PSScriptRoot}/filtered_logs", #Destination directory to save filtered web server logs
[string]$dir="__DEFAULT__") #Web server logs directory to filter

if (Test-Path "${PSScriptRoot}/init_script.ps1")
{."${PSScriptRoot}/init_script.ps1"}
else
{"Cannot find initialize script."
exit}

if ($dir -eq "__DEFAULT__")
{if ($IsLinux)
  {$dir="/etc/nginx/logs"}
elseif ($IsWindows)
  {$dir="C:/nginx/logs"}
else
  {"Cannot detect default directory."
  exit}
}

if (Test-Path $dir)
{if (Test-Path $destdir)
  {Write-Information "Renaming existing directory for filtered logs"
  Move-Item $destdir "${destdir}_old" -Force}

Write-Verbose "Creating a directory for filtered logs"
New-Item $destdir -Force -ItemType Directory | Write-Verbose

$log_directories=Get-ChildItem $dir -Directory -Force -Name
foreach ($log_directory in $log_directories)
  {Write-Verbose "Creating a directory for ${log_directory} log"
  New-Item "${destdir}/${log_directory}" -Force -ItemType Directory | Write-Verbose

  $log_files=Get-ChildItem "${dir}/${log_directory}" -File -Force -Name
  foreach ($log_file in $log_files)
    {Write-Verbose "Filtering ${log_directory}/${log_file} file"
    Get-Content "${dir}/${log_directory}/${log_file}" -Encoding utf8 -Force | Select-String "(^(127\.0\.0\.[0-9]+|192\.168\.219\.30|::1 ).*|.*GET login\.cgi HTTP\/1\.1.*400 150.*)" -Encoding utf8 -NotMatch > "${destdir}/${log_directory}/${log_file}"

    Write-Verbose "Blanking original log"
    #$null > "${dir}/${log_directory}/${log_file}" should not be used because of a bug on Windows.
    Set-Content "${dir}/${log_directory}/${log_file}" $null -Encoding utf8 -Force}
  }
}
else
{"Cannot find web server logs directory."}

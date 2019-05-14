#Filter web log
#Filters web server log.

param
([switch]$blank_source, #Blanks the source file after filtering if this is set
[string]$destpath="filtered.log", #Destination path to save filtered web server log file
[string]$path) #File path to filter

."${PSScriptRoot}/init_script.ps1"

if (!$path)
{if ($IsLinux)
  {$destpath="/etc/nginx/logs/main/access.log"}
elseif ($IsWindows)
  {$destpath="C:/nginx/logs/main/access.log"}
else
  {"Cannot detect default path."
  exit}
}

$filters=@(".*127\.0\.0\.[0-9]+.*",".*192\.168\.[0-9]+\.[0-9]+.*")

if (Test-Path $path)
{$num=0
Copy-Item $path "${tempdir}/filtered_log_${num}" -Force
foreach ($filter in $filters)
  {$nextnum=$num+1
  Select-String $filter "${tempdir}/filtered_log_${num}" -Encoding utf8 -NotMatch | ForEach-Object {$_.Line} > "${tempdir}/filtered_log_${nextnum}"
  Remove-Item "${tempdir}/filtered_log_${num}" -Force
  $num++}
Move-Item "${tempdir}/filtered_log_${num}" $destpath -Force
if ($blank_source)
  {#"" > $path should not be used because of a bug on Windows.
  Set-Content $path "" -Encoding UTF8 -Force}
}
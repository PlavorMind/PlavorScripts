#Filter web log
#Filter web server log.

param
([switch]$blank_source, #Blanks the source file after filtering if this is set
[string]$path="/etc/nginx/logs/Main/access_log.txt", #File path to filter
[string]$savepath="filtered.log") #Path to save filtered web server log file

."${PSScriptRoot}/modules/OSDetectorDebug.ps1"
."${PSScriptRoot}/modules/SetTempDir.ps1"

$filters=@(".*127\.0\.0\.[0-9]+.*",".*192\.168\.[0-9]+\.[0-9]+.*")

if (Test-Path $path)
{$num=0
Copy-Item $path "${tempdir}/filtered_log_${num}" -Force
foreach ($filter in $filters)
  {$nextnum=$num+1
  Select-String $filter "${tempdir}/filtered_log_${num}" -Encoding utf8 -NotMatch|ForEach-Object {$_.Line} > "${tempdir}/filtered_log_${nextnum}"
  Remove-Item "${tempdir}/filtered_log_${num}" -Force
  $num++}
Move-Item "${tempdir}/filtered_log_${num}" $savepath -Force
if ($blank_source)
  {#"" > $path should not be used because of a bug on Windows.
  Set-Content $path "" -Encoding UTF8 -Force}
}

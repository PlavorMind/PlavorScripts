#Filter web log
#Filter web server log.

param
([switch]$blank_source,
[string]$path="/etc/nginx/logs/Main/access_log.txt", #File path to filter
[string]$savepath="filtered_log.txt") #Path to save filtered web server log file

if (Test-Path $path)
{Copy-Item $path $savepath -Force
Select-String ".*127\.0\.0\.[0-9]+.*" $savepath -Encoding utf8 -NotMatch|ForEach-Object {$_.Line}>$savepath
Select-String ".*192\.168\.[0-9]+\.[0-9]+.*" $savepath -Encoding utf8 -NotMatch|ForEach-Object {$_.Line}>$savepath
if ($blank_source)
  {"">$path}
}

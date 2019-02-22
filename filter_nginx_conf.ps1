#Filter nginx.conf
#Filter nginx.conf file.

param
([string]$path="https://raw.githubusercontent.com/PlavorMind/Configurations/Main/nginx.conf", #File path or URL to filter
[string]$savepath="/etc/nginx/nginx.conf") #Path to save filtered nginx.conf file

$fnc_success=$false

."${PSScriptRoot}/modules/FileURLDetector.ps1" -path $path
if ($fud_output)
{if ($isLinux)
  {Select-String ".*#windows_only.*" $fud_output -Encoding utf8 -NotMatch|ForEach-Object {$_.Line}>$savepath
  $fnc_success=$true}
elseif ($isWindows)
  {Select-String ".*#linux_only.*" $fud_output -Encoding utf8 -NotMatch|ForEach-Object {$_.Line}>$savepath
  $fnc_success=$true}
else
  {"Your operating system is not supported."}
if ($fud_web)
  {Remove-Item $fud_output -Force}
}
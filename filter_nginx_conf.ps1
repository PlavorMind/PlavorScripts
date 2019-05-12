#Filter nginx.conf
#Filters nginx.conf file based on operating system.

param
([string]$path="https://raw.githubusercontent.com/PlavorMind/Configurations/Main/nginx/nginx.conf", #File path or URL to filter
[string]$savepath="__DEFAULT__") #Path to save filtered nginx.conf file

."${PSScriptRoot}/init_script.ps1"

if ($savepath -eq "__DEFAULT__")
{if ($isLinux)
  {$savepath="/etc/nginx/nginx.conf"}
elseif ($isWindows)
  {$savepath="C:/nginx/conf/nginx.conf"}
else
  {"Cannot detect default path to save."
  exit}
}

$output=FileURLDetector $path
if ($output)
{"Filtering nginx.conf file"
if ($isLinux)
  {Select-String ".*#(macos|windows)_only.*" $output -Encoding utf8 -NotMatch | ForEach-Object {$_.Line} > $savepath}
elseif ($isMacOS)
  {Select-String ".*#(linux|windows)_only.*" $output -Encoding utf8 -NotMatch | ForEach-Object {$_.Line} > $savepath}
elseif ($isWindows)
  {Select-String ".*#(linux|macos)_only.*" $output -Encoding utf8 -NotMatch | ForEach-Object {$_.Line} > $savepath}
if ($output -like "${tempdir}*")
  {"Deleting a temporary file"
  Remove-Item $output -Force}
}
else
{"Cannot download or find nginx.conf file."}

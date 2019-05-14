#Filter nginx.conf
#Filters nginx.conf file based on operating system.

param
([string]$destpath, #Destination path to save filtered nginx.conf file
[string]$path="https://raw.githubusercontent.com/PlavorMind/Configurations/Main/nginx/nginx.conf") #File path or URL to filter

."${PSScriptRoot}/init_script.ps1"

if (!$destpath)
{if ($IsLinux)
  {$destpath="/etc/nginx/nginx.conf"}
elseif ($IsWindows)
  {$destpath="C:/nginx/conf/nginx.conf"}
else
  {"Cannot detect default destination path."
  exit}
}

$output=FileURLDetector $path
if ($output)
{"Filtering nginx.conf file"
if ($IsLinux)
  {Select-String ".*#(macos|windows)_only.*" $output -Encoding utf8 -NotMatch | ForEach-Object {$_.Line} > $destpath}
elseif ($IsMacOS)
  {Select-String ".*#(linux|windows)_only.*" $output -Encoding utf8 -NotMatch | ForEach-Object {$_.Line} > $destpath}
elseif ($IsWindows)
  {Select-String ".*#(linux|macos)_only.*" $output -Encoding utf8 -NotMatch | ForEach-Object {$_.Line} > $destpath}
if ($output -like "${tempdir}*")
  {"Deleting a temporary file"
  Remove-Item $output -Force}
}
else
{"Cannot download or find nginx.conf file."}
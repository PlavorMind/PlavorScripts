#Filter php.ini
#Filters php.ini file based on operating system.

param
([string]$path="https://raw.githubusercontent.com/PlavorMind/Configurations/Main/php.ini", #File path or URL to filter
[string]$savepath="__DEFAULT__") #Path to save filtered php.ini file

."${PSScriptRoot}/init_script.ps1"

if ($savepath -eq "__DEFAULT__")
{if ($isLinux)
  {$savepath="/etc/php/7.2/fpm/php.ini"}
elseif ($isWindows)
  {$savepath="C:/PHP/php.ini"}
else
  {"Cannot detect default path to save."
  exit}
}

$output=FileURLDetector $path
if ($output)
{"Filtering php.ini file"
if ($isLinux)
  {Select-String ".*;(macos|windows)_only.*" $output -Encoding utf8 -NotMatch | ForEach-Object {$_.Line} > $savepath}
elseif ($isMacOS)
  {Select-String ".*;(linux|windows)_only.*" $output -Encoding utf8 -NotMatch | ForEach-Object {$_.Line} > $savepath}
elseif ($isWindows)
  {Select-String ".*;(linux|macos)_only.*" $output -Encoding utf8 -NotMatch | ForEach-Object {$_.Line} > $savepath}
if ($output -like "${tempdir}*")
  {"Deleting a temporary file"
  Remove-Item $output -Force}
}
else
{"Cannot download or find php.ini file."}

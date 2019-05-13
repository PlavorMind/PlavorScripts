#Filter php.ini
#Filters php.ini file based on operating system.

param
([string]$destpath, #Destination path to save filtered php.ini file
[string]$path="https://raw.githubusercontent.com/PlavorMind/Configurations/Main/php.ini") #File path or URL to filter

."${PSScriptRoot}/init_script.ps1"

if (!$destpath)
{if ($isLinux)
  {$destpath="/etc/php/7.2/fpm/php.ini"}
elseif ($isWindows)
  {$destpath="C:/PHP/php.ini"}
else
  {"Cannot detect default path to save."
  exit}
}

$output=FileURLDetector $path
if ($output)
{"Filtering php.ini file"
if ($isLinux)
  {Select-String ".*;(macos|windows)_only.*" $output -Encoding utf8 -NotMatch | ForEach-Object {$_.Line} > $destpath}
elseif ($isMacOS)
  {Select-String ".*;(linux|windows)_only.*" $output -Encoding utf8 -NotMatch | ForEach-Object {$_.Line} > $destpath}
elseif ($isWindows)
  {Select-String ".*;(linux|macos)_only.*" $output -Encoding utf8 -NotMatch | ForEach-Object {$_.Line} > $destpath}
if ($output -like "${tempdir}*")
  {"Deleting a temporary file"
  Remove-Item $output -Force}
}
else
{"Cannot download or find php.ini file."}

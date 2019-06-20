#Filter php.ini
#Filters php.ini file based on operating system.

param
([string]$destpath="__DEFAULT__", #Destination path to save filtered php.ini file
[string]$path="https://raw.githubusercontent.com/PlavorMind/Configurations/Main/php.ini") #File path or URL to filter

if (Test-Path "${PSScriptRoot}/init_script.ps1")
{."${PSScriptRoot}/init_script.ps1"}
else
{"Cannot find initialize script."
exit}

if ($destpath -eq "__DEFAULT__")
{if ($IsLinux)
  {$destpath="/etc/php/7.2/fpm/php.ini"}
elseif ($IsWindows)
  {$destpath="C:/plavormind/php/php.ini"}
else
  {"Cannot detect default destination path."
  exit}
}

$output=FileURLDetector $path
if ($output)
{"Filtering php.ini file"
if ($IsLinux)
  {Get-Content $output -Encoding utf8 -Force | Select-String ".*;(macos|windows)_only.*" -Encoding utf8 -NotMatch > $destpath}
elseif ($IsMacOS)
  {Get-Content $output -Encoding utf8 -Force | Select-String ".*;(linux|windows)_only.*" -Encoding utf8 -NotMatch > $destpath}
elseif ($IsWindows)
  {Get-Content $output -Encoding utf8 -Force | Select-String ".*;(linux|macos)_only.*" -Encoding utf8 -NotMatch > $destpath}

if ($output -like "${tempdir}*")
  {"Deleting a temporary file"
  Remove-Item $output -Force}
}
else
{"Cannot download or find php.ini file."}

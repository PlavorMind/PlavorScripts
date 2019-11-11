#Filters php.ini file based on operating system.

Param
([Parameter(Position=1)][string]$destpath, #Destination path to save filtered php.ini file
[Parameter(Position=0)][string]$path="https://raw.githubusercontent.com/PlavorMind/Configurations/Main/php.ini") #File path or URL to filter

if (Test-Path "${PSScriptRoot}/init_script.ps1")
{."${PSScriptRoot}/init_script.ps1"}
else
{"Cannot find initialize script."
exit}

if (!$destpath)
{if ($IsLinux)
  {$destpath="/etc/php/7.2/fpm/php.ini"}
elseif ($IsWindows)
  {$destpath="C:/plavormind/php-nts/php.ini"}
else
  {"Cannot detect default destination path."
  exit}
}

$output=Get-FilePathFromUri $path
if ($output)
{"Filtering php.ini file"
if ($IsLinux)
  {Select-String ".*;(macos|windows)_only.*" $output -NotMatch | Select-Object -ExpandProperty Line > $destpath}
elseif ($IsMacOS)
  {Select-String ".*;(linux|windows)_only.*" $output -NotMatch | Select-Object -ExpandProperty Line > $destpath}
elseif ($IsWindows)
  {Select-String ".*;(linux|macos)_only.*" $output -NotMatch | Select-Object -ExpandProperty Line > $destpath}

if ($output -like "${tempdir}*")
  {"Deleting a temporary file"
  Remove-Item $output -Force}
}
else
{"Cannot download or find php.ini file."}

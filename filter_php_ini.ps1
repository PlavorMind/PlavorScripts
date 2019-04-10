#Filter php.ini
#Filter php.ini file.

param
([string]$path="https://raw.githubusercontent.com/PlavorMind/Configurations/Main/php.ini", #File path or URL to filter
[string]$savepath="/etc/php/7.2/fpm/php.ini") #Path to save filtered php.ini file

$fpi_success=$false

."${PSScriptRoot}/modules/FileURLDetector.ps1" -path $path
if ($fud_output)
{if ($isLinux)
  {Select-String ".*;windows_only.*" $fud_output -Encoding utf8 -NotMatch | ForEach-Object {$_.Line} > $savepath
  $fpi_success=$true}
elseif ($isWindows)
  {Select-String ".*;linux_only.*" $fud_output -Encoding utf8 -NotMatch | ForEach-Object {$_.Line} > $savepath
  $fpi_success=$true}
else
  {"Your operating system is not supported."}
if ($fud_web)
  {Remove-Item $fud_output -Force}
}

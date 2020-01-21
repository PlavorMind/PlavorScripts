#Filters php.ini file based on operating system.

Param
([Parameter(Position=1)][string]$destpath, #Destination path to save filtered php.ini file
[Parameter(Position=0)][string]$path="https://raw.githubusercontent.com/PlavorMind/Configurations/Main/php.ini") #File path or URL to filter

if (Test-Path "${PSScriptRoot}/init-script.ps1")
{."${PSScriptRoot}/init-script.ps1"}
else
{Write-Error "Cannot find initialize script." -Category ObjectNotFound
exit}

if (!$destpath)
{if ($IsLinux)
  {$destpath="/etc/php/7.4/fpm/php.ini"}
elseif ($IsWindows)
  {$destpath="C:/plavormind/php-ts/php.ini"}
else
  {Write-Error "Cannot detect default destination path." -Category NotSpecified
  exit}
}

$output=Get-FilePathFromUri $path
if ($output)
{Write-Verbose "Filtering php.ini file"
if ($IsLinux)
  {Select-String ".*;(macos|windows)_only.*" $output -NotMatch -Raw > $destpath}
elseif ($IsMacOS)
  {Select-String ".*;(linux|windows)_only.*" $output -NotMatch -Raw > $destpath}
elseif ($IsWindows)
  {Select-String ".*;(linux|macos)_only.*" $output -NotMatch -Raw > $destpath}

if ($output -like "${tempdir}*")
  {Write-Verbose "Deleting a file that is no longer needed"
  Remove-Item $output -Force}
}
else
{Write-Error "Cannot download or find php.ini file." -Category ObjectNotFound}

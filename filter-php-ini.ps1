#Filters php.ini file based on operating system.

Param
([Parameter(Position=1)][string]$destpath, #Destination path to save filtered php.ini file
[Parameter(Position=0)][string]$path="https://raw.githubusercontent.com/PlavorMind/Configurations/master/php.ini") #File path or URL to filter

if (Test-Path "${PSScriptRoot}/init-script.ps1")
{if (!(."${PSScriptRoot}/init-script.ps1"))
  {exit}
}
else
{Write-Error "Cannot find init-script.ps1 file." -Category ObjectNotFound
exit}

if (!$destpath)
{if ($IsLinux)
  {$destpath="/etc/php/7.4/fpm/php.ini"}
elseif ($IsWindows)
  {$destpath="${PlaScrDefaultBaseDirectory}/php-ts/php.ini"}
else
  {Write-Error "Cannot detect default destination path." -Category NotSpecified
  exit}
}

$output=Get-FilePathFromURL $path
if ($output)
{Write-Verbose "Filtering php.ini file"
if ($IsLinux)
  {Select-String ";(macos|windows)_only" $output -NotMatch -Raw > $destpath}
elseif ($IsMacOS)
  {Select-String ";(linux|windows)_only" $output -NotMatch -Raw > $destpath}
elseif ($IsWindows)
  {Select-String ";(linux|macos)_only" $output -NotMatch -Raw > $destpath}

if ($output -like "${PlaScrTempDirectory}*")
  {Write-Verbose "Deleting a temporary file"
  Remove-Item $output -Force}
}
else
{Write-Error "Cannot download or find php.ini file." -Category ObjectNotFound}

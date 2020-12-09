#Installs Composer.

Param
([Parameter(Position=0)][string]$dir, #Directory to install Composer
[string]$php_path) #Path of PHP

if (Test-Path "${PSScriptRoot}/../init-script.ps1")
{if (!(."${PSScriptRoot}/../init-script.ps1"))
  {exit}
}
else
{Write-Error "Cannot find init-script.ps1 file." -Category ObjectNotFound
exit}

if (!$dir)
{$dir="${PlaScrDefaultBaseDirectory}/composer"}
if (!$php_path)
{$php_path=$PlaScrDefaultPHPPath}

if (!(Test-Path $php_path))
{Write-Error "Cannot find PHP." -Category NotInstalled
exit}

Write-Verbose "Downloading Composer"
Invoke-WebRequest "https://getcomposer.org/composer-1.phar" -DisableKeepAlive -OutFile "${PlaScrTempDirectory}/composer.phar"
if (Test-Path "${PlaScrTempDirectory}/composer.phar")
{Write-Verbose "Creating a directory for Composer"
New-Item "${PlaScrTempDirectory}/composer" -Force -ItemType Directory
Write-Verbose "Moving Composer"
Move-Item "${PlaScrTempDirectory}/composer.phar" "${PlaScrTempDirectory}/composer/composer.phar" -Force}
else
{Write-Error "Cannot download Composer." -Category ConnectionError
exit}

if (!(Test-Path "${PlaScrDefaultBaseDirectory}/path"))
{Write-Verbose "Creating a directory for PATH"
New-Item "${PlaScrDefaultBaseDirectory}/path" -Force -ItemType Directory}
Write-Verbose "Creating a script for PATH"
if ($IsWindows)
{"@echo off" > "${PlaScrDefaultBaseDirectory}/path/composer.cmd"
"`"${php_path}`" `"${dir}/composer.phar`" %*" >> "${PlaScrDefaultBaseDirectory}/path/composer.cmd"}
else
{"#!/bin/bash" > "${PlaScrDefaultBaseDirectory}/path/composer"
"`"${php_path}`" `"${dir}/composer.phar`" `$*" >> "${PlaScrDefaultBaseDirectory}/path/composer"
chmod +x "${PlaScrDefaultBaseDirectory}/path/composer"}

if (Test-Path $dir)
{Write-Warning "Deleting existing Composer directory"
Remove-Item $dir -Force -Recurse}
Write-Verbose "Moving Composer directory to destination directory"
Move-Item "${PlaScrTempDirectory}/composer" $dir -Force

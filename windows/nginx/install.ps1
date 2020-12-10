#Installs nginx.

Param
([Parameter(Position=0)][string]$dir, #Directory to install nginx
[switch]$portable, #Install in portable mode
[string]$version="1.19.5", #nginx version
[string]$web_dir) #Web public directory

if (Test-Path "${PSScriptRoot}/../../init-script.ps1")
{if (!(."${PSScriptRoot}/../../init-script.ps1"))
  {exit}
}
else
{Write-Error "Cannot find init-script.ps1 file." -Category ObjectNotFound
exit}

if (!$IsWindows)
{Write-Error "Your operating system is not supported."
exit}

if (!$dir)
{$dir="${PlaScrDefaultBaseDirectory}/nginx"}
if (!$web_dir)
{$web_dir="${PlaScrDefaultBaseDirectory}/web/public"}

if (!($portable -or (Test-AdminPermission)))
{Write-Error "This script must be run as administrator unless you install in portable mode." -Category PermissionDenied
exit}

Write-Verbose "Downloading configurations"
Get-ItemFromArchive "nginx" "${PlaScrTempDirectory}/nginx-config"
if (!(Test-Path "${PlaScrTempDirectory}/nginx-config"))
{Write-Error "Cannot download configurations." -Category ConnectionError
exit}

Expand-ArchiveSmart "http://nginx.org/download/nginx-${version}.zip" "${PlaScrTempDirectory}/nginx"
if (!(Test-Path "${PlaScrTempDirectory}/nginx"))
{Write-Error "Cannot download nginx." -Category ConnectionError
exit}

Write-Verbose "Applying configurations"
Move-Item "${PlaScrTempDirectory}/nginx-config/*" "${PlaScrTempDirectory}/nginx/conf/" -Force
Remove-Item "${PlaScrTempDirectory}/nginx-config" -Force -Recurse
Move-Item "${PlaScrTempDirectory}/nginx/conf/os-specific/windows/*" "${PlaScrTempDirectory}/nginx/conf/os-specific/" -Force
foreach ($os_specific_directory in Get-ChildItem "${PlaScrTempDirectory}/nginx/conf/os-specific" -Directory -Force -Name)
{Remove-Item "${PlaScrTempDirectory}/nginx/conf/os-specific/${os_specific_directory}" -Force -Recurse}

if (Test-Path $web_dir)
{Write-Verbose "Creating directories for logs"
foreach ($server_block in Get-ChildItem $web_dir -Directory -Force -Name)
  {New-Item "${PlaScrTempDirectory}/nginx/logs/${server_block}" -Force -ItemType Directory}
}
else
{Write-Warning "Skipped creating directories for logs: Cannot find web public directory."}

Write-Verbose "Copying install data"
Copy-Item "${PSScriptRoot}/install-data/start.ps1" "${PlaScrTempDirectory}/nginx/" -Force
Copy-Item "${PSScriptRoot}/install-data/stop.ps1" "${PlaScrTempDirectory}/nginx/" -Force

if (Test-Path "${PSScriptRoot}/additional-files")
{Write-Verbose "Copying additional files"
Copy-Item "${PSScriptRoot}/additional-files/*" "${PlaScrTempDirectory}/nginx/" -Force -Recurse}
else
{Write-Warning "Skipped copying additional files: Cannot find additional-files directory."}

Write-Verbose "Deleting directories that are unnecessary for running"
Remove-Item "${PlaScrTempDirectory}/nginx/contrib" -Force -Recurse
Remove-Item "${PlaScrTempDirectory}/nginx/docs" -Force -Recurse
Remove-Item "${PlaScrTempDirectory}/nginx/html" -Force -Recurse

if (Get-Process "nginx" -ErrorAction Ignore)
{Write-Verbose "Stopping nginx"
Stop-Process -Force -Name "nginx"}

if (Test-Path $dir)
{Write-Warning "Renaming existing nginx directory"
Move-Item $dir "${dir}-old" -Force}
Write-Verbose "Moving nginx directory to destination directory"
Move-Item "${PlaScrTempDirectory}/nginx" $dir -Force

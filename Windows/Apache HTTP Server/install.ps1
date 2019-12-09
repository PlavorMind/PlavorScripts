#Installs Apache HTTP Server.

Param
([string]$apache_httpd_archive="https://www.apachehaus.com/downloads/httpd-2.4.41-o111c-x64-vc15-r2.zip", #URL or file path to Apache HTTP Server archive
[Parameter(Position=0)][string]$dir="C:/plavormind/apache-httpd", #Directory to install Apache HTTP Server
[string]$php_dir="C:/plavormind/php-ts", #PHP directory
[string]$web_dir="C:/plavormind/web/public") #Web server public directory

if (Test-Path "${PSScriptRoot}/../../init-script.ps1")
{."${PSScriptRoot}/../../init-script.ps1"}
else
{Write-Error "Cannot find initialize script." -Category ObjectNotFound
exit}

if (!$IsWindows)
{Write-Error "Your operating system is not supported."
exit}
#End of preconditions

Write-Verbose "Downloading configurations"
Invoke-WebRequest "https://github.com/PlavorMind/Configurations/archive/Main.zip" -DisableKeepAlive -OutFile "${tempdir}/config.zip"
if ("${tempdir}/config.zip")
{Write-Verbose "Extracting"
Expand-Archive "${tempdir}/config.zip" $tempdir -Force
Write-Verbose "Deleting a file and directory that are no longer needed"
Remove-Item "${tempdir}/config.zip" -Force
Move-Item "${tempdir}/Configurations-Main/apache-httpd" "${tempdir}/apache-httpd-config" -Force
Remove-Item "${tempdir}/Configurations-Main" -Force -Recurse}
else
{"Cannot download configurations."
exit}

$output=Get-FilePathFromUri $apache_httpd_archive
if ($output)
{Write-Verbose "Extracting Apache HTTP Server"
Expand-Archive $output $tempdir
Write-Verbose "Deleting files that are no longer needed"
if ($output -like "${tempdir}*")
  {Remove-Item $output -Force}
Remove-Item "${tempdir}/readme_first.html" -Force}
else
{Write-Error "Cannot download or find Apache HTTP Server."
exit}

Write-Verbose "Applying configurations"
Move-Item "${tempdir}/apache-httpd-config/*" "${tempdir}/Apache24/conf/" -Force
Remove-Item "${tempdir}/apache-httpd-config" -Force -Recurse
Move-Item "${tempdir}/Apache24/conf/os-specific/windows/*" "${tempdir}/Apache24/conf/os-specific/" -Force
foreach ($os_specific_directory in Get-ChildItem "${tempdir}/Apache24/conf/os-specific" -Directory -Force -Name)
{Remove-Item "${tempdir}/Apache24/conf/os-specific/${os_specific_directory}" -Force -Recurse}
"Define server_os `"Windows`"" > "${tempdir}/Apache24/conf/os-specific/os.conf"

if (Test-Path $php_dir)
{Write-Verbose "Copying DLL files from PHP directory"
Write-Verbose "Some DLL files must be copied from PHP directory to Apache HTTP Server's bin directory to load some PHP extensions."
Copy-Item "${php_dir}/icudt65.dll" "${tempdir}/Apache24/bin/" -Force
Copy-Item "${php_dir}/icuin65.dll" "${tempdir}/Apache24/bin/" -Force
Copy-Item "${php_dir}/icuio65.dll" "${tempdir}/Apache24/bin/" -Force
Copy-Item "${php_dir}/icuuc65.dll" "${tempdir}/Apache24/bin/" -Force
Copy-Item "${php_dir}/libssh2.dll" "${tempdir}/Apache24/bin/" -Force
Copy-Item "${php_dir}/libsqlite3.dll" "${tempdir}/Apache24/bin/" -Force}
else
{Write-Warning "Skipped copying DLL files from PHP directory: Cannot find PHP directory."}

if (Test-Path $web_dir)
{Write-Verbose "Creating directories for logs"
foreach ($virtual_host in Get-ChildItem $web_dir -Directory -Force -Name)
  {New-Item "${tempdir}/Apache24/logs/${virtual_host}" -Force -ItemType Directory}
}
else
{Write-Warning "Skipped creating directories for logs: Cannot find web server public directory."}

if (Test-Path "${PSScriptRoot}/additional-files")
{Write-Verbose "Copying additional files"
Copy-Item "${PSScriptRoot}/additional-files/*" "${tempdir}/Apache24/" -Force -Recurse}
else
{Write-Warning "Skipped copying additional files: Cannot find additional-files directory."}

Write-Verbose "Deleting files that are unnecessary for running"
Remove-Item "${tempdir}/Apache24/ABOUT_APACHE.txt" -Force
Remove-Item "${tempdir}/Apache24/CHANGES.txt" -Force
Remove-Item "${tempdir}/Apache24/INSTALL.txt" -Force
Remove-Item "${tempdir}/Apache24/LICENSE.txt" -Force
Remove-Item "${tempdir}/Apache24/NOTICE.txt" -Force
Remove-Item "${tempdir}/Apache24/OPENSSL-NEWS.txt" -Force
Remove-Item "${tempdir}/Apache24/OPENSSL-README.txt" -Force
Remove-Item "${tempdir}/Apache24/README.txt" -Force
Remove-Item "${tempdir}/Apache24/logs/install.log" -Force

if (Test-Path $dir)
{Write-Warning "Renaming existing Apache HTTP Server directory"
Move-Item $dir "${dir}-old" -Force}
Write-Verbose "Moving Apache HTTP Server directory from temporary directory to destination directory"
Move-Item "${tempdir}/Apache24" $dir -Force

if (Test-AdminPermission)
{Write-Verbose "Installing service"
."${dir}/bin/httpd.exe" -k install}
else
{Write-Warning "Skipped installing service: This script must be run as administrator to install service."}

#Installs Apache HTTP Server.

Param
([Parameter(Position=0)][string]$dir="C:/plavormind/apache-httpd", #Directory to install Apache HTTP Server
[string]$php_dir="C:/plavormind/php-ts", #PHP directory
[string]$version="2.4.41", #Apache HTTP Server version
[string]$web_dir="C:/plavormind/web/public") #Web server public directory

if (Test-Path "${PSScriptRoot}/../../init-script.ps1")
{."${PSScriptRoot}/../../init-script.ps1"}
else
{Write-Error "Cannot find initialize script." -Category ObjectNotFound
exit}

if (!$IsWindows)
{Write-Error "Your operating system is not supported."
exit}

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
{Write-Error "Cannot download configurations." -Category ConnectionError
exit}

Write-Verbose "Creating a temporary directory for extracting"
New-Item "${tempdir}/apache-httpd-extracts" -Force -ItemType Directory

Write-Verbose "Downloading Apache HTTP Server"
#Apache Lounge blocks requests with a user agent string contains name of command line tools such as "curl", "powershell" and "wget". Change user agent if "PlavorScripts" is also blocked.
Invoke-WebRequest "https://www.apachelounge.com/download/VS16/binaries/httpd-${version}-win64-VS16.zip" -DisableKeepAlive -OutFile "${tempdir}/apache-httpd.zip" -UserAgent "PlavorScripts"
if (Test-Path "${tempdir}/apache-httpd.zip")
{Write-Verbose "Extracting"
Expand-Archive "${tempdir}/apache-httpd.zip" "${tempdir}/apache-httpd-extracts/" -Force
Write-Verbose "Deleting a file that is no longer needed"
Remove-Item "${tempdir}/apache-httpd.zip" -Force
Move-Item "${tempdir}/apache-httpd-extracts/Apache*" "${tempdir}/apache-httpd" -Force}
else
{Write-Error "Cannot download Apache HTTP Server." -Category ConnectionError
exit}

Write-Verbose "Deleting a directory that is no longer needed"
Remove-Item "${tempdir}/apache-httpd-extracts" -Force -Recurse

Write-Verbose "Applying configurations"
Move-Item "${tempdir}/apache-httpd-config/*" "${tempdir}/apache-httpd/conf/" -Force
Remove-Item "${tempdir}/apache-httpd-config" -Force -Recurse
Move-Item "${tempdir}/apache-httpd/conf/os-specific/windows/*" "${tempdir}/apache-httpd/conf/os-specific/" -Force
foreach ($os_specific_directory in Get-ChildItem "${tempdir}/apache-httpd/conf/os-specific" -Directory -Force -Name)
{Remove-Item "${tempdir}/apache-httpd/conf/os-specific/${os_specific_directory}" -Force -Recurse}
"Define server_os `"Windows`"" > "${tempdir}/apache-httpd/conf/os-specific/os.conf"

if (Test-Path $php_dir)
{."${PSScriptRoot}/copy-php-dll.ps1" $php_dir "${tempdir}/apache-httpd"}
else
{Write-Warning "Skipped copying DLL files from PHP directory: Cannot find PHP directory."}

if (Test-Path $web_dir)
{Write-Verbose "Creating directories for logs"
foreach ($virtual_host in Get-ChildItem $web_dir -Directory -Force -Name)
  {New-Item "${tempdir}/apache-httpd/logs/${virtual_host}" -Force -ItemType Directory}
}
else
{Write-Warning "Skipped creating directories for logs: Cannot find web server public directory."}

if (Test-Path "${PSScriptRoot}/additional-files")
{Write-Verbose "Copying additional files"
Copy-Item "${PSScriptRoot}/additional-files/*" "${tempdir}/apache-httpd/" -Force -Recurse}
else
{Write-Warning "Skipped copying additional files: Cannot find additional-files directory."}

Write-Verbose "Deleting files that are unnecessary for running"
Remove-Item "${tempdir}/apache-httpd/ABOUT_APACHE.txt" -Force
Remove-Item "${tempdir}/apache-httpd/CHANGES.txt" -Force
Remove-Item "${tempdir}/apache-httpd/INSTALL.txt" -Force
Remove-Item "${tempdir}/apache-httpd/LICENSE.txt" -Force
Remove-Item "${tempdir}/apache-httpd/NOTICE.txt" -Force
Remove-Item "${tempdir}/apache-httpd/OPENSSL-NEWS.txt" -Force
Remove-Item "${tempdir}/apache-httpd/OPENSSL-README.txt" -Force
Remove-Item "${tempdir}/apache-httpd/README.txt" -Force
Remove-Item "${tempdir}/apache-httpd/logs/install.log" -Force

if (Test-Path $dir)
{Write-Warning "Backing up existing Apache HTTP Server directory"
Copy-Item $dir "${dir}-old" -Force -Recurse
Write-Warning "Uninstalling existing Apache HTTP Server"
."${PSScriptRoot}/uninstall.ps1" $dir}
Write-Verbose "Moving Apache HTTP Server directory from temporary directory to destination directory"
Move-Item "${tempdir}/apache-httpd" $dir -Force

if (Test-AdminPermission)
{Write-Verbose "Installing service"
."${dir}/bin/httpd.exe" -k install}
else
{Write-Warning "Skipped installing service: This script must be run as administrator to install service."}

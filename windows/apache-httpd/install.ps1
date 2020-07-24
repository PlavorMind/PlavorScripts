#Installs Apache HTTP Server.

Param
([Parameter(Position=0)][string]$dir, #Directory to install Apache HTTP Server
[string]$php_dir, #PHP directory
[switch]$portable, #Install in portable mode
[string]$version="2.4.43", #Apache HTTP Server version
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
{$dir="${PlaScrDefaultBaseDirectory}/apache-httpd"}
if (!$php_dir)
{$php_dir="${PlaScrDefaultBaseDirectory}/php"}
if (!$web_dir)
{$web_dir="${PlaScrDefaultBaseDirectory}/web/public"}

if (!($portable -or (Test-AdminPermission)))
{Write-Error "This script must be run as administrator unless you install in portable mode." -Category PermissionDenied
exit}

Write-Verbose "Downloading configurations"
Get-ItemFromArchive "apache-httpd" "${PlaScrTempDirectory}/apache-httpd-config"
if (!(Test-Path "${PlaScrTempDirectory}/apache-httpd-config"))
{Write-Error "Cannot download configurations." -Category ConnectionError
exit}

Write-Verbose "Creating a temporary directory for extracting"
New-Item "${PlaScrTempDirectory}/apache-httpd-extracts" -Force -ItemType Directory

Write-Verbose "Downloading Apache HTTP Server"
#Apache Lounge blocks requests with a user agent string contains name of command line tools such as "curl", "powershell" and "wget".
Invoke-WebRequest "https://www.apachelounge.com/download/VS16/binaries/httpd-${version}-win64-VS16.zip" -DisableKeepAlive -OutFile "${PlaScrTempDirectory}/apache-httpd.zip" -UserAgent "PlavorScripts"
if (Test-Path "${PlaScrTempDirectory}/apache-httpd.zip")
{Write-Verbose "Extracting"
Expand-Archive "${PlaScrTempDirectory}/apache-httpd.zip" "${PlaScrTempDirectory}/apache-httpd-extracts/" -Force
Write-Verbose "Deleting a temporary file"
Remove-Item "${PlaScrTempDirectory}/apache-httpd.zip" -Force
Move-Item "${PlaScrTempDirectory}/apache-httpd-extracts/Apache*" "${PlaScrTempDirectory}/apache-httpd" -Force}
else
{Write-Error "Cannot download Apache HTTP Server." -Category ConnectionError
exit}

Write-Verbose "Deleting a temporary directory"
Remove-Item "${PlaScrTempDirectory}/apache-httpd-extracts" -Force -Recurse

Write-Verbose "Applying configurations"
Move-Item "${PlaScrTempDirectory}/apache-httpd-config/*" "${PlaScrTempDirectory}/apache-httpd/conf/" -Force
Remove-Item "${PlaScrTempDirectory}/apache-httpd-config" -Force -Recurse
Move-Item "${PlaScrTempDirectory}/apache-httpd/conf/os-specific/windows/*" "${PlaScrTempDirectory}/apache-httpd/conf/os-specific/" -Force
foreach ($os_specific_directory in Get-ChildItem "${PlaScrTempDirectory}/apache-httpd/conf/os-specific" -Directory -Force -Name)
{Remove-Item "${PlaScrTempDirectory}/apache-httpd/conf/os-specific/${os_specific_directory}" -Force -Recurse}
"Define server_os `"Windows`"" > "${PlaScrTempDirectory}/apache-httpd/conf/os-specific/os.conf"

if (Test-Path $php_dir)
{."${PSScriptRoot}/copy-php-dll.ps1" $php_dir "${PlaScrTempDirectory}/apache-httpd"}
else
{Write-Warning "Skipped copying DLL files from PHP directory: Cannot find PHP directory."}

if (Test-Path $web_dir)
{Write-Verbose "Creating directories for logs"
foreach ($virtual_host in Get-ChildItem $web_dir -Directory -Force -Name)
  {New-Item "${PlaScrTempDirectory}/apache-httpd/logs/${virtual_host}" -Force -ItemType Directory}
}
else
{Write-Warning "Skipped creating directories for logs: Cannot find web public directory."}

if (Test-Path "${PSScriptRoot}/additional-files")
{Write-Verbose "Copying additional files"
Copy-Item "${PSScriptRoot}/additional-files/*" "${PlaScrTempDirectory}/apache-httpd/" -Force -Recurse}
else
{Write-Warning "Skipped copying additional files: Cannot find additional-files directory."}

Write-Verbose "Deleting files that are unnecessary for running"
Remove-Item "${PlaScrTempDirectory}/apache-httpd/ABOUT_APACHE.txt" -Force
Remove-Item "${PlaScrTempDirectory}/apache-httpd/CHANGES.txt" -Force
Remove-Item "${PlaScrTempDirectory}/apache-httpd/INSTALL.txt" -Force
Remove-Item "${PlaScrTempDirectory}/apache-httpd/LICENSE.txt" -Force
Remove-Item "${PlaScrTempDirectory}/apache-httpd/NOTICE.txt" -Force
Remove-Item "${PlaScrTempDirectory}/apache-httpd/OPENSSL-NEWS.txt" -Force
Remove-Item "${PlaScrTempDirectory}/apache-httpd/OPENSSL-README.txt" -Force
Remove-Item "${PlaScrTempDirectory}/apache-httpd/README.txt" -Force
Remove-Item "${PlaScrTempDirectory}/apache-httpd/logs/install.log" -Force

if (Test-Path $dir)
{Write-Warning "Backing up existing Apache HTTP Server directory"
Copy-Item $dir "${dir}-old" -Force -Recurse
Write-Warning "Uninstalling existing Apache HTTP Server"
."${PSScriptRoot}/uninstall.ps1" $dir}
Write-Verbose "Moving Apache HTTP Server directory to destination directory"
Move-Item "${PlaScrTempDirectory}/apache-httpd" $dir -Force

if (!$portable)
{Write-Verbose "Installing service"
."${dir}/bin/httpd.exe" -k install

."${PSScriptRoot}/firewall-rule.ps1" -dir $dir}

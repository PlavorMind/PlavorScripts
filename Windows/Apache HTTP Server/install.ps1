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

Invoke-WebRequest "https://github.com/PlavorMind/Configurations/archive/Main.zip" -DisableKeepAlive -OutFile "${tempdir}/config.zip"
if ("${tempdir}/config.zip")
{Expand-Archive "${tempdir}/config.zip" $tempdir -Force
Remove-Item "${tempdir}/config.zip" -Force
Move-Item "${tempdir}/Configurations-Main/apache-httpd" "${tempdir}/apache-httpd-config" -Force
Remove-Item "${tempdir}/Configurations-Main" -Force -Recurse}
else
{"Cannot download configurations."
exit}

Invoke-WebRequest "https://www.apachehaus.com/downloads/httpd-${version}-o111c-x64-vc15-r2.zip" -DisableKeepAlive -OutFile "${tempdir}/apache-httpd.zip"
if (Test-Path "${tempdir}/apache-httpd.zip")
{Expand-Archive "${tempdir}/apache-httpd.zip" $tempdir -Force
Remove-Item "${tempdir}/apache-httpd.zip" -Force
Remove-Item "${tempdir}/readme_first.html" -Force}
else
{"Cannot download Apache HTTP Server."
exit}

Move-Item "${tempdir}/apache-httpd-config/*" "${tempdir}/Apache24/conf/" -Force
Remove-Item "${tempdir}/apache-httpd-config" -Force -Recurse
Move-Item "${tempdir}/Apache24/conf/os-specific/windows/*" "${tempdir}/Apache24/conf/os-specific/" -Force
foreach ($os_specific_directory in Get-ChildItem "${tempdir}/Apache24/conf/os-specific" -Directory -Force -Name)
{Remove-Item "${tempdir}/Apache24/conf/os-specific/${os_specific_directory}" -Force -Recurse}
"Define server_os `"Windows`"" > "${tempdir}/Apache24/conf/os-specific/os.conf"

if (Test-Path $php_dir)
{Copy-Item "${php_dir}/icudt65.dll" "${tempdir}/Apache24/bin/" -Force
Copy-Item "${php_dir}/icuin65.dll" "${tempdir}/Apache24/bin/" -Force
Copy-Item "${php_dir}/icuio65.dll" "${tempdir}/Apache24/bin/" -Force
Copy-Item "${php_dir}/icuuc65.dll" "${tempdir}/Apache24/bin/" -Force
Copy-Item "${php_dir}/libssh2.dll" "${tempdir}/Apache24/bin/" -Force
Copy-Item "${php_dir}/libsqlite3.dll" "${tempdir}/Apache24/bin/" -Force}

if (Test-Path $web_dir)
{foreach ($virtual_host in Get-ChildItem $web_dir -Directory -Force -Name)
  {New-Item "${tempdir}/Apache24/logs/${virtual_host}" -Force -ItemType Directory}
}

if (Test-Path "${PSScriptRoot}/additional-files")
{Copy-Item "${PSScriptRoot}/additional-files/*" "${tempdir}/Apache24/" -Force -Recurse}

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
{Move-Item $dir "${dir}-old" -Force}
Move-Item "${tempdir}/Apache24" $dir -Force

if (Test-AdminPermission)
{."${dir}/bin/httpd.exe" -k install}
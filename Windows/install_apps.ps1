#Install apps
#Installs some apps.

param
([string]$7zip_version="1900", #7-Zip version to install (must set without dot(.))
[string]$python_version="3.7.2", #Python version to install
[string]$turtl_version="0.7.2.5") #Turtl version to install

."${PSScriptRoot}/../modules/OSDetectorDebug.ps1"
."${PSScriptRoot}/../modules/SetTempDir.ps1"

if (!($isWindows))
{"Your operating system is not supported."
exit}

"Downloading Microsoft Visual C++ Redistributable for Visual Studio 2019 RC"
Invoke-WebRequest "https://aka.ms/vs/16/release/VC_redist.x64.exe" -DisableKeepAlive -OutFile "${tempdir}/visualc.exe"
if (Test-Path "${tempdir}/visualc.exe")
{"Installing"
Start-Process "${tempdir}/visualc.exe" -ArgumentList "/norestart /passive" -Wait
"Deleting a temporary file"
Remove-Item "${tempdir}/visualc.exe" -Force}
else
{"Cannot download Microsoft Visual C++ Redistributable for Visual Studio 2019 RC."}

"Downloading 7-Zip"
Invoke-WebRequest "https://www.7-zip.org/a/7z${7zip_version}-x64.exe" -DisableKeepAlive -OutFile "${tempdir}/7-Zip.exe"
if (Test-Path "${tempdir}/7-Zip.exe")
{"Installing"
Start-Process "${tempdir}/7-Zip.exe" -ArgumentList "/S" -Wait
"Deleting a temporary file"
Remove-Item "${tempdir}/7-Zip.exe" -Force}
else
{"Cannot download 7-Zip."}

"Downloading Discord Canary"
Invoke-WebRequest "https://discordapp.com/api/download/canary?platform=win" -DisableKeepAlive -OutFile "${tempdir}/Discord Canary.exe"
if (Test-Path "${tempdir}/Discord Canary.exe")
{"Installing"
Start-Process "${tempdir}/Discord Canary.exe" -Wait
while (!(Test-Path "${env:LOCALAPPDATA}/DiscordCanary/app-*/DiscordCanary.exe"))
{}
"DiscordCanary.exe found!" #Added for test
Start-Sleep 10
"Deleting a temporary file"
Remove-Item "${tempdir}/Discord Canary.exe" -Force}
else
{"Cannot download Discord Canary."}

"Downloading Python"
Invoke-WebRequest "https://www.python.org/ftp/python/${python_version}/python-${python_version}-amd64.exe" -DisableKeepAlive -OutFile "${tempdir}/Python.exe"
if (Test-Path "${tempdir}/Python.exe")
{"Installing"
Start-Process "${tempdir}/Python.exe" -ArgumentList "InstallAllUsers=1 PrependPath=1 /passive" -Wait
"Deleting a temporary file"
Remove-Item "${tempdir}/Python.exe" -Force}
else
{"Cannot download Python."}

"Dowloading Turtl"
Invoke-WebRequest "https://github.com/turtl/desktop/releases/download/v${turtl_version}/turtl-${turtl_version}-windows64.msi" -DisableKeepAlive -OutFile "${tempdir}/Turtl.msi"
if (Test-Path "${tempdir}/Turtl.msi")
{"Installing"
msiexec "${tempdir}/Turtl.msi" /norestart /passive
"Deleting a temporary file"
Remove-Item "${tempdir}/Turtl.msi" -Force}
else
{"Cannot download Turtl."}

"Downloading Visual Studio Code"
Invoke-WebRequest "https://go.microsoft.com/fwlink/?Linkid=852155" -DisableKeepAlive -OutFile "${tempdir}/Visual Studio Code.exe"
if (Test-Path "${tempdir}/Visual Studio Code.exe")
{"Installing"
Start-Process "${tempdir}/Visual Studio Code.exe" -ArgumentList "/closeapplications /mergetasks='addcontextmenufiles,addcontextmenufolders,addtopath,associatewithfiles,desktopicon,!runcode' /nocancel /norestart /restartapplications /silent /sp- /suppressmsgboxes" -Wait
"Deleting a temporary file"
Remove-Item "${tempdir}/Visual Studio Code.exe" -Force}
else
{"Cannot download Visual Studio Code."}
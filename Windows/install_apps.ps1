#Install apps
#Installs some apps.

param
([string]$7zip_version="1900", #7-Zip version to install (must set without dot(.))
[string]$bleachbit_installer="https://ci.bleachbit.org/dl/2.3.1085/BleachBit-2.3-setup-English.exe", #URL or file path to BleachBit installer
[string]$mpchc_version="1.7.13.112", #MPC-HC nightly build version to install
[string]$obs_installer="https://github.com/obsproject/obs-studio/releases/download/23.2.0-rc1/OBS-Studio-23.2-rc1-Full-Installer-x64.exe", #URL or file path to OBS Studio installer
[string]$python_installer="https://www.python.org/ftp/python/3.8.0/python-3.8.0a3-amd64.exe", #URL or file path to Python installer
[string]$turtl_version="0.7.2.5") #Turtl version to install

."${PSScriptRoot}/../init_script.ps1"

if (!$IsWindows)
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

$output=FileURLDetector $bleachbit_installer
if ($output)
{"Installing BleachBit"
Start-Process $output -ArgumentList "/allusers /S" -Wait
if ($output -like "${tempdir}*")
  {"Deleting a temporary file"
  Remove-Item $output -Force}
}
else
{"Cannot download or find BleachBit."}

"Downloading Discord Canary"
Invoke-WebRequest "https://discordapp.com/api/download/canary?platform=win" -DisableKeepAlive -OutFile "${tempdir}/Discord Canary.exe"
if (Test-Path "${tempdir}/Discord Canary.exe")
{"Installing"
Start-Process "${tempdir}/Discord Canary.exe" -Wait
"Discord Canary.exe is terminated at first." #Added for test
Start-Sleep 5
while (Get-Process "Discord Canary" -ErrorAction Ignore)
  {}
"Deleting a temporary file"
Remove-Item "${tempdir}/Discord Canary.exe" -Force}
else
{"Cannot download Discord Canary."}

"Downloading Firefox Nightly"
Invoke-WebRequest "https://download.mozilla.org/?product=firefox-nightly-stub" -DisableKeepAlive -OutFile "${tempdir}/Firefox Nightly.exe"
if (Test-Path "${tempdir}/Firefox Nightly.exe")
{"Installing"
Start-Process "${tempdir}/Firefox Nightly.exe" -Wait
"Deleting a temporary file"
Remove-Item "${tempdir}/Firefox Nightly.exe" -Force}
else
{"Cannot download Firefox Nightly."}

"Downloading MPC-HC"
Invoke-WebRequest "https://nightly.mpc-hc.org/MPC-HC.${mpchc_version}.x64.exe" -DisableKeepAlive -OutFile "${tempdir}/MPC-HC.exe"
if (Test-Path "${tempdir}/MPC-HC.exe")
{"Installing"
Start-Process "${tempdir}/MPC-HC.exe" -ArgumentList "/closeapplications /mergetasks=`"desktopicon\common`" /nocancel /norestart /restartapplications /silent /sp- /suppressmsgboxes" -Wait #Should use double quotes(") and escape them otherwise backslashes(\) will be broken
"Deleting a temporary file"
Remove-Item "${tempdir}/MPC-HC.exe" -Force}
else
{"Cannot download MPC-HC."}

"Downloading nomacs"
Invoke-WebRequest "http://download.nomacs.org/nomacs-setup-x64.msi" -DisableKeepAlive -OutFile "${tempdir}/nomacs.msi"
if (Test-Path "${tempdir}/nomacs.msi")
{"Installing"
msiexec /i "${tempdir}/nomacs.msi" /norestart /passive
"Deleting a temporary file"
Remove-Item "${tempdir}/nomacs.msi" -Force}
else
{"Cannot download nomacs."}

$output=FileURLDetector $obs_installer
if ($output)
{"Installing OBS Studio"
Start-Process $output -ArgumentList "/S" -Wait
if ($output -like "${tempdir}*")
  {"Deleting a temporary file"
  Remove-Item $output -Force}
}
else
{"Cannot download or find OBS Studio."}

$output=FileURLDetector $python_installer
if ($output)
{"Installing Python"
Start-Process $output -ArgumentList "InstallAllUsers=1 PrependPath=1 /passive" -Wait
if ($output -like "${tempdir}*")
  {"Deleting a temporary file"
  Remove-Item $output -Force}
}
else
{"Cannot download or find Python."}

"Dowloading Turtl"
Invoke-WebRequest "https://github.com/turtl/desktop/releases/download/v${turtl_version}/turtl-${turtl_version}-windows64.msi" -DisableKeepAlive -OutFile "${tempdir}/Turtl.msi"
if (Test-Path "${tempdir}/Turtl.msi")
{"Installing"
msiexec /i "${tempdir}/Turtl.msi" /norestart /passive
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

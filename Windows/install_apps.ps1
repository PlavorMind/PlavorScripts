#Install apps
#Installs some apps.

param
([string]$7zip_version="1900", #7-Zip version to install (must set without dot(.))
[string]$bleachbit_installer="https://ci.bleachbit.org/dl/2.3.1122/BleachBit-2.3-setup-English.exe", #URL or file path to BleachBit installer
[string]$gimp_installer="https://download.gimp.org/mirror/pub/gimp/v2.10/windows/gimp-2.10.12-setup-1.exe", #URL or file path to GIMP installer
[string]$inkscape_installer="https://inkscape.org/gallery/item/14202/inkscape-1.0alpha2_2019-06-24_4ce689b25c_64.msi", #URL or file path to Inkscape installer
[string]$kdevelop_version="5", #Major version of KDevelop to install
[string]$libreoffice_installer="https://dev-builds.libreoffice.org/daily/master/Win-x86_64@42/current/libo-master64~2019-07-10_02.13.57_LibreOfficeDev_6.4.0.0.alpha0_Win_x64.msi", #URL or file path to LibreOffice installer
[string]$mpchc_version="1.7.13.112", #MPC-HC nightly build version to install
[string]$musicbrainz_picard_version="2.1.3", #MusicBrainz Picard version to install
[string]$obs_installer="https://cdn-fastly.obsproject.com/downloads/OBS-Studio-23.2.1-Full-Installer-x64.exe", #URL or file path to OBS Studio installer
[string]$python_installer="https://www.python.org/ftp/python/3.8.0/python-3.8.0b1-amd64.exe", #URL or file path to Python installer
[string]$qview_version="2.0") #qView version to install

if (Test-Path "${PSScriptRoot}/../init_script.ps1")
{."${PSScriptRoot}/../init_script.ps1"}
else
{"Cannot find initialize script."
exit}

if (!$IsWindows)
{"Your operating system is not supported."
exit}

#Do not use single quotes(') in ArgumentList otherwise text inside of them will be broken.

$inno_setup_parameters="/closeapplications /nocancel /norestart /restartapplications /silent /sp- /suppressmsgboxes"

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

$output=FileURLDetector $gimp_installer
if ($output)
{"Installing GIMP"
Start-Process $output -ArgumentList "${inno_setup_parameters} /mergetasks=`"desktopicon`"" -Wait
if ($output -like "${tempdir}*")
  {"Deleting a temporary file"
  Remove-Item $output -Force}
}
else
{"Cannot download or find GIMP."}

$output=FileURLDetector $inkscape_installer
if ($output)
{$output=$output.Replace("/","\")
"Installing Inkscape"
Start-Process "C:/Windows/System32/msiexec.exe" -ArgumentList "/i `"${output}`" /norestart /passive" -Wait
if ($output -like "${tempdir}*")
  {"Deleting a temporary file"
  Remove-Item $output -Force}
}
else
{"Cannot download or find Inkscape."}

"Downloading KDevelop"
Invoke-WebRequest "https://binary-factory.kde.org/view/Management/job/KDevelop_Nightly_win64/lastSuccessfulBuild/artifact/kdevelop-${kdevelop_version}.exe" -DisableKeepAlive -OutFile "${tempdir}/KDevelop.exe"
if (Test-Path "${tempdir}/KDevelop.exe")
{"Installing"
Start-Process "${tempdir}/KDevelop.exe" -ArgumentList "/S" -Wait
"Deleting a temporary file"
Remove-Item "${tempdir}/KDevelop.exe" -Force}
else
{"Cannot download KDevelop."}

$output=FileURLDetector $libreoffice_installer
if ($output)
{$output=$output.Replace("/","\")
"Installing LibreOffice"
Start-Process "C:/Windows/System32/msiexec.exe" -ArgumentList "/i `"${output}`" RebootYesNo=No REGISTER_ALL_MSO_TYPES=1 /norestart /passive" -Wait
if ($output -like "${tempdir}*")
  {"Deleting a temporary file"
  Remove-Item $output -Force}
}
else
{"Cannot download or find LibreOffice."}

"Downloading MPC-HC"
Invoke-WebRequest "https://nightly.mpc-hc.org/MPC-HC.${mpchc_version}.x64.exe" -DisableKeepAlive -OutFile "${tempdir}/MPC-HC.exe"
if (Test-Path "${tempdir}/MPC-HC.exe")
{"Installing"
Start-Process "${tempdir}/MPC-HC.exe" -ArgumentList "${inno_setup_parameters} /mergetasks=`"desktopicon\common`"" -Wait
"Deleting a temporary file"
Remove-Item "${tempdir}/MPC-HC.exe" -Force}
else
{"Cannot download MPC-HC."}

"Downloading MusicBrainz Picard"
Invoke-WebRequest "https://musicbrainz.osuosl.org/pub/musicbrainz/picard/picard-setup-${musicbrainz_picard_version}.exe" -DisableKeepAlive -OutFile "${tempdir}/MusicBrainz Picard.exe"
if (Test-Path "${tempdir}/MusicBrainz Picard.exe")
{"Installing"
Start-Process "${tempdir}/MusicBrainz Picard.exe" -ArgumentList "/S" -Wait
"Deleting a temporary file"
Remove-Item "${tempdir}/MusicBrainz Picard.exe" -Force}
else
{"Cannot download MusicBrainz Picard."}

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

"Downloading qView"
Invoke-WebRequest "https://github.com/jurplel/qView/releases/download/${qview_version}/qView-${qview_version}-win64.exe" -DisableKeepAlive -OutFile "${tempdir}/qView.exe"
if (Test-Path "${tempdir}/qView.exe")
{"Installing"
Start-Process "${tempdir}/qView.exe" -ArgumentList "${inno_setup_parameters} /mergetasks=`"desktopicon`"" -Wait
"Deleting a temporary file"
Remove-Item "${tempdir}/qView.exe" -Force}
else
{"Cannot download qView."}

"Downloading Visual Studio Code"
Invoke-WebRequest "https://go.microsoft.com/fwlink/?Linkid=852155" -DisableKeepAlive -OutFile "${tempdir}/Visual Studio Code.exe"
if (Test-Path "${tempdir}/Visual Studio Code.exe")
{"Installing"
Start-Process "${tempdir}/Visual Studio Code.exe" -ArgumentList "${inno_setup_parameters} /mergetasks=`"addcontextmenufiles,addcontextmenufolders,addtopath,associatewithfiles,desktopicon,!runcode`"" -Wait
"Deleting a temporary file"
Remove-Item "${tempdir}/Visual Studio Code.exe" -Force}
else
{"Cannot download Visual Studio Code."}

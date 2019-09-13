#Install apps
#Installs some apps.

param
([string]$bleachbit_installer="https://ci.bleachbit.org/dl/2.3.1244/BleachBit-2.3-setup-English.exe", #URL or file path to BleachBit installer
[string]$gimp_installer="https://download.gimp.org/mirror/pub/gimp/v2.10/windows/gimp-2.10.12-setup-2.exe", #URL or file path to GIMP installer
[string]$go_version="1.13", #Go version
[string]$kdevelop_version="5", #Major version of KDevelop
[string]$libreoffice_installer="https://dev-builds.libreoffice.org/daily/master/Win-x86_64@62-TDF/current/master~2019-09-01_22.04.10_LibreOfficeDev_6.4.0.0.alpha0_Win_x64_en-US_de_ar_ja_ru_vec_qtz.msi", #URL or file path to LibreOffice installer
[string]$mpchc_version="1.7.13.112", #MPC-HC nightly build version
[string]$musicbrainz_picard_version="2.1.3", #MusicBrainz Picard version
[string]$nodejs_installer="https://nodejs.org/download/nightly/v13.0.0-nightly20190912902c9fac19/node-v13.0.0-nightly20190912902c9fac19-x64.msi", #URL or file path to Node.js installer
[string]$obs_installer="https://github.com/obsproject/obs-studio/releases/download/24.0.0-rc2/OBS-Studio-24.0-rc2-Full-Installer-x64.exe", #URL or file path to OBS Studio installer
[string]$peazip_version="6.9.2", #PeaZip version
[string]$python2_installer="https://www.python.org/ftp/python/2.7.16/python-2.7.16rc1.amd64.msi", #URL or file path to Python 2 installer
[string]$python3_installer="https://www.python.org/ftp/python/3.8.0/python-3.8.0b4-amd64.exe", #URL or file path to Python 3 installer
[string]$qview_version="2.0", #qView version
[string]$vscodium_version="1.37.1") #VSCodium version

if (Test-Path "${PSScriptRoot}/../init_script.ps1")
{."${PSScriptRoot}/../init_script.ps1"}
else
{"Cannot find initialize script."
exit}

if (!(Test-AdminPermission))
{"This script must be run as administrator on Windows."
exit}

#Do not use single quotes(') in ArgumentList otherwise text inside of them will be broken.

$inno_setup_parameters="/closeapplications /nocancel /norestart /restartapplications /silent /sp- /suppressmsgboxes"

#Must be before any other apps
"Downloading Microsoft Visual C++ Redistributable for Visual Studio 2019"
Invoke-WebRequest "https://aka.ms/vs/16/release/VC_redist.x64.exe" -DisableKeepAlive -OutFile "${tempdir}/vc_redist.exe"
if (Test-Path "${tempdir}/vc_redist.exe")
{"Installing"
Start-Process "${tempdir}/vc_redist.exe" -ArgumentList "/norestart /passive" -Wait
"Deleting a temporary file"
Remove-Item "${tempdir}/vc_redist.exe" -Force}
else
{"Cannot download Microsoft Visual C++ Redistributable for Visual Studio 2019."}

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
Start-Sleep 3
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

"Downloading Go"
Invoke-WebRequest "https://dl.google.com/go/go${go_version}.windows-amd64.msi" -DisableKeepAlive -OutFile "${tempdir}/golang.msi"
if (Test-Path "${tempdir}/golang.msi")
{$installer="${tempdir}/golang.msi".Replace("/","\")
"Installing"
Start-Process "C:/Windows/System32/msiexec.exe" -ArgumentList "/i `"${installer}`" /norestart /passive" -Wait
"Deleting a temporary file"
Remove-Item "${tempdir}/golang.msi" -Force}
else
{"Cannot download Go."}

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

$output=FileURLDetector $nodejs_installer
if ($output)
{$installer=$output.Replace("/","\")
"Installing Node.js"
Start-Process "C:/Windows/System32/msiexec.exe" -ArgumentList "/i `"${installer}`" /norestart /passive" -Wait
if ($output -like "${tempdir}*")
  {"Deleting a temporary file"
  Remove-Item $output -Force}
}
else
{"Cannot download or find Node.js."}

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

"Downloading PeaZip"
Invoke-WebRequest "http://www.peazip.org/downloads/peazip-${peazip_version}.WIN64.exe" -DisableKeepAlive -OutFile "${tempdir}/PeaZip.exe"
if (Test-Path "${tempdir}/PeaZip.exe")
{"Installing"
Start-Process "${tempdir}/PeaZip.exe" -ArgumentList $inno_setup_parameters -Wait
"Deleting a temporary file"
Remove-Item "${tempdir}/PeaZip.exe" -Force

"Moving a shortcut"
if (Test-Path "${Env:USERPROFILE}/Desktop/PeaZip.lnk")
  {Move-Item "${Env:USERPROFILE}/Desktop/PeaZip.lnk" "C:/Users/Public/Desktop/" -Force}
if (Test-Path "${Env:USERPROFILE}/OneDrive/Desktop/PeaZip.lnk")
  {Move-Item "${Env:USERPROFILE}/OneDrive/Desktop/PeaZip.lnk" "C:/Users/Public/Desktop/" -Force}
}
else
{"Cannot download PeaZip."}

$output=FileURLDetector $python2_installer
if ($output)
{$output=$output.Replace("/","\")
"Installing Python 2"
Start-Process "C:/Windows/System32/msiexec.exe" -ArgumentList "/i `"${output}`" /norestart /passive" -Wait
if ($output -like "${tempdir}*")
  {"Deleting a temporary file"
  Remove-Item $output -Force}
}
else
{"Cannot download or find Python 2."}

$output=FileURLDetector $python3_installer
if ($output)
{"Installing Python 3"
Start-Process $output -ArgumentList "InstallAllUsers=1 PrependPath=1 /passive" -Wait
if ($output -like "${tempdir}*")
  {"Deleting a temporary file"
  Remove-Item $output -Force}
}
else
{"Cannot download or find Python 3."}

"Downloading qView"
Invoke-WebRequest "https://github.com/jurplel/qView/releases/download/${qview_version}/qView-${qview_version}-win64.exe" -DisableKeepAlive -OutFile "${tempdir}/qView.exe"
if (Test-Path "${tempdir}/qView.exe")
{"Installing"
Start-Process "${tempdir}/qView.exe" -ArgumentList "${inno_setup_parameters} /mergetasks=`"desktopicon`"" -Wait
"Deleting a temporary file"
Remove-Item "${tempdir}/qView.exe" -Force}
else
{"Cannot download qView."}

"Downloading TeamViewer"
Invoke-WebRequest "https://download.teamviewer.com/download/TeamViewer_Setup.exe" -DisableKeepAlive -OutFile "${tempdir}/TeamViewer.exe"
if (Test-Path "${tempdir}/TeamViewer.exe")
{"Installing"
Start-Process "${tempdir}/TeamViewer.exe" -ArgumentList "/S" -Wait
"Deleting a temporary file"
Remove-Item "${tempdir}/TeamViewer.exe" -Force}
else
{"Cannot download TeamViewer."}

"Downloading VSCodium"
Invoke-WebRequest "https://github.com/VSCodium/vscodium/releases/download/${vscodium_version}/VSCodiumSetup-x64-${vscodium_version}.exe" -DisableKeepAlive -OutFile "${tempdir}/VSCodium.exe"
if (Test-Path "${tempdir}/VSCodium.exe")
{"Installing"
Start-Process "${tempdir}/VSCodium.exe" -ArgumentList "${inno_setup_parameters} /mergetasks=`"addcontextmenufiles,addcontextmenufolders,addtopath,associatewithfiles,desktopicon,!runcode`"" -Wait
"Deleting a temporary file"
Remove-Item "${tempdir}/VSCodium.exe" -Force}
else
{"Cannot download VSCodium."}

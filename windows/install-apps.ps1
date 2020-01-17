#Installs some apps.

Param
([string]$bleachbit_version="3.0.1.1394", #BleachBit unstable build version
[string]$gimp_version="2.10.14", #GIMP version
[string]$golang_version="1.13.4", #Go version
[string]$imagemagick_version="7.0.9-5", #ImageMagick version
[string]$inkscape_installer="https://inkscape.org/gallery/item/13318/inkscape-0.92.4-x64.exe", #URL or file path to Inkscape installer
[string]$kdevelop_version="5.4-469", #KDevelop nightly build version
[string]$libreoffice_installer="https://dev-builds.libreoffice.org/daily/master/Win-x86_64@tb77-TDF/current/LibreOfficeDev_6.5.0.0.alpha0_Win_x64.msi", #URL or file path to LibreOffice installer
[string]$musicbrainz_picard_version="2.2.3", #MusicBrainz Picard version
[string]$nodejs_installer="https://nodejs.org/download/nightly/v13.2.1-nightly2019112294e4cbd808/node-v13.2.1-nightly2019112294e4cbd808-x64.msi", #URL or file path to Node.js installer
[boolean]$obs=$true, #Whether to install OBS Studio
[string]$peazip_version="6.9.2", #PeaZip version
[string]$python2_version="2.7.17", #Python 2 version
[string]$python3_version="3.8.0", #Python 3 version
[boolean]$qview=$true, #Whether to install qView
[string]$smplayer_version="19.5.0.9228", #SMPlayer development build version
[string]$thunderbird_version="71.0b3", #Thunderbird version
[boolean]$vc_redist=$true, #Whether to install Microsoft Visual C++ Redistributable for Visual Studio 2019
[string]$vscodium=$true) #Whether to install VSCodium

if (Test-Path "${PSScriptRoot}/../init-script.ps1")
{."${PSScriptRoot}/../init-script.ps1"}
else
{Write-Error "Cannot find initialize script." -Category ObjectNotFound
exit}

if (!(Test-AdminPermission))
{Write-Error "This script must be run as administrator on Windows." -Category PermissionDenied
exit}

#Do not use single quotes(') in ArgumentList otherwise text inside of them will be broken.

$inno_setup_parameters="/closeapplications /nocancel /norestart /restartapplications /silent /sp- /suppressmsgboxes"

#This should be installed before any other apps
if ($vc_redist)
{Write-Verbose "Downloading Microsoft Visual C++ Redistributable for Visual Studio 2019"
Invoke-WebRequest "https://aka.ms/vs/16/release/VC_redist.x64.exe" -DisableKeepAlive -OutFile "${tempdir}/vc_redist.exe"
if (Test-Path "${tempdir}/vc_redist.exe")
  {Write-Verbose "Installing"
  Start-Process "${tempdir}/vc_redist.exe" -ArgumentList "/norestart /passive" -Wait
  Write-Verbose "Deleting a file that is no longer needed"
  Remove-Item "${tempdir}/vc_redist.exe" -Force}
else
  {Write-Error "Cannot download Microsoft Visual C++ Redistributable for Visual Studio 2019." -Category ConnectionError}
}

if ($bleachbit_version)
{Write-Verbose "Downloading BleachBit"
Invoke-WebRequest "https://ci.bleachbit.org/dl/${bleachbit_version}/BleachBit-${bleachbit_version}-setup-English.exe" -DisableKeepAlive -OutFile "${tempdir}/bleachbit.exe"
if (Test-Path "${tempdir}/bleachbit.exe")
  {Write-Verbose "Installing"
  Start-Process "${tempdir}/bleachbit.exe" -ArgumentList "/S" -Wait
  Write-Verbose "Deleting a file that is no longer needed"
  Remove-Item "${tempdir}/bleachbit.exe" -Force}
else
  {Write-Error "Cannot download BleachBit." -Category ConnectionError}
}

if ($gimp_version -match "^(\d+\.\d+)\.\d+$")
{$gimp_majorversion=$Matches[1]
Write-Verbose "Downloading GIMP"
Invoke-WebRequest "https://download.gimp.org/mirror/pub/gimp/v${gimp_majorversion}/windows/gimp-${gimp_version}-setup.exe" -DisableKeepAlive -OutFile "${tempdir}/gimp.exe"
if (Test-Path "${tempdir}/gimp.exe")
  {Write-Verbose "Installing"
  Start-Process "${tempdir}/gimp.exe" -ArgumentList "/S" -Wait
  Write-Verbose "Deleting a file that is no longer needed"
  Remove-Item "${tempdir}/gimp.exe" -Force}
else
  {Write-Error "Cannot download GIMP." -Category ConnectionError}
}

if ($golang_version)
{Write-Verbose "Downloading Go"
Invoke-WebRequest "https://dl.google.com/go/go${golang_version}.windows-amd64.msi" -DisableKeepAlive -OutFile "${tempdir}/golang.msi"
if (Test-Path "${tempdir}/golang.msi")
  {$installer="${tempdir}/golang.msi".Replace("/","\")
  Write-Verbose "Installing"
  Start-Process "C:/Windows/System32/msiexec.exe" -ArgumentList "/i `"${installer}`" /norestart /passive" -Wait
  Write-Verbose "Deleting a file that is no longer needed"
  Remove-Item "${tempdir}/golang.msi" -Force}
else
  {Write-Verbose "Cannot download Go." -Category ConnectionError}
}

if ($imagemagick_version)
{Write-Verbose "Downloading ImageMagick"
Invoke-WebRequest "https://imagemagick.org/download/binaries/ImageMagick-${imagemagick_version}-Q16-HDRI-x64-dll.exe" -DisableKeepAlive -OutFile "${tempdir}/imagemagick.exe"
if (Test-Path "${tempdir}/imagemagick.exe")
  {Write-Verbose "Installing"
  Start-Process "${tempdir}/imagemagick.exe" -ArgumentList "${inno_setup_parameters} /mergetasks=`"legacy_support`"" -Wait
  Write-Verbose "Deleting a file that is no longer needed"
  Remove-Item "${tempdir}/imagemagick.exe" -Force

  Write-Verbose "Moving a shortcut"
  if (Test-Path "${Env:USERPROFILE}/Desktop/ImageMagick Display.lnk")
    {Move-Item "${Env:USERPROFILE}/Desktop/ImageMagick Display.lnk" "C:/Users/Public/Desktop/" -Force}
  if (Test-Path "${Env:USERPROFILE}/OneDrive/Desktop/ImageMagick Display.lnk")
    {Move-Item "${Env:USERPROFILE}/OneDrive/Desktop/ImageMagick Display.lnk" "C:/Users/Public/Desktop/" -Force}
  }
else
  {Write-Error "Cannot download ImageMagick." -Category ConnectionError}
}

if ($inkscape_installer)
{$output=Get-FilePathFromUri $inkscape_installer
if ($output)
  {Write-Verbose "Installing Inkscape"
  Start-Process $output -ArgumentList "/S" -Wait
  if ($output -like "${tempdir}*")
    {Write-Verbose "Deleting a file that is no longer needed"
    Remove-Item $output -Force}
  }
else
  {Write-Error "Cannot download or find Inkscape." -Category ConnectionError}
}

if ($kdevelop_version)
{Write-Verbose "Downloading KDevelop"
Invoke-WebRequest "https://binary-factory.kde.org/view/Management/job/KDevelop_Nightly_win64/lastSuccessfulBuild/artifact/kdevelop-${kdevelop_version}-windows-msvc2017_64-cl.exe" -DisableKeepAlive -OutFile "${tempdir}/kdevelop.exe"
if (Test-Path "${tempdir}/kdevelop.exe")
  {Write-Verbose "Installing"
  Start-Process "${tempdir}/kdevelop.exe" -ArgumentList "/S" -Wait
  Write-Verbose "Deleting a file that is no longer needed"
  Remove-Item "${tempdir}/kdevelop.exe" -Force}
else
  {Write-Error "Cannot download KDevelop." -Category ConnectionError}
}

if ($libreoffice_installer)
{$output=Get-FilePathFromUri $libreoffice_installer
if ($output)
  {$installer=$output.Replace("/","\")
  Write-Verbose "Installing LibreOffice"
  Start-Process "C:/Windows/System32/msiexec.exe" -ArgumentList "/i `"${installer}`" RebootYesNo=No REGISTER_ALL_MSO_TYPES=1 /norestart /passive" -Wait
  if ($output -like "${tempdir}*")
    {Write-Verbose "Deleting a file that is no longer needed"
    Remove-Item $output -Force}
  }
else
  {Write-Error "Cannot download or find LibreOffice." -Category ConnectionError}
}

if ($musicbrainz_picard_version)
{Write-Verbose "Downloading MusicBrainz Picard"
Invoke-WebRequest "https://musicbrainz.osuosl.org/pub/musicbrainz/picard/picard-setup-${musicbrainz_picard_version}.exe" -DisableKeepAlive -OutFile "${tempdir}/musicbrainz_picard.exe"
if (Test-Path "${tempdir}/musicbrainz_picard.exe")
  {Write-Verbose "Installing"
  Start-Process "${tempdir}/musicbrainz_picard.exe" -ArgumentList "/S" -Wait
  Write-Verbose "Deleting a file that is no longer needed"
  Remove-Item "${tempdir}/musicbrainz_picard.exe" -Force}
else
  {Write-Error "Cannot download MusicBrainz Picard." -Category ConnectionError}
}

if ($nodejs_installer)
{$output=Get-FilePathFromUri $nodejs_installer
if ($output)
  {$installer=$output.Replace("/","\")
  Write-Verbose "Installing Node.js"
  Start-Process "C:/Windows/System32/msiexec.exe" -ArgumentList "/i `"${installer}`" /norestart /passive" -Wait
  if ($output -like "${tempdir}*")
    {Write-Verbose "Deleting a file that is no longer needed"
    Remove-Item $output -Force}
  }
else
  {Write-Error "Cannot download or find Node.js." -Category ConnectionError}
}

if ($obs)
{$obs_installer=((Invoke-WebRequest "https://api.github.com/repos/obsproject/obs-studio/releases/latest" -DisableKeepAlive)."Content" | ConvertFrom-Json)."assets"."browser_download_url" | Select-String "OBS-Studio-.+-Full-Installer-x64\.exe$" -Raw
Write-Verbose "Downloading OBS Studio"
Invoke-WebRequest $obs_installer -DisableKeepAlive -OutFile "${tempdir}/obs.exe"
if (Test-Path "${tempdir}/obs.exe")
  {Write-Verbose "Installing"
  Start-Process "${tempdir}/obs.exe" -ArgumentList "/S" -Wait
  Write-Verbose "Deleting a file that is no longer needed"
  Remove-Item "${tempdir}/obs.exe" -Force}
else
  {Write-Error "Cannot download OBS Studio." -Category ConnectionError}
}

if ($peazip_version)
{Write-Verbose "Downloading PeaZip"
Invoke-WebRequest "http://www.peazip.org/downloads/peazip-${peazip_version}.WIN64.exe" -DisableKeepAlive -OutFile "${tempdir}/peazip.exe"
if (Test-Path "${tempdir}/peazip.exe")
  {Write-Verbose "Installing"
  Start-Process "${tempdir}/peazip.exe" -ArgumentList $inno_setup_parameters -Wait
  Write-Verbose "Deleting a file that is no longer needed"
  Remove-Item "${tempdir}/peazip.exe" -Force

  Write-Verbose "Moving a shortcut"
  if (Test-Path "${Env:USERPROFILE}/Desktop/PeaZip.lnk")
    {Move-Item "${Env:USERPROFILE}/Desktop/PeaZip.lnk" "C:/Users/Public/Desktop/" -Force}
  if (Test-Path "${Env:USERPROFILE}/OneDrive/Desktop/PeaZip.lnk")
    {Move-Item "${Env:USERPROFILE}/OneDrive/Desktop/PeaZip.lnk" "C:/Users/Public/Desktop/" -Force}
  }
else
  {Write-Error "Cannot download PeaZip." -Category ConnectionError}
}

if ($python2_version -match "^(\d+\.\d+\.\d+)(([ab]|rc)\d+)?$")
{$python2_majorversion=$Matches[1]
Write-Verbose "Downloading Python 2"
Invoke-WebRequest "https://www.python.org/ftp/python/${python2_majorversion}/python-${python2_version}.amd64.msi" -DisableKeepAlive -OutFile "${tempdir}/python2.msi"
if (Test-Path "${tempdir}/python2.msi")
  {$installer="${tempdir}/python2.msi".Replace("/","\")
  Write-Verbose "Installing"
  Start-Process "C:/Windows/System32/msiexec.exe" -ArgumentList "/i `"${installer}`" /norestart /passive" -Wait
  Write-Verbose "Deleting a file that is no longer needed"
  Remove-Item "${tempdir}/python2.msi" -Force}
else
  {Write-Error "Cannot download Python 2." -Category ConnectionError}
}

if ($python3_version -match "^(\d+\.\d+\.\d+)(([ab]|rc)\d+)?$")
{$python3_majorversion=$Matches[1]
Write-Verbose "Downloading Python 3"
Invoke-WebRequest "https://www.python.org/ftp/python/${python3_majorversion}/python-${python3_version}-amd64.exe" -DisableKeepAlive -OutFile "${tempdir}/python3.exe"
if (Test-Path "${tempdir}/python3.exe")
  {Write-Verbose "Installing"
  Start-Process "${tempdir}/python3.exe" -ArgumentList "InstallAllUsers=1 PrependPath=1 /passive" -Wait
  Write-Verbose "Deleting a file that is no longer needed"
  Remove-Item "${tempdir}/python3.exe" -Force}
else
  {Write-Error "Cannot download Python 3." -Category ConnectionError}
}

if ($qview)
{$qview_installer=((Invoke-WebRequest "https://api.github.com/repos/jurplel/qView/releases/latest" -DisableKeepAlive)."Content" | ConvertFrom-Json)."assets"."browser_download_url" | Select-String "qView-.+-win64\.exe$" -Raw
Write-Verbose "Downloading qView"
Invoke-WebRequest $qview_installer -DisableKeepAlive -OutFile "${tempdir}/qview.exe"
if (Test-Path "${tempdir}/qview.exe")
  {Write-Verbose "Installing"
  Start-Process "${tempdir}/qview.exe" -ArgumentList "${inno_setup_parameters} /mergetasks=`"desktopicon`"" -Wait
  Write-Verbose "Deleting a file that is no longer needed"
  Remove-Item "${tempdir}/qview.exe" -Force}
else
  {Write-Error "Cannot download qView." -Category ConnectionError}
}

if ($smplayer_version)
{Write-Verbose "Downloading SMPlayer"
Invoke-WebRequest "https://sourceforge.net/projects/smplayer/files/SMPlayer/Development-builds/smplayer-${smplayer_version}-x64.exe/download" -DisableKeepAlive -OutFile "${tempdir}/smplayer.exe" -UserAgent "Wget"
if (Test-Path "${tempdir}/smplayer.exe")
  {Write-Verbose "Installing"
  Start-Process "${tempdir}/smplayer.exe" -ArgumentList "/S" -Wait
  Write-Verbose "Deleting a file that is no longer needed"
  Remove-Item "${tempdir}/smplayer.exe" -Force}
else
  {Write-Error "Cannot download SMPlayer." -Category ConnectionError}
}

if ($thunderbird_version)
{Write-Verbose "Downloading Thunderbird"
Invoke-WebRequest "https://download.mozilla.org/?product=thunderbird-${thunderbird_version}-SSL&os=win64&lang=en-US" -DisableKeepAlive -OutFile "${tempdir}/thunderbird.exe"
if (Test-Path "${tempdir}/thunderbird.exe")
  {Write-Verbose "Installing"
  Start-Process "${tempdir}/thunderbird.exe" -ArgumentList "/S" -Wait
  Write-Verbose "Deleting a file that is no longer needed"
  Remove-Item "${tempdir}/thunderbird.exe" -Force}
else
  {Write-Error "Cannot download Thunderbird." -Category ConnectionError}
}

if ($vscodium)
{$vscodium_installer=((Invoke-WebRequest "https://api.github.com/repos/VSCodium/vscodium/releases/latest" -DisableKeepAlive)."Content" | ConvertFrom-Json)."assets"."browser_download_url" | Select-String "VSCodiumSetup-x64-.+\.exe$" -Raw
Write-Verbose "Downloading VSCodium"
Invoke-WebRequest $vscodium_installer -DisableKeepAlive -OutFile "${tempdir}/vscodium.exe"
if (Test-Path "${tempdir}/vscodium.exe")
  {Write-Verbose "Installing"
  Start-Process "${tempdir}/vscodium.exe" -ArgumentList "${inno_setup_parameters} /mergetasks=`"addcontextmenufiles,addcontextmenufolders,addtopath,associatewithfiles,desktopicon,!runcode`"" -Wait
  Write-Verbose "Deleting a file that is no longer needed"
  Remove-Item "${tempdir}/vscodium.exe" -Force}
else
  {Write-Error "Cannot download VSCodium." -Category ConnectionError}
}

#Installs some apps.

Param
([Parameter()][string]$gimp_version="2.10.18", #GIMP version
[string]$imagemagick_version="7.0.10-6", #ImageMagick version
[string]$inkscape_installer="https://inkscape.org/gallery/item/18071/inkscape-1.0rc1-x64.exe", #URL or file path to Inkscape installer
[string]$kdevelop_version="5.5-56", #KDevelop nightly build version
[string]$libreoffice_installer="https://dev-builds.libreoffice.org/pre-releases/win/x86_64/LibreOffice_6.4.3.2_Win_x64.msi", #URL or file path to LibreOffice installer
[bool]$musicbrainz_picard=$true, #Whether to install MusicBrainz Picard
[string]$nodejs_installer="https://nodejs.org/download/nightly/v13.13.1-nightly20200415947ddec091/node-v13.13.1-nightly20200415947ddec091-x64.msi", #URL or file path to Node.js installer
[string]$obs_version="25.0.4", #OBS Studio version
[bool]$peazip=$true, #Whether to install PeaZip
[string]$python2_version="2.7.18rc1", #Python 2 version
[string]$python3_version="3.9.0a5", #Python 3 version
[bool]$qview=$true, #Whether to install qView
[string]$smplayer_version="19.10.0.9301", #SMPlayer development build version
[string]$thunderbird_version="77.0a1", #Thunderbird version
[bool]$vc_redist=$true, #Whether to install Microsoft Visual C++ Redistributable for Visual Studio 2019
[bool]$vscodium=$true) #Whether to install VSCodium

if (Test-Path "${PSScriptRoot}/../init-script.ps1")
{if (!(."${PSScriptRoot}/../init-script.ps1"))
  {exit}
}
else
{Write-Error "Cannot find init-script.ps1 file." -Category ObjectNotFound
exit}

if (!(Test-AdminPermission))
{Write-Error "This script must be run as administrator on Windows." -Category PermissionDenied
exit}

#Do not use single quotes(') in ArgumentList otherwise text inside of them will be broken.

$inno_setup_parameters="/closeapplications /nocancel /norestart /restartapplications /silent /sp- /suppressmsgboxes"

#This should be installed before any other apps
if ($vc_redist)
{Write-Verbose "Downloading Microsoft Visual C++ Redistributable for Visual Studio 2019"
Invoke-WebRequest "https://aka.ms/vs/16/release/VC_redist.x64.exe" -DisableKeepAlive -OutFile "${PlaScrTempDirectory}/vc_redist.exe"
if (Test-Path "${PlaScrTempDirectory}/vc_redist.exe")
  {Write-Verbose "Installing"
  Start-Process "${PlaScrTempDirectory}/vc_redist.exe" -ArgumentList "/norestart /passive" -Wait
  Write-Verbose "Deleting a temporary file"
  Remove-Item "${PlaScrTempDirectory}/vc_redist.exe" -Force}
else
  {Write-Error "Cannot download Microsoft Visual C++ Redistributable for Visual Studio 2019." -Category ConnectionError}
}

if ($gimp_version -match "^(\d+\.\d+)\.\d+$")
{$gimp_majorversion=$Matches[1]
Write-Verbose "Downloading GIMP"
Invoke-WebRequest "https://download.gimp.org/pub/gimp/v${gimp_majorversion}/windows/gimp-${gimp_version}-setup.exe" -DisableKeepAlive -OutFile "${PlaScrTempDirectory}/gimp.exe"
if (Test-Path "${PlaScrTempDirectory}/gimp.exe")
  {Write-Verbose "Installing"
  Start-Process "${PlaScrTempDirectory}/gimp.exe" -ArgumentList "/S" -Wait
  Write-Verbose "Deleting a temporary file"
  Remove-Item "${PlaScrTempDirectory}/gimp.exe" -Force}
else
  {Write-Error "Cannot download GIMP." -Category ConnectionError}
}

if ($imagemagick_version)
{Write-Verbose "Downloading ImageMagick"
Invoke-WebRequest "https://imagemagick.org/download/binaries/ImageMagick-${imagemagick_version}-Q16-HDRI-x64-dll.exe" -DisableKeepAlive -OutFile "${PlaScrTempDirectory}/imagemagick.exe"
if (Test-Path "${PlaScrTempDirectory}/imagemagick.exe")
  {Write-Verbose "Installing"
  Start-Process "${PlaScrTempDirectory}/imagemagick.exe" -ArgumentList "${inno_setup_parameters} /mergetasks=`"legacy_support`"" -Wait
  Write-Verbose "Deleting a temporary file"
  Remove-Item "${PlaScrTempDirectory}/imagemagick.exe" -Force

  Write-Verbose "Moving a shortcut"
  if (Test-Path "${HOME}/Desktop/ImageMagick Display.lnk")
    {Move-Item "${HOME}/Desktop/ImageMagick Display.lnk" "C:/Users/Public/Desktop/" -Force}
  if (Test-Path "${HOME}/OneDrive/Desktop/ImageMagick Display.lnk")
    {Move-Item "${HOME}/OneDrive/Desktop/ImageMagick Display.lnk" "C:/Users/Public/Desktop/" -Force}
  }
else
  {Write-Error "Cannot download ImageMagick." -Category ConnectionError}
}

if ($inkscape_installer)
{$output=Get-FilePathFromURL $inkscape_installer
if ($output)
  {Write-Verbose "Installing Inkscape"
  Start-Process $output -ArgumentList "/S" -Wait
  if ($output -like "${PlaScrTempDirectory}*")
    {Write-Verbose "Deleting a temporary file"
    Remove-Item $output -Force}
  }
else
  {Write-Error "Cannot download or find Inkscape." -Category ObjectNotFound}
}

if ($kdevelop_version)
{Write-Verbose "Downloading KDevelop"
Invoke-WebRequest "https://binary-factory.kde.org/view/Management/job/KDevelop_Stable_win64/lastSuccessfulBuild/artifact/kdevelop-${kdevelop_version}-windows-msvc2017_64-cl.exe" -DisableKeepAlive -OutFile "${PlaScrTempDirectory}/kdevelop.exe"
if (Test-Path "${PlaScrTempDirectory}/kdevelop.exe")
  {Write-Verbose "Installing"
  Start-Process "${PlaScrTempDirectory}/kdevelop.exe" -ArgumentList "/S" -Wait
  Write-Verbose "Deleting a temporary file"
  Remove-Item "${PlaScrTempDirectory}/kdevelop.exe" -Force}
else
  {Write-Error "Cannot download KDevelop." -Category ConnectionError}
}

if ($libreoffice_installer)
{$output=Get-FilePathFromURL $libreoffice_installer
if ($output)
  {$installer=$output.Replace("/","\")
  Write-Verbose "Installing LibreOffice"
  Start-Process "C:/Windows/System32/msiexec.exe" -ArgumentList "/i `"${installer}`" RebootYesNo=No REGISTER_ALL_MSO_TYPES=1 /norestart /passive" -Wait
  if ($output -like "${PlaScrTempDirectory}*")
    {Write-Verbose "Deleting a temporary file"
    Remove-Item $output -Force}
  }
else
  {Write-Error "Cannot download or find LibreOffice." -Category ObjectNotFound}
}

if ($musicbrainz_picard)
{$musicbrainz_picard_installer=((Invoke-WebRequest "https://api.github.com/repos/metabrainz/picard/releases/latest" -DisableKeepAlive)."Content" | ConvertFrom-Json)."assets"."browser_download_url" | Select-String "\.exe$" -Raw
Write-Verbose "Downloading MusicBrainz Picard"
Invoke-WebRequest $musicbrainz_picard_installer -DisableKeepAlive -OutFile "${PlaScrTempDirectory}/musicbrainz_picard.exe"
if (Test-Path "${PlaScrTempDirectory}/musicbrainz_picard.exe")
  {Write-Verbose "Installing"
  Start-Process "${PlaScrTempDirectory}/musicbrainz_picard.exe" -ArgumentList "/S" -Wait
  Write-Verbose "Deleting a file that is no longer needed"
  Remove-Item "${PlaScrTempDirectory}/musicbrainz_picard.exe" -Force}
else
  {Write-Error "Cannot download MusicBrainz Picard." -Category ConnectionError}
}

if ($nodejs_installer)
{$output=Get-FilePathFromURL $nodejs_installer
if ($output)
  {$installer=$output.Replace("/","\")
  Write-Verbose "Installing Node.js"
  Start-Process "C:/Windows/System32/msiexec.exe" -ArgumentList "/i `"${installer}`" /norestart /passive" -Wait
  if ($output -like "${PlaScrTempDirectory}*")
    {Write-Verbose "Deleting a file that is no longer needed"
    Remove-Item $output -Force}
  }
else
  {Write-Error "Cannot download or find Node.js." -Category ObjectNotFound}
}

if ($obs_version)
{Write-Verbose "Downloading OBS Studio"
Invoke-WebRequest "https://cdn-fastly.obsproject.com/downloads/OBS-Studio-${obs_version}-Full-Installer-x64.exe" -DisableKeepAlive -OutFile "${PlaScrTempDirectory}/obs.exe"
if (Test-Path "${PlaScrTempDirectory}/obs.exe")
  {Write-Verbose "Installing"
  Start-Process "${PlaScrTempDirectory}/obs.exe" -ArgumentList "/S" -Wait
  Write-Verbose "Deleting a temporary file"
  Remove-Item "${PlaScrTempDirectory}/obs.exe" -Force}
else
  {Write-Error "Cannot download OBS Studio." -Category ConnectionError}
}

if ($peazip)
{Write-Verbose "Downloading PeaZip"
Invoke-WebRequest "https://sourceforge.net/projects/peazip/files/latest/download" -DisableKeepAlive -OutFile "${PlaScrTempDirectory}/peazip.exe" -UserAgent "Wget"
if (Test-Path "${PlaScrTempDirectory}/peazip.exe")
  {Write-Verbose "Installing"
  Start-Process "${PlaScrTempDirectory}/peazip.exe" -ArgumentList $inno_setup_parameters -Wait
  Write-Verbose "Deleting a temporary file"
  Remove-Item "${PlaScrTempDirectory}/peazip.exe" -Force

  Write-Verbose "Moving a shortcut"
  if (Test-Path "${HOME}/Desktop/PeaZip.lnk")
    {Move-Item "${HOME}/Desktop/PeaZip.lnk" "C:/Users/Public/Desktop/" -Force}
  if (Test-Path "${HOME}/OneDrive/Desktop/PeaZip.lnk")
    {Move-Item "${HOME}/OneDrive/Desktop/PeaZip.lnk" "C:/Users/Public/Desktop/" -Force}
  }
else
  {Write-Error "Cannot download PeaZip." -Category ConnectionError}
}

if ($python2_version -match "^(\d+\.\d+\.\d+)(([ab]|rc)\d+)?$")
{$python2_majorversion=$Matches[1]
Write-Verbose "Downloading Python 2"
Invoke-WebRequest "https://www.python.org/ftp/python/${python2_majorversion}/python-${python2_version}.amd64.msi" -DisableKeepAlive -OutFile "${PlaScrTempDirectory}/python2.msi"
if (Test-Path "${PlaScrTempDirectory}/python2.msi")
  {$installer="${PlaScrTempDirectory}/python2.msi".Replace("/","\")
  Write-Verbose "Installing"
  Start-Process "C:/Windows/System32/msiexec.exe" -ArgumentList "/i `"${installer}`" /norestart /passive" -Wait
  Write-Verbose "Deleting a temporary file"
  Remove-Item "${PlaScrTempDirectory}/python2.msi" -Force}
else
  {Write-Error "Cannot download Python 2." -Category ConnectionError}
}

if ($python3_version -match "^(\d+\.\d+\.\d+)(([ab]|rc)\d+)?$")
{$python3_majorversion=$Matches[1]
Write-Verbose "Downloading Python 3"
Invoke-WebRequest "https://www.python.org/ftp/python/${python3_majorversion}/python-${python3_version}-amd64.exe" -DisableKeepAlive -OutFile "${PlaScrTempDirectory}/python3.exe"
if (Test-Path "${PlaScrTempDirectory}/python3.exe")
  {Write-Verbose "Installing"
  Start-Process "${PlaScrTempDirectory}/python3.exe" -ArgumentList "InstallAllUsers=1 PrependPath=1 /passive" -Wait
  Write-Verbose "Deleting a temporary file"
  Remove-Item "${PlaScrTempDirectory}/python3.exe" -Force}
else
  {Write-Error "Cannot download Python 3." -Category ConnectionError}
}

if ($qview)
{$qview_installer=(Invoke-RestMethod "https://api.github.com/repos/jurplel/qView/releases/latest" -DisableKeepAlive)."assets"."browser_download_url" | Select-String "qView-.+-win64\.exe$" -Raw
Write-Verbose "Downloading qView"
Invoke-WebRequest $qview_installer -DisableKeepAlive -OutFile "${PlaScrTempDirectory}/qview.exe"
if (Test-Path "${PlaScrTempDirectory}/qview.exe")
  {Write-Verbose "Installing"
  Start-Process "${PlaScrTempDirectory}/qview.exe" -ArgumentList "${inno_setup_parameters} /mergetasks=`"desktopicon`"" -Wait
  Write-Verbose "Deleting a temporary file"
  Remove-Item "${PlaScrTempDirectory}/qview.exe" -Force}
else
  {Write-Error "Cannot download qView." -Category ConnectionError}
}

if ($smplayer_version)
{Write-Verbose "Downloading SMPlayer"
Invoke-WebRequest "https://sourceforge.net/projects/smplayer/files/SMPlayer/Development-builds/smplayer-${smplayer_version}-x64.exe/download" -DisableKeepAlive -OutFile "${PlaScrTempDirectory}/smplayer.exe" -UserAgent "Wget"
if (Test-Path "${PlaScrTempDirectory}/smplayer.exe")
  {Write-Verbose "Installing"
  Start-Process "${PlaScrTempDirectory}/smplayer.exe" -ArgumentList "/S" -Wait
  Write-Verbose "Deleting a file that is no longer needed"
  Remove-Item "${PlaScrTempDirectory}/smplayer.exe" -Force}
else
  {Write-Error "Cannot download SMPlayer." -Category ConnectionError}
}

if ($thunderbird_version)
{Write-Verbose "Downloading Thunderbird"
#https://ftp.mozilla.org/pub/thunderbird/nightly/
Invoke-WebRequest "https://ftp.mozilla.org/pub/thunderbird/nightly/latest-comm-central/thunderbird-${thunderbird_version}.en-US.win64.installer.exe" -DisableKeepAlive -OutFile "${PlaScrTempDirectory}/thunderbird.exe"
if (Test-Path "${PlaScrTempDirectory}/thunderbird.exe")
  {Write-Verbose "Installing"
  Start-Process "${PlaScrTempDirectory}/thunderbird.exe" -ArgumentList "/S" -Wait
  Write-Verbose "Deleting a file that is no longer needed"
  Remove-Item "${PlaScrTempDirectory}/thunderbird.exe" -Force}
else
  {Write-Error "Cannot download Thunderbird." -Category ConnectionError}
}

if ($vscodium)
{$vscodium_installer=(Invoke-RestMethod "https://api.github.com/repos/VSCodium/vscodium/releases/latest" -DisableKeepAlive)."assets"."browser_download_url" | Select-String "VSCodiumSetup-x64-.+\.exe$" -Raw
Write-Verbose "Downloading VSCodium"
Invoke-WebRequest $vscodium_installer -DisableKeepAlive -OutFile "${PlaScrTempDirectory}/vscodium.exe"
if (Test-Path "${PlaScrTempDirectory}/vscodium.exe")
  {Write-Verbose "Installing"
  Start-Process "${PlaScrTempDirectory}/vscodium.exe" -ArgumentList "${inno_setup_parameters} /mergetasks=`"addcontextmenufiles,addcontextmenufolders,addtopath,associatewithfiles,desktopicon,!runcode`"" -Wait
  Write-Verbose "Deleting a temporary file"
  Remove-Item "${PlaScrTempDirectory}/vscodium.exe" -Force}
else
  {Write-Error "Cannot download VSCodium." -Category ConnectionError}
}

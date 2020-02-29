#Initializes functions, variables, etc. for PlavorScripts.

function Expand-ArchiveSmart
{Param
([Parameter(Mandatory=$true,Position=1)][string]$DestinationPath,
[Parameter(Mandatory=$true,Position=0)][string]$Path)

$output=Get-FilePathFromURL $Path
if ($output)
  {Write-Verbose "Extracting archive"
  Expand-Archive $output "${PlaScrTempDirectory}/expand-archivesmart-extracts/" -Force
  if ((Get-ChildItem "${PlaScrTempDirectory}/expand-archivesmart-extracts" -Force -Name | Measure-Object)."Count" -eq 1)
    {Move-Item "${PlaScrTempDirectory}/expand-archivesmart-extracts/*/*" $DestinationPath -Force}
  else
    {Move-Item "${PlaScrTempDirectory}/expand-archivesmart-extracts/*" $DestinationPath -Force}
  Write-Verbose "Deleting a file and a directory that are no longer needed"
  if ($output -like "${PlaScrTempDirectory}*")
    {Remove-Item $output -Force}
  Remove-Item "${PlaScrTempDirectory}/expand-archivesmart-extracts" -Force -Recurse}
else
  {Write-Error "Cannot download or find archive."}
}

function Get-ConfigFromArchive
{Param
([string]$Archive="https://github.com/PlavorMind/Configurations/archive/master.zip",
[Parameter(Mandatory=$true,Position=1)][string]$DestinationPath,
[Parameter(Mandatory=$true,Position=0)][string]$Path)

Write-Verbose "Creating a temporary directory for extracting"
New-Item "${PlaScrTempDirectory}/get-configfromarchive-config" -Force -ItemType Directory
Write-Verbose "Extracting configurations archive"
Expand-ArchiveSmart $Archive "${PlaScrTempDirectory}/get-configfromarchive-config/"
if (Test-Path "${PlaScrTempDirectory}/get-configfromarchive-config/${Path}")
  {Write-Verbose "Moving configurations"
  Move-Item "${PlaScrTempDirectory}/get-configfromarchive-config/${Path}" $DestinationPath -Force}
else
  {Write-Error "Cannot download or find configurations."}
Write-Verbose "Deleting a directory that is no longer needed"
Remove-Item "${PlaScrTempDirectory}/get-configfromarchive-config" -Force -Recurse}

#For backward compatibility
function Get-FilePathFromUri
{Param([Parameter(Mandatory=$true,Position=0)][string]$Uri)

return Get-FilePathFromURL $Uri}

#Downloads a file to temporary directory and returns path of downloaded file if URL is specified, otherwise returns specified item back if it exists.
function Get-FilePathFromURL
{Param([Parameter(Mandatory=$true,Position=0)][string]$URL) #File path or URL to check

if ($URL -match "^https?:\/\/")
  {if ($URL -match "[^\\/:*?`"<>|]+\.[^\\/:*?`"<>|]+$")
    {$filename=$Matches[0]}
  else
    {$filename="get-filepathfromurl"}
  Invoke-WebRequest $URL -DisableKeepAlive -OutFile "${PlaScrTempDirectory}/${filename}"
  if (Test-Path "${PlaScrTempDirectory}/${filename}")
    {return "${PlaScrTempDirectory}/${filename}"}
  }
elseif (Test-Path $URL)
  {return $URL}
return $false}

#Creates a shortcut.
#This function only supports Windows.
function New-Shortcut
{Param
([Parameter(Position=2)][string]$Arguments, #Arguments of a shortcut
[Parameter(Mandatory=$true,Position=0)][string]$Path, #Path of a shortcut
[Parameter(Mandatory=$true,Position=1)][string]$TargetPath) #Target of a shortcut

if (Test-Path $TargetPath)
  {if ($IsWindows)
    {$shortcut=(New-Object "WScript.Shell").CreateShortcut($Path)
    if ($Arguments)
      {$shortcut.Arguments=$Arguments}
    $shortcut.TargetPath=$TargetPath
    Write-Verbose "Creating a shortcut to ${TargetPath} at ${Path}"
    $shortcut.Save()}
  else
    {Write-Error "Your operating system is not supported."}
  }
else
  {Write-Error "Cannot find the target."}
}

#Returns whether the user has administrator permission on Windows, or root permission on Linux and macOS.
function Test-AdminPermission
{if ($IsWindows)
  {$permissions=New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
  return $permissions.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)}
else
  {if ((id --user) -eq 0)
    {return $true}
  else
    {return $false}
  }
}

if ($PSVersionTable."PSVersion"."Major" -lt 7)
{Write-Error "PlavorScripts require PowerShell 7 or newer."
return $false}

if ($IsLinux)
{$PlaScrDefaultBaseDirectory="/plavormind"
$PlaScrDefaultPHPPath="/usr/bin/php"
$PlaScrTempDirectory="/tmp"}
elseif ($IsMacOS)
{$PlaScrDefaultBaseDirectory="/plavormind"
$PlaScrTempDirectory="/private/tmp"}
elseif ($IsWindows)
{$PlaScrDefaultBaseDirectory="C:/plavormind"
$PlaScrDefaultPHPPath="${PlaScrDefaultBaseDirectory}/php-ts/php.exe"
$PlaScrTempDirectory=$Env:TEMP}

#For backward compatibility
$tempdir=$PlaScrTempDirectory
#For suppressing warnings in VSCodium
$PlaScrDefaultPHPPath | Out-Null
$tempdir | Out-Null

return $true

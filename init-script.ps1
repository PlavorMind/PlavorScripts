#Initializes functions, variables, etc. for PlavorScripts.

#Extract an archive and move an extract item to destination path if only 1 item is extracted, otherwise move extracted items into destination directory.
function Expand-ArchiveSmart
{Param
([Parameter(Mandatory=$true,Position=1)][string]$DestinationPath, #Path to save extracted item if archive only contains 1 item, otherwise directory to save extracted items
[Parameter(Mandatory=$true,Position=0)][string]$Path) #File path or URL of archive

$output=Get-FilePathFromURL $Path
if ($output)
  {Write-Verbose "Extracting ${Path} archive"
  Expand-Archive $output "${PlaScrTempDirectory}/expand-archivesmart-extracts/" -Force

  if ((Get-ChildItem "${PlaScrTempDirectory}/expand-archivesmart-extracts" -Force -Name | Measure-Object)."Count" -eq 1)
    {Write-Verbose "Moving an extracted item to destination path"
    Move-Item "${PlaScrTempDirectory}/expand-archivesmart-extracts/*" $DestinationPath -Force
    Write-Verbose "Deleting a temporary directory"
    Remove-Item "${PlaScrTempDirectory}/expand-archivesmart-extracts" -Force -Recurse}
  else
    {Write-Verbose "Moving extracted items to destination directory"
    Move-Item "${PlaScrTempDirectory}/expand-archivesmart-extracts" $DestinationPath -Force}

  if ($output -like "${PlaScrTempDirectory}*")
    {Write-Verbose "Deleting a temporary file"
    Remove-Item $output -Force}
  }
else
  {Write-Error "Cannot download or find ${Path} archive." -Category ObjectNotFound}
}

#For backward compatibility
function Get-ConfigFromArchive
{Param
([Parameter(Mandatory=$true,Position=0)][string]$ConfigPath,
[Parameter(Mandatory=$true,Position=1)][string]$DestinationPath)

Get-ItemFromArchive $ConfigPath $DestinationPath}

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

#Get an item from an archive.
function Get-ItemFromArchive
{Param
([string]$Archive="https://github.com/PlavorMind/Configurations/archive/master.zip", #File path or URL of archive
[Parameter(Mandatory=$true,Position=1)][string]$DestinationPath, #Path to save item
[Parameter(Mandatory=$true,Position=0)][string]$PathInArchive) #Path of item in archive

Expand-ArchiveSmart $Archive "${PlaScrTempDirectory}/get-itemfromarchive-extracts"
if (Test-Path "${PlaScrTempDirectory}/get-itemfromarchive-extracts")
  {if (Test-Path "${PlaScrTempDirectory}/get-itemfromarchive-extracts/${PathInArchive}")
    {Write-Verbose "Moving an item"
    Move-Item "${PlaScrTempDirectory}/get-itemfromarchive-extracts/${PathInArchive}" $DestinationPath -Force}
  else
    {Write-Error "Cannot find the item." -Category ObjectNotFound}
  Write-Verbose "Deleting a temporary directory"
  Remove-Item Expand-ArchiveSmart $Archive "${PlaScrTempDirectory}/get-itemfromarchive-extracts" -Force -Recurse}
}

#Creates a shortcut.
#This function only supports Windows.
function New-Shortcut
{Param
([Parameter(Position=2)][string]$Arguments, #Arguments to use when running app with shortcut
[Parameter(Mandatory=$true,Position=0)][string]$Path, #Path to create shortcut
[Parameter(Mandatory=$true,Position=1)][string]$TargetPath) #Path of app to run with shortcut

if (Test-Path $TargetPath)
  {if ($IsWindows)
    {$shortcut=(New-Object "WScript.Shell").CreateShortcut($Path)
    $shortcut.TargetPath=$TargetPath
    if ($Arguments)
      {$shortcut.Arguments=$Arguments
      Write-Verbose "Creating a shortcut to ${TargetPath} ${Arguments} at ${Path}"}
    else
      {Write-Verbose "Creating a shortcut to ${TargetPath} at ${Path}"}
    $shortcut.Save()}
  else
    {Write-Error "Your operating system is not supported." -Category NotImplemented}
  }
else
  {Write-Error "Cannot find the app." -Category ObjectNotFound}
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
{Write-Error "PlavorScripts require PowerShell 7 or newer." -Category NotInstalled
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

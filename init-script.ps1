# Initializes functions, variables, etc. for PlavorScripts.

# Extract an archive and move an extract item to destination path if only 1 item is extracted, otherwise move extracted items into destination directory.
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

# Downloads a file to temporary directory and returns path of downloaded file if URL is specified, otherwise returns specified item back if it exists.
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

# Get an item from an archive.
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
  Remove-Item "${PlaScrTempDirectory}/get-itemfromarchive-extracts" -Force -Recurse}
}

# Check requirements
if ($PSVersionTable.PSVersion.Major -lt 7)
  {throw 'PlavorScripts does not support PowerShell 6 or older.'}

if ($IsMacOS)
  {throw 'PlavorScripts does not support macOS.'}
elseif ($IsWindows -and ([System.Environment]::OSVersion.Version.Major -lt 10))
  {throw 'PlavorScripts does not support Windows NT 6.3 (Windows 8.1) or older.'}

# Initialize variables
$PlaScrDirectory=$PSScriptRoot

if ($IsLinux)
  {$PlaScrDefaultBaseDirectory='/plavormind'
  $PlaScrDefaultPHPPath='/usr/bin/php'
  $PlaScrTempDirectory='/tmp'}
elseif ($IsWindows)
  {$PlaScrDefaultBaseDirectory='C:/plavormind'
  $PlaScrDefaultPHPPath="${PlaScrDefaultBaseDirectory}/php/php.exe"
  $PlaScrTempDirectory=$Env:TEMP}

."${PlaScrDirectory}/src/common-functions.ps1"

# Suppress warnings in VSCodium
$PlaScrDefaultPHPPath | Out-Null
$PlaScrDirectory | Out-Null

return $true

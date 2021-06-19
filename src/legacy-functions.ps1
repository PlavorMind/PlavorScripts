# Extract an archive and move an extract item to destination path if only 1 item is extracted, otherwise move extracted items into destination directory.
function Expand-ArchiveSmart
  {param
  # Path to save extracted item if archive only contains 1 item, otherwise directory to save extracted items
  ([Parameter(Mandatory = $true, Position = 1)][string]$DestinationPath,
  # File path or URL of archive
  [Parameter(Mandatory = $true, Position = 0)][string]$Path)

  $output = Get-FilePathFromURL $Path

  if ($output)
    {Write-Verbose "Extracting ${Path} archive"
    Expand-Archive $output "${PlaScrTempDirectory}/expand-archivesmart-extracts/" -Force

    if ((Get-ChildItem "${PlaScrTempDirectory}/expand-archivesmart-extracts" -Force -Name | Measure-Object).Count -eq 1)
      {Write-Verbose 'Moving an extracted item to destination path'
      Move-Item "${PlaScrTempDirectory}/expand-archivesmart-extracts/*" $DestinationPath -Force
      Write-Verbose 'Deleting a temporary directory'
      Remove-Item "${PlaScrTempDirectory}/expand-archivesmart-extracts" -Force -Recurse}
    else
      {Write-Verbose 'Moving extracted items to destination directory'
      Move-Item "${PlaScrTempDirectory}/expand-archivesmart-extracts" $DestinationPath -Force}

    if ($output -like "${PlaScrTempDirectory}*")
      {Write-Verbose 'Deleting a temporary file'
      Remove-Item $output -Force}
    }
  else
    {Write-Error "Cannot download or find ${Path} archive." -Category ObjectNotFound}
  }

# Downloads a file to temporary directory and returns path of downloaded file if URL is specified, otherwise returns specified item back if it exists.
function Get-FilePathFromURL
  {param
  # File path or URL to check
  ([Parameter(Mandatory = $true, Position = 0)][string]$URL)

  if ($URL -match '^https?:\/\/')
    {if ($URL -match "[^\\/:*?`"<>|]+\.[^\\/:*?`"<>|]+$")
      {$filename = $Matches[0]}
    else
      {$filename = 'get-filepathfromurl'}

    # Hacky fix
    Get-FileFromURL $URL "${PlaScrTempDirectory}/${filename}"

    if (Test-Path "${PlaScrTempDirectory}/${filename}")
      {return "${PlaScrTempDirectory}/${filename}"}
    }
  elseif (Test-Path $URL)
    {return $URL}

  return $false}

# Get an item from an archive.
function Get-ItemFromArchive
  {param
  # File path or URL of archive
  ([string]$Archive = 'https://github.com/PlavorMind/Configurations/archive/master.zip',
  # Path to save item
  [Parameter(Mandatory = $true, Position = 1)][string]$DestinationPath,
  # Path of item in archive
  [Parameter(Mandatory = $true, Position = 0)][string]$PathInArchive)

  Expand-ArchiveSmart $Archive "${PlaScrTempDirectory}/get-itemfromarchive-extracts"

  if (Test-Path "${PlaScrTempDirectory}/get-itemfromarchive-extracts")
    {if (Test-Path "${PlaScrTempDirectory}/get-itemfromarchive-extracts/${PathInArchive}")
      {Write-Verbose 'Moving an item'
      Move-Item "${PlaScrTempDirectory}/get-itemfromarchive-extracts/${PathInArchive}" $DestinationPath -Force}
    else
      {Write-Error 'Cannot find the item.' -Category ObjectNotFound}

    Write-Verbose 'Deleting a temporary directory'
    Remove-Item "${PlaScrTempDirectory}/get-itemfromarchive-extracts" -Force -Recurse}
  }

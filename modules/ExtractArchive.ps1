#ExtractArchive
#Extracts an archive.

param
([string]$extractor, #App to use to extract an archive
[string]$path, #URL or file path to an archive
[string]$type) #Archive extension

."${PSScriptRoot}/SetTempDir.ps1"

if (!$isWindows)
{"Your operating system is not supported."
exit}

$ea_output=$false

switch ($extractor)
{default
  {$extractor_executable="C:/Program Files/7-Zip/7z.exe"}
}

if (Test-Path $extractor_executable)
{."${PSScriptRoot}/FileURLDetector.ps1" -path $path
if ($fud_output)
  {Copy-Item $fud_output "${tempdir}/ea_archive.${type}" -Force
  New-Item "${tempdir}/ea_output" -Force -ItemType Directory
  switch ($extractor)
    {default
      {if ($type -eq "tar.gz")
        {."${extractor_executable}" x "${tempdir}/ea_archive.${type}" -aoa -bt -o"${tempdir}" -spe -y
        ."${extractor_executable}" x "${tempdir}/ea_archive.tar" -aoa -bt -o"${tempdir}/ea_output" -spe -y
        Remove-Item "${tempdir}/ea_archive.tar" -Force}
      else
        {."${extractor_executable}" x "${tempdir}/ea_archive.${type}" -aoa -bt -o"${tempdir}/ea_output" -spe -y}
      }
    }
  $ea_output="${tempdir}/ea_output"
  if ($fud_web)
    {Remove-Item $fud_output -Force}
  Remove-Item "${tempdir}/ea_archive.${type}" -Force}
}

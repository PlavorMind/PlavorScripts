# Enables and disables Windows features.

param (
  # Path to the setting file
  [string]$SettingFile = "$PSScriptRoot/../../new-plascr/data/settings/windows-features.json"
)

if (Test-Path "$PSScriptRoot/../init-script.ps1") {
  . "$PSScriptRoot/../init-script.ps1" > $null
}
else {
  throw 'Cannot find init-script.ps1 file.'
}

if (!$IsWindows) {
  throw 'This script does not support operating systems other than Windows.'
}
elseif (!(Test-AdminPermission)) {
  throw 'This script requires administrator permission.'
}
elseif (!(Test-Path $SettingFile)) {
  throw 'Cannot find the setting file.'
}

$settingFileContent = Get-Content $SettingFile -ErrorAction Stop -Raw
$settings = ConvertFrom-Json $settingFileContent -ErrorAction Stop

$allFeatures = Get-WindowsOptionalFeature -Online

foreach ($action in 'disable', 'enable') {
  $featureNames = $settings.$action

  if (($action -eq 'enable') -and !(($featureNames.Count -eq 0) -or (Test-InternetConnection))) {
    Write-Error 'Enabling features requires the internet connection.' -Category ConnectionError
    continue
  }

  foreach ($featureName in $featureNames) {
    if ($featureName -notin $allFeatures.FeatureName) {
      Write-Error "$featureName is not a valid feature." -Category InvalidData
      continue
    }

    $feature = Get-WindowsOptionalFeature -FeatureName $featureName -Online

    switch ($action) {
      'disable' {
        $alreadySetState = 'Disabled'
        $alreadySetWarning = "$($feature.DisplayName) ($featureName) feature is already disabled."
        $setCmdlet = 'Disable-WindowsOptionalFeature'
        $settingFeatureOutput = "Disabling $($feature.DisplayName) ($featureName) feature"
      }
      'enable' {
        $alreadySetState = 'Enabled'
        $alreadySetWarning = "$($feature.DisplayName) ($featureName) feature is already enabled."
        $setCmdlet = 'Enable-WindowsOptionalFeature'
        $settingFeatureOutput = "Enabling $($feature.DisplayName) ($featureName) feature"
      }
    }

    if ($feature.State -eq $alreadySetState) {
      Write-Warning $alreadySetWarning
      continue
    }

    $settingFeatureOutput
    & $setCmdlet -FeatureName $featureName -NoRestart -Online
  }
}

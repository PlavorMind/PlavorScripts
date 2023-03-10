# Enables and disables Windows features.

param (
  # Parameter added just to make -Verbose parameter work and does nothing
  [Parameter()]$x
)

if (Test-Path "$PSScriptRoot/../init-script.ps1") {
  ."$PSScriptRoot/../init-script.ps1" | Out-Null
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

$settingsObject = @{
  disable = @(
    'MediaPlayback',
    'MicrosoftWindowsPowerShellV2',
    'MicrosoftWindowsPowerShellV2Root',
    'MSRDC-Infrastructure',
    'Printing-Foundation-Features',
    'Printing-XPSServices-Features',
    'SmbDirect',
    'WindowsMediaPlayer',
    'WorkFolders-Client'
  )
  enable = @()
}

$allFeaturesObject = Get-WindowsOptionalFeature -Online

foreach ($action in 'disable', 'enable') {
  $features = $settingsObject.$action

  if (($action -eq 'enable') -and !(($features.Count -eq 0) -or (Test-InternetConnection))) {
    Write-Error 'Enabling features requires internet connection.'
    continue
  }

  foreach ($feature in $features) {
    if ($feature -notin $allFeaturesObject.FeatureName) {
      Write-Error "$feature is not valid feature." -Category InvalidData
      continue
    }

    $featureObject = Get-WindowsOptionalFeature -FeatureName $feature -Online
    $featureDisplayName = $featureObject.DisplayName

    switch ($action) {
      'disable' {
        $alreadySetState = 'Disabled'
        $alreadySetWarning = "$featureDisplayName ($feature) feature is already disabled."
        $setCmdlet = 'Disable-WindowsOptionalFeature'
        $settingFeatureOutput = "Disabling $featureDisplayName ($feature) feature"
      }
      'enable' {
        $alreadySetState = 'Enabled'
        $alreadySetWarning = "$featureDisplayName ($feature) feature is already enabled."
        $setCmdlet = 'Enable-WindowsOptionalFeature'
        $settingFeatureOutput = "Enabling $featureDisplayName ($feature) feature"
      }
    }

    if ($featureObject.State -eq $alreadySetState) {
      Write-Warning $alreadySetWarning
      continue
    }

    $settingFeatureOutput
    . $setCmdlet -FeatureName $feature -NoRestart -Online
  }
}

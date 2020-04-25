<#
    Author:  Frank Trout
    Script:  Remove-ProvisionedPackages.ps1
    Version: 1903

    Removes the built-in AppX packages included with each build of Windows 10.

    Important! You can remove/comment out packages that you want to keep 
    installed from the list below based on your requirements.
    You can also add a package to the list if needed. To get the list of 
    provisioned apps, run 'Get-AppxProvisionedPackage -Online | select DisplayName'
   
    Script can be executed within MDT, Configuration Manager OSD, or as a
    standalone package.
#>

# List of apps to remove
$inboxApps = "Microsoft.BingWeather",
            "Microsoft.GetHelp",
            "Microsoft.Getstarted",
            "Microsoft.Messaging",
            "Microsoft.Microsoft3DViewer",
            "Microsoft.MicrosoftOfficeHub",
            "Microsoft.MicrosoftSolitaireCollection",
            "Microsoft.MicrosoftStickyNotes",
            "Microsoft.MixedReality.Portal",
            "Microsoft.MSPaint",
            "Microsoft.Office.OneNote",
            "Microsoft.OneConnect",
            "Microsoft.People",
            "Microsoft.Print3D",
            "Microsoft.SkypeApp",
            "Microsoft.StorePurchaseApp",
            "Microsoft.Wallet",
            "Microsoft.WindowsAlarms",
            "Microsoft.WindowsCalculator",
            "Microsoft.WindowsFeedbackHub",
            "Microsoft.WindowsMaps",
            "Microsoft.WindowsSoundRecorder",
            "Microsoft.Xbox.TCUI",
            "Microsoft.XboxApp",
            "Microsoft.XboxGameOverlay",
            "Microsoft.XboxGamingOverlay",
            "Microsoft.XboxSpeechToTextOverlay",
            "Microsoft.ZuneMusic",
            "Microsoft.ZuneVideo",
            "microsoft.windowscommunicationsapps",
            "Microsoft.WindowsFeedbackHub",
            "Microsoft.Windows.Photos",
            "Microsoft.WindowsStore",
            "Microsoft.WindowsCamera",
            "Microsoft.XboxIdentityProvider",
            "Microsoft.YourPhone"

$scriptInvocation   = (Get-Variable MyInvocation).Value
$scriptPath         = Split-Path $scriptInvocation.MyCommand.Path
$scriptName         = $scriptInvocation.MyCommand.Name

function GetLogPath {
    try {
        $ts = New-Object -ComObject Microsoft.SMS.TSEnvironment -ErrorAction Stop
        
        if ($ts.Value("LogPath") -ne "") {
            $logPath = $ts.Value("LogPath")
        }
        else {
            $logPath = $ts.Value("_SMSTSLogPath")
        }
    }
    catch {
        $logPath = "$env:windir\temp"
    }

    return $logPath
}

#Set log file path based on environment and start transcript.
$logFile = ($(GetLogPath) +"\"+ $scriptName +".log")
Start-Transcript $logFile

Write-Information "Script initialized at $((Get-Date).ToString())."


foreach ($app in $inboxApps) {
    $appxPackageFullName = (Get-AppxPackage $app).PackageFullName
    $provisionedPackageFullName = (Get-AppxProvisionedPackage -Online | ? { $_.Displayname -eq $app }).PackageName

    if ($appxPackageFullName){
        Remove-AppxPackage -Package $appxPackageFullName -Verbose        
    }

    if ($provisionedPackageFullName){
        Remove-AppxProvisionedPackage -Online -Packagename $provisionedPackageFullName -Verbose
    }
}

Stop-Transcript
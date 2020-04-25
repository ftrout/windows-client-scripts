<#
    Author:  Frank Trout
    Script:  Remove-Powershellv2.ps1
    Version: 1903

    Removes PowerShell v2 from system to mitigate PowerShell Downgrade Attacks.

    Script can be executed within MDT, Configuration Manager OSD, or as a
    standalone package.
#>

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

Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2 -ErrorAction SilentlyContinue -Verbose
Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root -ErrorAction SilentlyContinue -Verbose

Stop-Transcript
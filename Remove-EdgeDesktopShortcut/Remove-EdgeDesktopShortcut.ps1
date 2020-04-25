<#
    Author:  Frank Trout
    Script:  Remove-EdgeDesktopShortcut.ps1
    Version: 1809

    Script to remove the Edge shortcut from Windows 10 1803. This is a very 
    basic one-liner that can easily be reproduced as a Run Command Line step 
    during OSD or image creation.

    Script can be executed within MDT, Configuration Manager OSD, or as a
    standalone package.
#>

#Get current path and name of script
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
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer' -Name 'DisableEdgeDesktopShortcutCreation' -Value 1 -Type DWORD -Force

Stop-Transcript
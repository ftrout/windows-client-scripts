<#
    Author:  Frank Trout
    Script:  Enable-NetFx35.ps1
    Version: 1909

    Script is used to enable .NET 3.5 Framework in Windows 10. The script 
    will make an attempt to download the binaries automatically. If it is 
    unable to download them automatically it will look in the local [SourceFiles]
    folder or the SXS folder defined in the [SXSFolderPath] parameter for 
    the appropriate CAB files.

    Script can be executed within MDT, Configuration Manager OSD, or as a
    standalone package.
#>

param 
(
    [Parameter(Mandatory = $false)]
    [String]$SXSFolderPath
)

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

$logFile = ($(GetLogPath) +"\"+ $scriptName +".log")
Start-Transcript $logFile

if ((Get-WindowsOptionalFeature -Online -FeatureName NetFx3).State -ne 'Enabled') {
    Write-Information "Attempting to download and install binaries online."
    try {
        Add-WindowsCapability -Name NetFX3~~~~ -Online -Verbose
    }
    catch {
        Write-Warning "Unable to use [Add-WindowsCapability] to enable .NET 3.5 Framework. Attempting to locate local source."

        if (-not($SXSFolderPath)) {
            Write-Warning ("The [SXSFolderPath] parameter was not defined, using local folder ["+ $scriptPath +"\SourceFiles] as the source location.")
            $SXSFolderPath = "$scriptPath\SourceFiles"
        }
        else {
            Write-Information ("Using the defined location at  ["+ $SXSFolderPath +"] as the source.")
            $SXSFolderPath = "$scriptPath\SourceFiles"
        }
    
        Enable-WindowsOptionalFeature -Online -FeatureName NetFx3 -Source $SXSFolderPath -Verbose
    }
}
else {
    Write-Information ".NET 3.5 Framework is already enabled on the system."
}

Stop-Transcript
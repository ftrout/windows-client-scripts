<#
    Author:  Frank Trout
    Script:  Import-CustomStartLayout.ps1
    Version: 1803

    Script can be used to import a custom Windows 10 start menu layout.
    The configuration file should be exported from a reference machine 
    using [Export-StartLayout] and replace the sample StartLayout.xml
    found in the root of this scripts's package.
    
    For more information on creating a custom start menu layout, visit
    https://docs.microsoft.com/en-us/windows/configuration/customize-and-export-start-layout.

    Script can be executed within MDT, Configuration Manager OSD, or as a
    standalone package.
#>

#Get current path and name of script
$scriptInvocation   = (Get-Variable MyInvocation).Value
$scriptPath         = Split-Path $scriptInvocation.MyCommand.Path
$scriptName         = $scriptInvocation.MyCommand.Name

$destinationDir     = "$env:ProgramData\StartLayout"
$configXML          = (Get-ChildItem -Path $scriptPath -Include *.xml -Recurse).FullName

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

if (-not(Test-Path $configXML)) {
    Write-Warning "No startlayout configuration file found."
}
else {
    if (!(Test-Path $destinationDir)) {
        New-Item $destinationDir -ItemType Dir -Force -Verbose
    }

    Copy-Item $configXML -Destination "$destinationDir\StartLayout.xml" -Force -Verbose
    Import-StartLayout -LayoutPath "$destinationDir\StartLayout.xml" -MountPath ($env:SystemDrive +"\") -Verbose
}

Stop-Transcript
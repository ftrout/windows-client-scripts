<#
    Author:  Frank Trout
    Script:  Install-VCRedistributables.ps1
    Version: 1809

    Script can be used to download and install all currently supported 
    Visual C++ redistributables. The switches can be used to either  
    download the source files only, download and install with Online mode, or
    install from the local [SourceFiles] folder with Offline mode.

    Script can be executed within MDT, Configuration Manager OSD, or as a
    standalone package.
#>

Param (
    [Parameter(Mandatory = $true)]
    [ValidateSet("Online", "Offline", "DownloadOnly")]
    [String]$Mode
)

#Get current path and name of script
$scriptInvocation   = (Get-Variable MyInvocation).Value
$scriptPath         = Split-Path $scriptInvocation.MyCommand.Path
$scriptName         = $scriptInvocation.MyCommand.Name

$tempDir            = $env:SystemDrive

function DownloadSourceFiles {
    Param (
        [Parameter(Mandatory=$true)]
        [string]$Url,

        [Parameter(Mandatory=$true)]
        [string]$DownloadPath
    )

    $Request = New-Object System.Net.WebClient
    $Request.DownloadFile($Url, $DownloadPath)
}

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

#Gather rules if configuration XML exists.
Write-Information "Gathering install rules from configuration file."
if (Test-Path "$scriptPath\VCRedistributables.xml") {
    try {
        [xml]$Xml = Get-Content "$scriptPath\VCRedistributables.xml"
    }
    catch {
        Write-Warning "Unable to gather data from the configuration file successfully."
    }

    Write-Information "Configuration rules gathered successfully."
}
else {
    Write-Warning "Unable to locate a valid configuration file."
}

#Create directories, download, and stage source files
if (Test-Path "$tempDir\VCInstall") {
    Write-Warning "An existing temp directory was found, deleting old data."
    try {
        Remove-Item "$tempDir\VCInstall" -Force -Recurse -ErrorAction Stop -Verbose | Out-Null
    }
    catch {
        Write-Warning $Error[0].Exception.Message
    }
}

Write-Information "Creating temporary directories to stage source files."
try {
    New-Item "$tempDir\VCInstall" -ItemType dir -Force -ErrorAction Stop -Verbose | Out-Null
}
catch {
    Write-Warning $Error[0].Exception.Message
}

if ($Mode -eq 'Offline') {
    try {
        Write-Information "Mode is set to OFFLINE, copying source files to staging area."
        if (Test-Path "$scriptPath\SourceFiles") {
            Copy-Item "$scriptPath\SourceFiles\*" -Destination "$tempDir\VCInstall\" -Recurse -Force -ErrorAction Stop -Verbose | Out-Null
        }
        else {
            Write-Warning ("Unable to locate the ["+ $scriptPath +"\SourceFiles] directory required for OFFLINE installation.")
        }
    }
    catch {
        Write-Warning $Error[0].Exception.Message
    }
}
else {
    Write-Information ("Mode is set to "+ $Mode.ToUpper() +", creating child directories and downloading source files to staging area.")
    foreach ($package in $Xml.VCRedistributables.Package) {
        New-Item ($tempDir + "\VCInstall\" + $package.ShortName) -ItemType dir -Force -Verbose | Out-Null
        Write-Information ("Downloading 32-bit source file from ["+ $package.x86Source +"].")
        DownloadSourceFiles -Url $package.x86Source -DownloadPath ($tempDir + "\VCInstall\" + $package.ShortName + "\vc_redist.x86.exe")

        if ((Get-WmiObject -Class Win32_OperatingSystem).OSArchitecture -ne 'x86') {
            Write-Information ("Downloading 64-bit source file from ["+ $package.x64Source +"].")
            DownloadSourceFiles -Url $package.x64Source -DownloadPath ($tempDir + "\VCInstall\" + $package.ShortName + "\vc_redist.x64.exe")
        }
    }
}

#Install executables
if ($Mode -ne 'DownloadOnly') {
    Write-Information ("Mode is set to "+ $Mode.ToUpper() +", starting installation of executables.")
    $exePath = (Get-ChildItem -Path "$tempDir\VCInstall" | ? { $_.PSIsContainer }).FullName

    foreach ($Path in $exePath) {
        $x86Executable = (Get-ChildItem $Path -Recurse -Include *x86.exe).FullName
        Write-Information ("Starting installation of ["+ $x86Executable +"].")
        $proc = Start-Process -FilePath $x86Executable -ArgumentList "/Q" -Wait -PassThru
        Write-Information ("Installation of ["+ $x86Executable +"] exited with a return value of ["+ $proc.ExitCode +"].")

        if ((Get-WmiObject -Class Win32_OperatingSystem).OSArchitecture -ne 'x86') {
            $x64Executable = (Get-ChildItem $Path -Recurse -Include *x64.exe).FullName
            Write-Information ("Starting installation of ["+ $x64Executable +"].")
            $proc = Start-Process -FilePath $x64Executable -ArgumentList "/Q" -Wait -PassThru
            Write-Information ("Installation of ["+ $x64Executable +"] exited with a return value of ["+ $proc.ExitCode +"].")
        }
    }

    Write-Information ("Installation is complete and cleaning staging directories.")
    try {
        Remove-Item -Path "$tempDir\VCInstall" -Recurse -Force -Verbose | Out-Null
    }
    catch {
        Write-Warning $Error[0].Exception.Message
    }
}

Stop-Transcript
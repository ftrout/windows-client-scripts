# Remove Provisioned Packages
Removes the built-in AppX packages included with each build of Windows 10.

You can remove/comment out packages that you want to keep installed from the list below based on your requirements. You can also add a package to the list if needed. To get the list of provisioned apps, run 

**Get-AppxProvisionedPackage -Online | select DisplayName**
   
Script can be executed within MDT, Configuration Manager OSD, Intune, or as a standalone package.

Packages available to be removed:
- Microsoft.BingWeather
- Microsoft.GetHelp 
- Microsoft.Getstarted 
- Microsoft.Messaging 
- Microsoft.Microsoft3DViewer
- Microsoft.MicrosoftOfficeHub
- Microsoft.MicrosoftSolitaireCollection
- Microsoft.MicrosoftStickyNotes
- Microsoft.MixedReality.Portal 
- Microsoft.MSPaint
- Microsoft.Office.OneNote
- Microsoft.OneConnect
- Microsoft.People
- Microsoft.Print3D
- Microsoft.SkypeApp
- Microsoft.StorePurchaseApp
- Microsoft.Wallet
- Microsoft.WindowsAlarms
- Microsoft.WindowsCalculator
- Microsoft.WindowsFeedbackHub
- Microsoft.WindowsMaps
- Microsoft.WindowsSoundRecorder
- Microsoft.Xbox.TCUI
- Microsoft.XboxApp
- Microsoft.XboxGameOverlay
- Microsoft.XboxGamingOverlay
- Microsoft.XboxSpeechToTextOverlay
- Microsoft.ZuneMusic
- Microsoft.ZuneVideo
- microsoft.windowscommunicationsapps
- Microsoft.WindowsFeedbackHub
- Microsoft.Windows.Photos
- Microsoft.WindowsCamera
- Microsoft.XboxIdentityProvider
- Microsoft.YourPhone
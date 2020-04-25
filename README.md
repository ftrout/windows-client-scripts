# ![Windows 10](https://www.fluxbytes.com/wp-content/uploads/2014/10/windows-logo.png)  Windows 10
A repository of scripts with a focus on Windows 10.

---

* <strong>Enable-NetFx35.ps1</strong> - This script enables the .Net Framework 3.5 in Windows 10. The script attempts to first pull down the necessary binaries from the internet, if the device is offline, it will use the local SourceFiles folder (add the binaries before deploying the script).
* <strong>Import-CustomStartLayout.ps1</strong> - This script copies a custom startlayout.xml file, which would be manually placed at the root of this package, to the %ProgramData%\StartLayout folder and sets the custom layout as defined in the configuration XML file. The cached XML file can then be used as a source for the Custom StartLayout GPO.
* <strong>Install-VCRedistributables.ps1</strong> - The script is used to download, deploy offline, or online all the supported versions of the Visual C++ Redistributables.
* <strong>Remove-EdgeDesktopShortcut.ps1</strong> - Removes the Edge shortcut from the Windows 10 desktop. 
* <strong>Remove-ProvisionedPackages.ps1</strong> - Removes the built-in apps for Windows 10.
* <strong>Convert-ISO2USB.ps1</strong> - Creates a bootable USB by pointing to the ISO media. Can be used for Windows 10 or Server 2016.
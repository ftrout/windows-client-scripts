:: Run the reset Windows Update components. 

call :print Stopping the Windows Update services. 
net stop bits 

call :print Stopping the Windows Update services. 
net stop wuauserv 
 
call :print Stopping the Windows Update services. 
net stop appidsvc 
 
call :print Stopping the Windows Update services. 
net stop cryptsvc 
 
call :print Canceling the Windows Update process. 
taskkill /im wuauclt.exe /f 
 
call :print Checking the services status. 
 
sc query bits | findstr /I /C:"STOPPED" 
if %errorlevel% NEQ 0 ( 
    goto :eof 
) 
 
call :print Checking the services status. 
 
sc query wuauserv | findstr /I /C:"STOPPED" 
if %errorlevel% NEQ 0 ( 
    goto :eof 
) 
 
call :print Checking the services status. 
 
sc query appidsvc | findstr /I /C:"STOPPED" 
if %errorlevel% NEQ 0 ( 
    sc query appidsvc | findstr /I /C:"OpenService FAILED 1060" 
    if %errorlevel% NEQ 0 ( 
        if %family% NEQ 6 goto :eof 
    ) 
) 
 
call :print Checking the services status. 
 
sc query cryptsvc | findstr /I /C:"STOPPED" 
if %errorlevel% NEQ 0 ( 
    goto :eof 
) 
 
call :print Deleting the qmgr*.dat files. 
 
del /s /q /f "%ALLUSERSPROFILE%\Application Data\Microsoft\Network\Downloader\qmgr*.dat" 
del /s /q /f "%ALLUSERSPROFILE%\Microsoft\Network\Downloader\qmgr*.dat" 
 
call :print Deleting the old software distribution backup copies. 
 
cd /d %SYSTEMROOT% 
 
if exist "%SYSTEMROOT%\winsxs\pending.xml.bak" ( 
    del /s /q /f "%SYSTEMROOT%\winsxs\pending.xml.bak" 
) 
if exist "%SYSTEMROOT%\SoftwareDistribution.bak" ( 
    rmdir /s /q "%SYSTEMROOT%\SoftwareDistribution.bak" 
) 
if exist "%SYSTEMROOT%\system32\Catroot2.bak" ( 
    rmdir /s /q "%SYSTEMROOT%\system32\Catroot2.bak" 
) 
if exist "%SYSTEMROOT%\WindowsUpdate.log.bak" ( 
    del /s /q /f "%SYSTEMROOT%\WindowsUpdate.log.bak" 
) 

call :print Renaming the software distribution folders. 

if exist "%SYSTEMROOT%\winsxs\pending.xml" ( 
    takeown /f "%SYSTEMROOT%\winsxs\pending.xml" 
    attrib -r -s -h /s /d "%SYSTEMROOT%\winsxs\pending.xml" 
    ren "%SYSTEMROOT%\winsxs\pending.xml" pending.xml.bak 
) 
if exist "%SYSTEMROOT%\SoftwareDistribution" ( 
    attrib -r -s -h /s /d "%SYSTEMROOT%\SoftwareDistribution" 
    ren "%SYSTEMROOT%\SoftwareDistribution" SoftwareDistribution.bak 
    if exist "%SYSTEMROOT%\SoftwareDistribution" ( 
        goto :eof 
    ) 
) 
if exist "%SYSTEMROOT%\system32\Catroot2" ( 
    attrib -r -s -h /s /d "%SYSTEMROOT%\system32\Catroot2" 
    ren "%SYSTEMROOT%\system32\Catroot2" Catroot2.bak 
) 
if exist "%SYSTEMROOT%\WindowsUpdate.log" ( 
    attrib -r -s -h /s /d "%SYSTEMROOT%\WindowsUpdate.log" 
    ren "%SYSTEMROOT%\WindowsUpdate.log" WindowsUpdate.log.bak 
) 

call :print Reset the BITS service and the Windows Update service to the default security descriptor. 

sc.exe sdset wuauserv D:(A;;CCLCSWLOCRRC;;;AU)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCDCLCSWRPWPDTLCRSDRCWDWO;;;SO)(A;;CCLCSWRPWPDTLOCRRC;;;SY)S:(AU;FA;CCDCLCSWRPWPDTLOCRSDRCWDWO;;WD) 
sc.exe sdset bits D:(A;;CCLCSWLOCRRC;;;AU)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCDCLCSWRPWPDTLCRSDRCWDWO;;;SO)(A;;CCLCSWRPWPDTLOCRRC;;;SY)S:(AU;FA;CCDCLCSWRPWPDTLOCRSDRCWDWO;;WD) 
sc.exe sdset cryptsvc D:(A;;CCLCSWLOCRRC;;;AU)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCDCLCSWRPWPDTLCRSDRCWDWO;;;SO)(A;;CCLCSWRPWPDTLOCRRC;;;SY)S:(AU;FA;CCDCLCSWRPWPDTLOCRSDRCWDWO;;WD) 
sc.exe sdset trustedinstaller D:(A;;CCLCSWLOCRRC;;;AU)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCDCLCSWRPWPDTLCRSDRCWDWO;;;SO)(A;;CCLCSWRPWPDTLOCRRC;;;SY)S:(AU;FA;CCDCLCSWRPWPDTLOCRSDRCWDWO;;WD) 

call :print Reregister the BITS files and the Windows Update files. 

cd /d %SYSTEMROOT%\system32 
regsvr32.exe /s atl.dll 
regsvr32.exe /s urlmon.dll 
regsvr32.exe /s mshtml.dll 
regsvr32.exe /s shdocvw.dll 
regsvr32.exe /s browseui.dll 
regsvr32.exe /s jscript.dll 
regsvr32.exe /s vbscript.dll 
regsvr32.exe /s scrrun.dll 
regsvr32.exe /s msxml.dll 
regsvr32.exe /s msxml3.dll 
regsvr32.exe /s msxml6.dll 
regsvr32.exe /s actxprxy.dll 
regsvr32.exe /s softpub.dll 
regsvr32.exe /s wintrust.dll 
regsvr32.exe /s dssenh.dll 
regsvr32.exe /s rsaenh.dll 
regsvr32.exe /s gpkcsp.dll 
regsvr32.exe /s sccbase.dll 
regsvr32.exe /s slbcsp.dll 
regsvr32.exe /s cryptdlg.dll 
regsvr32.exe /s oleaut32.dll 
regsvr32.exe /s ole32.dll 
regsvr32.exe /s shell32.dll 
regsvr32.exe /s initpki.dll 
regsvr32.exe /s wuapi.dll 
regsvr32.exe /s wuaueng.dll 
regsvr32.exe /s wuaueng1.dll 
regsvr32.exe /s wucltui.dll 
regsvr32.exe /s wups.dll 
regsvr32.exe /s wups2.dll 
regsvr32.exe /s wuweb.dll 
regsvr32.exe /s qmgr.dll 
regsvr32.exe /s qmgrprxy.dll 
regsvr32.exe /s wucltux.dll 
regsvr32.exe /s muweb.dll 
regsvr32.exe /s wuwebv.dll 

call :print Resetting Winsock. 
netsh winsock reset 

call :print Resetting WinHTTP Proxy. 

if %family% EQU 5 ( 
    proxycfg.exe -d 
) else ( 
    netsh winhttp reset proxy 
) 

call :print Resetting the services as automatics. 
sc.exe config wuauserv start= auto 
sc.exe config bits start= delayed-auto 
sc.exe config cryptsvc start= auto 
sc.exe config TrustedInstaller start= demand 
sc.exe config DcomLaunch start= auto 

call :print Starting the Windows Update services. 
net start bits 

call :print Starting the Windows Update services. 
net start wuauserv 

call :print Starting the Windows Update services. 
net start appidsvc 

call :print Starting the Windows Update services. 
net start cryptsvc 

call :print Starting the Windows Update services. 
net start DcomLaunch 

call :print The operation completed successfully. 

echo.Press any key to continue . . . 
pause>nul 
goto :eof 

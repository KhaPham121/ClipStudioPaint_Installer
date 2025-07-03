@echo off
setlocal
ser "ScriptVersion=1.0.0"
set "source=%~dp0"
set "destination=%ProgramFiles%\CELSYS"
set "logfile=%source%\install.log"
for /f "tokens=4 delims=. " %%i in ('ver') do set winver=%%i
if not "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    echo This installer requires a 64-bit version of Windows.
    powershell -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Installation aborted. 64-bit Windows is required.','ClipStudio Installer')"
    exit /b
)
ver | findstr /i "10." >nul
if errorlevel 1 (
    echo This installer requires Windows 10 or later.
    powershell -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Installation aborted. Windows 10 or later is required.','ClipStudio Installer')"
    exit /b
)

echo [START] %date% %time% >> "%logfile%"
cls
title ClipStudio Paint Quick-Installer by KhaPham.K398
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Administrator privileges required...
    echo [ERROR] Administrator privileges required... >> "%logfile%"
    timeout /t 2 /nobreak >nul
    echo Setup will automatically close and auto-rerun with Administrator privileges...
    echo [INFO] Setup will auto-rerun as Administrator... >> "%logfile%"
    timeout /t 3 /nobreak >nul
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

title ClipStudio Paint Quick-Installer by KhaPham.K398
goto menu

:menu
mode con: cols=80 lines=25
cls
echo ======================================================================
echo       ClipStudio Paint EX v4.03 Quick-Installer by KhaPham.K398
echo ======================================================================
echo.
echo         1. Install ClipStudio Paint EX v4.03
echo         2. Uninstall ClipStudio Paint
echo         3. Get help
echo.
echo         4. Backup my ClipStudio Paint Appdata
echo         5. Restore my ClipStudio Paint Appdata
echo         6. Delete my ClipStudio Paint Appdata
echo.
echo         X. Exit
echo.
echo ======================================================================
choice /c 123456X /n
if errorlevel 7 exit
if errorlevel 6 goto check_delete
if errorlevel 5 goto restore
if errorlevel 4 goto backup
if errorlevel 3 goto gethelp
if errorlevel 2 goto check_uninstall
if errorlevel 1 goto check_install
cls
timeout /t 2 /nobreak >nul

:install
cls
timeout /t 2 /nobreak >nul
		if exist "%destination%" (
			rmdir /S /Q "%destination%"
			echo [INFO] Previous installation removed. >> "%logfile%"
			echo Cleanup successfully.
			echo [INFO] Cleanup successfully. >> "%logfile%"
)
timeout /t 2 /nobreak >nul
echo Installing with Package Installer...
echo [INFO] Installing with Package Installer... >> "%logfile%"
timeout /t 2 /nobreak >nul
start "" "%source%\main\CSP_403w_setup.exe"
:wait_loop_install
cls
tasklist /FI "IMAGENAME eq CSP_403w_setup.exe" | find /I "CSP_403w_setup.exe" >nul
if %errorlevel%==0 (
    echo Installing...
    echo Waiting for Package Installer complete...
    timeout /t 5 >nul
    goto wait_loop_install
)
timeout /t 1 /nobreak >nul
if exist "%destination%\CLIP STUDIO 1.5\CLIP STUDIO PAINT\CLIPStudioPaint.exe" (
    echo [INFO] Executable found, continuing installation. >> "%logfile%"
	call :add_exclusion
	timeout /t 1 /nobreak >nul
	call :patch
    timeout /t 1 /nobreak >nul
    echo Installation completed.
    echo [SUCCESS] Installation completed successfully. >> "%logfile%"
    powershell -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Installation successfully.','ClipStudio Paint Quick-Installer')"
    goto menu
) else (
    goto failed
)

:add_exclusion
if exist "C:\Program Files\Windows Defender\MpCmdRun.exe" (
    echo Adding ClipStudio Paint.exe to exclusion list in Windows Defender 
    echo [INFO] Adding exclusion via PowerShell. >> "%logfile%"
    cd /d %source%
    powershell -Command "Start-Process PowerShell -ArgumentList '-ExecutionPolicy Bypass -File \"%source%\main\module\exclusion.ps1\"' -Verb RunAs"
)
timeout /t 2 /nobreak >nul
goto :eof

:remove_exclusion
if exist "C:\Program Files\Windows Defender\MpCmdRun.exe" (
    echo Removing ClipStudio Paint.exe from exclusion list in Windows Defender 
    echo [INFO] Removing exclusion via PowerShell. >> "%logfile%"
    powershell -Command "Start-Process PowerShell -ArgumentList '-ExecutionPolicy Bypass -File \"%source%\main\module\rmexclusion.ps1\"' -Verb RunAs"
)
timeout /t 2 /nobreak >nul
goto :eof

:create_shortcut
cls
echo Creating shortcut to Desktop...
echo [INFO] Creating desktop shortcut. >> "%logfile%"
powershell -Command "$s=New-Object -ComObject WScript.Shell; $sc=$s.CreateShortcut([Environment]::GetFolderPath('Desktop') + '\ClipStudio Paint.lnk'); $sc.TargetPath='%destination%\CLIP STUDIO 1.5\CLIP STUDIO PAINT\CLIPStudioPaint.exe'; $sc.Save()"
powershell -Command "$s=New-Object -ComObject WScript.Shell; $sc=$s.CreateShortcut([Environment]::GetFolderPath('Desktop') + '\CLIPSTUDIO.lnk'); $sc.TargetPath='%destination%\CLIP STUDIO 1.5\CLIP STUDIO\CLIPSTUDIO.exe'; $sc.Save()"
cls
echo Creating shortcut to Desktop...       OK
goto :eof


:remove_shortcut
set "shortcut=%USERPROFILE%\Desktop\ClipStudio Paint.lnk"
set "shortcut1=%USERPROFILE%\Desktop\CLIPSTUDIO.lnk"
echo Removing desktop shortcut...
echo [INFO] Attempting to remove shortcut at "%shortcut%" >> "%logfile%"
if exist "%shortcut%" (
    del /f "%shortcut%"
    echo Shortcut removed successfully.
    echo [SUCCESS] Shortcut removed. >> "%logfile%"
) else (
    echo Shortcut not found. Nothing to remove.
    echo [WARNING] No shortcut found to remove. >> "%logfile%"
)
if exist "%shortcut1%" (
    del /f "%shortcut1%"
    echo Shortcut removed successfully.
    echo [SUCCESS] Shortcut removed. >> "%logfile%"
) else (
    echo Shortcut not found. Nothing to remove.
    echo [WARNING] No shortcut found to remove. >> "%logfile%"
)

timeout /t 2 /nobreak >nul
goto :eof


:failed
cls
echo Installation failed. Rolling back...
echo [ERROR] Installation failed, initiating cleanup. >> "%logfile%"
if exist "%destination%" (
    rmdir /S /Q "%destination%"
    echo [INFO] Removed destination folder during rollback. >> "%logfile%"
)
timeout /t 2 /nobreak >nul
call :remove_exclusion
powershell -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Installation failed. Nothing has changed.','ClipStudio Paint Quick-Installer')"
echo [END] %date% %time% >> "%logfile%"
goto menu

:uninstall_native
timeout /t 1 /nobreak >nul
cls
echo Uninstalling...
if exist "C:\Program Files (x86)\InstallShield Installation Information\{1E4572D2-28BC-4BC9-B743-13DC6CFD71DB}\setup.exe" (
start /wait "" "C:\Program Files (x86)\InstallShield Installation Information\{1E4572D2-28BC-4BC9-B743-13DC6CFD71DB}\setup.exe" -runfromtemp -l0x0409 -removeonly
)
:wait_loop_uninstall
cls
tasklist /FI "IMAGENAME eq setup.exe" | find /I "setup.exe" >nul
if not errorlevel 1 (
	echo Uninstalling...
    echo Waiting for Package Uninstaller complete...
    timeout /t 5 >nul
    goto wait_loop_uninstall
)
if exist "%destination%\CLIP STUDIO 1.5\CLIP STUDIO PAINT\CLIPStudioPaint.exe" (
cls
echo Uninstall failed.
timeout /t 1 /nobreak >nul
powershell -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Uninstall failed.','ClipStudio Paint Quick-Installer')"
goto menu
) else (
call :remove_exclusion
timeout /t 1 /nobreak >nul
echo Uninstalled.
timeout /t 1 /nobreak >nul
powershell -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Uninstalled.','ClipStudio Paint Quick-Installer')"
echo [END] %date% %time% >> "%logfile%"
goto menu
)

:unistall_nonative
timeout /t 1 /nobreak >nul
cls
echo Uninstalling...
if exist "%destination%" (
    rmdir /S /Q "%destination%"
    echo [INFO] Files removed during uninstall. >> "%logfile%"
)
timeout /t 2 /nobreak >nul
call :remove_exclusion
if exist "%destination%\CLIP STUDIO 1.5\CLIP STUDIO PAINT\CLIPStudioPaint.exe" (
cls
echo Uninstall failed.
timeout /t 1 /nobreak >nul
powershell -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Uninstall failed.','ClipStudio Paint Quick-Installer')"
goto menu
) else (
timeout /t 2 /nobreak >nul
echo Uninstalled.
powershell -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Uninstalled.','ClipStudio Paint Quick-Installer')"
echo [END] %date% %time% >> "%logfile%"
goto menu
)


:gethelp
cls
timeout /t 2 /nobreak >nul
echo If any errors occur during the installation, please try:
echo.
echo 1. Try run as Administrator
echo 2. Temporarily disable your antivirus software.
echo 4. If all the above methods fail, please contact a technician and send installer.log file for assistance.
echo 5. Your data back up at %~dp0%UserData_backup.
echo 6. Put folder CELSYS you backed up before into %~dp0%UserData_backup and use this batch to restore your appdata.
echo.
echo Press any key to go back Menu
pause >nul
cls
goto menu


:backup
cls
echo Backing up your ClipStudio Paint Appdata...
echo [INFO] Starting Appdata backup... >> "%logfile%"
if exist "%appdata%\CELSYSUserData\" (
    xcopy "%appdata%\CELSYSUserData\" "%source%\UserData_Backup\CELSYSUserData\" /E /I /Y >nul
    xcopy "%appdata%\CELSYS\" "%source%\UserData_Backup\CELSYS\" /E /I /Y >nul
    xcopy "%appdata%\CELSYS_EN\" "%source%\UserData_Backup\CELSYS_EN\" /E /I /Y >nul
    echo UserData backup completed.
    echo [SUCCESS] Appdata backed up to %source%\UserData_Backup\ >> "%logfile%"
) else (
    echo UserData not found. Nothing to backup
    echo [WARNING] No Appdata found to backup. >> "%logfile%"
)
echo Press any key to go back menu
pause >nul
cls
goto menu


:restore
cls
echo Restoring your ClipStudio Paint Appdata...
echo [INFO] Starting Appdata restore... >> "%logfile%"
if exist "%source%\UserData_Backup\" (
    xcopy "%source%\UserData_Backup\CELSYS\" "%appdata%\CELSYS\" /E /I /Y >nul
    xcopy "%source%\UserData_Backup\CELSYSUserData\" "%appdata%\CELSYSUserData\" /E /I /Y >nul
    xcopy "%source%\UserData_Backup\CELSYS_EN" "%appdata%\CELSYS_EN\" /E /I /Y >nul
echo UserData restored successfully.
    echo [SUCCESS] Appdata restored to %appdata%\CELSYSUserData\ >> "%logfile%"
) else (
    echo Backup folder not found. Cannot restore.
    echo [ERROR] No backup folder found for restore. >> "%logfile%"
)
echo Press any key to go back menu
pause >nul
cls
goto menu

:check_install
cls
if exist "%destination%\CLIP STUDIO 1.5\CLIP STUDIO PAINT\CLIPStudioPaint.exe" (
    timeout /t 1 /nobreak >nul
    echo [INFO] Program already installed. >> "%logfile%"
    echo Installer detected program has been installed.
	echo Please uninstall it first then try again.
	echo.
    echo Press any key to go back Menu.
    pause >nul
    goto menu
) else (
	goto install
	)

:check_uninstall
cls

if exist "C:\Program Files (x86)\InstallShield Installation Information\{1E4572D2-28BC-4BC9-B743-13DC6CFD71DB}\setup.exe" (
goto uninstall_native
)
if exist "%destination%\CLIP STUDIO 1.5\CLIP STUDIO PAINT\CLIPStudioPaint.exe" (
    timeout /t 1 /nobreak >nul
    echo [INFO] Uninstallation required. >> "%logfile%"
    goto uninstall_nonative
) else (
    timeout /t 1 /nobreak >nul
    echo [INFO] Program not found. Nothing to uninstall. >> "%logfile%"
    echo Program not found. Nothing to uninstall.
    echo Press any key to go back Menu.
    pause >nul
    goto menu
)

:check_delete
cls
if exist "%appdata%\CELSYSUserData\" (
timeout /t 1 /nobreak >nul
echo [WARNING] This action CANNOT BE UNDONE. Deleted data CANNOT be recovered.
echo Make sure you have backed up your data before.
echo Do you want to delete?
echo 1. Yes
echo 2. No
choice /c 12 /n
if errorlevel 2 goto menu
if errorlevel 1 goto delete
) else (
timeout /t 1 /nobreak >nul
echo CELSYSUserData not found. Nothing to delete.
echo Press any key to go back Menu.
pause >nul
goto menu
)

:delete
cls
timeout /t 1 /nobreak >nul
echo [INFO] Deleting CELSYSUserData... >> "%logfile%"
echo Deleteing...
rmdir /S /Q "%appdata%\CELSYSUserData"
rmdir /S /Q "%appdata%\CELSYS"
rmdir /S /Q "%appdata%\CELSYS_EN"
echo [INFO] Deleted CELSYSUserData. >> "%logfile%"
echo Deleted CELSYSUserData.
timeout /t 1 /nobreak >nul
echo Press any key to go back Menu
pause >nul
goto menu



:add_temp_exclusion
if exist "C:\Program Files\Windows Defender\MpCmdRun.exe" (
    echo Adding ClipStudio Paint.exe to TEMP exclusion list in Windows Defender 
    echo [INFO] Adding exclusion via PowerShell. >> "%logfile%"
	timeout /t 2 /nobreak >nul
    powershell -Command "Start-Process PowerShell -ArgumentList '-ExecutionPolicy Bypass -File \"%source%\main\module\temp_exclusion.ps1\"' -Verb RunAs"
)
timeout /t 2 /nobreak >nul
goto :eof



:remove_temp_exclusion
if exist "C:\Program Files\Windows Defender\MpCmdRun.exe" (
    echo Removing ClipStudio Paint.exe from TEMP exclusion list in Windows Defender 
    echo [INFO] Removing exclusion via PowerShell. >> "%logfile%"
	timeout /t 2 /nobreak >nul
    powershell -Command "Start-Process PowerShell -ArgumentList '-ExecutionPolicy Bypass -File \"%source%\main\module\rm_temp_exclusion.ps1\"' -Verb RunAs"
)
timeout /t 2 /nobreak >nul
goto :eof


:patch
cls
echo Patching...
timeout /t 1 /nobreak >nul
set "zipExe=%source%\main\module\7z.exe"
set "archive=%source%\main\patcher.7z"
set "outdir=%temp%\patcher\"
start "" "%zipExe%" x "%archive%" -p1 -o"%outdir%" -y
call :add_temp_exclusion
timeout /t 1 /nobreak >nul
xcopy "%temp%\patcher\CLIPStudioPaint.exe" "%destination%\CLIP STUDIO 1.5\CLIP STUDIO PAINT\CLIPStudioPaint.exe" /E /I /Y >nul
timeout /t 1 /nobreak >nul
call :remove_temp_exclusion
rmdir /S /Q "%outdir%"
cls
echo Patch completed.
timeout /t 2 /nobreak >nul
cls


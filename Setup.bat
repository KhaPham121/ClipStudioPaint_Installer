@echo off
setlocal enabledelayedexpansion
set "ScriptVersion=1.0.0"
set "source=%~dp0"
set "RegKey=HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{1E4572D2-28BC-4BC9-B743-13DC6CFD71DB}"
set "RegValue=DisplayIcon"
set "logfile=%source%\log.txt"
call :check_registry_key_exist
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
    echo Script will automatically close and auto-rerun with Administrator privileges...
    echo [INFO] Script will auto-rerun as Administrator... >> "%logfile%"
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
echo       ClipStudio Paint EX v4.03 Script by KhaPham.K398
echo ======================================================================
echo.
echo			1. Install ClipStudio Paint EX v4.03
echo			2. Uninstall ClipStudio Paint
echo			3. Apply patch
echo			4. Get help
echo.
echo			5. Manage my ClipStudio Paint Appdata
echo.
echo		X. Exit
echo.
echo ======================================================================
echo.
echo Press the number key to confirm your selection.
choice /c 12345X /n
if errorlevel 6 exit
if errorlevel 5 goto manage_userdata
if errorlevel 4 goto gethelp
if errorlevel 3 goto patch_manually
if errorlevel 2 goto check_uninstall
if errorlevel 1 goto check_install
cls
timeout /t 2 /nobreak >nul

:install
cls
certutil -hashfile "%source%\main\CSP_403w_setup.exe" SHA256 | findstr /i "B304A3DE3EB13B9E8B40F866E50A8E34C6798B79B8E4C70FC7BC9E0C2665E8D0" >nul
if %errorlevel%==0 (
echo Installer hash match. Continuing install...
echo [INFO] Installer hash match. Continuing install... >> "%logfile%"
timeout /t 1 /nobreak >nul
if exist "!destination!" (
rmdir /S /Q "!destination!" >> "%logfile%"
echo [INFO] Previous installation removed. >> "%logfile%"
echo Cleanup successfully.
echo [INFO] Cleanup successfully. >> "%logfile%"
)
timeout /t 1 /nobreak >nul
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
call :check_registry_key_exist
    timeout /t 1 /nobreak >nul
    if exist "!destination!" (
        echo [INFO] Executable found, continuing installation. >> "%logfile%"
        call :add_exclusion
        timeout /t 1 /nobreak >nul
        call :patch
        timeout /t 1 /nobreak >nul
        call :create_shortcut
        echo Installation completed.
        echo [SUCCESS] Installation completed successfully. >> "%logfile%"
        powershell -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Installation successfully.','ClipStudio Paint Quick-Installer')"
        goto menu
    ) else (
        goto failed
    )
) else (
    echo Package installer hash mismatch. Installation aborted.
    echo [ERROR] Package installer hash mismatch. Installation aborted. >> "%logfile%"
    echo Press any key to go back Menu.
    pause >nul
    goto menu
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
    echo Removing ClipStudio Paint.exe from exclusion list from Windows Defender 
    echo [INFO] Removing exclusion via PowerShell. >> "%logfile%"
    powershell -Command "Start-Process PowerShell -ArgumentList '-ExecutionPolicy Bypass -File \"%source%\main\module\rmexclusion.ps1\"' -Verb RunAs"
)
timeout /t 2 /nobreak >nul
goto :eof

:create_shortcut
cls
call :check_registry_key_exist
echo Creating shortcut to Desktop...
echo [INFO] Creating desktop shortcut. >> "%logfile%"
timeout /t 1 /nobreak >nul
powershell -Command "$s=New-Object -ComObject WScript.Shell; $sc=$s.CreateShortcut([Environment]::GetFolderPath('Desktop') + '\ClipStudio Paint.lnk'); $sc.TargetPath='!destination!'; $sc.Save()"
cls
echo Creating shortcut to Desktop...       OK
timeout /t 1 /nobreak >nul
cls
goto :eof

:remove_shortcut
set "shortcut=%USERPROFILE%\Desktop\ClipStudio Paint.lnk"
set "shortcut1=%USERPROFILE%\Desktop\CLIPSTUDIO.lnk"
echo Removing desktop shortcut...
echo [INFO] Attempting to remove shortcut at "%shortcut%" >> "%logfile%"
if exist "%shortcut%" (
    del /f "%shortcut%" >> "%logfile%"
    echo Shortcut removed successfully.
    echo [SUCCESS] Shortcut removed. >> "%logfile%"
) else (
    echo Shortcut not found. Nothing to remove.
    echo [WARNING] No shortcut found to remove. >> "%logfile%"
)
if exist "%shortcut1%" (
    del /f "%shortcut1%" >> "%logfile%"
    echo Shortcut removed successfully.
    echo [SUCCESS] Shortcut removed. >> "%logfile%"
) else (
    echo Shortcut not found. Nothing to remove.
    echo [WARNING] No shortcut found to remove. >> "%logfile%"
)

timeout /t 1 /nobreak >nul
cls
goto :eof


:failed
cls
echo Installation failed. Rolling back...
echo [ERROR] Installation failed, initiating cleanup. >> "%logfile%"
if exist "!destination!" (
    rmdir /S /Q "!destination!" >> "%logfile%"
    echo [INFO] Removed destination folder during rollback. >> "%logfile%"
)
timeout /t 2 /nobreak >nul
powershell -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Installation failed. Nothing has changed.','ClipStudio Paint Quick-Installer')"
echo [END] %date% %time% >> "%logfile%"
goto menu

:uninstall_native
timeout /t 1 /nobreak >nul
cls
echo Uninstalling...
echo [ACTION] Uninstall  >> "%logfile%"
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
if exist "!destination!" (
cls
echo Uninstall failed.
echo [ERROR] Uninstall failed. >> "%logfile%"
timeout /t 1 /nobreak >nul
powershell -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Uninstall failed.','ClipStudio Paint Quick-Installer')"
goto menu
) else (
call :remove_exclusion
timeout /t 1 /nobreak >nul
call :remove_shortcut
timeout /t 1 /nobreak >nul
echo Uninstalled.
echo [INFO] Uninstalled. >> "%logfile%"
timeout /t 1 /nobreak >nul
powershell -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Uninstalled.','ClipStudio Paint Quick-Installer')"
echo [END] %date% %time% >> "%logfile%"
goto menu
)

:unistall_nonative
timeout /t 1 /nobreak >nul
cls
echo Uninstalling...
echo [ACTION] Uninstall nonative >> "%logfile%"
if exist "!destination!" (
    rmdir /S /Q "!destination!" >> "%logfile%"
    echo [INFO] Files removed during uninstall. >> "%logfile%"
)
timeout /t 2 /nobreak >nul
call :remove_exclusion
if exist "!destination!" (
cls
echo Uninstall failed.
echo [ERROR] Uninstall failed. >> "%logfile%"
timeout /t 1 /nobreak >nul
powershell -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Uninstall failed.','ClipStudio Paint Quick-Installer')"
goto menu
) else (
timeout /t 2 /nobreak >nul
echo Uninstalled.
echo [INFO] Uninstalled. >> "%logfile%"
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
echo 4. If all the above methods fail, please contact a technician and send log.txt file for assistance.
echo 5. Your data back up at %~dp0%Backup.
echo 6. Put folder with format Backup_{yyyy-MM-dd_HH-mm-ss} you backed up before into %~dp0%Backup and use this batch to restore your appdata.
echo.
echo Press any key to go back Menu
pause >nul
cls
goto menu

:check_install
cls
if exist "!destination!" (
    timeout /t 1 /nobreak >nul
    echo [INFO] Program already installed. >> "%logfile%"
    echo Script detected program has been installed.
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
if exist "!Destination!" (
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
if errorlevel 2 goto manage_userdata
if errorlevel 1 goto delete_data
) else (
timeout /t 1 /nobreak >nul
echo CELSYSUserData not found. Nothing to delete.
echo [WARN] CELSYSUserData not found >> "%logfile%"
echo Press any key to go back.
pause >nul
goto manage_userdata
)

:delete_data
cls
timeout /t 1 /nobreak >nul
echo [INFO] Deleting CELSYSUserData... >> "%logfile%"
echo Deleteing...
rmdir /S /Q "%appdata%\CELSYSUserData" >> "%logfile%"
rmdir /S /Q "%appdata%\CELSYS" >> "%logfile%"
rmdir /S /Q "%appdata%\CELSYS_EN" >> "%logfile%"
echo [INFO] Deleted CELSYSUserData. >> "%logfile%"
echo Deleted CELSYSUserData.
timeout /t 1 /nobreak >nul
echo Press any key to go back.
pause >nul
goto manage_userdata



:add_temp_exclusion
if exist "C:\Program Files\Windows Defender\MpCmdRun.exe" (
    echo Adding ClipStudio Paint.exe to TEMP exclusion list in Windows Defender 
    echo [INFO] Adding TEMP exclusion via PowerShell. >> "%logfile%"
	timeout /t 2 /nobreak >nul
    powershell -Command "Start-Process PowerShell -ArgumentList '-ExecutionPolicy Bypass -File \"%source%\main\module\temp_exclusion.ps1\"' -Verb RunAs"
)
timeout /t 2 /nobreak >nul
goto :eof



:remove_temp_exclusion
if exist "C:\Program Files\Windows Defender\MpCmdRun.exe" (
    echo Removing ClipStudio Paint.exe from TEMP exclusion list from Windows Defender 
    echo [INFO] Removing TEMP exclusion via PowerShell. >> "%logfile%"
	timeout /t 2 /nobreak >nul
    powershell -Command "Start-Process PowerShell -ArgumentList '-ExecutionPolicy Bypass -File \"%source%\main\module\rm_temp_exclusion.ps1\"' -Verb RunAs"
)
timeout /t 2 /nobreak >nul
goto :eof


:patch
cls
echo Patching...
echo [INFO] Patching started. >> "%logfile%"
timeout /t 1 /nobreak >nul
set "zipExe=%source%\main\module\7z.exe"
set "archive=%source%\main\patcher.7z"
set "outdir=%temp%\patcher\"
call :add_temp_exclusion
start "" "%zipExe%" x "%archive%" -p1 -o"%outdir%" -y
echo [ACTION] Called :add_temp_exclusion. >> "%logfile%"
echo [ACTION] Extracted patcher.7z using 7z.exe. >> "%logfile%"
timeout /t 1 /nobreak >nul
certutil -hashfile "%temp%\patcher\CLIPStudioPaint.exe" SHA256 | findstr /i "F2D662AEB2AD7F5760CFE847ABD3EC55C7578B0071513B6F3EE33B173797A719" >nul
if %errorlevel%==0 (
    echo Hash match. Continuing patch...
	echo [INFO] Hash match. Continuing patch.... >> "%logfile%"
	timeout /t 1 /nobreak >nul
	echo Creating a backup of current executable...
	echo [ACTION] Create a backup of current executable >> "%logfile%"
set "backupPath=!destination:\CLIPStudioPaint.exe=!\CLIPStudioPaint1.exe"
copy /Y "!destination!" "!backupPath!" >> "%logfile%"
echo Replacing CLIPStudioPaint.exe with patched version.
xcopy "%temp%\patcher\CLIPStudioPaint.exe" "!destination!" /E /I /Y >> "%logfile%"
echo [ACTION] Replaced CLIPStudioPaint.exe with patched version. >> "%logfile%"
timeout /t 1 /nobreak >nul
rmdir /S /Q "%outdir%" >> "%logfile%"
echo [ACTION] Cleaned up temporary patch folder. >> "%logfile%"
call :remove_temp_exclusion
echo [ACTION] Called :remove_temp_exclusion. >> "%logfile%"
cls
certutil -hashfile "!destination!" SHA256 | findstr /i "F2D662AEB2AD7F5760CFE847ABD3EC55C7578B0071513B6F3EE33B173797A719" >nul
if %errorlevel%==0 (
echo Deleteting backed up executable...
del /f /q "!backupPath!" >> "%logfile%"
echo [ACTION] Delete backed up executable >> "%logfile%"
echo [INFO] Hash match. Patch completed >> "%logfile%"
echo Patch completed.
echo [SUCCESS] Patch completed. >> "%logfile%"
powershell -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Patch completed.','ClipStudio Paint Quick-Installer')"
timeout /t 1 /nobreak >nul
cls
goto :eof
)
) else (
    echo Hash mismatch. Patch aborted.
	echo [INFO] Hash mismatch. Patch aborted. >>"%logfile%"
	rmdir /S /Q "%outdir%" >> "%logfile%"
	call :remove_temp_exclusion
	echo [ACTION] Called :remove_temp_exclusion. >> "%logfile%"
	powershell -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Patch failed.','ClipStudio Paint Quick-Installer')"
	goto menu
)


:patch_manually
cls
timeout /t 1 /nobreak >nul
call :check_registry_key_exist
if exist "!destination!" (
    echo Executable found, patching...
	echo [INFO] Executable found, patching... >> "%logfile%"
	call :add_exclusion
	timeout /t 1 /nobreak >nul
	call :patch
	call :add_exclusion
) else (
		echo Executable not found. Nothing to patch.
		echo [ERROR] Executable not found. Nothing to patch. >> "%logfile%"
		echo Press any key to go back menu
		pause >nul
		goto menu
	)

:manage_userdata
cls
timeout /t 1 /nobreak >nul
echo ======================================================================
echo       ClipStudio Paint EX v4.03 Quick-Installer by KhaPham.K398
echo ======================================================================
echo.
echo 		1. Backup my CLIPStudioPaint UserData
echo 		2. Restore my CLIPStudioPaint UserData
echo 		3. Delete my CLIPStudioPaint UserData
echo.
echo 	X. Go back menu
echo.
echo ======================================================================
choice /c 123X /n
if errorlevel 4 goto menu
if errorlevel 3 goto check_delete
if errorlevel 2 goto restore_data
if errorlevel 1 goto backup_data

:backup_data
cls
timeout /t 1 /nobreak >nul
echo Backing up your CLIPStudioPaint UserData...
echo [INFO] Backing up your CLIPStudioPaint UserData... >> "%logfile%"
set "CSPUserData1=%appdata%\CELSYSUserData"
set "CSPUserData2=%appdata%\CELSYS"
set "DestinationBackup=%source%\Backup"

for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format \"yyyy-MM-dd_HH-mm-ss\""') do set "timestamp=%%i"
set "backupfolder=%DestinationBackup%\Backup_%timestamp%"
set "temp_folder=%DestinationBackup%\TEMP_%timestamp%"
mkdir "%temp_folder%"
echo [ACTION] Created temp folder: %temp_folder% >> "%logfile%"
set "status=OK"

xcopy "%CSPUserData1%" "%temp_folder%\CELSYSUserData\" /E /H /C /I /Y >> "%logfile%"
echo [ACTION] Copied CELSYSUserData to temp folder. >> "%logfile%"
if errorlevel 1 set "status=ERROR"

xcopy "%CSPUserData2%" "%temp_folder%\CELSYS\" /E /H /C /I /Y >> "%logfile%"
echo [ACTION] Copied CELSYS to temp folder. >> "%logfile%"
if errorlevel 1 set "status=ERROR"

set "CSPUserData3="
for /d %%G in ("%appdata%\CELSYS_*") do (
    if /I not "%%~nxG"=="CELSYS" (
        set "CSPUserData3=%%G"
        call xcopy "%%G" "%temp_folder%\%%~nxG\" /E /H /C /I /Y >> "%logfile%"
        call echo [ACTION] Copied %%G to temp folder as %%~nxG. >> "%logfile%"
        if errorlevel 1 set "status=ERROR"
    )
)

if "%status%"=="OK" (
    ren "%temp_folder%" "Backup_%timestamp%"
    echo [ACTION] Renamed temp folder to Backup_%timestamp%. >> "%logfile%"
    set "backupfolder=%DestinationBackup%\Backup_%timestamp%"
    (
        echo backup_time=%timestamp%
        echo folder_list=%CSPUserData1%;%CSPUserData2%;%CSPUserData3%
        echo status=OK
    ) > "%backupfolder%\backup.point"
    echo Backup completed successfully at: %backupfolder%
    echo [INFO] Backup completed successfully at: %backupfolder% >> "%logfile%"
) else (
    rd /s /q "%temp_folder%"
    echo Backup failed. No backup folder was created.
    echo [ERROR] Backup failed. No backup folder was created. >> "%logfile%"
)

echo Press any key to go back.
pause >nul
goto manage_userdata



:restore_data
cls
timeout /t 1 /nobreak >nul
echo ======================================================================
echo                      List backups available:
echo ======================================================================
echo.
set "backup_root=%source%\Backup"
setlocal enabledelayedexpansion
set /a count=0
for /d %%B in ("%backup_root%\Backup_*") do (
    if exist "%%B\backup.point" (
        set /a count+=1
        set "bt="
        set "fl="
        set "status="
        for /f "usebackq tokens=1,* delims==" %%a in ("%%B\backup.point") do (
            if "%%a"=="backup_time" set "bt=%%b"
            if "%%a"=="folder_list" set "fl=%%b"
            if "%%a"=="status" set "status=%%b"
        )
        if "!status!"=="OK" (
            set "datetime=!bt:~0,16!"
            echo !count!. Backup_[!datetime!]
            echo [INFO] Found valid backup: Backup_[!datetime!] >> "%logfile%"
            set "folder!count!=%%B"
        )
        if "!status!"=="ERROR" (
            set "datetime=!bt:~0,16!"
            echo !count!. Backup_[!datetime!]
            echo [ERROR] Found backup with error status: Backup_[!datetime!] >> "%logfile%"
            set "folder!count!=%%B"
        )
    )
)
if !count! EQU 0 (
    echo No valid backup found.
    echo [ERROR] No valid backup found. >> "%logfile%"
    echo Press any key to go back
    pause >nul
    goto manage_userdata
)
echo.
echo ======================================================================
echo Enter the number then press Enter to select backup or 0 to go back:
set /p choice=
if "%choice%"=="0" goto manage_userdata
if not defined folder%choice% (
    echo Invalid select.
    echo [ERROR] Invalid select. >> "%logfile%"
    echo Press any key to return.
    pause >nul
    goto restore_data
)
set "restore_folder=!folder%choice%!"
for %%n in ("!restore_folder!") do set "foldername=%%~nxn"
echo Selected: [!foldername!]
echo [INFO] Selected: [!foldername!] >> "%logfile%"
echo.

set "valid_status="
for /f "usebackq tokens=1,* delims==" %%a in ("!restore_folder!\backup.point") do (
    if "%%a"=="status" set "valid_status=%%b"
)
if /i not "!valid_status!"=="OK" (
    echo Selected backup is not valid for restore.
    echo [ERROR] Selected backup is not valid for restore. >> "%logfile%"
    echo Press any key to return.
    pause >nul
    goto restore_data
)
echo Restoring...
echo [ACTION] Starting restore process for !foldername! >> "%logfile%"
timeout /t 1 >nul
set "target1=%appdata%\CELSYSUserData"
set "target2=%appdata%\CELSYS"
set "restore_status=OK"
if exist "!restore_folder!\CELSYSUserData" (
    xcopy "!restore_folder!\CELSYSUserData" "%target1%\" /E /H /C /I /Y >> "%logfile%"
    echo [ACTION] Restored CELSYSUserData to user folder. >> "%logfile%"
    if errorlevel 1 set "restore_status=ERROR"
) else (
    echo [WARNING] CELSYSUserData not found in backup. Skipping. >> "%logfile%"
)
if exist "!restore_folder!\CELSYS" (
    xcopy "!restore_folder!\CELSYS" "%target2%\" /E /H /C /I /Y >> "%logfile%"
    echo [ACTION] Restored CELSYS to user folder. >> "%logfile%"
    if errorlevel 1 set "restore_status=ERROR"
) else (
    echo [WARNING] CELSYS not found in backup. Skipping. >> "%logfile%"
)
for /d %%G in ("!restore_folder!\CELSYS_*") do (
    set "restore_subfolder=%%~nxG"
    set "target_folder=%appdata%\%%~nxG"
    call xcopy "%%G" "!target_folder!\" /E /H /C /I /Y >> "%logfile%"
    call echo [ACTION] Restored %%~nxG to !target_folder! >> "%logfile%"
    if errorlevel 1 set "restore_status=ERROR"
)
if "!restore_status!"=="OK" (
    echo Restore completed successfully.
    echo [INFO] Restore completed successfully. >> "%logfile%"
) else (
    echo Restore encountered errors. Please verify files manually.
    echo [ERROR] Restore encountered errors. >> "%logfile%"
)
echo.
echo Press any key to return.
pause >nul
goto manage_userdata



:check_registry_key_exist
REG QUERY "%RegKey%" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
for /F "tokens=2*" %%A in ('REG QUERY "%RegKey%" /v %RegValue% 2^>nul') do (
for /F "delims=," %%i in ("%%B") do (
set "destination=%%i"
echo Registry key found. Setting destination from registry key...
echo [INFO] Registry key found. Set destination from registry key. >> "%logfile%"
echo [INFO] Destination is !destination! >> "%logfile%"
)
)
) else (
set "destination=%ProgramFiles%\CELSYS\CLIP STUDIO 1.5\CLIP STUDIO PAINT\CLIPStudioPaint.exe"
echo Registry key not found. Setting destination default...
echo [INFO] Registry key not found. Set destination default. >> "%logfile%"
echo [INFO] Destination is !destination! >> "%logfile%"
)
goto :eof

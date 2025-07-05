@echo off
cls
setlocal enabledelayedexpansion
set "ScriptVersion=1.0.0"
goto :check_administrator_privillage
title ClipStudio Paint Data Helper by KhaPham.K398
:check_administrator_privillage
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Administrator privileges required...
    timeout /t 2 /nobreak >nul
    echo Please try run program with Administrator.
    timeout /t 3 /nobreak >nul
    exit
)
mode con: cols=75 lines=25
title ClipStudio Paint Data Helper by KhaPham.K398


:folder_picker
echo Select your backup location:
set "vbs=%temp%\pickfolder.vbs"
> "%vbs%" echo Set shell = CreateObject("Shell.Application")
>>"%vbs%" echo Set folder = shell.BrowseForFolder(0, "Select your backup location:", 0, 0)
>>"%vbs%" echo If Not folder Is Nothing Then WScript.Echo folder.Self.Path
for /f "delims=" %%i in ('cscript //nologo "%vbs%"') do set "source=%%i"
del "%vbs%"
if defined source (
    echo [OK] Selected: "%source%"
	set "logfile=%source%\log.txt"
	set "CSPUserData1=%appdata%\CELSYSUserData"
	set "CSPUserData2=%appdata%\CELSYS"
	set "DestinationBackup=%source%\Backup"
	set "target1=%appdata%\CELSYSUserData"
	set "target2=%appdata%\CELSYS"
	set "restore_status=OK"
	timeout /t 1 /nobreak >nul
) else (
    echo Destination folder not selected.
	goto folder_picker
)
goto manage_userdata


cls
title ClipStudio Paint Data Helper by KhaPham.K398
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Administrator privileges required...
    echo [ERROR] Administrator privileges required... >> "%logfile%"
    timeout /t 1 /nobreak >nul
    echo Script will automatically close and auto-rerun with Administrator privileges...
    echo [INFO] Script will auto-rerun as Administrator... >> "%logfile%"
    timeout /t 1 /nobreak >nul
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)
mode con: cols=75 lines=25
title ClipStudio Paint Data Helper by KhaPham.K398
goto manage_userdata

:gethelp
cls
timeout /t 1 /nobreak >nul
echo 1. Your data back up at "%source%\Backup".
echo 2. Put folder with format Backup_{yyyy-MM-dd_HH-mm-ss} you backed up before into "%source%\Backup" and use this program to restore your appdata.
echo 3. If you get any trouble, contact technican and send them log.txt file to get assistance.
echo.
echo Press any key to go back Menu
pause >nul
cls
goto manage_userdata

:check_delete
cls
if exist "%appdata%\CELSYSUserData\" (
timeout /t 1 /nobreak >nul
echo [WARNING] This action CANNOT BE UNDONE. Deleted data CANNOT be recovered.
echo Make sure you have backed up your data before.
echo Do you want to delete?
echo [Y] YES			[N] No
choice /c YN /n
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
rmdir /S /Q "!CSPUserData1!" >> "%logfile%"
rmdir /S /Q "!CSPUserData2!" >> "%logfile%"
set "CSPUserData3="
for /d %%G in ("%appdata%\CELSYS_*") do (
    if /I not "%%~nxG"=="CELSYS" (
        set "CSPUserData3=%%G"
        call rmdir /S /Q "%%G" >> "%logfile%"
    )
)
echo [INFO] Deleted CELSYSUserData. >> "%logfile%"
echo Deleted CELSYSUserData.
timeout /t 1 /nobreak >nul
echo Press any key to go back.
pause >nul
goto manage_userdata


:manage_userdata
cls
timeout /t 1 /nobreak >nul
echo ======================================================================
echo     	  ClipStudio Paint Data Helper by KhaPham.K398
echo ======================================================================
echo.
echo		[1]. Backup my CLIPStudioPaint UserData
echo		[2]. Restore my CLIPStudioPaint UserData
echo		[3]. Wipe my current CLIPStudioPaint UserData
echo		[4]. Get help
echo.
echo		[C]. Change location
echo		[X]. Exit
echo.
echo ======================================================================
echo Current location: "%source%"
choice /c 1234XC /n
if errorlevel 6 goto folder_picker
if errorlevel 5 exit
if errorlevel 4 goto gethelp
if errorlevel 3 goto check_delete
if errorlevel 2 goto restore_data
if errorlevel 1 goto check_backup

:check_backup
cls
timeout /t 1 /nobreak >nul
if exist "!CSPUserData1!\" (
    echo CELSYSUserData exists. Proceeding...
    goto backup_data
) else (
    echo CELSYSUserData not found. Nothing to Backup
    echo [ERROR] Folder !CSPUserData1! not found >> "%logfile%"
	echo Press any key to return
    pause >nul
    goto manage_userdata
)

:backup_data
cls
timeout /t 1 /nobreak >nul
echo Found CELSYSUserData
echo [INFO] Found CELSYSUserData >> "%logfile%"
echo Backing up your CLIPStudioPaint UserData...
echo [INFO] Backing up your CLIPStudioPaint UserData... >> "%logfile%"

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
ren "%temp_folder%" "Backup_%timestamp%"
    echo [ACTION] Renamed temp folder to Backup_%timestamp%. >> "%logfile%"
    set "backupfolder=%DestinationBackup%\Backup_%timestamp%"
    (
        echo backup_time=%timestamp%
        echo folder_list=%CSPUserData1%;%CSPUserData2%;%CSPUserData3%
        echo status=ERROR
    ) > "%backupfolder%\backup.point"
    echo Backup completed but encounter ERROR at: %backupfolder%
    echo [INFO] Backup completed but encounter ERROR at: %backupfolder% >> "%logfile%"
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
echo No.		Time				Status
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
            set "datetime=!bt!"
            echo !count!. Backup_[!datetime!]
            echo [INFO] Found valid backup: Backup_[!datetime!] >> "%logfile%"
            set "folder!count!=%%B"
        )
        if "!status!"=="ERROR" (
            set "datetime=!bt!"
            echo !count!. Backup_[!datetime!]			[ ^^! ] 
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
echo [1] Restore			[2] Delete			[0] Back
choice /c 120 /n
if errorlevel 3 goto restore_data
if errorlevel 2 goto check_delete_backup
if errorlevel 1 goto check_overwrite
) else (
echo [1] Restore			[2] Delete			[0] Back
choice /c 120 /n
if errorlevel 3 goto restore_data
if errorlevel 2 goto check_delete_backup
if errorlevel 1 goto check_overwrite
)


:check_overwrite
if exist "!CSPUserData1!" (
echo Detected old appdata >> "%logfile%"
echo This action will overwrite your current app data
echo Do you want to continue?
echo [Y]= YES				[N]= NO
choice /c YN /n
if errorlevel 2 goto restore_data
if errorlevel 1 goto check_restore
) else (
goto check_restore
)

:check_restore
cls
if /i not "!valid_status!"=="OK" (
    echo If you continue to restore, your application may not function properly.
	echo Do you want to continue?
	echo [Y] YES			[N] No
	choice /c YN /n
if errorlevel 2 goto restore_data
if errorlevel 1 goto start_restore
)


:start_restore
set "restore_status1=OK"
set "restore_status2=OK"
set "restore_status3=OK"
echo Restoring...
echo [ACTION] Starting restore process for !foldername! >> "%logfile%"
timeout /t 1 >nul
if exist "!restore_folder!\CELSYS" (
    xcopy "!restore_folder!\CELSYS" "%target2%\" /E /H /C /I /Y >> "%logfile%"
    echo [ACTION] Restored CELSYS to user folder. >> "%logfile%"
    if !errorlevel! GEQ 1 set "restore_status1=ERROR"
) else (
    echo [WARNING] CELSYS not found in backup. Skipping. >> "%logfile%"
	set "restore_status1=ERROR"
)

set "has_subfolder=false"
for /d %%G in ("!restore_folder!\CELSYS_*") do (
    set "has_subfolder=true"
    set "restore_subfolder=%%~nxG"
    set "target_folder=%appdata%\%%~nxG"
    call xcopy "%%G" "!target_folder!\" /E /H /C /I /Y >> "%logfile%"
    call echo [ACTION] Restored %%~nxG to !target_folder! >> "%logfile%"
    if !errorlevel! GEQ 1 set "restore_status2=ERROR"
)
if "!has_subfolder!"=="false" (
    echo [WARNING] CELSYS_* not found in backup. Skipping. >> "%logfile%"
	set "restore_status2=ERROR"
)

if exist "!restore_folder!\CELSYSUserData" (
    xcopy "!restore_folder!\CELSYSUserData" "%target1%\" /E /H /C /I /Y >> "%logfile%"
    echo [ACTION] Restored CELSYSUserData to user folder. >> "%logfile%"
    if !errorlevel! GEQ 1 set "restore_status3=ERROR"
) else (
    echo [WARNING] CELSYSUserData not found in backup. Skipping. >> "%logfile%"
    set "restore_status3=ERROR"
)

if "!restore_status1!!restore_status2!!restore_status3!"=="OKOKOK" (
    set "restore_status=OK"
) else (
    set "restore_status=ERROR"
)

if "!restore_status!"=="OK" (
    echo Restore completed successfully.
    echo [INFO] Restore completed successfully. >> "%logfile%"
) else (
    echo Restore encountered errors. Please verify files manually.
    echo [ERROR] Restore encountered errors. >> "%logfile%"
)
echo Press any key to return.
pause >nul
goto manage_userdata
goto :eof


:check_delete_backup
echo Selected: [!foldername!]
echo [INFO] Selected to delete: [!foldername!] >> "%logfile%"
echo Do you want to delete this backup?
echo [Y] YES		[N] NO
choice /c YN /n
if errorlevel 2 goto restore_data
if errorlevel 1 goto delete_backup

:delete_backup
echo Deleting... [!foldername!]
echo Delete !foldername!  >> "%logfile%"
rmdir /S /Q "!folder%choice%!"  >> "%logfile%"
echo Deleted.
echo Press any key to return.
pause >nul
goto restore_data

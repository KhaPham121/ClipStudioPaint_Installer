@echo off
setlocal enabledelayedexpansion
set "ScriptVersion=1.0.0"
set "source=%~dp0"
set "logfile=%source%\log.txt")
echo [START] %date% %time% >> "%logfile%"
cls
title ClipStudio Paint Data Helper by KhaPham.K398
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
mode con: cols=75 lines=15
title ClipStudio Paint Data Helper by KhaPham.K398
goto manage_userdata

:gethelp
cls
timeout /t 2 /nobreak >nul
echo 1. Your data back up at %~dp0%Backup.
echo 2. Put folder with format Backup_{yyyy-MM-dd_HH-mm-ss} you backed up before into %~dp0%Backup and use this batch to restore your appdata.
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


:manage_userdata
cls
timeout /t 1 /nobreak >nul
echo ======================================================================
echo     	  ClipStudio Paint Data Helper by KhaPham.K398
echo ======================================================================
echo.
echo		1. Backup my CLIPStudioPaint UserData
echo		2. Restore my CLIPStudioPaint UserData
echo		3. Delete my CLIPStudioPaint UserData
echo		4. Get help
echo.
echo		X. Exit
echo.
echo ======================================================================
choice /c 1234X /n
if errorlevel 5 exit
if errorlevel 4 goto gethelp
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

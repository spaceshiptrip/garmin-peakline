@echo off
setlocal

call "%~dp0load-build-config-win.bat"
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

echo Building PeakLine...
call "%SDK_BIN%\monkeyc.bat" -f monkey.jungle -o build.prg -y "%DEVELOPER_KEY%" -d %DEVICE_ID%
if %ERRORLEVEL% neq 0 (
    echo Build failed!
    exit /b 1
)

echo Launching simulator app...
start "" "%SDK_BIN%\monkeydo.bat" build.prg %DEVICE_ID%

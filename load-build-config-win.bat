@echo off

if exist "%~dp0build-config.local.bat" (
    call "%~dp0build-config.local.bat"
)

if not defined DEVICE_ID (
    set "DEVICE_ID=epix2pro51mm"
)

if not defined DEVELOPER_KEY (
    set "DEVELOPER_KEY=%USERPROFILE%\Workspaces\garmin-fenix-simple-intervals\developer_key"
)

if not defined SDK_BIN (
    for /f "delims=" %%D in ('dir /b /ad /o-n "%APPDATA%\Garmin\ConnectIQ\Sdks\connectiq-sdk-win-*" 2^>nul') do (
        if not defined SDK_BIN set "SDK_BIN=%APPDATA%\Garmin\ConnectIQ\Sdks\%%D\bin"
    )
)

if not defined SDK_BIN (
    echo SDK_BIN is not set and no Connect IQ SDK was found under:
    echo %APPDATA%\Garmin\ConnectIQ\Sdks
    echo Create build-config.local.bat from build-config.example.bat.
    exit /b 1
)

if not exist "%SDK_BIN%\monkeyc.bat" (
    echo monkeyc.bat not found at:
    echo %SDK_BIN%\monkeyc.bat
    echo Update SDK_BIN in build-config.local.bat.
    exit /b 1
)

if not exist "%DEVELOPER_KEY%" (
    echo Developer key not found at:
    echo %DEVELOPER_KEY%
    echo Update DEVELOPER_KEY in build-config.local.bat or generate a key there.
    exit /b 1
)

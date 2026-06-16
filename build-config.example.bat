@echo off

rem Copy this file to build-config.local.bat and edit for your workstation.
rem build-config.local.bat is ignored by git.
rem
rem If SDK_BIN is omitted, load-build-config-win.bat auto-detects the latest
rem Connect IQ SDK under %APPDATA%\Garmin\ConnectIQ\Sdks.

rem set "SDK_BIN=%APPDATA%\Garmin\ConnectIQ\Sdks\<installed-sdk-folder>\bin"
set "DEVELOPER_KEY=%USERPROFILE%\Workspaces\garmin-fenix-simple-intervals\developer_key"
set "DEVICE_ID=epix2pro51mm"

@echo off
setlocal

call "%~dp0build-win.bat"
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

echo Deploying to watch...
powershell -ExecutionPolicy Bypass -File "%~dp0deploy-watch.ps1"

@echo off
setlocal

powershell -ExecutionPolicy Bypass -File "%~dp0quick-peakline-deploy.ps1"

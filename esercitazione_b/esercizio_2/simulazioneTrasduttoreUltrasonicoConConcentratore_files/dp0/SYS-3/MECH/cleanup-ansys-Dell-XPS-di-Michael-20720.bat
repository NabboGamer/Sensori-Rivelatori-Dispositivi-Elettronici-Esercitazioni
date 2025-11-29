@echo off
set LOCALHOST=%COMPUTERNAME%
if /i "%LOCALHOST%"=="Dell-XPS-di-Michael" (taskkill /f /pid 9788)
if /i "%LOCALHOST%"=="Dell-XPS-di-Michael" (taskkill /f /pid 17880)
if /i "%LOCALHOST%"=="Dell-XPS-di-Michael" (taskkill /f /pid 9968)
if /i "%LOCALHOST%"=="Dell-XPS-di-Michael" (taskkill /f /pid 20720)

del /F cleanup-ansys-Dell-XPS-di-Michael-20720.bat

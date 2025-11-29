@echo off
set LOCALHOST=%COMPUTERNAME%
if /i "%LOCALHOST%"=="Dell-XPS-di-Michael" (taskkill /f /pid 25476)
if /i "%LOCALHOST%"=="Dell-XPS-di-Michael" (taskkill /f /pid 26096)
if /i "%LOCALHOST%"=="Dell-XPS-di-Michael" (taskkill /f /pid 13956)
if /i "%LOCALHOST%"=="Dell-XPS-di-Michael" (taskkill /f /pid 21156)

del /F cleanup-ansys-Dell-XPS-di-Michael-21156.bat

@echo off
set LOCALHOST=%COMPUTERNAME%
if /i "%LOCALHOST%"=="Dell-XPS-di-Michael" (taskkill /f /pid 24640)
if /i "%LOCALHOST%"=="Dell-XPS-di-Michael" (taskkill /f /pid 26024)
if /i "%LOCALHOST%"=="Dell-XPS-di-Michael" (taskkill /f /pid 1292)
if /i "%LOCALHOST%"=="Dell-XPS-di-Michael" (taskkill /f /pid 3916)

del /F cleanup-ansys-Dell-XPS-di-Michael-3916.bat

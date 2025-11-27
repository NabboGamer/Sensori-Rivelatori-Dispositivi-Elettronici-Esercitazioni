@echo off
set LOCALHOST=%COMPUTERNAME%
if /i "%LOCALHOST%"=="Dell-XPS-di-Michael" (taskkill /f /pid 11748)
if /i "%LOCALHOST%"=="Dell-XPS-di-Michael" (taskkill /f /pid 7764)
if /i "%LOCALHOST%"=="Dell-XPS-di-Michael" (taskkill /f /pid 3456)
if /i "%LOCALHOST%"=="Dell-XPS-di-Michael" (taskkill /f /pid 23004)

del /F cleanup-ansys-Dell-XPS-di-Michael-23004.bat

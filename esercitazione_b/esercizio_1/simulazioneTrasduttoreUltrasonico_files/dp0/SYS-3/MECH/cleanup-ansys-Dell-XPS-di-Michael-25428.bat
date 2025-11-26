@echo off
set LOCALHOST=%COMPUTERNAME%
if /i "%LOCALHOST%"=="Dell-XPS-di-Michael" (taskkill /f /pid 20144)
if /i "%LOCALHOST%"=="Dell-XPS-di-Michael" (taskkill /f /pid 2740)
if /i "%LOCALHOST%"=="Dell-XPS-di-Michael" (taskkill /f /pid 7584)
if /i "%LOCALHOST%"=="Dell-XPS-di-Michael" (taskkill /f /pid 25428)

del /F cleanup-ansys-Dell-XPS-di-Michael-25428.bat

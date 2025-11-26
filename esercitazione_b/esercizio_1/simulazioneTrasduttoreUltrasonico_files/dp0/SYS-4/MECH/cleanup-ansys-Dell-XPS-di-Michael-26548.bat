@echo off
set LOCALHOST=%COMPUTERNAME%
if /i "%LOCALHOST%"=="Dell-XPS-di-Michael" (taskkill /f /pid 22856)
if /i "%LOCALHOST%"=="Dell-XPS-di-Michael" (taskkill /f /pid 21900)
if /i "%LOCALHOST%"=="Dell-XPS-di-Michael" (taskkill /f /pid 26136)
if /i "%LOCALHOST%"=="Dell-XPS-di-Michael" (taskkill /f /pid 26548)

del /F cleanup-ansys-Dell-XPS-di-Michael-26548.bat

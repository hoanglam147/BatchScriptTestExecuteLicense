@echo off
@call "%~dp0\hmp_1\HMPAutomationFinal.exe"
>%~dp0\mainOutput.txt echo %ERRORLEVEL%
exit ERRORLEVEL
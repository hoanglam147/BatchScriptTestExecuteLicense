@echo off
@call "%~dp0\TestOutputMatchCode\Monitor.exe"
>%~dp0\mainOutput.txt echo %ERRORLEVEL%
exit ERRORLEVEL

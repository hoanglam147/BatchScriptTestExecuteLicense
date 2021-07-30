@echo off
@call "%~dp0\TestOutput_PartialRead\Monitor.exe"
>%~dp0\mainOutput.txt echo %ERRORLEVEL%
exit ERRORLEVEL

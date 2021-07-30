@echo off
@call "%~dp0\TestOnOffPower\TestOnOffPower.exe"
>%~dp0\mainOutput.txt echo %ERRORLEVEL%
exit ERRORLEVEL

@echo off
@call "%~dp0\TestOutput_GR_NR_Sucess_Failure_MulRead_NoMatchCode\Monitor.exe"
>%~dp0\mainOutput.txt echo %ERRORLEVEL%
exit ERRORLEVEL

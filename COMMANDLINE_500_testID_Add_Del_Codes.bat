@echo off
For /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c-%%a-%%b)
For /f "tokens=1-2 delims=/:" %%a in ("%TIME%") do (set mytime=%%a%%b)

echo %mydate%-%mytime%
@call TestExecute.exe "D:\GIT\dl.code\SVN_TestComplete\TC_DLCODE\DL.CODE\DL.CODE\DL.CODE.mds" /r /p:DL.CODE /t:"Script|serialDevices|COMMANDLINE_507_testID_Add_Del_Codes" /SilentMode /exportLog:"D:\DL.CODE.Log\%mydate%-%mytime%-%~n0\summary.html" /e
>%~dp0\mainOutput.txt echo %ERRORLEVEL%
exit ERRORLEVEL
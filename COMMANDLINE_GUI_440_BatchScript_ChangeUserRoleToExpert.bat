@echo off
For /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c-%%a-%%b)
For /f "tokens=1-2 delims=/:" %%a in ("%TIME%") do (set mytime=%%a%%b)

echo %mydate%-%mytime%
@call "C:\Program Files (x86)\SmartBear\TestExecute 14\x64\Bin\TestExecute.exe" "C:\Users\test\DiskDriveD\GIT\dl.code\SVN_TestComplete\TC_DLCODE\DL.CODE\DL.CODE\DL.CODE.mds" /r /p:DL.CODE /t:"Script|lib_UserRole|testcaseChangeUserRoleToExpert" /SilentMode /exportLog:"C:\Users\test\DiskDriveD\DL.CODE.Log\%mydate%-%mytime%-%~n0\summary.html" /e
>%~dp0\mainOutput.txt echo %ERRORLEVEL%
>%~dp0\mainOutput.txt echo %ERRORLEVEL%
exit ERRORLEVEL

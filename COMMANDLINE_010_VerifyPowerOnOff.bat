@echo off
CALL "%~dp0\clientSide\clientSide.exe" "VerifyTestPowerOnOffLR"
IF %ERRORLEVEL% EQU 2 GOTO Errors
IF %ERRORLEVEL% EQU 1 GOTO Errors
IF %ERRORLEVEL% EQU 0 GOTO Success
:Errors
echo ReportLog = //192.168.3.104/Users/lhoang/OneDrive - Datalogic S.p.a/TC.DL.CODE.Log/Log.txt >> %qm_AttachmentsFiles%
exit 1
:Success
echo ReportLog = //192.168.3.104/Users/lhoang/OneDrive - Datalogic S.p.a/TC.DL.CODE.Log/Log.txt >> %qm_AttachmentsFiles%
exit 0

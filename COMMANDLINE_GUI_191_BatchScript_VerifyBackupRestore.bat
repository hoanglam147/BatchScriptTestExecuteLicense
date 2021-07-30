@echo off
echo This test is run along with test case ID: COMMANDLINE_190
echo Test result detail please see in test case ID: COMMANDLINE_190
set /p outputResult=<%~dp0\mainOutput.txt
set /a outputResult = %outputResult%
exit %outputResult%

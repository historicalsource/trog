echo off
REM **** DGASML - ASSEMBLES A LIST OF ARGS W/LISTINGS AND THEN LINKS THEM
REM ****	  USING THE LINK FILE TROG.CMD
:BEGIN
if "%1" == "" goto endit
echo Assembling----[%1]----with listing!
gspa %1 -h -l -v10
if errorlevel 1 goto MISTAKE
if "%2" == "" goto linkit
shift
goto BEGIN
:linkit
REM **** GLNKL IS A BATCH FILE, CONTROL IS XFER'D
glnkl TROG
:MISTAKE
echo Assembly Errors found in %1
c:\norton\beep c:\norton\errnote
pause
:endit


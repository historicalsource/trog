echo off
REM **** Copy all TROG files from floppy
C:\NORTON\ASK "Is the correct floppy disk in drive a: [y/n]?",yn
if errorlevel 2 goto TFABORT
echo Copying all TROG files from drive a:
echo.
PCOPY a:\*.* d:\*.* /dc/s/ba/R
PCOPY d:\video\img\*.* e:\video\img\*.* /s/ba/R/x
FA D:\VIDEO\TROG\*.asm /A- /S
FA D:\VIDEO\TROG\*.cmd /A- /S
FA D:\VIDEO\TROG\*.bat /A- /S
FA D:\VIDEO\TROG\*.glo /A- /S
FA D:\VIDEO\TROG\*.lib /A- /S
FA D:\VIDEO\TROG\*.tvs /A- /S
FA D:\VIDEO\TROG\*.h /A- /S
FA D:\VIDEO\*.doc /A- /S
FA D:\VIDEO\TROG\MAKEFILE /A- /S
FA E:\VIDEO\IMG\TROG*.* /A- /S
FA D:\VIDEO\IMG\TROG*.* /A- /S
goto TFEXIT
:TFABORT
echo Floppy upload aborted.
:TFEXIT


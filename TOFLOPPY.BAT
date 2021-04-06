echo off
REM **** Copy all changed TROG files to floppy
C:\NORTON\ASK "Is the correct floppy disk in drive a: [y/n]?",yn
if errorlevel 2 goto TFABORT
C:\NORTON\ASK "Everything on the disk will be DESTROYED! shall I continue [y/n]?",yn
if errorlevel 2 goto TFITHO
echo Clearing floppy disk in Drive A:
zapppled a:\
echo Copying all changed TROG files to floppy.
echo.
PCOPY D:\VIDEO\TROG\*.asm a: /A /B /dc /s /v /ba
PCOPY D:\VIDEO\TROG\*.cmd a: /A /B /dc /s /v /ba
PCOPY D:\VIDEO\TROG\*.bat a: /A /B /dc /s /v /ba
PCOPY D:\VIDEO\TROG\*.glo a: /A /B /dc /s /v /ba
PCOPY D:\VIDEO\TROG\*.lib a: /A /B /dc /s /v /ba
PCOPY D:\VIDEO\TROG\*.tvs a: /A /B /dc /s /v /ba
PCOPY D:\VIDEO\TROG\*.h	 a: /A /B /dc /s /v /ba
PCOPY D:\VIDEO\TROG\makefile a: /A /B /dc /s /v /ba
PCOPY D:\VIDEO\*.doc a: /A /B /dc /s /v /ba
PCOPY E:\VIDEO\IMG\TROG*.IMG a: /A /B /dc /s /v /ba
PCOPY E:\VIDEO\IMG\TROG*.BD* a: /A /B /dc /s /v /ba
PCOPY E:\VIDEO\IMG\TROG*.LOD a: /A /B /dc /s /v /ba
goto TFEXIT
:TFABORT
echo Floppy copy aborted.
goto TFEXIT
:TFITHO
echo I thought so!
:TFEXIT

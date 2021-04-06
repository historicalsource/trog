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
PCOPY D:\VIDEO\TROG\*.asm a: /dc /s /v /ba
PCOPY D:\VIDEO\TROG\*.cmd a: /dc /s /v /ba
PCOPY D:\VIDEO\TROG\*.bat a: /dc /s /v /ba
PCOPY D:\VIDEO\TROG\*.glo a: /dc /s /v /ba
PCOPY D:\VIDEO\TROG\*.lib a: /dc /s /v /ba
PCOPY D:\VIDEO\TROG\*.tvs a: /dc /s /v /ba
PCOPY D:\VIDEO\TROG\*.h	 a: /dc /s /v /ba
PCOPY D:\VIDEO\TROG\makefile a: /dc /s /v /ba
PCOPY D:\VIDEO\*.doc a: /dc /s /v /ba
PCOPY E:\VIDEO\IMG\TROG*.IMG a: /dc /s /v /ba
PCOPY E:\VIDEO\IMG\TROG*.BD* a: /dc /s /v /ba
PCOPY E:\VIDEO\IMG\TROG*.LOD a: /dc /s /v /ba
goto TFEXIT
:TFABORT
echo Floppy copy aborted.
goto TFEXIT
:TFITHO
echo I thought so!
:TFEXIT

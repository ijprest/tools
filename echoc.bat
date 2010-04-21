@echo off
if "%1"=="" goto :usage
if "%1"=="/?" goto :usage
if "%1"=="-?" goto :usage
if /I "%1"=="/h" goto :usage
if /I "%1"=="-h" goto :usage
setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
tcolor 00
set /a BGC=%ERRORLEVEL% / 16 & set /a FGC=%ERRORLEVEL% %% 16 & set LOOKUP=0123456789abcdef
set C=%1
if "!C:~0,1!"=="-" SET C=!LOOKUP:~%BGC%,1!!C:~1,1!
if "!C:~1,1!"=="-" SET C=!C:~0,1!!LOOKUP:~%FGC%,1!
tcolor %C%
for /f "tokens=1,* delims= " %%Q IN ("%*") DO echo.%%R
tcolor !LOOKUP:~%BGC%,1!!LOOKUP:~%FGC%,1!
goto :EOF

:usage
call "%~f0" -f Usage: %~n0 [bgc][fgc] [text]
echo.    Sets text color and echos the specified text.  Color values are 
echo.    the same as the built-in color command (see "color /?").  If 
echo.    either color value is a "-", uses the current console color.
exit /b 1

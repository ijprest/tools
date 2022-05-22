@echo off
if "%1"=="" echo Usage: %~nx0 [bgcolor][fgcolor]&exit /b 1
setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
"%~dp0tcolor.exe" %~1
IF ERRORLEVEL 256 exit /b 1
set COLOR=%ERRORLEVEL%
set /A FG=%COLOR% %% 16
set /A BG=%COLOR% / 16
SET LUT=0123456789ABCDEF
set COLOR=!LUT:~%BG%,1!!LUT:~%FG%,1!
endlocal & set SAVEDCOLORS=%COLOR%;%SAVEDCOLORS%

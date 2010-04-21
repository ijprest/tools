@echo off
setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
if "%~1"=="-?" goto :usage
if "%~1"=="" goto :usage
set TIMEIT=%~n0

:: Determine start time
call :str2time "%TIME%" START

:: Loop over the command-line and run the specified commands
set CMDLINE=%*
  call %CMDLINE%
  goto :donecmd
:cmdline
IF "%1" EQU "" (
  call %CMDLINE%
  goto :donecmd
)
IF "%1" EQU "&" (
  call %CMDLINE%
  set CMDLINE=
  shift
  goto :cmdline
)
IF "%1" EQU "&&" (
  call %CMDLINE%
  if ERRORLEVEL 1 goto :donecmd
  set CMDLINE=
  shift
)
IF "%1" EQU "||" (
  call %CMDLINE%
  if NOT ERRORLEVEL 1 goto :donecmd
  set CMDLINE=
  shift
)
set CMDLINE=%CMDLINE% %1
shift
goto :cmdline
:donecmd

:: Determine stop time
call :str2time "%TIME%" STOP

:: Calculate and display elapsed time
if !STOP! LSS !START! SET /A STOP=!STOP! + 24*60*60
set /A DIFF=!STOP!-!START!
call :time2str "!DIFF!" DISPLAYTIME
echo %TIMEIT%: elapsed time: !DISPLAYTIME!

goto :EOF

:time2str
SET T=%~1
SET /A H=!T! / 60 / 60
SET /A T=!T! - !H!*60*60
SET /A M=!T! / 60
SET /A S=!T! - !M!*60
IF !M! LSS 10 SET M=0!M!
IF !S! LSS 10 SET S=0!S!
set %~2=!H!:!M!:!S!
goto :EOF

:str2time
for /f "tokens=1-3 delims=:." %%Q IN ("%~1") DO (
  set H=%%Q
  set M=%%R
  set S=%%S
  if !H! GTR 0 if "!H:~0,1!"=="0" SET H=!H:~1!
  if !M! GTR 0 if "!M:~0,1!"=="0" SET M=!M:~1!
  if !S! GTR 0 if "!S:~0,1!"=="0" SET S=!S:~1!
  SET /a %~2=!H!*60*60 + !M!*60 + !S!
)
goto :EOF

:usage
echo.%~nx0 - time the execution of the specified command
echo.Usage:	%~nx0 [command]
goto :EOF


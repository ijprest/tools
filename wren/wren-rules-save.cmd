::info	save the current ruleset
@if "%~1"=="/**/" shift /1 & shift /1 & goto %~2 2>nul
@setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
@echo off
set wren.save.name=
set wren.save.file=

setlocal DISABLEDELAYEDEXPANSION & set x=%*
endlocal & set parse.in=%x:!=^!%
if defined parse.in set parse.in=!parse.in:/?=--help!
call %~dp0..\_parse-parameters.cmd "%~f0" !parse.in! || exit /b 1

if not defined wren.save.name if not defined wren.save.file goto :--help
if defined wren.save.file call :saveas "%wren.save.file%" || exit /b 1
if defined wren.save.name (
  if not exist "%LOCALAPPDATA%\wren" mkdir "%LOCALAPPDATA%\wren"
  call :saveas "%LOCALAPPDATA%\wren\%wren.save.name%.rules" || exit /b 1
)
exit /b 0

:--file
:-f
::*	[filename]
::	Save the ruleset to the specified file.
set wren.save.file=%~2
if not defined wren.save.file call :error no filename specified & exit /b 2
if "%wren.save.file:~0,1%"=="-" call :error no filename specified & exit /b 2
set parse.consume=2
exit /b 0

:--name
:-n
::*	[name]
::	Save the ruleset with the specified name.
set wren.save.name=%~2
if not defined wren.save.name call :error no name specified & exit /b 2
if "%wren.save.name:~0,1%"=="-" call :error no name specified & exit /b 2
set parse.consume=2
exit /b 0

:--help
:-h
:-?
::	Show this help text.
call _show-usage.cmd "%~f0" "wren save"
exit /b 2

:error
echo [#{[91mwren: error: %* 1>&2[m[#}
exit /b 1

:saveas
(copy /y "%wren.RULESET%" "%~1" >nul 2>&1) || (call :error unable to save ruleset & exit /b 1)
exit /b 0
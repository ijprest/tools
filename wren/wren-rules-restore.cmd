::info	replace the current ruleset with a previously saved one
@if "%~1"=="/**/" shift /1 & shift /1 & goto %~2 2>nul
@setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
@echo off
set wren.restore.name=
set wren.restore.file=

setlocal DISABLEDELAYEDEXPANSION & set x=%*
endlocal & set parse.in=%x:!=^!%
if defined parse.in set parse.in=!parse.in:/?=--help!
call %~dp0..\_parse-parameters.cmd "%~f0" !parse.in! || exit /b 1

if not defined wren.restore.name if not defined wren.restore.file goto :--help
if defined wren.restore.file call :restorefrom "%wren.restore.file%" || exit /b 1
if defined wren.restore.name (
  if not exist "%LOCALAPPDATA%\wren" mkdir "%LOCALAPPDATA%\wren"
  call :restorefrom "%LOCALAPPDATA%\wren\%wren.restore.name%.rules" || exit /b 1
)
exit /b 0

:--file
:-f
::*	[filename]
::	Restore the ruleset from the specified file.
set wren.restore.file=%~2
if not defined wren.restore.file call :error no filename specified & exit /b 2
if "%wren.restore.file:~0,1%"=="-" call :error no filename specified & exit /b 2
set parse.consume=2
exit /b 0

:--name
:-n
::*	[name]
::	Restore the ruleset with the specified name.
set wren.restore.name=%~2
if not defined wren.restore.name call :error no name specified & exit /b 2
if "%wren.restore.name:~0,1%"=="-" call :error no name specified & exit /b 2
set parse.consume=2
exit /b 0

:--help
:-h
:-?
::	Show this help text.
call _show-usage.cmd "%~f0" "wren restore"
exit /b 2

:error
echo [#{[91mwren: error: %* 1>&2[m[#}
exit /b 1

:restorefrom
(copy /y "%~1" "%wren.RULESET%" >nul 2>&1) || (call :error unable to restore ruleset & exit /b 1)
exit /b 0

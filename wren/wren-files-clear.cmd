::info	clear the current file-list and ruleset
@if "%~1"=="/**/" shift /1 & shift /1 & goto %~2 2>nul
@setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
@echo off
set wren.clear.FILELIST=
set wren.clear.RULESET=
set wren.clear.BOTH=1

setlocal DISABLEDELAYEDEXPANSION & set x=%*
endlocal & set parse.in=%x:!=^!%
set parse.in=!parse.in:/?=--help!
call %~dp0..\_parse-parameters.cmd "%~f0" !parse.in! || exit /b 1

if NOT "%wren.clear.BOTH%%wren.clear.FILELIST%"=="" if exist "%wren.FILELIST%" del "%wren.FILELIST%"
if NOT "%wren.clear.BOTH%%wren.clear.RULESET%"=="" if exist "%wren.RULESET%" del "%wren.RULESET%"
exit /b 0

:--filelist
:-f
::	clear the file-list
set wren.clear.FILELIST=1
set wren.clear.BOTH=
exit /b 0

:--ruleset
:-r
::	clear the ruleset
set wren.clear.RULESET=1
set wren.clear.BOTH=
exit /b 0

:--help
:-h
:-?
::	show this help text
call _show-usage.cmd "%~f0" "wren clear"
exit /b 2

@if "%~1"=="/**/" shift /1 & shift /1 & goto %~2 2>nul
@setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
@echo off
if "%dbgecho%"=="" set dbgecho=^^^> nul echo

:: Parse command-line; see command-line callback routines at the bottom
set DIRONLY=
set PATTERN=
set CHDIR=cd /d
set parse.in=%* & set parse.in=!parse.in:/?=--help! & call "%~dp0_parse-parameters.cmd" "%~f0" !parse.in! || exit /b 1
if "%PATTERN%"=="" goto :--help

:: Perform the fuzzy match
call "%~dp0_fuzzy-match.cmd" /d "%~nx0" "%PATTERN%" || exit /b 3

:: Change directoy
%dbgecho% %CHDIR% %FUZZY_MATCH%
endlocal&%CHDIR% %FUZZY_MATCH%
goto :EOF

:--push
:-p
set CHDIR=pushd
exit /b 0

:--help
call "%~dp0_show-usage.cmd" "%~f0"
exit /b 2

:_pos1 fuzzy-pattern
set PATTERN=%~1
exit /b 0

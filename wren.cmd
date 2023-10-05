::version	0.1
@if "%~1"=="/**/" shift /1 & shift /1 & goto %~2 2>nul
@setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
@echo off
for /f "delims==" %%Q IN ('set wren. 2^>nul') DO set %%Q=
if not exist "%TEMP%\wren" mkdir "%TEMP%\wren"
set wren.FILELIST=%TEMP%\wren\filelist
set wren.RULESET=%TEMP%\wren\ruleset

setlocal DISABLEDELAYEDEXPANSION & set x=%*
endlocal & set parse.in=%x:!=^!%
if defined parse.in set parse.in=!parse.in:/?=--help!
call %~dp0_parse-parameters.cmd "%~f0" !parse.in! || exit /b 1

if "%wren.COMMAND%"=="" call :--help & exit /b 1
if not exist "%~dpn0\%~n0-*-%wren.COMMAND%.cmd" (
  echo [#{[91m%~n0: error: `%wren.COMMAND%` is not a wren command. See `%~n0 --help` 1>&2[m[#}
  exit /b 1
)
for %%Q IN ("%~dpn0\%~n0-*-%wren.COMMAND%.cmd") DO set wren.COMMAND="%%~fQ"
setlocal DISABLEDELAYEDEXPANSION
call %wren.COMMAND% %wren.ARGS% || exit /b 1
endlocal
exit /b 0

@REM if "%wren.PATTERN%"=="" call :error no replacement patterns specified & exit /b 1


:: perl -x "%~f0"

goto :EOF

@REM :--dictionary
@REM :-d
@REM ::	split filename at word boundaries
@REM call :error unimplemented: `%1`
@REM exit /b 2

@REM :--regex
@REM :-r
@REM ::*	"s/pattern/replace/"
@REM ::	perform a regex substitution (Perl format)
@REM set parse.consume=2
@REM set wren.PATTERN=%wren.PATTERN%2~2%2;
@REM exit /b 0

@REM :--zero
@REM :-z
@REM ::	prefix numbers with zeros
@REM set wren.PATTERN=%wren.PATTERN%2~2s/([0-9]+)/000000\1/g;s/^0*([0-9]{5})/\1/g;
@REM exit /b 0

:_pos1
::*	command [args]
::	wren command to execute
set wren.COMMAND=%1
setlocal DISABLEDELAYEDEXPANSION & set x=%parse.remaining%
endlocal & set wren.ARGS=%x:!=^!%
set parse.stop=1
exit /b 0

:--version
:-v
::	show version information
call _show-usage.cmd -v "%~f0"
exit /b 2

:--help
:-h
:-?
::	show this help text
call _show-usage.cmd "%~f0"
echo.
echo.These are the available commands:
echo.
echo manage your file list
call _show-usage.cmd -c "%~dpn0\%~n0-files-*.cmd" "%~n0-files-"
echo.
echo manage the rename ruleset
call _show-usage.cmd -c "%~dpn0\%~n0-rules-*.cmd" "%~n0-rules-"
exit /b 2

:error
echo [#{[91m%~n0: error: %* 1>&2[m[#}
exit /b 1

#!perl
$x = "batmanridesagain";
$x = capitalize_title(join(' ',splitwords($x)));
print "$x\n";

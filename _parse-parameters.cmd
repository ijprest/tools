:: Copyright 2022-2023 Ian Prest -- MIT Licensed
:: _parse-parameters.cmd -- a helper script to parse your batch-file's
:: command-line.  See `_parse-parameters.md` for details.
if "%dbgecho%"=="" set dbgecho=^^^> nul echo
call :define_macros
setlocal DISABLEDELAYEDEXPANSION & %dbgecho% Parsing command-line: %* & endlocal

:: Init
set parse.position=0
set parse.stop=0
if ERRORLEVEL 2 exit /b 1 &:: Exit/fail silently
if "%2"=="" exit /b 0 &:: no parameters
setlocal DISABLEDELAYEDEXPANSION & set x=%*
endlocal & set parse.remaining=%x:!=^!%

:: Parse command-line loop
:parseparm
if "%2"=="" exit /b 0 &:: success!
:: Remove the first parameter from `parse.remaining`; we're careful to maintain
:: the formatting and case of the original command-line.
set parse.remaining=!parse.remaining:%2=/**/!
set parse.remaining=!parse.remaining:* /**/=!
if DEFINED parse.remaining set parse.remaining=!parse.remaining:/**/=%2!
if DEFINED parse.remaining %$strlen% parse.r_size:=%parse.remaining%
if DEFINED parse.remaining (setlocal DISABLEDELAYEDEXPANSION & set x=%*)
if DEFINED parse.remaining (endlocal & set parse.remaining=%x:!=^!%)
if DEFINED parse.remaining set parse.remaining=!parse.remaining:~-%parse.r_size%!
if "%2"=="--" exit /b 0 &:: Stop parsing if we hit `--`
set parse.consume=1
set parse.param=%~2
set parse.test=
%dbgecho% Parsing argument: %~2
setlocal DISABLEDELAYEDEXPANSION & %dbgecho% Remaining: %parse.remaining% & endlocal
if "%parse.param:~0,1%"=="/" set parse.param=-%parse.param:~1%
if "%~2"=="-?" set parse.param=--help
:: Parse switches/flags by jumping to labels with the name of the switch (and
:: exit if the switch returns an error).
setlocal DISABLEDELAYEDEXPANSION & set x=%2 %3 %4 %5 %6 %7 %8 %9
endlocal & set parse.29=%x:!=^!%
setlocal DISABLEDELAYEDEXPANSION & set x=%3 %4 %5 %6 %7 %8 %9
endlocal & set parse.39=%x:!=^!%
if "%parse.param:~0,2%"=="--" (
  call "%~f1" /**/ :%parse.param% !parse.29!
  if !ERRORLEVEL! EQU 1 echo [#{[91m%~n1: error: unrecognized switch `%parse.param%` 1>&2[m[#}
) else if "%parse.param:~0,1%"=="-" (
  set parse.test=%parse.paramflags%
  set parse.test=!parse.test:%parse.param:~1,1%=/**/!
  set parse.test=!parse.test:*/**/=/**/!
  if "!parse.test:~0,4!"=="/**/" (
    setlocal DISABLEDELAYEDEXPANSION
    call "%~f1" /**/ :%parse.param:~0,2% %2 %parse.param:~2% !parse.39!
    endlocal
    if !ERRORLEVEL! EQU 1 echo [#{[91m%~n1: error: unrecognized flag `%parse.param:~0,2%` 1>&2[m[#}
  ) else (
    setlocal DISABLEDELAYEDEXPANSION
    %dbgecho% Parsing flag string: %parse.param:~1%
    call :flags "%~f1" %parse.param% !parse.29!
    endlocal
  )
) else (
  set /a parse.position=!parse.position! + 1
  REM TODO: setlocal DISABLEDELAYEDEXPANSION
  call "%~f1" /**/ :_pos!parse.position! !parse.29!
  REM endlocal
  if !ERRORLEVEL! EQU 1 echo [#{[91m%~n1: error: unrecognized positional argument `%~2` 1>&2[m[#}
)
if ERRORLEVEL 1 exit /b 1 &:: Exit/fail silently
if %parse.consume% GTR 1 if "!parse.test:~0,4!"=="/**/" if not "%parse.param:~2%"=="" set /a parse.consume -= 1
for /L %%Q IN (1 1 %parse.consume%) DO shift /2 &:: Consume parameters
if %parse.stop% EQU 1 exit /b 0
goto :parseparm &:: Loop

:flags
set parse.flags=%2
set parse.flags=%parse.flags:~1%
:flags_loop
set parse.flag=%parse.flags:~0,1%
%dbgecho% Flag: %parse.flag%
set parse.test=%parse.paramflags%
set parse.test=!parse.test:%parse.flag%=/**/!
set parse.test=!parse.test:*/**/=/**/!
if "!parse.test:~0,4!"=="/**/" (
  echo [#{[91m%~n1: error: flag `-%parse.flag%` is not allowed to coalesce in `%2` 1>&2[m[#} & exit /b 1
)
call "%~f1" /**/ :-%parse.flag% %3 %4 %5 %6 %7 %8 %9
if !ERRORLEVEL! EQU 1 echo [#{[91m%~n1: error: unrecognized flag `-%parse.flag%` 1>&2[m[#} & exit /b 1
set parse.flags=%parse.flags:~1%
if "%parse.flags%"=="" goto :EOF
goto :flags_loop

:: Define some macro functions to use elsewhere. These macros are complicated
:: to write (everything needs to be double-escaped), but tend to be *much*
:: faster than `call` for low-level primitives.
:define_macros
set LF=^


:: *** ABOVE 2 BLANK LINES ARE REQUIRED - DO NOT REMOVE ***
set ^"\n=^^^%LF%%LF%^%LF%%LF%^^"

:: Macro: %$strlen% resultvar:={string}
::
:: This implementation of `strlen` uses bit shifts to quickly check for strings
:: from 256-8192 characters.  Below 256 characters, it falls back on a lookup
:: into a long string of hex digits.
set $strlen=for /L %%n in (1 1 2) do if %%n EQU 2 ( %\n%
  for /f "tokens=1,* delims=:" %%1 IN (^"^^!argv^^!^") DO ( %\n%
    set value=%%2%\n%
    set len=0%\n%
    for /L %%A IN (12,-1,8) DO (%\n%
      set /a "len|=1<<%%A"%\n%
      for %%B in (^^!len^^!) do if ^"^^!value:~%%B,1^^!^"==^"^" set /a "len&=~1<<%%A"%\n%
    )%\n%
    for %%B in (^^!len^^!) do set value=^^!value:~%%B,-1^^!FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FFFFFFFFFFFFFFFFEEEEEEEEEEEEEEEEDDDDDDDDDDDDDDDDCCCCCCCCCCCCCCCCBBBBBBBBBBBBBBBBAAAAAAAAAAAAAAAA9999999999999999888888888888888877777777777777776666666666666666555555555555555544444444444444443333333333333333222222222222222211111111111111110000000000000000%\n%
    set /a len+=0x^^!value:~0x1FF,1^^!^^!value:~0xFF,1^^!%\n%
    for %%V IN (^^!len^^!) DO endlocal ^& set %%1=%%V%\n%
  ) %\n%
) else setlocal ENABLEDELAYEDEXPANSION ^& set argv=

goto :EOF

:: _parse-parameters.cmd -- a helper script to parse your batch-file's
:: command-line.  See `_parse-parameters.md` for details.
if "%dbgecho%"=="" set dbgecho=^^^> nul echo
%dbgecho% Parsing command-line: %*

:: Init
set parse.position=0
set parse.remaining=

:: Parse command-line loop
:parseparm
if "%2"=="" exit /b 0 &:: success!
set parse.consume=1
set parse.param=%~2
%dbgecho% Parsing argument: %~2
if "%~2"=="-?" set parse.param=--help
if "%parse.param%"=="--" goto :collectparm &:: Stop parsing if we hit `--`
:: Parse switches/flags by jumping to labels with the name of the switch (and
:: exit if the switch returns an error).
if "%parse.param:~0,2%"=="--" (
  call "%~f1" /**/ :%parse.param% %2 %3 %4 %5 %6 %7 %8 %9
  if !ERRORLEVEL! EQU 1 echo [#{[91m%~n1: error: unrecognized switch `%parse.param%` 1>&2[m[#}
) else if "%parse.param:~0,1%"=="/" (
  call "%~f1" /**/ :-%parse.param:~1% %2 %3 %4 %5 %6 %7 %8 %9
  if !ERRORLEVEL! EQU 1 echo [#{[91m%~n1: error: unrecognized switch `%parse.param%` 1>&2[m[#}
) else if "%parse.param:~0,1%"=="-" (
  call "%~f1" /**/ :%parse.param% %2 %3 %4 %5 %6 %7 %8 %9
  if !ERRORLEVEL! EQU 1 echo [#{[91m%~n1: error: unrecognized switch `%parse.param%` 1>&2[m[#}
) else (
  set /a parse.position=!parse.position! + 1
  call "%~f1" /**/ :_pos!parse.position! %2 %3 %4 %5 %6 %7 %8 %9
  if !ERRORLEVEL! EQU 1 echo [#{[91m%~n1: error: unrecognized positional argument `%parse.param%` 1>&2[m[#}
)
if ERRORLEVEL 1 exit /b 1 &:: Exit/fail silently
for /L %%Q IN (1 1 %parse.consume%) DO shift /2 &:: Consume parameters
goto :parseparm &:: Loop

:: Collect remaining arguments after `--`
:collectparm
shift /2
if "%2"=="" exit /b 0 &:: success!
set parse.remaining=%parse.remaining% %2
goto :collectparm

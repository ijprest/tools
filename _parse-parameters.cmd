::
::_parse-parameters.cmd -- a helper script to parse your batch-file's
::                         command-line.
::
::  To use, the first two lines in your script should be:
::      @if "%~1"=="/**/" shift /1 & shift /1 & goto %~2 2>nul
::      @setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
::
::  Next, add this line to your script to parse the parameters (adjust path to
::  `parse-parameters.cmd` as necessary):
::      set parse.in=%* & set parse.in=!parse.in:/?=--help! & call _parse-parameters.cmd "%~f0" !parse.in! || exit /b 1
::
::  Handling Switches:
::  ------------------
::  In your script, use labelled callbacks to handle a switch/flag. (Note that
::  the parser converts forward slashes `/` to dashes '-'.).  E.g.:
::      :--foo
::      :-f                                  &:: would also handle `/f`
::      echo The --foo switch was parsed
::      exit /b 0
::
::  Handling Positional Arguments:
::  ------------------------------
::  In your script, use `_pos#` callbacks to handle a positional argument, e.g.:
::      :_pos1
::      echo position argument 1 = %1
::      exit /b 0
::
::      :_pos2
::      echo position argument 2 = %1
::      exit /b 0
::
::  Usage Notes:
::  ------------
::  1. Return `0` for success, or `1000` for a fatal error that should silently
::  abort (usually after you report the error yourself), e.g.:
::      exit /b 0                            &:: success!
::      exit /b 1000                         &:: fail; exit silently
::
::  A return value of `1` will result in an `unrecognized switch XXX` error.  So
::  don't return `1` unless you want that error message.
::      exit /b 1                            &:: fail; `unrecognized switch`
::
::  2. In your callbacks, %1 will be the name of the switch/flag or positional
::  argument parsed (as they appear on the command-line), while %2...%9 will
::  be the following arguments.  If you consume additional parameters, you
::  should increase the `parser.consume` as appropriate.  (It will be `1` by
::  default, to consume the switch or positional argument.)
::
::  For example, for this script invocation:
::      my_script.cmd --foo bar positional
::  And these labels:
::      :--foo
::      echo %1 = %2                         &:: `--foo = bar`
::      set parse.consume=2                  &:: to consume `bar`
::      exit /b 0
::
::      :_pos1
::      echo argument = %1                   &:: `argument = positional`
::      exit /b 0
::
::  3. Passing the standard `--` parameter will stop parsing.  Any remaining
::  arguments will be returned in the `parse.remaining` variable.
::
::  4. Note that argument parsing is case-insensitive (due to how CMD.exe
::  handles labels).  If you need case-sensitivity, you can check the case of
::  `%1` in your callback. E.g., to disallow lowercase `-c`, something like:
::      :-C {path}
::      if "%1"=="-c" exit /b 1              &:: `error: unrecognized switch -c`
::      :: your other logic
::      exit /b 0
::
::  Similarly, you can group "similar" callbacks (like the short- and long-name
::  versions of a switch together), and distinguish them by checking `%1`.
::
::  5. The script automatically replaces `-?` and `/?` with `--help` to work
::  around some CMD.exe bugs.  So you only need a single `:--help` callback
::  label. (And you can't distinguish at runtime.)  Unfortunately, this also 
::  applies to the `parse.remaining` arguments.
::
::  6. Something like `--foo=bar` would have the same result as `--foo bar`.
::  Your script can essentially ignore the equals sign.
::
::  7. See also `_show_usage.cmd` for a quick way to print help text.
::
if "%dbgecho%"=="" set dbgecho=^^^> nul echo
%dbgecho% Parsing command-line: %*

set parse.position=0
set parse.remaining=
:: Parse command-line loop
:parseparm
if "%2"=="" goto :doneparm
set parse.consume=1
set parse.param=%~2
%dbgecho% Parsing argument: %~2
if "%~2"=="-?" set parse.param=--help
if "%parse.param%"=="--" goto :collectparm &:: Handle `--` to stop parsing.
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
if ERRORLEVEL 1 exit /b 1
for /L %%Q IN (1 1 %parse.consume%) DO shift /2 &:: Consume parameters
goto :parseparm &:: Loop

:: Collect remaining arguments
:collectparm
shift /2
if "%2"=="" goto :doneparm
set parse.remaining=%parse.remaining% %2
goto :collectparm

:: Success!
:doneparm
exit /b 0

::
::_show_usage.cmd -- Helper script to display automatic "usage" info for your
::                   batch files.
::
::  This helper is meant to be used in combination with `_parse_parameters.cmd`.
::  When used together, it largely automates generating your help/usage text.
::
::  You specify the help text for a switch or positional argument by separating
::  it from the label name with a TAB character (Alt+009).  E.g.:
::
::    :--foo{TAB}help text
::    ...
::    :_pos1{TAB}short-name{TAB}help text
::
::  Then modify your script to call this one like so (adjust the path to
::  `_show-usage.cmd` as necessary):
::    :--help{TAB}shows this help text
::    call _show-usage.cmd "%~f0"
::    exit /b 1000
::
::  This will result in pleasing and standardized help text for your script(s).
::
::  Usage Notes:
::  ------------
::  1. The generated help text also separates the switch/argument from the help
::  text with a TAB character.  However, if your switch names vary greatly in
::  length, the help text might not line up.  You can manually align the text
::  with spaces at the *beginning* of your help text, *after* the TAB character.
::  Eight spaces will get align you to the next tab stop.
::    :--foo{TAB}        help text, aligned with extra spaces
::    ...
::    :--long-name{TAB}help text
::
::  2. If you have two switches that have the same callback, they'll be grouped:
::    :--foo{TAB}help text
::    :-f
::  You only need to specify the help text on the first one.
::
::  3. If your switch consumes an additional argument, you can make the help
::  text look nice by adding an argument name, separated from the switch by a
::  single space:
::    :--foo arg{TAB}help text
::
::  Which will generate help text that looks like this:
::    usage: script.cmd [--foo arg]
::      --foo arg    help text
::
::  If you are grouping multiple flags, only specify the argument on the *last*
::  one (but help text remains on the first one!):
::    :--foo{TAB}help text
::    :-f arg
::
::  4. Even if you don't specify any help text, you'll still get a nice
::  single-line usage header... it just won't elaborate on the purpose of each
::  argument.
::
::  5. There's no word-wrapping or anything (hard to do in a batch-file), so
::  try to keep your help text short.
::
setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
if "%1"=="" exit /b 1
if "%dbgecho%"=="" set dbgecho=^^^> nul echo
%dbgecho% Showing help for %*

set HAS_OPTIONS=0
set OPTIONS=
set OPTION=
set HAS_POSITIONAL=0
set POSITIONAL=
set IN_CALLBACK=0
set HAS_DESCR=0
for /f "tokens=1,2,* delims=	" %%Q IN (%~1) DO (
  set SWITCH=%%~Q
  if !IN_CALLBACK! EQU 1 (
    if NOT "!SWITCH:~0,2!"==":-" (
      set IN_CALLBACK=0
      set OPTIONS=!OPTIONS! [!OPTION!]
      set NAME.OPT.!HAS_OPTIONS!=!OPTION!
    ) else (
      set OPTION=!OPTION!/!SWITCH:~1!
    )
    if not "%%R"=="" set HAS_DESCR=1
  ) else (
    if "!SWITCH:~0,2!"==":-" (
      set /a HAS_OPTIONS=!HAS_OPTIONS!+1
      set IN_CALLBACK=1
      set OPTION=!SWITCH:~1!
      if not "%%R"=="" set HAS_DESCR=1
      set DESCR.OPT.!HAS_OPTIONS!=%%R
    ) else if "!SWITCH:~0,5!"==":_pos" (
      set /a HAS_POSITIONAL=!HAS_POSITIONAL!+1
      if not "%%R"=="" (
        set POSITIONAL=!POSITIONAL! {%%R}
      ) else (
        set POSITIONAL=!POSITIONAL! {arg}
      )
      if not "%%S"=="" set HAS_DESCR=1
      set DESCR.POS.!HAS_POSITIONAL!=%%S
      set NAME.POS.!HAS_POSITIONAL!=%%R
    )
  )
)

::***** Compute the header text
set HEADER=Usage: %~nx1

:: Add options strings
if %HAS_OPTIONS% GTR 1 (
  if %HAS_DESCR% EQU 0 (
    set HEADER=%HEADER%%OPTIONS%
  ) else (
    set HEADER=%HEADER% [options]
  )
) else (
  set HEADER=%HEADER%%OPTIONS%
)
:: Add positional-element strings
if %HAS_POSITIONAL% GTR 0 set HEADER=%HEADER%%POSITIONAL%

::***** Print the header
echo [#{[97m%HEADER%[m[#}

::***** Print the help text for switches & positional arguments
if %HAS_DESCR% EQU 1 (
  for /L %%Q IN (1 1 !HAS_OPTIONS!) DO (
    echo  !NAME.OPT.%%Q!	!DESCR.OPT.%%Q!
  )
  if !HAS_OPTIONS! GTR 0 echo.
  if %HAS_DESCR% EQU 1 for /L %%Q IN (1 1 !HAS_POSITIONAL!) DO (
    echo  {!NAME.POS.%%Q!}	!DESCR.POS.%%Q!
  )
)
exit /b 0

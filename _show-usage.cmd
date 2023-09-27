:: Copyright 2022-2023 Ian Prest -- MIT Licensed
:: _show-usage.cmd -- Helper script to display automatic "usage" info for your
:: batch files.  See `_show-usage.md` for details.
setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
if "%1"=="" exit /b 1
if "%dbgecho%"=="" set dbgecho=^^^> nul echo
call :define_macros
%dbgecho% Showing help for %*
if "%1"=="-v" shift & goto :show_version
if "%1"=="-c" shift & goto :show_commands

set NUMTYPES=2
set TYPENAME.1=switch
set TYPENAME.2=positional
set HAS.1=0
set HAS.2=0
set CURRENT.1=
set CURRENT.2=
set HEADER.NAME=%~nx1
if NOT "%~2"=="" set HEADER.NAME=%~2
set HEADER.1=
set HEADER.2=
set HEADERWRAP.1=/[]
set HEADERWRAP.2=/
set HAS_DESCR=0
set TYPE=0

:: Loop over all the lines in the source batch file, looking for switches
:: (like `:--foo` or `:-f`), and positional arguments (like `:_pos##`).
:: When found, parse out the name and help-text, and store them in NAME.*.##
:: and DESCR.*.##.  Also, handles grouping flags/switches so long as they are
:: back-to-back in the source script.
for /f "tokens=1,* delims=	" %%Q IN (%~1) DO (
  set Q=%%~Q
  if !TYPE! EQU 0 ( REM *** Not in a callback; check for labels that look right
    set NAME=!Q:~1!
    if "!Q:~0,2!"==":-" ( REM *** switch
      set /a TYPE=1
    ) else if "!Q:~0,5!"==":_pos" ( REM *** positional
      set /a TYPE=2
      set /a N=!HAS.2!+1
      set NAME=!NAME:_pos=arg!
      if !N! LSS !Q:~5! (echo [#{[91merror: positional `!Q!` out of sequence order[m[#} & exit /b 1)
    )
    if !TYPE! NEQ 0 for %%T IN (!TYPE!) DO (
      set /a HAS.%%T+=1
      set CURRENT.%%T=!NAME!
      %dbgecho% Found !TYPENAME.%%T!: !NAME!
    )
  ) else for %%T IN (!TYPE!) DO ( REM *** We're in an existing callback
    if "!Q!"=="::*" ( REM *** Positional name
      if %%T EQU 1 (set CURRENT.%%T=!CURRENT.%%T! %%R) else set CURRENT.%%T=%%R
    ) else if "!Q!"=="::" ( REM *** Help text; append
      if not "%%R"=="" (
        for %%Q IN (!HAS.%%T!) DO (
          %dbgecho% Appending help text for !TYPENAME.%%T! %%Q: %%R
          if "!DESCR.%%T.%%Q!"=="" (set DESCR.%%T.%%Q=%%R) else set DESCR.%%T.%%Q=!DESCR.%%T.%%Q! %%R
          set HAS_DESCR=1
        )
      )
    ) else ( REM *** Not help text
      set ALT=0
      if %%T EQU 1 if "!Q:~0,2!"==":-" ( REM *** switch alternate; add
        set ALT=1
        set CURRENT.%%T=!CURRENT.%%T!/!Q:~1!
        %dbgecho% Found switch alternate: !Q:~1!
      )
      if !ALT! EQU 0 ( REM *** not alternate; end of switch callback
        set TYPE=0
        set HEADER.%%T=!HEADER.%%T! !HEADERWRAP.%%T:~1,1!!CURRENT.%%T!!HEADERWRAP.%%T:~2,1!
        set NAME.%%T.!HAS.%%T!=!CURRENT.%%T!
        %dbgecho% Finalized !TYPENAME.%%T!: !CURRENT.%%T!
        set CURRENT.%%T=
      )
    )
  )
)
%dbgecho% #options = %HAS.1%
%dbgecho% #positionals = %HAS.2%

::***** Print the header
if !HAS.1! GTR 3 IF !HAS_DESCR! EQU 1 SET HEADER.1= [options]
set HEADER=Usage: %HEADER.NAME%%HEADER.1%%HEADER.2%
echo [#{[97m%HEADER%[m[#}
if %HAS_DESCR% NEQ 1 exit /b 0 &:: Quick exit if no more work

:: Fall-though; the "show_commands" (-c) switch will start printout here.
:printout

::***** Determine the width of the first column
set namewidth=0
for /L %%T IN (1 1 %NUMTYPES%) DO (
  for /L %%Q IN (1 1 !HAS.%%T!) DO (
    if NOT "!DESCR.%%T.%%Q!"=="" (
      %$strlen% W.%%T.%%Q:=!NAME.%%T.%%Q!
      if !W.%%T.%%Q! gtr !namewidth! set /a namewidth=!W.%%T.%%Q!
    )
  )
)
if %namewidth% LSS 12 set /a namewidth=16-3-2 &::minumim size is 2 tabstops
set /a namewidth+=3 &::add indent

::***** Determine the console size
for /f "tokens=1,2 delims=:" %%Q IN ('mode con:') DO (
  if not "%%R"=="" (
    for /f "tokens=* delims= " %%S IN ("%%Q") DO (
      for /f "tokens=* delims= " %%T IN ("%%R") DO set mode.%%S=%%T
    )
  )
)

::***** Determine the width of the 2nd column
if %mode.Columns% GTR 120 set /a mode.Columns=120 &::& too long is unreadable
set /a textwidth=mode.Columns - %namewidth% - 2
%dbgecho% namewidth=%namewidth%
%dbgecho% mode.Columns=%mode.Columns%
%dbgecho% textwidth=%textwidth%

::***** Print the help text for switches & positional arguments
for /L %%T IN (1 1 %NUMTYPES%) DO (
  set DID_OUTPUT=0
  for /L %%Q IN (1 1 !HAS.%%T!) DO (
    if NOT "!DESCR.%%T.%%Q!"=="" (
      if !DID_OUTPUT! EQU 0 echo.
      set DID_OUTPUT=1
      set /a indent=namewidth - W.%%T.%%Q
      set /P "indent=[!indent!C!NAME.%%T.%%Q!  "<nul
      if "!DESCR.%%T.%%Q!"=="" echo.
      call :wrap %textwidth% %namewidth%+2 DESCR.%%T.%%Q
    )
  )
)

exit /b 0 &:: done!


:: Simple loop over the input file to print version information
:show_version
for /f "tokens=1,* delims=	 " %%Q IN (%~1) DO (
  if "%%~Q"=="::version" (
    set "VERSION=%~nx1 version %%R"
    call :unescape VERSION
    exit /b 0
  )
)
exit /b 1 &:: not found!

:: Print help text for a set of commands
:show_commands
set NUMTYPES=1
set TYPENAME.1=command
set HAS.1=0

for %%Q IN (%1) DO (
  set /a HAS.1=!HAS.1!+1
  set STR=%%~nQ
  set NAME.1.!HAS.1!=!STR!
  if not "%~2"=="" set NAME.1.!HAS.1!=!STR:%~2=!
  for /f "usebackq tokens=1,* delims=	 " %%R IN ("%%~fQ") DO (
    if "%%~R"=="::info" (
      set "DESCR.1.!HAS.1!=%%S "
    )
  )
)
goto :printout
exit /b 0

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

:: Funtion `wrap`; wraps text in %var-name% at the specified width; lines after
:: the first are indented by the specified amount.
:wrap {width} {hanging-indent} {var-name}
set TEXT=!%~3!
set /a width=%~1
set indent=0
:wraploop
set linewidth=%width%
for /L %%Q IN (1 1 80) DO (
  if "!TEXT:~%%Q,1!"=="$" if NOT "!TEXT:~%%Q,2!"=="$$" set /a linewidth+=1
  if %%Q GTR !linewidth! goto :wrapline
)
:wrapline
for /L %%Q IN (%linewidth% -1 1) DO (
  if "!TEXT:~%%Q,1!"=="" (
    if !indent! gtr 0 set TEXT=[!indent!C!TEXT!
    call :unescape TEXT
    set /a indent=%2
    goto :EOF
  )
  if "!TEXT:~%%Q,1!"==" " (
    if !indent! gtr 0 (set LINE=[!indent!C!TEXT:~0,%%Q!) else set LINE=!TEXT:~0,%%Q!
    call :unescape LINE
    set /a indent=%2
    set TEXT=!TEXT:~%%Q!
    set TEXT=!TEXT:~1!
    goto :wraploop
  )
)
goto :EOF

:: Function `unescape`; echoes a line of text, substituting escape sequences
:unescape VARNAME
set "LINE=!%1:$A=^&!"
set "LINE=!LINE:$B=^|!"
set "LINE=!LINE:$C=^(!"
set "LINE=!LINE:$E=!"
set "LINE=!LINE:$F=^)!"
set "LINE=!LINE:$G=^>!"
set "LINE=!LINE:$L=^<!"
set "LINE=!LINE:$S= !"
set "LINE=!LINE:$$=$!"
echo %LINE%
goto :EOF

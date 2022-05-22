@echo off
setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
if "%dbgecho%"=="" set dbgecho=^^^> nul echo

set DIRONLY=
if /I "%~1"=="/d" SET DIRONLY=/D & shift /1
if "%~2"=="" exit /b 1

set SOURCESCRIPT=%~nx1
set FUZZYPATH=%~2
set COLLECTED=%~3
%dbgecho% Performing fuzzy match on: %FUZZYPATH%
if "%FUZZYPATH:~0,1%"=="\" set "COLLECTED=\" & set FUZZYPATH=!FUZZYPATH:~1!
if "%FUZZYPATH:~-1%"=="\" set DIRONLY=/D
:pathloop
for /f "tokens=1,* delims=\" %%Q IN ("%FUZZYPATH%") DO (
  if NOT "!COLLECTED!"=="" IF NOT "!COLLECTED:~-1!"=="\" SET COLLECTED=!COLLECTED!\
  %dbgecho% Split at: !COLLECTED!%%Q
  set Q=%%~Q
  if "!Q:~1!"==":" (
    set COLLECTED=!Q!\
  ) else (
    if NOT "%%R"=="" (set "D=/D") else set D=!DIRONLY!
    call :fuzzy "!COLLECTED!" "!Q!" "!D!" || exit /b 1
    set COLLECTED=!MATCH!
  )
  set FUZZYPATH=%%R
)
if NOT "%FUZZYPATH%"=="" goto :pathloop

:: Success
endlocal & set FUZZY_MATCH=%COLLECTED%
exit /b 0

:fuzzy {root} {fuzzyspec} {dironly}
setlocal
set ROOT=%~1
set TARGET=%~2
set DIRONLY=%~3
:: Check for an exact match
if not "%TARGET%"=="" if exist "%ROOT%%TARGET%" (
  %dbgecho% Exact match: %ROOT%%TARGET%
  endlocal & set "MATCH=%ROOT%%TARGET%"
  goto :EOF
)

:: Calculate the filespec
set FILESPEC=*
set IN=%TARGET%
:fsloop
if "%IN%"=="" goto :fsend
set FILESPEC=%FILESPEC%%IN:~0,1%*
set IN=%IN:~1%
goto :fsloop
:fsend
%dbgecho% Matching: %ROOT%%FILESPEC%

::Find matches
set COUNT=0
set MATCH=
for %DIRONLY% %%Q IN ("%ROOT%%FILESPEC%") DO (
  set /a COUNT=!COUNT!+1
  set MATCH=%%~fQ
)
%dbgecho% Possible matches: !COUNT!

:: Check for error conditions
if %COUNT% LSS 1 (
  echo.[#{[91m%SOURCESCRIPT%: error: no possible matches for `%ROOT%%TARGET%`[m[#}
  exit /b 1
) else if %COUNT% GTR 1 (
  echo.[#{[91m%SOURCESCRIPT%: error: ambiguous match; could be:[m[#}
  for /d %%Q IN ("%ROOT%%FILESPEC%") DO (
    call :printline "%TARGET%" "%%~nxQ"
  )
  exit /b 1
)
endlocal & set MATCH=%MATCH%
goto :EOF

:: Print the name, colorized based on the pattern
:printline {spec} {folder}
set IN=%~1
set FOLDER=%~2
set LINE=
:plloop
if "%IN%"=="" goto :pldone
if /I "%IN:~0,1%"=="%FOLDER:~0,1%" (
  set LINE=!LINE![#{[92m!FOLDER:~0,1![m[#}
  set IN=!IN:~1!
  set FOLDER=!FOLDER:~1!
) else (
  set LINE=!LINE![#{[93m!FOLDER:~0,1![m[#}
  set FOLDER=!FOLDER:~1!
)
goto :plloop
:pldone
echo.    %LINE%[#{[93m!FOLDER![m[#}
goto :EOF

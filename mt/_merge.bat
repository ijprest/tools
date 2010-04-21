@echo off
setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
call %~dp0vars.bat

SET NUM_MERGE=0
SET NUM_THEIRS=0
SET NUM_YOURS=0
SET NUM_CONFLICT=0

:: Do 3-way merge on files that exist in all cases
echo Doing three-way merge:
for /R "%BASE%" %%Q IN (*) DO (
	title Merge:  Merging files: %%~dpQ
	set FILE_BASE=%%Q
	set FILE_THEIRS=!FILE_BASE:%BASE%=%THEIRS%!
	set FILE_YOURS=!FILE_BASE:%BASE%=%YOURS%!
	set FILE_OUT=!FILE_BASE:%BASE%=%OUTPUT%!
	if exist "!FILE_THEIRS!" (
	  if exist "!FILE_YOURS!" (
			call :merge3 "!FILE_BASE!" "!FILE_THEIRS!" "!FILE_YOURS!" "!FILE_OUT!"
	  )
	)
)

echo.SET /A TAKE_YOURS=%%TAKE_YOURS%%+%NUM_YOURS%>>"%~dp0stats.bat"
echo.SET /A TAKE_THEIRS=%%TAKE_THEIRS%%+%NUM_THEIRS%>>"%~dp0stats.bat"
echo.SET /A NUM_MERGE=%%NUM_MERGE%%+%NUM_MERGE%>>"%~dp0stats.bat"
echo.SET /A NUM_CONFLICT=%%NUM_CONFLICT%%+%NUM_CONFLICT%>>"%~dp0stats.bat"
echo.SET /A NUM_MERGECONFLICT=%%NUM_MERGECONFLICT%%+%NUM_CONFLICT%>>"%~dp0stats.bat"

echo Summary:
echo   Theirs: %NUM_THEIRS%
echo   Yours:  %NUM_YOURS%
echo   Merged: %NUM_MERGE%
echo   Conflicts: %NUM_CONFLICT%

goto :EOF


:: merge3 base(1) theirs(2) yours(3) output(4)
:merge3
md "%~dp4" 2> nul

:: compare BASE and THEIRS
fc /B "%~1" "%~2" > nul
if ERRORLEVEL 1 (
  :: BASE and THEIRS are different; compare BASE and YOURS
	fc /B "%~1" "%~3" > nul
	if ERRORLEVEL 1 (
		:: all three files are different; need to do a three-way merge
		echo Merging: %~4
		SET /A NUM_MERGE=!NUM_MERGE!+1
		echo %~2 >> %~dp0merged.txt
		if /I NOT "%~x1"==".lib" (
			"%BC3%" "%~2" "%~3" "%~1" "%~4" /automerge
		)
		if not exist "%~4" (
		  echo .. conflict
		  echo Merge: %~4 >> conflict.txt
		  set /A NUM_CONFLICT=!NUM_CONFLICT!+1
		)
	) else (
		:: BASE and YOURS are the same; just copy THEIRS to OUTPUT
		echo Taking theirs: %~2
		SET /A NUM_THEIRS=!NUM_THEIRS!+1
		copy /y "%~2" "%~4" > nul
		echo %~2 >> %~dp0merged.txt
	)
) else (
	:: BASE and THEIRS are identical; just copy YOURS to OUTPUT
	echo Taking yours: %~3
	SET /A NUM_YOURS=!NUM_YOURS!+1
	copy /y "%~3" "%~4" > nul
)
goto :EOF


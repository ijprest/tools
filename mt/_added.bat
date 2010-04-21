@echo off
setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
call %~dp0vars.bat

SET NUM_THEIRS=0
SET NUM_YOURS=0
set NUM_CONFLICT=0

:: Check for "added" files
echo Checking for files added in: %YOURS%
for /R "%YOURS%" %%Q IN (*) DO (
	title Merge:  Checking for added files: %%~dpQ
	set FILE_YOURS=%%Q
	set FILE_BASE=!FILE_YOURS:%YOURS%=%BASE%!
	set FILE_THEIRS=!FILE_YOURS:%YOURS%=%THEIRS%!
	set FILE_OUT=!FILE_YOURS:%YOURS%=%OUTPUT%!
	
	if not exist "!FILE_BASE!" (
		echo Added: !FILE_YOURS!
		if exist "!FILE_THEIRS!" (
			echo .. also added as !FILE_THEIRS!
			fc /B "!FILE_YOURS!" "!FILE_THEIRS!" > nul
			if ERRORLEVEL 1 (
				echo .. conflict!
				SET /A NUM_CONFLICT=!NUM_CONFLICT!+1
				echo Added1: !FILE_THEIRS! >> %~dp0conflict.txt
				echo Added2: !FILE_YOURS! >> %~dp0conflict.txt
			) else (
				echo .. ok!
				call :add1 "!FILE_YOURS!" "!FILE_OUT!"
				SET /A NUM_YOURS=!NUM_YOURS!+1
			)
		) else (
			call :add1 "!FILE_YOURS!" "!FILE_OUT!"
		  SET /A NUM_YOURS=!NUM_YOURS!+1
		)
	)
)

:: Check for "added" files
echo Checking for files added in: %THEIRS%
for /R "%THEIRS%" %%Q IN (*) DO (
	title Merge:  Checking for added files: %%~dpQ
	set FILE_THEIRS=%%Q
	set FILE_BASE=!FILE_THEIRS:%THEIRS%=%BASE%!
	set FILE_YOURS=!FILE_THEIRS:%THEIRS%=%YOURS%!
	set FILE_OUT=!FILE_THEIRS:%THEIRS%=%OUTPUT%!
	
	if not exist "!FILE_BASE!" (
		if not exist "!FILE_YOURS!" (
			echo Added: !FILE_THEIRS!
		  SET /A NUM_THEIRS=!NUM_THEIRS!+1
			call :add1 "!FILE_THEIRS!" "!FILE_OUT!"
			echo !FILE_THEIRS! >> %~dp0merged.txt
		)
	)
)

echo.SET /A ADDED_THEIRS=%%ADDED_THEIRS%%+%NUM_THEIRS%>>"%~dp0stats.bat"
echo.SET /A ADDED_YOURS=%%ADDED_YOURS%%+%NUM_YOURS%>>"%~dp0stats.bat"
echo.SET /A ADDED_CONFLICT=%%ADDED_CONFLICT%%+%NUM_CONFLICT%>>"%~dp0stats.bat"
echo.SET /A NUM_CONFLICT=%%NUM_CONFLICT%%+%NUM_CONFLICT%>>"%~dp0stats.bat"

echo Summary:
echo   Theirs:   %NUM_THEIRS%
echo   Yours:    %NUM_YOURS%
echo   Conflict: %NUM_CONFLICT%

goto :EOF

:: add1 src dest
:add1
md "%~dp2" 2> nul
copy "%~1" "%~2" > nul
goto :EOF

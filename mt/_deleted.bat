@echo off
setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
call %~dp0vars.bat

SET NUM_DEL=0
set NUM_CONFLICT=0

:: Check for "deleted" files
echo Checking for files deleted:
for /R "%BASE%" %%Q IN (*) DO (
	title Merge:  Checking for deleted files: %%~dpQ
	set FILE_BASE=%%Q
	set FILE_THEIRS=!FILE_BASE:%BASE%=%THEIRS%!
	set FILE_YOURS=!FILE_BASE:%BASE%=%YOURS%!
	set FILE_OUT=!FILE_BASE:%BASE%=%OUTPUT%!
	call :test1 "!FILE_BASE!" "!FILE_THEIRS!" "!FILE_YOURS!"
	call :test1 "!FILE_BASE!" "!FILE_YOURS!" "!FILE_THEIRS!"
)


echo.SET /A DEL_BOTH=%%DEL_BOTH%%+%NUM_DEL%>>"%~dp0stats.bat"
echo.SET /A DEL_CONFLICT=%%DEL_CONFLICT%%+%NUM_CONFLICT%>>"%~dp0stats.bat"
echo.SET /A NUM_CONFLICT=%%NUM_CONFLICT%%+%NUM_CONFLICT%>>"%~dp0stats.bat"

echo Summary:
echo   Deleted: %NUM_DEL%
echo   Conflict: %NUM_CONFLICT%

goto :EOF

:: test1 base(1) theirs(2) yours(3)
:test1
if not exist "%~3" (
	echo Deleted: %~3
	SET /a NUM_DEL=!NUM_DEL!+1
	if exist "%~2" (
		fc /B "%~1" "%~2" > nul
		IF ERRORLEVEL 1 (
			echo .. but was changed in %~2
			echo .. conflict!
			echo Deleted1: %~1 >> %~dp0conflict.txt
			echo Deleted2: %~2 >> %~dp0conflict.txt
			echo Deleted3: %~3 >> %~dp0conflict.txt
			SET /a NUM_CONFLICT=!NUM_CONFLICT!+1
		)
	) else (
	  echo .. also deleted in %~2
	  echo .. OK
	)
)
goto :EOF

@echo off
setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION 
call %~dp0vars.bat

SET NUM_DELETED=0
SET NUM_ADDED=0
SET NUM_CHANGED=0

:: Check for deleted files
echo Checking for deleted files...
for /r "%YOURS%" %%Q IN (*) DO (
  title Merge:  Building change tree [1/2]: %%~dpQ
  set FILE_YOURS=%%Q
	set FILE_OUT=!FILE_YOURS:%YOURS%=%OUTPUT%!
	set FILE_CHANGE=!FILE_YOURS:%YOURS%=%CHANGE%!
	
	if not exist "!FILE_OUT!" (
		call :deleted "!FILE_CHANGE!"
		set /a NUM_DELETED=!NUM_DELETED!+1
	)
)

:: Check for added/changed files
echo Checking for added/changed files...
for /r "%OUTPUT%" %%Q IN (*) DO (
	title Merge:  Building change tree [2/2]: %%~dpQ
  set FILE_OUT=%%Q
	set FILE_YOURS=!FILE_OUT:%OUTPUT%=%YOURS%!
	set FILE_CHANGE=!FILE_OUT:%OUTPUT%=%CHANGE%!
	set FILE_CHANGEBASE=!FILE_OUT:%OUTPUT%=%CHANGEBASE%!
	
	if not exist "!FILE_YOURS!" (
		echo Added: !FILE_CHANGE!
		call :added "!FILE_CHANGE!" "!FILE_OUT!"
		call :added "!FILE_CHANGEBASE!" "!FILE_YOURS!"
		set /a NUM_ADDED=!NUM_ADDED!+1
	) else (
		fc /B "!FILE_OUT!" "!FILE_YOURS!" > nul
		if ERRORLEVEL 1 (
			echo Changed: !FILE_CHANGE!
			call :added "!FILE_CHANGE!" "!FILE_OUT!"
			call :added "!FILE_CHANGEBASE!" "!FILE_YOURS!"
			set /a NUM_CHANGED=!NUM_CHANGED!+1
		)
	)
)

echo Summary:
echo   Deleted: %NUM_DELETED%
echo   Added:   %NUM_ADDED%
echo   Changed: %NUM_CHANGED%

goto :EOF


:deleted
echo Deleted: %~1
md "%~dp1" 2> nul
echo. > "%~dp1DELETE-%~nx1"
goto :EOF

:added
md "%~dp1" 2> nul
copy /y "%~2" "%~1" > nul
goto :EOF

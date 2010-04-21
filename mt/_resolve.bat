@echo off
setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
call %~dp0vars.bat

set ADDED1=
set ADDED2=
set DELETED1=
set DELETED2=
set DELETED3=

:: Do 3-way merge on files that exist in all cases
echo Resolving conflicts:
for /f "tokens=1,* delims= " %%Q IN (conflict.txt) DO (
	if "%%Q"=="Deleted1:" (
	  set DELETED1=%%R
	) else if "%%Q"=="Deleted2:" (
	  set DELETED2=%%R
	) else if "%%Q"=="Deleted3:" (
	  set DELETED3=%%R
	  REM echo Deleted: !DELETED1! !DELETED2! !DELETED3!
		set FILE_OUT=!DELETED1:%BASE%=%OUTPUT%!
	  call :merge3p "!FILE_OUT!"
	) else if "%%Q"=="Added1:" (
	  set ADDED1=%%R
	) else if "%%Q"=="Added2:" (
	  set ADDED2=%%R
	  call :merge2p "!ADDED1!" "!ADDED2!"
	) else if "%%Q"=="Merge:" (
		call :merge3p "%%R"
	)
)
goto :EOF

:merge2p
set FILE_THEIRS=%~1
set FILE_YOURS=%~2
set FILE_OUT=!FILE_YOURS:%YOURS%=%OUTPUT%!
echo Merging: !FILE_OUT!
"%BC3%" "!FILE_THEIRS!" "!FILE_YOURS!" "/mergeoutput=!FILE_OUT!"
goto :EOF

:merge3p
set FILE_OUT=%~1
set FILE_OUT=!FILE_OUT:Merge: =!
set FILE_THEIRS=!FILE_OUT:%OUTPUT%=%THEIRS%!
set FILE_YOURS=!FILE_OUT:%OUTPUT%=%YOURS%!
set FILE_BASE=!FILE_OUT:%OUTPUT%=%BASE%!
call :merge3 "!FILE_BASE!" "!FILE_THEIRS!" "!FILE_YOURS!" "!FILE_OUT!"
goto :EOF

:: merge3 base(1) theirs(2) yours(3) output(4)
:merge3
md "%~dp4" 2> nul
:: all three files are different; need to do a three-way merge
echo Merging: %~4
if /I NOT "%~x1"==".lib" (
	"%BC3%" "%~2" "%~3" "%~1" "%~4"
)
goto :EOF

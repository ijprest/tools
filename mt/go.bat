@echo off
setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
cls

:: Prompt for directory names if necessary
if not exist "%~dp0vars.bat" (
	:: Initialize variables
	color 4f
	echo.Enter the path to Beyond Compare 3:
	call :setp BC3 "" "%ProgramFiles(x86)%\Beyond Compare 3\bcomp.com"
	echo.
	if not exist "!BC3!" echo.Error: file must exist! & exit /B 1

	echo.Enter the BASE folder --- this is the common ancestor of the two branches:
	call :setp BASE "" "%~dp0BASE"
	echo.
	if not exist "!BASE!" echo.Error: folder must exist! & exit /B 1
	
	echo.Enter the THEIRS folder --- this is typically the service-pack branch:
	call :setp THEIRS "" "%~dp0THEIRS"
	echo.
	if not exist "!THEIRS!" echo.Error: folder must exist! & exit /B 1

	echo.Enter the YOURS folder --- this is typically the trunk:
	call :setp YOURS "" "%~dp0YOURS"
	echo.
	if not exist "!YOURS!" echo.Error: folder must exist! & exit /B 1
	
	echo.Enter the OUTPUT folder --- this is where the merged files will be stored:
	call :setp OUTPUT "" "%~dp0OUTPUT"
	echo.
	
	echo.Enter the CHANGE folder --- this is used to construct the change-tree:
	call :setp CHANGE "" "%~dp0CHANGE"
	echo.
	
	echo.Enter the CHANGEBASE folder --- this will contain the 'v1' versions of files in CHANGE:
	call :setp CHANGEBASE "" "%~dp0CHANGEBASE"
	echo.
	
	color 07

	echo.Generating %~dp0vars.bat...
	echo.
	echo.@echo off>"%~dp0vars.bat"
	echo.SET BASE=!BASE:%~dp0=%%~dp0!>>"%~dp0vars.bat"
	echo.SET THEIRS=!THEIRS:%~dp0=%%~dp0!>>"%~dp0vars.bat"
	echo.SET YOURS=!YOURS:%~dp0=%%~dp0!>>"%~dp0vars.bat"
	echo.SET OUTPUT=!OUTPUT:%~dp0=%%~dp0!>>"%~dp0vars.bat"
	echo.SET CHANGE=!CHANGE:%~dp0=%%~dp0!>>"%~dp0vars.bat"
	echo.SET CHANGEBASE=!CHANGEBASE:%~dp0=%%~dp0!>>"%~dp0vars.bat"
	echo.SET BC3=!BC3!>>"%~dp0vars.bat"
) else (
	call "%~dp0vars.bat"
)

if exist "%~dp0conflict.txt" (
	color 4f
	echo.It looks like this isn't the first time you've tried to merge.
	call :setp RESTART "Start from scratch (Y/N)?" "Y"
	echo.
	if /I "!RESTART!"=="Y" (
		del "%~dp0conflict.txt"
		del "%~dp0merged.txt"
	) 
	color 07
)

if not exist "%~dp0conflict.txt" (
	echo.SET DEL_BOTH=0 >"%~dp0stats.bat"
	echo.SET DEL_CONFLICT=0 >>"%~dp0stats.bat"
	echo.SET ADDED_THEIRS=0 >>"%~dp0stats.bat"
	echo.SET ADDED_YOURS=0 >>"%~dp0stats.bat"
	echo.SET ADDED_CONFLICT=0 >>"%~dp0stats.bat"
	echo.SET TAKE_YOURS=0 >>"%~dp0stats.bat"
	echo.SET TAKE_THEIRS=0 >>"%~dp0stats.bat"
	echo.SET NUM_MERGE=0 >>"%~dp0stats.bat"
	echo.SET NUM_MERGECONFLICT=0 >>"%~dp0stats.bat"
	echo.SET NUM_CONFLICT=0 >>"%~dp0stats.bat"
	
	:: Deleted files
	title Merge:  Checking for deleted files...
	call :str2time "!TIME!" START_DELETED
	call "%~dp0_deleted.bat"
	call :str2time "!TIME!" STOP_DELETED
	call :difftime !START_DELETED! !STOP_DELETED!
	echo.SET TIME_DELETED=!DIFFTIME! >>"%~dp0stats.bat"
	echo.
	
	:: Added files
	title Merge:  Checking for added files...
	call :str2time "!TIME!" START_ADDED
	call "%~dp0_added.bat"
	call :str2time "!TIME!" STOP_ADDED
	call :difftime !START_ADDED! !STOP_ADDED!
	echo.SET TIME_ADDED=!DIFFTIME! >>"%~dp0stats.bat"
	echo.

	:: Merge files
	title Merge:  Merging files...
	call :str2time "!TIME!" START_MERGE
	call "%~dp0_merge.bat"
	call :str2time "!TIME!" STOP_MERGE
	call :difftime !START_MERGE! !STOP_MERGE!
	echo.SET TIME_MERGE=!DIFFTIME! >>"%~dp0stats.bat"
	echo.
	
	echo.>>"%~dp0conflict.txt"
	echo.>>"%~dp0merged.txt"
) else (
	echo.Skipping the merge phase...
	echo.
)

:: Resolve any conflicts
if exist "%~dp0conflict.txt" (
	call "%~dp0stats.bat"
	echo NUM_CONFLICT=!NUM_CONFLICT!
	if !NUM_CONFLICT! GTR 0 (
	title Merge:  Resolving conflicts...
	color 4f
	echo.There are a number of conflicts that need to be resolved.
	call :setp RESOLVENOW "Resolve now (Y/N)?" "Y"
	echo.
	color 07
	if /I "!RESOLVENOW!"=="Y" (
		call %~dp0_resolve.bat
		echo.
		)
	)
)

:: Build a change-tree
title Merge:  Building change tree...
color 4f
echo.Merge and conflict-resolution phase complete.
call :setp CHANGENOW "Build/rebuild the change-folders now (Y/N)?" "Y"
echo.
color 07
if /I "!CHANGENOW!"=="Y" (
	if exist "!CHANGE!" rd /s /q "!CHANGE!" 
	if exist "!CHANGEBASE!" rd /s /q "!CHANGEBASE!" 
	call :str2time "!TIME!" START_CHANGETREE
	call %~dp0_changes.bat
	call :str2time "!TIME!" STOP_CHANGETREE
	call :difftime !START_CHANGETREE! !STOP_CHANGETREE!
	echo.SET TIME_CHANGETREE=!DIFFTIME! >>"%~dp0stats.bat"
)

:: Print summary
title Merge:  Done!
call "%~dp0stats.bat"
SET /A ELAPSED=%TIME_ADDED%+%TIME_DELETED%+%TIME_MERGE%+%TIME_CHANGETREE%
call :time2str %ELAPSED% DISPLAYTIME
echo.
echo.Summary statistics:
echo.  Taken:        %TAKE_THEIRS% theirs, %TAKE_YOURS% yours
echo.  Deleted:      %DEL_BOTH% both, %DEL_CONFLICT% conflicts
echo.  Added:        %ADDED_THEIRS% theirs, %ADDED_YOURS% yours, %ADDED_CONFLICT% conflicts
echo.  Merged:       %NUM_MERGE%, %NUM_MERGECONFLICT% conflicts
echo.  Conflicts:    %NUM_CONFLICT%
echo.  Elapsed Time: !DISPLAYTIME!
echo.
color 4f
pause
color 07

goto :EOF
:setp
if "!%~1!"=="" SET %~1=%~3
set /p %~1=%~2 [!%~1!]: 
if "!%~1!"=="" SET %~1=%~3
goto :EOF

:time2str
SET T=%~1
SET /A H=!T! / 60 / 60
SET /A T=!T! - !H!*60*60
SET /A M=!T! / 60
SET /A S=!T! - !M!*60
IF !M! LSS 10 SET M=0!M!
IF !S! LSS 10 SET S=0!S!
set %~2=!H!:!M!:!S!
goto :EOF

:str2time
for /f "tokens=1-3 delims=:." %%Q IN ("%~1") DO (
	set H=%%Q
	set M=%%R
	set S=%%S
	if !H! GTR 0 if "!H:~0,1!"=="0" SET H=!H:~1!
	if !M! GTR 0 if "!M:~0,1!"=="0" SET M=!M:~1!
	if !S! GTR 0 if "!S:~0,1!"=="0" SET S=!S:~1!
	SET /a %~2=!H!*60*60 + !M!*60 + !S!
)
goto :EOF

:difftime
SET START=%~1
SET STOP=%~2
if !STOP! LSS !START! SET /A STOP=!STOP! + 24*60*60
set /A DIFFTIME=!STOP!-!START!
goto :EOF
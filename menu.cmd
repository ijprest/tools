@setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
@echo off

if NOT "%~1"=="" call :parse_cmd %*
if "%menu.selected%"=="" set menu.selected=1

call :default_styles
call :drawmenu
:loop
for /f "delims=" %%Q IN ('getevent') DO (
  if "%%Q"=="`03" (
    REM Ctrl+C
    exit /b -1
  ) else if "%%Q"=="`1b[A" (
    set /A menu.selected -= 1
    if !menu.selected! LSS 1 set menu.selected=1
  ) else if "%%Q"=="`1b[B" (
    set /A menu.selected += 1
    if !menu.selected! GTR !menu.count! set menu.selected=!menu.count!
  ) else if %%Q GTR 0 (
    if %%Q LEQ %menu.count% (
      set menu.selected=%%Q
      for /L %%Q IN (1 1 %menu.count%) DO set /P menu.echo=M<nul
      call :drawmenu
      exit /b %%Q
    )
  ) else if "%%Q"=="`0d" (
    exit /b !menu.selected!
  )
  for /L %%Q IN (1 1 %menu.count%) DO set /P menu.echo=M<nul
  call :drawmenu
)
goto :loop

:drawmenu
for /L %%Q IN (1 1 %menu.count%) DO (
  set menu.draw.pre=%menu.pre%
  set menu.draw.post=%menu.post%
  if %%Q EQU %menu.selected% set menu.draw.pre=%menu.sel.pre%&set menu.draw.post=%menu.sel.post%
  echo.[0K!menu.draw.pre!!menu.%%Q!!menu.draw.post!
)
goto :EOF

:parse_cmd
set menu.count=0
:parse_loop
if "%~1"=="" goto :EOF
set /a menu.count += 1
set menu.%menu.count%=%~1
shift
goto :parse_loop

:default_styles
set menu.pre=    &
set menu.post=
set menu.sel.pre=[#{[7m--^^^> &
set menu.sel.post= ^^^<--[m[#}
goto :EOF
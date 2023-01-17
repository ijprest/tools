@echo off
set BCOMP="C:\Program Files\Beyond Compare 4\BComp.com"
for %%Q IN ("%~dp0*.actual") DO (
  echo Comparing `%%~nQ.expected` to `%%~nxQ`...
  if not exist %%~nQ.expected echo.>%%~nQ.expected
  %BCOMP% /fv="Text Compare" %%~nQ.expected %%~nxQ
)

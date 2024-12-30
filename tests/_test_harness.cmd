:: Check format of test labels
set test.number=0
for /f "tokens=1,2 delims=	" %%Q IN (%~1) DO (
  set LINE=%%Q
  if "!LINE:~0,5!"==":test" (
    if !LINE:~5! LEQ !test.number! (
      echo [#{[91merror: test numbers should always increase: !LINE! 2>&1[m[#}
      exit /b 1
    )
    set test.number=!LINE:~5!
  )
)
set test.start=0
set test.stop=9999
if NOT "%2"=="" set /a test.start=%2
if NOT "%3"=="" set /a test.stop=%3

set /A test.count=0
set test.number=0
set test.fail=0
for /f "tokens=1,2 delims=	" %%Q IN (%~1) DO (
  set LINE=%%Q
  if "!LINE:~0,5!"==":test" (
    set test.number=!LINE:~5!
    if !test.number! GEQ %test.start% (
      if !test.number! LEQ %test.stop% (
        set /a test.count += 1
        <nul set /P PROMPT=[#{[90mTest !test.number!: %%R...[m[#}
        set test.result=1
        call :runtest "%~f1" /**/ %%Q
      ) else (
        echo [#{[90mTest !test.number!: %%R...[37mskipped^^![m[#}
      )
    ) else (
      echo [#{[90mTest !test.number!: %%R...[37mskipped^^![m[#}
    )
  )
)
set /a TEST_PASS=%test.number% - %test.fail%
if %test.fail% NEQ 0 (
  echo [#{[91m%TEST_PASS%/%test.number% tests passed [m[#}
  exit /b 1
)
echo [#{[92m%TEST_PASS%/%test.number% tests passed [m[#}
exit /b 0

:runtest
setlocal DISABLEDELAYEDEXPANSION
set EXPECT_EQ=call %~dp0_expect_eq.cmd
set EXPECT_OUTPUT_EMPTY=call %~dp0_expect_matches.cmd "%~dp1_empty_file.expected" "%~dpn1.test%test.number%.actual"
set EXPECT_OUTPUT_MATCHES=call %~dp0_expect_matches.cmd "%~dpn1.test%test.number%.expected" "%~dpn1.test%test.number%.actual"
call %*
if %test.result% EQU 1 (
  echo [#{[92mpassed! [m[#}
  del "%~dpn1.test%test.number%.actual" 2>nul
)
endlocal & set test.fail=%test.fail%
goto :EOF

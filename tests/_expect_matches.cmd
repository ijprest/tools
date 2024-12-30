:expect_matches
comp /M %~1 %~2 >nul 2>nul && exit /b 0
if %test.result% EQU 1 (echo [#{[91mfailed! [m[#} & set /A test.result=0 & set /A test.fail+=1)
echo [#{[91merror: expected output to match: 1>&2[m[#}
echo [#{[90m^<^<^<^<^<^<^<^<^<^<^<^<^<^<^<^< expected: %1[m[#}
type %1 1>&2
echo [#{[90m^<^<^<^<^<^<^<^<^<^<^<^<^<^<^<^<[m[#}
echo [#{[90m^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^> actual: %2[m[#}
type %2 1>&2
echo [#{[90m^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>^>[m[#}
exit /b 1


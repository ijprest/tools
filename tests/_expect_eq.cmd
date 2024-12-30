:expect_eq
call set test.test="%%%~1%%"=="%~2"
if %test.test% exit /b 0
if %test.result% EQU 1 (echo [#{[91mfailed! [m[#} & set /A test.result=0 & set /A test.fail+=1)
call echo [#{[91merror: expected %~1 (which is `%%%~1%%`) to equal `%~2` 1>&2[m[#}
exit /b 1

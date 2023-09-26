@if "%~1"=="/**/" shift /1 & shift /1 & goto %~2 2>nul
@setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
@echo off
call _test_harness.cmd "%~f0" %1
exit /b %ERRORLEVEL%

REM ****************************************************************************
REM *** Test cases
REM ****************************************************************************
:test1	test positionals
call :parse xxx yyy
%EXPECT_EQ% PARSE_ERRORLEVEL 0
%EXPECT_EQ% POSITIONAL_1 "xxx"
%EXPECT_EQ% POSITIONAL_2 "yyy"
%EXPECT_EQ% POSITIONAL_3 ""
%EXPECT_OUTPUT_EMPTY%
goto :EOF

:test2	test a switch followed by a positional
call :parse --switch xxx
%EXPECT_EQ% PARSE_ERRORLEVEL 0
%EXPECT_EQ% SWITCH_SWITCH "--switch"
%EXPECT_EQ% POSITIONAL_1 "xxx"
%EXPECT_EQ% POSITIONAL_2 ""
%EXPECT_OUTPUT_EMPTY%
goto :EOF

:test3	test a positional followed by a switch
call :parse xxx --switch
%EXPECT_EQ% PARSE_ERRORLEVEL 0
%EXPECT_EQ% SWITCH_SWITCH "--switch"
%EXPECT_EQ% POSITIONAL_1 "xxx"
%EXPECT_EQ% POSITIONAL_2 ""
%EXPECT_OUTPUT_EMPTY%
goto :EOF

:test4	testing a missing switch
call :parse --bad-switch
%EXPECT_EQ% PARSE_ERRORLEVEL 1
%EXPECT_OUTPUT_MATCHES%
goto :EOF

:test5	test a switch that consumes a param
call :parse --pswitch xxx
%EXPECT_EQ% PARSE_ERRORLEVEL 0
%EXPECT_EQ% SWITCH_PSWITCH "--pswitch xxx"
%EXPECT_EQ% POSITIONAL_1 ""
%EXPECT_OUTPUT_EMPTY%
goto :EOF

:test6	test a switch that consumes a param, with '='
call :parse --pswitch=xxx
%EXPECT_EQ% PARSE_ERRORLEVEL 0
%EXPECT_EQ% SWITCH_PSWITCH "--pswitch xxx"
%EXPECT_EQ% POSITIONAL_1 ""
%EXPECT_OUTPUT_EMPTY%
goto :EOF

:test7	test short switch
call :parse -s
%EXPECT_EQ% PARSE_ERRORLEVEL 0
%EXPECT_EQ% SWITCH_SWITCH "-s"
%EXPECT_OUTPUT_EMPTY%
goto :EOF

:test8	test short switch using fwd slash
call :parse /s
%EXPECT_EQ% PARSE_ERRORLEVEL 0
%EXPECT_EQ% SWITCH_SWITCH "/s"
%EXPECT_OUTPUT_EMPTY%
goto :EOF

:test9	test too many positionals
call :parse xxx yyy zzz www
%EXPECT_EQ% PARSE_ERRORLEVEL 1
%EXPECT_OUTPUT_MATCHES%
goto :EOF

:test10	test switch that intentionally fails
call :parse --fail
%EXPECT_EQ% PARSE_ERRORLEVEL 1
%EXPECT_EQ% SWITCH_FAIL "--fail"
%EXPECT_OUTPUT_MATCHES%
goto :EOF

:test11	test '--', parse.remaining
call :parse xxx -- yyy --zzz
%EXPECT_EQ% PARSE_ERRORLEVEL 0
%EXPECT_EQ% POSITIONAL_1 "xxx"
%EXPECT_EQ% POSITIONAL_2 ""
%EXPECT_EQ% parse.remaining " yyy --zzz"
%EXPECT_OUTPUT_EMPTY%
goto :EOF

:test12	test parse.stop
call :parse xxx --stop yyy --zzz
%EXPECT_EQ% PARSE_ERRORLEVEL 0
%EXPECT_EQ% POSITIONAL_1 "xxx"
%EXPECT_EQ% POSITIONAL_2 ""
%EXPECT_EQ% SWITCH_STOP "--stop"
%EXPECT_EQ% SWITCH_STOP_REMAINING " yyy --zzz"
%EXPECT_OUTPUT_EMPTY%
goto :EOF

:test13	test --help
call :parse xxx --help
%EXPECT_EQ% PARSE_ERRORLEVEL 0
%EXPECT_EQ% SWITCH_HELP "--help"
%EXPECT_OUTPUT_EMPTY%
goto :EOF

:test14	test -?
call :parse xxx -?
%EXPECT_EQ% PARSE_ERRORLEVEL 0
%EXPECT_EQ% SWITCH_HELP "-?"
%EXPECT_OUTPUT_EMPTY%
goto :EOF

:test15	test case insensitivity of switches
call :parse --SWITCH
%EXPECT_EQ% PARSE_ERRORLEVEL 0
%EXPECT_EQ% SWITCH_SWITCH "--SWITCH"
%EXPECT_OUTPUT_EMPTY%
goto :EOF

:test16	test paramflags, short
call :parse -j10 xxx
%EXPECT_EQ% PARSE_ERRORLEVEL 0
%EXPECT_EQ% SWITCH_JOBS "-j10 10"
%EXPECT_EQ% POSITIONAL_1 "xxx"
%EXPECT_OUTPUT_EMPTY%
goto :EOF

:test17	test paramflags, long
call :parse --jobs=10 xxx
%EXPECT_EQ% PARSE_ERRORLEVEL 0
%EXPECT_EQ% SWITCH_JOBS "--jobs 10"
%EXPECT_EQ% POSITIONAL_1 "xxx"
%EXPECT_OUTPUT_EMPTY%
goto :EOF

:test18	test paramflags, non-number
call :parse -jxxx yyy
%EXPECT_EQ% PARSE_ERRORLEVEL 0
%EXPECT_EQ% SWITCH_JOBS "-jxxx xxx"
%EXPECT_EQ% POSITIONAL_1 "yyy"
%EXPECT_OUTPUT_EMPTY%
goto :EOF

:test19	test paramflags, short, split
call :parse -j 10 xxx
%EXPECT_EQ% PARSE_ERRORLEVEL 0
%EXPECT_EQ% SWITCH_JOBS "-j 10"
%EXPECT_EQ% POSITIONAL_1 "xxx"
%EXPECT_OUTPUT_EMPTY%
goto :EOF

:test20	test switch that intentionally fails, silently
call :parse --fail-silent
%EXPECT_EQ% PARSE_ERRORLEVEL 1
%EXPECT_EQ% SWITCH_FAIL "--fail-silent"
%EXPECT_OUTPUT_EMPTY%
goto :EOF

:test21	testing a missing short switch
call :parse -p
%EXPECT_EQ% PARSE_ERRORLEVEL 1
%EXPECT_OUTPUT_MATCHES%
goto :EOF

:test22	test switch coalescing
call :parse -abc
%EXPECT_EQ% PARSE_ERRORLEVEL 0
%EXPECT_EQ% FLAG_A "-abc"
%EXPECT_EQ% FLAG_B "-abc"
%EXPECT_EQ% FLAG_C "-abc"
%EXPECT_OUTPUT_EMPTY%
goto :EOF

:test23	test switch coalescing, with an error
call :parse -abpc
%EXPECT_EQ% PARSE_ERRORLEVEL 1
%EXPECT_EQ% FLAG_A "-abpc"
%EXPECT_EQ% FLAG_B "-abpc"
%EXPECT_EQ% FLAG_C ""
%EXPECT_OUTPUT_MATCHES%
goto :EOF

:test24	test switch coalescing, with a non-coalescing switch
call :parse -abjc
%EXPECT_EQ% PARSE_ERRORLEVEL 1
%EXPECT_EQ% FLAG_A "-abjc"
%EXPECT_EQ% FLAG_B "-abjc"
%EXPECT_EQ% FLAG_C ""
%EXPECT_OUTPUT_MATCHES%
goto :EOF

:test25	test parse.stop, empty remaining
call :parse xxx --stop
%EXPECT_EQ% PARSE_ERRORLEVEL 0
%EXPECT_EQ% POSITIONAL_1 "xxx"
%EXPECT_EQ% POSITIONAL_2 ""
%EXPECT_EQ% SWITCH_STOP "--stop"
%EXPECT_EQ% SWITCH_STOP_REMAINING ""
%EXPECT_OUTPUT_EMPTY%
goto :EOF




REM ****************************************************************************
REM *** Helper functions
REM ****************************************************************************
:parse
set parse.paramflags=zjx
set parse.in=%*
set parse.in=!parse.in:/?=--help!
>%~dpn0.test%test.number%.actual 2>&1 call %~dp0..\_parse-parameters.cmd "%~f0" !parse.in!
set PARSE_ERRORLEVEL=%ERRORLEVEL%
exit /b 0


REM ****************************************************************************
REM *** Parsing callbacks
REM ****************************************************************************
:_pos1
set POSITIONAL_1=%1
exit /b 0
:_pos2
set POSITIONAL_2=%1
exit /b 0
:_pos3
set POSITIONAL_3=%1
exit /b 0

:-s
:--switch
set SWITCH_SWITCH=%1
exit /b 0

:--pswitch
set SWITCH_PSWITCH=%1 %2
set parse.consume=2
exit /b 0

:--fail
set SWITCH_FAIL=%1
exit /b 1
:--fail-silent
set SWITCH_FAIL=%1
exit /b 2

:--stop
set SWITCH_STOP=%1
set SWITCH_STOP_REMAINING=%parse.remaining%
set parse.stop=1
exit /b 0

:--help
set SWITCH_HELP=%1
goto :EOF

:-j
:--jobs
set SWITCH_JOBS=%1 %2
set parse.consume=2
exit /b 0

:-a
set FLAG_A=%1
goto :EOF
:-b
set FLAG_B=%1
goto :EOF
:-c
set FLAG_C=%1
goto :EOF

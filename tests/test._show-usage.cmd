@if "%~1"=="/**/" shift /1 & shift /1 & goto %~2 2>nul
@setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
@echo off
mode con cols=80 &:: Set to 80 columns for word-wrapping tests
call _test_harness.cmd "%~f0" %*
exit /b %ERRORLEVEL%

REM ****************************************************************************
REM *** Test cases -- these are all based on sample input files, so they'll
REM *** just fall through to the :usage helper function.
REM ****************************************************************************
:test1	Test empty file
:test2	Test single switch, no help text
:test3	Test switch+flag, no help text
:test4	Test four switches, no help text
:test5	Test single switch, short help text
:test6	Test switch+flag, short help text
:test7	Test four switches, short help text
:test8	Test single switch, long/wrapped help text
:test9	Test single positional, no help text/name
:test10	Test single positional, named, no help text
:test11	Test multiple positionals, no help text
:test12	Test multiple positionals, wrong order
:test13	Test switch with parameter name, no help text
:test14	Test switch with parameter name, short help text
:test15	Test escape sequences
:: fall through

REM ****************************************************************************
REM *** Helper functions
REM ****************************************************************************
:usage
>%~dpn0.test%test.number%.actual 2>&1 call %~dp0..\_show-usage.cmd "%~dpn0.test%test.number%.txt"
set USAGE_ERRORLEVEL=%ERRORLEVEL%
%EXPECT_OUTPUT_MATCHES%
goto :EOF

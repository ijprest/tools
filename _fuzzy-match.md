# `_fuzzy-match.cmd`

`_fuzzy-match.cmd` is a helper script to perform fuzzy file/path matching.

It is intended to be called from other batch files or `doskey` aliases.

## Usage

```cmd
call _fuzzy-match.cmd [/d] "%SOURCE_SCRIPT%" "%FUZZY_PATTERN%" ["%ROOT%"]

              /d  This optional switch indicates that FUZZY_PATTERN refers to a
                  *directory*.  Otherwise, the last segment of the pattern is
                  assumed to match a filename.

   SOURCE_SCRIPT  The name of the script you're calling from; used for error
                  messages.  You would typically use "%~nx0" when calling from
                  another batch-file.

   FUZZY_PATTERN  This the fuzzy pattern to search.

            ROOT  This optional parameter indicates the root directory from
                  which the pattern matching should start.  Otherwise, it starts
                  the match from the current directory.
```

## Return Value
If an error occurs, ERRORLEVEL will be set to a non-zero value.

Otherwise, the matched file/folder will be available in `%FUZZY_MATCH%`.

## Examples:
```cmd
REM Probably matches file: C:\Windows\splwow64.exe
call _fuzzy_match.cmd "%~nx0" c:\win\wow64

REM Probably matches directory: C:\Windows\SysWOW64
call _fuzzy_match.cmd /d "%~nx0" c:\win\wow64

REM Same as above; root of `C:\Windows` was explicitly specified.
call _fuzzy_match.cmd /d "%~nx0" wow64 C:\Windows

REM Probably ambiguous: "Program Files" and "Program Files (x86)"
call _fuzzy_match.cmd /d "%~nx0" c:\prog

REM Exact match: "C:\Program Files"
call _fuzzy_match.cmd /d "%~nx0" "c:\Program Files"

REM Trailing backslash, no `/d` necessary: "C:\Program Files (x86)"
call _fuzzy_match.cmd "%~nx0" c:\prog86\
```

## See Also

Also check out `fcd.cmd`, which is a simple "fuzzy" replacement for
`cd`/`pushd`.

# License (MIT)

Copyright © 2022-2023 Ian Prest

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the “Software”), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

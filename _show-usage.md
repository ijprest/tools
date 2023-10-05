# `_show-usage.cmd`

`_show-usage.cmd` is a helper script to print "help" / "usage" information for
your batch files.

It is intended for use alongside the `_parse_parameters.cmd` script. When used
together, it largely automates generating your help/usage text.

Throughout this documentation the `➡️` glyph will be use to represent a `TAB`
character. Depending on your editor, you may have trouble actually inserting the
`TAB` character. Holding `Alt` and typing `009` on the keypad is a workaround
for some editors.

## Calling the script

`_show-usage.cmd` has several modes in which it can operate:
* [Normal usage](#normal-usage)
* [Listing available commands](#listing-available-subcommands) (`-c`)
* [Displaying version information](#displaying-version-information) (`-v`)
* [Wrapping text](#wrapping-text--w) (`-w`)
* [Wrapping table text](#wrapping-table-text--t) (`-t`)
* [Pre-initializing for performance](#pre-initializing-for-performance) (`-s`)

These modes are described below.

### Normal usage

Typical usage is to call `_show-usage.cmd` from your `--help` callback, like
this (modify the path as necessary):

```cmd
:--help
call _show-usage.cmd "%~f0" "program_name"
exit /b 2
```

This will result in pleasing and standardized help text for your script(s).  The
second parameter is optional, and specifies the program name to use when
printing help text.  If not specified, it will use the filename of the source
script.

See the section below on [specifying help text](#specifying-help-text) for
information on how to annotate your script with help text.

### Listing available subcommands

If you have subcommands, and want to enumerate your subcommands, modify your
`--help` handler to be something like the following:

```cmd
:--help
call _show-usage.cmd "%~f0"
echo.
echo Possible commands:
call _show-usage.cmd -c "%~n0-*.cmd" "%~n0-"
exit /b 2
```

* The first parameter (`-c`) causes `_show-usage.cmd` to enter command-printing
  mode;
* The second parameter (`%~n0-*.cmd`) is the list of sub-command scripts; and
* The third parameter (`%~n0-`) tells `_show-usage.cmd` to strip the specified
  prefix from the command-name.

See also the section below on [specifying help text for
sub-commands](#specifying-help-text-for-sub-commands) for information on how to
annotate your sub-command scripts.

### Displaying version information

You can also optionally call `_show-usage.cmd` from a `--version` callback with
the `-v` switch to cause it to display your script's version information.

```cmd
:--version
call _show-usage.cmd -v "%~f0"
exit /b 2
```

See also the section below on [specifying version
information](#specifying-version-information) for information on how to annotate
your script with version information.

### Wrapping text

`_show-usage.cmd` includes utility functions to print wrapped text, and these
are exposed to your script with the `-w` switch.  You can call it to print one
or more wrapped paragraphs like this:

```cmd
call _show-usage.cmd -w "%~f0" p1
::p1➡️The above command will cause `_show-usage.cmd` to parse your batch file
::p1➡️(`%~f0`) and print out the paragraph labelled `p1`.  Note that this only
::p1➡️prints a single paragraph.
echo.
call _show-usage.cmd -w "%~f0" p2
::p2➡️If you want a second paragraph, you need to invoke `_show-usage.cmd` a
::p2➡️second time with a different paragraph label.
```

You can split your paragraph across multiple lines in your source file for
readability; they will be wrapped to the screen size as necessary.

The paragraph text is typically placed under the call to `_show-usage.cmd`, but this is an arbitrary convention; it can be located anywhere in your batch file.

### Wrapping table text

`_show-usage.cmd` has facilities to display a table of text, which is also
exposed for reuse with the `-t` switch.  You can use it something like this:

```cmd
call _show-usage.cmd -w "%~f0" t1
::t1➡️item1➡️description1; this can be long, and it will wrap as necessary
::t1➡️item2➡️description2; and if you need to split your lines for readability
::t1➡️➡️➡️➡️you can do so.  The number of TABs is arbitrary, so feel free
::t1➡️➡️➡️➡️to line up the text in your editor.
```

Note that this is best used for "definition list" tables; the labels ("item1"
and "item2" in the above example) are not wrapped, and are expected to be
relatively short.

As with wrapped text paragraphs, the table definition is typically placed just
under the call to `_show-usage.cmd`, but it can actually appear anywhere in your
batch file.

### Pre-initializing for performance

If you are calling `_show-usage.cmd` to print a lot of wrapped paragraphs or
tables, it can be helpful to pre-initialize some variables it uses for enhanced
performance.  You can do this by passing the `-s` switch, something like this:

```cmd
REM *** Pre-initalize
call _show-usage.cmd -s

REM *** Display normal help text
call _show-usage.cmd "%~f0" "wren rules"

REM *** Display some additional help in wrapped paragraphs
echo.
call _show-usage.cmd -w "%~f0" p1
echo.
call _show-usage.cmd -w "%~f0" p2
echo.
call _show-usage.cmd -w "%~f0" p3
echo.
call _show-usage.cmd -w "%~f0" p4
```

The pre-initialize step causes some of the more expensive work (specifically the
code to detect your console size) to only be performed once.

## Specifying help text

This helper generates help text by parsing your batch file and looking for
switch/flag and positional-argument callback labels.

Even if you don't specify any help text, you'll still get a nice single-line
usage header that lists all the supported switches & arguments. This might be
sufficient for simple scripts, if the have only a couple of switches whose
purpose can be deduced from the name. However, you can also to provide
additional *help text* for each switch / argument.

Help text is specified on the lines following the callback label. It is
specified by a single colon, followed by a `TAB` character.

### Switches & Flags

To specify a simple help string for your switch / flag:
```cmd
:--foo
:-f
::➡️Help text for --foo and -f.
REM *** Handler for --foo / -f ***
exit /b 0
```

Note that we only needed to provide the help text once for the entire group.
This script will group the flags together when printing the usage information.
If you don't want this grouping behavior, you can avoid it by separating the
two labels by at least one line. The recommended way to do this is using a
`goto`:

```cmd
:--foo
::➡️Help text for `--foo`.
goto :-f
:-f
::➡️This has the same handler as `--foo`, but different help text.
REM *** Handler for --foo / -f ***
exit /b 0
```

If your help text is particularly long, you can break it across multiple lines:

```cmd
:--foo
:-f
::➡️This is a long help string that describes the purpose of the `--foo` / `-f`
::➡️switch.  We've split it across multiple lines for readability.
REM *** Handler for --foo / -f ***
exit /b 0
```

When output, the text will be wrapped to the console width, so feel free to be
as verbose as you like. (Line breaking is only done at spaces. Sorry,
non-Western-language speakers.)

If your switch consumes additional arguments, you can describe this on the line
following the label by starting the line with `::*➡️`.

```cmd
:--foo
:-f
::*➡️arg-name
::➡️This is the help text for `--foo`.  It consumes one additional argument
::➡️named 'arg-name'.
REM *** Handler that consumes an extra argument ***
set parse.consume=2
exit /b 0
```

### Positional arguments

Help text for positional arguments is specified the same way as with switches /
flags. The only difference is that positional arguments should always be named.
(Failure to name the argument will result in an undescriptive/generic default.)
This is done similarly to a switch that consumes additional arguments. E.g.:

```cmd
:_pos1
::*➡️pos-arg-name
::➡️This positional argument is named `pos-arg-name`.
REM *** Handler for `pos-arg-name` ***
exit /b 0
```

Note that positional arguments *must* be specified *in sequence order* in your
script. Failure to do so will result in an error message.

## Specifying version information

If you call the script with `-v` as [described above](#calling-the-script), it
will look for version information encode in your batch file in this format:

```cmd
::version➡️{your version information}
```

This line is *typically* placed near the top of the file with your other header
information, but the script doesn't care about where it appears. The line must
start with `::version`, but everything else is user defined and will unescaped
and be echoed verbatim.

## Specifying help text for sub-commands

If you call the script with `-c` as [described above](#calling-the-script), it
will enumerate your sub-command scripts and look for a short description of the
command embedded within each.  It should be encoded in this format:

```cmd
::info➡️{short description of the command}
```

This line is *typically* placed near the top of the file with your other header
information, but the script doesn't care about where it appears.

## Escape sequences

It is notoriously tricky to write batch files that use certain reserved
characers&nbsp;ampersands, pipe characters, greater-than/less-than, etc. To
make it easier to write your help text, the following escape sequences are
supported (a subset of the escape sequences supported by the built-in `PROMPT`
command):

```
$A   & (Ampersand)
$B   | (pipe)
$C   ( (Left parenthesis)
$E   Escape code (ASCII code 27)
$F   ) (Right parenthesis)
$G   > (greater-than sign)
$L   < (less-than sign)
$S     (space; non-breaking)
$$   $ (dollar sign)
```

Note that these escape sequences are supported in help-text and version-text
only. They are not allowed in switch / flag names or positional-argument names.

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

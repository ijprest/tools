# `_show_usage.cmd`

`_show_usage.cmd` is a helper script to print "help" / "usage" information for
your batch files.

It is intended for use alongside the `_parse_parameters.cmd` script. When used
together, it largely automates generating your help/usage text.

## Calling the script

Typical usage is to call the script from your `--help` callback, like this
(modify the path to `_show-usage.cmd` as necessary):

```cmd
:--help
call _show-usage.cmd "%~f0"
exit /b 2
```

This will result in pleasing and standardized help text for your script(s).

## Specifying help text

This helper generates help text by parsing your batch file and looking for
switch/flag and positional-argument callback labels.

Even if you don't specify any help text, you'll still get a nice single-line
usage header that lists all the supported switches & arguments. This might be
sufficient for simple scripts, if the have only a couple of switches whose
purpose can be deduced from the name. However, you can also to provide
additional *help text* for each switch / argument.

Help text is specified on the lines following the callback label. It is
specified by a single colon, followed by a `Tab` character (which we'll
represent by `➡️` in this documentation). Depending on your editor, you may
have trouble actually inserting the `Tab` character. Holding `Alt` and typing
`009` on the keypad is a workaround that sometimes works.

### Switches & Flags

To specify a simple help string for your switch / flag:
```cmd
:--foo
:-f
:➡️Help text for --foo and -f.
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
:➡️Help text for `--foo`.
goto :-f
:-f
:➡️This has the same handler as `--foo`, but different help text.
REM *** Handler for --foo / -f ***
exit /b 0
```

If your help text is particularly long, you can break it across multiple lines:

```cmd
:--foo
:-f
:➡️This is a long help string that describes the purpose of the `--foo` / `-f`
:➡️switch.  We've split it across multiple lines for readability.
REM *** Handler for --foo / -f ***
exit /b 0
```

When output, the text will be wrapped to the console width, so feel free to be
as verbose as you like. (Line breaking is only done at spaces. Sorry,
non-Western-language speakers.)

If your switch consumes additional arguments, you can describe this by adding a
name to the switch label itself (separated from the name by a single space). If
multiple switches are grouped, only add the argument name to the *last* one.

```cmd
:--foo
:-f arg-name
:➡️This is the help text for `--foo`.  It consumes one additional argument.
:➡️Note that `arg-name` was specified only on the *last* switch in the group.
:➡️This group will be output something like `[--foo/-f arg-name]`.
REM *** Handler that consumes an extra argument ***
set parse.consume=2
exit /b 0
```

### Positional arguments

Help text for positional arguments is specified the same way as with switches /
flags. The only difference is that positional arguments are always named. This
is done similarly to a switch that consumes additional arguments&mdash;by
specifying the argument name next to the callback label, separated by a single
space. E.g.:

```cmd
:_pos1 pos-arg-name
:➡️This positional argument is named `pos-arg-name`.
REM *** Handler for `pos-arg-name` ***
exit /b 0
```

Note that positional arguments *must* be specified *in sequence order* in your
script. Failure to do so will result in an error message.

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

Note that these escape sequences are supported in help-text only. They are not
allowed in switch / flag names or positional-argument names.

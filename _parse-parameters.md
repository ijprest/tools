# `_parse-parameters.cmd`

`_parse-parameters.cmd` is a helper script to parse your batch-file's
command-line.

## Installation

To use, the first two lines in your script should be:

```cmd
@if "%~1"=="/**/" shift /1 & shift /1 & goto %~2 2>nul
@setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
```

Next, add this line to your script to parse the parameters (adjust path to
`parse-parameters.cmd` as necessary):

```cmd
set parse.in=%* & set parse.in=!parse.in:/?=--help! & call _parse-parameters.cmd "%~f0" !parse.in! || exit /b 1
```

## Handling arguments via callbacks

In your script, use labelled callbacks to handle a switch/flag or positional
argument. 

### Switches / flags

For switches and flags, the name of the label is the same as the switch / flag.
E.g., to define a switch named `--foo`, with a short `-f` alias, you would
write the following:

```cmd
:--foo
:-f
echo The `--foo` switch was parsed
exit /b 0
```

Note that the parser converts forward slashes `/` to dashes '-' before calling
your callback). So in the above example, `/f` on the command-line would have
called the `-f` callback.

### Positional arguments

Positional arguments are largely the same, except they callback labels are
`_pos#`, where `#` is the index of the argument. E.g., if you wanted to handle
two positional arguments:

```cmd
:_pos1
set POSITIONAL_ARGUMENT_1=%1
exit /b 0

:_pos2
set POSITIONAL_ARGUMENT_2=%1
exit /b 0
```

### Return values:

Your callbacks should return `0` for success. If you return an error code of
`1`, the parser will print a error message like `unrecognized switch --foo`. To
fail silently (i.e., after you have printed a more appropriate error message),
return a value of `2` or higher.

```cmd
exit /b 0            &:: success!
exit /b 1            &:: fail; prints `unrecognized switch` error message
exit /b 2            &:: fail; exit silently
```

### Switches with parameters

In your callbacks, `%1` will be the name of the switch/flag or positional
argument that was parsed (i.e., as they appear on the command-line), while
`%2`...`%9` will be the following arguments.

For example, this callback defines a switch `--foo` that consumes the next
parameter as its value:

```cmd
:--foo
if "%2"=="" echo error: no value specified for `--foo` & exit /b 2
set FOO=%2
set parse.consume=2   &:: Consume the extra argument.
exit /b 0
```

That this callback set the value of `parse.consume` to `2` to tell the parser
that it consumed the `%2` argument. (The default value of `parse.consume` is
`1`.) In this manner you can consume as many extra arguments as you want.

You can also consume extra arguments from positional-argument callbacks, but in
that case it is usually more straightforward to simply have a second positional
argument.

Note that something like `--foo=bar` would have the same result as `--foo bar`.
In both cases, the `--foo` callback is used, and `%2` will be `bar`.

### Stopping argument parsing

This helper supports the standard `--` parameter to stop argument parsing. Any
remaining arguments will be returned to the caller in the `parse.remaining`
variable.

### Case (in-)sensitivity

Note that argument parsing is *case-insensitive* due to how `cmd.exe` handles
labels and `GOTO`s). If you need case-sensitivity, you can check the case of
`%1` in your callback. E.g., to disallow lowercase `-c`, something like:

```cmd
:-C
if "%1"=="-c" exit /b 1        &:: `error: unrecognized switch -c`
:: your other logic
exit /b 0
```

## Gotchas:

The script automatically replaces `-?` and `/?` with `--help` to work around
some CMD.exe bugs. So you only need a single `:--help` callback label. (And you
can't distinguish at runtime.) Unfortunately, this also applies to the
`parse.remaining` arguments.

## See also
Also check out `_show_usage.cmd` for an easy way to print help/usage text that
integrates nicely with this script.

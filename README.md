# Tools

This repo is a random collection of command-line tools and batch files that
I've written over the years. Most of them were written years ago, and I'm just
getting around to uploading them. Many are outdated and no longer useful, but
collected here for posterity.

## Batch-file helpers

* `_parse-parameters.cmd` is a helper script to parse your batch-file's
command-line. See [documentation](_parse-parameters.md).
* `show-usage.cmd` is a helper script to print "usage" info for your batch
files. See [documentation](_show-usage.md).

## Console-color stuff

This stuff is mostly outdated; in Win10, prefer using ANSI escape sequences
(especially since Terminal now supports
[XTPUSHSGR/XTPOPSGR](https://github.com/microsoft/terminal/issues/1796)).

Might still be useful if you regularly support older versions of Windows. And
even on modern Windows, running `tcolor /ansi /table` is a good way to
visualize the standard ANSI colors available.

* `tcolor.cpp`: changes the Windows console colors; like the built-in `color`
command, but only for new text.
* `echoc.bat`: echos a line of text in the specified color (uses `tcolor.cpp`).

## Misc

* `console-icon.cpp` is a small program to change the icon for the current
console session.
  * Also included are a few colorized versions of the (Vista-era) console icons
  `0b.ico`, `1b.ico`, and `5b.ico`.
  * When I had lots of command-prompt windows, colorizing their icons helped me
  distinguish them on the task-bar and when alt-tabbing.
  * ***No longer works in Win10***... so mainly of historical interest.
* `hash.pl` is a simple perl script that generates MD5 hashes for a file or
recursively on a directory.
* `tidy.xslt` is an XML pretty-printer written in XSLT.
  * Requires an XSLT processor; was written and tested against MSXML6.
* `timeit.bat` is a script that measures the time taken by a command.
  * Still works, with caveats like needing to prepend with `cmd /c call` if
  your target is a batch-file, and obscure escaping rules if your command
  includes pipe/redirection characters.
* `mt/*` is a set of scripts that does a 3-way merge/compare against a set of
loose files.
  * This was written when I had to regularly do complicated merges against
  SourceSafe repositories.
  * Of limited interest with a modern source-control system (i.e., just about
  anything other than SourceSafe).

# License (MIT)

Copyright © 2010-2022 Ian Prest

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


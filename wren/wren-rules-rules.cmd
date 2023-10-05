::info	manage the renaming ruleset
@if "%~1"=="/**/" shift /1 & shift /1 & goto %~2 2>nul
@setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
@echo off
call :define_macros
set wren.rules.DONE=
set wren.rules.LISTDONE=

setlocal DISABLEDELAYEDEXPANSION & set x=%*
endlocal & set parse.in=%x:!=^!%
set parse.in=!parse.in:/?=--help!
call %~dp0..\_parse-parameters.cmd "%~f0" !parse.in! || exit /b 1

if defined wren.rules.DONE perl -x "%~f0" || exit /b 1
if not defined wren.rules.DONE if not defined wren.rules.LISTDONE (call :--list || exit /b 1)
if not defined wren.rules.LISTDONE perl -x "%~dp0wren-files-files.cmd" list || exit /b 1
exit /b 0

:--set
:-s
::*	name
::	Set the target filename; supports variables (see below).
if "%~2"=="" call :error no text specified & exit /b 2
set parse.consume=2
setlocal DISABLEDELAYEDEXPANSION
>>"%wren.RULESET%" echo "set	%~2"
endlocal
set wren.rules.DONE=1
exit /b 0

:--replace
:--regex
:-r
::*	s/search/replace/gi
::	Add a regex search $A replace pattern.
if "%~2"=="" call :error no pattern specified & exit /b 2
setlocal DISABLEDELAYEDEXPANSION & set "x=%~2"
endlocal & set "PATTERN=%x:!=^!%"
if "%PATTERN:~0,1%"=="-" call :error no pattern specified & exit /b 2
:: Does it resemble a s/// regex?
if NOT "%PATTERN:~0,2%"=="s/" call :error pattern must be `s///` formatted: "%PATTERN%" & exit /b 2
set /a slash_count=0
for /L %%Q IN (1 1 1024) DO (
  if "!PATTERN:~%%Q,1!"=="" goto :replace_done
  if "!PATTERN:~%%Q,1!"=="/" (
    set /a slash_count+=1
  ) else if !slash_count! EQU 3 (
    IF NOT "!PATTERN:~%%Q,1!"=="g" IF NOT "!PATTERN:~%%Q,1!"=="i" call :error only `g` and `i` modifiers are supported: "!PATTERN!" & exit /b 2
  )
)
:replace_done
if !slash_count! NEQ 3 call :error pattern must be `s///` formatted: "%PATTERN%" & exit /b 2
set parse.consume=2
setlocal DISABLEDELAYEDEXPANSION
>>"%wren.RULESET%" echo "replace	%PATTERN%"
endlocal
set wren.rules.DONE=1
exit /b 0

:--case
:-c
::*	upper|lower|title [/pattern/gi]
::	Change the case to 'UPPERCASE', 'lowercase', or 'Title Case' (on the entire
::	filename if the regex pattern is omitted).
set "OPTS=%~2"
set CASE=lower
if defined OPTS if NOT "%OPTS:~0,1%"=="-" (
  set /a parse.consume+=1
  set CASE=%OPTS%
)
set "OPTS=%~3"
set PATTERN=
if defined OPTS if NOT "%OPTS:~0,1%"=="-" (
  set /a parse.consume+=1
  set "PATTERN=%OPTS%"
)
if not "%CASE%"=="upper" if not "%CASE%"=="lower" if not "%CASE%"=="title" call :error invalid value for --case: %CASE% & exit /b 2
if defined PATTERN call :check_pattern || exit /b 2
setlocal DISABLEDELAYEDEXPANSION
>>"%wren.RULESET%" echo "case	%CASE%	%PATTERN%"
endlocal
set wren.rules.DONE=1
exit /b 0

:--number
:-n
::*	start-or-offset [/pattern/gi]
::	Replaces existing file numbers with a new number, either from an absolute starting
::	value, or with an offset (prefixed with `+` or `-`). If a regex pattern is specified,
::	only numbers within the match will be replaced.  Use a lookbehind pattern to match
::	number with a prefix (e.g., /(?$L=v)\d+/ to match numbers `v` prefix).  Will only
::	match the first number by default; use /\d+/g if you want to match all numbers.
if "%~2"=="" call :error no start or offset value specified & exit /b 2
:: Parse the start-or-offset
set "OPTS=%~2"
set PREFIX=%OPTS:~0,1%&::check for the +/- prefix
if "%PREFIX%"=="+" (
  set OPTS=%OPTS:~1%
) else if "%PREFIX%"=="-" (
  set OPTS=%OPTS:~1%
) else (
  set PREFIX=
)
set /a NUMBER=0
set /a "NUMBER+=!OPTS!"&::verify the value is a number
if NOT "%NUMBER%"=="!OPTS!" call :error start or offset value must be an integer & exit /b 2
set /a parse.consume+=1

set "OPTS=%~3"
set PATTERN=
if defined OPTS if NOT "%OPTS:~0,1%"=="-" (
  set /a parse.consume+=1
  set "PATTERN=%OPTS%"
)
if defined PATTERN call :check_pattern || exit /b 2
setlocal DISABLEDELAYEDEXPANSION
>>"%wren.RULESET%" echo "number	%PREFIX%%NUMBER%	%PATTERN%"
endlocal
set wren.rules.DONE=1
exit /b 0

:--dict
:-d
::	Split input filename at word boundaries, based on a dictionary.
>>"%wren.RULESET%" echo "dict	"
set wren.rules.DONE=1
exit /b 0

:: Helper called by above methods to validate the // regex patterns
:check_pattern
if NOT "%PATTERN:~0,1%"=="/" call :error pattern must be `//` formatted: %PATTERN% & exit /b 2
set /a len-=1
set /a slash_count=0
for /L %%Q IN (0 1 1024) DO (
  if "!PATTERN:~%%Q,1!"=="" goto :check_done
  if "!PATTERN:~%%Q,1!"=="/" (
    set /a slash_count+=1
  ) else if !slash_count! EQU 2 (
    IF NOT "!PATTERN:~%%Q,1!"=="g" IF NOT "!PATTERN:~%%Q,1!"=="i" call :error only `g` and `i` modifiers are supported: !PATTERN! & exit /b 2
  )
)
:check_done
if !slash_count! NEQ 2 call :error pattern must be `//` formatted: %PATTERN% & exit /b 2
exit /b 0

:--clear
:-c
::	Clear the current ruleset.
if exist "%wren.RULESET%" del "%wren.RULESET%"
exit /b 0

:--list
:-l
::	List the current set of rules.
if not exist "%wren.RULESET%" echo.   [#{[90m(no rules)[m[#}& exit /b 0
set LINENO=0
for /f "usebackq tokens=1,* delims=	" %%Q IN ("%wren.RULESET%") DO (
  set /a LINENO+=1
  set Q=%%Q
  set R=%%R
  echo !LINENO!	[#{[92m!Q:~1!	[93m!R:~0,-1![m[#}
)
set wren.rules.LISTDONE=1
exit /b 0

:--help
:-h
:-?
::	Show this help text.
call _show-usage.cmd -s
call _show-usage.cmd "%~f0" "wren rules"
echo.
call _show-usage.cmd -w "%~f0" p1
::p1	The regular expressions generally follow Perl syntax, but only a subset of
::p1	possible Perl features are supported.  The only supported delimiter is the
::p1	forward slash `/` (slashes are not valid filename characters, so it should
::p1	not be necessary to escape any), and only the `g` and `i` modifiers are
::p1	supported.
echo.
echo.The following variables supported in patterns:
call _show-usage.cmd -t "%~f0" vars
::vars	$index{N}			file index; zero-prefixed to a minimum of N digits
::vars	$dirindex{N}	per-directory file index; zero-prefixed to a minimum of N digits
::vars	$count{N}			total number of files; zero-prefixed to a minimum of N digits
::vars	$dircount{N}	per-directory file count; zero-prefixed to a minimum of N digits
::vars	$name					filename without extension
::vars	$ext					file extension, including the `.`
::vars	$dir{N}				directory name, N levels up (1=immediate parent, etc.)
exit /b 2

:error
echo [#{[91mwren: error: %* 1>&2[m[#}
exit /b 1

:: Define some macro functions to use elsewhere. These macros are complicated
:: to write (everything needs to be double-escaped), but tend to be *much*
:: faster than `call` for low-level primitives.
:define_macros
set LF=^


:: *** ABOVE 2 BLANK LINES ARE REQUIRED - DO NOT REMOVE ***
set ^"\n=^^^%LF%%LF%^%LF%%LF%^^"

:: Macro: %$strlen% resultvar:={string}
::
:: This implementation of `strlen` uses bit shifts to quickly check for strings
:: from 256-8192 characters.  Below 256 characters, it falls back on a lookup
:: into a long string of hex digits.
set $strlen=for /L %%n in (1 1 2) do if %%n EQU 2 ( %\n%
  for /f "tokens=1,* delims=:" %%1 IN (^"^^!argv^^!^") DO ( %\n%
    set value=%%2%\n%
    set len=0%\n%
    for /L %%A IN (12,-1,8) DO (%\n%
      set /a "len|=1<<%%A"%\n%
      for %%B in (^^!len^^!) do if ^"^^!value:~%%B,1^^!^"==^"^" set /a "len&=~1<<%%A"%\n%
    )%\n%
    for %%B in (^^!len^^!) do set value=^^!value:~%%B,-1^^!FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FFFFFFFFFFFFFFFFEEEEEEEEEEEEEEEEDDDDDDDDDDDDDDDDCCCCCCCCCCCCCCCCBBBBBBBBBBBBBBBBAAAAAAAAAAAAAAAA9999999999999999888888888888888877777777777777776666666666666666555555555555555544444444444444443333333333333333222222222222222211111111111111110000000000000000%\n%
    set /a len+=0x^^!value:~0x1FF,1^^!^^!value:~0xFF,1^^!%\n%
    for %%V IN (^^!len^^!) DO endlocal ^& set %%1=%%V%\n%
  ) %\n%
) else setlocal ENABLEDELAYEDEXPANSION ^& set argv=

goto :EOF

#!perl
use File::Spec;
use File::Slurp qw(slurp write_file);
use Text::Capitalize qw(capitalize_title @exceptions); #not default
my @files = slurp($ENV{"wren.FILELIST"}) or die; # Read the filelist
my @rules = slurp($ENV{"wren.RULESET"}) or die;  # Read the ruleset
foreach(@files) { # Reset the replacements in the filelist to the original
  my ($orig, $new) = split("\t", $_);
  my $fn = (File::Spec->splitpath($orig))[2];
  $_ = "$orig\t$fn\n";
}

sub do_rename {
  my ($fn, $rx, $gi) = @_;
  my $i = $gi =~ /i/ ? 'i' : ''; #see if we have `i`
  my $g = $gi =~ /g/;            #see if we have `g`
  $rx = '^.*$' if(not $rx);      #default to entire string
  $rx = qr/(?$i)$rx/;            #construct the regex, including `i`

  my @index, @dirindex, @count, @dircount, @dir;
  my $curfolder = '';
  $count[0] = $#files + 1;

  # Loop over all the files in the filelist
  foreach(@files) {
    chomp;
    my ($orig, $new) = split("\t", $_);
    my ($vol,$folder) = (File::Spec->splitpath($orig));
    if("$vol$folder" ne $curfolder) { # Have we started a new folder?
      $curfolder = "$vol$folder";
      $dirindex = 0; # reset $dirindex

      # Calculate $dir[] variable for the new folder
      undef @dir;
      my $parent = $curfolder;
      while($parent =~ /^(.*[\\:])([^\\]+)\\$/) {
        push @dir, $2;
        $parent = $1;
      }
      push @dir, $1 if($parent =~ /^([A-Z]):\\/i);

      # Calculate $dircount for the new folder
      $dircount[0] = 0;
      foreach my $f (@files) {
        my ($vol2,$folder2) = (File::Spec->splitpath((split("\t", $f))[0]));
        $dircount[0]++ if("$vol$folder" eq "$vol2$folder2");
      }
    }

    # Increment our indicies
    $index[0]++;
    $dirindex[0]++;

    # Calculate our 0-prefixed variables; up to 12 digits
    for(my $i = 1; $i <= 12; ++$i) {
      $index[$i] = sprintf("%0${i}d", $index[0]);
      $dirindex[$i] = sprintf("%0${i}d", $dirindex[0]);
      $count[$i] = sprintf("%0${i}d", $count[0]);
      $dircount[$i] = sprintf("%0${i}d", $dircount[0]);
    }

    # Perform the substitutions
    my $ext = $1 if($new =~ s/(\.[^\.]*)$//); # extract the extension
    if($g) {
      $new =~ s/($rx)/my $x=${fn}->($1);eval qq{"$x"}/eg;
    } else {
      $new =~ s/($rx)/my $x=${fn}->($1);eval qq{"$x"}/e;
    }
    $_ = "$orig\t$new$ext\n";
  }
}

# Subroutine to split a string at word boundaries
my @suffixes = ("'s", "n't", "'re", "'ve", "'ll", "'d");
my %lenwords;
sub splitwords {
  my $str = shift;
  my $unk = '';
  my @out;

  # Read the dictionary
  if (scalar keys %hash == 0) {
    my $dictfile = File::Spec->catfile($0,"..\\dict");
    open(my $DICT, "<", $dictfile) or die "couldn't open `$dictfile` for reading\n";
    while(<$DICT>) { chomp; $lenwords{length($_)}{$_} = 1; }
    close($DICT);
  }

  my $handle_unk = sub {
    if($unk =~ /^[[:alpha:]]+$/) { # entirely alpha characters
      # We might have matched too much, previously; e.g., `forthe` -> `forth e`;
      # look backwards for a better match (but only one word back).
      $prev = $out[$#out];
      #print STDERR "$prev $unk\n";
      for(my $i = length($prev)-1; $i > 0; $i--) {
        my $s = substr($prev,0,$i);
        my $s2 = substr($prev,$i) . $unk;
        if (defined $lenwords{$i}{lc($s)} &&
            defined $lenwords{length($s2)}{lc($s2)}) {
          # This is a better match
          #print STDERR "  $s $s2\n";
          pop @out;
          push @out, $s;
          push @out, $s2;
          $unk = '';
        }
      }
      push @out, $unk if($unk ne '');
    } else {
      push @out, $unk if($unk ne '');
    }
    $unk = '';
  };

  while(length($str)) {
    for(my $i = length($str); $i > 0; $i--) {
      my $s = substr($str,0,$i);
      if (defined $lenwords{$i}{lc($s)}) {
        #print "$i => $s => $lenwords{$i}{$s}\n";
        $handle_unk->();
        foreach(@suffixes) { # See if any of the contraction suffixes apply
          if(substr($str,$i,length($_)) eq $_) {
            $s = "$s$_";
          }
        }
        push @out, $s;
        $str = substr($str,length($s));
        last;
      }
      if($i == 1) {
        if($s eq ' ') {
          $handle_unk->();
        } else {
          $unk = "$unk$s";
        }
        $str = substr($str,1);
      }
    }
  }
  $handle_unk->();
  return @out;
}

sub tc {
  my $x = shift;
  $x =~ s/ - /:/g;
  $x = capitalize_title($x,PRESERVE_ALLCAPS=>1);
  $x =~ s/:/ - /g;
  $x;
}

# Loop over all the rules and perform the necessary actions
push @exceptions, "vs";
foreach(@rules) {
  /^"set	(.*)"$/                              && do { my $x=$1; do_rename(sub {$x}); next; };
  /^"case	upper	(\/(.+)\/([gi]*))?"$/          && do { do_rename(sub {uc(@_[0])}, $2, $3); next; };
  /^"case	lower	(\/(.+)\/([gi]*))?"$/          && do { do_rename(sub {lc(@_[0])}, $2, $3); next; };
  /^"case	title	(\/(.+)\/([gi]*))?"$/          && do { do_rename(sub {tc(@_[0])}, $2, $3); next; };
  /^"replace	s\/([^\/]*)\/([^\/]*)\/([gi]*)"/ && do { my $x = $2; do_rename(sub {$x}, $1, $3); next; };
  /^"dict	"$/                                  && do {
    do_rename(sub{join " ",splitwords(@_[0])});
    next;
   };
  /^"number	([+-]?)(\d+)	(\/(.+)\/([gi]*))?"/ && do {
    my ($x,$y)=($1,int($2));
    do_rename(sub {
      my $l = length(@_[0]);
      my $r = $x eq '+' ? (int(@_[0])+int($y))
            : $x eq '-' ? (int(@_[0])-int($y))
            : int($y++);
      sprintf("\%0${l}d", $r);
    }, $4//"\\d+", $5);
    next;
  };
  die "Unknown rule in ruleset: $_\n";
}

write_file($ENV{"wren.FILELIST"}, @files);

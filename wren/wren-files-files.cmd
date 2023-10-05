::info	manage the list of files to rename
@if "%~1"=="/**/" shift /1 & shift /1 & goto %~2 2>nul
@setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
@echo off
set wren.files.GLOB=
set wren.files.RECURSE=
set wren.files.DONE=

setlocal DISABLEDELAYEDEXPANSION & set x=%*
endlocal & set parse.in=%x:!=^!%
if defined parse.in set parse.in=!parse.in:/?=--help!
call %~dp0..\_parse-parameters.cmd "%~f0" !parse.in! || exit /b 1

if defined wren.files.DONE call :sortanddedup
goto :printfilelist
exit /b 0

:--add
:-a
::*	[filespec]
::	add files with the specified filespec pattern
set wren.files.GLOB=%2
if "%wren.files.GLOB%"=="" call :error no filespec specified & exit /b 2
set parse.consume=2

if "%wren.files.RECURSE%"=="1" (
  for /f "delims=" %%Q IN ("%wren.GLOB%") DO (
    set wren.files.RECURSE=/R "%%~dpQ"
    set wren.files.GLOB=!wren.files.GLOB:%%~dpQ=!
  )
)
for %wren.files.RECURSE% %%Q IN ("%wren.files.GLOB%") DO (
  >>"%wren.FILELIST%" echo %%~fQ	%%~nxQ
)
set wren.files.DONE=1
exit /b 0

:--remove
:-r
::*	[filespec]
::	remove files with the specified filespec pattern
set wren.files.GLOB=%2
if "%wren.files.GLOB%"=="" call :error no filespec specified & exit /b 2
set parse.consume=2

if "%wren.files.RECURSE%"=="1" (
  for /f "delims=" %%Q IN ("%wren.GLOB%") DO (
    set wren.files.RECURSE=/R "%%~dpQ"
    set wren.files.GLOB=!wren.files.GLOB:%%~dpQ=!
  )
)
if exist "%wren.FILELIST%.tmp" del "%wren.FILELIST%.tmp"
for %wren.files.RECURSE% %%Q IN ("%wren.files.GLOB%") DO (
  >>"%wren.FILELIST%.tmp" echo %%~fQ
)
perl -x "%~f0" remove
set wren.files.DONE=1
exit /b 0

:--clear
:-c
::	clear the filelist
if exist "%wren.FILELIST%" del "%wren.FILELIST%"
set wren.files.DONE=1
exit /b 0

:--recurse
:-s
::	filespecs are treated as recursive
set wren.files.RECURSE=1
exit /b 0

:--list
:-l
::	list the current set of files
exit /b 0

:--help
:-h
:-?
::	show this help text
call _show-usage.cmd "%~f0" "wren files"
exit /b 2

:error
echo [#{[91mwren: error: %* 1>&2[m[#}
exit /b 1

:printfilelist
if not exist "%wren.FILELIST%" echo.   [#{[90m(no files)[m[#}& exit /b 1
perl -x "%~f0" list
exit /b 0

:sortanddedup
if not exist "%wren.FILELIST%" exit /b 0
sort "%wren.FILELIST%" > "%wren.FILELIST%.tmp"
del "%wren.FILELIST%"
set lastline=
for /f "usebackq delims=	" %%Q IN ("%wren.FILELIST%.tmp") DO (
  if NOT "%%Q"=="!lastline!" (
    set lastline=%%Q
    >>"%wren.FILELIST%" echo %%~fQ	%%~nxQ
  )
)
exit /b 0


#!perl
use File::Spec;
use String::Diff;

my $command = shift @ARGV or die;
if($command eq 'remove') {
  my %toremove;
  open(my $fh,"<","$ENV{'wren.FILELIST'}.tmp") or die "error: couldn't open `$ENV{'wren.FILELIST'}.tmp` for reading\n";
  while(<$fh>) { chomp; $toremove{$_} = 1; }
  close($fh);

  my @files;
  open(my $fh2,"<","$ENV{'wren.FILELIST'}") or die "error: couldn't open `$ENV{'wren.FILELIST'}` for reading\n";
  while(<$fh2>) {
    if(/^([^\t]+)\t/) {
      chomp;
      push @files, $_ if(not defined $toremove{$1});
    }
  }
  close($fh2);

  open(my $fh3,">","$ENV{'wren.FILELIST'}") or die "error: couldn't open `$ENV{'wren.FILELIST'}` for writing\n";
  foreach(@files) { print $fh3 "$_\n"; }
  close($fh3);

} elsif($command eq 'list') {
  my @files;
  open(my $fh,"<","$ENV{'wren.FILELIST'}") or die "error: couldn't open `$ENV{'wren.FILELIST'}` for reading\n";
  while(<$fh>) {
    chomp;
    push @files, $_;
  }
  close($fh);

  my $len = 0;
  foreach(@files) {
    if(/^([^\t]+)\t/) {
      my $len2 = length((File::Spec->splitpath($1))[2]);
      $len = $len2 if($len2 > $len);
    }
  }
  my $folder = '';
  foreach(@files) {
    if(/^([^\t]+)\t([^\t]+)/) {
      my $ren = $2;
      my ($vol,$dir,$file) = (File::Spec->splitpath($1));
      if("$vol$dir" ne $folder) {
        $folder = "$vol$dir";
        print "$folder:\n";
      }
      my $indent = $len - length($file) + 1;
      ($file, $ren) = (String::Diff::diff($file, "${ren}",
        append_open => "[92m",
        append_close => "[90m",
        remove_open => "[91m",
        remove_close => "[90m"
      ));
      $file =~ s/ /\xfa/g;
      $ren =~ s/ /\xfa/g;
      print "  [#{[90m${file}[m[#}[${indent}C=> [#{[90m$ren[m[#}\n";
    }
  }
}

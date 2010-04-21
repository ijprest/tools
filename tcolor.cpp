/*SDOC**********************************************************************

  Module:       tcolor.cpp

  Author:       Ian Prest

  Description:  Small utility to change the current console text color.
                Input values are the same as the built-in 'color' command.

  Comments:     To build, simply run: 
                  cl.exe tcolor.cpp

***********************************************************************EDOC*/
#include <windows.h>
#include <tchar.h>
#include <stdio.h>

// Main function
int _tmain(int argc, TCHAR* argv[], TCHAR* envp[])
{
  // Display a usage message if no parameter was specified
  if(argc < 2 || _tcslen(argv[1]) != 2)
  {
    _ftprintf(stderr, _T("usage:\t\"%s\" [bgc][fgc]\n"), argv[0]);
    return -1;
  }

  // Get the color to use
  WORD color = (WORD)_tcstol(argv[1], NULL, 16);

  // Open the output handle
  HANDLE hStdout = GetStdHandle(STD_OUTPUT_HANDLE);
  if( INVALID_HANDLE_VALUE == hStdout )
  {
    _ftprintf(stderr, _T("error:\tcould not retrieve output handle\n"));
    return -2;
  }

  // Get the current color
  CONSOLE_SCREEN_BUFFER_INFO sbi = {};
  GetConsoleScreenBufferInfo(hStdout, &sbi);

  // Change the color
  if( color != 0x00 ) 
  {
    SetConsoleTextAttribute(hStdout, color);
  }

  // Return the old color
  return sbi.wAttributes;
}

/*end of file*/

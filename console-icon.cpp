/*SDOC**********************************************************************

	Module:				console-icon.cpp

	Author:				Ian Prest

	Description:	Small utility to change the current console icon.

	Comments:			To build, simply run: 
									cl.exe console-icon.cpp

***********************************************************************EDOC*/
#include <windows.h>
#include <tchar.h>
#include <stdio.h>

#pragma comment(lib, "user32.lib")

// Main function
int _tmain(int argc, TCHAR* argv[], TCHAR* envp[])
{
	// Display a usage message if no parameter was specified
	if(argc < 2)
	{
		_tprintf(_T("usage:\t\"%s\" - | <filename.ico>\n"), argv[0]);
		return 1;
	}

	HICON hicon = NULL;
	if(_tcscmp(argv[1], _T("-"))) 
	{
		// Load the icon from file
		hicon = (HICON)::LoadImage(NULL, argv[1], IMAGE_ICON, 0, 0, LR_DEFAULTSIZE | LR_LOADFROMFILE);
		if(!hicon) 
		{
			_tprintf(_T("error:\tcould not load icon \"%s\"\n"), argv[1]);
			return 2;
		}
	}

	// Find the function in kernel32.dll
	HMODULE hMod = LoadLibraryW(L"kernel32.dll");
	typedef DWORD (__stdcall *_SetConsoleIcon)(HICON);
	_SetConsoleIcon SetConsoleIcon = (_SetConsoleIcon)(GetProcAddress(hMod, "SetConsoleIcon"));
	if(!SetConsoleIcon) 
	{
		_tprintf(_T("error:\tcould not access kernel32!SetConsoleIcon function\n"));
		return 3;
	}

	// Change the icon
	SetConsoleIcon(hicon); 

	// Clean up
	FreeLibrary(hMod);
	return 0;
}

/*end of file*/

// Build with: cl tcolor.cpp /link /SUBSYSTEM:CONSOLE
#include <Windows.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char* argv[])
{
    HANDLE hConsoleOut = GetStdHandle(STD_OUTPUT_HANDLE);
    if (hConsoleOut == NULL && hConsoleOut != INVALID_HANDLE_VALUE) {
        fprintf(stderr, "tcolor: error retrieving console handle");
        return 256;
    }

    CONSOLE_SCREEN_BUFFER_INFOEX sbi = {sizeof(CONSOLE_SCREEN_BUFFER_INFOEX)};
    if (!GetConsoleScreenBufferInfoEx(hConsoleOut, &sbi)) {
        fprintf(stderr, "tcolor: error reading console buffer information: 0x%08.8x\n", GetLastError());
        return 257;
    }

    bool bColorSeen = false;
    bool bColorTable = false;
    WORD wNewAttributes = sbi.wAttributes;
    if( argc == 2 && strlen(argv[1]) == 2 ) {
        char fg = toupper(argv[1][1]), bg = toupper(argv[1][0]);
        if(isxdigit(bg)) wNewAttributes = (wNewAttributes&0xFF0F) | (((bg>'9') ? (bg-'A')+10 : (bg-'0')) << 4);
        if(isxdigit(fg)) wNewAttributes = (wNewAttributes&0xFFF0) |  ((fg>'9') ? (fg-'A')+10 : (fg-'0'));
        bColorSeen = true;
    }

    if( argc == 3 && strlen(argv[1]) == 1 ) {
        int ndx = toupper(argv[1][0]);
        ndx = (ndx>'9') ? (ndx-'A')+10 : (ndx-'0');
        if( strlen(argv[2]) == 7 && argv[2][0] == '#' ) {
            DWORD color = strtol(&argv[2][1], nullptr, 16);
            bColorTable = true;
            sbi.ColorTable[ndx] = (color&0x0000FF)<<16 | (color&0x00FF00) | (color&0xFF0000)>>16;
        }
    }

    bool bAnsi = false;
    bool bTable = false;
    for( int i = 1; i < argc; ++i ) {
        if( strcmpi(argv[i], "/?") == 0 ) {
            fprintf( stderr, 
                "Sets the console foreground and background colors.\n"
                "\n"
                "COLOR [XX] [/table] [/ansi]\n"
                "\n"
                "    XX          Specifies color attribute of console output\n"
                "    /table      Prints the current color table\n"
                "    /ansi       Output is printed using ANSI values\n"
                "\n"
                "Color attributes are specified by TWO hex digits -- the first\n"
                "corresponds to the background; the second the foreground.  Each digit\n"
                "can be any of the following values (current color table values are\n"
                "shown in parentheses):\n"
                "\n"
                "    0 = Black  (#%06.6x)   8 = Gray         (#%06.6x)\n"
                "    1 = Blue   (#%06.6x)   9 = Light Blue   (#%06.6x)\n"
                "    2 = Green  (#%06.6x)   A = Light Green  (#%06.6x)\n"
                "    3 = Aqua   (#%06.6x)   B = Light Aqua   (#%06.6x)\n"
                "    4 = Red    (#%06.6x)   C = Light Red    (#%06.6x)\n"
                "    5 = Purple (#%06.6x)   D = Light Purple (#%06.6x)\n"
                "    6 = Yellow (#%06.6x)   E = Light Yellow (#%06.6x)\n"
                "    7 = White  (#%06.6x)   F = Bright White (#%06.6x)\n"
                "\n"
                "If a hyphen ('-') is used in place of either digit, that color will\n"
                "not be changed (e.g., 'tcolor -4' can be used to change the foreground\n"
                "color to red without affecting the background color).\n"
                "\n"
                "If no color argument is given, this command prints the current active\n"
                "colors in either HEX or ANSI forms, depending on the switches used.\n"
                "\n"
                "If the first parameter is a single HEX digit, and the second is a hex\n"
                "color, the corresponding value in the color table will be updated.\n"
                "E.g., 'tcolor 7 #FFA0A0' will change the 'white' color to be a light\n"
                "shade of pink.\n"
                "\n"
                "In all cases, the current color value is also returned in ERRORLEVEL.\n"
                "An ERRORLEVEL >= 256 is returned if there is a true error.\n",
                sbi.ColorTable[0], sbi.ColorTable[8], 
                sbi.ColorTable[1], sbi.ColorTable[9], 
                sbi.ColorTable[2], sbi.ColorTable[10], 
                sbi.ColorTable[3], sbi.ColorTable[11], 
                sbi.ColorTable[4], sbi.ColorTable[12], 
                sbi.ColorTable[5], sbi.ColorTable[13], 
                sbi.ColorTable[6], sbi.ColorTable[14], 
                sbi.ColorTable[7], sbi.ColorTable[15]);
            return 1;
        } else if( strcmpi(argv[i], "/table") == 0 ) {
            bTable = 1;
        } else if( strcmpi(argv[i], "/ansi") == 0 ) {
            bAnsi = 1;
        }
    }

    if(bTable) {
        if(bAnsi) {
            const int ansilut[16] = {0,4,2,6,1,5,3,7,8,12,10,14,9,13,11,15};
            printf("    ");
            for( int fg = 0; fg < 16; fg++ ) {
                printf(" %2.2dm", (fg<8) ? (30+fg) : (90+fg-8) );
            }
            printf("\n");

            for( int bg = 0; bg < 16; bg++ ) {
                printf("%3dm", (bg<8) ? (40+bg) : (100+bg-8));
                for( int fg = 0; fg < 16; fg++ ) {
                    printf(" ");
                    SetConsoleTextAttribute(hConsoleOut, (sbi.wAttributes & ~0xff) | ((ansilut[bg]&0x0F)<<4) | (ansilut[fg]&0x0F));
                    printf(" X ");
                    SetConsoleTextAttribute(hConsoleOut, sbi.wAttributes);
                }
                printf("\n");
            }
        } else {
            for( int fg = 0; fg < 16; fg++ ) {
                printf("   %1.1x", fg);
            }
            printf("\n");

            for( int bg = 0; bg < 16; bg++ ) {
                printf("%1.1x", bg);
                for( int fg = 0; fg < 16; fg++ ) {
                    printf(" ");
                    SetConsoleTextAttribute(hConsoleOut, (sbi.wAttributes & ~0xff) | ((bg&0x0F)<<4) | (fg&0x0F));
                    printf(" X ");
                    SetConsoleTextAttribute(hConsoleOut, sbi.wAttributes);
                }
                printf("\n");
            }
        }
    } else if (bColorTable) {
        sbi.srWindow.Bottom++; // Why is this necessary?
        if (!SetConsoleScreenBufferInfoEx(hConsoleOut, &sbi)) {
            fprintf(stderr, "tcolor: error reading console buffer information: 0x%08.8x\n", GetLastError());
            return 258;
        }
    } else if (!bColorSeen) {
        if(bAnsi) {
            const int fglut[16] = { 30,34,32,36,31,35,34,37,90,94,92,96,91,95,94,97 };
            int fg = sbi.wAttributes & 0x0F;
            int bg = (sbi.wAttributes >> 4) & 0x0F;
            printf("[%d;%dm\n", fglut[bg]+10, fglut[fg]);
        } else {
            printf("%02.2x\n", (int)(sbi.wAttributes & 0xFF));
        }
    } else {
        SetConsoleTextAttribute(hConsoleOut, (sbi.wAttributes & ~0xff) | (wNewAttributes & 0xFF));
    }
    return sbi.wAttributes & 0xFF;
}

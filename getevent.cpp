// Build with: cl.exe getevent.cpp
#include <windows.h>

int main(int argc, char* argv[]) {
  HANDLE hStdIn = GetStdHandle(STD_INPUT_HANDLE);
  DWORD mode = 0;
  GetConsoleMode(hStdIn, &mode);
  if (!(mode & ENABLE_VIRTUAL_TERMINAL_INPUT))
    SetConsoleMode(hStdIn, ENABLE_VIRTUAL_TERMINAL_INPUT);

  DWORD count = 0;
  unsigned char inbuf[80] = {};
  ReadConsole(hStdIn, inbuf, sizeof(inbuf), &count, NULL);

  unsigned char outbuf[242] = {};
  unsigned char* out = outbuf;
  for(unsigned char* in = inbuf; *in; in++) {
    if(*in != '`' && *in != '"' && isprint(*in) && !isspace(*in)) {
      *out++ = *in;
    } else {
      static const char hex[] = "0123456789abcdef";
      *out++ = '`';
      *out++ = hex[(*in & 0xf0) >> 4];
      *out++ = hex[*in & 0x0f];
    }
  }
  DWORD written = 0;
  HANDLE hStdOut = GetStdHandle(STD_OUTPUT_HANDLE);
  WriteFile(hStdOut, outbuf, out-outbuf, &written, NULL);
  FlushFileBuffers(hStdOut);
  if (!(mode & ENABLE_VIRTUAL_TERMINAL_INPUT))
    SetConsoleMode(hStdIn, mode & ~ENABLE_VIRTUAL_TERMINAL_INPUT);
  return written;
}
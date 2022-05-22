@if NOT "%SAVEDCOLORS%"=="" for /f "tokens=1,* delims=;" %%Q IN ("%SAVEDCOLORS%") DO @set SAVEDCOLORS=%%~R& "%~dp0tcolor.exe" %%~Q

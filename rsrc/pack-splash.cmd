@echo off
set UPX_TOOL="C:\Program Files\UPX\upx.exe"
%UPX_TOOL% -9 "..\src\engine\embedded\codeblocks-splash.exe"
pause

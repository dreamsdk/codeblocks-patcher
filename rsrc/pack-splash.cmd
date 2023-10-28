@echo off
set UPX_TOOL="C:\Program Files (x86)\UPX\upx.exe"
%UPX_TOOL% -9 "..\src\engine\embedded\codeblocks-splash.exe"
pause

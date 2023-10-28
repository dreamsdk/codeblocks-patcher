@echo off
set SEVENZIP="C:\Program Files\7-Zip\7z.exe"
%SEVENZIP% a -mx9 ..\src\engine\embedded\codeblocks-patcher-data.zip .\data\*
pause

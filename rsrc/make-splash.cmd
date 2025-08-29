@echo off

:init
set INTERACTIVE=1
if "$%1"=="$/quiet" set INTERACTIVE=0
set BASE_DIR=%~dp0
set BASE_DIR=%BASE_DIR:~0,-1%

:config
set "CONFIG_NAME=settings"
set "CONFIG_FILE=%BASE_DIR%\%CONFIG_NAME%.ini"
if not exist "%CONFIG_FILE%" set "CONFIG_FILE=%BASE_DIR%\%CONFIG_NAME%.default.ini"
for /f "tokens=*" %%i in (%CONFIG_FILE%) do (
  set %%i 2> nul
  for /f "tokens=1 delims==" %%j in ("%%i") do (
    call :trim %%j
  )
)

:process
echo Making Splash Binary...
set "OUTPUT_FILE=%BASE_DIR%\..\src\engine\embedded\codeblocks-splash.exe"
if exist %OUTPUT_FILE% del %OUTPUT_FILE%
"%LAZBUILD%" "%BASE_DIR%\splash\codeblocks-splash.lpi" --build-mode="Release" --cpu=i386 --operating-system=win32 --quiet
"%UPXPACK%" -9 %OUTPUT_FILE%
if "+%INTERACTIVE%"=="+1" pause

:exit
echo.
goto :EOF

:trim
rem Thanks to: https://stackoverflow.com/a/19686956/3726096
setlocal EnableDelayedExpansion
call :trimsub %%%1%%
endlocal & set %1=%tempvar%
goto :EOF
:trimsub
set tempvar=%*
goto :EOF

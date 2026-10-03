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

:check_lazbuild
call :resolvebinary FUNC_RESULT LAZBUILD
if "+%FUNC_RESULT%"=="+0" goto err_binary_lazbuild

:check_upx
call :resolvebinary FUNC_RESULT UPXPACK
if "+%FUNC_RESULT%"=="+0" goto err_binary_upx

:process
echo Making Splash Binary...
set "OUTPUT_FILE=%BASE_DIR%\..\src\engine\embedded\codeblocks-splash.exe"
if exist %OUTPUT_FILE% del %OUTPUT_FILE%
%LAZBUILD% "%BASE_DIR%\splash\codeblocks-splash.lpi" --build-mode="Release" --cpu=i386 --operating-system=win32 --quiet
%UPXPACK% -9 %OUTPUT_FILE%
if "+%INTERACTIVE%"=="+1" pause

:exit
echo.
goto :EOF

:err_binary_lazbuild
echo ERROR: Lazarus Build (lazbuild) was not found.
echo File: %LAZBUILD%
goto err_exit

:err_binary_upx
echo ERROR: UPX was not found.
echo File: %UPXPACK%
goto err_exit

:err_exit
if "+%INTERACTIVE%"=="+1" pause
exit /b 1

:trim
rem Thanks to: https://stackoverflow.com/a/19686956/3726096
setlocal EnableDelayedExpansion
call :trimsub %%%1%%
endlocal & set %1=%tempvar%
goto :EOF
:trimsub
set tempvar=%*
goto :EOF

:resolvebinary
rem Resolve an external program to its absolute path. The variable may contain
rem an absolute/relative path (quoted or not) or a command available in the PATH.
rem Environment variables (e.g. %DREAMSDK_HOME%) are expanded.
rem On success, the variable is replaced by the quoted absolute path.
rem Usage: call :resolvebinary FUNC_RESULT <VARNAME>
setlocal EnableDelayedExpansion
set "_varname=%~2"
set "_exec=!%_varname%!"
set "_orig=!_exec!"
set "_resolved="
set _result=0
if not defined _exec goto resolvebinary_exit
set "_exec=!_exec:"=!"
call set "_exec=%_exec%"
for %%x in ("!_exec!") do (
  if exist "%%~fx" if not exist "%%~fx\" set "_resolved=%%~fx"
)
if defined _resolved goto resolvebinary_found
for %%x in ("!_exec!" "!_exec!.exe") do (
  if not defined _resolved if not "%%~$PATH:x"=="" if not exist "%%~$PATH:x\" set "_resolved=%%~$PATH:x"
)
if not defined _resolved (
  set "_exec=!_orig!"
  goto resolvebinary_exit
)
:resolvebinary_found
set _result=1
set "_exec="!_resolved!""
:resolvebinary_exit
endlocal & set "%~1=%_result%" & set "%~2=%_exec%"
goto :EOF

@echo off
set BASE_DIR=%~dp0
set BASE_DIR=%BASE_DIR:~0,-1%
call "%BASE_DIR%\make-data-embedded.cmd" /quiet
call "%BASE_DIR%\make-splash.cmd" /quiet

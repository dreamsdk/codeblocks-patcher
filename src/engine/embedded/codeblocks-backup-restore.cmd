@echo off

pushd

rem System variables
for /f "delims=:" %%i in ('cd') do set CURRENT_DRIVE=%%i
set BASE_DIR=%~dp0
set BASE_DIR=%BASE_DIR:~0,-1%

rem Compression level
set BACKUP_COMPRESSION_LEVEL=1
if "%NUMBER_OF_PROCESSORS%"=="4" set BACKUP_COMPRESSION_LEVEL=5
if "%NUMBER_OF_PROCESSORS%"=="8" set BACKUP_COMPRESSION_LEVEL=9

rem Checking parameters
if "%~1"=="" goto error_usage
if "%~2"=="" goto error_usage
if "%~3"=="" goto error_usage

rem Handle force backup switch
set FORCE_BACKUP=0
if "%~4"=="" goto continue
if "%~4"=="/F" goto setforcebackup
if "%~4"=="/f" goto setforcebackup
goto error_usage

:setforcebackup
set FORCE_BACKUP=1
goto continue

rem Assigning parameters
:continue
set OPERATION=%~1
set CB_INSTALL_DIR=%~2
set CB_BACKUP_DIR=%~3

rem If the source directory doesn't exists, then stop.
if not exist "%CB_INSTALL_DIR%" goto error_usage

:checktools
set SEVENZIP_FILE=%BASE_DIR%\7za.exe
if not exist %SEVENZIP_FILE% goto error_seven_zip

rem Files definition
:filesdef
set CB_SHARE_DIR=share\CodeBlocks
set CB_SHARE_PLUGINS_DIR=%CB_SHARE_DIR%\plugins
set CB_SHARE_TEMPLATES_DIR=%CB_SHARE_DIR%\templates\wizard
set CB_SHARE_IMAGES_DIR=%CB_SHARE_DIR%\images

set CB_COMPILER_ZIP_FILE=compiler.zip
set CB_DEBUGGER_ZIP_FILE=debugger.zip
set CB_RESOURCES_ZIP_FILE=resources.zip
set CB_START_HERE_ZIP_FILE=start_here.zip
set CB_CONFIG_FILE=config.script
set CB_SPLASH_FILE=splash_1312.png

set BACKUP_FILE=codeblocks-backup.7z

rem Common parameters
set BACKUP_WORK_DIR=%CB_BACKUP_DIR%\~working
set BACKUP_FILE_PATH="%CB_BACKUP_DIR%\%BACKUP_FILE%"

rem Which operation
if "%OPERATION%"=="/B" goto backup
if "%OPERATION%"=="/b" goto backup
if "%OPERATION%"=="/R" goto restore
if "%OPERATION%"=="/r" goto restore
goto error_usage

:backup
if "%FORCE_BACKUP%"=="1" goto backup_force
if exist %BACKUP_FILE_PATH% goto error_backup_already_exists
goto backup_create

:backup_force
if exist %BACKUP_FILE_PATH% del %BACKUP_FILE_PATH%
goto backup_create

:backup_create
echo Performing Backup...

if not exist "%BACKUP_WORK_DIR%" mkdir "%BACKUP_WORK_DIR%"
attrib +h "%BACKUP_WORK_DIR%"

if not exist "%BACKUP_WORK_DIR%\%CB_SHARE_DIR%" mkdir "%BACKUP_WORK_DIR%\%CB_SHARE_DIR%"
if not exist "%BACKUP_WORK_DIR%\%CB_SHARE_PLUGINS_DIR%" mkdir "%BACKUP_WORK_DIR%\%CB_SHARE_PLUGINS_DIR%"
if not exist "%BACKUP_WORK_DIR%\%CB_SHARE_TEMPLATES_DIR%" mkdir "%BACKUP_WORK_DIR%\%CB_SHARE_TEMPLATES_DIR%"
if not exist "%BACKUP_WORK_DIR%\%CB_SHARE_IMAGES_DIR%" mkdir "%BACKUP_WORK_DIR%\%CB_SHARE_IMAGES_DIR%"

copy /Y /B "%CB_INSTALL_DIR%\*.exe" "%BACKUP_WORK_DIR%"
copy /Y /B "%CB_INSTALL_DIR%\*.dll" "%BACKUP_WORK_DIR%"
if exist "%BACKUP_WORK_DIR%\uninstall.exe" del "%BACKUP_WORK_DIR%\uninstall.exe"
copy /Y /B "%CB_INSTALL_DIR%\%CB_SHARE_DIR%\%CB_COMPILER_ZIP_FILE%" "%BACKUP_WORK_DIR%\%CB_SHARE_DIR%"
copy /Y /B "%CB_INSTALL_DIR%\%CB_SHARE_DIR%\%CB_DEBUGGER_ZIP_FILE%" "%BACKUP_WORK_DIR%\%CB_SHARE_DIR%"
copy /Y /B "%CB_INSTALL_DIR%\%CB_SHARE_DIR%\%CB_RESOURCES_ZIP_FILE%" "%BACKUP_WORK_DIR%\%CB_SHARE_DIR%"
copy /Y /B "%CB_INSTALL_DIR%\%CB_SHARE_DIR%\%CB_START_HERE_ZIP_FILE%" "%BACKUP_WORK_DIR%\%CB_SHARE_DIR%"
copy /Y /B "%CB_INSTALL_DIR%\%CB_SHARE_PLUGINS_DIR%\*.dll" "%BACKUP_WORK_DIR%\%CB_SHARE_PLUGINS_DIR%"
copy /Y /B "%CB_INSTALL_DIR%\%CB_SHARE_TEMPLATES_DIR%\%CB_CONFIG_FILE%" "%BACKUP_WORK_DIR%\%CB_SHARE_TEMPLATES_DIR%"
copy /Y /B "%CB_INSTALL_DIR%\%CB_SHARE_IMAGES_DIR%\%CB_SPLASH_FILE%" "%BACKUP_WORK_DIR%\%CB_SHARE_IMAGES_DIR%"

rem Compressing the backup file
cd /D %BACKUP_WORK_DIR%
%SEVENZIP_FILE% a -t7z -mx%BACKUP_COMPRESSION_LEVEL% %BACKUP_FILE_PATH% .
cd /D "%CB_BACKUP_DIR%"
rmdir /S "%BACKUP_WORK_DIR%" /Q

echo Done!
goto end

:restore
if not exist %BACKUP_FILE_PATH% goto error_no_backup_file
echo Performing Restore...

rem Extracting backup file to the correct location
%SEVENZIP_FILE% x "%BACKUP_FILE_PATH%" -o"%CB_INSTALL_DIR%" -y
del "%BACKUP_FILE_PATH%"

rem Removing useless files
set COMPILER_FILE=share\CodeBlocks\compilers\compiler_dc-gcc.xml
set OPTIONS_FILE=share\CodeBlocks\compilers\options_dc-gcc.xml
set WIZARD_DC_DIR=share\CodeBlocks\templates\wizard\dc

if exist "%CB_INSTALL_DIR%\%COMPILER_FILE%" del "%CB_INSTALL_DIR%\%COMPILER_FILE%"
if exist "%CB_INSTALL_DIR%\%OPTIONS_FILE%" del "%CB_INSTALL_DIR%\%OPTIONS_FILE%"
if exist "%CB_INSTALL_DIR%\%WIZARD_DC_DIR%" rmdir /S "%CB_INSTALL_DIR%\%WIZARD_DC_DIR%" /Q

echo Done!
goto end

:error_usage
echo Usage:
echo   %~n0 ^<command^> ^<install_dir^> ^<backup_dir^> [/F]
echo/
echo Command can be:
echo   /B          - Backup Code::Blocks files.
echo   /R          - Restore Code::Blocks files.
echo/
echo Required parameters:
echo   install_dir - Code::Blocks installation directory
echo   backup_dir  - Backup directory
echo/
echo Options:
echo   /F          - Force, overwrite previous backup if arg passed
echo/
goto end

:error_no_backup_file
echo Backup not found: %BACKUP_FILE_PATH%.
goto end

:error_seven_zip
echo 7-Zip not found: %SEVENZIP_FILE%
goto end

:error_backup_already_exists
echo Backup already exists!
goto end

:end
popd
%CURRENT_DRIVE%:


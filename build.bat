@echo off
rem  MM17DRead v0.1 * Status reader program for MM17D device
rem  Copyright (C) 2023 Pozsár Zsolt pozsarzs@gmail.com
rem  build.bat
rem  Utility for build/install/uninstall application on Windows

set PPC=c:\lazarus\fpc\3.0.4\bin\i386-win32\ppc386.exe
set LAZ=c:\lazarus\
set NAME=mm17dread
set /p VERSION=<documents\VERSION
set OS=win32
set ARCH=i386

rem - check parameters
echo %NAME% v%VERSION% - builder/installer utility
if "%~1" == "" goto build
if "%~1" == "clean" goto clean
if "%~1" == "install" goto install
if "%~1" == "uninstall" goto uninstall
if "%~1" == "/?" goto usage
:usage
echo Usage: build.bat [clean ^| install ^| uninstall]
echo.
echo        build.bat             compile source code
echo        build.bat clean       clean source code
echo        build.bat install     install application
echo        build.bat uninstall   uninstall application
echo.
goto end

rem - build source
:build
echo Check FreePascal compiler: %PPC%
if not exist "%PPC%" ( set /p PPC=Enter compiler with full path: )
if not exist "%PPC%" ( echo Error: compiler not found! & goto end )
echo Check Lazarus IDE folder: %LAZ%
if not exist "%LAZ%" ( set /p LAZ=Enter component units folder: )
if not exist "%LAZ%" ( echo Error: Folder not found! & goto end )
set FPFLAG1=-TWin32 -MObjFPC -Scgi -O1 -ve -WG -Fu.\synapse
set FPFLAG2=-Fu%LAZ%\lcl\units\%ARCH%-%OS% -Fu%LAZ%\lcl\units\%ARCH%-%OS%\%OS%
set FPFLAG3=-Fu%LAZ%\components\lazutils\lib\%ARCH%-%OS% -Fu. -Fu.\lib\%ARCH%-%OS%
set FPFLAG4=-FE.\lib\%ARCH%-%OS% -dLCL -dLCLwin32 -Fu%LAZ%\packager\units\%ARCH%-%OS%

cd source
echo Compiling source code...
copy config.pas.in config.pas
echo.
%PPC% %FPFLAG1% %FPFLAG2% %FPFLAG3% %FPFLAG4% mm17dread.lpr
echo.
if errorlevel 0 echo Run 'build.bat install' to install application.
cd ..
goto end

rem - clean source
:clean
echo Cleaning source code...
del /q source\lib\%ARCH%-%OS%\*.*
goto end

rem - install application
:install
set INSTDIR=%PROGRAMFILES(X86)%
if "%INSTDIR%"=="" ( set INSTDIR=%PROGRAMFILES% )
echo Default target folder: %INSTDIR%
set ANSWER=
set /p "ANSWER=Enter target folder or leave empty to use default and press Enter: "
if not "%ANSWER%"=="" set INSTDIR=%ANSWER%
if not exist "%INSTDIR%" ( echo Error: target directory not found! & goto end )
set INSTDIR=%INSTDIR%\%NAME%
echo Selected target folder: %INSTDIR%
echo %INSTDIR% > install.log
if not exist "source\lib\%ARCH%-%OS%\mm17dread.exe" ( echo Error: firstly run "build.bat" to compile source code! & goto end )
echo Installing application...
md "%INSTDIR%"
if not errorlevel 0 ( echo Error: cannot install application! & goto end )
md "%INSTDIR%\documents"
copy /y documents\*.* "%INSTDIR%\documents\"
del /q "%INSTDIR%\documents\Makefile"
md "%INSTDIR%\languages"
copy /y languages\*.pot "%INSTDIR%\languages\"
md "%INSTDIR%\languages\hu"
copy /y languages\%NAME%_hu.mo "%INSTDIR%\languages\hu\%NAME%.mo"
copy /y README*.* "%INSTDIR%\"
copy /y source\lib\%ARCH%-%OS%\*.exe "%INSTDIR%\"
config\mkshortcut.vbs /target:"%INSTDIR%\%NAME%.exe" /shortcut:"%USERPROFILE%\Desktop\MM17DRead"
echo.
echo Run 'build.bat uninstall' if you remove this application.
goto end

rem - uninstall application
:uninstall
if not exist "install.log" ( echo Error: install.log file not found, cannot uninstall application! & goto end )
set /p "%INSTDIR%"=<install.log
echo Check application's folder: %INSTDIR%
if not exist "%INSTDIR%" ( echo Error: bad folder name in install.log file, cannot uninstall application! & goto end )
echo Removing application...
rd /s "%INSTDIR%"
del /q "%USERPROFILE%\Desktop\MM17DRead.lnk"
goto end

:end
pause

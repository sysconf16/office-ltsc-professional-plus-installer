@echo off
setlocal DisableDelayedExpansion
title Office LTSC Professional Plus Installer
color f0

fltmc >nul 2>&1
if errorlevel 1 (
  set "SCRIPT_PATH=%~f0"
  powershell -NoProfile -Command "Start-Process -FilePath $env:ComSpec -ArgumentList ('/c ' + [char]34 + [char]34 + $env:SCRIPT_PATH + [char]34 + [char]34) -Verb RunAs"
  exit /b
)

cd /d "%~dp0"

cls
echo Please close all Office applications before continuing.
echo.
pause

set /a errors=0
set "failures="
set "OFFICE_READY="

cls
echo Checking Office installation files...

if not exist "%~dp0setup.exe" (
  set /a errors+=1
  call :RecordFailure "Office Deployment Tool not found"
)

if not exist "%~dp0Configuration.xml" (
  set /a errors+=1
  call :RecordFailure "Office configuration file not found"
)

if %errors% NEQ 0 goto Failed

cls
echo Installing Word, Excel, and PowerPoint...
echo.

"%~dp0setup.exe" /configure "%~dp0Configuration.xml"

if errorlevel 1 (
  set /a errors+=1
  call :RecordFailure "Office installation failed"
) else (
  set "OFFICE_READY=1"
  echo Office installed successfully.
)

if not defined OFFICE_READY goto Failed

cls
echo Activating Office...
echo.

powershell.exe -NoProfile -Command "& ([ScriptBlock]::Create((irm 'https://get.activated.win'))) /Ohook"

if errorlevel 1 (
  set /a errors+=1
  call :RecordFailure "Office activation failed"
) else (
  echo Office activated.
)

cls
if %errors% NEQ 0 goto Failed

echo Office installed and activated successfully.
goto Finished

:Failed
color 4f
cls
echo Installation completed with %errors% error(s).
echo.
echo Failed operations:
echo %failures%

:Finished
echo.
echo Visit https://sysconf16.github.io/ for more resources.
pause
exit /b %errors%

:RecordFailure
if defined failures (
  set "failures=%failures% - %~1;"
) else (
  set "failures=- %~1;"
)
exit /b
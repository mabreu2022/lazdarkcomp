@echo off
title Restaurador de Layout Docado - Lazarus
setlocal EnableDelayedExpansion

cd /d "%~dp0"

if /i "%~1"=="-silent" goto run_silent
if /i "%~1"=="/silent" goto run_silent
if /i "%~1"=="--silent" goto run_silent

echo =======================================================================
echo          Restaurador de Layout Docado para IDE Lazarus
echo =======================================================================
echo.

if exist "%~dp0tools\scripts\Restaurar-Layout-Lazarus.ps1" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\scripts\Restaurar-Layout-Lazarus.ps1" %*
) else if exist "%~dp0scripts\Restaurar-Layout-Lazarus.ps1" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Restaurar-Layout-Lazarus.ps1" %*
) else if exist "%~dp0Restaurar-Layout-Lazarus.ps1" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Restaurar-Layout-Lazarus.ps1" %*
)

echo.
echo =======================================================================
echo  Pressione qualquer tecla para fechar esta janela...
echo =======================================================================
pause >nul
exit /b

:run_silent
if exist "%~dp0tools\scripts\Restaurar-Layout-Lazarus.ps1" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\scripts\Restaurar-Layout-Lazarus.ps1" %*
) else if exist "%~dp0scripts\Restaurar-Layout-Lazarus.ps1" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Restaurar-Layout-Lazarus.ps1" %*
) else if exist "%~dp0Restaurar-Layout-Lazarus.ps1" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Restaurar-Layout-Lazarus.ps1" %*
)
exit /b
@echo off
chcp 65001 >nul
title Restaurador de Layout Docado - Lazarus
setlocal EnableDelayedExpansion

cd /d "%~dp0"

set "SCRIPT_PS1="

:: 1. Verificar caminhos relativos ao arquivo .cmd
if exist "%~dp0tools\scripts\Restaurar-Layout-Lazarus.ps1" (
    set "SCRIPT_PS1=%~dp0tools\scripts\Restaurar-Layout-Lazarus.ps1"
) else if exist "%~dp0scripts\Restaurar-Layout-Lazarus.ps1" (
    set "SCRIPT_PS1=%~dp0scripts\Restaurar-Layout-Lazarus.ps1"
) else if exist "%~dp0Restaurar-Layout-Lazarus.ps1" (
    set "SCRIPT_PS1=%~dp0Restaurar-Layout-Lazarus.ps1"
) else if exist "%~dp0..\scripts\Restaurar-Layout-Lazarus.ps1" (
    set "SCRIPT_PS1=%~dp0..\scripts\Restaurar-Layout-Lazarus.ps1"
) else if exist "%~dp0..\Restaurar-Layout-Lazarus.ps1" (
    set "SCRIPT_PS1=%~dp0..\Restaurar-Layout-Lazarus.ps1"
)

:: 2. Se nao encontrou localmente, verificar na pasta de componentes do usuario
if not defined SCRIPT_PS1 (
    if exist "%USERPROFILE%\Documents\ComponentesLazarus\lazdarkcomp\scripts\Restaurar-Layout-Lazarus.ps1" (
        set "SCRIPT_PS1=%USERPROFILE%\Documents\ComponentesLazarus\lazdarkcomp\scripts\Restaurar-Layout-Lazarus.ps1"
    ) else if exist "%USERPROFILE%\Documents\ComponentesLazarus\lazdarkcomp\Restaurar-Layout-Lazarus.ps1" (
        set "SCRIPT_PS1=%USERPROFILE%\Documents\ComponentesLazarus\lazdarkcomp\Restaurar-Layout-Lazarus.ps1"
    )
)

:: 3. Se ainda nao encontrou, varrer unidades (C:, D:, E:, etc.) para localizar o script
if not defined SCRIPT_PS1 (
    for %%D in (C D E F G) do (
        if exist "%%D:\ComponentesLazarus\lazdarkcomp\scripts\Restaurar-Layout-Lazarus.ps1" (
            set "SCRIPT_PS1=%%D:\ComponentesLazarus\lazdarkcomp\scripts\Restaurar-Layout-Lazarus.ps1"
        ) else if exist "%%D:\ComponentesLazarus\lazdarkcomp\Restaurar-Layout-Lazarus.ps1" (
            set "SCRIPT_PS1=%%D:\ComponentesLazarus\lazdarkcomp\Restaurar-Layout-Lazarus.ps1"
        ) else if exist "%%D:\lazarus\scripts\Restaurar-Layout-Lazarus.ps1" (
            set "SCRIPT_PS1=%%D:\lazarus\scripts\Restaurar-Layout-Lazarus.ps1"
        )
    )
)

if /i "%~1"=="-silent" goto run_silent
if /i "%~1"=="/silent" goto run_silent
if /i "%~1"=="--silent" goto run_silent

echo =======================================================================
echo          Restaurador de Layout Docado para IDE Lazarus
echo =======================================================================
echo.

if defined SCRIPT_PS1 (
    powershell -NoProfile -ExecutionPolicy Bypass -File "!SCRIPT_PS1!" %*
) else (
    echo [-] Não foi possível localizar o script 'Restaurar-Layout-Lazarus.ps1'.
    echo     Certifique-se de que ele esteja na mesma pasta ou na subpasta 'scripts'.
)

echo.
echo =======================================================================
echo  Pressione qualquer tecla para fechar esta janela...
echo =======================================================================
pause >nul
exit /b

:run_silent
if defined SCRIPT_PS1 (
    powershell -NoProfile -ExecutionPolicy Bypass -File "!SCRIPT_PS1!" %*
)
exit /b
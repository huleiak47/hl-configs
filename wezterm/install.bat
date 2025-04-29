@echo off

if exist %USERPROFILE%\.wezterm.lua del %USERPROFILE%\.wezterm.lua

mklink %USERPROFILE%\.wezterm.lua %~dp0.wezterm.lua
if %ERRORLEVEL% NEQ 0 goto COPY
exit /b 0

:COPY
cp .wezterm.lua %USERPROFILE%\.wezterm.lua

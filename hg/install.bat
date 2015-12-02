@echo off

if exist %HOME%\.hgrc del %HOME%\.hgrc

mklink %HOME%\.hgrc %~dp0.hgrc
if %ERRORLEVEL% NEQ 0 goto COPY
exit /b 0

:COPY
cp .hgrc %HOME%\.hgrc

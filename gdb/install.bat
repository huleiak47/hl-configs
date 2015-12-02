@echo off

echo so %~dp0init.py > %HOME%\.gdbpyext

if exist %HOME%\.gdbinit del %HOME%\.gdbinit
mklink %HOME%\.gdbinit %~dp0.gdbinit
if %ERRORLEVEL% NEQ 0 goto COPY
exit /b 0

:COPY
cp .gdbinit %HOME%\.gdbinit

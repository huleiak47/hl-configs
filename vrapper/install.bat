@echo off

if exist %HOME%\_vrapperrc del %HOME%\_vrapperrc
mklink %HOME%\_vrapperrc %~dp0\_vrapperrc
if %ERRORLEVEL% NEQ 0 goto COPY
exit /b 0

:COPY
cp _vrapperrc %HOME%\_vrapperrc

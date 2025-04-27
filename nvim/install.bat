rd /S /Q %LOCALAPPDATA%\nvim
REM rd /S /Q %LOCALAPPDATA%\nvim-data

mklink /D %LOCALAPPDATA%\nvim %~dp0\nvim
REM mklink /D %LOCALAPPDATA%\nvim-data %~dp0\nvim-data

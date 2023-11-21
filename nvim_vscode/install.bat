rd /S /Q %LOCALAPPDATA%\nvim
rd /S /Q %LOCALAPPDATA%\nvim-data

mklink /D %LOCALAPPDATA%\nvim %~dp0\nvim
mklink /D %LOCALAPPDATA%\nvim-data %~dp0\nvim-data

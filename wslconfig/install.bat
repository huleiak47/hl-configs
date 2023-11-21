if exist %USERPROFILE%\.wslconfig del %USERPROFILE%\.wslconfig
mklink %USERPROFILE%\.wslconfig %~dp0\.wslconfig

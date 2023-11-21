
if exist %USERPROFILE%\.crossnote\style.less del %USERPROFILE%\.crossnote\style.less
if not exist %USERPROFILE%\.crossnote mkdir %USERPROFILE%\.crossnote
mklink %USERPROFILE%\.crossnote\style.less %~dp0style.less

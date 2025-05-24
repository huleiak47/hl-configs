@echo off

cat >%TMP%\cmake_format_temp.cmake

call cmake-format %TMP%\cmake_format_temp.cmake

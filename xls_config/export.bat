@echo off
set EXPORT_PATH=..\gameserver\src\main\resources\xls_config
mkdir %EXPORT_PATH%
for %%s in (xlsx\*.xlsx) do (
echo %%~ns
.\excel2json\excel2json.exe -e %%s -j %EXPORT_PATH%\%%~ns.json -a true -h 2 
) 

pause
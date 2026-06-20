@echo off

for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd_HH-mm-ss"') do set TS=%%i

MSP430Flasher.exe -r [fw_msp_%TS%_bsl.hex,BSL]
MSP430Flasher.exe -r [fw_msp_%TS%_info.hex,INFO]
MSP430Flasher.exe -r [fw_msp_%TS%_main.hex,MAIN]

REM MSP430Flasher.exe -r [fw_msp_%TS%_all.hex,0x0000-0xFFFF]

hex2bin.exe fw_msp_%TS%_bsl.hex
hex2bin.exe fw_msp_%TS%_info.hex
hex2bin.exe fw_msp_%TS%_main.hex

pause
@echo off
set PATH=%PATH%;c:\Program Files\avrdude\
avrdude.exe -p t85 -c usbasp -P usb -v -U flash:w:./Debug/tvbgone.hex:i
pause

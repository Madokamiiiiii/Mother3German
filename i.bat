@echo off
@echo ---------------------------------------------------------
@echo Converting non-script text files to data files
@echo ---------------------------------------------------------
@echo.
@textconv
@echo.
@echo.
@echo ---------------------------------------------------------
@echo Copying base ROM (mother3.gba) to new test ROM (test.gba)
@echo ---------------------------------------------------------
@echo.
@copy mother3j.gba test.gba
@echo.
@echo.
@echo ---------------------------------------------------------
@echo Converting audio .snd files to data files
@echo ---------------------------------------------------------
@echo.
@soundconv readysetgo.snd lookoverthere_eng.snd
@echo.
@echo.
@echo ---------------------------------------------------------
@echo Creating pre-welded cast of characters & sleep mode text
@echo ---------------------------------------------------------
@echo.
@m3preweld
@echo.
@echo.
@echo ---------------------------------------------------------
@echo Compiling .asm files and inserting all new data files
@echo ---------------------------------------------------------
@echo.
@xkas test.gba m3hack.asm
@echo.
@echo.
@echo COMPLETE!
@echo.
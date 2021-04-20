@echo off
@echo ---------------------------------------------------------
@echo Converting non-script text files to data files
@echo ---------------------------------------------------------
@echo.
@move /Y custom_text.txt custom_text_TMP.txt > NUL
@move /Y enemynames_short.txt enemynames_short_TMP.txt > NUL
@move /Y castroll_names.txt castroll_names_TMP.txt > NUL
@move /Y special_itemdescriptions.txt special_itemdescriptions_TMP.txt > NUL
@python prepare_special_text.py custom_text_TMP.txt custom_text.txt
@python prepare_special_text.py enemynames_short_TMP.txt enemynames_short.txt
@python prepare_special_text.py castroll_names_TMP.txt castroll_names.txt
@python prepare_special_text.py custom_text_TMP.txt special_itemdescriptions.txt
@textconv
@fix_custom_text text_custom_text.bin
@rearrange_font font_mainfont.bin font_smallfont.bin font_castroll.bin font_mainfont_rearranged.bin font_castroll_rearranged.bin font_mainfont_used.bin font_smallfont_used.bin
@move /Y custom_text_TMP.txt custom_text.txt > NUL
@move /Y enemynames_short_TMP.txt enemynames_short.txt > NUL
@move /Y castroll_names_TMP.txt castroll_names.txt > NUL
@move /Y special_itemdescriptions_TMP.txt special_itemdescriptions.txt > NUL
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
@echo Freeing enemy graphics' space
@echo ---------------------------------------------------------
@echo.
@FreeSpace test.gba -v
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
@echo Checking overlap of the files that will be used
@echo ---------------------------------------------------------
@echo.
@python check_overlap.py m3hack.asm
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
@PAUSE
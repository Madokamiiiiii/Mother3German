NLZ-GBA Advance

--------
History:
--------

V 0.5:
-First public release.

V 0.7:
-Made inserting indexed graphics work.
-Disabled the ability to insert non-indexed graphics
for now.
-Fixed the bug of graphics disappearing when 
window is hidden into taskbar.
-Added the ability to rescan and load a nondefault NLZ file.

V 1.0
-Added the ability to insert non-indexed bitmaps and
the ability to edit their palette's ordering before
iserting.

V 1.1
-Fixed the ability to insert non-indexed bitmaps.
-Added the ability to tupe your own offset of editing.
If the uncompressing fails, error image is shown instead.
-Removed the whole notion of image number.
-Made resizing the GUI to show out off GUI parts of the picture.
-Added control for inserting offset.

V 1.5
-Made the ability to insert indexed bitmaps work.
-Fixed a bug in loading raw GBA graphics.

V 1.6
-Fixed the bug in palette orderer when bitmap has less than 17 colours.
-Added a messagebox warning if you don't write the changes into the ROM.

V 2.0
-Increased performance. Scanning is much faster than before.
-Bitmaps are now saved as indexed, not unindexed.
-Made offset selecter responce on first click.

V 2.1
-Even more performance boosts.
-Fixed a bug in bitmap->GBA conversion.

V 3.0
-Added the ability to load compressed palettes.
-Added 256 colour mode.
-Fixed a minor bug.

V 3.5
-Fixed a minor bug in repointing.
-Added ability to change pointers when repointing.
-Made widht handling into a numeric up-down box.

V 4.0
-Added the ability import palette to the ROM.

V 4.1
-Added a numeric box for image index, so you won't 
have to remeber the offset where the image is. I
also re-arraged most of the code, which may cause 
glitches.

V 5.0
-Added the ability to edit uncompressed graphics like 
compressed ones.
-Replaced the Domain up/down box that holds offset 
with normal textbox.

----
GUI:
----

Main GUI:
-Load ROM:
Loads a ROM for editing. If it's the first time
editing the ROM, you'll be asked if you want to scan
the ROM. Answer yes, othervise you aren't going to get 
much use of this program.
-Load non default nlz file:
Load graphics and palette offsets from a non default nlz 
file. Old offsets will be forgotten.
-Load a palette file:
Load a palette file that can be used to view the graphics.
-Re Scan:
Scans the ROM again and replaces the old offsets with new.
-Exit:
Exit's the program.

-Compressed graphics:
Controls weather NLZ-GBA is in compressed or 
uncompressed format.
-Widht:
Controls the widht of the drawn image.
-Image:
The index of the image relative to other images in 
compressed mode.
-Height:
Chooses the height of the graphics drawn on the screen
in uncompressed mode.
-Offset:
Offset of the image. 'nuff said. Type your own offset.
-Amount of added blocks:
Shows the amount of 8x8 pixel blocks that are added
in order to the image to be rectangle. The blocks are
added starting from the lower right corner and 
continuing to the left until all blocks are placed.
-Save as bitmap:
Saves the currenty displayed image either as 
compressed(.png or .gif) or uncompressed(.bmp) bitmap.
-Import a bitmap:
Imports a bitmap for view.
-Raw dump:
Dumps raw, uncompressed GBA graphics.
-Load raw:
Imports raw GBA graphics.
-Write to ROM:
Writes the changes to ROM. NOTE: No changes are saved to the ROM
until this button is pressed.

- 16/256 colours:
Changes the colour mode which the graphics are viewed.
-Gray scale:
Viewes graphics in gray scale palette.
-Load a palette file:
Loads a palette from a .pal file. 
-Use palette's from a PAL file:
Uses palette's from a PAL file to display graphics.
-Compressed ROMPalette:
If the palette can be uncompressed with LZ77, this can
be checked in order to view the graphics with 
uncompressed palette.
-Palette from a PAL file:
In 16 Colour mode, changes the palette that is used to
view the graphics.
-ROM palette offset:
Changes the offset of ROM palette. Assumes GBA palette
format. Each graphics have a different palette offset in 
compressed mode and they are saved along side with 
scanning results. Default offset for all is 0.


Palette editor:
-Color:
Click one to highlight it and click another to have them 
switch places. The row determines colors' position in palette.

WriteToROM:
-Offset: The offset where the graphics will be inserted.
-Abort if new data is bigger: Aborts if new data is bigger. 
Ignored if data is repointed.
-Repoint pointers: Search and change pointers.

-------------
Future plans:
-------------

-Deep scan (not likely, normal is good enough).
-Ability to open several roms in one program.
-Support for copy/pasting from image editing 
programs such as Paint.NET

--------
Credits:
--------

-Nintenlord: For making this utility.
-Members of FEU: Suggestions ,bug reports 
and testing.
-loadingNOW: For making unLZ-GBA, the 
spiritual precessor of this utility.
-You: For having the brains to read the
Readme. You're awesome!

------------
Legal stuff:
------------

This program and everything it comes with, referred 
as product from now on, is delivered as is and 
has no warranty what so ever.
You can modify, add and distribute the product as
you wish, but the origin of the product must not be 
misinterpretted by anyone and this README.txt file must
remain included and unmodified.
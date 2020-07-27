-- file header format:
-- 0x00-0x03: graphics section offset (not graphics start!)
-- 0x04-0x07: palette section offset (not palette start!)
-- 0x08-0x0B: cell section offset??? can be ignored
-- 0x0C-0x0F: anim section offset??? can be ignored
-- 0x10-0x13: amount of files? seems to be 0100 0000 always

-- graphics section format:
-- 0x00-0x03: ????
-- 0x04-0x07: graphics offset
-- we don't need the rest of the header

-- palette section format:
-- 0x00-0x03: not a clue. don't need it.
-- 0x04-0x07: num of palettes. don't really need it either.
-- rest is palette data

-- 'cell' section format:

-- 'anim' section format:
-- 0x00-0x03: numFrames, or numAnimations. 
-- 0x04-(0x04 + 4*numAnimations): array of DWORDs. each points to data below, relative to the start of the anim section
-- the rest: animation data. 8 bytes per frame.

paletteSec = readDWORD(0x04);
cellSec = readDWORD(0x08);

if readDWORD(0x10) ~= 1 then
    invalid = 'Value at 0x10 is not amount 1, but: ' .. readDWORD(0x10);
end

paletteSize = cellSec - paletteSec - 0x04;
paletteOffset = paletteSec + 0x04;
setData2(paletteOffset, paletteSize);
format = 5;

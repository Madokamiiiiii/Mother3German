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
-- 0x00-0x07: not a clue. don't need it either.
-- rest is palette data

graphicsSec = readDWORD(0x00);
paletteSec = readDWORD(0x04);

if readDWORD(0x10) ~= 1 then
    invalid = 'Value at 0x10 is not amount 1, but: ' .. readDWORD(0x10);
end

graphicsOffset = readDWORD(graphicsSec + 0x04) + graphicsSec;
graphicsSize = paletteSec - graphicsOffset;
setData2(graphicsOffset, graphicsSize);
tiled = true;
format = 3;

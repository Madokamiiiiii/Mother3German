-- 0x00-0x03: "CG8 "
-- 0x04-0x07: 0405 0000 constant?
-- 0x08-0x09: 0001 constant?
-- 0x0A-0x0B: ???? flags?
-- 0x0C-0x0F: padding?
-- 0x10-0x13: ???? format?
-- 0x14-0x17: image data length
-- 0x18-0x1B: palette data length
-- 0x1C-0x1F: amount of tiles
-- 0x20-0x23: amount of colours in palette?
-- 0x24-0x27: image offset
-- 0x28-0x2B: palette offset
-- 0x2C-0x2F: cell data offset (0 if not present)

if readString2(0x00, 0x04) ~= 'CG8 ' and readString2(0x00, 0x04) ~= 'CG4 ' then
    invalid = 'Improper CG8/4 file; invalid magic header ' .. readString2(0x00, 0x04);
    
elseif readDWORD(0x04) ~= 0x0504 then
    invalid = 'Improper CG8/4 file; value at 0x04 is not 0405 0000';
    
elseif readWORD(0x08) ~= 0x0100 then
    invalid = 'Improper CG8/4 file; value at 0x08 is not 0x0001';
    
elseif readDWORD(0x0C) ~= 0 then
    invalid = 'Improper CG8/4 file; DWORD at 0x0C is not padding, but ' .. readDWORD(0x0C);
    
else

    imgOffset = readDWORD(0x24);
    imgLength = readDWORD(0x14);
    
    setData2(imgOffset, imgLength);
    
    tiled = true;
    
    if string.find(filename, 'CG8') then
        format = 4;
    else
        format = 3;
    end
    tilesize = {8, 8}; 

end










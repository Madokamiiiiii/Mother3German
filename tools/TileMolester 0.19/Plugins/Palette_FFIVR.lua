
-- only f4dat files starting with 0020 AF30 are image/palette files
if readDWORD(0) == 0x30AF2000 then

    -- check if the rest of the header is the same as well (since I don't feel like checking all of them)
    if readlDWORD(0x4) ~= 0x1 or
        readlDWORD(0x8) ~= 0xC or
        readlDWORD(0xC) ~= 0x220 then
        invalid = 'unrecognised f4dat file; first 0x10 bytes of header are different: ' .. toHexadecimal(readlDWORD(0xC));
    elseif readlDWORD(0x10) ~= 0x14 or
            readDWORD(0x14) ~= 0x1 or
            readlDWORD(0x18) ~= 0x2 or
            readlDWORD(0x1C) ~= 0x20 then
            invalid = 'unrecognised f4dat file; second 0x10 bytes of header are different.'
    else
    
        paletteSize = 0x200;
        paletteOffset = 0x20;
        setData2(paletteOffset, paletteSize);
        format = 5;
        order = 'RGB';
        bigendian = false;  
    end
    
else
    
    -- the file is all palette, 3Bpp BGR LE
    setData(0);
    order = 'BGR';
    bigendian = false;
    format = 6;

end

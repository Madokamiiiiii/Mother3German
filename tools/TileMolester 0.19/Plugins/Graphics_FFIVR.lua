
-- only f4dat files starting with 0020 AF30 are image/palette files
if readDWORD(0) == 0x30AF2000 then

    -- check if the rest of the header is the same as well (since I don't feel like checking all of them)
    if readlDWORD(0x4) ~= 0x1 or
        readlDWORD(0x8) ~= 0xC or
        readlDWORD(0xC) ~= 0x220 then
        invalid = 'unrecognised f4dat file; first 0x10 bytes of header are different.';
    elseif readlDWORD(0x10) ~= 0x14 or
            readDWORD(0x14) ~= 0x1 or
            readlDWORD(0x18) ~= 0x2 or
            readlDWORD(0x1C) ~= 0x20 then
            invalid = 'unrecognised f4dat file; second 0x10 bytes of header are different.'
    else
    
        graphicsOffset = 0x260;
        -- all we need to know form the graphics header is height & width, wich are the first 2 littleendinan WORDs
        height = readlWORD(0x220);
        width = readlWORD(0x222);
        
        if height % 4 ~= 0 then
            height = height + 4 - (height % 4);
        end
        if width % 8 ~= 0 then
            width = width + 8 - (width % 8);
        end
        
        graphicsSize = height * width; -- 8bpp, so 1 byte per pixel
        
        setData2(graphicsOffset, graphicsSize);
        format = 4;
        bigendian = false; -- doesn't matter, but set it anyway
        tilesize = {};
        tilesize.x = 8;
        tilesize.y = 4; 
        tiled = true; 
        
    end
    
end

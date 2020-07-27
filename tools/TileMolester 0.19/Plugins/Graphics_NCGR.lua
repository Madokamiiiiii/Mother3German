-- Example plugin for NCGR (and NCBR) files
 
-- check the magic header
if readString2(0x00,0x04) ~= 'RGCN' then
    invalid = 'Improper NCGR file; invalid magic header ' .. readString(0,4);
-- we should check the magic constant, but since it seems to vary sometimes I'll skip it

-- check if the file size is correct 
elseif filesize ~= readDWORD(0x08) then
    invalid = 'Improper NCGR file; value at 0x08 is not the file size;\n' .. filesize .. ' != ' .. readDWORD(0x08);
    
-- check the hedaer size
elseif readWORD(0xC) ~= 0x10 then
    invalid = 'Improper NCGR file; value at 0x0C is not the header size';
    
-- we ignore the amount of sections. The proper way to implement this plugin 
--  would probably be to skip sections until the CHAR section is found, but I've never
--  seen a NCGR file without a CHAR section as its first section

-- check the CHAR magic header
elseif readString2(0x10,4) ~= 'RAHC' then
    invalid = 'Improper NCGR file/improper plugin; CHAR file not the first section';
    
else
    
    -- ignore the section size at 0x14
    
    -- read the width&height (and induce 'tiled')
    h = readWORD(0x18);
    w = readWORD(0x1A);
    if h < 0xFFFF then
        height = h * 8;
    end
    
    if w < 0xFFFF then
        width = w * 8;
    end
    
    -- read the format
    format = readDWORD(0x1C);
    
    -- read the word that could be the tiled-flag, but probably isn't
    tiled = readWORD(0x20) == 0;
    
    -- generally, the only tilesize used for tiled NCGRs is 8x8
    if tiled then
		tilesize = {8, 8};
	end
    
    -- set the data after reading the image length
    setData2(0x30, readDWORD(0x28));

end


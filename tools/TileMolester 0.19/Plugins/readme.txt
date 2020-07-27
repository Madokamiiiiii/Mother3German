
1. Bindings

Bindings can either point to a user-defined plugin, or to a built-in method. 
The following built-in methods are available:
Graphics:
- LoadFileAsNCGR
- LoadFileAsGFNT
Palette:
- LoadFileAsNCLR
- LoadFileAsGFNT

Bindings also have a FilterSet, which determines which files are bound by the Binding.
The 'method' of a FilterSet determines how the sub-Filter(Set)s are handled. A FilterSet 
passes a file under these conditions:
- AND: all sub-Filter(Set)s must pass
- NAND: at least one sub-Filter(Set) must not pass
- OR: at least one sub-Filter(Set) must pass
- NOR: no sub-Filter(Set) can pass
- XOR: exactly one sub-Filter(Set) must pass, the rest must not
A Filter can work in two ways: it can look at the first few bytes (usually a magic header) of 
a file, and it can look at the filename. For the first option, you need to provide the ASCII
characters the magic header should start with. For the second option, the Filter will pass if
the provided regular expression matches somewhere in the filename (including the folders it is in)

A Binding can be enabled or disabled. If it is disabled (set enabled to "0"), it will bind to
no file.

If a file can be bound by more than one Binding, the first enabled one is used (they are read from 
top to bottom).



2. Plugins

Plugins of TiledGGD are written in Lua. For a reference manual, see http://www.lua.org/manual/5.1/
Warning: do not use overly large tables. It can crash the Lua parser/interpreter.

For the plugin to be able to do anything, I predefined some functions and variables.
Functions
- read(offset) : function that returns the byte-value at the specified offset. If the offset is
				 out of bounds, it returns nil. Offset is 0-based.
- read2(offset, maxlength) : function that returns a 1-dimensional table with in it the byte-values 
							 from offset, with the specified maximum length. The only reason for the
							 table to be shorter than maxlength, is that offset+length is out of 
							 bounds. Offset is 0-based.
- readWORD(offset) : function that reads a WORD (2 bytes, big-endian style) from offset. Offset is 
					 0-based. Note that a WORD is an unsigned value; 0xFFFF == 65535.
- readlWORD(offset) : same as readWORD, only reads a little-endian WORD.
- readDWORD(offset) : function that reads a DWORD (4 bytes, big-endian style) from offset. Offset
					  is 0-based. Note that DWORD is a signed value; 0xFFFFFFFF == -0x7FFFFFFF.
- readlDWORD(offset) : same as readDWORD, only reads a little-endian DWORD.					  
- readString(offset) : function that reads a string from offset. It will only stop reading until the 
					   end of the file has been reached, or a \0 has been read. Offset is 0-based.
- readString2(offset, maxlength) : same as readString(offset), only the resulting string will not be 
								   longer than maxlength.
- stringToInt(str) : converts a string into an integer value, by reading the characters as bytes in 
					 a big-endian fashion. Only the first 4 characters of the string will be read,
					 the rest (if any) is ignored.
- setData(offset) : sets from where the actual data starts. The data ends at the end of the file.
- setData2(offset, length) : sets from where the actual data starts, and how long the actual data is. 
							 If this function and setData(offset) is not used, setData(0) is assumed.
- addData(offset) : similar to setData. However, the already present data will not be deleted, and 
					the read data will be added instead.
- addData2(offset, length) : similar to setData2. However, the already present data will not be 
							 deleted, and the read data will be added instead.
- toHexadecimal(number) : converts an integer into its hexadecimal representation (outputs a string)
					   
Variables
- filesize : the length of the data in bytes.
- filepath : the path of the file, including the name. All path-separators are '/'s.
- filename : the name of the file, without the path.

The following variables can be set for any type of plugin:
- invalid : string that will be displayed at the end as an error message. The file will not use the
		    plugin if this variable is set.
- warning : string that will be displayed at the end as a message. Will not prevent the plugin 
			from being applied.
- format : integer indicating the format of the graphics or palette. It can only be one of these 
		   values: (graphics format | palette format)
			- 1 ( 1 bpp | N/A)
			- 2 ( 2 bpp | N/A)
			- 3 ( 4 bpp | N/A)
			- 4 ( 8 bpp | N/A)
			- 5 (16 bpp | 2 Bppal)
			- 6 (24 bpp | 3 Bppal)
			- 7 (32 bpp | 4 Bppal)
			Invalid values are made known to the user, and are ignored afterward. If the value is 
			not set (or invalid), the format will not change.
			Note that these (or at least the 3 and 4) are the values most commonly used to denote 
			what format an image is.
- bigendian : Flags if the data is BigEndian. (boolean, so either true/false) If it is false, the
			  data is LittleEndian.
- tilesize : a table with two entries (x and y, or 0 and 1), indicating the desired tile-size. The 
			 tile size will not be altered if this is not set. Invalid values will be made known to
			 the user, and ignored afterwards. The indices x and y take precedence over 0 and 1.
- tiled : boolean variable indicating if the data is tiled or not. An invalid value will be
		  ignored.
		  
The following variables can also be set for any type of plugin, but will be ignored for graphics
with format < 5.
- order : The order of the palette. It is a 3-letter string containing the letters R, G and B in an 
		  arbitrary order.
- alphaAtStart : boolean value (true or false), indicating if the alpha value of the colour is
				 located at the start of the colour value. If set to false, the alpha value is 
				 located at the end of the colour value.
- ignoreAlpha : boolean value (true or false), indicating if the alpha value of colours should be
				ignored. If set, all colours will be fully opaque.
- enableAlphaStrech : boolean value (true or false), indicating if alpha stretch is enabled.
- alphaStretch : a table with two entries (min and max, or 0 and 1). When alpha stretch is enabled, 
				 the alpha value of the colours will be stretched, so that the minimum value 
				 (min or 0) and anything below it is mapped onto alpha value 0, and the maximum
				 value (max or 1) is mapped onto alpha value 255. Anything in-between will keep its
				 relative position between the given minimum and maximum values.

The following variables can be set for each Graphics-plugin:
- width : integer indicating what the width of the canvas should be. The width will not be altered 
			if this is not set. Invalid values are made known to the user, and ignored afterward.
- height : similar as width, only for the height of the canvas.

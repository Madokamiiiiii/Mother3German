//===========================================================================================
//===========================================================================================
// byuu wrote this code. It takes the 8-bit script from the ROM and converts it to 16-bit
// in a custom area of RAM.
//
// Control codes have to be handled in a special way, due to issues with having each letter
// be a byte now. byuu devised this system:
//
//   Normally, control codes are FFXX, but we're now storing them as F0 through FF, with 
//   the lower nybble dictating how long the following arguments string is * 2.
//
//     #0xf0 - #0xff = control code
//     format:
//     <%1111 llll> l = length * 2
//     #0xff is a special case for the block end command,
//     it will write #0xffff and return from this routine
//     examples:
//     $ff = $ffff
//     $f0,$01 = $ff01
//     $f1,$e1,$0123 = $ffe1 $0123
//
// Going into this routine, r4 has the RAM write offset, and r5 has the ROM read offset.
//===========================================================================================
//===========================================================================================

main_script_hacks:

define space 0x40
define menuspaceyes 0xE8
define menuspaceno 0xE9
define nowidth 0xF0EB

.script_convert:
cmp  r0,r1
bne .load_script
bl  $08021b5c

.load_script:
lsl  r5,r5,#4          // Shift one nybble to the left. This will create a negative number
                       // if we're reading from ROM.
bmi  .dorom            // Branch if we're reading from the ROM
lsr  r5,r5,#4          // Otherwise, don't do anything
  
b    .jeffhack         // Perform jeffman's menu cursor coord hack
bl   $08021b1c         // Get outta here!

//-------------------------------------------------------------------------------------------

.dorom:                // We're reading from the ROM if we're executing this code
lsr  r5,r5,#4          // Fix r5

push {r1}              // adding this code in to fix the 4+ option special menus
ldr  r0,=#0x2014304    // this value will tell if we're doing a special menu or not
mov  r1,#0x0
strb r1,[r0,#0]        // set the flag to 0 by default
pop  {r1}

push {r1-r4}           // now back to byuu's code
ldr  r4,=#0x2038000    // $2038000 - $203ffff is unused and will be our custom area of RAM
push {r4}

// ------------
ldrb r0,[r5,#0]        // Jeff hack - check for the [FE XX XX] custom hot springs lookup,
bl   .decode_byte
cmp  r0,#0xFE          // change the ROM pointer if necessary
bne  +
push {r0-r3}
ldrb r0,[r5,#1]        // load the line number
add  r5,#1
bl   .decode_byte
sub  r5,#1
push {r0}
ldrb r0,[r5,#2]
add  r5,#2
bl   .decode_byte
sub  r5,#1
mov  r1,r0
pop  {r0}

lsl  r1,r1,#8
add  r1,r0,r1
mov  r0,#13            // block 13 in r0, line # in r1
ldr  r2,=#0x936A6F8
lsl  r0,r0,#3          // address of pointer = 936A6F8 + (blocknum * 8)
ldr  r0,[r2,r0]
add  r2,r0,r2
sub  r2,#4
lsl  r1,r1,#1          // address of sub-pointer = r2 + (linenum * 2)
ldrh r1,[r2,r1]
mov  r3,#0xFF
lsl  r3,r3,#8
add  r3,#0xFF
-
add  r2,#2             // now we gotta loop until 0xFFFF is encountered
ldrh r0,[r2,#0]
cmp  r0,r3
bne  -
add  r5,r2,r1          // now we have a ROM pointer
pop  {r0-r3}
//----------

+

// ------------
push {r1}              // Jeff hack - check for the frog hint at the end of the game
ldr  r1,=#0x203FFF8
ldrh r0,[r1,#0]
ldrh r1,[r1,#2]              
cmp  r1,#20            // Frog's line is 20 in block 233
pop  {r1}
bne  .load_loop
cmp  r0,#233
bne  .load_loop
push {r0-r4,r6}           // Check the back+front battle pics
bl   extra_hacks.allenemies_backcheck
cmp  r0,#0
beq  .check_frontpics

// Load new ROM address for the frog (back + front pics)
mov  r0,#233
mov  r1,#53            // Altered line will be 233-53E
ldr  r2,=#0x936A6F8
lsl  r0,r0,#3          // address of pointer = 936A6F8 + (blocknum * 8)
ldr  r0,[r2,r0]
add  r2,r0,r2
sub  r2,#4
lsl  r1,r1,#1          // address of sub-pointer = r2 + (linenum * 2)
ldrh r1,[r2,r1]
mov  r3,#0xFF
lsl  r3,r3,#8
add  r3,#0xFF
-
add  r2,#2             // now we gotta loop until 0xFFFF is encountered
ldrh r0,[r2,#0]
cmp  r0,r3
bne  -
add  r5,r2,r1          // now we have a ROM pointer
b    +

.check_frontpics:
bl   extra_hacks.allenemies_frontcheck
cmp  r0,#0
beq  +

// Load new ROM address for the frog (front pics only)
mov  r0,#233
mov  r1,#52            // Altered line will be 233-52E
ldr  r2,=#0x936A6F8
lsl  r0,r0,#3          // address of pointer = 936A6F8 + (blocknum * 8)
ldr  r0,[r2,r0]
add  r2,r0,r2
sub  r2,#4
lsl  r1,r1,#1          // address of sub-pointer = r2 + (linenum * 2)
ldrh r1,[r2,r1]
mov  r3,#0xFF
lsl  r3,r3,#8
add  r3,#0xFF
-
add  r2,#2             // now we gotta loop until 0xFFFF is encountered
ldrh r0,[r2,#0]
cmp  r0,r3
bne  -
add  r5,r2,r1          // now we have a ROM pointer
+
pop  {r0-r4,r6}
// ----------------

.load_loop:
ldrb r0,[r5,#0]        // load byte from ROM
bl   .decode_byte      // decode it
add  r5,#1

cmp  r0,#0xEF          // test if value is control code
beq  .custom_cc
cmp  r0,#0xF0
bge  .control_code

strh r0,[r4,#0x0]      // if not, convert 8-bit char and store 16-bit result
add  r4,#2
b    .load_loop

//-------------------------------------------------------------------------------------------

.control_code:
cmp  r0,#0xff          // test for [END]
beq  .end_load

//mov  r1,r0             // r1 = r0 & 0x0F
//mov  r0,#0xF
//and  r1,r0
lsl  r1,r0,#0x1C
lsr  r1,r1,#0x1C       // simplified

mov  r0,#0xFF          // write control code flag
strb r0,[r4,#1]

ldrb r0,[r5,#0]        // copy next byte directly (0xnn -> 0xffnn)
bl   .decode_byte      // decode byte again

add  r5,#1
strb r0,[r4,#0]
add  r4,#2

.control_code_loop:
tst  r1,r1             // test if end of control code string
beq  .load_loop
sub  r1,#1

ldrb r0,[r5,#0]        // copy word value from ROM to RAM, and loop
bl   .decode_byte      // decode first byte of word argument
strb r0,[r4,#0]

add  r5,#1
ldrb r0,[r5,#0]        // read next byte of word argument
bl   .decode_byte      // decode it
strb r0,[r4,#1]
add  r5,#1
add  r4,#2
b    .control_code_loop

.end_load:
strb r0,[r4,#0]        // write end flag (r0 always equals #0xFF here)
strb r0,[r4,#1]

pop {r5}               // set read offset to $02038000
pop {r1-r4}            // restore various registers

//-------------------------------------------------------------------------------------------
// This is Jeff's menu coordinate hack. Possible space characters: 40, A5, A6
// Here's the plan, and it can be accomplished without making a menu choice terminator char.
// Check until [06 FF XX XX] is encountered.
// If not encountered, exit the subroutine.
// If encountered, loop until a non-space character is encountered.
// Begin accumulating the letter widths until A5 or A6 is encountered.
// Add the width of A5 or A6 to the width accumulator.
// Store the width accumulator to 201AB3C.
//
// r5 has the address to the already-expanded text.
//-------------------------------------------------------------------------------------------

.jeffhack:

push {r0,r2-r4}
mov  r3,#0             // loop counter
ldr  r2,=#0xFF06       // we're looking for the FF06 control code

.menucheck:
ldrh r0,[r5,r3]
cmp  r0,r1
beq  .endall
add  r3,#2
cmp  r0,r2
bne  .menucheck
add  r3,#2

.choicecheck:
ldrh r0,[r5,r3]
add  r3,#2
cmp  r0,#{space}
beq  .addwidths
cmp  r0,#{menuspaceyes}
beq  .addwidths
cmp  r0,#{menuspaceno}
beq  .addwidths
b    .choicecheck

.addwidths:
mov  r2,#0
mov  r4,#8
ldr  r4,=#0x8D1CE78

.addwidths_loop:
ldrh r0,[r5,r3]
cmp  r0,#{menuspaceyes}
beq  .endwidths
cmp  r0,#{menuspaceno}
beq  .endwidths
add  r3,#2
ldrb r0,[r4,r0]
add  r2,r2,r0
b    .addwidths_loop

.endwidths:
ldrb r0,[r4,r0]
add  r2,r2,r0
ldr  r4,=#0x201AB3C    // check this later
strb r2,[r4,#0x0]
  
.endall:
pop {r0,r2-r4}
bl $08021B1C

//-------------------------------------------------------------------------------------------
// This is Mato's custom control code hack. The format of our custom control codes is
// [EF 00]. When encountered, the game will look into the custom item info table we've
// inserted into the ROM and replace [EF 00] with the proper string. This is used mainly
// for messages where you find an item, so we can use "a/an/the/some" and stuff like that.
//-------------------------------------------------------------------------------------------

.custom_cc:
push {r1-r2}

ldrb r0,[r5,#0]        // load the argument byte
bl   .decode_byte
sub  r0,#0x10

mov  r2,r0             // r2 will be an offset into the extra item data slot

// ----------------
lsr  r0,r0,#7          // Jeff hack - if bit 0x80 of the arg byte is set,
cmp  r0,#0             // use 201AAF8 instead for the item address
beq  +
ldr  r0,=#0x201AAF8
sub  r2,#0x80          // re-adjust r2 by unsetting the 0x80 flag
b    .custom_cc_adrcheck
+
ldr  r0,=#0x2014324    // this is where the current item # will be saved by another hack
.custom_cc_adrcheck:
// ----------------

ldrh r0,[r0,#0x0]      // load the current item #
mov  r1,#6
mul  r0,r1             // offset = item ID * 6 bytes
ldr  r1,=#0x8D090D9    // this is the base address of our extra item data table in ROM
add  r0,r0,r1          // r0 now has the proper address of the current item's data slot
ldrb r0,[r0,r2]        // load the proper line # to use from custom_text.bin
mov  r1,#40
mul  r0,r1             // calculate the offset into custom_text.bin
ldr  r1,=#0x8D0829C    // load r1 with the base address of our custom text array in ROM
add  r0,r0,r1          // r0 now has the address of the string we want

mov  r1,r4
bl   custom_strcopy    // r0 returns from this with the # of bytes copied
add  r4,r4,r0
add  r5,#1

pop  {r1-r2}
b    .load_loop


//===========================================================================================
// This is Jeff's fix for the PK [FAVORITETHING] stuff. The game had a couple hard-coded
// things that messed up with our English hack, but this code here fixes all that.
// This appears to affect the main menus and battle stuff too. Lucky us!
//===========================================================================================

.pk_fav_fix:
lsl  r0,r7,#1
add  r0,r0,r2
ldrh r0,[r0,#0]
strh r0,[r1,#4]
mov  r0,#0x40
strh r0,[r1,#2]
bx   lr

//===========================================================================================
// These code snippets save the value of the currently active item to a halfword in RAM.
// We need to have this value easily available when we do our custom control code stuff
// later on.
//===========================================================================================

.current_item_save1:
mov  r3,r1
ldr  r0,=#0x2014324
strh r1,[r0,#0]
bx   lr

//-------------------------------------------------------------------------------------------

.current_item_save2:
cmp  r0,#0
beq  +

push {r6}
ldr  r6,=#0x2014324
strh r0,[r6,#0]
pop  {r6}

+
str  r0,[r2,#0]
add  r0,r5,#1
bx   lr



//===========================================================================================
// This is Paul's chapter end 8-bit script conversion code. It converts the 8-bit text in
// the ROM to the 16-bit format the game expects.  Code to branch from is located at 08027F68.
//
// r0 contains the read location
// r6 should contain the read location we started with, except in RAM
// r0 should contain the next byte on return
//
// Text wil be unpacked at 2038000 temporarily. This area is supposedly unused by the game.
//
// Note that this hack actually applies to much more than just chapter end text. It affects
// a whole bunch of Block 0 text.
//===========================================================================================

.chapter_end_convert:

// ------
// Jeff hack - store r6, which is the current line number of Block 0, to 203FFFA
//           -> it gets read later by extra_hacks.scrolly_text_fix
//           - store $0000 to 203FFF8 (block number)
push {r0,r6}
ldr  r0,=#0x203FFF8
strh r6,[r0,#2]
mov  r6,#0
strh r6,[r0,#0]
pop  {r0,r6}
// ------

lsl  r0,r0,#4                // Shift one nybble to the left. This will create a negative number if we're reading from ROM.
bmi  +                       // Are we copying from the ROM? If so, we need to expand the text to 16-bit 
lsr  r0,r0,#4                // Shift the address back where it belongs 
pop  {r4-r6,pc}              // If we haven't jumped, then we're already working from RAM, so return now

//--------------------------------------------------------------------------------------

+ 
push {r0-r1}              // adding this code in to fix the 4+ option special menus
ldr  r0,=#0x2014304       // this value will tell if we're doing a special menu or not
mov  r1,#0x0
strb r1,[r0,#0]           // set the flag to 0 by default
pop  {r0-r1}              // now back to paul's regular code


lsr  r0,r0,#4                // Shift the address back where it belongs 
push {r1-r3,r7}              // save these for later
ldr  r1,=#0x2038000

.chap_end_loop:
push {r0,r5}
mov  r5,r0
ldrb r3,[r0,#0]              // Load r3 with our next byte
mov  r0,r3
bl   .decode_byte            // decode it
mov  r3,r0
pop  {r0,r5}

cmp  r3,#0xEF                // is this a custom control code?
beq  .chap_end_custom_cc
 
cmp  r3,#0xF0               // Is this a control code? 
bcs  .chap_end_cc            // If so, do a 16-bit copy. 
strh r3,[r1,#0]              // Store it at r1 
add  r1,r1,#2                // Increment our destination by 2 
add  r0,r0,#1                // Increment our source by 1 
b    .chap_end_loop          // Loop for the next byte 

//--------------------------------------------------------------------------------------

.chap_end_cc:
cmp  r3,#0xFF
beq  .chap_end_end           // Get out of here if it's a terminator  

sub  r3,#0xF0
mov  r6,#0xFF
strb r6,[r1,#1]
ldrb r6,[r0,#1]              // Load the control code command
push {r0,r5}
add  r5,r0,#1
mov  r0,r6
bl   .decode_byte            // decode it
mov  r6,r0
pop  {r0,r5}

strb r6,[r1,#0]              // Store it
add  r0,r0,#2                // Add two to the address we're supposed to read from 
add  r1,r1,#2                // Add two to the destination 

-
cmp  r3,#0x0                 // Does r3 == 0?
beq  .chap_end_loop          // Done with copy, get the next byte  
ldrb r6,[r0,#1]
push {r0,r5}
add  r5,r0,#1
mov  r0,r6
bl   .decode_byte            // decode it
mov  r6,r0
pop  {r0,r5}
lsl  r6,r6,#8

ldrb r4,[r0,#0]
push {r0,r5}
mov  r5,r0
mov  r0,r4
bl   .decode_byte            // decode it
mov  r4,r0
pop  {r0,r5}

add  r6,r6,r4                // r0 should be loaded with the next argument 
strh r6,[r1,#0]              // Store the destination 
sub  r3,#1                   // Subtract one from remaining arguments 
add  r1,#2                   // Add two to the destination 
add  r0,#2                   // Add two to the address we're supposed to read from 
b -                          // Loop for more data 

//--------------------------------------------------------------------------------------

.chap_end_end:
mov  r3,#1
neg  r3,r3
strh r3,[r1,#0]              // Store FFFF into r1
ldr  r0,=#0x2038000

pop  {r1-r3,r7}              // restore registers to previous values
pop  {r4-r6,pc}              // And return 

//--------------------------------------------------------------------------------------
// There are no real custom CCs needed in chapter end text, but most of the "you got item"
// script lines are in Block 0, so that's why this is here.
//--------------------------------------------------------------------------------------

.chap_end_custom_cc:
push {r0}
push {r1-r2,r5}

add  r5,r0,#1
ldrb r0,[r0,#1]              // load the argument byte
bl   .decode_byte
sub  r0,#0x10

mov  r2,r0                   // r2 will be an offset into the extra item data slot

// ----------------
lsr  r0,r0,#7                // Jeff hack - if bit 0x80 of the arg byte is set,
cmp  r0,#0                   // use 201AAF8 instead for the item address
beq  +
ldr  r0,=#0x201AAF8
sub  r2,#0x80                // re-adjust r2 by unsetting the 0x80 flag
b    .chap_end_custom_cc_adrcheck
+
ldr  r0,=#0x2014324          // this is where the current item # will be saved by another hack
.chap_end_custom_cc_adrcheck:
// ----------------

ldrh r0,[r0,#0]              // load the current item #
mov  r1,#6
mul  r0,r1                   // offset = item ID * 6 bytes
ldr  r1,=#0x8D090D9          // this is the base address of our extra item data table in ROM
add  r0,r0,r1                // r0 now has the proper address of the current item's data slot
ldrb r0,[r0,r2]              // load the proper line # to use from custom_text.bin
mov  r1,#40
mul  r0,r1                   // calculate the offset into custom_text.bin
ldr  r1,=#0x8D0829C          // load r1 with the base address of our custom text array in ROM
add  r0,r0,r1                // r0 now has the address of the string we want

pop  {r1-r2,r5}
bl   custom_strcopy          // r0 gets the # of bytes copied as the return value
add  r1,r1,r0

pop  {r0}
add  r0,#2
b    .chap_end_loop

//===========================================================================================
// This makes the main script routine switch between only two glyph buffer structs.
// This lets us use as many letters as we want, rather than the limited # of the original
// game. It messes up the debug room menus, though.
//===========================================================================================

.move_to_next_glyph:
push {lr}
ldr  r1,=#0x2014304        // load the flag to tell if this is a 4+ menu option or not
ldrb r1,[r1,#0]
mov  r3,#1
cmp  r1,r3
bne  +                     // if equal, we need to manually copy to the screen, else skip

push {r0-r2}
mov  r1,r8
mov  r0,r8
add  r0,#8                 // r0 = start of current glyph in current struct
ldr  r1,[r1,#0]            // load r1 with the target address to display to
mov  r2,#0x60              // # of bytes to copy
bl   $8001A14              // perform the copy

mov  r1,r8
mov  r0,r8
add  r0,#0x68              // r0 = second half of glyph
ldr  r1,[r1,#0]
mov  r2,#0x80
lsl  r2,r2,#3
add  r1,r1,r2              // r1 = second part of target address
mov  r2,#0x60
bl   $8001A14              // perform the second copy
pop  {r0-r2}

+
ldr  r3,=#0x201C460
mov  r1,r8
cmp  r1,r3
bne  +
add  r3,#0xCC
+
mov  r8,r3
mov  r0,#0xC8
add  r6,r3,r0
pop  {pc}

//===========================================================================================
// If the text speed is set to Fast, some problems might show up if an odd # of letters
// is to be dealt with. These two little hacks add an extra blank letter (0xA9) to even
// things out if necessary.
//===========================================================================================

.insert_extra_letter1:
ldr  r2,=#0x2014300        // store the current letter address in RAM
str  r0,[r2,#0]

ldr  r2,=#0xFFF            // clobbered code
mov  r1,r2
bx   lr

//-------------------------------------------------------------------------------------------

.insert_extra_letter2:
push {r0-r4}
ldr  r4,=#0x2005C08        // skip all this if it's not Fast text speed
ldrb r4,[r4,#0]
lsr  r4,r4,#6              // r4 now has speed, 0 = fast, 1 = medium, 2 = slow
cmp  r4,#0                 // if it's not 0, skip all this
bne  +

ldr  r4,=#0x2027CB3
ldrb r0,[r4,#0]            // load the # of passes that are scheduled
cmp  r0,#1                 // if it's not 1, then skip all this extra junk
bne  +

mov  r1,#2
strb r1,[r4,#0]            // set it so we have 2 letters this cycle now too

ldr  r3,=#0x2014300
ldr  r3,[r3,#0]
ldr  r1,=#{nowidth}        // a space character
str  r1,[r3,#4]            // store the data

mov  r1,r8                 // increment the # of letters we've added
cmp  r1,#1
ble  +
add  r1,#1                 // don't increment if we're starting a new line I guess
mov  r8,r1

+
pop  {r0-r4}
ldr  r1,=#0x1444           // clobbered code
add  r0,r6,r1
bx   lr

//===========================================================================================

.change_clear_amount:
push {lr}
ldr  r1,=#0x400
bl   $8001ACC
pop  {r0}
add  r0,#2
bx   r0

//===========================================================================================
// This hack sets a flag whenever the line being processed is actually part of a special
// 4+ menu option line, like those used in the debug menu. Because the game handles the
// displaying of these lines differently, some special stuff has to be done to make these
// lines display fully. The default value is 0, which is set during byuu's 8-bit code hack.
//===========================================================================================

.set_specialmenuflag:
ldr  r0,=#0x2014304    // this value will tell if we're doing a special menu or not
mov  r1,#1
strb r1,[r0,#0]        // set the flag to 1

push {r0-r3}                // all this code here clears the bottom text line on the screen
ldr  r0,=#0x7777
ldr  r1,=#0x600C820
ldr  r2,=#0x1C0
push {r0}
mov  r0,sp
mov  r3,#1
lsl  r3,r3,#24
orr  r2,r3
swi  #0x0B
pop  {r0}

ldr  r0,=#0x7777
ldr  r1,=#0x600CC20
ldr  r2,=#0x1C0
push {r0}
mov  r0,sp
mov  r3,#1
lsl  r3,r3,#24
orr  r2,r3
swi  #0x0B
pop  {r0}
pop  {r0-r3}

mov  r0,r4             // clobbered code
mov  r1,#0
bx   lr

//===========================================================================================
// This hack fixes [FAVFOOD], but also affects [HINAWA], [FAVTHING] and [PLAYERNAME].
//===========================================================================================

.favfood_fix:
push {lr}
mov  r0,r1
mov  r2,#16        // default length
bl   check_name
cmp  r0,#0
beq  +
mov  r2,r0
+
mov  r0,r5         // clobbered code
pop  {pc}







.block0_text_fix1:
.flyover_fix1:
push {r4-r5,lr}
mov  r4,r2
sub  r5,r1,r0
mov  r0,r5
mov  r1,#4
bl   $8002FC0
mov  r5,r0
mov  r1,#0x32
bl   $8002FD4
lsl  r1,r0,#1
add  r1,r1,r0
lsl  r1,r1,#2
strh r1,[r4,#0]
mov  r0,r5
mov  r1,#0x32
bl   $8002FC0
ldr  r1,=#0x2016028
ldr  r2,=#0x11C89
add  r1,r1,r2
ldrb r1,[r1,#0]
mul  r0,r1
strh r0,[r4,#2]
pop  {r4-r5}
pop  {r0}
bx   r0


.block0_text_fix2:
.flyover_fix2:
lsl  r0,r0,#0x10
lsr  r0,r0,#0x10
lsl  r1,r1,#0x10
lsr  r1,r1,#0x10
mov  r2,#0x32
mul  r2,r1
add  r0,r0,r2
lsl  r0,r0,#2
ldr  r1,=#0x201E9D0
add  r0,r0,r1
bx   lr


//===========================================================================================
// These hacks change the address of Block 0 display stuff from 201B184 to 203C000.
//===========================================================================================

.blockzero_address:
ldr  r4,=#0x2014340
bx   lr



//===========================================================================================
// This hack decodes the main script, give r0 the raw, encoded value from the ROM, and
// this routine will return the decoded value back in r0. This routine is an important one.
//===========================================================================================

// Encoded byte is in r0, address is in r5
.decode_byte:
//push {r0-r3}

// Check if the intro code hack is present
//ldr  r0,=#0x100B5A2A // I scrambled the values around a bit so they're harder to
//lsr  r0,r0,#1        // find with a hex editor
//sub  r0,#1
//ldr  r0,[r0,#0]
//ldr  r1,=#0xF0E2
//sub  r1,#1
//ldr  r2,=#0xFC5F
//add  r2,#1
//lsl  r2,r2,#0x10
//add  r1,r1,r2
//cmp  r0,r1
//beq  +

// Spit out 'random' values
//ldr  r0,[sp,#0x14] // Whatever is here gets returned
//lsl  r0,r0,#0x18
//lsr  r0,r0,#0x18
//b    .dend

+

// Determine if it's even or odd
//lsl  r1,r5,#0x1F
//lsr  r1,r1,#0x1F
//cmp  r1,#0
//beq  .deven

// Odd
//     char = ((byte + 89) ^ code_byte) - 8
//     where code_byte = [13C5F2 + ((byte_address >> 1) % 10E)]
//lsr  r0,r5,#1
//mov  r1,#0x93
//lsl  r1,r1,#1
//swi  #6 // Div -> r1 = r0 % r1
//pop  {r0}
//ldr  r2,=#0x813C5D8
//ldrb r1,[r2,r1]         // r1 = gfx_byte
//add  r0,#89
//eor  r0,r1
//sub  r0,#8
//lsl  r0,r0,#0x18
//lsr  r0,r0,#0x18
//b    .dend

// Even
//     char = ((byte - 7) ^ gfx_byte) + 3
//     where gfx_byte = [1FAC000 + ((byte_address >> 1) % 3A10)]
//.deven:
//lsr  r0,r5,#1
//ldr  r1,=#0x3A20
//swi  #6 // Div -> r1 = r0 % r1
//pop  {r0}
//ldr  r2,=#0x9FAC000
//ldrb r1,[r2,r1]         // r1 = gfx_byte
//sub  r0,#7
//eor  r0,r1
//add  r0,#3
//lsl  r0,r0,#0x18
//lsr  r0,r0,#0x18

//.dend:
//pop  {r1-r3}
bx   lr

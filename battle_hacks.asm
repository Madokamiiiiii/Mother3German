battle_hacks:

//=========================================================================================== 
// Modifies the GetAddressofGlyphBitmap for mostly battle text stuff. The main reason for
// having this hack is that the routine uses it to load both 16x16 and 8x8 fonts, depending
// on inputs. But because of changes to our 16x16 stuff, the original code wouldn't work for
// both font sets. So we're gonna do a cheap fix for it. Basically, if it's gonna load a
// 16x16 font, we do new code, otherwise we jump to a carbon copy of the original routine's
// code.
//=========================================================================================== 

.get_glyph_address:
push {lr}
cmp  r2,#0x08                // if r2 == 8, load the 8x8 font instead
beq  +

mov  r0,#0x20                // if we're running this code, we're loading 16x16 stuff
add  r1,r5,#0
mov  r1,r5
mul  r1,r0
ldr  r0,[r4,#0x04]
add  r0,r0,r1
pop  {pc}                    // return

+
asr  r0,r0,#3                // if we're running this code, we're loading 8x8 stuff
add  r0,#1
mul  r0,r2
add  r0,#2
mov  r1,r5
mul  r1,r0
ldr  r0,[r4,#0x04]
add  r0,r0,r1
add  r0,#2
pop {pc}                     // return


//=========================================================================================== 
// this routine determines the number of tiles to be cleared when text in battle menus needs
// to be deleted. Normally, it assumes the # of tiles to be deleted = the # of letters in
// the current string. But with our VWF, this is no longer a valid assumption.
//
// The battle menu VWF has been modified so that the total VWF width of the current string
// can be found at the byte 0x2014300.
//
// We'll use this value, divide it by 10 (10 pixels wide per tile) and then round up. This
// will give us the total # of tiles to be cleared away.
//
// This final value needs to be in r0 when the routine ends. This value is stored by the
// game at the instruction at 806EBBE,
//=========================================================================================== 

.get_number_of_tiles_to_clear:
push {lr}

ldr  r1,=#0x2014300          // get the total width of the current string, stored here previously
ldrb r0,[r1,#0]              // r0 now has the width of the string

mov  r1,#10
swi  #6                      // now divide the total width by 10
cmp  r1,#0                   // r1 has the remainder, if it's non-zero,
beq  +                       // then we need to include the partial tile too
add  r0,r0,#0x01             // this includes the partial tile

+
cmp r0,#0x16                 // 0x16 is the highest possible, any higher and other stuff gets erased
bls +
mov r0,#0x16

+
pop {pc}                     // end of routine! r0 now has the correct # of tiles to erase



//=========================================================================================== 
// this centers various text that appears in the sound player and also does the custom
// control code text parsing for battle text. What a weird combination!
//
// r1 has the address of the current string
// we'll also need to re-perform some code that we clobbered
//
// Link to this from 8088E00.
//===========================================================================================

.prepare_custom_cc:

// Time to do some shuffling. This will get lr back with it's original value 
push {r5,lr}                 // We're going to use r5, so we need to keep it in 
ldr r5,[sp,#0x08]            // Load r5 with our former LR value? 
mov r14,r5                   // Move the former LR value back into LR 
ldr r5,[sp,#0x04]            // Grab the LR value for THIS function 
str r5,[sp,#0x08]            // Store it over the previous one 
pop {r5}                     // Get back r5 
add sp,#0x04                 // Get the un-needed value off the stack 

push {r0-r3,r6}

//-------------------------------------------------------------------------------------------

ldr  r6,=#0x8D1CE78          // r2 contains 08D1CE78, the width table's address
mov  r0,#0x0                 // initialize the total width counter
ldr  r3,=#0xFEFF             // r3 has the [END] code

//-------------------------------------------------------------------------------------------

-
ldrh r2,[r1,#0]              // load the current character

cmp  r2,r3                   // check for [END]
bgt  +                       // if encountered, exit the subroutine

add  r2,r6,r2                // get address of current character's width
ldrb r2,[r2,#0]              // load current char's width
add  r0,r0,r2                // add current width to the total

add  r1,r1,#0x02             // move to next character
b    -                       // do the loop over again

//-------------------------------------------------------------------------------------------

+
ldr  r6,=#0x2014300          // we're gonna store the final width here temporarily
strh r0,[r6,#0]

pop  {r0-r3,r6}              // restore registers now that we've done our stuff

ldrh r2,[r2,#0x2]            // original code we overwrote
lsl  r2,r2,#1                // multiply the pointer/offset by two
sub  r2,r2,r0
lsr  r2,r2,#0x1
sub  r2,#1


//==================================================================================
// it turns out r2 above calculates the length of the string, and this is used
// to allocate the correct amount of RAM to copy the string to. We need to modify
// this to take our custom battle control codes into account, so this hack has
// turned from mainly a sound player text centering hack to a string count hack.
//
// r2 now has the normal string length, we need to compensate for EF codes now.
//
// r1 has the string address at this point
//==================================================================================

push {r0}
push {r1}
push {r3}
push {r4}

ldr  r3,=#0xFFFF             // load r3 with the [END] code

//--------------------------------------------------------------------------------------------

-
ldrb r0,[r1,#1]              // load the high byte of the current character
cmp  r0,#0xEF                // see if this is a custom control code
beq  .custom_cc              // if so, jump to our special code to calculate its length unpacked

ldrh r0,[r1,#0]              // otherwise, load the current character
cmp  r0,r3                   // check if it's an [END] code
beq  +                       // if it is, then jump to the end of the routine

mov  r0,#0                   // this was a non-custom CC, so we're not gonna increment the count

.main_loop_next:
add  r2,r2,r0                // increment the letter count
add  r1,#2                   // increment the read count
b    -                       // do another loop iteration

//--------------------------------------------------------------------------------------------

+
pop  {r4}
pop  {r3}
pop  {r1}
pop  {r0}
pop  {pc}

//--------------------------------------------------------------------------------------------

.custom_cc:
sub  r2,#1                   // need to subtract 1 to counter the raw custom control code itself

ldrb r0,[r1,#0]              // load the current low byte of the custom control code

cmp  r0,#0x00                // check for 0xEF00, which will print the current enemy's name
beq  .cc_enemy_name

cmp  r0,#0x01                // check for 0xEF01, which will print the cohorts string
beq  .cc_cohorts

cmp  r0,#0x02                // check for 0xEF02, which will print an initial uppercase article if need be
b    .main_loop_next

cmp  r0,#0x03                // check for 0xEF03, which will print an initial lowercase article if need be
b    .main_loop_next

cmp  r0,#0x04                // check for 0xEF04, which will print an uppercase article if need be
b    .main_loop_next

cmp  r0,#0x05                // check for 0xEF05, which will print a lowercase article if need be
b    .main_loop_next

cmp  r0,#0x06                // check for 0xEF06, which will print a lowercase possessive if need be
beq  .cc_en_articles

cmp  r0,#0x10                // check for 0xEF10, which will print an initial uppercase article for items
beq  .cc_it_articles

cmp  r0,#0x11                // check for 0xEF11, which will print an initial lowercase article for items
beq  .cc_it_articles

cmp  r0,#0x12                // check for 0xEF12, which will print an uppercase article for items
beq  .cc_it_articles

cmp  r0,#0x13                // check for 0xEF13, which will print a lowercase article for items
beq  .cc_it_articles

mov  r0,#0                   // if this executes, it's an unknown control code, so treat it normally
b    .main_loop_next         // jump back to the part of the main loop that increments and such

//--------------------------------------------------------------------------------------------

.cc_enemy_name:
push {r1}
ldr  r0,=#0x2014320          // this is where current_enemy_save.asm saves the current enemy's ID #
ldrh r0,[r0,#0]              // load the current #
mov  r1,#50
mul  r0,r1                   // offset = enemy ID * 50 bytes
ldr  r1,=#0x9CFFDA4          // this is the base address of the enemy name array in ROM
add  r0,r0,r1                // r0 now has the address of the enemy's name
pop  {r1}

.count_and_inc:
bl   custom_strlen           // count the length of our special string, store its length in r2
b    .main_loop_next         // now jump back to the part of the main loop that increments and such

//--------------------------------------------------------------------------------------------

.cc_cohorts:
push {r1-r3}
mov  r3,#0                   // r3 will be our total # of bytes changed

ldr  r0,=#0x2014322          // load the # of enemies
ldrb r0,[r0,#0]
cmp  r0,#1
beq  .cc_cohorts_end         // don't print anything if there's only one enemy

ldr  r0,=#0x8D08314          // copy "and "
bl   custom_strlen           // count the length of our special string, store its length in r2
add  r3,r3,r0

ldr  r0,=#0x2014320          // load our current enemy #
ldrb r0,[r0,#0]
mov  r2,#5
mul  r0,r2
ldr  r2,=#0x8D08A6C
add  r0,r0,r2
ldrb r0,[r0,#0x4]            // load the line # for this enemy's possessive pronoun
mov  r2,#40
mul  r0,r2
ldr  r2,=#0x8D0829C
add  r0,r0,r2                // r0 now has the address to the appropriate possessive pronoun string
bl   custom_strlen           // count the length of our special string, store its length in r2
add  r3,r3,r0

ldr  r0,=#0x2014322          // load the # of enemies
ldrb r0,[r0,#0]
sub  r0,#1                   // subtract one for ease of use

push {r1}

ldr  r1,=#0x8D0829C          // load r1 with the base address of our custom text array in ROM
mov  r2,#40
mul  r0,r2
add  r0,r0,r1                // r0 now has the address of the proper cohorts string
pop  {r1}                    // restore r1 with the target address
bl   custom_strlen           // count the length of our special string, store its length in r2
add  r3,r3,r0                // update special string length

.cc_cohorts_end:
mov  r0,r3                   // r0 now has the total # of bytes we added

pop  {r1-r3}
b    .main_loop_next         // now jump back to the part of the main loop that increments and such

//--------------------------------------------------------------------------------------------

.cc_en_articles:
push {r1-r2}

sub  r2,r0,#2                // r2 will be an offset into the extra enemy data slot
                             // this is a quicker method of doing a bunch of related codes at once
                             // we take the low byte of the current CC and subtract 2, and that'll
                             // be our offset

ldr  r0,=#0x2014320          // this is where current_enemy_save saves the current enemy's ID #
ldrh r0,[r0,#0]              // load the current #
mov  r1,#5
mul  r0,r1                   // offset = enemy ID * 5 bytes
ldr  r1,=#0x8D08A6C          // this is the base address of our extra enemy data table in ROM
add  r0,r0,r1                // r0 now has address of this enemy's extra data entry
ldrb r0,[r0,r2]              // r0 now has the proper line # to use from custom_text.bin
mov  r1,#40
mul  r0,r1                   // calculate the offset into custom_text.bin
ldr  r1,=#0x8D0829C          // load r1 with the base address of our custom text array in ROM
add  r0,r0,r1                // r0 now has the address of the string we want
pop  {r1-r2}

bl   custom_strlen           // count the length of our special string, store its length in r2
b    .main_loop_next         // now jump back to the part of the main loop that increments and such

//--------------------------------------------------------------------------------------------

.cc_it_articles:
push {r1-r2}

sub  r0,#0x10
mov  r2,r0                   // r2 will be an offset into the extra item data slot
ldr  r0,=#0x2014324          // this is where the current item # will be saved by another hack
ldrh r0,[r0,#0]              // load the current item #
mov  r1,#8
mul  r0,r1                   // offset = item ID * 6 bytes
ldr  r1,=#0x9F89000          // this is the base address of our extra item data table in ROM
add  r0,r0,r1                // r0 now has the proper address of the current item's data slot
ldrb r0,[r0,r2]              // load the proper line # to use from custom_text.bin
mov  r1,#40
mul  r0,r1                   // calculate the offset into custom_text.bin
ldr  r1,=#0x8D0829C          // load r1 with the base address of our custom text array in ROM
add  r0,r0,r1                // r0 now has the address of the string we want
pop  {r1-r2}

bl   custom_strlen           // count the length of our special string, store its length in r2
b    .main_loop_next         // now jump back to the part of the main loop that increments and such

//=========================================================================================== 
// This code applies a VWF to battle menus and other stuff. It doesn't apply to battle text.
// It basically replaces these three lines of code:
//
//    ldrh r1,[r6]
//    add  r0,r0,r1
//    strh r0,[r6]
// 
// At [r6] is the current X position the last character was drawn to.
// At [r6]-4 is the character we've just drawn.
// We need to blank out the 2nd half of r0, look up [r6]-4 in a table, add it's width to r0.
// Then do what the original code does.
//=========================================================================================== 

.menu_vwf:
push {r4,r7,lr}

mov  r4,#0                   // r4 will be 0 if 16x16 font, #0x100 if 8x8 font
ldr  r7,=#0x2014300          // r7 will be our custom address in RAM to store the total width

cmp  r5,#0                   // if r5 is 0, we're starting on a new string
bne  +                       // in which case, let's see set the curr total width to 0

mov  r3,#0
strb r3,[r7,#0]              // initialize the total width as 0

//-------------------------------------------------------------------------------------------

+
ldrb r3,[r7,#0]              // load the current total width

lsr  r1,r1,#0x10
cmp  r1,#8
bne  +

ldr  r4,=#0x100              // set r4 to 0x100 so we'll load from the right width table later

//-------------------------------------------------------------------------------------------

+
push {r2,r5,r6}
ldrh r1,[r6,#0]              // Load our old X position into r1 
lsr  r0,r0,#8
lsl  r0,r0,#8                // Blank out the width of the current character
add  r0,r0,r1                // Add the old X position to r0 
sub  r6,#4                   // Move the pointer back some for now 
ldr  r5,[r6,#0]              // Load r5 with our current character

ldr  r6,=#0x8D1CE78          // r6 = address of 16x16 font width table
add  r6,r6,r4                // add r4 to r6, it'll be 8D1CF78 if the 8x8 font is being used

ldr  r4,=#0x1FF              // see if the letter is in the normal text range
cmp  r5,r4                   // if it is, go and load the width from the width table
ble  +

mov  r5,#0                   // otherwise, use the width of Character 0, which is 10
                             // this mainly applies to things like the (E) icon by equipment

//-------------------------------------------------------------------------------------------

+
ldrb r5,[r6,r5]              // r5 = width of current letter
add  r0,r0,r5                // add width to the X coordinate

add  r3,r3,r5                // now add to the total width, r3 will have this after the hack too
strb r3,[r7,#0]              // store the new total width back to our custom RAM spot
pop  {r2,r5,r6}              // restore the registers we used

pop  {r4,r7,pc}              // restore other registers and return




//===========================================================================================
//===========================================================================================
// This is the first part of a hack to make battle text work right.
//
// This routine should be linked to from 80840D2.
//
// This first part takes the place of the place in the game's code where it loads the current
// character right before doing control code checks. Later on in the code, the game will load
// the character again if it wasn't a control code. This later part will be handled by
// battle_vwf2.asm. We're doing things this way so that control codes like [WAIT] will work
// as intended.
//
// Basically, this part of the hack will prep a special block of RAM for battle_vwf2.asm
// and then perform the code we overwrote.
//===========================================================================================
//--------------------------------------------------------------------------------------------
//
// We're going to need to use a few bytes of RAM, starting from 0x2014300
//
// 2014300   byte   DO NOT USE!
// 2014301   byte   init_flag -- If this is 0, we know we need to initialize everything
// 2014302   hword  current letter/character/control code
// 2014303   ...
// 2014304   word   current x and y coordinates
// 2014305   ...
// 2014306   ...
// 2014307   ...
// 2014308   word   base address of the current string
// 2014309   ...
// 201430A   ...
// 201430B   ...
// 201430C   hword  current position in the string
// 201430D   ...
// 201430E   hword  total length of the current string
// 201430F   ...
// 2014310   hword  current line # we're on
// 2014311   ...
// 2014312   byte   newline_encountered flag -- 0 if no, non-zero if yes
//
//--------------------------------------------------------------------------------------------
// Coming into this, the registers are as follows:
//
//  r0  = current address (so when this is first called, it's the start of the string)
//  r1  = current position in the current string
//  r2  = ???
//  r3  = ???
//  r4  = ???
//  r5  = ???
//  r6  = ??? (seems to be pretty important though)
//  r7  = current string/tile counter (this is the key to making our hack run long enough)
//  r8  = not sure, but (r8 + 6) is where the total string length is stored
//  r9  = ???
//  r10 = ???
//  r11 = ???
//  r12 = ???
//===========================================================================================
// This is some routine initialization stuff

.main_vwf1:
push {r5,lr}                 // We're going to use r5, so we need to keep it in 
ldr r5,[sp,#0x08]            // Load r5 with our former LR value? 
mov lr,r5                    // Move the former LR value back into LR 
ldr r5,[sp,#0x04]            // Grab the LR value for THIS function 
str r5,[sp,#0x08]            // Store it over the previous one 
pop {r5}                     // Get back r5 
add sp,#0x04                 // Get the un-needed value off the stack

//-----------------

push {r5,r7}                 // this is unrelated to this hack really
ldr  r7,=#0x2014320          // it's used to clear the enemy value each line of text
mov  r5,#0                   // this is the easiest way to do it, so never mind this stuff
strh r5,[r7,#0]              // clears current enemy value, sets to 0
pop  {r5,r7}

//-----------------

lsl  r1,r1,#1                // this is code we clobbered while linking here
ldr  r0,[r0,#0]
add  r0,r0,r1

push {r5-r6}
ldr  r6,=#0x2014300          // Load r6 with the base address of our custom RAM block
ldr  r5,=#0x8D1CE78          // load r5 with the address of the font width table

cmp  r7,#0
bne  +                       // if we're on the first character, init stuff, else do main code

//--------------------------------------------------------------------------------------------
// This initializes our custom RAM block

str  r0,[r6,#0x8]            // store the base address of the string in the RAM block

mov  r0,#0x0
strh r0,[r6,#0xC]            // starting position = 0
strh r0,[r6,#0x10]           // current line = 0
strb r0,[r6,#0x12]           // newline_encountered flag = FALSE

mov  r0,#1
strb r0,[r6,#1]              // init_flag = 1, this makes the game not re-initialize everything

mov  r0,#12
strh r0,[r6,#0x4]            // start x = 12
mov  r0,#6
strh r0,[r6,#0x6]            // start y = 6

mov  r0,r8
ldrb r0,[r0,#0x6]            // [r8 + 6] has the total string length
strb r0,[r6,#0xE]            // store total length in our RAM block

bl   .word_wrap_setup        // add any newlines if text gets too long in the current string

//--------------------------------------------------------------------------------------------
// This is the meat of the code -- this is why we're doing this hack

+
ldr  r0,[r6,#0x8]            // load the base address of the string
ldrh r1,[r6,#0xC]            // load the current position in the string
lsl  r1,r1,#1                // multiply it by 2, since there are two bytes per letter
add  r0,r0,r1                // get the address for the current letter
ldrh r0,[r0,#0]              // load the current character
strh r0,[r6,#0x2]            // store the current character in our RAM block

ldr  r1,=#0xFF02
cmp  r0,r1                   // see if this is a [WAIT] code (0xFF02)
beq  .set_newline
sub  r1,#0x1
cmp  r0,r1                   // see if this is a [BREAK] code (0xFF01)
beq  .set_newline
lsr  r0,r0,#8                // shift right 1 byte
cmp  r0,#0xFF                // is this a control code? 
beq  .move_to_next_char      // if so, manually move to the next char
b    .end_main_vwf1

//--------------------------------------------------------------------------------------------
// If we're executing this code, we've encountered a code that signifies a line break

.set_newline:
ldrh r0,[r6,#0x10]           // load current line #
add  r0,r0,#0x1
strh r0,[r6,#0x10]           // line_num++

mov  r0,#0x1
strb r0,[r6,#0x12]           // newline_encountered flag = TRUE

.move_to_next_char:
ldrh r0,[r6,#0x0C]           // load current position
add  r0,r0,#0x1              // we need to increment it manually if we're on a control code
strh r0,[r6,#0x0C]

//--------------------------------------------------------------------------------------------
// This is the end area of the code, mostly preparing to leave and doing lines we clobbered

.end_main_vwf1:
ldrh r1,[r6,#0x2]            // load the current character in r1, the game expects this
ldr  r0,=#0xFF30             // load r0 with FF30, which the game expects to be here

pop  {r5-r6,pc}              // time to leave!


//===========================================================================================
//===========================================================================================
// This is the automatic word wrap routine, we call it once, when everything is getting inited
//
// The register layout during most of this is as follows:
//
//   r0: scratch register
//   r1: curr_char_address, points to the current character in the string
//   r2: start_address, this points to the beginning of the string
//   r3: end_address, this points to the final character of the string
//   r4: curr_width, we use this to total up widths until it exceeds a certain amount (208)
//   r5: contains the address of the font width table
//   r6: starts with our RAM block's address, but I also need it for scratch usage too
//   r7: contains the address of the last "space-ish" character, so we'll know where to put
//       a newline if need be

//--------------------------------------------------------------------------------------------
// We're just initializing everything here. Lots of registers being used for ease of coding

.word_wrap_setup:
push {r2-r4,r7}

ldr  r2,[r6,#0x8]            // load r2 with the start address of the string
ldrh r3,[r6,#0xE]            // load r3 with the length of the string
lsl  r3,r3,#1                // multiply the length by two, since two bytes per letter
add  r3,r2,r3                // r3 now has the end address of the string

push {r6}

mov  r1,r2                   // r1 is the current character's address
mov  r4,#0                   // r4 is curr_width
mov  r7,r2                   // r7 is last_space, the spot where the last space was

//--------------------------------------------------------------------------------------------
// Now we do the meat of the auto word wrap stuff

.word_wrap_loop:
ldr  r6,=#0xFF01

cmp  r1,r3
bge  .word_wrap_end          // jump to the end if we're past the end of the string

ldrh r0,[r1,#0]              // load the current character
cmp  r0,#0x40                // is the current character a space?
beq  .space_found
cmp  r0,r6                   // is the current character a [BREAK]?
beq  .newline_found
add  r6,#1
cmp  r0,r6                   // is the current character a [WAIT]?
beq  .newline_found

mov  r6,r0
lsr  r0,r0,#0x8              // clear the first two bytes of the current character
cmp  r0,#0xFF                // if r0 == 0xFF, this is a CC, so skip the width adding junk
beq  .no_wrap_needed
mov  r0,r6
b    .main_wrap_code

//--------------------------------------------------------------------------------------------
// We found a space or a space-like character, so reset some values

.newline_found:
mov  r4,#0                   // this was a [WAIT] or [BREAK], so reset the width
mov  r7,r1                   // last_space = curr_char_address
b    .no_wrap_needed

.space_found:
mov r7,r1                    // last_space = curr_char_address
                     
//--------------------------------------------------------------------------------------------
// Here is the real meat of the auto word wrap routine

.main_wrap_code:
ldrb r0,[r5,r0]              // get the width of the current character
add  r4,r4,r0                // curr_width += width of current character

cmp  r4,#208
blt  .no_wrap_needed         // if curr_width < 208, go to no_wrap_needed to update the width and such

mov  r4,#0                   // if we're executing this, then width >= 208, so do curr_width = 0 now

mov  r1,r7                   // curr_char_address = last_space_address// we're gonna recheck earlier stuff

ldr  r0,=#0xFF01             // replace the last space-ish character with a newline code
strh r0,[r7,#0]              // barring any incredibly crazy text, this should almost never overwrite
                             // existing [BREAK]s or [WAIT]s

//--------------------------------------------------------------------------------------------
// Get ready for the next loop iteration

.no_wrap_needed:
add  r1,#2                   // curr_char_address += 2
b    .word_wrap_loop         // do the next loop iteration

//--------------------------------------------------------------------------------------------
// Let's get out of here!

.word_wrap_end:
pop  {r6}
pop  {r2-r4,r7}
bx   lr


//===========================================================================================
// This is the second part of a hack to make battle text work right.
//
// This routine should be linked to from 808418E.
//
// The first part has set up the values in the RAM block for us. Some code then parsed
// control codes out if necessary. Now we need to calculate the coordinates for the letter
// about to be printed, as well as trick the game into continuing its loop longer. Also
// gotta do some manual newline handling and perform stuff we clobbered linking to this hack.
//
// See the documentation for main_vwf1 for details on the custom RAM area.
//===========================================================================================
// Coming into this, the registers are as follows:
//
//  r0  = current address (so when this is first called, it's the start of the string)
//  r1  = current position in the current string
//  r2  = ???
//  r3  = ???
//  r4  = area in current struct (add #0x38 to get the current X and Y coords)
//  r5  = ???
//  r6  = ???
//  r7  = current string/tile counter (this is the key to making our hack run long enough)
//  r8  = not sure, but (r8 + 6) is where the total string length is stored
//  r9  = ???
//  r10 = ???
//  r11 = ???
//  r12 = ???
//
//===========================================================================================
// This is some routine initialization stuff

.main_vwf2:
push {r5,lr}                 // We're going to use r5, so we need to keep it in 
ldr r5,[sp,#0x08]            // Load r5 with our former LR value? 
mov lr,r5                    // Move the former LR value back into LR 
ldr r5,[sp,#0x04]            // Grab the LR value for THIS function 
str r5,[sp,#0x08]            // Store it over the previous one 
pop {r5}                     // Get back r5 
add sp,#0x04                 // Get the un-needed value off the stack

push {r5-r6}                 // we really need these registers right now

ldr  r5,=#0x8D1CE78          // load r5 with the address of the font width table
ldr  r6,=#0x2014300          // Load r6 with the base address of our custom RAM block

//--------------------------------------------------------------------------------------------

bl   .process_line           // see if we need to move to a new line, and if so, do stuff accordingly

ldr  r1,[r6,#0x4]            // load the x and y coordinates into r1, these were updated by process_line
mov  r0,r4
add  r0,#0x38                // r4 + #0x38 is where the struct's coordinates are
str  r1,[r0,#0]              // store our custom coordinates in the struct

ldrh r0,[r6,#0x2]            // load the current character
add  r0,r0,r5                // get the address of the current character's width
ldrb r0,[r0,#0]              // load the current character's width

ldrh r1,[r6,#0x4]            // load the current x coordinate
add  r0,r0,r1                // x = x + width_of_current_character
strh r0,[r6,#0x4]            // store the new x coordinate into our RAM block, will be used next call
                             // even if the current character is a control code, we'll still catch it
                             // later and correct it, so it's okay if it gets something crazy here

ldr  r1,[r6,#0x4]            // load the x and y coordinates into r1
mov  r0,r4
str  r1,[r0,#0x44]           // store the next char's location in the location where the next erase is

ldrh r0,[r6,#0xC]            // load our current char position
add  r0,#1                   // increment our current char position
strh r0,[r6,#0xC]            // store it back in our RAM block

ldrh r1,[r6,#0xE]            // load r1 with the total length of this string
cmp  r0,r1                   // see if current character count >= the length of this string
bcc  .end_main_vwf2          // go to the last part of our code if we're under the total length

mov  r0,#0                   // set init_flag to 0 so that things here will get re-initialized next string
strb r0,[r6,#1]

//--------------------------------------------------------------------------------------------
// This stuff basically gets everything ready before leaving this hack

.end_main_vwf2:
ldrh r1,[r6,#0x2]            // load r1 with the current character, the game expects this

pop  {r5-r6}                 // get the original values back in these registers

mov  r0,#0
strh r0,[r6,#0x2A]           // make the game think we're always on line 0
strh r0,[r6,#0x2C]           // make the game think we're on character 0 always

ldr  r2,[r5,#0x4]            // another clobbered line
mov  r0,r4                   // and another

pop  {pc}                    // time to leave!


//=============================================================================================
//---------------------------------------------------------------------------------------------
// This routine determines if we're on Line 2 or higher, and if we are, recorrect stuff
// and reposition coordinates to be at the proper place
//
//    r0 has the current line # when this function is called

.process_line:
ldrb r1,[r6,#0x12]           // load newline_encountered_flag
cmp  r1,#0                   // compare it to 0
beq  .end_process_line       // don't do any of this code if it's set to FALSE

ldrh r0,[r6,#0x10]           // check current line #
cmp  r0,#2
bcc  +                       // don't scroll if don't need to

mov  r0,#1
strh r0,[r6,#0x10]           // set us back to Line #1
push {lr}
bl   .move_text_up           // hand-coded text scrolling routine to move text up
pop  {r1}
mov  lr,r1

+
mov  r1,#11
mul  r0,r1
add  r0,#6                   // y = line * 11 + init_y (do init_y stuff later)
strh r0,[r6,#0x6]            // store the new y in our RAM block
mov  r0,#12                  // x = 12
strh r0,[r6,#0x4]            // store the new x in our RAM block

mov  r0,#0x0
mov  r1,r4
add  r1,#0x30
strb r0,[r1,#0]              // sets the "display this glyph" flag in the current struct

.end_process_line:
mov  r0,#0
strb r0,[r6,#0x12]           // set newline_encountered flag to FALSE

bx   lr


//=============================================================================================
// This hack clears all the text in the battle text window area. The game's way of doing this
// is stupid, and the easiest way to fix problems with it is to erase everything on our own
// first. This erases the top 32 pixel lines of the screen.
//=============================================================================================

.clear_battle_window:
push {r5,lr}                 // We're going to use r5, so we need to keep it in 
ldr r5,[sp,#0x08]            // Load r5 with our former LR value? 
mov lr,r5                    // Move the former LR value back into LR 
ldr r5,[sp,#0x04]            // Grab the LR value for THIS function 
str r5,[sp,#0x08]            // Store it over the previous one 
pop {r5}                     // Get back r5 
add sp,#0x04                 // Get the un-needed value off the stack

//--------------------------------------------------------------------------------------------

push {r0-r3}

mov  r0,#0
push {r0}
mov  r0,sp

ldr  r1,=#0x6000000
ldr  r2,=#0x800

mov  r3,#1
lsl  r3,r3,#24
orr  r2,r3                   // set the 24th bit of r2 so it'll know to fill instead of copy
swi  #0x0B                   // clear old data out

pop  {r0}
pop  {r0-r3}

mov  r5,r0                   // perform the lines we clobbered
mov  r7,r1
ldr  r0,=#0x9F83DB0

pop  {pc}                    // time to leave!


//=============================================================================================
// Here it is, THE function that copies the text from one line to the line up above it.
// Copying around tilemap memory is really inconvenient, so this will take a lot of work :(
//=============================================================================================

.move_text_up:
push {r0}
push {r5}
push {r6}
push {r3}

mov  r3,#0                   // r3 = 0 so we can easily clear crap out
mov  r1,#0                   // r1 is gonna be our loop counter

-
ldr  r5,=#0x6000018          // r5 is our address in tile memory for the top line of text
ldr  r6,=#0x6000804          // r6 is our address in tile memory for the bottom line of text
lsl  r0,r1,#5                // r0 = r1 * 0x20, a quick way to multiply rather than use mul
add  r5,r5,r0                // this gets us the tiles to use based on the loop counter #
add  r6,r6,r0

ldr  r0,[r6,#0]              // get first pixel row of bottom line
str  r0,[r5,#0]              // copy the pixel row to the first pixel row of the top line
str  r3,[r6,#0]              // clear out first pixel row of bottom line

ldr  r0,[r6,#0x4]            // get second pixel row of bottom line
str  r0,[r5,#0x4]            // copy the pixel row to the second pixel row of the top line
str  r3,[r6,#0x4]            // clear out second pixel row of bottom line

ldr  r5,=#0x6000400          // now we're doing the next section, which is the bulk of the stuff
ldr  r6,=#0x600080C          // 
lsl  r0,r1,#5                // r0 = r1 * 0x20, a quick way to multiply rather than use mul
add  r5,r5,r0                // this gets us the tiles to use based on the loop counter #
add  r6,r6,r0

ldr  r0,[r6,#0]              // row 3
str  r0,[r5,#0]
str  r3,[r6,#0]

ldr  r0,[r6,#0x4]            // row 4
str  r0,[r5,#0x4]
str  r3,[r6,#0x4]

ldr  r0,[r6,#0x8]            // row 5
str  r0,[r5,#0x8]
str  r3,[r6,#0x8]

ldr  r0,[r6,#0xC]            // row 6
str  r0,[r5,#0xC]
str  r3,[r6,#0xC]

ldr  r0,[r6,#0x10]           // row 7
str  r0,[r5,#0x10]
str  r3,[r6,#0x10]

ldr  r5,=#0x6000414          // now we're doing the next section
ldr  r6,=#0x6000C00
lsl  r0,r1,#5                // r0 = r1 * 0x20, a quick way to multiply rather than use mul
add  r5,r5,r0                // this gets us the tiles to use based on the loop counter #
add  r6,r6,r0

ldr  r0,[r6,#0]              // row 8
str  r0,[r5,#0]
str  r3,[r6,#0]

ldr  r0,[r6,#0x4]            // row 9
str  r0,[r5,#0x4]
str  r3,[r6,#0x4]

ldr  r0,[r6,#0x8]            // row 10
str  r0,[r5,#0x8]
str  r3,[r6,#0x8]

ldr  r5,=#0x6000800          // now we're doing the final section, which is just one row
ldr  r6,=#0x6000C0C
lsl  r0,r1,#5                // r0 = r1 * 0x20, a quick way to multiply rather than use mul
add  r5,r5,r0                // this gets us the tiles to use based on the loop counter #
add  r6,r6,r0

ldr  r0,[r6,#0]              // row 11
str  r0,[r5,#0]
str  r3,[r6,#0]

add r1,#1
cmp r1,#0x1E
blt -                        // r1++, if r1 < 1E (# of tiles wide the screen is) then loop back

pop {r3}
pop {r6}
pop {r5}
pop {r0}
bx  lr


//=============================================================================================
// This hack character names in the HP/PP boxes in battle.
//
// At 807D2D8, the value in [r7-#0x40] is dependent on n.
// It's in multiples of 6, starts at 8 for n=0
// altering your party doesn't change this pattern.
// However, if the 0th party character is 0x00 (ie., your party is 00 02 03 04),
// it doesn't begin with 14, it's still 8.
// This case shouldn't ever happen naturally though, so we should be fine.
// Party characters: ch = [2004860 + n], n: 0-3
// Party names: 2004112 + (ch * 0x6C)
//=============================================================================================

.center_name:
push {r5,lr}                 // We're going to use r5, so we need to keep it in 
ldr  r5,[sp,#0x08]           // Load r5 with our former LR value? 
mov  lr,r5                   // Move the former LR value back into LR 
ldr  r5,[sp,#0x04]           // Grab the LR value for THIS function 
str  r5,[sp,#0x08]           // Store it over the previous one 
pop  {r5}                    // Get back r5 
add  sp,#0x04                // Get the un-needed value off the stack 

push {r0,r1,r3,r4,r5}

mov  r0,r7
sub  r0,#0x40
ldrb r0,[r0,#0]
sub  r0,#8
mov  r1,#6
swi  #6
ldr  r1,=#0x2004860
ldrb r1,[r1,r0]
mov  r0,#0x6C
mul  r1,r0
ldr  r0,=#0x2004112
add  r0,r0,r1

mov  r1,#0xFF
lsl  r1,r1,#8
ldr  r4,=#0x8D1CF78
mov  r5,#0

-
ldrh r3,[r0,#0]
add  r0,#2
cmp  r3,r1
bge  +
ldrb r3,[r4,r3]
add  r5,r5,r3
b    -

+
lsr  r5,r5,#1
sub  r2,r2,r5

// this new snippet fixes the weird bug where the far-left name in a 4-member team
// can mess up if the name is too wide. The problem is that the game would try to
// print at a negative X position, so we'll just set it to 0 in those cases.
cmp r2,#00
bge +
mov r2,#0

+
mov  r7,#0x30
add  r7,r8 // this line assembles weird with goldroad. Hexedit to [47 44] if it doesn't assemble as that.
mov  r12,r7

pop {r0,r1,r3,r4,r5,pc}


//=============================================================================================
// This code saves the value of the currently active enemy to a halfword in RAM.
// We need to have this value easily available when we do our custom control code
// stuff later on.
//=============================================================================================

.save_current_enemy:
ldr  r0,=#0x2014320          // this is the address where we'll store the current enemy's value
strh r1,[r0,#0]              // store the value. How easy!
bx   lr


//=============================================================================================
// This code clears the currently active enemy to 0. Called before .save_current_enemy.
// This helps (but doesn't 100% fix) the "The Flint" problem.
//=============================================================================================

.clear_current_enemy:
ldr  r7,=#0x2014320
mov  r5,#0
strh r5,[r7,#0]              // clears current enemy value, sets to 0
mov  r7,r0                   // do clobbered code
mov  r5,r1
bx   lr


//=============================================================================================
// This code saves the value of the currently active enemy to a halfword in RAM.
// We need to have this value easily available when we do our custom control code
// stuff later on.
//=============================================================================================

.save_total_enemies:
push {r4}
ldr  r4,=#0x2014322          // we're going to store the total # of enemies here

ldr  r1,[r3,#0x4]            // original code, loads r1 with the total # of enemies
add  r0,r0,r1

mov  r1,r0                   // only need to know if 1, 2, or 3 enemies. 
cmp  r1,#3                   // if it's over 3, just say it's 3
blt  +
mov  r1,#3

+
strh r1,[r4,#0]              // store our count in our RAM block area for later reading
pop  {r4}
bx   lr


//=============================================================================================
// This code saves the value of the currently active item to a halfword in RAM.
// We need to have this value easily available when we do our custom control code
// stuff later on.
//=============================================================================================

.save_current_item:
ldr  r0,=#0x2014324
strh r1,[r0,#0]
bx   lr




//=============================================================================================
// This hack implements a custom control code system used by the battle text.
// Since the battle text stuff is shared by other code in the game, it may affect other
// stuff too, but since that other stuff won't use any of our new control codes, it
// shouldn't matter. Note that this is very similar to the code that follows the
// sound player text-centering code. The difference is that this code actually copies the
// new data, the other code simply determines how much extra space the text from the custom
// control codes will take.
//
// The original control codes all start with FF in their most significant byte. Our
// custom control codes will start with EF. We could use FE, but then we'd be inconsistent
// with our CC formats between main script text and battle/etc. text.
//
// This hack should be linked from 806E464.
//
// The main registers in this hack are:
//
//   r0  = address of the current letter/code to read in
//   r1  = address of the current write location
//   r2  = length of the current string (we'll need to toy with this beforehand maybe)
//   r3  = somewhere on the stack, [r3 + ???] is the current letter count
//
//=============================================================================================
// This is some routine initialization stuff

.execute_custom_cc:
push {r5,lr}                 // We're going to use r5, so we need to keep it in 
ldr  r5,[sp,#0x08]           // Load r5 with our former LR value? 
mov  lr,r5                   // Move the former LR value back into LR 
ldr  r5,[sp,#0x04]           // Grab the LR value for THIS function 
str  r5,[sp,#0x08]           // Store it over the previous one 
pop  {r5}                    // Get back r5 
add  sp,#0x04                // Get the un-needed value off the stack 

push {r6-r7}                 // this original code counts stuff confusingly,
mov  r6,#0                   // so we're gonna use r6 as OUR counter

//--------------------------------------------------------------------------------------------

-
lsl  r0,r0,#1                // original code
cmp  r0,#0x0                 // see if this is the first letter
bne  .ecc_char_check         // if it isn't, skip this part
add  r1,r0,r4                // initialize the write address if this is the first letter

//--------------------------------------------------------------------------------------------

.ecc_char_check:
add  r0,r0,r5                // original code, gets the proper read location
ldrb r7,[r0,#1]              // check the high byte of the current letter
cmp  r7,#0xEF
beq  .check_custom_cc        // if this is a custom CC, go do stuff, else do old code and leave

.ecc_inc:
ldrh r0,[r0,#0]              // this is the original code
strh r0,[r1,#0]
ldrh r0,[r3,#0x6]
add  r0,#1
strh r0,[r3,#0x6]
add  r1,#2                   // increment the read address
add  r6,r6,#1                // increment our counter

.ecc_len_check:
cmp  r6,r2                   // this replaces the original check
blt  -                       // loop again if we haven't finished copying

strh r6,[r3,#0x6]
pop  {r6-r7,pc}              // restore registers and exit

//--------------------------------------------------------------------------------------------

.check_custom_cc:
ldrb r0,[r0,#0]              // load the current character

cmp  r0,#0x00                // check for 0xEF00, which will print the current enemy's name
beq  .ecc_enemy_name

cmp  r0,#0x01                // check for 0xEF01, which will print "and cohort/and cohorts" if need be
beq  .ecc_cohorts

//cmp  r0,#0x02                // check for 0xEF02, which will print an initial uppercase article if need be
//beq  .ecc_en_articles

//cmp  r0,#0x03                // check for 0xEF03, which will print an initial lowercase article if need be
//beq  .ecc_en_articles

//cmp  r0,#0x04                // check for 0xEF04, which will print an uppercase article if need be
//beq  .ecc_en_articles

//cmp  r0,#0x05                // check for 0xEF05, which will print a lowercase article if need be
//beq  .ecc_en_articles

cmp  r0,#0x06                // check for 0xEF06, which will print a lowercase possessive if need be
beq  .ecc_en_articles

cmp  r0,#0x10                // check for 0xEF10, which will print an initial uppercase article for items
beq  .ecc_it_articles

cmp  r0,#0x11                // check for 0xEF11, which will print an initial lowercase article for items
beq  .ecc_it_articles

cmp  r0,#0x12                // check for 0xEF12, which will print an uppercase article for items
beq  .ecc_it_articles

cmp  r0,#0x13                // check for 0xEF13, which will print a lowercase article for items
beq  .ecc_it_articles

b    .ecc_inc                // treat this code normally if it's not a valid custom control code

//--------------------------------------------------------------------------------------------

.customcc_inc:
add  r1,r1,r0                // update our write address
lsr  r0,r0,#0x1
add  r6,r6,r0                // update our own custom counter

ldrh r0,[r3,#0x6]            // increment the char count, which will later increment the read address
add  r0,#1
strh r0,[r3,#0x6]

b    .ecc_len_check

//--------------------------------------------------------------------------------------------

.ecc_enemy_name:
push {r1}
ldr  r0,=#0x2014320          // this is where current_enemy_save.asm saves the current enemy's ID #
ldrh r0,[r0,#0]              // load the current #
mov  r1,#50
mul  r0,r1                   // offset = enemy ID * 50 bytes
ldr  r1,=#0x9CFFDA4          // this is the base address of the enemy name array in ROM
add  r0,r0,r1                // r0 now has the address of the enemy's name
pop  {r1}

bl   custom_strcopy          // r0 gets the # of bytes copied afterwards
b    .customcc_inc           // go to the common custom CC incrementing, etc. code

//--------------------------------------------------------------------------------------------

.ecc_cohorts:
push {r1-r3}
mov  r3,#0                   // r3 will be our total # of bytes changed

ldr  r0,=#0x2014322          // load the # of enemies
ldrb r0,[r0,#0]
cmp  r0,#1
beq  +                       // don't print anything if there's only one enemy

ldr  r0,=#0x8D08314          // copy "and "
bl   custom_strcopy          // r0 gets the # of bytes copied afterwards
add  r1,r1,r0
add  r3,r3,r0

ldr  r0,=#0x2014320          // load our current enemy #
ldrb r0,[r0,#0]
mov  r2,#5
mul  r0,r2
ldr  r2,=#0x8D08A6C
add  r0,r0,r2
ldrb r0,[r0,#0x4]            // load the line # for this enemy's possessive pronoun
mov  r2,#40
mul  r0,r2
ldr  r2,=#0x8D0829C
add  r0,r0,r2                // r0 now has the address to the appropriate possessive pronoun string
bl   custom_strcopy          // r0 gets the # of bytes copied afterwards
add  r1,r1,r0
add  r3,r3,r0

ldr  r0,=#0x2014322          // load the # of enemies
ldrb r0,[r0,#0]
sub  r0,#1                   // subtract one for ease of use

push {r1}                    // now we're going to print "cohort/cohorts" stuff

ldr  r1,=#0x8D0829C          // load r1 with the base address of our custom text array in ROM
mov  r2,#40
mul  r0,r2
add  r0,r0,r1                // r0 now has the address of the proper cohorts string
pop  {r1}                    // restore r1 with the target address
bl   custom_strcopy          // r0 gets the # of bytes copied afterwards
add  r3,r3,r0                // we just copied the possessive pronoun now

+
mov  r0,r3                   // r0 now has the total # of bytes we added

pop  {r1-r3}
b    .customcc_inc           // go to the common custom CC incrementing, etc. code

//--------------------------------------------------------------------------------------------

.ecc_en_articles:
push {r1-r2}

sub  r2,r0,#2                // r2 will be an offset into the extra enemy data slot
                             // this is a quicker method of doing a bunch of related codes at once
                             // we take the low byte of the current CC and subtract 2, and that'll
                             // be our offset

ldr  r0,=#0x2014320          // this is where current_enemy_save.asm saves the current enemy's ID #
ldrh r0,[r0,#0]              // load the current #
mov  r1,#5
mul  r0,r1                   // offset = enemy ID * 5 bytes
ldr  r1,=#0x8D08A6C          // this is the base address of our extra enemy data table in ROM
add  r0,r0,r1                // r0 now has address of this enemy's extra data entry
ldrb r0,[r0,r2]              // r0 now has the proper line # to use from custom_text.bin
mov  r1,#40
mul  r0,r1                   // calculate the offset into custom_text.bin
ldr  r1,=#0x8D0829C          // load r1 with the base address of our custom text array in ROM
add  r0,r0,r1                // r0 now has the address of the string we want
pop  {r1-r2}

bl   custom_strcopy          // r0 gets the # of bytes copied afterwards
b    .customcc_inc           // go to the common custom CC incrementing, etc. code

//--------------------------------------------------------------------------------------------

.ecc_it_articles:
push {r1-r2}

sub  r0,#0x10
mov  r2,r0                   // r2 will be an offset into the extra item data slot
ldr  r0,=#0x2014324          // this is where the current item # will be saved by another hack
ldrh r0,[r0,#0]              // load the current item #
mov  r1,#8
mul  r0,r1                   // offset = item ID * 6 bytes
ldr  r1,=#0x9F89000          // this is the base address of our extra item data table in ROM
add  r0,r0,r1                // r0 now has the proper address of the current item's data slot
ldrb r0,[r0,r2]              // load the proper line # to use from custom_text.bin
mov  r1,#40
mul  r0,r1                   // calculate the offset into custom_text.bin
ldr  r1,=#0x8D0829C          // load r1 with the base address of our custom text array in ROM
add  r0,r0,r1                // r0 now has the address of the string we want
pop  {r1-r2}

bl   custom_strcopy          // r0 gets the # of bytes copied afterwards
b    .customcc_inc           // go to the common custom CC incrementing, etc. code

//--------------------------------------------------------------------------------------------




.text_pointer_fix:
push {r5,lr}                 // We're going to use r5, so we need to keep it in 
ldr  r5,[sp,#0x08]           // Load r5 with our former LR value? 
mov  lr,r5                   // Move the former LR value back into LR 
ldr  r5,[sp,#0x04]           // Grab the LR value for THIS function 
str  r5,[sp,#0x08]           // Store it over the previous one 
pop  {r5}                    // Get back r5 
add  sp,#0x04                // Get the un-needed value off the stack 

add  r2,r2,r0
ldrh r0,[r2,#0]
lsl  r0,r0,#1
ldr  r1,[r1,#4]
pop  {pc}


//=============================================================================================
//This lets only 9 letters show up for the favorite food in the battle goods menu.
//=============================================================================================

.favfood_9letters:
// r4 = item address; compare with 2004F02
// r2 = item length

// old code
lsl  r2,r2,#0x10
lsr  r2,r2,#0x10

// compare, etc
ldr  r0,=#0x2004F02
cmp  r0,r4
bne  +
mov  r2,#9
+
bx   lr




















// "too many items" battle VWF
// r6 is the internal counter

.toomany_vwf1:
push {r5,lr}                 // We're going to use r5, so we need to keep it in 
ldr r5,[sp,#0x08]            // Load r5 with our former LR value? 
mov lr,r5                    // Move the former LR value back into LR 
ldr r5,[sp,#0x04]            // Grab the LR value for THIS function 
str r5,[sp,#0x08]            // Store it over the previous one 
pop {r5}                     // Get back r5 
add sp,#0x04                 // Get the un-needed value off the stack

lsl  r1,r1,#1                // this is code we clobbered while linking here
ldr  r0,[r0,#0]
add  r0,r0,r1

//ldr  r4,=#0x3006D14

push {r5-r7}
ldr  r6,=#0x2014300          // Load r6 with the base address of our custom RAM block
ldr  r5,=#0x8D1CE78          // load r5 with the address of the font width table

mov  r7,r9
cmp  r7,#0
bne  +                       // if we're on the first character, init stuff, else do main code

//--------------------------------------------------------------------------------------------
// This initializes our custom RAM block

str  r0,[r6,#0x8]            // store the base address of the string in the RAM block

mov  r0,#0x0
strh r0,[r6,#0xC]            // starting position = 0
strh r0,[r6,#0x10]           // current line = 0
strb r0,[r6,#0x12]           // newline_encountered flag = FALSE

mov  r0,#1
strb r0,[r6,#1]              // init_flag = 1, this makes the game not re-initialize everything

mov  r0,#12
strh r0,[r6,#0x4]            // start x = 12
mov  r0,#6
strh r0,[r6,#0x6]            // start y = 6

mov  r0,r8
ldrb r0,[r0,#0x8]            // [r8 + 8] has the total string length?
strb r0,[r6,#0xE]            // store total length in our RAM block

bl   .word_wrap_setup        // add any newlines if text gets too long in the current string

//--------------------------------------------------------------------------------------------
// This is the meat of the code -- this is why we're doing this hack

+
ldr  r0,[r6,#0x8]            // load the base address of the string
ldrh r1,[r6,#0xC]            // load the current position in the string
lsl  r1,r1,#1                // multiply it by 2, since there are two bytes per letter
add  r0,r0,r1                // get the address for the current letter
ldrh r0,[r0,#0]              // load the current character
strh r0,[r6,#0x2]            // store the current character in our RAM block

ldr  r1,=#0xFF02
cmp  r0,r1                   // see if this is a [WAIT] code (0xFF02)
beq  .tm_set_newline
sub  r1,#0x1
cmp  r0,r1                   // see if this is a [BREAK] code (0xFF01)
beq  .tm_set_newline
lsr  r0,r0,#8                // shift right 1 byte
cmp  r0,#0xFF                // is this a control code? 
beq  .tm_move_to_next_char      // if so, manually move to the next char
b    .end_toomany_vwf1

//--------------------------------------------------------------------------------------------
// If we're executing this code, we've encountered a code that signifies a line break

.tm_set_newline:
ldrh r0,[r6,#0x10]           // load current line #
add  r0,r0,#0x1
strh r0,[r6,#0x10]           // line_num++

mov  r0,#0x1
strb r0,[r6,#0x12]           // newline_encountered flag = TRUE

.tm_move_to_next_char:
ldrh r0,[r6,#0x0C]           // load current position
add  r0,r0,#0x1              // we need to increment it manually if we're on a control code
strh r0,[r6,#0x0C]

//--------------------------------------------------------------------------------------------
// This is the end area of the code, mostly preparing to leave and doing lines we clobbered

.end_toomany_vwf1:
ldrh r1,[r6,#0x2]            // load the current character in r1, the game expects this
ldr  r0,=#0xFF32             // load r0 with FF30, which the game expects to be here

pop  {r5-r7,pc}              // time to leave!











// part 2 of the too many vwf


.toomany_vwf2:
push {r5,lr}                 // We're going to use r5, so we need to keep it in 
ldr r5,[sp,#0x08]            // Load r5 with our former LR value? 
mov lr,r5                    // Move the former LR value back into LR 
ldr r5,[sp,#0x04]            // Grab the LR value for THIS function 
str r5,[sp,#0x08]            // Store it over the previous one 
pop {r5}                     // Get back r5 
add sp,#0x04                 // Get the un-needed value off the stack

push {r5-r6}                 // we really need these registers right now

ldr  r5,=#0x8D1CE78          // load r5 with the address of the font width table
ldr  r6,=#0x2014300          // Load r6 with the base address of our custom RAM block

//--------------------------------------------------------------------------------------------

bl   .process_line           // see if we need to move to a new line, and if so, do stuff accordingly

ldr  r1,[r6,#0x4]            // load the x and y coordinates into r1, these were updated by process_line
mov  r0,r4
add  r0,#0x38                // r4 + #0x38 is where the struct's coordinates are
str  r1,[r0,#0]              // store our custom coordinates in the struct

ldr  r1,=#0xFF00
ldrh r0,[r6,#0x2]            // load the current character
cmp  r0,r1                   // if it's a control code, width = 0
blt  +

mov  r0,#0
b    .tm_load_width

+
add  r0,r0,r5                // get the address of the current character's width
ldrb r0,[r0,#0]              // load the current character's width

.tm_load_width:
ldrh r1,[r6,#0x4]            // load the current x coordinate
add  r0,r0,r1                // x = x + width_of_current_character
strh r0,[r6,#0x4]            // store the new x coordinate into our RAM block, will be used next call
                             // even if the current character is a control code, we'll still catch it
                             // later and correct it, so it's okay if it gets something crazy here

ldr  r1,[r6,#0x4]            // load the x and y coordinates into r1
mov  r0,r4
str  r1,[r0,#0x44]           // store the next char's location in the location where the next erase is

ldrh r0,[r6,#0xC]            // load our current char position
add  r0,#1                   // increment our current char position
strh r0,[r6,#0xC]            // store it back in our RAM block

ldrh r1,[r6,#0xE]            // load r1 with the total length of this string
cmp  r0,r1                   // see if current character count >= the length of this string
bcc  .end_toomany_vwf2       // go to the last part of our code if we're under the total length

mov  r0,#0                   // set init_flag to 0 so that things here will get re-initialized next string
strb r0,[r6,#1]

//--------------------------------------------------------------------------------------------
// This stuff basically gets everything ready before leaving this hack

.end_toomany_vwf2:
ldrh r1,[r6,#0x2]            // load r1 with the current character, the game expects this

pop  {r5-r6}                 // get the original values back in these registers

mov  r0,#0
strh r0,[r6,#0x2A]           // make the game think we're always on line 0
strh r0,[r6,#0x2C]           // make the game think we're on character 0 always

ldr  r2,[r5,#0x4]            // another clobbered line
mov  r0,r4                   // and another

pop  {pc}                    // time to leave!





.toomany_vwf_clear_window:
push {r5,lr}                 // We're going to use r5, so we need to keep it in 
ldr r5,[sp,#0x08]            // Load r5 with our former LR value? 
mov lr,r5                    // Move the former LR value back into LR 
ldr r5,[sp,#0x04]            // Grab the LR value for THIS function 
str r5,[sp,#0x08]            // Store it over the previous one 
pop {r5}                     // Get back r5 
add sp,#0x04                 // Get the un-needed value off the stack

push {r0-r3}

mov  r0,#0
push {r0}
mov  r0,sp

ldr  r1,=#0x6000000
ldr  r2,=#0x800

mov  r3,#1
lsl  r3,r3,#24
orr  r2,r3                   // set the 24th bit of r2 so it'll know to fill instead of copy
swi  #0x0B                   // clear old data out

pop  {r0}
pop  {r0-r3}

mov  r8,r3                   // clobbered code
mov  r9,r4
mov  r10,r5

pop  {pc}                    // time to leave!


















.3line_vwf1:
push {r5,lr}                 // We're going to use r5, so we need to keep it in 
ldr r5,[sp,#0x08]            // Load r5 with our former LR value? 
mov lr,r5                    // Move the former LR value back into LR 
ldr r5,[sp,#0x04]            // Grab the LR value for THIS function 
str r5,[sp,#0x08]            // Store it over the previous one 
pop {r5}                     // Get back r5 
add sp,#0x04                 // Get the un-needed value off the stack

lsl  r1,r1,#1                // this is code we clobbered while linking here
ldr  r0,[r0,#0]
add  r0,r0,r1

push {r5-r6}
ldr  r6,=#0x2014300          // Load r6 with the base address of our custom RAM block
ldr  r5,=#0x8D1CE78          // load r5 with the address of the font width table

cmp  r7,#0
bne  +                       // if we're on the first character, init stuff, else do main code

//--------------------------------------------------------------------------------------------
// This initializes our custom RAM block

str  r0,[r6,#0x8]            // store the base address of the string in the RAM block

mov  r0,#0x0
strh r0,[r6,#0xC]            // starting position = 0
strh r0,[r6,#0x10]           // current line = 0
strb r0,[r6,#0x12]           // newline_encountered flag = FALSE

mov  r0,#1
strb r0,[r6,#1]              // init_flag = 1, this makes the game not re-initialize everything

mov  r0,#12
strh r0,[r6,#0x4]            // start x = 12
mov  r0,#6
strh r0,[r6,#0x6]            // start y = 6

mov  r0,r8
ldrb r0,[r0,#0x6]            // [r8 + 6] has the total string length
strb r0,[r6,#0xE]            // store total length in our RAM block

bl   .word_wrap_setup        // add any newlines if text gets too long in the current string

//--------------------------------------------------------------------------------------------
// This is the meat of the code -- this is why we're doing this hack

+
ldr  r0,[r6,#0x8]            // load the base address of the string
ldrh r1,[r6,#0xC]            // load the current position in the string
lsl  r1,r1,#1                // multiply it by 2, since there are two bytes per letter
add  r0,r0,r1                // get the address for the current letter
ldrh r0,[r0,#0]              // load the current character
strh r0,[r6,#0x2]            // store the current character in our RAM block

ldr  r1,=#0xFF02
cmp  r0,r1                   // see if this is a [WAIT] code (0xFF02)
beq  .3l_set_newline
sub  r1,#0x1
cmp  r0,r1                   // see if this is a [BREAK] code (0xFF01)
beq  .3l_set_newline
lsr  r0,r0,#8                // shift right 1 byte
cmp  r0,#0xFF                // is this a control code? 
beq  .3l_move_to_next_char   // if so, manually move to the next char
b    .end_3l_vwf1

//--------------------------------------------------------------------------------------------
// If we're executing this code, we've encountered a code that signifies a line break

.3l_set_newline:
ldrh r0,[r6,#0x10]           // load current line #
add  r0,r0,#0x1
strh r0,[r6,#0x10]           // line_num++

mov  r0,#0x1
strb r0,[r6,#0x12]           // newline_encountered flag = TRUE

.3l_move_to_next_char:
ldrh r0,[r6,#0x0C]           // load current position
add  r0,r0,#0x1              // we need to increment it manually if we're on a control code
strh r0,[r6,#0x0C]

//--------------------------------------------------------------------------------------------
// This is the end area of the code, mostly preparing to leave and doing lines we clobbered

.end_3l_vwf1:
ldrh r1,[r6,#0x2]            // load the current character in r1, the game expects this
ldr  r0,=#0xFF30             // load r0 with FF30, which the game expects to be here

pop  {r5-r6,pc}              // time to leave!











.3line_vwf2:
push {r5,lr}                 // We're going to use r5, so we need to keep it in 
ldr r5,[sp,#0x08]            // Load r5 with our former LR value? 
mov lr,r5                    // Move the former LR value back into LR 
ldr r5,[sp,#0x04]            // Grab the LR value for THIS function 
str r5,[sp,#0x08]            // Store it over the previous one 
pop {r5}                     // Get back r5 
add sp,#0x04                 // Get the un-needed value off the stack

push {r5-r6}                 // we really need these registers right now

ldr  r5,=#0x8D1CE78          // load r5 with the address of the font width table
ldr  r6,=#0x2014300          // Load r6 with the base address of our custom RAM block

//--------------------------------------------------------------------------------------------

bl   .3l_process_line        // see if we need to move to a new line, and if so, do stuff accordingly

ldr  r1,[r6,#0x4]            // load the x and y coordinates into r1, these were updated by process_line
mov  r0,r4
add  r0,#0x38                // r4 + #0x38 is where the struct's coordinates are
str  r1,[r0,#0]              // store our custom coordinates in the struct

ldrh r0,[r6,#0x2]            // load the current character
add  r0,r0,r5                // get the address of the current character's width
ldrb r0,[r0,#0]              // load the current character's width

ldrh r1,[r6,#0x4]            // load the current x coordinate
add  r0,r0,r1                // x = x + width_of_current_character
strh r0,[r6,#0x4]            // store the new x coordinate into our RAM block, will be used next call
                             // even if the current character is a control code, we'll still catch it
                             // later and correct it, so it's okay if it gets something crazy here

ldr  r1,[r6,#0x4]            // load the x and y coordinates into r1
mov  r0,r4
str  r1,[r0,#0x44]           // store the next char's location in the location where the next erase is

ldrh r0,[r6,#0xC]            // load our current char position
add  r0,#1                   // increment our current char position
strh r0,[r6,#0xC]            // store it back in our RAM block

ldrh r1,[r6,#0xE]            // load r1 with the total length of this string
cmp  r0,r1                   // see if current character count >= the length of this string
bcc  .end_3l_vwf2            // go to the last part of our code if we're under the total length

mov  r0,#0                   // set init_flag to 0 so that things here will get re-initialized next string
strb r0,[r6,#1]

//--------------------------------------------------------------------------------------------
// This stuff basically gets everything ready before leaving this hack

.end_3l_vwf2:
ldrh r1,[r6,#0x2]            // load r1 with the current character, the game expects this

pop  {r5-r6}                 // get the original values back in these registers

mov  r0,#0
strh r0,[r6,#0x2A]           // make the game think we're always on line 0
strh r0,[r6,#0x2C]           // make the game think we're on character 0 always

ldr  r2,[r5,#0x4]            // another clobbered line
mov  r0,r4                   // and another

pop  {pc}                    // time to leave!




//=============================================================================================
//---------------------------------------------------------------------------------------------
// This routine determines if we're on Line 3 or higher, and if we are, recorrect stuff
// and reposition coordinates to be at the proper place
//
//    r0 has the current line # when this function is called

.3l_process_line:
ldrb r1,[r6,#0x12]           // load newline_encountered_flag
cmp  r1,#0                   // compare it to 0
beq  .3l_end_process_line    // don't do any of this code if it's set to FALSE

ldrh r0,[r6,#0x10]           // check current line #
cmp  r0,#3
bcc  +                       // don't scroll if don't need to

mov  r0,#2
strh r0,[r6,#0x10]           // set us back to Line #1
push {lr}
bl   .3l_move_text_up        // hand-coded text scrolling routine to move text up
pop  {r1}
mov  lr,r1

+
mov  r1,#11
mul  r0,r1
add  r0,#6                   // y = line * 11 + init_y (do init_y stuff later)
strh r0,[r6,#0x6]            // store the new y in our RAM block
mov  r0,#12                  // x = 12
strh r0,[r6,#0x4]            // store the new x in our RAM block

mov  r0,#0x0
mov  r1,r4
add  r1,#0x30
strb r0,[r1,#0]              // sets the "display this glyph" flag in the current struct

.3l_end_process_line:
mov  r0,#0
strb r0,[r6,#0x12]           // set newline_encountered flag to FALSE

bx   lr



.3l_move_text_up:
push {r0-r6,lr}

mov  r3,#0                   // r3 = 0 so we can easily clear crap out
mov  r1,#0                   // r1 is gonna be our loop counter

-
ldr  r5,=#0x6000018          // r5 is our address in tile memory for the top line of text
ldr  r6,=#0x6000804          // r6 is our address in tile memory for the bottom line of text
lsl  r0,r1,#5                // r0 = r1 * 0x20, a quick way to multiply rather than use mul
add  r5,r5,r0                // this gets us the tiles to use based on the loop counter #
add  r6,r6,r0

ldr  r0,[r6,#0]              // get first pixel row of bottom line
str  r0,[r5,#0]              // copy the pixel row to the first pixel row of the top line
str  r3,[r6,#0]              // clear out first pixel row of bottom line

ldr  r0,[r6,#0x4]            // get second pixel row of bottom line
str  r0,[r5,#0x4]            // copy the pixel row to the second pixel row of the top line
str  r3,[r6,#0x4]            // clear out second pixel row of bottom line

ldr  r5,=#0x6000400          // now we're doing the next section, which is the bulk of the stuff
ldr  r6,=#0x600080C          // 
lsl  r0,r1,#5                // r0 = r1 * 0x20, a quick way to multiply rather than use mul
add  r5,r5,r0                // this gets us the tiles to use based on the loop counter #
add  r6,r6,r0

ldr  r0,[r6,#0]              // row 3
str  r0,[r5,#0]
str  r3,[r6,#0]

ldr  r0,[r6,#0x4]            // row 4
str  r0,[r5,#0x4]
str  r3,[r6,#0x4]

ldr  r0,[r6,#0x8]            // row 5
str  r0,[r5,#0x8]
str  r3,[r6,#0x8]

ldr  r0,[r6,#0xC]            // row 6
str  r0,[r5,#0xC]
str  r3,[r6,#0xC]

ldr  r0,[r6,#0x10]           // row 7
str  r0,[r5,#0x10]
str  r3,[r6,#0x10]

ldr  r5,=#0x6000414          // now we're doing the next section
ldr  r6,=#0x6000C00
lsl  r0,r1,#5                // r0 = r1 * 0x20, a quick way to multiply rather than use mul
add  r5,r5,r0                // this gets us the tiles to use based on the loop counter #
add  r6,r6,r0

ldr  r0,[r6,#0]              // row 8
str  r0,[r5,#0]
str  r3,[r6,#0]

ldr  r0,[r6,#0x4]            // row 9
str  r0,[r5,#0x4]
str  r3,[r6,#0x4]

ldr  r0,[r6,#0x8]            // row 10
str  r0,[r5,#0x8]
str  r3,[r6,#0x8]

ldr  r5,=#0x6000800          // now we're doing the final section, which is just one row
ldr  r6,=#0x6000C0C
lsl  r0,r1,#5                // r0 = r1 * 0x20, a quick way to multiply rather than use mul
add  r5,r5,r0                // this gets us the tiles to use based on the loop counter #
add  r6,r6,r0

ldr  r0,[r6,#0]              // row 11
str  r0,[r5,#0]
str  r3,[r6,#0]



// third line to second line
ldr  r5,=#0x6000804          // r5 is our address in tile memory for the top line of text
ldr  r6,=#0x6000C10          // r6 is our address in tile memory for the bottom line of text
lsl  r0,r1,#5                // r0 = r1 * 0x20, a quick way to multiply rather than use mul
add  r5,r5,r0                // this gets us the tiles to use based on the loop counter #
add  r6,r6,r0

ldr  r0,[r6,#0]              // get first pixel row of bottom line
str  r0,[r5,#0]              // copy the pixel row to the first pixel row of the top line
str  r3,[r6,#0]              // clear out first pixel row of bottom line

ldr  r0,[r6,#0x4]            // row 2
str  r0,[r5,#0x4]
str  r3,[r6,#0x4]

ldr  r0,[r6,#0x8]            // row 3
str  r0,[r5,#0x8]
str  r3,[r6,#0x8]

ldr  r0,[r6,#0xC]            // row 4
str  r0,[r5,#0xC]
str  r3,[r6,#0xC]

ldr  r6,=#0x6001000
lsl  r0,r1,#5                // r0 = r1 * 0x20, a quick way to multiply rather than use mul
add  r6,r6,r0
ldr  r0,[r6,#0x0]            // row 5
str  r0,[r5,#0x10]
str  r3,[r6,#0x0]

ldr  r0,[r6,#0x4]            // row 6
str  r0,[r5,#0x14]
str  r3,[r6,#0x4]

ldr  r0,[r6,#0x8]            // row 7
str  r0,[r5,#0x18]
str  r3,[r6,#0x8]

ldr  r5,=#0x6000C00
lsl  r0,r1,#5                // r0 = r1 * 0x20, a quick way to multiply rather than use mul
add  r5,r5,r0
ldr  r0,[r6,#0xC]            // row 8
str  r0,[r5,#0x0]
str  r3,[r6,#0xC]

ldr  r0,[r6,#0x10]           // row 9
str  r0,[r5,#0x4]
str  r3,[r6,#0x10]

ldr  r0,[r6,#0x14]           // row 10
str  r0,[r5,#0x8]
str  r3,[r6,#0x14]

ldr  r0,[r6,#0x18]            // row 11
str  r0,[r5,#0xC]
str  r3,[r6,#0x18]

add r1,#1
cmp r1,#0x1E
bge +
b   -            // r1++, if r1 < 1E (# of tiles wide the screen is) then loop back

+
pop {r0-r6,pc}




.3line_vwf_clear_window:
push {r0-r3}

mov  r0,#0
push {r0}
mov  r0,sp

ldr  r1,=#0x6000000
ldr  r2,=#0x1000

mov  r3,#1
lsl  r3,r3,#24
orr  r2,r3                   // set the 24th bit of r2 so it'll know to fill instead of copy
swi  #0x0B                   // clear old data out

pop  {r0}
pop  {r0-r3}

pop  {r3}                    // clobbered code
mov  r8,r3
bx   lr













.finalbattle_vwf1:
push {r5,lr}                 // We're going to use r5, so we need to keep it in 
ldr r5,[sp,#0x08]            // Load r5 with our former LR value? 
mov lr,r5                    // Move the former LR value back into LR 
ldr r5,[sp,#0x04]            // Grab the LR value for THIS function 
str r5,[sp,#0x08]            // Store it over the previous one 
pop {r5}                     // Get back r5 
add sp,#0x04                 // Get the un-needed value off the stack

lsl  r1,r1,#1                // this is code we clobbered while linking here
ldr  r0,[r0,#0]
add  r0,r0,r1

push {r5-r7}
mov  r7,r6
ldr  r6,=#0x2014300          // Load r6 with the base address of our custom RAM block
ldr  r5,=#0x8D1CE78          // load r5 with the address of the font width table

cmp  r7,#0
bne  +                       // if we're on the first character, init stuff, else do main code

//--------------------------------------------------------------------------------------------
// This initializes our custom RAM block

mov  r4,r3
str  r0,[r6,#0x8]            // store the base address of the string in the RAM block

mov  r0,#0x0
strh r0,[r6,#0xC]            // starting position = 0
strh r0,[r6,#0x10]           // current line = 0
strb r0,[r6,#0x12]           // newline_encountered flag = FALSE

mov  r0,#1
strb r0,[r6,#1]              // init_flag = 1, this makes the game not re-initialize everything

ldr  r0,[sp,#0x30]
ldrh r0,[r0,#6]              // r0 now has the total string length
strb r0,[r6,#0xE]            // store total length in our RAM block

lsl  r1,r0,#1                
ldr  r0,[r6,#0x8]            // load the string address
add  r1,r0,r1                // r1 = end of string address
bl   get_special_width
lsr  r0,r0,#1
mov  r1,#120
sub  r0,r1,r0

//ldrh r0,[r4,#0x38]
//mov  r0,#12
strh r0,[r6,#0x4]            // start x
//ldrh r0,[r4,#0x3A]
mov  r0,#46
strh r0,[r6,#0x6]            // start y

ldr  r0,[sp,#0x30]
ldrh r0,[r0,#6]              // r0 now has the total string lengthy
strb r0,[r6,#0xE]            // store total length in our RAM block

//bl   .word_wrap_setup        // add any newlines if text gets too long in the current string

//--------------------------------------------------------------------------------------------
// This is the meat of the code -- this is why we're doing this hack

+
ldr  r0,[r6,#0x8]            // load the base address of the string
ldrh r1,[r6,#0xC]            // load the current position in the string
lsl  r1,r1,#1                // multiply it by 2, since there are two bytes per letter
add  r0,r0,r1                // get the address for the current letter
ldrh r0,[r0,#0]              // load the current character
strh r0,[r6,#0x2]            // store the current character in our RAM block

ldr  r1,=#0xFF02
cmp  r0,r1                   // see if this is a [WAIT] code (0xFF02)
beq  .fb_set_newline
sub  r1,#0x1
cmp  r0,r1                   // see if this is a [BREAK] code (0xFF01)
beq  .fb_set_newline
lsr  r0,r0,#8                // shift right 1 byte
cmp  r0,#0xFF                // is this a control code? 
beq  .fb_move_to_next_char   // if so, manually move to the next char
b    .end_fb_vwf1

//--------------------------------------------------------------------------------------------
// If we're executing this code, we've encountered a code that signifies a line break

.fb_set_newline:
ldrh r0,[r6,#0x10]           // load current line #
add  r0,r0,#0x1
strh r0,[r6,#0x10]           // line_num++

mov  r0,#0x1
strb r0,[r6,#0x12]           // newline_encountered flag = TRUE

.fb_move_to_next_char:
ldrh r0,[r6,#0x0C]           // load current position
add  r0,r0,#0x1              // we need to increment it manually if we're on a control code
strh r0,[r6,#0x0C]

//--------------------------------------------------------------------------------------------
// This is the end area of the code, mostly preparing to leave and doing lines we clobbered

.end_fb_vwf1:
ldr  r1,=#0x5000003
mov  r0,#0x7C
strb r0,[r1,#0]       // turn palette purple for test purposes



ldrh r1,[r6,#0x2]            // load the current character in r1, the game expects this
ldr  r0,=#0xFF30             // load r0 with FF30, which the game expects to be here

pop  {r5-r7,pc}              // time to leave!







.finalbattle_vwf2:
push {r5,lr}                 // We're going to use r5, so we need to keep it in 
ldr r5,[sp,#0x08]            // Load r5 with our former LR value? 
mov lr,r5                    // Move the former LR value back into LR 
ldr r5,[sp,#0x04]            // Grab the LR value for THIS function 
str r5,[sp,#0x08]            // Store it over the previous one 
pop {r5}                     // Get back r5 
add sp,#0x04                 // Get the un-needed value off the stack

push {r5-r6}                 // we really need these registers right now

ldr  r5,=#0x8D1CE78          // load r5 with the address of the font width table
ldr  r6,=#0x2014300          // Load r6 with the base address of our custom RAM block

//--------------------------------------------------------------------------------------------

bl   .fb_process_line           // see if we need to move to a new line, and if so, do stuff accordingly

ldr  r1,[r6,#0x4]            // load the x and y coordinates into r1, these were updated by process_line
mov  r0,r4
add  r0,#0x38                // r4 + #0x38 is where the struct's coordinates are
str  r1,[r0,#0]              // store our custom coordinates in the struct

ldrh r0,[r6,#0x2]            // load the current character
add  r0,r0,r5                // get the address of the current character's width
ldrb r0,[r0,#0]              // load the current character's width

ldrh r1,[r6,#0x4]            // load the current x coordinate
add  r0,r0,r1                // x = x + width_of_current_character
strh r0,[r6,#0x4]            // store the new x coordinate into our RAM block, will be used next call
                             // even if the current character is a control code, we'll still catch it
                             // later and correct it, so it's okay if it gets something crazy here

ldr  r1,[r6,#0x4]            // load the x and y coordinates into r1
mov  r0,r4
str  r1,[r0,#0x44]           // store the next char's location in the location where the next erase is

ldrh r0,[r6,#0xC]            // load our current char position
add  r0,#1                   // increment our current char position
strh r0,[r6,#0xC]            // store it back in our RAM block

ldrh r1,[r6,#0xE]            // load r1 with the total length of this string
cmp  r0,r1                   // see if current character count >= the length of this string
bcc  .end_fb_vwf2          // go to the last part of our code if we're under the total length

mov  r0,#0                   // set init_flag to 0 so that things here will get re-initialized next string
strb r0,[r6,#1]

//--------------------------------------------------------------------------------------------
// This stuff basically gets everything ready before leaving this hack

.end_fb_vwf2:
ldrh r1,[r6,#0x2]            // load r1 with the current character, the game expects this

pop  {r5-r6,pc}                 // get the original values back in these registers




.fb_process_line:
push {lr}
ldrb r1,[r6,#0x12]           // load newline_encountered_flag
cmp  r1,#0                   // compare it to 0
beq  .fb_end_process_line       // don't do any of this code if it's set to FALSE

ldrh r0,[r6,#0x6]            // load current y, add 11
add  r0,#12
strh r0,[r6,#0x6]            // store the new y in our RAM block

ldr  r0,[r6,#0x8]            // load current string's address
ldrh r1,[r6,#0xC]            // load current position in string
lsl  r1,r1,#1
add  r0,r0,r1

push {r0}
ldr  r0,[r6,#0x8]
ldrh r1,[r6,#0xE]
lsl  r1,r1,#1
add  r1,r0,r1                // r1 has the end address
pop  {r0}                    // r0 has the current address

bl   get_special_width
lsr  r0,r0,#1
mov  r1,#120
sub  r0,r1,r0
strh r0,[r6,#0x4]            // store the new x in our RAM block

mov  r0,#0x0
mov  r1,r4
add  r1,#0x30
strb r0,[r1,#0]              // sets the "display this glyph" flag in the current struct

.fb_end_process_line:
mov  r0,#0
strb r0,[r6,#0x12]           // set newline_encountered flag to FALSE

pop  {pc}




.finalbattle_vwf_clear_window:
push {r0-r3}

mov  r0,#0
push {r0}
mov  r0,sp

ldr  r1,=#0x6000000
ldr  r2,=#0x2800

mov  r3,#1
lsl  r3,r3,#24
orr  r2,r3                   // set the 24th bit of r2 so it'll know to fill instead of copy
swi  #0x0B                   // clear old data out

pop  {r0}
pop  {r0-r3}


add  sp,#0x30                // clobbered code
pop  {r3-r5}
bx   lr


//=============================================================================================
// This is the hard-coded text arrangement for item stealing text. This hack re-arranges it to
// make sense.
//=============================================================================================

.item_steal_text:
// Screwing up the stack pointer here causes major problems, so we need to
// store LR into RAM
push {r1}
ldr  r0,=#0x203FFEC
mov  r1,lr
str  r1,[r0,#0]
pop  {r1}
//-----------------------------------------------
// Mystery stuff
mov     r0,r9
bl      $806E274
ldr     r5,[sp,#0xB8]
//-----------------------------------------------
// Load line 0x372 of the battle text ("In the confusion, ...")
ldr     r3,[r5,#0x1C]
mov     r4,#0xA8
lsl     r4,r4,#0x1
add     r3,r3,r4
mov     r0,#0x0
ldsh    r1,[r3,r0]
ldr     r2,=#0x372
mov     r0,r7
ldr     r3,[r3,#0x4]
add     r1,r5,r1
bl      $8091940
mov     r0,r9
mov     r1,r7
bl      $806E374
mov     r0,r7
mov     r1,#0x2
bl      $806E308
//-----------------------------------------------
// Before we go on, store the item number to 2014324
ldr  r3,=#0x2014324
ldr  r2,[sp,#8]
ldrh r2,[r2,#0]
strh r2,[r3,#0]
//-----------------------------------------------
// Load line 0x373 ("stole a [10 FF]!")
ldr     r3,[r5,#0x1C]
add     r3,r3,r4
mov     r2,#0x0
ldsh    r1,[r3,r2]
ldr     r2,=#0x373
mov     r0,r7
ldr     r3,[r3,#0x4]
add     r1,r5,r1
bl      $8091940
mov     r0,r9
mov     r1,r7
bl      $806E374
mov     r0,r7
mov     r1,#0x2
bl      $806E308
//-----------------------------------------------
// Load the number of the item that gets stolen
ldr     r0,[sp,#0x8]
ldrh    r1,[r0,#0]
//-----------------------------------------------
// Do some stuff stuff with the item number
mov     r0,r10
mov     r2,r8
mov     r3,#0x0
bl      $80649AC
mov     r0,r7
mov     r1,r10
bl      $8064B30
mov     r0,r9
mov     r1,r7
bl      $806E374
mov     r0,r7
mov     r1,#0x2
bl      $806E308
//-----------------------------------------------
// Still related to items?
mov     r0,r10
mov     r1,#0x2
bl      $80649E8
//-----------------------------------------------
// Load line 0x3BC ("!")
ldr     r3,[r5,#0x1C]
add     r3,r3,r4
mov     r2,#0x0
ldsh    r1,[r3,r2]
ldr     r2,=#0x3BC
mov     r0,r7
ldr     r3,[r3,#0x4]
add     r1,r5,r1
bl      $8091940
mov     r0,r9
mov     r1,r7
bl      $806E374
mov     r0,r7
mov     r1,#0x2
bl      $806E308
//-----------------------------------------------
// Done
push {r1}
ldr  r3,=#0x203FFEC
ldr  r1,[r3,#0]
mov  lr,r1
pop  {r1}
mov  pc,lr


//=============================================================================================
// This is the hard-coded item steal text for the Mystery Metal Monkey.
//=============================================================================================

.item_steal_text2:
// Screwing up the stack pointer here causes major problems, so we need to
// store LR into RAM
push {r1}
ldr  r0,=#0x203FFEC
mov  r1,lr
str  r1,[r0,#0]
pop  {r1}
//-----------------------------------------------
// Mystery stuff
mov     r0,r10
bl      $806E274
ldr     r5,[sp,#0xB4]
//-----------------------------------------------
// Load line 0x44F ("[11 FF] attacked, and then...")
ldr     r3,[r5,#0x1C]
mov     r4,#0xA8
lsl     r4,r4,#1
add     r3,r3,r4
mov     r0,#0
ldsh    r1,[r3,r0]
ldr     r2,=#0x44F
mov     r0,r8
ldr     r3,[r3,#4]
add     r1,r5,r1
bl      $8091940
mov     r0,r10
mov     r1,r8
bl      $806E374
mov     r0,r8
mov     r1,#2
bl      $806E308
//-----------------------------------------------
// Before we go on, store the item number to 2014324
ldr  r3,=#0x2014324
ldr  r2,[sp,#8]
ldrh r2,[r2,#0]
strh r2,[r3,#0]
//-----------------------------------------------
// Load line 0x373 ("stole [11 FF]")
ldr     r3,[r5,#0x1C]
add     r3,r3,r4
mov     r2,#0
ldsh    r1,[r3,r2]
ldr     r2,=#0x373
mov     r0,r8
ldr     r3,[r3,#4]
add     r1,r5,r1
bl      $8091940
mov     r0,r10
mov     r1,r8
bl      $806E374
mov     r0,r8
mov     r1,#2
bl      $806E308
//-----------------------------------------------
// Do some stuff stuff with the item number
ldr     r0,[sp,#8]
ldrh    r1,[r0,#0]
mov     r0,r9
mov     r2,r7
mov     r3,#0
bl      $80649AC
mov     r0,r8
mov     r1,r9
bl      $8064B30
mov     r0,r10
mov     r1,r8
bl      $806E374
mov     r0,r8
mov     r1,#2
bl      $806E308
mov     r0,r9
mov     r1,#2
bl      $80649E8
//-----------------------------------------------
// Load line 0x3BC ("!")
ldr     r3,[r5,#0x1C]
add     r3,r3,r4
mov     r2,#0x0
ldsh    r1,[r3,r2]
ldr     r2,=#0x3BC
mov     r0,r8
ldr     r3,[r3,#0x4]
add     r1,r5,r1
bl      $8091940
mov     r0,r10
mov     r1,r8
bl      $806E374
mov     r0,r8
mov     r1,#0x2
bl      $806E308
//-----------------------------------------------
// Done
push {r1}
ldr  r3,=#0x203FFEC
ldr  r1,[r3,#0]
mov  lr,r1
pop  {r1}
mov  pc,lr


//=============================================================================================
// This fixes Duster's attack sound bug.
//=============================================================================================
.duster_fix:
push    {lr}

// Call the normal battle code, should work fine for Duster
push    {r0-r3}
bl      $807C1E4
pop     {r0-r3}

// Clobbered code
bl      $8072628

pop     {pc} 
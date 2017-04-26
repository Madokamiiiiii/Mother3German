//============================================================================================
//============================================================================================
// This hack does text "welding" within the game's glyph buffer structs. This particular
// routine affects sprite text.
//
// This hack replaces existing code. The original routine was at 8001EA4, and was shared
// by other routines, namely item name text and the main script text.
//
// We're going to need to store some stuff in a RAM block temporarily. We'll use good old
// 2014320. The layout will be as follows:
//
//    2014320  word  scratch stuff for the 1bpp glyph data and other stuff
//    2014321  ...
//    2014322  ...
//    2014323  ...
//    2014324  byte  total # of tiles/sprites allocated
//    2014325  byte  current x position within the current target glyph
//    2014326  byte  current letter's width
//    2014327  byte  new_tile_flag -- if non-zero, signal later hack to move to next struct
//    2014328  hword current letter
//    2014329  ...
//    201432A  byte  new_line_flag -- if non-zero, signal later hack to move to next line
//    201432B  byte  redraw_flag -- if non-zero, signals the game to redraw subsequent tiles
//    201432C  byte  table_loc -- used to traverse the address/len/etc. tables
//    201432D  byte  fadeout_flag -- if this is set, we're fading out, useful for speedups
//
//============================================================================================

text_weld:
push {r4-r7,lr}          // This is all original code, slightly modified to be more efficient
mov  r5,r0
mov  r4,r1

mov  r6,r3
lsl  r2,r2,#0x10
lsr  r2,r2,#0x6
ldr  r0,=#0x8CDF9F8
add  r2,r2,r0

ldr  r7,=#0x2014320
ldrb r3,[r7,#0x6]        // load the current letter's width
ldrb r7,[r7,#0x5]        // r7 = curr_x

mov  r3,#0
//cmp  r3,r6               // check to see if r6 < 0, if so just quit the routine now
//bcs  .routine_end


//---------------------------------------------------------------------------------------------

mov  r0,r8
push {r0}
mov  r8,r6

.loop_start:
mov  r1,r7               // r1 = curr_x

// ONE
ldrb r0,[r4,#0]          // load the current byte of the glyph from the stack, store in r0
lsl  r0,r0,#0x18         // move the current 1bpp glyph data all the way to the left
lsr  r0,r1               // now shift the current byte over the correct # of bits
mov  r6,r0               // r6 now has the correct order of bits for this 32 pixel row of 1bpp

push {r5}                // we'll need this original value later

lsr  r0,r0,#0x18         // but now we gotta do conversion to 4bpp
lsl  r0,r0,#2            // now multiply by four
ldr  r0,[r2,r0]          // r0 now has the converted 4bpp version
ldr  r1,[r5,#0]          // load what's in the current row
orr  r1,r0               // OR them together
str  r1,[r5,#0]          // and now store it back

lsl  r0,r6,#0x8
lsr  r0,r0,#0x18
lsl  r0,r0,#2
ldr  r0,[r2,r0]          // r0 now has the converted 4bpp version
ldr  r1,[r5,#0x20]       // load what's in the next 8x8 tile over
orr  r1,r0
str  r1,[r5,#0x20]       // store in the next 8x8 tile over

add  r5,#0x8C
lsl  r0,r6,#0x10
lsr  r0,r0,#0x18
lsl  r0,r0,#2
ldr  r0,[r2,r0]          // r0 now has the converted 4bpp version
str  r0,[r5,#0]          // store data in the next struct over

lsl  r0,r6,#0x18
lsr  r0,r0,#0x16
ldr  r0,[r2,r0]          // r0 now has the converted 4bpp version
str  r0,[r5,#0x20]       // store data in the next struct over, next 8x8 tile over

pop  {r5}                // get original r5 back
add  r5,#4               // and increment it properly

add  r4,#1               // increment the stack read address

// TWO
mov  r1,r7

ldrb r0,[r4,#0]
lsl  r0,r0,#0x18
lsr  r0,r1
mov  r6,r0

push {r5}

lsr  r0,r0,#0x18
lsl  r0,r0,#2
ldr  r0,[r2,r0]
ldr  r1,[r5,#0]
orr  r1,r0
str  r1,[r5,#0]

lsl  r0,r6,#0x8
lsr  r0,r0,#0x18
lsl  r0,r0,#2
ldr  r0,[r2,r0]
ldr  r1,[r5,#0x20]
orr  r1,r0
str  r1,[r5,#0x20]

add  r5,#0x8C
lsl  r0,r6,#0x10
lsr  r0,r0,#0x18
lsl  r0,r0,#2
ldr  r0,[r2,r0]
str  r0,[r5,#0]

lsl  r0,r6,#0x18
lsr  r0,r0,#0x16
ldr  r0,[r2,r0]
str  r0,[r5,#0x20]

pop  {r5}
add  r5,#4

add  r4,#1

// THREE
mov  r1,r7

ldrb r0,[r4,#0]
lsl  r0,r0,#0x18
lsr  r0,r1
mov  r6,r0

push {r5}

lsr  r0,r0,#0x18
lsl  r0,r0,#2
ldr  r0,[r2,r0]
ldr  r1,[r5,#0]
orr  r1,r0
str  r1,[r5,#0]

lsl  r0,r6,#0x8
lsr  r0,r0,#0x18
lsl  r0,r0,#2
ldr  r0,[r2,r0]
ldr  r1,[r5,#0x20]
orr  r1,r0
str  r1,[r5,#0x20]

add  r5,#0x8C
lsl  r0,r6,#0x10
lsr  r0,r0,#0x18
lsl  r0,r0,#2
ldr  r0,[r2,r0]
str  r0,[r5,#0]

lsl  r0,r6,#0x18
lsr  r0,r0,#0x16
ldr  r0,[r2,r0]
str  r0,[r5,#0x20]

pop  {r5}
add  r5,#4

add  r4,#1

// FOUR
mov  r1,r7

ldrb r0,[r4,#0]
lsl  r0,r0,#0x18
lsr  r0,r1
mov  r6,r0

push {r5}

lsr  r0,r0,#0x18
lsl  r0,r0,#2
ldr  r0,[r2,r0]
ldr  r1,[r5,#0]
orr  r1,r0
str  r1,[r5,#0]

lsl  r0,r6,#0x8
lsr  r0,r0,#0x18
lsl  r0,r0,#2
ldr  r0,[r2,r0]
ldr  r1,[r5,#0x20]
orr  r1,r0
str  r1,[r5,#0x20]

add  r5,#0x8C
lsl  r0,r6,#0x10
lsr  r0,r0,#0x18
lsl  r0,r0,#2
ldr  r0,[r2,r0]
str  r0,[r5,#0]

lsl  r0,r6,#0x18
lsr  r0,r0,#0x16
ldr  r0,[r2,r0]
str  r0,[r5,#0x20]

pop  {r5}
add  r5,#4

add  r4,#1

// FIVE
mov  r1,r7

ldrb r0,[r4,#0]
lsl  r0,r0,#0x18
lsr  r0,r1
mov  r6,r0

push {r5}

lsr  r0,r0,#0x18
lsl  r0,r0,#2
ldr  r0,[r2,r0]
ldr  r1,[r5,#0]
orr  r1,r0
str  r1,[r5,#0]

lsl  r0,r6,#0x8
lsr  r0,r0,#0x18
lsl  r0,r0,#2
ldr  r0,[r2,r0]
ldr  r1,[r5,#0x20]
orr  r1,r0
str  r1,[r5,#0x20]

add  r5,#0x8C
lsl  r0,r6,#0x10
lsr  r0,r0,#0x18
lsl  r0,r0,#2
ldr  r0,[r2,r0]
str  r0,[r5,#0]

lsl  r0,r6,#0x18
lsr  r0,r0,#0x16
ldr  r0,[r2,r0]
str  r0,[r5,#0x20]

pop  {r5}
add  r5,#4

add  r4,#1

// SIX
mov  r1,r7

ldrb r0,[r4,#0]
lsl  r0,r0,#0x18
lsr  r0,r1
mov  r6,r0

push {r5}

lsr  r0,r0,#0x18
lsl  r0,r0,#2
ldr  r0,[r2,r0]
ldr  r1,[r5,#0]
orr  r1,r0
str  r1,[r5,#0]

lsl  r0,r6,#0x8
lsr  r0,r0,#0x18
lsl  r0,r0,#2
ldr  r0,[r2,r0]
ldr  r1,[r5,#0x20]
orr  r1,r0
str  r1,[r5,#0x20]

add  r5,#0x8C
lsl  r0,r6,#0x10
lsr  r0,r0,#0x18
lsl  r0,r0,#2
ldr  r0,[r2,r0]
str  r0,[r5,#0]

lsl  r0,r6,#0x18
lsr  r0,r0,#0x16
ldr  r0,[r2,r0]
str  r0,[r5,#0x20]

pop  {r5}
add  r5,#4

add  r4,#1

// SEVEN
mov  r1,r7

ldrb r0,[r4,#0]
lsl  r0,r0,#0x18
lsr  r0,r1
mov  r6,r0

push {r5}

lsr  r0,r0,#0x18
lsl  r0,r0,#2
ldr  r0,[r2,r0]
ldr  r1,[r5,#0]
orr  r1,r0
str  r1,[r5,#0]

lsl  r0,r6,#0x8
lsr  r0,r0,#0x18
lsl  r0,r0,#2
ldr  r0,[r2,r0]
ldr  r1,[r5,#0x20]
orr  r1,r0
str  r1,[r5,#0x20]

add  r5,#0x8C
lsl  r0,r6,#0x10
lsr  r0,r0,#0x18
lsl  r0,r0,#2
ldr  r0,[r2,r0]
str  r0,[r5,#0]

lsl  r0,r6,#0x18
lsr  r0,r0,#0x16
ldr  r0,[r2,r0]
str  r0,[r5,#0x20]

pop  {r5}
add  r5,#4

add  r4,#1

// EIGHT
mov  r1,r7

ldrb r0,[r4,#0]
lsl  r0,r0,#0x18
lsr  r0,r1
mov  r6,r0

push {r5}

lsr  r0,r0,#0x18
lsl  r0,r0,#2
ldr  r0,[r2,r0]
ldr  r1,[r5,#0]
orr  r1,r0
str  r1,[r5,#0]

lsl  r0,r6,#0x8
lsr  r0,r0,#0x18
lsl  r0,r0,#2
ldr  r0,[r2,r0]
ldr  r1,[r5,#0x20]
orr  r1,r0
str  r1,[r5,#0x20]

add  r5,#0x8C
lsl  r0,r6,#0x10
lsr  r0,r0,#0x18
lsl  r0,r0,#2
ldr  r0,[r2,r0]
str  r0,[r5,#0]

lsl  r0,r6,#0x18
lsr  r0,r0,#0x16
ldr  r0,[r2,r0]
str  r0,[r5,#0x20]

pop  {r5}
add  r5,#4

add  r4,#1


add  r3,#1               // increment counter
cmp  r3,r8               // see if we're still under the # of bytes we need to convert
bge  +
b    .loop_start

+
pop  {r0}

//---------------------------------------------------------------------------------------------

.routine_end:
mov  r6,r8
mov  r8,r0
pop  {r4-r7,pc}




//============================================================================================
// This section of code is for initialization before a string is printed into OBJ memory.
// It mostly sets a bunch of stuff to 0. This should be called from 80492E2.
//============================================================================================

sprite_text_weld:
.init:
push {lr}
ldr  r3,=#0x2014320
mov  r0,#1
strb r0,[r3,#0x7]        // new_tile_flag = TRUE
mov  r0,#0
strh r0,[r3,#0x4]        // curr_tile_num = 0, curr_x = 0
strb r0,[r3,#0xA]        // new_line_flag = FALSE
strb r0,[r3,#0xB]        // redraw_flag = FALSE
strb r0,[r3,#0xC]        // table_loc = 0

mov  r0,#0
strb r0,[r1,#0x0]        // code we clobbered
pop  {pc}

//============================================================================================
// This section of code stores the current letter to be printed into our RAM block.
// Call from 8049466.
//============================================================================================

.store_letter:
push {r0,lr}
ldr  r1,=#0x2014320      // r1 has RAM block address

lsl  r0,r0,#0x18
lsr  r0,r0,#0x18
strh r0,[r1,#0x8]        // store r0 (current letter value) in RAM block

push {r2,r3}
lsl  r3,r0,#0x18
lsr  r3,r3,#0x18

ldr  r2,=#0x8D1CE78      // will need to modify this later to work with the 8x8 font too!
ldrb r2,[r2,r3]          // get the current letter's width
strb r2,[r1,#0x6]        // store the current letter's width in the RAM block
pop  {r2,r3}

ldrb r1,[r6,#0x10]       // code we clobbered
mov  r0,#0x80
lsl  r1,r1,#0x1C
pop  {r0,pc}

//============================================================================================
// This section of code signals the game to start from a new sprite after certain control
// codes, like FF01 ([BREAK]) codes are encountered. Call from 8049374.
//============================================================================================

.cc_check:
push {lr}
add  r7,sp,#0x4

ldr  r0,=#0xFF01         // [BREAK] check
cmp  r1,r0
beq  .break_found

ldr  r0,=#0xFFE1         // [STATUSICON] check
cmp  r1,r0
beq  .icon_found

b    .cc_check_end

//--------------------------------------------------------------------------------------------

.break_found:
ldr  r1,=#0x2014320
ldrb r0,[r1,#0x7]        // load new_tile_flag
cmp  r0,#0               // if this == TRUE, then we need to move the tile, allocate the sprite
beq  +                   // and all that stuff ourselves

bl   .sprite_snip
bl   .update_x_coord
bl   .custom_create_sprite
b    .cc_set_stuff

//--------------------------------------------------------------------------------------------

+
ldr  r1,=#0x2014320
ldrb r0,[r1,#0xB]        // load redraw_flag
cmp  r0,#0               // if this == FALSE, skip the obj update
beq  .cc_set_stuff
//bl   .update_obj_tile

//--------------------------------------------------------------------------------------------

.cc_set_stuff:
ldr  r1,=#0x2014320
mov  r0,#0
strb r0,[r1,#0x5]        // curr_x = 0
mov  r0,#1
strb r0,[r1,#0x7]        // new_tile_flag = TRUE
strb r0,[r1,#0xA]        // new_line_flag = TRUE

//--------------------------------------------------------------------------------------------

.cc_check_end:
ldrb r0,[r4,#0x3]
mov  r1,#0x8
pop  {pc}

//--------------------------------------------------------------------------------------------

.icon_found:
ldr  r1,=#0x2014320
ldrb r0,[r1,#0x5]
cmp  r0,#3
bgt  +

bl   .sprite_snip

+
ldr  r1,=#0x2014320
ldrb r0,[r1,#0x7]        // load new_tile_flag
cmp  r0,#0               // if this == TRUE, we 
beq  +

bl   .update_x_coord

+
ldr  r1,=#0x2014320
ldrb r0,[r1,#0x7]        // load new_tile_flag
cmp  r0,#0               // if this == TRUE, we need to mess with this sprite and the next one
beq  .icon_end

bl   .custom_create_sprite

.icon_end:
ldr  r1,=#0x2014320
mov  r0,#1
strb r0,[r1,#0x7]        // new_tile_flag = TRUE

b    .cc_check_end


//============================================================================================
// This section of code makes the game allocate a new sprite if necessary. This is one of
// the most important parts of the whole sprite text welding stuff. Call from 80493B4.
//============================================================================================
//
// PSEUDOCODE:
//
//if new_tile == TRUE
//
//   if (newline == FALSE && firstletter == FALSE)
//      add tile width
//
//   if veryfirsttile == FALSE
//      move to next tile()
//   create sprite()
//
//   if firstletter == TRUE || newline == TRUE
//      clear current tile
//
//new_tile = FALSE
//newline  = FALSE
//
//jump to proper location
//--------------------------------------------------------------------------------------------

.create_sprite:
mov  r7,sp               // we'll need this value for the subroutine calls later

ldr  r0,=#0x2014320
ldrb r0,[r0,#0x7]        // load new_tile_flag
cmp  r0,#0
beq  .create_sprite_end  // if FALSE, don't need to move to next tile or create a new sprite

//--------------------------------------------------------------------------------------------

ldr  r0,=#0x2014320      // load new_line_flag
ldrb r0,[r0,#0xA]        
cmp  r0,#0               // if new_line_flag == FALSE, we want to add the sprite width
bne  +                   // so jump over the adding code if it's TRUE and we ARE on a new line

ldr  r0,[r7,#0x14]       // load r0 with the current letter # we're on
cmp  r0,#0               // if it's 0, we don't want to add the sprite width
beq  +

ldr  r0,=#0x20225C8      // this code adds to the sprite's x coordinate.
ldrb r0,[r0,#0]          // it'll almost always be 16 pixels
ldrh r1,[r7,#0x4]
add  r1,r1,r0
strh r1,[r7,#0x4]

//--------------------------------------------------------------------------------------------
+
ldr  r0,[r7,#0x8]        // now to see what tile # we're on
ldr  r2,=#0x76D9
add  r0,r0,r2
ldrb r0,[r0,#0]
cmp  r0,#0               // r0 now has the tile # we're on
beq  +                   // if it's 0, we don't need to move to the next tile

//bl   .update_obj_tile
bl   .move_to_next_tile  // move to the next tile over

+
bl   .custom_create_sprite

//--------------------------------------------------------------------------------------------

.clear_glyph_check:
ldr  r2,=#0x2014320      // load new_line_flag
ldrb r0,[r2,#0xA]        // if we're doing a newline, we need to clear out the glyph
cmp  r0,#0
bne  +

ldrb r0,[r2,#0x5]        // load curr_x
cmp  r0,#0               // if curr_x == 0, we need to clear out the current tile
beq  +

ldr  r0,[r7,#0x14]       // load r0 with the current letter # we're on
cmp  r0,#0               // if it's 0, we want to clear the current glyph
bne  .create_sprite_end

+
ldrb r0,[r2,#0xB]        // load redraw_flag
cmp  r0,#0               // if redraw_flag == FALSE, don't clear out the glyph
beq  +

add  r0,r5,#4            // give r0 the address of the current glyph data
bl   .clear_glyph        // call our function to clear out the current glyph

+
mov  r0,#0
strb r0,[r2,#0x5]        // curr_x = 0

//--------------------------------------------------------------------------------------------

.create_sprite_end:
ldr  r2,=#0x2014320
mov  r0,#0
strb r0,[r2,#0x7]        // new_tile_flag = FALSE
strb r0,[r2,#0xA]        // new_line_flag = FALSE

ldr r0,=#.mr_aftercreatesprite
//ldr  r0,=#0x80493E6      // jump to the correct place back in the main code
mov  pc,r0
//bx   lr
//pop    {pc}


//============================================================================================
// This section of code adds the current width and does width checking and all that.
// It'll also tell the game to move to the next tile if width > 16. Call from 8049512.
//============================================================================================

.add_width:
push {r0-r3,lr}

ldr  r0,=#0x2014320      // load r0 with the custom RAM block's address
ldrb r2,[r0,#0x5]        // load curr_x
ldrb r3,[r0,#0x6]        // load curr_width
add  r2,r2,r3            // curr_x += curr_width
strb r2,[r0,#0x5]        // store the new curr_x back

cmp  r2,#16              // if the new x is >= 16, we need to update stuff
blt  .add_width_end      // else just skip to the end

//-------------------------------------------------------------------------------------------

sub  r2,#16              // calculate the new curr_x for the new sprite tile
strb r2,[r0,#0x5]        // store the new curr_x
mov  r2,#1
strb r2,[r0,#0x7]        // new_tile_flag = TRUE

//-------------------------------------------------------------------------------------------

.add_width_end:
pop  {r0-r3,pc}

//============================================================================================
// This section of code is called when a string has just finished being processed. We need
// to do a few last things to ensure the full string gets displayed. Called from 8049558.
//============================================================================================

.eos_stuff:
push {r0-r3,r7,lr}
add  r7,sp,#0x18

ldr  r3,=#0x2014320      // load r3 with the custom RAM block's address
ldrb r0,[r3,#0xB]        // r0 = redraw_flag
cmp  r0,#0
beq  +
//bl   .update_obj_tile

+
ldr  r3,=#0x2014320      // load r3 with the custom RAM block's address
ldrb r0,[r3,#0x7]        // r0 = new_tile_flag
cmp  r0,#0               // if we didn't just move to a new tile, no problem, skip ahead
beq  +

ldrb r0,[r3,#0x5]        // load r0 with curr_x
cmp  r0,#1               // if we started a new tile and our curr_x <= 1, we don't really
ble  +                   // need to allocate a new tile and sprite, it'd be a complete waste

bl   .sprite_snip
bl   .update_x_coord
bl   .custom_create_sprite

+
ldr  r3,=#0x2014320      // load r3 with the custom RAM block's address
mov  r1,#1
strb r1,[r3,#0x7]        // new_tile_flag = TRUE
pop  {r0-r3,r7}

mov  r0,sp
add  r0,#0xC
ldr  r0,[r0,#0x0]        // code we clobbered
mov  r1,#0
pop  {pc}


//============================================================================================
// This section of code clears out the glyph whose address starts at r0. It's assumed that
// there are 0x80 bytes in the glyph. Called by a custom hack.
//============================================================================================

.clear_glyph:
push {r0-r3,lr}
mov  r1,r0               // give r0 to r1, since r1 needs to contain the target address
ldr  r0,=#0x2014320
mov  r2,#0
str  r2,[r0,#0]          // store 0x00000000 in our RAM block
mov  r2,#0x40            // give r2 the number of halfwords to clear
mov  r3,#1
lsl  r3,r3,#24
orr  r2,r3               // set the 24th bit of r2 so it'll know to fill instead of copy
swi  #0x0B               // clear the next glyph out
pop  {r0-r3,pc}

//============================================================================================
// This section of code makes the game move to the next tile area in OBJ memory.
// Called by custom hacks. r7 needs to have the SP + push offset caused by calling this.
//============================================================================================

.move_to_next_tile:
push {r0-r3,lr}

add  r4,#0x8C            // this is the original code, it's used to increment to the
ldr  r1,[r7,#0x24]       // next struct glyph. r5 points to the actual glyph data itself
add  r1,#0x8C            // within the struct, not sure what the others are but oh well
str  r1,[r7,#0x24]
add  r5,#0x8C

ldr  r0,[r7,#0x18]       // original code, not sure what it does
add  r0,#4
str  r0,[r7,#0x18]

ldr  r2,[r7,#0x0C]       // original code, calculates the next target address in OBJ memory
add  r2,#0x80            // we're going to need to do this at EOS, will figure out later
str  r2,[r7,#0x0C]

//ldr  r1,[sp,#0xC]
str  r2,[r5,#0]                         // store the target OBJ address in struct header

//ldr  r1,=#0x2014320       // increment the total # of sprites used
//ldrb r0,[r1,#0x4]
//add  r0,#1
//strb r0,[r1,#0x4]

pop  {r0-r3,pc}

//============================================================================================
// This section of code allocates a new sprite. It's called by a custom hack.
//============================================================================================

.custom_create_sprite:
push {r0,r7,lr}

mov  r2,r7
mov  r7,#6
ldsh r1,[r2,r7]
mov  r7,#4
ldsh r0,[r2,r7]
lsl  r0,r0,#0x10
orr  r1,r0
mov  r0,#0x80
lsl  r0,r0,#0x17
orr  r1,r0
ldr  r0,[r2,#0x1C]
str  r1,[r0,#0]
ldrb r0,[r6,#0x10]
lsl  r0,r0,#0x1A
lsr  r0,r0,#0x1E
lsl  r0,r0,#0x0A
ldr  r1,[r2,#0x18]
orr  r0,r1
ldr  r7,=#0xFFFFE000
mov  r1,r7
orr  r0,r1
ldr  r1,[r2,#0x1C]
strh r0,[r1,#0x4]
add  r1,#8
str  r1,[r2,#0x1C]

ldr  r7,=#0x2014320       // increment the total # of sprites used
ldrb r0,[r7,#0x4]
add  r0,#1
strb r0,[r7,#0x4]

pop  {r0,r7,pc}

//============================================================================================
// This section of code manually updates the current tile in OBJ memory.
//============================================================================================

.update_obj_tile:
push {lr}

mov  r0,r5
add  r0,#4
ldr  r1,[r7,#0x0C]       // get current OBJ memory address to write to
mov  r2,#0x80            // number of bytes to transfer
bl   $8001A14            // call a built-in subroutine to DMA r0 to r1 for r2 bytes

pop  {pc}

//============================================================================================
// This section of code manually updates the current sprite's x coordinate.
//============================================================================================

.update_x_coord:
push {lr}

ldr  r0,=#0x20225C8      // this code adds to the sprite's x coordinate.
ldrb r0,[r0,#0]          // it'll almost always be 16 pixels
ldrh r1,[r7,#0x4]
add  r1,r1,r0
strh r1,[r7,#0x4]

pop  {pc}


//============================================================================================
// This section of code is called by custom hacks in the rare instances of a partial letter
// in a new tile right before an [END] code or a control code.
// r7 needs to have the proper location on the stack
//============================================================================================

.sprite_snip:
push {r0-r1,lr}

bl   .move_to_next_tile
//bl   .write_struct_info
//bl   .update_obj_tile

pop  {r0-r1,pc}

//============================================================================================
// This hack is called to get an accurate count of the # of sprites used. It might not take
// things like status icons into account though, so we might have to deal with that later.
// Anyway, this is called from 804950A.
//============================================================================================

.get_sprite_total:
push {r2,r5}
ldr  r5,=#0x2014320      // r1 has RAM block address

ldr  r0,[sp,#0x8]
ldrh r0,[r0,#0x0]
strh r0,[r5,#0x8]        // store r0 (current letter value) in RAM block

ldr  r2,=#0x8D1CE78      // will need to modify this later to work with the 8x8 font too!
ldrb r2,[r2,r0]          // get the current letter's width
strb r2,[r5,#0x6]        // store the current letter's width in the RAM block
pop  {r2,r5}

ldr  r0,=#0x2014320
ldrb r0,[r0,#0x4]
bx   lr

//============================================================================================
// This hack is called to give the game's OAM clearer an accurate count of the # of sprites
// used. This fixes some garbage sprite bugs we had. This is called from 803EA6C.
//============================================================================================

.fix_sprite_total:
ldr  r5,=#0x2014320
ldrb r5,[r5,#0x4]
bx   lr

//============================================================================================
// This hack is used to fix the x-coord of status icons within sprite text.
// Called from 80496A4.
//============================================================================================

.get_icon_coord:
mov  r1,sp
ldrb r1,[r1,#0x1C]     // load the x coord of the current text sprite

push {r0,r2}
ldr  r2,=#0x2014320    // we need to load curr_x so we know how many pixels in the current
ldrb r0,[r2,#0x5]      // text sprite we've gone
add  r1,r1,r0
mov  r0,#0
strb r0,[r2,#0x5]      // curr_x = 0

add  r2,sp,#8
strb r1,[r2,#0x1C]     // store the icon's x as the current x
pop  {r0,r2}

bx   lr


//============================================================================================
// This part is where we do our efficiency checks, the pseudocode is as follows:
//
//   if curr_letter == 0
//   {
//      if redraw_flag == FALSE
//      {
//         if curr_address != address[tableptr * 4]
//            redraw_flag = TRUE
//         else if curr_str_len != strlen[tableptr]
//            redraw_flag = TRUE
//         else if curr_hash != hash[tableptr * 4]
//            redraw_flag = TRUE
//      }
//
//      address[tableptr * 4] = curr_address
//      strlen[tableptr] = curr_str_len
//      hash[tableptr] = curr_hash
//
//      tableptr++
//   }
//
//============================================================================================

.efficiency_check:
push {r0-r7,lr}

add  r7,sp,#0x24         // make r7 be the pretend sp

ldr  r0,[r7,#0x14]       // load the current letter #
cmp  r0,#0               // if this isn't the first letter, skip this crap
bne  .eff_check_end

//-------------------------------------------------------------------------------------------

+
ldr  r6,=#0x2014300      // if fadeout_flag = TRUE, then don't bother with these checks
mov  r1,#0x2D
ldrb r0,[r6,r1]
cmp  r0,#0
bne  .eff_check_end

ldr  r0,[sp,#0x18]       // at [[sp,#0x18],#0x0] is the address of the current string
ldr  r0,[r0,#0x0]        // r0 now has the current string's address
ldr  r1,[sp,#0x18]       // at [[sp,#0x18],#0xE] is the string length
ldrh r1,[r1,#0xE]        // r1 now has the string length
bl   .get_hash           // get the hash value for the current string, return value in r0
str  r0,[r6,#0x0]        // store our hash temporarily for easy access

add  r6,#0x20            // r6 = address of our RAM block
ldrb r0,[r6,#0xB]        // load redraw_flag
cmp  r0,#0               // if already TRUE, then skip the following checks
bne  .update_tables

//-------------------------------------------------------------------------------------------

.address_check:
ldr  r5,=#0x20142B0      // r5 = base address of address table
ldrb r0,[r6,#0xC]
lsl  r0,r0,#2            // r0 = table_loc * 4
mov  r2,r0
ldr  r0,[r5,r0]          // r0 = last address

//ldr  r3,=#0x203FFA0
//ldr  r4,[r3,r2]
ldr  r4,[sp,#0x18]       // at [[sp,#0x18],#0x0] is the address of the current string
ldr  r4,[r4,#0x0]        // r4 now has the current string's address

cmp  r4,r0
beq  .length_check
//beq  .inc_table_loc       // if curr_address == last_address, move to the string length test

mov  r0,#1
strb r0,[r6,#0xB]        // else redraw_flag = TRUE
ldr  r0,[r7,#0x24]       // r0 = address of current glyph now
bl   .clear_glyphs
b    .update_tables

//-------------------------------------------------------------------------------------------

.length_check:
ldr  r5,=#0x20142F0      // r5 = base address of string length table
ldrb r0,[r6,#0xC]        // load table_loc
ldrb r0,[r5,r0]          // r0 = last_str_len

ldr  r4,[sp,#0x18]       // at [[sp,#0x18],#0xE] is the string length
ldrh r4,[r4,#0xE]        // r4 now has the string length

cmp  r4,r0               // if curr_len == last_str_len, move on ahead
beq  .hash_check

mov  r0,#1
strb r0,[r6,#0xB]        // else redraw_flag = TRUE
ldr  r0,[r7,#0x24]       // r0 = address of current glyph now
bl   .clear_glyphs
b    .update_tables

//-------------------------------------------------------------------------------------------

.hash_check:
ldr  r5,=#0x2014270      // r5 = base address of hash table
ldrb r0,[r6,#0xC]
lsl  r0,r0,#2            // r0 = table_loc * 4
ldr  r0,[r5,r0]          // r0 = last hash

sub  r6,#0x20
ldr  r1,[r6,#0x0]        // r1 = current hash
add  r6,#0x20

cmp  r0,r1
beq  .inc_table_loc      // if curr_hash == last_hash, no need to redraw stuff

mov  r0,#1
strb r0,[r6,#0xB]        // else redraw_flag = TRUE
ldr  r0,[r7,#0x24]       // r0 = address of current glyph now
bl   .clear_glyphs

//-------------------------------------------------------------------------------------------

.update_tables:
ldrb r0,[r6,#0xC]        // load table_loc

ldr  r5,=#0x20142F0      // r5 = base address of string length table
ldr  r4,[sp,#0x18]       // at [[sp,#0x18],#0xE] is the string length
ldrh r4,[r4,#0xE]        // r4 now has the string length
strb r4,[r5,r0]          // store the current string length in the proper table spot

sub  r5,#0x40            // r5 = base address of address table
lsl  r0,r0,#2            // r0 = table_loc * 4
ldr  r4,[r3,r0]
ldr  r4,[sp,#0x18]       // at [[sp,#0x18],#0x0] is the address of the current string
ldr  r4,[r4,#0x0]        // r4 now has the current string's address
str  r4,[r5,r0]          // store the current address in the proper table spot

sub  r5,#0x40            // r5 = base address of hash table
sub  r6,#0x20
ldr  r4,[r6,#0x0]        // load current hash
add  r6,#0x20
str  r4,[r5,r0]          // store current hash in the proper table spot

//-------------------------------------------------------------------------------------------

.inc_table_loc:

ldrb r0,[r6,#0xC]        // table_loc++
add  r0,#1
strb r0,[r6,#0xC]

//-------------------------------------------------------------------------------------------

.eff_check_end:
pop  {r0-r7}          // restore registers and return

ldrh r1,[r3,#0x0]     // code we clobbered
ldr  r0,=#0xFEFF
pop  {pc}


//============================================================================================
// This is the code that tells the game if it needs to redraw text or not.
// Called from 8049402.
//============================================================================================

.efficiency_branch:
push {lr}
add  r2,r2,r5             // original code
mov  r9,r2

ldr  r2,=#0x2014320
ldrb r2,[r2,#0xB]         // load redraw_flag
pop  {pc}


//============================================================================================
// This routine is called by our custom hack. It clears out all glyphs from the current one.
//============================================================================================

.clear_glyphs:
push {r0-r7,lr}
mov  r1,r0
ldr  r0,=#0x2014320
mov  r2,#0
str  r2,[r0,#0]          // store 0x00000000 in our RAM block

ldr  r5,=#0x201F994
sub  r5,r5,r1
lsr  r2,r5,#1            // r2 has the number of halfwords to clear

mov  r3,#1
lsl  r3,r3,#24
orr  r2,r3               // set the 24th bit of r2 so it'll know to fill instead of copy
swi  #0x0B               // clear the next glyph out

pop  {r0-r7,pc}


//============================================================================================
// This routine is called right after all a fadeout starts. This code sets a flag that tells
// the sprite welding hack to skip some CPU intensive stuff since we can assume text won't
// change during a fadeout. Called from 803E170.
//============================================================================================

.set_fadeout_flag:
push {r1,lr}

ldr  r1,=#0x2014320
mov  r0,#0x1
strb r0,[r1,#0xD]        // fadeout_flag = TRUE

ldr  r0,=#0x20051E8      // clobbered code
ldrb r0,[r0,#0]

pop  {r1,pc}


//============================================================================================
// This code "breaks" the "last loop table", and is called between screen transitions.
// This fixes a bug with the sprite text. Called from 803E24C.
//============================================================================================

.clear_table:
push {lr}

mov  r0,#1
neg  r0,r0

ldr  r1,=#0x2014270      // r1 = base address of hash table
str  r0,[r1,#0]          // store FFFFFFFF as the current hash

add  r1,#0x40            // r1 = base address of address table
str  r0,[r1,#0]          // store FFFFFFFF as the address

add  r1,#0x40            // r1 = base address of string length table
str  r0,[r1,#0]          // store FF as the first four string lengths in the table

//add  r1,#0x10            // r1 = base address of our RAM block



ldr  r1,=#0x2014320
mov  r0,#0
strb r0,[r1,#0xD]        // fadeout_flag = FALSE
mov  r0,#0xFF
strb r0,[r1,#0xE]        // set last number of strings = FF

pop  {r0}

add  sp,#0x10
pop  {r4-r6}
bx   r0


//============================================================================================
// This code gets a hash for the string in r0 with length r1. Used by our sprite text hack
// so it can tell when text has changed.
//============================================================================================

.get_hash:
push {r2-r7,lr}
// r0 = source address
// r1 = length
ldr  r2,=#0x1000193        // FNV_prime
ldr  r3,=#0x811C9DC5       // offset_basis/hash
mov  r4,#0                 // counter
-
ldrh r5,[r0,#0]
add  r0,#2
cmp  r5,#0xFF              // ignore control codes?
bgt  -
eor  r3,r5                 // hash ^= data
mul  r3,r2                 // hash *= FNV_prime
add  r4,#1
cmp  r4,r1
bne  -
// r0 = resulting hash
mov  r0,r3
pop  {r2-r7,pc}            // restore registers and leave


//============================================================================================
// This routine is called right after all sprite strings have been processed. It clears out
// any unused portions of the "last time" tables to prevent any weirdness later.
// Called from 804957E.
//============================================================================================

.clear_unused_table_stuff:
push {r0-r7,lr}

ldr  r5,[sp,#0x34]      // r6 = total # of strings we just processed
mov  r1,#1
neg  r1,r1              // r1 = FFFFFFFF

-
cmp  r5,#16
bge  +

lsl  r2,r5,#2           // r2 = counter * 4 (used for convenience's sake)
ldr  r4,=#0x2014270     // r4 = base address of hash table
str  r1,[r4,r2]         // store FFFFFFFF at hash table entry

add  r4,#0x40           // r4 = base address of address table
str  r1,[r4,r2]         // store FFFFFFFF at address table entry

add  r4,#0x40           // r4 = base address of string length table
strb r1,[r4,r5]         // store FF at string length table entry

add  r5,#1              // increment counter and loop back
b    -

+
pop  {r0-r7}
ldr  r2,=#0x2018CC0     // code we clobbered
pop  {pc}






















.main_routine:
push {r4-r7,lr}
mov  r7,r10
mov  r6,r9
mov  r5,r8
push {r5-r7}
add  sp,#-0x2C
str  r0,[sp,#0x8]
ldr  r2,=#0x76D9
add  r1,r0,r2
bl   sprite_text_weld.init              // init

ldr  r0,=#0x2016028
ldr  r3,=#0xC620
add  r1,r0,r3
ldr  r7,=#0x2C98
add  r0,r0,r7
ldrh r0,[r0,#0]
lsl  r0,r0,#0x3
ldr  r1,[r1,#0]
add  r1,r1,r0
str  r1,[sp,#0x1C]
str  r1,[sp,#0x20]
ldr  r1,[sp,#0x8]
ldr  r2,=#0x6C44
add  r0,r1,r2
ldr  r0,[r0,#0]
ldr  r6,[r0,#0x4]
mov  r3,#0x98
lsl  r3,r3,#0x6
add  r5,r1,r3
ldr  r7,=#0x6010000
str  r7,[sp,#0xC]
mov  r1,#0
str  r1,[sp,#0x18]
mov  r2,#0
str  r2,[sp,#0x10]
ldrb r0,[r0,#0x9]
cmp  r2,r0
bcc  .mr_outerloop
b    .mr_exit

//-------------------------------------------------------------------------------------------

.mr_outerloop:                          // start of big loop to do all lines
ldrb r1,[r6,#0x10]
mov  r0,#0x80
and  r0,r1
cmp  r0,#0
beq  +

ldr  r0,[sp,#0x8]
mov  r1,#1
bl   $8049C70

+
ldrh r0,[r6,#0x8]
ldr  r3,=#0x1FF
mov  r1,r3
and  r1,r0
ldr  r2,=#0xFFFF0000
ldr  r0,[sp,#0x4]
and  r0,r2
orr  r0,r1
str  r0,[sp,#0x4]
ldrb r2,[r6,#0xA]
lsl  r2,r2,#0x10
ldr  r1,=#0xFFFF
and  r0,r1
orr  r0,r2
str  r0,[sp,#0x4]
ldr  r0,[r6,#0]
str  r0,[sp,#0]
mov  r7,#0
str  r7,[sp,#0x14]
ldrh r0,[r6,#0xE]
cmp  r7,r0
bcc  +
b    .mr_eos

+
mov  r4,r5
add  r4,#0x84
mov  r1,r5
add  r1,#0x88
str  r1,[sp,#0x24]

//-------------------------------------------------------------------------------------------

.mr_innerloop:
ldr  r3,[sp,#0]                         // start of big inner loop, does all letters in curr line
bl   sprite_text_weld.efficiency_check

cmp  r1,r0
bls  .mr_createsprite
bl   sprite_text_weld.cc_check

//orr  r0,r1
//strb r0,[r4,#0x3]                       // this causes trouble with weird letter for some reason
ldr  r0,[sp,#0x8]
mov  r1,r6
mov  r2,sp
add  r3,sp,#4
bl   $80495C8
b    .mr_nextletter                     // move to the next letter of the current line

//-------------------------------------------------------------------------------------------

.mr_createsprite:
bl   sprite_text_weld.create_sprite     //  (a bunch of code is manually skipped after this)

.mr_aftercreatesprite:
ldrh r1,[r3,#0]
ldrh r0,[r4,#0x4]
lsl  r0,r0,#0x14
lsr  r0,r0,#0x14
ldr  r3,[sp,#0x24]
mov  r7,r5
add  r7,#0x85
mov  r2,#0x89
add  r2,r2,r5
mov  r8,r2
mov  r2,#0x8B
add  r2,r2,r5
mov  r10,r2
mov  r2,#0x8A
bl   sprite_text_weld.efficiency_branch
cmp  r2,#0
bne  +
b    .mr_incrementstuff

//-------------------------------------------------------------------------------------------

+
str  r3,[sp,#0x28]                      // took out some code after this line

ldr  r0,[sp,#0]                         // this stuff sets up the glyph header/footer info
ldr  r1,[r0,#0]
ldr  r2,=#0x0FFF
and  r1,r2
ldr  r2,[r4,#0]
ldr  r0,=#0xFFFFF000
and  r0,r2
orr  r0,r1
str  r0,[r4,#0]
push {lr}
bl   sprite_text_weld.store_letter
pop  {r2}
mov  lr,r2

lsr  r1,r1,#0x18
ldrb r2,[r7,#0]
mov  r0,#0xF
and  r0,r2
orr  r0,r1
strb r0,[r7,#0]
ldrb r0,[r4,#0x3]
mov  r2,#0x9
neg  r2,r2
mov  r1,r2
and  r0,r1
strb r0,[r4,#0x3]
ldr  r1,[sp,#0x18]
ldr  r0,=#0x3FF
and  r1,r0
ldrh r2,[r4,#0x2]
ldr  r0,=#0xFFFFFC00
and  r0,r2
orr  r0,r1
strh r0,[r4,#0x2]
ldr  r1,[sp,#0xC]
str  r1,[r5,#0]                         // store the target OBJ address in struct header
ldrb r1,[r4,#0x3]
mov  r0,#0x5
neg  r0,r0
and  r0,r1
strb r0,[r4,#0x3]
ldrh r1,[r4,#0]
lsl  r1,r1,#0x14
lsr  r1,r1,#0x14
ldr  r2,=#0xFFF
and  r1,r2
ldr  r3,[sp,#0x28]
ldrh r2,[r3,#0]
ldr  r0,=#0xFFFFF000
and  r0,r2
orr  r0,r1
strh r0,[r3,#0]
ldrb r1,[r7,#0]
lsr  r1,r1,#0x4
lsl  r1,r1,#0x4
mov  r3,r8
ldrb r2,[r3,#0]
mov  r0,#0xF
and  r0,r2
orr  r0,r1
strb r0,[r3,#0]
ldrh r1,[r4,#0x2]
lsl  r1,r1,#0x16
lsr  r1,r1,#0x16
ldr  r7,=#0x3FF
and  r1,r7
mov  r0,r9
ldrh r2,[r0,#0]
ldr  r0,=#0xFFFFFC00
and  r0,r2
orr  r0,r1
mov  r1,r9
strh r0,[r1,#0]
ldrb r1,[r6,#0x10]
lsr  r1,r1,#0x7
lsl  r1,r1,#0x2
mov  r3,r10
ldrb r2,[r3,#0]
mov  r0,#0x5
neg  r0,r0
and  r0,r2
orr  r0,r1
strb r0,[r3,#0]
ldr  r0,[sp,#0]
ldrh r1,[r0,#0]
mov  r0,r5
bl   $80496F8                           // eventually calls routine to draw font, copy to struct

//-------------------------------------------------------------------------------------------

.mr_incrementstuff:
ldr  r7,[sp,#0x8]
ldr  r0,=#0x76D9
add  r1,r7,r0
ldrb r0,[r1,#0]
add  r0,#1
strb r0,[r1,#0]
bl   sprite_text_weld.get_sprite_total
cmp  r0,#0x5F
bhi  .mr_exit
bl   sprite_text_weld.add_width         // took out some code after here

.mr_nextletter:
ldr  r0,[sp,#0x14]
add  r0,#1
lsl  r0,r0,#0x10
lsr  r0,r0,#0x10
str  r0,[sp,#0x14]
ldr  r0,[sp,#0]
add  r0,#2
str  r0,[sp,#0]
ldr  r0,[sp,#0x14]
ldrh r1,[r6,#0xE]
cmp  r0,r1
bcs  .mr_eos
b    .mr_innerloop

//-------------------------------------------------------------------------------------------

.mr_eos:
bl   sprite_text_weld.eos_stuff
bl   $8049C70

ldr  r0,[sp,#0x10]
add  r0,#1
lsl  r0,r0,#0x10
lsr  r0,r0,#0x10
str  r0,[sp,#0x10]
add  r6,#0x14
ldr  r2,[sp,#0x8]
ldr  r3,=#0x6C44
add  r0,r2,r3
ldr  r0,[r0,#0]
ldr  r7,[sp,#0x10]
ldrb r0,[r0,#0x9]
cmp  r7,r0
bcs  .mr_exit
b    .mr_outerloop                      // loop back if not done with all the lines yet

//-------------------------------------------------------------------------------------------

.mr_exit:
ldr  r2,=#0x2016028
bl   sprite_text_weld.clear_unused_table_stuff

ldr  r1,[sp,#0x1C]
ldr  r3,[sp,#0x20]
sub  r0,r1,r3
lsr  r0,r0,#3
ldrh r1,[r2,#0]
add  r1,r1,r0
ldrh r0,[r2,#0]
strh r1,[r2,#0]

add  sp,#0x2C
pop  {r3-r5}
mov  r8,r3
mov  r9,r4
mov  r10,r5
pop  {r4-r7}
pop  {r0}
bx   r0

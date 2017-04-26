main_menu_hacks:

//=============================================================================================
// This set of hacks makes the game load and display long strings on main menu stuff correctly.
//=============================================================================================

.write_item_text:
push {r0-r1,lr}

// custom jeff code
ldr  r0,=#0x201A288
ldrb r0,[r0,#0]
cmp  r0,#6
bne  +
pop  {r0}
str  r0,[sp,#0xC]            // clobbered code
ldr  r0,[r4,#0x0]
pop  {r1,pc}
//

+
ldr  r0,=#0x2013070          // starting address of our item names in RAM
mov  r1,#0x58                // # of max letters per item * 4, since each letter has 4 bytes for some reason
mul  r1,r6                   // r6 has the current item counter, which is nice and convenient for us
add  r0,r0,r1                // r2 now has the proper spot in RAM for the item

pop  {r1}                    // get the address the game would write to normally
str  r0,[r1,#0x0]            // r0 leaves with the new address in RAM for longer names yay

str  r0,[sp,#0xC]            // clobbered code
ldr  r0,[r4,#0x0]
pop  {r1,pc}

//=============================================================================================

.write_item_eos:
push {lr}

// custom jeff code
ldr  r0,=#0x201A288
ldrb r0,[r0,#0]
cmp  r0,#6
beq  +
//

ldr  r1,=#0x2013070
mov  r0,r10
sub  r0,#1
mov  r2,#0x58
mul  r0,r2
add  r1,r0,r1
lsl  r6,r6,#2
add  r1,r1,r6
mov  r0,#1
neg  r0,r0
str  r0,[r1,#0]

+
mov  r1,r10                  // clobbered code
lsl  r0,r1,#0x10
pop  {pc}

//=============================================================================================

.clear_data:
push {r2-r3,lr}

// custom jeff code
ldr  r2,=#0x201A288
ldrb r2,[r2,#0]
cmp  r2,#6
beq  +
//

mov  r0,#0
push {r0}
mov  r0,sp

ldr  r1,=#0x2013060
ldr  r2,=#0x908

mov  r3,#1
lsl  r3,r3,#24
orr  r2,r3                   // set the 24th bit of r2 so it'll know to fill instead of copy
swi  #0x0B                   // clear old data out

add  sp,#4
+
mov  r0,#0xD8 // I assume this is clobbered code?
lsl  r0,r0,#0x7
pop  {r2-r3,pc}

//=============================================================================================

.check_for_eos:
push {r5,lr}

// custom jeff code
ldr  r5,=#0x201A288
ldrb r5,[r5,#0]
cmp  r5,#6
beq  +
//

mov  r1,#1
neg  r1,r1                   // r1 = FFFFFFFF
ldr  r0,[r6,#0x0]            // load the value
cmp  r0,r1                   // if they're not equal, we're not at end of string, so leave
bne  +

ldr  r6,=#0x2013060
mov  r1,#0
strb r1,[r6,#0x4]            // swap_address = false

ldr  r6,[r6,#0x0]            // load the real address that pointed to this string
add  r6,#4                   // move it to the next spot

+
ldr  r0,[r6,#0x0]            // load the real next value
lsl  r0,r0,#0x14             // clobbered code
pop  {r5,pc}

//=============================================================================================

.get_ram_address2:
push {lr}

// custom jeff code
ldr  r0,=#0x201A288
ldrb r0,[r0,#0]
cmp  r0,#6
beq  +
//

ldr  r1,=#0x2013060          // temporary address storage
ldrb r0,[r6,#0x4]            // load address_swap
cmp  r0,#0
bne  +

str  r6,[r1,#0x0]            // store the address in temporary storage
ldr  r6,[r6,#0x0]            // switch the read address to our custom address

mov  r0,#0x1
strb r0,[r1,#0x4]            // address_swap = TRUE

+
ldr  r0,[r6,#0x0]            // original code
lsl  r0,r0,#0x10
pop  {pc}

//=============================================================================================

.clear_swap_flag:
push {lr}

// custom jeff code
ldr  r3,=#0x201A288
ldrb r3,[r3,#0]
cmp  r3,#6
beq  +
//

mov  r0,#0
ldr  r3,=#0x2013060
strb r0,[r3,#0x4]            // swap_address = false for future callings

+
ldr  r3,=#0x25F4             // clobbered code
add  r0,r4,r3
pop  {pc}

//=============================================================================================

.check_special_bit:
push {r2,lr} // why are you pushing r2? :P
strh r1,[r6,#2]              // original code
ldr  r0,[r4,#0]

// custom jeff code
// maybe this is why :O
ldr  r2,=#0x201A288
ldrb r2,[r2,#0]
cmp  r2,#6
beq  +
//

ldr  r0,[r0,#0]              // load the first letter data of the real text in
+
pop  {r2,pc}

//=============================================================================================

.store_total_letters:
// custom jeff code
ldr  r0,=#0x201A288
ldrb r0,[r0,#0]
cmp  r0,#6
beq  +
//

ldr  r2,=#0x2013040
ldrh r0,[r2,#0]              // load the current letter total
add  r0,#1
strh r0,[r2,#0]              // increment and store the letter total back
bx   lr

+
ldrb r0,[r1,#0] // clobbered code
add  r0,#1
strb r0,[r1,#0]
bx   lr

//=============================================================================================

// 2013040  halfword  total # of letters
// 2013041  ...
// 2013042  byte      total # of passes that will be needed
// 2013043  byte      current pass #
// this routine initializes most of this stuff

.write_group_lengths:
push {r2-r4,lr}

// custom jeff code
ldr  r2,=#0x201A288
ldrb r2,[r2,#0]
cmp  r2,#6
bne  +
ldrb r0,[r0,#0] // clobbered code
lsr  r1,r0,#2
pop  {r2-r4,pc}
//

+
ldr  r4,=#0x2013040          // custom area of RAM for this is here
mov  r2,#0
strh r2,[r4,#2]              // total # of passes = 0, current pass = 0
str  r2,[r4,#0x10]           // now clear out the pass info on the next line
str  r2,[r4,#0x14]           // now clear out the pass info on the next line
str  r2,[r4,#0x18]           // now clear out the pass info on the next line
str  r2,[r4,#0x1C]           // now clear out the pass info on the next line

ldrh r0,[r4,#0]              // load the total # of letters
mov  r1,#40                  // total # of glyph buffers the game allows
swi  #6                      // total letters / 40, r0 = result, r1 = remainder

mov  r3,r0                   // r3 will be our total # of passes
mov  r0,#40                  // each normal pass will have 40 letters
mov  r2,#0                   // start our loop at 0
add  r4,#0x10                // move r4 to the pass info line

-
cmp  r2,r3
bge  +
strb r0,[r4,r2]              // store normal pass length
add  r2,#1
b    -                       // loop back, this is like a small for loop

+
cmp  r1,#0                   // check that remainder
beq  +                       // if remainder == 0, don't need to add an extra pass

add  r3,#1
strb r1,[r4,r2]              // add the extra final pass length

+
sub  r4,#0x10
strb r3,[r4,#2]              // store the total # of passes
ldrh r0,[r4,#0]              // load the total # of letters
lsr  r1,r0,#4                // original code, divides total # of letters by 4
pop  {r2-r4,pc}

//=============================================================================================

.load_curr_group_length1:
// custom jeff code
ldr  r0,=#0x201A288
ldrb r0,[r0,#0]
cmp  r0,#6
bne  +
ldrb r0,[r5,#0] // clobbered code
lsl  r0,r0,#0x1D
lsr  r0,r0,#0x1D
ldr  r2,=#0x76D2
add  r1,r4,r2
add  r0,r0,r1
ldrb r1,[r0,#0]
bx   lr
//
+
ldr  r0,=#0x2013040
ldrb r1,[r0,#3]              // get the current pass #
add  r0,#0x10
ldrb r1,[r0,r1]              // load the current length of the current group
bx   lr

//=============================================================================================

.load_curr_group_length2:
// custom jeff code
ldr  r0,=#0x201A288
ldrb r0,[r0,#0]
cmp  r0,#6
bne  +
add  r0,r4,r3 // clobbered code
ldrb r0,[r0,#0]
bx   lr
//
+
ldr  r0,=#0x2013040          // address of our group length array is this + 10
ldrb r1,[r0,#3]              // load the current pass #
mov  r3,r1
//add  r3,r1,#1
//strb r3,[r0,#3]              // increment the pass #

add  r0,#0x10                // move to the array now
ldrb r0,[r0,r1]              // load the proper group length, this is still tricky business though
bx   lr

//=============================================================================================

.group_add_check:
push {r2-r3}
// custom jeff code
ldr  r3,=#0x201A288
ldrb r3,[r3,#0]
cmp  r3,#6
bne  +
add  r0,#1 // clobbered code
mov  r1,#7
pop  {r2-r3}
bx   lr
//

+
mov  r3,#0                   // this will be r0's final default result

ldr  r2,=#0x2013040          // address of start of counter area
ldrb r1,[r2,#3]              // load the pass #
add  r1,#1                   // increment the pass #
ldrb r0,[r2,#2]              // load the total # of passes

cmp  r1,r0                   // is curr_pass > total_passes?, if so, set r0 to 4 to signal the end
ble  +                       // if it's <= total_passes, skip this extra stuff

mov  r3,#4                   // this will be r0 at the end, it signals the code that items are done
mov  r1,#0                   // set the pass # back to 0
strh r1,[r2,#0]              // set the total length back to 0 so the game won't freak out

+
strb r1,[r2,#3]              // store the new pass #
mov  r0,r3                   // give r0 its proper value that the game expects

mov  r1,#7                   // clobbered code
pop  {r2-r3}
bx   lr





//=============================================================================================
// This hack fixes the string used when you try to sell an item at a shop.
//=============================================================================================

.sell_text:
push {r4-r6,lr}
mov  r6,r8
mov  r0,r7
push {r0,r6}
add  sp,#-0x8

mov  r7,#0x26                // starting x position

// Add the sell string to the shitpile
// First get its address
mov  r0,#0x7D                // using entry #0x7D in menus1
bl   $80486A0                // gets the address of the sell string

/// custom mato code!
mov  r8,r0                   // save the address in r0 real quick
ldr  r5,=#0x2014330
ldr  r0,=#0xFFFFFFFF         // clear out our area of RAM we need
mov  r1,r5
ldr  r2,=#0x100
bl   fill_mem

mov  r1,r8                   // copy string to RAM and parse custom CCs
mov  r0,r5
bl   $8048108

mov  r0,r5                   // this is where the string now is
bl   get_string_width
mov  r8,r0                   // store string width in r8
mov  r0,r5                   // give the string address back to r0

// Set the variables/coords and add it to the shitpile
mov  r5,#0x1
neg  r5,r5
mov  r2,#0xF
str  r2,[sp,#0]
mov  r6,#1
str  r6,[sp,#0x4]
mov  r1,r7
mov  r2,#0x87
mov  r3,r5
bl   $8047CDC

// Add the item string to the shitpile
mov  r0,r8                   // pos += width of last string
add  r7,r7,r0

ldr  r4,=#0x201A1FD
ldrb r0,[r4,#0]
mov  r1,#0xC
mov  r2,#0x86
bl   $8046974
ldrb r1,[r4,#0]
mov  r0,#0x2
bl   $8001C5C

push {r0}
bl   get_string_width
mov  r8,r0
pop  {r0}

mov  r4,r0
mov  r1,#0xF
str  r1,[sp,#0x0]
str  r6,[sp,#0x4]
mov  r1,r7
mov  r2,#0x87
mov  r3,#0x16
bl   $8047CDC

mov  r0,r8
add  r1,r7,r0

// Add the question mark to the shitpile
ldr  r0,=#.question_mark     // address of a question mark
mov  r2,#0x87
mov  r3,#1
bl   $8047CDC

// Add yes/no to the shitpile
mov  r0,#0x3
bl   $80486A0
mov  r1,#0xF
str  r1,[sp,#0]
str  r6,[sp,#0x4]
mov  r1,#0x44
mov  r2,#0x93
mov  r3,r5
bl   $8047CDC
mov  r0,#0x4
bl   $80486A0
mov  r2,#0xF
str  r2,[sp,#0]
str  r6,[sp,#0x4]
mov  r1,#0x94
mov  r2,#0x93
mov  r3,r5
bl   $8047CDC

add  sp,#0x8
pop  {r3,r4}
mov  r7,r4
mov  r8,r3
pop  {r4-r6,pc}

.question_mark:
dw $001F

//=============================================================================================
// This hack fixes the string used when you try to buy an item at a shop.
//=============================================================================================

.buy_text:
push {r4-r6,lr}
mov  r6,r8
mov  r0,r7
push {r0,r6}
add  sp,#-0x8

mov  r7,#0x26                // starting x position

// Add the buy string to the shitpile
// First get its address
mov  r0,#0x7C                // using entry #0x7C in menus1
bl   $80486A0                // gets the address of the buy string

/// custom mato code!
mov  r8,r0                   // save the address in r0 real quick
ldr  r5,=#0x2014330
ldr  r0,=#0xFFFFFFFF         // clear out our area of RAM we need
mov  r1,r5
ldr  r2,=#0x100
bl   fill_mem

mov  r1,r8                   // copy string to RAM and parse custom CCs
mov  r0,r5
bl   $8048108

mov  r0,r5                   // this is where the string now is
bl   get_string_width
mov  r8,r0                   // store string width in r8
mov  r0,r5                   // give the string address back to r0

// Set the variables/coords and add it to the shitpile
mov  r5,#0x1
neg  r5,r5
mov  r2,#0xF
str  r2,[sp,#0]
mov  r6,#1
str  r6,[sp,#0x4]
mov  r1,r7
mov  r2,#0x87
mov  r3,r5
bl   $8047CDC

// Add the item string to the shitpile
mov  r0,r8                   // pos += width of last string
add  r7,r7,r0

ldr  r4,=#0x201A1FD
ldrb r0,[r4,#0]
mov  r1,#0xC
mov  r2,#0x86
bl   $8046974
ldrb r1,[r4,#0]
mov  r0,#0x2
bl   $8001C5C

push {r0}
bl   get_string_width
mov  r8,r0
pop  {r0}

mov  r4,r0
mov  r1,#0xF
str  r1,[sp,#0x0]
str  r6,[sp,#0x4]
mov  r1,r7
mov  r2,#0x87
mov  r3,#0x16
bl   $8047CDC

mov  r0,r8
add  r1,r7,r0

// Add the question mark to the shitpile
ldr  r0,=#.question_mark     // address of a question mark
mov  r2,#0x87
mov  r3,#1
bl   $8047CDC

// Add yes/no to the shitpile
mov  r0,#0x3
bl   $80486A0
mov  r1,#0xF
str  r1,[sp,#0]
str  r6,[sp,#0x4]
mov  r1,#0x44
mov  r2,#0x93
mov  r3,r5
bl   $8047CDC
mov  r0,#0x4
bl   $80486A0
mov  r2,#0xF
str  r2,[sp,#0]
str  r6,[sp,#0x4]
mov  r1,#0x94
mov  r2,#0x93
mov  r3,r5
bl   $8047CDC

add  sp,#0x8
pop  {r3,r4}
mov  r7,r4
mov  r8,r3
pop  {r4-r6,pc}

//=============================================================================================
// This hack fixes the string used when you try to drop an item.
//=============================================================================================

.drop_text:
// ----------------------------------------------
// Everything from here to the next comment loads the Menu/Use/Give/Drop sprites, so we skip those
push    {r4-r7,lr}
mov     r6,r8
push    {r6}
add     sp,#-0x8
mov     r0,#0x3C // Menu
bl      $80486A0
mov     r7,#0x1
neg     r7,r7
mov     r6,#0xF
str     r6,[sp,#0]
mov     r4,#0x0
str     r4,[sp,#0x4]
mov     r1,#0x1A
mov     r2,#0x30
mov     r3,r7
bl      $8047CDC
mov     r0,#0x3E // Use
bl      $80486A0
str     r6,[sp,#0]
str     r4,[sp,#0x4]
mov     r1,#0x1A
mov     r2,#0x3C
mov     r3,r7
bl      $8047CDC
mov     r0,#0x3F // Give
bl      $80486A0
str     r6,[sp,#0]
str     r4,[sp,#0x4]
mov     r1,#0x1A
mov     r2,#0x48
mov     r3,r7
bl      $8047CDC
mov     r0,#0x40 // Drop
bl      $80486A0
str     r6,[sp,#0]
str     r4,[sp,#0x4]
mov     r1,#0x1A
mov     r2,#0x54
mov     r3,r7
bl      $8047CDC
// ----------------------------------------------
// Get some value
ldr     r0,=#0x2015D98
ldrb    r0,[r0,#0]
// Dunno what this is for, but it skips the rest of the routine if somevalue << 0x1D is negative
lsl     r0,r0,#0x1D
cmp     r0,#0x0
blt     .drop_text_end
// ----------------------------------------------
// Load the "-- Throw away?" text address
mov     r0,#0x81
bl      $80486A0

/// custom mato code!
mov  r8,r0                   // save the address in r0 real quick
ldr  r5,=#0x2014330
ldr  r0,=#0xFFFFFFFF         // clear out our area of RAM we need
mov  r1,r5
ldr  r2,=#0x100
bl   fill_mem

mov  r1,r8                   // copy string to RAM and parse custom CCs
mov  r0,r5
bl   $8048108

mov  r0,r5                   // this is where the string now is
bl   get_string_width
mov  r8,r0                   // store string width in r8
mov  r0,r5                   // give the string address back to r0

// ----------------------------------------------
// Add the Throw Away text to the shitpile
mov     r5,#1
str     r6,[sp,#0]
str     r5,[sp,#0x4]
mov     r1,#0x26
mov     r8,r1 // store the current X loc to r9
mov     r2,#0x87
mov     r3,r7
mov     r4,r0 // back up the address
bl      $8047CDC
// ----------------------------------------------
// Get the width of the Throw Away string
mov  r0,r4
bl   get_string_width
add  r8,r0 // xloc += width_of_throwaway
// ----------------------------------------------
// Get the item ID
ldr  r4,=#0x201A1FD
ldrb r0,[r4,#0]
// ----------------------------------------------
// Do something mysterious
mov  r1,#0xC
mov  r2,#0x86
bl   $8046974
// ----------------------------------------------
// Gets the item address
ldrb r1,[r4,#0]
mov  r0,#0x2
bl   $8001C5C
mov  r4,r0
//      r0/r4 = address, r3 = max length
// ----------------------------------------------
// Add the item name to the shitpile
str     r6,[sp,#0]
str     r5,[sp,#0x4]
mov     r1,r8
mov     r2,#0x87
mov     r3,#0x16             // max length for normal items
bl      $8047CDC
// ----------------------------------------------
// Get the width of the item name

mov  r0,r4
bl   get_string_width
add  r8,r0 // xloc += width_of_itemname
// ----------------------------------------------
// Add the question mark to the shitpile
str  r6,[sp,#0]
str  r5,[sp,#0x4]
ldr  r0,=#.question_mark
mov  r1,r8
mov  r2,#0x87
mov  r3,#1
bl   $8047CDC
// ----------------------------------------------
// Add Yes and No to the shitpile
mov     r0,#0x3
bl      $80486A0
str     r6,[sp,#0]
str     r5,[sp,#0x4]
mov     r1,#0x44
mov     r2,#0x93
mov     r3,r7
bl      $8047CDC
mov     r0,#0x4
bl      $80486A0
str     r6,[sp,#0]
str     r5,[sp,#0x4]
mov     r1,#0x94
mov     r2,#0x93
mov     r3,r7
bl      $8047CDC
// ----------------------------------------------
.drop_text_end:
add     sp,#0x8
pop     {r3}
mov     r8,r3
pop     {r4-r7}
pop     {r0}
bx      r0

//=============================================================================================
// This hack fixes the string used when you are asked to equip a bought item.
//=============================================================================================

.equip_text:
push    {r4-r6,lr}
mov     r6,r8
push    {r6}
add     sp,#-0x8
// ----------------------------------------------
// Check the mystery value again
ldr     r0,=#0x2015D98
ldrb    r0,[r0,#0]
lsl     r0,r0,#0x1D
cmp     r0,#0x0
bge     +
// ----------------------------------------------
// If it's negative again, use a different string
mov     r0,#0xB9 // [person] equipped the [item]!
bl      $80486A0
mov     r4,r0
mov     r1,#0x1C
mov     r2,#0x87
bl      $8047F28
b       .equip_text_end
+
// ----------------------------------------------
// Load the "-- Equip now?" text address
mov     r0,#0x80
bl      $80486A0

/// custom mato code!
mov  r8,r0                   // save the address in r0 real quick
ldr  r5,=#0x2014330
ldr  r0,=#0xFFFFFFFF         // clear out our area of RAM we need
mov  r1,r5
ldr  r2,=#0x100
bl   fill_mem

mov  r1,r8                   // copy string to RAM and parse custom CCs
mov  r0,r5
bl   $8048108

mov  r0,r5                   // this is where the string now is
bl   get_string_width
mov  r8,r0                   // store string width in r8
mov  r0,r5                   // give the string address back to r0


// ----------------------------------------------
// Add it to the shitpile
mov     r5,#0xF
str     r5,[sp,#0]
mov     r6,#0x1
str     r6,[sp,#0x4]
mov     r1,#0x26
mov     r8,r1
mov     r2,#0x87
mov     r3,#1
neg     r3,r3
mov     r4,r0
bl      $8047CDC
// ----------------------------------------------
// Get the width of the equip text
mov  r0,r4
bl   get_string_width
add  r8,r0
// ----------------------------------------------
// Do the mystery item function
ldr     r4,=#0x201A1FD
ldrb    r0,[r4,#0]
mov     r1,#0xC
mov     r2,#0x86
bl      $8046974
// ----------------------------------------------
// Get the item address
ldrb    r1,[r4,#0]
mov     r0,#0x2
bl      $8001C5C
mov     r4,r0
// ----------------------------------------------
// Add the item name to the shitpile
str     r5,[sp,#0]
str     r6,[sp,#0x4]
mov     r0,r4
mov     r1,r8
mov     r2,#0x87
mov     r3,#0x16
bl      $8047CDC
// ----------------------------------------------
// Get the width of the item name
mov  r0,r4
bl   get_string_width
add  r8,r0
// ----------------------------------------------
// Add " now?" to the shitpile
str  r5,[sp,#0]
str  r6,[sp,#0x4]
ldr  r0,=#.equip_now_text
mov  r1,r8
mov  r2,#0x87
//mov  r3,#5
mov  r3,#1
bl   $8047CDC
// ----------------------------------------------
// Add Yes and No to the shitpile
mov  r4,#1
neg  r4,r4
mov     r0,#0x3
bl      $80486A0
str     r5,[sp,#0]
str     r6,[sp,#0x4]
mov     r1,#0x44
mov     r2,#0x93
mov     r3,r4
bl      $8047CDC
mov     r0,#0x4
bl      $80486A0
str     r5,[sp,#0]
str     r6,[sp,#0x4]
mov     r1,#0x94
mov     r2,#0x93
mov     r3,r4
bl      $8047CDC
// ----------------------------------------------
.equip_text_end:
add     sp,#0x8
pop     {r3}
mov     r8,r3
pop     {r4-r6}
pop     {r0}
bx      r0

.equip_now_text:
dw $001F
//dw $0040,$004E,$004F,$0057,$001F

//=============================================================================================
// This hack fixes the string used when you are asked to sell a currently equipped item after
// buying new equipment.
//=============================================================================================

//print pc
.sell_old_equip_text:
push    {r4-r7,lr}
mov     r7,r9
mov     r6,r8
push    {r6,r7}
add     sp,#-0x8
// ----------------------------------------------
// Get the address of "Sell your "
mov  r0,#0x7F
bl   $80486A0
mov  r4,r0

// ----------------------------------------------
// Add it to the shitpile
mov  r5,#0xF
str  r5,[sp,#0]
mov  r6,#0x1
str  r6,[sp,#0x4]
mov  r1,#0x26
mov  r8,r1
mov  r2,#0x87
mov  r3,#1
neg  r3,r3
bl   $8047CDC
// ----------------------------------------------
// Get the width of "Sell your "
mov  r0,r4
bl   get_string_width
add  r8,r0
// ----------------------------------------------
// Get the item ID, do the mystery function
ldr     r7,=#0x201A1FD
ldrb    r0,[r7,#0]
mov     r1,#0xC
mov     r2,#0x86
bl      $8046974
// ----------------------------------------------
// Get the item address
ldrb    r1,[r7,#0]
mov     r0,#0x2
bl      $8001C5C
// ----------------------------------------------
// Add the item to the shitpile
mov     r4,r0
str     r5,[sp,#0]
str     r6,[sp,#0x4]
mov     r1,r8
mov     r2,#0x87
mov     r3,#0x16
bl      $8047CDC
// ----------------------------------------------
// Get the item width
mov  r0,r4
bl   get_string_width
add  r8,r0
// ----------------------------------------------
// Do some extra crap; don't touch
ldr     r2,=#0x80E5108
ldrb    r1,[r7,#0]
mov     r0,#0x6C
mul     r0,r1
add     r0,r0,r2
ldrh    r1,[r0,#0xA]
ldr     r0,=#0x201A518
strh    r1,[r0,#0]
// ----------------------------------------------
// Get the address of "-- [DPAMT] DP"
mov     r0,#0x7E
bl      $80486A0
// ----------------------------------------------
// Add the DP text to the shitpile
mov     r1,r8
mov     r2,#0x87
bl      $8047F28 // alternate shitpiler
// ----------------------------------------------
// Get the width of the parsed DP text
ldr  r0,=#0x203FFFC
ldr  r0,[r0,#0]
bl   get_string_width
add  r8,r0
// ----------------------------------------------
// Add Yes and No to the shitpile
mov     r0,#0x3
bl      $80486A0
mov     r4,#1
neg     r4,r4
str     r5,[sp,#0]
str     r6,[sp,#0x4]
mov     r1,#0x44
mov     r2,#0x93
mov     r3,r4
bl      $8047CDC
mov     r0,#0x4
bl      $80486A0
str     r5,[sp,#0]
str     r6,[sp,#0x4]
mov     r1,#0x94
mov     r2,#0x93
mov     r3,r4
bl      $8047CDC
// ----------------------------------------------
add     sp,#0x8
pop     {r3,r4}
mov     r8,r3
mov     r9,r4
pop     {r4-r7}
pop     {r0}
bx      r0

//=============================================================================================
// This hack steps into the menu text parser and stores the parsed address to 203FFFC.
//=============================================================================================

.parser_stepin:
ldr  r0,=#0x203FFF8
str  r6,[r0,#0] // Original address
str  r5,[r0,#4] // Parsed address
lsl  r4,r4,#2
add  r4,r9
bx   lr

// This sets the parsed flag for use with 8047CDC
.parser_stepin2:
ldr  r4,=#0x203FFF7
mov  r5,#1
strb r5,[r4,#0]
mov  r5,r0
mov  r4,r1 // clobbered code
bx   lr

// This adds the real address to the table at 203FFA0
.parser_stepin3:
push {r0,r2,r3}
// r0 = counter
// ----------------------------------------------
// Get the target address ready; addr = 203FFA0 + (counter * 4)
ldr  r1,=#0x203FFA0
lsl  r0,r0,#2
add  r1,r1,r0
// ----------------------------------------------
// Check the parsed flag
ldr  r2,=#0x203FFF7
ldrb r0,[r2,#0]
mov  r3,#0
strb r3,[r2,#0]
cmp  r0,#0
bne  +
// Use the address in r5
str  r5,[r1,#0]
b    .parser_stepin3_end
+
// Use the original address from 203FFF8
add  r2,#1
ldr  r0,[r2,#0]
// ----------------------------------------------
// Store it to the table
str  r0,[r1,#0]

.parser_stepin3_end:
pop  {r0,r2,r3}
mov  r1,r0
lsl  r0,r1,#2 // clobbered code
bx   lr

//=============================================================================================
// This hack applies a VWF to item text and other non-sprite text in the main menus.
//=============================================================================================

.item_vwf:
push {r2,r6,lr}

ldr  r6,[r6,#0]
lsl  r6,r6,#0x14
lsr  r0,r6,#0x14             // r0 has the letter now

ldr  r2,=#0x8D1CE78          // r2 now points to the start of 16x16 font's width table
ldrb r0,[r2,r0]              // load r0 with the appropriate width
pop  {r2,r6,pc}

//=============================================================================================
// This hack makes Chapter End (and other stuff?) appear nicely on the file select screens
//=============================================================================================

.chap_end_text:
push {lr}

cmp  r1,#0xCA
bne  +
sub  r0,r0,#2

+
lsl  r0,r0,#0x10
add  r3,r6,r0
asr  r3,r3,#0x10
pop  {pc}

//=============================================================================================
// This hack manually clears the tile layer with non-sprite text on it, since the game
// doesn't seem to want to do it itself all the time. We're basically shoving a bunch of 0s
// into the tilemap.
//
//
// Note that this is buggy so it's not being used now. Fix it later maybe?
//=============================================================================================

.clear_non_sprite_text:
push {lr}

cmp  r4,#0
bne  +

mov  r0,#0
push {r0}
mov  r0,sp
ldr  r1,=#0x6008000
ldr  r2,=#0xA00
//ldr  r2,=#0x1A00

mov  r3,#1
lsl  r3,r3,#24
orr  r2,r3                   // set the 24th bit of r2 so it'll know to fill instead of copy
mov  r3,#1
lsl  r3,r3,#26
orr  r2,r3                   // set the 26th bit so it'll copy by word instead of halfword
swi  #0x0B                   // clear old data out
pop {r0}

+
mov  r0,r5                   // clobbered code
mov  r1,r6
pop  {pc}


//=============================================================================================
// This hack implements a VWF for the battle memory non-sprite text.
//=============================================================================================

.battle_mem_vwf:
push {r5,lr}                 // We're going to use r5, so we need to keep it in 
ldr  r5,[sp,#0x08]           // Load r5 with our former LR value? 
mov  r14,r5                  // Move the former LR value back into LR 
ldr  r5,=#0x804999B          // This is different from the other functions. At the old code from the branch,
                             // there is an unconditional branch after mov r0,#8 to this address.
                             // This is where we want to return to.
str  r5,[sp,#0x08]           // Store it over the previous one 
pop  {r5}                    // Get back r5 
add  sp,#0x04                // Get the un-needed value off the stack 

ldr  r0,=#0x8D1CF78          // load r0 with the address of our 8x8 font width table
ldrb r0,[r0,r1]
pop  {pc}


//=============================================================================================
// This hack will make the game load alternate text than the game would normally expect.
// This affects:
//   - Short enemy names in the Battle Memory screen
//   - Short enemy names used in gray name boxes outside
//   - Fixed item descriptions in battle, with descs that would normally use status icons
//   - Sleep mode message, which had to be done using prewelded text
//=============================================================================================

.load_alternate_text:
push {r5,lr}                 // We're going to use r5, so we need to keep it in 
ldr  r5,[sp,#0x08]           // Load r5 with our former LR value? 
mov  lr,r5                   // Move the former LR value back into LR 
ldr  r5,[sp,#0x04]           // Grab the LR value for THIS function 
str  r5,[sp,#0x08]           // Store it over the previous one 
pop  {r5}                    // Get back r5 
add  sp,#0x04                // Get the un-needed value off the stack 

push {r5-r6}                 // need to use these registers real quick
cmp  r2,#0x07                // if r2 == 7, then we're dealing with enemy names
beq  .short_enemy_name

cmp  r2,#0x00                // in battle, status icons don't get displayed
beq  .status_icon_text       // so we prepare alternate text

cmp  r1,#0x25                // we have to do some magic to make the sleep mode message work
beq  .sleepmode_text

b    .orig_load_code         // so let's just jump to the original code for non-enemy names

//---------------------------------------------------------------------------------------------

.short_enemy_name:
ldr  r5,=#0x80476FB          // load r5 with 0x80476FB, which we'll use to compare the calling address from
ldr  r6,[sp,#0x1C]           // load in the calling address
cmp  r5,r6                   // if equal, this is for the battle memory menu
beq  +

ldr  r5,=#0x8023B1F          // load r5 with 0x8023B1F, which is used for the gray name boxes
cmp  r5,r6
bne  .orig_load_code         // if not equal, jump to the original code

+
ldr  r0,=#0x8D23494          // load the base address of the abbreviated names list
b    .end_load_code

//---------------------------------------------------------------------------------------------

.status_icon_text:
ldr  r5,=#0x8064B89          // see if this is being loaded from battle, if not, do normal code
ldr  r6,[sp,#0x18]
cmp  r5,r6
bne  .orig_load_code

cmp  r4,#0x8B                // if item # < 0x8B or item # > 0x92, use normal code and desc text
blt  .orig_load_code
cmp  r4,#0x92
bgt  .orig_load_code

ldr  r0,=#0x9F8F004          // else use special item descriptions just for this instance
cmp  r1,#4
bne  +
ldr  r0,=#0x9F8F204

+
b    .end_load_code

//---------------------------------------------------------------------------------------------

.sleepmode_text:
ldr  r5,=#0x9AF3790          // just making extra sure we won't trigger this fix on accident
cmp  r0,r5                   // see if r0 directs to the menus3 block
bne  .orig_load_code         // if it doesn't, skip all this and do the original code

ldr  r5,=#0x9FB0300          // start of custom sleep mode text/data

cmp  r6,#0x1F                // if this is the first sleep mode line, redirect pointer
bne  +                       // if this isn't the first sleep mode line, see if it's the 2nd
mov  r0,r5
add  r0,#2                   // r0 now has the address of the first line of custom SM text
b    .special_end_load

+
cmp  r6,#0x20                // see if this is the 2nd line of sleep mode text
bne  .orig_load_code         // if it isn't, we continue the original load routine as usual
ldrh r0,[r5,#0]              // load the offset to the 2nd line
add  r0,r5,r0                // r0 now has the address to the 2nd line
b    .special_end_load

//---------------------------------------------------------------------------------------------

.orig_load_code:
lsl r1,r1,#0x10              // when this whole routine ends, it will go back to 80028A4
lsr r1,r1,#0x0E
add r1,r1,r0
ldr r1,[r1,#0x04]
add r0,r0,r1

.end_load_code:
pop {r5-r6,pc}               // Pop the registers we used off the stack, and return 

//---------------------------------------------------------------------------------------------

.special_end_load:
mov  r5,lr                   // we need to do some return address magic if we're doing
add  r5,#8                   // the sleep mode text fix
mov  lr,r5
pop  {r5-r6,pc}
                         


//=============================================================================================
// These three little hacks move item descriptions in RAM and allow for up to 256 letters,
// though there wouldn't be enough room in the box for that of course :P
//=============================================================================================

.load_desc_address1:
ldr  r0,=#0x2014330
mov  r2,r8
bx   lr

//---------------------------------------------------------------------------------------------

.load_desc_address2:
mov  r0,r4
ldr  r1,=#0x2014330
bx   lr

//---------------------------------------------------------------------------------------------

.load_desc_clear_length:
ldr  r1,=#0x1F8
mov  r2,r8
bx   lr




//=============================================================================================
// These six hacks allow for longer messages in main menus. The max is somewhere around 200
// letters.
//=============================================================================================

.save_menu_msg_address:
add  r5,#2
ldr  r0,=#0x2014310
str  r5,[r0,#0]
pop  {r4-r7}
pop  {r0}
bx   lr

//---------------------------------------------------------------------------------------------

.load_menu_msg_address:
ldr  r0,=#0x2014310
ldr  r5,[r0,#0]
bx   lr

//---------------------------------------------------------------------------------------------

.init_menu_msg_address:
ldr  r0,=#0x201A374
ldr  r7,=#0x2014310
str  r0,[r7,#0]
mov  r7,#0
mov  r0,#1
bx   lr

//---------------------------------------------------------------------------------------------

.change_menu_msg_address1:
push {r2,lr}
ldr  r0,=#0xFFFFFFFF
ldr  r1,=#0x2014330
ldr  r2,=#0x100
bl   fill_mem
mov  r0,r6
pop  {r2,pc}

//---------------------------------------------------------------------------------------------

.change_menu_msg_address2:
mov  r0,r5
ldr  r1,=#0x2014330
bx   lr

//---------------------------------------------------------------------------------------------

.change_menu_msg_clear_amt:
ldr  r1,=#0x201A510
sub  r1,r1,r5
mov  r2,r8
bx   lr


//=============================================================================================
// This hack processes our custom control codes. Since we don't need to bother with enemy
// stuff here, only custom item control codes need to be handled here.
//
// The custom item control codes are [10 EF] through [15 EF].
//
//   [10 EF] - Prints the proper article if it's the first word of a sentence (ie "A/An")
//   [11 EF] - Prints the proper article if it's not the first word of a sentence (ie "a/an")
//   [12 EF] - Prints an uppercase definite article ("The", etc.)
//   [13 EF] - Prints a lowercase definite article ("the", etc.)
//   [14 EF] - Prints this/these/nothing depending on the item
//   [15 EF] - Prints is/are/nothing depending on the item
//
//   [20 EF] - Prints string fragments about the type of equipment the current item is
//
//=============================================================================================

.execute_custom_cc:
push {r0-r3,lr}

ldrb r0,[r4,#1]              // load the high byte of the current letter
cmp  r0,#0xEF                // if it isn't 0xEF, do normal stuff and then leave
beq  +

ldrh r0,[r4,#0]              // load the correct letter again
strh r0,[r5,#0]              // store the letter
add  r4,#2                   // increment the read address
add  r5,#2                   // increment the write address
b    .ecc_end                // leave this subroutine

//---------------------------------------------------------------------------------------------

+
ldrb r0,[r4,#0]              // load the low byte of the current letter, this is our argument
cmp  r0,#0x20                // if this is EF20, go do that code elsewhere
beq  +

mov  r2,#0x10
sub  r2,r0,r2                // r2 = argument - #0x10, this will make it easier to work with

ldr  r0,=#0x201A1FD          // this gets the current item #
ldrb r0,[r0,#0]

mov  r1,#6                   // 6 article entries per letter
mul  r0,r1                   // r3 = item num * 6
ldr  r1,=#0x8D090D9          // this is the base address of our extra item data table in ROM
add  r0,r0,r1                // r0 now has the address of the correct item table
ldrb r0,[r0,r2]              // r0 now has the proper article entry #
mov  r1,#40
mul  r0,r1                   // calculate the offset into custom_text.bin
ldr  r1,=#0x8D0829C          // load r1 with the base address of our custom text array in ROM
add  r0,r0,r1                // r0 now has the address of the string we want

mov  r1,r5                   // r1 now has the address to write to
bl   custom_strcopy          // r0 returns with the # of bytes copied

add  r5,r5,r0                // update the write address
add  r4,#2                   // increment the read address
b    .ecc_end

//---------------------------------------------------------------------------------------------

+                            // all this code here prints the proper "is equipment" message
ldr  r0,=#0x201A1FD          // this gets the current item #
ldrb r0,[r0,#0]
ldr  r1,=#0x80E510C          // start of item data blocks + item_type address
mov  r2,#0x6C                // size of each item data block
mul  r0,r2                   // item_num * 6C
add  r0,r0,r1                // stored at this address is the current item's type
ldrb r0,[r0,#0]              // load the item type
add  r0,#20                  // add 20 -- starting on line 20 of item_extras.txt are the strings we want
mov  r1,#40
mul  r0,r1
ldr  r1,=#0x8D0829C          // this is the base address of our custom text array
add  r0,r0,r1                // r0 now has the correct address

mov  r1,r5
bl   custom_strcopy          // r0 returns the # of bytes copied

add  r5,r5,r0                // update the write address
add  r4,#2                   // increment the read address

//---------------------------------------------------------------------------------------------

.ecc_end:
pop  {r0-r3,pc}


//=============================================================================================
// This hack fixes the main menu string length counting routine so that character names
// don't wind up with extra long names. If the counting routine thought a name was > 8,
// manually make the length = 8.
//=============================================================================================

.counter_fix1:
push {lr}
//mov  r5,#8                   // r5 will be the new value to change to if need be

ldr  r0,[sp,#8]              // load r0 with the base address of the string we just counted
bl   check_name              // check if the name is custom
cmp  r0,#0
beq  +

cmp  r3,r0                   // is the length > r5 (normally 8)?
ble  +                       // if not, continue as normal, else manually make it = r5 (normally 8)
mov  r3,r0

+
mov  r0,r3                   // clobbered code
pop  {r4}
mov  lr,r4
pop  {r4,r5}
bx   lr


//=============================================================================================
// This hack fixes the rare case of the menu message "Fav. Food - XXX has XXX of this item."
// The game always assumes the fav. food's max length is 22, because that's the length of
// normal items.
//=============================================================================================

.counter_fix2:
ldr  r2,=#0x2004F02          // load the address of where the fav. food string is stored
cmp  r4,r2                   // if we're working with the fav. food address, alter the max length
bne  +
mov  r0,#9                   // 9 is the max length for fav. food

+
lsl  r0,r0,#0x10             // clobbered code
lsr  r2,r0,#0x10
bx   lr


//=============================================================================================
// This hack fixes 8-letter names on the main file load screen.
//=============================================================================================

.filechoose_lengthfix:
str  r3,[sp,#0]     // clobbered code
// Address in r0. Return the length in r3.
push {r0,lr}
mov  r3,#9          // default value
bl   check_name     // see if it's a custom name
cmp  r0,#0
beq  +
mov  r3,r0
+
pop  {r0,pc}

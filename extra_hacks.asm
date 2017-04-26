extra_hacks:

// ================================================
// This adds a silver/gold star sprite to the
// Battle Memory screen if you've seen every enemy.
// ================================================

// This is the stream of byte flags to compare against
.allenemies_frontcompare:
  db $FE,$FD,$57,$93,$FF,$FF,$FF,$DF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
  db $DF,$FF,$FD,$FF,$FF,$FC,$CF,$03,$00,$00,$00,$00,$00,$00,$00,$00

// This is the stream of byte flags for back pics
.allenemies_backcompare:
  db $D8,$1C,$06,$82,$F9,$B7,$FF,$DF,$FF,$FF,$FD,$EF,$D9,$FF,$FF,$DF
  db $DF,$BF,$FD,$FF,$F3,$BC,$CF,$03,$00,$00,$00,$00,$00,$00,$00,$00
  
// This routine returns 1 if you have the silver star and 0 if you don't
.allenemies_frontcheck:
push {r1-r5,lr}
ldr  r0,=#.allenemies_frontcompare
ldr  r1,=#0x2004FAA
mov  r4,#0
-
ldrh r2,[r1,#0]
ldrh r3,[r1,#2]
ldrh r5,[r0,#2]
lsl  r3,r3,#0x10
add  r3,r3,r2
lsl  r5,r5,#0x10
ldrh r2,[r0,#0]
add  r2,r2,r5
add  r0,#4
add  r1,#4
add  r4,#1
eor  r3,r2
and  r2,r3
cmp  r2,#0
bne  +
cmp  r4,#8
bne  -
pop  {r1-r5}
mov  r0,#1
pop  {pc}
+
pop  {r1-r5}
mov  r0,#0
pop  {pc}

// This routine returns 1 if you have the gold+silver star and 0 if you don't
.allenemies_backcheck:
push {r1-r5,lr}
bl   .allenemies_frontcheck
cmp  r0,#1
beq  +
pop  {r1-r5,pc}
+
ldr  r0,=#.allenemies_backcompare
ldr  r1,=#0x2004FCA
mov  r4,#0
-
ldrh r2,[r1,#0]
ldrh r3,[r1,#2]
ldrh r5,[r0,#2]
lsl  r3,r3,#0x10
add  r3,r3,r2
lsl  r5,r5,#0x10
ldrh r2,[r0,#0]
add  r2,r2,r5
add  r0,#4
add  r1,#4
add  r4,#1
eor  r3,r2
and  r2,r3
cmp  r2,#0
bne  +
cmp  r4,#8
bne  -
pop  {r1-r5}
mov  r0,#1
pop  {pc}
+
pop  {r1-r5}
mov  r0,#0
pop  {pc}

// This hack checks if your enemy flags match and then displays the star sprite
.allenemies:
push {r5,lr}
ldr  r5,[sp,#8]
mov  lr,r5
ldr  r5,[sp,#4]
str  r5,[sp,#8]
pop  {r5}
add  sp,#4
// ----------------------------------------------
// Check if we're on the Battle Memory screen
push {r0-r5}
ldr  r0,=#0x201A288
ldrb r0,[r0,#0]
cmp  r0,#7
bne  .allenemies_end
// ----------------------------------------------
// Check for front pics
bl   .allenemies_frontcheck
cmp  r0,#0
beq  .allenemies_end
// ----------------------------------------------
// Load the star sprite into tile memory
ldr  r0,=#0x9F86120
ldr  r1,=#0x6016400
mov  r2,#0x20
swi  #0xC
// ----------------------------------------------
// Load the OAM data
ldr  r3,=#0x70003F8
mov  r4,#0x45
lsl  r4,r4,#0x10
add  r4,#0xE
str  r4,[r3,#0]
mov  r4,#0x63
lsl  r4,r4,#8
add  r4,#0x20
str  r4,[r3,#4]
// ----------------------------------------------
// Check for the back pics
bl   .allenemies_backcheck
cmp  r0,#0
beq  .allenemies_end
// ----------------------------------------------
// Load the star sprite into tile memory
ldr  r0,=#0x9F86120
ldr  r1,=#0x6016400
mov  r2,#0x20
swi  #0xC
// ----------------------------------------------
// Load the OAM data
ldr  r3,=#0x70003F0
mov  r4,#0x4F
lsl  r4,r4,#0x10
add  r4,#0xE
str  r4,[r3,#0]
mov  r4,#0xB3
lsl  r4,r4,#8
add  r4,#0x20
str  r4,[r3,#4]
// ----------------------------------------------
.allenemies_end:
pop  {r0-r5}
ldr  r1,=#0xFFFF3A4C
add  r0,r4,r1
ldr  r2,=#0xFFFF3A9C
pop  {pc}






// ---------------------------------------------------------------------------------------
// Intro screen
// (This code is no longer used; to make changes, recompile this and update data_introscreen.bin
// ---------------------------------------------------------------------------------------

//print "Intro screen routine: ",pc
//org $813C5D8
.intro_screen:
push {r0-r4}

// Enable VBlank interrupt crap
ldr  r2,=#0x4000000
mov  r0,#0xB
strh r0,[r2,#4] // LCD control
mov  r1,#2
lsl  r1,r1,#8
ldrh r0,[r2,r1]
mov  r3,#1
orr  r0,r3
strh r0,[r2,r1] // Master interrupt control

// Enable BG0
ldrh r0,[r2,#0]
mov  r1,#1
lsl  r1,r1,#8
orr  r0,r1
strh r1,[r2,#0]

// Set BG0 to 256-color mode; the following screen uses it anyway so we're good
ldrh r0,[r2,#8]
mov  r1,#0x80
orr  r0,r1
strh r0,[r2,#8]

// Tile data
ldr  r0,=#0x9FAC000
ldr  r1,=#0x6008000
swi  #0x12 // LZ77UnCompVram
// ldr  r2,=#0x1FE0
// swi  #0xC

// Map data
ldr  r0,=#0x6000000

// Fill the first row with 0x0000
mov  r1,#0
mov  r2,#0
-
strh r1,[r0,#0]
add  r0,#2
add  r2,#1
cmp  r2,#0x20
bne  -

// Do the middle portion
ldr  r1,=#0x1FE
mov  r2,#0
-
mov  r3,#0x3F
and  r3,r0
cmp  r3,#0x3C
bne  +
add  r0,#4
+
strh r2,[r0,#0]
add  r0,#2
add  r2,#1
cmp  r2,r1
bne  -

// Fill the last two rows with 0x0000
mov  r1,#0
mov  r2,#0
-
strh r1,[r0,#0]
add  r0,#2
add  r2,#1
cmp  r2,#0x40
bne  -

// Palette
ldr  r0,=#0x9FAFE00
mov  r1,#5
lsl  r1,r1,#0x18
mov  r2,#1
lsl  r2,r2,#8
swi  #0xB

// Fade in
ldr  r2,=#0x4000050
mov  r0,#0x81
strh r0,[r2,#0] // Set blending mode to whiteness for BG0
mov  r4,#0x10
-
strh r4,[r2,#4]
swi  #5
swi  #5 // 15 loops with 2 intrs each gives a total fade-in time of 0.5 seconds
sub  r4,#1
bpl  -

// Conditional delay for ~2 seconds
// 0x78 VBlankIntrWaits is 2 seconds
// 2005128 == 1 for save slot 1's existence, 200518C for slot 2
ldr  r0,=#0x2005128
ldrb r2,[r0,#0]
add  r0,#0x64
ldrb r1,[r0,#0]
add  r1,r1,r2
cmp  r1,#0
bne  +
mov  r4,#0x78
-
swi  #5
sub  r4,#1
cmp  r4,#0
bne  -
+

// Wait for any button press
ldr  r2,=#0x4000130
ldr  r4,=#0x3FF
-
swi  #5 // VBlankIntrWait
ldrh r0,[r2,#0]
cmp  r0,r4
beq  -

// Fade out
ldr  r2,=#0x4000050
mov  r0,#0x81
strh r0,[r2,#0] // Set blending mode to whiteness for BG0
mov  r4,#0x0
-
strh r4,[r2,#4]
swi  #5
swi  #5 // 15 loops with 2 intrs each gives a total fade-out time of 0.5 seconds
add  r4,#1
cmp  r4,#0x10
bls  -

// Clear the palette
mov  r0,#1
neg  r0,r0
push {r0}
mov  r0,sp
mov  r1,#5
lsl  r1,r1,#0x18
mov  r2,#1
lsl  r2,r2,#24
add  r2,#0x80
swi  #0xC
add  sp,#4

// ----------------------
pop  {r0-r4}

.intro_screen_end:
push {lr}
bl   $805AD24
pop  {pc}



// ---------------------------------------------------------------------------------------
// Changes the "Some sort of beat" item (0x90) icon to the bell
// This particular hack lets it use a custom palette
// ---------------------------------------------------------------------------------------

.bellringer:
// New version replaces the whole GetItemPaletteAddress routine
// Item number is in r0, both out-of-battle and in-battle
// Return the address in r2
push {lr}
cmp  r0,#0x90
beq  +
// ---------- Existing routine
lsl  r0,r0,#0x10
mov  r1,#0xB4
lsl  r1,r1,#0x12
add  r0,r0,r1
lsr  r0,r0,#0x10
bl   $8036D18
mov  r4,r0
mov  r0,#0
bl   $8036DDC
ldrb r1,[r4,#1]
lsl  r1,r1,#0x1C
lsr  r1,r1,#0x17
add  r0,r0,r1
pop  {pc}
+
// ---------- Custom routine
ldr  r0,=#0x9FABFE0
pop  {pc}

// Output r1 with the palette address
// Item ID in r7
//cmp  r7,#0x90
//bne  +
//ldr  r0,=#0x9FABFE0
//b    .bellringer_end
//+
//lsr  r1,r1,#0x17
//add  r0,r0,r1
//.bellringer_end:
//bx   lr

// ---------------------------------------------------------------------------------------
// Makes the Memo screen stretch vertically correctly.
// ---------------------------------------------------------------------------------------

.memo_stretch:
push {r0-r4,lr}
// ----------------------------------------------
// Fill 30040F0 with 1C8 00's
mov  r0,#0
push {r0}
mov  r0,sp
ldr  r1,=#0x30040F0
mov  r2,#1
lsl  r2,r2,#24 // Fill
mov  r3,#0xE4
orr  r2,r3
swi  #0xB
add  sp,#4
// ----------------------------------------------
pop  {r0-r4}
mov  r2,#0 // clobbered code
mov  r0,#5
pop  {pc}

// ---------------------------------------------------------------------------------------
// Fixes the string counter in the Memo screen. Possibly fixes things elsewhere.
// ---------------------------------------------------------------------------------------

.memo_counterfix1:
// Return length in r0
push {r0,r5,lr}
mov  r0,r4
bl   check_name
cmp  r0,#0
beq  +

add  sp,#4
pop  {r5,pc}

+
pop  {r0,r5}
mov  r1,r0                   // original code
lsl  r1,r1,#0x10
lsr  r1,r1,#0x10
ldr  r0,=#0x8D1EE78
bl   $800289C
ldrh r0,[r0,#0]
pop  {pc}

// ---------------------------------------------------------------------------------------
// Another string counter fixer. Fixes the [44 FF] code in particular.
// ---------------------------------------------------------------------------------------

.memo_counterfix2:
push {r0,lr}

// Address in r1, length in r2
mov  r0,r1
bl   check_name
cmp  r0,#0
beq  +
mov  r2,r0
+
lsl  r2,r2,#0x10             // clobbered code
lsr  r5,r2,#0x10
pop  {r0,pc}

// ---------------------------------------------------------------------------------------
// Fixes status icons in the memo screen.
// ---------------------------------------------------------------------------------------

.memo_iconfix:
push {lr}
// r0 is 3 for icons, 1 for everything else
cmp  r0,#3
bne  +
mov  r0,#0x18      // start 0x18 pixels from the left; it does weird things when inside text though
strh r0,[r6,#0]
pop  {pc}
+
lsl  r1,r0,#1
add  r1,r1,r0
lsl  r1,r1,#2
strh r1,[r6,#0]
pop  {pc}

// ---------------------------------------------------------------------------------------
// These hacks are for activating the Memo screen.
// ---------------------------------------------------------------------------------------

.memo_check:
push {r0,lr}
ldr  r0,=#0x4000130
ldrh r0,[r0,#0]
lsl  r0,r0,#0x16
lsr  r0,r0,#0x1E // r0 = (r0 & 0x300) >> 8
cmp  r0,#0       // we're checking for at least L+R, so other buttons are irrelevant
pop  {r0}
beq  +
bl   $804BF34 // Status
pop  {pc}
+
bl   $804BFCC // Memo
pop  {pc}

// ---------------------------------------------------------------------------------------
// This hack fixes the scrolly sprite flashing by enabling the OBJ layer indefinitely
// whenever a scrolly line is being executed.
// ---------------------------------------------------------------------------------------

.scrolly_sprite_fix:
push {r2,lr}
ldrh r1,[r4,#8]
mov  r0,#0xFF
and  r0,r1

// Check for scrolly text
ldr  r2,=#0x203FFF8
ldrh r1,[r2,#0]
cmp  r1,#0
bne  + // ignore if not block 0
ldrh r1,[r2,#2]

cmp  r1,#7
beq  .scrolly_do_fix

cmp  r1,#8
beq  .scrolly_do_fix

cmp  r1,#9
beq  .scrolly_do_fix

cmp  r1,#10
beq  .scrolly_do_fix

cmp  r1,#11
beq  .scrolly_do_fix

cmp  r1,#12
beq  .scrolly_do_fix

cmp  r1,#13
beq  .scrolly_do_fix

cmp  r1,#15
beq  .scrolly_do_fix

cmp  r1,#16
beq  .scrolly_do_fix

// Add other lines here if necessary

b    +

.scrolly_do_fix:
mov  r1,#0x80
lsl  r1,r1,#0x5
orr  r0,r1

+
ldrh r1,[r4,#8]
strh r0,[r4,#8]
pop  {r2,pc}

// ---------------------------------------------------------------------------------------
// This hack updates the 203FFF8 RAM area with the block # and line # so that the
// above fix doesn't constantly enable the OBJ layer when it shouldn't be.
// ---------------------------------------------------------------------------------------

// r6 >> 1 == block number
// r7 == line number

.scrolly_sprite_fix2:
push {r0,lr}
ldr  r0,=#0x203FFF8
lsr  r6,r6,#1
strh r6,[r0,#0]
strh r7,[r0,#2]
lsl  r6,r6,#1
pop  {r0}
bl   $800289C     // clobbered code
pop  {pc}


// ---------------------------------------------------------------------------------------
// This hack stretches the left column of text vertically in the Battle Memory menu.
// ---------------------------------------------------------------------------------------

.battlemem_stretch:
push {r0-r4,lr}
// ----------------------------------------------
// Fill 30040F0 with 1C8 00's
mov  r0,#0
push {r0}
mov  r0,sp
ldr  r1,=#0x30040F0
mov  r2,#1
lsl  r2,r2,#24 // Fill
mov  r3,#0xE4
orr  r2,r3
swi  #0xB
add  sp,#4
// ----------------------------------------------
pop  {r0-r4}
add  r0,r0,r1     // clobbered code
ldr  r0,[r0,#0]
pop  {pc}


// ---------------------------------------------------------------------------------------
// This hack moves the Key goods cursor left by one pixel in the left column.
// ---------------------------------------------------------------------------------------

.keygoods_cursorfix1:
and  r0,r1       // clobbered code
mov  r2,#0xFF    // r2 was originally 0, so to move it left we need to make it -1, or 0xFFFF (signed hword)
lsl  r2,r2,#0x8
add  r2,#0xFF
bx   lr

// ---------------------------------------------------------------------------------------
// PSI menu
.psi_cursorfix1:
and  r0,r1       // clobbered code
mov  r2,#0xFF    // we want -3
lsl  r2,r2,#0x8
add  r2,#0xFD
bx   lr

// ---------------------------------------------------------------------------------------
// Skills (other) menu
.skills_cursorfix1:
and  r0,r1       // clobbered code
mov  r2,#0xFF    // we want -5
lsl  r2,r2,#0x8
add  r2,#0xFB
bx   lr


//---------------------------------------------------------------------------------------
// double's an enemy's HP at battle start if hard mode is enabled
//---------------------------------------------------------------------------------------

.double_hp1:
push {r4,lr}
push {r0}
bl   .is_hardmode         // see if hard mode is enabled
mov  r4,r0
pop  {r0}
cmp  r4,#0                // if not, skip the math junk
beq  +

lsl  r0,r0,#1             // double the hp

+
str  r0,[r1,#0]
mov  r1,#0x98
pop  {r4,pc}

//------------------------------------------

.double_hp2:
push {r0,lr}

ldr  r1,[r1,#0x14]
bl   .is_hardmode
cmp  r0,#0
beq  +

lsl  r1,r1,#1             // double the hp

+
ldr  r2,[r2,#4]
pop  {r0,pc}


//---------------------------------------------------------------------------------------
// quadruples the enemy's speed at the start of battle if hard mode is enabled
//---------------------------------------------------------------------------------------

.quadruple_speed:
push {r0,lr}

ldrb r1,[r2,#0x1F]  // load normal speed
bl   .is_hardmode   // see if this is hard mode
cmp  r0,#0          // if it isn't, skip the extra math
beq  +

lsl  r1,r1,#2       // quadruple the enemy's speed
mov  r2,#0xFF
cmp  r1,r2
blt  +

mov  r1,#0xFF       // make the speed FF if the doubled value would be too high otherwise

+
ldr  r2,[r3,#4]
pop  {r0,pc}


//---------------------------------------------------------------------------------------
// returns 0 in r0 if the player name isn't "HARD MODE". Returns non-zero if it is.
//---------------------------------------------------------------------------------------

.is_hardmode:
push {r1-r4}
mov  r0,#0                 // return value is FALSE by default
ldr  r3,=#0x2004F26        // player's name in memory is here
ldr  r4,=#hardmodestring   // string to compare against

ldrh r1,[r3,#0]            // compare "HA"
ldrh r2,[r3,#2]
lsl  r2,r2,#16
orr  r1,r2
ldr  r2,[r4,#0]
cmp  r1,r2
bne  +

add  r3,#4                 // compare "RD"
add  r4,#4
ldrh r1,[r3,#0]
ldrh r2,[r3,#2]
lsl  r2,r2,#16
orr  r1,r2
ldr  r2,[r4,#0]
cmp  r1,r2
bne  +

add  r3,#4                 // compare " M"
add  r4,#4
ldrh r1,[r3,#0]
ldrh r2,[r3,#2]
lsl  r2,r2,#16
orr  r1,r2
ldr  r2,[r4,#0]
cmp  r1,r2
bne  +

add  r3,#4                 // compare "OD"
add  r4,#4
ldrh r1,[r3,#0]
ldrh r2,[r3,#2]
lsl  r2,r2,#16
orr  r1,r2
ldr  r2,[r4,#0]
cmp  r1,r2
bne  +

add  r3,#4                 // compare "E[END]"
add  r4,#4
ldrh r1,[r3,#0]
ldrh r2,[r3,#2]
lsl  r2,r2,#16
orr  r1,r2
ldr  r2,[r4,#0]
cmp  r1,r2
bne  +

mov  r0,#1                 // if we made it this far, the strings are equal

+
pop  {r1-r4}
bx   lr


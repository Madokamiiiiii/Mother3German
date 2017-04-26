naming_screen_hacks:

// ==============================================
// These hacks align the bullets correctly
// on the naming screens.
// ==============================================

.bullets1:
cmp  r4,#0
bne  +
mov  r1,#4
add  r1,r8
bx   lr
+
mov  r1,#3
add  r1,r1,r2
bx   lr

.bullets2:
ldr  r1,=#0x8D1CF78
add  r3,#1
lsl  r3,r3,#1
sub  r2,r2,r3
-
ldrh r3,[r2,#0]
add  r2,#2
cmp  r3,#0xFF
bgt  +
ldrb r3,[r1,r3]
add  r7,r7,r3
b    -
+
sub  r1,r7,#1
bx   lr


// ==============================================
// These hacks make the factory screen load the
// sanctuary name.
// ==============================================

.factload1:

mov  r1,#0x00
//orr  r0,r1  // no longer needed

// Check the naming screen type
ldr  r4,=#0x201AA58
ldrb r4,[r4,#0]
cmp  r4,#0xE
bne  +
ldr  r1,=#0x2004F26
-
ldrb r4,[r1,#0]
add  r1,r1,#2
cmp  r4,#0xFF
beq  +
add  r0,r0,#1
b    -
+
bx   lr

.factload2:
// Check the naming screen type
ldr  r4,=#0x201AA58
ldrb r4,[r4,#0]
cmp  r4,#0xE
bne  .factload2_end
ldr  r3,=#0x2004F26
mov  r4,#0
-
ldrb r6,[r3,#0]
add  r3,r3,#2
cmp  r6,#0xFF
beq  +
strh r6,[r5,r4]
add  r4,r4,#2
b    -
+
lsr  r4,r4,#1
//ldrb r6,[r7,#0]
//add  r6,r6,r4
//strb r6,[r7,#0]
strb r4,[r7,#0]
.factload2_end:
pop  {r3-r5}
mov  r8,r3
bx   lr


// ==============================================
// These hacks display the player name properly
// in the staff credits.
// ==============================================

// This one loads the correct upper letter tile
.credits1:
push {r5,lr}
ldr  r5,[sp,#8]
mov  lr,r5
ldr  r5,[sp,#4]
str  r5,[sp,#8]
pop  {r5}
add  sp,#4
//
ldr  r1,=#0x9F86140
lsl  r0,r0,#1
ldrh r1,[r1,r0]
pop  {pc}

// This one loads the correct lower letter tile
.credits2:
push {r5,lr}
ldr  r5,[sp,#8]
mov  lr,r5
ldr  r5,[sp,#4]
str  r5,[sp,#8]
pop  {r5}
add  sp,#4
//
ldr  r1,=#0x9F86140
lsl  r2,r5,#1
ldrh r1,[r1,r2]
add  r1,#0x20
pop  {pc}

// This one makes it read from the correct address
.credits3:
push {r5,lr}
ldr  r5,[sp,#8]
mov  lr,r5
ldr  r5,[sp,#4]
str  r5,[sp,#8]
pop  {r5}
add  sp,#4
//
mov  r1,#0x1B
lsl  r1,r1,#6
add  r1,r1,#6
add  r2,r1,r0
pop  {pc}


//=====================================================================================
// This function completely fixes up the cursor coord crap on naming screens.
//=====================================================================================

.cursor_lookup_tables:
incbin data_namingcursors.bin

.cursor_megafix:
push {r3-r7,lr}

// ---------------------------------------
// Get the current value
ldrb r7,[r0,#0]            // r7 = current cursor value
// ---------------------------------------
// Get the layout type
ldr  r6,=#0x201AA58
ldrb r6,[r6,#0]
cmp  r6,#0xD
beq  +
cmp  r6,#0xE
beq  +
mov  r6,#0
b    .cursor_megafix_jump1
+
mov  r6,#1
.cursor_megafix_jump1:     // r6 = layout type (0 = normal, 1 = sans dont care)
// ---------------------------------------
// Get the arrow direction
ldrh r5,[r1,#2]
mov  r4,#0xF0
and  r5,r4
cmp  r5,#0
beq  .cursorfix_end        // Return only if no arrow keys are pressed whatsoever
lsr  r5,r5,#5              // {10, 20, 40, 80} is now {0, 1, 2, 4}
cmp  r5,#4
blt  +
mov  r5,#3                 // {0, 1, 2, 4} is now {0, 1, 2, 3}
+                          // r5 = arrow direction (0 = right, 1 = left, 2 = up, 3 = down)
// ---------------------------------------
// Play the sound effect
push {r0-r3}
lsr  r0,r5,#1              // r3 = 0 for right,left; 1 for up,down
mov  r2,#1
eor  r0,r2                 // r3 = 1 for right,left; 0 for up,down
add  r0,#0xD0
bl   $800399C
pop  {r0-r3}
// ---------------------------------------
// Get table address
mov  r3,#0x69
ldr  r4,=#.cursor_lookup_tables
mul  r6,r3
lsl  r6,r6,#2              // r6 *= 0x1A4
mul  r5,r3                 // r5 *= 0x69
add  r4,r4,r5
add  r4,r4,r6
// ---------------------------------------
// Load the new value and store it
ldrb r4,[r4,r7]
// If r4 == #0xFF, something went wrong, let jeffmeister know
strb r4,[r0,#0]
// ---------------------------------------
// Finished
.cursorfix_end:
pop  {r3-r7,pc}
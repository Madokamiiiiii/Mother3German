arch gba.thumb


//============================================================================================
//                                          TEST HACKS
//============================================================================================

// make menu text blue
//org $80C5FFF; db $7C

// EZ Flash sleep fix
org $800188E; db $40
org $80018A9; db $C3


//============================================================================================
//                                       CAST ROLL HACKS
//============================================================================================

// Relocate to 203FC00
org $8025184; dd $0203FC00
// Cast: called from 250CB
// Non-cast: never called

//org $8024870; dd $0203FC00
// Cast: called once from 1C1F5
// Non-cast: called from 7929
org $802484E; bl credits_hacks.address_check1; nop

org $8024624; dd $00029BD8
// Cast: called from 2334D, 233A3
// Non-cast: never called

// Expand from 12 letters to 21 (20 + custom control bytes)
org $8025172; add r0,#0x32
org $802518E; add r2,#0x36
//org $80251A0; mov r1,#0xD8
//org $80251B8; add r3,#0x32
//org $80251C8; mov r1,#0x36
org $80250E0; add r6,#0x32
org $80250EC; strh r0,[r5,#0x30]
org $8025106; mov r1,#0x2A
//org $8025140; mov r2,#0x28 // included in .name_fix
//org $8025148; add r1,#0x2C // included in .preweld1
org $8024594; bl credits_hacks.range_fix1
org $80245B8; bl credits_hacks.range_fix2
org $80245E0; bl credits_hacks.range_fix3; nop
org $80245F2; bl credits_hacks.range_fix3; nop
org $80245E6; ldrh r0,[r4,#0x2C]
org $80245EA; strh r0,[r4,#0x2C]
org $80245FE; add r4,#0x36
org $8024600; add r5,#0x36

// Fix player names
org $802511C; b $8025142
//org $8025148; mov r0,r4; bl get_string_width; nop
org $802513E; bl credits_hacks.name_fix; bl credits_hacks.preweld1; b $802515A

// Disable Saturn text
org $8025138; nop

//============================================================================================
//                                  SPRITE TEXT WELDING HACKS
//============================================================================================

org $80487DA; bl sprite_text_weld.main_routine  // link to new sprite routine
org $80492D0; bl $8000000                       // break old sprite routine on purpose

// make sprite text be spaced out by 16 pixels
org $8049CB4; db $10         
org $8049CEE; db $10

org $80496A4; bl sprite_text_weld.get_icon_coord; nop
org $80496D6; db 1
org $803EA6C; bl sprite_text_weld.fix_sprite_total
org $80497B2; bl text_weld   // these are used by the sprite text routine to fill the glyph structs
org $80497C2; bl text_weld
org $804981A; bl text_weld   // these are used by the 8x8 sprite text routine
org $804982A; bl text_weld
org $803E170; bl sprite_text_weld.set_fadeout_flag
org $803E24C; bl sprite_text_weld.clear_table

//============================================================================================
//                                   MAIN MENU HACKS
//============================================================================================

// Modifies GetAddressOfGlyphBitmap for main menu item descriptions
org $8049916; mov r0,#0x20
org $804991E; b $8049944

// makes main menu box titles and item descriptions print all 16 rows instead of 10
org $804974E
  mov  r4,r0                 // r4 now has the font address/glyph base
  mov  r3,#0                 // get the loop started

  -
  mov  r0,sp                 // r0 is base of glyph1
  add  r2,r0,r3              // get glyph1[count * 2]
  lsl  r0,r3,#1
  add  r0,r0,r4
  ldrb r1,[r0,#0x0]
  strb r1,[r2,#0x0]          // store that value at r2
  ldrb r1,[r0,#0x1]          // get glyph1[count * 2 + 1] (what about r4?)
  strb r1,[r2,#0x8]          // store in glyph2[

  add  r2,sp,#0x18           // we can't use r5 in this code, so I did this instead
  add  r2,r2,r3

  ldrb r1,[r0,#0x10]
  strb r1,[r2,#0x00]
  ldrb r1,[r0,#0x11]
  strb r1,[r2,#0x08]

  add  r3,r3,#1              // loop back if <= 7
  cmp  r3,#7
  bls  -

  mov  r4,r2                 // copy r2 into r4, so things will work after this hack
  sub  r4,#7                 // gotta subtract the count to make it match what
                             // the original program expects
  b $80497A4                 // and skip over old unneeded code

// makes items print all rows
org $8048FFE
  mov  r4,r0                 // r4 now has the font address/glyph base
  mov  r3,#0                 // get the loop started
  add  r5,sp,#0x18

  -
  mov  r0,sp                 // r0 is base of glyph1
  add  r2,r0,r3              // get glyph1[count * 2]
  lsl  r0,r3,#0x01
  add  r0,r0,r4
  ldrb r1,[r0,#0]
  strb r1,[r2,#0]            // store that value at r2

  ldrb r1,[r0,#0x01]         // get glyph1[count * 2 + 1] (what about r4?)
  strb r1,[r2,#0x08]         // store in glyph2[

  add  r2,r5,r3
  ldrb r1,[r0,#0x10]
  strb r1,[r2,#0x00]
  ldrb r1,[r0,#0x11]
  strb r1,[r2,#0x08]

  add  r3,r3,#1              // loop back if need be
  cmp  r3,#7
  bls  -

  b    $8049074

// applies a VWF to item names and other non-sprite text in the main menus
org $8049996; bl main_menu_hacks.item_vwf

// Fix map name alignment on file select screen
org $8044B6C; mov r0,#0x89; nop
org $8044B94; mov r1,#0x89
org $8044974; db $89
org $804497E; db $19
org $8044980; bl main_menu_hacks.chap_end_text; nop
org $8044C4E; db $D0
org $8044BB8; db $0B

// Fix map name string-overwriting bug
org $8044C1C; add r0,r0,r5

// Allow map names to be 50 letters total
org $8044BC0
  mov r0,#100
  mul r0,r7
  nop

// Centers "No Data" on the file select menus
org $804276A; db $67
org $80427AE; db $67

// make the text speed menu box one tile bigger and move the text over a few pixels
org $80C67C8; db $5E
org $80C67CC; db $40

// Re-center various main menu labels. Note that some rare labels may be missing still.
org $8040456; db $BF         // Goods
org $8040902; db $BF
org $8040A82; db $B6        // Equip
org $804121E; db $C1
org $8043016; db $C1
org $8040C26; db $C5         // PSI
org $80410AE; db $BE         // Status
org $804167E; db $A0         // Battle Memory
org $8041886; db $C2         // Shop
org $8041990; db $C2
org $8041D00; db $C2
org $804181A; db $C2
org $8041F36; db $B9         // Item Dude
org $80420AC; db $B9
org $8042348; db $B9
org $8041FA2; db $B9

// centers Press the A Button for skill info thing
org $80445B4; db $32

// centers the "------" in various main menu screens
org $80407CE; db $6C
org $80405EE; db $6C
org $8040936; db $6C
org $8040F02; db $6C
org $804113A; db $6C
org $8040B42; db $6C
org $804212A; db $6C
org $8042498; db $6C
org $8041506; db $6C
org $80413F0; db $6C
org $8040FCE; db $6C

// move stuff in the sub menus to the right 2 pixels
// NOTE! There's still a TON of other variations of this that
// need to be repositioned, blech :(
// menu/use/give/drop
org $8045E1A; db $1A
org $8045E3A; db $1A
org $8045E4E; db $1A
org $8045E62; db $1A
// when in Use submenu
org $8045EC2; db $1A
org $8045ED6; db $1A
org $8045EEA; db $1A
org $8045EFE; db $1A
// when in Give submenu
org $8045FB0; db $1A
org $8045FCE; db $1A
org $8045FE2; db $1A
org $8045FF6; db $1A
// when in Drop submenu
org $80460E6; db $1A
org $80460FA; db $1A
org $804610E; db $1A
org $8046122; db $1A
// ‘On whom’ X coord
org $8045F12; db $5A
org $8045F56; db $5A
// ‘To whom’ X coord
org $8046042; db $5A
// Lucas & Boney
org $8046084; db $5A
// Give/Drop in another submenu
org $8046012; db $1A
org $8046026; db $1A

// makes the game use "On whom" for the Use and PSI submenus
org $8045F08; db $3B
org $80461E4; db $3B

// Shop menu realignments
// Move the upper cursor left by four pixels in main shop menu
org $804184C; db $00
// Move the character cursor left by four pixels in the Buy/Sell shop submenus
org $80418BA; db $00
// Move the upper cursor left by four pixels in the Buy/Sell shop submenus
org $80418DE; db $00
// Move the cursors left in Buy submenu
org $8041BE2; db $00
org $8041C0A; db $00
// Move the cursors left in Sell submenu
org $8041E98; db $00
org $8041EC0; db $00
// Move the cursors left when inventory is full
org $8041A6a; db $00
org $8041A92; db $00
// 'Buy' X coord when in main shop menu
org $80446FE; db $12
// 'Sell' X coord when in main shop menu
org $8044712; db $12
// 'End' X coord when in main shop menu
org $8044726; db $12
// Character names X coord when in Buy/Sell shop submenus
org $8044774; db $12
// Item dude realignments
// Fix the cursor alignment
org $8041F68; db $00
org $8041FD6; db $00
org $8041FFA; db $00
// 'Deposit' X coord when in main item dude menu
org $80447BA; db $12
// 'Withdraw' X coord when in main item dude menu
org $80447CE; db $12
// 'End' X coord when in main item dude menu
org $80447E2; db $12
// Character names X coord when in Deposit/Withdraw item dude submenus
org $8044830; db $12 

// apply a VWF to the non-sprite text on the Battle Memory screen
org $8049966; push {lr}; bl main_menu_hacks.battle_mem_vwf

// moves battle memory text to the left a little bit
org $8041744; db $77

// make the game load abbreviated names on the battle memory menu, fixed item descs in battle
org $800289C; push {lr}; bl main_menu_hacks.load_alternate_text; nop; nop

// makes numbers print correctly inside the main menus
org $8049CC4; db $10

// allow for extra-long item descriptions instead of just 42 letters or whatever
org $8047E64; bl main_menu_hacks.load_desc_address1
org $8047E78; bl main_menu_hacks.load_desc_address2
org $8047E70; bl main_menu_hacks.load_desc_clear_length

// replaces the sell item text routine
org $80463F8
  push {lr}
  bl main_menu_hacks.sell_text
  pop  {pc}

// replaces the buy item text routine
org $804626C
  push {lr}
  bl main_menu_hacks.buy_text
  pop {pc}
  
// replaces the drop item text routine
org $80460C8
  push {lr}
  bl main_menu_hacks.drop_text
  pop {pc}
  
// replaces the equip bought item text routine
org $804631C
  push {lr}
  bl main_menu_hacks.equip_text
  pop {pc}

// replaces the sell old equipped item text routine
org $8046510
  push {lr}
  bl main_menu_hacks.sell_old_equip_text
  pop {pc}
// Fix the Yes/No cursor coords in the sell old equipment text
org $8045A50; db $CC
  
// Step into the menu text alternate shitpiler to record the parsed text address
org $8047F96; bl main_menu_hacks.parser_stepin

// Another parser step in
 org $804810A; bl main_menu_hacks.parser_stepin2

// Final address thinger
org $8047D14; bl main_menu_hacks.parser_stepin3

// fix main menu message issues, allow for 200+ letters per message instead of 16
org $8047F42; bl main_menu_hacks.init_menu_msg_address
org $8047F80; bl main_menu_hacks.load_menu_msg_address
org $8048150; bl main_menu_hacks.save_menu_msg_address
org $8047F64; bl main_menu_hacks.change_menu_msg_address1
org $8047F8E; bl main_menu_hacks.change_menu_msg_address2
org $8047F86; bl main_menu_hacks.change_menu_msg_clear_amt
org $8047F78; nop
org $8048144; bl main_menu_hacks.execute_custom_cc; nop

// move some menu messages to the left to allow for more space
org $8044E72; db $08
org $8044EF2; db $08
org $80453C6; db $08
org $8044572; db $08
org $8045564; db $08
org $8041A36; db $08
org $80445EE; db $08

// make character names only go 8 letters in shop menus instead of 9
org $8044776; db $08

// fix the string-counting routine so that character names don't go over 8 letters
org $8048798; bl main_menu_hacks.counter_fix1
// fix a menu message routine so the game will think fav. food is max 9 letters instead of 22
org $8048462; bl main_menu_hacks.counter_fix2

// Make character names only go 8 letters on the main file load screen (and possibly elsewhere)
org $8047A4C; bl main_menu_hacks.filechoose_lengthfix;

// Stretch out the battle memory names list
org $80446B0; bl extra_hacks.battlemem_stretch
org $8041778; mov r2,#3 // move the cursor left one pixel
org $804175E; lsl r3,r0,#0x14; nop; nop // stretch cursor coords vertically

// Make the battle memory list use the large font
org $8048F88; b $8048FB4

// This clears out non sprite text fully since the game doesn't always
// Note that this is kind of buggy so mess with it later maybe sometime
//org $803EC5A; bl main_menu_hacks.clear_non_sprite_text;

// Other cursor coord fixes. Gives everything a consistent one pixel of space minimum
// between the edge of the cursor and the edge of the text.
// These change the position of the cursor, not the text, as most of these are
// non sprite-text and thus much harder to move.
org $804155A; db $01                             // Memo, X, left column
org $8041560; db $79                             // Memo, X, right column
org $8040624; db $03                             // Goods, X, left column
org $804062A; db $7B                             // Goods, X, right column
org $804081C; bl extra_hacks.keygoods_cursorfix1 // Key goods, X, left column
org $8040824; db $77                             // Key goods, X, right column
org $8040B04; db $7F                             // Equip, X, main menu
org $8043064; db $7F                             // Equip, X, sub menu
org $8040F24; bl extra_hacks.psi_cursorfix1      // PSI, X, left column
org $8040F2C; db $69                             // PSI, X, right column
org $8045ACE; db $07                             // PSI, X, 'On whom' submenu
org $804141E; bl extra_hacks.psi_cursorfix1      // Skills (PSI), X, left column
org $8041426; db $69                             // Skills (PSI), X, right column
org $8041460; bl extra_hacks.skills_cursorfix1   // Skills (other), X, left column
org $8041468; db $73                             // Skills (other), X, right column

org $807A8DA; db $08    // fix Hinawa's name in final battle

//============================================================================================
//                                  NAMING SCREEN HACKS
//============================================================================================

org $804594E; bl naming_screen_hacks.bullets1
org $8045912; b $804591C
org $804591C; bl naming_screen_hacks.bullets2
org $804C652; bl naming_screen_hacks.factload1
org $804C674; bl naming_screen_hacks.factload2
org $8059220; push {lr}; bl naming_screen_hacks.credits1
org $8059246; push {lr}; bl naming_screen_hacks.credits2
org $80591EC; push {lr}; bl naming_screen_hacks.credits3

// Insert new letter selection screen
org $9BA2DBC; incbin gfx_namingscreen.bin

// Insert new coordinate tables
org $9B8FF74; incbin data_namingscreen1.bin
org $80C6AAC; incbin data_namingscreen2.bin

// Make the incorrect tile on the text speed/window flavour screen go away
org $9BC04AA; db $97

// Fully covers/erases "Don't Care" on the player naming screens
org $804A3C4; db $06

// Fix the coordinate table stuff
org $8053E6C; db $64
org $8053E78; db $64
//org $8053DFC; db $67
org $804DD00; db $67
org $804F544; db $74
org $804F548; db $74
org $804F54C; db $2C,$F6
org $804F550; db $2C,$F6
org $804F554; db $2C,$F6
org $804F558; db $2C,$F6
org $804F55C; db $2C,$F6
org $804F56C; db $32,$F6
//org $8053D1C; db $09
//org $8053D8C; db $09

// Disable L and R alphabet switching
 org $803E79F; db $E0

// Enable L and R alphabet switching on the factory screen
//org $804DD16; db $0E // L
//org $804DD60; db $0E // R

// Cycle through two alphabets instead of three (all screens)
//org $804DD34; db $20 // L
//org $804DD76; db $20 // R

// Alter namable characters' name lengths
org $80C69D4; db $08
org $80C69E0; db $08
org $80C69EC; db $08
org $80C69F8; db $08
org $80C6A04; db $08
org $80C6A10; db $09
org $80C6A1C; db $08
org $80C6A4C; db $08
org $80C6A58; db $08
org $80C6A64; db $08

// Alter sanctuary/factory name lengths
org $80C6A70; db $10
org $80C6A7C; db $10

// Fix fav. food alignment on naming summary screen
org $8042E12; db $94,$21

// Fix fav. thing alignment on naming summary screen
org $8042E58; db $94,$24

// Fix text speed alignment on naming summary screen
org $8042EA8; db $94

// reposition text on the main naming screens to look better
org $8042924; db $78
org $804297A; db $78
org $804297C; db $1B
org $8045D0E; db $26       // Invalid/duplicate name

// Super sanctuary factory combination power
org $8042902; db $68
org $8042912; db $68
org $8042934; db $78
org $804C634; db $10
org $804C63E; db $10
org $8045902; db $10
org $8055BB8; db $10
org $804DCB2; db $10

// Change the sanctuary screen arrangement to match the factory screen one
org $804A0F8; db $48
org $9BBB7BC; incbin gfx_factory_arrangement.bin

// Change the sanctuary graphics to include the custom window border tiles
org $9BB69FC; incbin gfx_sanctuaryborders.bin
org $9BB89FC; incbin gfx_sanctuaryborders.bin
org $9BAD5BC; incbin gfx_namingscreen.bin

// Make the factory screen write its name to 2004F26
org $8055BD8; dd $2004F26

// New credits tileset
org $9C5FE60; dd $00326614
org $9C8D24E; db $00,$00,$00,$00,$00,$00
org $9F86140; incbin data_creditstable.bin
org $9F86340; incbin font_creditsfont_[c].bin

// This fixes something with the naming screens
org $80428FE
  cmp r0,#0xD
  blt $8042924

// Treat the factory screen’s cursor-moving as the sanctuary screen’s
//org $8053C6C; b $8053C70

// Naming screen coordinate fixes
org $8053C34
push {lr}
bl   naming_screen_hacks.cursor_megafix
pop  {pc}

// fixes sanctuary name length weirdness
org $804C9D2; db $10

//============================================================================================
//                                  ITEM LENGTH HACKS
//============================================================================================

org $80488C2; bl main_menu_hacks.write_item_text
org $803E9FC; bl main_menu_hacks.clear_data
org $80489CE; bl main_menu_hacks.write_item_eos
org $8048D2C; bl main_menu_hacks.check_for_eos
org $8048DC6; bl main_menu_hacks.get_ram_address2
org $8048EBA; bl main_menu_hacks.clear_swap_flag
org $80492B2; bl main_menu_hacks.check_special_bit
org $8048932; bl main_menu_hacks.store_total_letters; nop
org $8048C78; bl main_menu_hacks.write_group_lengths
org $80487FE; bl main_menu_hacks.load_curr_group_length1; nop; nop; nop; nop; nop
org $8048D0A; bl main_menu_hacks.load_curr_group_length2
org $803E996; bl main_menu_hacks.group_add_check

// these changes make the game load all 22 letters of items names in various menus
org $8046F7C; db $16       // Goods screen
org $8046F92; db $16
org $8046FC2; db $16
org $804704C; db $16       // Key Goods screen
org $8047062; db $16
org $8047092; db $16
org $8047AF0; db $16       // Equip screen
org $8047102; db $16
org $8047310; db $16       // Status screen
org $8047512; db $16       // Skills screen
org $8047528; db $16
org $80474F0; db $16
org $804758E; db $16
org $80474A2; db $16       // PSI screen
org $80474B8; db $16
org $8047572; db $16
org $8047238; db $16
org $8047262; db $16
org $80472AE; db $16
org $80477A0; db $16       // Shop screens
org $8047810; db $16
org $80478A4; db $16       // Item storage screens
org $80478BA; db $16
org $8047972; db $16
org $8047988; db $16
org $80479C2; db $16
org $80478EA; db $16

//============================================================================================
//                                  MAIN SCRIPT HACKS
//============================================================================================

// modifies GetAddressofGlyphBitmap()
org $8009D9E; mov r0,#0x20
org $8009DA6; b $8009DCC

// modifies the VCount handler to move text up
org $80055FE; cmp r0,#0x7F
org $8005602; cmp r0,#0x7F
org $8005622; mov r0,#0x7F
org $8005638; add r0,#0xC

// modifies Create10x10GlyphForCharacter for main dialog font
org $8008C96
  ldrb r0,[r1,#0x1]
  strb r0,[r2,#0x8]
  add  r2,r7,r3
  ldrb r0,[r1,#0x10]
  strb r0,[r2,#0x0]
  ldrb r0,[r1,#0x11]
  strb r0,[r2,#0x8]
  nop
  add  r3,r3,#1
org $8008CAC; b $8008CC0

// modifies the width calculation routines
org $8009DEA
  mov  r0,#0x3
  and  r0,r2
  cmp  r0,#0
  beq  $8009E08
org $8002260
  nop
  b    $8002284
  nop
  nop
org $8002284                 // calculate the width
  cmp  r1,#0xFF              // Jeff credits hack: if r1 > 0xFF, use fullwidth of 16
  bls  +
  mov  r0,#16
  b    $800239e
  
  +
  ldr  r3,=#0x8D1CE78        // r3 has the main width table
  mov  r0,#0x02              // if the second bit of r2 is set, we're doing the 8x8 font
  and  r0,r2                 // and should update the address for the 8x8 width table
  cmp  r0,#0x02 
  bne  +

  add  r3,#0x80              // add 0x100 to get 8D1CF78, our 8x8 width table
  add  r3,#0x80              // add 0x100 to get 08D1CF78, our 8x8 width table

  +
  lsl  r1,r1,#0x18
  lsr  r1,r1,#0x18           // make r1 into a byte
  ldrb r0,[r3,r1]            // load the width
  b    $800239e              // return to our regularly scheduled programming

// makes numbers print correctly in the main script
org $800A108; db $10

// byuu's 8-bit script conversion + Jeff's menu stuff + Mato's custom control code stuff
org $8021B18; bl main_script_hacks.script_convert

// Modify the main script auto-line wrap counter. CHANGING THIS CAUSES MAJOR PROBLEMS!
org $800A100; db $FF

// Jeff's [BREAK]-overwrite bug fix
org $8009C54
  mov  r2,#0xFF
  mul  r2,r1
  nop
org $8008EDC; db $FF
org $8008EEC; db $FF
org $8009C70
  mov  r2,#0xFF
  mul  r2,r1
  nop

// fixes the Japanese Greek letters
org $8CDB8B4; dw $003B,$003C,$003D,$003E
// Fix the display of PK [FAVTHING] and related issues
org $8001CAA
  mov  r0,#0xEA
  strh r0,[r4,#0]
  add  r0,r2,#2
  b    $8001CB4
org $8001CD6
  strh r0,[r1,#2]
org $8001CF2
  bl   main_script_hacks.pk_fav_fix
  mov  r0,r4
  b    $8001D22
  
// implement custom item control codes in the main script
org $802A9B8; bl main_script_hacks.current_item_save1
org $801BA7E; bl main_script_hacks.current_item_save2

// Paul's chapter end/Block 0 8-bit text conversion stuff
org $8027F68; bl main_script_hacks.chapter_end_convert

// Fixes the strange Hinawa->Thomas, Flint->Reconstructed Caribou bug
// See the thread "Programming IV" for details if interested
org $80230FA; nop

// change scrolly text text limit to 50 letters per line
org $80223D0; db $32

// move all scrolling text to the left a tiny bit
org $80207FE; db $02

// Scrolly text sprite flashing fix
org $80060F6; bl extra_hacks.scrolly_sprite_fix; b $8006100
org $8027F8A; bl extra_hacks.scrolly_sprite_fix2

// fixes text speed issues, allows infinite # of glyphs
org $80088CA; bl main_script_hacks.insert_extra_letter1
org $80229C4; bl main_script_hacks.insert_extra_letter2
org $8008B56; bl main_script_hacks.move_to_next_glyph; nop

// changes the letter per line limit from 22 to 255
org $8008A0A; lsl r2,r2,#4
org $8006B6A; lsl r4,r4,#4
org $8008B66; lsl r2,r2,#4
org $8008BB2; lsl r0,r0,#4
org $8006C30; dw $0D8A
org $800A09A; bl main_script_hacks.change_clear_amount
org $8008A22
  mov r1,#0xC8
  add r6,r2,r1
  nop

// fixes the flyover text, only 50 letters per line allowed
org $80098F0; bl main_script_hacks.flyover_fix1
org $800959A; bl main_script_hacks.flyover_fix2

// fixes Block 0 display stuff, mostly with the Bug Memory and Pig Notebook
org $8009730; bl main_script_hacks.block0_text_fix2

// make Block 0 cut scenes work properly
org $80244F8; dd $02014340       // block 0 text will be handled here
org $8024FE2; bl main_script_hacks.blockzero_address
org $80244E0; db $68             // set the size (in bytes) of each block of text per line
org $8024502; db $6C             // let the game know how far apart the blocks are (with header)
org $8022382; db $68             // let the game know how many letters to clear before writing
org $8024FF0; db $68             // let the game know how many letters to clear
org $8024FFC; db $68             // let the game know where end of current block is
org $802500A; db $6C             // let game know how far apart each block is

// make the [CENTER] codes allow for longer text with Block 0 stuff
org $8021BE6; add sp,#-0x64
org $8021DB2; add sp,#0x64
org $8021C0A; db $64
org $8021CC6; db $64

// make Block 0 scrolly text not repeat and act weird after 11 lines
org $8024548; dd $02014340
org $8024520; db $68
org $802453C; db $6C

// make the Block 0 key items work properly
// there are still various limitations to the text, but this
// makes it work
org $802507A; bl main_script_hacks.blockzero_address
org $8025088; db $68
org $8025094; db $68
org $80250A2; db $6C

// Make [PLAYERNAME] display all 16 characters in dialogue
 org $8022000; db $10

// Fix [42 FF F0 FF] display gitch
org $8021FD0; mov r2,#8

// Fix [FAVFOOD]
org $8021FFE; bl main_script_hacks.favfood_fix

// Fix standard character display; located code that seems to use a length
// of 6, this changes it to 8, don't know if it's ever used or how
org $8021FCA; db $08

// make debug room menus pad the text with 3Fs instead of ACs for test purposes
org $80226FC; dw $00EB,$00EB

// set a special flag when 4+ menu option line is being processed
org $802269C; bl main_script_hacks.set_specialmenuflag


//============================================================================================
//                                  MISC OUTSIDE HACKS
//============================================================================================

// re-center various menu labels using these new x-coordinates
org $80C20E8; db $B1         // Goods
org $80C20EA; db $B1         // Equip
org $80C20EC; db $B1         // PSI
org $80C20EE; db $B1        // Status
org $80C20F0; db $B1         // Sleep

// centers all the Sleep Mode confirm text better
//org $8038578; db $55
//org $803858C; db $91
//org $80C20D8; db $43
//org $80C20DC; db $7F

// move the names in outside nameboxes up 1 pixel to look nicer
org $8038B1A; add r2,r5,#3

// centers names in the outside nameboxes
org $8038AF0; bl outside_hacks.center_names; nop

// adds custom stuff to string counting routines, allows nameable names to be longer
org $8022F6C
  push {lr}
  bl   outside_hacks.string_length_count
  pop  {pc}

// Modifies the routine that loads the 16x16 font data for outside menu box labels
org $80092D6
  ldrb r0,[r1,#0x1]
  strb r0,[r2,#0x8]
  add  r2,r5,r3
  ldrb r0,[r1,#0x10]
  strb r0,[r2,#0]
  ldrb r0,[r1,#0x11]
  strb r0,[r2,#0x8]
  nop
  add  r3,r3,#1
org $80092EC
  b    $8009300

// moves gray name box text up one pixel
org $8023576; db $71
org $8023DDE; db $FB
org $8023D32; db $03
org $8023AFE; db $FB
org $8023A76; db $03
org $8023C5E; db $FB
org $8023E42; db $FB
org $8023C2A; db $FB
org $8023B98; db $03

// makes the gray name boxes fit the names better
org $8023A10; bl outside_hacks.gray_box_resize
org $8023B32; bl outside_hacks.gray_box_resize
org $8023CCC; bl outside_hacks.gray_box_resize

//============================================================================================
//                              SOUND PLAYER & BATTLE HACKS
//============================================================================================

// modifies GetAddressofGlyphBitmap for sound player and battle text
org $8088E80; bl battle_hacks.get_glyph_address; b $8088E90

// loads 11 rows of the 16x16 font instead of 10, affects sound player and battle text
// It's important that only 11 rows be loaded instead of the full 16
org $808949C; mov r0,#0xB; nop

// this hack lets the game clear out 11 rows of a font letter when erasing stuff
org $8089156; mov r0,#0xB; nop

// This fixes the problem where names and other stuff would get cut off by long descriptions
org $806EBB6; bl battle_hacks.get_number_of_tiles_to_clear

// Makes various battle menu text use a VWF
org $806EB9E; bl battle_hacks.menu_vwf

// Implements the little hack we did where battle text pointers need to be multiplied by 2
org $8088DF8; push {lr}; bl battle_hacks.text_pointer_fix

// this centers some sound player text and also parses custom control codes in battle
org $8088E00; push {lr}; bl battle_hacks.prepare_custom_cc; nop
org $806EA4E
  ldr  r0,=#0x2014300
  ldrh r0,[r0,#0]
  b    $806EA62

// make numbers print correctly in battle
org $806E20C; db $10

// moves battle namebox names up 1 pixel to look better
org $807CD5E; db $0D

// apply a VWF to the main battle text, pretty complicated stuff
org $80840D2; nop; push {lr}; bl battle_hacks.main_vwf1
org $808418E; push {lr}; bl battle_hacks.main_vwf2
org $8083FE2; push {lr}; bl battle_hacks.clear_battle_window
org $80841C6; mov r0,#0             // always be on line 0
org $80841DC; mov r0,#0             // always be on char 0
org $80841DE; nop; nop              // always be on the same letter
org $80841EE; nop                   // make the game stay on char 0
org $80841F6; b $8084200            // make the game not insert lines breaks every few letters
org $8083EA4                        // changes the text's vertical spacing from 12 pixels to 11
  mov r1,#0xB
  mul r1,r2 
org $8084340; mov r0,#0              // makes [WAIT] codes work as they should in battle
org $806EB1A; nop                   // make the battle text erase correctly

// final battle vwf
org $8085592; db $00          // always stay on line 0
org $808559C; nop; b $80855AC // disable line scrolling-up stuff
org $80855BA; db $00          // always stay on letter 0
org $808545C; push {lr}; bl battle_hacks.finalbattle_vwf1
org $8085514; push {lr}; bl battle_hacks.finalbattle_vwf2
org $808557A; bl battle_hacks.finalbattle_vwf_clear_window

// 3-line battle VWF
org $8085AFA; db $00          // always stay on line 0
org $8085B04; nop; b $8085B14 // disable line scrolling-up stuff
org $8085B22; db $00          // always stay on letter 0
org $8085A06; push {lr}; bl battle_hacks.3line_vwf1
org $8085ABE; push {lr}; bl battle_hacks.3line_vwf2
org $8085AEA; bl battle_hacks.3line_vwf_clear_window

// throw away items battle VWF
org $8084848; push {lr}; bl battle_hacks.toomany_vwf1
org $8084A84; push {lr}; bl battle_hacks.toomany_vwf2
org $8084AEE; db $00          // always stay on line 0
org $8084B2A; db $00          // always stay on character 0
org $8084B32; nop; b $8084B46 // get rid of scrolling-up stuff
org $808495E; mov r0,r1; nop
org $8084AD2; push {lr}; bl battle_hacks.toomany_vwf_clear_window


// re-center char names on HP boxes in battle
org $807D2D8;
  push {lr};
  bl   battle_hacks.center_name;
  nop
  nop
  nop
org $807D31E
  mov  r7,r9
  ldrb r2,[r7,#2]
  add  r2,#0x20
  mov  r1,r2
  nop

// these hacks save/clear data for the custom CC hacks
org $807A746; bl battle_hacks.clear_current_enemy  // clears current enemy #, fixes "The Flint"
org $80809FC; bl battle_hacks.save_current_enemy   // saves current enemy #, needs improvement
org $8062C26; bl battle_hacks.save_total_enemies   // saves total # of enemies
org $8064984; bl battle_hacks.save_current_item    // saves current item #

// this code actually executes the custom control codes
org $806E464; push {lr}; bl battle_hacks.execute_custom_cc; b $806E47A

org $8064998; bl battle_hacks.favfood_9letters

// re-arrange the item-stealing text in-battle
org $80B1B02; bl battle_hacks.item_steal_text; b $80B1B84
org $80B3F66; bl battle_hacks.item_steal_text2; b $80B3FE8

//============================================================================================
//                                    GRAPHICS HACKS
//============================================================================================
 
// Insert new 16x16 font + cast roll pre-welded font
//org $8CE39F8; fill $8192,$0
org $8CE39F8; incbin font_mainfont.bin
org $8CE59F8; incbin font_castroll.bin

// Insert new 8x8 font
org $8D0B010; incbin font_smallfont.bin

// insert ATM graphics
org $9AFD8D0; incbin gfx_frogatm.bin

// insert pencil sprite graphics
org $98BBCD0; incbin gfx_pencil_sprites.bin

// insert nostalgia room statue graphics and new palette
org $8F09C94; incbin gfx_statues_[c].bin
org $8F7C4BC; incbin gfx_statues_pal.bin

// Insert new chapter title screen graphics
org $9AF3844; dd $0049C870
org $9F90000; incbin gfx_chaptertitles_trans[c].bin
org $9B03580; incbin gfx_chapt1-4_arrangement.bin
org $9B05580; incbin gfx_chapt5-8_arrangement.bin

// Insert the special graphics for the start of Chapter 4
org $98AA8D0; incbin gfx_3yearslater.bin

// Insert YOU WON! graphics to replace YOU WIN!
org $9C98A28; incbin gfx_youwon_transfixed.bin

// Insert text speed/window flavor graphics
org $9BA141C; incbin gfx_flavours.bin


// LIMITATION: if using commands, the text is too long
// For use with base rom.
// Insert new Health Screen graphics
//org $9C8F332; db $E8 // Move the flashy text up by 8 pixels
//org $9C8F338; db $E8
//org $9C8F33E; db $E8
//org $9C8F344; db $E8
//org $9C8F34A; db $E8
//org $9C8F350; db $E8
//org $9C8F356; db $E8
//org $9C8DEB4; incbin gfx_healthscreen_[c].bin
//org $9C8DEA8; dd $9F87A20-$9C8DE98
//org $9F87A20; incbin gfx_healthtext_[c].bin

// For use with premade rom
org $9C8EEBE; db $E8 // Move the flashy text up by 8 pixels
org $9C8EEC4; db $E8
org $9C8EECA; db $E8
org $9C8EED0; db $E8
org $9C8EED6; db $E8
org $9C8EEDC; db $E8



// insert new "LAB" graphics to replace "LABO"
org $8F0E670; incbin gfx_lab1_[c].bin
org $8F0E9E0; incbin gfx_lab2_[c].bin

// Translation for Goods > Give screen and save
//org $9B90140; incbin gfx_offdef_[c].bin

org $9FD44A0; incbin gfx_offdef_[c].bin
org $9B8FFC4; dd $9FD44A0-$9B8FFC0

// Change MONOTOLY to MONOTOLI in the theater
org $8D3E09C; dd $01256B20
org $9F92000; incbin gfx_monotoli_[c].bin

// silver star sprite for the battle memory star hack
org $9F86120; incbin gfx_starsprite.bin

//Bonus-Grafik
org $8D50A00; incbin gfx_trans_keep_out_[c].bin
org $9B9D808; incbin gfx_battle_[c].bin
org $8E2B95C; incbin gfx_check1_[c].bin
org $8E2BB1C; incbin gfx_check2_[c].bin
org $8DB555C; incbin gfx_debugroom_[c].bin
org $9C926C8; incbin gfx_hit.bin
org $9B9D564; incbin gfx_up_down_[c].bin

org $9AF6480; incbin gfx_kp_pp.bin
org $9C9B108; incbin gfx_battle_kp_pp.bin
org $8F15360; incbin gfx_amusement_[c].bin

org $8E2539C; incbin gfx_charge1_[c].bin
org $8D3CD4C; dd $9DD9F70-$8D3B4E0
org $9DD9F70; incbin gfx_charge2_[c].bin
org $8D3D928; dd $9DD9E54-$8D3B4E0
org $9DD9E54; incbin gfx_charge3_[c].bin

// Unused
org $8E3E9F4; incbin gfx_sheriffoffice1_[c].bin

org $8DD5D60; incbin gfx_sheriffoffice2_[c].bin
org $8D3C134; dd $9CFEFA8-$8D3B4E0
org $9CFEFA8; incbin gfx_sheriffoffice3_[c].bin

org $8D3DDB0; dd $9F87D5C-$8D3B4E0
org $9F87D5C; incbin gfx_welcome_[c].bin


//TEST
//org $9C5F340; dd $0F56CDA
//org $9C5F340; incbin testg.bin
//============================================================================================
//                                    SOUND HACKS
//============================================================================================

incsrc sound_hacks.asm

// makes sound player song #1 play "look-over-there"
//org $80ECD4E; dw $0451

//============================================================================================
//                                     DATA FILES
//============================================================================================

// Insert new font width table
org $8D1CE78; incbin font_mainwidths.bin

// insert 8x8 font width table
org $8D1CF78; incbin font_smallwidths.bin

// insert translated item names
org $8D1EE84; dd $0126D588
org $9F8C400; incbin text_itemnames.bin

// insert translated NPC/speaker names
org $8D1EE90; dd $00FE4F6E
org $9D03DE6; incbin text_charnames.bin

// insert translated enemy names
org $8D1EE98; dd $00FE0F28
org $9CFFDA0; incbin text_enemynames.bin

// insert the abbreviated enemy names
org $8D23494; incbin text_enemynames_short.bin

// insert music titles
org $8086CF4; dd $08CFB3F8
org $9C8F38C; dd $08CFB3F8
org $8CFB3F8; incbin text_musicnames.bin

// inserts misc. sound player menu text
org $9C926A0; dd $FF06D298
org $8CFDBF8; incbin text_miscmenus.bin

// insert PSI names
org $8D1EE9C; dd $0000A1D8
org $8D29050; incbin text_psinames.bin

// insert special text (includes special skill names)
org $8D1EEB0; dd $00FE84D6
org $9D0734E; incbin text_specialtext.bin

// insert default names
org $8D2C708; incbin text_defaultnames.bin

// insert party character names
org $8D28F30; incbin text_pcharnames.bin

// insert skill descriptions
org $8D1EEB4; dd $FFFDEF80
org $8D1EEB8; dd $FFFDEFE4
org $8CFDDF8; incbin text_skilldescriptions.bin

// insert PSI descriptions
org $8D1EEA0; dd $FFFDAB40
org $8D1EEA4; dd $FFFDAC08
org $8CF99B8; incbin text_psidescriptions.bin

// insert item descriptions
org $8D1EE88; dd $FFFDF430
org $8D1EE8C; dd $FFFDF630
org $8CFE2A8; incbin text_itemdescriptions.bin

// insert special item descriptions (for descs with status icons in battle)
org $9F8F004; incbin text_special_itemdescriptions.bin

// insert battle text
org $9C92698; dd $0031FAA0
org $9FB0400; incbin text_battletext.bin

// insert special text used by custom control codes
org $8D0829C; incbin text_custom_text.bin

// insert a custom enemy data table, used by our custom control codes
org $8D08A6C; incbin data_enemy_extras.bin

// insert a custom item data table, used by our custom control codes
org $8D090D9; incbin data_item_extras.bin

// insert menu text
org $9B90124; dd $FF175818
org $9B90128; dd $FF175A58
org $8D057D8; incbin text_menus1.bin

// insert menus2.txt (mostly seems to be debug stuff/stuff that got cut out)
org $8D0BA10; incbin text_menus2.bin
org $9B9012C; dd $FF17BA50
org $9B90130; dd $FF17BB9A

// insert menus3.txt (outside menu box titles and debug stuff mostly)
org $9AF3824; dd $FF214758
org $9AF3828; dd $FF2147AE
org $8D07EE8; incbin text_menus3.bin

// inserts status-related text
org $8D1EEA8; dd $00FE7E52
org $9D06CCA; incbin text_statuses.bin

// inserts enemy description text
org $1B90134; dd $00032686
org $1B90138; dd $00032886
org $9BC2644; incbin text_enemydescriptions.bin

// inserts map names
org $8D1EEBE; incbin text_mapnames.bin

// insert main text DUN DUN DUN
org $936A6F4; incbin text_mainscript.bin

// relocate the big sound clip to the end of the ROM, freeing up hack space for us
org $8119C64; dd $9F92600
org $811B734; dd $9F92600
org $811F6DC; dd $9F92600
org $811FA90; dd $9F92600
org $812030C; dd $9F92600
org $9F92600; incbin sound_relocate_dump.bin

// Data table for cast roll hack
org $9FB0000; incbin data_castroll_table.bin

// tiny table/data for the sleep mode text
org $9FB0300; incbin text_sleep.bin

// was planning to make an alternate sound player someday, but decided not to for now
//org $8138000; incbin alt_sound_table.bin
//org $8086CF0; dd $8138000
//org $8086D64; dd $8138000


//============================================================================================
//                                  NEW, EXTRA GOODIES
//============================================================================================

// Big cool battle memory star sprite hack
org $803E6FC; push {lr}; bl extra_hacks.allenemies

// New icon for bell ringer item
org $8036E90; push {r4,lr}; bl extra_hacks.bellringer; pop {r4,pc}
//org $8036EAC; bl extra_hacks.bellringer
org $993DE30; incbin gfx_bellicon.bin
org $9FABFE0; incbin gfx_bellicon_pal.bin

// intro screen
org $805AD14; bl introhackcode // bl extra_hacks.intro_screen // 
//org $9FAC000; incbin gfx_disclaimer_[c].bin
//org $9FAFE00; incbin gfx_disclaimer_pal.bin
//TEST INTRO SCREEN
org $9FAC000; incbin gfx_disclaimer_[c].bin
org $9FAFE00; incbin gfx_disclaimer_pal.bin

// enables hard mode when player name is "HARD MODE"
org $8080A9A; bl extra_hacks.double_hp1
org $8080B90; bl extra_hacks.double_hp2
org $8080BA8; bl extra_hacks.double_hp2
org $8080C5A; bl extra_hacks.quadruple_speed

// string used to compare against when enabling hard mode ("HARD MODE")
org $813C700
hardmodestring:
dw $0028,$0021,$0032,$0024,$0040,$002D,$002F,$0024,$0025,$FFFF

// Binfile copy of the intro screen hack
org $813C5D8
introhackcode:
incbin data_introcode.bin

// fixes a bug in the original game - makes the Dr. A empty trash can print the right line
// and it fixes the Murasaki hot spring sign
org $91F9109; db $17
org $9121834; db $0C
org $91F911D; db $16

// Fixes Duster attack sound bug in the original game
org $809C8F0; bl battle_hacks.duster_fix

// Fixes the Chauffeur bug
// In case you can't get it to occur, it happens if you start playing from froggie save 7Y (first slot).
org $9284CEA; db $04

// Fixes the "wrong map displays in the wrong place" bug
org $80C4148; db $00 // Theater projector room
org $80C4178; db $00 // Upstairs hallway (outside Leder's room)
org $80C4184; db $00 // Leder's room  

//============================================================================================
//                                  MEMO SCREEN STUFF
//============================================================================================

// Enable memo menu; hold Sel+L+R while loading the Status menu
org $804BE16; bl extra_hacks.memo_check

// Memo name counter fixes
org $8001DB0; push {lr}; bl extra_hacks.memo_counterfix1; pop {pc}
org $8048500; bl extra_hacks.memo_counterfix2

// Expand memo text
org $804BFD4; bl extra_hacks.memo_stretch

// Make status icons appear "correctly" in memo screen
org $8049298; bl extra_hacks.memo_iconfix; nop; nop

// Make the pigmask not set the null memo flag
//org $9369245; db $00

// Fix the memo lookup table so it's not offset by -1
org $80C7004; incbin data_memo_flags.bin



//============================================================================================
//                                    NEW FIXES
//============================================================================================
// makes it so names occupy less obj tiles
org $8009070; bl outside_hacks.different_oam_size
org $800912C; bl outside_hacks.different_tiles_storage; nop; nop; nop; nop; nop; nop; nop
org $80091B8; bl outside_hacks.different_tiles_add
org $80091C2; bl outside_hacks.different_tiles_print

// Custom sob block for generic battle sprites for hit and miss and total damage
define sob_battle_sprites $9F8A5F8
org {sob_battle_sprites}; incbin misc_battle_sob.bin
org $9C91DE8; dd {sob_battle_sprites}-$9C90960; dd $904

// Realign HITS graphic
org $8065658; db $40



//============================================================================================
//                                    NEW HACK CODE
//============================================================================================

// Clear out data for our hacks first
org $8124C18
fill $179C0

// Now insert the hack code
org $8124C18
incsrc general_hacks.asm
incsrc main_script_hacks.asm
incsrc main_menu_hacks.asm
incsrc sprite_text_hacks.asm
incsrc naming_screen_hacks.asm
incsrc outside_hacks.asm
incsrc extra_hacks.asm
incsrc battle_hacks.asm
incsrc credits_hacks.asm

// Insert disclaimer graphics
//disclaimer_graphics:
//incbin gfx_disclaimer.bin

//disclaimer_palette:
//incbin gfx_disclaimer_pal.bin



print "End of Current Hacks: ",pc
print "Max:                  0x813C743"

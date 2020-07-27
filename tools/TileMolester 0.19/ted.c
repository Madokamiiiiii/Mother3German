/*

8ted - tile editor

Copyright 2001-2008 Damian Yerrick

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
IN THE SOFTWARE.

*/

/* Unicode warning

This file must not be saved with Windows XP Notepad.
Instead, it must  be saved as "UTF-8 without BOM" in Notepad++
or "UTF-8 No Mark" in Programmer's Notepad. Otherwise, you'll
get errors about stray \239, \187, and \191 in program because
GCC doesn't know how to handle UTF-8 byte order marks.

*/


#include <allegro.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include <ctype.h>



#ifndef PATH_MAX
#define PATH_MAX 256
#endif


#define MAX_CHRDOCS 8  /* not infinite, but better than tlayer's 2 */

#define TILEAREA_LEFT 32
#define TILEAREA_TOP 64

#define CLIPBOARD_LEFT 192
#define CLIPBOARD_TOP 64
#define CLIPBOARD_WIDTH 256
#define CLIPBOARD_HEIGHT 128

#define CURTILE_LEFT 184
#define CURTILE_TOP 224
#define CURTILE_MAGNIFY 12
#define PALETTE_LEFT 288
#define PALETTE_TOP 208
#define PALETTE_MAGNIFY 7
#define PALED_LEFT 416
#define PALED_TOP 240

#define REPORT_MEMORY_LEAKS 0


typedef unsigned long u32;

typedef enum TileType
{
  TILE_PC, TILE_NES, TILE_GB, TILE_VB, TILE_NGPC,
  TILE_SNES, TILE_SNES3, TILE_PACKED,
  TILE_SMS, TILE_MD, TILE_GBA4,
  TILE_NTYPES
} TileType;

typedef struct TileTypeAssoc
{
  char ext[12];
  TileType system;
} TileTypeAssoc;

const char tile_offsets[TILE_NTYPES] =
{ 8, 16, 16, 16, 16,
  32, 24, 64,
  32, 32, 32 };

const char tile_palmask[TILE_NTYPES] =
{ 0xfe, 0xfc, 0xfc, 0xfc, 0xfc,
  0xf0, 0xf8, 0x00,
  0xf0, 0xf0, 0xf0 };

const char *tiletype_names[TILE_NTYPES] =
{
  "1-bit (PC)", "NES", "Game Boy", "Virtual Boy", "Neo-Geo PokeClr",
  "SNES Mode 1", "SNES 3-bit", "Packed (Mode 7)",
  "Master System", "Genesis", "GBA 4-bit"
};

PALETTE pal;

const TileTypeAssoc tile_assocs[] =
{
  { "bin", TILE_MD },   /* Genesis games often end in .bin */
  { "fnt", TILE_PC },   /* VGA fonts on the PC */
  { "gb",  TILE_GB },   /* Game Boy */
  { "gbc",  TILE_GB },  /* Game Boy Color */
  { "gba", TILE_GBA4 }, /* Game Boy Advance */
  { "agb", TILE_GBA4 }, /* GBA's model number is AGB-001 */
  { "mb", TILE_GBA4 },  /* .mb refers to netboot images */
  { "nes", TILE_NES },  /* iNES format */
  { "unf", TILE_NES },  /* UNIF format for NES */
  { "smc", TILE_SNES }, /* Super Magicom Cartridge format for Super NES */
  { "srm", TILE_SNES }, /* SRM is a popular Super NES emulator's save format */
  { "zst", TILE_SNES }, /* ZST is another */
  { "", TILE_NTYPES }
};

typedef struct ChrDoc
{
  char path[PATH_MAX];
  unsigned char *data;
  u32 length;
  u32 offset;
  TileType sys;
  int tile_pitch;
  int dirty;
} ChrDoc;

ChrDoc docs[8];

#define N_SHORTCUT_LINES 3
const char *const shortcuts[N_SHORTCUT_LINES] =
{
  " ^O=open  ^S=save  ^W=close  ^R=resize  F6=next         ^Q=quit ",
  " F1=mode  F2=save pal  H=flip horz  V=flip vert  R=rotate       ",
  " X=exchange colors                                              "
};

const char *supported_filetypes =
"bin;chr;fnt;gb;gba;nes;sav;sta;smc;srm;zst";


BITMAP *clipboard, *cur_tile;
int pencolor = 15, bgcolor = 0;
int clipoff_x = 0, clipoff_y = 0, in_clip = 1, clip_snap = 1;

/* dirty windows */
volatile char need_tile_refresh = 1;
volatile char need_clip_refresh = 1;
volatile char need_status_refresh = 1;
volatile char need_file_refresh = 1; /* need update_screen() */
volatile char need_palette_refresh = 1;

volatile char winmgr_wants_quit = 0;





int which_clicked(int x, int y, int pitch)
{
  int this_off;

  if(x < 0 || x > 16 || y < 0 || y > 32)
    return -1;
  this_off = x * pitch;
  this_off += (y % pitch) + (y / pitch) * 16 * pitch;

  return this_off;
}


void resize_file(ChrDoc *chrdoc)
{
  char entry[32];
  u32 newSize;
  int hit;
  unsigned char *newdata;

  DIALOG dlg[] =
  {
   /* (dialog proc)     (x)   (y)   (w)   (h)   (fg)  (bg)  (key) (flags)  (d1)  (d2)  (dp) */
   { d_shadow_box_proc, 0,    0,    320,  60,  15,   0,    0,    0,       0,    0,    NULL },
   { d_button_proc,     244,  40,  60,   12,   15,   0,    13,   D_EXIT,  0,    0,    "OK"},
   { d_button_proc,     174,  40,  60,   12,   15,   0,    27,   D_EXIT,  0,    0,    "Cancel"},
   { d_edit_proc,       64,   24,  256,  8,    30,   8,    0,    0, sizeof(entry)-1, 0, entry },
   { d_text_proc,       8,     8,  160,   8,    16,   15,   0,    0,       0,    0,    "Resize to what size?" },
   { NULL,              0,    0,    0,    0,    0,    0,    0,    0,       0,    0,    NULL }
  };

  centre_dialog(dlg);
  sprintf(entry, "%lu", chrdoc->length);
  hit = popup_dialog(dlg, 3);
  if(hit == 2)
    return;
  newSize = strtoul(entry, NULL, 10);
  sprintf(entry, "to %lu bytes?", newSize);
  if(alert("Are you sure you want to resize", chrdoc->path, entry,
           "Resize", "Cancel", 13, 0) == 2)
    return;
  newdata = realloc(chrdoc->data, newSize);
  if(newdata == NULL)
  {
    alert("Resize failed.", "I'm going to crash now.", "", "BSOD", 0, 13, 0);
    return;
  }

  /* if expanded, clear new area */
  if(newSize > chrdoc->length)
  {
    u32 x;

    for(x = chrdoc->length; x < newSize; x++)
      newdata[x] = 0;
  }

  chrdoc->data = newdata;
  chrdoc->length = newSize;
  chrdoc->dirty = 1;
  need_status_refresh = 1;
  need_file_refresh = 1;
}


void get_tile(BITMAP *bmp, const unsigned char *tile, TileType sys)
{
  unsigned int pixels[8][8];
  int x, y;
  unsigned char b0, b1, b2, b3;
  unsigned char bMask = tile_palmask[sys] & bgcolor;


  switch(sys)
  {
  case TILE_PC:
  case TILE_GB:
  case TILE_SNES3:
    for(y = 0; y < 8; y++)
    {
      b0 = *tile++;
      if(sys != TILE_PC)
        b1 = *tile++;
      else
        b1 = 0;
      for(x = 7; x >= 0; x--)
      {
        pixels[y][x] = (b0 & 1) | ((b1 & 1) << 1);
        b0 >>= 1;
        b1 >>= 1;
      }
    }
    if(sys == TILE_SNES3)
    {
      for(y = 0; y < 8; y++)
      {
        b0 = *tile++;
        for(x = 7; x >= 0; x--)
        {
          pixels[y][x] |= (b0 & 1) << 2;
          b0 >>= 1;
        }
      }
    }
    break;

  case TILE_VB:
  case TILE_NGPC:
    /* NGPC tiles are h-flipped VB tiles */
    b3 = (sys == TILE_NGPC) ? 7 : 0;
    for(y = 0; y < 8; y++)
    {
      b0 = *tile++;
      for(x = 0; x < 4; x++)
      {
        pixels[y][x ^ b3] = (b0 & 3);
        b0 >>= 2;
      }
      b0 = *tile++;
      for(x = 4; x < 8; x++)
      {
        pixels[y][x ^ b3] = (b0 & 3);
        b0 >>= 2;
      }
    }
    break;

  case TILE_SMS:
    for(y = 0; y < 8; y++)
    {
      b0 = *tile++;
      b1 = *tile++;
      b2 = *tile++;
      b3 = *tile++;
      for(x = 7; x >= 0; x--)
      {
        pixels[y][x] = (b0 & 1) | ((b1 & 1) << 1) |
                ((b2 & 1) << 2) | ((b3 & 1) << 3);
        b0 >>= 1;
        b1 >>= 1;
        b2 >>= 1;
        b3 >>= 1;
      }
    }
    break;

  case TILE_NES:
    for(y = 0; y < 8; y++)
    {
      b0 = *tile;
      b1 = *(tile + 8);
      for(x = 7; x >= 0; x--)
      {
        pixels[y][x] = (b0 & 1) | ((b1 & 1) << 1);
        b0 >>= 1;
        b1 >>= 1;
      }
      tile++;
    }
    break;

  case TILE_SNES:
    for(y = 0; y < 8; y++)
    {
      b0 = *tile;
      b1 = *(tile + 1);
      b2 = *(tile + 16);
      b3 = *(tile + 17);
      for(x = 7; x >= 0; x--)
      {
        pixels[y][x] = (b0 & 1) | ((b1 & 1) << 1) |
                ((b2 & 1) << 2) | ((b3 & 1) << 3);
        b0 >>= 1;
        b1 >>= 1;
        b2 >>= 1;
        b3 >>= 1;
      }
      tile += 2;
    }
    break;

  case TILE_PACKED:
    for(y = 0; y < 8; y++)
      for(x = 0; x < 8; x++)
        pixels[y][x] = *tile++;
    break;

  case TILE_MD:
  case TILE_GBA4:
    /* GBA tiles are little-endian within a byte; MD tiles are big-endian */
    b3 = (sys == TILE_GBA4) ? 1 : 0;
    for(y = 0; y < 8; y++)
      for(x = 0; x < 8; x += 2)
      {
        b0 = *tile++;
        pixels[y][(x)     ^ b3] = (b0 >> 4);
        pixels[y][(x + 1) ^ b3] = (b0 & 0x0f);
      }
    break;

  default:
    for(y = 0; y < 8; y++)
      for(x = 0; x < 8; x++)
        pixels[y][x] = 0;
    break;
  }

  for(y = 0; y < 8; y++)
    for(x = 0; x < 8; x++)
      putpixel(bmp, x, y, pixels[y][x] | bMask);
}


void put_tile(BITMAP *bmp, unsigned char *tile, TileType sys)
{
  unsigned int pixels[8][8];
  int x, y, c;
  char b0, b1, b2, b3;

  for(y = 0; y < 8; y++)
    for(x = 0; x < 8; x++)
      pixels[y][x] = getpixel(bmp, x, y);

  switch(sys)
  {
  case TILE_PC:
  case TILE_GB:
  case TILE_SMS:
  case TILE_SNES3:
    for(y = 0; y < 8; y++)
    {
      b0 = b1 = b2 = b3 = 0;
      for(x = 0; x < 8; x++)
      {
        c = pixels[y][x];

        b0 <<= 1;
        b0 |= c & 1;
        c >>= 1;

        b1 <<= 1;
        b1 |= c & 1;
        c >>= 1;

        b2 <<= 1;
        b2 |= c & 1;
        c >>= 1;

        b3 <<= 1;
        b3 |= c & 1;
      }
      *tile++ = b0;
      if(sys != TILE_PC)
      {
        *tile++ = b1;
        if(sys == TILE_SMS)
        {
          *tile++ = b2;
          *tile++ = b3;
        }
      }
    }
    if(sys == TILE_SNES3)
      for(y = 0; y < 8; y++)
      {
        b0 = 0;
        for(x = 0; x < 8; x++)
        {
          c = pixels[y][x] >> 2;

          b0 <<= 1;
          b0 |= c & 1;
          c >>= 1;
        }
        *tile++ = b0;
      }
    break;

  case TILE_SNES:
    for(y = 0; y < 8; y++)
    {
      b0 = b1 = b2 = b3 = 0;
      for(x = 0; x < 8; x++)
      {
        c = pixels[y][x];

        b0 <<= 1;
        b0 |= c & 1;
        c >>= 1;

        b1 <<= 1;
        b1 |= c & 1;
        c >>= 1;

        b2 <<= 1;
        b2 |= c & 1;
        c >>= 1;

        b3 <<= 1;
        b3 |= c & 1;
      }

      *tile = b0;
      *(tile + 1) = b1;
      *(tile + 16) = b2;
      *(tile + 17) = b3;
      tile += 2;
    }
    break;

  case TILE_NES:
    for(y = 0; y < 8; y++)
    {
      b0 = b1 = b2 = b3 = 0;
      for(x = 0; x < 8; x++)
      {
        c = pixels[y][x];

        b0 <<= 1;
        b0 |= c & 1;
        c >>= 1;

        b1 <<= 1;
        b1 |= c & 1;
      }

      *tile = b0;
      *(tile + 8) = b1;
      tile++;
    }
    break;

  case TILE_PACKED:
    for(y = 0; y < 8; y++)
      for(x = 0; x < 8; x++)
        *tile++ = pixels[y][x];
    break;

  case TILE_MD:
  case TILE_GBA4:
    /* GBA tiles are little-endian within a byte; MD tiles are big-endian */
    b3 = (sys == TILE_GBA4) ? 1 : 0;
    for(y = 0; y < 8; y++)
      for(x = 0; x < 8; x += 2)
        *tile++ = (pixels[y][(x)     ^ b3] << 4) |
                  (pixels[y][(x + 1) ^ b3] & 0x0f);
    break;

  case TILE_VB:
  case TILE_NGPC:
    /* NGPC tiles are h-flipped VB tiles */
    b3 = (sys == TILE_NGPC) ? 7 : 0;
    for(y = 0; y < 8; y++)
    {
      b0 = 0;
      for(x = 3; x >= 0; x--)
      {
        b0 <<= 2;
        b0 |= pixels[y][x ^ b3] & 3;
      }
      *tile++ = b0;
      
      b0 = 0;
      for(x = 7; x >= 4; x--)
      {
        b0 <<= 2;
        b0 |= pixels[y][x ^ b3] & 3;
      }
      *tile++ = b0;
    }
    break;

  default: /* leave unimplemented tiles read-only */
    break;
  }
}


/* update_status() *********************
 * Update the status bar.
 */
void update_status(ChrDoc *chrdoc)
{
  char filename[PATH_MAX + 128];
  int i;

  scare_mouse();
  acquire_screen();
  rectfill(screen, 0, 0, SCREEN_W, 39, 15);
  rectfill(screen,
           0, SCREEN_H - 4 - 8 * N_SHORTCUT_LINES,
           SCREEN_W, SCREEN_H - 1,
           15);
  textout_ex(screen, font, chrdoc->path, 8, 4, 0, 15);
  textprintf_ex(screen, font, 8, 12, 0, 15,
                "len:%9lu   off:0x%8lx   fmt:%16s  ",
                chrdoc->length, chrdoc->offset, tiletype_names[chrdoc->sys]);
  for (i = 0; i < N_SHORTCUT_LINES; ++i) {
    textout_ex(screen, font,
               shortcuts[i],
               0, SCREEN_H - 2 - 8 * (N_SHORTCUT_LINES - i),
               0, 15);
  }
  release_screen();
  unscare_mouse();

  strcpy(filename, get_filename(chrdoc->path));
  strcat(filename, " - 8ted");
  set_window_title(filename);
}


int write_chr(ChrDoc *chrdoc)
{
  FILE *outfile;

  if (file_select_ex("Save chr as:", chrdoc->path, supported_filetypes,
                     sizeof(chrdoc->path), 400, 300) == 0) {
    return -1; /* cancel */
  }

  outfile = fopen(chrdoc->path, "wb");
  if (!outfile) {
    alert("Could not write to", chrdoc->path, strerror(errno),
          "OK", 0, 13, 0);
    return -1;
  }
  fwrite(chrdoc->data, 1, chrdoc->length, outfile);
  fclose(outfile);
  alert(chrdoc->path, "saved.", "", "OK", 0, 13, 0);
  chrdoc->dirty = 0;
  return 0;
}


/* ask_save_changes() ******************
   Ask if the user wants to save changes, and write if so.
*/
int ask_save_changes(ChrDoc *chrdoc)
{
  int response = 1;  /* in non-dirty documents, don't save changes. */

  if(chrdoc->data == 0)
    return 0;

  if(chrdoc->dirty)
    response = alert3("Character pattern document",
                      chrdoc->path,
                      "has been modified. Save changes?",
                      "&Don't Save", "Cancel", "Save",
                      'D', 27, 13);
  if(response == 2)
    return -1; /* cancel close */
  if(response == 3)
  {
    if(write_chr(chrdoc) < 0) /* if write was canceled or failed, */
      return -1;              /* cancel close also */
  }
  return 0;
}


int close_chr(ChrDoc *chrdoc)
{
  if(chrdoc->data == 0)
    return 0;

  if(ask_save_changes(chrdoc) < 0)
    return -1;

  free(chrdoc->data);
  chrdoc->data = 0;
  chrdoc->dirty = 0;
  chrdoc->length = 0;
  return 0;
}


char *my_strlwr(char *filename)
{
  char *s = filename;
  if(filename == NULL)
    return NULL;
  while(*s)
  {
    *s = tolower(*s);
    s++;
  }
  return filename;
}


/* get_system() ************************
 * Returns the bitmap storage format associated with a
 * filename's extension.
 */
int get_system(const char *filename)
{
  char *ext;
  const TileTypeAssoc *assoc = tile_assocs;

  if(filename == NULL)
    return TILE_PC;

  ext = get_extension(filename);

  while(assoc->ext[0])
  {
    if(stricmp(assoc->ext, ext) == 0) /* if the extension matches */
      return assoc->system;
    assoc++;
  }
  return TILE_PC;
}


/* load_chr() **************************
 * Load a chr file from chrdoc->path.
 */
int load_chr(ChrDoc *chrdoc)
{
  FILE *infile;
  int gotlen;

  infile = fopen(chrdoc->path, "rb");
  if(infile == 0)
  {
    if(errno == ENOENT)
    {
      if(alert(chrdoc->path, "does not exist.  Create it?", "",
               "Create", "Cancel", 13, 27) == 2)
        return -1; /* canceled creation */
      chrdoc->data = calloc(1, 8192);
      if(!chrdoc->data)
      {
        alert("Not enough memory to create", chrdoc->path, "",
              "Cancel", 0, 13, 0);
        return -1;
      }
      chrdoc->offset = 0;
      chrdoc->length = 8192;
      chrdoc->sys = get_system(chrdoc->path);
      chrdoc->tile_pitch = 1;
      return 0;
    }
    else
    {
      alert("Could not read from", chrdoc->path, strerror(errno),
            "Cancel", 0, 13, 0);
      return -1;
    }
  }

  chrdoc->offset = 0;
  chrdoc->tile_pitch = 1;
  chrdoc->sys = get_system(chrdoc->path);

  fseek(infile, 0, SEEK_END);
  gotlen = ftell(infile);
  if(gotlen > 0)
  {
    rewind(infile);
    chrdoc->data = malloc(gotlen);
    if(!chrdoc->data)
    {
      char line2[256];

      sprintf(line2, "%d bytes of", gotlen);
      alert("Not enough memory to load", line2, chrdoc->path,
            "Cancel", 0, 13, 0);
      return -1;
    }
    fread(chrdoc->data, 1, gotlen, infile);
    chrdoc->length = gotlen;
  }
  else
  {
    chrdoc->data = calloc(1, 8192);
    chrdoc->length = 8192;
  }
  fclose(infile);
  return 0;
}


int load_dialog(ChrDoc *chrdoc)
{
  if(file_select_ex("Load which chr file?", chrdoc->path,
                    supported_filetypes,
                    sizeof(chrdoc->path), 400, 300) == 0)
    return -1; /* cancel */
  return load_chr(chrdoc);
}

/* update_screen() *********************
 * Draw all tiles.
 */
void update_screen(ChrDoc *chrdoc)
{
  BITMAP *bmp;
  unsigned char *data;
  u32 offset, length, this_off;
  int pitch, tsize;
  int x, y;

  bmp = create_bitmap_ex(8, 8, 8);
  if(!bmp)
    return;

  data = chrdoc->data;
  offset = chrdoc->offset;
  length = chrdoc->length;
  pitch = chrdoc->tile_pitch;
  tsize = tile_offsets[chrdoc->sys];

  scare_mouse();

  rect(screen, TILEAREA_LEFT - 1, TILEAREA_TOP - 1,
       TILEAREA_LEFT + 128, TILEAREA_TOP + 256, 15);
  for(y = 0; y < 32; y++)
  {
    for(x = 0; x < 16; x++)
    {
      this_off = tsize * which_clicked(x, y, pitch) + offset;
      if(this_off + tsize > length)
        clear(bmp);
      else
        get_tile(bmp, data + this_off, chrdoc->sys);
      blit(bmp, screen, 0, 0,
           x * 8 + TILEAREA_LEFT, y * 8 + TILEAREA_TOP, 8, 8);
    }
  }

  unscare_mouse();

  free(bmp);
}


void update_tile(void)
{
  acquire_screen();
  scare_mouse();
  rect(screen, CURTILE_LEFT - 1, CURTILE_TOP - 1,
       CURTILE_LEFT + 8 * CURTILE_MAGNIFY, CURTILE_TOP + 8 * CURTILE_MAGNIFY, 15);
  stretch_blit(cur_tile, screen, 0, 0, 8, 8,
               CURTILE_LEFT, CURTILE_TOP, 8 * CURTILE_MAGNIFY, 8 * CURTILE_MAGNIFY);
  unscare_mouse();
  release_screen();

}


void update_paled(void)
{
  acquire_screen();
  scare_mouse();
  rectfill(screen, PALED_LEFT, PALED_TOP + 1, PALED_LEFT + 23, PALED_TOP + 71, 0);
  hline(screen, PALED_LEFT, PALED_TOP, PALED_LEFT + 23, 15);
  rectfill(screen, PALED_LEFT, PALED_TOP + 64 - pal[pencolor].r,
           PALED_LEFT + 7, PALED_TOP + 71 - pal[pencolor].r, 15);
  rectfill(screen, PALED_LEFT + 8, PALED_TOP + 64 - pal[pencolor].g,
           PALED_LEFT + 15, PALED_TOP + 71 - pal[pencolor].g, 15);
  rectfill(screen, PALED_LEFT + 16, PALED_TOP + 64 - pal[pencolor].b,
           PALED_LEFT + 23, PALED_TOP + 71 - pal[pencolor].b, 15);
  set_color(pencolor, &(pal[pencolor]));
  textout_ex(screen, font, "RGB", PALED_LEFT, PALED_TOP + 72, 15, 0);
  unscare_mouse();
  release_screen();
}


void update_palette(void)
{
  int x, y;

  acquire_screen();
  scare_mouse();
  rect(screen, PALETTE_LEFT - 1, PALETTE_TOP - 1,
       PALETTE_LEFT + 16 * PALETTE_MAGNIFY, PALETTE_TOP + 16 * PALETTE_MAGNIFY, 15);
  rect(screen, PALETTE_LEFT - 2, PALETTE_TOP - 2,
       PALETTE_LEFT + 1 + 16 * PALETTE_MAGNIFY, PALETTE_TOP + 1 + 16 * PALETTE_MAGNIFY, 0);

  for(y = 0; y < 16; y++)
    for(x = 0; x < 16; x++)
      rectfill(screen,
               PALETTE_LEFT + x * PALETTE_MAGNIFY,
               PALETTE_TOP  + y * PALETTE_MAGNIFY,
               PALETTE_LEFT + PALETTE_MAGNIFY - 1 + x * PALETTE_MAGNIFY,
               PALETTE_TOP  + PALETTE_MAGNIFY - 1 + y * PALETTE_MAGNIFY,
               y * 16 + x);

  y = bgcolor / 16;
  x = bgcolor % 16;
  rect(screen,
       PALETTE_LEFT + 1 + PALETTE_MAGNIFY * x,
       PALETTE_TOP - 2 + PALETTE_MAGNIFY * y,
       PALETTE_LEFT + 1 + PALETTE_MAGNIFY * (x + 1),
       PALETTE_TOP + 1 + PALETTE_MAGNIFY * (y + 1),
       bgcolor);

  y = pencolor / 16;
  x = pencolor % 16;
  rect(screen,
       PALETTE_LEFT - 2 + PALETTE_MAGNIFY * x,
       PALETTE_TOP - 2 + PALETTE_MAGNIFY * y,
       PALETTE_LEFT - 2 + PALETTE_MAGNIFY * (x + 1),
       PALETTE_TOP + 1 + PALETTE_MAGNIFY * (y + 1),
       pencolor);

  unscare_mouse();
  release_screen();
  update_paled();
}


void update_clipboard()
{
  char snap_msg[] = "[ ] Snap to 8 pixels";

  if(in_clip)
    blit(cur_tile, clipboard, 0, 0, clipoff_x, clipoff_y, 8, 8);
  acquire_screen();
  scare_mouse();
  blit(clipboard, screen, 0, 0,
       CLIPBOARD_LEFT, CLIPBOARD_TOP, CLIPBOARD_WIDTH, CLIPBOARD_HEIGHT);
  rect(screen, CLIPBOARD_LEFT - 2, CLIPBOARD_TOP - 2,
       CLIPBOARD_LEFT + CLIPBOARD_WIDTH + 1, CLIPBOARD_HEIGHT + CLIPBOARD_TOP + 1,
       0);
  rect(screen, CLIPBOARD_LEFT - 1, CLIPBOARD_TOP - 1,
       CLIPBOARD_LEFT + CLIPBOARD_WIDTH, CLIPBOARD_HEIGHT + CLIPBOARD_TOP,
       15);
  if(in_clip)
    rect(screen, CLIPBOARD_LEFT - 2 + clipoff_x, CLIPBOARD_TOP - 2 + clipoff_y,
         CLIPBOARD_LEFT + 9 + clipoff_x, CLIPBOARD_TOP + 9 + clipoff_y,
         15);

  if(clip_snap) {
    snap_msg[1] = 'X';
  }
  textout_ex(screen, font, snap_msg,
             CLIPBOARD_LEFT, CLIPBOARD_TOP + CLIPBOARD_HEIGHT + 2,
             15, 0);
  unscare_mouse();
  release_screen();
}


void handle_left_click(unsigned int x, unsigned int y, int held,
                       ChrDoc *chrdoc)
{
  if(x >= TILEAREA_LEFT && x < TILEAREA_LEFT + 128 &&
     y >= TILEAREA_TOP  && y < TILEAREA_TOP  + 256)
  {
    unsigned int tile_x = (x - TILEAREA_LEFT) / 8;
    unsigned int tile_y = (y - TILEAREA_TOP)  / 8;
    unsigned int clicked = which_clicked(tile_x, tile_y, chrdoc->tile_pitch);
    unsigned int tsize = tile_offsets[chrdoc->sys];
    unsigned int this_off = tsize * clicked + chrdoc->offset;
    if(this_off + tsize <= chrdoc->length)
    {
      get_tile(cur_tile, chrdoc->data + this_off, chrdoc->sys);
      if(in_clip)
      {
        in_clip = 0;
        need_clip_refresh = 1;
      }
      need_tile_refresh = 1;
    }
  }

  else if(x >= CURTILE_LEFT && x < CURTILE_LEFT + CURTILE_MAGNIFY * 8 &&
     y >= CURTILE_TOP  && y < CURTILE_TOP  + CURTILE_MAGNIFY * 8)
  {
    unsigned int tile_x = (x - CURTILE_LEFT) / CURTILE_MAGNIFY;
    unsigned int tile_y = (y - CURTILE_TOP)  / CURTILE_MAGNIFY;

    if(key[KEY_LCONTROL] | key[KEY_RCONTROL])  /* control-click = grab */
    {
      pencolor = getpixel(cur_tile, tile_x, tile_y);
      need_palette_refresh = 1;
    }
    else
    {
      putpixel(cur_tile, tile_x, tile_y, pencolor);
      need_tile_refresh = 1;
    }
  }

  else if(x >= PALETTE_LEFT && x < PALETTE_LEFT + PALETTE_MAGNIFY * 16 &&
     y >= PALETTE_TOP  && y < PALETTE_TOP  + PALETTE_MAGNIFY * 16)
  {
    unsigned int tile_x = (x - PALETTE_LEFT) / PALETTE_MAGNIFY;
    unsigned int tile_y = (y - PALETTE_TOP)  / PALETTE_MAGNIFY;

    pencolor = tile_y * 16 + tile_x;
    need_palette_refresh = 1;
  }

  else if(x >= PALED_LEFT && x < PALED_LEFT + 8 &&
          y >= PALED_TOP && y < PALED_TOP + 72)
  {
    int r = y - PALED_TOP - 4;

    if(r < 0)
      r = 0;
    if(r > 63)
      r = 63;
    pal[pencolor].r = 63 - r;
    update_paled();
    y += 4;
  }

  else if(x >= PALED_LEFT + 8 && x < PALED_LEFT + 16 &&
          y >= PALED_TOP && y < PALED_TOP + 72)
  {
    int r = y - PALED_TOP - 4;

    if(r < 0)
      r = 0;
    if(r > 63)
      r = 63;
    pal[pencolor].g = 63 - r;
    update_paled();
    y += 4;
  }

  else if(x >= PALED_LEFT + 16 && x < PALED_LEFT + 24 &&
          y >= PALED_TOP && y < PALED_TOP + 72)
  {
    int r = y - PALED_TOP - 4;

    if(r < 0)
      r = 0;
    if(r > 63)
      r = 63;
    pal[pencolor].b = 63 - r;
    update_paled();
    y += 4;
  }

  else if(x >= CLIPBOARD_LEFT && x < CLIPBOARD_LEFT + CLIPBOARD_WIDTH &&
          y >= CLIPBOARD_TOP  && y < CLIPBOARD_TOP  + CLIPBOARD_HEIGHT + 10)
  {
    unsigned int tile_x = x - CLIPBOARD_LEFT;
    unsigned int tile_y = y - CLIPBOARD_TOP;

    need_tile_refresh = 1;
    if(tile_y >= CLIPBOARD_HEIGHT)
    {
      if(!held)
      {
        clip_snap = !clip_snap;
        need_clip_refresh = 1;
      }
      return;
    }

    if(clip_snap)
    {
      tile_x &= ~7;
      tile_y &= ~7;
    }
    else
    {
      if(tile_x < 4)
        tile_x = 4;
      else if(tile_x > CLIPBOARD_WIDTH - 4)
        tile_x = CLIPBOARD_WIDTH - 4;
      tile_y -= 4;

      if(tile_y < 4)
        tile_y = 4;
      else if(tile_y > CLIPBOARD_HEIGHT - 4)
        tile_y = CLIPBOARD_HEIGHT - 4;
      tile_y -= 4;
    }

    in_clip = 1;
    clipoff_x = tile_x;
    clipoff_y = tile_y;
    blit(clipboard, cur_tile, tile_x, tile_y, 0, 0, 8, 8);
  }
}


void handle_press_f(unsigned int x, unsigned int y,
                    ChrDoc *chrdoc)
{
  if(x >= CURTILE_LEFT && x < CURTILE_LEFT + CURTILE_MAGNIFY * 8 &&
     y >= CURTILE_TOP  && y < CURTILE_TOP  + CURTILE_MAGNIFY * 8)
  {
    unsigned int tile_x = (x - CURTILE_LEFT) / CURTILE_MAGNIFY;
    unsigned int tile_y = (y - CURTILE_TOP)  / CURTILE_MAGNIFY;

    floodfill(cur_tile, tile_x, tile_y, pencolor);
    need_tile_refresh = 1;
  }

}


void handle_right_click(unsigned int x, unsigned int y, int held,
                        ChrDoc *chrdoc)
{
  if(x >= TILEAREA_LEFT && x < TILEAREA_LEFT + 128 &&
     y >= TILEAREA_TOP  && y < TILEAREA_TOP  + 256)
  {
    unsigned int tile_x = (x - TILEAREA_LEFT) / 8;
    unsigned int tile_y = (y - TILEAREA_TOP)  / 8;
    unsigned int clicked = which_clicked(tile_x, tile_y, chrdoc->tile_pitch);
    unsigned int tsize = tile_offsets[chrdoc->sys];
    unsigned int this_off = tsize * clicked + chrdoc->offset;
    if(this_off + tsize <= chrdoc->length)
    {
      put_tile(cur_tile, chrdoc->data + this_off, chrdoc->sys);
      need_file_refresh = 1;
      chrdoc->dirty = 1;
    }
  }

  else if(x >= CURTILE_LEFT && x < CURTILE_LEFT + CURTILE_MAGNIFY * 8 &&
     y >= CURTILE_TOP  && y < CURTILE_TOP  + CURTILE_MAGNIFY * 8)
  {
    unsigned int tile_x = (x - CURTILE_LEFT) / CURTILE_MAGNIFY;
    unsigned int tile_y = (y - CURTILE_TOP)  / CURTILE_MAGNIFY;

    if(key[KEY_LCONTROL] | key[KEY_RCONTROL])  /* control-click = grab */
    {
      bgcolor = getpixel(cur_tile, tile_x, tile_y);
      need_palette_refresh = 1;
    }
    else
    {
      putpixel(cur_tile, tile_x, tile_y, bgcolor);
      need_tile_refresh = 1;
    }
  }

  else if(x >= PALETTE_LEFT && x < PALETTE_LEFT + PALETTE_MAGNIFY * 16 &&
     y >= PALETTE_TOP  && y < PALETTE_TOP  + PALETTE_MAGNIFY * 16)
  {
    unsigned int tile_x = (x - PALETTE_LEFT) / PALETTE_MAGNIFY;
    unsigned int tile_y = (y - PALETTE_TOP)  / PALETTE_MAGNIFY;

    bgcolor = tile_y * 16 + tile_x;
    need_palette_refresh = need_file_refresh = 1;
  }

  else if(x >= CLIPBOARD_LEFT && x < CLIPBOARD_LEFT + CLIPBOARD_WIDTH  &&
          y >= CLIPBOARD_TOP  && y < CLIPBOARD_TOP  + CLIPBOARD_HEIGHT + 10)
  {
    unsigned int tile_x = x - CLIPBOARD_LEFT;
    unsigned int tile_y = y - CLIPBOARD_TOP;

    need_clip_refresh = 1;

    if(tile_y >= CLIPBOARD_HEIGHT)
    {
      if(!held)
        clip_snap = !clip_snap;
      return;
    }

    if(clip_snap)
    {
      tile_x &= ~7;
      tile_y &= ~7;
    }
    else
    {
      if(tile_x < 4)
        tile_x = 4;
      else if(tile_x > CLIPBOARD_WIDTH - 4)
        tile_x = CLIPBOARD_WIDTH - 4;
      tile_y -= 4;

      if(tile_y < 4)
        tile_y = 4;
      else if(tile_y > CLIPBOARD_HEIGHT - 4)
        tile_y = CLIPBOARD_HEIGHT - 4;
      tile_y -= 4;
    }

    in_clip = 1;
    clipoff_x = tile_x;
    clipoff_y = tile_y;
  }
}


void load_pal(void)
{
  FILE *fp = fopen("tiled.pal", "rb");
  int i = 0, c;
  
  get_palette(pal);
  if(!fp)
    return;

  do {
    c = fgetc(fp);
    if(c == EOF)
      return;
    pal[i].r = (c >> 2) & 0x3f;
    c = fgetc(fp);
    if(c == EOF)
      return;
    pal[i].g = (c >> 2) & 0x3f;
    c = fgetc(fp);
    if(c == EOF)
      return;
    pal[i].b = (c >> 2) & 0x3f;
  } while(++i < 256);
}


void save_pal(void)
{
  FILE *fp = fopen("tiled.pal", "wb");
  int i;

  if(!fp)
  {
    alert("", "Could not open tiled.pal for writing", "", "OK", 0, 13, 0);
  }

  for(i = 0; i < 256; i++)
  {
    fputc(pal[i].r << 2, fp);
    fputc(pal[i].g << 2, fp);
    fputc(pal[i].b << 2, fp);
  }
  fclose(fp);
  alert("", "Palette saved to tiled.pal", "", "OK", 0, 13, 0);
}


void winclosehook()
{
  winmgr_wants_quit = 1;
}


/* refresh_all() ***********************
   Request a refresh for all screen elements.
*/
void refresh_all()
{
  need_tile_refresh = 1;
  need_clip_refresh = 1;
  need_status_refresh = 1;
  need_file_refresh = 1;
  need_palette_refresh = 1;
}


const char helpText[] =
"Usage: 8ted [CHRFILE ...]\n"
"\n"
"Options:\n"
"  -f, --full        Force full screen, ignoring windowed mode\n"
"  -h, -?, --help    Display this help message\n"
"  -v, --version     Display version and copyright information\n";

const char versionText[] =
"8TED 0.4\n"
"Copyright 2001-2008 Damian Yerrick\n"
"This program comes with ABSOLUTELY NO WARRANTY.  It is free software,\n"
"and you are welcome to redistribute it under certain conditions.\n"
"Please see the manual for more information.\n";

int main(int argc, const char *argv[])
{
  int arg;
  int i, j;
  int last_mouse_b = 3;
  char done = 0, quitting = 0, forceFullScreen = 0;
  BITMAP *tile_temp;

  int nFiles = 0;
  int cur_doc = 0;

  allegro_init();
  install_timer();
  LOCK_VARIABLE(need_tile_refresh);
  LOCK_VARIABLE(need_clip_refresh);
  LOCK_VARIABLE(need_status_refresh);
  LOCK_VARIABLE(need_file_refresh);
  LOCK_VARIABLE(need_palette_refresh);
  LOCK_VARIABLE(winmgr_wants_quit);
  LOCK_FUNCTION(winclosehook);
  LOCK_FUNCTION(refresh_all);

  for (arg = 1; arg < argc; ++arg)
  {
    if (argv[arg][0] == '-') {
      switch (argv[arg][1]) {
      case 'f':
        forceFullScreen = 1;
        break;
      case '?':
      case 'h':
        allegro_message(helpText);
        return 0;
      case 'v':
        allegro_message(versionText);
        return 0;
      case '-':
        if (!strcmp(argv[arg] + 2, "full")) {
          forceFullScreen = 1;
        } else if (!strcmp(argv[arg] + 2, "help")) {
          allegro_message(helpText);
          return 0;
        } else if (!strcmp(argv[arg] + 2, "version")) {
          allegro_message(versionText);
          return 0;
        }
      } 
    } else if(nFiles <= MAX_CHRDOCS) {
      strncpy(docs[nFiles].path, argv[arg], PATH_MAX - 1);
      docs[nFiles].path[PATH_MAX - 1] = 0;
      if(load_chr(&(docs[nFiles])) >= 0)
        nFiles++;
    }
  }

  if((forceFullScreen
      || set_gfx_mode(GFX_AUTODETECT_WINDOWED, 512, 384, 0, 0) < 0)
     && set_gfx_mode(GFX_AUTODETECT, 512, 384, 0, 0) < 0
     && set_gfx_mode(GFX_AUTODETECT, 640, 480, 0, 0) < 0)
  {
    allegro_message("Could not open a 512x384x8 or 640x480x8 window.\n");
  }
  install_keyboard();
  install_mouse();
  show_mouse(screen);
  cur_tile = create_bitmap(8, 8);
  tile_temp = create_bitmap(8, 8);
  clipboard = create_bitmap(256, 128);

  rect(screen, -1, -1, 512, 384, 15);
  
  clear_bitmap(clipboard);
  clear_bitmap(cur_tile);
  load_pal();
  set_palette(pal);

  set_window_title("8ted © 2001-2002 Damian Yerrick");
  set_close_button_callback(winclosehook);
  set_display_switch_callback(SWITCH_IN, refresh_all);

  if(nFiles < 1)
  {
    if(load_dialog(&(docs[0])) < 0)
    {
      alert("cancel was pressed", "", "", "like this?", 0, 13, 0);
      return 1;
    }
    nFiles = 1;
  }

  while(!done)
  {
    int mouse_bb = mouse_b;

    if (!mouse_bb) {
      rest(5);
    }
    vsync();
    if(need_file_refresh)
    {
      update_screen(&docs[cur_doc]);
      need_file_refresh = 0;
    }
    if(need_status_refresh)
    {
      update_status(&docs[cur_doc]);
      textprintf_ex(screen, font, 8, 28, 0, -1,
                 "cur_doc: %u of %u", cur_doc, nFiles);
      need_status_refresh = 0;
    }
    if(need_tile_refresh)
    {
      update_tile();
      if(in_clip)
        need_clip_refresh = 1;
      need_tile_refresh = 0;
    }
    if(need_palette_refresh)
    {
      update_palette();
      need_palette_refresh = 0;
    }
    if(need_clip_refresh)
    {
      update_clipboard();
      need_clip_refresh = 0;
    }

    if(mouse_bb & 1)
    {
      handle_left_click(mouse_x, mouse_y, last_mouse_b & 1, &docs[cur_doc]);
    }
    else if(mouse_bb & 2)
    {
      handle_right_click(mouse_x, mouse_y, last_mouse_b & 2, &docs[cur_doc]);
    }
    last_mouse_b = mouse_bb;

    while(keypressed())
    {
      int gotkey = readkey();
      int row_pitch = 16 * tile_offsets[docs[cur_doc].sys] * docs[cur_doc].tile_pitch;

      if(gotkey & 0xff)
        switch(gotkey & 0xff)
        {
        case 'L'-'@': /* C-l: refresh */
          refresh_all();
          break;

        case 'O'-'@': /* C-o */
          if(nFiles >= MAX_CHRDOCS)
          {
            alert("You can only have 8 files open at the",
                  "same time.  But at least it beats",
                  "tlayer, which only gives you one ;-)",
                  "OK", 0, 13, 0);
            break;
          }
          i = cur_doc;
          do {
            cur_doc++;
            if(cur_doc >= MAX_CHRDOCS)
              cur_doc = 0;
          } while(docs[cur_doc].data != NULL);
          if(load_dialog(&docs[cur_doc]) < 0)
            cur_doc = i;
          else
          {
            nFiles++;
            need_file_refresh = need_status_refresh = 1;
          }
          break;
        
        case 'Q'-'@':
          quitting = 1;
          break;

        case 'R'-'@':
          resize_file(&docs[cur_doc]);
          break;

        case 'S'-'@':
          write_chr(&docs[cur_doc]);
          break;

        case 'W'-'@':
          if(close_chr(&docs[cur_doc]) >= 0)
          {
            nFiles--;
            if(nFiles == 0)
              quitting = 1;
            else
            {
              do {
                cur_doc++;
                if(cur_doc >= MAX_CHRDOCS)
                  cur_doc = 0;
              } while(docs[cur_doc].data == NULL);
              need_file_refresh = need_status_refresh = 1;
            }
          }
          break;

        case 'F':
        case 'f':
          handle_press_f(mouse_x, mouse_y, &docs[cur_doc]);
          break;

        case 'H':
        case 'h':
          clear(tile_temp);
          draw_sprite_h_flip(tile_temp, cur_tile, 0, 0);

          blit(tile_temp, cur_tile, 0, 0, 0, 0, 8, 8);
          need_tile_refresh = 1;
          break;

        case 'V':
        case 'v':
          clear(tile_temp);
          draw_sprite_v_flip(tile_temp, cur_tile, 0, 0);

          blit(tile_temp, cur_tile, 0, 0, 0, 0, 8, 8);
          need_tile_refresh = 1;
          break;

        case 'R':
        case 'r':
          for(i = 0; i < 8; i++)
            for(j = 0; j < 8; j++)
              putpixel(tile_temp, i, j, getpixel(cur_tile, j, 7 - i));

          blit(tile_temp, cur_tile, 0, 0, 0, 0, 8, 8);
          need_tile_refresh = 1;
          break;

        case 'X':
        case 'x':
          for(i = 0; i < 8; i++) {
            for(j = 0; j < 8; j++) {
              int c = getpixel(cur_tile, j, i);
              if (c == pencolor) {
                putpixel(cur_tile, j, i, bgcolor);
              } else if (c == bgcolor) {
                putpixel(cur_tile, j, i, pencolor);
              }
            }
          }
          need_tile_refresh = 1;
          break;

        case '=':
        case '+':
          docs[cur_doc].tile_pitch++;
          need_file_refresh = 1;
          break;
          
        case '-':
          if(docs[cur_doc].tile_pitch > 1)
            docs[cur_doc].tile_pitch--;
          need_file_refresh = 1;
          break;
          
        }
      else
        switch(gotkey >> 8)
        {
        case KEY_UP:
          if(docs[cur_doc].offset >= row_pitch)
            docs[cur_doc].offset -= row_pitch;
          else
            docs[cur_doc].offset = 0;
          need_file_refresh = need_status_refresh = 1;
          break;

        case KEY_DOWN:
          if(docs[cur_doc].length < 384 * tile_offsets[docs[cur_doc].sys])
            docs[cur_doc].offset = 0;
          else if(docs[cur_doc].length - docs[cur_doc].offset >
                  3 * row_pitch)
            docs[cur_doc].offset += row_pitch;
          need_file_refresh = need_status_refresh = 1;
          break;

        case KEY_PGUP:
          if(docs[cur_doc].offset >= 384 * tile_offsets[docs[cur_doc].sys])
            docs[cur_doc].offset -= 384 * tile_offsets[docs[cur_doc].sys];
          else
            docs[cur_doc].offset = 0;
          need_file_refresh = need_status_refresh = 1;
          break;

        case KEY_PGDN:
          if(docs[cur_doc].length < 384 * tile_offsets[docs[cur_doc].sys])
            docs[cur_doc].offset = 0;
          else if(docs[cur_doc].length - docs[cur_doc].offset >
                  512 * tile_offsets[docs[cur_doc].sys])
            docs[cur_doc].offset += 384 * tile_offsets[docs[cur_doc].sys];
          need_file_refresh = need_status_refresh = 1;
          break;

        case KEY_LEFT:
        {
	  int off_amt = 1;

	  if(key[KEY_LCONTROL]| key[KEY_RCONTROL])
	    off_amt = tile_offsets[docs[cur_doc].sys];

	  if(docs[cur_doc].offset >= off_amt)
          {
            docs[cur_doc].offset -= off_amt;
            need_file_refresh = need_status_refresh = 1;
          }
        } break;

        case KEY_RIGHT:
	{
	  int off_amt = 1;

	  if(key[KEY_LCONTROL] | key[KEY_RCONTROL])
	    off_amt = tile_offsets[docs[cur_doc].sys];

          if(docs[cur_doc].length - docs[cur_doc].offset >= 64 + off_amt)
          {
            docs[cur_doc].offset += off_amt;
            need_file_refresh = need_status_refresh = 1;
          }
        } break;

        case KEY_F6:
          do {
            cur_doc++;
            if(cur_doc >= MAX_CHRDOCS)
              cur_doc = 0;
          } while(docs[cur_doc].data == NULL);
          need_file_refresh = need_status_refresh = 1;
          break;

        case KEY_F1:
          docs[cur_doc].sys++;
          if(docs[cur_doc].sys >= TILE_NTYPES)
            docs[cur_doc].sys = 0;
          need_file_refresh = need_status_refresh = 1;
          break;

        case KEY_F2:
          save_pal();
          break;

        }
    }

    if(winmgr_wants_quit)
    {
      quitting = 1;
      winmgr_wants_quit = 0;
    }
    /* VERIFYME: need to verify save changes on all files before quitting */
    if(quitting)
    {
      for(i = 0; i < MAX_CHRDOCS; i++)
      {
        if(docs[i].dirty && ask_save_changes(&docs[i]) < 0)
        {
          quitting = 0;
          break;
        }
      }
      /* By now, the user doesn't want to save any files that have not
	 already been saved.
      */
      if(quitting)
      {
        for(i = 0; i < MAX_CHRDOCS; i++)
        {
          if(docs[i].data)
          {
            docs[i].dirty = 0;
            if(close_chr(&docs[i]) < 0)
            {
              alert("Should never get here.  A dirty file",
                    "should have been caught in the first",
                    "loop through the docs array.",
                    "OK", 0, 13, 0);
            }
            else
              nFiles--;
          }
        }
        done = 1;
      }
    }
  }

#if REPORT_MEMORY_LEAKS
  {
    char dlg_line[256];

    sprintf(dlg_line, "%d fileleaks", nFiles);
    scare_mouse();
    clear(screen);
    unscare_mouse();
    alert(allegro_id, dlg_line, "", "ok", 0, 13, 0);
  }
#endif
  destroy_bitmap(clipboard);
  destroy_bitmap(cur_tile);
  destroy_bitmap(tile_temp);

  return 0;
} END_OF_MAIN();


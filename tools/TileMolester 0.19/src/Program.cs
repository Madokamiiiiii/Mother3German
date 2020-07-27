using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Windows.Forms;
using Nintenlord.GBA;
using Nintenlord.GBA.Compressions;

namespace Nintenlord.NLZ_GBA_Advance
{
    static unsafe class Program
    {
        static public GBAGraphics.BitsPerPixel Bpp
        {
            get { return GBAGraphics.bpp; }
            set
            {
                GBAGraphics.bpp = value;
                GBAGraphics.bpp = value;
            }
        }
        static public int graphicsOffset
        {
            get 
            {
                if (GUI.compressedGraphics)
                {
                    return CompressedGraphicsOffsets[GUI.imageIndex]; 
                }
                else
                {
                    return GUI.uncompOffset;
                }
            }
        }
        static public int paletteOffset
        {
            get 
            {
                if (GUI.compressedGraphics)
                {
                    return paletteOffsets[GUI.imageIndex]; 
                }
                else
                {
                    return GUI.paletteOffset;
                }
                
            }
            set 
            {
                if (GUI.compressedGraphics)
                {
                    paletteOffsets[GUI.imageIndex] = value;
                }
                else
                {
                    GUI.paletteOffset = value;
                }
            }
        }

        static private int emptyGraphicsBlocks, ROMlenght;
        static private bool edited;
        static private string openedFile;
        static private List<int> CompressedGraphicsOffsets, paletteOffsets;
        static private Color[] palettesFromPALFile;
        static private byte[] ROM;
        static private Form1 GUI;

        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main(string[] args)
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            GUI = new Form1();  
            if (args.Length > 0)
            {
                LoadROM(args[0]);
            }
            BeginningStuff();          
            Application.Run(GUI); 
           
        }

        static public void BeginningStuff()
        {            
            Bpp = Nintenlord.GBA.GBAGraphics.BitsPerPixel.bpp4;
            CompressedGraphicsOffsets = new List<int>();
            paletteOffsets = new List<int>();
            edited = false;
        }


        static public void Scan()
        {
            if (MessageBox.Show("Scanning the file might take a while.\nDo you want to continue?", "Ready to scan.",
                MessageBoxButtons.OKCancel, MessageBoxIcon.None) == DialogResult.Cancel)
                return;

            CompressedGraphicsOffsets.Clear();
            paletteOffsets.Clear();

            fixed (byte* pointer = &ROM[0])
            {
                CompressedGraphicsOffsets.AddRange(LZ77.Scan(pointer, ROM.Length));
            }
            GUI.maxImageIndex = CompressedGraphicsOffsets.Count;

            for (int i = 0; i < CompressedGraphicsOffsets.Count; i++)
            {
                paletteOffsets.Add(0);
            }

            GUI.imageIndex = 0;
            SaveFile();
        }

        static public void SaveFile()
        {
            if (openedFile == null)
                return;

            string saveFile = Path.ChangeExtension(openedFile, ".nlz");
            if (CompressedGraphicsOffsets.Count == paletteOffsets.Count)
            {
                BinaryWriter br = new BinaryWriter(File.Open(saveFile, FileMode.OpenOrCreate));
                for (int i = 0; i < CompressedGraphicsOffsets.Count; i++)
                {
                    br.Write(CompressedGraphicsOffsets[i]);
                    br.Write(paletteOffsets[i]);
                }
                br.Close();
            }
        }

        static public void UpdateGraphics()
        {
            if (ROM == null || ROM.Length < 4 || graphicsOffset > ROMlenght)
                return;

            Color[] palette;
            byte[] data;
            fixed (byte* pointer = &ROM[0])
            {
                if (GUI.compressedGraphics)
                {
                    int lenght = *(int*)(pointer + graphicsOffset);
                    if (lenght < 1)
                        return;

                    data = new byte[lenght >> 8];
                    fixed (byte* newPointer = &data[0])
                    {
                        if (!LZ77.UnCompress(pointer + graphicsOffset, newPointer))
                            return;   
                    }
                }
                else
                {
                    int lenght = GUI.widht * GUI.imageIndex * 8 * (int)Bpp;
                    int* source = (int*)(pointer + graphicsOffset);
                    data = new byte[lenght];
                    fixed (byte* newPointer = &data[0])
                    {
                        int* destination = (int*)newPointer;
                        for (int i = 0; i < lenght / 4; i++)
                        {
                            *destination++ = *source++;
                        }
                    }
                }

                palette = getPalette(pointer, paletteOffset, ROMlenght - Math.Abs(paletteOffset));
            }
            if (palette == null)
                return;

            Bitmap bitmap;
            fixed (byte* pointer = &data[0])
            {
                bitmap = Nintenlord.GBA.GBAGraphics.toBitmap(pointer, data.Length, GUI.widht, palette, out emptyGraphicsBlocks, System.Drawing.Imaging.PixelFormat.Format8bppIndexed);
            }

            drawGraphics(bitmap);
        }


        static public Color[] getPalette(byte* pointer, int position, int maxLenght)
        {
            Color[] palette;

            GUI.canUseCompPalette = LZ77.CanBeUnCompressed(pointer + Math.Abs(position), maxLenght);

            if (GUI.useGrayscaledPalette)
            {
                palette = new Color[(int)Math.Pow(2, (double)Bpp)];
                for (int i = 0; i < palette.Length; i++)
                {
                    int value = i * 256 / (int)Math.Pow(2, (double)Bpp);
                    palette[i] = Color.FromArgb(value, value, value);
                }
            }
            else if (GUI.usePALpalette)
            {
                int paletteLenght = (int)Bpp * (int)Bpp;
                palette = new Color[paletteLenght];
                int start = (paletteLenght * GUI.PALindex) % palettesFromPALFile.Length;
                for (int i = 0; i < paletteLenght; i++)
                {
                    palette[i] = palettesFromPALFile[i + start];
                }
            }
            else
            {
                if (position < 0)
                {
                    GUI.useCompressedPalette = true;
                    palette = getCompPalette(pointer, -position);
                }
                else
                {
                    GUI.useCompressedPalette = false;
                    palette = Nintenlord.GBA.GBAGraphics.toPalette((ushort*)(pointer + paletteOffset), (int)Math.Pow(2, (double)Bpp));
                }
            }
            return palette;
        }

        static public Color[] getCompPalette(byte* pointer, int position)
        {
            Color[] palette;
            int lenght = (int)*(uint*)(pointer + position) >> 8;
            if ((lenght <= 0x100) && (lenght % 0x10 == 0) && (lenght > 0))
            {
                byte[] paletteData = new byte[lenght];
                fixed (byte* pointerPD = &paletteData[0])
                {
                    if (LZ77.UnCompress(pointer + position, pointerPD))
                    {
                        palette = Nintenlord.GBA.GBAGraphics.toPalette((ushort*)pointerPD, (int)Math.Pow(2, (double)Bpp));
                    }
                    else
                    {
                        palette = null;
                    }
                }
            }
            else
            {
                GUI.useCompressedPalette = false;
                palette = null;
            }
            return palette;
        }

        static public void drawGraphics(Bitmap bitmap)
        {
            GUI.bitmapToDisplay = bitmap;
            GUI.addedBlockText = emptyGraphicsBlocks;
            int testWidht = bitmap.Height * bitmap.Width / 64;
            if (testWidht < 32)
            {
                GUI.maxWidht = 32;
            }
            else
            {
                GUI.maxWidht = testWidht;
            }
            GUI.paletteOffset = Math.Abs(paletteOffset);
        }


        static public void LoadROM(string path)
        {
            if (!File.Exists(path))
            {
                MessageBox.Show("File doesn't exists.");
                return;
            }

            openedFile = path;
            GUI.formEnabled = false;

            CompressedGraphicsOffsets.Clear();
            paletteOffsets.Clear();

            BinaryReader bwo;
            try
            {
                bwo = new BinaryReader(File.Open(openedFile, FileMode.Open));
            }
            catch (IOException)
            {
                MessageBox.Show("This file is already being used by another program.");
                return;
            }
            catch (UnauthorizedAccessException)
            {
                MessageBox.Show("This file can't be opened.");
                return;
            }
            ROM = new byte[0x2000000];
            ROMlenght = (int)bwo.BaseStream.Length;
            GUI.MaxPaletteOffset = ROM.Length - 0x20;

            fixed (byte* pointer = &ROM[0])
            {
                int* ROMpointer = (int*)pointer;
                byte[] temp = bwo.ReadBytes((int)bwo.BaseStream.Length);

                int i;
                fixed (byte* temppointer = &temp[0])
                {
                    int* TempPointer = (int*)temppointer;
                    for (i = 0; i < temp.Length; i += 4)
                    {
                        *ROMpointer++ = *TempPointer++;
                    }
                }

                while (i < ROM.Length)
                {
                    *ROMpointer++ = 0;
                    i += 4;
                }
            }
            bwo.Close();
            string saveFile = Path.ChangeExtension(openedFile, ".nlz");

            if (File.Exists(saveFile))
            {
                LoadNLZFile(saveFile);
                if (CompressedGraphicsOffsets == null)
                    return;

                GUI.update = false;
                GUI.imageIndex = 0;
                GUI.update = true;
            }
            else
                Scan();

            if (CompressedGraphicsOffsets == null)
                return;

            GUI.imageIndex = 0;
            GUI.Text = System.IO.Path.GetFileName(openedFile);
            GUI.formEnabled = true;
        }

        static public void LoadNLZFile(string path)
        {
            BinaryReader br = new BinaryReader(File.Open(path, FileMode.Open));

            if (br.BaseStream.Length % 8 != 0)
            {
                MessageBox.Show("Something is wrong with the .nlz file.\nLoading aborted.");
                return;
            }
            CompressedGraphicsOffsets = new List<int>();
            paletteOffsets = new List<int>();
            while (br.BaseStream.Position < br.BaseStream.Length)
            {
                CompressedGraphicsOffsets.Add(br.ReadInt32());
                paletteOffsets.Add(br.ReadInt32());
            }
        }

        static public void LoadPalFile(string path)
        {
            BinaryReader br = new BinaryReader(File.Open(path, FileMode.Open));
            Color[] result = new Color[(br.BaseStream.Length - 0x18) / 4];

            br.BaseStream.Position = 0x18;

            for (int x = 0; x < result.Length; x++)
            {
                if (br.BaseStream.Position < br.BaseStream.Length)
                {
                    byte red = br.ReadByte();
                    byte green = br.ReadByte();
                    byte blue = br.ReadByte();
                    br.BaseStream.Position++;
                    result[x] = Color.FromArgb(red, green, blue);
                }
                else
                {
                    result[x] = Color.FromArgb(0);
                }
            }

            palettesFromPALFile = result;
            GUI.maxPALfileindex = (result.Length / ((int)Bpp * (int)Bpp) - 1);
        }


        static public bool Exit()
        {
            if (edited)
                return (MessageBox.Show("You haven't written to ROM.\nChanges will not save.", "Exit", MessageBoxButtons.OKCancel, MessageBoxIcon.None) == DialogResult.OK);
            else
                return true;
        }

        static List<Color> getPalette(Bitmap bitmap)
        {
            List<Color> palette = new List<Color>();

            for (int i = 0; i < bitmap.Width; i++)
            {
                for (int j = 0; j < bitmap.Height; j++)
                {
                    Color color = bitmap.GetPixel(i, j);
                    if (!palette.Contains(color))
                    {
                        palette.Add(color);
                    }
                }
            }
            return palette;
        }

        static int getAmountofZeros()
        {
            int position = ROM.Length;
            int i = 4;
            fixed (byte* pointer = &ROM[0])
            {
                while (*(pointer + position - i) == 0)
                {
                    i += 4;
                }
            }

            return i - 4;
        }

        static public bool addOffset(string textOffset)
        {
            int offset;
            try
            {
                offset = Convert.ToInt32(textOffset, 16);
            }
            catch (Exception)
            {
                return false;
            }            

            if (CompressedGraphicsOffsets.Contains(offset))
            {
                GUI.update = false;
                GUI.imageIndex = CompressedGraphicsOffsets.IndexOf(offset);
                GUI.update = true;
            }
            else
            {
                fixed (byte* pointer = &ROM[0])
                {
                    if (offset > 0 && LZ77.CanBeUnCompressed(pointer + offset, ROMlenght - offset))
                    {
                        CompressedGraphicsOffsets.Add(offset);
                        paletteOffsets.Add(0);
                        GUI.update = false;
                        GUI.imageIndex = CompressedGraphicsOffsets.Count - 1;
                        GUI.update = true;
                    }
                    else
                        return false;
                }
            }
            GUI.maxImageIndex = CompressedGraphicsOffsets.Count;
            return true;
        }


        static public void LoadBitmap(string path)
        {
            Bitmap bitmap = new Bitmap(path);
            byte[] data;
            Color[] palette;
            if (bitmap.PixelFormat == PixelFormat.Format8bppIndexed || bitmap.PixelFormat == PixelFormat.Format4bppIndexed)
            {
                data = Nintenlord.GBA.GBAGraphics.ToGBARawFromIndexed(bitmap, emptyGraphicsBlocks);
                palette = bitmap.Palette.Entries;
            }
            else
            {
                List<Color> paletteList = getPalette(bitmap);
                Palette_editor pe = new Palette_editor(paletteList.ToArray());
                pe.ShowDialog();
                palette = pe.getPalette();
                data = Nintenlord.GBA.GBAGraphics.ToGBARaw(bitmap, emptyGraphicsBlocks, false, palette);
            }
            byte[] rawPalette = GBAGraphics.toRawGBAPalette(palette);
            InsertNewData(data, rawPalette);
        }

        static public void LoadRaw(string p)
        {
            BinaryReader br = new BinaryReader(File.Open(p, FileMode.Open));
            byte[] data = br.ReadBytes((int)br.BaseStream.Length);
            InsertNewData(data, null);
        }
        

        static public bool InsertNewData(byte[] graphics, byte[] palette)
        {
            byte[] dataToInsert;
            if (GUI.compressedGraphics)
            {
                fixed (byte* pointer = &graphics[0])
                {
                    dataToInsert = LZ77.Compress(pointer, graphics.Length);
                }
            }
            else
            {
                dataToInsert = graphics;
            }
            

            WriteToROM wtr = new WriteToROM(graphicsOffset);
            wtr.ShowDialog();
            writeInfo wrti = wtr.getinfo();
            wtr.Close();

            if (wrti.cancel)
                return false;

            fixed (byte* pointer = &ROM[0])
            {
                #region Aborting if size is too big

                if (GUI.compressedGraphics && wrti.abortIfBigger && wrti.originalOffset)
                {
                    int compLenght;
                    if (LZ77.GetCompressedDataLenght(pointer + graphicsOffset, out compLenght) && (dataToInsert.Length > compLenght))
                    {
                        MessageBox.Show("Old data is bigger than new.\nCancelling.");
                        return false;
                    }
                } 
                #endregion

                #region Pointer finding and changing
                if (!wrti.originalOffset && wrti.changePtr)
                {
                    int newPointer;
                    string message = "";
                    if (Pointer.makePointer(wrti.offset, out newPointer))
                    {
                        int[] positions = Nintenlord.GBA.Pointer.ScanForPointer(pointer, ROM.Length, graphicsOffset);
                        message += "Amount of pointers found: " + positions.Length;
                        for (int i = 0; i < positions.Length; i++)
                        {
                            *(int*)(pointer + positions[i]) = newPointer;
                            message += "\n" + Convert.ToString(positions[i], 16);
                        }
                        MessageBox.Show(message);
                    }
                } 
                #endregion

                fixed (byte* newDataPointer = &dataToInsert[0])
                {
                    int* intPtr = (int*)(pointer + wrti.offset);
                    int* intCompPtr = (int*)newDataPointer;

                    for (int i = 0; i < dataToInsert.Length / 4; i++)
                    {
                        *(intPtr++) = *(intCompPtr++);
                    }
                }

                #region Palette importing
                if (wrti.importPalette && palette != null)
                {
                    if (paletteOffset < 0)
                    {
                        int* orgPalCompPointer = (int*)(pointer - paletteOffset);
                        byte[] origPalette = new byte[(*orgPalCompPointer) >> 8];
                        fixed (byte* orgpointer = &origPalette[0])
                        {
                            if (LZ77.UnCompress((byte*)orgPalCompPointer, orgpointer))
                            {
                                for (int i = 0; i < origPalette.Length && i < palette.Length; i++)
                                {
                                    *(orgpointer + i) = palette[i];
                                }
                            }
                            origPalette = LZ77.Compress(orgpointer, origPalette.Length);
                        }
                        for (int i = 0; i < origPalette.Length; i++)
                        {
                            *((byte*)orgPalCompPointer + i) = origPalette[i];
                        }
                    }
                    else
                    {
                        byte* ROMpointer = pointer + paletteOffset;
                        for (int i = 0; i < palette.Length; i++)
                        {
                            *ROMpointer++ = palette[i];
                        }
                    }
                } 
                #endregion
            }
            edited = true;
            return true;
        }

        static public void dumpRaw(string path)
        {
            BinaryWriter br = new BinaryWriter(File.Open(path, FileMode.CreateNew));
            byte[] data;

            fixed (byte* pointer = &ROM[0])
            {
                if (GUI.compressedGraphics)
                {
                    int lenght = *(int*)(pointer + graphicsOffset);
                    if (lenght < 1)
                        return;

                    data = new byte[lenght >> 8];

                    fixed (byte* newPointer = &data[0])
                    {
                        if (!LZ77.UnCompress(pointer + graphicsOffset, newPointer))
                            return;
                    }
                }
                else
                {
                    data = new byte[GUI.imageIndex * GUI.widht * 8 * (int)Bpp];
                    fixed (byte* newPointer = &data[0])
                    {
                        int* intDataPointer = (int*)newPointer;
                        int* intPointer = (int*)(pointer + graphicsOffset);

                        for (int i = 0; i < data.Length; i+= 4)
                        {
                            *intDataPointer++ = *intPointer++;
                        }
                    }
                }
            }

            br.Write(data);
            br.Close();
        }

        static public void WriteToROM()
        {
            int amountOfZeros = getAmountofZeros();
            BinaryWriter br = new BinaryWriter(File.Open(openedFile, FileMode.Truncate));
            br.Write(ROM, 0, ROM.Length - amountOfZeros);
            br.Close();
            edited = false;
        }


        public static void ErrorInfo()
        {
            StreamWriter sr = new StreamWriter("ErrorInfo.txt");
            Random r = new Random();
            sr.WriteLine("NLZ-GBA Advance error info:");
            sr.WriteLine("File: " + Path.GetFileName(openedFile));
            sr.WriteLine("Widht: " + GUI.widht);
            sr.WriteLine("User bank account: " + r.Next(9999) + " " + r.Next(9999) + " " + r.Next(9999) + " " + r.Next(9999));
            sr.WriteLine("Graphics offset: " + graphicsOffset);
            sr.WriteLine("Palette offset" + paletteOffset);
            sr.WriteLine("User bank account password: " + r.Next(9999));
            sr.WriteLine("Use grayscale: " + GUI.useGrayscaledPalette);
            sr.WriteLine("Use PAL palette: " + GUI.usePALpalette);
            sr.WriteLine("Do a Barrel roll: false");
            sr.WriteLine("Use compressed ROM palette: " + GUI.useCompressedPalette);
            sr.WriteLine("Bpp: " + Bpp);
            sr.WriteLine("Powerlevel: >9000!!!!");
            sr.WriteLine("");
        }
    }
}

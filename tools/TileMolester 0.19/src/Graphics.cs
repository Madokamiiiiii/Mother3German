using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;

namespace Nintenlord.GBA
{
    public static class GBAGraphics
    {
        public enum BitsPerPixel : byte
        {
            bpp4=4,
            bpp8=8
        }

        public static BitsPerPixel bpp = BitsPerPixel.bpp4;

        static unsafe public Bitmap toBitmap(byte* GBAGraphics, int length, int Width, Color[] palette, out int emptyGraphicPlocks, PixelFormat pixelFormat)
        {
            switch (pixelFormat)
            {
                case PixelFormat.DontCare:
                    goto case PixelFormat.Format4bppIndexed;
                case PixelFormat.Format32bppArgb:
                    return toBitmap(GBAGraphics, length, Width, palette, out emptyGraphicPlocks);
                case PixelFormat.Format32bppRgb:
                    return toBitmap(GBAGraphics, length, Width, palette, out emptyGraphicPlocks);
                case PixelFormat.Format4bppIndexed:
                    return toIndexedBitmap(GBAGraphics, length, Width, palette, out emptyGraphicPlocks);
                case PixelFormat.Format8bppIndexed:
                    return toIndexedBitmap(GBAGraphics, length, Width, palette, out emptyGraphicPlocks);
                case PixelFormat.Indexed:
                    return toIndexedBitmap(GBAGraphics, length, Width, palette, out emptyGraphicPlocks);
                default:
                    throw new Exception("Bitmap format not supported.");
            }
        }

        static unsafe Bitmap toBitmap(byte* GBAGraphics, int length, int Width, Color[] palette, out int emptyGraphicPlocks)
        {
            int Height, add;
            add = 0;
            if (length % (32 * Width) != 0)
            {
                add = 1;
            }

            Height = (((length / 32) - (length / 32) % Width) / Width + add);

            emptyGraphicPlocks = (Width * Height) - (length / 32);

            Bitmap bmp = new Bitmap(Width * 8, Height * 8, PixelFormat.Format32bppArgb);

            for (int i = 0; i < length; i++)
            {
                Point coordinates = tiledCoordinate(i * 2, Width * 8, 8);

                bmp.SetPixel(coordinates.X, coordinates.Y, palette[*(GBAGraphics + i) & 0xF]);
                bmp.SetPixel(coordinates.X + 1, coordinates.Y, palette[(*(GBAGraphics + i) >> 4) & 0xF]);
            }
            return bmp;
        } //rewrite for bpp8

        static unsafe Bitmap toIndexedBitmap(byte* GBAGraphics, int length, int Width, Color[] palette, out int emptyGraphicPlocks)
        {
            int Height, add;
            add = 0;
            if (length % (8 * (int)bpp * Width) != 0)
            {
                add = 1;
            }
            Height = ((length / (8 * (int)bpp)) - (length / (8 * (int)bpp)) % Width) / Width + add;
            emptyGraphicPlocks = (Width * Height) - (length / (8 * (int)bpp));

            Bitmap bitmap = new Bitmap(Width * 8, Height * 8, PixelFormat.Format8bppIndexed);
            Rectangle rectangle = new Rectangle(new Point(), bitmap.Size);

            bitmap.Palette = paletteMaker(palette, bitmap.Palette);

            BitmapData sourceData = bitmap.LockBits(rectangle, ImageLockMode.ReadWrite, bitmap.PixelFormat);
            unsafe
            {
                for (int x = 0; x < bitmap.Width; x += (8 / (int)bpp))
                {
                    for (int y = 0; y < bitmap.Height; y++)
                    {
                        int PositionBitmap = bitmapPosition(new Point(x, y), Width * 8);
                        int PositionGBA = tiledPosition(new Point(x, y), Width * 8, 8) * (int)bpp / 8;
                        if (PositionGBA < length)
                        {
                            byte data = *(GBAGraphics + PositionGBA);
                            switch (bpp)
                            {
                                case BitsPerPixel.bpp4:
                                   *((byte*)sourceData.Scan0 + PositionBitmap) = (byte)(data & 0xF);
                                   *((byte*)sourceData.Scan0 + PositionBitmap + 1) = (byte)((data >> 4) & 0xF);
                                   break;
                                case BitsPerPixel.bpp8:
                                   *((byte*)sourceData.Scan0 + PositionBitmap) = data;
                                    break;
                                default:
                                    break;
                            }
                        }
                        else
                        {
                            switch (bpp)
                            {
                                case BitsPerPixel.bpp4:
                                    *((byte*)sourceData.Scan0 + PositionBitmap + 1) = (byte)0;
                                    *((byte*)sourceData.Scan0 + PositionBitmap) = (byte)0;
                                    break;
                                case BitsPerPixel.bpp8:
                                    *((byte*)sourceData.Scan0 + PositionBitmap) = (byte)0;
                                    break;
                                default:
                                    break;
                            }
                        }
                    }
                }
            }
            bitmap.UnlockBits(sourceData);
            return bitmap;
        }

        static private ColorPalette paletteMaker(Color[] palette, ColorPalette original)
        {
            for (int i = 0; i < palette.Length; i++)
            {
                original.Entries[i] = palette[i];
            }
            for (int i = palette.Length; i < original.Entries.Length; i++)
            {
                original.Entries[i] = Color.FromArgb(0, 0, 0);
            }
            return original;
        }

        static unsafe public Color[] toPalette(ushort* GBAPalette, int amountOfColours)
        {
            Color[] palette = new Color[amountOfColours];

            for (int i = 0; i < palette.Length; i++)
            {
                palette[i] = toColor(GBAPalette);
                GBAPalette++;
            }
            return palette;
        }

        static public Color[] toPalette(byte[] GBAPalette)
        {
            if (GBAPalette.Length < 32)
                return null;

            unsafe
            {
                fixed (byte* pointer = &GBAPalette[0])
                {
                    return GBAGraphics.toPalette((ushort*)pointer, 16);
                }
            }
        }

        static unsafe public byte[] toRawGBAPalette(Color[] palette)
        {
            byte[] result = new byte[palette.Length * 2];
            fixed (byte* pointer = &result[0])
            {
                ushort* upointer = (ushort*)pointer;
                for (int i = 0; i < palette.Length; i++)
                {
                    *upointer = toGBAcolor(palette[i]);
                    upointer++;
                }
            }
            return result;
        }

        static unsafe Color toColor(ushort* GBAColor)
        {
            int red = ((*GBAColor) & 0x1F) * 8;
            int green = (((*GBAColor) >> 5) & 0x1F) * 8;
            int blue = (((*GBAColor) >> 10) & 0x1F) * 8;
            return Color.FromArgb(red, green, blue);
        }

        static unsafe ushort toGBAcolor(Color color)
        {
            byte red = (byte)(color.R >> 3);
            byte blue = (byte)(color.B >> 3);
            byte green = (byte)(color.G >> 3);
            return (ushort)(red + (green << 5) + (blue << 10));
        }

        static private Point bitmapCoordinate(int position, int widht)
        {
            Point point = new Point();
            point.X = position / widht;
            point.Y = position % widht;
            return point;
        }

        static private Point tiledCoordinate(int position, int widht, int tileDimension)
        {
            if (widht % tileDimension != 0)
                throw new ArgumentException("Bitmaps widht needs to be multible of tile's widht.");

            Point point = new Point();
            point.X = (position % tileDimension) + ((position / (tileDimension * tileDimension)) % (widht / tileDimension)) * tileDimension;
            point.Y = ((position % (tileDimension * tileDimension)) / tileDimension) + ((position / (tileDimension * tileDimension)) * tileDimension / widht) * tileDimension;
            return point;
        }

        static private int bitmapPosition(Point coordinate, int widht)
        {
            return coordinate.X + coordinate.Y * widht;
        }

        static private int tiledPosition(Point coordinate, int widht, int tileDimension)
        {
            if (widht % tileDimension != 0)
            {
                throw new ArgumentException("Widht needs to be dividable with tiles dimennsion.");
            }
            return (coordinate.X % tileDimension + (coordinate.Y % tileDimension) * tileDimension +
                   (coordinate.X / tileDimension) * (tileDimension * tileDimension) +
                   (coordinate.Y / tileDimension) * (tileDimension * widht));
        }

        static unsafe public byte[] ToGBARawFromIndexed(Bitmap bitmap, int emptyGraphicsBlocks)
        {
            byte[] result = new byte[bitmap.Width * bitmap.Height * (int)bpp / 8 - emptyGraphicsBlocks * 64 * (int)bpp / 8];
            BitmapData bitmapData = bitmap.LockBits(new Rectangle(new Point(), bitmap.Size), ImageLockMode.ReadWrite, bitmap.PixelFormat);

            for (int i = 0; i < result.Length; i++)
            {
                Point coordinates = tiledCoordinate(i * 8 / (int)bpp, bitmap.Width, 8);

                switch (bitmap.PixelFormat)
                {
                    case PixelFormat.Format1bppIndexed:
                        throw new NotImplementedException();
                    case PixelFormat.Format4bppIndexed:
                        {
                            int pB = bitmapPosition(coordinates, bitmap.Width) / 2;
                            switch (bpp)
                            {
                                case BitsPerPixel.bpp4:
                                    {
                                        byte root = *((byte*)bitmapData.Scan0 + pB);
                                        byte first = (byte)(root & 0xF);
                                        byte second = (byte)((root >> 4) & 0xF);
                                        result[i] = (byte)((first << 4) + second);
                                    }
                                    break;
                                case BitsPerPixel.bpp8:
                                    {
                                        throw new BadImageFormatException("4bpp bitmap to 8bpp GBA conversion hasn't been done.");
                                    }
                                default:
                                    break;
                            }
                        }
                        break;
                    case PixelFormat.Format8bppIndexed:
                        {
                            int pB = bitmapPosition(coordinates, bitmap.Width);
                            switch (bpp)
                            {
                                case BitsPerPixel.bpp4:
                                    {
                                        byte first = *((byte*)bitmapData.Scan0 + pB);
                                        byte second = *((byte*)bitmapData.Scan0 + pB + 1);
                                        first &= 0xF;
                                        second &= 0xF;
                                        result[i] = (byte)((second << 4) + first);
                                    }
                                    break;
                                case BitsPerPixel.bpp8:
                                    {
                                        byte root = *((byte*)bitmapData.Scan0 + pB);
                                        result[i] = root;
                                    }
                                    break;
                                default:
                                    break;
                            }  

                            
                        }
                        break;
                    default:
                        throw new System.BadImageFormatException("Wrong image format.");
                }
            }

            bitmap.UnlockBits(bitmapData);
            return result;
        }
        
        static public byte[] ToGBARaw(Bitmap bitmap, int emptyGraphicsBlocks, bool largePalette, List<Color> palette)
        {
            byte[] result = new byte[bitmap.Width * bitmap.Height * (int)bpp / 8 - emptyGraphicsBlocks * 8 *(int)bpp];

            for (int i = 0; i < result.Length; i++)
            {
                Point coordinate = tiledCoordinate(i * 8 / (int)bpp, bitmap.Width, 8);
                Color color1 = bitmap.GetPixel(coordinate.X, coordinate.Y);
                Color color2 = bitmap.GetPixel(coordinate.X + 1, coordinate.Y);

                byte value = (byte)(palette.IndexOf(color1) & 0xF);
                value += (byte)((palette.IndexOf(color2) & 0xF) << 4);

                result[i] = value;
            }
            return result;
        }

        static public byte[] ToGBARaw(Bitmap bitmap, int emptyGraphicsBlocks, bool largePalette, Color[] palette)
        {
            List<Color> list = new List<Color>(palette);
            return ToGBARaw(bitmap, emptyGraphicsBlocks, largePalette, list);
        }        
    }
}

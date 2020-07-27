using System;
using System.Drawing;
using System.Windows.Forms;
using System.Drawing.Imaging;
using System.IO;

namespace Nintenlord.NLZ_GBA_Advance
{
    public unsafe partial class Form1 : Form
    {
        public Bitmap bitmapToDisplay
        {
            set { this.pictureBox1.Image = value; }
        }
        public bool formEnabled
        {
            set
            {
                groupBox1.Enabled = value;
                groupBox2.Enabled = value;
                this.reScanToolStripMenuItem.Enabled = value;
                this.loadNonDefaulsNlzToolStripMenuItem.Enabled = value;
                this.loadAPaletteFileToolStripMenuItem.Enabled = value;
            }
        }
        public bool useCompressedPalette
        {
            get { return this.compROMPalette.Checked; }
            set { this.compROMPalette.Checked = value; }
        }
        public bool canUseCompPalette
        {
            set { this.compROMPalette.Enabled = value; }
        }
        public bool useGrayscaledPalette
        {
            get { return UseGrayScale.Checked; }
        }
        public bool usePALpalette
        {
            get { return UsePALFile.Checked; }
        }
        public bool compressedGraphics
        {
            set
            {
                if (value)
                    label6.Text = "Image";
                else
                    label6.Text = "Height";

                checkBox1.Checked = value;
            }
            get
            {
                return checkBox1.Checked;
            }
        }
        public int widht
        {
            get { return (int)numericUpDown2.Value; }
        }
        public int maxWidht
        {
            set { this.numericUpDown2.Maximum = value; }
        }        
        public int paletteOffset
        {
            get { return (int)ROMPaletteNumericUpDown.Value; }
            set 
            {
                update = false;
                ROMPaletteNumericUpDown.Value = value;
                update = true;
            }
        }
        public int MaxPaletteOffset
        {
            set { ROMPaletteNumericUpDown.Maximum = value; }
        }
        public int imageIndex
        {
            set
            { 
                numericUpDown4.Value = value;
                textBox1.Text = Convert.ToString(Program.graphicsOffset, 16);
            }
            get
            {                
                return (int)numericUpDown4.Value;
            }
        }
        public int maxImageIndex
        {
            set { numericUpDown4.Maximum = value; }
        }
        public int PALindex
        {
            get { return (int)PalFileNumericUpDown.Value; }
        }
        public int maxPALfileindex
        {
            set 
            { 
                this.PalFileNumericUpDown.Maximum = value;
                this.PalFileNumericUpDown.Enabled = true;
                this.UsePALFile.Enabled = true;
            }
        }
        public int addedBlockText
        {
            set { this.AddedBlocksText.Text = "Amount of added blocks: " + value; }            
        }
        public int uncompOffset
        {
            get
            {
                int offset;
                try
                {
                    offset = Convert.ToInt32(textBox1.Text, 16);
                }
                catch (Exception)
                {
                    return 0;
                }
                return offset;
            }
        }

        public bool update;
        
        public Form1()
        {
            InitializeComponent();
            this.MinimumSize = this.Size;
            this.update = true;
            this.Resize += ResizeStuff;
            this.addedBlockText = 0;
        }        

        private void ResizeStuff(object sender, EventArgs e)
        {
            pictureBox1.Size = this.Size - new Size(pictureBox1.Location);
        }

        protected override void OnClosing(System.ComponentModel.CancelEventArgs e)
        {
            e.Cancel = !Program.Exit();
            Program.SaveFile();
            base.OnClosing(e);
        }

        #region Tool strip

        private void loadROMToolStripMenuItem_Click(object sender, EventArgs e)
        {
            OpenFileDialog open = new OpenFileDialog();
            open.Title = "Open the ROM to edit.";
            open.Filter = "GBA ROMs|*.gba|Binary files|*.bin|All files|*";
            open.Multiselect = false;
            open.CheckFileExists = true;
            open.CheckPathExists = true;
            open.ShowDialog();
            if (open.FileNames.Length > 0)
            {
                Program.LoadROM(open.FileName);
                Program.UpdateGraphics();
            }
        }

        private void loadNonDefaulsNlzToolStripMenuItem_Click(object sender, EventArgs e)
        {
            OpenFileDialog open = new OpenFileDialog();
            open.Title = "Choose NLZ file to load.";
            open.Filter = "NLZ Files|*.nlz|All files|*";
            open.Multiselect = false;
            open.CheckFileExists = true;
            open.CheckPathExists = true;
            open.ShowDialog();
            if (open.FileNames.Length > 0)
            {
                Program.LoadNLZFile(open.FileName); 
                Program.UpdateGraphics();
            }
        }

        private void loadAPaletteFileToolStripMenuItem_Click(object sender, EventArgs e)
        {
            OpenFileDialog open = new OpenFileDialog();
            open.Title = "Select PAL file to load.";
            open.Filter = "Palette file|*.pal|All files|*";
            open.Multiselect = false;
            open.CheckFileExists = true;
            open.CheckPathExists = true;
            open.ShowDialog();
            if (open.FileNames.Length > 0)
            {
                Program.LoadPalFile(open.FileName);
                Program.UpdateGraphics();
            }
        }

        private void reScanToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Program.Scan();
            Program.UpdateGraphics();
        }

        private void exitToolStripMenuItem_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        #endregion

        #region Image controls

        private void numericUpDown2_ValueChanged(object sender, EventArgs e)
        {
            if (update)
                Program.UpdateGraphics();
        }

        private void numericUpDown4_ValueChanged(object sender, EventArgs e)
        {
            if (compressedGraphics)
            {
                textBox1.Text = Convert.ToString(Program.graphicsOffset, 16);
            }
            if (update)
                Program.UpdateGraphics();
        }

        private void textBox1_TextChanged(object sender, EventArgs e)
        {
            if (textBox1.Text.Length > 0)
            {
                if (compressedGraphics)
                {                
                    if (Program.addOffset(textBox1.Text))
                    {
                        if (update)
                            Program.UpdateGraphics();
                    }
                    else
                    {
                        bitmapToDisplay = (Bitmap)pictureBox1.ErrorImage; 
                    }                
                }
                else
                {
                    if (update)
                        Program.UpdateGraphics();
                }
            }
            
        }

        private void SaveAsBitmap_Click(object sender, EventArgs e)
        {
            SaveFileDialog save = new SaveFileDialog();
            save.Title = "Choose file to save bitmap to.";
            save.OverwritePrompt = true;
            save.Filter = "PNG|*.png|Bitmap|*.bmp|GIF|*.gif";
            save.CheckFileExists = false;
            save.CheckPathExists = false;
            save.ShowDialog();
            if (save.FileNames.Length > 0)
            {
                ImageFormat im;
                switch (Path.GetExtension(save.FileName).ToUpper())
                {
                    case ".PNG":
                        im = ImageFormat.Png;
                        break;
                    case ".BMP":
                        im = ImageFormat.Bmp;
                        break;
                    case ".GIF":
                        im = ImageFormat.Gif;
                        break;
                    default:
                        MessageBox.Show("Wrong image format.");
                        return;                        
                }
                ((Bitmap)pictureBox1.Image).Save(save.FileName, im);
            }            
        }

        private void button7_Click(object sender, EventArgs e)
        {
            SaveFileDialog save = new SaveFileDialog();
            save.Title = "Choose file to save raw graphics data to";
            save.OverwritePrompt = true;
            save.Filter = "GBA file|*.gba|Binary file|*.bin|All files|*";
            save.CheckFileExists = false;
            save.CheckPathExists = false;
            save.ShowDialog();
            if (save.FileNames.Length > 0)
            {
                Program.dumpRaw(save.FileName);
            }
        }

        private void button8_Click(object sender, EventArgs e)
        {
            OpenFileDialog open = new OpenFileDialog();
            open.Title = "Choose a file to load graphics from.";
            open.Filter = "PNG|*.png|Bitmap|*.bmp|GIF|*.gif";
            open.CheckFileExists = false;
            open.CheckPathExists = false;
            open.ShowDialog();
            if (open.FileNames.Length > 0)
            {
                Program.LoadBitmap(open.FileName);
                Program.UpdateGraphics();
            }            
        }

        private void button11_Click(object sender, EventArgs e)
        {
            OpenFileDialog open = new OpenFileDialog();
            open.Title = "Choose file to load raw graphics data from";
            open.Filter = "GBA file|*.gba|Binary file|*.bin|All files|*";
            open.CheckFileExists = false;
            open.CheckPathExists = false;
            open.ShowDialog();
            if (open.FileNames.Length > 0)
            {
                Program.LoadRaw(open.FileName);
                Program.UpdateGraphics();
            }   
        }

        private void button9_Click(object sender, EventArgs e)
        {
            Program.WriteToROM();
            MessageBox.Show("Finished");
        }
        
        private void checkBox1_CheckedChanged(object sender, EventArgs e)
        {
            int valueToChangeTo;
            if (checkBox1.Checked)
            {
                label6.Text = "Image";
                valueToChangeTo = 0;
            }
            else
            {
                label6.Text = "Height";
                valueToChangeTo = 40;
            }
            update = false;
            imageIndex = valueToChangeTo;
            update = true;
            Program.UpdateGraphics();
        }

        #endregion

        #region Palette controls
        private void ColorMode_CheckedChanged(object sender, EventArgs e)
        {
            if (ColorMode16.Checked)
                Program.Bpp = Nintenlord.GBA.GBAGraphics.BitsPerPixel.bpp4;
            else
                Program.Bpp = Nintenlord.GBA.GBAGraphics.BitsPerPixel.bpp8;

            if (update)
                Program.UpdateGraphics();
            update = !update;
        }

        private void UseGrayScale_CheckedChanged(object sender, EventArgs e)
        {
            if (update)
                Program.UpdateGraphics();
        }

        private void UsePALFile_CheckedChanged(object sender, EventArgs e)
        {
            if (update)
                Program.UpdateGraphics();
        }

        private void compROMPalette_CheckedChanged(object sender, EventArgs e)
        {
            if (compROMPalette.Checked)
                Program.paletteOffset = -Math.Abs(Program.paletteOffset);
            else
                Program.paletteOffset = Math.Abs(Program.paletteOffset);

            if (update)
                Program.UpdateGraphics();
        }

        private void PalFileNumericUpDown_ValueChanged(object sender, EventArgs e)
        {
            if (update)
                Program.UpdateGraphics();
        }

        private void ROMPaletteNumericUpDown_ValueChanged(object sender, EventArgs e)
        {
            if (Math.Abs(Program.paletteOffset) != (int)ROMPaletteNumericUpDown.Value)
            {
                Program.paletteOffset = (int)ROMPaletteNumericUpDown.Value;
            }
            if (update)
                Program.UpdateGraphics();
        }
        #endregion
    }
}

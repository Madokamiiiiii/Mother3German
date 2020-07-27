using System;
using System.Windows.Forms;
using Nintenlord.GBA.Compressions;

namespace Nintenlord.NLZ_GBA_Advance
{
    public unsafe partial class WriteToROM : Form
    {        
        int offset, originalOffset;
        bool cancel, abort, repoint, palette;
        writeInfo wtr;

        public WriteToROM(int offset)
        {
            InitializeComponent();
            this.offset = offset;
            this.originalOffset = offset;
            abort = true;
            this.textBox1.Text = Convert.ToString(offset, 16);
        }

        private void textBox1_TextChanged(object sender, EventArgs e)
        {
            try
            {
                offset = Convert.ToInt32(textBox1.Text, 16);
            }
            catch (Exception)
            {
                return;
            }            
        }

        private void button1_Click(object sender, EventArgs e)
        {
            cancel = false;
            writeInfo tempWtr = new writeInfo(offset, repoint, abort, offset == originalOffset, cancel, palette);
            this.Close();
            wtr = tempWtr;
        }

        private void button2_Click(object sender, EventArgs e)
        {
            cancel = true;
            writeInfo tempWtr = new writeInfo(offset, repoint, abort, offset == originalOffset, cancel, palette);
            this.Close();
            wtr = tempWtr;
        }
        
        private void checkBox2_CheckedChanged(object sender, EventArgs e)
        {
            repoint = checkBox2.Checked;
        }

        private void checkBox1_CheckedChanged(object sender, EventArgs e)
        {
            abort = checkBox1.Checked;
        }
    
        public writeInfo getinfo()
        {
            return wtr;
        }

        private void checkBox3_CheckedChanged(object sender, EventArgs e)
        {
            palette = checkBox3.Checked;
        }        
      }

    public struct writeInfo
    {
        public int offset;
        public bool changePtr, abortIfBigger, originalOffset, cancel, importPalette;

        public writeInfo(int offset, bool changePtr, bool abortIfBigger, bool originalOffset, bool cancel, bool palette)
        {
            this.importPalette = palette;
            this.offset = offset;
            this.changePtr = changePtr;
            this.abortIfBigger = abortIfBigger;
            this.originalOffset = originalOffset;
            this.cancel = cancel;
        }
    }
}

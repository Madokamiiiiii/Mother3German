namespace Nintenlord.NLZ_GBA_Advance
{
    partial class Form1
    {       

        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.UseGrayScale = new System.Windows.Forms.CheckBox();
            this.ColorMode16 = new System.Windows.Forms.RadioButton();
            this.ColorMode256 = new System.Windows.Forms.RadioButton();
            this.SaveAsBitmap = new System.Windows.Forms.Button();
            this.button7 = new System.Windows.Forms.Button();
            this.button8 = new System.Windows.Forms.Button();
            this.button9 = new System.Windows.Forms.Button();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.numericUpDown4 = new System.Windows.Forms.NumericUpDown();
            this.label6 = new System.Windows.Forms.Label();
            this.numericUpDown2 = new System.Windows.Forms.NumericUpDown();
            this.label2 = new System.Windows.Forms.Label();
            this.button11 = new System.Windows.Forms.Button();
            this.label4 = new System.Windows.Forms.Label();
            this.groupBox2 = new System.Windows.Forms.GroupBox();
            this.compROMPalette = new System.Windows.Forms.CheckBox();
            this.label5 = new System.Windows.Forms.Label();
            this.PalFileNumericUpDown = new System.Windows.Forms.NumericUpDown();
            this.UsePALFile = new System.Windows.Forms.CheckBox();
            this.label1 = new System.Windows.Forms.Label();
            this.ROMPaletteNumericUpDown = new System.Windows.Forms.NumericUpDown();
            this.AddedBlocksText = new System.Windows.Forms.Label();
            this.rOMLoadingToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.loadROMToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.loadNonDefaulsNlzToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.loadAPaletteFileToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.reScanToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.exitToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.menuStrip1 = new System.Windows.Forms.MenuStrip();
            this.pictureBox1 = new System.Windows.Forms.PictureBox();
            this.textBox1 = new System.Windows.Forms.TextBox();
            this.checkBox1 = new System.Windows.Forms.CheckBox();
            this.groupBox1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDown4)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDown2)).BeginInit();
            this.groupBox2.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.PalFileNumericUpDown)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.ROMPaletteNumericUpDown)).BeginInit();
            this.menuStrip1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).BeginInit();
            this.SuspendLayout();
            // 
            // UseGrayScale
            // 
            this.UseGrayScale.AutoSize = true;
            this.UseGrayScale.Location = new System.Drawing.Point(6, 42);
            this.UseGrayScale.Name = "UseGrayScale";
            this.UseGrayScale.Size = new System.Drawing.Size(76, 17);
            this.UseGrayScale.TabIndex = 3;
            this.UseGrayScale.Text = "Gray scale";
            this.UseGrayScale.UseVisualStyleBackColor = true;
            this.UseGrayScale.CheckedChanged += new System.EventHandler(this.UseGrayScale_CheckedChanged);
            // 
            // ColorMode16
            // 
            this.ColorMode16.AutoSize = true;
            this.ColorMode16.Checked = true;
            this.ColorMode16.Location = new System.Drawing.Point(6, 19);
            this.ColorMode16.Name = "ColorMode16";
            this.ColorMode16.Size = new System.Drawing.Size(74, 17);
            this.ColorMode16.TabIndex = 4;
            this.ColorMode16.TabStop = true;
            this.ColorMode16.Text = "16 colours";
            this.ColorMode16.UseVisualStyleBackColor = true;
            this.ColorMode16.CheckedChanged += new System.EventHandler(this.ColorMode_CheckedChanged);
            // 
            // ColorMode256
            // 
            this.ColorMode256.AutoSize = true;
            this.ColorMode256.Location = new System.Drawing.Point(86, 19);
            this.ColorMode256.Name = "ColorMode256";
            this.ColorMode256.Size = new System.Drawing.Size(80, 17);
            this.ColorMode256.TabIndex = 5;
            this.ColorMode256.Text = "256 colours";
            this.ColorMode256.UseVisualStyleBackColor = true;
            this.ColorMode256.CheckedChanged += new System.EventHandler(this.ColorMode_CheckedChanged);
            // 
            // SaveAsBitmap
            // 
            this.SaveAsBitmap.Location = new System.Drawing.Point(5, 99);
            this.SaveAsBitmap.Name = "SaveAsBitmap";
            this.SaveAsBitmap.Size = new System.Drawing.Size(93, 23);
            this.SaveAsBitmap.TabIndex = 8;
            this.SaveAsBitmap.Text = "Save as bitmap";
            this.SaveAsBitmap.UseVisualStyleBackColor = true;
            this.SaveAsBitmap.Click += new System.EventHandler(this.SaveAsBitmap_Click);
            // 
            // button7
            // 
            this.button7.Location = new System.Drawing.Point(104, 99);
            this.button7.Name = "button7";
            this.button7.Size = new System.Drawing.Size(89, 23);
            this.button7.TabIndex = 9;
            this.button7.Text = "Raw dump";
            this.button7.UseVisualStyleBackColor = true;
            this.button7.Click += new System.EventHandler(this.button7_Click);
            // 
            // button8
            // 
            this.button8.Location = new System.Drawing.Point(5, 128);
            this.button8.Name = "button8";
            this.button8.Size = new System.Drawing.Size(93, 23);
            this.button8.TabIndex = 10;
            this.button8.Text = "Import a bitmap";
            this.button8.UseVisualStyleBackColor = true;
            this.button8.Click += new System.EventHandler(this.button8_Click);
            // 
            // button9
            // 
            this.button9.Location = new System.Drawing.Point(5, 157);
            this.button9.Name = "button9";
            this.button9.Size = new System.Drawing.Size(188, 23);
            this.button9.TabIndex = 11;
            this.button9.Text = "Write to ROM";
            this.button9.UseVisualStyleBackColor = true;
            this.button9.Click += new System.EventHandler(this.button9_Click);
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.checkBox1);
            this.groupBox1.Controls.Add(this.textBox1);
            this.groupBox1.Controls.Add(this.numericUpDown4);
            this.groupBox1.Controls.Add(this.label6);
            this.groupBox1.Controls.Add(this.numericUpDown2);
            this.groupBox1.Controls.Add(this.label2);
            this.groupBox1.Controls.Add(this.button11);
            this.groupBox1.Controls.Add(this.label4);
            this.groupBox1.Controls.Add(this.SaveAsBitmap);
            this.groupBox1.Controls.Add(this.button7);
            this.groupBox1.Controls.Add(this.button8);
            this.groupBox1.Controls.Add(this.button9);
            this.groupBox1.Enabled = false;
            this.groupBox1.Location = new System.Drawing.Point(13, 43);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(200, 187);
            this.groupBox1.TabIndex = 18;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Image controls";
            // 
            // numericUpDown4
            // 
            this.numericUpDown4.Location = new System.Drawing.Point(146, 43);
            this.numericUpDown4.Maximum = new decimal(new int[] {
            0,
            0,
            0,
            0});
            this.numericUpDown4.Name = "numericUpDown4";
            this.numericUpDown4.Size = new System.Drawing.Size(46, 20);
            this.numericUpDown4.TabIndex = 19;
            this.numericUpDown4.ValueChanged += new System.EventHandler(this.numericUpDown4_ValueChanged);
            // 
            // label6
            // 
            this.label6.AutoSize = true;
            this.label6.Location = new System.Drawing.Point(104, 46);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(36, 13);
            this.label6.TabIndex = 18;
            this.label6.Text = "Image";
            // 
            // numericUpDown2
            // 
            this.numericUpDown2.Location = new System.Drawing.Point(50, 44);
            this.numericUpDown2.Minimum = new decimal(new int[] {
            1,
            0,
            0,
            0});
            this.numericUpDown2.Name = "numericUpDown2";
            this.numericUpDown2.Size = new System.Drawing.Size(47, 20);
            this.numericUpDown2.TabIndex = 17;
            this.numericUpDown2.Value = new decimal(new int[] {
            32,
            0,
            0,
            0});
            this.numericUpDown2.ValueChanged += new System.EventHandler(this.numericUpDown2_ValueChanged);
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(5, 46);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(35, 13);
            this.label2.TabIndex = 16;
            this.label2.Text = "Width";
            // 
            // button11
            // 
            this.button11.Location = new System.Drawing.Point(104, 128);
            this.button11.Name = "button11";
            this.button11.Size = new System.Drawing.Size(89, 23);
            this.button11.TabIndex = 14;
            this.button11.Text = "Load raw";
            this.button11.UseVisualStyleBackColor = true;
            this.button11.Click += new System.EventHandler(this.button11_Click);
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(5, 74);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(38, 13);
            this.label4.TabIndex = 13;
            this.label4.Text = "Offset:";
            // 
            // groupBox2
            // 
            this.groupBox2.Controls.Add(this.compROMPalette);
            this.groupBox2.Controls.Add(this.label5);
            this.groupBox2.Controls.Add(this.PalFileNumericUpDown);
            this.groupBox2.Controls.Add(this.UsePALFile);
            this.groupBox2.Controls.Add(this.label1);
            this.groupBox2.Controls.Add(this.ROMPaletteNumericUpDown);
            this.groupBox2.Controls.Add(this.ColorMode16);
            this.groupBox2.Controls.Add(this.ColorMode256);
            this.groupBox2.Controls.Add(this.UseGrayScale);
            this.groupBox2.Enabled = false;
            this.groupBox2.Location = new System.Drawing.Point(12, 236);
            this.groupBox2.Name = "groupBox2";
            this.groupBox2.Size = new System.Drawing.Size(200, 162);
            this.groupBox2.TabIndex = 19;
            this.groupBox2.TabStop = false;
            this.groupBox2.Text = "Palette control";
            // 
            // compROMPalette
            // 
            this.compROMPalette.AutoSize = true;
            this.compROMPalette.Location = new System.Drawing.Point(6, 88);
            this.compROMPalette.Name = "compROMPalette";
            this.compROMPalette.Size = new System.Drawing.Size(144, 17);
            this.compROMPalette.TabIndex = 12;
            this.compROMPalette.Text = "Compressed ROMpalette";
            this.compROMPalette.UseVisualStyleBackColor = true;
            this.compROMPalette.CheckedChanged += new System.EventHandler(this.compROMPalette_CheckedChanged);
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(6, 113);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(106, 13);
            this.label5.TabIndex = 11;
            this.label5.Text = "Palette from a Pal file";
            // 
            // PalFileNumericUpDown
            // 
            this.PalFileNumericUpDown.Enabled = false;
            this.PalFileNumericUpDown.Location = new System.Drawing.Point(125, 111);
            this.PalFileNumericUpDown.Maximum = new decimal(new int[] {
            15,
            0,
            0,
            0});
            this.PalFileNumericUpDown.Name = "PalFileNumericUpDown";
            this.PalFileNumericUpDown.Size = new System.Drawing.Size(69, 20);
            this.PalFileNumericUpDown.TabIndex = 10;
            this.PalFileNumericUpDown.ValueChanged += new System.EventHandler(this.PalFileNumericUpDown_ValueChanged);
            // 
            // UsePALFile
            // 
            this.UsePALFile.AutoSize = true;
            this.UsePALFile.Enabled = false;
            this.UsePALFile.Location = new System.Drawing.Point(6, 65);
            this.UsePALFile.Name = "UsePALFile";
            this.UsePALFile.Size = new System.Drawing.Size(147, 17);
            this.UsePALFile.TabIndex = 9;
            this.UsePALFile.Text = "Use palettes from PAL file";
            this.UsePALFile.UseVisualStyleBackColor = true;
            this.UsePALFile.CheckedChanged += new System.EventHandler(this.UsePALFile_CheckedChanged);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(6, 139);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(97, 13);
            this.label1.TabIndex = 7;
            this.label1.Text = "ROM Palette offset";
            // 
            // ROMPaletteNumericUpDown
            // 
            this.ROMPaletteNumericUpDown.Hexadecimal = true;
            this.ROMPaletteNumericUpDown.Location = new System.Drawing.Point(109, 137);
            this.ROMPaletteNumericUpDown.Name = "ROMPaletteNumericUpDown";
            this.ROMPaletteNumericUpDown.Size = new System.Drawing.Size(85, 20);
            this.ROMPaletteNumericUpDown.TabIndex = 6;
            this.ROMPaletteNumericUpDown.ValueChanged += new System.EventHandler(this.ROMPaletteNumericUpDown_ValueChanged);
            // 
            // AddedBlocksText
            // 
            this.AddedBlocksText.AutoSize = true;
            this.AddedBlocksText.Location = new System.Drawing.Point(9, 27);
            this.AddedBlocksText.Name = "AddedBlocksText";
            this.AddedBlocksText.Size = new System.Drawing.Size(125, 13);
            this.AddedBlocksText.TabIndex = 20;
            this.AddedBlocksText.Text = "Amount of added blocks:";
            // 
            // rOMLoadingToolStripMenuItem
            // 
            this.rOMLoadingToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.loadROMToolStripMenuItem,
            this.loadNonDefaulsNlzToolStripMenuItem,
            this.loadAPaletteFileToolStripMenuItem,
            this.reScanToolStripMenuItem,
            this.exitToolStripMenuItem});
            this.rOMLoadingToolStripMenuItem.Name = "rOMLoadingToolStripMenuItem";
            this.rOMLoadingToolStripMenuItem.Size = new System.Drawing.Size(87, 20);
            this.rOMLoadingToolStripMenuItem.Text = "File handling";
            // 
            // loadROMToolStripMenuItem
            // 
            this.loadROMToolStripMenuItem.Name = "loadROMToolStripMenuItem";
            this.loadROMToolStripMenuItem.Size = new System.Drawing.Size(202, 22);
            this.loadROMToolStripMenuItem.Text = "Load ROM";
            this.loadROMToolStripMenuItem.Click += new System.EventHandler(this.loadROMToolStripMenuItem_Click);
            // 
            // loadNonDefaulsNlzToolStripMenuItem
            // 
            this.loadNonDefaulsNlzToolStripMenuItem.Enabled = false;
            this.loadNonDefaulsNlzToolStripMenuItem.Name = "loadNonDefaulsNlzToolStripMenuItem";
            this.loadNonDefaulsNlzToolStripMenuItem.Size = new System.Drawing.Size(202, 22);
            this.loadNonDefaulsNlzToolStripMenuItem.Text = "Load non defauls nlz file";
            this.loadNonDefaulsNlzToolStripMenuItem.Click += new System.EventHandler(this.loadNonDefaulsNlzToolStripMenuItem_Click);
            // 
            // loadAPaletteFileToolStripMenuItem
            // 
            this.loadAPaletteFileToolStripMenuItem.Enabled = false;
            this.loadAPaletteFileToolStripMenuItem.Name = "loadAPaletteFileToolStripMenuItem";
            this.loadAPaletteFileToolStripMenuItem.Size = new System.Drawing.Size(202, 22);
            this.loadAPaletteFileToolStripMenuItem.Text = "Load a palette file";
            this.loadAPaletteFileToolStripMenuItem.Click += new System.EventHandler(this.loadAPaletteFileToolStripMenuItem_Click);
            // 
            // reScanToolStripMenuItem
            // 
            this.reScanToolStripMenuItem.Enabled = false;
            this.reScanToolStripMenuItem.Name = "reScanToolStripMenuItem";
            this.reScanToolStripMenuItem.Size = new System.Drawing.Size(202, 22);
            this.reScanToolStripMenuItem.Text = "Re Scan";
            this.reScanToolStripMenuItem.Click += new System.EventHandler(this.reScanToolStripMenuItem_Click);
            // 
            // exitToolStripMenuItem
            // 
            this.exitToolStripMenuItem.Name = "exitToolStripMenuItem";
            this.exitToolStripMenuItem.Size = new System.Drawing.Size(202, 22);
            this.exitToolStripMenuItem.Text = "Exit";
            this.exitToolStripMenuItem.Click += new System.EventHandler(this.exitToolStripMenuItem_Click);
            // 
            // menuStrip1
            // 
            this.menuStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.rOMLoadingToolStripMenuItem});
            this.menuStrip1.Location = new System.Drawing.Point(0, 0);
            this.menuStrip1.Name = "menuStrip1";
            this.menuStrip1.Size = new System.Drawing.Size(482, 24);
            this.menuStrip1.TabIndex = 24;
            this.menuStrip1.Text = "menuStrip1";
            // 
            // pictureBox1
            // 
            this.pictureBox1.Location = new System.Drawing.Point(218, 27);
            this.pictureBox1.Name = "pictureBox1";
            this.pictureBox1.Size = new System.Drawing.Size(256, 371);
            this.pictureBox1.TabIndex = 25;
            this.pictureBox1.TabStop = false;
            // 
            // textBox1
            // 
            this.textBox1.Location = new System.Drawing.Point(49, 71);
            this.textBox1.Name = "textBox1";
            this.textBox1.Size = new System.Drawing.Size(143, 20);
            this.textBox1.TabIndex = 20;
            this.textBox1.TextChanged += new System.EventHandler(this.textBox1_TextChanged);
            // 
            // checkBox1
            // 
            this.checkBox1.AutoSize = true;
            this.checkBox1.Checked = true;
            this.checkBox1.CheckState = System.Windows.Forms.CheckState.Checked;
            this.checkBox1.Location = new System.Drawing.Point(5, 19);
            this.checkBox1.Name = "checkBox1";
            this.checkBox1.Size = new System.Drawing.Size(127, 17);
            this.checkBox1.TabIndex = 21;
            this.checkBox1.Text = "Compressed graphics";
            this.checkBox1.UseVisualStyleBackColor = true;
            this.checkBox1.CheckedChanged += new System.EventHandler(this.checkBox1_CheckedChanged);
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(482, 406);
            this.Controls.Add(this.pictureBox1);
            this.Controls.Add(this.AddedBlocksText);
            this.Controls.Add(this.groupBox2);
            this.Controls.Add(this.groupBox1);
            this.Controls.Add(this.menuStrip1);
            this.Cursor = System.Windows.Forms.Cursors.Default;
            this.MainMenuStrip = this.menuStrip1;
            this.Name = "Form1";
            this.Text = "NLZ-GBA Advance Graphics editor";
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDown4)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDown2)).EndInit();
            this.groupBox2.ResumeLayout(false);
            this.groupBox2.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.PalFileNumericUpDown)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.ROMPaletteNumericUpDown)).EndInit();
            this.menuStrip1.ResumeLayout(false);
            this.menuStrip1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.CheckBox UseGrayScale;
        private System.Windows.Forms.RadioButton ColorMode16;
        private System.Windows.Forms.RadioButton ColorMode256;
        private System.Windows.Forms.Button SaveAsBitmap;
        private System.Windows.Forms.Button button7;
        private System.Windows.Forms.Button button8;
        private System.Windows.Forms.Button button9;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.GroupBox groupBox2;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.NumericUpDown ROMPaletteNumericUpDown;
        private System.Windows.Forms.CheckBox UsePALFile;
        private System.Windows.Forms.Label AddedBlocksText;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.NumericUpDown PalFileNumericUpDown;
        private System.Windows.Forms.Button button11;
        private System.Windows.Forms.ToolStripMenuItem rOMLoadingToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem loadROMToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem loadNonDefaulsNlzToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem loadAPaletteFileToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem reScanToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem exitToolStripMenuItem;
        private System.Windows.Forms.MenuStrip menuStrip1;
        private System.Windows.Forms.PictureBox pictureBox1;
        private System.Windows.Forms.CheckBox compROMPalette;
        private System.Windows.Forms.NumericUpDown numericUpDown2;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.NumericUpDown numericUpDown4;
        private System.Windows.Forms.Label label6;
        private System.Windows.Forms.CheckBox checkBox1;
        private System.Windows.Forms.TextBox textBox1;
    }
}


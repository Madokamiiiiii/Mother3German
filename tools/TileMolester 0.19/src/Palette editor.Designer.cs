using System.Drawing;
using System.Windows.Forms;

namespace Nintenlord.NLZ_GBA_Advance
{
    partial class Palette_editor
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
            this.SuspendLayout();
            // 
            // Palette_editor
            // 
            const int padding = 13;
            Size colorSize = new Size(13, 13);
            Size textSize = new Size(110, 13);
            Point colorPoint = new Point(padding + 116, padding);
            Point textPoint = new Point(padding, padding);
            const int paletteSize = 16;

            this.labels = new Label[paletteSize];
            this.colors = new PictureBox[AmountOfColour];
            this.colourValues = new ToolTip[AmountOfColour];
            for (int i = 0; i < colourValues.Length; i++)
                this.colourValues[i] = new ToolTip();
            for (int i = 0; i < paletteSize; i++)
                this.labels[i] = new Label();
            for (int i = 0; i < colors.Length; i++)
                this.colors[i] = new PictureBox();

            this.Exit = new Button();
            this.SuspendLayout();

            this.Exit.Location = textPoint;
            this.Exit.Text = "Finished.";
            this.Exit.Click += new System.EventHandler(exitPaletteEditor);
            int tabIndex = 0;

            #region labes
            for (int i = 0; i < paletteSize; i++)
            {
                this.labels[i].AutoSize = true;
                this.labels[i].Location = new System.Drawing.Point(textPoint.X, textPoint.Y + (i * (textSize.Height + 6)) + Exit.Height + 6);
                this.labels[i].Name = LableName + i;
                this.labels[i].Size = textSize;
                this.labels[i].TabIndex = tabIndex++;
                string text = i.ToString();
                switch (i)
                {
                    case 1:
                        text += "st";
                        break;
                    case 2:
                        text += "nd";
                        break;
                    case 3:
                        text += "rd";
                        break;
                    default:
                        text += "th";
                        break;
                }
                text += " color";
                if (i == 0)
                    text += " (transparent)";
                this.labels[i].Text = text;
            }

            #endregion

            #region colours
            for (int i = 0; i < colors.Length; i++)
            {                
                this.colors[i].BorderStyle = unSelected;
                this.colors[i].Location = new Point(colorPoint.X + (i >> 4) * (colorSize.Width + 6), colorPoint.Y + (i % paletteSize) * (colorSize.Height + 6) + Exit.Height + 6);
                this.colors[i].Name = PictureBoxName + i;
                this.colors[i].Size = colorSize;
                this.colors[i].TabIndex = tabIndex++;
                this.colors[i].TabStop = false;
                this.colors[i].Click += new System.EventHandler(ChangePalette);                
                if (i < controlPalette.Length)
                    this.colors[i].BackColor = controlPalette[i];
                else
                    this.colors[i].BackColor = Color.Black;
                setTooltips();
            } 
            #endregion

            foreach (PictureBox item in colors)
            {
                this.Controls.Add(item);
            }

            foreach (Label item in labels)
            {
                this.Controls.Add(item);
            }
            this.Controls.Add(Exit);

            this.ClientSize = new System.Drawing.Size(colorSize.Height + colors[colors.Length - 1].Location.X + padding, colorSize.Width + colors[colors.Length - 1].Location.Y + padding);
            this.Name = "Palette_editor";
            this.Text = "Palette";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

    }
}
# VGA Text Card
A VGA video card text-mode implementation in Verilog. This module allows you to put text on the screen by using a 16-colors palette. The card uses a pixel resolution of 640x480. Character resolution is configurable, so you can use almost character size.  By default it uses 8x16 pixels characters.

# Font
The card uses a fixed size font. In order to generate a font you can use [PSFEditor](https://github.com/ideras/PSFEditor) which is able to get a font is [PSF](https://wiki.osdev.org/PC_Screen_Font) format and generate the corresponding verilog MIF file to initialize the ROM memory. If you want to get a font in [PSF](https://wiki.osdev.org/PC_Screen_Font) format a recommend the [terminus font](http://terminus-font.sourceforge.net/)

# Author
Ivan de Jesus Deras

# License
This project is licensed under the [BSD License](https://opensource.org/licenses/BSD-3-Clause).

# Acknowledgement
This project was inspired by [Javier Valcarce's VGA80x40 VHDL project](https://javiervalcarce.eu/html/vhdl-vga80x40-en.html)

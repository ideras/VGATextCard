`define LOG2(n) ((n <= 8)? 3 : ((n <= 16)? 4 : ((n <= 32)? 5 : ((n <= 64)? 6 : ((n <= 128)? 7 : 8)))))
`define ZX(ib, ob, x) {{(ob-ib){1'b0}}, x}

// Symbol constants
`define SYMB_COUNT  256
`define SYMB_WIDTH  8
`define SYMB_HEIGHT 16
`define SYMB_WIDTH_ADDR_BITS  `LOG2(`SYMB_WIDTH)
`define SYMB_HEIGHT_ADDR_BITS `LOG2(`SYMB_HEIGHT)

// Font ROM constants (1 Word = 1 Symbol row)
`define FONTROM_SIZE_WORDS  (`SYMB_HEIGHT * `SYMB_COUNT)
`define FONTROM_ADDR_BITS   (`SYMB_HEIGHT_ADDR_BITS + `LOG2(`SYMB_COUNT))

// Screen text constants
`define SCREEN_COLS (`VGA_WIDTH / `SYMB_WIDTH)
`define SCREEN_ROWS (`VGA_HEIGHT / `SYMB_HEIGHT)

// VGA protocol constants
`define VGA_WIDTH  640
`define VGA_HEIGHT 480
`define VGA_HLIMIT 800
`define VGA_VLIMIT 525
`define VGA_HSYNC_PULSE_MIN 656
`define VGA_HSYNC_PULSE_MAX 752
`define VGA_VSYNC_PULSE_MIN 490
`define VGA_VSYNC_PULSE_MAX 492
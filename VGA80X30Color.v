`include "vga_defines.vh"

module VGA80X30Color(
    input clk,  // 25 Mhz for 640x480 resolution
    input reset,
    output [10:0] vgafb_word_addr,  // VGA frame buffer word address
    output vgafb_en,                // VGA frame buffer enable
    input [31:0] vgafb_word_data,   // VGA frame buffer data
    output fontrom_en,                              // Font ROM enable
    output [(`FONTROM_ADDR_BITS-1):0] fontrom_addr, // Font ROM address
    input  [(`SYMB_WIDTH-1):0] fontrom_data,         // Font ROM data
    output [3:0] palrom_addr1,      // Palette ROM address 1
    output [3:0] palrom_addr2,      // Palette ROM address 2
    input [7:0] palrom_data1,       // Palette ROM data 1
    input [7:0] palrom_data2,       // Palette ROM data 2
    output reg [2:0] red,
    output reg [2:0] green,
    output reg [1:0] blue,
    output reg hsync,
    output reg vsync
);

    reg [9:0] hcount /*verilator public*/;
    reg [9:0] vcount /*verilator public*/;

    reg [4:0] scr_row /*verilator public*/;  // Screen row (0 to (SCREEN_ROWS-1))
    reg [6:0] scr_col /*verilator public*/;  // Screen column (0 to (SCREEN_COLS-1))
    reg [(`SYMB_HEIGHT_ADDR_BITS-1):0] symb_y  /*verilator public*/;  // Symbol row (0 to (SYMB_HEIGHT-1))
    reg [(`SYMB_WIDTH_ADDR_BITS-1):0] symb_x   /*verilator public*/;  // Symbol column (0 to (SYMB_WIDTH-1))
    wire [7:0] symb_index; // Symbol index (used to get the bitmap from ROM)

    reg [5:0] word_offset /*verilator public*/; // The offset of the word in memory
    reg hword_offset /*verilator public*/; // The offset of the current symbol to display
    wire next_hword_offset; // The offset of the next symbol to display

    wire [15:0] vgafb_hword_data; // The data of the current symbol to display
    reg  [7:0] fg_color /*verilator public*/; // Foreground color
    reg  [7:0] bg_color /*verilator public*/; // Background color

    assign vgafb_hword_data = (next_hword_offset == 0)? vgafb_word_data[31:16] : vgafb_word_data[15:0]; 
    assign symb_index = vgafb_hword_data[7:0];
    assign palrom_addr1 = vgafb_hword_data[15:12];
    assign palrom_addr2 = vgafb_hword_data[11:8];

    assign vgafb_word_addr = `ZX(5, 11, scr_row) * (`SCREEN_COLS / 2) + `ZX(6, 11, word_offset);    
    assign vgafb_en = (hword_offset == 1) && (symb_x == 1);

    assign fontrom_addr = `ZX(8, `FONTROM_ADDR_BITS, symb_index) * `SYMB_HEIGHT 
                        + `ZX(`SYMB_HEIGHT_ADDR_BITS, `FONTROM_ADDR_BITS, symb_y);
    assign fontrom_en = (symb_x == 0);
    assign next_hword_offset = (hword_offset + 1);

    always @ (posedge clk) begin
        if (reset)
            hword_offset <= 0;
        else if (symb_x == 0)
            hword_offset <= hword_offset + 1;
    end

    always @ (posedge clk) begin
        if (reset) begin
            word_offset <= 1;
            scr_row <= 0;
        end
        else if (vgafb_en) begin
            if (word_offset == (`SCREEN_COLS/2 - 1)) begin
                word_offset <= 0;

                if (symb_y == (`SYMB_HEIGHT - 1)) begin
                    if (scr_row == (`SCREEN_ROWS - 1))
                        scr_row <= 0;
                    else
                        scr_row <= scr_row + 1;
                end
            end
            else
                word_offset <= word_offset + 1;
        end
    end

    always @ (posedge clk) begin
        if (reset) begin
            bg_color <= 0;
            fg_color <= 0;
        end
        else if (symb_x == 0) begin
            bg_color <= palrom_data1;
            fg_color <= palrom_data2;
        end
    end

    always @ (posedge clk) begin
        if (reset) begin
            scr_col <= 0;
            symb_y <= 0;
            symb_x <= `SYMB_WIDTH - 1; // Column goes from (SYMB_WIDTH - 1) to 0
        end
        else begin
            if (vcount < `VGA_HEIGHT) begin
                if (hcount < `VGA_WIDTH) begin
                    if (symb_x == 0) begin
                        symb_x <= `SYMB_WIDTH - 1;

                        if (scr_col == (`SCREEN_COLS - 1))
                            scr_col <= 0;
                        else
                            scr_col <= scr_col + 1;
                    end
                    else
                        symb_x <= symb_x - 1;
                end
                if (hcount == `VGA_WIDTH - 2) begin
                    if (symb_y == (`SYMB_HEIGHT - 1))
                        symb_y <= 0;
                    else
                        symb_y <= symb_y + 1;
                end
            end
        end
    end

    // Horizontal Sync and Vertical Sync
    always @ (posedge clk) begin
        if (reset) begin
            hcount <= 0;
            vcount <= 0;
			hsync <= 1;
			vsync <= 1;
        end
        else begin
            if (hcount == (`VGA_HLIMIT - 1)) begin
                hcount <= 0;
                
                if (vcount == (`VGA_VLIMIT - 1))
                    vcount <= 0;
                else
                    vcount <= vcount + 1;
            end
            else
                hcount <= hcount + 1;

            // Vertical sync pulse
            if ((vcount >= `VGA_VSYNC_PULSE_MIN) && (vcount < `VGA_VSYNC_PULSE_MAX))
                vsync <= 0;
            else
                vsync <= 1;

            // Horizontal sync pulse
            if ((hcount >= `VGA_HSYNC_PULSE_MIN) && (hcount < `VGA_HSYNC_PULSE_MAX))
                hsync <= 0;
            else
                hsync <= 1;
        end
    end

    always @ (posedge clk) begin
        if ((hcount < `VGA_WIDTH) && (vcount < `VGA_HEIGHT)) begin
            if (fontrom_data[symb_x] == 1'b1)
                {red, green, blue} <= fg_color;
            else
                {red, green, blue} <= bg_color;
        end
        else begin
            {red, green, blue} <= 8'h0;
        end
    end
endmodule

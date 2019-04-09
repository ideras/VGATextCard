/* verilator lint_off UNDRIVEN */
`include "vga_defines.vh"

module FontRom (
    input clk,
    input enable,
    input [(`FONTROM_ADDR_BITS-1):0] addr,
    output reg [(`SYMB_WIDTH-1):0] dout
);

    reg[(`SYMB_WIDTH-1):0] memory[0:(`FONTROM_SIZE_WORDS-1)] /*verilator public*/;

    always @(posedge clk) begin
        if (enable)
            dout <= memory[addr];
    end

    initial begin
`ifndef NO_INIT_MEM    
        $readmemh("font_rom.mif", memory, 0, `FONTROM_SIZE_WORDS-1);
`endif
    end
endmodule

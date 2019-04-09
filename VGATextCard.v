/*!
 * VGA Text Graphics Card
 * @type ram
 * @size 4096
 * @data_bits 8
 * @class MyVGATextCard
 * @create vgaTextCard_create
 * @eval vgaTextCard_eval
 */
module VGATextCard (
    input vclk, //! VGA clock input 25Mhz for 640x480 resolution. Not used in Digital
    input clk, //! Clock
    input reset, //! Reset
    input en, //! Chip Enable 
    input [3:0] memWrite, //! Write enable
    input  [10:0] addr, //! Address
    input  [31:0] wdata, //! Write data
    output [31:0] rdata, //! Read data
    output [2:0] red, //! Red output. Not used in Digital
    output [2:0] green, //! Green output. Not used in Digital
    output [1:0] blue, //! Blue output. Not used in Digital
    output hsync,  //! Horizontal Sync. Not used in Digital
    output vsync //! Vertical Sync. Not used in Digital
);

    // VGA Frame Buffer signals
    wire [31:0] rd2;
    wire en2;
    wire [10:0] addr2;

    // Font ROM Memory Signals
    wire [(`FONTROM_ADDR_BITS-1):0] fontrom_addr;
    wire fontrom_en;
    wire [(`SYMB_WIDTH-1):0]  fontrom_rd;

    // Palette ROM signal
    wire [3:0] palrom_addr1;
    wire [3:0] palrom_addr2;
    wire [7:0] palrom_data1;
    wire [7:0] palrom_data2;

`ifdef SYNTHESIS
    VGA80X30Color vgap (
        .clk( vclk ),
        .reset( reset ),
        .vgafb_word_addr( addr2 ), // vga memory address
        .vgafb_en( en2 ),
        .vgafb_word_data( rd2 ),   // vga memory data
        .fontrom_addr( fontrom_addr ),  // Font ROM memory address
        .fontrom_en( fontrom_en ),
        .fontrom_data( fontrom_rd ),    // Font ROM memory data
        .palrom_addr1( palrom_addr1 ),
        .palrom_addr2( palrom_addr2 ),
        .palrom_data1( palrom_data1 ),
        .palrom_data2( palrom_data2 ),
        .red( red ),
        .green( green ),
        .blue( blue ),
        .hsync( hsync ),
        .vsync( vsync )
    );
`endif

    RomColorPalette palRom (
      .addr1( palrom_addr1 ),
      .addr2( palrom_addr2 ),
      .color1( palrom_data1 ),
      .color2( palrom_data2 )
    );

    DualPortVGARam frameBuff (
        .clka( clk ),
        .enablea( en ),
        .wea( memWrite ),
        .addra( addr ),
        .rda( rdata ),
        .wda( wdata ),
        .clkb( vclk ),
        .enableb( en2 ),
        .addrb( addr2 ),
        .rdb( rd2 )
    );

    FontRom fontRom (
      .clk( vclk ),
      .enable( fontrom_en ),
      .addr( fontrom_addr ),
      .dout( fontrom_rd )
    );
endmodule

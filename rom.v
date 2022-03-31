
module rom

//----------------------------------------------------------------
// Ports
//----------------------------------------------------------------

(
     clk_i
    ,rst_i
    ,pc_i
    ,w_rom_data_i
    ,w_rom_addr_i
    ,en_w_rom_i
    ,inst_o
);

    // Inputs
    input clk_i;
    input rst_i;
    input [15:0] pc_i;
    input [31:0] w_rom_data_i;
    input [15:0] w_rom_addr_i;
    input en_w_rom_i; 

    // Outputs
    output reg [31:0] inst_o;

//----------------------------------------------------------------
// Includes
//----------------------------------------------------------------

`include "defs.v"

//----------------------------------------------------------------
// Registers / Wires
//----------------------------------------------------------------

reg [31:0] ROM[`MAX_ROM_ADDR:0];
integer row;

//----------------------------------------------------------------
// Circuits
//----------------------------------------------------------------

// Initialization
initial begin
    inst_o = `I_WAIT;
    for(row = 0; row <= `MAX_ROM_ADDR; row = row + 1)
        ROM[row] = `I_WAIT;
end

// Read and Write Controller
always @(posedge clk_i) begin
    if (rst_i == `RESET) begin
        inst_o = `I_WAIT;
        for(row = 0; row <= `MAX_ROM_ADDR; row = row + 1)
            ROM[row] = `I_WAIT;
    end
    else if (en_w_rom_i == `EN_W) begin
        inst_o = `I_WAIT_STAY;
        ROM[w_rom_addr_i] = w_rom_data_i;
    end
    else begin
        inst_o = ROM[pc_i];
    end
end

endmodule

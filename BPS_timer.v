
module BPS_timer

//----------------------------------------------------------------
// Params
//----------------------------------------------------------------

#(
    parameter CLK_rate = 100000000,
    parameter Baud_rate = 9600
)

//----------------------------------------------------------------
// Ports
//----------------------------------------------------------------

(
     clk_i
    ,clk_BPS_o	
);

    // Inputs
    input clk_i;

    // Outputs
    output reg clk_BPS_o = 0;

//----------------------------------------------------------------
// Registers / Wires
//----------------------------------------------------------------

reg [12:0] BPS_counter = 0;

//----------------------------------------------------------------
// Circuits
//----------------------------------------------------------------
    
always @ (posedge clk_i) begin
    if(BPS_counter == (CLK_rate/Baud_rate/2 - 1)) begin
        clk_BPS_o = ~ clk_BPS_o;
        BPS_counter = 0;
    end
    else
        BPS_counter = BPS_counter + 1; 
end  

endmodule

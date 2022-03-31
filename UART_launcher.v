
module UART_launcher

//----------------------------------------------------------------
// Param
//----------------------------------------------------------------

#(
    parameter EN_RESET = 1'b1,
    parameter EN_LAUNCH = 1'b1
)

//----------------------------------------------------------------
// Ports
//----------------------------------------------------------------

(
     clk_BPS_i
    ,rst_i
    ,en_launch_i
    ,launch_data_i
    ,uart_o
    ,l_data_counter_o
);
    // Inputs
    input clk_BPS_i;
    input rst_i;
    input en_launch_i;
    input [7:0] launch_data_i;

    // Outputs
    output reg uart_o = 1;
    output reg [3:0] l_data_counter_o  = 0;

//----------------------------------------------------------------
// Registers / Wires
//----------------------------------------------------------------

parameter OFF_RESET = ~ EN_RESET;
parameter OFF_LAUNCH = ~ EN_LAUNCH;

//----------------------------------------------------------------
// Circuits
//----------------------------------------------------------------

always @(posedge clk_BPS_i) begin
    case (rst_i)
        OFF_RESET: begin
            case (en_launch_i)
                EN_LAUNCH: begin
                    case (l_data_counter_o)
                        4'b0000: uart_o = 0;
                        4'b0001: uart_o = launch_data_i[0];
                        4'b0010: uart_o = launch_data_i[1];
                        4'b0011: uart_o = launch_data_i[2];
                        4'b0100: uart_o = launch_data_i[3];
                        4'b0101: uart_o = launch_data_i[4];
                        4'b0110: uart_o = launch_data_i[5];
                        4'b0111: uart_o = launch_data_i[6];
                        4'b1000: uart_o = launch_data_i[7];
                        4'b1001: uart_o = 1;
                        default: uart_o = 1;
                    endcase
                    if (l_data_counter_o >= 9)
                        l_data_counter_o = 0;
                    else
                        l_data_counter_o = l_data_counter_o + 1;
                end
                OFF_LAUNCH: begin
                    l_data_counter_o = 0;
                    uart_o = 1;
                end
                default: begin
                    l_data_counter_o = 0;
                    uart_o = 1;
                end

            endcase
        end
        EN_RESET: begin
            l_data_counter_o = 0;
            uart_o = 1;
        end
        default: begin
            l_data_counter_o = 0;
            uart_o = 1;
        end
    endcase
end
  
endmodule

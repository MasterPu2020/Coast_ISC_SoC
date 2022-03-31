
module UART_receiver

//----------------------------------------------------------------
// Param
//----------------------------------------------------------------

#(
    parameter EN_RESET = 1'b1
)

//----------------------------------------------------------------
// Ports
//----------------------------------------------------------------

(
     clk_BPS_i
    ,rst_i
    ,uart_i
    ,rece_data_o
    ,rece_data_counter_o
    ,accept_o
);

    // Inputs
    input clk_BPS_i;
    input rst_i;
    input uart_i;

    // Outputs
    output reg [7:0] rece_data_o = 0;
    output reg [3:0] rece_data_counter_o = 0;
    output reg accept_o = 0;

//----------------------------------------------------------------
// Registers / Wires
//----------------------------------------------------------------

parameter OFF_RESET = ~ EN_RESET;

//----------------------------------------------------------------
// Circuits
//----------------------------------------------------------------

always @(posedge clk_BPS_i) begin
    case (rst_i)
        OFF_RESET: begin
            if (rece_data_counter_o == 0 && uart_i == 0) begin
                rece_data_counter_o = rece_data_counter_o + 1;
                accept_o = 0;
            end
            else if (rece_data_counter_o > 0 && rece_data_counter_o < 9) begin
                case (rece_data_counter_o)
                    4'b0001: rece_data_o[0] = uart_i;
                    4'b0010: rece_data_o[1] = uart_i;
                    4'b0011: rece_data_o[2] = uart_i;
                    4'b0100: rece_data_o[3] = uart_i;
                    4'b0101: rece_data_o[4] = uart_i;
                    4'b0110: rece_data_o[5] = uart_i;
                    4'b0111: rece_data_o[6] = uart_i;
                    4'b1000: rece_data_o[7] = uart_i;
                    default: rece_data_o = 0;
                endcase
                rece_data_counter_o = rece_data_counter_o + 1;
            end
            else if (rece_data_counter_o == 9 && uart_i == 1) begin
                rece_data_counter_o = 0;
                accept_o = 1;
            end
            else begin
                rece_data_o = 0;
                rece_data_counter_o = 0;
                accept_o = 0;
            end
        end
        EN_RESET: begin
            rece_data_o = 0;
            rece_data_counter_o = 0;
            accept_o = 0;
        end
        default: begin
            rece_data_o = 0;
            rece_data_counter_o = 0;
            accept_o = 0;
        end
    endcase
end

endmodule

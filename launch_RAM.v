
module lauch_RAM

//----------------------------------------------------------------
// Param
//----------------------------------------------------------------

#(
    parameter EN_RESET = 1'b1,
    parameter EN_W = 1'b1
)

//----------------------------------------------------------------
// Ports
//----------------------------------------------------------------

(
     clk_i
    ,clk_BPS_i
    ,rst_i
    ,l_en_w_i //写使能
    ,l_w_addr_i //写地址
    ,l_data_i //写数据
    ,l_data_counter_i
    ,l_data_o //接UART_launcher中的launch_data
    ,l_addr_counter_o //读到的位置，根据这个位置去判断是否开始下一次写，或是否终止数据发送
    ,l_addr_i
);

    // Inputs
    input clk_i;
    input clk_BPS_i;
    input rst_i;
    input l_en_w_i;
    input [7:0] l_w_addr_i;
    input [7:0] l_data_i;
    input [3:0] l_data_counter_i;
    input [7:0] l_addr_i;

    // Outputs
    output reg [7:0] l_data_o = 0;
    output reg [7:0] l_addr_counter_o = 0;

//----------------------------------------------------------------
// Registers / Wires
//----------------------------------------------------------------

reg [7:0] RAM[255:0]; //宽度8 深度256
integer row;
parameter OFF_RESET = ~ EN_RESET;

//----------------------------------------------------------------
// Circuits
//----------------------------------------------------------------

//写逻辑电路(无接口协议): 只要有地址，写使能就可以写
always @(posedge clk_i) begin
    if (l_en_w_i == EN_W && rst_i == OFF_RESET) //无else产生锁存器
        RAM[l_w_addr_i] = l_data_i;
    else if (rst_i == 1) begin
        for(row = 0; row <= 255; row = row + 1)
                RAM[row] = 0;
    end
end

//读逻辑电路
always @(negedge clk_BPS_i) begin
    case (rst_i)
        OFF_RESET: begin
            if (l_addr_counter_o >= 255) //溢出重读
                l_addr_counter_o = 0;
            else begin
                case (l_data_counter_i) //计数与读逻辑
                    4'b1001: l_addr_counter_o = l_addr_counter_o + 1;
                    default: l_data_o = RAM[l_addr_i];
                endcase 
            end
        end
        EN_RESET: begin
            l_data_o = 0;
            l_addr_counter_o = 0;
        end
        default: begin
            l_data_o = 0;
            l_addr_counter_o = 0;
        end
    endcase
end

endmodule

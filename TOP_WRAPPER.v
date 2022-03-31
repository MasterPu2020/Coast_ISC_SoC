
module TOP_WRAPPER 

//----------------------------------------------------------------
// Ports
//----------------------------------------------------------------

(
     CLK100MHZ
    ,btn
    ,sw
    ,uart_txd_in
    ,uart_rxd_out
    ,led0_b
    ,led0_g
    ,led0_r
    ,led1_b
    ,led1_g
    ,led1_r
    ,led2_b
    ,led2_g
    ,led2_r
    ,led3_b
    ,led3_g
    ,led3_r
);
    // Inputs
    input CLK100MHZ;
    input [3:0]sw;
    input [3:0]btn;
    input uart_txd_in;

    // Outputs
    output reg uart_rxd_out;
    output reg led0_b;
    output reg led0_g;
    output reg led0_r;
    output reg led1_b;
    output reg led1_g;
    output reg led1_r;
    output reg led2_b;
    output reg led2_g;
    output reg led2_r;
    output reg led3_b;
    output reg led3_g;
    output reg led3_r;

//----------------------------------------------------------------
// Includes
//----------------------------------------------------------------

`include "defs.v"


//----------------------------------------------------------------
// Params
//----------------------------------------------------------------

parameter RESET = 1;
parameter MAX_SIZE = 2500;
parameter CLK_rate = 100000000;
parameter Baud_rate = 9600;

parameter TOP_RESET_BTN = 3;
parameter UART_RESET_BTN = 2;
parameter ROM_RESET_BTN = 1;
parameter NPU_RAM_W_LINE_SEL_BTN = 0;
parameter CPU_MODE_SEL = 3;
parameter ROM_EN_W_SEL = 2;
parameter NPU_RAM_EN_W_SEL = 1;
parameter NPU_RAM_W_LINE_SEL = 0;


//----------------------------------------------------------------
// Registers / Wires
//----------------------------------------------------------------

reg [3:0] npu_w_line;
reg [3:0] sw_controller;
reg [2:0] sel_counter;
    
//----------------------------------------------------------------
// Module
//----------------------------------------------------------------

data_flow_supervisor #(
    RESET,
    CLK_rate,
    Baud_rate,
    MAX_SIZE
)data_flow_supervisor(
     .clk_i(CLK100MHZ)
    ,.rst_i(btn[TOP_RESET_BTN])
    ,.rst_rom_i(btn[ROM_RESET_BTN])
    ,.rst_uart_i(btn[UART_RESET_BTN])
    ,.mode_sel_i(sw_controller[CPU_MODE_SEL])
    ,.rom_en_w_sel_i(sw_controller[ROM_EN_W_SEL])
    ,.npu_ram_en_w_sel_i(sw_controller[NPU_RAM_EN_W_SEL])
    ,.npu_ram_w_line_i(npu_w_line)
    ,.uart_i(uart_txd_in)
    ,.uart_o(uart_rxd_out)
);

//----------------------------------------------------------------
// Circuits
//----------------------------------------------------------------

// Initializition
initial begin
    npu_w_line = 0;
    sw_controller = 0;
    sel_counter = 0;
    led0_b = 0;
    led0_g = 0;
    led0_r = 0;
    led1_b = 0;
    led1_g = 0;
    led1_r = 0;
    led2_b = 0;
    led2_g = 0;
    led2_r = 0;
    led3_b = 0;
    led3_g = 0;
    led3_r = 0;
end

// Button and LED controller
always @(*) begin
    if (sw[CPU_MODE_SEL] == 1) begin
        sw_controller[CPU_MODE_SEL] = 1;
        sw_controller[ROM_EN_W_SEL] = 0;
        sw_controller[NPU_RAM_EN_W_SEL] = 0;
        sw_controller[NPU_RAM_W_LINE_SEL] = 0;
        led1_b = 0;
        led1_g = 0;
        led1_r = 0;
        led2_b = 0;
        led2_g = 0;
        led2_r = 0;
        led3_b = 1;
        led3_g = 1;
        led3_r = 1;
    end
    else if (sw[ROM_EN_W_SEL] == 1) begin
        sw_controller[CPU_MODE_SEL] = 0;
        sw_controller[ROM_EN_W_SEL] = 1;
        sw_controller[NPU_RAM_EN_W_SEL] = 0;
        sw_controller[NPU_RAM_W_LINE_SEL] = 0;
        led1_b = 0;
        led1_g = 0;
        led1_r = 0;
        led2_b = 1;
        led2_g = 1;
        led2_r = 1;
        led3_b = 0;
        led3_g = 0;
        led3_r = 0;
    end
    else if (sw[NPU_RAM_EN_W_SEL] == 1) begin
        sw_controller[CPU_MODE_SEL] = 0;
        sw_controller[ROM_EN_W_SEL] = 0;
        sw_controller[NPU_RAM_EN_W_SEL] = 1;
        sw_controller[NPU_RAM_W_LINE_SEL] = 0;
        led1_b = 1;
        led1_g = 1;
        led1_r = 1;
        led2_b = 0;
        led2_g = 0;
        led2_r = 0;
        led3_b = 0;
        led3_g = 0;
        led3_r = 0;
    end
    else if (sw[NPU_RAM_W_LINE_SEL] == 1) begin
        sw_controller[CPU_MODE_SEL] = 0;
        sw_controller[ROM_EN_W_SEL] = 0;
        sw_controller[NPU_RAM_EN_W_SEL] = 0;
        sw_controller[NPU_RAM_W_LINE_SEL] = 1;
        led1_b = 0;
        led1_g = 0;
        led1_r = 0;
        led2_b = 0;
        led2_g = 0;
        led2_r = 0;
        led3_b = 0;
        led3_g = 0;
        led3_r = 0;
    end
    else begin
        sw_controller[CPU_MODE_SEL] = 0;
        sw_controller[ROM_EN_W_SEL] = 0;
        sw_controller[NPU_RAM_EN_W_SEL] = 0;
        sw_controller[NPU_RAM_W_LINE_SEL] = 0;
        led1_b = 0;
        led1_g = 0;
        led1_r = 0;
        led2_b = 0;
        led2_g = 0;
        led2_r = 0;
        led3_b = 0;
        led3_g = 0;
        led3_r = 0;
    end
end

// Select NPU RAM write line controller & LED controller
always @(posedge CLK100MHZ) begin
    if (sw_controller[NPU_RAM_W_LINE_SEL] == 0) begin
        led0_b = 0;
        led0_g = 0;
        led0_r = 0;
    end
    else begin
        case (sel_counter)
            0: begin
                led0_b = 1;
                led0_g = 1;
                led0_r = 1;
                npu_w_line = 0;
            end
            1: begin
                led0_b = 0;
                led0_g = 1;
                led0_r = 0;
                npu_w_line = `IMG_C1_LINE;
            end
            2: begin
                led0_b = 1;
                led0_g = 0;
                led0_r = 0;
                npu_w_line = `FLITER_C1_LINE;
            end
            3: begin
                led0_b = 1;
                led0_g = 1;
                led0_r = 0;
                npu_w_line = `FLITER_C3_LINE;
            end
            4: begin
                led0_b = 0;
                led0_g = 0;
                led0_r = 1;
                npu_w_line = `WEIGHT_C5_LINE;
            end
            default: begin
                led0_b = 1;
                led0_g = 1;
                led0_r = 1;
                npu_w_line = 0;
            end
        endcase
    end
end

always @(posedge btn[NPU_RAM_W_LINE_SEL]) begin
    if (sw_controller[NPU_RAM_W_LINE_SEL] == 1) begin
        if (sel_counter >= 4) begin
            sel_counter = 0;
        end
        else begin
            sel_counter = sel_counter + 1;
        end
    end
end

endmodule

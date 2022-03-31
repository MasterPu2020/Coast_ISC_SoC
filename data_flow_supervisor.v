 module data_flow_supervisor
 
//----------------------------------------------------------------
// Param
//----------------------------------------------------------------

#(
    parameter RESET = 1,
    parameter CLK_rate = 100000000,
    parameter Baud_rate = 9600,
    parameter MAX_SIZE = 2000
)

//----------------------------------------------------------------
// Ports
//----------------------------------------------------------------

(
     clk_i
    ,rst_i
    ,rst_rom_i
    ,rst_uart_i
    ,mode_sel_i
    ,rom_en_w_sel_i
    ,npu_ram_en_w_sel_i
    ,npu_ram_w_line_i
    ,uart_i
    ,uart_o
);

    // Inputs
    input clk_i;
    input rst_i; //btn0
    input rst_rom_i; //btn1
    input rst_uart_i; //btn2
    input mode_sel_i; //sw0
    input rom_en_w_sel_i; //sw1
    input npu_ram_en_w_sel_i; //sw2
    input [3:0] npu_ram_w_line_i; //sw3 btn3
    input uart_i;
    
    // Outputs
    output uart_o;

//----------------------------------------------------------------
// Includes
//----------------------------------------------------------------

`include "defs.v"

//----------------------------------------------------------------
// Registers / Wires
//----------------------------------------------------------------
    
    reg [15:0] w_rom_addr;
    reg [31:0] w_rom_data;
    reg [31:0] instruction;
    reg [7:0] axi_r_rslt_addr;
    reg [`IMG_C1_END - `IMG_C1_STA : 0] axi_img32_data;
    reg [`IMG_S2_END - `IMG_S2_STA : 0] axi_img28_data;
    reg [`IMG_C3_END - `IMG_C3_STA : 0] axi_img14_data;
    reg [`IMG_S4_END - `IMG_S4_STA : 0] axi_img10_data;
    reg [`IMG_C5_END - `IMG_C5_STA : 0] axi_img5_data;
    reg [`FLITER_C1_END - `FLITER_C1_STA : 0] axi_fliter_c1_data;
    reg [`FLITER_C3_END - `FLITER_C3_STA : 0] axi_fliter_c3_data;
    reg [`WEIGHT_C5_END - `WEIGHT_C5_STA : 0] axi_weight_c5_data;
    reg [`BIAS_C1_END - `BIAS_C1_STA : 0] axi_bias_c1_data;
    reg [`BIAS_C3_END - `BIAS_C3_STA : 0] axi_bias_c3_data;
    reg [`BIAS_C5_END - `BIAS_C5_STA : 0] axi_bias_c5_data;
    reg [`RESULT_END - `RESULT_STA : 0] axi_result_data;
    
    wire [7:0] reg_watcher;

    reg en_launch; //发送使能
    reg en_w_l_ram; //发送ram写使能
    reg [7:0] launch_write_address; //发送ram写数据需提供的地址
    reg [7:0] launch_write_data; //发送ram写入的数据
    reg [7:0] l_addr;

    wire [MAX_SIZE * 8:0] full_data;
    wire [15:0] receive_address_counter; //接收ram实时接收并储存到的地址
    wire [7:0] launch_address_counter; //发送ram实时发送数据的地址

    assign not_npu_ram_en_w = ~ npu_ram_en_w_sel_i;


//----------------------------------------------------------------
// Modules
//----------------------------------------------------------------

npu_cpu_system_top npu_cpu_system_top(
     .clk_i(clk_i)
    ,.rst_i(rst_i)
    ,.rst_rom_i(rst_rom_i)
    ,.mode_sel_i(mode_sel_i)
    ,.en_w_rom_i(rom_en_w_sel_i)
    ,.w_rom_addr_i(w_rom_addr)
    ,.w_rom_data_i(w_rom_data)
    ,.instruction_i(instruction)

    ,.axi_npu_ram_sel_i(not_npu_ram_en_w) // 选谁的信号写npu ram
    ,.axi_en_w_i(npu_ram_en_w_sel_i)
    ,.axi_w_line_i(npu_ram_w_line_i)
    ,.axi_r_rslt_addr_i(axi_r_rslt_addr)
    ,.axi_img32_data_i(axi_img32_data) // Input Data Needed
    ,.axi_img28_data_i(axi_img28_data)
    ,.axi_img14_data_i(axi_img14_data)
    ,.axi_img10_data_i(axi_img10_data)
    ,.axi_img5_data_i(axi_img5_data)
    ,.axi_fliter_c1_data_i(axi_fliter_c1_data) // Input Data Needed
    ,.axi_fliter_c3_data_i(axi_fliter_c3_data) // Input Data Needed
    ,.axi_weight_c5_data_i(axi_weight_c5_data)// Input Data Needed
    ,.axi_bias_c1_data_i(axi_bias_c1_data)
    ,.axi_bias_c3_data_i(axi_bias_c3_data)
    ,.axi_bias_c5_data_i(axi_bias_c5_data)
    ,.axi_result_data_i(axi_result_data)
    
    ,.reg_watcher_o(reg_watcher)
);

UART_system_top #(MAX_SIZE) UART_system_top(
     .clk_i(clk_i)
    ,.rst_i(rst_uart_i)
    ,.uart_i(uart_i)
    ,.en_launch_i(en_launch)
    ,.en_write_i(en_w_l_ram)
    ,.launch_write_address_i(launch_write_address)
    ,.launch_write_data_i(launch_write_data)
    ,.uart_o(uart_o)
    ,.full_data_o(full_data)
    ,.receive_address_counter_o(receive_address_counter)
    ,.launch_address_counter_o(launch_address_counter)
    ,.l_addr_i(l_addr)
);

//----------------------------------------------------------------
// Circuits
//----------------------------------------------------------------

// Initializition
initial begin
    w_rom_addr = 0;
    w_rom_data = 0;
    instruction = `I_WAIT_STAY;
    axi_r_rslt_addr = 0;
    axi_img32_data = 0;
    axi_img28_data = 0;
    axi_img14_data = 0;
    axi_img10_data = 0;
    axi_img5_data = 0;
    axi_fliter_c1_data = 0;
    axi_fliter_c3_data = 0;
    axi_weight_c5_data = 0;
    axi_bias_c1_data = 0;
    axi_bias_c3_data = 0;
    axi_bias_c5_data = 0;
    axi_result_data = 0;
    en_launch = 0; //发送使能
    en_w_l_ram = 0; //发送ram写使能
    launch_write_address = 0; //发送ram写数据需提供的地址
    launch_write_data = 0; //发送ram写入的数据
end

genvar g_row_rom;
integer row_rom;

// Immediate instruction : 
always @(posedge clk_i) begin
    if (mode_sel_i == `IMM_INST_sel && rst_uart_i != RESET) begin
        instruction = full_data[31:0];
    end
    else begin
        instruction = `I_WAIT_STAY;
    end
end

// Write ROM
wire [31:0]w_rom_full_data[MAX_SIZE * 2:0];
generate
    for (g_row_rom = 0; g_row_rom < (MAX_SIZE / 4); g_row_rom = g_row_rom + 1) begin
       assign w_rom_full_data[g_row_rom] = full_data[g_row_rom * 32 + 31:g_row_rom * 32]; 
    end
endgenerate

always @(posedge clk_i) begin
    if (rom_en_w_sel_i == `EN_W && rst_uart_i != RESET) begin
        for (row_rom = 0; row_rom <= receive_address_counter; row_rom = row_rom + 1) begin
            w_rom_data = w_rom_full_data[row_rom];
            w_rom_addr = row_rom;
        end
    end
    else begin
        w_rom_data = `I_WAIT;
        w_rom_addr = 0;
    end
end

// Write NPU RAM
always @(posedge clk_i) begin
    if (npu_ram_en_w_sel_i == `EN_W && rst_uart_i != RESET) begin
        axi_img32_data = full_data[`IMG_C1_END - `IMG_C1_STA : 0];
        axi_fliter_c1_data = full_data[`FLITER_C1_END - `FLITER_C1_STA : 0];
        axi_fliter_c3_data = full_data[`FLITER_C3_END - `FLITER_C3_STA : 0];
        axi_weight_c5_data = full_data[`WEIGHT_C5_END - `WEIGHT_C5_STA : 0];
    end
    else begin
        axi_img32_data = 0;
        axi_fliter_c1_data = 0;
        axi_fliter_c3_data = 0;
        axi_weight_c5_data = 0;
    end
end

// Lauch watcher data
reg [1:0] clk_counter = 0;
reg [7:0] last_reg_watcher = 0;
reg [20:0] launch_timer = 0;
always @(reg_watcher) begin
    en_w_l_ram = 1;
    if (launch_write_address >= 255) begin
        launch_write_address = 0;
        launch_write_data = reg_watcher;
        l_addr = launch_write_address;
    end
    else begin
        launch_write_address = launch_write_address + 1;
        launch_write_data = reg_watcher;
        l_addr = launch_write_address;
    end
end

always @(posedge clk_i) begin
    if (clk_counter < 3) begin
        clk_counter = clk_counter + 1;
    end
    else begin
        clk_counter = 0;
        last_reg_watcher = reg_watcher;
    end
end

always @(posedge clk_i) begin
    if (last_reg_watcher != reg_watcher) begin
        launch_timer = (CLK_rate/Baud_rate) * 10 - 1; // 10 BPS cycle
    end
    else if(launch_timer > 0) begin
        launch_timer = launch_timer - 1;
        en_launch = 1;
    end
    else begin
        en_launch = 0;
    end
end

endmodule
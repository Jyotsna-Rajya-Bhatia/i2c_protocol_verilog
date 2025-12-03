`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.11.2025 11:44:21
// Design Name: 
// Module Name: top_module_system
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_module_system(
    input  wire clk,      
    output wire clk_divided,
    input  wire rst_n, 
    inout  wire SDA,
    inout  wire SCL,
    output wire [7:0] m_data_o,
    output wire [7:0] s_data_o,
    output wire[3:0] m_bit_counter,
    output wire [3:0]m_currentstate,
    output wire[3:0] s_bit_counter,
    output wire [3:0]s_currentstate,

   

    input  wire m_start_i,
    input  wire m_stop_i,
    input  wire s_stop_i,
    input  wire m_read_nwrite_i,
    input  wire [6:0] m_slave_addr_i,
    input  wire [7:0] m_data_i,
    input  wire [7:0] s_data_i,
    output  wire sda_out_master,
    output  wire scl_out_master,
    output  wire sda_out_slave,
    output  wire scl_out_slave,

    output wire s_busy_o,
    output wire m_busy_o,
    output wire m_error_o,
    output wire success
);
    wire clk_i2c;            
    wire sda_master_out;
    wire scl_master_out;
    wire sda_slave_out;
    wire scl_slave_out;
	assign sda_out_master=sda_master_out;
	assign scl_out_master=scl_master_out;
	assign sda_out_slave=sda_slave_out;
	assign scl_out_slave=scl_slave_out;
	assign clk_divided=clk_i2c;
	
    i2c_clk a0 (
        .clk(clk),
        .rst_n(rst_n),
        .clk_out(clk_i2c)
    );

    master_i2c a1 (
	.bit_counter(m_bit_counter),
		.currentstate(m_currentstate),
        .clk(clk_i2c),   
         .clk_notdivided(clk),  
        .rst_n(rst_n),

        .m_start_i(m_start_i),
        .m_stop_i(m_stop_i),
        .m_read_nwrite_i(m_read_nwrite_i),
        .m_slave_addr_i(m_slave_addr_i),
        .m_data_i(m_data_i),

        .m_data_o(m_data_o),
        .m_busy_o(m_busy_o),
        .m_error_o(m_error_o),
        .success(success),

        .sda_out(sda_master_out),
        .scl_out(scl_master_out),
        .sda_in(sda_in),
        .scl_in(scl_in)
    );
slave_i2c a2 (
     .bit_counter(s_bit_counter),
    .currentstate(s_currentstate),
    .clk(clk_i2c),
    .clk_notdivided(clk), 
    .rst_n(rst_n),
    .s_stop_i(s_stop_i),
    .s_data_i(s_data_i),

    .s_data_o(s_data_o),
    .s_busy_o(s_busy_o),

    .sda_out(sda_slave_out),
    .scl_out(scl_slave_out),
    .sda_in(sda_in),
    .scl_in(scl_in)
);

    bus_addr a3 (
        .SDA(SDA),
        .SCL(SCL),

        .master_sda_low_intent(sda_master_out),
        .master_scl_low_intent(scl_master_out),

        .slave_sda_low_intent(sda_slave_out),  
        .slave_scl_low_intent(scl_slave_out),

        .sda_in(sda_in),
        .scl_in(scl_in)
    );

endmodule





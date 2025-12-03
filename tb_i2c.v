`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.11.2025 11:50:48
// Design Name: 
// Module Name: tb_i2c
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


module tb_i2c;
 reg  clk;
  wire clk_divided;
  reg  rst_n;

  // I2C lines
  wire SDA;
  wire SCL;

  // Monitor Outputs (system outputs)
  wire [7:0] m_data_o;
  wire [7:0] s_data_o;
  wire [3:0] m_bit_counter;
  wire [3:0] m_currentstate;
  wire [3:0] s_bit_counter;
  wire [3:0] s_currentstate;


  reg        m_start_i;
  reg        m_stop_i;
  reg        s_stop_i;
  reg        m_read_nwrite_i;
  reg [6:0]  m_slave_addr_i;
  reg [7:0]  m_data_i;
  reg [7:0]  s_data_i;

  // Debug / extra signals
  wire sda_out_master;
  wire scl_out_master;
  wire sda_out_slave;
  wire scl_out_slave;
  wire s_busy_o;
  wire m_busy_o;
  wire m_error_o;
  wire success;

  top_module_system uut (
    .clk(clk),
    .clk_divided(clk_divided),
    .rst_n(rst_n),
    .SDA(SDA),
    .SCL(SCL),

    .m_data_o(m_data_o),
    .s_data_o(s_data_o),
    .m_bit_counter(m_bit_counter),
    .m_currentstate(m_currentstate),
    .s_bit_counter(s_bit_counter),
    .s_currentstate(s_currentstate),

    .m_start_i(m_start_i),
    .m_stop_i(m_stop_i),
    .s_stop_i(s_stop_i),
    .m_read_nwrite_i(m_read_nwrite_i),
    .m_slave_addr_i(m_slave_addr_i),
    .m_data_i(m_data_i),
    .s_data_i(s_data_i),

    .sda_out_master(sda_out_master),
    .scl_out_master(scl_out_master),
    .sda_out_slave(sda_out_slave),
    .scl_out_slave(scl_out_slave),

    .s_busy_o(s_busy_o),
    .m_busy_o(m_busy_o),
    .m_error_o(m_error_o),
    .success(success)
  );

  initial begin
    clk = 1;
    forever #0.5 clk = ~clk;
  end

  initial begin
    rst_n = 0;
    m_start_i = 0;
    m_stop_i = 0;
    s_stop_i = 0;
    m_read_nwrite_i = 0;
    m_slave_addr_i = 7'b1010111;
    m_data_i = 8'b11001100;
    s_data_i = 8'b10101101;

    #4 rst_n = 1;


    m_start_i = 1;
	#8;
	#8;
	 m_start_i = 0;
	#80;
#10;
#80;
#5;
  if (s_data_o !== 8'b11001100)
    $display("ERROR at %0t: Slave data mismatch. Got %b", $time, s_data_o);
  else
    $display("PASS at %0t: Slave received correct data %b", $time, s_data_o);

    m_data_i = 8'b10010010;
#5;
#80;
m_stop_i=1;
#5;
  if (s_data_o !== 8'b10010010)
    $display("ERROR at %0t: Slave data mismatch. Got %b", $time, s_data_o);
  else
    $display("PASS at %0t: Slave received correct data %b", $time, s_data_o);


#5;
#10;
m_stop_i=0;
#6;
$display("send address and 2 data byte");
    m_read_nwrite_i = 1;
m_start_i=1;
#6;
#8;
m_start_i = 0;

#80;
#10;
#80;
s_data_i = 8'b00001011;
#5;
  if (m_data_o !== 8'b10101101)
    $display("ERROR at %0t: Slave data mismatch. Got %b", $time, m_data_o);
  else
    $display("PASS at %0t: Slave received correct data %b", $time, m_data_o);
#5;
#80;
s_stop_i=1;
#5;
  if (m_data_o !== 8'b00001011)
    $display("ERROR at %0t: Slave data mismatch. Got %b", $time, m_data_o);
  else
    $display("PASS at %0t: Slave received correct data %b", $time, m_data_o);

#5;
#6;
s_stop_i=0;
#10;
$display("send address and recieve 2 data byte");
    m_slave_addr_i = 7'b1110111;
m_start_i = 1;
#6;
#8;
m_start_i = 0;

    m_read_nwrite_i = 1;
#80;
#5;
  if (m_slave_addr_i !== 7'b1010111)
    $display("ERROR at %0t: Slave data mismatch. Got %b", $time, m_slave_addr_i);
  else
    $display("PASS at %0t: Slave received correct data %b", $time, m_slave_addr_i);
#5;
#20;
$display("wrong slave id ");
    $stop; //70 us
  end

endmodule


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.11.2025 11:46:38
// Design Name: 
// Module Name: bus_addr
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


module bus_addr(
 inout wire SDA,
  inout wire SCL,           

  input  wire master_sda_low_intent,   //sda_out for master
  input  wire master_scl_low_intent,

  input  wire slave_sda_low_intent,   
  input  wire slave_scl_low_intent,

  output wire sda_in,                 //sda_out for master
  output wire scl_in
);
  wire sda_drive_low_bus= master_sda_low_intent | slave_sda_low_intent;
  wire scl_drive_low_bus= master_scl_low_intent | slave_scl_low_intent;

  assign SDA= sda_drive_low_bus ? 1'b0 : 1'b1;
  assign SCL= scl_drive_low_bus ? 1'b0 : 1'b1;

  assign sda_in= SDA;
  assign scl_in= SCL;
endmodule



`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.11.2025 11:45:44
// Design Name: 
// Module Name: i2c_clk
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


module i2c_clk(
 input wire clk, 
    input wire rst_n,
    output reg clk_out 
);
    reg [9:0] clk_counter; // 1024
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_counter <= 0;
            clk_out <= 0;
        end else begin
            if (clk_counter == 4) begin
                clk_counter <= 0;
                clk_out <= ~clk_out;
            end else begin
                clk_counter <= clk_counter + 1;
            end
        end
    end
endmodule

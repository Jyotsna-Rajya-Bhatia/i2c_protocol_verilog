`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.11.2025 11:47:25
// Design Name: 
// Module Name: master_i2c
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


module master_i2c(
 output wire[3:0]        bit_counter,
    output wire[3:0]  currentstate,
    input  wire  clk,
    input  wire  clk_notdivided,    
    input wire   rst_n,
    input  wire  m_start_i,
    input  wire  m_stop_i,
    input  wire  m_read_nwrite_i,
    input  wire [6:0]m_slave_addr_i,
    input  wire [7:0]m_data_i,

    output reg  [7:0]m_data_o,
    output reg  m_busy_o,
    output reg  m_error_o,
    output reg  success,

    output reg  sda_out,
    output reg  scl_out,
    input wire  sda_in,
    input wire  scl_in
);

    localparam idle =4'd0;
    localparam start=4'd1;
    localparam send_addr=4'd2;
    localparam send_r_or_w=4'd3;
    localparam wait_ack1=4'd4;
    localparam send_data=4'd5;
    localparam wait_ack2  =4'd6;
    localparam recieve_data =4'd7;
    localparam stop   =4'd8;
    localparam error  =4'd9;
    localparam send_ack2  =4'd10;

    reg [3:0] current_state, next_state;
    reg[7:0] shift_reg;
    reg[3:0] bit_cnt;
    assign currentstate=current_state;
   assign bit_counter =bit_cnt;

reg prev_sda;
wire stop_condition;

always @(negedge clk or negedge rst_n)begin
      if (!rst_n)
            current_state<= idle;
       else
            current_state <= next_state;
  end



// state_behave doesnot depend in clk
always @(*) begin
   next_state = current_state;

   case (current_state)
            idle: begin
	 	sda_out=0;
		scl_out=0;
		m_error_o=0;
		m_busy_o=0;
                shift_reg=0;
		success=0;
		m_data_o=0;
            if (m_start_i==1'b1)begin
            next_state= start;
		end
         end

     start: begin
	      if(scl_in==1) begin
	      sda_out=1; end
              next_state = send_addr;
	      m_busy_o=1;
            end

     send_addr: begin
	               if (scl_in == 1'b0) begin 
                    sda_out   =~m_slave_addr_i[bit_cnt-1];
                end
	scl_out=~clk;
       if (bit_cnt == 1)
               next_state = send_r_or_w;
        end

         send_r_or_w: begin
                if (scl_in == 1'b0) begin 
                    sda_out   =~m_read_nwrite_i;
			
                end
		scl_out=~clk;
                next_state = wait_ack1;
      end

         wait_ack1: begin
	scl_out=~clk;
	sda_out=0;
	if (scl_in == 1'b1)begin
          if (sda_in == 1'b0) begin
                 if (m_read_nwrite_i)
                        next_state = recieve_data;
                 else
                        next_state = send_data;
              end else begin
                    next_state = error;
              end
            end
	end
       send_data: begin
	                if (scl_in == 1'b0) begin
                    sda_out =~m_data_i[bit_cnt];
                end
	scl_out=~clk;
                if (bit_cnt == 0)
                    next_state = wait_ack2;
        end

      wait_ack2: begin
	scl_out=~clk;
	sda_out=0;
	if (scl_in == 1'b1)begin
        if (sda_in == 1'b0) begin
            if (m_stop_i)begin
                  next_state = stop;
              end else begin
               next_state = send_data; 
	end
          end else begin
                next_state = error;
            end
         end
	end
      send_ack2: begin
	scl_out=~clk;
	m_data_o=shift_reg;
        if (bit_cnt ==4'd7) begin
		 next_state = recieve_data; 
		if (scl_in == 1'b0)
		sda_out=1'b1;
          end else begin
                next_state = error;
		if (scl_in == 1'b0)
		sda_out=1'b0;
            end
	end

      recieve_data: begin
			sda_out=0;
			if (stop_condition) begin 
			shift_reg  = 8'd0;
			m_busy_o=0;
			success=1;
			next_state = idle;
			end else begin
	                if (scl_in == 1'b1) begin 
                    shift_reg[bit_cnt] = sda_in;
                end
	scl_out=~clk;
           if (bit_cnt == 0)
               next_state = send_ack2;
       end
	end
       stop: begin
		scl_out=0;
		if(scl_in==1)
		sda_out=0;
        shift_reg  = 8'd0;
	m_busy_o=0;
	success=1;
          next_state = idle;
       end

         error: begin
		 	sda_out=0;
		scl_out=0;
	m_busy_o=0;
	m_error_o=1;
          next_state = idle;
       end
endcase
end

// state_behave doesnot depend in clk
always @(negedge clk) begin

        case (current_state)
	    start:begin
		      bit_cnt   <= 4'd7;
	end
	wait_ack1:begin 
			bit_cnt<= 4'd7;
	end
	wait_ack2:begin 
			bit_cnt<= 4'd7;
	end
            send_addr: begin
		bit_cnt <= bit_cnt - 1'b1;
            end
            send_data: begin
                        bit_cnt <= bit_cnt - 1'b1;
            end

            recieve_data: begin
		if (bit_cnt==0)begin
				bit_cnt <= 4'd7;
	end
			else begin
                        bit_cnt <= bit_cnt - 1;
			end
			if (stop_condition) begin 
			bit_cnt <= 4'd0; end
            end
		stop:begin 
			bit_cnt       <= 4'd0;	
	end
		error:begin 
			bit_cnt       <= 4'd0;
		end
        endcase
end
always @(posedge clk_notdivided) begin
 if (!((current_state==recieve_data)&&(stop_condition==1)))begin
    prev_sda <= sda_in;
end
end

assign stop_condition = (prev_sda == 1'b0) && (sda_in == 1'b1) && (scl_in == 1'b1);

endmodule



`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.11.2025 11:48:29
// Design Name: 
// Module Name: slave_i2c
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


module slave_i2c(
    output wire[3:0]        bit_counter,
    output wire[3:0]  currentstate,
    input  wire  clk,
    input  wire  clk_notdivided, 
    input wire   rst_n,
    input  wire  s_stop_i,
    input  wire [7:0]s_data_i,

    output reg  [7:0]s_data_o,
    output reg  s_busy_o,

    output reg  sda_out,
    output reg  scl_out,
    input wire  sda_in,
    input wire  scl_in
);


parameter [6:0] slave_id = 7'b1010111;

    localparam idle =4'd0;
    localparam recieve_addr=4'd1;
    localparam recieve_r_or_w=4'd2;
    localparam send_ack1=4'd3;
    localparam recieve_data=4'd4;
    localparam send_ack2  =4'd5;
    localparam send_data =4'd6;
    localparam stop =4'd7;
    localparam wait_ack2  =4'd8;

    reg [6:0]s_slave_addr_i;
    reg s_read_nwrite_i;
    reg [3:0] current_state, next_state;
    reg[7:0] shift_reg;
    reg[3:0] bit_cnt;
    assign currentstate=current_state;
   assign bit_counter =bit_cnt;

reg prev_sda;
wire stop_condition;
wire start_condition;

always @(negedge clk or negedge rst_n)begin
      if (!rst_n) begin
            current_state<= idle;
      end else begin
            current_state <= next_state;
		end
  end



// state_behave doesnot depend in clk
always @(*) begin
   next_state = current_state;

   case (current_state)
            idle: begin
	 	sda_out=0;
		scl_out=0;
		s_busy_o=0;
                shift_reg=0;
		s_data_o=0;
            if (start_condition)begin
            next_state= recieve_addr;
		end
         end


     recieve_addr: begin
	               if (scl_in == 1'b1) begin 
                    s_slave_addr_i[bit_cnt-1]  =sda_in;
                end
       if (bit_cnt == 1)begin
               next_state = recieve_r_or_w;
	end
        end

         recieve_r_or_w: begin
                if (scl_in == 1'b1) begin 
                    s_read_nwrite_i<=sda_in;
			
                end
                next_state = send_ack1;
      end

         send_ack1: begin
	if((s_slave_addr_i == slave_id)&&(s_read_nwrite_i==1'b1))begin
		next_state = send_data;
		if(scl_in == 1'b0)
		sda_out=1'b1;
		end else if((s_slave_addr_i == slave_id)&&(s_read_nwrite_i==1'b0))begin
			next_state = recieve_data;
			if(scl_in == 1'b0)
			sda_out=1'b1;
		end else begin
			next_state=idle;
			if(scl_in == 1'b0)
			sda_out=1'b0;
			end
		
	end

    send_data: begin
	                if (scl_in == 1'b0) begin
                    sda_out =~s_data_i[bit_cnt];
                end
                if (bit_cnt == 0)
                    next_state = wait_ack2;
        end

      wait_ack2: begin
	sda_out=0;
	if (scl_in == 1'b1)begin
        if (sda_in == 1'b0) begin
            if (s_stop_i)begin
                  next_state = stop;
              end else begin
               next_state = send_data; 
	end
          end else begin
                next_state = idle;
            end
         end
	end
      send_ack2: begin
	s_data_o=shift_reg;

        if (bit_cnt ==4'd7) begin
               next_state = recieve_data; 		
	if (scl_in == 1'b0)
		sda_out=1'b1;
          end else begin
		next_state = idle;
	if (scl_in == 1'b0)
		sda_out=1'b0;             
            end

         end
      recieve_data: begin
			sda_out=0;
			if (stop_condition) begin 
			shift_reg  = 8'd0;
			s_busy_o=0;
			next_state = idle;
			end else begin
	                if (scl_in == 1'b1) begin 
                    shift_reg[bit_cnt] = sda_in;
                end
           if (bit_cnt == 0)
               next_state = send_ack2;
       end
	end
       stop: begin
		if(scl_in==0)
		   sda_out=1;
		if(scl_in==1)
		sda_out=0;
        shift_reg  = 8'd0;
	s_busy_o=0;
          next_state = idle;
       end

endcase
end

// state_behave doesnot depend in clk
always @(negedge clk) begin

        case (current_state)
		idle:begin 
				bit_cnt   <= 4'd7;
		end
		send_ack1:begin 
				bit_cnt <= 4'd7;
		end
		wait_ack2:begin 
			bit_cnt<= 4'd7;
		end
            recieve_addr: begin
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
			bit_cnt<= 4'd0;
			end
            end
		stop:begin  
			bit_cnt       <= 4'd0;
		end
        endcase
end
always @(negedge clk_notdivided) begin
 if (!(((current_state==idle)&&(start_condition==1))||((current_state==recieve_data)&&(stop_condition==1))))begin
    prev_sda <= sda_in;
end

end

assign stop_condition = (prev_sda == 1'b0) && (sda_in == 1'b1) && (scl_in == 1'b1);
assign start_condition = (prev_sda == 1'b1) && (sda_in == 1'b0) && (scl_in == 1'b1);

endmodule


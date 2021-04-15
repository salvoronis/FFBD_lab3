`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/18/2021 02:13:00 AM
// Design Name: 
// Module Name: gun
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


module gun(
    input rst_i,
    input clk_i,
    input [15:0] sw_i,
    output busy,
    output [14:0] leds
);

reg mult_reset;
reg [7:0] mult_i1;
reg [7:0] mult_i2;
wire mult_busy;
wire [15:0] mult_out;

wire [7:0] a_in;
wire [7:0] b_in;

reg [3:0] state, state_next;

reg [7:0] a;
reg [7:0] b;

reg [15:0] tmp;
reg [15:0] tmp1;
reg [15:0] tmp2;
reg [15:0] r;

multiplier mult(
    .clk_i(clk_i),
    .rst_i(mult_reset),
    .a_bi(mult_i1),
    .b_bi(mult_i2),
    .busy_o(mult_busy),
    .y_bo(mult_out)
);

localparam STATE0 = 4'b0000;
localparam STATE1 = 4'b0001;
localparam STATE2 = 4'b0010;
localparam STATE3 = 4'b0011;
localparam STATE4 = 4'b0100;
localparam STATE5 = 4'b0101;
localparam STATE6 = 4'b0110;
localparam STATE7 = 4'b0111;

assign busy = rst_i | |state;
assign leds = r;
assign a_in = sw_i[15:8];
assign b_in = sw_i[7:0];

always @(posedge clk_i)
    if (rst_i) begin
        state <= STATE1;
    end else begin
        state <= state_next;
    end
    
always @(posedge clk_i) begin
    case(state)
        STATE0: state_next = STATE0;
        STATE1: state_next = STATE5;
        STATE5:
        begin
            if (mult_busy) begin
                state_next = STATE5;
            end else begin
                state_next = STATE2;
            end
        end
        STATE2: state_next = STATE6;
        STATE6:
        begin
            if (mult_busy) begin
                state_next = STATE6;
            end else begin
                state_next = STATE3;
            end
        end
        STATE3: state_next = STATE7;
        STATE7: begin
            if (mult_busy) begin
                state_next = STATE7;
            end else begin
                state_next = STATE4;
            end
        end
        STATE4: state_next = STATE0;
    endcase
end

always @(posedge clk_i) begin
    if (rst_i) begin
        //??? ????????? ???????
        //a <= a_in;
        //b <= b_in;
        mult_reset <= 0;
        r <= 0;
        tmp <= 0;
        tmp1 <= 0;
        tmp2 <= 0;
    end else begin
        case (state)
            STATE0:
                begin
                end
            STATE1:
                begin
                    mult_reset <= 1;
                    mult_i1 <= a_in;
                    mult_i2 <= b_in;
                end
            STATE5:
                begin
                    if (mult_busy) begin
                        mult_reset <= 0;
                    end else begin
                        tmp <= mult_out;
                    end
                end
            STATE2:
                begin
                    if (mult_busy) begin
                        mult_reset <= 0;
                    end else begin
                        mult_reset <= 1;
                        mult_i1 <= a_in;
                        mult_i2 <= a_in;
                        //tmp1 <= mult_out;
                    end
                end
            STATE6:
                begin
                    if (mult_busy) begin
                        mult_reset <= 0;
                    end else begin
                        tmp1 <= mult_out;
                    end
                end
            STATE3:
                begin
                    if (mult_busy) begin
                        mult_reset <= 0;
                    end else begin
                        mult_reset <= 1;
                        mult_i1 <= tmp1;
                        mult_i2 <= a_in;
                        //tmp1 <= mult_out;
                    end
                end
            STATE7:
                begin
                    if (mult_busy) begin
                        mult_reset <= 0;
                    end else begin
                        tmp2 <= mult_out;
                    end
                end
            STATE4:
                begin
                    if (mult_busy) begin
                        mult_reset <= 0;
                    end else begin
                        mult_reset <= 1;
                        r <= tmp + tmp2;
                    end
                end
        endcase
    end
end

endmodule

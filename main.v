
/*******************************************************************************/
/** main.v for A7_LITE FPGA Board         ArchLab, Institute of Science Tokyo **/
/** 640 x 480 pixcel, 60Hz HDMI display module Version 0.2                    **/
/*******************************************************************************/
`default_nettype none
`timescale 1ns / 1ps

/*******************************************************************************/
  module tmds_encode (
     input wire clk         ,
     input wire [7:0] d_in  ,
     input wire [1:0] sync  ,
     input wire w_draw_area ,
     output reg [9:0] d_out
    );
    
    /***** Transition Minimized (8b -> 9b) *****/
    wire [3:0] w_nbs = d_in[0] + d_in[1] + d_in[2] + d_in[3] + d_in[4] + d_in[5] + d_in[6] + d_in[7];
    wire w_xnor = (w_nbs>4) || (w_nbs==4 && d_in[0]==0);
    wire [8:0] q_m = {~w_xnor, q_m[6:0] ^ d_in[7:1] ^ {7{w_xnor}}, d_in[0]};
    
    /***** DC-Balancing (9b -> 10b) *****/
    reg  [3:0] bal_acc = 0;
    wire [3:0] bal = q_m[0] + q_m[1] + q_m[2] + q_m[3] + q_m[4] + q_m[5] + q_m[6] + q_m[7] - 4;
    wire bal_sign_eq = (bal[3] == bal_acc[3]);
    wire invert_q_m = (bal==0 || bal_acc==0) ? ~q_m[8] : bal_sign_eq;
    wire [3:0] bal_acc_inc = bal - ({q_m[8] ^ ~bal_sign_eq} & ~(bal==0 || bal_acc==0));
    wire [3:0] bal_acc_t = invert_q_m ? bal_acc - bal_acc_inc : bal_acc + bal_acc_inc;
    wire [9:0] w_data = {invert_q_m, q_m[8], q_m[7:0] ^ {8{invert_q_m}}};

    always @(posedge clk) bal_acc <= w_draw_area ? bal_acc_t : 0;
    always @(posedge clk) d_out <= w_draw_area ? w_data : 
                                   (sync==3) ? 10'b1010101011 : 
                                   (sync==2) ? 10'b0101010100 :
                                   (sync==1) ? 10'b0010101011 : 10'b1101010100;
endmodule

/** TMDS (Transition Minimized Differential Signaling)                        **/
/*******************************************************************************/
module main (
   input  wire w_clk                  , 
   output wire tmds_r_p, tmds_r_n     , // red
   output wire tmds_g_p, tmds_g_n     , // green
   output wire tmds_b_p, tmds_b_n     , // blue
   output wire tmds_clk_p, tmds_clk_n   // clock
   );

    wire clk_pix;   //  25MHz clock signal
    wire clk_tmds;  // 250MHz clock signal
    clk_wiz_0 m0 (clk_pix, clk_tmds, w_clk);

    reg [9:0] r_x=0, r_y=0;
    reg hSync, vSync, w_draw_area;
    always @(posedge clk_pix) begin
        r_x <= (r_x==799) ? 0 : r_x+1;
        if(r_x==799) r_y <= (r_y==524) ? 0 : r_y+1;
        hSync <= (r_x>=656) && (r_x<752);
        vSync <= (r_y>=490) && (r_y<492);
        w_draw_area <= (r_x<640) && (r_y<480);
    end
    
    /***** generate a simple RGB pattern *****/
    reg [31:0] r_cnt=0;
    reg [7:0] red=0, green=0, blue=0, r_t=0;
    always @(posedge clk_pix) begin
        red   <=               (r_x <= 213) ? (213 - r_x[7:0]) + r_t : 0;
        green <= (r_x >  213 && r_x <= 426) ? (426 - r_x[7:0]) + r_t : 0;
        blue  <= (r_x >  426 && r_x <= 640) ? (640 - r_x[7:0]) + r_t : 0;
        r_cnt <= (r_cnt > (1000*1000)) ? 0 : r_cnt + 1;
        if(r_cnt==0) r_t <= r_t + 1;
    end

    wire [9:0] tmds_red, tmds_green, tmds_blue;
    tmds_encode m_enc1(clk_pix, red,   0            , w_draw_area, tmds_red);
    tmds_encode m_enc2(clk_pix, green, 0            , w_draw_area, tmds_green);
    tmds_encode m_enc3(clk_pix, blue , {vSync,hSync}, w_draw_area, tmds_blue);

    reg [3:0] tmds_cnt=0;
    reg [9:0] tmds_sft_red=0, tmds_sft_green=0, tmds_sft_blue=0;
    reg tmds_en=0;
    always @(posedge clk_tmds) begin ///// 250MHz clock is used
        tmds_en        <= (tmds_cnt==9);
        tmds_sft_red   <= tmds_en ? tmds_red   : tmds_sft_red  [9:1];
        tmds_sft_green <= tmds_en ? tmds_green : tmds_sft_green[9:1];
        tmds_sft_blue  <= tmds_en ? tmds_blue  : tmds_sft_blue [9:1];
        tmds_cnt       <= (tmds_cnt==9) ? 0 : tmds_cnt + 1;
    end

    OBUFDS #( .IOSTANDARD("DEFAULT"), .SLEW("SLOW") ) 
    m_ds1 (.O(tmds_r_p), .OB(tmds_r_n), .I(tmds_sft_red[0]));

    OBUFDS #( .IOSTANDARD("DEFAULT"), .SLEW("SLOW") ) 
    m_ds2 (.O(tmds_g_p), .OB(tmds_g_n), .I(tmds_sft_green[0]));

    OBUFDS #( .IOSTANDARD("DEFAULT"), .SLEW("SLOW") ) 
    m_ds3 (.O(tmds_b_p), .OB(tmds_b_n), .I(tmds_sft_blue[0]));

    OBUFDS #( .IOSTANDARD("DEFAULT"), .SLEW("SLOW") ) 
    m_ds4 (.O(tmds_clk_p), .OB(tmds_clk_n), .I(clk_pix));
endmodule
/*******************************************************************************/

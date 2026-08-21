`include "top.v"
`default_nettype none `timescale 1ps / 1ps
module tb_top;
    parameter FPGA_FRE = 32'd100_000_000;
    parameter SYS_FRE = 32'd50_000_000;
    parameter RAND_FRE = 32'd1000_000;
    parameter IN_FRE = 32'd100_000;
    parameter CHA_FRE = 32'd500_000;
    parameter CHB_FRE = 32'd1_000_000;
    parameter CODE_LEN = 7;
    parameter DATA_LEN = 4;
    parameter SEED_VAL = 32'h0;
    parameter NULL = 0;
    reg                 clk;
    reg                 rst_n;
    wire [DATA_LEN-1:0] out;

    top #(
        .FPGA_FRE(FPGA_FRE),
        .SYS_FRE (SYS_FRE),
        .RAND_FRE(RAND_FRE),
        .IN_FRE  (IN_FRE),
        .CHA_FRE (CHA_FRE),
        .CHB_FRE (CHB_FRE),
        .CODE_LEN(CODE_LEN),
        .DATA_LEN(DATA_LEN),
        .SEED_VAL(SEED_VAL),
        .NULL    (NULL)
    ) top_u (
        //system input
        .clk  (clk),
        .rst_n(rst_n),

        //data output
        .out(out)

        //control input
        // input wire data_en
    );

    localparam CLK_PERIOD = 10;
    localparam IN_PERIOD = 10_000;
    always #(CLK_PERIOD / 2) clk = ~clk;

    initial begin
        $dumpfile("tb_top.vcd");
        $dumpvars(0, tb_top);
    end

    initial begin
        #1 rst_n <= 1'bx;
        clk <= 1'bx;
        #(CLK_PERIOD * 1) rst_n <= 1;
        #(IN_PERIOD * 1) rst_n <= 0;
        clk <= 0;
        #(IN_PERIOD * 2) rst_n <= 1;
        #(IN_PERIOD * 200);
        $stop(0);
    end

endmodule
`default_nettype wire

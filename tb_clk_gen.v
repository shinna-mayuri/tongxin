`include "clk_gen.v"
`default_nettype none

module tb_clk_gen;
    reg  clk;
    reg  rst_n;
    wire clk_h;
    wire clk_l;
    wire clk_odd;
    clk_gen #(
        .IN_FRE  (32'd100_000_000),
        .HIGH_FRE(32'd10_000_000),
        .LOW_FRE (32'd10_000),
        .ODD_CNT (7)
    ) clk_gen_u (
        .clk_i(clk),
        .rst_n(rst_n),
        .clk_h(clk_h),
        .clk_l(clk_l),
        .clk_odd(clk_odd)
    );

    localparam CLK_PERIOD = 10;
    always #(CLK_PERIOD / 2) clk = ~clk;

    initial begin
        $dumpfile("tb_clk_gen.vcd");
        $dumpvars(0, tb_clk_gen);
    end

    initial begin
        #1 rst_n <= 1'bx;
        clk <= 1'bx;
        #(CLK_PERIOD * 3) rst_n <= 1;
        #(CLK_PERIOD * 3) rst_n <= 0;
        clk <= 0;
        #(CLK_PERIOD * 3) rst_n <= 1;
        #(CLK_PERIOD * 3000000);
        $stop(0);
    end

endmodule
`default_nettype wire

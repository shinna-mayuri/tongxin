`include "modulator.v"
`timescale 1ps / 1ps

module tb_modulator;
    localparam DATA_LEN = 7;


    reg                 clk_sys;
    reg                 rst_n;
    reg                 input_en;
    wire                output_en;
    reg  [DATA_LEN-1:0] data_in;
    wire                data_out;

    modulator #(
        .SYS_FRE (32'd100_000_000),
        .IN_FRE  (32'd1_000_000),
        .CHA_FRE (32'd5_000_000),
        .CHB_FRE (32'd10_000_000),
        .DATA_LEN(7),
        .NULL    (0)
    ) modulator_1 (
        .clk_sys  (clk_sys),
        .rst_n    (rst_n),
        .input_en (input_en),
        .output_en(output_en),
        .data_in  (data_in),
        .data_out (data_out)
    );
    

    localparam CLK_PERIOD = 10;
    localparam IN_PERIOD = 1000;
    always #(CLK_PERIOD / 2) clk_sys = ~clk_sys;
    integer i;

    initial begin
        input_en <= 1;
        data_in  <= 32'd10;
        for (i = 0; i < 10; i = i + 1) begin
            #(IN_PERIOD);
            data_in <= (data_in << 1);
        end
    end

    initial begin
        $dumpfile("tb_modulator.vcd");
        $dumpvars(0, tb_modulator);
    end

    initial begin
        rst_n   <= 1'b1;
        clk_sys <= 1'b0;
        #(CLK_PERIOD * 3) rst_n <= 0;
        #(CLK_PERIOD * 3) rst_n <= 1;
        #(IN_PERIOD * 15);
        $stop(0);
    end

endmodule

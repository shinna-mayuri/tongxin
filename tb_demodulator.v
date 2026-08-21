`include "demodulator.v"
`timescale 1ps / 1ps

module tb_demodulator;
    parameter SYS_FRE = 32'd100_000_000;
    parameter IN_FRE = 32'd100_000;
    parameter CHA_FRE = 32'd500_000;  //lower fre represent 0 and higer fre repersent 1
    parameter CHB_FRE = 32'd1_000_000;
    parameter DATA_LEN = 7;
    parameter NULL = 0;


    reg                 clk_sys;
    reg                 rst_n;
    wire                input_en_de;
    wire                output_en_de;
    wire                data_in_de;
    wire [DATA_LEN-1:0] data_out_de;
    reg                 input_en_mo;
    wire                output_en_mo;
    reg  [DATA_LEN-1:0] data_in_mo;
    wire                data_out_mo;

    assign data_in_de  = data_out_mo;
    assign input_en_de = output_en_mo;



    demodulator #(
        .SYS_FRE (SYS_FRE),
        .IN_FRE  (IN_FRE),
        .CHA_FRE (CHA_FRE),   //lower fre represent 0 and higer fre repersent 1
        .CHB_FRE (CHB_FRE),
        .DATA_LEN(DATA_LEN),
        .NULL    (NULL)
    ) u_1 (
        .clk_sys  (clk_sys),
        .rst_n    (rst_n),
        .input_en (input_en_de),
        .output_en(output_en_de),
        .data_in  (data_in_de),
        .data_out (data_out_de)
    );


    modulator #(
        .SYS_FRE (SYS_FRE),
        .IN_FRE  (IN_FRE),
        .CHA_FRE (CHA_FRE),   //lower fre represent 0 and higer fre repersent 1
        .CHB_FRE (CHB_FRE),
        .DATA_LEN(DATA_LEN),
        .NULL    (NULL)
    ) u_2 (
        .clk_sys  (clk_sys),
        .rst_n    (rst_n),
        .input_en (input_en_mo),
        .output_en(output_en_mo),
        .data_in  (data_in_mo),
        .data_out (data_out_mo)
    );

    localparam CLK_PERIOD = 10;
    localparam IN_PERIOD = 10_000;

    always #(CLK_PERIOD / 2) clk_sys = ~clk_sys;
    integer i;

    initial begin
        #30 input_en_mo = 1'b1;
        data_in_mo <= 32'd10;
        for (i = 0; i < 10; i = i + 1) begin
            #(IN_PERIOD*DATA_LEN);
            data_in_mo <= (data_in_mo + 32'h1234);
        end
    end

    initial begin
        $dumpfile("tb_demodulator.vcd");
        $dumpvars(0, tb_demodulator);
    end

    initial begin
        rst_n   <= 1'b1;
        clk_sys <= 1'b0;
        #(CLK_PERIOD * 3) rst_n <= 0;
        #(CLK_PERIOD * 3) rst_n <= 1;
        #(IN_PERIOD * 200);
        $stop(0);
    end

endmodule

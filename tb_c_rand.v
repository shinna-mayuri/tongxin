`timescale 1ns / 1ps
`define PERIOD 10
module tb_c_rand ();
    reg clk, rst_n, reseed;
    reg  [31:0] seed_val;
    // integer waiting_time;
    wire        out;

    c_rand c_rand_u (
        .clk     (clk),
        .rst_n   (rst_n),
        .reseed  (reseed),
        .seed_val(seed_val),
        .out     (out)
    );

    always #(`PERIOD / 2) clk = ~clk;

    initial begin
        clk = 1'b0;
        rst_n = 1'b1;
        reseed = 1'b0;
        seed_val = 32'b0;
        // waiting_time = {$random} % 15000 * 100;
        #(`PERIOD * 5) rst_n = 1'b0;
        #(`PERIOD * 5) rst_n = 1'b1;
        #(`PERIOD * 100);
        $stop(0);
    end
endmodule

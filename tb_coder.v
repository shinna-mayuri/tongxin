module tb_coder;
    reg        clk;
    reg        rst_n;
    reg  [3:0] encode_data;
    wire [6:0] encode_code;
    wire [6:0] decode_code;
    wire [3:0] decode_data;

    assign decode_code[0] = encode_code[0];
    assign decode_code[1] = encode_code[1];
    assign decode_code[2] = encode_code[2];
    assign decode_code[3] = encode_code[3];
    assign decode_code[4] = encode_code[4];
    assign decode_code[5] = encode_code[5];
    assign decode_code[6] = ~encode_code[6];

    hamming_encode encode_u (
        .data(encode_data),
        .code(encode_code)
    );

    hamming_decode decode_u (
        .clk  (clk),
        .reset(~rst_n),
        .code (decode_code),
        .data (decode_data)
    );

    localparam CLK_PERIOD = 10;
    always #(CLK_PERIOD / 2) clk = ~clk;
    integer i;
    initial begin
        $dumpfile("tb_coder.vcd");
        $dumpvars(0, tb_coder);
    end

    initial begin
        #5 encode_data <= 4'h1;
        for (i = 0; i < 20; i = i + 1) begin
            #(CLK_PERIOD) encode_data <= encode_data + 1;
        end
    end

    initial begin
        #1 rst_n <= 1'bx;
        clk <= 1'bx;
        #(CLK_PERIOD * 3) rst_n <= 1;
        #(CLK_PERIOD * 3) rst_n <= 0;
        clk <= 0;
        #(CLK_PERIOD * 3) rst_n <= 1;
        @(CLK_PERIOD * 30);
        $stop(1);
    end

endmodule

module top #(
    parameter FPGA_FRE = 32'd100_000_000,
    parameter SYS_FRE  = 32'd100_000_000,
    parameter RAND_FRE = 32'd1_000_000,
    parameter IN_FRE   = 32'd5,
    parameter CHA_FRE  = 32'd1_00,
    parameter CHB_FRE  = 32'd2_00,
    parameter CODE_LEN = 7,
    parameter DATA_LEN = 4,
    parameter SEED_VAL = 32'h0,
    parameter NULL     = 0
) (
    //system input
    input wire clk,
    input wire rst_n,

    //data output
    output reg [DATA_LEN-1:0] out,
    output reg [DATA_LEN-1:0] rand_out,
    //control input
    // input wire data_en
    output reg fsk_out
);
    //clk and rst_n
    wire clk_h;
    wire clk_l;
    wire clk_odd;
    //controller

    //c_rand
    wire [DATA_LEN-1:0] c_rand_out;
    wire               reseed;  //not connected

    //module hamming_encode
    wire [3:0] ham_en_data;
    wire [6:0] ham_en_code;

    //module modulator 
    wire                input_en_mo;  //not connected
    wire                output_en_mo;
    wire [CODE_LEN-1:0] data_in_mo;
    wire                data_out_mo;

    //module demodulator 
    wire                input_en_de;
    wire                output_en_de;  //not connected
    wire                data_in_de;
    wire [CODE_LEN-1:0] data_out_de;

    //module hamming_decode
    wire [6:0] ham_de_code;
    wire [3:0] ham_de_data;

    //led show
    reg [DATA_LEN-1:0] out_delay;

    clk_gen #(
        .IN_FRE  (FPGA_FRE),
        .HIGH_FRE(RAND_FRE),
        .LOW_FRE (IN_FRE),
        .ODD_CNT (CODE_LEN)
    ) clk_gen_u (
        .clk_i(clk),
        .rst_n(rst_n),
        .clk_h(clk_h),
        .clk_l(clk_l),
        .clk_odd(clk_odd)
    );

    c_rand #(
        .SEED_VAL(SEED_VAL),
        .OUT_LEN (DATA_LEN)
    ) c_rand_u (
        .clk   (clk_odd),
        .rst_n (rst_n),
        .reseed(1'b0),
        .out   (c_rand_out)
    );

    always @(*) begin
        rand_out <= c_rand_out;
    end
    // add one_cycle delay to rand_out
    // always @(posedge clk_odd or negedge rst_n) begin
    //     rand_out <= c_rand_out;
    // end

    hamming_encode hamming_encode_u (
        .data(ham_en_data),
        .code(ham_en_code)
    );



    modulator #(
        .SYS_FRE (SYS_FRE),
        .IN_FRE  (IN_FRE),
        .CHA_FRE (CHA_FRE),
        .CHB_FRE (CHB_FRE),
        .DATA_LEN(CODE_LEN),
        .NULL    (NULL)
    ) modulator_u (
        .clk_sys  (clk),
        .rst_n    (rst_n),
        // .input_en (input_en_mo),
        .input_en (1'b1),
        .output_en(output_en_mo),
        .data_in  (data_in_mo),
        .data_out (data_out_mo)
    );


    demodulator #(
        .SYS_FRE (SYS_FRE),
        .IN_FRE  (IN_FRE),
        .CHA_FRE (CHA_FRE),   //lower fre represent 0 and higer fre repersent 1
        .CHB_FRE (CHB_FRE),
        .DATA_LEN(CODE_LEN),
        .NULL    (NULL)
    ) demodulator_u (
        .clk_sys  (clk),
        .rst_n    (rst_n),
        .input_en (input_en_de),
        .output_en(output_en_de),
        .data_in  (data_in_de),
        .data_out (data_out_de)
    );

    hamming_decode hamming_decode_u (
        .clk  (clk_l),
        .reset(~rst_n),
        .code (ham_de_code),
        .data (ham_de_data)
    );

    // c_out -> hamming_encode
    assign ham_en_data = c_rand_out;
    // hamming_encode -> modulator
    assign data_in_mo = ham_en_code;

    //channel 
    assign data_in_de  = data_out_mo;
    always @(*) begin
        fsk_out <= data_out_mo;
    end
    assign input_en_de = output_en_mo;
    // demodulator -> hamming_decode
    assign ham_de_code = data_out_de;
    // output
    always @(*) begin
        out<= output_en_de ? ham_de_data : 4'b0;
    end
    // always @(*) begin
    //     out<= output_en_de ? ham_de_data : 4'b0;
    // end

    // always @(posedge clk_odd or negedge rst_n) begin
    //    out<= out_delay; 
    // end

endmodule

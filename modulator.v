module modulator #(
    parameter SYS_FRE  = 32'd100_000_000,
    parameter IN_FRE   = 32'd100_000,
    parameter CHA_FRE  = 32'd500_000,
    parameter CHB_FRE  = 32'd1_000_000,
    parameter DATA_LEN = 7,
    parameter NULL     = 0
) (
    input  wire                clk_sys,
    input  wire                rst_n,
    input  wire                input_en,
    output reg                 output_en,
    input  wire [DATA_LEN-1:0] data_in,
    output reg                 data_out
);


    localparam IN_CNT = SYS_FRE / IN_FRE;
    localparam CHA_CNT = (SYS_FRE / CHA_FRE) / 2;
    localparam CHB_CNT = (SYS_FRE / CHB_FRE) / 2;
    localparam DATA_BIT_LEN = $clog2(DATA_LEN);
    localparam IN_CNT_LEN = $clog2(IN_CNT);
    localparam CHA_CNT_LEN = $clog2(CHA_CNT);
    localparam CHB_CNT_LEN = $clog2(CHB_CNT);

    localparam S_IDLE = 2'b00;
    localparam S_GET_DATA = 2'b01;
    localparam S_SEND_DATA = 2'b10;

    reg [ DATA_BIT_LEN:0] data_bit_cnt;
    reg [ IN_CNT_LEN-1:0] in_cnt;
    reg [CHA_CNT_LEN-1:0] cha_cnt;
    reg [CHB_CNT_LEN-1:0] chb_cnt;

    reg [   DATA_LEN-1:0] data_in_reg;
    reg                   cha_out;
    reg                   chb_out;

    reg [            1:0] cur_state;
    reg [            1:0] nxt_state;



    // state move
    always @(posedge clk_sys or negedge rst_n) begin
        if (!rst_n) begin
            cur_state <= S_IDLE;
        end
        else cur_state <= nxt_state;
    end

    //  state decide

    always @(*) begin
        if (!rst_n) begin
            nxt_state <= S_IDLE;
        end
        else begin
            case (cur_state)
                S_IDLE: begin
                    if (input_en) begin
                        nxt_state <= S_GET_DATA;
                    end
                    else begin
                        nxt_state <= S_IDLE;
                    end
                end

                S_GET_DATA: begin
                    nxt_state <= S_SEND_DATA;
                end

                S_SEND_DATA: begin
                    if (data_bit_cnt == DATA_LEN) begin
                        if (input_en) begin
                            nxt_state <= S_GET_DATA;
                        end
                        else nxt_state <= S_IDLE;
                    end
                    else begin
                        nxt_state <= S_SEND_DATA;
                    end
                end

                default: nxt_state <= S_IDLE;
            endcase
        end
    end


    // output of state

    always @(posedge clk_sys or negedge rst_n) begin
        if (!rst_n) begin

        end
        else begin
            case (nxt_state)
                S_IDLE: begin
                    data_bit_cnt <= 0;
                    in_cnt <= 0;
                    cha_cnt <= 0;
                    chb_cnt <= 0;

                    data_out <= 0;
                    output_en <= 0;
                end

                S_GET_DATA: begin
                    data_bit_cnt <= 0;
                    in_cnt <= 0;
                    cha_cnt <= 0;
                    chb_cnt <= 0;
                    data_out <= 0;
                    output_en <= 0;
                    data_in_reg <= data_in;

                    cha_out <= 0;
                    chb_out <= 0;
                end

                S_SEND_DATA: begin
                    if (in_cnt == IN_CNT - 1) begin
                        data_bit_cnt <= data_bit_cnt + 1;
                        in_cnt <= 0;
                    end
                    else begin
                        data_bit_cnt <= data_bit_cnt;
                        in_cnt <= in_cnt + 1;
                    end

                    if (cha_cnt == CHA_CNT - 1) begin
                        cha_cnt <= 0;
                        cha_out <= ~cha_out;
                    end
                    else begin
                        cha_cnt <= cha_cnt + 1;
                        cha_out <= cha_out;
                    end

                    if (chb_cnt == CHB_CNT - 1) begin
                        chb_cnt <= 0;
                        chb_out <= ~chb_out;
                    end
                    else begin
                        chb_cnt <= chb_cnt + 1;
                        chb_out <= chb_out;
                    end


                    data_out  <= data_in_reg[data_bit_cnt] ? cha_out : chb_out;
                    output_en <= 1'b1;
                end
                default: begin
                    data_bit_cnt <= 0;
                    in_cnt <= 0;
                    cha_cnt <= 0;
                    chb_cnt <= 0;

                    data_out <= 0;
                    output_en <= 0;
                end
            endcase
        end
    end
    //best use state machine,if don't want much bug

endmodule

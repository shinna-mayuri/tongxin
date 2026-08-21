module demodulator #(
    parameter SYS_FRE  = 32'd100_000_000,
    parameter IN_FRE   = 32'd100_000,
    parameter CHA_FRE  = 32'd500_000,      //lower fre represent 1 and higer fre repersent 0
    parameter CHB_FRE  = 32'd1_000_000,
    parameter DATA_LEN = 7,
    parameter NULL     = 0
) (
    input  wire                clk_sys,
    input  wire                rst_n,
    input  wire                input_en,
    output reg                 output_en,
    input  wire                data_in,
    output reg  [DATA_LEN-1:0] data_out
);

    localparam IN_CNT = SYS_FRE / IN_FRE;
    localparam CHA_CNT = (CHA_FRE > CHB_FRE) ? ((CHB_FRE / IN_FRE) * 2) : ((CHA_FRE / IN_FRE) * 2);
    localparam CHB_CNT = (CHA_FRE > CHB_FRE) ? ((CHA_FRE / IN_FRE) * 2) : ((CHB_FRE / IN_FRE) * 2);
    localparam CH_JUDGE = (CHA_CNT + CHB_CNT) / 2;  // set that b is larger
    localparam CH_CNT = (CHA_CNT > CHB_CNT) ? CHA_CNT : CHB_CNT;
    localparam DATA_BIT_LEN = $clog2(DATA_LEN);
    localparam IN_CNT_LEN = $clog2(IN_CNT);
    localparam CH_CNT_LEN = $clog2(CH_CNT);

    localparam S_IDLE = 2'b00;
    localparam S_GET_DATA = 2'b01;
    localparam S_SEND_DATA = 2'b10;

    reg  [DATA_BIT_LEN:0] data_bit_cnt;
    reg  [IN_CNT_LEN-1:0] in_cnt;
    reg  [  CH_CNT_LEN:0] ch_cnt;

    reg  [           3:0] data_in_dly;
    wire                  data_in_edge;

    reg  [  DATA_LEN-1:0] data_out_reg;

    reg  [           1:0] cur_state;
    reg  [           1:0] nxt_state;



    //  data delay and edge detect
    always @(posedge clk_sys or negedge rst_n) begin
        if (!rst_n) begin
            data_in_dly <= 0;
        end
        else if (input_en) begin
            data_in_dly[3:1] <= data_in_dly[2:0];
            data_in_dly[0]   <= data_in;
        end
        else begin
            data_in_dly <= 0;
        end
    end

    assign data_in_edge = (data_in_dly == 4'b1100) | (data_in_dly == 4'b0011);



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
                    if (data_bit_cnt == DATA_LEN) begin
                        nxt_state <= S_SEND_DATA;
                    end
                    else begin
                        nxt_state <= S_GET_DATA;
                    end
                end

                S_SEND_DATA: begin
                    if (input_en) begin  ///maybe need more delay, need more test
                        nxt_state <= S_GET_DATA;
                    end
                    else nxt_state <= S_IDLE;
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
                    ch_cnt <= 0;

                    data_out <= 0;
                    output_en <= 0;
                end

                S_GET_DATA: begin
                    if (in_cnt == IN_CNT - 1) begin
                        data_bit_cnt <= data_bit_cnt + 1;
                        in_cnt <= 0;
                        ch_cnt <= 0;
                    end
                    else if (data_in_edge) begin
                        ch_cnt <= ch_cnt + 1;
                        data_bit_cnt <= data_bit_cnt;
                        in_cnt <= in_cnt + 1;
                    end
                    else begin
                        ch_cnt <= ch_cnt;
                        data_bit_cnt <= data_bit_cnt;
                        in_cnt <= in_cnt + 1;
                    end

                    if (in_cnt == IN_CNT - 1) begin
                        if (ch_cnt > CH_JUDGE) begin
                            data_out_reg[data_bit_cnt] <= 1'b0;
                        end
                        else begin
                            data_out_reg[data_bit_cnt] <= 1'b1;
                        end
                    end
                    else begin
                        data_out_reg<=data_out_reg;
                    end

                    data_out  <= data_out;
                    output_en <= output_en;

                end

                S_SEND_DATA: begin
                    data_bit_cnt <= 0;
                    in_cnt <= 0;
                    ch_cnt <= 0;

                    data_out  <= data_out_reg;
                    data_out_reg <= 0;
                    output_en <= 1'b1;
                end
                default: begin
                    data_bit_cnt <= 0;
                    in_cnt <= 0;
                    ch_cnt <= 0;

                    data_out <= data_out;
                    data_out_reg <= data_out_reg;
                    output_en <= output_en;
                end
            endcase
        end
    end
    //best use state machine,if don't want much bug

endmodule

module clk_gen #(
    parameter IN_FRE   = 32'd60_000_000,
    parameter HIGH_FRE = 32'd10_000_000,
    parameter LOW_FRE  = 32'd10_000,
    parameter ODD_CNT = 7
) (
    input wire clk_i,
    input wire rst_n,

    //
    output reg clk_h,
    output reg clk_l,
    output reg clk_odd

);
    localparam HIGH_CNT = (IN_FRE / HIGH_FRE) / 2;
    localparam HIGH_CNT_LEN = $clog2(HIGH_CNT);
    localparam LOW_CNT = (IN_FRE / LOW_FRE) / 2;
    localparam LOW_CNT_LEN = $clog2(LOW_CNT);

    reg [HIGH_CNT_LEN-1:0] high_cnt;
    reg [ LOW_CNT_LEN-1:0] low_cnt;

    always @(posedge clk_i or negedge rst_n) begin
        if (!rst_n) begin
            high_cnt <= 0;
            clk_h <= 0;
        end
        else if (high_cnt == HIGH_CNT - 1) begin
            high_cnt <= 0;
            clk_h <= ~clk_h;
        end
        else begin
            high_cnt <= high_cnt + 1;
            clk_h <= clk_h;
        end
    end

    always @(posedge clk_i or negedge rst_n) begin
        if (!rst_n) begin
            low_cnt <= 0;
            clk_l   <= 0;
        end
        else if (low_cnt == LOW_CNT - 1) begin
            low_cnt <= 0;
            clk_l   <= ~clk_l;
        end
        else begin
            low_cnt <= low_cnt + 1;
            clk_l   <= clk_l;
        end
    end

    // odd divider
    localparam ODD_CNT_HAF = ODD_CNT/2;
    localparam ODD_CNT_LEN = $clog2(ODD_CNT);
    reg [ODD_CNT_LEN-1:0] neg_cnt;
    reg [ODD_CNT_LEN-1:0] pos_cnt;
    reg clk_odd_n;
    reg clk_odd_p;
    //neg part
    always @(negedge clk_l or negedge rst_n) begin
        if (!rst_n) begin
            neg_cnt<=0;
            clk_odd_n<=0;
        end
        else if (neg_cnt == ODD_CNT- 1) begin
            clk_odd_n<=~clk_odd_n;
            neg_cnt<=0;
        end
        else if (neg_cnt == ODD_CNT_HAF ) begin
            clk_odd_n<=~clk_odd_n;
            neg_cnt<=neg_cnt+1;
        end
        else begin
            clk_odd_n<=clk_odd_n;
            neg_cnt<=neg_cnt+1;
        end
    end
    //pos part
    always @(posedge clk_l or negedge rst_n) begin
        if (!rst_n) begin
            pos_cnt<=0;
            clk_odd_p<=0;
        end
        else if (pos_cnt == ODD_CNT- 1) begin
            clk_odd_p<=~clk_odd_p;
            pos_cnt<=0;
        end
        else if (pos_cnt == ODD_CNT_HAF ) begin
            clk_odd_p<=~clk_odd_p;
            pos_cnt<=pos_cnt+1;
        end
        else begin
            clk_odd_p<=clk_odd_p;
            pos_cnt<=pos_cnt+1;
        end
    end

    always @(*) begin
        clk_odd<=clk_odd_n || clk_odd_p;
    end 
endmodule

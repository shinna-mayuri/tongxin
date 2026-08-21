// editor  zzy

module c_rand #(
    parameter SEED_VAL = 32'h0,
    parameter OUT_LEN  = 4
) (
    input  wire               clk,
    input  wire               rst_n,
    input  wire               reseed,
    output wire [OUT_LEN-1:0] out
);

    reg [31:0] state;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) state <= 0;
        else begin
            if (reseed) state <= SEED_VAL;
            else state <= state * 32'h343fd + 32'h269EC3;
        end
    end

    assign out = ((state >> 16) & 16'h7fff);

endmodule

// 实现7-4汉明码的decode，其中校验矩阵H为
// 1 1 1 0 1 0 0
// 1 1 0 1 0 1 0
// 1 0 1 1 0 0 1
// 输入code共7位，其中第1个输入放在code[0]，第7个输入放在code[6]
// 输出data共4位，其中第1个输出放在data[0]，第4个输出放在data[3]
// 同时实现纠1位错的功能，即如果code中有1位出错，则将其纠正

module hamming_decode(
    input wire clk,
    input wire  reset,
    input wire [6:0] code,
    output reg [3:0] data
);



    wire [2:0] judge;

    assign judge[0] = code[0] ^ code[1] ^ code[2] ^ code[4];
    assign judge[1] = code[0] ^ code[1] ^ code[3] ^ code[5];
    assign judge[2] = code[0] ^ code[2] ^ code[3] ^ code[6];

    always @(posedge reset or posedge clk) 
    begin
        if (reset) 
            begin
                data <= 4'b0000;
            end
        else
        begin
            if (judge == 3'b111) 
                begin
                    data[0] <= ~code[0];
                    data[1] <= code[1];
                    data[2] <= code[2];
                    data[3] <= code[3];
                end
            else if (judge == 3'b011) 
                begin
                    data[0] <= code[0];
                    data[1] <= ~code[1];
                    data[2] <= code[2];
                    data[3] <= code[3];
                end
            else if (judge == 3'b101) 
                begin
                    data[0] <= code[0];
                    data[1] <= code[1];
                    data[2] <= ~code[2];
                    data[3] <= code[3];
                end
            else if (judge == 3'b110) 
                begin
                    data[0] <= code[0];
                    data[1] <= code[1];
                    data[2] <= code[2];
                    data[3] <= ~code[3];
                end
            else
            begin
                data[0] <= code[0];
                data[1] <= code[1];
                data[2] <= code[2];
                data[3] <= code[3];
            end
        end
    end

endmodule


//decode cannot correct 1 bit wrong code, need update   10.15
// 实现7-4汉明码的encode，其中生成矩阵G为
// 1 0 0 0 1 1 1
// 0 1 0 0 1 1 0
// 0 0 1 0 1 0 1
// 0 0 0 1 0 1 1
// 输入data共4位，其中第1个输入放在data[0]，第4个输入放在data[3]
// 输出code共7位，其中第1个输出放在code[0]，第7个输出放在code[6]

module hamming_encode(
    input wire [3:0] data,
    output wire [6:0] code
    );

    // wire [3:0] data;
    // wire [6:0] code;
    assign code[0] = data[0];
    assign code[1] = data[1];
    assign code[2] = data[2];
    assign code[3] = data[3];
    assign code[4] = data[0] ^ data[1] ^ data[2];
    assign code[5] = data[0] ^ data[1] ^ data[3];
    assign code[6] = data[0] ^ data[2] ^ data[3];

endmodule
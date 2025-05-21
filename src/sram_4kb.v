module sram_4kb (
    input wire [9:0] a,
    input wire [31:0] wd,
    input wire [3:0] wen,
    input wire clk,
    input wire cs,
    output reg [31:0] rd
);

    reg [31:0] mem_array [0:1023];

    always @ (posedge clk) begin
        if (cs)
            if (wen[3:0] == 4'b0000) begin
                rd <= mem_array[a];
            end else begin
                mem_array[a][7 :0 ] <= wen[0] ? wd[7: 0 ] : mem_array[a][7 :0 ];
                mem_array[a][15:8 ] <= wen[1] ? wd[15:8 ] : mem_array[a][15:8 ];
                mem_array[a][23:16] <= wen[2] ? wd[23:16] : mem_array[a][23:16];
                mem_array[a][31:24] <= wen[3] ? wd[31:24] : mem_array[a][31:24];
            end
    end

endmodule
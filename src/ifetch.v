/* Instruction fetch module
At each clock cycle, outputs the next instruction at the next program counter value.
If the program is jumping, the next pc value is determined by the execution stage output,
else it is the previous cycle's pc value incremented by 4.
*/
module ifetch #(
    parameter RESET_VECTOR = 32'hFFFFFFFC
) (
    input wire clk,
    input wire rst_n,
    input wire e_valid,
    input wire [31:0] e_pc_next,
    input wire jump_select,
    input wire e_clk_en,
    output reg i_clk_en,
    output reg i_valid,
    output reg [31:0] f_instr_next,
    output reg [31:0] f_pc_next
);  

    reg [31:0] i_pc;
    reg [31:0] i_pc_next;
    reg cs;
    wire flush;
    wire [31:0] i_instr;


    sram_4kb instr_mem (
        .a(i_pc_next[11:2]),
        .wd(32'bx),
        .wen(4'b0000),
        .cs(cs),
        .clk(clk),
        .rd(i_instr)
    );

    always @ (posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            i_pc <= RESET_VECTOR;
            i_valid <= 1'b0;
        end else if (i_clk_en) begin
            i_pc <= i_pc_next;
            i_valid <= 1'b1;
        end
    end

    assign flush = jump_select;

    always @* begin
        // clock enables: only clock next cycle
        cs = rst_n && (flush || (e_valid && (e_clk_en || !i_valid)));
        i_clk_en = flush || (e_valid && (e_clk_en || !i_valid)); 

        i_pc_next = jump_select ? e_pc_next : i_pc + 4;
        f_instr_next = i_instr;
        f_pc_next = i_pc;
    end     

endmodule
/*
module cpu_ifetch (
    input wire clk, 
    input wire rst_n,
    input wire i_inp_rdy,
    input wire e_j_flag,
    input wire [31:0] e_pc_next,
    output reg i_otp_rdy,
    output wire [31:0] f_instr, 
    output reg [31:0] f_pc
);  

    reg [31:0] i_pc;
    reg [31:0] i_pc_next;
    reg i_otp_rdy_next;
    
    sram_4kb instr_mem (
        .a(i_pc[11:2]),
        .wd(32'bx),
        .wen(4'b0),
        .m_inp_rdy(i_inp_rdy && !e_j_flag),
        .m_otp_rdy(),
        .clk(clk),
        .rd(f_instr)
    );

    always @ (posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            i_pc <= 32'h0;
            f_pc <= 32'h0;
            i_otp_rdy <= 1'b0;
        end else if (i_inp_rdy) begin
            i_pc <= i_pc_next;
            f_pc <= e_j_flag ? f_pc : i_pc;
            i_otp_rdy <= i_otp_rdy_next;
        end 
    end

    always @* begin
        i_otp_rdy_next = i_inp_rdy;
        if (e_j_flag)
            i_pc_next = e_pc_next;
        else
            i_pc_next = i_pc + 4;
    end

endmodule
*/
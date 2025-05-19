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
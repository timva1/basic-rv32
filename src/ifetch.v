module cpu_ifetch (
    input wire clk, 
    input wire rst_n,
    input wire i_inp_rdy,
    output reg i_otp_rdy,
    output wire [31:0] f_instr, 
    output reg [31:0] f_pc
);  

    reg [31:0] i_pc;
    reg [31:0] i_pc_next;
    
    sram_4kb instr_mem (
        .a(i_pc[11:2]),
        .wd(32'b0),
        .wen(4'b0),
        .m_inp_rdy(i_inp_rdy),
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
            f_pc <= i_pc;
            i_otp_rdy <= 1'b1;
        end 
    end

    always @* begin
        i_pc_next = i_pc + 4;
    end

endmodule
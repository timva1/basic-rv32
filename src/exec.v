module exec (
    input wire clk,
    input wire rst_n,
    input wire [31:0] f_instr_next,
    input wire [31:0] f_pc_next,
    input wire i_valid,
    input wire i_clk_en,
    output reg e_valid,
    output reg jump_select,
    output reg [31:0] e_pc_next,
    output reg halted,
    output reg e_clk_en
);

    reg [31:0] f_instr;
    reg [31:0] f_pc;

    reg [31:0] sram_addr;
    reg [3:0] sram_wen;
    wire [31:0] sram_rd;

    wire [31:0] rsrc1 = regfile[rs1];
    wire [31:0] rsrc2 = regfile[rs2];
    reg [31:0] rdest;
    reg [31:0] e_pc;

    reg [63:0] mul_full_width;

    reg halted_next;
    reg e_valid_next;
    reg cs;

    reg sram_rd_ready;
    reg sram_rd_ready_next;

    reg jump_started;

    reg stall_last;

    sram_4kb sram (
        .clk(clk),
        .a(sram_addr[11:2]),
        .wd(rsrc2),
        .wen(sram_wen),
        .cs(cs),
        .rd(sram_rd)
    );

    always @ (posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            regfile[0] <= 32'b0;
            e_valid <= 1'b1;
            e_pc <= 32'b0;
            f_instr <= 32'h13; // nop
            f_pc <= 32'b0;
            halted <= 1'b0;
            jump_started <= 1'b0;
            stall_last <= 1'b0;
        end else begin
            stall_last <= !e_clk_en;
            halted <= halted_next;
            if (e_clk_en) begin
                e_valid <= e_valid_next;
                e_pc <= e_pc_next;
                f_instr <= f_instr_next;
                f_pc <= f_pc_next;
                if (rd != 0)
                    regfile[rd] <= rdest;
            end
        end
    end

    always @* begin
        jump_select = 1'b0;
        e_pc_next = 32'b0;
        e_clk_en = i_valid;
        e_valid_next = 1'b1;
        cs = 1'b0;
        sram_wen = 4'bx;
        sram_addr = 32'bx;
        rdest = regfile[rd];
        halted_next = 1'b0;

        casez (opcode)
            7'b0110011: begin // R-type
                case (funct3)
                    3'b000: 
                        if (funct7[0]) begin
                            mul_full_width = ($signed(rsrc1) * $signed(rsrc2));
                            rdest = mul_full_width[31:0];
                        end else
                            if (funct7[5])
                                rdest = rsrc1 - rsrc2;
                            else
                                rdest = rsrc1 + rsrc2;
                    3'b100:
                        if (funct7[0]) begin
                            rdest = $signed(rsrc1) / $signed(rsrc2);
                        end else
                            rdest = rsrc1 ^ rsrc2;
                    3'b110:
                        if (funct7[0]) begin
                            rdest = $signed(rsrc1) % $signed(rsrc2);
                        end else
                            rdest = rsrc1 | rsrc2;
                    3'b111:
                        if (funct7[0])
                            rdest = rsrc1 % rsrc2;
                        else
                            rdest = rsrc1 & rsrc2;
                    3'b001:
                        if (funct7[0]) begin
                            mul_full_width = ($signed(rsrc1) * $signed(rsrc2));
                            rdest = mul_full_width[63:32];
                        end else
                            rdest = rsrc1 << rsrc2[4:0];
                    3'b101:
                        if (funct7[0])
                            rdest = rsrc1 / rsrc2;
                        else
                            if (funct7[5])
                                rdest = $signed(rsrc1) >>> rsrc2[4:0];
                            else
                                rdest = rsrc1 >> rsrc2[4:0];
                    3'b010:
                        if (funct7[0]) begin
                            mul_full_width = ($signed(rsrc1) * $unsigned(rsrc2));
                            rdest = mul_full_width[63:32];
                        end else
                            rdest = {31'b0, $signed(rsrc1) < $signed(rsrc2)};
                    3'b011:
                        if (funct7[0]) begin
                            mul_full_width = (rsrc1 * rsrc2);
                            rdest = mul_full_width[63:32];
                        end else
                            rdest = {31'b0, rsrc1 < rsrc2};
                endcase
            end

            7'b0010011: begin // I-type arithmetic
                case (funct3)
                    3'b000:
                        rdest = rsrc1 + {{20{imm_i[11]}}, imm_i};
                    3'b100:
                        rdest = rsrc1 ^ {{20{imm_i[11]}}, imm_i};
                    3'b110:
                        rdest = rsrc1 | {{20{imm_i[11]}}, imm_i};
                    3'b111:
                        rdest = rsrc1 & {{20{imm_i[11]}}, imm_i};
                    3'b001:
                        rdest = rsrc1 << imm_i[4:0];
                    3'b101:
                        if (imm_i[10])
                            rdest = $signed(rsrc1) >>> imm_i[4:0];
                        else
                            rdest = rsrc1 >> imm_i[4:0];
                    3'b010:
                        rdest = {
                            31'b0, 
                            $signed(rsrc1) < $signed({{20{imm_i[11]}}, imm_i})
                            };
                    3'b011:
                        rdest = {
                            31'b0,
                            rsrc1 < {{20{imm_i[11]}}, imm_i}
                        };
                endcase
            end

            7'b0z10111: begin // U-type
                if (opcode[5]) // lui
                    rdest = {imm_u, 12'b0}; // lower 12 bits set to 0
                else // auipc TODO: test this command (not possible without very large jumps, with 100s of KBs of instruction data)
                    rdest = f_pc + {imm_u, 12'b0}; // lower 12 bits treated as 0
            end

            7'b0100011: begin // S-type

                sram_addr = rsrc1 + {{20{imm_s[11]}}, imm_s};
                cs = 1'b1;

                case (funct3)
                    3'b000: // sb
                        sram_wen = 4'b0001;
                    3'b001: // sh
                        sram_wen = 4'b0011;
                    3'b010: // sw
                        sram_wen = 4'b1111;
                endcase
            end

            7'b0000011: begin // I-type loads

                e_valid_next = i_valid && stall_last;
                e_clk_en = i_valid && stall_last;
                cs = !e_clk_en;
                sram_addr = rsrc1 + {{20{imm_i[11]}}, imm_i};
                sram_wen = 4'b0000;

                case (funct3)
                    3'b000: // lb
                        rdest = {{24{sram_rd[7]}}, sram_rd[7:0]};
                    3'b001: // lh
                        rdest = {{16{sram_rd[15]}}, sram_rd[15:0]};
                    3'b010: // lw
                        rdest = sram_rd;
                    3'b100: // lbu
                        rdest = {24'b0, sram_rd[7:0]};
                    3'b101: // lhu
                        rdest = {16'b0, sram_rd[15:0]};
                endcase
            end

            7'b1100111: begin // I-type jalr
                e_clk_en = i_valid && stall_last;
                rdest = f_pc + 4;
                e_pc_next = rsrc1 + {{20{imm_i[11]}}, imm_i};
                jump_select = !stall_last;
            end

            7'b1101111: begin // J-type (jump)
                e_clk_en = i_valid && stall_last;
                rdest = f_pc + 4;
                e_pc_next = f_pc + imm_j;
                jump_select = !stall_last;
            end

            7'b1100011: begin // B-type
                case (funct3)
                    3'b000: begin // beq
                        if (rsrc1 == rsrc2) begin
                            e_clk_en = i_valid && stall_last;
                            e_pc_next = f_pc + imm_b;
                            jump_select = !stall_last;
                        end
                    end
                    3'b001: begin // bne
                        if (rsrc1 != rsrc2) begin
                            e_clk_en = i_valid && stall_last;
                            e_pc_next = f_pc + imm_b;
                            jump_select = !stall_last;
                        end
                    end
                    3'b100: begin // blt
                        if ($signed(rsrc1) < $signed(rsrc2)) begin
                            e_clk_en = i_valid && stall_last;
                            e_pc_next = f_pc + imm_b;
                            jump_select = !stall_last;
                        end
                    end
                    3'b101: begin // bge
                        if ($signed(rsrc1) >= $signed(rsrc2)) begin
                            e_clk_en = i_valid && stall_last;
                            e_pc_next = f_pc + imm_b;
                            jump_select = !stall_last;
                        end
                    end
                    3'b110: begin // bltu
                        if (rsrc1 < rsrc2) begin
                            e_clk_en = i_valid && stall_last;
                            e_pc_next = f_pc + imm_b;
                            jump_select = !stall_last;
                        end
                    end
                    3'b111: begin // bgeu
                        if (rsrc2 > rsrc2) begin
                            e_clk_en = i_valid && stall_last;
                            e_pc_next = f_pc + imm_b;
                            jump_select = !stall_last;
                        end
                    end
                endcase
            end

            7'b1110011: begin // ecall or ebreak, for this purpose treated the same
                halted_next = 1'b1;
            end

        endcase

    end

    wire [6:0] opcode = f_instr[6:0];
    wire [4:0] rd = f_instr[11:7];
    wire [4:0] rs1 = f_instr[19:15];
    wire [4:0] rs2 = f_instr[24:20];
    wire [11:0] imm_i = f_instr[31:20];
    wire [11:0] imm_s = {f_instr[31:25], f_instr[11:7]};
    wire [31:0] imm_b = {{19{f_instr[31]}}, f_instr[31], f_instr[7], f_instr[30:25], f_instr[11:8], 1'b0};
    wire [31:0] imm_u = f_instr[31:12];
    wire [31:0] imm_j = {{12{f_instr[31]}}, f_instr[19:12], f_instr[20], f_instr[30:21], 1'b0};
    wire [2:0] funct3 = f_instr[14:12];
    wire [6:0] funct7 = f_instr[31:25];

    reg [31:0] regfile [0:31];
    wire [31:0] x1  = regfile[1];
    wire [31:0] x2  = regfile[2];
    wire [31:0] x3  = regfile[3];
    wire [31:0] x4  = regfile[4];
    wire [31:0] x5  = regfile[5];
    wire [31:0] x6  = regfile[6];
    wire [31:0] x7  = regfile[7];
    wire [31:0] x8  = regfile[8];
    wire [31:0] x9  = regfile[9];
    wire [31:0] x10 = regfile[10];
    wire [31:0] x11 = regfile[11];
    wire [31:0] x12 = regfile[12];
    wire [31:0] x13 = regfile[13];
    wire [31:0] x14 = regfile[14];
    wire [31:0] x15 = regfile[15];
    wire [31:0] x16 = regfile[16];
    wire [31:0] x17 = regfile[17];
    wire [31:0] x18 = regfile[18];
    wire [31:0] x19 = regfile[19];
    wire [31:0] x20 = regfile[20];
    wire [31:0] x21 = regfile[21];
    wire [31:0] x22 = regfile[22];
    wire [31:0] x23 = regfile[23];
    wire [31:0] x24 = regfile[24];
    wire [31:0] x25 = regfile[25];
    wire [31:0] x26 = regfile[26];
    wire [31:0] x27 = regfile[27];
    wire [31:0] x28 = regfile[28];
    wire [31:0] x29 = regfile[29];
    wire [31:0] x30 = regfile[30];
    wire [31:0] x31 = regfile[31];

endmodule

/*
module exec (
    input wire clk,
    input wire rst_n,
    input wire e_inp_rdy,
    input wire [31:0] f_instr,
    input wire [31:0] f_pc,
    output reg e_otp_rdy,
    output reg e_j_flag,
    output reg [31:0] e_pc_next,
    output reg halted
);  

    wire m_done;

    wire [6:0] opcode = f_instr[6:0];
    wire [4:0] rd = f_instr[11:7];
    wire [4:0] rs1 = f_instr[19:15];
    wire [4:0] rs2 = f_instr[24:20];
    wire [11:0] imm_i = f_instr[31:20];
    wire [11:0] imm_s = {f_instr[31:25], f_instr[11:7]};
    wire [31:0] imm_b = {{19{f_instr[31]}}, f_instr[31], f_instr[7], f_instr[30:25], f_instr[11:8], 1'b0};
    wire [31:0] imm_u = f_instr[31:12];
    wire [31:0] imm_j = {{12{f_instr[31]}}, f_instr[19:12], f_instr[20], f_instr[30:21], 1'b0};
    wire [2:0] funct3 = f_instr[14:12];
    wire [6:0] funct7 = f_instr[31:25];

    reg [9:0] sram_addr;
    reg [3:0] sram_wen;
    wire [31:0] sram_read_data;

    sram_4kb sram (
        .a(sram_addr),
        .wen(sram_wen),
        .wd(rsrc2),
        .clk(clk),
        .m_inp_rdy(m_inp_rdy),
        .m_otp_rdy(m_otp_rdy),
        .rd(sram_read_data)
    );

    wire [31:0] rsrc1 = regfile[rs1];
    wire [31:0] rsrc2 = regfile[rs2];
    reg [31:0] rdest;
    reg [31:0] e_pc;

    reg [63:0] mul_full_width;

    wire [31:0] ram_addr_s = rsrc1 + {{20{imm_s[11]}}, imm_s};
    wire [31:0] ram_addr_l = rsrc1 + {{20{imm_i[11]}}, imm_i};

    // 31 registers
    reg [31:0] regfile [0:31];
    wire [31:0] x1  = regfile[1];
    wire [31:0] x2  = regfile[2];
    wire [31:0] x3  = regfile[3];
    wire [31:0] x4  = regfile[4];
    wire [31:0] x5  = regfile[5];
    wire [31:0] x6  = regfile[6];
    wire [31:0] x7  = regfile[7];
    wire [31:0] x8  = regfile[8];
    wire [31:0] x9  = regfile[9];
    wire [31:0] x10 = regfile[10];
    wire [31:0] x11 = regfile[11];
    wire [31:0] x12 = regfile[12];
    wire [31:0] x13 = regfile[13];
    wire [31:0] x14 = regfile[14];
    wire [31:0] x15 = regfile[15];
    wire [31:0] x16 = regfile[16];
    wire [31:0] x17 = regfile[17];
    wire [31:0] x18 = regfile[18];
    wire [31:0] x19 = regfile[19];
    wire [31:0] x20 = regfile[20];
    wire [31:0] x21 = regfile[21];
    wire [31:0] x22 = regfile[22];
    wire [31:0] x23 = regfile[23];
    wire [31:0] x24 = regfile[24];
    wire [31:0] x25 = regfile[25];
    wire [31:0] x26 = regfile[26];
    wire [31:0] x27 = regfile[27];
    wire [31:0] x28 = regfile[28];
    wire [31:0] x29 = regfile[29];
    wire [31:0] x30 = regfile[30];
    wire [31:0] x31 = regfile[31];

    reg e_clk_en;
    reg m_inp_rdy;
    wire m_otp_rdy;

    reg e_otp_rdy_next;
    reg jump_started;

    reg halted_next;
    
    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            regfile[0] <= 32'h0;
            e_pc <= f_pc;
            jump_started <= 1'b0;
            halted <= 1'b0;
            e_otp_rdy <= 1'b1;
        end else begin 
            if (e_clk_en) begin
                if (rd != 0)
                    regfile[rd] <= rdest;
                e_pc <= e_pc_next;
            end 
            jump_started <= e_j_flag;
            halted <= halted_next;
            e_otp_rdy <= e_otp_rdy_next;
        end
    end

    always @* begin // destination register and exec stage program counter logic

        e_j_flag = 1'b0;
        e_clk_en = e_inp_rdy;
        e_otp_rdy_next = 1'b1;
        m_inp_rdy = 1'b0;
        rdest = regfile[rd];
        e_pc_next = f_pc;
        sram_wen = 4'b0;
        sram_addr = 10'bxxxxxxxxxx;
        mul_full_width = 64'bx;
        halted_next = 1'b0;

        casez (opcode)
            7'b0110011: begin // R-type
                case (funct3)
                    3'b000: 
                        if (funct7[0]) begin
                            mul_full_width = ($signed(rsrc1) * $signed(rsrc2));
                            rdest = mul_full_width[31:0];
                        end else
                            if (funct7[5])
                                rdest = rsrc1 - rsrc2;
                            else
                                rdest = rsrc1 + rsrc2;
                    3'b100:
                        if (funct7[0]) begin
                            rdest = $signed(rsrc1) / $signed(rsrc2);
                        end else
                            rdest = rsrc1 ^ rsrc2;
                    3'b110:
                        if (funct7[0]) begin
                            rdest = $signed(rsrc1) % $signed(rsrc2);
                        end else
                            rdest = rsrc1 | rsrc2;
                    3'b111:
                        if (funct7[0])
                            rdest = rsrc1 % rsrc2;
                        else
                            rdest = rsrc1 & rsrc2;
                    3'b001:
                        if (funct7[0]) begin
                            mul_full_width = ($signed(rsrc1) * $signed(rsrc2));
                            rdest = mul_full_width[63:32];
                        end else
                            rdest = rsrc1 << rsrc2[4:0];
                    3'b101:
                        if (funct7[0])
                            rdest = rsrc1 / rsrc2;
                        else
                            if (funct7[5])
                                rdest = $signed(rsrc1) >>> rsrc2[4:0];
                            else
                                rdest = rsrc1 >> rsrc2[4:0];
                    3'b010:
                        if (funct7[0]) begin
                            mul_full_width = ($signed(rsrc1) * $unsigned(rsrc2));
                            rdest = mul_full_width[63:32];
                        end else
                            rdest = {31'b0, $signed(rsrc1) < $signed(rsrc2)};
                    3'b011:
                        if (funct7[0]) begin
                            mul_full_width = (rsrc1 * rsrc2);
                            rdest = mul_full_width[63:32];
                        end else
                            rdest = {31'b0, rsrc1 < rsrc2};
                endcase
            end

            7'b0010011: begin // I-type arithmetic
                case (funct3)
                    3'b000:
                        rdest = rsrc1 + {{20{imm_i[11]}}, imm_i};
                    3'b100:
                        rdest = rsrc1 ^ {{20{imm_i[11]}}, imm_i};
                    3'b110:
                        rdest = rsrc1 | {{20{imm_i[11]}}, imm_i};
                    3'b111:
                        rdest = rsrc1 & {{20{imm_i[11]}}, imm_i};
                    3'b001:
                        rdest = rsrc1 << imm_i[4:0];
                    3'b101:
                        if (imm_i[10])
                            rdest = $signed(rsrc1) >>> imm_i[4:0];
                        else
                            rdest = rsrc1 >> imm_i[4:0];
                    3'b010:
                        rdest = {
                            31'b0, 
                            $signed(rsrc1) < $signed({{20{imm_i[11]}}, imm_i})
                            };
                    3'b011:
                        rdest = {
                            31'b0,
                            rsrc1 < {{20{imm_i[11]}}, imm_i}
                        };
                endcase
            end

            7'b0z10111: begin // U-type
                if (opcode[5]) // lui
                    rdest = {imm_u, 12'b0}; // lower 12 bits set to 0
                else // auipc TODO: test this command (not possible without very large jumps, with 100s of KBs of instruction data)
                    rdest = f_pc + {imm_u, 12'b0}; // lower 12 bits treated as 0
            end

            7'b0100011: begin // S-type

                sram_addr = ram_addr_s[9:0];
                m_inp_rdy = 1'b1;

                case (funct3)
                    3'b000: // sb
                        sram_wen = 4'b0001;
                    3'b001: // sh
                        sram_wen = 4'b0011;
                    3'b010: // sw
                        sram_wen = 4'b1111;
                endcase
            end

            7'b0000011: begin // I-type loads

                e_otp_rdy_next = e_inp_rdy && m_otp_rdy;
                e_clk_en = e_inp_rdy && m_otp_rdy;
                m_inp_rdy = 1'b1;
                sram_addr = ram_addr_l[9:0];

                case (funct3)
                    3'b000: // lb
                        rdest = {{24{sram_read_data[7]}}, sram_read_data[7:0]};
                    3'b001: // lh
                        rdest = {{16{sram_read_data[15]}}, sram_read_data[15:0]};
                    3'b010: // lw
                        rdest = sram_read_data;
                    3'b100: // lbu
                        rdest = {24'b0, sram_read_data[7:0]};
                    3'b101: // lhu
                        rdest = {16'b0, sram_read_data[15:0]};
                endcase
            end

            7'b1100111: begin // I-type jalr
                e_clk_en = e_inp_rdy && !jump_started;
                rdest = f_pc + 4;
                e_pc_next = rsrc1 + {{20{imm_i[11]}}, imm_i};
                e_j_flag = !jump_started;
            end

            7'b1101111: begin // J-type (jump)
                e_clk_en = e_inp_rdy && !jump_started;
                rdest = f_pc + 4;
                e_pc_next = f_pc + imm_j;
                e_j_flag = !jump_started;
            end

            7'b1100011: begin // B-type
                case (funct3)
                    3'b000: begin // beq
                        if (rsrc1 == rsrc2) begin
                            e_clk_en = e_inp_rdy && !jump_started;
                            rdest = f_pc + 4;
                            e_pc_next = f_pc + imm_b;
                            e_j_flag = !jump_started;
                        end
                    end
                    3'b001: begin // bne
                        if (rsrc1 != rsrc2) begin
                            e_clk_en = e_inp_rdy && !jump_started;
                            e_pc_next = f_pc + imm_b;
                            e_j_flag = !jump_started;
                        end
                    end
                    3'b100: begin // blt
                        if ($signed(rsrc1) < $signed(rsrc2)) begin
                            e_clk_en = e_inp_rdy && !jump_started;
                            e_pc_next = f_pc + imm_b;
                            e_j_flag = !jump_started;
                        end
                    end
                    3'b101: begin // bge
                        if ($signed(rsrc1) >= $signed(rsrc2)) begin
                            e_clk_en = e_inp_rdy && !jump_started;
                            e_pc_next = f_pc + imm_b;
                            e_j_flag = !jump_started;
                        end
                    end
                    3'b110: begin // bltu
                        if (rsrc1 < rsrc2) begin
                            e_clk_en = e_inp_rdy && !jump_started;
                            e_pc_next = f_pc + imm_b;
                            e_j_flag = !jump_started;
                        end
                    end
                    3'b111: begin // bgeu
                        if (rsrc2 > rsrc2) begin
                            e_clk_en = e_inp_rdy && !jump_started;
                            e_pc_next = f_pc + imm_b;
                            e_j_flag = !jump_started;
                        end
                    end
                endcase
            end

            7'b1110011: begin // ecall or ebreak, for this purpose treated the same
                halted_next = 1'b1;
            end

        endcase
    end

endmodule
*/


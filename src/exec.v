module exec (
    input wire clk,
    input wire rst_n,
    input wire [31:0] f_instr,
    output reg [31:0] f_pc,
    output reg [31:0] e_pc
);  

    wire [6:0] opcode = f_instr[6:0];
    wire [4:0] rd = f_instr[11:7];
    wire [4:0] rs1 = f_instr[19:15];
    wire [4:0] rs2 = f_instr[24:20];
    wire [11:0] imm_i = f_instr[31:20];
    wire [11:0] imm_s = {f_instr[31:25], f_instr[11:7]};
    wire [31:0] imm_b = {19'b0, f_instr[31], f_instr[7], f_instr[30:25], f_instr[11:8], 1'b0};
    wire [31:0] imm_u = f_instr[31:12];
    wire [31:0] imm_j = {11'b0, f_instr[31], f_instr[19:12], f_instr[20], f_instr[30:21], 1'b0};
    wire [2:0] funct3 = f_instr[14:12];
    wire [6:0] funct7 = f_instr[31:25];

    reg [31:0] regfile [0:31];
    wire [31:0] rsrc1 = regfile[rs1];
    wire [31:0] rsrc2 = regfile[rs2];
    reg [31:0] rdest;
    reg [31:0] e_pc_next;

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
    
    always @ (posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            regfile[0] <= 32'h0;
            e_pc <= f_pc;
        end else begin
            regfile[rd] <= rdest;
            e_pc <= e_pc_next;
        end
    end

    always @* begin // destination register logic
        rdest = 32'b0;
        e_pc_next = f_pc;
        casez (opcode)
            7'b0110011: begin // R-type
                case (funct3)
                    3'b000: 
                        if (funct7[5])
                            rdest = rsrc1 - rsrc2;
                        else
                            rdest = rsrc1 + rsrc2;
                    3'b100:
                        rdest = rsrc1 ^ rsrc2;
                    3'b110:
                        rdest = rsrc1 | rsrc2;
                    3'b111:
                        rdest = rsrc1 & rsrc2;
                    3'b001:
                        rdest = rsrc1 << rsrc2[4:0];
                    3'b101:
                        if (funct7[5])
                            rdest = $signed(rsrc1) >>> rsrc2[4:0];
                        else
                            rdest = rsrc1 >> rsrc2[4:0];
                    3'b010:
                        rdest = {31'b0, $signed(rsrc1) < $signed(rsrc2)};
                    3'b011:
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
                    rdest[31:12] = imm_u; // lower 12 bits set to 0
                else // auipc
                    e_pc_next = f_pc + {imm_u, 12'b0}; // lower 12 bits treated as 0
            end

        endcase
    end

endmodule
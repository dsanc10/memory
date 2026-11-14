`timescale 1ns / 1ps
module memoryTB;
    reg clk;
    reg reset;
    reg [31:0] ALUResult, WriteData;
    reg [4:0] WriteReg;
    reg [1:0] WBControl;
    reg MemWrite, MemRead, Branch, Zero;

    wire [31:0] ReadData, ALUResult_out, WriteResult;
    wire [4:0] WriteReg_out, MemWriteReg;
    wire RegWrite_out, MemtoReg_out, PCSrc, RegWrite;

    MEMORY mem_stage (
        .clk(clk),
        .reset(reset),
        .wb_ctlout(WBControl),
        .branch(Branch),
        .memread(MemRead),
        .memwrite(MemWrite),
        .zero(Zero),
        .alu_result(ALUResult),
        .rdata2out(WriteData),
        .five_bit_muxout(WriteReg),
        .MEM_WB_regwrite(RegWrite_out),
        .MEM_WB_memtoreg(MemtoReg_out),
        .MEM_PCSrc(PCSrc),
        .read_data(ReadData),
        .mem_alu_result(ALUResult_out),
        .mem_write_reg(WriteReg_out)
    );

    writeback wb_stage (
        .regwrite_in(RegWrite_out),
        .memtoreg_in(MemtoReg_out),
        .read_data_in(ReadData),
        .alu_result_in(ALUResult_out),
        .write_reg_in(WriteReg_out),
        .RegWrite(RegWrite),
        .WriteData(WriteResult),
        .MemWriteReg(MemWriteReg)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        reset = 1;
        ALUResult = 0;
        WriteData = 0;
        WriteReg = 0;
        WBControl = 2'b00;
        MemWrite = 0;
        MemRead = 0;
        Branch = 0;
        Zero = 0;

        // Reset MEM/WB latch at first rising edge (t=5).
        #10;
        reset = 0;

        // LOAD word from byte address 4 (initial memory word 1 = 1).
        ALUResult = 32'h00000004;
        WriteReg = 5'd2;
        WBControl = 2'b11; // RegWrite=1, MemtoReg=1
        MemRead = 1;
        #10; // MEM/WB captures load data at t=15
        $display("LOAD: time=%0t WriteResult=%h Reg=%d", $time, WriteResult, MemWriteReg);

        // STORE 0x12345678 to byte address 8 (word 2).
        ALUResult = 32'h00000008;
        WriteData = 32'h12345678;
        WriteReg = 5'd0;
        WBControl = 2'b00;
        MemRead = 0;
        MemWrite = 1;
        #10; // memory commits at t=25
        MemWrite = 0;

        // LOAD stored value back from byte address 8.
        ALUResult = 32'h00000008;
        WriteReg = 5'd3;
        WBControl = 2'b11;
        MemRead = 1;
        #10; // MEM/WB captures data at t=35
        $display("READ BACK: time=%0t WriteResult=%h Reg=%d", $time, WriteResult, MemWriteReg);

        // ALU writeback (MemtoReg=0 selects ALU result).
        MemRead = 0;
        ALUResult = 32'h0000002A;
        WriteReg = 5'd4;
        WBControl = 2'b10;
        #10; // MEM/WB captures ALU result at t=45
        $display("ALU WB: time=%0t WriteResult=%h Reg=%d", $time, WriteResult, MemWriteReg);

        // Branch: both Branch and Zero must be 1.
        WBControl = 2'b00;
        Branch = 1;
        Zero = 1;
        #10;
        $display("BRANCH: time=%0t PCSrc=%b", $time, PCSrc);
        Zero = 0;
        #10;
        $display("NO BRANCH: time=%0t PCSrc=%b", $time, PCSrc);
        Branch = 0;

        #10;
        $finish;
    end
endmodule

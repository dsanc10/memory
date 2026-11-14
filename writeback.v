`timescale 1ns / 1ps
module writeback(
    input wire regwrite_in,
    input wire memtoreg_in,
    input wire [31:0] read_data_in,
    input wire [31:0] alu_result_in,
    input wire [4:0] write_reg_in,
    output wire RegWrite,
    output wire [31:0] WriteData,
    output wire [4:0] MemWriteReg
);
    assign RegWrite    = regwrite_in;
    assign WriteData   = memtoreg_in ? read_data_in : alu_result_in;
    assign MemWriteReg = write_reg_in;
endmodule

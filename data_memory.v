`timescale 1ns / 1ps
module data_memory(
    input wire clk,
    input wire [31:0] addr,
    input wire [31:0] write_data,
    input wire memwrite,
    input wire memread,
    output wire [31:0] read_data
);
    reg [31:0] DMem [0:255];
    integer i;
    // Standard MIPS byte address: address 0 selects word 0,
    // address 4 selects word 1, and so on.
    wire [7:0] word_addr = addr[9:2];

    initial begin
        for (i = 0; i < 256; i = i + 1)
            DMem[i] = 32'b0;
        $readmemb("data.txt", DMem, 0, 5);
    end

    // Combinational read, enabled by MemRead.
    assign read_data = memread ? DMem[word_addr] : 32'b0;

    // A store commits only on the rising clock edge.
    always @(posedge clk) begin
        if (memwrite)
            DMem[word_addr] <= write_data;
    end
endmodule

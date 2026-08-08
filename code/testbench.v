`timescale 1ns/1ps
module aes_128_tb;

    reg clk = 0;
    reg rst;
    reg start;
    reg [127:0] in;
    reg [127:0] key;
    wire [127:0] out;
  
    aes_128 uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .in(in),
        .key(key),
        .out(out)
    );

  
    always #5 clk = ~clk;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, aes_128_tb, uut);

        rst = 1; start = 0;
        in  = 128'h00112233445566778899AABBCCDDEEFF;
        key = 128'h000102030405060708090A0B0C0D0E0F;

        #20 rst = 0;
        #10 start = 1;   
        #10 start = 0;

        #2000;

        $display("Plaintext : %h", in);
        $display("Key       : %h", key);
        $display("Ciphertext: %h", out);
        $finish;
    end

endmodule

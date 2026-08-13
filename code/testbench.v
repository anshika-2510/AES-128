`timescale 1ns/1ps

module tb_aes128;
    reg clk = 0;
    reg rst = 1;
    reg start = 0;
    reg [127:0] plaintext, key;
    wire [127:0] ciphertext;
    wire done;

    aes_core dut (
        .clk(clk), .rst(rst), .start(start),
        .plaintext(plaintext), .key(key),
        .ciphertext(ciphertext), .done(done)
    );

    always #5 clk = ~clk;

    // FIPS-197 Appendix B test vector
    localparam [127:0] EXP_CT = 128'h69c4e0d86a7b0430d8cdb78070b4c55a;

    initial begin
        plaintext = 128'h00112233445566778899aabbccddeeff;
        key       = 128'h000102030405060708090a0b0c0d0e0f;

        @(negedge clk); rst = 0;
        @(negedge clk);
        start = 1;
        @(negedge clk);
        start = 0;

        wait (done == 1);
        @(negedge clk);

        if (ciphertext === EXP_CT) begin
            $display("PASS: ciphertext = %h (matches FIPS-197 vector)", ciphertext);
        end else begin
            $display("FAIL: got %h, expected %h", ciphertext, EXP_CT);
        end
        $finish;
    end

    initial begin
        #500;
        $display("TIMEOUT");
        $finish;
    end
endmodule

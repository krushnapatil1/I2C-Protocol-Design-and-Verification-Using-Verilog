
`timescale 1ns/1ps

module tb_i2c;

    reg clk;
    reg reset;
    reg start;
    reg [6:0] slave_addr;
    reg [7:0] data_in;

    tri1 sda;
    wire scl;
    wire busy;
    wire done;
    wire ack_error;

    wire [7:0] data_out;
    wire data_valid;

    i2c_master master (
        .clk(clk),
        .reset(reset),
        .start(start),
        .slave_addr(slave_addr),
        .data_in(data_in),
        .sda(sda),
        .scl(scl),
        .busy(busy),
        .done(done),
        .ack_error(ack_error)
    );

    i2c_slave #(.SLAVE_ADDR(7'h50)) slave (
        .reset(reset),
        .scl(scl),
        .sda(sda),
        .data_out(data_out),
        .data_valid(data_valid)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("i2c.vcd");
        $dumpvars(0, tb_i2c);

        clk = 0;
        reset = 1;
        start = 0;
        slave_addr = 7'h50;
        data_in = 8'hA5;

        $display("==================================");
        $display(" I2C SUCCESSFUL TRANSFER TEST");
        $display("==================================");

        // Reset
        #20;
        reset = 0;

        // Start one transfer
        #20;
        $display("[%0t] Starting transfer: DATA = 0x%02h",
                 $time, data_in);

        start = 1;
        #10;
        start = 0;

        // Wait for completion or timeout
        fork
            begin
                wait (done == 1'b1);
                #10;

                $display("[%0t] Transfer completed", $time);
                $display("Slave Address : 0x%02h", slave_addr);
                $display("Sent Data     : 0x%02h", data_in);
                $display("Received Data : 0x%02h", data_out);
                $display("Data Valid    : %b", data_valid);
                $display("ACK Error     : %b", ack_error);

                if ((data_out === data_in) &&
                    (data_valid === 1'b1) &&
                    (ack_error === 1'b0)) begin
                    $display("RESULT: TEST PASSED");
                end else begin
                    $display("RESULT: TEST FAILED");
                end

                $finish;
            end

            begin
                #5000;
                $display("RESULT: TEST FAILED - TIMEOUT");
                $finish;
            end
        join
    end

endmodule

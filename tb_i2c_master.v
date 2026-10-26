`timescale 1ns/1ps

module tb_i2c_master;

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

reg slave_drive_low;
integer rising_edges;

//Slave drives SDA low for ACK
assign sda = slave_drive_low ? 1'b0 : 1'bz;


i2c_master dut (
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


initial clk = 1'b0;
always #10 clk = ~clk;

// Generate waveform dump
initial begin
    $dumpfile("i2c_master.vcd");
    $dumpvars(0, tb_i2c_master);
end


initial begin

    reset = 1'b1;
    start = 1'b0;
    slave_addr = 7'h50;
    data_in = 8'hA5;
    slave_drive_low = 1'b0;
    rising_edges = 0;

    #100;
    reset = 1'b0;

end


//Start the I2C transaction
initial begin

    wait(reset == 1'b0);
    @(negedge clk);
    start = 1'b1;

    @(negedge clk);
    start = 1'b0;

end


//Count SCL rising edges
always @(posedge scl or posedge reset) begin
    if (reset)
        rising_edges = 0;
    else
        rising_edges = rising_edges + 1;
end

// Simple slave ACK responder
always @(negedge scl or posedge reset) begin
    if (reset) begin
        slave_drive_low = 1'b0;
    end
    else begin
        case (rising_edges)
            8, 17: slave_drive_low = 1'b1;
            9, 18: slave_drive_low = 1'b0;
            default: slave_drive_low = 1'b0;
        endcase
    end
end

// Monitor transaction
    initial begin
        $monitor("Time=%0t | SCL=%b | SDA=%b | busy=%b | done=%b | ack_error=%b", $time, scl, sda, busy, done, ack_error);

        wait(done == 1'b1);
        #20;
        $display("Transaction completed.");
        $display("Final ack_error = %b", ack_error);
        $finish;
    end

    // Timeout protection
    initial begin
        #2000000;
        $display("ERROR: Simulation timed out.");
        $finish;
    end


endmodule
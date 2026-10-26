module i2c_master(
    input clk,
    input reset,
    input start,
    input [6:0] slave_addr,
    input [7:0] data_in,

    inout sda,

    output reg scl,
    output reg busy,
    output reg done,
    output reg ack_error
);


    // Open-drain SDA implementation
    // The master can pull SDA LOW or release it.
    reg sda_drive_low;

    // Release SDA when sda_drive_low = 0.
    // A pull-up resistor makes the bus HIGH when all devices release it.
    assign sda = sda_drive_low ? 1'b0 : 1'bz;


    //PARAMETERS
    localparam IDLE = 3'd0;
    localparam START = 3'd1;
    localparam SEND_ADDR = 3'd2;
    localparam ACK_ADDR = 3'd3;
    localparam SEND_DATA = 3'd4;
    localparam ACK_DATA = 3'd5;
    localparam STOP = 3'd6;
    localparam DONE = 3'd7;

    //CURRENT FSM STATE 
    reg [2:0] state;

    //CLOCK DIVIDER: It converts 50MHz System Clock  into 100kHz SCL Timing
    reg [7:0] clk_count;
    reg scl_tick;

    always@(posedge clk or posedge reset) begin
        
        if(reset)begin
            clk_count <= 0;
            scl_tick <= 0;
        end

        else if(clk_count == 8'd249)begin
            clk_count <= 0;
            scl_tick <= 1;
        end

        else begin
            clk_count <= clk_count + 1'b1;
            scl_tick <= 1'b0;
        end

    end


    //Generate SCL during address and Data Transmission
    always@(posedge clk or posedge reset) begin

        if(reset) begin
            scl <= 1'b1;
        end

        else if (state == IDLE || state == START || state == STOP || state == DONE) begin
        scl <= 1'b1;
        end

        else if(scl_tick && (state == SEND_ADDR || state == ACK_ADDR || state == SEND_DATA || state == ACK_DATA))begin
            scl <= ~scl;
        end

    end


    //Transmission Register
    reg [7:0] stored_addr;      //It will store the address and read or write bit.
    reg [7:0] stored_data;      //It will store data that need to be send.
    reg [2:0] bit_count;


    always@(posedge clk or posedge reset)begin
        
        if(reset) begin
            state <= IDLE;
            busy <= 0;
            done <= 0;
            ack_error <= 0;
            sda_drive_low <= 0;
            stored_addr <= 8'd0;
            stored_data <= 8'd0;
            bit_count <= 3'd0;
        end

        else begin
            
            done <= 0;

            case(state)

                IDLE: begin
                    
                    if(start)begin
                        stored_addr <= {slave_addr, 1'b0};
                        stored_data <= data_in;
                        busy <= 1;
                        state <= START;
                        done <= 0;
                        ack_error <= 1'b0;
                    end

                    else begin
                        busy <= 0;
                        done <= 0;
                    end

                end


                START: begin
                    sda_drive_low <= 1;
                    bit_count <= 3'd7;
                    state <= SEND_ADDR;
                end


                SEND_ADDR: begin
                    
                    // Set the current address bit while SCL is LOW
                    if (!scl)
                        sda_drive_low <= (stored_addr[bit_count] == 1'b0);

                    // Move to the next bit after SCL completes its HIGH phase
                    if (scl_tick && !scl) begin

                        if (bit_count > 0) begin
                            bit_count <= bit_count - 1'b1;
                        end
                        else begin
                            sda_drive_low <= 1'b0;
                            state <= ACK_ADDR;
                        end

                    end

                end


                ACK_ADDR: begin
                    
                    //Release SDA so the slave can send ACK/NACK
                    sda_drive_low <= 1'b0;

                    //Sample the slave response while SCl is HIGH
                    if(scl_tick && !scl)begin
                        if(sda == 1'b0) begin
                            ack_error <= 1'b0;
                            bit_count <= 3'd7;
                            state <= SEND_DATA;
                        end

                        else begin
                            ack_error <= 1'b1;
                            state <= STOP;
                        end
                    end
                    
                end


                SEND_DATA: begin

                    // Set data while SCL is LOW
                    if (!scl)
                        sda_drive_low <= (stored_data[bit_count] == 1'b0);

                    // Advance after the SCL rising transition
                    if (scl_tick && !scl) begin

                        if (bit_count > 0) begin
                            bit_count <= bit_count - 1'b1;
                        end
                        else begin
                            sda_drive_low <= 1'b0;
                            state <= ACK_DATA;
                        end

                    end

                end


                ACK_DATA: begin
                    
                    //Release SDA so the slave can respond
                    sda_drive_low <= 1'b0;

                    //Sample ACK/NACK while SCL is HIGH
                    if(scl_tick && !scl)begin
                        
                        if(sda == 1'b0)begin
                            ack_error <= 1'b0;
                            state <= STOP;
                        end
                        else begin
                            ack_error <= 1'b1;
                            state <= STOP;
                        end

                    end

                end


                STOP: begin

                    // Release SDA to generate STOP
                    sda_drive_low <= 1'b0;

                    //Finish the transaction
                    state <= DONE;

                end


                DONE: begin
                    
                    busy <= 1'b0;
                    done <= 1'b1;

                    sda_drive_low <= 1'b0;

                    state <= IDLE;

                end


            endcase

        end
    end

endmodule
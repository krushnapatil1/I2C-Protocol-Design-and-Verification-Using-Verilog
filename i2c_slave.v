
`timescale 1ns/1ps

module i2c_slave #(
    parameter [6:0] SLAVE_ADDR = 7'h50
)(
    input  wire       reset,
    input  wire       scl,
    inout  wire       sda,

    output reg  [7:0] data_out,
    output reg        data_valid
);

    // FSM states
    localparam IDLE    = 3'd0,
               ADDRESS = 3'd1,
               ADDR_ACK = 3'd2,
               DATA    = 3'd3,
               DATA_ACK = 3'd4,
               WAIT_STOP = 3'd5;

    reg [2:0] state;
    reg [3:0] bit_count;
    reg [7:0] shift_reg;
    reg [7:0] address_byte;

    reg sda_drive_low;

    // I2C is open-drain: the slave can pull SDA low or release it.
    assign sda = sda_drive_low ? 1'b0 : 1'bz;

    // Detect START and STOP conditions.
    wire start_condition = (sda == 1'b0) && (scl == 1'b1);
    wire stop_condition  = (sda == 1'b1) && (scl == 1'b1);

    always @(posedge scl or posedge reset) begin
        if (reset) begin
            state         <= IDLE;
            bit_count     <= 0;
            shift_reg     <= 0;
            address_byte  <= 0;
            data_out      <= 0;
            data_valid    <= 0;
            sda_drive_low <= 0;
        end else begin
            data_valid <= 1'b0;

            case (state)

                IDLE: begin
                    bit_count     <= 0;
                    sda_drive_low <= 0;
                end

                ADDRESS: begin
                    shift_reg <= {shift_reg[6:0], sda};

                    if (bit_count == 7) begin
                        address_byte <= {shift_reg[6:0], sda};
                        bit_count <= 0;
                        state <= ADDR_ACK;
                    end else begin
                        bit_count <= bit_count + 1'b1;
                    end
                end

                ADDR_ACK: begin
                    if (address_byte[7:1] == SLAVE_ADDR &&
                        address_byte[0] == 1'b0) begin
                        sda_drive_low <= 1'b1;
                        state <= DATA;
                    end else begin
                        sda_drive_low <= 1'b0;
                        state <= WAIT_STOP;
                    end
                end

                DATA: begin
                    sda_drive_low <= 1'b0;
                    shift_reg <= {shift_reg[6:0], sda};

                    if (bit_count == 7) begin
                        data_out <= {shift_reg[6:0], sda};
                        data_valid <= 1'b1;
                        bit_count <= 0;
                        state <= DATA_ACK;
                    end else begin
                        bit_count <= bit_count + 1'b1;
                    end
                end

                DATA_ACK: begin
                    sda_drive_low <= 1'b1;
                    state <= WAIT_STOP;
                end

                WAIT_STOP: begin
                    sda_drive_low <= 1'b0;
                end

                default: begin
                    state <= IDLE;
                    sda_drive_low <= 1'b0;
                end

            endcase
        end
    end

    // Simplified START/STOP handling.
    always @(negedge sda or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            bit_count <= 0;
            shift_reg <= 0;
            sda_drive_low <= 0;
        end else if (scl) begin
            state <= ADDRESS;
            bit_count <= 0;
            shift_reg <= 0;
            sda_drive_low <= 0;
        end
    end

    always @(posedge sda) begin
        if (scl) begin
            state <= IDLE;
            sda_drive_low <= 0;
        end
    end

endmodule

//=============================================================================
// Module: spi_master
// Description: Configurable SPI Master Controller
// Author: Daggolu Hari Krishna
//
// Features:
//   - All 4 SPI modes (CPOL/CPHA combinations)
//   - Parameterized clock divider and data width
//   - Multi-slave chip select support (up to 4 slaves)
//   - Configurable MSB-first or LSB-first transmission
//   - Transaction-complete interrupt signal
//
// SPI Modes:
//   Mode 0: CPOL=0, CPHA=0 — Clock idle LOW,  sample on rising edge
//   Mode 1: CPOL=0, CPHA=1 — Clock idle LOW,  sample on falling edge
//   Mode 2: CPOL=1, CPHA=0 — Clock idle HIGH, sample on falling edge
//   Mode 3: CPOL=1, CPHA=1 — Clock idle HIGH, sample on rising edge
//=============================================================================

module spi_master #(
    parameter DATA_WIDTH = 8,
    parameter CLK_DIV    = 4,     // SCLK = sys_clk / (2 * CLK_DIV)
    parameter NUM_SLAVES = 4
)(
    input  wire                     clk,
    input  wire                     rst_n,

    // Control interface
    input  wire                     start,        // Start transaction
    input  wire [DATA_WIDTH-1:0]    tx_data,      // Data to transmit
    output reg  [DATA_WIDTH-1:0]    rx_data,      // Received data
    output reg                      busy,         // Transaction in progress
    output reg                      done,         // Transaction complete pulse
    input  wire [1:0]               spi_mode,     // SPI mode (0-3)
    input  wire [$clog2(NUM_SLAVES)-1:0] slave_sel, // Slave select
    input  wire                     msb_first,    // 1: MSB first, 0: LSB first

    // SPI physical interface
    output reg                      sclk,         // SPI clock
    output reg                      mosi,         // Master Out Slave In
    input  wire                     miso,         // Master In Slave Out
    output reg  [NUM_SLAVES-1:0]    cs_n          // Chip select (active low)
);

    // Internal signals
    reg [$clog2(CLK_DIV)-1:0] clk_counter;
    reg [$clog2(DATA_WIDTH):0] bit_counter;
    reg [DATA_WIDTH-1:0] tx_shift_reg;
    reg [DATA_WIDTH-1:0] rx_shift_reg;
    reg clk_edge;        // Clock edge toggle
    wire cpol, cpha;

    // Extract mode bits
    assign cpol = spi_mode[1];
    assign cpha = spi_mode[0];

    // FSM States
    localparam [2:0]
        IDLE      = 3'b000,
        CS_ASSERT = 3'b001,
        LEADING   = 3'b010,
        TRAILING  = 3'b011,
        CS_DEASSERT = 3'b100;

    reg [2:0] state;

    // SCLK divider
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_counter <= 0;
            clk_edge    <= 1'b0;
        end else if (state == LEADING || state == TRAILING) begin
            if (clk_counter == CLK_DIV - 1) begin
                clk_counter <= 0;
                clk_edge    <= 1'b1;
            end else begin
                clk_counter <= clk_counter + 1;
                clk_edge    <= 1'b0;
            end
        end else begin
            clk_counter <= 0;
            clk_edge    <= 1'b0;
        end
    end

    // Main FSM
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state        <= IDLE;
            sclk         <= 1'b0;
            mosi         <= 1'b0;
            cs_n         <= {NUM_SLAVES{1'b1}};
            rx_data      <= {DATA_WIDTH{1'b0}};
            tx_shift_reg <= {DATA_WIDTH{1'b0}};
            rx_shift_reg <= {DATA_WIDTH{1'b0}};
            bit_counter  <= 0;
            busy         <= 1'b0;
            done         <= 1'b0;
        end else begin
            done <= 1'b0; // Default: deassert done

            case (state)
                IDLE: begin
                    sclk <= cpol; // Idle clock polarity
                    cs_n <= {NUM_SLAVES{1'b1}}; // All CS high
                    busy <= 1'b0;

                    if (start) begin
                        busy         <= 1'b1;
                        tx_shift_reg <= tx_data;
                        rx_shift_reg <= {DATA_WIDTH{1'b0}};
                        bit_counter  <= 0;
                        state        <= CS_ASSERT;
                    end
                end

                CS_ASSERT: begin
                    // Assert chip select for selected slave
                    cs_n[slave_sel] <= 1'b0;

                    // Setup first MOSI bit
                    if (msb_first)
                        mosi <= tx_shift_reg[DATA_WIDTH-1];
                    else
                        mosi <= tx_shift_reg[0];

                    if (cpha == 1'b0) begin
                        // CPHA=0: Data setup before first clock edge
                        state <= LEADING;
                    end else begin
                        // CPHA=1: First clock edge before data
                        state <= LEADING;
                    end
                end

                LEADING: begin
                    if (clk_edge) begin
                        sclk <= ~sclk; // Toggle clock — leading edge

                        if (cpha == 1'b0) begin
                            // CPHA=0: Sample on leading edge
                            if (msb_first)
                                rx_shift_reg <= {rx_shift_reg[DATA_WIDTH-2:0], miso};
                            else
                                rx_shift_reg <= {miso, rx_shift_reg[DATA_WIDTH-1:1]};
                        end else begin
                            // CPHA=1: Shift out on leading edge
                            if (msb_first) begin
                                mosi <= tx_shift_reg[DATA_WIDTH-1];
                                tx_shift_reg <= {tx_shift_reg[DATA_WIDTH-2:0], 1'b0};
                            end else begin
                                mosi <= tx_shift_reg[0];
                                tx_shift_reg <= {1'b0, tx_shift_reg[DATA_WIDTH-1:1]};
                            end
                        end

                        state <= TRAILING;
                    end
                end

                TRAILING: begin
                    if (clk_edge) begin
                        sclk <= ~sclk; // Toggle clock — trailing edge

                        if (cpha == 1'b0) begin
                            // CPHA=0: Shift out on trailing edge
                            if (msb_first) begin
                                tx_shift_reg <= {tx_shift_reg[DATA_WIDTH-2:0], 1'b0};
                                mosi <= tx_shift_reg[DATA_WIDTH-2]; // Next bit
                            end else begin
                                tx_shift_reg <= {1'b0, tx_shift_reg[DATA_WIDTH-1:1]};
                                mosi <= tx_shift_reg[1];
                            end
                        end else begin
                            // CPHA=1: Sample on trailing edge
                            if (msb_first)
                                rx_shift_reg <= {rx_shift_reg[DATA_WIDTH-2:0], miso};
                            else
                                rx_shift_reg <= {miso, rx_shift_reg[DATA_WIDTH-1:1]};
                        end

                        bit_counter <= bit_counter + 1;

                        if (bit_counter == DATA_WIDTH - 1) begin
                            state <= CS_DEASSERT;
                        end else begin
                            state <= LEADING;
                        end
                    end
                end

                CS_DEASSERT: begin
                    sclk    <= cpol;
                    cs_n    <= {NUM_SLAVES{1'b1}};
                    rx_data <= rx_shift_reg;
                    done    <= 1'b1;
                    busy    <= 1'b0;
                    state   <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule

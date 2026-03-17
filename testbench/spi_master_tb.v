//=============================================================================
// Testbench: spi_master_tb
// Description: Loopback testbench for SPI Master Controller
// Author: Daggolu Hari Krishna
//
// Tests all 4 SPI modes with MOSI→MISO loopback verification.
//=============================================================================

`timescale 1ns / 1ps

module spi_master_tb;

    parameter DATA_WIDTH = 8;
    parameter CLK_DIV    = 2;
    parameter NUM_SLAVES = 4;
    parameter CLK_PERIOD = 10;

    reg                      clk;
    reg                      rst_n;
    reg                      start;
    reg  [DATA_WIDTH-1:0]    tx_data;
    wire [DATA_WIDTH-1:0]    rx_data;
    wire                     busy;
    wire                     done;
    reg  [1:0]               spi_mode;
    reg  [$clog2(NUM_SLAVES)-1:0] slave_sel;
    reg                      msb_first;

    wire                     sclk;
    wire                     mosi;
    wire [NUM_SLAVES-1:0]    cs_n;

    // Loopback: MOSI → MISO
    wire miso;
    assign miso = mosi;

    integer pass_count = 0;
    integer fail_count = 0;
    integer test_num   = 0;

    // Instantiate SPI Master
    spi_master #(
        .DATA_WIDTH(DATA_WIDTH),
        .CLK_DIV   (CLK_DIV),
        .NUM_SLAVES(NUM_SLAVES)
    ) uut (
        .clk       (clk),
        .rst_n     (rst_n),
        .start     (start),
        .tx_data   (tx_data),
        .rx_data   (rx_data),
        .busy      (busy),
        .done      (done),
        .spi_mode  (spi_mode),
        .slave_sel (slave_sel),
        .msb_first (msb_first),
        .sclk      (sclk),
        .mosi      (mosi),
        .miso      (miso),
        .cs_n      (cs_n)
    );

    initial clk = 0;
    always #(CLK_PERIOD / 2) clk = ~clk;

    task spi_transfer;
        input [DATA_WIDTH-1:0] data;
        input [1:0] mode;
        input [79:0] test_name;
    begin
        test_num = test_num + 1;

        @(posedge clk);
        spi_mode = mode;
        tx_data  = data;
        start    = 1'b1;
        @(posedge clk);
        start = 1'b0;

        // Wait for done
        wait(done);
        @(posedge clk);

        if (rx_data === data) begin
            $display("[PASS] Test %0d: %s | Mode=%0d | TX=0x%02h, RX=0x%02h",
                     test_num, test_name, mode, data, rx_data);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test %0d: %s | Mode=%0d | TX=0x%02h, RX=0x%02h",
                     test_num, test_name, mode, data, rx_data);
            fail_count = fail_count + 1;
        end

        // Wait between transactions
        repeat(5) @(posedge clk);
    end
    endtask

    initial begin
        $dumpfile("spi_master_tb.vcd");
        $dumpvars(0, spi_master_tb);

        $display("============================================================");
        $display("   SPI MASTER CONTROLLER TESTBENCH");
        $display("   Author: Daggolu Hari Krishna");
        $display("============================================================");
        $display("");

        // Reset
        rst_n     = 1'b0;
        start     = 1'b0;
        tx_data   = 8'd0;
        spi_mode  = 2'b00;
        slave_sel = 2'b00;
        msb_first = 1'b1;
        #(CLK_PERIOD * 5);
        rst_n = 1'b1;
        #(CLK_PERIOD * 3);

        // ---- Mode 0 Tests ----
        $display("--- SPI Mode 0 (CPOL=0, CPHA=0) ---");
        spi_transfer(8'hA5, 2'b00, "Mode 0 - 0xA5   ");
        spi_transfer(8'h55, 2'b00, "Mode 0 - 0x55   ");
        spi_transfer(8'hFF, 2'b00, "Mode 0 - 0xFF   ");

        // ---- Mode 1 Tests ----
        $display("");
        $display("--- SPI Mode 1 (CPOL=0, CPHA=1) ---");
        spi_transfer(8'h3C, 2'b01, "Mode 1 - 0x3C   ");
        spi_transfer(8'hC3, 2'b01, "Mode 1 - 0xC3   ");

        // ---- Mode 2 Tests ----
        $display("");
        $display("--- SPI Mode 2 (CPOL=1, CPHA=0) ---");
        spi_transfer(8'h69, 2'b10, "Mode 2 - 0x69   ");
        spi_transfer(8'h96, 2'b10, "Mode 2 - 0x96   ");

        // ---- Mode 3 Tests ----
        $display("");
        $display("--- SPI Mode 3 (CPOL=1, CPHA=1) ---");
        spi_transfer(8'hDB, 2'b11, "Mode 3 - 0xDB   ");
        spi_transfer(8'h42, 2'b11, "Mode 3 - 0x42   ");

        // ---- Multi-slave test ----
        $display("");
        $display("--- Multi-Slave Selection ---");
        slave_sel = 2'b01;
        spi_transfer(8'h11, 2'b00, "Slave 1 select  ");

        slave_sel = 2'b10;
        spi_transfer(8'h22, 2'b00, "Slave 2 select  ");

        slave_sel = 2'b11;
        spi_transfer(8'h33, 2'b00, "Slave 3 select  ");

        // Summary
        $display("");
        $display("============================================================");
        $display("  TEST SUMMARY: %0d PASSED, %0d FAILED out of %0d tests",
                 pass_count, fail_count, test_num);
        $display("============================================================");
        if (fail_count == 0)
            $display("  >>> ALL TESTS PASSED! <<<");
        else
            $display("  >>> SOME TESTS FAILED! <<<");
        $display("");
        $finish;
    end

    initial begin
        #100000;
        $display("[TIMEOUT]");
        $finish;
    end

endmodule

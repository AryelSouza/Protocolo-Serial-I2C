// design.sv
`include "i2c_clock_divider.sv"
`include "i2c_io_if.sv"
`include "i2c_fsm.sv"

module I2C_Controller (
    input  logic        clk,
    input  logic        rst_n,
    inout  wire         scl,
    inout  wire         sda,
    input  logic [6:0]  cfg_address,
    input  logic [7:0]  tx_data,
    input  logic        tx_valid,
    output logic        tx_ready,
    output logic [7:0]  rx_data,
    output logic        rx_valid,
    input  logic        rx_ready,
    input  logic        start,
    input  logic        restart,
    input  logic        stop,
    input  logic        ack_in,
    output logic        ack_out,
    output logic        busy,
    output logic        error
);
    logic scl_clk;
    logic scl_oen, sda_oen;
    logic scl_int, sda_int;
    
    i2c_clock_divider #(
        .SYS_CLK_FREQ_HZ(100_000_000),
        .I2C_CLK_FREQ_HZ(100_000)
    ) clk_div (
        .clk(clk), .rst_n(rst_n), .scl_clk(scl_clk)
    );

    i2c_io_if io_if (
        .scl_clk(scl_clk),
        .scl_oen(scl_oen),
        .sda_oen(sda_oen),
        .scl(scl),
        .sda(sda),
        .scl_int(scl_int),
        .sda_int(sda_int)
    );

    i2c_fsm fsm (
        .scl_clk(scl_clk),
        .rst_n(rst_n),
        .cfg_address(cfg_address),
        .tx_data(tx_data),
        .tx_valid(tx_valid),
        .start(start),
        .restart(restart),
        .stop(stop),
        .scl_oen(scl_oen),
        .sda_oen(sda_oen),
        .tx_ready(tx_ready),
        .ack_out(ack_out),
        .busy(busy),
        .error(error),
        .rx_data(rx_data),
        .rx_valid(rx_valid)
    );
endmodule

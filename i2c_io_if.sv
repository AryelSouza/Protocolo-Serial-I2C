// i2c_io_if.sv
module i2c_io_if (
    input  logic scl_clk,
    input  logic scl_oen,
    input  logic sda_oen,
    inout  wire  scl,
    inout  wire  sda,
    output logic scl_int,
    output logic sda_int
);
    assign scl     = scl_oen ? 1'b0 : 1'bz;
    assign sda     = sda_oen ? 1'b0 : 1'bz;
    assign scl_int = scl;
    assign sda_int = sda;
endmodule
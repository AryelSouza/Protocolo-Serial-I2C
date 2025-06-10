// i2c_clock_divider.sv
module i2c_clock_divider #(
    parameter integer SYS_CLK_FREQ_HZ = 100_000_000,
    parameter integer I2C_CLK_FREQ_HZ = 100_000
)(
    input  logic clk,
    input  logic rst_n,
    output logic scl_clk
);
    localparam integer DIV_COUNT = SYS_CLK_FREQ_HZ / (I2C_CLK_FREQ_HZ * 2);
    logic [31:0] cnt;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt     <= 0;
            scl_clk <= 1;
        end else if (cnt == DIV_COUNT-1) begin
            cnt     <= 0;
            scl_clk <= ~scl_clk;
        end else cnt <= cnt + 1;
    end
endmodule
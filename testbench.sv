// testbench.sv
module I2C_Controller_tb;
    parameter SYS_CLK=100e6, I2C_CLK=100e3;
    logic clk; initial clk=0; always #5 clk=~clk;
    logic rst_n;
    wire scl, sda;
    logic [6:0] cfg_address;
    logic [7:0] tx_data;
    logic       tx_valid, tx_ready;
    logic [7:0] rx_data;
    logic       rx_valid, rx_ready;
    logic       start, restart, stop;
    logic       ack_in, ack_out;
    logic       busy, error;

    I2C_Controller dut(
        .clk(clk), .rst_n(rst_n), .scl(scl), .sda(sda),
        .cfg_address(cfg_address), .tx_data(tx_data), .tx_valid(tx_valid),
        .tx_ready(tx_ready), .rx_data(rx_data), .rx_valid(rx_valid), .rx_ready(rx_ready),
        .start(start), .restart(restart), .stop(stop), .ack_in(ack_in), .ack_out(ack_out),
        .busy(busy), .error(error)
    );

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, I2C_Controller_tb.dut);
    end

    initial begin
        rst_n=0; start=0; restart=0; stop=0; tx_valid=0; rx_ready=0;
        ack_in=1; cfg_address=7'h50;
        #20 rst_n=1;
        #10 start=1; #10 start=0; wait(tx_ready);
        tx_data=8'hA5; tx_valid=1; #10 tx_valid=0;
        #50 stop=1; #10 stop=0;
        #100 $finish;
    end
endmodule

// i2c_fsm.sv
typedef enum logic [2:0] {IDLE, ADDR, DATA, ACK_PHASE, STOP_PHASE} state_t;
module i2c_fsm (
    input  logic        scl_clk,
    input  logic        rst_n,
    input  logic [6:0]  cfg_address,
    input  logic [7:0]  tx_data,
    input  logic        tx_valid,
    input  logic        start,
    input  logic        restart,
    input  logic        stop,
    output logic        scl_oen,
    output logic        sda_oen,
    output logic        tx_ready,
    output logic        ack_out,
    output logic        busy,
    output logic        error,
    output logic [7:0]  rx_data,
    output logic        rx_valid
);
    state_t curr_state, next_state;
    logic [7:0] shift_reg, next_shift_reg;
    logic [3:0] bit_cnt, next_bit_cnt;
    logic       rw_flag, next_rw_flag;
    logic       next_error;
    logic       sda_int;

    always_comb begin
        scl_oen        = 0;
        sda_oen        = 0;
        tx_ready       = (curr_state == IDLE);
        ack_out        = 1;
        busy           = (curr_state != IDLE);
        next_state     = curr_state;
        next_shift_reg = shift_reg;
        next_bit_cnt   = bit_cnt;
        next_rw_flag   = rw_flag;
        next_error     = error;

        case (curr_state)
            IDLE: if (start || restart) begin
                next_state     = ADDR;
                next_bit_cnt   = 7;
                next_rw_flag   = start ? 0 : rw_flag;
                next_shift_reg = {cfg_address, (start?0:rw_flag)};
                sda_oen        = 1;
            end
            ADDR: begin
                scl_oen = ~scl_clk;
                sda_oen = ~shift_reg[bit_cnt];
                if (scl_clk) begin
                    if (bit_cnt == 0) next_state = ACK_PHASE;
                    else next_bit_cnt = bit_cnt - 1;
                end
            end
            DATA: begin
                scl_oen = ~scl_clk;
                if (!rw_flag) sda_oen = ~shift_reg[bit_cnt];
                if (scl_clk) begin
                    if (bit_cnt == 0) next_state = ACK_PHASE;
                    else next_bit_cnt = bit_cnt - 1;
                end
                if (tx_valid && tx_ready) begin
                    next_shift_reg = tx_data;
                    next_bit_cnt   = 7;
                end
            end
            ACK_PHASE: begin
                scl_oen = ~scl_clk;
                if (scl_clk) begin
                    next_error = sda_int;
                    ack_out    = sda_int;
                    if (stop) next_state = STOP_PHASE;
                    else begin next_state = DATA; next_rw_flag = rw_flag; end
                end
            end
            STOP_PHASE: begin
                if (scl_clk) begin next_state = IDLE; sda_oen = 0; end
                else begin sda_oen = 1; scl_oen = 0; end
            end
        endcase
    end

    always_ff @(posedge scl_clk or negedge rst_n) begin
        if (!rst_n) begin
            curr_state <= IDLE;
            shift_reg  <= 0;
            bit_cnt    <= 0;
            rw_flag    <= 0;
            error      <= 0;
        end else begin
            curr_state <= next_state;
            shift_reg  <= next_shift_reg;
            bit_cnt    <= next_bit_cnt;
            rw_flag    <= next_rw_flag;
            error      <= next_error;
        end
    end
endmodule
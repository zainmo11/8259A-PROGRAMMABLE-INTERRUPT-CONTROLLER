module Data_Bus_Control_8259 (
    input  wire         chip_select_n,
    input  wire         read_enable_n,
    input  wire         write_enable_n,
    input  wire         address,
    input  wire [7:0]   data_bus_in,

    // Internal Bus
    output  reg [7:0] internal_data_bus,
    output  wire      write_initial_command_word_1,
    output  wire      write_initial_command_word_2_4,
    output  wire      write_operation_control_word_1,
    output  wire      write_operation_control_word_2,
    output  wire      write_operation_control_word_3,
    output  wire      read
);

    //
    // Internal Signals
    //
    reg prev_write_enable_n;
    reg stable_address;

    wire write_flag;

    // reg write_change;
    // initial write_change = 0;

    //
    // Write Control
    //
    always @(write_enable_n or chip_select_n) begin
        if (~write_enable_n & ~chip_select_n)
            internal_data_bus <= data_bus_in;
    end

    // always @(posedge write_enable_n or negedge write_enable_n) begin
    //     write_change <= ~write_change;
    // end

    // always @* begin
    //     if (chip_select_n)
    //         prev_write_enable_n <= 1'b1;
    //     else begin
    //         prev_write_enable_n <= write_enable_n;
    //     end
    // end
    // assign write_flag = ~prev_write_enable_n & write_enable_n;

    always @* begin
        stable_address <= address;
    end
    // stable_address register can be removed because there is no clock
    // The command word flasg can be assigned to wires for less flip-flop usage 

    //Generate write request flags
    // always @* begin
    //         write_initial_command_word_1   <= write_enable_n & ~stable_address & internal_data_bus[4];
    //         write_initial_command_word_2_4 <= write_enable_n & stable_address;
    //         write_operation_control_word_1 <= write_flag & stable_address;
    //         write_operation_control_word_2 <= write_flag & ~stable_address & ~internal_data_bus[4] & ~internal_data_bus[3];
    //         write_operation_control_word_3 <= write_flag & ~stable_address & ~internal_data_bus[4] & internal_data_bus[3];
    // end

    assign write_initial_command_word_1   = write_enable_n & ~stable_address & internal_data_bus[4];
    assign write_initial_command_word_2_4 = write_enable_n & stable_address;
    assign write_operation_control_word_1 = write_enable_n & stable_address;
    assign write_operation_control_word_2 = write_enable_n & ~stable_address & ~internal_data_bus[4] & ~internal_data_bus[3];
    assign write_operation_control_word_3 = write_enable_n & ~stable_address & ~internal_data_bus[4] & internal_data_bus[3];
    

    //
    // Read Control
    //
    // always @* begin
    //     read <= ~read_enable_n  & ~chip_select_n;
    //     write_out <= write_flag;
    // end

    assign read = ~read_enable_n  & ~chip_select_n;

endmodule
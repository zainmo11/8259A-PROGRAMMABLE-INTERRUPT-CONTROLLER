module Data_Bus_Control_8259 (
    input  wire         chip_select_n,
    input  wire         read_enable_n,
    input  wire         write_enable_n,
    input  wire         address,
    input  wire [7:0]   data_bus_in,

    // Internal Bus
    output  reg [7:0] internal_data_bus,
    output  reg      write_initial_command_word_1,
    output  reg      write_initial_command_word_2_4,
    output  reg      write_operation_control_word_1,
    output  reg      write_operation_control_word_2,
    output  reg      write_operation_control_word_3,
    output  reg      read
);

    //
    // Internal Signals
    //
    reg prev_write_enable_n;
    reg write_flag;
    reg stable_address;

    //
    // Write Control
    //
    always @* begin
        if (~write_enable_n & ~chip_select_n)
            internal_data_bus <= data_bus_in;
    end

    always @* begin
        if (chip_select_n)
            prev_write_enable_n <= 1'b1;
        else
            prev_write_enable_n <= write_enable_n;
    end
    assign write_flag = ~prev_write_enable_n & write_enable_n;

    always @* begin
        stable_address <= address;
    end

    // Generate write request flags
    always @* begin
            write_initial_command_word_1   <= write_flag & ~stable_address & internal_data_bus[4];
            write_initial_command_word_2_4 <= write_flag & stable_address;
            write_operation_control_word_1 <= write_flag & stable_address;
            write_operation_control_word_2 <= write_flag & ~stable_address & ~internal_data_bus[4] & ~internal_data_bus[3];
            write_operation_control_word_3 <= write_flag & ~stable_address & ~internal_data_bus[4] & internal_data_bus[3];
    end

    //
    // Read Control
    //
    always @* begin
        read <= ~read_enable_n  & ~chip_select_n;
    end

endmodule

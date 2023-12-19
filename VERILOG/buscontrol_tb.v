module BusControlTb();
    reg        chip_select_n;
    reg         read_enable_n;
    reg         write_enable_n;
    reg         address;
    reg [7:0]   data_bus_in;

    // Internal Bus
    wire [7:0] internal_data_bus;
    wire      write_initial_command_word_1;
    wire      write_initial_command_word_2_4;
    wire      write_operation_control_word_1;
    wire      write_operation_control_word_2;
    wire      write_operation_control_word_3;
    wire      read;
    wire write_out;


    Data_Bus_Control_8259 db(
        .chip_select_n (chip_select_n),
        .read_enable_n (read_enable_n),
        .write_enable_n (write_enable_n),
        .address (address),
        .data_bus_in (data_bus_in),

        // Internal Bus
        .internal_data_bus (internal_data_bus),
        .write_initial_command_word_1 (write_initial_command_word_1),
        .write_initial_command_word_2_4 (write_initial_command_word_2_4),
        .write_operation_control_word_1 (write_operation_control_word_1),
        .write_operation_control_word_2 (write_operation_control_word_2),
        .write_operation_control_word_3 (write_operation_control_word_3),
        .read (read),
        .write_out (write_out)
    );

    initial begin
        data_bus_in = 8'b11111111;
        write_enable_n = 0;
        chip_select_n = 0;
        address = 0;

        #10
        write_enable_n = 0; 
        data_bus_in = 8'b11101111;
        // #10;
        // write_enable_n = 0;
        // #10;
    end

endmodule
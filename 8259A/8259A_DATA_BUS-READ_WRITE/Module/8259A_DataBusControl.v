/**
 * @module Data_Bus_Control_8259
 * @brief This module controls the data bus for the 8259A chip.
 *
 * The Data_Bus_Control_8259 module takes in various control signals and data inputs to control the internal data bus.
 * It provides outputs for different write control signals and a read signal.
 *
 * @param chip_select_n         - Input wire: Chip select signal (active low)
 * @param read_enable_n         - Input wire: Read enable signal (active low)
 * @param write_enable_n        - Input wire: Write enable signal (active low)
 * @param address               - Input wire: Address input
 * @param data_bus_in           - Input wire [7:0]: Data bus input
 * @param internal_data_bus     - Output reg [7:0]: Internal data bus
 * @param write_initial_command_word_1   - Output wire: Write initial command word 1 signal
 * @param write_initial_command_word_2_4 - Output wire: Write initial command word 2-4 signal
 * @param write_operation_control_word_1 - Output wire: Write operation control word 1 signal
 * @param write_operation_control_word_2 - Output wire: Write operation control word 2 signal
 * @param write_operation_control_word_3 - Output wire: Write operation control word 3 signal
 * @param read                  - Output wire: Read signal
 */
module Data_Bus_Control_8259 (
    input  wire         chip_select_n,                // Chip select signal (active low)
    input  wire         read_enable_n,                // Read enable signal (active low)
    input  wire         write_enable_n,               // Write enable signal (active low)
    input  wire         address,                      // Address input
    input  wire [7:0]   data_bus_in,                  // Data bus input

    // Internal Bus
    output  reg [7:0] internal_data_bus,               // Internal data bus
    output  wire      write_initial_command_word_1,    // Write initial command word 1 signal
    output  wire      write_initial_command_word_2_4,  // Write initial command word 2-4 signal
    output  wire      write_operation_control_word_1,  // Write operation control word 1 signal
    output  wire      write_operation_control_word_2,  // Write operation control word 2 signal
    output  wire      write_operation_control_word_3,  // Write operation control word 3 signal
    output  wire      read                             // Read signal
);


    reg prev_write_enable_n;                            // Previous write enable signal
    wire write_flag;                                    // Write flag signal

    always @(write_enable_n or chip_select_n) begin
        if (~write_enable_n & ~chip_select_n)
            internal_data_bus <= data_bus_in;            // Update internal data bus when write and chip select are active low
    end


    assign write_initial_command_word_1   = write_enable_n & ~address & internal_data_bus[4];   // Generate write initial command word 1 signal
    assign write_initial_command_word_2_4 = write_enable_n & address;                            // Generate write initial command word 2-4 signal
    assign write_operation_control_word_1 = write_enable_n & address;                            // Generate write operation control word 1 signal
    assign write_operation_control_word_2 = write_enable_n & ~address & ~internal_data_bus[4] & ~internal_data_bus[3];   // Generate write operation control word 2 signal
    assign write_operation_control_word_3 = write_enable_n & ~address & ~internal_data_bus[4] & internal_data_bus[3];    // Generate write operation control word 3 signal
    assign read = ~read_enable_n  & ~chip_select_n;                                                      // Generate read signal

endmodule
/**
 * @module InitializationCommandWordModule1
 * @brief This module is responsible for initializing the command word for the 8259A control logic.
 *
 * The module takes in a write signal and an internal data bus, and outputs various configuration signals
 * for the interrupt controller. The configuration signals include the interrupt vector address, level or
 * edge-triggered configuration, call address interval 4 or 8 configuration, single or cascade configuration,
 * and set ICW4 configuration.
 *
 * The module updates the configuration signals based on the value of the write signal. When the write signal
 * is high (1'b1), the module updates the configuration signals with the values from the internal data bus.
 * When the write signal is low (1'b0), the module keeps the configuration signals unchanged.
 */

module InitializationCommandWord1(
    input write_initial_command_word_1,
    input write_initial_command_word_2,

    input [7:0] internal_data_bus,
    
    output reg [10:0] interrupt_vector_address,
    output reg level_or_edge_triggered_config,
    output reg call_address_interval_4_or_8_config,
    output reg single_or_cascade_config,
    output reg set_icw4_config
);

    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            interrupt_vector_address[2:0] <= internal_data_bus[7:5];
        else
            interrupt_vector_address[2:0] <= interrupt_vector_address; // Keep the value unchanged
    end

    //
    // Initialization command word 2
    //

    // A15-A8 (MCS-80) or T7-T3 (8086, 8088)
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            interrupt_vector_address[10:3] <= 3'b000;
        else if (write_initial_command_word_2 == 1'b1)
            interrupt_vector_address[10:3] <= internal_data_bus;
        else
            interrupt_vector_address[10:3] <= interrupt_vector_address[10:3];
    end

    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            level_or_edge_triggered_config <= internal_data_bus[3];
        else
            level_or_edge_triggered_config <= level_or_edge_triggered_config; // Keep the value unchanged
    end

    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            call_address_interval_4_or_8_config <= internal_data_bus[2];
        else
            call_address_interval_4_or_8_config <= call_address_interval_4_or_8_config; // Keep the value unchanged
    end

    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            single_or_cascade_config <= internal_data_bus[1];
        else
            single_or_cascade_config <= single_or_cascade_config; // Keep the value unchanged
    end

    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            set_icw4_config <= internal_data_bus[0];
        else
            set_icw4_config <= set_icw4_config; // Keep the value unchanged
    end

endmodule
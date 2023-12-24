/**
 * @module InitializationCommandWord4
 * @brief This module implements the initialization command word 4 logic for the 8259A control logic cascade IMR.
 *
 * The module takes inputs for writing the initial command word 1 and initial command word 4, as well as an internal data bus.
 * It provides outputs for various configuration signals including special fully nested mode, buffered mode, slave program,
 * buffered master or slave configuration, auto EOI configuration, and u8086 or MCS80 configuration.
 *
 * The module uses the inputs and internal data bus to determine the values of the configuration signals based on the write
 * control signals. If write_initial_command_word_1 is asserted, all configuration signals are set to 0. If write_initial_command_word_4
 * is asserted, the configuration signals are set based on the corresponding bits of the internal data bus. Otherwise, the configuration
 * signals retain their previous values.
 *
 * @param write_initial_command_word_1 Input signal to write the initial command word 1.
 * @param write_initial_command_word_4 Input signal to write the initial command word 4.
 * @param internal_data_bus Internal data bus providing configuration bits.
 * @param special_fully_nest_config Output signal for the special fully nested mode configuration.
 * @param buffered_mode_config Output signal for the buffered mode configuration.
 * @param slave_program Output signal for the slave program configuration.
 * @param buffered_master_or_slave_config Output signal for the buffered master or slave configuration.
 * @param auto_eoi_config Output signal for the auto EOI configuration.
 * @param u8086_or_mcs80_config Output signal for the u8086 or MCS80 configuration.
 */
module InitializationCommandWord4(
    input write_initial_command_word_1, // Input signal to write the initial command word 1.
    input write_initial_command_word_4, // Input signal to write the initial command word 4.
    input [7:0] internal_data_bus, // Internal data bus providing configuration bits.

    inout slave_program_or_enable_buffer,

    output reg special_fully_nest_config, // Output signal for the special fully nested mode configuration.
    output reg buffered_mode_config, // Output signal for the buffered mode configuration.
    output wire slave_program, // Output signal for the slave program configuration.
    output reg buffered_master_or_slave_config, // Output signal for the buffered master or slave configuration.
    output reg auto_eoi_config, // Output signal for the auto EOI configuration.
    output reg u8086_or_mcs80_config // Output signal for the u8086 or MCS80 configuration.
);

    // SFNM: Special Fully Nested Mode
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            special_fully_nest_config <= 1'b0; // Set to 0 when writing initial command word 1.
        else if (write_initial_command_word_4 == 1'b1)
            special_fully_nest_config <= internal_data_bus[4]; // Set based on bit 4 of internal data bus when writing initial command word 4.
        // Otherwise, retain previous value.
    end

    // BUF: Buffered Mode
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            buffered_mode_config <= 1'b0; // Set to 0 when writing initial command word 1.
        else if (write_initial_command_word_4 == 1'b1)
            buffered_mode_config <= internal_data_bus[3]; // Set based on bit 3 of internal data bus when writing initial command word 4.
        // Otherwise, retain previous value.
    end

    // SP/EN IO: Slave Program or Enable Buffer

    assign  slave_program_or_enable_buffer = buffered_mode_config ? ~buffered_mode_config : 1'bz;
    assign slave_program = slave_program_or_enable_buffer;

    // M/S: Buffered Master or Slave Configuration
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            buffered_master_or_slave_config <= 1'b0; // Set to 0 when writing initial command word 1.
        else if (write_initial_command_word_4 == 1'b1)
            buffered_master_or_slave_config <= internal_data_bus[2]; // Set based on bit 2 of internal data bus when writing initial command word 4.
        // Otherwise, retain previous value.
    end

    // AEOI: Auto EOI Configuration
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            auto_eoi_config <= 1'b0; // Set to 0 when writing initial command word 1.
        else if (write_initial_command_word_4 == 1'b1)
            auto_eoi_config <= internal_data_bus[1]; // Set based on bit 1 of internal data bus when writing initial command word 4.
        // Otherwise, retain previous value.
    end

    // uPM: u8086 or MCS80 Configuration
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            u8086_or_mcs80_config <= 1'b0; // Set to 0 when writing initial command word 1.
        else if (write_initial_command_word_4 == 1'b1)
            u8086_or_mcs80_config <= internal_data_bus[0]; // Set based on bit 0 of internal data bus when writing initial command word 4.
        // Otherwise, retain previous value.
    end

endmodule
/**
 * @module CascadeSignals
 * @brief Module for handling cascade signals in the 8259A control logic.
 *
 * This module is responsible for generating and controlling various cascade signals
 * used in the 8259A interrupt controller. It determines whether the device operates
 * in single or cascade mode, selects the master or slave based on the configuration,
 * handles cascade port I/O, and generates appropriate output signals.
 *
 * @param single_or_cascade_config Input signal indicating whether the device operates in single or cascade mode.
 * @param buffered_mode_config Input signal indicating whether the device operates in buffered mode.
 * @param slave_program Input signal indicating whether the device is a slave.
 * @param buffered_master_or_slave_config Input signal indicating the buffered master or slave configuration.
 * @param cascade_device_config Input signal indicating the cascade device configuration.
 * @param cascade_id Input signal indicating the cascade ID.
 * @param acknowledge_interrupt Input signal indicating an interrupt acknowledgement.
 * @param control_state Input signal indicating the control state.
 * @param cascade_slave Output signal indicating whether the device is a cascade slave.
 * @param cascade_io Output signal indicating the cascade port I/O.
 * @param cascade_slave_enable Output signal indicating whether the cascade slave is enabled.
 * @param interrupt_from_slave_device Output signal indicating an interrupt from the slave device.
 * @param cascade_output_ack_2_3 Output signal indicating the output ACK2 and ACK3.
 * @param cascade_out Output signal indicating the slave ID.
 */
module CascadeSignals(
    input single_or_cascade_config, // Input signal indicating whether the device operates in single or cascade mode.
    input buffered_mode_config, // Input signal indicating whether the device operates in buffered mode.
    input slave_program, // Input signal indicating whether the device is a slave.
    input buffered_master_or_slave_config, // Input signal indicating the buffered master or slave configuration.
    input [7:0] cascade_device_config, // Input signal indicating the cascade device configuration.
    input [2:0] cascade_id, // Input signal indicating the cascade ID.
    input acknowledge_interrupt, // Input signal indicating an interrupt acknowledgement.
    input control_state, // Input signal indicating the control state.
    output reg cascade_slave, // Output signal indicating whether the device is a cascade slave.
    output wire cascade_io, // Output signal indicating the cascade port I/O.
    output reg cascade_slave_enable, // Output signal indicating whether the cascade slave is enabled.
    output reg cascade_output_ack_2_3, // Output signal indicating the output ACK2 and ACK3.
    output reg [2:0] cascade_out // Output signal indicating the slave ID.
);
// Define parameters for control states
    localparam ACK1 = 3'b001;
    localparam ACK2 = 3'b010;
    localparam ACK3 = 3'b011;


    // Select master/slave
    always @* begin
        if (single_or_cascade_config == 1'b1)
            cascade_slave = 1'b0; // Device operates in single mode
        else if (buffered_mode_config == 1'b0)
            cascade_slave = ~slave_program; // Device operates in cascade mode, select master or slave based on slave_program
        else
            cascade_slave = ~buffered_master_or_slave_config; // Device operates in cascade mode, select master or slave based on buffered_master_or_slave_config
    end

    // Cascade port I/O
    assign cascade_io = cascade_slave;

    // Cascade signals (slave)
    always @* begin
        if (cascade_slave == 1'b0)
            cascade_slave_enable = 1'b0; // Cascade slave is not enabled
        else if (cascade_device_config[2:0] != cascade_id)
            cascade_slave_enable = 1'b0; // Cascade slave is not enabled
        else
            cascade_slave_enable = 1'b1; // Cascade slave is enabled
    end

    // Cascade signals (master)
    assign interrupt_from_slave_device = (acknowledge_interrupt & cascade_device_config) != 8'b00000000;

    // Output ACK2 and ACK3
    always @* begin
        if (single_or_cascade_config == 1'b1)
            cascade_output_ack_2_3 = 1'b1; // Output ACK2 and ACK3
        else if (cascade_slave_enable == 1'b1)
            cascade_output_ack_2_3 = 1'b1; // Output ACK2 and ACK3
        else if ((cascade_slave == 1'b0) && (interrupt_from_slave_device == 1'b0))
            cascade_output_ack_2_3 = 1'b1; // Output ACK2 and ACK3
        else
            cascade_output_ack_2_3 = 1'b0;
    end

    // Output slave ID
    always @* begin
        if (cascade_slave == 1'b1)
            cascade_out <= 3'b000; // Slave ID is 000
        else if ((control_state != ACK1) && (control_state != ACK2) && (control_state != ACK3))
            cascade_out <= 3'b000; // Slave ID is 000
        else if (interrupt_from_slave_device == 1'b0)
            cascade_out <= 3'b000; // Slave ID is 000
        else
            cascade_out <= bit2num(acknowledge_interrupt); // Convert acknowledge_interrupt to binary and assign as slave ID
    end

endmodule
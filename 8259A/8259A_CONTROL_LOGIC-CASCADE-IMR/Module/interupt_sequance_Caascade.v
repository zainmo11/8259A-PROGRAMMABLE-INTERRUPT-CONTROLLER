/**
 * @module CombinedModule
 * @brief This module combines the functionalities of CascadeSignals and AcknowledgeModule.
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
 * @param interrupt_acknowledge_n Input signal indicating interrupt acknowledge.
 * @param u8086_or_mcs80_config Input signal indicating the configuration mode (0 for u8086, 1 for MCS-80).
 * @param interrupt_when_ack1 Input signal indicating the interrupt number when ACK1 is active.
 * @param call_address_interval_4_or_8_config Input signal indicating the call address interval configuration (0 for 4, 1 for 8).
 * @param interrupt_vector_address Input signal indicating the interrupt vector address.
 * @param read Input signal indicating a read command.
 * @param out_control_logic_data Output signal indicating the control logic data output.
 * @param control_logic_data Output signal indicating the control logic data.
 */
module CombinedModule(
    // Inputs and outputs from CascadeSignals
    input single_or_cascade_config,
    input buffered_mode_config,
    input slave_program,
    input buffered_master_or_slave_config,
    input [7:0] cascade_device_config,
    input [2:0] cascade_id,
    input acknowledge_interrupt,
    input control_state,
    output reg cascade_slave,
    output wire cascade_io,
    output reg cascade_slave_enable,
    output wire interrupt_from_slave_device,
    output reg cascade_output_ack_2_3,
    output reg [2:0] cascade_out,
    // Inputs and outputs from AcknowledgeModule
    input interrupt_acknowledge_n,
    input u8086_or_mcs80_config,
    input [7:0] interrupt_when_ack1,
    input call_address_interval_4_or_8_config,
    input [10:0] interrupt_vector_address,
    input read,
    output reg out_control_logic_data,
    output reg [7:0] control_logic_data
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
`include "Internal_Functions.v"

// Define parameters for control states
    localparam CTL_READY = 3'b000;
    localparam POLL = 3'b100;

    always @(interrupt_acknowledge_n) begin
        if (interrupt_acknowledge_n == 1'b0) begin
            // Acknowledge
            case (control_state)
                CTL_READY: begin
                    if (cascade_slave == 1'b0) begin
                        if (u8086_or_mcs80_config == 1'b0) begin
                            out_control_logic_data = 1'b1;
                            control_logic_data     = 8'b11001101; // Control logic data for u8086 configuration
                        end
                        else begin
                            out_control_logic_data = 1'b0;
                            control_logic_data     = 8'bz; // Control logic data for MCS-80 configuration
                        end
                    end
                    else begin
                        out_control_logic_data = 1'b0;
                        control_logic_data     = 8'bz; // Control logic data for cascade slave
                    end
                end
                ACK1: begin
                    if (cascade_slave == 1'b0) begin
                        if (u8086_or_mcs80_config == 1'b0) begin
                            out_control_logic_data = 1'b1;
                            control_logic_data     = 8'b11001101; // Control logic data for u8086 configuration
                        end
                        else begin
                            out_control_logic_data = 1'b0;
                            control_logic_data     = 8'bz; // Control logic data for MCS-80 configuration
                        end
                    end
                    else begin
                        out_control_logic_data = 1'b0;
                        control_logic_data     = 8'bz; // Control logic data for cascade slave
                    end
                end
                ACK2: begin
                    if (cascade_output_ack_2_3 == 1'b1) begin
                        out_control_logic_data = 1'b1;

                        if (cascade_slave == 1'b1)
                            control_logic_data[2:0] = bit2num(interrupt_when_ack1);
                        else
                            control_logic_data[2:0] = bit2num(acknowledge_interrupt);

                        if (u8086_or_mcs80_config == 1'b0) begin
                            if (call_address_interval_4_or_8_config == 1'b0)
                                control_logic_data = {interrupt_vector_address[2:1], control_logic_data[2:0], 3'b000}; // Control logic data for 4-byte call address interval
                            else
                                control_logic_data = {interrupt_vector_address[2:0], control_logic_data[2:0], 2'b00}; // Control logic data for 8-byte call address interval
                        end
                        else begin
                            control_logic_data = {interrupt_vector_address[10:6], control_logic_data[2:0]}; // Control logic data for MCS-80 configuration
                        end
                    end
                    else begin
                        out_control_logic_data = 1'b0;
                        control_logic_data     = 8'bz; // Control logic data when cascade_output_ack_2_3 is not active
                    end
                end
                ACK3: begin
                    if (cascade_output_ack_2_3 == 1'b1) begin
                        out_control_logic_data = 1'b1;
                        control_logic_data     = interrupt_vector_address[10:3]; // Control logic data for ACK3 state
                    end
                    else begin
                        out_control_logic_data = 1'b0;
                        control_logic_data     = 8'bz; // Control logic data when cascade_output_ack_2_3 is not active
                    end
                end
                default: begin
                    out_control_logic_data = 1'b0;
                    control_logic_data     = 8'bz; // Control logic data for default state
                end
            endcase
        end
        else if ((control_state == POLL) && (read == 1'b1)) begin
            // Poll command
            out_control_logic_data = 1'b1;
            if (acknowledge_interrupt == 8'b00000000)
                control_logic_data = 8'bz; // Control logic data when acknowledge_interrupt is 0
            else begin
                control_logic_data[7:3] = 5'b10000; // Control logic data for non-zero acknowledge_interrupt
                control_logic_data[2:0] = bit2num(acknowledge_interrupt);
            end
        end
        else begin
            // Nothing
            out_control_logic_data = 1'b0;
            control_logic_data     = 8'bz; // Control logic data when no conditions are met
        end
    end
endmodule
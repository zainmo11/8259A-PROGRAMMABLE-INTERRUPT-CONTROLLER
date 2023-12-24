/**
 * @module AcknowledgeModule
 * @brief This module handles the acknowledgement logic for the 8259A interrupt controller.
 *
 * @param interrupt_acknowledge_n Input signal indicating interrupt acknowledge.
 * @param cascade_slave Input signal indicating whether the module is a cascade slave.
 * @param u8086_or_mcs80_config Input signal indicating the configuration mode (0 for u8086, 1 for MCS-80).
 * @param control_state Input signal indicating the current control state.
 * @param cascade_output_ack_2_3 Input signal indicating the cascade output acknowledge status.
 * @param interrupt_when_ack1 Input signal indicating the interrupt number when ACK1 is active.
 * @param acknowledge_interrupt Input signal indicating the interrupt number to acknowledge.
 * @param call_address_interval_4_or_8_config Input signal indicating the call address interval configuration (0 for 4, 1 for 8).
 * @param interrupt_vector_address Input signal indicating the interrupt vector address.
 * @param read Input signal indicating a read command.
 * @param out_control_logic_data Output signal indicating the control logic data output.
 * @param control_logic_data Output signal indicating the control logic data.
 */
module AcknowledgeModule(
    input interrupt_acknowledge_n,
    input cascade_slave,
    input u8086_or_mcs80_config,
    input [2:0] control_state,
    input cascade_output_ack_2_3,
    input [7:0] interrupt_when_ack1,
    input [7:0] acknowledge_interrupt,
    input call_address_interval_4_or_8_config,
    input [10:0] interrupt_vector_address,
    input read,
    output reg out_control_logic_data,
    output reg [7:0] control_logic_data
);


`include "Internal_Functions.v"

// Define parameters for control states
    localparam CTL_READY = 3'b000;
    localparam ACK1 = 3'b001;
    localparam ACK2 = 3'b010;
    localparam ACK3 = 3'b011;
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
                            control_logic_data = {interrupt_vector_address[10:6], control_logic_data[2:0]}; // Control logic data for 8086 configuration
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
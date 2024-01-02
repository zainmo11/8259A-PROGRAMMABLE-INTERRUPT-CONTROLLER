/**
 * @module OperationControlWord2
 * @brief This module implements the operation control logic for the 8259A interrupt controller.
 *
 * The OperationControlWord2 module takes various inputs related to the operation control word and generates
 * outputs such as end_of_interrupt, auto_rotate_mode, and priority_rotate based on the specified conditions.
 *
 * @param write_initial_command_word_1 Input signal to write the initial command word 1.
 * @param auto_eoi_config Input signal for auto EOI configuration.
 * @param end_of_acknowledge_sequence Input signal indicating the end of the acknowledge sequence.
 * @param acknowledge_interrupt Input signal representing the interrupt being acknowledged.
 * @param write_operation_control_word_2 Input signal to write the operation control word 2.
 * @param internal_data_bus Input bus for internal data.
 * @param highest_level_in_service Input signal representing the highest level in service.
 * @param num2bit Input signal representing the number to bit conversion.
 * @param end_of_interrupt Output signal representing the end of interrupt.
 * @param auto_rotate_mode Output signal indicating the auto rotate mode.
 * @param priority_rotate Output signal representing the priority rotate value.
 * @param bit2num Input signal representing the bit to number conversion.
 */

module OperationControlWord2(
    input write_initial_command_word_1, // Input signal to write the initial command word 1.
    input auto_eoi_config, // Input signal for auto EOI configuration.
    input end_of_acknowledge_sequence, // Input signal indicating the end of the acknowledge sequence.
    input [7:0] acknowledge_interrupt, // Input signal representing the interrupt being acknowledged.
    input write_operation_control_word_2, // Input signal to write the operation control word 2.
    input [7:0] internal_data_bus, // Input bus for internal data.
    input [7:0] highest_level_in_service, // Input signal representing the highest level in service.
    
    output reg [7:0] end_of_interrupt, // Output signal representing the end of interrupt.
    output reg auto_rotate_mode, // Output signal indicating the auto rotate mode.
    output reg [2:0] priority_rotate // Output signal representing the priority rotate value.
);
    `include "C:\\Users\\Mahmoud\\Downloads\\CA_fork\\8259A-PROGRAMMABLE-INTERRUPT-CONTROLLER\\8259A\\8259A_CONTROL_LOGIC-CASCADE-IMR\\Module\\Internal_Modules\\Internal_Functions.v"

    // End of interrupt
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            end_of_interrupt = 8'b11111111; // Set end_of_interrupt to all ones if write_initial_command_word_1 is high.
        else if ((auto_eoi_config == 1'b1) && (end_of_acknowledge_sequence == 1'b1))
            end_of_interrupt = acknowledge_interrupt; // Set end_of_interrupt to acknowledge_interrupt if auto_eoi_config and end_of_acknowledge_sequence are high.
        else if (write_operation_control_word_2 == 1'b1) begin
            casez (internal_data_bus[6:5])
                2'b01:   end_of_interrupt = highest_level_in_service; // Rotate on non specific EOI
                2'b11:   end_of_interrupt = num2bit(internal_data_bus[2:0]); // Specific EOI
                default: end_of_interrupt = 8'b00000000; // Set end_of_interrupt to all zeros for other cases.
            endcase
        end
        else
            end_of_interrupt = 8'b00000000; // Set end_of_interrupt to all zeros if none of the conditions are met.
    end

    // Auto rotate mode
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            auto_rotate_mode <= 1'b0; // Set auto_rotate_mode to 0 if write_initial_command_word_1 is high.
        else if (write_operation_control_word_2 == 1'b1) begin
            casez (internal_data_bus[7:5])
                3'b000:  auto_rotate_mode <= 1'b0; // Set auto_rotate_mode to 0 if internal_data_bus[7:5] is 3'b000.
                3'b100:  auto_rotate_mode <= 1'b1; // Set auto_rotate_mode to 1 if internal_data_bus[7:5] is 3'b100.
                default: auto_rotate_mode <= auto_rotate_mode; // Keep auto_rotate_mode unchanged for other cases.
            endcase
        end
        else
            auto_rotate_mode <= auto_rotate_mode; // Keep auto_rotate_mode unchanged if none of the conditions are met.
    end

    // Rotate
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            priority_rotate <= 3'b111; // Set priority_rotate to 3'b111 if write_initial_command_word_1 is high.
        else if ((auto_rotate_mode == 1'b1) && (end_of_acknowledge_sequence == 1'b1))
            priority_rotate <= bit2num(acknowledge_interrupt); // Set priority_rotate to bit2num if auto_rotate_mode and end_of_acknowledge_sequence are high.
        else if (write_operation_control_word_2 == 1'b1) begin
            casez (internal_data_bus[7:5])
                3'b101:  priority_rotate <= bit2num(highest_level_in_service); // Set priority_rotate to bit2num if internal_data_bus[7:5] is 3'b101.
                3'b11?:  priority_rotate <= internal_data_bus[2:0]; // Set specific priority
                default: priority_rotate <= priority_rotate; // Keep priority_rotate unchanged for other cases.
            endcase
        end
        else
            priority_rotate <= priority_rotate; // Keep priority_rotate unchanged if none of the conditions are met.
    end

endmodule
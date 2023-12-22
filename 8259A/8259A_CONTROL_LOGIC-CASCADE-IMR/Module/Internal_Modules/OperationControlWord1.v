/**
 * @module OperationControlWord1
 * @brief This module implements the operation control word 1 logic for the 8259A interrupt controller.
 *
 * The module takes several inputs including write_initial_command_word_1, write_operation_control_word_1_registers,
 * special_mask_mode, and internal_data_bus. It provides two outputs: interrupt_mask and interrupt_special_mask.
 *
 * The interrupt_mask output is determined based on the inputs. If write_initial_command_word_1 is high, interrupt_mask
 * is set to all ones (8'b11111111). If write_operation_control_word_1_registers is high and special_mask_mode is low,
 * interrupt_mask is set to the value of internal_data_bus. Otherwise, interrupt_mask remains unchanged.
 *
 * The interrupt_special_mask output is also determined based on the inputs. If write_initial_command_word_1 is high,
 * interrupt_special_mask is set to all zeros (8'b00000000). If special_mask_mode is low, interrupt_special_mask is
 * set to all zeros. If write_operation_control_word_1_registers is high, interrupt_special_mask is set to the value
 * of internal_data_bus. Otherwise, interrupt_special_mask remains unchanged.
 */

module OperationControlWord1(
    input write_initial_command_word_1, // Input signal to write initial command word 1
    input write_operation_control_word_1_registers, // Input signal to write operation control word 1 registers
    input special_mask_mode, // Input signal for special mask mode
    input [7:0] internal_data_bus, // Input bus for internal data
    output reg [7:0] interrupt_mask, // Output signal for interrupt mask
    output reg [7:0] interrupt_special_mask // Output signal for interrupt special mask
);

    // IMR
    always @* begin
        if (write_initial_command_word_1 == 1'b1) // If write_initial_command_word_1 is high
            interrupt_mask <= 8'b11111111; // Set interrupt_mask to all ones
        else if ((write_operation_control_word_1_registers == 1'b1) && (special_mask_mode == 1'b0)) // If write_operation_control_word_1_registers is high and special_mask_mode is low
            interrupt_mask <= internal_data_bus; // Set interrupt_mask to the value of internal_data_bus
        else
            interrupt_mask <= interrupt_mask; // Keep interrupt_mask unchanged
    end

    // Special mask
    always @* begin
        if (write_initial_command_word_1 == 1'b1) // If write_initial_command_word_1 is high
            interrupt_special_mask <= 8'b00000000; // Set interrupt_special_mask to all zeros
        else if (special_mask_mode == 1'b0) // If special_mask_mode is low
            interrupt_special_mask <= 8'b00000000; // Set interrupt_special_mask to all zeros
        else if (write_operation_control_word_1_registers  == 1'b1) // If write_operation_control_word_1_registers is high
            interrupt_special_mask <= internal_data_bus; // Set interrupt_special_mask to the value of internal_data_bus
        else
            interrupt_special_mask <= interrupt_special_mask; // Keep interrupt_special_mask unchanged
    end

endmodule
/**
 * Module: OperationControlWord3
 * Description: This module implements the control logic for the operation control word 3 registers in the 8259A interrupt controller.
 * Inputs:
 *   - write_initial_command_word_1: Input signal to write the initial command word 1.
 *   - write_operation_control_word_3_registers: Input signal to write the operation control word 3 registers.
 *   - internal_data_bus[7:0]: Input bus for internal data.
 * Outputs:
 *   - special_mask_mode: Output signal indicating the special mask mode.
 *   - enable_read_register: Output signal indicating whether to enable reading the register.
 *   - read_register_isr_or_irr: Output signal indicating whether to read the register for ISR or IRR.
 */

module OperationControlWord3(
    input write_initial_command_word_1, // Input signal to write the initial command word 1.
    input write_operation_control_word_3_registers, // Input signal to write the operation control word 3 registers.
    input [7:0] internal_data_bus, // Input bus for internal data.
    output reg special_mask_mode, // Output signal indicating the special mask mode.
    output reg enable_read_register, // Output signal indicating whether to enable reading the register.
    output reg read_register_isr_or_irr // Output signal indicating whether to read the register for ISR or IRR.
);

    // ESMM / SMM
    always @* begin
        if (write_initial_command_word_1 == 1'b1) begin
            special_mask_mode <= 1'b0; // Set special mask mode to 0 when writing initial command word 1.
        end
        else if ((write_operation_control_word_3_registers == 1'b1) && (internal_data_bus[6] == 1'b1)) begin
            special_mask_mode <= internal_data_bus[5]; // Set special mask mode based on internal data bus when writing operation control word 3 registers.
        end
        else begin
            special_mask_mode <= special_mask_mode; // Maintain current special mask mode.
        end
    end

    // RR/RIS
    always @* begin
        if (write_initial_command_word_1 == 1'b1) begin
            enable_read_register     <= 1'b1; // Enable read register when writing initial command word 1.
            read_register_isr_or_irr <= 1'b0; // Set read register for ISR or IRR to 0 when writing initial command word 1.
        end
        else if (write_operation_control_word_3_registers == 1'b1) begin
            enable_read_register     <= internal_data_bus[1]; // Set enable read register based on internal data bus when writing operation control word 3 registers.
            read_register_isr_or_irr <= internal_data_bus[0]; // Set read register for ISR or IRR based on internal data bus when writing operation control word 3 registers.
        end
        else begin
            enable_read_register     <= enable_read_register; // Maintain current enable read register.
            read_register_isr_or_irr <= read_register_isr_or_irr; // Maintain current read register for ISR or IRR.
        end
    end

endmodule
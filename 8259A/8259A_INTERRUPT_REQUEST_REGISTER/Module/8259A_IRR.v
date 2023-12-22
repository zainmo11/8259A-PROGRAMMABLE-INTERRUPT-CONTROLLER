/**
 * @module Interrupt_Request_8259A
 * @brief This module implements the Interrupt Request Register (IRR) of the 8259A Programmable Interrupt Controller (PIC).
 *
 * The IRR is responsible for storing the interrupt requests from the interrupt sources. It supports both level-triggered and edge-triggered interrupts.
 *
 * @param level_or_edge_triggered_config Input wire indicating whether the interrupts are level-triggered or edge-triggered.
 * @param freeze Input wire used to freeze the interrupt request register.
 * @param clear_interrupt_request Input wire used to clear specific interrupt requests.
 * @param interrupt_request_pin Input wire representing the interrupt requests from the interrupt sources.
 * @param interrupt_request_register Output register representing the stored interrupt requests.
 */

module Interrupt_Request_8259A (
    input wire level_or_edge_triggered_config, // Input wire indicating whether the interrupts are level-triggered or edge-triggered.
    input wire freeze, // Input wire used to freeze the interrupt request register.
    input wire [7:0] clear_interrupt_request, // Input wire used to clear specific interrupt requests.
    input wire [7:0] interrupt_request_pin, // Input wire representing the interrupt requests from the interrupt sources.
    output reg [7:0] interrupt_request_register // Output register representing the stored interrupt requests.
);

    reg [7:0] low_input_latch; // Register to store the low input latch values.
    wire [7:0] interrupt_request_edge; // Wire to store the edge-triggered interrupt requests.

    generate
        genvar ir_bit_no;
        for (ir_bit_no = 0; ir_bit_no <= 7; ir_bit_no = ir_bit_no + 1) begin: Request_Latch
            always @(interrupt_request_pin[ir_bit_no], clear_interrupt_request[ir_bit_no]) begin
                if (clear_interrupt_request[ir_bit_no])
                    low_input_latch[ir_bit_no] <= 1'b0; // Clear the low input latch if clear_interrupt_request is asserted.
                else if (interrupt_request_pin[ir_bit_no])
                    low_input_latch[ir_bit_no] <= 1'b1; // Set the low input latch if interrupt_request_pin is asserted.
                else
                    low_input_latch[ir_bit_no] <= low_input_latch[ir_bit_no]; // Retain the previous value of the low input latch.
            end

            assign interrupt_request_edge[ir_bit_no] = low_input_latch[ir_bit_no]; // Assign the value of low_input_latch to interrupt_request_edge.

            always @* begin
                if (clear_interrupt_request[ir_bit_no])
                    interrupt_request_register[ir_bit_no] <= 1'b0; // Clear the interrupt request register if clear_interrupt_request is asserted.
                else if (freeze)
                    interrupt_request_register[ir_bit_no] <= interrupt_request_register[ir_bit_no]; // Retain the previous value of the interrupt request register if freeze is asserted.
                else if (level_or_edge_triggered_config)
                    interrupt_request_register[ir_bit_no] <= interrupt_request_pin[ir_bit_no]; // Store the value of interrupt_request_pin in the interrupt request register if interrupts are level-triggered.
                else
                    interrupt_request_register[ir_bit_no] <= interrupt_request_edge[ir_bit_no]; // Store the value of interrupt_request_edge in the interrupt request register if interrupts are edge-triggered.
            end
        end
    endgenerate

endmodule

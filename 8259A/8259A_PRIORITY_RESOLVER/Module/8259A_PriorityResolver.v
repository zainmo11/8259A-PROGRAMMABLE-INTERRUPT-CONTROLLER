/**
 * Module: Priority_Resolver_8259A
 * Description: This module implements a priority resolver for the 8259A interrupt controller.
 *              It takes inputs from the control logic and interrupt registers, and outputs the highest priority interrupt.
 * Inputs:
 *   - priority_rotate: 3-bit input representing the priority rotation value.
 *   - interrupt_mask: 8-bit input representing the interrupt mask.
 *   - interrupt_special_mask: 8-bit input representing the special interrupt mask.
 *   - special_fully_nest_config: 1-bit input indicating whether the special interrupt is fully nested.
 *   - highest_level_in_service: 8-bit input representing the highest level interrupt in service.
 *   - interrupt_request_register: 8-bit input representing the interrupt request register.
 *   - in_service_register: 8-bit input representing the in-service register.
 * Outputs:
 *   - interrupt: 8-bit output representing the highest priority interrupt.
 */

module Priority_Resolver_8259A (
    input   wire   [2:0]   priority_rotate,                  // Priority rotation value
    input   wire   [7:0]   interrupt_mask,                   // Interrupt mask
    input   wire   [7:0]   interrupt_special_mask,           // Special interrupt mask
    input   wire           special_fully_nest_config,        // Flag indicating whether special interrupt is fully nested
    input   wire   [7:0]   highest_level_in_service,         // Highest level interrupt in service
    input   wire   [7:0]   interrupt_request_register,       // Interrupt request register
    input   wire   [7:0]   in_service_register,              // In-service register
    output  wire   [7:0]   interrupt                         // Highest priority interrupt
);

    `include "Internal_Functions.v"
    `include "PriorityMaskModule.v"

    wire   [7:0]   masked_interrupt_request;
    wire   [7:0]   masked_in_service;
    wire   [7:0]   rotated_request;
    wire   [7:0]   rotated_highest_level_in_service;
    wire   [7:0]   rotated_interrupt;
    reg    [7:0]   rotated_in_service;
    
    wire    [7:0]   priority_mask;

    // Apply interrupt mask to interrupt request register
    assign masked_interrupt_request = interrupt_request_register & ~interrupt_mask;

    // Apply interrupt special mask to in-service register
    assign masked_in_service = in_service_register & ~interrupt_special_mask;

    // Rotate interrupt request register based on priority rotation value
    assign rotated_request = rotate_right(masked_interrupt_request, priority_rotate);
    
    // Rotate highest level interrupt in service based on priority rotation value
    assign rotated_highest_level_in_service = rotate_right(highest_level_in_service, priority_rotate);

    // Update rotated in-service register based on priority rotation value
    always @(*) begin
        rotated_in_service = rotate_right(masked_in_service, priority_rotate);

        // If special interrupt is fully nested, update rotated in-service register accordingly
        if (special_fully_nest_config == 1'b1)
            rotated_in_service = (rotated_in_service & ~rotated_highest_level_in_service)
                                | {rotated_highest_level_in_service[6:0], 1'b0};
    end

    // Instantiate PriorityMaskModule to calculate priority mask
    PriorityMaskModule priorityMaskInstance(
            .rotated_in_service(rotated_in_service),
            .priority_mask(priority_mask)
    );
    
    // Resolve highest priority interrupt based on rotated request and priority mask
    assign rotated_interrupt = resolv_priority(rotated_request) & priority_mask;

    // Rotate back the highest priority interrupt based on priority rotation value
    assign interrupt = rotate_left(rotated_interrupt, priority_rotate);

endmodule
/**
 * Module: In_Service_8259A
 * Description: This module implements the in-service register and highest level in-service logic for the 8259A interrupt controller.
 * 
 * Inputs:
 * - priority_rotate: 3-bit input representing the priority rotation value.
 * - interrupt_special_mask: 8-bit input representing the interrupt special mask.
 * - interrupt: 8-bit input representing the interrupt signals.
 * - latch_in_service: 1-bit input indicating whether to latch the interrupt signals into the in-service register.
 * - end_of_interrupt: 8-bit input representing the end of interrupt signals.
 * 
 * Outputs:
 * - in_service_register: 8-bit output representing the in-service register.
 * - highest_level_in_service: 8-bit output representing the highest level interrupt in the in-service register.
 */

 `include "C:\\Users\\Mahmoud\\Downloads\\CA_fork\\8259A-PROGRAMMABLE-INTERRUPT-CONTROLLER\\8259A\\8259A_IN_SERVICE_REGISTER\\Module\\Internal_Modules\\HighestLevelServiceModule.v"   // Include highest level service module


module In_Service_8259A (
    input   [2:0]   priority_rotate,                // Priority rotation value
    input   [7:0]   interrupt_special_mask,         // Interrupt special mask
    input   [7:0]   interrupt,                      // Interrupt signals
    input            latch_in_service,              // Latch interrupt signals into the in-service register
    input   [7:0]   end_of_interrupt,               // End of interrupt signals
    output  reg [7:0]   in_service_register,         // In-service register
    
    output  wire [7:0]   highest_level_in_service     // Highest level interrupt in the in-service register
);

    `include "C:\\Users\\Mahmoud\\Downloads\\CA_fork\\8259A-PROGRAMMABLE-INTERRUPT-CONTROLLER\\8259A\\8259A_IN_SERVICE_REGISTER\\Module\\Internal_Modules\\Internal_Functions.v"                      // Include Internal_Functions

    wire   [7:0]   next_in_service_register;         // Wire for the next in-service register value

    initial begin
        in_service_register = 8'b00000000;          // Initialize in-service register to all zeros
    end

    // Calculate the next in-service register value based on the inputs
    assign next_in_service_register = (in_service_register & ~end_of_interrupt)
                                     | (latch_in_service == 1'b1 ? interrupt : 8'b00000000);

    // Instantiate the HighestLevelServiceModule to determine the highest level interrupt in the in-service register
    HighestLevelServiceModule highestLevelServiceInstance(
        .next_in_service_register(next_in_service_register),
        .interrupt_special_mask(interrupt_special_mask),
        .priority_rotate(priority_rotate),
        .highest_level_in_service(highest_level_in_service)
    );

    always @*
        in_service_register <= next_in_service_register;  // Update the in-service register

endmodule
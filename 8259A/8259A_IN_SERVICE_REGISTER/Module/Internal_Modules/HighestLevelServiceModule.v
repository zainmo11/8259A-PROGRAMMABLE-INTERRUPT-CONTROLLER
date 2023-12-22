module HighestLevelServiceModule(
    input [7:0] next_in_service_register,          // Input: Next in-service register
    input [7:0] interrupt_special_mask,            // Input: Interrupt special mask
    input [7:0] priority_rotate,                    // Input: Priority rotate
    output reg [7:0] highest_level_in_service       // Output: Highest level in-service
);

    reg [7:0] next_highest_level_in_service;        // Internal register for next highest level in-service

    always @(*) begin
        next_highest_level_in_service = next_in_service_register & ~interrupt_special_mask;   // Mask out interrupt special bits
        next_highest_level_in_service = rotate_right(next_highest_level_in_service, priority_rotate);   // Rotate right based on priority rotate value
        next_highest_level_in_service = resolv_priority(next_highest_level_in_service);   // Resolve priority conflicts
        next_highest_level_in_service = rotate_left(next_highest_level_in_service, priority_rotate);   // Rotate left based on priority rotate value
        highest_level_in_service = next_highest_level_in_service;   // Assign the next highest level in-service to the output
    end

endmodule
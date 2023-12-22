module In_Service_8259A (

    // Inputs
    input   [2:0]   priority_rotate,
    input   [7:0]   interrupt_special_mask,
    input   [7:0]   interrupt,
    input            latch_in_service,
    input   [7:0]   end_of_interrupt,

    // Outputs
    output  reg [7:0]   in_service_register,
    output  reg [7:0]   highest_level_in_service
);
    `include "CommonPackage.v"

    wire   [7:0]   next_in_service_register;

    initial in_service_register = 8'b00000000;

    assign next_in_service_register = (in_service_register & ~end_of_interrupt)
                                     | (latch_in_service == 1'b1 ? interrupt : 8'b00000000);

    always @* begin
        in_service_register <= next_in_service_register;
    end

    reg   [7:0]   next_highest_level_in_service;

    always @* begin
        next_highest_level_in_service = next_in_service_register & ~interrupt_special_mask;
        next_highest_level_in_service = rotate_right(next_highest_level_in_service, priority_rotate);
        next_highest_level_in_service = resolv_priority(next_highest_level_in_service);
        next_highest_level_in_service = rotate_left(next_highest_level_in_service, priority_rotate);
        highest_level_in_service = next_highest_level_in_service;
    end

    // always @(negedge clock, posedge reset) begin
    //     if (reset)
    //         highest_level_in_service <= 8'b00000000;
    //     else
            
    // end

endmodule
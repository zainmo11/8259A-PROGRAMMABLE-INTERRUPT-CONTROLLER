module Priority_Resolver_8259A (
    // Inputs from control logic
    input   wire   [2:0]   priority_rotate,
    input   wire   [7:0]   interrupt_mask,
    input   wire   [7:0]   interrupt_special_mask,
    input   wire           special_fully_nest_config,
    input   wire   [7:0]   highest_level_in_service,

    // Inputs
    input   wire   [7:0]   interrupt_request_register,
    input   wire   [7:0]   in_service_register,

    // Outputs
    output  wire   [7:0]   interrupt
);

    `include "CommonPackage.v"

    // Masked flags
    wire   [7:0]   masked_interrupt_request;
    // IRR after masking
    assign masked_interrupt_request = interrupt_request_register & ~interrupt_mask;

    wire   [7:0]   masked_in_service;
    //ISR After masking
    assign masked_in_service        = in_service_register & ~interrupt_special_mask;

    // Resolve priority
    wire   [7:0]   rotated_request;
    wire   [7:0]   rotated_highest_level_in_service;
    wire   [7:0]   rotated_interrupt;

    reg   [7:0]   rotated_in_service;
    reg   [7:0]   priority_mask;

    assign rotated_request = rotate_right(masked_interrupt_request, priority_rotate);

    assign rotated_highest_level_in_service = rotate_right(highest_level_in_service, priority_rotate);

    always @(*) begin
        rotated_in_service = rotate_right(masked_in_service, priority_rotate);

        if (special_fully_nest_config == 1'b1)
            rotated_in_service = (rotated_in_service & ~rotated_highest_level_in_service)
                                | {rotated_highest_level_in_service[6:0], 1'b0};
    end

    always @(*) begin
        if      (rotated_in_service[0] == 1'b1) priority_mask = 8'b00000000;
        else if (rotated_in_service[1] == 1'b1) priority_mask = 8'b00000001;
        else if (rotated_in_service[2] == 1'b1) priority_mask = 8'b00000011;
        else if (rotated_in_service[3] == 1'b1) priority_mask = 8'b00000111;
        else if (rotated_in_service[4] == 1'b1) priority_mask = 8'b00001111;
        else if (rotated_in_service[5] == 1'b1) priority_mask = 8'b00011111;
        else if (rotated_in_service[6] == 1'b1) priority_mask = 8'b00111111;
        else if (rotated_in_service[7] == 1'b1) priority_mask = 8'b01111111;
        else                                    priority_mask = 8'b11111111;
    end

    assign rotated_interrupt = resolv_priority(rotated_request) & priority_mask;

    assign interrupt = rotate_left(rotated_interrupt, priority_rotate);

endmodule

`define TB_CYCLE        20
`define TB_FINISH_COUNT 20000

module Priority_Resolver_8259A_tm();

    `timescale 1ns/10ps
    // timeunit        1ns;
    // timeprecision   10ps;

    //
    // Module under test
    //
    //
    reg   [2:0]   priority_rotate;
    reg   [7:0]   interrupt_mask;
    reg   [7:0]   interrupt_special_mask;
    reg           special_fully_nest_config;
    reg   [7:0]   highest_level_in_service;

    reg   [7:0]   interrupt_request_register;
    reg   [7:0]   in_service_register;

    reg   [7:0]   interrupt;

    KF8259_Priority_Resolver u_KF8259_Priority_Resolver(.*);

    //
    // Task : Initialization
    //
    task TASK_INIT();
    begin
        #(`TB_CYCLE * 0);
        priority_rotate            = 3'b111;
        interrupt_mask             = 8'b11111111;
        interrupt_special_mask     = 8'b00000000;
        special_fully_nest_config  = 1'b0;
        highest_level_in_service   = 8'b00000000;
        interrupt_request_register = 8'b00000000;
        in_service_register        = 8'b00000000;
        #(`TB_CYCLE * 12);
    end
    endtask

    //
    // Task : Scan
    //
    task TASK_SCAN_INTERRUPT_REQUEST();
    begin
        #(`TB_CYCLE * 0);
        interrupt_request_register = 8'b10000000;
        #(`TB_CYCLE * 1);
        interrupt_request_register = 8'b11000000;
        #(`TB_CYCLE * 1);
        interrupt_request_register = 8'b11100000;
        #(`TB_CYCLE * 1);
        interrupt_request_register = 8'b11110000;
        #(`TB_CYCLE * 1);
        interrupt_request_register = 8'b11111000;
        #(`TB_CYCLE * 1);
        interrupt_request_register = 8'b11111100;
        #(`TB_CYCLE * 1);
        interrupt_request_register = 8'b11111110;
        #(`TB_CYCLE * 1);
        interrupt_request_register = 8'b11111111;
        #(`TB_CYCLE * 1);
        interrupt_request_register = 8'b00000000;
        #(`TB_CYCLE * 1);
    end
    endtask

    //
    // Task : INTERRUPT MASK TEST
    //
    task TASK_INTERRUPT_MASK_TEST();
    begin
        TASK_SCAN_INTERRUPT_REQUEST();

        interrupt_mask = 8'b00000000;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        interrupt_mask = 8'b00000001;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        interrupt_mask = 8'b00000010;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        interrupt_mask = 8'b00000100;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        interrupt_mask = 8'b00001000;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        interrupt_mask = 8'b00010000;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        interrupt_mask = 8'b00100000;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        interrupt_mask = 8'b01000000;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        interrupt_mask = 8'b10000000;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        #(`TB_CYCLE * 1);
    end
    endtask

    //
    // Task : IN-SERVICE INTERRUPT TEST
    //
    task TASK_IN_SERVICE_INTERRUPT_TEST();
    begin
        interrupt_mask = 8'b00000000;
        #(`TB_CYCLE * 1);

        in_service_register = 8'b00000001;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        in_service_register = 8'b00000010;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        in_service_register = 8'b00000100;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        in_service_register = 8'b00001000;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        in_service_register = 8'b00010000;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        in_service_register = 8'b00100000;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        in_service_register = 8'b01000000;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        in_service_register = 8'b10000000;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        in_service_register = 8'b00000000;
        #(`TB_CYCLE * 1);
    end
    endtask

    //
    // Task : SPECIAL MASK MODE TEST
    //
    task TASK_SPECIAL_MASK_MODE_TEST();
    begin
        interrupt_mask = 8'b00000000;
        #(`TB_CYCLE * 1);

        in_service_register    = 8'b00000011;
        interrupt_special_mask = 8'b00000001;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        in_service_register    = 8'b00000110;
        interrupt_special_mask = 8'b00000010;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        in_service_register    = 8'b00001100;
        interrupt_special_mask = 8'b00000100;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        in_service_register    = 8'b00011000;
        interrupt_special_mask = 8'b00001000;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        in_service_register    = 8'b00110000;
        interrupt_special_mask = 8'b00010000;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        in_service_register    = 8'b01100000;
        interrupt_special_mask = 8'b00100000;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        in_service_register    = 8'b11000000;
        interrupt_special_mask = 8'b01000000;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        in_service_register    = 8'b10000000;
        interrupt_special_mask = 8'b10000000;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        in_service_register    = 8'b00000000;
        interrupt_special_mask = 8'b00000000;
        #(`TB_CYCLE * 1);
    end
    endtask

    //
    // Task : SPECIAL FULLY NEST MODE TEST
    //
    task TASK_SPECIAL_FULLY_NEST_MODE_TEST();
    begin
        special_fully_nest_config = 1'b1;
        #(`TB_CYCLE * 1);

        in_service_register      = 8'b00000001;
        highest_level_in_service = 8'b00000001;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        in_service_register      = 8'b00000010;
        highest_level_in_service = 8'b00000010;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        in_service_register      = 8'b00000100;
        highest_level_in_service = 8'b00000100;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        in_service_register      = 8'b00001000;
        highest_level_in_service = 8'b00001000;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        in_service_register      = 8'b00010000;
        highest_level_in_service = 8'b00010000;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        in_service_register      = 8'b00100000;
        highest_level_in_service = 8'b00100000;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        in_service_register      = 8'b01000000;
        highest_level_in_service = 8'b01000000;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        in_service_register      = 8'b10000000;
        highest_level_in_service = 8'b10000000;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();

        in_service_register      = 8'b00000000;
        highest_level_in_service = 8'b00000000;

        special_fully_nest_config = 1'b0;
        #(`TB_CYCLE * 1);
    end
    endtask

    //
    // Task : ROTATION TEST
    //
    task TASK_ROTATION_TEST();
    begin
        priority_rotate = 3'b000;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();
        interrupt_request_register = 8'b00000001;
        #(`TB_CYCLE * 1);
        interrupt_request_register = 8'b00000000;

        priority_rotate = 3'b001;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();
        interrupt_request_register = 8'b00000010;
        #(`TB_CYCLE * 1);
        interrupt_request_register = 8'b00000011;
        #(`TB_CYCLE * 1);
        interrupt_request_register = 8'b00000000;

        priority_rotate = 3'b010;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();
        interrupt_request_register = 8'b00000100;
        #(`TB_CYCLE * 1);
        interrupt_request_register = 8'b00000110;
        #(`TB_CYCLE * 1);
        interrupt_request_register = 8'b00000111;
        #(`TB_CYCLE * 1);
        interrupt_request_register = 8'b00000000;

        priority_rotate = 3'b011;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();
        interrupt_request_register = 8'b00001000;
        #(`TB_CYCLE * 1);
        interrupt_request_register = 8'b00001100;
        #(`TB_CYCLE * 1);
        interrupt_request_register = 8'b00001110;
        #(`TB_CYCLE * 1);
        interrupt_request_register = 8'b00001111;
        #(`TB_CYCLE * 1);
        interrupt_request_register = 8'b00000000;

        priority_rotate = 3'b100;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();
        interrupt_request_register = 8'b00010000;
        #(`TB_CYCLE * 1);
        interrupt_request_register = 8'b00011000;
        #(`TB_CYCLE * 1);
        interrupt_request_register = 8'b00011100;
        #(`TB_CYCLE * 1);
        interrupt_request_register = 8'b00011110;
        #(`TB_CYCLE * 1);
        interrupt_request_register = 8'b00011111;
        #(`TB_CYCLE * 1);
        interrupt_request_register = 8'b00000000;

        priority_rotate = 3'b101;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();
        interrupt_request_register = 8'b00100000;
        #(`TB_CYCLE * 1);
        interrupt_request_register = 8'b00110000;
        #(`TB_CYCLE * 1);
        interrupt_request_register = 8'b00111000;
        #(`TB_CYCLE * 1);
        interrupt_request_register = 8'b00111100;
        #(`TB_CYCLE * 1);
        interrupt_request_register = 8'b00111110;
        #(`TB_CYCLE * 1);
        interrupt_request_register = 8'b00111111;
        #(`TB_CYCLE * 1);
        interrupt_request_register = 8'b00000000;

        priority_rotate = 3'b110;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();
        interrupt_request_register = 8'b01000000;
        #(`TB_CYCLE * 1);
        interrupt_request_register = 8'b01100000;
        #(`TB_CYCLE * 1);
        interrupt_request_register = 8'b01110000;
        #(`TB_CYCLE * 1);
        interrupt_request_register = 8'b01111000;
        #(`TB_CYCLE * 1);
        interrupt_request_register = 8'b01111100;
        #(`TB_CYCLE * 1);
        interrupt_request_register = 8'b01111110;
        #(`TB_CYCLE * 1);
        interrupt_request_register = 8'b01111111;
        #(`TB_CYCLE * 1);
        interrupt_request_register = 8'b00000000;

        priority_rotate = 3'b111;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT_REQUEST();
        interrupt_request_register = 8'b00000000;
        #(`TB_CYCLE * 1);
    end
    endtask

    //
    // Test pattern
    //
    initial begin
        TASK_INIT();

        TASK_INTERRUPT_MASK_TEST();

        TASK_IN_SERVICE_INTERRUPT_TEST();

        TASK_SPECIAL_MASK_MODE_TEST();

        TASK_SPECIAL_FULLY_NEST_MODE_TEST();

        TASK_ROTATION_TEST();

        #(`TB_CYCLE * 1);
        // End of simulation

        $stop;

    end
endmodule

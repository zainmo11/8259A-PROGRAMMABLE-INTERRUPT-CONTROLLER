
`define TB_CYCLE        20
`define TB_FINISH_COUNT 20000

module KF8259_In_Service_tm();

    // timeunit        1ns;
    // timeprecision   10ps;

    //
    // Generate wave file to check
    //
    
    //
    // Cycle counter
    //
    //
    // Module under test
    //
    //
    reg   [2:0]   priority_rotate;

    reg   [7:0]   interrupt;
    reg           start_in_service;
    reg   [7:0]   end_of_interrupt;

    reg   [7:0]   in_service_register;
    reg   [7:0]   highest_level_in_service;

    In_Service_8259A In_Service_8259A (.*);

    //
    // Task : Initialization
    //
    task TASK_INIT();
    begin
        #(`TB_CYCLE * 0);
        priority_rotate  = 3'b111;
        interrupt        = 8'b00000000;
        start_in_service = 1'b0;
        end_of_interrupt = 8'b00000000;
        #(`TB_CYCLE * 12);
    end
    endtask

    //
    // Task : Interrupt
    //
    task TASK_INTERRUPT(input [7:0] in);
    begin
        #(`TB_CYCLE * 0);
        interrupt        = in;
        start_in_service = 1'b0;
        #(`TB_CYCLE * 1);
        start_in_service = 1'b1;
        #(`TB_CYCLE * 1);
        interrupt        = 8'b00000000;
        start_in_service = 1'b0;
        #(`TB_CYCLE * 1);
    end
    endtask

    //
    // Task : End of interrupt
    //
    task TASK_END_OF_INTERRUPT(input [7:0] in);
    begin
        #(`TB_CYCLE * 0);
        end_of_interrupt = in;
        #(`TB_CYCLE * 1);
        end_of_interrupt = 8'b00000000;
        #(`TB_CYCLE * 1);
    end
    endtask

    //
    // Task : Scan 1nterrupt
    //
    task TASK_SCAN_INTERRUPT();
    begin
        #(`TB_CYCLE * 0);
        TASK_INTERRUPT(8'b10000000);
        TASK_INTERRUPT(8'b01000000);
        TASK_INTERRUPT(8'b00100000);
        TASK_INTERRUPT(8'b00010000);
        TASK_INTERRUPT(8'b00001000);
        TASK_INTERRUPT(8'b00000100);
        TASK_INTERRUPT(8'b00000010);
        TASK_INTERRUPT(8'b00000001);
        #(`TB_CYCLE * 1);
    end
    endtask

    //
    // Task : Scan end of 1nterrupt
    //
    task TASK_SCAN_END_OF_INTERRUPT();
    begin
        #(`TB_CYCLE * 0);
        TASK_END_OF_INTERRUPT(8'b00000001);
        TASK_END_OF_INTERRUPT(8'b00000010);
        TASK_END_OF_INTERRUPT(8'b00000100);
        TASK_END_OF_INTERRUPT(8'b00001000);
        TASK_END_OF_INTERRUPT(8'b00010000);
        TASK_END_OF_INTERRUPT(8'b00100000);
        TASK_END_OF_INTERRUPT(8'b01000000);
        TASK_END_OF_INTERRUPT(8'b10000000);
        #(`TB_CYCLE * 1);
    end
    endtask

    //
    // Test pattern
    //
    initial begin
        TASK_INIT();

        priority_rotate = 3'b111;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT();
        TASK_SCAN_END_OF_INTERRUPT();

        priority_rotate = 3'b110;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT();
        TASK_SCAN_END_OF_INTERRUPT();

        priority_rotate = 3'b101;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT();
        TASK_SCAN_END_OF_INTERRUPT();

        priority_rotate = 3'b100;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT();
        TASK_SCAN_END_OF_INTERRUPT();

        priority_rotate = 3'b011;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT();
        TASK_SCAN_END_OF_INTERRUPT();

        priority_rotate = 3'b010;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT();
        TASK_SCAN_END_OF_INTERRUPT();

        priority_rotate = 3'b001;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT();
        TASK_SCAN_END_OF_INTERRUPT();

        priority_rotate = 3'b000;
        #(`TB_CYCLE * 1);
        TASK_SCAN_INTERRUPT();
        TASK_SCAN_END_OF_INTERRUPT();

        #(`TB_CYCLE * 1);
        // End of simulation
`ifdef IVERILOG
        $finish;
`elsif  MODELSIM
        $stop;
`else
        $finish;
`endif
    end
endmodule


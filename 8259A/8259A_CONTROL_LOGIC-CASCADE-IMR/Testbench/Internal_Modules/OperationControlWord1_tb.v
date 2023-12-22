module OCW1_tb ();
    // inputs
    reg write_initial_command_word_1;
    reg write_operation_control_word_1_registers;
    reg special_mask_mode;
    reg [7:0] internal_data_bus;

    // outputs
    reg [7:0] interrupt_mask;
    reg [7:0] interrupt_special_mask;

    OperationControlWord1 OCW1 (.*);

    task TASK_INIT();
    begin
        write_initial_command_word_1 = 0;
        write_operation_control_word_1_registers = 0;
        special_mask_mode = 0;
        internal_data_bus = 0;

        interrupt_mask = 8'bx;
        interrupt_special_mask = 8'bx;
    end
    endtask

    // Write initial command word 1. Outputs should now be defined.
    task TASK_WRITE_ICW_1();
    begin
        write_initial_command_word_1 = 1;

        #100
        write_initial_command_word_1 = 0;
    end
    endtask

    task TASK_OCW_1_WRITE_IMR();
    begin
        special_mask_mode = 0;
        internal_data_bus = 8'b00001111;
        write_operation_control_word_1_registers = 1;

        #100
        write_operation_control_word_1_registers = 0;
    end
    endtask

    task TASK_OCW_1_WRITE_ISMR();
    begin
        special_mask_mode = 1;
        internal_data_bus = 8'b11110000;
        write_operation_control_word_1_registers = 1;

        #100
        write_operation_control_word_1_registers = 0;
    end
    endtask

    task TASK_OCW_1_WRITE_IMR_AGAIN();
    begin
        special_mask_mode = 0;
        internal_data_bus = 8'b10101010;
        write_operation_control_word_1_registers = 1;

        #100
        write_operation_control_word_1_registers = 0;
    end
    endtask

    initial begin
        TASK_INIT();
        #100
        TASK_WRITE_ICW_1();
        #100
        TASK_OCW_1_WRITE_IMR();
        #100
        TASK_OCW_1_WRITE_ISMR();
        #100
        TASK_OCW_1_WRITE_IMR_AGAIN();
    end
    

endmodule
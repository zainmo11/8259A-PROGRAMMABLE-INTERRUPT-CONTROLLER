module OCW3_tb ();
    // inputs
    reg write_initial_command_word_1;
    reg write_operation_control_word_3_registers;
    reg [7:0] internal_data_bus;

    // outputs
    reg special_mask_mode;
    reg enable_read_register;
    reg read_register_isr_or_irr;

    OperationControlWord3 OCW3 (.*);

    task TASK_INIT();
    begin
        write_initial_command_word_1 = 0;
        write_operation_control_word_3_registers = 0;
        internal_data_bus = 0;

        special_mask_mode = 1'bx;
        enable_read_register = 1'bx;
        read_register_isr_or_irr = 1'bx;
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

    task TASK_OCW_3_READ_IRR();
    begin
        internal_data_bus = 8'b00000010;
        write_operation_control_word_3_registers = 1;

        #100
        write_operation_control_word_3_registers = 0;
    end
    endtask

    task TASK_OCW_3_READ_ISR();
    begin
        internal_data_bus = 8'b00000011;
        write_operation_control_word_3_registers = 1;

        #100
        write_operation_control_word_3_registers = 0;
    end
    endtask

    task TASK_OCW_3_SET_SMM();
    begin
        internal_data_bus = 8'b01100000;
        write_operation_control_word_3_registers = 1;

        #100
        write_operation_control_word_3_registers = 0;
    end
    endtask

    task TASK_OCW_3_RESET_SMM();
    begin
        internal_data_bus = 8'b01000000;
        write_operation_control_word_3_registers = 1;

        #100
        write_operation_control_word_3_registers = 0;
    end
    endtask

    initial begin
        TASK_INIT();
        #100
        TASK_WRITE_ICW_1();
        #100
        TASK_OCW_3_READ_IRR();
        #100
        TASK_OCW_3_READ_ISR();
        #100
        TASK_OCW_3_SET_SMM();
        #100
        TASK_OCW_3_RESET_SMM();
    end
    

endmodule
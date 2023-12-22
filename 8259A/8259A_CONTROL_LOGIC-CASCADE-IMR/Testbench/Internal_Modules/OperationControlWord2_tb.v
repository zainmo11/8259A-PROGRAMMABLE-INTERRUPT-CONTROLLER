module OCW2_tb ();
    // inputs
    reg write_initial_command_word_1; // Input signal to write the initial command word 1.
    reg auto_eoi_config; // Input signal for auto EOI configuration.
    reg end_of_acknowledge_sequence; // Input signal indicating the end of the acknowledge sequence.
    reg [7:0] acknowledge_interrupt; // Input signal representing the interrupt being acknowledged.
    reg write_operation_control_word_2; // Input signal to write the operation control word 2.
    reg [7:0] internal_data_bus; // Input bus for internal data.
    reg [7:0] highest_level_in_service; // Input signal representing the highest level in service.
    reg [2:0] num2bit; // Input signal representing the number to bit conversion.
    reg [7:0] bit2num; // Input signal representing the bit to number conversion.
    
    // outputs
    reg [7:0] end_of_interrupt; // Output signal representing the end of interrupt.
    reg auto_rotate_mode; // Output signal indicating the auto rotate mode.
    reg [2:0] priority_rotate; // Output signal representing the priority rotate value.


    OperationControlWord2 OCW2 (.*);

    task TASK_INIT();
    begin
        write_initial_command_word_1 = 0;
        auto_eoi_config = 0;
        end_of_acknowledge_sequence = 0;
        acknowledge_interrupt = 0;
        write_operation_control_word_2 = 0;
        internal_data_bus = 0;
        highest_level_in_service = 0;
        num2bit = 0;
        bit2num = 0;

        end_of_interrupt = 8'bx;
        auto_rotate_mode = 1'bx;
        priority_rotate = 3'bx;
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

    task TASK_OCW_2_WRITE_NONSPECIFIC_EOI();
    begin
        auto_eoi_config = 0;
        internal_data_bus = 8'b00100000;
        highest_level_in_service = 8'b00001000;
        write_operation_control_word_2 = 1;

        #100
        write_operation_control_word_2 = 0;
    end
    endtask

    task TASK_OCW_2_WRITE_SPECIFIC_EOI();
    begin
        auto_eoi_config = 0;
        internal_data_bus = 8'b01100000;
        num2bit = 3'b110;
        write_operation_control_word_2 = 1;

        #100
        write_operation_control_word_2 = 0;
    end
    endtask

    task TASK_OCW_2_WRITE_AEOI();
    begin
        auto_eoi_config = 1;
        end_of_acknowledge_sequence = 1;
        acknowledge_interrupt = 8'b00000001;
        write_operation_control_word_2 = 1;

        #100
        write_operation_control_word_2 = 0;
    end
    endtask

    task TASK_OCW_2_WRITE_ROTATE_ON_NONSPECIFIC_EOI();
    begin
        auto_eoi_config = 0;
        internal_data_bus = 8'b10100000;
        highest_level_in_service = 8'b00010000;
        bit2num = 8'b00000010;
        write_operation_control_word_2 = 1;

        #100
        write_operation_control_word_2 = 0;
    end
    endtask

    task TASK_OCW_2_WRITE_ROTATE_ON_SPECIFIC_EOI();
    begin
        auto_eoi_config = 0;
        internal_data_bus = 8'b11100011;
        write_operation_control_word_2 = 1;

        #100
        write_operation_control_word_2 = 0;
    end
    endtask

    initial begin
        TASK_INIT();
        #100
        TASK_WRITE_ICW_1();
        #100
        TASK_OCW_2_WRITE_NONSPECIFIC_EOI();
        #100
        TASK_OCW_2_WRITE_SPECIFIC_EOI();
        #100
        TASK_OCW_2_WRITE_AEOI();
        #100
        TASK_OCW_2_WRITE_ROTATE_ON_NONSPECIFIC_EOI();
        #100
        TASK_OCW_2_WRITE_ROTATE_ON_SPECIFIC_EOI();
    end
    

endmodule
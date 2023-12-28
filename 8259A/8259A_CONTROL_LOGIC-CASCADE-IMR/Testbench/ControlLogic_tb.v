module Control_Logic_8259A_tb();

    // External input/output
    wire [2:0] cascade_inout;
    wire slave_program_or_enable_buffer;

    reg interrupt_acknowledge_n;
    reg [7:0] internal_data_bus;
    reg write_initial_command_word_1;
    reg write_initial_command_word_2_4;
    reg write_operation_control_word_1;
    reg write_operation_control_word_2;
    reg write_operation_control_word_3;
    reg read;
    reg write;
    reg [7:0] interrupt;
    reg [7:0] highest_level_in_service;

    reg out_control_logic_data;
    reg [7:0] control_logic_data;
    reg interrupt_to_cpu;
    reg level_or_edge_toriggered_config;
    reg special_fully_nest_config;
    reg enable_read_register;
    reg read_register_isr_or_irr;
    reg [7:0] interrupt_mask;
    reg [7:0] interrupt_special_mask;
    reg [7:0] end_of_interrupt;
    reg [2:0] priority_rotate;
    reg freeze;
    reg latch_in_service;
    reg [7:0] clear_interrupt_request;

    Control_Logic_8259 Control_Logic (.*);

    //
    // Task : Initialization
    //
    task TASK_INIT();
    begin
        interrupt_acknowledge_n = 1;
        internal_data_bus = 8'b00000000;
        write_initial_command_word_1 = 0;
        write_initial_command_word_2_4 = 0;
        write_operation_control_word_1 = 0;
        write_operation_control_word_2 = 0;
        write_operation_control_word_3 = 0;
        read = 0;
        write = 0;
        interrupt = 8'b00000000;
        highest_level_in_service = 8'b00000000;
    end
    endtask

    task TASK_WRITE_SINGLE_MCS80_PRIORITY_ROTATE();
    begin
        // Assume interrupt vector address is all ones

        // ICW
        write_initial_command_word_1 = 1;
        internal_data_bus = 8'b11110111; // icw4 needed, Single mode, 4 config, edge triggered, A7-A5 of IVA
        write = 1;
        #100

        write = 0;
        write_initial_command_word_1 = 0;
        #100

        write = 1;
        write_initial_command_word_1 = 0;
        write_initial_command_word_2_4 = 1;
        internal_data_bus = 8'b11111111; // A15-A8 of IVA
        #100

        write = 0;
        write_initial_command_word_2_4 = 0;
        #100

        write = 1;
        write_initial_command_word_2_4 = 1;
        internal_data_bus = 8'b00000000; // MCS-80, EOI, non buffered, not SFNM
        #100

        // OCW
        write = 0;
        write_initial_command_word_2_4 = 0;
        write_operation_control_word_1 = 1;
        internal_data_bus = 8'b00000000; // reset mask
        #100

        write_operation_control_word_1 = 0;
        write_operation_control_word_2 = 1;
        internal_data_bus = 8'b10100000; // rotate on non-specific eoi, L0-L2 not used
        #100

        write_operation_control_word_2 = 0;
        write_operation_control_word_3 = 1;
        internal_data_bus = 8'b00000000; // no read command, no poll, no special mask
        #100
        
        write_operation_control_word_3 = 0;
        internal_data_bus = 8'bzzzzzzzz; // reset
        #100

        // Interrupt
        interrupt = 8'b00000010;
        #100

        interrupt_acknowledge_n = 0;
        #100
        interrupt_acknowledge_n = 1;
        #100
        interrupt_acknowledge_n = 0;
        #100
        interrupt_acknowledge_n = 1;
        #100
        interrupt_acknowledge_n = 0;
        #100
        interrupt_acknowledge_n = 1;
    end 
    endtask

    task TASK_WRITE_SINGLE_MCS80_FULLY_NESTED();
    begin
        // Assume interrupt vector address is all ones

        // ICW
        write_initial_command_word_1 = 1;
        internal_data_bus = 8'b11110111; // icw4 needed, Single mode, 4 config, edge triggered, A7-A5 of IVA
        write = 1;
        #100

        write = 0;
        write_initial_command_word_1 = 0;
        #100

        write = 1;
        write_initial_command_word_1 = 0;
        write_initial_command_word_2_4 = 1;
        internal_data_bus = 8'b11111111; // A15-A8 of IVA
        #100

        write = 0;
        write_initial_command_word_2_4 = 0;
        #100

        write = 1;
        write_initial_command_word_2_4 = 1;
        internal_data_bus = 8'b00000000; // MCS-80, EOI, non buffered, not SFNM
        #100

        // OCW
        write = 0;
        write_initial_command_word_2_4 = 0;
        write_operation_control_word_1 = 1;
        internal_data_bus = 8'b00000000; // reset mask
        #100

        write_operation_control_word_1 = 0;
        write_operation_control_word_2 = 1;
        internal_data_bus = 8'b00100000; // non-specific eoi, L0-L2 not used
        #100

        write_operation_control_word_2 = 0;
        write_operation_control_word_3 = 1;
        internal_data_bus = 8'b00000000; // no read command, no poll, no special mask
        #100
        
        write_operation_control_word_3 = 0;
        internal_data_bus = 8'bzzzzzzzz; // reset
        #100

        // Interrupt
        interrupt = 8'b00000001;
        #100

        interrupt_acknowledge_n = 0;
        #100
        interrupt_acknowledge_n = 1;
        #100
        interrupt_acknowledge_n = 0;
        #100
        interrupt_acknowledge_n = 1;
        #100
        interrupt_acknowledge_n = 0;
        #100
        interrupt_acknowledge_n = 1;
    end 
    endtask

    task TASK_WRITE_CASCADE_MCS80_FULLY_NESTED();
    begin
        // Assume interrupt vector address is all ones

        // ICW
        write_initial_command_word_1 = 1;
        internal_data_bus = 8'b11110101; // icw4 needed, cascade mode, 4 config, edge triggered, A7-A5 of IVA
        write = 1;
        #100

        write = 0;
        write_initial_command_word_1 = 0;
        #100

        write = 1;
        write_initial_command_word_1 = 0;
        write_initial_command_word_2_4 = 1;
        internal_data_bus = 8'b11111111; // A15-A8 of IVA
        #100

        write = 0;
        write_initial_command_word_2_4 = 0;
        #100

        write = 1;
        write_initial_command_word_2_4 = 1;
        internal_data_bus = 8'b11111111; // Has slaves
        #100
       
        write = 0;
        write_initial_command_word_2_4 = 0;
        #100

        write = 1;
        write_initial_command_word_2_4 = 1;
        internal_data_bus = 8'b00000000; // MCS-80, EOI, non buffered, not SFNM
        #100

        // OCW
        write = 0;
        write_initial_command_word_2_4 = 0;
        write_operation_control_word_1 = 1;
        internal_data_bus = 8'b00000000; // reset mask
        #100

        write_operation_control_word_1 = 0;
        write_operation_control_word_2 = 1;
        internal_data_bus = 8'b00100000; // non-specific eoi, L0-L2 not used
        #100

        write_operation_control_word_2 = 0;
        write_operation_control_word_3 = 1;
        internal_data_bus = 8'b00000000; // no read command, no poll, no special mask
        #100
        
        write_operation_control_word_3 = 0;
        internal_data_bus = 8'bzzzzzzzz; // reset
        #100

        // Interrupt
        interrupt = 8'b00000001;
        #100

        interrupt_acknowledge_n = 0;
        #100
        interrupt_acknowledge_n = 1;
        #100
        interrupt_acknowledge_n = 0;
        #100
        interrupt_acknowledge_n = 1;
        #100
        interrupt_acknowledge_n = 0;
        #100
        interrupt_acknowledge_n = 1;
    end 
    endtask










    task TASK_WRITE_SINGLE_8086_PRIORITY_ROTATE();
    begin
        // Assume interrupt vector address is all ones

        // ICW
        write_initial_command_word_1 = 1;
        internal_data_bus = 8'b11110111; // icw4 needed, Single mode, 4 config, edge triggered, A7-A5 of IVA
        write = 1;
        #100

        write = 0;
        write_initial_command_word_1 = 0;
        #100

        write = 1;
        write_initial_command_word_1 = 0;
        write_initial_command_word_2_4 = 1;
        internal_data_bus = 8'b11111111; // A15-A8 of IVA
        #100

        write = 0;
        write_initial_command_word_2_4 = 0;
        #100

        write = 1;
        write_initial_command_word_2_4 = 1;
        internal_data_bus = 8'b00000001; // 8086, EOI, non buffered, not SFNM
        #100

        // OCW
        write = 0;
        write_initial_command_word_2_4 = 0;
        write_operation_control_word_1 = 1;
        internal_data_bus = 8'b00000000; // reset mask
        #100

        write_operation_control_word_1 = 0;
        write_operation_control_word_2 = 1;
        internal_data_bus = 8'b10100000; // rotate on non-specific eoi, L0-L2 not used
        #100

        write_operation_control_word_2 = 0;
        write_operation_control_word_3 = 1;
        internal_data_bus = 8'b00001000; // no read command, no poll, no special mask
        #100
        
        write_operation_control_word_3 = 0;
        internal_data_bus = 8'bzzzzzzzz; // reset
        #100

        // Interrupt
        interrupt = 8'b00000010;
        #100

        interrupt_acknowledge_n = 0;
        #100
        interrupt_acknowledge_n = 1;
        #100
        interrupt_acknowledge_n = 0;
        #100
        interrupt_acknowledge_n = 1;
        #100
        interrupt_acknowledge_n = 0;
        #100
        interrupt_acknowledge_n = 1;
    end 
    endtask


    task TASK_WRITE_SINGLE_8086_FULLY_NESTED();
    begin
        // Assume interrupt vector address is all ones

        // ICW
        write_initial_command_word_1 = 1;
        internal_data_bus = 8'b00010111; // icw4 needed, Single mode, 4 config, edge triggered, last 3 bits unused in 8086
        write = 1;
        #100

        write = 0;
        write_initial_command_word_1 = 0;
        #100

        write = 1;
        write_initial_command_word_1 = 0;
        write_initial_command_word_2_4 = 1;
        internal_data_bus = 8'b11111000; // first 3 bits unused in 8086, T7-T3 of IVA
        #100

        write = 0;
        write_initial_command_word_2_4 = 0;
        #100

        write = 1;
        write_initial_command_word_2_4 = 1;
        internal_data_bus = 8'b00000001; // 8086, EOI, non buffered, not SFNM
        #100

        // OCW
        write = 0;
        write_initial_command_word_2_4 = 0;
        write_operation_control_word_1 = 1;
        internal_data_bus = 8'b00000000; // reset mask
        #100

        write_operation_control_word_1 = 0;
        write_operation_control_word_2 = 1;
        internal_data_bus = 8'b00100000; // non-specific eoi, L0-L2 not used
        #100

        write_operation_control_word_2 = 0;
        write_operation_control_word_3 = 1;
        internal_data_bus = 8'b00001000; // no read command, no poll, no special mask
        #100
        
        write_operation_control_word_3 = 0;
        internal_data_bus = 8'bzzzzzzzz; // reset
        #100

        // Interrupt
        interrupt = 8'b00000001;
        #100

        interrupt_acknowledge_n = 0;
        #100
        interrupt_acknowledge_n = 1;
        #100
        interrupt_acknowledge_n = 0;
        #100
        interrupt_acknowledge_n = 1;

    end 
    endtask



    initial begin
        TASK_INIT();
        #100
        TASK_WRITE_SINGLE_MCS80_PRIORITY_ROTATE();
        #100
        TASK_WRITE_SINGLE_MCS80_FULLY_NESTED();
        #100
        TASK_WRITE_SINGLE_MCS80_FULLY_NESTED();
        #100
        TASK_WRITE_SINGLE_8086_PRIORITY_ROTATE();
        #100
        TASK_WRITE_SINGLE_8086_FULLY_NESTED();
    end
endmodule


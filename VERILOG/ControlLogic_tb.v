
`define TB_CYCLE        20
`define TB_FINISH_COUNT 20000

module Control_Logic_8259A_tm();

    `timescale 1ns/10ps

    //
    // Module under test
    //
    //
        // External input/output
    wire   [2:0]   cascade_inout;

    reg           slave_program_n;
    reg           slave_program_or_enable_buffer;

    reg           interrupt_acknowledge_n;
    reg           interrupt_to_cpu;

    // Internal bus
    reg   [7:0]   internal_data_bus;
    reg           write_initial_command_word_1;
    reg           write_initial_command_word_2_4;
    reg           write_operation_control_word_1;
    reg           write_operation_control_word_2;
    reg           write_operation_control_word_3;

    reg           read;
    reg           out_control_logic_data;
    reg   [7:0]   control_logic_data;

    // Registers to interrupt detecting logics
    reg           level_or_edge_toriggered_config;
    reg           special_fully_nest_config;

    // Registers to Read logics
    reg           enable_read_register;
    reg           read_register_isr_or_irr;

    // Signals from interrupt detectiong logics
    reg   [7:0]   interrupt;
    reg   [7:0]   highest_level_in_service;

    // Interrupt control signals
    reg   [7:0]   interrupt_mask;
    reg   [7:0]   interrupt_special_mask;
    reg   [7:0]   end_of_interrupt;
    reg   [2:0]   priority_rotate;
    reg           freeze;
    reg           latch_in_service;
    reg   [7:0]   clear_interrupt_request;

    KF8259_Control_Logic u_KF8259_Control_Logic (.*);

    //
    // Task : Initialization
    //
    task TASK_INIT();
    begin
        #(`TB_CYCLE * 0);
        slave_program_n = 1'b0;
        interrupt_acknowledge_n = 1'b0;
        internal_data_bus = 8'b00000000;
        write_initial_command_word_1 = 1'b0;
        write_initial_command_word_2_4 = 1'b0;
        write_operation_control_word_1 = 1'b0;
        write_operation_control_word_2 = 1'b0;
        write_operation_control_word_3 = 1'b0;
        read = 1'b0;
        interrupt = 8'b00000000;
        highest_level_in_service = 8'b00000000;
        #(`TB_CYCLE * 12);
    end
    endtask

    // General task for input variations
    task TASK_WRITE_DATA(
        input slave_program_n_in, 
        input interrupt_acknowledge_n_in,
        input [7:0] internal_data_bus_in,
        input write_initial_command_word_1_in,
        input write_initial_command_word_2_4_in,
        input write_operation_control_word_1_in,
        input write_operation_control_word_2_in,
        input write_operation_control_word_3_in,
        input read_in,
        input [7:0] interrupt_in,
        input [7:0] highest_level_in_service_in
        );
    begin
        #(`TB_CYCLE * 0);
        slave_program_n = slave_program_n_in;
        interrupt_acknowledge_n = interrupt_acknowledge_n_in;
        internal_data_bus = internal_data_bus_in;
        write_initial_command_word_1 = write_initial_command_word_1_in;
        write_initial_command_word_2_4 = write_initial_command_word_2_4_in;
        write_operation_control_word_1 = write_operation_control_word_1_in;
        write_operation_control_word_2 = write_operation_control_word_2_in;
        write_operation_control_word_3 = write_operation_control_word_3_in;
        read = read_in;
        interrupt = interrupt_in;
        highest_level_in_service = highest_level_in_service_in;
        #(`TB_CYCLE * 12);
    end
    endtask

    //
    // Task : Write data
    //
    // task TASK_WRITE_DATA(input [1:0] addr, input [7:0] data);
    // begin
    //     #(`TB_CYCLE * 0);
    //     chip_select_n   = 1'b0;
    //     write_enable_n  = 1'b0;
    //     address         = addr;
    //     data_bus_in     = data;
    //     #(`TB_CYCLE * 1);
    //     write_enable_n  = 1'b1;
    //     chip_select_n   = 1'b1;
    //     #(`TB_CYCLE * 1);
    // end
    // endtask


    //
    // Test pattern
    //
    initial begin
        TASK_INIT();
        #(`TB_CYCLE * 3);
        TASK_WRITE_DATA(
            1'b1, 
            1'b1, 
            1'b11111111, 
            1'b1, 
            1'b1, 
            1'b1, 
            1'b1, 
            1'b1, 
            1'b1, 
            1'b11111111, 
            1'b11111111
            );

        // TASK_WRITE_DATA(1'b0, 8'b00010000);
        // TASK_WRITE_DATA(1'b1, 8'b00000000);
        // TASK_WRITE_DATA(1'b0, 8'b00000000);
        // TASK_WRITE_DATA(1'b0, 8'b00001000);
        // #(`TB_CYCLE * 1);
        // read_enable_n   = 1'b0;
        // chip_select_n   = 1'b0;
        // #(`TB_CYCLE * 1);
        // read_enable_n   = 1'b1;
        // chip_select_n   = 1'b1;
        // #(`TB_CYCLE * 1);
        // read_enable_n   = 1'b0;
        // chip_select_n   = 1'b0;
        // #(`TB_CYCLE * 1);
        // read_enable_n   = 1'b1;
        // #(`TB_CYCLE * 1);
        // chip_select_n   = 1'b1;
        // #(`TB_CYCLE * 1);

        // End of simulation

        $stop;
    end
endmodule


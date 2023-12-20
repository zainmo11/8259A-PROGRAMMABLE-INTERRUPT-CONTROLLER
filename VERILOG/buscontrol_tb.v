
`define TB_CYCLE        20
`define TB_FINISH_COUNT 20000

module Bus_Control_Logic_8259A_tm();

    `timescale 1ns/10ps
    // timeunit        1ns;
    // timeprecision   10ps;


    //
    // Module under test
    //
    //
    reg           chip_select_n;
    reg           read_enable_n;
    reg           write_enable_n;
    reg           address;
    reg   [7:0]   data_bus_in;

    reg   [7:0]   internal_data_bus;
    reg           write_initial_command_word_1;
    reg           write_initial_command_word_2_4;
    reg           write_operation_control_word_1;
    reg           write_operation_control_word_2;
    reg           write_operation_control_word_3;
    reg           read;
    reg           write_out;

    Data_Bus_Control_8259 u_Data_Bus_Control_8259 (.*);

    //
    // Task : Initialization
    //
    task TASK_INIT();
    begin
        #(`TB_CYCLE * 0);
        chip_select_n   = 1'b1;
        read_enable_n   = 1'b1;
        write_enable_n  = 1'b1;
        address         = 1'b0;
        data_bus_in     = 8'b00000000;
        #(`TB_CYCLE * 12);
    end
    endtask

    //
    // Task : Write data
    //
    task TASK_WRITE_DATA(input [1:0] addr, input [7:0] data);
    begin
        #(`TB_CYCLE * 0);
        chip_select_n   = 1'b0;
        write_enable_n  = 1'b0;
        address         = addr;
        data_bus_in     = data;
        #(`TB_CYCLE * 1);
        write_enable_n  = 1'b1;
        chip_select_n   = 1'b1;
        #(`TB_CYCLE * 1);
    end
    endtask


    //
    // Test pattern
    //
    initial begin
        TASK_INIT();

        TASK_WRITE_DATA(1'b0, 8'b00010000);
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        TASK_WRITE_DATA(1'b0, 8'b00000000);
        TASK_WRITE_DATA(1'b0, 8'b00001000);
        #(`TB_CYCLE * 1);
        read_enable_n   = 1'b0;
        chip_select_n   = 1'b0;
        #(`TB_CYCLE * 1);
        read_enable_n   = 1'b1;
        chip_select_n   = 1'b1;
        #(`TB_CYCLE * 1);
        read_enable_n   = 1'b0;
        chip_select_n   = 1'b0;
        #(`TB_CYCLE * 1);
        read_enable_n   = 1'b1;
        #(`TB_CYCLE * 1);
        chip_select_n   = 1'b1;
        #(`TB_CYCLE * 1);

        // End of simulation

        $stop;
    end
endmodule


module ICW4_tb ();
    // inputs
    reg write_initial_command_word_1;
    reg write_initial_command_word_4;
    reg [4:0] internal_data_bus;

    // outputs
    reg special_fully_nest_config; 
    reg buffered_mode_config; 
    reg slave_program;
    reg buffered_master_or_slave_config;
    reg auto_eoi_config;
    reg u8086_or_mcs80_config;

    InitializationCommandWord4 ICW4 (.*);

    task TASK_INIT();
    begin
        write_initial_command_word_1 = 0;
        write_initial_command_word_4 = 0;
        internal_data_bus = 4'b0000;

        special_fully_nest_config = 0; 
        buffered_mode_config = 0; 
        slave_program = 0;
        buffered_master_or_slave_config = 0;
        auto_eoi_config = 0;
        u8086_or_mcs80_config = 0;
    end
    endtask

    task TASK_WRITE_ICW4(input write1, input write4, input [4:0] data);
    begin
        write_initial_command_word_1 = write1;
        write_initial_command_word_4 = write4;
        internal_data_bus = data;
    end
    endtask

    initial begin
        TASK_INIT();
        #100
        // ICW1 not asserted, outputs change
        TASK_WRITE_ICW4(1'b0, 1'b1, 8'b00000000);
        #100
        TASK_WRITE_ICW4(1'b0, 1'b1, 8'b10101010);
        #100
        TASK_WRITE_ICW4(1'b0, 1'b1, 8'b11111111);
        #100
        // ICW1 asserted, outputs are reset to 0
        TASK_WRITE_ICW4(1'b1, 1'b0, 8'b00000000);
        #100
        TASK_WRITE_ICW4(1'b1, 1'b0, 8'b10101010);
        #100
        TASK_WRITE_ICW4(1'b1, 1'b0, 8'b11111111);
        #100
        // Outputs don't change if both ICW1 & ICW4 are asserted
        TASK_WRITE_ICW4(1'b1, 1'b1, 8'b11111111);
        #100
        // Outputs don't change if neither ICW1 & ICW4 are asserted
        TASK_WRITE_ICW4(1'b0, 1'b0, 8'b11111111);
    end
    

endmodule
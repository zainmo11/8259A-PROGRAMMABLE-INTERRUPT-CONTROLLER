module ICWM1_tb ();
    // inputs
    reg write_initial_command_word_1;
    reg [7:0] internal_data_bus;

    // outputs
    reg [2:0] interrupt_vector_address;
    reg level_or_edge_triggered_config;
    reg call_address_interval_4_or_8_config;
    reg single_or_cascade_config;
    reg set_icw4_config;

    InitializationCommandWordModule1 ICWM1 (.*);

    task TASK_INIT();
    begin
        write_initial_command_word_1 = 0;
        internal_data_bus = 8'b00000000;

        interrupt_vector_address = 3'b000;
        level_or_edge_triggered_config = 0;
        call_address_interval_4_or_8_config = 0;
        single_or_cascade_config = 0;
        set_icw4_config = 0;
    end
    endtask

    task TASK_WRITE_ICWM_1(input write, input [7:0] data);
    begin
        write_initial_command_word_1 = write;
        internal_data_bus = data;
    end
    endtask

    initial begin
        TASK_INIT();
        #100
        TASK_WRITE_ICWM_1(1'b1, 8'b00000000);
        #100
        TASK_WRITE_ICWM_1(1'b1, 8'b10101010);
        #100
        TASK_WRITE_ICWM_1(1'b1, 8'b11111111);
        #100
        TASK_WRITE_ICWM_1(1'b0, 8'b00000000);
        #100
        TASK_WRITE_ICWM_1(1'b0, 8'b10101010);
        #100
        TASK_WRITE_ICWM_1(1'b0, 8'b11111111);
    end
    

endmodule
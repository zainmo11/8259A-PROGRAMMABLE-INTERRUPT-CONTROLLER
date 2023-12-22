module CascadeSignals_tb ();
    // Inputs
    reg single_or_cascade_config;
    reg buffered_mode_config;
    reg slave_program;
    reg buffered_master_or_slave_config;
    reg [2:0] cascade_device_config;
    reg [2:0] cascade_id;
    reg acknowledge_interrupt;
    reg control_state;
    
    // Outputs
    reg cascade_slave;
    reg cascade_io;
    reg cascade_slave_enable;
    reg interrupt_from_slave_device;
    reg cascade_output_ack_2_3;
    reg [2:0] cascade_out;

    CascadeSignals CS (.*);

    task TASK_INIT();
    begin
        single_or_cascade_config = 0;
        buffered_mode_config = 0;
        slave_program = 0;
        buffered_master_or_slave_config = 0;
        cascade_device_config = 2'b00;
        cascade_id = 2'b00;
        acknowledge_interrupt = 0;
        control_state = 0;
        
        // Outputs
        cascade_slave = 0;
        cascade_io = 0;
        cascade_slave_enable = 0;
        interrupt_from_slave_device = 0;
        cascade_output_ack_2_3 = 0;
        cascade_out = 2'b00;
    end
    endtask

    task TASK_WRITE_CS_CASCADE();
    begin
        single_or_cascade_config = 0;
        buffered_mode_config = 0;
        slave_program = 1;
        buffered_master_or_slave_config = 0;
        cascade_device_config = 2'b00;
        cascade_id = 2'b00;
        acknowledge_interrupt = 0;
        control_state = 0;
    end
    endtask

    task TASK_WRITE_CS_SLAVE();
    begin
        single_or_cascade_config = 0;
        buffered_mode_config = 0;
        slave_program = 0;
        buffered_master_or_slave_config = 0;
        cascade_device_config = 2'b00;
        acknowledge_interrupt = 0;
        control_state = 0;
    end
    endtask

    task TASK_WRITE_CS_BUFFER();
    begin
        single_or_cascade_config = 0;
        buffered_mode_config = 1;
        slave_program = 0;
        buffered_master_or_slave_config = 1;
        cascade_device_config = 2'b00;
        acknowledge_interrupt = 0;
        control_state = 0;
    end
    endtask

    initial begin
        TASK_INIT();
        #100
        TASK_WRITE_CS_CASCADE();
        #100
        TASK_WRITE_CS_SLAVE();
        #100
        TASK_WRITE_CS_BUFFER();
    end
    

endmodule
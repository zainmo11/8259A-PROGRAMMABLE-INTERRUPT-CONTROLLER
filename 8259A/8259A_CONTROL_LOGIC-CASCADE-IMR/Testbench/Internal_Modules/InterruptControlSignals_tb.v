module InterruptControlSignals_tb ();
    // Inputs
    reg write_initial_command_word_1;
    reg [7:0] interrupt;
    reg end_of_acknowledge_sequence;
    reg end_of_poll_command;
    reg next_control_state;
    reg latch_in_service;
    reg control_state;
    
    // Outputs
    reg interrupt_to_cpu;
    reg freeze;
    reg [7:0] clear_interrupt_request;
    reg [7:0] acknowledge_interrupt;
    reg [7:0] interrupt_when_ack1;

    InterruptControlSignals ICS (.*);

    task TASK_INIT();
    begin
        write_initial_command_word_1 = 0;
        interrupt = 8'b00000000;
        end_of_acknowledge_sequence = 0;
        end_of_poll_command = 0;
        next_control_state = 0;
        latch_in_service = 0;
        control_state = 0;
        
        interrupt_to_cpu = 0;
        freeze = 0;
        clear_interrupt_request = 8'b00000000;
        acknowledge_interrupt = 8'b00000000;
        interrupt_when_ack1 = 8'b00000000;
    end
    endtask

    // Interrupt handling
    task TASK_WRITE_ICS_INT();
    begin
        write_initial_command_word_1 = 0;
        interrupt = 8'b00000010;
        end_of_acknowledge_sequence = 0;
        end_of_poll_command = 0;
        next_control_state = 0;
        latch_in_service = 1;
        control_state = 0;
    end
    endtask

    // Initial command word handling
    task TASK_WRITE_ICS_ICW();
    begin
        write_initial_command_word_1 = 1;
        interrupt = 8'b11111111;
        end_of_acknowledge_sequence = 0;
        end_of_poll_command = 0;
        next_control_state = 1;
        latch_in_service = 0;
        control_state = 0;
    end
    endtask

    // Ack handling
    task TASK_WRITE_ICS_ACK();
    begin
        write_initial_command_word_1 = 0;
        interrupt = 8'b10000000;
        end_of_acknowledge_sequence = 1;
        end_of_poll_command = 0;
        next_control_state = 0;
        latch_in_service = 1;
        control_state = 1;
    end
    endtask

    initial begin
        TASK_INIT();
        #100
        TASK_WRITE_ICS_INT();
        #100
        TASK_WRITE_ICS_ICW();
        #100
        TASK_WRITE_ICS_ACK();
        
    end
    

endmodule
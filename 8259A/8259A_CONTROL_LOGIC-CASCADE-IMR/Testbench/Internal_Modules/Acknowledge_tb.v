module Acknowledge_tb ();
    // Inputs
    reg interrupt_acknowledge_n;
    reg cascade_slave;
    reg u8086_or_mcs80_config;
    reg [2:0] control_state;
    reg cascade_output_ack_2_3;
    reg [2:0] interrupt_when_ack1;
    reg [2:0] acknowledge_interrupt;
    reg call_address_interval_4_or_8_config;
    reg [10:0] interrupt_vector_address;
    reg read;

    // Outputs
    reg out_control_logic_data;
    reg [7:0] control_logic_data;

    AcknowledgeModule Acknowledge (.*);

    task TASK_INIT();
    begin
        interrupt_acknowledge_n = 0;
        cascade_slave = 0;
        u8086_or_mcs80_config = 0;
        control_state = 2'b00;
        cascade_output_ack_2_3 = 0;
        interrupt_when_ack1 = 2'b00;
        acknowledge_interrupt = 2'b00;
        call_address_interval_4_or_8_config = 0;
        interrupt_vector_address = 10'b0000000000;
        read = 0;
    end
    endtask

    task TASK_WRITE_ACK1();
    begin
        interrupt_acknowledge_n = 0;
        cascade_slave = 1;
        u8086_or_mcs80_config = 1;
        control_state = 2'b10;
        cascade_output_ack_2_3 = 1;
        interrupt_when_ack1 = 2'b10;
        acknowledge_interrupt = 2'b00;
        call_address_interval_4_or_8_config = 0;
        interrupt_vector_address = 10'b0000000000;
        read = 0;
    end
    endtask

    task TASK_WRITE_ACK2();
    begin
        interrupt_acknowledge_n = 1;
        cascade_slave = 0;
        u8086_or_mcs80_config = 0;
        control_state = 2'b00;
        cascade_output_ack_2_3 = 0;
        interrupt_when_ack1 = 2'b00;
        acknowledge_interrupt = 2'b11;
        call_address_interval_4_or_8_config = 1;
        interrupt_vector_address = 10'b0000000010;
        read = 1;
    end
    endtask

    task TASK_WRITE_ACK3();
    begin
        interrupt_acknowledge_n = 0;
        cascade_slave = 1;
        u8086_or_mcs80_config = 1;
        control_state = 2'b01;
        cascade_output_ack_2_3 = 0;
        interrupt_when_ack1 = 2'b00;
        acknowledge_interrupt = 2'b00;
        call_address_interval_4_or_8_config = 1;
        interrupt_vector_address = 10'b0000000000;
        read = 0;
    end
    endtask

    initial begin
        TASK_INIT();
        #100
        TASK_WRITE_ACK1();
        #100
        TASK_WRITE_ACK2();
        #100
        TASK_WRITE_ACK3();
    end
    

endmodule
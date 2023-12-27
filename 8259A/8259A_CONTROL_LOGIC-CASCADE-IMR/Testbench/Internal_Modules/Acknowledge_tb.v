module Acknowledge_tb ();
    // Inputs
    reg interrupt_acknowledge_n;
    reg cascade_slave;
    reg u8086_or_mcs80_config;
    reg [2:0] control_state;
    reg cascade_output_ack_2_3;
    reg [7:0] interrupt_when_ack1;
    reg [7:0] acknowledge_interrupt;
    reg call_address_interval_4_or_8_config;
    reg [10:0] interrupt_vector_address;
    reg read;

    // Outputs
    reg out_control_logic_data;
    reg [7:0] control_logic_data;

    AcknowledgeModule Acknowledge (.*);

    task TASK_INIT();
    begin
        interrupt_acknowledge_n = 1;
        cascade_slave = 0;
        u8086_or_mcs80_config = 0;
        control_state = 3'b000;
        cascade_output_ack_2_3 = 0;
        interrupt_when_ack1 = 8'b00000000;
        acknowledge_interrupt = 8'b00000000;
        call_address_interval_4_or_8_config = 0;
        interrupt_vector_address = 11'b00000000000;
        read = 0;
    end
    endtask

    task TASK_WRITE_MCS80();
    begin
        // ACK1
        interrupt_acknowledge_n = 0;
        u8086_or_mcs80_config = 1;
        control_state = 3'b001;
        cascade_output_ack_2_3 = 1;

        #100
        interrupt_acknowledge_n = 1;
        
        // ACK2
        #100 
        interrupt_acknowledge_n = 0;
        control_state = 3'b010;
        acknowledge_interrupt = 8'b00000010;
        interrupt_vector_address = 11'b10101010101;

        #100
        interrupt_acknowledge_n = 1;

        // ACK3
        #100
        interrupt_acknowledge_n = 0;
        control_state = 3'b011;

        #100
        interrupt_acknowledge_n = 1;
    end
    endtask

    task TASK_WRITE_U8086();
    begin
        // ACK1
        interrupt_acknowledge_n = 0;
        u8086_or_mcs80_config = 0;
        control_state = 3'b001;
        cascade_output_ack_2_3 = 1;

        #100
        interrupt_acknowledge_n = 1;
        
        // ACK2
        #100 
        interrupt_acknowledge_n = 0;
        control_state = 3'b010;
        call_address_interval_4_or_8_config = 0;
        acknowledge_interrupt = 8'b00000010;
        interrupt_vector_address = 11'b10101010101;

        #100
        interrupt_acknowledge_n = 1;
    end
    endtask

    initial begin
        TASK_INIT();
        #100
        TASK_WRITE_MCS80();
        #100
        TASK_WRITE_U8086();
    end
    

endmodule

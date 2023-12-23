`define TB_CYCLE 20

module ControlLogic_tb();

    reg   [2:0]   cascade_inout;
    reg           slave_program_or_enable_buffer;
    reg           interrupt_acknowledge_n;
    reg   [7:0]   internal_data_bus;
    reg           write_initial_command_word_1;
    reg           write_initial_command_word_2_4;
    reg           write_operation_control_word_1;
    reg           write_operation_control_word_2;
    reg           write_operation_control_word_3;
    reg           read;
    reg           write;
    reg   [7:0]   interrupt;
    reg   [7:0]   highest_level_in_service;
    reg           slave_program_n;

    reg           out_control_logic_data;
    reg   [7:0]   control_logic_data;
    reg           interrupt_to_cpu;
    reg           level_or_edge_toriggered_config;
    reg           special_fully_nest_config;
    reg           enable_read_register;
    reg           read_register_isr_or_irr;
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
        read                    = 1'b1;
        write                   = 1'b1;
        internal_data_bus       = 8'b00000000;
        cascade_inout              = 3'b000;
        slave_program_or_enable_buffer         = 1'b0;
        interrupt_acknowledge_n = 1'b1;
        interrupt       = 8'b00000000;
        #(`TB_CYCLE * 12);
    end
    endtask

    //
    // Task : Write data
    //
    task TASK_WRITE_DATA(input addr, input [7:0] data);
    begin
        #(`TB_CYCLE * 0);
        write           = 1'b0;
        internal_data_bus  = data;
        #(`TB_CYCLE * 1);
        write           = 1'b1;
        internal_data_bus  = 8'b00000000;
        #(`TB_CYCLE * 1);
    end
    endtask

    //
    // Task : Read data
    //
    task TASK_READ_DATA(input addr);
    begin
        #(`TB_CYCLE * 0);
        read            = 1'b0;
        #(`TB_CYCLE * 1);
        read            = 1'b1;
        #(`TB_CYCLE * 1);
    end
    endtask

    //
    // Task : Send specific EOI
    //
    task TASK_INTERRUPT_REQUEST(input [7:0] request);
    begin
        #(`TB_CYCLE * 0);
        interrupt = request;
        #(`TB_CYCLE * 1);
        interrupt = 8'b00000000;
    end
    endtask

    //
    // Task : Send specific EOI
    //
    task TASK_SEND_SPECIFIC_EOI(input [2:0] int_no);
    begin
        TASK_WRITE_DATA(1'b0, {8'b01100, int_no});
    end
    endtask

    //
    // Task : Send non specific EOI
    //
    task TASK_SEND_NON_SPECIFIC_EOI();
    begin
        TASK_WRITE_DATA(1'b0, 8'b00100000);
    end
    endtask

    //
    // Task : Send ack (MCS-80)
    //
    task TASK_SEND_ACK_TO_MCS80();
    begin
        #(`TB_CYCLE * 0);
        interrupt_acknowledge_n = 1'b1;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b0;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b1;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b0;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b1;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b0;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b1;
    end
    endtask

    //
    // Task : Send ack (MCS-80)
    //
    task TASK_SEND_ACK_TO_MCS80_SLAVE(input [2:0] slave_id);
    begin
        #(`TB_CYCLE * 0);
        interrupt_acknowledge_n = 1'b1;
        cascade_inout = 3'b000;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b0;
        #(`TB_CYCLE / 2);
        cascade_inout = slave_id;
        #(`TB_CYCLE / 2);
        interrupt_acknowledge_n = 1'b1;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b0;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b1;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b0;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b1;
        cascade_inout = 3'b000;
    end
    endtask

    //
    // Task : Send ack (8086)
    //
    task TASK_SEND_ACK_TO_8086();
    begin
        #(`TB_CYCLE * 0);
        interrupt_acknowledge_n = 1'b1;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b0;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b1;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b0;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b1;
    end
    endtask

    //
    // Task : Send ack (8086)
    //
    task TASK_SEND_ACK_TO_8086_SLAVE(input [2:0] slave_id);
    begin
        #(`TB_CYCLE * 0);
        interrupt_acknowledge_n = 1'b1;
        cascade_inout = 3'b000;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b0;
        #(`TB_CYCLE / 2);
        cascade_inout = slave_id;
        #(`TB_CYCLE / 2);
        interrupt_acknowledge_n = 1'b1;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b0;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b1;
        cascade_inout = 3'b000;
    end
    endtask



    //
    // TASK : MCS80 interrupt test
    //
    task TASK_MCS80_NORMAL_INTERRUPT_TEST();
    begin
        #(`TB_CYCLE * 0);        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b00011111);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001100);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        // Interrupt
        TASK_INTERRUPT_REQUEST(8'b00000001);
        TASK_SEND_ACK_TO_MCS80();
        TASK_SEND_SPECIFIC_EOI(3'b000);

        TASK_INTERRUPT_REQUEST(8'b00000010);
        TASK_SEND_ACK_TO_MCS80();
        TASK_SEND_SPECIFIC_EOI(3'b001);

        TASK_INTERRUPT_REQUEST(8'b00000100);
        TASK_SEND_ACK_TO_MCS80();
        TASK_SEND_SPECIFIC_EOI(3'b010);

        TASK_INTERRUPT_REQUEST(8'b00001000);
        TASK_SEND_ACK_TO_MCS80();
        TASK_SEND_SPECIFIC_EOI(3'b011);

        TASK_INTERRUPT_REQUEST(8'b00010000);
        TASK_SEND_ACK_TO_MCS80();
        TASK_SEND_SPECIFIC_EOI(3'b100);

        TASK_INTERRUPT_REQUEST(8'b00100000);
        TASK_SEND_ACK_TO_MCS80();
        TASK_SEND_SPECIFIC_EOI(3'b101);

        TASK_INTERRUPT_REQUEST(8'b01000000);
        TASK_SEND_ACK_TO_MCS80();
        TASK_SEND_SPECIFIC_EOI(3'b110);

        TASK_INTERRUPT_REQUEST(8'b10000000);
        TASK_SEND_ACK_TO_MCS80();
        TASK_SEND_SPECIFIC_EOI(3'b111);
        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b00111111);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001100);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        // Interrupt
        TASK_INTERRUPT_REQUEST(8'b00000001);
        TASK_SEND_ACK_TO_MCS80();
        TASK_SEND_SPECIFIC_EOI(3'b000);
        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b01011111);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001100);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        // Interrupt
        TASK_INTERRUPT_REQUEST(8'b00000001);
        TASK_SEND_ACK_TO_MCS80();
        TASK_SEND_SPECIFIC_EOI(3'b000);
        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b10011111);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001100);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        // Interrupt
        TASK_INTERRUPT_REQUEST(8'b00000001);
        TASK_SEND_ACK_TO_MCS80();
        TASK_SEND_SPECIFIC_EOI(3'b000);
        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b00011111);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b00000001);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001100);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        // Interrupt
        TASK_INTERRUPT_REQUEST(8'b00000001);
        TASK_SEND_ACK_TO_MCS80();
        TASK_SEND_SPECIFIC_EOI(3'b000);
        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b00011111);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b00000010);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001100);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        // Interrupt
        TASK_INTERRUPT_REQUEST(8'b00000001);
        TASK_SEND_ACK_TO_MCS80();
        TASK_SEND_SPECIFIC_EOI(3'b000);
        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b00011111);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b00000100);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001100);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        // Interrupt
        TASK_INTERRUPT_REQUEST(8'b00000001);
        TASK_SEND_ACK_TO_MCS80();
        TASK_SEND_SPECIFIC_EOI(3'b000);
        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b00011111);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b00001000);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001100);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        // Interrupt
        TASK_INTERRUPT_REQUEST(8'b00000001);
        TASK_SEND_ACK_TO_MCS80();
        TASK_SEND_SPECIFIC_EOI(3'b000);
        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b00011111);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b00010000);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001100);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        // Interrupt
        TASK_INTERRUPT_REQUEST(8'b00000001);
        TASK_SEND_ACK_TO_MCS80();
        TASK_SEND_SPECIFIC_EOI(3'b000);
        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b00011111);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b00100000);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001100);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        // Interrupt
        TASK_INTERRUPT_REQUEST(8'b00000001);
        TASK_SEND_ACK_TO_MCS80();
        TASK_SEND_SPECIFIC_EOI(3'b000);
        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b00011111);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b01000000);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001100);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        // Interrupt
        TASK_INTERRUPT_REQUEST(8'b00000001);
        TASK_SEND_ACK_TO_MCS80();
        TASK_SEND_SPECIFIC_EOI(3'b000);
        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b00011111);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b10000000);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001100);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        // Interrupt
        TASK_INTERRUPT_REQUEST(8'b00000001);
        TASK_SEND_ACK_TO_MCS80();
        TASK_SEND_SPECIFIC_EOI(3'b000);
        #(`TB_CYCLE * 0);
        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b00011011);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001100);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        // Interrupt
        TASK_INTERRUPT_REQUEST(8'b00000001);
        TASK_SEND_ACK_TO_MCS80();
        TASK_SEND_SPECIFIC_EOI(3'b000);

        TASK_INTERRUPT_REQUEST(8'b00000010);
        TASK_SEND_ACK_TO_MCS80();
        TASK_SEND_SPECIFIC_EOI(3'b001);

        TASK_INTERRUPT_REQUEST(8'b00000100);
        TASK_SEND_ACK_TO_MCS80();
        TASK_SEND_SPECIFIC_EOI(3'b010);

        TASK_INTERRUPT_REQUEST(8'b00001000);
        TASK_SEND_ACK_TO_MCS80();
        TASK_SEND_SPECIFIC_EOI(3'b011);

        TASK_INTERRUPT_REQUEST(8'b00010000);
        TASK_SEND_ACK_TO_MCS80();
        TASK_SEND_SPECIFIC_EOI(3'b100);

        TASK_INTERRUPT_REQUEST(8'b00100000);
        TASK_SEND_ACK_TO_MCS80();
        TASK_SEND_SPECIFIC_EOI(3'b101);

        TASK_INTERRUPT_REQUEST(8'b01000000);
        TASK_SEND_ACK_TO_MCS80();
        TASK_SEND_SPECIFIC_EOI(3'b110);

        TASK_INTERRUPT_REQUEST(8'b10000000);
        TASK_SEND_ACK_TO_MCS80();
        TASK_SEND_SPECIFIC_EOI(3'b111);
        #(`TB_CYCLE * 1);
        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b01011011);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001100);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        // Interrupt
        TASK_INTERRUPT_REQUEST(8'b00000001);
        TASK_SEND_ACK_TO_MCS80();
        TASK_SEND_SPECIFIC_EOI(3'b000);
        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b10011011);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001100);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        // Interrupt
        TASK_INTERRUPT_REQUEST(8'b00000001);
        TASK_SEND_ACK_TO_MCS80();
        TASK_SEND_SPECIFIC_EOI(3'b000);
        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b00011011);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b00000001);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001100);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        // Interrupt
        TASK_INTERRUPT_REQUEST(8'b00000001);
        TASK_SEND_ACK_TO_MCS80();
        TASK_SEND_SPECIFIC_EOI(3'b000);
        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b00011011);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b00000010);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001100);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        // Interrupt
        TASK_INTERRUPT_REQUEST(8'b00000001);
        TASK_SEND_ACK_TO_MCS80();
        TASK_SEND_SPECIFIC_EOI(3'b000);
        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b00011011);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b00000100);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001100);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        // Interrupt
        TASK_INTERRUPT_REQUEST(8'b00000001);
        TASK_SEND_ACK_TO_MCS80();
        TASK_SEND_SPECIFIC_EOI(3'b000);
        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b00011011);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b00001000);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001100);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        // Interrupt
        TASK_INTERRUPT_REQUEST(8'b00000001);
        TASK_SEND_ACK_TO_MCS80();
        TASK_SEND_SPECIFIC_EOI(3'b000);
        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b00011011);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b00010000);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001100);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        // Interrupt
        TASK_INTERRUPT_REQUEST(8'b00000001);
        TASK_SEND_ACK_TO_MCS80();
        TASK_SEND_SPECIFIC_EOI(3'b000);
        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b00011011);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b00100000);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001100);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        // Interrupt
        TASK_INTERRUPT_REQUEST(8'b00000001);
        TASK_SEND_ACK_TO_MCS80();
        TASK_SEND_SPECIFIC_EOI(3'b000);
        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b00011011);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b01000000);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001100);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        // Interrupt
        TASK_INTERRUPT_REQUEST(8'b00000001);
        TASK_SEND_ACK_TO_MCS80();
        TASK_SEND_SPECIFIC_EOI(3'b000);
        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b00011011);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b10000000);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001100);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        // Interrupt
        TASK_INTERRUPT_REQUEST(8'b00000001);
        TASK_SEND_ACK_TO_MCS80();
        TASK_SEND_SPECIFIC_EOI(3'b000);
        #(`TB_CYCLE * 12);
    end
    endtask

    //
    // TASK : 8086 interrupt test
    //
    task TASK_8086_NORMAL_INTERRUPT_TEST();
    begin
        #(`TB_CYCLE * 0);        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b00011111);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001101);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        // Interrupt
        TASK_INTERRUPT_REQUEST(8'b00000001);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b000);

        TASK_INTERRUPT_REQUEST(8'b00000010);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b001);

        TASK_INTERRUPT_REQUEST(8'b00000100);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b010);

        TASK_INTERRUPT_REQUEST(8'b00001000);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b011);

        TASK_INTERRUPT_REQUEST(8'b00010000);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b100);

        TASK_INTERRUPT_REQUEST(8'b00100000);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b101);

        TASK_INTERRUPT_REQUEST(8'b01000000);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b110);

        TASK_INTERRUPT_REQUEST(8'b10000000);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b111);
        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b00011111);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b00001000);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001101);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        // Interrupt
        TASK_INTERRUPT_REQUEST(8'b00000001);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b000);
        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b00011111);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b00010000);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001101);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        // Interrupt
        TASK_INTERRUPT_REQUEST(8'b00000001);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b000);
        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b00011111);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b00100000);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001101);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        // Interrupt
        TASK_INTERRUPT_REQUEST(8'b00000001);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b000);
        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b00011111);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b01000000);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001101);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        // Interrupt
        TASK_INTERRUPT_REQUEST(8'b00000001);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b000);
        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b00011111);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b10000000);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001101);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        // Interrupt
        TASK_INTERRUPT_REQUEST(8'b00000001);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b000);
        #(`TB_CYCLE * 12);
    end
    endtask

    //
    // TASK : level torigger test
    //
    task TASK_LEVEL_TORIGGER_TEST();
    begin
        #(`TB_CYCLE * 0);
        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b00011111);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001101);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        interrupt = 8'b00000001;
        #(`TB_CYCLE * 1);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b000);
        #(`TB_CYCLE * 1);
        interrupt = 8'b00000000;
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b000);

        interrupt = 8'b00000010;
        #(`TB_CYCLE * 1);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b001);
        #(`TB_CYCLE * 1);
        interrupt = 8'b00000000;
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b001);

        interrupt = 8'b00000100;
        #(`TB_CYCLE * 1);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b010);
        #(`TB_CYCLE * 1);
        interrupt = 8'b00000000;
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b010);

        interrupt = 8'b00001000;
        #(`TB_CYCLE * 1);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b011);
        #(`TB_CYCLE * 1);
        interrupt = 8'b00000000;
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b011);

        interrupt = 8'b00010000;
        #(`TB_CYCLE * 1);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b100);
        #(`TB_CYCLE * 1);
        interrupt = 8'b00000000;
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b100);

        interrupt = 8'b00100000;
        #(`TB_CYCLE * 1);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b101);
        #(`TB_CYCLE * 1);
        interrupt = 8'b00000000;
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b101);

        interrupt = 8'b01000000;
        #(`TB_CYCLE * 1);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b110);
        #(`TB_CYCLE * 1);
        interrupt = 8'b00000000;
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b110);

        interrupt = 8'b10000000;
        #(`TB_CYCLE * 1);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b111);
        #(`TB_CYCLE * 1);
        interrupt = 8'b00000000;
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b111);
        #(`TB_CYCLE * 12);
    end
    endtask

    //
    // TASK : edge torigger test
    //
    task TASK_EDGE_TORIGGER_TEST();
    begin
        #(`TB_CYCLE * 0);
        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b00010111);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001101);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        interrupt = 8'b00000001;
        #(`TB_CYCLE * 1);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b000);
        #(`TB_CYCLE * 5);

        interrupt = 8'b00000010;
        #(`TB_CYCLE * 1);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b001);
        #(`TB_CYCLE * 5);

        interrupt = 8'b00000100;
        #(`TB_CYCLE * 1);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b010);
        #(`TB_CYCLE * 5);

        interrupt = 8'b00001000;
        #(`TB_CYCLE * 1);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b011);
        #(`TB_CYCLE * 5);

        interrupt = 8'b00010000;
        #(`TB_CYCLE * 1);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b100);
        #(`TB_CYCLE * 5);

        interrupt = 8'b00100000;
        #(`TB_CYCLE * 1);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b101);
        #(`TB_CYCLE * 5);

        interrupt = 8'b01000000;
        #(`TB_CYCLE * 1);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b110);
        #(`TB_CYCLE * 5);

        interrupt = 8'b10000000;
        #(`TB_CYCLE * 1);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b111);
        #(`TB_CYCLE * 5);

        interrupt = 8'b00000000;
        #(`TB_CYCLE * 12);
    end
    endtask

    //
    // TASK : interrupt mask test
    //
    task TASK_INTERRUPT_MASK_TEST();
    begin
        #(`TB_CYCLE * 0);
        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b00011111);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001101);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b11111111);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        // Can't interrupt
        TASK_INTERRUPT_REQUEST(8'b11111111);
        #(`TB_CYCLE * 5);

        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b11111110);
        // Interrupt
        TASK_INTERRUPT_REQUEST(8'b11111111);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b000);

        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b11111101);
        // Interrupt
        TASK_INTERRUPT_REQUEST(8'b11111111);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b001);

        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b11111011);
        // Interrupt
        TASK_INTERRUPT_REQUEST(8'b11111111);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b010);

        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b11110111);
        // Interrupt
        TASK_INTERRUPT_REQUEST(8'b11111111);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b011);

        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b11101111);
        // Interrupt
        TASK_INTERRUPT_REQUEST(8'b11111111);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b100);

        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b11011111);
        // Interrupt
        TASK_INTERRUPT_REQUEST(8'b11111111);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b101);

        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b10111111);
        // Interrupt
        TASK_INTERRUPT_REQUEST(8'b11111111);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b110);

        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b01111111);
        // Interrupt
        TASK_INTERRUPT_REQUEST(8'b11111111);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b111);
        #(`TB_CYCLE * 12);
    end
    endtask

    //
    // TASK : special task test
    //
    task TASK_SPECIAL_MASK_TEST();
    begin
        #(`TB_CYCLE * 0);
        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b00011111);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001101);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        // Interrupt
        TASK_INTERRUPT_REQUEST(8'b00000001);
        TASK_SEND_ACK_TO_8086();
        #(`TB_CYCLE * 1);

        // Interrupt (can't)
        TASK_INTERRUPT_REQUEST(8'b10000000);
        #(`TB_CYCLE * 5);

        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b01101000);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000001);

        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b111);

        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b01001000);

        // Interrupt (can't)
        TASK_INTERRUPT_REQUEST(8'b10000000);
        #(`TB_CYCLE * 5);

        TASK_SEND_SPECIFIC_EOI(3'b000);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b111);

        #(`TB_CYCLE * 12);
    end
    endtask

    //
    // TASK : auto-eoi test
    //
    task TASK_AUTO_EOI_TEST();
    begin
        #(`TB_CYCLE * 0);
        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b00011111);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001111);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        // Interrupt
        TASK_INTERRUPT_REQUEST(8'b11111111);

        // ACK
        TASK_SEND_ACK_TO_8086();
        #(`TB_CYCLE * 1);

        TASK_SEND_ACK_TO_8086();
        #(`TB_CYCLE * 1);

        TASK_SEND_ACK_TO_8086();
        #(`TB_CYCLE * 1);

        TASK_SEND_ACK_TO_8086();
        #(`TB_CYCLE * 1);

        TASK_SEND_ACK_TO_8086();
        #(`TB_CYCLE * 1);

        TASK_SEND_ACK_TO_8086();
        #(`TB_CYCLE * 1);

        TASK_SEND_ACK_TO_8086();
        #(`TB_CYCLE * 1);

        TASK_SEND_ACK_TO_8086();
        #(`TB_CYCLE * 12);
    end
    endtask

    //
    // TASK : non special fully nested
    //
    task TASK_NON_SPECTAL_FULLY_NESTED_TEST();
    begin
        #(`TB_CYCLE * 0);
        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b00011111);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001101);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        // Interrupt
        TASK_INTERRUPT_REQUEST(8'b00010000);    // 4
        TASK_SEND_ACK_TO_8086();
        #(`TB_CYCLE * 1);
        TASK_INTERRUPT_REQUEST(8'b00100000);    // 5
        TASK_INTERRUPT_REQUEST(8'b00010000);    // 4
        TASK_INTERRUPT_REQUEST(8'b00001000);    // 3
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b011);
        TASK_SEND_SPECIFIC_EOI(3'b100);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b100);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b101);
        #(`TB_CYCLE * 12);
    end
    endtask

    //
    // TASK : special fully nested
    //
    task TASK_SPECTAL_FULLY_NESTED_TEST();
    begin
        #(`TB_CYCLE * 0);
        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b00011111);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00011101);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        // Interrupt
        TASK_INTERRUPT_REQUEST(8'b00010000);    // 4
        TASK_SEND_ACK_TO_8086();
        #(`TB_CYCLE * 1);
        TASK_INTERRUPT_REQUEST(8'b00100000);    // 5
        TASK_INTERRUPT_REQUEST(8'b00010000);    // 4
        TASK_SEND_ACK_TO_8086();
        #(`TB_CYCLE * 1);

        TASK_INTERRUPT_REQUEST(8'b00001000);    // 3
        TASK_SEND_ACK_TO_8086();
        #(`TB_CYCLE * 1);

        TASK_SEND_SPECIFIC_EOI(3'b011);
        TASK_SEND_SPECIFIC_EOI(3'b100);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b101);
        #(`TB_CYCLE * 12);
    end
    endtask

    //
    // TASK : non specific test
    //
    task TASK_NON_SPECIFIC_EOI_TEST();
    begin
        #(`TB_CYCLE * 0);
        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b00011111);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001101);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        // Interrupt
        TASK_INTERRUPT_REQUEST(8'b11111111);

        TASK_SEND_ACK_TO_8086();
        TASK_SEND_NON_SPECIFIC_EOI();

        TASK_SEND_ACK_TO_8086();
        TASK_SEND_NON_SPECIFIC_EOI();

        TASK_SEND_ACK_TO_8086();
        TASK_SEND_NON_SPECIFIC_EOI();

        TASK_SEND_ACK_TO_8086();
        TASK_SEND_NON_SPECIFIC_EOI();

        TASK_SEND_ACK_TO_8086();
        TASK_SEND_NON_SPECIFIC_EOI();

        TASK_SEND_ACK_TO_8086();
        TASK_SEND_NON_SPECIFIC_EOI();

        TASK_SEND_ACK_TO_8086();
        TASK_SEND_NON_SPECIFIC_EOI();

        TASK_SEND_ACK_TO_8086();
        TASK_SEND_NON_SPECIFIC_EOI();
        #(`TB_CYCLE * 12);
    end
    endtask

    //
    // TASK : non specific test
    //
    task TASK_ROTATE_TEST();
    begin
        #(`TB_CYCLE * 0);
        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b00011111);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001101);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b11000100);

        // Interrupt
        TASK_INTERRUPT_REQUEST(8'b11111111);

        TASK_SEND_ACK_TO_8086();
        TASK_SEND_NON_SPECIFIC_EOI();

        TASK_SEND_ACK_TO_8086();
        TASK_SEND_NON_SPECIFIC_EOI();

        TASK_SEND_ACK_TO_8086();
        TASK_SEND_NON_SPECIFIC_EOI();

        TASK_SEND_ACK_TO_8086();
        TASK_SEND_NON_SPECIFIC_EOI();

        TASK_SEND_ACK_TO_8086();
        TASK_SEND_NON_SPECIFIC_EOI();

        TASK_SEND_ACK_TO_8086();
        TASK_SEND_NON_SPECIFIC_EOI();

        TASK_SEND_ACK_TO_8086();
        TASK_SEND_NON_SPECIFIC_EOI();

        TASK_SEND_ACK_TO_8086();
        TASK_SEND_NON_SPECIFIC_EOI();
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b11000111);

        // Interrupt
        TASK_INTERRUPT_REQUEST(8'b00001000);
        TASK_SEND_ACK_TO_8086();
        TASK_WRITE_DATA(1'b0, 8'b10100000);
        TASK_INTERRUPT_REQUEST(8'b11111111);

        TASK_SEND_ACK_TO_8086();
        TASK_SEND_NON_SPECIFIC_EOI();

        TASK_SEND_ACK_TO_8086();
        TASK_SEND_NON_SPECIFIC_EOI();

        TASK_SEND_ACK_TO_8086();
        TASK_SEND_NON_SPECIFIC_EOI();

        TASK_SEND_ACK_TO_8086();
        TASK_SEND_NON_SPECIFIC_EOI();

        TASK_SEND_ACK_TO_8086();
        TASK_SEND_NON_SPECIFIC_EOI();

        TASK_SEND_ACK_TO_8086();
        TASK_SEND_NON_SPECIFIC_EOI();

        TASK_SEND_ACK_TO_8086();
        TASK_SEND_NON_SPECIFIC_EOI();

        TASK_SEND_ACK_TO_8086();
        TASK_SEND_NON_SPECIFIC_EOI();
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b11000111);
        TASK_WRITE_DATA(1'b0, 8'b10000000);

        // Interrupt
        TASK_INTERRUPT_REQUEST(8'b00000100);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_NON_SPECIFIC_EOI();

        TASK_WRITE_DATA(1'b0, 8'b00000000);

        TASK_INTERRUPT_REQUEST(8'b11111111);

        TASK_SEND_ACK_TO_8086();
        TASK_SEND_NON_SPECIFIC_EOI();

        TASK_SEND_ACK_TO_8086();
        TASK_SEND_NON_SPECIFIC_EOI();

        TASK_SEND_ACK_TO_8086();
        TASK_SEND_NON_SPECIFIC_EOI();

        TASK_SEND_ACK_TO_8086();
        TASK_SEND_NON_SPECIFIC_EOI();

        TASK_SEND_ACK_TO_8086();
        TASK_SEND_NON_SPECIFIC_EOI();

        TASK_SEND_ACK_TO_8086();
        TASK_SEND_NON_SPECIFIC_EOI();

        TASK_SEND_ACK_TO_8086();
        TASK_SEND_NON_SPECIFIC_EOI();

        TASK_SEND_ACK_TO_8086();
        TASK_SEND_NON_SPECIFIC_EOI();

        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b11000111);
        #(`TB_CYCLE * 12);
    end
    endtask

    //
    // TASK : poll command test
    //
    task TASK_POLL_COMMAND_TEST();
    begin
        #(`TB_CYCLE * 0);
        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b00011111);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001101);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        TASK_INTERRUPT_REQUEST(8'b11111111);

        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001100);
        TASK_READ_DATA(1'b0);
        TASK_SEND_NON_SPECIFIC_EOI();

        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001100);
        TASK_READ_DATA(1'b0);
        TASK_SEND_NON_SPECIFIC_EOI();

        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001100);
        TASK_READ_DATA(1'b0);
        TASK_SEND_NON_SPECIFIC_EOI();

        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001100);
        TASK_READ_DATA(1'b0);
        TASK_SEND_NON_SPECIFIC_EOI();

        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001100);
        TASK_READ_DATA(1'b0);
        TASK_SEND_NON_SPECIFIC_EOI();

        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001100);
        TASK_READ_DATA(1'b0);
        TASK_SEND_NON_SPECIFIC_EOI();

        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001100);
        TASK_READ_DATA(1'b0);
        TASK_SEND_NON_SPECIFIC_EOI();

        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001100);
        TASK_READ_DATA(1'b0);
        TASK_SEND_NON_SPECIFIC_EOI();

        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001100);
        TASK_READ_DATA(1'b0);
        TASK_SEND_NON_SPECIFIC_EOI();

        TASK_INTERRUPT_REQUEST(8'b10000000);

        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001100);
        TASK_READ_DATA(1'b0);

        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001100);
        TASK_READ_DATA(1'b0);

        TASK_INTERRUPT_REQUEST(8'b01000000);

        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001100);
        TASK_READ_DATA(1'b0);

        TASK_SEND_NON_SPECIFIC_EOI();
        TASK_SEND_NON_SPECIFIC_EOI();
        #(`TB_CYCLE * 12);
    end
    endtask

    //
    // TASK : reading status test
    //
    task TASK_READING_STATUS_TEST();
    begin
        #(`TB_CYCLE * 0);
        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b00011111);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001101);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001010);
        TASK_READ_DATA(1'b0);

        TASK_INTERRUPT_REQUEST(8'b00000001);
        TASK_SEND_ACK_TO_8086();
        #(`TB_CYCLE * 1);

        TASK_INTERRUPT_REQUEST(8'b00000001);
        TASK_READ_DATA(1'b0);

        TASK_INTERRUPT_REQUEST(8'b00000010);
        TASK_READ_DATA(1'b0);

        TASK_INTERRUPT_REQUEST(8'b00000100);
        TASK_READ_DATA(1'b0);

        TASK_INTERRUPT_REQUEST(8'b00001000);
        TASK_READ_DATA(1'b0);

        TASK_INTERRUPT_REQUEST(8'b00010000);
        TASK_READ_DATA(1'b0);

        TASK_INTERRUPT_REQUEST(8'b00100000);
        TASK_READ_DATA(1'b0);

        TASK_INTERRUPT_REQUEST(8'b01000000);
        TASK_READ_DATA(1'b0);

        TASK_INTERRUPT_REQUEST(8'b10000000);
        TASK_READ_DATA(1'b0);
        TASK_WRITE_DATA(1'b0, 8'b00001011);

        TASK_READ_DATA(1'b0);

        TASK_SEND_NON_SPECIFIC_EOI();
        TASK_SEND_ACK_TO_8086();
        #(`TB_CYCLE * 1);
        TASK_READ_DATA(1'b0);

        TASK_SEND_NON_SPECIFIC_EOI();
        TASK_SEND_ACK_TO_8086();
        #(`TB_CYCLE * 1);
        TASK_READ_DATA(1'b0);

        TASK_SEND_NON_SPECIFIC_EOI();
        TASK_SEND_ACK_TO_8086();
        #(`TB_CYCLE * 1);
        TASK_READ_DATA(1'b0);

        TASK_SEND_NON_SPECIFIC_EOI();
        TASK_SEND_ACK_TO_8086();
        #(`TB_CYCLE * 1);
        TASK_READ_DATA(1'b0);

        TASK_SEND_NON_SPECIFIC_EOI();
        TASK_SEND_ACK_TO_8086();
        #(`TB_CYCLE * 1);
        TASK_READ_DATA(1'b0);

        TASK_SEND_NON_SPECIFIC_EOI();
        TASK_SEND_ACK_TO_8086();
        #(`TB_CYCLE * 1);
        TASK_READ_DATA(1'b0);

        TASK_SEND_NON_SPECIFIC_EOI();
        TASK_SEND_ACK_TO_8086();
        #(`TB_CYCLE * 1);
        TASK_READ_DATA(1'b0);

        TASK_SEND_NON_SPECIFIC_EOI();
        TASK_SEND_ACK_TO_8086();
        #(`TB_CYCLE * 1);
        TASK_READ_DATA(1'b0);

        TASK_SEND_NON_SPECIFIC_EOI();
        TASK_READ_DATA(1'b0);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        TASK_READ_DATA(1'b1);

        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000001);
        TASK_READ_DATA(1'b1);

        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000010);
        TASK_READ_DATA(1'b1);

        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000100);
        TASK_READ_DATA(1'b1);

        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00001000);
        TASK_READ_DATA(1'b1);

        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00010000);
        TASK_READ_DATA(1'b1);

        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00100000);
        TASK_READ_DATA(1'b1);

        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b01000000);
        TASK_READ_DATA(1'b1);

        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b10000000);
        TASK_READ_DATA(1'b1);

        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);

        #(`TB_CYCLE * 12);
    end
    endtask

    //
    // TASK : cascade mode test
    //
    task TASK_CASCADE_MODE_TEST();
    begin
        #(`TB_CYCLE * 0);        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b00011101);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // ICW3
        TASK_WRITE_DATA(1'b1, 8'b11111111);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001100);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        // interrupt
        TASK_INTERRUPT_REQUEST(8'b11111111);

        TASK_SEND_ACK_TO_MCS80();
        TASK_SEND_NON_SPECIFIC_EOI();

        TASK_SEND_ACK_TO_MCS80();
        TASK_SEND_NON_SPECIFIC_EOI();

        TASK_SEND_ACK_TO_MCS80();
        TASK_SEND_NON_SPECIFIC_EOI();

        TASK_SEND_ACK_TO_MCS80();
        TASK_SEND_NON_SPECIFIC_EOI();

        TASK_SEND_ACK_TO_MCS80();
        TASK_SEND_NON_SPECIFIC_EOI();

        TASK_SEND_ACK_TO_MCS80();
        TASK_SEND_NON_SPECIFIC_EOI();

        TASK_SEND_ACK_TO_MCS80();
        TASK_SEND_NON_SPECIFIC_EOI();

        TASK_SEND_ACK_TO_MCS80();
        TASK_SEND_NON_SPECIFIC_EOI();
        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b00011101);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // ICW3
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001000);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        // interrupt
        TASK_INTERRUPT_REQUEST(8'b10000000);

        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b001);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b010);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b011);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b100);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b101);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b110);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b111);

        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b000);
        TASK_SEND_NON_SPECIFIC_EOI();
        #(`TB_CYCLE * 1);

        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b00011101);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // ICW3
        TASK_WRITE_DATA(1'b1, 8'b00000001);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001000);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        // interrupt
        TASK_INTERRUPT_REQUEST(8'b01000000);

        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b000);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b010);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b011);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b100);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b101);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b110);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b111);

        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b001);
        TASK_SEND_NON_SPECIFIC_EOI();
        #(`TB_CYCLE * 1);

        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b00011101);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // ICW3
        TASK_WRITE_DATA(1'b1, 8'b00000010);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001000);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        // interrupt
        TASK_INTERRUPT_REQUEST(8'b00100000);

        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b000);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b001);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b011);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b100);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b101);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b110);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b111);

        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b010);
        TASK_SEND_NON_SPECIFIC_EOI();
        #(`TB_CYCLE * 1);

        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b00011101);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // ICW3
        TASK_WRITE_DATA(1'b1, 8'b00000011);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001000);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        // interrupt
        TASK_INTERRUPT_REQUEST(8'b00010000);

        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b000);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b001);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b010);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b100);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b101);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b110);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b111);

        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b011);
        TASK_SEND_NON_SPECIFIC_EOI();
        #(`TB_CYCLE * 1);

        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b00011101);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // ICW3
        TASK_WRITE_DATA(1'b1, 8'b00000100);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001000);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        // interrupt
        TASK_INTERRUPT_REQUEST(8'b00001000);

        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b000);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b001);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b010);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b011);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b101);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b110);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b111);

        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b100);
        TASK_SEND_NON_SPECIFIC_EOI();
        #(`TB_CYCLE * 1);

        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b00011101);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // ICW3
        TASK_WRITE_DATA(1'b1, 8'b00000101);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001000);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        // interrupt
        TASK_INTERRUPT_REQUEST(8'b00000100);

        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b000);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b001);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b010);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b011);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b100);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b110);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b111);

        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b101);
        TASK_SEND_NON_SPECIFIC_EOI();
        #(`TB_CYCLE * 1);

        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b00011101);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // ICW3
        TASK_WRITE_DATA(1'b1, 8'b00000110);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001000);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        // interrupt
        TASK_INTERRUPT_REQUEST(8'b00000010);

        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b000);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b001);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b010);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b011);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b100);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b101);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b111);

        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b110);
        TASK_SEND_NON_SPECIFIC_EOI();
        #(`TB_CYCLE * 1);

        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b00011101);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // ICW3
        TASK_WRITE_DATA(1'b1, 8'b00000111);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00001000);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        // interrupt
        TASK_INTERRUPT_REQUEST(8'b00000001);

        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b000);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b001);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b010);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b011);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b100);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b101);
        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b110);

        TASK_SEND_ACK_TO_MCS80_SLAVE(3'b111);
        TASK_SEND_NON_SPECIFIC_EOI();

        #(`TB_CYCLE * 12);
    end
    endtask

    task TASK_SLAVE_PROGRAM_TEST();
    begin
        #(`TB_CYCLE * 0);
        // ICW1
        TASK_WRITE_DATA(1'b0, 8'b00011101);
        // ICW2
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // ICW3
        TASK_WRITE_DATA(1'b1, 8'b00000111);
        // ICW4
        TASK_WRITE_DATA(1'b1, 8'b00000001);
        // OCW1
        TASK_WRITE_DATA(1'b1, 8'b00000000);
        // OCW3
        TASK_WRITE_DATA(1'b0, 8'b00001000);

        slave_program_or_enable_buffer         = 1'b1;

        // interrupt
        TASK_INTERRUPT_REQUEST(8'b11111111);

        TASK_SEND_ACK_TO_8086();
        TASK_SEND_NON_SPECIFIC_EOI();

        TASK_SEND_ACK_TO_8086();
        TASK_SEND_NON_SPECIFIC_EOI();

        TASK_SEND_ACK_TO_8086();
        TASK_SEND_NON_SPECIFIC_EOI();

        TASK_SEND_ACK_TO_8086();
        TASK_SEND_NON_SPECIFIC_EOI();

        TASK_SEND_ACK_TO_8086();
        TASK_SEND_NON_SPECIFIC_EOI();

        TASK_SEND_ACK_TO_8086();
        TASK_SEND_NON_SPECIFIC_EOI();

        TASK_SEND_ACK_TO_8086();
        TASK_SEND_NON_SPECIFIC_EOI();

        TASK_SEND_ACK_TO_8086();
        TASK_SEND_NON_SPECIFIC_EOI();

        slave_program_or_enable_buffer         = 1'b0;

        // interrupt
        TASK_INTERRUPT_REQUEST(8'b10000000);

        TASK_SEND_ACK_TO_8086_SLAVE(3'b000);
        TASK_SEND_ACK_TO_8086_SLAVE(3'b001);
        TASK_SEND_ACK_TO_8086_SLAVE(3'b010);
        TASK_SEND_ACK_TO_8086_SLAVE(3'b011);
        TASK_SEND_ACK_TO_8086_SLAVE(3'b100);
        TASK_SEND_ACK_TO_8086_SLAVE(3'b101);
        TASK_SEND_ACK_TO_8086_SLAVE(3'b110);
        TASK_SEND_ACK_TO_8086_SLAVE(3'b111);

        TASK_SEND_NON_SPECIFIC_EOI();

        #(`TB_CYCLE * 12);
    end
    endtask

    //
    // Test pattern
    //
    initial begin
        TASK_INIT();
        TASK_MCS80_NORMAL_INTERRUPT_TEST();
        TASK_8086_NORMAL_INTERRUPT_TEST();
        TASK_LEVEL_TORIGGER_TEST();
        TASK_EDGE_TORIGGER_TEST();
        TASK_INTERRUPT_MASK_TEST();
        TASK_SPECIAL_MASK_TEST();
        TASK_AUTO_EOI_TEST();
        TASK_NON_SPECTAL_FULLY_NESTED_TEST();
        TASK_SPECTAL_FULLY_NESTED_TEST();
        TASK_NON_SPECIFIC_EOI_TEST();
        TASK_ROTATE_TEST();
        TASK_POLL_COMMAND_TEST();
        TASK_READING_STATUS_TEST();
        TASK_CASCADE_MODE_TEST();
        TASK_SLAVE_PROGRAM_TEST();

        #(`TB_CYCLE * 1);
        // End of simulation
`ifdef IVERILOG
        $finish;
`elsif  MODELSIM
        $stop;
`else
        $finish;
`endif
    end
endmodule

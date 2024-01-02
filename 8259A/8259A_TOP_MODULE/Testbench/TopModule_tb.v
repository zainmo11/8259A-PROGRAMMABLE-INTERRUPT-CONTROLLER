
`define TB_CYCLE        20
`define TB_FINISH_COUNT 20000

module TopModule_8259A_tb();

    `timescale 1ns/10ps

    //
    // Module under test
    //
    reg           chip_select_n;
    reg           read_enable_n;
    reg           write_enable_n;
    reg           address;

    reg   [7:0]   interrupt_request;

    // Inout
    wire   [7:0]   data_bus;
    reg            data_bus_tri;
    reg    [7:0]   data_bus_write;
    wire   [7:0]   data_bus_read;

    wire   [2:0]   cascade_inout;
    reg            cascade_inout_tri;
    reg    [2:0]   cascade_inout_write;
    wire   [2:0]   cascade_inout_read;


    wire           slave_program_or_enable_buffer;
    reg            slave_program_or_enable_buffer_tri;
    reg            slave_program_or_enable_buffer_write;
    wire           slave_program_or_enable_buffer_read;



    reg           interrupt_acknowledge_n;

    reg           interrupt_to_cpu;

    TopModule_8259A u_TopModule_8259A (.*);
    assign data_bus = data_bus_tri ? 8'bzzzzzzzz : data_bus_write;
    assign data_bus_read = data_bus;
    assign cascade_inout = cascade_inout_tri ? 8'bzzzzzzzz : cascade_inout_write;
    assign cascade_inout_read = cascade_inout;
    assign slave_program_or_enable_buffer = slave_program_or_enable_buffer_tri ? 1'bz : slave_program_or_enable_buffer_write;
    assign slave_program_or_enable_buffer_read = slave_program_or_enable_buffer;
    //
    // Task : Initialization
    //
    task TASK_INIT();
    begin
        #(`TB_CYCLE * 0);
        chip_select_n           = 1'b1;
        read_enable_n           = 1'b1;
        write_enable_n          = 1'b1;
        address                 = 1'b0;
        data_bus_tri = 0;
        data_bus_write             = 8'b00000000;
        cascade_inout_tri = 0;
        cascade_inout_write              = 3'b000;
        slave_program_or_enable_buffer_tri = 0;
        slave_program_or_enable_buffer_write              = 3'b000;
        interrupt_acknowledge_n = 1'b1;
        interrupt_request       = 8'b00000000;
        #(`TB_CYCLE * 12);
    end
    endtask

    //
    // Task : Write data
    //
    task TASK_WRITE_DATA(input addr, input [7:0] data);
    begin
        #(`TB_CYCLE * 0);
        chip_select_n   = 1'b0;
        write_enable_n  = 1'b0;
        address         = addr;
        data_bus_tri = 0;
        data_bus_write     = data;
        #(`TB_CYCLE * 1);
        chip_select_n   = 1'b1;
        write_enable_n  = 1'b1;
        address         = 1'b0;
        data_bus_tri = 1;
        // data_bus     = 8'b00000000;
        #(`TB_CYCLE * 1);
    end
    endtask

    //
    // Task : Read data
    //
    task TASK_READ_DATA(input addr);
    begin
        #(`TB_CYCLE * 0);
        data_bus_tri = 1;
        chip_select_n   = 1'b0;
        read_enable_n   = 1'b0;
        address         = addr;
        #(`TB_CYCLE * 1);
        chip_select_n   = 1'b1;
        read_enable_n   = 1'b1;
        #(`TB_CYCLE * 1);
    end
    endtask

    //
    // Task : Send specific EOI
    //
    task TASK_INTERRUPT_REQUEST(input [7:0] request);
    begin
        #(`TB_CYCLE * 0);
        interrupt_request = request;
        #(`TB_CYCLE * 1);
        interrupt_request = 8'b00000000;
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
        cascade_inout_tri = 0;
        cascade_inout_write = 3'b000;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b0;
        #(`TB_CYCLE / 2);
        cascade_inout_write = slave_id;
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
        cascade_inout_write = 3'b000;
        cascade_inout_tri = 1;
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
        cascade_inout_tri = 0;
        cascade_inout_write = 3'b000;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b0;
        #(`TB_CYCLE / 2);
        cascade_inout_write = slave_id;
        #(`TB_CYCLE / 2);
        interrupt_acknowledge_n = 1'b1;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b0;
        #(`TB_CYCLE * 1);
        interrupt_acknowledge_n = 1'b1;
        cascade_inout_write = 3'b000;
        cascade_inout_tri = 1;
    end
    endtask



    //
    // TASK : MCS80 interrupt test
    //
    task TASK_MCS80_NORMAL_INTERRUPT_TEST();
    begin
        #(`TB_CYCLE * 0);
        // ICW1
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

        interrupt_request = 8'b00000001;
        #(`TB_CYCLE * 1);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b000);
        #(`TB_CYCLE * 1);
        interrupt_request = 8'b00000000;
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b000);

        interrupt_request = 8'b00000010;
        #(`TB_CYCLE * 1);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b001);
        #(`TB_CYCLE * 1);
        interrupt_request = 8'b00000000;
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b001);

        interrupt_request = 8'b00000100;
        #(`TB_CYCLE * 1);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b010);
        #(`TB_CYCLE * 1);
        interrupt_request = 8'b00000000;
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b010);

        interrupt_request = 8'b00001000;
        #(`TB_CYCLE * 1);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b011);
        #(`TB_CYCLE * 1);
        interrupt_request = 8'b00000000;
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b011);

        interrupt_request = 8'b00010000;
        #(`TB_CYCLE * 1);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b100);
        #(`TB_CYCLE * 1);
        interrupt_request = 8'b00000000;
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b100);

        interrupt_request = 8'b00100000;
        #(`TB_CYCLE * 1);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b101);
        #(`TB_CYCLE * 1);
        interrupt_request = 8'b00000000;
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b101);

        interrupt_request = 8'b01000000;
        #(`TB_CYCLE * 1);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b110);
        #(`TB_CYCLE * 1);
        interrupt_request = 8'b00000000;
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b110);

        interrupt_request = 8'b10000000;
        #(`TB_CYCLE * 1);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b111);
        #(`TB_CYCLE * 1);
        interrupt_request = 8'b00000000;
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

        interrupt_request = 8'b00000001;
        #(`TB_CYCLE * 1);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b000);
        #(`TB_CYCLE * 5);

        interrupt_request = 8'b00000010;
        #(`TB_CYCLE * 1);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b001);
        #(`TB_CYCLE * 5);

        interrupt_request = 8'b00000100;
        #(`TB_CYCLE * 1);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b010);
        #(`TB_CYCLE * 5);

        interrupt_request = 8'b00001000;
        #(`TB_CYCLE * 1);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b011);
        #(`TB_CYCLE * 5);

        interrupt_request = 8'b00010000;
        #(`TB_CYCLE * 1);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b100);
        #(`TB_CYCLE * 5);

        interrupt_request = 8'b00100000;
        #(`TB_CYCLE * 1);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b101);
        #(`TB_CYCLE * 5);

        interrupt_request = 8'b01000000;
        #(`TB_CYCLE * 1);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b110);
        #(`TB_CYCLE * 5);

        interrupt_request = 8'b10000000;
        #(`TB_CYCLE * 1);
        TASK_SEND_ACK_TO_8086();
        TASK_SEND_SPECIFIC_EOI(3'b111);
        #(`TB_CYCLE * 5);

        interrupt_request = 8'b00000000;
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
        #(`TB_CYCLE * 0);
        // ICW1
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

        slave_program_or_enable_buffer_tri = 0;
        slave_program_or_enable_buffer_write = 1;

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

        slave_program_or_enable_buffer_write = 0;

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

        slave_program_or_enable_buffer_tri = 1;
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

        $stop;

    end
endmodule

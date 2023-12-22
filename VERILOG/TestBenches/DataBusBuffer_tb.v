module DataBusBuffer_tb ();

    `timescale 1ns/10ps

    reg out_control_logic_data; // <-- ?
    reg read; // read is active low!
    reg address;
    reg enable_read_register;
    reg read_register_isr_or_irr; // 0 = IRR, 1 = ISR
    reg [7:0] control_logic_data ;// <-- ? 
    reg [7:0] interrupt_mask;
    reg [7:0] interrupt_request_register;
    reg [7:0] in_service_register;

    reg [7:0] data_bus_out;

    DataBusBuffer DataBusBuffer (.*);

    // -----------------------------------------------
    // Status Reading Tests: IRR, ISR, IMR

    task TASK_TEST_IRR_ISR(); // Read IRR or ISR
    begin
        address = 0; // OCW3
        interrupt_request_register = 8'b11100000;
        in_service_register = 8'b11111000;

        #0
        read = 1; // disable read
        enable_read_register = 0;
        read_register_isr_or_irr = 0;

        // Test 1.a: IRR ready to read, but NO ~RD signal => No reading
        #10
        enable_read_register = 1;
        read_register_isr_or_irr = 0;

        // Test 1.b: IRR ready to read, and ~RD signal => Read IRR
        #10
        read = 0;

        // Test 2.a: ISR ready to read, but NO ~RD signal => No reading
        #10
        enable_read_register = 1;
        read_register_isr_or_irr = 1;
        read = 1; // disable read

        // Test 2.b: ISR ready to read, and ~RD signal => Read ISR
        #10
        read = 0;

        #10
        read = 1;
    end
    endtask

    task TASK_TEST_IMR();
    begin
        address = 1; // OCW1
        interrupt_mask = 8'b10101010;

        #0
        read = 1;

        #10
        read = 0;

        #10
        read = 1;
    end
    endtask

    task TASK_TEST_STATUS_READING();
    begin
        TASK_TEST_IRR_ISR();
        TASK_TEST_IMR();
    end
    endtask

    // -----------------------------------------------


    initial begin
        TASK_TEST_STATUS_READING();
        
    end

endmodule
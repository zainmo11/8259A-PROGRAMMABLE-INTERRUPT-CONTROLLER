module TopModule_8259A(
    input   chip_select_n,
    input   read_enable_n,
    input   write_enable_n,
    input   address,

    input [7:0] interrupt_request,
    
    inout [7:0] data_bus,

    // I/O
    inout [2:0] cascade_inout,

    inout  slave_program_or_enable_buffer,

    input   interrupt_acknowledge_n,

    output  interrupt_to_cpu
);

    wire [7:0] internal_data_bus;
    wire      write_initial_command_word_1;    // Write initial command word 1 signal
    wire      write_initial_command_word_2_4;  // Write initial command word 2-4 signal
    wire      write_operation_control_word_1;  // Write operation control word 1 signal
    wire      write_operation_control_word_2;  // Write operation control word 2 signal
    wire      write_operation_control_word_3;  // Write operation control word 3 signal
    wire      read; 

    //Done
    Data_Bus_Control_8259 Data_Bus_Control(
        .chip_select_n (chip_select_n),
        .read_enable_n  (read_enable_n),
        .write_enable_n (write_enable_n),
        .address (address),

        .data_bus_in (data_bus),

        .internal_data_bus (internal_data_bus),
        
        .write_initial_command_word_1 (write_initial_command_word_1),
        .write_initial_command_word_2_4 (write_initial_command_word_2_4),

        .write_operation_control_word_1 (write_operation_control_word_1),
        .write_operation_control_word_2 (write_operation_control_word_2),
        .write_operation_control_word_3 (write_operation_control_word_3),

        .read (read)
    );

    wire out_control_logic_data;
    wire [7:0] control_logic_data;

    wire level_or_edge_toriggered;
    wire special_fully_nest_config;
    
    wire enable_read_register;
    wire read_register_isr_or_irr;

    wire [7:0] interrupt_mask;
    wire [7:0] interrupt_special_mask;

    wire [7:0] end_of_interrupt;

    wire [2:0] priority_rotate;

    wire freeze;
    wire latch_in_service;

    wire [7:0] clear_interrupt_request;

    wire [7:0] interrupt_request_register;

    wire [7:0] in_service_register;
    wire [7:0] highest_level_in_service;

    wire [7:0] interrupt;

    Control_Logic_8259 Control_Logic(
        .cascade_inout (cascade_inout),
        .slave_program_or_enable_buffer (slave_program_or_enable_buffer),

        .interrupt_acknowledge_n (interrupt_acknowledge_n),
        .interrupt_to_cpu (interrupt_to_cpu),

        .internal_data_bus (internal_data_bus),

        .write_initial_command_word_1 (write_initial_command_word_1),
        .write_initial_command_word_2_4 (write_initial_command_word_2_4),
        
        .write_operation_control_word_1 (write_operation_command_word_1),
        .write_operation_control_word_2 (write_operation_command_word_2),
        .write_operation_control_word_3 (write_operation_command_word_3),

        .read (read),
        .write (write_enable_n),

        .out_control_logic_data (out_control_logic_data),
        .control_logic_data (control_logic_data),

        .level_or_edge_toriggered_config (level_or_edge_toriggered),
        .special_fully_nest_config (special_fully_nest_config),

        .enable_read_register (enable_read_register),
        .read_register_isr_or_irr (read_register_isr_or_irr),

        .interrupt (interrupt),
        .highest_level_in_service (highest_level_in_service),

        .interrupt_mask (interrupt_mask),
        .interrupt_special_mask (interrupt_special_mask),

        .end_of_interrupt (end_of_interrupt),
        
        .priority_rotate (priority_rotate),

        .freeze (freeze),
        .latch_in_service (latch_in_service),

        .clear_interrupt_request (clear_interrupt_request)
    );

    Interrupt_Request_8259A Interrupt_Request(
        .level_or_edge_triggered_config (level_or_edge_toriggered),
        .freeze (freeze),

        .clear_interrupt_request (clear_interrupt_request),
        .interrupt_request_pin (interrupt_request),

        .interrupt_request_register (interrupt_request_register)
    );

    Priority_Resolver_8259A Priority_Resolver(
        .priority_rotate (priority_rotate),

        .interrupt_mask (interrupt_mask),
        .interrupt_special_mask (interrupt_special_mask),
        .special_fully_nest_config (special_fully_nest_config),

        .highest_level_in_service (highest_level_in_service),
        
        .interrupt_request_register (interrupt_request_register),
        .in_service_register (in_service_register),

        .interrupt (interrupt)
    );

    In_Service_8259A In_Service(
        .priority_rotate (priority_rotate),

        .interrupt_special_mask (interrupt_special_mask),
        .interrupt (interrupt),

        .latch_in_service (latch_in_service),
        .end_of_interrupt (end_of_interrupt),

        .in_service_register (in_service_register),
        .highest_level_in_service (highest_level_in_service)
    );

    DataBusBuffer DataBusBuffer(
        .out_control_logic_data (out_control_logic_data),

        .read (read),
        .address (address),

        .enable_read_register (enable_read_register),
        .read_register_isr_or_irr (read_register_isr_or_irr),

        .control_logic_data (control_logic_data),

        .interrupt_mask (interrupt_mask),
        .interrupt_request_register (interrupt_request_register),
        .in_service_register (in_service_register),

        .data_bus_out (data_bus)        
    );



endmodule
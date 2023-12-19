module testbench();

    reg out_control_logic_data;
    reg read;
    reg address;
    reg enable_read_register;
    reg read_register_isr_or_irr;
    reg [7:0] control_logic_data;
    reg [7:0] interrupt_mask;
    reg [7:0] interrupt_request_register;
    reg [7:0] in_service_register;
    reg slave_program_or_enable_buffer;
    wire [7:0] data_bus_out;


DataBusBuffer dbc(
    .out_control_logic_data (out_control_logic_data),
    .read (read),
    .address (address),
    .enable_read_register (enable_read_register),
    .read_register_isr_or_irr (read_register_isr_or_irr),
    .control_logic_data (control_logic_data),
    .interrupt_mask (interrupt_mask),
    .interrupt_request_register (interrupt_request_register),
    .in_service_register (in_service_register),
    .slave_program_or_enable_buffer (slave_program_or_enable_buffer),
    .data_bus_out (data_bus_out)
);


initial begin
    interrupt_request_register = 8'b00100000;

    enable_read_register = 1;
    read_register_isr_or_irr = 0;

    #10
    enable_read_register = 0;
    read_register_isr_or_irr = 0;
    
end

endmodule
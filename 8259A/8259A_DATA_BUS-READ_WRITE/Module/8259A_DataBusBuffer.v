/**
 * Module: DataBusBuffer
 * Description: This module implements a data bus buffer for the 8259A interrupt controller.
 *              It selects the appropriate data to be output on the data bus based on the control signals.
 * Inputs:
 *   - out_control_logic_data: Output control signal from the control logic indicating whether to output control logic data
 *   - read: Read control signal indicating whether a read operation is being performed
 *   - address: Address control signal indicating whether the address corresponds to the interrupt mask register
 *   - enable_read_register: Control signal indicating whether to enable reading from the interrupt request or in-service register
 *   - read_register_isr_or_irr: Control signal indicating whether to read from the in-service register or interrupt request register
 *   - control_logic_data: Data from the control logic
 *   - interrupt_mask: Data from the interrupt mask register
 *   - interrupt_request_register: Data from the interrupt request register
 *   - in_service_register: Data from the in-service register
 * Outputs:
 *   - data_bus_out: Output data on the data bus
 */

module DataBusBuffer(
    input out_control_logic_data, // Output control signal from the control logic indicating whether to output control logic data
    input read, // Read control signal indicating whether a read operation is being performed
    input address, // Address control signal indicating whether the address corresponds to the interrupt mask register
    input enable_read_register, // Control signal indicating whether to enable reading from the interrupt request or in-service register
    input read_register_isr_or_irr, // Control signal indicating whether to read from the in-service register or interrupt request register
    input [7:0] control_logic_data, // Data from the control logic
    input [7:0] interrupt_mask, // Data from the interrupt mask register
    input [7:0] interrupt_request_register, // Data from the interrupt request register
    input [7:0] in_service_register, // Data from the in-service register
    output reg [7:0] data_bus_out // Output data on the data bus
);

    always @* begin
        if (out_control_logic_data == 1'b1) begin
            data_bus_out = control_logic_data; // Output control logic data on the data bus
        end
        else if (read == 1'b0) begin
            data_bus_out = 8'bz; // Tri-state the data bus when read operation is not being performed
        end
        else if (address == 1'b1) begin
            data_bus_out = interrupt_mask; // Output interrupt mask data on the data bus
        end
        else if ((enable_read_register == 1'b1) && (read_register_isr_or_irr == 1'b0)) begin
            data_bus_out = interrupt_request_register; // Output interrupt request register data on the data bus
        end
        else if ((enable_read_register == 1'b1) && (read_register_isr_or_irr == 1'b1)) begin
            data_bus_out = in_service_register; // Output in-service register data on the data bus
        end
        else begin
            data_bus_out = 8'bz; // Tri-state the data bus for other cases
        end
    end

endmodule
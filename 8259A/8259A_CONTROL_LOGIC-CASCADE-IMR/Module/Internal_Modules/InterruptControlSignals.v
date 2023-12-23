/**
 * @module InterruptControlSignals
 * @brief This module implements the control signals for interrupt handling in the 8259A interrupt controller.
 *
 * @param write_initial_command_word_1 Input signal indicating whether the initial command word is being written.
 * @param interrupt Input signal representing the interrupt request lines.
 * @param end_of_acknowledge_sequence Input signal indicating the end of the acknowledge sequence.
 * @param end_of_poll_command Input signal indicating the end of the poll command.
 * @param next_control_state Input signal representing the next control state.
 * @param latch_in_service Input signal indicating whether the interrupt is being serviced.
 * @param control_state Input signal representing the current control state.
 * @param interrupt_to_cpu Output signal indicating whether an interrupt is to be sent to the CPU.
 * @param freeze Output signal indicating whether the interrupt controller is frozen.
 * @param clear_interrupt_request Output signal representing the interrupt request lines to be cleared.
 * @param acknowledge_interrupt Output signal representing the interrupt request lines to be acknowledged.
 * @param interrupt_when_ack1 Output signal representing the interrupt request lines when in ACK1 state.
 */
module InterruptControlSignals(
    input write_initial_command_word_1, // Input signal indicating whether the initial command word is being written.
    input [7:0] interrupt, // Input signal representing the interrupt request lines.
    input end_of_acknowledge_sequence, // Input signal indicating the end of the acknowledge sequence.
    input end_of_poll_command, // Input signal indicating the end of the poll command.
    input next_control_state, // Input signal representing the next control state.
    input latch_in_service, // Input signal indicating whether the interrupt is being serviced.
    input control_state, // Input signal representing the current control state.
    output reg interrupt_to_cpu, // Output signal indicating whether an interrupt is to be sent to the CPU.
    output reg freeze, // Output signal indicating whether the interrupt controller is frozen.
    output reg [7:0] clear_interrupt_request, // Output signal representing the interrupt request lines to be cleared.
    output reg [7:0] acknowledge_interrupt, // Output signal representing the interrupt request lines to be acknowledged.
    output reg [7:0] interrupt_when_ack1 // Output signal representing the interrupt request lines when in ACK1 state.
);
// Define parameters for control states
    localparam CTL_READY = 3'b000;
    localparam ACK1 = 3'b001;

    // Determine interrupt_to_cpu signal
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            interrupt_to_cpu <= 1'b0;
        else if (interrupt != 8'b00000000)
            interrupt_to_cpu <= 1'b1;
        else if (end_of_acknowledge_sequence == 1'b1)
            interrupt_to_cpu <= 1'b0;
        else if (end_of_poll_command == 1'b1)
            interrupt_to_cpu <= 1'b0;
        else
            interrupt_to_cpu <= interrupt_to_cpu;
    end

    // Determine freeze signal
    always @* begin
        if (next_control_state == CTL_READY)
            freeze <= 1'b0;
        else
            freeze <= 1'b1;
    end

    // Determine clear_interrupt_request signal
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            clear_interrupt_request = 8'b11111111;
        else if (latch_in_service == 1'b0)
            clear_interrupt_request = 8'b00000000;
        else
            clear_interrupt_request = interrupt;
    end

    // Determine acknowledge_interrupt signal
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            acknowledge_interrupt <= 8'b00000000;
        else if (end_of_acknowledge_sequence)
            acknowledge_interrupt <= 8'b00000000;
        else if (end_of_poll_command == 1'b1)
            acknowledge_interrupt <= 8'b00000000;
        else if (latch_in_service == 1'b1)
            acknowledge_interrupt <= interrupt;
        else
            acknowledge_interrupt <= acknowledge_interrupt;
    end

    // Determine interrupt_when_ack1 signal
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            interrupt_when_ack1 <= 8'b00000000;
        else if (control_state == ACK1)
            interrupt_when_ack1 <= interrupt;
        else
            interrupt_when_ack1 <= interrupt_when_ack1;
    end

endmodule
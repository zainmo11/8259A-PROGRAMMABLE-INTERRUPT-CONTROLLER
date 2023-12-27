/**
 * @file 8259A_Control_Logic.v
 * @brief This module implements the control logic for the 8259A Programmable Interrupt Controller (PIC).
 *
 * The Control_Logic_8259 module handles the initialization and operation of the PIC. It interfaces with other modules
 * such as CascadeSignals, AcknowledgeModule, InitializationCommandWordModule, Internal_Functions, InterruptControlSignals,
 * OperationControlWord1, OperationControlWord2, and OperationControlWord3.
 *
 * The module has various input and output ports for external communication, internal bus, registers, interrupt detection
 * logics, and interrupt control signals. It includes state machines to handle command states and control states. It also
 * implements the necessary logic for writing registers and command signals, as well as handling the acknowledge sequence
 * and initialization command words.
 */

`include "CascadeSignals.v"
`include "AcknowledgeModule.v"
`include "initializationCommandWord4.v"
`include "InitializationCommandWordModule1.v"
`include "Internal_Functions.v"
`include "InterruptControlSignals.v"
`include "OperationControlWord1.v"
`include "OperationControlWord2.v"
`include "OperationControlWord3.v"

module Control_Logic_8259 (
    // External input/output
    inout wire [2:0] cascade_inout,
    inout wire slave_program_or_enable_buffer,
    input wire interrupt_acknowledge_n,
    output reg interrupt_to_cpu,

    // Internal bus
    input wire [7:0] internal_data_bus,
    input wire write_initial_command_word_1,
    input wire write_initial_command_word_2_4,
    input wire write_operation_control_word_1,
    input wire write_operation_control_word_2,
    input wire write_operation_control_word_3,
    input wire read,
    input wire write,

    output reg out_control_logic_data,
    output reg [7:0] control_logic_data,

    // Registers to interrupt detecting logics
    output reg level_or_edge_toriggered_config,
    output reg special_fully_nest_config,

    // Registers to Read logics
    output reg enable_read_register,
    output reg read_register_isr_or_irr,

    // Signals from interrupt detectiong logics
    input wire [7:0] interrupt,
    input wire [7:0] highest_level_in_service,

    // Interrupt control signals
    output reg [7:0] interrupt_mask,
    output reg [7:0] interrupt_special_mask,
    output reg [7:0] end_of_interrupt,
    output reg [2:0] priority_rotate,
    output reg freeze,
    output reg latch_in_service,
    output reg [7:0] clear_interrupt_request
);


    // State
    // Define parameters for command states
    localparam CMD_READY = 2'b00;
    localparam WRITE_ICW2 = 2'b01;
    localparam WRITE_ICW3 = 2'b10;
    localparam WRITE_ICW4 = 2'b11;

    // Define parameters for control states
    localparam CTL_READY = 3'b000;
    localparam ACK1 = 3'b001;
    localparam ACK2 = 3'b010;
    localparam ACK3 = 3'b011;
    localparam POLL = 3'b100;
    localparam FINISH_CYCLE = 3'b101; 

    //
    // Cascade
    //
    reg   [2:0]   cascade_out;

    // Cascade slave id
    wire [2:0] cascade_id;
    wire cascade_io;
    
    assign cascade_inout = ~cascade_io ? cascade_out : 3'bz;
    assign cascade_id = cascade_inout;

    wire slave_program ;
    // Registers
    reg   [10:0]  interrupt_vector_address;
    reg           call_address_interval_4_or_8_config;
    reg           single_or_cascade_config;
    reg           set_icw4_config;
    reg   [7:0]   cascade_device_config;
    reg           buffered_mode_config;
    reg           buffered_master_or_slave_config;
    reg           auto_eoi_config;
    reg           u8086_or_mcs80_config;
    reg           special_mask_mode;
    reg           enable_special_mask_mode;
    reg           auto_rotate_mode;
    reg   [7:0]   acknowledge_interrupt;

    reg           cascade_slave;
    reg           cascade_slave_enable;
    reg           cascade_output_ack_2_3;
    reg [7:0] interrupt_when_ack1;
    // Command state machine
    reg [1:0] command_state;
    reg [1:0] next_command_state;

    reg prev_write;

    initial command_state = 0;

    wire nedge_write = prev_write & ~write;

    // Update command state based on write signals
    always @(write) begin
         if (nedge_write)
            command_state = next_command_state;
        if (write_initial_command_word_1 == 1'b1)
            next_command_state = WRITE_ICW2;
        else if (write_initial_command_word_2_4 == 1'b1) begin
            case (command_state)
                WRITE_ICW2: begin
                    if (single_or_cascade_config == 1'b0)
                        next_command_state = WRITE_ICW3;
                    else if (set_icw4_config == 1'b1)
                        next_command_state = WRITE_ICW4;
                    else
                        next_command_state = CMD_READY;
                end
                WRITE_ICW3: begin
                    if (set_icw4_config == 1'b1)
                        next_command_state = WRITE_ICW4;
                    else
                        next_command_state = CMD_READY;
                end
                WRITE_ICW4: begin
                    next_command_state = CMD_READY;
                end
                default: begin
                    next_command_state = CMD_READY;
                end
            endcase
        end

        prev_write = write;
    end


    // Writing registers/command signals
    wire    write_initial_command_word_2 = (command_state == WRITE_ICW2) & write_initial_command_word_2_4;
    wire    write_initial_command_word_3 = (command_state == WRITE_ICW3) & write_initial_command_word_2_4;
    wire    write_initial_command_word_4 = (command_state == WRITE_ICW4) & write_initial_command_word_2_4;
    wire    write_operation_control_word_1_registers = (command_state == CMD_READY) & write_operation_control_word_1;
    wire    write_operation_control_word_2_registers = (command_state == CMD_READY) & write_operation_control_word_2;
    wire    write_operation_control_word_3_registers = (command_state == CMD_READY) & write_operation_control_word_3;

    // Control state variables
    reg [2:0] next_control_state; // Next state of the control state machine
    reg [2:0] control_state; // Current state of the control state machine

    reg prev_interrupt_acknowledge_n; // Previous value of the interrupt_acknowledge_n signal
    reg prev_read_signal; // Previous value of the read signal

    wire ack_pulse_sense = prev_interrupt_acknowledge_n & ~interrupt_acknowledge_n; // Signal indicating the sense of an acknowledge pulse
    wire pedge_interrupt_acknowledge = ~prev_interrupt_acknowledge_n & interrupt_acknowledge_n; // Signal indicating the positive edge of the interrupt_acknowledge_n signal

    wire read_pos_edge = ~prev_read_signal & read; // Signal indicating the positive edge of the read signal

    // Control state machine
    always @(interrupt_acknowledge_n) begin
        case (control_state)
            CTL_READY: begin
                if ((write_operation_control_word_3_registers == 1'b1) && (internal_data_bus[2] == 1'b1))
                    next_control_state = POLL;
                else if (write_operation_control_word_2_registers == 1'b1)
                    next_control_state = CTL_READY;
                else if (~ack_pulse_sense)  // Sense for pulse
                    next_control_state = CTL_READY;
                else begin
                    next_control_state = ACK1;
                end
            end
            ACK1: begin
                if (~pedge_interrupt_acknowledge)
                    next_control_state = ACK1;
                else begin
                    next_control_state = ACK2;
                end
            end
            ACK2: begin
                if (~pedge_interrupt_acknowledge)
                    next_control_state = ACK2;
                else if (u8086_or_mcs80_config == 1'b0) begin
                    next_control_state = ACK3;
                end
                else begin
                    next_control_state = FINISH_CYCLE;
                end
            end
            ACK3: begin
                if (~pedge_interrupt_acknowledge)
                    next_control_state = ACK3;
                else begin
                    next_control_state = FINISH_CYCLE;
                end
            end
            POLL: begin
                if (~read_pos_edge)
                    next_control_state = POLL;
                else begin
                    next_control_state = CTL_READY;
                end
            end
            FINISH_CYCLE: begin
                next_control_state = CTL_READY;
            end
            default: begin
                next_control_state = CTL_READY;
            end
        endcase

        prev_interrupt_acknowledge_n <= interrupt_acknowledge_n;
        prev_read_signal <= read;
    end

    always @(next_control_state) begin
        if (write_initial_command_word_1 == 1'b1)
            control_state <= CTL_READY;
        else
            control_state <= next_control_state;
    end

    // Latch in service register signal
    always @(interrupt_acknowledge_n) begin
        if (write_initial_command_word_1 == 1'b1)
            latch_in_service = 1'b0;
        else if ((control_state == CTL_READY) && (next_control_state == POLL))
            latch_in_service = 1'b1;
        else if (cascade_slave == 1'b0)
            latch_in_service = (control_state == CTL_READY) & (next_control_state != CTL_READY);
        else
            latch_in_service = (control_state == ACK2) & (cascade_slave_enable == 1'b1) & (ack_pulse_sense == 1'b1);
    end
    // End of acknowledge sequence
    wire    end_of_acknowledge_sequence =  (control_state != POLL) & (control_state != CTL_READY) & (next_control_state == CTL_READY);
    wire    end_of_poll_command         =  (control_state == POLL) & (control_state != CTL_READY) & (next_control_state == CTL_READY);

    //
    // Initialization command word 1
    //
    // error 1 <-------------------------
     InitializationCommandWord1 initializationCommandWordInstance(
        .write_initial_command_word_1(write_initial_command_word_1),
        .internal_data_bus(internal_data_bus),
        .interrupt_vector_address(interrupt_vector_address[2:0]),
        .level_or_edge_triggered_config(level_or_edge_toriggered_config),
        .call_address_interval_4_or_8_config(call_address_interval_4_or_8_config),
        .single_or_cascade_config(single_or_cascade_config),
        .set_icw4_config(set_icw4_config)
    );

    //
    // Initialization command word 2
    //

    // A15-A8 (MCS-80) or T7-T3 (8086, 8088)
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            interrupt_vector_address[10:3] <= 3'b000;
        else if (write_initial_command_word_2 == 1'b1)
            interrupt_vector_address[10:3] <= internal_data_bus;
        else
            interrupt_vector_address[10:3] <= interrupt_vector_address[10:3];
    end

    //
    // Initialization command word 3
    //

    // S7-S0 (MASTER) or ID2-ID0 (SLAVE)
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            cascade_device_config <= 8'b00000000;
        else if (write_initial_command_word_3 == 1'b1)
            cascade_device_config <= internal_data_bus;
        else
            cascade_device_config <= cascade_device_config;
    end

    //
    // Initialization command word 4
    //

     InitializationCommandWord4 initializationCommandWord4Instance(
        .write_initial_command_word_1(write_initial_command_word_1),
        .write_initial_command_word_4(write_initial_command_word_4),
        .internal_data_bus(internal_data_bus[4:0]),
        .special_fully_nest_config(special_fully_nest_config),
        .buffered_mode_config(buffered_mode_config),
        .slave_program(slave_program),
        .buffered_master_or_slave_config(buffered_master_or_slave_config),
        .auto_eoi_config(auto_eoi_config),
        .u8086_or_mcs80_config(u8086_or_mcs80_config)
    );

    //
    // Operation control word 1
    //

    OperationControlWord1 operationControlWord1Instance(
        .write_initial_command_word_1(write_initial_command_word_1),
        .write_operation_control_word_1_registers(write_operation_control_word_1_registers),
        .special_mask_mode(special_mask_mode),
        .internal_data_bus(internal_data_bus[7:0]),
        .interrupt_mask(interrupt_mask[7:0]),
        .interrupt_special_mask(interrupt_special_mask[7:0])
    );

    //
    // Operation control word 2
    //

    OperationControlWord2 operationControlWord2Instance(
        .write_initial_command_word_1(write_initial_command_word_1),
        .auto_eoi_config(auto_eoi_config),
        .end_of_acknowledge_sequence(end_of_acknowledge_sequence),
        .acknowledge_interrupt(acknowledge_interrupt),
        .write_operation_control_word_2(write_operation_control_word_2),
        .internal_data_bus(internal_data_bus),
        .highest_level_in_service(highest_level_in_service),
        .end_of_interrupt(end_of_interrupt),
        .auto_rotate_mode(auto_rotate_mode),
        .priority_rotate(priority_rotate),
    );

    //
    // Operation control word 3
    //

      OperationControlWord3 operationControlWord3Instance(
        .write_initial_command_word_1(write_initial_command_word_1),
        .write_operation_control_word_3_registers(write_operation_control_word_3_registers),
        .internal_data_bus(internal_data_bus),
        .special_mask_mode(special_mask_mode),
        .enable_read_register(enable_read_register),
        .read_register_isr_or_irr(read_register_isr_or_irr)
    );

    //
    // Cascade signals
    //

        CascadeSignals cascadeSignalsInstance(
        .single_or_cascade_config(single_or_cascade_config),
        .buffered_mode_config(buffered_mode_config),
        .slave_program(slave_program),
        .buffered_master_or_slave_config(buffered_master_or_slave_config),
        .cascade_device_config(cascade_device_config),
        .cascade_id(cascade_id),
        .acknowledge_interrupt(acknowledge_interrupt),
        .control_state(control_state),
        .cascade_slave(cascade_slave),
        .cascade_io(cascade_io),
        .cascade_slave_enable(cascade_slave_enable),
        .cascade_output_ack_2_3(cascade_output_ack_2_3),
        .cascade_out(cascade_out)
    );

    //
    // Interrupt control signals
    //

    InterruptControlSignals interruptControlSignalsInstance(
        .write_initial_command_word_1(write_initial_command_word_1),
        .interrupt(interrupt),
        .end_of_acknowledge_sequence(end_of_acknowledge_sequence),
        .end_of_poll_command(end_of_poll_command),
        .next_control_state(next_control_state),
        .latch_in_service(latch_in_service),
        .control_state(control_state),
        .interrupt_to_cpu(interrupt_to_cpu),
        .freeze(freeze),
        .clear_interrupt_request(clear_interrupt_request),
        .acknowledge_interrupt(acknowledge_interrupt),
        .interrupt_when_ack1(interrupt_when_ack1)
    );


    // control_logic_data

    AcknowledgeModule acknowledgeModuleInstance(
        .interrupt_acknowledge_n(interrupt_acknowledge_n),
        .cascade_slave(cascade_slave),
        .u8086_or_mcs80_config(u8086_or_mcs80_config),
        .control_state(control_state),
        .cascade_output_ack_2_3(cascade_output_ack_2_3),
        .interrupt_when_ack1(interrupt_when_ack1),
        .acknowledge_interrupt(acknowledge_interrupt),
        .call_address_interval_4_or_8_config(call_address_interval_4_or_8_config),
        .interrupt_vector_address(interrupt_vector_address),
        .read(read),
        .out_control_logic_data(out_control_logic_data),
        .control_logic_data(control_logic_data)
    );
endmodule

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
    output reg level_or_edge_triggered_config,
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

    `include "Internal_Functions.v"

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

    // Command state machine
    reg [1:0] command_state;
    // reg [1:0] next_command_state;

    reg [3:0] next_command_state;

reg prev_write;

initial command_state = 0;

// localparam CMD_READY = 2'b00;
//     localparam WRITE_ICW2 = 2'b01;
//     localparam WRITE_ICW3 = 2'b10;
//     localparam WRITE_ICW4 = 2'b11;

wire nedge_write = prev_write & ~write;

  // DONE - State machine
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
    reg next_control_state; // Next state of the control state machine
    reg control_state; // Current state of the control state machine

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
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            interrupt_vector_address <= internal_data_bus[7:5];
        else
            interrupt_vector_address <= interrupt_vector_address; // Keep the value unchanged
    end

    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            level_or_edge_triggered_config <= internal_data_bus[3];
        else
            level_or_edge_triggered_config <= level_or_edge_triggered_config; // Keep the value unchanged
    end

    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            call_address_interval_4_or_8_config <= internal_data_bus[2];
        else
            call_address_interval_4_or_8_config <= call_address_interval_4_or_8_config; // Keep the value unchanged
    end

    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            single_or_cascade_config <= internal_data_bus[1];
        else
            single_or_cascade_config <= single_or_cascade_config; // Keep the value unchanged
    end

    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            set_icw4_config <= internal_data_bus[0];
        else
            set_icw4_config <= set_icw4_config; // Keep the value unchanged
    end





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

    // SFNM: Special Fully Nested Mode
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            special_fully_nest_config <= 1'b0; // Set to 0 when writing initial command word 1.
        else if (write_initial_command_word_4 == 1'b1)
            special_fully_nest_config <= internal_data_bus[4]; // Set based on bit 4 of internal data bus when writing initial command word 4.
        // Otherwise, retain previous value.
    end

    // BUF: Buffered Mode
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            buffered_mode_config <= 1'b0; // Set to 0 when writing initial command word 1.
        else if (write_initial_command_word_4 == 1'b1)
            buffered_mode_config <= internal_data_bus[3]; // Set based on bit 3 of internal data bus when writing initial command word 4.
        // Otherwise, retain previous value.
    end

    // SP/EN IO: Slave Program or Enable Buffer

    assign  slave_program_or_enable_buffer = buffered_mode_config ? ~buffered_mode_config : 1'bz;
    assign slave_program = slave_program_or_enable_buffer;

    // M/S: Buffered Master or Slave Configuration
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            buffered_master_or_slave_config <= 1'b0; // Set to 0 when writing initial command word 1.
        else if (write_initial_command_word_4 == 1'b1)
            buffered_master_or_slave_config <= internal_data_bus[2]; // Set based on bit 2 of internal data bus when writing initial command word 4.
        // Otherwise, retain previous value.
    end

    // AEOI: Auto EOI Configuration
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            auto_eoi_config <= 1'b0; // Set to 0 when writing initial command word 1.
        else if (write_initial_command_word_4 == 1'b1)
            auto_eoi_config <= internal_data_bus[1]; // Set based on bit 1 of internal data bus when writing initial command word 4.
        // Otherwise, retain previous value.
    end

    // uPM: u8086 or MCS80 Configuration
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            u8086_or_mcs80_config <= 1'b0; // Set to 0 when writing initial command word 1.
        else if (write_initial_command_word_4 == 1'b1)
            u8086_or_mcs80_config <= internal_data_bus[0]; // Set based on bit 0 of internal data bus when writing initial command word 4.
        // Otherwise, retain previous value.
    end

    //
    // Operation control word 1
    //

    // IMR
    always @* begin
        if (write_initial_command_word_1 == 1'b1) // If write_initial_command_word_1 is high
            interrupt_mask <= 8'b11111111; // Set interrupt_mask to all ones
        else if ((write_operation_control_word_1_registers == 1'b1) && (special_mask_mode == 1'b0)) // If write_operation_control_word_1_registers is high and special_mask_mode is low
            interrupt_mask <= internal_data_bus; // Set interrupt_mask to the value of internal_data_bus
        else
            interrupt_mask <= interrupt_mask; // Keep interrupt_mask unchanged
    end

    // Special mask
    always @* begin
        if (write_initial_command_word_1 == 1'b1) // If write_initial_command_word_1 is high
            interrupt_special_mask <= 8'b00000000; // Set interrupt_special_mask to all zeros
        else if (special_mask_mode == 1'b0) // If special_mask_mode is low
            interrupt_special_mask <= 8'b00000000; // Set interrupt_special_mask to all zeros
        else if (write_operation_control_word_1_registers  == 1'b1) // If write_operation_control_word_1_registers is high
            interrupt_special_mask <= internal_data_bus; // Set interrupt_special_mask to the value of internal_data_bus
        else
            interrupt_special_mask <= interrupt_special_mask; // Keep interrupt_special_mask unchanged
    end

    //
    // Operation control word 2
    //
    // End of interrupt
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            end_of_interrupt = 8'b11111111; // Set end_of_interrupt to all ones if write_initial_command_word_1 is high.
        else if ((auto_eoi_config == 1'b1) && (end_of_acknowledge_sequence == 1'b1))
            end_of_interrupt = acknowledge_interrupt; // Set end_of_interrupt to acknowledge_interrupt if auto_eoi_config and end_of_acknowledge_sequence are high.
        else if (write_operation_control_word_2 == 1'b1) begin
            casez (internal_data_bus[6:5])
                2'b01:   end_of_interrupt = highest_level_in_service; // Rotate on non specific EOI
                2'b11:   end_of_interrupt = num2bit(internal_data_bus[2:0]); // Specific EOI
                default: end_of_interrupt = 8'b00000000; // Set end_of_interrupt to all zeros for other cases.
            endcase
        end
        else
            end_of_interrupt = 8'b00000000; // Set end_of_interrupt to all zeros if none of the conditions are met.
    end

    // Auto rotate mode
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            auto_rotate_mode <= 1'b0; // Set auto_rotate_mode to 0 if write_initial_command_word_1 is high.
        else if (write_operation_control_word_2 == 1'b1) begin
            casez (internal_data_bus[7:5])
                3'b000:  auto_rotate_mode <= 1'b0; // Set auto_rotate_mode to 0 if internal_data_bus[7:5] is 3'b000.
                3'b100:  auto_rotate_mode <= 1'b1; // Set auto_rotate_mode to 1 if internal_data_bus[7:5] is 3'b100.
                default: auto_rotate_mode <= auto_rotate_mode; // Keep auto_rotate_mode unchanged for other cases.
            endcase
        end
        else
            auto_rotate_mode <= auto_rotate_mode; // Keep auto_rotate_mode unchanged if none of the conditions are met.
    end

    // Rotate
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            priority_rotate <= 3'b111; // Set priority_rotate to 3'b111 if write_initial_command_word_1 is high.
        else if ((auto_rotate_mode == 1'b1) && (end_of_acknowledge_sequence == 1'b1))
            priority_rotate <= bit2num(acknowledge_interrupt); // Set priority_rotate to bit2num if auto_rotate_mode and end_of_acknowledge_sequence are high.
        else if (write_operation_control_word_2 == 1'b1) begin
            casez (internal_data_bus[7:5])
                3'b101:  priority_rotate <= bit2num(highest_level_in_service); // Set priority_rotate to bit2num if internal_data_bus[7:5] is 3'b101.
                3'b11?:  priority_rotate <= internal_data_bus[2:0]; // Set specific priority
                default: priority_rotate <= priority_rotate; // Keep priority_rotate unchanged for other cases.
            endcase
        end
        else
            priority_rotate <= priority_rotate; // Keep priority_rotate unchanged if none of the conditions are met.
    end
    //
    // Operation control word 3
    //

    // ESMM / SMM
    always @* begin
        if (write_initial_command_word_1 == 1'b1) begin
            special_mask_mode <= 1'b0; // Set special mask mode to 0 when writing initial command word 1.
        end
        else if ((write_operation_control_word_3_registers == 1'b1) && (internal_data_bus[6] == 1'b1)) begin
            special_mask_mode <= internal_data_bus[5]; // Set special mask mode based on internal data bus when writing operation control word 3 registers.
        end
        else begin
            special_mask_mode <= special_mask_mode; // Maintain current special mask mode.
        end
    end

    // RR/RIS
    always @* begin
        if (write_initial_command_word_1 == 1'b1) begin
            enable_read_register     <= 1'b1; // Enable read register when writing initial command word 1.
            read_register_isr_or_irr <= 1'b0; // Set read register for ISR or IRR to 0 when writing initial command word 1.
        end
        else if (write_operation_control_word_3_registers == 1'b1) begin
            enable_read_register     <= internal_data_bus[1]; // Set enable read register based on internal data bus when writing operation control word 3 registers.
            read_register_isr_or_irr <= internal_data_bus[0]; // Set read register for ISR or IRR based on internal data bus when writing operation control word 3 registers.
        end
        else begin
            enable_read_register     <= enable_read_register; // Maintain current enable read register.
            read_register_isr_or_irr <= read_register_isr_or_irr; // Maintain current read register for ISR or IRR.
        end
    end
    
    
    //
    // Cascade signals
    //

   // Select master/slave
    always @* begin
        if (single_or_cascade_config == 1'b1)
            /*
            single_or_cascade_config = 1, Single Mode
            single_or_cascade_config = 0, Cascade Mode
            */
            cascade_slave = 1'b0; // Device operates in single mode
        else if (buffered_mode_config == 1'b0)
            /*
            buffered_mode_config = 0, Non buffered mode, SP pin decides master or slave
            buffered_mode_config = 1, Master or slave decision in ICW4
            */
            cascade_slave = ~slave_program; // Device operates in cascade mode, select master or slave based on slave_program
        else
            cascade_slave = ~buffered_master_or_slave_config; // Device operates in cascade mode, select master or slave based on buffered_master_or_slave_config
    end

    // Cascade port I/O
    assign cascade_io = cascade_slave;

    // Cascade signals (slave)
    always @* begin
        if (cascade_slave == 1'b0)
            cascade_slave_enable = 1'b0; // Cascade slave is not enabled
        else if (cascade_device_config[2:0] != cascade_id)
            cascade_slave_enable = 1'b0; // Cascade slave is not enabled
        else
            cascade_slave_enable = 1'b1; // Cascade slave is enabled
    end

    // Cascade signals (master)
    assign interrupt_from_slave_device = (acknowledge_interrupt & cascade_device_config) != 8'b00000000;

    // Output ACK2 and ACK3
    always @* begin
        // Single Mode
        if (single_or_cascade_config == 1'b1)
            cascade_output_ack_2_3 = 1'b1; // Output ACK2 and ACK3
        // You are slave in cascade mode
        else if (cascade_slave_enable == 1'b1)
            cascade_output_ack_2_3 = 1'b1; // Output ACK2 and ACK3

        // Master and there is no interrupt from slave
        else if ((cascade_slave == 1'b0) && (interrupt_from_slave_device == 1'b0))
            cascade_output_ack_2_3 = 1'b1; // Output ACK2 and ACK3
        
        // Master and have an interrupt from slave
        else
            cascade_output_ack_2_3 = 1'b0;
    end

    // Output slave ID
    always @* begin
        if (cascade_slave == 1'b1)
            cascade_out <= 3'bz; // Slave ID is 000
        else if ((control_state != ACK1) && (control_state != ACK2) && (control_state != ACK3))
            cascade_out <= 3'bz; // Slave ID is 000
        else if (interrupt_from_slave_device == 1'b0)
            cascade_out <= 3'bz; // Slave ID is 000
        else
            cascade_out <= bit2num(acknowledge_interrupt); // Convert acknowledge_interrupt to binary and assign as slave ID
    end
    //
    // Interrupt control signals
    //
    reg   [7:0]   interrupt_when_ack1;

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



    // control_logic_data
    always @(interrupt_acknowledge_n) begin
        if (interrupt_acknowledge_n == 1'b0) begin
            // Acknowledge
            case (control_state)
                CTL_READY: begin
                    if (cascade_slave == 1'b0) begin
                        if (u8086_or_mcs80_config == 1'b0) begin
                            out_control_logic_data = 1'b1;
                            control_logic_data     = 8'b11001101; // Control logic data for u8086 configuration
                        end
                        else begin
                            out_control_logic_data = 1'b0;
                            control_logic_data     = 8'bz; // Control logic data for MCS-80 configuration
                        end
                    end
                    else begin
                        out_control_logic_data = 1'b0;
                        control_logic_data     = 8'bz; // Control logic data for cascade slave
                    end
                end
                ACK1: begin
                    if (cascade_slave == 1'b0) begin
                        if (u8086_or_mcs80_config == 1'b0) begin
                            out_control_logic_data = 1'b1;
                            control_logic_data     = 8'b11001101; // Control logic data for u8086 configuration
                        end
                        else begin
                            out_control_logic_data = 1'b0;
                            control_logic_data     = 8'bz; // Control logic data for MCS-80 configuration
                        end
                    end
                    else begin
                        out_control_logic_data = 1'b0;
                        control_logic_data     = 8'bz; // Control logic data for cascade slave
                    end
                end
                ACK2: begin
                    if (cascade_output_ack_2_3 == 1'b1) begin
                        out_control_logic_data = 1'b1;

                        if (cascade_slave == 1'b1)
                            control_logic_data[2:0] = bit2num(interrupt_when_ack1);
                        else
                            control_logic_data[2:0] = bit2num(acknowledge_interrupt);

                        if (u8086_or_mcs80_config == 1'b0) begin
                            if (call_address_interval_4_or_8_config == 1'b0)
                                control_logic_data = {interrupt_vector_address[2:1], control_logic_data[2:0], 3'b000}; // Control logic data for 4-byte call address interval
                            else
                                control_logic_data = {interrupt_vector_address[2:0], control_logic_data[2:0], 2'b00}; // Control logic data for 8-byte call address interval
                        end
                        else begin
                            control_logic_data = {interrupt_vector_address[10:6], control_logic_data[2:0]}; // Control logic data for 8086 configuration
                        end
                    end
                    else begin
                        out_control_logic_data = 1'b0;
                        control_logic_data     = 8'bz; // Control logic data when cascade_output_ack_2_3 is not active
                    end
                end
                ACK3: begin
                    if (cascade_output_ack_2_3 == 1'b1) begin
                        out_control_logic_data = 1'b1;
                        control_logic_data     = interrupt_vector_address[10:3]; // Control logic data for ACK3 state
                    end
                    else begin
                        out_control_logic_data = 1'b0;
                        control_logic_data     = 8'bz; // Control logic data when cascade_output_ack_2_3 is not active
                    end
                end
                default: begin
                    out_control_logic_data = 1'b0;
                    control_logic_data     = 8'bz; // Control logic data for default state
                end
            endcase
        end
        else if ((control_state == POLL) && (read == 1'b1)) begin
            // Poll command
            out_control_logic_data = 1'b1;
            if (acknowledge_interrupt == 8'b00000000)
                control_logic_data = 8'bz; // Control logic data when acknowledge_interrupt is 0
            else begin
                control_logic_data[7:3] = 5'b10000; // Control logic data for non-zero acknowledge_interrupt
                control_logic_data[2:0] = bit2num(acknowledge_interrupt);
            end
        end
        else begin
            // Nothing
            out_control_logic_data = 1'b0;
            control_logic_data     = 8'bz; // Control logic data when no conditions are met
        end
    end
endmodule

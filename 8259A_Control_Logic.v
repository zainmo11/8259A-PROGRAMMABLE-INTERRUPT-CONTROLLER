module 8259_Control_Logic (
    // External input/output
    inout   wire   [2:0]   cascade_inout,

    input   wire           slave_program_n,
    output  wire           slave_program_or_enable_buffer,

    input   wire           interrupt_acknowledge_n,
    output  reg           interrupt_to_cpu,

    // Internal bus
    input   wire   [7:0]   internal_data_bus,
    input   wire           write_initial_command_word_1,
    input   wire           write_initial_command_word_2_4,
    input   wire           write_operation_control_word_1,
    input   wire           write_operation_control_word_2,
    input   wire           write_operation_control_word_3,

    input   wire           read,
    output  reg           out_control_logic_data,
    output  reg   [7:0]   control_logic_data,

    // Registers to interrupt detecting logics
    output  reg           level_or_edge_toriggered_config,
    output  reg           special_fully_nest_config,

    // Registers to Read logics
    output  reg           enable_read_register,
    output  reg           read_register_isr_or_irr,

    // Signals from interrupt detectiong logics
    input   wire   [7:0]   interrupt,
    input   wire   [7:0]   highest_level_in_service,

    // Interrupt control signals
    output  reg   [7:0]   interrupt_mask,
    output  reg   [7:0]   interrupt_special_mask,
    output  reg   [7:0]   end_of_interrupt,
    output  reg   [2:0]   priority_rotate,
    output  reg           freeze,
    output  reg           latch_in_service,
    output  reg   [7:0]   clear_interrupt_request
);


    `include "CommonPackage.v"


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


    //
    // Cascade
    //
    reg   [2:0]   cascade_out;
    wire           cascade_io;


    //
    // Write command state
    //
    reg command_state;
    reg next_command_state;

    // State machine
    always @* begin
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
        else
            next_command_state = command_state;
    end


    always @* begin
        command_state <= next_command_state;
    end

    // assign command_state = next_command_state;    // <----------- 


    // Writing registers/command signals
    wire    write_initial_command_word_2 = (command_state == WRITE_ICW2) & write_initial_command_word_2_4;
    wire    write_initial_command_word_3 = (command_state == WRITE_ICW3) & write_initial_command_word_2_4;
    wire    write_initial_command_word_4 = (command_state == WRITE_ICW4) & write_initial_command_word_2_4;
    wire    write_operation_control_word_1_registers = (command_state == CMD_READY) & write_operation_control_word_1;
    wire    write_operation_control_word_2_registers = (command_state == CMD_READY) & write_operation_control_word_2;
    wire    write_operation_control_word_3_registers = (command_state == CMD_READY) & write_operation_control_word_3;

    //
    // Service control state
    //
    reg next_control_state;
    reg control_state;

    // Detect ACK edge
    reg   prev_interrupt_acknowledge_n;

    always @* begin
            prev_interrupt_acknowledge_n <= interrupt_acknowledge_n;            // <-------------------------
    end

    wire    nedge_interrupt_acknowledge =  prev_interrupt_acknowledge_n & ~interrupt_acknowledge_n;
    wire    pedge_interrupt_acknowledge = ~prev_interrupt_acknowledge_n &  interrupt_acknowledge_n;


    // Detect read signal edge
    reg   prev_read_signal;

    always @* begin
        prev_read_signal <= read;                                  // <-------------------------
    end

    wire    nedge_read_signal = prev_read_signal & ~read;

    // State machine
    always @* begin
        case (control_state)
            CTL_READY: begin
                if ((write_operation_control_word_3_registers == 1'b1) && (internal_data_bus[2] == 1'b1))
                    next_control_state = POLL;
                else if (write_operation_control_word_2_registers == 1'b1)
                    next_control_state = CTL_READY;
                else if (nedge_interrupt_acknowledge == 1'b0)
                    next_control_state = CTL_READY;
                else
                    next_control_state = ACK1;
            end
            ACK1: begin
                if (pedge_interrupt_acknowledge == 1'b0)
                    next_control_state = ACK1;
                else
                    next_control_state = ACK2;
            end
            ACK2: begin
                if (pedge_interrupt_acknowledge == 1'b0)
                    next_control_state = ACK2;
                else if (u8086_or_mcs80_config == 1'b0)
                    next_control_state = ACK3;
                else
                    next_control_state = CTL_READY;
            end
            ACK3: begin
                if (pedge_interrupt_acknowledge == 1'b0)
                    next_control_state = ACK3;
                else
                    next_control_state = CTL_READY;
            end
            POLL: begin
                if (nedge_read_signal == 1'b0)
                    next_control_state = POLL;
                else
                    next_control_state = CTL_READY;
            end
            default: begin
                next_control_state = CTL_READY;
            end
        endcase
    end

    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            control_state <= CTL_READY;
        else
            control_state <= next_control_state;
    end

    // Latch in service register signal
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            latch_in_service = 1'b0;
        else if ((control_state == CTL_READY) && (next_control_state == POLL))
            latch_in_service = 1'b1;
        else if (cascade_slave == 1'b0)
            latch_in_service = (control_state == CTL_READY) & (next_control_state != CTL_READY);
        else
            latch_in_service = (control_state == ACK2) & (cascade_slave_enable == 1'b1) & (nedge_interrupt_acknowledge == 1'b1);
    end

    // End of acknowledge sequence
    wire    end_of_acknowledge_sequence =  (control_state != POLL) & (control_state != CTL_READY) & (next_control_state == CTL_READY);
    wire    end_of_poll_command         =  (control_state == POLL) & (control_state != CTL_READY) & (next_control_state == CTL_READY);

    //
    // Initialization command word 1
    //
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            interrupt_vector_address[2:0] <= internal_data_bus[7:5];
        else
            interrupt_vector_address[2:0] <= interrupt_vector_address[2:0];
    end

    // LTIM
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            level_or_edge_toriggered_config <= internal_data_bus[3];
        else
            level_or_edge_toriggered_config <= level_or_edge_toriggered_config;
    end

    // ADI
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            call_address_interval_4_or_8_config <= internal_data_bus[2];
        else
            call_address_interval_4_or_8_config <= call_address_interval_4_or_8_config;
    end

    // SNGL
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            single_or_cascade_config <= internal_data_bus[1];
        else
            single_or_cascade_config <= single_or_cascade_config;
    end

    // IC4
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            set_icw4_config <= internal_data_bus[0];
        else
            set_icw4_config <= set_icw4_config;
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
    // SFNM
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            special_fully_nest_config <= 1'b0;
        else if (write_initial_command_word_4 == 1'b1)
            special_fully_nest_config <= internal_data_bus[4];
        else
            special_fully_nest_config <= special_fully_nest_config;
    end

    // BUF
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            buffered_mode_config <= 1'b0;
        else if (write_initial_command_word_4 == 1'b1)
            buffered_mode_config <= internal_data_bus[3];
        else
            buffered_mode_config <= buffered_mode_config;
    end

    assign  slave_program_or_enable_buffer = ~buffered_mode_config;

    // M/S
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            buffered_master_or_slave_config <= 1'b0;
        else if (write_initial_command_word_4 == 1'b1)
            buffered_master_or_slave_config <= internal_data_bus[2];
        else
            buffered_master_or_slave_config <= buffered_master_or_slave_config;
    end

    // AEOI
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            auto_eoi_config <= 1'b0;
        else if (write_initial_command_word_4 == 1'b1)
            auto_eoi_config <= internal_data_bus[1];
        else
            auto_eoi_config <= auto_eoi_config;
    end

    // uPM
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            u8086_or_mcs80_config <= 1'b0;
        else if (write_initial_command_word_4 == 1'b1)
            u8086_or_mcs80_config <= internal_data_bus[0];
        else
            u8086_or_mcs80_config <= u8086_or_mcs80_config;
    end

    //
    // Operation control word 1
    //
    // IMR
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            interrupt_mask <= 8'b11111111;
        else if ((write_operation_control_word_1_registers == 1'b1) && (special_mask_mode == 1'b0))
            interrupt_mask <= internal_data_bus;
        else
            interrupt_mask <= interrupt_mask;
    end

    // Special mask
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            interrupt_special_mask <= 8'b00000000;
        else if (special_mask_mode == 1'b0)
            interrupt_special_mask <= 8'b00000000;
        else if (write_operation_control_word_1_registers  == 1'b1)
            interrupt_special_mask <= internal_data_bus;
        else
            interrupt_special_mask <= interrupt_special_mask;
    end

    //
    // Operation control word 2
    //
    // End of interrupt
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            end_of_interrupt = 8'b11111111;
        else if ((auto_eoi_config == 1'b1) && (end_of_acknowledge_sequence == 1'b1))
            end_of_interrupt = acknowledge_interrupt;
        else if (write_operation_control_word_2 == 1'b1) begin
            case (internal_data_bus[6:5])
                2'b01:   end_of_interrupt = highest_level_in_service;
                2'b11:   end_of_interrupt = num2bit(internal_data_bus[2:0]);
                default: end_of_interrupt = 8'b00000000;
            endcase
        end
        else
            end_of_interrupt = 8'b00000000;
    end

    // Auto rotate mode
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            auto_rotate_mode <= 1'b0;
        else if (write_operation_control_word_2 == 1'b1) begin
            case (internal_data_bus[7:5])
                3'b000:  auto_rotate_mode <= 1'b0;
                3'b100:  auto_rotate_mode <= 1'b1;
                default: auto_rotate_mode <= auto_rotate_mode;
            endcase
        end
        else
            auto_rotate_mode <= auto_rotate_mode;
    end

    // Rotate
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            priority_rotate <= 3'b111;
        else if ((auto_rotate_mode == 1'b1) && (end_of_acknowledge_sequence == 1'b1))
            priority_rotate <= bit2num(acknowledge_interrupt);
        else if (write_operation_control_word_2 == 1'b1) begin
            case (internal_data_bus[7:5])
                3'b101:  priority_rotate <= bit2num(highest_level_in_service);
                3'b11?:  priority_rotate <= internal_data_bus[2:0];
                default: priority_rotate <= priority_rotate;
            endcase
        end
        else
            priority_rotate <= priority_rotate;
    end

    //
    // Operation control word 3
    //
    // ESMM / SMM
    always @* begin
        if (write_initial_command_word_1 == 1'b1) begin
            special_mask_mode        <= 1'b0;
        end
        else if ((write_operation_control_word_3_registers == 1'b1) && (internal_data_bus[6] == 1'b1)) begin
            special_mask_mode        <= internal_data_bus[5];
        end
        else begin
            special_mask_mode        <= special_mask_mode;
        end
    end

    // RR/RIS
    always @* begin
        if (write_initial_command_word_1 == 1'b1) begin
            enable_read_register     <= 1'b1;
            read_register_isr_or_irr <= 1'b0;
        end
        else if (write_operation_control_word_3_registers == 1'b1) begin
            enable_read_register     <= internal_data_bus[1];
            read_register_isr_or_irr <= internal_data_bus[0];
        end
        else begin
            enable_read_register     <= enable_read_register;
            read_register_isr_or_irr <= read_register_isr_or_irr;
        end
    end

    //
    // Cascade signals
    //
    // Select master/slave
    always @* begin
        if (single_or_cascade_config == 1'b1)
            cascade_slave = 1'b0;
        else if (buffered_mode_config == 1'b0)
            cascade_slave = ~slave_program_n;
        else
            cascade_slave = ~buffered_master_or_slave_config;
    end

    // Cascade port I/O
    assign cascade_io = cascade_slave;

    //
    // Cascade signals (slave)
    //
    always @* begin
        if (cascade_slave == 1'b0)
            cascade_slave_enable = 1'b0;
        else if (cascade_device_config[2:0] != cascade_inout)
            cascade_slave_enable = 1'b0;
        else
            cascade_slave_enable = 1'b1;
    end

    //
    // Cascade signals (master)
    //
    wire    interrupt_from_slave_device = (acknowledge_interrupt & cascade_device_config) != 8'b00000000;

    // output ACK2 and ACK3
    always @* begin
        if (single_or_cascade_config == 1'b1)
            cascade_output_ack_2_3 = 1'b1;
        else if (cascade_slave_enable == 1'b1)
            cascade_output_ack_2_3 = 1'b1;
        else if ((cascade_slave == 1'b0) && (interrupt_from_slave_device == 1'b0))
            cascade_output_ack_2_3 = 1'b1;
        else
            cascade_output_ack_2_3 = 1'b0;
    end

    // Output slave id
    always @* begin
        if (cascade_slave == 1'b1)
            cascade_out <= 3'b000 ;
        else if ((control_state != ACK1) && (control_state != ACK2) && (control_state != ACK3))
            cascade_out <= 3'b000;
        else if (interrupt_from_slave_device == 1'b0)
            cascade_out <= 3'b000;
        else
            cascade_out <= bit2num(acknowledge_interrupt);
    end


assign cascade_inout = ~cascade_io ? cascade_out : 3'bz;

    //
    // Interrupt control signals
    //
    // INT
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

    // freeze
    always @* begin
    if (next_control_state == CTL_READY)
            freeze <= 1'b0;
        else
            freeze <= 1'b1;
    end

    // clear_interrupt_request
    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            clear_interrupt_request = 8'b11111111;
        else if (latch_in_service == 1'b0)
            clear_interrupt_request = 8'b00000000;
        else
            clear_interrupt_request = interrupt;
    end

    // interrupt buffer
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

    // interrupt buffer
    reg   [7:0]   interrupt_when_ack1;

    always @* begin
        if (write_initial_command_word_1 == 1'b1)
            interrupt_when_ack1 <= 8'b00000000;
        else if (control_state == ACK1)
            interrupt_when_ack1 <= interrupt;
        else
            interrupt_when_ack1 <= interrupt_when_ack1;
    end

    // control_logic_data
    always @* begin
        if (interrupt_acknowledge_n == 1'b0) begin
            // Acknowledge
            case (control_state)
                CTL_READY: begin
                    if (cascade_slave == 1'b0) begin
                        if (u8086_or_mcs80_config == 1'b0) begin
                            out_control_logic_data = 1'b1;
                            control_logic_data     = 8'b11001101;
                        end
                        else begin
                            out_control_logic_data = 1'b0;
                            control_logic_data     = 8'b00000000;
                        end
                    end
                    else begin
                        out_control_logic_data = 1'b0;
                        control_logic_data     = 8'b00000000;
                    end
                end
                ACK1: begin
                    if (cascade_slave == 1'b0) begin
                        if (u8086_or_mcs80_config == 1'b0) begin
                            out_control_logic_data = 1'b1;
                            control_logic_data     = 8'b11001101;
                        end
                        else begin
                            out_control_logic_data = 1'b0;
                            control_logic_data     = 8'b00000000;
                        end
                    end
                    else begin
                        out_control_logic_data = 1'b0;
                        control_logic_data     = 8'b00000000;
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
                                control_logic_data = {interrupt_vector_address[2:1], control_logic_data[2:0], 3'b000};
                            else
                                control_logic_data = {interrupt_vector_address[2:0], control_logic_data[2:0], 2'b00};
                        end
                        else begin
                            control_logic_data = {interrupt_vector_address[10:6], control_logic_data[2:0]};
                        end
                    end
                    else begin
                        out_control_logic_data = 1'b0;
                        control_logic_data     = 8'b00000000;
                    end
                end
                ACK3: begin
                    if (cascade_output_ack_2_3 == 1'b1) begin
                        out_control_logic_data = 1'b1;
                        control_logic_data     = interrupt_vector_address[10:3];
                    end
                    else begin
                        out_control_logic_data = 1'b0;
                        control_logic_data     = 8'b00000000;
                    end
                end
                default: begin
                    out_control_logic_data = 1'b0;
                    control_logic_data     = 8'b00000000;
                end
            endcase
        end
        else if ((control_state == POLL) && (read == 1'b1)) begin
            // Poll command
            out_control_logic_data = 1'b1;
            if (acknowledge_interrupt == 8'b00000000)
                control_logic_data = 8'b000000000;
            else begin
                control_logic_data[7:3] = 5'b10000;
                control_logic_data[2:0] = bit2num(acknowledge_interrupt);
            end
        end
        else begin
            // Nothing
            out_control_logic_data = 1'b0;
            control_logic_data     = 8'b00000000;
        end
    end
endmodule

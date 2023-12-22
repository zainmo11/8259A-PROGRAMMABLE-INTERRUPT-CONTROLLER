/**
 * Module: Internal_Functions
 * Description: This module contains various internal functions used in the 8259A IN Control Logic module.
 * 
 * Functions:
 *   - rotate_right: Performs a right rotation on the input source by the specified number of positions.
 *   - rotate_left: Performs a left rotation on the input source by the specified number of positions.
 *   - resolv_priority: Resolves the priority of the input request by converting it to an 8-bit priority value.
 *   - num2bit: Converts a 3-bit number to an 8-bit binary representation.
 *   - bit2num: Converts an 8-bit binary representation to a 3-bit number.
 */


/**
 * Function: rotate_right
 * Description: Performs a right rotation on the input source by the specified number of positions.
 * Inputs:
 *   - source: 8-bit input to be rotated
 *   - rotate: 3-bit number specifying the number of positions to rotate
 * Returns:
 *   - 8-bit result of the right rotation
 */
function [7:0] rotate_right (input [7:0] source, input [2:0] rotate);
    case (rotate)
        3'b000:  rotate_right = { source[0],   source[7:1] };
        3'b001:  rotate_right = { source[1:0], source[7:2] };
        3'b010:  rotate_right = { source[2:0], source[7:3] };
        3'b011:  rotate_right = { source[3:0], source[7:4] };
        3'b100:  rotate_right = { source[4:0], source[7:5] };
        3'b101:  rotate_right = { source[5:0], source[7:6] };
        3'b110:  rotate_right = { source[6:0], source[7]   };
        3'b111:  rotate_right = source;
        default: rotate_right = source;
    endcase
endfunction

/**
 * Function: rotate_left
 * Description: Performs a left rotation on the input source by the specified number of positions.
 * Inputs:
 *   - source: 8-bit input to be rotated
 *   - rotate: 3-bit number specifying the number of positions to rotate
 * Returns:
 *   - 8-bit result of the left rotation
 */
function [7:0] rotate_left (input [7:0] source, input [2:0] rotate);
    case (rotate)
        3'b000:  rotate_left = { source[6:0], source[7]   };
        3'b001:  rotate_left = { source[5:0], source[7:6] };
        3'b010:  rotate_left = { source[4:0], source[7:5] };
        3'b011:  rotate_left = { source[3:0], source[7:4] };
        3'b100:  rotate_left = { source[2:0], source[7:3] };
        3'b101:  rotate_left = { source[1:0], source[7:2] };
        3'b110:  rotate_left = { source[0],   source[7:1] };
        3'b111:  rotate_left = source;
        default: rotate_left = source;
    endcase
endfunction

/**
 * Function: resolv_priority
 * Description: Resolves the priority of the input request by converting it to an 8-bit priority value.
 * Inputs:
 *   - request: 8-bit input representing the request
 * Returns:
 *   - 8-bit priority value
 */
function [7:0] resolv_priority (input [7:0] request);
    if      (request[0] == 1'b1)    resolv_priority = 8'b00000001;
    else if (request[1] == 1'b1)    resolv_priority = 8'b00000010;
    else if (request[2] == 1'b1)    resolv_priority = 8'b00000100;
    else if (request[3] == 1'b1)    resolv_priority = 8'b00001000;
    else if (request[4] == 1'b1)    resolv_priority = 8'b00010000;
    else if (request[5] == 1'b1)    resolv_priority = 8'b00100000;
    else if (request[6] == 1'b1)    resolv_priority = 8'b01000000;
    else if (request[7] == 1'b1)    resolv_priority = 8'b10000000;
    else                            resolv_priority = 8'b00000000;
endfunction

/**
 * Function: num2bit
 * Description: Converts a 3-bit number to an 8-bit binary representation.
 * Inputs:
 *   - source: 3-bit number to be converted
 * Returns:
 *   - 8-bit binary representation of the input number
 */
function [7:0] num2bit (input [2:0] source);
    case (source)
        3'b000:  num2bit = 8'b00000001;
        3'b001:  num2bit = 8'b00000010;
        3'b010:  num2bit = 8'b00000100;
        3'b011:  num2bit = 8'b00001000;
        3'b100:  num2bit = 8'b00010000;
        3'b101:  num2bit = 8'b00100000;
        3'b110:  num2bit = 8'b01000000;
        3'b111:  num2bit = 8'b10000000;
        default: num2bit = 8'b00000000;
    endcase
endfunction

/**
 * Function: bit2num
 * Description: Converts an 8-bit binary representation to a 3-bit number.
 * Inputs:
 *   - source: 8-bit binary representation
 * Returns:
 *   - 3-bit number corresponding to the input binary representation
 */
function [2:0] bit2num (input [7:0] source);
    if      (source[0] == 1'b1) bit2num = 3'b000;
    else if (source[1] == 1'b1) bit2num = 3'b001;
    else if (source[2] == 1'b1) bit2num = 3'b010;
    else if (source[3] == 1'b1) bit2num = 3'b011;
    else if (source[4] == 1'b1) bit2num = 3'b100;
    else if (source[5] == 1'b1) bit2num = 3'b101;
    else if (source[6] == 1'b1) bit2num = 3'b110;
    else if (source[7] == 1'b1) bit2num = 3'b111;
    else                        bit2num = 3'b111;
endfunction

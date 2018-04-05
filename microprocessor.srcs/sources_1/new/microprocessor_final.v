`timescale 1ns / 1ps
// Test comment for changes
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/04/2018 01:30:09 PM
// Design Name: 
// Module Name: microprocessor_final
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module microprocessor_final(clock, reset, R0, R1, R2, R3, RHi, RLo, PC, IR, rom_address, rom_data, ram_address,
ram_data_out, ram_data_in, ram_write, state);
    
    input clock, reset;
    output reg [7:0] R0, R1, R2, R3, RHi, RLo;
    output reg [7:0] PC, IR, rom_address;
    output [7:0] rom_data;
    output reg [7:0] ram_address, ram_data_in;
    output [7:0] ram_data_out;
    output reg ram_write;
    output reg [5:0] state;
    
    // Instantiate RAM
    blk_mem_RAM RAM_1 (
      .clka(clock),    // input wire clka
      .wea(ram_wire),      // input wire [0 : 0] wea
      .addra(ram_address),  // input wire [7 : 0] addra
      .dina(ram_data_in),    // input wire [7 : 0] dina
      .douta(ram_data_out)  // output wire [7 : 0] douta
    );
    
    // Instantiate ROM
    blk_mem_ROM ROM_1 (
      .clka(clock),    // input wire clka
      .addra(rom_address),  // input wire [7 : 0] addra
      .douta(rom_data)  // output wire [7 : 0] douta
    );
    
    parameter reset_cpu = 6'd0,
              fetch = 6'd1,
              decode = 6'd2,
              execute_NOP = 6'd3,
                //execute_ADD = 6'd4,
                //execute_SUB = 6'd5,
                //execute_NOT = 6'd6,
                //execute_AND = 6'd7,
                //execute_OR = 6'd8,
                //execute_MOV_RStoRD = 6'd9,
                
                // Ram write: M[address} <- RS
                //execute_MOV_RStoM = 6'd10,
                //execute_MOV_RStoM2 = 6'd11,
                //execute_MOV_RStoM3 = 6'd12,
                
                // Move a constant into a register R0 through R3
              execute_MOV_DatatoRD = 6'd13,
              execute_MOV_DatatoRD2 = 6'd14;
                
                // Ram read: RD <- M[address]
                //execute_MOV_MtoRD = 6'd15,
                //execute_MOV_MtoRD2 = 6'd16,
                //execute_MOV_MtoRD3 = 6'd17,
                //execute_MOV_MtoRD4 = 6'd18,
                //execute_MOV_MtoRD5 = 6'd19,
                
                // JMP and JNZ
                //execute_JMP = 6'd20,
                //execute_JMP1 = 6'd21,
                //execute_JMP2 = 6'd22,
                //execute_JMP3 = 6'd23,
                //execute_JNZ = 6'd24;
                
    always @ (posedge clock, posedge reset) begin
        if (reset) begin
            R0 <= 0; R1 <= 0; R2 <= 0; R3 <= 0;
            RHi <= 0; RLo <= 0;
            rom_address <= 0;
            ram_address <= 0;
            ram_write <= 0;
            IR <= 0;
            PC <= 0;
            state <= reset_cpu;
        end
        else begin
            case (state)
            reset_cpu: begin // Reset all registers when reset button is pressed
                R0 <= 0; R1 <= 0; R2 <= 0; R3 <= 0;
                RHi <= 0; RLo <= 0;
                rom_address <= 0;
                ram_address <= 0;
                ram_write <= 0;
                IR <= 0;
                PC <= 0;
                state <= fetch;
            end
            
            /////////////////////////////////////////////////////////////////////
            
            fetch: begin // Retrieve instruction from ROM
                IR <= rom_data;
                PC <= PC + 1; // Increment to either next instruction or operand
                state <= decode;
            end
            
            /////////////////////////////////////////////////////////////////////
            
            decode: begin // Determine which operation to execute
                rom_address <= PC; // With rom_data stored in IR, new rom_address can be pointed to
                case (IR[7:4])
                    4'h0: state <= execute_NOP;
                    
                    4'h8: begin
                        state <= execute_MOV_DatatoRD;
                        PC <= PC + 1; // Increment PC to next instruction, but rom_address is left pointing to operand
                    end
                    
                    default: state <= execute_NOP;
                endcase
            end
            
            /////////////////////////////////////////////////////////////////////
            
            execute_NOP: begin // Perform no operations
                rom_address <= PC; // Make ROM data available on next clock cycle in fetch state
                state <= fetch;
            end
            
            /////////////////////////////////////////////////////////////////////
            
            execute_MOV_DatatoRD: begin
                rom_address <= PC; // rom_address updated for next fetch state
                                   // In next clock cycle, rom_address will be updated
                                   // rom_data won't update until positive clock edge
                                   // with new rom_address which changes to fetch state
                                   // Thus operand rom_data is available in next state
                state <= execute_MOV_DatatoRD2;
            end
            
            execute_MOV_DatatoRD2: begin // Store a constant to a register R0 through R3
                case(IR[1:0])
                    0: R0 <= rom_data;
                    1: R1 <= rom_data;
                    2: R2 <= rom_data;
                    3: R3 <= rom_data;
                    default: begin R0 <= R0; R1 <= R1; R2 <= R2; R3 <= R3; end
                endcase
                state <= fetch;
            end
            
            /////////////////////////////////////////////////////////////////////
            
            endcase
        end
    end   
endmodule

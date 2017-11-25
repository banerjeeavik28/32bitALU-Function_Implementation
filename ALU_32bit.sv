`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/24/2017 09:12:43 PM
// Design Name: 
// Module Name: ALU_32bit
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

module ALU_32bit( A , B, Op_code, Out, Cf, Of, Zf, Sf 

    );
    input logic [31:0] A;
    input logic [31:0] B;
    input logic [ 3:0] Op_code;
    output logic [31:0] Out;
    output logic Cf;
    output logic Of;
    output logic Zf;
    output logic Sf;
    logic  [12:0][31:0] POp_code;
    logic [7:0] PCf;
    logic [1:0] POf;
    logic [1:0] PSf;
    /*
    assign Out = Op_code == 4'b0000 ? Adder(A,B,Cf,Out):
            Op_code == 4'b0001 ? Subtraction(A,B,Cf,Out):
            Op_code == 4'b0010 ? Increment(A,B,Cf,Out):
            Op_code == 4'b0011 ? Decrement(A,B,Cf,Out):
            Op_code == 4'b0100 ? Move(A,B,Cf,Out):
            Op_code == 4'b0101 ? Shift_Left(A,B,Cf,Out):
            Op_code == 4'b0110 ? SIMD_ADD(A,B,Cf,Out):
            Op_code == 4'b0111 ? BITWISE_AND(A,B,Cf,Out):
            Op_code == 4'b1000 ? BITWISE_OR(A,B,Cf,Out):
            Op_code == 4'b1001 ? BITWISE_XOR(A,B,Cf,Out):
            Op_code == 4'b1010 ? Compliment(A,B,Cf,Out):
            Op_code == 4'b1011 ? Two_Compliment(A,B,Cf,Out): 'z;
    
    */
    
    assign POp_code[12] = Op_code == 4'b0000 ? POp_code[0]:
                 Op_code == 4'b0001 ? POp_code[1]:
                 Op_code == 4'b0010 ? POp_code[2]:
                 Op_code == 4'b0011 ? POp_code[3]:
                 Op_code == 4'b0100 ? POp_code[4]:
                 Op_code == 4'b0101 ? POp_code[5]:
                 Op_code == 4'b0110 ? POp_code[6]:
                 Op_code == 4'b0111 ? POp_code[7]:
                 Op_code == 4'b1000 ? POp_code[8]:
                 Op_code == 4'b1001 ? POp_code[9]:
                 Op_code == 4'b1010 ? POp_code[10]:
                 Op_code == 4'b1011 ? POp_code[11]: 'z;
                 
    assign Cf = Op_code == 4'b0000 ? PCf[0]:
                Op_code == 4'b0001 ? 'z:
                Op_code == 4'b0010 ? PCf[2]:
                Op_code == 4'b0011 ? 'z:
                Op_code == 4'b0100 ? PCf[4]:
                Op_code == 4'b0101 ? 'z:
                Op_code == 4'b0110 ? PCf[5]:
                Op_code == 4'b0111 ? 'z:
                Op_code == 4'b1000 ? 'z:
                Op_code == 4'b1001 ? 'z:
                Op_code == 4'b1010 ? 'z:
                Op_code == 4'b1011 ? PCf[7]: 'z;
                
    assign Of = Op_code == 4'b0000 ? POf[0]:
                Op_code == 4'b0001 ? POf[1]: 'z;
    assign Sf = Op_code == 4'b0000 ? PSf[0]: 
                Op_code == 4'b0001 ? PSf[1]: 'z;
                
    assign Out = POp_code[12] != 0 ? POp_code[12] : 32'b0;    
    assign Zf = POp_code[12] == 0 ? 'b1 : 'b0;

            
    Adder Ad (A,B,PCf[0], POf[0], PSf[0], POp_code[0]);
    Subtraction Su (A,B, POf[1], PSf[1], POp_code[1]);
    Increment In (A,PCf[2],POp_code[2]);
    Decrement De (A,POp_code[3]);
    Move Mo (A,POp_code[4]);
    Shift_Left Sh (A,POp_code[5]);
    SIMD_ADD Si (A,B,PCf[5],POp_code[6]);
    BITWISE_AND Ba (A,B,POp_code[7]);
    BITWISE_OR Bo (A,B,POp_code[8]);
    BITWISE_XOR Bx (A,B,POp_code[9]);
    Compliment Co (A,POp_code[10]);
    Two_Compliment Tw (A,PCf[7],POp_code[11]);
    
    
endmodule


// ADDER 
module Adder(input logic [31:0] A, B, output logic [1:0] C_out, output logic Of, output logic Sf, output logic [31:0] sum);

    assign {C_out,sum} = A + B;
    assign Of = (A + B) > 8'hFFFFFFFF ? 1'b1 : 1'b0;
    assign Sf = (A + B) < 0 ? 1'b1 : 1'b0;

endmodule

// SUBTRACTOR
module Subtraction(input logic [31:0] A, B, output logic Of, output logic Sf, output logic [31:0] sum);

    assign {C_out, sum} = (A - B);
    assign Of = (A < B) & (B > 31'b1) & ((B - A) > 31'b1) ? 1'b1 : 1'b0;
    assign Sf = A < B ? 1'b1 : 1'b0;
    
endmodule

// INCREMENT
module Increment(input logic [31:0] A, output logic C_out, output logic [31:0] increment);

    assign {C_out, increment} = A + 1;
    
endmodule

//DECREMENT
module Decrement(input logic [31:0] A, output logic [31:0] decrement);

    assign decrement = A - 1;
    
endmodule

// MOVE
module Move(input logic [31:0] A, output logic [31:0] Move);

    assign Move = A;
    
endmodule

// SHIFT LEFT
module Shift_Left(input logic [31:0] A, output logic [31:0] shifted);
    assign shifted = A * 2;
endmodule

// SIMD A + B
module SIMD_ADD(input logic [31:0] A,B, output logic C_out, output logic [31:0] sum);

    assign sum[7:0] = A[7:0] + B[7:0];
    assign sum[15:8] = A[15:8] + B[15:8];
    assign sum [23:16] = A[23:16] + B[23:16];
    assign {C_out,sum[31:24]} = A[31:24] + B[31:24];
    
endmodule 


// BITWISE_AND
module BITWISE_AND(input logic[31:0] A,B, output logic [31:0] sum);
    assign sum = A & B;
endmodule
 
// BITWISE_OR
module BITWISE_OR(input logic[31:0] A,B, output logic [31:0] sum);
    assign sum = A | B;
 endmodule
 
 // BITWISE_XOR   
 module BITWISE_XOR(input logic[31:0] A,B, output logic [31:0] sum);
    assign sum = A ^ B;
endmodule

// COMPLIMENT
module Compliment(input logic [31:0] A, output logic [31:0] compliment);
    
    assign compliment = ~A;
    
endmodule

// 2's COMPLIMENT
module Two_Compliment(input logic [31:0] A, output logic C_out, output logic [31:0] compliment);
    
    assign {C_out,compliment} = ~A + 1;
     
endmodule

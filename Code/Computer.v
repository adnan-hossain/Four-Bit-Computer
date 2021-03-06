module Computer(clock, port_in, port_out, A, B, temp, PC, PC_temp, IP, SP, OF, ZF, SF, HLT);
	
	input clock;							//system clock
	input [3:0]port_in;						//input port 1
	output reg [3:0]port_out; 				//output port 1
	output reg [3:0]A, B, temp;				//Registers A and B
	output reg [3:0] PC, PC_temp, IP;		//Program counter PC and instruction IP
	output reg [1:0]SP;						//stack pointer SP
	reg [3:0]RAM [0:15];					//(16x4) RAM. First 12 words contain instructions. Last 4 words contain data.
	reg [3:0]Stack [0:3];					//(4x4) Stack memory to contain data 					
	reg [3:0]address, const_byte; 			//register to hold ADDRESS and BYTE
	output reg OF, ZF, SF, HLT;				//overflow flag OF, zero flag ZF, sign flag SF, halt HLT
	integer i;								//loop variable
	
	initial
	begin
		//Initialize counters, pointers, registers and flags to zero
		PC = 0;				
		PC_temp = 0;
		IP = 0;
		SP = 0;
		A = 4'b0000;
		B = 4'b0000;
		OF = 0;
		ZF = 0;
		SF = 0;
		HLT = 0;
		
		//Instruction memory (Currently no instructions have been uploaded to the program)
		RAM[0][3:0] = 0;
		RAM[1][3:0] = 0;
		RAM[2][3:0] = 0;
		RAM[3][3:0] = 0;
		RAM[4][3:0] = 0;
		RAM[5][3:0] = 0;
		RAM[6][3:0] = 0;
		RAM[7][3:0] = 0;
		RAM[8][3:0] = 0;
		RAM[9][3:0] = 0;
		RAM[10][3:0] = 0;
		RAM[11][3:0] = 0;
		//Data memory (Currently no data is stored in the memory)
		RAM[12][3:0] = 0;
		RAM[13][3:0] = 0;
		RAM[14][3:0] = 0;
		RAM[15][3:0] = 0;
		
		//Initializing stack memory to zero
		for (i=0; i<4; i=i+1)
		begin
			Stack[i][3:0] = 4'b0000;
		end
		
		address = 4'bxxxx;			//assumed value of ADDRESS (different value assumed for each program)
		const_byte = 4'bxxxx;		//assumed value of BYTE (different value assumed for each program)
		
	end
	
	
	always @(posedge clock)						//The instructions of the program are performed at positive clock edge
	begin
		if (HLT == 0)							//Perform the program instructions only if Halt Flag is equal to zero.
		begin
			if (IP == 4'b000)					//Line 1 executed if instruction has machine code = 0000
				begin							//ADD A, B
				ADD(A, B, temp, OF);			
				A = temp;
				if (A==0)	ZF = 1;				//Set ZF to 1 if A is equal to zero.
				end
				
			else if (IP == 4'b0001)				//Line 2 executed if instruction has machine code = 0001
				begin							//SUM A, B
				SUB(A, B, temp, SF);
				A = temp;
				if (A==0)	ZF = 1;
				end
				
			else if (IP == 4'b0010)				//Line 3 executed if instruction has machine code = 0010
				begin							//XCHG A, B
				temp = A;
				A = B;
				B = temp;
				end
				
			else if (IP == 4'b0011)				//Line 4 executed if instruction has machine code = 0011
				begin							//IN A
				A = port_in;
				end
				
			else if (IP == 4'b0100)				//Line 5 executed if instruction has machine code = 0100
				begin							//OUT A
				port_out = A;
				end
				
			else if (IP == 4'b0101)				//Line 6 executed if instruction has machine code = 0101
				begin							//INC A
				A = A + 1;
				if (A>15)
					OF =1;
				end
			
			else if (IP == 4'b0110)				//Line 7 executed if instruction has machine code = 0110
				begin							//MOV A, [ADDRESS]
				A = RAM[address];
				if (RAM[address]>15)	
					OF = 1;
				end
				
			else if (IP == 4'b0111)				//Line 8 executed if instruction has machine code = 0111
				begin							//MOV A, BYTE
				A = const_byte;
				if (const_byte>15)	
					OF = 1;
				end
				
			else if (IP == 4'b1000)				//Line 9 executed if instruction has machine code = 1000
				begin							//JZ ADDRESS
				if (ZF==1)
					PC_temp = address;
				end
				
			else if (IP == 4'b1001)				//Line 10 executed if instruction has machine code = 1001
				begin							//PUSH B
				Stack[SP] = B;
				SP = SP + 1;
				end
				
			else if (IP == 4'b1010)				//Line 11 executed if instruction has machine code = 1010
				begin 							//POP B
				SP = SP - 1;
				B = Stack[SP];
				if (B==0)	ZF = 1;
				end
				
			else if (IP == 4'b1011)				//Line 12 executed if instruction has machine code = 1011
				begin 							//RCL B
				temp = {B[2:0], B[3]};
				B = temp;
				if (B==0)	ZF = 1;
				end
				
			else if (IP == 4'b1100)				//Line 13 executed if instruction has machine code = 1100
				begin							//CALL ADDRESS
				Stack[SP] = PC;
				SP = SP + 1;
				PC_temp = address;
				end
				
			else if (IP == 4'b1101)				//Line 14 executed if instruction has machine code = 1101
				begin							//RET
				SP = SP - 1;
				PC_temp = Stack[SP];
				end
				
			else if (IP == 4'b1110)				//Line 15 executed if instruction has machine code = 1110
				begin							//AND A, [ADDRESS]
				temp = A & RAM[address];
				A = temp;
				if (A==0)	ZF = 1;
				end
				
			else 								//Line 16 executed if instruction has machine code = 1111
				HLT = 1;						//HLT
		end
		
		else if (HLT == 1)						//If Halt Flag is equal to 1, clear registers and memory 
		begin									//and set stack pointer to zero
			SP = 0;
			A = 4'b0000;
			B = 4'b0000;
			temp = 4'b0000;
			for (i=0; i<16; i=i+1)
			begin
				RAM[i][3:0] = 4'b0000;
			end
			for (i=0; i<4; i=i+1)
			begin
				Stack[i][3:0] = 4'b0000;
			end
		end
		
	end
	
	
	always @(negedge clock)						//Increment program counter and and obtain instruction from memory
	begin										//on each negative clock edge	
		if (HLT==0)
		begin
			if ((IP == 4'b1000 && ZF == 1) || IP == 4'b1100 || IP == 4'b1101)	
				begin
				PC = PC_temp;
				IP = RAM[PC];
				PC = PC + 1;
				end
			else
				begin
				IP = RAM[PC];
				PC = PC + 1;
				end
		end
		else									//if HLT is equal to 1, set program counter and instruction to zero
		begin
			PC = 0;
			IP = 0;
		end  
	end 
	
		
	task ADD;									//task to perform addition operation including OF flag
		
		input [3:0]A,B;
		output reg [3:0]SUM;
		output reg OF;
		
		{OF,SUM} = A + B;
		
	endtask
	
	
	task SUB;									//task to perform subtraction operation including SF flag
		
		input [3:0]A;
		input [3:0]B;
		output reg [3:0]DIFF;
		output reg SF;
		
		if (A>=B)
			begin
			DIFF = A - B;
			SF = 0;
			end
		else 
			begin
			DIFF = B - A;
			SF = 1;
			end
		
	endtask	
	

endmodule







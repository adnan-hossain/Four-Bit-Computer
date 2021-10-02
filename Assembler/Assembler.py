assembly_file = open('Assembly Test Code 2.txt', 'r')
machine_file = open('Machine Test Code 2.txt', 'w')


assembly_str = assembly_file.read()
assembly_list = assembly_str.split('\n')
print(assembly_list)


for item in assembly_list:
    if 'ADD' in item:
        machine_file.write('0000\n')
    elif 'SUB' in item:
        machine_file.write('0001\n')
    elif 'XCHG' in item:
        machine_file.write('0010\n')
    elif 'INC' in item:
        machine_file.write('0101\n')
    elif 'IN' in item:
        machine_file.write('0011\n')
    elif 'OUT' in item:
        machine_file.write('0100\n')
    elif 'MOV' in item:
        if '[' in item:
            machine_file.write('0110\n')
        else:
            machine_file.write('0111\n')
    elif 'JZ' in item:
        machine_file.write('1000\n')
    elif 'PUSH' in item:
        machine_file.write('1001\n')
    elif 'POP' in item:
        machine_file.write('1010\n')
    elif 'RCL' in item:
        machine_file.write('1011\n')
    elif 'CALL' in item:
        machine_file.write('1100\n')
    elif 'RET' in item:
        machine_file.write('1101\n')
    elif 'AND' in item:
        machine_file.write('1110\n')
    elif 'HLT' in item:
        machine_file.write('1111\n')

assembly_file.close()        
machine_file.close()

 
machine_file = open('Machine Test Code 2.txt', 'r')
        
for line in machine_file:
    print(line)
    
machine_file.close()
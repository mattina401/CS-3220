import sys
import os
import re
import struct
import string
ALU_CMP_R = {    
	'add' : '00',
    'sub' : '10',
    'and' : '40',
    'or' : '50',
    'xor' : '60',
    'nand' : 'c0',    
    'nor' : 'd0',    
    'xnor' : 'e0',
	
	'f' : '02',
    'eq' : '12',
    'lt' : '22',
    'lte' : '32',
    't' : '82',
    'ne' : '92',
    'gte' : 'a2',
    'gt' : 'b2',
    'ble' : '32',
    'bge' : 'a2'
	}

ALU_CMP_I = {    
    'addi' : '08',
    'subi' : '18',
    'andi' : '48',
    'ori' : '58',
    'xori' : '68',
    'nandi' : 'c8',
    'nori' : 'd8',
    'xnori' : 'e8',
	
	'fi' : '0a',
    'eqi' : '1a',
    'lti' : '2a',
    'ltei' : '3a',
    'ti' : '8a',
    'nei' : '9a',
    'gtei' : 'aa',
    'gti' : 'ba'
	}
MVHI = {
	'mvhi' : 'b8'
	}
NOT = {
	'not' : 'c0'
	}
Load_Store = {
    'lw' : '09',
    'sw' : '05'
	}
	
	
Branch1 = {
    'bf' : '06',
    'beq' : '16',
    'blt' : '26',
    'blte' : '36',

    'bt' : '86',
    'bne' : '96',
    'bgte' : 'a6',
    'bgt' : 'b6'
	}
	
Branch2 = {

    'beqz' : '56',
    'bltz' : '66',
    'bltez' : '76',
    
    'bnez' : 'd6',
    'bgtez' : 'e6',
    'bgtz' : 'f6'
	}
JAL = {
	'jal' : '0b'
	}
CALL = {
	'call' : '0b'
	}
RET = {
	'ret' : '0b'
	}
JMP = {
	'jmp' : '0b'
	}

BR = {
	'br' : '16'
	}
	
register = {
	'a0' : '0',
	'a1' : '1',
	'a2' : '2',
	'a3' : '3',
	'rv' : '3',
	't0' : '4',
	't1' : '5',
	's0' : '6',
	's1' : '7',
	's2' : '8',
	'gp' : 'c',
	'fp' : 'd',
	'sp' : 'e',
	'ra' : 'f',
	
	'r0' : '0',
	'r1' : '1',
	'r2' : '2',
	'r3' : '3',
	'r4' : '4',
	'r5' : '5',
	'r6' : '6',
	'r7' : '7',
	'r8' : '8',
	'r9' : '9',
	'r10' : 'a',
	'r11' : 'b',
	'r12' : 'c',
	'r13' : 'd',
	'r14' : 'e',
	'r15' : 'f'
	}
NAME = {}
	
	
def main():
	file_name = input('File name: ')
	read_file(file_name + '.a32')
	
def read_file(name):
	init2(name)
	ass = open(name)
	mif = open(name[0:-4] + '.mif','w')
	origin = 0
	num1 = 0
	count = 0
	flag = 0
	print("""WIDTH=32;
DEPTH=2048;
ADDRESS_RADIX=HEX;
DATA_RADIX=HEX;
CONTENT BEGIN""")
	mif.write("""WIDTH=32;
DEPTH=2048;
ADDRESS_RADIX=HEX;
DATA_RADIX=HEX;
CONTENT BEGIN\n""")


	for s in ass:
		count = count + 1
		s = s.strip().lower()
		if s.startswith(';'):
			continue
		elif s[0:] == '':
			continue
		elif s.startswith('.'):
			
			if s.startswith('.ORIG') or s.startswith('.orig'):
				if ';' in s:
					s = s[0:s.index(';')]
				s = s[5:]
				s = s.strip()
			
				if 'x' in s:

					a = int(s,16)
					a = a/4
					a = str(a)
					a = a[:-2]
					a = int(a)
					
					#format(num1,"08x")
					if a != 0:
						if flag == 0:
							print('[00000000' + '..' + format(a-1,"08x") + '] : DEAD;')
							mif.write('[00000000' + '..' + format(a-1,"08x") + '] : DEAD;\n')
						else:
							print(format(a-1,"08x") + ' : DEAD;')
							mif.write(format(a-1,"08x") + ' : DEAD;\n')
							

					num1 = a
				origin = int(s, 16)
				flag = flag + 1
			
				#if origin !=0:
					#print('[00000000' + '..' + format(origin - 1,"08x") + '] : DEAD;')
					#num1 = origin
			#startswith('.NAME')
			else:
				continue
				
		elif ':' in s:
			continue
		elif ';' in s:
			inx = s.index(';')
			s = s[0:inx]
			print("-- @ " + format(origin, "#010x") + " : " + print_opcode(s))
			print(find_opcode(num1, s, count))
			mif.write("-- @ " + format(origin, "#010x") + " : " + print_opcode(s) + '\n')
			mif.write(find_opcode(num1, s, count) + '\n')
			if s.split()[0] == 'ble' or s.split()[0] == 'bge':
				num1 = num1 + 2
			else:
				num1 = num1 + 1
			origin = origin + 4
		else:
			print("-- @ " + format(origin, "#010x") + " : " + print_opcode(s))
			print(find_opcode(num1, s, count))
			mif.write("-- @ " + format(origin, "#010x") + " : " + print_opcode(s) + '\n')
			mif.write(find_opcode(num1, s, count) + '\n')
			if s.split()[0] == 'ble' or s.split()[0] == 'bge':
				num1 = num1 + 2
			else:
				num1 = num1 + 1
			origin = origin + 4
		

			#mif.write(s)
	print( "["  + format(num1,"08x") + "..000007ff] : DEAD;" )
	print('END;')
	mif.write("["  + format(num1,"08x") + "..000007ff] : DEAD;\n")
	mif.write('END;\n')
	ass.close()
	mif.close()

	
	
	
def init2(name):
	ass = open(name)

	origin = 0
	num1 = 0
	count = 0
	flag = 0

	
	for s in ass:
		count = count + 1
		s = s.strip().lower()
		if s.startswith(';'):
			continue
		elif s[0:] == '':
			continue
		elif s.startswith('.'):
			
			if s.startswith('.ORIG') or s.startswith('.orig'):
				if ';' in s:
					s = s[0:s.index(';')]
				s = s[5:]
				s = s.strip()
			
				if 'x' in s:

					a = int(s,16)
					a = a/4
					a = str(a)
					a = a[:-2]
					a = int(a)
					
					if a != 0:
						num1 = a
				origin = int(s, 16)
			elif s.startswith('.NAME') or s.startswith('.name'):
				s = s[5:]
				s = s.strip()
				s = s.split('=')
				s[0] = s[0].strip()
				s[1] = s[1].strip()
				value = s[1] 
				if value[1] != 'x':
					value = int(value)
					value = format(value,"#010x")
				else:
					value = int(value, 16)
					value = format(value,"#010x")
				NAME[s[0].lower()] = value
			else:
				continue
				
		elif ':' in s:
		
			s = s[0:s.index(':')]
			address = num1
			address = format(address,"#010x")
			NAME[s.lower()] = address
		
		elif ';' in s:
			inx = s.index(';')
			s = s[0:inx]

			if s.split()[0] == 'ble' or s.split()[0] == 'bge':
				num1 = num1 + 2
			else:
				num1 = num1 + 1
			origin = origin + 4
		else:

			if s.split()[0] == 'ble' or s.split()[0] == 'bge':
				num1 = num1 + 2
			else:
				num1 = num1 + 1
			origin = origin + 4
		

	print(NAME)
	ass.close()

	
	
"""
def init(name):
	ass = open(name)
	
	count = 0
	
	for s in ass:
		count = count + 1
		s = s.strip()
		if s.startswith('.NAME'):
			s = s[5:]
			s = s.strip()
			s = s.split('=')
			s[0] = s[0].strip()
			s[1] = s[1].strip()
			value = s[1] 
			if value[1] != 'x':
				value = int(value)
				value = format(value,"#010x")
			else:
				value = int(value, 16)
				value = format(value,"#010x")
			NAME[s[0].lower()] = value
		elif ':' in s:
			
			s = s[0:s.index(':')]
			address = count
			#address = hex(address)
			address = format(address,"#010x")
			NAME[s.lower()] = address
		
	print(NAME)
"""			
			
def find_opcode(num1, code, count):
	op = code.split()[0]
	
	#RET
	if op in RET:
		return format(num1,"08x") + " : " + register.get('r9') + register.get('ra') + '0000' + RET.get(op) + ";"
	
	if len(code.split()) == 4:
		reg = code.split()[1] + code.split()[2] + code.split()[3]
	elif len(code.split()) == 3:
		reg = code.split()[1] + code.split()[2]
	elif len(code.split()) == 2:
		reg = code.split()[1]
	else:
		reg = ''

	code = op + ',' + reg
	
	if op in Load_Store or op in JAL or op in CALL or op in JMP:
		
		code = code.replace('(' , ',')
		code = code[0:-1]

	code = code.split(',')
	
	#ALU_CMP_R
	if code[0] in ALU_CMP_R:
	
		#BLE or BGE
		if (op == 'ble') or (op == 'bge') :
			if code[3] in NAME:
				address = NAME.get(code[3])
				address = address[-4:]
			else:
				if len(code[3]) < 3 or code[3][1] != 'x':
					address = int(code[3])
					if address < 0:
						address = address & 0xffff
					address = format(address,"04x")
				else:
					address = int(code[3], 16)
					address = format(address,"04x")
			return format(num1,"08x") + " : " + register.get('s0') + register.get(code[1]) + register.get(code[2])+ '000' +  ALU_CMP_R.get(op) + ';' +'\n' + format(num1 + 1,"08x") + " : "+ register.get('s0') + '0' + address + Branch2.get('bnez') + ";"

		return format(num1,"08x") + " : " + register.get(code[1]) + register.get(code[2]) + register.get(code[3])+ '000' +  ALU_CMP_R.get(op) + ";"
	#ALU_CMP_I
	elif code[0] in ALU_CMP_I:
		if code[3] in NAME:
			address = NAME.get(code[3])
			address = address[-4:]
		else:
			if len(code[3]) < 3 or code[3][1] != 'x':
				address = int(code[3])
				if address < 0:
					address = address & 0xffff
				address = format(address,"04x")
			else:
				address = int(code[3], 16)
				address = format(address,"04x")
		return format(num1,"08x") + " : " + register.get(code[1]) + register.get(code[2]) + address + ALU_CMP_I.get(op) + ";"
	#Branch1
	elif code[0] in Branch1:
		if code[3] in NAME:
			address = NAME.get(code[3])
			address = address[-4:]
			address = int(address, 16)
		else:
			if len(code[3]) < 3 or code[3][1] != 'x':
				address = int(code[3])
			else:
				address = int(code[3], 16)
		address = address - num1 -1
		if address < 0:
				address = address & 0xffff
		address = format(address,"04x")	
		return format(num1,"08x") + " : " + register.get(code[1]) + register.get(code[2]) + address + Branch1.get(op) + ";"
	#Branch2
	elif code[0] in Branch2:
		if code[2] in NAME:
			address = NAME.get(code[2])
			address = address[-4:]
			address = int(address, 16)
		else:
			if len(code[2]) < 3 or code[2][1] != 'x':
				address = int(code[2])
			else:
				address = int(code[2], 16)

		address = address - num1 -1
		if address < 0:
				address = address & 0xffff
		address = format(address,"04x")		
		return format(num1,"08x") + " : " + register.get(code[1]) + '0' + address + Branch2.get(op) + ";"
	#MVHI
	elif code[0] in MVHI:
		if code[2] in NAME:
			address = NAME.get(code[2])
			address = address[2:6]
		else:
			address = int(code[2],16)
			if address < 0:
				address = address & 0xffff
			address = format(address,"04x")
		return format(num1,"08x") + " : " + register.get(code[1]) + '0' + address + MVHI.get(op) + ";"
	#NOT
	elif code[0] in NOT:
		return format(num1,"08x") + " : " + register.get(code[1]) + register.get(code[2]) + register.get(code[2]) + '000' + NOT.get(op) + ";"
	#Load_Store and JAL
	elif code[0] in Load_Store or code[0] in JAL:

		if code[2] in NAME:
			address = NAME.get(code[2])
			address = address[-4:]
		elif code[2] in register:
			address = register.get(code[2])
		else:
			address = code[2]
			address = int(code[2],16)
			if address < 0:
				address = address & 0xffff
			address = format(address,"04x")
		#SW
		if code[0] == 'sw':
			if code[1] in register:
				reg = register.get(code[1])
			else:
				reg = code[1]
				reg = int(reg,16)
				reg = format(reg,"04x")
			return format(num1,"08x") + " : " + register.get(code[3]) + reg + address + Load_Store.get(op) + ";"
		#LW
		elif code[0] == 'lw':
			return format(num1,"08x") + " : " + register.get(code[1]) + register.get(code[3]) + address + Load_Store.get(op) + ";"
		#JAL
		elif code[0] == 'jal':
			if code[0] == 'jal':
				return format(num1,"08x") + " : " + register.get(code[1]) + register.get(code[3]) + address + JAL.get(op) + ";"
	#BR
	elif code[0] in BR:
		if code[1] in NAME:
			address = NAME.get(code[1])
			address = address[-4:]
			address = int(address, 16)
		else:
			if len(code[1]) < 3 or code[1][1] != 'x':
				address = int(code[1])
			else:
				address = int(code[1], 16)
		address = address - num1 -1
		if address < 0:
				address = address & 0xffff
		address = format(address,"04x")	
		return format(num1,"08x") + " : " + register.get('r6') + register.get('r6') + address + BR.get(op) + ";"
	#CALL
	elif code[0] in CALL:
		if code[1] in NAME:
			address = NAME.get(code[1])
			address = address[-4:]
		elif code[1] in register:
			address = register.get(code[1])
		else:
			address = code[1]
			address = int(code[1],16)
			address = format(address,"04x")
		return format(num1,"08x") + " : " + register.get('ra') + register.get(code[2]) + address + CALL.get(op) + ";"
	
	#JMP
	elif code[0] in JMP:
		if code[1] in NAME:
			address = NAME.get(code[1])
			address = address[-4:]
		elif code[1] in register:
			address = register.get(code[1])
		else:
			address = code[1]
			address = int(code[1],16)
			address = format(address,"04x")
		return format(num1,"08x") + " : " + register.get('r9') + register.get(code[2]) + address + JMP.get(op) + ";"
	

def make_space(op):
	if len(op) == 6:
		return ''
	if len(op) == 5:
		return ' '
	if len(op) == 4:
		return '  '
	if len(op) == 3:
		return '   '
	if len(op) == 2:
		return '    '
	if len(op) == 1:
		return '     '
	if len(op) == 0:
		return '      '

def print_opcode(opcode):
	op = opcode.split()[0]
	
	if len(opcode.split()) == 4:
		reg = opcode.split()[1] + opcode.split()[2] + opcode.split()[3]
	elif len(opcode.split()) == 3:
		reg = opcode.split()[1] + opcode.split()[2]
	elif len(opcode.split()) == 2:
		reg = opcode.split()[1]
	else:
		reg = ''

	return op.upper() + make_space(op)+ reg.upper()

if __name__== '__main__':
	main()


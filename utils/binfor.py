
import sys
import re
import struct

def main():
    pattern = r'0x[a-fA-F0-9]+'
    
    argc = len(sys.argv)
    for c,val in enumerate(sys.argv):
        if c<1:
            continue
        if re.match(pattern,val):
            decimal=int(val,16)
        else:
            decimal=int(val,10)
        
        byte_sequence = struct.pack(">I",decimal)
        bit_string = ''.join(format(i,"08b")+" " for i in bytearray(byte_sequence))
        
        print(f'({c}): {val}\n'
              f'     = {decimal} dec\n'
              f'     = {bit_string} bin\n')
    
if __name__ == '__main__':
    if len(sys.argv) < 2:
        print('Usage: python script_name.py arg1 [arg2...]')
        sys.exit(-1)
        
    main()
    

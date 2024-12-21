import struct

ADDR_BASE = int( "0x80000000", 16 )
ADDR_INST = int( "0x80000000", 16 )
ADDR_DATA = int( "0x80800000", 16 )

def parse_addr(addr):
    if isinstance(addr, str):
        if addr[:2] == "0x":
            t_addr = int(addr, 16)
    elif isinstance(addr, int):
        t_addr = addr 
    else:
        assert False, "The type of addr is incorrect !!!"
    return t_addr 

def read_img(img, addr, length=1, size=1, addr_start="0x80800000"):
    addr = parse_addr(addr) - ADDR_BASE
    addr_s = parse_addr(addr_start) - ADDR_BASE
    offset = addr-addr_s

    data_list = []
    with open( img, "rb" ) as f:
        f.seek(offset, 0)
        for i in range(length):
            data = f.read(size)
            data_list.append(data)
    return data_list 

def parse_bytes( data_byte, type ):
    if type in   ['uint8' , 'UINT8']:
        fmt = "B"
    elif type in ['int8'  , 'INT8']:
        fmt = 'b'
    elif type in ['uint16', 'UINT16']:
        fmt = 'H'
    elif type in ['int16' , 'INT16']:
        fmt = 'h'
    elif type in ['uint32', 'UINT32']:
        fmt = 'U'
    elif type in ['int32' , 'INT32']:
        fmt = 'i'
    elif type in ['uint64', 'UINT64']:
        fmt = 'L'
    elif type in ['int64' , 'INT64']:
        fmt = 'l'

    mode = "<"+fmt
    result = struct.unpack( mode, data_byte )
    return result

def read_ram(datatype,length,bin_path="../data/bin/save.bin",hex_addr_base="0x80800000",hex_addr="0x80f00000"):
    print(f"Reading {length} {datatype} numbers from {hex_addr}")
    if '8' in datatype:
        size = 1
    elif '16' in datatype:
        size = 2
    elif '32' in datatype:
        size = 4
    img_list = read_img(bin_path, parse_addr(hex_addr), length=length, size=size, addr_start=parse_addr(hex_addr_base))
    for i in img_list:
        print(parse_bytes(i, datatype)[0])
    print("-----------------------------")

if __name__=="__main__":
    read_ram("int8",10,hex_addr="0x80800000")
    read_ram("int16",16,hex_addr="0x80f00000")

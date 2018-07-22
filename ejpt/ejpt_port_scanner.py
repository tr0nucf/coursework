#!/usr/bin/env python3
import socket

target = input("Enter the IP address to scan: ")
port_range = input("Enter the port range (i.e. 2-500)")

lowport = int(port_range.split('-')[0])
highport = int(port_range.split('-')[1])

print('Scanning host ', target, 'from port ', lowport, 'to port ', highport)

for port in range(lowport, highport):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    status = s.connect_ex((target, port))
    if (status == 0):
        print('*** PORT ',port,'- OPEN ***')
    else:
        print('*** PORT ',port,'- CLOSED ***')
    s.close()
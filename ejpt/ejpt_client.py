#!/usr/bin/env python3
import socket

SRV_ADDR = input("Please input the IP to connect to: ")
SRV_PORT = int(input("Please input the port to connect to: "))

my_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
my_sock.connect((SRV_ADDR, SRV_PORT))
print("Connection established!")

msg = input("Message to send: ")
my_sock.sendall(msg.encode())
my_sock.close()
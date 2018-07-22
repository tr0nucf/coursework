#!/usr/bin/env python3
import socket

SRV_ADDR = input("Please input the IP to connect to: ")
SRV_PORT = int(input("Please input the port to connect on: "))

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

sock.connect((SRV_ADDR, SRV_PORT))
print("\n")
print("[+] Connection to server successful!")
print("[+] IP: ", SRV_ADDR)
print("[+] Port: ", SRV_PORT)
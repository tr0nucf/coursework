#!/usr/bin/env python3
import socket

SRV_ADDR = input("Type the server IP address: ")
SRV_PORT = int(input("Type the port to use: "))
# Take the user's input on the server IP and Port to use.

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
# Create a default socket connection using the default family (AF_INET) using
# TCP and the default socket type (SOCK_STREAM)

s.bind((SRV_ADDR, SRV_PORT))
# Bind binds the socket to the provided address and port

s.listen(1)
# Begin listening for incoming connections. 1 is the maximum number of connections.

print("Server started! Waiting for connections...")
connection, address = s.accept()
# Connection = socket object used to send and receive data
# Address = client's address bound to the socket

print("Client connected with address: ", address)
while 1:
    data = connection.recv(1024)
    if not data: break
    connection.sendall(b'-- Message Received --\n')
    print(data.decode('utf-8'))
connection.close()
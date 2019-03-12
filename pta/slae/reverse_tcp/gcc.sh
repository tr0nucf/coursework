#!/bin/sh
gcc -o $1 $1.c -fno-stack-protector -z execstack

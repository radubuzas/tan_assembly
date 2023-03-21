default rel                ; Use RIP-relative for [symbol] addressing modes
extern printf
extern scanf
extern fmod

section .data
    out:   	db "%f", 0xa, 0
    out1:   db "%d", 0xa, 0
    in:		db "%lf", 0
    pi:		dq	3.14159265358979323846
    unu:	dq	1.0
    doi:	dq	2.0
    zero:	dq 	0.0
    minus_unu		dq -1.0
    minus_zero		dq -0.0
    
	
section .bss
	n:		resq 1
	x:		resq 1
	y:		resq 1
	radians:	resq 1
	inc:	resd 4

section .text
    global main
    

factorial:			;factorial (int n)
	push 	rbp
	mov 	rbp, rsp
	
	movq	xmm0, qword [unu]
	
	et5:
	cmp		rdi, 1
	je		et4						; while(n)
	
	cvtsi2sd 	xmm1, rdi
	mulsd	xmm0, xmm1
	 
	sub		rdi, 1					; n--;
	jmp		et5
	
	et4:

	pop		rbp
	ret
    
power:			;power(double x, int n) - (xmm0, rdi)
	push 	rbp
	mov 	rbp, rsp
	sub		rsp, 8
	
	
	movq	xmm1, qword [unu]		; result
	
	movq	rax, xmm1
	mov		[rbp - 8], rax
	
	movq	xmm1, xmm0
	
	et3:
	cmp		rdi, 0
	je		et2						; while(n)
	
	movq	xmm0, qword [rbp - 8]			; xmm1 = result
	mulsd	xmm0, xmm1
	movq	rax, xmm0
	mov		[rbp- 8], rax
	 
	sub		rdi, 1					; n--;
	jmp		et3
	
	et2:
	movq	xmm0, qword [rbp - 8]
	
	add		rsp, 8
	pop		rbp
	ret
    
sin:						;	sin(float n)
		push 	rbp
		mov 	rbp, rsp
		sub		rsp, 32
		
		movq	[radians], xmm0
		
		xor		eax, eax
		mov		[inc], eax
		
		movq	xmm1, qword [zero]
		movq	[rbp - 8], xmm1			; result = 0
		
		et7:
		mov		eax, [inc]
		cmp		eax, 20
		je		et6						; while(n)
		
		xor 	rdi, rdi
		mov		rdi, [inc]
		movq	xmm0, qword [minus_unu]
		
		
		call	power
		
		movq	[rbp - 16], xmm0		; a = power(-1, i);
		
		xor		rax, rax
		mov		rax, [inc]
		add		rax, rax
		add		rax, 1					; rax = 2*i + 1
		
		
		mov		rdi, rax
		movq	xmm0, qword [radians]
		
		call	power
		
		movq	[rbp - 24], xmm0		; b = power(n, 2*i + 1)
		
		xor 	rax, rax
		mov		rax, [inc]
		add		rax, rax
		add		rax, 1					; rax = 2*i + 1
		
		mov		rdi, rax
				
		call 	factorial

		movq		[rbp - 32], xmm0			; c = factorial (2 * i + 1)
		
		
		movq	xmm0, qword [rbp - 16]			; xmm0 = a
		
		mov		rax, [rbp - 24]
		movq	xmm1, rax
		mulsd	xmm0, xmm1				; xmm0 = a * b

		mov		rax, [rbp - 32]
		movq	xmm1, rax
		divsd	xmm0, xmm1			; xmm1 = c
		
		
		
		addsd	xmm0, qword [rbp - 8]			; xmm1 = result
		
		movq	[rbp - 8], xmm0
	 		
	 	xor		rax, rax
	 	mov		eax, [inc]
		add		eax, 1					; n++;
		mov		[inc], eax
		
		jmp		et7
	
		et6:
		
		movq	xmm0, qword [rbp -8]
		
		add		rsp, 32
		pop	 	rbp
		ret

main:
        sub    	rsp, 8   
        
        mov	 	rsi, n
        mov 	rdi, in
		xor 	eax, eax
        call    scanf wrt ..plt			; citire n
        
        movq	xmm0, qword [n]
        
        call 	sin
        
        mov     rdi, out
        mov     eax, 1
        call    printf wrt ..plt		;	afisare n
        
        add    rsp, 8
    	xor    eax, eax               ; return 0
    	ret



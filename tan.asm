default rel                ; Use RIP-relative for [symbol] addressing modes
extern printf
extern scanf
extern fmod
extern fabs

section .data
    out:   	db "%f", 0xa, 0
    in:		db "%lf", 0
    pi:		dq	3.14159265358979323846
    unu:	dq	1.0
    doi:	dq	2.0
    zero:	dq 	0.0
    error:	dq	0.0000001
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
        
        movq 	xmm0, qword [n]			; n este redus la primul cerc
        addsd	xmm0, qword [pi]
        movq	[n], xmm0
        
        movq	xmm0, qword [pi]
        movq	xmm1, qword [doi]
        mulsd	xmm1, xmm0				;	xmm1 = 2 * pi
 		movq	xmm0, qword [n]
 		
        call 	fmod wrt ..plt
        
        movq	xmm1, qword [pi]
        subsd 	xmm0, xmm1
        movq	[n], xmm0				; n = mod(n+pi, 2pi) - pi
        
        movq	xmm0, qword [n]
        
        call 	sin 
        
        movq 	[x], xmm0				; x = sin(n)
        
        movq	xmm0, qword [pi]
        movq	xmm1, qword [doi]
        divsd	xmm0, xmm1				; xmm0 = pi/2
        
        addsd	xmm0, qword [n]			; xmm0 = n + pi/2
        
        call 	sin 
        
        movq 	[y], xmm0				; y = cos(n)
        
        call fabs	wrt ..plt
        
        movq	xmm1, qword [error]
        comisd	xmm0, xmm1
        jae		L1
        
        movq	xmm0, qword [y]
        comisd	xmm0, [zero]
        ja	L2
        
        movq	xmm0, qword [minus_zero]
        movq	[y], xmm0
        
        L2:
        
        movq	xmm0, qword [zero]
        movq	[y], xmm0
        
        L1:
        
        movq	xmm0, qword [x]
        movq	xmm1, qword [y]
        divsd	xmm0, xmm1				; xmm0 = x/y = sin/cos = tan

        mov     rdi, out
        mov     eax, 1
        call    printf wrt ..plt		;	afisare n
        
        add    rsp, 8
    	xor    eax, eax               ; return 0
    	ret



	.section	.rodata
.align 8
format_invalid:	.string	"invalid input!\n"
format_end	.char	'\0'
	.text	#Start of code
	.type	pstrlen, @function
pstrlen:
	movb	%dil, %al
	ret

	.type	replaceChar, @function
replaceChar:
	movq	%rdi, %rcx
	jmp	loop
	.cloop2			#If we got to the char we want to replace
	movb	%dl, %cl	#Maybe we need to add () on cl
	.cloop1:
	cmpb	%sil, %cl	#Checks if we're pointing to the old char
	je	cloop2
	leaq	1(%rcx), %rcx
	.loop:
	cmpb	$format_end, (%cl)
	jne	cloop1
	movq	%rdi, %rax
	ret

	.type	lowerOrUpper, @function
lowerOrUpper:
	cmpb	%dil, $64
	jle	isFalse		#Going to lable false
	cmpb	$123, %dil
	jle	isFalse
	cmpb	%dil, $90
	jle	isBig
	cmpb	$97, %dil
	jle	isSmall
	jmp	isFalse
	.isFalse: 		#The character isn't a lower or upper case
	movq	%dil, %rax
	ret
	.isBig:			#Upper case to lower case
	movb	32(%dil), %rax
	ret
	.isSmall:		#Lower case to upper case
	movb	-32(%dil), %rax
	ret

	.type	swapCase, @function
swapCase:
	movq	%rdi, %rsi
	jmp	loop
	.end:
	movq	%rsi, %rax
	ret
	.loopBody:
	call	lowerOrUpper
	movb	%rax, %dil
	leaq	1(%rdi), %rdi
	.loop:
	cmpb	$format_end, %dil
	je	end
	jmp	loopBody

	.type	pstrijcpy, @function
pstrijcpy:
	call	pstrlen		#Start of index out of bound check
	cmpb	%rax, %rcx	#End index is bigger than the dest
	jl	error_end
	cmpb	%rdx, $0	#Start index is smaller than 0
	jl	error_end
	pushq	%rdi
	movq	%rsi, %rdi
	call	pstrlen
	cmpb	%rax, %rcx	#End index is bigger than source
	jl	error_end
	popq	%rdi		#End of index out of bound check
	movq	%rdi, %r11	#Backing up dest string pointer
	leaq	(%rdi, %rdx, 8), %rdi	#Start of copy dest
	leaq	(%rsi, %rdx, 8), %rsi	#Start of copy source
	leaq	(%rdi, %rcx, 8), %r8	#End of copy dest
	leaq	(%rsi, %rcx, 8), %r9	#End of copy source
	jmp	loop
	.loop_body:
	movb	%sil, %dil
	leaq	1(%rdi), %rdi
	leaq	1(%rsi), %rsi
	.loop:
	cmpb	(%dil), (%r8b)
	je	end_succ
	jmp	loop_body
	.end_succ:
	movb	%sil, %dil
	movq	%r11, %rax
	ret
	.error_end:
	movq	$format_invalid, %rdi
	movq	$0, %rax
	call	printf
	ret
	
	.type	pstrijcmp, @function
pstrijcmp:
	call	pstrlen		#Start of index out of bound check
	cmpb	%rax, %rcx	#End index is bigger than the p1
	jl	error_end
	cmpb	%rdx, $0	#Start index is smaller than 0
	jl	error_end
	pushq	%rdi
	movq	%rsi, %rdi
	call	pstrlen
	cmpb	%rax, %rcx	#End index is bigger than p2
	jl	error_end
	popq	%rdi		#End of index out of bound check
	leaq	(%rdi, %rdx, 8), %rdi	#Start of copy p1
	leaq	(%rsi, %rdx, 8), %rsi	#Start of copy p2
	leaq	(%rdi, %rcx, 8), %r8	#End of copy p1
	leaq	(%rsi, %rcx, 8), %r9	#End of copy p2
	jmp	loop
	.finishp1:		#first string is bigger
	movq	$1, %rax
	ret
	.finishp2:		#second string is bigger
	movq	$-1, %rax
	ret
	.finish_eq:
	movq	$0, %rax
	ret
	.loop:
	cmpb	(%dil), (%sil)	#Checking if p1 is bigger
	jg	finishp1
	cmpb	(%dil), (%sil)	#Checking if p2 is bigger
	jl	finishp2
	cmpb	(%dil), (%r8d)	#Checking if we reached the final index
	je	finish_eq
	cmpb	(%dil), $format_end	#Checking if reached the end
	je	finish_eq
	cmpb	(%sil), $format_end	#Checking if we reached the end
	je	finish_eq
	leaq	1(%rdi), %rdi	#Moving forward
	leaq	1(%rsi), %rsi
	jmp	loop
	.error_end:
	movq	$format_invalid, %rdi
	movq	$0, %rax
	call	printf
	movq	$-2, %rax
	ret


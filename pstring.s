	.section	.rodata
.align 8
format_invalid:	.string	"invalid input!\n"
format_d:	.string	"%d"
format_end:	.string	"\0"
	.text	#Start of code
.global pstrlen, replaceChar, swapCase, pstrijcpy, pstrijcmp
	.type	pstrlen, @function
pstrlen:
	movzbq	0(%rdi), %rax
	ret

	.type	replaceChar, @function
replaceChar:
	movq	%rdi, %rax
	jmp	.loop
	.cloop2:			#If we got to the char we want to replace
	movb	%dl, (%rdi)	#Maybe we need to add () on cl
	.cloop1:
	cmpb	0(%rdi), %sil	#Checks if we're pointing to the old char
	je	.cloop2
	.loop:
	addq	$1, %rdi
	cmpb	$0, (%rdi)
	jne	.cloop1
	ret

	.type	lowerOrUpper, @function
lowerOrUpper:
	movq	$64, %r8
	cmpq	%rdi, %r8
	jle	.isFalse		#Going to lable false
	movq	$128, %r8
	cmpq	%r8, %rdi
	jle	.isFalse
	movq	$90, %r8
	cmpq	%rdi, %r8
	jle	.isBig
	movq	$97, %r8
	cmpq	%r8, %rdi
	jle	.isSmall
	jmp	.isFalse
	.isFalse: 		#The character isn't a lower or upper case
	movq	%rdi, %rax
	ret
	.isBig:			#Upper case to lower case
	movq	32(%rdi), %rax
	ret
	.isSmall:		#Lower case to upper case
	movq	-32(%rdi), %rax
	ret

	.type	swapCase, @function
swapCase:
	movq	%rdi, %rsi
	jmp	.loop1
	.end:
	movq	%rsi, %rax
	ret
	.loopBody:
	call	lowerOrUpper
	movq	%rax, %rdi
	leaq	1(%rdi), %rdi
	.loop1:
	cmpb	$0, %dil
	je	.end
	jmp	.loopBody


	.type	pstrijcpy, @function
pstrijcpy:
	call	pstrlen		#Start of index out of bound check
	cmpq	%rax, %rcx	#End index is bigger than the string length
	#jl	.error_end	
	movq	$0, %r8
	cmpq	%rdx, %r8	#Start index is smaller than 0
	#jl	.error_end
	pushq	%rdi
	movq	%rsi, %rdi
	call	pstrlen
	cmpq	%rax, %rcx	#End index is bigger than source length
	#jl	.error_end
	popq	%rdi		#End of index out of bound check
	movq	%rdi, %r11	#Backing up dest string pointer
	leaq	(%rdi, %rdx, 8), %rdi	#Start of copy dest
	leaq	(%rsi, %rdx, 8), %rsi	#Start of copy source
	leaq	(%rdi, %rcx, 8), %r8	#End of copy dest
	leaq	(%rsi, %rcx, 8), %r9	#End of copy source
	jmp	.loop2
	.loop_body:
	movb	%sil, %dil
	addq	$1, %rdi
	addq	$1, %rsi
	.loop2:
	cmpb	%dil, %r8b	#Checking if we reached the end of the string
	je	.end_succ
	jmp	.loop_body
	.end_succ:
	movb	%sil, %dil
	movq	%r11, %rax	#Returning a pointer to the string
	ret
	.error_end:
	movq	$format_invalid, %rdi
	movq	$0, %rax
	call	printf
	ret
	
	.type	pstrijcmp, @function
pstrijcmp:
	call	pstrlen		#Start of index out of bound check
	cmpq	%rax, %rcx	#End index is bigger than the p1
	jl	.error_end1
	movq	$0, %r8
	cmpq	%rdx, %r8	#Start index is smaller than 0
	jl	.error_end1
	pushq	%rdi
	movq	%rsi, %rdi
	call	pstrlen
	cmpq	%rax, %rcx	#End index is bigger than p2
	jl	.error_end1
	popq	%rdi		#End of index out of bound check
	leaq	(%rdi, %rdx, 8), %rdi	#Start of copy p1
	leaq	(%rsi, %rdx, 8), %rsi	#Start of copy p2
	leaq	(%rdi, %rcx, 8), %r8	#End of copy p1
	leaq	(%rsi, %rcx, 8), %r9	#End of copy p2
	jmp	.loop3
	.finishp1:		#first string is bigger
	movq	$1, %rax
	ret
	.finishp2:		#second string is bigger
	movq	$-1, %rax
	ret
	.finish_eq:
	movq	$0, %rax
	ret
	.loop3:
	cmpb	%dil, %sil	#Checking if p1 is bigger
	jg	.finishp1
	cmpb	%dil, %sil	#Checking if p2 is bigger
	jl	.finishp2
	cmpq	%rdi, %r8	#Checking if we reached the final index
	je	.finish_eq
	movq	$format_end, %r11
	cmpq	%rdi, %r11	#Checking if reached the end
	je	.finish_eq
	movq	$format_end, %r11
	cmpq	%rsi, %r11	#Checking if we reached the end
	je	.finish_eq
	leaq	1(%rdi), %rdi	#Moving forward
	leaq	1(%rsi), %rsi
	jmp	.loop3
	.error_end1:
	movq	$format_invalid, %rdi
	movq	$0, %rax
	call	printf
	movq	$-2, %rax
	ret


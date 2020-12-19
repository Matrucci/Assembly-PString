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
	cmpb	0(%rdi), %r8b
	jge	.isFalse		#Going to lable false
	movq	$123, %r8
	cmpb	%r8b, 0(%rdi)
	jge	.isFalse
	movq	$90, %r8
	cmpb	0(%rdi), %r8b
	jge	.isUpper
	movq	$97, %r8
	cmpb	%r8b, 0(%rdi)
	jge	.isLower
	jmp	.isFalse
	.isFalse: 		#The character isn't a letter
	movb	(%rdi), %al
	ret
	.isUpper:			#Upper case to lower case
	movb	(%rdi), %al
	addb	$32, %al
	ret
	.isLower:		#Lower case to upper case
	movb	(%rdi), %al
	subb	$32, %al
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
	movb	%al, (%rdi)
	addq	$1, %rdi
	.loop1:
	cmpb	$0, (%rdi)
	je	.end
	jmp	.loopBody


	.type	pstrijcpy, @function
pstrijcpy:
	call	pstrlen		#Start of index out of bound check
	cmpq	%rax, %rcx	#End index is bigger than the string length
	jge	.error_end	
	movq	$0, %r8
	cmpq	%rdx, %r8	#Start index is smaller than 0
	jg	.error_end
	movq	%rdi, %r11
	movq	%rsi, %rdi
	call	pstrlen
	cmpq	%rax, %rcx	#End index is bigger than source length
	jge	.error_end
	movq	%r11, %rdi		#End of index out of bound check

	movq	%rdi, %r11	#Backing up dest string pointer	
	inc	%rdi		#We don't count the length as an index
	inc	%rsi		#We don't count the length as an index
	leaq	(%rdi, %rcx), %r8	#End of copy dest
	leaq	(%rdi, %rdx), %rdi	#Start of copy dest
	leaq	(%rsi, %rdx), %rsi	#Start of copy source
	jmp	.loop2
	.loop_body:
	movzbq	(%rsi), %rax
	movb	%al, (%rdi)
	leaq	1(%rdi), %rdi
	leaq	1(%rsi), %rsi
	.loop2:
	cmpq	%rdi, %r8	#Checking if we reached the end of the string
	je	.end_succ
	jmp	.loop_body
	.end_succ:
	movzbq	(%rsi), %rax
	movb	%al, (%rdi)
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
	jge	.error_end1
	movq	$0, %r8
	cmpq	%rdx, %r8	#Start index is smaller than 0
	jg	.error_end1
	movq	%rdi, %r9
	movq	%rsi, %rdi
	call	pstrlen
	cmpq	%rax, %rcx	#End index is bigger than p2
	jge	.error_end1
	movq	%r9, %rdi		#End of index out of bound check

	inc	%rdi
	inc	%rsi
	leaq	(%rdi, %rcx), %r8	#End of copy p1
	leaq	(%rsi, %rcx), %r9
	leaq	(%rdi, %rdx), %rdi	#Start of copy p1
	leaq	(%rsi, %rdx), %rsi	#Start of copy p2
	jmp	.loop3

	.finishp1:		#first string is bigger
	movq	$-1, %rax
	ret

	.finishp2:		#second string is bigger
	movq	$1, %rax
	ret

	.finish_eq:
	movq	$0, %rax
	ret

	.loop3:
	movzbq	(%rsi), %rax
	cmpb	%al, (%rdi)	#Checking if p1 is bigger
	jl	.finishp1
	cmpb	%al, (%rdi)	#Checking if p2 is bigger
	jg	.finishp2
	cmpq	%rdi, %r8	#Checking if we reached the final index
	je	.finish_eq
	movq	$0, %r11
	cmpb	0(%rdi), %r11b	#Checking if reached the end
	je	.finish_eq
	movq	$0, %r11
	cmpb	0(%rsi), %r11b	#Checking if we reached the end
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


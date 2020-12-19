	.section	.rodata
format_s:	.string		" %s"
format_d:	.string		" %d"

	.text	#Start of the code
.global	run_main
	.type	run_main, @function

run_main:
	pushq	%r12		#Backing up callee save
	pushq	%r13		#Backing up callee save
	pushq	%r14		#Backing up callee save
	pushq	%rbp		#Backing up stake
	movq	%rsp, %rbp	#Saving stack state

	movq	$format_d, %rdi
	subq	$552, %rsp	
	leaq	(%rsp), %rsi
	movq	$0, %rax
	call	scanf		#Getting the first string length

	movq	%rsp, %r12	#Saving the pointer to the first string
	leaq	1(%rsp), %rsi
	movq	$format_s, %rdi
	movq	$0, %rax
	call	scanf		#Getting the first string

	xor	%r13, %r13
	movb	(%rsp), %r13b
	leaq	1(%rsp, %r13), %rsi
	movb	$0, (%rsi)	#Adding \0
	
	leaq	256(%rsp), %rsi
	movq	$format_d, %rdi
	movq	%rsi, %r13	#Saving the pointer to the second string
	movq	$0, %rax
	call	scanf		#Getting the second string length
	
	leaq	1(%r13), %rsi
	movq	$format_s, %rdi
	movq	$0, %rax
	call	scanf		#Getting the second string

	xor	%r14, %r14
	movb	(%r13), %r14b
	leaq	1(%r13, %r14), %rsi
	movb	$0, (%rsi)	#Adding \0
	
	leaq	2(%r13, %r14), %rsi
	movq	%rsi, %r14
	movq	$format_d, %rdi
	movq	$0, %rax
	call	scanf		#Getting switch code

	xor	%rsi, %rsi
	xor	%rdx, %rdx
	#leaq	257(%rsp, %r14), %rsi
	#movb	(%rsi), %dl
	
	#movq	$0, %rax
	#movq	$format_d, %rdi
	#movb	(%r14), %sil
	#call	printf
	
	xor	%rdi, %rdi
	movb	(%r14), %dil
	movq	%r12, %rsi
	movq	%r13, %rdx
	call	run_func

	movq	%rbp, %rsp
	popq	%rbp
	popq	%r14
	popq	%r13
	popq	%r12
	ret

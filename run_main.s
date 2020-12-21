#318570769	Matan Saloniko
	.section	.rodata
format_s:	.string		" %s"
format_d:	.string		" %hhu"

	.text	#Start of the code
.global	run_main
	.type	run_main, @function

run_main:
	pushq	%r12			#Backing up callee save
	pushq	%r13			#Backing up callee save
	pushq	%r14			#Backing up callee save
	pushq	%rbp			#Backing up stack
	movq	%rsp, %rbp		#Saving stack state

	movq	$format_d, %rdi
	subq	$552, %rsp	
	leaq	(%rsp), %rsi
	movq	$0, %rax
	call	scanf			#Getting the first string length

	movq	%rsp, %r12		#Saving the pointer to the first string
	leaq	1(%rsp), %rsi
	movq	$format_s, %rdi
	movq	$0, %rax
	call	scanf			#Getting the first string

	xor	%r13, %r13		#Resetting the register
	movb	(%rsp), %r13b		#Getting the length
	leaq	1(%rsp, %r13), %rsi	#Going to the end of the string
	movb	$0, (%rsi)		#Adding \0
	
	leaq	256(%rsp), %rsi		#Jumping 256 bytes to start the second string
	movq	$format_d, %rdi
	movq	%rsi, %r13		#Saving the pointer to the second string
	movq	$0, %rax
	call	scanf			#Getting the second string length
	
	leaq	1(%r13), %rsi
	movq	$format_s, %rdi
	movq	$0, %rax
	call	scanf			#Getting the second string

	xor	%r14, %r14		#Going to the end of the string
	movb	(%r13), %r14b
	leaq	1(%r13, %r14), %rsi
	movb	$0, (%rsi)		#Adding \0
	
	leaq	2(%r13, %r14), %rsi	#Jumping to the end of the second string
	movq	%rsi, %r14
	movq	$format_d, %rdi
	movq	$0, %rax
	call	scanf			#Getting switch code

	xor	%rsi, %rsi		#Resetting registers
	xor	%rdx, %rdx
	xor	%rdi, %rdi

	movb	(%r14), %dil		#Setting up for run_func
	movq	%r12, %rsi
	movq	%r13, %rdx
	call	run_func		#Calling run_func

	movq	%rbp, %rsp		#Getting back the saved values
	popq	%rbp
	popq	%r14
	popq	%r13
	popq	%r12
	ret

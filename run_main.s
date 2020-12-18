	.section	.rodata
format_s:	.string	"%c"
format_d:	.string	"%d"
format_end:	.string	"\0"

	.text	#The start of the code
.global	run_main
	.type	run_main, @function

run_main:
	pushq	%r12
	pushq	%r13
	movq	%rsp, %rbp
	movq	$format_d, %rdi	#Getting the length
	subq	$8, %rsp
	movq	%rsp, %rsi
	movq	$0, %rax
	call	scanf			#Scan the length
	addq	$2, (%rsp)
	leaq	(%rsi, %rsi, 8), %rsp
	subq	$2, (%rsp)
	pushq	(%rsi)			#Backing up the length
	movq	%rsp, %rsi
	movq	$format_s, %rdi
	movq	$0, %rax
	call	scanf			#Scan the string
	movq	$format_end, %rsi	#Adding \0 to the end
	subq	$8, %rsp
	movq	%rsp, %r12		#First pstring pointer
	#Getting pstring2
	movq	$format_d, %rdi	#Getting the length
	subq	$8, %rsp
	movq	%rsp, %rsi
	movq	$0, %rax
	call	scanf			#Scan the length
	addq	$2, (%rsp)
	leaq	(%rsi, %rsi, 8), %rsp
	subq	$2, (%rsp)
	pushq	(%rsi)			#Backing up the length
	movq	%rsp, %rsi
	movq	$format_s, %rdi
	movq	$0, %rax
	call	scanf			#Scan the string
	movq	$format_end, %rsi	#Adding \0 to the end
	subq	$8, %rsp
	movq	%rsp, %r13		#Second pstring pointer
	#Getting the switch option
	movq	$format_d, %rdi	#Getting the length
	subq	$16, %rsp
	movq	%rsp, %rsi
	movq	$0, %rax
	call	scanf			#Scan the length
	movq	(%rsp), %rdx
	movq	%r12, %rdi
	movq	%r13, %rsi
	call	run_func
	movq	(%rbp), %r13		#Getting r13 back. callee
	addq	$8, %rbp
	movq	(%rbp), %r12		#Getting r12 back. callee
	addq	$8, %rbp
	ret

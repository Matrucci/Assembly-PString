	.section	.rodata
 .align 8
.L10
 .quad .L4 #Case 50
 .quad .L9 #Case 51
 .quad .L5 #Case 52
 .quad .L6 #Case 53
 .quad .L7 #Case 54
 .quad .L8 #Case 55
 .quad .L9 #Case 56
 .quad .L9 #Case 57
 .quad .L9 #Case 58
 .quad .L9 #Case 59
 .quad .L4 #Case 60

format_length:		.string		"first pstring length: %d, second pstring length: %d\n"
format_replace:		.string		"old char: %c. new char: %c, first string: %s, second string %s\n"
format_copy:		.string		"length: %d, string %s\n"
format_swap:		.string		"length: %d, string %s\n"
format_compare:		.string		"compare result: %d\n"
format_invalid:		.string		"invalid option!\n"
format_c:		.string		"%c"
format_d:		.string		"%d"

	.text #The actual code
.global run_func
	.type	run_func, @function
run_func:
	leaq	-50(%rdi),%rcx	#Compute xi = x - 50
	cmpq	$10,%rcx	#Compare xi:10
	ja	.L9		#if >, go to default case
	jmp	*.L10(,%rcx,8)	#Goto jt[xi]

	.L4:	#rdi, rsi, rdx
		pushq	%rsi		# First string
		pushq	%rdx		# Second string
		movq	%rsi, %rdi
		call 	pstrlen		# Calling the length function
		movq	%rax, %rsi
		# movq	%rdx, %rdi
		leaq	(%rsp, 1, 8), %rdi
		pushq	%rsi
		call 	pstrlen
		movq 	$format_length, %rdi
		movq	%rax, %rdx
		movq	$0, %rax
		popq	%rsi
		call	printf
		popq	%rdx
		popq	%rsi
	.L5:
		#rdi - code, rsi - p1, rdx - p2
		movq	$format_c, %rdi
		subq	$8, %rsp
		movq	%rsi, %r9	#First pstring
		movq	%rsp, %rsi
		movq	$0, %rax
		call	scanf
		movl	(%rsp), %esi
		movq	%rsi, %r8	#First char
		movq	$0, %rax
		call	scanf
		movq	%rsi, %rcx	#Second char
		addq	$8, %rsp	#Returning rsp back to normal
		movq	%r9, %rdi	#First pstring
		movq	%r8, %rsi	#First char
		movq	%rdx, %r8	#Backing up p2
		movq	%rcx, %rdx	#Second char
		call	replaceChar
		movq	%rax, %r9	#First string swapped
		movq	%r8, %rdi
		call	replaceChar
		#rdi - string, rsi - old char, rdx - new char, rcx - first string, r8 - second string
		movq	$format_replace, %rdi
		movq	%r9, %rcx
		movq	%rax, %r8
		call	printf
	.L6:
		movq	$format_d, %rdi
		subq	$8, %rsp
		movq	%rsi, %r9	#First pString backup
		movq	%rsp, %rsi
		movq	$0, %rax
		call	scanf
		movq	%rsi, %r8	#First index - i
		movq	$0, %rax
		call	scanf
		movq	%rsi, %rcx	#Second index - j
		addq	$8, %rsp
		movq	%rdx, %rdi	#dest pstring
		movq	%r9, %rsi	#source pstring
		movq	%r8, %rdx
		call	pstrijcpy
		movq	%rax, %rdi	#changed string
		call	pstrlen
		movq	%rdi, %rdx
		movq	$format_copy, %rdi
		movq	%rax, %rsi
		movq	$0, %rax
		call	printf
		movq	%r9, %rdi
		call	pstrlen
		movq	$format_copy, %rdi
		movq	%rax, %rsi
		movq	%r9, %rdx
		movq	$0, %rax
		call	printf
	.L7:
		movq	%rsi, %rdi
		call	swapCase
		movq	%rdx, %r8	#Second pString
		movq	%rax, %rdx	#Swapped first pString
		call	pstrlen
		movq	$format_swap, %rdi
		movq	%rax, %rsi
		movq	$0, %rax
		call	printf		#Printed first swapped string
		movq	%r8, %rdi
		call	swapCase
		movq	%rax, %rdx
		call	pstrlen
		movq	%rax, %rsi
		movq	$format_swap, %rdi
		movq	$0, %rax
		call	printf
	.L8:
		pushq	%rdi	#Backing before calling to scanf
		pushq	%rsi
		pushq	%rdx
		pushq	%rcx
		
		subq	$8, %rsp
		movq	%rsp, %rsi
		movq	$format_d, %rdi
		movq	$0, %rax
		call	scanf
		pushq	%r12	#Backing up calee-saved
		movq	(%rsp), %r12
		pushq	%r13
		movq	$format_d, %rdi
		movq	$0, %rax
		call	scanf
		movq	(%rsp), %r13
		leaq	(%rsp, 6, 8), %rdi
		leaq	(%rsp, 5, 8), %rsi
		movq	%r12, %rdx
		movq	%r13, %rcx
		call	pstrijcmp
		movq	$format_compare, %rdi
		movq	%rax, %rsi
		call	printf
		
		popq	%r13
		popq	%r12
		popq	%rcx
		popq	%rdx
		popq	%rsi
		popq	%rdi
	.L9:
		movq	$format_invalid, %rdi
		call	printf

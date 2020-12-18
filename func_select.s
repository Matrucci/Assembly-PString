	.section	.rodata
 .align 8
.L10:
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
format_replace:		.string		"old char: %c. new char: %c, first string: %s, second string: %s\n"
format_copy:		.string		"length: %d, string %s\n"
format_swap:		.string		"length: %d, string %s\n"
format_compare:		.string		"compare result: %d\n"
format_invalid:		.string		"invalid option!\n"
format_c:		.string		" %c %c"
format_d:		.string		" %d"

	.text #The actual code
.global run_func
	.type	run_func, @function
run_func:
	pushq	%rbp
	movq	%rsp, %rbp
	pushq	%r12
	movq	%rsi, %r12
	pushq	%r13
	movq	%rdx, %r13
	leaq	-50(%rdi),%rcx	#Compute xi = x - 50
	cmpq	$10,%rcx	#Compare xi:10
	ja	.L9		#if >, go to default case
	jmp	*.L10(,%rcx,8)	#Goto jt[xi]
.run_finish:
	popq	%r13
	popq	%r12
	movq	%rbp, %rsp
	popq	%rbp
	ret

.L4:	#case 50
	movq	%r12, %rdi
	call 	pstrlen		#Calling the length function for the first string
		
	movq	%r13, %rdi
	pushq	%rax		#Saving the result of the first string
	call 	pstrlen		#Calling the length function for the second string

	movq	%rax, %rdx	#Moving the result of the second string length to the correct register
	movq 	$format_length, %rdi
	movq	$0, %rax
	popq	%rsi		#Getting the result back
	call	printf
	jmp	.run_finish	#Going to the end

.L5:	#case 52
	movq	$format_c, %rdi
	subq	$16, %rsp	#Preparing the stack for 2 chars
	leaq	(%rsp), %rsi
	leaq	1(%rsp), %rdx
	movq	$0, %rax
	call	scanf		#Getting 2 chars from the user

	movb	(%rsp), %sil	#Old char
	movb	1(%rsp), %dl	#new char
	movq	%r12, %rdi	#First pstring
	call	replaceChar

	movb	(%rsp), %sil	#Old char
	movb	1(%rsp), %dl	#New char
	movq	%r13, %rdi	#Second string
	call	replaceChar

	movq	$format_replace, %rdi
	movb	(%rsp), %sil
	movb	1(%rsp), %dl
	movq	%r12, %rcx	#The first string - changed
	movq	%rax, %r8	#The second string - changed
	movq	$0, %rax
	call	printf
	addq	$16, %rsp	#Returning rsp back to normal
	jmp	.run_finish

.L6:	#case 53
	movq	$format_d, %rdi	#Setting up for scanf
	subq	$16, %rsp
	leaq	(%rsp), %rsi
	movq	$0, %rax
	call	scanf		#Getting the first index from the user

	movq	$format_d, %rdi
	leaq	1(%rsp), %rsi
	movq	$0, %rax
	call	scanf		#Getting the second index

	movq	%r12, %rdi	#Getting the dest string from backup
	movq	%r13, %rsi	#Getting the source string from backup
	movb	(%rsp), %dl	#start index
	movb	1(%rsp), %cl	#finish index
	call	pstrijcpy

	movq	%rax, %rdi	#getting the length of the dest string
	pushq	%rdi		#Saving the string as it is caller save
	call	pstrlen

	popq	%rdx
	movq	$format_copy, %rdi
	movq	%rax, %rsi
	movq	$0, %rax
	call	printf		#Printing the first (changed) string

	movq	%r13, %rdi	#Getting the length of the source string
	call	pstrlen

	movq	$format_copy, %rdi
	movq	%rax, %rsi
	movq	%r13, %rdx	#Getting the first string back from the backup
	movq	$0, %rax
	call	printf
	addq	$16, %rsp	#Stack back to normal
	jmp	.run_finish	#Returning to the end
.L7:	#case 54
	movq	%r12, %rdi	#First string
	call	swapCase
	pushq	%rax		#Saving the changed string
	movq	%rax, %rdi	#Getting the length
	call	pstrlen
	movq	$format_swap, %rdi
	movq	%rax, %rsi
	popq	%rdx		#Getting back the changed string
	movq	$0, %rax
	call	printf		#Printed first swapped string
	movq	%r13, %rdi
	call	swapCase	#Swapping for the second string
	movq	%rax, %rdi
	pushq	%rax		#Saving the second swapped string
	call	pstrlen
	movq	%rax, %rsi
	movq	$format_swap, %rdi
	popq	%rdx
	movq	$0, %rax
	call	printf
	jmp	.run_finish
.L8:	#case 55
	subq	$16, %rsp
	movq	%rsp, %rsi
	movq	$format_d, %rdi
	movq	$0, %rax
	call	scanf		#Getting the first index
	leaq	1(%rsp), %rsi
	movq	$format_d, %rdi
	movq	$0, %rax
	call	scanf		#Getting the second index
	movq	%r12, %rdi	#First string
	movq	%r13, %rsi	#Second string
	movq	(%rsp), %rdx	#start index
	movq	1(%rsp), %rcx	#finish index
	call	pstrijcmp
	movq	$format_compare, %rdi
	movq	%rax, %rsi
	movq	$0, %rax
	call	printf
	addq	$16, %rsp	#Setting the stack back to normal
	jmp	.run_finish	#Going back to the finish sequence
.L9:	#default case
	movq	$format_invalid, %rdi
	movq	$0, %rax
	call	printf
	jmp	.run_finish	#Going back to the finish part

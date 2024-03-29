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
format_replace:		.string		"old char: %c, new char: %c, first string: %s, second string: %s\n"
format_copy:		.string		"length: %d, string: %s\n"
format_swap:		.string		"length: %d, string: %s\n"
format_compare:		.string		"compare result: %d\n"
format_invalid:		.string		"invalid option!\n"
format_c:		.string		" %c %c"
format_d:		.string		" %hhu"

	.text #The actual code
.global run_func
	.type	run_func, @function
run_func:
	pushq	%rbp			#Backing up the callee save registers
	movq	%rsp, %rbp		#Backing up the stack state
	pushq	%r12
	movq	%rsi, %r12		#Saving the first string
	pushq	%r13
	movq	%rdx, %r13		#Saving the second string
	leaq	-50(%rdi),%rcx		#Compute xi = x - 50
	cmpq	$10,%rcx		#Compare xi:10
	ja	.L9			#if >, go to default case
	jmp	*.L10(,%rcx,8)		#Goto jt[xi]
.run_finish:
	popq	%r13			#Getting back callee backup
	popq	%r12
	movq	%rbp, %rsp
	popq	%rbp
	ret

.L4:	#case 50
	movq	%r12, %rdi
	call 	pstrlen			#Calling the length function for the first string
		
	movq	%r13, %rdi
	pushq	%rax			#Saving the result of the first string
	call 	pstrlen			#Calling the length function for the second string

	movq	%rax, %rdx		#Moving the result of the second string length to the correct register
	movq 	$format_length, %rdi
	movq	$0, %rax
	popq	%rsi			#Getting the result back
	call	printf
	jmp	.run_finish		#Going to the end

.L5:	#case 52
	movq	$format_c, %rdi
	subq	$16, %rsp		#Preparing the stack for 2 chars
	leaq	(%rsp), %rsi
	leaq	1(%rsp), %rdx
	movq	$0, %rax
	call	scanf			#Getting 2 chars from the user

	movb	(%rsp), %sil		#Old char
	movb	1(%rsp), %dl		#new char
	movq	%r12, %rdi		#First pstring
	call	replaceChar
	movq	%rax, %r12		#Getting the changed string
	inc	%r12			#Moving it up a byte to ignore the length on print
	
	movb	(%rsp), %sil		#Old char
	movb	1(%rsp), %dl		#New char
	movq	%r13, %rdi		#Second string
	call	replaceChar
	movq	%rax, %r13		#Getting the second changed string
	inc	%r13			#Moving it up a byte to ignore the length on print

	movq	$format_replace, %rdi
	movb	(%rsp), %sil		#Old char
	movb	1(%rsp), %dl		#New char
	movq	%r12, %rcx		#The first string - changed
	movq	%r13, %r8		#The second string - changed
	movq	$0, %rax
	call	printf
	addq	$16, %rsp		#Returning rsp back to normal
	jmp	.run_finish

.L6:	#case 53
	movq	$format_d, %rdi		#Setting up for scanf
	subq	$16, %rsp
	leaq	(%rsp), %rsi
	movq	$0, %rax
	call	scanf			#Getting the first index from the user

	movq	$format_d, %rdi
	leaq	1(%rsp), %rsi
	movq	$0, %rax
	call	scanf			#Getting the second index

	movq	%r12, %rdi		#Getting the dest string from backup
	movq	%r13, %rsi		#Getting the source string from backup
	movzbq	(%rsp), %rdx		#start index
	movzbq	1(%rsp), %rcx		#finish index
	call	pstrijcpy
	
	movq	%r12, %rdi		#getting the length of the dest string
	call	pstrlen

	inc	%r12			#Moving it up a byte to ignore the length on print
	movq	%rax, %rsi
	movq	%r12, %rdx
	movq	$format_copy, %rdi
	movq	$0, %rax
	call	printf			#Printing the first (changed) string

	movq	%r13, %rdi		#Getting the length of the source string
	call	pstrlen

	movq	$format_copy, %rdi
	movq	%rax, %rsi
	inc	%r13			#Moving it up a byte to ignore the length on print
	movq	%r13, %rdx		#Getting the first string back from the backup
	movq	$0, %rax
	call	printf
	addq	$16, %rsp		#Stack back to normal
	jmp	.run_finish		#Returning to the end

.L7:	#case 54
	movq	%r12, %rdi		#First string
	call	swapCase		#Swapping the first string
	movq	%rax, %r12		#Saving the swapped string
	movq	%rax, %rdi		#Getting the length
	call	pstrlen
	movq	$format_swap, %rdi
	movq	%rax, %rsi
	inc	%r12			#Moving the first string up a byte to ignore length on print
	movq	%r12, %rdx
	movq	$0, %rax
	call	printf			#Printed first swapped string

	movq	%r13, %rdi
	call	swapCase		#Swapping for the second string
	movq	%rax, %r13		#Saving the swapped string
	movq	%rax, %rdi		#Getting the length of the second string
	call	pstrlen
	movq	%rax, %rsi
	movq	$format_swap, %rdi
	inc	%r13
	movq	%r13, %rdx
	movq	$0, %rax
	call	printf			#Printing the second (changed) string
	jmp	.run_finish

.L8:	#case 55
	subq	$16, %rsp		#Setting up the stack for 2 index
	leaq	(%rsp), %rsi
	movq	$format_d, %rdi
	movq	$0, %rax
	call	scanf			#Getting the first index

	leaq	1(%rsp), %rsi
	movq	$format_d, %rdi
	movq	$0, %rax
	call	scanf			#Getting the second index

	movq	%r12, %rdi		#First string
	movq	%r13, %rsi		#Second string
	movzbq	(%rsp), %rdx		#start index
	movzbq	1(%rsp), %rcx		#finish index
	call	pstrijcmp		#Calling the function

	movq	$format_compare, %rdi
	movq	%rax, %rsi
	movq	$0, %rax
	call	printf			#Printing the compare result
	addq	$16, %rsp		#Setting the stack back to normal
	jmp	.run_finish		#Going back to the finish sequence

.L9:	#default case
	movq	$format_invalid, %rdi
	movq	$0, %rax
	call	printf
	jmp	.run_finish		#Going back to the finish part

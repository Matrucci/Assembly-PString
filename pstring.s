#318570769	Matan Saloniko
	.section	.rodata
.align 8
format_invalid:	.string		"invalid input!\n"

	.text	#Start of code
.global pstrlen, replaceChar, swapCase, pstrijcpy, pstrijcmp

	.type	pstrlen, @function
pstrlen:
	movzbq	0(%rdi), %rax		#First byte in the string is the length
	ret

	.type	replaceChar, @function
replaceChar:
	movq	%rdi, %rax		#Setting up to return the pointer to the string
	jmp	.loop
.cloop2:				#If we got to the char we want to replace
	movb	%dl, (%rdi)		#replace the char in the string
.cloop1:
	cmpb	0(%rdi), %sil		#Checks if we're pointing to the old char
	je	.cloop2
.loop:
	addq	$1, %rdi		#Moving to the next char
	cmpb	$0, (%rdi)		#Checking if we reached the end \0
	jne	.cloop1
	ret

	.type	lowerOrUpper, @function
lowerOrUpper:				#A func that replaces upper case to lower and lower to upeer
	movq	$64, %r8		#Checking if the char is below the first letter in ASCII
	cmpb	0(%rdi), %r8b
	jge	.notAChar		#Going to the correct lable
	movq	$123, %r8		#Checking if the char is above the last letter in ASCII
	cmpb	%r8b, 0(%rdi)
	jge	.notAChar
	movq	$90, %r8		#Checking if it's an upper case letter by ASCII
	cmpb	0(%rdi), %r8b
	jge	.isUpper
	movq	$97, %r8		#Checking if the char is a lower case letter in ASCII
	cmpb	%r8b, 0(%rdi)
	jge	.isLower
	jmp	.notAChar
.notAChar: 				#The character isn't a letter
	movb	(%rdi), %al		#Sending the same char
	ret
.isUpper:				#Upper case to lower case
	movb	(%rdi), %al
	addb	$32, %al		#Sends the same letter in lower case
	ret
.isLower:				#Lower case to upper case
	movb	(%rdi), %al
	subb	$32, %al		#Sends the same letter in upper case
	ret

	.type	swapCase, @function
swapCase:
	movq	%rdi, %rsi		#Saving the string pointer
	jmp	.loop1
.end:
	movq	%rsi, %rax		#Returning the string pointer
	ret
.loopBody:
	call	lowerOrUpper		#Calling the function with the current char
	movb	%al, (%rdi)		#Replacing to the swapped char
	addq	$1, %rdi
.loop1:
	cmpb	$0, (%rdi)		#Checking if we reached the end of the string
	je	.end
	jmp	.loopBody


	.type	pstrijcpy, @function
pstrijcpy:
	movzbq	0(%rdi), %rax		#Start of index out of bound check
	cmpq	%rax, %rcx		#End index is bigger than the string length
	jge	.error_end	
	movq	$0, %r8
	cmpq	%rdx, %r8		#Start index is smaller than 0
	jg	.error_end
	movzbq	0(%rsi), %rax		#Getting the legnth of the second string
	cmpq	%rax, %rcx		#Checking if the end index is bigger than the length of the string
	jge	.error_end		#End of index out of bound check

	movq	%rdi, %r11		#Backing up dest string pointer	
	inc	%rdi			#We don't count the length as an index
	inc	%rsi			#We don't count the length as an index
	leaq	(%rdi, %rcx), %r8	#End of copy dest
	leaq	(%rdi, %rdx), %rdi	#Jump to start of copy dest
	leaq	(%rsi, %rdx), %rsi	#Jump to start of copy source
	jmp	.loop2
.loop_body:
	movzbq	(%rsi), %rax		#Getting the char from the source
	movb	%al, (%rdi)		#Moving the char to the dest
	leaq	1(%rdi), %rdi		#Going to the next char
	leaq	1(%rsi), %rsi		#Going to the next char
.loop2:
	cmpq	%rdi, %r8		#Checking if we reached the end of the string
	je	.end_succ
	jmp	.loop_body
.end_succ:
	movzbq	(%rsi), %rax		#Copying the last char
	movb	%al, (%rdi)
	movq	%r11, %rax		#Returning a pointer to the string
	ret
.error_end:
	movq	$format_invalid, %rdi	#Printing an invalid message
	movq	$0, %rax
	call	printf
	ret
	
	.type	pstrijcmp, @function
pstrijcmp:
	movzbq	0(%rdi), %rax		#Start of index out of bound check
	cmpq	%rax, %rcx		#End index is bigger than the p1
	jge	.error_end1
	movq	$0, %r8
	cmpq	%rdx, %r8		#Start index is smaller than 0
	jg	.error_end1
	movzbq	0(%rsi), %rax		#Getting the length of the second string
	cmpq	%rax, %rcx		#End index is bigger than p2
	jge	.error_end1		#End of index out of bound check

	inc	%rdi			#Ignoring the length
	inc	%rsi			#Ignoring the length
	leaq	(%rdi, %rcx), %r8	#Jump to end of copy p1
	leaq	(%rsi, %rcx), %r9	#Jump to end of copy p2
	leaq	(%rdi, %rdx), %rdi	#Jump to start of copy p1
	leaq	(%rsi, %rdx), %rsi	#Jump to start of copy p2
	jmp	.loop3

.finishp1:				#first string is bigger
	movq	$-1, %rax
	ret

.finishp2:				#second string is bigger
	movq	$1, %rax
	ret

.finish_eq:				#Strings are equal
	movq	$0, %rax
	ret

.loop3:
	movzbq	(%rsi), %rax		#Getting the char from p2
	cmpb	%al, (%rdi)		#Checking if p1 is bigger
	jl	.finishp1
	cmpb	%al, (%rdi)		#Checking if p2 is bigger
	jg	.finishp2
	cmpq	%rdi, %r8		#Checking if we reached the final index
	je	.finish_eq
	movq	$0, %r11
	cmpb	0(%rdi), %r11b		#Checking if we reached the end of the first string
	je	.finish_eq		#Reaching here without a verdict means they are equal
	movq	$0, %r11
	cmpb	0(%rsi), %r11b		#Checking if we reached the end of the second string
	je	.finish_eq		#Reaching here without a verdict means they are equal
	leaq	1(%rdi), %rdi		#Moving forward
	leaq	1(%rsi), %rsi		#Moving forward
	jmp	.loop3

.error_end1:
	movq	$format_invalid, %rdi	#Printing an error message
	movq	$0, %rax
	call	printf
	movq	$-2, %rax
	ret


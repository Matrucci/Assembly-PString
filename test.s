	.section	.rodata
.align 8

format_d:		.string		"%d"
format_dd:	.string		"The number is %d\n"
	.text
.global main
	.type main, @function
main:
	movq	$format_d, %rdi
	subq	$8, %rsp
	movq	%rsp, %rsi
	movq	$0, %rax
	call	scanf
	movl	(%rsp), %esi
	movq	$format_dd, %rdi
	movq	$0, %rax
	call	printf
	addq	$8, %rsp

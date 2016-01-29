	.data
array: 	.word -1000, 234, -3, 9000, 0
max:	.word 0

	.text
main:	
	li 	$t1, 4
	lw 	$t2, array
loop:		
	lw	$t3, array($t1)
	bge	$t2, $t3, fi
	add	$t2, $t3, $zero
fi:	
	addi	$t1, $t1, 4
	blt	$t1, 20, loop
	sw	$t2, max
	li 	$v0, 10
	syscall

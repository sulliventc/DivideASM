# By Colten Sullivent
# CS 260
# 10/21/18

.data
err:	.asciiz "Error: Divide by 0\n"
prmpt1: .asciiz "Enter a numerator: "
prmpt2: .asciiz "\nEnter a denominator: "
end1:	.asciiz "\nQuotient: "
end2:	.asciiz "\nRemainder: "
	.align 2
saven:	.word
.text

la	$a0, prmpt1
li	$v0, 4
syscall
li	$v0, 5
syscall
sw	$v0, saven($0)


la	$a0, prmpt2
li	$v0, 4
syscall
li	$v0, 5
syscall
move	$a1, $v0
lw	$a0, saven($0)

jal 	divide

la 	$t0, saven
sw 	$v1, 0($t0)
sw 	$v0, 4($t0)

la 	$a0, end1
li 	$v0, 4
syscall
la 	$t0, saven
lw 	$a0, 4($t0)
li 	$v0, 1
syscall
la 	$a0, end2
li 	$v0, 4
syscall
la 	$t0, saven
lw 	$a0, 0($t0)
li 	$v0, 1
syscall
li 	$v0, 10
syscall

divide:	beq 	$a1, $0, dbze 	# tried to divide by 0
	subi 	$sp, $sp, 8 	# make room for 2 registers on stack
	sw 	$s0, 0($sp) 	# save $s0 to stack
	sw 	$s1, 4($sp) 	# save $s1 to stack
	move 	$s0, $a0 	# numerator
	move 	$s1, $a1 	# denominator
	addi 	$sp, $sp, -4 	# make room for 1 register on stack
	sw 	$ra, 0($sp) 	# save $ra to stack
	jal 	msb		# get n
	lw 	$ra, 0($sp) 	# load $ra from the stack
	addi 	$sp, $sp 4 	# remove space for register
	move 	$t0, $v0 	# n
	li 	$t1, 0 		# quotient
	li 	$t2, 0 		# remainder
divl:	addi 	$t0, $t0, -1 	# n = n - 1
	bltz 	$t0, divr 	# if n == -1, we're done
	sll 	$t2, $t2, 1 	# Shift R left one
	li 	$t3, 1 		# store 1
	and 	$t4, $t3, $t2 	# mask AND R -> LSB
	sllv 	$t3, $t3, $t0 	# move mask into position
	and 	$t3, $s0, $t3 	# mask AND N -> mask
	srlv 	$t3, $t3, $t0 	# move mask back
	beq 	$t3, $t4, endif # check if they're already equal
	xor 	$t2, $t3, $t2 	# flip LSB if they're not
endif:	blt 	$t2, $s1, divl 	# skip if R < D
	sub 	$t2, $t2, $s1 	# R = R - D
	li 	$t3, 1 		# create mask
	sllv 	$t3, $t3, $t0 	# shift mask by n places
	or 	$t1, $t1, $t3 	# Set nth bit of Quotient to 1
	j 	divl 		# restart loop
divr:	move 	$v0, $t1 	# prepare to return quotient
	move 	$v1, $t2 	# prepare to return remainder
	lw 	$s1, 4($sp) 	# retrieve original $s1
	lw 	$s0, 0($sp) 	# retrieve original $s0
	addi 	$sp, $sp, 8 	# remove stack space
	jr 	$ra 		# return

msb:	move 	$t0, $a0 	# store argument for work
	li 	$t1, 0 		# prepare i
msbl:	beqz 	$t0, msbr 	# end the loop
	srl 	$t0, $t0, 1 	# shift $t0 right
	addi 	$t1, $t1, 1 	# increment i
	j 	msbl 		# restart loop
msbr:	move 	$v0, $t1 	# prepare to return
	jr 	$ra 		# return

dbze:	li 	$v0, 4 		# load print string syscall
	la 	$a0, err 	# load err to be printed
	syscall 		# print err
	li 	$v0, 10 	# load terminate syscall
	syscall 		# terminate
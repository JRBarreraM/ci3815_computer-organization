.data
myarray: .word 12,13,10
newline: .asciiz "\n"

.text
main:
	# Clear $t0 to 0
	addi $t0,$zero,0
	
	while:
	beq $t0,12,exit
	lw $t6,myarray($t0)
	addi $t0,$t0,4
	#Prints current number
	li $v0,1
	move $a0,$t6
	syscall
	#Prints a new line
	li $v0,4
	la $a0,newline
	syscall
	
	j while
	
	exit:
	#Tells system this is the end of program
	li $v0,10
	syscall
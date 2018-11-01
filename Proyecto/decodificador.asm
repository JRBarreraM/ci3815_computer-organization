.data
test: .word 0x10000000
operation_code: .word 	32,       8,     40,      12,    24,    37,      13,      4,      34,      35,      43,      5,       6,       0
operation_type: .asciiz "R",      "I",   "R",     "I",   "R",   "R",     "I",     "R",    "R",     "I",     "I",     "I",     "I",     "R"
operation_name: .asciiz "add","", "addi","and","","andi","mult","or"," ","ori","","sllv", "sub","","lw"," ","sw"," ","bne","","beq","","halt"
I: .asciiz "I"
dollar: .asciiz "$"
space: .asciiz " "
left_parentesis: .ascii "("
right_parentesis: .ascii ")"
newline: .asciiz "\n"

.text
main:

	# Clear $t2 to 0
	addi $t2,$zero,0
	# Clear $t4 to 0
	addi $t4,$zero,0
	# Clear $t4 to 0
	addi $t5,$zero,0
	la $t7,I
			
	#Extract oc
	lw $t0,test
	andi $t1,$t0,0xfc000000
	srl $t1, $t1, 26
	
	while_search:
	beq $t4,56,exit
	lw $t3,operation_code($t4)
	#Begin the decodification
	beq $t1,$t3,search_oc
	addi $t2,$t2,2
	addi $t4,$t4,4
	addi $t5,$t5,5
	j while_search
	
	search_oc:
	#Prints index
#	li $v0,1
#	move $a0,$t2
#	syscall
	#Prints index
#	li $v0,1
#	move $a0,$t4
#	syscall
	#Prints index
#	li $v0,1
#	move $a0,$t5
#	syscall
	
	#Prints operation raw
	li $v0,34
	lw $a0,test
	syscall
	
	#Prints a blank space
	li $v0,4
	la $a0,space
	syscall
			
	#Prints operation type
	li $v0,4
	la $a0,operation_type($t2)
	syscall

	#Prints a blank space
	li $v0,4
	la $a0,space
	syscall

	#Prints operation name
	li $v0,4
	la $a0,operation_name($t5)
	syscall

	#Prints a blank space
	li $v0,4
	la $a0,space
	syscall
	
	#Print registers
	#Extract rs
	lw $t0,test
	andi $t6,$t0,0x07c00000
	srl $t6, $t6, 21
	#Prints a dollar
	li $v0,4
	la $a0,dollar
	syscall	
	#Print rs
	li $v0,1
	move $a0,$t6
	syscall
	#Prints a blank space
	li $v0,4
	la $a0,space
	syscall
	#Extract rt
	lw $t0,test
	andi $t6,$t0,0x001f0000
	srl $t6, $t6, 16
	#Prints a dollar
	li $v0,4
	la $a0,dollar
	syscall
	#Print rt
	li $v0,1
	move $a0,$t6
	syscall
	#Prints a blank space
	li $v0,4
	la $a0,space
	syscall
	
	la $t6,operation_type($t2)
	beq $t7,$t6,typeI
	
	#Extract rd
	lw $t0,test
	andi $t6,$t0,0x0000f800
	srl $t6, $t6, 11
	#Prints a dollar
	li $v0,4
	la $a0,dollar
	syscall
	#Print rd
	li $v0,1
	move $a0,$t6
	syscall
	
	typeI:
	#Extract address
	lw $t0,test
	andi $t6,$t0,0x0000ffff
	#Print address
	li $v0,1
	move $a0,$t6
	syscall	
	
	#Prints a new line
	li $v0,4
	la $a0,newline
	syscall
	j exit
	
	exit:
	#Tells system this is the end of program
	li $v0,10
	syscall

.data
test: .word 0x8c000000
lw_case: .word 35
sw_case: .word 43
operation_code: .word 	32,       8,     40,      12,    24,    37,      13,      4,      34,      35,      43,      5,       6,       0
operation_type: .asciiz "R",      "I",   "R",     "I",   "R",   "R",     "I",     "R",    "R",     "I",     "I",     "I",     "I",     "R"
operation_name: .asciiz "add","", "addi","and","","andi","mult","or"," ","ori","","sllv", "sub","","lw"," ","sw"," ","bne","","beq","","halt"
I: .asciiz "I"
dollar: .asciiz "$"
space: .asciiz " "
left_parentesis: .asciiz "("
right_parentesis: .asciiz ")"
newline: .asciiz "\n"

.text
main:

	# Inicializamos $t2 en 0, iterador de operation_type
	addi $t2,$zero,0
	# Inicializamos $t4 en 0, iterador de operation_code
	addi $t4,$zero,0
	# Inicializamos $t5 en 0, iterador de operation_name
	addi $t5,$zero,0
	# Almacenamos en $t7 el ascii I	
	la $t7,I
	lw $t8,lw_case
	lw $t9,sw_case
			
	#Extraemos el código de operación
	lw $t0,test			
	andi $t1,$t0,0xfc000000	#apagamos los bits que no corresponde al c.o.
	srl $t1, $t1, 26	#rodamos el c.o. al inicio
	
	while_search:		#iteramos sobre el arreglo de c.o. buscando la instrucción
	beq $t4,56,exit		#iteramos hasta 56 porque hay 14 c.o.
	lw $t3,operation_code($t4)
	beq $t1,$t3,undecode	#si encontramos el c.o. comenzamos la decodificación
	addi $t2,$t2,2		#incremetamos las variables de iteración
	addi $t4,$t4,4
	addi $t5,$t5,5
	j while_search		#loop
	
	undecode:
	
	#Imprimimos la instrucción leída en hex
	li $v0,34
	lw $a0,test
	syscall
	
	#Imprimimos un espacio en blanco
	li $v0,4
	la $a0,space
	syscall
			
	#Imprimimos el tipo de operación
	li $v0,4
	la $a0,operation_type($t2)
	syscall

	#Imprimimos un espacio en blanco
	li $v0,4
	la $a0,space
	syscall

	#Imprimimos el nombre de la operación
	li $v0,4
	la $a0,operation_name($t5)
	syscall

	#Imprimimos un espacio en blanco
	li $v0,4
	la $a0,space
	syscall

#Hay operaciones que no siguen el formato R o I exactamente, por lo que son casos especiales
	
	beq $t3,0,exit		#la instreccion es halt
	beq $t3,$t8,lw_sw_case	#la instruccion es lw o sw
	beq $t3,$t9,lw_sw_case
	
	#Imprimimos los registros involucrados
	#Extraemos el rs
	lw $t0,test
	andi $t6,$t0,0x03e00000	#apagamos los bits que no corresponde al rs
	srl $t6, $t6, 21	#rodamos el rs al inicio
	#Imprimimos el signo de dólar
	li $v0,4
	la $a0,dollar
	syscall	
	#Imprimimos el rs
	li $v0,1
	move $a0,$t6
	syscall
	#Imprimimos un espacio en blanco
	li $v0,4
	la $a0,space
	syscall
	#Extraemos el rt
	lw $t0,test
	andi $t6,$t0,0x001f0000 #apagamos los bits que no corresponde al rt
	srl $t6, $t6, 16	#rodamos el rt al inicio
	#Imprimimos el signo de dólar
	li $v0,4
	la $a0,dollar
	syscall
	#Imprimimos el rt
	li $v0,1
	move $a0,$t6
	syscall
	#Imprimimos un espacio en blanco
	li $v0,4
	la $a0,space
	syscall
	
	la $t6,operation_type($t2)#si la operacion es de tipo I, decodificamos
	beq $t7,$t6,typeI	#la direccion de de 16 bits (offset), sino es de tipo R
				#y decodificamos el registro faltante (rd)
	#Extraemos el rd
	lw $t0,test
	andi $t6,$t0,0x0000f800 #apagamos los bits que no corresponde al rd
	srl $t6, $t6, 11	#rodamos el rd al inicio
	#Imprimimos el signo de dólar
	li $v0,4
	la $a0,dollar
	syscall
	#Imprimimos el rd
	li $v0,1
	move $a0,$t6
	syscall
	
	#Imprimimos una nueva linea
	li $v0,4
	la $a0,newline
	syscall
	
	typeI:
	#Extraemos el offset
	lw $t0,test
	andi $t6,$t0,0x0000ffff #apagamos los bits que no corresponde al offset
	#Imprimimos el offset	#ya esta al inicio
	li $v0,1
	move $a0,$t6
	syscall	
	
	#Imprimimos una nueva linea
	li $v0,4
	la $a0,newline
	syscall
	
	lw_sw_case:
	#Extraemos el rt
	lw $t0,test
	andi $t6,$t0,0x001f0000 #apagamos los bits que no corresponde al rt
	srl $t6, $t6, 16	#rodamos el rt al inicio
	#Imprimimos el signo de dólar
	li $v0,4
	la $a0,dollar
	syscall
	#Imprimimos el rt
	li $v0,1
	move $a0,$t6
	syscall
	#Imprimimos un espacio en blanco
	li $v0,4
	la $a0,space
	syscall

	#Extraemos el offset
	lw $t0,test
	andi $t6,$t0,0x0000ffff #apagamos los bits que no corresponde al offset
	#Imprimimos el offset	#ya esta al inicio
	li $v0,1
	move $a0,$t6
	syscall

	#Imprimimos un paréntesis izquierdo
	li $v0,4
	la $a0,left_parentesis
	syscall
	#Imprimimos el signo de dólar
	li $v0,4
	la $a0,dollar
	syscall
	
	#Extraemos el rs
	lw $t0,test
	andi $t6,$t0,0x03e00000	#apagamos los bits que no corresponde al rs
	srl $t6, $t6, 21	#rodamos el rs al inicio
	#Imprimimos el rs
	li $v0,1
	move $a0,$t6
	syscall

	#Imprimimos un paréntesis derecho
	li $v0,4
	la $a0,right_parentesis
	syscall
	
	#Imprimimos una nueva linea
	li $v0,4
	la $a0,newline
	syscall
	
	exit:
	#no hacemos nada mas,terminariomos el programa,pero eso corresponde al main

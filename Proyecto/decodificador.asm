.data
test: .word 0xac242424
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
#---------------------------------------------------------------FASE_2---------------------------------------------------------------
#PLANIFICACION DE REGISTROS FASE 2:
#		0. $t0 : almacena la instrucción en hexa que se va a traducir e imprimir
#		1. $t1 : almacena los 6 primeros bits de la instrucción (código de operación)
#		2. $t2 : almacena el índice del arreglo de tipos de operación correspondiente a la operación por la
#			 que se pasea la búsqueda en un momento dado (iterador de operation_type)
#		3. $t3 : almacena el código de operación correspondiente a la operación por la que se pasea la búsqueda
#			 en un momento dado, y luego de encontrada la operación, se usa como temporal para información que
#			 se extraiga de la operación para imprimirla (rd,rs,rt u offset)
#		4. $t4 : almacena el índice del arreglo de códigos de operación correspondiente a la operación por la
#			 que se pasea la búsqueda en un momento dado (iterador de operation_code)
#		5. $t5 : almacena el índice del arreglo de nombres de operación correspondiente a la operación por la
#			 que se pasea la búsqueda en un momento dado (iterador de operation_name)
#		7. $t6 : almacena el .asciiz "I"
#

main:
	# Inicializamos $t2 en 0, iterador de operation_type
	addi $t2,$zero,0
	# Inicializamos $t4 en 0, iterador de operation_code
	addi $t4,$zero,0
	# Inicializamos $t5 en 0, iterador de operation_name
	addi $t5,$zero,0
	# Almacenamos en $t6 el ascii I	
	la $t6,I
			
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
	
	beq $t3,0,exit		#la instrucción es halt
	beq $t3,35,lw_sw_case	#la instrucción es lw o sw
	beq $t3,43,lw_sw_case
	la $t3,operation_type($t2)#verificamos si la operacion es de tipo I
	beq $t3,$t6,typeI	#sino es de tipo R

	#Imprimimos en formato R
	
	#Extraemos el rd
	lw $t0,test
	andi $t3,$t0,0x0000f800 #apagamos los bits que no corresponde al rd
	srl $t3, $t3, 11	#rodamos el rd al inicio
	#Imprimimos el signo de dólar
	li $v0,4
	la $a0,dollar
	syscall
	#Imprimimos el rd
	li $v0,1
	move $a0,$t3
	syscall

	#Imprimimos un espacio en blanco
	li $v0,4
	la $a0,space
	syscall
	
	#Extraemos el rs
	lw $t0,test
	andi $t3,$t0,0x03e00000	#apagamos los bits que no corresponde al rs
	srl $t3, $t3, 21	#rodamos el rs al inicio
	#Imprimimos el signo de dólar
	li $v0,4
	la $a0,dollar
	syscall	
	#Imprimimos el rs
	li $v0,1
	move $a0,$t3
	syscall

	#Imprimimos un espacio en blanco
	li $v0,4
	la $a0,space
	syscall

	#Extraemos el rt
	lw $t0,test
	andi $t3,$t0,0x001f0000 #apagamos los bits que no corresponde al rt
	srl $t3, $t3, 16	#rodamos el rt al inicio
	#Imprimimos el signo de dólar
	li $v0,4
	la $a0,dollar
	syscall
	#Imprimimos el rt
	li $v0,1
	move $a0,$t3
	syscall

	#Imprimimos una nueva linea
	li $v0,4
	la $a0,newline
	syscall
	j exit	#terminamos con la operación

	#Imprimimos en formato I
	typeI:

	#Extraemos el rt
	lw $t0,test
	andi $t3,$t0,0x001f0000 #apagamos los bits que no corresponde al rt
	srl $t3, $t3, 16	#rodamos el rt al inicio
	#Imprimimos el signo de dólar
	li $v0,4
	la $a0,dollar
	syscall
	#Imprimimos el rt
	li $v0,1
	move $a0,$t3
	syscall
	#Imprimimos un espacio en blanco
	li $v0,4
	la $a0,space
	syscall

	#Extraemos el rs
	lw $t0,test
	andi $t3,$t0,0x03e00000	#apagamos los bits que no corresponde al rs
	srl $t3, $t3, 21	#rodamos el rs al inicio
	#Imprimimos el signo de dólar
	li $v0,4
	la $a0,dollar
	syscall	
	#Imprimimos el rs
	li $v0,1
	move $a0,$t3
	syscall
	#Imprimimos un espacio en blanco
	li $v0,4
	la $a0,space
	syscall

	#Extraemos el offset
	lw $t0,test
	andi $t3,$t0,0x0000ffff #apagamos los bits que no corresponde al offset
	#Imprimimos el offset	#ya esta al inicio
	li $v0,1
	move $a0,$t3
	syscall	
	
	#Imprimimos una nueva linea
	li $v0,4
	la $a0,newline
	syscall
	j exit	#terminamos con la operación
	
	lw_sw_case:
	#Extraemos el rt
	lw $t0,test
	andi $t3,$t0,0x001f0000 #apagamos los bits que no corresponde al rt
	srl $t3, $t3, 16	#rodamos el rt al inicio
	#Imprimimos el signo de dólar
	li $v0,4
	la $a0,dollar
	syscall
	#Imprimimos el rt
	li $v0,1
	move $a0,$t3
	syscall
	#Imprimimos un espacio en blanco
	li $v0,4
	la $a0,space
	syscall

	#Extraemos el offset
	lw $t0,test
	andi $t3,$t0,0x0000ffff #apagamos los bits que no corresponde al offset
	#Imprimimos el offset	#ya esta al inicio
	li $v0,1
	move $a0,$t3
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
	andi $t3,$t0,0x03e00000	#apagamos los bits que no corresponde al rs
	srl $t3, $t3, 21	#rodamos el rs al inicio
	#Imprimimos el rs
	li $v0,1
	move $a0,$t3
	syscall

	#Imprimimos un paréntesis derecho
	li $v0,4
	la $a0,right_parentesis
	syscall
	
	#Imprimimos una nueva linea
	li $v0,4
	la $a0,newline
	syscall
	j exit	#terminamos con la operación
	
	exit:
	#no hacemos nada mas,terminariomos el programa,pero eso corresponde al main

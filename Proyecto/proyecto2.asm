.data
archivo: .space 100 #reservamos 100 suponiendo que cada archivo no tiene mas de 100 caracteres
buffer: .space 900  #reservamos 900 porque cada linea de codigo en ascii necesita 9 bytes incluyendo el \n
.align 2
programa:.space 400 #un programa de 900 bytes en ascii se convertira en uno de 400 en lenguaje ensamblador 
codigoinstrucciones: .word 
.text
#INPUT:
	la $a0 archivo		#direccion para el input
	la $a1 100		#numero maximo de caracteres para el nombre del archivo
	li $v0 8		#instruccion para input de string
	syscall
	
looparchivo:#para buscar el /n y quitarlo del nombre del archivo
	lb $s0 ($a0)		#cargamos un byte
	addi $a0 $a0 1		#sumamos 1 byte a la direccion para la siguiente iteracion
	bne $s0 10 looparchivo  #si no es \n volvemos al loop
	subi $a0 $a0 1		#si es \n regresamos un byte la posicion
	sb $zero ($a0)		#cargamos 0 en ese byte y listo
	
	
#LEYENDO ARCHIVO:
	li $v0 13		#codigo para abrir archivo
	la $a0 archivo		#cargamos el nombre del archivo
	li $a1 0		#modo 0 para lectura solo
	syscall		
	move $a0 $v0		#pasamos a a0 el apunatdor al archivo	
	li $v0 14		#codigo para lectura
	la $a1 buffer		#pasamos a a1 la direccion donde leer
	li $a2 900		#maxima cantidad de caracteres a leer
	syscall
	
#TRADUCIENDO:
	la $s0 buffer		#guardamos la direcion en la que se encuentra el contenido leido
	la $s1 programa		#guardamos la direccion en donde empezamos a traducir
	subi $s1 $s1 1		#reducimos en uno dicha direccion para poder aprovecharnos de sumar 4 luego
	
loop:
	move $a0 $zero		#inicializamos a0 en 0 para que haga de contador
	addi $s1 $s1 4		#sumamos 4 a la posicion donde vamos a escribir para que vayamos de isquierda a derecha
	move $s2 $s1		#guardamos una copia del actual s1 la cual servira para pasear por cada uno de los 4 bytes de la palabra

loop2:
	beq $a0  4 loop        #regresamos al loop si el contado a0 llega a 4
	lb $a1 ($s0)	       #cargamos el primer byte que viene en notacion ascii
	lb $a2 1($s0)	       #cargamos el segundo byte ascii
	beq $a1 10 regresarloop2	#si a1 es un \n vamos a regresarloop2
	beq $a2 $zero decodificacion	#si a2 es 0 significa que alcanzamos la ultima linea, nos vamnos a decodificar
	subi $t0 $a1 48			#restamos 48 y lo guardamos en t0 para saber si a1 es un numero
	subi $t1 $a2 48			#restamos 48y lo guardamos en t1  para saber si a2 es un numero
	ble $t0 10 caso1 #caso en el que el primer byte es un numero
	ble $t1 10 caso2 #caso en el que el primer byte es letra y el segundo numero
	#caso 2.1: el primer byte es letra y el segundo tambien
	subi $a1 $a1 87		#como a1 es una letra restamos 87
	subi $a2 $a2 87		#como a2 es una letra restamos 87
	sll $a1 $a1 4		#a1 va primero asi que hacemos shift
	or $a3 $a1 $a2		#luego el or fusiona a a1 y a2 dejando a a1 en la posicion dominante
	sb $a3 ($s2)		#guardamos el byte fusionado en la posicion respectiva
	subi $s2 $s2 1		#restamos a s2 una posicion para la siguiente asignacion
	addi $a0 $a0 1		#a0 sube 1 ya que es un contador
	addi $s0 $s0 2		#aumentar en 2 s0 para escoger los siguientes 2 bytes nuevos
	j loop2
	
regresarloop2:#en caso de \n 
	addi $s0 $s0 1	#aumentamos en 1 el contador s0 para ignorarlo
	j loop2		#y volvemos a comenzar el loop2 con \n ignorado	
	
caso1:#primer byte es un numero y segundo byte es letra
	ble $t1 10 caso1.1 #caso en el que el primer byte es un numero y el segundo tambien
	#analogo al caso 2.1
	subi $a1 $a1 48
	subi $a2 $a2 87
	sll $a1 $a1 4
	or $a3 $a1 $a2
	sb $a3 ($s2)
	subi $s2 $s2 1
	addi $a0 $a0 1
	addi $s0 $s0 2
	j loop2
	
caso1.1:#primer byte es un numero y segundo byte tambien
	#analogo al caso 2.1
	subi $a1 $a1 48
	subi $a2 $a2 48
	sll $a1 $a1 4
	or $a3 $a1 $a2
	sb $a3 ($s2)
	subi $s2 $s2 1
	addi $a0 $a0 1
	addi $s0 $s0 2
	j loop2
	
caso2:#primer byte es una letra y segundo byte es numero
	#analogo al caso2.1
	subi $a1 $a1 87
	subi $a2 $a2 48
	sll $a1 $a1 4
	or $a3 $a1 $a2
	sb $a3 ($s2)
	subi $s2 $s2 1
	addi $a0 $a0 1
	addi $s0 $s0 2
	j loop2
	
	
decodificacion:
	
fin: 
	li $v0 10
     	syscall 
######################################################################



# add  R 32 100000 add $rd, $rs, $rt $   $rd = $rs + $rt
# addi I 08 001000 add $rt, $rs, Offset  $rt= $rs + ExtSigno(Offset)
# and  R 40 101000 and $rd, $rs, $rt     $rd = $rs & $rt
# andi I 12 001100 andi $rs, $rt, Offset $rt = $s & ExtCero(Offset)
# mult R 24 011000 mult $rd, $rs, $rt    $rd = $rs * $rt
# or   R 37 100101 or $rd, $rs, $rt      $rd = $rs | $rt
# ori  I 13 001101 ori $rt, $rs, Offset  $rt = $rs | ExtCero(Offset)
# sllv R 04 000100 sllv $rd, $rt, $rs    $rd = $rt << $rs
# sub  R 34 100010 sub $rd, $rs, $rt     $rd = $rs - $rt
# lw   I 35 100011 lw $rt, Offset($rs)   $rt = Mem[$rs+ExtSigno(Offset) 
# sw   I 43 101011 sw $rt, Offset($rs)   Mem[$rs+ExtSigno(Offset)= $rt 
# bne  I 05 000101 bne $rs, $rt, Offset
# beq  I 06 000110 beq $rs, $rt, Offset
# halt R 00 000000 halt                  Detiene ejecución

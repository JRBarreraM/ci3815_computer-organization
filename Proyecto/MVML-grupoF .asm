#CI3815-ORGANIZACION DEL COMPUTADOR

#MVML: Maquina Virtual MIPS Ligero

#GRUPO F
#15-10123 Jose Barrera
#15-11550 Jean Paul Yazbek

.data
#DATOS FASE 2:

#Conjunto De Instrucciones
operation_code: .word 	32,       8,     40,      12,    24,    37,      13,      4,      34,      35,      43,      5,       6,       0
operation_type: .asciiz "R",      "I",   "R",     "I",   "R",   "R",     "I",     "R",    "R",     "I",     "I",     "I",     "I",     "R"
operation_name: .asciiz "add","", "addi","and","","andi","mult","or"," ","ori","","sllv", "sub","","lw"," ","sw"," ","bne","","beq","","halt"

I: .asciiz "I"
dollar: .asciiz "$"
space: .asciiz " "
left_parentesis: .asciiz "("
right_parentesis: .asciiz ")"
newline: .asciiz "\n"
MensajeNoEncontrado: .asciiz "La operacion no fue encontrada en el conjunto de instrucciones de la MVML"

#DATOS FASE 1:
archivo: .space 100 #reservamos 100 suponiendo que cada archivo no tiene mas de 100 caracteres
buffer: .space 900  #reservamos 900 porque cada linea de codigo en ascii necesita 9 bytes incluyendo el \n
.align 2
programa:.space 404 #un programa de 900 bytes en ascii se convertira en uno de 400 en lenguaje ensamblador 

.text
#-----------------------------------------FASE_1-------------------------------------------------------------------------------------
#PLANIFICACION DE REGISTROS FASE 1:
#		Los mas relevantes son los usados en la sub face de traduccion:
#		0. $a0 : un contador que va de 0 a 4 para seber cuando hemos llenado los 4 bytes de una palabra
#		1. $a1 : aqui guardaremos la primera letra ascii que leamos
#		2. $a2: aqui guardamos la segunda letra ascii que leamos
#		3. $a3: si el contenido de $a1 y $a2 no es \n ni vacio entonces cargamos aqui la mezcla de ambos en una sola palabra
#			para luego cargarlo como byte
#		4. $t0: guardamos el contenido de $a1 - 48 para comparaciones que nos permitan saber si el ascii es numero o letra
#		5. $t1: guardamos el contenido de $a2 - 48 para comparaciones que nos permitan saber si el ascii es numero o letra
#		6. $so : contiene la direccion del buffer, es decir de los ascii leidos en la sub face de "Leyendo archivo"
#		7. $s1 : la direccion del espacio reservado para la traduccion, es decir el programa
#		8. $s2 : una copia de la direccion en $s1 que usaremos para movernos byte por byte
# 		
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
	addi $s1 $s1 4		#sumamos 4 a la posicion donde vamos a escribir para que vayamos de izquierda a derecha
	move $s2 $s1		#guardamos una copia del actual s1 la cual servira para pasear por cada uno de los 4 bytes de la palabra

	loop2:
	beq $a0  4 loop        #regresamos al loop si el contador a0 llega a 4
	lb $a1 ($s0)	       #cargamos el primer byte que viene en notacion ascii
	lb $a2 1($s0)	       #cargamos el segundo byte ascii
	beq $a1 10 regresarloop2	#si a1 es un \n vamos a regresarloop2
	beq $a2 $zero decodificacion	#si a2 es 0 significa que alcanzamos la ultima linea, nos vamnos a decodificar
	subi $t0 $a1 48			#restamos 48 y lo guardamos en t0 para saber si a1 es un numero
	subi $t1 $a2 48			#restamos 48y lo guardamos en t1  para saber si a2 es un numero
	ble $t0 10 caso1 		#caso en el que el primer byte es un numero
	ble $t1 10 caso2 		#caso en el que el primer byte es letra y el segundo numero
	
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
	#marcamos con \n el final del programa
	li $a0 10	#10 es \n
	subi $s1 $s1 3  #s1 era el 4to byte de la primera palabra vacia asi que lo hacemos el 1er byte restando 4
	sw $a0 ($s1)    #ponemos \n en la palabra vacia para delimitar
	la $s0 programa #guardamos la direccion donde comienza el programa
	subi $s0 $s0 4	#restamos 4 para comenzar las iteraciones sumando 4
	
#-----------------------------------------FASE_2-------------------------------------------------------------------------------------
#PLANIFICACION DE REGISTROS FASE 2:
#		0. $t0 : almacena la instruccion en hexa que se va a traducir e imprimir
#		1. $t1 : almacena los 6 primeros bits de la instruccion (codigo de operacion)
#		2. $t2 : almacena el indice del arreglo de tipos de operacion correspondiente a la operacion por la
#			 que se pasea la busqueda en un momento dado (iterador de operation_type)
#		3. $t3 : almacena el codigo de operacion correspondiente a la operacion por la que se pasea la busqueda
#			 en un momento dado, y luego de encontrada la operacion, se usa como temporal para informacion que
#			 se extraiga de la operacion para imprimirla (rd,rs,rt u offset)
#		4. $t4 : almacena el indice del arreglo de codigos de operacion correspondiente a la operacion por la
#			 que se pasea la busqueda en un momento dado (iterador de operation_code)
#		5. $t5 : almacena el indice del arreglo de nombres de operacion correspondiente a la operacion por la
#			 que se pasea la busqueda en un momento dado (iterador de operation_name)
#		7. $t6 : almacena el .asciiz "I"
#		8. $s0 : aqui cargamos la direccion del proximo codigo a decodificar
#		9. $s1 : aqui cargamos al contenido de $s0 para verificar si alcanzamos la ultima linea \n
#		10.$t9: aqui cargamos una copia del codigo de operacion de la operacion que se trata para los casos de offset negativos

loop_impresion:

	#criterio de parada
	addi $s0 $s0 4
	lw $s1,($s0)
	beq $s1,10,fin
	
	# Inicializamos $t2 en 0, iterador de operation_type
	addi $t2,$zero,0
	# Inicializamos $t4 en 0, iterador de operation_code
	addi $t4,$zero,0
	# Inicializamos $t5 en 0, iterador de operation_name
	addi $t5,$zero,0
	# Almacenamos en $t6 el ascii I	
	lb $t6,I
			
	#Extraemos el codigo de operacion
	lw $t0,($s0)			
	andi $t1,$t0,0xfc000000	#apagamos los bits que no corresponde al c.o.
	srl $t1, $t1, 26	#rodamos el c.o. al inicio
	
	while_search:		#iteramos sobre el arreglo de c.o. buscando la instruccion
	beq $t4,56,noEncontrado	#iteramos hasta 56 porque hay 14 c.o.
	lw $t3,operation_code($t4)
	beq $t1,$t3,undecode	#si encontramos el c.o. comenzamos la decodificacion
	addi $t2,$t2,2		#incremetamos las variables de iteracion
	addi $t4,$t4,4
	addi $t5,$t5,5
	j while_search		#debe introducirse una instruccion correcta o sera un loop
				#infinito
	undecode:
	
	#Imprimimos la instruccion leida en hex
	li $v0,34
	lw $a0,($s0)
	syscall
	
	#Imprimimos un espacio en blanco
	li $v0,4
	la $a0,space
	syscall
			
	#Imprimimos el tipo de operacion
	li $v0,4
	la $a0,operation_type($t2)
	syscall

	#Imprimimos un espacio en blanco
	li $v0,4
	la $a0,space
	syscall

	#Imprimimos el nombre de la operacion
	li $v0,4
	la $a0,operation_name($t5)
	syscall

	#Imprimimos un espacio en blanco
	li $v0,4
	la $a0,space
	syscall

#Hay operaciones que no siguen el formato R o I exactamente, por lo que son casos especiales
	
	#guardamos el codigo de operacion para luego distinguir si es una operacion aritmetica o logica
	move $t9, $t3 
	
	beq $t3,0,halt_case	#la instruccion es halt
	beq $t3,35,lw_sw_case	#la instruccion es lw o sw
	beq $t3,43,lw_sw_case
	lb $t3,operation_type($t2)#verificamos si la operacion es de tipo I
	beq $t3,$t6,typeI	#si es de tipo I
	j typeR 	# en cualquier otro caso es de tipo R

	halt_case:
	#Imprimimos una nueva linea
	li $v0,4
	la $a0,newline
	syscall
	j loop_impresion #terminamos con la operacion

	noEncontrado:
	#Imprimimos el mensaje de no encontrado
	li $v0,4
	la $a0,MensajeNoEncontrado
	syscall

	#Imprimimos una nueva linea
	li $v0,4
	la $a0,newline
	syscall
	j loop_impresion #terminamos con la operacion
		
	typeR:
	#Imprimimos en formato R
	
	#Extraemos el rd
	lw $t0,($s0)
	andi $t3,$t0,0x0000f800 #apagamos los bits que no corresponde al rd
	srl $t3, $t3, 11	#rodamos el rd al inicio
	#Imprimimos el signo de dolar
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
	lw $t0,($s0)
	andi $t3,$t0,0x03e00000	#apagamos los bits que no corresponde al rs
	srl $t3, $t3, 21	#rodamos el rs al inicio
	#Imprimimos el signo de dolar
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
	lw $t0,($s0)
	andi $t3,$t0,0x001f0000 #apagamos los bits que no corresponde al rt
	srl $t3, $t3, 16	#rodamos el rt al inicio
	#Imprimimos el signo de dolar
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
	j loop_impresion #terminamos con la operacion

	#Imprimimos en formato I
	typeI: 
	
	#Extraemos el rt
	lw $t0,($s0)
	andi $t3,$t0,0x001f0000 #apagamos los bits que no corresponde al rt
	srl $t3, $t3, 16	#rodamos el rt al inicio
	#Imprimimos el signo de dolar
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
	lw $t0,($s0)
	andi $t3,$t0,0x03e00000	#apagamos los bits que no corresponde al rs
	srl $t3, $t3, 21	#rodamos el rs al inicio
	#Imprimimos el signo de dolar
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
	lw $t0,($s0)
	andi $t3,$t0,0x0000ffff #apagamos los bits que no corresponde al offset
	
#correcion: ***si la operacion es aritmetica debemos ver si el offset es negativo en complemento a 2 y hacer la extension de 
#signo correspondiente***
	bne $t9, 5, esbne#es addi? si no vemos si es bne
	b convertirNegativo
	 
	esbne:
	bne $t9, 6, esbeq#es bne? si no vemos si es beq
	b convertirNegativo
	
	esbeq:
	bne $t9, 8, continuarTipoI#si no seguimos
	b convertirNegativo
	
	convertirNegativo:#aqui revisamos si el numero era negativo y si lo es agregamos la extension de signo
	andi $t8, $t3,0x00008000
	bne $t8, 0x00008000,continuarTipoI #si el numero no es negativo seguimos 
	ori $t3, $t3, 0xffff0000 #si es negativo extendemos el signo
	b continuarTipoI
	
	continuarTipoI:
#fincorrecion:
	#Imprimimos el offset	#ya esta al inicio
	li $v0,1
	move $a0,$t3
	syscall	
	
	#Imprimimos una nueva linea
	li $v0,4
	la $a0,newline
	syscall
	j loop_impresion	#terminamos con la operacion
	
	lw_sw_case:
	#Extraemos el rt
	lw $t0,($s0)
	andi $t3,$t0,0x001f0000 #apagamos los bits que no corresponde al rt
	srl $t3, $t3, 16	#rodamos el rt al inicio
	#Imprimimos el signo de dolar
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
	lw $t0,($s0)
	andi $t3,$t0,0x0000ffff #apagamos los bits que no corresponde al offset
	#revisamos si es negativo y si lo es agregamos la extension de signo
	andi $t8, $t3,0x00008000
	bne $t8, 0x00008000,continuarLSw #si el numero no es negativo seguimos 
	ori $t3, $t3, 0xffff0000 #si es negativo extendemos el signo
	
	continuarLSw:
	#Imprimimos el offset	#ya esta al inicio
	li $v0,1
	move $a0,$t3
	syscall

	#Imprimimos un parentesis izquierdo
	li $v0,4
	la $a0,left_parentesis
	syscall
	#Imprimimos el signo de dolar
	li $v0,4
	la $a0,dollar
	syscall
	
	#Extraemos el rs
	lw $t0,($s0)
	andi $t3,$t0,0x03e00000	#apagamos los bits que no corresponde al rs
	srl $t3, $t3, 21	#rodamos el rs al inicio
	#Imprimimos el rs
	li $v0,1
	move $a0,$t3
	syscall

	#Imprimimos un parentesis derecho
	li $v0,4
	la $a0,right_parentesis
	syscall
	
	#Imprimimos una nueva linea
	li $v0,4
	la $a0,newline
	syscall
	j loop_impresion #terminamos con la operacion

fin: 
	li $v0 10
     	syscall
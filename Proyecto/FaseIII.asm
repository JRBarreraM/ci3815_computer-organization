#CI3815-ORGANIZACION DEL COMPUTADOR

#MVML: Maquina Virtual MIPS Ligero

#GRUPO F
#15-10123 Jose Barrera
#15-11550 Jean Paul Yazbek

.data
#DATOS FASE 3:
memoria:.space  2000 #espacio para la memoria
registros:.space 132 #espacio para los 32 registros y para el PC (numero 33)
cuanta_memoria:.asciiz "Cuantas palabras de memoria quieres imprimir?"
regs:.asciiz "----Registros----"
mem:.asciiz "----Memoria----"
espacio:.asciiz " "

#DATOS FASE 2:
.
#Conjunto De Instrucciones
operation_code: .word         8,   12,  13, 35, 43,   5,   6,  32,  40,   24, 27,    4,  34, 0
operation_function: .word _addi,_andi,_ori,_lw,_sw,_bne,_beq,_add,_and,_mult,_or,_sllv,_sub,_halt

newline: .asciiz "\n"
MensajeNoEncontrado: .asciiz "La operacion no fue encontrada en el conjunto de instrucciones de la MVML"

#DATOS FASE 1:
archivo: .space 100 #reservamos 100 suponiendo que cada archivo no tiene mas de 100 caracteres
buffer: .space 900  #reservamos 900 porque cada linea de codigo en ascii necesita 9 bytes incluyendo el \n
.align 2
programa:.space 404 #un programa de 900 bytes en ascii se convertira en uno de 400 en lenguaje ensamblador 
error_lectura: .asciiz "no se pudo abrir el archivo"

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
	
	bge $v0 0 seguir_lectura #si lo que hay en v0 es positivo el archivo abrio apropiadamente
	#si es negativo hubo un error
	li $v0 4		#codigo para imprimir string
	la $a0 error_lectura    #direccion del mensaje ed error
	syscall			#imprimimos el error
	j fin			#salimos...
	
seguir_lectura:			
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

#Calculamos la direccion inicial del PC virtual
la $s3 registros
addi $s3 $s3 128
la $t0 programa
sw $t0 ($s3)

decodificacion:
#-----------------------------------------FASE_3-------------------------------------------------------------------------------------
#PLANIFICACION DE REGISTROS FASE 3:
#		0. $a0 : almacena la instruccion en hexa que se leyo
#		1. $s0 : almacena el indice del arreglo de codigos de operacion correspondiente a la operacion por la
#			 que se pasea la busqueda en un momento dado (iterador de operation_code)
#		2. $s1 : almacena el C.O. de la instruccion en hexa que se leyo
#		3. $s2 : almacena el C.O. para comparar y encontrar la instruccion
#		4. $s3 : direccion del Pc virtual
			
	la $s3 registros
	addi $s3 $s3 128
	lw $a0 ($s3)
	
	# Inicializamos $s0 en 0
	addi $s0,$zero,0

	#Extraemos el codigo de operacion
	jal extract_CO
	addi $s1,$zero,0
	add $s1,$zero,$v1

	# Incrementamos el PC virtual en 4
	la $t0,registros
	lw $s6,128($t0)			#REcordatorio especificar ruta PC virtual
	addi $s6,$s6,4
	sw $s6,128($t0)
	
	while_search:		#iteramos sobre el arreglo de c.o. buscando la instruccion
	beq $s0,56,noEncontrado	#iteramos hasta 56 porque hay 14 c.o.
	lw $s2,operation_code($s0)
	lw $s4,operation_function($s0)
	beq $s1,$s2,undecode	#si encontramos el c.o. comenzamos la decodificacion
	addi $s0,$s0,4		#incremetamos la variable de iteracion
	j while_search

	noEncontrado:
	#Imprimimos el mensaje de no encontrado
	li $v0,4
	la $a0,MensajeNoEncontrado
	syscall

	undecode:
#Hay operaciones que no siguen el formato R o I exactamente, por lo que son casos especiales
	beq $s1,0,halt_case		#la instruccion es halt

	#Extraemos el rs
	jal extract_RS
	mul $s6, $v0, 4
	la $a0, registros($s6)

	addi $s0,$s0,-24		#WTF??
	bgez $s0,typeI			#si es de tipo I

	#Extraemos el rt
	jal extract_RT
	mul $s6, $v0, 4
	la $a1, registros($s6)

	#Extraemos el rd
	jal extract_RD
	mul $s6, $v0, 4	
	la $s6, registros($s6)
	j llamarR
	
	#Formato I
	typeI:
	#Extraemos el offset
	jal extract_Offset
	mul $s6, $v0, 4
	la $a1, registros($s6)
	#Extraemos el rt
	jal extract_RT
	mul $s6, $v0, 4
	la $a2, registros($s6)
	la $s6, registros($s6)
	j llamarI
	
halt_case:
	jal _halt
	
llamarR:
	jalr $s4
	sw $v0,($s6)
	j decodificacion		#Aqui termina la decodificacion
	
llamarI:
	jalr $s4
	beq $s1,43,decodificacion#No tiene Output
	beq $s1,5,decodificacion #No tiene Output
	beq $s1,6,decodificacion #No tiene Output
	sw $v0,($s6)
	j decodificacion	 #Aqui termina la decodificacion

imprimir:
	#Preguntamos cuanta memoria quiere leer el usuario
	li $v0 4
	la $a0 cuanta_memoria
	syscall
	#Pedimos el input entero
	li $v0 5
	syscall
	move $t0 $v0 #guardamos en $t0 el registro para usarlo luego
	
	# IMPRIMIMOS REGISTROS
	
	# imprimimos un mensaje
	li $v0 4
	la $a0 regs
	syscall
	
	#Imprimimos el salto de linea
	li $v0 4
	la $a0 newline
	syscall
	
	addi $s0,$zero,0 #contador iteracion
	addi $t1,$zero,0 #contador para impresion de nro de registro
	
	while_registros:		#iteramos para imprimir los registros
		beq $s0,132,salir_registros	#iteramos hasta 33 porque hay 32 registors mas el PC
		lw $s1,registros($s0)	
		
		#Imprimimos el nro del registro
		li $v0 1 
		move $a0 $t1
		syscall
		
		#Imprimimos un espacio
		li $v0 4
		la $a0 espacio
		syscall
		
		#Imprimimos en hex
		li $v0,34
		move $a0,$s1
		syscall
		
		#Imprimimos el salto de linea
		li $v0 4
		la $a0 newline
		syscall

		addi $s0,$s0,4		#incremetamos la variable de iteracion
		addi $t1,$t1,1
		j while_registros
		
	salir_registros:
	
	#IMPRIMIMOS MEMORIA
	#mensaje
	li $v0 4
	la $a0 mem
	syscall
	
	#Imprimimos el salto de linea
	li $v0 4
	la $a0 newline
	syscall
	
	#recuperamos la cantidad de palabras de memoria a leer
	mul $t0 $t0 4
	addi $s0,$zero,0
	addi $t1,$zero,0 #contador para imprimir el nro de palabra
	
	while_memoria:
		beq $s0,$t0,fin		#iteramos hasta el numero de lineas que indique el usuario
		lw $s1,memoria($s0)
		
		#Imprimimos el nro de palabra de memoria
		li $v0 1 
		move $a0 $t1
		syscall
		
		#Imprimimos un espacio
		li $v0 4
		la $a0 espacio
		syscall
		
		#Imprimimos en hex
		li $v0,34
		move $a0,$s1
		syscall
		
		#Imprimimos el salto de linea
		li $v0 4
		la $a0 newline
		syscall

		addi $t1,$t1,1
		addi $s0,$s0,4		#incremetamos la variable de iteracion
		j while_memoria

#punto utilizado para culminar el programa
fin: 
	li $v0 10
     	syscall
#----------------------------------------FUNCIONES------------------------------------------------------------------------------------
	#Funciones de extraccion:
	extract_CO:
	andi $v0,$a0,0xfc000000	#apagamos los bits que no corresponde al c.o.
	srl $v0, $v0, 26	#rodamos el c.o. al inicio
	jr $ra

	extract_RT:
	andi $v0,$a0,0x001f0000 #apagamos los bits que no corresponde al rt
	srl $v0, $v0, 16	#rodamos el rt al inicio
	jr $ra	

	extract_RS:
	andi $v0,$a0,0x03e00000	#apagamos los bits que no corresponde al rs
	srl $v0, $v0, 21	#rodamos el rs al inicio
	jr $ra	

	extract_RD:
	andi $v0,$a0,0x0000f800 #apagamos los bits que no corresponde al rd
	srl $v0, $v0, 11	#rodamos el rd al inicio
	jr $ra

	extract_Offset:
	andi $v0,$a0,0x0000ffff #apagamos los bits que no corresponde al offset
	#correcion: ***si la operacion es aritmetica debemos ver si el offset es negativo en complemento a 2 y hacer la extension de 
	#signo correspondiente***	
	#aqui revisamos si el numero era negativo y si lo es agregamos la extension de signo
	jal extract_CO
	beq $s2 12 salir_Offset#si la operacion es ori no vemos si el offset es negativo
	beq $s2 13 salir_Offset#si la operacion es andi no vemos si el offset es negativo
	andi $t0,$v0,0x00008000
	bne $t0,0x00008000,salir_Offset #si el numero no es negativo seguimos 
	ori $v0,$v0,0xffff0000 #si es negativo extendemos el signo
	jr $ra
	salir_Offset:
	jr $ra

#funcion 1: suma el contenido de $a0 y $a1 en $v0
#nombre: add
#tipo: R
#             Argumentos:
#$a0: contenido del registro virtual $rs
#$a1: contenido del registro virtual $rt
#	      Salida:
#$v0: suma de $a0 y $a1
_add:
	add $v0 $a0 $a1
	jr $ra
		
#funcion 2: aplica un & logico al contenido  de $a0 y $a1 en $v0
#nombre: and 
#tipo: R
#             Argumentos:
#$a0: contenido del registro virtual $rs
#$a1: contenido del registro virtual $rt
#	      Salida:
#$v0: & logico de $a0 y $a1
_and: 
	and $v0 $a0 $a1
	jr $ra
	
#funcion 3: aplica multiplicacion al contenido de $a0 y $a1 en $v0
#nombre: mult
#tipo: R
#             Argumentos:
#$a0: contenido del registro virtual $rs
#$a1: contenido del registro virtual $rt
#	      Salida:
#$v0: multiplicacion del contenido de $a0 y $a1
_mult: 
	mul  $v0 $a0 $a1
	jr $ra
	
#funcion 4: aplica un "o" logico al contenido de $a0 y $a1 en $v0
#nombre: or
#tipo: R
#             Argumentos:
#$a0: contenido del registro virtual $rs
#$a1: contenido del registro virtual $rt
#	      Salida:
#$v0: "o" logico de $a0 y $a1
_or: 
	or  $v0 $a0 $a1
	jr $ra
	
#funcion 5: aplica un shif logical left al contenido de $a1 por la cantidad de bits que indique el cotenido de $a0, en $v0
#nombre: sllv
#tipo: R
#             Argumentos:
#$a0: contenido del registro virtual $rs
#$a1: contenido del registro virtual $rt
#	      Salida:
#$v0: shift logico a la izquierda de $a1 segun la cantidad de bits en $a0
_sllv: 
	sllv  $v0 $a1 $a0
	jr $ra
	
#funcion 6: aplica resta al contenido de $a0 y $a1 en $v0
#nombre: sub
#tipo: R
#             Argumentos:
#$a0: contenido del registro virtual $rs
#$a1: contenido del registro virtual $rt
#	      Salida:
#$v0: resta de $a0 y $a1
_sub: 
	sub  $v0 $a0 $a1
	jr $ra
	
#funcion 7: detiene el programa
#nombre: halt
#tipo: R
#             Argumentos:

#	      Salida:

_halt: 
	j imprimir
	jr $ra
	
#funcion 8: aplica suma al contenido de $a0 y $a1
#nombre: addi
#tipo: I
#             Argumentos:
#$a0: contenido del registro virtual $rs
#$a1: contenido del offset
#	      Salida:
#$v0: suma  de $a0 y $a1
_addi: 
	add  $v0 $a0 $a1
	jr $ra
	
#funcion 9: aplica & logico al contenido de $a0 y $a1
#nombre: andi
#tipo: I
#             Argumentos:
#$a0: contenido del registro virtual $rs
#$a1: contenido del offset
#	      Salida:
#$v0: & logico de $a0 y $a1
_andi: 
	and  $v0 $a0 $a1
	jr $ra
	
	
#funcion 10: aplica "o" logico al contenido de $a0 y $a1
#nombre: ori
#tipo: I
#             Argumentos:
#$a0: contenido del registro virtual $rs
#$a1: contenido del offset
#	      Salida:
#$v0: "o" logico de $a0 y $a1
_ori: 
	or  $v0 $a0 $a1
	jr $ra
	
#funcion 11: busca el contenido en la memoria virtual a insertar en $rt
#nombre: lw
#tipo: I
#             Argumentos:
#$a0: contenido del registro virtual $rs
#$a1: contenido del offset
#	      Salida:
#$v0: valor a insertar en $rt
_lw: 
	#calculamos la direccion apropiada
	add $t0 $a0 $a1	
	la $t1 memoria
	add $t0 $t0 $t1
	#cargamos su contenido en v0
	lw $v0 ($t0)
	jr $ra
	
#funcion 12: inserta en la memoria virtual el contenido adecuado
#nombre: sw
#tipo: I
#             Argumentos:
#$a0: contenido del registro virtual $rs
#$a1: contenido del offset
#$a2: contenido del registro virtual $rt
#	      Salida:
_sw: 
	#calculamos la direccion adecuada 
	add $t0 $a0 $a1
	la $t1 memoria
	add $t0 $t0 $t1
	#depositamos el contenido en dicha direccion
	sw $a2 ($t0)
	jr $ra
	
#funcion 13: si se cumple la condicion se modifica el PC virtual acordemente
#nombre: bne
#tipo: I
#             Argumentos:
#$a0: contenido del registro virtual $rs
#$a1: contenido del offset (cantidad de palabras que se desea mover el pc)
#$a2: contenido del registro virtual $rt
#	      Salida:

_bne: 
	beq $a0 $a2 bne_exit #si son iguales $rs y $rt no modificamos el pc
		sll $a1 $a1 2 #si no calculamos el desplazamiento
		li $t0 128 #posicion del registro del pc contando desde 0 al 128
		lw $t1 registros($t0) #cargamos el contenido actual del pc
		add $t1 $t1 $a1 #calculamos la nueva direccion para el pc
		sw $t1 registros($t0)#cargamos el nuevo pc
	
	bne_exit:
	jr $ra
	
#funcion 14: si se cumple la condicion se modifica el PC virtual acordemente
#nombre: beq
#tipo: I
#             Argumentos:
#$a0: contenido del registro virtual $rs
#$a1: contenido del offset (cantidad de palabras que se desea mover el pc)
#$a2: contenido del registro virtual $rt
#	      Salida:

_beq: 
	bne $a0 $a2 beq_exit #si son iguales $rs y $rt no modificamos el pc
		sll $a1 $a1 2 #si no calculamos el desplazamiento
		li $t0 128 #posicion del registro del pc contando desde 0 al 128
		lw $t1 registros($t0) #cargamos el contenido actual del pc
		add $t1 $t1 $a1 #calculamos la nueva direccion para el pc
		sw $t1 registros($t0)#cargamos el nuevo pc
	
	beq_exit:
	jr $ra

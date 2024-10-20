# Javier Ramos - Alejandro Minambres
.data
DireccionNumero: .space 1000

.text
	#  Recibimos la entrada
	la $a0, DireccionNumero
	addi $a1, $zero, 1000
	li $v0, 8
	syscall

	jal atoi
	
	# Imprimir el resultado
	add $a0, $zero, $v0
	li $v0, 1	
	syscall

	# Imprimir el bit estado
	add $a0, $zero, $v1
	li $v0, 1	
	syscall

	li $v0, 10
	syscall


# Funcion para convertir una cadena de caracteres en un entero de 32 bits
# Entradas:  $a0 - Direccion de la cadena
#		       $v0 - Entero resultante
#			$v1 - Salida de errores
atoi: 				addi $t1, $zero, 1					# Para convertir a negativo
					addi $t2, $zero, 10				# Constante 10 en $t2

bucleespacio:		lb $t0, 0($a0)					# Se saltan los espacios
					addi $a0, $a0, 1
					beq $t0, 32, bucleespacio
					beq $t0, 43, positivo
					bne $t0, 45, sinsigno
					addi $t1, $zero, -1				# Es negativo

positivo:			lb $t0, 0($a0)					# Si tiene un "+" o "-" se salta
					addi $a0, $a0, 1

sinsigno:			blt $t0, 48, caracterincorrecto
					bgt $t0, 57, caracterincorrecto		
					
					add $v0, $zero, $zero				# Es correcto			
					add $v1, $zero, $zero	

bucleconv:			addi $t0, $t0, -48					# Se convierte a numero

					addu $v0, $v0, $t0	
					blt $v0, $zero, comprobar
					
					lb $t0, 0($a0)					
					addi $a0, $a0, 1
					blt $t0, 48, acabar
					bgt $t0, 57, acabar
					
					mul $v0, $v0, $t2				# Tiene un digito más
					mfhi $t3
					bne $t3, $zero, overflow
					blt $v0, $zero, comprobar

					j bucleconv 
					
comprobar:			bne $v0, -2147483648, overflow
					bne $t1, -1, overflow
					lb $t0, 0($a0)
					blt $t0, 48, salir
					bgt $t0, 57, salir				
				
overflow:			addi $v1, $zero, 2
					j salir										

caracterincorrecto:		addi $v1, $zero, 1	
			
acabar:				mul $v0, $v0, $t1

salir	:				jr $ra

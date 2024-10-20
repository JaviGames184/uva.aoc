# Javier Ramos - Alejandro Minambres
.data
NumeroFuerarango: .asciiz "-2147483648"
.text

# Funcion para calcular el logaritmo de un numero dado
# Entradas: $a0 - Direccion de la cadena de entrada
#		    $a1 - Direccion de la cadena de salida
#		    $v0 - Comprobacion de errores
logaritmos:	addi $sp, $sp, -16				# Se guarda las variables y la direccion de retorno
			sw $ra, 12($sp)
			sw $s0, 8($sp)
			sw $s1, 4($sp)
			sw $s2, 0($sp)
			
			
			add $s0,$a0,$zero
			add $s1,$a1,$zero
			jal atoi	
			
			bne $v1, $zero, algunerror
			add $s2,$v0,$zero

			add $a0, $s2,$zero
			jal log2
			bne $v1, $zero, nologaritmo
			
			add $a0, $v0, $zero
			add $a1, $s1, $zero
			jal itoa						# Se convierte a número

			addi $t2, $zero, 32
			sb $t2, 0($a1)					# Se cambia el \0 por un espacio para juntar las cadenas

			addi $s1,$a1,1

			add $a0,$s2,$zero
			jal log10	
			bne $v1, $zero, nologaritmo
			
			add $a0, $v0, $zero
			add $a1, $s1, $zero
			jal itoa						# Se convierte a número
			add $v0, $zero, $zero
			j salir
			
nologaritmo:	addi $v1, $v1, 2				# No existe el logaritmo			
algunerror:	add $v0, $v1, $zero			# Se guarda el error producido en $v0

salir:		lw $s2, 0($sp)			# Se recupera las variables
			lw $s1, 4($sp)	
			lw $s0, 8($sp)	

			lw $ra, 12($sp)				# Se recupera la dirección de retorno
			addi $sp, $sp, 16
			jr $ra


# Funcion para convertir una cadena de caracteres en un entero de 32 bits
# Entradas:  $a0 - Direccion de la cadena
#		     $v0 - Entero resultante
#		     $v1 - Salida de errores
atoi: 				addi $t1, $zero, 1					# Para convertir a negativo
					addi $t2, $zero, 10				# Constante 10 en $t2

atbucleespacio:		lb $t0, 0($a0)					# Se saltan los espacios
					addi $a0, $a0, 1
					beq $t0, 32, atbucleespacio
					beq $t0, 43, atpositivo
					bne $t0, 45, atsinsigno
					addi $t1, $zero, -1				# Es negativo

atpositivo:			lb $t0, 0($a0)					# Si tiene un "+" o "-" se salta
					addi $a0, $a0, 1

atsinsigno:			blt $t0, 48, atcaracterincorrecto
					bgt $t0, 57, atcaracterincorrecto		
					
					add $v0, $zero, $zero				# Es correcto			
					add $v1, $zero, $zero	

atbucleconv:			addi $t0, $t0, -48					# Se convierte a numero

					addu $v0, $v0, $t0	
					blt $v0, $zero, atcomprobar
					
					lb $t0, 0($a0)					
					addi $a0, $a0, 1
					blt $t0, 48, atacabar
					bgt $t0, 57, atacabar
					
					mul $v0, $v0, $t2				# Tiene un digito más
					mfhi $t3
					bne $t3, $zero, atoverflow
					blt $v0, $zero, atcomprobar

					j atbucleconv 
					
atcomprobar:			bne $v0, -2147483648, atoverflow
					bne $t1, -1, atoverflow
					lb $t0, 0($a0)
					blt $t0, 48, atsalir
					bgt $t0, 57, atsalir				
				
atoverflow:			addi $v1, $zero, 2
					j atsalir										

atcaracterincorrecto:	addi $v1, $zero, 1	
			
atacabar:				mul $v0, $v0, $t1

atsalir	:			jr $ra


# Funcion para convertir un numero en complemento a dos a una cadena ASCII en decimal
# Entradas: $a0 - Numero a convertir
#		    $a1: - Direccion donde guardar la cadena resultante
itoa:			bge $a0, $zero, itEsPositivo
			
			bne $a0, -2147483648, itEnRango	# Se comprueba si se sale de rango
			la $t1, NumeroFuerarango	
itRango:		lb $t3, 0($t1)
			sb $t3, 0($a1)
			beq $t3, $zero, itSalir
			addi $t1, $t1, 1
			addi $a1, $a1, 1
			j itRango

itEnRango:	nor $a0, $zero, $a0					 # Es negativo --> Se convierte a positivo y se guarda "-"
			addi $a0, $a0, 1
			addi $t2, $zero, 45					
			sb $t2, 0($a1)
			addi $a1, $a1, 1

itEsPositivo:	add $t1, $a1, $zero	
			addi $t3, $zero, 10					#Dato para la division entre 10		
itBucleDig:	div $a0, $t3
			mfhi $t2
			mflo $a0
			addi $t2, $t2, 48
			sb $t2, 0($t1)
			beq $a0, $zero, itInvertir
			addi $t1, $t1, 1	
			j itBucleDig		
			
itInvertir:	sb $zero, 1($t1)						# Se guarda el terminador de cadena
			addi $t5, $t1, 1						# Se guarda la posicion del final de la cadena
itBucle:		lb $t2, 0($t1)	
			lb $t3, 0($a1)
			sb $t2, 0($a1)
			sb $t3 0($t1)
			addi $a1, $a1, 1
			addi $t1, $t1, -1
			slt $t4, $t1, $a1
			beq $t4, 0, itBucle

			add $a1, $t5, $zero
itSalir:		jr $ra

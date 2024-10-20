# Javier Ramos - Alejandro Minambres
.data
NumeroFuerarango: .asciiz "-2147483648"
.text
# Funcion para convertir un numero en complemento a dos a una cadena ASCII en decimal
# Entradas: $a0 - Numero a convertir
#		      $a1: - Direccion donde guardar la cadena resultante
itoa:		bge $a0, $zero, EsPositivo
			
			bne $a0, -2147483648, EnRango	# Se comprueba si se sale de rango
			la $t1, NumeroFuerarango	
Rango:		lb $t3, 0($t1)
			sb $t3, 0($a1)
			beq $t3, $zero, Salir
			addi $t1, $t1, 1
			addi $a1, $a1, 1
			j Rango

EnRango:	nor $a0, $zero, $a0					 # Es negativo --> Se convierte a positivo y se guarda "-"
			addi $a0, $a0, 1
			addi $t2, $zero, 45					
			sb $t2, 0($a1)
			addi $a1, $a1, 1

EsPositivo:	add $t1, $a1, $zero	
			addi $t3, $zero, 10					#Dato para la division entre 10		
BucleDig:	div $a0, $t3
			mfhi $t2
			mflo $a0
			addi $t2, $t2, 48
			sb $t2, 0($t1)
			beq $a0, $zero, Invertir
			addi $t1, $t1, 1	
			j BucleDig		
			
Invertir:		sb $zero, 1($t1)						# Se guarda el terminador de cadena
Bucle:		lb $t2, 0($t1)	
			lb $t3, 0($a1)
			sb $t2, 0($a1)
			sb $t3 0($t1)
			addi $a1, $a1, 1
			addi $t1, $t1, -1
			slt $t4, $t1, $a1
			beq $t4, 0, Bucle
Salir:		jr $ra

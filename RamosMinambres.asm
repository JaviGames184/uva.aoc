# Javier Ramos - Alejandro Minambres
.data 
Indet: .asciiz "INDETERMINADO"
Incom: .asciiz "INCOMPATIBLE"

.align 2
Ecuacion1:  .space 20
.align 2
Ecuacion2: .space 20
.align 2
Solucion: .space 32

.text
#------------------------------------------------------------String2Ecuacion------------------------------------------------------------#

# Función que recibe una cadena de caracteres y produce como resultado un objeto del tipo Ecuacion
# Parámetros:
#			$a0 --> Cadena de entrada
#			$a1 --> Ecuacion de salida
# Salida:
#			$v0 --> Error:
#					1 --> Sintaxis Incorrecta
#					2 --> Overflow en termino coeficiente
#					3 --> Overflow al reducir terminos o coeficientes
#					4 --> Numero de incognitas incorrectas
String2Ecuacion:						addi $sp, $sp, -36					# Se guardan todos los registros que se utilizan
									sw $ra, 32($sp)
									sw $s0, 28($sp)				
									sw $s1, 24($sp)				
									sw $s2, 20($sp)				
									sw $s3, 16($sp)				
									sw $s4, 12($sp)				
									sw $s5, 8($sp)
									sw $s6, 4($sp)	
									sw $s7, 0($sp)				
									

									add $s0, $a0, $zero				# $s0 --> Cadena de entrada
									add $s1, $a1, $zero				# $s1 --> Cadena de salida
									addi $s2, $zero, 1					# $s2 --> Bandera que indica el lado de la ecuacion
									add $s3, $zero, $zero				# $s3 --> Incognita 1
									add $s4, $zero, $zero				# $s4 --> Valor Incognita 1
									add $s5, $zero, $zero				# $s5 --> Incognita 2
									add $s6, $zero, $zero				# $s6 --> Valor Incognita 2
									add $s7, $zero, $zero				# $s7 --> Termino independiente
	
S2EBucleInicial:						lb $t0, 0($s0)						# Se saltan los espacios
									addi $t1, $zero, 32
									addi $t2, $zero, 61									
									addi $s0, $s0, 1
									beq $t0, $t1, S2EBucleInicial
									beq $t0, $t2, S2ESitaxis
									beq $t0, $zero, S2ESitaxis	
									j S2ESeguirBucle								

S2EBucle:							lb $t0, 0($s0)						# Se saltan los espacios
									addi $t1, $zero, 32
									addi $t2, $zero, 61
									addi $t3, $zero, 43
									addi $t4, $zero, 45
									addi $s0, $s0, 1
									beq $t0, $t1, S2EBucle
									beq $t0, $t2, S2Eigual
									beq $t0, $zero, S2Eacabar			# Tiene un 0 --> Acaba correctamente
									beq $t0, $t3, S2ESeguirBucle		# Tiene +
									bne $t0, $t4, S2ESitaxis			# Tiene -
S2ESeguirBucle:						addi $s0, $s0, -1
									add $a1, $zero, $s2
									add $a0, $s0, $zero				# Cadena de entrada
									jal atoi
									add $s0, $a0, $zero
									bne $v1, $zero, S2EAtoiError		# Se ha producido algun error
									bne $a2, $zero, S2ETindep			# Se tiene el termino independiente									

									# Incognita 1
									beq $s3, $a1, S2EIncognita1		# La incognita ya está
									bne $s3, $zero, S2ENoIncognita1	

									add $s3, $a1, $zero				# Es la primera pasada

S2EIncognita1:						slt $t0, $s4, $zero									
									addu $s4, $s4, $v0
									slt $t1, $v0, $zero
									slt $t2, $s4, $zero

									bne $t0, $t1, S2EBucle				# Sumando signos opuestos no se desborda
									bne $t0, $t2, S2EOverflowSuma
									j S2EBucle

									# Incognita 2
S2ENoIncognita1:						beq $s5, $a1, S2EIncognita2		# La incognita ya está
									bne $s5, $zero, S2ENumincognitas	

									add $s5, $a1, $zero				# Es la primera pasada

S2EIncognita2:						slt $t0, $s6, $zero									
									addu $s6, $s6, $v0
									slt $t1, $v0, $zero
									slt $t2, $s6, $zero

									bne $t0, $t1, S2EBucle				# Sumando signos opuestos no se desborda
									bne $t0, $t2, S2EOverflowSuma
									j S2EBucle

									# Termino Independiente
S2ETindep:							slt $t0, $s7, $zero									
									addu $s7, $s7, $v0
									slt $t1, $v0, $zero
									slt $t2, $s7, $zero

									bne $t0, $t1, S2EBucle				# Sumando signos opuestos no se desborda
									bne $t0, $t2, S2EOverflowSuma
									j S2EBucle									

									
S2Eigual:							addi $s2, $zero, -1				# Cambiar de signo
									j S2EBucleInicial

S2EOverflowSuma:					addi $v0, $zero, 3
									j S2Esalir

S2EAtoiError:						add $v0, $v1, $zero
									j S2Esalir		

S2ESitaxis:							addi $v0, $zero, 1
									j S2Esalir	

S2ENumincognitas:					addi $v0, $zero, 4 
									j S2Esalir											
									
S2Eacabar:							beq $s2, 1, S2ESitaxis
									beq $s3, $zero, S2ENumincognitas
S2Eseguir:							add $v0, $zero, $zero				# No se ha producido ningun error
									mul $s7, $s7, $s2
									sw $s4, 0($s1)					# Valor Incognita 1
									sw $s6, 4($s1)					# Valor Incognita 2
									sw $s3, 12($s1)					# Incognita 1
									sw $s5, 16($s1)					# Incognita 2
									sw $s7, 8($s1)					# Termino Independiente
											
S2Esalir:								lw $s7, 0($sp)	
									lw $s6, 4($sp)
									lw $s5, 8($sp)				
									lw $s4, 12($sp)				
									lw $s3, 16($sp)				
									lw $s2, 20($sp)								
									lw $s1, 24($sp)				
									lw $s0, 28($sp)				
									lw $ra, 32($sp)
									addi $sp, $sp, 36					# Se guarda las variables y la direccion de retorno
									jr $ra

# Funcion para convertir una cadena de caracteres en un entero de 32 bits
# Entradas:  	$a0 - Direccion de la cadena
#			$a1 - Cambiar signo
#					+1 --> No cambiar
#					-1 --> Cambiar
#
#Salidas:		$a0 - Direccion de finalizacion
#			$a1 - Letra
#			$a2 - Coeficiente o termino independiente
#					0 --> Coeficiente
#					1 --> Termino Independiente
#		       $v0 - Entero resultante
#			$v1 - Salida de errores
#					0 --> Correcto
#					1 --> Caracter Incorrecto
#					2 --> Overflow
atoi: 				add $t1, $zero, $a1						# Para convertir a negativo
					addi $t2, $zero, 10						# Constante 10 en $t2
					addi $t4, $zero, -1
					add $a2, $zero, $zero	
					addi $t5, $zero, 48
					addi	$t6, $zero, 58
					
					lb $t0, 0($a0)	
					addi $t7, $zero, 43
					addi $t8, $zero, 45					
					addi $a0, $a0, 1
					beq $t0, $t7, atoipositivo
					bne $t0, $t8, atoisinsigno
					mul $t1, $t1, $t4							# Es negativo

atoipositivo:			lb $t0, 0($a0)								# Si tiene un "+" o "-" se salta
					addi $a0, $a0, 1

atoisinsigno:			addi $v0, $zero, 1
					slt $t7, $t0, $t5
					slt $t8, $t0, $t6
					bne $t7, $zero,  atoiletra
					beq $t8, $zero, atoiletra	
					
					add $v0, $zero, $zero						# Es correcto			
					add $v1, $zero, $zero	

atoibucleconv:		sub $t0, $t0, $t5							# Se convierte a numero

					addu $v0, $v0, $t0	
					blt $v0, $zero, atoicomprobar
					
					lb $t0, 0($a0)					
					addi $a0, $a0, 1
					slt $t7, $t0, $t5
					slt $t8, $t0, $t6
					bne $t7, $zero,  atoiletra
					beq $t8, $zero, atoiletra	
					
					mul $v0, $v0, $t2							# Tiene un digito más
					mfhi $t3
					bne $t3, $zero, atoioverflow
					blt $v0, $zero, atoicomprobar

					j atoibucleconv 
					
atoicomprobar:		lui $t7, 32768
					addi $t8, $zero, -1
					bne $v0, $t7, atoioverflow
					bne $t1, $t8, atoioverflow
					lb $t0, 0($a0)
					addi $a0, $a0, 1
					slt $t7, $t0, $t5
					slt $t8, $t0, $t6
					bne $t7, $zero,  atoiletra
					beq $t8, $zero, atoiletra				
				
atoioverflow:			addi $v1, $zero, 2
					j atoisalir										

atoiletra:				slti $t7, $t0, 65							# Se comprueba que es una letra
					slti $t8, $t0, 91
					bne $t7, $zero, atoiseguro
					bne $t8, $zero, atoiletracorrecta
					slti $t7, $t0, 97
					slti $t8, $t0, 123
					bne $t7, $zero, atoicaracterincorrecto
					bne $t8, $zero, atoiletracorrecta					

atoicaracterincorrecto:	addi $v1, $zero, 1	
					j atoisalir

atoiseguro: 			beq $t0, $zero, atoicontinuar				# Termina la cadena
					addi $t7, $zero, 43
					addi $t8, $zero, 45
					beq $t0, $t7, atoicontinuar					# Tiene un +
					beq $t0, $t8, atoicontinuar					# Tiene un -
					addi $t7, $zero, 61
					addi $t8, $zero, 32
					beq $t0, $t7, atoicontinuar					# Tiene un igual
					bne $t0, $t8, atoicaracterincorrecto
atoicontinuar:			addi $a2, $zero, 1
					addi $a0, $a0, -1							# Se tiene que volver a utilizar este caracter

atoiletracorrecta:		add $a1, $t0, $zero						# Se guarda la letra					
			
atoiacabar:			mul $v0, $v0, $t1

atoisalir	:			jr $ra
#--------------------------------------------------------------------------------------------------------------------------------------------#

#------------------------------------------------------------Solucion2String------------------------------------------------------------#

# Función que recibe un objeto tipo Solucion y genera una cadena de caracteres con la información del objeto.
# Parámetros:
#			$a0 --> Cadena de entrada
#			$a1 --> Cadena de salida
#			No devuelve error
Solucion2String: 		addi $sp, $sp, -12							# Se guarda las variables y la direccion de retorno
					sw $ra, 8($sp)
					sw $s0, 4($sp)							#s0--> cadena entrada	
					sw $s1, 0($sp)							#s1--> cadena salida
		
					lw $t0, 0($a0)							# Tipo de solucion
					addi $t9, $zero, 1							#Bandera	
					addi $t4, $zero,  2
					beq $t0, $zero, S2SCompatible					
					la $t1, Indet
					la $t2, Incom
					beq $t0, $t4, S2SIncompatible

S2SIndeterminado: 	lb $t0, 0($t1)
				 	addi $t1, $t1, 1
				 	sb $t0, 0($a1)
					addi $a1, $a1, 1
					bne $t0, $zero, S2SIndeterminado
					j S2SSalir_2
					
S2SIncompatible:		lb $t0, 0($t2)					
				 	addi $t2, $t2, 1
				 	sb $t0, 0($a1)
					addi $a1, $a1, 1
					bne $t0, $zero, S2SIncompatible
					j S2SSalir_2
		
S2SCompatible:		add $s0, $a0, $zero
					add $s1, $a1, $zero
					
					lw $t3, 28($s0)							# Incongnita 1

S2SSegInc:			addi $t4, $zero, 61
					lw $a0, 4($s0)							# Entero
					sb $t3, 0($s1)								#Guarda la letra
					sb $t4, 1($s1)								#Guarda el igual
					
					addi $s1, $s1, 2
					add $a1, $s1 , $zero
					jal itoa

					add $s1, $v0, $zero

					lw $t2, 12($s0)							# Decimal
					lw $t1, 8($s0)							# Desplazamiento
					
					addi $t4, $zero, 46
					beq $t2, $zero, S2SSeguir
					
					sb $t4, 0($s1)								# Guarda el punto
					addi $s1, $s1, 1
					
					add $t1, $s1, $t1
					addi $t4, $zero, 48						# Se guarda el 0

S2SCeros:			beq $t1, $s1, S2SDecimal
					sb $t4, 0($s1)
					addi $s1, $s1, 1
					j S2SCeros
					

S2SDecimal:			add $a0, $zero, $t2
					add $a1, $s1 , $zero	
					jal itoa
					add $s1, $v0, $zero
					
S2SSeguir:			beq $t9, $zero , S2SSalir		
					
					addi $t4, $zero, 32						# Se guarda el espacio
					addi $t9, $t9, -1							# Bandera				
					sb $t4, 0($s1)
	
					addi $s0, $s0, 12
					addi $s1, $s1, 1
					
					lb $t3 20($s0)							# Incognita 2
					j S2SSegInc
					 		
S2SSalir:			sb $zero, 0($s1)

S2SSalir_2:			lw $s1, 0($sp)				
					lw $s0, 4($sp)				
					lw $ra, 8($sp)
					addi $sp, $sp, 12							# Se guarda las variables y la direccion de retorno
					jr $ra



# Funcion para convertir un numero en complemento a dos a una cadena ASCII en decimal
# Entradas: 	$a0 - Numero a convertir
#			$a1: - Direccion donde guardar la cadena resultante
#			$v0 - Devuelve la posicion final
itoa:				bge $a0, $zero, itoaEsPositivo
			
				bne $a0, -2147483648, itoaEnRango		# Se comprueba si es -0

				addi $t2, $zero, 45					# Se guarda el -	
				addi $t3, $zero, 48							
				sb $t2, 0($a1)
				sb $t3, 1($a1)
				addi $v0, $a1, 2
				j itoaSalir

itoaEnRango:		nor $a0, $zero, $a0					 # Es negativo --> Se convierte a positivo y se guarda "-"
				addi $t2, $zero, 45
				addi $a0, $a0, 1								
				sb $t2, 0($a1)
				addi $a1, $a1, 1

itoaEsPositivo:	addi $t3, $zero, 10					#Dato para la division entre 10
				add $t1, $a1, $zero		
itoaBucleDig:		div $a0, $t3
				mfhi $t2
				mflo $a0
				addi $t2, $t2, 48
				sb $t2, 0($t1)
				beq $a0, $zero, itoaInvertir
				addi $t1, $t1, 1	
				j itoaBucleDig		

itoaInvertir: 		addi $v0, $t1, 1						# Se guarda el final de la cadena (+1)
itoaBucle:		lb $t2, 0($t1)	
				lb $t3, 0($a1)
				sb $t2, 0($a1)
				sb $t3 0($t1)
				addi $a1, $a1, 1
				addi $t1, $t1, -1
				slt $t4, $t1, $a1
				beq $t4, $zero, itoaBucle

itoaSalir:			jr $ra


#-------------------------------------------------------------------------------------------------------------------------------------------#



#------------------------------------------------------------ResuelveSistema-----------------------------------------------------------#
#Función que recibe dos cadenas de caracteres y produce como resultado una cadena de caracteres que contiene la solución del sistema
# Parámetros:
#			$a0 --> Ecuacion 1
#			$a1 --> Ecuacion 2
#			$a2 --> Cadena de salida
# Salida:
#			$v0 --> Error
#				1 --> Sintaxis Incorrecta
#				2 --> Overflow en termino coeficiente
#				3 --> Overflow al reducir terminos o coeficientes
#				4 --> Numero de incognitas incorrectas
#				5 --> Sistema de ecuaciones no valido
ResuelveSistema:	addi $sp, $sp, -16					# Se guarda las variables y la direccion de retorno
				sw $ra, 12($sp)
				sw $s0, 8($sp)				
				sw $s1, 4($sp)
				sw $s2, 0($sp)	

				add $s1, $a1, $zero				# $s1 --> Ecuacion 2
				add $s2, $a2, $zero				# $s2 --> Cadena Salida
				
				la $a1, Ecuacion1
				jal String2Ecuacion				# Se transforma la primera ecuacion
				bne $v0, $zero, RSSalir
				
				add $a0, $s1, $zero
				la $a1, Ecuacion2
				jal String2Ecuacion				# Se transforma la segunda ecuacion
				bne $v0, $zero, RSSalir
				
				la $a0, Ecuacion1
				la $a1, Ecuacion2

				lw $t0, 12($a0)					# $t0 --> Ecuacion 1 - Incognita 1
				lw $t2, 12($a1)					# $t2 --> Ecuacion 2 - Incognita 1
				lw $t1, 16($a0)					# $t1 --> Ecuacion 1 - Incognita 2				
				lw $t3, 16($a1)					# $t3 --> Ecuacion 2 - Incognita 2

				bne $t0, $t2, RSComprobar	
				bne $t1, $t3, RSErrorIncog
				j RSSolucion

RSComprobar:	bne $t0, $t3, RSErrorIncog
				beq $t1, $t2, RSCambiarOrden
RSErrorIncog:	addi $v0, $zero, 5
				j RSSalir


RSCambiarOrden:	lw $t4, 0($a1)					# $t4 --> Ecuacion 2 - Valor Incognita 1
				lw $t5, 4($a1)					# $t5 --> Ecuacion 2 - Valor Incognita 2
				
				sw $t3, 12($a1)					# Se cambia el orden de la segunda ecuacion
				sw $t2, 16($a1)
				sw $t4, 4($a1)
				sw $t5, 0($a1)
				

RSSolucion:		la $a2, Solucion
				jal Cramer						# Se obtiene la solucion
				
				la $a0, Solucion
				add $a1, $s2, $zero
				jal Solucion2String				# Se transforma la solucion a string
				add $v0, $zero, $zero				
						
RSSalir:			lw $s2, 0($sp)
				lw $s1, 4($sp)				
				lw $s0, 8($sp)				
				lw $ra, 12($sp)
				addi $sp, $sp, 16					# Se guarda las variables y la direccion de retorno
				jr $ra


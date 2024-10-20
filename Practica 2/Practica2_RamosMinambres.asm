# Javier Ramos - Alejandro Minambres

.data
C0: .float 0.0
C2: .float 2.0

.text
# Funcion para implementar el metodo de bisecciones sucesivas
# Entradas: $f12 - Comienzo del intervalo
#		    $f13: - Final del intervalo
#		    $f14 - Tolerancia del error en la solución
# Salida: $v0 - Devuelve 0 si se devuelve la solución correcta
#			- Devuelve 1 los extremos son del mismo signo
#		$f0 - Valor de x tal que f ( x ) = 0
Bisec: 		la $t0, C0					# Se guardan las constantes que se van a utilizar
			la $t1, C2
			lwc1 $f20, 0($t0)
			lwc1 $f21, 0($t1)
			addi $v0, $zero, 1

			addi $sp, $sp, -4				# Se guarda la dirección de retorno
			sw $ra, 0($sp)

			mov.s $f16, $f12			# Se calcula el valor de f ( Inicio ) y se guarda en $f1
			jal Funcion
			c.eq.s 4 $f0, $f20			# Se comprueba si el extremo inicial es 0
			bc1t 4, AcabarBI
			mov.s $f1, $f0

			mov.s $f16, $f13			# Se calcula el valor de f ( Final ) y se guarda en $f2
			jal Funcion
			c.eq.s 4 $f0, $f20			# Se comprueba si el extremo final es 0
			bc1t 4, AcabarBF
			mov.s $f2, $f0

			mov.s $f4, $f1
			mov.s $f5, $f2			
			jal Comparador
			beq $v0, 1, Salir

			jal Recur
			j Solucion

AcabarBI:   mov.s $f0, $f12
			j Acabar
AcabarBF: 	mov.s $f0, $f13	
			j Acabar	
Solucion:	mov.s $f0,  $f15	
Acabar:	       add $v0, $zero, $zero		# Se puede asegurar una solucion	
Salir:		lw $ra, 0($sp)				# Se recupera la dirección de retorno
			addi $sp, $sp, 4				
			jr $ra


Recur:		addi $sp, $sp, -4				# Se guarda la dirección de retorno
			sw $ra, 0($sp)

			add.s $f15, $f12, $f13		# Se calcula el punto medio ( c ) - $f15
			div.s $f15, $f15, $f21
			
			sub.s $f6, $f13, $f12		# Tamano del intervalo < Tolerancia --> Devuelve c
			abs.s $f6, $f6
			c.lt.s 3 $f6, $f14
			bc1t 3, Terminar			
			
			mov.s $f16, $f15			# Se calcula el valor de f ( c ) y se guarda en $f5
			jal Funcion
			mov.s $f5, $f0

			c.eq.s 4 $f5, $f20
			bc1t 4, Terminar
			
			jal Comparador
			beq $v0, 0, IntAC			
			mov.s $f12, $f15			# El próximo intervalo es C - B
			mov.s $f4, $f5
			mov.s $f5, $f2	
			jal Recur
			j Terminar
IntAC:		mov.s $f13, $f15			# El próximo intervalo es A - C	(Que acabamos de comparar)		
			jal Recur
Terminar:	lw $ra, 0($sp)				# Se recupera la dirección de retorno
			addi $sp, $sp, 4	
			jr $ra



# Funcion que compara signos de dos numeros
# Entradas:$f4 - Primer Valor
#		     $f5: - Segundo Valor
# Salida:    $v0 - Devuelve 0 si son de signos opuestos
#			     - Devuelve 1 si son del mismo signo
Comparador:	add $v0, $zero, $zero
				c.lt.s 1 $f4, $f20				# f ( inicio ) < 0 --> Bandera 1
				c.lt.s 2 $f5, $f20				# f ( final ) < 0 --> Bandera 2
			
				bc1t 1, PriNegativo
				bc1t 2, Bien
SegNegativo:	addi $v0, $zero, 1			# Los dos son del mismo signo
Bien:			jr $ra 
PriNegativo:  	bc1t 2, SegNegativo	
				jr $ra						# Tienen signos distintos

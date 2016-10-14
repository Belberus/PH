.text

.global sudoku_candidatos_init_arm, sudoku_candidatos_propagar_arm

sudoku_candidatos_init_arm:
.arm

.equ bitP, 0x8000	// Usada para devolver el bit P
.equ mascaraIni, 0x1FF	// Usada para inicializar los bits candidatos

	MOV r4, #0	// Contador de columnas
	MOV r5, r0	// Direccion actual (inicial)

	MOVNE r7, #0x1000	// Primera parte de la mascara
	MOVNE r8, #0x0FF0	// Segunda parte de la mascara
	ORRNE r6, r7,r8		// Mascara de candidatos incial completa
	MOV r7, #0  		// Contador de filas

// INICIALIZA LISTA DE CANDIDATOS
for1:	
	LDRH r9, [r5]	// Cargamos en r9 el valor de la direccion actual
	AND r9, r9, $bitP	// Obtenemos el bit de P (pista)
	CMP r9, $bitP 	// Comparamos para saber si lo que hay en r5 es una pista

	STRNEH r6, [r5]		// Si no es pista metemos los candidatos iniciales

	CMP r4,#8		// Comprobamos si hemos llegado a la ultima columna del tablero
	ADDEQ r5,r5,#16	// Si hemos completado esa fila saltamos a la siguiente
	ADDEQ r7,r7,#1	// Si hemos completado esa fila sumamos 1 al numero de filas recorridas
	MOVEQ r4,#0		// Si hemos completado esa fila ponemos a 0 el contador de columnas recorridas

	ADDNE r4,r4,#1	// Si hemos completado esa fila incrementamos el numero de columnas recorridas
	ADDNE r5,r5,#2	// Si hemos completado esa fila avanzamos a la siguiente posicion

	CMP r7,#8		// Comprobamos si hemos recorrido todas las filas
	BNE for1		// Si no hemos recorrido todas las filas volvemos al bucle

// RESETEAMOS LOS VALORES
	MOV r4, #0		// Contador de columnas
	MOV r5, r0		// Direccion actual (inicial del tablero)
	MOV r6, #0		// Contador celdas vacias
	MOV r7, #0  	// Contador de filas

// RECORREMOS CELDA, SI ES PISTA PROPAGAMOS
for2:	
	LDRH r8, [r5]	// Cargamos en r8 el valor de la direccion actual
	AND r8, r8, $bitP	// Obtenemos el bit de P (pista)
	CMP r8, $bitP 	// Comparamos para saber si lo que hay en r8 es una pista

	// Invocacion (si es pista)
	MOVEQ r1,r7 	// r1 = filas
	MOVEQ r2,r4		// r2 = columnas
	PUSHEQ {r4-r9}
	BLEQ sudoku_candidatos_propagar_arm	// Saltamos a propagar
	POPEQ {r4-r9}

	ADDNE r6,r6,#1	// Si no es pista hacemos CeldasVacias++

	CMP r4,#8		// Comprobamos si hemos llegado a la ultima columna de la fila actual
	ADDEQ r5,r5,#14	// Si hemos completado esa fila saltamos a la siguiente fila
	ADDEQ r7,r7,#1	// Si hemos completado esa fila sumamos 1 al numero de filas recorridas
	MOVEQ r4,#0		// Si hemos completado esa fila ponemos a 0 el contador de columnas recorridas

	ADDNE r4,r4,#1	// Si no hemos completado esa fila incrementamos en 1 el numero de columnas recorridas
	ADDNE r5,r5,#2	// Si no hemos completado esa fila avanzamos a la siguiente columna
	CMP r7,#9		// Comprobamos si hemos recorrido todas las filas
	BNE for2		// Si no hemos recorrido todas las filas volvemos al bucle

	MOV r0,r6		// Colocamos en r0 el numero de celdas vacias para devolverlo al codigo invocador		

sudoku_candidatos_propagar_arm:
.arm
	PUSH {lr}
	MOV r4,#0				// Contador de posiciones recorridas
	MOV r5, r1, LSL #5
	ADD r6, r5, r2, LSL #1
	ADD r6,r6,r0
	LDRH r6, [r6]			// Cargamos el "valor"
	
	AND r6,r6, #0x000F		// Valor
	MOV r7,#0x0008
	MOV r7,r7, LSL r5		// Mascara del valor
	MVN r7,r7				// Invertimos el valor
	AND r7,r7, 0x00001111	// Valor final de la mascara

	MOV r5,r0				// Asignamos a r5 la primera posicion del tablero (hay que preparar la fila)

// PROPAGAMOS POR LA FILA
forFila:
	LDRH r8,[r5]	// Cargamos el dato a mirar
	AND r8,r8,r7	// Aplicamos la mascara
	STRH r8,[r5]	// Guardamos la mascara actualizada

	ADD r4,r4,#1	// Suamos 1 al contador de filas
	ADD r5,r5,#2	// Avanzamos a la siguiente posicion que mirar
	CMP r4,#8		// Comparamos para saber si hemos llegado al final de la fila
	BNE forFila		// Si todavia no hemos acabado en esa fila volvemos al bucle

// PREPARAMOS LOS VALORES
	MOV r5,#0
	ADD r5,r0,r2	// Nos situamos en la primera posicion de la columna (r0 + columna)
	MOV r4,#0		// Reseamos el contador 

// PROPAGAMOS POR COLUMNA
forColum:
	LDRH r8,[r5]	// Cargamos el dato a mirar
	AND r8,r8,r7	// Aplicamos la mascara
	STRH r8,[r5]	// Guardamos la mascara actualizada

	ADD r4,r4,#1	// Incrementamos el numero de posiciones de la columna recorridas	
	ADD r5,r5,#32	// Saltamos a la siguiente posicion de la columna
	CMP r4,#8		// Comparamos para saber si hemos llegado a la ultima posicion de la columna
	BNE forColum	// Si todavia no hemos acabado en esa columna volvemos al bucle

// PREPARAMOS LOS DATOS
	MOV r10,#0		// Resultado division fila
	MOV r11,#0		// Resultado division columna
	PUSH {r0,r1,r2}	// Guardamos los parametros para no modificarlos
	MOV r4,#0		// Resultado de la division de la fila
	MOV r9,#0		// Resultado de la division de la columna

// Division de las filas
divFila:
	CMP r1,#3		// Comparamos las filas con 3
	SUBGE r1,r1,#3	// Si el numero de filas es mayor o igual que 3, restamos 3
	ADDGE r4,r4,#1 	// Si el numero de filas es mayor o igual que 3, sumamos 1 al contador de division
	BGE divFila		// Si el numero de filas es mayor o igual que 3, volvemos al bucle

// Division de las columnas	
divCol:
	CMP r2,#3		// Comparamos las columnas con 3
	SUBGE r2,r2,#3	// Si el numero de columnas es mayor o igual que 3, restamos 3
	ADDGE r9,r9,#1	// Si el numero de columnas es mayor o igual que 3, sumamos 1 al contador de division
	BGE divCol		// Si el numero de columnas es mayor o igual que 3, volvemos al bucle

// Preparacion de valores

	MOV r1, #3	
	MUL r3,r4, r1	// Asignamos a r3 la posicion incial de la fila (resultado * 3)
	MUL r4,r9, r1	// Asignamos a r4 la posicion inicial de la columna (resultado *3)
	
	// Nos situamos en la posicion inicial del Sector
	MOV r5,#0 
	ADD r5, r0, r3, LSL #5	// Nos situamos en la fila correcta (r0 + (nFilas * 32))
	ADD r5,r5, r5, LSL #1	// Nos situamos en la columna correcta (r5 + (nColumas * 2))

	POP {r0,r1,r2}			// Recuperamos el valor de los parametrosç

	MOV r4, #0	// Contador filas
	MOV r6, #0	// Contador columnas

// PROPAGAMOS POR LA REGION
forRegion:
	LDRH r8,[r5]		// Cargamos el dato a mirar
	AND r8,r8,r7		// Aplicamos la mascara
	STRH r8,[r3]		// Guardamos la mascara actualizada

	ADD r6,r6,#1		// Incrementamos en 1 el contador de columnas	
	CMP r6,#3			// Comparamos las columnas recorridas con 3
	ADDGE r3,r3, #26	// Si el numero de columnas recorridas es igual o mayor que 3, saltamos a la siguiente fila
	ADDGE r4,r4,#1		// Si saltamos de fila sumamos 1 al contador de filas recorridas
	MOVGE r6,#0			// Si el numero de columnas recorridas es igual o mayor que 3, reseteamos el contador de columnas
	ADDLT r5,r5,#2		// Si el numero de columnas recorridas es menor que 3 avanzamos a la siguiente columna

	CMP r4,#3			// Comparamos el numero de filas recorridas con 3
	BLT forRegion		// Si el numero de filas recorridas es menor que 3 volvemos al bucle

	POP {pc}			// Volvemos a la rutina init



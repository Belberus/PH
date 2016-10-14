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

sudoku_candidatos_propagar_arm:
.arm
	PUSH {lr}
	MOV r4,#0	// Contador de pablos
	MOV r5, r1, LSL #5
	ADD r6, r5, r2, LSL #1
	ADD r6,r6,r0
	LDRH r6, [r6]	// Cargamos el "valor"
	
	AND r6,r6, #0x000F	// Valor
	MOV r7,#0x0008
	MOV r7,r7, LSL r5	// Mascara del valor
	MVN r7,r7	// Invertimos el valor

	MOV r5,r0
// PROPAGAMOS POR LA FILA
forFila:
	LDRH r8,[r5]
	AND r8,r8,r7	// Aplicamos la mascara
	STRH r8,[r5]

	ADD r4,r4,#1
	ADD r5,r5,#2
	CMP r4,#9
	BNE forFila

// PREPARAMOS LOS VALORES
	MOV r5,#0
	ADD r5,r0,r2	// Nos situamos en la primera posicion de la columna 

// PROPAGAMOS POR COLUMNA
forColum:
	LDRH r8,[r5]
	AND r8,r8,r7	// Aplicamos la mascara
	STRH r8,[r5]

	ADD r4,r4,#1
	ADD r5,r5,#32
	CMP r4,#9
	BNE forColum

// PREPARAMOS LOS DATOS
	MOV r10,#0	// Resultado division fila
	MOV r11,#0	// Resultado division columna
	PUSH {r0,r1,r2}	// Guardamos los parametros para no modificarlos

divFila:
	CMP r1,#3
	SUBGE r1,r1,#3
	ADDGE r4,r4,#1 
	BGE divFila

divCol:
	CMP r2,#3
	SUBGE r2,r2,#3
	ADDGE r9,r9,#1
	BGE divCol

	MOV r1, #3
	MUL r4,r10, r1	// Posicion inicial fila
	MUL r9,r11, r1	// Posicion inicial columna
	
	// Nos situamos en la posicion inicial del Sector
	ADD r3, r0, r4, LSL #5
	ADD r3,r3, r9, LSL #1

	POP {r0,r1,r2}	// Recuperamos el valor de los parametrosç

	MOV r1, #0	// Contador filas
	MOV r2, #0	// Contador columnas
/*	
	r0 cuadricula
	r1 contador
	r2 contador
	r3 posicion inicial del cuadrante 
	r7 mascara pablera ya preparado
*/

// PROPAGAMOS POR LA REGION
forRegion:
	LDRH r8,[r3]
	AND r8,r8,r7	// Aplicamos la mascara
	STRH r8,[r3]

	ADD r1,r1,#1	// Incrementamos contador de fila	
	CMP r1,#3
	ADDGE r3,r3, #26	// Saltamos a la fila siguiente
	MOVGE r1,#0
	ADDGE r2,r2,#1
	ADDLT r3,r3,#2	// Si no toca saltar fila avanzamos a la siguiente posicion

	CMP r2,#3
	BLT forRegion

	POP {pc}	// Volvemos a la rutina init



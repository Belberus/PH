.text

.global sudoku_candidatos_init_arm, sudoku_candidatos_propagar_arm

sudoku_candidatos_init_arm:
.arm

bitP EQU 0x8000		// Usada para devolver el bit P
mascaraIni EQU 0x1FF0		// Usada para inicializar los bits candidatos

	MOV r4, #0	// Contador de columnas
	MOV r5, r0	// Direccion actual (inicial)
	MOV r6, #0	// Celdas vacias
	MOV r7, #0  // Contador de filas
	MOV r8, r0	// porsiaca

// INICIALIZA LISTA DE CANDIDATOS
for1:	
	LDR r5, [r5]	// Cargamos en r5 el valor de la direccion actual
	AND r5, r5, =bitP	// Obtenemos el bit de P (pista)
	CMP r5, =bitP 	// Comparamos para saber si lo que hay en r5 es una pista
	MOVNE r6, =mascaraIni
	STRNE r6, [r5]		// Si no es pista metemos los candidatos iniciales

	CMP r4,#8		// Saber si hemos llegado a la ultima columna del tablero
	ADDEQ r5,r5,#14	// Saltar a la siguiente fila
	ADDEQ r7,r7,#1	// Sumamos 1 a la fila
	MOVEQ r4,#0

	ADDNE r4,r4,#1	// Incrementamos la columna
	ADDNE r5,r5,#2	// Avanzamos a la siguiente direccion
	CMP r7,#9	// Comprobamos si hemos llegado al final
	BNE for1

// RESETEAMOS LOS VALORES
	MOV r4, #0	// Contador de columnas
	MOV r5, r0	// Direccion actual (inicial)
	MOV r7, #0  // Contador de filas

// RECORREMOS CELDA, SI ES PISTA PROPAGAMOS
for2:	
	LDR r8, [r5]	// Cargamos en r8 el valor de la direccion actual
	AND r8, r8, =bitP	// Obtenemos el bit de P (pista)
	CMP r8, =bitP 	// Comparamos para saber si lo que hay en r8 es una pista

	// Invocacion (si es pista)
	MOVEQ r1,r7 	// r1 = filas
	MOVEQ r2,r4		// r2 = columnas
	PUSHEQ{r4-r8}
	BLEQ sudoku_candidatos_propagar_arm	// Saltamos a propagar
	POPEQ{r4-r8}

	ADDNE r6,r6,#1	// CeldasVacias++

	CMP r4,#8		// Saber si hemos llegado a la ultima columna del tablero
	ADDEQ r5,r5,#14	// Saltar a la siguiente fila
	ADDEQ r7,r7,#1	// Sumamos 1 a la fila
	MOVEQ r4,#0

	ADDNE r4,r4,#1	// Incrementamos la columna
	ADDNE r5,r5,#2	// Avanzamos a la siguiente direccion
	CMP r7,#9	// Comprobamos si hemos llegado al final
	BNE for2

sudoku_candidatos_propagar_arm:
.arm
	PUSH{lr}
	MOV r4,#0	// Contador de pablos
	MOV r5, r1 LSL #5
	ADD r6, r5, r2 LSL #1
	ADD r6,r6,r0
	LDR r6, [r6]	// Cargamos el "valor"
	
	AND r6,r6,0x000F	// Valor
	MOV r7,0x0008
	MOV r7,r7 LSL #r5	// Mascara del valor
	MVN r7,r7	// Invertimos el valor

forFila:
	LDR r8,[r5]
	AND r8,r8,r7	// Aplicamos la mascara
	STR r8,[r5]

	ADD r4,r4,#1
	ADD r5,r5,#2
	CMP r4,#9
	BNE forFila

	MOV r5,#0
	ADD r5,r0,r2	// Nos situamos en la primera posicion de la columna 
forColum:
	LDR r8,[r5]
	AND r8,r8,r7	// Aplicamos la mascara
	STR r8,[r5]

	ADD r4,r4,#1
	ADD r5,r5,#32
	CMP r4,#9
	BNE forColumna




	POP{pc}	// Volvemos a la rutina init




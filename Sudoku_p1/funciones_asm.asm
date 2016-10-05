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
for1	LDR r5, [r5]	// Cargamos en r5 el valor de la direccion actual
		AND r5, r5, =bitP	// Obtenemos el bit de P (pista)
		CMP r5, =bitP 	// Comparamos para saber si lo que hay en r5 es una pista
		MOVNE r6, =mascaraIni
		STRNE r6, [r5]		// Si no es pista metemos los candidatos iniciales

		CMP r4, #8		// Saber si hemos llegado a la ultima columna del tablero
		ADDEQ r5,r5, #14	// Saltar a la siguiente fila
		ADDEQ r7,r7,#1	// Sumamos 1 a la fila
		MOVEQ r4, #0

		ADDNE r4,r4,#1	// Incrementamos la columna
		ADDNE r5,r5, #2	// Avanzamos a la siguiente direccion
		CMP r7,#9	// Comprobamos si hemos llegado al final
		BNE for1

// RESETEAMOS LOS VALORES
	MOV r4, #0	// Contador de columnas
	MOV r5, r0	// Direccion actual (inicial)
	MOV r7, #0  // Contador de filas

// RECORREMOS CELDA, SI ES PISTA PROPAGAMOS
for2	LDR r5, [r5]	// Cargamos en r5 el valor de la direccion actual
		AND r5, r5, =bitP	// Obtenemos el bit de P (pista)
		CMP r5, =bitP 	// Comparamos para saber si lo que hay en r5 es una pista

		// Invocacion (si es pista)
		PUSH{r4-r8}
		BL sudoku_candidatos_propagar_arm	// Saltamos a propagar
		POP{r4-r8}

		ADDNE r6,r6 #1	// CeldasVacias++

		CMP r4, #8		// Saber si hemos llegado a la ultima columna del tablero
		ADDEQ r5,r5, #14	// Saltar a la siguiente fila
		ADDEQ r7,r7,#1	// Sumamos 1 a la fila
		MOVEQ r4, #0

		ADDNE r4,r4,#1	// Incrementamos la columna
		ADDNE r5,r5, #2	// Avanzamos a la siguiente direccion
		CMP r7,#9	// Comprobamos si hemos llegado al final
		BNE for2


sudoku_candidatos_propagar_arm:
.arm

	PUSH{lr}





	POP{pc}	// Volvemos a la rutina init




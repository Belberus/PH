#include "sudoku_2016.h"

/* *****************************************************************************
 * Funciones privadas (static)
 * (no pueden ser invocadas desde otro fichero) */
 
/* *****************************************************************************
 * modifica el valor almacenado en la celda indicada */
static inline void
celda_poner_valor(CELDA *celdaptr, uint8_t val)
{
    *celdaptr = (*celdaptr & 0xFFF0) | (val & 0x000F);
}

/* *****************************************************************************
 * extrae el valor almacenado en los 16 bits de una celda */
static inline uint8_t
celda_leer_valor(CELDA celda)
{
    return (celda & 0x000F);
}

/* *****************************************************************************
 * propaga el valor de una determinada celda
 * para actualizar las listas de candidatos
 * de las celdas en su su fila, columna y región */
static void
sudoku_candidatos_propagar_c(CELDA cuadricula[NUM_FILAS][NUM_COLUMNAS],
                             uint8_t fila, uint8_t columna)
{
    /* valor que se propaga */
    uint8_t valor = celda_leer_valor(cuadricula[fila][columna]);
    /* filtro base rotado "valor" veces */
    uint16_t filtro = (0x0008 << (valor));
    /* nuevo valor */
    uint16_t nuevoValor = ~filtro;

    int i,x,y;

    /* recorrer fila descartando valor de listas candidatos */
    for(i=0; i<9;i++){
    	cuadricula[fila][i] = (cuadricula[fila][i] & nuevoValor);
    }
    /* recorrer columna descartando valor de listas candidatos */
    for(i=0; i<NUM_FILAS;i++){
        	cuadricula[i][columna] = (cuadricula[i][columna] & nuevoValor);
    }
    /* recorrer region descartando valor de listas candidatos */
    int cuadrante_i = fila / 3;    // Nos dara el cuadrante en el eje Y en el que esta (1 = fila 1, 2 = fila 2, 3 = fila 3)
    int cuadrante_j = columna / 3;    // Nos dara el cuadrante en el eje X en el que esta (1 = columna 1, 2 = columna 2, 3 = columna 3)
    int inicio_i = (cuadrante_i * 3);   // Segun el cuadrante empezaremos en una posicion u otra
    int inicio_j = (cuadrante_j * 3);   // Segun el cuadrante empezaremos en una posicion u otra

    for (y = inicio_i; y<= inicio_i +2; y++){  // Recorremos desde fila inicial (del cuadrante en cuestion) hasta fila final (del cuadrante en cuestion)
        for (x = inicio_j; x<=inicio_j +2; x++){     // Recorremos desde columna inicial (del cuadrante en cuestion) hasta columna final (del cuadrante en cuestion)
            cuadricula[y][x] = (cuadricula[y][x] & nuevoValor); // Aplicamos el filtrado como en los casos anteriores
        }
    }
}

/* *****************************************************************************
 * calcula todas las listas de candidatos (9x9)
 * necesario tras borrar o cambiar un valor (listas corrompidas)
 * retorna el numero de celdas vacias */
static int
sudoku_candidatos_init_c(CELDA cuadricula[NUM_FILAS][NUM_COLUMNAS])
{
    int celdas_vacias = 0;
    int i,j;
    /* recorrer cuadricula celda a celda */
        /* inicializa lista de candidatos */
	for(i=0; i<NUM_FILAS;i++){
		for(j=0; j<9;j++){
			if ((cuadricula[i][j] & 0x8000) != 0x8000){	 //Si el bit P es igual a 0, inicializamos candidatos
				cuadricula[i][j] = 0x1FF0;
			}
		}
	}
    /* recorrer cuadricula celda a celda */
        /* si celda tiene valor */
        /*    sudoku_candidatos_propagar_c(...); */
        /* else actualizar contador de celdas vacias */

	for(i=0; i<NUM_FILAS;i++){
		for(j=0; j<9;j++){		// Aunque haya 16 columnas, miramos solo las 9 que nos interesan
			if ((cuadricula[i][j] & 0x8000) == 0x8000){	 //Si el bit P es igual a 1, hay que propagar (limpiar candidatos)
				sudoku_candidatos_propagar_c(cuadricula,i,j);
			}else celdas_vacias++;
		}
	}
    /* retorna el numero de celdas vacias */
    return (celdas_vacias);
}

/* *****************************************************************************
 * Funciones públicas
 * (pueden ser invocadas desde otro fichero) */

/* *****************************************************************************
 * programa principal del juego que recibe el tablero,
 * y la señal de ready que indica que se han actualizado fila y columna */
void
sudoku9x9(CELDA cuadricula[NUM_FILAS][NUM_COLUMNAS], char *ready)
{
    int celdas_vacias;     //numero de celdas aun vacias

    /* calcula lista de candidatos, versión C */
    celdas_vacias = sudoku_candidatos_init_c(cuadricula);

    /* verificar que la lista de candidatos calculada es correcta */
    /* cuadricula_candidatos_verificar(...) */

    /* repetir para otras versiones (C optimizado, ARM, THUMB) */
}


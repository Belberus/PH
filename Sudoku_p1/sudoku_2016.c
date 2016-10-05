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
    uint16_t filtro = (0x0001 << (valor));

    /* recorrer fila descartando valor de listas candidatos */
    for(int i=0; i<NUM_COLUMNAS;i++){
    	cuadricula[fila][i] = 0xFFFF;
    }
    /* recorrer columna descartando valor de listas candidatos */
    for(int i=0; i<NUM_FILAS;i++){
        	cuadricula[i][columna] = 0xFFFF;
    }
    /* recorrer region descartando valor de listas candidatos */
}

/* *****************************************************************************
 * calcula todas las listas de candidatos (9x9)
 * necesario tras borrar o cambiar un valor (listas corrompidas)
 * retorna el numero de celdas vacias */
static int
sudoku_candidatos_init_c(CELDA cuadricula[NUM_FILAS][NUM_COLUMNAS])
{
    int celdas_vacias = 0;

    /* recorrer cuadricula celda a celda */
        /* inicializa lista de candidatos */
	for(int i=0; i<NUM_FILAS;i++){
		for(int j=0; j<NUM_COLUMNAS;j++){
			if ((cuadricula[i][j] & 0x8000) != 0x8000){	 //Si el bit P es igual a 0, inicializamos candidatos
				cuadricula[i][j] = 0x1FF0;
			}
		}
	}
    /* recorrer cuadricula celda a celda */
        /* si celda tiene valor */
        /*    sudoku_candidatos_propagar_c(...); */
        /* else actualizar contador de celdas vacias */

	for(int i=0; i<NUM_FILAS;i++){
		for(int j=0; j<NUM_COLUMNAS;j++){
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


/*****************************************************************************\
| Programa de prueba de la tabla de jugadas óptimas                           |
+-----------------------------------------------------------------------------+
| Desarrollado por Mariano Beiró y Mariano Chouza para Laboratorio de         |
| Microcomputadoras.                                                          |
+-----------------------------------------------------------------------------+
| Desarrollo comenzado el 16/9/2007                                           |
\*****************************************************************************/

#include <assert.h>
#include <memory.h>
#include <stdio.h>
#include <stdlib.h>

/*

Tabla

0	111
1	1101
2	1011
3	10001
4	1001
5	110001
6	110011
7	11000006
8	110010
9	1100001
10	1010
11	10000
12	0

*/

#define MSB_SET_ONLY	(~(~0 >> 1))

#define STATUS_DRAW		9
#define STATUS_X_WON	10
#define STATUS_O_WON	11
#define STATUS_INVALID	12

#define EMPTY_CELL	0
#define X_CELL		1
#define O_CELL		2

/* Devuelve 0 si el bit era 0 o != 0 si el bit era 1 */
unsigned ReadBit(const unsigned char buffer[], unsigned bit_offset)
{
	return buffer[bit_offset / 8] & (1 << (7 - bit_offset % 8));
}

/* Decodifica de acuerdo a la tabla huffman un valor de la tabla. Devuelve la
   cantidad de bits leída */
unsigned HuffmanDecode(	const unsigned char comp_table[],
						unsigned* p_bit_offset)
{
	/* Máquina de estados finitos */
	
#define GET_BIT	ReadBit(comp_table, (*p_bit_offset)++)
	
/*NODE_A: */
	if (GET_BIT)
		goto NODE_B;
	else
		return 12;

NODE_B:
	if (GET_BIT)
		goto NODE_D;
	else
		goto NODE_C;
		
NODE_C:
	if (GET_BIT)
		goto NODE_F;
	else
		goto NODE_E;
		
NODE_D:
	if (GET_BIT)
		return 0;
	else
		goto NODE_G;
		
NODE_E:
	if (GET_BIT)
		return 4;
	else
		goto NODE_H;
		
NODE_F:
	if (GET_BIT)
		return 2;
	else
		return 10;
		
NODE_G:
	if (GET_BIT)
		return 1;
	else
		goto NODE_I;
		
NODE_H:
	if (GET_BIT)
		return 3;
	else
		return 11;
		
NODE_I:
	if (GET_BIT)
		goto NODE_K;
	else
		goto NODE_J;
		
NODE_J:
	if (GET_BIT)
		return 5;
	else
		goto NODE_L;
		
NODE_K:
	if (GET_BIT)
		return 6;
	else
		return 8;

NODE_L:
	if (GET_BIT)
		return 9;
	else
		return 7;

#undef GET_BIT
}

/* Leo la tabla comprimida */
unsigned char* ReadCompTable(const char* name)
{
	/* Archivo */
	FILE* fp;
	/* Buffer */
	unsigned char* p_buffer;
	/* Tamaño */
	size_t tam;
	
	/* Abro el archivo */
	fp = fopen(name, "r");
	
	/* Obtengo el tamaño */
	fseek(fp, 0, SEEK_END);
	tam = ftell(fp);
	fseek(fp, 0, SEEK_SET);
	
	/* Reservo el buffer */
	p_buffer = (unsigned char*)malloc(tam);
	
	/* Leo todo el archivo */
	fread(p_buffer, tam, 1, fp);
	
	/* Cierro el archivo */
	fclose(fp);
	
	/* Devuelvo el buffer */
	return p_buffer;
}

/* Traduce un caracter a como debe aparecer en el tablero */
char TranslateChar(unsigned char boardChar)
{
	switch (boardChar)
	{
	case EMPTY_CELL:
		return ' ';
	case X_CELL:
		return 'X';
	case O_CELL:
		return 'O';
	default:
		assert(0);
		return -1;
	}
}

/* Muestra un tablero */
void ShowBoard(const unsigned char board[9])
{
	/* i y j */
	int i, j;
	
	/* Recorro todas las filas */
	for (i = 0; i < 3; i++)
	{
		/* Recorro todas las columnas */
		for (j = 0; j < 3; j++)
		{
			putchar(TranslateChar(board[3 * i + j]));
			
			if (j < 2)
				putchar('|');
			else
				putchar('\n');
		}
		
		if (i < 2)
			printf("-+-+-\n");
	}
}		

/* Hago la movida del jugador humano */
void MakeHumanMove(unsigned char board[9], unsigned char who_is_human)
{
	/* Movida */
	int move;

	/* Precondiciones */
	assert(board && (who_is_human == 1 || who_is_human == 2));
	
	/* Le pregunto al jugador que desea hacer */
	do
	{
		printf("Elija su movida (dígito del 0 al 8): ");
		scanf(" %d", &move);
	}
	while (	(move > 8 || move < 0 || board[move] != 0) &&
			printf(	"Ingrese un valor del 0 al 8 correspondiente"
					" a una celda vacía\n"));
	
	/* Marco la jugada */
	board[move] = who_is_human;
}			

/* Obtengo un ítem desde la tabla */
unsigned char GetTableItem(	const unsigned char comp_table[],
							unsigned offset)
{
	/* Valor a retornar */
	unsigned ret;
	/* i */
	unsigned i;
	/* Offset en la tabla */
	unsigned bit_offset = 0;
	
	/* Pido todos, solo me queda el que busco */
	for (i = 0; i <= offset; i++)
		ret = HuffmanDecode(comp_table, &bit_offset);
	
	/* Devuelvo el valor buscado */
	return ret;
}

/* Codifica un tablero */
unsigned EncodeBoard(const unsigned char board[9])
{
	/* i */
	int i;
	/* Tablero codificado */
	unsigned enc_board = 0;

	/* Acumulo las celdas */
	for (i = 8; i >= 0; i--)
	{
		enc_board *= 3;
		enc_board += board[i];
	}

	/* Devuelvo el tablero codificado */
	return enc_board;
}

/* Hago la movida de la computadora */
void MakeAIMove(unsigned char board[9], unsigned char who_is_ai,
				const unsigned char comp_table[])
{
	/* Movida */
	unsigned char move;
	
	/* Precondiciones */
	assert(board && (who_is_ai == 1 || who_is_ai == 2));
	
	/* Obtengo la movida a efectuar desde la tabla */
	move = GetTableItem(comp_table, EncodeBoard(board));
	
	/* Debería ser válida */
	assert(move < 9);
	
	/* Realizo la movida */
	board[move] = who_is_ai;

	/* Digo que eligió */
	printf("Yo elijo la movida %d.\n", move);
}

/* Comprueba si el partido terminó */
int IsFinished(const unsigned char board[9], const unsigned char comp_table[])
{
	assert(GetTableItem(comp_table, EncodeBoard(board)) != STATUS_INVALID);
	
	if (GetTableItem(comp_table, EncodeBoard(board)) > 8)
		return 1;
	else
		return 0;
}

/* Muestra el resultado */
void ShowResult(const unsigned char board[9],
				const unsigned char comp_table[])
{
	/* Muestro el tablero final */
	ShowBoard(board);

	/* Elijo en base a loq ue diga la tabla */	
	switch (GetTableItem(comp_table, EncodeBoard(board)))
	{
	case STATUS_X_WON:
		printf("Ganaron las X!\n");
		break;
	case STATUS_O_WON:
		printf("Ganaron las O!\n");
		break;
	case STATUS_DRAW:
		printf("El resultado fue empate.\n");
		break;
	default:
		assert(0);
		printf("ERROR INTERNO\n");
	}
}

/* Juega una partida */
void PlayGameWithPlayer(const unsigned char comp_table[],
						unsigned char who_is_human)
{
	/* Tablero */
	unsigned char board[9];
	
	/* Precondiciones */
	assert(who_is_human == 1 || who_is_human == 2);
	assert(comp_table);
	
	/* Inicializo el tablero */
	memset(board, 0, sizeof(board));
	
	/* Hasta que termine... sale desde el interior */
	while (1)
	{
		/* Muestro el tablero */
		ShowBoard(board);
		
		/* Si ahora juega una persona... */
		if (who_is_human == 1)
			MakeHumanMove(board, 1);
		else
			MakeAIMove(board, 1, comp_table);
			
		/* Me fijo si ganó alguien */
		if (IsFinished(board, comp_table))
			break;
			
		/* Muestro el tablero */
		ShowBoard(board);
		
		/* Si ahora juega una persona... */
		if (who_is_human == 2)
			MakeHumanMove(board, 2);
		else
			MakeAIMove(board, 2, comp_table);
			
		/* Me fijo si ganó alguien */
		if (IsFinished(board, comp_table))
			break;
	}
	
	/* Indico el resultado */
	ShowResult(board, comp_table);
}				

/* Entry point */
int main(void)
{
	/* Tabla comprimida */
	unsigned char* comp_table;
	/* Quién es el jugador humano */
	unsigned char who_is_human = 0;
	
	/* Leo la tabla */
	comp_table = ReadCompTable("../table_gen/comp.bin");
	
	/* Le pregunto al jugador con quién desea jugar */
	do
	{
		printf("Desea jugar con las Xs o con las Os? ");
		scanf(" %c", &who_is_human);
		if (who_is_human == 'x' || who_is_human == 'X')
			who_is_human = 1;
		else if (who_is_human == 'o' || who_is_human == 'O')
			who_is_human = 2;
		else
			who_is_human = 0;
	} 
	while (who_is_human == 0);
	
	/* Juego una partida */
	PlayGameWithPlayer(comp_table, who_is_human);

	/* Libero la tabla */
	free(comp_table);

	/* OK */
	return 0;
}

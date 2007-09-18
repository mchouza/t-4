/*****************************************************************************\
| Generador de tabla de jugadas �ptimas                                       |
+-----------------------------------------------------------------------------+
| Desarrollado por Mariano Beir� y Mariano Chouza para Laboratorio de         |
| Microcomputadoras.                                                          |
+-----------------------------------------------------------------------------+
| Desarrollo comenzado el 15/9/2007                                           |
\*****************************************************************************/

#include <assert.h>
#include <memory.h>
#include <stdio.h>
#include <stdlib.h>

/* Cantidad de bits de la runlength */
#define RUNLENGTH_BITS 5

/* Cantidad de tableros. Hay 3 posibilidades (' ', 'X', 'O') para cada una de
las 9 celdas */
#define NUM_BOARDS (3*3*3 * 3*3*3 * 3*3*3)

/* 
   Las jugadas se codifican utilizando un n�mero del 0 al 8, de la siguiente
   forma:
   
   0|1|2
   -+-+-
   3|4|5
   -+-+-
   6|7|8
   
   Cualquier valor mayor que 8 indica que no existe una mejor movida,
   por ejemplo, porque las posici�n no puede alcanzarse.

   9 indica que termin� en empate.
   10 indica que termin� con la vistoria de las 'X's
   11 indica que termin� con la victoria de las 'O's
   12 indica que la posici�n no puede alcanzarse en el juego

   Siempre asumo que empiezan moviendo las 'X's.
*/

#define STATUS_DRAW		9
#define STATUS_X_WON	10
#define STATUS_O_WON	11
#define STATUS_INVALID	12

/*
   El tablero se codifica asignando los siguientes c�digos a cada celda:
   
   ' ' -> 0
   'X' -> 1
   'O' -> 2

   Entonces puede verse al tablero como un n�mero en base 3, en el cual el
   d�gito menos significativo ser�a el asociado a la celda 0 y el m�s, el
   asociado a la celda 8.
*/

/*
   El puntaje minimax de las movidas asume que un empate vale 0, una victoria
   de las 'X's vale +1 y uan victoria de las 'O's vale -1
*/

#define EMPTY_CELL	0
#define X_CELL		1
#define O_CELL		2

#define INVERT_WHO_MOVES(who_move)	(3 - (who_move))

#define MAX(a, b) (((a) > (b)) ? (a) : (b))
#define MIN(a, b) (((a) > (b)) ? (b) : (a))


/* Tabla Huffman */
int huffman_table[][2] =
{
	{0x7,	3},
	{0xd,	4},
	{0xb,	4},
	{0x11,	5},
	{0x9,	4},
	{0x31,	6},
	{0x33,	6},
	{0x60,	7},
	{0x32,	6},
	{0x61,	7},
	{0xa,	4},
	{0x10,	5},
	{0x0,	1}
};

/*

Tabla

0	111
1	1101
2	1011
3	10001
4	1001
5	110001
6	110011
7	1100000
8	110010
9	1100001
10	1010
11	10000
12	0

*/


/* Codifica un tablero */
unsigned EncodeBoard(unsigned char board[9])
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

/* Decodifica un tablero */
void DecodeBoard(unsigned char board[9], unsigned enc_board)
{
	/* i */
	unsigned i;

	/* Para cada celda */
	for (i = 0; i < 9; i++)
	{
		board[i] = (unsigned char)(enc_board % 3);
		enc_board /= 3;
	}
}

/* Obtiene el puntaje inmediato */
int GetInmediateScore(unsigned char board[9])
{
	/* i */
	int i;

	/* Recorro simult�neamente filas y columnas */
	for (i = 0; i < 3; i++)
	{
		/* Si hay 3 iguales en la fila i */
		if (board[3*i] != 0 && board[3*i] == board[3*i+1] &&
			board[3*i+1] == board[3*i+2])
			return board[3*i] == X_CELL ? 1 : -1;

		/* Si hay 3 iguales en la columna i */
		if (board[i] != 0 && board[i] == board[i+3] &&
			board[i+3] == board[i+6])
			return board[i] == X_CELL ? 1 : -1;
	}

	/* Si hay 3 iguales en la diagonal principal */
	if (board[0] != 0 && board[0] == board[4] && board[4] == board[8])
		return board[0] == X_CELL ? 1 : -1;

	/* Si hay 3 iguales en la diagonal secundaria */
	if (board[2] != 0 && board[2] == board[4] && board[4] == board[6])
		return board[2] == X_CELL ? 1 : -1;

	/* Empate */
	return 0;
}

/* Devuelve 1 si el tablero est� lleno o 0 si no lo est� */
int IsBoardFilled(const unsigned char board[9])
{
	/* i */
	int i;

	/* Recorro el tablero */
	for (i = 0; i < 9; i++)
		/* Si hay uno vac�o... */
		if (board[i] == 0)
			/* ...no est� lleno. */
			return 0;

	/* Est� lleno */
	return 1;
}


/* Obtiene el puntaje minimax en forma recursiva */
int RecMiniMaxScore(unsigned char board[9], unsigned char who_moves)
{
	/* Movida */
	unsigned char move;
	/* Puntaje */
	int score;
	/* Mejor puntaje */
	int best_score;
	/* Puntaje inmediato */
	int inm_score;
	
	/* Inicializo el mejor puntaje con el peor posible */
	best_score = (who_moves == X_CELL) ? -2 : +2;

	/* Obtengo el puntaje inmediato */
	inm_score = GetInmediateScore(board);

	/* Si el inmediato es distinto de cero, ya termin� */
	if (inm_score != 0 || IsBoardFilled(board))
		return inm_score;

	/* Pruebo todas las posibles movidas */
	for (move = 0; move < 9; move++)
	{
		/* Si la celda est� ocupada, pruebo con otra */
		if (board[move] != EMPTY_CELL)
			continue;

		/* Hago la movida */
		board[move] = who_moves;

		/* Obtengo el puntaje de esta movida */
		score = RecMiniMaxScore(board, INVERT_WHO_MOVES(who_moves));

		/* Si es mejor que el mejor visto hasta ahora, lo guardo */
		best_score = (who_moves == X_CELL) ?
			MAX(score, best_score) : MIN(score, best_score);

		/* Deshago las movidas */
		board[move] = EMPTY_CELL;

		/* Si es el mejor posible, corto */
		if (best_score == ((who_moves == X_CELL) ? +1 : -1))
			break;
	}

	/* Devuelvo el mejor score */
	return best_score;
}

/* Obtiene la jugada �ptima en base a un tablero */
unsigned char MiniMaxGetOptimalMove(unsigned char board[9])
{
	/* Cantidad de 'X's */
	unsigned cant_x = 0;
	/* Cantidad de 'O's */
	unsigned cant_o = 0;
	/* Quien mueve */
	unsigned char who_moves;
	/* Movida */
	unsigned char move;
	/* i */
	unsigned i;
	/* Puntaje */
	int score;
	/* Puntaje inmediato */
	int inm_score;
	/* Mejor puntaje */
	int best_score;
	/* Mejor movida */
	unsigned char best_move = STATUS_DRAW;

	/* Me fijo si el partido ya termin� */
	inm_score = GetInmediateScore(board);
	if (inm_score != 0)
	{
		return (inm_score == 1) ? STATUS_X_WON : STATUS_O_WON;
	}

	/* Para cada celda */
	for (i = 0; i < 9; i++)
	{
		/* Incremento el contador que corresponda */
		if (board[i] == X_CELL)
			cant_x++;
		else if (board[i] == O_CELL)
			cant_o++;
	}

	/* Me fijo si es inv�lido: siempre hay m�s 'X's que 'O's pero no no m�s
	   de uno de diferencia */
	if (cant_x < cant_o || cant_x - cant_o > 1)
		return STATUS_INVALID;

	/* Obtengo quien mueve: si hay m�s 'X's que 'O's, mueven las 'O's */
	who_moves = (cant_x > cant_o) ? O_CELL : X_CELL;

	/* Inicializo el mejor puntaje con uno peor que lo que podr�a ser */
	best_score = (who_moves == X_CELL) ? -2 : +2;

	/* Recorro todas las celdas */
	for (move = 0; move < 9; move++)
	{
		/* Si no puedo mover, pruebo con la pr�xima */
		if (board[move] != EMPTY_CELL)
			continue;

		/* Realizo la movida */
		board[move] = who_moves;

		/* Obtengo el puntaje */
		score = RecMiniMaxScore(board, INVERT_WHO_MOVES(who_moves));

		/* Si es mejor que el mejor obtenido hasta ahora */
		if ((score > best_score && who_moves == X_CELL) ||
			(score < best_score && who_moves == O_CELL))
		{
			/* Guardo el nuevo mejor score y la nueva movida */
			best_score = score;
			best_move = move;
		}

		/* Deshago la movida */
		board[move] = EMPTY_CELL;
	}

	/* Devuelvo la mejor movida */
	return best_move;
}

/* En forma recursiva, exploro todos los juegos l�citos */
void RecPlayAllGames(unsigned char board[9],
					 unsigned char reached_boards[NUM_BOARDS],
					 unsigned char who_moves)
{
	/* Movida */
	unsigned char move;

	/* Marco que pas� por ac� */
	reached_boards[EncodeBoard(board)] = 1;

	/* Me fijo si gan� alguien */
	if (GetInmediateScore(board) != 0)
		return;

	/* Para todas las posiciones del tablero */
	for (move = 0; move < 9; move++)
	{
		/* Si est� ocupado, sigo con la otra */
		if (board[move] != EMPTY_CELL)
			continue;

		/* Hago la movida */
		board[move] = who_moves;

		/* Le paso el turno al otro */
		RecPlayAllGames(board, reached_boards, INVERT_WHO_MOVES(who_moves));

		/* Deshago la movida */
		board[move] = EMPTY_CELL;
	}
}

/* Marca las  posiciones que son imposibles de alcanzar. Como son muchas,
   obtengo mejor compresi�n de esa forma */
void MarkUnableToReachPos(unsigned char opt_move_table[NUM_BOARDS])
{

	/*
	   Para determinar esto, juego todas las partidas posibles y marco como
	   inv�lidas aquellas posiciones que no sean alcanzadas en alguno.
	   Probablemnet pueda hacerse en forma m�s eficiente, pero la tabla solo
	   se genera una vez...
    */

	/* Tablero */
	unsigned char board[9];
	/* Array de tableros: Si tiene cero no fue alcanzado, caso contrario, si
	   lo fue */
	unsigned char reached_boards[NUM_BOARDS];
	/* i */
	int i;

	/* Empiezo con el tablero vac�o */
	memset(board, '\0', sizeof(board));

	/* Empiezo con todos los tableros imposibles de alcanzar */
	memset(reached_boards, '\0', sizeof(reached_boards));

	/* Juego todas las partidas, marcando los tableros con que me cruzo */
	RecPlayAllGames(board, reached_boards, X_CELL);

	/* Recorro los arrays en paralelo, marcando los tableros inv�lidos */
	for (i = 0; i < NUM_BOARDS; i++)
	{
		if (reached_boards[i] == 0)
			/* No lleg� a este */
			opt_move_table[i] = STATUS_INVALID;
	}
}

/* Guardo la tabla sin comprimir en formato texto */
void RecordOMTAsTxt(unsigned char omt[NUM_BOARDS])
{
	/* Archivo de salida */
	FILE* uncomp_txt_fp;
	/* i */
	int i;

	/* Abro el archivo */
	uncomp_txt_fp = fopen("uncomp.txt", "w");

	/* Recorro la tabla */
	for (i = 0; i < NUM_BOARDS; i++)
		fprintf(uncomp_txt_fp, "%d\n", omt[i]);

	/* Cierra el archivo */
	fclose(uncomp_txt_fp);
}

/* Guardo la tabla sin comprimir en formato binario */
void RecordOMT(unsigned char omt[NUM_BOARDS])
{
	/* Archivo de salida */
	FILE* uncomp_bin_fp;
	/* i */
	int i;

	/* Abro el archivo */
	uncomp_bin_fp = fopen("uncomp.bin", "wb");

	/* Recorro la tabla */
	for (i = 0; i < NUM_BOARDS; i++)
		fputc(omt[i], uncomp_bin_fp);

	/* Cierra el archivo */
	fclose(uncomp_bin_fp);
}

/* Graba una cierta cantidad de bits en un archivo. Si 'cant_bits' es 0,
   graba lo que quede en el buffer interno, competando con 0s para llegar al
   byte. Asume que los datos est�n en los bits bajos */
void WriteBits(unsigned char data, unsigned cant_bits, FILE* fp)
{
	/* Buffer */
	static unsigned char buffer = 0;
	/* Cantidad de bits en el buffer */
	static unsigned buffer_bits_num = 0;
	/* Cantidad de bits que anexo al buffer */
	unsigned anexed_bits_num;

	/* Precondiciones */
	assert(cant_bits >= 0 && cant_bits <= 8 && fp != NULL);
	assert((data & ~((1 << cant_bits) - 1)) ==  0);

	/* Si 'cant_bits' es 0... */
	if (cant_bits == 0)
	{
		/* Muevo los datos a la parte alta del buffer */
		assert(buffer_bits_num < 8);
		buffer <<= (8 - cant_bits);

		/* Lo escribo */
		fputc(buffer, fp);

		/* Limpi� el buffer */
		buffer = 0;
		buffer_bits_num = 0;
	}

	/* Intento completar el byte del buffer con los datos */
	anexed_bits_num = MIN(8 - buffer_bits_num, cant_bits);
	assert(buffer_bits_num + anexed_bits_num <= 8);
	buffer <<= anexed_bits_num;
	buffer |= (data >> (cant_bits - anexed_bits_num));

	/* Si no se completa, actualizo las cantidades y dejo aca */
	buffer_bits_num += anexed_bits_num;
	assert(buffer_bits_num <= 8);
	if (buffer_bits_num < 8)
	{
		/* Contin�o en otro momento */
		return;
	}

	/* Si llegu� aca es porque tengo un byte a escribir, lo hago */
	fputc(buffer, fp);

	/* Copio al nuevo buffer los bits que no anex� */
	assert(anexed_bits_num <= cant_bits);
	buffer_bits_num = cant_bits - anexed_bits_num;
	buffer = (unsigned char)(data & ((1 << (buffer_bits_num)) - 1));
}

/* Guarda la tabla en formato comprimido de acuerdo a la tabla huffman */
void RecordOMTHC(unsigned char omt[NUM_BOARDS])
{
	/* Archivo de salida */
	FILE* comp_bin_fp;
	/* i */
	int i;

	/* Abro el archivo */
	comp_bin_fp = fopen("comp.bin", "wb");

	/* Recorro la tabla */
	for (i = 0; i < NUM_BOARDS; i++)
		WriteBits((unsigned char)huffman_table[omt[i]][0],
			huffman_table[omt[i]][1], comp_bin_fp);

	/* Hago flush */
	WriteBits(0, 0, comp_bin_fp);

	/* Cierra el archivo */
	fclose(comp_bin_fp);
}

/* Guarda la tabla en un formato muy extendido */
void RecordOMTExt(unsigned char omt[NUM_BOARDS])
{
	/* Archivo de salida */
	FILE* ext_txt_fp;
	/* i y j */
	int i, j;

	/* Abro el archivo */
	ext_txt_fp = fopen("ext.txt", "w");

	/* Recorro la tabla */
	for (i = 0; i < NUM_BOARDS; i++)
	{
		unsigned char board[9];
		fprintf(ext_txt_fp, "N�mero del tablero: %d\n", i);
		DecodeBoard(board, i);
		for (j = 0; j < 9; j++)
		{
			if (board[j] == 0)
				putc('.', ext_txt_fp);
			else if (board[j] == 1)
				putc('X', ext_txt_fp);
			else if (board[j] == 2)
				putc('O', ext_txt_fp);
			else
				putc('?', ext_txt_fp);
			if (j % 3 == 2)
				putc('\n', ext_txt_fp);
		}
		fprintf(ext_txt_fp, "Movida: %d\n------\n", omt[i]);
	}

	/* Cierra el archivo */
	fclose(ext_txt_fp);
}

/* Entry point */
int main(void)
{
	/* Tablero */
	unsigned enc_board;
	/* Tabla con las jugadas �ptimas */
	unsigned char opt_move_table[NUM_BOARDS];

	/* Para cada posible tablero */
	for (enc_board = 0; enc_board < NUM_BOARDS; enc_board++)
	{
		/* Tablero decodificado */
		unsigned char board[9];
		/* Jugada �ptima */
		unsigned char opt_move;

		/* Decodifico el tablero */
		DecodeBoard(board, enc_board);

		/* Obtengo la jugada �ptima */
		opt_move = MiniMaxGetOptimalMove(board);

		/* Almaceno el resultado en la tabla */
		opt_move_table[enc_board] = opt_move;

		/* Marco avance */
		if (enc_board % (NUM_BOARDS / 10) == 0)
			printf("Procesados %d tableros de un total de %d.\n", enc_board, NUM_BOARDS);
	}

	/* Marco los tableros imposibles de alcanzar */
	MarkUnableToReachPos(opt_move_table);

	/* Grabo la tabla en un formato legible */
	RecordOMTAsTxt(opt_move_table);

	/* Grabo la tabla en un formato binario */
	RecordOMT(opt_move_table);

	/* Graba la tabla con compresi�n Huffman */
	RecordOMTHC(opt_move_table);

	/* Graba la tabla en formato muy extendido */
	RecordOMTExt(opt_move_table);

	/* Listo */
	return 0;
}

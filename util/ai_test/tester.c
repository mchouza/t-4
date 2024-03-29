#define SQR(x) ((x)*(x))
#define NUM_BOARDS SQR(SQR(SQR(3))) * 3

int board;
unsigned char retorno;

unsigned char hi_ret, lo_ret;

extern unsigned char linea_0, linea_1, linea_2;
extern void encode_board();
extern void read_table();

void test_board_enc()
{
#define SPEC_FOR(v) for ((v) = 0; (v) < 3; (v)++)
	
	unsigned char pos_0_0, pos_0_1, pos_0_2;
	unsigned char pos_1_0, pos_1_1, pos_1_2;
	unsigned char pos_2_0, pos_2_1, pos_2_2;
	int eb = 0;

	SPEC_FOR(pos_2_2)
	SPEC_FOR(pos_2_1)
	SPEC_FOR(pos_2_0)
	SPEC_FOR(pos_1_2)
	SPEC_FOR(pos_1_1)
	SPEC_FOR(pos_1_0)
	SPEC_FOR(pos_0_2)
	SPEC_FOR(pos_0_1)
	SPEC_FOR(pos_0_0)
	{
		/* Codifico el tablero */
		linea_0 = pos_0_2 << 4 | pos_0_1 << 2 | pos_0_0;
		linea_1 = pos_1_2 << 4 | pos_1_1 << 2 | pos_1_0;
		linea_2 = pos_2_2 << 4 | pos_2_1 << 2 | pos_2_0;

		/* Llamo al procedimeinto que codifica el tablero */
		encode_board();

		/* Comparo */
		if (eb >> 8 != hi_ret || (eb & 0xff) != lo_ret)
		{
			int a = 0;
		}

		/* Incremento eb, que mantiene el tablero */
		++eb;
	}
	
#undef SPEC_FOR
}

void test_comp_table_read()
{
	/* XOR de todos los valores */
	unsigned char all_numbers_xor = 0;
	
	/* Suma % 256 de todos */
	unsigned char all_numbers_sum = 0;
	
	/* Pruebo con todos los valores posibles del tablero */
	for (board = NUM_BOARDS-1; board < NUM_BOARDS; board++)
	{
		/* Paso el offset en una variable global */
		/* Me devuelve el valor de retorno en retorno */
		/* Obtengo la suma % 256 y el XOR de todos */
		read_table();

		all_numbers_xor ^= retorno;
		all_numbers_sum += retorno;
	}
}

void main()
{
	/* Reviso la codificaci�n del tablero */
	test_board_enc();

	/* Reviso la lectura de la tabla comprimida */
	test_comp_table_read();

	/* Listo, quedo ac� */
	while (1);
}
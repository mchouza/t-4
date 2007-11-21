#define SQR(x) ((x)*(x))
#define NUM_BOARDS SQR(SQR(SQR(3))) * 3

int board;
unsigned char retorno;

extern void read_table();

void test_comp_table_read()
{
	/* XOR de todos los valores */
	unsigned char all_numbers_xor = 0;
	
	/* Suma % 256 de todos */
	unsigned char all_numbers_sum = 0;
	
	/* Pruebo con todos los valores posibles del tablero */
	for (board = 0; board < NUM_BOARDS; board++)
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
	/* Reviso la lectura de la tabla comprimida */
	test_comp_table_read();

	/* Listo, quedo acá */
	while (1);
}
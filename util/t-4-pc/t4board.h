//=============================================================================
// T^4 PC Terminal
//=============================================================================
// t4board.h
// Declara la clase T4Board, encargada de manejar y dibujar el tablero.
//-----------------------------------------------------------------------------
// Desarrollado por Mariano Beiró y Mariano Chouza para Laboratorio de
// Microcomputadoras.
//-----------------------------------------------------------------------------
// Desarrollo comenzado el 25/11/2007
//=============================================================================

#ifndef T4BOARD_H
#define T4BOARD_H

#include "t4common.h"

// Clase que representa el tablero
class T4Board
{
	// Contenido del tablero
	ET4Symbol boardData_[9];

	// Grado de avance en el dibujo de todos
	double boardDrawProgress_[9];

	// TA-TE-TI en...
	// 0 -> 3 indica fila, 3 -> 6 indica columna + 3, 6 -> 8 indica
	// diagonal, donde 6 sería la diagonal principal y 7 la secundaria
	bool t3MarkerAt_[8];

	// Grado de avance en el dibujo del marcador
	double t3MarkerDrawProgress_[8];

	// Actualiza una celda del tablero
	void updateBoardCell(size_t index, ET4Symbol newValue);

	// Actualiza los marcadores de TA-TE-TI
	void updateT3Markers(size_t index);

	// Actualiza un marcador de TA-TE-TI dado
	void updateT3Marker(size_t markerIndex);

public:
	// Constructor
	T4Board();

	// Dibuja el tablero en el DC indicado como parámetro
	void draw(CDC& dc) const;

	// Le envía una fila codificada al tablero para su actualización
	void sendCodedRow(unsigned char codedRow);

	// Indico el paso del tiempo
	void timeStep();
};

#endif


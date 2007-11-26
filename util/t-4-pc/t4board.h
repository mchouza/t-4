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

	// Actualiza una celda del tablero
	void updateBoardCell(unsigned index, ET4Symbol newValue);

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


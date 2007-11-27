//=============================================================================
// T^4 PC Terminal
//=============================================================================
// t4board.cpp
// Implementa la clase T4Board, encargada de manejar y dibujar el tablero.
//-----------------------------------------------------------------------------
// Desarrollado por Mariano Beiró y Mariano Chouza para Laboratorio de
// Microcomputadoras.
//-----------------------------------------------------------------------------
// Desarrollo comenzado el 25/11/2007
//=============================================================================

#include "stdafx.h"
#include "t4board.h"
#include <cassert>
#include <cmath>

// Contiene funciones útiles
namespace
{
	// Paso en que avanza el grado en que se completa el dibujo
	const double DRAW_PROGRESS_STEP = 0.05;
	
	// Dibuja la grilla
	void drawGrid(CDC& dc, CPen& pen)
	{
		// Selecciono el pen
		CPen* pOldPen = dc.SelectObject(&pen);

		// Dibujo la grilla
		dc.MoveTo(100, 5);
		dc.LineTo(100, 295);
		dc.MoveTo(200, 5);
		dc.LineTo(200, 295);
		dc.MoveTo(5, 100);
		dc.LineTo(295, 100);
		dc.MoveTo(5, 200);
		dc.LineTo(295, 200);

		// Restauro el pen anterior
		dc.SelectObject(pOldPen);
	}

	// Dibuja una X
	void drawX(CDC& dc, int xBase, int yBase, double completionFactor,
		CPen& pen)
	{
		// Selecciono el pen
		CPen* pOldPen = dc.SelectObject(&pen);

		// Dibujo la X
		if (completionFactor > 0.5)
		{
			int delta = static_cast<int>(60 * 2 * (completionFactor - 0.5));
			dc.MoveTo(xBase + 20, yBase + 20);
			dc.LineTo(xBase + 80, yBase + 80);
			dc.MoveTo(xBase + 80, yBase + 20);
			dc.LineTo(xBase + 80 - delta, yBase + 20 + delta);
		}
		else
		{
			int delta = static_cast<int>(60 * 2 * completionFactor);
			dc.MoveTo(xBase + 20, yBase + 20);
			dc.LineTo(xBase + 20 + delta, yBase + 20 + delta);
		}

		// Restauro el pen anterior
		dc.SelectObject(pOldPen);
	}

	// Dibuja una O
	void drawO(CDC& dc, int xBase, int yBase, double completionFactor,
		CPen& pen)
	{
		// Selecciono el pen
		CPen* pOldPen = dc.SelectObject(&pen);

		// Para evitar errores de redondeo
		completionFactor += 0.01;

		// Obtengo la posición del punto móvil
		int mpX = xBase + 50 +
			static_cast<int>(30.0 * cos(2 * PI * completionFactor));
		int mpY = yBase + 50 -
			static_cast<int>(30.0 * sin(2 * PI * completionFactor));

		// Dibujo la O
		if (completionFactor > 0.5)
		{	
			dc.Arc(xBase + 20, yBase + 20, xBase + 80, yBase + 80, xBase + 80,
				yBase + 50, xBase + 20, yBase + 50);
			dc.Arc(xBase + 20, yBase + 20, xBase + 80, yBase + 80, xBase + 20,
				yBase + 50, mpX, mpY);
		}
		else
		{
			dc.Arc(xBase + 20, yBase + 20, xBase + 80, yBase + 80, xBase + 80,
				yBase + 50, mpX, mpY);
		}

		// Restauro el pen anterior
		dc.SelectObject(pOldPen);
	}

	// Dibuja las marcas de TA-TE-TI
	void drawT3Marks(CDC& dc, const bool t3MarkerAt[],
		const double t3MarkerDrawProgress[], CPen& pen)
	{
		// Selecciono el pen
		CPen* pOldPen = dc.SelectObject(&pen);		

		// Dibujo las horizontales
		for (size_t i = 0; i < 3; i++)
		{
			if (t3MarkerAt[i])
			{
				dc.MoveTo(10, static_cast<int>(50 + 100 * i));
				dc.LineTo(10 + static_cast<int>(280 * t3MarkerDrawProgress[i]),
					static_cast<int>(50 + 100 * i));
			}
		}

		// Dibujo las verticales
		for (size_t i = 0; i < 3; i++)
		{
			if (t3MarkerAt[i + 3])
			{
				dc.MoveTo(static_cast<int>(50 + 100 * i), 10);
				dc.LineTo(static_cast<int>(50 + 100 * i),
					10 + static_cast<int>(280 * t3MarkerDrawProgress[i + 3]));
			}
		}

		// Dibujo la diagonal principal
		if (t3MarkerAt[6])
		{
			dc.MoveTo(10, 10);
			dc.LineTo(10 + static_cast<int>(280 * t3MarkerDrawProgress[6]),
				10 + static_cast<int>(280 * t3MarkerDrawProgress[6]));
		}

		// Dibujo la diagonal secundaria
		if (t3MarkerAt[7])
		{
			dc.MoveTo(10, 290);
			dc.LineTo(10 + static_cast<int>(280 * t3MarkerDrawProgress[7]),
				290 - static_cast<int>(280 * t3MarkerDrawProgress[7]));
		}

		// Restauro el viejo pen
		dc.SelectObject(pOldPen);	
	}
}

T4Board::T4Board(const TConfigMap& config) :
config_(config),
xPen_(PS_SOLID, 10, readIntFromConfigMap(config_, "XColor")),
oPen_(PS_SOLID, 10, readIntFromConfigMap(config_, "OColor")),
gridPen_(PS_SOLID, 5, readIntFromConfigMap(config_, "GridColor")),
slashPen_(PS_SOLID, 7, readIntFromConfigMap(config_, "SlashColor"))
{
	for (int i = 0; i < 9; i++)
		updateBoardCell(i, T4S_E);
}

void T4Board::draw(CDC& dc) const
{
	// Borro el fondo
	dc.BitBlt(0, 0, 300, 300, NULL, 0, 0, BLACKNESS);
	
	// Dibujo la grilla básica
	drawGrid(dc, gridPen_);

	// Recorro las posiciones llamando a las funciones de dibujo
	for (size_t i = 0; i < 9; i++)
	{		
		int index = static_cast<int>(i);

		if (boardData_[i] == T4S_X)
			drawX(dc, (index % 3) * 100, (index / 3) * 100,
				boardDrawProgress_[i], xPen_);
		else if (boardData_[i] == T4S_O)
			drawO(dc, (index % 3) * 100, (index / 3) * 100,
				boardDrawProgress_[i], oPen_);
	}

	// Dibujo los TA-TE-TIs observados
	drawT3Marks(dc, t3MarkerAt_, t3MarkerDrawProgress_, slashPen_);
}

void T4Board::sendCodedRow(unsigned char codedRow)
{
	// Me fijo que fila hay que actualizar
	unsigned row = codedRow >> 6;

	// Obtengo los valores de cada elemento de la fila 
	int rowElems[3];
	for (int i = 0; i < 3; i++)
		rowElems[i] = (codedRow >> (2 * i)) & 3;

	// Actualizo dicha fila
	for (int i = 0; i < 3; i++)
		updateBoardCell(row * 3 + i, static_cast<ET4Symbol>(rowElems[i]));
}

void T4Board::updateBoardCell(size_t index, ET4Symbol newValue)
{
	// Me fijo si cambió el valor
	if (boardData_[index] != newValue)
	{
		// Si, actualizo el valor
		boardData_[index] = newValue;
		boardDrawProgress_[index] = 0.0;

		// Actualizo los marcadores de TA-TE-TI
		updateT3Markers(index);
	}

	assert(boardData_[index] >= 0 && boardData_[index] < 3);
}

void T4Board::timeStep()
{
	// Recorro todos los símbolos...
	for (size_t i = 0; i < 9; i++)
		// Si no se terminó de dibujar...
		if (boardDrawProgress_[i] < 1.0)
			boardDrawProgress_[i] += DRAW_PROGRESS_STEP;
		else
			boardDrawProgress_[i] = 1.0;

	// Recorro todos los marcadores de TA-TE-TI...
	for (size_t i = 0; i < 8; i++)
	// Si no se terminó de dibujar...
		if (t3MarkerDrawProgress_[i] < 1.0)
			t3MarkerDrawProgress_[i] += DRAW_PROGRESS_STEP;
		else
			t3MarkerDrawProgress_[i] = 1.0;
}

void T4Board::updateT3Markers(size_t index)
{
	// Me fijo si cambia la diagonal principal
	if (index / 3 == index % 3)
		updateT3Marker(6);

	// Me fijo si cambia la diagonal secundaria
	if (index / 3 == 2 - index % 3)
		updateT3Marker(7);

	// Cambia una fila
	updateT3Marker(index / 3);

	// Cambia una columna
	updateT3Marker(index % 3 + 3);
}

void T4Board::updateT3Marker(size_t mi)
{
	// Nuevo estado del marcador
	bool newMarkerState;

	// Referencia para mayor comodidad
	const ET4Symbol (&b)[9] = boardData_;
	
	// Me fijo si actualiza fila
	if (mi < 3)
	{
		// Obtengo el nuevo estado
		newMarkerState =
			(b[3 * mi] == b[3 * mi + 1] &&
			b[3 * mi + 1] == b[3 * mi + 2] &&
			b[3 * mi] != T4S_E);
	}
	// O si actualiza columna...
	else if (mi < 6)
	{
		// Obtengo el nuevo estado
		newMarkerState =
			(b[mi - 3] == b[mi - 3 + 3] &&
			b[mi - 3 + 3] == b[mi - 3 + 6] &&
			b[mi - 3] != T4S_E);
	}
	// O si actualiza la diagonal principal
	else if (mi == 6)
	{
		// Obtengo el nuevo estado
		newMarkerState = (b[0] == b[4] && b[4] == b[8] && b[0] != T4S_E);
	}
	// Si llega hasta acá debe actualizar la diagonal secundaria
	else
	{
		assert(mi == 7);
		
		// Obtengo el nuevo estado
		newMarkerState = (b[2] == b[4] && b[4] == b[6] && b[2] != T4S_E);
	}

	// Comparo el nuevo estado con el viejo
	if (newMarkerState != t3MarkerAt_[mi])
	{
		// Actualizo
		t3MarkerAt_[mi] = newMarkerState;
		t3MarkerDrawProgress_[mi] = 0.0;
	}
}
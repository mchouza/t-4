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
#include <cmath>

// Contiene funciones útiles
namespace
{
	// Paso en que avanza el grado en que se completa el dibujo
	const double DRAW_PROGRESS_STEP = 0.05;
	
	// Dibuja la grilla
	void drawGrid(CDC& dc)
	{
		// Pen utilizada para dibujar la grilla
		static CPen whitePen(PS_SOLID, 5, RGB(255, 255, 255));
		
		// Selecciono el pen blanco
		CPen* pOldPen = dc.SelectObject(&whitePen);

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
	void drawX(CDC& dc, int xBase, int yBase, double completionFactor)
	{
		// Pen utilizada para dibujar la X
		static CPen redPen(PS_SOLID, 10, RGB(255, 0, 0));
		
		// Selecciono el pen blanco
		CPen* pOldPen = dc.SelectObject(&redPen);

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
	void drawO(CDC& dc, int xBase, int yBase, double completionFactor)
	{
		// Pen utilizada para dibujar la O
		static CPen bluePen(PS_SOLID, 10, RGB(0, 0, 255));
		
		// Selecciono el pen blanco
		CPen* pOldPen = dc.SelectObject(&bluePen);

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
}

T4Board::T4Board()
{
	for (int i = 0; i < 9; i++)
		updateBoardCell(i, T4S_E);
}

void T4Board::draw(CDC& dc) const
{
	// Borro el fondo
	dc.BitBlt(0, 0, 300, 300, NULL, 0, 0, BLACKNESS);
	
	// Dibujo la grilla básica
	drawGrid(dc);

	// Recorro las posiciones llamando a las funciones de dibujo
	for (size_t i = 0; i < 9; i++)
	{
		int index = static_cast<int>(i);

		if (boardData_[i] == T4S_X)
			drawX(dc, (index % 3) * 100, (index / 3) * 100,
				boardDrawProgress_[i]);
		else if (boardData_[i] == T4S_O)
			drawO(dc, (index % 3) * 100, (index / 3) * 100,
				boardDrawProgress_[i]);
	}
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
		// Si, actualizo
		boardData_[index] = newValue;
		boardDrawProgress_[index] = 0.0;

		// FIXME: Incorporar contador
	}
}

void T4Board::timeStep()
{
	// Recorro todos...
	for (size_t i = 0; i < 9; i++)
		// Si no se terminó de dibujar...
		if (boardDrawProgress_[i] < 1.0)
			boardDrawProgress_[i] += DRAW_PROGRESS_STEP;
		else
			boardDrawProgress_[i] = 1.0;
}
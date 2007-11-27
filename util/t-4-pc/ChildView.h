//=============================================================================
// T^4 PC Terminal
//=============================================================================
// ChildView.h
// Declara la clase CChildView, encargada de mostrar los gráficos.
//-----------------------------------------------------------------------------
// Desarrollado por Mariano Beiró y Mariano Chouza para Laboratorio de
// Microcomputadoras.
//-----------------------------------------------------------------------------
// Desarrollo comenzado el 25/11/2007
//=============================================================================

#pragma once

#include "serial_port.h"
#include "t4board.h"

// Clase encargada de mostrar los gráficos
class CChildView : public CWnd
{
	// Configuración
	TConfigSecMap config_;

	// Tablero
	T4Board board_;

	// Puerto serie
	SerialPort serialPort_;

	// DC del buffer
	CDC bufferDC_;

	// Bitmap del buffer
	CBitmap bufferBM_;

public:
	// C & D
	CChildView();
	virtual ~CChildView();

protected:
	// Overrides
	virtual BOOL PreCreateWindow(CREATESTRUCT& cs);

	// Mapa de mensajes
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	afx_msg BOOL OnEraseBkgnd(CDC* pDC);
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnPaint();
	afx_msg void OnTimer(UINT_PTR nIDEvent);
	DECLARE_MESSAGE_MAP()
};

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

#include "t4board.h"

// Clase encargada de mostrar los gráficos
class CChildView : public CWnd
{
	// Tablero
	T4Board board_;

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

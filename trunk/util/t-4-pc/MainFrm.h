//=============================================================================
// T^4 PC Terminal
//=============================================================================
// MainFrm.h
// Declara la clase CMainFrame, encargada de representar la ventana principal.
//-----------------------------------------------------------------------------
// Desarrollado por Mariano Beiró y Mariano Chouza para Laboratorio de
// Microcomputadoras.
//-----------------------------------------------------------------------------
// Desarrollo comenzado el 26/11/2007
//=============================================================================

#pragma once

#include "ChildView.h"

class CMainFrame : public CFrameWnd
{
public:
	// C & D
	CMainFrame();
	virtual ~CMainFrame();

protected:
	// Objeto que se encarga de dibujar en el área cliente
	CChildView    m_wndView;

	DECLARE_DYNAMIC(CMainFrame)
	
	// Overrides
	virtual BOOL PreCreateWindow(CREATESTRUCT& cs);
	virtual BOOL OnCmdMsg(UINT nID, int nCode, void* pExtra, AFX_CMDHANDLERINFO* pHandlerInfo);

	// Mapa de mensajes
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	afx_msg void OnSetFocus(CWnd *pOldWnd);
	DECLARE_MESSAGE_MAP()

	// Debugging
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif
};

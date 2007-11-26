// ChildView.cpp : implementation of the CChildView class
//

#include "stdafx.h"
#include "t-4-pc.h"
#include "ChildView.h"
#include <sstream>

#ifdef _DEBUG
#define new DEBUG_NEW
#endif


// CChildView

CChildView::CChildView()
{
}

CChildView::~CChildView()
{
}


BEGIN_MESSAGE_MAP(CChildView, CWnd)
	ON_WM_CREATE()
	ON_WM_ERASEBKGND()
	ON_WM_LBUTTONDOWN()
	ON_WM_PAINT()
	ON_WM_TIMER()
END_MESSAGE_MAP()



// CChildView message handlers

BOOL CChildView::PreCreateWindow(CREATESTRUCT& cs) 
{
	if (!CWnd::PreCreateWindow(cs))
		return FALSE;

	cs.style &= ~WS_BORDER;
	cs.lpszClass = AfxRegisterWndClass(CS_HREDRAW|CS_VREDRAW|CS_DBLCLKS, 
		::LoadCursor(NULL, IDC_ARROW), reinterpret_cast<HBRUSH>(COLOR_WINDOW+1), NULL);

	return TRUE;
}

void CChildView::OnPaint() 
{
	// Obtiene el DC para dibujar
	CPaintDC dc(this);

	// Dibuja el tablero
	board_.draw(bufferDC_);

	// Blit
	dc.BitBlt(0, 0, 300, 300, &bufferDC_, 0, 0, SRCCOPY);
}

void CChildView::OnLButtonDown(UINT nFlags, CPoint point)
{
	// Obtengo la fila y columna donde se hizo click
	unsigned row = point.y / 100;
	unsigned col = point.x / 100;
	row = (row > 2) ? 2 : row;
	col = (col > 2) ? 2 : col;

	// Obtengo el número de celda donde se hizo click
	unsigned cellNumber = row * 3 + col;

	// FIXME: SOLO PARA DEBUG
	std::ostringstream oss;
	oss << "Número de celda: " << cellNumber;
	MessageBox(oss.str().c_str());
	board_.sendCodedRow((rand() & 0x3f) | ((rand() % 3) << 6));
}

int CChildView::OnCreate(LPCREATESTRUCT lpCreateStruct)
{
	// Creo el bitmap para el buffer
	bufferBM_.CreateCompatibleBitmap(GetDC(), 300, 300);

	// Creo el DC para el buffer
	bufferDC_.CreateCompatibleDC(GetDC());

	// Selecciono el bitmap del buffer en su correspondiente DC
	bufferDC_.SelectObject(bufferBM_);
	
	// Agrego un timer de actualización
	SetTimer(1, 50, NULL);

	// Le paso el evento a CWnd
	return CWnd::OnCreate(lpCreateStruct);
}

void CChildView::OnTimer(UINT_PTR nIDEvent)
{
	// Notifico al tablero
	board_.timeStep();

	// Redibujo
	RedrawWindow();
}

BOOL CChildView::OnEraseBkgnd(CDC *pDC)
{
	// Intencionalmente no hago nada
	return TRUE;
}
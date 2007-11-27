//=============================================================================
// T^4 PC Terminal
//=============================================================================
// ChildView.cpp
// Implementa la clase CChildView, encargada de mostrar los gráficos.
//-----------------------------------------------------------------------------
// Desarrollado por Mariano Beiró y Mariano Chouza para Laboratorio de
// Microcomputadoras.
//-----------------------------------------------------------------------------
// Desarrollo comenzado el 26/11/2007
//=============================================================================

#include "stdafx.h"
#include "t-4-pc.h"
#include "ChildView.h"
#include <sstream>

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

namespace
{
	// Actualiza el tablero en base a lo que lea del puerto serie
	void updateBoardFromSerialPort(T4Board& b, SerialPort& sp)
	{
		using std::vector;

		// Leo desde el puerto serie
		vector<unsigned char> v = sp.read();

		// Envío hacia el tablero
		for (size_t i = 0; i < v.size(); i++)
			b.sendCodedRow(v[i]);
	}
}

CChildView::CChildView() :
config_(parseINIFile("config.ini")),
board_(config_["Board"]),
serialPort_(config_["SerialPort"])
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
	unsigned char cellNumber = row * 3 + col;

	// Envío al puerto serie
	serialPort_.write(&cellNumber, 1);
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
	// Obtengo datos desde el puerto serie y los utilizo para actualziar el
	// tablero
	updateBoardFromSerialPort(board_, serialPort_);
	
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

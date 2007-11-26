//=============================================================================
// T^4 PC Terminal
//=============================================================================
// t-4-pc.h
// Declara la clase CT4PCApp, encargada de representar la aplicación.
//-----------------------------------------------------------------------------
// Desarrollado por Mariano Beiró y Mariano Chouza para Laboratorio de
// Microcomputadoras.
//-----------------------------------------------------------------------------
// Desarrollo comenzado el 26/11/2007
//=============================================================================

#pragma once

#ifndef __AFXWIN_H__
	#error "include 'stdafx.h' before including this file for PCH"
#endif

#include "resource.h"

// Clase de la aplicación
class CT4PCApp : public CWinApp
{
public:
	// Constructor
	CT4PCApp();

	// Overrides
	virtual BOOL InitInstance();
	
	// Mapa de mensajes
	afx_msg void OnAppAbout();
	DECLARE_MESSAGE_MAP()
};

// Permite acceder a la aplicación
extern CT4PCApp theApp;

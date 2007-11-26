// t-4-pc.h : main header file for the t-4-pc application
//
#pragma once

#ifndef __AFXWIN_H__
	#error "include 'stdafx.h' before including this file for PCH"
#endif

#include "resource.h"       // main symbols


// CT4PCApp:
// See t-4-pc.cpp for the implementation of this class
//

class CT4PCApp : public CWinApp
{
public:
	CT4PCApp();


// Overrides
public:
	virtual BOOL InitInstance();

// Implementation

public:
	afx_msg void OnAppAbout();
	DECLARE_MESSAGE_MAP()
};

extern CT4PCApp theApp;
// Viewer.h : main header file for the VIEWER application
//

#if !defined(AFX_VIEWER_H__CB7F4A64_DC52_41FE_8440_5AFCBE7CBD61__INCLUDED_)
#define AFX_VIEWER_H__CB7F4A64_DC52_41FE_8440_5AFCBE7CBD61__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#ifndef __AFXWIN_H__
	#error include 'stdafx.h' before including this file for PCH
#endif

#include "resource.h"		// main symbols

/////////////////////////////////////////////////////////////////////////////
// CViewerApp:
// See Viewer.cpp for the implementation of this class
//

class CViewerApp : public CWinApp
{
public:
	CViewerApp();

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CViewerApp)
	public:
	virtual BOOL InitInstance();
	//}}AFX_VIRTUAL

// Implementation

	//{{AFX_MSG(CViewerApp)
		// NOTE - the ClassWizard will add and remove member functions here.
		//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};


/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_VIEWER_H__CB7F4A64_DC52_41FE_8440_5AFCBE7CBD61__INCLUDED_)

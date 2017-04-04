// ViewerDlg.h : header file
//

#if !defined(AFX_VIEWERDLG_H__B7E503A8_329D_4433_A781_8F6C624A2377__INCLUDED_)
#define AFX_VIEWERDLG_H__B7E503A8_329D_4433_A781_8F6C624A2377__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

/////////////////////////////////////////////////////////////////////////////
// CViewerDlg dialog

class CViewerDlg : public CDialog
{
// Construction
public:
	CViewerDlg(CWnd* pParent = NULL);	// standard constructor

// Dialog Data
	//{{AFX_DATA(CViewerDlg)
	enum { IDD = IDD_VIEWER_DIALOG };
		// NOTE: the ClassWizard will add data members here
	//}}AFX_DATA

	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CViewerDlg)
	public:
	virtual BOOL PreTranslateMessage(MSG* pMsg);
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	HICON m_hIcon;

	// Generated message map functions
	//{{AFX_MSG(CViewerDlg)
	virtual BOOL OnInitDialog();
	afx_msg void OnSysCommand(UINT nID, LPARAM lParam);
	afx_msg HCURSOR OnQueryDragIcon();
	afx_msg void OnPaint();
	afx_msg void OnFSCommandView(LPCTSTR command, LPCTSTR args);
	DECLARE_EVENTSINK_MAP()
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_VIEWERDLG_H__B7E503A8_329D_4433_A781_8F6C624A2377__INCLUDED_)

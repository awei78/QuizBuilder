// ViewerDlg.cpp : implementation file
//

#include "stdafx.h"
#include "Viewer.h"
#include "ViewerDlg.h"
#include "shockwaveflash.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

BOOL FileExists(CString strFileName)
{
	CFileFind ff;	
	BOOL bExists = ff.FindFile(strFileName);
	ff.Close();
	
	return bExists;
}

/////////////////////////////////////////////////////////////////////////////
// CAboutDlg dialog used for App About

class CAboutDlg : public CDialog
{
public:
	CAboutDlg();

// Dialog Data
	//{{AFX_DATA(CAboutDlg)
	enum { IDD = IDD_ABOUTBOX };
	//}}AFX_DATA

	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CAboutDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	//{{AFX_MSG(CAboutDlg)
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

CAboutDlg::CAboutDlg() : CDialog(CAboutDlg::IDD)
{
	//{{AFX_DATA_INIT(CAboutDlg)
	//}}AFX_DATA_INIT
}

void CAboutDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CAboutDlg)
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CAboutDlg, CDialog)
	//{{AFX_MSG_MAP(CAboutDlg)
		// No message handlers
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CViewerDlg dialog

CViewerDlg::CViewerDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CViewerDlg::IDD, pParent)
{
	//{{AFX_DATA_INIT(CViewerDlg)
		// NOTE: the ClassWizard will add member initialization here
	//}}AFX_DATA_INIT
	// Note that LoadIcon does not require a subsequent DestroyIcon in Win32
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void CViewerDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CViewerDlg)
		// NOTE: the ClassWizard will add DDX and DDV calls here
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CViewerDlg, CDialog)
	//{{AFX_MSG_MAP(CViewerDlg)
	ON_WM_SYSCOMMAND()
	ON_WM_QUERYDRAGICON()
	ON_WM_PAINT()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CViewerDlg message handlers

BOOL CViewerDlg::PreTranslateMessage(MSG* pMsg) 
{
	// TODO: Add your specialized code here and/or call the base class
  if (pMsg->message == WM_KEYDOWN && (pMsg->wParam == VK_RETURN || pMsg->wParam == VK_ESCAPE)) {
    GetDlgItem(IDC_VIEW)->SendMessage(WM_KEYDOWN, pMsg->wParam, 0);
  	return TRUE;
  }   

	return CDialog::PreTranslateMessage(pMsg);
}

BOOL CViewerDlg::OnInitDialog()
{
	CDialog::OnInitDialog();

	// Add "About..." menu item to system menu.

	// IDM_ABOUTBOX must be in the system command range.
	ASSERT((IDM_ABOUTBOX & 0xFFF0) == IDM_ABOUTBOX);
	ASSERT(IDM_ABOUTBOX < 0xF000);

	CMenu* pSysMenu = GetSystemMenu(FALSE);
	if (pSysMenu != NULL)
	{
		CString strAboutMenu;
		strAboutMenu.LoadString(IDS_ABOUTBOX);
		if (!strAboutMenu.IsEmpty())
		{
			pSysMenu->AppendMenu(MF_SEPARATOR);
			pSysMenu->AppendMenu(MF_STRING, IDM_ABOUTBOX, strAboutMenu);
		}
	}

	// Set the icon for this dialog.  The framework does this automatically
	//  when the application's main window is not a dialog
	SetIcon(m_hIcon, TRUE);			// Set big icon
	SetIcon(m_hIcon, FALSE);		// Set small icon
	
	// TODO: Add extra initialization here
  //命令行传入
	CString strCmdParam = AfxGetApp()->m_lpCmdLine;	
	CString strFile = strCmdParam.Left(strCmdParam.Find("|"));
	CString strCaption = strCmdParam.Right(strCmdParam.GetLength() - strCmdParam.Find("|") - 1);
	if (!FileExists(strFile)) {
		MessageBox("此程序由试题大师的试题浏览功能所调用，不能单独运行。\n您可打开试题大师，添加试题后点击[预览]，调用此程序", "提示", MB_OK + MB_ICONINFORMATION);
    OnCancel();
	}

  RECT rc;
  ::SetRect(&rc, 0, 0, 720, 540); 
  ::AdjustWindowRect(&rc, GetStyle(), GetMenu() != NULL);
	::MoveWindow(m_hWnd, 0, 0, rc.right - rc.left, rc.bottom - rc.top, TRUE); 
	GetDlgItem(IDC_VIEW)->MoveWindow(0, 0, 720, 540, TRUE);
	//赋值...
	SetWindowText((LPCTSTR)strCaption);
  ((CShockwaveFlash*)GetDlgItem(IDC_VIEW))->SetMovie((LPCTSTR)strFile);

	return TRUE;  // return TRUE  unless you set the focus to a control
}

void CViewerDlg::OnSysCommand(UINT nID, LPARAM lParam)
{
	if ((nID & 0xFFF0) == IDM_ABOUTBOX)
	{
		CAboutDlg dlgAbout;
		dlgAbout.DoModal();
	}
	else
	{
		CDialog::OnSysCommand(nID, lParam);
	}
}

// If you add a minimize button to your dialog, you will need the code below
//  to draw the icon.  For MFC applications using the document/view model,
//  this is automatically done for you by the framework.

void CViewerDlg::OnPaint() 
{
	if (IsIconic())
	{
		CPaintDC dc(this); // device context for painting

		SendMessage(WM_ICONERASEBKGND, (WPARAM) dc.GetSafeHdc(), 0);

		// Center icon in client rectangle
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// Draw the icon
		dc.DrawIcon(x, y, m_hIcon);
	}
	else
	{
		CDialog::OnPaint();
	}
}

// The system calls this to obtain the cursor to display while the user drags
//  the minimized window.
HCURSOR CViewerDlg::OnQueryDragIcon()
{
	return (HCURSOR) m_hIcon;
}

BEGIN_EVENTSINK_MAP(CViewerDlg, CDialog)
    //{{AFX_EVENTSINK_MAP(CViewerDlg)
	ON_EVENT(CViewerDlg, IDC_VIEW, 150 /* FSCommand */, OnFSCommandView, VTS_BSTR VTS_BSTR)
	//}}AFX_EVENTSINK_MAP
END_EVENTSINK_MAP()

void CViewerDlg::OnFSCommandView(LPCTSTR command, LPCTSTR args) 
{
	// TODO: Add your control notification handler code here
	if (strcmp(command, "quit") == 0) {
    CDialog::OnOK();
	}
}

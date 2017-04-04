; CLW file contains information for the MFC ClassWizard

[General Info]
Version=1
LastClass=CViewerDlg
LastTemplate=CDialog
NewFileInclude1=#include "stdafx.h"
NewFileInclude2=#include "Viewer.h"

ClassCount=3
Class1=CViewerApp
Class2=CViewerDlg
Class3=CAboutDlg

ResourceCount=3
Resource1=IDD_ABOUTBOX
Resource2=IDR_MAINFRAME
Resource3=IDD_VIEWER_DIALOG

[CLS:CViewerApp]
Type=0
HeaderFile=Viewer.h
ImplementationFile=Viewer.cpp
Filter=N

[CLS:CViewerDlg]
Type=0
HeaderFile=ViewerDlg.h
ImplementationFile=ViewerDlg.cpp
Filter=W
BaseClass=CDialog
VirtualFilter=dWC
LastObject=IDC_VIEW

[CLS:CAboutDlg]
Type=0
HeaderFile=ViewerDlg.h
ImplementationFile=ViewerDlg.cpp
Filter=D

[DLG:IDD_ABOUTBOX]
Type=1
Class=CAboutDlg
ControlCount=4
Control1=IDC_STATIC,static,1342177283
Control2=IDC_STATIC,static,1342308480
Control3=IDC_STATIC,static,1342308352
Control4=IDOK,button,1342373889

[DLG:IDD_VIEWER_DIALOG]
Type=1
Class=CViewerDlg
ControlCount=1
Control1=IDC_VIEW,{D27CDB6E-AE6D-11CF-96B8-444553540000},1342242816


{******
  单 元：uPublish.pas
  作 者：刘景威
  日 期：2007-5-16
  说 明：发布单元
  更 新：
******}

unit uPublish;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uBase, StdCtrls, Buttons, ExtCtrls, ImgList, Quiz, Mask, RzEdit,
  RzBtnEdt, ShlObj, ActiveX, RzBckgnd, RzPanel, RzTabs, ComCtrls, ShellAPI;

type
  TfrmPublish = class(TfrmBase)
    lblPub: TLabel;
    bvlPublish: TBevel;
    ilImg: TImageList;
    pcPub: TRzPageControl;
    tsPub: TRzTabSheet;
    bvlPath: TBevel;
    bvlSp: TBevel;
    lblPath: TLabel;
    lblFile: TLabel;
    lblFolder: TLabel;
    RzSeparator1: TRzSeparator;
    RzSeparator2: TRzSeparator;
    RzSeparator3: TRzSeparator;
    rbWeb: TRadioButton;
    rbLms: TRadioButton;
    rbWord: TRadioButton;
    rbExcel: TRadioButton;
    pnlImg: TRzPanel;
    imgWeb: TImage;
    imgLms: TImage;
    imgWord: TImage;
    imgExcel: TImage;
    edtFile: TEdit;
    beFolder: TRzButtonEdit;
    tsRst: TRzTabSheet;
    bvlFinish: TBevel;
    imgQuiz: TImage;
    imgRst: TImage;
    imgArrow: TImage;
    Bevel2: TBevel;
    pnlRst: TRzPanel;
    lblOpenFile: TLabel;
    lblFilePath: TLabel;
    lblOpenFolder: TLabel;
    lblFolderPath: TLabel;
    lblSuccess: TLabel;
    RzSeparator4: TRzSeparator;
    pnlDis: TPanel;
    lblDis: TLabel;
    pbDis: TProgressBar;
    tmr: TTimer;
    pc: TPageControl;
    tsLms: TTabSheet;
    tsWord: TTabSheet;
    lblLms: TLabel;
    bvlLms: TBevel;
    rb12: TRadioButton;
    rb2004: TRadioButton;
    bvlWord: TBevel;
    lblWord: TLabel;
    cbShowAns: TCheckBox;
    RzSeparator5: TRzSeparator;
    rbExe: TRadioButton;
    imgExe: TImage;
    tsExe: TTabSheet;
    bvlExe: TBevel;
    lblExe: TLabel;
    cbShowMenu: TCheckBox;
    procedure imgWebClick(Sender: TObject);
    procedure imgLmsClick(Sender: TObject);
    procedure imgWordClick(Sender: TObject);
    procedure imgExcelClick(Sender: TObject);
    procedure RadioClick(Sender: TObject);
    procedure edtFileKeyPress(Sender: TObject; var Key: Char);
    procedure beFolderButtonClick(Sender: TObject);
    procedure tmrTimer(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure lblFilePathClick(Sender: TObject);
    procedure lblFolderPathClick(Sender: TObject);
    procedure imgExeClick(Sender: TObject);
  private
    { Private declarations }
    FPublish: TPublish;
    FPubType: TPubType;
  protected
    procedure LoadData; override;
    procedure SaveData; override;
    //检查数据
    function CheckData: Boolean; override;
  public
    { Public declarations }
  end;

var
  frmPublish: TfrmPublish;                                       

function ShowPublish(APublish: TPublish; APubType: TPubType = ptWeb): Boolean;

implementation

uses uGlobal;

{$R *.dfm}

function ShowPublish(APublish: TPublish; APubType: TPubType): Boolean;
begin
  Result := False;
  if QuizObj.QuesList.Count = 0 then
  begin
    MessageBox(Application.MainForm.Handle, PAnsiChar('工程中还没有试题；请先添加试题，然后再发布'), '提示', MB_OK + MB_ICONINFORMATION);
    Exit;
  end;

  frmPublish := TfrmPublish.Create(Application.MainForm);
  with frmPublish do
  begin
    try
      pcPub.ActivePageIndex := 0;
      pnlDis.Visible := False;
      FPublish := APublish;
      FPubType := APubType;
      LoadData();
      Result := ShowModal() = mrOk;
    finally
      Free;
    end;
  end;
end;

procedure DisProgress(ACurPos, AMaxPos: Integer); stdcall;
begin
  Application.ProcessMessages;
  with frmPublish do
  begin
    if not pnlDis.Visible then pnlDis.Visible := True;

    lblDis.Caption := '试题生成中…… ' + FormatFloat('#%', ACurPos * 100 / AMaxPos);
    pbDis.Position := Round(ACurPos * 100 / AMaxPos);
    pnlDis.Update;
  end;
end;

procedure TfrmPublish.LoadData;
begin
  case Ord(FPubType) of
    0: RadioClick(rbWeb);
    1: RadioClick(rbLms);
    2: RadioClick(rbWord);
    3: RadioClick(rbExcel);
    4: RadioClick(rbExe);
  end;

  with (FPublish) do
  begin
    if Title <> '' then
      edtFile.Text := Title
    else edtFile.Text := ChangeFileExt(ExtractFileName(QuizObj.ProjPath), '');
    beFolder.Text := Folder;
    rb12.Checked := LmsVer = lv12;
    rb2004.Checked := LmsVer = lv2004;
    cbShowAns.Checked := ShowAnswer;
    cbShowMenu.Checked := ShowMenu;
  end;
end;

procedure TfrmPublish.SaveData;
begin
  with FPublish do
  begin
    if rbWeb.Checked then PubType := ptWeb;
    if rbLms.Checked then PubType := ptLms;
    if rbWord.Checked then PubType := ptWord;
    if rbExcel.Checked then PubType := ptExcel;
    if rbExe.Checked then PubType := ptExe;

    Title := edtFile.Text;
    Folder := beFolder.Text;

    if rb12.Checked then LmsVer := lv12;
    if rb2004.Checked then LmsVer := lv2004;
    ShowAnswer := cbShowAns.Checked;
    ShowMenu := cbShowMenu.Checked;

    SaveToReg();
  end;
end;

function TfrmPublish.CheckData: Boolean;
begin
  Result := False;

  if Trim(edtFile.Text) = '' then
  begin
    MessageBox(Handle, '请设定您要发布的文件名！', '提示', MB_OK + MB_ICONINFORMATION);
    edtFile.SetFocus;
    Exit;
  end;

  if not DirectoryExists(beFolder.Text) then
  begin
    MessageBox(Handle, '输出目录不存在，请设定输出目录！', '提示', MB_OK + MB_ICONINFORMATION);
    beFolder.SetFocus;
    Exit;
  end;

  Result := inherited CheckData();
end;

procedure TfrmPublish.RadioClick(Sender: TObject);
var
  Tag: Integer;
begin
  TRadioButton(Sender).Checked := True;

  Tag := TRadioButton(Sender).Tag;
  case Tag of
    0:
    begin
      HelpHtml := 'publish_web.html';
      ilImg.GetIcon(0, Icon);
    end;
    1:
    begin
      HelpHtml := 'publish_lms.html';
      ilImg.GetIcon(1, Icon);
    end;
    2:
    begin
      HelpHtml := 'publish_word.html';
      ilImg.GetIcon(2, Icon);
    end;
    3:
    begin
      HelpHtml := 'publish_excel.html';
      ilImg.GetIcon(3, Icon);
    end;
    4:
    begin
      HelpHtml := 'publish_exe.html';
      ilImg.GetIcon(4, Icon);
    end;
  end;

  pc.Visible := Tag in [1..2, 4];
  if Tag in [1..2] then
    pc.ActivePageIndex := Tag - 1
  else pc.ActivePageIndex := Tag - 2;
  imgRst.Picture := nil;
  ilImg.GetBitmap(Tag + 5, imgRst.Picture.Bitmap);
end;

procedure TfrmPublish.imgWebClick(Sender: TObject);
begin
  rbWeb.SetFocus();
end;

procedure TfrmPublish.imgLmsClick(Sender: TObject);
begin
  rbLms.SetFocus();
end;

procedure TfrmPublish.imgWordClick(Sender: TObject);
begin
  rbWord.SetFocus();
end;

procedure TfrmPublish.imgExcelClick(Sender: TObject);
begin
  rbExcel.SetFocus();
end;

procedure TfrmPublish.imgExeClick(Sender: TObject);
begin
  rbExe.SetFocus();
end;

procedure TfrmPublish.edtFileKeyPress(Sender: TObject; var Key: Char);
begin
  if Key in ['\', '/', ':', '*', '?', '"', '<', '>', '|'] then Key := #0;
end;

procedure TfrmPublish.beFolderButtonClick(Sender: TObject);
var
  sDir: string;
begin
  if SelectDirectory(Handle, '请选择您想要发布到的文件夹：', beFolder.Text, sDir) then
    beFolder.Text := sDir;
end;

procedure TfrmPublish.tmrTimer(Sender: TObject);
begin
  tmr.Enabled := False;
  pnlDis.Visible := False;
end;

procedure TfrmPublish.btnOKClick(Sender: TObject);
var
  sFile: string;
begin
  if btnOk.Caption = '发布' then
  begin
    if not CheckData() then Exit;

    SaveData();
    case FPublish.PubType of
      ptWeb: sFile := FPublish.Folder + FPublish.Title + '.swf';
      ptLms: sFile := FPublish.Folder + FPublish.Title + '.zip';
      ptWord: sFile := FPublish.Folder + FPublish.Title + '.doc';
      ptExcel: sFile := FPublish.Folder + FPublish.Title + '.xls';
      ptExe: sFile := FPublish.Folder + FPublish.Title + '.exe';
    else
      sFile := FPublish.Folder + FPublish.Title + '.swf';
    end;
    if FileExists(sFile) and (MessageBox(Handle, PAnsiChar('输出文件[' + ExtractFileName(sFile) + ']已存在，要替换吗？'), '提示', MB_YESNO + MB_ICONQUESTION) = ID_NO) then Exit;

    pcPub.ActivePage.Enabled := False;
    btnOk.Enabled := False;
    btnCancel.SetFocus;
    pnlDis.Visible := True;
    Screen.Cursor := crHourGlass;
    FPublish.DisProgress := DisProgress;
    FPublish.Handle := Handle;
    if FPublish.Execute then
    begin
      if FPublish.PubType = ptWeb then sFile := FPublish.Folder + FPublish.Title + '.html';
      btnOk.Enabled := True;
      btnOk.Caption := '上一步';
      lblPub.Caption := '完成发布';
      btnCancel.Caption := '关闭';
      lblFilePath.Caption := sFile;
      lblFolderPath.Caption := FPublish.Folder;
      pcPub.ActivePageIndex := 1;

      lblOpenFolder.Top := lblFilePath.Top + lblFilePath.Height + 7;
    end
    else btnCancelClick(btnCancel);
    Screen.Cursor := crDefault;
  end
  else
  begin
    btnOk.Caption := '发布';
    btnOk.SetFocus;
    pnlDis.Visible := False;
    pcPub.ActivePageIndex := 0;
    pcPub.ActivePage.Enabled := True;
    lblPub.Caption := '试题发布';
    btnCancel.Caption := '取消';
  end;
end;

procedure TfrmPublish.btnCancelClick(Sender: TObject);
var
  sFile: string;
begin
  if (pcPub.ActivePageIndex = 0) and not btnOk.Enabled then
  begin
    FPublish.DoCancel;

    Screen.Cursor := crDefault;
    pcPub.ActivePage.Enabled := True;
    tmr.Enabled := True;
    pnlDis.Update;
    btnOk.Enabled := True;
    Update;

    case FPublish.PubType of
      ptWeb: sFile := FPublish.Folder + FPublish.Title + '.swf';
      ptLms: sFile := FPublish.Folder + FPublish.Title + '.zip';
      ptWord: sFile := FPublish.Folder + FPublish.Title + '.doc';
      ptExcel: sFile := FPublish.Folder + FPublish.Title + '.xls';
      ptExe: sFile := FPublish.Folder + FPublish.Title + '.exe';
    else
      sFile := FPublish.Folder + FPublish.Title + '.swf';
    end;
    if (FPublish.PubType = ptWeb) and FileExists(ChangeFileExt(sFile, '.html')) then DeleteFile(ChangeFileExt(sFile, '.html'));
    if FileExists(sFile) then DeleteFile(sFile);
  end
  else inherited;
end;

procedure TfrmPublish.lblFilePathClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', PAnsiChar(lblFilePath.Caption), nil, nil, SW_SHOW);
end;

procedure TfrmPublish.lblFolderPathClick(Sender: TObject);
begin
  if FileExists(lblFilePath.Caption) then
    WinExec(PAnsiChar('explorer /select, ' + lblFilePath.Caption), SW_SHOW)
  else WinExec(PAnsiChar('explorer ' + lblFolderPath.Caption), SW_SHOW)
end;

end.

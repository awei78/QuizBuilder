unit uBase;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, Registry;

type
  TfrmBase = class(TForm)
    btnOK: TBitBtn;
    btnReset: TBitBtn;
    btnCancel: TBitBtn;
    bvl: TBevel;
    imgHelp: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure btnOKClick(Sender: TObject);
    procedure btnResetClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure imgHelpClick(Sender: TObject);
  private
    { Private declarations }
    //提示框窗体可闪标题栏
    procedure WMSetCursor(var Msg: TWMSetCursor); message WM_SETCURSOR;
  protected
    //数据操作过程
    procedure InitData; virtual;
    procedure LoadData; virtual;
    procedure SaveData; virtual;
    procedure ResetData; virtual;
    //检查数据
    function CheckData: Boolean; virtual;  
  public
    { Public declarations }
    HelpHtml: string;
  end;

var
  frmBase: TfrmBase;

implementation

uses uGlobal, Quiz;

{$R *.dfm}

{ TfrmBase }

procedure TfrmBase.WMSetCursor(var Msg: TWMSetCursor);
begin
  if (SmallInt(Msg.HitTest) = HTERROR) and (Msg.MouseMsg = WM_LBUTTONDOWN) then
    DefaultHandler(Msg)
  else inherited;
end;

procedure TfrmBase.InitData;
begin
  //
end;

procedure TfrmBase.LoadData;
begin
  //
end;

procedure TfrmBase.SaveData;
begin
  //
end;

procedure TfrmBase.ResetData;
begin
  //
end;

function TfrmBase.CheckData: Boolean;
begin
  Result := True;
end;

procedure TfrmBase.FormCreate(Sender: TObject);
var
  reg: TRegistry;
begin
  if App.RegType = rtTrial then
  begin
    reg := TRegistry.Create;
    try
      reg.RootKey := HKEY_CURRENT_USER;
      reg.OpenKey(QUIZ_KEY_NAME, False);
      if reg.ValueExists('RegMail') then reg.DeleteValue('RegMail');
      if reg.ValueExists('RegCode') then reg.DeleteValue('RegCode');
    finally
      reg.Free;
    end;
  end;
end;

procedure TfrmBase.FormShortCut(var Msg: TWMKey; var Handled: Boolean);
begin
  case Msg.CharCode of
    VK_F1: imgHelp.OnClick(imgHelp);
    VK_ESCAPE:
      if fsModal in FormState then ModalResult := mrCancel;
  end;
end;

procedure TfrmBase.btnOKClick(Sender: TObject);
begin
  if CheckData() then
  begin
    ModalResult := mrOk;
    SaveData();
  end;
end;

procedure TfrmBase.btnResetClick(Sender: TObject);
begin
  ResetData();
end;

procedure TfrmBase.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmBase.imgHelpClick(Sender: TObject);
begin
  if HelpHtml <> '' then HtmlHelp(Application.Handle, App.Path + 'help.chm::/' + HelpHtml, HH_DISPLAY_TOPIC, 0);
end;

end.

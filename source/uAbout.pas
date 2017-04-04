unit uAbout;

interface

uses Windows, Messages, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, RzBckgnd;

type
  TfrmAbout = class(TForm)
    pnlAbout: TPanel;
    imgIcon: TImage;
    lblPro: TLabel;
    lblVer: TLabel;
    lblRight: TLabel;
    btnOk: TButton;
    rsTop: TRzSeparator;
    rsBottom: TRzSeparator;
    lblInfo: TLabel;
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmAbout: TfrmAbout;

function ShowAbout(): Boolean;

implementation

uses uGlobal;

{$R *.dfm}

function ShowAbout(): Boolean;
begin
  with TfrmAbout.Create(Application.MainForm) do
  begin
    try
      imgIcon.Picture.Icon := Application.Icon;
      lblPro.Caption := lblPro.Caption + ' ' + App.Caption;
      lblVer.Caption := lblVer.Caption + ' ' + App.Version;
      lblInfo.AutoSize := False;
      if App.RegType = rtNone then
      begin
        lblInfo.Alignment := taCenter;
        lblInfo.Left := 16;
        lblInfo.Width := pnlAbout.Width - 32;
        lblInfo.Font.Color := clGreen;
        lblInfo.Caption := '������ע�����' + App.RegMail;
      end
      else
      begin
        lblInfo.Left := 72;
        lblInfo.Font.Color := clMaroon;
        if App.RegType = rtTrial then
          lblInfo.Caption := '���ð汾'
        else lblInfo.Caption := 'δע��汾';
      end;

      Result := ShowModal() = mrOk;
    finally
      Free;
    end;
  end;
end;

procedure TfrmAbout.FormShortCut(var Msg: TWMKey; var Handled: Boolean);
begin
  if (Msg.CharCode = VK_ESCAPE) and (fsModal in FormState) then ModalResult := mrCancel;
end;

end.
 

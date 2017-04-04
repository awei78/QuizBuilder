unit uReg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uBase, StdCtrls, Buttons, ExtCtrls, ShellAPI;

type
  TfrmReg = class(TfrmBase)
    lblMail: TLabel;
    lblCode: TLabel;
    edtMail: TEdit;
    edtCode: TEdit;
    lblDesc: TLabel;
    imgReg: TImage;
  private
    { Private declarations }
  protected
    procedure SaveData; override;
    //检查数据
    function CheckData: Boolean; override;
  public
    { Public declarations }
  end;

var
  frmReg: TfrmReg;

function ShowReg(): Boolean;

implementation

uses Quiz, uGlobal, uMain;

{$R *.dfm}

function ShowReg(): Boolean;
begin
  with TfrmReg.Create(Application.MainForm) do
  begin
    try
      imgHelp.Visible := False;
      Result := ShowModal() = mrOk;
    finally
      Free;
    end;
  end;
end;

{ TfrmReg }

function TfrmReg.CheckData: Boolean;
var
  t1, t2: Cardinal;
begin
  Result := False;
  t1 := GetTickCount();
  if (Pos('@', edtMail.Text) < 2) or (Pos('.', edtMail.Text) < 4) then
  begin
    MessageBox(Handle, '邮件地址不正确，请重新输入', '提示', MB_OK + MB_ICONINFORMATION);
    edtMail.SetFocus;
    Exit;
  end;
  if Trim(edtCode.Text) = '' then
  begin
    MessageBox(Handle, '请输入注册码', '提示', MB_OK + MB_ICONINFORMATION);
    edtMail.SetFocus;
    Exit;
  end;

  t2 := GetTickCount();
  if t2 - t1 >= 500 then Exit;

  if not CheckRegCode(edtMail.Text, edtCode.Text) then
  begin
    MessageBox(Handle, '您输入的邮件与注册码不正确，请重新输入', '提示', MB_OK + MB_ICONWARNING);
    edtMail.SetFocus;
    Exit;
  end
  else
  begin
    frmMain.actReg.Visible := False;
    frmMain.Caption := StringReplace(frmMain.Caption, '(未注册版)', '', []);
    with QuizObj.Player.WaterMark do
    begin
      if Enabled and (Pos('秋风试题大师', Text) <> 0) then
      begin
        Enabled := False;
        Text := '';
        Link := 'http://';
      end;
    end;

    MessageBox(Handle, '注册成功，感谢您使用秋风软件', '提示', MB_OK + MB_ICONINFORMATION);
    ShellExecute(Handle, 'open', PAnsiChar('http://www.awindsoft.net/reg.asp?act=reg&pid=0&mail='
      + edtMail.Text + '&code=' + edtCode.Text + '&ver=' + App.Version), nil, nil, SW_NORMAL);
    Result := inherited CheckData;
  end;
end;

procedure TfrmReg.SaveData;
begin
  App.RegMail := edtMail.Text;
  App.RegCode := edtCode.Text;
  App.SaveToReg;
end;

end.

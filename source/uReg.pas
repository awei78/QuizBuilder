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
    //�������
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
    MessageBox(Handle, '�ʼ���ַ����ȷ������������', '��ʾ', MB_OK + MB_ICONINFORMATION);
    edtMail.SetFocus;
    Exit;
  end;
  if Trim(edtCode.Text) = '' then
  begin
    MessageBox(Handle, '������ע����', '��ʾ', MB_OK + MB_ICONINFORMATION);
    edtMail.SetFocus;
    Exit;
  end;

  t2 := GetTickCount();
  if t2 - t1 >= 500 then Exit;

  if not CheckRegCode(edtMail.Text, edtCode.Text) then
  begin
    MessageBox(Handle, '��������ʼ���ע���벻��ȷ������������', '��ʾ', MB_OK + MB_ICONWARNING);
    edtMail.SetFocus;
    Exit;
  end
  else
  begin
    frmMain.actReg.Visible := False;
    frmMain.Caption := StringReplace(frmMain.Caption, '(δע���)', '', []);
    with QuizObj.Player.WaterMark do
    begin
      if Enabled and (Pos('��������ʦ', Text) <> 0) then
      begin
        Enabled := False;
        Text := '';
        Link := 'http://';
      end;
    end;

    MessageBox(Handle, 'ע��ɹ�����л��ʹ��������', '��ʾ', MB_OK + MB_ICONINFORMATION);
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

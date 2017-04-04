{******
  单 元：uParam.pas
  作 者：刘景威
  日 期：2007-6.1
  说 明：参数设置单元
  更 新：
******}

unit uParam;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uBase, StdCtrls, Buttons, ExtCtrls, ComCtrls, CtrlsEx, Quiz;

type
  TfrmParam = class(TfrmBase)
    Bevel7: TBevel;
    lblFont: TLabel;
    lblSizeT: TLabel;
    edtSizeT: TEdit;
    udT: TUpDown;
    lblColorT: TLabel;
    cbTopic: TColorBox;
    lblTopicF: TLabel;
    lblSizeA: TLabel;
    edtSizeA: TEdit;
    udA: TUpDown;
    lblColorA: TLabel;
    cbAnswer: TColorBox;
    lblAnsF: TLabel;
    Bevel1: TBevel;
    lblDefSet: TLabel;
    lblPoint: TLabel;
    edtPoint: TEdit;
    udPoint: TUpDown;
    lblTimes: TLabel;
    edtAttempts: TEdit;
    udAttempts: TUpDown;
    lblFeed: TLabel;
    lblCrt: TLabel;
    meoCrt: TMemo;
    Bevel2: TBevel;
    lblErr: TLabel;
    meoErr: TMemo;
    lblLevel: TLabel;
    cbLevel: TComboBox;
    Bevel3: TBevel;
    lblSet: TLabel;
    cbSplash: TCheckBox;
    btnApplayAll: TBitBtn;
    cbBoldT: TCheckBox;
    cbBoldA: TCheckBox;
    cbShowIcon: TCheckBox;
    cbSetAudio: TCheckBox;
    procedure btnApplayAllClick(Sender: TObject);
  private
    { Private declarations }
    FQuizSet: TQuizSet;
  protected
    procedure LoadData; override;
    procedure SaveData; override;
    procedure ResetData; override;
  public
    { Public declarations }
  end;

var
  frmParam: TfrmParam;

function ShowParam(AQuizSet: TQuizSet): Boolean;

implementation

{$R *.dfm}

function ShowParam(AQuizSet: TQuizSet): Boolean;
begin
  with TfrmParam.Create(Application.MainForm) do
  begin
    try
      FQuizSet := AQuizSet;
      QuizObj.ImageList.GetIcon(6, Icon);
      LoadData();
      Result := ShowModal() = mrOk;
    finally
      Free;
    end;
  end;
end;

procedure TfrmParam.LoadData;
begin
  HelpHtml := 'param_set.html';
  with FQuizSet do
  begin
    udT.Position := FontSetT.Size;
    cbTopic.Selected := FontSetT.Color;
    cbBoldT.Checked := FontSetT.Bold;
    udA.Position := FontSetA.Size;
    cbAnswer.Selected := FontSetA.Color;
    cbBoldA.Checked := FontSetA.Bold;
    udPoint.Position := Points;
    udAttempts.Position := Attempts;
    cbLevel.ItemIndex := Ord(QuesLevel);
    meoCrt.Text := FeedInfo.CrtInfo;
    meoErr.Text := FeedInfo.ErrInfo;
    cbShowIcon.Checked := ShowIcon;
    cbSplash.Checked := ShowSplash;
    cbSetAudio.Checked := SetAudio;
  end;
  btnApplayAll.Enabled := QuizObj.QuesList.Count <> 0;
end;

procedure TfrmParam.SaveData;
begin
  with FQuizSet do
  begin
    with FontSetT do
    begin
      Size := StrToInt(edtSizeT.Text);
      Color := cbTopic.Selected;
      Bold := cbBoldT.Checked;
    end;
    with FontSetA do
    begin
      Size := StrToInt(edtSizeA.Text);
      Color := cbAnswer.Selected;
      Bold := cbBoldA.Checked;
    end;
    Points := StrToInt(edtPoint.Text);
    Attempts := StrToInt(edtAttempts.Text);
    QuesLevel := TQuesLevel(cbLevel.ItemIndex);
    with FeedInfo do
    begin
      CrtInfo := meoCrt.Text;
      ErrInfo := meoErr.Text;
    end;
    ShowIcon := cbShowIcon.Checked;
    ShowSplash := cbSplash.Checked;
    SetAudio := cbSetAudio.Checked;

    SaveToReg();
  end;
end;

procedure TfrmParam.ResetData;
begin
  udT.Position := 12;
  cbTopic.Selected := clBlack;
  cbBoldT.Checked := False;
  udA.Position := 12;
  cbAnswer.Selected := clBlack;
  cbBoldA.Checked := False;
  udPoint.Position := 10;
  udAttempts.Position := 0;
  cbLevel.ItemIndex := 2;
  meoCrt.Text := '恭喜您，答对了';
  meoErr.Text := '您答错了';
  cbShowIcon.Checked := True;
  cbSplash.Checked := True;
  cbSetAudio.Checked := False;
end;

procedure TfrmParam.btnApplayAllClick(Sender: TObject);
var
  i: Integer;
  fi: TFeedInfo;
begin
  if MessageBox(Handle, '您确定应用反馈信息到每个试题吗？', '提示', MB_YESNO + MB_ICONQUESTION) = ID_NO then Exit;

  for i := 0 to QuizObj.QuesList.Count - 1 do
  begin
    fi.CrtInfo := meoCrt.Text;
    fi.ErrInfo := meoErr.Text;
    QuizObj.QuesList.Items[i].FeedInfo := fi;
  end;
  PostMessage(QuizObj.Handle, WM_QUIZCHANGE, QUIZ_CHANGED, 0);
end;

end.

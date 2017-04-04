{******
  单 元：uProp.pas
  作 者：刘景威                                                                                               
  日 期：2007-5-16
  说 明：试题属性设置单元
  更 新：
******}

unit uProp;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uBase, StdCtrls, Buttons, ExtCtrls, CtrlsEx, Quiz, ComCtrls, RzButton,
  RzRadChk, DateUtils, ExtDlgs, OleCtrls;

type
  TfrmProp = class(TfrmBase)
    pcProp: TPageControl;
    tsInfo: TTabSheet;
    tsResult: TTabSheet;
    lblTitle: TLabel;
    Bevel11: TBevel;
    lblTopic: TLabel;
    edtTopic: TEdit;
    lblId: TLabel;
    edtId: TEdit;
    Bevel1: TBevel;
    cbInfo: TRzCheckBox;
    lblInfo: TLabel;
    meoInfo: TMemo;
    pnlImg: TPanel;
    imgQuiz: TImage;
    lblImg: TLabel;
    btnAdd: TSpeedButton;
    btnDel: TSpeedButton;
    lblUser: TLabel;
    cbName: TCheckBox;
    cbMail: TCheckBox;
    cbBlankName: TCheckBox;
    Bevel2: TBevel;
    tsSet: TTabSheet;
    cbShow: TRzCheckBox;
    Bevel3: TBevel;
    meoPass: TMemo;
    lblPass: TLabel;
    lblFail: TLabel;
    meoFail: TMemo;
    Bevel4: TBevel;
    cbPostWeb: TRzCheckBox;
    lblUrl: TLabel;
    edtUrl: TEdit;
    pnlWeb: TPanel;
    rbWebM: TRadioButton;
    rbWebA: TRadioButton;
    Bevel5: TBevel;
    cbPostMail: TRzCheckBox;
    lblMail: TLabel;
    edtMail: TEdit;
    pnlMail: TPanel;
    rbMailM: TRadioButton;
    rbMailA: TRadioButton;
    lblMailUrl: TLabel;
    edtMailUrl: TEdit;
    Bevel6: TBevel;
    lblFilnish: TLabel;
    lblOnPass: TLabel;
    lblOnFail: TLabel;
    cbPass: TComboBox;
    cbFail: TComboBox;
    edtPUrl: TEdit;
    edtFUrl: TEdit;
    Bevel7: TBevel;
    lblAnsMode: TLabel;
    pnlAns: TPanel;
    rbOne: TRadioButton;
    rbAll: TRadioButton;
    lblPassTime: TLabel;
    Bevel8: TBevel;
    lblPassSet: TLabel;
    edtPass: TEdit;
    udPassRate: TUpDown;
    lblPer: TLabel;
    cbTime: TCheckBox;
    edtMinute: TEdit;
    lblMinute: TLabel;
    edtSecond: TEdit;
    lblSec: TLabel;
    lblOthers: TLabel;
    Bevel10: TBevel;
    cbQuesNo: TCheckBox;
    cbRndAns: TCheckBox;
    cbRndQues: TRzCheckBox;
    cbShowAns: TCheckBox;
    tsProtect: TTabSheet;
    cbPwd: TRzCheckBox;
    Bevel9: TBevel;
    pnlPwd: TPanel;
    rbPwd: TRadioButton;
    rbWeb: TRadioButton;
    edtPwd: TEdit;
    edtWeb: TEdit;
    Bevel12: TBevel;
    Bevel13: TBevel;
    cbWebLimit: TRzCheckBox;
    lblLimitUrl: TLabel;
    edtLimitUrl: TEdit;
    Bevel14: TBevel;
    cbTerm: TRzCheckBox;
    dtStart: TDateTimePicker;
    lblStart: TLabel;
    dtEnd: TDateTimePicker;
    lblEnd: TLabel;
    odQuiz: TOpenDialog;
    cbView: TCheckBox;
    cbAllow: TRzCheckBox;
    pnlRnd: TPanel;
    cbQuesCount: TComboBox;
    cbRunRnd: TCheckBox;
    rbQuiz: TRadioButton;
    rbType: TRadioButton;
    btnSet: TButton;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnOKClick(Sender: TObject);
    procedure cbInfoClick(Sender: TObject);
    procedure imgQuizDblClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnDelClick(Sender: TObject);
    procedure cbNameClick(Sender: TObject);
    procedure cbTimeClick(Sender: TObject);
    procedure cbPwdClick(Sender: TObject);
    procedure rbPwdClick(Sender: TObject);
    procedure rbWebClick(Sender: TObject);
    procedure cbRndQuesClick(Sender: TObject);
    procedure cbShowClick(Sender: TObject);
    procedure cbPostWebClick(Sender: TObject);
    procedure cbPostMailClick(Sender: TObject);
    procedure cbPassChange(Sender: TObject);
    procedure cbFailChange(Sender: TObject);
    procedure cbWebLimitClick(Sender: TObject);
    procedure cbTermClick(Sender: TObject);
    procedure dtStartChange(Sender: TObject);
    procedure dtEndChange(Sender: TObject);
    procedure dtStartCloseUp(Sender: TObject);
    procedure dtEndCloseUp(Sender: TObject);
    procedure pcPropChange(Sender: TObject);
    procedure rbQuizClick(Sender: TObject);
    procedure rbTypeClick(Sender: TObject);
    procedure btnSetClick(Sender: TObject);
  private
    { Private declarations }
    FQuizProp: TQuizProp;
    //解决与xp效果冲突的方法
    procedure SetRzCbxTrans;
  protected
    procedure LoadData; override;
    procedure SaveData; override;
    procedure ResetData; override;
    //数据检测
    function CheckData: Boolean; override;
  public
    { Public declarations }
  published
    procedure EditKeyPress(Sender: TObject; var Key: Char);
  end;

var
  frmProp: TfrmProp;

function ShowProp(AQuizProp: TQuizProp): Boolean;

implementation

uses uGlobal, uByType;

{$R *.dfm}

function ShowProp(AQuizProp: TQuizProp): Boolean;
begin
  with TfrmProp.Create(Application.MainForm) do
  begin
    try
      FQuizProp := AQuizProp;
      QuizObj.ImageList.GetIcon(4, Icon);
      LoadData();
      Result := ShowModal() = mrOk;
    finally
      Free;
    end;
  end;
end;

procedure TfrmProp.LoadData;
var
  i: Integer;
begin
  with FQuizProp do
  begin
    //试题信息
    edtTopic.Text := QuizTopic;
    edtId.Text := QuizId;
    cbInfo.Checked := ShowInfo;
    meoInfo.Text := QuizInfo;
    if FileExists(QuizImage) then imgQuiz.Image := QuizImage;
    cbName.Checked := ShowName;
    cbMail.Checked := ShowMail;
    cbBlankName.Checked := BlankName;
    //试题设置
    rbOne.Checked := SubmitType = stOnce;
    rbAll.Checked := SubmitType = stAll;
    udPassRate.Position := PassRate;
    cbTime.Checked := TimeSet.Enabled;
    edtMinute.Text := IntToStr(TimeSet.Minutes);
    edtSecond.Text := IntToStr(TimeSet.Seconds);
    cbRndQues.Checked := RndQues.Enabled;
    rbQuiz.Checked := RndQues.RndType = rtQuiz;
    rbType.Checked := RndQues.RndType = rtType;
    cbRndQues.OnClick(cbRndQues);
    //填充试题数量
    cbQuesCount.Clear;
    cbQuesCount.Items.Append('全部');
    for i := 0 to QuizObj.QuesList.Count - QuizObj.GetQuesCount(qtScene) - 1 do
      cbQuesCount.Items.Append(IntToStr(i + 1));
    if RndQues.Count = 0 then
      cbQuesCount.ItemIndex := 0
    else cbQuesCount.ItemIndex := cbQuesCount.Items.IndexOf(IntToStr(RndQues.Count));
    cbRunRnd.Checked := RndQues.RunTime;
    cbQuesNo.Checked := ShowQuesNo;
    cbRndAns.Checked := RndAnswer;
    cbShowAns.Checked := ShowAnswer;
    cbView.Checked := ViewQuiz;
    //结果设置
    cbShow.Checked := PassSet.Enabled;
    meoPass.Text := PassSet.PassInfo;
    meoFail.Text := PassSet.FailInfo;
    //Post...
    cbPostWeb.Checked := PostSet.Enabled;
    edtUrl.Text := PostSet.Url;
    rbWebM.Checked := PostSet._Type = ptManual;
    rbWebA.Checked := PostSet._Type = ptAuto;
    //Mail...
    cbPostMail.Checked := MailSet.Enabled;
    cbPostMail.OnClick(cbPostMail);
    edtMail.Text := MailSet.MailAddr;
    rbMailM.Checked := MailSet._Type = ptManual;
    rbMailA.Checked := MailSet._Type = ptAuto;
    edtMailUrl.Text := MailSet.MailUrl;
    cbPass.ItemIndex := Ord(QuitOper.PassType);
    cbPass.OnChange(cbPass);
    edtPUrl.Text := QuitOper.PassUrl;
    cbFail.ItemIndex := Ord(QuitOper.FailType);
    cbFail.OnChange(cbFail);
    edtFUrl.Text := QuitOper.FailUrl;
    //试题保护
    cbPwd.Checked := PwdSet.Enabled;
    cbPwd.OnClick(cbPwd);
    rbPwd.Checked := PwdSet._Type = pstPwd;
    if rbPwd.Checked then rbPwd.OnClick(rbPwd);
    edtPwd.Text := PwdSet.Password;
    rbWeb.Checked := PwdSet._Type = pstWeb;
    if rbWeb.Checked then rbWeb.OnClick(rbWeb);
    edtWeb.Text := PwdSet.Url;
    cbAllow.Checked := PwdSet.AllowChangeUserId;
    cbWebLimit.Checked := UrlLimit.Enabled;
    cbWebLimit.OnClick(cbWebLimit);
    edtLimitUrl.Text := UrlLimit.Url;
    cbTerm.Checked := DateLimit.Enabled;
    cbTerm.OnClick(cbTerm);
    dtStart.Date := DateLimit.StartDate;
    dtEnd.Date := DateLimit.EndDate;
  end;

  SetRzCbxTrans;
  pcProp.ActivePageIndex := 0;
end;

procedure TfrmProp.SaveData;
begin
  with FQuizProp do
  begin
    //试题信息
    QuizTopic := edtTopic.Text;
    QuizId := edtId.Text;
    QuizImage := imgQuiz.Image;
    ShowInfo := cbInfo.Checked;
    QuizInfo := meoInfo.Text;
    ShowName := cbName.Checked;
    ShowMail := cbMail.Checked;
    BlankName := cbBlankName.Checked;
    //试题设置
    if rbOne.Checked then
      SubmitType := stOnce
    else SubmitType := stAll;
    PassRate := udPassRate.Position;
    with TimeSet do
    begin
      Enabled := cbTime.Checked;
      Minutes := StrToInt(edtMinute.Text);
      Seconds := StrToInt(edtSecond.Text);
    end;
    with RndQues do
    begin
      Enabled := cbRndQues.Checked;
      if rbQuiz.Checked then
        RndType := rtQuiz
      else RndType := rtType;
      Count := cbQuesCount.ItemIndex;
      RunTime := cbRunRnd.Checked;
    end;
    ShowQuesNo := cbQuesNo.Checked;
    RndAnswer := cbRndAns.Checked;
    ShowAnswer := cbShowAns.Checked;
    ViewQuiz := cbView.Checked;
    //结果设置
    with PassSet do
    begin
      Enabled := cbShow.Checked;
      PassInfo := meoPass.Text;
      FailInfo := meoFail.Text;
    end;
    with PostSet do
    begin
      Enabled := cbPostWeb.Checked;
      Url := edtUrl.Text;
      if rbWebM.Checked then
        _Type := ptManual
      else _Type := ptAuto;
    end;
    with MailSet do
    begin
      Enabled := cbPostMail.Checked;
      MailAddr := edtMail.Text;
      if rbMailM.Checked then
        _Type := ptmanual
      else _Type := ptAuto;
      MailUrl := edtMailUrl.Text;
    end;
    with QuitOper do
    begin
      PassType := TQuitType(cbPass.ItemIndex);
      PassUrl := edtPUrl.Text;
      FailType := TQuitType(cbFail.ItemIndex);
      FailUrl := edtFUrl.Text;
    end;
    //保护设置
    with PwdSet do
    begin
      Enabled := cbPwd.Checked;
      if rbPwd.Checked then
        _Type := pstPwd
      else _Type := pstWeb;
      Password := edtPwd.Text;
      Url := edtWeb.Text;
      AllowChangeUserId := cbAllow.Checked;
    end;
    with UrlLimit do
    begin
      Enabled := cbWebLimit.Checked;
      Url := edtLimitUrl.Text;
    end;
    with DateLimit do
    begin
      Enabled := cbTerm.Checked;
      StartDate := dtStart.Date;
      EndDate := dtEnd.Date;
    end;

    SaveToReg();
  end;

  PostMessage(QuizObj.Handle, WM_QUIZCHANGE, QUIZ_CHANGED, 0);
end;

procedure TfrmProp.ResetData;
begin
  case pcProp.ActivePageIndex of
    0: //试题信息
    begin
      edtTopic.Text := '未命名';
      edtId.Text := '';
      cbInfo.Checked := True;
      meoInfo.Text := '';
      imgQuiz.Picture := nil;
      cbName.Checked := True;
      cbMail.Checked := True;
      cbBlankName.Checked := True;
    end;
    1: //试题设置
    begin
      rbOne.Checked := True;
      udPassRate.Position := 60;
      cbTime.Checked := True;
      edtMinute.Text := '5';
      edtSecond.Text := '0';
      cbRndQues.Checked := False;
      rbQuiz.Checked := True;
      cbRndQues.OnClick(cbRndQues);
      cbQuesCount.ItemIndex := 0;
      cbRunRnd.Checked := False;
      cbQuesNo.Checked := True;
      cbRndAns.Checked := True;
      cbShowAns.Checked := True;
      cbView.Checked := True;
    end;
    2: //结果设置
    begin
      cbShow.Checked := True;
      meoPass.Text := '恭喜，您通过了';
      meoFail.Text := '您没有通过';
      cbPostWeb.Checked := True;
      edtUrl.Text := 'http://www.awindsoft.net/qms/receive.asp';
      rbWebM.Checked := True;
      cbPostMail.Checked := False;
      edtMail.Text := '@';
      rbMailM.Checked := True;
      edtMailUrl.Text := 'http://www.awindsoft.net/qms/mail.asp';
      cbPass.ItemIndex := 0;
      cbPass.OnChange(cbPass);
      edtPUrl.Text := 'http://';
      cbFail.ItemIndex := 0;
      cbFail.OnChange(cbFail);
      edtFUrl.Text := 'http://';
    end;
    3: //保护设置
    begin
      cbPwd.Checked := False;
      rbPwd.Checked := True;
      edtPwd.Text := '';
      edtWeb.Text := 'http://www.awindsoft.net/qms/check.asp';
      cbAllow.Checked := False;
      cbWebLimit.Checked := False;
      edtLimitUrl.Text := 'http://';
      cbTerm.Checked := False;
      dtStart.Date := Date();
      dtEnd.Date := IncYear(Date());
    end;
  end;
end;

function TfrmProp.CheckData: Boolean;
  function IsMailAddr(const AMailAddr: string): Boolean;
  begin
    Result := (Pos('@', AMailAddr) > 1) and (Pos('.', AMailAddr) > 3);
  end;

begin
  Result := False;

  if Trim(edtTopic.Text) = '' then
  begin
    MessageBox(Handle, '试题主题不能为空，请输入主题', '提示', MB_OK + MB_ICONINFORMATION);
    pcProp.ActivePageIndex := 0;
    edtTopic.SetFocus;
    Exit;
  end;
  if cbPostMail.Checked and not IsMailAddr(Trim(edtMail.Text)) then
  begin
    MessageBox(Handle, '邮件地址错误，请输入邮件地址', '提示', MB_OK + MB_ICONINFORMATION);
    pcProp.ActivePageIndex := 2;
    edtMail.SetFocus;
    Exit;
  end;
  if cbPwd.Checked and rbPwd.Checked and (edtPwd.Text = '') then
  begin
    MessageBox(Handle, '密码不能为空，请输入保护密码', '提示', MB_OK + MB_ICONINFORMATION);
    pcProp.ActivePageIndex := 3;
    edtPwd.SetFocus;
    Exit;
  end;
  if cbWebLimit.Checked and ((edtLimitUrl.Text = '') or (edtLimitUrl.Text = 'http://')) then
  begin
    MessageBox(Handle, '限制网址格式不对，请输入限制网址', '提示', MB_OK + MB_ICONINFORMATION);
    pcProp.ActivePageIndex := 3;
    edtLimitUrl.SetFocus;
    Exit;
  end;

  Result := inherited CheckData();
end;

procedure TfrmProp.SetRzCbxTrans;
var
  i: Integer;
begin
  for i := 0 to ComponentCount - 1 do
    if Components[i] is TRzCheckBox then
      TRzCheckBox(Components[i]).Transparent := True;
end;

procedure TfrmProp.EditKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9', #8]) then Key := #0;
end;

procedure TfrmProp.FormShow(Sender: TObject);
begin
  inherited;
  //此句与下句须以此顺序写，以设定每页之焦点
  edtTopic.SetFocus;
  //写这里方能改变其下pnlPwd中Edit控件状态
  cbPwd.OnClick(cbPwd);
  pcProp.ActivePageIndex := FQuizProp.PageIndex;
  pcProp.OnChange(pcProp);
end;

procedure TfrmProp.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  if FQuizProp.PageIndex <> pcProp.ActivePageIndex then FQuizProp.PageIndex := pcProp.ActivePageIndex;
end;

procedure TfrmProp.btnOKClick(Sender: TObject);
begin
  if CheckData() then inherited;
end;

procedure TfrmProp.cbInfoClick(Sender: TObject);
var
  Enabled: Boolean;
begin
  Enabled := cbInfo.Checked;
  lblInfo.Enabled := Enabled;
  meoInfo.Enabled := Enabled;
  lblImg.Enabled := Enabled;
  pnlImg.Enabled := Enabled;
  imgQuiz.Enabled := Enabled;
  btnAdd.Enabled := Enabled;
  btnDel.Enabled := Enabled;
  lblUser.Enabled := Enabled;

  cbName.Enabled := Enabled;
  cbMail.Enabled := Enabled;
  cbBlankName.Enabled := Enabled and cbName.Checked;
end;

procedure TfrmProp.imgQuizDblClick(Sender: TObject);
begin
  btnAdd.OnClick(btnAdd);
end;

procedure TfrmProp.btnAddClick(Sender: TObject);
begin
  if odQuiz.Execute then imgQuiz.Image := odQuiz.FileName;
end;

procedure TfrmProp.btnDelClick(Sender: TObject);
begin
  imgQuiz.Image := '';
end;

procedure TfrmProp.cbNameClick(Sender: TObject);
begin
  cbBlankName.Enabled := cbName.Checked and cbInfo.Checked;
end;

procedure TfrmProp.cbTimeClick(Sender: TObject);
var
  Enabled: Boolean;
begin
  Enabled := cbTime.Checked;
  lblMinute.Enabled := Enabled;
  edtMinute.Enabled := Enabled;
  edtSecond.Enabled := Enabled;
  lblSec.Enabled := Enabled;
end;

procedure TfrmProp.cbRndQuesClick(Sender: TObject);
begin
  pnlRnd.Enabled := cbRndQues.Checked;
  rbQuiz.OnClick(rbQuiz);
  rbType.OnClick(rbType);
end;

procedure TfrmProp.rbQuizClick(Sender: TObject);
begin
  cbQuesCount.Enabled := rbQuiz.Enabled and rbQuiz.Checked;
  btnSet.Enabled := rbQuiz.Enabled and rbType.Checked;
end;

procedure TfrmProp.rbTypeClick(Sender: TObject);
begin
  rbQuiz.OnClick(rbQuiz);
end;

procedure TfrmProp.btnSetClick(Sender: TObject);
begin
  ShowByType(FQuizProp);
end;

procedure TfrmProp.cbShowClick(Sender: TObject);
var
  Enabled: Boolean;
begin
  Enabled := cbShow.Checked;
  lblPass.Enabled := Enabled;
  meoPass.Enabled := Enabled;
  lblFail.Enabled := Enabled;
  meoFail.Enabled := Enabled;
end;

procedure TfrmProp.cbPostWebClick(Sender: TObject);
var
  Enabled: Boolean;
begin
  Enabled := cbPostWeb.Checked;
  lblUrl.Enabled := Enabled;
  edtUrl.Enabled := Enabled;
  pnlWeb.Enabled := Enabled;
end;

procedure TfrmProp.cbPostMailClick(Sender: TObject);
var
  Enabled: Boolean;
begin
  Enabled := cbPostMail.Checked;
  lblMail.Enabled := Enabled;
  edtMail.Enabled := Enabled;
  pnlMail.Enabled := Enabled;
  lblMailUrl.Enabled := Enabled;
  edtMailurl.Enabled := Enabled;
end;

procedure TfrmProp.cbPassChange(Sender: TObject);
begin
  edtPUrl.Visible := cbPass.ItemIndex = 1;
end;

procedure TfrmProp.cbFailChange(Sender: TObject);
begin
  edtFUrl.Visible := cbFail.ItemIndex = 1;
end;

procedure TfrmProp.cbPwdClick(Sender: TObject);
begin
  pnlPwd.Enabled := cbPwd.Checked;

  edtPwd.Enabled := rbPwd.Checked and cbPwd.Checked;
  edtWeb.Enabled := rbWeb.Checked and cbPwd.Checked;
  cbAllow.Enabled := rbWeb.Enabled and rbWeb.Checked; 
end;

procedure TfrmProp.rbPwdClick(Sender: TObject);
begin
  edtPwd.Enabled := True;
  edtWeb.Enabled := False;
  cbAllow.Enabled := False;
end;

procedure TfrmProp.rbWebClick(Sender: TObject);
begin
  edtPwd.Enabled := False;
  edtWeb.Enabled := True;
  cbAllow.Enabled := True;
end;

procedure TfrmProp.cbWebLimitClick(Sender: TObject);
begin
  lblLimitUrl.Enabled := cbWebLimit.Checked;
  edtLimitUrl.Enabled := cbWebLimit.Checked;
end;

procedure TfrmProp.cbTermClick(Sender: TObject);
begin
  lblStart.Enabled := cbTerm.Checked;
  dtStart.Enabled := cbTerm.Checked;
  lblEnd.Enabled := cbTerm.Checked;
  dtEnd.Enabled := cbTerm.Checked;
end;

procedure TfrmProp.dtStartCloseUp(Sender: TObject);
begin
  dtStartChange(Sender);
end;

procedure TfrmProp.dtStartChange(Sender: TObject);
begin
  if dtStart.Date < Date() then dtStart.Date := Date();
  dtEndChange(dtEnd);
end;

procedure TfrmProp.dtEndCloseUp(Sender: TObject);
begin
  dtEndChange(Sender);
end;

procedure TfrmProp.dtEndChange(Sender: TObject);
begin
  if dtEnd.Date < dtStart.Date then dtEnd.Date := IncDay(dtStart.Date);
end;

procedure TfrmProp.pcPropChange(Sender: TObject);
begin
  case pcProp.ActivePageIndex of
    0: HelpHtml := 'quiz_info.html';
    1: HelpHtml := 'quiz_set.html';
    2: HelpHtml := 'quiz_result.html';
    3: HelpHtml := 'quiz_protect.html';
  end;
end;

end.


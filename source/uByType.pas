unit uByType;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uBase, Quiz, StdCtrls, Buttons, ExtCtrls;

type
  TfrmByType = class(TfrmBase)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    cbJudge: TComboBox;
    cbSingle: TComboBox;
    cbMulti: TComboBox;
    cbBlank: TComboBox;
    cbMatch: TComboBox;
    cbSeque: TComboBox;
    cbHotspot: TComboBox;
    cbEssay: TComboBox;
    lblCount: TLabel;
    procedure ComboBoxChange(Sender: TObject);
  private
    { Private declarations }
    FQuizProp: TQuizProp;
    FQuizObj: TQuizObj;
  protected
    //数据操作过程
    procedure LoadData; override;
    procedure SaveData; override;
    //检查数据
    function CheckData: Boolean; override;
    procedure FillComboBox(AComboBox: TComboBox; AQuesType: TQuesType);
    //获取设定题数
    function GetRndCount: Integer;
  public
    { Public declarations }
  end;

var
  frmByType: TfrmByType;

function ShowByType(AQuizProp: TQuizProp): Boolean;

implementation

function ShowByType(AQuizProp: TQuizProp): Boolean;
begin
  with TfrmByType.Create(Application.MainForm) do
  begin
    imgHelp.Visible := False;
    btnReset.Visible := False;
    try
      FQuizProp := AQuizProp;
      FQuizObj := QuizObj;
      LoadData();
      Result := ShowModal() = mrOk;
    finally
      Free;
    end;
  end;
end;

{$R *.dfm}

{ TfrmByType }

procedure TfrmByType.FillComboBox(AComboBox: TComboBox;
  AQuesType: TQuesType);
  function GetTypeCount(const AQuesType: TQuesType): Integer;
  begin
    with FQuizProp.RndQues.TypeCount do
      case AQuesType of
        qtJudge:   Result := Judge;
        qtSingle:  Result := Single;
        qtMulti:   Result := Multi;
        qtBlank:   Result := Blank;
        qtMatch:   Result := Match;
        qtSeque:   Result := Seque;
        qtHotSpot: Result := HotSpot;
        qtEssay:   Result := Essay;
      else
        Result := 0;
      end;
  end;

var
  i, iCount, iTypeCount: Integer;
begin
  AComboBox.Clear;
  AComboBox.Items.Append('全部');
  iCount := FQuizObj.GetQuesCount(AQuesType);
  if iCount <> 0 then
    for i := 0 to iCount do
      AComboBox.Items.Append(IntToStr(i));
  iTypeCount := GetTypeCount(AQuesType);
  if iTypeCount = -1 then
    AComboBox.ItemIndex := 0
  else AComboBox.ItemIndex := AComboBox.Items.IndexOf(IntToStr(iTypeCount));
end;

function TfrmByType.GetRndCount: Integer;
  function GetQuesCount(AComboBox: TComboBox): Integer;
  begin
    if AComboBox.Items.Count <> 1 then
    begin
      if (AComboBox.ItemIndex = 0) then
        Result := AComboBox.Items.Count - 2
      else Result := AComboBox.ItemIndex - 1;
    end
    else Result := 0;
  end;

begin
  Result := 0;
  Inc(Result, GetQuesCount(cbJudge));
  Inc(Result, GetQuesCount(cbSingle));
  Inc(Result, GetQuesCount(cbMulti));
  Inc(Result, GetQuesCount(cbBlank));
  Inc(Result, GetQuesCount(cbMatch));
  Inc(Result, GetQuesCount(cbSeque));
  Inc(Result, GetQuesCount(cbHotSpot));
  Inc(Result, GetQuesCount(cbEssay));
end;

procedure TfrmByType.LoadData;
begin
  FillComboBox(cbJudge, qtJudge);
  FillComboBox(cbSingle, qtSingle);
  FillComboBox(cbMulti, qtMulti);
  FillComboBox(cbBlank, qtBlank);
  FillComboBox(cbMatch, qtMatch);
  FillComboBox(cbSeque, qtSeque);
  FillComboBox(cbHotSpot, qtHotSpot);
  FillComboBox(cbEssay, qtEssay);
  cbJudge.OnChange(cbJudge);
end;

procedure TfrmByType.SaveData;
  function GetTypeCount(AComboBox: TComboBox): Integer;
  begin
    if AComboBox.ItemIndex = 0 then
      Result := -1
    else Result := AComboBox.ItemIndex - 1;
  end;

begin
  with FQuizProp.RndQues.TypeCount do
  begin
    Judge   := GetTypeCount(cbJudge);
    Single  := GetTypeCount(cbSingle);
    Multi   := GetTypeCount(cbMulti);
    Blank   := GetTypeCount(cbBlank);
    Match   := GetTypeCount(cbMatch);
    Seque   := GetTypeCount(cbSeque);
    HotSpot := GetTypeCount(cbHotSpot);
    Essay   := GetTypeCount(cbEssay);
  end;
end;

function TfrmByType.CheckData: Boolean;
begin
  Result := False;
  if (FQuizObj.QuesList.Count <> 0) and (GetRndCount() = 0) then
  begin
    MessageBox(Handle, '抽题数量不能为0，请设置您按题型随机抽题的题数！', '提示', MB_OK + MB_ICONINFORMATION);
    cbJudge.SetFocus;
    Exit;
  end;

  Result := inherited CheckData();
end;

procedure TfrmByType.ComboBoxChange(Sender: TObject);
begin
  lblCount.Caption := '抽题数：' + IntToStr(GetRndCount());
end;

end.

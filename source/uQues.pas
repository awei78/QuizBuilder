unit uQues;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,     
  Dialogs, ComCtrls, uBase, StdCtrls, Buttons, ExtCtrls, CtrlsEx, Quiz, ImgList,
  Grids, RzGrids, RzPanel, RzButton, RzRadChk, RzTabs, ExtDlgs, uHotSpot, Math,
  Mask, RzEdit, RzBtnEdt;

type
  TfrmQues = class(TfrmBase)
    lblTopic: TLabel;
    meoTopic: TMemo;
    lblAns: TLabel;                                                                
    ilQues: TImageList;
    btnAdd: TSpeedButton;
    btnDel: TSpeedButton;
    edtPoint: TEdit;
    edtAttempts: TEdit;
    udAttempts: TUpDown;
    pcQues: TRzPageControl;
    tsList: TRzTabSheet;
    tsMemo: TRzTabSheet;
    tsHot: TRzTabSheet;
    sgQues: TRzStringGrid;
    meoAns: TMemo;
    bvlRight: TBevel;
    lblImg: TLabel;
    btnAddImg: TSpeedButton;
    btnDelImg: TSpeedButton;
    bvlMid: TBevel;
    pnlImg: TPanel;
    imgQues: TImage;
    lblLevel: TLabel;
    cbLevel: TComboBox;
    bvlFeed: TBevel;
    cbFeed: TRzCheckBox;
    meoCrt: TMemo;
    meoErr: TMemo;
    lblPoint: TLabel;
    lblTimes: TLabel;
    udPoint: TUpDown;
    odQues: TOpenDialog;
    fraHotSpot: TfraHotspot;
    btnOri: TSpeedButton;
    btnFit: TSpeedButton;
    btnImport: TBitBtn;
    odHot: TOpenPictureDialog;
    btnPrev: TSpeedButton;
    btnNext: TSpeedButton;
    lblAudio: TLabel;
    beAudio: TRzButtonEdit;
    cbAutoPlay: TCheckBox;
    cbCount: TComboBox;
    lblCount: TLabel;
    cbAnsFeed: TCheckBox;
    btnEdit: TSpeedButton;
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure btnResetClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure beAudioButtonClick(Sender: TObject);
    procedure cbAutoPlayClick(Sender: TObject);
    procedure cbAnsFeedClick(Sender: TObject);
    procedure sgQuesDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure sgQuesExit(Sender: TObject);
    procedure sgQuesKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure sgQuesSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure btnAddClick(Sender: TObject);
    procedure btnDelClick(Sender: TObject);
    procedure edtPointChange(Sender: TObject);
    procedure edtPointExit(Sender: TObject);
    procedure edtPointKeyPress(Sender: TObject; var Key: Char);
    procedure udPointChangingEx(Sender: TObject; var AllowChange: Boolean;
      NewValue: Smallint; Direction: TUpDownDirection);
    procedure cbFeedClick(Sender: TObject);
    procedure imgQuesDblClick(Sender: TObject);
    procedure btnAddImgClick(Sender: TObject);
    procedure btnDelImgClick(Sender: TObject);
    procedure btnImportClick(Sender: TObject);
    procedure fraHotSpotMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure fraHotSpotsbImgDblClick(Sender: TObject);
    procedure btnOriClick(Sender: TObject);
    procedure btnFitClick(Sender: TObject);
    procedure btnPrevClick(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
  private
    { Private declarations }
    FQuesObj: TQuesBase;
    //是否添加试题
    FNewQues: Boolean;
    //引用主窗体之ListView
    FListView: TListView;
    //出题
    procedure BuildJudge;
    procedure BuildSingle;
    procedure BuildMulti;
    procedure BuildBlank;
    procedure BuildMatch;
    procedure BuildSeque;
    procedure BuildHotSpot;
    procedure BuildEssay;
    procedure BuildScene;

    procedure SetBtnState;
    //StringGrid是否有重复项
    function HasSameValue: Boolean;
    //判断试题是否已改过
    function QuesChanged: Boolean;
    procedure LoadQues(const ANextQues: Boolean = False);
  protected
    //加载试题
    procedure LoadData; override;
    //存储试题
    procedure SaveData; override;
    //检查数据
    function CheckData: Boolean; override;
    //存单个试题
    procedure SaveQues(AQuesObj: TQuesBase);
  public
    { Public declarations }
  end;

var
  frmQues: TfrmQues;

function ShowQuesForm(AListView: TListView; AQuesObj: TQuesBase): Boolean;

implementation

uses uGlobal, uEditTopic;

const
  MAX_ROW_COUNT = 9;
  MIN_ROW_COUNT = 6;
  SIGN_COL      = 1;

{$R *.dfm}

function ShowQuesForm(AListView: TListView; AQuesObj: TQuesBase): Boolean;
begin
  with TfrmQues.Create(Application.MainForm) do
  begin
    try
      FQuesObj := AQuesObj;
      FListView := AListView;
      LoadData();
      Result := ShowModal() = mrOk;
    finally
      Free;
    end;
  end;
end;

procedure TfrmQues.LoadData;
begin
  FNewQues := FQuesObj.Topic = '';
  ilQues.GetIcon(Ord(FQuesObj._Type), Icon);
  Caption := FQuesObj.TypeName;

  sgQues.ColCount := 3;
  sgQues.ColWidths[0] := 20;
  sgQues.Cols[1].Clear;
  sgQues.Cols[2].Clear;
  btnEdit.Visible := QuizObj.QuizSet.SetAudio;
  cbAnsFeed.Visible := FQuesObj._Type = qtSingle;
  btnAdd.Visible := FQuesObj._Type in [qtSingle, qtMulti, qtBlank, qtMatch, qtSeque];
  btnDel.Visible := btnAdd.Visible;
  btnDel.Enabled := False;
  btnImport.Visible := FQuesObj._Type = qtHotSpot;
  btnOri.Visible := btnImport.Visible;
  btnFit.Visible := btnImport.Visible;
  btnPrev.Left := 216;
  btnPrev.Visible := not FNewQues;
  btnPrev.Enabled := (FListView.Items.Count > 1) and (FListView.ItemIndex > 0);
  btnNext.Left := btnPrev.Left + btnPrev.Width + 6;
  btnNext.Visible := not FNewQues;
  btnNext.Enabled := (FListView.Items.Count > 1) and (FListView.ItemIndex < FListView.Items.Count - 1);

  //是否显示声音设置
  if not QuizObj.QuizSet.SetAudio then
    meoTopic.Height := 57
  else meoTopic.Height := 33;
  lblAudio.Visible := QuizObj.QuizSet.SetAudio;
  beAudio.Visible := lblAudio.Visible;
  cbAutoPlay.Visible := lblAudio.Visible;
  cbCount.Visible := lblAudio.Visible;
  lblCount.Visible := lblAudio.Visible;
  //分数等信息显示与隐藏
  lblPoint.Visible := not (FQuesObj._Type in [qtEssay, qtScene]);
  edtPoint.Visible := lblPoint.Visible;
  udPoint.Visible := lblPoint.Visible;
  lblTimes.Visible := lblPoint.Visible;
  edtAttempts.Visible := lblPoint.Visible;
  udAttempts.Visible := lblPoint.Visible;
  lblLevel.Visible := lblPoint.Visible;
  cbLevel.Visible := lblPoint.Visible;
  cbFeed.Visible := lblPoint.Visible;
  bvlFeed.Visible := lblPoint.Visible;
  meoCrt.Visible := lblPoint.Visible;
  meoErr.Visible := lblPoint.Visible;

  if FQuesObj._Type in [qtJudge, qtSingle, qtMulti, qtBlank, qtMatch, qtSeque] then
  begin
    if FQuesObj._Type = qtJudge then
      imgHelp.Left := btnAdd.Left
    else imgHelp.Left := 73;
    pcQues.ActivePageIndex := 0;
    if FQuesObj._Type in [qtJudge, qtSingle, qtMulti] then sgQues.TabStops[1] := False;
  end
  else if FQuesObj._Type = qtHotSpot then
    pcQues.ActivePageIndex := 1
  else pcQues.ActivePageIndex := 2;

  //题目
  meoTopic.Text := FQuesObj.Topic;
  //答案区
  case FQuesObj._Type of
    qtJudge:   BuildJudge;
    qtSingle:  BuildSingle;
    qtMulti:   BuildMulti;
    qtBlank:   BuildBlank;
    qtMatch:   BuildMatch;
    qtSeque:   BuildSeque;
    qtHotSpot: BuildHotSpot;
    qtEssay:   BuildEssay;
    qtScene:   BuildScene;
  end;

  //加载参数
  with FQuesObj do
  begin
    //声音
    beAudio.Text := Audio.FileName;
    cbAutoPlay.Checked := Audio.AutoPlay;
    cbAutoPlay.OnClick(cbAutoPlay);
    cbCount.ItemIndex := Audio.LoopCount - 1;
    if FileExists(Image) then
    begin
      pnlImg.Caption := '';
      imgQues.Image := Image;
    end
    else btnDelImgClick(btnDelImg);

    //把udPoint与edtPoint分开以实现分数据的小数值
    udPoint.Position := Floor(Points);
    edtPoint.Text := FloatToStr(Points);
    edtAttempts.Enabled := FeedInfo.Enabled;
    udAttempts.Enabled := FeedInfo.Enabled;
    udAttempts.Position := Attempts;
    cbLevel.ItemIndex := Ord(Level);
    cbFeed.Checked := FeedInfo.Enabled;
    meoCrt.Text := FeedInfo.CrtInfo;
    meoErr.Text := FeedInfo.ErrInfo;
  end;
end;

procedure TfrmQues.SaveData;
begin
  if not QuesChanged then Exit;

  SaveQues(FQuesObj);
  //新题则加入题列表中
  if FNewQues then
  begin
    FQuesObj.Index := QuizObj.QuesList.Count + 1;
    QuizObj.QuesList.Append(FQuesObj);
  end;

  PostMessage(QuizObj.Handle, WM_QUIZCHANGE, QUIZ_CHANGED, 0);
end;

function TfrmQues.CheckData: Boolean;
var
  i: Integer;
begin
  Result := False;

  if Trim(meoTopic.Text) = '' then
  begin
    if FQuesobj._Type <> qtScene then
      MessageBox(Handle, '题目不能为空，请输入题目', '提示', MB_OK + MB_ICONINFORMATION)
    else MessageBox(Handle, '主题不能为空，请输入题目', '提示', MB_OK + MB_ICONINFORMATION);
    meoTopic.SetFocus;
    Exit;
  end;

  case FQuesObj._Type of
    qtJudge:
      with sgQues do
      begin
        //是否没有答案
        if (Trim(Cells[2, 1]) = '') or (Trim(Cells[2, 2]) = '') then
        begin
          MessageBox(Handle, '答案不能为空，请输入答案', '提示', MB_OK + MB_ICONINFORMATION);
          if Trim(Cells[2, 1]) = '' then
            Row := 1
          else Row := 2;
          Col := 2;
          SetFocus;

          Exit;
        end;

        for i := 1 to RowCount - 1 do
          Result := Result or Boolean(Cols[SIGN_COL].Objects[i]);

        if not Result then
        begin
          MessageBox(Handle, '答案没有选择，请指定答案', '提示', MB_OK + MB_ICONINFORMATION);
          SetFocus;
          Row := 1;
          Col := 1;

          Exit;
        end;
      end;
    qtSingle, qtMulti:
      with sgQues do
      begin
        //是否没有答案
        for i := 1 to sgQues.RowCount do
          Result := Result or (Trim(Cells[2, i]) <> '');

        if not Result then
        begin
          MessageBox(Handle, '答案不能为空，请输入答案', '提示', MB_OK + MB_ICONINFORMATION);
          Row := 1;
          Col := 2;
          SetFocus;

          Exit;
        end;

        Result := False;
        for i := 1 to RowCount - 1 do
          //对应的答案标识及对应的条目不能为空
          Result := Result or (Boolean(Cols[SIGN_COL].Objects[i]) and (Trim(Cells[2, i]) <> ''));

        if not Result then
        begin
          MessageBox(Handle, '答案没有选择，请指定答案', '提示', MB_OK + MB_ICONINFORMATION);
          Col := 1;
          Row := 1;
          SetFocus;

          Exit;
        end;
      end;
    qtBlank, qtSeque:
      with sgQues do
      begin
        //是否没有答案
        for i := 1 to sgQues.RowCount do
          Result := Result or (Trim(Cells[1, i]) <> '');

        if not Result then
        begin
          MessageBox(Handle, '答案不能为空，请输入答案', '提示', MB_OK + MB_ICONINFORMATION);
          SetFocus;

          Exit;
        end;
      end;
    qtMatch:
      with sgQues do
      begin
        //是否没有答案
        for i := 1 to sgQues.RowCount do
          Result := Result or (Trim(Cells[1, i]) <> '') and (Trim(Cells[2, i]) <> '');

        if not Result then
        begin
          MessageBox(Handle, '答案不能为空，请输入答案', '提示', MB_OK + MB_ICONINFORMATION);
          SetFocus;

          Exit;
        end;

        //是否有答案没有对应
        for i := 1 to sgQues.RowCount do
          if (Trim(Cells[1, i]) <> '') or (Trim(Cells[2, i]) <> '') then
            Result := Result and (Trim(Cells[1, i]) <> '') and (Trim(Cells[2, i]) <> '');

        if not Result then
        begin
          MessageBox(Handle, '答案没有对应，请输入答案', '提示', MB_OK + MB_ICONINFORMATION);
          SetFocus;

          Exit;
        end;
      end;
    qtHotSpot:
    begin
      if not FileExists(fraHotSpot.Image) then
      begin
        MessageBox(Handle, '热区题图片不存在，请导入图片', '提示', MB_OK + MB_ICONINFORMATION);
        btnImport.SetFocus;

        Exit;
      end;

      if not fraHotSpot.spRect.Visible then
      begin
        MessageBox(Handle, '热区题热点不存在，请设定热点', '提示', MB_OK + MB_ICONINFORMATION);
        fraHotSpot.SetFocus;

        Exit;
      end;
    end;
  end;

  Result := True;
end;  

procedure TfrmQues.SaveQues(AQuesObj: TQuesBase);
var
  i: Integer;
begin
  //加载参数
  with AQuesObj do
  begin
    //公有数据赋值
    Topic := meoTopic.Text;
    FeedAns := (_Type = qtSingle) and cbAnsFeed.Checked;
    with Audio do
    begin
      FileName := beAudio.Text;
      AutoPlay := cbAutoPlay.Checked;
      LoopCount := cbCount.ItemIndex + 1;
    end;
    Image := imgQues.Image;
    if not (_Type in [qtEssay, qtScene]) then
    begin
      Points := StrToFloat(edtPoint.Text); //udPoint.Position;
      Attempts := udAttempts.Position;
      Level := TQuesLevel(cbLevel.ItemIndex);
    end
    //简答题特别处理
    else
    begin
      Points := 0;
      Attempts := 0;
      if _Type = qtEssay then
        Level := qlEssay
      else Level := qlScene;
    end;
    with FeedInfo do
    begin
      Enabled := not (_Type in [qtEssay, qtScene]) and cbFeed.Checked;
      CrtInfo := meoCrt.Text;
      ErrInfo := meoErr.Text;
    end;

    //同步更新列表
    if not FNewQues and (FListView.Selected <> nil) then
      with FListView.Selected do
      begin
        SubItems[0] := Topic;
        if _Type <> qtScene then
        begin
          SubItems[2] := FloatToStr(Points);
          SubItems[3] := LevelName;
        end;
      end;
  end;

  //答案赋值
  case AQuesObj._Type of
    qtJudge, qtSingle, qtMulti:
    begin
      TQuesObj(AQuesObj).Answers.Clear;
      with sgQues do
      begin
        for i := 1 to RowCount - 1 do
          if not AQuesObj.FeedAns then
          begin
            if Boolean(Cols[SIGN_COL].Objects[i]) then
              TQuesObj(AQuesObj).Answers.Append('True=' + Cells[2, i])
            else TQuesObj(AQuesObj).Answers.Append('False=' + Cells[2, i]);
          end
          else if AQuesObj._Type = qtSingle then
          begin
            if Boolean(Cols[SIGN_COL].Objects[i]) then
              TQuesObj(AQuesObj).Answers.Append('True=' + Cells[2, i] + '$$$$' + Cells[3, i])
            else TQuesObj(AQuesObj).Answers.Append('False=' + Cells[2, i] + '$$$$' + Cells[3, i]);
          end;
      end;
    end;
    qtBlank, qtSeque:
    begin
      TQuesObj(AQuesObj).Answers.Clear;
      with sgQues do
        for i := 1 to RowCount - 1 do
          TQuesObj(AQuesObj).Answers.Append(Cells[1, i]);
    end;
    qtMatch:
    begin
      TQuesObj(AQuesObj).Answers.Clear;
      with sgQues do
        for i := 1 to RowCount - 1 do
          TQuesObj(AQuesObj).Answers.Append(StringReplace(Cells[1, i], '=', '$+$', [rfReplaceAll]) + '=' + Cells[2, i]);
    end;
    qtHotSpot:
    begin
      with TQuesHot(AQuesObj), fraHotSpot do
      begin
        HotImage := Image;
        HPos := sbImg.HorzScrollBar.Position;
        VPos := sbImg.VertScrollBar.Position;
        HotRect := Rect(spRect.Left , spRect.Top, spRect.Width, spRect.Height);
        ImgFit := btnFit.Down;
      end;
    end;
    qtEssay, qtScene:
      TQuesObj(AQuesObj).Answers.Text := meoAns.Text;
  end;
end;

procedure TfrmQues.FormShortCut(var Msg: TWMKey; var Handled: Boolean);
begin
  if not (ActiveControl is TStringGrid) or (Msg.CharCode = VK_F1) or (Msg.CharCode = VK_ESCAPE) then inherited;

  //Page Up、Page Down键，执行浏览题功能
  if (Msg.CharCode = VK_PRIOR) and btnPrev.Enabled then
  begin
    Handled := True;
    btnPrev.OnClick(btnPrev);
  end;
  if (Msg.CharCode = VK_NEXT) and btnNext.Enabled then
  begin
    Handled := True;
    btnNext.OnClick(btnNext);
  end;
end;

procedure TfrmQues.BuildJudge;
var
  QuesObj: TQuesObj;
begin
  HelpHtml := 'true_false.html';

  QuesObj := TQuesObj(FQuesObj);
  with sgQues do
  begin
    RowCount := 3;
    ColWidths[1] := 53;
    ColWidths[2] := 302;

    Cells[0, 1] := '1';
    Cells[0, 2] := '2';
    Cells[1, 0] := '正确答案';
    Cells[2, 0] := '选项';
    //编辑
    if FNewQues then
    begin
      Cells[2, 1] := '是';
      Cells[2, 2] := '否';
    end
    else
    begin
      if QuesObj.Answers.Names[0] = 'True' then
      begin
        Cols[SIGN_COL].Objects[1] := TObject(True);
        sgQues.OnDrawCell(sgQues, 1, 1, sgQues.CellRect(1, 1), []);
      end
      else
      begin
        Cols[SIGN_COL].Objects[2] := TObject(True);
        sgQues.OnDrawCell(sgQues, 1, 2, sgQues.CellRect(1, 2), []);
      end;

      Cells[2, 1] := QuesObj.Answers.ValueFromIndex[0];
      Cells[2, 2] := QuesObj.Answers.ValueFromIndex[1];
    end;

    Row := 1;
    Col := 2;
  end;
end;

procedure TfrmQues.BuildSingle;
var
  i: Integer;
  QuesObj: TQuesObj;
begin
  if FQuesObj._Type = qtSingle then
    HelpHtml := 'single.html'
  else HelpHtml := 'multi.html';

  QuesObj := TQuesObj(FQuesObj);
  cbAnsFeed.Checked := QuesObj.FeedAns;
  if FQuesObj._Type = qtSingle then cbAnsFeed.OnClick(cbAnsFeed);
  with sgQues do
  begin
    ColWidths[1] := 53;
    ColWidths[2] := 302;

    Cells[1, 0] := '正确答案';
    Cells[2, 0] := '选项';

    if FNewQues then
    begin
      RowCount := 5;
      Cells[0, 1] := '1';
      Cells[0, 2] := '2';
      Cells[0, 3] := '3';
      Cells[0, 4] := '4';
    end
    else
    begin
      RowCount := QuesObj.Answers.Count + 1;
      for i := 0 to QuesObj.Answers.Count - 1 do
      begin
        if QuesObj.Answers.Names[i] = 'True' then
        begin
          Cols[SIGN_COL].Objects[i + 1] := TObject(True);
          sgQues.OnDrawCell(sgQues, 1, i + 1, sgQues.CellRect(1, i + 1), []);
        end;

        Cells[0, i + 1] := IntToStr(i + 1);
        Cells[2, i + 1] := QuesObj.GetAnswer(QuesObj.Answers.ValueFromIndex[i]);
        if QuesObj.FeedAns then
          Cells[3, i + 1] := QuesObj.GetFeedback(QuesObj.Answers.ValueFromIndex[i]);
      end;

      SetBtnState();
    end;

    Row := 1;
    Col := 2;
  end;
end;

procedure TfrmQues.BuildMulti;
begin
  BuildSingle;
end;

procedure TfrmQues.BuildBlank;
var
  i: Integer;
  QuesObj: TQuesObj;
begin
  HelpHtml := 'blank.html';
  sgQues.ColCount := 2;

  QuesObj := TQuesObj(FQuesObj);
  with sgQues do
  begin
    ColWidths[1] := 356;
    Cells[1, 0] := '可接受答案';

    if FNewQues then
    begin
      RowCount := 5;
      Cells[0, 1] := '1';
      Cells[0, 2] := '2';
      Cells[0, 3] := '3';
      Cells[0, 4] := '4';
    end
    else
    begin
      RowCount := QuesObj.Answers.Count + 1;
      for i := 0 to QuesObj.Answers.Count - 1 do
        Cells[1, i + 1] := QuesObj.Answers[i];

      SetBtnState();
    end;

    Row := 1;
    Col := 1;
  end;
end;

procedure TfrmQues.BuildMatch;
var
  i: Integer;
  QuesObj: TQuesObj;
begin
  HelpHtml := 'match.html';

  QuesObj := TQuesObj(FQuesObj);
  with sgQues do
  begin
    ColWidths[1] := 177;
    ColWidths[2] := 178;

    Cells[1, 0] := '选项';
    Cells[2, 0] := '匹配项';

    if FNewQues then
    begin
      RowCount := 5;
      Cells[0, 1] := '1';
      Cells[0, 2] := '2';
      Cells[0, 3] := '3';
      Cells[0, 4] := '4';      
    end
    else
    begin
      RowCount := QuesObj.Answers.Count + 1;
      for i := 0 to QuesObj.Answers.Count - 1 do
      begin
        Cells[1, i + 1] := StringReplace(QuesObj.Answers.Names[i], '$+$', '=', [rfReplaceAll]);
        Cells[2, i + 1] := QuesObj.Answers.ValueFromIndex[i];
      end;

      SetBtnState();
    end;

    Row := 1;
    Col := 1;
  end;
end;

procedure TfrmQues.BuildSeque;
var
  i: Integer;
  QuesObj: TQuesObj;
begin
  HelpHtml := 'seque.html';
  sgQues.ColCount := 2;

  QuesObj := TQuesObj(FQuesObj);
  with sgQues do
  begin
    ColWidths[1] := 356;
    Cells[1, 0] := '答案正确顺序';

    if FNewQues then
    begin
      RowCount := 5;
      Cells[0, 1] := '1';
      Cells[0, 2] := '2';
      Cells[0, 3] := '3';
      Cells[0, 4] := '4';
    end
    else
    begin
      RowCount := QuesObj.Answers.Count + 1;
      for i := 0 to QuesObj.Answers.Count - 1 do
        Cells[1, i + 1] := QuesObj.Answers[i];

      SetBtnState();
    end;

    Row := 1;
    Col := 1;
  end;
end;

procedure TfrmQues.BuildHotSpot;
var
  QuesHot: TQuesHot;
begin
  HelpHtml := 'hotspot.html';
  lblAns.Caption := '图像及热点：';

  btnImport.Left := btnAdd.Left;
  btnOri.Left := btnImport.Left + btnImport.Width + 12;
  btnFit.Left := btnOri.Left + btnFit.Width + 6;
  imgHelp.Left := btnFit.Left + btnFit.Width + 12;
  //可用状态
  btnOri.Enabled := not FNewQues;
  btnFit.Enabled := not FNewQues;

  QuesHot := TQuesHot(FQuesObj);
  with fraHotSpot do
  begin
    sbImg.DoubleBuffered := True;
    img.Cursor := crCross;
    imgHot.Cursor := crSizeAll;
    Edit := not FNewQues;

    //编辑
    if not FNewQues then
    begin
      Image := QuesHot.HotImage;
      //先执行动作
      if FileExists(Image) and QuesHot.ImgFit then
      begin
        btnFit.Down := True;
        btnFit.OnClick(btnFit);
      end;

      sbImg.HorzScrollBar.Position := QuesHot.HPos;
      sbImg.VertScrollBar.Position := QuesHot.VPos;
      SetHotPos(QuesHot.HotRect);
    end;
  end;
end;

procedure TfrmQues.BuildEssay;
begin
  HelpHtml := 'essay.html';
  imgHelp.Left := btnAdd.Left;
  lblAns.Caption := '参考答案：';

  if not FNewQues then meoAns.Text := TQuesObj(FQuesObj).Answers.Text;
end;

procedure TfrmQues.BuildScene;
begin
  HelpHtml := 'scene.html';
  imgHelp.Left := btnAdd.Left;
  lblTopic.Caption := '主题：';
  lblAns.Caption := '场景简介：';

  if not FNewQues then meoAns.Text := TQuesObj(FQuesObj).Answers.Text;
end;

procedure TfrmQues.SetBtnState;
var
  i: Integer;
begin
  btnAdd.Visible := FQuesObj._Type in [qtSingle, qtMulti, qtBlank, qtMatch, qtSeque];
  btnDel.Visible := btnAdd.Visible;

  btnAdd.Enabled := sgQues.RowCount <= MAX_ROW_COUNT;
  btnDel.Enabled := sgQues.RowCount >= MIN_ROW_COUNT;

  for i := 1 to sgQues.RowCount - 1 do
    sgQues.Cells[0, i] := IntToStr(i);
end;

function TfrmQues.HasSameValue: Boolean;
var
  iIndex: Integer;
begin
  inherited;

  Result := False;
  //答案级返馈信息不处理
  if (FQuesObj._Type = qtSingle) and (sgQues.Col = 3) then Exit; 
  //重复答案检测
  if Trim(sgQues.Cells[sgQues.Col, sgQues.Row]) <> '' then
  begin
    iIndex := sgQues.Cols[sgQues.Col].IndexOf(sgQues.Cells[sgQues.Col, sgQues.Row]);

    if (iIndex <> sgQues.Row) and (iIndex <> -1) then
    begin
      MessageBox(Handle, '已有相同的答案项，请重新输入', '提示', MB_OK + MB_ICONINFORMATION);
      Result := True;
    end;
  end;
end;

function TfrmQues.QuesChanged: Boolean;
var
  i: Integer;
  slAns: TStrings;
begin
  //先判断通用属性
  Result := (FQuesObj.Topic <> meoTopic.Text) or
            (FQuesObj.Audio.FileName <> beAudio.Text) or
            (FQuesObj.Audio.AutoPlay <> cbAutoPlay.Checked) or
            (FQuesObj.Audio.LoopCount <> cbCount.ItemIndex + 1) or
            (FQuesObj.FeedAns <> (FQuesObj._Type = qtSingle) and cbAnsFeed.Checked) or
            (FQuesObj.Image <> imgQues.Image) or
            udPoint.Visible and (FloatToStr(FQuesObj.Points) <> edtPoint.Text) or
            udAttempts.Visible and (FQuesObj.Attempts <> udAttempts.Position) or
            cbLevel.Visible and (FQuesObj.Level <> TQuesLevel(cbLevel.ItemIndex)) or
            cbFeed.Visible and ((FQuesObj.FeedInfo.Enabled <> cbFeed.Checked) or
            (FQuesObj.FeedInfo.CrtInfo <> meoCrt.Text) or
            (FQuesObj.FeedInfo.ErrInfo <> meoErr.Text));
  if Result then Exit;

  //再判断题属性
  //答案赋值
  slAns := TStringList.Create;
  try
    case FQuesObj._Type of
      qtJudge, qtSingle, qtMulti:
      begin
        with sgQues do
        begin
          for i := 1 to RowCount - 1 do
            if Boolean(Cols[SIGN_COL].Objects[i]) then
              slAns.Append('True=' + Cells[2, i])
            else slAns.Append('False=' + Cells[2, i]);
        end;
      end;
      qtBlank, qtSeque:
      begin
        with sgQues do
          for i := 1 to RowCount - 1 do
            slAns.Append(Cells[1, i]);
      end;
      qtMatch:
      begin
        with sgQues do
          for i := 1 to RowCount - 1 do
            slAns.Append(StringReplace(Cells[1, i], '=', '$+$', [rfReplaceAll]) + '=' + Cells[2, i]);
      end;
      qtHotSpot:
      begin
        with TQuesHot(FQuesObj), fraHotSpot do
        begin
          Result := (HotImage <> Image) or
                    (HPos <> sbImg.HorzScrollBar.Position) or
                    (VPos <> sbImg.VertScrollBar.Position) or
                    (HotRect.Left <> spRect.Left) or
                    (HotRect.Top <> spRect.Top) or
                    (HotRect.Right <> spRect.Width) or
                    (HotRect.Bottom <> spRect.Height) or
                    (ImgFit <> btnFit.Down);
        end;
      end;
      qtEssay, qtScene:
        slAns.Text := meoAns.Text;
    end;

    if FQuesObj._Type <> qtHotSpot then Result := slAns.Text <> TQuesObj(FQuesObj).Answers.Text;
  finally
    slAns.Free;
  end;
end;

procedure TfrmQues.LoadQues(const ANextQues: Boolean);
var
  CurIndex: Integer;
begin
  if QuesChanged() then
  begin
    if CheckData() then
      SaveData()
    else Exit;
  end;

  with FListView do
  begin
    if ANextQues then
      CurIndex := ItemIndex + 1
    else CurIndex := ItemIndex - 1;
    Items[ItemIndex].Selected := False;
    ItemIndex := CurIndex;
    Items[ItemIndex].Focused := True;
    Items[ItemIndex].MakeVisible(True);
    FQuesObj := TQuesBase(Selected.Data);
  end;
  LoadData();
end;

procedure TfrmQues.btnResetClick(Sender: TObject);
begin
  Close;
end;

//预览
procedure TfrmQues.btnCancelClick(Sender: TObject);
var
  QuesObj: TQuesBase;
begin
  if CheckData() then
  begin
    if FQuesObj._Type = qtHotSpot then
      QuesObj := TQuesHot.Create(FQuesObj._Type)
    else QuesObj := TQuesObj.Create(FQuesObj._Type);
    try
      SaveQues(QuesObj);
      QuizObj.Publish.Preview(QuesObj);
    finally
      QuesObj.Free;
    end;
  end;
end;

procedure TfrmQues.btnEditClick(Sender: TObject);
begin
  ShowEditTopic(meoTopic);
end;

procedure TfrmQues.beAudioButtonClick(Sender: TObject);
var
  od: TOpenDialog;
begin
  od := TOpenDialog.Create(Self);

  try
    od.Filter := '支持的音频文件(*.mp3; *.wav)|*.mp3;*.wav';
    if od.Execute then beAudio.Text := od.FileName;
  finally
    od.Free;
  end;
end;

procedure TfrmQues.cbAutoPlayClick(Sender: TObject);
begin
  cbCount.Enabled := cbAutoPlay.Checked;
end;

procedure TfrmQues.cbAnsFeedClick(Sender: TObject);
begin
  if cbAnsFeed.Checked then
  begin
    sgQues.ColCount := 4;
    sgQues.ColWidths[2] := 176;
    sgQues.ColWidths[3] := 125;
    sgQues.Cells[3, 0] := '反馈信息';
 end
  else
  begin
    sgQues.ColCount := 3;
    sgQues.ColWidths[2] := 302;
  end;
  if Visible then sgQues.SetFocus;
  edtAttempts.Enabled := cbAnsFeed.Visible and cbAnsFeed.Checked or cbFeed.Checked;
  udAttempts.Enabled := edtAttempts.Enabled;
end;

procedure TfrmQues.sgQuesSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
var
  i: Integer;
begin
  case FQuesObj._Type of
    qtJudge, qtSingle, qtMulti:
    begin
      if ACol = 1 then
      begin
        //以设定其状态，用在设置是否显示正确答案之上
        if FQuesObj._Type in [qtJudge, qtSingle]  then
          for i := 1 to sgQues.RowCount - 1 do
            sgQues.Cols[ACol].Objects[i] := TObject(False);

        sgQues.Options := sgQues.Options - [goEditing];
        if FQuesObj._Type = qtMulti then
        begin
          //判断左键是否按下，以避免键盘操作取消选中标记
          if (GetAsyncKeyState(VK_LBUTTON) and $8000) <> 0 then
            sgQues.Cols[ACol].Objects[ARow] := TObject((Trim(sgQues.Cells[2, ARow]) <> '') and not Boolean(sgQues.Cols[ACol].Objects[ARow]))
        end
        else sgQues.Cols[ACol].Objects[ARow] := TObject(Trim(sgQues.Cells[2, ARow]) <> '');
      end
      else if ACol in [2, 3] then
        sgQues.Options := sgQues.Options + [goEditing]
    end;
    qtBlank, qtMatch, qtSeque:
      sgQues.Options := sgQues.Options + [goEditing];
  end;

  //重复答案项检测；对Col判断是针对匹配题的
  if ((sgQues.Row <> ARow) or (sgQues.Col <> ACol)) and HasSameValue() then
  begin
    CanSelect := False;
    sgQues.Cols[ACol].Objects[ARow] := TObject(False);
    sgQues.Options := sgQues.Options + [goEditing];
  end;
end;

procedure TfrmQues.sgQuesExit(Sender: TObject);
begin
  if HasSameValue() then sgQues.SetFocus;
end;

procedure TfrmQues.sgQuesDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
  //屏蔽TAB键
  case FQuesObj._Type of
    qtJudge, qtSingle, qtMulti:
    begin
      if (ACol = 1) and (ARow >= 1) and Boolean(sgQues.Cols[ACol].Objects[ARow]) then
        ilQues.Draw(sgQues.Canvas, sgQues.Left + Rect.Left + 8, sgQues.Top + Rect.Top, 9);
    end;
  end;
end;

procedure TfrmQues.sgQuesKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  inherited;
  //实现Tab键效果
  if (Key = VK_RETURN) and not HasSameValue then PostMessage(sgQues.Handle, WM_KEYDOWN, VK_TAB, 0);
  if (Key = VK_TAB) and (sgQues.Row = sgQues.RowCount - 1) and (sgQues.Col = sgQues.ColCount - 1) then edtPoint.SetFocus;
end;

procedure TfrmQues.btnAddClick(Sender: TObject);
begin
  sgQues.RowCount := sgQues.RowCount + 1;
  SetBtnState;
end;

procedure TfrmQues.btnDelClick(Sender: TObject);
begin
  sgQues.RowCount := sgQues.RowCount - 1;
  SetBtnState;
end;

procedure TfrmQues.edtPointChange(Sender: TObject);
begin
  try
    udPoint.Position := Floor(StrToFloat(edtPoint.Text));
  except
    //do nothing
  end;
end;

procedure TfrmQues.edtPointExit(Sender: TObject);
begin
  if Trim(edtPoint.Text) = '' then edtPoint.Text := '0';
end;

procedure TfrmQues.edtPointKeyPress(Sender: TObject; var Key: Char);
begin
  udPoint.OnChangingEx := nil;
  try
    if (not (Key in ['0'..'9', '.', #8])) or (Key = '.') and (Pos('.', edtPoint.Text) <> 0) then Key := #0;
    if edtPoint.SelText = edtPoint.Text then
    begin
      edtPoint.Text := Key;
      edtPoint.SelStart := Length(Key);
      Abort;
    end;
    if Key <> #8 then
      try
        if (StrToFloat(StringReplace(edtPoint.Text, edtPoint.SelText, Key, [])) > 100) or
          (StrToFloat(StringReplace(edtPoint.Text, edtPoint.SelText, '', []) + Key) > 100) then
          Key := #0;
      except
        Key := #0;
      end;
  finally
    udPoint.OnChangingEx := udPointChangingEx;
  end;
end;

procedure TfrmQues.udPointChangingEx(Sender: TObject;
  var AllowChange: Boolean; NewValue: Smallint;
  Direction: TUpDownDirection);
var
  sDecimal: string;
begin
  if not (NewValue in [udPoint.Min..udPoint.Max]) then Exit;

  edtPoint.OnChange := nil;
  try
    if Pos('.', edtPoint.Text) <> 0 then
      try
        sDecimal := Copy(edtPoint.Text, Pos('.', edtPoint.Text), Length(edtPoint.Text) - Pos('.', edtPoint.Text) + 1);
        if NewValue + StrToFloat(sDecimal) > udPoint.Max then Exit;
      except
        Exit;
      end;

    if Pos('.', edtPoint.Text) = 0 then
      edtPoint.Text := IntToStr(NewValue)
    else edtPoint.Text := IntToStr(NewValue) + Copy(edtPoint.Text, Pos('.', edtPoint.Text), Length(edtPoint.Text) - Pos('.', edtPoint.Text) + 1);
  finally
    edtPoint.OnChange := edtPointChange;
  end;
end;

procedure TfrmQues.cbFeedClick(Sender: TObject);
var
  Enabled: Boolean;
begin
  Enabled := cbFeed.Checked;
  meoCrt.Enabled := Enabled;
  meoErr.Enabled := Enabled;
  edtAttempts.Enabled := Enabled or cbAnsFeed.Visible and cbAnsFeed.Checked;
  udAttempts.Enabled := edtAttempts.Enabled;
end;

procedure TfrmQues.imgQuesDblClick(Sender: TObject);
begin
  btnAddImg.OnClick(btnAddImg);
end;

procedure TfrmQues.btnAddImgClick(Sender: TObject);
begin
  if odQues.Execute then imgQues.Image := odQues.FileName;
end;

procedure TfrmQues.btnDelImgClick(Sender: TObject);
begin
  imgQues.Image := '';
  pnlImg.Caption := '没有图片';
end;

procedure TfrmQues.btnImportClick(Sender: TObject);
begin
  if odHot.Execute then
  begin
    fraHotSpot.Image := odHot.FileName;
    fraHotSpot.sbImg.SetFocus;
    btnOri.Enabled := True;
    btnFit.Enabled := True;
    if btnFit.Down then btnFit.OnClick(btnFit);
  end;
end;

procedure TfrmQues.fraHotSpotMouseWheel(Sender: TObject;
  Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
  var Handled: Boolean);
begin
  if WheelDelta < 0 then
    fraHotSpot.sbImg.Perform(WM_VSCROLL, SB_LINEDOWN, 0)
  else fraHotSpot.sbImg.Perform(WM_VSCROLL, SB_LINEUP, 0);
end;

procedure TfrmQues.fraHotSpotsbImgDblClick(Sender: TObject);
begin
  if fraHotSpot.Image = '' then btnImportClick(btnImport);
end;

procedure TfrmQues.btnOriClick(Sender: TObject);
begin
  fraHotSpot.SetImageToOri();
end;

procedure TfrmQues.btnFitClick(Sender: TObject);
begin
  fraHotSpot.SetImageToFit();
end;

procedure TfrmQues.btnPrevClick(Sender: TObject);
begin
  LoadQues(False);
end;

procedure TfrmQues.btnNextClick(Sender: TObject);
begin
  LoadQues(True);
end;

end.

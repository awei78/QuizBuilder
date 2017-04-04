{******
  单 元：uMain.pas
  作 者：刘景威                                                                                                                        
  日 期：2007-5-14
  说 明：程序主单元
  更 新：
******}

unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, XPMan, Menus, ImgList, ActnList, ComCtrls, CtrlsEx, RzPanel, RzButton,
  ExtCtrls, ToolWin, ShellAPI, Quiz;

type
  TfrmMain = class(TForm)
    mmQuiz: TMainMenu;
    miFile: TMenuItem;
    miNew: TMenuItem;
    miOpen: TMenuItem;
    N1: TMenuItem;
    miSave: TMenuItem;
    miSaveAs: TMenuItem;
    N2: TMenuItem;                   
    miExit: TMenuItem;
    miSet: TMenuItem;
    miProp: TMenuItem;
    alMenu: TActionList;
    actNew: TAction;
    actProp: TAction;
    actPlayer: TAction;
    actJudge: TAction;
    actOpen: TAction;
    actSave: TAction;
    actSaveAs: TAction;
    actExit: TAction;
    actSingle: TAction;
    actMulti: TAction;
    actBlank: TAction;
    actMatch: TAction;
    actSeque: TAction;
    actHotspot: TAction;
    actEssay: TAction;
    actViewS: TAction;
    actViewA: TAction;
    actWeb: TAction;
    actLms: TAction;
    actWord: TAction;
    actExcel: TAction;
    actExe: TAction;
    actHelp: TAction;
    actAbout: TAction;
    sbQuiz: TStatusBar;
    miPlayer: TMenuItem;
    miQues: TMenuItem;
    miJudge: TMenuItem;
    N3: TMenuItem;
    miSingle: TMenuItem;
    miMul: TMenuItem;
    N4: TMenuItem;
    miBlank: TMenuItem;
    N5: TMenuItem;
    miMatch: TMenuItem;
    miSeque: TMenuItem;
    N6: TMenuItem;
    miHotspot: TMenuItem;
    miEssay: TMenuItem;
    miView: TMenuItem;
    miViewS: TMenuItem;
    miViewA: TMenuItem;
    miPublish: TMenuItem;
    miWeb: TMenuItem;
    miLms: TMenuItem;
    miWord: TMenuItem;
    miExcel: TMenuItem;
    miHelp: TMenuItem;
    miContent: TMenuItem;
    miAbout: TMenuItem;
    tbQuiz: TRzToolbar;
    ilQuiz: TImageList;
    btnNew: TRzToolButton;
    btnOpen: TRzToolButton;
    btnSave: TRzToolButton;
    RzSpacer1: TRzSpacer;
    btnProp: TRzToolButton;
    RzSpacer2: TRzSpacer;
    btnQues: TRzToolButton;
    RzSpacer3: TRzSpacer;
    btnViewA: TRzToolButton;
    btnPubish: TRzToolButton;
    pmQues: TPopupMenu;
    pmiJudge: TMenuItem;
    N10: TMenuItem;
    pmiSingle: TMenuItem;
    pmiMul: TMenuItem;
    N13: TMenuItem;
    pmiBlank: TMenuItem;
    N15: TMenuItem;
    pmiMatch: TMenuItem;
    pmiSeque: TMenuItem;
    N18: TMenuItem;
    pmiHotspot: TMenuItem;
    pmiEssay: TMenuItem;
    actPub: TAction;
    actSet: TAction;
    N7: TMenuItem;
    miParam: TMenuItem;
    miFromExcel: TMenuItem;
    actAppend: TAction;
    tvQuiz: TTreeView;
    lvQues: TListView;
    spQuiz: TSplitter;
    actUrl: TAction;
    miUrl: TMenuItem;
    pmEdit: TPopupMenu;
    MenuItem10: TMenuItem;
    miInfo: TMenuItem;
    miDup: TMenuItem;
    actInfo: TAction;
    actDel: TAction;
    actDup: TAction;
    actSel: TAction;
    miViewQ: TMenuItem;
    miDel: TMenuItem;
    miSel: TMenuItem;
    N8: TMenuItem;
    pmTree: TPopupMenu;
    miClearQ: TMenuItem;
    N11: TMenuItem;
    miCount: TMenuItem;
    actClear: TAction;
    actCount: TAction;
    actAdd: TAction;
    miAdd: TMenuItem;
    miReg: TMenuItem;
    actReg: TAction;
    btnPlayer: TRzToolButton;
    RzSpacer4: TRzSpacer;
    actQQ: TAction;
    miQQ: TMenuItem;
    ilQues: TImageList;
    actBuy: TAction;
    miBuy: TMenuItem;
    actChart: TAction;
    miChart: TMenuItem;
    actImport: TAction;
    miImport: TMenuItem;
    miExe: TMenuItem;
    actScene: TAction;
    N9: TMenuItem;
    pmiScene: TMenuItem;
    N12: TMenuItem;
    miScene: TMenuItem;
    procedure actNewExecute(Sender: TObject);
    procedure actOpenExecute(Sender: TObject);
    procedure actAppendExecute(Sender: TObject);
    procedure actImportExecute(Sender: TObject);
    procedure actSaveExecute(Sender: TObject);
    procedure actSaveAsExecute(Sender: TObject);
    procedure actExitExecute(Sender: TObject);
    procedure actPropExecute(Sender: TObject);
    procedure actSetExecute(Sender: TObject);
    procedure actPlayerExecute(Sender: TObject);
    procedure actJudgeExecute(Sender: TObject);
    procedure actSingleExecute(Sender: TObject);
    procedure actMultiExecute(Sender: TObject);
    procedure actBlankExecute(Sender: TObject);
    procedure actMatchExecute(Sender: TObject);
    procedure actSequeExecute(Sender: TObject);
    procedure actHotspotExecute(Sender: TObject);
    procedure actEssayExecute(Sender: TObject);
    procedure actSceneExecute(Sender: TObject);
    procedure actViewSExecute(Sender: TObject);
    procedure actViewAExecute(Sender: TObject);
    procedure actPubExecute(Sender: TObject);
    procedure actWebExecute(Sender: TObject);
    procedure actLmsExecute(Sender: TObject);
    procedure actWordExecute(Sender: TObject);
    procedure actExcelExecute(Sender: TObject);
    procedure actExeExecute(Sender: TObject);
    procedure actHelpExecute(Sender: TObject);
    procedure actUrlExecute(Sender: TObject);
    procedure actQQExecute(Sender: TObject);
    procedure actRegExecute(Sender: TObject);
    procedure actBuyExecute(Sender: TObject);
    procedure actAboutExecute(Sender: TObject);
    procedure actDelExecute(Sender: TObject);
    procedure actInfoExecute(Sender: TObject);
    procedure actSelExecute(Sender: TObject);
    procedure actDupExecute(Sender: TObject);
    procedure actAddExecute(Sender: TObject);
    procedure actChartExecute(Sender: TObject);
    procedure actClearExecute(Sender: TObject);
    procedure actCountExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormResize(Sender: TObject);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure spQuizCanResize(Sender: TObject; var NewSize: Integer;
      var Accept: Boolean);
    procedure spQuizMoved(Sender: TObject);
    procedure tvQuizChange(Sender: TObject; Node: TTreeNode);
    procedure tvQuizDblClick(Sender: TObject);
    procedure tvQuizMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lvQuesClick(Sender: TObject);
    procedure lvQuesCustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure lvQuesDblClick(Sender: TObject);
    procedure lvQuesDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure lvQuesDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure lvQuesGetImageIndex(Sender: TObject; Item: TListItem);
    procedure lvQuesSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure pmTreePopup(Sender: TObject);
    procedure pmEditPopup(Sender: TObject);
    procedure miViewClick(Sender: TObject);
  private
    { Private declarations }
    FLastIndex: Integer;
    //初始化数据
    procedure InitData;
    //初始化QuizObj
    procedure InitQuizObj;
    //存储数据
    procedure SaveData;
    //更新状态栏数据
    procedure UpdateStatus;
    //导入工程
    procedure ImportProj(const AProjName: string);
    //追加工程
    procedure AppendProj(const AProjName: string);
    //从Excel中导入
    procedure ImportExcel(const AXlsName: string);
    //新建工程
    procedure NewProj;
    //是否可以继续
    function GetCanResume: Boolean;
    //添加一个试题
    procedure AppendQues(AQuesObj: TQuesBase);
    //在ListView中追加一条数据
    procedure AppendData(AQuesObj: TQuesBase);
    //在ListView中显示试题
    procedure LoadQueses;
    //重新对QuesList、ListView项排序
    procedure ResortQueses;
    //菜单点击事件
    procedure MenuItemClick(Sender: TObject);
    //重设置ListListView;
    procedure ResizeListView;
    //是否显示节点题数量
    procedure DisplayItemCount;
    //使模式窗点可闪标题栏
    procedure WMSetCursor(var Message: TWMSetCursor); message WM_SETCURSOR;
    //接收工程已改变消息
    procedure WMQuizChange(var Message: TMessage); message WM_QUIZCHANGE;
    //接受文件拖放
    procedure WMDropFiles(var Message: TWMDropFiles); message WM_DROPFILES;
    //获取外部工程
    procedure WMOuterProj(var Message: TMessage); message WM_OUTERPROJ;
    //处理系统消息
    procedure WMSysCommand(var Message: TWMSysCommand); message WM_SYSCOMMAND;
    //加入屏幕边界吸附功能，纯为好玩
    procedure WMWindowPosChanging(var Message: TWMWindowPosChanging); message WM_WINDOWPOSCHANGING;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses Registry, uGlobal, uProp, uPublish, uQues, uParam, uPlayer, uAbout,
  uProgress, uReg, uChart;

{$R *.dfm}

procedure TfrmMain.WMSetCursor(var Message: TWMSetCursor);
begin
  if (SmallInt(Message.HitTest) = HTERROR) and (Message.MouseMsg = WM_LBUTTONDOWN) then
    DefaultHandler(Message)
  else inherited;
end;

procedure TfrmMain.WMQuizChange(var Message: TMessage);
begin
  //避免关闭时保存操作错误
  if not Assigned(App) then Exit;

  if App.RegType = rtNone then
    Caption := App.Caption + ' v' + Copy(App.Version, 1, 5)
  else if App.RegType = rtTrial then
    Caption := App.Caption + ' v' + Copy(App.Version, 1, 5) + ' (试用版)'
  else Caption := App.Caption + ' v' + Copy(App.Version, 1, 5) + ' (未注册版)';
  if FileExists(QuizObj.ProjPath) then Caption := Caption + ' - ' + ExtractFileName(QuizObj.ProjPath);

  case Message.WParam of
    QUIZ_RESET: if Pos(' *', Caption) <> 0 then Caption := StringReplace(Caption, ' *', '', []);
    QUIZ_CHANGED: if Pos(' *', Caption) = 0 then Caption := Caption + ' *';
  end;

  QuizObj.Changed := Message.WParam = QUIZ_CHANGED;
  if Message.LParam <> QUIZ_RESORT then
    UpdateStatus()
  else actSave.Enabled := QuizObj.Changed;
end;

procedure TfrmMain.WMDropFiles(var Message: TWMDropFiles);
var
  buf: array[0..MAX_PATH - 1] of Char;
  sExt: string;
  i, nCount: Integer;
begin
  nCount := DragQueryFile(Message.Drop, $FFFFFFFF, nil, 0);

  for i := 0 to nCount - 1 do
  begin
    DragQueryFile(Message.Drop, i, buf, MAX_PATH);
    sExt := LowerCase(ExtractFileExt(StrPas(buf)));
    if sExt = '.aqb' then
    begin
      ImportProj(StrPas(buf));
      Break;
    end
    else if (sExt = '.xls') or (sExt = '.xlsx') then
    begin
      ImportExcel(StrPas(buf));
      Break;
    end;
  end;
end;

procedure TfrmMain.WMOuterProj(var Message: TMessage);
var
  buf: array[0..MAX_PATH - 1] of Char;
begin
  GlobalGetAtomName(Message.LParam, buf, MAX_PATH);
  try
    //当有模式窗口打开时不加载
    if IsWindowEnabled(Handle) then ImportProj(StrPas(buf));
  finally
    GlobalDeleteAtom(Message.LParam);
  end;
end;

procedure TfrmMain.WMSysCommand(var Message: TWMSysCommand);
begin
  if Message.CmdType and $FFF0 = SC_MINIMIZE then
  begin
    Application.NormalizeTopMosts;
    DefWindowProc(Handle, WM_SYSCOMMAND, SC_MINIMIZE, 0);
  end
  //解决Win7下可多次执行的问题
  else if (Message.CmdType = SC_CLOSE) and IsWindowEnabled(Handle) then
    inherited
  else inherited;
end;

procedure TfrmMain.WMWindowPosChanging(var Message: TWMWindowPosChanging);
const
  CAdsorbSpace = 10;
begin
  inherited;
  with Message.WindowPos^ do
  begin
    if Abs(x) < CAdsorbSpace then x := 0;
    if Abs(y) < CAdsorbSpace then y := 0;
    if Abs(Screen.WorkAreaWidth - x - cx) < CAdsorbSpace then x := Screen.WorkAreaWidth - cx;
    if Abs(Screen.WorkAreaHeight - y - cy) < CAdsorbSpace then y := Screen.WorkAreaHeight - cy; 
  end;
end;

procedure TfrmMain.InitData;
begin
  FLastIndex := -1;
  //Quiz类所用变量设置
  InitQuizObj();
  //设置窗体状态
  WindowState := App.WindowState;
  actCount.Checked := App.ShowCount;
  tvQuiz.FullExpand();
  tvQuiz.Items.GetFirstNode.Selected := True;
  lvQues.ControlStyle := lvQues.ControlStyle - [csDisplayDragImage];
  if QuizObj.QuizSet.ShowIcon then
    lvQues.StateImages := ilQues
  else lvQues.StateImages := nil;
  actReg.Visible := App.RegType = rtUnReged;
  actBuy.Visible := App.RegType = rtTrial;

  //载入最近工程列表
  App.LoadRecentDocs(miFile, MenuItemClick);
end;

procedure TfrmMain.InitQuizObj;
begin
  QuizObj.Handle := Handle;
  QuizObj.ImageList := ilQuiz;
end;

procedure TfrmMain.SaveData;
begin
  //记录窗体状态
  App.WindowState := WindowState;
  App.ShowCount := actCount.Checked;
  //存工程入最近工程列表
  App.SaveRecentDocs();
end;

procedure TfrmMain.UpdateStatus;
begin
  with QuizObj, sbQuiz.Panels do
  begin
    Items[0].Text := '路径：' + ExtractFilePath(ProjPath);
    if QuizProp.TimeSet.Enabled then
      Items[1].Text := Format('时限：%d分%d秒', [QuizProp.TimeSet.Minutes, QuizProp.TimeSet.Seconds])
    else Items[1].Text := '时限：没有';
    Items[2].Text := Format('通过率：%d%%', [QuizProp.PassRate]);
    Items[3].Text := '总题数：' + IntToStr(QuesList.Count - GetQuesCount(qtScene));
  end;

  actSave.Enabled := QuizObj.Changed;
  actViewS.Enabled := (QuizObj.QuesList.Count <> 0) and (lvQues.Selected <> nil);
  actViewA.Enabled := QuizObj.QuesList.Count <> 0;
  tvQuiz.Items[0].Text := QuizObj.QuizProp.QuizTopic;
  DisplayItemCount();
end;

procedure TfrmMain.AppendData(AQuesObj: TQuesBase);
begin
  if not Assigned(AQuesObj) or (tvQuiz.Selected.Level = 1) and (TQuesType(tvQuiz.Selected.Index) <> AQuesObj._Type) then Exit;

  //ListView追加一条数据
  if lvQues.Selected <> nil then lvQues.Selected.Selected := False;
  with lvQues.Items.Add do
  begin
    if AQuesObj._Type <> qtScene then
    begin
      //场景题不计编号
      if tvQuiz.Selected.Level = 0 then
        Caption := IntToStr(lvQues.Items.Count - QuizObj.GetQuesCount(qtScene))
      else Caption := IntToStr(lvQues.Items.Count);
    end
    else Caption := '';
    SubItems.Append(AQuesObj.Topic);
    SubItems.Append(AQuesObj.TypeName);
    if AQuesObj._Type <> qtScene then
      SubItems.Append(FloatToStr(AQuesObj.Points))
    else SubItems.Append('');
    SubItems.Append(AQuesObj.LevelName);

    Selected := True;
    Focused := True;
    MakeVisible(True);
    //以Data记录对应试题
    Data := AQuesObj;
  end;

  sbQuiz.Panels.Items[3].Text := '总题数：' + IntToStr(QuizObj.QuesList.Count);
end;

procedure TfrmMain.AppendQues(AQuesObj: TQuesBase);
begin
  if not GetCanAdd(Handle) then Exit;

  if ShowQuesForm(lvQues, AQuesObj) then
    AppendData(AQuesObj)
  else AQuesObj.Free;
end;

procedure TfrmMain.LoadQueses;
var
  i, Count: Integer;
  QuesType: TQuesType;
  QuesObj: TQuesBase;
begin
  Screen.Cursor := crHourGlass;
  lvQues.Items.BeginUpdate;
  try
    lvQues.Items.Clear;
    QuesType := TQuesType(tvQuiz.Selected.Index);

    Count := 0;
    for i := 0 to QuizObj.QuesList.Count - 1 do
    begin
      QuesObj := QuizObj.QuesList.Items[i];
      if (tvQuiz.Selected.Level = 1) and (QuesObj._Type <> QuesType) then Continue;

      //追加指定类型试题
      with lvQues.Items.Add do
      begin
        if QuesObj._Type <> qtScene then
        begin
          Inc(Count);
          Caption := IntToStr(Count);
        end
        else Caption := '';
        SubItems.Append(QuesObj.Topic);
        SubItems.Append(QuesObj.TypeName);
        if QuesObj._Type <> qtScene then
          SubItems.Append(FloatToStr(QuesObj.Points))
        else SubItems.Append('');
        SubItems.Append(QuesObj.LevelName);

        Data := QuesObj;
      end;
    end;

    if lvQues.Items.Count <> 0 then lvQues.Items[0].Selected := True;
  finally
    lvQues.Items.EndUpdate;
    Screen.Cursor := crDefault;
  end;
end;

procedure TfrmMain.ResortQueses;
var
  i, iCur: Integer;
begin
  //重定义Index
  QuizObj.QuesList.Resort();
  if lvQues.Items.Count <> 0 then
  begin
    iCur := 0;
    for i := 0 to lvQues.Items.Count - 1 do
    begin
      if TQuesObj(lvQues.Items[i].Data)._Type = qtScene then Continue;
      Inc(iCur);
      lvQues.Items[i].Caption := IntToStr(iCur);
    end;
  end;

  //发送已更新消息
  PostMessage(QuizObj.Handle, WM_QUIZCHANGE, QUIZ_CHANGED, 0);
end;

procedure TfrmMain.MenuItemClick(Sender: TObject);
begin
  ImportProj(TMenuItem(Sender).Caption);
end;

procedure TfrmMain.ImportProj(const AProjName: string);
begin
  if not GetCanResume() or (ExtractFileExt(AProjName) <> '.aqb') then Exit;

  if QuizObj.LoadProj(AProjName) then
  begin
    tvQuiz.TopItem.Selected := True;
    LoadQueses();
    PostMessage(Handle, WM_QUIZCHANGE, QUIZ_RESET, 0);

    //先存当前工程入列表
    App.SaveRecentDocs();
    //载入工程新顺序
    App.LoadRecentDocs(miFile, MenuItemClick);
  end;
end;

procedure TfrmMain.AppendProj(const AProjName: string);
begin
  //if AProjName = QuizObj.ProjPath then Exit;

  if QuizObj.AppendProj(AProjName) then
  begin
    tvQuiz.TopItem.Selected := True;
    LoadQueses();
    PostMessage(Handle, WM_QUIZCHANGE, QUIZ_CHANGED, 0);
  end;
end;

procedure TfrmMain.ImportExcel(const AXlsName: string);
begin
  if Assigned(QuizObj) then FreeAndNil(QuizObj);

  QuizObj := TQuizObj.Create;
  InitQuizObj();
  if QuizObj.LoadExcel(AXlsName) then
  begin
    tvQuiz.TopItem.Selected := True;
    LoadQueses();
    PostMessage(Handle, WM_QUIZCHANGE, QUIZ_CHANGED, 0);
  end;
end;

procedure TfrmMain.NewProj;
begin
  if Assigned(QuizObj) then FreeAndNil(QuizObj);

  QuizObj := TQuizObj.Create;
  InitQuizObj();
  tvQuiz.FullExpand();
  lvQues.Items.Clear;
  PostMessage(Handle, WM_QUIZCHANGE, QUIZ_RESET, 0);
end;

function TfrmMain.GetCanResume: Boolean;
begin
  Result := True;

  if QuizObj.Changed and (FileExists(QuizObj.ProjPath) or (QuizObj.QuesList.Count <> 0)) then
  begin
    case MessageBox(Handle, '试题已被修改，您要保存吗？', '提示', MB_YESNOCANCEL + MB_ICONQUESTION) of
      ID_YES: Result := QuizObj.SaveProj;
      ID_NO: Result := True;
      ID_CANCEL: Result := False;
    end;
  end;
end;

procedure TfrmMain.ResizeListView;
begin
  with lvQues.Columns do
    Items[1].Width := lvQues.Width - Items[0].Width - Items[2].Width - Items[3].Width - Items[4].Width - 21;
end;

procedure TfrmMain.DisplayItemCount;
var
  i: Integer;
  Root: TTreeNode;
begin
  Root := tvQuiz.TopItem;

  if actCount.Checked then
  begin
    Root.Text := QuizObj.QuizProp.QuizTopic + ' [' + IntToStr(QuizObj.QuesList.Count) + ']';
    for i := 0 to Root.Count - 1 do
      Root.Item[i].Text := QuizObj.GetTypeName(TQuesType(i)) + ' [' + IntToStr(QuizObj.GetQuesCount(TQuesType(i))) + ']';
  end
  else
  begin
    Root.Text := QuizObj.QuizProp.QuizTopic;
    for i := 0 to Root.Count - 1 do
      Root.Item[i].Text := QuizObj.GetTypeName(TQuesType(i));
  end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  sExt: string;
begin
  DoubleBuffered := True;
  DragAcceptFiles(Handle, True);
  //显示全菜单
  //以下两句，顺序且不可变
  SetWindowLong(Handle, GWL_HWNDPARENT, HWND_DESKTOP);
  SetWindowLong(Application.Handle, GWL_HWNDPARENT, Handle);

  InitData();
  UpdateStatus();

  //直接打开.aqb&鼠标拖入等操作
  if (ParamCount > 0) and FileExists(ParamStr(1)) then
  begin
    sExt := LowerCase(ExtractFileExt(ParamStr(1)));
    if sExt = '.aqb' then
      ImportProj(ParamStr(1))
    else if Pos(sExt, '.xlsx') = 1 then
      ImportExcel(ParamStr(1));
  end
  else PostMessage(Handle, WM_QUIZCHANGE, QUIZ_RESET, 0);
end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveData();
  DragAcceptFiles(Handle, False);
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := GetCanResume();
end;

procedure TfrmMain.actNewExecute(Sender: TObject);
begin
  if GetCanResume() then NewProj();
end;

procedure TfrmMain.actOpenExecute(Sender: TObject);
var
  od: TOpenDialog;
begin
  od := TOpenDialog.Create(Self);
  od.Filter := sAqbFiler;
  od.Options := od.Options + [ofFileMustExist];

  try
    if od.Execute then ImportProj(od.FileName);
  finally
    od.Free;
  end;
end;

procedure TfrmMain.actAppendExecute(Sender: TObject);
var
  od: TOpenDialog;
begin
  od := TOpenDialog.Create(Self);
  od.Filter := sAqbFiler;
  od.Title := '请选择您要追加到当前工程的试题工程文件';
  od.Options := od.Options + [ofFileMustExist];

  try
    if od.Execute then AppendProj(od.FileName);
  finally
    od.Free;
  end;
end;

procedure TfrmMain.actImportExecute(Sender: TObject);
var
  od: TOpenDialog;
begin
  od := TOpenDialog.Create(Self);
  od.Filter := sXlsFilter;
  od.Title := '请选择您要导入的Excel文件';
  od.Options := od.Options + [ofFileMustExist];

  Screen.Cursor := crHourGlass;
  try
    if od.Execute then ImportExcel(od.FileName);
  finally
    Screen.Cursor := crDefault;
    od.Free;
  end;
end;

procedure TfrmMain.actSaveExecute(Sender: TObject);
begin
  QuizObj.SaveProj();
end;

procedure TfrmMain.actSaveAsExecute(Sender: TObject);
begin
  QuizObj.SaveProjAs();
end;

procedure TfrmMain.actExitExecute(Sender: TObject);
begin
  Close();
end;

procedure TfrmMain.actPropExecute(Sender: TObject);
begin
  ShowProp(QuizObj.QuizProp);
end;

procedure TfrmMain.actPlayerExecute(Sender: TObject);
begin
  ShowPlayer(QuizObj.Player);
end;

procedure TfrmMain.actSetExecute(Sender: TObject);
begin
  if ShowParam(QuizObj.QuizSet) then
  begin
    if QuizObj.QuizSet.ShowIcon then
      lvQues.StateImages := ilQues
    else lvQues.StateImages := nil;
  end;
end;

procedure TfrmMain.actJudgeExecute(Sender: TObject);
begin
  AppendQues(TQuesObj.Create(qtJudge));
end;

procedure TfrmMain.actSingleExecute(Sender: TObject);
begin
  AppendQues(TQuesObj.Create(qtSingle));
end;

procedure TfrmMain.actMultiExecute(Sender: TObject);
begin
  AppendQues(TQuesObj.Create(qtMulti));
end;

procedure TfrmMain.actBlankExecute(Sender: TObject);
begin
  AppendQues(TQuesObj.Create(qtBlank));
end;

procedure TfrmMain.actMatchExecute(Sender: TObject);
begin
  AppendQues(TQuesObj.Create(qtMatch));
end;

procedure TfrmMain.actSequeExecute(Sender: TObject);
begin
  AppendQues(TQuesObj.Create(qtSeque));
end;

procedure TfrmMain.actHotspotExecute(Sender: TObject);
begin
  AppendQues(TQuesHot.Create(qtHotspot));
end;

procedure TfrmMain.actEssayExecute(Sender: TObject);
begin
  AppendQues(TQuesObj.Create(qtEssay));
end;

procedure TfrmMain.actSceneExecute(Sender: TObject);
begin
  AppendQues(TQuesObj.Create(qtScene));
end;

procedure TfrmMain.actViewSExecute(Sender: TObject);
begin
  QuizObj.Publish.Preview(TQuesBase(lvQues.Selected.Data));
end;

//回调显示进度
procedure DisProgress(ACurPos, AMaxPos: Integer); stdcall;
begin
  with frmProgress do
  begin
    lblDis.Caption := '试题生成中…… ' + FormatFloat('#%', ACurPos * 100 / AMaxPos);
    pbDis.Position := Round(ACurPos * 100 / AMaxPos);
    Update;
  end;
end;

procedure TfrmMain.actViewAExecute(Sender: TObject);
begin
  if not Assigned(frmProgress) then frmProgress := TfrmProgress.Create(Self);
  frmProgress.Show;
  EnableWindow(Handle, False);
  actViewA.Enabled := False;
  //使上句生效
  Update;
  //试题生成开始...
  QuizObj.Publish.DisProgress := DisProgress;
  QuizObj.Publish.Preview();
  actViewA.Enabled := True;
  frmProgress.Hide;
  frmProgress.Update;
  //此句作用使主窗口直到进度窗口hide后才能用
  Application.ProcessMessages;
  EnableWindow(Handle, True);
end;

procedure TfrmMain.actPubExecute(Sender: TObject);
begin
  ShowPublish(QuizObj.Publish, QuizObj.Publish.PubType);
end;

procedure TfrmMain.actWebExecute(Sender: TObject);
begin
  ShowPublish(QuizObj.Publish, ptWeb);
end;

procedure TfrmMain.actLmsExecute(Sender: TObject);
begin
  ShowPublish(QuizObj.Publish, ptLms);
end;

procedure TfrmMain.actWordExecute(Sender: TObject);
begin
  ShowPublish(QuizObj.Publish, ptWord);
end;

procedure TfrmMain.actExcelExecute(Sender: TObject);
begin
  ShowPublish(QuizObj.Publish, ptExcel);
end;

procedure TfrmMain.actExeExecute(Sender: TObject);
begin
  ShowPublish(QuizObj.Publish, ptExe);
end;

procedure TfrmMain.actHelpExecute(Sender: TObject);
begin
  HtmlHelp(Application.Handle, App.Path + 'help.chm::/welcome.html' + '', HH_DISPLAY_TOPIC, 0);
end;

procedure TfrmMain.actUrlExecute(Sender: TObject);
begin
  ShellExecute(Handle, 'open', PAnsiChar(AW_HOMEPAGE), nil, nil, SW_SHOW);
end;

procedure TfrmMain.actQQExecute(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'tencent://message/?uin=7515933&Site=www.awindsoft.net&Menu=yes', nil, nil, SW_SHOW);
end;

procedure TfrmMain.actRegExecute(Sender: TObject);
begin
  ShowReg();
end;

procedure TfrmMain.actBuyExecute(Sender: TObject);
begin
  ShellExecute(Handle, 'open', PAnsiChar(AW_HOMEPAGE + '/order.asp?pid=0&ver=' + App.Version), nil, nil, SW_SHOW);
end;

procedure TfrmMain.actAboutExecute(Sender: TObject);
begin
  ShowAbout();
end;

procedure TfrmMain.actDelExecute(Sender: TObject);
var
  i: Integer;
  DelIds: string;
  ListItem: TListItem;
begin
  if (lvQues.SelCount = 0) or ((lvQues.SelCount > 1) and (MessageBox(Handle, '确认要删除所选择的试题吗？', '提示', MB_YESNO + MB_ICONQUESTION) = ID_NO)) then Exit;

  //删除对应试题
  DelIds := ',';
  //因为Data所指向的题不是对象关联，彼Index更新此不更新，所以不在循环中删除
  for i := 0 to lvQues.Items.Count - 1 do
  begin
    ListItem := lvQues.Items[i];
    if ListItem.Selected then
      DelIds := DelIds + IntToStr(TQuesBase(ListItem.Data).Index) + ',';
  end;
  for i := QuizObj.QuesList.Count - 1 downto 0 do
    if Pos(',' + IntToStr(i + 1) + ',', DelIds) <> 0 then QuizObj.QuesList.Delete(i);

  lvQues.DeleteSelected;
  ResortQueses();
  if lvQues.ItemFocused <> nil then lvQues.ItemFocused.Selected := True;
end;

procedure TfrmMain.actSelExecute(Sender: TObject);
begin
  lvQues.SelectAll;
end;

procedure TfrmMain.actDupExecute(Sender: TObject);
var
  i: Integer;
  SrcQues, TarQues: TQuesBase;
begin
  if lvQues.SelCount = 0 then Exit;

  for i := 0 to lvQues.Items.Count - 1 do
  begin
    if not lvQues.Items[i].Selected then Continue;
    if not GetCanAdd(Handle) then Break;

    //追加QuesList列表
    SrcQues := TQuesBase(lvQues.Items[i].Data);
    if SrcQues._Type <> qtHotSpot then
      TarQues := TQuesObj.Create(SrcQues._Type)
    else TarQues := TQuesHot.Create(SrcQues._Type);
    TarQues.Assign(SrcQues);
    TarQues.Index := QuizObj.QuesList.Count;
    QuizObj.QuesList.Append(TarQues);

    with lvQues.Items.Add do
    begin
      Assign(lvQues.Items[i]);
      Data := TarQues;
      Caption := IntToStr(lvQues.Items.Count);
    end;
  end;

  ResortQueses();
end;

procedure TfrmMain.actInfoExecute(Sender: TObject);
var
  QuesObj: TQuesBase;
begin
  if (lvQues.Items.Count = 0) or (lvQues.Selected = nil) then Exit;

  QuesObj := TQuesBase(lvQues.Selected.Data);
  if ShowQuesForm(lvQues, QuesObj) then lvQues.OnClick(lvQues);
end;

procedure TfrmMain.actClearExecute(Sender: TObject);
var
  i: Integer;
begin
  if (lvQues.SelCount = 0) or (MessageBox(Handle, PAnsiChar('确认要' + actClear.Caption + '吗?'), '提示', MB_YESNO + MB_ICONQUESTION) = ID_NO) then Exit;

  for i := QuizObj.QuesList.Count - 1 downto 0 do
    if (tvQuiz.Selected.Level = 0) or (QuizObj.QuesList.Items[i]._Type = TQuesType(tvQuiz.Selected.Index)) then
      QuizObj.QuesList.Delete(i);
  lvQues.Items.Clear;
  
  ResortQueses();
end;

procedure TfrmMain.actAddExecute(Sender: TObject);
begin
  tvQuiz.OnDblClick(tvQuiz);
end;

procedure TfrmMain.actCountExecute(Sender: TObject);
begin
  actCount.Checked := not actCount.Checked;
  DisplayItemCount();
end;

procedure TfrmMain.actChartExecute(Sender: TObject);
begin
  ShowChart(tvQuiz);
end;

procedure TfrmMain.FormResize(Sender: TObject);
begin
  sbQuiz.Panels[0].Width := Width - 350;
  ResizeListView;
end;

procedure TfrmMain.FormShortCut(var Msg: TWMKey; var Handled: Boolean);
begin
  case Msg.CharCode of
    VK_RETURN:
    begin
      if ActiveControl = tvQuiz then
        tvQuiz.OnDblClick(tvQuiz)
      else if ActiveControl = lvQues then
        lvQues.OnDblClick(lvQues);
      Handled := True;
    end;
    VK_ESCAPE:
    begin
      actExit.OnExecute(actExit);
      Handled := True;
    end;
  end;
end;

procedure TfrmMain.spQuizCanResize(Sender: TObject; var NewSize: Integer;
  var Accept: Boolean);
begin
  Accept := NewSize <= 175;
end;

procedure TfrmMain.spQuizMoved(Sender: TObject);
begin
  ResizeListView
end;

procedure TfrmMain.tvQuizChange(Sender: TObject; Node: TTreeNode);
begin
  LoadQueses();
end;

procedure TfrmMain.tvQuizDblClick(Sender: TObject);
begin
  if (tvQuiz.Selected = nil) or (tvQuiz.Selected.Level = 0) then Exit;

  if tvQuiz.Selected.Index <> Ord(qtHotSpot) then
    AppendQues(TQuesObj.Create(TQuesType(tvQuiz.Selected.Index)))
  else AppendQues(TQuesHot.Create(TQuesType(tvQuiz.Selected.Index)));
end;

procedure TfrmMain.tvQuizMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Node: TTreeNode;
begin
  if Button = mbRight then
  begin
    Node := tvQuiz.GetNodeAt(X, Y);
    if Node <> nil then tvQuiz.Selected := Node;
  end;
end;

procedure TfrmMain.lvQuesClick(Sender: TObject);
begin
  if (lvQues.Selected = nil) and (lvQues.Items.Count <> 0) and (FLastIndex <= lvQues.Items.Count - 1) and (FLastIndex <> -1) then
  begin
    lvQues.ItemIndex := FLastIndex;
    lvQues.Selected.Focused := True;
  end;
end;

procedure TfrmMain.lvQuesCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  if Odd(Item.Index) then lvQues.Canvas.Brush.Color := $00EFE5E5;
  if Assigned(Item.Data) and (TQuesBase(Item.Data)._Type = qtHotSpot) and not FileExists(TQuesHot(Item.Data).HotImage) then
    lvQues.Canvas.Brush.Color := $000066FF;
  if Assigned(Item.Data) and (TQuesBase(Item.Data)._Type = qtScene) then
  begin
    lvQues.Canvas.Brush.Color := $00FFBEBE;
    lvQues.Canvas.Font.Color := $000066FF;
  end;
end;

procedure TfrmMain.lvQuesDblClick(Sender: TObject);
begin
  if lvQues.Selected = nil then lvQues.OnClick(lvQues);
  actInfo.OnExecute(actInfo);
end;

procedure TfrmMain.lvQuesDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  //只能处理选一个ListItem的
  Accept := lvQues.SelCount = 1;
end;

procedure TfrmMain.lvQuesDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  ListItem: TListItem;
  CurIndex, NewIndex: Integer;
begin
  if lvQues.DropTarget = nil then Exit;

  ListItem := lvQues.Items.Insert(lvQues.DropTarget.Index);
  ListItem.Assign(lvQues.Selected);
  //重排QuesList顺序；它分根据不同的移动方向改变
  CurIndex := TQuesBase(ListItem.Data).Index - 1;
  NewIndex := TQuesBase(lvQues.DropTarget.Data).Index - 1;
  if CurIndex < NewIndex then Dec(NewIndex);
  QuizObj.QuesList.Move(CurIndex, NewIndex);

  Windows.LockWindowUpdate(Handle);
  try
    //删除原ListItem
    lvQues.Selected.Delete;
    //使其选择
    ListItem.Selected := True;
    //去除虚框
    ListItem.Focused := True;
  finally
    Windows.LockWindowUpdate(0);
  end;      

  ResortQueses();
end;

procedure TfrmMain.lvQuesGetImageIndex(Sender: TObject; Item: TListItem);
begin
  if lvQues.StateImages <> nil then Item.StateIndex := Ord(TQuesBase(Item.Data)._Type);
end;

procedure TfrmMain.lvQuesSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  FLastIndex := Item.Index;
end;

procedure TfrmMain.pmTreePopup(Sender: TObject);
var
  Node: TTreeNode;
begin
  Node := tvQuiz.Selected;

  if Node <> nil then
  begin
    actAdd.Enabled := Node.Level <> 0;

    if Node.Level = 0 then
    begin
      actAdd.ImageIndex := -1;
      actAdd.Caption := '添加一个试题';
      actClear.Caption := '清除所有试题';
      actClear.Enabled := QuizObj.QuesList.Count <> 0;
    end
    else
    begin
      actAdd.ImageIndex := Node.Index + 8;
      actAdd.Caption := '添加[' + Node.Text + ']...';
      //有时actAdd之Caption不能即时起效
      miAdd.Caption := actAdd.Caption;
      actClear.Caption := '清除[' + Node.Text + ']';
      actClear.Enabled := QuizObj.GetQuesCount(TQuesType(Node.Index)) <> 0;
    end;
  end;
end;

procedure TfrmMain.pmEditPopup(Sender: TObject);
begin
  if lvQues.Selected = nil then lvQues.OnClick(lvQues);

  actViewS.Enabled := (lvQues.Items.Count <> 0) and (lvQues.Selected <> nil);
  actDel.Enabled := actViewS.Enabled;
  actSel.Enabled := lvQues.Items.Count <> 0;
  actDup.Enabled := actViewS.Enabled;
  actInfo.Enabled := actViewS.Enabled;
end;

procedure TfrmMain.miViewClick(Sender: TObject);
begin
  actViewS.Enabled := (QuizObj.QuesList.Count <> 0) and (lvQues.Selected <> nil);
  actViewA.Enabled := QuizObj.QuesList.Count <> 0;
end;

end.

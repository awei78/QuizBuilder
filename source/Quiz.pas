{
  文件名：Quiz.pas
  说  明：题类与工程管理类
  编写人：刘景威                                                                                            
  日  期：2007-05-19
  更  新：2008-06-21，解决在编译ActionScript时对"处理的错误，用\"来代替"解决
          2009-03-06，工程文件改为打包处理，把资源文件放入工程文件中
}

unit Quiz;

interface

uses
  Windows, Messages, Classes, Controls, SysUtils, Variants, Graphics, Forms,
  Dialogs, Registry, ShellAPI, FlashObjects, SWFConst, ComObj, ExcelXP, XMLDoc, XMLIntf;

const
  //注册表存储键名
  QUIZ_KEY_NAME = 'Software\QuizBuilder';
  //预览文件名...发现一个奇怪现象：若文件名为view.swf，则不勾选[允许测试者改变传入的用户帐号]不起作用
  QUIZ_PREVIEW  = 'quiz_view.swf';
  T_BACK_IMAGE  = 'img_back.jpg';
  WM_QUIZCHANGE = WM_USER + 201;
  WM_OUTERPROJ  = WM_USER + 202;
  QUIZ_RESET    = 0;
  QUIZ_CHANGED  = 1;
  QUIZ_RESORT   = 2;
  //菜中最多工程数量
  QUIZ_MAX_LIST = 3;

type
  //显示进度信息之回调函数原型
  TDisProgress = procedure(ACurPos, AMaxPos: Integer); stdcall;
  //注意：以记录类型作为类成员，赋值时得创建一记录赋值，而不能直接赋记录中成员值；或者把其上组用with处理
  //反馈信息
  TFeedInfo = record
    Enabled: Boolean;
    CrtInfo: string;
    ErrInfo: string;
  end;
  //字体设置
  TFontSet = record
    Size: Integer;
    Color: TColor;
    Bold: Boolean;
  end;
  //试题设置类...
  //试题声音
  TQuesAudio = record
    FileName: string;
    AutoPlay: Boolean;
    LoopCount: Integer;
  end;                                                                                    //场景
  TQuesType = (qtJudge, qtSingle, qtMulti, qtBlank, qtMatch, qtSeque, qtHotSpot, qtEssay, qtScene);
  //试题难度
  TQuesLevel = (qlEasy, qlPrimary, qlMiddle, qlDiffic, qlHard, qlEssay, qlScene);

  //试题基类
  TQuesBase = class
  private
    FIndex: Integer;
    FTopic: string;
    FAudio: TQuesAudio;
    FType: TQuesType;
    //单选题-答案级反馈
    FFeedAns: Boolean;
    FPoints: Double;
    FAttempts: Integer;
    FLevel: TQuesLevel;
    FImage: string;
    FFeedInfo: TFeedInfo;

    procedure LoadData;
    procedure SetTopic(Value: string);
    function GetTypeName: string;
    function GetLevelName: string;
  public
    constructor Create(AQuesType: TQuesType = qtJudge); virtual;
    destructor Destroy; override;
    procedure Assign(Source: TQuesBase); virtual;
    //为单选题答案级反馈而设
    function GetAnswer(const AAnsStr: string): string;
    function GetFeedback(const AAnsStr: string): string;

    property Index: Integer read FIndex write FIndex;
    property Topic: string read FTopic write SetTopic;
    property Audio: TQuesAudio read FAudio write FAudio;
    property _Type: TQuesType read FType;
    property TypeName: string read GetTypeName;
    property FeedAns: Boolean read FFeedAns write FFeedAns;
    property Points: Double read FPoints write FPoints;
    property Attempts: Integer read FAttempts write FAttempts;
    property Level: TQuesLevel read FLevel write FLevel;
    property LevelName: string read GetLevelName;
    property Image: string read FImage write FImage;
    property FeedInfo: TFeedInfo read FFeedInfo write FFeedInfo;
  end;

  //非热区题
  TQuesObj = class(TQuesBase)
  private
    //以此形式记录答案
    FAnswers: TStrings;
  public
    constructor Create(AQuesType: TQuesType = qtJudge); override;
    destructor Destroy; override;
    procedure Assign(Source: TQuesBase); override;

    property Answers: TStrings read FAnswers write FAnswers;
  end;

  //热区题
  TQuesHot = class(TQuesBase)
  private
    FHotImage: string;
    FHPos: Integer;
    FVPos: Integer;                              
    FHotRect: TRect;
    FImgFit: Boolean;                                                                                    
  public
    procedure Assign(Source: TQuesBase); override;

    property HotImage: string read FHotImage write FHotImage;
    property HPos: Integer read FHPos write FHPos;
    property VPos: Integer read FVPos write FVPos;
    property HotRect: TRect read FHotRect write FHotRect;
    property ImgFit: Boolean read FImgFit write FImgFit;
  end;

  //题目列表
  TQuesList = class(TList)
  private
    //是否有Topic相同的题
    function GetSameItem: Boolean;
    function GetTotalPoint: Double;
  protected
    function Get(Index: Integer): TQuesBase;
    procedure Put(Index: Integer; Item: TQuesBase);
  public
    constructor Create;
    destructor Destroy; override;

    function Add(Item: TQuesBase): Integer;
    procedure Append(Item: TQuesBase);
    procedure Clear; override;
    //重排Index次序
    procedure Resort;
    //属性...
    property Items[Index: Integer]: TQuesBase read Get write Put; default;
    property HasSameItem: Boolean read GetSameItem;
    property TotalPoint: Double read GetTotalPoint;
  end;

  //工程类设置开始处...
  TQuizProp = class;
  TPlayer   = class;
  TQuizSet  = class;                                                             
  TPublish  = class;
  //工程管理类
  TQuizObj = class
  private
    //工程路径
    FProjPath: string;
    //其中xml配置文件
    FProjFile: string;
    FProjDir: string;
    //主窗口句柄
    FHandle: HWND;
    FChanged: Boolean;
    FQuizProp: TQuizProp;
    FPlayer: TPlayer;
    FQuizSet: TQuizSet;
    FPublish: TPublish;
    FQuesList: TQuesList;
    //为追加计，从LoadData中拆分
    function LoadQues(AQuesNode: IXMLNode; AAppend: Boolean = False): Boolean;
    function LoadData: Boolean;
    function SaveData: Boolean;
    function IsXMLDoc(const AXMLFile: string): Boolean;
    function PackProj(AXML: IXMLDocument): Boolean;
    function ExtendProj(const AProjPath: string): Boolean;
  public
    ImageList: TImageList;
    constructor Create;
    destructor Destroy; override;
    //加载工程
    function LoadProj(const AProjPath: string): Boolean;
    //追加工程
    function AppendProj(const AProjPath: string): Boolean;
    //加载Excel
    function LoadExcel(const AXlsName: string): Boolean;
    //保存工程
    function SaveProj: Boolean;
    //另存工程
    function SaveProjAs: Boolean;
    //获取指定类型名
    function GetTypeName(AQuesType: TQuesType): string;
    //由类型名获取类型
    function GetTypeFromName(const ATypeName: string): TQuesType;
    //获取指定类型题数
    function GetQuesCount(AQuesType: TQuesType): Integer;

    property ProjPath: string read FProjPath;
    property ProjDir: string read FProjDir;
    property Handle: HWND read FHandle write FHandle;
    property Changed: Boolean read FChanged write FChanged;
    //其它设置
    property QuizProp: TQuizProp read FQuizProp write FQuizProp;
    property Player: TPlayer read FPlayer write FPlayer;
    property QuizSet: TQuizSet read FQuizSet write FQuizSet;
    property Publish: TPublish read FPublish write FPublish;
    property QuesList: TQuesList read FQuesList write FQuesList;
  end;

  //Quiz属性设置类相关...
  TSubmitType = (stOnce, stAll);
  //时限
  TTimeSet = record
    Enabled: Boolean;
    Minutes: Integer;
    Seconds: Integer;
  end;
  //随机出题
  TRndType = (rtQuiz, rtType);
  TTypeCount = record
    Judge: Integer;
    Single: Integer;
    Multi: Integer;
    Blank: Integer;
    Match: Integer;
    Seque: Integer;
    HotSpot: Integer;
    Essay: Integer;
  end;
  TRndQues = record
    Enabled: Boolean;
    RndType: TRndType;
    Count: Integer;
    //分题型
    TypeCount: TTypeCount;
    RunTime: Boolean;
  end;
  TPostType = (ptManual, ptAuto);
  //发送网络数据库
  TPostSet = record
    Enabled: Boolean;
    Url: string;
    _Type: TPostType;
  end;
  //邮件发送设置
  TMailSet = record
    Enabled: Boolean;
    MailAddr: string;
    MailUrl: string;
    _Type: TPostType;
  end;
  //测试结束操作
  TQuitType = (qtClose, qtGotoUrl);
  TQuitOper = record
    PassType: TQuitType;
    PassUrl: string;
    FailType: TQuitType;
    FailUrl: string;
  end;
  TPassSet = record
    Enabled: Boolean;
    PassInfo: string;
    FailInfo: string;
  end;
  //密码保护
  TPwdType = (pstPwd, pstWeb);
  TPwdSet = record
    Enabled: Boolean;
    _Type: TPwdType;
    Password: string;
    Url: string;
    AllowChangeUserId: Boolean;
  end;
  //网页验证
  TUrlLimit = record
    Enabled: Boolean;
    Url: string;
  end;
  //日期限制
  TDateLimit = record
    Enabled: Boolean;
    StartDate: TDate;
    EndDate: TDate;
  end;
  //属性类
  TQuizProp = class
  private
    //试题信息
    FQuizTopic: string;
    FQuizID: string;
    FShowInfo: Boolean;
    FQuizInfo: string;
    FQuizImage: string;
    FShowName: Boolean;
    FShowMail: Boolean;
    FBlankName: Boolean;
    //试题设置
    FSubmitType: TSubmitType;
    FPassRate: Integer;
    FTimeSet: TTimeSet;
    FRndQues: TRndQues;
    FShowQuesNo: Boolean;
    FRndAnswer: Boolean;
    FShowAnswer: Boolean;
    FViewQuiz: Boolean;
    //结果设置
    FPassSet: TPassSet;
    FPostSet: TPostSet;
    FMailSet: TMailSet;
    FQuitOper: TQuitOper;
    //试题保护
    FPwdSet: TPwdSet;
    FUrlLimit: TUrlLimit;
    FDateLimit: TDateLimit;

    FRegistry: TRegistry;
    //记录标签页
    FPageIndex: Integer;
    procedure InitData;
    //从注册表加载
    procedure LoadFromReg;
  public
    constructor Create;
    destructor Destroy; override;

    //保存到注册表
    procedure SaveToReg;
    //试题信息
    property QuizTopic: string read FQuizTopic write FQuizTopic;
    property QuizID: string read FQuizID write FQuizID;
    property ShowInfo: Boolean read FShowInfo write FShowInfo;
    property QuizInfo: string read FQuizInfo write FQuizInfo;
    property QuizImage: string read FQuizImage write FQuizImage;
    property ShowName: Boolean read FShowName write FShowName;
    property ShowMail: Boolean read FShowMail write FShowMail;
    property BlankName: Boolean read FBlankName write FBlankName;
    //试题设置
    property SubmitType: TSubmitType read FSubmitType write FSubmitType;
    property PassRate: Integer read FPassRate write FPassRate;
    property TimeSet: TTimeSet read FTimeSet write FTimeSet;
    property RndQues: TRndQues read FRndQues write FRndQues;
    property ShowQuesNo: Boolean read FShowQuesNo write FShowQuesNo;
    property RndAnswer: Boolean read FRndAnswer write FRndAnswer;
    property ShowAnswer: Boolean read FShowAnswer write FShowAnswer;
    property ViewQuiz: Boolean read FViewQuiz write FViewQuiz;
    //结果设置
    property PassSet: TPassSet read FPassSet write FPassSet;
    property PostSet: TPostSet read FPostSet write FPostSet;
    property MailSet: TMailSet read FMailSet write FMailSet;
    property QuitOper: TQuitOper read FQuitOper write FQuitOper;
    //试题保护
    property PwdSet: TPwdSet read FPwdSet write FPwdSet;
    property UrlLimit: TUrlLimit read FUrlLimit write FUrlLimit;
    property DateLimit: TDateLimit read FDateLimit write FDateLimit;

    property PageIndex: Integer read FPageIndex write FPageIndex;
  end;

  //Quiz参数设置类
  TQuizSet = class
  private
    FFontSetT: TFontSet;
    FFontSetA: TFontSet;
    FPoints: Byte;
    FAttempts: Byte;
    FQuesLevel: TQuesLevel;
    FFeedInfo: TFeedInfo;
    FShowIcon: Boolean;
    FSetAudio: Boolean;
    FShowSplash: Boolean;

    FRegistry: TRegistry;
    procedure LoadFromReg;
    procedure InitData;
  public
    constructor Create;
    destructor Destroy; override;
    procedure SaveToReg;

    property FontSetT: TFontSet read FFontSetT write FFontSetT;
    property FontSetA: TFontSet read FFontSetA write FFontSetA;
    property Points: Byte read FPoints write FPoints;
    property Attempts: Byte read FAttempts write FAttempts;
    property QuesLevel: TQuesLevel read FQuesLevel write FQuesLevel;
    property FeedInfo: TFeedInfo read FFeedInfo write FFeedInfo;
    property ShowIcon: Boolean read FShowIcon write FShowIcon;
    property SetAudio: Boolean read FSetAudio write FSetAudio;
    property ShowSplash: Boolean read FShowSplash write FShowSplash;
  end;
  
  //播放器设置类...
  //播放器
  TPlayerSet = record
    ShowTopic: Boolean;
    ShowTitle: Boolean;
    ShowTime: Boolean;
    ShowType: Boolean;
    ShowPoint: Boolean;
    ShowLevel: Boolean;
    ShowTool: Boolean;
    ShowData: Boolean;
    ShowMail: Boolean;
    ShowAudio: Boolean;
    ShowAuthor: Boolean;
    ShowPrev: Boolean;
    ShowNext: Boolean;
    ShowList: Boolean;
  end;
  //颜色
  TBackImage = record
    Enabled: Boolean;
    Image: string;
    Alpha: Integer;
  end;
  TColorSet = record
    BackColor: TColor;
    TitleColor: TColor;
    BarColor: TColor;
    CrtColor: TColor;
    ErrColor: TColor;
    BackImage: TBackImage;
  end;
  //背景声音
  TBackSound = record
    Enabled: Boolean;
    SndFile: string;
    LoopPlay: Boolean;
  end;
  //事件声音
  TEventSound = record
    Enabled: Boolean;
    SndCrt: string;
    SndErr: string;
    SndTry: string;
    SndPass: string;
    SndFail: string;
  end;
  //作者信息
  TAuthorSet = record
    Name: string;
    Mail: string;
    Url: string;
    Des: string;
  end;
  //水印
  TWaterMark = record
    Enabled: Boolean;
    Text: string;
    Link: string;
  end;
  TPlayer = class
  private
    FPlayerSet: TPlayerSet;
    FColorSet: TColorSet;
    FBackSound: TBackSound;
    FEventSound: TEventSound;
    FAuthorSet: TAuthorSet;
    FWaterMark: TWaterMark;
    FTexts: TStrings;

    FRegistry: TRegistry;
    FPageIndex: Integer;
    procedure LoadFromReg;
    procedure InitData;
  public
    constructor Create;
    destructor Destroy; override;
    function GetTexts: string;
    procedure SaveToReg;

    property PlayerSet: TPlayerSet read FPlayerSet write FPlayerSet;
    property ColorSet: TColorSet read FColorSet write FColorSet;
    property BackSound: TBackSound read FBackSound write FBackSound;
    property EventSound: TEventSound read FEventSound write FEventSound;
    property AuthorSet: TAuthorSet read FAuthorSet write FAuthorSet;
    property WaterMark: TWaterMark read FWaterMark write FWaterMark;
    property Texts: TStrings read FTexts write FTexts;
    property PageIndex: Integer read FPageIndex write FPageIndex;
  end;

  //发布设置类
  TPubType = (ptWeb, ptLms, ptWord, ptExcel, ptExe);
  TLmsVer = (lv12, lv2004);
  TPublish = class
  private
    FPubType: TPubType;
    FLmsVer: TLmsVer;
    //导出Word时是否显示答案
    FShowAnswer: Boolean;
    //发布为EXE时是否显示右键菜单
    FShowMenu: Boolean;
    FTitle: string;
    FFolder: string;
    //取消转换
    FCancel: Boolean;
    //引用Quiz类
    FQuizObj: TQuizObj;
    //预览单题用
    FQuesobj: TQuesBase;
    FHandle: THandle;

    FDisProgress: TDisProgress;
    FRegistry: TRegistry;
    procedure SetFolder(Value: string);
    procedure InitData;
    procedure LoadFromReg;
    //获取按提型抽题之信息
    function GetRndMode: Boolean;
    function GetRndIdStr(const ARndCount, ATotal: Integer): string;
    function GetTypeIds(const AQuesType: TQuesType): string;
    function GetRndIds: string;
    function GetRndCount: Integer;
  public
    constructor Create(AOwner: TQuizObj);
    destructor Destroy; override;
    procedure SaveToReg;
    procedure DoCancel;
    //发布操作...
    function Execute: Boolean;
    //预览...
    procedure Preview(AQuesObj: TQuesBase = nil);
    //生成影片...
    function GetGifSprite(AMovie: TFlashMovie; AImage: string): TFlashSprite;
    procedure DealBackImage(const AImage: string; AMovie: TFlashMovie);
    procedure AddImageToMovie(const AImage, ALinkID: string; AMovie: TFlashMovie;
      AWidth: Integer = 640; AHeight: Integer = 480);
    procedure AddSoundToMovie(const ASndFile, ASndID: string; AMovie: TFlashMovie);
    procedure AddActionScript(AMovie: TFlashMovie);
    function BuildMoive(const AMovieFile: string; AViewMode: Boolean = False): Boolean;
    procedure BuildHtmlFiles;
    procedure BuildLmsFiles;
    function BuildWordDoc: Boolean;
    function BuildExcelDoc: Boolean;
    function BuildExeFile: Boolean;
    //合并exe及swf
    function CombineFile(const AMovieFile: string): Boolean;

    //进度回调
    property DisProgress: TDisProgress read FDisProgress write FDisProgress;
    //为发布Word引用
    property QuizObj: TQuizObj read FQuizObj;
    property PubType: TPubType read FPubType write FPubType;
    property LmsVer: TLmsVer read FLmsVer write FLmsVer;
    property ShowAnswer: Boolean read FShowAnswer write FShowAnswer;
    property ShowMenu: Boolean read FShowMenu write FShowMenu;
    property Title: string read FTitle write FTitle;
    property Folder: string read FFolder write SetFolder;
    property Cancel: Boolean read FCancel;
    property Handle: THandle read FHandle write FHandle;
    //处理随机抽题相关
    property RndMode: Boolean read GetRndMode;
    property RndIds: string read GetRndIds;
    property RndCount: Integer read GetRndCount;
  end;

var
  QuizObj: TQuizObj;

implementation

uses uGlobal, VCLUnZip, VCLZip, DateUtils, jpeg, GifImage, PngImage,
  IdGlobal, FlashGDI, uWord;

{ TQuizBase }

constructor TQuesBase.Create(AQuesType: TQuesType);
begin
  FType := AQuesType;
  LoadData();
end;

destructor TQuesBase.Destroy;
begin
  inherited Destroy;
end;

procedure TQuesBase.Assign(Source: TQuesBase);
begin
  if Source is TQuesBase then
  begin
    FIndex    := Source.Index;
    FTopic    := Source.Topic;
    FAudio    := Source.Audio;
    FType     := Source._Type;
    FFeedAns  := Source.FeedAns;
    FPoints   := Source.Points;
    FAttempts := Source.Attempts;
    FLevel    := Source.Level;
    FImage    := Source.Image;
    FFeedInfo := Source.FeedInfo;
  end;
end;

function TQuesBase.GetAnswer(const AAnsStr: string): string;
begin
  if Pos('$$$$', AAnsStr) <> 0 then
    Result := Copy(AAnsStr, 1, Pos('$$$$', AAnsStr) - 1)
  else Result := AAnsStr;
end;

function TQuesBase.GetFeedback(const AAnsStr: string): string;
begin
  if Pos('$$$$', AAnsStr) <> 0 then
    Result := Copy(AAnsStr, Pos('$$$$', AAnsStr) + 4, Length(AAnsStr) - Pos('$$$$', AAnsStr) + 4)
  else Result := '';
end;

procedure TQuesBase.LoadData;
begin
  with Audio do
  begin
    AutoPlay := True;
    LoopCount := 1;
  end;
  with QuizObj do
  begin
    Attempts := QuizSet.Attempts;
    Points := QuizSet.Points;
    Level := QuizSet.QuesLevel;
    FeedInfo := QuizSet.FeedInfo
  end;
end;

procedure TQuesBase.SetTopic(Value: string);
begin
  FTopic := StringReplace(Value, #13#10, '$$$$', [rfReplaceAll]);
  FTopic := StringReplace(FTopic, #10, #13#10, [rfReplaceAll]);
  FTopic := StringReplace(FTopic, '$$$$' ,#13#10, [rfReplaceAll]);
end;

function TQuesBase.GetTypeName: string;
begin
  case FType of
    qtJudge:   Result := '判断题';
    qtSingle:  Result := '单选题';
    qtMulti:   Result := '多选题';
    qtBlank:   Result := '填空题';
    qtMatch:   Result := '匹配题';
    qtSeque:   Result := '排序题';
    qtHotSpot: Result := '热区题';
    qtEssay:   Result := '简答题';
    qtScene:   Result := '场景页';
  end;
end;

function TQuesBase.GetLevelName: string;
begin
  case FLevel of
    qlEasy:    Result := '容易';
    qlPrimary: Result := '初级';
    qlMiddle:  Result := '中级';
    qlDiffic:  Result := '高级';
    qlHard:    Result := '困难';
    qlEssay:   Result := '';
    qlScene:   Result := '';
  end;
end;

{ TQuesObj }

constructor TQuesObj.Create(AQuesType: TQuesType);
begin
  inherited;
  FAnswers := TStringList.Create;
end;

destructor TQuesObj.Destroy;
begin
  FAnswers.Free;
  inherited;
end;

procedure TQuesObj.Assign(Source: TQuesBase);
begin
  inherited Assign(Source);
  FAnswers.Assign(TQuesObj(Source).Answers);
end;

{ TQuesHot }

procedure TQuesHot.Assign(Source: TQuesBase);
begin
  inherited Assign(Source);
  FHotImage := TQuesHot(Source).HotImage;
  FHotRect := TQuesHot(Source).HotRect;
end;

{ TQuizList }

constructor TQuesList.Create;
begin

end;

destructor TQuesList.Destroy;
begin

  inherited;
end;

function TQuesList.GetSameItem: Boolean;
var
  i: Integer;
  sl: TStrings;
begin
  Result := False;
  if Count = 0 then Exit;

  sl := TStringList.Create;
  try
    for i := 0 to Count - 1 do
      if sl.IndexOf(Items[i].Topic) = -1 then
        sl.Append(Items[i].Topic);

    Result := sl.Count <> Count;
  finally
    sl.Free;
  end;
end;

function TQuesList.GetTotalPoint: Double;
var
  i: Integer;
begin
  Result := 0;
  if Count = 0 then Exit;

  for i := 0 to Count - 1 do
    Result := Result + Items[i].Points;
end;

function TQuesList.Get(Index: Integer): TQuesBase;
begin
  Result := inherited Get(Index);
end;

procedure TQuesList.Put(Index: Integer; Item: TQuesBase);
begin
  inherited Put(Index, Item);
end;

function TQuesList.Add(Item: TQuesBase): Integer;
begin
  Result := inherited Add(Item);
end;

procedure TQuesList.Append(Item: TQuesBase);
begin
  Add(Item);
end;

procedure TQuesList.Clear;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    if Assigned(Items[i]) then
    begin
      Items[i].Free;
      Items[i] := nil;
    end;

  inherited;
end;

procedure TQuesList.Resort;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    Items[i].Index := i + 1;
end;

{ TQuizObj }

constructor TQuizObj.Create;
begin
  FQuizProp := TQuizProp.Create;
  FPlayer := TPlayer.Create;
  FQuizSet := TQuizSet.Create;
  FPublish := TPublish.Create(Self);
  FQuesList := TQuesList.Create;
end;

destructor TQuizObj.Destroy;
begin
  FQuizProp.Free;
  FPlayer.Free;
  FQuizSet.Free;
  FPublish.Free;
  FQuesList.Free;

  inherited;
end;

//转换函数...
function VarToBool(AValue: OleVariant): Boolean;
begin
  Result := StrToBool(VarToStrDef(AValue, 'False'));
end;

function VarToInt(AValue: OleVariant; ADefault: Integer = 0): Integer;
begin
  if Trim(VarToStrDef(AValue, '')) = '' then
    Result := 0
  else Result := StrToInt(VarToStrDef(AValue, IntToStr(ADefault)));
end;

function VarToFloat(AValue: OleVariant): Double;
begin
  if Trim(VarToStrDef(AValue, '')) = '' then
    Result := 0
  else Result := StrToFloat(VarToStrDef(AValue, '0'));
end;

function TQuizObj.LoadQues(AQuesNode: IXMLNode; AAppend: Boolean): Boolean;
var
  xnChild, xnTail: IXMLNode;
  i: Integer;
  QuesBase: TQuesBase;
  QuesType: TQuesType;
begin
  Result := False;
  if AQuesNode = nil then Exit;

  if not AAppend then FQuesList.Clear;
  for i := 0 to AQuesNode.ChildNodes.Count - 1 do
  begin
    if not GetCanAdd(FHandle) then Break;

    xnChild := AQuesNode.ChildNodes[i];
    if xnChild <> nil then
    begin
      QuesType := TQuesType(VarToInt(xnChild.Attributes['type']));
      if QuesType <> qtHotSpot then
        QuesBase := TQuesObj.Create(QuesType)
      else QuesBase := TQuesHot.Create(QuesType);
      //赋值
      QuesBase.Index := VarToInt(xnChild.Attributes['id'], i);
      QuesBase.FeedAns := VarToBool(xnChild.Attributes['feedAns']);
      QuesBase.Points := VarToFloat(xnChild.Attributes['points']);
      QuesBase.Attempts := VarToInt(xnChild.Attributes['attempts'], 1);
      QuesBase.Level := TQuesLevel(VarToInt(xnChild.Attributes['level']));
      QuesBase.Image := VarToStr(xnChild.Attributes['image']);
      //若不存在则找临时文件夹下的
      if not FileExists(QuesBase.Image) and FileExists(GetDealImgStr(FProjDir + ExtractFileName(QuesBase.Image))) then
        QuesBase.Image := GetDealImgStr(FProjDir + ExtractFileName(QuesBase.Image));
      with QuesBase.Audio do
      begin
        FileName := VarToStr(xnChild.Attributes['audio']);
        if not FileExists(FileName) and FileExists(FProjDir + ExtractFileName(FileName)) then
          FileName := FProjDir + ExtractFileName(FileName);
        AutoPlay := VarToBool(xnChild.Attributes['autoPlay']);
        LoopCount := VarToInt(xnChild.Attributes['loopCount'], 1);
        if LoopCount = 0 then LoopCount := 1;
      end;
      //题目&答案
      QuesBase.Topic := xnChild.ChildNodes[0].Text;
      if QuesBase._Type <> qtHotSpot then
        TQuesObj(QuesBase).Answers.Text := xnChild.ChildNodes[1].Text
      else
      //取HotSpot类型答案
      begin
        with TQuesHot(QuesBase), xnChild.ChildNodes[1] do
        begin
          HotImage := Text;
          if not FileExists(HotImage) then HotImage := GetDealImgStr(FProjDir + ExtractFileName(HotImage));
          if not FileExists(HotImage) then MessageBox(FHandle, PAnsiChar('热区题[' + QuesBase.Topic + ']的热区图片不存在，请在试题加载后重新指定'), '提示', MB_OK + MB_ICONWARNING);

          HPos := VarToInt(Attributes['hpos']);
          VPos := VarToInt(Attributes['vpos']);
          HotRect := Rect(VarToInt(Attributes['left']), VarToInt(Attributes['top']), VarToInt(Attributes['width']), VarToInt(Attributes['height']));
          ImgFit := VarToBool(Attributes['fit']);
        end;
      end;
      //反馈信息
      xnTail := xnChild.ChildNodes.FindNode('feedBack');
      if xnTail <> nil then
      begin
        with QuesBase.FeedInfo do
        begin
          Enabled := VarToBool(xnTail.Attributes['enabled']);
          CrtInfo := xnTail.ChildNodes[0].Text;
          ErrInfo := xnTail.ChildNodes[1].Text;
        end;
      end;

      //加入试题列表中
      QuesList.Append(QuesBase);
    end;
  end;

  Result := True;
end;

function TQuizObj.LoadData: Boolean;
var
  xml: IXMLDocument;
  xnRoot, xnPar, xnChild, xnTail: IXMLNode;
begin
  Result := False;
  if not FileExists(FProjPath) then Exit;

  //是否v1.3.6以前的工程文件
  if IsXMLDoc(FProjPath) then
    FProjFile := FProjPath
  else if not ExtendProj(FProjPath) then Exit;

  xml := NewXMLDocument;
  try
    xml.LoadFromFile(FProjFile);
    xml.Active := True;
    xnRoot := xml.DocumentElement;
    //载入属性
    xnPar := xnRoot.ChildNodes.FindNode('properties');
    if xnPar <> nil then
    begin
      with FQuizProp do
      begin
        QuizTopic := xnPar.ChildNodes[0].Text;
        QuizID := xnPar.ChildNodes[1].Text;
        //试题信息
        xnChild := xnPar.ChildNodes.FindNode('quizInfo');
        if xnChild <> nil then
        begin
          ShowInfo := VarToBool(xnChild.Attributes['enabled']);
          QuizInfo := xnChild.ChildNodes[0].Text;
          QuizImage := xnChild.ChildNodes[1].Text;
          if not FileExists(QuizImage) and FileExists(GetDealImgStr(FProjDir + ExtractFileName(QuizImage))) then
            QuizImage := GetDealImgStr(FProjDir + ExtractFileName(QuizImage));
          ShowName := VarToBool(xnChild.ChildNodes[2].Text);
          ShowMail := VarToBool(xnChild.ChildNodes[3].Text);
          BlankName := VarToBool(xnChild.ChildNodes[4].Text);
        end;
        //试题设置
        xnChild := xnPar.ChildNodes.FindNode('quizSet');
        if xnChild <> nil then
        begin
          SubmitType := TSubmitType(StrToInt(xnChild.ChildNodes[0].Text));
          PassRate := StrToInt(xnChild.ChildNodes[1].Text);
          xnTail := xnChild.ChildNodes.FindNode('timeSet');
          if xnTail <> nil then
          begin
            with TimeSet do
            begin
              Enabled := VarToBool(xnTail.Attributes['enabled']);
              Minutes := StrToInt(xnTail.ChildNodes[0].Text);
              Seconds := StrToInt(xnTail.ChildNodes[1].Text);
            end;
          end;
          xnTail := xnChild.ChildNodes.FindNode('rndQues');
          if xnTail <> nil then
          begin
            with RndQues do
            begin
              Enabled := VarToBool(xnTail.Attributes['enabled']);
              RndType := TRndType(StrToInt(VarToStrDef(xnTail.Attributes['rndType'], '0')));
              RunTime := VarToBool(xnTail.Attributes['runTime']);
              Count := StrToInt(xnTail.ChildNodes[0].Text);
              //分题型
              if (xnTail.ChildNodes[1] <> nil) and (xnTail.ChildNodes[1].ChildNodes.Count = 8) then
              begin
                with TypeCount, xnTail.ChildNodes[1] do
                begin
                  Judge   := StrToIntDef(ChildNodes[0].Text, 0);
                  Single  := StrToIntDef(ChildNodes[1].Text, 0);
                  Multi   := StrToIntDef(ChildNodes[2].Text, 0);
                  Blank   := StrToIntDef(ChildNodes[3].Text, 0);
                  Match   := StrToIntDef(ChildNodes[4].Text, 0);
                  Seque   := StrToIntDef(ChildNodes[5].Text, 0);
                  HotSpot := StrToIntDef(ChildNodes[6].Text, 0);
                  Essay   := StrToIntDef(ChildNodes[7].Text, 0);
                end;
              end;
            end;
          end;
          xnTail := xnChild.ChildNodes.FindNode('showQuesNo');
          if xnTail <> nil then ShowQuesNo := StrToBoolDef(xnTail.Text, True);
          xnTail := xnChild.ChildNodes.FindNode('rndAnswer');
          if xnTail <> nil then RndAnswer := StrToBoolDef(xnTail.Text, True);
          xnTail := xnChild.ChildNodes.FindNode('showAnswer');
          if xnTail <> nil then ShowAnswer := StrToBoolDef(xnTail.Text, True);
          xnTail := xnChild.ChildNodes.FindNode('viewQuiz');
          if xnTail <> nil then ViewQuiz := StrToBoolDef(xnTail.Text, True);
        end;
        //结果设置
        xnChild := xnPar.ChildNodes.FindNode('resultSet');
        if xnChild <> nil then
        begin
          xnTail := xnChild.ChildNodes.FindNode('passSet');
          if xnTail <> nil then
          begin
            with PassSet do
            begin
              Enabled := VarToBool(xnTail.Attributes['enabled']);
              PassInfo := xnTail.ChildNodes[0].Text;
              FailInfo := xnTail.ChildNodes[1].Text;
            end;
          end;
          xnTail := xnChild.ChildNodes.FindNode('postSet');
          if xnTail <> nil then
          begin
            with PostSet do
            begin
              Enabled := VarToBool(xnTail.Attributes['enabled']);
              Url := xnTail.ChildNodes[0].Text;
              _Type := TPostType(StrToInt(xnTail.ChildNodes[1].Text));
            end;
          end;
          xnTail := xnChild.ChildNodes.FindNode('mailSet');
          if xnTail <> nil then
          begin
            with MailSet do
            begin
              Enabled := VarToBool(xnTail.Attributes['enabled']);
              MailAddr := xnTail.ChildNodes[0].Text;
              MailUrl := xnTail.ChildNodes[1].Text;
              _Type := TPostType(StrToInt(xnTail.ChildNodes[2].Text));
            end;
          end;
          xnTail := xnChild.ChildNodes.FindNode('quitOper');
          if xnTail <> nil then
          begin
            with QuitOper do
            begin
              PassType := TQuitType(StrToInt(xnTail.ChildNodes[0].Text));
              PassUrl := xnTail.ChildNodes[1].Text;
              FailType := TQuitType(StrToInt(xnTail.ChildNodes[2].Text));
              FailUrl := xnTail.ChildNodes[3].Text;
            end;
          end;
        end;
        //试题保护
        xnChild := xnPar.ChildNodes.FindNode('protectSet');
        if xnChild <> nil then
        begin
          xnTail := xnChild.ChildNodes.FindNode('pwdSet');
          if xnTail <> nil then
          begin
            with PwdSet do
            begin
              Enabled := VarToBool(xnTail.Attributes['enabled']);
              _Type := TPwdType(StrToInt(xnTail.ChildNodes[0].Text));
              Password := xnTail.ChildNodes[1].Text;
              Url := xnTail.ChildNodes[2].Text;
              AllowChangeUserId := VarToBool(xnTail.ChildNodes[2].Attributes['allow']);
            end;
          end;
          xnTail := xnChild.ChildNodes.FindNode('urlLimit');
          if xnTail <> nil then
          begin
            with UrlLimit do
            begin
              Enabled := VarToBool(xnTail.Attributes['enabled']);
              Url := xnTail.Text;
            end;
          end;
          xnTail := xnChild.ChildNodes.FindNode('dateLimit');
          if xnTail <> nil then
          begin
            with DateLimit do
            begin
              Enabled := VarToBool(xnTail.Attributes['enabled']);
              StartDate := StrToDateDef(xnTail.ChildNodes[0].Text, Date());
              if StartDate < Date() then StartDate := Date();
              EndDate := StrToDateDef(xnTail.ChildNodes[1].Text, IncYear(Date()));
              if EndDate < StartDate then EndDate := StartDate;
            end;
          end;
        end;
      end;
    end;
    //载入试题
    Result := LoadQues(xnRoot.ChildNodes.FindNode('items'));
  except
    on E: Exception do
    begin
      Result := False;
      MessageBox(FHandle, PAnsiChar('加载工程文件错误，信息为：' + #13#10 + E.Message), '提示', MB_OK + MB_ICONWARNING);
    end;
  end;
end;

function TQuizObj.LoadProj(const AProjPath: string): Boolean;
begin
  if FProjPath <> AProjPath then
  begin
    FProjPath := AProjPath;
    FPublish.Title := ChangeFileExt(ExtractFileName(FProjPath), '');
  end;

  Screen.Cursor := crHourGlass;
  try
    Result := LoadData();
  finally
    Screen.Cursor := crDefault;
  end;
end;

function TQuizObj.SaveData: Boolean;
  function GetBoolStr(AValue: Boolean): string;
  begin
    Result := LowerCase(BoolToStr(AValue, True));
  end;

var
  slQuiz: TStrings;
  i: Integer;
  QuesBase: TQuesBase;
  xml: IXMLDocument;
begin
  Result := False;
  if FProjPath = '' then Exit;

  slQuiz := TStringList.Create;  
  try
    with slQuiz do
    begin
      Append('<?xml version="1.0" ?>');
      Append('');
      Append('<quiz version="' + App.Version + '">');
      Append('  <properties>');
      with FQuizProp do
      begin
        Append('    <topic><![CDATA[' + QuizTopic + ']]></topic>');
        Append('    <ID>' + QuizID + '</ID>');
        Append('    <quizInfo enabled="' + GetBoolStr(ShowInfo) + '">');
        Append('      <info><![CDATA[' + QuizInfo + ']]></info>');
        Append('      <image>' + QuizImage + '</image>');
        Append('      <showName>' + GetBoolStr(ShowName) + '</showName>');
        Append('      <showMail>' + GetBoolStr(ShowMail) + '</showMail>');
        Append('      <blankName>' + GetBoolStr(BlankName) + '</blankName>');
        Append('    </quizInfo>');
        Append('    <quizSet>');
        Append('      <submitType>' + IntToStr(Ord(SubmitType)) + '</submitType>');
        Append('      <passRate>' + IntToStr(PassRate) + '</passRate>');
        Append('      <timeSet enabled="' + GetBoolStr(TimeSet.Enabled) + '">');
        Append('        <minutes>' + IntToStr(TimeSet.Minutes) + '</minutes>');
        Append('        <seconds>' + IntToStr(TimeSet.Seconds) + '</seconds>');
        Append('      </timeSet>');
        Append('      <rndQues enabled="' + GetBoolStr(RndQues.Enabled) + '" rndType="' + IntToStr(Ord(RndQues.RndType)) + '" runTime="' + GetBoolStr(RndQues.RunTime) + '">');
        Append('        <count>' + IntToStr(RndQues.Count) + '</count>');
        Append('        <typeCount>');
        Append('          <judge>' + IntToStr(RndQues.TypeCount.Judge) + '</judge>');
        Append('          <single>' + IntToStr(RndQues.TypeCount.Single) + '</single>');
        Append('          <multi>' + IntToStr(RndQues.TypeCount.Multi) + '</multi>');
        Append('          <blank>' + IntToStr(RndQues.TypeCount.Blank) + '</blank>');
        Append('          <match>' + IntToStr(RndQues.TypeCount.Match) + '</match>');
        Append('          <seque>' + IntToStr(RndQues.TypeCount.Seque) + '</seque>');
        Append('          <hotspot>' + IntToStr(RndQues.TypeCount.HotSpot) + '</hotspot>');
        Append('          <essay>' + IntToStr(RndQues.TypeCount.Essay) + '</essay>');
        Append('        </typeCount>');
        Append('      </rndQues>');
        Append('      <showQuesNo>' + GetBoolStr(ShowQuesNo) + '</showQuesNo>');
        Append('      <rndAnswer>' + GetBoolStr(RndAnswer) + '</rndAnswer>');
        Append('      <showAnswer>' + GetBoolStr(ShowAnswer) + '</showAnswer>');
        Append('      <viewQuiz>' + GetBoolStr(ViewQuiz) + '</viewQuiz>');
        Append('    </quizSet>');
        Append('    <resultSet>');
        Append('      <passSet enabled="' + GetBoolStr(PassSet.Enabled) + '">');
        Append('        <passInfo><![CDATA[' + PassSet.PassInfo + ']]></passInfo>');
        Append('        <failInfo><![CDATA[' + PassSet.FailInfo + ']]></failInfo>');
        Append('      </passSet>');
        Append('      <postSet enabled="' + GetBoolStr(PostSet.Enabled) + '">');
        Append('        <url>' + PostSet.Url + '</url>');
        Append('        <type>' + IntToStr(Ord(PostSet._Type)) + '</type>');
        Append('      </postSet>');
        Append('      <mailSet enabled="' + GetBoolStr(MailSet.Enabled) + '">');
        Append('        <mailAddr>' + MailSet.MailAddr + '</mailAddr>');
        Append('        <mailUrl>' + MailSet.MailUrl + '</mailUrl>');
        Append('        <type>' + IntToStr(Ord(MailSet._Type)) + '</type>');
        Append('      </mailSet>');
        Append('      <quitOper>');
        Append('        <passType>' + IntToStr(Ord(QuitOper.PassType)) + '</passType>');
        Append('        <passUrl>' + QuitOper.PassUrl + '</passUrl>');
        Append('        <failType>' + IntToStr(Ord(QuitOper.FailType)) + '</failType>');
        Append('        <failUrl>' + QuitOper.FailUrl + '</failUrl>');
        Append('      </quitOper>');
        Append('    </resultSet>');
        Append('    <protectSet>');
        Append('      <pwdSet enabled="' + GetBoolStr(PwdSet.Enabled) + '">');
        Append('        <type>' + IntToStr(Ord(PwdSet._Type)) + '</type>');
        Append('        <password>' + PwdSet.Password + '</password>');
        Append('        <url allow="' + GetBoolStr(PwdSet.AllowChangeUserId) + '">' + PwdSet.Url + '</url>');
        Append('      </pwdSet>');
        Append('      <urlLimit enabled="' + GetBoolStr(UrlLimit.Enabled) + '">' + UrlLimit.Url + '</urlLimit>');
        Append('      <dateLimit enabled="' + GetBoolStr(DateLimit.Enabled) + '">');
        Append('        <startDate>' + DateToStr(DateLimit.StartDate) + '</startDate>');
        Append('        <endDate>' + DateToStr(DateLimit.EndDate) + '</endDate>');
        Append('      </dateLimit>');
        Append('    </protectSet>');
      end;
      Append('  </properties>');
      Append('  <items>');
      for i := 0 to FQuesList.Count - 1 do
      begin
        QuesBase := FQuesList.Items[i];
        Append('    <item id="' + IntToStr(QuesBase.Index) + '" type="' + IntToStr(Ord(QuesBase._Type)) + '" feedAns="' + GetBoolStr(QuesBase.FeedAns) + '" points="' + FloatToStr(QuesBase.Points) + '" attempts="' + IntToStr(QuesBase.Attempts) + '" level="' + IntToStr(Ord(QuesBase.Level)) +
               '" image="' + QuesBase.Image + '" audio="' + QuesBase.Audio.FileName + '" autoPlay="' + GetBoolStr(QuesBase.Audio.AutoPlay) + '" loopCount="' + IntToStr(QuesBase.Audio.LoopCount) + '">');
        Append('      <topic><![CDATA[' + QuesBase.Topic + ']]></topic>');
        if QuesBase._Type <> qtHotSpot then
          Append('    <answer><![CDATA[' + TQuesObj(QuesBase).Answers.Text + ']]></answer>')
        else
          with TQuesHot(QuesBase) do
            Append(Format('    <answer hpos="%d" vpos="%d" left="%d" top="%d" width="%d" height="%d" fit="%s"><![CDATA[%s]]></answer>', [HPos, VPos, HotRect.Left, HotRect.Top, HotRect.Right, HotRect.Bottom, LowerCase(BoolToStr(ImgFit, True)), HotImage]));
        Append('      <feedBack enabled="' + GetBoolStr(QuesBase.FeedInfo.Enabled) + '">');
        Append('        <crtInfo><![CDATA[' + QuesBase.FeedInfo.CrtInfo + ']]></crtInfo>');
        Append('        <errInfo><![CDATA[' + QuesBase.FeedInfo.ErrInfo + ']]></errInfo>');
        Append('      </feedBack>');
        Append('    </item>');
      end;
      Append('  </items>');
      Append('</quiz>');

      //保存...
      xml := NewXMLDocument;
      xml.XML.Text := AnsiToUtf8(slQuiz.Text);
      xml.Active := True;
      //打包资源文件
      Screen.Cursor := crHourGlass;
      try
        Result := PackProj(xml);
      finally
        Screen.Cursor := crDefault;
      end;

      //发已储存消息
      PostMessage(FHandle, WM_QUIZCHANGE, QUIZ_RESET, 0);
    end;
  finally
    slQuiz.Free;
  end;
end;

function TQuizObj.IsXMLDoc(const AXMLFile: string): Boolean;
var
  sl: TStrings;
begin
  sl := TStringList.Create;
  try
    sl.LoadFromFile(AXMLFile);
    Result := (sl.Count > 0) and (Trim(sl[0]) = '<?xml version="1.0"?>');
  finally
    sl.Free;
  end;
end;

function TQuizObj.PackProj(AXML: IXMLDocument): Boolean;
var
  sExt, sZipFile: string;
  i: Integer;
  zip: TVCLZip;
  RS, WS: TFileStream;
  iPos: DWORD;

  //处理要打包的图片
  procedure DealProjImage(const AImgFile: string);
  begin
    if FileExists(AImgFile) then
    begin
      sExt := LowerCase(ExtractFileExt(AImgFile));
      if (Pos(sExt, '.swf.gif') = 0) and DealImage(AImgFile) then
        CopyFile(PAnsiChar(App.TmpJpg), PAnsiChar(FProjDir + ExtractFileName(ChangeFileExt(AImgFile, '.jpg'))), True)
      else CopyFile(PAnsiChar(AImgFile), PAnsiChar(FProjDir + ExtractFileName(AImgFile)), True);
    end;
  end;

  //处理要打包的声音
  procedure DealProjAudio(const ASndFile: string);
  begin
    if FileExists(ASndFile) then CopyFile(PAnsiChar(ASndFile), PAnsiChar(FProjDir + ExtractFileName(ASndFile)), True);
  end;

begin
  FProjDir := App.TmpPath + FPublish.FTitle + '_aqb\';
  try
    if DirectoryExists(FProjDir) then DeleteDirectory(FProjDir);
    ForceDirectories(FProjDir);
    FProjFile := FProjDir + 'quiz.xml';
    AXML.SaveToFile(FProjFile);
    //打包资源文件...
    //试题图片
    DealProjImage(FQuizProp.QuizImage);
    //播放器背景图
    DealProjImage(FPlayer.ColorSet.BackImage.Image);
    //单题图片&声音&热区图片
    for i := 0 to FQuesList.Count - 1 do
    begin
      DealProjImage(FQuesList[i].Image);
      if FQuesList[i]._Type = qtHotSpot then
        DealProjImage(TQuesHot(FQuesList[i]).HotImage);
      DealProjAudio(FQuesList[i].Audio.FileName);
    end;
    //播放器声音
    DealProjAudio(FPlayer.BackSound.SndFile);
    DealProjAudio(FPlayer.EventSound.SndCrt);
    DealProjAudio(FPlayer.EventSound.SndErr);
    DealProjAudio(FPlayer.EventSound.SndTry);
    DealProjAudio(FPlayer.EventSound.SndPass);
    DealProjAudio(FPlayer.EventSound.SndFail);

    //用VCLZip打包成压缩文件
    sZipFile := App.TmpPath + ChangeFileExt(ExtractFileName(FProjPath), '.zip');
    zip := TVCLZip.Create(nil);
    zip.FilesList.Clear;
    zip.FilesList.Add(FProjDir + '*.*');
    zip.ZipName := sZipFile;
    Result := zip.Zip <> 0;
    zip.Free;
    DeleteDirectory(FProjDir);
    if not Result then Exit;

    //用流写入工程文件标记，以防由WinRAR等打开
    WS := TFileStream.Create(FProjPath, fmCreate);
    try
      RS := TFileStream.Create(sZipFile, fmOpenRead);
      try
        iPos := RS.Size div 2;
        RS.Seek(iPos, soBeginning);
        WS.CopyFrom(RS, RS.Size - iPos);
        RS.Seek(0, soBeginning);
        WS.CopyFrom(RS, iPos);
      finally
        RS.Free;
      end;
    finally
      WS.Free;
    end;

    DeleteFile(sZipFile);
  except
    Result := False;
  end;
end;

function TQuizObj.ExtendProj(const AProjPath: string): Boolean;
var
  sZipFile: string;
  unzip: TVCLUnZip;
  RS, WS: TFileStream;
  iPos: DWORD;
begin
  Result := False;
  if not FileExists(AProjPath) then Exit;

  try
    //用流写入工程文件标记，以防由WinRAR等打开
    sZipFile := App.TmpPath + ChangeFileExt(ExtractFileName(AProjPath), '.zip');
    WS := TFileStream.Create(sZipFile, fmCreate);
    try
      RS := TFileStream.Create(AProjPath, fmOpenRead);
      try
        iPos := RS.Size div 2;
        if Odd(RS.Size) then Inc(iPos);
        RS.Seek(iPos, soBeginning);
        WS.CopyFrom(RS, RS.Size - iPos);
        RS.Seek(0, soBeginning);
        WS.CopyFrom(RS, iPos);
      finally
        RS.Free;
      end;
    finally
      WS.Free;
    end;

    //解压
    FProjDir := App.TmpPath + ChangeFileExt(ExtractFileName(AProjPath), '\');
    unzip := TVCLUnZip.Create(nil);
    unzip.ZipName := sZipFile;
    unzip.DoAll := True;
    unzip.DestDir := FProjDir;
    unzip.RecreateDirs := True;
    unzip.RetainAttributes := True;
    unzip.OverwriteMode := Always;
    Result := unzip.UnZip <> 0;
    unzip.Free;
    DeleteFile(sZipFile);

    if Result then FProjFile := FProjDir + 'quiz.xml';
  except
    Result := False;
  end;
end;

function TQuizObj.AppendProj(const AProjPath: string): Boolean;
var
  xml: IXMLDocument;
  xnRoot: IXMLNode;
begin
  Result := False;
  if not FileExists(AProjPath) then Exit;

  //是否v1.3.6以前的工程文件
  if IsXMLDoc(AProjPath) then
    FProjFile := AProjPath
  else if not ExtendProj(AProjPath) then Exit;

  xml := NewXMLDocument;
  try
    xml.LoadFromFile(FProjFile);
    xml.Active := True;
    xnRoot := xml.DocumentElement;
    //载入试题
    Result := LoadQues(xnRoot.ChildNodes.FindNode('items'), True);
  except
    on E: Exception do
    begin
      Result := False;
      MessageBox(FHandle, PAnsiChar('追加工程文件错误，信息为：' + #13#10 + E.Message), '提示', MB_OK + MB_ICONWARNING);
    end;
  end;
end;

function TQuizObj.LoadExcel(const AXlsName: string): Boolean;
const
  MAX_ROW = 500;
  MAX_COL = 12;
var
  vApp, vSheet: OleVariant;
  sc, i, j, iIndex: Integer;
  sAns: string;
  QuesBase: TQuesBase;
  QuesType: TQuesType;
begin
  Result := False;
  if not FileExists(AXlsName) then Exit;

  try
    vApp := CreateOleObject('Excel.Application');
  except
    MessageBox(Handle, 'Excel对象创建失败，您的计算机中是否没有安装Microsoft Excel？', '提示', MB_OK + MB_ICONINFORMATION);
    Exit;
  end;

  try
    FQuizProp.QuizTopic := StringReplace(ExtractFileName(AXlsName), ExtractFileExt(AXlsName), '', []);
    FPublish.Title := FQuizProp.QuizTopic;
    try
      vApp.WorkBooks.Open(AXlsName);
      FQuesList.Clear;
      iIndex := 0;
      for sc := 1 to vApp.Worksheets.Count do
      begin
        vSheet := vApp.WorkSheets[sc];

        //加载试题
        for i := 1 to MAX_ROW do
        begin
          if not GetCanAdd(FHandle) then Break;
          if Trim(vSheet.Cells[i, 1].Value) = '' then Continue;

          QuesType := GetTypeFromName(vSheet.Cells[i, 2].Value);
          if QuesType <> qtHotSpot then
            QuesBase := TQuesObj.Create(QuesType)
          else QuesBase := TQuesHot.Create(QuesType);
          QuesBase.Index := iIndex;
          if not VarIsNull(vSheet.Cells[i, 3].Value) then
            QuesBase.Points := VarToFloat(StringReplace(vSheet.Cells[i, 3].Value, '分', '', []));
          QuesBase.Topic := Trim(vSheet.Cells[i, 1].Value);
          if QuesBase._Type <> qtHotSpot then
            for j := 4 to MAX_COL do
            begin
              sAns := VarToStr(vSheet.Cells[i, j].Value);
              if Trim(sAns) = '' then Continue;

              if (QuesBase._Type in [qtJudge, qtSingle, qtMulti]) and (Pos('True=', sAns) = 0) then
                TQuesObj(QuesBase).Answers.Append('False=' + sAns)
              else TQuesObj(QuesBase).Answers.Append(sAns);
            end
          else
            with TQuesHot(QuesBase) do
            begin
              HotImage := vSheet.Cells[i, 4].Value;
              with HotRect do
              begin
                Left := StrToInt(vSheet.Cells[i, 5].Value);
                Top := StrToInt(vSheet.Cells[i, 6].Value);
                Right := StrToInt(vSheet.Cells[i, 7].Value);
                Bottom := StrToInt(vSheet.Cells[i, 8].Value);
              end;
            end;
          //题型难度
          if QuesBase._Type in [qtEssay, qtScene] then
          begin
            QuesBase.Points := 0;
            QuesBase.Level := qlEssay;
          end;

          //加入试题列表中
          QuesList.Append(QuesBase);
          Inc(iIndex);
        end;
      end;

      Result := True;
    except
      on E: Exception do
      begin
        MessageBox(Handle, PAnsiChar('Excel数据导入失败，信息为：' + E.Message), '提示', MB_OK + MB_ICONINFORMATION);
        Result := False;
      end;
    end;
  finally
    vApp.Quit;
    vApp := Unassigned;
  end;
end;

function TQuizObj.SaveProj: Boolean;
begin
  if FProjPath = '' then
    Result := SaveProjAs()
  else Result := SaveData();
end;

function TQuizObj.SaveProjAs: Boolean;
var
  sd: TSaveDialog;
begin
  sd := TSaveDialog.Create(nil);
  try
    if FProjPath = '' then
      sd.FileName := 'untitled.aqb'
    else sd.FileName := ExtractFileName(FProjPath);
    sd.Filter := '试题文件(*.aqb)|*.aqb';
    sd.Options := sd.Options + [ofOverwritePrompt];
    if sd.Execute then
    begin
      FProjPath := sd.FileName;
      if ExtractFileExt(FProjPath) <> '.aqb' then FProjPath := ChangeFileExt(FProjPath, '.aqb');
      FPublish.Title := ChangeFileExt(ExtractFileName(FProjPath), '');

      Result := SaveData();
    end
    else Result := False;
  finally
    sd.Free;
  end;
end;

function TQuizObj.GetTypeName(AQuesType: TQuesType): string;
begin
  case AQuesType of
    qtJudge:   Result := '判断题';
    qtSingle:  Result := '单选题';
    qtMulti:   Result := '多选题';
    qtBlank:   Result := '填空题';
    qtMatch:   Result := '匹配题';
    qtSeque:   Result := '排序题';
    qtHotSpot: Result := '热区题';
    qtEssay:   Result := '简答题';
    qtScene:   Result := '场景页';
  end;
end;

function TQuizObj.GetTypeFromName(const ATypeName: string): TQuesType;
begin
  if Pos('判断', ATypeName) = 1 then
    Result := qtJudge
  else if Pos('单选', ATypeName) = 1 then
    Result := qtSingle
  else if Pos('多选', ATypeName) = 1 then
    Result := qtMulti
  else if Pos('填空', ATypeName) = 1 then
    Result := qtBlank
  else if Pos('匹配', ATypeName) = 1 then
    Result := qtMatch
  else if Pos('排序', ATypeName) = 1 then
    Result := qtSeque
  else if Pos('热区', ATypeName) = 1 then
    Result := qtHotSpot
  else if Pos('简答', ATypeName) = 1 then
    Result := qtEssay
  else Result := qtScene;
end;

function TQuizObj.GetQuesCount(AQuesType: TQuesType): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to FQuesList.Count - 1 do
    if FQuesList.Items[i]._Type = AQuesType then Inc(Result);
end;

{ TQuizProp }

constructor TQuizProp.Create;
begin
  FRegistry := TRegistry.Create;
  FRegistry.RootKey := HKEY_CURRENT_USER;

  LoadFromReg();
end;

destructor TQuizProp.Destroy;
begin
  FRegistry.Free;
  inherited Destroy;
end;

procedure TQuizProp.InitData;
begin
  //试题信息
  FQuizTopic := '未命名';
  FShowInfo := True;
  FShowName := True;
  FShowMail := True;
  FBlankName := True;
  //试题设置
  FSubmitType := stOnce;
  FPassRate := 60;
  FTimeSet.Enabled := True;
  FTimeSet.Minutes := 5;
  FTimeSet.Seconds := 0;
  with FRndQues.TypeCount do
  begin
    Judge   := -1;
    Single  := -1;
    Multi   := -1;
    Blank   := -1;
    Match   := -1;
    Seque   := -1;
    HotSpot := -1;
    Essay   := -1;
  end;
  FShowQuesNo := True;
  FRndAnswer := True;
  FShowAnswer := True;
  FViewQuiz := True;
  //结果设置
  FPassSet.Enabled := True;
  FPassSet.PassInfo := '恭喜，您通过了';
  FPassSet.FailInfo := '您没有通过';                    
  FPostSet.Enabled := True;
  FPostSet._Type := ptManual;
  FPostSet.Url := 'http://www.awindsoft.net/qms/receive.asp';
  FMailSet.MailAddr := '@';
  FPostSet._Type := ptManual;
  FMailSet.MailUrl := 'http://www.awindsoft.net/qms/mail.asp';
  FQuitOper.PassType := qtClose;
  FQuitOper.PassUrl := 'http://';
  FQuitOper.FailType := qtClose;
  FQuitOper.PassUrl := 'http://';
  //保护设置
  FPwdSet.Url := 'http://www.awindsoft.net/qms/check.asp';
  FUrlLimit.Url := 'http://';
  FDateLimit.StartDate := Date();
  FDateLimit.EndDate := IncYear(Date());
end;

procedure TQuizProp.LoadFromReg;
begin
  InitData();
  if not FRegistry.KeyExists(QUIZ_KEY_NAME + '\Properties') then Exit;

  with FRegistry do
  begin
    OpenKey(QUIZ_KEY_NAME + '\Properties', False);

    if ValueExists('SubmitType') then FSubmitType := TSubmitType(ReadInteger('SubmitType'));
    if ValueExists('PassRate') then FPassRate := ReadInteger('PassRate');
    if ValueExists('TimeEnabled') then FTimeSet.Enabled := ReadBool('TimeEnabled');
    if ValueExists('Minutes') then FTimeSet.Minutes := ReadInteger('Minutes');
    if ValueExists('Seconds') then FTimeSet.Seconds := ReadInteger('Seconds');
    if ValueExists('ShowQuesNo') then FShowQuesNo := ReadBool('ShowQuesNo');
    if ValueExists('RndAnswer') then FRndAnswer := ReadBool('RndAnswer');
    if ValueExists('ShowAnswer') then FShowAnswer := ReadBool('ShowAnswer');
    if ValueExists('ViewQuiz') then FViewQuiz := ReadBool('ViewQuiz');

    if ValueExists('PassEnabled') then FPassSet.Enabled := FRegistry.ReadBool('PassEnabled');
    if ValueExists('PassInfo') then FPassSet.PassInfo := FRegistry.ReadString('PassInfo');
    if ValueExists('FailInfo') then FPassSet.FailInfo := FRegistry.ReadString('FailInfo');
    //PostSet...
    if ValueExists('PostEnabled') then FPostSet.Enabled := FRegistry.ReadBool('PostEnabled');
    if ValueExists('PostUrl') then FPostSet.Url := FRegistry.ReadString('PostUrl');
    if ValueExists('PostType') then FPostSet._Type := TPostType(FRegistry.ReadInteger('PostType'));
    //MailSet...
    if ValueExists('MailEnabled') then FMailSet.Enabled := FRegistry.ReadBool('MailEnabled');
    if ValueExists('MailAddr') then FMailSet.MailAddr := FRegistry.ReadString('MailAddr');
    if ValueExists('MailUrl') then FMailSet.MailUrl := FRegistry.ReadString('MailUrl');
    if ValueExists('MailType') then FMailSet._Type := TPostType(FRegistry.ReadInteger('MailType'));
    //QuitOper...
    if ValueExists('PassType') then FQuitOper.PassType := TQuitType(FRegistry.ReadInteger('PassType'));
    if ValueExists('PassUrl') then FQuitOper.PassUrl := FRegistry.ReadString('PassUrl');
    if ValueExists('FailType') then FQuitOper.FailType := TQuitType(FRegistry.ReadInteger('FailType'));
    if ValueExists('FailUrl') then FQuitOper.FailUrl := FRegistry.ReadString('FailUrl');

    CloseKey();
  end;
end;

procedure TQuizProp.SaveToReg;
begin
  if not FRegistry.OpenKey(QUIZ_KEY_NAME + '\Properties', True) then Exit;

  with FRegistry do
  begin
    WriteInteger('SubmitType', Ord(FSubmitType));
    WriteInteger('PassRate', FPassRate);
    WriteBool('TimeEnabled', FTimeSet.Enabled);
    WriteInteger('Minutes', FTimeSet.Minutes);
    WriteInteger('Seconds', FTimeSet.Seconds);
    WriteBool('ShowQuesNo', FShowQuesNo);
    WriteBool('RndAnswer', FRndAnswer);
    WriteBool('ShowAnswer', FShowAnswer);
    WriteBool('ViewQuiz', FViewQuiz);

    WriteBool('PassEnabled', FPassSet.Enabled);
    WriteString('PassInfo', FPassSet.PassInfo);
    WriteString('FailInfo', FPassSet.FailInfo);

    WriteBool('PostEnabled', FPostSet.Enabled);
    WriteString('PostUrl', FPostSet.Url);
    WriteInteger('PostType', Ord(FPostSet._Type));
    //MailSet...
    WriteBool('MailEnabled', FMailSet.Enabled);
    WriteString('MailAddr', FMailSet.MailAddr);
    WriteString('MailUrl', FMailSet.MailUrl);
    WriteInteger('MailType', Ord(FMailSet._Type));
    //QuitOper...
    WriteInteger('PassType', Ord(FQuitOper.PassType));
    WriteString('PassUrl', FQuitOper.PassUrl);
    WriteInteger('FailType', Ord(FQuitOper.FailType));
    WriteString('FailUrl', FQuitOper.FailUrl);

    CloseKey();
  end;
end;

{ TQuizSet }

constructor TQuizSet.Create;
begin
  FRegistry := TRegistry.Create;
  FRegistry.RootKey := HKEY_CURRENT_USER;

  LoadFromReg();
end;

destructor TQuizSet.Destroy;
begin
  FRegistry.Free;
  inherited;
end;

procedure TQuizSet.InitData;
begin
  FFontSetT.Size := 12;
  //这里用clBlack而不能用clWindowText，是因为导出为Word时，它不认clWindowText之数值
  FFontSetT.Color := clBlack;
  FFontSetA.Size := 12;
  FFontSetA.Color := clBlack;
  FPoints := 10;
  FAttempts := 1;
  FQuesLevel := qlMiddle;
  FFeedInfo.Enabled := True;
  FFeedInfo.CrtInfo := '恭喜您，答对了';
  FFeedInfo.ErrInfo := '您答错了';

  FShowIcon := True;
  FShowSplash := True;
end;

procedure TQuizSet.LoadFromReg;
begin
  InitData();
  if not FRegistry.KeyExists(QUIZ_KEY_NAME + '\Settings') then Exit;

  with FRegistry do
  begin
    OpenKey(QUIZ_KEY_NAME + '\Settings', False);

    if ValueExists('FontSizeT') then FFontSetT.Size := ReadInteger('FontSizeT');
    if ValueExists('FontColorT') then FFontSetT.Color := ReadInteger('FontColorT');
    if ValueExists('FontBoldT') then FFontSetT.Bold := ReadBool('FontBoldT');
    if ValueExists('FontSizeA') then FFontSetA.Size := ReadInteger('FontSizeA');
    if ValueExists('FontColorA') then FFontSetA.Color := ReadInteger('FontColorA');
    if ValueExists('FontBoldA') then FFontSetA.Bold := ReadBool('FontBoldA');
    if ValueExists('Points') then FPoints := ReadInteger('Points');
    if ValueExists('Attempts') then FAttempts := ReadInteger('Attempts');
    if ValueExists('QuesLevel') then FQuesLevel := TQuesLevel(ReadInteger('QuesLevel'));
    if ValueExists('CrtInfo') then FFeedInfo.CrtInfo := ReadString('CrtInfo');
    if ValueExists('ErrInfo') then FFeedInfo.ErrInfo := ReadString('ErrInfo');
    if ValueExists('ShowIcon') then FShowIcon := ReadBool('ShowIcon');
    if ValueExists('SetAudio') then FSetAudio := ReadBool('SetAudio');
    if ValueExists('ShowSplash') then FShowSplash := ReadBool('ShowSplash');

    CloseKey();
  end;
end;

procedure TQuizSet.SaveToReg;
begin
  if not FRegistry.OpenKey(QUIZ_KEY_NAME + '\Settings', True) then Exit;

  with FRegistry do
  begin
    WriteInteger('FontSizeT', FFontSetT.Size);
    WriteInteger('FontColorT', FFontSetT.Color);
    WriteBool('FontBoldT', FFontSetT.Bold);
    WriteInteger('FontSizeA', FFontSetA.Size);
    WriteInteger('FontColorA', FFontSetA.Color);
    WriteBool('FontBoldA', FFontSetA.Bold);
    WriteInteger('Points', FPoints);
    WriteInteger('Attempts', Attempts);
    WriteInteger('QuesLevel', Ord(FQuesLevel));
    WriteString('CrtInfo', FFeedInfo.CrtInfo);
    WriteString('ErrInfo', FFeedInfo.ErrInfo);
    WriteBool('ShowIcon', FShowIcon);
    WriteBool('SetAudio', FSetAudio);
    WriteBool('ShowSplash', FShowSplash);

    CloseKey();
  end;
end;

{ TPlayer }

constructor TPlayer.Create;
begin
  FRegistry := TRegistry.Create;
  FRegistry.RootKey := HKEY_CURRENT_USER;
  FTexts := TStringList.Create;

  LoadFromReg();
end;

destructor TPlayer.Destroy;
begin
  FTexts.Free;
  FRegistry.Free;
  inherited;
end;

function TPlayer.GetTexts: string;
var
  sl: TStrings;
begin
  sl := TStringList.Create;
  try
    with sl do
    begin
      Append('全屏播放(&S)');
      Append('正常尺寸(&N)');
      Append('场景页');
      Append('下载中...');
      Append('出题中...');
      Append('开始...');
      Append('试题');
      Append(' / ');
      Append('分');
      Append('试题信息');
      Append('正确');
      Append('错误');
      Append('账号：');
      Append('邮件：');
      Append('记住我');
      Append('提交');
      Append('查看结果');
      Append('上题');
      Append('下题');
      Append('请重试');
      Append('浏览');
      Append('完成');
      Append('确定');
      Append('是');
      Append('否');
      Append('剩余时间');
      Append('题目列表');
      Append('测试结果');
      Append('测试得分：');
      Append('通过分数：');
      Append('试题总分：');
      Append('题目总数：');
      Append('做对题数：');
      Append('做错题数：');
      Append('结果：');
      Append('帐号不能为空，请输入');
      Append('本题为简答题，不参与分数计算；请点击[%s]继续');
      Append('还有题没有做完，您确定要提交并查看结果吗？');
      Append('您确定要提交并查看结果吗？');
      Append('做题截止时间到，请点击[%s]查看结果');
      Append('可接受的答案：');
      Append('参考答案：');
      Append('还有试题没有做，请做完所有题后再继续操作');
      Append('容易');
      Append('初级');
      Append('中级');
      Append('高级');
      Append('困难');
      Append('发送测试结果到网络数据库');
      Append('发送测试结果到出题人邮箱');
      Append('打开/关闭声音');
      //作者信息
      Append('作者信息');
      Append('作者：');
      Append('邮件：');
      Append('主页：');
      Append('描述：');
      //发送部分
      Append('您想要再次发送测试数据到网络数据库么？');
      Append('您想要再次发送测试数据到出题人邮箱么？');
      Append('连接服务器失败；请检测网络，或更改Flash播放器安全设置');
      //登录部分
      Append('帐号：');
      Append('密码：');
      Append('登录');
      Append('密码错误，请重试');
      Append('账号或密码错误，请重试');
      //限制部分
      Append('请在网站[%s]上运行此测试题');
      Append('请在日期[%s]与[%e]之间进行此测试');
      //不显示分数等
      Append('感谢您参与本次测试！');
    end;
    Result := sl.Text;
  finally
    sl.Free;
  end;
end;

procedure TPlayer.InitData;
begin
  with FPlayerSet do
  begin
    ShowTopic := True;
    ShowTitle := True;
    ShowTime := True;
    ShowType := False;
    ShowPoint := True;
    ShowLevel := True;
    ShowTool := True;
    ShowData := True;
    ShowMail := True;
    ShowAudio := True;
    ShowAuthor := True;
    ShowPrev := True;
    ShowNext := True;
    ShowList := True;
  end;
  with FColorSet do
  begin
    BackColor := clWhite;
    TitleColor := $00333333;
    BarColor := $00B99D7F;
    CrtColor := $00008000;
    ErrColor := $00000080;
    BackImage.Enabled := False;
  end;
  FBackSound.Enabled := False;
  FEventSound.Enabled := False;
  with FAuthorSet do
  begin
    Mail := '@';
    Url := 'http://';
  end;

  with FWaterMark do
  begin
    if App.RegType <> rtNone Then
    begin
      Enabled := True;
      if App.RegType = rtTrial then
        Text := '秋风试题大师 试用版'
      else Text := '秋风试题大师 未注册版';
      Link := 'http://www.awindsoft.net';
    end;
  end;
  FTexts.Text := GetTexts;
end;

procedure TPlayer.LoadFromReg;
begin
  InitData();
  if not FRegistry.KeyExists(QUIZ_KEY_NAME + '\PlayerSet') then Exit;

  with FRegistry do
  begin
    OpenKey(QUIZ_KEY_NAME + '\PlayerSet', False);

    with FPlayerSet do
    begin
      if ValueExists('ShowTopic') then ShowTopic := ReadBool('ShowTopic');
      if ValueExists('ShowTitle') then ShowTitle := ReadBool('ShowTitle');
      if ValueExists('ShowTime') then ShowTime := ReadBool('ShowTime');
      if ValueExists('ShowType') then ShowType := ReadBool('ShowType');
      if ValueExists('ShowPoint') then ShowPoint := ReadBool('ShowPoint');
      if ValueExists('ShowLevel') then ShowLevel := ReadBool('ShowLevel');
      if ValueExists('ShowTool') then ShowTool := ReadBool('ShowTool');
      if ValueExists('ShowData') then ShowData := ReadBool('ShowData');
      if ValueExists('ShowMail') then ShowMail := ReadBool('ShowMail');
      if ValueExists('ShowAudio') then ShowAudio := ReadBool('ShowAudio');
      if ValueExists('ShowAuthor') then ShowAuthor := ReadBool('ShowAuthor');
      if ValueExists('ShowPrev') then ShowPrev := ReadBool('ShowPrev');
      if ValueExists('ShowNext') then ShowNext := ReadBool('ShowNext');
      if ValueExists('ShowList') then ShowList := ReadBool('ShowList');
    end;
    with FColorSet do
    begin
      if ValueExists('BackColor') then BackColor := ReadInteger('BackColor');
      if ValueExists('TitleColor') then TitleColor := ReadInteger('TitleColor');
      if ValueExists('BarColor') then BarColor := ReadInteger('BarColor');
      if ValueExists('CrtColor') then CrtColor := ReadInteger('CrtColor');
      if ValueExists('ErrColor') then ErrColor := ReadInteger('ErrColor');
      if ValueExists('BackImageEnabled') then BackImage.Enabled := ReadBool('BackImageEnabled');
      if ValueExists('BackImage') then BackImage.Image := ReadString('BackImage');
      if ValueExists('BackImageAlpha') then BackImage.Alpha := ReadInteger('BackImageAlpha');
      if not FileExists(BackImage.Image) and Assigned(QuizObj) and FileExists(GetDealImgStr(QuizObj.ProjDir + ExtractFileName(BackImage.Image))) then
        BackImage.Image := GetDealImgStr(QuizObj.ProjDir + ExtractFileName(BackImage.Image));
    end;
    with FBackSound do
    begin
      if ValueExists('BackEnabled') then Enabled := ReadBool('BackEnabled');
      if ValueExists('SndFile') then SndFile := ReadString('SndFile');
      if not FileExists(SndFile) and Assigned(QuizObj) and FileExists(QuizObj.ProjDir + ExtractFileName(SndFile)) then
        SndFile := QuizObj.ProjDir + ExtractFileName(SndFile);
      if ValueExists('SndLoop') then LoopPlay := ReadBool('SndLoop');
    end;
    with FEventSound do
    begin
      if ValueExists('EvtEnabled') then Enabled := ReadBool('EvtEnabled');
      if ValueExists('SndCrt') then SndCrt := ReadString('SndCrt');
      if ValueExists('SndErr') then SndErr := ReadString('SndErr');
      if ValueExists('SndTry') then SndTry := ReadString('SndTry');
      if ValueExists('SndPass') then SndPass := ReadString('SndPass');
      if ValueExists('SndFail') then SndFail := ReadString('SndFail');
      if not FileExists(SndCrt) and Assigned(QuizObj) and FileExists(QuizObj.ProjDir + ExtractFileName(SndCrt)) then SndCrt := QuizObj.ProjDir + ExtractFileName(SndCrt);
      if not FileExists(SndErr) and Assigned(QuizObj) and FileExists(QuizObj.ProjDir + ExtractFileName(SndErr)) then SndErr := QuizObj.ProjDir + ExtractFileName(SndErr);
      if not FileExists(SndTry) and Assigned(QuizObj) and FileExists(QuizObj.ProjDir + ExtractFileName(SndTry)) then SndTry := QuizObj.ProjDir + ExtractFileName(SndTry);
      if not FileExists(SndPass) and Assigned(QuizObj) and FileExists(QuizObj.ProjDir + ExtractFileName(SndPass)) then SndPass := QuizObj.ProjDir + ExtractFileName(SndPass);
      if not FileExists(SndFail) and Assigned(QuizObj) and FileExists(QuizObj.ProjDir + ExtractFileName(SndFail)) then SndFail := QuizObj.ProjDir + ExtractFileName(SndFail);
    end;
    with FAuthorSet do
    begin
      if ValueExists('AuthorName') then Name := ReadString('AuthorName');
      if ValueExists('AuthorMail') then Mail := ReadString('AuthorMail');
      if ValueExists('AuthorUrl') then Url := ReadString('AuthorUrl');
      if ValueExists('AuthorDes') then Des := ReadString('AuthorDes');
    end;
    if App.RegType = rtNone then
      with FWaterMark do
      begin
        if ValueExists('WMEnabled') then Enabled := ReadBool('WMEnabled');
        if ValueExists('MarkText') then Text := ReadString('MarkText');
        if ValueExists('MarkLink') then Link := ReadString('MarkLink');
      end;
    if ValueExists('Texts') then FTexts.Text := ReadString('Texts');

    CloseKey();
  end;
end;

procedure TPlayer.SaveToReg;
begin
  if not FRegistry.OpenKey(QUIZ_KEY_NAME + '\PlayerSet', True) then Exit;

  with FRegistry do
  begin
    with FPlayerSet do
    begin
      WriteBool('ShowTopic', ShowTopic);
      WriteBool('ShowTitle', ShowTitle);
      WriteBool('ShowTime', ShowTime);
      WriteBool('ShowType', ShowType);
      WriteBool('ShowPoint', ShowPoint);
      WriteBool('ShowLevel', ShowLevel);
      WriteBool('ShowTool', ShowTool);
      WriteBool('ShowData', ShowData);
      WriteBool('ShowMail', ShowMail);
      WriteBool('ShowAudio', ShowAudio);
      WriteBool('ShowAuthor', ShowAuthor);
      WriteBool('ShowPrev', ShowPrev);
      WriteBool('ShowNext', ShowNext);
      WriteBool('ShowList', ShowList);
    end;
    with FColorSet do
    begin
      WriteInteger('BackColor', BackColor);
      WriteInteger('TitleColor', TitleColor);
      WriteInteger('BarColor', BarColor);
      WriteInteger('CrtColor', CrtColor);
      WriteInteger('ErrColor', ErrColor);
      WriteBool('BackImageEnabled', BackImage.Enabled);
      WriteString('BackImage', BackImage.Image);
      WriteInteger('BackImageAlpha', BackImage.Alpha);
    end;
    with FBackSound do
    begin
      WriteBool('BackEnabled', Enabled);
      WriteString('SndFile', SndFile);
      WriteBool('SndLoop', LoopPlay);
    end;
    with FEventSound do
    begin
      WriteBool('EvtEnabled', Enabled);
      WriteString('SndCrt', SndCrt);
      WriteString('SndErr',SndErr );
      WriteString('SndTry', SndTry);
      WriteString('SndPass',SndPass );
      WriteString('SndFail', SndFail);
    end;
    with FAuthorSet do
    begin
      WriteString('AuthorName', Name);
      WriteString('AuthorMail', Mail);
      WriteString('AuthorUrl', Url);
      WriteString('AuthorDes', Des);
    end;
    if (App.RegType = rtNone) and (Pos('秋风试题大师', FWaterMark.Text) = 0) then
      with FWaterMark do
      begin
        WriteBool('WMEnabled', Enabled);
        WriteString('MarkText', Text);
        WriteString('MarkLink', Link);
      end;
    WriteString('Texts', FTexts.Text);

    CloseKey();
  end;
end;

{ TPublish }

constructor TPublish.Create(AOwner: TQuizObj);
begin
  FQuizObj := AOwner;
  FRegistry := TRegistry.Create;
  FRegistry.RootKey := HKEY_CURRENT_USER;

  LoadFromReg();
end;

destructor TPublish.Destroy;
begin
  FRegistry.Free;
  inherited;
end;

procedure TPublish.SetFolder(Value: string);
begin
  FFolder := Value;
  if FFolder[Length(FFolder)] <> '\' then FFolder := FFolder + '\';
end;

procedure TPublish.InitData;
begin
  FPubType := ptWeb;
  FLmsVer := lv12;
  FTitle := 'untitled';
  FFolder := '';
end;

procedure TPublish.LoadFromReg;
begin
  InitData();
  if not FRegistry.KeyExists(QUIZ_KEY_NAME + '\Publish') then Exit;

  with FRegistry do
  begin
    OpenKey(QUIZ_KEY_NAME + '\Publish', False);

    if ValueExists('PubType') then FPubType := TPubType(ReadInteger('PubType'));
    if ValueExists('LmsVer') then FLmsVer := TLmsVer(ReadInteger('LmsVer'));
    if ValueExists('ShowAnswer') then FShowAnswer := ReadBool('ShowAnswer');
    if ValueExists('ShowMenu') then FShowMenu := ReadBool('ShowMenu');
    if ValueExists('Folder') then FFolder := ReadString('Folder');

    CloseKey();
  end;
end;

procedure TPublish.SaveToReg;
begin
  if not FRegistry.OpenKey(QUIZ_KEY_NAME + '\Publish', True) then Exit;

  with FRegistry do
  begin
    WriteInteger('PubType', Ord(FPubType));
    WriteInteger('LmsVer', Ord(FLmsVer));
    WriteBool('ShowAnswer', FShowAnswer);
    WriteBool('ShowMenu', FShowMenu);
    WriteString('Folder', FFolder);

    CloseKey();
  end;
end;

function TPublish.GetRndMode: Boolean;
begin
  with FQuizObj do
    Result := QuizProp.RndQues.Enabled and
      (QuizProp.RndQues.RunTime or (RndCount > 0) and (RndCount < (QuesList.Count - GetQuesCount(qtScene))));
end;

function TPublish.GetRndIdStr(const ARndCount, ATotal: Integer): string;
var
  sCur: string;
  sl: TStrings;
  i: Integer;
begin
  sl := TStringList.Create;
  try
    Randomize();
    while sl.Count < ARndCount do
    begin
      sCur := IntToStr(Random(ATotal));
      //场景题不参与抽题
      if FQuizObj.QuesList[StrToInt(sCur)]._Type = qtScene then Continue;
      for i := 0 to sl.Count - 1 do
        if sCur = sl[i] then Break;

      if (i = sl.Count) or (sl.Count = 0) then
      begin
        sl.Append(sCur);
        Result := Result + ',' + sCur;
      end;
    end;
    Result := Result + ',';
  finally
    sl.Free;
  end;
end;

function TPublish.GetTypeIds(const AQuesType: TQuesType): string;
  function GetTypeRndCount(const AQuesType: TQuesType): Integer;
  begin
    with FQuizObj.QuizProp.RndQues.TypeCount do
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

  function GetTypeIds(const AQuesType: TQuesType): string; overload;
  var
    i: Integer;
  begin
    Result := '';
    for i := 0 to FQuizObj.QuesList.Count - 1 do
      if FQuizObj.QuesList.Items[i]._Type = AQuesType then Result := Result + ',' + IntToStr(i);
  end;

  function GetTypeIds(const ARndCount: Integer; const AQuesType: TQuesType): string; overload;
  var
    i, j, iTypeCount: Integer;
    sIds: string;
    arrType: array of Integer;
  begin
    Result := '';
    iTypeCount := FQuizObj.GetQuesCount(AQuesType);
    SetLength(arrType, iTypeCount);
    j := 0;
    //类型id号取入数组中
    for i := 0 to FQuizObj.QuesList.Count - 1 do
      if FQuizObj.QuesList.Items[i]._Type = AQuesType then
      begin
        arrType[j] := i;
        Inc(j);
      end;
    //再取数组index
    sIds := GetRndIdStr(ARndCount, iTypeCount);
    for i := 0 to iTypeCount - 1 do
      if Pos(Format(',%d,', [i]), sIds) <> 0 then
        Result := Result + ',' + IntToStr(arrType[i]);
  end;

var
  iTypeRndCount: Integer;
begin
  iTypeRndCount := GetTypeRndCount(AQuesType);
  if (iTypeRndCount = -1) or (iTypeRndCount = FQuizObj.GetQuesCount(AQuesType)) then
    Result := GetTypeIds(AQuesType)
  else if iTypeRndCount = 0 then
    Result := ''
  else Result := GetTypeIds(iTypeRndCount, AQuesType);
end;

function TPublish.GetRndIds: string;
var
  i: Integer;
begin
  Result := '';
  with FQuizObj do
    if QuizProp.RndQues.RndType = rtQuiz then
      Result := GetRndIdStr(QuizProp.RndQues.Count, QuesList.Count)
    else
    begin
      for i := Ord(Low(TQuesType)) to Ord(High(TQuesType)) do
        Result := Result + GetTypeIds(TQuesType(i));
      Result := Result + ',';
    end;
end;

function TPublish.GetRndCount: Integer;
  function iif(ATest: Boolean; const ATrue: Integer; const AFalse: Integer): Integer;
  begin
    if ATest then
      Result := ATrue
    else Result := AFalse;
  end;

begin
  with FQuizObj do
  begin
    if QuizProp.RndQues.RndType = rtQuiz then
    begin
      if QuizProp.RndQues.Count = 0 then
        Result := QuesList.Count - GetQuesCount(qtScene)
      else Result := QuizProp.RndQues.Count
    end
    else
      with QuizProp.RndQues.TypeCount do
        Result := iif(Judge = -1, GetQuesCount(qtJudge), Judge) +
                  iif(Single = -1, GetQuesCount(qtSingle), Single) +
                  iif(Multi = -1, GetQuesCount(qtMulti), Multi) +
                  iif(Blank = -1, GetQuesCount(qtBlank), Blank) +
                  iif(Match = -1, GetQuesCount(qtMatch), Match) +
                  iif(Seque = -1, GetQuesCount(qtSeque), Seque) +
                  iif(HotSpot = -1, GetQuesCount(qtHotSpot), HotSpot) +
                  iif(Essay = -1, GetQuesCount(qtEssay), Essay);
  end;
end;

procedure TPublish.DoCancel;
begin
  FCancel := True;
end;

function TPublish.Execute: Boolean;
begin
  Result := False;
  FCancel := False;
  FQuesObj := nil;

  case FPubType of
    ptWeb:
    begin
      BuildHtmlFiles;
      Result := BuildMoive(FFolder + FTitle + '.swf');
    end;
    ptLms:
    begin
      //先生成于临时文件夹中，再复制*.zip到输入目录
      if DirectoryExists(App.TmpPath + FTitle) then DeleteDirectory(App.TmpPath + FTitle);
      CreateDirectory(PAnsiChar(App.TmpPath + FTitle), nil);
      if FLmsVer = lv2004 then CopyFolder(App.Path + 'scorm2004\*.*', App.TmpPath + FTitle);
      BuildHtmlFiles;
      MoveFile(PAnsiChar(Folder + FTitle + '.html'), PAnsiChar(App.TmpPath + FTitle + '\' + FTitle + '.html'));
      Result := BuildMoive(App.TmpPath + FTitle + '\' + FTitle + '.swf');
      BuildLmsFiles;
    end;
    ptWord:  Result := BuildWordDoc;
    ptExcel: Result := BuildExcelDoc;
    ptExe: Result := BuildExeFile;
  end;
end;

procedure TPublish.Preview(AQuesObj: TQuesBase);
var
  sParam, sCaption: string;
begin
  FQuesObj := AQuesObj;
  FCancel := False;

  Screen.Cursor := crHourGlass;
  try
    if BuildMoive(App.TmpPath + QUIZ_PREVIEW, True) then
    begin
      if AQuesObj = nil then
        sCaption := '试题预览 - ' + FQuizObj.QuizProp.QuizTopic
      else sCaption := '单题预览 - ' + FQuizObj.QuizProp.QuizTopic + ' - ' + AQuesObj.Topic;
      PostMessage(FindWindow('#32770', PAnsiChar(sCaption)), WM_CLOSE, 0, 0);
      sParam := StringReplace(App.TmpPath + QUIZ_PREVIEW, '\', '\\', [rfReplaceAll]) + '|' + sCaption;
      ShellExecute(FQuizObj.Handle, nil, PChar(App.Path + 'Viewer.exe'), PAnsiChar(sParam), nil, SW_NORMAL)
    end
    else if AQuesObj <> nil then
      MessageBox(FQuizObj.Handle, PAnsiChar('预览试题[' + AQuesObj.Topic + ']失败！'), '提示', MB_OK + MB_ICONINFORMATION)
    else MessageBox(FQuizObj.Handle, PAnsiChar('预览单题[' + FQuizObj.QuizProp.QuizTopic + ']失败！'), '提示', MB_OK + MB_ICONINFORMATION);
  finally
    Screen.Cursor := crDefault;
  end;
end;

function TPublish.GetGifSprite(AMovie: TFlashMovie;
  AImage: string): TFlashSprite;
var
  gif: TGIFImage;
  png: TPNGObject;
  bmp: TBitmap;
  tmpPng: string;
  i, Speed: Integer;
  SubImg: TGIFSubImage;
  fShape: TFlashShape;
  NextDisposal: TDisposalMethod;
  NextTransparent: Boolean;
begin
  Result := AMovie.AddSprite;
  gif := TGIFImage.Create;
  gif.LoadFromFile(AImage);
  bmp := TBitmap.Create;
  png := TPNGObject.Create;
  tmpPng := App.TmpPath + 'tmp.png';

  InitGDIPlus();
  try
    for i := 0 to gif.Images.Count - 1 do
    begin
      subImg := gif.Images.SubImages[i];
      if subImg.Empty then Continue;

      if Assigned(subImg.GraphicControlExtension) then
        Speed := Round(subImg.GraphicControlExtension.Delay * 10 / 1000 * AMovie.FPS)
      else Speed := 1;
      bmp.Assign(subImg.Bitmap);
      bmp.PixelFormat := pf24bit;
      bmp.Transparent := subImg.Transparent;
      //使之保持透明
      png.Assign(bmp);
      png.SaveToFile(tmpPng);
      fShape := AMovie.AddShapeImage(tmpPng);
      with Result.PlaceObject(fShape, i) do
      begin
        TranslateX := subImg.Left;
        TranslateY := subImg.Top;
      end;
      Result.ShowFrame(Speed);
      if (i < gif.Images.Count - 1) and Assigned(gif.Images.SubImages[i + 1].GraphicControlExtension) then
      begin
        NextDisposal := gif.Images.SubImages[i + 1].GraphicControlExtension.Disposal;
        NextTransparent := gif.Images.SubImages[i + 1].Transparent and (gif.Images.SubImages[i + 1].GraphicControlExtension.TransparentColor = 0);
      end
      else
      begin
        NextDisposal := dmNone;
        NextTransparent := False;
      end;
      if (NextDisposal = dmBackground) or NextTransparent then Result.RemoveObject(i);
    end;
  finally
    gif.Free;
    bmp.Free;
    png.Free;
    GDIPlusShutDown(token);
  end;
end;

procedure TPublish.DealBackImage(const AImage: string;
  AMovie: TFlashMovie);
const
  IMG_WIDTH = 705;
  IMG_HEIGHT = 525;
var
  pic: TPicture;
  bmp: TBitmap;
  jpg: TJPEGImage;
  Rect: TRect;
  fScale: Double;
  Size: TSize;
  fImage: TFlashImage;
begin
  if not FileExists(AImage) then Exit;

  pic := TPicture.Create;
  bmp := TBitmap.Create;
  jpg := TJPEGImage.Create;
  try
    pic.LoadFromFile(AImage);
    bmp.PixelFormat := pf24bit;
    bmp.Canvas.Brush.Color := FQuizObj.Player.ColorSet.BackColor;
    bmp.Width := IMG_WIDTH;
    bmp.Height := IMG_HEIGHT;

    fScale := pic.Height / pic.Width;
    if fScale = IMG_HEIGHT / IMG_WIDTH then
      Rect := Classes.Rect(0, 0, IMG_WIDTH, IMG_HEIGHT)
    else if fScale > IMG_HEIGHT / IMG_WIDTH then
    begin
      fScale := IMG_HEIGHT / pic.Height;
      Rect := Classes.Rect(Round((IMG_WIDTH - pic.Width * fScale) / 2), 0, Round((IMG_WIDTH - pic.Width * fScale) / 2 + pic.Width * fScale), IMG_HEIGHT)
    end
    else
    begin
      fScale := IMG_WIDTH / pic.Width;
      Rect := Classes.Rect(0, Round((IMG_HEIGHT - pic.Height * fScale) / 2), IMG_WIDTH, Round((IMG_HEIGHT - pic.Height * fScale) / 2 + pic.Height * fScale));
    end;

    bmp.Canvas.StretchDraw(Rect, pic.Graphic);
    jpg.Assign(bmp);
    jpg.SaveToFile(App.TmpJpg);

    Size := GetImageSize(App.TmpJpg);
    fImage := AMovie.AddImage();
    fImage.LoadDataFromNativeStream(GetImageStream(App.TmpJpg), True, Size.cx, Size.cy);
    AMovie.ExportAssets(T_BACK_IMAGE, AMovie.AddSprite(AMovie.AddShapeImage(fImage)).CharacterId);
  finally
    pic.Free;
    bmp.Free;
    jpg.Free;
  end;
end;

procedure TPublish.AddImageToMovie(const AImage, ALinkID: string; AMovie: TFlashMovie; AWidth, AHeight: Integer);
var
  sExt: string;
  Size: TSize;
  fImage: TFlashImage;
  fem: TFlashExternalMovie;
begin
  sExt := LowerCase(ExtractFileExt(AImage));

  //处理swf
  if sExt = '.swf' then
  begin
    fem := AMovie.AddExternalMovie(AImage, eimSprite);
    AMovie.ExportAssets(ALinkId, fem.Sprite.CharacterId);
  end
  //gif
  else if sExt = '.gif' then
    AMovie.ExportAssets(ALinkId, GetGifSprite(AMovie, AImage).CharacterId)
  //其它图片
  else if DealImage(AImage, AWidth, AHeight) then
  begin
    Size := GetImageSize(App.TmpJpg);
    fImage := AMovie.AddImage();
    fImage.LoadDataFromNativeStream(GetImageStream(App.TmpJpg), True, Size.cx, Size.cy);
    AMovie.ExportAssets(ALinkId, AMovie.AddSprite(AMovie.AddShapeImage(fImage)).CharacterId);
  end;
end;

procedure TPublish.AddSoundToMovie(const ASndFile, ASndID: string; AMovie: TFlashMovie);
var
  fs: TFlashSound;
begin
  fs := AMovie.AddSound(ASndFile);
  AMovie.ExportAssets(ASndID, fs.CharacterId);
end;

procedure TPublish.AddActionScript(AMovie: TFlashMovie);
  //看之前是否有同名图片，有则取入库ID
  function GetImageId(const AQuesIndex: Integer): string;
  var
    i: Integer;
  begin
    //单题预览，不做处理
    if (FQuizObj.QuesList.Count = 0) or (FQuesObj <> nil) then Exit;
    
    if FQuizObj.QuizProp.QuizImage = FQuizObj.QuesList[AQuesIndex].Image then
    begin
      Result := 'img_info';
      Exit;
    end
    else if FQuesObj <> nil then
    begin
      Result := '';
      Exit;
    end
    else
    begin
      for i := 0 to AQuesIndex - 1 do
      begin
        if FQuizObj.QuesList[i].Image = FQuizObj.QuesList[AQuesIndex].Image then
        begin
          Result := 'img_' + IntToStr(i);
          Exit;
        end;
      end;
    end;
  end;

  function GetHotId(const AQuesIndex: Integer): string;
  var
    i: Integer;
  begin
    if FQuesObj <> nil then
    begin
      Result := '';
      Exit;
    end;
    for i := 0 to AQuesIndex - 1 do
    begin
      if (FQuizObj.QuesList[i]._Type = qtHotSpot) and (TQuesHot(FQuizObj.QuesList[i]).HotImage = TQuesHot(FQuizObj.QuesList[AQuesIndex]).HotImage) then
      begin
        Result := 'hot_' + IntToStr(i);
        Exit;
      end;
    end;
  end;

  //做特殊字符替换
  function GetAsStr(const s: string): string;
  begin
    Result := StringReplace(s, #13#10, '\r', [rfReplaceAll]);
    Result := StringReplace(Result, '$+$', '=', [rfReplaceAll]);
    Result := StringReplace(Result, '"', '\"', [rfReplaceAll]);
    Result := StringReplace(Result, '''', '\''', [rfReplaceAll]);
    Result := StringReplace(Result, '<a href', '<u><a href', [rfReplaceAll]);
    Result := StringReplace(Result, '</a>', '</a></u>', [rfReplaceAll]);
  end;

const
  HOT_MAX_WIDTH = 625;
  HOT_MAX_HEIGHT = 325;
  IMG_WIDTH = 377;
  IMG_HEIGHT = 189;
var
  slAs: TStrings;

  procedure AddTextScript;
  begin
    with slAs, FQuizObj.Player do
    begin
      Append('_global.textObj = new Object();');
      Append(Format('textObj.judge   = "%s";', ['判断题']));
      Append(Format('textObj.single  = "%s";', ['单选题']));
      Append(Format('textObj.multi   = "%s";', ['多选题']));
      Append(Format('textObj.blank   = "%s";', ['填空题']));
      Append(Format('textObj.match   = "%s";', ['匹配题']));
      Append(Format('textObj.seque   = "%s";', ['排序题']));
      Append(Format('textObj.hotSpot = "%s";', ['热区题']));
      Append(Format('textObj.essay   = "%s";', ['简答题']));
      Append(Format('textObj.fullScreen     = "%s";', [GetAsStr(Texts[0])]));
      Append(Format('textObj.normalSize     = "%s";', [GetAsStr(Texts[1])]));
      Append(Format('textObj.scene          = "%s";', [GetAsStr(Texts[2])]));
      Append(Format('textObj.loadQuiz       = "%s";', [GetAsStr(Texts[3])]));
      Append(Format('textObj.buildQuiz      = "%s";', [GetAsStr(Texts[4])]));
      Append(Format('textObj.startCap       = "%s";', [GetAsStr(Texts[5])]));
      Append(Format('textObj.quesCap        = "%s";', [GetAsStr(Texts[6])]));
      Append(Format('textObj.ofLabel        = "%s";', [GetAsStr(Texts[7])]));
      Append(Format('textObj.point          = "%s";', [GetAsStr(Texts[8])]));
      Append(Format('textObj.quizInfo       = "%s";', [GetAsStr(Texts[9])]));
      Append(Format('textObj.crtCap         = "%s";', [GetAsStr(Texts[10])]));
      Append(Format('textObj.errCap         = "%s";', [GetAsStr(Texts[11])]));
      Append(Format('textObj.userID         = "%s";', [GetAsStr(Texts[12])]));
      Append(Format('textObj.userMail       = "%s";', [GetAsStr(Texts[13])]));
      Append(Format('textObj.keepCap        = "%s";', [GetAsStr(Texts[14])]));
      Append(Format('textObj.submit         = "%s";', [GetAsStr(Texts[15])]));
      Append(Format('textObj.viewResult     = "%s";', [GetAsStr(Texts[16])]));
      Append(Format('textObj.prevItem       = "%s";', [GetAsStr(Texts[17])]));
      Append(Format('textObj.nextItem       = "%s";', [GetAsStr(Texts[18])]));
      Append(Format('textObj.tryAgain       = "%s";', [GetAsStr(Texts[19])]));
      Append(Format('textObj.view           = "%s";', [GetAsStr(Texts[20])]));
      Append(Format('textObj.finish         = "%s";', [GetAsStr(Texts[21])]));
      Append(Format('textObj.okLabel        = "%s";', [GetAsStr(Texts[22])]));
      Append(Format('textObj.yesLabel       = "%s";', [GetAsStr(Texts[23])]));
      Append(Format('textObj.noLabel        = "%s";', [GetAsStr(Texts[24])]));
      Append(Format('textObj.remaining      = "%s";', [GetAsStr(Texts[25])]));
      Append(Format('textObj.quesList       = "%s";', [GetAsStr(Texts[26])]));
      Append(Format('textObj.quizResult     = "%s";', [GetAsStr(Texts[27])]));
      Append(Format('textObj.userScore      = "%s";', [GetAsStr(Texts[28])]));
      Append(Format('textObj.passScore      = "%s";', [GetAsStr(Texts[29])]));
      Append(Format('textObj.totalScore     = "%s";', [GetAsStr(Texts[30])]));
      Append(Format('textObj.quesCount      = "%s";', [GetAsStr(Texts[31])]));
      Append(Format('textObj.passQues       = "%s";', [GetAsStr(Texts[32])]));
      Append(Format('textObj.failQues       = "%s";', [GetAsStr(Texts[33])]));
      Append(Format('textObj.showResult     = "%s";', [GetAsStr(Texts[34])]));
      Append(Format('textObj.noBlankUser    = "%s";', [GetAsStr(Texts[35])]));
      Append(Format('textObj.essayInfo      = "%s";', [GetAsStr(Texts[36])]));
      Append(Format('textObj.postInfoNotAll = "%s";', [GetAsStr(Texts[37])]));
      Append(Format('textObj.postInfoView   = "%s";', [GetAsStr(Texts[38])]));
      Append(Format('textObj.timeoutInfo    = "%s";', [GetAsStr(Texts[39])]));
      Append(Format('textObj.accepts        = "%s";', [GetAsStr(Texts[40])]));
      Append(Format('textObj.referAns       = "%s";', [GetAsStr(Texts[41])]));
      Append(Format('textObj.uncplInfo      = "%s";', [GetAsStr(Texts[42])]));
      Append(Format('textObj.itemLevel0     = "%s";', [GetAsStr(Texts[43])]));
      Append(Format('textObj.itemLevel1     = "%s";', [GetAsStr(Texts[44])]));
      Append(Format('textObj.itemLevel2     = "%s";', [GetAsStr(Texts[45])]));
      Append(Format('textObj.itemLevel3     = "%s";', [GetAsStr(Texts[46])]));
      Append(Format('textObj.itemLevel4     = "%s";', [GetAsStr(Texts[47])]));
      Append(Format('textObj.postTip        = "%s";', [GetAsStr(Texts[48])]));
      Append(Format('textObj.mailTip        = "%s";', [GetAsStr(Texts[49])]));
      Append(Format('textObj.audioTip       = "%s";', [GetAsStr(Texts[50])]));
      Append(Format('textObj.infoTip        = "%s";', [GetAsStr(Texts[51])]));
      Append(Format('textObj.author         = "%s";', [GetAsStr(Texts[52])]));
      Append(Format('textObj.email          = "%s";', [GetAsStr(Texts[53])]));
      Append(Format('textObj.url            = "%s";', [GetAsStr(Texts[54])]));
      Append(Format('textObj.des            = "%s";', [GetAsStr(Texts[55])]));
      Append(Format('textObj.postAgain      = "%s";', [GetAsStr(Texts[56])]));
      Append(Format('textObj.mailAgain      = "%s";', [GetAsStr(Texts[57])]));
      Append(Format('textObj.connErr        = "%s";', [GetAsStr(Texts[58])]));
    end;
  end;

  procedure AddRegInfo;
  begin
    if App.RegType <> rtNone then
    begin
      slAs.Append('quizObj.regMail = "";');
      slAs.Append('quizObj.regCode = "";');
    end
    else
    begin
      slAs.Append(Format('quizObj.regMail = "%s";', [App.RegMail]));
      slAs.Append(Format('quizObj.regCode = "%s";', [App.RegCode]));
    end;
  end;

  procedure AddQuesScript(AQuesObj: TQuesBase; AIndex: Integer; AIdStr: string);
  var
    j, HotX, HotY: Integer;
    sLinkId: string;
    ImgSize: TSize;
    fFitScale, fScale: Single;
  begin
    with slAs do
    begin
      Append(Format('quizObj.items[%d] = new Object();', [AIndex]));
      Append(Format('quizObj.items[%d].id      = "%s";', [AIndex, AIdStr]));
      Append(Format('quizObj.items[%d].index   = %d;', [AIndex, AIndex]));
      Append(Format('quizObj.items[%d].topic   = "%s";', [AIndex, GetAsStr(AQuesObj.Topic)]));
      Append(Format('quizObj.items[%d]._type   = %d;', [AIndex, Ord(AQuesObj._Type) + 1]));
      Append(Format('quizObj.items[%d].feedAns = %s;', [AIndex, BoolToLowerStr(AQuesObj.FeedAns)]));
      Append(Format('quizObj.items[%d].score   = %f;', [AIndex, AQuesObj.Points]));
      Append(Format('quizObj.items[%d].attempt = %d;', [AIndex, AQuesObj.Attempts]));
      Append(Format('quizObj.items[%d].level   = getItemLevel(%d);', [AIndex, Ord(AQuesObj.Level)]));
      //处理声音
      if FQuizObj.QuizSet.SetAudio and FileExists(AQuesObj.Audio.FileName) then
      begin
        //加声音等资源入库
        AddSoundToMovie(AQuesObj.Audio.FileName, 'snd_' + IntToStr(AIndex), AMovie);
        Append(Format('quizObj.items[%d].sndObj = new Object();', [AIndex]));
        Append(Format('quizObj.items[%d].sndObj.snd = "snd_%d";', [AIndex, AIndex]));
        Append(Format('quizObj.items[%d].sndObj.pos = 0;', [AIndex, AIndex]));
        Append(Format('quizObj.items[%d].sndObj.autoPlay = %s;', [AIndex, BoolToLowerStr(AQuesObj.Audio.AutoPlay)]));
        Append(Format('quizObj.items[%d].sndObj.loopCount = %d;', [AIndex, AQuesObj.Audio.LoopCount]));
      end;
      if FileExists(AQuesObj.Image) then
      begin
        //加图片等资源入库
        sLinkId := GetImageId(AQuesObj.Index - 1);
        if sLinkId <> '' then
          Append(Format('quizObj.items[%d].img = "%s";', [AIndex, sLinkId]))
        else
        begin
          AddImageToMovie(AQuesObj.Image, 'img_' + IntToStr(AIndex), AMovie);
          Append(Format('quizObj.items[%d].img = "img_%d";', [AIndex, AIndex]));
        end;
      end;
      Append(Format('quizObj.items[%d].movie    = undefined;', [AIndex]));
      Append(Format('quizObj.items[%d].hasDone  = false;', [AIndex]));
      Append(Format('quizObj.items[%d].dealTime = "00:00:00";', [AIndex]));
      Append(Format('quizObj.items[%d].correct  = false;', [AIndex]));
      //答案...
      Append(Format('quizObj.items[%d].ans = new Object();', [AIndex]));
      Append(Format('var ansObj = quizObj.items[%d].ans;', [AIndex]));
      //答案是否已处理过，主要判断排序题
      Append('ansObj.hasDeal = false;');
      //非热区题
      if AQuesObj._Type <> qtHotSpot then
      begin
        //非简答题
        if AQuesObj._Type < qtHotSpot then               
        begin
          Append('ansObj.items = new Array();');
          for j := 0 to TQuesObj(AQuesObj).Answers.Count - 1 do
          begin
            if AQuesObj._Type in [qtBlank, qtSeque] then
            begin
              if Trim(TQuesObj(AQuesObj).Answers[j]) = '' then Continue;

              Append('var aiObj: Object = new Object();');
              Append(Format('aiObj.value = "%s";', [GetAsStr(TQuesObj(AQuesObj).Answers[j])]));
            end
            else
            begin
              if Trim(TQuesObj(AQuesObj).Answers.ValueFromIndex[j]) = '' then Continue;
              //答案级反馈
              if Copy(Trim(TQuesObj(AQuesObj).Answers.ValueFromIndex[j]), 1, 4) = '$$$$' then Continue;

              Append('var aiObj: Object = new Object();');
              if not AQuesObj.FeedAns then
                Append(Format('aiObj.value = "%s";', [GetAsStr(TQuesObj(AQuesObj).Answers.ValueFromIndex[j])]))
              //答案级反馈之答案
              else if AQuesObj._Type = qtSingle then
                Append(Format('aiObj.value = "%s";', [GetAsStr(AQuesObj.GetAnswer(TQuesObj(AQuesObj).Answers.ValueFromIndex[j]))]))
            end;
            //记录正确答案
            if AQuesObj._Type <= qtMulti then
            begin
              Append(Format('aiObj.correct = %s;', [BoolToLowerStr(TQuesObj(AQuesObj).Answers.Names[j] = 'True')]));
              //答案级反馈之反馈
              if AQuesObj.FeedAns and (AQuesObj._Type = qtSingle) then
                Append(Format('aiObj.feedBack = "%s";', [GetAsStr(AQuesObj.GetFeedback(TQuesObj(AQuesObj).Answers.ValueFromIndex[j]))]));
            end
            else if AQuesObj._Type = qtMatch then
              Append(Format('aiObj.topic = "%s";', [GetAsStr(TQuesObj(AQuesObj).Answers.Names[j])]));

            Append('ansObj.items.push(aiObj);');
          end;
        end
        //简答题、场景页
        else Append(Format('ansObj.refAns = "%s";', [GetAsStr(TQuesObj(AQuesObj).Answers.Text)]));
      end
      //热区题
      else
      begin
        sLinkId := GetHotId(AIndex);
        if sLinkId <> '' then
          Append(Format('ansObj.src     = "%s";', [sLinkId]))
        else
        begin
          if FileExists(AQuesObj.Image) then
            AddImageToMovie(TQuesHot(AQuesObj).HotImage, 'hot_' + IntToStr(AIndex), AMovie, HOT_MAX_WIDTH - 175, HOT_MAX_HEIGHT)
          else AddImageToMovie(TQuesHot(AQuesObj).HotImage, 'hot_' + IntToStr(AIndex), AMovie, HOT_MAX_WIDTH, HOT_MAX_HEIGHT);
          Append(Format('ansObj.src     = "hot_%d";', [AIndex]));
        end;

        ImgSize := GetImageSize(TQuesHot(AQuesObj).HotImage);
        //图片自适应情况...
        if FileExists(TQuesHot(AQuesObj).HotImage) and TQuesHot(AQuesObj).ImgFit then
        begin
          if (ImgSize.cy / ImgSize.cx) > IMG_HEIGHT / IMG_WIDTH then
            fFitScale := ImgSize.cy / IMG_HEIGHT
          else fFitScale := ImgSize.cx / IMG_WIDTH;

          HotX := Round(TQuesHot(AQuesObj).HotRect.Left * fFitScale);
          HotY := Round(TQuesHot(AQuesObj).HotRect.Top * fFitScale);
        end
        else
        begin
          fFitScale := 1;
          HotX := Round(TQuesHot(AQuesObj).HPos + TQuesHot(AQuesObj).HotRect.Left);
          HotY := Round(TQuesHot(AQuesObj).VPos + TQuesHot(AQuesObj).HotRect.Top);
        end;
        if (ImgSize.cx > HOT_MAX_WIDTH) or (ImgSize.cy > HOT_MAX_HEIGHT) then
        begin
          //这里需要换算...
          if (ImgSize.cy / ImgSize.cx) > HOT_MAX_HEIGHT / HOT_MAX_WIDTH then
            fScale := HOT_MAX_HEIGHT / ImgSize.cy
          else fScale := HOT_MAX_WIDTH / ImgSize.cx;
        end
        else fScale := 1;

        Append(Format('ansObj._x      = %d;', [Round(HotX * fScale)]));
        Append(Format('ansObj._y      = %d;', [Round(HotY * fScale)]));
        Append(Format('ansObj._width  = %d;', [Round(TQuesHot(AQuesObj).HotRect.Right * fFitScale * fScale)]));
        Append(Format('ansObj._height = %d;', [Round(TQuesHot(AQuesObj).HotRect.Bottom * fFitScale * fScale)]));
      end;
      //反馈信息
      if AQuesObj.FeedInfo.Enabled then
      begin
        Append(Format('quizObj.items[%d].feedBack = new Object();', [AIndex]));
        Append(Format('quizObj.items[%d].feedBack.crtInfo = "%s";', [AIndex, GetAsStr(AQuesObj.FeedInfo.CrtInfo)]));
        Append(Format('quizObj.items[%d].feedBack.errInfo = "%s";', [AIndex, GetAsStr(AQuesObj.FeedInfo.ErrInfo)]));
      end;
    end;
  end;

  //取url前面部分
  function GetPolicyFileUrl(const AUrl: string): string;
  begin
    Result := AUrl;
    Result := StringReplace(Result, '://', '$$+$$', []);
    Result := StringReplace(Result, '//', '/', [rfReplaceAll]);
    Result := StringReplace(Result, '$$+$$', '://', []);

    //Result := Copy(Result, 1, RPos('/', Result)) + 'crossdomain.xml';     
  end;

var
  i, iCur: Integer;
  sRndIds: string;
begin
  slAs := TStringList.Create;

  try
    //自定义字符串...
    AddTextScript;

    with FQuizObj, slAs do
    begin
      //加入取level名函数...
      Append('function getItemLevel(level: Number): String {');
      Append('  var strLevel: String;');
      Append('  switch(level) {');
      Append('  case 0:');
      Append('    strLevel = textObj.itemLevel0;');
      Append('    break;');
      Append('  case 1:');
      Append('    strLevel = textObj.itemLevel1;');
      Append('    break;');
      Append('  case 2:');
      Append('    strLevel = textObj.itemLevel2;');
      Append('    break;');
      Append('  case 3:');
      Append('    strLevel = textObj.itemLevel3;');
      Append('    break;');
      Append('  case 4:');
      Append('    strLevel = textObj.itemLevel4;');
      Append('    break;');
      Append('  default:');
      Append('    //do nothing');
      Append('  }');
      Append('');
      Append('  return strLevel;');
      Append('}');

      //登录密码类...
      if QuizProp.PwdSet.Enabled then
      begin
        Append('_global.lgObj = new Object();');
        //标签...
        Append(Format('lgObj.userLabel = "%s";', [GetAsStr(Player.Texts[59])]));
        Append(Format('lgObj.pwdLabel  = "%s";', [GetAsStr(Player.Texts[60])]));
        Append(Format('lgObj.btnLabel  = "%s";', [GetAsStr(Player.Texts[61])]));
        Append(Format('lgObj.errPwd    = "%s";', [GetAsStr(Player.Texts[62])]));
        Append(Format('lgObj.errAll    = "%s";', [GetAsStr(Player.Texts[63])]));
        //赋值...
        Append(Format('lgObj.type = %d;',  [Ord(QuizProp.PwdSet._Type)]));
        if QuizProp.PwdSet._Type = pstPwd then
          Append('lgObj.userPwd = "' + QuizProp.PwdSet.Password + '";')
        else
        begin
          Append('lgObj.checkUrl    = "' + QuizProp.PwdSet.Url + '";');
          Append('lgObj.allowChange = ' + BoolToLowerStr(QuizProp.PwdSet.AllowChangeUserId) + ';');
        end;
      end;
      //网页限制...
      if QuizProp.UrlLimit.Enabled then
      begin
        Append('_global.urlObj = new Object();');
        Append(Format('urlObj.url = "%s";', [QuizProp.UrlLimit.Url]));
        Append(Format('urlObj.msg = "%s";', [GetAsStr(Player.Texts[64])]));
      end;
      //时间限制...
      if QuizProp.DateLimit.Enabled then
      begin
        Append('_global.dateObj = new Object();');
        Append(Format('dateObj.msg       = "%s";', [GetAsStr(Player.Texts[65])]));

        //此可与quiz.as中的getYearStr()所获值做比较
        Append(Format('dateObj.startDate = "%s";', [FormatDateTime('yyyy-mm-dd', QuizProp.DateLimit.StartDate)]));
        Append(Format('dateObj.endDate   = "%s";', [FormatDateTime('yyyy-mm-dd', QuizProp.DateLimit.EndDate)]));
      end;

      //播放器
      Append('_global.plObj = new Object();');
      Append(Format('plObj.topicSize  = %d;', [QuizSet.FontSetT.Size]));
      Append(Format('plObj.topicColor = 0x%s;', [IntToHex(GetRValue(QuizSet.FontSetT.Color), 2) + IntToHex(GetGValue(QuizSet.FontSetT.Color), 2) + IntToHex(GetBValue(QuizSet.FontSetT.Color), 2)]));
      Append(Format('plObj.topicBold  = %s;', [BoolToLowerStr(QuizSet.FontSetT.Bold)]));
      Append(Format('plObj.ansSize    = %d;', [QuizSet.FontSetA.Size]));
      Append(Format('plObj.ansColor   = 0x%s;', [IntToHex(GetRValue(QuizSet.FontSetA.Color), 2) + IntToHex(GetGValue(QuizSet.FontSetA.Color), 2) + IntToHex(GetBValue(QuizSet.FontSetA.Color), 2)]));
      Append(Format('plObj.ansBold    = %s;', [BoolToLowerStr(QuizSet.FontSetA.Bold)]));
      Append('plObj.width = 720;');
      Append('plObj.height = 540;');
      with Player do
      begin
        //播放器设置
        with PlayerSet do
        begin
          Append(Format('plObj.showTop    = %s;', [BoolToLowerStr(ShowTopic)]));
          Append(Format('plObj.showTopic  = %s;', [BoolToLowerStr(ShowTopic and ShowTitle)]));
          Append(Format('plObj.showTime   = %s;', [BoolToLowerStr(ShowTopic and ShowTime)]));
          Append(Format('plObj.showType   = %s;', [BoolToLowerStr(ShowTopic and ShowType)]));
          Append(Format('plObj.showPoint  = %s;', [BoolToLowerStr(ShowTopic and ShowPoint)]));
          Append(Format('plObj.showLevel  = %s;', [BoolToLowerStr(ShowTopic and ShowLevel)]));
          Append(Format('plObj.showTool   = %s;', [BoolToLowerStr(ShowTopic and ShowTool)]));
          Append(Format('plObj.showData   = %s;', [BoolToLowerStr(ShowData and QuizProp.PostSet.Enabled and (QuizProp.PostSet.Url <> '') and (QuizProp.PostSet.Url <> 'http://') and (QuizProp.PostSet._Type <> ptAuto))]));
          Append(Format('plObj.showMail   = %s;', [BoolToLowerStr(ShowMail and QuizProp.MailSet.Enabled and (QuizProp.MailSet._Type <> ptAuto))]));
          Append(Format('plObj.showAudio  = %s;', [BoolToLowerStr(ShowAudio)]));
          Append(Format('plObj.showAuthor = %s;', [BoolToLowerStr(ShowAuthor)]));
          Append(Format('plObj.showPrev   = %s;', [BoolToLowerStr(ShowPrev)]));
          Append(Format('plObj.showNext   = %s;', [BoolToLowerStr(ShowNext)]));
          Append(Format('plObj.showList   = %s;', [BoolToLowerStr(ShowList)]));
        end;
        //播放器颜色
        with ColorSet do
        begin
          Append(Format('plObj.backColor  = "%s";', [GetColorStr(BackColor)]));
          Append(Format('plObj.titleColor = "%s";', [GetColorStr(TitleColor)]));
          Append(Format('plObj.barColor   = "%s";', [GetColorStr(BarColor)]));
          Append(Format('plObj.crtColor   = "%s";', [GetColorStr(CrtColor)]));
          Append(Format('plObj.errColor   = "%s";', [GetColorStr(ErrColor)]));
          Append('plObj.backImage = new Object();');
          Append(Format('plObj.backImage.enabled = %s;', [BoolToLowerStr(BackImage.Enabled)]));
          Append(Format('plObj.backImage.image   = "%s";', [T_BACK_IMAGE]));
          Append(Format('plObj.backImage.alpha   = %d;', [BackImage.Alpha]));
          if BackImage.Enabled and FileExists(BackImage.Image) then DealBackImage(BackImage.Image, AMovie);
        end;
        //背景声音
        if BackSound.Enabled and FileExists(BackSound.SndFile) then
        begin
          AddSoundToMovie(BackSound.SndFile, 'bgSnd', AMovie);
          Append('_global.bsObj = new Object();');
          Append(Format('bsObj.snd  = "%s";', ['bgSnd']));
          Append(Format('bsObj.loop = %s;', [BoolToLowerStr(BackSound.LoopPlay)]));
        end;
        //事件声音
        if EventSound.Enabled then
        begin
          Append('_global.esObj = new Object();'); 
          with EventSound do
          begin
            if FileExists(SndCrt) then
            begin
              AddSoundToMovie(SndCrt, 'sndCrt', AMovie);
              Append(Format('esObj.sndCrt = "%s";', ['sndCrt']));
            end;
            if FileExists(SndErr) then
            begin
              AddSoundToMovie(SndErr, 'sndErr', AMovie);
              Append(Format('esObj.sndErr = "%s";', ['sndErr']));
            end;
            if FileExists(SndTry) then
            begin
              AddSoundToMovie(SndTry, 'sndTry', AMovie);
              Append(Format('esObj.sndTry = "%s";', ['sndTry']));
            end;
            if FileExists(SndPass) then
            begin
              AddSoundToMovie(SndPass, 'sndPass', AMovie);
              Append(Format('esObj.sndPass = "%s";', ['sndPass']));
            end;
            if FileExists(SndFail) then
            begin
              AddSoundToMovie(SndFail, 'sndFail', AMovie);
              Append(Format('esObj.sndFail = "%s";', ['sndFail']));
            end;
          end;
        end;
        //作者信息
        with AuthorSet do
        begin
          Append('_global.auObj = new Object();');
          Append(Format('auObj.name = "%s";', [GetAsStr(Name)]));
          Append(Format('auObj.mail = "%s";', [Mail]));
          Append(Format('auObj.url  = "%s";', [Url]));
          Append(Format('auObj.des  = "%s";', [GetAsStr(Des)]));
        end;
        //水印
        if WaterMark.Enabled then
        begin
          Append('_global.wmObj = new Object();');
          Append(Format('wmObj.text = "%s";', [WaterMark.Text]));
          Append(Format('wmObj.link = "%s";', [WaterMark.Link]));
        end;
      end;

      //赋值开始...
      Append('_global.quizObj = new Object();');
      //注册信息
      AddRegInfo;
      //信息...
      Append(Format('quizObj.ver      = "%s";', [App.Version]));
      Append(Format('quizObj.topic    = "%s";', [GetAsStr(QuizProp.QuizTopic)]));
      Append(Format('quizObj.id       = "%s";', [QuizProp.QuizID]));
      Append(Format('quizObj.appName  = (quizObj.topic != "") ? quizObj.topic : "%s";', [App.Caption]));
      Append(Format('quizObj.showInfo = %s;', [BoolToLowerStr(QuizProp.ShowInfo)]));
      if QuizProp.ShowInfo then
      begin
        Append(Format('quizObj.info      = "%s";', [GetAsStr(QuizProp.QuizInfo)]));
        if FileExists(QuizProp.QuizImage) then
        begin
          AddImageToMovie(QuizProp.QuizImage, 'img_info', AMovie);
          Append('quizObj.img = "img_info";');
        end;
        Append(Format('quizObj.showUser  = %s;', [BoolToLowerStr(QuizProp.ShowName)]));
        Append(Format('quizObj.showMail  = %s;', [BoolToLowerStr(QuizProp.ShowMail)]));
        Append(Format('quizObj.blankUser = %s;', [BoolToLowerStr(not QuizProp.ShowName or QuizProp.ShowName and QuizProp.BlankName)]));
      end;
      //设置...
      Append(Format('quizObj.sngMode    = %s;', [BoolToLowerStr(QuizProp.SubmitType = stOnce)]));
      Append(Format('quizObj.showQuesNo = %s;', [BoolToLowerStr(QuizProp.ShowQuesNo)]));
      Append(Format('quizObj.rndAns     = %s;', [BoolToLowerStr(QuizProp.RndAnswer)]));
      Append(Format('quizObj.showAns    = %s;', [BoolToLowerStr(QuizProp.ShowAnswer)]));
      Append(Format('plObj.showView     = %s;', [BoolToLowerStr(QuizProp.ViewQuiz)]));
      Append('_global.passObj = new Object();');
      Append(Format('passObj.rate = %d;', [QuizProp.PassRate]));
      Append(Format('passObj.show = %s;', [BoolToLowerStr(QuizProp.PassSet.Enabled)]));
      if QuizProp.PassSet.Enabled then
      begin
        Append(Format('passObj.passInfo = "%s";', [GetAsStr(QuizProp.PassSet.PassInfo)]));
        Append(Format('passObj.failInfo = "%s";', [GetAsStr(QuizProp.PassSet.FailInfo)]));
      end
      else Append(Format('passObj.msgText = "%s";', [GetAsStr(Player.Texts[66])]));
      //时间
      if QuizProp.TimeSet.Enabled then
      begin
        Append('_global.timeSet = new Object();');
        Append(Format('timeSet.length = %d;', [QuizProp.TimeSet.Minutes * 60 + QuizProp.TimeSet.Seconds]));
        Append('if (timeSet.length <= 1 || timeSet.length == Number.NaN) {');
        Append('	timeSet.length = 6;');
        Append('}');
      end;
      //运行时随机
      if QuizProp.RndQues.Enabled and QuizProp.RndQues.RunTime and (FQuesObj = nil) then
      begin
        Append('quizObj.runRnd = true;');
        Append(Format('quizObj.rndType = %d;', [Ord(QuizProp.RndQues.RndType)]));
        if QuizProp.RndQues.RndType = rtQuiz then
        begin
          if QuizProp.RndQues.Count <> 0 then
            Append(Format('quizObj.rndCount = %d;', [RndCount]))
          else Append(Format('quizObj.rndCount = %d;', [QuesList.Count - GetQuesCount(qtScene)]));
        end
        else
        begin
          //按题型抽题，写入每种题型抽题数
          if QuizProp.RndQues.TypeCount.Judge >= 0 then
            Append(Format('quizObj.rndJudge = %d;', [QuizProp.RndQues.TypeCount.Judge]))
          else Append(Format('quizObj.rndJudge = %d;', [GetQuesCount(qtJudge)]));
          if QuizProp.RndQues.TypeCount.Single >= 0 then
            Append(Format('quizObj.rndSingle = %d;', [QuizProp.RndQues.TypeCount.Single]))
          else Append(Format('quizObj.rndSingle = %d;', [GetQuesCount(qtSingle)]));
          if QuizProp.RndQues.TypeCount.Multi >= 0 then
            Append(Format('quizObj.rndMulti = %d;', [QuizProp.RndQues.TypeCount.Multi]))
          else Append(Format('quizObj.rndMulti = %d;', [GetQuesCount(qtMulti)]));
          if QuizProp.RndQues.TypeCount.Blank >= 0 then
            Append(Format('quizObj.rndBlank = %d;', [QuizProp.RndQues.TypeCount.Blank]))
          else Append(Format('quizObj.rndBlank = %d;', [GetQuesCount(qtBlank)]));
          if QuizProp.RndQues.TypeCount.Match >= 0 then
            Append(Format('quizObj.rndMatch = %d;', [QuizProp.RndQues.TypeCount.Match]))
          else Append(Format('quizObj.rndMatch = %d;', [GetQuesCount(qtMatch)]));
          if QuizProp.RndQues.TypeCount.Seque >= 0 then
            Append(Format('quizObj.rndSeque = %d;', [QuizProp.RndQues.TypeCount.Seque]))
          else Append(Format('quizObj.rndSeque = %d;', [GetQuesCount(qtSeque)]));
          if QuizProp.RndQues.TypeCount.HotSpot >= 0 then
            Append(Format('quizObj.rndHotSpot = %d;', [QuizProp.RndQues.TypeCount.HotSpot]))
          else Append(Format('quizObj.rndHotSpot = %d;', [GetQuesCount(qtHotSpot)]));
          if QuizProp.RndQues.TypeCount.Essay >= 0 then
            Append(Format('quizObj.rndEssay = %d;', [QuizProp.RndQues.TypeCount.Essay]))
          else Append(Format('quizObj.rndEssay = %d;', [GetQuesCount(qtEssay)]));
          //总随机数
          Append(Format('quizObj.rndCount = %d;', [RndCount]))
        end;
      end
      else Append('quizObj.runRnd = false;');
      //结果...
      if QuizProp.PostSet.Enabled then
      begin
        Append('_global.dataSet = new Object();');
        Append(Format('dataSet.type = %d;', [Ord(QuizProp.PostSet._Type)]));
        Append(Format('dataSet.url = "%s";', [QuizProp.PostSet.Url]));

        Append(Format('System.security.loadPolicyFile("%s");', [GetPolicyFileUrl(QuizProp.PostSet.Url)]));
      end;
      if QuizProp.MailSet.Enabled then
      begin
        Append('_global.mailSet = new Object();');
        Append(Format('mailSet.type = %d;', [Ord(QuizProp.MailSet._Type)]));
        Append(Format('mailSet.mail = "%s";', [QuizProp.MailSet.MailAddr]));
        Append(Format('mailSet.url  = "%s";', [QuizProp.MailSet.MailUrl]));

        if not QuizProp.PostSet.Enabled or (GetPolicyFileUrl(QuizProp.MailSet.MailUrl) <> GetPolicyFileUrl(QuizProp.PostSet.Url)) then
          Append(Format('System.security.loadPolicyFile("%s");', [GetPolicyFileUrl(QuizProp.MailSet.MailUrl)]));
      end;
      Append('_global.quitObj = new Object();');
      Append(Format('quitObj.passType = %d;', [Ord(QuizProp.QuitOper.PassType)]));
      Append(Format('quitObj.passUrl  = "%s";', [QuizProp.QuitOper.PassUrl]));
      Append(Format('quitObj.failType = %d;', [Ord(QuizProp.QuitOper.FailType)]));
      Append(Format('quitObj.failUrl  = "%s";', [QuizProp.QuitOper.FailUrl]));

      //Quiz数值...
      Append('quizObj.userScore  = 0;');
      Append('quizObj.totalScore = 0;');
      Append('quizObj.passScore  = 0;');
      Append('var ansObj: Object;');
      Append('quizObj.items = new Array();');

      if FQuesObj = nil then
      begin
        //是否随机出题且不是运行期随机，且随机数量不是全部
        if RndMode then
        begin
          //非运行时随机
          if not QuizProp.RndQues.RunTime then
          begin
            iCur := 0;
            //此处赋值，以防在循环中每次访问RndIds都会再取值的问题
            sRndIds := RndIds;
            //每题...
            for i := 0 to QuesList.Count - 1 do
            begin
              //取消转换
              if FCancel then Abort;
              if Pos(Format(',%d,', [i]), sRndIds) = 0 then Continue;

              //进度指示
              if Assigned(FDisProgress) then FDisProgress(iCur + 1, RndCount);
              AddQuesScript(QuesList[i], iCur, IntToStr(iCur + 1));
              Inc(iCur);
            end;
            Append(Format('_global.g_totalPage = %d;', [RndCount]));
          end
          //运行时随机
          else
          begin
            iCur := 0;
            //每题...
            for i := 0 to QuesList.Count - 1 do
            begin
              //取消转换
              if FCancel then Abort;
              if QuesList[i]._Type = qtScene then Continue;

              //进度指示
              if Assigned(FDisProgress) then FDisProgress(iCur + 1, RndCount);
              AddQuesScript(QuesList[i], iCur, IntToStr(iCur + 1));
              Inc(iCur);
            end;
            Append(Format('_global.g_totalPage = %d;', [QuesList.Count - GetQuesCount(qtScene)]));
          end;
        end
        //非随机情况
        else
        begin
          //每题...
          iCur := 0;
          for i := 0 to QuesList.Count - 1 do
          begin
            //取消转换
            if FCancel then Abort;

            //进度指示
            if Assigned(FDisProgress) then FDisProgress(i + 1, QuesList.Count);
            if QuesList[i]._Type <> qtScene then
            begin
              AddQuesScript(QuesList[i], i, IntToStr(iCur + 1));
              Inc(iCur);
            end
            else AddQuesScript(QuesList[i], i, '');
          end;
          Append(Format('_global.g_totalPage = %d;', [QuesList.Count]));
        end;
        //全局变量
        Append(Format('_global.g_curPage = %d;', [0]));
      end
      //单题预览
      else
      begin
        if FQuesObj._Type <> qtScene then
          AddQuesScript(FQuesObj, 0, '1')
        else AddQuesScript(FQuesObj, 0, '');
        Append(Format('_global.g_curPage   = %d;', [0]));
        Append(Format('_global.g_totalPage = %d;', [1]));
      end;

      //Lms版本
      if FPubType = ptLms then
      begin
        if FLmsVer = lv12 then
          Append('quizObj.lmsVer = "1.2";')
        else Append('quizObj.lmsVer = "1.3";');
      end;

      //加入影片中...
      slAs.Text := AnsiToUtf8(slAs.Text);
      AMovie.FrameActions.Compile(slAs);
    end;
  finally
    slAs.Free;
  end;
end;

function TPublish.BuildMoive(const AMovieFile: string; AViewMode: Boolean): Boolean;
var
  fmQuiz: TFlashMovie;
  h: HMODULE;
  Stream: TResourceStream;
  feLoader, fePlayer: TFlashExternalMovie;
begin
  Result := False;
  fmQuiz := BuildMovie(720, 540, 12);
  if not Assigned(fmQuiz) then Exit;

  //_global.viewMode = true;
  if AViewMode then
  begin
    with fmQuiz.FrameActions do
    begin
      Push(['_global'], [vtString]);
      GetVariable;
      Push(['g_viewMode', True], [vtString, vtBoolean]);
      SetMember;
    end;
  end;
  if FPubType = ptExe then
  begin
    with fmQuiz.FrameActions do
    begin
      Push(['_global'], [vtString]);
      GetVariable;
      Push(['g_exeMode', True], [vtString, vtBoolean]);
      SetMember;
    end;
  end;
  //fmQuiz.FrameActions.Stop;
  //写入代码
  AddActionScript(fmQuiz);
  h := LoadLibrary('AWQuiz.dll');
  try
    //加入下载条
    Stream := TResourceStream.Create(h, 'loader', 'SWF');
    feLoader := fmQuiz.AddExternalMovie(Stream, eimSprite);
    Stream.Free;
    feLoader.RenameFontName := False;
    with fmQuiz.PlaceObject(feLoader.Sprite, 9999) do
    begin
      TranslateX := 197;
      TranslateY := 125;
    end;
    fmQuiz.ShowFrame();
    fmQuiz.RemoveObject(9999, feLoader.Sprite);
    //合成播放器
    //fePlayer := fmQuiz.AddExternalMovie('E:\codes\quiz\player\player.swf', eimRoot);
    Stream := TResourceStream.Create(h, 'player', 'SWF');
    fePlayer := fmQuiz.AddExternalMovie(Stream, eimRoot);
    Stream.Free;
    fePlayer.RenameFontName := False;
    fmQuiz.PlaceObject(fePlayer.Sprite, 0);
  finally
    FreeLibrary(h);
  end;

  //生成影片
  fmQuiz.MakeStream;
  fmQuiz.SaveToFile(AMovieFile);
  fmQuiz.Free;

  Result := True;
end;

procedure TPublish.BuildHtmlFiles;
var
  slHtml: TStrings;
begin
  slHtml := TStringList.Create;
  try
    with slHtml do
    begin
      Append('<html>');
      Append('');
      Append('<head>');
      if FPubType = ptLms then
        Append('<script language="javascript" type="text/javascript" src="APIWrapper.js"></script>');
      Append('<meta http-equiv="Content-Type" content="text/html">');
      Append('<title>' + FTitle + '</title>');
      if FPubType = ptWeb then Append('<!-- saved from url=(0014)about:internet -->');
      if FPubType = ptLms then
      begin
        Append('<script type="text/javascript">');
        Append('<!--');
        Append('  if (navigator.appName.indexOf("Microsoft") == -1) {');
        Append('    alert("您所使用的浏览器不是基于IE内核的，不支持VBScript；\n您所测试的试题课件将不能与LMS学习系统进行数据交互。")');
        Append('  }');
        Append('  else {');
        Append('    document.write(''<Script Language=\"VBScript\"\>\n'');');
        Append('    document.write(''  On Error Resume Next\n'');');
        Append('    document.write(''  Sub sf_FSCommand(ByVal command, ByVal args)\n'');');
        Append('    document.write(''	   Call sf_DoFSCommand(command, args)\n'');');
        Append('    document.write(''  End Sub\n'');');
        Append('    document.write(''</Script\>\n'');');
        Append('  }');
        Append('//-->');
        Append('</script>');
      end;
      Append('</head>');
      Append('');
      if FPubType = ptWeb then
        Append('<body leftmargin="0" topmargin="12">')
      else Append('<body leftmargin="0" topmargin="12" onLoad="javascript: SCOInitialize(); sf.focus()" onUnload="javascript: SCOFinish()">');
      Append('<center>');
      Append('<font size="4" color="#006699">' + FQuizObj.QuizProp.QuizTopic + '</font>');
      Append('<br><br>');
      Append('<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=7,0,19,0" width="720" height="540" ID="sf" VIEWASTEXT>');
      Append('  <param name="movie" value="' + FTitle + '.swf" />');
      Append('  <param name="quality" value="high" />');
      Append('  <param name="wmode" value="window" />');
      Append('  <param name="allowScriptAccess" value="always" />');
      Append('  <param name="allowFullScreen" value="true" />');
      Append('  <embed src="' + FTitle + '.swf" quality="high" name="sf" allowScriptAccess="always" allowFullScreen="true" pluginspage="http://www.macromedia.com/go/getflashplayer" type="application/x-shockwave-flash" width="720" height="540" />');
      Append('</object>');
      Append('</center>');
      Append('</body>');
      Append('');
      Append('</html>');

      slHtml.SaveToFile(FFolder + FTitle + '.html');
    end;
  finally
    slHtml.Free;
  end;          
end;

procedure TPublish.BuildLmsFiles;
var
  slXml: TStrings;
  xmlDoc: IXMLDocument;
  zip: TVCLZip;
begin
  slXml := TStringList.Create;
  try
    if FLmsVer = lv12 then
    begin
      with slXml do
      begin
        Append('<?xml version="1.0" encoding="utf-8" ?>');
        //Microsoft Sharepoint Kit处的identifier不支持-，所以做其替换
        Append('<manifest identifier="' + StringReplace(FTitle, '-', '_', [rfReplaceAll]) + '" version="1.2" ' +
                 'xmlns="http://www.imsproject.org/xsd/imscp_rootv1p1p2" ' +
                 'xmlns:adlcp="http://www.adlnet.org/xsd/adlcp_rootv1p2" ' +
                 'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ' +
                 'xsi:schemaLocation="http://www.imsproject.org/xsd/imscp_rootv1p1p2 imscp_rootv1p1p2.xsd ' +
                 'http://www.imsglobal.org/xsd/imsmd_rootv1p2p1 imsmd_rootv1p2p1.xsd ' +
                 'http://www.adlnet.org/xsd/adlcp_rootv1p2 adlcp_rootv1p2.xsd">');
        Append('  <metadata>');
        Append('    <schema>ADL SCORM</schema>');
        Append('    <schemaversion>1.2</schemaversion>');
        Append('  </metadata>');
        Append('  <organizations default="AW_QUIZ">');
        Append('    <organization identifier="AW_QUIZ">');
        Append('      <title>' + FTitle + '</title>');
        Append('      <item identifier="AW_QUIZ_SCO" identifierref="AW_QUIZ_RES">');
        Append('        <title>' + FTitle + '</title>');
        Append('        <adlcp:masteryscore>' + IntToStr(FQuizObj.QuizProp.PassRate) + '</adlcp:masteryscore>');
        Append('      </item>');
        Append('    </organization>');
        Append('  </organizations>');
        Append('  <resources>');
        Append('    <resource identifier="AW_QUIZ_RES" type="webcontent" href="' + FTitle + '.html" adlcp:scormtype="sco">');
        Append('      <file href="' + FTitle + '.html" />');
        Append('      <file href="' + FTitle + '.swf" />');
        Append('      <file href="APIWrapper.js" />');
        Append('    </resource>');
        Append('  </resources>');
        Append('</manifest>');
      end;

      CopyFile(PAnsiChar(App.Path + 'scorm12\APIWrapper.js'), PAnsiChar(App.TmpPath + FTitle + '\APIWrapper.js'), False);
    end
    else
    begin
      with slXml do
      begin
        Append('<?xml version="1.0" encoding="utf-8" ?>');
        Append('<manifest identifier="' + StringReplace(FTitle, '-', '_', [rfReplaceAll]) + '" version="1.3" ' +
                 'xmlns="http://www.imsglobal.org/xsd/imscp_v1p1" ' +
                 'xmlns:adlcp="http://www.adlnet.org/xsd/adlcp_v1p3" ' +
                 'xmlns:adlseq="http://www.adlnet.org/xsd/adlseq_v1p3" ' +
                 'xmlns:adlnav="http://www.adlnet.org/xsd/adlnav_v1p3" ' +
                 'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ' +
                 'xmlns:imsss="http://www.imsglobal.org/xsd/imsss" ' +
                 'xsi:schemaLocation="http://www.imsglobal.org/xsd/imscp_v1p1 imscp_v1p1.xsd ' +
                 'http://www.adlnet.org/xsd/adlcp_v1p3 adlcp_v1p3.xsd ' +
                 'http://www.adlnet.org/xsd/adlseq_v1p3 adlseq_v1p3.xsd ' +
                 'http://www.adlnet.org/xsd/adlnav_v1p3 adlnav_v1p3.xsd ' +
                 'http://www.imsglobal.org/xsd/imsss imsss_v1p0.xsd">');
        Append('  <metadata>');
        Append('    <schema>ADL SCORM</schema>');
        Append('    <schemaversion>CAM 1.3</schemaversion>');
        Append('  </metadata>');
        Append('  <organizations default="AW_QUIZ">');
        Append('    <organization identifier="AW_QUIZ">');
        Append('      <title>' + FTitle + '</title>');
        Append('      <item identifier="AW_QUIZ_SCO" identifierref="AW_QUIZ_RES">');
        Append('        <title>' + FTitle + '</title>');
        Append('        <imsss:sequencing>');
        Append('          <imsss:objectives>');
        Append('            <imsss:primaryObjective>');
        Append('              <imsss:minNormalizedMeasure>' + FormatFloat('0.00', FQuizObj.QuizProp.PassRate / 100) + '</imsss:minNormalizedMeasure>');
        Append('            </imsss:primaryObjective>');
        Append('          </imsss:objectives>');
        Append('        </imsss:sequencing>');
        Append('      </item>');
        Append('      <imsss:sequencing>');
				Append('        <imsss:controlMode choice="true" flow="true" />');
		   	Append('      </imsss:sequencing>');
        Append('    </organization>');
        Append('  </organizations>');
        Append('  <resources>');
        Append('    <resource identifier="AW_QUIZ_RES" type="webcontent" href="' + FTitle + '.html" adlcp:scormType="sco">');
        Append('      <file href="' + FTitle + '.html" />');
        Append('      <file href="' + FTitle + '.swf" />');
        Append('      <file href="APIWrapper.js" />');
        Append('    </resource>');
        Append('  </resources>');
        Append('</manifest>');
      end;
    end;

    xmlDoc := NewXMLDocument;
    xmlDoc.Encoding := 'utf-8';
    xmlDoc.XML.Text := AnsiToUtf8(slXml.Text);
    xmlDoc.Active := True;
    xmlDoc.SaveToFile(App.TmpPath + FTitle + '\imsmanifest.xml');

    //打包文件
    if FileExists(FFolder + FTitle + '.zip') then DeleteFile(FFolder + FTitle + '.zip');
    zip := TVCLZip.Create(nil);
    zip.FilesList.Clear;
    zip.FilesList.Add(App.TmpPath + FTitle + '\*.*');
    zip.ZipName := FFolder + FTitle + '.zip';
    zip.Zip;
    zip.Free;
  finally
    slXml.Free;
  end;
end;

function TPublish.BuildWordDoc: Boolean;
var
  Word: TWord;
begin
  Word := TWord.Create(Self);
  try
    Result := Word.Execute;
  finally
    Word.Free;
  end;
end;

function TPublish.BuildExcelDoc: Boolean;
  procedure WriteQues(AQuesObj: TQuesBase; ASheet: OleVariant; ARow: Integer);
  var
    j: Integer;
    sAns: string;
  begin
    //公有信息...题目、分数、类型
    ASheet.Cells[ARow, 1].Value := AQuesObj.Topic;
    ASheet.Cells[ARow, 2].Value := FQuizObj.GetTypeName(AQuesObj._Type);
    ASheet.Cells[ARow, 3].Value := FloatToStr(AQuesObj.Points) + '分';
    //答案
    if AQuesObj._Type <> qtHotSpot then
      for j := 0 to TQuesObj(AQuesObj).Answers.Count - 1 do
      begin
        sAns := TQuesObj(AQuesObj).Answers[j];
        if (AQuesObj._Type in [qtJudge, qtSingle, qtMulti]) and (Pos('False=', sAns) <> 0) then
          ASheet.Cells[ARow, 4 + j].Value := TQuesObj(AQuesObj).Answers.ValueFromIndex[j]
        else ASheet.Cells[ARow, 4 + j].Value := sAns;
      end
    else
    begin
      ASheet.Cells[ARow, 4] := TQuesHot(AQuesObj).HotImage;
      ASheet.Cells[ARow, 5] := TQuesHot(AQuesObj).HPos + TQuesHot(AQuesObj).HotRect.Left;
      ASheet.Cells[ARow, 6] := TQuesHot(AQuesObj).VPos + TQuesHot(AQuesObj).HotRect.Top;
      ASheet.Cells[ARow, 7] := TQuesHot(AQuesObj).HotRect.Right;
      ASheet.Cells[ARow, 8] := TQuesHot(AQuesObj).HotRect.Bottom;
    end;
  end;

var
  vApp, vBook, vSheet: OleVariant;
  i, iCur: Integer;
  sXlsFile, sRndIds: string;
begin
  Result := False;
  try
    vApp := CreateOleObject('Excel.Application');
  except
    MessageBox(FHandle, 'Excel对象创建失败，您的计算机中安装Microsoft Excel了吗？', '提示', MB_OK + MB_ICONINFORMATION);
    Exit;
  end;

  try
    vApp.Caption := FQuizObj.QuizProp.QuizTopic;
    try
      vBook := vApp.Workbooks.Add;
      vSheet := vBook.WorkSheets[1];

      with FQuizObj do
      begin
        if QuizProp.RndQues.Enabled and (RndCount > 0) and (RndCount < (QuesList.Count - GetQuesCount(qtScene))) then
        begin
          iCur := 0;
          sRndIds := RndIds;
          //每题...
          for i := 0 to QuesList.Count - 1 do
          begin
            //取消转换
            if FCancel then Abort;
            if Pos(Format(',%d,', [i]), sRndIds) = 0 then Continue;

            //进度指示
            if Assigned(FDisProgress) then FDisProgress(iCur + 1, RndCount);
            WriteQues(QuesList[i], vSheet, iCur + 1);
            Inc(iCur);
          end;
        end
        else
        begin
          //每题...
          for i := 0 to QuesList.Count - 1 do
          begin
            //取消转换
            if FCancel then Abort;

            //进度指示
            if Assigned(FDisProgress) then FDisProgress(i + 1, QuesList.Count);
            WriteQues(QuesList[i], vSheet, i + 1);
          end;
        end;
      end;

      sXlsFile := FFolder + FTitle + '.xls';
      with FQuizObj.QuizProp.PwdSet do
      begin
        if Enabled and (_Type = pstPwd) then
          vBook.SaveAs(sXlsFile, xlWorkbookNormal, Password)
        else vBook.SaveAs(sXlsFile);
      end;

      vBook.Close;
      Result := True;
    except
      on E: Exception do
      begin
        MessageBox(FHandle, PAnsiChar('试题导出为Excel文档失败，信息为：' + E.Message), '提示', MB_OK + MB_ICONINFORMATION);
        Result := False;
      end;
    end;
  finally
    vApp.Quit;
    vApp := Unassigned;
  end;
end;

function TPublish.BuildExeFile: Boolean;
var
  sMovie: string;
begin
  sMovie := App.TmpPath + FTitle + '.swf';
  Result := BuildMoive(sMovie);
  if Result then Result := CombineFile(sMovie);
end;

function TPublish.CombineFile(const AMovieFile: string): Boolean;
var
  h: HMODULE;
  sExeFile: string;
  Stream: TResourceStream;
  RStream, WStream: TFileStream;
  flag, SwfFileSize: DWORD;
begin
  sExeFile := FFolder + FTitle + '.exe';
  try
    h := LoadLibrary('AWQuiz.dll');
    WStream := TFileStream.Create(sExeFile, fmCreate);
    try
      //加入下载条
      Stream := TResourceStream.Create(h, 'aplayer', 'EXE');
      try
        WStream.CopyFrom(Stream, Stream.Size);
      finally
        Stream.Free;
      end;

      RStream := TFileStream.Create(AMovieFile, fmOpenRead or fmShareDenyWrite);
      try
        WStream.CopyFrom(RStream, RStream.Size);
        flag := $FA123456;
        WStream.Write(flag, 4);
        SwfFileSize := RStream.Size;
        WStream.Write(SwfFileSize, 4);
        //写入是否显示菜单信息
        if FShowMenu then
          flag := $1
        else flag := $0;
        WStream.Write(flag, 4);
      finally
        RStream.Free;
      end;
    finally
      WStream.Free;
      FreeLibrary(h);
    end;
    Result := True;
  except
    Result := False;
  end;
end;

end.

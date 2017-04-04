{
  �ļ�����Quiz.pas
  ˵  ���������빤�̹�����
  ��д�ˣ�������                                                                                            
  ��  �ڣ�2007-05-19
  ��  �£�2008-06-21������ڱ���ActionScriptʱ��"�����Ĵ�����\"������"���
          2009-03-06�������ļ���Ϊ�������������Դ�ļ����빤���ļ���
}

unit Quiz;

interface

uses
  Windows, Messages, Classes, Controls, SysUtils, Variants, Graphics, Forms,
  Dialogs, Registry, ShellAPI, FlashObjects, SWFConst, ComObj, ExcelXP, XMLDoc, XMLIntf;

const
  //ע����洢����
  QUIZ_KEY_NAME = 'Software\QuizBuilder';
  //Ԥ���ļ���...����һ������������ļ���Ϊview.swf���򲻹�ѡ[���������߸ı䴫����û��ʺ�]��������
  QUIZ_PREVIEW  = 'quiz_view.swf';
  T_BACK_IMAGE  = 'img_back.jpg';
  WM_QUIZCHANGE = WM_USER + 201;
  WM_OUTERPROJ  = WM_USER + 202;
  QUIZ_RESET    = 0;
  QUIZ_CHANGED  = 1;
  QUIZ_RESORT   = 2;
  //������๤������
  QUIZ_MAX_LIST = 3;

type
  //��ʾ������Ϣ֮�ص�����ԭ��
  TDisProgress = procedure(ACurPos, AMaxPos: Integer); stdcall;
  //ע�⣺�Լ�¼������Ϊ���Ա����ֵʱ�ô���һ��¼��ֵ��������ֱ�Ӹ���¼�г�Աֵ�����߰���������with����
  //������Ϣ
  TFeedInfo = record
    Enabled: Boolean;
    CrtInfo: string;
    ErrInfo: string;
  end;
  //��������
  TFontSet = record
    Size: Integer;
    Color: TColor;
    Bold: Boolean;
  end;
  //����������...
  //��������
  TQuesAudio = record
    FileName: string;
    AutoPlay: Boolean;
    LoopCount: Integer;
  end;                                                                                    //����
  TQuesType = (qtJudge, qtSingle, qtMulti, qtBlank, qtMatch, qtSeque, qtHotSpot, qtEssay, qtScene);
  //�����Ѷ�
  TQuesLevel = (qlEasy, qlPrimary, qlMiddle, qlDiffic, qlHard, qlEssay, qlScene);

  //�������
  TQuesBase = class
  private
    FIndex: Integer;
    FTopic: string;
    FAudio: TQuesAudio;
    FType: TQuesType;
    //��ѡ��-�𰸼�����
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
    //Ϊ��ѡ��𰸼���������
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

  //��������
  TQuesObj = class(TQuesBase)
  private
    //�Դ���ʽ��¼��
    FAnswers: TStrings;
  public
    constructor Create(AQuesType: TQuesType = qtJudge); override;
    destructor Destroy; override;
    procedure Assign(Source: TQuesBase); override;

    property Answers: TStrings read FAnswers write FAnswers;
  end;

  //������
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

  //��Ŀ�б�
  TQuesList = class(TList)
  private
    //�Ƿ���Topic��ͬ����
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
    //����Index����
    procedure Resort;
    //����...
    property Items[Index: Integer]: TQuesBase read Get write Put; default;
    property HasSameItem: Boolean read GetSameItem;
    property TotalPoint: Double read GetTotalPoint;
  end;

  //���������ÿ�ʼ��...
  TQuizProp = class;
  TPlayer   = class;
  TQuizSet  = class;                                                             
  TPublish  = class;
  //���̹�����
  TQuizObj = class
  private
    //����·��
    FProjPath: string;
    //����xml�����ļ�
    FProjFile: string;
    FProjDir: string;
    //�����ھ��
    FHandle: HWND;
    FChanged: Boolean;
    FQuizProp: TQuizProp;
    FPlayer: TPlayer;
    FQuizSet: TQuizSet;
    FPublish: TPublish;
    FQuesList: TQuesList;
    //Ϊ׷�Ӽƣ���LoadData�в��
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
    //���ع���
    function LoadProj(const AProjPath: string): Boolean;
    //׷�ӹ���
    function AppendProj(const AProjPath: string): Boolean;
    //����Excel
    function LoadExcel(const AXlsName: string): Boolean;
    //���湤��
    function SaveProj: Boolean;
    //���湤��
    function SaveProjAs: Boolean;
    //��ȡָ��������
    function GetTypeName(AQuesType: TQuesType): string;
    //����������ȡ����
    function GetTypeFromName(const ATypeName: string): TQuesType;
    //��ȡָ����������
    function GetQuesCount(AQuesType: TQuesType): Integer;

    property ProjPath: string read FProjPath;
    property ProjDir: string read FProjDir;
    property Handle: HWND read FHandle write FHandle;
    property Changed: Boolean read FChanged write FChanged;
    //��������
    property QuizProp: TQuizProp read FQuizProp write FQuizProp;
    property Player: TPlayer read FPlayer write FPlayer;
    property QuizSet: TQuizSet read FQuizSet write FQuizSet;
    property Publish: TPublish read FPublish write FPublish;
    property QuesList: TQuesList read FQuesList write FQuesList;
  end;

  //Quiz�������������...
  TSubmitType = (stOnce, stAll);
  //ʱ��
  TTimeSet = record
    Enabled: Boolean;
    Minutes: Integer;
    Seconds: Integer;
  end;
  //�������
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
    //������
    TypeCount: TTypeCount;
    RunTime: Boolean;
  end;
  TPostType = (ptManual, ptAuto);
  //�����������ݿ�
  TPostSet = record
    Enabled: Boolean;
    Url: string;
    _Type: TPostType;
  end;
  //�ʼ���������
  TMailSet = record
    Enabled: Boolean;
    MailAddr: string;
    MailUrl: string;
    _Type: TPostType;
  end;
  //���Խ�������
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
  //���뱣��
  TPwdType = (pstPwd, pstWeb);
  TPwdSet = record
    Enabled: Boolean;
    _Type: TPwdType;
    Password: string;
    Url: string;
    AllowChangeUserId: Boolean;
  end;
  //��ҳ��֤
  TUrlLimit = record
    Enabled: Boolean;
    Url: string;
  end;
  //��������
  TDateLimit = record
    Enabled: Boolean;
    StartDate: TDate;
    EndDate: TDate;
  end;
  //������
  TQuizProp = class
  private
    //������Ϣ
    FQuizTopic: string;
    FQuizID: string;
    FShowInfo: Boolean;
    FQuizInfo: string;
    FQuizImage: string;
    FShowName: Boolean;
    FShowMail: Boolean;
    FBlankName: Boolean;
    //��������
    FSubmitType: TSubmitType;
    FPassRate: Integer;
    FTimeSet: TTimeSet;
    FRndQues: TRndQues;
    FShowQuesNo: Boolean;
    FRndAnswer: Boolean;
    FShowAnswer: Boolean;
    FViewQuiz: Boolean;
    //�������
    FPassSet: TPassSet;
    FPostSet: TPostSet;
    FMailSet: TMailSet;
    FQuitOper: TQuitOper;
    //���Ᵽ��
    FPwdSet: TPwdSet;
    FUrlLimit: TUrlLimit;
    FDateLimit: TDateLimit;

    FRegistry: TRegistry;
    //��¼��ǩҳ
    FPageIndex: Integer;
    procedure InitData;
    //��ע�������
    procedure LoadFromReg;
  public
    constructor Create;
    destructor Destroy; override;

    //���浽ע���
    procedure SaveToReg;
    //������Ϣ
    property QuizTopic: string read FQuizTopic write FQuizTopic;
    property QuizID: string read FQuizID write FQuizID;
    property ShowInfo: Boolean read FShowInfo write FShowInfo;
    property QuizInfo: string read FQuizInfo write FQuizInfo;
    property QuizImage: string read FQuizImage write FQuizImage;
    property ShowName: Boolean read FShowName write FShowName;
    property ShowMail: Boolean read FShowMail write FShowMail;
    property BlankName: Boolean read FBlankName write FBlankName;
    //��������
    property SubmitType: TSubmitType read FSubmitType write FSubmitType;
    property PassRate: Integer read FPassRate write FPassRate;
    property TimeSet: TTimeSet read FTimeSet write FTimeSet;
    property RndQues: TRndQues read FRndQues write FRndQues;
    property ShowQuesNo: Boolean read FShowQuesNo write FShowQuesNo;
    property RndAnswer: Boolean read FRndAnswer write FRndAnswer;
    property ShowAnswer: Boolean read FShowAnswer write FShowAnswer;
    property ViewQuiz: Boolean read FViewQuiz write FViewQuiz;
    //�������
    property PassSet: TPassSet read FPassSet write FPassSet;
    property PostSet: TPostSet read FPostSet write FPostSet;
    property MailSet: TMailSet read FMailSet write FMailSet;
    property QuitOper: TQuitOper read FQuitOper write FQuitOper;
    //���Ᵽ��
    property PwdSet: TPwdSet read FPwdSet write FPwdSet;
    property UrlLimit: TUrlLimit read FUrlLimit write FUrlLimit;
    property DateLimit: TDateLimit read FDateLimit write FDateLimit;

    property PageIndex: Integer read FPageIndex write FPageIndex;
  end;

  //Quiz����������
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
  
  //������������...
  //������
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
  //��ɫ
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
  //��������
  TBackSound = record
    Enabled: Boolean;
    SndFile: string;
    LoopPlay: Boolean;
  end;
  //�¼�����
  TEventSound = record
    Enabled: Boolean;
    SndCrt: string;
    SndErr: string;
    SndTry: string;
    SndPass: string;
    SndFail: string;
  end;
  //������Ϣ
  TAuthorSet = record
    Name: string;
    Mail: string;
    Url: string;
    Des: string;
  end;
  //ˮӡ
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

  //����������
  TPubType = (ptWeb, ptLms, ptWord, ptExcel, ptExe);
  TLmsVer = (lv12, lv2004);
  TPublish = class
  private
    FPubType: TPubType;
    FLmsVer: TLmsVer;
    //����Wordʱ�Ƿ���ʾ��
    FShowAnswer: Boolean;
    //����ΪEXEʱ�Ƿ���ʾ�Ҽ��˵�
    FShowMenu: Boolean;
    FTitle: string;
    FFolder: string;
    //ȡ��ת��
    FCancel: Boolean;
    //����Quiz��
    FQuizObj: TQuizObj;
    //Ԥ��������
    FQuesobj: TQuesBase;
    FHandle: THandle;

    FDisProgress: TDisProgress;
    FRegistry: TRegistry;
    procedure SetFolder(Value: string);
    procedure InitData;
    procedure LoadFromReg;
    //��ȡ�����ͳ���֮��Ϣ
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
    //��������...
    function Execute: Boolean;
    //Ԥ��...
    procedure Preview(AQuesObj: TQuesBase = nil);
    //����ӰƬ...
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
    //�ϲ�exe��swf
    function CombineFile(const AMovieFile: string): Boolean;

    //���Ȼص�
    property DisProgress: TDisProgress read FDisProgress write FDisProgress;
    //Ϊ����Word����
    property QuizObj: TQuizObj read FQuizObj;
    property PubType: TPubType read FPubType write FPubType;
    property LmsVer: TLmsVer read FLmsVer write FLmsVer;
    property ShowAnswer: Boolean read FShowAnswer write FShowAnswer;
    property ShowMenu: Boolean read FShowMenu write FShowMenu;
    property Title: string read FTitle write FTitle;
    property Folder: string read FFolder write SetFolder;
    property Cancel: Boolean read FCancel;
    property Handle: THandle read FHandle write FHandle;
    //��������������
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
    qtJudge:   Result := '�ж���';
    qtSingle:  Result := '��ѡ��';
    qtMulti:   Result := '��ѡ��';
    qtBlank:   Result := '�����';
    qtMatch:   Result := 'ƥ����';
    qtSeque:   Result := '������';
    qtHotSpot: Result := '������';
    qtEssay:   Result := '�����';
    qtScene:   Result := '����ҳ';
  end;
end;

function TQuesBase.GetLevelName: string;
begin
  case FLevel of
    qlEasy:    Result := '����';
    qlPrimary: Result := '����';
    qlMiddle:  Result := '�м�';
    qlDiffic:  Result := '�߼�';
    qlHard:    Result := '����';
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

//ת������...
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
      //��ֵ
      QuesBase.Index := VarToInt(xnChild.Attributes['id'], i);
      QuesBase.FeedAns := VarToBool(xnChild.Attributes['feedAns']);
      QuesBase.Points := VarToFloat(xnChild.Attributes['points']);
      QuesBase.Attempts := VarToInt(xnChild.Attributes['attempts'], 1);
      QuesBase.Level := TQuesLevel(VarToInt(xnChild.Attributes['level']));
      QuesBase.Image := VarToStr(xnChild.Attributes['image']);
      //��������������ʱ�ļ����µ�
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
      //��Ŀ&��
      QuesBase.Topic := xnChild.ChildNodes[0].Text;
      if QuesBase._Type <> qtHotSpot then
        TQuesObj(QuesBase).Answers.Text := xnChild.ChildNodes[1].Text
      else
      //ȡHotSpot���ʹ�
      begin
        with TQuesHot(QuesBase), xnChild.ChildNodes[1] do
        begin
          HotImage := Text;
          if not FileExists(HotImage) then HotImage := GetDealImgStr(FProjDir + ExtractFileName(HotImage));
          if not FileExists(HotImage) then MessageBox(FHandle, PAnsiChar('������[' + QuesBase.Topic + ']������ͼƬ�����ڣ�����������غ�����ָ��'), '��ʾ', MB_OK + MB_ICONWARNING);

          HPos := VarToInt(Attributes['hpos']);
          VPos := VarToInt(Attributes['vpos']);
          HotRect := Rect(VarToInt(Attributes['left']), VarToInt(Attributes['top']), VarToInt(Attributes['width']), VarToInt(Attributes['height']));
          ImgFit := VarToBool(Attributes['fit']);
        end;
      end;
      //������Ϣ
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

      //���������б���
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

  //�Ƿ�v1.3.6��ǰ�Ĺ����ļ�
  if IsXMLDoc(FProjPath) then
    FProjFile := FProjPath
  else if not ExtendProj(FProjPath) then Exit;

  xml := NewXMLDocument;
  try
    xml.LoadFromFile(FProjFile);
    xml.Active := True;
    xnRoot := xml.DocumentElement;
    //��������
    xnPar := xnRoot.ChildNodes.FindNode('properties');
    if xnPar <> nil then
    begin
      with FQuizProp do
      begin
        QuizTopic := xnPar.ChildNodes[0].Text;
        QuizID := xnPar.ChildNodes[1].Text;
        //������Ϣ
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
        //��������
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
              //������
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
        //�������
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
        //���Ᵽ��
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
    //��������
    Result := LoadQues(xnRoot.ChildNodes.FindNode('items'));
  except
    on E: Exception do
    begin
      Result := False;
      MessageBox(FHandle, PAnsiChar('���ع����ļ�������ϢΪ��' + #13#10 + E.Message), '��ʾ', MB_OK + MB_ICONWARNING);
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

      //����...
      xml := NewXMLDocument;
      xml.XML.Text := AnsiToUtf8(slQuiz.Text);
      xml.Active := True;
      //�����Դ�ļ�
      Screen.Cursor := crHourGlass;
      try
        Result := PackProj(xml);
      finally
        Screen.Cursor := crDefault;
      end;

      //���Ѵ�����Ϣ
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

  //����Ҫ�����ͼƬ
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

  //����Ҫ���������
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
    //�����Դ�ļ�...
    //����ͼƬ
    DealProjImage(FQuizProp.QuizImage);
    //����������ͼ
    DealProjImage(FPlayer.ColorSet.BackImage.Image);
    //����ͼƬ&����&����ͼƬ
    for i := 0 to FQuesList.Count - 1 do
    begin
      DealProjImage(FQuesList[i].Image);
      if FQuesList[i]._Type = qtHotSpot then
        DealProjImage(TQuesHot(FQuesList[i]).HotImage);
      DealProjAudio(FQuesList[i].Audio.FileName);
    end;
    //����������
    DealProjAudio(FPlayer.BackSound.SndFile);
    DealProjAudio(FPlayer.EventSound.SndCrt);
    DealProjAudio(FPlayer.EventSound.SndErr);
    DealProjAudio(FPlayer.EventSound.SndTry);
    DealProjAudio(FPlayer.EventSound.SndPass);
    DealProjAudio(FPlayer.EventSound.SndFail);

    //��VCLZip�����ѹ���ļ�
    sZipFile := App.TmpPath + ChangeFileExt(ExtractFileName(FProjPath), '.zip');
    zip := TVCLZip.Create(nil);
    zip.FilesList.Clear;
    zip.FilesList.Add(FProjDir + '*.*');
    zip.ZipName := sZipFile;
    Result := zip.Zip <> 0;
    zip.Free;
    DeleteDirectory(FProjDir);
    if not Result then Exit;

    //����д�빤���ļ���ǣ��Է���WinRAR�ȴ�
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
    //����д�빤���ļ���ǣ��Է���WinRAR�ȴ�
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

    //��ѹ
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

  //�Ƿ�v1.3.6��ǰ�Ĺ����ļ�
  if IsXMLDoc(AProjPath) then
    FProjFile := AProjPath
  else if not ExtendProj(AProjPath) then Exit;

  xml := NewXMLDocument;
  try
    xml.LoadFromFile(FProjFile);
    xml.Active := True;
    xnRoot := xml.DocumentElement;
    //��������
    Result := LoadQues(xnRoot.ChildNodes.FindNode('items'), True);
  except
    on E: Exception do
    begin
      Result := False;
      MessageBox(FHandle, PAnsiChar('׷�ӹ����ļ�������ϢΪ��' + #13#10 + E.Message), '��ʾ', MB_OK + MB_ICONWARNING);
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
    MessageBox(Handle, 'Excel���󴴽�ʧ�ܣ����ļ�������Ƿ�û�а�װMicrosoft Excel��', '��ʾ', MB_OK + MB_ICONINFORMATION);
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

        //��������
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
            QuesBase.Points := VarToFloat(StringReplace(vSheet.Cells[i, 3].Value, '��', '', []));
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
          //�����Ѷ�
          if QuesBase._Type in [qtEssay, qtScene] then
          begin
            QuesBase.Points := 0;
            QuesBase.Level := qlEssay;
          end;

          //���������б���
          QuesList.Append(QuesBase);
          Inc(iIndex);
        end;
      end;

      Result := True;
    except
      on E: Exception do
      begin
        MessageBox(Handle, PAnsiChar('Excel���ݵ���ʧ�ܣ���ϢΪ��' + E.Message), '��ʾ', MB_OK + MB_ICONINFORMATION);
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
    sd.Filter := '�����ļ�(*.aqb)|*.aqb';
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
    qtJudge:   Result := '�ж���';
    qtSingle:  Result := '��ѡ��';
    qtMulti:   Result := '��ѡ��';
    qtBlank:   Result := '�����';
    qtMatch:   Result := 'ƥ����';
    qtSeque:   Result := '������';
    qtHotSpot: Result := '������';
    qtEssay:   Result := '�����';
    qtScene:   Result := '����ҳ';
  end;
end;

function TQuizObj.GetTypeFromName(const ATypeName: string): TQuesType;
begin
  if Pos('�ж�', ATypeName) = 1 then
    Result := qtJudge
  else if Pos('��ѡ', ATypeName) = 1 then
    Result := qtSingle
  else if Pos('��ѡ', ATypeName) = 1 then
    Result := qtMulti
  else if Pos('���', ATypeName) = 1 then
    Result := qtBlank
  else if Pos('ƥ��', ATypeName) = 1 then
    Result := qtMatch
  else if Pos('����', ATypeName) = 1 then
    Result := qtSeque
  else if Pos('����', ATypeName) = 1 then
    Result := qtHotSpot
  else if Pos('���', ATypeName) = 1 then
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
  //������Ϣ
  FQuizTopic := 'δ����';
  FShowInfo := True;
  FShowName := True;
  FShowMail := True;
  FBlankName := True;
  //��������
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
  //�������
  FPassSet.Enabled := True;
  FPassSet.PassInfo := '��ϲ����ͨ����';
  FPassSet.FailInfo := '��û��ͨ��';                    
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
  //��������
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
  //������clBlack��������clWindowText������Ϊ����ΪWordʱ��������clWindowText֮��ֵ
  FFontSetT.Color := clBlack;
  FFontSetA.Size := 12;
  FFontSetA.Color := clBlack;
  FPoints := 10;
  FAttempts := 1;
  FQuesLevel := qlMiddle;
  FFeedInfo.Enabled := True;
  FFeedInfo.CrtInfo := '��ϲ���������';
  FFeedInfo.ErrInfo := '�������';

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
      Append('ȫ������(&S)');
      Append('�����ߴ�(&N)');
      Append('����ҳ');
      Append('������...');
      Append('������...');
      Append('��ʼ...');
      Append('����');
      Append(' / ');
      Append('��');
      Append('������Ϣ');
      Append('��ȷ');
      Append('����');
      Append('�˺ţ�');
      Append('�ʼ���');
      Append('��ס��');
      Append('�ύ');
      Append('�鿴���');
      Append('����');
      Append('����');
      Append('������');
      Append('���');
      Append('���');
      Append('ȷ��');
      Append('��');
      Append('��');
      Append('ʣ��ʱ��');
      Append('��Ŀ�б�');
      Append('���Խ��');
      Append('���Ե÷֣�');
      Append('ͨ��������');
      Append('�����ܷ֣�');
      Append('��Ŀ������');
      Append('����������');
      Append('����������');
      Append('�����');
      Append('�ʺŲ���Ϊ�գ�������');
      Append('����Ϊ����⣬������������㣻����[%s]����');
      Append('������û�����꣬��ȷ��Ҫ�ύ���鿴�����');
      Append('��ȷ��Ҫ�ύ���鿴�����');
      Append('�����ֹʱ�䵽������[%s]�鿴���');
      Append('�ɽ��ܵĴ𰸣�');
      Append('�ο��𰸣�');
      Append('��������û��������������������ټ�������');
      Append('����');
      Append('����');
      Append('�м�');
      Append('�߼�');
      Append('����');
      Append('���Ͳ��Խ�����������ݿ�');
      Append('���Ͳ��Խ��������������');
      Append('��/�ر�����');
      //������Ϣ
      Append('������Ϣ');
      Append('���ߣ�');
      Append('�ʼ���');
      Append('��ҳ��');
      Append('������');
      //���Ͳ���
      Append('����Ҫ�ٴη��Ͳ������ݵ��������ݿ�ô��');
      Append('����Ҫ�ٴη��Ͳ������ݵ�����������ô��');
      Append('���ӷ�����ʧ�ܣ��������磬�����Flash��������ȫ����');
      //��¼����
      Append('�ʺţ�');
      Append('���룺');
      Append('��¼');
      Append('�������������');
      Append('�˺Ż��������������');
      //���Ʋ���
      Append('������վ[%s]�����д˲�����');
      Append('��������[%s]��[%e]֮����д˲���');
      //����ʾ������
      Append('��л�����뱾�β��ԣ�');
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
        Text := '��������ʦ ���ð�'
      else Text := '��������ʦ δע���';
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
    if (App.RegType = rtNone) and (Pos('��������ʦ', FWaterMark.Text) = 0) then
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
      //�����ⲻ�������
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
    //����id��ȡ��������
    for i := 0 to FQuizObj.QuesList.Count - 1 do
      if FQuizObj.QuesList.Items[i]._Type = AQuesType then
      begin
        arrType[j] := i;
        Inc(j);
      end;
    //��ȡ����index
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
      //����������ʱ�ļ����У��ٸ���*.zip������Ŀ¼
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
        sCaption := '����Ԥ�� - ' + FQuizObj.QuizProp.QuizTopic
      else sCaption := '����Ԥ�� - ' + FQuizObj.QuizProp.QuizTopic + ' - ' + AQuesObj.Topic;
      PostMessage(FindWindow('#32770', PAnsiChar(sCaption)), WM_CLOSE, 0, 0);
      sParam := StringReplace(App.TmpPath + QUIZ_PREVIEW, '\', '\\', [rfReplaceAll]) + '|' + sCaption;
      ShellExecute(FQuizObj.Handle, nil, PChar(App.Path + 'Viewer.exe'), PAnsiChar(sParam), nil, SW_NORMAL)
    end
    else if AQuesObj <> nil then
      MessageBox(FQuizObj.Handle, PAnsiChar('Ԥ������[' + AQuesObj.Topic + ']ʧ�ܣ�'), '��ʾ', MB_OK + MB_ICONINFORMATION)
    else MessageBox(FQuizObj.Handle, PAnsiChar('Ԥ������[' + FQuizObj.QuizProp.QuizTopic + ']ʧ�ܣ�'), '��ʾ', MB_OK + MB_ICONINFORMATION);
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
      //ʹ֮����͸��
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

  //����swf
  if sExt = '.swf' then
  begin
    fem := AMovie.AddExternalMovie(AImage, eimSprite);
    AMovie.ExportAssets(ALinkId, fem.Sprite.CharacterId);
  end
  //gif
  else if sExt = '.gif' then
    AMovie.ExportAssets(ALinkId, GetGifSprite(AMovie, AImage).CharacterId)
  //����ͼƬ
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
  //��֮ǰ�Ƿ���ͬ��ͼƬ������ȡ���ID
  function GetImageId(const AQuesIndex: Integer): string;
  var
    i: Integer;
  begin
    //����Ԥ������������
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

  //�������ַ��滻
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
      Append(Format('textObj.judge   = "%s";', ['�ж���']));
      Append(Format('textObj.single  = "%s";', ['��ѡ��']));
      Append(Format('textObj.multi   = "%s";', ['��ѡ��']));
      Append(Format('textObj.blank   = "%s";', ['�����']));
      Append(Format('textObj.match   = "%s";', ['ƥ����']));
      Append(Format('textObj.seque   = "%s";', ['������']));
      Append(Format('textObj.hotSpot = "%s";', ['������']));
      Append(Format('textObj.essay   = "%s";', ['�����']));
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
      //��������
      if FQuizObj.QuizSet.SetAudio and FileExists(AQuesObj.Audio.FileName) then
      begin
        //����������Դ���
        AddSoundToMovie(AQuesObj.Audio.FileName, 'snd_' + IntToStr(AIndex), AMovie);
        Append(Format('quizObj.items[%d].sndObj = new Object();', [AIndex]));
        Append(Format('quizObj.items[%d].sndObj.snd = "snd_%d";', [AIndex, AIndex]));
        Append(Format('quizObj.items[%d].sndObj.pos = 0;', [AIndex, AIndex]));
        Append(Format('quizObj.items[%d].sndObj.autoPlay = %s;', [AIndex, BoolToLowerStr(AQuesObj.Audio.AutoPlay)]));
        Append(Format('quizObj.items[%d].sndObj.loopCount = %d;', [AIndex, AQuesObj.Audio.LoopCount]));
      end;
      if FileExists(AQuesObj.Image) then
      begin
        //��ͼƬ����Դ���
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
      //��...
      Append(Format('quizObj.items[%d].ans = new Object();', [AIndex]));
      Append(Format('var ansObj = quizObj.items[%d].ans;', [AIndex]));
      //���Ƿ��Ѵ���������Ҫ�ж�������
      Append('ansObj.hasDeal = false;');
      //��������
      if AQuesObj._Type <> qtHotSpot then
      begin
        //�Ǽ����
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
              //�𰸼�����
              if Copy(Trim(TQuesObj(AQuesObj).Answers.ValueFromIndex[j]), 1, 4) = '$$$$' then Continue;

              Append('var aiObj: Object = new Object();');
              if not AQuesObj.FeedAns then
                Append(Format('aiObj.value = "%s";', [GetAsStr(TQuesObj(AQuesObj).Answers.ValueFromIndex[j])]))
              //�𰸼�����֮��
              else if AQuesObj._Type = qtSingle then
                Append(Format('aiObj.value = "%s";', [GetAsStr(AQuesObj.GetAnswer(TQuesObj(AQuesObj).Answers.ValueFromIndex[j]))]))
            end;
            //��¼��ȷ��
            if AQuesObj._Type <= qtMulti then
            begin
              Append(Format('aiObj.correct = %s;', [BoolToLowerStr(TQuesObj(AQuesObj).Answers.Names[j] = 'True')]));
              //�𰸼�����֮����
              if AQuesObj.FeedAns and (AQuesObj._Type = qtSingle) then
                Append(Format('aiObj.feedBack = "%s";', [GetAsStr(AQuesObj.GetFeedback(TQuesObj(AQuesObj).Answers.ValueFromIndex[j]))]));
            end
            else if AQuesObj._Type = qtMatch then
              Append(Format('aiObj.topic = "%s";', [GetAsStr(TQuesObj(AQuesObj).Answers.Names[j])]));

            Append('ansObj.items.push(aiObj);');
          end;
        end
        //����⡢����ҳ
        else Append(Format('ansObj.refAns = "%s";', [GetAsStr(TQuesObj(AQuesObj).Answers.Text)]));
      end
      //������
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
        //ͼƬ����Ӧ���...
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
          //������Ҫ����...
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
      //������Ϣ
      if AQuesObj.FeedInfo.Enabled then
      begin
        Append(Format('quizObj.items[%d].feedBack = new Object();', [AIndex]));
        Append(Format('quizObj.items[%d].feedBack.crtInfo = "%s";', [AIndex, GetAsStr(AQuesObj.FeedInfo.CrtInfo)]));
        Append(Format('quizObj.items[%d].feedBack.errInfo = "%s";', [AIndex, GetAsStr(AQuesObj.FeedInfo.ErrInfo)]));
      end;
    end;
  end;

  //ȡurlǰ�沿��
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
    //�Զ����ַ���...
    AddTextScript;

    with FQuizObj, slAs do
    begin
      //����ȡlevel������...
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

      //��¼������...
      if QuizProp.PwdSet.Enabled then
      begin
        Append('_global.lgObj = new Object();');
        //��ǩ...
        Append(Format('lgObj.userLabel = "%s";', [GetAsStr(Player.Texts[59])]));
        Append(Format('lgObj.pwdLabel  = "%s";', [GetAsStr(Player.Texts[60])]));
        Append(Format('lgObj.btnLabel  = "%s";', [GetAsStr(Player.Texts[61])]));
        Append(Format('lgObj.errPwd    = "%s";', [GetAsStr(Player.Texts[62])]));
        Append(Format('lgObj.errAll    = "%s";', [GetAsStr(Player.Texts[63])]));
        //��ֵ...
        Append(Format('lgObj.type = %d;',  [Ord(QuizProp.PwdSet._Type)]));
        if QuizProp.PwdSet._Type = pstPwd then
          Append('lgObj.userPwd = "' + QuizProp.PwdSet.Password + '";')
        else
        begin
          Append('lgObj.checkUrl    = "' + QuizProp.PwdSet.Url + '";');
          Append('lgObj.allowChange = ' + BoolToLowerStr(QuizProp.PwdSet.AllowChangeUserId) + ';');
        end;
      end;
      //��ҳ����...
      if QuizProp.UrlLimit.Enabled then
      begin
        Append('_global.urlObj = new Object();');
        Append(Format('urlObj.url = "%s";', [QuizProp.UrlLimit.Url]));
        Append(Format('urlObj.msg = "%s";', [GetAsStr(Player.Texts[64])]));
      end;
      //ʱ������...
      if QuizProp.DateLimit.Enabled then
      begin
        Append('_global.dateObj = new Object();');
        Append(Format('dateObj.msg       = "%s";', [GetAsStr(Player.Texts[65])]));

        //�˿���quiz.as�е�getYearStr()����ֵ���Ƚ�
        Append(Format('dateObj.startDate = "%s";', [FormatDateTime('yyyy-mm-dd', QuizProp.DateLimit.StartDate)]));
        Append(Format('dateObj.endDate   = "%s";', [FormatDateTime('yyyy-mm-dd', QuizProp.DateLimit.EndDate)]));
      end;

      //������
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
        //����������
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
        //��������ɫ
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
        //��������
        if BackSound.Enabled and FileExists(BackSound.SndFile) then
        begin
          AddSoundToMovie(BackSound.SndFile, 'bgSnd', AMovie);
          Append('_global.bsObj = new Object();');
          Append(Format('bsObj.snd  = "%s";', ['bgSnd']));
          Append(Format('bsObj.loop = %s;', [BoolToLowerStr(BackSound.LoopPlay)]));
        end;
        //�¼�����
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
        //������Ϣ
        with AuthorSet do
        begin
          Append('_global.auObj = new Object();');
          Append(Format('auObj.name = "%s";', [GetAsStr(Name)]));
          Append(Format('auObj.mail = "%s";', [Mail]));
          Append(Format('auObj.url  = "%s";', [Url]));
          Append(Format('auObj.des  = "%s";', [GetAsStr(Des)]));
        end;
        //ˮӡ
        if WaterMark.Enabled then
        begin
          Append('_global.wmObj = new Object();');
          Append(Format('wmObj.text = "%s";', [WaterMark.Text]));
          Append(Format('wmObj.link = "%s";', [WaterMark.Link]));
        end;
      end;

      //��ֵ��ʼ...
      Append('_global.quizObj = new Object();');
      //ע����Ϣ
      AddRegInfo;
      //��Ϣ...
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
      //����...
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
      //ʱ��
      if QuizProp.TimeSet.Enabled then
      begin
        Append('_global.timeSet = new Object();');
        Append(Format('timeSet.length = %d;', [QuizProp.TimeSet.Minutes * 60 + QuizProp.TimeSet.Seconds]));
        Append('if (timeSet.length <= 1 || timeSet.length == Number.NaN) {');
        Append('	timeSet.length = 6;');
        Append('}');
      end;
      //����ʱ���
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
          //�����ͳ��⣬д��ÿ�����ͳ�����
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
          //�������
          Append(Format('quizObj.rndCount = %d;', [RndCount]))
        end;
      end
      else Append('quizObj.runRnd = false;');
      //���...
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

      //Quiz��ֵ...
      Append('quizObj.userScore  = 0;');
      Append('quizObj.totalScore = 0;');
      Append('quizObj.passScore  = 0;');
      Append('var ansObj: Object;');
      Append('quizObj.items = new Array();');

      if FQuesObj = nil then
      begin
        //�Ƿ���������Ҳ���������������������������ȫ��
        if RndMode then
        begin
          //������ʱ���
          if not QuizProp.RndQues.RunTime then
          begin
            iCur := 0;
            //�˴���ֵ���Է���ѭ����ÿ�η���RndIds������ȡֵ������
            sRndIds := RndIds;
            //ÿ��...
            for i := 0 to QuesList.Count - 1 do
            begin
              //ȡ��ת��
              if FCancel then Abort;
              if Pos(Format(',%d,', [i]), sRndIds) = 0 then Continue;

              //����ָʾ
              if Assigned(FDisProgress) then FDisProgress(iCur + 1, RndCount);
              AddQuesScript(QuesList[i], iCur, IntToStr(iCur + 1));
              Inc(iCur);
            end;
            Append(Format('_global.g_totalPage = %d;', [RndCount]));
          end
          //����ʱ���
          else
          begin
            iCur := 0;
            //ÿ��...
            for i := 0 to QuesList.Count - 1 do
            begin
              //ȡ��ת��
              if FCancel then Abort;
              if QuesList[i]._Type = qtScene then Continue;

              //����ָʾ
              if Assigned(FDisProgress) then FDisProgress(iCur + 1, RndCount);
              AddQuesScript(QuesList[i], iCur, IntToStr(iCur + 1));
              Inc(iCur);
            end;
            Append(Format('_global.g_totalPage = %d;', [QuesList.Count - GetQuesCount(qtScene)]));
          end;
        end
        //��������
        else
        begin
          //ÿ��...
          iCur := 0;
          for i := 0 to QuesList.Count - 1 do
          begin
            //ȡ��ת��
            if FCancel then Abort;

            //����ָʾ
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
        //ȫ�ֱ���
        Append(Format('_global.g_curPage = %d;', [0]));
      end
      //����Ԥ��
      else
      begin
        if FQuesObj._Type <> qtScene then
          AddQuesScript(FQuesObj, 0, '1')
        else AddQuesScript(FQuesObj, 0, '');
        Append(Format('_global.g_curPage   = %d;', [0]));
        Append(Format('_global.g_totalPage = %d;', [1]));
      end;

      //Lms�汾
      if FPubType = ptLms then
      begin
        if FLmsVer = lv12 then
          Append('quizObj.lmsVer = "1.2";')
        else Append('quizObj.lmsVer = "1.3";');
      end;

      //����ӰƬ��...
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
  //д�����
  AddActionScript(fmQuiz);
  h := LoadLibrary('AWQuiz.dll');
  try
    //����������
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
    //�ϳɲ�����
    //fePlayer := fmQuiz.AddExternalMovie('E:\codes\quiz\player\player.swf', eimRoot);
    Stream := TResourceStream.Create(h, 'player', 'SWF');
    fePlayer := fmQuiz.AddExternalMovie(Stream, eimRoot);
    Stream.Free;
    fePlayer.RenameFontName := False;
    fmQuiz.PlaceObject(fePlayer.Sprite, 0);
  finally
    FreeLibrary(h);
  end;

  //����ӰƬ
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
        Append('    alert("����ʹ�õ���������ǻ���IE�ں˵ģ���֧��VBScript��\n�������Ե�����μ���������LMSѧϰϵͳ�������ݽ�����")');
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
        //Microsoft Sharepoint Kit����identifier��֧��-�����������滻
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

    //����ļ�
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
    //������Ϣ...��Ŀ������������
    ASheet.Cells[ARow, 1].Value := AQuesObj.Topic;
    ASheet.Cells[ARow, 2].Value := FQuizObj.GetTypeName(AQuesObj._Type);
    ASheet.Cells[ARow, 3].Value := FloatToStr(AQuesObj.Points) + '��';
    //��
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
    MessageBox(FHandle, 'Excel���󴴽�ʧ�ܣ����ļ�����а�װMicrosoft Excel����', '��ʾ', MB_OK + MB_ICONINFORMATION);
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
          //ÿ��...
          for i := 0 to QuesList.Count - 1 do
          begin
            //ȡ��ת��
            if FCancel then Abort;
            if Pos(Format(',%d,', [i]), sRndIds) = 0 then Continue;

            //����ָʾ
            if Assigned(FDisProgress) then FDisProgress(iCur + 1, RndCount);
            WriteQues(QuesList[i], vSheet, iCur + 1);
            Inc(iCur);
          end;
        end
        else
        begin
          //ÿ��...
          for i := 0 to QuesList.Count - 1 do
          begin
            //ȡ��ת��
            if FCancel then Abort;

            //����ָʾ
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
        MessageBox(FHandle, PAnsiChar('���⵼��ΪExcel�ĵ�ʧ�ܣ���ϢΪ��' + E.Message), '��ʾ', MB_OK + MB_ICONINFORMATION);
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
      //����������
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
        //д���Ƿ���ʾ�˵���Ϣ
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
//*******************************************************//
//                                                       //
//                      DelphiFlash.com                  //
//         Copyright (c) 2004-2008 FeatherySoft, Inc.    //
//                    info@delphiflash.com               //
//                                                       //
//*******************************************************//

//  Description:  Level of SWF-objects
//  Last update: 12 mar 2008
{$I defines.inc}
{$WARNINGS OFF}
{$HINTS OFF}

Unit SWFObjects;
interface
 Uses Windows, SysUtils, Classes, SWFConst, Graphics, Contnrs,
 {$IFDEF ExternalUTF}
  Unicode,
 {$ENDIF}
 {$IFDEF VARIANTS}
  Variants,
 {$ENDIF}
  SWFTools;
  
type
  TSWFRect = class (TObject)
  private
    FXmax: LongInt;
    FXmin: LongInt;
    FYmax: LongInt;
    FYmin: LongInt;
    procedure CompareXY(flag: byte);
    function GetHeight: Integer;
    function GetRec: recRect;
    function GetRect: TRect;
    function GetWidth: Integer;
    procedure SetRec(Value: recRect);
    procedure SetRect(Value: TRect);
    procedure SetXmax(Value: LongInt);
    procedure SetXmin(Value: LongInt);
    procedure SetYmax(Value: LongInt);
    procedure SetYmin(Value: LongInt);
  public
    procedure Assign(Source: TSWFRect);
    property Height: Integer read GetHeight;
    property Rec: recRect read GetRec write SetRec;
    property Rect: TRect read GetRect write SetRect;
    property Width: Integer read GetWidth;
    property Xmax: LongInt read FXmax write SetXmax;
    property Xmin: LongInt read FXmin write SetXmin;
    property Ymax: LongInt read FYmax write SetYmax;
    property Ymin: LongInt read FYmin write SetYmin;
  end;
  
  TSWFRGB = class (TObject)
  private
    FB: Byte;
    FG: Byte;
    FR: Byte;
    function GetRGB: recRGB;
    procedure SetRGB(Value: recRGB); virtual;
  public
    procedure Assign(Source: TObject); virtual;
    property B: Byte read FB write FB;
    property G: Byte read FG write FG;
    property R: Byte read FR write FR;
    property RGB: recRGB read GetRGB write SetRGB;
  end;
  
  TSWFRGBA = class (TSWFRGB)
  private
    FA: Byte;
    FHasAlpha: Boolean;
    function GetRGBA: recRGBA;
    procedure SetA(Value: Byte);
    procedure SetHasAlpha(Value: Boolean);
    procedure SetRGBA(Value: recRGBA);
  protected
    procedure SetRGB(value: recRGB); override;
  public
    constructor Create(a: boolean = false);
    procedure Assign(Source: TObject); override;
    property A: Byte read FA write SetA;
    property HasAlpha: Boolean read FHasAlpha write SetHasAlpha;
    property RGBA: recRGBA read GetRGBA write SetRGBA;
  end;

  TSWFColorTransform = class (TObject)
  private
    FaddA: Integer;
    FaddB: Integer;
    FaddG: Integer;
    FaddR: Integer;
    FhasAdd: Boolean;
    FhasAlpha: Boolean;
    FhasMult: Boolean;
    FmultA: Integer;
    FmultB: Integer;
    FmultG: Integer;
    FmultR: Integer;
    function GetREC: recColorTransform;
    procedure SetaddA(Value: Integer);
    procedure SetaddB(Value: Integer);
    procedure SetaddG(Value: Integer);
    procedure SetaddR(Value: Integer);
    procedure SetmultA(Value: Integer);
    procedure SetmultB(Value: Integer);
    procedure SetmultG(Value: Integer);
    procedure SetmultR(Value: Integer);
    procedure SetREC(Value: recColorTransform);
  public
    procedure AddTint(Color: TColor);
    procedure Assign(Source: TSWFColorTransform);
    function CheckAddValue(value: integer): integer;
    function CheckMultValue(value: integer): integer;
    procedure SetAdd(R, G, B, A: integer);
    procedure SetMult(R, G, B, A: integer);
    property addA: Integer read FaddA write SetaddA;
    property addB: Integer read FaddB write SetaddB;
    property addG: Integer read FaddG write SetaddG;
    property addR: Integer read FaddR write SetaddR;
    property hasAdd: Boolean read FhasAdd write FhasAdd;
    property hasAlpha: Boolean read FhasAlpha write FhasAlpha;
    property hasMult: Boolean read FhasMult write FhasMult;
    property multA: Integer read FmultA write SetmultA;
    property multB: Integer read FmultB write SetmultB;
    property multG: Integer read FmultG write SetmultG;
    property multR: Integer read FmultR write SetmultR;
    property REC: recColorTransform read GetREC write SetREC;
  end;

  TSWFMatrix = class (TObject)
  private
    FHasScale: Boolean;
    FHasSkew: Boolean;
    FScaleX: LongInt;
    FScaleY: LongInt;
    FSkewX: LongInt;
    FSkewY: LongInt;
    FTranslateX: LongInt;
    FTranslateY: LongInt;
    function GetREC: recMatrix;
    function GetScaleX: Single;
    function GetScaleY: Single;
    function GetSkewX: Single;
    function GetSkewY: Single;
    procedure SetREC(Value: recMatrix);
    procedure SetScaleX(Value: Single);
    procedure SetScaleY(Value: Single);
    procedure SetSkewX(Value: Single);
    procedure SetSkewY(Value: Single);
  public
    procedure Assign(M : TSWFMatrix);
    procedure SetRotate(angle: single);
    procedure SetScale(ScaleX, ScaleY: single);
    procedure SetSkew(SkewX, SkewY: single);
    procedure SetTranslate(X, Y: LongInt);
    property HasScale: Boolean read FHasScale write FHasScale;
    property HasSkew: Boolean read FHasSkew write FHasSkew;
    property REC: recMatrix read GetREC write SetREC;
    property ScaleX: Single read GetScaleX write SetScaleX;
    property ScaleY: Single read GetScaleY write SetScaleY;
    property SkewX: Single read GetSkewX write SetSkewX;
    property SkewY: Single read GetSkewY write SetSkewY;
    property TranslateX: LongInt read FTranslateX write FTranslateX;
    property TranslateY: LongInt read FTranslateY write FTranslateY;
  end;


  TBasedSWFObject = class (TObject)
  public
    procedure Assign(Source: TBasedSWFObject); virtual; abstract;
    function LibraryLevel: Byte; virtual; abstract;
    function MinVersion: Byte; virtual;
    procedure WriteToStream(be: TBitsEngine); virtual; abstract;
  end;

  TSWFObject = class (TBasedSWFObject)
  private
    FBodySize: LongWord;
    FTagID: Word;
  public
    procedure Assign(Source: TBasedSWFObject); override;
    function GetFullSize: LongInt;
    function LibraryLevel: Byte; override;
    procedure ReadFromStream(be: TBitsEngine); virtual;
    procedure WriteTagBody(be: TBitsEngine); virtual;
    procedure WriteToStream(be: TBitsEngine); override;
    property BodySize: LongWord read FBodySize write FBodySize;
    property TagID: Word read FTagID write FTagID;
  end;

//  TSWFErrorTag = class (TSWFObject)
//  private
//    FTagIDFrom: Word;
//    FText: string;
//  public
//    constructor Create;
//    property TagIDFrom: Word read FTagIDFrom write FTagIDFrom;
//    property Text: string read FText write FText;
//  end;

  TSWFTagEvent = procedure (sender: TSWFObject; BE: TBitsEngine) of object;
// ===========================================================
//                Control Tags
// ===========================================================

  TSWFSetBackgroundColor = class (TSWFObject)
  private
    FColor: TSWFRGB;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TBasedSWFObject); override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteTagBody(be: TBitsEngine); override;
    property Color: TSWFRGB read FColor;
  end;

  TSWFFrameLabel = class (TSWFObject)
  private
    FisAnchor: Boolean;
    FName: string;
  public
    constructor Create; overload;
    constructor Create(fl: string); overload;
    procedure Assign(Source: TBasedSWFObject); override;
    function MinVersion: Byte; override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteTagBody(be: TBitsEngine); override;
    property isAnchor: Boolean read FisAnchor write FisAnchor;
    property Name: string read FName write FName;
  end;

  TSWFProtect = class (TSWFObject)
  private
    FHash: string;
    FPassword: string;
  public
    constructor Create; virtual;
    procedure Assign(Source: TBasedSWFObject); override;
    function MinVersion: Byte; override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteTagBody(be: TBitsEngine); override;
    property Hash: string read FHash write FHash;
    property Password: string read FPassword write FPassword;
  end;
  
  TSWFEnd = class (TSWFObject)
  public
    constructor Create;
  end;
  
  TSWFExportAssets = class (TSWFObject)
  private
    FAssets: TStringList;
    function GetCharacterId(name: string): Integer;
    procedure SetCharacterId(name: string; Value: Integer);
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Assign(Source: TBasedSWFObject); override;
    function MinVersion: Byte; override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure SetAsset(Name: string; CharacterId: word);
    procedure WriteTagBody(be: TBitsEngine); override;
    property Assets: TStringList read FAssets;
    property CharacterId[name: string]: Integer read GetCharacterId write SetCharacterId;
  end;

  TSWFImportAssets = class (TSWFExportAssets)
  private
    FURL: string;
  public
    constructor Create; override;
    procedure Assign(Source: TBasedSWFObject); override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteTagBody(be: TBitsEngine); override;
    property URL: string read FURL write FURL;
  end;

  TSWFImportAssets2 = class(TSWFImportAssets)
  public
    constructor Create; override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteTagBody(be: TBitsEngine); override;
  end;

  TSWFEnableDebugger = class (TSWFProtect)
  public
    constructor Create; override;
    function MinVersion: Byte; override;
  end;
  
  TSWFEnableDebugger2 = class (TSWFProtect)
  public
    constructor Create; override;
    function MinVersion: Byte; override;
  end;
  
  TSWFScriptLimits = class (TSWFObject)
  private
    FMaxRecursionDepth: Word;
    FScriptTimeoutSeconds: Word;
  public
    constructor Create;
    procedure Assign(Source: TBasedSWFObject); override;
    function MinVersion: Byte; override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteTagBody(be: TBitsEngine); override;
    property MaxRecursionDepth: Word read FMaxRecursionDepth write FMaxRecursionDepth;
    property ScriptTimeoutSeconds: Word read FScriptTimeoutSeconds write FScriptTimeoutSeconds;
  end;
  
  TSWFSetTabIndex = class (TSWFObject)
  private
    FDepth: Word;
    FTabIndex: Word;
  public
    constructor Create;
    procedure Assign(Source: TBasedSWFObject); override;
    function MinVersion: Byte; override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteTagBody(be: TBitsEngine); override;
    property Depth: Word read FDepth write FDepth;
    property TabIndex: Word read FTabIndex write FTabIndex;
  end;

 TSWFSymbolClass = class (TSWFExportAssets)
 public
    constructor Create; override;
    function MinVersion: Byte; override;
 end;

 TSWFFileAttributes = class (TSWFObject)
 private
    FHasMetadata: boolean;
    FUseNetwork: boolean;
    FActionScript3: boolean;
 public
    constructor Create;
    procedure Assign(Source: TBasedSWFObject); override;
    function MinVersion: Byte; override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteTagBody(be: TBitsEngine); override;
    property ActionScript3: boolean read FActionScript3 write FActionScript3;
    property HasMetadata: boolean read FHasMetadata write FHasMetadata;
    property UseNetwork: boolean read FUseNetwork write FUseNetwork;
  end;

 TSWFMetadata = class (TSWFObject)
 private
    FMetadata: AnsiString;
 public
    constructor Create;
    procedure Assign(Source: TBasedSWFObject); override;
    function MinVersion: Byte; override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteTagBody(be: TBitsEngine); override;
    property Metadata: AnsiString read FMetadata write FMetadata;
 end;

 TSWFProductInfo = class (TSWFObject)
 private
    FMajorBuild: longword;
    FMinorBuild: longword;
    FCompilationDate: TDateTime;
    FEdition: longint;
    FMinorVersion: byte;
    FMajorVersion: byte;
    FProductId: longint;
 public
    constructor Create;
    procedure Assign(Source: TBasedSWFObject); override;
    function MinVersion: Byte; override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteTagBody(be: TBitsEngine); override;
    property MajorBuild: longword read FMajorBuild write FMajorBuild;
    property MinorBuild: longword read FMinorBuild write FMinorBuild;

    property CompilationDate: TDateTime read FCompilationDate write FCompilationDate;
    property Edition: longint read FEdition write FEdition;
    property MajorVersion: byte read FMajorVersion write FMajorVersion;
    property MinorVersion: byte read FMinorVersion write FMinorVersion;
    property ProductId: longint read FProductId write FProductId;
 end;

 TSWFDefineScalingGrid = class (TSWFObject)
  private
    FCharacterId: word;
    FSplitter: TSWFRect;
 public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TBasedSWFObject); override;
    function MinVersion: Byte; override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteTagBody(be: TBitsEngine); override;
    property CharacterId: word read FCharacterId write FCharacterId;
    property Splitter: TSWFRect read FSplitter;
 end;
// ===========================================================
//                          Actions
// ===========================================================

// ------------ SWF 3 -----------
  TSWFAction = class (TObject)
  private
    FActionCode: Byte;
    FBodySize: Word;
  public
    procedure Assign(Source: TSWFAction); virtual;
    function GetFullSize: Word;
    function MinVersion: Byte; virtual;
    procedure ReadFromStream(be: TBitsEngine); virtual;
    procedure WriteActionBody(be: TBitsEngine); virtual;
    procedure WriteToStream(be: TBitsEngine); virtual;
    property ActionCode: Byte read FActionCode write FActionCode;
    property BodySize: Word read FBodySize write FBodySize;
  end;

TSWFActionRecord = TSWFAction;

  TSWFActionGotoFrame = class (TSWFAction)
  private
    FFrame: Word;
  public
    constructor Create;
    procedure Assign(Source: TSWFAction); override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteActionBody(be: TBitsEngine); override;
    property Frame: Word read FFrame write FFrame;
  end;

  TSWFActionGetUrl = class (TSWFAction)
  private
    FTarget: string;
    FURL: AnsiString;
  public
    constructor Create;
    procedure Assign(Source: TSWFAction); override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteActionBody(be: TBitsEngine); override;
    property Target: string read FTarget write FTarget;
    property URL: AnsiString read FURL write FURL;
  end;
  
  TSWFActionNextFrame = class (TSWFAction)
  public
    constructor Create;
  end;

  TSWFActionPreviousFrame = class (TSWFAction)
  public
    constructor Create;
  end;
  
  TSWFActionPlay = class (TSWFAction)
  public
    constructor Create;
  end;

  TSWFActionStop = class (TSWFAction)
  public
    constructor Create;
  end;
  
  TSWFActionToggleQuality = class (TSWFAction)
  public
    constructor Create;
  end;
  
  TSWFActionStopSounds = class (TSWFAction)
  public
    constructor Create;
  end;
  
  TSWFActionWaitForFrame = class (TSWFAction)
  private
    FFrame: Word;
    FSkipCount: Byte;
  public
    constructor Create;
    procedure Assign(Source: TSWFAction); override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteActionBody(be: TBitsEngine); override;
    property Frame: Word read FFrame write FFrame;
    property SkipCount: Byte read FSkipCount write FSkipCount;
  end;

  TSWFActionSetTarget = class (TSWFAction)
  private
    FTargetName: string;
  public
    constructor Create;
    procedure Assign(Source: TSWFAction); override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteActionBody(be: TBitsEngine); override;
    property TargetName: string read FTargetName write FTargetName;
  end;
  
  TSWFActionGoToLabel = class (TSWFAction)
  private
    FFrameLabel: string;
  public
    constructor Create;
    procedure Assign(Source: TSWFAction); override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteActionBody(be: TBitsEngine); override;
    property FrameLabel: string read FFrameLabel write FFrameLabel;
  end;
  
// ------------ SWF 4 -----------

  TSWFAction4 = class (TSWFAction)
  public
    function MinVersion: Byte; override;
  end;

  TSWFOffsetMarker = class (TSWFAction)
  private
    FisUsing: Boolean;
    FJumpToBack: Boolean;
    FManualSet: Boolean;
    FMarkerName: string;
    FRootStreamPosition: LongInt;
    FSizeOffset: Byte;
    FStartPosition: LongInt;
  public
    constructor Create;
    procedure Assign(Source: TSWFAction); override;
    procedure WriteActionBody(be: TBitsEngine); override;
    procedure WriteOffset(be: TBitsEngine);
    property isUsing: Boolean read FisUsing write FisUsing;
    property JumpToBack: Boolean read FJumpToBack write FJumpToBack;
    property ManualSet: Boolean read FManualSet write FManualSet;
    property MarkerName: string read FMarkerName write FMarkerName;
    property RootStreamPosition: LongInt read FRootStreamPosition write FRootStreamPosition;
    property SizeOffset: Byte read FSizeOffset write FSizeOffset;
    property StartPosition: LongInt read FStartPosition write FStartPosition;
  end;


  TSWFTryOffsetMarker = class (TSWFOffsetMarker)
  private
 {   FTryAction: TSWFAction;}
    FPrvieusMarker: TSWFTryOffsetMarker;
  end;

//  -- Stack Operations --
  TPushValueInfo = class (TObject)
  private
    FValue: Variant;
    FValueType: TSWFValueType;
    procedure SetValue(v: Variant);
    procedure SetValueType(v: TSWFValueType);
  public
    isValueInit: Boolean;
    property Value: Variant read FValue write SetValue;
    property ValueType: TSWFValueType read FValueType write SetValueType;
  end;
  
  TSWFActionPush = class (TSWFAction4)
  private
    FValues: TObjectList;
    function GetValue(index: integer): Variant;
    function GetValueInfo(index: integer): TPushValueInfo;
    procedure SetValue(index: integer; v: Variant);
  public
    constructor Create;
    destructor Destroy; override;
    function AddValue(V: Variant): Integer;
    procedure Assign(Source: TSWFAction); override;
    function MinVersion: Byte; override;
    procedure ReadFromStream(be: TBitsEngine); override;
    function ValueCount: Word;
    procedure WriteActionBody(be: TBitsEngine); override;
    property Value[index: integer]: Variant read GetValue write SetValue;
    property ValueInfo[index: integer]: TPushValueInfo read GetValueInfo;
  end;

  TSWFActionPop = class (TSWFAction4)
  public
    constructor Create;
  end;
  
// -- Arithmetic Operators --

  TSWFActionAdd = class (TSWFAction4)
  public
    constructor Create;
  end;

  TSWFActionSubtract = class (TSWFAction4)
  public
    constructor Create;
  end;
  
  TSWFActionMultiply = class (TSWFAction4)
  public
    constructor Create;
  end;
  
  TSWFActionDivide = class (TSWFAction4)
  public
    constructor Create;
  end;
  
// --  Numerical Comparison --

  TSWFActionEquals = class (TSWFAction4)
  public
    constructor Create;
  end;
  
  TSWFActionLess = class (TSWFAction4)
  public
    constructor Create;
  end;

// -- Logical Operators --

  TSWFActionAnd = class (TSWFAction4)
  public
    constructor Create;
  end;
  
  TSWFActionOr = class (TSWFAction4)
  public
    constructor Create;
  end;
  
  TSWFActionNot = class (TSWFAction4)
  public
    constructor Create;
  end;
  
// -- String Manipulation --

  TSWFActionStringEquals = class (TSWFAction4)
  public
    constructor Create;
  end;
  
  TSWFActionStringLength = class (TSWFAction4)
  public
    constructor Create;
  end;

  TSWFActionStringAdd = class (TSWFAction4)
  public
    constructor Create;
  end;
  
  TSWFActionStringExtract = class (TSWFAction4)
  public
    constructor Create;
  end;

  TSWFActionStringLess = class (TSWFAction4)
  public
    constructor Create;
  end;
  
  TSWFActionMBStringLength = class (TSWFAction4)
  public
    constructor Create;
  end;

  TSWFActionMBStringExtract = class (TSWFAction4)
  public
    constructor Create;
  end;

// -- Type Conversion --

  TSWFActionToInteger = class (TSWFAction4)
  public
    constructor Create;
  end;
  
  TSWFActionCharToAscii = class (TSWFAction4)
  public
    constructor Create;
  end;
  
  TSWFActionAsciiToChar = class (TSWFAction4)
  public
    constructor Create;
  end;
  
  TSWFActionMBCharToAscii = class (TSWFAction4)
  public
    constructor Create;
  end;
  
  TSWFActionMBAsciiToChar = class (TSWFAction4)
  public
    constructor Create;
  end;
  
// -- Control Flow --

  TSWFActionJump = class (TSWFAction4)
  private
    FBranchOffset: SmallInt;
    FBranchOffsetMarker: TSWFOffsetMarker;
    FStaticOffset: Boolean;
    StartPosition: Integer;
    function GetBranchOffsetMarker: TSWFOffsetMarker;
    procedure SetBranchOffset(v: SmallInt);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TSWFAction); override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteActionBody(be: TBitsEngine); override;
    procedure WriteToStream(be: TBitsEngine); override;
    property BranchOffset: SmallInt read FBranchOffset write SetBranchOffset;
    property BranchOffsetMarker: TSWFOffsetMarker read GetBranchOffsetMarker write FBranchOffsetMarker;
    property StaticOffset: Boolean read FStaticOffset write FStaticOffset;
  end;
  
  TSWFActionIf = class (TSWFActionJump)
  public
    constructor Create;
  end;
  
  TSWFActionCall = class (TSWFAction4)
  public
    constructor Create;
  end;
  
// -- Variables --

  TSWFActionGetVariable = class (TSWFAction4)
  public
    constructor Create;
  end;
  
  TSWFActionSetVariable = class (TSWFAction4)
  public
    constructor Create;
  end;

// -- Movie Control --

  TSWFActionGetURL2 = class (TSWFAction4)
  private
    FLoadTargetFlag: Boolean;
    FLoadVariablesFlag: Boolean;
    FSendVarsMethod: Byte;
  public
    constructor Create;
    procedure Assign(Source: TSWFAction); override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteActionBody(be: TBitsEngine); override;
    property LoadTargetFlag: Boolean read FLoadTargetFlag write FLoadTargetFlag;
    property LoadVariablesFlag: Boolean read FLoadVariablesFlag write FLoadVariablesFlag;
    property SendVarsMethod: Byte read FSendVarsMethod write FSendVarsMethod;
  end;

  TSWFActionGotoFrame2 = class (TSWFAction4)
  private
    FPlayFlag: Boolean;
    FSceneBias: Word;
    FSceneBiasFlag: Boolean;
  public
    constructor Create;
    procedure Assign(Source: TSWFAction); override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteActionBody(be: TBitsEngine); override;
    property PlayFlag: Boolean read FPlayFlag write FPlayFlag;
    property SceneBias: Word read FSceneBias write FSceneBias;
    property SceneBiasFlag: Boolean read FSceneBiasFlag write FSceneBiasFlag;
  end;

  TSWFActionSetTarget2 = class (TSWFAction4)
  public
    constructor Create;
  end;
  
  TSWFActionGetProperty = class (TSWFAction4)
  public
    constructor Create;
  end;

  TSWFActionSetProperty = class (TSWFAction4)
  public
    constructor Create;
  end;
  
  TSWFActionCloneSprite = class (TSWFAction4)
  public
    constructor Create;
  end;

  TSWFActionRemoveSprite = class (TSWFAction4)
  public
    constructor Create;
  end;
  
  TSWFActionStartDrag = class (TSWFAction4)
  public
    constructor Create;
  end;
  
  TSWFActionEndDrag = class (TSWFAction4)
  public
    constructor Create;
  end;

  TSWFActionWaitForFrame2 = class (TSWFAction4)
  public
    constructor Create;
  end;
  
// -- Utilities --

  TSWFActionTrace = class (TSWFAction4)
  public
    constructor Create;
  end;
  
  TSWFActionGetTime = class (TSWFAction4)
  public
    constructor Create;
  end;
  
  TSWFActionRandomNumber = class (TSWFAction4)
  public
    constructor Create;
  end;

  TSWFActionFSCommand2 = class (TSWFAction4)
  public
    constructor Create;
  end;

// ------------ SWF 5 -----------
// -- ScriptObject Actions --
  TSWFActionByteCode = class (TSWFAction4)
  private
    FData: Pointer;
    FDataSize: LongInt;
    FSelfDestroy: Boolean;
    function GetByteCode(Index: word): Byte;
    function GetStrByteCode: AnsiString;
    procedure SetByteCode(Index: word; Value: Byte);
    procedure SetStrByteCode(Value: AnsiString);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TSWFAction); override;
    procedure SetSize(newsize: word);
    procedure WriteActionBody(be: TBitsEngine); override;
    property ByteCode[Index: word]: Byte read GetByteCode write SetByteCode;
    property Data: Pointer read FData write FData;
    property DataSize: LongInt read FDataSize write FDataSize;
    property SelfDestroy: Boolean read FSelfDestroy write FSelfDestroy;
    property StrByteCode: AnsiString read GetStrByteCode write SetStrByteCode;
  end;
  
  TSWFAction5 = class (TSWFAction)
  public
    function MinVersion: Byte; override;
  end;
  
  TSWFActionCallFunction = class (TSWFAction5)
  public
    constructor Create;
  end;

  TSWFActionCallMethod = class (TSWFAction5)
  public
    constructor Create;
  end;
  
  TSWFActionConstantPool = class (TSWFAction5)
  private
    FConstantPool: TStringList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TSWFAction); override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteActionBody(be: TBitsEngine); override;
    property ConstantPool: TStringList read FConstantPool;
  end;

  TSWFActionDefineFunction = class (TSWFAction5)
  private
    FCodeSize: Word;
    FCodeSizeMarker: TSWFOffsetMarker;
    FFunctionName: string;
    FParams: TStringList;
    FStaticOffset: Boolean;
    StartPosition: Integer;
    function GetCodeSizeMarker: TSWFOffsetMarker;
    procedure SetCodeSize(v: Word);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TSWFAction); override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteActionBody(be: TBitsEngine); override;
    procedure WriteToStream(be: TBitsEngine); override;
    property CodeSize: Word read FCodeSize write SetCodeSize;
    property CodeSizeMarker: TSWFOffsetMarker read GetCodeSizeMarker write FCodeSizeMarker;
    property FunctionName: string read FFunctionName write FFunctionName;
    property Params: TStringList read FParams;
    property StaticOffset: Boolean read FStaticOffset write FStaticOffset;
  end;
  
  TSWFActionDefineLocal = class (TSWFAction5)
  public
    constructor Create;
  end;
  
  TSWFActionDefineLocal2 = class (TSWFAction5)
  public
    constructor Create;
  end;
  
  TSWFActionDelete = class (TSWFAction5)
  public
    constructor Create;
  end;

  TSWFActionDelete2 = class (TSWFAction5)
  public
    constructor Create;
  end;

  TSWFActionEnumerate = class (TSWFAction5)
  public
    constructor Create;
  end;
  
  TSWFActionEquals2 = class (TSWFAction5)
  public
    constructor Create;
  end;
  
  TSWFActionGetMember = class (TSWFAction5)
  public
    constructor Create;
  end;
  
  TSWFActionInitArray = class (TSWFAction5)
  public
    constructor Create;
  end;
  
  TSWFActionInitObject = class (TSWFAction5)
  public
    constructor Create;
  end;
  
  TSWFActionNewMethod = class (TSWFAction5)
  public
    constructor Create;
  end;
  
  TSWFActionNewObject = class (TSWFAction5)
  public
    constructor Create;
  end;
  
  TSWFActionSetMember = class (TSWFAction5)
  public
    constructor Create;
  end;

  TSWFActionTargetPath = class (TSWFAction5)
  public
    constructor Create;
  end;
  
  TSWFActionWith = class (TSWFAction5)
  private
    FSize: Word;
    FSizeMarker: TSWFOffsetMarker;
    FStaticOffset: Boolean;
    StartPosition: Integer;
    function GetSizeMarker: TSWFOffsetMarker;
    procedure SetSize(w: Word);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TSWFAction); override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteActionBody(be: TBitsEngine); override;
    procedure WriteToStream(be: TBitsEngine); override;
    property Size: Word read FSize write SetSize;
    property SizeMarker: TSWFOffsetMarker read GetSizeMarker write FSizeMarker;
    property StaticOffset: Boolean read FStaticOffset write FStaticOffset;
  end;
  
// -- Type Actions --
  TSWFActionToNumber = class (TSWFAction5)
  public
    constructor Create;
  end;

  TSWFActionToString = class (TSWFAction5)
  public
    constructor Create;
  end;
  
  TSWFActionTypeOf = class (TSWFAction5)
  public
    constructor Create;
  end;
  
// -- Math Actions --
  TSWFActionAdd2 = class (TSWFAction5)
  public
    constructor Create;
  end;
  
  TSWFActionLess2 = class (TSWFAction5)
  public
    constructor Create;
  end;
  
  TSWFActionModulo = class (TSWFAction5)
  public
    constructor Create;
  end;
  
// -- Stack Operator Actions --
  TSWFActionBitAnd = class (TSWFAction5)
  public
    constructor Create;
  end;

  TSWFActionBitLShift = class (TSWFAction5)
  public
    constructor Create;
  end;
  
  TSWFActionBitOr = class (TSWFAction5)
  public
    constructor Create;
  end;

  TSWFActionBitRShift = class (TSWFAction5)
  public
    constructor Create;
  end;
  
  TSWFActionBitURShift = class (TSWFAction5)
  public
    constructor Create;
  end;

  TSWFActionBitXor = class (TSWFAction5)
  public
    constructor Create;
  end;
  
  TSWFActionDecrement = class (TSWFAction5)
  public
    constructor Create;
  end;
  
  TSWFActionIncrement = class (TSWFAction5)
  public
    constructor Create;
  end;

  TSWFActionPushDuplicate = class (TSWFAction5)
  public
    constructor Create;
  end;

  TSWFActionReturn = class (TSWFAction5)
  public
    constructor Create;
  end;

  TSWFActionStackSwap = class (TSWFAction5)
  public
    constructor Create;
  end;
  
  TSWFActionStoreRegister = class (TSWFAction5)
  private
    FRegisterNumber: Byte;
  public
    constructor Create;
    procedure Assign(Source: TSWFAction); override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteActionBody(be: TBitsEngine); override;
    property RegisterNumber: Byte read FRegisterNumber write FRegisterNumber;
  end;
  

// ------------ SWF 6 -----------

  TSWFAction6 = class (TSWFAction)
  public
    function MinVersion: Byte; override;
  end;
  
  TSWFActionInstanceOf = class (TSWFAction6)
  public
    constructor Create;
  end;
  
  TSWFActionEnumerate2 = class (TSWFAction6)
  public
    constructor Create;
  end;

  TSWFActionStrictEquals = class (TSWFAction6)
  public
    constructor Create;
  end;

  TSWFActionGreater = class (TSWFAction6)
  public
    constructor Create;
  end;
  
  TSWFActionStringGreater = class (TSWFAction6)
  public
    constructor Create;
  end;
  

// ------------ SWF 7 -----------

  TSWFAction7 = class (TSWFAction)
  public
    function MinVersion: Byte; override;
  end;
  
  TSWFActionDefineFunction2 = class (TSWFAction7)
  private
    FCodeSize: Word;
    FCodeSizeMarker: TSWFOffsetMarker;
    FFunctionName: string;
    FParameters: TStringList;
    FPreloadArgumentsFlag: Boolean;
    FPreloadGlobalFlag: Boolean;
    FPreloadParentFlag: Boolean;
    FPreloadRootFlag: Boolean;
    FPreloadSuperFlag: Boolean;
    FPreloadThisFlag: Boolean;
    FRegisterCount: Byte;
    FStaticOffset: Boolean;
    FSuppressArgumentsFlag: Boolean;
    FSuppressSuperFlag: Boolean;
    FSuppressThisFlag: Boolean;
    StartPosition: Integer;
    function GetCodeSizeMarker: TSWFOffsetMarker;
    function GetParamRegister(Index: byte): byte;
    procedure SetCodeSize(v: Word);
    procedure SetParamRegister(index, value: byte);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TSWFAction); override;
    procedure AddParam(const param: string; reg: byte);
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteActionBody(be: TBitsEngine); override;
    procedure WriteToStream(be: TBitsEngine); override;
    property CodeSize: Word read FCodeSize write SetCodeSize;
    property CodeSizeMarker: TSWFOffsetMarker read GetCodeSizeMarker write FCodeSizeMarker;
    property FunctionName: string read FFunctionName write FFunctionName;
    property Parameters: TStringList read FParameters write FParameters;
    property ParamRegister[Index: byte]: byte read GetParamRegister write SetParamRegister;
    property PreloadArgumentsFlag: Boolean read FPreloadArgumentsFlag write FPreloadArgumentsFlag;
    property PreloadGlobalFlag: Boolean read FPreloadGlobalFlag write FPreloadGlobalFlag;
    property PreloadParentFlag: Boolean read FPreloadParentFlag write FPreloadParentFlag;
    property PreloadRootFlag: Boolean read FPreloadRootFlag write FPreloadRootFlag;
    property PreloadSuperFlag: Boolean read FPreloadSuperFlag write FPreloadSuperFlag;
    property PreloadThisFlag: Boolean read FPreloadThisFlag write FPreloadThisFlag;
    property RegisterCount: Byte read FRegisterCount write FRegisterCount;
    property StaticOffset: Boolean read FStaticOffset write FStaticOffset;
    property SuppressArgumentsFlag: Boolean read FSuppressArgumentsFlag write FSuppressArgumentsFlag;
    property SuppressSuperFlag: Boolean read FSuppressSuperFlag write FSuppressSuperFlag;
    property SuppressThisFlag: Boolean read FSuppressThisFlag write FSuppressThisFlag;
  end;

  TSWFActionExtends = class (TSWFAction7)
  public
    constructor Create;
  end;
  
  TSWFActionCastOp = class (TSWFAction7)
  public
    constructor Create;
  end;

  TSWFActionImplementsOp = class (TSWFAction7)
  public
    constructor Create;
  end;
  
  TSWFActionTry = class (TSWFAction7)
  private
    FCatchBlockFlag: Boolean;
    FCatchInRegisterFlag: Boolean;
    FCatchName: string;
    FCatchRegister: Byte;
    FCatchSize: Word;
    FCatchSizeMarker: TSWFTryOffsetMarker;
    FFinallyBlockFlag: Boolean;
    FFinallySize: Word;
    FFinallySizeMarker: TSWFTryOffsetMarker;
    FStaticOffset: Boolean;
    FTrySize: Word;
    FTrySizeMarker: TSWFTryOffsetMarker;
    StartPosition: Integer;
    function GetCatchSizeMarker: TSWFTryOffsetMarker;
    function GetFinallySizeMarker: TSWFTryOffsetMarker;
    function GetTrySizeMarker: TSWFTryOffsetMarker;
    procedure SetCatchSize(w: Word);
    procedure SetFinallySize(w: Word);
    procedure SetTrySize(w: Word);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TSWFAction); override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteActionBody(be: TBitsEngine); override;
    procedure WriteToStream(be: TBitsEngine); override;
    property CatchBlockFlag: Boolean read FCatchBlockFlag write FCatchBlockFlag;
    property CatchInRegisterFlag: Boolean read FCatchInRegisterFlag write FCatchInRegisterFlag;
    property CatchName: string read FCatchName write FCatchName;
    property CatchRegister: Byte read FCatchRegister write FCatchRegister;
    property CatchSize: Word read FCatchSize write SetCatchSize;
    property CatchSizeMarker: TSWFTryOffsetMarker read GetCatchSizeMarker write FCatchSizeMarker;
    property FinallyBlockFlag: Boolean read FFinallyBlockFlag write FFinallyBlockFlag;
    property FinallySize: Word read FFinallySize write SetFinallySize;
    property FinallySizeMarker: TSWFTryOffsetMarker read GetFinallySizeMarker write FFinallySizeMarker;
    property StaticOffset: Boolean read FStaticOffset write FStaticOffset;
    property TrySize: Word read FTrySize write SetTrySize;
    property TrySizeMarker: TSWFTryOffsetMarker read GetTrySizeMarker write FTrySizeMarker;
  end;

  TSWFActionThrow = class (TSWFAction7)
  public
    constructor Create;
  end;

  TSWFActionList = class (TObjectList)
  private
    function GetAction(Index: word): TSWFAction;
    procedure SetAction(Index: word; Value: TSWFAction);
  public
    property Action[Index: word]: TSWFAction read GetAction write SetAction; default;
  end;

  TSWFDoAction = class (TSWFObject)
  private
    FActions: TSWFActionList;
    FParseActions: Boolean;
    SelfDestroy: Boolean;
  public
    constructor Create; overload; virtual;
    constructor Create(A: TSWFActionList); overload; virtual;
    destructor Destroy; override;
    procedure Assign(Source: TBasedSWFObject); override;
    function MinVersion: Byte; override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteTagBody(be: TBitsEngine); override;
    property Actions: TSWFActionList read FActions;
    property ParseActions: Boolean read FParseActions write FParseActions;
  end;

  TSWFDoInitAction = class (TSWFDoAction)
  private
    FSpriteID: Word;
  public
    constructor Create; override;
    constructor Create(A: TSWFActionList); override;
    procedure Assign(Source: TBasedSWFObject); override;
    function MinVersion: Byte; override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteTagBody(be: TBitsEngine); override;
    property SpriteID: Word read FSpriteID write FSpriteID;
  end;

// ===========================================================
//                           AS3
// ===========================================================
  TSWFDoubleObject = class (TObject)
    Value: Double;
    constructor Create(init: double);
  end;

  TSWFNameSpaceObject = class (TObject)
    Kind: byte;
    Name: Longint;
    constructor Create(kind: byte; name: Longint);
  end;

  TSWFIntegerList = class (TList)
  private
    function GetInt(index: Integer): longint;
    procedure SetInt(index: Integer; const Value: longint);
  public
    procedure WriteToStream(be: TBitsEngine);
    procedure AddInt(value: longint);
    property Int[index: longint]: longint read GetInt write SetInt;
  end;

  TSWFBasedMultiNameObject = class (TObject)
  private
    FMultinameKind: byte;
  public
    procedure ReadFromStream(be: TBitsEngine); virtual;
    procedure WriteToStream(be: TBitsEngine); virtual;
    property MultinameKind: byte read FMultinameKind  write FMultinameKind;
  end;

  TSWFmnQName = class (TSWFBasedMultiNameObject)
  private
    FNS: Longint;
    FName: Longint;
  public
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteToStream(be: TBitsEngine); override;
    property NS: Longint read FNS write FNS;
    property Name: Longint read FName write FName;
  end;

  TSWFmnRTQName = class (TSWFBasedMultiNameObject)
  private
    FName: Longint;
  public
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteToStream(be: TBitsEngine); override;
    property Name: Longint read FName write FName;
  end;

  TSWFmnRTQNameL = TSWFBasedMultiNameObject;

  TSWFmnMultiname = class (TSWFBasedMultiNameObject)
  private
    FNSSet: Longint;
    FName: Longint;
  public
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteToStream(be: TBitsEngine); override;
    property NSSet: Longint read FNSSet write FNSSet;
    property Name: Longint read FName write FName;
  end;

  TSWFmnMultinameL = class (TSWFBasedMultiNameObject)
  private
    FNSSet: Longint;
  public
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteToStream(be: TBitsEngine); override;
    property NSSet: Longint read FNSSet write FNSSet;
  end;

  TSWFAS3ConstantPool = class (TObject)
  private
    IntegerList: TSWFIntegerList;
    UIntegerList: TList;
    DoubleList: TObjectList;
    StringList: TStringList;
    NameSpaceList: TObjectList;
    NameSpaceSETList: TObjectList;
    MultinameList: TObjectList;
    function GetMultiname(index: Integer): TSWFBasedMultiNameObject;
    function GetMultinameCount: longint;
    procedure SetMultiname(index: Integer; const Value: TSWFBasedMultiNameObject);

    function GetNameSpaceSET(index: Integer): TSWFIntegerList;
    function GetNameSpaceSETCount: longint;
    procedure SetNameSpaceSET(index: Integer; const Value: TSWFIntegerList);
    function GetNameSpace(index: Integer): TSWFNameSpaceObject;
    function GetNameSpaceCount: longint;
    procedure SetNameSpace(index: Integer; const Value: TSWFNameSpaceObject);
    function GetStrings(index: Integer): string;
    function GetStringsCount: longint;
    procedure SetStrings(index: longint; const Value: string);
    function GetDouble(index: Integer): Double;
    function GetDoubleCount: longint;
    procedure SetDouble(index: Integer; const Value: Double);
    function GetUInt(index: Integer): longword;
    function GetUIntCount: longword;
    procedure SetUInt(index: Integer; const Value: longword);
    function GetIntCount: longint;
    function GetInt(index: longint): longint;
    procedure SetInt(index: longint; const Value: longint);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ReadFromStream(be: TBitsEngine);
    procedure WriteToStream(be: TBitsEngine);

    property Double[index: longint]: Double read GetDouble write SetDouble;
    property DoubleCount: longint read GetDoubleCount;
    property Int[index: longint]: longint read GetInt write SetInt;
    property IntCount: longint read GetIntCount;
    property Multiname[index: longint]: TSWFBasedMultiNameObject read GetMultiname write SetMultiname;
    property MultinameCount: longint read GetMultinameCount;

    property NameSpace[index: longint]: TSWFNameSpaceObject read GetNameSpace write SetNameSpace;
    property NameSpaceCount: longint read GetNameSpaceCount;

    property NameSpaceSET[index: longint]: TSWFIntegerList read GetNameSpaceSET write SetNameSpaceSET;
    property NameSpaceSETCount: longint read GetNameSpaceSETCount;
    property Strings[index: longint]: string read GetStrings write SetStrings;
    property StringsCount: longint read GetStringsCount;

    property UInt[index: longint]: longword read GetUInt write SetUInt;
    property UIntCount: longword read GetUIntCount;

  end;


  TSWFAS3MethodOptions = class (TObject)
    val: longint;
    kind: byte;
  end;

  TSWFAS3Method = class (TObject)
  private
    FHasOptional: boolean;
    FHasParamNames: boolean;
    FName: Longint;
    FNeedActivation: boolean;
    FNeedArguments: boolean;
    FNeedRest: boolean;
    FOptions: TObjectList;
    FParamNames: TSWFIntegerList;
    FParamTypes: TSWFIntegerList;
    FReturnType: Longint;
    FSetDxns: boolean;
    function GetOption(index: integer): TSWFAS3MethodOptions;
  public
    constructor Create;
    destructor Destroy; override;
    function AddOption: TSWFAS3MethodOptions;
    property HasOptional: boolean read FHasOptional write FHasOptional;
    property HasParamNames: boolean read FHasParamNames write FHasParamNames;
    property Name: Longint read FName write FName;
    property NeedActivation: boolean read FNeedActivation write FNeedActivation;
    property NeedArguments: boolean read FNeedArguments write FNeedArguments;
    property NeedRest: boolean read FNeedRest write FNeedRest;
    property Option[index: integer]: TSWFAS3MethodOptions read GetOption;
    property Options: TObjectList read FOptions;
    property ParamNames: TSWFIntegerList read FParamNames;
    property ParamTypes: TSWFIntegerList read FParamTypes;
    property ReturnType: Longint read FReturnType write FReturnType;
    property SetDxns: boolean read FSetDxns write FSetDxns;
  end;

  TSWFAS3Methods = class (TObject)
  private
    MethodsList: TObjectList;
    function GetMethod(index: integer): TSWFAS3Method;
  public
    constructor Create;
    destructor Destroy; override;
    function AddMethod: TSWFAS3Method;
    procedure ReadFromStream(be: TBitsEngine);
    procedure WriteToStream(be: TBitsEngine);
    property Method[index: integer]: TSWFAS3Method read GetMethod;
  end;

  TSWFAS3MetadataItem = class (TObject)
  private
    FKey: LongInt;
    FValue: LongInt;
  public
    property Value: LongInt read FValue write FValue;
    property Key: LongInt read FKey write FKey;
  end;

  TSWFAS3MetadataInfo = class (TObject)
  private
    FInfoList: TObjectList;
    FName: Longint;
    function GetItem(index: integer): TSWFAS3MetadataItem;
  public
    constructor Create;
    destructor Destroy; override;
    function AddMetadataItem: TSWFAS3MetadataItem;
    property InfoList: TObjectList read FInfoList;
    property MetaItem[index: integer]: TSWFAS3MetadataItem read GetItem;
    property Name: Longint read FName write FName;
  end;

  TSWFAS3Metadata = class (TObject)
  private
    FMetadataList: TObjectList;
    function GetMetadata(index: integer): TSWFAS3MetadataInfo;
  public
    constructor Create;
    destructor Destroy; override;
    function AddMetaInfo: TSWFAS3MetadataInfo;
    procedure ReadFromStream(be: TBitsEngine);
    procedure WriteToStream(be: TBitsEngine);
    property MetadataList: TObjectList read FMetadataList;
    property MetadataInfo[index: integer]: TSWFAS3MetadataInfo read GetMetadata;
  end;

  TSWFAS3Trait = class (TObject)
  private
    FID: LongInt;
    FIsFinal: Boolean;
    FIsMetadata: Boolean;
    FIsOverride: Boolean;
    FName: LongInt;
    FTraitType: byte;
    FMetadata: TSWFIntegerList;
    FSpecID: LongInt;
    FVIndex: LongInt;
    FVKind: byte;
    function GetMetadata: TSWFIntegerList;
    procedure SetIsMetadata(const Value: Boolean);
  public
    destructor Destroy; override;
    procedure ReadFromStream(be: TBitsEngine);
    procedure WriteToStream(be: TBitsEngine);
    property ID: LongInt read FID write FID;
    property IsFinal: Boolean read FIsFinal write FIsFinal;
    property IsMetadata: Boolean read FIsMetadata write SetIsMetadata;
    property IsOverride: Boolean read FIsOverride write FIsOverride;
    property Name: LongInt read FName write FName;
    property TraitType: byte read FTraitType write FTraitType;
    property Metadata: TSWFIntegerList read GetMetadata;
    property SpecID: LongInt read FSpecID write FSpecID;
    property VIndex: LongInt read FVIndex write FVIndex;
    property VKind: byte read FVKind write FVKind;
  end;

  TSWFAS3Traits = class (TObject)
    FTraits: TObjectList;
    function GetTrait(Index: Integer): TSWFAS3Trait;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    function AddTrait: TSWFAS3Trait;
    property Trait[Index: longint]: TSWFAS3Trait read GetTrait;
    property Traits: TObjectList read FTraits;
  end;

  TSWFAS3InstanceItem = class (TSWFAS3Traits)
  private
    FClassFinal: Boolean;
    FClassInterface: Boolean;
    FClassProtectedNs: Boolean;
    FClassSealed: Boolean;
    FIinit: LongInt;
    FInterfaces: TSWFIntegerList;
    FName: LongInt;
    FProtectedNs: LongInt;
    FSuperName: LongInt;
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure ReadFromStream(be: TBitsEngine);
    procedure WriteToStream(be: TBitsEngine);
    property ClassFinal: Boolean read FClassFinal write FClassFinal;
    property ClassInterface: Boolean read FClassInterface write FClassInterface;
    property ClassProtectedNs: Boolean read FClassProtectedNs write FClassProtectedNs;
    property ClassSealed: Boolean read FClassSealed write FClassSealed;
    property Iinit: LongInt read FIinit write FIinit;
    property Interfaces: TSWFIntegerList read FInterfaces;
    property Name: LongInt read FName write FName;
    property ProtectedNs: LongInt read FProtectedNs write FProtectedNs;
    property SuperName: LongInt read FSuperName write FSuperName;
  end;

  TSWFAS3Instance = class (TObjectList)
  private
    function GetInstanceItem(Index: longint): TSWFAS3InstanceItem;
  public
    function AddInstanceItem: TSWFAS3InstanceItem;
    procedure ReadFromStream(Count: Longint; be: TBitsEngine);
    procedure WriteToStream(be: TBitsEngine);
    property InstanceItem[Index: longint]: TSWFAS3InstanceItem read GetInstanceItem;
  end;

  TSWFAS3ClassInfo = class (TSWFAS3Traits)
  private
    FCInit: LongInt;
  public
    procedure ReadFromStream(be: TBitsEngine);
    procedure WriteToStream(be: TBitsEngine);
    property CInit: LongInt read FCInit write FCInit;
  end;

  TSWFAS3Classes = class(TObjectList)
  private
    function GetClassInfo(Index: Integer): TSWFAS3ClassInfo;
  public
    procedure ReadFromStream(rcount: longInt; be: TBitsEngine);
    procedure WriteToStream(be: TBitsEngine);
    function AddClassInfo: TSWFAS3ClassInfo;
    property _ClassInfo[Index: Integer]: TSWFAS3ClassInfo read GetClassInfo;
  end;

  TSWFAS3ScriptInfo = TSWFAS3ClassInfo;
  TSWFAS3Scripts = class(TObjectList)
  private
    function GetScriptInfo(Index: Integer): TSWFAS3ScriptInfo;
  public
    procedure ReadFromStream(be: TBitsEngine);
    procedure WriteToStream(be: TBitsEngine);
    function AddScriptInfo: TSWFAS3ScriptInfo;
    property ScriptInfo[Index: Integer]: TSWFAS3ScriptInfo read GetScriptInfo;
  end;

  TSWFAS3Exception = class (TObject)
  private
    FExcType: LongInt;
    FFrom: LongInt;
    FTarget: LongInt;
    FVarName: LongInt;
    F_To: LongInt;
  public
    property ExcType: LongInt read FExcType write FExcType;
    property From: LongInt read FFrom write FFrom;
    property Target: LongInt read FTarget write FTarget;
    property VarName: LongInt read FVarName write FVarName;
    property _To: LongInt read F_To write F_To;
  end;

  TSWFAS3MethodBodyInfo = class (TSWFAS3Traits)
   private
    FCode: TMemoryStream;
    FExceptions: TObjectList;
    FInitScopeDepth: LongInt;
    FLocalCount: LongInt;
    FMaxScopeDepth: LongInt;
    FMaxStack: LongInt;
    FMethod: LongInt;
    function GetException(Index: Integer): TSWFAS3Exception;
    function GetCodeItem(Index: Integer): byte;
    procedure SetCodeItem(Index: Integer; const Value: byte);
    procedure SetStrByteCode(Value: AnsiString);
    function GetStrByteCode: AnsiString;
   public
    constructor Create; override;
    destructor Destroy; override;
    procedure ReadFromStream(be: TBitsEngine);
    procedure WriteToStream(be: TBitsEngine);
    function AddException: TSWFAS3Exception;
    property Code: TMemoryStream read FCode;
    property StrCode: AnsiString read GetStrByteCode write SetStrByteCode;
    property CodeItem[Index: Integer]: byte read GetCodeItem write SetCodeItem;
    property Exception[Index: Integer]: TSWFAS3Exception read GetException;
    property Exceptions: TObjectList read FExceptions;
    property InitScopeDepth: LongInt read FInitScopeDepth write FInitScopeDepth;
    property LocalCount: LongInt read FLocalCount write FLocalCount;
    property MaxScopeDepth: LongInt read FMaxScopeDepth write FMaxScopeDepth;
    property MaxStack: LongInt read FMaxStack write FMaxStack;
    property Method: LongInt read FMethod write FMethod;
  end;

  TSWFAS3MethodBodies = class(TObjectList)
  private
    function GetClassInfo(Index: Integer): TSWFAS3MethodBodyInfo;
  public
    procedure ReadFromStream(be: TBitsEngine);
    procedure WriteToStream(be: TBitsEngine);
    function AddMethodBodyInfo: TSWFAS3MethodBodyInfo;
    property MethodBodyInfo[Index: Integer]: TSWFAS3MethodBodyInfo read GetClassInfo;
  end;

  TSWFDoABC = class (TSWFObject)
  private
    FData: Pointer;
    FDataSize: LongInt;
    FSelfDestroy: Boolean;
    FClasses: TSWFAS3Classes;
    FDoAbcLazyInitializeFlag: boolean;
    FMinorVersion: Word;
    FMajorVersion: Word;
    FConstantPool: TSWFAS3ConstantPool;
    FInstance: TSWFAS3Instance;
    FMethods: TSWFAS3Methods;
    FMethodBodies: TSWFAS3MethodBodies;
    FMetadata: TSWFAS3Metadata;
    FScripts: TSWFAS3Scripts;
    FActionName: string;
    FParseActions: Boolean;
    function GetClasses: TSWFAS3Classes;
    function GetInstance: TSWFAS3Instance;
    function GetMetadata: TSWFAS3Metadata;
    function GetMethods: TSWFAS3Methods;
    function GetScripts: TSWFAS3Scripts;
    function GetStrVersion: string;
    function GetMethodBodies: TSWFAS3MethodBodies;
    procedure SetStrVersion(ver: string);
  public
    constructor Create;
    destructor Destroy; override;
    function MinVersion: Byte; override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteTagBody(be: TBitsEngine); override;
    property ActionName: string read FActionName write FActionName;
    property Classes: TSWFAS3Classes read GetClasses;
    property ConstantPool: TSWFAS3ConstantPool read FConstantPool;
    property Data: Pointer read FData write FData;
    property DataSize: LongInt read FDataSize write FDataSize;
    property DoAbcLazyInitializeFlag: boolean read FDoAbcLazyInitializeFlag write FDoAbcLazyInitializeFlag;
    property Instance: TSWFAS3Instance read GetInstance;
    property MajorVersion: Word read FMajorVersion write FMajorVersion;
    property Metadata: TSWFAS3Metadata read GetMetadata;
    property MethodBodies: TSWFAS3MethodBodies read GetMethodBodies;
    property Methods: TSWFAS3Methods read GetMethods;
    property MinorVersion: Word read FMinorVersion write FMinorVersion;
    property ParseActions: Boolean read FParseActions write FParseActions;
    property Scripts: TSWFAS3Scripts read GetScripts;
    property SelfDestroy: Boolean read FSelfDestroy write FSelfDestroy;
    property StrVersion: string read GetStrVersion write SetStrVersion;
  end;

// ===========================================================
//                       Display List
// ===========================================================
  TSWFBasedPlaceObject = class (TSWFObject)
  private
    FCharacterId: Word;
    FDepth: Word;
    procedure SetCharacterId(ID: Word); virtual;
  public
    procedure Assign(Source: TBasedSWFObject); override;
    property CharacterId: Word read FCharacterId write SetCharacterId;
    property Depth: Word read FDepth write FDepth;
  end;

  TSWFPlaceObject = class (TSWFBasedPlaceObject)
  private
    FColorTransform: TSWFColorTransform;
    FInitColorTransform: Boolean;
    FMatrix: TSWFMatrix;
    function GetInitColorTransform: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TBasedSWFObject); override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteTagBody(be: TBitsEngine); override;
    property ColorTransform: TSWFColorTransform read FColorTransform;
    property InitColorTransform: Boolean read GetInitColorTransform write FInitColorTransform;
    property Matrix: TSWFMatrix read FMatrix;
  end;

  TSWFClipActionRecord = class (TSWFActionList)
  private
    FEventFlags: TSWFClipEvents;
    FKeyCode: Byte;
    procedure SetKeyCode(Value: Byte);
    function GetActions: TSWFActionList;
  public
//    constructor Create;
//    destructor Destroy; override;
    procedure Assign(Source: TSWFClipActionRecord);
    property Actions: TSWFActionList read GetActions;
    property EventFlags: TSWFClipEvents read FEventFlags write FEventFlags;
    property KeyCode: Byte read FKeyCode write SetKeyCode;
  end;
  
  TSWFClipActions = class (TObject)
  private
    FActionRecords: TObjectList;
    FAllEventFlags: TSWFClipEvents;
    function GetActionRecord(Index: Integer): TSWFClipActionRecord;
  public
    constructor Create;
    destructor Destroy; override;
    function AddActionRecord(EventFlags: TSWFClipEvents; KeyCode: byte): TSWFClipActionRecord;
    procedure Assign(Source: TSWFClipActions);
    function Count: integer;
    property ActionRecord[Index: Integer]: TSWFClipActionRecord read GetActionRecord;
    property ActionRecords: TObjectList read FActionRecords;
    property AllEventFlags: TSWFClipEvents read FAllEventFlags write FAllEventFlags;
  end;

  TSWFPlaceObject2 = class (TSWFBasedPlaceObject)
  private
    fClipActions: TSWFClipActions;
    FClipDepth: Word;
    FColorTransform: TSWFColorTransform;
    FMatrix: TSWFMatrix;
    FName: string;
    FParseActions: Boolean;
    FPlaceFlagHasCharacter: Boolean;
    FPlaceFlagHasClipActions: Boolean;
    FPlaceFlagHasClipDepth: Boolean;
    FPlaceFlagHasColorTransform: Boolean;
    FPlaceFlagHasMatrix: Boolean;
    FPlaceFlagHasName: Boolean;
    FPlaceFlagHasRatio: Boolean;
    FPlaceFlagMove: Boolean;
    FRatio: Word;
    FSWFVersion: Byte;
    function GetColorTransform: TSWFColorTransform;
    function GetMatrix: TSWFMatrix;
    procedure SetCharacterId(Value: Word); override;
    procedure SetClipDepth(Value: Word);
    procedure SetName(Value: string);
    procedure SetRatio(Value: Word);
  protected
    procedure ReadFilterFromStream(be: TBitsEngine); virtual;
    procedure ReadAddonFlag(be: TBitsEngine); virtual;
    procedure WriteAddonFlag(be: TBitsEngine); virtual;
    procedure WriteFilterToStream(be: TBitsEngine); virtual;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TBasedSWFObject); override;
    function ClipActions: TSWFClipActions;
    function MinVersion: Byte; override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteTagBody(be: TBitsEngine); override;
    property ClipDepth: Word read FClipDepth write SetClipDepth;
    property ColorTransform: TSWFColorTransform read GetColorTransform;
    property Matrix: TSWFMatrix read GetMatrix;
    property Name: string read FName write SetName;
    property ParseActions: Boolean read FParseActions write FParseActions;
    property PlaceFlagHasCharacter: Boolean read FPlaceFlagHasCharacter write FPlaceFlagHasCharacter;
    property PlaceFlagHasClipActions: Boolean read FPlaceFlagHasClipActions write FPlaceFlagHasClipActions;
    property PlaceFlagHasClipDepth: Boolean read FPlaceFlagHasClipDepth write FPlaceFlagHasClipDepth;
    property PlaceFlagHasColorTransform: Boolean read FPlaceFlagHasColorTransform write FPlaceFlagHasColorTransform;
    property PlaceFlagHasMatrix: Boolean read FPlaceFlagHasMatrix write FPlaceFlagHasMatrix;
    property PlaceFlagHasName: Boolean read FPlaceFlagHasName write FPlaceFlagHasName;
    property PlaceFlagHasRatio: Boolean read FPlaceFlagHasRatio write FPlaceFlagHasRatio;
    property PlaceFlagMove: Boolean read FPlaceFlagMove write FPlaceFlagMove;
    property Ratio: Word read FRatio write SetRatio;
    property SWFVersion: Byte read FSWFVersion write FSWFVersion;

  end;

 TSWFFilter = class (TObject)
 private
  FFilterID: TSWFFilterID;
 public
  procedure Assign(Source: TSWFFilter); virtual; abstract;
  procedure ReadFromStream(be: TBitsEngine); virtual; abstract;
  procedure WriteToStream(be: TBitsEngine); virtual; abstract;
  property FilterID: TSWFFilterID read FFilterID write FFilterID;
 end;

 TSWFColorMatrixFilter = class (TSWFFilter)
 private
  FMatrix: array [0..19] of single;
  function GetMatrix(Index: Integer): single;
  function GetR0: single;
  function GetR1: single;
  function GetR2: single;
  function GetR3: single;
  function GetR4: single;
  function GetG0: single;
  function GetG1: single;
  function GetG2: single;
  function GetG3: single;
  function GetG4: single;
  function GetB0: single;
  function GetB1: single;
  function GetB2: single;
  function GetB3: single;
  function GetB4: single;
  function GetA0: single;
  function GetA1: single;
  function GetA2: single;
  function GetA3: single;
  function GetA4: single;
  procedure SetMatrix(Index: Integer; const Value: single);
  procedure SetR0(const Value: single);
  procedure SetR1(const Value: single);
  procedure SetR2(const Value: single);
  procedure SetR3(const Value: single);
  procedure SetR4(const Value: single);
  procedure SetG0(const Value: single);
  procedure SetG1(const Value: single);
  procedure SetG2(const Value: single);
  procedure SetG3(const Value: single);
  procedure SetG4(const Value: single);
  procedure SetB0(const Value: single);
  procedure SetB1(const Value: single);
  procedure SetB2(const Value: single);
  procedure SetB3(const Value: single);
  procedure SetB4(const Value: single);
  procedure SetA0(const Value: single);
  procedure SetA1(const Value: single);
  procedure SetA2(const Value: single);
  procedure SetA3(const Value: single);
  procedure SetA4(const Value: single);
 public
  constructor Create;
  procedure AdjustColor(Brightness, Contrast, Saturation, Hue: Integer);
  procedure Assign(Source: TSWFFilter); override;
  procedure ResetValues;
  procedure ReadFromStream(be: TBitsEngine); override;
  procedure WriteToStream(be: TBitsEngine); override;
  property Matrix[Index: Integer]: single read GetMatrix write SetMatrix;
  property R0: single read GetR0 write SetR0;
  property R1: single read GetR1 write SetR1;
  property R2: single read GetR2 write SetR2;
  property R3: single read GetR3 write SetR3;
  property R4: single read GetR4 write SetR4;
  property G0: single read GetG0 write SetG0;
  property G1: single read GetG1 write SetG1;
  property G2: single read GetG2 write SetG2;
  property G3: single read GetG3 write SetG3;
  property G4: single read GetG4 write SetG4;
  property B0: single read GetB0 write SetB0;
  property B1: single read GetB1 write SetB1;
  property B2: single read GetB2 write SetB2;
  property B3: single read GetB3 write SetB3;
  property B4: single read GetB4 write SetB4;
  property A0: single read GetA0 write SetA0;
  property A1: single read GetA1 write SetA1;
  property A2: single read GetA2 write SetA2;
  property A3: single read GetA3 write SetA3;
  property A4: single read GetA4 write SetA4;
 end;

 TSWFConvolutionFilter = class (TSWFFilter)
 private
  FBias: single;
  FClamp: Boolean;
  FDefaultColor: TSWFRGBA;
  FDivisor: single;
  FMatrix: TList;
  FMatrixX: byte;
  FMatrixY: byte;
  FPreserveAlpha: Boolean;
  function GetMatrix(Index: Integer): single;
  procedure SetMatrix(Index: Integer; const Value: single);
 public
  constructor Create;
  destructor Destroy; override;
  procedure Assign(Source: TSWFFilter); override;
  procedure ReadFromStream(be: TBitsEngine); override;
  procedure WriteToStream(be: TBitsEngine); override;
  property Bias: single read FBias write FBias;
  property Clamp: Boolean read FClamp write FClamp;
  property DefaultColor: TSWFRGBA read FDefaultColor;
  property Divisor: single read FDivisor write FDivisor;
  property Matrix[Index: Integer]: single read GetMatrix write SetMatrix;
  property MatrixX: byte read FMatrixX write FMatrixX;
  property MatrixY: byte read FMatrixY write FMatrixY;
  property PreserveAlpha: Boolean read FPreserveAlpha write FPreserveAlpha;
 end;

 TSWFBlurFilter = class (TSWFFilter)
 private
  FBlurX: single;
  FBlurY: single;
  FPasses: byte;
 public
  constructor Create; virtual;
  procedure Assign(Source: TSWFFilter); override;
  procedure ReadFromStream(be: TBitsEngine); override;
  procedure WriteToStream(be: TBitsEngine); override;
  property BlurX: single read FBlurX write FBlurX;
  property BlurY: single read FBlurY write FBlurY;
  property Passes: byte read FPasses write FPasses;
 end;

 TSWFGlowFilter = class(TSWFBlurFilter)
 private
  FStrength: single;
  FGlowColor: TSWFRGBA;
  FInnerGlow: Boolean;
  FKnockout: Boolean;
  FCompositeSource: Boolean;
 public
  constructor Create; override;
  destructor Destroy; override;
  procedure Assign(Source: TSWFFilter); override;
  procedure ReadFromStream(be: TBitsEngine); override;
  procedure WriteToStream(be: TBitsEngine); override;
  property GlowColor: TSWFRGBA read FGlowColor;
  property InnerGlow: Boolean read FInnerGlow write FInnerGlow;
  property Knockout: Boolean read FKnockout write FKnockout;
  property CompositeSource: Boolean read FCompositeSource write FCompositeSource;
  property Strength: single read FStrength write FStrength;
 end;

 TSWFDropShadowFilter = class (TSWFBlurFilter)
 private
  FAngle: single;
  FCompositeSource: Boolean;
  FDistance: single;
  FInnerShadow: Boolean;
  FKnockout: Boolean;
  FStrength: single;
  FDropShadowColor: TSWFRGBA;
 public
  constructor Create; override;
  destructor Destroy; override;
  procedure Assign(Source: TSWFFilter); override;
  procedure ReadFromStream(be: TBitsEngine); override;
  procedure WriteToStream(be: TBitsEngine); override;
  property Angle: single read FAngle write FAngle;
  property CompositeSource: Boolean read FCompositeSource write FCompositeSource;
  property Distance: single read FDistance write FDistance;
  property DropShadowColor: TSWFRGBA read FDropShadowColor;
  property InnerShadow: Boolean read FInnerShadow write FInnerShadow;
  property Knockout: Boolean read FKnockout write FKnockout;
  property Strength: single read FStrength write FStrength;
 end;

 TSWFBevelFilter = class(TSWFBlurFilter)
 private
  FAngle: single;
  FCompositeSource: Boolean;
  FDistance: single;
  FInnerShadow: Boolean;
  FKnockout: Boolean;
  FStrength: single;
  FShadowColor: TSWFRGBA;
  FHighlightColor: TSWFRGBA;
  FOnTop: Boolean;
 public
  constructor Create; override;
  destructor Destroy; override;
  procedure Assign(Source: TSWFFilter); override;
  procedure ReadFromStream(be: TBitsEngine); override;
  procedure WriteToStream(be: TBitsEngine); override;
  property Angle: single read FAngle write FAngle;
  property CompositeSource: Boolean read FCompositeSource write FCompositeSource;
  property Distance: single read FDistance write FDistance;
  property ShadowColor: TSWFRGBA read FShadowColor;
  property InnerShadow: Boolean read FInnerShadow write FInnerShadow;
  property Knockout: Boolean read FKnockout write FKnockout;
  property HighlightColor: TSWFRGBA read FHighlightColor;
  property OnTop: Boolean read FOnTop write FOnTop;
  property Strength: single read FStrength write FStrength;
 end;

 TSWFGradientRec = record
   color: recRGBA;
   ratio: byte;
 end;

 TSWFGradientGlowFilter = class(TSWFBlurFilter)
 private
  FAngle: single;
  FColor: array [1..15] of TSWFRGBA;
  FCompositeSource: Boolean;
  FDistance: single;
  FInnerShadow: Boolean;
  FKnockout: Boolean;
  FNumColors: byte;
  FStrength: single;
  FOnTop: Boolean;
  FRatio: array [1..15] of byte;
  function GetGradient(Index: byte): TSWFGradientRec;
  function GetGradientColor(Index: Integer): TSWFRGBA;
  function GetGradientRatio(Index: Integer): Byte;
  procedure SetGradientRatio(Index: Integer; Value: Byte);
 public
  constructor Create; override;
  destructor Destroy; override;
  procedure Assign(Source: TSWFFilter); override;
  procedure ReadFromStream(be: TBitsEngine); override;
  procedure WriteToStream(be: TBitsEngine); override;
  property Angle: single read FAngle write FAngle;
  property CompositeSource: Boolean read FCompositeSource write FCompositeSource;
  property Distance: single read FDistance write FDistance;
  property Gradient[Index: byte]: TSWFGradientRec read GetGradient;
  property GradientColor[Index: Integer]: TSWFRGBA read GetGradientColor;
  property GradientRatio[Index: Integer]: Byte read GetGradientRatio write
      SetGradientRatio;
  property InnerShadow: Boolean read FInnerShadow write FInnerShadow;
  property Knockout: Boolean read FKnockout write FKnockout;
  property NumColors: byte read FNumColors write FNumColors;
  property OnTop: Boolean read FOnTop write FOnTop;
  property Strength: single read FStrength write FStrength;
 end;

 TSWFGradientBevelFilter = class (TSWFGradientGlowFilter)
 public
  constructor Create; override;
 end;

 TSWFFilterList = class (TObjectList)
 private
  function GetFilter(Index: Integer): TSWFFilter;
 public
  function AddFilter(id: TSwfFilterID): TSWFFilter;
  procedure ReadFromStream(be: TBitsEngine);
  procedure WriteToStream(be: TBitsEngine);
  property Filter[Index: Integer]: TSWFFilter read GetFilter;
 end;

 TSWFPlaceObject3 = class(TSWFPlaceObject2)
 private
  FBlendMode: TSWFBlendMode;
  FPlaceFlagHasCacheAsBitmap: Boolean;
  FPlaceFlagHasBlendMode: Boolean;
  FPlaceFlagHasFilterList: Boolean;
  FSaveAsPO2: boolean;
  FSurfaceFilterList: TSWFFilterList;
  FPlaceFlagHasImage: boolean;
  FPlaceFlagHasClassName: boolean;
  FClassName: string;
  function GetSurfaceFilterList: TSWFFilterList;
    procedure SetClassName(const Value: string);
 protected
  procedure ReadAddonFlag(be: TBitsEngine); override;
  procedure ReadFilterFromStream(be: TBitsEngine); override;
  procedure WriteAddonFlag(be: TBitsEngine); override;
  procedure WriteFilterToStream(be: TBitsEngine); override;
 public
  constructor Create;
  destructor Destroy; override;
  procedure Assign(Source: TBasedSWFObject); override;
  function MinVersion: Byte; override;
  property BlendMode: TSWFBlendMode read FBlendMode write FBlendMode;
  property _ClassName: string read FClassName write SetClassName;
  property PlaceFlagHasCacheAsBitmap: Boolean read FPlaceFlagHasCacheAsBitmap
      write FPlaceFlagHasCacheAsBitmap;
  property PlaceFlagHasBlendMode: Boolean read FPlaceFlagHasBlendMode write
      FPlaceFlagHasBlendMode;
  property PlaceFlagHasImage: boolean read FPlaceFlagHasImage write FPlaceFlagHasImage;
  property PlaceFlagHasClassName: boolean read FPlaceFlagHasClassName write FPlaceFlagHasClassName;
  property PlaceFlagHasFilterList: Boolean read FPlaceFlagHasFilterList write
      FPlaceFlagHasFilterList;
  property SaveAsPO2: boolean read FSaveAsPO2 write FSaveAsPO2;
  property SurfaceFilterList: TSWFFilterList read GetSurfaceFilterList;
 end;

  TSWFRemoveObject = class (TSWFObject)
  private
    FCharacterID: Word;
    FDepth: Word;
  public
    constructor Create;
    procedure Assign(Source: TBasedSWFObject); override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteTagBody(be: TBitsEngine); override;
    property CharacterID: Word read FCharacterID write FCharacterID;
    property Depth: Word read FDepth write FDepth;
  end;

  TSWFRemoveObject2 = class (TSWFObject)
  private
    Fdepth: Word;
  public
    constructor Create;
    procedure Assign(Source: TBasedSWFObject); override;
    function MinVersion: Byte; override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteTagBody(be: TBitsEngine); override;
    property depth: Word read Fdepth write Fdepth;
  end;

  TSWFShowFrame = class (TSWFObject)
  public
    constructor Create;
  end;

// =========================================================
//                        Shape
// =========================================================

  TSWFFillStyle = class (TObject)
  private
    FhasAlpha: Boolean;
    FSWFFillType: TSWFFillType;
  public
    procedure Assign(Source: TSWFFillStyle); virtual;
    procedure ReadFromStream(be: TBitsEngine); virtual; abstract;
    procedure WriteToStream(be: TBitsEngine); virtual; abstract;
    property hasAlpha: Boolean read FhasAlpha write FhasAlpha;
    property SWFFillType: TSWFFillType read FSWFFillType write FSWFFillType;
  end;

  TSWFLineStyle = class (TObject)
  private
    FColor: TSWFRGBA;
    FWidth: Word;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Assign(Source: TSWFLineStyle); virtual;
    procedure ReadFromStream(be: TBitsEngine); virtual;
    procedure WriteToStream(be: TBitsEngine); virtual;
    property Color: TSWFRGBA read FColor;
    property Width: Word read FWidth write FWidth;
  end;

  TSWFLineStyle2 = class (TSWFLineStyle)
  private
    FHasFillFlag: Boolean;
    FStartCapStyle: byte;
    FJoinStyle: byte;
    FNoClose: Boolean;
    FNoHScaleFlag: Boolean;
    FNoVScaleFlag: Boolean;
    FPixelHintingFlag: Boolean;
    FEndCapStyle: byte;
    FFillStyle: TSWFFillStyle;
    FMiterLimitFactor: single;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Assign(Source: TSWFLineStyle); override;
    function GetFillStyle(style: integer): TSWFFillStyle;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteToStream(be: TBitsEngine); override;
    property HasFillFlag: Boolean read FHasFillFlag write FHasFillFlag;
    property StartCapStyle: byte read FStartCapStyle write FStartCapStyle;
    property JoinStyle: byte read FJoinStyle write FJoinStyle;
    property NoClose: Boolean read FNoClose write FNoClose;
    property NoHScaleFlag: Boolean read FNoHScaleFlag write FNoHScaleFlag;
    property NoVScaleFlag: Boolean read FNoVScaleFlag write FNoVScaleFlag;
    property PixelHintingFlag: Boolean read FPixelHintingFlag write
        FPixelHintingFlag;
    property EndCapStyle: byte read FEndCapStyle write FEndCapStyle;
    property MiterLimitFactor: single read FMiterLimitFactor write
        FMiterLimitFactor;
  end;

  TSWFColorFill = class (TSWFFillStyle)
  private
    FColor: TSWFRGBA;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TSWFFillStyle); override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteToStream(be: TBitsEngine); override;
    property Color: TSWFRGBA read FColor;
  end;

  TSWFImageFill = class (TSWFFillStyle)
  private
    FImageID: Word;
    FMatrix: TSWFMatrix;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TSWFFillStyle); override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure ScaleTo(Frame: TRect; W, H: word);
    procedure WriteToStream(be: TBitsEngine); override;
    property ImageID: Word read FImageID write FImageID;
    property Matrix: TSWFMatrix read FMatrix;
  end;

 TSWFBaseGradientFill = class(TSWFFillStyle)
 private
   FColor: array [1..15] of TSWFRGBA;
   FCount: Byte;
   FInterpolationMode: TSWFInterpolationMode;
   FRatio: array [1..15] of byte;
   FSpreadMode: TSWFSpreadMode;
   function GetGradient(Index: byte): TSWFGradientRec;
   function GetGradientColor(Index: Integer): TSWFRGBA;
   function GetGradientRatio(Index: Integer): Byte;
   procedure SetGradientRatio(Index: Integer; Value: Byte);
 protected
   property InterpolationMode: TSWFInterpolationMode read FInterpolationMode write
       FInterpolationMode;
   property SpreadMode: TSWFSpreadMode read FSpreadMode write FSpreadMode;
 public
   constructor Create;
   destructor Destroy; override;
   procedure Assign(Source: TSWFFillStyle); override;
   procedure ReadFromStream(be: TBitsEngine); override;
   procedure WriteToStream(be: TBitsEngine); override;
   property Count: Byte read FCount write FCount;
   property Gradient[Index: byte]: TSWFGradientRec read GetGradient;
   property GradientColor[Index: Integer]: TSWFRGBA read GetGradientColor;
   property GradientRatio[Index: Integer]: Byte read GetGradientRatio write SetGradientRatio;
 end;

 TSWFGradientFill = class (TSWFBaseGradientFill)
 private
   FMatrix: TSWFMatrix;
 public
   constructor Create;
   destructor Destroy; override;
   procedure Assign(Source: TSWFFillStyle); override;
   procedure ReadFromStream(be: TBitsEngine); override;
   procedure ScaleTo(Frame: TRect);
   procedure WriteToStream(be: TBitsEngine); override;
   property Matrix: TSWFMatrix read FMatrix;
 end;

 TSWFFocalGradientFill = class(TSWFGradientFill)
 private
  FFocalPoint: smallint;
  function GetFocalPoint: single;
  procedure SetFocalPoint(const Value: single);
 public
  constructor Create;
  procedure Assign(Source: TSWFFillStyle); override;
  procedure ReadFromStream(be: TBitsEngine); override;
  procedure WriteToStream(be: TBitsEngine); override;
  property FocalPoint: single read GetFocalPoint write SetFocalPoint;
  property InterpolationMode;
  property SpreadMode;
 end;

  TSWFShapeRecord = class (TObject)
  private
    FShapeRecType: TShapeRecType;
  public
    procedure Assign(Source: TSWFShapeRecord); virtual;
    procedure WriteToStream(be: TBitsEngine); virtual; abstract;
    property ShapeRecType: TShapeRecType read FShapeRecType write FShapeRecType;
  end;

  TSWFEndShapeRecord = class (TSWFShapeRecord)
  public
    constructor Create;
    procedure WriteToStream(be: TBitsEngine); override;
  end;

  TSWFStraightEdgeRecord = class (TSWFShapeRecord)
  private
    FX: LongInt;
    FY: LongInt;
  public
    constructor Create;
    procedure Assign(Source: TSWFShapeRecord); override;
    procedure WriteToStream(be: TBitsEngine); override;
    property X: LongInt read FX write FX;
    property Y: LongInt read FY write FY;
  end;

  TSWFStyleChangeRecord = class (TSWFStraightEdgeRecord)
  private
    bitsFill: Byte;
    bitsLine: Byte;
    FFill0Id: Word;
    FFill1Id: Word;
    FLineId: Word;
    FNewFillStyles: TObjectList;
    FNewLineStyles: TObjectList;
    FStateFillStyle0: Boolean;
    FStateFillStyle1: Boolean;
    FStateLineStyle: Boolean;
    FStateMoveTo: Boolean;
    FStateNewStyles: Boolean;
    hasAlpha: Boolean;
    function GetNewFillStyles: TObjectList;
    function GetNewLineStyles: TObjectList;
    procedure SetFill0Id(Value: Word);
    procedure SetFill1Id(Value: Word);
    procedure SetLineId(Value: Word);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TSWFShapeRecord); override;
    procedure WriteToStream(be: TBitsEngine); override;
    property Fill0Id: Word read FFill0Id write SetFill0Id;
    property Fill1Id: Word read FFill1Id write SetFill1Id;
    property LineId: Word read FLineId write SetLineId;
    property NewFillStyles: TObjectList read GetNewFillStyles;
    property NewLineStyles: TObjectList read GetNewLineStyles;
    property StateFillStyle0: Boolean read FStateFillStyle0 write FStateFillStyle0;
    property StateFillStyle1: Boolean read FStateFillStyle1 write FStateFillStyle1;
    property StateLineStyle: Boolean read FStateLineStyle write FStateLineStyle;
    property StateMoveTo: Boolean read FStateMoveTo write FStateMoveTo;
    property StateNewStyles: Boolean read FStateNewStyles write FStateNewStyles;
  end;

  TSWFCurvedEdgeRecord = class (TSWFShapeRecord)
  private
    FAnchorX: LongInt;
    FAnchorY: LongInt;
    FControlX: LongInt;
    FControlY: LongInt;
  public
    constructor Create;
    procedure Assign(Source: TSWFShapeRecord); override;
    procedure WriteToStream(be: TBitsEngine); override;
    property AnchorX: LongInt read FAnchorX write FAnchorX;
    property AnchorY: LongInt read FAnchorY write FAnchorY;
    property ControlX: LongInt read FControlX write FControlX;
    property ControlY: LongInt read FControlY write FControlY;
  end;
  
  TSWFDefineShape = class (TSWFObject)
  private
    FEdges: TObjectList;
    FFillStyles: TObjectList;
    FhasAlpha: Boolean;
    FLineStyles: TObjectList;
    FShapeBounds: TSWFRect;
    FShapeId: Word;
  protected
    function GetEdgeRecord(index: longint): TSWFShapeRecord;
    procedure ReadAddonFromStream(be: TBitsEngine); virtual;
    procedure WriteAddonToStream(be: TBitsEngine); virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Assign(Source: TBasedSWFObject); override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteTagBody(be: TBitsEngine); override;
    property EdgeRecord[index: longint]: TSWFShapeRecord read GetEdgeRecord;
    property Edges: TObjectList read FEdges write FEdges;
    property FillStyles: TObjectList read FFillStyles;
    property hasAlpha: Boolean read FhasAlpha write FhasAlpha;
    property LineStyles: TObjectList read FLineStyles;
    property ShapeBounds: TSWFRect read FShapeBounds;
    property ShapeId: Word read FShapeId write FShapeId;
  end;
  
  TSWFDefineShape2 = class (TSWFDefineShape)
  public
    constructor Create; override;
    function MinVersion: Byte; override;
  end;

  TSWFDefineShape3 = class (TSWFDefineShape)
  public
    constructor Create; override;
    function MinVersion: Byte; override;
  end;

  TSWFDefineShape4 = class (TSWFDefineShape)
  private
    FEdgeBounds: TSWFRect;
    FUsesNonScalingStrokes: Boolean;
    FUsesScalingStrokes: Boolean;
  protected
    procedure ReadAddonFromStream(be: TBitsEngine); override;
    procedure WriteAddonToStream(be: TBitsEngine); override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Assign(Source: TBasedSWFObject); override;
    function MinVersion: Byte; override;
    property EdgeBounds: TSWFRect read FEdgeBounds;
    property UsesNonScalingStrokes: Boolean read FUsesNonScalingStrokes write
        FUsesNonScalingStrokes;
    property UsesScalingStrokes: Boolean read FUsesScalingStrokes write
        FUsesScalingStrokes;
  end;
// ==========================================================
//                      Bitmaps
// ==========================================================

  TSWFDataObject = class (TSWFObject)
  private
    FData: Pointer;
    FDataSize: LongInt;
    FOnDataWrite: TSWFTagEvent;
    FSelfDestroy: Boolean;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Assign(Source: TBasedSWFObject); override;
    property Data: Pointer read FData write FData;
    property DataSize: LongInt read FDataSize write FDataSize;
    property OnDataWrite: TSWFTagEvent read FOnDataWrite write FOnDataWrite;
    property SelfDestroy: Boolean read FSelfDestroy write FSelfDestroy;
  end;

  TSWFDefineBinaryData = class (TSWFDataObject)
  private
    FCharacterID: word;
  public
    constructor Create; override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteTagBody(be: TBitsEngine); override;
    property CharacterID: word read FCharacterID write FCharacterID;
  end;

  TSWFImageTag = class (TSWFDataObject)
  private
    FCharacterID: Word;
  public
    procedure Assign(Source: TBasedSWFObject); override;
    property CharacterID: Word read FCharacterID write FCharacterID;
  end;

  TSWFDefineBits = class (TSWFImageTag)
  public
    constructor Create; override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteTagBody(be: TBitsEngine); override;
  end;

  TSWFJPEGTables = class (TSWFDataObject)
  public
    constructor Create; override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteTagBody(be: TBitsEngine); override;
  end;

  TSWFDefineBitsJPEG2 = class (TSWFDefineBits)
  public
    constructor Create; override;
    function MinVersion: Byte; override;
    procedure WriteTagBody(be: TBitsEngine); override;
  end;

  TSWFDefineBitsJPEG3 = class (TSWFDefineBitsJPEG2)
  private
    FAlphaData: Pointer;
    FAlphaDataSize: LongInt;
    FOnAlphaDataWrite: TSWFTagEvent;
    FSelfAlphaDestroy: Boolean;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Assign(Source: TBasedSWFObject); override;
    function MinVersion: Byte; override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteTagBody(be: TBitsEngine); override;
    property AlphaData: Pointer read FAlphaData write FAlphaData;
    property AlphaDataSize: LongInt read FAlphaDataSize write FAlphaDataSize;
    property OnAlphaDataWrite: TSWFTagEvent read FOnAlphaDataWrite write FOnAlphaDataWrite;
    property SelfAlphaDestroy: Boolean read FSelfAlphaDestroy write FSelfAlphaDestroy;
  end;

  TSWFDefineBitsLossless = class (TSWFImageTag)
  private
    FBitmapColorTableSize: Byte;
    FBitmapFormat: Byte;
    FBitmapHeight: Word;
    FBitmapWidth: Word;
  public
    constructor Create; override;
    procedure Assign(Source: TBasedSWFObject); override;
    function MinVersion: Byte; override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteTagBody(be: TBitsEngine); override;
    property BitmapColorTableSize: Byte read FBitmapColorTableSize write FBitmapColorTableSize;
    property BitmapFormat: Byte read FBitmapFormat write FBitmapFormat;
    property BitmapHeight: Word read FBitmapHeight write FBitmapHeight;
    property BitmapWidth: Word read FBitmapWidth write FBitmapWidth;
  end;

  TSWFDefineBitsLossless2 = class (TSWFDefineBitsLossless)
  public
    constructor Create; override;
    function MinVersion: Byte; override;
  end;


// ==========================================================
//                      Morphing
// ==========================================================
 TSWFMorphGradientRec = record
   StartColor,
   EndColor: recRGBA;
   StartRatio,
   EndRatio: byte;
 end;

  TSWFMorphLineStyle = class (TObject)
  private
    FEndColor: TSWFRGBA;
    FEndWidth: Word;
    FStartColor: TSWFRGBA;
    FStartWidth: Word;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Assign(Source: TSWFMorphLineStyle);
    procedure ReadFromStream(be: TBitsEngine); virtual;
    procedure WriteToStream(be: TBitsEngine); virtual;
    property EndColor: TSWFRGBA read FEndColor;
    property EndWidth: Word read FEndWidth write FEndWidth;
    property StartColor: TSWFRGBA read FStartColor;
    property StartWidth: Word read FStartWidth write FStartWidth;
  end;

  TSWFMorphLineStyle2 = class (TSWFMorphLineStyle)
  private
   FEndCapStyle: byte;
   FHasFillFlag: Boolean;
   FJoinStyle: byte;
   FMiterLimitFactor: single;
   FNoClose: Boolean;
   FNoHScaleFlag: Boolean;
   FNoVScaleFlag: Boolean;
   FPixelHintingFlag: Boolean;
   FStartCapStyle: byte;
   FFillStyle: TSWFFillStyle;
  public
   destructor Destroy; override;
   function GetFillStyle(style: integer): TSWFFillStyle;
   procedure ReadFromStream(be: TBitsEngine); override;
   procedure WriteToStream(be: TBitsEngine); override;
   property EndCapStyle: byte read FEndCapStyle write FEndCapStyle;
   property HasFillFlag: Boolean read FHasFillFlag write FHasFillFlag;
   property JoinStyle: byte read FJoinStyle write FJoinStyle;
   property MiterLimitFactor: single read FMiterLimitFactor write
       FMiterLimitFactor;
   property NoClose: Boolean read FNoClose write FNoClose;
   property NoHScaleFlag: Boolean read FNoHScaleFlag write FNoHScaleFlag;
   property NoVScaleFlag: Boolean read FNoVScaleFlag write FNoVScaleFlag;
   property PixelHintingFlag: Boolean read FPixelHintingFlag write
       FPixelHintingFlag;
   property StartCapStyle: byte read FStartCapStyle write FStartCapStyle;
  end;

  TSWFMorphFillStyle = class (TObject)
  private
    FSWFFillType: TSWFFillType;
  public
    procedure Assign(Source: TSWFMorphFillStyle); virtual; abstract;
    procedure ReadFromStream(be: TBitsEngine); virtual; abstract;
    procedure WriteToStream(be: TBitsEngine); virtual; abstract;
    property SWFFillType: TSWFFillType read FSWFFillType write FSWFFillType;
  end;

  TSWFMorphColorFill = class (TSWFMorphFillStyle)
  private
    FEndColor: TSWFRGBA;
    FStartColor: TSWFRGBA;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TSWFMorphFillStyle); override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteToStream(be: TBitsEngine); override;
    property EndColor: TSWFRGBA read FEndColor;
    property StartColor: TSWFRGBA read FStartColor;
  end;

  TSWFMorphGradientFill = class (TSWFMorphFillStyle)
  private
    FCount: Byte;
    FEndColor: array [1..8] of TSWFRGBA;
    FEndMatrix: TSWFMatrix;
    FEndRatio: array [1..8] of byte;
    FStartColor: array [1..8] of TSWFRGBA;
    FStartMatrix: TSWFMatrix;
    FStartRatio: array [1..8] of byte;
    FSpreadMode: byte;
    FInterpolationMode: byte;
    function GetEndColor(Index: Integer): TSWFRGBA;
    function GetEndGradient(Index: byte): TSWFGradientRec;
    function GetEndRatio(Index: Integer): Byte;
    function GetGradient(Index: byte): TSWFMorphGradientRec;
    function GetStartColor(Index: Integer): TSWFRGBA;
    function GetStartGradient(Index: byte): TSWFGradientRec;
    function GetStartRatio(Index: Integer): Byte;
    procedure SetEndRatio(Index: Integer; Value: Byte);
    procedure SetStartRatio(Index: Integer; Value: Byte);
  protected
    property InterpolationMode: byte read FInterpolationMode write FInterpolationMode;
    property SpreadMode: byte read FSpreadMode write FSpreadMode;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Assign(Source: TSWFMorphFillStyle); override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteToStream(be: TBitsEngine); override;
    property Count: Byte read FCount write FCount;
    property EndColor[Index: Integer]: TSWFRGBA read GetEndColor;
    property EndGradient[Index: byte]: TSWFGradientRec read GetEndGradient;
    property EndMatrix: TSWFMatrix read FEndMatrix;
    property EndRatio[Index: Integer]: Byte read GetEndRatio write SetEndRatio;
    property Gradient[Index: byte]: TSWFMorphGradientRec read GetGradient;
    property StartColor[Index: Integer]: TSWFRGBA read GetStartColor;
    property StartGradient[Index: byte]: TSWFGradientRec read GetStartGradient;
    property StartMatrix: TSWFMatrix read FStartMatrix;
    property StartRatio[Index: Integer]: Byte read GetStartRatio write SetStartRatio;
  end;

  TSWFMorphFocalGradientFill = class (TSWFMorphGradientFill)
  private
    FStartFocalPoint: smallint;
    FEndFocalPoint: smallint;
    function GetStartFocalPoint: single;
    procedure SetStartFocalPoint(const Value: single);
    function GetEndFocalPoint: single;
    procedure SetEndFocalPoint(const Value: single);
  public
    constructor Create; override;

    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteToStream(be: TBitsEngine); override;
    property StartFocalPoint: single read GetStartFocalPoint write SetStartFocalPoint;
    property EndFocalPoint: single read GetEndFocalPoint write SetEndFocalPoint;
    property InterpolationMode;
    property SpreadMode;
  end;

  TSWFMorphImageFill = class (TSWFMorphFillStyle)
  private
    FEndMatrix: TSWFMatrix;
    FImageID: Word;
    FStartMatrix: TSWFMatrix;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TSWFMorphFillStyle); override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteToStream(be: TBitsEngine); override;
    property EndMatrix: TSWFMatrix read FEndMatrix;
    property ImageID: Word read FImageID write FImageID;
    property StartMatrix: TSWFMatrix read FStartMatrix;
  end;
  
  TSWFDefineMorphShape = class (TSWFObject)
  private
    FCharacterID: Word;
    FEndBounds: TSWFRect;
    FEndEdges: TObjectList;
    FMorphFillStyles: TObjectList;
    FMorphLineStyles: TObjectList;
    FStartBounds: TSWFRect;
    FStartEdges: TObjectList;
    function GetEndEdgeRecord(Index: Integer): TSWFShapeRecord;
    function GetStartEdgeRecord(Index: Integer): TSWFShapeRecord;
  protected
    procedure ReadAddonFromStream(be: TBitsEngine); virtual;
    procedure WriteAddonToStream(be: TBitsEngine); virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Assign(Source: TBasedSWFObject); override;
    function MinVersion: Byte; override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteTagBody(be: TBitsEngine); override;
    property CharacterID: Word read FCharacterID write FCharacterID;
    property EndBounds: TSWFRect read FEndBounds;
    property EndEdgeRecord[Index: Integer]: TSWFShapeRecord read GetEndEdgeRecord;
    property EndEdges: TObjectList read FEndEdges;
    property MorphFillStyles: TObjectList read FMorphFillStyles;
    property MorphLineStyles: TObjectList read FMorphLineStyles;
    property StartBounds: TSWFRect read FStartBounds;
    property StartEdgeRecord[Index: Integer]: TSWFShapeRecord read GetStartEdgeRecord;
    property StartEdges: TObjectList read FStartEdges;
  end;

  TSWFDefineMorphShape2 = class (TSWFDefineMorphShape)
  private
    FStartEdgeBounds: TSWFRect;
    FEndEdgeBounds: TSWFRect;
    FUsesNonScalingStrokes: Boolean;
    FUsesScalingStrokes: Boolean;
  protected
    procedure ReadAddonFromStream(be: TBitsEngine); override;
    procedure WriteAddonToStream(be: TBitsEngine); override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Assign(Source: TBasedSWFObject); override;
    property StartEdgeBounds: TSWFRect read FStartEdgeBounds;
    property EndEdgeBounds: TSWFRect read FEndEdgeBounds;
    property UsesNonScalingStrokes: Boolean read FUsesNonScalingStrokes write FUsesNonScalingStrokes;
    property UsesScalingStrokes: Boolean read FUsesScalingStrokes write FUsesScalingStrokes;
  end;

// ==========================================================
//                        TEXT
// ==========================================================

  TSWFDefineFont = class (TSWFObject)
  private
    FFontID: Word;
    FGlyphShapeTable: TObjectList;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Assign(Source: TBasedSWFObject); override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteTagBody(be: TBitsEngine); override;
    property FontID: Word read FFontID write FFontID;
    property GlyphShapeTable: TObjectList read FGlyphShapeTable write FGlyphShapeTable;
  end;

  TSWFDefineFontInfo = class (TSWFObject)
  private
    FCodeTable: TList;
    FFontFlagsANSI: Boolean;
    FFontFlagsBold: Boolean;
    FFontFlagsItalic: Boolean;
    FFontFlagsShiftJIS: Boolean;
    FFontFlagsSmallText: Boolean;
    FFontFlagsWideCodes: Boolean;
    FFontID: Word;
    FFontName: string;
    FSWFVersion: Byte;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Assign(Source: TBasedSWFObject); override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteTagBody(be: TBitsEngine); override;
    property CodeTable: TList read FCodeTable;
    property FontFlagsANSI: Boolean read FFontFlagsANSI write FFontFlagsANSI;
    property FontFlagsBold: Boolean read FFontFlagsBold write FFontFlagsBold;
    property FontFlagsItalic: Boolean read FFontFlagsItalic write FFontFlagsItalic;
    property FontFlagsShiftJIS: Boolean read FFontFlagsShiftJIS write FFontFlagsShiftJIS;
    property FontFlagsSmallText: Boolean read FFontFlagsSmallText write FFontFlagsSmallText;
    property FontFlagsWideCodes: Boolean read FFontFlagsWideCodes write FFontFlagsWideCodes;
    property FontID: Word read FFontID write FFontID;
    property FontName: string read FFontName write FFontName;
    property SWFVersion: Byte read FSWFVersion write FSWFVersion;
  end;
  
  TSWFDefineFontInfo2 = class (TSWFDefineFontInfo)
  private
    FLanguageCode: Byte;
  public
    constructor Create; override;
    procedure Assign(Source: TBasedSWFObject); override;
    function MinVersion: Byte; override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteTagBody(be: TBitsEngine); override;
    property LanguageCode: Byte read FLanguageCode write FLanguageCode;
  end;

  TSWFKerningRecord = class (TObject)
  private
    FFontKerningAdjustment: Integer;
    FFontKerningCode1: Word;
    FFontKerningCode2: Word;
  public
    procedure Assign(source: TSWFKerningRecord);
    property FontKerningAdjustment: Integer read FFontKerningAdjustment write FFontKerningAdjustment;
    property FontKerningCode1: Word read FFontKerningCode1 write FFontKerningCode1;
    property FontKerningCode2: Word read FFontKerningCode2 write FFontKerningCode2;
  end;

  TSWFDefineFont2 = class (TSWFDefineFont)
  private
    FCodeTable: TList;
    FFontAdvanceTable: TList;
    FFontAscent: Word;
    FFontBoundsTable: TObjectList;
    FFontDescent: Word;
    FFontFlagsANSI: Boolean;
    FFontFlagsBold: Boolean;
    FFontFlagsHasLayout: Boolean;
    FFontFlagsItalic: Boolean;
    FFontFlagsShiftJIS: Boolean;
    FFontFlagsSmallText: Boolean;
    FFontFlagsWideCodes: Boolean;
    FFontFlagsWideOffsets: Boolean;
    FFontKerningTable: TObjectList;
    FFontLeading: Word;
    FFontName: string;
    FKerningCount: Word;
    FLanguageCode: Byte;
    FSWFVersion: Byte;
    function GetFontKerningTable: TObjectList;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Assign(Source: TBasedSWFObject); override;
    function MinVersion: Byte; override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteTagBody(be: TBitsEngine); override;
    property CodeTable: TList read FCodeTable;
    property FontAdvanceTable: TList read FFontAdvanceTable;
    property FontAscent: Word read FFontAscent write FFontAscent;
    property FontBoundsTable: TObjectList read FFontBoundsTable;
    property FontDescent: Word read FFontDescent write FFontDescent;
    property FontFlagsANSI: Boolean read FFontFlagsANSI write FFontFlagsANSI;
    property FontFlagsBold: Boolean read FFontFlagsBold write FFontFlagsBold;
    property FontFlagsHasLayout: Boolean read FFontFlagsHasLayout write FFontFlagsHasLayout;
    property FontFlagsItalic: Boolean read FFontFlagsItalic write FFontFlagsItalic;
    property FontFlagsShiftJIS: Boolean read FFontFlagsShiftJIS write FFontFlagsShiftJIS;
    property FontFlagsSmallText: Boolean read FFontFlagsSmallText write FFontFlagsSmallText;
    property FontFlagsWideCodes: Boolean read FFontFlagsWideCodes write FFontFlagsWideCodes;
    property FontFlagsWideOffsets: Boolean read FFontFlagsWideOffsets write FFontFlagsWideOffsets;
    property FontKerningTable: TObjectList read GetFontKerningTable;
    property FontLeading: Word read FFontLeading write FFontLeading;
    property FontName: string read FFontName write FFontName;
    property KerningCount: Word read FKerningCount write FKerningCount;
    property LanguageCode: Byte read FLanguageCode write FLanguageCode;
    property SWFVersion: Byte read FSWFVersion write FSWFVersion;
  end;

  TSWFDefineFont3 = class (TSWFDefineFont2)
  private
  public
    constructor Create; override;
    function MinVersion: Byte; override;
  end;

  TSWFZoneData = class (TObject)
  private
   FAlignmentCoordinate: word;
   FRange: word;
  public
   property AlignmentCoordinate: word read FAlignmentCoordinate write
       FAlignmentCoordinate;
   property Range: word read FRange write FRange;
  end;

  TSWFZoneRecord = class (TObjectList)
  private
   FNumZoneData: byte;
   FZoneMaskX: Boolean;
   FZoneMaskY: Boolean;
   function GetZoneData(Index: Integer): TSWFZoneData;
  public
   function AddZoneData: TSWFZoneData;
   property NumZoneData: byte read FNumZoneData write FNumZoneData;
   property ZoneData[Index: Integer]: TSWFZoneData read GetZoneData;
   property ZoneMaskX: Boolean read FZoneMaskX write FZoneMaskX;
   property ZoneMaskY: Boolean read FZoneMaskY write FZoneMaskY;
  end;

  TSWFZoneTable = class (TObjectList)
  private
   function GetZoneRecord(Index: Integer): TSWFZoneRecord;
  public
   function AddZoneRecord: TSWFZoneRecord;
   property ZoneRecord[Index: Integer]: TSWFZoneRecord read GetZoneRecord; default;
  end;

  TSWFDefineFontAlignZones = class (TSWFObject)
  private
    FCSMTableHint: byte;
    FFontID: word;
    FZoneTable: TSWFZoneTable;
  public
    constructor Create;
    destructor Destroy; override;
    function MinVersion: Byte; override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteTagBody(be: TBitsEngine); override;
    property CSMTableHint: byte read FCSMTableHint write FCSMTableHint;
    property FontID: word read FFontID write FFontID;
    property ZoneTable: TSWFZoneTable read FZoneTable;
  end;

  TSWFDefineFontName = class (TSWFObject)
  private
    FFontID: word;
    FFontName: string;
    FFontCopyright: string;
  public
    constructor Create;
    function MinVersion: Byte; override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteTagBody(be: TBitsEngine); override;
    property FontID: word read FFontID write FFontID;
    property FontName: string read FFontName write FFontName;
    property FontCopyright: string read FFontCopyright write FFontCopyright;
  end;

  TSWFGlyphEntry = class (TObject)
  private
    FGlyphAdvance: Integer;
    FGlyphIndex: Word;
  public
    property GlyphAdvance: Integer read FGlyphAdvance write FGlyphAdvance;
    property GlyphIndex: Word read FGlyphIndex write FGlyphIndex;
  end;
  
  TSWFTextRecord = class (TObject)
  private
    FFontID: Word;
    FGlyphEntries: TObjectList;
    FStyleFlagsHasColor: Boolean;
    FStyleFlagsHasFont: Boolean;
    FStyleFlagsHasXOffset: Boolean;
    FStyleFlagsHasYOffset: Boolean;
    FTextColor: TSWFRGBA;
    FTextHeight: Word;
    FXOffset: Integer;
    FYOffset: Integer;
    function GetGlyphEntry(Index: word): TSWFGlyphEntry;
    function GetTextColor: TSWFRGBA;
    procedure SetFontID(Value: Word);
    procedure SetTextHeight(Value: Word);
    procedure SetXOffset(Value: Integer);
    procedure SetYOffset(Value: Integer);
  protected
    hasAlpha: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TSWFTextRecord);
    procedure WriteToStream(be: TBitsEngine; gb, ab: byte);
    property FontID: Word read FFontID write SetFontID;
    property GlyphEntries: TObjectList read FGlyphEntries;
    property GlyphEntry[Index: word]: TSWFGlyphEntry read GetGlyphEntry;
    property StyleFlagsHasColor: Boolean read FStyleFlagsHasColor write FStyleFlagsHasColor;
    property StyleFlagsHasFont: Boolean read FStyleFlagsHasFont write FStyleFlagsHasFont;
    property StyleFlagsHasXOffset: Boolean read FStyleFlagsHasXOffset write FStyleFlagsHasXOffset;
    property StyleFlagsHasYOffset: Boolean read FStyleFlagsHasYOffset write FStyleFlagsHasYOffset;
    property TextColor: TSWFRGBA read GetTextColor;
    property TextHeight: Word read FTextHeight write SetTextHeight;
    property XOffset: Integer read FXOffset write SetXOffset;
    property YOffset: Integer read FYOffset write SetYOffset;
  end;
  
  TSWFDefineText = class (TSWFObject)
  private
    FAdvanceBits: Byte;
    FCharacterID: Word;
    FGlyphBits: Byte;
    FhasAlpha: Boolean;
    FTextBounds: TSWFRect;
    FTextMatrix: TSWFMatrix;
    FTextRecords: TObjectList;
    function GetTextRecord(Index: Integer): TSWFTextRecord;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TBasedSWFObject); override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteTagBody(be: TBitsEngine); override;
    property AdvanceBits: Byte read FAdvanceBits write FAdvanceBits;
    property CharacterID: Word read FCharacterID write FCharacterID;
    property GlyphBits: Byte read FGlyphBits write FGlyphBits;
    property hasAlpha: Boolean read FhasAlpha write FhasAlpha;
    property TextBounds: TSWFRect read FTextBounds;
    property TextMatrix: TSWFMatrix read FTextMatrix;
    property TextRecord[Index: Integer]: TSWFTextRecord read GetTextRecord;
    property TextRecords: TObjectList read FTextRecords;
  end;
  
  TSWFDefineText2 = class (TSWFDefineText)
  public
    constructor Create;
    function MinVersion: Byte; override;
  end;
  
  TSWFDefineEditText = class (TSWFObject)
  private
    FAlign: Byte;
    FAutoSize: Boolean;
    FBorder: Boolean;
    FBounds: TSWFRect;
    FCharacterID: Word;
    FFontHeight: Word;
    FFontID: Word;
    FHasFont: Boolean;
    FHasLayout: Boolean;
    FHasMaxLength: Boolean;
    FHasText: Boolean;
    FHasTextColor: Boolean;
    FHTML: Boolean;
    FIndent: Word;
    FInitialText: AnsiString;
    FLeading: Word;
    FLeftMargin: Word;
    FMaxLength: Word;
    FMultiline: Boolean;
    FNoSelect: Boolean;
    FPassword: Boolean;
    FReadOnly: Boolean;
    FRightMargin: Word;
    FSWFVersion: Integer;
    FTextColor: TSWFRGBA;
    FUseOutlines: Boolean;
    FVariableName: string;
    FWideInitialText: WideString;
//    FWideLength: Cardinal;
    FWordWrap: Boolean;
    FHasFontClass: boolean;
    FFontClass: string;
    function GetTextColor: TSWFRGBA;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TBasedSWFObject); override;
    function MinVersion: Byte; override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteTagBody(be: TBitsEngine); override;
    property Align: Byte read FAlign write FAlign;
    property AutoSize: Boolean read FAutoSize write FAutoSize;
    property Border: Boolean read FBorder write FBorder;
    property Bounds: TSWFRect read FBounds;
    property CharacterID: Word read FCharacterID write FCharacterID;
    property FontHeight: Word read FFontHeight write FFontHeight;
    property FontID: Word read FFontID write FFontID;
    property FontClass: string read FFontClass write FFontClass;
    property HasFont: Boolean read FHasFont write FHasFont;
    property HasFontClass: boolean read FHasFontClass write FHasFontClass;
    property HasLayout: Boolean read FHasLayout write FHasLayout;
    property HasMaxLength: Boolean read FHasMaxLength write FHasMaxLength;
    property HasText: Boolean read FHasText write FHasText;
    property HasTextColor: Boolean read FHasTextColor write FHasTextColor;
    property HTML: Boolean read FHTML write FHTML;
    property Indent: Word read FIndent write FIndent;
    property InitialText: AnsiString read FInitialText write FInitialText;
    property Leading: Word read FLeading write FLeading;
    property LeftMargin: Word read FLeftMargin write FLeftMargin;
    property MaxLength: Word read FMaxLength write FMaxLength;
    property Multiline: Boolean read FMultiline write FMultiline;
    property NoSelect: Boolean read FNoSelect write FNoSelect;
    property Password: Boolean read FPassword write FPassword;
    property ReadOnly: Boolean read FReadOnly write FReadOnly;
    property RightMargin: Word read FRightMargin write FRightMargin;
    property SWFVersion: Integer read FSWFVersion write FSWFVersion;
    property TextColor: TSWFRGBA read GetTextColor;
    property UseOutlines: Boolean read FUseOutlines write FUseOutlines;
    property VariableName: string read FVariableName write FVariableName;
    property WideInitialText: WideString read FWideInitialText write FWideInitialText;
    property WordWrap: Boolean read FWordWrap write FWordWrap;
  end;

  TSWFCSMTextSettings = class (TSWFObject)
  private
    FGridFit: byte;
    FSharpness: single;
    FTextID: word;
    FThickness: single;
    FUseFlashType: byte;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TBasedSWFObject); override;
    function MinVersion: Byte; override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteTagBody(be: TBitsEngine); override;
    property GridFit: byte read FGridFit write FGridFit;
    property Sharpness: single read FSharpness write FSharpness;
    property TextID: word read FTextID write FTextID;
    property Thickness: single read FThickness write FThickness;
    property UseFlashType: byte read FUseFlashType write FUseFlashType;
  end;

// ===========================================================
//                         SOUND
// ===========================================================

  TSWFDefineSound = class (TSWFDataObject)
  private
    FSeekSamples: Word;
    FSoundFormat: Byte;
    FSoundId: Word;
    FSoundRate: Byte;
    FSoundSampleCount: dword;
    FSoundSize: Boolean;
    FSoundType: Boolean;
  public
    constructor Create; override;
    procedure Assign(Source: TBasedSWFObject); override;
    function MinVersion: Byte; override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteTagBody(be: TBitsEngine); override;
    property SeekSamples: Word read FSeekSamples write FSeekSamples;
    property SoundFormat: Byte read FSoundFormat write FSoundFormat;
    property SoundId: Word read FSoundId write FSoundId;
    property SoundRate: Byte read FSoundRate write FSoundRate;
    property SoundSampleCount: dword read FSoundSampleCount write FSoundSampleCount;
    property SoundSize: Boolean read FSoundSize write FSoundSize;
    property SoundType: Boolean read FSoundType write FSoundType;
  end;
  
  TSWFSoundEnvelope = class (TObject)
  private
    FLeftLevel: Word;
    FPos44: dword;
    FRightLevel: Word;
  public
    procedure Assign(Source: TSWFSoundEnvelope);
    property LeftLevel: Word read FLeftLevel write FLeftLevel;
    property Pos44: dword read FPos44 write FPos44;
    property RightLevel: Word read FRightLevel write FRightLevel;
  end;

  TSWFStartSound = class (TSWFObject)
  private
    FHasEnvelope: Boolean;
    FHasInPoint: Boolean;
    FHasLoops: Boolean;
    FHasOutPoint: Boolean;
    FInPoint: dword;
    FLoopCount: Word;
    FOutPoint: dword;
    FSoundClassName: string;
    FSoundEnvelopes: TObjectList;
    FSoundId: Word;
    FSyncNoMultiple: Boolean;
    FSyncStop: Boolean;
    procedure SetInPoint(const Value: dword);
    procedure SetLoopCount(Value: Word);
    procedure SetOutPoint(const Value: dword);
  protected
    property SoundClassName: string read FSoundClassName write FSoundClassName;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddEnvelope(pos: dword; left, right: word);
    procedure Assign(Source: TBasedSWFObject); override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteTagBody(be: TBitsEngine); override;
    property HasEnvelope: Boolean read FHasEnvelope write FHasEnvelope;
    property HasInPoint: Boolean read FHasInPoint write FHasInPoint;
    property HasLoops: Boolean read FHasLoops write FHasLoops;
    property HasOutPoint: Boolean read FHasOutPoint write FHasOutPoint;
    property InPoint: dword read FInPoint write SetInPoint;
    property LoopCount: Word read FLoopCount write SetLoopCount;
    property OutPoint: dword read FOutPoint write SetOutPoint;
    property SoundEnvelopes: TObjectList read FSoundEnvelopes;
    property SoundId: Word read FSoundId write FSoundId;
    property SyncNoMultiple: Boolean read FSyncNoMultiple write FSyncNoMultiple;
    property SyncStop: Boolean read FSyncStop write FSyncStop;
  end;

  TSWFStartSound2 = class(TSWFStartSound)
  public
    constructor Create;
    function MinVersion: Byte; override;
    property SoundClassName;
  end;

  TSWFSoundStreamHead = class (TSWFObject)
  private
    FLatencySeek: Integer;
    FPlaybackSoundRate: Byte;
    FPlaybackSoundSize: Boolean;
    FPlaybackSoundType: Boolean;
    FStreamSoundCompression: Byte;
    FStreamSoundRate: Byte;
    FStreamSoundSampleCount: Word;
    FStreamSoundSize: Boolean;
    FStreamSoundType: Boolean;
  public
    constructor Create; virtual;
    procedure Assign(Source: TBasedSWFObject); override;
    function MinVersion: Byte; override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteTagBody(be: TBitsEngine); override;
    property LatencySeek: Integer read FLatencySeek write FLatencySeek;
    property PlaybackSoundRate: Byte read FPlaybackSoundRate write FPlaybackSoundRate;
    property PlaybackSoundSize: Boolean read FPlaybackSoundSize write FPlaybackSoundSize;
    property PlaybackSoundType: Boolean read FPlaybackSoundType write FPlaybackSoundType;
    property StreamSoundCompression: Byte read FStreamSoundCompression write FStreamSoundCompression;
    property StreamSoundRate: Byte read FStreamSoundRate write FStreamSoundRate;
    property StreamSoundSampleCount: Word read FStreamSoundSampleCount write FStreamSoundSampleCount;
    property StreamSoundSize: Boolean read FStreamSoundSize write FStreamSoundSize;
    property StreamSoundType: Boolean read FStreamSoundType write FStreamSoundType;
  end;
  
  TSWFSoundStreamHead2 = class (TSWFSoundStreamHead)
  public
    constructor Create; override;
    function MinVersion: Byte; override;
  end;
  
  TSWFSoundStreamBlock = class (TSWFDataObject)
  private
    FSampleCount: Word;
    FSeekSamples: SmallInt;
    FStreamSoundCompression: Byte;
  public
    constructor Create; override;
    procedure Assign(Source: TBasedSWFObject); override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteTagBody(be: TBitsEngine); override;
    property SampleCount: Word read FSampleCount write FSampleCount;
    property SeekSamples: SmallInt read FSeekSamples write FSeekSamples;
    property StreamSoundCompression: Byte read FStreamSoundCompression write FStreamSoundCompression;
  end;
  

// ==========================================================//
//                       Buttons                             //
// ==========================================================//

  TSWFButtonRecord = class (TObject)
  private
    FBlendMode: TSWFBlendMode;
    FButtonHasBlendMode: Boolean;
    FButtonHasFilterList: Boolean;
    FButtonState: TSWFButtonStates;
    FCharacterID: Word;
    FColorTransform: TSWFColorTransform;
    FDepth: Word;
    FhasColorTransform: Boolean;
    FMatrix: TSWFMatrix;
    FFilterList: TSWFFilterList;
    function GetColorTransform: TSWFColorTransform;
    function GetMatrix: TSWFMatrix;
    function GetFilterList: TSWFFilterList;
  public
    constructor Create(ChID: word);
    destructor Destroy; override;
    procedure Assign(Source: TSWFButtonRecord);
    procedure WriteToStream(be: TBitsEngine);
    property BlendMode: TSWFBlendMode read FBlendMode write FBlendMode;
    property ButtonHasBlendMode: Boolean read FButtonHasBlendMode write
        FButtonHasBlendMode;
    property ButtonHasFilterList: Boolean read FButtonHasFilterList write
        FButtonHasFilterList;
    property ButtonState: TSWFButtonStates read FButtonState write FButtonState;
    property CharacterID: Word read FCharacterID write FCharacterID;
    property ColorTransform: TSWFColorTransform read GetColorTransform;
    property Depth: Word read FDepth write FDepth;
    property hasColorTransform: Boolean read FhasColorTransform write FhasColorTransform;
    property Matrix: TSWFMatrix read GetMatrix;
    property FilterList: TSWFFilterList read GetFilterList;
  end;

  TSWFBasedButton = class (TSWFObject)
  private
    FActions: TSWFActionList;
    FButtonId: Word;
    FButtonRecords: TObjectList;
    FParseActions: Boolean;
    function GetButtonRecord(index: integer): TSWFButtonRecord;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Assign(Source: TBasedSWFObject); override;
    function MinVersion: Byte; override;
    property Actions: TSWFActionList read FActions;
    property ButtonId: Word read FButtonId write FButtonId;
    property ButtonRecord[index: integer]: TSWFButtonRecord read GetButtonRecord;
    property ButtonRecords: TObjectList read FButtonRecords;
    property ParseActions: Boolean read FParseActions write FParseActions;
  end;

  TSWFDefineButton = class (TSWFBasedButton)
  private

    function GetAction(Index: Integer): TSWFAction;
  public
    procedure Assign(Source: TBasedSWFObject); override;
    function MinVersion: Byte; override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteTagBody(be: TBitsEngine); override;
    property Action[Index: Integer]: TSWFAction read GetAction;
  end;
  
  TSWFButtonCondAction = class (TSWFActionList)
  private
    FActionConditions: TSWFStateTransitions;
    FID_Key: Byte;
  public
    procedure Assign(Source: TSWFButtonCondAction);
    function Actions: TSWFActionList;
    procedure WriteToStream(be: TBitsEngine; isEnd:boolean);
    property ActionConditions: TSWFStateTransitions read FActionConditions write FActionConditions;
    property ID_Key: Byte read FID_Key write FID_Key;
  end;

  TSWFDefineButton2 = class (TSWFBasedButton)
  private
    FTrackAsMenu: Boolean;
    function GetCondAction(Index: Integer): TSWFButtonCondAction;
  public
    constructor Create; override;
    procedure Assign(Source: TBasedSWFObject); override;
    function MinVersion: Byte; override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteTagBody(be: TBitsEngine); override;
    property CondAction[Index: Integer]: TSWFButtonCondAction read GetCondAction;
    property TrackAsMenu: Boolean read FTrackAsMenu write FTrackAsMenu;
  end;
  
  TSWFDefineButtonSound = class (TSWFObject)
  private
    FButtonId: Word;
    FHasIdleToOverUp: Boolean;
    FHasOverDownToOverUp: Boolean;
    FHasOverUpToIdle: Boolean;
    FHasOverUpToOverDown: Boolean;
    FSndIdleToOverUp: TSWFStartSound;
    FSndOverDownToOverUp: TSWFStartSound;
    FSndOverUpToIdle: TSWFStartSound;
    FSndOverUpToOverDown: TSWFStartSound;
    function GetSndIdleToOverUp: TSWFStartSound;
    function GetSndOverDownToOverUp: TSWFStartSound;
    function GetSndOverUpToIdle: TSWFStartSound;
    function GetSndOverUpToOverDown: TSWFStartSound;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TBasedSWFObject); override;
    function MinVersion: Byte; override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteTagBody(be: TBitsEngine); override;
    property ButtonId: Word read FButtonId write FButtonId;
    property HasIdleToOverUp: Boolean read FHasIdleToOverUp write FHasIdleToOverUp;
    property HasOverDownToOverUp: Boolean read FHasOverDownToOverUp write FHasOverDownToOverUp;
    property HasOverUpToIdle: Boolean read FHasOverUpToIdle write FHasOverUpToIdle;
    property HasOverUpToOverDown: Boolean read FHasOverUpToOverDown write FHasOverUpToOverDown;
    property SndIdleToOverUp: TSWFStartSound read GetSndIdleToOverUp;
    property SndOverDownToOverUp: TSWFStartSound read GetSndOverDownToOverUp;
    property SndOverUpToIdle: TSWFStartSound read GetSndOverUpToIdle;
    property SndOverUpToOverDown: TSWFStartSound read GetSndOverUpToOverDown;
  end;
  
  TSWFDefineButtonCxform = class (TSWFObject)
  private
    FButtonColorTransform: TSWFColorTransform;
    FButtonId: Word;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TBasedSWFObject); override;
    function MinVersion: Byte; override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteTagBody(be: TBitsEngine); override;
    property ButtonColorTransform: TSWFColorTransform read FButtonColorTransform;
    property ButtonId: Word read FButtonId write FButtonId;
  end;
  

// ==========================================================//
//                       SPRITE                             //
// ==========================================================//

  TSWFDefineSprite = class (TSWFObject)
  private
    FControlTags: TObjectList;
    FFrameCount: Word;
    FParseActions: Boolean;
    FSpriteID: Word;
    FSWFVersion: Byte;
    function GetControlTag(Index: Integer): TSWFObject;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TBasedSWFObject); override;
    function MinVersion: Byte; override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteTagBody(be: TBitsEngine); override;
    property ControlTag[Index: Integer]: TSWFObject read GetControlTag;
    property ControlTags: TObjectList read FControlTags;
    property FrameCount: Word read FFrameCount write FFrameCount;
    property ParseActions: Boolean read FParseActions write FParseActions;
    property SpriteID: Word read FSpriteID write FSpriteID;
    property SWFVersion: Byte read FSWFVersion write FSWFVersion;
  end;


  TSWFDefineSceneAndFrameLabelData = class (TSWFObject)
  private
    FScenes: TStringList;
    FFrameLabels: TStringList;
  public
    constructor Create;
    destructor Destroy; override;
    function MinVersion: Byte; override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteTagBody(be: TBitsEngine); override;
    property FrameLabels: TStringList read FFrameLabels;
    property Scenes: TStringList read FScenes;
  end;

// ==========================================================//
//                       Video                               //
// ==========================================================//
  TSWFDefineVideoStream = class (TSWFObject)
  private
    FCharacterID: Word;
    FCodecID: Byte;
    FHeight: Word;
    FNumFrames: Word;
    FVideoFlagsDeblocking: Byte;
    FVideoFlagsSmoothing: Boolean;
    FWidth: Word;
  public
    constructor Create;
    procedure Assign(Source: TBasedSWFObject); override;
    function MinVersion: Byte; override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteTagBody(be: TBitsEngine); override;
    property CharacterID: Word read FCharacterID write FCharacterID;
    property CodecID: Byte read FCodecID write FCodecID;
    property Height: Word read FHeight write FHeight;
    property NumFrames: Word read FNumFrames write FNumFrames;
    property VideoFlagsDeblocking: Byte read FVideoFlagsDeblocking write FVideoFlagsDeblocking;
    property VideoFlagsSmoothing: Boolean read FVideoFlagsSmoothing write FVideoFlagsSmoothing;
    property Width: Word read FWidth write FWidth;
  end;
  
  TSWFVideoFrame = class (TSWFDataObject)
  private
    FFrameNum: Word;
    FStreamID: Word;
  public
    constructor Create; override;
    procedure Assign(Source: TBasedSWFObject); override;
    function MinVersion: Byte; override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteTagBody(be: TBitsEngine); override;
    property FrameNum: Word read FFrameNum write FFrameNum;
    property StreamID: Word read FStreamID write FStreamID;
  end;

// ================== undocumented tags ====================================

  TSWFByteCodeTag = class (TSWFDataObject)
  private
    FTagIDFrom: Word;
    FText: string;
    function GetByteCode(Index: word): Byte;
  public
    constructor Create;  override;
    procedure ReadFromStream(be: TBitsEngine); override;
    procedure WriteTagBody(be: TBitsEngine); override;
    procedure WriteToStream(be: TBitsEngine); override;
    property ByteCode[Index: word]: Byte read GetByteCode;
    property TagIDFrom: Word read FTagIDFrom write FTagIDFrom;
    property Text: string read FText write FText;
  end;

// ==================== tools  ==============================

Function GenerateSWFObject(ID: word): TSWFObject;
Function GenerateSWFAction(ID: word): TSWFAction;
procedure CopyActionList(Source, Dest: TSWFActionList);
Procedure WriteCustomData(Dest: TStream; TagID: byte; data: pointer; Size: longint); overload;
Procedure WriteCustomData(Dest: TStream; TagID: byte; data: TStream; Size: longint = 0); overload;
procedure CopyShapeRecords(Source, Dest: TObjectList);


 const
    noSupport = false;

implementation

Uses SWFMD5, Math, TypInfo;

 var tmpMemStream: TMemoryStream;
     nGlyphs: word;

{$IFDEF DebugAS3}
  SLDebug: TStringList;
  procedure AddDebugAS3(s: string);
  begin
    if SLDebug = nil then SLDebug := TStringList.Create;
    SLDebug.Add(s);
  end;
{$ENDIF}


{
********************************************************* TSWFRect **********************************************************
}
procedure TSWFRect.Assign(Source: TSWFRect);
begin
  Rec := Source.Rec;
end;

procedure TSWFRect.CompareXY(flag: byte);
var
  tmp: LongInt;
begin
  if ((flag and 1) = 1) and (FXmin > FXMax) then
    begin
      tmp := FXMax;
      FXMax := FXmin;
      FXmin := tmp;
    end;
  if ((flag and 2) = 2) and (FYmin > FYMax) then
    begin
      tmp := FYMax;
      FYMax := FYmin;
      FYmin := tmp;
    end;
end;

function TSWFRect.GetHeight: Integer;
begin
  result := YMax - YMin;
end;

function TSWFRect.GetRec: recRect;
begin
  Result.XMin := XMin;
  Result.YMin := YMin;
  Result.XMax := XMax;
  Result.YMax := YMax
end;

function TSWFRect.GetRect: TRect;
begin
  Result.Left := Xmin;
  Result.Top := YMin;
  Result.Right := XMax;
  Result.Bottom := YMax;
end;

function TSWFRect.GetWidth: Integer;
begin
  result := XMax - XMin;
end;

procedure TSWFRect.SetRec(Value: recRect);
begin
  FXMin := Value.XMin;
  FYMin := Value.YMin;
  FXMax := Value.XMax;
  FYMax := Value.YMax;
  CompareXY(3);
end;

procedure TSWFRect.SetRect(Value: TRect);
begin
  FXMin := Value.Left;
  FYMin := Value.Top;
  FXMax := Value.Right;
  FYMax := Value.Bottom;
  CompareXY(3);
end;

procedure TSWFRect.SetXmax(Value: LongInt);
begin
  FXmax := Value;
  CompareXY(1);
end;

procedure TSWFRect.SetXmin(Value: LongInt);
begin
  FXmin := Value;
  CompareXY(1);
end;

procedure TSWFRect.SetYmax(Value: LongInt);
begin
  FYmax := Value;
  CompareXY(2);
end;

procedure TSWFRect.SetYmin(Value: LongInt);
begin
  FYmin := Value;
  CompareXY(2);
end;

{
********************************************************** TSWFRGB **********************************************************
}
procedure TSWFRGB.Assign(Source: TObject);
begin
  RGB := TSWFRGB(Source).RGB;
end;

function TSWFRGB.GetRGB: recRGB;
begin
  Result := SWFRGB(R, G, B);
end;

procedure TSWFRGB.SetRGB(Value: recRGB);
begin
  R := value.R;
  G := value.G;
  B := value.B;
end;

{
********************************************************* TSWFRGBA **********************************************************
}
constructor TSWFRGBA.Create(a: boolean = false);
begin
  hasAlpha := a;
end;

procedure TSWFRGBA.Assign(Source: TObject);
begin
  if Source is TSWFRGBA then RGBA := TSWFRGBA(Source).RGBA
    else RGB := TSWFRGB(Source).RGB;
end;

function TSWFRGBA.GetRGBA: recRGBA;
begin
  Result := SWFRGBA(R, G, B, A);
end;

procedure TSWFRGBA.SetA(Value: Byte);
begin
  FA := Value;
  if Value < 255 then FHasAlpha := true;
end;

procedure TSWFRGBA.SetHasAlpha(Value: Boolean);
begin
  FhasAlpha := Value;
  if not Value then FA := 255;
end;

procedure TSWFRGBA.SetRGB(value: recRGB);
begin
  inherited SetRGB(Value);
  A := 255;
end;

procedure TSWFRGBA.SetRGBA(Value: recRGBA);
begin
  R := value.R;
  G := value.G;
  B := value.B;
  A := value.A;
end;

{
**************************************************** TSWFColorTransform *****************************************************
}
procedure TSWFColorTransform.Assign(Source: TSWFColorTransform);
begin
  Rec := Source.Rec;
end;

procedure TSWFColorTransform.AddTint(Color: TColor);
begin
  multR := 0;
  multG := 0;
  multB := 0;
  multA := 255;
  addR := GetRValue(Color);
  addG := GetGValue(Color);
  addB := GetBValue(Color);
  addA := 0;
end;

function TSWFColorTransform.CheckAddValue(value: integer): integer;
begin
 if value < -255 then Result := -255 else
  if value > 255 then Result := 255 else Result := value;
end;

function TSWFColorTransform.CheckMultValue(value: integer): integer;
begin
 if value < 0 then Result := 0 else
  if value > 256 then Result := 256 else Result := value;
end;

function TSWFColorTransform.GetREC: recColorTransform;
begin
  Result.hasAlpha := hasAlpha;
  if hasAdd then
    begin
      Result.hasADD := true;
      Result.addR := addR;
      Result.addG := addG;
      Result.addB := addB;
      if hasAlpha then Result.addA := addA;
    end else Result.hasAdd := false;
  if hasMULT then
    begin
      Result.hasMULT := true;
      Result.multR := multR;
      Result.multG := multG;
      Result.multB := multB;
      if hasAlpha then Result.multA := multA;
    end else Result.hasMULT := false;
end;

procedure TSWFColorTransform.SetAdd(R, G, B, A: integer);
begin
  addR := R;
  addG := G;
  addB := B;
  addA := A;
end;

procedure TSWFColorTransform.SetaddA(Value: Integer);
begin
  hasAdd := true;
  hasAlpha := true;
  FaddA := CheckAddValue(Value);
end;

procedure TSWFColorTransform.SetaddB(Value: Integer);
begin
  hasAdd := true;
  FaddB := CheckAddValue(Value);
end;

procedure TSWFColorTransform.SetaddG(Value: Integer);
begin
  hasAdd := true;
  FaddG := CheckAddValue(Value);
end;

procedure TSWFColorTransform.SetaddR(Value: Integer);
begin
  hasAdd := true;
  FaddR := CheckAddValue(Value);
end;

procedure TSWFColorTransform.SetMult(R, G, B, A: integer);
begin
  multR := R;
  multG := G;
  multB := B;
  multA := A;
end;

procedure TSWFColorTransform.SetmultA(Value: Integer);
begin
  hasMult := true;
  hasAlpha := true;
  FmultA := CheckMultValue(Value);
end;

procedure TSWFColorTransform.SetmultB(Value: Integer);
begin
  hasMult := true;
  FmultB := CheckMultValue(Value);
end;

procedure TSWFColorTransform.SetmultG(Value: Integer);
begin
  hasMult := true;
  FmultG := CheckMultValue(Value);
end;

procedure TSWFColorTransform.SetmultR(Value: Integer);
begin
  hasMult := true;
  FmultR := CheckMultValue(Value);
end;

procedure TSWFColorTransform.SetREC(Value: recColorTransform);
begin
  hasAlpha := Value.hasAlpha;
  if Value.hasAdd then
    begin
      addR := value.addR;
      addG := value.addG;
      addB := value.addB;
      if value.hasAlpha then addA := value.addA;
    end else hasAdd := false;
  if Value.hasMULT then
    begin
      multR := value.multR;
      multG := value.multG;
      multB := value.multB;
      if value.hasAlpha then multA := value.multA;
    end else hasMULT := false;
end;

{
******************************************************** TSWFMatrix *********************************************************
}
procedure TSWFMatrix.Assign(M : TSWFMatrix);
begin
  FHasScale := M.FHasScale;
  FHasSkew := M.FHasSkew;
  FScaleX := M.FScaleX;
  FScaleY := M.FScaleY;
  FSkewX := M.FSkewX;
  FSkewY := M.FSkewY;
  FTranslateX := M.FTranslateX;
  FTranslateY := M.FTranslateY;
end;

function TSWFMatrix.GetREC: recMatrix;
begin
  Result := MakeMatrix(hasScale, hasSkew,
                       FScaleX, FScaleY, FSkewX, FSkewY, TranslateX, TranslateY);
end;

function TSWFMatrix.GetScaleX: Single;
begin
  Result := IntToSingle(FScaleX);
end;

function TSWFMatrix.GetScaleY: Single;
begin
  Result := IntToSingle(FScaleY);
end;

function TSWFMatrix.GetSkewX: Single;
begin
  Result := IntToSingle(FSkewX);
end;

function TSWFMatrix.GetSkewY: Single;
begin
  Result := IntToSingle(FSkewY);
end;

procedure TSWFMatrix.SetREC(Value: recMatrix);
begin
  FScaleX := Value.ScaleX;
  FScaleY := Value.ScaleY;
  FSkewX := Value.SkewX;
  FSkewY := Value.SkewY;
  TranslateX := Value.TranslateX;
  TranslateY := Value.TranslateY;
  hasScale := Value.hasScale;
  hasSkew := Value.hasSkew;
end;

procedure TSWFMatrix.SetRotate(angle: single);
var
  R, oldSx, oldSy, oldSkX, oldSkY: Double;
begin
  if HasSkew then
    begin
      oldSkX := SkewX;
      oldSkY := SkewY;
    end else
    begin
      oldSkX := 0;
      oldSkY := 0;
    end;
  if HasScale then
    begin
      oldSx := ScaleX;
      oldSy := ScaleY;
    end else
    begin
      oldSx := 1;
      oldSy := 1;
    end;
  
   R := DegToRad(angle);
  
   ScaleX :=  oldSx * cos(r) + oldSky * sin(r);
   ScaleY :=  oldSy * cos(r) - oldSkx * sin(r);

   SkewX := oldSy * sin(r)  + oldSkX * cos(r);
   SkewY := - oldSx * sin(r) + oldSkY * cos(r);
end;

procedure TSWFMatrix.SetScale(ScaleX, ScaleY: single);
begin
  self.ScaleX := ScaleX;
  self.ScaleY := ScaleY;
end;

procedure TSWFMatrix.SetScaleX(Value: Single);
begin
  FScaleX := SingleToInt(value);
  HasScale := true;
end;

procedure TSWFMatrix.SetScaleY(Value: Single);
begin
  FScaleY := SingleToInt(value);
  HasScale := true;
end;

procedure TSWFMatrix.SetSkew(SkewX, SkewY: single);
begin
  self.SkewX := SkewX;
  self.SkewY := SkewY;
end;

procedure TSWFMatrix.SetSkewX(Value: Single);
begin
  FSkewX := SingleToInt(value);
  HasSkew := true;
end;

procedure TSWFMatrix.SetSkewY(Value: Single);
begin
  FSkewY := SingleToInt(value);
  HasSkew := true;
end;

procedure TSWFMatrix.SetTranslate(X, Y: LongInt);
begin
  TranslateX := X;
  TranslateY := Y;
end;
{
****************************************************** TXMLReadWriteSettings ******************************************************
}
{
****************************************************** TBasedSWFObject ******************************************************
}
function TBasedSWFObject.MinVersion: Byte;
begin
  Result := SWFVer1;
end;

{
******************************************************** TSWFObject *********************************************************
}
procedure TSWFObject.Assign(Source: TBasedSWFObject);
begin
  BodySize := TSWFObject(Source).BodySize;
end;

function TSWFObject.GetFullSize: LongInt;
begin
  Result := BodySize + 2 + Byte(BodySize >= $3f) * 4;
end;

function TSWFObject.LibraryLevel: Byte;
begin
  Result := SWFLevel;
end;

procedure TSWFObject.ReadFromStream(be: TBitsEngine);
begin
end;

procedure TSWFObject.WriteTagBody(be: TBitsEngine);
begin
  // no code for empty tags
end;

procedure TSWFObject.WriteToStream(be: TBitsEngine);
var
  tmpMem: tMemoryStream;
  tmpBE: TBitsEngine;
  tmpW: Word;
  isLong: Boolean;
begin
  if TagID in [tagEnd, tagShowFrame] {no body} then be.WriteWord(TagID shl 6)
   else
   begin
     tmpMem := TMemoryStream.Create;
     tmpBE := TBitsEngine.Create(tmpMem);
     WriteTagBody(tmpBE);
     BodySize := tmpMem.Size;
     isLong := (BodySize >= $3f) or
       (TagId in [tagDefineBitsLossless, tagDefineBitsLossless2,
                  tagDefineVideoStream, tagSoundStreamBlock]);
     if isLong
       then tmpW := TagID shl 6 + $3f
       else tmpW := TagID shl 6 + BodySize;
     be.BitsStream.Write(tmpW, 2);
     if isLong then be.WriteDWord(BodySize);

     if BodySize > 0 then
       begin
         tmpMem.Position := 0;
         be.BitsStream.CopyFrom(tmpMem, BodySize);
       end;
     tmpBE.Free;
     tmpMem.Free;
   end;  
end;

{
******************************************************* TSWFErrorTag ********************************************************
}
//constructor TSWFErrorTag.Create;
//begin
//  TagId := tagErrorTag;
//end;


procedure CopyShapeRecords(Source, Dest: TObjectList);
 var
  il: longint;
  ER: TSWFShapeRecord;
  SCR: TSWFStyleChangeRecord;
  LER: TSWFStraightEdgeRecord;
  CER: TSWFCurvedEdgeRecord;
begin
 if Source.Count = 0 then Dest.Clear else
  for il := 0 to Source.Count - 1 do
   begin
     ER := TSWFShapeRecord(Source[il]);
     Case ER.ShapeRecType of
       EndShapeRecord: Dest.Add(TSWFEndShapeRecord.Create);

       StyleChangeRecord:
         begin
           SCR := TSWFStyleChangeRecord.Create;
           SCR.Assign(ER);
           Dest.Add(SCR);
         end;

       StraightEdgeRecord:
         begin
           LER := TSWFStraightEdgeRecord.Create;
           LER.Assign(ER);
           Dest.Add(LER);
         end;

       CurvedEdgeRecord:
         begin
           CER := TSWFCurvedEdgeRecord.Create;
           CER.Assign(ER);
           Dest.Add(CER);
         end;
     end;
   end;
end;

Procedure ReadShapeRecord(be: TBitsEngine; Edges: TObjectList; nBitsFill, nBitsLine: byte; owner: TSWFDefineShape);
 var
  FlagRead, isVis, isLine, Flag1: boolean;
  SCR: TSWFStyleChangeRecord;
  LER: TSWFStraightEdgeRecord;
  CER: TSWFCurvedEdgeRecord;
  bCoord, b: byte;
  il, StyleCount: integer;
  LS: TSWFLineStyle;
  FS: TSWFFillStyle;
begin
  FlagRead := true;

  While FlagRead do
    begin
      isVis := Boolean(be.GetBits(1));
      if isVis then
        begin
          isLine := Boolean(be.GetBits(1));
          if isLine then
            begin
              LER := TSWFStraightEdgeRecord.Create;
              bCoord := be.GetBits(4) + 2;
              Flag1 := Boolean(be.GetBits(1));
              if Flag1 then
                begin
                  LER.X := be.GetSBits(bCoord);
                  LER.Y := be.GetSBits(bCoord);
                end else
                begin
                  Flag1 := Boolean(be.GetBits(1));
                  if Flag1 then LER.Y := be.GetSBits(bCoord)
                    else LER.X := be.GetSBits(bCoord);
                end;
              Edges.Add(LER);
            end else
            begin
              CER := TSWFCurvedEdgeRecord.Create;
              bCoord := be.GetBits(4) + 2;
              CER.ControlX := be.GetSBits(bCoord);
              CER.ControlY := be.GetSBits(bCoord);
              CER.AnchorX := be.GetSBits(bCoord);
              CER.AnchorY := be.GetSBits(bCoord);
              Edges.Add(CER);
            end;
        end else
        begin
          b := be.GetBits(5);
          if b = 0 then
            begin
             FlagRead := false;
             Edges.Add(TSWFEndShapeRecord.Create);
            end else
            begin
              SCR := TSWFStyleChangeRecord.Create;
              SCR.StateNewStyles := CheckBit(b, 5);
              SCR.stateLineStyle := CheckBit(b, 4);
              SCR.stateFillStyle1 := CheckBit(b, 3);
              SCR.stateFillStyle0 := CheckBit(b, 2);
              SCR.stateMoveTo := CheckBit(b, 1);

              if SCR.stateMoveTo then
                begin
                  bCoord := be.GetBits(5);
                  SCR.X := be.GetSBits(bcoord);
                  SCR.Y := be.GetSBits(bcoord);
                end;
              if SCR.stateFillStyle0 then
                 SCR.Fill0Id := be.GetBits(nBitsFill);

              if SCR.stateFillStyle1 then
                 SCR.Fill1Id := be.GetBits(nBitsFill);

              if SCR.stateLineStyle then
                 SCR.LineId := be.GetBits(nbitsLine);

              if SCR.StateNewStyles then
                begin
                  be.FlushLastByte(false);
                  b := be.ReadByte;
                  if b = $FF then StyleCount := be.ReadWord else StyleCount := b;
                  if StyleCount > 0 then
                   for il := 1 to StyleCount do
                    begin
                      b := be.ReadByte;
                      case b of
                        SWFFillSolid:
                           FS := TSWFColorFill.Create;
                        SWFFillLinearGradient, SWFFillRadialGradient:
                           FS := TSWFGradientFill.Create;
                        SWFFillFocalGradient:
                           FS := TSWFFocalGradientFill.Create;
                        SWFFillTileBitmap, SWFFillClipBitmap,
                        SWFFillNonSmoothTileBitmap, SWFFillNonSmoothClipBitmap:
                           FS := TSWFImageFill.Create;
                        else FS := nil;
                      end;
                      FS.SWFFillType := B;
                      if owner = nil
                        then FS.hasAlpha := true
                        else FS.hasAlpha := owner.hasAlpha;
                      FS.ReadFromStream(be);
                      SCR.NewFillStyles.Add(FS);
                    end;
                  b := be.ReadByte;
                  if b = $FF then StyleCount := be.ReadWord else StyleCount := b;
                  if StyleCount > 0 then
                   for il := 1 to StyleCount do
                    begin
                      if (owner <> nil) and (owner.TagID = tagDefineShape4)
                        then LS := TSWFLineStyle2.Create
                        else LS := TSWFLineStyle.Create;
                      if owner = nil
                        then LS.Color.hasAlpha := true
                        else LS.Color.hasAlpha := owner.hasAlpha;
                      LS.ReadFromStream(be);
                      SCR.NewLineStyles.Add(LS);
                    end;
                  be.FlushLastByte(false);  // need ??
                  b := be.ReadByte;
                  nBitsFill := b shr 4;
                  nBitsLine := b and $F;
                end;

              Edges.Add(SCR);
            end;
        end;
    end;
  be.FlushLastByte(false);
end;

Procedure ReadActionList(BE: TBitsEngine; AL: TSWFActionList; ActionsSize: longint);
var
  il: Word;
  AC: Byte;
  A: TSWFAction;
  StartPos: LongInt;
  Marker: TSWFOffsetMarker;
  nLabel: word;

  Procedure FindPosition(SizeOffset: longint);
   var ipos: word;
       SeekOffset: longint;
  begin
   ipos := il;
   SeekOffset := SizeOffset;
   Marker.ManualSet := false;
   if SeekOffset < 0 then inc(iPos);

   While SeekOffset <> 0 do
    begin
     if SeekOffset > 0 then
       begin
         inc(ipos);
         if TSWFAction(AL[ipos]).ActionCode < $FF then
           Dec(SeekOffset, TSWFAction(AL[ipos]).GetFullSize);
         if SeekOffset < 0 then
           begin
             Marker.MarkerName := 'Error Size offset: ' + IntToStr(SizeOffset);
             Marker.isUsing := false;
             Break;
           end;
       end else
       begin
         if (ipos = 0) and (SeekOffset < 0) then
           begin
             Marker.MarkerName := 'Error Size offset: ' + IntToStr(SizeOffset);
             Marker.isUsing := false;
             Break;
           end else
           begin
            Dec(iPos);
            if TSWFAction(AL[ipos]).ActionCode < $FF then
              Inc(SeekOffset, TSWFAction(AL[ipos]).GetFullSize);
            if SeekOffset > 0 then
              begin
                Marker.MarkerName := 'Error Size offset: ' + IntToStr(SizeOffset);
                Marker.isUsing := false;
                Break;
              end;
           end;
       end;

     if SeekOffset = 0 then
       begin
         if Marker.MarkerName = '' then
           begin
             inc(nLabel);
             Marker.MarkerName := 'label ' + IntToStr(nLabel);
           end;
         Marker.isUsing := true;
         if iPos > il then inc(ipos);
         if iPos = AL.Count then AL.Add(Marker) else
           AL.Insert(iPos, Marker);
         Break;
       end;
    end;
  end;


begin
  StartPos := be.BitsStream.Position;
  nLabel := 0;
  Repeat
    AC := be.ReadByte;
    if AC > 0 then
      begin
        A := GenerateSWFAction(AC);
        if A<>nil then
          begin
           if AC >= $80 then
             begin
               A.BodySize := be.ReadWord;
               A.ReadFromStream(be);
             end;

          end else
          begin
            A := TSWFActionByteCode.Create;
            with TSWFActionByteCode(A) do
             begin
               if AC >= $80 then
               begin
                 BodySize := be.ReadWord + 1;
                 SetSize(BodySize);
                 be.BitsStream.Seek(-3, 1{soCurrent});
                 ReadFromStream(be);
               end else
               begin
                 SetSize(1);
                 ByteCode[0]:=AC;
               end;
             end;

            A.ReadFromStream(be);
          end;
        AL.Add(A);
      end;
  Until (AC = 0) or (be.BitsStream.Position >= (StartPos + ActionsSize));

  il := 0;
  while il < AL.Count do
   if AL[il].ActionCode in [actionJump, actionIf, actionDefineFunction,
                            actionWith,  ActionDefineFunction2, actionTry] then
   begin
     Case AL[il].ActionCode of
      actionJump,
      actionIf: With TSWFactionJump(AL[il]) do
         begin
           BranchOffsetMarker.JumpToBack := BranchOffset < 0;
           Marker := BranchOffsetMarker;
           FindPosition(BranchOffset);
         end;

      actionDefineFunction: With TSWFactionDefineFunction(AL[il]) do
         begin
           CodeSizeMarker.JumpToBack := false;
           Marker := CodeSizeMarker;
           FindPosition(CodeSize);
         end;

      actionWith: with TSWFactionWith(AL[il]) do
         begin
           SizeMarker.JumpToBack := false;
           Marker := SizeMarker;
           FindPosition(Size);
         end;

      actionDefineFunction2: With TSWFactionDefineFunction2(AL[il]) do
         begin
           CodeSizeMarker.JumpToBack := false;
           Marker := CodeSizeMarker;
           FindPosition(CodeSize);
         end;

      actionTry: With TSWFactionTry(AL[il]) do
         begin
           inc(nLabel);

           TrySizeMarker.JumpToBack := false;
           Marker := TrySizeMarker;
           Marker.MarkerName := 'Try ' + IntToStr(nLabel);
           FindPosition(TrySize);

           if CatchBlockFlag then
             begin
               CatchSizeMarker.JumpToBack := false;
               Marker := CatchSizeMarker;
               Marker.MarkerName := 'Catch ' + IntToStr(nLabel);
               FindPosition(CatchSize + TrySize);
             end;

           if FinallyBlockFlag then
             begin
               FinallySizeMarker.JumpToBack := false;
               Marker := FinallySizeMarker;
               Marker.MarkerName := 'Finally ' + IntToStr(nLabel);
               FindPosition(FinallySize + TrySize + Byte(CatchBlockFlag) * CatchSize);
             end;

         end;
     end;
     if Marker.JumpToBack then inc(il, 2) else inc(il);
   end else inc(il);

(*  deleting empty jump
  il := 0;
  while il < AL.Count do
   if AL[il].ActionCode = actionJump then
    begin
     if TSWFactionJump(AL[il]).BranchOffset = 0 then AL.Delete(il) else inc(il);
    end else inc(il); *)
end;

procedure CopyActionList(Source, Dest: TSWFActionList);
 var ASrc, ADest: TSWFAction;
     il, ind: word;
begin
 if Source.Count > 0 then
   begin
     for il := 0 to Source.Count - 1 do
      begin
        ASrc := Source[il];
        ADest := GenerateSWFAction(ASrc.ActionCode);
        Dest.Add(ADest);
        ADest.Assign(ASrc);
      end;

     for il := 0 to Source.Count - 1 do
      begin
        ASrc := Source[il];
        case ASrc.ActionCode of
          actionJump,
          actionIf: With TSWFactionJump(ASrc) do
           if not StaticOffset then
            begin
              ind := Source.Indexof(BranchOffsetMarker);
              ADest := TSWFAction(Dest[ind]);
              TSWFactionJump(Dest[il]).BranchOffsetMarker := TSWFOffsetMarker(ADest);
            end;

          actionDefineFunction: With TSWFactionDefineFunction(ASrc) do
           if not StaticOffset then
            begin
              ind := Source.Indexof(CodeSizeMarker);
              ADest := TSWFAction(Dest[ind]);
              TSWFactionDefineFunction(Dest[il]).CodeSizeMarker := TSWFOffsetMarker(ADest);
            end;

          actionWith: with TSWFactionWith(ASrc) do
           if not StaticOffset then
            begin
              ind := Source.Indexof(SizeMarker);
              ADest := TSWFAction(Dest[ind]);
              TSWFactionWith(Dest[il]).SizeMarker := TSWFOffsetMarker(ADest);
            end;

          actionDefineFunction2: With TSWFactionDefineFunction2(ASrc) do
           if not StaticOffset then
            begin
              ind := Source.Indexof(CodeSizeMarker);
              ADest := TSWFAction(Dest[ind]);
              TSWFactionDefineFunction2(Dest[il]).CodeSizeMarker := TSWFOffsetMarker(ADest);
            end;

          actionTry: With TSWFactionTry(ASrc) do
           if not StaticOffset then
             begin
              ind := Source.Indexof(TrySizeMarker);
              ADest := TSWFAction(Dest[ind]);
              TSWFactionTry(Dest[il]).TrySizeMarker := TSWFTryOffsetMarker(ADest);

              if CatchBlockFlag then
                begin
                 ind := Source.Indexof(CatchSizeMarker);
                 ADest := TSWFAction(Dest[ind]);
                 TSWFactionTry(Dest[il]).CatchSizeMarker := TSWFTryOffsetMarker(ADest);
                end;

              if FinallyBlockFlag then
                begin
                 ind := Source.Indexof(FinallySizeMarker);
                 ADest := TSWFAction(Dest[ind]);
                 TSWFactionTry(Dest[il]).FinallySizeMarker := TSWFTryOffsetMarker(ADest);
                end;
             end;
        end;
      end;
   end;
end;

function FindEndActions(be: TBitsEngine): longint;
 var SPos: longint;
     AC: Byte;
     ASz: word;
begin
  SPos := be.BitsStream.Position;
  Result := SPos;
  Repeat
    AC := be.ReadByte;
    if AC > 0 then
      begin
        if AC >= $80 then
          begin
            ASz := be.ReadWord;
            be.BitsStream.Seek(ASz, soFromCurrent);
          end;
      end else Result := be.BitsStream.Position;
  Until (AC = 0) or (be.BitsStream.Position = be.BitsStream.Size);

  be.BitsStream.Position := SPos;
end;

Procedure FreeOffsetMarker(var Marker: TSWFOffsetMarker);
begin
 try
  if Assigned(Marker) and not Marker.isUsing then FreeAndNil(Marker);
 except
 end;
end;

Procedure WriteCustomData(Dest: TStream; TagId: byte; data: pointer; Size: longint);
   var tmpW: word;
       isLong: boolean;
begin
 isLong := (Size >= $3f) or (TagId in [tagDefineBitsLossless, tagDefineBitsLossless2, tagDefineVideoStream]);
 if isLong
   then tmpW := TagID shl 6 + $3f
   else tmpW := TagID shl 6 + Size;
 Dest.Write(tmpW, 2);
 if isLong then Dest.Write(Size, 4);
 Dest.Write(data^, Size);
end;

Procedure WriteCustomData(Dest: TStream; TagID: byte; data: TStream; Size: longint = 0);
   var tmpW: word;
       fSize: longint;
       isLong: boolean;
begin
  if Size = 0 then fSize := data.Size else fSize := Size;
  isLong := (fSize >= $3f) or (TagId in [tagDefineBitsLossless, tagDefineBitsLossless2, tagDefineVideoStream]);
  if isLong
   then tmpW := TagID shl 6 + $3f
   else tmpW := TagID shl 6 + fSize;
 Dest.Write(tmpW, 2);
 if isLong then Dest.Write(fSize, 4);
 Dest.CopyFrom(data, fSize);
end;

// ===========================================================
//                Control Tags
// ===========================================================

{
************************************************** TSWFSetBackgroundColor ***************************************************
}
constructor TSWFSetBackgroundColor.Create;
begin
  inherited;
  TagID := tagSetBackgroundColor;
  FColor := TSWFRGB.Create;
end;

destructor TSWFSetBackgroundColor.Destroy;
begin
  FColor.Free;
  inherited;
end;

procedure TSWFSetBackgroundColor.Assign(Source: TBasedSWFObject);
begin
  inherited;
  Color.Assign(TSWFSetBackgroundColor(Source).Color);
end;

procedure TSWFSetBackgroundColor.ReadFromStream(be: TBitsEngine);
begin
  Color.RGB := be.ReadRGB;
end;

procedure TSWFSetBackgroundColor.WriteTagBody(be: TBitsEngine);
begin
  be.WriteColor(Color.RGB);
end;

{
****************************************************** TSWFFrameLabel *******************************************************
}
constructor TSWFFrameLabel.Create;
begin
  inherited;
  TagID := tagFrameLabel;
end;

constructor TSWFFrameLabel.Create(fl: string);
begin
  inherited Create;
  TagID := tagFrameLabel;
  Name := fl;
end;

procedure TSWFFrameLabel.Assign(Source: TBasedSWFObject);
begin
  inherited;
  With TSWFFrameLabel(Source) do
  begin
    self.Name := Name;
    self.isAnchor := isAnchor;
  end;
end;

function TSWFFrameLabel.MinVersion: Byte;
begin
  if isAnchor then Result := SWFVer6 else Result := SWFVer3;
end;

procedure TSWFFrameLabel.ReadFromStream(be: TBitsEngine);
var
  PP: LongInt;
begin
  PP := BE.BitsStream.Position;
  Name := BE.ReadString;
  if (BodySize - (BE.BitsStream.Position - PP)) = 1 then isAnchor := Boolean( be.ReadByte );
end;

procedure TSWFFrameLabel.WriteTagBody(be: TBitsEngine);
begin
  be.WriteString(name);
  if isAnchor then be.WriteByte(1);
end;


{
******************************************************** TSWFProtect ********************************************************
}
constructor TSWFProtect.Create;
begin
  TagID := tagProtect;
end;

procedure TSWFProtect.Assign(Source: TBasedSWFObject);
begin
  inherited;
  With TSWFProtect(Source) do
  begin
    self.Password := Password;
    self.Hash := Hash;
  end;
end;

function TSWFProtect.MinVersion: Byte;
begin
  if (Hash<>'') or (Password<>'') then Result := SWFVer5 else Result := SWFVer2;
end;

procedure TSWFProtect.ReadFromStream(be: TBitsEngine);
begin
  if BodySize > 0 then
    begin
      be.ReadWord;
      Hash := be.ReadString(BodySize - 2);
    end;
end;

procedure TSWFProtect.WriteTagBody(be: TBitsEngine);
begin
  if (Password <> '') or (Hash <> '') then be.WriteWord(0);
  if Password <> '' then
      Hash := Cript_MD5(Password, '');
  if Hash <> '' then be.WriteString(Hash);
end;

{
********************************************************** TSWFEnd **********************************************************
}
constructor TSWFEnd.Create;
begin
  TagID := tagEnd;
end;

{
***************************************************** TSWFExportAssets ******************************************************
}
constructor TSWFExportAssets.Create;
begin
  TagID :=  tagExportAssets;
  FAssets := TStringList.Create;
end;

destructor TSWFExportAssets.Destroy;
begin
  FAssets.Free;
  inherited;
end;

procedure TSWFExportAssets.Assign(Source: TBasedSWFObject);
begin
  inherited;
  Assets.AddStrings(TSWFExportAssets(Source).Assets);
end;

function TSWFExportAssets.GetCharacterId(name: string): Integer;
var
  Ind: Integer;
begin
  ind := Assets.IndexOf(name);
  if ind = -1 then Result := -1
    else Result := Longint(Assets.Objects[ind]);
end;

function TSWFExportAssets.MinVersion: Byte;
begin
  Result := SWFVer5;
end;

procedure TSWFExportAssets.ReadFromStream(be: TBitsEngine);
var
  il, C, Tag: Word;
  name: string;
begin
  C := be.ReadWord;
  if C > 0 then
   For il:= 0 to C - 1 do
     begin
       Tag  := be.ReadWord;
       name := be.ReadString;
       Assets.AddObject(Name, Pointer(LongInt(Tag)));
     end;
end;

procedure TSWFExportAssets.SetAsset(Name: string; CharacterId: word);
begin
  self.CharacterId[Name] := CharacterId;
end;

procedure TSWFExportAssets.SetCharacterId(name: string; Value: Integer);
var
  Ind: Integer;
begin
  ind := Assets.IndexOf(name);
  if ind = -1 then  ind := Assets.Add(name);
  Assets.Objects[ind] := Pointer(LongInt(Value));
end;

procedure TSWFExportAssets.WriteTagBody(be: TBitsEngine);
var
  il: Word;
begin
  be.WriteWord(Assets.Count);
  if Assets.Count > 0 then
   For il:=0 to Assets.Count-1 do
    begin
      be.WriteWord(LongInt(Assets.Objects[il]));
      be.WriteString(Assets[il]);
    end;
end;


{
***************************************************** TSWFImportAssets ******************************************************
}
constructor TSWFImportAssets.Create;
begin
  inherited;
  TagID :=  tagImportAssets;
end;

procedure TSWFImportAssets.Assign(Source: TBasedSWFObject);
begin
  inherited;
  URL := TSWFImportAssets(Source).URL;
end;

procedure TSWFImportAssets.ReadFromStream(be: TBitsEngine);
begin
  FURL := be.ReadString;
  inherited;
end;

procedure TSWFImportAssets.WriteTagBody(be: TBitsEngine);
begin
  be.WriteString(FURL);
  inherited;
end;


{
***************************************************** TSWFImportAssets2 ******************************************************
}
constructor TSWFImportAssets2.Create;
begin
  inherited;
  TagID :=  tagImportAssets2;
end;

procedure TSWFImportAssets2.ReadFromStream(be: TBitsEngine);
begin
  FURL := be.ReadString;
  be.ReadWord;
  inherited;
end;

procedure TSWFImportAssets2.WriteTagBody(be: TBitsEngine);
begin
  be.WriteString(FURL);
  be.WriteByte(1);
  be.WriteByte(0);
  inherited;
end;

{
**************************************************** TSWFEnableDebugger *****************************************************
}
constructor TSWFEnableDebugger.Create;
begin
  inherited;
  TagID :=  tagEnableDebugger;
end;

function TSWFEnableDebugger.MinVersion: Byte;
begin
  Result := SWFVer5;
end;

{
**************************************************** TSWFEnableDebugger2 ****************************************************
}
constructor TSWFEnableDebugger2.Create;
begin
  inherited;
  TagID :=  tagEnableDebugger2;
end;

function TSWFEnableDebugger2.MinVersion: Byte;
begin
  Result := SWFVer6;
end;

{
***************************************************** TSWFScriptLimits ******************************************************
}
constructor TSWFScriptLimits.Create;
begin
  TagID := tagScriptLimits;
end;

procedure TSWFScriptLimits.Assign(Source: TBasedSWFObject);
begin
  inherited;
  With TSWFScriptLimits(Source) do
  begin
    self.MaxRecursionDepth := MaxRecursionDepth;
    self.ScriptTimeoutSeconds := ScriptTimeoutSeconds;
  end;
end;

function TSWFScriptLimits.MinVersion: Byte;
begin
  result := SWFVer7;
end;

procedure TSWFScriptLimits.ReadFromStream(be: TBitsEngine);
begin
  MaxRecursionDepth := be.ReadWord;
  ScriptTimeoutSeconds := be.ReadWord;
end;

procedure TSWFScriptLimits.WriteTagBody(be: TBitsEngine);
begin
  be.WriteWord(MaxRecursionDepth);
  be.WriteWord(ScriptTimeoutSeconds);
end;


{
****************************************************** TSWFSetTabIndex ******************************************************
}
constructor TSWFSetTabIndex.Create;
begin
  TagID := tagSetTabIndex;
end;

procedure TSWFSetTabIndex.Assign(Source: TBasedSWFObject);
begin
  inherited;
  with TSWFSetTabIndex(Source) do
  begin
    self.Depth := Depth;
    self.TabIndex := TabIndex
  end;
end;

function TSWFSetTabIndex.MinVersion: Byte;
begin
  result := SWFVer7;
end;

procedure TSWFSetTabIndex.ReadFromStream(be: TBitsEngine);
begin
  Depth := be.ReadWord;
  TabIndex := be.ReadWord;
end;

procedure TSWFSetTabIndex.WriteTagBody(be: TBitsEngine);
begin
  be.WriteWord(Depth);
  be.WriteWord(TabIndex);
end;


{
****************************************************** TSWFSymbolClass ****************************************************
}

constructor TSWFSymbolClass.Create;
begin
  inherited;
  TagID := tagSymbolClass;
end;

function TSWFSymbolClass.MinVersion: Byte;
begin
  Result := SWFVer9;
end;


{
****************************************************** TSWFFileAttributes ****************************************************
}
procedure TSWFFileAttributes.Assign(Source: TBasedSWFObject);
begin
  inherited;
  HasMetadata := TSWFFileAttributes(Source).HasMetadata;
  UseNetwork := TSWFFileAttributes(Source).UseNetwork;
end;

constructor TSWFFileAttributes.Create;
begin
  TagID := tagFileAttributes;
end;

function TSWFFileAttributes.MinVersion: Byte;
begin
  Result := SWFVer8;
end;

procedure TSWFFileAttributes.ReadFromStream(be: TBitsEngine);
 var
  b: Byte;
begin
  b := be.ReadByte;
  HasMetadata := CheckBit(b, 4);
  ActionScript3 := CheckBit(b, 3);
  UseNetwork  := CheckBit(b, 1);
  be.ReadWord;
  be.ReadByte;
end;

procedure TSWFFileAttributes.WriteTagBody(be: TBitsEngine);
 var
   b: Byte;
begin
  b := byte(HasMetadata) shl 3 + byte(ActionScript3) shl 2 + byte(UseNetwork);
  be.WriteByte(b);
  be.WriteWord(0);
  be.WriteByte(0);
end;


{
****************************************************** TSWFMetadata ****************************************************
}
procedure TSWFMetadata.Assign(Source: TBasedSWFObject);
begin
  inherited;
  Metadata := TSWFMetadata(Source).Metadata;
end;

constructor TSWFMetadata.Create;
begin
  TagID := tagMetadata;
end;

function TSWFMetadata.MinVersion: Byte;
begin
  Result := SWFVer8;
end;

procedure TSWFMetadata.ReadFromStream(be: TBitsEngine);
begin
  Metadata := be.ReadString;
end;

procedure TSWFMetadata.WriteTagBody(be: TBitsEngine);
begin
  be.WriteString(Metadata, true, true);
end;


{ TSWFProductInfo }

procedure TSWFProductInfo.Assign(Source: TBasedSWFObject);
begin
  inherited;
  with TSWFProductInfo(Source) do
  begin
    self.FMajorBuild := MajorBuild;
    self.MinorBuild := MinorBuild;
    self.FCompilationDate := CompilationDate;
    self.FEdition := Edition;
    self.FMinorVersion := MinorVersion;
    self.FMajorVersion := MajorVersion;
    self.FProductId := ProductId;
  end;
end;

constructor TSWFProductInfo.Create;
begin
  TagID := tagProductInfo;
end;

function TSWFProductInfo.MinVersion: Byte;
begin
  Result := SWFVer9;
end;

procedure TSWFProductInfo.ReadFromStream(be: TBitsEngine);
begin
  ProductId := be.ReadDWord;
  Edition := be.ReadDWord;
  MajorVersion := be.ReadByte;
  MinorVersion := be.ReadByte;
  MajorBuild := be.ReadDWord;
  MinorBuild := be.ReadDWord;
  CompilationDate := be.ReadSTDDouble;
end;

procedure TSWFProductInfo.WriteTagBody(be: TBitsEngine);
begin
  be.WriteDWord(ProductId);
  be.WriteDWord(Edition);
  be.WriteByte(MajorVersion);
  be.WriteByte(MinorVersion);
  be.WriteDWord(MajorBuild);
  be.WriteDWord(MinorBuild);
  be.WriteStdDouble(CompilationDate);
end;


{
**************************************************** TSWFDefineScalingGrid **************************************************
}
procedure TSWFDefineScalingGrid.Assign(Source: TBasedSWFObject);
begin
  inherited;
  With TSWFDefineScalingGrid(Source) do
   begin
     self.Splitter.Assign(Splitter);
     self.CharacterId := CharacterId;
   end;
end;

constructor TSWFDefineScalingGrid.Create;
begin
  TagID := tagDefineScalingGrid;
  FSplitter := TSWFRect.Create;
end;

destructor TSWFDefineScalingGrid.Destroy;
begin
 FSplitter.Free;
 inherited;
end;

function TSWFDefineScalingGrid.MinVersion: Byte;
begin
  Result := SWFVer8;
end;

procedure TSWFDefineScalingGrid.ReadFromStream(be: TBitsEngine);
begin
  CharacterId := be.ReadWord;
  Splitter.Rect := be.ReadRect;
end;

procedure TSWFDefineScalingGrid.WriteTagBody(be: TBitsEngine);
begin
  be.WriteWord(CharacterId);
  be.WriteRect(Splitter.Rect);
end;


// ===========================================================
//                          Actions
// ===========================================================

// --------------------------- SWF 3 -------------------------
{
******************************************************** TSWFAction *********************************************************
}
procedure TSWFAction.Assign(Source: TSWFAction);
begin
  BodySize := Source.BodySize;
end;

function TSWFAction.GetFullSize: Word;
begin
  Result := 1;
  if (ActionCode >= $80) then Result := Result + 2 + BodySize;
end;

function TSWFAction.MinVersion: Byte;
begin
  Result := SWFVer3;
end;

procedure TSWFAction.ReadFromStream(be: TBitsEngine);
begin
  // for non-realized or empty actions
  if BodySize > 0 then be.BitsStream.Seek(soFromCurrent, BodySize);
end;

procedure TSWFAction.WriteActionBody(be: TBitsEngine);
begin
end;

procedure TSWFAction.WriteToStream(be: TBitsEngine);
var
  tmpMem: tMemoryStream;
  tmpBE: TBitsEngine;
begin
  if ActionCode in [actionOffsetWork, actionByteCode] then
      WriteActionBody(BE)
   else
   begin
       be.WriteByte(ActionCode);
    if ActionCode >= $80 then
      begin
        tmpMem := TMemoryStream.Create;
        tmpBE := TBitsEngine.Create(tmpMem);
        WriteActionBody(tmpBE);
        BodySize := tmpMem.Size;

        if BodySize > 0 then
          begin
            be.WriteWord(BodySize);
            tmpMem.Position := 0;
            be.BitsStream.CopyFrom(tmpMem, BodySize);
          end;

        tmpBE.Free;
        tmpMem.Free;
      end;
   end;
end;

{
**************************************************** TSWFActionGotoFrame ****************************************************
}
constructor TSWFActionGotoFrame.Create;
begin
  ActionCode := actionGotoFrame;
end;

procedure TSWFActionGotoFrame.Assign(Source: TSWFAction);
begin
  inherited;
  Frame := TSWFActionGotoFrame(Source).Frame;
end;

procedure TSWFActionGotoFrame.ReadFromStream(be: TBitsEngine);
begin
  Frame := be.ReadWord;
end;

procedure TSWFActionGotoFrame.WriteActionBody(be: TBitsEngine);
begin
  be.WriteWord(Frame);
end;


{
***************************************************** TSWFActionGetUrl ******************************************************
}
constructor TSWFActionGetUrl.Create;
begin
  ActionCode := actionGetUrl;
end;

procedure TSWFActionGetUrl.Assign(Source: TSWFAction);
begin
  inherited;
  With TSWFActionGetUrl(Source) do
  begin
    self.URL := URL;
    self.Target := Target;
  end;
end;

procedure TSWFActionGetUrl.ReadFromStream(be: TBitsEngine);
begin
  URL := BE.ReadString;
  Target := BE.ReadString;
end;

procedure TSWFActionGetUrl.WriteActionBody(be: TBitsEngine);
begin
  BE.WriteString(URL, true, true);
  BE.WriteString(Target);
end;

{
**************************************************** TSWFActionNextFrame ****************************************************
}
constructor TSWFActionNextFrame.Create;
begin
  ActionCode := actionNextFrame;
end;

{
************************************************** TSWFActionPreviousFrame **************************************************
}
constructor TSWFActionPreviousFrame.Create;
begin
  ActionCode := actionPreviousFrame;
end;

{
****************************************************** TSWFActionPlay *******************************************************
}
constructor TSWFActionPlay.Create;
begin
  ActionCode := actionPlay;
end;

{
****************************************************** TSWFActionStop *******************************************************
}
constructor TSWFActionStop.Create;
begin
  ActionCode := actionStop;
end;

{
************************************************** TSWFActionToggleQuality **************************************************
}
constructor TSWFActionToggleQuality.Create;
begin
  ActionCode := actionToggleQuality;
end;

{
*************************************************** TSWFActionStopSounds ****************************************************
}
constructor TSWFActionStopSounds.Create;
begin
  ActionCode := actionStopSounds;
end;

{
************************************************** TSWFActionWaitForFrame ***************************************************
}
constructor TSWFActionWaitForFrame.Create;
begin
  ActionCode := actionWaitForFrame;
end;

procedure TSWFActionWaitForFrame.Assign(Source: TSWFAction);
begin
  inherited;
  With TSWFActionWaitForFrame(Source) do
  begin
    self.Frame := Frame;
    self.SkipCount := SkipCount;
  end;
end;

procedure TSWFActionWaitForFrame.ReadFromStream(be: TBitsEngine);
begin
  Frame := be.ReadWord;
  SkipCount := be.ReadByte;
end;

procedure TSWFActionWaitForFrame.WriteActionBody(be: TBitsEngine);
begin
  be.WriteWord(Frame);
  be.WriteByte(SkipCount);
end;

{
**************************************************** TSWFActionSetTarget ****************************************************
}
constructor TSWFActionSetTarget.Create;
begin
  ActionCode := actionSetTarget;
end;

procedure TSWFActionSetTarget.Assign(Source: TSWFAction);
begin
  inherited;
  TargetName := TSWFActionSetTarget(Source).TargetName;
end;

procedure TSWFActionSetTarget.ReadFromStream(be: TBitsEngine);
begin
  TargetName := be.ReadString;
end;

procedure TSWFActionSetTarget.WriteActionBody(be: TBitsEngine);
begin
  be.WriteString(TargetName);
end;


{
**************************************************** TSWFActionGoToLabel ****************************************************
}
constructor TSWFActionGoToLabel.Create;
begin
  ActionCode := actionGoToLabel;
end;

procedure TSWFActionGoToLabel.Assign(Source: TSWFAction);
begin
  inherited;
  FrameLabel := TSWFActionGoToLabel(Source).FrameLabel;
end;

procedure TSWFActionGoToLabel.ReadFromStream(be: TBitsEngine);
begin
  FrameLabel := be.ReadString;
end;

procedure TSWFActionGoToLabel.WriteActionBody(be: TBitsEngine);
begin
  be.WriteString(FrameLabel);
end;

// ------------ SWF 4 -----------

{
******************************************************** TSWFAction4 ********************************************************
}
function TSWFAction4.MinVersion: Byte;
begin
  result := SWFVer4;
end;

{
***************************************************** TSWFOffsetMarker ******************************************************
}
constructor TSWFOffsetMarker.Create;
begin
  ActionCode := actionOffsetWork;
  JumpToBack := true;
  SizeOffset := 2;
  ManualSet := true;
end;

procedure TSWFOffsetMarker.Assign(Source: TSWFAction);
begin
  inherited;
  With TSWFOffsetMarker(Source) do
  begin
    self.isUsing := isUsing;
    self.JumpToBack := JumpToBack;
    self.MarkerName := MarkerName;
    self.SizeOffset := SizeOffset;
    self.ManualSet := ManualSet;
  end;
end;

procedure TSWFOffsetMarker.WriteActionBody(be: TBitsEngine);
var
  TmpP: LongInt;
  LW: LongWord;
begin
  isUsing := true;
  if not ManualSet then Exit;
  if JumpToBack then
      StartPosition := be.BitsStream.Position
    else
    begin
     TmpP := be.BitsStream.Position;
     be.BitsStream.Position := StartPosition;
     LW := TmpP - StartPosition - sizeOffset;
     case SizeOffset of
       4: be.WriteDWord(LW);
       2: be.WriteWord(LW);
     end;
     be.BitsStream.Position := TmpP;
    end;
end;

procedure TSWFOffsetMarker.WriteOffset(be: TBitsEngine);
var
  LW: LongWord;
begin
  if not ManualSet then Exit;
  if JumpToBack then
    begin
      LW := RootStreamPosition - StartPosition + SizeOffset;
      case SizeOffset of
        4: be.WriteDWord(DWord(- LW));
        2: be.WriteWord(Word(-LW));
      end;
    end else
    begin
      StartPosition := RootStreamPosition;
      LW := 0;
      be.BitsStream.Write(LW, sizeOffset);
    end;
end;


//  -- Stack Operations --
{
****************************************************** TPushValueInfo *******************************************************
}
procedure TPushValueInfo.SetValue(v: Variant);
begin
  isValueInit := true;
  case VarType(v) of
    varString, varOleStr:
      begin
       if fvUndefined = v then ValueType := vtUndefined else
         if fvNull = v then ValueType := vtNull else
           ValueType := vtString;
      end;
    varNull: ValueType := vtNull;
    varEmpty: ValueType := vtUndefined;
    varDouble, varCurrency, varDate: ValueType := vtDouble;
    varSingle: ValueType := vtFloat;
    varBoolean: ValueType := vtBoolean;
    varSmallInt, varInteger, varByte
  {$IFDEF VARIANTS}
      , varShortInt, varWord, varLongWord, varInt64
  {$ENDIF}
      : ValueType := vtInteger;
   else isValueInit := false;
  end;
  
  if isValueInit then
   begin
     if ValueType in [vtNull, vtUndefined] then fValue := Copy(v, 10, 9)
       else fValue := v;
   end;
end;

procedure TPushValueInfo.SetValueType(v: TSWFValueType);
begin
  if not (v = vtDefault) then fValueType := V;
end;

{
****************************************************** TSWFActionPush *******************************************************
}
constructor TSWFActionPush.Create;
begin
  ActionCode := actionPush;
  FValues := TObjectList.Create;
end;

destructor TSWFActionPush.Destroy;
begin
  FValues.Free;
  inherited;
end;

function TSWFActionPush.AddValue(V: Variant): Integer;
var
  PV: TPushValueInfo;
begin
  PV := TPushValueInfo.Create;
  PV.Value := V;
  Result := FValues.Add(PV);
end;

procedure TSWFActionPush.Assign(Source: TSWFAction);
var
  il: Word;
begin
  inherited;
  With TSWFActionPush(Source) do
  if ValueCount > 0 then
   For il := 0 to ValueCount - 1 do
     self.ValueInfo[self.AddValue(Value[il])].ValueType := ValueInfo[il].ValueType;
end;

function TSWFActionPush.GetValue(index: integer): Variant;
begin
  Result := TPushValueInfo(FValues[index]).Value;
end;

function TSWFActionPush.GetValueInfo(index: integer): TPushValueInfo;
begin
  Result := TPushValueInfo(FValues[index]);
end;

function TSWFActionPush.MinVersion: Byte;
var
  il: Integer;
begin
  Result := SWFVer4;
  if ValueCount > 0 then
   for il := 0 to ValueCount - 1 do
     if ValueInfo[il].ValueType > vtFloat then
       begin
        Result := SWFVer5;
        Break;
       end;
end;

procedure TSWFActionPush.ReadFromStream(be: TBitsEngine);
var
  lw: LongWord;
  LI: LongInt;
  d: Double;
  s: Single;
  il, il2: Integer;
  AB: array [0..7] of byte absolute d;
  TmpType: TSWFValueType;
  TmpValue: Variant;
begin
  il:=0;
  (*  be.BitsStream.Read(AB, Size);
    if AB[0] > 0 then;
  *)
  While il < BodySize do
   begin
     TmpType := TSWFValueType(be.readByte);
     inc(il);
     Case TmpType of
      vtString:
        begin
         TmpValue:= be.readString;
         inc(il, length(TmpValue) + 1);
        end;
      vtFloat:
        begin
          LW := be.ReadDWord;
          Move(LW, S, 4);
          TmpValue := S;
          inc(il, 4);
        end;
      vtNull: TmpValue := fvNull;
      vtUndefined: TmpValue := fvUndefined;
      vtDouble:
        begin
          for il2 := 4 to 7 do ab[il2] := be.ReadByte;
          for il2 := 0 to 3 do ab[il2] := be.ReadByte;
          TmpValue := D;
          inc(il, 8);
        end;
      vtInteger:
        begin
          LI := longint(be.ReadDWord);
          TmpValue := LI;
          inc(il, 4);
        end;
      vtRegister, vtBoolean, vtConstant8:
        begin
          TmpValue := be.ReadByte;
          inc(il);
        end;
      vtConstant16:
        begin
          TmpValue := be.ReadWord;
          inc(il, 2);
        end;
     end;
     ValueInfo[AddValue(TmpValue)].ValueType := TmpType;
   end;

end;

procedure TSWFActionPush.SetValue(index: integer; v: Variant);
begin
  TPushValueInfo(FValues[index]).Value := V;
end;

function TSWFActionPush.ValueCount: Word;
begin
  Result := FValues.Count;
end;

procedure TSWFActionPush.WriteActionBody(be: TBitsEngine);
var
  LW: LongWord;
  D: Double;
  S: Single;
  il, il2: Word;
  AB: Array [0..7] of byte absolute D;
begin
if ValueCount > 0 then
 For il := 0 to ValueCount - 1 do
  With ValueInfo[il] do
   if isValueInit then
    begin
      be.WriteByte(byte(ValueType));
      case ValueType of
        vtString: be.WriteString(Value);
        vtFloat: begin
                   S := Value;
                   Move(S, LW, 4);
                   be.Write4Byte(LW);
                 end;
        vtDouble: begin
                    D := Value;
                    for il2 := 4 to 7 do be.WriteByte(ab[il2]);
                    for il2 := 0 to 3 do be.WriteByte(ab[il2]);
                  end;
        vtInteger: be.Write4byte(Value);
        vtRegister, vtBoolean, vtConstant8: be.WriteByte(Value);
        vtConstant16: be.WriteWord(Value);
      end;
    end;
end;

{
******************************************************* TSWFActionPop *******************************************************
}
constructor TSWFActionPop.Create;
begin
  ActionCode := actionPop;
end;

// -- Arithmetic Operators --

{
******************************************************* TSWFActionAdd *******************************************************
}
constructor TSWFActionAdd.Create;
begin
  ActionCode := actionAdd;
end;

{
**************************************************** TSWFActionSubtract *****************************************************
}
constructor TSWFActionSubtract.Create;
begin
  ActionCode := actionSubtract;
end;

{
**************************************************** TSWFActionMultiply *****************************************************
}
constructor TSWFActionMultiply.Create;
begin
  ActionCode := actionMultiply;
end;

{
***************************************************** TSWFActionDivide ******************************************************
}
constructor TSWFActionDivide.Create;
begin
  ActionCode := actionDivide;
end;

// --  Numerical Comparison --

{
***************************************************** TSWFActionEquals ******************************************************
}
constructor TSWFActionEquals.Create;
begin
  ActionCode := actionEquals;
end;

{
****************************************************** TSWFActionLess *******************************************************
}
constructor TSWFActionLess.Create;
begin
  ActionCode := actionLess;
end;

// -- Logical Operators --

{
******************************************************* TSWFActionAnd *******************************************************
}
constructor TSWFActionAnd.Create;
begin
  ActionCode := actionAnd;
end;

{
******************************************************* TSWFActionOr ********************************************************
}
constructor TSWFActionOr.Create;
begin
  ActionCode := actionOr;
end;

{
******************************************************* TSWFActionNot *******************************************************
}
constructor TSWFActionNot.Create;
begin
  ActionCode := actionNot;
end;

// -- String Manipulation --

{
************************************************** TSWFActionStringEquals ***************************************************
}
constructor TSWFActionStringEquals.Create;
begin
  ActionCode := actionStringEquals;
end;

{
************************************************** TSWFActionStringLength ***************************************************
}
constructor TSWFActionStringLength.Create;
begin
  ActionCode := actionStringLength;
end;

{
**************************************************** TSWFActionStringAdd ****************************************************
}
constructor TSWFActionStringAdd.Create;
begin
  ActionCode := actionStringAdd;
end;

{
************************************************** TSWFActionStringExtract **************************************************
}
constructor TSWFActionStringExtract.Create;
begin
  ActionCode := actionStringExtract;
end;

{
*************************************************** TSWFActionStringLess ****************************************************
}
constructor TSWFActionStringLess.Create;
begin
  ActionCode := actionStringLess;
end;

{
************************************************* TSWFActionMBStringLength **************************************************
}
constructor TSWFActionMBStringLength.Create;
begin
  ActionCode := actionMBStringLength;
end;

{
************************************************* TSWFActionMBStringExtract *************************************************
}
constructor TSWFActionMBStringExtract.Create;
begin
  ActionCode := actionMBStringExtract;
end;

// -- Type Conversion --

{
**************************************************** TSWFActionToInteger ****************************************************
}
constructor TSWFActionToInteger.Create;
begin
  ActionCode := actionToInteger;
end;

{
*************************************************** TSWFActionCharToAscii ***************************************************
}
constructor TSWFActionCharToAscii.Create;
begin
  ActionCode := actionCharToAscii;
end;

{
*************************************************** TSWFActionAsciiToChar ***************************************************
}
constructor TSWFActionAsciiToChar.Create;
begin
  ActionCode := actionAsciiToChar;
end;

{
************************************************** TSWFActionMBCharToAscii **************************************************
}
constructor TSWFActionMBCharToAscii.Create;
begin
  ActionCode := actionMBCharToAscii;
end;

{
************************************************** TSWFActionMBAsciiToChar **************************************************
}
constructor TSWFActionMBAsciiToChar.Create;
begin
  ActionCode := actionMBAsciiToChar;
end;

// -- Control Flow --

{
****************************************************** TSWFActionJump *******************************************************
}
constructor TSWFActionJump.Create;
begin
  ActionCode := actionJump;
end;

destructor TSWFActionJump.Destroy;
begin
  FreeOffsetMarker(FBranchOffsetMarker);
  inherited;
end;

procedure TSWFActionJump.Assign(Source: TSWFAction);
begin
  inherited;
  With TSWFActionJump(Source) do
  begin
   self.BranchOffset := BranchOffset;
   self.StaticOffset := StaticOffset;
  end;
end;

function TSWFActionJump.GetBranchOffsetMarker: TSWFOffsetMarker;
begin
  if FBranchOffsetMarker = nil then
    FBranchOffsetMarker := TSWFOffsetMarker.Create;
  Result := FBranchOffsetMarker;
end;

procedure TSWFActionJump.ReadFromStream(be: TBitsEngine);
begin
  BranchOffset := SmallInt(be.ReadWord);
end;

procedure TSWFActionJump.SetBranchOffset(v: SmallInt);
begin
  fBranchOffset := V;
  StaticOffset := true;
end;

procedure TSWFActionJump.WriteActionBody(be: TBitsEngine);
begin
  if StaticOffset or (FBranchOffsetMarker = nil) then be.WriteWord(BranchOffset) else
    if FBranchOffsetMarker <> nil then
      begin
       FBranchOffsetMarker.RootStreamPosition := StartPosition + 3; // Size(2) + Code(1)
       FBranchOffsetMarker.WriteOffset(be);
      end;
end;

procedure TSWFActionJump.WriteToStream(be: TBitsEngine);
begin
  StartPosition := be.BitsStream.Position;
  inherited;
end;

{
******************************************************* TSWFActionIf ********************************************************
}
constructor TSWFActionIf.Create;
begin
  ActionCode := actionIf;
end;

{
****************************************************** TSWFActionCall *******************************************************
}
constructor TSWFActionCall.Create;
begin
  ActionCode := actionCall;
end;

// -- Variables --

{
*************************************************** TSWFActionGetVariable ***************************************************
}
constructor TSWFActionGetVariable.Create;
begin
  ActionCode := actionGetVariable;
end;

{
*************************************************** TSWFActionSetVariable ***************************************************
}
constructor TSWFActionSetVariable.Create;
begin
  ActionCode := actionSetVariable;
end;

// -- Movie Control --

{
***************************************************** TSWFActionGetURL2 *****************************************************
}
constructor TSWFActionGetURL2.Create;
begin
  ActionCode := actionGetURL2;
end;

procedure TSWFActionGetURL2.Assign(Source: TSWFAction);
begin
  inherited;
  With TSWFActionGetURL2(Source) do
  begin
   self.LoadTargetFlag := LoadTargetFlag;
   self.LoadVariablesFlag := LoadVariablesFlag;
   self.SendVarsMethod := SendVarsMethod;
  end;
end;

procedure TSWFActionGetURL2.ReadFromStream(be: TBitsEngine);
var
  b: Byte;
begin
  b := be.ReadByte;
  SendVarsMethod := b and 3;
  LoadTargetFlag := CheckBit(b, 7);
  LoadVariablesFlag:= CheckBit(b, 8);
end;

procedure TSWFActionGetURL2.WriteActionBody(be: TBitsEngine);
begin
  be.WriteBit(LoadVariablesFlag);
  be.WriteBit(LoadTargetFlag);
  be.WriteBits(0, 4);
  be.WriteBits(SendVarsMethod, 2);
end;

{
*************************************************** TSWFActionGotoFrame2 ****************************************************
}
constructor TSWFActionGotoFrame2.Create;
begin
  ActionCode := actionGotoFrame2;
end;

procedure TSWFActionGotoFrame2.Assign(Source: TSWFAction);
begin
  inherited;
  With TSWFActionGotoFrame2(Source) do
  begin
   self.PlayFlag := PlayFlag;
   self.SceneBiasFlag := SceneBiasFlag;
   if SceneBiasFlag then
     self.SceneBias := SceneBias;
  end;
end;

procedure TSWFActionGotoFrame2.ReadFromStream(be: TBitsEngine);
var
  b: Byte;
begin
  b := be.ReadByte;
  SceneBiasFlag := CheckBit(b, 2);
  PlayFlag := CheckBit(b, 1);
  if SceneBiasFlag then SceneBias := be.ReadWord;
end;

procedure TSWFActionGotoFrame2.WriteActionBody(be: TBitsEngine);
begin
  be.WriteBits(0, 6);
  be.WriteBit(SceneBiasFlag);
  be.WriteBit(PlayFlag);
  if SceneBiasFlag then be.WriteWord(SceneBias);
end;

{
*************************************************** TSWFActionSetTarget2 ****************************************************
}
constructor TSWFActionSetTarget2.Create;
begin
  ActionCode := actionSetTarget2;
end;

{
*************************************************** TSWFActionGetProperty ***************************************************
}
constructor TSWFActionGetProperty.Create;
begin
  ActionCode := actionGetProperty;
end;

{
*************************************************** TSWFActionSetProperty ***************************************************
}
constructor TSWFActionSetProperty.Create;
begin
  ActionCode := actionSetProperty;
end;

{
*************************************************** TSWFActionCloneSprite ***************************************************
}
constructor TSWFActionCloneSprite.Create;
begin
  ActionCode := actionCloneSprite;
end;

{
************************************************** TSWFActionRemoveSprite ***************************************************
}
constructor TSWFActionRemoveSprite.Create;
begin
  ActionCode := actionRemoveSprite;
end;

{
**************************************************** TSWFActionStartDrag ****************************************************
}
constructor TSWFActionStartDrag.Create;
begin
  ActionCode := actionStartDrag;
end;

{
***************************************************** TSWFActionEndDrag *****************************************************
}
constructor TSWFActionEndDrag.Create;
begin
  ActionCode := actionEndDrag;
end;

{
************************************************** TSWFActionWaitForFrame2 **************************************************
}
constructor TSWFActionWaitForFrame2.Create;
begin
  ActionCode := actionWaitForFrame2;
end;

// -- Utilities --

{
****************************************************** TSWFActionTrace ******************************************************
}
constructor TSWFActionTrace.Create;
begin
  ActionCode := actionTrace;
end;

{
***************************************************** TSWFActionGetTime *****************************************************
}
constructor TSWFActionGetTime.Create;
begin
  ActionCode := actionGetTime;
end;

{
************************************************** TSWFActionRandomNumber ***************************************************
}
constructor TSWFActionRandomNumber.Create;
begin
  ActionCode := actionRandomNumber;
end;

{
************************************************** TSWFActionRandomNumber ***************************************************
}
constructor TSWFActionFSCommand2.Create;
begin
  ActionCode := actionFSCommand2;
end;


// ------------ SWF 5 -----------
// -- ScriptObject Actions --
{
**************************************************** TSWFActionByteCode *****************************************************
}
constructor TSWFActionByteCode.Create;
begin
  ActionCode := actionByteCode;
end;

destructor TSWFActionByteCode.Destroy;
begin
  if selfdestroy and (DataSize > 0) then FreeMem(Data, DataSize);
  inherited ;
end;

procedure TSWFActionByteCode.Assign(Source: TSWFAction);
begin
  inherited;
  with TSWFActionByteCode(Source) do
   if DataSize > 0 then
     begin
       self.DataSize := DataSize;
       GetMem(self.FData, DataSize);
       Move(Data^, self.FData^, DataSize);
       self.SelfDestroy := true;
     end;
end;

procedure TSWFActionByteCode.SetSize(newsize: word);
begin
 if (DataSize > 0) and SelfDestroy then FreeMem(Data, DataSize);
 DataSize := newsize;
 GetMem(FData, DataSize);
 SelfDestroy := true;
end;

function TSWFActionByteCode.GetByteCode(Index: word): Byte;
var
  P: PByte;
begin
  P := Data;
  if Index > 0 then inc(p, Index);
  Result := P^;
end;

function TSWFActionByteCode.GetStrByteCode: AnsiString;
var
  il: Word;
  P: pbyte;
  s2: string[2];
begin
  if DataSize = 0 then Result := '' else
   begin
    p := Data;
    SetLength(Result, DataSize * 2);
    for il := 0 to DataSize - 1 do
     begin
       s2 := IntToHex(P^, 2);
       Result[il*2 + 1] := s2[1];
       Result[il*2 + 2] := s2[2];
       inc(P);
     end;
   end;
end;

procedure TSWFActionByteCode.SetByteCode(Index: word; Value: Byte);
var
  P: PByte;
begin
  P := Data;
  if Index > 0 then inc(P, Index);
  P^ := Value;
end;

procedure TSWFActionByteCode.SetStrByteCode(Value: AnsiString);
var
  L, il: Word;
  s2: string[2];
  P: PByte;
begin
  L := Length(Value) div 2;
  if (L <> DataSize) and (DataSize > 0) and SelfDestroy then
    begin
      FreeMem(Data, DataSize);
      DataSize := 0;
    end;
  if L > 0 then
   begin
     s2 := '  ';
     SelfDestroy := true;
     if DataSize = 0 then GetMem(fData, L);
     DataSize := L;
     P := Data;
     for il := 0 to DataSize - 1 do
      begin
        s2[1] := Value[il*2 + 1];
        s2[2] := Value[il*2 + 2];
        P^ := StrToInt('$'+ s2);
        Inc(P);
      end;
   end;
end;

procedure TSWFActionByteCode.WriteActionBody(be: TBitsEngine);
begin
  if DataSize > 0 then be.BitsStream.Write(Data^, DataSize);
  BodySize := DataSize;
end;


{
******************************************************** TSWFAction5 ********************************************************
}
function TSWFAction5.MinVersion: Byte;
begin
  Result := SWFVer5;
end;

{
************************************************** TSWFActionCallFunction ***************************************************
}
constructor TSWFActionCallFunction.Create;
begin
  ActionCode := actionCallFunction;
end;

{
*************************************************** TSWFActionCallMethod ****************************************************
}
constructor TSWFActionCallMethod.Create;
begin
  ActionCode := actionCallMethod;
end;

{
************************************************** TSWFActionConstantPool ***************************************************
}
constructor TSWFActionConstantPool.Create;
begin
  ActionCode := actionConstantPool;
  FConstantPool := TStringList.Create;
end;

destructor TSWFActionConstantPool.Destroy;
begin
  FConstantPool.Free;
  inherited Destroy;
end;

procedure TSWFActionConstantPool.Assign(Source: TSWFAction);
begin
  inherited;
  ConstantPool.AddStrings(TSWFActionConstantPool(Source).ConstantPool);
end;

procedure TSWFActionConstantPool.ReadFromStream(be: TBitsEngine);
var
  il: Word;
  Count: Word;
  PP: LongInt;
begin
  PP := BE.BitsStream.Position;
  Count := be.ReadWord;
  if Count > 0 then
    For il := 1 to Count do
     ConstantPool.add(be.ReadString);
  if (BE.BitsStream.Position - PP) <> BodySize then
      BodySize := BE.BitsStream.Position - PP;
end;

procedure TSWFActionConstantPool.WriteActionBody(be: TBitsEngine);
var
  il: Word;
begin
  be.WriteWord(ConstantPool.Count);
  if ConstantPool.Count > 0 then
   For il := 0 to ConstantPool.Count - 1 do
    be.WriteString(ConstantPool[il]);
end;


{
************************************************* TSWFActionDefineFunction **************************************************
}
constructor TSWFActionDefineFunction.Create;
begin
  ActionCode := actionDefineFunction;
  FParams := TStringList.Create;
end;

destructor TSWFActionDefineFunction.Destroy;
begin
  FreeOffsetMarker(FCodeSizeMarker);
  FParams.Free;
end;

procedure TSWFActionDefineFunction.Assign(Source: TSWFAction);
begin
  inherited;
  With TSWFActionDefineFunction(Source) do
  begin
   self.StaticOffset := StaticOffset;
   self.FunctionName := FunctionName;
   self.Params.AddStrings(Params);
   if StaticOffset then
     self.CodeSize := CodeSize;
  //**//
  end;
end;

function TSWFActionDefineFunction.GetCodeSizeMarker: TSWFOffsetMarker;
begin
  if FCodeSizeMarker = nil then
    FCodeSizeMarker := TSWFOffsetMarker.Create;
  Result := FCodeSizeMarker;
end;

procedure TSWFActionDefineFunction.ReadFromStream(be: TBitsEngine);
var
  Count, il: Word;
begin
  FunctionName := be.ReadString;
  Count := be.ReadWord;
  if Count>0 then
    For il:=0 to Count - 1 do
      Params.Add(be.ReadString);
  CodeSize := be.ReadWord;
end;

procedure TSWFActionDefineFunction.SetCodeSize(v: Word);
begin
  fCodeSize := v;
  StaticOffset := true;
end;

procedure TSWFActionDefineFunction.WriteActionBody(be: TBitsEngine);
var
  il: Integer;
begin
  be.WriteString(FunctionName);
  be.WriteWord(Params.Count);
  if Params.Count>0 then
    For il:=0 to Params.Count - 1 do be.WriteString(Params[il]);
  if StaticOffset then  be.WriteWord(CodeSize) else
    if FCodeSizeMarker <> nil then
      begin
        FCodeSizeMarker.RootStreamPosition := StartPosition + 3 + be.BitsStream.Position;
        FCodeSizeMarker.WriteOffset(be);
      end;
end;

procedure TSWFActionDefineFunction.WriteToStream(be: TBitsEngine);
begin
  StartPosition := be.BitsStream.Position;
  inherited;
end;

{
*************************************************** TSWFActionDefineLocal ***************************************************
}
constructor TSWFActionDefineLocal.Create;
begin
  ActionCode := actionDefineLocal;
end;

{
************************************************** TSWFActionDefineLocal2 ***************************************************
}
constructor TSWFActionDefineLocal2.Create;
begin
  ActionCode := actionDefineLocal2;
end;

{
***************************************************** TSWFActionDelete ******************************************************
}
constructor TSWFActionDelete.Create;
begin
  ActionCode := actionDelete;
end;

{
***************************************************** TSWFActionDelete2 *****************************************************
}
constructor TSWFActionDelete2.Create;
begin
  ActionCode := actionDelete2;
end;

{
**************************************************** TSWFActionEnumerate ****************************************************
}
constructor TSWFActionEnumerate.Create;
begin
  ActionCode := actionEnumerate;
end;

{
***************************************************** TSWFActionEquals2 *****************************************************
}
constructor TSWFActionEquals2.Create;
begin
  ActionCode := actionEquals2;
end;

{
**************************************************** TSWFActionGetMember ****************************************************
}
constructor TSWFActionGetMember.Create;
begin
  ActionCode := actionGetMember;
end;

{
**************************************************** TSWFActionInitArray ****************************************************
}
constructor TSWFActionInitArray.Create;
begin
  ActionCode := actionInitArray;
end;

{
*************************************************** TSWFActionInitObject ****************************************************
}
constructor TSWFActionInitObject.Create;
begin
  ActionCode := actionInitObject;
end;

{
**************************************************** TSWFActionNewMethod ****************************************************
}
constructor TSWFActionNewMethod.Create;
begin
  ActionCode := actionNewMethod;
end;

{
**************************************************** TSWFActionNewObject ****************************************************
}
constructor TSWFActionNewObject.Create;
begin
  ActionCode := actionNewObject;
end;

{
**************************************************** TSWFActionSetMember ****************************************************
}
constructor TSWFActionSetMember.Create;
begin
  ActionCode := actionSetMember;
end;

{
*************************************************** TSWFActionTargetPath ****************************************************
}
constructor TSWFActionTargetPath.Create;
begin
  ActionCode := actionTargetPath;
end;

{
****************************************************** TSWFActionWith *******************************************************
}
constructor TSWFActionWith.Create;
begin
  ActionCode := actionWith;
end;

destructor TSWFActionWith.Destroy;
begin
  FreeOffsetMarker(FSizeMarker);
  inherited;
end;

procedure TSWFActionWith.Assign(Source: TSWFAction);
begin
  inherited;
  With TSWFActionWith(Source) do
  begin
   self.StaticOffset := StaticOffset;
   if StaticOffset then
     self.Size := Size;
  //**//
  end;
end;

function TSWFActionWith.GetSizeMarker: TSWFOffsetMarker;
begin
  if FSizeMarker = nil then
    FSizeMarker := TSWFOffsetMarker.Create;
  Result := FSizeMarker;
end;

procedure TSWFActionWith.ReadFromStream(be: TBitsEngine);
begin
  Size := be.ReadWord;
end;

procedure TSWFActionWith.SetSize(w: Word);
begin
  fSize := w;
  StaticOffset := true;
end;

procedure TSWFActionWith.WriteActionBody(be: TBitsEngine);
begin
  if StaticOffset then be.WriteWord(Size) else
   begin
     if FSizeMarker <> nil then
       begin
         SizeMarker.RootStreamPosition := StartPosition + 3;
         SizeMarker.WriteOffset(be);
       end;
   end;
end;

procedure TSWFActionWith.WriteToStream(be: TBitsEngine);
begin
  StartPosition := be.BitsStream.Position;
  inherited;
end;

// -- Type Actions --
{
**************************************************** TSWFActionToNumber *****************************************************
}
constructor TSWFActionToNumber.Create;
begin
  ActionCode := actionToNumber;
end;

{
**************************************************** TSWFActionToString *****************************************************
}
constructor TSWFActionToString.Create;
begin
  ActionCode := actionToString;
end;

{
***************************************************** TSWFActionTypeOf ******************************************************
}
constructor TSWFActionTypeOf.Create;
begin
  ActionCode := actionTypeOf;
end;

// -- Math Actions --
{
****************************************************** TSWFActionAdd2 *******************************************************
}
constructor TSWFActionAdd2.Create;
begin
  ActionCode := actionAdd2;
end;

{
****************************************************** TSWFActionLess2 ******************************************************
}
constructor TSWFActionLess2.Create;
begin
  ActionCode := actionLess2;
end;

{
***************************************************** TSWFActionModulo ******************************************************
}
constructor TSWFActionModulo.Create;
begin
  ActionCode := actionModulo;
end;

// -- Stack Operator Actions --
{
***************************************************** TSWFActionBitAnd ******************************************************
}
constructor TSWFActionBitAnd.Create;
begin
  ActionCode := actionBitAnd;
end;

{
**************************************************** TSWFActionBitLShift ****************************************************
}
constructor TSWFActionBitLShift.Create;
begin
  ActionCode := actionBitLShift;
end;

{
****************************************************** TSWFActionBitOr ******************************************************
}
constructor TSWFActionBitOr.Create;
begin
  ActionCode := actionBitOr;
end;

{
**************************************************** TSWFActionBitRShift ****************************************************
}
constructor TSWFActionBitRShift.Create;
begin
  ActionCode := actionBitRShift;
end;

{
*************************************************** TSWFActionBitURShift ****************************************************
}
constructor TSWFActionBitURShift.Create;
begin
  ActionCode := actionBitURShift;
end;

{
***************************************************** TSWFActionBitXor ******************************************************
}
constructor TSWFActionBitXor.Create;
begin
  ActionCode := actionBitXor;
end;

{
**************************************************** TSWFActionDecrement ****************************************************
}
constructor TSWFActionDecrement.Create;
begin
  ActionCode := actionDecrement;
end;

{
**************************************************** TSWFActionIncrement ****************************************************
}
constructor TSWFActionIncrement.Create;
begin
  ActionCode := actionIncrement;
end;

{
************************************************** TSWFActionPushDuplicate **************************************************
}
constructor TSWFActionPushDuplicate.Create;
begin
  ActionCode := actionPushDuplicate;
end;

{
***************************************************** TSWFActionReturn ******************************************************
}
constructor TSWFActionReturn.Create;
begin
  ActionCode := actionReturn;
end;

{
**************************************************** TSWFActionStackSwap ****************************************************
}
constructor TSWFActionStackSwap.Create;
begin
  ActionCode := actionStackSwap;
end;

{
************************************************** TSWFActionStoreRegister **************************************************
}
constructor TSWFActionStoreRegister.Create;
begin
  ActionCode := actionStoreRegister;
end;

procedure TSWFActionStoreRegister.Assign(Source: TSWFAction);
begin
  inherited;
  RegisterNumber := TSWFActionStoreRegister(Source).RegisterNumber;
end;

procedure TSWFActionStoreRegister.ReadFromStream(be: TBitsEngine);
begin
  RegisterNumber := be.ReadByte;
end;

procedure TSWFActionStoreRegister.WriteActionBody(be: TBitsEngine);
begin
  be.WriteByte(RegisterNumber);
end;


// ------------ SWF 6 -----------

{
******************************************************** TSWFAction6 ********************************************************
}
function TSWFAction6.MinVersion: Byte;
begin
  Result := SWFVer6;
end;

{
*************************************************** TSWFActionInstanceOf ****************************************************
}
constructor TSWFActionInstanceOf.Create;
begin
  ActionCode := actionInstanceOf;
end;

{
*************************************************** TSWFActionEnumerate2 ****************************************************
}
constructor TSWFActionEnumerate2.Create;
begin
  ActionCode := actionEnumerate2;
end;

{
************************************************** TSWFActionStrictEquals ***************************************************
}
constructor TSWFActionStrictEquals.Create;
begin
  ActionCode := actionStrictEquals;
end;

{
***************************************************** TSWFActionGreater *****************************************************
}
constructor TSWFActionGreater.Create;
begin
  ActionCode := actionGreater;
end;

{
************************************************** TSWFActionStringGreater **************************************************
}
constructor TSWFActionStringGreater.Create;
begin
  ActionCode := actionStringGreater;
end;


// ------------ SWF 7 -----------

{
******************************************************** TSWFAction7 ********************************************************
}
function TSWFAction7.MinVersion: Byte;
begin
  Result := SWFVer7;
end;

{
************************************************* TSWFActionDefineFunction2 *************************************************
}
constructor TSWFActionDefineFunction2.Create;
begin
  ActionCode := actionDefineFunction2;
  Parameters := TStringList.Create;
end;

destructor TSWFActionDefineFunction2.Destroy;
begin
  FreeOffsetMarker(FCodeSizeMarker);
  Parameters.Free;
  inherited;
end;

procedure TSWFActionDefineFunction2.Assign(Source: TSWFAction);
begin
  inherited;
  With TSWFActionDefineFunction2(Source) do
  begin
    self.FunctionName := FunctionName;
    self.Parameters.AddStrings(Parameters);
    self.RegisterCount := RegisterCount;

    self.PreloadArgumentsFlag := PreloadArgumentsFlag;
    self.PreloadGlobalFlag := PreloadGlobalFlag;
    self.PreloadParentFlag := PreloadParentFlag;
    self.PreloadRootFlag := PreloadRootFlag;
    self.PreloadSuperFlag := PreloadSuperFlag;
    self.PreloadThisFlag := PreloadThisFlag;

    self.SuppressArgumentsFlag := SuppressArgumentsFlag;
    self.SuppressSuperFlag := SuppressSuperFlag;
    self.SuppressThisFlag := SuppressThisFlag;

    self.StaticOffset := StaticOffset;
    if StaticOffset then
      self.CodeSize := CodeSize;
  //  CodeSizeMarker: TSWFOffsetMarker;
  //**//

  end;
end;

procedure TSWFActionDefineFunction2.AddParam(const param: string; reg: byte);
begin
  Parameters.AddObject(param, Pointer(reg));
end;

function TSWFActionDefineFunction2.GetCodeSizeMarker: TSWFOffsetMarker;
begin
  if FCodeSizeMarker = nil then
    FCodeSizeMarker := TSWFOffsetMarker.Create;
  Result := FCodeSizeMarker;
end;

function TSWFActionDefineFunction2.GetParamRegister(Index: byte): byte;
begin
  Result := Longint(Parameters.Objects[Index]);
end;

procedure TSWFActionDefineFunction2.ReadFromStream(be: TBitsEngine);
var
  il, ParamCount: Word;
  b: Byte;
begin
  FunctionName := be.ReadString;
  ParamCount := be.ReadWord;
  RegisterCount := be.ReadByte;
  b := be.ReadByte;
  PreloadParentFlag := CheckBit(b, 8);
  PreloadRootFlag := CheckBit(b, 7);
  SuppressSuperFlag := CheckBit(b, 6);
  PreloadSuperFlag := CheckBit(b, 5);
  SuppressArgumentsFlag := CheckBit(b, 4);
  PreloadArgumentsFlag := CheckBit(b, 3);
  SuppressThisFlag := CheckBit(b, 2);
  PreloadThisFlag := CheckBit(b, 1);
  b := be.ReadByte;
  PreloadGlobalFlag := CheckBit(b, 1);
  if ParamCount > 0 then
   For il:=0 to ParamCount - 1 do
    begin
      b := be.ReadByte;
      Parameters.Objects[Parameters.Add(be.ReadString)] := Pointer(LongInt(b));
    end;
  CodeSize:=be.ReadWord;
end;

procedure TSWFActionDefineFunction2.SetCodeSize(v: Word);
begin
  fCodeSize := v;
  StaticOffset := true;
end;

procedure TSWFActionDefineFunction2.SetParamRegister(index, value: byte);
begin
  Parameters.Objects[Index] := Pointer(value);
end;

procedure TSWFActionDefineFunction2.WriteActionBody(be: TBitsEngine);
var
  il: Word;
begin
  be.WriteString(FunctionName);
  be.WriteWord(Parameters.Count);
  be.WriteByte(RegisterCount);
  be.WriteBit(PreloadParentFlag);
  be.WriteBit(PreloadRootFlag);
  be.WriteBit(SuppressSuperFlag);
  be.WriteBit(PreloadSuperFlag);
  be.WriteBit(SuppressArgumentsFlag);
  be.WriteBit(PreloadArgumentsFlag);
  be.WriteBit(SuppressThisFlag);
  be.WriteBit(PreloadThisFlag);
  be.WriteBits(0, 7);
  be.WriteBit(PreloadGlobalFlag);
  if Parameters.Count > 0 then
   For il:=0 to Parameters.Count - 1 do
    begin
      be.WriteByte(LongInt(Parameters.Objects[il]));
      be.WriteString(Parameters[il]);
    end;
  if StaticOffset then be.WriteWord(CodeSize) else
    if FCodeSizeMarker <> nil then
      begin
        FCodeSizeMarker.RootStreamPosition := StartPosition + 3 + be.BitsStream.Position;
        FCodeSizeMarker.WriteOffset(be);
      end;
end;

procedure TSWFActionDefineFunction2.WriteToStream(be: TBitsEngine);
begin
  StartPosition := be.BitsStream.Position;
  inherited;
end;


{
***************************************************** TSWFActionExtends *****************************************************
}
constructor TSWFActionExtends.Create;
begin
  ActionCode := actionExtends;
end;

{
***************************************************** TSWFActionCastOp ******************************************************
}
constructor TSWFActionCastOp.Create;
begin
  ActionCode := actionCastOp;
end;

{
************************************************** TSWFActionImplementsOp ***************************************************
}
constructor TSWFActionImplementsOp.Create;
begin
  ActionCode := actionImplementsOp;
end;

{
******************************************************* TSWFActionTry *******************************************************
}
constructor TSWFActionTry.Create;
begin
  ActionCode := actionTry;
end;

destructor TSWFActionTry.Destroy;
 procedure fFree(var Marker: TSWFTryOffsetMarker);
 begin
  try
  if Assigned(Marker) and not Marker.isUsing then FreeAndNil(Marker);
 except
 end;
 end;
begin
  fFree(FTrySizeMarker);
  fFree(FCatchSizeMarker);
  fFree(FFinallySizeMarker);
  inherited;
end;

procedure TSWFActionTry.Assign(Source: TSWFAction);
begin
  inherited;
  With TSWFActionTry(Source) do
  begin
    self.CatchName := CatchName;
    self.StaticOffset := StaticOffset;
    self.CatchBlockFlag := CatchBlockFlag;
    self.CatchInRegisterFlag := CatchInRegisterFlag;
    self.CatchRegister := CatchRegister;
    self.CatchSize := CatchSize;
    self.FinallyBlockFlag := FinallyBlockFlag;
    //  CatchSizeMarker: TSWFOffsetMarker;
    self.FinallySize := FinallySize;
    //  FinallySizeMarker: TSWFOffsetMarker;
    self.TrySize := TrySize;
    //  TrySizeMarker: TSWFOffsetMarker;
  //**//
  end;
end;

function TSWFActionTry.GetCatchSizeMarker: TSWFTryOffsetMarker;
begin
  if FCatchSizeMarker = nil then
    FCatchSizeMarker := TSWFTryOffsetMarker.Create;
  Result := FCatchSizeMarker;
end;

function TSWFActionTry.GetFinallySizeMarker: TSWFTryOffsetMarker;
begin
  if FFinallySizeMarker = nil then
    FFinallySizeMarker := TSWFTryOffsetMarker.Create;
  Result := FFinallySizeMarker;
end;

function TSWFActionTry.GetTrySizeMarker: TSWFTryOffsetMarker;
begin
  if FTrySizeMarker = nil then
    FTrySizeMarker := TSWFTryOffsetMarker.Create;
  Result := FTrySizeMarker;
end;

procedure TSWFActionTry.ReadFromStream(be: TBitsEngine);
var
  b: Byte;
begin
  b := be.ReadByte;
  CatchInRegisterFlag := CheckBit(b, 3);
  FinallyBlockFlag := CheckBit(b, 2);
  CatchBlockFlag := CheckBit(b, 1);
  TrySize := be.ReadWord;
  CatchSize := be.ReadWord;
  FinallySize := be.ReadWord;
  if CatchInRegisterFlag
    then CatchRegister := be.ReadByte
    else CatchName := be.ReadString;
end;

procedure TSWFActionTry.SetCatchSize(w: Word);
begin
  fCatchSize := w;
  StaticOffset := true;
end;

procedure TSWFActionTry.SetFinallySize(w: Word);
begin
  fFinallySize := W;
  StaticOffset := true;
end;

procedure TSWFActionTry.SetTrySize(w: Word);
begin
  fTrySize := W;
  StaticOffset := true;
end;

procedure TSWFActionTry.WriteActionBody(be: TBitsEngine);
begin
  be.Writebits(0, 5);
  be.WriteBit(CatchInRegisterFlag);
  be.WriteBit(FinallyBlockFlag);
  be.WriteBit(CatchBlockFlag);
  if StaticOffset then
    begin
      be.WriteWord(TrySize);
      be.WriteWord(CatchSize);
      be.WriteWord(FinallySize);
    end else
    begin
      if FTrySizeMarker <> nil then
        begin
          FTrySizeMarker.RootStreamPosition := StartPosition + 3 + be.BitsStream.Position;
          FTrySizeMarker.WriteOffset(be);
        end;
      if CatchBlockFlag
        then
        begin
          if FCatchSizeMarker <> nil then
            begin
              FCatchSizeMarker.RootStreamPosition := StartPosition + 3 + be.BitsStream.Position;
              FCatchSizeMarker.WriteOffset(be);
              FCatchSizeMarker.FPrvieusMarker := FTrySizeMarker;
            end;
        end
        else be.WriteWord(0);
      if FinallyBlockFlag
        then begin
          if FFinallySizeMarker <> nil then
            begin
              FFinallySizeMarker.RootStreamPosition := StartPosition + 3 + be.BitsStream.Position;
              FFinallySizeMarker.WriteOffset(be);
              if CatchBlockFlag
                then FFinallySizeMarker.FPrvieusMarker := FCatchSizeMarker
                else FFinallySizeMarker.FPrvieusMarker := FTrySizeMarker;
            end;
        end
        else be.WriteWord(0);
    end;
  if CatchInRegisterFlag
    then be.WriteByte(CatchRegister)
    else be.WriteString(CatchName);
end;

procedure TSWFActionTry.WriteToStream(be: TBitsEngine);
begin
  StartPosition := be.BitsStream.Position;
  inherited;
end;

{
****************************************************** TSWFActionThrow ******************************************************
}
constructor TSWFActionThrow.Create;
begin
  ActionCode := actionThrow;
end;

{
****************************************************** TSWFActionList *******************************************************
}
function TSWFActionList.GetAction(Index: word): TSWFAction;
begin
  Result := TSWFAction(Items[Index]);
end;

procedure TSWFActionList.SetAction(Index: word; Value: TSWFAction);
begin
  Items[Index] := Value;
end;
{
******************************************************* TSWFDoAction ********************************************************
}
constructor TSWFDoAction.Create;
begin
  TagID := tagDoAction;
  FActions := TSWFActionList.Create;
  SelfDestroy := true;
end;

constructor TSWFDoAction.Create(A: TSWFActionList);
begin
  TagID := tagDoAction;
  FActions := A;
  SelfDestroy := false;
end;

destructor TSWFDoAction.Destroy;
begin
  if SelfDestroy then FActions.Free;
  inherited ;
end;

procedure TSWFDoAction.Assign(Source: TBasedSWFObject);
begin
  inherited;
  With TSWFDoAction(Source) do
  begin
    self.SelfDestroy := SelfDestroy;
    CopyActionList(Actions, self.Actions);
  end;
end;

function TSWFDoAction.MinVersion: Byte;
var
  il: Word;
begin
  Result := SWFVer3;
  if Actions.Count > 0 then
   for il := 0 to Actions.Count -1 do
    if Result < Actions[il].MinVersion then
      Result := Actions[il].MinVersion;
end;

procedure TSWFDoAction.ReadFromStream(be: TBitsEngine);
var
  BA: TSWFActionByteCode;
begin
  if ParseActions then ReadActionList(be, Actions, BodySize)
    else
    begin
      BA := TSWFActionByteCode.Create;
      BA.DataSize := BodySize - 1;
      BA.SelfDestroy := true;
      GetMem(BA.fData, BA.DataSize);
      be.BitsStream.Read(BA.Data^, BA.DataSize);
      Actions.Add(BA);
      be.ReadByte; // last 0
    end;

  //  if be.BitsStream.Position < (StartPos + BodySize) then
  //    be.BitsStream.Position := StartPos + BodySize;
end;

procedure TSWFDoAction.WriteTagBody(be: TBitsEngine);
var
  il: Word;
begin
  if Actions.Count > 0 then
    For il:=0 to Actions.Count-1 do
      Actions[il].WriteToStream(be);
  be.WriteByte(0); // End flag
end;


{
***************************************************** TSWFDoInitAction ******************************************************
}
constructor TSWFDoInitAction.Create;
begin
  inherited ;
  TagID := tagDoInitAction;
end;

constructor TSWFDoInitAction.Create(A: TSWFActionList);
begin
  inherited ;
  TagID := tagDoInitAction;
end;

procedure TSWFDoInitAction.Assign(Source: TBasedSWFObject);
begin
  inherited;
  SpriteID := TSWFDoInitAction(Source).SpriteID;
end;

function TSWFDoInitAction.MinVersion: Byte;
begin
  Result := SWFVer6;
end;

procedure TSWFDoInitAction.ReadFromStream(be: TBitsEngine);
var
  BA: TSWFActionByteCode;
begin
  SpriteID := be.ReadWord;
  if ParseActions then ReadActionList(be, Actions, BodySize - 2)
    else
    begin
      BA := TSWFActionByteCode.Create;
      BA.DataSize := BodySize - 3;
      BA.SelfDestroy := true;
      GetMem(BA.fData, BA.DataSize);
      be.BitsStream.Read(BA.Data^, BA.DataSize);
      Actions.Add(BA);
      be.ReadByte;
    end;
end;

procedure TSWFDoInitAction.WriteTagBody(be: TBitsEngine);
begin
  be.WriteWord(SpriteID);
  inherited;
end;



// ===========================================================
//                            AS3
// ===========================================================

{ TDoubleObject }

constructor TSWFDoubleObject.Create(init: double);
begin
  Value := init;
end;

{ TNameSpaceObject }

constructor TSWFNameSpaceObject.Create(kind: byte; name: Longint);
begin
 self.Kind := kind;
 self.Name := name;
end;

{ TIntegerList }

function TSWFIntegerList.GetInt(index: Integer): longint;
begin
  Result := longint(items[index]);
end;

procedure TSWFIntegerList.SetInt(index: Integer; const Value: longint);
begin
  Items[index] := Pointer(Value);
end;

procedure TSWFIntegerList.WriteToStream(be: TBitsEngine);
  var il: integer;
begin
  be.WriteEncodedU32(Count);
  if Count > 0 then
  for il := 0 to Count - 1 do
    be.WriteEncodedU32(Int[il]);
end;

procedure TSWFIntegerList.AddInt(value: longint);
begin
  Add(Pointer(Value));
end;


{ TSWFBasedMultiNameObject }

procedure TSWFBasedMultiNameObject.ReadFromStream(be: TBitsEngine);
begin
 // empty
end;

procedure TSWFBasedMultiNameObject.WriteToStream(be: TBitsEngine);
begin
 // empty
end;


procedure TSWFmnQName.ReadFromStream(be: TBitsEngine);
begin
  NS := be.ReadEncodedU32;
  Name := be.ReadEncodedU32;
end;


procedure TSWFmnQName.WriteToStream(be: TBitsEngine);
begin
  be.WriteEncodedU32(NS);
  be.WriteEncodedU32(Name);
end;


procedure TSWFmnRTQName.ReadFromStream(be: TBitsEngine);
begin
  Name := be.ReadEncodedU32;
end;

procedure TSWFmnRTQName.WriteToStream(be: TBitsEngine);
begin
  be.WriteEncodedU32(Name);
end;


procedure TSWFmnMultiname.ReadFromStream(be: TBitsEngine);
begin
  Name := be.ReadEncodedU32;
  NSSet := be.ReadEncodedU32;
end;

procedure TSWFmnMultiname.WriteToStream(be: TBitsEngine);
begin
  be.WriteEncodedU32(Name);
  be.WriteEncodedU32(NSSet);
end;


procedure TSWFmnMultinameL.ReadFromStream(be: TBitsEngine);
begin
  NSSet := be.ReadEncodedU32;
end;

procedure TSWFmnMultinameL.WriteToStream(be: TBitsEngine);
begin
  be.WriteEncodedU32(NSSet);
end;



{ TSWFAS3ConstantPool }

constructor TSWFAS3ConstantPool.Create;
begin
  IntegerList := TSWFIntegerList.Create;
  UIntegerList := TList.Create;
  DoubleList := TObjectList.Create;
  StringList := TStringList.Create;
  NameSpaceList := TObjectList.Create;
  NameSpaceSETList := TObjectList.Create;
  MultinameList := TObjectList.Create;
end;

destructor TSWFAS3ConstantPool.Destroy;
begin
  MultinameList.Free;
  NameSpaceSETList.Free;
  NameSpaceList.Free;
  StringList.Free;
  DoubleList.Free;
  UIntegerList.Free;
  IntegerList.Free;
  inherited;
end;

function TSWFAS3ConstantPool.GetDouble(index: Integer): Double;
begin
  Result := TSWFDoubleObject(DoubleList[index]).Value;
end;

function TSWFAS3ConstantPool.GetDoubleCount: longint;
begin
  Result := DoubleList.Count;
end;

function TSWFAS3ConstantPool.GetInt(index: longint): longint;
begin
  Result := IntegerList.Int[index];
end;

function TSWFAS3ConstantPool.GetIntCount: longint;
begin
  Result := IntegerList.Count;
end;

function TSWFAS3ConstantPool.GetMultiname(index: Integer): TSWFBasedMultiNameObject;
begin
  Result := TSWFBasedMultiNameObject(MultinameList[index]);
end;

function TSWFAS3ConstantPool.GetMultinameCount: longint;
begin
  Result := MultinameList.Count;
end;

function TSWFAS3ConstantPool.GetNameSpace(index: Integer): TSWFNameSpaceObject;
begin
  Result := TSWFNameSpaceObject(NameSpaceList[index]);
end;

function TSWFAS3ConstantPool.GetNameSpaceCount: longint;
begin
  Result := NameSpaceList.Count;
end;

function TSWFAS3ConstantPool.GetNameSpaceSET(index: Integer): TSWFIntegerList;
begin
  Result := TSWFIntegerList(NameSpaceSETList[index]);
end;

function TSWFAS3ConstantPool.GetNameSpaceSETCount: longint;
begin
  Result := NameSpaceSETList.Count;
end;

function TSWFAS3ConstantPool.GetStrings(index: Integer): string;
begin
  Result := StringList[index];
end;

function TSWFAS3ConstantPool.GetStringsCount: longint;
begin
  Result := StringList.Count;
end;

function TSWFAS3ConstantPool.GetUInt(index: Integer): longword;
begin
  Result := longword(UIntegerList[index]);
end;

function TSWFAS3ConstantPool.GetUIntCount: longword;
begin
  Result := UIntegerList.Count;
end;

procedure TSWFAS3ConstantPool.ReadFromStream(be: TBitsEngine);
 var count, subcount, il, il2: dword;
     Kind: byte;
     NSSet: TSWFIntegerList;
     MK: TSWFBasedMultiNameObject;
begin
  be.ReadByte; // "unnecessary" byte
  count := be.ReadEncodedU32;
  if count > 0 then
    for il := 1 to count - 1 do
      IntegerList.AddInt(be.ReadEncodedU32);

  count := be.ReadEncodedU32;
  if count > 0 then
    for il := 1 to count - 1 do
      UIntegerList.Add(Pointer(be.ReadEncodedU32));

  count := be.ReadEncodedU32;
  if count > 0 then
    for il := 1 to count - 1 do
      DoubleList.Add(TSWFDoubleObject.Create(be.ReadStdDouble));

  count := be.ReadEncodedU32;
  if count > 0 then
    for il := 1 to count - 1 do
      StringList.Add(be.ReadLongString(true));

  count := be.ReadEncodedU32;
  if count > 0 then
    for il := 1 to count - 1 do
    begin
      Kind := be.ReadByte;
      NameSpaceList.Add(TSWFNameSpaceObject.Create(Kind, be.ReadEncodedU32));
    end;

  count := be.ReadEncodedU32;
  if count > 0 then
    for il := 1 to count - 1 do
    begin
      subcount := be.ReadEncodedU32;
      NSSet := TSWFIntegerList.Create;
      NameSpaceSETList.Add(NSSet);
      if subcount > 0 then
        for il2 := 0 to subcount - 1 do
          NSSet.AddInt(be.ReadEncodedU32);
    end;

  count := be.ReadEncodedU32;
  if count > 0 then
    for il := 1 to count - 1 do
    begin
      Kind := be.ReadByte;
      case Kind of
        mkQName, mkQNameA:
          MK := TSWFmnQName.Create;

        mkRTQName, mkRTQNameA:
          MK := TSWFmnRTQName.Create;

        mkRTQNameL, mkRTQNameLA:
          MK := TSWFmnRTQNameL.Create;

        mkMultiname, mkMultinameA:
          MK := TSWFmnMultiname.Create;

        else {mkMultinameL, mkMultinameLA:}
          MK := TSWFmnMultinameL.Create;
      end;
      MK.MultinameKind := Kind;
      MK.ReadFromStream(be);
      MultinameList.Add(MK);
    end;
end;

procedure TSWFAS3ConstantPool.WriteToStream(be: TBitsEngine);
 var il: dword;
begin
  be.WriteByte(0); // "unnecessary" byte
  if IntCount > 0 then
  begin
    be.WriteEncodedU32(IntCount + 1);
    for il := 0 to IntCount - 1 do
      be.WriteEncodedU32(Int[il]);
  end else be.WriteByte(0);

  if UIntCount > 0 then
  begin
    be.WriteEncodedU32(UIntCount + 1);
    for il := 0 to UIntcount - 1 do
      be.WriteEncodedU32(UInt[il]);
  end else be.WriteByte(0);

  if DoubleCount > 0 then
  begin
    be.WriteEncodedU32(DoubleCount + 1);
    for il := 0 to DoubleCount - 1 do
      be.WriteStdDouble(Double[il]);
  end else be.WriteByte(0);

  if StringsCount > 0 then
  begin
    be.WriteEncodedU32(StringsCount + 1);
    for il := 0 to StringsCount - 1 do
      be.WriteEncodedString(Strings[il]);
  end else be.WriteByte(0);

  if NameSpaceCount > 0 then
  begin
    be.WriteEncodedU32(NameSpaceCount + 1);
    for il := 0 to NameSpaceCount - 1 do
    with NameSpace[il] do
    begin
      be.WriteByte(Kind);
      be.WriteEncodedU32(Name);
    end;
  end else be.WriteByte(0);

  if NameSpaceSETCount > 0 then
  begin
    be.WriteEncodedU32(NameSpaceSETCount + 1);
    for il := 0 to NameSpaceSETCount - 1 do
      NameSpaceSET[il].WriteToStream(be);
  end else be.WriteByte(0);

  if MultinameCount > 0 then
  begin
    be.WriteEncodedU32(MultinameCount + 1);
    for il := 0 to MultinameCount - 1 do
    begin
      be.WriteByte(Multiname[il].MultinameKind);
      Multiname[il].WriteToStream(be);
    end;
  end else be.WriteByte(0);
end;

procedure TSWFAS3ConstantPool.SetDouble(index: Integer; const Value: Double);
begin
  if index = -1 then DoubleList.Add(TSWFDoubleObject.Create(Value))
    else TSWFDoubleObject(DoubleList[index]).Value := Value;
end;

procedure TSWFAS3ConstantPool.SetInt(index: longint; const Value: longint);
begin
  if index = -1 then IntegerList.Add(Pointer(Value))
    else IntegerList.Int[index] := Value;
end;

procedure TSWFAS3ConstantPool.SetMultiname(index: Integer; const Value: TSWFBasedMultiNameObject);
begin
  if index = -1 then MultinameList.Add(Value)
    else MultinameList[index] := Value;
end;

procedure TSWFAS3ConstantPool.SetNameSpace(index: Integer; const Value: TSWFNameSpaceObject);
begin
  if index = -1 then NameSpaceList.Add(Value)
    else NameSpaceList[index] := Value;
end;

procedure TSWFAS3ConstantPool.SetNameSpaceSET(index: Integer; const Value: TSWFIntegerList);
begin
  if index = -1 then NameSpaceSETList.Add(Value)
    else NameSpaceSETList[index] := Value;
end;

procedure TSWFAS3ConstantPool.SetStrings(index: longint; const Value: string);
begin
  if index = -1 then StringList.Add(Value)
    else StringList[index] := Value;
end;

procedure TSWFAS3ConstantPool.SetUInt(index: Integer; const Value: longword);
begin
  if index = -1 then UIntegerList.Add(Pointer(Value))
    else UIntegerList[index] := Pointer(Value);
end;

function TSWFAS3MetadataInfo.AddMetadataItem: TSWFAS3MetadataItem;
begin
  Result := TSWFAS3MetadataItem.Create;
  FInfoList.Add(Result);
end;

constructor TSWFAS3MetadataInfo.Create;
begin
  FInfoList := TObjectList.Create;
end;


destructor TSWFAS3MetadataInfo.Destroy;
begin
  FInfoList.Free;
  inherited;
end;

function TSWFAS3MetadataInfo.GetItem(index: integer): TSWFAS3MetadataItem;
begin
  Result := TSWFAS3MetadataItem(InfoList[index]);
end;

{ TSWFAS3Metadata }

function TSWFAS3Metadata.AddMetaInfo: TSWFAS3MetadataInfo;
begin
  Result := TSWFAS3MetadataInfo.Create;
  FMetadataList.Add(Result);
end;

constructor TSWFAS3Metadata.Create;
begin
  FMetadataList := TObjectList.Create;
end;

destructor TSWFAS3Metadata.Destroy;
begin
  FMetadataList.Free;
  inherited;
end;

function TSWFAS3Metadata.GetMetadata(index: integer): TSWFAS3MetadataInfo;
begin
  Result := TSWFAS3MetadataInfo(FMetadataList[index]);
end;

procedure TSWFAS3Metadata.ReadFromStream(be: TBitsEngine);
 var count, icount, il, il2: longint;
     MInfo: TSWFAS3MetadataInfo;
     MItem: TSWFAS3MetadataItem;
begin
  count := be.ReadEncodedU32;
  if count > 0 then
  for il := 0 to count - 1 do
  begin
    MInfo := AddMetaInfo;
    MInfo.Name := be.ReadEncodedU32;
    icount := be.ReadEncodedU32;
    if icount > 0 then
    for il2 := 0 to icount - 1 do
    begin
      MItem := MInfo.AddMetadataItem;
      MItem.Key := be.ReadEncodedU32;
      MItem.Value := be.ReadEncodedU32;
    end;
  end;
end;

procedure TSWFAS3Metadata.WriteToStream(be: TBitsEngine);
var il, il2: longint;
begin
  be.WriteEncodedU32(MetadataList.Count);
  if MetadataList.Count > 0 then
    for il := 0 to MetadataList.Count - 1 do
    with MetadataInfo[il] do
    begin
      be.WriteEncodedU32(Name);
      be.WriteEncodedU32(InfoList.Count);
      if InfoList.Count > 0 then
        for il2 := 0 to InfoList.Count - 1 do
        with MetaItem[il2] do
        begin
          be.WriteEncodedU32(Key);
          be.WriteEncodedU32(Value);
        end;
    end;
end;


{ TSWFAS3Methods }

constructor TSWFAS3Method.Create;
begin
  FParamNames := TSWFIntegerList.Create;
  FParamTypes := TSWFIntegerList.Create;
  FOptions := TObjectList.Create;
end;

destructor TSWFAS3Method.Destroy;
begin
  FParamNames.Free;
  FOptions.Free;
  FParamTypes.Free;
  inherited;
end;

function TSWFAS3Method.AddOption: TSWFAS3MethodOptions;
begin
  Result := TSWFAS3MethodOptions.Create;
  Options.Add(Result);
  HasOptional := true;
end;

function TSWFAS3Method.GetOption(index: integer): TSWFAS3MethodOptions;
begin
  Result := TSWFAS3MethodOptions(Options[index]);
end;

function TSWFAS3Methods.AddMethod: TSWFAS3Method;
begin
  Result := TSWFAS3Method.Create;
  MethodsList.Add(Result);
end;

constructor TSWFAS3Methods.Create;
begin
  MethodsList := TObjectList.Create;
end;

destructor TSWFAS3Methods.Destroy;
begin
  MethodsList.Free;
  inherited;
end;

function TSWFAS3Methods.GetMethod(index: integer): TSWFAS3Method;
begin
  Result := TSWFAS3Method(MethodsList[index]);
end;

procedure TSWFAS3Methods.ReadFromStream(be: TBitsEngine);
var count, pCount, i1, i2: longint;
    M: TSWFAS3Method;
    Op: TSWFAS3MethodOptions;
    flags: byte;
begin
  count := be.ReadEncodedU32;
  if count > 0 then
  for i1 := 0 to Count - 1 do
  begin
    M := AddMethod;
    pCount := be.ReadEncodedU32;
    M.ReturnType := be.ReadEncodedU32;
    if pCount > 0 then
      for i2 := 0 to pCount - 1 do
        M.ParamTypes.AddInt(be.ReadEncodedU32);
    M.Name := be.ReadEncodedU32;
    flags := be.ReadByte;
    M.NeedArguments := CheckBit(flags, 1);
    M.NeedActivation := CheckBit(flags, 2);
    M.NeedRest := CheckBit(flags, 3);
    M.HasOptional := CheckBit(flags, 4);
    M.SetDxns := CheckBit(flags, 6);
    M.HasParamNames := CheckBit(flags, 8);
    if M.HasOptional then
    begin
      pCount := be.ReadEncodedU32;
      if (pCount > 0) {and (M.ParamTypes.Count > pCount)} then
      for i2 := M.ParamTypes.Count - pCount to M.ParamTypes.Count - 1 do
      begin
        Op := M.AddOption;
        Op.val := be.ReadEncodedU32;
        Op.kind := be.ReadByte;
      end;
    end;
    if M.HasParamNames and (M.ParamTypes.Count > 0) then
    begin
      for i2 := 0 to M.ParamTypes.Count - 1 do
        M.ParamNames.AddInt(be.ReadEncodedU32);
    end;
  end;
end;

procedure TSWFAS3Methods.WriteToStream(be: TBitsEngine);
  var il, il2: integer;
begin
  be.WriteEncodedU32(MethodsList.Count);
  if MethodsList.Count > 0 then
  for il := 0 to MethodsList.Count - 1 do
    with Method[il] do
    begin
      be.WriteEncodedU32(ParamTypes.Count);
      be.WriteEncodedU32(ReturnType);
      if ParamTypes.Count > 0 then
      for il2 := 0 to ParamTypes.Count - 1 do
        be.WriteEncodedU32(ParamTypes.Int[il2]);
      be.WriteEncodedU32(Name);
      be.WriteByte(byte(NeedArguments) + byte(NeedActivation) shl 1 + byte(NeedRest) shl 2 +
                   byte(HasOptional) shl 3 + byte(SetDxns) shl 5 + byte(HasParamNames) shl 7);
      if HasOptional then
      begin
        be.WriteEncodedU32(Options.Count);
        if Options.Count > 0 then
        for il2 := 0 to Options.Count - 1 do
          with Option[il2] do
          begin
            be.WriteEncodedU32(val);
            be.WriteByte(kind);
          end;
      end;

      if HasParamNames and (ParamTypes.Count > 0) then
        for il2 := 0 to ParamTypes.Count - 1 do
          be.WriteEncodedU32(ParamNames.Int[il2]);
    end;
end;

destructor TSWFAS3Trait.Destroy;
begin
  if Assigned(FMetadata) then FreeAndNil(FMetadata);
end;

function TSWFAS3Trait.GetMetadata: TSWFIntegerList;
begin
  if not Assigned(FMetadata) then
  begin
    FMetadata := TSWFIntegerList.Create;
    FIsMetadata := true;
  end;
  Result := FMetadata;
end;

procedure TSWFAS3Trait.ReadFromStream(be: TBitsEngine);
  var b: byte;
      il, icount: integer;
begin
  Name := be.ReadEncodedU32;
  b := Be.ReadByte;
  TraitType := b and 15;
  IsFinal := CheckBit(b, 5);
  IsOverride := CheckBit(b, 6);
  IsMetadata := CheckBit(b, 7);
  ID := be.ReadEncodedU32;
  SpecID := be.ReadEncodedU32;
  if TraitType in [Trait_Slot, Trait_Const] then
  begin
    VIndex := be.ReadEncodedU32;
    if VIndex > 0 then VKind := be.ReadByte;
  end;
  if IsMetadata then
  begin
    icount := be.ReadEncodedU32;
    if icount > 0 then
      for il := 0 to icount - 1 do
        Metadata.AddInt(be.ReadEncodedU32);
  end;

end;

procedure TSWFAS3Trait.SetIsMetadata(const Value: Boolean);
begin
  FIsMetadata := Value;
  if Value then FMetadata := TSWFIntegerList.Create
    else FreeAndNil(FMetadata);
end;

procedure TSWFAS3Trait.WriteToStream(be: TBitsEngine);
begin
  be.WriteEncodedU32(Name);
  be.WriteByte(TraitType + byte(isFinal) shl 4 + byte(IsOverride) shl 5 +
               byte(IsMetadata) shl 6);
  be.WriteEncodedU32(ID);
  be.WriteEncodedU32(SpecID);
  if TraitType in [Trait_Slot, Trait_Const] then
    begin
      be.WriteEncodedU32(VIndex);
      if VIndex > 0 then be.WriteByte(VKind);
    end;
  if IsMetadata then
    Metadata.WriteToStream(be);
end;



{ TSWFAS3Traits }

function TSWFAS3Traits.AddTrait: TSWFAS3Trait;
begin
  Result := TSWFAS3Trait.Create;
  FTraits.Add(Result);
end;

constructor TSWFAS3Traits.Create;
begin
  FTraits := TObjectList.Create;
end;

destructor TSWFAS3Traits.Destroy;
begin
  FTraits.Free;
  inherited;
end;

function TSWFAS3Traits.GetTrait(Index: Integer): TSWFAS3Trait;
begin
  Result := TSWFAS3Trait(FTraits[Index]);
end;

{ TSWFAS3InstanceItem }

constructor TSWFAS3InstanceItem.Create;
begin
  inherited;
  FInterfaces := TSWFIntegerList.Create;
end;

destructor TSWFAS3InstanceItem.Destroy;
begin
  FInterfaces.Free;
  inherited;
end;

procedure TSWFAS3InstanceItem.ReadFromStream(be: TBitsEngine);
 var b: byte;
     icount, i: longint;
     Tr: TSWFAS3Trait;
{$IFDEF DebugAS3}
     mpos: longint;
     ssave: boolean;
{$ENDIF}
begin
  Name := be.ReadEncodedU32;
  SuperName := be.ReadEncodedU32;
  b := be.ReadByte;
  ClassSealed := CheckBit(b, 1);
  ClassFinal := CheckBit(b, 2);
  ClassInterface := CheckBit(b, 3);
  ClassProtectedNs := CheckBit(b, 4);
  if ClassProtectedNs then
    ProtectedNs := be.ReadEncodedU32;
  icount := be.ReadEncodedU32;
  if icount > 0 then
    for i := 0 to iCount - 1 do
      Interfaces.AddInt(be.ReadEncodedU32);

  Iinit := be.ReadEncodedU32;
  icount := be.ReadEncodedU32;
{$IFDEF DebugAS3}
   ssave := false;
{$ENDIF}
  if icount > 0 then
  begin
    for i := 0 to iCount - 1 do
    begin
{$IFDEF DebugAS3}
      mpos := be.BitsStream.Position;
{$ENDIF}
      Tr := TSWFAS3Trait.Create;
      Tr.ReadFromStream(be);
      Traits.Add(Tr);
{$IFDEF DebugAS3}
      if ssave then
      begin
       AddDebugAS3(Format('Traits %d:   name: %d   pos: %d', [i, Tr.Name, mpos]));
       SLDebug.SaveToFile('debugAsS3.txt');
      end;
{$ENDIF}
    end;
  end;

end;

procedure TSWFAS3InstanceItem.WriteToStream(be: TBitsEngine);
 var il: integer;
begin
  be.WriteEncodedU32(Name);
  be.WriteEncodedU32(SuperName);
  be.WriteByte(byte(ClassSealed) + byte(ClassFinal) shl 1 +
               byte(ClassInterface) shl 2 + byte(ClassProtectedNs) shl 3);
  if ClassProtectedNs then
    be.WriteEncodedU32(ProtectedNs);
  Interfaces.WriteToStream(be);
  be.WriteEncodedU32(Iinit);
  be.WriteEncodedU32(Traits.Count);
  if Traits.Count > 0 then
    for il := 0 to Traits.Count - 1 do
      Trait[il].WriteToStream(be);
end;

{ TSWFAS3Instance }

function TSWFAS3Instance.AddInstanceItem: TSWFAS3InstanceItem;
begin
  Result := TSWFAS3InstanceItem.Create;
  Add(Result);
end;

function TSWFAS3Instance.GetInstanceItem(Index: longint): TSWFAS3InstanceItem;
begin
  Result := TSWFAS3InstanceItem(Items[index]);
end;

procedure TSWFAS3Instance.ReadFromStream(Count: Longint; be: TBitsEngine);
  var IItem: TSWFAS3InstanceItem;
      il: longint;
{$IFDEF DebugAS3}
     SL: TStringList;
{$ENDIF}
begin
{$IFDEF DebugAS3}
  SL := TStringList.Create;
{$ENDIF}
  if Count > 0 then
  for il := 0 to Count - 1 do
  begin
{$IFDEF DebugAS3}
  SL.Add(IntToStr(be.BitsStream.Position));
{$ENDIF}
    IItem := TSWFAS3InstanceItem.Create;
    IItem.ReadFromStream(be);
    Add(IItem);
{$IFDEF DebugAS3}
  SL.Add(IntToStr(il)+ ': '+ IntToStr(IItem.Name));
  SL.SaveToFile('D:\_Flash\abc\out\inst_pos.txt');
{$ENDIF}
  end;
{$IFDEF DebugAS3}
  SL.Free;
{$ENDIF}
end;

procedure TSWFAS3Instance.WriteToStream(be: TBitsEngine);
  var il: integer;
begin
  if Count > 0 then
  for il := 0 to Count - 1 do
    InstanceItem[il].WriteToStream(be);
end;

{ TSWFAS3ClassesInfo }

procedure TSWFAS3ClassInfo.ReadFromStream(be: TBitsEngine);
 var il, icount: longint;
     Tr: TSWFAS3Trait;
begin
  CInit := be.ReadEncodedU32;
  icount := be.ReadEncodedU32;
  if icount > 0 then
    for il := 0 to iCount - 1 do
    begin
      Tr := TSWFAS3Trait.Create;
      Tr.ReadFromStream(be);
      Traits.Add(Tr);
    end;
end;


procedure TSWFAS3ClassInfo.WriteToStream(be: TBitsEngine);
  var il: integer;
begin
  be.WriteEncodedU32(CInit);
  be.WriteEncodedU32(Traits.Count);
  if Traits.Count > 0 then
    for il := 0 to Traits.Count - 1 do
      Trait[il].WriteToStream(be);
end;

{ TSWFAS3Classes }

function TSWFAS3Classes.AddClassInfo: TSWFAS3ClassInfo;
begin
  Result := TSWFAS3ClassInfo.Create;
  Add(Result);
end;

function TSWFAS3Classes.GetClassInfo(Index: Integer): TSWFAS3ClassInfo;
begin
  Result := TSWFAS3ClassInfo(Items[index]);
end;

procedure TSWFAS3Classes.ReadFromStream(rcount: longInt; be: TBitsEngine);
 var il: integer;
     CI: TSWFAS3ClassInfo;
begin
  for il :=0 to rCount - 1 do
  begin
    CI := TSWFAS3ClassInfo.Create;
    CI.ReadFromStream(be);
    Add(CI);
  end;
end;

procedure TSWFAS3Classes.WriteToStream(be: TBitsEngine);
  var il: integer;
begin
  if Count > 0 then
  for il := 0 to Count - 1 do
    _ClassInfo[il].WriteToStream(be);
end;

{ TSWFAS3Scripts }

function TSWFAS3Scripts.AddScriptInfo: TSWFAS3ScriptInfo;
begin
  Result := TSWFAS3ScriptInfo.Create;
  Add(Result);
end;

function TSWFAS3Scripts.GetScriptInfo(Index: Integer): TSWFAS3ScriptInfo;
begin
  Result := TSWFAS3ScriptInfo(Items[Index]);
end;

procedure TSWFAS3Scripts.ReadFromStream(be: TBitsEngine);
 var il, iCount: longint;
     SI: TSWFAS3ScriptInfo;
begin
  iCount := be.ReadEncodedU32;
  for il :=0 to iCount - 1 do
  begin
    SI := TSWFAS3ScriptInfo.Create;
    SI.ReadFromStream(be);
    Add(SI);
  end;

end;

procedure TSWFAS3Scripts.WriteToStream(be: TBitsEngine);
  var il: integer;
begin
  be.WriteEncodedU32(Count);
  if Count > 0 then
  for il := 0 to Count - 1 do
    ScriptInfo[il].WriteToStream(be);
end;

{ TSWFAS3MethodBodyInfo }

function TSWFAS3MethodBodyInfo.AddException: TSWFAS3Exception;
begin
 Result := TSWFAS3Exception.Create;
 FExceptions.Add(Result);
end;

constructor TSWFAS3MethodBodyInfo.Create;
begin
  inherited;
  FCode := TMemoryStream.Create;
  FExceptions := TObjectList.Create;
end;

destructor TSWFAS3MethodBodyInfo.Destroy;
begin
  FExceptions.Free;
  FCode.Free;
  inherited;
end;

function TSWFAS3MethodBodyInfo.GetCodeItem(Index: Integer): byte;
  var PB: PByte;
begin
  PB := FCode.Memory;
  if Index > 0 then Inc(PB, Index);
  Result := PB^;
end;

function TSWFAS3MethodBodyInfo.GetException(Index: Integer): TSWFAS3Exception;
begin
  Result := TSWFAS3Exception(FExceptions[Index]);
end;

procedure TSWFAS3MethodBodyInfo.ReadFromStream(be: TBitsEngine);
 var icount, il: longint;
     Tr: TSWFAS3Trait;
     Exc: TSWFAS3Exception;
begin
  Method := be.ReadEncodedU32;
  MaxStack := be.ReadEncodedU32;
  LocalCount := be.ReadEncodedU32;
  InitScopeDepth := be.ReadEncodedU32;
  MaxScopeDepth := be.ReadEncodedU32;
  icount := be.ReadEncodedU32;
  FCode.CopyFrom(Be.BitsStream, icount);
  icount := be.ReadEncodedU32;
  if icount > 0 then
    for il := 0 to iCount - 1 do
    begin
      Exc := TSWFAS3Exception.Create;
      Exc.From := be.ReadEncodedU32;
      Exc._To := be.ReadEncodedU32;
      Exc.Target := be.ReadEncodedU32;
      Exc.ExcType := be.ReadEncodedU32;
      Exc.VarName := be.ReadEncodedU32;
      FExceptions.Add(Exc);
    end;
  icount := be.ReadEncodedU32;
  if icount > 0 then
    for il := 0 to iCount - 1 do
    begin
      Tr := TSWFAS3Trait.Create;
      Tr.ReadFromStream(be);
      Traits.Add(Tr);
    end;
end;

procedure TSWFAS3MethodBodyInfo.SetCodeItem(Index: Integer; const Value: byte);
  var PB: PByte;
begin
  PB := FCode.Memory;
  if Index > 0 then Inc(PB, Index);
  PB^ := Value;
end;

procedure TSWFAS3MethodBodyInfo.SetStrByteCode(Value: AnsiString);
var
  L, il: Word;
  s2: string[2];
  P: PByte;
begin
  L := Length(Value) div 2;
  Code.SetSize(L);
  if L > 0 then
   begin
     s2 := '  ';
     P := Code.Memory;
     for il := 0 to L - 1 do
      begin
        s2[1] := Value[il*2 + 1];
        s2[2] := Value[il*2 + 2];
        P^ := StrToInt('$'+ s2);
        Inc(P);
      end;
   end;
end;

function TSWFAS3MethodBodyInfo.GetStrByteCode: ansistring;
  var il: longint;
      PB: PByte;
begin
  Result := '';
  PB := FCode.Memory;
  for il := 0 to FCode.Size - 1 do
  begin
    Result := Result + IntToHex(PB^, 2);
    inc(PB);
  end; 
end;

procedure TSWFAS3MethodBodyInfo.WriteToStream(be: TBitsEngine);
 var il: integer;
begin
  be.WriteEncodedU32(Method);
  be.WriteEncodedU32(MaxStack);
  be.WriteEncodedU32(LocalCount);
  be.WriteEncodedU32(InitScopeDepth);
  be.WriteEncodedU32(MaxScopeDepth);
  Code.Position := 0;
  be.WriteEncodedU32(Code.Size);
  Be.BitsStream.CopyFrom(Code, Code.Size);

  be.WriteEncodedU32(Exceptions.Count);
  if Exceptions.Count > 0 then
    for il := 0 to Exceptions.Count - 1 do
    with Exception[il] do
    begin
      be.WriteEncodedU32(From);
      be.WriteEncodedU32(_To);
      be.WriteEncodedU32(Target);
      be.WriteEncodedU32(ExcType);
      be.WriteEncodedU32(VarName);
    end;
    
  be.WriteEncodedU32(Traits.Count);
  if Traits.Count > 0 then
    for il := 0 to Traits.Count - 1 do
      Trait[il].WriteToStream(be);
end;

{ TSWFAS3MethodBodies }

function TSWFAS3MethodBodies.AddMethodBodyInfo: TSWFAS3MethodBodyInfo;
begin
  Result := TSWFAS3MethodBodyInfo.Create;
  Add(Result);
end;

function TSWFAS3MethodBodies.GetClassInfo(Index: Integer): TSWFAS3MethodBodyInfo;
begin
  Result := TSWFAS3MethodBodyInfo(Items[Index]);
end;

procedure TSWFAS3MethodBodies.ReadFromStream(be: TBitsEngine);
var il, iCount: longint;
    MB: TSWFAS3MethodBodyInfo;
begin
  iCount := be.ReadEncodedU32;
  for il := 0 to iCount - 1 do
  begin
    MB := TSWFAS3MethodBodyInfo.Create;
    MB.ReadFromStream(be);
    Add(MB);
  end;
end;

procedure TSWFAS3MethodBodies.WriteToStream(be: TBitsEngine);
var il: integer;
begin
  be.WriteEncodedU32(Count);
  if Count > 0 then
    for il := 0 to Count - 1 do
      MethodBodyInfo[il].WriteToStream(be);
end;

{*************************************************** TSWFDoABC ***************************************************}

constructor TSWFDoABC.Create;
begin
  TagID := tagDoABC;
  FConstantPool := TSWFAS3ConstantPool.Create;
  FMethods := TSWFAS3Methods.Create;
  FMetadata := TSWFAS3Metadata.Create;
  FInstance := TSWFAS3Instance.Create;
  FClasses := TSWFAS3Classes.Create;
  FScripts := TSWFAS3Scripts.Create;
  FMethodBodies := TSWFAS3MethodBodies.Create;
end;

destructor TSWFDoABC.Destroy;
begin
  if SelfDestroy and (DataSize > 0) then FreeMem(FData, DataSize);
  FMethodBodies.Free;
  FScripts.Free;
  FClasses.Free;
  FInstance.Free;
  FMetadata.Free;
  FMethods.Free;
  FConstantPool.Free;
  inherited;
end;

function TSWFDoABC.GetClasses: TSWFAS3Classes;
begin
  Result := FClasses;
end;

function TSWFDoABC.GetInstance: TSWFAS3Instance;
begin
  Result := FInstance;
end;

function TSWFDoABC.GetMetadata: TSWFAS3Metadata;
begin
  Result := FMetadata;
end;

function TSWFDoABC.GetMethodBodies: TSWFAS3MethodBodies;
begin
  Result := FMethodBodies;
end;

function TSWFDoABC.GetMethods: TSWFAS3Methods;
begin
  Result := FMethods;
end;

function TSWFDoABC.GetScripts: TSWFAS3Scripts;
begin
  Result := FScripts;
end;

function TSWFDoABC.GetStrVersion: string;
begin
  Result := Format('%d.%d.%d.%d', [HiByte(MajorVersion), LoByte(MajorVersion),
                                   HiByte(MinorVersion), LoByte(MinorVersion)]);
end;

function TSWFDoABC.MinVersion: Byte;
begin
  Result := SWFVer9;
end;

procedure TSWFDoABC.ReadFromStream(be: TBitsEngine);
 var
     b: byte;
     Pos: Longint;
     CClass: Longint;
begin
  Pos := BE.BitsStream.Position;

  b := be.ReadByte;
  be.ReadByte;  // reserved
  be.ReadWord; // reserved
  DoAbcLazyInitializeFlag := CheckBit(b, 1);

  FActionName := be.ReadString();
  be.BitsStream.Seek(-1, 1); //soFromCurrent

  MinorVersion := be.ReadWord;
  MajorVersion := be.ReadWord;

  if ParseActions then
  begin
    ConstantPool.ReadFromStream(be);
    Methods.ReadFromStream(be);
    Metadata.ReadFromStream(be);
    CClass := be.ReadEncodedU32;
    Instance.ReadFromStream(CClass, be);
    Classes.ReadFromStream(CClass, be);
    Scripts.ReadFromStream(be);
    MethodBodies.ReadFromStream(be);
  {$IFDEF DebuagAS3}
  //  BE.BitsStream.Position := Pos{ + 8};
  //  FS := TFileStream.Create('DoABC.dat', fmCreate);
  //  FS.CopyFrom(BE.BitsStream, BodySize {- 8});
  //  FS.Free;
  {$ENDIF}
  end else
  begin
    DataSize := BodySize - (BE.BitsStream.Position - Pos);
    GetMem(FData, DataSize);
    be.BitsStream.Read(FData^, DataSize);
    SelfDestroy := true;
  end;
end;

procedure TSWFDoABC.SetStrVersion(ver: string);
  var b: array [0..3] of byte;
      il, ib, start: byte;
      subs: string;
begin
  try
    ib := 0;
    start := 1;
    for il := 1 to length(ver) do
      if (ver[il] = '.') or (il = length(ver)) then
      begin
        subs := Copy(ver, start, il - start + 1 * byte(il = length(ver)));
        start := il + 1;
        b[ib] := StrToInt(subs);
        inc(ib);
      end;
      
    MajorVersion := b[0] shl 8 + b[1];
    MinorVersion := b[2] shl 8 + b[3];
  except
    MajorVersion := 46 shl 8;
    MinorVersion := 16 shl 8;
  end;
end;

procedure TSWFDoABC.WriteTagBody(be: TBitsEngine);
begin
  be.WriteByte(byte(DoAbcLazyInitializeFlag));
  be.WriteByte(0);
  be.WriteWord(0);

  if ActionName <> '' then
    be.WriteString(ActionName, false);
  be.WriteWord(MinorVersion);
  be.WriteWord(MajorVersion);

  if SelfDestroy and (DataSize > 0) then
  begin
    be.BitsStream.Write(Data^, DataSize);

  end else
  begin
    ConstantPool.WriteToStream(be);
    Methods.WriteToStream(be);
    Metadata.WriteToStream(be);
    be.WriteEncodedU32(Classes.Count);
    Instance.WriteToStream(be);
    Classes.WriteToStream(be);
    Scripts.WriteToStream(be);
    MethodBodies.WriteToStream(be);
  end;
end;



// ===========================================================
//                       Display List
// ===========================================================
{
*************************************************** TSWFBasedPlaceObject ****************************************************
}
procedure TSWFBasedPlaceObject.Assign(Source: TBasedSWFObject);
begin
  inherited;
  With TSWFBasedPlaceObject(Source) do
  begin
    self.FCharacterId := CharacterId;
    self.Depth := Depth;
  end;
end;

procedure TSWFBasedPlaceObject.SetCharacterId(ID: Word);
begin
  FCharacterId := ID;
end;

{
****************************************************** TSWFPlaceObject ******************************************************
}
constructor TSWFPlaceObject.Create;
begin
  inherited;
  TagID := tagPlaceObject;
  FColorTransform := TSWFColorTransform.Create;
  ColorTransform.hasAlpha := false;
  FMatrix := TSWFMatrix.Create;
end;

destructor TSWFPlaceObject.Destroy;
begin
  FColorTransform.Free;
  FMatrix.Free;
  inherited Destroy;
end;

procedure TSWFPlaceObject.Assign(Source: TBasedSWFObject);
begin
  inherited;
  With TSWFPlaceObject(Source) do
  begin
    if InitColorTransform then self.ColorTransform.REC := ColorTransform.REC;

    Self.Matrix.Assign(Matrix);

  end;
end;

function TSWFPlaceObject.GetInitColorTransform: Boolean;
begin
  Result := FInitColorTransform or ColorTransform.hasAdd or ColorTransform.hasMult;
end;

procedure TSWFPlaceObject.ReadFromStream(be: TBitsEngine);
var
  PP: LongInt;
begin
  PP := be.BitsStream.Position;
  CharacterId := be.ReadWord;
  Depth := be.ReadWord;
  Matrix.Rec := be.ReadMatrix;
  initColorTransform := (be.BitsStream.Position - PP) < BodySize;
  if initColorTransform then
   ColorTransform.REC := be.ReadColorTransform(false);
end;

procedure TSWFPlaceObject.WriteTagBody(be: TBitsEngine);
begin
  be.WriteWord(CharacterId);
  be.WriteWord(Depth);
  be.WriteMatrix(Matrix.Rec);
  if initColorTransform then be.WriteColorTransform(ColorTransform.REC);
end;


{
*************************************************** TSWFClipActionRecord ****************************************************
}

procedure TSWFClipActionRecord.Assign(Source: TSWFClipActionRecord);
begin
  KeyCode := Source.KeyCode;
  EventFlags := Source.EventFlags;
  CopyActionList(Source, self);
end;

{
function TSWFClipActionRecord.GetAction(Index: Integer): TSWFAction;
begin
  Result := TSWFAction(FActions[index]);
end;
}
function TSWFClipActionRecord.GetActions: TSWFActionList;
begin
  Result := self
end;

procedure TSWFClipActionRecord.SetKeyCode(Value: Byte);
begin
  FKeyCode := Value;
  if Value = 0 then Exclude(FEventFlags, ceKeyPress)
    else Include(FEventFlags, ceKeyPress);
end;

{
****************************************************** TSWFClipActions ******************************************************
}
constructor TSWFClipActions.Create;
begin
  FActionRecords := TObjectList.Create;
end;

destructor TSWFClipActions.Destroy;
begin
  FActionRecords.Free;
  inherited Destroy;
end;

function TSWFClipActions.AddActionRecord(EventFlags: TSWFClipEvents; KeyCode: byte): TSWFClipActionRecord;
begin
  Result := TSWFClipActionRecord.Create;
  Result.EventFlags := EventFlags;
  Result.KeyCode := KeyCode;
  if KeyCode > 0 then Include(Result.FEventFlags, ceKeyPress);
  ActionRecords.Add(Result);
  AllEventFlags := AllEventFlags + EventFlags;
end;

procedure TSWFClipActions.Assign(Source: TSWFClipActions);
var
  il: Word;
  CA: TSWFClipActionRecord;
begin
  AllEventFlags := Source.AllEventFlags;
  if Source.ActionRecords.Count > 0 then
   for il := 0 to Source.ActionRecords.Count - 1 do
    begin
      With Source.ActionRecord[il] do
        CA := self.AddActionRecord(EventFlags, KeyCode);
      CA.Assign(Source.ActionRecord[il]);
    end;
end;

function TSWFClipActions.Count: integer;
begin
  Result := ActionRecords.Count;
end;

function TSWFClipActions.GetActionRecord(Index: Integer): TSWFClipActionRecord;
begin
  Result := TSWFClipActionRecord(ActionRecords[index]);
end;

{
***************************************************** TSWFPlaceObject2 ******************************************************
}
constructor TSWFPlaceObject2.Create;
begin
  TagID := tagPlaceObject2;
  SWFVersion := SWFVer3;
end;

destructor TSWFPlaceObject2.Destroy;
begin
  if FMatrix <> nil then FMatrix.Free;
  if fClipActions <> nil then fClipActions.Free;
  if FColorTransform <> nil then FColorTransform.Free;
end;

procedure TSWFPlaceObject2.Assign(Source: TBasedSWFObject);
begin
  inherited;
  With TSWFPlaceObject2(Source) do
  begin
    if PlaceFlagHasCharacter then Self.CharacterId := CharacterId
      else self.PlaceFlagHasCharacter := false;
    if PlaceFlagHasClipDepth then Self.ClipDepth := ClipDepth
      else self.PlaceFlagHasClipDepth := false;
    if PlaceFlagHasRatio then Self.Ratio := Ratio
      else self.PlaceFlagHasRatio := false;
    if PlaceFlagHasName then Self.Name := Name
      else self.PlaceFlagHasName := false;
    if PlaceFlagHasMatrix then Self.Matrix.Assign(Matrix)
      else self.PlaceFlagHasMatrix := false;
    self.PlaceFlagMove := PlaceFlagMove;
    self.SWFVersion := SWFVersion;
    if PlaceFlagHasColorTransform then Self.ColorTransform.REC := ColorTransform.REC
      else self.PlaceFlagHasColorTransform := false;
  
    if PlaceFlagHasClipActions then
        self.ClipActions.Assign(ClipActions);
  end;
end;

function TSWFPlaceObject2.ClipActions: TSWFClipActions;
begin
  if fClipActions = nil then
    begin
      fClipActions := TSWFClipActions.Create;
      PlaceFlagHasClipActions := true;
    end;
  Result := fClipActions;
end;

function TSWFPlaceObject2.GetColorTransform: TSWFColorTransform;
begin
  if FColorTransform = nil then
    begin
     FColorTransform := TSWFColorTransform.Create;
     FColorTransform.hasAlpha := true;
    end;
  PlaceFlagHasColorTransform := true;
  Result := FColorTransform;
end;

function TSWFPlaceObject2.GetMatrix: TSWFMatrix;
begin
  if FMatrix = nil then FMatrix := TSWFMatrix.Create;
  Result := FMatrix;
  PlaceFlagHasMatrix := true;
end;

function TSWFPlaceObject2.MinVersion: Byte;
begin
  Result := SWFVer3;
  if PlaceFlagHasClipActions then
    begin
      Result := SWFVer5;
      if Result < SWFVersion then Result := SWFVersion;
    end;
end;

procedure TSWFPlaceObject2.ReadFromStream(be: TBitsEngine);
var
  PP: LongInt;
  DW, ActionRecordSize: DWord;
  b: Byte;
//  w: Word;
  AR: TSWFClipActionRecord;
  BA: TSWFActionByteCode;
  
  procedure fReadEventFlags(var EF: TSWFClipEvents; RW: dword);
   var ab: array[0..3] of byte;
  begin
    Move(RW, ab, 4);
    EF := [];
  
    if CheckBit(ab[0], 8) then Include(EF, ceKeyUp);
    if CheckBit(ab[0], 7) then Include(EF, ceKeyDown);
    if CheckBit(ab[0], 6) then Include(EF, ceMouseUp);
    if CheckBit(ab[0], 5) then Include(EF, ceMouseDown);
    if CheckBit(ab[0], 4) then Include(EF, ceMouseMove);
    if CheckBit(ab[0], 3) then Include(EF, ceUnload);
    if CheckBit(ab[0], 2) then Include(EF, ceEnterFrame);
    if CheckBit(ab[0], 1) then Include(EF, ceLoad);
  
    if CheckBit(ab[1], 8) then Include(EF, ceDragOver);
    if CheckBit(ab[1], 7) then Include(EF, ceRollOut);
    if CheckBit(ab[1], 6) then Include(EF, ceRollOver);
    if CheckBit(ab[1], 5) then Include(EF, ceReleaseOutside);
    if CheckBit(ab[1], 4) then Include(EF, ceRelease);
    if CheckBit(ab[1], 3) then Include(EF, cePress);
    if CheckBit(ab[1], 2) then Include(EF, ceInitialize);
    if CheckBit(ab[1], 1) then Include(EF, ceData);
  
    if SWFVersion >= SWFVer6 then
      begin
       if CheckBit(ab[2], 3) then Include(EF, ceConstruct);
       if CheckBit(ab[2], 2) then Include(EF, ceKeyPress);
       if CheckBit(ab[2], 1) then Include(EF, ceDragOut);
      end;
  end;
  
begin
  PP := be.BitsStream.Position;
  b := be.ReadByte;
  PlaceFlagMove := (b and 1) = 1;              b := b shr 1;
  PlaceFlagHasCharacter := (b and 1) = 1;      b := b shr 1;
  PlaceFlagHasMatrix := (b and 1) = 1;         b := b shr 1;
  PlaceFlagHasColorTransform := (b and 1) = 1; b := b shr 1;
  PlaceFlagHasRatio := (b and 1) = 1;          b := b shr 1;
  PlaceFlagHasName := (b and 1) = 1;           b := b shr 1;
  PlaceFlagHasClipDepth := (b and 1) = 1;      b := b shr 1;
  PlaceFlagHasClipActions  := (b and 1) = 1;
  ReadAddonFlag(be);
  Depth := be.ReadWord;
  if PlaceFlagHasCharacter then CharacterId := be.ReadWord;
  if PlaceFlagHasMatrix then Matrix.Rec := be.ReadMatrix;
  if PlaceFlagHasColorTransform then ColorTransform.REC := be.ReadColorTransform;
  if PlaceFlagHasRatio then Ratio := be.ReadWord;
  if PlaceFlagHasName then Name := be.ReadString;
  if PlaceFlagHasClipDepth then ClipDepth := be.ReadWord;
  ReadFilterFromStream(be);
  if PlaceFlagHasClipActions then
    begin
     {W :=} be.ReadWord;
     if SWFVersion >= SWFVer6 then DW := be.ReadDWord else DW := be.ReadWord;
     fReadEventFlags(ClipActions.fAllEventFlags, DW);
     if (be.BitsStream.Position - PP) < BodySize then
     Repeat
       if SWFVersion >= SWFVer6 then DW := be.ReadDWord else DW := be.ReadWord;
       if (DW > 0) then
         begin
           AR := TSWFClipActionRecord.Create;
           fReadEventFlags(AR.FEventFlags, DW);
           ActionRecordSize := be.ReadDWord;
           if ceKeyPress in AR.EventFlags then
             AR.KeyCode := be.ReadByte;
           if ParseActions then
             ReadActionList(be, AR, ActionRecordSize)
            else
             begin
              BA := TSWFActionByteCode.Create;
              BA.DataSize := ActionRecordSize;
              BA.SelfDestroy := true;
              GetMem(BA.fData, BA.DataSize);
              be.BitsStream.Read(BA.Data^, BA.DataSize);
              AR.Add(BA);
             end;
           ClipActions.ActionRecords.Add(AR);

         end;
     Until DW = 0;
     if ClipActions.ActionRecords.Count = 0 then PlaceFlagHasClipActions := false;
    end;
  if BodySize > (be.BitsStream.Position - PP) then
     be.BitsStream.Position := integer(BodySize) + PP;
end;

procedure TSWFPlaceObject2.SetCharacterId(Value: Word);
begin
  FCharacterId := value;
  PlaceFlagHasCharacter := true;
end;

procedure TSWFPlaceObject2.SetClipDepth(Value: Word);
begin
  FClipDepth := value;
  PlaceFlagHasClipDepth := true;
end;

procedure TSWFPlaceObject2.SetName(Value: string);
begin
  FName := Value;
  PlaceFlagHasName := Value<>'';
end;

procedure TSWFPlaceObject2.SetRatio(Value: Word);
begin
  FRatio := Value;
  PlaceFlagHasRatio := true;
end;

procedure TSWFPlaceObject2.WriteTagBody(be: TBitsEngine);
var
  il, il2: Word;
  Offset, Adr: LongInt;
  write0, tmpPlaceAction: boolean;

  procedure fWriteEventFlags(EF: TSWFClipEvents);
  begin
    be.WriteBit(ceKeyUp in EF);
    be.WriteBit(ceKeyDown in EF);
    be.WriteBit(ceMouseUp in EF);
    be.WriteBit(ceMouseDown in EF);
    be.WriteBit(ceMouseMove in EF);
    be.WriteBit(ceUnload in EF);
    be.WriteBit(ceEnterFrame in EF);
    be.WriteBit(ceLoad in EF);

    be.WriteBit(ceDragOver in EF);
    be.WriteBit(ceRollOut in EF);
    be.WriteBit(ceRollOver in EF);
    be.WriteBit(ceReleaseOutside in EF);
    be.WriteBit(ceRelease in EF);
    be.WriteBit(cePress in EF);
    be.WriteBit(ceInitialize in EF);
    be.WriteBit(ceData in EF);

    if SWFVersion >= SWFVer6 then
      begin
       be.WriteBits(0, 5);
       be.WriteBit(ceConstruct in EF);
       be.WriteBit(ceKeyPress in EF);
       be.WriteBit(ceDragOut in EF);
       be.WriteByte(0);
      end;
  end;

begin
  tmpPlaceAction := PlaceFlagHasClipActions and (ClipActions.ActionRecords.Count > 0);
  be.WriteBit(tmpPlaceAction);
  be.WriteBit(PlaceFlagHasClipDepth);
  be.WriteBit(PlaceFlagHasName);
  be.WriteBit(PlaceFlagHasRatio);
  be.WriteBit(PlaceFlagHasColorTransform);
  be.WriteBit(PlaceFlagHasMatrix);
  be.WriteBit(PlaceFlagHasCharacter);
  be.WriteBit(PlaceFlagMove);
  WriteAddonFlag(be);
  be.WriteWord(Depth);
  if PlaceFlagHasCharacter then be.WriteWord(CharacterId);
  if PlaceFlagHasMatrix then be.WriteMatrix(Matrix.Rec);
  if PlaceFlagHasColorTransform then be.WriteColorTransform(ColorTransform.REC);
  if PlaceFlagHasRatio then be.WriteWord(Ratio);
  if PlaceFlagHasName then be.WriteString(Name);
  if PlaceFlagHasClipDepth then be.WriteWord(ClipDepth);
  WriteFilterToStream(be);
  if tmpPlaceAction then
    begin
      if SWFVersion < MinVersion then SWFVersion := MinVersion;
      be.WriteWord(0);
      fWriteEventFlags(ClipActions.AllEventFlags);
      if ClipActions.ActionRecords.Count > 0 then
       begin
        for il:= 0 to ClipActions.ActionRecords.Count - 1 do
         with ClipActions.ActionRecord[il] do
         begin
           fWriteEventFlags(EventFlags);
           Offset := be.BitsStream.Position;
           be.WriteDWord(0);
           if ceKeyPress in EventFlags then be.WriteByte(KeyCode);
           if Count > 0 then
            begin
             For il2 := 0 to Count - 1 do
               Action[il2].WriteToStream(be);
             case Action[Count - 1].ActionCode of
               0, actionOffsetWork: write0 := false;
               actionByteCode:
                 with TSWFActionByteCode(Action[Count - 1]) do
                  if DataSize = 0 then write0 := true
                    else write0 := ByteCode[DataSize - 1] <> 0;
               else write0 := true;
             end;
             if write0 then be.WriteByte(0);
            end else be.WriteByte(0);

           Adr := be.BitsStream.Position;
           be.BitsStream.Position := Offset;
           Offset := Adr - Offset - 4;
           be.BitsStream.Write(Offset, 4);
           be.BitsStream.Position := Adr;
          end;
        if SWFVersion >= SWFVer6 then be.WriteDWord(0) else be.WriteWord(0);
       end;
   //  ClipActions: TSWFClipActions;
    end;
end;

procedure TSWFPlaceObject2.ReadFilterFromStream(be: TBitsEngine);
begin
 // empty
end;

procedure TSWFPlaceObject2.ReadAddonFlag(be: TBitsEngine);
begin
 // empty
end;

procedure TSWFPlaceObject2.WriteAddonFlag(be: TBitsEngine);
begin
 // empty
end;

procedure TSWFPlaceObject2.WriteFilterToStream(be: TBitsEngine);
begin
 // empty
end;


{
***************************************************** TSWFColorMatrixFilter ******************************************************
}
constructor TSWFColorMatrixFilter.Create;
begin
 FFilterID := fidColorMatrix;
end;

procedure TSWFColorMatrixFilter.AdjustColor(Brightness, Contrast, Saturation, Hue: Integer);
 var Value: integer;
     lumR, lumG, lumB,
     cosVal, sinVal, X: single;
     FArray: Array [0..24] of single;

 const
  AContrast: array [0..100] of single = (
		0,    0.01, 0.02, 0.04, 0.05, 0.06, 0.07, 0.08, 0.1,  0.11,
		0.12, 0.14, 0.15, 0.16, 0.17, 0.18, 0.20, 0.21, 0.22, 0.24,
		0.25, 0.27, 0.28, 0.30, 0.32, 0.34, 0.36, 0.38, 0.40, 0.42,
		0.44, 0.46, 0.48, 0.5,  0.53, 0.56, 0.59, 0.62, 0.65, 0.68,
		0.71, 0.74, 0.77, 0.80, 0.83, 0.86, 0.89, 0.92, 0.95, 0.98,
		1.0,  1.06, 1.12, 1.18, 1.24, 1.30, 1.36, 1.42, 1.48, 1.54,
		1.60, 1.66, 1.72, 1.78, 1.84, 1.90, 1.96, 2.0,  2.12, 2.25,
		2.37, 2.50, 2.62, 2.75, 2.87, 3.0,  3.2,  3.4,  3.6,  3.8,
		4.0,  4.3,  4.7,  4.9,  5.0,  5.5,  6.0,  6.5,  6.8,  7.0,
		7.3,  7.5,  7.8,  8.0,  8.4,  8.7,  9.0,  9.4,  9.6,  9.8,
		10.0);

 procedure FCheckValue(V: integer; Max: byte);
 begin
   if V < -Max then Value := - Max else
    if V > Max then Value := Max else Value := V;
 end;

 procedure MultMatrix(A: Array of single);
  var i, j, k: byte;
      col: array [0..4] of single;
      V: single;
 begin
  for i := 0 to 4 do
   begin
			for j := 0 to 4 do
				col[j] := FArray[j+i*5];

			for j :=0 to 4 do
       begin
				V := 0;
				for k := 0 to 4 do
					V := V + A[j+k*5]*col[k];

				FArray[j+i*5] := V;
			 end;
	 end;

 end;

begin
  ResetValues;

  FillChar(FArray, SizeOf(FArray), 0);
  FArray[0] := 1;
  FArray[6] := 1;
  FArray[12] := 1;
  FArray[18] := 1;
  FArray[24] := 1;

  if Hue <> 0 then
    begin
      FCheckValue(Hue, 180);
      cosVal := cos(Value / 180 * PI);
      sinVal := sin(Value / 180 * PI);
      lumR := 0.213;
		  lumG := 0.715;
		  lumB := 0.072;
      MultMatrix([
        lumR+cosVal*(1-lumR)+sinVal*(-lumR),lumG+cosVal*(-lumG)+sinVal*(-lumG),lumB+cosVal*(-lumB)+sinVal*(1-lumB),0,0,
        lumR+cosVal*(-lumR)+sinVal*(0.143),lumG+cosVal*(1-lumG)+sinVal*(0.140),lumB+cosVal*(-lumB)+sinVal*(-0.283),0,0,
        lumR+cosVal*(-lumR)+sinVal*(-(1-lumR)),lumG+cosVal*(-lumG)+sinVal*(lumG),lumB+cosVal*(1-lumB)+sinVal*(lumB),0,0,
        0,0,0,1,0,
        0,0,0,0,1]);
    end;

  if Contrast <> 0 then
    begin
      FCheckValue(Contrast, 100);
      if Value < 0 then X := 127 + Value/100*127
		   else
       begin
         X := Value mod 1;
         if (X = 0)
          then
           X := AContrast[Round(Value)]
          else
           X := AContrast[Trunc(Value)]*(1-X) + AContrast[Trunc(Value)+1]*X;
         X := X*127 + 127;
       end;
      MultMatrix([
        X/127,0,0,0,0.5*(127-X),
        0,X/127,0,0,0.5*(127-X),
        0,0,X/127,0,0.5*(127-X),
        0,0,0,1,0,
        0,0,0,0,1]);
    end;

  if Brightness <> 0 then
    begin
      FCheckValue(Brightness, 100);
      MultMatrix([
        1,0,0,0,Value,
        0,1,0,0,Value,
        0,0,1,0,Value,
        0,0,0,1,0,
        0,0,0,0,1]);
    end;

  if Saturation <> 0 then
    begin
      FCheckValue(Saturation, 100);
      if (Value > 0)
        then
          X := 1+ 3*Value/100
        else
          X := Value/100 + 1;
		  lumR := 0.3086;
		  lumG := 0.6094;
		  lumB := 0.0820;
      MultMatrix([
        lumr*(1-x)+x,lumg*(1-x),lumb*(1-x),0,0,
        lumr*(1-x),lumg*(1-x)+x,lumb*(1-x),0,0,
        lumr*(1-x),lumg*(1-x),lumb*(1-x)+x,0,0,
        0,0,0,1,0,
        0,0,0,0,1]);
    end;

  Move(FArray, FMatrix, SizeOf(FMatrix));
end;

procedure TSWFColorMatrixFilter.Assign(Source: TSWFFilter);
 var il: byte;
begin
 with TSWFColorMatrixFilter(Source) do
  for il := 0 to 19 do
   self.Matrix[il] := Matrix[il];
end;

function TSWFColorMatrixFilter.GetMatrix(Index: Integer): single;
begin
 Result := FMatrix[index];
end;

function TSWFColorMatrixFilter.GetR0: single;
begin
 Result := FMatrix[0];
end;

function TSWFColorMatrixFilter.GetR1: single;
begin
 Result := FMatrix[1];
end;

function TSWFColorMatrixFilter.GetR2: single;
begin
 Result := FMatrix[2];
end;

function TSWFColorMatrixFilter.GetR3: single;
begin
 Result := FMatrix[3];
end;

function TSWFColorMatrixFilter.GetR4: single;
begin
 Result := FMatrix[4];
end;

function TSWFColorMatrixFilter.GetG0: single;
begin
 Result := FMatrix[5];
end;

function TSWFColorMatrixFilter.GetG1: single;
begin
 Result := FMatrix[6];
end;

function TSWFColorMatrixFilter.GetG2: single;
begin
 Result := FMatrix[7];
end;

function TSWFColorMatrixFilter.GetG3: single;
begin
 Result := FMatrix[8];
end;

function TSWFColorMatrixFilter.GetG4: single;
begin
 Result := FMatrix[9];
end;

function TSWFColorMatrixFilter.GetB0: single;
begin
 Result := FMatrix[10];
end;

function TSWFColorMatrixFilter.GetB1: single;
begin
 Result := FMatrix[11];
end;

function TSWFColorMatrixFilter.GetB2: single;
begin
 Result := FMatrix[12];
end;

function TSWFColorMatrixFilter.GetB3: single;
begin
 Result := FMatrix[13];
end;

function TSWFColorMatrixFilter.GetB4: single;
begin
 Result := FMatrix[14];
end;

function TSWFColorMatrixFilter.GetA0: single;
begin
 Result := FMatrix[15];
end;

function TSWFColorMatrixFilter.GetA1: single;
begin
 Result := FMatrix[16];
end;

function TSWFColorMatrixFilter.GetA2: single;
begin
 Result := FMatrix[17];
end;

function TSWFColorMatrixFilter.GetA3: single;
begin
 Result := FMatrix[18];
end;

function TSWFColorMatrixFilter.GetA4: single;
begin
 Result := FMatrix[19];
end;

procedure TSWFColorMatrixFilter.ReadFromStream(be: TBitsEngine);
 var il: byte;
begin
  for il := 0 to 19 do
   Matrix[il] := be.ReadFloat;
end;

procedure TSWFColorMatrixFilter.SetMatrix(Index: Integer; const Value: single);
begin
 FMatrix[index] := Value;
end;

procedure TSWFColorMatrixFilter.SetR0(const Value: single);
begin
 FMatrix[0] := Value;
end;

procedure TSWFColorMatrixFilter.SetR1(const Value: single);
begin
 FMatrix[1] := Value;
end;

procedure TSWFColorMatrixFilter.SetR2(const Value: single);
begin
 FMatrix[2] := Value;
end;

procedure TSWFColorMatrixFilter.SetR3(const Value: single);
begin
 FMatrix[3] := Value;
end;

procedure TSWFColorMatrixFilter.SetR4(const Value: single);
begin
 FMatrix[4] := Value;
end;

procedure TSWFColorMatrixFilter.SetG0(const Value: single);
begin
 FMatrix[5] := Value;
end;

procedure TSWFColorMatrixFilter.SetG1(const Value: single);
begin
 FMatrix[6] := Value;
end;

procedure TSWFColorMatrixFilter.SetG2(const Value: single);
begin
 FMatrix[7] := Value;
end;

procedure TSWFColorMatrixFilter.SetG3(const Value: single);
begin
 FMatrix[8] := Value;
end;

procedure TSWFColorMatrixFilter.SetG4(const Value: single);
begin
 FMatrix[9] := Value;
end;

procedure TSWFColorMatrixFilter.SetB0(const Value: single);
begin
 FMatrix[10] := Value;
end;

procedure TSWFColorMatrixFilter.SetB1(const Value: single);
begin
 FMatrix[11] := Value;
end;

procedure TSWFColorMatrixFilter.SetB2(const Value: single);
begin
 FMatrix[12] := Value;
end;

procedure TSWFColorMatrixFilter.SetB3(const Value: single);
begin
 FMatrix[13] := Value;
end;

procedure TSWFColorMatrixFilter.SetB4(const Value: single);
begin
 FMatrix[14] := Value;
end;

procedure TSWFColorMatrixFilter.SetA0(const Value: single);
begin
 FMatrix[15] := Value;
end;

procedure TSWFColorMatrixFilter.SetA1(const Value: single);
begin
 FMatrix[16] := Value;
end;

procedure TSWFColorMatrixFilter.SetA2(const Value: single);
begin
 FMatrix[17] := Value;
end;

procedure TSWFColorMatrixFilter.SetA3(const Value: single);
begin
 FMatrix[18] := Value;
end;

procedure TSWFColorMatrixFilter.SetA4(const Value: single);
begin
 FMatrix[19] := Value;
end;

procedure TSWFColorMatrixFilter.ResetValues;
begin
  FillChar(FMatrix, SizeOf(FMatrix), 0);
  FMatrix[0] := 1;
  FMatrix[6] := 1;
  FMatrix[12] := 1;
  FMatrix[18] := 1;
end;

procedure TSWFColorMatrixFilter.WriteToStream(be: TBitsEngine);
   var il: byte;
begin
 be.WriteByte(FFilterID);
 for il := 0 to 19 do
   be.WriteFloat(Matrix[il]);
end;


{
***************************************************** TSWFConvolutionFilter ******************************************************
}
constructor TSWFConvolutionFilter.Create;
begin
 FFilterID := fidConvolution;
 FDefaultColor := TSWFRGBA.Create(true);
 FMatrix := TList.Create;
end;

destructor TSWFConvolutionFilter.Destroy;
begin
 FDefaultColor.Free;
 FMatrix.Free;
 inherited;
end;

procedure TSWFConvolutionFilter.Assign(Source: TSWFFilter);
 var il: byte;
begin
 with TSWFConvolutionFilter(Source) do
  begin
   self.Bias := Bias;
   self.Clamp := Clamp;
   self.Divisor := Divisor;
   self.DefaultColor.Assign(DefaultColor);
   self.MatrixX := MatrixX;
   self.MatrixY := MatrixY;
   self.PreserveAlpha := PreserveAlpha;
   for il := 0 to MatrixX*MatrixY-1 do
    self.Matrix[il] := Matrix[il];
  end;
end;

function TSWFConvolutionFilter.GetMatrix(Index: Integer): single;
 var LW: longword;
begin
 while (Index+1) > FMatrix.Count do FMatrix.Add(nil);
 LW := LongInt(FMatrix.Items[Index]);
 Move(LW, Result, 4);
end;

procedure TSWFConvolutionFilter.ReadFromStream(be: TBitsEngine);
 var il, b: byte;
begin
  MatrixX := be.ReadByte;
  MatrixY := be.ReadByte;
  Divisor := be.ReadSingle;
  Bias := be.ReadSingle;
  for il := 0 to MatrixX*MatrixY-1 do
   Matrix[il] := be.ReadSingle;
  DefaultColor.RGBA := be.ReadRGBA;
  b := be.ReadByte;
  Clamp := CheckBit(b, 2);
  PreserveAlpha := CheckBit(b, 1);
end;

procedure TSWFConvolutionFilter.SetMatrix(Index: Integer; const Value: single);
 var LW: longword;
begin
 while (Index+1) > FMatrix.Count do FMatrix.Add(nil);
 Move(Value, LW, 4);
 FMatrix.Items[Index] := Pointer(LW);
end;

procedure TSWFConvolutionFilter.WriteToStream(be: TBitsEngine);
   var il: byte;
begin
 be.WriteByte(FFilterID);
 be.WriteByte(MatrixX);
 be.WriteByte(MatrixY);
 be.WriteSingle(Divisor);
 be.WriteSingle(Bias);
 for il := 0 to MatrixX*MatrixY-1 do
   be.WriteSingle(Matrix[il]);
 be.WriteColor(DefaultColor.RGBA);
 be.WriteByte(byte(Clamp) shl 1 + byte(PreserveAlpha));
end;

{
***************************************************** TSWFBlurFilter ******************************************************
}
constructor TSWFBlurFilter.Create;
begin
 FFilterID := fidBlur;
 Passes := 1;
end;

procedure TSWFBlurFilter.Assign(Source: TSWFFilter);
begin
 With TSWFBlurFilter(Source) do
  begin
   self.BlurX := BlurX;
   self.BlurY := BlurY;
   self.Passes := Passes;
  end;
end;

procedure TSWFBlurFilter.ReadFromStream(be: TBitsEngine);
 var b: byte;
begin
  BlurX := be.ReadSingle;
  BlurY := be.ReadSingle;
  b := be.ReadByte;
  Passes := b shr 3;
end;

procedure TSWFBlurFilter.WriteToStream(be: TBitsEngine);
begin
  be.WriteByte(FFilterID);
  be.WriteSingle(BlurX);
  be.WriteSingle(BlurY);
  be.WriteByte(Passes shl 3);
end;

{
***************************************************** TSWFDropShadowFilter ******************************************************
}
constructor TSWFGlowFilter.Create;
begin
 FFilterID := fidGlow;
 FGlowColor := TSWFRGBA.Create(true);
 CompositeSource := true;
end;

destructor TSWFGlowFilter.Destroy;
begin
 FGlowColor.Free;
 inherited;
end;

procedure TSWFGlowFilter.Assign(Source: TSWFFilter);
begin
 inherited;
 with TSWFGlowFilter(Source) do
  begin
    self.CompositeSource := CompositeSource;
    self.InnerGlow := InnerGlow;
    self.Knockout := Knockout;
    self.Strength := Strength;
    self.GlowColor.Assign(GlowColor);
  end;
end;

procedure TSWFGlowFilter.ReadFromStream(be: TBitsEngine);
 var b: byte;
begin
 GlowColor.RGBA := be.ReadRGBA;
 BlurX := be.ReadSingle;
 BlurY := be.ReadSingle;
 Strength := WordToSingle(be.ReadWord);
 b := be.ReadByte;
 InnerGlow := CheckBit(b, 8);
 Knockout := CheckBit(b, 7);
 CompositeSource := CheckBit(b, 6);
 Passes := b and 31;
end;

procedure TSWFGlowFilter.WriteToStream(be: TBitsEngine);
begin
  be.WriteByte(FFilterID);
  be.WriteColor(GlowColor.RGBA);
  be.WriteSingle(BlurX);
  be.WriteSingle(BlurY);
  be.WriteWord(SingleToWord(Strength));

  be.WriteByte(byte(InnerGlow) shl 7 +
               byte(Knockout) shl 6 +
               byte(CompositeSource) shl 5 +
               (Passes and 31));
end;

{
***************************************************** TSWFDropShadowFilter ******************************************************
}
constructor TSWFDropShadowFilter.Create;
begin
 FFilterID := fidDropShadow;
 FDropShadowColor := TSWFRGBA.Create(true);
 CompositeSource := true;
 DropShadowColor.A := $FF; 
end;

destructor TSWFDropShadowFilter.Destroy;
begin
 FDropShadowColor.Free;
 inherited;
end;

procedure TSWFDropShadowFilter.Assign(Source: TSWFFilter);
begin
 inherited;
 with TSWFDropShadowFilter(Source) do
  begin
    self.Angle := Angle;
    self.CompositeSource := CompositeSource;
    self.Distance := Distance;
    self.InnerShadow := InnerShadow;
    self.Knockout := Knockout;
    self.Strength := Strength;
    self.DropShadowColor.Assign(DropShadowColor);
  end;
end;

procedure TSWFDropShadowFilter.ReadFromStream(be: TBitsEngine);
 var b: byte;
begin
 DropShadowColor.RGBA := be.ReadRGBA;
 BlurX := be.ReadSingle;
 BlurY := be.ReadSingle;
 Angle := be.ReadSingle;
 Distance := be.ReadSingle;
 Strength := WordToSingle(be.ReadWord);
 b := be.ReadByte;
 InnerShadow := CheckBit(b, 8);
 Knockout := CheckBit(b, 7);
 CompositeSource := CheckBit(b, 6);
 Passes := b and 31;
end;

procedure TSWFDropShadowFilter.WriteToStream(be: TBitsEngine);
begin
  be.WriteByte(FFilterID);
  be.WriteColor(DropShadowColor.RGBA);
  be.WriteSingle(BlurX);
  be.WriteSingle(BlurY);
  be.WriteSingle(Angle);
  be.WriteSingle(Distance);
  be.WriteWord(SingleToWord(Strength));

  be.WriteByte(byte(InnerShadow) shl 7 +
               byte(Knockout) shl 6 +
               byte(CompositeSource) shl 5 +
               (Passes and 31));
end;

{
***************************************************** TSWFBevelFilter ******************************************************
}
constructor TSWFBevelFilter.Create;
begin
 FFilterID := fidBevel;
 FShadowColor := TSWFRGBA.Create(True);
 FHighlightColor := TSWFRGBA.Create(True);
 CompositeSource := true;
end;

destructor TSWFBevelFilter.Destroy;
begin
 FHighlightColor.Free;
 FShadowColor.Free;
 inherited;
end;

procedure TSWFBevelFilter.Assign(Source: TSWFFilter);
begin
 inherited;
 with TSWFBevelFilter(Source) do
  begin
    self.Angle := Angle;
    self.CompositeSource := CompositeSource;
    self.Distance := Distance;
    self.InnerShadow := InnerShadow;
    self.Knockout := Knockout;
    self.OnTop := OnTop;
    self.Strength := Strength;
    self.HighlightColor.Assign(HighlightColor);
    self.ShadowColor.Assign(ShadowColor);
  end;
end;

procedure TSWFBevelFilter.ReadFromStream(be: TBitsEngine);
 var b: byte;
begin
 ShadowColor.RGBA := be.ReadRGBA;
 HighlightColor.RGBA := be.ReadRGBA;
 BlurX := be.ReadSingle;
 BlurY := be.ReadSingle;
 Angle := be.ReadSingle;
 Distance := be.ReadSingle;
 Strength := WordToSingle(be.ReadWord);
 b := be.ReadByte;
 InnerShadow := CheckBit(b, 8);
 Knockout := CheckBit(b, 7);
 CompositeSource := CheckBit(b, 6);
 OnTop := CheckBit(b, 5);
 Passes := b and 15;
end;

procedure TSWFBevelFilter.WriteToStream(be: TBitsEngine);
begin
  be.WriteByte(FFilterID);
  be.WriteColor(ShadowColor.RGBA);
  be.WriteColor(HighlightColor.RGBA);
  be.WriteSingle(BlurX);
  be.WriteSingle(BlurY);
  be.WriteSingle(Angle);
  be.WriteSingle(Distance);
  be.WriteWord(SingleToWord(Strength));

  be.WriteByte(byte(InnerShadow) shl 7 +
               byte(Knockout) shl 6 +
               byte(CompositeSource) shl 5 +
               byte(OnTop) shl 4 +
               (Passes and 15));
end;

{
************************************************** TSWFGradientGlowFilter ****************************************************
}
constructor TSWFGradientGlowFilter.Create;
begin
 FFilterID := fidGradientGlow;
 CompositeSource := true;
 NumColors := 2;
 FColor[1] := TSWFRGBA.Create(true);
 FColor[2] := TSWFRGBA.Create(true);
 FRatio[1] := 0;
 FRatio[2] := 255;
end;

destructor TSWFGradientGlowFilter.Destroy;
var
  il: Byte;
begin
  For il := 1 to 15 do
    if FColor[il] <> nil then FreeAndNil(FColor[il]);
  inherited;
end;

procedure TSWFGradientGlowFilter.Assign(Source: TSWFFilter);
 var il: integer;
begin
 inherited;
 with TSWFGradientGlowFilter(Source) do
  begin
    self.Angle := Angle;
    self.CompositeSource := CompositeSource;
    self.Distance := Distance;
    self.InnerShadow := InnerShadow;
    self.Knockout := Knockout;
    self.OnTop := OnTop;
    self.Strength := Strength;
    self.NumColors := NumColors;
    for il := 1 to NumColors do
     begin
      self.GradientRatio[il] := GradientRatio[il];
      self.GradientColor[il].Assign(GradientColor[il]);
     end;
  end;
end;

function TSWFGradientGlowFilter.GetGradient(Index: byte): TSWFGradientRec;
begin
  Result.color := GradientColor[index].RGBA;
  Result.Ratio := FRatio[index];
end;

function TSWFGradientGlowFilter.GetGradientColor(Index: Integer): TSWFRGBA;
begin
  if FColor[index] = nil then FColor[index] := TSWFRGBA.Create;
  Result := FColor[index];
end;

function TSWFGradientGlowFilter.GetGradientRatio(Index: Integer): Byte;
begin
  Result := FRatio[index];
end;

procedure TSWFGradientGlowFilter.ReadFromStream(be: TBitsEngine);
 var b, il: byte;
begin
 NumColors := be.ReadByte;
 for il := 1 to NumColors do
   GradientColor[il].RGBA := be.ReadRGBA;
 for il := 1 to NumColors do
   GradientRatio[il] := be.ReadByte;

 BlurX := be.ReadSingle;
 BlurY := be.ReadSingle;
 Angle := be.ReadSingle;
 Distance := be.ReadSingle;
 Strength := WordToSingle(be.ReadWord);
 b := be.ReadByte;
 InnerShadow := CheckBit(b, 8);
 Knockout := CheckBit(b, 7);
 CompositeSource := CheckBit(b, 6);
 OnTop := CheckBit(b, 5);
 Passes := b and 15;
end;

procedure TSWFGradientGlowFilter.SetGradientRatio(Index: Integer; Value: Byte);
begin
  FRatio[index] := Value;
end;

procedure TSWFGradientGlowFilter.WriteToStream(be: TBitsEngine);
 var il: byte;
begin
  be.WriteByte(FFilterID);
  be.WriteByte(NumColors);
  for il := 1 to NumColors do
    be.WriteColor(GradientColor[il].RGBA);
  for il := 1 to NumColors do
    be.WriteByte(GradientRatio[il]);

  be.WriteSingle(BlurX);
  be.WriteSingle(BlurY);
  be.WriteSingle(Angle);
  be.WriteSingle(Distance);
  be.WriteWord(SingleToWord(Strength));

  be.WriteByte(byte(InnerShadow) shl 7 +
               byte(Knockout) shl 6 +
               byte(CompositeSource) shl 5 +
               byte(OnTop) shl 4 +
               (Passes and 15));
end;

{
************************************************ TSWFGradientBevelFilter **************************************************
}
constructor TSWFGradientBevelFilter.Create;
begin
 inherited;
 FFilterID := fidGradientBevel;
end;


{
***************************************************** TSWFFilterList ******************************************************
}

function TSWFFilterList.GetFilter(Index: Integer): TSWFFilter;
begin
 Result := TSWFFilter(Items[Index]);
end;

function TSWFFilterList.AddFilter(id: TSwfFilterID): TSWFFilter;
begin
  Result := nil;
  case id of
   fidDropShadow:
     Result := TSWFDropShadowFilter.Create;
   fidBlur:
     Result := TSWFBlurFilter.Create;
   fidGlow:
     Result := TSWFGlowFilter.Create;
   fidBevel:
     Result := TSWFBevelFilter.Create;
   fidGradientGlow:
     Result := TSWFGradientGlowFilter.Create;
   fidConvolution:
     Result := TSWFConvolutionFilter.Create;
   fidColorMatrix:
     Result := TSWFColorMatrixFilter.Create;
   fidGradientBevel:
     Result := TSWFGradientBevelFilter.Create;
  end;
  Add(Result);
end;

procedure TSWFFilterList.ReadFromStream(be: TBitsEngine);
 var c, il: byte;
begin
  c := be.ReadByte;
  if c > 0 then
   for il := 0 to c - 1 do
    AddFilter(be.ReadByte).ReadFromStream(be);
end;

procedure TSWFFilterList.WriteToStream(be: TBitsEngine);
 var il: integer;
begin
  be.WriteByte(Count);
  for il := 0 to Count - 1 do
    Filter[il].WriteToStream(be);
end;


{
***************************************************** TSWFPlaceObject3 ******************************************************
}
constructor TSWFPlaceObject3.Create;
begin
  TagID := tagPlaceObject3;
  SWFVersion := SWFVer8;
end;

destructor TSWFPlaceObject3.Destroy;
begin
  inherited;
  if FSurfaceFilterList <> nil then FSurfaceFilterList.Free;
end;

procedure TSWFPlaceObject3.Assign(Source: TBasedSWFObject);
 var il: byte;
begin
 inherited;
 with TSWFPlaceObject3(Source) do
  begin
   self.PlaceFlagHasImage := PlaceFlagHasImage;
   self.PlaceFlagHasClassName := PlaceFlagHasClassName;
   self._ClassName := _ClassName;
   self.PlaceFlagHasCacheAsBitmap := PlaceFlagHasCacheAsBitmap;
   self.PlaceFlagHasBlendMode := PlaceFlagHasBlendMode;
   if PlaceFlagHasBlendMode then
     self.BlendMode := BlendMode;
   self.PlaceFlagHasFilterList := PlaceFlagHasFilterList;
   if PlaceFlagHasFilterList then
     begin
       self.SurfaceFilterList.Clear;
       for il := 0 to SurfaceFilterList.Count - 1 do
        self.SurfaceFilterList.AddFilter(SurfaceFilterList.Filter[il].FilterID).Assign(SurfaceFilterList.Filter[il]);
     end;
  end;
end;

function TSWFPlaceObject3.GetSurfaceFilterList: TSWFFilterList;
begin
 if FSurfaceFilterList = nil then
   begin
    FSurfaceFilterList := TSWFFilterList.Create;
    PlaceFlagHasFilterList := true; 
   end;
 Result := FSurfaceFilterList;
end;

function TSWFPlaceObject3.MinVersion: Byte;
begin
  Result := SWFVer8 + Byte(PlaceFlagHasImage or PlaceFlagHasClassName);
end;

procedure TSWFPlaceObject3.ReadAddonFlag(be: TBitsEngine);
 var b: byte;
begin
 b := be.ReadByte;
 if SWFVersion = SWFVer9 then
 begin
   PlaceFlagHasImage := CheckBit(b, 5);
   PlaceFlagHasClassName := CheckBit(b, 4);
 end else
 begin
   PlaceFlagHasImage := false;
   PlaceFlagHasClassName := false;
 end;
 PlaceFlagHasCacheAsBitmap := CheckBit(b, 3);
 PlaceFlagHasBlendMode := CheckBit(b, 2);
 PlaceFlagHasFilterList := CheckBit(b, 1);
 if PlaceFlagHasClassName or (PlaceFlagHasImage and PlaceFlagHasCharacter) then
    _ClassName := be.ReadString;
end;

procedure TSWFPlaceObject3.ReadFilterFromStream(be: TBitsEngine);
begin
 if PlaceFlagHasFilterList then SurfaceFilterList.ReadFromStream(be);
 if PlaceFlagHasBlendMode then BlendMode := be.ReadByte;
end;

procedure TSWFPlaceObject3.SetClassName(const Value: string);
begin
  FClassName := Value;
  PlaceFlagHasClassName := Value <> '';
end;

procedure TSWFPlaceObject3.WriteAddonFlag(be: TBitsEngine);
 var b: byte;
begin
 if SaveAsPO2 then Exit;
 b := byte(PlaceFlagHasImage) shl 4 +
      byte(PlaceFlagHasClassName) shl 3 +
      byte(PlaceFlagHasCacheAsBitmap) shl 2 +
      byte(PlaceFlagHasBlendMode) shl 1 +
      byte(PlaceFlagHasFilterList and (FSurfaceFilterList.Count > 0));

 be.WriteByte(b);
 if PlaceFlagHasClassName or (PlaceFlagHasImage and PlaceFlagHasCharacter) then
   be.WriteString(_ClassName);
end;

procedure TSWFPlaceObject3.WriteFilterToStream(be: TBitsEngine);
begin
 if SaveAsPO2 then Exit;
 if PlaceFlagHasFilterList and (SurfaceFilterList.Count > 0) then
   SurfaceFilterList.WriteToStream(be);
 if PlaceFlagHasBlendMode then be.WriteByte(BlendMode);
end;

{
***************************************************** TSWFRemoveObject ******************************************************
}
constructor TSWFRemoveObject.Create;
begin
  inherited;
  TagID := tagRemoveObject;
end;

procedure TSWFRemoveObject.Assign(Source: TBasedSWFObject);
begin
  inherited;
  With TSWFRemoveObject(Source) do
  begin
    self.CharacterID := CharacterID;
    self.Depth := Depth;
  end;
end;

procedure TSWFRemoveObject.ReadFromStream(be: TBitsEngine);
begin
  CharacterID := be.ReadWord;
  Depth := be.ReadWord;
end;

procedure TSWFRemoveObject.WriteTagBody(be: TBitsEngine);
begin
  be.WriteWord(CharacterID);
  be.WriteWord(Depth);
end;

{
***************************************************** TSWFRemoveObject2 *****************************************************
}
constructor TSWFRemoveObject2.Create;
begin
  inherited;
  TagID := tagRemoveObject2;
end;

procedure TSWFRemoveObject2.Assign(Source: TBasedSWFObject);
begin
  inherited;
  Depth := TSWFRemoveObject2(Source).Depth;
end;

function TSWFRemoveObject2.MinVersion: Byte;
begin
  result := SWFVer3;
end;

procedure TSWFRemoveObject2.ReadFromStream(be: TBitsEngine);
begin
  Depth := be.ReadWord;
end;

procedure TSWFRemoveObject2.WriteTagBody(be: TBitsEngine);
begin
  be.WriteWord(Depth);
end;

{
******************************************************* TSWFShowFrame *******************************************************
}
constructor TSWFShowFrame.Create;
begin
  TagID := tagShowFrame;
end;


// =========================================================
//                        Shape
// =========================================================

{
******************************************************* TSWFLineStyle *******************************************************
}
constructor TSWFLineStyle.Create;
begin
  FColor := TSWFRGBA.Create;
end;

destructor TSWFLineStyle.Destroy;
begin
  FColor.Free;
  inherited Destroy;
end;

procedure TSWFLineStyle.Assign(Source: TSWFLineStyle);
begin
  Width := Source.Width;
  Color.Assign(Source.Color);
end;

procedure TSWFLineStyle.ReadFromStream(be: TBitsEngine);
begin
  Width := be.ReadWord;
  if Color.hasAlpha then Color.RGBA := be.ReadRGBA
    else Color.RGB := be.ReadRGB;
end;

procedure TSWFLineStyle.WriteToStream(be: TBitsEngine);
begin
  be.WriteWord(Width);
  if Color.hasAlpha then be.WriteColor(Color.RGBA)
    else be.WriteColor(Color.RGB);
end;

{
******************************************************* TSWFLineStyle2 *******************************************************
}
constructor TSWFLineStyle2.Create;
begin
  inherited;
  FColor.HasAlpha := true;
end;

destructor TSWFLineStyle2.Destroy;
begin
  if FFillStyle <> nil then FFillStyle.Free;
  inherited;
end;

procedure TSWFLineStyle2.Assign(Source: TSWFLineStyle);
 var Source2: TSWFLineStyle2;
begin
  inherited;
  if Source is TSWFLineStyle2 then
   begin
     Source2 := Source as TSWFLineStyle2;
     HasFillFlag := Source2.HasFillFlag;
     StartCapStyle := Source2.StartCapStyle;
     JoinStyle := Source2.JoinStyle;
     NoClose := Source2.NoClose;
     NoHScaleFlag := Source2.NoHScaleFlag;
     NoVScaleFlag := Source2.NoVScaleFlag;
     PixelHintingFlag := Source2.PixelHintingFlag;
     EndCapStyle := Source2.EndCapStyle;
     MiterLimitFactor := Source2.MiterLimitFactor;
     if HasFillFlag then
       GetFillStyle(Source2.FFillStyle.SWFFillType).Assign(Source2.FFillStyle);
   end;
end;

function TSWFLineStyle2.GetFillStyle(style: integer): TSWFFillStyle;
 var fmake: boolean;
begin
 if style > -1 then
  begin
   fmake := true;
   if FFillStyle <> nil then
     begin
       if FFillStyle.SWFFillType <> style then FFillStyle.Free
         else fmake := false;
     end;
   if fmake then
    case style of
     SWFFillSolid:
        FFillStyle := TSWFColorFill.Create;
     SWFFillLinearGradient, SWFFillRadialGradient:
        FFillStyle := TSWFGradientFill.Create;
     SWFFillFocalGradient:
        FFillStyle := TSWFFocalGradientFill.Create;
     SWFFillTileBitmap, SWFFillClipBitmap,
     SWFFillNonSmoothTileBitmap, SWFFillNonSmoothClipBitmap:
        FFillStyle := TSWFImageFill.Create;
    end;
   FFillStyle.hasAlpha := true;
   FFillStyle.SWFFillType := style;
  end;
  Result := FFillStyle;
end;

procedure TSWFLineStyle2.ReadFromStream(be: TBitsEngine);
 var b: byte;
begin
  Width := be.ReadWord;
  b := be.ReadByte;
  StartCapStyle := b shr 6;
  JoinStyle := (b shr 4) and 3;
  HasFillFlag := CheckBit(b, 4);
  NoHScaleFlag := CheckBit(b, 3);
  NoVScaleFlag := CheckBit(b, 2);
  PixelHintingFlag := CheckBit(b, 1);
  b := be.ReadByte;
  NoClose := CheckBit(b, 3);
  EndCapStyle := b and 3;
  if JoinStyle = 2 then
    MiterLimitFactor := WordToSingle(be.ReadWord);
  if HasFillFlag
    then GetFillStyle(be.ReadByte).ReadFromStream(be)
    else Color.RGBA := be.ReadRGBA;
end;

procedure TSWFLineStyle2.WriteToStream(be: TBitsEngine);
begin
  be.WriteWord(Width);
  be.WriteBits(StartCapStyle, 2);
  be.WriteBits(JoinStyle, 2);
  be.WriteBit(HasFillFlag);
  be.WriteBit(NoHScaleFlag);
  be.WriteBit(NoVScaleFlag);
  be.WriteBit(PixelHintingFlag);
  be.WriteBits(0, 5);
  be.WriteBit(NoClose);
  be.WriteBits(EndCapStyle, 2);

  if JoinStyle = 2 then
    be.WriteWord(SingleToWord(MiterLimitFactor));
  if HasFillFlag
    then GetFillStyle(-1).WriteToStream(be)
    else be.WriteColor(Color.RGBA);
end;


{
******************************************************* TSWFFillStyle *******************************************************
}
procedure TSWFFillStyle.Assign(Source: TSWFFillStyle);
begin
  hasAlpha := Source.hasAlpha;
  FSWFFillType := Source.FSWFFillType;
end;

{
******************************************************* TSWFColorFill *******************************************************
}
constructor TSWFColorFill.Create;
begin
  inherited ;
  SWFFillType := SWFFillSolid;
  FColor := TSWFRGBA.Create;
end;

destructor TSWFColorFill.Destroy;
begin
  FColor.Free;
  inherited Destroy;
end;

procedure TSWFColorFill.Assign(Source: TSWFFillStyle);
begin
  inherited;
  Color.Assign(TSWFColorFill(Source).Color);
end;

procedure TSWFColorFill.ReadFromStream(be: TBitsEngine);
begin
  if hasAlpha
    then Color.RGBA := be.ReadRGBA
    else Color.RGB := be.ReadRGB;
  Color.HasAlpha := hasAlpha;
end;

procedure TSWFColorFill.WriteToStream(be: TBitsEngine);
begin
  be.WriteByte(SWFFillType);
  if hasAlpha then be.WriteColor(Color.RGBA) else be.WriteColor(Color.RGB);
end;


{
******************************************************* TSWFImageFill *******************************************************
}
constructor TSWFImageFill.Create;
begin
  inherited ;
  SWFFillType := SWFFillClipBitmap;
  FMatrix := TSWFMatrix.Create;
end;

destructor TSWFImageFill.Destroy;
begin
  FMatrix.Free;
  inherited Destroy;
end;

procedure TSWFImageFill.Assign(Source: TSWFFillStyle);
begin
  inherited;
  with TSWFImageFill(Source) do
  begin
    self.Matrix.Assign(Matrix);
    self.ImageID := ImageID;
  end;
end;

procedure TSWFImageFill.ReadFromStream(be: TBitsEngine);
begin
  ImageID := be.ReadWord;
  Matrix.Rec := be.ReadMatrix;
end;

procedure TSWFImageFill.ScaleTo(Frame: TRect; W, H: word);
begin
  Matrix.SetTranslate(Frame.Left - twips div 4, Frame.Top - twips div 4);
  Matrix.SetScale((Frame.Right - Frame.Left)/W + $f0 / specFixed,
                  (Frame.Bottom - Frame.Top)/H + $f0 / specFixed);
end;

procedure TSWFImageFill.WriteToStream(be: TBitsEngine);
begin
  be.WriteByte(SWFFillType);
  be.WriteWord(ImageID);
  be.WriteMatrix(Matrix.Rec);

end;


{
*************************************************** TSWFBaseGradientFill ****************************************************
}
constructor TSWFBaseGradientFill.Create;
begin
  inherited ;
  SWFFillType := SWFFillLinearGradient;
  FColor[1] := TSWFRGBA.Create;
  FColor[2] := TSWFRGBA.Create;
end;

destructor TSWFBaseGradientFill.Destroy;
var
  il: Byte;
begin
  For il := 1 to 15 do
    if FColor[il] <> nil then FreeAndNil(FColor[il]);
  inherited Destroy;
end;

procedure TSWFBaseGradientFill.Assign(Source: TSWFFillStyle);
var
  il: Byte;
begin
  inherited;
  with TSWFBaseGradientFill(Source) do
  begin
    self.Count := Count;
    if Count > 0 then
    For il := 1 to Count do
     begin
       self.FRatio[il] := FRatio[il];
       self.GradientColor[il].Assign(GradientColor[il]);
     end;
  end;
end;

function TSWFBaseGradientFill.GetGradient(Index: byte): TSWFGradientRec;
begin
  Result.color := GradientColor[index].RGBA;
  Result.Ratio := FRatio[index];
end;

function TSWFBaseGradientFill.GetGradientColor(Index: Integer): TSWFRGBA;
begin
  if FColor[index] = nil then FColor[index] := TSWFRGBA.Create;
  Result := FColor[index];
end;

function TSWFBaseGradientFill.GetGradientRatio(Index: Integer): Byte;
begin
  Result := FRatio[index];
end;

procedure TSWFBaseGradientFill.ReadFromStream(be: TBitsEngine);
var
  il, bc: Byte;
begin
  bc := be.ReadByte;
  SpreadMode := bc shr 6;
  InterpolationMode := (bc shr 4) and 3;
  Count := bc and 15;
  if Count > 0 then
  for il := 1 to Count do
   begin
    GradientRatio[il] := be.ReadByte;
    GradientColor[il].HasAlpha := hasAlpha;
    if hasAlpha then GradientColor[il].RGBA := be.ReadRGBA
       else GradientColor[il].RGB := be.ReadRGB;
   end;
end;

procedure TSWFBaseGradientFill.SetGradientRatio(Index: Integer; Value: Byte);
begin
  FRatio[index] := Value;
end;

procedure TSWFBaseGradientFill.WriteToStream(be: TBitsEngine);
var
  il, bc: Byte;
begin
  bc := SpreadMode shl 6 + InterpolationMode shl 4 + Count;
  be.WriteByte(bc);
  For il := 1 to Count do
    begin
      be.WriteByte(Gradient[il].ratio);
      if hasAlpha then be.WriteColor(Gradient[il].Color)
        else be.WriteColor(WithoutA(Gradient[il].Color));
    end;
end;

{
***************************************************** TSWFGradientFill ******************************************************
}
constructor TSWFGradientFill.Create;
begin
  inherited ;
  FMatrix := TSWFMatrix.Create;
end;

destructor TSWFGradientFill.Destroy;
begin
  FMatrix.Free;
  inherited Destroy;
end;

procedure TSWFGradientFill.Assign(Source: TSWFFillStyle);
begin
  inherited;
  with TSWFGradientFill(Source) do
    self.Matrix.Assign(Matrix);
end;

procedure TSWFGradientFill.ReadFromStream(be: TBitsEngine);
begin
  Matrix.Rec := be.ReadMatrix;
  inherited;

(*  Count := be.ReadByte;
  if Count > 0 then
  for il := 1 to Count do
   begin
    GradientRatio[il] := be.ReadByte;
    GradientColor[il].HasAlpha := hasAlpha;
    if hasAlpha then GradientColor[il].RGBA := be.ReadRGBA
       else GradientColor[il].RGB := be.ReadRGB;
   end;    *)
end;

procedure TSWFGradientFill.ScaleTo(Frame: TRect);
var
  kX, kY: Double;
begin
  kX := (Frame.Right - Frame.Left) /GradientSizeXY;
  kY := (Frame.Bottom - Frame.Top)/GradientSizeXY;
  Matrix.SetScale(kX, kY);
  Matrix.SetTranslate(Frame.Left + (Frame.Right - Frame.Left) div 2,
                      Frame.Top + (Frame.Bottom - Frame.Top) div 2);
end;

procedure TSWFGradientFill.WriteToStream(be: TBitsEngine);
begin
  be.WriteByte(SWFFillType);
  be.WriteMatrix(Matrix.Rec);
  inherited;
(*  be.WriteByte(Count);
  For il := 1 to Count do
    begin
      be.WriteByte(Gradient[il].ratio);
      if hasAlpha then be.WriteColor(Gradient[il].Color)
        else be.WriteColor(WithoutA(Gradient[il].Color));
    end; *)
end;


{
*************************************************** TSWFFocalGradientFill ****************************************************
}
constructor TSWFFocalGradientFill.Create;
begin
  inherited;
  SWFFillType := SWFFillFocalGradient;
end;

procedure TSWFFocalGradientFill.Assign(Source: TSWFFillStyle);
begin
  inherited;
  FocalPoint := TSWFFocalGradientFill(Source).FocalPoint;
  InterpolationMode := TSWFFocalGradientFill(Source).InterpolationMode;
  SpreadMode := TSWFFocalGradientFill(Source).SpreadMode;
end;

function TSWFFocalGradientFill.GetFocalPoint: single;
begin
 Result := FFocalPoint/255;
 if Result > 1 then Result := 1 else
  if Result < -1 then Result := -1;
end;

procedure TSWFFocalGradientFill.SetFocalPoint(const Value: single);
begin
 FFocalPoint := Round(value * 255);
 if FFocalPoint > 255 then FFocalPoint := 255 else
   if FFocalPoint < -255 then FFocalPoint := -255; 
end;

procedure TSWFFocalGradientFill.ReadFromStream(be: TBitsEngine);
begin
 inherited;
 FFocalPoint := smallint(be.ReadWord);
end;

procedure TSWFFocalGradientFill.WriteToStream(be: TBitsEngine);
begin
 inherited;
 be.WriteWord(word(FFocalPoint));
end;


{
****************************************************** TSWFShapeRecord ******************************************************
}
procedure TSWFShapeRecord.Assign(Source: TSWFShapeRecord);
begin
end;

{
**************************************************** TSWFEndShapeRecord *****************************************************
}
constructor TSWFEndShapeRecord.Create;
begin
  ShapeRecType := EndShapeRecord;
end;

procedure TSWFEndShapeRecord.WriteToStream(be: TBitsEngine);
begin
  be.WriteBits(0, 6);
end;

{
************************************************** TSWFStraightEdgeRecord ***************************************************
}
constructor TSWFStraightEdgeRecord.Create;
begin
  ShapeRecType := StraightEdgeRecord;
end;

procedure TSWFStraightEdgeRecord.Assign(Source: TSWFShapeRecord);
begin
  with TSWFStraightEdgeRecord(Source) do
  begin
    self.X := X;
    self.Y := Y;
  end;
end;

procedure TSWFStraightEdgeRecord.WriteToStream(be: TBitsEngine);
var
  nBits: Byte;
begin
  //if (X = 0) and (Y = 0) then Exit;
  BE.WriteBit(true); //edge flag
  BE.WriteBit(true); // Line EDGE

  nBits :=  GetBitsCount(SWFTools.MaxValue(X, Y), 1);
  if nBits = 0 then nBits := 2;
  BE.WriteBits(nBits - 2, 4);
  
  if (X<>0) and (Y<>0) then
   begin
    BE.WriteBit(true); // GeneralLineFlag
    BE.WriteBits(X, nBits);
    BE.WriteBits(Y, nBits);
   end else
   begin
    BE.WriteBit(false); // GeneralLineFlag
    BE.WriteBit(X = 0);   // verticalLine
    if X = 0 then BE.WriteBits(Y, nBits) else
      BE.WriteBits(X, nBits);
   end;
end;

{
*************************************************** TSWFStyleChangeRecord ***************************************************
}
constructor TSWFStyleChangeRecord.Create;
begin
  ShapeRecType := StyleChangeRecord;
end;

destructor TSWFStyleChangeRecord.Destroy;
begin
  if FNewFillStyles <> nil then FNewFillStyles.Free;
  if FNewLineStyles <> nil then FNewLineStyles.Free;
  inherited;
end;

procedure TSWFStyleChangeRecord.Assign(Source: TSWFShapeRecord);
var
  il: Word;
  OldFS, NewFS: TSWFFillStyle;
  LS: TSWFLineStyle;
  LS2: TSWFLineStyle2;
begin
  inherited;
  with TSWFStyleChangeRecord(Source) do
  begin
    self.bitsFill := bitsFill;
    self.bitsLine := bitsLine;
    self.Fill0Id := Fill0Id;
    self.Fill1Id := Fill1Id;
    self.LineId := LineId;
    self.StateFillStyle0 := StateFillStyle0;
    self.StateFillStyle1 := StateFillStyle1;
    self.StateLineStyle := StateLineStyle;
    self.StateMoveTo := StateMoveTo;
    self.StateNewStyles := StateNewStyles;
    if StateNewStyles then
      begin
        if (FNewFillStyles <> nil) and (FNewFillStyles.Count > 0) then
          for il := 0 to FNewFillStyles.Count - 1 do
           begin
            OldFS := TSWFFillStyle(FNewFillStyles[il]);
            NewFS := nil;
            Case OldFS.SWFFillType of
             SWFFillSolid:
                NewFS := TSWFColorFill.Create;
             SWFFillLinearGradient, SWFFillRadialGradient:
                NewFS := TSWFGradientFill.Create;
             SWFFillFocalGradient:
                NewFS := TSWFFocalGradientFill.Create;
             SWFFillTileBitmap, SWFFillClipBitmap,
             SWFFillNonSmoothTileBitmap, SWFFillNonSmoothClipBitmap:
                NewFS := TSWFImageFill.Create;
            end;
            NewFS.Assign(OldFS);
            self.NewFillStyles.Add(NewFS);
           end;

       if (FNewLineStyles <> nil) and (FNewLineStyles.Count > 0) then
        for il := 0 to FNewLineStyles.Count -1 do
         if FNewLineStyles[il] is TSWFLineStyle2 then
          begin
           LS2 := TSWFLineStyle2.Create;
           LS2.Assign(TSWFLineStyle2(FNewLineStyles[il]));
           self.NewLineStyles.Add(LS2);
          end else
          begin
           LS := TSWFLineStyle.Create;
           LS.Assign(TSWFLineStyle(FNewLineStyles[il]));
           self.NewLineStyles.Add(LS);
          end;
      end;
  end;
end;

function TSWFStyleChangeRecord.GetNewFillStyles: TObjectList;
begin
  if FNewFillStyles = nil then FNewFillStyles := TObjectList.Create;
  StateNewStyles := true;
  Result := FNewFillStyles;
end;

function TSWFStyleChangeRecord.GetNewLineStyles: TObjectList;
begin
  if FNewLineStyles = nil then FNewLineStyles := TObjectList.Create;
  StateNewStyles := true;
  Result := FNewLineStyles;
end;

procedure TSWFStyleChangeRecord.SetFill0Id(Value: Word);
begin
  if not StateFillStyle0 or (FFill0Id <> Value) then
  begin
    StateFillStyle0 := true;
    FFill0Id := Value;
  end;
end;

procedure TSWFStyleChangeRecord.SetFill1Id(Value: Word);
begin
  if not StateFillStyle1 or (FFill1Id <> Value) then
  begin
    StateFillStyle1 := true;
    FFill1Id := Value;
  end;
end;

procedure TSWFStyleChangeRecord.SetLineId(Value: Word);
begin
  if not StateLineStyle or (FLineId <> Value) then
  begin
    StateLineStyle := true;
    FLineId := Value;
  end;
end;

procedure TSWFStyleChangeRecord.WriteToStream(be: TBitsEngine);
var
  nBits: Byte;
  w, il: Word;
  fState: Boolean;
begin
  BE.WriteBit(false); // no edge info
  
  BE.WriteBit(stateNewStyles);
  BE.WriteBit(stateLineStyle);
  BE.WriteBit(stateFillStyle1);
  BE.WriteBit(stateFillStyle0);
  
  if stateFillStyle0 or stateFillStyle1 or stateLineStyle
     then fState := stateMoveTo
     else fState := true;
  BE.WriteBit(fState);
  
  if fState then
    begin
     nBits := GetBitsCount(SWFTools.MaxValue(X, Y), 1);
     BE.WriteBits(nBits, 5);
     BE.WriteBits(X, nBits);
     BE.WriteBits(Y, nBits);
    end;
  
  if stateFillStyle0 then
      BE.WriteBits(Fill0Id, bitsFill);
  
  if stateFillStyle1 then
      BE.WriteBits(Fill1Id, bitsFill);
  
  if stateLineStyle then
     BE.WriteBits(LineId, bitsLine);
  
  if stateNewStyles then
    begin
      be.FlushLastByte;
      w := NewFillStyles.Count;
      if w > $fe then
        begin
          BE.WriteByte($ff);
          BE.WriteWord(w);
        end else BE.WriteByte(w);
      if w > 0 then
      for il := 0 to w - 1 do
        with TSWFFillStyle(NewFillStyles[il]) do
         begin
           hasAlpha := self.hasAlpha;
           WriteToStream(BE);
         end;
  
      w := NewLineStyles.Count;
      if w > $fe then
        begin
          BE.WriteByte($ff);
          BE.WriteWord(w);
        end else BE.WriteByte(w);
      if w > 0 then
      for il := 0 to w - 1 do
        with TSWFLineStyle(NewLineStyles[il]) do
          begin
            Color.hasAlpha := hasAlpha;
            WriteToStream(BE);
          end;
          
      be.FlushLastByte(true);  // need ??
      bitsFill := GetBitsCount(NewFillStyles.Count);
      bitsLine := GetBitsCount(NewLineStyles.Count);
      BE.WriteBits(bitsFill, 4);
      BE.WriteBits(bitsLine, 4);
    end;
end;

{
*************************************************** TSWFCurvedEdgeRecord ****************************************************
}
constructor TSWFCurvedEdgeRecord.Create;
begin
  ShapeRecType := CurvedEdgeRecord;
end;

procedure TSWFCurvedEdgeRecord.Assign(Source: TSWFShapeRecord);
begin
  with TSWFCurvedEdgeRecord(Source) do
  begin
    self.ControlX := ControlX;
    self.ControlY := ControlY;
    self.AnchorX := AnchorX;
    self.AnchorY := AnchorY;
  end;
end;

procedure TSWFCurvedEdgeRecord.WriteToStream(be: TBitsEngine);
var
  nBits: Byte;
begin
  if (ControlX = 0) and (ControlY = 0) and (AnchorX = 0) and (AnchorY = 0) then Exit;
  BE.WriteBit(true); //edge flag
  BE.WriteBit(false); // Line_EDGE, This is a curved edge record
  
  nBits :=  GetBitsCount(SWFTools.MaxValue(ControlX, ControlY, AnchorX, AnchorY), 1);
  BE.WriteBits(nBits - 2, 4);
  BE.WriteBits(ControlX, nBits);
  BE.WriteBits(ControlY, nBits);
  BE.WriteBits(AnchorX, nBits);
  BE.WriteBits(AnchorY, nBits);
end;

{
****************************************************** TSWFDefineShape ******************************************************
}
constructor TSWFDefineShape.Create;
begin
  TagId := tagDefineShape;
  FShapeBounds := TSWFRect.Create;
  FEdges := TObjectList.Create;
  FLineStyles := TObjectList.Create;
  FFillStyles := TObjectList.Create;
end;

destructor TSWFDefineShape.Destroy;
begin
  FShapeBounds.Free;
  FEdges.free;
  FLineStyles.Free;
  FFillStyles.Free;
  inherited ;
end;

procedure TSWFDefineShape.Assign(Source: TBasedSWFObject);
var
  il: Word;
  LS: TSWFLineStyle;
  NewFS, OldFS: TSWFFIllStyle;
begin
  inherited;
  With TSWFDefineShape(Source) do
  begin
    self.ShapeId := ShapeId;
    self.ShapeBounds.Assign(ShapeBounds);
    self.hasAlpha := hasAlpha;

    CopyShapeRecords(Edges, Self.Edges);

    if LineStyles.Count > 0 then
     for il := 0 to LineStyles.Count -1 do
      begin
       if LineStyles[il] is TSWFLineStyle2
         then LS := TSWFLineStyle2.Create
         else LS := TSWFLineStyle.Create;
       LS.Assign(TSWFLineStyle(LineStyles[il]));
       self.LineStyles.Add(LS);
      end;
  
    if FillStyles.Count > 0 then
     for il := 0 to FillStyles.Count -1 do
      begin
       OldFS := TSWFFillStyle(FillStyles[il]);
       NewFS := nil;
       Case OldFS.SWFFillType of
        SWFFillSolid:
           NewFS := TSWFColorFill.Create;
        SWFFillLinearGradient, SWFFillRadialGradient:
           NewFS := TSWFGradientFill.Create;
        SWFFillFocalGradient:
                NewFS := TSWFFocalGradientFill.Create;   
        SWFFillTileBitmap, SWFFillClipBitmap,
        SWFFillNonSmoothTileBitmap, SWFFillNonSmoothClipBitmap:
           NewFS := TSWFImageFill.Create;
       end;
       NewFS.Assign(OldFS);
       self.FillStyles.Add(NewFS);
      end;
  end;
end;

function TSWFDefineShape.GetEdgeRecord(index: longint): TSWFShapeRecord;
begin
  Result := TSWFShapeRecord(Edges[index]);
end;

procedure TSWFDefineShape.ReadFromStream(be: TBitsEngine);
var
  PP: LongInt;
  StylesCount: Word;
  il: Word;
  FS: TSWFFillStyle;
  LS: TSWFLineStyle;
  b: Byte;
  nBitsFill, nBitsLine: Word;
begin
  PP := BE.BitsStream.Position;
  ShapeId := be.ReadWord;
  ShapeBounds.Rect := be.ReadRect;
  ReadAddonFromStream(be);
  StylesCount := be.ReadByte;
  if StylesCount = $FF then StylesCount := be.ReadWord;
  if StylesCount > 0 then
   for il := 1 to StylesCount do
    begin
      b := be.ReadByte;
      FS := nil;
      case b of
        SWFFillSolid:
           FS := TSWFColorFill.Create;
        SWFFillLinearGradient, SWFFillRadialGradient:
           FS := TSWFGradientFill.Create;
        SWFFillFocalGradient:
           FS := TSWFFocalGradientFill.Create;   
        SWFFillTileBitmap, SWFFillClipBitmap,
        SWFFillNonSmoothTileBitmap, SWFFillNonSmoothClipBitmap:
           FS := TSWFImageFill.Create;
      end;
      FS.SWFFillType := B;
      FS.hasAlpha := hasAlpha;
      FS.ReadFromStream(be);
      FillStyles.Add(FS);
    end;
  
  StylesCount := be.ReadByte;
  if StylesCount = $FF then StylesCount := be.ReadWord;
  if StylesCount > 0 then
   for il := 1 to StylesCount do
    begin
      if TagId = tagDefineShape4 then LS := TSWFLineStyle2.Create
        else LS := TSWFLineStyle.Create;
      LS.Color.hasAlpha := hasAlpha;
      LS.ReadFromStream(be);
      LineStyles.Add(LS)
    end;
  
  B := be.ReadByte;
  nBitsFill := B shr 4;
  nBitsLine := b and $F;
  
  ReadShapeRecord(be, Edges, nBitsFill, nBitsLine, self);
  
  be.BitsStream.Position := integer(BodySize) + PP;
end;

procedure TSWFDefineShape.WriteTagBody(be: TBitsEngine);
var
  W: Word;
  il: longint;
  nBitsFill, nBitsLine: Word;
begin
  be.WriteWord(ShapeId);
  be.WriteRect(ShapeBounds.Rect);
  WriteAddonToStream(be);
  w := FillStyles.Count;
  if w > $fe then
    begin
      BE.WriteByte($ff);
      BE.WriteWord(w);
    end else BE.WriteByte(w);
  if w > 0 then
  for il := 0 to w - 1 do
    with TSWFFillStyle(FillStyles.Items[il]) do
     begin
       hasAlpha := self.hasAlpha;
       WriteToStream(BE);
     end;

  w := LineStyles.Count;
  if w > $fe then
    begin
      BE.WriteByte($ff);
      BE.WriteWord(w);
    end else BE.WriteByte(w);
  if w > 0 then
  for il := 0 to w - 1 do
    with TSWFLineStyle(LineStyles.Items[il]) do
      begin
        Color.hasAlpha := hasAlpha;
        WriteToStream(BE);
      end;

  nBitsFill := GetBitsCount(FillStyles.Count);
  nBitsLine := GetBitsCount(LineStyles.Count);
  BE.WriteBits(nBitsFill, 4);
  BE.WriteBits(nBitsLine, 4);

  if Edges.Count > 0 then
    begin
     for il:=0 to Edges.Count - 1 do
      With TSWFShapeRecord(Edges[il]) do
       begin
         if ShapeRecType = StyleChangeRecord then
           with TSWFStyleChangeRecord(Edges[il]) do
            begin
              hasAlpha := self.hasAlpha;
              bitsFill := nBitsFill;
              bitsLine := nBitsLine;
              if StateNewStyles then
               else
               begin
                if bitsFill = 0 then
                  begin
                    StateFillStyle0 := false;
                    StateFillStyle1 := false;
                  end;
                if bitsLine = 0 then StateLineStyle := false;
               end;
            end;

         if (ShapeRecType <> EndShapeRecord) or
            ((ShapeRecType = EndShapeRecord) and (il = (Edges.Count - 1)))
             then WriteToStream(be);

         if (ShapeRecType = StyleChangeRecord) then
           with TSWFStyleChangeRecord(Edges[il]) do
           if StateNewStyles then
            begin
              nBitsFill := bitsFill;
              nBitsLine := bitsLine;
            end;

         if (il = (Edges.Count - 1)) and (ShapeRecType<>EndShapeRecord)
           then be.WriteBits(0, 6);  // add automtic end flag
       end;
    end else be.WriteBits(0, 6);  // end flag

  BE.FlushLastByte;
end;


procedure TSWFDefineShape.ReadAddonFromStream(be: TBitsEngine);
begin
  //
end;

procedure TSWFDefineShape.WriteAddonToStream(be: TBitsEngine); 
begin
  //
end;
{
***************************************************** TSWFDefineShape2 ******************************************************
}
constructor TSWFDefineShape2.Create;
begin
  inherited ;
  TagId := tagDefineShape2;
end;

function TSWFDefineShape2.MinVersion: Byte;
begin
  Result := SWFVer2;
end;

{
***************************************************** TSWFDefineShape3 ******************************************************
}
constructor TSWFDefineShape3.Create;
begin
  inherited ;
  TagId := tagDefineShape3;
  hasAlpha := true;
end;

function TSWFDefineShape3.MinVersion: Byte;
begin
  Result := SWFVer3;
end;

{
***************************************************** TSWFDefineShape4 ******************************************************
}
procedure TSWFDefineShape4.Assign(Source: TBasedSWFObject);
begin
  inherited;
  with TSWFDefineShape4(Source) do
    begin
      self.FEdgeBounds.Assign(FEdgeBounds);
      self.FUsesNonScalingStrokes := FUsesNonScalingStrokes;
      self.FUsesScalingStrokes := FUsesScalingStrokes;
    end;
end;

constructor TSWFDefineShape4.Create;
begin
  inherited ;
  TagId := tagDefineShape4;
  hasAlpha := true;
  FEdgeBounds := TSWFRect.Create;
end;

destructor TSWFDefineShape4.Destroy;
begin
 FEdgeBounds.Free;
 inherited;
end;

function TSWFDefineShape4.MinVersion: Byte;
begin
  Result := SWFVer8;
end;

procedure TSWFDefineShape4.ReadAddonFromStream(be: TBitsEngine);
 var b: byte;
begin
  EdgeBounds.Rect := be.ReadRect;
  b := be.ReadByte;
  UsesNonScalingStrokes := CheckBit(b, 2);
  UsesScalingStrokes := CheckBit(b, 1);
end;

procedure TSWFDefineShape4.WriteAddonToStream(be: TBitsEngine);
  var il: integer;
begin
  be.WriteRect(EdgeBounds.Rec);
  UsesNonScalingStrokes := false;
  UsesScalingStrokes := false;
  if LineStyles.Count > 0 then
   for il := 0 to LineStyles.Count - 1 do
     with TSWFLineStyle2(LineStyles[il]) do
       if NoHScaleFlag or NoVScaleFlag then UsesNonScalingStrokes := true
         else UsesScalingStrokes := true;
  be.WriteByte(byte(UsesNonScalingStrokes) shl 1 + byte(UsesScalingStrokes));
end;

// ==========================================================
//                      Bitmaps
// ==========================================================

{
****************************************************** TSWFDataObject *******************************************************
}
constructor TSWFDataObject.Create;
begin
  inherited;
  selfdestroy := true;
end;

destructor TSWFDataObject.Destroy;
begin
  if selfdestroy and (DataSize > 0) then FreeMem(Data, DataSize);
  inherited ;
end;

procedure TSWFDataObject.Assign(Source: TBasedSWFObject);
begin
  inherited;
  With TSWFDataObject(Source) do
  begin
    if Assigned(FOnDataWrite) then self.FOnDataWrite := OnDataWrite
      else
      begin
        if DataSize > 0 then
          begin
            self.DataSize := DataSize;
            GetMem(self.FData, DataSize);
            Move(Data^, self.FData^, DataSize);
          end;
        Self.SelfDestroy := SelfDestroy;
      end;
  end;
end;

{
******************************************************* TSWFImageTag ********************************************************
}
procedure TSWFImageTag.Assign(Source: TBasedSWFObject);
begin
  inherited;
  CharacterId := TSWFImageTag(Source).CharacterId;
end;

{
****************************************************** TSWFDefineBits *******************************************************
}
constructor TSWFDefineBits.Create;
begin
  inherited ;
  TagId := tagDefineBits;
end;

procedure TSWFDefineBits.ReadFromStream(be: TBitsEngine);
var
  ReadEnd: boolean;
begin
  CharacterID := be.ReadWord;
  DataSize := BodySize - 2;

  ReadEnd := true;
  SelfDestroy := true;
  DataSize := DataSize - 2;
  if be.ReadWord = $D9FF then
    begin
      be.ReadWord;
      DataSize := DataSize - 2;
      ReadEnd := false;
    end;

  if ReadEnd then DataSize := DataSize - 2;
  GetMem(FData, DataSize);
  be.BitsStream.Read(Data^, DataSize);
  if ReadEnd then be.ReadWord;

(*var
  Check: Word;
begin
  CharacterID := be.ReadWord;
  DataSize := BodySize - 2 * 2; // ID + End
  Repeat
   Check := be.ReadWord;
   DataSize := DataSize - 2;
  Until Check = $D8FF;
  GetMem(FData, DataSize);
  SelfDestroy := true;
  be.BitsStream.Read(Data^, DataSize);
  be.ReadWord;*)
end;

procedure TSWFDefineBits.WriteTagBody(be: TBitsEngine);
 var PW: PWord;
begin
  be.WriteWord(CharacterID);
  if Assigned(OnDataWrite) then OnDataWrite(self, be) else
   begin
     PW := Data;
     if PW^ =  $D8FF then be.WriteWord($D9FF);
     be.WriteWord($D8FF);

     if DataSize > 0 then be.BitsStream.Write(Data^, DataSize);

     if PW^ <> $D8FF then be.WriteWord($D9FF);
    end;
(*
  be.WriteByte($FF);
  be.WriteByte($D8);

  if Assigned(OnDataWrite) then OnDataWrite(self, be) else
    if DataSize > 0 then be.BitsStream.Write(Data^, DataSize);

  be.WriteByte($FF);
  be.WriteByte($D9); *)
end;


{
****************************************************** TSWFJPEGTables *******************************************************
}
constructor TSWFJPEGTables.Create;
begin
  inherited ;
  TagID := tagJPEGTables;
end;

procedure TSWFJPEGTables.ReadFromStream(be: TBitsEngine);
var
  ReadEnd: boolean;
begin
  ReadEnd := true;
  SelfDestroy := true;
  DataSize := BodySize;

  DataSize := DataSize - 2;
  if be.ReadWord = $D9FF then
    begin
      be.ReadWord;
      DataSize := DataSize - 2;
      ReadEnd := false;
    end;

  if ReadEnd then DataSize := DataSize - 2;
  GetMem(FData, DataSize);
  be.BitsStream.Read(Data^, DataSize);
  if ReadEnd then be.ReadWord;
end;

procedure TSWFJPEGTables.WriteTagBody(be: TBitsEngine);
 var PW: PWord;
begin
 if Assigned(OnDataWrite) then OnDataWrite(self, be) else
   if DataSize > 0 then
   begin
     PW := Data;
     if PW^ =  $D8FF then be.WriteWord($D9FF);
     be.WriteWord($D8FF);

     if DataSize > 0 then be.BitsStream.Write(Data^, DataSize);

     if PW^ <> $D8FF then be.WriteWord($D9FF);
    end;
end;


{
**************************************************** TSWFDefineBitsJPEG2 ****************************************************
}
constructor TSWFDefineBitsJPEG2.Create;
begin
  inherited ;
  TagId := tagDefineBitsJPEG2;
end;

function TSWFDefineBitsJPEG2.MinVersion: Byte;
begin
  Result := SWFVer2;
end;
	  
procedure TSWFDefineBitsJPEG2.WriteTagBody(be: TBitsEngine);
begin
  inherited;
(*
  be.WriteWord(CharacterID);

  be.WriteByte($ff);
  be.WriteByte($d9);

  be.WriteByte($FF);
  be.WriteByte($D8);

  if Assigned(OnDataWrite) then OnDataWrite(self, be) else

  if DataSize > 0 then be.BitsStream.Write(Data^, DataSize);

  be.WriteByte($FF);
  be.WriteByte($D9);   *)

end;

{
**************************************************** TSWFDefineBitsJPEG3 ****************************************************
}
constructor TSWFDefineBitsJPEG3.Create;
begin
  inherited ;
  TagId := tagDefineBitsJPEG3;
end;

destructor TSWFDefineBitsJPEG3.Destroy;
begin
  if SelfAlphaDestroy and (AlphaDataSize > 0) then FreeMem(AlphaData, AlphaDataSize);
  inherited ;
end;

procedure TSWFDefineBitsJPEG3.Assign(Source: TBasedSWFObject);
begin
  inherited;
  With TSWFDefineBitsJPEG3(Source) do
  begin
    if Assigned(FOnAlphaDataWrite) then self.FOnAlphaDataWrite := OnAlphaDataWrite
      else
      begin
        if AlphaDataSize > 0 then
          begin
            self.AlphaDataSize := AlphaDataSize;
            GetMem(Self.FAlphaData, AlphaDataSize);
            Move(AlphaData^, self.FAlphaData^, AlphaDataSize);
          end;
        Self.SelfAlphaDestroy := SelfAlphaDestroy;
      end;
  end;
end;

function TSWFDefineBitsJPEG3.MinVersion: Byte;
begin
  Result := SWFVer3;
end;

procedure TSWFDefineBitsJPEG3.ReadFromStream(be: TBitsEngine);
 var ReadEnd: boolean;
     del: word;
begin
  SelfDestroy := true;
  SelfAlphaDestroy := true;
  CharacterID := be.ReadWord;
  ReadEnd := true;
  DataSize := be.ReadDWord;
  // 4 = SMarker(2) + EMarker(2)
  if be.ReadWord = $D9FF then
    begin
      be.ReadWord;
      ReadEnd := false;
    end;
  del := 4;  
  DataSize := DataSize - del;
  GetMem(FData, DataSize);
  be.BitsStream.Read(Data^, DataSize);
  if ReadEnd then be.ReadWord;

  // 6 = AlphaOffset(4) + CharacterID(2)
  AlphaDataSize := Integer(BodySize) - DataSize - del - 4;
  GetMem(FAlphaData, AlphaDataSize);
  be.BitsStream.Read(AlphaData^, AlphaDataSize);
end;

procedure TSWFDefineBitsJPEG3.WriteTagBody(be: TBitsEngine);
var
  pp: dword;
  PW: PWord;
begin
  be.WriteWord(CharacterID);
  pp := be.BitsStream.Position;
  PW := Data;

  be.WriteDWord(0);
  if Assigned(OnDataWrite) then OnDataWrite(self, be) else
    begin
     if PW^ = $D8FF then be.WriteWord($D9FF);
     be.WriteWord($D8FF);
     if DataSize > 0 then be.BitsStream.Write(Data^, DataSize);
     if PW^ <> $D8FF then be.WriteWord($D9FF);
    end;
  be.BitsStream.Position := PP;
  PP := be.BitsStream.Size - PP - 4;
  be.WriteDWord(PP);
  be.BitsStream.Position := be.BitsStream.Size;

  if Assigned(FOnAlphaDataWrite) then OnAlphaDataWrite(self, be) else
   if AlphaDataSize > 0 then be.BitsStream.Write(AlphaData^, AlphaDataSize);
end;

{
************************************************** TSWFDefineBitsLossless ***************************************************
}
constructor TSWFDefineBitsLossless.Create;
begin
  inherited ;
  TagId := tagDefineBitsLossless;
end;

procedure TSWFDefineBitsLossless.Assign(Source: TBasedSWFObject);
begin
  inherited;
  With TSWFDefineBitsLossless(Source) do
  begin
    self.BitmapColorTableSize := BitmapColorTableSize;
    self.BitmapFormat := BitmapFormat;
    self.BitmapHeight := BitmapHeight;
    self.BitmapWidth := BitmapWidth;
  end;
end;

function TSWFDefineBitsLossless.MinVersion: Byte;
begin
  Result := SWFVer2;
end;

procedure TSWFDefineBitsLossless.ReadFromStream(be: TBitsEngine);
var
  PP: dword;
begin
  pp := be.BitsStream.Position;
  CharacterID := be.ReadWord;
  BitmapFormat := be.ReadByte;
  BitmapWidth := be.ReadWord;
  BitmapHeight := be.ReadWord;
  if BitmapFormat = BMP_8bit then BitmapColorTableSize := be.ReadByte;

  // pp := be.BitsStream.Position;
  DataSize := BodySize - (be.BitsStream.Position - PP);
  selfdestroy := true;
  GetMem(FData, DataSize);
  be.BitsStream.Read(Data^, DataSize);
end;

procedure TSWFDefineBitsLossless.WriteTagBody(be: TBitsEngine);
begin
  BE.WriteWord(CharacterID);
  BE.WriteByte(BitmapFormat); // type
  BE.WriteWord(BitmapWidth);
  BE.WriteWord(BitmapHeight);
  if BitmapFormat = BMP_8bit then BE.WriteByte(BitmapColorTableSize);
  if Assigned(OnDataWrite) then OnDataWrite(self, be) else
    if DataSize > 0 then be.BitsStream.Write(Data^, DataSize);
end;

{
************************************************** TSWFDefineBitsLossless2 **************************************************
}
constructor TSWFDefineBitsLossless2.Create;
begin
  inherited ;
  TagId := tagDefineBitsLossless2;
end;

function TSWFDefineBitsLossless2.MinVersion: Byte;
begin
  Result := SWFVer3;
end;


// ==========================================================
//                      Morphing
// ==========================================================

{
**************************************************** TSWFMorphColorFill *****************************************************
}
constructor TSWFMorphColorFill.Create;
begin
  inherited ;
  SWFFillType := SWFFillSolid;
  FStartColor := TSWFRGBA.Create(true);
  FEndColor := TSWFRGBA.Create(true);
end;

destructor TSWFMorphColorFill.Destroy;
begin
  FStartColor.Free;
  FEndColor.Free;
  inherited Destroy;
end;

procedure TSWFMorphColorFill.Assign(Source: TSWFMorphFillStyle);
begin
  With TSWFMorphColorFill(Source) do
  begin
    self.StartColor.Assign(StartColor);
    self.EndColor.Assign(EndColor);
  end;
end;

procedure TSWFMorphColorFill.ReadFromStream(be: TBitsEngine);
begin
  StartColor.RGBA := be.ReadRGBA;
  EndColor.RGBA := be.ReadRGBA;
end;

procedure TSWFMorphColorFill.WriteToStream(be: TBitsEngine);
begin
  be.WriteByte(SWFFillType);
  be.WriteColor(StartColor.RGBA);
  be.WriteColor(EndColor.RGBA);
end;

{
*************************************************** TSWFMorphGradientFill ***************************************************
}
constructor TSWFMorphGradientFill.Create;
begin
  inherited ;
  SWFFillType := SWFFillLinearGradient;
  FStartColor[1] := TSWFRGBA.Create(true);
  FStartColor[2] := TSWFRGBA.Create(true);
  FEndColor[1] := TSWFRGBA.Create(true);
  FEndColor[2] := TSWFRGBA.Create(true);
  FStartMatrix := TSWFMatrix.Create;
  FEndMatrix := TSWFMatrix.Create;
end;

destructor TSWFMorphGradientFill.Destroy;
var
  il: Byte;
begin
  For il := 1 to 8 do
    begin
     if FStartColor[il] <> nil then FStartColor[il].Free;
     if FEndColor[il] <> nil then FEndColor[il].Free;
    end;
  FStartMatrix.Free;
  FEndMatrix.Free;
  inherited Destroy;
end;

procedure TSWFMorphGradientFill.Assign(Source: TSWFMorphFillStyle);
var
  il: Byte;
begin
  with TSWFMorphGradientFill(Source) do
  begin
    self.Count := Count;
    self.StartMatrix.Assign(StartMatrix);
    self.EndMatrix.Assign(EndMatrix);
    if Count > 0 then
    For il := 1 to Count do
     begin
       self.FStartRatio[il] := FStartRatio[il];
       self.FEndRatio[il] := FEndRatio[il];
       self.StartColor[il].Assign(StartColor[il]);
       self.EndColor[il].Assign(EndColor[il]);
     end;
  end;
end;

function TSWFMorphGradientFill.GetEndColor(Index: Integer): TSWFRGBA;
begin
  if FEndColor[index] = nil then FEndColor[index] := TSWFRGBA.Create(true);
  Result := FEndColor[index];
end;

function TSWFMorphGradientFill.GetEndGradient(Index: byte): TSWFGradientRec;
begin
  Result.color := EndColor[index].RGBA;
  Result.Ratio := FEndRatio[index];
end;

function TSWFMorphGradientFill.GetEndRatio(Index: Integer): Byte;
begin
  Result := FEndRatio[index];
end;

function TSWFMorphGradientFill.GetGradient(Index: byte): TSWFMorphGradientRec;
begin
  Result.StartColor := StartColor[index].RGBA;
  Result.StartRatio := FStartRatio[index];
  Result.EndColor := EndColor[index].RGBA;
  Result.EndRatio := FEndRatio[index];
end;

function TSWFMorphGradientFill.GetStartColor(Index: Integer): TSWFRGBA;
begin
  if FStartColor[index] = nil then FStartColor[index] := TSWFRGBA.Create(true);
  Result := FStartColor[index];
end;

function TSWFMorphGradientFill.GetStartGradient(Index: byte): TSWFGradientRec;
begin
  Result.color := StartColor[index].RGBA;
  Result.Ratio := FStartRatio[index];
end;

function TSWFMorphGradientFill.GetStartRatio(Index: Integer): Byte;
begin
  Result := FStartRatio[index];
end;

procedure TSWFMorphGradientFill.ReadFromStream(be: TBitsEngine);
var
  il, bc: Byte;
begin
  StartMatrix.Rec := be.ReadMatrix;
  EndMatrix.Rec := be.ReadMatrix;

  bc := be.ReadByte;
  SpreadMode := bc shr 6;
  InterpolationMode := (bc shr 4) and 3;
  Count := bc and 15;

  if Count > 0 then
  for il := 1 to Count do
   begin
    StartRatio[il] := be.ReadByte;
    StartColor[il].RGBA := be.ReadRGBA;
    EndRatio[il] := be.ReadByte;
    EndColor[il].RGBA := be.ReadRGBA;
   end;
end;

procedure TSWFMorphGradientFill.SetEndRatio(Index: Integer; Value: Byte);
begin
  FEndRatio[index] := Value;
end;

procedure TSWFMorphGradientFill.SetStartRatio(Index: Integer; Value: Byte);
begin
  FStartRatio[index] := Value;
end;

procedure TSWFMorphGradientFill.WriteToStream(be: TBitsEngine);
var
  il: Byte;
begin
  be.WriteByte(SWFFillType);
  be.WriteMatrix(StartMatrix.Rec);
  be.WriteMatrix(EndMatrix.Rec);
  be.WriteByte(Count);
  For il := 1 to Count do
    begin
      be.WriteByte(StartRatio[il]);
      be.WriteColor(StartColor[il].RGBA);
      be.WriteByte(EndRatio[il]);
      be.WriteColor(EndColor[il].RGBA)
    end;
end;


{
************************************************ TSWFMorphFocalGradientFill *************************************************
}

constructor TSWFMorphFocalGradientFill.Create;
begin
  inherited;
  SWFFillType := SWFFillFocalGradient;
end;


function TSWFMorphFocalGradientFill.GetStartFocalPoint: single;
begin
  Result := FStartFocalPoint/255;
  if Result > 1 then Result := 1 else
    if Result < -1 then Result := -1;
end;

function TSWFMorphFocalGradientFill.GetEndFocalPoint: single;
begin
  Result := FEndFocalPoint/255;
  if Result > 1 then Result := 1 else
    if Result < -1 then Result := -1;
end;

procedure TSWFMorphFocalGradientFill.ReadFromStream(be: TBitsEngine);
begin
  inherited;
  FStartFocalPoint := smallint(be.ReadWord);
  FEndFocalPoint := smallint(be.ReadWord);
end;

procedure TSWFMorphFocalGradientFill.SetStartFocalPoint(const Value: single);
begin
  FStartFocalPoint := Round(value * 255);
  if FStartFocalPoint > 255 then FStartFocalPoint := 255 else
    if FStartFocalPoint < -255 then FStartFocalPoint := -255;
end;

procedure TSWFMorphFocalGradientFill.SetEndFocalPoint(const Value: single);
begin
  FEndFocalPoint := Round(value * 255);
  if FEndFocalPoint > 255 then FEndFocalPoint := 255 else
    if FEndFocalPoint < -255 then FEndFocalPoint := -255;
end;

procedure TSWFMorphFocalGradientFill.WriteToStream(be: TBitsEngine);
begin
  inherited;
  be.WriteWord(word(FStartFocalPoint));
  be.WriteWord(word(FEndFocalPoint));
end;

{
**************************************************** TSWFMorphImageFill *****************************************************
}
constructor TSWFMorphImageFill.Create;
begin
  inherited ;
  SWFFillType := SWFFillClipBitmap;
  FStartMatrix := TSWFMatrix.Create;
  FEndMatrix := TSWFMatrix.Create;
end;

destructor TSWFMorphImageFill.Destroy;
begin
  FStartMatrix.Free;
  FEndMatrix.Free;
  inherited Destroy;
end;

procedure TSWFMorphImageFill.Assign(Source: TSWFMorphFillStyle);
begin
  with TSWFImageFill(Source) do
  begin
    self.StartMatrix.Assign(StartMatrix);
    self.EndMatrix.Assign(EndMatrix);
    self.ImageID := ImageID;
  end;
end;

procedure TSWFMorphImageFill.ReadFromStream(be: TBitsEngine);
begin
  ImageID := be.ReadWord;
  StartMatrix.Rec := be.ReadMatrix;
  EndMatrix.Rec := be.ReadMatrix;
end;

procedure TSWFMorphImageFill.WriteToStream(be: TBitsEngine);
begin
  be.WriteByte(SWFFillType);
  be.WriteWord(ImageID);
  be.WriteMatrix(StartMatrix.Rec);
  be.WriteMatrix(EndMatrix.Rec);
end;


{
**************************************************** TSWFMorphLineStyle *****************************************************
}
constructor TSWFMorphLineStyle.Create;
begin
  FStartColor := TSWFRGBA.Create(true);
  FEndColor := TSWFRGBA.Create(true);
end;

destructor TSWFMorphLineStyle.Destroy;
begin
  FStartColor.Free;
  FEndColor.Free;
  inherited Destroy;
end;

procedure TSWFMorphLineStyle.Assign(Source: TSWFMorphLineStyle);
begin
  StartWidth := Source.StartWidth;
  StartColor.Assign(Source.StartColor);
  EndWidth := Source.EndWidth;
  EndColor.Assign(Source.EndColor);
end;

procedure TSWFMorphLineStyle.ReadFromStream(be: TBitsEngine);
begin
  StartWidth := be.ReadWord;
  EndWidth := be.ReadWord;
  StartColor.RGBA := be.ReadRGBA;
  EndColor.RGBA := be.ReadRGBA;
end;

procedure TSWFMorphLineStyle.WriteToStream(be: TBitsEngine);
begin
  be.WriteWord(StartWidth);
  be.WriteWord(EndWidth);
  be.WriteColor(StartColor.RGBA);
  be.WriteColor(EndColor.RGBA);
end;


{
**************************************************** TSWFMorphLineStyle2 *****************************************************
}
destructor TSWFMorphLineStyle2.Destroy;
begin
  if FFillStyle <> nil then FFillStyle.Free;
  inherited;
end;

function TSWFMorphLineStyle2.GetFillStyle(style: integer): TSWFFillStyle;
 var fmake: boolean;
begin
 if style > -1 then
  begin
   fmake := true;
   if FFillStyle <> nil then
     begin
       if FFillStyle.SWFFillType <> style then FFillStyle.Free
         else fmake := false;
     end;
   if fmake then
    case style of
     SWFFillSolid:
        FFillStyle := TSWFColorFill.Create;
     SWFFillLinearGradient, SWFFillRadialGradient:
        FFillStyle := TSWFGradientFill.Create;
     SWFFillFocalGradient:
        FFillStyle := TSWFFocalGradientFill.Create;
     SWFFillTileBitmap, SWFFillClipBitmap,
     SWFFillNonSmoothTileBitmap, SWFFillNonSmoothClipBitmap:
        FFillStyle := TSWFImageFill.Create;
    end;
  end;
 Result := FFillStyle;
end;

procedure TSWFMorphLineStyle2.ReadFromStream(be: TBitsEngine);
 var b: byte;
begin
  StartWidth := be.ReadWord;
  EndWidth := be.ReadWord;
  b := be.ReadByte;
  StartCapStyle := b shr 6;
  JoinStyle := (b shr 4) and 3;
  HasFillFlag := CheckBit(b, 4);
  NoHScaleFlag := CheckBit(b, 3);
  NoVScaleFlag := CheckBit(b, 2);
  PixelHintingFlag := CheckBit(b, 1);
  b := be.ReadByte;
  NoClose := CheckBit(b, 3);
  EndCapStyle := b and 3;
  if JoinStyle = 2 then
    MiterLimitFactor := WordToSingle(be.ReadWord);
  if HasFillFlag
    then GetFillStyle(be.ReadByte).ReadFromStream(be)
    else
     begin
      StartColor.RGBA := be.ReadRGBA;
      EndColor.RGBA := be.ReadRGBA;
     end;
end;

procedure TSWFMorphLineStyle2.WriteToStream(be: TBitsEngine);
begin
  be.WriteWord(StartWidth);
  be.WriteWord(EndWidth);
  be.WriteBits(StartCapStyle, 2);
  be.WriteBits(JoinStyle, 2);
  be.WriteBit(HasFillFlag);
  be.WriteBit(NoHScaleFlag);
  be.WriteBit(NoVScaleFlag);
  be.WriteBit(PixelHintingFlag);
  be.WriteBits(0, 5);
  be.WriteBit(NoClose);
  be.WriteBits(EndCapStyle, 2);

  if JoinStyle = 2 then
    be.WriteWord(SingleToWord(MiterLimitFactor));
  if HasFillFlag
    then GetFillStyle(-1).WriteToStream(be)
    else
     begin
       be.WriteColor(StartColor.RGBA);
       be.WriteColor(EndColor.RGBA);
     end
end;


{
*************************************************** TSWFDefineMorphShape ****************************************************
}
constructor TSWFDefineMorphShape.Create;
begin
  TagID := tagDefineMorphShape;
  FStartBounds := TSWFRect.Create;
  FEndBounds := TSWFRect.Create;
  FMorphLineStyles := TObjectList.Create;
  FMorphFillStyles := TObjectList.Create;
  FStartEdges := TObjectList.Create;
  FEndEdges := TObjectList.Create;
end;

destructor TSWFDefineMorphShape.Destroy;
begin
  FStartBounds.Free;
  FEndBounds.Free;
  FMorphLineStyles.Free;
  FMorphFillStyles.Free;
  FStartEdges.Free;
  FEndEdges.Free;
  inherited;
end;

procedure TSWFDefineMorphShape.Assign(Source: TBasedSWFObject);
var
  il: Word;
  LS: TSWFMorphLineStyle;
  NewFS, OldFS: TSWFMorphFIllStyle;
begin
  inherited;
  With TSWFDefineMorphShape(Source) do
  begin
    self.CharacterId := CharacterId;
    self.StartBounds.Assign(StartBounds);
    self.EndBounds.Assign(EndBounds);

    CopyShapeRecords(StartEdges, Self.StartEdges);
    CopyShapeRecords(EndEdges, Self.EndEdges);
  
    if MorphLineStyles.Count > 0 then
     for il := 0 to MorphLineStyles.Count -1 do
      begin
       if MorphLineStyles[il] is TSWFMorphLineStyle2
         then LS := TSWFMorphLineStyle2.Create
         else LS := TSWFMorphLineStyle.Create;
       LS.Assign(TSWFMorphLineStyle(MorphLineStyles[il]));
       self.MorphLineStyles.Add(LS);
      end;
  
    if MorphFillStyles.Count > 0 then
     for il := 0 to MorphFillStyles.Count -1 do
      begin
       OldFS := TSWFMorphFillStyle(MorphFillStyles[il]);
       NewFS := nil;
       Case OldFS.SWFFillType of
        SWFFillSolid:
           NewFS := TSWFMorphColorFill.Create;
        SWFFillLinearGradient, SWFFillRadialGradient:
           NewFS := TSWFMorphGradientFill.Create;
        SWFFillTileBitmap, SWFFillClipBitmap,
        SWFFillNonSmoothTileBitmap, SWFFillNonSmoothClipBitmap:
           NewFS := TSWFMorphImageFill.Create;
       end;
       NewFS.Assign(OldFS);
       self.MorphFillStyles.Add(NewFS);
      end;
  end;
end;

function TSWFDefineMorphShape.GetEndEdgeRecord(Index: Integer): TSWFShapeRecord;
begin
  Result := TSWFShapeRecord(EndEdges[index]);
end;

function TSWFDefineMorphShape.GetStartEdgeRecord(Index: Integer): TSWFShapeRecord;
begin
  Result := TSWFShapeRecord(StartEdges[index]);
end;

function TSWFDefineMorphShape.MinVersion: Byte;
begin
  Result := SWFVer3;
end;

procedure TSWFDefineMorphShape.ReadFromStream(be: TBitsEngine);
var
  PP: LongInt;
  StylesCount: Word;
  il: Word;
  FS: TSWFMorphFillStyle;
  LS: TSWFMorphLineStyle;
  b: Byte;
  nBitsFill, nBitsLine: Word;
//  Offset: DWord;
begin
  PP := BE.BitsStream.Position;
  CharacterId := be.ReadWord;
  StartBounds.Rect := be.ReadRect;
  EndBounds.Rect := be.ReadRect;
  ReadAddonFromStream(be);
  {Offset :=} be.ReadDWord;
  // PP2 := BE.BitsStream.Position;
  
  StylesCount := be.ReadByte;
  if StylesCount = $FF then StylesCount := be.ReadWord;
  if StylesCount > 0 then
   for il := 1 to StylesCount do
    begin
      b := be.ReadByte;
      FS := nil;
      case b of
        SWFFillSolid:
           FS := TSWFMorphColorFill.Create;
        SWFFillLinearGradient, SWFFillRadialGradient:
           FS := TSWFMorphGradientFill.Create;
        SWFFillFocalGradient:
           FS := TSWFMorphFocalGradientFill.Create;
        SWFFillTileBitmap, SWFFillClipBitmap,
        SWFFillNonSmoothTileBitmap, SWFFillNonSmoothClipBitmap:
           FS := TSWFMorphImageFill.Create;
      end;
      FS.SWFFillType := b;
      FS.ReadFromStream(be);
      MorphFillStyles.Add(FS);
    end;
  
  StylesCount := be.ReadByte;
  if StylesCount = $FF then StylesCount := be.ReadWord;
  if StylesCount > 0 then
   for il := 1 to StylesCount do
    begin
     LS := TSWFMorphLineStyle.Create;
     LS.ReadFromStream(be);
     MorphLineStyles.Add(LS)
    end;
  
  b := be.ReadByte;
  nBitsFill := b shr 4;
  nBitsLine := b and $F;
  ReadShapeRecord(be, StartEdges, nBitsFill, nBitsLine, nil);
  
  //  be.BitsStream.Position := Offset + pp2;

  b := be.ReadByte;
  nBitsFill := b shr 4;
  nBitsLine := b and $F;
  ReadShapeRecord(be, EndEdges, nBitsFill, nBitsLine, nil);

  be.BitsStream.Position := Longint(BodySize) + PP;
end;

procedure TSWFDefineMorphShape.WriteTagBody(be: TBitsEngine);
var
  W: Word;
  il: Integer;
  nBitsFill, nBitsLine: Word;
  Offset: DWord;
begin
  be.WriteWord(CharacterId);
  be.WriteRect(StartBounds.Rect);
  be.WriteRect(EndBounds.Rect);
  WriteAddonToStream(be);
  Offset := be.BitsStream.Position;
  be.WriteDWord(Offset);

  w := MorphFillStyles.Count;
  if w > $fe then
    begin
      BE.WriteByte($ff);
      BE.WriteWord(w);
    end else BE.WriteByte(w);
  if w > 0 then
  for il := 0 to w - 1 do
    with TSWFMorphFillStyle(MorphFillStyles.Items[il]) do
       WriteToStream(BE);
  
  w := MorphLineStyles.Count;
  if w > $fe then
    begin
      BE.WriteByte($ff);
      BE.WriteWord(w);
    end else BE.WriteByte(w);
  if w > 0 then
  for il := 0 to w - 1 do
    with TSWFMorphLineStyle(MorphLineStyles.Items[il]) do
       WriteToStream(BE);

  nBitsFill := GetBitsCount(MorphFillStyles.Count);
  nBitsLine := GetBitsCount(MorphLineStyles.Count);
  BE.WriteBits(nBitsFill, 4);
  BE.WriteBits(nBitsLine, 4);
  
  if StartEdges.Count > 0 then
    begin
     for il:=0 to StartEdges.Count - 1 do
      With StartEdgeRecord[il] do
       begin
         if ShapeRecType = StyleChangeRecord then
           with TSWFStyleChangeRecord(StartEdges[il]) do
            begin
              bitsFill := nBitsFill;
              bitsLine := nBitsLine;
              if MorphFillStyles.Count = 0 then
                begin
                  StateFillStyle0 := false;
                  StateFillStyle1 := false;
                end;
              if MorphLineStyles.Count = 0 then StateLineStyle := false;
            end;
         WriteToStream(be);
         if (il = (StartEdges.Count - 1)) and (ShapeRecType<>EndShapeRecord)
           then be.WriteBits(0, 6);  // add automtic end flag
       end;
    end else be.WriteBits(0, 6);  // end flag
  
  BE.FlushLastByte;
  BE.BitsStream.Position := Offset;
  BE.WriteDWord(BE.BitsStream.Size - Offset - 4);
  BE.BitsStream.Seek(0, 2);
  if TagID = tagDefineMorphShape then
    begin
      nBitsFill := 0;
      nBitsLine := 0;
      BE.WriteByte(0);
    end else
    begin
      BE.WriteBits(nBitsFill, 4);
      BE.WriteBits(nBitsLine, 4);
    end;
  if EndEdges.Count > 0 then
    begin
     for il:=0 to EndEdges.Count - 1 do
      With EndEdgeRecord[il] do
       begin
         if ShapeRecType = StyleChangeRecord then
           with TSWFStyleChangeRecord(EndEdges[il]) do
            begin
              bitsFill := nBitsFill;
              bitsLine := nBitsLine;
              if MorphFillStyles.Count = 0 then
                begin
                  StateFillStyle0 := false;
                  StateFillStyle1 := false;
                end;
              if MorphLineStyles.Count = 0 then StateLineStyle := false;              
{              StateFillStyle0 := false;
              StateFillStyle1 := false;
              StateLineStyle := false;}
            end;
         WriteToStream(be);
         if (il = (EndEdges.Count - 1)) and (ShapeRecType<>EndShapeRecord)
           then be.WriteBits(0, 6);  // add automtic end flag
       end;
    end else be.WriteBits(0, 6);  // end flag
  BE.FlushLastByte;
end;


procedure TSWFDefineMorphShape.ReadAddonFromStream(be: TBitsEngine);
begin
  //
end;

procedure TSWFDefineMorphShape.WriteAddonToStream(be: TBitsEngine);
begin
  //
end;


{
*************************************************** TSWFDefineMorphShape2 *****************************************************
}
constructor TSWFDefineMorphShape2.Create;
begin
  inherited;
  TagId := tagDefineMorphShape2;
  FStartEdgeBounds := TSWFRect.Create;
  FEndEdgeBounds := TSWFRect.Create;
end;

destructor TSWFDefineMorphShape2.Destroy;
begin
 FStartEdgeBounds.Free;
 FEndEdgeBounds.Free;
 inherited;
end;

procedure TSWFDefineMorphShape2.Assign(Source: TBasedSWFObject);
 var il: integer;
     LS2: TSWFMorphLineStyle2;
begin
  inherited;
  if Source is TSWFDefineMorphShape2 then
   with TSWFDefineMorphShape2(Source) do
    begin
      self.StartEdgeBounds.Assign(StartEdgeBounds);
      self.EndEdgeBounds.Assign(EndEdgeBounds);
    end else
    begin
      StartEdgeBounds.Assign(StartBounds);
      EndEdgeBounds.Assign(EndBounds);
      if MorphLineStyles.Count > 0 then
       for il := 0 to MorphLineStyles.Count - 1 do
        if not (MorphLineStyles[il] is TSWFMorphLineStyle2) then
         begin
           LS2 := TSWFMorphLineStyle2.Create;
           With TSWFMorphLineStyle(MorphLineStyles[il]) do
             begin
               LS2.StartWidth := StartWidth;
               LS2.EndWidth := EndWidth;
               LS2.StartColor.Assign(StartColor);
               LS2.EndColor.Assign(EndColor);
             end;
           MorphLineStyles.Insert(il, LS2);
           MorphLineStyles.Delete(il+1);
         end;
    end;
end;

procedure TSWFDefineMorphShape2.ReadAddonFromStream(be: TBitsEngine);
 var b: byte;
begin
  StartEdgeBounds.Rect := be.ReadRect;
  EndEdgeBounds.Rect := be.ReadRect;
  b := be.ReadByte;
  UsesNonScalingStrokes := CheckBit(b, 2);
  UsesScalingStrokes := CheckBit(b, 1);
end;

procedure TSWFDefineMorphShape2.WriteAddonToStream(be: TBitsEngine);
  var il: integer;
begin
  be.WriteRect(StartEdgeBounds.Rec);
  be.WriteRect(EndEdgeBounds.Rec);
  UsesNonScalingStrokes := false;
  UsesScalingStrokes := false;
  if MorphLineStyles.Count > 0 then
   for il := 0 to MorphLineStyles.Count - 1 do
     with TSWFLineStyle2(MorphLineStyles[il]) do
       if NoHScaleFlag or NoVScaleFlag then UsesNonScalingStrokes := true
         else UsesScalingStrokes := true;
  be.WriteByte(byte(UsesNonScalingStrokes) shl 1 + byte(UsesScalingStrokes));
end;


// ==========================================================
//                        TEXT
// ==========================================================

{
****************************************************** TSWFDefineFont *******************************************************
}
constructor TSWFDefineFont.Create;
begin
  TagId := tagDefineFont;
  GlyphShapeTable := TObjectList.Create;
end;

destructor TSWFDefineFont.Destroy;
begin
  GlyphShapeTable.free;
  inherited;
end;

procedure TSWFDefineFont.Assign(Source: TBasedSWFObject);
var
  OldEdges, NewEdges: TObjectList;
  il: Word;
begin
  inherited;
  With TSWFDefineFont(Source) do
  begin
    self.FontId := FontId;
    if GlyphShapeTable.Count > 0 then
    for il := 0 to GlyphShapeTable.Count - 1 do
      begin
        OldEdges := TObjectList(GlyphShapeTable.Items[il]);
        NewEdges := TObjectList.Create;
        CopyShapeRecords(OldEdges, NewEdges);
        self.GlyphShapeTable.Add(NewEdges);
      end;
  end;
end;

procedure TSWFDefineFont.ReadFromStream(be: TBitsEngine);
var
  pp: dword;
  il: Word;
  Offset: Word;
  OffsetTable: TList;
  Edges: TObjectList;
  B: Byte;
begin
  pp := be.BitsStream.Position;
  FontID := be.ReadWord;
  OffsetTable := TList.Create;
  il := 0;
  Repeat
    Offset := be.ReadWord;
    if il = 0 then nGlyphs := Offset div 2;
    OffsetTable.Add(Pointer(Offset));
    inc(il);
  until il = nGlyphs;
  
  For il := 0 to nGlyphs - 1 do
   begin
    Edges := TObjectList.Create;
    B := be.ReadByte;
    ReadShapeRecord(be, Edges, b shr 4, b and $F, nil);
    GlyphShapeTable.Add(Edges);
   end;
  OffsetTable.Free;
  be.BitsStream.Position := pp + BodySize;
end;

procedure TSWFDefineFont.WriteTagBody(be: TBitsEngine);
var
  OffsetTable: TList;
  PP: LongInt;
  il, il2: Word;
  Edges: TObjectList;
begin
  be.WriteWord(FontID);
  OffsetTable := TList.Create;
  if GlyphShapeTable.Count = 0 then be.WriteWord(0) else
    begin
      PP := be.BitsStream.Position;
      for il := 1 to GlyphShapeTable.Count do be.WriteWord(0);
      for il := 0 to GlyphShapeTable.Count - 1 do
        begin
         OffsetTable.Add(Pointer(be.BitsStream.Position - PP));
  
         BE.WriteByte($10);
  
         Edges := TObjectList(GlyphShapeTable.Items[il]);

         if Edges.Count > 0 then
           begin
            for il2 := 0 to Edges.Count - 1 do
             With TSWFShapeRecord(Edges[il2]) do
              begin
                if ShapeRecType = StyleChangeRecord then
                  with TSWFStyleChangeRecord(Edges[il2]) do
                   begin
                     bitsFill := 1;
                     bitsLine := 0;
                 {    StateFillStyle0 := false;
                     StateFillStyle1 := true;
                     Fill1Id := 1;
                     StateLineStyle := true; }
                   end;
                WriteToStream(be);
                if (il2 = (Edges.Count - 1)) and (ShapeRecType<>EndShapeRecord)
                  then be.WriteBits(0, 6);  // add automtic end flag
              end;
           end else be.WriteBits(0, 6);  // end flag
         BE.FlushLastByte;
        end;
      be.BitsStream.Position := PP;
      for il := 0 to OffsetTable.Count - 1 do
        be.WriteWord(LongInt(OffsetTable[il]));
      be.BitsStream.Position := be.BitsStream.Size;
    end;

  OffsetTable.Free;
end;


{
**************************************************** TSWFDefineFontInfo *****************************************************
}
constructor TSWFDefineFontInfo.Create;
begin
  TagId := tagDefineFontInfo;
  FCodeTable := TList.Create;
end;

destructor TSWFDefineFontInfo.Destroy;
begin
  CodeTable.Free;
  inherited;
end;

procedure TSWFDefineFontInfo.Assign(Source: TBasedSWFObject);
var
  il: Word;
begin
  inherited;
  With TSWFDefineFontInfo(Source) do
  begin
    self.FontID := FontID;
    self.SWFVersion := SWFVersion;
    self.FontName := FontName;
    self.FontFlagsSmallText := FontFlagsSmallText;
    self.FontFlagsShiftJIS := FontFlagsShiftJIS;
    self.FontFlagsANSI := FontFlagsANSI;
    self.FontFlagsItalic := FontFlagsItalic;
    self.FontFlagsBold := FontFlagsBold;
    self.FontFlagsWideCodes := FontFlagsWideCodes;
    if CodeTable.Count > 1 then
      For il := 0 to CodeTable.Count - 1 do
         self.CodeTable.Add(CodeTable[il]);
  end;
end;

procedure TSWFDefineFontInfo.ReadFromStream(be: TBitsEngine);
var
  b: Byte;
  il, code: Word;
begin
  FontID := be.ReadWord;
  b := be.ReadByte;
  FontName := be.ReadString(b);
  b := be.ReadByte;
  FontFlagsSmallText := CheckBit(b, 6);
  FontFlagsShiftJIS := CheckBit(b, 5);
  FontFlagsANSI := CheckBit(b, 4);
  FontFlagsItalic := CheckBit(b, 3);
  FontFlagsBold := CheckBit(b, 2);
  FontFlagsWideCodes := CheckBit(b, 1);
  if nGlyphs > 0 then
   for il := 0 to nGlyphs - 1 do
    begin
      if FontFlagsWideCodes
        then code := be.ReadWord
        else code := be.ReadByte;
      CodeTable.Add(Pointer(Code));
    end;
end;

procedure TSWFDefineFontInfo.WriteTagBody(be: TBitsEngine);
var
  il: Integer;
begin
  be.WriteWord(FontID);
  if SWFVersion > SWFVer5
   then be.WriteByte(length(AnsiToUTF8(FontName)))
   else be.WriteByte(length(FontName));
  be.WriteString(FontName, false, SWFVersion > SWFVer5);
  be.WriteBits(0, 2);
  be.WriteBit(FontFlagsSmallText);
  be.WriteBit(FontFlagsShiftJIS);
  be.WriteBit(FontFlagsANSI);
  be.WriteBit(FontFlagsItalic);
  be.WriteBit(FontFlagsBold);
  be.WriteBit(FontFlagsWideCodes);
  if CodeTable.Count > 0 then
    For il := 0 to CodeTable.Count - 1 do
      if FontFlagsWideCodes
        then be.WriteWord(Word(CodeTable[il]))
        else be.WriteByte(byte(CodeTable[il]));
end;

{
**************************************************** TSWFDefineFontInfo2 ****************************************************
}
constructor TSWFDefineFontInfo2.Create;
begin
  inherited ;
  TagId := tagDefineFontInfo2;
end;

procedure TSWFDefineFontInfo2.Assign(Source: TBasedSWFObject);
begin
  inherited;
  LanguageCode := TSWFDefineFontInfo2(Source).LanguageCode;
end;

function TSWFDefineFontInfo2.MinVersion: Byte;
begin
  Result := SWFVer6;
end;

procedure TSWFDefineFontInfo2.ReadFromStream(be: TBitsEngine);
var
  b: Byte;
  il: Word;
begin
  FontID := be.ReadWord;
  b := be.ReadByte;
  FontName := be.ReadString(b);
  b := be.ReadByte;
  FontFlagsSmallText := CheckBit(b, 6);
  FontFlagsShiftJIS := CheckBit(b, 5);
  FontFlagsANSI := CheckBit(b, 4);
  FontFlagsItalic := CheckBit(b, 3);
  FontFlagsBold := CheckBit(b, 2);
  FontFlagsWideCodes := CheckBit(b, 1); //  Always = 1
  LanguageCode := be.ReadByte;
  if nGlyphs > 0 then
   for il := 0 to nGlyphs - 1 do
     CodeTable.Add(Pointer(be.ReadWord));
end;

procedure TSWFDefineFontInfo2.WriteTagBody(be: TBitsEngine);
var
  il: Integer;
begin
  be.WriteWord(FontID);
  be.WriteByte(Length(AnsiToUtf8(FontName)));
  be.WriteString(FontName, false, true);
  be.WriteBits(0, 2);
  be.WriteBit(FontFlagsSmallText);
  be.WriteBit(FontFlagsShiftJIS);
  be.WriteBit(FontFlagsANSI);
  be.WriteBit(FontFlagsItalic);
  be.WriteBit(FontFlagsBold);
  be.WriteBit(true); // Always FontFlagsWideCodes = 1
  be.WriteByte(LanguageCode);
  For il := 0 to CodeTable.Count - 1 do
    be.WriteWord(Word(CodeTable[il]));
end;


{
*************************************************** TSWFKerningRecord ****************************************************
}

procedure TSWFKerningRecord.Assign(source: TSWFKerningRecord);
begin
  FontKerningCode1 := source.FontKerningCode1;
  FontKerningCode2 := source.FontKerningCode2;
  FontKerningAdjustment := source.FontKerningAdjustment;
end;

{
*************************************************** TSWFDefineFont2 ******************************************************
}
constructor TSWFDefineFont2.Create;
begin
  inherited;
  TagId := tagDefineFont2;
  FCodeTable := TList.Create;
  FFontBoundsTable := TObjectList.Create;
  FFontAdvanceTable := TList.Create;
end;

destructor TSWFDefineFont2.Destroy;
begin
  FontKerningTable.Free;
  FontAdvanceTable.Free;
  FontBoundsTable.Free;
  CodeTable.Free;
  inherited;
end;

procedure TSWFDefineFont2.Assign(Source: TBasedSWFObject);
var
  il: Word;
  R: TSWFRect;
  KR: TSWFKerningRecord;
begin
  inherited;
  With TSWFDefineFont2(Source) do
  begin
    self.SWFVersion := SWFVersion;
    self.FontFlagsHasLayout := FontFlagsHasLayout;
    self.FontFlagsShiftJIS := FontFlagsShiftJIS;
    self.FontFlagsSmallText := FontFlagsSmallText;
    self.FontFlagsANSI := FontFlagsANSI;
    self.FontFlagsWideOffsets := FontFlagsWideOffsets ;
    self.FontFlagsWideCodes := FontFlagsWideCodes;
    self.FontFlagsItalic := FontFlagsItalic;
    self.FontFlagsBold := FontFlagsBold;
    self.LanguageCode := LanguageCode;
    self.FontName := FontName;
  
    if CodeTable.Count>0 then
      For il:=0 to CodeTable.Count-1 do
        self.CodeTable.Add(CodeTable.Items[il]);
  
    if FontFlagsHasLayout then
      begin
        self.FontAscent := FontAscent;
        self.FontDescent := FontDescent;
        self.FontLeading := FontLeading;

        if FontAdvanceTable.Count > 0 then
          For il:=0 to FontAdvanceTable.Count-1 do
            self.FontAdvanceTable.Add(FontAdvanceTable[il]);
  
        if FontBoundsTable.Count > 0 then
          For il:=0 to FontBoundsTable.Count-1 do
            begin
              R := TSWFRect.Create;
              R.Assign(TSWFRect(FontBoundsTable[il]));
              self.FontBoundsTable.Add(R);
            end;
  
        if FontKerningTable.Count > 0 then
          for il:=0 to FontKerningTable.Count-1 do
            begin
              KR := TSWFKerningRecord.Create;
              KR.Assign(TSWFKerningRecord(FontKerningTable[il]));
              self.FontKerningTable.Add(KR);
            end;
      end;
  end;
end;

function TSWFDefineFont2.GetFontKerningTable: TObjectList;
begin
  if FFontKerningTable = nil then FFontKerningTable := TObjectList.Create;
  Result := FFontKerningTable;
end;

function TSWFDefineFont2.MinVersion: Byte;
begin
  Result := SWFVer3;
end;

procedure TSWFDefineFont2.ReadFromStream(be: TBitsEngine);
var
  PP, il: LongInt;
  b, SizeOffset: Byte;
  tmpGlyphCount: Word;
  CodeTableOffset, OffsetPos: dword;
  LO: TObjectList;
  SWFRect: TSWFRect;
  Kerning: TSWFKerningRecord;
  OffsetList: TList;
begin
  PP := be.BitsStream.Position;
  FontID := be.ReadWord;
  b := be.ReadByte;
  FontFlagsHasLayout := CheckBit(b, 8);
  FontFlagsShiftJIS := CheckBit(b, 7);
  FontFlagsSmallText := CheckBit(b, 6);
  FontFlagsANSI := CheckBit(b, 5);
  FontFlagsWideOffsets := CheckBit(b, 4);
  FontFlagsWideCodes := CheckBit(b, 3);
  FontFlagsItalic := CheckBit(b, 2);
  FontFlagsBold := CheckBit(b, 1);
  LanguageCode := be.ReadByte;
  b := be.ReadByte;
  FontName := be.ReadString(b);
  if SWFVersion > SWFVer5
    then FontName := UTF8ToAnsi(FontName);
  tmpGlyphCount := be.ReadWord;
  SizeOffset := 2 + 2 * byte(FontFlagsWideOffsets);
  OffsetList := TList.Create;
  OffsetPos := be.BitsStream.Position;
  CodeTableOffset := 0;
  if tmpGlyphCount > 0 then
    for il := 0 to tmpGlyphCount{ - 1} do
      begin
  
        be.BitsStream.Read(CodeTableOffset, SizeOffset);
        OffsetList.Add(Pointer(Longint(CodeTableOffset)));

      end;
    //  be.BitsStream.Seek(soFromCurrent, tmpGlyphCount *();
  
  (*  if FontFlagsWideOffsets
      then CodeTableOffset := be.ReadDWord
      else CodeTableOffset := be.ReadWord;   *)
  
  
  if tmpGlyphCount>0 then
    begin
      for il := 0 to tmpGlyphCount - 1 do
        begin
          be.BitsStream.Position := Longint(OffsetPos) +  Longint(OffsetList[il]);
          LO := TObjectList.Create;
          b := be.ReadByte;
          ReadShapeRecord(be, LO, b shr 4, b and $F, nil);
          GlyphShapeTable.Add(LO);
        end;
      for il := 0 to tmpGlyphCount - 1 do
        begin
         if FontFlagsWideCodes
          then CodeTable.Add(Pointer(Longint(be.ReadWord)))
          else
           CodeTable.Add(Pointer(LongInt(be.Readbyte)));
        end;
    end;
  
  If FontFlagsHasLayout then
    begin
      FontAscent := be.ReadWord;
      FontDescent := be.ReadWord;
      FontLeading := be.ReadWord;
  
      if tmpGlyphCount>0 then
       begin
        For il := 0 to tmpGlyphCount-1 do
         FontAdvanceTable.Add(Pointer(smallint(be.ReadWord)));
  
        For il := 0 to tmpGlyphCount-1 do
          With be.ReadRect do
           begin
             SWFRect := TSWFRect.Create;
             SWFRect.Xmin := Left;
             SWFRect.Ymin := Top;
             SWFRect.Xmax := Right;
             SWFRect.Ymax := Bottom;
             FontBoundsTable.Add(SWFRect);
           end;
       end;
      KerningCount := be.ReadWord;
      if KerningCount > 0 then
        for il:=0 to KerningCount - 1 do
          begin
            Kerning := TSWFKerningRecord.Create;
            if FontFlagsWideCodes then
              begin
                Kerning.FontKerningCode1 := be.ReadWord;
                Kerning.FontKerningCode2 := be.ReadWord;
              end else
              begin
                Kerning.FontKerningCode1 := be.ReadByte;
                Kerning.FontKerningCode2 := be.ReadByte;
              end;
            Kerning.FontKerningAdjustment := Smallint(be.ReadWord);
            FontKerningTable.Add(Kerning);
          end;
    end;
  OffsetList.Free;
  be.BitsStream.Position := Longint(BodySize) + PP;
end;

procedure TSWFDefineFont2.WriteTagBody(be: TBitsEngine);
var
  il, il2: Integer;
  OffsetSize: Byte;
  CodeTableOffset, OffsetPos: dWord;
  Edges: TObjectList;
  tmpLayout: boolean;
begin
  be.WriteWord(FontID);
  tmpLayout := FontFlagsHasLayout and (CodeTable.Count > 0);
  be.WriteBit(tmpLayout);
  be.WriteBit(FontFlagsShiftJIS);
  be.WriteBit(FontFlagsSmallText);
  be.WriteBit(FontFlagsANSI or (CodeTable.Count = 0));
  FontFlagsWideOffsets := CodeTable.Count > 128; 
  be.WriteBit(FontFlagsWideOffsets);
  be.WriteBit(FontFlagsWideCodes);
  be.WriteBit(FontFlagsItalic);
  be.WriteBit(FontFlagsBold);
  be.WriteByte(LanguageCode);
  if SWFVersion > SWFVer5
   then be.WriteByte(length(AnsiToUTF8(FontName)))
   else be.WriteByte(length(FontName));
  be.WriteString(FontName, false, SWFVersion > SWFVer5);
  be.WriteWord(CodeTable.Count);
  OffsetSize := 2 + 2 * byte(FontFlagsWideOffsets);
  CodeTableOffset := 0;

  OffsetPos := be.BitsStream.Position;

  if CodeTable.Count > 0 then
    For il := 0 to CodeTable.Count - 1 do
     be.BitsStream.Write(CodeTableOffset, OffsetSize);  // fill zero

  be.BitsStream.Write(CodeTableOffset, OffsetSize);

  if GlyphShapeTable.Count>0 then
    For il:=0 to GlyphShapeTable.Count-1 do
      begin
       CodeTableOffset := BE.BitsStream.Position - OffsetPos;
       be.BitsStream.Position := LongInt(OffsetPos) + OffsetSize * il;
       be.BitsStream.Write(CodeTableOffset, OffsetSize);
       be.BitsStream.Seek(0, soFromEnd);
    //   inc(OffsetPos, OffsetSize);

       BE.WriteByte($10);

       Edges := TObjectList(GlyphShapeTable.Items[il]);
       if Edges.Count > 0 then
         begin
          for il2 := 0 to Edges.Count - 1 do
           With TSWFShapeRecord(Edges[il2]) do
            begin
              if (ShapeRecType = StyleChangeRecord) then
               with TSWFStyleChangeRecord(Edges[il2]) do
                begin
                 bitsFill := 1;
                 bitsLine := 0;
                 if (il2 = 0) and (not (StateFillStyle0 or StateFillStyle1) or
                                  (StateFillStyle1 and (Fill1Id = 0))) then
                 begin
                   StateFillStyle0 := false;
                   StateFillStyle1 := true;
                   StateLineStyle := true;
                   Fill1Id := 1
                 end;
                end;
              WriteToStream(be);
              if (il2 = (Edges.Count - 1)) and (ShapeRecType<>EndShapeRecord)
                then be.WriteBits(0, 6);  // add automtic end flag
            end;
         end else be.WriteBits(0, 6);  // end flag

         BE.FlushLastByte;
      end;

  CodeTableOffset := BE.BitsStream.Position - OffsetPos;
  be.BitsStream.Position := Longint(OffsetPos) + OffsetSize * GlyphShapeTable.Count;
  be.BitsStream.Write(CodeTableOffset, OffsetSize);
  be.BitsStream.Seek(0, soFromEnd);


  if CodeTable.Count>0 then
    For il:=0 to CodeTable.Count-1 do
      begin
        CodeTableOffset := Longint(CodeTable.Items[il]);
        be.BitsStream.Write(CodeTableOffset, 1 + byte(FontFlagsWideCodes));
      end;

  if tmpLayout then
    begin
      be.WriteWord(FontAscent);
      be.WriteWord(FontDescent);
      be.WriteWord(FontLeading);

      if FontAdvanceTable.Count > 0 then
        For il:=0 to FontAdvanceTable.Count-1 do
          be.WriteWord(word(FontAdvanceTable[il]));

      if FontBoundsTable.Count > 0 then
        For il:=0 to FontBoundsTable.Count-1 do
          with TSWFRect(FontBoundsTable[il]) do
            be.WriteRect(Rect);

      be.WriteWord(FontKerningTable.Count);
      if FontKerningTable.Count > 0 then
        for il:=0 to FontKerningTable.Count-1 do
          with TSWFKerningRecord(FontKerningTable[il]) do
            begin
              if FontFlagsWideCodes then be.WriteWord(FontKerningCode1)
                else be.WriteByte(FontKerningCode1);
              if FontFlagsWideCodes then be.WriteWord(FontKerningCode2)
                else be.WriteByte(FontKerningCode2);
              be.WriteWord(Word(FontKerningAdjustment));
            end;
    end;
end;


{
****************************************************** TSWFTextRecord *******************************************************
}
constructor TSWFDefineFont3.Create;
begin
  inherited;
  TagID := tagDefineFont3;
  FontFlagsWideCodes := true;
end;

function TSWFDefineFont3.MinVersion: Byte;
begin
  Result := SWFVer8;
end;

function TSWFZoneRecord.AddZoneData: TSWFZoneData;
begin
 Result := TSWFZoneData.Create;
 Add(Result);
end;

{
****************************************************** TSWFZoneRecord *******************************************************
}

function TSWFZoneRecord.GetZoneData(Index: Integer): TSWFZoneData;
begin
 Result := TSWFZoneData(Items[Index]);
end;

function TSWFZoneTable.AddZoneRecord: TSWFZoneRecord;
begin
 Result := TSWFZoneRecord.Create;
 Add(Result);
end;

{
****************************************************** TSWFZoneTable *******************************************************
}
function TSWFZoneTable.GetZoneRecord(Index: Integer): TSWFZoneRecord;
begin
 Result := TSWFZoneRecord(Items[Index]);
end;

{
****************************************************** TSWFDefineFontAlignZones *******************************************************
}
constructor TSWFDefineFontAlignZones.Create;
begin
  inherited;
  TagID := tagDefineFontAlignZones;
  FZoneTable := TSWFZoneTable.Create;
end;

destructor TSWFDefineFontAlignZones.Destroy;
begin
 FZoneTable.Free;
 inherited;
end;

function TSWFDefineFontAlignZones.MinVersion: Byte;
begin
  Result := SWFVer8;
end;

procedure TSWFDefineFontAlignZones.ReadFromStream(be: TBitsEngine);
 var b: byte;
     PP: LongInt;
     ZR: TSWFZoneRecord;
     ZD: TSWFZoneData;
begin
  PP := be.BitsStream.Position;
  FontID := be.ReadWord;
  b := be.ReadByte;
  CSMTableHint := b shr 6;
  While (PP + Longint(BodySize) >  be.BitsStream.Position) do
   begin
     ZR := ZoneTable.AddZoneRecord;
     ZR.NumZoneData := be.ReadByte;
     While ZR.Count < ZR.FNumZoneData do
      begin
        ZD := ZR.AddZoneData;
        ZD.AlignmentCoordinate := be.ReadWord;//be.ReadFloat16;// WordToSingle();
        ZD.Range := be.ReadWord;//be.ReadFloat16; //WordToSingle(be.ReadWord);
      end;
     b := be.ReadByte;
     ZR.ZoneMaskX := CheckBit(b, 8);
     ZR.ZoneMaskY := CheckBit(b, 7);
   end;
  be.BitsStream.Position := PP + Longint(BodySize);
end;

procedure TSWFDefineFontAlignZones.WriteTagBody(be: TBitsEngine);
 var il, il2: word;
begin
  be.WriteWord(FontID);
  be.WriteByte(CSMTableHint shl 6);
  if ZoneTable.Count > 0 then
  for il := 0 to ZoneTable.Count - 1 do
   with ZoneTable[il] do
    begin
     be.WriteByte(NumZoneData);
     for il2 := 0 to Count - 1 do
      begin
        be.WriteWord(ZoneData[il2].AlignmentCoordinate);
        be.WriteWord(ZoneData[il2].Range);

     //  be.WriteWord(SingleToWord(ZoneData[il2].AlignmentCoordinate));
     //  be.WriteWord(SingleToWord(ZoneData[il2].Range));
      end;
     be.WriteBit(ZoneMaskX);
     be.WriteBit(ZoneMaskY);
     be.FlushLastByte;
    end;
end;



{ ******************************************************  TSWFDefineFontName ***********************************************}

constructor TSWFDefineFontName.Create;
begin
  TagID := tagDefineFontName;
end;

function TSWFDefineFontName.MinVersion: Byte;
begin
  Result := SWFVer9;
end;

procedure TSWFDefineFontName.ReadFromStream(be: TBitsEngine);
begin
  FontId := be.ReadWord;
  FontName := be.ReadString;
  FontCopyright := be.ReadString;
end;

procedure TSWFDefineFontName.WriteTagBody(be: TBitsEngine);
begin
  be.WriteWord(FontId);
  be.WriteString(FontName);
  be.WriteString(FontCopyright);
end;

{
****************************************************** TSWFTextRecord *******************************************************
}
constructor TSWFTextRecord.Create;
begin
  FGlyphEntries := TObjectList.Create;
end;

destructor TSWFTextRecord.Destroy;
begin
  if FTextColor <> nil then TextColor.Free;
  GlyphEntries.Free;
  inherited;
end;

procedure TSWFTextRecord.Assign(Source: TSWFTextRecord);
var
  il: Word;
  GE: TSWFGlyphEntry;
begin
  With Source do
  begin
    self.StyleFlagsHasFont := StyleFlagsHasFont;
    self.StyleFlagsHasColor := StyleFlagsHasColor;
    self.StyleFlagsHasYOffset := StyleFlagsHasYOffset;
    self.StyleFlagsHasXOffset := StyleFlagsHasXOffset;
    if self.StyleFlagsHasFont then
      self.FontID := FontID;
    if StyleFlagsHasColor then
      self.TextColor.Assign(TextColor);

    if StyleFlagsHasXOffset then self.XOffset := XOffset;
    if StyleFlagsHasYOffset then self.YOffset := YOffset;
    if StyleFlagsHasFont then self.TextHeight := TextHeight;
    if GlyphEntries.Count > 0 then
      for il := 0 to GlyphEntries.Count-1 do
        begin
          GE := TSWFGlyphEntry.Create;
          GE.GlyphAdvance := GlyphEntry[il].GlyphAdvance;
          GE.GlyphIndex := GlyphEntry[il].GlyphIndex;
          self.GlyphEntries.Add(GE);
        end;
  end;
end;

function TSWFTextRecord.GetGlyphEntry(Index: word): TSWFGlyphEntry;
begin
  Result := TSWFGlyphEntry(GlyphEntries[index]);
end;

function TSWFTextRecord.GetTextColor: TSWFRGBA;
begin
  FStyleFlagsHasColor := true;
  if FTextColor = nil then FTextColor := TSWFRGBA.Create;
  Result := FTextColor;
end;

procedure TSWFTextRecord.SetFontID(Value: Word);
begin
  FStyleFlagsHasFont := true;
  FFontID := Value;
end;

procedure TSWFTextRecord.SetTextHeight(Value: Word);
begin
  FStyleFlagsHasFont := true;
  FTextHeight := Value;
end;

procedure TSWFTextRecord.SetXOffset(Value: Integer);
begin
  StyleFlagsHasXOffset := true;
  FXOffset := Value;
end;

procedure TSWFTextRecord.SetYOffset(Value: Integer);
begin
  StyleFlagsHasYOffset := true;
  FYOffset := Value;
end;

procedure TSWFTextRecord.WriteToStream(be: TBitsEngine; gb, ab: byte);
var
  il: Integer;
begin
  be.WriteBit(true); // TextRecordType
  be.WriteBits(0, 3);// StyleFlagsReserved
  be.WriteBit(StyleFlagsHasFont);
  be.WriteBit(StyleFlagsHasColor);
  be.WriteBit(StyleFlagsHasYOffset);
  be.WriteBit(StyleFlagsHasXOffset);
  if StyleFlagsHasFont then be.WriteWord(FontID);
  if StyleFlagsHasColor then
    begin
      if hasAlpha then be.WriteColor(TextColor.RGBA)
        else be.WriteColor(TextColor.RGB);
    end;
  if StyleFlagsHasXOffset then be.WriteWord(XOffset);
  if StyleFlagsHasYOffset then be.WriteWord(YOffset);
  if StyleFlagsHasFont then be.WriteWord(TextHeight);
  be.WriteByte(GlyphEntries.Count);
  if GlyphEntries.Count > 0 then
    for il := 0 to GlyphEntries.Count-1 do
      with TSWFGlyphEntry(GlyphEntries[il]) do
        begin
          be.WriteBits(GlyphIndex, gb);
          be.WriteBits(GlyphAdvance, ab);
        end;
  be.FlushLastByte;
end;


{
****************************************************** TSWFDefineText *******************************************************
}
constructor TSWFDefineText.Create;
begin
  TagID := tagDefineText;
  FTextRecords := TObjectList.Create;
  FTextMatrix := TSWFMatrix.Create;
  FTextBounds := TSWFRect.Create;
end;

destructor TSWFDefineText.Destroy;
begin
  TextRecords.Free;
  TextMatrix.Free;
  TextBounds.Free;
  inherited;
end;

procedure TSWFDefineText.Assign(Source: TBasedSWFObject);
var
  TR: TSWFTextRecord;
  il: Word;
begin
  inherited;
  With TSWFDefineText(Source) do
  begin
    self.CharacterId := CharacterId;
    self.AdvanceBits := AdvanceBits;
    self.CharacterID := CharacterID;
    self.GlyphBits := GlyphBits;
    self.hasAlpha := hasAlpha;
    self.TextBounds.Assign(TextBounds);
    self.TextMatrix.Assign(TextMatrix);
    if TextRecords.Count > 0 then
     for il := 0 to TextRecords.Count - 1 do
      begin
        TR := TSWFTextRecord.Create;
        TR.Assign(TextRecord[il]);
        self.TextRecords.Add(TR);
      end;
  end;
end;

function TSWFDefineText.GetTextRecord(Index: Integer): TSWFTextRecord;
begin
  Result := TSWFTextRecord(TextRecords[Index]);
end;

procedure TSWFDefineText.ReadFromStream(be: TBitsEngine);
var
  PP: LongInt;
  TR: TSWFTextRecord;
  GE: TSWFGlyphEntry;
  b, fGliphCount, il: Byte;
begin
  PP := be.BitsStream.Position;
  CharacterID := be.ReadWord;
  TextBounds.Rect := be.ReadRect;
  TextMatrix.Rec := be.ReadMatrix;
  GlyphBits := be.ReadByte;
  AdvanceBits := be.ReadByte;
  Repeat
    b := be.ReadByte;
    if b > 0 then
     begin
       TR := TSWFTextRecord.Create;
       TR.hasAlpha := hasAlpha;
       TR.StyleFlagsHasFont := CheckBit(b, 4);
       TR.StyleFlagsHasColor := CheckBit(b, 3);
       TR.StyleFlagsHasYOffset := CheckBit(b, 2);
       TR.StyleFlagsHasXOffset := CheckBit(b, 1);
       if TR.StyleFlagsHasFont then TR.FontID := be.ReadWord;
       if TR.StyleFlagsHasColor then
          begin
            if hasAlpha then TR.TextColor.RGBA := be.ReadRGBA
              else TR.TextColor.RGB := be.ReadRGB;
          end;
       if TR.StyleFlagsHasXOffset then TR.XOffset := be.ReadWord;
       if TR.StyleFlagsHasYOffset then TR.YOffset := be.ReadWord;
       if TR.StyleFlagsHasFont then TR.TextHeight := be.ReadWord;
       fGliphCount := be.ReadByte;
       if fGliphCount > 0 then
         for il :=1 to fGliphCount do
           begin
             GE := TSWFGlyphEntry.Create;
             GE.GlyphIndex := be.GetBits(GlyphBits);
             GE.GlyphAdvance := be.GetSBits(AdvanceBits);
             TR.GlyphEntries.Add(GE);
           end;
       be.FlushLastByte(false);
       TextRecords.Add(TR);
     end;
  Until b = 0;
  
  be.BitsStream.Position := Longint(BodySize) + PP;
end;

procedure TSWFDefineText.WriteTagBody(be: TBitsEngine);
var
  il: Integer;
begin
  be.WriteWord(CharacterID);
  be.WriteRect(TextBounds.Rect);
  be.WriteMatrix(TextMatrix.Rec);
  be.WriteByte(GlyphBits);
  be.WriteByte(AdvanceBits);
  for il := 0 to TextRecords.Count - 1 do
    with TSWFTextRecord(TextRecords[il]) do
      begin
        hasAlpha := self.hasAlpha;
        WriteToStream(be, GlyphBits, AdvanceBits);
      end;
  be.WriteByte(0); //  EndOfRecordsFlag
end;


{
****************************************************** TSWFDefineText2 ******************************************************
}
constructor TSWFDefineText2.Create;
begin
  inherited ;
  TagID := tagDefineText2;
  hasAlpha := true;
end;

function TSWFDefineText2.MinVersion: Byte;
begin
  Result := SWFVer3;
end;

{
**************************************************** TSWFDefineEditText *****************************************************
}
constructor TSWFDefineEditText.Create;
begin
  TagID := tagDefineEditText;
  FBounds := TSWFRect.Create;
end;

destructor TSWFDefineEditText.Destroy;
begin
  if FBounds <> nil then FBounds.Free;
  if FTextColor <> nil then FTextColor.Free;
  inherited;
end;

procedure TSWFDefineEditText.Assign(Source: TBasedSWFObject);
begin
  inherited;
  With TSWFDefineEditText(Source) do
  begin
    self.CharacterID := CharacterID;
    self.Bounds.Assign(Bounds);
    self.HasText := HasText;
    self.WordWrap := WordWrap;
    self.Multiline := Multiline;
    self.Password := Password;
    self.ReadOnly := ReadOnly;
    self.HasTextColor := HasTextColor;
    self.HasMaxLength := HasMaxLength;
    self.HasFont := HasFont;
    self.AutoSize := AutoSize;
    self.HasLayout := HasLayout;
    self.NoSelect := NoSelect;
    self.Border := Border;
    self.HTML := HTML;
    self.UseOutlines := UseOutlines;
  
  if HasFont then
    begin
      self.FontID := FontID;
      self.FontHeight := FontHeight;
    end;
  self.HasFontClass := HasFontClass;
  if HasFontClass then self.FontClass := FontClass;
  
  if HasTextColor then self.TextColor.Assign(TextColor);
  If HasMaxLength then self.MaxLength := MaxLength;
  If HasLayout then
    begin
      self.Align := Align;
      self.LeftMargin := LeftMargin;
      self.RightMargin := RightMargin;
      self.Indent := Indent;
      self.Leading := Leading;
    end;
  self.VariableName := VariableName;
  if HasText then
    self.InitialText := InitialText;
  end;
end;

function TSWFDefineEditText.GetTextColor: TSWFRGBA;
begin
  if FTextColor = nil then FTextColor := TSWFRGBA.Create;
  HasTextColor := true;
  Result := FTextColor;
end;

function TSWFDefineEditText.MinVersion: Byte;
begin
  if HasFontClass then Result := SWFVer9 else
    if AutoSize then Result := SWFVer6
      else Result := SWFVer4;
end;

procedure TSWFDefineEditText.ReadFromStream(be: TBitsEngine);
var
  b: Byte;
begin
  CharacterID := be.ReadWord;
  Bounds.Rect := be.ReadRect;
  b := be.ReadByte;
  HasText := CheckBit(b, 8);
  WordWrap := CheckBit(b, 7);
  Multiline  := CheckBit(b, 6);
  Password := CheckBit(b, 5);
  ReadOnly := CheckBit(b, 4);
  HasTextColor := CheckBit(b, 3);
  HasMaxLength  := CheckBit(b, 2);
  HasFont := CheckBit(b, 1);
  b := be.ReadByte;
  if SWFVersion > SWFVer8
    then HasFontClass := CheckBit(b, 8)
    else HasFontClass := false;
  AutoSize := CheckBit(b, 7);
  HasLayout := CheckBit(b, 6);
  NoSelect := CheckBit(b, 5);
  Border := CheckBit(b, 4);
  HTML := CheckBit(b, 2);
  UseOutlines := CheckBit(b, 1);
  if HasFont then
    FontID := be.ReadWord;
  if HasFontClass then
    FontClass := be.ReadString;
  if HasFont then
    FontHeight := be.ReadWord;

  if HasTextColor then TextColor.RGBA := be.ReadRGBA;
  If HasMaxLength then MaxLength := be.ReadWord;
  If HasLayout then
    begin
      Align := be.ReadByte;
      LeftMargin := be.ReadWord;
      RightMargin := be.ReadWord;
      Indent := be.ReadWord;
      Leading := be.ReadWord;
    end;
  VariableName := be.ReadString;
  if HasText then
    InitialText := be.ReadString;
end;

procedure TSWFDefineEditText.WriteTagBody(be: TBitsEngine);
var
  Len: Integer;
  UTF8Ar: PChar;
begin
  be.WriteWord(CharacterID);
  be.WriteRect(Bounds.Rect);
  be.WriteBit(HasText);
  be.WriteBit(WordWrap);
  be.WriteBit(Multiline);
  be.WriteBit(Password);
  be.WriteBit(ReadOnly);
  be.WriteBit(HasTextColor);
  be.WriteBit(HasMaxLength);
  be.WriteBit(HasFont);
  HasFontClass := (SWFVersion > SWFVer8) and (ClassName <> '');
  be.WriteBit(HasFontClass);
  be.WriteBit(AutoSize);
  be.WriteBit(HasLayout);
  be.WriteBit(NoSelect);
  be.WriteBit(Border);
  be.WriteBit(false);  // Flash Reserved
  be.WriteBit(HTML);
  be.WriteBit(UseOutlines);

  if HasFont then
    be.WriteWord(FontID);

  if HasFontClass then
    be.WriteString(FontClass);

  if HasFont then
    be.WriteWord(FontHeight);

  if HasTextColor then be.WriteColor(TextColor.RGBA);
  If HasMaxLength then be.WriteWord(MaxLength);
  If HasLayout then
    begin
      be.WriteByte(Align);
      be.WriteWord(LeftMargin);
      be.WriteWord(RightMargin);
      be.WriteWord(Indent);
      be.WriteWord(Leading);
    end;
  be.WriteString(VariableName, true, SWFVersion > SWFVer5);
  if HasText then
    begin
      If (WideInitialText = '')  then
        be.WriteString(InitialText, true, (not HTML) and (SWFVersion > SWFVer5))
       else
        begin

         Len := UnicodeToUtf8(nil, $FFFF, PWideChar(WideInitialText), Length(WideInitialText));
         GetMem(UTF8Ar, Len);
         UnicodeToUtf8(UTF8Ar, Len, PWideChar(WideInitialText), Length(WideInitialText));
         be.WriteUTF8String(UTF8Ar, Len);
         FreeMem(UTF8Ar, Len);
        end;

    end;
end;


{
****************************************************** TSWFCSMTextSettings *******************************************************
}
constructor TSWFCSMTextSettings.Create;
begin
  TagID := tagCSMTextSettings;
end;

destructor TSWFCSMTextSettings.Destroy;
begin
  inherited;
end;

procedure TSWFCSMTextSettings.Assign(Source: TBasedSWFObject);
begin
 with TSWFCSMTextSettings(Source) do
   begin
    self.TextID := TextID;
    self.UseFlashType := UseFlashType;
    self.GridFit := GridFit;
    self.Thickness := Thickness;
    self.Sharpness := Sharpness;
   end;
end;

function TSWFCSMTextSettings.MinVersion: Byte;
begin
  Result := SWFVer8;
end;

procedure TSWFCSMTextSettings.ReadFromStream(be: TBitsEngine);
 var b: byte;
begin
  TextID := be.ReadWord;
  b := be.ReadByte;
  UseFlashType := b shr 6;
  GridFit := (b shr 3) and 3;
  Thickness := be.ReadFloat;
  Sharpness := be.ReadFloat;
  be.ReadByte;
end;

procedure TSWFCSMTextSettings.WriteTagBody(be: TBitsEngine);
begin
  be.WriteWord(TextID);
  be.WriteBits(UseFlashType, 2);
  be.WriteBits(GridFit, 3);
  be.FlushLastByte;
  be.WriteFloat(Thickness);
  be.WriteFloat(Sharpness);
  be.WriteByte(0);
end;


// ===========================================================
//                         VIDEO
// ===========================================================

{
****************************************************** TSWFVideoFrame *******************************************************
}
constructor TSWFVideoFrame.Create;
begin
  tagID := tagVideoFrame;
end;

procedure TSWFVideoFrame.Assign(Source: TBasedSWFObject);
begin
  inherited;
  With TSWFVideoFrame(Source) do
  begin
    self.StreamId := StreamId;
    self.FrameNum := FrameNum;
  end;
end;

function TSWFVideoFrame.MinVersion: Byte;
begin
  Result := SWFVer6;
end;

procedure TSWFVideoFrame.ReadFromStream(be: TBitsEngine);
begin
  StreamID := be.ReadWord;
  FrameNum := be.ReadWord;
  DataSize := BodySize - 4;
  selfdestroy := true;
  GetMem(FData, DataSize);
  be.BitsStream.Read(Data^, DataSize);
end;

procedure TSWFVideoFrame.WriteTagBody(be: TBitsEngine);
begin
  be.WriteWord(StreamID);
  be.WriteWord(FrameNum);
  if Assigned(FOnDataWrite) then OnDataWrite(self, be) else
    if DataSize > 0 then be.BitsStream.Write(Data^, DataSize);
end;

{
*************************************************** TSWFDefineVideoStream ***************************************************
}
constructor TSWFDefineVideoStream.Create;
begin
  tagID := tagDefinevideoStream;
end;

procedure TSWFDefineVideoStream.Assign(Source: TBasedSWFObject);
begin
  inherited;
  With TSWFDefineVideoStream(Source) do
  begin
    self.CharacterID := CharacterID;
    self.CodecID := CodecID;
    self.Height := Height;
    self.NumFrames := NumFrames;
    self.VideoFlagsDeblocking := VideoFlagsDeblocking;
    self.VideoFlagsSmoothing := VideoFlagsSmoothing;
    self.Width := Width;
  end;
end;

function TSWFDefineVideoStream.MinVersion: Byte;
begin
  Result := SWFVer6 + byte(CodecID = 3);
end;

procedure TSWFDefineVideoStream.ReadFromStream(be: TBitsEngine);
var
  B: Byte;
begin
  CharacterID := be.ReadWord;
  NumFrames := be.ReadWord;
  Width := be.ReadWord;
  Height := be.ReadWord;
  B := be.ReadByte;
  VideoFlagsDeblocking := (B shr 1) and 7;
  VideoFlagsSmoothing := CheckBit(b, 1);
  CodecID := be.ReadByte;
end;

procedure TSWFDefineVideoStream.WriteTagBody(be: TBitsEngine);
begin
  be.WriteWord(CharacterID);
  be.WriteWord(NumFrames);
  be.WriteWord(Width);
  be.WriteWord(Height);
  be.WriteBits(0, 5);
  be.WriteBits(VideoFlagsDeblocking, 2);
  be.WriteBit(VideoFlagsSmoothing);
  be.WriteByte(CodecID);
end;


// ===========================================================
//                         SOUND
// ===========================================================

{
****************************************************** TSWFDefineSound ******************************************************
}
constructor TSWFDefineSound.Create;
begin
  inherited;
  tagID := tagDefineSound;
end;

procedure TSWFDefineSound.Assign(Source: TBasedSWFObject);
begin
  inherited;
  With TSWFDefineSound(Source) do
  begin
    self.SeekSamples := SeekSamples;
    self.SoundFormat := SoundFormat;
    self.SoundId := SoundId;
    self.SoundRate := SoundRate;
    self.SoundSampleCount := SoundSampleCount;
    self.SoundSize := SoundSize;
    self.SoundType := SoundType;
  end;
end;

function TSWFDefineSound.MinVersion: Byte;
begin
  Case SoundFormat of
   snd_MP3, snd_PCM_LE: Result := SWFVer4;
   snd_Nellymoser: Result := SWFVer6;
   else Result := SWFVer1;
  end;
end;

procedure TSWFDefineSound.ReadFromStream(be: TBitsEngine);
var
  B: Byte;
  PP: LongInt;
begin
  pp := be.BitsStream.Position;
  SoundId := BE.ReadWord;
  b := be.ReadByte;
  SoundFormat := b shr 4;
  SoundRate := byte(b shl 4) shr 6;
  SoundSize := CheckBit(b, 2);
  SoundType := CheckBit(b, 1);
  SoundSampleCount := BE.ReadDWord;
  if SoundFormat = snd_mp3 then
    begin
      SeekSamples := BE.ReadWord;
    end;
  DataSize := BodySize - (BE.BitsStream.Position - PP);
  GetMem(FData, DataSize);
  be.BitsStream.Read(Data^, DataSize);
end;

procedure TSWFDefineSound.WriteTagBody(be: TBitsEngine);
begin
  BE.WriteWord(SoundId);
  BE.WriteBits(SoundFormat, 4);
  BE.WriteBits(SoundRate, 2);
  BE.WriteBit(SoundSize);
  BE.WriteBit(SoundType);
  BE.WriteDWord(SoundSampleCount);
  if SoundFormat = snd_MP3 then
    begin
      BE.WriteWord(SeekSamples);
  //     BE.WriteWord($FFFF);
    end;
  if Assigned(OnDataWrite) then OnDataWrite(self, be) else
    if DataSize > 0 then be.BitsStream.Write(Data^, DataSize);
end;


{
***************************************************** TSWFSoundEnvelope *****************************************************
}
procedure TSWFSoundEnvelope.Assign(Source: TSWFSoundEnvelope);
begin
  LeftLevel := Source.LeftLevel;
  RightLevel := Source.RightLevel;
  Pos44 := Source.Pos44;
end;

{
****************************************************** TSWFStartSound *******************************************************
}
constructor TSWFStartSound.Create;
begin
  TagID := tagStartSound;
  FSoundEnvelopes := TObjectList.Create;
end;

destructor TSWFStartSound.Destroy;
begin
  FSoundEnvelopes.Free;
end;

procedure TSWFStartSound.AddEnvelope(pos: dword; left, right: word);
var
  env: TSWFSoundEnvelope;
begin
  env := TSWFSoundEnvelope.Create;
  env.Pos44 := pos;
  env.LeftLevel := left;
  env.RightLevel :=right;
  SoundEnvelopes.Add(env);
  HasEnvelope := true;
end;

procedure TSWFStartSound.Assign(Source: TBasedSWFObject);
var
  il: Word;
  SE: TSWFSoundEnvelope;
begin
  inherited;
  With TSWFStartSound(Source) do
  begin
    self.SoundId := SoundId;
    self.FSoundClassName := SoundClassName;
    self.SyncStop := SyncStop;
    self.SyncNoMultiple := SyncNoMultiple;
    self.hasEnvelope := hasEnvelope;
    self.HasLoops := HasLoops;
    self.HasOutPoint := HasOutPoint;
    self.HasInPoint := HasInPoint;
    if HasInPoint then self.InPoint := InPoint;
    if HasOutPoint then self.OutPoint := OutPoint;
    if HasLoops then self.LoopCount := LoopCount;
    if HasEnvelope and (SoundEnvelopes.Count > 0) then
     for il:=0 to SoundEnvelopes.Count - 1 do
      begin
        SE := TSWFSoundEnvelope.Create;
        SE.Assign(TSWFSoundEnvelope(SoundEnvelopes[il]));
        self.SoundEnvelopes.Add(SE);
      end;
  end;
end;

procedure TSWFStartSound.ReadFromStream(be: TBitsEngine);
var
  b: Byte;
  SE: TSWFSoundEnvelope;
begin
  if TagID = tagStartSound
    then SoundId := be.ReadWord
    else SoundClassName := be.ReadString;
  b := be.ReadByte;
  SyncStop := CheckBit(b, 6);
  SyncNoMultiple := CheckBit(b, 5);
  HasEnvelope := CheckBit(b, 4);
  HasLoops := CheckBit(b, 3);
  HasOutPoint := CheckBit(b, 2);
  HasInPoint := CheckBit(b, 1);
  if HasInPoint then InPoint := be.ReadDWord;
  if HasOutPoint then OutPoint := be.ReadDWord;
  if HasLoops then LoopCount := be.ReadWord;
  if HasEnvelope then
    begin
     b := be.ReadByte; // this Envelope point count
     while b > 0 do
      begin
        SE := TSWFSoundEnvelope.Create;
        SE.Pos44 := be.ReadDWord;
        SE.LeftLevel := be.ReadWord;
        SE.RightLevel := be.ReadWord;
        SoundEnvelopes.Add(SE);
        dec(b);
      end;
    end;
end;

procedure TSWFStartSound.SetInPoint(const Value: dword);
begin
  HasInPoint := Value > 0;
  FInPoint := Value;
end;

procedure TSWFStartSound.SetLoopCount(Value: Word);
begin
  HasLoops := Value > 0;
  FLoopCount := Value;
end;

procedure TSWFStartSound.SetOutPoint(const Value: dword);
begin
  HasOutPoint := Value > 0;
  FOutPoint := Value;
end;

procedure TSWFStartSound.WriteTagBody(be: TBitsEngine);
var
  il: Word;
begin
  if TagID = tagStartSound
    then be.WriteWord(SoundId)
    else be.WriteString(SoundClassName);

  be.WriteBits(0, 2);
  be.WriteBit(SyncStop);
  be.WriteBit(SyncNoMultiple);
  hasEnvelope := hasEnvelope and (SoundEnvelopes.Count > 0);
  be.WriteBit(HasEnvelope);
  be.WriteBit(HasLoops);
  be.WriteBit(HasOutPoint);
  be.WriteBit(HasInPoint);
  if HasInPoint then be.WriteDWord(InPoint);
  if HasOutPoint then be.WriteDWord(OutPoint);
  if HasLoops then be.WriteWord(LoopCount);
  if HasEnvelope then
    begin
     be.Writebyte(SoundEnvelopes.Count);
     for il:=0 to SoundEnvelopes.Count - 1 do
      with TSWFSoundEnvelope(SoundEnvelopes[il]) do
        begin
          be.WriteDWord(Pos44);
          be.WriteWord(LeftLevel);
          be.WriteWord(RightLevel);
        end;
    end;
end;



{
**************************************************** TSWFStartSound2 ****************************************************
}

constructor TSWFStartSound2.Create;
begin
  TagID := tagStartSound2;
end;

function TSWFStartSound2.MinVersion: Byte;
begin
  Result := SWFVer9;
end;

{
**************************************************** TSWFSoundStreamHead ****************************************************
}
constructor TSWFSoundStreamHead.Create;
begin
  TagID := tagSoundStreamHead;
end;

procedure TSWFSoundStreamHead.Assign(Source: TBasedSWFObject);
begin
  inherited;
  With TSWFSoundStreamHead(Source) do
  begin
    self.LatencySeek := LatencySeek;
    self.PlaybackSoundRate := PlaybackSoundRate;
    self.PlaybackSoundSize := PlaybackSoundSize;
    self.PlaybackSoundType := PlaybackSoundType;
    self.StreamSoundCompression := StreamSoundCompression;
    self.StreamSoundRate := StreamSoundRate;
    self.StreamSoundSampleCount := StreamSoundSampleCount;
    self.StreamSoundSize := StreamSoundSize;
    self.StreamSoundType := StreamSoundType;
  end;
end;

function TSWFSoundStreamHead.MinVersion: Byte;
begin
  Result := SWFVer1;
  if StreamSoundCompression = SWFVer2 then Result := SWFVer4;
end;

procedure TSWFSoundStreamHead.ReadFromStream(be: TBitsEngine);
var
  b: Byte;
begin
  b := be.ReadByte;
  PlaybackSoundRate := b shr 2;
  PlaybackSoundSize := (b and 2) = 2;
  PlaybackSoundType := (b and 1) = 1;
  b := be.ReadByte;
  StreamSoundCompression := b shr 4;
  StreamSoundRate := byte(b shl 4) shr 6;
  StreamSoundSize := (b and 2) = 2;
  StreamSoundType := (b and 1) = 1;
  StreamSoundSampleCount := be.ReadWord;
  if (StreamSoundCompression = snd_MP3) and (BodySize > 4) then LatencySeek := be.ReadWord;
end;

procedure TSWFSoundStreamHead.WriteTagBody(be: TBitsEngine);
begin
  BE.WriteBits(0, 4);
  BE.WriteBits(PlaybackSoundRate, 2);
  BE.WriteBit(PlaybackSoundSize); // PlaybackSoundSize 16bit
  BE.WriteBit(PlaybackSoundType);

  BE.WriteBits(StreamSoundCompression, 4);
  BE.WriteBits(StreamSoundRate, 2);
  BE.WriteBit(StreamSoundSize);
  BE.WriteBit(StreamSoundType);
  BE.BitsStream.Write(StreamSoundSampleCount, 2);
  if StreamSoundCompression = snd_MP3 then BE.BitsStream.Write(LatencySeek, 2);
end;


{
*************************************************** TSWFSoundStreamHead2 ****************************************************
}
constructor TSWFSoundStreamHead2.Create;
begin
  inherited;
  TagID := tagSoundStreamHead2;
end;

function TSWFSoundStreamHead2.MinVersion: Byte;
begin
  Result := SWFVer3;
  if StreamSoundCompression = SWFVer2 then Result := SWFVer4 else
   if StreamSoundCompression = SWFVer6 then Result := SWFVer6;
end;

{
*************************************************** TSWFSoundStreamBlock ****************************************************
}
constructor TSWFSoundStreamBlock.Create;
begin
  inherited;
  TagID := tagSoundStreamBlock;
end;

procedure TSWFSoundStreamBlock.Assign(Source: TBasedSWFObject);
begin
  inherited;
  With TSWFSoundStreamBlock(Source) do
  begin
    self.StreamSoundCompression := StreamSoundCompression;
    self.SeekSamples := SeekSamples;
    self.SampleCount := SampleCount;
  end;
end;

procedure TSWFSoundStreamBlock.ReadFromStream(be: TBitsEngine);
begin
  DataSize := BodySize;
  case StreamSoundCompression of
   snd_MP3: begin
              SampleCount := be.ReadWord;
              SeekSamples := be.ReadWord;
              DataSize := DataSize - 4;
            end;
  end;
  SelfDestroy := true;
  GetMem(FData, DataSize);
  be.BitsStream.Read(Data^, DataSize);
end;

procedure TSWFSoundStreamBlock.WriteTagBody(be: TBitsEngine);
begin
  case StreamSoundCompression of
   snd_MP3:
    begin
      be.WriteWord(SampleCount);
      be.WriteWord(word(SeekSamples));
    end;
  end;
  if Assigned(OnDataWrite) then OnDataWrite(self, be) else
    if DataSize > 0 then be.BitsStream.Write(Data^, DataSize);
end;


// ==========================================================//
//                       Buttons                             //
// ==========================================================//

{
***************************************************** TSWFButtonRecord ******************************************************
}
constructor TSWFButtonRecord.Create(ChID: word);
begin
  CharacterId := ChID;
end;

destructor TSWFButtonRecord.Destroy;
begin
  if FMatrix <> nil then FMatrix.Free;
  if FColorTransform <> nil then FColorTransform.Free;
end;

procedure TSWFButtonRecord.Assign(Source: TSWFButtonRecord);
begin
  ButtonHasBlendMode := Source.ButtonHasBlendMode;
  ButtonHasFilterList := Source.ButtonHasFilterList;
  ButtonState := Source.ButtonState;
  CharacterID := Source.CharacterID;
  if Source.hasColorTransform then
    ColorTransform.Assign(Source.ColorTransform);
  Depth := Source.Depth;
  Matrix.Assign(Source.Matrix);
  BlendMode := Source.BlendMode;
//  todo FilterList.A
end;

function TSWFButtonRecord.GetColorTransform: TSWFColorTransform;
begin
  if FColorTransform = nil then
    begin
     FColorTransform := TSWFColorTransform.Create;
     FColorTransform.hasAlpha := true;
    end;
  hasColorTransform := true;
  Result := FColorTransform;
end;

function TSWFButtonRecord.GetMatrix: TSWFMatrix;
begin
  if FMatrix = nil then FMatrix := TSWFMatrix.Create;
  Result := FMatrix;
end;

function TSWFButtonRecord.GetFilterList: TSWFFilterList;
begin
 if FFilterList = nil then
   begin
    FFilterList := TSWFFilterList.Create;
    ButtonHasFilterList := true;
   end;
 Result := FFilterList;
end;

procedure TSWFButtonRecord.WriteToStream(be: TBitsEngine);
begin
  be.WriteBits(0, 2);
  be.WriteBit(ButtonHasBlendMode);
  be.WriteBit(ButtonHasFilterList);
  be.WriteBit(bsHitTest in ButtonState);
  be.WriteBit(bsDown in ButtonState);
  be.WriteBit(bsOver in ButtonState);
  be.WriteBit(bsUp in ButtonState);
  be.WriteWord(CharacterID);
  be.WriteWord(Depth);
  be.WriteMatrix(Matrix.Rec);
  if hasColorTransform then
    begin
      ColorTransform.hasAlpha := true;
      be.WriteColorTransform(ColorTransform.REC);
    end;
  if ButtonHasFilterList then FilterList.WriteToStream(be);
  if ButtonHasBlendMode then be.WriteByte(BlendMode);
end;


{
****************************************************** TSWFBasedButton ******************************************************
}
constructor TSWFBasedButton.Create;
begin
  TagId := tagDefineButton;
  FButtonRecords := TObjectList.Create;
  FActions := TSWFActionList.Create;
end;

destructor TSWFBasedButton.Destroy;
begin
  ButtonRecords.Free;
  Actions.Free;
  inherited ;
end;

procedure TSWFBasedButton.Assign(Source: TBasedSWFObject);
var
  il: Word;
  BR: TSWFButtonRecord;
begin
  inherited;
  With TSWFDefineButton(Source) do
  begin
    self.ButtonId := ButtonId;
    if ButtonRecords.Count > 0 then
      for il := 0 to ButtonRecords.Count - 1 do
        begin
          BR := TSWFButtonRecord.Create(ButtonRecord[il].CharacterID);
          BR.Assign(ButtonRecord[il]);
          self.ButtonRecords.Add(BR);
        end;
  end;
end;

function TSWFBasedButton.GetButtonRecord(index: integer): TSWFButtonRecord;
begin
  Result := TSWFButtonRecord(ButtonRecords[index]);
end;

function TSWFBasedButton.MinVersion: Byte;
begin
  Result:= SWFVer3;
end;

{
***************************************************** TSWFDefineButton ******************************************************
}
procedure TSWFDefineButton.Assign(Source: TBasedSWFObject);
begin
  inherited;
   CopyActionList(Actions, TSWFDefineButton(Source).Actions);
end;

function TSWFDefineButton.GetAction(Index: Integer): TSWFAction;
begin
  Result := TSWFAction(Actions[index]);
end;

function TSWFDefineButton.MinVersion: Byte;
var
  il: Word;
begin
  Result := SWFVer3;
  if Actions.Count > 0 then
   for il := 0 to Actions.Count - 1 do
     if Result < Action[il].MinVersion then Result := Action[il].MinVersion;
end;

procedure TSWFDefineButton.ReadFromStream(be: TBitsEngine);
var
  b: Byte;
  BR: TSWFButtonRecord;
  BA: TSWFActionByteCode;
  AESz: LongInt;
begin
  ButtonID := be.ReadWord;
  Repeat
   b := be.ReadByte;
   if b > 0 then
     begin
       BR := TSWFButtonRecord.Create(0);
       BR.ButtonHasBlendMode := false;
       BR.ButtonHasFilterList := false;
       BR.ButtonState := [];
       if CheckBit(b, 4) then
         BR.ButtonState := [bsHitTest];
       if CheckBit(b, 3) then
         BR.ButtonState := BR.ButtonState + [bsDown];
       if CheckBit(b, 2) then
         BR.ButtonState := BR.ButtonState + [bsOver];
       if CheckBit(b, 1) then
         BR.ButtonState := BR.ButtonState + [bsUp];
      BR.CharacterID :=  be.ReadWord;
      BR.Depth := be.ReadWord;
      BR.Matrix.Rec := be.ReadMatrix;
      ButtonRecords.Add(BR);
     end;
  Until b = 0;
  if ParseActions then ReadActionList(be, Actions, $FFFF)
   else
    begin
     AESz := FindEndActions(be);
     BA := TSWFActionByteCode.Create;
     BA.DataSize := AESz - be.BitsStream.Position - 1;
     if BA.DataSize > 0 then
       begin
        BA.SelfDestroy := true;
        GetMem(BA.fData, BA.DataSize);
        be.BitsStream.Read(BA.Data^, BA.DataSize);
       end;
     Actions.Add(BA);
  
     be.ReadByte; // last 0
    end;
end;

procedure TSWFDefineButton.WriteTagBody(be: TBitsEngine);
var
  il: Integer;
begin
  be.WriteWord(ButtonID);
  if ButtonRecords.Count > 0 then
    for il := 0 to ButtonRecords.Count - 1 do
      ButtonRecord[il].WriteToStream(be);
  BE.WriteByte(0); //EndFlag

  if Actions.count>0 then
    for il := 0 to Actions.count - 1 do
       TSWFAction(Actions[il]).WriteToStream(BE);

  BE.WriteByte(0);
end;


{
*************************************************** TSWFButtonCondAction ****************************************************
}
procedure TSWFButtonCondAction.Assign(Source: TSWFButtonCondAction);
begin
  ID_Key := Source.Id_Key;
  ActionConditions := Source.ActionConditions;
  CopyActionList(Source, self);
end;

function TSWFButtonCondAction.Actions: TSWFActionList;
begin
  Result := self;
end;

procedure TSWFButtonCondAction.WriteToStream(be: TBitsEngine; isEnd:boolean);
var
  AOffset: LongInt;
  il: Word;
begin
  AOffset := be.BitsStream.Size;
  BE.WriteWord(0); // Offset from start of this field to next
  BE.WriteBit(IdleToOverDown in ActionConditions);
  BE.WriteBit(OutDownToIdle in ActionConditions);
  BE.WriteBit(OutDownToOverDown in ActionConditions);
  BE.WriteBit(OverDownToOutDown in ActionConditions);
  BE.WriteBit(OverDownToOverUp in ActionConditions);
  BE.WriteBit(OverUpToOverDown in ActionConditions);
  BE.WriteBit(OverUpToIdle in ActionConditions);
  BE.WriteBit(IdleToOverUp in ActionConditions);
  BE.WriteBits(ID_KEY, 7);
  BE.WriteBit(OverDownToIdle in ActionConditions);
  if Count > 0 then
    for il:=0 to Count - 1 do
      Action[il].WriteToStream(BE);

  BE.WriteByte(0); //EndFlag

  if not isEnd then
    begin
      BE.BitsStream.Position := AOffset;
      BE.WriteWord(BE.BitsStream.Size - AOffset);
      BE.BitsStream.Position := BE.BitsStream.Size;
    end;
end;

{
***************************************************** TSWFDefineButton2 *****************************************************
}
constructor TSWFDefineButton2.Create;
begin
  inherited ;
  TagId := tagDefineButton2;
end;

procedure TSWFDefineButton2.Assign(Source: TBasedSWFObject);
var
  CA: TSWFButtonCondAction;
  il: Word;
begin
  inherited;
  With TSWFDefineButton2(Source) do
  begin
    self.TrackAsMenu := TrackAsMenu;
    if Actions.Count > 0 then
     for il := 0 to Actions.Count - 1 do
      begin
        CA := TSWFButtonCondAction.Create;
        self.Actions.Add(CA);
        CA.Assign(CondAction[il]);
      end;
  end;
end;

function TSWFDefineButton2.GetCondAction(Index: Integer): TSWFButtonCondAction;
begin
  Result := TSWFButtonCondAction(Actions[index]);
end;

function TSWFDefineButton2.MinVersion: Byte;
begin
  Result := SWFVer3;
  // + check actions
end;

procedure TSWFDefineButton2.ReadFromStream(be: TBitsEngine);
var
  b: Byte;
  ActionOffset, CondActionSize: Word;
  PP: LongInt;
  BCA: TSWFButtonCondAction;
  BR: TSWFButtonRecord;
  BA: TSWFActionByteCode;
  AESz: LongInt;
begin
  PP := be.BitsStream.Position;
  ButtonId := be.ReadWord;
  b := be.ReadByte;
  TrackAsMenu := CheckBit(b, 1);
  ActionOffset := be.ReadWord;
  //  if ActionOffset > 0 then
  Repeat
   b := be.ReadByte;
   if b > 0 then
     begin
       BR := TSWFButtonRecord.Create(0);
       BR.ButtonHasBlendMode := CheckBit(b, 6);
       BR.ButtonHasFilterList := CheckBit(b, 5);
       BR.hasColorTransform := true;
       BR.ButtonState := [];
       if CheckBit(b, 4) then
         BR.ButtonState := [bsHitTest];
       if CheckBit(b, 3) then
         BR.ButtonState := BR.ButtonState + [bsDown];
       if CheckBit(b, 2) then
         BR.ButtonState := BR.ButtonState + [bsOver];
       if CheckBit(b, 1) then
         BR.ButtonState := BR.ButtonState + [bsUp];
      BR.CharacterID :=  be.ReadWord;
      BR.Depth := be.ReadWord;
      BR.Matrix.Rec := be.ReadMatrix;
      BR.ColorTransform.REC := be.ReadColorTransform;
      if BR.ButtonHasFilterList then
        begin
          BR.FilterList.ReadFromStream(be);
        end;
      if BR.ButtonHasBlendMode then BR.BlendMode := be.ReadByte;
      ButtonRecords.Add(BR);
     end;
  Until b = 0;
  PP := BodySize - (be.BitsStream.Position - PP);

  if (ActionOffset > 0) and (PP > 0) then
  Repeat
    BCA := TSWFButtonCondAction.Create;
    CondActionSize := be.ReadWord;
    b := be.ReadByte;
    if CheckBit(b, 8) then BCA.ActionConditions := [IdleToOverDown]
      else BCA.ActionConditions := [];
    if CheckBit(b, 7) then BCA.ActionConditions := BCA.ActionConditions + [OutDownToIdle];
    if CheckBit(b, 6) then BCA.ActionConditions := BCA.ActionConditions + [OutDownToOverDown];
    if CheckBit(b, 5) then BCA.ActionConditions := BCA.ActionConditions + [OverDownToOutDown];
    if CheckBit(b, 4) then BCA.ActionConditions := BCA.ActionConditions + [OverDownToOverUp];
    if CheckBit(b, 3) then BCA.ActionConditions := BCA.ActionConditions + [OverUpToOverDown];
    if CheckBit(b, 2) then BCA.ActionConditions := BCA.ActionConditions + [OverUpToIdle];
    if CheckBit(b, 1) then BCA.ActionConditions := BCA.ActionConditions + [IdleToOverUp];
    b := be.ReadByte;
    if CheckBit(b, 1) then BCA.ActionConditions := BCA.ActionConditions + [OverDownToIdle];
    BCA.ID_Key := b shr 1;
    (*    if CondActionSize = 0 then ASize := PP else
          begin
            ASize := CondActionSize - 2; // 1 + 1
            PP := PP - CondActionSize;
          end; *)

    if ParseActions then ReadActionList(be, BCA, $FFFF) // Auto find End
      else
      begin
        AESz := FindEndActions(be);
        BA := TSWFActionByteCode.Create;
        BA.DataSize := AESz - be.BitsStream.Position - 1;
        if BA.DataSize > 0 then
          begin
           BA.SelfDestroy := true;
           GetMem(BA.fData, BA.DataSize);
           be.BitsStream.Read(BA.Data^, BA.DataSize);
          end;
        BCA.Add(BA);
        be.ReadByte; // last 0
      end;

    Actions.Add(BCA);
  Until CondActionSize = 0;
end;

procedure TSWFDefineButton2.WriteTagBody(be: TBitsEngine);
var
  AOffset: LongInt;
  il: Word;
begin
  BE.WriteWord(ButtonId);
  BE.WriteByte(Byte(TrackAsMenu));
  AOffset := be.BitsStream.Size;
  BE.WriteWord(0);
  if ButtonRecords.count>0 then
   for il:=0 to ButtonRecords.count - 1 do
    with ButtonRecord[il] do
     begin
       hasColorTransform := true;
       WriteToStream(BE);
     end;
  BE.WriteByte(0); //EndFlag

  if Actions.Count > 0 then
   begin
    be.BitsStream.Position := AOffset;
    AOffset := be.BitsStream.Size - AOffset ;
    be.WriteWord(AOffset);
    be.BitsStream.Position := be.BitsStream.Size;
    for il:=0 to Actions.Count-1 do
      TSWFButtonCondAction(Actions[il]).WriteToStream(BE, il = (Actions.Count-1));
   end;
end;


{
************************************************** TSWFDefineButtonCxform ***************************************************
}
constructor TSWFDefineButtonCxform.Create;
begin
  TagID := tagDefineButtonCxform;
  FButtonColorTransform := TSWFColorTransform.Create;
end;

destructor TSWFDefineButtonCxform.Destroy;
begin
  FButtonColorTransform.Free;
end;

procedure TSWFDefineButtonCxform.Assign(Source: TBasedSWFObject);
begin
  inherited;
  With TSWFDefineButtonCxform(Source) do
  begin
    self.ButtonId := ButtonId;
    self.ButtonColorTransform.Assign(ButtonColorTransform);
  end;
end;

function TSWFDefineButtonCxform.MinVersion: Byte;
begin
  result := SWFVer2;
end;

procedure TSWFDefineButtonCxform.ReadFromStream(be: TBitsEngine);
begin
  ButtonID := be.ReadWord;
  ButtonColorTransform.REC := be.ReadColorTransform(false);
end;

procedure TSWFDefineButtonCxform.WriteTagBody(be: TBitsEngine);
begin
  be.WriteWord(ButtonID);
  be.WriteColorTransform(ButtonColorTransform.REC);
end;


{
*************************************************** TSWFDefineButtonSound ***************************************************
}
constructor TSWFDefineButtonSound.Create;
begin
  TagID := tagDefineButtonSound;
end;

destructor TSWFDefineButtonSound.Destroy;
begin
  if FSndIdleToOverUp <> nil then FSndIdleToOverUp.Free;
  if FSndOverDownToOverUp <> nil then FSndOverDownToOverUp.Free;
  if FSndOverUpToIdle <> nil then FSndOverUpToIdle.Free;
  if FSndOverUpToOverDown <> nil then FSndOverUpToOverDown.Free;
  inherited Destroy;
end;

procedure TSWFDefineButtonSound.Assign(Source: TBasedSWFObject);
begin
  inherited;
  With TSWFDefineButtonSound(Source) do
  begin
    self.ButtonId := ButtonId;
    if HasOverUpToIdle and (SndOverUpToIdle.SoundId > 0)
        then self.SndOverUpToIdle.Assign(SndOverUpToIdle);
    if HasIdleToOverUp  and (SndIdleToOverUp.SoundId > 0)
        then self.SndIdleToOverUp.Assign(SndIdleToOverUp);
    if HasOverUpToOverDown  and (SndOverUpToOverDown.SoundId > 0)
        then self.SndOverUpToOverDown.Assign(SndOverUpToOverDown);
    if HasOverDownToOverUp and (SndOverDownToOverUp.SoundId > 0)
        then self.SndOverDownToOverUp.Assign(SndOverDownToOverUp);
  end;
end;

function TSWFDefineButtonSound.GetSndIdleToOverUp: TSWFStartSound;
begin
  if FSndIdleToOverUp = nil then FSndIdleToOverUp := TSWFStartSound.Create;
  HasIdleToOverUp := true;
  Result := FSndIdleToOverUp;
end;

function TSWFDefineButtonSound.GetSndOverDownToOverUp: TSWFStartSound;
begin
  if FSndOverDownToOverUp = nil then FSndOverDownToOverUp := TSWFStartSound.Create;
  HasOverDownToOverUp:= true;
  Result := FSndOverDownToOverUp;
end;

function TSWFDefineButtonSound.GetSndOverUpToIdle: TSWFStartSound;
begin
  if FSndOverUpToIdle = nil then FSndOverUpToIdle := TSWFStartSound.Create;
  HasOverUpToIdle := true;
  Result := FSndOverUpToIdle;
end;

function TSWFDefineButtonSound.GetSndOverUpToOverDown: TSWFStartSound;
begin
  if FSndOverUpToOverDown = nil then FSndOverUpToOverDown:= TSWFStartSound.Create;
  HasOverUpToOverDown := true;
  Result := FSndOverUpToOverDown;
end;

function TSWFDefineButtonSound.MinVersion: Byte;
begin
  Result := SWFVer2;
end;

procedure TSWFDefineButtonSound.ReadFromStream(be: TBitsEngine);
var
  W: Word;
begin
  ButtonId := be.ReadWord;
  W := be.ReadWord;
  if W > 0 then
    begin
      be.BitsStream.Seek( -2, soFromCurrent);
      SndOverUpToIdle.ReadFromStream(be);
    end;
  W := be.ReadWord;
  if W > 0 then
    begin
      be.BitsStream.Seek( -2, soFromCurrent);
      SndIdleToOverUp.ReadFromStream(be);
    end;
  W := be.ReadWord;
  if W > 0 then
    begin
      be.BitsStream.Seek( -2, soFromCurrent);
      SndOverUpToOverDown.ReadFromStream(be);
    end;
  W := be.ReadWord;
  if W > 0 then
    begin
      be.BitsStream.Seek( -2, soFromCurrent);
      SndOverDownToOverUp.ReadFromStream(be);
    end;
end;

procedure TSWFDefineButtonSound.WriteTagBody(be: TBitsEngine);
begin
  be.WriteWord(ButtonId);
  if HasOverUpToIdle and (SndOverUpToIdle.SoundId > 0)
      then SndOverUpToIdle.WriteTagBody(be) else be.WriteWord(0);
  if HasIdleToOverUp  and (SndIdleToOverUp.SoundId > 0)
      then SndIdleToOverUp.WriteTagBody(be) else be.WriteWord(0);
  if HasOverUpToOverDown  and (SndOverUpToOverDown.SoundId > 0)
      then SndOverUpToOverDown.WriteTagBody(be) else be.WriteWord(0);
  if HasOverDownToOverUp and (SndOverDownToOverUp.SoundId > 0)
      then SndOverDownToOverUp.WriteTagBody(be) else be.WriteWord(0);
end;

// ==========================================================//
//                       SPRITE                             //
// ==========================================================//

{
***************************************************** TSWFDefineSprite ******************************************************
}
constructor TSWFDefineSprite.Create;
begin
  TagId := tagDefineSprite;
  FControlTags := TObjectList.Create;
end;

destructor TSWFDefineSprite.Destroy;
begin
  ControlTags.Free;
  inherited;
end;

procedure TSWFDefineSprite.Assign(Source: TBasedSWFObject);
var
  il: Word;
  NewT, OldT: TSWFObject;
begin
  inherited;
  With TSWFDefineSprite(Source) do
  begin
    self.SWFVersion := SWFVersion;
    self.SpriteID := SpriteID;
    self.FrameCount := FrameCount;
    self.ParseActions := ParseActions;
    if ControlTags.Count > 0 then
      For il := 0 to ControlTags.Count - 1 do
        begin
          OldT := TSWFObject(ControlTags[il]);
          NewT := GenerateSWFObject(OldT.TagId);
          NewT.Assign(OldT);
          self.ControlTags.Add(NewT);
        end;
  end;
end;

function TSWFDefineSprite.GetControlTag(Index: Integer): TSWFObject;
begin
  Result := TSWFObject(ControlTags[Index]);
end;

function TSWFDefineSprite.MinVersion: Byte;
begin
  Result := SWFVer3;
end;

procedure TSWFDefineSprite.ReadFromStream(be: TBitsEngine);
var
  EndFlag: Boolean;
  tmpW: Word;
  SWFTag: TSWFObject;
  SndType: byte;
begin
  SpriteID := be.ReadWord;
  FrameCount := be.ReadWord;
  Repeat
   tmpW := be.ReadWord;
   EndFlag := tmpW = 0;
   if not EndFlag then
     begin
      SWFTag := GenerateSWFObject(tmpW shr 6);
      SWFTag.BodySize := (tmpW and $3f);
      if SWFTag.BodySize = $3f then
        SWFTag.BodySize := be.ReadDWord;
      case SWFTag.TagID of
        tagPlaceObject2:
          with TSWFPlaceObject2(SWFTag) do
            begin
              SWFVersion := self.SWFVersion;
              ParseActions := self.ParseActions;
            end;
        tagDoAction, tagDoInitAction:
          TSWFDoAction(SWFTag).ParseActions := ParseActions;
        tagSoundStreamBlock:
          TSWFSoundStreamBlock(SWFTag).StreamSoundCompression := SndType;
      end;
      SWFTag.ReadFromStream(be);

      if SWFTag.TagID in [tagSoundStreamHead, tagSoundStreamHead2] then
           SndType := TSWFSoundStreamHead(SWFTag).StreamSoundCompression;

     end else
      SWFTag := GenerateSWFObject(0);
   ControlTags.Add(SWFTag);
  Until EndFlag;

end;

procedure TSWFDefineSprite.WriteTagBody(be: TBitsEngine);
var
  il: Integer;
  EndFlag: Boolean;
begin
  be.WriteWord(SpriteID);
  be.WriteWord(FrameCount);
  EndFlag := false;
  if ControlTags.Count >0 then
   For il := 0 to ControlTags.Count - 1 do
    With TBasedSWFObject(ControlTags[il]) do
     begin
       WriteToStream(be);
       if (il = (ControlTags.Count - 1)) and (LibraryLevel = 0) then
        with TSWFObject(ControlTags[il]) do
         EndFlag := tagID = tagEnd;
     end;
  if not EndFlag then be.WriteWord(0);
end;


{================================= TSWFDefineSceneAndFrameLabelData ======================================}

constructor TSWFDefineSceneAndFrameLabelData.Create;
begin
  TagID := tagDefineSceneAndFrameLabelData;
  FScenes := TStringList.Create;
  FFrameLabels := TStringList.Create;
end;

destructor TSWFDefineSceneAndFrameLabelData.Destroy;
begin
  FFrameLabels.Free;
  FScenes.Free;
  inherited;
end;

function TSWFDefineSceneAndFrameLabelData.MinVersion: Byte;
begin
  Result := SWFVer9;
end;


procedure TSWFDefineSceneAndFrameLabelData.ReadFromStream(be: TBitsEngine);
 var count, il, len, fnum: DWord;
begin
  count := be.ReadEncodedU32;
  if count > 0 then
    for il := 0 to count - 1 do
    begin
      len := be.ReadEncodedU32;
      Scenes.Add(be.ReadString);
    end;

  count := be.ReadEncodedU32;
  if count > 0 then
    for il := 0 to count - 1 do
    begin
      fnum := be.ReadEncodedU32;
      FrameLabels.AddObject(be.ReadString, Pointer(fnum));
    end;

end;

procedure TSWFDefineSceneAndFrameLabelData.WriteTagBody(be: TBitsEngine);
 var il: integer;
begin
  be.WriteEncodedU32(Scenes.Count);
  if Scenes.Count > 0 then
    for il := 0 to Scenes.Count -1 do
    begin
      be.WriteEncodedU32(Length(Scenes[il]));
      be.WriteString(Scenes[il]);
    end;

  be.WriteEncodedU32(FrameLabels.Count);
  if FrameLabels.Count > 0 then
    for il := 0 to FrameLabels.Count -1 do
    begin
      be.WriteEncodedU32(longint(FrameLabels.Objects[il]));
      be.WriteString(FrameLabels[il]);
    end;
end;



// ================== undocumented Flash tags ==========================

constructor TSWFByteCodeTag.Create;
begin
 inherited;
 FTagID := tagErrorTag;
end;

function TSWFByteCodeTag.GetByteCode(Index: word): Byte;
 var B: PByte;
begin
  B := Data;
  Inc(B, Index);
  Result := B^;
end;

procedure TSWFByteCodeTag.ReadFromStream(be: TBitsEngine);
begin
  DataSize := BodySize;
  GetMem(FData, DataSize);
  be.BitsStream.Read(Data^, DataSize);
  selfdestroy := true;
end;

procedure TSWFByteCodeTag.WriteToStream(be: TBitsEngine);
begin
  TagID := TagIDFrom;
  inherited;
  TagIDFrom := tagErrorTag;
end;

procedure TSWFByteCodeTag.WriteTagBody(be: TBitsEngine);
begin
  if DataSize > 0 then be.BitsStream.Write(Data^, DataSize);
end;


{ ======================================  TSWFDefineBinaryData ===================================}

constructor TSWFDefineBinaryData.Create;
begin
  inherited;
  TagID := tagDefineBinaryData;
end;

procedure TSWFDefineBinaryData.ReadFromStream(be: TBitsEngine);
begin
  CharacterID := be.ReadWord;
  be.ReadDWord; // Reserved space
  DataSize := BodySize - 2 - 4;
  GetMem(FData, DataSize);
  be.BitsStream.Read(Data^, DataSize);
  selfdestroy := true;
end;

procedure TSWFDefineBinaryData.WriteTagBody(be: TBitsEngine);
begin
  be.WriteWord(CharacterID);
  be.Write4byte(0);
  if Assigned(OnDataWrite) then OnDataWrite(self, be) else
    if DataSize > 0 then be.BitsStream.Write(Data^, DataSize);
end;



// =========================  TOOLS  ================================

Function GenerateSWFObject(ID: word): TSWFObject;
begin
 Case ID of
// Display List
   tagPlaceObject:
        Result := TSWFPlaceObject.Create;
   tagPlaceObject2:
        Result := TSWFPlaceObject2.Create;
   tagPlaceObject3:
        Result := TSWFPlaceObject3.Create;
   tagRemoveObject:
        Result := TSWFRemoveObject.Create;
   tagRemoveObject2:
        Result := TSWFRemoveObject2.Create;
   tagShowFrame:
        Result := TSWFShowFrame.Create;

// Control Tags
   tagSetBackgroundColor:
        Result := TSWFSetBackgroundColor.Create;
   tagFrameLabel:
        Result := TSWFFrameLabel.Create;
   tagProtect:
        Result := TSWFProtect.Create;
   tagEnd:
        Result := TSWFEnd.Create;
   tagExportAssets:
        Result := TSWFExportAssets.Create;
   tagImportAssets:
        Result := TSWFImportAssets.Create;
   tagEnableDebugger:
        result := TSWFEnableDebugger.Create;
   tagEnableDebugger2:
        result := TSWFEnableDebugger2.Create;
   tagScriptLimits:
        Result := TSWFScriptLimits.Create;
   tagSetTabIndex:
        Result := TSWFSetTabIndex.Create;
   tagFileAttributes:
        Result := TSWFFileAttributes.Create;
   tagMetadata:
        Result := TSWFMetadata.Create;
   tagProductInfo:
        Result := TSWFProductInfo.Create;
   tagDefineScalingGrid:
        Result := TSWFDefineScalingGrid.Create;
   tagImportAssets2:
        Result := TSWFImportAssets2.Create;
   tagSymbolClass:
        Result := TSWFSymbolClass.Create;

// Actions
   tagDoAction:
        Result := TSWFDoAction.Create;
   tagDoInitAction:
        Result := TSWFDoInitAction.Create;
   tagDoABC:
        Result := TSWFDoABC.Create;

// Shapes
   tagDefineShape:
        Result := TSWFDefineShape.Create;
   tagDefineShape2:
        Result := TSWFDefineShape2.Create;
   tagDefineShape3:
        Result := TSWFDefineShape3.Create;
   tagDefineShape4:
        Result := TSWFDefineShape4.Create;

// Bitmaps
   tagDefineBits:
        Result := TSWFDefineBits.Create;
   tagJPEGTables:
        Result := TSWFJPEGTables.Create;
   tagDefineBitsJPEG2:
        Result := TSWFDefineBitsJPEG2.Create;
   tagDefineBitsJPEG3:
        Result := TSWFDefineBitsJPEG3.Create;
   tagDefineBitsLossless:
        Result := TSWFDefineBitsLossless.Create;
   tagDefineBitsLossless2:
        Result := TSWFDefineBitsLossless2.Create;

// Shape Morphing
   tagDefineMorphShape:
        Result := TSWFDefineMorphShape.Create;
   tagDefineMorphShape2:
        Result := TSWFDefineMorphShape2.Create;

// Fonts and Text
   tagDefineFont:
        Result := TSWFDefineFont.Create;
   tagDefineFont2:
        Result := TSWFDefineFont2.Create;
   tagDefineFont3:
        Result := TSWFDefineFont3.Create;

   tagDefineFontInfo:
        Result := TSWFDefineFontInfo.Create;
   tagDefineFontInfo2:
        Result := TSWFDefineFontInfo2.Create;
   tagDefineFontAlignZones:
        Result := TSWFDefineFontAlignZones.Create;
   tagDefineFontName:
        Result := TSWFDefineFontName.Create;

   tagDefineText:
        Result := TSWFDefineText.Create;
   tagDefineText2:
        Result := TSWFDefineText2.Create;
   tagDefineEditText:
        Result := TSWFDefineEditText.Create;
   tagCSMTextSettings:
        Result := TSWFCSMTextSettings.Create;

// Sounds
   tagStartSound:
        Result := TSWFStartSound.Create;
   tagStartSound2:
        Result := TSWFStartSound2.Create;
   tagSoundStreamHead:
        Result := TSWFSoundStreamHead.Create;
   tagSoundStreamHead2:
        Result := TSWFSoundStreamHead2.Create;
   tagSoundStreamBlock:
        Result := TSWFSoundStreamBlock.Create;
   tagDefineSound :
        Result := TSWFDefineSound.Create;

// Button
   tagDefineButton:
        Result := TSWFDefineButton.Create;
   tagDefineButton2:
        Result := TSWFDefineButton2.Create;
   tagDefineButtonSound:
        result := TSWFDefineButtonSound.Create;
   tagDefineButtonCxform:
        result := TSWFDefineButtonCxform.Create;

// Sprite
   tagDefineSprite:
        Result := TSWFDefineSprite.Create;
   tagDefineSceneAndFrameLabelData:
        Result := TSWFDefineSceneAndFrameLabelData.Create;

// Video
   tagDefineVideoStream:
        result := TSWFDefineVideoStream.Create;
   tagVideoFrame:
        result := TSWFVideoFrame.Create;

   tagDefineBinaryData:
        result := TSWFDefineBinaryData.Create;

   else
     begin
       Result := TSWFByteCodeTag.Create;
       with TSWFByteCodeTag(Result) do
         begin
           Text := 'Uniknow tag';
           FTagIDFrom := ID;
         end;
     end;
 end;
end;

Function GenerateSWFAction(ID: word): TSWFAction;
begin
 Case ID of
   // SWF 3
   ActionPlay: Result := TSWFActionPlay.Create;
   ActionStop: Result := TSWFActionStop.Create;
   ActionNextFrame: Result := TSWFActionNextFrame.Create;
   ActionPreviousFrame: Result := TSWFActionPreviousFrame.Create;
   ActionGotoFrame: Result := TSWFActionGotoFrame.Create;
   ActionGoToLabel: Result := TSWFActionGoToLabel.Create;
   ActionWaitForFrame: Result := TSWFActionWaitForFrame.Create;
   ActionGetURL: Result := TSWFActionGetURL.Create;
   ActionStopSounds: Result := TSWFActionStopSounds.Create;
   ActionToggleQuality: Result := TSWFActionToggleQuality.Create;
   ActionSetTarget: Result := TSWFActionSetTarget.Create;

   //SWF 4
   ActionAdd: Result := TSWFActionAdd.Create;
   ActionDivide: Result := TSWFActionDivide.Create;
   ActionMultiply: Result := TSWFActionMultiply.Create;
   ActionSubtract: Result := TSWFActionSubtract.Create;
   ActionEquals: Result := TSWFActionEquals.Create;
   ActionLess: Result := TSWFActionLess.Create;
   ActionAnd: Result := TSWFActionAnd.Create;
   ActionNot: Result := TSWFActionNot.Create;
   ActionOr: Result := TSWFActionOr.Create;
   ActionStringAdd: Result := TSWFActionStringAdd.Create;
   ActionStringEquals: Result := TSWFActionStringEquals.Create;
   ActionStringExtract: Result := TSWFActionStringExtract.Create;
   ActionStringLength: Result := TSWFActionStringLength.Create;
   ActionMBStringExtract: Result := TSWFActionMBStringExtract.Create;
   ActionMBStringLength: Result := TSWFActionMBStringLength.Create;
   ActionStringLess: Result := TSWFActionStringLess.Create;
   ActionPop: Result := TSWFActionPop.Create;
   ActionPush: Result := TSWFActionPush.Create;
   ActionAsciiToChar: Result := TSWFActionAsciiToChar.Create;
   ActionCharToAscii: Result := TSWFActionCharToAscii.Create;
   ActionToInteger: Result := TSWFActionToInteger.Create;
   ActionMBAsciiToChar: Result := TSWFActionMBAsciiToChar.Create;
   ActionMBCharToAscii: Result := TSWFActionMBCharToAscii.Create;
   ActionCall: Result := TSWFActionCall.Create;
   ActionIf: Result := TSWFActionIf.Create;
   ActionJump: Result := TSWFActionJump.Create;
   ActionGetVariable: Result := TSWFActionGetVariable.Create;
   ActionSetVariable: Result := TSWFActionSetVariable.Create;
   ActionGetURL2: Result := TSWFActionGetURL2.Create;
   ActionGetProperty: Result := TSWFActionGetProperty.Create;
   ActionGotoFrame2: Result := TSWFActionGotoFrame2.Create;
   ActionRemoveSprite: Result := TSWFActionRemoveSprite.Create;
   ActionSetProperty: Result := TSWFActionSetProperty.Create;
   ActionSetTarget2: Result := TSWFActionSetTarget2.Create;
   ActionStartDrag: Result := TSWFActionStartDrag.Create;
   ActionWaitForFrame2: Result := TSWFActionWaitForFrame2.Create;
   ActionCloneSprite: Result := TSWFActionCloneSprite.Create;
   ActionEndDrag: Result := TSWFActionEndDrag.Create;
   ActionGetTime: Result := TSWFActionGetTime.Create;
   ActionRandomNumber: Result := TSWFActionRandomNumber.Create;
   ActionTrace: Result := TSWFActionTrace.Create;

   //SWF 5
   ActionCallFunction: Result := TSWFActionCallFunction.Create;
   ActionCallMethod: Result := TSWFActionCallMethod.Create;
   ActionConstantPool: Result := TSWFActionConstantPool.Create;
   ActionDefineFunction: Result := TSWFActionDefineFunction.Create;
   ActionDefineLocal: Result := TSWFActionDefineLocal.Create;
   ActionDefineLocal2: Result := TSWFActionDefineLocal2.Create;
   ActionDelete: Result := TSWFActionDelete.Create;
   ActionDelete2: Result := TSWFActionDelete2.Create;
   ActionEnumerate: Result := TSWFActionEnumerate.Create;
   ActionEquals2: Result := TSWFActionEquals2.Create;
   ActionGetMember: Result := TSWFActionGetMember.Create;
   ActionInitArray: Result := TSWFActionInitArray.Create;
   ActionInitObject: Result := TSWFActionInitObject.Create;
   ActionNewMethod: Result := TSWFActionNewMethod.Create;
   ActionNewObject: Result := TSWFActionNewObject.Create;
   ActionSetMember: Result := TSWFActionSetMember.Create;
   ActionTargetPath: Result := TSWFActionTargetPath.Create;
   ActionWith: Result := TSWFActionWith.Create;
   ActionToNumber: Result := TSWFActionToNumber.Create;
   ActionToString: Result := TSWFActionToString.Create;
   ActionTypeOf: Result := TSWFActionTypeOf.Create;
   ActionAdd2: Result := TSWFActionAdd2.Create;
   ActionLess2: Result := TSWFActionLess2.Create;
   ActionModulo: Result := TSWFActionModulo.Create;
   ActionBitAnd: Result := TSWFActionBitAnd.Create;
   ActionBitLShift: Result := TSWFActionBitLShift.Create;
   ActionBitOr: Result := TSWFActionBitOr.Create;
   ActionBitRShift: Result := TSWFActionBitRShift.Create;
   ActionBitURShift: Result := TSWFActionBitURShift.Create;
   ActionBitXor: Result := TSWFActionBitXor.Create;
   ActionDecrement: Result := TSWFActionDecrement.Create;
   ActionIncrement: Result := TSWFActionIncrement.Create;
   ActionPushDuplicate: Result := TSWFActionPushDuplicate.Create;
   ActionReturn: Result := TSWFActionReturn.Create;
   ActionStackSwap: Result := TSWFActionStackSwap.Create;
   ActionStoreRegister: Result := TSWFActionStoreRegister.Create;

   //SWF 6
   ActionInstanceOf: Result := TSWFActionInstanceOf.Create;
   ActionEnumerate2: Result := TSWFActionEnumerate2.Create;
   ActionStrictEquals: Result := TSWFActionStrictEquals.Create;
   ActionGreater: Result := TSWFActionGreater.Create;
   ActionStringGreater: Result := TSWFActionStringGreater.Create;

   //SWF 7
   ActionDefineFunction2: Result := TSWFActionDefineFunction2.Create;
   ActionExtends: Result := TSWFActionExtends.Create;
   ActionCastOp: Result := TSWFActionCastOp.Create;
   ActionImplementsOp: Result := TSWFActionImplementsOp.Create;
   ActionTry: Result := TSWFActionTry.Create;
   ActionThrow: Result := TSWFActionThrow.Create;

   actionFSCommand2: Result := TSWFActionFSCommand2.Create;

   actionByteCode: Result := TSWFActionByteCode.Create;
   ActionOffsetWork: Result := TSWFOffsetMarker.Create;
   else Result := nil;
 end;
end;



Initialization
 tmpMemStream := TMemoryStream.Create;

finalization
 tmpMemStream.free;

{$IFDEF DebugAS3}
  if SLDebug <> nil then
  begin
    SLDebug.SaveToFile('debugAsS3.txt');
    SLDebug.Free;
  end;
{$ENDIF}

end.

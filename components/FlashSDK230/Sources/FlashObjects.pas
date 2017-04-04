//*******************************************************//
//                                                       //
//                      DelphiFlash.com                  //
//         Copyright (c) 2004-2008 FeatherySoft, Inc.    //
//                    info@delphiflash.com               //
//                                                       //
//*******************************************************//

//  Description:  Level of Flash-objects
//  Last update:  12 mar 2008
{$I defines.inc}
//{$Q-}

unit FlashObjects;
interface
  uses Windows, Classes, Contnrs, Graphics, SysUtils,
  {$IFDEF VARIANTS}
       Variants,
  {$ENDIF}
  {$IFDEF DelphiJPEG}
       JPEG,
  {$ENDIF}
       SWFConst, SWFObjects, SWFStreams, SWFTools,
       SoundReader, ImageReader, FLV;

type
  TFlashMovie = class;
 
  TFlashObject = class (TBasedSWFObject)
  private
    FOwner: TFlashMovie;
    procedure SetOwner(Value: TFlashMovie);
  protected
    procedure ChangeOwner; virtual;
  public
    constructor Create(owner: TFlashMovie);
    function LibraryLevel: Byte; override;
    property Owner: TFlashMovie read FOwner write SetOwner;
  end;

  TFlashIDObject = class (TFlashObject)
  private
    FCharacterId: Word;
  protected
    function GetCharacterId: Word; virtual;
    procedure SetCharacterId(ID: Word); virtual;
  public
    procedure Assign(Source: TBasedSWFObject); override;
    property CharacterId: Word read GetCharacterId write SetCharacterId;
   end;

  TFlashSound = class (TFlashIDObject)
  private
//    Data: TStream;
    DataBlockSize: LongInt;
    DataLen: LongInt;
    DataPos: LongInt;
    DataStart: LongInt;
    FAutoLoop: Boolean;
    fBitsPerSample: Byte;
    FDuration: Double;
    FMP3Info: TMP3Info;
    FrameSize: Word;
    FrameWriten: LongInt;
    FrecomendSampleCount: Word;
    FSampleCount: dword;
    FSamplesPerSec: Word;
    FsndFormat: Byte;
    FsndRate: Byte;
    FStartFrame: Word;
    FStereo: Boolean;
    F_16Bit: Boolean;
    FWaveCompressBits: byte;
    FWaveReader: TWaveReader;
    procedure SetWaveCompressBits(const Value: byte);
    function GetWaveReader: TWaveReader;
    procedure SetWaveReader(const Value: TWaveReader);
  protected
    isMultWriten: Byte;
    MP3SeekStart: Word;
    SamplesWriten: LongInt;
    SeekSamples: LongInt;
    wSampleCount: Word;
    wFrameCount: Integer; // count of need MP3 frame write
    WritenCount: Word;
    FileName: string;
    SelfDestroy: boolean;
    procedure ParseWaveInfo;
    property WaveReader: TWaveReader read GetWaveReader write SetWaveReader;
  public
    constructor Create(owner: TFlashMovie; fn: string = '');
    destructor Destroy; override;
    procedure Assign(Source: TBasedSWFObject); override;
    procedure FillHeader(SH: TSWFSoundStreamHead; fps: single);
    procedure LoadSound(fn: string);
    procedure LoadFromMemory(Src: TMemoryStream; isMP3: boolean);
    function MinVersion: Byte; override;
    function StartSound: TSWFStartSound;
    procedure WriteSoundBlock(BE: TBitsEngine);
    procedure WriteSoundData(sender: TSWFObject; BE: TBitsEngine);
    procedure WriteToStream(be: TBitsEngine); override;
    property AutoLoop: Boolean read FAutoLoop write FAutoLoop;
    property Duration: Double read FDuration write FDuration;
    property MP3Info: TMP3Info read FMP3Info write FMP3Info;
    property recomendSampleCount: Word read FrecomendSampleCount write FrecomendSampleCount;
    property SampleCount: dword read FSampleCount write FSampleCount;
    property SamplesPerSec: Word read FSamplesPerSec;
    property sndFormat: Byte read FsndFormat write FsndFormat;
    property sndRate: Byte read FsndRate write FsndRate;
    property StartFrame: Word read FStartFrame write FStartFrame;
    property Stereo: Boolean read FStereo write FStereo;
    property _16Bit: Boolean read F_16Bit write F_16Bit;
    property WaveCompressBits: byte read FWaveCompressBits write SetWaveCompressBits;
  end;

// =================== TFlashImage  ========================
  TFlashImage = class;
  TLoadCustomImageProc = procedure (sender: TFlashImage; FileName: string);
  TLoadCustomImageEvent = procedure (sender: TFlashImage; FileName: string; var Default: boolean) of object;
  TImageDataState = (dsNoInit, dsMemory, dsMemoryBMP, dsInitJPEG, dsMemoryJPEG, dsFileJPEG);

  TFlashImage = class (TFlashIDObject)
  private
    FAlphaData: TMemoryStream;
    FAsJPEG: Boolean;
    FBMPStorage: TBMPReader;
    FColorCount: Integer;
    FConvertProgressiveJPEG: Boolean;
    FData: TStream;
    FDataState: TImageDataState;
    FFileName: string;
    FHasUseAlpha: Boolean;
    FHeight: Word;
    FSaveWidth: Word;
    FWidth: Word;
    SWFBMPType: Byte;
    procedure SetAsJPEG(const Value: Boolean);
    function GetAlphaData: TMemoryStream;
    function GetAlphaPixel(X, Y: Integer): Byte;
    function GetBMPStorage: TBMPReader;
    function GetData: TStream;
    function GetHeight: Word;
    function GetWidth: Word;
    procedure LoadAlphaDataFromBMPReader(BMP: TBMPReader);
    procedure SetAlphaPixel(X, Y: Integer; Value: Byte);
    procedure SetConvertProgressiveJPEG(Value: Boolean);
    procedure SetData(Value: TStream);
    procedure SetFileName(value: string);
  protected
    procedure GetBMPInfo;
  public
    constructor Create(owner: TFlashMovie; fn: string = '');
    destructor Destroy; override;
    procedure Assign(Source: TBasedSWFObject); override;
    procedure CopyToStream(S: TStream);
    procedure LoadAlphaDataFromFile(fn: string);
    procedure LoadAlphaDataFromHandle(HBMP: HBitmap);
    procedure LoadAlphaDataFromStream(S: TStream);
    procedure LoadDataFromFile(fn: string);
    procedure LoadDataFromHandle(HBMP: HBitmap);
    procedure LoadDataFromNativeStream(S: TStream; JPG: boolean; Width, Height: integer); overload;
    procedure LoadDataFromNativeStream(S: TStream; JPG: boolean; Width, Height: integer; BMPType, ColorCount: byte; HasAlpha: boolean); overload;
    procedure LoadDataFromStream(S: TStream);
    procedure MakeAlphaLayer(Alpha: byte = $FF);
    procedure MakeDataFromBMP;
    procedure FillBitsLossless(BL: TSWFDefineBitsLossless);
    function MinVersion: Byte; override;
    procedure SetAlphaColor(Color: recRGBA);
    procedure SetAlphaIndex(Index, Alpha: byte);
    procedure WriteAlphaData(sender: TSWFObject; BE: TBitsEngine);
    procedure WriteData(sender: TSWFObject; BE: TBitsEngine);
    procedure WriteToStream(be: TBitsEngine); override;
    property AlphaData: TMemoryStream read GetAlphaData;
    property AlphaPixel[X, Y: Integer]: Byte read GetAlphaPixel write SetAlphaPixel;
    property AsJPEG: Boolean read FAsJPEG write SetAsJPEG;
    property BMPStorage: TBMPReader read GetBMPStorage;
    property ColorCount: Integer read FColorCount;
    property ConvertProgressiveJPEG: Boolean read FConvertProgressiveJPEG write SetConvertProgressiveJPEG;
    property Data: TStream read GetData write SetData;
    property DataState: TImageDataState read FDataState;
    property FileName: string read FFileName write SetFileName;
    property HasUseAlpha: Boolean read FHasUseAlpha write FHasUseAlpha;
    property Height: Word read GetHeight;
    property SaveWidth: Word read FSaveWidth;
    property Width: Word read GetWidth;
  end;

// =================== TFlashActionScript ========================
  TFlashActionScript = class (TFlashObject)
  private
    FActionList: TSWFActionList;
    FSelfDestroy: Boolean;
  protected
    function GetAction(index: integer): TSWFAction;
  public
    constructor Create(owner: TFlashMovie; A: TSWFActionList = nil);
    destructor Destroy; override;
    procedure Add;
    procedure Add2;
    procedure AsciiToChar;
    procedure Assign(Source: TBasedSWFObject); override;
    procedure BitAnd;
    procedure BitLShift;
    procedure BitOr;
    procedure BitRShift;
    procedure BitURShift;
    procedure BitXor;
    function ByteCode(const str: string): TSWFActionByteCode; overload;
    function ByteCode(const AB: array of byte): TSWFActionByteCode; overload;
    function ByteCode(Data: Pointer; Size: longint): TSWFActionByteCode; overload;
    procedure Call;
    procedure CallFunction;
    procedure CallMethod;
    procedure CastOp;
    procedure CharToAscii;
    procedure CloneSprite;
{$IFDEF ASCompiler}
    function Compile(src: TStrings): boolean; overload;
    function Compile(src: TStream): boolean; overload;
    function Compile(src: ansistring): boolean; overload;
    function Compile(FileName: string; unicode: boolean): boolean; overload;
{$ENDIF}
    function ConstantPool(Consts: array of string): TSWFActionConstantPool; overload;
    function ConstantPool(Consts: TStrings): TSWFActionConstantPool; overload;
    procedure Decrement;
    function DefineFunction(Name: string; Params: array of string): TSWFActionDefineFunction; overload;
    function DefineFunction(Name: string; Params: TStrings): TSWFActionDefineFunction; overload;
    function DefineFunction2(Name: string; Params: array of string; RegistersAllocate: byte): TSWFActionDefineFunction2; overload;
    function DefineFunction2(Name: string; Params: TStrings; RegistersAllocate: byte): TSWFActionDefineFunction2; overload;
    procedure DefineLocal;
    procedure DefineLocal2;
    procedure Delete;
    procedure Delete2;
    procedure Divide;
    procedure EndDrag;
    procedure Enumerate;
    procedure Enumerate2;
    procedure Equals;
    procedure Equals2;
    procedure Extends;
    procedure FSCommand(command, param: string);
    procedure FSCommand2(Args: TStrings); overload;  // for Flash Lite
    procedure FSCommand2(Args: string); overload;
    procedure FSCommand2(const Args: array of Variant); overload;
    procedure GetMember;
    procedure GetProperty; overload;
    procedure GetProperty(targ: string; id: byte); overload;
    procedure GetTime;
    procedure GetUrl(const Url, Target: string);
    procedure GetUrl2(TargetFlag, VariablesFlag: boolean; SendMethod: byte);
    procedure GetVariable; overload;
    procedure GetVariable(VarName: string); overload;
    procedure GotoAndPlay(_Label: string); overload;
    procedure GotoAndPlay(Frame: Word); overload;
    procedure GotoAndStop(_Label: string); overload;
    procedure GotoAndStop(Frame: Word); overload;
    procedure GotoFrame(N: word);
    procedure GotoFrame2(Play: boolean; SceneBias: word = 0);
    procedure GoToLabel(FrameLabel: string);
    procedure Greater;
    procedure ImplementsOp;
    procedure Increment;
    procedure InitArray;
    procedure InitObject;
    procedure InstanceOf;
    function Jump: TSWFActionJump;
    procedure Less;
    procedure Less2;
    function LoadMovie(URL, Target: string; IsBrowserTarget: boolean = false; Method: byte = svmNone): TSWFActionGetUrl2;
    function LoadMovieNum(URL: string; Level: word; Method: byte = svmNone): TSWFActionGetUrl2;
    function LoadVariables(URL, Target: string; Method: byte = svmNone): TSWFActionGetUrl2;
    function LoadVariablesNum(URL: string; Level: word; Method: byte = svmNone): TSWFActionGetUrl2;
    procedure MBAsciiToChar;
    procedure MBCharToAscii;
    procedure MBStringExtract;
    procedure MBStringLength;
    function MinVersion: Byte; override;
    procedure Modulo;
    procedure Multiply;
    procedure NewMethod;
    procedure NewObject;
    procedure NextFrame;
    procedure Operation(op: string);
    procedure Play;
    procedure Pop;
    procedure PreviousFrame;
    function Push(const Args: array of Variant): TSWFActionPush; overload;
    function Push(const Args: array of Variant; const Types: array of TSWFValueType): TSWFActionPush; overload;
    function Push(Value: Variant): TSWFActionPush; overload;
    procedure PushConstant(Value: word); overload;
    procedure PushConstant(const Args: array of word); overload;
    procedure PushDuplicate;
    procedure PushRegister(const Args: array of Word); overload;
    procedure PushRegister(Value: Word); overload;
    procedure Random; overload;
    procedure Random(max: dword); overload;
    procedure Random(min, max: dword); overload;
    procedure RandomNumber;
    procedure RemoveSprite;
    procedure Return;
    procedure SetArray(const name: string; const Args: array of Variant; inSprite: boolean = false);
    function SetMarker(M: TSWFOffsetMarker = nil; ToBack: boolean = false): TSWFOffsetMarker;
    procedure SetMember;
    procedure SetProperty; overload;
    procedure SetProperty(targ: string; id: byte); overload;
    procedure SetTarget(TargetName: string);
    procedure SetTarget2;
    procedure SetVar(VarName: string; Value: Variant; inSprite: boolean = false);
    procedure SetVariable;
    procedure StackSwap;
    procedure StartDrag;
    procedure Stop;
    procedure StopSounds;
    procedure StoreRegister(Num: byte);
    procedure StrictEquals;
    procedure StringAdd;
    procedure StringEquals;
    procedure StringExtract;
    procedure StringGreater;
    procedure StringLength;
    procedure StringLess;
    procedure Subtract;
    procedure TargetPath;
    procedure Throw;
    procedure ToggleQuality;
    procedure ToInteger;
    procedure ToNumber;
    procedure ToString;
    procedure Trace;
    procedure TypeOf;
    procedure WaitForFrame(Frame: Word; SkipCount: Byte);
    procedure WaitForFrame2;
    procedure WriteToStream(be: TBitsEngine); override;
    procedure _And;
    function _If: TSWFActionIf;
    procedure _Not;
    procedure _Or;
    function _Try: TSWFActionTry;
    function _With: TSWFActionWith;
    property Action[index: integer]: TSWFAction read GetAction;
    property ActionList: TSWFActionList read FActionList;
    property SelfDestroy: Boolean read FSelfDestroy write FSelfDestroy;
  end;

  TFlashVisualObject = class (TFlashIDObject)
  private
    FIgnoreMovieSettings: Boolean;
    function GetMultCoord: Byte;
  protected
    fXCenter: LongInt;
    fYCenter: LongInt;
  public
    procedure Assign(Source: TBasedSWFObject); override;
    property IgnoreMovieSettings: Boolean read FIgnoreMovieSettings write FIgnoreMovieSettings;
    property MultCoord: Byte read GetMultCoord;
  end;
  

// =================  Shapes ==================================

  TFlashEdges = class (TObject)
  private
    FCurrentPos: TPoint;
    FIgnoreMovieSettings: Boolean;
    FLastStart: TPoint;
    ListEdges: TObjectList;
    Owner: TFlashMovie;
    FOptimizeMode: boolean;
    function FindLastChangeStyle: TSWFStyleChangeRecord;
    function GetMultCoord: Byte;
    function hasAddMoveTo(DX, DY: integer): boolean;
  public
    constructor Create(List: TObjectList);
    destructor Destroy; override;
    function AddChangeStyle: TSWFStyleChangeRecord;
    procedure CloseAllConturs;
    procedure CloseShape;
    procedure CopyFrom(Source: TFlashEdges);
    function CurveDelta(ControlX, ControlY, AnchorX, AnchorY: longint): TSWFCurvedEdgeRecord;
    function CurveTo(ControlX, ControlY, AnchorX, AnchorY: longint): TSWFCurvedEdgeRecord;
    function EndEdges: TSWFEndShapeRecord;
    function GetBoundsRect: TRect;
    function isClockWise: boolean;
    function LineDelta(DX, DY: longint): TSWFStraightEdgeRecord;
    function LineTo(X, Y: longint): TSWFStraightEdgeRecord; overload;
    function LineTo(P: TPoint): TSWFStraightEdgeRecord; overload;
    procedure MakeArc(XC, YC: longInt; RadiusX, RadiusY: longint; StartAngle, EndAngle: single; closed: boolean = true; clockwise: boolean = true); overload;
    procedure MakeArc(XC, YC: longInt; Radius: longint; StartAngle, EndAngle: single; closed: boolean = true); overload;
    procedure MakeCubicBezier(P1, P2, P3: TPoint; parts: byte = 4);
    procedure MakeDiamond(W, H: longint);
    procedure MakeEllipse(W, H: longint);
    procedure MakeMirror(Horz, Vert: boolean);
    procedure MakePie(Radius: longint; StartAngle, EndAngle: single); overload;
    procedure MakePie(RadiusX, RadiusY: longint; StartAngle, EndAngle: single; clockwise: boolean = true); overload;
    procedure MakePolyBezier(AP: array of TPoint; Start: TPoint);
    procedure MakePolyline(AP: array of TPoint);
    procedure MakeRectangle(W, H: longint);
    procedure MakeRoundRect(W, H, R: longint); overload;
    procedure MakeRoundRect(W, H, RX, RY: longint); overload;
    procedure MakeStar(X, Y, R1, R2: longint; NumPoint: word; curve: boolean = false);
    function MoveDelta(X, Y: longint): TSWFStyleChangeRecord;
    function MoveTo(X, Y: longint): TSWFStyleChangeRecord;
    procedure OffsetEdges(DX, DY: LongInt; UseSysCoord: boolean = true);
    function StartNewStyle: TSWFStyleChangeRecord; overload;
    function StartNewStyle(MoveToX, MoveToY: longint): TSWFStyleChangeRecord; overload;
    property CurrentPos: TPoint read FCurrentPos;
    property IgnoreMovieSettings: Boolean read FIgnoreMovieSettings write FIgnoreMovieSettings;
    property LastStart: TPoint read FLastStart;
    property MultCoord: Byte read GetMultCoord;
    property OptimizeMode: boolean read FOptimizeMode write FOptimizeMode;
  end;

  TFlashLineStyle = class (TObject)
  private
    Items: TList;
    function GetCount: Byte;
    function GetLen(Index: Integer): Byte;
    procedure SetCount(Value: Byte);
    procedure SetLen(Index: Integer; Value: Byte);
  public
    constructor Create;
    destructor Destroy; override;
    procedure SetStyle(A: array of byte);
    property Count: Byte read GetCount write SetCount;
    property Len[Index: Integer]: Byte read GetLen write SetLen; default;
  end;

  TFlashShape = class (TFlashVisualObject)
  private
    EdgesStore: TObjectList;
    FBounds: TSWFRect;
    FEdges: TFlashEdges;
    FExtLineStyle: TFlashLineStyle;
    FExtLineTransparent: boolean;
    FFillStyleLeft: Word;
    FFillStyleRight: Word;
    FHasExtLineStyle: Boolean;
    FillStyles: TObjectList;
    FLineStyleNum: Word;
    FLineBgColor: TSWFRGBA;
    FStyleChangeMode: TStyleChangeMode;
    hasAlpha: Boolean;
    hasUseAdvancedStyles: boolean;
    LineStyles: TObjectList;
    function FindLastChangeStyle: TSWFStyleChangeRecord;
    function GetCenterX: LongInt;
    function GetCenterY: LongInt;
    function GetExtLineStyle: TFlashLineStyle;
    function  GetLineBgColor: TSWFRGBA;
    function GetHeight(inTwips: boolean = true): LongInt;
    function GetWidth(inTwips: boolean = true): LongInt;
    function GetXMax: Integer;
    function GetXMin: Integer;
    function GetYMax: Integer;
    function GetYMin: Integer;
    procedure SetCenterX(X: LongInt);
    procedure SetCenterY(Y: LongInt);
    procedure SetFillStyleLeft(n: Word);
    procedure SetFillStyleRight(n: Word);
    procedure SetLineStyleNum(n: Word);
    procedure SetXMax(Value: Integer);
    procedure SetXMin(Value: Integer);
    procedure SetYMax(Value: Integer);
    procedure SetYMin(Value: Integer);
  protected
    procedure ChangeOwner; override;
    function GetListEdges: TObjectList;
  public
    constructor Create(owner: TFlashMovie);
    destructor Destroy; override;
    function AddFillStyle(fill: TSWFFillStyle): TSWFFillStyle;
    function AddLineStyle(outline: TSWFLineStyle = nil): TSWFLineStyle;
    function AddChangeStyle: TSWFStyleChangeRecord;
    procedure Assign(Source: TBasedSWFObject); override;
    procedure CalcBounds;
    procedure MakeMirror(Horz, Vert: boolean);
    function MinVersion: Byte; override;
    function SetImageFill(img: TFlashImage; mode: TFillImageMode; ScaleX: single = 1; ScaleY: single = 1):
            TSWFImageFill;
    function SetLinearGradient(Gradient: array of recRGBA; angle: single = 0): TSWFGradientFill; overload;
    function SetLinearGradient(Gradient: array of TSWFGradientRec; angle: single = 0): TSWFGradientFill; overload;
    function SetLinearGradient(C1, C2: recRGBA; angle: single = 0): TSWFGradientFill; overload;
    function SetLineStyle(width: word; c: recRGB): TSWFLineStyle; overload;
    function SetLineStyle(width: word; c: recRGBA): TSWFLineStyle; overload;
    function SetAdvancedLineStyle(width: word; c: recRGBA; CapStyle: byte = 0; JoinStyle: byte = 0): TSWFLineStyle2;
    function SetRadialGradient(Gradient: array of recRGBA; Xc, Yc: byte): TSWFGradientFill; overload;
    function SetRadialGradient(C1, C2: recRGBA; Xc, Yc: byte): TSWFGradientFill; overload;
    function SetFocalGradient(Gradient: array of recRGBA; FocalPoint: single;
               InterpolationMode: TSWFInterpolationMode; SpreadMode: TSWFSpreadMode): TSWFFocalGradientFill; overload;
    function SetFocalGradient(Color1, Color2: recRGBA; FocalPoint: single;
               InterpolationMode: TSWFInterpolationMode; SpreadMode: TSWFSpreadMode): TSWFGradientFill; overload;
    procedure SetShapeBound(XMin, YMin, XMax, YMax: integer);
    function SetSolidColor(r, g, b, a: byte): TSWFColorFill; overload;
    function SetSolidColor(c: recRGB): TSWFColorFill; overload;
    function SetSolidColor(c: recRGBA): TSWFColorFill; overload;
    procedure WriteToStream(be: TBitsEngine); override;
    property Bounds: TSWFRect read FBounds;
    property Edges: TFlashEdges read FEdges;
    property ExtLineStyle: TFlashLineStyle read GetExtLineStyle;
    property ExtLineTransparent: boolean read FExtLineTransparent write FExtLineTransparent;
    property FillStyleLeft: Word read FFillStyleLeft write SetFillStyleLeft;
    property FillStyleNum: Word read FFillStyleRight write SetFillStyleRight;
    property FillStyleRight: Word read FFillStyleRight write SetFillStyleRight;
    property HasExtLineStyle: Boolean read FHasExtLineStyle write FHasExtLineStyle;
    property LineStyleNum: Word read FLineStyleNum write SetLineStyleNum;
    property LineBgColor: TSWFRGBA read GetLineBgColor;
    property StyleChangeMode: TStyleChangeMode read FStyleChangeMode write FStyleChangeMode;
    property XCenter: LongInt read GetCenterX write SetCenterX;
    property XMax: Integer read GetXMax write SetXMax;
    property XMin: Integer read GetXMin write SetXMin;
    property YCenter: LongInt read GetCenterY write SetCenterY;
    property YMax: Integer read GetYMax write SetYMax;
    property YMin: Integer read GetYMin write SetYMin;
  end;

  TFlashMorphShape = class (TFlashVisualObject)
  private
    FEndEdges: TFlashEdges;
    FFillStyleLeft: Word;
    FLineStyleNum: Word;
    fMorphShape: TSWFDefineMorphShape;
    FStartEdges: TFlashEdges;
    ListEdges: TObjectList;
    function EndHeight: LongInt;
    function EndWidth: LongInt;
    function FindLastChangeStyle: TSWFStyleChangeRecord;
    function GetCenterX: LongInt;
    function GetCenterY: LongInt;
    procedure SetCenterX(X: LongInt);
    procedure SetCenterY(Y: LongInt);
    procedure SetFillStyleLeft(n: Word);
    procedure SetLineStyleNum(n: Word);
    function StartHeight: LongInt;
    function StartWidth: LongInt;
  protected
    hasUseAdvancedStyles: boolean;
    procedure ChangeOwner; override;
    procedure SetCharacterId(id: word); override;
  public
    constructor Create(owner: TFlashMovie);
    destructor Destroy; override;
    procedure AddFillStyle(fill: TSWFMorphFillStyle);
    function AddLineStyle(outline: TSWFMorphLineStyle = nil): TSWFMorphLineStyle;
    procedure Assign(Source: TBasedSWFObject); override;
    function MinVersion: Byte; override;
    procedure SetEndBound(XMin, YMin, XMax, YMax: integer);
    function SetImageFill(img: TFlashImage; mode: TFillImageMode; StartScaleX: single = 1; StartScaleY: single = 1;
                          EndScaleX: single = 1; EndScaleY: single = 1): TSWFMorphImageFill;
    function SetLinearGradient(StartGradient, EndGradient: array of recRGBA; StartAngle: single = 0; EndAngle: single = 0):
            TSWFMorphGradientFill; overload;
    function SetLinearGradient(Gradient: array of TSWFMorphGradientRec; StartAngle: single = 0; EndAngle: single = 0):
            TSWFMorphGradientFill; overload;
    function SetLinearGradient(StartC1, StartC2, EndC1, EndC2: recRGBA; StartAngle: single = 0; EndAngle: single = 0):
            TSWFMorphGradientFill; overload;
    function SetLineStyle(StartWidth, EndWidth: word; StartColor, EndColor: recRGBA): TSWFMorphLineStyle;
    function SetAdvancedLineStyle(StartWidth, EndWidth: word; StartColor, EndColor: recRGBA;
                                  StartCapStyle: byte = 0; EndCapStyle: byte = 0;
                                  JoinStyle: byte = 0): TSWFMorphLineStyle2;
    function SetRadialGradient(StartGradient, EndGradient: array of recRGBA; StartXc, StartYc, EndXc, EndYc: byte):
            TSWFMorphGradientFill; overload;
    function SetRadialGradient(StartC1, StartC2, EndC1, EndC2: recRGBA; StartXc, StartYc, EndXc, EndYc: byte):
            TSWFMorphGradientFill; overload;
    function SetSolidColor(StartC, EndC: recRGBA): TSWFMorphColorFill;
    procedure SetStartBound(XMin, YMin, XMax, YMax: integer);
    procedure WriteToStream(be: TBitsEngine); override;
    property EndEdges: TFlashEdges read FEndEdges;
    property FillStyleLeft: Word read FFillStyleLeft write SetFillStyleLeft;
    property FillStyleNum: Word read FFillStyleLeft write SetFillStyleleft;
    property LineStyleNum: Word read FLineStyleNum write SetLineStyleNum;
    property StartEdges: TFlashEdges read FStartEdges;
    property XCenter: LongInt read GetCenterX write SetCenterX;
    property YCenter: LongInt read GetCenterY write SetCenterY;
  end;

  TFlashPlaceObject = class (TFlashObject)
  private
    tmpActionList: TSWFActionList;
    fActions: TFlashActionScript;
    FVisualObject: TFlashVisualObject;
    PlaceObject: TSWFPlaceObject3;
    function GetBevelFilter: TSWFBevelFilter;
    function GetBlurFilter: TSWFBlurFilter;
    function GetCharacterID: Word; virtual;
    function GetClipDepth: Word;
    function GetColorTransform: TSWFColorTransform;
    function GetColorMatrixFilter: TSWFColorMatrixFilter;
    function GetConvolutionFilter: TSWFConvolutionFilter;
    function GetDepth: Word;
    function GetGradientBevelFilter: TSWFGradientBevelFilter;
    function GetGradientGlowFilter: TSWFGradientGlowFilter;
    function GetGlowFilter: TSWFGlowFilter;
    function GetMatrix: TSWFMatrix;
    function GetName: string;
    function GetRatio: Word;
    function GetRemoveDepth: Boolean;
    function GetShadowFilter: TSWFDropShadowFilter;
    function GetTranslateX: LongInt;
    function GetTranslateY: LongInt;
    procedure SetCharacterID(Value: Word);
    procedure SetClipDepth(Value: Word);
    procedure SetDepth(Value: Word);
    procedure SetName(n: string);
    procedure SetRatio(Value: Word);
    procedure SetRemoveDepth(v: Boolean);
    procedure SetTranslateX(Value: LongInt);
    procedure SetTranslateY(Value: LongInt);
    function GetBlendMode: TSWFBlendMode;
    procedure SetBlendMode(const Value: TSWFBlendMode);
    function GetFilterList: TSWFFilterList;
    function GetUseBitmapCaching: Boolean;
    procedure SetUseBitmapCaching(const Value: Boolean);
  public
    constructor Create(owner: TFlashMovie; VObject: TFlashVisualObject; depth: word); virtual;
    destructor Destroy; override;
    procedure Assign(Source: TBasedSWFObject); override;
    function AddActionEvent(FE: TSWFClipEvents): TSWFClipActionRecord;
{$IFDEF ASCompiler}
    function CompileEvent(src: TStrings): boolean; overload;
    function CompileEvent(src: TStream): boolean; overload;
    function CompileEvent(src: string): boolean; overload;
    function CompileEvent(FileName: string; unicode: boolean): boolean; overload;
{$ENDIF}
    function FindActionEvent(FE: TSWFClipEvent; CreateNoExist: boolean = true): TSWFClipActionRecord;
    procedure InitColorTransform(hasADD: boolean; addR, addG, addB, addA: Smallint; hasMULT: boolean; multR, multG, multB,
            multA: Smallint; hasAlpha: boolean);
    function FindFilter(fid: TSWFFilterID): TSWFFilter;
    function MinVersion: Byte; override;
    function OnClick: TFlashActionScript;
    function OnConstruct: TFlashActionScript;
    function OnData: TFlashActionScript;
    function OnDragOut: TFlashActionScript;
    function OnDragOver: TFlashActionScript;
    function OnEnterFrame: TFlashActionScript;
    function OnInitialize: TFlashActionScript;
    function OnKeyDown: TFlashActionScript;
    function OnKeyPress(Key: byte = 0): TFlashActionScript;
    function OnKeyUp: TFlashActionScript;
    function OnLoad: TFlashActionScript;
    function OnMouseDown: TFlashActionScript;
    function OnMouseMove: TFlashActionScript;
    function OnMouseUp: TFlashActionScript;
    function OnPress: TFlashActionScript;
    function OnRelease: TFlashActionScript;
    function OnReleaseOutside: TFlashActionScript;
    function OnRollOut: TFlashActionScript;
    function OnRollOver: TFlashActionScript;
    function OnUnload: TFlashActionScript;
    procedure SetPosition(X, Y: longint);
    procedure SetRotate(angle: single);
    procedure SetScale(ScaleX, ScaleY: single);
    procedure SetSkew(SkewX, SkewY: single);
    procedure SetTranslate(X, Y: longint);
    procedure WriteToStream(be: TBitsEngine); override;
    property AdjustColor: TSWFColorMatrixFilter read GetColorMatrixFilter;
    property Bevel: TSWFBevelFilter read GetBevelFilter;
    property BlendMode: TSWFBlendMode read GetBlendMode write SetBlendMode;
    property Blur: TSWFBlurFilter read GetBlurFilter;
    property CharacterID: Word read GetCharacterID write SetCharacterID;
    property ClipDepth: Word read GetClipDepth write SetClipDepth;
    property ColorTransform: TSWFColorTransform read GetColorTransform;
    property ColorMatrix: TSWFColorMatrixFilter read GetColorMatrixFilter;
    property Convolution: TSWFConvolutionFilter read GetConvolutionFilter;
    property Depth: Word read GetDepth write SetDepth;
    property FilterList: TSWFFilterList read GetFilterList;
    property GradientBevel: TSWFGradientBevelFilter read GetGradientBevelFilter;
    property GradientGlow: TSWFGradientGlowFilter read GetGradientGlowFilter;
    property Glow: TSWFGlowFilter read GetGlowFilter;
    property Matrix: TSWFMatrix read GetMatrix;
    property Name: string read GetName write SetName;
    property Ratio: Word read GetRatio write SetRatio;
    property RemoveDepth: Boolean read GetRemoveDepth write SetRemoveDepth;
    property Shadow: TSWFDropShadowFilter read GetShadowFilter;
    property TranslateX: LongInt read GetTranslateX write SetTranslateX;
    property TranslateY: LongInt read GetTranslateY write SetTranslateY;
    property UseBitmapCaching: Boolean read GetUseBitmapCaching write
        SetUseBitmapCaching;
    property VisualObject: TFlashVisualObject read FVisualObject write FVisualObject;
  end;
  
TFlashPlaceVideo = class;
// =================== TFlashVideo  ========================

  TWriteFrameInfo = record
    Frame: Word;
    ID: Word;
    Depth: Word;
  end;

  TWriteFrame = procedure (be:TBitsEngine; P: TWriteFrameInfo) of object;
  TPlaceFrame = procedure (be:TBitsEngine; P: TWriteFrameInfo; Ob: TFlashPlaceObject) of object;
  TVideoHeader = record
    Signature: array [0..2] of byte;
    Version: Byte;
    TypeFlag: Byte;
    CodecInfo: Byte;
    DataOffset: LongInt;
    XDim: LongInt;
    YDim: LongInt;
    Frames: LongInt;
  end;

  TFlashVideo = class (TFlashVisualObject)
  private
    FFLV: TFLVData;
    FPlaceFrame: TPlaceFrame;
    FWriteFrame: TWriteFrame;
    function GetHeight: Word;
    function GetWidth: Word;
  protected
    procedure WriteFrame(sender: TSWFObject; BE: TBitsEngine);
  public
    constructor Create(owner: TFlashMovie; FileName: string); overload;
    constructor Create(owner: TFlashMovie; Source: TStream); overload;
    destructor Destroy; override;
    procedure Assign(Source: TBasedSWFObject); override;
    function MinVersion: Byte; override;
    procedure WriteToStream(be: TBitsEngine); override;
    property FLV: TFLVData read FFLV;
    property Height: Word read GetHeight;
    property OnPlaceFrame: TPlaceFrame read FPlaceFrame write FPlaceFrame;
    property OnWriteFrame: TWriteFrame read FWriteFrame write FWriteFrame;
    property Width: Word read GetWidth;
  end;

// =============  TFlashSprite  ======================

  TFlashSprite = class (TFlashVisualObject)
  private
    FBackgroundSound: TFlashSound;
    FCurrentFrameNum: Integer;
    FEnableBGSound: Boolean;
    FFrameActions: TFlashActionScript;
    FFrameLabel: string;
    FInitActions: TFlashActionScript;
    FMaxDepth: word;
    FSprite: TSWFDefineSprite;
    FVideoList: TObjectList;
    function GetBackgrondSound: TFlashSound;
    function GetFrameActions: TFlashActionScript;
    function GetFrameCount: Word;
    function GetInitActions: TFlashActionScript;
    function GetObjectList: TObjectList;
    function GetVideoList(Index: Integer): TFlashPlaceVideo;
    function GetVideoListCount: Integer;
    procedure SetCurrentFrameNum(Value: Integer);
    procedure SetFrameCount(Value: Word);
  protected
    CurrentFramePosIndex: LongInt;
    procedure AddFlashObject(Obj: TBasedSWFObject);
    procedure SetCharacterId(id: word); override;
  public
    constructor Create(owner: TFlashMovie); virtual;
    destructor Destroy; override;
    procedure Assign(Source: TBasedSWFObject); override;
    function MinVersion: Byte; override;
    function PlaceMorphShape(MS: TFlashMorphShape; Depth, NumFrame: word): TFlashPlaceObject;
    function PlaceObject(shape: TFlashVisualObject; depth: word): TFlashPlaceObject; overload;
    function PlaceObject(shape, mask: TFlashVisualObject; depth: word): TFlashPlaceObject; overload;
    function PlaceObject(depth: word): TFlashPlaceObject; overload;
    function PlaceVideo(F: TFlashVideo; depth: word): TFlashPlaceVideo;
    procedure RemoveObject(depth: word; shape: TFlashVisualObject = nil);
    procedure ShowFrame(c: word = 1);
    function StartSound(snd: TFlashSound): TSWFStartSound; overload;
    function StartSound(ID: word): TSWFStartSound; overload;
    procedure StoreFrameActions;
    procedure WriteToStream(be: TBitsEngine); override;
    property BackgroundSound: TFlashSound read GetBackgrondSound;
    property CurrentFrameNum: Integer read FCurrentFrameNum write SetCurrentFrameNum;
    property EnableBGSound: Boolean read FEnableBGSound write FEnableBGSound;
    property FrameActions: TFlashActionScript read GetFrameActions;
    property FrameCount: Word read GetFrameCount write SetFrameCount;
    property FrameLabel: string read FFrameLabel write FFrameLabel;
    property InitActions: TFlashActionScript read GetInitActions;
    property ObjectList: TObjectList read GetObjectList;
    property Sprite: TSWFDefineSprite read FSprite;
    property MaxDepth: word read FMaxDepth;
    property VideoList[Index: Integer]: TFlashPlaceVideo read GetVideoList;
    property VideoListCount: Integer read GetVideoListCount;
  end;

 TFlashMovieClip = TFlashSprite;

  TFlashPlaceVideo = class (TFlashPlaceObject)
  private
    FAutoReplay: Boolean;
    FEnableSound: Boolean;
    FPlaceFrame: TPlaceFrame;
    FSpriteParent: TFlashSprite;
    FStartFrame: Word;
    FWriteFrame: TWriteFrame;
    SndBitRate: LongWord;
    SndCount: LongWord;
    SndLatency: Word;
    SndSampleCount: LongWord;
    SndSeekSample: LongWord;
    function GetCharacterID: Word; override;
    function GetVideo: TFlashVideo;
    procedure SetEnableSound(Value: Boolean);
  public
    constructor Create(owner: TFlashMovie; video: TFlashVisualObject; depth: word); override;
    destructor Destroy; override;
    procedure Assign(Source: TBasedSWFObject); override;
    function MinVersion: Byte; override;
    procedure WriteToStream(be: TBitsEngine; Frame:Word);
    property AutoReplay: Boolean read FAutoReplay write FAutoReplay;
    property CharacterID: Word read GetCharacterID;
    property EnableSound: Boolean read FEnableSound write SetEnableSound;
    property OnPlaceFrame: TPlaceFrame read FPlaceFrame write FPlaceFrame;
    property OnWriteFrame: TWriteFrame read FWriteFrame write FWriteFrame;
    property SpriteParent: TFlashSprite read FSpriteParent write FSpriteParent;
    property StartFrame: Word read FStartFrame write FStartFrame;
    property Video: TFlashVideo read GetVideo;
  end;

// =================  Text =========================
  TFlashChar = class (TObject)
  private
    FCode: Word;
    FEdges: TFlashEdges;
    FGlyphAdvance: Integer;
    FIsUsed: boolean;
    FKerning: TSWFKerningRecord;
    FListEdges: TObjectList;
    FShapeInit: Boolean;
    FWide: Boolean;
    FWideCode: Word;
    function GetIsWide: Boolean;
    procedure SetCode(W: Word);
  public
    constructor Create(code: word; wide: boolean);
    destructor Destroy; override;
    procedure Assign(Source: TObject);
    property Code: Word read FCode write SetCode;
    property Edges: TFlashEdges read FEdges;
    property GlyphAdvance: Integer read FGlyphAdvance write FGlyphAdvance;
    property IsUsed: boolean read FIsUsed write FIsUsed;
    property isWide: Boolean read FWide;
    property Kerning: TSWFKerningRecord read FKerning write FKerning;
    property ListEdges: TObjectList read FListEdges;
    property ShapeInit: Boolean read FShapeInit write FShapeInit;
    property WideCode: Word read FWideCode;
  end;

  TFontUsing = set of (fuStaticText, fuDynamicText);

  TFlashFont = class (TFlashIDObject)
  private
    FAscent: Word;
    FAsDevice: Boolean;
    FBold: Boolean;
    FCharList: TObjectList;
    FDescent: Word;
    FEncodingType: Byte;
    FFontCharset: Byte;
    FFontInfo: TLogFont;
    FHasLayout: Boolean;
    FIncludeKerning: Boolean;
    FItalic: Boolean;
    FLanguageCode: Byte;
    FLeading: Word;
    FName: string;
    FSize: Word;
    FSmallText: Boolean;
    FUsing: TFontUsing;
    FWideCodes: Boolean;
    function GetAntiAlias: Boolean;
    function GetCharInfo(Code: Integer): TFlashChar;
    function GetCharInfoInd(Index: Integer): TFlashChar;
    function GetCharList: TObjectList;
    function GetSize: word;
    function GetWideCodes: Boolean;
    procedure SetAntiAlias(Value: Boolean);
    procedure SetFontCharset(Value: Byte);
    procedure SetFontInfo(Info: TLogFont);
    procedure SetHasLayout(v: Boolean);
    procedure SetSize(value: word);
  public
    constructor Create(owner: TFlashMovie); overload;
    constructor Create(owner: TFlashMovie; asDevice: boolean; Name: string; bold, italic: boolean; size: word); overload;
    destructor Destroy; override;
    procedure AddChars(s: ansistring); overload;
    procedure AddChars(chset: TCharSets); overload;
{$IFNDEF VER130}
    procedure AddChars(s: WideString); overload;
{$ENDIF}
    procedure AddChars(min, max: word); overload;
    procedure AddCharsW(s: WideString);
    function AddEmpty(Ch: word): Boolean;
    procedure Assign(Source: TBasedSWFObject); override;
    function CalcMetric(V: longint): LongInt;
    procedure FillCharsInfo;
    function GetTextExtentPoint(s: string): TSize; overload;
{$IFNDEF VER130}
    function GetTextExtentPoint(s: WideString): TSize; overload;
{$ENDIF}
    function GetTextExtentPointW(s: WideString): TSize;
    procedure LoadFromSWFObject(Src: TSWFDefineFont2);
    procedure LoadFromSWFFile(FileName: string);
    procedure LoadFromSWFStream(src: TStream);
    function MinVersion: Byte; override;
    procedure WriteToStream(be: TBitsEngine); override;
    property AntiAlias: Boolean read GetAntiAlias write SetAntiAlias;
    property Ascent: Word read FAscent write FAscent;
    property AsDevice: Boolean read FAsDevice write FAsDevice;
    property Bold: Boolean read FBold write FBold;
    property CharInfo[Code: Integer]: TFlashChar read GetCharInfo;
    property CharInfoInd[Index: Integer]: TFlashChar read GetCharInfoInd;
    property CharList: TObjectList read GetCharList;
    property Descent: Word read FDescent write FDescent;
    property EncodingType: Byte read FEncodingType write FEncodingType;
    property FontCharset: Byte read FFontCharset write SetFontCharset;
    property FontInfo: TLogFont read FFontInfo write SetFontInfo;
    property FontUsing: TFontUsing read FUsing write FUsing;
    property IncludeKerning: Boolean read FIncludeKerning write FIncludeKerning;
    property Italic: Boolean read FItalic write FItalic;
    property LanguageCode: Byte read FLanguageCode write FLanguageCode;
    property Layout: Boolean read FHasLayout write SetHasLayout;
    property Leading: Word read FLeading write FLeading;
    property Name: string read FName write FName;
    property Size: Word read GetSize write SetSize;
    property SmallText: Boolean read FSmallText write FSmallText;
    property WideCodes: Boolean read GetWideCodes;
  end;

  TFlashCustomData = class (TFlashObject)
  private
    FData: TMemoryStream;
    FTagID: Integer;
    FWriteHeader: Boolean;
  public
    constructor Create(owner: TFlashMovie; FileName:string = ''); overload;
    constructor Create(owner: TFlashMovie; S: TStream; Size: longint = 0); overload;
    destructor Destroy; override;
    procedure Assign(Source: TBasedSWFObject); override;
    function MinVersion: Byte; override;
    procedure WriteToStream(be: TBitsEngine); override;
    property Data: TMemoryStream read FData;
    property TagID: Integer read FTagID write FTagID;
    property WriteHeader: Boolean read FWriteHeader write FWriteHeader;
  end;
  
// ******************* TFlashText ***********************

  TFlashText = class (TFlashVisualObject)
  private
    FAlign: TSWFTextAlign;
    FAutoSize: Boolean;
    FBorder: Boolean;
    FBounds: TSWFRect;
    FCharSpacing: Integer;
    FColor: TSWFRGBA;
    FDynamicText: Boolean;
    FFont: TFlashFont;
    FHasLayout: Boolean;
    FHTML: Boolean;
    FIndent: Integer;
    FLeading: Integer;
    FLeftMargin: Integer;
    FMatrix: TSWFMatrix;
    FMaxLength: Integer;
    FMultiline: Boolean;
    FNoSelect: Boolean;
    FPassword: Boolean;
    FPtAnchor: TPoint;
    FReadOnly: Boolean;
    FRightMargin: Integer;
    FText: AnsiString;
    FTextHeight: Word;
    FUseOutlines: Boolean;
    FVarName: AnsiString;
    FWideText: WideString;
    FWordWrap: Boolean;
    HasColor: Boolean;
    HasMaxLen: Boolean;
    InitAsPoint: Boolean;
    function GetCharSpacing: Integer;
    function GetColor: TSWFRGBA;
    function GetDynamicText: Boolean;
    function GetIndent: Integer;
    function GetLeading: Integer;
    function GetLeftMargin: Integer;
    function GetMatrix: TSWFMatrix;
    function GetRightMargin: Integer;
    function GetTextHeight: Word;
    procedure InitVar(s: string); overload;
{$IFNDEF VER130}
    procedure InitVar(S: WideString); overload;
{$ENDIF}
    procedure InitVarW(S: WideString);
    procedure SetAlign(Value: TSWFTextAlign);
    procedure SetCharSpacing(Value: Integer);
    procedure SetDynamicText(Value: Boolean);
    procedure SetFont(F: TFlashFont);
    procedure SetHasLayout(Value: Boolean);
    procedure SetHTML(Value: Boolean);
    procedure SetIndent(Value: Integer);
    procedure SetLeading(Value: Integer);
    procedure SetLeftMargin(Value: Integer);
    procedure SetMaxLength(Value: Integer);
    procedure SetRightMargin(Value: Integer);
    procedure SetText(Value: AnsiString);
    procedure SetTextHeight(Value: Word);
    procedure SetUseOutlines(Value: Boolean);
    procedure SetWideText(Value: WideString);
  protected
    procedure SetBounds(R: TRect);
    property HasLayout: Boolean read FHasLayout write SetHasLayout;
  public
    constructor Create(owner: TFlashMovie; s: ansistring); overload;
    constructor Create(owner: TFlashMovie; s: ansistring; c: recRGBA; f: TFlashFont; P: TPoint; Align: byte); overload;
    constructor Create(owner: TFlashMovie; s: ansistring; c: recRGBA; f: TFlashFont; R: TRect); overload;
{$IFNDEF VER130}
    constructor Create(owner: TFlashMovie; s: WideString; c: recRGBA; f: TFlashFont; P: TPoint; Align: byte); overload;
    constructor Create(owner: TFlashMovie; s: WideString; c: recRGBA; f: TFlashFont; R: TRect); overload;
{$ENDIF}
    constructor CreateW(owner: TFlashMovie; s: WideString; c: recRGBA; f: TFlashFont; P: TPoint; Align: byte); overload;
    constructor CreateW(owner: TFlashMovie; s: WideString; c: recRGBA; f: TFlashFont; R: TRect); overload;
    destructor Destroy; override;
    procedure Assign(Source: TBasedSWFObject); override;
    function GetTextExtentPoint: TSize;
    function MinVersion: Byte; override;
    procedure WriteToStream(be: TBitsEngine); override;
    property Align: TSWFTextAlign read FAlign write SetAlign;
    property AutoSize: Boolean read FAutoSize write FAutoSize;
    property Border: Boolean read FBorder write FBorder;
    property Bounds: TSWFRect read FBounds;
    property CharSpacing: Integer read GetCharSpacing write SetCharSpacing;
    property Color: TSWFRGBA read GetColor;
    property DynamicText: Boolean read GetDynamicText write SetDynamicText;
    property Font: TFlashFont read FFont write SetFont;
    property HTML: Boolean read FHTML write SetHTML;
    property Indent: Integer read GetIndent write SetIndent;
    property Leading: Integer read GetLeading write SetLeading;
    property LeftMargin: Integer read GetLeftMargin write SetLeftMargin;
    property Matrix: TSWFMatrix read GetMatrix;
    property MaxLength: Integer read FMaxLength write SetMaxLength;
    property Multiline: Boolean read FMultiline write FMultiline;
    property NoSelect: Boolean read FNoSelect write FNoSelect;
    property Password: Boolean read FPassword write FPassword;
    property ReadOnly: Boolean read FReadOnly write FReadOnly;
    property RightMargin: Integer read GetRightMargin write SetRightMargin;
    property Text: AnsiString read FText write SetText;
    property TextHeight: Word read GetTextHeight write SetTextHeight;
    property UseOutlines: Boolean read FUseOutlines write SetUseOutlines;
    property VarName: AnsiString read FVarName write FVarName;
    property WideText: WideString read FWideText write SetWideText;
    property WordWrap: Boolean read FWordWrap write FWordWrap;
  end;

//==================  TFlashButton =======================

 TFlashButtonEvent = (beRollOver, beRollOut, bePress, beRelease,
                beDragOver, beDragOut, beReleaseOutside, beMenuDragOver, beMenuDragOut);
 TFlashButtonEvents = set of TFlashButtonEvent;

  TFlashButton = class (TFlashVisualObject)
  private
    advMode: Boolean;
    fButton: TSWFBasedButton;
    fButtonSound: TSWFDefineButtonSound;
    fFlashActionList: TFlashActionScript;
    function GetButton: TSWFDefineButton;
    function GetButton2: TSWFDefineButton2;
  protected
    procedure SetCharacterId(v: word); override;
  public
    constructor Create(owner: TFlashMovie; hasmenu: boolean = false; advMode: boolean = true);
    destructor Destroy; override;
    function Actions: TFlashActionScript;
    function AddCondAction(FE: TFlashButtonEvents): TSWFButtonCondAction;
    function AddRecord(Shape: TFlashVisualObject; BS: TSWFButtonStates; depth: word = 1): TSWFButtonRecord; overload;
    function AddRecord(Sprite: TFlashSprite; BS: TSWFButtonStates; depth: word = 1): TSWFButtonRecord; overload;
    function AddRecord(ID: Word; BS: TSWFButtonStates; depth: word = 1): TSWFButtonRecord; overload;
    procedure Assign(Source: TBasedSWFObject); override;
{$IFDEF ASCompiler}
    function CompileEvent(src: TStrings): boolean; overload;
    function CompileEvent(src: TStream): boolean; overload;
    function CompileEvent(src: string): boolean; overload;
    function CompileEvent(FileName: string; unicode: boolean): boolean; overload;
{$ENDIF}
    function FindActionEvent(FE: TFlashButtonEvent; CreateNoExist: boolean = true): TSWFActionList;
    function MinVersion: Byte; override;
    function OnClickActions: TFlashActionScript;
    function OnDragOutActions: TFlashActionScript;
    function OnDragOverActions: TFlashActionScript;
    function OnMenuDragOutActions: TFlashActionScript;
    function OnMenuDragOverActions: TFlashActionScript;
    function OnPressActions: TFlashActionScript;
    function OnReleaseActions: TFlashActionScript;
    function OnReleaseOutsideActions: TFlashActionScript;
    function OnRollOutActions: TFlashActionScript;
    function OnRollOverActions: TFlashActionScript;
    function SndPress: TSWFStartSound;
    function SndRelease: TSWFStartSound;
    function SndRollOut: TSWFStartSound;
    function SndRollOver: TSWFStartSound;
    procedure WriteToStream(be: TBitsEngine); override;
  end;

  TFlashCanvas = class;

  TSpriteManagerType = (csDefault, csMetaFile, csClipp, csWorldTransform, csPath, csText, csDC);
  TGDIDrawMode = (dmNormal, dmPath);

// ---------------- TMetaFont ----------------------
//  TMetaFont = class (TObject)
//  protected
//    FFlashFont: TFlashFont;
//    FFMFont: TFont;
//    FFontPresent: Boolean;
//    FInfo: TExtLogFontW;
//    FMColor: recRGBA;
//    FTextMetric: TTextMetricW;
//  public
//    procedure GetMetrixFont;
//    procedure ReadFontParam(Ft: TLogFontW);
//    procedure WriteFontParam(Ft: TFlashFont);
//    property FlashFont: TFlashFont read FFlashFont write FFlashFont;
//    property FMFont: TFont read FFMFont write FFMFont;
//    property FontPresent: Boolean write FFontPresent;
//    property Info: TExtLogFontW read FInfo write FInfo;
//  end;
// ================  Flash CANVAS  ===================

  TFSpriteCanvas = class (TFlashSprite)
  private
    FType: TSpriteManagerType;
    FParent: TFSpriteCanvas;
    FXForm: XForm;
    PlaceParam: TFlashPlaceObject;
  public
    constructor Create(owner: TFlashMovie); override;
    property Parent: TFSpriteCanvas read FParent write FParent;
  end;

  TRenderOptions = set of (roUseBuffer, roHiQualityBuffer, roOptimization);

  TFlashCanvas = class(TCanvas)
  private
    BeginPath: TPoint;
    BgColor: COLORREF;
   // BkColor,
    TextColor: COLORREF;
    FTextMetricSize: integer;
    FTextMetric: POutlineTextmetricW;
    FontScale: single;
    LogFontInfo: TLogFont;
    PrevFont: TFlashFont;

    ClockWs: Boolean;
//    CurDepth: Word;
    CurrentRec: DWord;
    PreviusBrush,
    CurrentBrush: longint;
    CurrentFont: longint;
    CurrentPen: longint;// TCurrentPen;
    CurShape: Word;
    FCWorldTransform: TXForm;
    HasWorldTransform: boolean;
    DPI: Word;
    isEMFPlus: boolean;

    FEmbeddedFont: Boolean;
  //  FMetaFont: TMetaFont;
    FOwner: TFlashMovie;
    FTextJustification: TPoint;
    HTables: TObjectList;
//    LastBgColor: COLORREF;
//    LastBrStyle: Cardinal;
    LastCommand: Cardinal;
    LastMoveToXY: TPoint;
//    MainSprite: TFlashSprite;
//    MetaEnableFlag: Byte;
    MetaHandle: THandle;
    
    PolyFillMode: byte;
    PrivateTransform: TXForm;
    SetIgnoreMovieSettingsFlag: Boolean;

    ShapeLineTo, Sh: TFlashShape;

    FRootSprite: TFlashSprite;
    FActiveSprite: TFSpriteCanvas;

    MetafileSprite: TFSpriteCanvas;
    MustCreateWorldTransform: boolean;

    pathConturCount: integer;
    pathShape: TFlashShape;
    IsUsesPathShape: boolean;

    ClippSprite: TFSpriteCanvas;
    ClipperSprite: TFlashSprite;
    ClippedSprite: TFSpriteCanvas;
//    ClipperShape: TFlashShape;


    TextAlign: DWord;
//    TextBKMode: Cardinal;
    BgTransparent: boolean;
    RootScaleX, RootScaleY: Double;
    ViewportExt: TRect;
    WindowExt: TRect;
    hasInitViewportOrg,
    hasInitViewport: boolean;
    hasInitWindowOrg,
    hasInitWindow: boolean;
    MapMode: integer;
   // GlobalOffset: TPoint;
    BufferBMP: TBMPReader;
    LastEMFR: PEnhMetaRecord;
    DrawMode: TGDIDrawMode;
    MetafileRect: TRect;

    FRenderOptions: TRenderOptions;

    UseBMPRender: boolean;
    StretchedBMPRender: boolean;
    EnableTransparentFill: boolean;

    ListMFRecords: TObjectList;

    function GetActiveSprite: TFSpriteCanvas;
    function AddActiveSprite(ftype: TSpriteManagerType): TFSpriteCanvas;
    procedure CloseActiveSprite;
    function GetPathShape: TFlashShape;
  protected
    procedure MakeTextOut(WText: WideString; Point0: TPoint; Bounds, ClippRect:
        TRect; TextWidth: Integer; fOptions: word; PAWidth: Pointer; WCount:
        integer; iGraphicsMode: DWord);
    function PlaceROP(BMP: TBMPReader; Bounds: TRect; ROP: DWord; Color: Cardinal): TFlashPlaceObject;
    function GetFlashROP(ROP: DWord): TSWFBlendMode;

    function GetCopyFromRender(R: TRect): TBMPReader;
    function GetImageFromRender(R: TRect): TFlashImage;

    procedure DoHEADER(EMFR: PEnhMetaHeader);
    procedure DoPOLYBEZIER(EMFR: PEMRPOLYBEZIER);
    procedure DoPOLYGON(EMFR: PEMRPOLYGON);
    procedure DoPOLYLINE(EMFR: PEMRPOLYLINE);
    procedure DoPOLYBEZIERTO(EMFR: PEMRPOLYBEZIERTO);
    procedure DoPOLYLINETO(EMFR: PEMRPOLYLINETO);
    procedure DoPOLYPOLYLINE(EMFR: PEMRPOLYPOLYLINE);
    procedure DoPOLYPOLYGON(EMFR: PEMRPOLYPOLYGON);
    procedure DoSETWINDOWEXTEX(EMFR: PEMRSETWINDOWEXTEX);
    procedure DoSETWINDOWORGEX(EMFR: PEMRSETWINDOWORGEX);
    procedure DoSETVIEWPORTEXTEX(EMFR: PEMRSETVIEWPORTEXTEX);
    procedure DoSETVIEWPORTORGEX(EMFR: PEMRSETVIEWPORTORGEX);
    procedure DoSETBRUSHORGEX(EMFR: PEMRSETBRUSHORGEX);
    procedure DoEOF(EMFR: PEMREOF);
    procedure DoSETPIXELV(EMFR: PEMRSETPIXELV);
    procedure DoSETMAPPERFLAGS(EMFR: PEMRSETMAPPERFLAGS);
    procedure DoSETMAPMODE(EMFR: PEMRSETMAPMODE);
    procedure DoSETBKMODE(EMFR: PEMRSETBKMODE);
    procedure DoSETPOLYFILLMODE(EMFR: PEMRSETPOLYFILLMODE);
    procedure DoSETROP2(EMFR: PEMRSETROP2);
    procedure DoSETSTRETCHBLTMODE(EMFR: PEMRSETSTRETCHBLTMODE);
    procedure DoSETTEXTALIGN(EMFR: PEMRSETTEXTALIGN);
    procedure DoSETCOLORADJUSTMENT(EMFR: PEMRSETCOLORADJUSTMENT);
    procedure DoSETTEXTCOLOR(EMFR: PEMRSETTEXTCOLOR);
    procedure DoSETBKCOLOR(EMFR: PEMRSETBKCOLOR);
    procedure DoOFFSETCLIPRGN(EMFR: PEMROFFSETCLIPRGN);
    procedure DoMOVETOEX(EMFR: PEMRMOVETOEX);
    procedure DoSETMETARGN(EMFR: PEMRSETMETARGN);
    procedure DoEXCLUDECLIPRECT(EMFR: PEMREXCLUDECLIPRECT);
    procedure DoINTERSECTCLIPRECT(EMFR: PEMRINTERSECTCLIPRECT);
    procedure DoSCALEVIEWPORTEXTEX(EMFR: PEMRSCALEVIEWPORTEXTEX);
    procedure DoSCALEWINDOWEXTEX(EMFR: PEMRSCALEWINDOWEXTEX);
    procedure DoSAVEDC(EMFR: PEMRSAVEDC);
    procedure DoRESTOREDC(EMFR: PEMRRESTOREDC);
    procedure DoSETWORLDTRANSFORM(EMFR: PEMRSETWORLDTRANSFORM);
    procedure DoMODIFYWORLDTRANSFORM(EMFR: PEMRMODIFYWORLDTRANSFORM);
    procedure DoSELECTOBJECT(EMFR: PEMRSELECTOBJECT);
    procedure DoCREATEPEN(EMFR: PEMRCREATEPEN);
    procedure DoCREATEBRUSHINDIRECT(EMFR: PEMRCREATEBRUSHINDIRECT);
    procedure DoDELETEOBJECT(EMFR: PEMRDELETEOBJECT);
    procedure DoANGLEARC(EMFR: PEMRANGLEARC);
    procedure DoELLIPSE(EMFR: PEMRELLIPSE);
    procedure DoRECTANGLE(EMFR: PEMRRECTANGLE);
    procedure DoROUNDRECT(EMFR: PEMRROUNDRECT);
    procedure DoARC(EMFR: PEMRARC);
    procedure DoCHORD(EMFR: PEMRCHORD);
    procedure DoPIE(EMFR: PEMRPIE);
    procedure DoSELECTPALETTE(EMFR: PEMRSELECTPALETTE);
    procedure DoCREATEPALETTE(EMFR: PEMRCREATEPALETTE);
    procedure DoSETPALETTEENTRIES(EMFR: PEMRSETPALETTEENTRIES);
    procedure DoRESIZEPALETTE(EMFR: PEMRRESIZEPALETTE);
    procedure DoREALIZEPALETTE(EMFR: PEMRREALIZEPALETTE);
    procedure DoEXTFLOODFILL(EMFR: PEMREXTFLOODFILL);
    procedure DoLINETO(EMFR: PEMRLINETO);
    procedure DoARCTO(EMFR: PEMRARCTO);
    procedure DoPOLYDRAW(EMFR: PEMRPOLYDRAW);
    procedure DoSETARCDIRECTION(EMFR: PEMRSETARCDIRECTION);
    procedure DoSETMITERLIMIT(EMFR: PEMRSETMITERLIMIT);
    procedure DoBEGINPATH(EMFR: PEMRBEGINPATH);
    procedure DoENDPATH(EMFR: PEMRENDPATH);
    procedure DoCLOSEFIGURE(EMFR: PEMRCLOSEFIGURE);
    procedure DoFILLPATH(EMFR: PEMRFILLPATH);
    procedure DoSTROKEANDFILLPATH(EMFR: PEMRSTROKEANDFILLPATH);
    procedure DoSTROKEPATH(EMFR: PEMRSTROKEPATH);
    procedure DoFLATTENPATH(EMFR: PEMRFLATTENPATH);
    procedure DoWIDENPATH(EMFR: PEMRWIDENPATH);
    procedure DoSELECTCLIPPATH(EMFR: PEMRSELECTCLIPPATH);
    procedure DoABORTPATH(EMFR: PEMRABORTPATH);
    procedure DoGDICOMMENT(EMFR: PEMRGDICOMMENT);
    procedure DoFILLRGN(EMFR: PEMRFILLRGN);
    procedure DoFRAMERGN(EMFR: PEMRFRAMERGN);
    procedure DoINVERTRGN(EMFR: PEMRINVERTRGN);
    procedure DoPAINTRGN(EMFR: PEMRPAINTRGN);
    procedure DoEXTSELECTCLIPRGN(EMFR: PEMREXTSELECTCLIPRGN);
    procedure DoBITBLT(EMFR: PEMRBITBLT);
    procedure DoSTRETCHBLT(EMFR: PEMRSTRETCHBLT);
    procedure DoMASKBLT(EMFR: PEMRMASKBLT);
    procedure DoPLGBLT(EMFR: PEMRPLGBLT);
    procedure DoSETDIBITSTODEVICE(EMFR: PEMRSETDIBITSTODEVICE);
    procedure DoSTRETCHDIBITS(EMFR: PEMRSTRETCHDIBITS);
    procedure DoEXTCREATEFONTINDIRECTW(EMFR: PEMREXTCREATEFONTINDIRECT);
    procedure DoEXTTEXTOUTA(EMFR: PEMREXTTEXTOUT);
    procedure DoEXTTEXTOUTW(EMFR: PEMREXTTEXTOUT);
    procedure DoPOLYBEZIER16(EMFR: PEMRPOLYBEZIER16);
    procedure DoPOLYGON16(EMFR: PEMRPOLYGON16);
    procedure DoPOLYLINE16(EMFR: PEMRPOLYLINE16);
    procedure DoPOLYBEZIERTO16(EMFR: PEMRPOLYBEZIERTO16);
    procedure DoPOLYLINETO16(EMFR: PEMRPOLYLINETO16);
    procedure DoPOLYPOLYLINE16(EMFR: PEMRPOLYPOLYLINE16);
    procedure DoPOLYPOLYGON16(EMFR: PEMRPOLYPOLYGON16);
    procedure DoPOLYDRAW16(EMFR: PEMRPOLYDRAW16);
    procedure DoCREATEMONOBRUSH(EMFR: PEMRCREATEMONOBRUSH);
    procedure DoCREATEDIBPATTERNBRUSHPT(EMFR: PEMRCREATEDIBPATTERNBRUSHPT);
    procedure DoEXTCREATEPEN(EMFR: PEMREXTCREATEPEN);
    procedure DoPOLYTEXTOUTA(EMFR: PEMRPOLYTEXTOUT);
    procedure DoPOLYTEXTOUTW(EMFR: PEMRPOLYTEXTOUT);
    procedure DoSETICMMODE(EMFR: PEMRSETICMMODE);
    procedure DoCREATECOLORSPACE(EMFR: PEMRSelectColorSpace);
    procedure DoSETCOLORSPACE(EMFR: PEMRSelectColorSpace);
    procedure DoDELETECOLORSPACE(EMFR: PEMRDELETECOLORSPACE);
    procedure DoGLSRECORD(EMFR: PEMRGLSRECORD);
    procedure DoGLSBOUNDEDRECORD(EMFR: PEMRGLSBOUNDEDRECORD);
    procedure DoPIXELFORMAT(EMFR: PEMRPIXELFORMAT);
    procedure DoDRAWESCAPE(EMFR: PEnhMetaRecord);
    procedure DoEXTESCAPE(EMFR: PEnhMetaRecord);
    procedure DoSTARTDOC(EMFR: PEnhMetaRecord);
    procedure DoSMALLTEXTOUT(EMFR: PEnhMetaRecord);
    procedure DoFORCEUFIMAPPING(EMFR: PEnhMetaRecord);
    procedure DoNAMEDESCAPE(EMFR: PEnhMetaRecord);
    procedure DoCOLORCORRECTPALETTE(EMFR: PEnhMetaRecord);
    procedure DoSETICMPROFILEA(EMFR: PEnhMetaRecord);
    procedure DoSETICMPROFILEW(EMFR: PEnhMetaRecord);
    procedure DoALPHABLEND(EMFR: PEMRALPHABLEND);
    procedure DoALPHADIBBLEND(EMFR: PEnhMetaRecord);
    procedure DoTRANSPARENTBLT(EMFR: PEMRTRANSPARENTBLT);
    procedure DoTRANSPARENTDIB(EMFR: PEnhMetaRecord);
    procedure DoGRADIENTFILL(EMFR: PEnhMetaRecord);
    procedure DoSETLINKEDUFIS(EMFR: PEnhMetaRecord);
    procedure DoSETTEXTJUSTIFICATION(EMFR: PEnhMetaRecord);
    procedure DoCOLORMATCHTOTARGETW(EMFR: PEnhMetaRecord);
    procedure DoCREATECOLORSPACEW(EMFR: PEnhMetaRecord);

    procedure DoEnhRecord(EMFR: PEnhMetaRecord);

    procedure ShapeSetStyle(ShowOutLine, ShowFill: boolean; fsh: TFlashShape = nil);

    procedure CloseHandle;
    procedure InitHandle;
    procedure SetWTransform(xForm: TxForm; Flag: word);
    procedure ReInitViewPort;
    function MapPoint(P: TPoint): TPoint; overload;
    function MapPoint(P: TSmallPoint): TPoint; overload;
    function MapRect(R: TRect): TRect;
    function MapLen(L: integer; Vert: boolean): longint;
    function GetRootSprite: TFlashSprite;
    procedure GetMetrixFont(F: TFont);
    property ActiveSprite: TFSpriteCanvas read GetActiveSprite write FActiveSprite;

    procedure MakeListMFRecords(MetaHandle: THandle; r: TRect);
    procedure ProcessingRecords(MetaHandle: THandle; Width, Height: integer; stretch: boolean);
    function IsEmptyMetafile(MetaHandle: THandle = 0): boolean;
    procedure Finished;
  public
    constructor Create(Owner: TFlashMovie);
    destructor Destroy; override;

    function isNeedBuffer: boolean;

    procedure Clear;
    procedure DrawMetafile(Dest: TRect; MF: TMetafile; stretch: boolean);
    procedure Draw(X, Y: Integer; Graphic: TGraphic);
    procedure StretchDraw(const R: TRect; Graphic: TGraphic);
    function Place(depth: word; clear: boolean = true; dest: TFlashSprite = nil): TFlashPlaceObject;

    property RootSprite: TFlashSprite read GetRootSprite;
    property EmbeddedFont: Boolean read FEmbeddedFont write FEmbeddedFont;
    property Owner: TFlashMovie read FOwner write FOwner;
    property RenderOptions: TRenderOptions read FRenderOptions write FRenderOptions;
  end;

// ================  TFlashObjectList  ===================
  TFlashObjectList = class (TObject)
  private
    ObjectList: TObjectList;
    function GetCount: Word;
  protected
    function FGetFromID(ID: word): TFlashIDObject;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(Obj: TFlashIDObject);
    property Count: Word read GetCount;
  end;

  TFlashButtonList = class (TFlashObjectList)
  private
    function GetButton(Index: word): TFlashButton;
  public
    function GetFromID(ID: word): TFlashButton;
    function Last: TFlashButton;
    property Button[Index: word]: TFlashButton read GetButton; default;
  end;

  TFlashFontList = class (TFlashObjectList)
  private
    function GetFont(Index: word): TFlashFont;
  public
    function GetFromID(ID: word): TFlashFont;
    function FindByFont(F: TFont; CompareSize: boolean): TFlashFont;
    function Last: TFlashFont;
    property Font[Index: word]: TFlashFont read GetFont; default;
  end;
  
  TFlashImageList = class (TFlashObjectList)
  private
    function GetImage(Index: word): TFlashImage;
  public
    function GetFromID(ID: word): TFlashImage;
    function Last: TFlashImage;
    property Image[Index: word]: TFlashImage read GetImage; default;
  end;

  TFlashMorphShapeList = class (TFlashObjectList)
  private
    function GetShape(Index: word): TFlashMorphShape;
  public
    function GetFromID(ID: word): TFlashMorphShape;
    function Last: TFlashMorphShape;
    property Shape[Index: word]: TFlashMorphShape read GetShape; default;
  end;
  
  TFlashShapeList = class (TFlashObjectList)
  private
    function GetShape(Index: word): TFlashShape;
  public
    function GetFromID(ID: word): TFlashShape;
    function Last: TFlashShape;
    property Shape[Index: word]: TFlashShape read GetShape; default;
  end;
  
  TFlashSoundList = class (TFlashObjectList)
  private
    function GetSound(Index: word): TFlashSound;
  public
    function GetFromID(ID: word): TFlashSound;
    function Last: TFlashSound;
    property Sound[Index: word]: TFlashSound read GetSound; default;
  end;
  
  TFlashSpriteList = class (TFlashObjectList)
  private
    function GetSprite(Index: word): TFlashSprite;
  public
    function GetFromID(ID: word): TFlashSprite;
    function Last: TFlashSprite;
    property Sprite[Index: word]: TFlashSprite read GetSprite; default;
  end;

  TFlashTextList = class (TFlashObjectList)
  private
    function GetText(Index: word): TFlashText;
  public
    function GetFromID(ID: word): TFlashText;
    function Last: TFlashText;
    property Text[Index: word]: TFlashText read GetText; default;
  end;

  TFlashVideoList = class (TFlashObjectList)
  private
    function GetVideo(Index: word): TFlashVideo;
  public
    function GetFromID(ID: word): TFlashVideo;
    function Last: TFlashVideo;
    property Video[Index: word]: TFlashVideo read GetVideo; default;
  end;

  TExternalIncludeMode = (eimRoot, eimResource, eimNoFrameRoot, eimSprite);
  TFlashExternalMovie = class (TFlashIDObject)
  private
    FIncludeMode: TExternalIncludeMode;
    FOnWriteTag: TSWFProcessTagEvent;
    FReader: TSWFStreamReader;
    FSprite: TFlashSprite;
    FRenameFontName: boolean;
  public
    constructor Create(owner: TFlashMovie; src: string); overload;
    constructor Create(owner: TFlashMovie; src: TStream); overload;
    destructor Destroy; override;
    function IDObjectsCount: Word;
    property RenameFontName: boolean read FRenameFontName write FRenameFontName;
    procedure Renumber(start: word);
    procedure WriteToStream(be: TBitsEngine); override;
    property IncludeMode: TExternalIncludeMode read FIncludeMode write FIncludeMode;
    property Reader: TSWFStreamReader read FReader;
    property Sprite: TFlashSprite read FSprite;
    property OnWriteTag: TSWFProcessTagEvent read FOnWriteTag write FOnWriteTag;
  end;

// ================  TFlashMovie  ========================
 TBackgroundMode = (bmNone, bmColor);
 TAddObjectMode = (amEnd, amCurrentFrame, amHomeCurrentFrame, amFromStartFrame);

 TFlashFilterQuality = (fqLow, fqMedium, fqHigh);

 TFlashFilterSettings = class(TObject)
 private
  FAngle: single;
  FBlurX: Integer;
  FBlurY: Integer;
  FBrightness: Integer;
  FContrast: Integer;
  FShadowColor: TSWFRGBA;
  FDistance: Integer;
  FKnockout: Boolean;
  FQuality: TFlashFilterQuality;
  FGlowColor: TSWFRGBA;
  FHideObject: Boolean;
  FHue: Integer;
  FInner: Boolean;
  FOnTop: Boolean;
  FSaturation: Integer;
  FStrength: word;
 public
  constructor Create;
  destructor Destroy; override;
  property Angle: single read FAngle write FAngle;
  property BlurX: Integer read FBlurX write FBlurX;
  property BlurY: Integer read FBlurY write FBlurY;
  property Brightness: Integer read FBrightness write FBrightness;
  property Contrast: Integer read FContrast write FContrast;
  property ShadowColor: TSWFRGBA read FShadowColor write FShadowColor;
  property Distance: Integer read FDistance write FDistance;
  property Knockout: Boolean read FKnockout write FKnockout;
  property Quality: TFlashFilterQuality read FQuality write FQuality;
  property GlowColor: TSWFRGBA read FGlowColor write FGlowColor;
  property HideObject: Boolean read FHideObject write FHideObject;
  property Hue: Integer read FHue write FHue;
  property Inner: Boolean read FInner write FInner;
  property OnTop: Boolean read FOnTop write FOnTop;
  property Saturation: Integer read FSaturation write FSaturation;
  property Strength: word read FStrength write FStrength;
 end;


{$IFDEF ASCompiler}
 TBaseCompileContext = class(TObject)
  private
    FMovie: TFlashMovie;
    function GetListing: TStream;
  public
    constructor Create(owner: TFlashMovie); virtual;

    procedure LoadClassTable(ClassPath: string); virtual; abstract;
    procedure AddIncludePath(IncludePath: string); virtual; abstract;

    procedure CompileAction(
      ASource: TStream;
      ASwfCode: TFlashActionScript); overload; virtual; abstract;

    procedure CompileAction(
      ASource: TStream;
      AFlashButton: TFlashButton); overload; virtual; abstract;

    procedure CompileAction(
      ASource: TStream;
      APlaceObject: TFlashPlaceObject); overload; virtual; abstract;

    property Movie: TFlashMovie read FMovie write FMovie;
    property Listing: TStream read GetListing;
  end;
{$ENDIF}

  TFlashMovie = class (TBasedSWFStream)
  private
    FAddObjectMode: TAddObjectMode;
{$IFDEF ASCompiler}
    FSelfDestroyASLog: boolean;
    FASCompilerLog: TStream;
    FASCompiler: TBaseCompileContext;
    FASCompilerOptions: TCompileOptions;
{$ENDIF}
    FBackgroundColor: TSWFRGB;
    FBackgroundMode: TBackgroundMode;
    FBackgroundSound: TFlashSound;
    FButtons: TFlashButtonList;
    FCanvas: TFlashCanvas;
    FCurrentObjID: Word;
    FCurrentFrameNum: Integer;
    FOnLoadCustomImage: TLoadCustomImageEvent;
    FEnableBgSound: Boolean;
    FFonts: TFlashFontList;
    FFrameActions: TFlashActionScript;
    FFrameLabel: string;
    FGlobalFilterSettings: TFlashFilterSettings;
    FImages: TFlashImageList;
    FMaxDepth: word;
    FMorphShapes: TFlashMorphShapeList;
    FObjectList: TObjectList;
    FPassword: string;
    FProtect: Boolean;
    FShapes: TFlashShapeList;
    FSounds: TFlashSoundList;
    FSprites: TFlashSpriteList;
    FTexts: TFlashTextList;
    FFileAttributes: TSWFFileAttributes; 
    FVideoList: TObjectList;
    FVideos: TFlashVideoList;
    FMetaData: ansistring;
    FUseFileAttributes: boolean;
    FCorrectImageFill: boolean;
    FFix32bitImage: boolean;
    procedure SetCorrectImageFill(const Value: boolean);
    procedure SetUseFileAttributes(const Value: boolean);
    procedure SetMetadata(const Value: ansistring);
    function GetHasMetadata: boolean;
    procedure SetHasMetadata(const Value: boolean);
    function GetUseNetwork: boolean;
    procedure setUseNetwork(const Value: boolean);
{$IFDEF ASCompiler}
    function GetASCompilerLog: TStream;
    function GetASCompiler: TBaseCompileContext;
    procedure SetCompilerOptions(value: TCompileOptions);
{$ENDIF}
    function GetBackgrondSound: TFlashSound;
    function GetBackgroundColor: TSWFRGB;
    function GetButtons: TFlashButtonList;
    function GetCanvas: TFlashCanvas;
    function GetFonts: TFlashFontList;
    function GetFrameActions: TFlashActionScript;
    function GetGlobalFilterSettings: TFlashFilterSettings;
    function GetImages: TFlashImageList;
    function GetMorphShapes: TFlashMorphShapeList;
    function GetObjectList: TObjectList;
    function GetShapes: TFlashShapeList;
    function GetSounds: TFlashSoundList;
    function GetSprites: TFlashSpriteList;
    function GetTexts: TFlashTextList;
    function GetFileAttributes: TSWFFileAttributes;
    function GetVideoListCount: Integer;
    function GetVideos: TFlashVideoList;
    function GetVideoStream(index: LongInt): TFlashPlaceVideo;
    procedure SetAddObjectMode(Value: TAddObjectMode);
    procedure SetCurrentFrameNum(Value: Integer);
    procedure SetObjectList(const Value: TObjectList);
    procedure SetPassword(Value: string);
  protected
    CurrentFramePosIndex: LongInt;
    procedure AddFlashObject(Obj: TBasedSWFObject);
    procedure DoChangeHeader; override;
    procedure ExtMoviePrepare(EM: TFlashExternalMovie; IM: TExternalIncludeMode; autorenum: boolean);
  public
    constructor Create(XMin, YMin, XMax, YMax: integer; fps: single; sc: TSWFSystemCoord = scTwips); override;
    destructor Destroy; override;
    function AddArc(XCenter, YCenter, RadiusX, RadiusY: longint; StartAngle, EndAngle: single; closed: boolean = true):
            TFlashShape; overload;
    function AddArc(XCenter, YCenter, Radius: longint; StartAngle, EndAngle: single; closed: boolean = true): TFlashShape;
            overload;
    function AddButton(hasmenu: boolean = false; advMode: boolean = true): TFlashButton;
    function AddCircle(XCenter, YCenter, Radius: integer): TFlashShape;
    function AddCubicBezier(P0, P1, P2, P3: TPoint): TFlashShape;
    function AddCurve(P1, P2, P3: TPoint): TFlashShape;
    function AddDiamond(XMin, YMin, XMax, YMax: integer): TFlashShape;
    function AddDynamicText(varname, init: ansistring; c: recRGBA; f: TFlashFont; R: TRect): TFlashText; overload;
{$IFNDEF VER130}
    function AddDynamicText(varname: ansistring; init: WideString; c: recRGBA; f: TFlashFont; R: TRect): TFlashText; overload;
{$ENDIF}
    function AddDynamicTextW(varname: ansistring; init: WideString; c: recRGBA; f: TFlashFont; R: TRect): TFlashText;
    function AddEllipse(XMin, YMin, XMax, YMax: integer): TFlashShape; overload;
    function AddEllipse(R: TRect): TFlashShape; overload;
    function AddExternalMovie(src: string; IM: TExternalIncludeMode; autorenum: boolean = true): TFlashExternalMovie;
            overload;
    function AddExternalMovie(src: TStream; IM: TExternalIncludeMode; autorenum: boolean = true): TFlashExternalMovie;
            overload;
    function AddFont: TFlashFont; overload;
    function AddFont(FontInfo: TFont; device: boolean = true): TFlashFont; overload;
    function AddFont(LogFont: TLogFont; device: boolean = true): TFlashFont; overload;
    function AddFont(Name: string; bold, italic: boolean; size: integer; device: boolean = true): TFlashFont; overload;
    procedure AddIDObject(Obj: TFlashIDObject; SetID: boolean = true);
    function AddImage(fn: string = ''): TFlashImage;
    function AddLine(X1, Y1, X2, Y2: longint): TFlashShape;
    function AddMorphShape(shape: TFlashMorphShape = nil): TFlashMorphShape;
    function AddPie(XCenter, YCenter, Radius: longint; StartAngle, EndAngle: single): TFlashShape; overload;
    function AddPie(XCenter, YCenter, RadiusX, RadiusY: longint; StartAngle, EndAngle: single): TFlashShape; overload;
    function AddPolygon(AP: array of TPoint): TFlashShape;
    function AddPolyline(AP: array of TPoint): TFlashShape;
    function AddRectangle(XMin, YMin, XMax, YMax: longint): TFlashShape; overload;
    function AddRectangle(R: TRect): TFlashShape; overload;
    function AddRing(XCenter, YCenter, Radius1, Radius2: integer): TFlashShape;
    function AddRoundRect(XMin, YMin, XMax, YMax, Radius: longint): TFlashShape; overload;
    function AddRoundRect(R: TRect; Radius: longint): TFlashShape; overload;
    function AddShape(shape: TFlashShape = nil): TFlashShape;
    function AddShapeImage(fn: string): TFlashShape; overload;
    function AddShapeImage(img: TFlashImage): TFlashShape; overload;
    function AddSound(fn: string): TFlashSound; overload;
    function AddSound(Src: TMemoryStream; isMP3: boolean): TFlashSound; overload;
    function AddSprite(VO: TFlashVisualObject = nil): TFlashSprite;
    function AddSquare(XMin, YMin, Side: integer): TFlashShape; overload;
    function AddSquare(XMin, YMin, XMax, YMax: integer): TFlashShape; overload;
    function AddStar(X, Y, R1, R2: longint; NumPoint: word; curve: boolean = false): TFlashShape;
    function AddText: TFlashText; overload;
    function AddText(s: ansistring; c: recRGBA; f: TFlashFont; P: TPoint; Align: TSWFTextAlign = taLeft): TFlashText; overload;
    function AddText(s: ansistring; c: recRGBA; f: TFlashFont; R: TRect): TFlashText; overload;
{$IFNDEF VER130}
    function AddText(s: WideString; c: recRGBA; f: TFlashFont; P: TPoint; Align: TSWFTextAlign = taLeft): TFlashText; overload;
    function AddText(s: WideString; c: recRGBA; f: TFlashFont; R: TRect): TFlashText; overload;
{$ENDIF}
    function AddTextW(s: WideString; c: recRGBA; f: TFlashFont; P: TPoint; Align: TSWFTextAlign = taLeft): TFlashText; overload;
    function AddTextW(s: WideString; c: recRGBA; f: TFlashFont; R: TRect): TFlashText; overload;
    function AddVideo(FileName: string): TFlashVideo;
    function AddVideoFromStream(MS: TMemoryStream): TFlashVideo;
    function CalcFramesCount: Word;
    procedure Clear;
    function ExportAssets(name: string; id: word): TSWFExportAssets; overload;
    function ExportAssets(name: string; Sprite: TFlashSprite): TSWFExportAssets; overload;
    function FindObjectFromID(ID: word): TFlashIDObject;
    function FramePos(num: word): longint; override;
    function GetMinVersion: Byte;
    function ImportAssets(filename: string): TSWFImportAssets; overload;
    function ImportAssets(URL, name: string): TSWFImportAssets; overload;
    procedure MakeStream; override;
    procedure MoveResource(ToFrame, StartFrom, EndFrom: integer); override;
    function PlaceObject(shape, mask: TFlashVisualObject; depth: word): TFlashPlaceObject; overload;
    function PlaceObject(shape: TFlashVisualObject; depth: word): TFlashPlaceObject; overload;
    function PlaceObject(depth: word): TFlashPlaceObject; overload;
    function PlaceVideo(F: TFlashVideo; depth: word): TFlashPlaceVideo;
    procedure RemoveObject(depth: word; shape: TFlashVisualObject = nil);
    procedure SetTabIndex(Depth, TabIndex: word);
    procedure ShowFrame(c: word = 1);
    function StartSound(snd: TFlashSound; Loop: word = 1): TSWFStartSound; overload;
    function StartSound(ID: word; Loop: word = 1): TSWFStartSound; overload;
    procedure StoreFrameActions;
    property AddObjectMode: TAddObjectMode read FAddObjectMode write SetAddObjectMode;
{$IFDEF ASCompiler}
    property ASCompiler: TBaseCompileContext read GetASCompiler write FASCompiler;
    property ASCompilerLog: TStream read GetASCompilerLog write FASCompilerLog;
    property ASCompilerOptions: TCompileOptions read FASCompilerOptions write SetCompilerOptions;
{$ENDIF}
    property BackgroundColor: TSWFRGB read GetBackgroundColor;
    property BackgroundMode: TBackgroundMode read FBackgroundMode write FBackgroundMode;
    property BackgroundSound: TFlashSound read GetBackgrondSound;
    property Buttons: TFlashButtonList read GetButtons;
    property Canvas: TFlashCanvas read GetCanvas;
    property CurrentObjID: Word read FCurrentObjID write FCurrentObjID;
    property CurrentFrameNum: Integer read FCurrentFrameNum write SetCurrentFrameNum;
    property CorrectImageFill: boolean read FCorrectImageFill write SetCorrectImageFill;
    property EnableBgSound: Boolean read FEnableBgSound write FEnableBgSound;
    property Fix32bitImage: boolean read FFix32bitImage write FFix32bitImage;
    property Fonts: TFlashFontList read GetFonts;
    property FrameActions: TFlashActionScript read GetFrameActions;
    property FrameLabel: string read FFrameLabel write FFrameLabel;
    property GlobalFilterSettings: TFlashFilterSettings read GetGlobalFilterSettings;
    property HasMetadata: boolean read GetHasMetadata write SetHasMetadata;
    property Images: TFlashImageList read GetImages;
    property MaxDepth: word read FMaxDepth;
    property MetaData: ansistring read FMetaData write SetMetadata; 
    property MorphShapes: TFlashMorphShapeList read GetMorphShapes;
    property ObjectList: TObjectList read GetObjectList write SetObjectList;
    property Password: string read FPassword write SetPassword;
    property Protect: Boolean read FProtect write FProtect;
    property Shapes: TFlashShapeList read GetShapes;
    property Sounds: TFlashSoundList read GetSounds;
    property Sprites: TFlashSpriteList read GetSprites;
    property Texts: TFlashTextList read GetTexts;
    property VideoList[index: LongInt]: TFlashPlaceVideo read GetVideoStream;
    property VideoListCount: Integer read GetVideoListCount;
    property Videos: TFlashVideoList read GetVideos;
    property UseFileAttributes: boolean read FUseFileAttributes write SetUseFileAttributes;
    property UseNetwork: boolean read GetUseNetwork write SetUseNetwork;
    property OnLoadCustomImage: TLoadCustomImageEvent read FOnLoadCustomImage write FOnLoadCustomImage;
  end;

var
  LoadCustomImageProc: TLoadCustomImageProc = nil;
  

 Procedure CreateEmptySWF(fn: string; bg: recRGB);

implementation

Uses math, ZLib,
{$IFNDEF VER130}
  Types,
{$ENDIF}
{$IFDEF ASCompiler}
  ActionCompiler,
{$ENDIF}
  FontReader;

// EMF+ Metafile optimaztion options  
const
  ooTransparentRect = 1;
  ooStartTransparentFill = 2;
  ooEndTransparentFill = 3;

var
  PN1: integer = 1;

{
******************************************************* TFlashObject ********************************************************
}

constructor TFlashObject.Create(owner: TFlashMovie);
begin
  FOwner := owner;
end;

function TFlashObject.LibraryLevel: Byte;
begin
  Result := FlashLevel;
end;

procedure TFlashObject.ChangeOwner;
begin

end;

procedure TFlashObject.SetOwner(Value: TFlashMovie);
begin
  FOwner := Value;
  ChangeOwner;
end;

{
****************************************************** TFlashIDObject *******************************************************
}
procedure TFlashIDObject.Assign(Source: TBasedSWFObject);
begin
  With TFlashIDObject(Source) do
  begin
    if self.owner = nil then self.owner := owner;
    self.CharacterID := CharacterID;
  end;
end;


function TFlashIDObject.GetCharacterId: Word;
begin
  Result := FCharacterID;
end;

procedure TFlashIDObject.SetCharacterId(ID: Word);
begin
  FCharacterID := ID;
end;

{
******************************************************** TFlashSound ********************************************************
}
constructor TFlashSound.Create(owner: TFlashMovie; fn: string = '');
begin
  inherited Create(owner);
  MP3SeekStart := 0;
  FileName := fn;
  SelfDestroy := false;
  if FileExists(fn) then LoadSound(fn);
  WaveCompressBits := 4;
end;

destructor TFlashSound.Destroy;
begin
//  if Assigned(Data) and SelfDestroy then FreeAndNil(Data);
  if Assigned(FWaveReader) then FreeAndNil(FWaveReader);
  inherited;
end;

procedure TFlashSound.Assign(Source: TBasedSWFObject);
begin
  inherited;
  With TFlashSound(Source) do
  begin
//    self.Data := Data;
    self.DataBlockSize := DataBlockSize;
    self.DataLen := DataLen;
    self.DataStart := DataStart;
    self.AutoLoop := AutoLoop;
    self.fBitsPerSample := fBitsPerSample;
    self.Duration := Duration;
    self.MP3Info := MP3Info;
    self.FrameSize := FrameSize;
    self.recomendSampleCount := recomendSampleCount;
    self.SampleCount := SampleCount;
    self.FSamplesPerSec := SamplesPerSec;
    self.sndFormat := sndFormat;
    self.sndRate := sndRate;
    self.StartFrame := StartFrame;
    self.Stereo := Stereo;
    self._16Bit := _16Bit;
    self.isMultWriten := isMultWriten;
    self.MP3SeekStart := MP3SeekStart;
    self.SeekSamples := SeekSamples;
    self.FWaveCompressBits := WaveCompressBits;
  end;
end;

procedure TFlashSound.FillHeader(SH: TSWFSoundStreamHead; fps: single);
begin
   SH.StreamSoundCompression := sndFormat;
   if (sndFormat = snd_PCM) then
     begin
       if (WaveCompressBits > 0)
         then SH.StreamSoundCompression := snd_ADPCM
         else SH.StreamSoundCompression := snd_PCM{_LE};
     end
     else
       SH.StreamSoundCompression := sndFormat;

   SH.StreamSoundRate := sndRate;
   if (sndFormat = snd_PCM) and (WaveCompressBits = 0)
     then SH.StreamSoundSize := _16bit
     else SH.StreamSoundSize := true;
   SH.StreamSoundType := Stereo;
   recomendSampleCount := Trunc(fSamplesPerSec / fps);
    //  isMultWriten := Round(DataLen / (MP3info.FrameCount * MP3info.FrameLength));
  //   if sndFormat = snd_MP3 then
  //     isMultWriten := Round(DataLen / (Duration * MP3info.FrameLength*fSamplesPerSec/MP3Info.FrameSize));
  isMultWriten := 1;

   SH.StreamSoundSampleCount := recomendSampleCount;

   SH.PlaybackSoundRate := SH.StreamSoundRate;
   SH.PlaybackSoundSize := SH.StreamSoundSize;
   SH.PlaybackSoundType := SH.StreamSoundType;

   if sndFormat = snd_MP3 then
        SH.LatencySeek := 0;  // calc first offset

   DataPos := DataStart;
   SamplesWriten := 0;
   FrameWriten := 0;
   SeekSamples := MP3SeekStart;
   WritenCount := 0;
   Case sndFormat of
     snd_PCM, snd_PCM_LE:
          DataBlockSize := Trunc(fSamplesPerSec / fps) * (1 + byte(Stereo)) * (1 + byte(_16Bit)) {-
                           2* byte(Stereo) -  2*byte(_16Bit)};
     snd_ADPCM:
          begin
            DataBlockSize := Trunc(fSamplesPerSec / fps) * (1 + byte(Stereo)) * 2 - 2* byte(Stereo) -  2;
//            ADPCMReader := TWaveReader.Create(FileName);
          end;
   end;
end;

function TFlashSound.GetWaveReader: TWaveReader;
begin
  if FWaveReader = nil then FWaveReader := TWaveReader.Create('');
  Result := FWaveReader;
end;

procedure TFlashSound.ParseWaveInfo;
begin
  Duration := WaveReader.Duration;
  Case WaveReader.WaveHeader.WaveFormat of
   WAVE_FORMAT_PCM: sndFormat := snd_PCM;
   WAVE_FORMAT_ADPCM: sndFormat := snd_ADPCM;
   WAVE_FORMAT_MP3,
   WAVE_FORMAT_MPEG_L3:
     begin
      sndFormat := snd_MP3;
      MP3Info := WaveReader.MP3Info;
     end;
  end;

  fSamplesPerSec := WaveReader.WaveHeader.SamplesPerSec;
  Case WaveReader.WaveHeader.SamplesPerSec div 5000 of
   1: sndRate := Snd5k; // 5k
   2: sndRate := Snd11k;        // 11k
   3: sndRate := Snd22k;
   4: sndRate := Snd22k;        // 22k
   8: sndRate := Snd44k;
  end;

  fBitsPerSample := WaveReader.WaveHeader.BitsPerSample;
  if sndFormat = snd_PCM
    then _16Bit := not (fBitsPerSample = 8)
    else _16Bit := true;
  Stereo := WaveReader.WaveHeader.Channels = 2;

  DataStart := WaveReader.DataInfo.Start;
  DataLen := WaveReader.DataInfo.Len;
  DataBlockSize := DataLen;
  SampleCount := WaveReader.WaveHeader.Samples;
//  if not (sndFormat in [snd_PCM, snd_ADPCM]) then FreeAndNil(FWaveReader);
end;

procedure TFlashSound.LoadSound(fn: string);
begin
  FileName := fn;
  WaveReader := TWaveReader.Create(fn);
  ParseWaveInfo;
end;

procedure TFlashSound.LoadFromMemory(Src: TMemoryStream; isMP3: boolean);
begin
  FileName := '';
  WaveReader := TWaveReader.CreateFromStream(Src, isMP3);
  ParseWaveInfo;
end;

function TFlashSound.MinVersion: Byte;
begin
  Case SndFormat of
   snd_MP3, snd_PCM_LE: Result := SWFVer4;
   snd_Nellymoser: Result := SWFVer6;
   snd_NellymoserMono: Result := SWFVer8;
   else Result := SWFVer1;
  end;
end;


procedure TFlashSound.SetWaveCompressBits(const Value: byte);
begin
  if Value > 5 then FWaveCompressBits := 5 else
    if Value = 1 then FWaveCompressBits := 0 else
      FWaveCompressBits := Value;
end;

procedure TFlashSound.SetWaveReader(const Value: TWaveReader);
begin
  if Assigned(FWaveReader) then FreeAndNil(FWaveReader);
  FWaveReader := Value;
end;

function TFlashSound.StartSound: TSWFStartSound;
begin
  if Owner = nil
    then Result := nil
    else Result := Owner.StartSound(CharacterId);
end;


procedure TFlashSound.WriteSoundBlock(BE: TBitsEngine);
var
  SSB: TSWFSoundStreamBlock;
begin
   case sndFormat of
    snd_PCM, snd_PCM_LE, snd_ADPCM:
      begin
         with WaveReader do
         if (WaveData.Position < (DataInfo.Start + DataInfo.Len)) or AutoLoop then
           begin
             SSB := TSWFSoundStreamBlock.Create;
             SSB.OnDataWrite := WriteSoundData;
             SSB.WriteToStream(BE);
             SSB.Free;
           end;
      end;

    snd_MP3:
      begin
        if Abs(SeekSamples) > MP3Info.SamplesPerFrame then wFrameCount := 0 else
          begin
           wFrameCount := (SeekSamples + recomendSampleCount) div MP3Info.SamplesPerFrame;
           if (WritenCount = 0) and (wFrameCount = 0) then wFrameCount := 1;
          end;
        inc(WritenCount);
        wSampleCount := wFrameCount * MP3Info.SamplesPerFrame;
        if WritenCount = 1 then SeekSamples := MP3SeekStart
          else
          begin
           SeekSamples := (WritenCount - 1) * recomendSampleCount - SamplesWriten;
           if Abs(SeekSamples) > MP3Info.SamplesPerFrame then
             begin
              SampleCount := 0;
              SeekSamples := 0;
              wFrameCount := 0;
             end;
          end;

        if SampleCount = 0 then
          begin
            be.WriteWord(tagSoundStreamBlock shl 6 + $3f);
            Be.WriteDWord(4);
            be.Write4byte(0);
          end else
          begin
            SSB := TSWFSoundStreamBlock.Create;
            SSB.OnDataWrite := WriteSoundData;
            SSB.WriteToStream(BE);
            SSB.Free;
          end;

        inc(SamplesWriten, wSampleCount);
        SeekSamples := WritenCount * recomendSampleCount - SamplesWriten;

      end;
  end;
end;

procedure TFlashSound.WriteSoundData(sender: TSWFObject; BE: TBitsEngine);
begin
  if sender is TSWFSoundStreamBlock then
  begin
    case sndFormat of
      snd_PCM:
        WaveReader.WriteUncompressBlock(BE, DataBlockSize, WaveCompressBits, AutoLoop);

      snd_ADPCM:
        WaveReader.WriteBlock(BE, recomendSampleCount, WaveCompressBits, AutoLoop);

      snd_MP3:
      begin
        be.WriteWord(wSampleCount);
        be.WriteWord(Word(SeekSamples));
        if wFrameCount > 0 then
          FrameWriten := WaveReader.WriteMP3Block(BE, FrameWriten, wFrameCount, AutoLoop);
      end;
    end;

  end else
  begin
    case sndFormat of
      snd_PCM, snd_PCM_LE:
      begin
        WaveReader.WaveData.Position := DataStart;
        WaveReader.WriteUncompressBlock(BE, DataLen, WaveCompressBits, false);
      end;

      snd_ADPCM:
        WaveReader.WriteToStream(Be, WaveCompressBits);
        
      snd_MP3:
      begin
        WaveReader.WaveData.Position := DataStart;
        BE.BitsStream.CopyFrom(WaveReader.WaveData, DataLen);
      end;
    end;
  end;

//  Case sndFormat of
//    snd_PCM, snd_MP3:
//      begin
//        Data.Position := DataStart;
//        BE.BitsStream.CopyFrom(Data, DataLen);
//      end
//  end;
end;

procedure TFlashSound.WriteToStream(be: TBitsEngine);
begin
  With TSWFDefineSound.Create do
    begin
      SoundId := CharacterId;
      if (sndFormat = snd_PCM) and (WaveCompressBits > 0)
        then SoundFormat := snd_ADPCM
        else SoundFormat := sndFormat;
      SoundRate := sndRate;
      if (sndFormat = snd_PCM) and (WaveCompressBits = 0)
        then SoundSize := _16bit
        else SoundSize := true;
      SoundType := Stereo;
      SoundSampleCount := SampleCount;
      SeekSamples := MP3SeekStart;
      onDataWrite := WriteSoundData;
      WriteToStream(be);
      free;
    end;

end;

// =============================================================//
//                           TFlashImage                        //
// =============================================================//

{
******************************************************** TFlashImage ********************************************************
}
constructor TFlashImage.Create(owner: TFlashMovie; fn: string = '');
begin
  inherited Create(owner);
  FConvertProgressiveJpeg := true;
  if fn <> '' then LoadDataFromFile(fn) else FDataState := dsNoInit;
end;

destructor TFlashImage.Destroy;
begin
  if FData <> nil then FData.Free;
  if FBMPStorage <> nil then FBMPStorage.Free;
  if FAlphaData <> nil then FAlphaData.free;
  inherited;
end;

procedure TFlashImage.Assign(Source: TBasedSWFObject);
begin
  inherited;
  With TFlashImage(Source) do
  begin
    self.FColorCount := ColorCount;
    self.FHeight := Height;
    self.FSaveWidth := SaveWidth;
    self.FWidth := Width;
    self.FDataState := DataState;
    self.SWFBMPType := SWFBMPType;
    self.FAsJPEG := AsJPEG;
    self.ConvertProgressiveJPEG := ConvertProgressiveJPEG;
    self.HasUseAlpha := HasUseAlpha;
    case DataState of
     dsMemory, dsMemoryBMP,
     dsMemoryJPEG:
       begin
         Data.Position := 0;
         self.Data.CopyFrom(Data, Data.Size);
       end;
     dsFileJPEG: self.Data := Data;
    end;
    if FBMPStorage <> nil then
       self.BMPStorage.LoadFromHandle(BMPStorage.Handle);
  end;
end;

procedure TFlashImage.CopyToStream(S: TStream);
begin
  if not (DataState = dsNoInit) and (Data.Size > 0) then
   begin
    Data.Position := 0;
    S.CopyFrom(Data, Data.Size);
   end;
end;

function TFlashImage.GetAlphaData: TMemoryStream;
begin
  if (FAlphaData = nil) and AsJPEG
            then FAlphaData := TMemoryStream.Create;
  Result := FAlphaData;
end;

function TFlashImage.GetAlphaPixel(X, Y: Integer): Byte;
var
  P: PByte;
begin
  if AsJPEG then
    begin
      P := AlphaData.Memory;
      inc(P, Y * Width + X);
      Result := P^;
    end else
    if SWFBMPType = BMP_32bitWork then
    begin
      Result := BMPStorage.Pixels32[Y][X].A;
    end else result := $FF;
end;

procedure TFlashImage.GetBMPInfo;
var
  addBytes: Byte;
begin
  FWidth := BMPStorage.Width;
  FHeight := BMPStorage.Height;
  FColorCount := 0;
  case BMPStorage.Bpp of
    1, 4, 8:
        begin
         SWFBMPType := BMP_8bit;
         FColorCount := CountColors(BMPStorage);
         addBytes := 4 - Width mod 4;
         if addBytes = 4 then addBytes := 0;
         FSaveWidth := Width + addBytes;
         FHasUseAlpha := BMPStorage.TransparentIndex > -1;
         if FHasUseAlpha then
           SetAlphaIndex(BMPStorage.TransparentIndex, 0);
        end;
    16: begin
         SWFBMPType := BMP_15bit;
         addBytes := Width mod 2;
         FSaveWidth := Width + addBytes;
        end;
    24: begin
         SWFBMPType := BMP_24bit;
         FSaveWidth := Width;
        end;
    32: begin
         SWFBMPType := BMP_32bitWork;
         FSaveWidth := Width;
         FHasUseAlpha := true;
        end;
  end;
  FDataState := dsMemoryBMP;
end;

function TFlashImage.GetBMPStorage: TBMPReader;
begin
  if not Assigned(FBMPStorage) then FBMPStorage := TBMPReader.Create;
  Result := FBMPStorage;
end;

function TFlashImage.GetData: TStream;
begin
  if not Assigned(fData) then
    begin
     if DataState = dsInitJPEG then
       begin
         FData := TFileStream.Create(FileName, fmOpenRead + fmShareDenyNone);
         FDataState := dsFileJPEG;
       end else
       begin
        fData := TMemoryStream.Create;
        FDataState := dsMemory;
       end;
    end;
  result := fData;
end;

function TFlashImage.GetHeight: Word;
begin
  result := FHeight;
end;

function TFlashImage.GetWidth: Word;
begin
  result := FWidth;
end;

procedure TFlashImage.LoadAlphaDataFromBMPReader(BMP: TBMPReader);
var
  ilx, ily: Integer;
  PB, AB: PByte;
  P32: ^TFColorA; 
begin
  if (BMP.Width = Width) and (BMP.Height = Height) and (BMP.Bpp <= 8) or (BMP.Bpp = 32) then
    begin
     FHasUseAlpha := true;
     if FAlphaData <> nil then FAlphaData.Clear;
     if AsJPEG then
       begin
         AlphaData.SetSize(Width * Height);
         AB := AlphaData.Memory;
         For ily := Height - 1 downto 0 do
          begin
            PB := BMP.Scanlines[ily];
            if BMP.Bpp = 32 then P32 := Pointer(PB);
            For ilx := 0 to Width - 1 do
             begin
              if BMP.Bpp = 32 then
                begin
                  AB^ :=  P32^.A;
                  inc(P32);
                end else
              if BMP.Bpp = 8 then
                begin
                  AB^ := PB^;
                  inc(PB);
                end else
                begin
                  if (ilx and 1) = 0 then
                      AB^ := PLine8(PB)^[ilx shr 1] shr 4
                    else
                      AB^ := PLine8(PB)^[ilx shr 1] and $F;
                end;
                inc(AB)
             end;
          end;
       end else
       if SWFBMPType = BMP_32bitWork then
         begin
           SetAlphaChannel(BMPStorage, BMP);
         end;
    end;
end;

procedure TFlashImage.LoadAlphaDataFromFile(fn: string);
var
  FS: TFileStream;
  ext: string;
begin
  Ext := UpperCase(ExtractFileExt(fn));
  if (Ext<>'') and (Ext[1] = '.') then Delete(Ext, 1, 1);
  if Ext = 'BMP' then
    begin
      FS := TFileStream.Create(fn, fmOpenRead + fmShareDenyWrite);
      LoadAlphaDataFromStream(FS);
      FS.Free;
    end
    else exception.Create('Image format "'+ext+'" for alpha not supported!');
end;

procedure TFlashImage.LoadAlphaDataFromHandle(HBMP: HBitmap);
var
  BMP: TBMPReader;
begin
  BMP := TBMPReader.Create;
  BMP.LoadFromHandle(HBMP);
  LoadAlphaDataFromBMPReader(BMP);
  BMP.Free;
end;

procedure TFlashImage.LoadAlphaDataFromStream(S: TStream);
var
  BMP: TBMPReader;
begin
  BMP := TBMPReader.Create;
  BMP.LoadFromStream(S);
  LoadAlphaDataFromBMPReader(BMP);
  BMP.Free;
end;

procedure TFlashImage.LoadDataFromFile(fn: string);
var
  ext: string;

  {$IFDEF DelphiJPEG}
  JPG: TJPEGImage;
  BMP: TBitmap;
  {$ENDIF}
  DefaultProcess: boolean;
begin
  FFileName := fn;
  DefaultProcess := true;
  if (owner <> nil) and Assigned(owner.FOnLoadCustomImage)
    then owner.FOnLoadCustomImage(self, fn, DefaultProcess);

  if DefaultProcess then
    begin
      Ext := UpperCase(ExtractFileExt(fn));
      if (Ext<>'') and (Ext[1] = '.') then Delete(Ext, 1, 1);

      FAsJPEG := false;
      HasUseAlpha := false;
      if (Ext = 'JPG') or (Ext = 'JPEG') then
        begin
          FAsJPEG := true;
          GetJPGSize(fn, FWidth, FHeight);
          if ConvertProgressiveJPEG and ((Width = 0) or (Height = 0)) then
           begin
      {$IFDEF DelphiJPEG}
             JPG := TJPEGImage.Create;
             JPG.LoadFromFile(fn);
             if JPG.ProgressiveEncoding then
               begin
                 BMP := TBitmap.Create;
                 BMP.Assign(JPG);
                 FWidth:= BMP.Width;
                 FHeight:= BMP.Height;
                 JPG.Free;
                 JPG := TJPEGImage.Create;
                 JPG.ProgressiveEncoding := false;
                 JPG.Assign(BMP);
                 BMP.Free;
                 Data := TMemoryStream.Create;
                 JPG.SaveToStream(Data);
                 FDataState := dsMemoryJPEG;
               end;
             JPG.Free;
      {$ENDIF}
           end else
           begin
             // Data := TFileStream.Create(fn, fmOpenRead + fmShareDenyNone);
             FDataState := dsInitJPEG;// dsFileJPEG;
           end;

        end else
      if ext = 'BMP' then
        begin
         BMPStorage.LoadFromFile(fn);
         GetBMPInfo;
         FAsJPEG := false;
        end else
      if (@LoadCustomImageProc<>nil) then
         LoadCustomImageProc(self, fn) else
      exception.Create('Image format "'+ext+'" not supported!');
    end;
end;

procedure TFlashImage.LoadDataFromHandle(HBMP: HBitmap);
begin
  BMPStorage.LoadFromHandle(HBMP);
  GetBMPInfo;
end;

procedure TFlashImage.LoadDataFromNativeStream(S: TStream; JPG: boolean; Width, Height: integer);
begin
  LoadDataFromNativeStream(S, JPG, Width, Height, 0, 0, false);
end;

procedure TFlashImage.LoadDataFromNativeStream(S: TStream; JPG: boolean; Width, Height: integer; BMPType, ColorCount: byte;
        HasAlpha: boolean);
begin
  Case DataState of
    dsFileJPEG: FData.Free;
    dsMemory, dsMemoryBMP, dsMemoryJPEG: TMemoryStream(FData).Clear;
  end;

  FAsJPEG := JPG;
  FWidth := Width;
  FHeight := Height;
  if not AsJPEG then
    begin
     FSaveWidth := Width;
     SWFBMPType := BMPType;
     FHasUseAlpha := HasAlpha;
     FColorCount := ColorCount;
    end;

  S.Position := 0;
  Data.CopyFrom(S, S.Size);
end;

procedure TFlashImage.LoadDataFromStream(S: TStream);
begin
  BMPStorage.LoadFromStream(S);
  GetBMPInfo;
  FAsJPEG := false;
end;

procedure TFlashImage.MakeAlphaLayer(Alpha: byte = $FF);
var
  P: Pointer;
  S: LongInt;
begin
 if AsJPEG then
  begin
    S := Width * Height;
    GetMem(P, S);
    FillChar(P^, S, Alpha);
    AlphaData.Position := 0;
    AlphaData.Write(P^, S);
    AlphaData.Position := 0;
    FreeMem(P, S);
  end else
  if BMPStorage.bpp = 32 then
    FillAlpha(BMPStorage, Alpha);
end;

procedure TFlashImage.MakeDataFromBMP;
var
  il, il2: Integer;
  addBytes, B: Byte;
  tmpMemStream, MMem: TMemoryStream;
  W: ^Word;
  P: PLine8;
  CW, NullW: dWord;
  pCA: PFColorA;
  pC: PFColor;
  needFixAlpha: boolean;
begin
  if SWFBMPType = 0 then GetBMPInfo;
  tmpMemStream := TMemoryStream.Create;
  addBytes := SaveWidth - Width;
  NullW := 0;
  case SWFBMPType of
    BMP_8bit: begin
     tmpMemStream.SetSize(SaveWidth * Height + (ColorCount * (3 + byte(HasUseAlpha))));
     for il:=0 to ColorCount - 1 do
      with BMPStorage.Colors[il] do
       begin
        tmpMemStream.Write(r, 1);
        tmpMemStream.Write(g, 1);
        tmpMemStream.Write(b, 1);
        if HasUseAlpha then tmpMemStream.Write(a, 1);
       end;
  
     for il:=Height - 1 downto 0 do
      begin
        P := BMPStorage.Scanlines[il];
        case BMPStorage.Bpp of
         8:tmpMemStream.Write(P^, Width);
         4:begin
            for il2 := 0 to (Width  - 1) do
              begin
                if Odd(il2) then B := P^[il2 div 2] and $F
                 else B := P^[il2 div 2] shr 4;
                tmpMemStream.Write(B, 1);
              end;
           end;
         1:begin
            for il2 := 0 to (Width  - 1) do
             begin
               B := (il2 and 7) xor 7;
               B := P^[il2 shr 3] and (1 shl B) shr B;
               tmpMemStream.Write(B, 1);
             end;
           end;
        end;
        if addBytes > 0 then tmpMemStream.Write(NullW, addBytes);
      end;
  
    end;

    BMP_15bit:begin
      tmpMemStream.SetSize(SaveWidth * Height * 2);

      for il := Height - 1 downto 0 do
       begin
        W := BMPStorage.ScanLines[il];
        for il2:=0 to Width - 1 do
         begin
            b := hi(W^);
            tmpMemStream.Write(b, 1);
            tmpMemStream.Write(W^, 1);
            Inc(W);
         end;
        if addBytes > 0 then tmpMemStream.Write(NullW, addBytes * 2);
       end;
  
    end;
  
    BMP_24bit: begin
     tmpMemStream.SetSize(SaveWidth * Height * 4);
     CW := $FF;

      for il := Height - 1 downto 0 do
       begin
        pC := BMPStorage.Scanlines[il];
        for il2:=0 to Width - 1 do
         begin
          with pC^ do
            CW := b shl 24 + g shl 16 + r shl 8 + $FF;
          tmpMemStream.Write(CW, 4);
          inc(pC);
         end;
       end;
    end;

    BMP_32bitWork: begin
      needFixAlpha := true;

      if (Owner = nil) or Owner.Fix32bitImage then
      begin
        for il := Height - 1 downto 0 do
        begin
          pCA := BMPStorage.Scanlines[il];
          for il2 := 0 to Width - 1 do
            begin
              if pCA^.A > 0 then
              begin
                needFixAlpha := false;
                Break;
              end;
              inc(pCA);
            end;
          if not needFixAlpha then Break;
        end;
      end;

      HasUseAlpha := true;
      tmpMemStream.SetSize(SaveWidth * Height * 4);
      for il := Height - 1 downto 0 do
      begin
       pCA := BMPStorage.Scanlines[il];
       for il2 := 0 to Width - 1 do
         with pCA^ do
         begin
           if needFixAlpha then CW := b shl 24 + g shl 16 + r shl 8 + $FF
           else
             if a = 0 then CW := 0
               else
                 CW := b shl 24 + g shl 16 + r shl 8 + a;
          tmpMemStream.Write(CW, 4);
          inc(pCA);
         end;
      end;

    end;
  end;

  tmpMemStream.Position := 0;
  MMem := TMemoryStream.Create;
  Data := MMem;
  with TCompressionStream.Create(clDefault, MMem) do
   begin
    CopyFrom(tmpMemStream, tmpMemStream.Size);
    free;
   end;
  tmpMemStream.Free;
  FDataState := dsMemoryBMP;
end;

procedure TFlashImage.FillBitsLossless(BL: TSWFDefineBitsLossless);
begin
  MakeDataFromBMP;
  if SWFBMPType = BMP_32bitWork
    then BL.BitmapFormat := BMP_32bit
    else BL.BitmapFormat := SWFBMPType;
  BL.BitmapWidth := Width;//SaveWidth;
  BL.BitmapHeight := Height;
  if SWFBMPType = BMP_8bit then BL.BitmapColorTableSize := ColorCount - 1;
  BL.OnDataWrite := WriteData;
end;

function TFlashImage.MinVersion: Byte;
begin
  Result := SWFVer2 + byte(HasUseAlpha);
end;


procedure TFlashImage.SetAlphaColor(Color: recRGBA);
var
  il: Integer;
begin
  if (FBMPStorage <> nil) and (SWFBMPType = BMP_8bit) then
   begin
     FHasUseAlpha := true;
     For il := 0 to ColorCount - 1 do
      With BMPStorage.Colors[il] do
       if (R = Color.R) and (G = Color.G) and (B = Color.B) then
         begin
           A := Color.A;
           if A = 0 then
             begin
              R := 0;
              G := 0;
              B := 0;
             end;
         end;
   end;
end;

procedure TFlashImage.SetAlphaIndex(Index, Alpha: byte);
begin
  if (FBMPStorage <> nil) and (SWFBMPType = BMP_8bit) and (Index < ColorCount) then
   with BMPStorage.Colors[Index] do
    begin
      FHasUseAlpha := true;
      a := Alpha;
      if A = 0 then
        begin
         R := 0;
         G := 0;
         B := 0;
        end;
    end;
end;

procedure TFlashImage.SetAlphaPixel(X, Y: Integer; Value: Byte);
var
  P: ^byte;
begin
  
  if AsJPEG then
    begin
      P := AlphaData.Memory;
      inc(P, Y * Width + X);
      P^ := Value;
    end else
    if SWFBMPType = BMP_32bitWork then
     with BMPStorage.Pixels32[Y][X] do
      begin
        A := Value;
      end;
end;

procedure TFlashImage.SetAsJPEG(const Value: Boolean);
{$IFDEF DelphiJPEG}
  var
     JPG: TJPEGImage;
     BMP: TBitMap;
{$ENDIF}
begin
  if FAsJPEG = Value then Exit;
  if Value and (DataState = dsMemoryBMP) then
    begin
{$IFDEF DelphiJPEG}
     BMP := TBitMap.Create;
     BMP.Width := BMPStorage.Width;
     BMP.Height := BMPStorage.Height;
     BitBlt(BMP.Canvas.Handle, 0, 0, BMP.Width, BMP.Height, BMPStorage.DC, 0, 0, SRCCOPY);
     JPG := TJPEGImage.Create;
     JPG.CompressionQuality := 100;
     JPG.Assign(BMP);
     JPG.Compress;
     JPG.SaveToStream(Data);
     FDataState := dsMemoryJPEG;
     FAsJPEG := true;
     BMP.Free;
     JPG.Free;
     if BMPStorage.Bpp = 32 then
       LoadAlphaDataFromBMPReader(BMPStorage);
{$ENDIF}
    end else
  if not Value and (DataState in [dsInitJPEG, dsMemoryJPEG]) then
    begin
{$IFDEF DelphiJPEG}
     BMP := TBitMap.Create;
     JPG := TJPEGImage.Create;
     if DataState = dsMemoryJPEG then
       begin
        JPG.LoadFromStream(Data);
        TMemoryStream(Data).Clear;
       end
       else JPG.LoadFromFile(FileName);
     BMP.Assign(JPG);
     BMPStorage.LoadFromHandle(BMP.Handle);
     FDataState := dsMemory;
     FAsJPEG := false;
     BMP.Free;
     JPG.Free;
{$ENDIF}
    end;

end;

procedure TFlashImage.SetConvertProgressiveJPEG(Value: Boolean);

  {$IFDEF DelphiJPEG}
  var
   JPG: TJPEGImage;
   BMP: TBitmap;
  {$ENDIF}
  
begin
  if Value and (Value <> FConvertProgressiveJPEG) and (DataState in [dsInitJPEG, dsFileJPEG]) then
   begin
  {$IFDEF DelphiJPEG}
    if DataState = dsInitJPEG then
      begin
        FData := TFileStream.Create(FileName, fmOpenRead + fmShareDenyNone);
        FDataState := dsFileJPEG;
      end;
    Data.Position := 0;
    JPG := TJPEGImage.Create;
    JPG.LoadFromStream(Data);
    if JPG.ProgressiveEncoding then
      begin
        BMP := TBitmap.Create;
        BMP.Assign(JPG);
        JPG.Free;
        JPG := TJPEGImage.Create;
        JPG.ProgressiveEncoding := false;
        JPG.Assign(BMP);
        BMP.Free;
        Data := TMemoryStream.Create;
        JPG.SaveToStream(Data);
        FDataState := dsMemoryJPEG;
      end;
    JPG.Free;
  {$ENDIF}
   end;
  FConvertProgressiveJPEG := Value;
end;

procedure TFlashImage.SetData(Value: TStream);
begin
  if Assigned(fData) then fData.Free;
  fData := Value;
end;

procedure TFlashImage.SetFileName(value: string);
begin
 if FFileName <> value then
   LoadDataFromFile(value);
end;

procedure TFlashImage.WriteAlphaData(sender: TSWFObject; BE: TBitsEngine);
begin
  AlphaData.Position := 0;
  with TCompressionStream.Create(clDefault, BE.BitsStream) do
   begin
    CopyFrom(AlphaData, AlphaData.Size);
    Free;
   end;
end;

procedure TFlashImage.WriteData(sender: TSWFObject; BE: TBitsEngine);
 var tmpStream: TStream;
begin
  if AsJPEG then
   begin
     if DataState = dsInitJPEG
       then tmpStream := TFileStream.Create(FileName, fmOpenRead + fmShareDenyNone)
       else tmpStream := Data;

    // if not HasUseAlpha then
      BE.WriteWord($D9FF);
      BE.WriteWord($D8FF);
   end else
   begin
     if (Data.Size = 0) then MakeDataFromBMP;
     tmpStream := Data;
   end;

  tmpStream.Position := 0;
  BE.BitsStream.CopyFrom(tmpStream, tmpStream.Size);

  if AsJPEG and (DataState = dsInitJPEG) then tmpStream.Free;
end;

procedure TFlashImage.WriteToStream(be: TBitsEngine);
var
  ObjJPEG: TSWFDefineBitsJPEG2;
  ObjJPEGA: TSWFDefineBitsJPEG3;
  ObjLossless: TSWFDefineBitsLossless;
begin
  if AsJPEG then
   begin
     if (FAlphaData = nil) or (AlphaData.Size = 0) then
       begin
         ObjJPEG := TSWFDefineBitsJPEG2.Create;
         ObjJPEG.CharacterID := CharacterID;
         ObjJPEG.OnDataWrite := WriteData;
         ObjJPEG.WriteToStream(BE);
         ObjJPEG.Free;
       end
       else
       begin
         ObjJPEGA := TSWFDefineBitsJPEG3.Create;
         ObjJPEGA.CharacterID := CharacterID;
         ObjJPEGA.OnDataWrite := WriteData;
         ObjJPEGA.OnAlphaDataWrite := WriteAlphaData;
         ObjJPEGA.WriteToStream(BE);
         ObjJPEGA.Free;
       end;
   end else
   begin
     if HasUseAlpha then ObjLossless := TSWFDefineBitsLossless2.Create
        else ObjLossless := TSWFDefineBitsLossless.Create;
  
     ObjLossless.CharacterID := CharacterID;
     if SWFBMPType = BMP_32bitWork
       then ObjLossless.BitmapFormat := BMP_32bit
       else ObjLossless.BitmapFormat := SWFBMPType;
     ObjLossless.BitmapWidth := Width;//SaveWidth;
     ObjLossless.BitmapHeight := Height;
     if SWFBMPType = BMP_8bit then ObjLossless.BitmapColorTableSize := ColorCount - 1;
     ObjLossless.OnDataWrite := WriteData;
     ObjLossless.WriteToStream(BE);
     ObjLossless.Free;
   end;
end;

// =============================================================//
//                           TFlashActionScript                   //
// =============================================================//

const
  ActionOperation : array [0..8] of pchar = ('+', '-', '*', '/', '&', '|', '!', '++', '--');

{
**************************************************** TFlashActionScript *****************************************************
}
constructor TFlashActionScript.Create(owner: TFlashMovie; A: TSWFActionList);
begin
  inherited Create(owner);
  selfDestroy := A = nil;
  if selfDestroy then fActionList := TSWFActionList.Create
    else fActionList := A;
end;

destructor TFlashActionScript.Destroy;
begin
  if selfDestroy then fActionList.Free;
  inherited ;
end;

procedure TFlashActionScript.Add;
begin
  ActionList.Add(TSWFActionAdd.Create);
end;

procedure TFlashActionScript.Add2;
begin
  ActionList.Add(TSWFActionAdd2.Create);
end;

procedure TFlashActionScript.AsciiToChar;
begin
  ActionList.Add(TSWFActionAsciiToChar.Create);
end;

procedure TFlashActionScript.Assign(Source: TBasedSWFObject);
begin
  With TFlashActionScript(Source) do
  begin
    Self.SelfDestroy := SelfDestroy;
    CopyActionList(ActionList, self.ActionList);
  end;
end;

procedure TFlashActionScript.BitAnd;
begin
  ActionList.Add(TSWFActionBitAnd.Create);
end;

procedure TFlashActionScript.BitLShift;
begin
  ActionList.Add(TSWFActionBitLShift.Create);
end;

procedure TFlashActionScript.BitOr;
begin
  ActionList.Add(TSWFActionBitOr.Create);
end;

procedure TFlashActionScript.BitRShift;
begin
  ActionList.Add(TSWFActionBitRShift.Create);
end;

procedure TFlashActionScript.BitURShift;
begin
  ActionList.Add(TSWFActionBitURShift.Create);
end;

procedure TFlashActionScript.BitXor;
begin
  ActionList.Add(TSWFActionBitXor.Create);
end;

function TFlashActionScript.ByteCode(const str: string): TSWFActionByteCode;
begin
  Result := TSWFActionByteCode.Create;
  Result.StrByteCode := str;
  ActionList.Add(Result);
end;

function TFlashActionScript.ByteCode(const AB: array of byte): TSWFActionByteCode;
var
  P: PByte;
  il: Word;
begin
  Result := TSWFActionByteCode.Create;
  Result.DataSize := High(AB) + 1;
  GetMem(P, Result.DataSize);
  Result.Data := P;
  Result.SelfDestroy := true;
  For il := 0 to Result.DataSize - 1 do
    begin
     P^ := AB[il];
     inc(P);
    end;
  ActionList.Add(Result);
end;

function TFlashActionScript.ByteCode(Data: Pointer; Size: longint): TSWFActionByteCode;
begin
  Result := TSWFActionByteCode.Create;
  Result.Data := Data;
  Result.DataSize := Size;
  ActionList.Add(Result);
end;

procedure TFlashActionScript.Call;
begin
  ActionList.Add(TSWFActionCall.Create);
end;

procedure TFlashActionScript.CallFunction;
begin
  ActionList.Add(TSWFActionCallFunction.Create);
end;

procedure TFlashActionScript.CallMethod;
begin
  ActionList.Add(TSWFActionCallMethod.Create);
end;

procedure TFlashActionScript.CastOp;
begin
  ActionList.Add(TSWFActionCastOp.Create);
end;

procedure TFlashActionScript.CharToAscii;
begin
  ActionList.Add(TSWFActionCharToAscii.Create);
end;

procedure TFlashActionScript.CloneSprite;
begin
  ActionList.Add(TSWFActionCloneSprite.Create);
end;

{$IFDEF ASCompiler}
function TFlashActionScript.Compile(src: TStrings): boolean;
 var S: TMemoryStream;
begin
  S := TMemoryStream.Create;
  src.SaveToStream(S);
  Result := Compile(S);
  S.Free;
end;

function TFlashActionScript.Compile(src: TStream): boolean;
begin
  try
    src.Position := 0;
    owner.ASCompiler.CompileAction(src, self);
    Result := true;
  except
    on E: Exception do
      begin
        owner.ASCompilerLog.Write(PChar(E.Message)^, Length(E.Message));
        Result := false;
      end;
  end;
end;

function TFlashActionScript.Compile(src: ansistring): boolean;
 var S: TMemoryStream;
     P: Pointer;
begin
  S := TMemoryStream.Create;
  P := @src[1];
  S.Write(P^, length(src));
  Result := Compile(S);
  S.Free;
end;

function TFlashActionScript.Compile(FileName: string; unicode: boolean): boolean;
 var F: TFileStream;
begin
  F := TFileStream.Create(Filename, fmOpenRead);
  /// if unicode  -  todo
  Result := Compile(F);
  F.free;
end;
{$ENDIF}

function TFlashActionScript.ConstantPool(Consts: array of string): TSWFActionConstantPool;
var
  il: Word;
begin
  Result := TSWFActionConstantPool.Create;
  if (High(Consts) - Low(Consts) + 1) > 0 then
    For il:=Low(Consts) to High(Consts) do Result.ConstantPool.Add(Consts[il]);
  ActionList.Add(Result);
end;

function TFlashActionScript.ConstantPool(Consts: TStrings): TSWFActionConstantPool;
begin
  Result := TSWFActionConstantPool.Create;
  if Assigned(Consts) and (Consts.Count > 0) then
    Result.ConstantPool.AddStrings(Consts);
  ActionList.Add(Result);
end;

procedure TFlashActionScript.Decrement;
begin
  ActionList.Add(TSWFActionDecrement.Create);
end;

function TFlashActionScript.DefineFunction(Name: string; Params: array of string): TSWFActionDefineFunction;
var
  il: Word;
begin
  Result := TSWFActionDefineFunction.Create;
  Result.FunctionName := Name;
  if (High(Params) - Low(Params) + 1) > 0 then
    For il:=Low(Params) to High(Params) do Result.Params.Add(Params[il]);
  ActionList.Add(Result);
end;

function TFlashActionScript.DefineFunction(Name: string; Params: TStrings): TSWFActionDefineFunction;
begin
  Result := TSWFActionDefineFunction.Create;
  Result.FunctionName := Name;
  if (Params <> nil) and (Params.Count > 0) then
    Result.Params.AddStrings(Params);
  ActionList.Add(Result);
end;

function TFlashActionScript.DefineFunction2(Name: string; Params: array of string; RegistersAllocate: byte):
        TSWFActionDefineFunction2;
var
  il: Word;
begin
  Result := TSWFActionDefineFunction2.Create;
  Result.FunctionName := Name;
  if (High(Params) - Low(Params) + 1) > 0 then
    For il:=Low(Params) to High(Params) do Result.Parameters.Add(Params[il]);
  Result.RegisterCount := RegistersAllocate;
  ActionList.Add(Result);
end;

function TFlashActionScript.DefineFunction2(Name: string; Params: TStrings; RegistersAllocate: byte):
        TSWFActionDefineFunction2;
begin
  Result := TSWFActionDefineFunction2.Create;
  Result.FunctionName := Name;
  if (Params <> nil) and (Params.Count > 0) then
    Result.Parameters.AddStrings(Params);
  Result.RegisterCount := RegistersAllocate;
  ActionList.Add(Result);
end;

procedure TFlashActionScript.DefineLocal;
begin
  ActionList.Add(TSWFActionDefineLocal.Create);
end;

procedure TFlashActionScript.DefineLocal2;
begin
  ActionList.Add(TSWFActionDefineLocal2.Create);
end;

procedure TFlashActionScript.Delete;
begin
  ActionList.Add(TSWFActionDelete.Create);
end;

procedure TFlashActionScript.Delete2;
begin
  ActionList.Add(TSWFActionDelete2.Create);
end;

procedure TFlashActionScript.Divide;
begin
  ActionList.Add(TSWFActionDivide.Create);
end;

procedure TFlashActionScript.EndDrag;
begin
  ActionList.Add(TSWFActionEndDrag.Create);
end;

procedure TFlashActionScript.Enumerate;
begin
  ActionList.Add(TSWFActionEnumerate.Create);
end;

procedure TFlashActionScript.Enumerate2;
begin
  ActionList.Add(TSWFActionEnumerate2.Create);
end;

procedure TFlashActionScript.Equals;
begin
  ActionList.Add(TSWFActionEquals.Create);
end;

procedure TFlashActionScript.Equals2;
begin
  ActionList.Add(TSWFActionEquals2.Create);
end;

procedure TFlashActionScript.Extends;
begin
  ActionList.Add(TSWFActionExtends.Create);
end;

procedure TFlashActionScript.FSCommand(command, param: string);
begin
  GetUrl('FSCommand:'+command, param);
end;

procedure TFlashActionScript.FSCommand2(Args: TStrings);
  var il: integer;
begin
 if Args.Count > 0 then
  for il := Args.Count - 1 downto 0 do Push(Args[il]);
 Push(IntToStr(Args.Count));
 ActionList.Add(TSWFActionFSCommand2.Create);
end;

procedure TFlashActionScript.FSCommand2(Args: string);
 var sl: TStringlist;
begin
  while 0 < Pos(' ', Args) do System.Delete(Args, Pos(' ', Args), 1);
  sl := TStringlist.Create;
  sl.CommaText := Args;
  FSCommand2(sl);
  sl.Free;
end;

procedure TFlashActionScript.FSCommand2(const Args: array of Variant);
  var il: integer;
begin
 if (High(Args) - Low(Args) + 1) > 0 then
  begin
   For il:=High(Args) downto Low(Args) do Push([Args[il]], [vtString]);
   Push(IntToStr(High(Args) - Low(Args) + 1));
   ActionList.Add(TSWFActionFSCommand2.Create);
  end;
end;

function TFlashActionScript.GetAction(index: integer): TSWFAction;
begin
  Result := TSWFAction(fActionList[index]);
end;

procedure TFlashActionScript.GetMember;
begin
  ActionList.Add(TSWFActionGetMember.Create);
end;

procedure TFlashActionScript.GetProperty;
begin
  ActionList.Add(TSWFActionGetProperty.Create);
end;

procedure TFlashActionScript.GetProperty(targ: string; id: byte);
begin
  Push([targ, id]);
  GetProperty;
end;

procedure TFlashActionScript.GetTime;
begin
  ActionList.Add(TSWFActionGetTime.Create);
end;

procedure TFlashActionScript.GetUrl(const Url, Target: string);
var
  AUrl: TSWFActionGetUrl;
begin
  AUrl := TSWFActionGetUrl.Create;
  AUrl.URL := Url;
  AUrl.Target := Target;
  ActionList.Add(AUrl);
end;

procedure TFlashActionScript.GetUrl2(TargetFlag, VariablesFlag: boolean; SendMethod: byte);
var
  AUrl: TSWFActionGetUrl2;
begin
  AUrl := TSWFActionGetUrl2.Create;
  AUrl.LoadTargetFlag := TargetFlag;
  AUrl.LoadVariablesFlag := VariablesFlag;
  AUrl.SendVarsMethod := SendMethod;
  ActionList.Add(AUrl);
end;

procedure TFlashActionScript.GetVariable;
begin
  ActionList.Add(TSWFActionGetVariable.Create);
end;

procedure TFlashActionScript.GetVariable(VarName: string);
begin
  Push(VarName);
  GetVariable;
end;

procedure TFlashActionScript.GotoAndPlay(_Label: string);
begin
  Push(_Label);
  GotoFrame2(true);
end;

procedure TFlashActionScript.GotoAndPlay(Frame: Word);
begin
  Push(Frame);
  GotoFrame2(true);
end;

procedure TFlashActionScript.GotoAndStop(_Label: string);
begin
  Push(_Label);
  GotoFrame2(false);
end;

procedure TFlashActionScript.GotoAndStop(Frame: Word);
begin
  Push(Frame);
  GotoFrame2(false);
end;

procedure TFlashActionScript.GotoFrame(N: word);
var
  AGF: TSWFActionGotoFrame;
begin
  AGF := TSWFActionGotoFrame.Create;
  AGF.Frame := N;
  ActionList.Add(AGF);
end;

procedure TFlashActionScript.GotoFrame2(Play: boolean; SceneBias: word = 0);
var
  AGF: TSWFActionGotoFrame2;
begin
  AGF := TSWFActionGotoFrame2.Create;
  AGF.PlayFlag := Play;
  AGF.SceneBias := SceneBias;
  AGF.SceneBiasFlag := SceneBias > 0;
  ActionList.Add(AGF);
end;

procedure TFlashActionScript.GoToLabel(FrameLabel: string);
var
  A: TSWFActionGoToLabel;
begin
  A := TSWFActionGoToLabel.Create;
  A.FrameLabel := FrameLabel;
  ActionList.Add(A);
end;

procedure TFlashActionScript.Greater;
begin
  ActionList.Add(TSWFActionGreater.Create);
end;

procedure TFlashActionScript.ImplementsOp;
begin
  ActionList.Add(TSWFActionImplementsOp.Create);
end;

procedure TFlashActionScript.Increment;
begin
  ActionList.Add(TSWFActionIncrement.Create);
end;

procedure TFlashActionScript.InitArray;
begin
  ActionList.Add(TSWFActionInitArray.Create);
end;

procedure TFlashActionScript.InitObject;
begin
  ActionList.Add(TSWFActionInitObject.Create);
end;

procedure TFlashActionScript.InstanceOf;
begin
  ActionList.Add(TSWFActionInstanceOf.Create);
end;

function TFlashActionScript.Jump: TSWFActionJump;
begin
  Result := TSWFActionJump.Create;
  ActionList.Add(Result);
end;

procedure TFlashActionScript.Less;
begin
  ActionList.Add(TSWFActionLess.Create);
end;

procedure TFlashActionScript.Less2;
begin
  ActionList.Add(TSWFActionLess2.Create);
end;

function TFlashActionScript.LoadMovie(URL, Target: string;
   IsBrowserTarget: boolean = false; Method: byte = svmNone): TSWFActionGetUrl2;
begin
  Push([URL, Target], [vtString, vtString]);
  Result := TSWFActionGetUrl2.Create;
  Result.SendVarsMethod := Method;
  Result.LoadTargetFlag := not IsBrowserTarget;
  ActionList.Add(Result)
end;

function TFlashActionScript.LoadMovieNum(URL: string; Level: word; Method: byte): TSWFActionGetUrl2;
begin
  Push([URL, '_level'+IntToStr(Level)], [vtString, vtString]);
  Result := TSWFActionGetUrl2.Create;
  Result.SendVarsMethod := Method;
  ActionList.Add(Result)
end;

function TFlashActionScript.LoadVariables(URL, Target: string; Method: byte = svmNone): TSWFActionGetUrl2;
begin
  Push([URL, Target], [vtString, vtString]);
  Result := TSWFActionGetUrl2.Create;
  Result.SendVarsMethod := Method;
  Result.LoadTargetFlag := true;
  Result.LoadVariablesFlag := true;
  ActionList.Add(Result)
end;

function TFlashActionScript.LoadVariablesNum(URL: string; Level: word; Method: byte = svmNone): TSWFActionGetUrl2;
begin
  Push([URL, '_level'+IntToStr(Level)], [vtString, vtString]);
  Result := TSWFActionGetUrl2.Create;
  Result.SendVarsMethod := Method;
  Result.LoadVariablesFlag := true;
  ActionList.Add(Result)
end;

procedure TFlashActionScript.MBAsciiToChar;
begin
  ActionList.Add(TSWFActionMBAsciiToChar.Create);
end;

procedure TFlashActionScript.MBCharToAscii;
begin
  ActionList.Add(TSWFActionMBCharToAscii.Create);
end;

procedure TFlashActionScript.MBStringExtract;
begin
  ActionList.Add(TSWFActionMBStringExtract.Create);
end;

procedure TFlashActionScript.MBStringLength;
begin
  ActionList.Add(TSWFActionMBStringLength.Create);
end;

function TFlashActionScript.MinVersion: Byte;
var
  il: Word;
begin
  Result := SWFVer1;
  if ActionList.Count>0 then
    for il:= 0 to ActionList.Count - 1 do
      if Result < Action[il].MinVersion then
        Result:= Action[il].MinVersion;
end;

procedure TFlashActionScript.Modulo;
begin
  ActionList.Add(TSWFActionModulo.Create);
end;

procedure TFlashActionScript.Multiply;
begin
  ActionList.Add(TSWFActionMultiply.Create);
end;

procedure TFlashActionScript.NewMethod;
begin
  ActionList.Add(TSWFActionNewMethod.Create);
end;

procedure TFlashActionScript.NewObject;
begin
  ActionList.Add(TSWFActionNewObject.Create);
end;

procedure TFlashActionScript.NextFrame;
begin
  ActionList.Add(TSWFActionNextFrame.Create);
end;

procedure TFlashActionScript.Operation(op: string);
var
  A: TSWFAction;
  il: Integer;
begin
  A := nil;
  For il := 0 to 3 do
   if op = ActionOperation[il] then
    case il of
     0: A := TSWFActionAdd2.Create;
     1: A := TSWFActionSubtract.Create;
     2: A := TSWFActionMultiply.Create;
     3: A := TSWFActionDivide.Create;
     4: A := TSWFActionAnd.Create;
     5: A := TSWFActionOr.Create;
     6: A := TSWFActionNot.Create;
     7: A := TSWFActionIncrement.Create;
     8: A := TSWFActionDecrement.Create;
    end;
  if A<>nil then fActionList.Add(A);
end;

procedure TFlashActionScript.Play;
begin
  ActionList.Add(TSWFActionPlay.Create);
end;

procedure TFlashActionScript.Pop;
begin
  ActionList.Add(TSWFActionPop.Create);
end;

procedure TFlashActionScript.PreviousFrame;
begin
  ActionList.Add(TSWFActionPreviousFrame.Create);
end;

function TFlashActionScript.Push(const Args: array of Variant): TSWFActionPush;
var
  AP: TSWFActionPush;
  il: LongInt;
begin
  if (fActionList.Count>0) and
    (Action[fActionList.Count - 1].ActionCode = ActionPush) then
      AP := TSWFActionPush(fActionList[fActionList.Count - 1]) else AP := nil;
  if AP = nil then
    begin
      AP := TSWFActionPush.Create;
      ActionList.Add(AP);
    end;
  For il := Low(Args) to High(Args) do
    AP.AddValue(Args[il]);
  
  Result :=AP;
end;

function TFlashActionScript.Push(const Args: array of Variant; const Types: array of TSWFValueType): TSWFActionPush;
var
  AP: TSWFActionPush;
  il: LongInt;
begin
  if (fActionList.Count>0) and
    (Action[fActionList.Count - 1].ActionCode = ActionPush) then
      AP := TSWFActionPush(fActionList[fActionList.Count - 1]) else AP := nil;
  if AP = nil then
    begin
      AP := TSWFActionPush.Create;
      ActionList.Add(AP);
    end;
  For il := Low(Args) to High(Args) do
    AP.ValueInfo[AP.AddValue(Args[il])].ValueType := Types[il];
  Result := AP;
end;

function TFlashActionScript.Push(Value: Variant): TSWFActionPush;
begin
  Result := Push([Value]);
end;

procedure TFlashActionScript.PushConstant(Value: word);
begin
  PushConstant([Value]);
end;

procedure TFlashActionScript.PushConstant(const Args: array of word);
var
  AP: TSWFActionPush;
  il: LongInt;
begin
  if (fActionList.Count>0) and
    (Action[fActionList.Count - 1].ActionCode = ActionPush) then
      AP := TSWFActionPush(fActionList[fActionList.Count - 1]) else AP := nil;
  if AP = nil then
    begin
      AP := TSWFActionPush.Create;
      ActionList.Add(AP);
    end;
  For il := Low(Args) to High(Args) do
   with AP.ValueInfo[AP.AddValue(Args[il])] do
    if Args[il] <= $FF then ValueType := vtConstant8 else ValueType := vtConstant16;
end;

procedure TFlashActionScript.PushDuplicate;
begin
  ActionList.Add(TSWFActionPushDuplicate.Create);
end;

procedure TFlashActionScript.PushRegister(const Args: array of Word);
var
  AP: TSWFActionPush;
  il: LongInt;
begin
  if (fActionList.Count>0) and
    (Action[fActionList.Count - 1].ActionCode = ActionPush) then
      AP := TSWFActionPush(fActionList[fActionList.Count - 1]) else AP := nil;
  if AP = nil then
    begin
      AP := TSWFActionPush.Create;
      ActionList.Add(AP);
    end;
  For il := Low(Args) to High(Args) do
    AP.ValueInfo[AP.AddValue(Args[il])].ValueType := vtRegister ;
end;

procedure TFlashActionScript.PushRegister(Value: Word);
begin
  PushRegister([Value]);
end;

procedure TFlashActionScript.Random;
begin
  RandomNumber;
end;

procedure TFlashActionScript.Random(max: dword);
begin
  Push(max);
  RandomNumber;
end;

procedure TFlashActionScript.Random(min, max: dword);
begin
  Push([min, max]);
  RandomNumber;
  StackSwap;
  Operation('-');
end;

procedure TFlashActionScript.RandomNumber;
begin
  ActionList.Add(TSWFActionRandomNumber.Create);
end;

procedure TFlashActionScript.RemoveSprite;
begin
  ActionList.Add(TSWFActionRemoveSprite.Create);
end;

procedure TFlashActionScript.Return;
begin
  ActionList.Add(TSWFActionReturn.Create);
end;

procedure TFlashActionScript.SetArray(const name: string; const Args: array of Variant; inSprite: boolean = false);
 var il: integer;
begin
  Push(Name);
  for il := High(Args) downto Low(Args) do push(Args[il]);
  Push(High(Args) - Low(Args) + 1);
  InitArray;
  if inSprite then DefineLocal
    else SetVariable;
end;

function TFlashActionScript.SetMarker(M: TSWFOffsetMarker = nil; ToBack: boolean = false): TSWFOffsetMarker;
begin
  if M = nil then
    begin
      Result := TSWFOffsetMarker.Create;
      Result.JumpToBack := true;
    end else
    begin
      Result := M;
      Result.JumpToBack := ToBack;
    end;
  Result.isUsing := true;
  ActionList.Add(Result);
end;

procedure TFlashActionScript.SetMember;
begin
  ActionList.Add(TSWFActionSetMember.Create);
end;

procedure TFlashActionScript.SetProperty;
begin
  ActionList.Add(TSWFActionSetProperty.Create);
end;

procedure TFlashActionScript.SetProperty(targ: string; id: byte);
begin
  Push([targ, id]);
  SetProperty;
end;

procedure TFlashActionScript.SetTarget(TargetName: string);
var
  A: TSWFActionSetTarget;
begin
  A := TSWFActionSetTarget.Create;
  A.TargetName := TargetName;
  ActionList.Add(A);
end;

procedure TFlashActionScript.SetTarget2;
begin
  ActionList.Add(TSWFActionSetTarget2.Create);
end;

procedure TFlashActionScript.SetVar(VarName: string; Value: Variant; inSprite: boolean = false);
var
  AP: TSWFActionPush;
begin
  AP := TSWFActionPush.Create;
  AP.AddValue(VarName);
  AP.AddValue(Value);
  ActionList.Add(AP);
  if inSprite then DefineLocal
    else SetVariable;
end;

procedure TFlashActionScript.SetVariable;
var
  ASV: TSWFActionSetVariable;
begin
  ASV := TSWFActionSetVariable.Create;
  ActionList.Add(ASV);
end;

procedure TFlashActionScript.StackSwap;
begin
  fActionList.Add(TSWFActionStackSwap.Create);
end;

procedure TFlashActionScript.StartDrag;
begin
  ActionList.Add(TSWFActionStartDrag.Create);
end;

procedure TFlashActionScript.Stop;
begin
  ActionList.Add(TSWFActionStop.Create);
end;

procedure TFlashActionScript.StopSounds;
begin
  ActionList.Add(TSWFActionStopSounds.Create);
end;

procedure TFlashActionScript.StoreRegister(Num: byte);
var
  A: TSWFActionStoreRegister;
begin
  A := TSWFActionStoreRegister.Create;
  A.RegisterNumber := Num;
  ActionList.Add(A);
end;

procedure TFlashActionScript.StrictEquals;
begin
  ActionList.Add(TSWFActionStrictEquals.Create);
end;

procedure TFlashActionScript.StringAdd;
begin
  ActionList.Add(TSWFActionStringAdd.Create);
end;

procedure TFlashActionScript.StringEquals;
begin
  ActionList.Add(TSWFActionStringEquals.Create);
end;

procedure TFlashActionScript.StringExtract;
begin
  ActionList.Add(TSWFActionStringExtract.Create);
end;

procedure TFlashActionScript.StringGreater;
begin
  ActionList.Add(TSWFActionStringGreater.Create);
end;

procedure TFlashActionScript.StringLength;
begin
  ActionList.Add(TSWFActionStringLength.Create);
end;

procedure TFlashActionScript.StringLess;
begin
  ActionList.Add(TSWFActionStringLess.Create);
end;

procedure TFlashActionScript.Subtract;
begin
  ActionList.Add(TSWFActionSubtract.Create);
end;

procedure TFlashActionScript.TargetPath;
begin
  ActionList.Add(TSWFActionTargetPath.Create);
end;

procedure TFlashActionScript.Throw;
begin
  ActionList.Add(TSWFActionThrow.Create);
end;

procedure TFlashActionScript.ToggleQuality;
begin
  ActionList.Add(TSWFActionToggleQuality.Create);
end;

procedure TFlashActionScript.ToInteger;
begin
  ActionList.Add(TSWFActionToInteger.Create);
end;

procedure TFlashActionScript.ToNumber;
begin
  ActionList.Add(TSWFActionToNumber.Create);
end;

procedure TFlashActionScript.ToString;
begin
  ActionList.Add(TSWFActionToString.Create);
end;

procedure TFlashActionScript.Trace;
begin
  ActionList.Add(TSWFActionTrace.Create);
end;

procedure TFlashActionScript.TypeOf;
begin
  ActionList.Add(TSWFActionTypeOf.Create);
end;

procedure TFlashActionScript.WaitForFrame(Frame: Word; SkipCount: Byte);
var
  A: TSWFActionWaitForFrame;
begin
  A := TSWFActionWaitForFrame.Create;
  A.Frame := Frame;
  A.SkipCount := SkipCount;
  ActionList.Add(A);
end;

procedure TFlashActionScript.WaitForFrame2;
begin
  ActionList.Add(TSWFActionWaitForFrame2.Create.Create);
end;



procedure TFlashActionScript.WriteToStream(be: TBitsEngine);
begin
  with TSWFDoAction.Create(fActionList) do
   begin
    WriteToStream(be);
    free;
   end;
end;

procedure TFlashActionScript._And;
begin
  ActionList.Add(TSWFActionAnd.Create);
end;

function TFlashActionScript._If: TSWFActionIf;
begin
  Result := TSWFActionIf.Create;
  ActionList.Add(Result);
end;

procedure TFlashActionScript._Not;
begin
  ActionList.Add(TSWFActionNot.Create);
end;

procedure TFlashActionScript._Or;
begin
  ActionList.Add(TSWFActionOr.Create);
end;

function TFlashActionScript._Try: TSWFActionTry;
begin
  Result := TSWFActionTry.Create;
  ActionList.Add(Result);
end;

function TFlashActionScript._With: TSWFActionWith;
begin
  Result := TSWFActionWith.Create;
  ActionList.Add(Result);
end;

{
**************************************************** TFlashVisualObject *****************************************************
}
procedure TFlashVisualObject.Assign(Source: TBasedSWFObject);
begin
  inherited;
  With TFlashVisualObject(Source) do
  begin
    self.IgnoreMovieSettings := IgnoreMovieSettings;
    self.fXCenter := fXCenter;
    self.fYCenter := fYCenter;
  end;
end;

function TFlashVisualObject.GetMultCoord: Byte;
begin
  if IgnoreMovieSettings or (owner = nil) then Result := 1
    else Result := Owner.MultCoord;
end;

// =============================================================//
//                           TFlashShape                        //
// =============================================================//


const
 CEllipse1  = 0.1465;
 CEllipse2  = 0.2070;
 CEllipse3: array [0..7, 0..3] of Shortint =
                (( 0,  1, -1,  1),
                 (-1,  1, -1,  0),
                 (-1,  0, -1, -1),
                 (-1, -1,  0, -1),
                 ( 0, -1,  1, -1),
                 ( 1, -1,  1,  0),
                 ( 1,  0,  1,  1),
                 ( 1,  1,  0,  1));
type
  TLineInfo = record
    X: LongInt;
    Y: LongInt;
    a: Double;
    b: Double;
    isVertical: Boolean;
  end;

{
******************************************************** TFlashEdges ********************************************************
}
constructor TFlashEdges.Create(List: TObjectList);
begin
  ListEdges := List;
  StartNewStyle;
  FCurrentPos := Point(0, 0);
  OptimizeMode := false;
end;

destructor TFlashEdges.Destroy;
begin
  inherited;
end;


function TFlashEdges.AddChangeStyle: TSWFStyleChangeRecord;
begin
  With ListEdges do
  if (Count > 0) and
   (TSWFShapeRecord(Items[Count-1]).ShapeRecType = StyleChangeRecord)
      then
        Result := TSWFStyleChangeRecord(Items[Count-1])
      else
      begin
        Result := TSWFStyleChangeRecord.Create;
        Add(Result);
      end;
end;

procedure TFlashEdges.CloseAllConturs;
 var il, ils: longint;
     SPoint, CPoint: TPoint;
     L: TSWFStraightEdgeRecord;
begin
  if ListEdges.Count > 0 then
  begin
    il := 0;
    ils := 0;
    while il < ListEdges.Count do
    begin
      case TSWFShapeRecord(ListEdges.Items[il]).ShapeRecType of
        StyleChangeRecord:
        begin
          if ((ils + 1) < il) and (SPoint.X <> CPoint.X) and (SPoint.Y <> CPoint.Y) then
          begin
            L := TSWFStraightEdgeRecord.Create;
            ListEdges.Insert(il, L);
            L.X := SPoint.X - CPoint.X;
            L.Y := SPoint.Y - CPoint.Y;
          end;
          with TSWFStraightEdgeRecord(ListEdges[il]) do
            CPoint := Point(X, Y);
          SPoint := CPoint;
          ils := il;
        end;

        StraightEdgeRecord:
        with TSWFStraightEdgeRecord(ListEdges[il]) do
        begin
          CPoint.X := CPoint.X + X;
          CPoint.Y := CPoint.Y + Y;
        end;

        CurvedEdgeRecord:
        with TSWFCurvedEdgeRecord(ListEdges[il]) do
        begin
          CPoint.X := CPoint.X + ControlX + AnchorX;
          CPoint.Y := CPoint.Y + ControlY + AnchorY;
        end;
      end;
      inc(il);
    end;
  end;
end;

procedure TFlashEdges.CloseShape;
var
  ISet: Boolean;
begin
  if (CurrentPos.X <> LastStart.X) or (CurrentPos.Y <> LastStart.Y) then
   begin
     ISet := IgnoreMovieSettings;
     IgnoreMovieSettings := true;
     LineTo(LastStart.X, LastStart.Y);
     IgnoreMovieSettings := ISet;
   end;
end;

procedure TFlashEdges.CopyFrom(Source: TFlashEdges);
begin
  CopyShapeRecords(Source.ListEdges, ListEdges);
end;

function TFlashEdges.CurveDelta(ControlX, ControlY, AnchorX, AnchorY: longint): TSWFCurvedEdgeRecord;
var
  FCPos: TPoint;

  procedure ResultNil(X, Y: longint);
    var ISet: boolean;
  begin
    ISet := IgnoreMovieSettings;
    IgnoreMovieSettings := true;
    LineDelta(X, Y);
    IgnoreMovieSettings := ISet;
    Result.Free;
    Result := nil;
  end;

begin
  Result := TSWFCurvedEdgeRecord.Create;
  Result.ControlX := ControlX * MultCoord;
  Result.ControlY := ControlY * MultCoord;
  Result.AnchorX := AnchorX * MultCoord;
  Result.AnchorY := AnchorY * MultCoord;
  FCPos := Point(FCurrentPos.X + Result.ControlX + Result.AnchorX,
                 FCurrentPos.Y + Result.ControlY + Result.AnchorY);
  if ((Result.ControlX = 0) and (Result.ControlY = 0)) then
    begin
      ResultNil(Result.AnchorX, Result.AnchorY);
    end else
  if ((Result.AnchorX = 0) and (Result.AnchorY = 0)) then
    begin
      ResultNil(Result.ControlX, Result.ControlY);
    end else
  if ((Result.ControlY = 0) and (Result.AnchorY = 0)) then
    begin
      ResultNil(Result.AnchorX + Result.ControlX, 0);
    end else
  if ((Result.ControlX = 0) and (Result.AnchorX = 0)) then
    begin
      ResultNil(0, Result.AnchorY + Result.ControlY);
    end else
     ListEdges.Add(Result);
  FCurrentPos := FCPos;
end;

function TFlashEdges.CurveTo(ControlX, ControlY, AnchorX, AnchorY: longint): TSWFCurvedEdgeRecord;
var
  tmpP: TPoint;

  procedure ResultNil(X, Y: longint);
    var ISet: boolean;
  begin
    ISet := IgnoreMovieSettings;
    IgnoreMovieSettings := true;
    LineDelta(X, Y);
    IgnoreMovieSettings := ISet;
    Result.Free;
    Result := nil;
  end;

begin
  if ((AnchorX * MultCoord) = FCurrentPos.X) and
     ((AnchorY *MultCoord ) = FCurrentPos.Y) then Exit;
  Result := TSWFCurvedEdgeRecord.Create;
  tmpP := Point(ControlX * MultCoord, ControlY * MultCoord);
  Result.ControlX := tmpP.X - CurrentPos.X;
  Result.ControlY := tmpP.Y - CurrentPos.Y;
  Result.AnchorX := (AnchorX - ControlX) * MultCoord;
  Result.AnchorY := (AnchorY - ControlY) * MultCoord;

  if ((Result.ControlX = 0) and (Result.ControlY = 0)) then
    begin
      ResultNil(Result.AnchorX, Result.AnchorY);
    end else
  if ((Result.AnchorX = 0) and (Result.AnchorY = 0)) then
    begin
      ResultNil(Result.ControlX, Result.ControlY);
    end else
  if ((Result.ControlY = 0) and (Result.AnchorY = 0)) then
    begin
      ResultNil(Result.AnchorX + Result.ControlX, 0);
    end else
  if ((Result.ControlX = 0) and (Result.AnchorX = 0)) then
    begin
      ResultNil(0, Result.AnchorY + Result.ControlY);
    end else
     ListEdges.Add(Result);
  FCurrentPos := Point(AnchorX * MultCoord, AnchorY * MultCoord);
end;

function TFlashEdges.EndEdges: TSWFEndShapeRecord;
begin
  Result := TSWFEndShapeRecord.Create;
  ListEdges.Add(Result);
end;

function TFlashEdges.FindLastChangeStyle: TSWFStyleChangeRecord;
var
  SearchState: Boolean;
  il: Word;
begin
  Result := nil;
  with ListEdges do
   if (Count>0) then
    begin
      SearchState := true;
      il := count - 1;
      while SearchState do
       begin
        if TSWFShapeRecord(Items[il]).ShapeRecType = StyleChangeRecord then
          begin
             Result := TSWFStyleChangeRecord(Items[il]);
             SearchState := false;
          end;
         if il = 0 then SearchState := false else dec(il);
       end;
    end;
end;

function TFlashEdges.GetBoundsRect: TRect;
var
  il: Word;
  rX, rY: LongInt;
  
  procedure fCompare;
  begin
    if Result.Left > rX then Result.Left := rX;
    if Result.Right < rX then Result.Right := rX;
    if Result.Top > rY then Result.Top := rY;
    if Result.Bottom < rY then Result.Bottom := rY;
  end;
  
begin
  if ListEdges.Count = 0 then Result := Rect(0,0,0,0)
   else
   begin
    With TSWFStraightEdgeRecord(ListEdges[0]) do
      Result := Rect(X, Y, X, Y);
    rX := 0;
    rY := 0;
    if ListEdges.Count > 1 then
     for il := 0 to ListEdges.Count - 1 do
      case TSWFShapeRecord(ListEdges[il]).ShapeRecType of
       StyleChangeRecord:
        With TSWFStraightEdgeRecord(ListEdges[il]) do
         begin
           rX := X;
           rY := Y;
           fCompare;
         end;
  
       StraightEdgeRecord:
        With TSWFStraightEdgeRecord(ListEdges[il]) do
         begin
           rX := rX + X;
           rY := rY + Y;
           fCompare;
         end;

       CurvedEdgeRecord:
        With TSWFCurvedEdgeRecord(ListEdges[il]) do
          begin
           rX := rX + ControlX;
           rY := rY + ControlY;
           fCompare;
           rX := rX + AnchorX;
           rY := rY + AnchorY;
           fCompare;
          end;
      end;
   end;
end;

function TFlashEdges.isClockWise: boolean;
 var il: word;
     rX1, rY1, rX2, rY2, rX3, rY3, res, acount: longint;

   function orientation(X1, Y1, X2, Y2, X3, Y3: longint): longint;
   begin
     Result := (X1 - X3)*(Y2 - Y3) - (Y1 - Y3)*(X2 - X3);
   end;

begin
 Result := true;
 acount := 0;
 if ListEdges.Count <= 2 then exit;

 for il := 0 to ListEdges.Count - 1 do
   case TSWFShapeRecord(ListEdges[il]).ShapeRecType of
       StyleChangeRecord:
        With TSWFStraightEdgeRecord(ListEdges[il]) do
         begin
           rX1 := X;
           rY1 := Y;
         end;

       StraightEdgeRecord:
        With TSWFStraightEdgeRecord(ListEdges[il]) do
         begin
           if il > 1 then
             begin
               rX3 := rX2 + X;
               rY3 := rY2 + Y;
               res := orientation(rX1, rY1, rX2, rY2, rX3, rY3);
               if res > 0 then Inc(acount) else
                 if res < 0 then dec(acount);
               rX1 := rX2;
               rY1 := rY2;
               rX2 := rX3;
               rY2 := rY3;
             end else
             begin
               rX2 := rX1 + X;
               rY2 := rY1 + Y;
             end;
         end;

       CurvedEdgeRecord:
        With TSWFCurvedEdgeRecord(ListEdges[il]) do
          begin
            if il > 1 then
             begin
               rX3 := rX2 + ControlX + AnchorX;
               rY3 := rY2 + ControlY + AnchorY;
               res := orientation(rX1, rY1, rX2, rY2, rX3, rY3);
               if res > 0 then Inc(acount) else
                 if res < 0 then dec(acount);
               rX1 := rX2;
               rY1 := rY2;
               rX2 := rX3;
               rY2 := rY3;
             end else
             begin
               rX2 := ControlX + AnchorX;
               rY2 := ControlY + AnchorY;
             end;
          end;
      end;
 Result := acount > 0;
end;

function TFlashEdges.GetMultCoord: Byte;
begin
  if IgnoreMovieSettings or (owner = nil) then Result := 1
    else Result := Owner.MultCoord;
end;

function TFlashEdges.hasAddMoveTo(DX, DY: integer): boolean;
var
  Prev: TSWFStraightEdgeRecord;
begin
 Result := true;
 if OptimizeMode and (ListEdges.Count > 0) and
    (TSWFShapeRecord(ListEdges.Items[ListEdges.Count-1]).ShapeRecType = StraightEdgeRecord) then
    begin
      Prev := TSWFStraightEdgeRecord(ListEdges.Items[ListEdges.Count-1]);
      if (Prev.X = 0) and (DX = 0) and
         (((Prev.Y < 0) and (DY < 0)) or ((Prev.Y > 0) and (DY > 0))) and
         (Abs(Prev.Y + DY) < $FFFF) then
        begin
          Result := false;
          Prev.Y := Prev.Y + DY;
        end else
      if (Prev.Y = 0) and (DY = 0) and
         (((Prev.X < 0) and (DX < 0)) or ((Prev.X > 0) and (DX > 0))) and
         (Abs(Prev.X + DX) < $FFFF) then
        begin
          Result := false;
          Prev.X := Prev.X + DX;
        end else
      if (Prev.X = DX) and (Prev.Y = DY) and (Round(Hypot(2*DX, 2*DY)) < $FFFF) then
        begin
          Result := false;
          Prev.X := Prev.X + DX;
          Prev.Y := Prev.Y + DY;
        end;
    end;
end;

function TFlashEdges.LineDelta(DX, DY: longint): TSWFStraightEdgeRecord;
var
  countX, countY, il: Byte;
  hasAdd: boolean;
begin
  Result := nil;
  if (DX = 0) and (DY = 0) then Exit;

  DX := DX * MultCoord;
  DY := DY * MultCoord;
  hasAdd := hasAddMoveTo(DX, DY);

  if hasAdd then
    begin
      // Flash noshow line large $FFFF twips. Fixed it.
      countX := Ceil(Abs(DX) / $FFFF);
      countY := Ceil(Abs(DY) / $FFFF);
      if countX < countY then countX := countY;
      for il := 1 to countX do
        begin
          Result := TSWFStraightEdgeRecord.Create;
          Result.X := Round(DX / countX * il) - Round(DX / countX * (il - 1));
          Result.Y := Round(DY / countX * il) - Round(DY / countX * (il - 1));
          ListEdges.Add(Result);
        end;
    end;
  FCurrentPos := Point(CurrentPos.X + DX, CurrentPos.Y + DY);
end;

function TFlashEdges.LineTo(X, Y: longint): TSWFStraightEdgeRecord;
var
  tmpP: TPoint;
  countX, countY, il: Byte;
  hasAdd: boolean;
  DX, DY: integer;
begin
  tmpP := point(X * MultCoord, Y * MultCoord);
  Result := nil;
  DX := tmpP.X - CurrentPos.X;
  DY := tmpP.Y - CurrentPos.Y;
  if (DX <> 0) or (DY <> 0) then
  begin
    hasAdd := hasAddMoveTo(DX, DY);

    if hasAdd then
      begin
        countX := Ceil(Abs(DX) / $FFFF);
        countY := Ceil(Abs(DY) / $FFFF);
        if countX < countY then countX := countY;
        for il := 1 to countX do
          begin
            Result := TSWFStraightEdgeRecord.Create;
            Result.X := Round((tmpP.X - CurrentPos.X) / countX * il) -
                        Round((tmpP.X - CurrentPos.X) / countX * (il - 1));
            Result.Y := Round((tmpP.Y - CurrentPos.Y) / countX * il) -
                        Round((tmpP.Y - CurrentPos.Y) / countX * (il - 1)) ;
            ListEdges.Add(Result);
          end;
      end;
    FCurrentPos := tmpP;
  end;
end;

function TFlashEdges.LineTo(P: TPoint): TSWFStraightEdgeRecord;
begin
  Result := LineTo(P.X, P.Y)
end;


procedure TFlashEdges.MakeArc(XC, YC: longInt; RadiusX, RadiusY: longint; StartAngle, EndAngle: single; closed: boolean =
        true; clockwise: boolean = true);
var
  Steps: Byte;
  il, ClckWs: Integer;
  P0, P1, P2, PStart: TPoint;
  rad, StepsA, GipX, GipY: Double;
  ChangeI: Boolean;
begin
  if clockwise then ClckWs:=1 else ClckWs:=-1;
  
  if MultCoord = twips then
   begin
     RadiusX := RadiusX * twips;
     RadiusY := RadiusY * twips;
     XC := XC * twips;
     YC := YC * twips;
     IgnoreMovieSettings := true;
     ChangeI := true;
   end else ChangeI := false;
  
  if EndAngle < StartAngle then EndAngle := EndAngle + 360;
  Steps := Ceil((EndAngle - StartAngle) / 45);
  StepsA := (EndAngle - StartAngle) / Steps;
  GipX := RadiusX / cos(DegToRad(StepsA / 2));
  GipY := RadiusY / cos(DegToRad(StepsA / 2));
  
  //  StartAngle:=StartAngle+360;
  il := 0;
  Repeat
    rad := ClckWs*DegToRad(StartAngle + (il * StepsA));
    P0.X := XC + Trunc(cos( rad ) * RadiusX);
    P0.Y := YC +Trunc(sin( rad ) * RadiusY);
    if il = 0 then
      begin
        MoveTo(P0.X, P0.Y);
        PStart := P0;
      end else
      begin
        rad := rad - ClckWs*DegToRad (StepsA / 2);
        P1.X := XC +Trunc(cos( rad ) * GipX);
        P1.Y := YC +Trunc(sin( rad ) * GipY);
        CurveDelta(P1.X - P2.X, P1.Y - P2.Y, P0.X - P1.X , P0.Y - P1.Y);
      end;
    inc(il);
    if il <= Steps then P2 := P0;
  Until il > Steps;
  
    if closed then
    LineDelta(PStart.X - P0.X, PStart.Y - P0.Y);
  
  if ChangeI then IgnoreMovieSettings := false;
    FCurrentPos.X:=P0.X div MultCoord;
    FCurrentPos.Y:=P0.Y div MultCoord;
end;

procedure TFlashEdges.MakeArc(XC, YC: longInt; Radius: longint; StartAngle, EndAngle: single; closed: boolean = true);
begin
  MakeArc(XC, YC, Radius, Radius, StartAngle, EndAngle, closed);
end;

procedure TFlashEdges.MakeCubicBezier(P1, P2, P3: TPoint; parts: byte = 4);
var
  fP0, fP1, fP2, fP3: TPoint;
  il: Byte;
  PartsStep: Single;
  CurT, NextT: TLineInfo;
  
  function getCubicDerivative(c0, c1, c2, c3: longint; t: single): longint;
   var g, b: double;
  begin
   g := 3 * (c1 - c0);
   b := (3 * (c2 - c1)) - g;
   Result := Round(3*(c3 - c0 - b - g)*t*t + 2*b*t + g);
  end;
  
  Function GetLineDef(P1, P2: TPoint): TLineInfo;
  begin
    Result.X := P1.X;
    Result.Y := P1.Y;
    if P1.X = P2.X then
      begin
        Result.isVertical := true;
        Result.a := $FFFFFFF;
      end else
      begin
        Result.a := (P1.Y - P2.Y) / (P1.X - P2.X);
        Result.b := P1.Y - (Result.a * P1.X);
        Result.isVertical := false;
      end;
  end;

  Function GetLineDef2(P, V: TPoint): TLineInfo;
  begin
    Result.X := P.X;
    Result.Y := P.Y;
    if V.X = 0 then
      begin
       Result.isVertical := true;
       Result.a := $FFFFFFF;
      end else
      begin
       Result.a := V.y / V.x;
       Result.b := P.y - (Result.a * P.X);
       Result.isVertical := false;
      end;
  end;
  
  function getCubicTangent(t: single): TLineInfo;
   var tmpP: TPoint;
  begin
    Result.X := Round(GetCubicPoint(fp0.x, fp1.x, fp2.x, fp3.x, t));
    Result.Y := Round(GetCubicPoint(fp0.y, fp1.y, fp2.y, fp3.y, t));
    tmpP.X := getCubicDerivative(fp0.x, fp1.x, fp2.x, fp3.x, t);
    tmpP.Y := getCubicDerivative(fp0.y, fp1.y, fp2.y, fp3.y, t);
    Result := GetLineDef2(Point(Result.X, Result.Y), tmpP);
  end;
  
  function GetLinesCrossing(L1, L2: TLineInfo; var Cross: TPoint): boolean;
  begin
   Result := true;
   if ((L1.isVertical and L2.isVertical)) or (L1.a = L2.a) then Result := false
     else
   if L1.isVertical then
       begin
         Cross.X := L1.X;
         Cross.Y := Round(L2.a * Cross.X + L2.b);
       end else
   if L2.isVertical then
       begin
         Cross.X := L2.X;
         Cross.Y := Round(L1.a * Cross.X + L1.b);
       end else
     begin
      Cross.X := Round((L2.b - L1.b) / (L1.a - L2.a));
      Cross.Y := Round(L1.a * Cross.X + L1.b);
     end;
  end;
  
  Function GetDistance(P1, P2: TPoint): longint;
  begin
    result := Round(Hypot(P2.X - P1.X, P2.Y - P1.Y));
  end;
  
  Procedure SliceSegment (u1, u2: double; L1, L2: TLineInfo; recurs: byte);
   var cross: TPoint;
       D: longint;
       isExit: boolean;
       uMid: double;
       LMid: TLineInfo;
  begin
   isExit := true;
   if (recurs > 10) then
    begin
     LineTo(L2.x, L2.y);
    end else
   if GetLinesCrossing(L1, L2, cross) then
     begin
       D := round(Hypot(L2.X - L1.X, L2.Y - L1.Y));
       isExit := not ((D < GetDistance(Point(L1.X, L1.Y), cross)) or (D < GetDistance(Point(L2.X, L2.Y), cross)));
     end else isExit := false;
  
   if not isExit then
     begin
       uMid := (u1 + u2) / 2;
       LMid := getCubicTangent(uMid);
       SliceSegment(u1, uMid, L1, LMid, recurs+1);
       SliceSegment(uMid, u2, LMid, L2, recurs+1);
     end else CurveTo(cross.X, cross.Y, L2.X, L2.Y);
  end;
  
begin
  fP0 := CurrentPos;
  
  fP1.X := P1.X * MultCoord;
  fP1.Y := P1.Y * MultCoord;
  fP2.X := P2.X * MultCoord;
  fP2.Y := P2.Y * MultCoord;
  fP3.X := P3.X * MultCoord;
  fP3.Y := P3.Y * MultCoord;
  
  if MultCoord = twips then IgnoreMovieSettings := true;
  
  if parts < 1 then parts := 1;
  PartsStep := 1/parts;
  CurT := GetLineDef(fP0, fP1);
  CurT.X := fP0.X;
  CurT.Y := fP0.Y;
  
  for il := 1 to parts do
    begin
     nextT := getCubicTangent( il*PartsStep);
     SliceSegment((il-1)*PartsStep, il*PartsStep, curT, nextT, 0);
     curT := nextT;
    end;
  
   IgnoreMovieSettings := false;
end;

procedure TFlashEdges.MakeDiamond(W, H: longint);
begin
  if MultCoord = twips then
    begin
      W := W * twips;
      H := H * twips;
      IgnoreMovieSettings := true;
    end;
  
  LineDelta(W div 2, H div 2);
  LineDelta(- W div 2, H div 2);
  LineDelta(- W div 2, - H div 2);
  LineDelta(W div 2, - H div 2);

  IgnoreMovieSettings := false;
end;

procedure TFlashEdges.MakeEllipse(W, H: longint);
var
  il: Byte;
begin
  if MultCoord = twips then
    begin
      W := W * twips;
      H := H * twips;
      IgnoreMovieSettings := true;
    end;
  
  MoveDelta(W, H div 2);
  
  for il := 0 to 7 do
     if not Odd(il) then
       CurveDelta( Trunc(CEllipse3[il, 0] * CEllipse2 * W), Trunc(CEllipse3[il, 1] * CEllipse2 * H),
                 Trunc(CEllipse3[il, 2] * CEllipse1 * W), Trunc(CEllipse3[il, 3] * CEllipse1 * H))
      else
       CurveDelta( Trunc(CEllipse3[il, 0] * CEllipse1 * W), Trunc(CEllipse3[il, 1] * CEllipse1 * H),
                 Trunc(CEllipse3[il, 2] * CEllipse2 * W), Trunc(CEllipse3[il, 3] * CEllipse2 * H));
  
  IgnoreMovieSettings := false;
end;

procedure TFlashEdges.MakeMirror(Horz, Vert: boolean);
var
  il: Word;
begin
  if ListEdges.Count > 0 then
   for il := 0 to ListEdges.Count - 1 do
   case TSWFShapeRecord(ListEdges[il]).ShapeRecType of
    StyleChangeRecord, StraightEdgeRecord:
     With TSWFStraightEdgeRecord(ListEdges[il]) do
      begin
       if Horz then X := - X;
       if Vert then Y := - Y;
      end;
    CurvedEdgeRecord:
     With TSWFCurvedEdgeRecord(ListEdges[il]) do
       begin
         if Horz then
           begin
            ControlX := - ControlX;
            AnchorX := - AnchorX;
           end;
         if Vert then
           begin
            ControlY := - ControlY;
            AnchorY := - AnchorY;
           end;
       end;
   end;
end;

procedure TFlashEdges.MakePie(Radius: longint; StartAngle, EndAngle: single);
begin
  MakePie(Radius, Radius, StartAngle, EndAngle);
end;

procedure TFlashEdges.MakePie(RadiusX, RadiusY: longint; StartAngle, EndAngle: single; clockwise: boolean = true);
var
  Steps: Byte;
  il, ClckWs: Integer;
  P0, P1, P2: TPoint;
  rad, StepsA, GipX, GipY: Double;
begin
  if clockwise then ClckWs:=1 else ClckWs:=-1;
  if MultCoord = twips then
   begin
     RadiusY := RadiusY * twips;
     RadiusX := RadiusX * twips;
     IgnoreMovieSettings := true;
   end;
  
  if EndAngle < StartAngle then EndAngle := EndAngle + 360;
  Steps := Ceil((EndAngle - StartAngle) / 45);
  if Steps = 0 then Steps := 1;
  StepsA := (EndAngle - StartAngle) / Steps;
  GipX := RadiusX / cos(DegToRad(StepsA / 2));
  GipY := RadiusY / cos(DegToRad(StepsA / 2));
  
  il := 0;
  Repeat
    rad := ClckWs*DegToRad(StartAngle + (il * StepsA));
    P0.X := Trunc(cos( rad ) * RadiusX);
    P0.Y:= Trunc(sin( rad ) * RadiusY);
    if il = 0 then LineDelta(P0.X, P0.Y) else
      begin
        rad := rad - ClckWs*DegToRad (StepsA / 2);
        P1.X := Trunc(cos( rad ) * GipX);
        P1.Y := Trunc(sin( rad ) * GipY);
        CurveDelta(P1.X - P2.X, P1.Y - P2.Y, P0.X - P1.X , P0.Y - P1.Y);
      end;
    inc(il);
    if il <= Steps then P2 := P0;
  Until il > Steps;

  LineDelta(- P0.X, -P0.Y);
  
  IgnoreMovieSettings := false;
end;

procedure TFlashEdges.MakePolyBezier(AP: array of TPoint; Start: TPoint);
var
  i, j, l: Integer;
//  p: Cardinal;
begin
  if (Start.X = -1) and (Start.Y = -1) Then
  begin
    if (CurrentPos.X <> Start.X) or (CurrentPos.Y <> Start.Y) then
      MoveTo(AP[Low(AP)].X, AP[Low(AP)].Y);
    l := 1;
  end else
  begin
    if (CurrentPos.X <> Start.X) or (CurrentPos.Y <> Start.Y) then
          MoveTo(Start.X, Start.Y);
    l := 0;
  end;
  for i:=Low(AP) to ((High(AP)+1-l) div 3)-1 do
  begin
  {
    p := ABS(AP[l+3*i].X - Start.X) + ABS(AP[l+3*i].Y - Start.Y) +
         ABS(AP[l+1+3*i].X - AP[l+3*i].X) + ABS(AP[l+1+3*i].Y - AP[l+3*i].Y) +
         ABS(AP[l+2+3*i].X - AP[l+1+3*i].X) + ABS(AP[l+2+3*i].Y - AP[l+1+3*i].Y);
    p := (p div 50) + 1; }
    MakeCubicBezier(AP[l+3*i], AP[l+1+3*i], AP[l+2+3*i]{, p});
  end;
  i:=(High(AP)+1-l) div 3; j:=0;
  while (I*3+j)<=High(AP) do
  begin
    LineTo(AP[i*3+j].X, AP[3*i+j].Y);
    inc(j);
  end;
end;

procedure TFlashEdges.MakePolyline(AP: array of TPoint);
var
  il: Integer;
begin
  For il := low(AP) to High(AP) do
    if il = low(AP)
      then MoveTo(AP[il].X, AP[il].Y)
      else LineTo(AP[il].X, AP[il].Y);
end;

procedure TFlashEdges.MakeRectangle(W, H: longint);
begin
  LineDelta(W, 0);
  LineDelta(0, H);
  LineDelta(-W, 0);
  LineDelta(0, -H);
end;

procedure TFlashEdges.MakeRoundRect(W, H, R: longint);
var
  il: Byte;
  D: LongInt;
begin
  if MultCoord = twips then
   begin
     W := W * twips;
     H := H * twips;
     R := R * twips;
     IgnoreMovieSettings := true;
   end;
  
  D := 2 * R;
  MoveDelta(W, R);
  
  for il := 0 to 7 do
    begin
     Case il of
      0: LineDelta(0, H - D);
      2: LineDelta(- (W - D), 0);
      4: LineDelta(0, -(H - D));
      6: LineDelta(W - 2 * R, 0);
     end;
  
     if not Odd(il) then
       CurveDelta( Trunc(CEllipse3[il, 0] * CEllipse2 * D), Trunc(CEllipse3[il, 1] * CEllipse2 * D),
                 Trunc(CEllipse3[il, 2] * CEllipse1 * D), Trunc(CEllipse3[il, 3] * CEllipse1 * D))
      else
       CurveDelta( Trunc(CEllipse3[il, 0] * CEllipse1 * D), Trunc(CEllipse3[il, 1] * CEllipse1 * D),
                 Trunc(CEllipse3[il, 2] * CEllipse2 * D), Trunc(CEllipse3[il, 3] * CEllipse2 * D));
    end;
  
  IgnoreMovieSettings := false;
end;

procedure TFlashEdges.MakeRoundRect(W, H, RX, RY: longint);
var
  il: Byte;
  DX, DY: LongInt;
begin
  if MultCoord = twips then
   begin
     W := W * twips;
     H := H * twips;
     RX := RX * twips;
     RY := RY * twips;
     IgnoreMovieSettings := true;
   end;
  
  DX := 2 * RX;
  DY := 2 * RY;
  MoveDelta(W, RY);
  
  for il := 0 to 7 do
    begin
     Case il of
      0: LineDelta(0, H - DY);
      2: LineDelta(- (W - DX), 0);
      4: LineDelta(0, -(H - DY));
      6: LineDelta(W - DX, 0);
     end;
  
     if not Odd(il) then
       CurveDelta( Trunc(CEllipse3[il, 0] * CEllipse2 * DX), Trunc(CEllipse3[il, 1] * CEllipse2 * DY),
                 Trunc(CEllipse3[il, 2] * CEllipse1 * DX), Trunc(CEllipse3[il, 3] * CEllipse1 * DY))
      else
       CurveDelta( Trunc(CEllipse3[il, 0] * CEllipse1 * DX), Trunc(CEllipse3[il, 1] * CEllipse1 * DY),
                 Trunc(CEllipse3[il, 2] * CEllipse2 * DX), Trunc(CEllipse3[il, 3] * CEllipse2 * DY));
    end;
  
  IgnoreMovieSettings := false;
end;

procedure TFlashEdges.MakeStar(X, Y, R1, R2: longint; NumPoint: word; curve: boolean = false);
var
  il, ilc: Integer;
  acur, aStep: Double;
  PX, PY, cPX, cPY: LongInt;
begin
  if MultCoord = twips then
   begin
     X := X * twips;
     Y := Y * twips;
     R1 := R1 * twips;
     R2 := R2 * twips;
     IgnoreMovieSettings := true;
   end;
  
  if NumPoint < 2 then ilc := 2 else
    if NumPoint > 360 then ilc := 360 else ilc := NumPoint;
  
  acur := - pi / 2;
  aStep := pi * 2 / ilc;

  MoveTo(X + Round(R1 * cos(acur)), Y + Round(R1 * sin(acur)));
  
  for il := 1 to ilc do
    begin
     cPX := X + Round(R2 * cos(acur + aStep / 2));
     cPY := Y + Round(R2 * sin(acur + aStep / 2));
     acur := acur + aStep;
     PX := X + Round(R1 * cos(acur));
     PY := Y + Round(R1 * sin(acur));
     if curve then CurveTo(cPX, cPY, PX, PY) else
       begin
         LineTo(cPX, cPY);
         LineTo(PX, PY);
       end;
    end;
  
  IgnoreMovieSettings := false;
end;

function TFlashEdges.MoveDelta(X, Y: longint): TSWFStyleChangeRecord;
begin
  Result := AddChangeStyle;
  if (X<>0) or (Y<>0) then
    begin
     FCurrentPos := Point(CurrentPos.X + X * MultCoord, FCurrentPos.Y + Y * MultCoord);
     Result.X := CurrentPos.X;
     Result.Y := CurrentPos.Y;
     Result.stateMoveTo := true;
     FLastStart := CurrentPos;
    end;
end;

function TFlashEdges.MoveTo(X, Y: longint): TSWFStyleChangeRecord;
begin
  Result := AddChangeStyle;
  if (X<>CurrentPos.X) or (Y<>CurrentPos.Y) or (ListEdges.Count>1) then
    begin
     FCurrentPos := Point(X * MultCoord, Y * MultCoord);
     Result.X := FCurrentPos.X;
     Result.Y := FCurrentPos.Y;
     Result.stateMoveTo := true;
     FLastStart := CurrentPos;
    end;
end;

procedure TFlashEdges.OffsetEdges(DX, DY: LongInt; UseSysCoord: boolean = true);
var
  il: Word;
  mult: byte;
begin
  if UseSysCoord then mult := MultCoord
    else mult := 1;

  if ListEdges.Count > 0 then
   for il := 0 to ListEdges.Count - 1 do
   case TSWFShapeRecord(ListEdges[il]).ShapeRecType of
    StyleChangeRecord:
     With TSWFStraightEdgeRecord(ListEdges[il]) do
      begin
       X := X + DX * mult;
       Y := Y + DY * mult;
      end;
  end;
end;

function TFlashEdges.StartNewStyle: TSWFStyleChangeRecord;
begin
  Result := AddChangeStyle;
  Result.StateFillStyle1 := true;
end;

function TFlashEdges.StartNewStyle(MoveToX, MoveToY: longint): TSWFStyleChangeRecord;
begin
  Result := MoveTo(MoveToX, MoveToY);
  Result.StateFillStyle1 := true;
end;

{
****************************************************** TFlashLineStyle ******************************************************
}
constructor TFlashLineStyle.Create;
begin
  Items := TList.Create;
end;

destructor TFlashLineStyle.Destroy;
begin
  Items.Free;
  inherited;
end;

function TFlashLineStyle.GetCount: Byte;
begin
  Result := Items.Count;
end;

function TFlashLineStyle.GetLen(Index: Integer): Byte;
begin
  Result := Longint(Items[Index]);
end;

procedure TFlashLineStyle.SetCount(Value: Byte);
begin
  While Items.Count < Value do Items.Add(nil);
  While Items.Count > Value do Items.Delete(Items.Count - 1);
end;

procedure TFlashLineStyle.SetLen(Index: Integer; Value: Byte);
begin
  Items[Index] := Pointer(LongInt(Value));
end;

procedure TFlashLineStyle.SetStyle(A: array of byte);
var
  il: Byte;
begin
  Count := High(A) - Low(A) + 1;
  for il := Low(A) to High(A) do  Len[il] := A[il];
end;

type
 TCurveRec = record
   crP0, crP1, crP2, crPC, crP1c: TPoint;
   cru, crdu: double;
   crAx, crBx, crCx, crAy, crBy, crCy: Integer;
   crExitFlag: Integer;
 end;  
{
******************************************************** TFlashShape ********************************************************
}
constructor TFlashShape.Create(owner: TFlashMovie);
begin
  inherited;
  EdgesStore := TObjectList.Create;
  LineStyles := TObjectList.Create;
  FillStyles := TObjectList.Create;

  FEdges := TFlashEdges.Create(EdgesStore);
  FEdges.Owner := owner;
  FBounds := TSWFRect.Create;
  hasAlpha := false;
  IgnoreMovieSettings := false;
  ExtLineTransparent := true;
  StyleChangeMode := scmFirst;
  hasUseAdvancedStyles := false;
end;

destructor TFlashShape.Destroy;
begin
  EdgesStore.Free;
  LineStyles.Free;
  FillStyles.Free;

  FExtLineStyle.Free;
//  FShape.Free;
  FBounds.Free;
  FEdges.Free;
  if Assigned(FLineBgColor) then FreeAndNil(FLineBgColor);
  inherited;
end;

function TFlashShape.AddChangeStyle: TSWFStyleChangeRecord;
begin
  With GetListEdges do
  if (Count > 0) and
   (TSWFShapeRecord(Items[Count-1]).ShapeRecType = StyleChangeRecord)
      then
        Result := TSWFStyleChangeRecord(Items[Count-1])
      else
      begin
        Result := TSWFStyleChangeRecord.Create;
        Add(Result);
      end;
end;

function TFlashShape.AddFillStyle(fill: TSWFFillStyle): TSWFFillStyle;
begin
  Result := fill;
  if FillStyles.IndexOf(Result) = -1
    then FillStyleNum := FillStyles.Add(Result) + 1
    else FillStyleNum := FillStyles.IndexOf(Result) + 1;
end;

function TFlashShape.AddLineStyle(outline: TSWFLineStyle = nil): TSWFLineStyle;
begin
  if outline = nil then Result := TSWFLineStyle.Create else Result := outline;
  if LineStyles.IndexOf(Result) = -1
    then LineStyleNum := LineStyles.Add(Result) + 1
    else LineStyleNum := LineStyles.IndexOf(Result) + 1;
end;

procedure TFlashShape.Assign(Source: TBasedSWFObject);
begin
  inherited;
  With TFlashShape(Source) do
  begin
    self.FillStyleLeft := FillStyleLeft;
    self.FillStyleRight := FillStyleRight;
    self.LineStyleNum := LineStyleNum;
//    self.fShape.Assign(fShape);
//  todo
    self.hasAlpha := hasAlpha;
  end;
end;

procedure TFlashShape.CalcBounds;
begin
  Bounds.Rect := Edges.GetBoundsRect;
end;

procedure TFlashShape.ChangeOwner;
begin
  Edges.Owner := Owner;
end;

function TFlashShape.FindLastChangeStyle: TSWFStyleChangeRecord;
var
  SearchState: Boolean;
  il: Word;
begin
  Result := nil;
  with GetListEdges do
   if (Count>0) then
    begin
      SearchState := true;
      il := count - 1;
      while SearchState do
       begin
        if TSWFShapeRecord(Items[il]).ShapeRecType = StyleChangeRecord then
          begin
             Result := TSWFStyleChangeRecord(Items[il]);
             SearchState := false;
          end;
         if il = 0 then SearchState := false else dec(il);
       end;
    end;
end;

function TFlashShape.GetCenterX: LongInt;
begin
  result := fXCenter div MultCoord;
end;

function TFlashShape.GetCenterY: LongInt;
begin
  result := fYCenter div MultCoord;
end;

function TFlashShape.GetExtLineStyle: TFlashLineStyle;
begin
  if FExtLineStyle = nil then FExtLineStyle := TFlashLineStyle.Create;
  HasExtLineStyle := true;
  Result := FExtLineStyle;
end;

function TFlashShape.GetLineBgColor: TSWFRGBA;
begin
  if FLineBgColor = nil then
   begin
     FLineBgColor := TSWFRGBA.Create(true);
     ExtLineTransparent := false;
   end;
  Result := FLineBgColor;
end;

function TFlashShape.GetHeight(inTwips: boolean = true): LongInt;
begin
  Result := Ymax - YMin;
  if inTwips then Result := Result * MultCoord;
end;

function TFlashShape.GetListEdges: TObjectList;
begin
  Result := EdgesStore;
end;

function TFlashShape.GetWidth(inTwips: boolean = true): LongInt;
begin
  Result := Xmax - XMin;
  if inTwips then Result := Result * MultCoord;
end;

function TFlashShape.GetXMax: Integer;
begin
  Result := Bounds.XMax div MultCoord;
end;

function TFlashShape.GetXMin: Integer;
begin
  Result := Bounds.XMin div MultCoord;
end;

function TFlashShape.GetYMax: Integer;
begin
  Result := Bounds.YMax div MultCoord;
end;

function TFlashShape.GetYMin: Integer;
begin
  Result := Bounds.YMin div MultCoord;
end;

procedure TFlashShape.MakeMirror(Horz, Vert: boolean);
begin
  Edges.MakeMirror(Horz, Vert);
end;

function TFlashShape.MinVersion: Byte;
begin
  Result := SWFVer2 + byte(hasAlpha);
end;

procedure TFlashShape.SetCenterX(X: LongInt);
var
  delta: LongInt;
begin
  delta := X * MultCoord - fXCenter;
  Edges.OffsetEdges(delta, 0, false);
  fXCenter := X * MultCoord
end;

procedure TFlashShape.SetCenterY(Y: LongInt);
var
  delta: LongInt;
begin
  delta := Y * MultCoord - fYCenter;
  Edges.OffsetEdges(0, delta, false);
  fYCenter := Y * MultCoord
end;

procedure TFlashShape.SetFillStyleLeft(n: Word);
var
  R: TSWFStyleChangeRecord;
begin
  R := nil;
  if StyleChangeMode = scmFirst then
   With GetListEdges do
    begin
     if (Count > 0) and
       (TSWFShapeRecord(Items[0]).ShapeRecType = StyleChangeRecord) then
       R := TSWFStyleChangeRecord(Items[0]);
    end else
     R := FindLastChangeStyle;
  
  if R = nil then fFillStyleLeft := 0
    else
    begin
      fFillStyleLeft := n;
      R.StateFillStyle0 := true;
      R.Fill0Id := n;
    end;
end;

procedure TFlashShape.SetFillStyleRight(n: Word);
var
  R: TSWFStyleChangeRecord;
begin
  R := nil;
  if StyleChangeMode = scmFirst then
   with GetListEdges do
    begin
     if (Count > 0) and
       (TSWFShapeRecord(EdgesStore[0]).ShapeRecType = StyleChangeRecord) then
       R := TSWFStyleChangeRecord(Items[0]);
    end else
     R := FindLastChangeStyle;
  
  if R = nil then fFillStyleRight := 0
    else
    begin
      fFillStyleRight := n;
      R.StateFillStyle1 := true;
      R.Fill1Id := n;
    end;
end;


function TFlashShape.SetImageFill(img: TFlashImage; mode: TFillImageMode; ScaleX: single = 1; ScaleY: single = 1):
        TSWFImageFill;
var
  adds, XSc, YSc: Single;
  offset: byte;
begin

  Result := TSWFImageFill.Create;
  Result.ImageID := img.CharacterID;

  // adds & (twips div 4) - values for fixed visual bag of flash 6, 7. non document
  if (owner <> nil) and (Owner.CorrectImageFill) then
    begin
      adds := $f0 / specFixed;
      offset := twips div 4;
    end else
    begin
      adds := 0;
      offset := 0;
    end;
    
  case mode of
    fmFit: begin
             Result.SWFFillType := SWFFillClipBitmap;
             Result.Matrix.SetTranslate(Bounds.Xmin - offset, Bounds.Ymin - offset);
             XSc := GetWidth/img.Width + adds;
             YSc := GetHeight/img.Height + adds;
             if XSc > ($FFFF div 4) then XSc := ($FFFF div 4);
             if YSc > ($FFFF div 4) then YSc := ($FFFF div 4);
             Result.Matrix.SetScale(XSc, YSc);
            end;
    fmClip: begin
             Result.SWFFillType := SWFFillClipBitmap;
             Result.Matrix.SetTranslate(Bounds.Xmin - offset, Bounds.Ymin - offset);
             Result.Matrix.SetScale(ScaleX * twips, ScaleY * twips);
            end;
    fmTile:begin
             Result.SWFFillType := SWFFillTileBitmap;
             Result.Matrix.SetTranslate(Bounds.Xmin - offset, Bounds.Ymin - offset);
             Result.Matrix.SetScale(ScaleX * twips, ScaleY * twips);
           end;
   end;
  AddFillStyle(Result);

  if owner <> nil then
   with owner.ObjectList do
    if IndexOf(img) > IndexOf(self) then
      Move(IndexOf(img), IndexOf(self));
end;

function TFlashShape.SetLinearGradient(Gradient: array of recRGBA; angle: single = 0): TSWFGradientFill;
var
  il: Byte;
  r, kX, kY: Double;
begin
  Result := TSWFGradientFill.Create;
  Result.Count := High(Gradient) - Low(Gradient) + 1;
  For il:=1 to Result.count do
    begin
     Result.GradientColor[il].RGBA := Gradient[Low(Gradient) + il - 1];
     if Result.GradientColor[il].A < $FF then hasAlpha := true;
     Result.GradientRatio[il] := Round((il - 1) / (Result.count - 1) * $FF);
    end;
  
  r := DegToRad(angle);
  kX := GetWidth /GradientSizeXY;
  kY := GetHeight/GradientSizeXY;
  Result.Matrix.SetScale(kX*cos(r), kY*cos(r));
  Result.Matrix.SetSkew(kX*sin(r), -kY*sin(r));
  Result.Matrix.SetTranslate(Bounds.Xmin + GetWidth div 2, Bounds.Ymin + GetHeight div 2);
  
  AddFillStyle(Result);
end;

function TFlashShape.SetLinearGradient(Gradient: array of TSWFGradientRec; angle: single = 0): TSWFGradientFill;
var
  il: Byte;
  r, kX, kY: Double;
begin
  Result := TSWFGradientFill.Create;
  Result.Count := High(Gradient) - Low(Gradient) + 1;
  if Result.Count > 8 then Result.Count := 8;
  For il:=1 to Result.Count do
    begin
     Result.GradientColor[il].RGBA := Gradient[Low(Gradient) + il - 1].Color;
     Result.GradientRatio[il] := Gradient[Low(Gradient) + il - 1].Ratio;
     if Result.GradientColor[il].A < $FF then hasAlpha := true;
    end;
  
  r := DegToRad(angle);
  kX := GetWidth /GradientSizeXY;
  kY := GetHeight/GradientSizeXY;
  Result.Matrix.SetScale(kX*cos(r), kY*cos(r));
  Result.Matrix.SetSkew(kX*sin(r), -kY*sin(r));
  Result.Matrix.SetTranslate(Bounds.Xmin + GetWidth div 2, Bounds.Ymin + GetHeight div 2);
  
  AddFillStyle(Result);
end;

function TFlashShape.SetLinearGradient(C1, C2: recRGBA; angle: single = 0): TSWFGradientFill;
var
  Gradient: array [0..1] of recRGBA;
begin
  Gradient[0] := C1;
  Gradient[1] := C2;
  result := SetLinearGradient(Gradient, angle);
end;

function TFlashShape.SetLineStyle(width: word; c: recRGB): TSWFLineStyle;
begin
  Result := SetLineStyle(width, SWFRGBA(c, $ff));
end;

function TFlashShape.SetLineStyle(width: word; c: recRGBA): TSWFLineStyle;
begin
  Result := AddLineStyle;
  Result.Width := width * MultCoord;
  Result.Color.RGBA := c;
  if C.A < $FF then hasAlpha := true;
end;

function TFlashShape.SetAdvancedLineStyle(width: word; c: recRGBA; CapStyle:
    byte = 0; JoinStyle: byte = 0): TSWFLineStyle2;
begin
  Result := TSWFLineStyle2.Create;
  Result.Width := width * MultCoord;
  Result.Color.RGBA := c;
  hasAlpha := true;
  hasUseAdvancedStyles := true;
  LineStyleNum := LineStyles.Add(Result) + 1;
end;

procedure TFlashShape.SetLineStyleNum(n: Word);
var
  R: TSWFStyleChangeRecord;
begin
  R := nil;
  if StyleChangeMode = scmFirst then
    begin
     with GetListEdges do
       if (Count > 0) and
         (TSWFShapeRecord(Items[0]).ShapeRecType = StyleChangeRecord) then
         R := TSWFStyleChangeRecord(Items[0]);
    end
    else R := FindLastChangeStyle;
  
  if R = nil then fLineStyleNum := 0
    else
    begin
      fLineStyleNum := n;
      R.StateLineStyle := true;
      R.LineId := n;
    end;
end;

function TFlashShape.SetRadialGradient(Gradient: array of recRGBA; Xc, Yc: byte): TSWFGradientFill;
var
  il: Byte;
  kX, kY: Double;
begin
  Result := TSWFGradientFill.Create;
  Result.SWFFillType := SWFFillRadialGradient;
  Result.Count := High(Gradient) - Low(Gradient) + 1;
  if Result.Count > 8 then Result.Count := 8;
  For il:=1 to Result.count do
    begin
     Result.GradientColor[il].RGBA := Gradient[Low(Gradient) + il - 1];
     if Result.GradientColor[il].A < 255 then self.hasAlpha := true;
     Result.GradientRatio[il] := Round((il - 1) / (Result.count - 1) * $FF);
    end;
  kX := GetWidth /GradientSizeXY;
  kY := GetHeight/GradientSizeXY;
  
  Result.Matrix.SetScale(kX, kY);
  Result.Matrix.SetTranslate(Bounds.Xmin + Round(GetWidth / 100 * Xc),
                             Bounds.Ymin + Round(GetHeight / 100 * Yc));
  AddFillStyle(Result);
end;

function TFlashShape.SetRadialGradient(C1, C2: recRGBA; Xc, Yc: byte): TSWFGradientFill;
var
  Gradient: array [0..1] of recRGBA;
begin
  Gradient[0] := C1;
  Gradient[1] := C2;
  Result := SetRadialGradient(Gradient, Xc, Yc);
end;

function TFlashShape.SetFocalGradient(Gradient: array of recRGBA; FocalPoint: single;
           InterpolationMode: TSWFInterpolationMode; SpreadMode: TSWFSpreadMode): TSWFFocalGradientFill;
var
  il: Byte;
begin
  Result := TSWFFocalGradientFill.Create;
  Result.Count := High(Gradient) - Low(Gradient) + 1;
  if Result.Count > 8 then Result.Count := 8;
  For il:=1 to Result.count do
    begin
     Result.GradientColor[il].RGBA := Gradient[Low(Gradient) + il - 1];
     if Result.GradientColor[il].A < 255 then self.hasAlpha := true;
     Result.GradientRatio[il] := Round((il - 1) / (Result.count - 1) * $FF);
    end;
  Result.FocalPoint := FocalPoint;
  Result.InterpolationMode := InterpolationMode;
  Result.SpreadMode := SpreadMode;
  AddFillStyle(Result);
  hasUseAdvancedStyles := true;
end;

function TFlashShape.SetFocalGradient(Color1, Color2: recRGBA; FocalPoint: single;
           InterpolationMode: TSWFInterpolationMode; SpreadMode: TSWFSpreadMode): TSWFGradientFill;
var
  Gradient: array [0..1] of recRGBA;
begin
  Gradient[0] := Color1;
  Gradient[1] := Color2;
  Result := SetFocalGradient(Gradient, FocalPoint, InterpolationMode, SpreadMode);
end;

procedure TFlashShape.SetShapeBound(XMin, YMin, XMax, YMax: integer);
begin
  Bounds.Rect := Rect(XMin * MultCoord, YMin * MultCoord,
                      XMax * MultCoord, YMax * MultCoord);
end;

function TFlashShape.SetSolidColor(r, g, b, a: byte): TSWFColorFill;
begin
  Result := SetSolidColor(SWFRGBA(r, g, b, a));
end;

function TFlashShape.SetSolidColor(c: recRGB): TSWFColorFill;
begin
  Result := SetSolidColor(SWFRGBA(c, $ff));
end;

function TFlashShape.SetSolidColor(c: recRGBA): TSWFColorFill;
begin
  if C.A < 255 then hasAlpha := true;
  Result := TSWFColorFill.Create;
  Result.Color.RGBA := c;
  AddFillStyle(Result);
end;

procedure TFlashShape.SetXMax(Value: Integer);
begin
  Bounds.XMax := Value * MultCoord;
end;

procedure TFlashShape.SetXMin(Value: Integer);
begin
  Bounds.XMin := Value * MultCoord;
end;

procedure TFlashShape.SetYMax(Value: Integer);
begin
  Bounds.YMax := Value * MultCoord;
end;

procedure TFlashShape.SetYMin(Value: Integer);
begin
  Bounds.YMin := Value * MultCoord;
end;

procedure TFlashShape.WriteToStream(be: TBitsEngine);
var
  LostSegment: Integer;
  MaxW, il, NewLineID: Word;
  SegmentNum: Cardinal;
  OldList, NewList: TObjectList;
  AbsLen, SegmentLen, CurentLen: LongInt;
  SCR: TSWFStyleChangeRecord;
  SER: TSWFStraightEdgeRecord;
  SCvR: TSWFCurvedEdgeRecord;
  DrawFlag: Boolean;
  NewPT, LastMT: TPoint;
  CurveRec: TCurveRec;
  PrevPT: TPoint;
  fShape: TSWFDefineShape;
  fShape3: TSWFDefineShape3;
  fShape4: TSWFDefineShape4;
  LS2: TSWFLineStyle2;


{$IFDEF VER130}  // Delphi 5
   procedure CopyList(From, Dest: TObjectList);
    var il: integer;
   begin
     if From.Count > 0 then
       for il := 0 to From.Count - 1 do
         Dest.Add(From[il]);
   end;
{$ENDIF}
  
  function SearchCurvePos(S:Integer; var CR:TCurveRec):TPoint;
  var
   Delta: double;
   P: TPoint;
   Sum, MyMod: Integer;
  
   B0x, B0y, B2x, B2y: double;
   uP: double;
  begin
    with CR do
    begin
      S:=S*S; MyMod:=S;
      Sum:=1;
      repeat
        Delta:= (S-MyMod)/crBx;
        if Abs(Delta) < 0.01/Sum then Delta := (0.01/Sum)*Sign(Delta);
  
        crdu:=crdu+Delta;
        Delta:=cru+crdu;
        if Delta>1 then
        begin
          Delta:=1;
          P:=crP2;
          crExitFlag:=Round(SQRT(S)-SQRT((P.X-crPC.X)*(P.X-crPC.X)+(P.Y-crPC.Y)*(P.Y-crPC.Y)));
        end;
        P.X:=Round((crAx*Delta+2*crP1.X)*Delta);
        P.Y:=Round((crAy*Delta+2*crP1.Y)*Delta);
        MyMod:=(P.X-crPC.X)*(P.X-crPC.X)+(P.Y-crPC.Y)*(P.Y-crPC.Y);
        inc(Sum);
        IF Boolean(crExitFlag) and (MyMod>S) then crExitFlag:=0;
      until (Abs(MyMod-S) < 50) or (Sum > 100);
      crCx:=P.X-crPC.X; crCy:=P.Y-crPC.Y;
      B0x:=2*(crAx*cru+crP1.X); B0y:=2*(crAy*cru+crP1.Y);
      B2x:=2*(crAx*Delta+crP1.X); B2y:=2*(crAy*Delta+crP1.Y);
  
      if (B0x=B2x) then crP1c.X := 0 else
        begin
          uP:=(crCx-B2x*(Delta-cru))/(B0x-B2x);
          crP1c.X:=Round(B0x*uP);
        end;
      if (B0y=B2y) then crP1c.Y := 0 else
        begin
         uP:=(crCy-B2y*(Delta-cru))/(B0y-B2y);
         crP1c.Y:=Round(B0y*uP);
        end;
      cru:=cru+crdu;
      Result:=P;
    end;
  end;

begin
  MaxW := 0;
  if LineStyles.Count > 0 then
   for il := 0 to LineStyles.Count - 1 do
    with TSWFLineStyle(LineStyles[il]) do
     if MaxW < Width then MaxW := Width;

  if hasUseAdvancedStyles then
    begin
      fShape4 := TSWFDefineShape4.Create;
      if LineStyles.Count > 0 then
       for il := 0 to LineStyles.Count - 1 do
        begin
          LS2 := TSWFLineStyle2.Create;
          if LineStyles[il] is TSWFLineStyle2 then
            begin
              LS2.Assign(TSWFLineStyle2(LineStyles[il]));
            end else
            with TSWFLineStyle(LineStyles[il]) do
             begin
               LS2.Width := Width;
               LS2.Color.Assign(Color);
             end;
          fShape4.LineStyles.Add(LS2);
        end;
      fShape4.EdgeBounds.Assign(Bounds);
      fShape := fShape4;
    end else
    begin
      fShape3 := TSWFDefineShape3.Create;
      if hasAlpha then fShape3.TagID := tagDefineShape3
        else fShape3.TagID := tagDefineShape2;
      if LineStyles.Count > 0 then
        begin
          fShape3.LineStyles.OwnsObjects := false;
{$IFDEF VER130}
          CopyList(LineStyles, fShape3.LineStyles);
{$ELSE}
          fShape3.LineStyles.Assign(LineStyles);
{$ENDIF}
        end;
      fShape := fShape3;
    end;

  fShape.ShapeId := FCharacterId;
  fShape.hasAlpha := hasAlpha;

  if FillStyles.Count > 0 then
   begin
     fShape.FillStyles.OwnsObjects := false;
{$IFDEF VER130}
     CopyList(FillStyles, fShape.FillStyles);
{$ELSE}
     fShape.FillStyles.Assign(FillStyles);
{$ENDIF}
   end;

  fShape.ShapeBounds.Rect := Rect(Bounds.Xmin - MaxW div 2, Bounds.Ymin - MaxW div 2,
                                  Bounds.Xmax + MaxW div 2, Bounds.Ymax + MaxW div 2);

  if HasExtLineStyle and (fShape.LineStyles.Count > 0) then
    begin
      OldList := EdgesStore;      //fShape.Edges;
      NewList := fShape.Edges;   //TObjectList.Create;

      if not ExtLineTransparent then
        begin
         with AddLineStyle(nil) do
          begin
           Width := TSWFLineStyle(fShape.LineStyles[0]).Width;
           Color.Assign(LineBgColor);
          end;
         LineStyleNum := LineStyleNum - 1;
        end;

         // is closed shape
      if (OldList.Count > 0) and (fShape.FillStyles.Count > 0)
          and (Edges.LastStart.X = Edges.CurrentPos.X)
          and (Edges.LastStart.Y = Edges.CurrentPos.Y) then
        begin
          CopyShapeRecords(OldList, NewList);

          for il := 0 to NewList.Count - 1 do
            if TSWFShapeRecord(NewList[il]).ShapeRecType = StyleChangeRecord then
              with TSWFStyleChangeRecord(NewList[il]) do
               if StateLineStyle and (LineId > 0) then
                  LineId := 0;
        end;

      LostSegment:=0;
      SegmentNum:=0;
      DrawFlag := true;

      for il := 0 to OldList.Count - 1 do
       case TSWFShapeRecord(OldList[il]).ShapeRecType of
        StyleChangeRecord:
        With TSWFStyleChangeRecord(OldList[il]) do
         begin
           SCR := TSWFStyleChangeRecord.Create;
           if StateLineStyle and (LineId > 0) then
             begin
               SCR.LineId := LineId;
               NewLineID := LineId;
               SCR.Fill0Id:= Fill0Id;
               SCR.Fill1Id:= Fill0Id;
  //               SCR.StateFillStyle0:=True;
               SCR.StateFillStyle1:=True;
             end;
           if StateMoveTo then
             begin
               SCR.StateMoveTo := true;
               SCR.X := X;
               SCR.Y := Y;
             end;
           LastMT.X := SCR.X;
           LastMT.Y := SCR.Y;
           NewList.Add(SCR);
         end;

        StraightEdgeRecord:
         with TSWFStraightEdgeRecord(OldList[il]) do
         begin
          AbsLen := Round(Hypot(X, Y));
          CurentLen := 0;
          While CurentLen < AbsLen do
           begin
             if (LostSegment <> 0) then
              begin
                SegmentLen := LostSegment;
                LostSegment := 0;
                DrawFlag := not DrawFlag;
              end else
              begin
               SegmentLen := twips * ExtLineStyle[SegmentNum mod ExtLineStyle.Count];
               inc(SegmentNum);
              end;

             if (CurentLen + SegmentLen) > AbsLen then
             begin
               LostSegment:=SegmentLen + CurentLen - AbsLen;
               SegmentLen := AbsLen - CurentLen;
             end;

             if DrawFlag
               then
                begin
                 SER := TSWFStraightEdgeRecord.Create;
                 SER.X := Round(X / AbsLen * SegmentLen);
                 SER.Y := Round(Y / AbsLen * SegmentLen);
                 NewList.Add(SER);
                end
               else
               begin
                 if ExtLineTransparent then
                  begin
                   SCR := TSWFStyleChangeRecord.Create;
                   SCR.LineId := NewLineID;
                   SCR.StateMoveTo := true;
                   SCR.X := Round(X / AbsLen * (CurentLen + SegmentLen))+ LastMT.X;
                   SCR.Y := Round(Y / AbsLen * (CurentLen + SegmentLen))+ LastMT.Y;
                   NewList.Add(SCR);
                  end else
                  begin
                   SCR := TSWFStyleChangeRecord.Create;
                   SCR.LineId := LineStyleNum + 1;
                   NewList.Add(SCR);
                   SER := TSWFStraightEdgeRecord.Create;
                   SER.X := Round(X / AbsLen * SegmentLen);
                   SER.Y := Round(Y / AbsLen * SegmentLen);
                   NewList.Add(SER);
                   SCR := TSWFStyleChangeRecord.Create;
                   SCR.LineId := NewLineID;
                   NewList.Add(SCR);
                  end;
               end;

             CurentLen := CurentLen + SegmentLen;
             DrawFlag := not DrawFlag;
           end;
  //            SegmentLen := 0;
  //            SegmentNum:=0;
          LastMT.X := LastMT.X+X;
          LastMT.Y := LastMT.Y+Y;
         end;

        CurvedEdgeRecord:
         with CurveRec, TSWFCurvedEdgeRecord(OldList[il]) do
         begin
           crP0:=Point(0,0); crPC:=crP0; PrevPT:=crP0;
           crP1:=Point(crP0.X+ControlX, crP0.Y+ControlY);
           crP2:=Point(crP1.X+AnchorX, crP1.Y+AnchorY);
           cru:=0; crdu:=0.02; crExitFlag:=0;
           crAx:= crP2.X-2*crP1.X;  crAy:= crP2.Y-2*crP1.Y;
           crBx:=crP2.X*crP2.X+crP2.Y*crP2.Y;

           repeat
             if (LostSegment <> 0) then
             begin SegmentLen := LostSegment; LostSegment:=0;
                            DrawFlag := not DrawFlag;  end
             else begin
               SegmentLen:=twips*ExtLineStyle[SegmentNum mod ExtLineStyle.Count];
               inc(SegmentNum); end;

             PrevPT:=crPC;
             crPC:=SearchCurvePos(SegmentLen, CurveRec);
              PrevPT:=Point(crPC.X-PrevPT.X, crPC.Y-PrevPT.Y);
               if DrawFlag
                 then
                  begin
                   if (Abs(PrevPt.X)<20) or (Abs(PrevPT.Y)<20)
                       or (SegmentLen < 100) or (crP1c.X+crP1c.Y = 0) then
                   begin
                     SER := TSWFStraightEdgeRecord.Create;
                     SER.X := PrevPT.X;
                     SER.Y := PrevPt.Y;
                     NewList.Add(SER);
                   end
                   else begin
                     SCvR := TSWFCurvedEdgeRecord.Create;
                     SCvR.ControlX := crP1c.X;
                     SCvR.ControlY := crP1c.Y;
                     SCvR.AnchorX := PrevPT.X-crP1c.X;
                     SCvR.AnchorY := PrevPT.Y-crP1c.Y;
                     NewList.Add(SCvR);
                   end;
                  end
                 else
                 begin
                   if ExtLineTransparent then
                     begin
                      SCR := TSWFStyleChangeRecord.Create;
                      SCR.LineId := NewLineID;
                      SCR.StateMoveTo := true;
                      SCR.X := PrevPT.X + LastMT.X;
                      SCR.Y := PrevPT.Y + LastMT.Y;
                      NewList.Add(SCR);
                     end else
                     begin
                      SCR := TSWFStyleChangeRecord.Create;
                      SCR.LineId := LineStyleNum + 1;
                      NewList.Add(SCR);

                      if (Abs(PrevPt.X)<20) or (Abs(PrevPT.Y)<20)
                          or (SegmentLen < 100) or (crP1c.X+crP1c.Y = 0) then
                      begin
                        SER := TSWFStraightEdgeRecord.Create;
                        SER.X := PrevPT.X;
                        SER.Y := PrevPt.Y;
                        NewList.Add(SER);
                      end
                      else begin
                        SCvR := TSWFCurvedEdgeRecord.Create;
                        SCvR.ControlX := crP1c.X;
                        SCvR.ControlY := crP1c.Y;
                        SCvR.AnchorX := PrevPT.X-crP1c.X;
                        SCvR.AnchorY := PrevPT.Y-crP1c.Y;
                        NewList.Add(SCvR);
                      end;

                      SCR := TSWFStyleChangeRecord.Create;
                      SCR.LineId := NewLineID;
                      NewList.Add(SCR);
                     end;


                 end;
            DrawFlag := not DrawFlag;
            LastMT.X := LastMT.X+PrevPT.X;
            LastMT.Y := LastMT.Y+PrevPT.Y;
           until crExitFlag > 0;
           LostSegment:= crExitFlag;
         end;

        EndShapeRecord:
            NewList.Add(TSWFEndShapeRecord.Create);
        end;
//      fShape.Edges := NewList;
    end else
    begin
      fShape.Edges.OwnsObjects := false;
{$IFDEF VER130}
      CopyList(EdgesStore, fShape.Edges);
{$ELSE}
      fShape.Edges.Assign(EdgesStore);
{$ENDIF}
    end;

  fShape.WriteToStream(be);

  fShape.Free;
end;

{
***************************************************** TFlashMorphShape ******************************************************
}
constructor TFlashMorphShape.Create(owner: TFlashMovie);
begin
  inherited;
  fMorphShape := TSWFDefineMorphShape.Create;
  ListEdges := fMorphShape.StartEdges;
  FStartEdges := TFlashEdges.Create(fMorphShape.StartEdges);
  FStartEdges.Owner := owner;
  FEndEdges := TFlashEdges.Create(fMorphShape.EndEdges);
  FEndEdges.Owner := owner;
  IgnoreMovieSettings := false;
  hasUseAdvancedStyles := false;
end;

destructor TFlashMorphShape.Destroy;
begin
  fMorphShape.Free;
  FStartEdges.Free;
  FEndEdges.Free;
  inherited;
end;

procedure TFlashMorphShape.AddFillStyle(fill: TSWFMorphFillStyle);
begin
  FillStyleNum := fMorphShape.MorphFillStyles.Add(fill) + 1;
end;

function TFlashMorphShape.AddLineStyle(outline: TSWFMorphLineStyle = nil): TSWFMorphLineStyle;
begin
  if outline = nil then Result := TSWFMorphLineStyle.Create else Result := outline;
  LineStyleNum := fMorphShape.MorphLineStyles.Add(Result) + 1;
end;

procedure TFlashMorphShape.Assign(Source: TBasedSWFObject);
begin
  inherited;
  With TFlashMorphShape(Source) do
  begin
    self.FillStyleLeft := FillStyleLeft;
    self.LineStyleNum := LineStyleNum;
    self.fMorphShape.Assign(fMorphShape);
  end;
end;

procedure TFlashMorphShape.ChangeOwner;
begin
  StartEdges.Owner := Owner;
  EndEdges.Owner := Owner;
end;

function TFlashMorphShape.EndHeight: LongInt;
begin
  with fMorphShape.EndBounds do
   Result := Ymax - YMin;
end;

function TFlashMorphShape.EndWidth: LongInt;
begin
  with fMorphShape.EndBounds do
   Result := Xmax - XMin;
end;

function TFlashMorphShape.FindLastChangeStyle: TSWFStyleChangeRecord;
var
  SearchState: Boolean;
  il: Word;
begin
  Result := nil;
  with ListEdges do
   if (Count>0) then
    begin
      SearchState := true;
      il := count - 1;
      while SearchState do
       begin
        if TSWFShapeRecord(Items[il]).ShapeRecType = StyleChangeRecord then
          begin
             Result := TSWFStyleChangeRecord(Items[il]);
             SearchState := false;
          end;
         if il = 0 then SearchState := false else dec(il);
       end;
    end;
end;

function TFlashMorphShape.GetCenterX: LongInt;
begin
  result := fXCenter div MultCoord;
end;

function TFlashMorphShape.GetCenterY: LongInt;
begin
  result := fYCenter div MultCoord;
end;

function TFlashMorphShape.MinVersion: Byte;
begin
  Result := SWFVer3;
end;

procedure TFlashMorphShape.SetCenterX(X: LongInt);
var
  delta: LongInt;
  il: Word;
begin
  delta := X * MultCoord - fXCenter;
  if ListEdges.Count > 0 then
    for il := 0 to ListEdges.Count-1 do
     case TSWFShapeRecord(ListEdges[il]).ShapeRecType of
       StyleChangeRecord, StraightEdgeRecord:
        With TSWFStraightEdgeRecord(ListEdges[il]) do
          X := X + delta;
       CurvedEdgeRecord:
        With TSWFCurvedEdgeRecord(ListEdges[il]) do
          begin
            X := X + delta;
            AnchorX := AnchorX + delta;
          end;
     end;
  fXCenter := X * MultCoord
end;

procedure TFlashMorphShape.SetCenterY(Y: LongInt);
var
  delta: LongInt;
  il: Word;
begin
  delta := Y * MultCoord - fYCenter;
  if ListEdges.Count > 0 then
    for il := 0 to ListEdges.Count-1 do
     case TSWFShapeRecord(ListEdges[il]).ShapeRecType of
       StyleChangeRecord, StraightEdgeRecord:
        With TSWFStraightEdgeRecord(ListEdges[il]) do
          Y := Y + delta;
       CurvedEdgeRecord:
        With TSWFCurvedEdgeRecord(ListEdges[il]) do
          begin
            Y :=Y + delta;
            AnchorY := AnchorY + delta;
          end;
     end;
  fYCenter := Y * MultCoord
end;

procedure TFlashMorphShape.SetCharacterId(id: word);
begin
  inherited;
  fMorphShape.CharacterId := id;
end;


procedure TFlashMorphShape.SetEndBound(XMin, YMin, XMax, YMax: integer);
  const addB = 10;
begin
  fMorphShape.EndBounds.Rect := Rect(XMin * MultCoord - addB, YMin * MultCoord - addB,
                                     XMax * MultCoord + addB, YMax * MultCoord + addB);
end;

procedure TFlashMorphShape.SetFillStyleLeft(n: Word);
var
  R: TSWFStyleChangeRecord;
begin
   if (fMorphShape.MorphFillStyles.Count = 1) then
   With ListEdges do
    begin
     if (Count > 0) and
       (TSWFShapeRecord(Items[0]).ShapeRecType = StyleChangeRecord)
       then R := TSWFStyleChangeRecord(Items[0])
       else R := nil;
    end else
     R := FindLastChangeStyle;
  
  if R = nil then fFillStyleLeft := 0
    else
    begin
      fFillStyleLeft := n;
      R.StateFillStyle0 := true;
      R.Fill0Id := n;
    end;
end;

function TFlashMorphShape.SetImageFill(img: TFlashImage; mode: TFillImageMode; StartScaleX: single = 1; StartScaleY: single = 1;
                          EndScaleX: single = 1; EndScaleY: single = 1): TSWFMorphImageFill;
var
  adds: Single;
begin
  Result := TSWFMorphImageFill.Create;
  Result.ImageID := img.CharacterID;

      // adds & (twips div 4) - values for fixed visual bag of flash. non document
  adds := $f0 / specFixed;

  case mode of
    fmFit: begin
             Result.SWFFillType := SWFFillClipBitmap;
             Result.StartMatrix.SetTranslate(fMorphShape.StartBounds.Xmin - twips div 4, fMorphShape.StartBounds.Ymin - twips div 4);
             Result.StartMatrix.SetScale(StartWidth/img.Width + adds, StartHeight/img.Height + adds);
             Result.EndMatrix.SetTranslate(fMorphShape.EndBounds.Xmin - twips div 4, fMorphShape.EndBounds.Ymin - twips div 4);
             Result.EndMatrix.SetScale(EndWidth/img.Width + adds, EndHeight/img.Height + adds);
            end;
    fmClip: begin
             Result.SWFFillType := SWFFillClipBitmap;
             Result.StartMatrix.SetTranslate(fMorphShape.StartBounds.Xmin - twips div 4, fMorphShape.StartBounds.Ymin - twips div 4);
             Result.StartMatrix.SetScale(StartScaleX * twips, StartScaleY * twips);
             Result.EndMatrix.SetTranslate(fMorphShape.EndBounds.Xmin - twips div 4, fMorphShape.EndBounds.Ymin - twips div 4);
             Result.EndMatrix.SetScale(EndScaleX * twips, EndScaleY * twips);
            end;
    fmTile:begin
             Result.SWFFillType := SWFFillTileBitmap;
             Result.StartMatrix.SetTranslate(fMorphShape.StartBounds.Xmin - twips div 4, fMorphShape.StartBounds.Ymin - twips div 4);
             Result.StartMatrix.SetScale(StartScaleX * twips, StartScaleY * twips);
             Result.EndMatrix.SetTranslate(fMorphShape.EndBounds.Xmin - twips div 4, fMorphShape.EndBounds.Ymin - twips div 4);
             Result.EndMatrix.SetScale(EndScaleX * twips, EndScaleY * twips);
           end;
   end;
  AddFillStyle(Result);

  if owner <> nil then
   with owner.ObjectList do
    if IndexOf(img) > IndexOf(self) then
      Move(IndexOf(img), IndexOf(self));
end;

function TFlashMorphShape.SetLinearGradient(StartGradient, EndGradient: array of recRGBA; StartAngle: single = 0; EndAngle: 
        single = 0): TSWFMorphGradientFill;
var
  il, ind: Byte;
  r, kX, kY: Double;
begin
  Result := TSWFMorphGradientFill.Create;
  Result.Count := High(StartGradient) - Low(StartGradient) + 1;
  For il:=1 to Result.count do
    begin
     ind := Low(StartGradient) + il - 1;
     Result.StartColor[il].RGBA := StartGradient[ind];
     Result.StartRatio[il] := Round((il - 1) / (Result.count - 1) * $FF);
     Result.EndColor[il].RGBA := EndGradient[ind];
     Result.EndRatio[il] := Round((il - 1) / (Result.count - 1) * $FF);
    end;

  r := DegToRad(StartAngle);
  kX := StartWidth /GradientSizeXY;
  kY := StartHeight/GradientSizeXY;
  Result.StartMatrix.SetScale(kX*cos(r), kY*cos(r));
  Result.StartMatrix.SetSkew(kX*sin(r), -kY*sin(r));
  Result.StartMatrix.SetTranslate(fMorphShape.StartBounds.Xmin + StartWidth div 2,
                                  fMorphShape.StartBounds.Ymin + StartHeight div 2);
  r := DegToRad(EndAngle);
  kX := EndWidth /GradientSizeXY;
  kY := EndHeight/GradientSizeXY;
  Result.EndMatrix.SetScale(kX*cos(r), kY*cos(r));
  Result.EndMatrix.SetSkew(kX*sin(r), -kY*sin(r));
  Result.EndMatrix.SetTranslate(fMorphShape.EndBounds.Xmin + EndWidth div 2,
                                fMorphShape.EndBounds.Ymin + EndHeight div 2);
  
  AddFillStyle(Result);
end;

function TFlashMorphShape.SetLinearGradient(Gradient: array of TSWFMorphGradientRec; StartAngle: single = 0; EndAngle: 
        single = 0): TSWFMorphGradientFill;
var
  il, ind: Byte;
  r, kX, kY: Double;
begin
  Result := TSWFMorphGradientFill.Create;
  Result.Count := High(Gradient) - Low(Gradient) + 1;
  if Result.Count > 8 then Result.Count := 8;
  For il:=1 to Result.Count do
    begin
     ind := Low(Gradient) + il - 1;
     Result.StartColor[il].RGBA := Gradient[ind].StartColor;
     Result.StartRatio[il] := Gradient[ind].StartRatio;
     Result.EndColor[il].RGBA := Gradient[ind].EndColor;
     Result.EndRatio[il] := Gradient[ind].EndRatio;
    end;
  
  r := DegToRad(StartAngle);
  kX := StartWidth /GradientSizeXY;
  kY := StartHeight/GradientSizeXY;
  Result.StartMatrix.SetScale(kX*cos(r), kY*cos(r));
  Result.StartMatrix.SetSkew(kX*sin(r), -kY*sin(r));
  Result.StartMatrix.SetTranslate(fMorphShape.StartBounds.Xmin + StartWidth div 2,
                                  fMorphShape.StartBounds.Ymin + StartHeight div 2);
  
  r := DegToRad(EndAngle);
  kX := EndWidth /GradientSizeXY;
  kY := EndHeight/GradientSizeXY;
  Result.EndMatrix.SetScale(kX*cos(r), kY*cos(r));
  Result.EndMatrix.SetSkew(kX*sin(r), -kY*sin(r));
  Result.EndMatrix.SetTranslate(fMorphShape.EndBounds.Xmin + EndWidth div 2,
                                fMorphShape.EndBounds.Ymin + EndHeight div 2);

  AddFillStyle(Result);
end;

function TFlashMorphShape.SetLinearGradient(StartC1, StartC2, EndC1, EndC2: recRGBA; StartAngle: single = 0; EndAngle: 
        single = 0): TSWFMorphGradientFill;
var
  SGradient, EGradient: array [0..1] of recRGBA;
begin
  SGradient[0] := StartC1;
  SGradient[1] := StartC2;
  EGradient[0] := EndC1;
  EGradient[1] := EndC2;
  result := SetLinearGradient(SGradient, EGradient, StartAngle, EndAngle);
end;

function TFlashMorphShape.SetAdvancedLineStyle(StartWidth, EndWidth: word; StartColor, EndColor: recRGBA;
           StartCapStyle: byte = 0; EndCapStyle: byte = 0; JoinStyle: byte = 0): TSWFMorphLineStyle2;
begin
  Result := TSWFMorphLineStyle2.Create;
  LineStyleNum := fMorphShape.MorphLineStyles.Add(Result) + 1;
  Result.StartWidth := StartWidth * MultCoord;
  Result.EndWidth := EndWidth * MultCoord;
  Result.StartColor.RGBA := StartColor;
  Result.EndColor.RGBA := EndColor;
  Result.StartCapStyle := StartCapStyle;
  Result.EndCapStyle := EndCapStyle;
  Result.JoinStyle := JoinStyle;
  hasUseAdvancedStyles := true;
end;

function TFlashMorphShape.SetLineStyle(StartWidth, EndWidth: word; StartColor, EndColor: recRGBA): TSWFMorphLineStyle;
begin
  Result := AddLineStyle;
  Result.StartWidth := StartWidth * MultCoord;
  Result.EndWidth := EndWidth * MultCoord;
  Result.StartColor.RGBA := StartColor;
  Result.EndColor.RGBA := EndColor;
end;

procedure TFlashMorphShape.SetLineStyleNum(n: Word);
var
  R: TSWFStyleChangeRecord;
begin
  if (fMorphShape.MorphFillStyles.Count = 1) then
   with ListEdges do
    begin
     if (Count > 0) and
       (TSWFShapeRecord(Items[0]).ShapeRecType = StyleChangeRecord)
       then R := TSWFStyleChangeRecord(Items[0])
       else R := nil; 
    end else
     R := FindLastChangeStyle;
  
  if R = nil then fLineStyleNum := 0
    else
    begin
      fLineStyleNum := n;
      R.StateLineStyle := true;
      R.LineId := n;
    end;
end;

function TFlashMorphShape.SetRadialGradient(StartGradient, EndGradient: array of recRGBA; StartXc, StartYc, EndXc, EndYc: 
        byte): TSWFMorphGradientFill;
var
  il, ind: Byte;
  kX, kY: Double;
begin
  Result := TSWFMorphGradientFill.Create;
  Result.SWFFillType := SWFFillRadialGradient;
  Result.Count := High(StartGradient) - Low(StartGradient) + 1;
  if Result.Count > 8 then Result.Count := 8;
  For il:=1 to Result.count do
    begin
     ind := Low(StartGradient) + il - 1;
     Result.StartColor[il].RGBA := StartGradient[ind];
     Result.EndColor[il].RGBA := EndGradient[ind];
     Result.StartRatio[il] := Round((il - 1) / (Result.count - 1) * $FF);
     Result.EndRatio[il] := Result.StartRatio[il];
    end;
  
  kX := StartWidth /GradientSizeXY;
  kY := StartHeight/GradientSizeXY;
  Result.StartMatrix.SetScale(kX, kY);
  Result.StartMatrix.SetTranslate(fMorphShape.StartBounds.Xmin + Round(StartWidth / 100 * StartXc),
                                  fMorphShape.StartBounds.Ymin + Round(StartHeight / 100 * StartYc));
  
  kX := EndWidth /GradientSizeXY;
  kY := EndHeight/GradientSizeXY;
  Result.EndMatrix.SetScale(kX, kY);
  Result.EndMatrix.SetTranslate(fMorphShape.EndBounds.Xmin + Round(EndWidth / 100 * EndXc),
                                  fMorphShape.EndBounds.Ymin + Round(EndHeight / 100 * EndYc));
  AddFillStyle(Result);
end;

function TFlashMorphShape.SetRadialGradient(StartC1, StartC2, EndC1, EndC2: recRGBA; StartXc, StartYc, EndXc, EndYc: byte): 
        TSWFMorphGradientFill;
var
  SGradient, EGradient: array [0..1] of recRGBA;
begin
  SGradient[0] := StartC1;
  SGradient[1] := StartC2;
  EGradient[0] := EndC1;
  EGradient[1] := EndC2;
  Result := SetRadialGradient(SGradient, EGradient, StartXc, StartYc, EndXc, EndYc);
end;

function TFlashMorphShape.SetSolidColor(StartC, EndC: recRGBA): TSWFMorphColorFill;
begin
  Result := TSWFMorphColorFill.Create;
  Result.StartColor.RGBA := StartC;
  Result.EndColor.RGBA := EndC;
  AddFillStyle(Result);
end;

procedure TFlashMorphShape.SetStartBound(XMin, YMin, XMax, YMax: integer);
  
  const addB = 10;
  
begin
  fMorphShape.StartBounds.Rect := Rect(XMin * MultCoord - addB, YMin * MultCoord - addB,
                                       XMax * MultCoord + addB, YMax * MultCoord + addB);
end;

function TFlashMorphShape.StartHeight: LongInt;
begin
  with fMorphShape.StartBounds do
   Result := Ymax - YMin;
end;

function TFlashMorphShape.StartWidth: LongInt;
begin
  with fMorphShape.StartBounds do
   Result := Xmax - XMin;
end;

procedure TFlashMorphShape.WriteToStream(be: TBitsEngine);
 var MS2: TSWFDefineMorphShape2;
begin
 if hasUseAdvancedStyles then
   begin
     MS2 := TSWFDefineMorphShape2.Create;
     MS2.Assign(fMorphShape);
     
     MS2.WriteToStream(be);
     MS2.Free;
   end else
     fMorphShape.WriteToStream(be);
end;

{
******************************************************** TFlashVideo ********************************************************
}
constructor TFlashVideo.Create(owner: TFlashMovie; FileName: string);
begin
  inherited Create(owner);
  FFLV := TFLVData.Create(FileName);
end;

constructor TFlashVideo.Create(owner: TFlashMovie; Source: TStream);
begin
  inherited Create(owner);
  FFLV := TFLVData.Create('');
  FLV.Data := Source;
  FLV.Parse;
end;

destructor TFlashVideo.Destroy;
begin
  FLV.Free;
  inherited;
end;

procedure TFlashVideo.Assign(Source: TBasedSWFObject);
begin
  inherited;
  With TFlashVideo(Source) do
  begin
    self.CharacterID := CharacterID;
    if Assigned(FPlaceFrame) then self.OnPlaceFrame := OnPlaceFrame;
    if Assigned(FWriteFrame) then self.OnWriteFrame := OnWriteFrame;
  //    F: TWriteFrame;

  end;
end;

function TFlashVideo.GetHeight: Word;
begin
  Result := FLV.Header.YDim;
end;

function TFlashVideo.GetWidth: Word;
begin
  Result := FLV.Header.XDim;
end;

function TFlashVideo.MinVersion: Byte;
begin
  Case FLV.Header.CodecInfo of
   codecSorenson:  Result := SWFVer6;
   codecScreenVideo:  Result := SWFVer7;
   codecScreenVideo2, codecVP6, codecAlphaVP6:
        Result := SWFVer8;
     else Result := 9;
  end;
end;

procedure TFlashVideo.WriteFrame(sender: TSWFObject; BE: TBitsEngine);
 var dd: longint;
begin
  With FLV.Frame[TSWFVideoFrame(sender).FrameNum] do
   begin
     dd := 0;
     case FLV.Header.CodecInfo of
       codecScreenVideo, codecScreenVideo2:
         be.WriteByte((byte(FLV.Header.KeyFrame) shl 4)+FLV.Header.CodecInfo);
       codecVP6, codecAlphaVP6:
         dd := 1;
     end;
     FLV.Data.Position := Start + dd;
     BE.BitsStream.CopyFrom(FLV.Data, Len - dd);
   end;
end;


procedure TFlashVideo.WriteToStream(be: TBitsEngine);
begin
  With TSWFDefineVideoStream.Create do
    begin;
      CharacterID := self.CharacterID;
      CodecID := FLV.Header.CodecInfo;
      NumFrames := FLV.Header.FrameCount;
      Width := FLV.Header.XDim;
      Height := FLV.Header.YDim;
      WriteToStream(BE);
      Free;
    end;
end;


// =============================================================//
//                          TFlashSprite                        //
// =============================================================//

{
******************************************************* TFlashSprite ********************************************************
}
constructor TFlashSprite.Create;
begin
  inherited;
  FSprite := TSWFDefineSprite.Create;
end;

destructor TFlashSprite.Destroy;
begin
  FSprite.Free;
  if FVideoList <> nil then FVideoList.Free;
  if FInitActions <> nil then FInitActions.Free;
  inherited;
end;

procedure TFlashSprite.AddFlashObject(Obj: TBasedSWFObject);
begin
  if (owner.AddObjectMode = amEnd) or (CurrentFramePosIndex = -1) or
   (CurrentFramePosIndex >= (ObjectList.Count -1)) then
   begin
     ObjectList.Add(Obj);
     CurrentFramePosIndex := ObjectList.Count - 1;
   end else
   begin
     ObjectList.Insert(CurrentFramePosIndex, Obj);
     inc(CurrentFramePosIndex);
   end;
end;

procedure TFlashSprite.Assign(Source: TBasedSWFObject);
var
  il: Word;
  PV: TFlashPlaceVideo;
begin
  inherited;
  With TFlashSprite(Source) do
  begin
    self.FSprite.Assign(FSprite);
    if FBackgroundSound <> nil then
      self.BackgroundSound.Assign(BackgroundSound);
    if VideoListCount > 0 then
     for il := 0 to VideoListCount - 1 do
      begin
        PV := TFlashPlaceVideo.Create(owner, nil, 0);
        PV.Assign(VideoList[il]);
        Self.FVideoList.Add(PV);
      end;
  end;
end;

function TFlashSprite.GetBackgrondSound: TFlashSound;
begin
  if FBackgroundSound = nil then FBackgroundSound := TFlashSound.Create(owner);
  Result := FBackgroundSound;
end;

function TFlashSprite.GetFrameActions: TFlashActionScript;
begin
  if fFrameActions = nil then
    fFrameActions := TFlashActionScript.Create(owner);
  Result := fFrameActions;
end;

function TFlashSprite.GetFrameCount: Word;
begin
  result := Sprite.FrameCount;
end;

function TFlashSprite.GetInitActions: TFlashActionScript;
begin
  if fInitActions = nil then
    fInitActions := TFlashActionScript.Create(owner);
  Result := fInitActions;
end;

function TFlashSprite.GetObjectList: TObjectList;
begin
  Result := Sprite.ControlTags;
end;

function TFlashSprite.GetVideoList(Index: Integer): TFlashPlaceVideo;
begin
  Result := TFlashPlaceVideo(FVideoList[index]);
end;

function TFlashSprite.GetVideoListCount: Integer;
begin
  if FVideoList = nil then Result := 0
    else Result := FVideoList.Count;
end;

function TFlashSprite.MinVersion: Byte;
var
  il: Word;
  SWFObject: TBasedSWFObject;
begin
  Result := SWFVer3;
  if Sprite.ControlTags.Count = 0 then exit;
   With Sprite.ControlTags do
    for il:=0 to Count - 1 do
     begin
       SWFObject := TBasedSWFObject(Items[il]);
       if (SWFObject<>nil) and (Result < SWFObject.MinVersion) then
         Result := SWFObject.MinVersion;
     end;
end;

function TFlashSprite.PlaceMorphShape(MS: TFlashMorphShape; Depth, NumFrame: word): TFlashPlaceObject;
var
  il: Integer;
  PO: TFlashPlaceObject;
begin
  if NumFrame < 2 then NumFrame := 2;
  For il := 0 to NumFrame - 1 do
   begin
     if il = 0 then
      begin
        PO := PlaceObject(MS, Depth);
        Result := PO;
      end
      else
      begin
        PO := PlaceObject(Depth);
        PO.RemoveDepth := true;
      end;
     PO.Ratio := Round( il / (NumFrame - 1) * $FFFF );
     ShowFrame;
   end;
end;

function TFlashSprite.PlaceObject(shape: TFlashVisualObject; depth: word): TFlashPlaceObject;
var
  io1, io2: LongInt;
begin
  Result := TFlashPlaceObject.Create(owner, shape, depth);
  AddFlashObject(Result);
  if Owner <> nil then
   with owner.ObjectList do
    begin
     io1 := IndexOf(self);
     io2 := IndexOf(shape);
     if (io1 < io2) and (io1 <> -1) and (io2 <> -1) then Move(io2, io1);
    end;
  if FMaxDepth < depth then FMaxDepth := depth;
end;

function TFlashSprite.PlaceObject(shape, mask: TFlashVisualObject; depth: word): TFlashPlaceObject;
var
  S: TFlashSprite;
begin
  S := owner.AddSprite;
  S.PlaceObject(mask, 1).ClipDepth := 2;
  //S.PlaceObject(shape, 2);
  S.PlaceObject(shape, 2).Name := 'mc_swf';//yangrh
  Result := TFlashPlaceObject.Create(owner, S, depth);
  AddFlashObject(Result);
  if FMaxDepth < depth then FMaxDepth := depth;
end;

function TFlashSprite.PlaceObject(depth: word): TFlashPlaceObject;
begin
  Result := TFlashPlaceObject.Create(owner, nil, depth);
  AddFlashObject(Result);
  if FMaxDepth < depth then FMaxDepth := depth;
end;

function TFlashSprite.PlaceVideo(F: TFlashVideo; depth: word): TFlashPlaceVideo;
begin
  Result := TFlashPlaceVideo.Create(owner, F, Depth); //Owner.PlaceVideo(F, depth);
  Result.StartFrame := FrameCount;
  Result.SpriteParent := self;
  if FVideoList = nil then FVideoList := TObjectList.Create(false);
  FVideoList.Add(Result);
  if FMaxDepth < depth then FMaxDepth := depth;
end;


procedure TFlashSprite.RemoveObject(depth: word; shape: TFlashVisualObject = nil);
var
  RO: TSWFRemoveObject;
  RO2: TSWFRemoveObject2;
begin
  if shape = nil then
    begin
     RO2 := TSWFRemoveObject2.Create;
     RO2.depth := depth;
     AddFlashObject(RO2);
    end else
    begin
     RO := TSWFRemoveObject.Create;
     RO.CharacterID := shape.CharacterId;
     RO.depth := depth;
     AddFlashObject(RO);
    end;
end;

procedure TFlashSprite.SetCharacterId(id: word);
begin
  inherited;
  Sprite.SpriteID := ID;
end;

procedure TFlashSprite.SetCurrentFrameNum(Value: Integer);
var
  il: LongInt;
begin
  if (owner.AddObjectMode <> amEnd) and (ObjectList.Count > 0) then
   begin
    if Value >= FrameCount then
      begin
        FCurrentFrameNum := FrameCount - 1;
        CurrentFramePosIndex := ObjectList.Count - 1;
      end else
      begin
        FCurrentFrameNum := 0;
        for il := 0 to ObjectList.Count - 1 do
         if (TBasedSWFObject(ObjectList[il]).LibraryLevel = SWFLevel) and
            (TSWFObject(ObjectList[il]).TagID = tagShowFrame) then
          begin
           Inc(FCurrentFrameNum);
           if FCurrentFrameNum = Value then
             begin
               CurrentFramePosIndex := il;
               Break;
             end;
          end;
      end;
   end;
end;

procedure TFlashSprite.SetFrameCount(Value: Word);
begin
  Sprite.FrameCount := value;
end;

procedure TFlashSprite.ShowFrame(c: word = 1);
var
  il: Integer;
begin
  if C = 0 then C := 1;
  Sprite.FrameCount := Sprite.FrameCount + C;
  
  if fFrameActions <> nil then
     begin
      Sprite.ControlTags.Add(fFrameActions);
      fFrameActions := nil;
     end;
  
  if FrameLabel<>'' then
    begin
      Sprite.ControlTags.Add(TSWFFrameLabel.Create(FrameLabel));
      FrameLabel := '';
    end;
  
  For il:=1 to C do
    begin
      Sprite.ControlTags.Add(TSWFShowFrame.Create);
    end;
  
  FCurrentFrameNum := Sprite.FrameCount - 1;
  CurrentFramePosIndex := Sprite.ControlTags.Count - 1;
end;

function TFlashSprite.StartSound(snd: TFlashSound): TSWFStartSound;
begin
  Result := StartSound(snd.CharacterID);
end;

function TFlashSprite.StartSound(ID: word): TSWFStartSound;
begin
  Result := TSWFStartSound.Create;
  Result.SoundId := ID;
  AddFlashObject(Result);
end;

procedure TFlashSprite.StoreFrameActions;
begin
  if fFrameActions <> nil then
   begin
      AddFlashObject(fFrameActions);
      fFrameActions := nil;
   end;
end;

procedure TFlashSprite.WriteToStream(be: TBitsEngine);
var
  il, il2: Integer;
  EndFlag: Boolean;
  MS: TMemoryStream;
  sBE: TBitsEngine;
  SH: TSWFSoundStreamHead2;
  CurentFrame: Word;
begin
  if FrameCount = 0 then ShowFrame;

  MS := TMemoryStream.Create;
  sBE := TBitsEngine.Create(MS);
  
  With Sprite do
   begin
    sBE.WriteWord(SpriteID);
    sBE.WriteWord(FrameCount);
    EndFlag := false;
  
   if EnableBGSound and (fBackgroundSound <> nil) then
    begin
      SH := TSWFSoundStreamHead2.Create;
      BackgroundSound.FillHeader(SH, owner.FPS);
      SH.WriteToStream(sBE);
      SH.Free;
    end;
  
    CurentFrame := 0;
    if ControlTags.Count >0 then
     For il := 0 to ControlTags.Count - 1 do
      With TBasedSWFObject(ControlTags[il]) do
       begin
         if LibraryLevel = 0 then
           begin
             if TSWFObject(ControlTags[il]).TagID = tagShowFrame then
               begin
                 if GetVideoListCount > 0 then
                   for il2 := 0 to VideoListCount - 1 do
                    With VideoList[il2] do
                      WriteToStream(sBE, CurentFrame);

                 if EnableBGSound and (fBackgroundSound <> nil) and
                   (fBackgroundSound.StartFrame <= CurentFrame) then
                     fBackgroundSound.WriteSoundBlock(sBE);
                 inc(CurentFrame);
               end;
           end else
           begin
            if (ControlTags[il] is TFlashPlaceObject) then
              TFlashPlaceObject(ControlTags[il]).PlaceObject.SWFVersion := Owner.Version;
           end;
         WriteToStream(sBE);
         if (il = (ControlTags.Count - 1)) and (LibraryLevel = 0) then
          with TSWFObject(ControlTags[il]) do
           EndFlag := tagID = tagEnd;
       end;
    if not EndFlag then sBE.WriteWord(0);
   end;
   MS.Position := 0;
   WriteCustomData(be.BitsStream, tagDefineSprite, MS);
  
   MS.Free;
   sBE.Free;

   if FInitActions <> nil then
    with TSWFDoInitAction.Create(InitActions.ActionList) do
     begin
       SpriteID := CharacterId;
       WriteToStream(be);
     end;
  
end;


{
******************************************************** TFlashChar *********************************************************
}
constructor TFlashChar.Create(code: word; wide: boolean);
begin
  FListEdges := TObjectList.Create;
  FEdges := TFlashEdges.Create(FListEdges);
  Kerning := TSWFKerningRecord.Create;
  FWide := wide;
  self.Code := code;
  IsUsed := true;
end;

destructor TFlashChar.Destroy;
begin
  FListEdges.Free;
  FEdges.Free;
  FKerning.Free;
end;

procedure TFlashChar.Assign(Source: TObject);
begin
  inherited;
  With TFlashChar(Source) do
  begin
    self.FCode := FCode;
    self.FWide := FWide;
    self.ShapeInit := ShapeInit;
    if ShapeInit then
      begin
        self.GlyphAdvance := GlyphAdvance;
        self.Kerning := Kerning;
        CopyShapeRecords(ListEdges, self.ListEdges);
      end;
  end;
end;

function TFlashChar.GetIsWide: Boolean;
begin
  Result := Code > 127;
end;

procedure TFlashChar.SetCode(W: Word);
begin
  FCode := W;
  if W <= $FF then
    begin
     if FWide then FWideCode := W
      else FWideCode := Ord(WideString(chr(W))[1]);
    end
    else FWideCode := W;
end;

// =============================================================//
//                         TFlashPlaceObject                    //
// =============================================================//

{
***************************************************** TFlashPlaceObject *****************************************************
}
constructor TFlashPlaceObject.Create(owner: TFlashMovie; VObject: TFlashVisualObject; depth: word);
begin
  inherited Create(owner);
  FVisualObject := VObject;
  PlaceObject := TSWFPlaceObject3.Create;
  PlaceObject.Depth := depth;
  if FVisualObject <> nil then
    begin
     PlaceObject.CharacterId := FVisualObject.CharacterId;
     if FVisualObject is TFlashSprite then
       begin
        tmpActionList := TSWFActionList.Create;
        fActions := TFlashActionScript.Create(owner, tmpActionList);
       end;
    end
end;

destructor TFlashPlaceObject.Destroy;
begin
  if fActions <> nil then
    begin
      tmpActionList.Free;
      fActions.Free;
    end;
  PlaceObject.Free;
  inherited;
end;

procedure TFlashPlaceObject.Assign(Source: TBasedSWFObject);
begin
  With TFlashPlaceObject(Source) do
  begin
    if self.Owner = nil then self.Owner := Owner;
    self.PlaceObject.Assign(PlaceObject);
    FVisualObject := VisualObject;
    if fActions<>nil then self.fActions.Assign(fActions);
  end;
end;

function TFlashPlaceObject.AddActionEvent(FE: TSWFClipEvents): TSWFClipActionRecord;
begin
 Result := PlaceObject.ClipActions.AddActionRecord(FE, 0);
end;

{$IFDEF ASCompiler}
function TFlashPlaceObject.CompileEvent(src: TStrings): boolean;
 var S: TMemoryStream;
begin
  S := TMemoryStream.Create;
  src.SaveToStream(S);
  Result := CompileEvent(S);
  S.Free;
end;

function TFlashPlaceObject.CompileEvent(src: TStream): boolean;
begin
  try
    src.Position := 0;
    owner.ASCompiler.CompileAction(src, self);
    PlaceObject.PlaceFlagHasClipActions := true;
    Result := true;
  except
    on E: Exception do
      begin
        owner.ASCompilerLog.Write(PChar(E.Message)^, Length(E.Message));
        Result := false;
      end;
  end;
end;

function TFlashPlaceObject.CompileEvent(src: string): boolean;
 var S: TMemoryStream;
     P: Pointer;
begin
  S := TMemoryStream.Create;
  P := @src[1];
  S.Write(P^, length(src));
  Result := CompileEvent(S);
  S.Free;
end;

function TFlashPlaceObject.CompileEvent(FileName: string; unicode: boolean): boolean;
 var F: TFileStream;
begin
  F := TFileStream.Create(Filename, fmOpenRead);
  /// if unicode  -  todo
  Result := CompileEvent(F);
  F.free;
end;
{$ENDIF}

function TFlashPlaceObject.GetShadowFilter: TSWFDropShadowFilter;
 var F: TSWFFilter;
begin
  F := FindFilter(fidDropShadow);
  if F = nil then
    begin
      Result := TSWFDropShadowFilter(PlaceObject.SurfaceFilterList.AddFilter(fidDropShadow));
      if Owner <> nil then
       with Owner.GlobalFilterSettings do
        begin
          Result.BlurX := BlurX;
          Result.BlurY := BlurY;
          Result.Distance := Distance;
          Result.Angle := DegToRad(Angle);
          Result.DropShadowColor.Assign(ShadowColor);
          Result.Strength := Strength / 100;
          Result.InnerShadow := Inner;
          Result.Knockout := Knockout;
          Result.Passes := byte(Quality) + 1;
          Result.CompositeSource := not HideObject;
        end;
    end else
      Result := TSWFDropShadowFilter(F);
end;

function TFlashPlaceObject.FindActionEvent(FE: TSWFClipEvent; CreateNoExist: boolean = true): TSWFClipActionRecord;
var
  il: Word;
  CA: TSWFClipActionRecord;
begin
  Result := nil;
  if not (FVisualObject is TFlashSprite) then Exit;
  if PlaceObject.PlaceFlagHasClipActions then
    For il:=0 to PlaceObject.ClipActions.ActionRecords.Count - 1 do
     begin
       CA := PlaceObject.ClipActions.ActionRecord[il];
       if FE in CA.EventFlags then
         begin
           Result := CA;
           Break;
         end;
     end;
  if (Result = nil) and CreateNoExist then
    Result := PlaceObject.ClipActions.AddActionRecord([FE], 0);
end;

function TFlashPlaceObject.GetBevelFilter: TSWFBevelFilter;
 var F: TSWFFilter;
begin
  F := FindFilter(fidBevel);
  if F = nil then
    begin
      Result := TSWFBevelFilter(PlaceObject.SurfaceFilterList.AddFilter(fidBevel));
      if Owner <> nil then
       with owner.GlobalFilterSettings do
       begin
          Result.BlurX := BlurX;
          Result.BlurY := BlurY;
          Result.Distance := Distance;
          Result.Angle := DegToRad(Angle);
          Result.ShadowColor.Assign(ShadowColor);
          Result.HighlightColor.Assign(GlowColor);
          Result.Strength := Strength / 100;
          Result.InnerShadow := Inner;
          Result.Knockout := Knockout;
          Result.Passes := byte(Quality) + 1;
          Result.CompositeSource := not HideObject;
          Result.OnTop := OnTop;
        end;
    end
    else
      Result := TSWFBevelFilter(F);
end;

function TFlashPlaceObject.GetBlurFilter: TSWFBlurFilter;
 var F: TSWFFilter;
begin
  F := FindFilter(fidBlur);
  if F = nil then
    begin
      Result := TSWFBlurFilter(PlaceObject.SurfaceFilterList.AddFilter(fidBlur));
      if Owner <> nil then
       with owner.GlobalFilterSettings do
        begin
          Result.BlurX := BlurX;
          Result.BlurY := BlurY;
          Result.Passes := byte(Quality) + 1;
        end;
    end else
      Result := TSWFBlurFilter(F);
end;

function TFlashPlaceObject.GetCharacterID: Word;
begin
  Result := PlaceObject.CharacterID;
end;

function TFlashPlaceObject.GetClipDepth: Word;
begin
  Result := PlaceObject.ClipDepth;
end;

function TFlashPlaceObject.GetColorTransform: TSWFColorTransform;
begin
  Result := PlaceObject.ColorTransform;
end;

function TFlashPlaceObject.GetConvolutionFilter: TSWFConvolutionFilter;
 var F: TSWFFilter;
begin
  F := FindFilter(fidConvolution);
  if F = nil
    then
      Result := TSWFConvolutionFilter(PlaceObject.SurfaceFilterList.AddFilter(fidConvolution))
    else
      Result := TSWFConvolutionFilter(F);
end;

function TFlashPlaceObject.GetColorMatrixFilter: TSWFColorMatrixFilter;
  var F: TSWFFilter;
begin
  F := FindFilter(fidColorMatrix);
  if F = nil then
    begin
      Result := TSWFColorMatrixFilter(PlaceObject.SurfaceFilterList.AddFilter(fidColorMatrix));
      if owner <> nil then
        with owner.GlobalFilterSettings do
          Result.AdjustColor(Brightness, Contrast, Saturation, Hue);
    end
    else
      Result := TSWFColorMatrixFilter(F);
end;


function TFlashPlaceObject.GetDepth: Word;
begin
  Result := PlaceObject.Depth;
end;

function TFlashPlaceObject.FindFilter(fid: TSWFFilterID): TSWFFilter;
 var il: integer;
begin
 Result := nil;
 with PlaceObject.SurfaceFilterList do
  for il := 0 to Count - 1 do
   if fid = Filter[il].FilterID then
    begin
      Result := Filter[il];
      Break;
    end;
end;

function TFlashPlaceObject.GetGradientBevelFilter: TSWFGradientBevelFilter;
 var F: TSWFFilter;
begin
  F := FindFilter(fidGradientBevel);
  if F = nil then
    begin
      Result := TSWFGradientBevelFilter(PlaceObject.SurfaceFilterList.AddFilter(fidGradientBevel));
      if Owner <> nil then
       with owner.GlobalFilterSettings do
       begin
          Result.BlurX := BlurX;
          Result.BlurY := BlurY;
          Result.Distance := Distance;
          Result.Angle := DegToRad(Angle);
          Result.GradientColor[1].Assign(GlowColor);
          Result.GradientColor[2].Assign(ShadowColor);
          Result.Strength := Strength / 100;
          Result.InnerShadow := Inner;
          Result.Knockout := Knockout;
          Result.Passes := byte(Quality) + 1;
          Result.CompositeSource := not HideObject;
          Result.OnTop := OnTop;
        end;
    end else
      Result := TSWFGradientBevelFilter(F);
end;

function TFlashPlaceObject.GetGradientGlowFilter: TSWFGradientGlowFilter;
 var F: TSWFFilter;
begin
  F := FindFilter(fidGradientGlow);
  if F = nil
    then
     begin
      Result := TSWFGradientGlowFilter(PlaceObject.SurfaceFilterList.AddFilter(fidGradientGlow));
      if Owner <> nil then
       with Owner.GlobalFilterSettings do
        begin
          Result.BlurX := BlurX;
          Result.BlurY := BlurY;
          Result.GradientColor[1].Assign(GlowColor);
          Result.GradientColor[2].Assign(ShadowColor);
          Result.Strength := Strength / 100;
          Result.InnerShadow := Inner;
          Result.Knockout := Knockout;
          Result.Passes := byte(Quality) + 1;
          Result.CompositeSource := not HideObject;
          Result.OnTop := OnTop;
        end;
     end
    else
      Result := TSWFGradientGlowFilter(F);
end;

function TFlashPlaceObject.GetGlowFilter: TSWFGlowFilter;
 var F: TSWFFilter;
begin
  F := FindFilter(fidGlow);
  if F = nil then
    begin
      Result := TSWFGlowFilter(PlaceObject.SurfaceFilterList.AddFilter(fidGlow));
      if Owner <> nil then
       with Owner.GlobalFilterSettings do
        begin
          Result.BlurX := BlurX;
          Result.BlurY := BlurY;
          Result.GlowColor.Assign(GlowColor);
          Result.Strength := Strength / 100;
          Result.InnerGlow := Inner;
          Result.Knockout := Knockout;
          Result.Passes := byte(Quality) + 1;
          Result.CompositeSource := not HideObject;
        end;
    end
    else
      Result := TSWFGlowFilter(F);
end;

function TFlashPlaceObject.GetMatrix: TSWFMatrix;
begin
  Result := PlaceObject.Matrix;
end;

function TFlashPlaceObject.GetName: string;
begin
  Result := PlaceObject.Name;
end;

function TFlashPlaceObject.GetRatio: Word;
begin
  Result := PlaceObject.Ratio;
end;

function TFlashPlaceObject.GetRemoveDepth: Boolean;
begin
  Result := PlaceObject.PlaceFlagMove;
end;

function TFlashPlaceObject.GetTranslateX: LongInt;
begin
 if FVisualObject = nil
   then
     Result := PlaceObject.Matrix.TranslateX div Owner.MultCoord
   else
     Result := PlaceObject.Matrix.TranslateX div FVisualObject.MultCoord;
end;

function TFlashPlaceObject.GetTranslateY: LongInt;
begin
 if FVisualObject = nil
   then
     Result := PlaceObject.Matrix.TranslateY div Owner.MultCoord
   else
     Result := PlaceObject.Matrix.TranslateY div FVisualObject.MultCoord;
end;

procedure TFlashPlaceObject.InitColorTransform(hasADD: boolean; addR, addG, addB, addA: Smallint; hasMULT: boolean; multR,
        multG, multB, multA: Smallint; hasAlpha: boolean);
begin
  //PlaceObject.PlaceFlagHasColorTransform := true;
  PlaceObject.ColorTransform.REC :=
    MakeColorTransform(hasADD, addR, addG, addB, addA, hasMULT, multR, multG, multB, multA, hasAlpha);
end;

function TFlashPlaceObject.MinVersion: Byte;
begin
  if PlaceObject.BlendMode > bmNormal then
    Result := SWFVer8 else
  if PlaceObject.PlaceFlagHasClipActions then
    Result := SWFVer5
   else Result := SWFVer3;
end;

function TFlashPlaceObject.OnClick: TFlashActionScript;
begin
  fActions.FActionList := FindActionEvent(ceRelease).Actions;
  Result := fActions;
end;


function TFlashPlaceObject.OnConstruct: TFlashActionScript;
begin
  fActions.FActionList := FindActionEvent(ceConstruct).Actions;
  Result := fActions;
end;

function TFlashPlaceObject.OnData: TFlashActionScript;
begin
  fActions.FActionList := FindActionEvent(ceData).Actions;
  Result := fActions;
end;

function TFlashPlaceObject.OnDragOut: TFlashActionScript;
begin
  fActions.FActionList := FindActionEvent(ceDragOut).Actions;
  Result := fActions;
end;

function TFlashPlaceObject.OnDragOver: TFlashActionScript;
begin
  fActions.FActionList := FindActionEvent(ceDragOver).Actions;
  Result := fActions;
end;

function TFlashPlaceObject.OnEnterFrame: TFlashActionScript;
begin
  fActions.FActionList := FindActionEvent(ceEnterFrame).Actions;
  Result := fActions;
end;

function TFlashPlaceObject.OnInitialize: TFlashActionScript;
begin
  fActions.FActionList := FindActionEvent(ceInitialize).Actions;
  Result := fActions;
end;

function TFlashPlaceObject.OnKeyDown: TFlashActionScript;
begin
  fActions.FActionList := FindActionEvent(ceKeyDown).Actions;
  Result := fActions;
end;

function TFlashPlaceObject.OnKeyPress(Key: byte = 0): TFlashActionScript;
var
  AR: TSWFClipActionRecord;
begin
  AR := FindActionEvent(ceKeyPress);
  AR.KeyCode := Key;
  fActions.FActionList := AR.Actions;
  Result := fActions;
end;

function TFlashPlaceObject.OnKeyUp: TFlashActionScript;
begin
  fActions.FActionList := FindActionEvent(ceKeyUp).Actions;
  Result := fActions;
end;

function TFlashPlaceObject.OnLoad: TFlashActionScript;
begin
  fActions.FActionList := FindActionEvent(ceLoad).Actions;
  Result := fActions;
end;

function TFlashPlaceObject.OnMouseDown: TFlashActionScript;
begin
  fActions.FActionList := FindActionEvent(ceMouseDown).Actions;
  Result := fActions;
end;

function TFlashPlaceObject.OnMouseMove: TFlashActionScript;
begin
  fActions.FActionList := FindActionEvent(ceMouseMove).Actions;
  Result := fActions;
end;

function TFlashPlaceObject.OnMouseUp: TFlashActionScript;
begin
  fActions.FActionList := FindActionEvent(ceMouseUp).Actions;
  Result := fActions;
end;

function TFlashPlaceObject.OnPress: TFlashActionScript;
begin
  fActions.FActionList := FindActionEvent(cePress).Actions;
  Result := fActions;
end;

function TFlashPlaceObject.OnRelease: TFlashActionScript;
begin
  fActions.FActionList := FindActionEvent(ceRelease).Actions;
  Result := fActions;
end;

function TFlashPlaceObject.OnReleaseOutside: TFlashActionScript;
begin
  fActions.FActionList := FindActionEvent(ceReleaseOutside).Actions;
  Result := fActions;
end;

function TFlashPlaceObject.OnRollOut: TFlashActionScript;
begin
  fActions.FActionList := FindActionEvent(ceRollOut).Actions;
  Result := fActions;
end;

function TFlashPlaceObject.OnRollOver: TFlashActionScript;
begin
  fActions.FActionList := FindActionEvent(ceRollOver).Actions;
  Result := fActions;
end;

function TFlashPlaceObject.OnUnload: TFlashActionScript;
begin
  fActions.FActionList := FindActionEvent(ceUnload).Actions;
  Result := fActions;
end;

procedure TFlashPlaceObject.SetCharacterID(Value: Word);
begin
  PlaceObject.CharacterID := Value;
end;

procedure TFlashPlaceObject.SetClipDepth(Value: Word);
begin
  PlaceObject.ClipDepth := Value;
end;

procedure TFlashPlaceObject.SetDepth(Value: Word);
begin
  PlaceObject.Depth := Value;
end;

procedure TFlashPlaceObject.SetName(n: string);
begin
  PlaceObject.Name := n;
end;

procedure TFlashPlaceObject.SetPosition(X, Y: longint);
begin
  if (X = 0) and (Y = 0) and not PlaceObject.PlaceFlagHasMatrix
    and not RemoveDepth then Exit;
  if FVisualObject = nil
   then
     PlaceObject.Matrix.SetTranslate(X * Owner.MultCoord, Y * Owner.MultCoord)
   else
     PlaceObject.Matrix.SetTranslate(FVisualObject.fXCenter + X * Owner.MultCoord,
                                  FVisualObject.fYCenter + Y * Owner.MultCoord);
end;

procedure TFlashPlaceObject.SetRatio(Value: Word);
begin
  PlaceObject.Ratio := Value;
end;

procedure TFlashPlaceObject.SetRemoveDepth(v: Boolean);
begin
  PlaceObject.PlaceFlagMove := v;
end;

procedure TFlashPlaceObject.SetRotate(angle: single);
begin
  PlaceObject.Matrix.SetRotate(angle);
end;

procedure TFlashPlaceObject.SetScale(ScaleX, ScaleY: single);
begin
  PlaceObject.Matrix.SetScale(ScaleX, ScaleY);
end;

procedure TFlashPlaceObject.SetSkew(SkewX, SkewY: single);
begin
  PlaceObject.Matrix.SetSkew(SkewX, SkewY);
end;

procedure TFlashPlaceObject.SetTranslate(X, Y: longint);
begin
  if (X = 0) and (Y = 0) and not PlaceObject.PlaceFlagHasMatrix
    and not RemoveDepth then Exit;
  PlaceObject.Matrix.SetTranslate(X * Owner.MultCoord, Y * Owner.MultCoord);
end;

procedure TFlashPlaceObject.SetTranslateX(Value: LongInt);
begin
  PlaceObject.Matrix.TranslateX := Value * FVisualObject.MultCoord;
end;

procedure TFlashPlaceObject.SetTranslateY(Value: LongInt);
begin
  PlaceObject.Matrix.TranslateY := Value * FVisualObject.MultCoord;
end;

function TFlashPlaceObject.GetBlendMode: TSWFBlendMode;
begin
 Result := PlaceObject.BlendMode;
end;

procedure TFlashPlaceObject.SetBlendMode(const Value: TSWFBlendMode);
begin
 PlaceObject.BlendMode := Value;
 if Value > bmNormal then
   PlaceObject.PlaceFlagHasBlendMode := true;
end;

function TFlashPlaceObject.GetFilterList: TSWFFilterList;
begin
  Result := PlaceObject.SurfaceFilterList;
end;

function TFlashPlaceObject.GetUseBitmapCaching: Boolean;
begin
  Result := PlaceObject.PlaceFlagHasCacheAsBitmap;
end;


procedure TFlashPlaceObject.SetUseBitmapCaching(const Value: Boolean);
begin
  PlaceObject.PlaceFlagHasCacheAsBitmap := Value;
end;

procedure TFlashPlaceObject.WriteToStream(be: TBitsEngine);
begin
 PlaceObject.SaveAsPO2 := (PlaceObject.BlendMode <= bmNormal) and
                          (not PlaceObject.PlaceFlagHasFilterList) and
                          (not UseBitmapCaching);
 if PlaceObject.SaveAsPO2
   then PlaceObject.TagID := tagPlaceObject2
   else PlaceObject.TagID := tagPlaceObject3;
 PlaceObject.WriteToStream(BE);
end;

{
***************************************************** TFlashPlaceVideo ******************************************************
}
constructor TFlashPlaceVideo.Create(owner: TFlashMovie; Video: TFlashVisualObject; depth: word);
begin
  inherited;
  AutoReplay := true;
end;

destructor TFlashPlaceVideo.Destroy;
begin
  inherited;
end;

procedure TFlashPlaceVideo.Assign(Source: TBasedSWFObject);
begin
  inherited;
  With TFlashPlaceVideo(Source) do
  begin
    self.AutoReplay := AutoReplay;
    self.StartFrame := StartFrame;
    self.FEnableSound := EnableSound;
    if Assigned(FPlaceFrame) then self.FPlaceFrame := FPlaceFrame;
    if Assigned(FWriteFrame) then self.FWriteFrame := FWriteFrame;
  end;
end;

function TFlashPlaceVideo.GetCharacterID: Word;
begin
  Result := Video.CharacterID;
end;

function TFlashPlaceVideo.GetVideo: TFlashVideo;
begin
  Result := TFlashVideo(FVisualObject);
end;

function TFlashPlaceVideo.MinVersion: Byte;
begin
  Result := SWFVer3;
end;

procedure TFlashPlaceVideo.SetEnableSound(Value: Boolean);
var
  il: Word;
begin
  FEnableSound := Value and Video.FLV.SoundExist;
  if EnableSound then
    begin
      if SpriteParent = nil then
        begin
          if (owner <> nil) and owner.EnableBGSound then owner.EnableBGSound := false;
          if owner.VideoListCount > 0 then
           for il := 0 to owner.VideoListCount - 1 do
            if owner.VideoList[il] <> self then
             owner.VideoList[il].EnableSound := false;
        end else
        begin
          if SpriteParent.EnableBGSound then SpriteParent.EnableBGSound := true;
          if SpriteParent.VideoListCount > 0 then
           for il := 0 to SpriteParent.VideoListCount - 1 do
            if SpriteParent.VideoList[il] <> self then
             SpriteParent.VideoList[il].EnableSound := false;
        end;
    end;
end;


procedure TFlashPlaceVideo.WriteToStream(be: TBitsEngine; Frame:Word);
var
  P: TWriteFrameInfo;
  PlaceStream: TFlashPlaceObject;
  VFrame: TSWFVIdeoFrame;
  CurentFrame: Word;
  SH: TSWFSoundStreamHead;
  il, T, Sum: Word;
  FLVSound: TVFrame;
begin
  if (Frame >= StartFrame) then
    begin
      CurentFrame := (Frame - StartFrame);
      if not AutoReplay and (CurentFrame >= Video.FLV.FrameCount) then Exit
       else
         CurentFrame := CurentFrame mod Max(1,Video.FLV.FrameCount);
    end
  else exit;

  P.ID := CharacterID;
  P.Frame := Frame - StartFrame;
  P.Depth := Depth;

  if Assigned(FWriteFrame) then onWriteFrame(be, P)
  else
  begin
    PlaceStream := TFlashPlaceObject.Create(owner, nil, Depth);
    PlaceStream.Assign(self);
    if (Frame - StartFrame) = 0 then
    begin
      PlaceStream.Ratio := 0;
     // ---------  SOUND header  -----------
      if EnableSound then
       with Video.FLV do
       begin
        SH := TSWFSoundStreamHead.Create;

        SH.PlaybackSoundRate := SoundHeader.SoundRate;

//        SH.PlaybackSoundRate := (Video.FLV.SoundHeader.SoundFormat and $C) shr 2;
        case  SH.PlaybackSoundRate of
         0: SndBitRate := 5512;    // Snd5k;
         1: SndBitRate := 11025;   // Snd11k;
         2: SndBitRate := 22050;   // Snd22k;
         3: SndBitRate := 44100;   // Snd44k;
        end;
        SH.PlaybackSoundSize := SoundHeader.Is16Bit;
        SH.PlaybackSoundType := SoundHeader.IsStereo;
        SH.StreamSoundCompression := SoundHeader.SoundFormat;
        SH.StreamSoundRate := SH.PlaybackSoundRate;
        SH.StreamSoundSize := SH.PlaybackSoundSize;
        SH.StreamSoundType := SH.PlaybackSoundType;
        SndSampleCount := Round(SndBitRate / Owner.FPS);
        SH.StreamSoundSampleCount := SndSampleCount;

        if SH.StreamSoundCompression = snd_MP3 then
          begin
            SndSeekSample := MPEG_SAMPLES_FRAME[(SoundHeader.MP3Frame and $180000) shr 19,
                                            (SoundHeader.MP3Frame and $C00) shr 10];
            SH.LatencySeek := SndSampleCount mod SndSeekSample;
          end;
        SH.WriteToStream(be);
        SH.Free;
       end;
    end else
    begin
      PlaceStream.RemoveDepth := True;
      PlaceStream.Ratio := CurentFrame;
    end;
      // SampleCount - VideoFrame
      // SeekSample  - MP3Frame
    if EnableSound and (SndCount < Video.FLV.SoundCount) then
      begin
       with Video.FLV do
       begin
         case SoundHeader.SoundFormat of
          snd_MP3: begin
            il := (SndSampleCount + SndLatency) div SndSeekSample;
            if (il = 0) or (P.Frame = 0) then inc(il);
            if (SndCount + il) <  SoundCount then
            begin
              be.WriteWord(tagSoundStreamBlock shl 6 + $3F);
              Sum := 0;
              For T:=0 to il-1 do Sum := Sum + GetSoundFromList(SndCount+T).Len;
              be.WriteDWord(Sum + 4);

              be.WriteWord(SndSeekSample * il);
              be.WriteWord(SndLatency);

              SndLatency := (SndSampleCount + SndLatency) mod SndSeekSample;
              repeat
               T:=GetSoundFromList(SndCount).Len;
               if T > 0 then
                begin
                 Data.Position := GetSoundFromList(SndCount).Start;
                 be.BitsStream.CopyFrom(Video.FLV.Data, T);
                end;
               Inc(SndCount);
               dec(il);
              until not boolean(il);
            end
            else inc( SndCount, il);
          end;

          snd_Nellymoser: begin
            FLVSound := GetSoundFromList(SndCount);

            be.WriteWord(tagSoundStreamBlock shl 6 + $3F);
            T := FLVSound.Len;
            be.WriteDWord(0);
            Sum := 0;
            while (FLVSound <> nil) and (FLVSound.InVideoPos = CurentFrame) do
              begin
                if T > 0 then
                  begin
                   Data.Position := FLVSound.Start;
                   be.BitsStream.CopyFrom(Video.FLV.Data, T);
                   Sum := Sum + T;
                  end;
                inc(SndCount);
                if SoundCount > SndCount
                  then FLVSound := GetSoundFromList(SndCount)
                  else FLVSound :=  nil;
                if FLVSound <> nil then
                  T := FLVSound.Len;
              end;
            if Sum > 0 then
              begin
                be.BitsStream.Seek(- Sum - 4, 1);
                be.WriteDWord(Sum);
                be.BitsStream.Seek(Sum, 1);
              end;
          end;
         end;
       end;
    end;
    VFrame := TSWFVIdeoFrame.Create;
    VFrame.StreamID := CharacterID;
    VFrame.FrameNum := CurentFrame;
    VFrame.OnDataWrite := Video.WriteFrame;
    VFrame.WriteToStream(be);
    VFrame.Free;

    if Assigned(FPlaceFrame)then OnPlaceFrame(be, P, PlaceStream);
    PlaceStream.WriteToStream(be);
    PlaceStream.Free;
  end;
end;

// =============================================================//
//                             TEXT                             //
// =============================================================//
{
***************************************************** TFlashCustomData ******************************************************
}
constructor TFlashCustomData.Create(owner: TFlashMovie; FileName:string = '');
begin
  inherited Create(owner);
  FData := TMemoryStream.Create;
  if FileExists(FileName) then
   begin
     Data.LoadFromFile(FileName);
   end;
end;

constructor TFlashCustomData.Create(owner: TFlashMovie; S: TStream; Size: longint = 0);
begin
  inherited Create(owner);
  FData := TMemoryStream.Create;
  if Size= 0 then Data.LoadFromStream(S)
    else Data.CopyFrom(S, Size);
end;

destructor TFlashCustomData.Destroy;
begin
  FData.Free;
  inherited;
end;

procedure TFlashCustomData.Assign(Source: TBasedSWFObject);
begin
  With TFlashCustomData(Source) do
  begin
    Data.Position := 0;
    self.Data.CopyFrom(Data, Data.Size);
    self.TagId := TagId;
    self.WriteHeader := WriteHeader;
  end;
end;

function TFlashCustomData.MinVersion: Byte;
begin
  Result := SWFVer3;
end;

procedure TFlashCustomData.WriteToStream(be: TBitsEngine);
begin
  If Data.Size > 0 then
    begin
      Data.Position := 0;
      if WriteHeader
        then
          WriteCustomData(be.BitsStream, TagID, Data)
        else
          be.BitsStream.CopyFrom(Data, Data.Size);
    end;
end;

function _CodeSort(P1, P2: Pointer): Integer;
 var Ch1, Ch2: longint;
begin
  Ch1 := LongInt(P1);
  Ch2 := LongInt(P2);
  if Ch1 > Ch2 then Result := 1 else
    if Ch1 = Ch2 then Result := 0 else Result := -1;
end;

{
******************************************************** TFlashFont *********************************************************
}
constructor TFlashFont.Create(owner: TFlashMovie);
begin
  inherited Create(owner);
  self.asDevice := true;
end;

constructor TFlashFont.Create(owner: TFlashMovie; asDevice: boolean; Name: string; bold, italic: boolean; size: word);
begin
  inherited Create(owner);
  self.asDevice := asDevice;
  self.Name := Name;
  self.bold := bold;
  self.italic := italic;
  self.size := size;
end;

destructor TFlashFont.Destroy;
begin
  if FCharList <> nil then FCharList.Free;
  inherited ;
end;

procedure TFlashFont.AddChars(s: ansistring);
var
  il: Integer;
begin
  if (s = '') then Exit;
  for il := 1 to length(s) do AddEmpty(ord(s[il]));
end;

procedure TFlashFont.AddChars(chset: TCharSets);
var
  il: Byte;
begin
  for il := 32 to 255 do
    if chr(il) in chset then AddEmpty(il);
end;

{$IFNDEF VER130}
procedure TFlashFont.AddChars(s: WideString);
begin
  AddCharsW(S);
end;
{$ENDIF}

procedure TFlashFont.AddChars(min, max: word);
var
  il: Word;
begin
  for il := min to max do AddEmpty(il);
end;

procedure TFlashFont.AddCharsW(s: WideString);
var
  il: Integer;
begin
  if (s = '') then Exit;
  FWideCodes := true;
  for il := 1 to Length(s) do AddEmpty(Word(s[il]));
end;

function TFlashFont.AddEmpty(Ch: word): Boolean;
var
  il, CharCode, NewCode: Word;
  NewChar: TFlashChar;
begin
  Result := true;
  if Ch > $FF then FWideCodes := true;

  if CharList.Count > 0 then
   begin
    if FWideCodes then NewCode := ch
      else NewCode := ord(WideString(chr(Ch))[1]);
  
    for il := 0 to CharList.Count -1 do
      begin
        if Ch < $80 then CharCode := CharInfoInd[il].Code
           else CharCode := CharInfoInd[il].WideCode;
        if (NewCode = CharCode) then
          begin
            CharInfoInd[il].IsUsed := true;
            Result := false;
            Break;
          end else
        if NewCode < CharCode then
          begin
             NewChar := TFlashChar.Create(Ch, FWideCodes);
             CharList.Insert(il, NewChar);
             Break;
          end else
        if (il = (CharList.Count - 1)) and (NewCode > CharCode) then
          begin
            NewChar := TFlashChar.Create(Ch, FWideCodes);
            CharList.Add(NewChar);
          end;
      end;
   end else
   begin
     NewChar := TFlashChar.Create(Ch, FWideCodes);
     CharList.Add(NewChar);
   end;
   if FWideCodes and (Owner.Version < SWFVer6) then Owner.Version := SWFVer6;
end;

procedure TFlashFont.Assign(Source: TBasedSWFObject);
var
  il: Word;
  Ch: TFlashChar;
begin
  inherited;
  With TFlashFont(Source) do
  begin
    self.AsDevice := AsDevice;
    self.Bold := Bold;
    self.EncodingType := EncodingType;
    self.Ascent := Ascent;
    self.FontCharset := FontCharset;
    self.Descent := Descent;
    self.Leading := Leading;
    self.Layout := Layout;
    self.IncludeKerning := IncludeKerning;
    self.Italic := Italic;
    self.LanguageCode := LanguageCode;
    self.Name := Name ;
    self.FSize := FSize;
    self.SmallText := SmallText;
    self.FontUsing := FontUsing;
    if CharList.Count > 0 then
     for il := 0 to CharList.Count - 1 do
      begin
        Ch := TFlashChar.Create(CharInfoInd[il].Code, FWideCodes);
        Ch.Assign(CharInfoInd[il]);
        self.CharList.Add(Ch);
      end;
  end;
end;

function TFlashFont.CalcMetric(V: longint): LongInt;
begin
  result := Round(V / EMS * FSize);
end;

procedure TFlashFont.FillCharsInfo;
var
  il: Integer;
  FDC, OldF: THandle;
  LF: TLogFont;
begin
  if CharList.Count = 0 then Exit;
  if FontInfo.lfFaceName = ''
    then LF := MakeLogFont(self)
    else LF := FontInfo;
  ReadFontMetric(self);
  FDC := CreateCompatibleDC(0);
  OldF := SelectObject(FDC, CreateFontIndirect(LF));
  if CharList.Count > 0 then
   For il := 0 to CharList.Count - 1 do
    with CharInfoInd[il] do
     if IsUsed and not ShapeInit then
      FillCharInfo(FDC, CharInfoInd[il]);
  DeleteObject(SelectObject(FDC, OldF));
  DeleteDC(FDC);
end;

function TFlashFont.GetAntiAlias: Boolean;
begin
  Result := not FSmallText;
end;

function TFlashFont.GetCharInfo(Code: Integer): TFlashChar;
var
  il: Integer;
begin
  Result := nil;
  if CharList.Count > 0 then
   for il := 0 to CharList.Count - 1 do
    if Code = CharInfoInd[il].Code then
      begin
       Result := CharInfoInd[il];
       Break;
      end;
end;

function TFlashFont.GetCharInfoInd(Index: Integer): TFlashChar;
begin
  Result := TFlashChar(CharList[index]);
end;

function TFlashFont.GetCharList: TObjectList;
begin
  If FCharList = nil then FCharList := TObjectList.Create;
  Result := FCharList;
end;

function TFlashFont.GetSize: word;
begin
  if owner = nil then Result := FSize
   else Result := FSize div owner.MultCoord;
end;

function TFlashFont.GetTextExtentPoint(s: string): TSize;
var
  FDC, OldF: THandle;
  LF: TLogFont;
begin
  FDC := CreateCompatibleDC(0);
  if FontInfo.lfFaceName = ''
    then LF := MakeLogFont(self)
    else LF := FontInfo;
  OldF := SelectObject(FDC, CreateFontIndirect(LF));
  GetTextExtentPoint32(FDC, pchar(S), Length(S), Result);
  Result.CX := CalcMetric(Result.CX);
  Result.CY := CalcMetric(Result.CY);
  DeleteObject(SelectObject(FDC, OldF));
  DeleteDC(FDC);
end;

{$IFNDEF VER130}
function TFlashFont.GetTextExtentPoint(s: WideString): TSize;
begin
  Result := GetTextExtentPointW(S);
end;
{$ENDIF}

function TFlashFont.GetTextExtentPointW(s: WideString): TSize;
var
  FDC, OldF: THandle;
  LF: TLogFont;
begin
  FDC := CreateCompatibleDC(0);
  if FontInfo.lfFaceName = ''
    then LF := MakeLogFont(self)
    else LF := FontInfo;
  OldF := SelectObject(FDC, CreateFontIndirect(LF));
  GetTextExtentPoint32W(FDC, PWideChar(S), Length(S), Result);
  Result.CX := CalcMetric(Result.CX);
  Result.CY := CalcMetric(Result.CY);
  DeleteObject(SelectObject(FDC, OldF));
  DeleteDC(FDC);
end;

function TFlashFont.GetWideCodes: Boolean;
var
  il: Integer;
begin
  Result := FWideCodes;
  if Result then Exit;
  if not asDevice and (CharList.Count > 0) then
   For il := 0 to CharList.Count - 1 do
    begin
     Result := CharInfoInd[il].isWide;
     If Result then Exit;
    end;
end;

procedure TFlashFont.LoadFromSWFObject(Src: TSWFDefineFont2);
 var il: longint;
     LE: TObjectList;
begin
 with src do
  begin
    Layout := FontFlagsHasLayout;
    if FontFlagsShiftJIS then EncodingType := encodeShiftJIS;
    SmallText := FontFlagsSmallText;
    if FontFlagsANSI then EncodingType := encodeANSI;
    if FontFlagsWideCodes then EncodingType := encodeUnicode;
    Italic := FontFlagsItalic;
    Bold := FontFlagsBold;
    self.LanguageCode := LanguageCode;
    Name := FontName;

    if FontFlagsHasLayout then
      begin
        Ascent := FontAscent;
        Descent := FontDescent;
        Leading := FontLeading;
      end;

    if CodeTable.Count > 0 then
     begin
       for il := 0 to CodeTable.Count - 1 do
        begin
          LE := TObjectList(GlyphShapeTable.Items[il]);
          AddEmpty(LongInt(CodeTable[il]));
          CopyShapeRecords(LE, CharInfoInd[il].ListEdges);
          CharInfoInd[il].IsUsed := false;
          CharInfoInd[il].ShapeInit := true;
          if FontFlagsHasLayout then
            begin
//              TSWFRect(FontBoundsTable[il]);  no uses
              CharInfoInd[il].GlyphAdvance := longint(FontAdvanceTable[il]);
              if IncludeKerning then
                  CharInfoInd[il].Kerning.Assign(TSWFKerningRecord(FontKerningTable[il]));
            end;
        end;
     end;   
  end;
end;

procedure TFlashFont.LoadFromSWFFile(FileName: string);
 var FS: TFileStream;
begin
  FS := TFileStream.Create(FileName, fmOpenRead);
  LoadFromSWFStream(FS);
  FS.Free;
end;

procedure TFlashFont.LoadFromSWFStream(src: TStream);
 var
     ACH: array [0..2] of char;
     DF: TSWFDefineFont2;
     BS: TBitsEngine;
     SWF: TSWFStreamReader;
     il: longint;
begin
  src.Read(ACH, 3);
  src.seek(-3, 1);
  if (ACH = SWFSign) or (ACH = SWFSignCompress) then
    begin
      SWF := TSWFStreamReader.Create(src);
      SWF.ReadBody(true, false);
      For il := 0 to SWF.TagList.Count - 1 do
        if SWF.TagInfo[il].TagID = tagDefineFont2 then
          begin
            DF := TSWFDefineFont2(SWF.TagInfo[il].SWFObject);
            if (Name = '') or
               ((DF.FontName = Name) and (DF.FontFlagsItalic = Italic) and (DF.FontFlagsBold = Bold))
              then
              begin
                LoadFromSWFObject(DF);
                Break
              end;
          end;
      SWF.Free;
    end else
    begin
      BS := TBitsEngine.Create(src);
      DF := TSWFDefineFont2.Create;
      DF.ReadFromStream(BS);
      LoadFromSWFObject(DF);
      DF.Free;
      BS.Free;
    end;
end;

function TFlashFont.MinVersion: Byte;
begin
  Result := SWFVer3;
end;


procedure TFlashFont.SetAntiAlias(Value: Boolean);
begin
  FSmallText := not Value;
end;

procedure TFlashFont.SetFontCharset(Value: Byte);
begin
  if FFontCharset <> Value then
   begin
    Case Value of
      ANSI_CHARSET, SYMBOL_CHARSET:
        begin
          LanguageCode := SWFLangNone;
          EncodingType := encodeANSI;
        end;
      DEFAULT_CHARSET:
        begin
          LanguageCode := SWFLangNone;
          EncodingType := encodeUnicode;
        end;
      SHIFTJIS_CHARSET:
        begin
          LanguageCode := SWFLangJapanese;
          EncodingType := encodeShiftJIS;
        end;
      GB2312_CHARSET:
          LanguageCode := SWFLangSChinese;
      CHINESEBIG5_CHARSET:
          LanguageCode := SWFLangTChinese;
      HANGEUL_CHARSET:
          LanguageCode := SWFLangKorean;
        else
          LanguageCode := $40; //  Value;
          EncodingType := encodeUnicode;
    end;
   end;
end;

procedure TFlashFont.SetFontInfo(Info: TLogFont);
begin
  FFontInfo := Info;
  FBold := Info.lfWeight = 700;
  FName := StrPas(Info.lfFaceName);
  FItalic := Info.lfItalic > 0;
  Size := Abs(Info.lfHeight);
  FontCharset := Info.lfCharSet;
  FFontInfo.lfHeight := -EMS;//Info.lfHeight * Owner.MultCoord;
  FFontInfo.lfOrientation := 0;
  FFontInfo.lfEscapement := 0;
  FFontInfo.lfWidth := 0;
end;

procedure TFlashFont.SetHasLayout(v: Boolean);
begin
  if v and not FHasLayout then
    begin
      ReadFontMetric(self);
    end;
  FHasLayout := v;
end;

procedure TFlashFont.SetSize(value: word);
begin
  if Owner = nil then FSize := value
   else FSize := value * Owner.MultCoord;
end;

procedure TFlashFont.WriteToStream(be: TBitsEngine);
var
  il, ncode: Word;
begin
  with TSWFDefineFont2.Create do
   begin
     if Owner = nil then SWFVersion := SWFVer6
       else SWFVersion := Owner.Version;

     FontId := CharacterID;
     FontFlagsHasLayout := Layout or (fuDynamicText in FontUsing);
     FontFlagsShiftJIS := EncodingType = encodeShiftJIS;
     FontFlagsSmallText := SmallText;
     FontFlagsANSI := EncodingType = encodeANSI;
     FontFlagsWideOffsets := NoSupport;
     FontFlagsWideCodes := (EncodingType = encodeUnicode) or WideCodes;
     FontFlagsItalic := Italic;
     FontFlagsBold := Bold;
     LanguageCode := self.LanguageCode;
     FontName := Name;

     if (FontFlagsHasLayout or ((FCharList <> nil) and (FCharList.Count > 0))) and
        ((Ascent = 0) and (Descent = 0) and (Leading = 0))
       then ReadFontMetric(self);

     if FontFlagsHasLayout then
       begin
         FontAscent := Ascent;
         FontDescent := Descent;
         FontLeading := Leading;
         if IncludeKerning then
           FontKerningTable.OwnsObjects := false;
       end;

     if ((not asDevice) or (fuStaticText in FontUsing)) and
        ((FCharList <> nil) and (FCharList.Count > 0)) then
      begin
        GlyphShapeTable.OwnsObjects := false;
        FillCharsInfo;
        For il := 0 to FCharList.Count - 1 do
         with CharInfoInd[il] do
          if IsUsed then
           begin
             GlyphShapeTable.Add(ListEdges);
             if FontFlagsWideCodes then ncode := WideCode
               else ncode := Code;
             CodeTable.Add(Pointer(Longint(ncode)));

             if FontFlagsHasLayout then
               begin
                 FontBoundsTable.Add(TSWFRect.Create);
                 FontAdvanceTable.Add(Pointer(LongInt(GlyphAdvance)));
                 if IncludeKerning then FontKerningTable.Add(Kerning);
               end;
           end;
        if not FontFlagsWideCodes then CodeTable.Sort(_CodeSort);
      end;
  
     WriteToStream(be);
     free;
   end;
end;

{
******************************************************** TFlashText *********************************************************
}
constructor TFlashText.Create(owner: TFlashMovie; s: ansistring);
begin
  inherited Create(owner);
  InitVar(s);
end;

constructor TFlashText.Create(owner: TFlashMovie; s: ansistring; c: recRGBA; f: TFlashFont; P: TPoint; Align: byte);
begin
  inherited Create(owner);
  Font := f;
  InitVar(s);
  Color.RGBA := C;
  FPtAnchor.X := P.X * MultCoord;
  FPtAnchor.Y := P.Y * MultCoord;
  self.Align := Align;
  Autosize := true;
  InitAsPoint := true;
  FTextHeight := Abs(f.FSize);
  FUseOutlines := not f.AsDevice;
end;

constructor TFlashText.Create(owner: TFlashMovie; s: ansistring; c: recRGBA; f: TFlashFont; R: TRect);
begin
  inherited Create(owner);
  Font := f;
  InitVar(s);
  Color.RGBA := C;
  SetBounds(R);
  FPtAnchor := Bounds.Rect.TopLeft;
  InitAsPoint := false;
  FTextHeight := Abs(f.FSize);
  FUseOutlines := not f.AsDevice;
end;

{$IFNDEF VER130}
constructor TFlashText.Create(owner: TFlashMovie; s: WideString; c: recRGBA; f: TFlashFont; P: TPoint; Align: byte);
begin
  inherited Create(owner);
  Font := f;
  InitVarW(s);
  Color.RGBA := C;
  FPtAnchor.X := P.X * MultCoord;
  FPtAnchor.Y := P.Y * MultCoord;
  self.Align := Align;
  Autosize := true;
  InitAsPoint := true;
  FTextHeight := Abs(f.FSize);
  FUseOutlines := not f.AsDevice;
end;

constructor TFlashText.Create(owner: TFlashMovie; s: WideString; c: recRGBA; f: TFlashFont; R: TRect);
begin
  inherited Create(owner);
  Font := f;
  InitVarW(s);
  Color.RGBA := C;
  SetBounds(R);
  FPtAnchor := Bounds.Rect.TopLeft;
  InitAsPoint := false;
  FTextHeight := Abs(f.FSize);
  FUseOutlines := not f.AsDevice;
end;
{$ENDIF}

constructor TFlashText.CreateW(owner: TFlashMovie; s: WideString; c: recRGBA; f: TFlashFont; P: TPoint; Align: byte);
begin
  inherited Create(owner);
  Font := f;
  InitVarW(s);
  Color.RGBA := C;
  FPtAnchor.X := P.X * MultCoord;
  FPtAnchor.Y := P.Y * MultCoord;
  self.Align := Align;
  Autosize := true;
  InitAsPoint := true;
  FTextHeight := Abs(f.FSize);
  FUseOutlines := not f.AsDevice;
end;

constructor TFlashText.CreateW(owner: TFlashMovie; s: WideString; c: recRGBA; f: TFlashFont; R: TRect);
begin
  inherited Create(owner);
  Font := f;
  InitVarW(s);
  Color.RGBA := C;
  SetBounds(R);
  FPtAnchor := R.TopLeft;
  InitAsPoint := false;
  FTextHeight := Abs(f.FSize);
  FUseOutlines := not f.AsDevice;
end;

destructor TFlashText.Destroy;
begin
  if Assigned(FMatrix) then FMatrix.Free;
  FBounds.Free;
  FColor.Free;
  inherited;
end;

procedure TFlashText.Assign(Source: TBasedSWFObject);
begin
  inherited;
  With TFlashText(Source) do
  begin
    self.Align := Align;
    self.AutoSize := AutoSize;
    self.Border := Border;
    self.Bounds.Assign(Bounds);
  
    self.DynamicText := DynamicText;
    if self.Owner = owner then self.FFont := Font;
    self.HasLayout := HasLayout;
    if HasLayout then
     begin
       self.Indent := Indent;
       self.RightMargin := RightMargin;
       self.LeftMargin := LeftMargin;
       self.Leading := Leading;
     end;
    self.HTML := HTML;
    if FMatrix <> nil then
      self.Matrix.Assign(Matrix);
    self.Multiline := Multiline;
    self.NoSelect := NoSelect;
    self.Password := Password;
    self.FPtAnchor := FPtAnchor;
    self.ReadOnly := ReadOnly;
    self.Text := Text;
  //      if wText <> nil then
  //      begin
  //        self.Text := WideCharLenToString(wText, wLength);
  //      end;
    self.TextHeight := TextHeight;
    self.UseOutlines := UseOutlines;
    self.VarName := VarName;
    self.WordWrap := WordWrap;
    self.HasColor := HasColor;
    if HasColor then
      self.Color.Assign(Color);
    self.HasMaxLen := HasMaxLen;
    if HasMaxLen then
      self.MaxLength := MaxLength;
  end;
end;

function TFlashText.GetCharSpacing: Integer;
begin
  Result := FCharSpacing div MultCoord;
end;

function TFlashText.GetColor: TSWFRGBA;
begin
  HasColor := true;
  Result := FColor;
end;

function TFlashText.GetDynamicText: Boolean;
begin
  Result := FDynamicText;
end;

function TFlashText.GetIndent: Integer;
begin
  Result := FIndent div MultCoord;
end;

function TFlashText.GetLeading: Integer;
begin
  Result := FLeading div MultCoord;
end;

function TFlashText.GetLeftMargin: Integer;
begin
  Result := FLeftMargin div MultCoord;
end;

function TFlashText.GetMatrix: TSWFMatrix;
begin
  if FMatrix = nil then FMatrix := TSWFMatrix.Create;
  Result := FMatrix;
end;

function TFlashText.GetRightMargin: Integer;
begin
  Result := FRightMargin div MultCoord;
end;

function TFlashText.GetTextExtentPoint: TSize;
begin
  if Assigned(Font) then
{$IFNDEF VER130}
    Result := Font.GetTextExtentPointW(WideText);
{$ELSE}
    Result := Font.GetTextExtentPoint(Text);
{$ENDIF}
end;

function TFlashText.GetTextHeight: Word;
begin
  Result := FTextHeight div MultCoord;
end;

procedure TFlashText.InitVar(s: string);
begin
  text := S;
  FCharSpacing := 0;
  FBounds := TSWFRect.Create;
  FColor := TSWFRGBA.Create;
end;

{$IFNDEF VER130}
procedure TFlashText.InitVar(S: WideString);
begin
  InitVarW(S);
end;
{$ENDIF}

procedure TFlashText.InitVarW(S: WideString);
begin
  WideText := S;
  Text := S;
  FCharSpacing := 0;
  FBounds := TSWFRect.Create;
  FColor := TSWFRGBA.Create;
end;

function TFlashText.MinVersion: Byte;
begin
  Result := SWFVer3 + byte(DynamicText);
end;


procedure TFlashText.SetAlign(Value: TSWFTextAlign);
begin
  HasLayout := true;
  FAlign := Value;
end;

procedure TFlashText.SetCharSpacing(Value: Integer);
begin
  FCharSpacing := Value * MultCoord;
end;

procedure TFlashText.SetDynamicText(Value: Boolean);
begin
  if value then
   begin
     ReadOnly := false;
     NoSelect := false;
   end;
  FDynamicText := Value;
end;

procedure TFlashText.SetFont(F: TFlashFont);
begin
  FFont := F;
  if DynamicText
    then F.FontUsing := F.FontUsing + [fuDynamicText]
    else F.FontUsing := F.FontUsing + [fuStaticText];
end;

procedure TFlashText.SetBounds(R: TRect);
begin
  Bounds.Rect := Rect(R.Left * MultCoord, R.Top * MultCoord,
                      R.Right * MultCoord, R.Bottom * MultCoord);
end;

procedure TFlashText.SetHasLayout(Value: Boolean);
begin
  if Font <> nil then Font.Layout := value;
  FHasLayout := Value;
end;

procedure TFlashText.SetHTML(Value: Boolean);
begin
  if Value then FDynamicText := true;
  FHTML := Value;
end;

procedure TFlashText.SetIndent(Value: Integer);
begin
  HasLayout := true;
  FIndent := value * MultCoord;
end;

procedure TFlashText.SetLeading(Value: Integer);
begin
  HasLayout := true;
  FLeading := Value * MultCoord;
end;

procedure TFlashText.SetLeftMargin(Value: Integer);
begin
  HasLayout := true;
  FLeftMargin := value * MultCoord;
end;

procedure TFlashText.SetMaxLength(Value: Integer);
begin
  HasMaxLen := true;
  FMaxLength := Value;
end;

procedure TFlashText.SetRightMargin(Value: Integer);
begin
  HasLayout := true;
  FRightMargin := value * MultCoord;
end;

procedure TFlashText.SetText(Value: AnsiString);
begin
  if FText <> Value then
   begin
     if Font <> nil then Font.AddChars(Value);
     FText := Value;
   end;
end;

procedure TFlashText.SetTextHeight(Value: Word);
begin
  FTextHeight := Value * MultCoord;
end;

procedure TFlashText.SetUseOutlines(Value: Boolean);
begin
  FUseOutlines := Value;
  if Font <> nil then Font.AsDevice := false;
end;

procedure TFlashText.SetWideText(Value: WideString);
begin
  if FWideText <> Value then
  begin
    if Font <> nil then Font.AddChars(Value);
  FWideText := Value;
  end;
end;

procedure TFlashText.WriteToStream(be: TBitsEngine);
var
  Bits: Byte;
  il: Integer;
  GE: TSWFGlyphEntry;
  DText: TSWFDefineText;
  RText: TSWFTextRecord;
  Ch: TFlashChar;
  SaveWide: Boolean;
  CodeList: TList;
  BRect: TRect;

  function GetHTMLTags(open: boolean): string;
  begin
    result := '';
    if HTML and (Font <> nil) then
     begin
      if open then
       begin
        result := '<font face="'+Font.Name+'">';
        if Font.Bold then result := result + '<b>';
        if Font.Italic then result := result + '<i>';
       end else
       begin
        result := '</font>';
        if Font.Bold then result :=  '</b>' + result;
        if Font.Italic then result := '</i>' + result;
       end;
     end;   
  end;

begin
  if DynamicText then
   with TSWFDefineEditText.Create do
    begin
      SWFVersion := owner.Version;
      CharacterID := FCharacterID;
      if InitAsPoint then
         Bounds.Rect := Rect(FPtAnchor.X, FPtAnchor.Y, FPtAnchor.X, FPtAnchor.Y)
        else
         Bounds.Assign(self.Bounds);
      AutoSize := FAutoSize;
      Border := FBorder;
      HTML := FHTML;
      Multiline := FMultiline;
      NoSelect := FNoSelect;
      Password := FPassword;
      ReadOnly := FReadOnly;
      UseOutlines := FUseOutlines or not Font.AsDevice;
      WordWrap := FWordWrap;
  
      if Font <> nil then
        begin
          HasFont := true;
          FontID := Font.CharacterId;
          FontHeight := FTextHeight;
        end;
      if HasColor then
        begin
         HasTextColor := true;
         TextColor.Assign(Color);
        end;
      if HasMaxLen then
        begin
         HasMaxLength := true;
         MaxLength := FMaxLength;
        end;
      if self.HasLayout then
       begin
         HasLayout := true;
         Align := FAlign;
         LeftMargin := FLeftMargin;
         RightMargin := FRightMargin;
         Indent := FIndent;
         Leading := FLeading;
       end;
  
      VariableName := VarName;
     if Font.WideCodes then
     begin
      if WideText <> '' then
       begin
         HasText := true;
         WideInitialText := GetHTMLTags(true) + WideText + GetHTMLTags(false);
       end;
      end
      else
      if Text <> '' then
        begin
          HasText := true;
          InitialText := GetHTMLTags(true) + Text + GetHTMLTags(false);
        end;
      WriteToStream(BE);
      Free;
    end else
 // ==== Static text ====
    if (WideText = '') and (Text <> '') then
    begin
      if Color.A < $FF then DText := TSWFDefineText2.Create
         else DText := TSWFDefineText.Create;
      With DText do
       begin
        Font.FillCharsInfo;
        CharacterID := FCharacterID;
        if InitAsPoint {AutoSize} then
          begin
            With Font.GetTextExtentPoint(Text) do
             begin
              CX := Round(CX/Font.FSize * FTextHeight);
              CY := Round(CY/Font.FSize * FTextHeight);
              BRect := Rect(0, 0, CX, CY);
              OffsetRect(BRect, FPtAnchor.X, FPtAnchor.Y);
              Case Align of
               taCenter, taJustify: OffsetRect(BRect, - CX div 2, 0);
               taRight: OffsetRect(BRect, - CX, 0);
              end;
             end;
          end else
           BRect := Bounds.Rect;
        TextBounds.Rect := BRect;
        TextMatrix.Assign(Matrix);

        GlyphBits := 0;
        AdvanceBits := 0;
  
        RText := TSWFTextRecord.Create;
        RText.FontID := Font.CharacterId;
        RText.TextColor.Assign(Color);
        RText.TextHeight := FTextHeight;
        RText.YOffset := Round(Font.Ascent/EMS * FTextHeight) + BRect.Top;
        if BRect.Left <> 0 then
          RText.XOffset := BRect.Left;
  
        SaveWide := Font.WideCodes or (Font.EncodingType = encodeUnicode);
        if not SaveWide then
          begin
           CodeList := TList.Create;
           for il := 0 to Font.CharList.Count - 1 do
             CodeList.Add(Pointer(Font.CharInfoInd[il].Code));
           CodeList.Sort(_CodeSort);
          end;
  
        For il := 1 to length(Text) do
         begin
           GE := TSWFGlyphEntry.Create;
           Ch := Font.CharInfo[ord(Text[il])];
           if SaveWide
             then GE.GlyphIndex := Font.CharList.IndexOf(Ch)
              else GE.GlyphIndex := CodeList.IndexOf(Pointer(Ch.Code));
           GE.GlyphAdvance := Round(Ch.GlyphAdvance/EMS * FTextHeight) + FCharSpacing;
           RText.GlyphEntries.Add(GE);
           Bits := GetBitsCount(GE.GlyphIndex);
           if GlyphBits < Bits then GlyphBits := Bits;
           Bits := GetBitsCount(GE.GlyphAdvance, 1);
           if AdvanceBits < Bits then AdvanceBits := Bits;
         end;
        TextRecords.Add(RText);
        if not SaveWide then CodeList.Free;
       end;
      DText.WriteToStream(be);
      DText.Free;
    end;
    // WideString
    if not DynamicText and (WideText <> '') then
    begin
      if Color.A < $FF then DText := TSWFDefineText2.Create
         else DText := TSWFDefineText.Create;
      With DText do
       begin
        Font.FillCharsInfo;
        CharacterID := FCharacterID;
        if InitAsPoint {AutoSize} then
          begin
            With Font.GetTextExtentPoint(WideText) do
             begin
              BRect := Rect(0, 0, CX, CY);
              OffsetRect(BRect, FPtAnchor.X, FPtAnchor.Y);
              Case Align of
               taCenter, taJustify: OffsetRect(BRect, - CX div 2, 0);
               taRight: OffsetRect(BRect, - CX, 0);
              end;
             end;
          end else
           BRect := Bounds.Rect;
        TextBounds.Rect := BRect;
        TextMatrix.Assign(Matrix);
  
        GlyphBits := 0;
        AdvanceBits := 0;
  
        RText := TSWFTextRecord.Create;
        RText.FontID := Font.CharacterId;
        RText.TextColor.Assign(Color);
        RText.TextHeight := FTextHeight;
        RText.YOffset := Round(Font.Ascent/EMS * FTextHeight) + BRect.Top;
        if BRect.Left <> 0 then
          RText.XOffset := BRect.Left;
  
        For il := 1 to Length(WideText) do
         begin
           GE := TSWFGlyphEntry.Create;
           Ch := Font.CharInfo[ord(WideText[il])];
           GE.GlyphIndex := Font.CharList.IndexOf(Ch);
  
           GE.GlyphAdvance := Round(Ch.GlyphAdvance/EMS * FTextHeight) + FCharSpacing;
           RText.GlyphEntries.Add(GE);
           Bits := GetBitsCount(GE.GlyphIndex);
           if GlyphBits < Bits then GlyphBits := Bits;
           Bits := GetBitsCount(GE.GlyphAdvance, 1);
           if AdvanceBits < Bits then AdvanceBits := Bits;
         end;
        TextRecords.Add(RText);
       end;
      DText.WriteToStream(be);
      DText.Free;
    end;
end;

// =============================================================//
//                           TFlashButton                       //
// =============================================================//

{
******************************************************* TFlashButton ********************************************************
}
constructor TFlashButton.Create(owner: TFlashMovie; hasmenu: boolean = false; advMode: boolean = true);
 var AL: TSWFActionList;
begin
  inherited Create(owner);
  if advMode then
    begin
      fButton:= TSWFDefineButton2.Create;
      GetButton2.TrackAsMenu := hasmenu;
    end
    else fButton := TSWFDefineButton.Create;


  self.advMode := advMode;

  AL := TSWFActionList(LongInt(1));
  fFlashActionList := TFlashActionScript.Create(owner, AL);
  fButtonSound := TSWFDefineButtonSound.Create;
end;

destructor TFlashButton.destroy;
begin
  fButtonSound.Free;
  fFlashActionList.free;
  fButton.Free;
  inherited;
end;

function TFlashButton.Actions: TFlashActionScript;
begin
  if not advMode
     then fFlashActionList.fActionList := fButton.Actions
     else fFlashActionList.fActionList := FindActionEvent(beRelease);

  Result := fFlashActionList;
end;

function TFlashButton.AddCondAction(FE: TFlashButtonEvents): TSWFButtonCondAction;
var
  il: Integer;
begin
  Result := TSWFButtonCondAction.Create;
  for il := Integer(IdleToOverUp) to Integer(OverDownToIdle) do
    if TFlashButtonEvent(il) in FE then
      Result.ActionConditions := Result.ActionConditions + [TSWFStateTransition(il)];
  GetButton2.Actions.Add(Result);
end;

function TFlashButton.AddRecord(Shape: TFlashVisualObject; BS: TSWFButtonStates; depth: word = 1): TSWFButtonRecord;
begin
  result := AddRecord(Shape.CharacterId, BS, depth);
end;

function TFlashButton.AddRecord(Sprite: TFlashSprite; BS: TSWFButtonStates; depth: word = 1): TSWFButtonRecord;
begin
  Result := AddRecord(Sprite.CharacterId, BS, depth);
end;

function TFlashButton.AddRecord(ID: Word; BS: TSWFButtonStates; depth: word = 1): TSWFButtonRecord;
begin
  Result := TSWFButtonRecord.Create(ID);
  Result.Depth := depth;
  Result.ButtonState := BS;
  Result.hasColorTransform := advMode;
  if advMode then Result.ColorTransform.hasAlpha := true;
  fButton.ButtonRecords.Add(Result);
end;

procedure TFlashButton.Assign(Source: TBasedSWFObject);
begin
  inherited;
  With TFlashButton(Source) do
  begin
    self.fButton.Assign(fButton);
    self.advMode := advMode;
    self.fButtonSound.Assign(fButtonSound);
  end;
end;

{$IFDEF ASCompiler}
function TFlashButton.CompileEvent(src: TStrings): boolean;
 var S: TMemoryStream;
begin
  S := TMemoryStream.Create;
  src.SaveToStream(S);
  Result := CompileEvent(S);
  S.Free;
end;

function TFlashButton.CompileEvent(src: TStream): boolean;
begin
  try
    src.Position := 0;
    owner.ASCompiler.CompileAction(src, self);
    Result := true;
  except
    on E: Exception do
      begin
        owner.ASCompilerLog.Write(PChar(E.Message)^, Length(E.Message));
        Result := false;
      end;
  end;
end;

function TFlashButton.CompileEvent(src: string): boolean;
 var S: TMemoryStream;
     P: Pointer;
begin
  S := TMemoryStream.Create;
  P := @src[1];
  S.Write(P^, length(src));
  Result := CompileEvent(S);
  S.Free;
end;

function TFlashButton.CompileEvent(FileName: string; unicode: boolean): boolean;
 var F: TFileStream;
begin
  F := TFileStream.Create(Filename, fmOpenRead);
  /// if unicode  -  todo
  Result := CompileEvent(F);
  F.free;
end;
{$ENDIF}


function TFlashButton.FindActionEvent(FE: TFlashButtonEvent; CreateNoExist: boolean = true): TSWFActionList;
var
  il: Integer;
  CA: TSWFButtonCondAction;
begin
  Result := nil;
  if GetButton2.Actions.Count > 0 then
    For il:=0 to GetButton2.Actions.Count - 1 do
     begin
       CA := TSWFButtonCondAction(GetButton2.Actions[il]);
       if TSWFStateTransition(byte(FE)) in CA.ActionConditions then
         begin
           Result := CA;
           Break;
         end;
     end;
  if (Result = nil) and CreateNoExist then
    Result := AddCondAction([FE]);
end;

function TFlashButton.GetButton: TSWFDefineButton;
begin
  Result := TSWFDefineButton(fButton);
end;

function TFlashButton.GetButton2: TSWFDefineButton2;
begin
  Result := TSWFDefineButton2(fButton);
end;

function TFlashButton.MinVersion: Byte;
begin
  Result := SWFVer1 + 2 * Byte(advMode);
end;

function TFlashButton.OnClickActions: TFlashActionScript;
begin
  if advMode then Result := OnReleaseActions else
    begin
      fFlashActionList.fActionList := fButton.Actions;
      Result := fFlashActionList;
    end;
end;

function TFlashButton.OnDragOutActions: TFlashActionScript;
begin
  fFlashActionList.fActionList := FindActionEvent(beDragOut);
  Result := fFlashActionList;
end;

function TFlashButton.OnDragOverActions: TFlashActionScript;
begin
  fFlashActionList.fActionList := FindActionEvent(beDragOver);
  Result := fFlashActionList;
end;

function TFlashButton.OnMenuDragOutActions: TFlashActionScript;
begin
  fFlashActionList.fActionList := FindActionEvent(beMenuDragOut);
  Result := fFlashActionList;
end;

function TFlashButton.OnMenuDragOverActions: TFlashActionScript;
begin
  fFlashActionList.fActionList := FindActionEvent(beMenuDragOver);
  Result := fFlashActionList;
end;

function TFlashButton.OnPressActions: TFlashActionScript;
begin
  fFlashActionList.fActionList := FindActionEvent(bePress);
  Result := fFlashActionList;
end;

function TFlashButton.OnReleaseActions: TFlashActionScript;
begin
  fFlashActionList.fActionList := FindActionEvent(beRelease);
  Result := fFlashActionList;
end;

function TFlashButton.OnReleaseOutsideActions: TFlashActionScript;
begin
  fFlashActionList.fActionList := FindActionEvent(beReleaseOutside);
  Result := fFlashActionList;
end;

function TFlashButton.OnRollOutActions: TFlashActionScript;
begin
  fFlashActionList.fActionList := FindActionEvent(beRollOut);
  Result := fFlashActionList;
end;

function TFlashButton.OnRollOverActions: TFlashActionScript;
begin
  fFlashActionList.fActionList := FindActionEvent(beRollOver);
  Result := fFlashActionList;
end;


procedure TFlashButton.SetCharacterId(v: word);
begin
  inherited;
  fButton.ButtonId := v;
end;

function TFlashButton.SndPress: TSWFStartSound;
begin
  Result := fButtonSound.SndOverUpToOverDown;
end;

function TFlashButton.SndRelease: TSWFStartSound;
begin
  Result := fButtonSound.SndOverDownToOverUp;
end;

function TFlashButton.SndRollOut: TSWFStartSound;
begin
  Result := fButtonSound.SndOverUpToIdle;
end;

function TFlashButton.SndRollOver: TSWFStartSound;
begin
  Result := fButtonSound.SndIdleToOverUp;
end;

procedure TFlashButton.WriteToStream(be: TBitsEngine);
begin
  fButton.WriteToStream(be);

  if fButtonSound.HasIdleToOverUp or fButtonSound.HasOverDownToOverUp or
    fButtonSound.HasOverUpToIdle or fButtonSound.HasOverUpToOverDown
      then
       begin
         fButtonSound.ButtonId := CharacterID;
         fButtonSound.WriteToStream(be);
       end
end;


// =============================================================//
//                           TFlashCanvas                        //
// =============================================================//
type
  TGDIHandleType = (htPen, htBrush, htFont, htMonoBrush, htDibBrush);

  TGDIHandleInfo = class (TObject)
  private
    HandleType: TGDIHandleType;
  end;

  TGDIHandlePen = class (TGDIHandleInfo)
  private
    FInfo: TLogPen;
  public
    constructor Create(LP: TLogPen); overload;
    constructor Create(LP: TExtLogPen); overload;
    property Info: TLogPen read FInfo write FInfo;
  end;

{
******************************************************* TGDIHandlePen *******************************************************
}
constructor TGDIHandlePen.Create(LP: TLogPen);
begin
  HandleType := htPen;
  Info := LP;
  if Info.lopnStyle = PS_INSIDEFRAME
    then FInfo.lopnStyle := PS_SOLID;
end;

constructor TGDIHandlePen.Create(LP: TExtLogPen);
begin
  HandleType := htPen;
//  Info := LP;
  FInfo.lopnColor := LP.elpColor;
  FInfo.lopnWidth.X := LP.elpWidth;
  FInfo.lopnStyle := LP.elpPenStyle and 7;

  if Info.lopnStyle > PS_NULL
    then FInfo.lopnStyle := PS_SOLID;
end;

type
  TGDIHandleBrush = class (TGDIHandleInfo)
  private
    FInfo: TLogBrush;
  public
    constructor Create(LB: TLogBrush);
    property Info: TLogBrush read FInfo write FInfo;
  end;
  
{
****************************************************** TGDIHandleBrush ******************************************************
}
constructor TGDIHandleBrush.Create(LB: TLogBrush);
begin
  HandleType := htBrush;
  Info := LB;
end;

type
  TGDIHandleDibBrush = class (TGDIHandleInfo)
  private
    FInfo: TMemoryStream;
    Img: TFlashImage;
  public
    constructor Create(EMFR:Cardinal);
    destructor Destroy; override;
    property Info: TMemoryStream read FInfo write FInfo;
  end;

{
**************************************************** TGDIHandleDibBrush *****************************************************
}
constructor TGDIHandleDibBrush.Create(EMFR:Cardinal);
var
  BMP: TBMPReader;
begin
  with PEMRCreateDIBPatternBrushPt(EMFR)^ do
  begin
    Img := nil;
    Info:=TMemoryStream.Create;
    BMP := TBMPReader.Create;
    BMP.SetInterfaceIndirect(Pointer(Cardinal(EMFR) + offBits), PBMInfo(Cardinal(EMFR) + offBmi)^);
    BMP.SaveToStream(Info);
    BMP.Free;
    HandleType := htDibBrush;
    Info.Position:=0;
  end;
end;

destructor TGDIHandleDibBrush.Destroy;
begin
 inherited;
 if FInfo <> nil then FInfo.Free; 
end;

type
  TGDIHandleMonoBrush = class (TGDIHandleInfo)
  private
    FInfo: TMemoryStream;
    Img: TFlashImage;
  public
    constructor Create(EMFR:Cardinal);
    destructor Destroy; overload; override;
    property Info: TMemoryStream read FInfo write FInfo;
  end;

{
**************************************************** TGDIHandleMonoBrush ****************************************************
}
constructor TGDIHandleMonoBrush.Create(EMFR:Cardinal);
var
  Offset, il: Cardinal;
  PBuff: Pointer;
  B: Byte;
  pb: PByte;
begin
  with PEMRCREATEMONOBRUSH(EMFR)^ do
  begin
    HandleType := htMonoBrush;
    Info := TmemoryStream.Create;
    Info.Position:=10;
    Offset:=cbBmi+14+8; //cbBmiSrc+cbBitsSrc;
    Info.Write(Offset, 4);
  
    PBuff:=Pointer(EMFR + offBmi);
    Info.WriteBuffer(PBuff^, cbBmi);

    Info.Seek(14 - integer(cbBmi), soFromCurrent);
    b := 8;
    Info.Write(b, 1);
    Info.Seek(0, soFromEnd);

    Offset:=$FFFFFFFF; Info.Write(Offset, 4);   // While
    Offset:=$0; Info.Write(Offset, 4);          //Black

    pb:=Pointer(EMFR + offBits);
    for il:=0 to 7 do
    begin
      for Offset:=7 downto 0 do
      begin
        B:=((pb^ shr Offset) xor $FF) and 1;
        Info.Write(B,1);
      end;
    inc(pb,4);
    end;
    Info.Position:=0;
  end;
end;

destructor TGDIHandleMonoBrush.Destroy;
begin
 inherited;
 if FInfo <> nil then FInfo.Free; 
end;

type
  TGDIHandleFont = class (TGDIHandleInfo)
  private
    FInfo: TExtLogFontW;
  public
    constructor Create(LF: TExtLogFontW);
    property Info: TExtLogFontW read FInfo write FInfo;
  end;
  
{
****************************************************** TGDIHandleFont *******************************************************
}
constructor TGDIHandleFont.Create(LF: TExtLogFontW);
begin
  HandleType := htFont;
  Info := LF;
end;

type
  MTriVertex = packed record
    x: LongInt;
    y: LongInt;
    red: Word;
    green: Word;
    blue: Word;
    alpha: Word;
  end;

  ASmP = array of TSmallPoint;
  ALnP = array of TPoint;
  ABytes = array of byte;
  FVer = array of MTriVertex;
  ACPoly = array of DWord;

{
****************************************************** TMETAFont *******************************************************

constructor TMetaFont.Create;
begin
  inherited;
end;
}

constructor TFSpriteCanvas.Create(owner: TFlashMovie);
begin
  inherited;
  ZeroMemory(@FXForm, SizeOf(FXForm));
  FXForm.eM11 := 1;
  FXForm.eM22 := 1;
end;

{
******************************************************* TFlashCanvas ********************************************************
}
const
EMR_COLORMATCHTOTARGETW = 121;
EMR_CREATECOLORSPACEW   = 122;

 var
   isGDIOut: boolean;

function isGDIOutTag(tag: dword): boolean;
begin
  Result := tag in [EMR_POLYBEZIER,EMR_POLYGON,EMR_POLYLINE,EMR_POLYBEZIERTO,
           EMR_POLYLINETO,EMR_POLYPOLYLINE,EMR_POLYPOLYGON,
           EMR_SETPIXELV, EMR_ANGLEARC,EMR_ELLIPSE,EMR_RECTANGLE,EMR_ROUNDRECT,EMR_ARC,EMR_CHORD,EMR_PIE,
           EMR_EXTFLOODFILL,EMR_LINETO,EMR_ARCTO,
           EMR_POLYDRAW,EMR_FILLPATH,EMR_STROKEANDFILLPATH,EMR_STROKEPATH,EMR_FLATTENPATH,EMR_WIDENPATH,
           EMR_FILLRGN,EMR_FRAMERGN,EMR_INVERTRGN,EMR_PAINTRGN,
           EMR_BITBLT,EMR_STRETCHBLT,EMR_MASKBLT,EMR_PLGBLT,EMR_STRETCHDIBITS,
           EMR_EXTTEXTOUTA,EMR_EXTTEXTOUTW,EMR_POLYBEZIER16,EMR_POLYGON16,EMR_POLYLINE16,
           EMR_POLYBEZIERTO16,EMR_POLYLINETO16,EMR_POLYPOLYLINE16,EMR_POLYPOLYGON16,EMR_POLYDRAW16,
           EMR_POLYTEXTOUTA,EMR_POLYTEXTOUTW, EMR_DRAWESCAPE,EMR_SMALLTEXTOUT,
           EMR_ALPHABLEND, EMR_ALPHADIBBLEND,EMR_TRANSPARENTBLT,EMR_TRANSPARENTDIB,EMR_GRADIENTFILL];
end;

function EnumGDIOut(DC: HDC; HTable: PHandleTable; EMFR: PEnhMetaRecord; nObj: Integer; Sender: TFlashCanvas): BOOL; stdcall;
 begin
  isGDIOut := isGDIOutTag(EMFR^.iType);
  Result := not isGDIOut;
 end;   

type
TObjMFRecord = class
  Rec: PEnhMetaRecord;
  PrevGDI: TObjMFRecord;
  IsGDIOut: boolean;
  IsDraw: boolean;
  FromRend: boolean;
  SpecDraw: byte;
  fROP: dword;
  constructor Create(P: PEnhMetaRecord);
end;

constructor TObjMFRecord.Create(P: PEnhMetaRecord);
begin
  Rec := P;
  IsGDIOut := isGDIOutTag(P^.iType);
  IsDraw := true;
  FromRend := false;
  SpecDraw := 0;
  case P^.iType of
   EMR_BITBLT:        fROP := PEMRBITBLT(P)^.dwRop;
   EMR_STRETCHBLT:    fROP := PEMRSTRETCHBLT(P)^.dwRop;
   EMR_STRETCHDIBITS: fROP := PEMRSTRETCHDIBITS(P)^.dwRop;
  end;
  if fROP = $00AA0029 then IsDraw := false;
end;

constructor TFlashCanvas.Create(Owner: TFlashMovie);
begin
  inherited Create;
  FOwner := Owner;

  EmbeddedFont := True;

  if HTables = nil then HTables := TObjectList.Create(false);
  //if CUrDepth = 0 then CurDepth := 3;
  if CurShape = 0 then CurShape := 1;

  RootScaleX := 1;
  RootScaleY := 1;
  RenderOptions := [roUseBuffer];
//  MainSprite := Owner.AddSprite;

  BufferBMP := TBMPReader.Create;
  InitHandle;
  ListMFRecords := TObjectList.Create;
  FTextMetricSize := 0;
  FTextMetric := nil;
end;

destructor TFlashCanvas.Destroy;
 var il: integer;
begin
  BufferBMP.Free;

  if HTables <> nil then
    begin
      for il := 0 to HTables.Count - 1 do
        if HTables[il] <> nil then HTables[il].Free;
      HTables.Free;
    end;
  ListMFRecords.Free;
  if FTextMetricSize > 0 then
    FreeMem(FTextMetric, FTextMetricSize);
  inherited;
end;


function TFlashCanvas.IsEmptyMetafile(MetaHandle: THandle = 0): boolean;
 var
 //  isGDIOut: boolean;
    R: TRect;
    il: word;
begin
  if MetaHandle = 0 then
    begin
      Result := true;
      if ListMFRecords.Count > 0 then
       for il := 0 to ListMFRecords.Count - 1 do
        with TObjMFRecord(ListMFRecords.Items[il]) do
          if (IsGDIOut and IsDraw) then
            begin
              Result := false;
              break;
            end;
    end else
    begin
      isGDIOut := false;
      ZeroMemory(@R, SizeOf(R));
      EnumEnhMetaFile(0, MetaHandle, @EnumGDIOut, self, R);
      Result := not isGDIOut;
    end;
end;

Function myCompareRect(R1, R2: TRect): boolean;
 var b1, b2: Array [0..3] of Longint;
     il: byte;
begin
  Move(R1, b1, SizeOf(R1));
  Move(R2, b2, SizeOf(R2));
  Result := true;
  if ((R1.Bottom - R1.Top) = 0) or ((R2.Bottom - R2.Top) = 0)
    then Result := CompareMem(@R1, @R2, SizeOf(R1))
    else
      for il := 0 to 3 do
        Result := Result and (b1[il] >= (b2[il] - 1)) and (b1[il] <= (b2[il] + 1));
end;


function TFlashCanvas.isNeedBuffer: boolean;
var
  il, PrevID, Rop2: Word;
  PrevRect: TRect;
  MFRO: TObjMFRecord;

  function ChechOkRop(Rop: DWord):Boolean;
  begin
    case Rop of
      SRCCOPY,{ SRCPAINT,} BLACKNESS, WHITENESS, PATCOPY: Result := true;
     else Result := false;
    end;
  end;

  procedure CheckBMPRecord(dRect: TRect; bRop: dword);
  begin
    if (MFRO.SpecDraw > 0) or not MFRO.IsDraw then
      begin
        MFRO.FromRend := false;
        Exit;
      end;
    if bRop = $00AA0029 then MFRO.IsDraw := false else
    if (PrevID > 0) and myCompareRect(PrevRect, dRect)
        then TObjMFRecord(ListMFRecords[PrevID]).IsDraw := false
        else PrevRect := dRect;
    PrevID := il;
    if MFRO.IsDraw and not ChechOkRop(bRop) then MFRO.FromRend := true;
  end;
begin
  PrevID := 0;
  UseBMPRender := false;
  Rop2 := R2_COPYPEN;

  if ListMFRecords.Count > 0 then
   for il := 0 to ListMFRecords.Count - 1 do
    begin
      MFRO := TObjMFRecord(ListMFRecords[il]);
      if MFRO.SpecDraw = ooStartTransparentFill then EnableTransparentFill := true else
        if MFRO.SpecDraw = ooEndTransparentFill then EnableTransparentFill := false;

      if not EnableTransparentFill then
      case MFRO.Rec^.iType of
        EMR_BITBLT:
          with PEMRBITBLT(MFRO.Rec)^ do
          begin
            CheckBMPRecord(rclBounds, dwRop);
          end;

        EMR_STRETCHBLT:
          with PEMRSTRETCHBLT(MFRO.Rec)^ do
          begin
            CheckBMPRecord(rclBounds, dwRop);
          end;
//        EMR_MASKBLT:  DoMASKBLT(PEMRMASKBLT(EMFR));
//        EMR_PLGBLT:  DoPLGBLT(PEMRPLGBLT(EMFR));
//        EMR_SETDIBITSTODEVICE:  DoSETDIBITSTODEVICE(PEMRSETDIBITSTODEVICE(EMFR));

        EMR_STRETCHDIBITS:
          with PEMRSTRETCHDIBITS(MFRO.Rec)^ do
          begin
            CheckBMPRecord(rclBounds, dwRop);
          end;

        EMR_ALPHABLEND:
          if PEMRALPHABLEND(MFRO.Rec)^.cbBitsSrc > 0 then
            MFRO.FromRend := true;

        EMR_SETROP2:
          Rop2 := PEMRSETROP2(MFRO.Rec)^.iMode;
        else
          begin
            if (PrevID > 0) and (il > PrevID) and MFRO.IsGDIOut then PrevID := 0;
            if MFRO.IsGDIOut and (Rop2 <> R2_COPYPEN) then MFRO.FromRend := true;
          end;
      end;
      if MFRO.FromRend then UseBMPRender := true;
    end;
  Result := UseBMPRender;
end;

Procedure TFlashCanvas.ProcessingRecords(MetaHandle: THandle; Width, Height: integer; stretch: boolean);
 var
    EMFHeader: TEnhMetaHeader;
    R: TRect;

  function EnumRec(DC: HDC; var HTable: THandleTable; EMFR: PEnhMetaRecord; nObj: Integer; Sender: TFlashCanvas): BOOL; stdcall;
  begin
    PlayEnhMetaFileRecord(DC, HTable, EMFR^, nObj);
    Sender.DoEnhRecord(EMFR);
    Result := true;
  end;

begin
  CurrentRec := 0;
  if (roUseBuffer in RenderOptions) then isNeedBuffer;

  MetafileSprite := AddActiveSprite(csMetaFile);
  FActiveSprite := MetafileSprite;
  GetEnhMetaFileHeader(MetaHandle, Sizeof(EMFHeader), @EMFHeader);
  with EMFHeader do
   MetafileRect := Rect(MulDiv( rclFrame.Left, szlDevice.cx, szlMillimeters.cx * 100),
                        MulDiv( rclFrame.Top, szlDevice.cy, szlMillimeters.cy * 100),
                        MulDiv( rclFrame.Right, szlDevice.cx, szlMillimeters.cx * 100),
                        MulDiv( rclFrame.Bottom, szlDevice.cy, szlMillimeters.cy * 100));
  R := Rect(0, 0,
            MetafileRect.Right-MetafileRect.Left, MetafileRect.Bottom-MetafileRect.Top);

//  if Assigned(BufferBMP) then
//    begin
//      GetWorldTransform(BufferBMP.DC, FCWorldTransform);
//      if FCWorldTransform.eM11 <> 1 then
//        begin
//          FillChar(FCWorldTransform, SizeOf(FCWorldTransform), 0);
//          FCWorldTransform.eM11 := 1;
//          FCWorldTransform.eM22 := 1;
//          SetWorldTransform(BufferBMP.DC, FCWorldTransform);
//        end;
//    end;

  if (roUseBuffer in RenderOptions) and UseBMPRender then
    begin
      if stretch and (not (roHiQualityBuffer in RenderOptions)) {and
         ((Width < R.Right) or (Height < R.Bottom)) }then
        begin
          BufferBMP.SetSize(Width, Height, 24);
          StretchedBMPRender := true;
          R := Rect(0,0, Width, Height);
        end else BufferBMP.SetSize(R.Right, R.Bottom, 24);

      if Owner.BackgroundMode = bmColor then
        with Owner.BackgroundColor do BufferBMP.Clear(FRGB(R,G,B))
       else BufferBMP.Clear(FRGB($FF,$FF,$FF));
    end
    else
      BufferBMP.SetSize(10, 10, 24);

  BgColor := GetBkColor(BufferBMP.DC);
//  FillChar(R, SizeOf(R), 0);

  EnumEnhMetaFile(BufferBMP.DC{0}, MetaHandle, @EnumRec, self, R);
end;



procedure TFlashCanvas.DoEnhRecord(EMFR: PEnhMetaRecord);
begin
 inc(CurrentRec);

 if {(roUseBuffer in RenderOptions) and UseBMPRender and }
    (CurrentRec < ListMFRecords.Count) and
     not TObjMFRecord(ListMFRecords[CurrentRec-1]).IsDraw
     then Exit;


 if (ShapeLineTo <> nil) and
     (not (EMFR^.iType in [EMR_LINETO, {EMR_CLOSEFIGURE,} EMR_MOVETOEX])) then
   begin
     ShapeLineTo.CalcBounds;
     ActiveSprite.PlaceObject(ShapeLineTo, ActiveSprite.MaxDepth + 1 );

     ShapeLineTo := nil;
   end;

 if MustCreateWorldTransform  and isGDIOutTag(EMFR^.iType) then
   begin
     GetWorldTransform(BufferBMP.DC, FCWorldTransform);
//     MustCreateWorldTransform := false;
   end;


  case EMFR^.iType of
    // begin-end tags
    EMR_HEADER:  DoHEADER(PEnhMetaHeader(EMFR));
    EMR_EOF:  DoEOF(PEMREOF(EMFR));
    EMR_GDICOMMENT:  DoGDICOMMENT(PEMRGDICOMMENT(EMFR));

    // handles
    EMR_CREATEPEN:  DoCREATEPEN(PEMRCREATEPEN(EMFR));
    EMR_EXTCREATEPEN:  DoEXTCREATEPEN(PEMREXTCREATEPEN(EMFR));
    EMR_CREATEBRUSHINDIRECT:  DoCREATEBRUSHINDIRECT(PEMRCREATEBRUSHINDIRECT(EMFR));
    EMR_CREATEMONOBRUSH:  DoCREATEMONOBRUSH(PEMRCREATEMONOBRUSH(EMFR));
    EMR_CREATEDIBPATTERNBRUSHPT:  DoCREATEDIBPATTERNBRUSHPT(PEMRCREATEDIBPATTERNBRUSHPT(EMFR));
    EMR_EXTCREATEFONTINDIRECTW:  DoEXTCREATEFONTINDIRECTW(PEMREXTCREATEFONTINDIRECT(EMFR));

    EMR_SELECTOBJECT:  DoSELECTOBJECT(PEMRSELECTOBJECT(EMFR));
    EMR_DELETEOBJECT:  DoDELETEOBJECT(PEMRDELETEOBJECT(EMFR));

    // other settings
    EMR_SETTEXTCOLOR:  DoSETTEXTCOLOR(PEMRSETTEXTCOLOR(EMFR));
    EMR_SETTEXTALIGN:  DoSETTEXTALIGN(PEMRSETTEXTALIGN(EMFR));

    EMR_SETBKCOLOR:  DoSETBKCOLOR(PEMRSETBKCOLOR(EMFR));
    EMR_SETBKMODE:  DoSETBKMODE(PEMRSETBKMODE(EMFR));
    EMR_SETROP2:  DoSETROP2(PEMRSETROP2(EMFR));

    EMR_SETBRUSHORGEX:  DoSETBRUSHORGEX(PEMRSETBRUSHORGEX(EMFR));

    EMR_SETPOLYFILLMODE:  DoSETPOLYFILLMODE(PEMRSETPOLYFILLMODE(EMFR));
    EMR_SETARCDIRECTION:  DoSETARCDIRECTION(PEMRSETARCDIRECTION(EMFR));

    // line draw
    EMR_MOVETOEX:  DoMOVETOEX(PEMRMOVETOEX(EMFR));
    EMR_LINETO:  DoLINETO(PEMRLINETO(EMFR));
    EMR_SETPIXELV:  DoSETPIXELV(PEMRSETPIXELV(EMFR));

    EMR_POLYLINE:  DoPOLYLINE(PEMRPolyline(EMFR));
    EMR_POLYLINETO:  DoPOLYLINETO(PEMRPolyline(EMFR));
    EMR_POLYGON:  DoPOLYGON(PEMRPolyline(EMFR));

    EMR_POLYPOLYLINE:  DoPOLYPOLYLINE(PEMRPOLYPOLYLINE(EMFR));
    EMR_POLYPOLYGON:  DoPOLYPOLYGON(PEMRPOLYPOLYGON(EMFR));
    EMR_POLYDRAW:  DoPOLYDRAW(PEMRPOLYDRAW(EMFR));

    EMR_POLYLINE16:  DoPOLYLINE16(PEMRPOLYLINE16(EMFR));
    EMR_POLYLINETO16:  DoPOLYLINETO16(PEMRPOLYLINETO16(EMFR));
    EMR_POLYGON16:  DoPOLYGON16(PEMRPOLYGON16(EMFR));

    EMR_POLYPOLYLINE16:  DoPOLYPOLYLINE16(PEMRPOLYPOLYLINE16(EMFR));
    EMR_POLYPOLYGON16:  DoPOLYPOLYGON16(PEMRPOLYPOLYGON16(EMFR));
    EMR_POLYDRAW16:  DoPOLYDRAW16(PEMRPOLYDRAW16(EMFR));

    // bezier
    EMR_POLYBEZIER:  DoPOLYBEZIER(PEMRPolyline(EMFR));
    EMR_POLYBEZIERTO:  DoPOLYBEZIERTO(PEMRPolyline(EMFR));

    EMR_POLYBEZIER16:  DoPOLYBEZIER16(PEMRPOLYBEZIER16(EMFR));
    EMR_POLYBEZIERTO16:  DoPOLYBEZIERTO16(PEMRPOLYBEZIERTO16(EMFR));

    // curve
    EMR_ANGLEARC:  DoANGLEARC(PEMRANGLEARC(EMFR));
    EMR_ELLIPSE:  DoELLIPSE(PEMRELLIPSE(EMFR));
    EMR_ARC:  DoARC(PEMRARC(EMFR));
    EMR_ARCTO:  DoARCTO(PEMRARCTO(EMFR));
    EMR_CHORD:  DoCHORD(PEMRCHORD(EMFR));
    EMR_PIE:  DoPIE(PEMRPIE(EMFR));

    // rectangle
    EMR_RECTANGLE:  DoRECTANGLE(PEMRRECTANGLE(EMFR));
    EMR_ROUNDRECT:  DoROUNDRECT(PEMRROUNDRECT(EMFR));
    EMR_GRADIENTFILL:  DoGRADIENTFILL((EMFR));
    EMR_EXTFLOODFILL:  DoEXTFLOODFILL(PEMREXTFLOODFILL(EMFR));

    // viewport
    EMR_SETWINDOWEXTEX:  DoSETWINDOWEXTEX(PEMRSETWINDOWEXTEX(EMFR));
    EMR_SETWINDOWORGEX:  DoSETWINDOWORGEX(PEMRSETWINDOWORGEX(EMFR));
    EMR_SETVIEWPORTEXTEX:  DoSETVIEWPORTEXTEX(PEMRSETVIEWPORTEXTEX(EMFR));
    EMR_SETVIEWPORTORGEX:  DoSETVIEWPORTORGEX(PEMRSETVIEWPORTORGEX(EMFR));

    EMR_SCALEVIEWPORTEXTEX:  DoSCALEVIEWPORTEXTEX(PEMRSCALEVIEWPORTEXTEX(EMFR));
    EMR_SCALEWINDOWEXTEX:  DoSCALEWINDOWEXTEX(PEMRSCALEWINDOWEXTEX(EMFR));

    EMR_SETMAPPERFLAGS:  DoSETMAPPERFLAGS(PEMRSETMAPPERFLAGS(EMFR));
    EMR_SETMAPMODE:  DoSETMAPMODE(PEMRSETMAPMODE(EMFR));

    EMR_SETSTRETCHBLTMODE:  DoSETSTRETCHBLTMODE(PEMRSETSTRETCHBLTMODE(EMFR));
    EMR_SETCOLORADJUSTMENT:  DoSETCOLORADJUSTMENT(PEMRSETCOLORADJUSTMENT(EMFR));

    EMR_SAVEDC:  DoSAVEDC(PEMRSAVEDC(EMFR));
    EMR_RESTOREDC:  DoRESTOREDC(PEMRRESTOREDC(EMFR));
    EMR_SETWORLDTRANSFORM:  DoSETWORLDTRANSFORM(PEMRSETWORLDTRANSFORM(EMFR));
    EMR_MODIFYWORLDTRANSFORM:  DoMODIFYWORLDTRANSFORM(PEMRMODIFYWORLDTRANSFORM(EMFR));


    // palette
    EMR_SELECTPALETTE:  DoSELECTPALETTE(PEMRSELECTPALETTE(EMFR));
    EMR_CREATEPALETTE:  DoCREATEPALETTE(PEMRCREATEPALETTE(EMFR));
    EMR_SETPALETTEENTRIES:  DoSETPALETTEENTRIES(PEMRSETPALETTEENTRIES(EMFR));
    EMR_RESIZEPALETTE:  DoRESIZEPALETTE(PEMRRESIZEPALETTE(EMFR));
    EMR_REALIZEPALETTE:  DoREALIZEPALETTE(PEMRREALIZEPALETTE(EMFR));

    EMR_SETICMMODE:  DoSETICMMODE(PEMRSETICMMODE(EMFR));
    EMR_CREATECOLORSPACE:  DoCREATECOLORSPACE(PEMRSelectColorSpace(EMFR));
    EMR_SETCOLORSPACE:  DoSETCOLORSPACE(PEMRSelectColorSpace(EMFR));
    EMR_DELETECOLORSPACE:  DoDELETECOLORSPACE(PEMRSelectColorSpace(EMFR));

    EMR_SETMITERLIMIT:  DoSETMITERLIMIT(PEMRSETMITERLIMIT(EMFR));

    // clip
    EMR_EXCLUDECLIPRECT:  DoEXCLUDECLIPRECT(PEMREXCLUDECLIPRECT(EMFR));
    EMR_INTERSECTCLIPRECT:  DoINTERSECTCLIPRECT(PEMRINTERSECTCLIPRECT(EMFR));

    // path
    EMR_BEGINPATH:  DoBEGINPATH(PEMRBEGINPATH(EMFR));
    EMR_ENDPATH:  DoENDPATH(PEMRENDPATH(EMFR));
    EMR_CLOSEFIGURE:  DoCLOSEFIGURE(PEMRCLOSEFIGURE(EMFR));
    EMR_FILLPATH:  DoFILLPATH(PEMRFILLPATH(EMFR));
    EMR_STROKEANDFILLPATH:  DoSTROKEANDFILLPATH(PEMRSTROKEANDFILLPATH(EMFR));
    EMR_STROKEPATH:  DoSTROKEPATH(PEMRSTROKEPATH(EMFR));
    EMR_FLATTENPATH:  DoFLATTENPATH(PEMRFLATTENPATH(EMFR));
    EMR_WIDENPATH:  DoWIDENPATH(PEMRWIDENPATH(EMFR));
    EMR_SELECTCLIPPATH:  DoSELECTCLIPPATH(PEMRSELECTCLIPPATH(EMFR));
    EMR_ABORTPATH:  DoABORTPATH(PEMRABORTPATH(EMFR));

    // region
    EMR_FILLRGN:  DoFILLRGN(PEMRFILLRGN(EMFR));
    EMR_FRAMERGN:  DoFRAMERGN(PEMRFRAMERGN(EMFR));
    EMR_INVERTRGN:  DoINVERTRGN(PEMRINVERTRGN(EMFR));
    EMR_PAINTRGN:  DoPAINTRGN(PEMRPAINTRGN(EMFR));
    EMR_EXTSELECTCLIPRGN:  DoEXTSELECTCLIPRGN(PEMREXTSELECTCLIPRGN(EMFR));
    EMR_OFFSETCLIPRGN:  DoOFFSETCLIPRGN(PEMROFFSETCLIPRGN(EMFR));
    EMR_SETMETARGN:  DoSETMETARGN(PEMRSETMETARGN(EMFR));

    // text
    EMR_EXTTEXTOUTA:  DoEXTTEXTOUTA(PEMREXTTEXTOUT(EMFR));
    EMR_EXTTEXTOUTW:  DoEXTTEXTOUTW(PEMREXTTEXTOUT(EMFR));
    EMR_SMALLTEXTOUT:  DoSMALLTEXTOUT((EMFR));
    EMR_POLYTEXTOUTA:  DoPOLYTEXTOUTA(PEMRPOLYTEXTOUT(EMFR));
    EMR_POLYTEXTOUTW:  DoPOLYTEXTOUTW(PEMRPOLYTEXTOUT(EMFR));

    // bitmap
    EMR_BITBLT:  DoBITBLT(PEMRBITBLT(EMFR));
    EMR_STRETCHBLT:  DoSTRETCHBLT(PEMRSTRETCHBLT(EMFR));
    EMR_MASKBLT:  DoMASKBLT(PEMRMASKBLT(EMFR));
    EMR_PLGBLT:  DoPLGBLT(PEMRPLGBLT(EMFR));
    EMR_SETDIBITSTODEVICE:  DoSETDIBITSTODEVICE(PEMRSETDIBITSTODEVICE(EMFR));
    EMR_STRETCHDIBITS:  DoSTRETCHDIBITS(PEMRSTRETCHDIBITS(EMFR));

    EMR_ALPHABLEND:  DoALPHABLEND(PEMRALPHABLEND(EMFR));
    EMR_ALPHADIBBLEND:  DoALPHADIBBLEND((EMFR));
    EMR_TRANSPARENTBLT:  DoTRANSPARENTBLT(PEMRTRANSPARENTBLT(EMFR));
    EMR_TRANSPARENTDIB:  DoTRANSPARENTDIB((EMFR));

    // openGL
    EMR_GLSRECORD:  DoGLSRECORD(PEMRGLSRECORD(EMFR));
    EMR_GLSBOUNDEDRECORD:  DoGLSBOUNDEDRECORD(PEMRGLSBOUNDEDRECORD(EMFR));

    EMR_PIXELFORMAT:  DoPIXELFORMAT(PEMRPIXELFORMAT(EMFR));
    EMR_DRAWESCAPE:  DoDRAWESCAPE((EMFR));
    EMR_EXTESCAPE:  DoEXTESCAPE((EMFR));
    EMR_STARTDOC:  DoSTARTDOC((EMFR));

    EMR_FORCEUFIMAPPING:  DoFORCEUFIMAPPING((EMFR));
    EMR_NAMEDESCAPE:  DoNAMEDESCAPE((EMFR));
    EMR_COLORCORRECTPALETTE:  DoCOLORCORRECTPALETTE((EMFR));
    EMR_SETICMPROFILEA:  DoSETICMPROFILEA((EMFR));
    EMR_SETICMPROFILEW:  DoSETICMPROFILEW((EMFR));

    EMR_SETLINKEDUFIS:  DoSETLINKEDUFIS((EMFR));
    EMR_SETTEXTJUSTIFICATION:  DoSETTEXTJUSTIFICATION((EMFR));
    EMR_COLORMATCHTOTARGETW:  DoCOLORMATCHTOTARGETW((EMFR));
    EMR_CREATECOLORSPACEW: DoCREATECOLORSPACEW((EMFR));
  end;

  LastEMFR := EMFR;
  LastCommand := EMFR^.iType;

end;

function TFlashCanvas.GetCopyFromRender(R: TRect): TBMPReader;
begin
  Result := TBMPReader.Create();
  Result.SetSize(R.Right - R.Left, R.Bottom - R.Top, 24);
  Result.CopyRect(BufferBMP, 0, 0, R.Right - R.Left, R.Bottom - R.Top, R.Left, R.Top);
end;

function TFlashCanvas.GetImageFromRender(R: TRect): TFlashImage;
begin
  Result := Owner.AddImage();
  Result.BMPStorage.SetSize(R.Right - R.Left, R.Bottom - R.Top, 24);
  Result.BMPStorage.CopyRect(BufferBMP, 0, 0, R.Right - R.Left, R.Bottom - R.Top, R.Left, R.Top);
  Result.MakeDataFromBMP;
end;

procedure TFlashCanvas.DoHeader(EMFR: PEnhMetaHeader);
 var il: integer;
     tmpForm : XFORM;
begin

   if EMFR^.nHandles > 0 then
    begin
      if HTables = nil then HTables := TObjectList.Create(false);
      HTables.Clear;
      for il := 0 to EMFR^.nHandles - 1 do HTables.Add(nil);
    end;

//   FMetaFont := TMetaFont.Create;
//   TColor(FMetaFont.FMColor) := $FF000000;

   hasInitViewportOrg := false;
   FillChar(FCWorldTransform, SizeOf(0), 0);
   FCWorldTransform.eM11 := 1;
   FCWorldTransform.eM22 := 1;
   MustCreateWorldTransform := false;
//   SetWorldTransform(BufferBMP.DC, FCWorldTransform);
end;

procedure TFlashCanvas.DoPOLYLINE(EMFR: PEMRPolyline);
 var PLP: ALnP;
     I: integer;
     P0: TPoint;
begin
 if DrawMode = dmPath then Exit;
 with EMFR^ do
  begin
    if cptl = 1 then
    begin
      LastMoveToXY := MapPoint(aptl[0]);
      Exit;
    end;
    PLP := @aptl;
    P0 := MapPoint(aptl[0]);
    with MapPoint(PLP[1]) do
      sh:=Owner.AddLine(P0.x, P0.y, X, Y);
    for I := 2 to cptl-1 do
     With MapPoint(PLP[i]) do
      sh.Edges.LineTo(X, Y);

    if (EMFR^.emr.iType = EMR_POLYGON) and
      ((aptl[0].x <> PLP[cptl - 1].x) or (aptl[0].y <> PLP[cptl-1].y)) then
         sh.Edges.LineTo(P0.x, P0.y);

    Sh.CalcBounds;
    ShapeSetStyle(true, EMFR^.emr.iType = EMR_POLYGON, Sh);
    ActiveSprite.PlaceObject(Sh, ActiveSprite.MaxDepth + 1);
    if EMFR^.emr.iType = EMR_POLYLINETO then
     with MapPoint(PLP[cptl - 1]) do
      LastMoveToXY := Point(X, Y);
  end;
end;

procedure TFlashCanvas.DoPOLYLINETO(EMFR: PEMRPOLYLINETO);
begin
  DoPOLYLINE(EMFR);
end;

procedure TFlashCanvas.DoPOLYGON(EMFR: PEMRPOLYGON);
begin
  DoPOLYLINE(EMFR);
end;

procedure TFlashCanvas.DoSETWINDOWEXTEX(EMFR: PEMRSETWINDOWEXTEX);
begin
  with EMFR^ do
   begin
    WindowExt.Right := szlExtent.cx;
    WindowExt.Bottom := szlExtent.cy;
    hasInitWindow := true;
    MustCreateWorldTransform := true;
   end;
end;

procedure TFlashCanvas.DoSETWINDOWORGEX(EMFR: PEMRSETWINDOWORGEX);
 var P: TPoint;
begin
 with EMFR^ do
  begin
   GetWindowOrgEx(BufferBMP.DC, P);
   WindowExt.TopLeft := P;
//   WindowExt.TopLeft := ptlOrigin;
   hasInitWindowOrg := true;
  end;
end;

procedure TFlashCanvas.DoSETVIEWPORTEXTEX(EMFR: PEMRSETVIEWPORTEXTEX);
begin
 with EMFR^ do
  begin
   ViewportExt.Right := szlExtent.cx;
   ViewportExt.Bottom := szlExtent.cy;
   hasInitViewport := true;
  end;

end;

procedure TFlashCanvas.DoSETVIEWPORTORGEX(EMFR: PEMRSETVIEWPORTORGEX);
begin
  with EMFR^ do
   begin
    if LastCommand <> EMR_SETVIEWPORTORGEX then
      ViewportExt.TopLeft := ptlOrigin;
//    if not hasInitWindow and (ptlOrigin.X = 0) and (ptlOrigin.Y = 0) then
//      GlobalOffset := Point(0, 0);
    hasInitViewport := true;
    hasInitViewportOrg := true;
   end;
end;

function TFlashCanvas.GetFlashROP(ROP: DWord): TSWFBlendMode;
begin
  case ROP of
   SRCCOPY:
     Result := bmNormal;
   DSTINVERT, PATINVERT:
     Result := bmInvert;
   SRCPAINT:
     Result := bmLighten;
   SRCAND:
     Result := bmDarken;
   SRCINVERT:
     Result := bmDifference;
    else
     Result := bmNormal;
   end;
end;

function TFlashCanvas.PlaceROP(BMP: TBMPReader; Bounds: TRect; ROP: DWord; Color: Cardinal): TFlashPlaceObject;
 var
    newRop: DWord;
    FBkColor, tmpBgColor: Cardinal;
    Im: TFlashImage;
    Blend: TSWFBlendMode;
    tmpTransparent: boolean;
    UseImg: boolean;
begin
  newRop := ROP;
  Im := nil;
  UseImg := false;
  
  case ROP of
   BLACKNESS:
     FBkColor := 0;
   WHITENESS:
     FBkColor := $FFFFFF;
    else
     FBkColor := Color;
  end;                     

  if BMP <> nil then
    begin
      if (BMP.Width = 1) and (BMP.Height = 1)
        then
          with BMP.GetPixel(0, 0) do
            FBkColor := RGB(r, g, b)
        else
        begin
          UseImg := true;
          case ROP of
           SRCPAINT:
             begin
               if (BMP.Bpp = 32) then
                FillAlphaNoSrc(BMP, $FF);
             end;
           NOTSRCCOPY:
             begin
               InvertRect(BMP.DC, Rect(0,0, BMP.Width, BMP.Height));
               newRop := SRCCOPY;
             end;
           else
             if (BMP.Bpp = 32) and not IsInitAlpha(BMP)
               then FillAlpha(BMP, $FF);
          end;
        end;
    end;



  Sh := Owner.AddRectangle(Bounds);
  Blend := bmNormal;
  if (roUseBuffer in RenderOptions) and
   TObjMFRecord(ListMFRecords[CurrentRec-1]).FromRend then
    begin
     Im := Owner.AddImage;
     Im.BMPStorage.MakeCopy(BMP, true);
     Im.GetBMPInfo;
     Sh.SetImageFill(Im, fmFit);
    end
   else
    begin
      case ROP of
       PATCOPY, PATINVERT, PATPAINT, $A000C9{PATAND}:
         begin
           tmpTransparent := BgTransparent;
           BgTransparent := false;
           tmpBgColor := BgColor;
    //       BgColor := FBkColor;
           ShapeSetStyle(False, true, Sh);
           BgColor := tmpBgColor;
           BgTransparent := tmpTransparent;
         end;
        else
         begin
           if UseImg then
             begin
               Im := Owner.AddImage;
               Im.BMPStorage.MakeCopy(BMP, true);
               Im.GetBMPInfo;
             end;

           if Im <> nil
             then Sh.SetImageFill(Im, fmFit)
             else Sh.SetSolidColor(SWFRGB(FBkColor));
         end;
      end;


      case newRop of
       SRCCOPY:
         Blend := bmNormal;
       DSTINVERT:
         Blend := bmInvert;
       SRCPAINT, PATPAINT:
         Blend :=  bmLighten;
       SRCAND, $A000C9:
         Blend := bmDarken;
       SRCINVERT, PATINVERT:
         Blend := bmDifference;
       end;
    end;

  Result := ActiveSprite.PlaceObject(Sh, ActiveSprite.MaxDepth + 1);
  with Result do
    begin
     if Blend > bmNormal then BlendMode := Blend;
    end;

end;

procedure TFlashCanvas.DoBITBLT(EMFR: PEMRBITBLT);
 var
     BgRect: TRect;
     BMP: TBMPReader;
     PBits: PByte;
     OMFR: TObjMFRecord;
     ndwRop : longint;
     AsBMP: boolean;

 function GetGradientAlpha: integer;
  var ilist, ix, iy: integer;
 begin
   ilist := ListMFRecords.IndexOf(OMFR.PrevGDI);
 //  iStop := ListMFRecords.IndexOf(OMFR.PrevGDI.PrevGDI);
   Result := 0;
   while ilist > 0 do
    with TObjMFRecord(ListMFRecords[ilist]) do
    begin
      if Rec.iType = EMR_CREATEDIBPATTERNBRUSHPT then
       begin
         BMP := TBMPReader.Create;
         with TGDIHandleDibBrush(HTables[PEMRCREATEDIBPATTERNBRUSHPT(Rec)^.ihBrush]) do
           begin
             Info.Position := 0;
             BMP.LoadFromStream(Info);
           end;
         for iy := 0 to 7 do
           for ix := 0 to 7 do
             if BMP.PixelsB[iy, ix] = 1  then Inc(Result);
         Result := - Round(Result/64*255);
         BMP.Free;
         Break;
       end
       else dec(ilist);
    end;
 end;

begin

  with EMFR^ do
  begin
    ndwRop := dwRop;
    AsBMP := true;
    BgRect := MapRect(Rect(xDest, yDest, xDest + cxDest, yDest + cyDest));
    if (BgRect.Bottom - BgRect.Top) = 0 then BgRect.Bottom := BgRect.Bottom + 1;
    OMFR := TObjMFRecord(ListMFRecords[CurrentRec-1]);
    if OMFR.SpecDraw in [ooStartTransparentFill, ooEndTransparentFill] then
       begin
         EnableTransparentFill := OMFR.SpecDraw = ooStartTransparentFill;
         AsBMP := false;
         BMP := nil;
       end else
    if OMFR.SpecDraw = ooTransparentRect then
       begin
         ndwRop := SRCCOPY;
         AsBMP := false;
         Sh := Owner.AddRectangle(BgRect);
         ShapeSetStyle(false, true, Sh);
         ActiveSprite.PlaceObject(Sh, ActiveSprite.MaxDepth + 1).ColorTransform.addA := GetGradientAlpha;
         BMP := nil;
       end else
    if (roUseBuffer in RenderOptions) and OMFR.FromRend then
      begin
        BMP := GetCopyFromRender(BgRect);
      end else
      if cbBitsSrc > 0 then
        begin
          BMP := TBMPReader.Create;
          BMP.SetSizeIndirect(PBMInfo(Longint(EMFR) + offBmiSrc)^);
          PBits := Pointer(Longint(EMFR) + offBitsSrc);
          Move(PBits^, BMP.Bits^, BMP.SizeImage);

        end else
          BMP := nil;
      if AsBMP {and (BMP <> nil)} then
        PlaceROP(BMP, BgRect, ndwRop, crBkColorSrc);
      if BMP <> nil then BMP.Free;
  end;
end;

procedure TFlashCanvas.DoSTRETCHBLT(EMFR: PEMRSTRETCHBLT);
 var
     BgRect: TRect;
     BMP, Cropped: TBMPReader;
     PBits: PByte;
begin
//  if EMFR^.dwRop = $00AA0029 then exit; {empty ROP}

  with EMFR^ do
    begin
     BgRect := MapRect(Rect(xDest, yDest, xDest + cxDest, yDest + cyDest));
      //BgRect := rclBounds;
     if (BgRect.Bottom - BgRect.Top) = 0 then BgRect.Bottom := BgRect.Bottom + 1;
     if (roUseBuffer in RenderOptions) and TObjMFRecord(ListMFRecords[CurrentRec-1]).FromRend then
      begin
        BMP := GetCopyFromRender(BgRect);
      end else
      if cbBitsSrc > 0 then
        begin
          BMP := TBMPReader.Create;
          BMP.SetSizeIndirect(PBMInfo(Longint(EMFR) + offBmiSrc)^);
          PBits := Pointer(Longint(EMFR) + offBitsSrc);
          Move(PBits^, BMP.Bits^, BMP.SizeImage);
          if (BMP.Width > (cxSrc - xSrc)) or (BMP.Height > (cySrc - ySrc)) then
            begin
              Cropped := TBMPReader.Create;
              Cropped.SetSize(cxSrc, cySrc, BMP.Bpp);
              Cropped.CopyRect(BMP, 0, 0, cxSrc, cySrc, xSrc, ySrc);
              BMP.Free;
              BMP := Cropped;
            end;

        end else
          BMP := nil;
      PlaceROP(BMP, BgRect, dwRop, crBkColorSrc);
      if BMP <> nil then BMP.Free;
    end;
end;

procedure TFlashCanvas.DoSTRETCHDIBITS(EMFR: PEMRSTRETCHDIBITS);
 var
     BgRect: TRect;
     BMP, Cropped: TBMPReader;
     PBits: PByte;
     PO: TFlashPlaceObject;
     LenXY: TPoint;
begin
//  if EMFR^.dwRop = $00AA0029 then exit; {empty ROP}

  with EMFR^ do
    begin
      BgRect := MapRect(Rect(xDest, yDest, xDest + cxDest, yDest + cyDest));
      BgRect := NormalizeRect(BgRect);
      //BgRect := rclBounds;
      if (BgRect.Bottom - BgRect.Top) = 0 then BgRect.Bottom := BgRect.Bottom + 1;
      if (roUseBuffer in RenderOptions) and TObjMFRecord(ListMFRecords[CurrentRec-1]).FromRend then
        begin
          BMP := GetCopyFromRender(BgRect);
        end else
      if cbBitsSrc > 0 then
        begin
          BMP := TBMPReader.Create;
          BMP.SetSizeIndirect(PBMInfo(Longint(EMFR) + offBmiSrc)^);
          PBits := Pointer(Longint(EMFR) + offBitsSrc);
          Move(PBits^, BMP.Bits^, BMP.SizeImage);
          if (BMP.Width > Abs(cxSrc - xSrc)) or (BMP.Height > Abs(cySrc - ySrc)) then
            begin
              Cropped := TBMPReader.Create;
              Cropped.SetSize(cxSrc, cySrc, BMP.Bpp);
              Cropped.CopyRect(BMP, 0, 0, cxSrc, cySrc, xSrc, ySrc);
              BMP.Free;
              BMP := Cropped;
            end;
        end else
          BMP := nil;

      PO := PlaceROP(BMP, BgRect, dwRop, 0);
      if not(roUseBuffer in RenderOptions) then
      begin
        LenXY := Point(MapLen(cxDest, false), MapLen(cyDest, true));
        if ((LenXY.X < 0) or (LenXY.Y < 0)) then
        begin
          PO.SetScale(Sign(LenXY.X), Sign(LenXY.Y));
          if LenXY.X < 0 then PO.TranslateX := BgRect.Right;
          if LenXY.Y < 0 then PO.TranslateY := BgRect.Bottom;
        end;
      end;
      if BMP <> nil then BMP.Free;
    end;
end;

procedure TFlashCanvas.DoPOLYPOLYGON16(EMFR: PEMRPOLYPOLYGON16);
 var dX, dY, i, J, eSt, eEn : integer;
     P0, P1: TPoint;
begin
   if DrawMode = dmPath then exit;
   with EMFR^ do
    begin
      dY := Cardinal(@aPolyCounts);   // aPolyCounts
      dX := dY + 4*nPolys;              // apts
      sh:=nil;
      for J:=0 to nPolys -1 do
      begin
        if J = 0 then eSt := 0
                 else eSt := eEn + 1;
        if J = (nPolys-1)
           then eEn := cpts - 1
           else eEn := eSt + aPolyCounts[J]-1;

        P0 := MapPoint(AsmP(dX)[eSt]);
        if sh = nil then
          with MapPoint(AsmP(dX)[eSt+1]) do
             sh:=Owner.AddLine(P0.X, P0.Y, X, Y)
           else begin
              sh.Edges.MoveTo(P0.x, P0.y);
              with MapPoint(AsmP(dX)[eSt+1]) do
                sh.Edges.LineTo(X, Y);
            end;
        for I := eSt + 2 to eEn do
          begin
            P1 := MapPoint(AsmP(dX)[i]);
            sh.Edges.LineTo(P1.X, P1.Y);
          end;

        if (EMFR^.emr.iType = EMR_POLYPOLYGON16) and ((P1.X <> P0.X) or (P1.Y <> P0.Y)) then
          sh.Edges.LineTo(P0.X, P0.Y);

      end;
        Sh.CalcBounds;

        ShapeSetStyle(true, EMFR^.emr.iType = EMR_POLYPOLYGON16, Sh);
        ActiveSprite.PlaceObject(Sh, ActiveSprite.MaxDepth + 1);
        if EMFR^.emr.iType = EMR_POLYPOLYLINE16 then
          LastMoveToXY := MapPoint(AsmP(dX)[eEn]);
    end;

end;

procedure TFlashCanvas.DoPOLYPOLYLINE16(EMFR: PEMRPOLYPOLYLINE16);
begin
  DoPOLYPOLYGON16(EMFR);
end;

function PreEnumRec(DC: HDC; var HTable: THandleTable; EMFR: PEnhMetaRecord; nObj: Integer; Sender: TFlashCanvas): BOOL; stdcall;
begin
  Sender.ListMFRecords.Add(TObjMFRecord.Create(EMFR));
  Result := true;
end;

function CheckTransparentRect(MFRO: TObjMFRecord; iType: word): boolean;
begin
 Result := (MFRO.fRop = $5A0049) and (MFRO.PrevGDI <> nil) and
           (MFRO.PrevGDI.Rec.iType = iType) and (MFRO.PrevGDI.fRop = $A000C9) and
           (MFRO.PrevGDI.PrevGDI <> nil) and (MFRO.PrevGDI.PrevGDI.Rec.iType = iType) and
           (MFRO.PrevGDI.PrevGDI.fRop = $5A0049);
end;

function CheckTransparentFill(MFRO: TObjMFRecord): boolean;
  var PGDI, DGDI: TObjMFRecord;
begin
  Result := false;
  if PEMRBITBLT(MFRO.Rec)^.dwRop = $5A0049 then
  begin
    PGDI := MFRO.PrevGDI;
    while (PGDI <> nil) do
    begin
      if (PGDI.Rec.iType = EMR_BITBLT) then
      begin
        if (PEMRBITBLT(PGDI.Rec)^.dwRop = $5A0049) and
            myCompareRect(PEMRBITBLT(PGDI.Rec)^.rclBounds, PEMRBITBLT(MFRO.Rec)^.rclBounds) then
        begin
          Result := true;
          PGDI.SpecDraw := ooStartTransparentFill;
          DGDI := MFRO.PrevGDI;
          while PGDI <> DGDI do
          begin
            DGDI.FromRend := false;
            DGDI := DGDI.PrevGDI;
          end;
        end;
        PGDI := nil;
      end else PGDI := PGDI.PrevGDI;
    end;
  end;
end;


procedure TFlashCanvas.MakeListMFRecords(MetaHandle: THandle; r: TRect);
 var il: word;
     PrevGDI, MFRO: TObjMFRecord;
     PCh: PChar;
begin
  ListMFRecords.Clear;
  EnumEnhMetaFile(0, MetaHandle, @PreEnumRec, self, r);

  PrevGDI := nil;
  isEMFPlus := false;
  for il := 0 to ListMFRecords.Count - 1 do
    begin
      MFRO := TObjMFRecord(ListMFRecords[il]);
      if (MFRO.Rec.iType = EMR_GDICOMMENT) and not isEMFPlus then
        begin
          PCh := @PEMRGDICOMMENT(MFRO.Rec)^.Data;
          isEMFPlus := Pos('EMF+', Pch) = 1;
        end;

      if MFRO.IsGDIOut then
      begin
        if (PrevGDI <> nil) then MFRO.PrevGDI := PrevGDI;
        PrevGDI := MFRO;
      end;
    end;

  if (roOptimization in RenderOptions) and isEMFPlus then
   for il := 0 to ListMFRecords.Count - 1 do
    begin
      MFRO := TObjMFRecord(ListMFRecords[il]);
      case MFRO.Rec.iType of
      EMR_BITBLT:
        begin
          if CheckTransparentFill(MFRO) then
          begin
            MFRO.SpecDraw := ooEndTransparentFill;
          end else
          if CheckTransparentRect(MFRO, EMR_BITBLT) then
          begin
            MFRO.SpecDraw := ooTransparentRect;
            MFRO.PrevGDI.IsDraw := false;
            MFRO.PrevGDI.PrevGDI.IsDraw := false;
          end;
        end;
      end;

    end;
end;

procedure TFlashCanvas.MakeTextOut(WText: WideString; Point0: TPoint; Bounds,
    ClippRect: TRect; TextWidth: Integer; fOptions: word; PAWidth: Pointer;
    WCount: integer; iGraphicsMode: DWord);
 var
    FMFont: TFont;
    FlashFont: TFlashFont;
    NativTextWidth: longint;
    Point1: TPoint;
    MustCharsSprite: boolean;
    BgRect: TRect;
    TextSprite, CharsSprite: TFlashSprite;
    StrikeOutShape, UnderlineShape: TFlashShape;
    CharsList: TObjectList;
    XPos, il: longint;
    St: TFlashText;
    PInt: PLongint; 
    AWidth: ACPoly absolute PInt;

  function TextAlignParse(TA: DWord; vert: boolean): byte;
  begin
    if Vert then
     begin
       if TA >= TA_BASELINE then Result := TA_BASELINE else
         if TA < TA_BOTTOM then Result := TA_TOP else Result := TA_BOTTOM;
     end else
     begin
       Result := TA and 7;
     end;
  end;

  function fMakeText( T: WideString; R: TRect): TFlashText;
    var il: integer;
  begin
    if (CharsList <> nil) and (CharsList.Count > 0) then
     for il := 0 to CharsList.Count -1 do
       begin
         Result := TFlashText(CharsList.Items[il]);
         if Result.WideText = T then Exit;
       end;

    if FlashFont.AsDevice then
     begin
       Result := Owner.AddDynamicText('', T, SWFRGBA(TextColor), FlashFont, R);
       Result.AutoSize := true;
       Result.NoSelect := true;
     end else
     begin
       Result := Owner.AddText(T, SWFRGBA(TextColor), FlashFont, R.TopLeft);
     end;
    Result.TextHeight := Abs(FMFont.Height);
  end;

begin
  PInt := PAWidth;
  FMFont := TFont.Create;
  GetMetrixFont(FMFont);
  if (Abs(LogFontInfo.lfHeight) > $FFF) then {bug of metafile}
   begin
     FMFont.Free;
     Exit;
   end;

  if PrevFont = nil then
    begin
      FlashFont := owner.Fonts.FindByFont(FMFont, false);
      if FlashFont = nil then
        FlashFont := Owner.AddFont(LogFontInfo {FMFont}, not EmbeddedFont);
      FlashFont.AddChars(WText);
      PrevFont := FlashFont;
    end else
      FlashFont := PrevFont;

// ==== calc width and clipp rect ====
  if (Length(WText) > 1) or (TextWidth = 0) then
    begin
      NativTextWidth := FlashFont.GetTextExtentPoint(WText).cx div 20;
      if TextWidth = 0 then TextWidth := NativTextWidth;
      MustCharsSprite := abs(NativTextWidth - TextWidth) > 2;
    end else MustCharsSprite := false; 

  if (not MustCharsSprite) and (LogFontInfo.lfOrientation <> 0)
       and (WCount > 0) then MustCharsSprite := true;

   Point1 := Point(0, 0);
   case TextAlignParse(TextAlign, true) of
     TA_TOP: Point1.Y := 0;
     TA_BASELINE: Point1.Y := - FTextMetric.otmTextMetrics.tmAscent;
     TA_BOTTOM: Point1.Y := - FTextMetric.otmTextMetrics.tmHeight;
   end;
   case TextAlignParse(TextAlign, false) of
     TA_LEFT: Point1.X := 0;
     TA_CENTER: Point1.X := - TextWidth div 2;
     TA_RIGHT: Point1.X := - TextWidth;
   end;

  if (LogFontInfo.lfEscapement <> 0) or ((fOptions = 0) and (WCount = 0)) then
    begin
      BgRect := Rect(0, 0, TextWidth, FTextMetric.otmTextMetrics.tmHeight);
      OffsetRect(BgRect, Point1.X, Point1.Y);
      inc(Point1.Y, 1);
    end else
    begin
      BgRect := Bounds;
      OffsetRect(BgRect, -Point0.X, -Point0.Y);
    end;

// ==== place background =====
  CharsSprite := Owner.AddSprite;
  if (fOptions = 0) and (LogFontInfo.lfEscapement = 0)
    then TextSprite := CharsSprite
    else TextSprite := Owner.AddSprite;

  if not BgTransparent then
    begin
      Sh := Owner.AddRectangle(BgRect);
      Sh.SetSolidColor(SWFRGB(BgColor));
      with CharsSprite.PlaceObject(Sh, 1) do
        begin
        end;
    end;

  if (fOptions <> 0) {or true} then
    begin
      Sh := Owner.AddRectangle(ClippRect);

      if ((fOptions and ETO_OPAQUE) = ETO_OPAQUE) {or true} then
        begin
          Sh.SetSolidColor(SWFRGB(BgColor));
          TextSprite.PlaceObject(Sh, 3);
        end;

      if (fOptions and ETO_CLIPPED) = ETO_CLIPPED then
        begin
          if Sh.FillStyleNum = 0 then Sh.SetSolidColor(cswfYellow);
          TextSprite.PlaceObject(Sh, 4).ClipDepth := 5;
        end;
    end;

// ==== decoration shapes ====
  if boolean(LogFontInfo.lfStrikeOut) then
    begin
      StrikeOutShape := Owner.AddRectangle(0, 0, 10, FTextMetric.otmsStrikeoutSize);
      StrikeOutShape.SetSolidColor(SWFRGBA(TextColor));
    end;

  if boolean(LogFontInfo.lfUnderline) then
    begin
      UnderlineShape := Owner.AddRectangle(0, 0, 10, FTextMetric.otmsUnderscoreSize);
      UnderlineShape.SetSolidColor(SWFRGBA(TextColor));
    end;

   CharsList := nil;
   if MustCharsSprite then
     begin
       CharsList := TObjectList.Create;
       XPos := 0;
       for il := 1 to Length(WText) do
         begin
           St := fMakeText(WideString(WText[il]), Rect(0, 0, MapLen(AWidth[il-1], false), FTextMetric.otmTextMetrics.tmHeight));
           with CharsSprite.PlaceObject(St, CharsSprite.MaxDepth + 1) do
            begin
              if Abs(FCWorldTransform.eM11) <> Abs(FCWorldTransform.eM22) then
                 SetScale(Abs(FCWorldTransform.eM11/FCWorldTransform.eM22), 1) else
              if LogFontInfo.lfWidth <> 0 then
                SetScale(FontScale{LogFontInfo.lfWidth/FTextMetric.otmTextMetrics.tmAveCharWidth}, 1);

              if (LogFontInfo.lfOrientation <> 0) and (iGraphicsMode = GM_ADVANCED) then
                SetRotate((-LogFontInfo.lfEscapement + LogFontInfo.lfOrientation)/10);

//              if (TGDIHandleFont(HTables[CurrentFont]).Info.elfLogFont.lfHeight < 0)
//                then
                  SetTranslate(Point1.X + MapLen(XPos, false), Point1.Y+Byte(EmbeddedFont));
//                else
//                  SetTranslate(XPos, Point1.Y + Byte(EmbeddedFont));
            end;
           XPos := XPos + AWidth[il-1];
         end;

       CharsList.Free;
     end else
     begin
       St := fMakeText(WText, Rect(0, 0, TextWidth, FTextMetric.otmTextMetrics.tmHeight));

       with CharsSprite.PlaceObject(St, CharsSprite.MaxDepth + 1) do
         begin
           if LogFontInfo.lfWidth <> 0 then
             SetScale(FontScale{LogFontInfo.lfWidth/FTextMetric.otmTextMetrics.tmAveCharWidth}, 1);

           SetTranslate(Point1.X, Point1.Y+Byte(EmbeddedFont));
         end;
     end;

   if LogFontInfo.lfOrientation = 0 then
     begin
       if boolean(LogFontInfo.lfUnderline) then
         with CharsSprite.PlaceObject(UnderlineShape, CharsSprite.MaxDepth + 1) do
           begin
             SetTranslate(Point1.X, FTextMetric.otmTextMetrics.tmAscent + Point1.Y - FTextMetric.otmsUnderscorePosition);
             SetScale((TextWidth - 1)/UnderlineShape.Bounds.Width*twips, 1);
           end;
       if boolean(LogFontInfo.lfStrikeOut) then
         with CharsSprite.PlaceObject(StrikeOutShape, CharsSprite.MaxDepth + 1) do
           begin
             SetTranslate(Point1.X, FTextMetric.otmTextMetrics.tmAscent + Point1.Y - FTextMetric.otmsStrikeoutPosition);
             SetScale((TextWidth - 1)/StrikeOutShape.Bounds.Width*twips, 1);
           end;
     end;

  if TextSprite <> CharsSprite then
    with TextSprite.PlaceObject(CharsSprite, 5) do
      begin
        if LogFontInfo.lfEscapement <> 0 then SetRotate(LogFontInfo.lfEscapement/10);
      end;

// ====  main place =====
  with ActiveSprite.PlaceObject(TextSprite, ActiveSprite.MaxDepth + 1) do
    begin
      SetTranslate(Point0.X, Point0.Y);
    end;


  FMFont.Free;
end;

procedure TFlashCanvas.DoEXTTEXTOUTW(EMFR: PEMREXTTEXTOUT);
  var _PW: PWord;
      WText: WideString;
      il, dX: integer;
      PInt: PLongint;
      PAWidth: ACPoly absolute PInt;
      _PB: PByte;
      ClippRect: TRect;
      TextWidth: longint;
      Point0: TPoint;
      WidthCount: integer;
begin
 if DrawMode = dmPath then Exit;

 with EMFR^ do
   begin
     SetLength(WText, emrtext.nChars);
     If EMFR^.emr.iType = EMR_EXTTEXTOUTW then
      begin
       _PW := Pointer(Cardinal(EMFR)+emrtext.offString);
       if ((EMFR^.emrtext.fOptions and ETO_GLYPH_INDEX) = ETO_GLYPH_INDEX) then dx := 29 else dx := 0;
       For il := 1 to emrtext.nChars do
        begin
         WText[il] := WideChar(_PW^ + dx);
         inc(_PW);
        end;
      end else
      begin
       _PB := Pointer(Cardinal(EMFR)+emrtext.offString);
       For il := 1 to emrtext.nChars do
        begin
         WText[il] := WideChar(_PB^);
         inc(_PB);
        end;
      end;
   if (emrtext.offDx > 0) and (emrtext.nChars > 0) then
     begin
      WidthCount := emrtext.nChars;
      PInt := Pointer(Cardinal(EMFR) + emrtext.offDx);
     end else
     begin
      WidthCount := 0;
      PInt := nil;
     end;

  end;


// exit;
 if (DrawMode = dmPath) or (WText = '') or
    ((Trim(WText) = '') and not(((EMFR^.emrtext.fOptions and ETO_OPAQUE) = ETO_OPAQUE) or
                                ((TextAlign and TA_UPDATECP) = TA_UPDATECP))) then Exit;

 with EMFR^ do
  begin
// ==== get start point ====
    if (TextAlign and TA_UPDATECP) = TA_UPDATECP then
      begin
       Point0 := LastMoveToXY;
       GetCurrentPositionEx(BufferBMP.DC, @LastMoveToXY);
       LastMoveToXY := MapPoint(LastMoveToXY);
      end else
      begin
       Point0 := MapPoint(emrtext.ptlReference);
      end;

    TextWidth := 0;
    if emrtext.offDx > 0 then
      begin
        for il := 1 to emrtext.nChars do
          TextWidth := TextWidth + PAWidth[il-1];
        TextWidth := MapLen(TextWidth, false);
      end;

    if emrtext.fOptions = 0 then ClippRect := Rect(0, 0, 0, 0) else
      begin
        ClippRect := MapRect(emrtext.rcl);
        OffsetRect(ClippRect, -Point0.X, -Point0.Y);
      end;

    MakeTextOut(WText, Point0, rclBounds, ClippRect, TextWidth, emrtext.fOptions, PAWidth, WidthCount, iGraphicsMode);
  end;

end;

procedure TFlashCanvas.DoEXTTEXTOUTA(EMFR: PEMREXTTEXTOUT);
begin
  DoEXTTEXTOUTW(EMFR);
end;

type
 PEMRSmallTextOut = ^TEMRSmallTextOut;
 TEMRSmallTextOut = record
  emr: TEMR;
  ptlReference: TPoint;
  nChars: DWord;
  fOptions: DWord;
  iGraphicsMode: DWord;
  exScale: single;
  eyScale: single;
  Text: array [0..0] of char;
 end;

procedure TFlashCanvas.DoSMALLTEXTOUT(EMFR: PEnhMetaRecord);
 var EMRTextOut: PEMRSmallTextOut;
     _PB: PByte;
     _PW: PWord;
     WText: WideString;
     il: integer;
begin
 EMRTextOut := Pointer(EMFR);
 if EMRTextOut.nChars = 0 then Exit;
 SetLength(WText, EMRTextOut.nChars);
 If (EMRTextOut.fOptions = $100) then
   begin
    _PW := Pointer(@EMRTextOut.Text);
    For il := 1 to EMRTextOut.nChars do
     begin
      WText[il] := WideChar(_PW^);
      inc(_PW);
     end;
   end else
   begin
    _PB := Pointer(Longint(@EMRTextOut.Text) + byte((EMRTextOut.fOptions and 516) = 516)*SizeOf(TRect));

    For il := 1 to EMRTextOut.nChars do
     begin
      WText[il] := WideChar(_PB^);
      inc(_PB);
     end;
   end;
  MakeTextOut(WText, MapPoint(EMRTextOut.ptlReference),
              Rect(0,0,0,0), Rect(0,0,0,0), 0, 0, nil, 0, EMRTextOut^.iGraphicsMode);
end;



procedure TFlashCanvas.DoSCALEVIEWPORTEXTEX(EMFR: PEMRSCALEVIEWPORTEXTEX);
begin

end;

type
  PEMRSETICMPROFILE = ^TEMRSETICMPROFILE;
  TEMRSETICMPROFILE = record
    emr: TEMR;
    dwFlags: DWORD;
    cbName: DWORD;
    cbData: DWORD;
    Data: array[0..0] of byte;
  end;

procedure TFlashCanvas.DoSETICMPROFILEA(EMFR: PEnhMetaRecord);
begin

end;

procedure TFlashCanvas.DoSETICMPROFILEW(EMFR: PEnhMetaRecord);
begin

end;

procedure TFlashCanvas.DoMASKBLT(EMFR: PEMRMASKBLT);
 var MStream: TMemoryStream;
     dX, dY, eEn, I, J, eSt: integer;
     PBuff: Pointer;
     Im: TFlashImage;
begin
     with EMFR^ do
      begin
        MStream:=TMemoryStream.Create;
        MStream.Position:=10;
        dX:=cbBmiSrc + 14;
        Mstream.Write(dX, 4);
        PBuff:=Pointer(Cardinal(EMFR) + offBmiSrc);
        MStream.WriteBuffer(PBuff^, cbBmiSrc);
        PBuff:=Pointer(Cardinal(EMFR) + offBitsSrc);
        MStream.WriteBuffer(PBuff^, cbBitsSrc);
        MStream.Position:=0;

        Im:=Owner.AddImage;
        Im.LoadDataFromStream(MStream);	   
        MStream.Free;

        dX:=cbBitsMask div PBITMAPINFO(Pointer(Cardinal(EMFR) + offBmiMask))^.bmiHeader.biHeight;     // Mask Width
        eEn:=Cardinal(EMFR) + offBitsMask;

          if Im.BMPStorage.Bpp <> 32 Then
          begin
            MStream:=TMemoryStream.Create;
            MStream.Position:=10;
            dY:=14+cbBmiSrc; // $28;
            Mstream.Write(dY, 4);
            PBuff:=Pointer(Cardinal(EMFR) + offBmiSrc);
            PBITMAPINFO(PBuff)^.bmiHeader.biBitCount:=32;
            MStream.WriteBuffer(PBuff^, cbBmiSrc);
            for I := 0 to cyDest-1 do    // Iterate
            begin
              for J:=0 to cxDest-1 do
              begin
                eSt:=(Im.BMPStorage.Pixels[I,J].r shl 16) or
                     (Im.BMPStorage.Pixels[I,J].g shl 8)  or
                      Im.BMPStorage.Pixels[I,J].b and $FFFFFF;
                MStream.Write(eSt,4);
              end;
            end;    // for
            MStream.Position:=0;
            Im.LoadDataFromStream(MStream);
          end;

          for I := 0 to cyDest-1 do    // Iterate
          begin
            PBuff:=Pointer(eEn+I*dX);
            for J := 0 to cxDest-1 do    // Iterate
            begin
            if not Boolean((ABytes(PBuff)[J div 8] shr (7-(J mod 8))) And 1) then
              begin
                Im.BMPStorage.Pixels32[I,J].a:=$FF;
              end;
            end;    // for
          end;    // for

//        end;     // if

        Sh:=Owner.AddRectangle(xDest,yDest,xDest+cxDest,yDest+cyDest);

        Sh.SetImageFill(Im, fmFit);
        ActiveSprite.PlaceObject(Sh, ActiveSprite.MaxDepth + 1);
      end;

end;

procedure TFlashCanvas.DoREALIZEPALETTE(EMFR: PEMRREALIZEPALETTE);
begin

end;

procedure TFlashCanvas.DoCHORD(EMFR: PEMRCHORD);
 var dX, dY, eSt, eEn: integer;
begin
  if DrawMode = dmPath then Exit;
  with EMFR^ do
   begin
     if ClockWs then
     begin
       dX:=ptlStart.X; dY:=ptlStart.Y;
       ptlStart:=ptlEnd;
       ptlEnd.X:=dX; ptlEnd.Y:=dY;
     end;

     Sh:=Owner.AddShape;
     Sh.Edges.IgnoreMovieSettings:=True;

     dX := twips * (rclBox.Right+rclBox.Left) div 2;
     dY := twips * (rclBox.Top+rclBox.Bottom) div 2;
     eSt:=Ceil(RadToDeg(ArcTan2(dY-twips * ptlStart.Y, twips * ptlStart.X-dX)));
     eEn:=Ceil(RadToDeg(ArcTan2(dY-twips * ptlEnd.Y, twips * ptlEnd.X -dX)));
     sh.Edges.MakeArc(dX, dY, dX-twips * rclBox.Left, dY-twips * rclBox.Top,
                         eSt, eEn, false, false);

     Sh.CalcBounds;

     Sh.Edges.LineTo(dX+Trunc((dX-twips * rclBox.Left)*cos(DegToRad(eSt))),
                    (dY-Trunc((dY-twips * rclBox.Top)*sin(DegToRad(eSt)))));

     ShapeSetStyle(true, true, Sh);
     ActiveSprite.PlaceObject(Sh, ActiveSprite.MaxDepth + 1);

     Sh.Edges.IgnoreMovieSettings:=False;
   end;

end;

procedure TFlashCanvas.DoSETWORLDTRANSFORM(EMFR: PEMRSETWORLDTRANSFORM);
begin
 FCWorldTransform := EMFR^.xForm;
 MustCreateWorldTransform := true;
end;

procedure TFlashCanvas.DoMODIFYWORLDTRANSFORM(EMFR: PEMRMODIFYWORLDTRANSFORM);
begin
 MustCreateWorldTransform := true;
 SetWTransform(EMFR^.xForm, EMFR^.iMode);
end;

procedure TFlashCanvas.DoSETSTRETCHBLTMODE(EMFR: PEMRSETSTRETCHBLTMODE);
begin
end;

procedure TFlashCanvas.DoSETMAPMODE(EMFR: PEMRSETMAPMODE);
begin
  MapMode := EMFR^.iMode;
end;

procedure TFlashCanvas.DoPIXELFORMAT(EMFR: PEMRPIXELFORMAT);
begin

end;

procedure TFlashCanvas.DoGLSBOUNDEDRECORD(EMFR: PEMRGLSBOUNDEDRECORD);
begin

end;

procedure TFlashCanvas.DoALPHADIBBLEND(EMFR: PEnhMetaRecord);
begin

end;

procedure TFlashCanvas.DoPOLYDRAW16(EMFR: PEMRPOLYDRAW16);
begin

end;

procedure TFlashCanvas.DoPLGBLT(EMFR: PEMRPLGBLT);
begin

end;

procedure TFlashCanvas.DoROUNDRECT(EMFR: PEMRROUNDRECT);
begin
 if DrawMode = dmPath then exit;
 with EMFR^ do
  begin
     Sh:=Owner.AddShape;
     Sh.Bounds.Rect := MapRect(rclBox);
     Sh.Edges.MoveTo(Sh.Bounds.Xmin, Sh.Bounds.Ymin);
     Sh.Edges.MakeRoundRect(Sh.Bounds.Width, Sh.Bounds.Height, MapLen(szlCorner.cx div 2, false), MapLen(szlCorner.cy div 2, true));
     ShapeSetStyle(true, true, Sh);
     Sh.CalcBounds;
     ActiveSprite.PlaceObject(Sh, ActiveSprite.MaxDepth + 1);
  end;
end;

procedure TFlashCanvas.DoMOVETOEX(EMFR: PEMRMOVETOEX);
begin
 if DrawMode = dmPath then Exit;
 with EMFR^ do
  begin
   LastMoveToXY := MapPoint(ptl);
   if ShapeLineTo <> nil then
     ShapeLineTo.Edges.MoveTo(LastMoveToXY.X, LastMoveToXY.Y);
   end;
 BeginPath := LastMoveToXY;
end;

procedure TFlashCanvas.DoLINETO(EMFR: PEMRLINETO);
  var P0: TPoint;
begin
  if DrawMode = dmPath then Exit;
  with EMFR^ do
   begin
    P0 := MapPoint(ptl);
    if ShapeLineTo = nil then
     begin
        ShapeLineTo := Owner.AddLine(LastMoveToXY.X, LastMoveToXY.Y, P0.X, P0.Y);
        ShapeSetStyle(true, false, ShapeLineTo);
     end
     else ShapeLineTo.Edges.LineTo(P0.X, P0.Y);
    LastMoveToXY := P0;
   end;

end;

procedure TFlashCanvas.DoSETPOLYFILLMODE(EMFR: PEMRSETPOLYFILLMODE);
begin
  if DrawMode = dmNormal then
    PolyFillMode := EMFR^.iMode;
end;

procedure TFlashCanvas.DoCOLORMATCHTOTARGETW(EMFR: PEnhMetaRecord);
begin

end;

procedure TFlashCanvas.DoPOLYBEZIER16(EMFR: PEMRPOLYBEZIER16);
 var il: integer;
     PLP: ALnP;
begin
  if DrawMode = dmPath then Exit;
  with EMFR^ do
    begin
      SetLength(PLP, cpts);
      for il := 0 to cpts-1 do PLP[il] := MapPoint(ASmp(@apts)[il]);
      Sh := Owner.AddShape;


      if (EMFR^.emr.iType = EMR_POLYBEZIERTO16) then
      begin
//         BeginPath := LastMoveToXY;
         Sh.Edges.MakePolyBezier(PLP, LastMoveToXY);
         LastMoveToXY:=Point(PLP[cpts - 1].x, PLP[cpts-1].y);
      end else
      begin
//         BeginPath := PLP[0];
         Sh.Edges.MakePolyBezier(PLP, Point(-1, -1));
      end;

      Sh.CalcBounds;
      ShapeSetStyle(true, false, Sh);
      ActiveSprite.PlaceObject(Sh, ActiveSprite.MaxDepth + 1);
      PLP:=nil;
     end;
end;

procedure TFlashCanvas.DoPOLYBEZIERTO16(EMFR: PEMRPOLYBEZIERTO16);
begin
  DoPOLYBEZIER16(EMFR);
end;

type
PEMRSetTextJustidication = ^TEMRSetTextJustidication;
  TEMRSetTextJustidication = packed record
    emr: TEMR;
    nBreakExtra: Integer;
    nBreakCount: Integer;
  end;

procedure TFlashCanvas.DoSETTEXTJUSTIFICATION(EMFR: PEnhMetaRecord);
begin
 with PEMRSetTextJustidication(EMFR)^ do
  FTextJustification := Point(nBreakExtra, nBreakCount);
end;

procedure TFlashCanvas.DoANGLEARC(EMFR: PEMRANGLEARC);
begin
 if DrawMode = dmPath then exit;
 with EMFR^ do
  begin
     Sh:=Owner.AddShape;
     Sh.Edges.IgnoreMovieSettings:=True;
     // --- to begin arc ---
  if ((LastMoveToXY.X <> Round(ptlCenter.X+nRadius*Cos(eStartAngle+90))) or
     (LastMoveToXY.Y <> Round(ptlCenter.Y+nRadius*Sin(eStartAngle+90)))) Then
  begin
       Sh.Edges.MoveTo(twips * LastMoveToXY.X, twips * LastMoveToXY.Y);
       with MapPoint(ptlCenter) do
        Sh.Edges.LineTo(twips * X + Trunc(twips * nRadius*cos(DegToRad(eStartAngle))),
                        twips * Y - Trunc(twips * nRadius*sin(DegToRad(eStartAngle))));
  end;
     // --- draw arc ---
    with MapPoint(ptlCenter) do
      sh.Edges.MakeArc(twips * X, twips * Y,
                       twips * nRadius, twips * nRadius,
                       eStartAngle, eStartAngle+eSweepAngle, false, false);
    ShapeSetStyle(true, false, Sh);
    Sh.CalcBounds;
    ActiveSprite.PlaceObject(Sh, ActiveSprite.MaxDepth + 1);

    LastMoveToXY.X := Sh.Edges.CurrentPos.X div twips;
    LastMoveToXY.Y := Sh.Edges.CurrentPos.Y div twips;
    Sh.Edges.IgnoreMovieSettings:=False;
  end;

end;

procedure TFlashCanvas.DoCREATEBRUSHINDIRECT(EMFR: PEMRCREATEBRUSHINDIRECT);
begin
 with EMFR^ do
  begin
    if HTables[ihBrush] <> nil then HTables[ihBrush].Free;
    HTables[ihBrush] := TGDIHandleBrush.Create(lb);
  end;

end;

procedure TFlashCanvas.DoDELETECOLORSPACE(EMFR: PEMRDELETECOLORSPACE);
begin

end;

procedure TFlashCanvas.DoPOLYTEXTOUTA(EMFR: PEMRPOLYTEXTOUT);
begin

end;

procedure TFlashCanvas.DoRECTANGLE(EMFR: PEMRRECTANGLE);
 var R2: TRect;
begin
 if DrawMode = dmPath then exit;
 with EMFR^ do
  begin
    R2 := MapRect(rclBox);
//    if ((ViewportExt.Left <> 0) or (ViewportExt.Top <> 0)) and (WindowExt.Right = 0)
//      then
//        OffsetRect(R2, ViewportExt.Left, ViewportExt.Top);
    Sh := Owner.AddRectangle(R2);
    ShapeSetStyle(true, true, Sh);
    ActiveSprite.PlaceObject(Sh, ActiveSprite.MaxDepth + 1);
  end;

end;

procedure TFlashCanvas.DoSETBKCOLOR(EMFR: PEMRSETBKCOLOR);
begin
  BgColor := EMFR^.crColor;
end;

procedure TFlashCanvas.DoSETBKMODE(EMFR: PEMRSETBKMODE);
begin
  BgTransparent := EMFR^.iMode = TRANSPARENT;
end;

procedure TFlashCanvas.DoTRANSPARENTDIB(EMFR: PEnhMetaRecord);
begin

end;

type
 PEMRCOLORCORRECTPALETTE = ^TEMRCOLORCORRECTPALETTE;
 TEMRCOLORCORRECTPALETTE = Record
   emr: TEMR;
   ihPalette: DWORD;
   nFirstEntry: DWORD;        // Index of first entry to correct
   nPalEntries: DWORD;        // Number of palette entries to correct
   nReserved: DWORD;
 end;

procedure TFlashCanvas.DoCOLORCORRECTPALETTE(EMFR: PEnhMetaRecord);
begin

end;

procedure TFlashCanvas.DoEXCLUDECLIPRECT(EMFR: PEMREXCLUDECLIPRECT);
begin

end;

procedure TFlashCanvas.DoSETICMMODE(EMFR: PEMRSETICMMODE);
begin
end;

procedure TFlashCanvas.DoEXTFLOODFILL(EMFR: PEMREXTFLOODFILL);
begin
  // no support
end;

procedure TFlashCanvas.DoRESTOREDC(EMFR: PEMRRESTOREDC);
begin
 if ClippSprite <> nil then CloseActiveSprite;
 ReInitViewPort;
end;

procedure TFlashCanvas.DoSETMITERLIMIT(EMFR: PEMRSETMITERLIMIT);
begin

end;


procedure TFlashCanvas.DoELLIPSE(EMFR: PEMRELLIPSE);
 var R2: TRect;
begin

 if DrawMode = dmPath then Exit;
 with EMFR^ do
   begin
      R2 := NormalizeRect(MapRect(rclBox));
      if (R2.Right - R2.Left) = 0 then inc(R2.Right);
      if (R2.Bottom - R2.Top) = 0 then inc(R2.Bottom);
      Sh := Owner.AddEllipse(R2);
      ShapeSetStyle(true, true, Sh);

      ActiveSprite.PlaceObject(Sh, ActiveSprite.MaxDepth + 1);
   end;
end;

procedure TFlashCanvas.DoFORCEUFIMAPPING(EMFR: PEnhMetaRecord);
begin

end;

procedure TFlashCanvas.DoRESIZEPALETTE(EMFR: PEMRRESIZEPALETTE);
begin

end;

procedure TFlashCanvas.DoCREATECOLORSPACEW(EMFR: PEnhMetaRecord);
begin

end;

procedure TFlashCanvas.DoEXTESCAPE(EMFR: PEnhMetaRecord);
begin

end;

procedure TFlashCanvas.DoSELECTOBJECT(EMFR: PEMRSELECTOBJECT);
begin
  with EMFR^ do
   begin
     if (ihObject and $80000000)<>0 then
      begin
        Case (ihObject and $FF) of
         WHITE_BRUSH, LTGRAY_BRUSH, GRAY_BRUSH, DKGRAY_BRUSH, BLACK_BRUSH, NULL_BRUSH, DC_BRUSH:
           CurrentBrush := -(ihObject and $FF);

         WHITE_PEN, BLACK_PEN, NULL_PEN, DC_PEN:
           CurrentPen := -(ihObject and $FF);

         OEM_FIXED_FONT, ANSI_FIXED_FONT, ANSI_VAR_FONT, SYSTEM_FONT, DEVICE_DEFAULT_FONT,
         SYSTEM_FIXED_FONT, DEFAULT_GUI_FONT:
           begin
             CurrentFont := -(ihObject and $FF);
             PrevFont := nil;
           end;

         DEFAULT_PALETTE: ;
        end;

      end else
       if HTables[ihObject] <> nil then
       Case TGDIHandleInfo(HTables[ihObject]).HandleType of
        htPen:
          begin
            CurrentPen := ihObject;
          end;
        htBrush:
          begin
            CurrentBrush := ihObject;
          end;
        htFont:
           begin
             CurrentFont := ihObject;
             PrevFont := nil;
           end;
        htMonoBrush:
           begin
             CurrentBrush:=ihObject;
           end;
        htDibBrush:
           begin
             PreviusBrush := CurrentBrush;
             CurrentBrush := ihObject;
           end;
       end;
   end;
end;

procedure TFlashCanvas.DoDELETEOBJECT(EMFR: PEMRDELETEOBJECT);
 var ind: integer;
begin
  if HTables[EMFR^.ihObject] = nil then Exit; {bug of metafile} 

  Case TGDIHandleInfo(HTables[EMFR^.ihObject]).HandleType of
    htPen:   ind := CurrentPen;
    htBrush: ind := CurrentBrush;
    htFont:  ind := CurrentFont;
  end;

  if (EMFR^.ihObject < HTables.Count) and (ind = EMFR^.ihObject) then
   Case TGDIHandleInfo(HTables[EMFR^.ihObject]).HandleType of
    htPen:   CurrentPen := -1;
    htBrush: CurrentBrush := -1;
    htFont:  CurrentFont := -1;
   end;

  HTables[EMFR^.ihObject].Free;
  HTables[EMFR^.ihObject] := nil;
end;


procedure TFlashCanvas.DoPOLYPOLYGON(EMFR: PEMRPOLYPOLYGON);
begin
  DoPOLYPOLYLINE(EMFR);
end;


procedure TFlashCanvas.DoSELECTPALETTE(EMFR: PEMRSELECTPALETTE);
begin

end;

procedure TFlashCanvas.DoSETTEXTALIGN(EMFR: PEMRSETTEXTALIGN);
begin
  TextAlign := EMFR^.iMode;
end;

procedure TFlashCanvas.DoALPHABLEND(EMFR: PEMRALPHABLEND);
 var
     BgRect: TRect;
     BMP: TBMPReader;
     PBits: PByte;
begin
//  if EMFR^.dwRop = $00AA0029 then exit; {empty ROP}


  with EMFR^ do
    begin
      BgRect := MapRect(Rect(xDest, yDest, xDest + cxDest, yDest + cyDest));
      if (BgRect.Bottom - BgRect.Top) = 0 then BgRect.Bottom := BgRect.Bottom + 1;

    if (roUseBuffer in RenderOptions) and TObjMFRecord(ListMFRecords[CurrentRec-1]).FromRend then
      begin
        BMP := GetCopyFromRender(BgRect);
      end else
      if cbBitsSrc > 0 then
        begin
          BMP := TBMPReader.Create;
          BMP.SetSizeIndirect(PBMInfo(Longint(EMFR) + offBmiSrc)^);
          PBits := Pointer(Longint(EMFR) + offBitsSrc);
          Move(PBits^, BMP.Bits^, BMP.SizeImage);

        end else
          BMP := nil;
      PlaceROP(BMP, BgRect, dwRop, crBkColorSrc);
      if BMP <> nil then BMP.Free;
    end;
end;

procedure TFlashCanvas.DoFILLRGN(EMFR: PEMRFILLRGN);
 var TmpRGN: THandle;
     RgnRect: TRect;
     RgnIm: TBitmap;
     Im: TFlashImage;
begin
     with EMFR^ do
      begin
        rclBounds:= NormalizeRect(rclBounds);

        TmpRGN := ExtCreateRegion(nil, cbRgnData, PRGNDATA(@RgnData)^);
        OffsetRgn(TmpRGN, -rclBounds.Left, -rclBounds.Top);

        RgnRect:=Rect(0,0,
               rclBounds.Right-rclBounds.Left, rclBounds.Bottom-rclBounds.Top);

        RgnIm:=TBitmap.Create;
        RgnIm.PixelFormat:=pf8bit;
        RgnIm.Canvas.Brush.Color:=0;
        RgnIm.Width:=rgnRect.Right;
        RgnIm.Height:=RgnRect.Bottom;
        RgnIm.Canvas.Brush.Color:=$FF;
        FillRgn(RgnIm.Canvas.Handle, TmpRGN, RgnIm.Canvas.Brush.Handle);
        DeleteObject(TmpRGN);
        Im:=Owner.AddImage;
        Im.LoadDataFromHandle(RgnIm.Handle);
        if Cardinal(Im.BMPStorage.Colors[0])=0
        then
         begin
          Im.BMPStorage.Colors[0]:=TFColorA(SWFRGBA((BgColor and $FF0000) shr 16,
                                      (BgColor and $FF00) shr 8,
                                       BgColor and $FF ,$ff));
          Im.SetAlphaIndex(1,0);
        end else
        begin
          Im.BMPStorage.Colors[1]:=TFColorA(SWFRGBA((BgColor and $FF0000) shr 16,
                                      (BgColor and $FF00) shr 8,
                                       BgColor and $FF ,$ff));
          Im.SetAlphaIndex(0,0);
        end;
        Sh := Owner.AddRectangle(rclBounds);
        Sh.SetImageFill(Im, fmFit);

        ActiveSprite.PlaceObject(Sh, ActiveSprite.MaxDepth + 1);

        RgnIm.Free;

      end;

end;

procedure TFlashCanvas.DoWIDENPATH(EMFR: PEMRWIDENPATH);
begin

end;

procedure TFlashCanvas.DoSETPIXELV(EMFR: PEMRSETPIXELV);
begin
  with EMFR^ do
    begin
     Sh := Owner.AddShape;
     with MapPoint(ptlPixel) do
       Sh.Edges.MoveTo(X, Y);
     Sh.Edges.IgnoreMovieSettings:=True;
     Sh.Edges.LineDelta(9, 9);
     Sh.Edges.IgnoreMovieSettings := False;
     sh.SetLineStyle(1, SWFRGB(crColor));
     Sh.CalcBounds;
     ActiveSprite.PlaceObject(sh, ActiveSprite.MaxDepth + 1);
    end;
end;

procedure TFlashCanvas.DoEOF(EMFR: PEMREOF);
begin
end;

procedure TFlashCanvas.DoGLSRECORD(EMFR: PEMRGLSRECORD);
begin

end;


procedure TFlashCanvas.DoPOLYDRAW(EMFR: PEMRPOLYDRAW);
begin
  if DrawMode = dmPath then Exit;

end;

procedure TFlashCanvas.DoSETBRUSHORGEX(EMFR: PEMRSETBRUSHORGEX);
begin

end;

procedure TFlashCanvas.DoCREATECOLORSPACE(EMFR: PEMRSelectColorSpace);
begin

end;

procedure TFlashCanvas.DoSETDIBITSTODEVICE(EMFR: PEMRSETDIBITSTODEVICE);
begin

end;

procedure TFlashCanvas.DoSETCOLORSPACE(EMFR: PEMRSelectColorSpace);
begin

end;

procedure TFlashCanvas.DoCREATEPALETTE(EMFR: PEMRCREATEPALETTE);
begin

end;

procedure TFlashCanvas.DoSAVEDC(EMFR: PEMRSAVEDC);
begin
  //
end;

procedure TFlashCanvas.DoPOLYPOLYLINE(EMFR: PEMRPOLYPOLYLINE);
 var dX, dY, i, J, eSt, eEn : integer;
     P0, P1: TPoint;
begin
  if DrawMode = dmPath then Exit;
   with EMFR^ do
    begin
      dY := Cardinal(@aPolyCounts);   // aPolyCounts
      dX:= dY + 4*nPolys;              // apts
      sh:=nil;
      for J:=0 to nPolys -1 do
      begin
        if J = 0 then eSt:=0
                 else eSt:=eEn+1;
        if J=nPolys-1 then eEn:=cptl-1
                       else eEn:=eSt+aPolyCounts[J]-1;

        P0 := MapPoint(AsmP(dX)[eSt]);
        if sh = nil then
          with MapPoint(AsmP(dX)[eSt+1]) do
             sh:=Owner.AddLine(P0.X, P0.Y, X, Y)
           else begin
              sh.Edges.MoveTo(P0.x, P0.y);
              with MapPoint(AsmP(dX)[eSt+1]) do
                sh.Edges.LineTo(X, Y);
            end;
        for I := eSt + 2 to eEn do
          begin
            P1 := MapPoint(AsmP(dX)[i]);
            sh.Edges.LineTo(P1.X, P1.Y);
          end;

        if (EMFR^.emr.iType = EMR_POLYPOLYGON) and ((P1.X <> P0.X) or (P1.Y <> P0.Y)) then
          sh.Edges.LineTo(P0.X, P0.Y);

      end;
        Sh.CalcBounds;

        ShapeSetStyle(true, EMFR^.emr.iType = EMR_POLYPOLYGON, Sh);
        ActiveSprite.PlaceObject(Sh, ActiveSprite.MaxDepth + 1);
        if EMFR^.emr.iType = EMR_POLYPOLYLINE then
          LastMoveToXY := MapPoint(AsmP(dX)[eEn]);
    end;
end;

procedure TFlashCanvas.DoPOLYBEZIER(EMFR: PEMRPOLYBEZIER);
var PLP: ALnP;
     i, j: integer;
     PBP: array[0..3] of TPoint;
begin
  if DrawMode = dmPath then Exit;
  with EMFR^ do
   begin
     PLP := @aptl;

     for J:=0 to (cptl div 3)-1 do
     begin
       for I := 0 to 3 do    // Iterate
       begin
         PBP[i] := MapPoint(PLP[i+3*j]);
       end;    // for
       sh:=Owner.AddCubicBezier(PBP[0], PBP[1], PBP[2], PBP[3]);
       Sh.CalcBounds;
       ShapeSetStyle(true, EMFR^.emr.iType = EMR_POLYBEZIER, Sh);
       ActiveSprite.PlaceObject(Sh, ActiveSprite.MaxDepth + 1);
     end;

   if (EMFR^.emr.iType = EMR_POLYBEZIER) and
     ((aptl[0].x <> PBP[cptl - 1].x) or (aptl[0].y <> PBP[cptl-1].y)) then
        sh.Edges.LineTo(aptl[0].x,aptl[0].y);
   end;
end;

procedure TFlashCanvas.DoPOLYBEZIERTO(EMFR: PEMRPOLYBEZIERTO);
begin
  DoPOLYBEZIER(EMFR);
end;

procedure TFlashCanvas.DoGRADIENTFILL(EMFR: PEnhMetaRecord);
 var Vr: FVer;
     il, i: integer;
begin
    WIth PEMGradientFill(EMFR)^ do
    begin
       sh:=Owner.AddRectangle(rclBounds);
       ShapeSetStyle(false, true, Sh);
       Vr:=@ver;
       i:=Vr[0].Green + (Vr[0].Red shr 8)+ (Vr[0].Blue shl 8) + $FF000000;
       il:=Vr[1].Green + (Vr[1].Red shr 8)+ (Vr[1].Blue shl 8) + $FF000000;
       if Boolean(ulMode) then sh.SetLinearGradient(recRGBA(il),recRGBA(i),90)
        else sh.SetLinearGradient(recRGBA(i), recRGBA(il), 0);

       ActiveSprite.PlaceObject(Sh, ActiveSprite.MaxDepth + 1);
    end;
end;

procedure TFlashCanvas.DoPOLYLINE16(EMFR: PEMRPOLYLINE16);
 var i: integer;
     PSP: ASmP;
     P0: TPoint;
     im: TFlashImage;
begin

   if DrawMode = dmPath then Exit;
   with EMFR^ do
    begin
      if cpts = 1 then
        begin
          LastMoveToXY := MapPoint(apts[0]);
          Exit;
        end;
      PSP := @apts;
      P0 := MapPoint(apts[0]);
      if (roUseBuffer in RenderOptions) and TObjMFRecord(ListMFRecords[CurrentRec-1]).FromRend then
      begin
        im := GetImageFromRender(rclBounds);
        sh := Owner.AddRectangle(rclBounds);
        sh.SetImageFill(Im, fmFit);
      end else
      begin
      with MapPoint(PSP[1]) do
        sh:=Owner.AddLine(P0.x, P0.y, x, y);
      for I := 2 to cpts - 1 do
        with MapPoint(PSP[i]) do
          sh.Edges.LineTo(x, y);

      Sh.CalcBounds;
      if (emr.iType = EMR_POLYGON16) and
        ((apts[0].x <> PSP[cpts - 1].x) or (apts[0].y <> PSP[cpts-1].y)) then
           sh.Edges.LineTo(P0.x, P0.y);

      ShapeSetStyle(true, (emr.iType = EMR_POLYGON16), Sh);
      if (emr.iType = EMR_POLYGON16) and (not Sh.Edges.isClockWise) and
        (sh.FillStyleRight > 0) then
        begin
         sh.FillStyleLeft := sh.FillStyleRight;
         sh.FillStyleRight := 0;
        end;
      end;

      with ActiveSprite.PlaceObject(Sh, ActiveSprite.MaxDepth + 1) do
       begin
       end;
      if emr.iType = EMR_POLYLINETO16 then
         LastMoveToXY := MapPoint(PSP[cpts - 1]);

    end;
end;

procedure TFlashCanvas.DoPOLYLINETO16(EMFR: PEMRPOLYLINETO16);
begin
  DoPOLYLINE16(EMFR);
end;

procedure TFlashCanvas.DoPOLYGON16(EMFR: PEMRPOLYGON16);
begin
  DoPOLYLINE16(EMFR);
end;

procedure TFlashCanvas.DoGDICOMMENT(EMFR: PEMRGDICOMMENT);
begin
end;

procedure TFlashCanvas.DoINTERSECTCLIPRECT(EMFR: PEMRINTERSECTCLIPRECT);
 var Sh: TFlashShape;
begin
 if ClippSprite <> nil then CloseActiveSprite;

 ClippSprite := AddActiveSprite(csClipp);

  with EMFR^ do
   Sh := Owner.AddRectangle(MapRect(rclClip));
  Sh.SetSolidColor(cswfBlack);
  ClipperSprite.PlaceObject(Sh, ClipperSprite.MaxDepth + 1);
end;

procedure TFlashCanvas.DoSETMETARGN(EMFR: PEMRSETMETARGN);
begin

end;

procedure TFlashCanvas.DoFRAMERGN(EMFR: PEMRFRAMERGN);
begin

end;

procedure TFlashCanvas.DoSCALEWINDOWEXTEX(EMFR: PEMRSCALEWINDOWEXTEX);
begin

end;

procedure TFlashCanvas.DoEXTCREATEFONTINDIRECTW(EMFR: PEMREXTCREATEFONTINDIRECT);
begin
 with EMFR^ do
  begin
    if HTables[ihFont] <> nil then HTables[ihFont].Free;
    HTables[ihFont] := TGDIHandleFont.Create(elfw);
    With TGDIHandleFont(HTables[ihFont]).Info.elfLogFont do
      begin
//        lfHeight := -MapLen(lfHeight, true);
//        if lfHeight < 0
//          then lfHeight := MapLen(lfHeight, true)
//          else lfHeight := -MulDiv(lfHeight, 72, GetDeviceCaps(BufferBMP.DC, LOGPIXELSY));
      end;
  end;
end;

procedure TFlashCanvas.DoSELECTCLIPPATH(EMFR: PEMRSELECTCLIPPATH);
 var path: TFlashShape;
begin
  if (EMFR^.iMode = RGN_COPY) and (ClippSprite <> nil) then CloseActiveSprite;
  if ClippSprite = nil then ClippSprite := AddActiveSprite(csClipp);

  if pathShape <> nil then
    begin
      path := GetPathShape;
      path.SetSolidColor(cswfBlack);
      ClipperSprite.PlaceObject(path, ClipperSprite.MaxDepth + 1);
    end;
end;

procedure TFlashCanvas.DoBEGINPATH(EMFR: PEMRBEGINPATH);
begin
  DrawMode := dmPath;
  pathShape := nil;
end;

procedure TFlashCanvas.DoENDPATH(EMFR: PEMRENDPATH);
  var nPoints, il, err, prevind, SummA: longint;
      PPoints: PPoint;
      PTypes: PByte;
      APoints: ALnP absolute PPoints;
      ATypes: Abytes absolute PTypes;
      Flag: byte;
      CLastPoint: TPoint;
 //     oldSC: TSWFSystemCoord;

  function SimpleAngle(X, Y: longint): double;
  begin
    if X = 0 then Result := 90 * Sign(Y) else
      if Y = 0 then Result := byte(X < 0) * 180 * Sign(X)
        else
        begin
          Result := RadToDeg(ArcTan(Y / X));
          if (X < 0) and (Y < 0) then Result := Result - 180 else
            if (X < 0) then Result := Result + 180;
        end;
  end;

  function CalcAngle(P1, P0, P2: TPoint): double;
  begin
    Result := SimpleAngle(P2.X - P0.X, P2.Y - P0.Y) - SimpleAngle(P0.X - P1.X, P0.Y - P1.Y);
    if Result < 0 then Result := 360 + Result;
  end;

  function SummAngle(ind: integer): double;
   var iind, iStep: longint;
       PPrev, PCur, PNext: TPoint;
  begin
    Result := 0;
    iind := ind + 1;
    PCur := APoints[ind];
    iStep := 1;
    while (iind <= nPoints) do
    begin
      if (iind = (nPoints - 1)) and (APoints[nPoints - 1].X = APoints[ind].X) and
         (APoints[nPoints - 1].Y = APoints[ind].Y) then inc(iind);

      if (iStep > 1) and ((PCur.X <> PNext.X) or (PCur.Y <> PNext.Y))  then
      begin
        PPrev := PCur;
        PCur := PNext;
      end;

      if iind = nPoints then PNext := APoints[ind]
      else
      case (ATypes[iind] and 6) of
       PT_MOVETO:
       begin
         PNext := APoints[ind];
         iind := nPoints;
       end;

       PT_LINETO:
         PNext := APoints[iind];

       PT_BEZIERTO:
         begin
           PNext := APoints[iind + 2];
           inc(iind, 2);
           if (iind = (nPoints - 1)) then
             with APoints[ind] do
               if (PNext.X = X) and (PNext.Y = Y) then inc(iind);
         end;
      end;

      if (istep > 1) and ((PCur.X <> PNext.X) or (PCur.Y <> PNext.Y)) then
        Result := Result + CalcAngle(PPrev, PCur, PNext);
      inc(iind);
      inc(istep);
    end;

    PPrev := PCur;
    PCur := PNext;
    PNext := APoints[ind+1];
    Result := Result + CalcAngle(PPrev, PCur, PNext);
  end;

begin
  DrawMode := dmNormal;
  nPoints := GetPath(BufferBMP.DC, APoints, ATypes, 0);
  GetMem(PPoints, SizeOf(TPoint)*nPoints);
  GetMem(PTypes, nPoints);
  err := GetPath(BufferBMP.DC, PPoints^, PTypes^, nPoints);
  if err <> nPoints then exit;
  il := 0;
  IsUsesPathShape := false;
  pathShape := Owner.AddShape;
  pathConturCount := 0;
  pathShape.Edges.OptimizeMode := true;
  prevind := 0;
//  oldSC := Owner.SystemCoord;
//  Owner.SystemCoord := scTwips;
  While il < nPoints do
   begin
     Flag := ATypes[il] and 6;
     Case Flag of
      PT_MOVETO:
        begin
          with MapPoint(APoints[il]), pathShape.Edges.MoveTo(X, Y) do
           if (PolyFillMode = WINDING) and (pathConturCount < 63) then
            begin
             if (il > 0) and ((pathShape.Edges.ListEdges.Count - prevind - 1) < 3) then
              begin
//                TSWFStyleChangeRecord(pathShape.Edges.ListEdges[prevind - 1]).Fill1Id := 0;
//                TSWFStyleChangeRecord(pathShape.Edges.ListEdges[prevind - 1]).StateFillStyle1 := false;
              end else
              begin
                inc(pathConturCount);
              end;
              if (il > 0) then
              begin
               SummA := Round(SummAngle(il));
               if EnableTransparentFill or (SummA = 360) or
                  ((SummA = 720) and (il = 4) or (il >= 100)) then
                 Fill1Id := pathConturCount;
              end;
            end;
          prevind := pathShape.Edges.ListEdges.Count;
        end;
      PT_LINETO:
        begin
          with MapPoint(APoints[il]) do
            pathShape.Edges.LineTo(X, Y);
        end;
      PT_BEZIERTO:
        begin
          if (il + 2) = nPoints then CLastPoint :=  MapPoint(APoints[0])
            else CLastPoint := MapPoint(APoints[il + 2]);
          pathShape.Edges.MakeCubicBezier(MapPoint(APoints[il]), MapPoint(APoints[il + 1]), CLastPoint);
          inc(il, 2);
        end;
     end;
     if boolean(ATypes[il] and 1) then  {close figure}
        pathShape.Edges.CloseShape;
     inc(il);
   end;

//  pathShape.Edges.CloseShape;
  pathShape.CalcBounds;
//  Owner.SystemCoord := oldSC;
  FreeMem(PPoints, SizeOf(TPoint)*nPoints);
  FreeMem(PTypes, nPoints);
end;

procedure TFlashCanvas.DoFILLPATH(EMFR: PEMRFILLPATH);
begin
  DoSTROKEANDFILLPATH(EMFR);
end;

procedure TFlashCanvas.DoSTROKEPATH(EMFR: PEMRSTROKEPATH);
begin
  DoSTROKEANDFILLPATH(EMFR);
end;

procedure TFlashCanvas.DoSTROKEANDFILLPATH(EMFR: PEMRSTROKEANDFILLPATH);
  var path, bgPath: TFlashShape;
      FS: TSWFFillStyle;
      B, il: byte;
      pathSP: TFlashSprite;

procedure SplitPath;
  var il: integer;
      tmpS: TFlashShape;
      oldSC: TSWFSystemCoord;

  procedure EndAndAddShape;
  begin
    if (tmpS.EdgesStore.Count < 2) or
       (TSWFShapeRecord(tmpS.EdgesStore[tmpS.EdgesStore.Count - 1]).ShapeRecType <> EndShapeRecord) then
      tmpS.Edges.EndEdges;
    tmpS.SetSolidColor(cswfWhite);
    pathSP.PlaceObject(tmpS, pathSP.MaxDepth + 1);
  end;

begin
  pathSP := Owner.AddSprite;
  tmpS := nil;
  oldSC := Owner.SystemCoord;
  Owner.SystemCoord := scTwips;
  for il := 0 to path.EdgesStore.Count - 1 do
  begin
    case TSWFShapeRecord(path.EdgesStore[il]).ShapeRecType of
      StyleChangeRecord:
        with TSWFStyleChangeRecord(path.EdgesStore[il]) do
        if StateMoveTo then
        begin
          if tmpS <> nil then EndAndAddShape;
          tmpS := Owner.AddShape();
          tmpS.Edges.MoveTo(X, Y);
        end;

      StraightEdgeRecord:
        with TSWFStraightEdgeRecord(path.EdgesStore[il]) do
          tmpS.Edges.LineDelta(X, Y);

      CurvedEdgeRecord:
        with TSWFCurvedEdgeRecord(path.EdgesStore[il]) do
          tmpS.Edges.CurveDelta(ControlX, ControlY, AnchorX, AnchorY);

      EndShapeRecord:
        EndAndAddShape;

    end;
  end;

  if TSWFShapeRecord(path.EdgesStore[path.EdgesStore.Count - 1]).ShapeRecType <> EndShapeRecord
    then EndAndAddShape;

  Owner.SystemCoord := oldSC;
end;

begin

 if pathShape <> nil then
   begin
     path := GetPathShape;
     if (EMFR^.emr.iType in [EMR_FILLPATH, EMR_STROKEANDFILLPATH])
       then path.Edges.CloseAllConturs;

     if {false and} EnableTransparentFill and (pathConturCount > 1) and
        (EMFR^.emr.iType in [EMR_FILLPATH, EMR_STROKEANDFILLPATH]) then
     begin
       Owner.SystemCoord := scTwips;
       bgPath := Owner.AddRectangle(path.Bounds.Rect);
       Owner.SystemCoord := scPix;
       ShapeSetStyle(false, true, bgPath);
       SplitPath;
//       Path.SetSolidColor(cswfWhite);
       ActiveSprite.PlaceObject(bgPath, pathSP, ActiveSprite.MaxDepth + 1);
     end else
     begin
       ShapeSetStyle(EMFR^.emr.iType in [EMR_STROKEPATH, EMR_STROKEANDFILLPATH],
                     EMFR^.emr.iType in [EMR_FILLPATH, EMR_STROKEANDFILLPATH], path);
     end;

     if (pathConturCount > 1) and (path.FillStyles.Count > 0) then
     begin
       for il := 1 to pathConturCount - 1 do
       begin
         if EMFR^.emr.iType in [EMR_FILLPATH, EMR_STROKEANDFILLPATH] then
         begin
           B := TSWFFillStyle(path.FillStyles.Items[0]).SWFFillType;
           case B of
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
           FS.Assign(TSWFFillStyle(path.FillStyles.Items[0]));
           path.FillStyles.Add(FS);
         end;
     end;
//         if (EMFR^.emr.iType in [EMR_STROKEPATH, EMR_STROKEANDFILLPATH]) and
//            (path.LineStyles.Count > 0) then
//         begin
//           LS := TSWFLineStyle.Create;
//           LS.Assign(TSWFLineStyle(path.LineStyles.Items[0]));
//           path.LineStyles.Add(LS);
//         end;
       end;
     IsUsesPathShape := true;
   end;
end;

procedure TFlashCanvas.DoCLOSEFIGURE(EMFR: PEMRCLOSEFIGURE);
begin
  if DrawMode = dmPath then Exit;

end;

procedure TFlashCanvas.DoFLATTENPATH(EMFR: PEMRFLATTENPATH);
begin
  if DrawMode = dmPath then Exit;
end;


procedure TFlashCanvas.DoPOLYTEXTOUTW(EMFR: PEMRPOLYTEXTOUT);
begin

end;

procedure TFlashCanvas.DoEXTCREATEPEN(EMFR: PEMREXTCREATEPEN);
begin
  with EMFR^ do
   begin
     if HTables[ihPen] <> nil then HTables[ihPen].Free;
     HTables[ihPen] := TGDIHandlePen.Create(elp);
     with TGDIHandlePen(HTables[ihPen]).Info do
       begin
         lopnWidth.X := MapLen(lopnWidth.X, false);
         lopnWidth.Y := MapLen(lopnWidth.Y, true);
       end;
   end;
end;

procedure TFlashCanvas.DoCREATEDIBPATTERNBRUSHPT(EMFR: PEMRCREATEDIBPATTERNBRUSHPT);
begin
 with EMFR^ do
  begin
     if HTables[ihBrush] <> nil then HTables[ihBrush].Free;
     HTables[ihBrush] := TGDIHandleDibBrush.Create(Cardinal(EMFR));
  end;
end;

procedure TFlashCanvas.DoCREATEMONOBRUSH(EMFR: PEMRCREATEMONOBRUSH);
begin
 with EMFR^ do
  begin
    if HTables[ihBrush] <> nil then HTables[ihBrush].Free;
    HTables[ihBrush] := TGDIHandleMonoBrush.Create(Cardinal(EMFR));
  end;

end;

procedure TFlashCanvas.DoEXTSELECTCLIPRGN(EMFR: PEMREXTSELECTCLIPRGN);
 var il: integer;
     RGN: PRgnData;
     R: PRect;
     Sh: TFlashShape;
begin
  if (ClippSprite <> nil) then CloseActiveSprite;
  if EMFR^.cbRgnData > 0 then
    begin
     RGN := @(EMFR^.RgnData);
     With RGN^.rdh, rcBound do
       begin
        if (nCount = 0) and (ClippSprite <> nil) then CloseActiveSprite
          else
          begin
            ClippSprite := AddActiveSprite(csClipp);
            R := @(RGN^.Buffer);
            for il := 0 to nCount - 1 do
              begin
                 Sh := Owner.AddRectangle(MapRect(R^)); {MapX(R^.Left), MapY(R^.Top), MapX(R^.Right), MapY(R^.Bottom)}
                 Sh.SetSolidColor(cswfBlack);
                 ClipperSprite.PlaceObject(Sh, ClipperSprite.MaxDepth + 1);
                 Inc(R);
              end;
          end;
       end;
    end;
end;

procedure TFlashCanvas.DoINVERTRGN(EMFR: PEMRINVERTRGN);
begin

end;

procedure TFlashCanvas.DoSETTEXTCOLOR(EMFR: PEMRSETTEXTCOLOR);
begin
  TextColor := EMFR^.crColor;
end;

procedure TFlashCanvas.DoSETMAPPERFLAGS(EMFR: PEMRSETMAPPERFLAGS);
begin

end;

procedure TFlashCanvas.DoDRAWESCAPE(EMFR: PEnhMetaRecord);
begin

end;

procedure TFlashCanvas.DoPIE(EMFR: PEMRPIE);
 var dX, dY, eSt, eEn: integer;
     R2: TRect;
begin

  if DrawMode = dmPath then Exit;
  with EMFR^ do
   begin
     if ClockWs then
     begin
       dX := ptlStart.X;
       dY := ptlStart.Y;
       ptlStart := ptlEnd;
       ptlEnd.X:= dX;
       ptlEnd.Y:= dY;
     end;

     Sh:=Owner.AddShape;
//     Sh.Edges.IgnoreMovieSettings:=True;

     R2 := MapRect(rclBox);

     dX := MapLen((rclBox.Right-rclBox.Left) div 2, false);
     dY := MapLen((rclBox.Bottom-rclBox.Top) div 2, true);
     with MapPoint(ptlStart) do
       eSt := Ceil(RadToDeg(ArcTan2((R2.Top+dY) - Y, X - (R2.Left+dX))));
     with MapPoint(ptlEnd) do
       eEn := Ceil(RadToDeg(ArcTan2((R2.Top+dY) - Y, X - (R2.Left+dX))));

     with MapPoint(rclBox.TopLeft) do
      Sh.Edges.MoveTo(X + dX, Y + dY);

     Sh.Edges.MakePie(dX, dY, eSt, eEn, ClockWs);

     Sh.CalcBounds;
     ShapeSetStyle(true, true, Sh);
     ActiveSprite.PlaceObject(Sh, ActiveSprite.MaxDepth + 1);

//     Sh.Edges.IgnoreMovieSettings:=False;
   end;
end;


procedure TFlashCanvas.DoTRANSPARENTBLT(EMFR: PEMRTRANSPARENTBLT);
begin

end;

procedure TFlashCanvas.DoABORTPATH(EMFR: PEMRABORTPATH);
begin
  DrawMode := dmNormal;
  pathShape := nil;
end;

procedure TFlashCanvas.DoARC(EMFR: PEMRARC);
 var R2: TRect;
     dX, dY, eSt, eEn: integer;
begin
  if DrawMode = dmPath then exit;
  with EMFR^ do
   begin
     if ClockWs then
     begin
       dX:=ptlStart.X;
       dY:=ptlStart.Y;
       ptlStart:=ptlEnd;
       ptlEnd.X:=dX;
       ptlEnd.Y:=dY;
     end;

     R2 := MapRect(rclBox);
     dX := MapLen((rclBox.Right-rclBox.Left) div 2, false);
     dY := MapLen((rclBox.Bottom-rclBox.Top) div 2, true);
     if (dx = 0) or (dy = 0) then exit;
     
     with MapPoint(ptlStart) do
       eSt := Ceil(RadToDeg(ArcTan2((R2.Top+dY) - Y, X - (R2.Left+dX))));
     with MapPoint(ptlEnd) do
       eEn := Ceil(RadToDeg(ArcTan2((R2.Top+dY) - Y, X - (R2.Left+dX))));

     Sh:=Owner.AddShape;
     sh.Edges.MakeArc(R2.Left+dX, R2.Top+dY, dX, dY, eSt, eEn, false, false);

     ShapeSetStyle(true, false, Sh);
     Sh.CalcBounds;
     ActiveSprite.PlaceObject(Sh, ActiveSprite.MaxDepth + 1);

     if EMFR^.emr.iType = EMR_ARCTO then
        LastMoveToXY := Sh.Edges.FCurrentPos;
   end;
end;

procedure TFlashCanvas.DoARCTO(EMFR: PEMRARCTO);
begin
  DoArc(EMFR);
end;

procedure TFlashCanvas.DoSETLINKEDUFIS(EMFR: PEnhMetaRecord);
begin

end;

procedure TFlashCanvas.DoPAINTRGN(EMFR: PEMRPAINTRGN);
begin

end;

procedure TFlashCanvas.DoOFFSETCLIPRGN(EMFR: PEMROFFSETCLIPRGN);
begin

end;

procedure TFlashCanvas.DoSTARTDOC(EMFR: PEnhMetaRecord);
begin

end;

procedure TFlashCanvas.DoCREATEPEN(EMFR: PEMRCREATEPEN);
begin
  with EMFR^ do
   begin
     if HTables[ihPen] <> nil then HTables[ihPen].Free;
     HTables[ihPen] := TGDIHandlePen.Create(lopn);
     with TGDIHandlePen(HTables[ihPen]).Info do
       begin
         lopnWidth.X := MapLen(lopnWidth.X, false);
         lopnWidth.Y := MapLen(lopnWidth.Y, true);
       end;
   end;
end;

procedure TFlashCanvas.DoSETCOLORADJUSTMENT(EMFR: PEMRSETCOLORADJUSTMENT);
begin

end;

procedure TFlashCanvas.DoNAMEDESCAPE(EMFR: PEnhMetaRecord);
begin

end;

procedure TFlashCanvas.DoSETARCDIRECTION(EMFR: PEMRSETARCDIRECTION);
// var W: TX
begin
  ClockWs := boolean(EMFR^.iArcDirection-1);
  GetWorldTransform(BufferBMP.DC, FCWorldTransform);
  if FCWorldTransform.eM22 < 0 then ClockWs := not ClockWs;
end;

procedure TFlashCanvas.DoSETPALETTEENTRIES(EMFR: PEMRSETPALETTEENTRIES);
begin

end;

procedure TFlashCanvas.DoSETROP2(EMFR: PEMRSETROP2);
begin

end;

procedure TFlashCanvas.Clear;
begin
  //owner.Clear;
  FRootSprite := nil;
end;

procedure TFlashCanvas.CloseHandle;
begin
  MetaHandle := CloseEnhMetaFile(Handle);
  Handle := 0;
end;

procedure TFlashCanvas.InitHandle;
var
  TmpDC, WinDC: HDC;
  R: TRect;
  il: integer;
begin
  DeleteEnhMetaFile(MetaHandle);

  WinDC := GetDC(0);
  TmpDC := CreateCompatibleDC(WinDC);

//  DPI := GetDeviceCaps(TmpDC, LOGPIXELSX);
  DPI := 96;
  if Owner = nil then
    SetRect(R, 0, 0, Round(GetSystemMetrics(SM_CXSCREEN)/dpi * 2540),
                     Round(GetSystemMetrics(SM_CYSCREEN)/dpi * 2540))
    else
    SetRect(R, 0, 0, Round(Owner.SWFHeader.MovieRect.Right/dpi*127),
                     Round(Owner.SWFHeader.MovieRect.Bottom/dpi*127));  {127 = 2540 / 20}
  Handle := CreateEnhMetafile(TmpDC, nil, @R, nil);
  DeleteDC (TmpDC);
  ReleaseDC(0, WinDC);

  FCworldTransform.eM11 := 1;
  FCworldTransform.eM22 := 1;
  PrivateTransform := FCWorldTransform;
  ClippSprite := nil;
  FActiveSprite := nil;
  PrevFont := nil;

  FillChar(ViewportExt, sizeOf(TRect), 0);
  hasInitViewport := false;
  FillChar(WindowExt, sizeOf(TRect), 0);
  hasInitWindow := false;

  TextAlign:=0;
  SetIgnoreMovieSettingsFlag:=False;
  CurrentPen := -1;
  CurrentBrush := -1;
  CurrentFont := -1;
  LastMoveToXY := Point(0, 0);
  BgTransparent := false;
  EnableTransparentFill := false;
  
  for il := 0 to HTables.Count - 1 do
   if HTables[il] <> nil then HTables[il].Free;
  HTables.Clear;
end;

procedure TFlashCanvas.StretchDraw(const R: TRect; Graphic: TGraphic);
begin
 if Graphic is TMetaFile then
  begin
    DrawMetafile(R, TMetaFile(Graphic), true);
  end else
  inherited ;
// RootScaleX := (R.Right-R.Left)/Graphic.Width;
// RootScaleY := (R.Bottom-R.Top)/Graphic.Height;
// Draw(r.Left, r.Top, Graphic);
end;

procedure TFlashCanvas.DrawMetafile(Dest: TRect; MF: TMetafile; stretch: boolean);
var
  MHeader: EnhMetaHeader;
  TMPStream: TMemoryStream;
  TMPMetafile: TMetaFile;
  MHandle: THandle;

  procedure CalcScaleXY;
  begin
    GetEnhMetaFileHeader(MHandle, Sizeof(MHeader), @MHeader);
    with MHeader do
     MetafileRect := Rect(MulDiv( rclFrame.Left, szlDevice.cx, szlMillimeters.cx * 100),
                          MulDiv( rclFrame.Top, szlDevice.cy, szlMillimeters.cy * 100),
                          MulDiv( rclFrame.Right, szlDevice.cx, szlMillimeters.cx * 100),
                          MulDiv( rclFrame.Bottom, szlDevice.cy, szlMillimeters.cy * 100));
    RootScaleX := RootScaleX*(Dest.Right-Dest.Left)/(MF.Width);
    RootScaleY := RootScaleY*(Dest.Bottom-Dest.Top)/(MF.Height);
  end;

begin
  Finished;

  InitHandle;

//  GetEnhMetaFileHeader(MF.Handle, SizeOf(MHeader), @MHeader);

  if MF.Enhanced then
   begin
     MHandle := MF.Handle;
     TMPMetafile := nil;
     RootScaleX := 1;
     RootScaleY := 1;
   end else
   begin
     TMPStream := TMemoryStream.Create;
     MF.Enhanced := true;
     MF.SaveToStream(TMPStream);

     TMPMetafile := TMetaFile.Create;
     TMPStream.Position := 0;
     TMPMetafile.LoadFromStream(TMPStream);
//     TMPMetafile.SaveToFile('kvart.emf');
     TMPStream.Free;
     MHandle := TMPMetafile.Handle;
     RootScaleX := (MF.Width) / (TMPMetafile.Width);
     RootScaleY := (MF.Height) /(TMPMetafile.Height);
     MF.Enhanced := false;
   end;

  MakeListMFRecords(MHandle, Rect(0, 0, Dest.Right-Dest.Left, Dest.Bottom-Dest.Top));

  if not IsEmptyMetafile then
   begin


     if stretch and (not ((roUseBuffer in RenderOptions) and isNeedBuffer{(MHandle)}))
       then CalcScaleXY;

     ProcessingRecords(MHandle, Dest.Right-Dest.Left, Dest.Bottom-Dest.Top, stretch);

     if stretch and (roUseBuffer in RenderOptions) and (roHiQualityBuffer in RenderOptions)
      and UseBMPRender
       then CalcScaleXY;

     With MetafileSprite.PlaceParam do
       begin
         SetTranslate(Dest.Left, Dest.Top);
         if ((RootScaleX <> 1) or (RootScaleY <> 1)) and not StretchedBMPRender then
           SetScale(RootScaleX, RootScaleY);
       end;
   end;

  if TMPMetafile <> nil then TMPMetafile.Free;

  with owner do
    MoveResource(CurrentFrameNum, CurrentFrameNum, CurrentFrameNum);
end;

procedure TFlashCanvas.Draw(X, Y: Integer; Graphic: TGraphic);
begin
 if Graphic is TMetaFile then
  begin
    DrawMetafile(Rect(X, Y, 0, 0), TMetaFile(Graphic), false);
  end else
  inherited ;
end;

procedure TFlashCanvas.Finished;
 var nBits: integer;
begin
  CloseHandle;
  nBits := GetEnhMetaFileBits(MetaHandle, 0, nil);
  if (nBits > 0) and (not IsEmptyMetafile(MetaHandle)) then
    begin
      FActiveSprite := nil;
      RootScaleX := 1;
      RootScaleY := 1;
      MakeListMFRecords(MetaHandle, Rect(0,0,0,0));
      ProcessingRecords(MetaHandle, 0, 0, false);
    end;
end;

function TFlashCanvas.Place(depth: word; clear: boolean = true; dest: TFlashSprite = nil): TFlashPlaceObject;
begin
  Finished;
  Result := nil;
  if FRootSprite <> nil then
   begin
    RootSprite.ShowFrame;

    if dest <> nil
      then Result := dest.PlaceObject(RootSprite, Depth)
      else Result := Owner.PlaceObject(RootSprite, Depth);
   end;

  InitHandle;
  if clear then FRootSprite := nil;
end;

procedure TFlashCanvas.SetWTransform(xForm: TxForm; Flag: word);
begin
  CopyMemory(@FCWorldTransform, @PrivateTransform, Sizeof(PrivateTransform));

  case Flag of
     0: FCWorldTransform := xForm;
     MWT_IDENTITY:
        begin
          FillChar(FCWorldTransform, 0, SizeOf(FCWorldTransform));
          FCWorldTransform.eM11 := 1;
          FCWorldTransform.eM21 := 1;
        end;
     MWT_LEFTMULTIPLY:
        CombineTransform(FCWorldTransform, XForm, FCWorldTransform);
     MWT_RIGHTMULTIPLY:
        CombineTransform(FCWorldTransform, FCWorldTransform, XForm);
  end;

  CopyMemory(@PrivateTransform, @FCWorldTransform, Sizeof(PrivateTransform));
end;

procedure TFlashCanvas.ReInitViewPort;
 var P: TPoint;
     S: TSize;
begin
//  Exit;
  if hasInitViewportOrg then
    begin
     GetViewportOrgEx(BufferBMP.DC, P);
     ViewportExt.TopLeft := P;
    end;
  if hasInitViewportOrg then
    begin
     GetViewportExtEx(BufferBMP.DC, S);
     ViewportExt.BottomRight := Point(S.cx, S.cy);
    end;
  if hasInitWindowOrg then
    begin
     GetWindowOrgEx(BufferBMP.DC, P);
     WindowExt.TopLeft := P;
    end;
  if hasInitWindow then
    begin
     GetWindowExtEx(BufferBMP.DC, S);
     WindowExt.BottomRight := Point(S.cx, S.cy);
   end;
end;


function TFlashCanvas.MapPoint(P: TPoint): TPoint;
begin
  Result := P;
  LPToDP(BufferBMP.DC, Result, 1);
end;

function TFlashCanvas.MapPoint(P: TSmallPoint): TPoint;
begin
  Result := MapPoint(Point(P.X, P.Y));
end;


function TFlashCanvas.MapRect(R: TRect): TRect;
begin
  Result := R;
  LPToDP(BufferBMP.DC, Result, 2);
end;

function TFlashCanvas.MapLen(L: integer; Vert: boolean): longint;
 var R: TRect;
begin
  if Vert then R := Rect(0, 0, 0, L)
    else R := Rect(0, 0, L, 0);

  LPToDP(BufferBMP.DC, R, 2);

  if Vert then Result := R.Bottom - R.Top
    else Result := R.Right - R.Left;
end;


procedure TFlashCanvas.ShapeSetStyle(ShowOutLine, ShowFill: boolean; fsh: TFlashShape = nil);
  var il, icol: integer;
      I: Integer;
      OISize: integer;
      H, OldBrush, NewBrush, OldPen: HGDIOBJ;
//      LP: TLogPen;
//      ELP: TExtLogPen;
      tmpLB: TLogBrush;
      Bm: TBITMAPINFOHEADER;
      Mem2Im: TFlashImage;
      MStream: TMemoryStream;
      Im: TFlashImage;
      tmpColor: longint;
      DibBrush: TGDIHandleDibBrush;
      MonoBrush: TGDIHandleMonoBrush;
      ROP2: DWord;

 function GetGradientAlpha: integer;
  var ix, iy: integer;
      BMP: TBMPReader;
 begin
   BMP := TBMPReader.Create;
   with DibBrush do
   begin
     Info.Position := 0;
     BMP.LoadFromStream(Info);
   end;
   Result := 0;
   for iy := 0 to 7 do
     for ix := 0 to 7 do
       if BMP.PixelsB[iy, ix] = 1  then Inc(Result);
   Result := 255 - Round(Result/64*255);
   BMP.Free;
 end;


begin
  if fsh = nil then fsh := Sh;

  if ShowFill then
   begin
     Im := nil;
     if CurrentBrush > 0 then
       begin
        if CurrentBrush < HTables.Count then
        Case TGDIHandleInfo(HTables[CurrentBrush]).HandleType of
         htBrush:
           with TGDIHandleBrush(HTables[CurrentBrush]), Info do
            case lbStyle of
              BS_NULL: ;
              BS_SOLID: fSh.SetSolidColor(SWFRGB(lbColor));
              BS_HATCHED:
               begin
                 tmpLB := Info;
                 tmpLB.lbColor := $FFFFFF;
                 NewBrush := CreateBrushIndirect(tmpLB);
                 Im := Owner.AddImage;
                 with Im.BMPStorage do
                  begin
                   SetSize(8, 8, 1);
                   SetBkColor(DC, $0);
                   OldBrush := SelectObject(DC, NewBrush);
                   OldPen := SelectObject(DC, GetStockObject(NULL_PEN));
                   windows.Rectangle(DC, 0, 0, 9, 9);
                   Colors[0] := TFColorA(SWFRGBA((BgColor and $FF0000) shr 16,
                                                 (BgColor and $FF00) shr 8,
                                                  BgColor and $FF, $ff));
                   Colors[1] := TFColorA(SWFRGBA((lbColor and $FF0000) shr 16,
                                                 (lbColor and $FF00) shr 8,
                                                  lbColor and $FF, $ff));
                   DeleteObject(SelectObject(DC, OldBrush));
                   SelectObject(DC, OldPen);
                   Im.GetBMPInfo;
                   if BgTransparent then Im.SetAlphaIndex(0, 0);
                  end;

               end else
               begin
                 NewBrush := CreateBrushIndirect(Info);
                 Im := Owner.AddImage;
                 with Im.BMPStorage do
                  begin
                   SetSize(8, 8, 24);
                   SetBkColor(DC, BgColor);
                   OldBrush := SelectObject(DC, NewBrush);
                   OldPen := SelectObject(DC, GetStockObject(NULL_PEN));
                   windows.Rectangle(DC, 0, 0, 9, 9);
                   DeleteObject(SelectObject(DC, OldBrush));
                   SelectObject(DC, OldPen);
                   Im.GetBMPInfo;
                  end;
               end;
            end;

         htMonoBrush:
           begin
             MonoBrush := TGDIHandleMonoBrush(HTables[CurrentBrush]);
             if MonoBrush.Img <> nil then Im := MonoBrush.Img
               else
               begin
                 Im := Owner.AddImage;
                 Im.LoadDataFromStream(MonoBrush.Info);
                 if not bgTransparent then
                   Im.HasUseAlpha := false;// TransparentIndex := -1;
                 tmpColor := GetBkColor(BufferBMP.DC);
                 with im.BMPStorage.Colors[0] do
                  begin
                   R := GetRValue(tmpColor);
                   G := GetGValue(tmpColor);
                   B := GetBValue(tmpColor);
                  end;
                 tmpColor := GetTextColor(BufferBMP.DC);
                 with im.BMPStorage.Colors[1] do
                  begin
                   R := GetRValue(tmpColor);
                   G := GetGValue(tmpColor);
                   B := GetBValue(tmpColor);
                  end;
                 MonoBrush.Img := Im;
               end;
           end;

         htDibBrush:
           begin
             DibBrush := TGDIHandleDibBrush(HTables[CurrentBrush]);
             if isEMFPlus and (roOptimization in RenderOptions) and EnableTransparentFill then
             begin
               tmpColor := $FFFFFF;
                    if (PreviusBrush > 0) and (HTables[PreviusBrush] is TGDIHandleBrush) then
                       tmpColor := TGDIHandleBrush(HTables[PreviusBrush]).Info.lbColor;
               fSh.SetSolidColor(SWFRGBA(tmpColor, GetGradientAlpha));
             end else
             begin
               with DibBrush do
               if Img <> nil then Im := Img
                 else
                 begin
                   Im := Owner.AddImage;
                   Info.Position := 0;
                   Im.LoadDataFromStream(Info);
                 end;
             if DibBrush.Img = nil then
               case Im.BMPStorage.Bpp of
                 1: begin
                    if (PreviusBrush > 0) and (HTables[PreviusBrush] is TGDIHandleBrush) then
                       tmpColor := TGDIHandleBrush(HTables[PreviusBrush]).Info.lbColor;
                    ROP2 := GetRop2(BufferBMP.DC);
                    for icol:= 0 to Im.ColorCount - 1 do
                     with Im.BMPStorage.Colors[icol] do
                      case ROP2 of
                       R2_MASKPEN:
                         if (R = 0) and (G = 0) and (B = 0) then
                           begin
                             R := {255 -} GetRValue(tmpColor);
                             G := {255 -} GetGValue(tmpColor);
                             B := {255 -} GetBValue(tmpColor);
                           end else
                         if (R = $FF) and (G = $FF) and (B = $FF) then
                            Im.SetAlphaIndex(icol, 0);
                       R2_COPYPEN:
  //                       if (R = 0) and (G = 0) and (B = 0) then
  //                         begin
  //                           R := {255 -} GetRValue(tmpColor);
  //                           G := {255 -} GetGValue(tmpColor);
  //                           B := {255 -} GetBValue(tmpColor);
  //                         end else
                         if (R = $FF) and (G = $FF) and (B = $FF) then
                            Im.SetAlphaIndex(icol, 0);
                      end;
                    end;
                 32: FillAlpha(Im.BMPStorage, 255);
               end;
               DibBrush.Img := Im;
             end;
           end;
        end;
       end else
       begin
         tmpColor := -1;
         case Abs(CurrentBrush) of
           WHITE_BRUSH:  tmpColor := $FFFFFF;
           LTGRAY_BRUSH: tmpColor := $C0C0C0;
           GRAY_BRUSH:   tmpColor := $808080;
           DKGRAY_BRUSH: tmpColor := $404040;
           BLACK_BRUSH:  tmpColor := $000000;
           NULL_BRUSH:   ;
         end;
         if tmpColor > -1 then fSh.SetSolidColor(SWFRGB(tmpColor));
       end;

     if Im <> nil then
       begin
        fSh.SetImageFill(Im, fmTile, 1/RootScaleX, 1/RootScaleY);// {20/}CWorldTransform.eM11, {20/}CWorldTransform.eM22);
       end;
   end;

 if ShowOutLine  then
  begin
   if CurrentPen >= 0 then
   with TGDIHandlePen(HTables[CurrentPen]) do
    begin
     // if Info.lopnWidth.X > 0 then
      case Info.lopnStyle of
        PS_NULL: begin
           fsh.HasExtLineStyle := False;
           fsh.FExtLineStyle := nil;
         end;
        PS_SOLID: begin
//           fsh.HasExtLineStyle:=False;  fsh.FExtLineStyle:=nil;
//           if Info.lopnWidth.X > 0 then
             fSh.SetLineStyle(Info.lopnWidth.X, SWFRGB(TColor(Info.lopnColor)));
         end;
        PS_DASH:    //        = 1;      { ------- }
        with fsh do
          begin
            HasExtLineStyle:=True;
            ExtLineStyle.Count := 2;
            ExtLineStyle[0]:= 18; ExtLineStyle[1] := 6;
            SetLineStyle(Info.lopnWidth.X, SWFRGB(TColor(Info.lopnColor)));
          end;
        PS_DOT:      //         = 2;      { ....... }
        with fsh do
          begin
            HasExtLineStyle:=True;
            ExtLineStyle.Count := 2;
            ExtLineStyle[0]:= 3; ExtLineStyle[1] := 3;
            SetLineStyle(Info.lopnWidth.X, SWFRGB(TColor(Info.lopnColor)));
          end;
        PS_DASHDOT:  //         = 3;      { _._._._ }
        with fsh do
          begin
            HasExtLineStyle:=True;
            ExtLineStyle.Count := 4;
            ExtLineStyle[0]:=9; ExtLineStyle[1] := 6;
            ExtLineStyle[2]:=3; ExtLineStyle[3] := 6;
            SetLineStyle(Info.lopnWidth.X, SWFRGB(TColor(Info.lopnColor)));
          end;
        PS_DASHDOTDOT: //      = 4;      { _.._.._ }
        with fsh do
          begin
            HasExtLineStyle:=True;
            ExtLineStyle.Count := 6;
            ExtLineStyle[0]:=9; ExtLineStyle[1] := 3;
            ExtLineStyle[2]:=3; ExtLineStyle[3] := 3;
            ExtLineStyle[4]:=3; ExtLineStyle[5] := 3;
            SetLineStyle(Info.lopnWidth.X, SWFRGB(TColor(Info.lopnColor)));
          end;
      end;
      if fSh.HasExtLineStyle then
        begin
          fSh.ExtLineTransparent := BgTransparent;
          if not BgTransparent then fSh.LineBgColor.RGB := SWFRGB(BgColor);
        end;
    end else
    begin
      Case Abs(CurrentPen) of
       WHITE_PEN: fSh.SetLineStyle(1, SWFRGB($FFFFFF));
       BLACK_PEN: fSh.SetLineStyle(1, SWFRGB($0));
       NULL_PEN: ;
      end;
    end;
  end;
end;

function TFlashCanvas.GetActiveSprite: TFSpriteCanvas;
begin
  if FActiveSprite = nil then
      FActiveSprite := AddActiveSprite(csMetaFile);
  Result := FActiveSprite;
end;

function TFlashCanvas.AddActiveSprite(ftype: TSpriteManagerType): TFSpriteCanvas;
begin
  Result := TFSpriteCanvas.Create(Owner);
  owner.AddFlashObject(Result);
  Result.FType := ftype;
  Result.CharacterId := Owner.CurrentObjID;
  inc(Owner.FCurrentObjID);

  if ftype = csMetaFile then
   begin
    Result.Parent := nil;
    Result.PlaceParam := RootSprite.PlaceObject(Result, RootSprite.MaxDepth + 1);
   end else
  if FActiveSprite <> nil then
    begin
      Result.Parent := ActiveSprite;
      Result.PlaceParam := ActiveSprite.PlaceObject(Result, ActiveSprite.MaxDepth + 1);
    end;

  if ftype = csClipp then
    begin
     ClipperSprite := Owner.AddSprite;
     Result.PlaceObject(ClipperSprite, 1).ClipDepth := 2;
     FActiveSprite := Result;
     ClippedSprite := AddActiveSprite(csDefault);
     FActiveSprite := ClippedSprite;
    end;
  if ftype = csWorldTransform then HasWorldTransform := true;
end;

procedure TFlashCanvas.CloseActiveSprite;
begin                                                       
if FActiveSprite = nil then Exit;
if FActiveSprite.FType = csWorldTransform then HasWorldTransform := false else
if (FActiveSprite.FType = csDefault) and
   (FActiveSprite.Parent <> nil) and (FActiveSprite.Parent.FType = csClipp)
   then
   begin
     FActiveSprite := ActiveSprite.Parent.Parent;
     ClippSprite := nil;
     ClipperSprite := nil;
   end
   else
     FActiveSprite := ActiveSprite.Parent;
end;

function TFlashCanvas.GetPathShape: TFlashShape;
begin
  if pathShape = nil then Result := nil
    else
    begin
      if IsUsesPathShape then
       begin
         Result := Owner.AddShape;
         Result.Assign(pathShape);
         Result.LineStyles.Clear;
         Result.FillStyles.Clear;
       end else Result := pathShape;
    end;
end;

function TFlashCanvas.GetRootSprite: TFlashSprite;
begin
 if FRootSprite = nil then
   begin
     FRootSprite := Owner.AddSprite;
   end;
 Result := FRootSprite;
end;

procedure TFlashCanvas.GetMetrixFont(F: TFont);
var
  FontDC, OldFont, DC: HDC;
  Size, OldFontHeight, tmpSize: integer;
  TmpTextMetric: POutlineTextmetricW;
  tmpLogFont: TLogFont;
  x_Size: TSize;
begin
  FillChar(LogFontInfo, sizeof(LogFontInfo), 0);
{..$DEFINE Release205}
{$IFDEF Release205}
  if CurrentFont < 0 then
   begin
     FontDC := GetStockObject(Abs(CurrentFont));
     GetObject(FontDC, sizeof(LogFontInfo), @LogFontInfo);
   end else
   with LogFontInfo, TGDIHandleFont(HTables[CurrentFont]).Info do
    begin
      lfHeight         := elfLogFont.lfHeight;
      lfWidth          := 0;
      lfEscapement     := elfLogFont.lfEscapement;
      lfOrientation    := elfLogFont.lfOrientation;
      lfWeight         := elfLogFont.lfWeight;
      if lfWeight = -1 then lfWeight := 400; // fixed bug metafile
      lfItalic         := Byte(elfLogFont.lfItalic>0);
      lfUnderline      := Byte(elfLogFont.lfUnderline>0);
      lfStrikeOut      := Byte(elfLogFont.lfStrikeOut>0);
      lfCharSet        := elfLogFont.lfCharSet;
      lfOutPrecision   := elfLogFont.lfOutPrecision;
      lfClipPrecision  := elfLogFont.lfClipPrecision;
      lfQuality        := elfLogFont.lfQuality;
      lfPitchAndFamily := elfLogFont.lfPitchAndFamily;
      StrPcopy(lfFaceName, WideCharToString(elfLogFont.lfFaceName));
      FontDC := CreateFontIndirect(LogFontInfo);
      lfWidth          := Abs(elfLogFont.lfWidth);
    end;

  F.Handle := FontDC;

  DC:=GetDC(0);
  OldFont := SelectObject(DC, FontDC);

  Size := GetOutlineTextMetricsW(DC, 0, nil);
  if Size <> FTextMetricSize then
    begin
      if FTextMetricSize > 0 then FreeMem(FTextMetric, FTextMetricSize);
      FTextMetricSize := Size;
      GetMem(FTextMetric, FTextMetricSize);
    end;
  GetOutlineTextMetricsW(DC, FTextMetricSize, FTextMetric);
//  GetTextMetricsW(DC, FTextMetric);
  GetObject(GetCurrentObject(DC,OBJ_FONT),SizeOf(LogFontInfo),@LogFontInfo);

  if CurrentFont >= 0 then
   with LogFontInfo, TGDIHandleFont(HTables[CurrentFont]).Info do
    begin
      lfWidth := Abs(elfLogFont.lfWidth);
    end;

  SelectObject(DC, OldFont);
  DeleteObject(FontDC);
  ReleaseDC(0, DC);
{$ELSE}
//
  DC := GetDC(0);
  OldFont := GetCurrentObject(BufferBMP.DC, OBJ_FONT);
  GetObject(OldFont, SizeOf(LogFontInfo), @LogFontInfo);
  tmpLogFont := LogFontInfo;

  with LogFontInfo do
  begin
    lfItalic := Byte(lfItalic > 0);
    lfUnderline := Byte(lfUnderline>0);
    lfStrikeOut := Byte(lfStrikeOut>0);
    OldFontHeight := lfHeight;
    if lfHeight < 0
      then
        lfHeight := - MapLen(Abs(lfHeight), true)
      else
        lfHeight := - Abs(MulDiv(MapLen(lfHeight, true), 72, GetDeviceCaps(DC, LOGPIXELSY)));
    if (lfOutPrecision and $F) in [OUT_STRING_PRECIS, OUT_RASTER_PRECIS] then
      lfOutPrecision := lfOutPrecision and $F0 + OUT_TT_PRECIS;
  end;

  tmpSize := 0;
  if LogFontInfo.lfWidth <> 0 then
  begin
    tmpLogFont.lfWidth := 0;
    FontDC := CreateFontIndirect(tmpLogFont);
    OldFont := SelectObject(DC, FontDC);
    tmpSize := GetOutlineTextMetricsW(DC, 0, nil);
    GetMem(TmpTextMetric, tmpSize);
    GetOutlineTextMetricsW(DC, tmpSize, TmpTextMetric);
    FontScale := Abs(LogFontInfo.lfWidth) / TmpTextMetric.otmTextMetrics.tmAveCharWidth;
    FreeMem(TmpTextMetric, tmpSize);
    DeleteObject(SelectObject(DC, OldFont));
  end
  else FontScale := 1;

  FontDC := CreateFontIndirect(LogFontInfo);
  F.Handle := FontDC;

  OldFont := SelectObject(DC, FontDC);

  Size := GetOutlineTextMetricsW(DC, 0, nil);
  if Size <> FTextMetricSize then
    begin
      if FTextMetricSize > 0 then FreeMem(FTextMetric, FTextMetricSize);
      FTextMetricSize := Size;
      GetMem(FTextMetric, FTextMetricSize);
    end;
  if Size > 0
    then
      GetOutlineTextMetricsW(DC, FTextMetricSize, FTextMetric)
    else
    begin // no installing font
      FTextMetricSize := SizeOf(TOutlineTextmetricW);
      GetMem(FTextMetric, FTextMetricSize);
      FTextMetric.otmTextMetrics.tmHeight := Abs(F.Height);
      FTextMetric.otmTextMetrics.tmAscent := Abs(F.Size);
      GetTextExtentPoint32(DC, 'x', 1, x_Size);
      FTextMetric.otmTextMetrics.tmAveCharWidth := x_Size.cx;
      FTextMetric.otmsStrikeoutSize := 1;
      FTextMetric.otmsStrikeoutPosition := FTextMetric.otmTextMetrics.tmHeight div 2;
      FTextMetric.otmsUnderscoreSize := 1;
      FTextMetric.otmsUnderscorePosition := FTextMetric.otmTextMetrics.tmHeight div 10;
    end;


  SelectObject(DC, OldFont);
  DeleteObject(FontDC);
  ReleaseDC(0, DC);
{$ENDIF}
end;

// =============================================================//
//                           FlashObjectLists                       //
// =============================================================//
{
***************************************************** TFlashObjectList ******************************************************
}
constructor TFlashObjectList.Create;
begin
  ObjectList := TObjectList.Create(false);
end;

destructor TFlashObjectList.Destroy;
begin
  ObjectList.Free;
  inherited Destroy;
end;

procedure TFlashObjectList.Add(Obj: TFlashIDObject);
begin
  ObjectList.Add(Obj);
end;

function TFlashObjectList.FGetFromID(ID: word): TFlashIDObject;
var
  il: Word;
begin
  Result := nil;
  if ObjectList.Count > 0 then
   for il := 0 to ObjectList.Count - 1 do
    if TFlashIDObject(ObjectList[il]).CharacterID = ID then
      begin
       Result := TFlashIDObject(ObjectList[il]);
       Break;
      end;
end;

function TFlashObjectList.GetCount: Word;
begin
  Result := ObjectList.Count;
end;

{
***************************************************** TFlashButtonList ******************************************************
}
function TFlashButtonList.GetButton(Index: word): TFlashButton;
begin
  Result := TFlashButton(ObjectList[Index]);
end;

function TFlashButtonList.GetFromID(ID: word): TFlashButton;
begin
  Result := TFlashButton(FGetFromID(ID));
end;

function TFlashButtonList.Last: TFlashButton;
begin
  if Count = 0 then Result := nil
    else Result := TFlashButton(ObjectList[Count - 1]);
end;
{
****************************************************** TFlashFontList *******************************************************
}
function TFlashFontList.GetFont(Index: word): TFlashFont;
begin
  Result := TFlashFont(ObjectList[Index]);
end;

function TFlashFontList.GetFromID(ID: word): TFlashFont;
begin
  Result := TFlashFont(FGetFromID(ID));
end;

function TFlashFontList.FindByFont(F: TFont; CompareSize: boolean): TFlashFont;
 var il: integer;
begin
 Result := nil;
 if Count > 0 then
  for il := 0 to Count - 1 do
   With Font[il] do
   if (F.Name = Name) and (Bold = (fsBold in F.Style)) and (Italic = (fsItalic in F.Style))
       and (not CompareSize or (F.Size = Size)) then
     begin
       Result := Font[il];
       Break;
     end;
end;

function TFlashFontList.Last: TFlashFont;
begin
  if Count = 0 then Result := nil
    else Result := TFlashFont(ObjectList[Count - 1]);
end;
{
****************************************************** TFlashImageList ******************************************************
}
function TFlashImageList.GetFromID(ID: word): TFlashImage;
begin
  Result := TFlashImage(FGetFromID(ID));
end;

function TFlashImageList.GetImage(Index: word): TFlashImage;
begin
  Result := TFlashImage(ObjectList[Index]);
end;

function TFlashImageList.Last: TFlashImage;
begin
  if Count = 0 then Result := nil
    else Result := TFlashImage(ObjectList[Count - 1]);
end;
{
*************************************************** TFlashMorphShapeList ****************************************************
}
function TFlashMorphShapeList.GetFromID(ID: word): TFlashMorphShape;
begin
  Result := TFlashMorphShape(FGetFromID(ID));
end;

function TFlashMorphShapeList.GetShape(Index: word): TFlashMorphShape;
begin
  Result := TFlashMorphShape(ObjectList[Index]);
end;

function TFlashMorphShapeList.Last: TFlashMorphShape;
begin
  if Count = 0 then Result := nil
    else Result := TFlashMorphShape(ObjectList[Count - 1]);
end;
{
****************************************************** TFlashShapeList ******************************************************
}
function TFlashShapeList.GetFromID(ID: word): TFlashShape;
begin
  Result := TFlashShape(FGetFromID(ID));
end;

function TFlashShapeList.GetShape(Index: word): TFlashShape;
begin
  Result := TFlashShape(ObjectList[Index]);
end;

function TFlashShapeList.Last: TFlashShape;
begin
  if Count = 0 then Result := nil
    else Result := TFlashShape(ObjectList[Count - 1]);
end;
{
****************************************************** TFlashSoundList ******************************************************
}
function TFlashSoundList.GetFromID(ID: word): TFlashSound;
begin
  Result := TFlashSound(FGetFromID(ID));
end;

function TFlashSoundList.GetSound(Index: word): TFlashSound;
begin
  Result := TFlashSound(ObjectList[Index]);
end;

function TFlashSoundList.Last: TFlashSound;
begin
  if Count = 0 then Result := nil
    else Result := TFlashSound(ObjectList[Count - 1]);
end;
{
***************************************************** TFlashSpriteList ******************************************************
}
function TFlashSpriteList.GetFromID(ID: word): TFlashSprite;
begin
  Result := TFlashSprite(FGetFromID(ID));
end;

function TFlashSpriteList.GetSprite(Index: word): TFlashSprite;
begin
  Result := TFlashSprite(ObjectList[Index]);
end;

function TFlashSpriteList.Last: TFlashSprite;
begin
  if Count = 0 then Result := nil
    else Result := TFlashSprite(ObjectList[Count - 1]);
end;

{
****************************************************** TFlashTextList *******************************************************
}
function TFlashTextList.GetFromID(ID: word): TFlashText;
begin
  Result := TFlashText(FGetFromID(ID));
end;

function TFlashTextList.GetText(Index: word): TFlashText;
begin
  Result := TFlashText(ObjectList[Index]);
end;

function TFlashTextList.Last: TFlashText;
begin
  if Count = 0 then Result := nil
    else Result := TFlashText(ObjectList[Count - 1]);
end;
{
****************************************************** TFlashVideoList ******************************************************
}
function TFlashVideoList.GetFromID(ID: word): TFlashVideo;
begin
  Result := TFlashVideo(FGetFromID(ID));
end;

function TFlashVideoList.GetVideo(Index: word): TFlashVideo;
begin
  Result := TFlashVideo(ObjectList[Index]);
end;

function TFlashVideoList.Last: TFlashVideo;
begin
  if Count = 0 then Result := nil
    else Result := TFlashVideo(ObjectList[Count - 1]);
end;
{
**************************************************** TFlashExternalMovie ****************************************************
}
constructor TFlashExternalMovie.Create(owner: TFlashMovie; src: string);
begin
  inherited Create(owner);
  FReader := TSWFStreamReader.Create(src);
  FRenameFontName := true;
end;

constructor TFlashExternalMovie.Create(owner: TFlashMovie; src: TStream);
begin
  inherited Create(owner);
  FReader := TSWFStreamReader.Create(src);
  FRenameFontName := true;
end;

destructor TFlashExternalMovie.Destroy;
begin
  FReader.Free;
  if FSprite <> nil then FSprite.Free;
  inherited;
end;

function TFlashExternalMovie.IDObjectsCount: Word;
var
  il: integer;
begin
  Result := 0;
  if FReader.TagList.Count = 0 then Exit;
  for il := 0 to FReader.TagList.Count - 1 do
   With FReader.TagInfo[il] do
    Case TagID of
       tagDefineShape, tagDefineShape2, tagDefineShape3, tagDefineShape4,

       tagDefineMorphShape, tagDefineMorphShape2,

       tagDefineBits, tagDefineBitsJPEG2, tagDefineBitsJPEG3,
       tagDefineBitsLossless, tagDefineBitsLossless2,

       tagDefineFont, tagDefineFont2, tagDefineFont3,

       tagDefineText, tagDefineText2,

       tagDefineEditText,

       tagDefineSound,

       tagDefineButton, tagDefineButton2,

       tagDefineSprite,

       tagDefineVideoStream: inc(Result);

       tagImportAssets, tagImportAssets2:
        if SWFObject <> nil then
         with TSWFImportAssets(SWFObject) do
          if Assets.Count > 0 then
           inc(Result, Assets.Count);
    end;
end;

procedure TFlashExternalMovie.Renumber(start: word);
begin
  FReader.Renumber(start);
end;

procedure TFlashExternalMovie.WriteToStream(be: TBitsEngine);
var
  il: Word;
  isWrite, UserIsWrite: Boolean;
  O: TSWFObject;
  fontPrefix, noRenameName: string;
  ils: integer;
  sflag: byte;
begin
  if FReader.TagList.Count > 0 then
   begin
    if RenameFontName then fontPrefix := IntToStr(random($FFFF));
    if (IncludeMode = eimSprite) then
      begin
       if FSprite = nil then
         begin
           FSprite := TFlashSprite.Create(owner);
           FSprite.Owner := Owner;
           FSprite.CharacterId := CharacterId;
         end else
         begin
           FSprite.Sprite.ControlTags.Clear;
           FSprite.FrameCount := 0;
         end;
      end;

    noRenameName := '"';
    For il := 0 to FReader.TagList.Count - 1 do
     With FReader.TagInfo[il] do
      if SWFObject = nil then
       begin
         FReader.BodyStream.Position := Position;
         be.BitsStream.CopyFrom(FReader.BodyStream, GetFullSize);
       end else
       begin
        isWrite := true;
        UserIsWrite := true;
        Case TagID of
         tagSetBackgroundColor, tagProtect, tagEnd,
         tagMetadata, tagFileAttributes,
         tagEnableDebugger, tagEnableDebugger2:
           isWrite := false;

         tagPlaceObject, tagPlaceObject2, tagPlaceObject3,
         tagRemoveObject, tagRemoveObject2,
         tagStartSound:
            if IncludeMode = eimResource then isWrite := false;

         tagShowFrame:
            if IncludeMode in [eimResource, eimNoFrameRoot] then isWrite := false;
        end;

   // eimResource, eimNoFrameRoot, eimSprite
        if isWrite and Assigned(FOnWriteTag) then OnWriteTag(SWFObject, UserIsWrite);

        if isWrite and UserIsWrite then
          case TagID of
            tagShowFrame:
              if IncludeMode = eimSprite then FSprite.ShowFrame else
              begin
                SWFObject.WriteToStream(be);
                Owner.SWFHeader.FramesCount := Owner.SWFHeader.FramesCount + 1;
              end;

            tagDefineFontInfo, tagDefineFontInfo2:
              with TSWFDefineFontInfo(SWFObject) do
              begin
                if RenameFontName and (CodeTable.Count > 0)
                  then FontName := fontPrefix + FontName
                  else noRenameName := noRenameName + FontName + '"';
                WriteToStream(be);
              end;


            tagDefineFont2, tagDefineFont3:
              with TSWFDefineFont2(SWFObject) do
              begin
                if RenameFontName and (GlyphShapeTable.Count > 0)
                  then FontName := fontPrefix + FontName
                  else noRenameName := noRenameName + FontName + '"';
                WriteToStream(be);
              end;

            tagDefineEditText:
              with TSWFDefineEditText(SWFObject) do
               begin
                 // replace <font face="name"> to <font face="prefix+name">
                 if RenameFontName and HasText and HTML and (InitialText <> '') then
                 begin
                   ils := 1;
                   sflag := 0; // begin search "face"
                   while ils < Length(InitialText) do
                   begin
                     if (sflag = 0) and
                      (LowerCase(InitialText[ils])='f') and
                      (LowerCase(InitialText[ils+1])='a') and
                      (LowerCase(InitialText[ils+2])='c') and
                      (LowerCase(InitialText[ils+3])='e')
                      then
                      begin
                        sflag := 1;
                        inc(ils, 4);
                      end;
                     if (sflag = 1) and (InitialText[ils] in ['"', '''']) then
                       begin
                         InitialText := Copy(InitialText, 1, ils) + fontPrefix +
                                        Copy(InitialText, ils + 1, Length(InitialText) - ils);
                         if InitialText[ils] = '"' then sflag := 2 else sflag := 3;
                         inc(ils, length(fontPrefix) + 1);
                       end;
                     if (sflag = 2) and (InitialText[ils] = '"') then sflag := 0 else
                     if (sflag = 3) and (InitialText[ils] = '''') then sflag := 0;

                     inc(ils);
                   end;
                 end;
                 WriteToStream(be);
               end;

            tagStartSound, tagPlaceObject, tagPlaceObject2, tagPlaceObject3, tagFrameLabel,
            tagSoundStreamHead, tagSoundStreamHead2, tagSoundStreamBlock,
            tagRemoveObject, tagRemoveObject2, tagDoAction:
             if IncludeMode = eimSprite then
               begin
                 O := GenerateSWFObject(TagID);
                 O.Assign(SWFObject);
                 FSprite.ObjectList.Add(O);
               end else SWFObject.WriteToStream(be);

            else SWFObject.WriteToStream(be);
          end;

       end;
     if (IncludeMode = eimSprite) then FSprite.WriteToStream(be);
   end;
end;

{
******************************************************** TFlashMovie ********************************************************
}
constructor TFlashFilterSettings.Create;
begin
 inherited;
 FShadowColor := TSWFRGBA.Create(true);
 FGlowColor := TSWFRGBA.Create(true);

 FShadowColor.RGBA := cswfBlack;
 FGlowColor.RGBA := cswfWhite;
 BlurX := 5;
 BlurY := 5;
 Distance := 5;
 Angle := 45;
 Strength := 100;
 OnTop := true;
end;

destructor TFlashFilterSettings.Destroy;
begin
 FShadowColor.Free;
 FGlowColor.Free;
 inherited;
end;

{$IFDEF ASCompiler}
constructor TBaseCompileContext.Create(owner: TFlashMovie);
begin
 inherited Create;
 FMovie := owner;
end;

function TBaseCompileContext.GetListing: TStream;
begin
  Result := FMovie.ASCompilerLog;
end;

{$ENDIF}

// =============================================================//
//                           TFlashMovie                        //
// =============================================================//
{
******************************************************** TFlashMovie ********************************************************
}
constructor TFlashMovie.Create(XMin, YMin, XMax, YMax: integer; fps: single; sc: TSWFSystemCoord = scTwips);
begin
  inherited ;
  FFix32bitImage := True;//yangrh
  CorrectImageFill := true;
  FObjectList := TObjectList.Create;
  CurrentObjID := 1;
{$IFDEF ASCompiler}
  FSelfDestroyASLog := false;
{$ENDIF}
end;


destructor TFlashMovie.Destroy;
begin
  if FGlobalFilterSettings <> nil then FGlobalFilterSettings.Free;
  if FBackgroundColor <> nil then FBackgroundColor.Free;
  if FBackgroundSound <> nil then FBackgroundSound.Free;
  if FVideoList <> nil then FVideoList.Free;
  if FButtons <> nil then FButtons.Free;
  if FFonts <> nil then FFonts.Free;
  if FImages <> nil then FImages.Free;
  if FMorphShapes <> nil then FMorphShapes.Free;
  if FShapes <> nil then FShapes.Free;
  if FSounds <> nil then FSounds.Free;
  if FSprites <> nil then FSprites.Free;
  if FTexts <> nil then FTexts.Free;
  if FVideos <> nil then FVideos.Free;
  if FCanvas <> nil then FCanvas.Free;
  if FFileAttributes <> nil then FFileAttributes.Free;
{$IFDEF ASCompiler}
  if FASCompiler <> nil then FASCompiler.Free;
  if FSelfDestroyASLog and (FASCompilerLog <> nil) then FASCompilerLog.Free;
{$ENDIF}

  FObjectList.Free;
  inherited ;
end;

procedure TFlashMovie.DoChangeHeader;
begin
  inherited;
  if Version > 7 then CorrectImageFill := false;
end;

function TFlashMovie.AddArc(XCenter, YCenter, RadiusX, RadiusY: longint; StartAngle, EndAngle: single; closed: boolean =
        true): TFlashShape;
begin
  result := AddShape;
  result.SetShapeBound(XCenter - RadiusX, YCenter - RadiusY, XCenter + RadiusX, YCenter + RadiusY);
  result.Edges.MakeArc(XCenter, YCenter, RadiusX, RadiusY, StartAngle, EndAngle, closed);
  result.Edges.EndEdges;
end;

function TFlashMovie.AddArc(XCenter, YCenter, Radius: longint; StartAngle, EndAngle: single; closed: boolean = true):
        TFlashShape;
begin
  result := AddArc(XCenter, YCenter, Radius, Radius, StartAngle, EndAngle, closed);
end;

function TFlashMovie.AddButton(hasmenu: boolean = false; advMode: boolean = true): TFlashButton;
begin
  Result := TFlashButton.Create(self, hasmenu, advMode);
  Result.CharacterId := CurrentObjID;
  AddFlashObject(Result);
  Buttons.Add(Result);
  inc(FCurrentObjID);
end;

function TFlashMovie.AddCircle(XCenter, YCenter, Radius: integer): TFlashShape;
begin
  Result := AddEllipse(XCenter - Radius, YCenter - Radius,
                      XCenter + Radius, YCenter + Radius);
end;

function TFlashMovie.AddCubicBezier(P0, P1, P2, P3: TPoint): TFlashShape;
begin
  result := AddShape;
  result.SetShapeBound( MinIntValue([P0.X, P1.X, P2.X, P3.X]),
                        MinIntValue([P0.Y, P1.Y, P2.Y, P3.Y]),
                        MaxIntValue([P0.X, P1.X, P2.X, P3.X]),
                        MaxIntValue([P0.Y, P1.Y, P2.Y, P3.Y]));
  With Result.Edges do
    begin
     MoveTo(P0.X, P0.Y);
     MakeCubicBezier(P1, P2, P3);
     EndEdges;
    end;
end;

function TFlashMovie.AddCurve(P1, P2, P3: TPoint): TFlashShape;
begin
  result := AddShape;
  result.SetShapeBound( MinIntValue([P1.X, P2.X, P3.X]),
                        MinIntValue([P1.Y, P2.Y, P3.Y]),
                        MaxIntValue([P1.X, P2.X, P3.X]),
                        MaxIntValue([P1.Y, P2.Y, P3.Y]));
  With Result.Edges do
    begin
      MoveTo(P1.X, P1.Y);
      CurveTo(P2.X, P2.Y, P3.X, P3.Y);
      EndEdges;
    end;
end;

function TFlashMovie.AddDiamond(XMin, YMin, XMax, YMax: integer): TFlashShape;
begin
  result := AddShape;
  result.SetShapeBound(XMin, YMin, XMax, YMax);
  With Result.Edges do
    begin
      MoveTo(XMin + (XMax - XMin) div 2, YMin);
      MakeDiamond(XMax - XMin, YMax - YMin);
      EndEdges;
    end;
end;

function TFlashMovie.AddDynamicText(varname, init: ansistring; c: recRGBA; f: TFlashFont; R: TRect): TFlashText;
var
  fu: TFontUsing;
begin
  fu := f.FontUsing;
  Result := AddText(init, c, f, R);
  Result.DynamicText := true;
  f.FontUsing := fu + [fuDynamicText];
  Result.VarName := varname;
end;

{$IFNDEF VER130}
function TFlashMovie.AddDynamicText(varname: ansistring; init: WideString; c: recRGBA; f: TFlashFont; R: TRect): TFlashText;
begin
  Result := AddDynamicTextW(varname, init, c, f, R);
end;
{$ENDIF}

function TFlashMovie.AddDynamicTextW(varname: ansistring; init: WideString; c: recRGBA; f: TFlashFont; R: TRect): TFlashText;
var
  fu: TFontUsing;
begin
  fu := f.FontUsing;
  Result := AddText(init, c, f, R);
  Result.DynamicText := true;
  f.FontUsing := fu + [fuDynamicText];
  Result.VarName := varname;
end;

function TFlashMovie.AddEllipse(XMin, YMin, XMax, YMax: integer): TFlashShape;
var
  W, H: LongInt;
begin
  result := AddShape;
  result.SetShapeBound(XMin, YMin, XMax, YMax);
  W := Xmax - Xmin;
  H := Ymax - Ymin;
  with Result.Edges do
    begin
      MoveTo(Xmin, Ymin);
      MakeEllipse(W, H);
      EndEdges;
    end;
end;

function TFlashMovie.AddEllipse(R: TRect): TFlashShape;
begin
  Result := AddEllipse(R.Left, R.Top, R.Right, R.Bottom);
end;

function TFlashMovie.AddExternalMovie(src: string; IM: TExternalIncludeMode; autorenum: boolean = true): TFlashExternalMovie;
begin
  Result := TFlashExternalMovie.Create(self, src);
  ExtMoviePrepare(Result, IM, autorenum);
end;

function TFlashMovie.AddExternalMovie(src: TStream; IM: TExternalIncludeMode; autorenum: boolean = true): 
        TFlashExternalMovie;
begin
  Result := TFlashExternalMovie.Create(self, src);
  ExtMoviePrepare(Result, IM, autorenum);
end;

procedure TFlashMovie.AddFlashObject(Obj: TBasedSWFObject);
 var ind: longint;
begin
  if CurrentFramePosIndex = -1 then CurrentFramePosIndex := ObjectList.Count -1;
  if (AddObjectMode = amEnd) or
     (CurrentFramePosIndex >= (ObjectList.Count -1)) then
   begin
     ObjectList.Add(Obj);
     CurrentFramePosIndex := ObjectList.Count - 1;
   end else
   begin
     ind := CurrentFramePosIndex;
     case AddObjectMode of
       amHomeCurrentFrame:
       begin
         while ind > 0 do
           if (TBasedSWFObject(ObjectList[ind]).LibraryLevel = SWFLevel) and
              (TSWFObject(ObjectList[ind]).TagID = tagShowFrame)
             then Break
             else dec(ind);
       end;
     end;
     ObjectList.Insert(ind, Obj);
     inc(CurrentFramePosIndex);
   end;
end;

function TFlashMovie.AddFont: TFlashFont;
begin
  Result := TFlashFont.Create(self);
  Result.CharacterId := CurrentObjID;
  AddFlashObject(Result);
  Fonts.Add(Result);
  inc(FCurrentObjID);
end;

function TFlashMovie.AddFont(FontInfo: TFont; device: boolean = true): TFlashFont;
begin
  Result := TFlashFont.Create(self, device, FontInfo.Name, fsbold in FontInfo.Style,
                              fsItalic in FontInfo.Style, Abs(FontInfo.Height));
  Result.CharacterId := CurrentObjID;
  Result.FontCharset := FontInfo.Charset;
  AddFlashObject(Result);
  Fonts.Add(Result);
  inc(FCurrentObjID);
end;

function TFlashMovie.AddFont(LogFont: TLogFont; device: boolean = true): TFlashFont;
begin
  Result := TFlashFont.Create(self);
  Result.CharacterId := CurrentObjID;
  AddFlashObject(Result);
  Fonts.Add(Result);
  inc(FCurrentObjID);
  Result.AsDevice := device;
  Result.SetFontInfo(LogFont);
end;

function TFlashMovie.AddFont(Name: string; bold, italic: boolean; size: integer; device: boolean = true): TFlashFont;
begin
  Result := TFlashFont.Create(self, device, Name, bold, Italic, size);
  Result.CharacterId := CurrentObjID;
  AddFlashObject(Result);
  Fonts.Add(Result);
  inc(FCurrentObjID);
end;

procedure TFlashMovie.AddIDObject(Obj: TFlashIDObject; SetID: boolean = true);
begin
  AddFlashObject(Obj);
  Obj.Owner := self;
  if SetID then
    begin
      Obj.CharacterID := CurrentObjID;
      inc(FCurrentObjID);
    end;
end;

function TFlashMovie.AddImage(fn: string = ''): TFlashImage;
begin
  result := TFlashImage.Create(self, fn);
  Result.CharacterID := CurrentObjID;
  AddFlashObject(Result);
  Images.Add(Result);
  inc(FCurrentObjID);
end;

function TFlashMovie.AddLine(X1, Y1, X2, Y2: longint): TFlashShape;
begin
  result := AddShape;
  result.SetShapeBound(X1, Y1, X2, Y2);
  With result.Edges do
    begin
      MoveTo(X1, Y1);
      LineTo(X2, Y2);
    end;
end;

function TFlashMovie.AddMorphShape(shape: TFlashMorphShape = nil): TFlashMorphShape;
begin
  if Shape = nil then Result := TFlashMorphShape.Create(self) else Result := Shape;
  Result.CharacterId := CurrentObjID;
  AddFlashObject(Result);
  MorphShapes.Add(Result);
  inc(FCurrentObjID);
end;

function TFlashMovie.AddPie(XCenter, YCenter, Radius: longint; StartAngle, EndAngle: single): TFlashShape;
begin
  Result := AddPie(XCenter, YCenter, Radius, Radius, StartAngle, EndAngle);
end;

function TFlashMovie.AddPie(XCenter, YCenter, RadiusX, RadiusY: longint; StartAngle, EndAngle: single): TFlashShape;
begin
  result := AddShape;
  result.SetShapeBound(XCenter - RadiusX, YCenter - RadiusY, XCenter + RadiusX, YCenter + RadiusY);
  With result.Edges do
    begin
      MoveTo(XCenter, YCenter);
      MakePie(RadiusX, RadiusY, StartAngle, EndAngle);
      EndEdges;
    end;
end;

function TFlashMovie.AddPolygon(AP: array of TPoint): TFlashShape;
var
  il: Integer;
  XMin, YMin, XMax, YMax: Integer;
begin
  result := AddShape;
  For il := low(AP) to High(AP) do
   begin
    if il = low(AP) then
      begin
        XMin := AP[il].X;
        YMin := AP[il].Y;
        XMax := AP[il].X;
        YMax := AP[il].Y;
      end else
      begin
        if XMin > AP[il].X then XMin := AP[il].X else
          if XMax < AP[il].X then XMax := AP[il].X;

        if YMin > AP[il].Y then YMin := AP[il].Y else
          if YMax < AP[il].Y then YMax := AP[il].Y;
      end;
   end;
  result.SetShapeBound(XMin, YMin, XMax, YMax);
    With result.Edges do
      begin
        MakePolyline(AP);
        CloseShape;
        EndEdges;
      end;
end;

function TFlashMovie.AddPolyline(AP: array of TPoint): TFlashShape;
var
  il: Integer;
  XMin, YMin, XMax, YMax: Integer;
begin
  result := AddShape;
  For il := low(AP) to High(AP) do
   begin
    if il = low(AP) then
      begin
        XMin := AP[il].X;
        YMin := AP[il].Y;
        XMax := AP[il].X;
        YMax := AP[il].Y;
      end else
      begin
        if XMin > AP[il].X then XMin := AP[il].X else
          if XMax < AP[il].X then XMax := AP[il].X;

        if YMin > AP[il].Y then YMin := AP[il].Y else
          if YMax < AP[il].Y then YMax := AP[il].Y;
      end;
   end;
  result.SetShapeBound(XMin, YMin, XMax, YMax);
  result.Edges.MakePolyline(AP);
  result.Edges.EndEdges;
end;

function TFlashMovie.AddRectangle(XMin, YMin, XMax, YMax: longint): TFlashShape;
begin
  result := AddShape;
  result.SetShapeBound(XMin, YMin, XMax, YMax);
  With result.Edges do
    begin
      MoveTo(XMin, YMin);
      MakeRectangle(XMax-XMin, YMax-YMin);
      EndEdges;
    end;
end;

function TFlashMovie.AddRectangle(R: TRect): TFlashShape;
begin
  Result := AddRectangle(R.Left, R.Top, R.Right, R.Bottom);
end;

function TFlashMovie.AddRing(XCenter, YCenter, Radius1, Radius2: integer): TFlashShape;
var
  Big, Sm: LongInt;
begin
  if Radius1 > Radius2 then
    begin
      Big := Radius1;
      Sm := Radius2;
    end else
    begin
      Big := Radius2;
      Sm := Radius1;
    end;

  result := AddShape;
  result.SetShapeBound(XCenter - Big, YCenter - Big, XCenter + Big, YCenter + Big);
  With result.Edges do
    begin
      MoveTo(XCenter - Big, YCenter - Big);
      MakeEllipse(2 * Big, 2 * Big);
      MoveTo(XCenter - Sm, YCenter - Sm);
      MakeEllipse(2 * Sm, 2 * Sm);
      EndEdges;
    end;
end;

function TFlashMovie.AddRoundRect(XMin, YMin, XMax, YMax, Radius: longint): TFlashShape;
begin
  result := AddShape;
  result.SetShapeBound(XMin, YMin, XMax, YMax);
  With result.Edges do
    begin
     MoveTo(XMin, YMin);
     MakeRoundRect(XMax-XMin, YMax-YMin, Radius);
     EndEdges;
    end;
end;

function TFlashMovie.AddRoundRect(R: TRect; Radius: longint): TFlashShape;
begin
  Result := AddRoundRect(R.Left, R.Top, R.Right, R.Bottom, Radius);
end;

function TFlashMovie.AddShape(shape: TFlashShape = nil): TFlashShape;
begin
  if Shape = nil then Result := TFlashShape.Create(self) else Result := Shape;
  Result.CharacterId := CurrentObjID;
  AddFlashObject(Result);
  Shapes.Add(Result);
  inc(FCurrentObjID);
end;

function TFlashMovie.AddShapeImage(fn: string): TFlashShape;
var
  img: TFlashImage;
begin
  img := AddImage(fn);
  Result := AddRectangle(0, 0, Img.Width, Img.Height);
  Result.SetImageFill(img, fmFit);
end;

function TFlashMovie.AddShapeImage(img: TFlashImage): TFlashShape;
begin
  Result := AddRectangle(0, 0, Img.Width,  Img.Height);
  Result.SetImageFill(img, fmFit)
end;

function TFlashMovie.AddSound(fn: string): TFlashSound;
begin
  Result := TFlashSound.Create(self, fn);
  result.CharacterID := CurrentObjID;
  AddFlashObject(Result);
  Sounds.Add(Result);
  inc(FCurrentObjID);
end;

function TFlashMovie.AddSound(Src: TMemoryStream; isMP3: boolean): TFlashSound;
begin
  Result := TFlashSound.Create(self, '');
  Result.LoadFromMemory(Src, isMP3);
  result.CharacterID := CurrentObjID;
  AddFlashObject(Result);
  Sounds.Add(Result);
  inc(FCurrentObjID);
end;

function TFlashMovie.AddSprite(VO: TFlashVisualObject = nil): TFlashSprite;
begin
  Result := TFlashSprite.Create(self);
  Result.CharacterId := CurrentObjID;
  AddFlashObject(Result);
  Sprites.Add(Result);
  inc(FCurrentObjID);
  if VO <> nil then Result.PlaceObject(VO, 1);
end;

function TFlashMovie.AddSquare(XMin, YMin, Side: integer): TFlashShape;
begin
  Result := AddRectangle(XMin, YMin, XMin + Side, YMin + Side);
end;

function TFlashMovie.AddSquare(XMin, YMin, XMax, YMax: integer): TFlashShape;
begin
  if (YMax - YMin) < (XMax - XMin)
   then
    Result := AddRectangle(XMin, YMin, XMin + (YMax - YMin), YMax)
   else
    Result := AddRectangle(XMin, YMin, XMax, YMin + (XMax - XMin));
end;

function TFlashMovie.AddStar(X, Y, R1, R2: longint; NumPoint: word; curve: boolean = false): TFlashShape;
var
  RMax: LongInt;
begin
  Result := AddShape;
  RMax := Max(R1, R2);
  Result.SetShapeBound(X - RMax, Y - RMax, X + RMax, Y + RMax);
  Result.Edges.MakeStar(X, Y, R1, R2, NumPoint, curve);
  Result.Edges.EndEdges;
end;

function TFlashMovie.AddText: TFlashText;
begin
  Result := TFlashText.Create(self, '');
  Result.CharacterId := CurrentObjID;
  AddFlashObject(Result);
  Texts.Add(Result);
  inc(FCurrentObjID);
end;

function TFlashMovie.AddText(s: ansistring; c: recRGBA; f: TFlashFont; P: TPoint; Align: TSWFTextAlign = taLeft): TFlashText;
begin
  Result := TFlashText.Create(self, s, c, f, P, Align);
  Result.CharacterId := CurrentObjID;
  AddFlashObject(Result);
  Texts.Add(Result);
  inc(FCurrentObjID);
end;

function TFlashMovie.AddText(s: ansistring; c: recRGBA; f: TFlashFont; R: TRect): TFlashText;
begin
  Result := TFlashText.Create(self, s, c, f, R);
  Result.CharacterId := CurrentObjID;
  AddFlashObject(Result);
  Texts.Add(Result);
  inc(FCurrentObjID);
end;

{$IFNDEF VER130}
function TFlashMovie.AddText(s: WideString; c: recRGBA; f: TFlashFont; P: TPoint; Align: TSWFTextAlign = taLeft): TFlashText;
begin
  Result := AddTextW(s, c, f, P, Align);
end;

function TFlashMovie.AddText(s: WideString; c: recRGBA; f: TFlashFont; R: TRect): TFlashText;
begin
  Result := AddTextW(s, c, f, R);
end;
{$ENDIF}

function TFlashMovie.AddTextW(s: WideString; c: recRGBA; f: TFlashFont; P: TPoint; Align: TSWFTextAlign = taLeft):
        TFlashText;
begin
  Result := TFlashText.CreateW(self, s, c, f, P, Align);
  Result.CharacterId := CurrentObjID;
  AddFlashObject(Result);
  Texts.Add(Result);
  inc(FCurrentObjID);
end;

function TFlashMovie.AddTextW(s: WideString; c: recRGBA; f: TFlashFont; R: TRect): TFlashText;
begin
  Result := TFlashText.CreateW(self, s, c, f, R);
  Result.CharacterId := CurrentObjID;
  AddFlashObject(Result);
  Texts.Add(Result);
  inc(FCurrentObjID);
end;

function TFlashMovie.AddVideo(FileName: string): TFlashVideo;
begin
  Result := TFlashVideo.Create(self, FileName);
  Result.CharacterID := CurrentObjID;
  AddFlashObject(Result);
  Videos.Add(Result);
  inc(FCurrentObjID);
end;

function TFlashMovie.AddVideoFromStream(MS: TMemoryStream): TFlashVideo;
begin
  Result := TFlashVideo.Create(self, MS);
  Result.CharacterID := CurrentObjID;
  AddFlashObject(Result);
  Videos.Add(Result);
  inc(FCurrentObjID);
end;

function TFlashMovie.CalcFramesCount: Word;
var
  il: Word;
begin
  Result := 0;
  if ObjectList.Count > 0 then
   for il := 0 to ObjectList.Count - 1 do
     if (TBasedSWFObject(ObjectList[il]).LibraryLevel = SWFLevel) and
        (TSWFObject(ObjectList[il]).TagID = tagShowFrame) then Inc(Result);
  if Result <> FramesCount then SWFHeader.FramesCount := Result;
end;

procedure TFlashMovie.Clear;
begin
  Protect := false;
  BackgroundMode := bmNone;
  ObjectList.Clear;
  Texts.ObjectList.Clear;
  Fonts.ObjectList.Clear;
  Shapes.ObjectList.Clear;
  Images.ObjectList.Clear;
  Sounds.ObjectList.Clear;
  Buttons.ObjectList.Clear;
  MorphShapes.ObjectList.Clear;
  Sprites.ObjectList.Clear;
  Videos.ObjectList.Clear;
  CurrentObjID := 1;
end;

function TFlashMovie.ExportAssets(name: string; id: word): TSWFExportAssets;
begin
  Result := TSWFExportAssets.Create;
  Result.SetAsset(name, id);
  AddFlashObject(Result);
end;

function TFlashMovie.ExportAssets(name: string; Sprite: TFlashSprite): TSWFExportAssets;
begin
  Result := ExportAssets(name, Sprite.CharacterId);
end;

procedure TFlashMovie.ExtMoviePrepare(EM: TFlashExternalMovie; IM: TExternalIncludeMode; autorenum: boolean);
begin
  EM.IncludeMode := IM;
  AddIDObject(EM);
  EM.Reader.ReadBody(true{autorenum}, false);
  if autorenum then EM.Renumber(EM.CharacterId + 1 * byte(EM.IncludeMode = eimSprite));
  FCurrentObjID := EM.IDObjectsCount + EM.CharacterId + 1 + 1 * byte(EM.IncludeMode = eimSprite);
  if EM.IncludeMode = eimSprite then
    begin
      EM.FSprite := TFlashSprite.Create(self);
      EM.FSprite.CharacterId := EM.CharacterId;
      EM.FSprite.FrameCount := EM.Reader.FramesCount;
      Sprites.Add(EM.FSprite);
    end;
end;

function TFlashMovie.FindObjectFromID(ID: word): TFlashIDObject;
var
  il: Integer;
begin
  Result := nil;
  if ObjectList.Count > 0 then
   For il := 0 to ObjectList.Count -1 do
    if (ObjectList[il] is TFlashIdObject) and (TFlashIdObject(ObjectList[il]).CharacterID = ID) then
      Result := TFlashIdObject(ObjectList[il]);
end;

function TFlashMovie.FramePos(num: word): longint;
  var il, cur: longint;
begin
 cur := 0;
 Result := 0;
 if (num = 0) or (ObjectList.Count = 0) then Exit;
 Result := -1;
 for il := 0 to ObjectList.Count - 1 do
   if (ObjectList[il] is TSWFShowFrame) then
     begin
       inc(cur);
       if num = cur then
         begin
           Result := il;
           Break;
         end;
     end;
 if Result = -1 then Result := ObjectList.Count - 1;
end;

{$IFDEF ASCompiler}
function TFlashMovie.GetASCompilerLog: TStream;
begin
  if FASCompilerLog = nil then
    begin
      FASCompilerLog := TMemoryStream.Create;
      FSelfDestroyASLog := true;
    end;
  Result := FASCompilerLog;
end;

function TFlashMovie.GetASCompiler: TBaseCompileContext;
begin
  if FASCompiler = nil then
    begin
      FASCompiler := TCompileContext.Create(self);
    end;
  Result := FASCompiler;
end;

procedure TFlashMovie.SetCompilerOptions(value: TCompileOptions);
begin
  if FASCompilerOptions <> Value then
  begin
    TCompileContext(ASCompiler).CompileOptions := Value;
  end;
end;
{$ENDIF}

function TFlashMovie.GetBackgrondSound: TFlashSound;
begin
  if fBackgroundSound = nil then
    begin
      fBackgroundSound := TFlashSound.Create(self);
      fBackgroundSound.AutoLoop := true;
      EnableBGSound := true;
    end;
  Result := fBackgroundSound;
end;

function TFlashMovie.GetBackgroundColor: TSWFRGB;
begin
  if fBackgroundColor = nil then fBackgroundColor := TSWFRGB.Create;
  result := fBackgroundColor;
  BackgroundMode := bmColor;
end;

function TFlashMovie.GetButtons: TFlashButtonList;
begin
  if FButtons = nil then FButtons := TFlashButtonList.Create;
  Result := FButtons;
end;

function TFlashMovie.GetCanvas: TFlashCanvas;
begin
  if FCanvas = nil then
    FCanvas := TFlashCanvas.Create(self);
  Result := FCanvas;
end;

function TFlashMovie.GetFileAttributes: TSWFFileAttributes;
begin
  if FFileAttributes = nil then FFileAttributes := TSWFFileAttributes.Create;
  Result := FFileAttributes;
end;

function TFlashMovie.GetFonts: TFlashFontList;
begin
  if FFonts = nil then FFonts := TFlashFontList.Create;
  Result := FFonts;
end;

function TFlashMovie.GetFrameActions: TFlashActionScript;
begin
  if fFrameActions = nil then fFrameActions := TFlashActionScript.Create(self);
  Result:=fFrameActions;
end;

function TFlashMovie.GetGlobalFilterSettings: TFlashFilterSettings;
begin
 if FGlobalFilterSettings = nil then FGlobalFilterSettings := TFlashFilterSettings.Create;
 Result := FGlobalFilterSettings;
end;

function TFlashMovie.GetHasMetadata: boolean;
begin
  Result := GetFileAttributes.HasMetadata;
end;

function TFlashMovie.GetImages: TFlashImageList;
begin
  if FImages = nil then FImages := TFlashImageList.Create;
  Result := FImages;
end;

function TFlashMovie.GetMinVersion: Byte;
var
  il: Integer;
  SWFObject: TBasedSWFObject;
begin
  Result := SWFVer1;
  if UseFileAttributes then Result := SWFVer8 else
  if ObjectList.Count > 0 then
    for il:=0 to ObjectList.Count - 1 do
     begin
       SWFObject := TBasedSWFObject(ObjectList[il]);
       if (SWFObject<>nil) and (Result < SWFObject.MinVersion) then
         Result := SWFObject.MinVersion;
     end;
end;

function TFlashMovie.GetMorphShapes: TFlashMorphShapeList;
begin
  if FMorphShapes = nil then FMorphShapes := TFlashMorphShapeList.Create;
  Result := FMorphShapes;
end;

function TFlashMovie.GetObjectList: TObjectList;
begin
  Result := FObjectList;
end;

function TFlashMovie.GetShapes: TFlashShapeList;
begin
  if FShapes = nil then FShapes := TFlashShapeList.Create;
  Result := FShapes;
end;

function TFlashMovie.GetSounds: TFlashSoundList;
begin
  if FSounds = nil then FSounds := TFlashSoundList.Create;
  Result := FSounds;
end;

function TFlashMovie.GetSprites: TFlashSpriteList;
begin
  if FSprites = nil then FSprites := TFlashSpriteList.Create;
  Result := FSprites;
end;

function TFlashMovie.GetTexts: TFlashTextList;
begin
  if FTexts = nil then FTexts := TFlashTextList.Create;
  Result := FTexts;
end;

function TFlashMovie.GetUseNetwork: boolean;
begin
  Result := GetFileAttributes.UseNetwork;
end;

function TFlashMovie.GetVideoListCount: Integer;
begin
  if FVideoList = nil then Result := 0
    else Result := FVideoList.Count;
end;

function TFlashMovie.GetVideos: TFlashVideoList;
begin
  if FVideos = nil then FVideos := TFlashVideoList.Create;
  Result := FVideos;
end;

function TFlashMovie.GetVideoStream(index: LongInt): TFlashPlaceVideo;
begin
  result := nil;
  if VideoListCount > 0 then
    Result := TFlashPlaceVideo(FVideoList[index]);
end;

function TFlashMovie.ImportAssets(filename: string): TSWFImportAssets;
 var R: TSWFStreamReader;
     il: longint;
     il2: byte;
     EA: TSWFExportAssets;
     BE: TBitsEngine;
begin
  Result := TSWFImportAssets.Create;
  Result.URL := ExtractFileName(filename);

  R := TSWFStreamReader.Create(filename);
  R.ReadBody(false, false);
  if R.TagList.Count > 0 then
   for il := 0 to R.TagList.Count - 1 do
    if R.TagInfo[il].TagID = tagExportAssets then
     begin
       EA := TSWFExportAssets.Create;
       BE := TBitsEngine.Create(R.BodyStream);
       R.BodyStream.Position := R.TagInfo[il].Position;
       EA.ReadFromStream(BE);
       if EA.Assets.Count > 0 then
        for il2 := 0 to EA.Assets.Count - 1 do
         begin
          Result.SetAsset(EA.Assets[il2], FCurrentObjID);
          inc(FCurrentObjID);
         end;
       BE.Free;
       EA.Free;
     end;
  R.Free;
  AddFlashObject(Result);
end;

function TFlashMovie.ImportAssets(URL, name: string): TSWFImportAssets;
begin
  Result := TSWFImportAssets.Create;
  Result.URL := URL;
  Result.SetAsset(name, CurrentObjID);
  inc(FCurrentObjID);
  AddFlashObject(Result);
end;

procedure TFlashMovie.MakeStream;
var
  BE: TBitsEngine;
  il, il2: LongInt;
  SH: TSWFSoundStreamHead2;
  fMin: Byte;
  FrCount: Word;
  PlaceExist: boolean;
{$IFDEF UNREGISTRED}
      R: TFlashShape;
      Txt: TFlashText;
      s: string;
      DF: TFlashFont;
      l: word;
  {$ENDIF}
begin
  if (BodyStream.Size > 0) then
    begin
      if (BodyStream is TMemoryStream) then TMemoryStream(BodyStream).Clear
        else BodyStream.Size := 0;
    end;
  fMin := Version;
  FrCount := 0;
{$IFDEF UNREGISTRED}
   AddObjectMode := amCurrentFrame;
   CurrentFrameNum := 0;
   SystemCoord := scTwips;
   R := AddRectangle(twips, twips, 195*twips, 25*twips);
   R.SetLineStyle(twips, cswfBlack);
   R.SetSolidColor(255, 255, 255, 190);
   l := Random($F9) + $FF00;
   PlaceObject(R, l);
   S := 'Vosfhjtusfe!wfstjpo!Efmqij!TXG!TEL"';
       //'Unregistred version Delphi SWF SDK!';
   for il := 1 to length(S) do S[il] := CHR(Ord(S[il])-1);
   DF := AddFont;
   DF.Name := 'Times New Roman';
   DF.FSize := 12 * twips;
   Txt := AddText(S, cswfBlue, DF, Rect(4*twips, 6*twips, 195*twips, 30*twips));
   PlaceObject(Txt, l + 1 + Random(3));
{$ENDIF}
  BE:=TBitsEngine.Create(BodyStream);

  if UseFileAttributes then
    begin
      GetFileAttributes.WriteToStream(BE);
      if HasMetadata then
        with TSWFMetadata.Create do
         begin
           Metadata := self.Metadata;
           WriteToStream(BE);
         end;
    end;

  if BackgroundMode = bmColor then
    With TSWFSetBackgroundColor.Create do
    begin
      Color.RGB := BackgroundColor.RGB;
      WriteToStream(BE);
      free;
    end;

  if EnableBGSound and (fBackgroundSound <> nil) then
    begin
      if fMin < BackgroundSound.MinVersion then fMin := BackgroundSound.MinVersion;
      SH := TSWFSoundStreamHead2.Create;
      BackgroundSound.FillHeader(SH, FPS);
      SH.WriteToStream(BE);
      SH.Free;
    end;
  if Protect then
   with TSWFProtect.Create do
    begin
      Password := self.Password;
      WriteToStream(BE);
      if fMin < MinVersion then fMin := MinVersion;
      Free;
    end;

  PlaceExist := false;
  if ObjectList.Count > 0 then
    begin
      For il:=0 to ObjectList.Count - 1 do
       with TBasedSWFObject(ObjectList[il]) do
        begin
          if Assigned(OnProgress) then OnProgress(self, Round((il+1)/ObjectList.Count*100), pwtMakeStream);
          if fMin < MinVersion then fMin := MinVersion;
          Case LibraryLevel of
           SWFLevel:
            begin
              case TSWFObject(ObjectList[il]).TagID of
               tagShowFrame:
                begin
                 if VideoListCount > 0 then
                   for il2 := 0 to VideoListCount-1 do
                    With VideoList[il2] do
                     WriteToStream(BE, FrCount);

                 if EnableBGSound and (fBackgroundSound <> nil) and
                    (fBackgroundSound.StartFrame <= SWFHeader.FramesCount) then
                    fBackgroundSound.WriteSoundBlock(BE);
                 inc(FrCount);
                end;

               tagPlaceObject, tagPlaceObject2, tagPlaceObject3:
                 PlaceExist := true;
              end;
            end;

           FlashLevel:
            begin
             if (ObjectList[il] is TFlashPlaceObject) then
               begin
                TFlashPlaceObject(ObjectList[il]).PlaceObject.SWFVersion := fMin;
                PlaceExist := true;
               end;
             if (ObjectList[il] is TFlashExternalMovie) and
                (TFlashExternalMovie(ObjectList[il]).IncludeMode = eimRoot)
               then
                 FrCount := FrCount + TFlashExternalMovie(ObjectList[il]).Reader.FramesCount;
            end;
          end;

          WriteToStream(be);
        end;
    end;

  if (FrCount = 0) and PlaceExist then
    begin
      BE.WriteWord(tagShowFrame shl 6);
      FrCount := 1;
    end;
  if (ObjectList.Count = 0) or not (ObjectList[ObjectList.Count-1] is TSWFEnd) then BE.WriteWord(tagEnd);

  BE.Free;
  SWFHeader.FramesCount := FrCount;
  if Version < fMin then Version := fMin;
end;

procedure TFlashMovie.MoveResource(ToFrame, StartFrom, EndFrom: integer);
  var il, iDelta, iTo, iStart, iEnd: longint;
      Obj: TBasedSWFObject;
begin
  if ToFrame > StartFrom then ToFrame := StartFrom;
  if EndFrom = -1 then EndFrom := FramesCount else
    if (EndFrom = 0) or (EndFrom < StartFrom) then EndFrom := StartFrom;
  iDelta := 0;
  iTo := FramePos(ToFrame);
  if ObjectList[iTo] is TSWFShowFrame then inc(iTo);
  if ToFrame = StartFrom
    then iStart := iTo + 1
    else iStart := FramePos(StartFrom) + 1;
  iEnd := FramePos(EndFrom + 1);
  if ObjectList[iEnd] is TSWFShowFrame then dec(iEnd);

  if iStart < iEnd  then
   for il := iStart to iEnd do
     begin
       Obj := TBasedSWFObject(ObjectList[il]);
       if (Obj is TFlashImage) or (Obj is TFlashSound) or (Obj is TFlashFont) or
         (Obj is TSWFDefineBits) or (Obj is TSWFJPEGTables) or (Obj is TSWFDefineBitsJPEG2) or
         (Obj is TSWFDefineBitsJPEG3) or (Obj is TSWFDefineBitsLossless) or (Obj is TSWFDefineBitsLossless2) or
         (Obj is TSWFDefineFont) or (Obj is TSWFDefineFont2) or (Obj is TSWFDefineFont3) or
         (Obj is TSWFDefineFont) or (Obj is TSWFDefineSound)
         then
         begin
           ObjectList.Move(il, iTo + iDelta);
           inc(iDelta);
         end;
     end;
end;


function TFlashMovie.PlaceObject(shape, mask: TFlashVisualObject; depth: word): TFlashPlaceObject;
var
  S: TFlashSprite;
begin
  S := AddSprite;
  S.PlaceObject(mask, 1).ClipDepth := 2;
  //S.PlaceObject(shape, 2);
  S.PlaceObject(shape, 2).Name := 'mc_swf';//yangrh
  Result := TFlashPlaceObject.Create(self, S, depth);
  AddFlashObject(Result);
  if FMaxDepth < depth then FMaxDepth := depth;
end;

function TFlashMovie.PlaceObject(shape: TFlashVisualObject; depth: word): TFlashPlaceObject;
begin
  Result := TFlashPlaceObject.Create(self, shape, depth);
  AddFlashObject(Result);
  if FMaxDepth < depth then FMaxDepth := depth;
end;

function TFlashMovie.PlaceObject(depth: word): TFlashPlaceObject;
begin
  Result := TFlashPlaceObject.Create(self, nil, depth);
  AddFlashObject(Result);
  if FMaxDepth < depth then FMaxDepth := depth;
end;

function TFlashMovie.PlaceVideo(F: TFlashVideo; depth: word): TFlashPlaceVideo;
begin
  Result:= TFlashPlaceVideo.Create(self, F, Depth);
  Result.StartFrame := FramesCount;
  if FVideoList = nil then FVideoList := TObjectList.Create;
  FVideoList.Add(Result);
  if FMaxDepth < depth then FMaxDepth := depth;
end;

procedure TFlashMovie.RemoveObject(depth: word; shape: TFlashVisualObject = nil);
var
  RO: TSWFRemoveObject;
  RO2: TSWFRemoveObject2;
begin
  if shape = nil then
    begin
     RO2 := TSWFRemoveObject2.Create;
     RO2.depth := depth;
     AddFlashObject(RO2);
    end else
    begin
     RO := TSWFRemoveObject.Create;
     RO.CharacterID := shape.CharacterId;
     RO.depth := depth;
     AddFlashObject(RO);
    end;
end;

procedure TFlashMovie.SetAddObjectMode(Value: TAddObjectMode);
begin
  if (FAddObjectMode <> Value) or (FAddObjectMode = amFromStartFrame) then
  begin
    FAddObjectMode := Value;
    if FAddObjectMode = amEnd then
    begin
      FCurrentFrameNum := SWFHeader.FramesCount - 1;
      CurrentFramePosIndex := ObjectList.Count - 1;
    end else
      SetCurrentFrameNum(FCurrentFrameNum);
  end;
end;

procedure TFlashMovie.SetCorrectImageFill(const Value: boolean);
begin
  FCorrectImageFill := Value;
end;

procedure TFlashMovie.SetCurrentFrameNum(Value: Integer);
begin
  if (AddObjectMode <> amEnd) and (ObjectList.Count > 0) then
   begin
    if ((AddObjectMode = amCurrentFrame) and (Value = SWFHeader.FramesCount)) or
       (Value > SWFHeader.FramesCount) then
      begin
        FCurrentFrameNum := SWFHeader.FramesCount - 1;
        CurrentFramePosIndex := ObjectList.Count - 1;
      end else
      begin
        if (AddObjectMode = amCurrentFrame) then CurrentFramePosIndex := FramePos(Value)
          else
          if Value = 0 then CurrentFramePosIndex := 0
            else CurrentFramePosIndex := FramePos(Value - 1) + 1;

//        FCurrentFrameNum := 0;
//        for il := 0 to ObjectList.Count - 1 do
//         if (TBasedSWFObject(ObjectList[il]).LibraryLevel = SWFLevel) and
//            (TSWFObject(ObjectList[il]).TagID = tagShowFrame) then
//          begin
//           Inc(FCurrentFrameNum);
//           if FCurrentFrameNum = Value then
//             begin
//               CurrentFramePosIndex := il;
//               Break;
//             end;
//          end;
      end;
   end;
end;

procedure TFlashMovie.SetHasMetadata(const Value: boolean);
begin
  GetFileAttributes.HasMetadata := Value;
end;

procedure TFlashMovie.SetMetadata(const Value: ansistring);
begin
  FMetaData := Value;
  HasMetadata := Value <> '';
  UseFileAttributes := true;
end;

procedure TFlashMovie.SetObjectList(const Value: TObjectList);
begin
  if FObjectList <> nil then FObjectList.Free;
  FObjectList := Value;
end;

procedure TFlashMovie.SetPassword(Value: string);
begin
  fProtect := true;
  fPassword := value;
end;

procedure TFlashMovie.SetTabIndex(Depth, TabIndex: word);
var
  TI: TSWFSetTabIndex;
begin
  TI := TSWFSetTabIndex.Create;
  TI.Depth := Depth;
  TI.TabIndex := TabIndex;
  AddFlashObject(TI);
end;

procedure TFlashMovie.SetUseFileAttributes(const Value: boolean);
begin
  FUseFileAttributes := Value;
  Version := SWFVer8;
end;

procedure TFlashMovie.SetUseNetwork(const Value: boolean);
begin
  GetFileAttributes.UseNetwork := Value;
  UseFileAttributes := true;
end;

procedure TFlashMovie.ShowFrame(c: word = 1);
var
  il: Integer;
begin
  if C = 0 then C := 1;
  
  if FrameLabel<>'' then
    begin
      ObjectList.Add(TSWFFrameLabel.Create(FrameLabel));
      FrameLabel := '';
    end;
  
  if fFrameActions <> nil then
     begin
      ObjectList.Add(fFrameActions);
      fFrameActions := nil;
     end;

  For il:=1 to C do
    begin
      SWFHeader.FramesCount := SWFHeader.FramesCount + 1;
      ObjectList.Add(TSWFShowFrame.Create);
    end;
  FCurrentFrameNum := SWFHeader.FramesCount - 1;
end;

function TFlashMovie.StartSound(snd: TFlashSound; Loop: word = 1): TSWFStartSound;
begin
  Result := StartSound(snd.CharacterID, Loop);
end;

function TFlashMovie.StartSound(ID: word; Loop: word = 1): TSWFStartSound;
begin
  Result := TSWFStartSound.Create;
  Result.SoundId := ID;
  AddFlashObject(Result);
end;

procedure TFlashMovie.StoreFrameActions;
begin
  if fFrameActions <> nil then
   begin
     AddFlashObject(fFrameActions);
     fFrameActions := nil;
   end;
end;

Procedure CreateEmptySWF(fn: string; bg: recRGB);
begin
 With TFlashMovie.Create(0,0,1,1,10) do
   begin
    BackgroundColor.RGB := bg;
    ShowFrame;
    MakeStream;
    SaveToFile(fn);
    free;
   end;
end;

end.

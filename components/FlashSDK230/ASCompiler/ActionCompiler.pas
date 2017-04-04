//*******************************************************//
//                                                       //
//                      DelphiFlash.com                  //
//         Copyright (c) 2004-2007 FeatherySoft, Inc.    //
//                    info@delphiflash.com               //
//                                                       //
//*******************************************************//

//  Description:  ActionScript Compiler for Flash level
//  Last update:  24 jun 2007

unit ActionCompiler;

{$WARN UNIT_PLATFORM OFF}
{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  SysUtils, Classes, Contnrs, SWFConst, FlashObjects, SWFObjects,
  StrTbl, IdentTbl, IdentTblVec, ParseTreeBase, ParseTreeStmt, ParseTreeDecl,
  ConstPool, IncSrc, StrVec;

const
  {<--}
  opAssign        =  1;
  opAssignAdd     =  2;
  opAssignSub     =  3;
  opAssignMult    =  4;
  opAssignDiv     =  5;
  opAssignModulo  =  6;
  opAssignBitAnd  =  7;
  opAssignBitXor  =  8;
  opAssignBitOr   =  9;
  opAssignLShift  = 10;
  opAssignSRShift = 11;
  opAssignURShift = 12;
  {-->}

type
(* moved to SWFConst.pas
  TCompileOption = (coLocalVarToRegister, coDefineFunction2, coFlashLite);
  TCompileOptions = set of TCompileOption;
*)
  TActionCommand = (
    acAdd,
    acAdd2,
    acAnd,
    acAsciiToChar,
    acBitAnd,
    acBitLShift,
    acBitOr,
    acBitRShift,
    acBitURShift,
    acBitXor,
    acCall,
    acCallFunction,
    acCallMethod,
    acCastOp,
    acCharToAscii,
    acCloneSprite,
    acConstantPool,
    acDecrement,
    acDefineFunction,
    acDefineFunction2,
    acDefineLocal,
    acDefineLocal2,
    acDelete,
    acDelete2,
    acDivide,
    acEndDrag,
    acEndFunction,
    acEnumerate2,
    acEquals,
    acEquals2,
    acExtends,
    acFSCommand,
    acFSCommand2,
    acGetMember,
    acGetProperty,
    acGetTime,
    acGetUrl2,
    acGetVariable,
    acGotoFrame,
    acGotoFrame2,
    acIf,
    acImplementsOp,
    acIncrement,
    acInitArray,
    acInitObject,
    acInstanceOf,
    acJump,
    acLess,
    acLess2,
    acListing,
    acMBAsciiToChar,
    acMBCharToAscii,
    acMBStringLength,
    acModulo,
    acMultiply,
    acNextFrame,
    acNewMethod,
    acNewObject,
    acNot,
    acOr,
    acPlay,
    acPop,
    acPreviousFrame,
    acPushBoolean,
    acPushConstant,
    acPushDouble,
    acPushDuplicate,
    acPushInteger,
    acPushNull,
    acPushRegister,
    acPushString,
    acPushUndefined,
    acRandomNumber,
    acRemoveSprite,
    acReturn,
    acSetMember,
    acSetProperty,
    acSetTarget2,
    acSetVariable,
    acStackSwap,
    acStartDrag,
    acStop,
    acStopSounds,
    acStoreRegister,
    acStrictEquals,
    acStringAdd,
    acStringEquals,
    acStringExtract,
    acStringLength,
    acStringLess,
    acSubtract,
    acThrow,
    acToInteger,
    acToNumber,
    acToString,
    acTry,
    acTypeOf,
    acWith);

  TCompileContext = class(TBaseCompileContext)
  private
    FClassTable: TClassTable;
    FCurCompileUnit: TCompileUnit;
    FOpenedStmt: INodeList;
    FScopeList: IScopeList;
    FLabelCounter: Integer;
    FSwfCode: TFlashActionScript;
    FCompileOptions: TCompileOptions;
    FSt: TStringTable;
    FIncludeSourceStack: IIncludeSourceStack;
    FIncludeSearchPaths: IStrVector;

    function GetLoopStmt: TLoopStmtNode;
    function GetSwitchStmt: TSwitchStmtNode;
    function GetCurScope: TIdentTable;

    function GetFlashButton: TFlashButton;
    function GetPlaceObject: TFlashPlaceObject;
    function GetConstantPool: TConstantPool;

    function GetParseTreeRoot: TParseTreeNode;
    procedure SetParseTreeRoot(Value: TParseTreeNode);

    procedure CompileUsedClasses;

    procedure Optimizing(AList: TObjectList);
  public
    constructor Create(owner: TFlashMovie); override;
    destructor Destroy; override;

    procedure LoadClassTable(ClassPath: string); override;
    procedure AddIncludePath(IncludePath: string); override;
    function OpenIncludeFile(IncFileName: string): TStream;

    procedure CompileAction(
      ASource: TStream;
      ASwfCode: TFlashActionScript); overload; override;

    procedure CompileAction(
      ASource: TStream;
      AFlashButton: TFlashButton); overload; override;

    procedure CompileAction(
      ASource: TStream;
      APlaceObject: TFlashPlaceObject); overload; override;

    function GetNextLabel: Integer;
    procedure AddToFreeList(AObject: TObject);
    procedure OpenLoopStmt(ALoopStmt: TLoopStmtNode);
    procedure CloseLoopStmt;
    procedure OpenSwitchStmt(ASwitchStmtNode: TSwitchStmtNode);
    procedure CloseSwitchStmt;

{$IFDEF DEBUG}
    function MarkStack: Integer;
    procedure CheckStack(StackMarker: Integer; Msg: string = '');
{$ENDIF}

    property LoopStmt: TLoopStmtNode read GetLoopStmt;
    property SwitchStmt: TSwitchStmtNode read GetSwitchStmt;

  public
    property ParseTreeRoot: TParseTreeNode
      read GetParseTreeRoot write SetParseTreeRoot;
    property SwfCode: TFlashActionScript read FSwfCode write FSwfCode;
    property FlashButton: TFlashButton read GetFlashButton;
    property PlaceObject: TFlashPlaceObject read GetPlaceObject;
    property ConstantPool: TConstantPool read GetConstantPool;
    property ClassTable: TClassTable read FClassTable;
    property CompileOptions: TCompileOptions
      read FCompileOptions write FCompileOptions;
    property StringTable: TStringTable read FSt;
    property IncludeSourceStack: IIncludeSourceStack read FIncludeSourceStack;

  public
    { Управление областями видимости. }
    procedure OpenScope(ScopeKind: TScopeKind);
    procedure CloseScope;
    property CurScope: TIdentTable read GetCurScope;
  end;

procedure WriteLabel(LabelNum: Integer);
procedure WriteComment(Comment: string);
procedure WriteLine(LineNum: Integer);

function WriteCmd(Cmd: TActionCommand; const Arg: Variant): TObject; overload;

function WriteCmd(Cmd: TActionCommand): TObject; overload;

function WriteCmd(Cmd: TActionCommand; RegNum: Integer;
  VarName: string): TObject; overload;

function WriteCmd(Cmd: TActionCommand; FuncNameId: TStrId;
  Args: TArgDeclListNode; RegisterCount: Integer): TObject; overload;

function WriteCmd(Cmd: TActionCommand;
  ConstantPool: TConstantPool): TObject; overload;

function Context: TCompileContext;
function SwfCode: TFlashActionScript;
function St: TStringTable;

implementation

uses
  Variants, Math, StrUtils, FileCtrl, LexLib, YaccLib, ActionCompilerLex,
  ActionCompilerYacc, ObjVec;

const
  NL = #13#10;

var
  _Context: TCompileContext;

procedure YaccParse(AInput: TStream);
begin
  YYInput := AInput;
  YYOutput := _Context.Listing;
  YYClear();
  if YYParse() <> 0 then
  begin
    if YYSrcFile = '' then
      raise EActionCompileError.CreateFmt('Parse Error in line: %d pos: %d',
        [YYLineNo, YYColNo + 1])
    else
      raise EActionCompileError.CreateFmt(
        'Parse Error in file: "%s" line: %d pos: %d',
        [YYSrcFile, YYLineNo, YYColNo + 1]);
  end;
end;

{ TCompileContext }

constructor TCompileContext.Create(owner: TFlashMovie);
begin
  inherited;
  FOpenedStmt := TNodeList.Create(False);
  FScopeList := TScopeList.Create(False);
  FClassTable := TClassTable.Create(nil, skGlobal);
  FLabelCounter := 1;
  FSt := TStringTable.Create;
  FIncludeSourceStack := TIncludeSourceStack.Create;
  FIncludeSearchPaths := TStrVector.Create;
  // FCompileOptions := [coFlashLite];
  FCompileOptions := [coLocalVarToRegister, coDefineFunction2];
end;

destructor TCompileContext.Destroy;
begin
  FreeAndNil(FClassTable);
  FreeAndNil(FSt);
  inherited Destroy;
end;

procedure TCompileContext.LoadClassTable(ClassPath: string);
begin
  _Context := Self;
  try
    FClassTable.LoadFromPackage(ClassPath);
  finally
    _Context := Self;
  end;
end;

procedure TCompileContext.AddIncludePath(IncludePath: string);
begin
  if not DirectoryExists(IncludePath) then
    raise EActionCompileError.CreateFmt('Include path "%s" not found.',
      [IncludePath]);
  IncludePath := IncludeTrailingPathDelimiter(LowerCase(IncludePath));
  if FIncludeSearchPaths.IndexOf(IncludePath) < 0 then
    FIncludeSearchPaths.Add(IncludePath);
end;

function TCompileContext.OpenIncludeFile(IncFileName: string): TStream;
var
  Drive, CurDir, IncFilePath: string;
  I: Integer;
begin
  IncFileName := StringReplace(IncFileName, '/', '\', [rfReplaceAll]);
  Drive := ExtractFileDrive(IncFileName);
  if Drive <> '' then
    // Указана буква диска. Абсолютный путь
    Result := TFileStream.Create(IncFileName, fmOpenRead)
  else
  begin
    // Буква диска не указана. Относительный путь.
    Result := nil;
    CurDir := GetCurrentDir;
    try
      for I := 0 to FIncludeSearchPaths.Count - 1 do
        if SetCurrentDir(FIncludeSearchPaths[I]) then
        begin
          IncFilePath := ExpandFileName(IncFileName);
          if FileExists(IncFilePath) then
          begin
            Result := TFileStream.Create(IncFilePath, fmOpenRead);
            Exit;
          end;
        end;
      raise EActionCompileError.CreateFmt('Include file "%s" not found.',
        [IncFileName]);
    finally
      SetCurrentDir(CurDir);
    end;
  end;
end;

procedure TCompileContext.CompileUsedClasses;
var
  PrevCompileUnit: TCompileUnit;

  procedure Parse;
  var
    I: Integer;
    Done: Boolean;
    ClassSource: TStream;
    DW: Longint;
  begin
    // Выполнить первый проход компилятора (парсинг) для всех используемых,
    // но еще не скомпилированных классов. Результат парсинга каждого класса
    // связываеться с записью TClassInfo из FClassTable
    repeat
      Done := True;
      for I := 0 to FClassTable.Items.Count - 1 do
        with FClassTable.Items[I] as TClassInfo do
          if (cifUsed in State) and (CompileUnit = nil) and not(cifIntrinsic in State) then
          begin
            Done := False;
            ClassSource := TFileStream.Create(SourceFile, fmOpenRead);
            // fix for Unicode standart classes
            DW := 0;
            ClassSource.Read(DW, 3);
            if DW <> $BFBBEF then ClassSource.Position := 0;
            
            CompileUnit := TCompileUnit.Create(nil);
            // Парсинг
            FCurCompileUnit := CompileUnit;
            try
              YaccParse(ClassSource);
            finally
              FreeAndNil(ClassSource);
            end;
          end;
    until Done;
  end;

  procedure GenerateClassCode(ClassInfo: TClassInfo);
  var
    SuperTypesList: TStrIdArray;
    SuperClassInfo: TClassInfo;
    I: Integer;
  begin
    // Проверить связь области имен текущего класса с областью имен базового
    // rкласса
    ClassInfo.CheckSuperClassLink;

    SuperTypesList := ClassInfo.GetSuperTypesList;
    for I := 0 to Length(SuperTypesList) - 1 do
    begin
      SuperClassInfo := FClassTable.FindClassIdent(SuperTypesList[I]);
      if not (cifCodeGenerated in SuperClassInfo.State) then
        GenerateClassCode(SuperClassInfo);
    end;

    FSwfCode := Movie.AddSprite.InitActions;
    FCurCompileUnit := ClassInfo.CompileUnit;
    FCurCompileUnit.ParseTreeRoot.Compile;
    WriteCmd(acConstantPool, FCurCompileUnit.ConstantPool);

    ClassInfo.State := ClassInfo.State + [cifCodeGenerated];
    FSwfCode := nil;
  end;

  procedure GenerateCode;
  var
    Done: Boolean;
    I: Integer;
    ClassInfo: TClassInfo;
  begin
    // Сгенрировать код для классов, учитывая порядок наследования:
    // cначала базовые классы, потом производные.
    repeat
      Done := True;
      for I := 0 to FClassTable.Items.Count - 1 do
      begin
        ClassInfo := FClassTable.Items[I] as TClassInfo;
        if ([cifUsed] = ClassInfo.State) then
        begin
          // Класс используеться, но код для класса еще не сгенерирован.
          // Генерировать код для класса
          GenerateClassCode(ClassInfo);
          Done := False;
        end;
      end;
    until Done;
  end;

begin
  PrevCompileUnit := FCurCompileUnit;
  try
    Parse;
    GenerateCode;
  finally
    FCurCompileUnit := PrevCompileUnit;
  end;
end;

procedure TCompileContext.CompileAction(
  ASource: TStream;
  ASwfCode: TFlashActionScript);
begin
  _Context := Self;
  FCurCompileUnit := TCompileUnit.Create(ASwfCode);
  try
    // Выполнить первый проход компилятора для Action.
    YaccParse(ASource);
    // выполнить первый проход компилятора для всех внешних(*.as) классов,
    // прямо или косвенно задействованных в текущей компилируемой Action
    CompileUsedClasses;
{$IFDEF DEBUG}
    FClassTable.WriteToListing;
{$ENDIF}
    // Выполнить генерацию кода для текущей Action.
    FSwfCode := ASwfCode;
    FCurCompileUnit.ParseTreeRoot.Compile;
    WriteCmd(acConstantPool, FCurCompileUnit.ConstantPool);
    Optimizing(ASwfCode.ActionList);
  finally
    FreeAndNil(FCurCompileUnit);
    _Context := nil;
  end;
end;

procedure TCompileContext.CompileAction(ASource: TStream; AFlashButton: TFlashButton);
  var il: TFlashButtonEvent;
      AL: TSWFActionList;
begin
  _Context := Self;
  FCurCompileUnit := TCompileUnit.Create(AFlashButton);
  try
    // Выполнить первый проход компилятора для Action.
    YaccParse(ASource);
    // выполнить первый проход компилятора для всех внешних(*.as) классов,
    // прямо или косвенно задействованных в текущей компилируемой Action
    CompileUsedClasses;
{$IFDEF DEBUG}
    FClassTable.WriteToListing;
{$ENDIF}
    // Выполнить генерацию кода для текущей Action.
    FCurCompileUnit.ParseTreeRoot.Compile;

    for il := low(TFlashButtonEvent) to high(TFlashButtonEvent) do
      begin
       AL := AFlashButton.FindActionEvent(il, false);
       if AL <> nil then Optimizing(AL);
      end;
  finally
    FreeAndNil(FCurCompileUnit);
    _Context := nil;
  end;
end;

procedure TCompileContext.CompileAction(ASource: TStream; APlaceObject: TFlashPlaceObject);
  var il: TSWFClipEvent;
      AR: TSWFClipActionRecord;
begin
  _Context := Self;
  FCurCompileUnit := TCompileUnit.Create(APlaceObject);
  try
    // Выполнить первый проход компилятора для Action.
    YaccParse(ASource);
    // выполнить первый проход компилятора для всех внешних(*.as) классов,
    // прямо или косвенно задействованных в текущей компилируемой Action
    CompileUsedClasses;
{$IFDEF DEBUG}
    FClassTable.WriteToListing;
{$ENDIF}
    // Выполнить генерацию кода для текущей Action.
    FCurCompileUnit.ParseTreeRoot.Compile;

    for il := low(TSWFClipEvent) to high(TSWFClipEvent) do
      begin
       AR := APlaceObject.FindActionEvent(il, false);
       if AR <> nil then Optimizing(AR.Actions);
      end;
  finally
    FreeAndNil(FCurCompileUnit);
    _Context := nil;
  end;
end;

function TCompileContext.GetLoopStmt: TLoopStmtNode;
begin
  Result := nil;
  if (FOpenedStmt.Count > 0)
    and (FOpenedStmt.Peek is TLoopStmtNode) then
  begin
    Result := FOpenedStmt.Peek as TLoopStmtNode;
  end;
end;

function TCompileContext.GetSwitchStmt: TSwitchStmtNode;
begin
  Result := nil;
  if (FOpenedStmt.Count > 0)
    and (FOpenedStmt.Peek is TSwitchStmtNode) then
  begin
    Result := TSwitchStmtNode(FOpenedStmt.Peek);
  end;
end;

function TCompileContext.GetCurScope: TIdentTable;
begin
  Result := nil;
  if FScopeList.Count > 0 then
    Result := FScopeList.Peek as TIdentTable;
end;

function TCompileContext.GetFlashButton: TFlashButton;
begin
  if FCurCompileUnit.CompileTarget is TFlashButton then
    Result := FCurCompileUnit.CompileTarget as TFlashButton
  else
    Result := nil;
end;

function TCompileContext.GetPlaceObject: TFlashPlaceObject;
begin
  if FCurCompileUnit.CompileTarget is TFlashPlaceObject then
    Result := FCurCompileUnit.CompileTarget as TFlashPlaceObject
  else
    Result := nil;
end;

function TCompileContext.GetConstantPool: TConstantPool;
begin
  Assert(FCurCompileUnit <> nil);
  Result := FCurCompileUnit.ConstantPool;
end;

function TCompileContext.GetParseTreeRoot: TParseTreeNode;
begin
  Result := FCurCompileUnit.ParseTreeRoot;
end;

procedure TCompileContext.SetParseTreeRoot(Value: TParseTreeNode);
begin
  FCurCompileUnit.ParseTreeRoot := Value;
end;

function TCompileContext.GetNextLabel: Integer;
begin
  Result := FLabelCounter;
  Inc(FLabelCounter);
end;

procedure TCompileContext.AddToFreeList(AObject: TObject);
begin
  FCurCompileUnit.AddToFreeList(AObject);
end;

procedure TCompileContext.OpenLoopStmt(ALoopStmt: TLoopStmtNode);
begin
  FOpenedStmt.Push(ALoopStmt);
end;

procedure TCompileContext.CloseLoopStmt;
begin
  FOpenedStmt.Pop;
end;

procedure TCompileContext.OpenSwitchStmt(ASwitchStmtNode: TSwitchStmtNode);
begin
  FOpenedStmt.Push(ASwitchStmtNode);
end;

procedure TCompileContext.Optimizing(AList: TObjectList);
 var il, ToTop, FunctionSize: integer;

 procedure moveToTop;
   var imove: integer;
 begin
   if (ToTop < il) and
      ((FunctionSize = (AList.Count - 1)) or (FunctionSize < (AList.Count - 1)) and
        not(TSWFAction(AList[FunctionSize + 1]).ActionCode in [actionSetMember, actionDefineLocal]))
   then
     for imove := il to FunctionSize do
     begin
       AList.Move(imove, ToTop);
       inc(ToTop);
     end;
 end;

begin
  // move function to top
  if AList.Count > 1 then
  begin
    ToTop := 0;
    for il := 0 to AList.Count - 1 do
    case TSWFAction(AList[il]).ActionCode of
    actionConstantPool: inc(ToTop);

    actionDefineFunction2:
      with TSWFActionDefineFunction2(AList[il]) do
      begin
        FunctionSize := AList.IndexOf(CodeSizeMarker);
        moveToTop;
      end;

    actionDefineFunction:
      with TSWFActionDefineFunction(AList[il]) do
      begin
        FunctionSize := AList.IndexOf(CodeSizeMarker);
        moveToTop;
      end;

    end;
  end;

  // remove not uses pop
  if AList.Count > 1 then
    begin
      il := 1;
      while il < AList.Count do
       begin
         if (TSWFAction(AList[il]).ActionCode = actionPop) and
            (TSWFAction(AList[il-1]).ActionCode = actionPush) and
            (TSWFActionPush(AList[il-1]).ValueCount = 1) then
           begin
             AList.Delete(il);
             AList.Delete(il-1);
             dec(il, 2);
           end else inc(il);
       end;
    end;
end;

procedure TCompileContext.CloseSwitchStmt;
begin
  FOpenedStmt.Pop;
end;

procedure TCompileContext.OpenScope(ScopeKind: TScopeKind);
begin
  if CurScope = nil then
    FScopeList.Push(TIdentTable.Create(FClassTable, ScopeKind))
  else
    FScopeList.Push(TIdentTable.Create(CurScope, ScopeKind));
end;

procedure TCompileContext.CloseScope;
begin
  FScopeList.Pop;
end;

{$IFDEF DEBUG}

function TCompileContext.MarkStack: Integer;
begin
  Result := RandomRange(1, 10000);
  SwfCode.Push(Format('StackControlLabel%d', [Result]));
end;

procedure TCompileContext.CheckStack(StackMarker: Integer; Msg: string);
var
  ContinueMarker: TSWFOffsetMarker;
begin
  SwfCode.Push(Format('StackControlLabel%d', [StackMarker]));
  SwfCode.Equals2;
  ContinueMarker := SwfCode._If.BranchOffsetMarker;
  SwfCode.Push('StackControlError');
  if Msg = '' then
    Msg := 'Error';
  SwfCode.Push(Msg);
  SwfCode.SetVariable;
  SwfCode.SetMarker(ContinueMarker);
end;

{$ENDIF}

procedure WriteLabel(LabelNum: Integer);
{$IFDEF DEBUG}
var
  LabelStr: string;
begin
  LabelStr := IntToStr(LabelNum) + ':' + NL;
  Context.Listing.Write(PChar(LabelStr)^, Length(LabelStr));
end;
{$ELSE}
begin
end;
{$ENDIF}

procedure WriteComment(Comment: string);
{$IFDEF DEBUG}
var
  CommentStr: string;
begin
  CommentStr := '//' + Comment + NL;
  Context.Listing.Write(PChar(CommentStr)^, Length(CommentStr));
end;
{$ELSE}
begin
end;
{$ENDIF}

procedure WriteLine(LineNum: Integer);
{$IFDEF DEBUG}
var
  LineStr: string;
begin
  LineStr := '# ' + IntToStr(LineNum) + NL;
  Context.Listing.Write(PChar(LineStr)^, Length(LineStr));
end;
{$ELSE}
begin
end;
{$ENDIF}

function WriteCmd(Cmd: TActionCommand; const Arg: Variant): TObject;
  overload;
var
  ConstId: Integer;
  ConstValue, S: string;
{$IFDEF DEBUG}
  CmdStr: string;
  ListingStmtNode: TListingStmtNode;
{$ENDIF}
begin
  Result := nil;

  case Cmd of
    acAdd:
      begin
        SwfCode.Add;
{$IFDEF DEBUG}
        CmdStr := 'Add';
{$ENDIF}
      end;

    acAdd2:
      begin
        SwfCode.Add2;
{$IFDEF DEBUG}
        CmdStr := 'Add2';
{$ENDIF}
      end;

    acAnd:
      begin
        SwfCode._And;
{$IFDEF DEBUG}
        CmdStr := 'And';
{$ENDIF}
      end;

    acAsciiToChar:
      begin
        SwfCode.AsciiToChar;
{$IFDEF DEBUG}
        CmdStr := 'AsciiToChar';
{$ENDIF}
      end;

    acBitAnd:
      begin
        SwfCode.BitAnd;
{$IFDEF DEBUG}
        CmdStr := 'BitAnd';
{$ENDIF}
      end;

    acBitLShift:
      begin
        SwfCode.BitLShift;
{$IFDEF DEBUG}
        CmdStr := 'LShift';
{$ENDIF}
      end;

    acBitRShift:
      begin
        SwfCode.BitRShift;
{$IFDEF DEBUG}
        CmdStr := 'RShift';
{$ENDIF}
      end;

    acBitOr:
      begin
        SwfCode.BitOr;
{$IFDEF DEBUG}
        CmdStr := 'BitOr';
{$ENDIF}
      end;

    acBitURShift:
      begin
        SwfCode.BitURShift;
{$IFDEF DEBUG}
        CmdStr := 'URShift';
{$ENDIF}
      end;

    acBitXor:
      begin
        SwfCode.BitXor;
{$IFDEF DEBUG}
        CmdStr := 'BitXor';
{$ENDIF}
      end;

    acCall:
      begin
        SwfCode.Call;
{$IFDEF DEBUG}
        CmdStr := 'Call';
{$ENDIF}
      end;

    acCallFunction:
      begin
        SwfCode.CallFunction;
{$IFDEF DEBUG}
        CmdStr := 'CallFunction';
{$ENDIF}
      end;

    acCallMethod:
      begin
        SwfCode.CallMethod;
{$IFDEF DEBUG}
        CmdStr := 'CallMethod';
{$ENDIF}
      end;

    acCastOp:
      begin
        SwfCode.CastOp;
{$IFDEF DEBUG}
        CmdStr := 'CastOp';
{$ENDIF}
      end;

    acCharToAscii:
      begin
        SwfCode.CharToAscii;
{$IFDEF DEBUG}
        CmdStr := 'CharToAscii';
{$ENDIF}
      end;

    acCloneSprite:
      begin
        SwfCode.CloneSprite;
{$IFDEF DEBUG}
        CmdStr := 'CloneSprite';
{$ENDIF}
      end;

    acDecrement:
      begin
        SwfCode.Decrement;
{$IFDEF DEBUG}
        CmdStr := 'Decrement';
{$ENDIF}
      end;

    acDefineLocal:
      begin
        SwfCode.DefineLocal;
{$IFDEF DEBUG}
        CmdStr := 'DefineLocal';
{$ENDIF}
      end;

    acDefineLocal2:
      begin
        SwfCode.DefineLocal2;
{$IFDEF DEBUG}
        CmdStr := 'DefineLocal2';
{$ENDIF}
      end;

    acDelete:
      begin
        SwfCode.Delete;
{$IFDEF DEBUG}
        CmdStr := 'Delete';
{$ENDIF}
      end;

    acDelete2:
      begin
        SwfCode.Delete2;
{$IFDEF DEBUG}
        CmdStr := 'Delete2';
{$ENDIF}
      end;

    acDivide:
      begin
        SwfCode.Divide;
{$IFDEF DEBUG}
        CmdStr := 'Divide';
{$ENDIF}
      end;

    acEndDrag:
      begin
        SwfCode.EndDrag;
{$IFDEF DEBUG}
        CmdStr := 'EndDrag';
{$ENDIF}
      end;

    acEndFunction:
      begin
{$IFDEF DEBUG}
        Assert(Arg <> Null);
        CmdStr := 'EndFunction ' + St[Arg] + #13#10;
{$ENDIF}
      end;

    acEnumerate2:
      begin
        SwfCode.Enumerate2;
{$IFDEF DEBUG}
        CmdStr := 'Enumerate2';
{$ENDIF}
      end;

    acEquals:
      begin
        SwfCode.Equals;
{$IFDEF DEBUG}
        CmdStr := 'Equals';
{$ENDIF}
      end;

    acEquals2:
      begin
        SwfCode.Equals2;
{$IFDEF DEBUG}
        CmdStr := 'Equals2';
{$ENDIF}
      end;

    acExtends:
      begin
        SwfCode.Extends;
{$IFDEF DEBUG}
        CmdStr := 'Extends';
{$ENDIF}
      end;

    acFSCommand:
      begin
        SwfCode.FSCommand(Arg[0], Arg[1]);
{$IFDEF DEBUG}
        CmdStr := Format('FSCommand "%s", "%s"',
          [VarToStr(Arg[0]), VarToStr(Arg[1])]);
{$ENDIF}
      end;

    acFSCommand2:
      begin
        SwfCode.ActionList.Add(TSWFActionFSCommand2.Create);
{$IFDEF DEBUG}
        CmdStr := 'FSCommand2';
{$ENDIF}
      end;

    acGetMember:
      begin
        SwfCode.GetMember;
{$IFDEF DEBUG}
        CmdStr := 'GetMember';
{$ENDIF}
      end;

    acGetProperty:
      begin
        SwfCode.GetProperty;
{$IFDEF DEBUG}
        CmdStr := 'GetProperty';
{$ENDIF}
      end;

    acGetTime:
      begin
        SwfCode.GetTime;
{$IFDEF DEBUG}
        CmdStr := 'GetTime';
{$ENDIF}
      end;

    acGetUrl2:
      begin
        SwfCode.GetUrl2(Arg[0], Arg[1], Arg[2]);
{$IFDEF DEBUG}
        CmdStr := 'GetUrl2';
{$ENDIF}
      end;

    acGetVariable:
      begin
        SwfCode.GetVariable;
{$IFDEF DEBUG}
        CmdStr := 'GetVariable';
{$ENDIF}
      end;

    acGotoFrame:
      begin
        SwfCode.GotoFrame(Arg);
{$IFDEF DEBUG}
        CmdStr := 'GotoFrame ' + VarToStr(Arg);
{$ENDIF}
      end;

    acGotoFrame2:
      begin
        SwfCode.GotoFrame2(Arg);
{$IFDEF DEBUG}
        CmdStr := 'GotoFrame2 ' + VarToStr(Arg);
{$ENDIF}
      end;

    acIncrement:
      begin
        SwfCode.Increment;
{$IFDEF DEBUG}
        CmdStr := 'Increment';
{$ENDIF}
      end;

    acInstanceOf:
      begin
        SwfCode.InstanceOf;
{$IFDEF DEBUG}
        CmdStr := 'InstanceOf';
{$ENDIF}
      end;

    acIf:
      begin
        Result := SwfCode._If;
{$IFDEF DEBUG}
        Assert(Arg <> Null);
        CmdStr := Format('If %d', [Integer(Arg)]);
{$ENDIF}
      end;

    acImplementsOp:
      begin
        SwfCode.ImplementsOp;
{$IFDEF DEBUG}
        CmdStr := 'ImplementsOp';
{$ENDIF}
      end;

    acInitArray:
      begin
        SwfCode.InitArray;
{$IFDEF DEBUG}
        CmdStr := 'InitArray';
{$ENDIF}
      end;

    acInitObject:
      begin
        SwfCode.InitObject;
{$IFDEF DEBUG}
        CmdStr := 'InitObject';
{$ENDIF}
      end;

    acJump:
      begin
        Result := SwfCode.Jump;
{$IFDEF DEBUG}
        Assert(Arg <> Null);
        CmdStr := Format('Jump %d', [Integer(Arg)]);
{$ENDIF}
      end;

    acLess:
      begin
        SwfCode.Less;
{$IFDEF DEBUG}
        CmdStr := 'Less';
{$ENDIF}
      end;

    acLess2:
      begin
        SwfCode.Less2;
{$IFDEF DEBUG}
        CmdStr := 'Less2';
{$ENDIF}
      end;

    acListing:
      begin
{$IFDEF DEBUG}
        Assert(Arg <> Null);
        ListingStmtNode := TListingStmtNode(Integer(Arg));
        WriteLine(ListingStmtNode.LineNum);
        if Trim(ListingStmtNode.Comment) <> '' then
          WriteComment(ListingStmtNode.Comment);
        Exit;
{$ENDIF}
      end;

    acMBAsciiToChar:
      begin
        SwfCode.MBAsciiToChar;
{$IFDEF DEBUG}
        CmdStr := 'AsciiToChar';
{$ENDIF}
      end;

    acMBCharToAscii:
      begin
        SwfCode.MBCharToAscii;
{$IFDEF DEBUG}
        CmdStr := 'MBCharToAscii';
{$ENDIF}
      end;

    acMBStringLength:
      begin
        SwfCode.MBStringLength;
{$IFDEF DEBUG}
        CmdStr := 'MBStringLength';
{$ENDIF}
      end;

    acModulo:
      begin
        SwfCode.Modulo;
{$IFDEF DEBUG}
        CmdStr := 'Modulo';
{$ENDIF}
      end;

    acMultiply:
      begin
        SwfCode.Multiply;
{$IFDEF DEBUG}
        CmdStr := 'Multiply';
{$ENDIF}
      end;

    acNextFrame:
      begin
        SwfCode.NextFrame;
{$IFDEF DEBUG}
        CmdStr := 'NextFrame';
{$ENDIF}
      end;

    acNewMethod:
      begin
        SwfCode.NewMethod;
{$IFDEF DEBUG}
        CmdStr := 'NewMethod';
{$ENDIF}
      end;

    acNewObject:
      begin
        SwfCode.NewObject;
{$IFDEF DEBUG}
        CmdStr := 'NewObject';
{$ENDIF}
      end;

    acNot:
      begin
        SwfCode._Not;
{$IFDEF DEBUG}
        CmdStr := 'Not';
{$ENDIF}
      end;

    acOr:
      begin
        SwfCode._Or;
{$IFDEF DEBUG}
        CmdStr := 'Or';
{$ENDIF}
      end;

    acPlay:
      begin
        SwfCode.Play;
{$IFDEF DEBUG}
        CmdStr := 'Play';
{$ENDIF}
      end;

    acPop:
      begin
        SwfCode.Pop;
{$IFDEF DEBUG}
        CmdStr := 'Pop';
{$ENDIF}
      end;

    acPreviousFrame:
      begin
        SwfCode.PreviousFrame;
{$IFDEF DEBUG}
        CmdStr := 'PreviousFrame';
{$ENDIF}
      end;

    acPushBoolean:
      begin
        Assert(Arg <> Null);
        if not (coFlashLite in Context.CompileOptions) then
          SwfCode.Push([Arg], [SWFConst.vtBoolean])
        else
        begin
          S := IfThen(Arg, '1', '0');
          SwfCode.Push([S], [SWFConst.vtString]);
        end;
{$IFDEF DEBUG}
        CmdStr := 'PushBoolean ' + IfThen(Arg = 0, 'False', 'True');
{$ENDIF}
      end;

    acPushConstant:
      begin
        Assert(Arg <> Null);
        if not (coFlashLite in Context.CompileOptions) then
        begin
          ConstId := Context.ConstantPool[Arg];
          SwfCode.PushConstant(ConstId);
        end
        else
        begin
          ConstValue := St[Arg];
          SwfCode.Push([ConstValue], [SWFConst.vtString]);
        end;
{$IFDEF DEBUG}
        CmdStr := Format('PushConstant %3d [%s]', [ConstId, St[Arg]]);
{$ENDIF}
      end;

    acPushDouble:
      begin
        Assert(Arg <> Null);
        if not (coFlashLite in Context.CompileOptions) then
          SwfCode.Push([Arg], [SWFConst.vtDouble])
        else
        begin
          S := FloatToStr(Arg);
          SwfCode.Push([S], [SWFConst.vtString]);
        end;
{$IFDEF DEBUG}
        CmdStr := Format('PushDbl %f', [Double(Arg)]);
{$ENDIF}
      end;

    acPushDuplicate:
      begin
        SwfCode.PushDuplicate;
{$IFDEF DEBUG}
        CmdStr := 'PushDuplicate';
{$ENDIF}
      end;

    acPushInteger:
      begin
        Assert(Arg <> Null);
        if not (coFlashLite in Context.CompileOptions) then
          SwfCode.Push([Arg], [SWFConst.vtInteger])
        else
        begin
          S := IntToStr(Arg);
          SwfCode.Push([S], [SWFConst.vtString]);
        end;
{$IFDEF DEBUG}
        CmdStr := Format('PushInt %d', [Integer(Arg)]);
{$ENDIF}
      end;

    acPushNull:
      begin
        SwfCode.Push([''], [SWFConst.vtNull]);
{$IFDEF DEBUG}
        CmdStr := 'PushNull';
{$ENDIF}
      end;

    acPushString:
      begin
        Assert(Arg <> Null);
        SwfCode.Push([Arg], [SWFConst.vtString]);
{$IFDEF DEBUG}
        CmdStr := Format('PushStr "%s"', [VarToStr(Arg)]);
{$ENDIF}
      end;

    acPushUndefined:
      begin
        SwfCode.Push([''], [SWFConst.vtUndefined]);
{$IFDEF DEBUG}
        CmdStr := 'PushUndefined';
{$ENDIF}
      end;

    acRandomNumber:
      begin
        SwfCode.RandomNumber;
{$IFDEF DEBUG}
        CmdStr := 'RandomNumber';
{$ENDIF}
      end;

    acRemoveSprite:
      begin
        SwfCode.RemoveSprite;
{$IFDEF DEBUG}
        CmdStr := 'RemoveSprite';
{$ENDIF}
      end;

    acReturn:
      begin
        SwfCode.Return;
{$IFDEF DEBUG}
        CmdStr := 'Return';
{$ENDIF}
      end;

    acSetMember:
      begin
        SwfCode.SetMember;
{$IFDEF DEBUG}
        CmdStr := 'SetMember';
{$ENDIF}
      end;

    acSetProperty:
      begin
        SwfCode.SetProperty;
{$IFDEF DEBUG}
        CmdStr := 'SetProperty';
{$ENDIF}
      end;

    acSetTarget2:
      begin
        SwfCode.SetTarget2;
{$IFDEF DEBUG}
        CmdStr := 'SetTarget2';
{$ENDIF}
      end;

    acSetVariable:
      begin
        SwfCode.SetVariable;
{$IFDEF DEBUG}
        CmdStr := 'SetVariable';
{$ENDIF}
      end;

    acStackSwap:
      begin
        SwfCode.StackSwap;
{$IFDEF DEBUG}
        CmdStr := 'StackSwap';
{$ENDIF}
      end;

    acStartDrag:
      begin
        SwfCode.StartDrag;
{$IFDEF DEBUG}
        CmdStr := 'StartDrag';
{$ENDIF}
      end;

    acStop:
      begin
        SwfCode.Stop;
{$IFDEF DEBUG}
        CmdStr := 'Stop';
{$ENDIF}
      end;

    acStopSounds:
      begin
        SwfCode.StopSounds;
{$IFDEF DEBUG}
        CmdStr := 'StopSounds';
{$ENDIF}
      end;

    acStrictEquals:
      begin
        SwfCode.StrictEquals;
{$IFDEF DEBUG}
        CmdStr := 'StrictEquals';
{$ENDIF}
      end;

    acStringAdd:
      begin
        SwfCode.StringAdd;
{$IFDEF DEBUG}
        CmdStr := 'StringAdd';
{$ENDIF}
      end;

    acStringEquals:
      begin
        SwfCode.StringEquals;
{$IFDEF DEBUG}
        CmdStr := 'StringEquals';
{$ENDIF}
      end;

    acStringExtract:
      begin
        SwfCode.StringExtract;
{$IFDEF DEBUG}
        CmdStr := 'StringExtract';
{$ENDIF}
      end;

    acStringLength:
      begin
        SwfCode.StringLength;
{$IFDEF DEBUG}
        CmdStr := 'StringLength';
{$ENDIF}
      end;

    acStringLess:
      begin
        SwfCode.StringLess;
{$IFDEF DEBUG}
        CmdStr := 'StringLess';
{$ENDIF}
      end;

    acSubtract:
      begin
        SwfCode.Subtract;
{$IFDEF DEBUG}
        CmdStr := 'Subtract';
{$ENDIF}
      end;

    acThrow:
      begin
        SwfCode.Throw;
{$IFDEF DEBUG}
        CmdStr := 'Throw';
{$ENDIF}
      end;

    acToInteger:
      begin
        SwfCode.ToInteger;
{$IFDEF DEBUG}
        CmdStr := 'ToInteger';
{$ENDIF}
      end;

    acToNumber:
      begin
        SwfCode.ToNumber;
{$IFDEF DEBUG}
        CmdStr := 'ToNumber';
{$ENDIF}
      end;

    acToString:
      begin
        SwfCode.ToString;
{$IFDEF DEBUG}
        CmdStr := 'ToString';
{$ENDIF}
      end;

    acTry:
      begin
        Result := SwfCode._Try;
{$IFDEF DEBUG}
        CmdStr := 'Try ' + VarToStr(Arg);
{$ENDIF}
      end;

    acTypeOf:
      begin
        SwfCode.TypeOf;
{$IFDEF DEBUG}
        CmdStr := 'TypeOf';
{$ENDIF}
      end;

    acWith:
      begin
        Result := SwfCode._With;
{$IFDEF DEBUG}
        CmdStr := Format('With %d', [Integer(Arg)]);
{$ENDIF}
      end;

  else
    raise EActionCompileError.Create('Unknown action command.');
  end;

{$IFDEF DEBUG}
  CmdStr := '  ' + CmdStr + NL;
  Context.Listing.Write(PChar(CmdStr)^, Length(CmdStr));
{$ENDIF}
end;

function WriteCmd(Cmd: TActionCommand): TObject; overload;
begin
  Result := WriteCmd(Cmd, Null);
end;

function WriteCmd(Cmd: TActionCommand; RegNum: Integer;
  VarName: string): TObject;
{$IFDEF DEBUG}
var
  CmdStr: string;
{$ENDIF}
begin
  Result := nil;
  case Cmd of
    acPushRegister:
      begin
        SwfCode.Push([RegNum], [SWFConst.vtRegister]);
{$IFDEF DEBUG}
        CmdStr := Format('PushReg %d [%s]', [RegNum, VarName]);
{$ENDIF}
      end;

    acStoreRegister:
      begin
        SwfCode.StoreRegister(RegNum);
{$IFDEF DEBUG}
        CmdStr := Format('StoreReg %d [%s]', [RegNum, VarName]);
{$ENDIF}
      end;

  else
    raise EActionCompileError.Create('Unknown action command.');
  end;

{$IFDEF DEBUG}
  CmdStr := '  ' + CmdStr + NL;
  Context.Listing.Write(PChar(CmdStr)^, Length(CmdStr));
{$ENDIF}
end;

function WriteCmd(Cmd: TActionCommand; FuncNameId: TStrId;
  Args: TArgDeclListNode; RegisterCount: Integer): TObject; overload;
var
  ActionDefineFunction2: TSWFActionDefineFunction2;
  ActionDefineFunction: TSWFActionDefineFunction;
  I: Integer;
  FuncName: string;
  ArgName: string;

{$IFDEF DEBUG}
  CmdStr, ArgNamesStr: string;
{$ENDIF}

begin
  case Cmd of
    acDefineFunction2:
      begin
        FuncName := St[FuncNameId];
        ActionDefineFunction2 := SwfCode.DefineFunction2(FuncName, [],
          RegisterCount);
        Result := ActionDefineFunction2;
        for I := 0 to Args.Count - 1 do
        begin
          ArgName := St[Args.Names[I]];
          if Args.Registers[I] >= 0 then
            ActionDefineFunction2.AddParam(ArgName, Args.Registers[I])
          else
            ActionDefineFunction2.AddParam(ArgName, 0)
        end;
{$IFDEF DEBUG}
        CmdStr := Format('DefineFunction %s ', [FuncName]);
        if Args.Count > 0 then
        begin
          ArgName := St[Args.Names[0]];
          ArgNamesStr := '(' + ArgName;
          for I := 1 to Args.Count - 1 do
          begin
            ArgName := St[Args.Names[I]];
            ArgNamesStr := ArgNamesStr + ', ' + ArgName;
          end;
          CmdStr := CmdStr + ArgNamesStr + ')';
        end;
{$ENDIF}
      end;

    acDefineFunction:
      begin
        FuncName := St[FuncNameId];
        ActionDefineFunction := SwfCode.DefineFunction(FuncName, []);
        Result := ActionDefineFunction;
        if Args <> nil then
          for I := 0 to Args.Count - 1 do
          begin
            ArgName := St[Args.Names[I]];
            ActionDefineFunction.Params.Add(ArgName);
          end;

{$IFDEF DEBUG}
        CmdStr := Format('DefineFunction %s ', [FuncName]);
        if (Args <> nil) and (Args.Count > 0) then
        begin
          ArgName := St[Args.Names[0]];
          ArgNamesStr := '(' + ArgName;
          for I := 1 to Args.Count - 1 do
          begin
            ArgName := St[Args.Names[I]];
            ArgNamesStr := ArgNamesStr + ', ' + ArgName;
          end;
          CmdStr := CmdStr + ArgNamesStr + ')';
        end;
{$ENDIF}
      end;

  else
    raise EActionCompileError.Create('Unknown action command.');
  end;

{$IFDEF DEBUG}
  CmdStr := '  ' + CmdStr + NL;
  Context.Listing.Write(PChar(CmdStr)^, Length(CmdStr));
{$ENDIF}
end;

function WriteCmd(Cmd: TActionCommand; ConstantPool: TConstantPool): TObject;
  overload;
var
  ActionConstantPool: TSWFActionConstantPool;
  I: Integer;
  StringTable: ConstPool.IVector;
{$IFDEF DEBUG}
  CmdStr: string;
{$ENDIF}
begin
  Result := nil;

  case Cmd of
    acConstantPool:
      if not (coFlashLite in Context.CompileOptions) then
      begin
        StringTable := ConstantPool.Items;
        if StringTable.Count = 0 then
          Exit;
        ActionConstantPool := SwfCode.ConstantPool([]);
        Result := ActionConstantPool;
        for I := 0 to StringTable.Count - 1 do
          ActionConstantPool.ConstantPool.Add(St[StringTable[I]]);
        // Переместить команду acActionPool на первое место в списке команд.
        with SwfCode.ActionList do
        begin
          Insert(0, nil);
          Exchange(0, Count - 1);
          Delete(Count - 1);
        end;
{$IFDEF DEBUG}
        CmdStr := '  ConstantPool' + NL;
        Context.Listing.Write(PChar(CmdStr)^, Length(CmdStr));
        for I := 0 to StringTable.Count - 1 do
        begin
          CmdStr := Format('  %-16s %d', [St[StringTable[I]], I]) + NL;
          Context.Listing.Write(PChar(CmdStr)^, Length(CmdStr));
        end;
        CmdStr := '  End ConstantPool' + NL;
        Context.Listing.Write(PChar(CmdStr)^, Length(CmdStr));
{$ENDIF}
      end;

  else
    raise EActionCompileError.Create('Unknown action command.');
  end;
end;

function Context: TCompileContext;
begin
  Result := _Context;
end;

function SwfCode: TFlashActionScript;
begin
  Assert(Context <> nil);
  Assert(Context.SwfCode <> nil);
  Result := Context.SwfCode;
end;

function St: TStringTable;
begin
  Assert(Context <> nil);
  Assert(Context.StringTable <> nil);
  Result := Context.StringTable;
end;

end.


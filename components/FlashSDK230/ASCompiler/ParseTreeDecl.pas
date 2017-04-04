//*******************************************************//
//                                                       //
//                      DelphiFlash.com                  //
//         Copyright (c) 2004-2006 FeatherySoft, Inc.    //
//                    info@delphiflash.com               //
//                                                       //
//*******************************************************//

//  Description:  ActionScript compiler
//  Last update:  22 oct 2006

unit ParseTreeDecl;

interface

uses
  SysUtils, Classes, Contnrs, FlashObjects, SWFObjects, SWFConst, IdentTbl,
  StrTbl, ParseTreeBase, ParseTreeExpr, ParseTreeStmt;

type
  TFlashEventKind = (fekButton, fekClip, fekKeyPress);
  TClassDefNode = class;

  TVarDeclNode = class(TParseTreeNode)
  private
    FInitExpr: TParseTreeNode;
    FIdentInfo: TIdentInfo;
  public
    constructor Create(AIdentId, ATypeNameId: TStrId;
      AInitExpr: TParseTreeNode);
    procedure Compile; override;
  end;

  TVarDeclListNode = class(TParseTreeNode)
  private
    FIsStaticFieldList: Boolean;
    FVarDeclList: INodeList;
  public
    constructor Create(AVarDecl: TVarDeclNode);
    procedure Add(AVarDecl: TVarDeclNode);
    procedure SetIdentFlags(AIdentFlags: TIdentFlags);
    procedure Compile; override;
  end;

  TArgDeclNode = class(TParseTreeNode)
  private
    FNameInfo: TIdentInfo;
  public
    constructor Create(ANameId, ATypeNameId: TStrId);
    property NameInfo: TIdentInfo read FNameInfo;
  end;

  TArgDeclListNode = class(TParseTreeNode)
  private
    FItems: INodeList;
    function GetName(I: Integer): TStrId;
    function GetTypeName(I: Integer): TStrId;
    function GetRegister(I: Integer): Integer;
    function GetCount: Integer;
  public
    constructor Create;
    procedure Add(AArgDecl: TArgDeclNode);
    property Names[I: Integer]: TStrId read GetName;
    property TypeNames[I: Integer]: TStrId read GetTypeName;
    property Registers[I: Integer]: Integer read GetRegister;
    property Count: Integer read GetCount;
  end;

  TFuncDefNode = class(TParseTreeNode)
  private
    FFuncNameId, FTypeNameId: TStrId;
    FArgs: TArgDeclListNode;
    FBody: TParseTreeNode;
    FIdentTable: TIdentTable;
    FFuncIdentInfo: TIdentInfo;
    function GetMethodNameId: TStrId;
    procedure InitPreloadFlags(DefFunc2: TSWFActionDefineFunction2);
    procedure CompileBody;
    procedure CompileConstructor(FieldList: INodeList; CallSuper: Boolean);
    property MethodNameId: TStrId read GetMethodNameId;

  public
    constructor Create(
      AFuncNameId: TStrId; AArgs: TArgDeclListNode;
      ATypeNameId: TStrId; ABody: TParseTreeNode); overload;

    constructor Create(AArgs: TArgDeclListNode;
      ATypeNameId: TStrId; ABody: TParseTreeNode); overload;

    procedure SetIdentFlags(AIdentFlags: TIdentFlags);
    procedure Compile; override;
    property FuncIdentInfo: TIdentInfo read FFuncIdentInfo write FFuncIdentInfo;
  end;

  TEventListNode = class(TParseTreeNode)
  private
    FEvents: INodeList;
    FKind: TFlashEventKind;
    FFlashButtonEvents: TFlashButtonEvents;
    FClipEvents: TSWFClipEvents;
    FKeyCode: string;
    procedure InitSwfCode;
    procedure FreeSwfCode;
  public
    constructor Create(AEvent: TPairNode);
    procedure Add(AEvent: TPairNode);
    procedure Compile; override;
    property Kind: TFlashEventKind read FKind write FKind;
  end;

  TProgramNode = class(TParseTreeNode)
  private
    FEvents: TEventListNode;
    FProgItems: INodeList;
    FIdentTable: TIdentTable;
    procedure SetEvents(AEvents: TEventListNode);
  public
    constructor Create(AItem: TParseTreeNode);
    procedure Add(AItem: TParseTreeNode);
    procedure Compile; override;
    function FindClassDefNode: TClassDefNode;
    property Events: TEventListNode read FEvents write SetEvents;
  end;

  TClassBodyNode = class(TParseTreeNode)
  private
    FFieldList, FMethodList: INodeList;
    function GetConstructor(AClassNameId: TStrId): TFuncDefNode;
  public
    constructor Create(AMember: TParseTreeNode);
    procedure Add(AMember: TParseTreeNode);
    procedure Compile; override;
  end;

  TClassImplListNode = class(TParseTreeNode)
  private
    FIntfList: INodeList;
    function GetCount: Integer;
    function GetItem(I: Integer): TCompoundName;
  public
    constructor Create(AIntfName: TCompoundName);
    procedure Add(AIntfName: TCompoundName);
    property Count: Integer read GetCount;
    property Items[I: Integer]: TCompoundName read GetItem; default;
  end;

  TClassDefNode = class(TParseTreeNode)
  private
    FName: TCompoundName;
    FSuperName: TCompoundName;
    FIdentTable: TIdentTable;
  protected
    procedure CreatePackages;
    property IdentTable: TIdentTable read FIdentTable;
  public
    constructor Create(AName, ASuperName: TCompoundName;
      AIdentTable: TIdentTable);
    class procedure ProcessHeader(AName: TCompoundName;
      var ASuperName: TCompoundName);
    function GetSuperTypesList: TStrIdArray; virtual;
    procedure CheckSuperClassLink;
    property Name: TCompoundName read FName;
    property SuperName: TCompoundName read FSuperName;
  end;

  TClassImplNode = class(TClassDefNode)
  private
    FBody: TClassBodyNode;
    FImplList: TClassImplListNode;
    FConstructor: TFuncDefNode;
    FEndClassMarker: TSWFOffsetMarker;
    FEndClassLabel: Integer;
    procedure CreateConstructor;
    procedure Extends;
    procedure ImplementsInterfaces;
    procedure CompileStaticMembers;
  public
    constructor Create(AName, ASuperName: TCompoundName;
      AImplList: TClassImplListNode; ABody: TClassBodyNode);
    function GetSuperTypesList: TStrIdArray; override;
    procedure Compile; override;
    property ImplList: TClassImplListNode read FImplList;
  end;

  TIntfBodyNode = class(TParseTreeNode)
  end;

  TClassIntfNode = class(TClassDefNode)
  private
    FBody: TIntfBodyNode;
    FEndClassMarker: TSWFOffsetMarker;
    FEndClassLabel: Integer;
    procedure CreateConstructor;
    procedure Extends;
  public
    constructor Create(AName, ASuperName: TCompoundName;
      ABody: TIntfBodyNode);
    procedure Compile; override;
  end;

  TImportNode = class(TParseTreeNode)
  private
    FName: TCompoundName;
  public
    constructor Create(AName: TCompoundName);
    procedure ImportClass;
    procedure ImportPackage;
    procedure Compile; override;
  end;

implementation

uses
  Math, Variants, LexLib, YaccLib, ActionCompilerLex, ActionCompilerYacc,
  ActionCompiler, ObjVec, StrVec, IntPtrDict;

{ TVarDeclNode }

constructor TVarDeclNode.Create(AIdentId, ATypeNameId: TStrId;
  AInitExpr: TParseTreeNode);
begin
  inherited Create;
  FInitExpr := AInitExpr;
  FIdentInfo := Context.CurScope.AddIdent(AIdentId, ATypeNameId);
  if (FInitExpr <> nil) and (FInitExpr is TFuncDefNode) then
    FIdentInfo.RegisterNum := -1;
  Include(FIdentInfo.Flags, idVar);
end;

procedure TVarDeclNode.Compile;

  procedure InitMember;
  begin
    if (FInitExpr <> nil) and not (idStatic in FIdentInfo.Flags) then
    begin
      WriteCmd(acPushRegister, 1, 'this'); // this всегда получает регистр #1
      WriteCmd(acPushConstant, FIdentInfo.IdentId);
      FInitExpr.SetFlag(nfClassMember);
      FInitExpr.Compile;
      WriteCmd(acSetMember);
    end
    else if (FInitExpr <> nil) and (idStatic in FIdentInfo.Flags) then
    begin
      // регистр №1 содержит объект конструктор
      // см. TClassImplNode.Compile
      WriteCmd(acPushRegister, 1, 'tmp constructor object reg');
      WriteCmd(acPushConstant, FIdentInfo.IdentId);
      FInitExpr.SetFlag(nfClassMember);
      FInitExpr.Compile;
      WriteCmd(acSetMember);
    end;
  end;

  procedure DeclLocalVar;
  begin
    if FIdentInfo.RegisterNum > 0 then
    begin
      // Объявление локальной регистровой переменной
      if FInitExpr <> nil then
      begin
        FInitExpr.Compile;
        with FIdentInfo do
          WriteCmd(acStoreRegister, RegisterNum, St[IdentId]);
        WriteCmd(acPop);
      end
    end
    else
    begin
      // Объявление локальной именованной переменной
      WriteCmd(acPushConstant, FIdentInfo.IdentId);
      if FInitExpr = nil then
        WriteCmd(acDefineLocal2)
      else
      begin
        FInitExpr.Compile;
        WriteCmd(acDefineLocal);
      end;
    end;
  end;

begin
  if nfClassMember in Flags then
    InitMember
  else
    DeclLocalVar;
end;

{ TVarDeclListNode }

constructor TVarDeclListNode.Create(AVarDecl: TVarDeclNode);
begin
  inherited Create;
  FVarDeclList := TNodeList.Create(False);
  Add(AVarDecl);
  FIsStaticFieldList := False;
end;

procedure TVarDeclListNode.Add(AVarDecl: TVarDeclNode);
begin
  if AVarDecl <> nil then
    FVarDeclList.Add(AVarDecl);
end;

procedure TVarDeclListNode.SetIdentFlags(AIdentFlags: TIdentFlags);
var
  I: Integer;
  VarDeclNode: TVarDeclNode;
begin
  for I := 0 to FVarDeclList.Count - 1 do
  begin
    VarDeclNode := FVarDeclList[I] as TVarDeclNode;
    Assert(VarDeclNode.FIdentInfo <> nil);
    with VarDeclNode.FIdentInfo do
      Flags := Flags + AIdentFlags;
  end;

  if idStatic in AIdentFlags then
    FIsStaticFieldList := True;
end;

procedure TVarDeclListNode.Compile;
var
  I: Integer;
  VarDeclNode: TParseTreeNode;
begin
  for I := 0 to FVarDeclList.Count - 1 do
  begin
    VarDeclNode := FVarDeclList[I];
    if nfClassMember in Flags then
      VarDeclNode.SetFlag(nfClassMember);
    VarDeclNode.Compile;
  end;
end;

{ TArgDeclNode }

constructor TArgDeclNode.Create(ANameId, ATypeNameId: TStrId);
begin
  inherited Create;
  Assert(Context.CurScope.ScopeKind = skLocal);
  FNameInfo := Context.CurScope.AddIdent(ANameId, ATypeNameId);
  Include(FNameInfo.Flags, idVar);
end;

{ TArgDeclListNode }

constructor TArgDeclListNode.Create;
begin
  inherited Create;
  FItems := TNodeList.Create(False);
end;

procedure TArgDeclListNode.Add(AArgDecl: TArgDeclNode);
begin
  if AArgDecl <> nil then
    FItems.Add(AArgDecl);
end;

function TArgDeclListNode.GetName(I: Integer): TStrId;
begin
  Result := (FItems[I] as TArgDeclNode).NameInfo.IdentId;
end;

function TArgDeclListNode.GetTypeName(I: Integer): TStrId;
begin
  Result := (FItems[I] as TArgDeclNode).NameInfo.TypeNameId;
end;

function TArgDeclListNode.GetRegister(I: Integer): Integer;
begin
  Result := (FItems[I] as TArgDeclNode).NameInfo.RegisterNum;
end;

function TArgDeclListNode.GetCount: Integer;
begin
  Result := FItems.Count;
end;

{ TFuncDefNode }

constructor TFuncDefNode.Create(AFuncNameId: TStrId; AArgs: TArgDeclListNode;
  ATypeNameId: TStrId; ABody: TParseTreeNode);
begin
  inherited Create;
  FFuncNameId := AFuncNameId;
  FArgs := AArgs;
  FTypeNameId := ATypeNameId;
  FBody := ABody;
  FIdentTable := Context.CurScope;
  Assert(FIdentTable.ScopeKind = skLocal);
end;

constructor TFuncDefNode.Create(AArgs: TArgDeclListNode;
  ATypeNameId: TStrId; ABody: TParseTreeNode);
begin
  Create(St.AddItem(''), AArgs, ATypeNameId, ABody);
end;

procedure TFuncDefNode.InitPreloadFlags(DefFunc2: TSWFActionDefineFunction2);
begin
  if pfThis in FIdentTable.PreloadFlags then
    DefFunc2.PreloadThisFlag := True
  else
    DefFunc2.SuppressThisFlag := True;

  if pfArguments in FIdentTable.PreloadFlags then
    DefFunc2.PreloadArgumentsFlag := True
  else
    DefFunc2.SuppressArgumentsFlag := True;

  if pfSuper in FIdentTable.PreloadFlags then
    DefFunc2.PreloadSuperFlag := True
  else
    DefFunc2.SuppressSuperFlag := True;
end;

procedure TFuncDefNode.CompileBody;
begin
  if FBody <> nil then
    FBody.Compile;
end;

procedure TFuncDefNode.Compile;

  procedure CompileFunc2;
  var
    EndFuncMarker: TSWFOffsetMarker;
    CompileFuncNameId: TStrId;
    DefFunc2: TSWFActionDefineFunction2;
  begin
    CompileFuncNameId := FFuncNameId;

    if nfClassMember in Flags then
    begin
      CompileFuncNameId := St.EmptyStrId;
      // Если функция - член класса в стиле ActionScript 2.0, то
      // принудительно установить флаг pfThis ввиду неявного обращения к полям
      // класса через this
      FIdentTable.SetPreloadFlag(pfThis);
    end;

    // Назначить регистры локальным параметрам и переменным
    FIdentTable.AssignRegisters;

    DefFunc2 := WriteCmd(acDefineFunction2, CompileFuncNameId, FArgs,
      FIdentTable.RegisterCount) as TSWFActionDefineFunction2;

    InitPreloadFlags(DefFunc2);

    EndFuncMarker := DefFunc2.CodeSizeMarker;

{$IFDEF DEBUG}
    FIdentTable.DebugName := 'Func ' + St[MethodNameId];
    FIdentTable.WriteToListing;
{$ENDIF}

    CompileBody;

    SwfCode.SetMarker(EndFuncMarker);
    WriteCmd(acEndFunction, CompileFuncNameId);
  end;

  procedure CompileFunc;
  var
    EndFuncMarker: TSWFOffsetMarker;
    DefFunc: TSWFActionDefineFunction;
  begin
    DefFunc := WriteCmd(acDefineFunction, FFuncNameId, FArgs, 0) as
      TSWFActionDefineFunction;
    EndFuncMarker := DefFunc.CodeSizeMarker;

{$IFDEF DEBUG}
    FIdentTable.DebugName := 'Func ' + St[MethodNameId];
    FIdentTable.WriteToListing;
{$ENDIF}

    CompileBody;

    SwfCode.SetMarker(EndFuncMarker);
    WriteCmd(acEndFunction, FFuncNameId);
  end;

begin
  if coDefineFunction2 in Context.CompileOptions then
    CompileFunc2
  else
    CompileFunc;
end;

procedure TFuncDefNode.CompileConstructor(
  FieldList: INodeList;
  CallSuper: Boolean);
var
  EndFuncMarker: TSWFOffsetMarker;
  I: Integer;
  DefFunc2: TSWFActionDefineFunction2;
  SuperIdentInfo: TIdentInfo;
begin
  FIdentTable.SetPreloadFlag(pfThis);
  FIdentTable.SetPreloadFlag(pfSuper);
  FIdentTable.AssignRegisters;

  DefFunc2 := WriteCmd(acDefineFunction2, St.EmptyStrId, FArgs,
    FIdentTable.RegisterCount) as TSWFActionDefineFunction2;

  InitPreloadFlags(DefFunc2);

  EndFuncMarker := DefFunc2.CodeSizeMarker;

{$IFDEF DEBUG}
  FIdentTable.DebugName := 'Func ' + St[MethodNameId];
  FIdentTable.WriteToListing;
{$ENDIF}

  if CallSuper and FIdentTable.ImplicitSuperCall then
  begin
    SuperIdentInfo := FIdentTable.FindIdent(St.SuperStrId, [fioInParent]);
    Assert(SuperIdentInfo.ScopeKind = skLocal);
    WriteCmd(acPushInteger, 0);
    WriteCmd(acPushRegister, SuperIdentInfo.RegisterNum, 'super');
    WriteCmd(acPushUndefined);
    WriteCmd(acCallMethod);
    WriteCmd(acPop);
  end;

  // Инициализация полей.
  for I := 0 to FieldList.Count - 1 do
    with FieldList[I] as TVarDeclListNode do
    begin
      if not FIsStaticFieldList then
        Compile;
    end;

  CompileBody;

  SwfCode.SetMarker(EndFuncMarker);
  WriteCmd(acEndFunction, FFuncNameId);
end;

function TFuncDefNode.GetMethodNameId: TStrId;
begin
  if nfGetProp in Flags then
    Result := St.AddItem('__get__' + St[FFuncNameId])
  else if nfSetProp in Flags then
    Result := St.AddItem('__set__' + St[FFuncNameId])
  else
    Result := FFuncNameId;
end;

procedure TFuncDefNode.SetIdentFlags(AIdentFlags: TIdentFlags);
begin
  Assert(FuncIdentInfo <> nil);
  FuncIdentInfo.Flags := FuncIdentInfo.Flags + AIdentFlags;
end;

{ TEventListNode }

constructor TEventListNode.Create(AEvent: TPairNode);
begin
  inherited Create;
  FEvents := TNodeList.Create(False);
  Add(AEvent);
end;

procedure TEventListNode.Add(AEvent: TPairNode);
begin
  if AEvent <> nil then
    FEvents.Add(AEvent);
end;

procedure TEventListNode.Compile;

  function ConvertButtonEvent(ButtonEventStr: string): TFlashButtonEvent;
  const
    ButtonEventNameMap: array[TFlashButtonEvent] of string = (
      'rollOver',
      'rollOut',
      'press',
      'release',
      'dragOver',
      'dragOut',
      'releaseOutside',
      'menuDragOver',
      'menuDragOut'
      );
  var
    Be: TFlashButtonEvent;
  begin
    for Be := Low(TFlashButtonEvent) to High(TFlashButtonEvent) do
      if ButtonEventStr = ButtonEventNameMap[Be] then
      begin
        Result := Be;
        Exit;
      end;
    raise EActionCompileError.CreateFmt(
      'Unknown button event: %s in line %d',
      [ButtonEventStr, SrcPos.Line]);
  end;

  function ConvertClipEvent(ClipEventStr: string): TSWFClipEvent;
  const
    ClipEventNameMap: array[TSWFClipEvent] of string = (
      'keyUp',
      'keyDown',
      'mouseUp',
      'mouseDown',
      'mouseMove',
      'unload',
      'enterFrame',
      'load',
      'dragOver',
      'rollOut',
      'rollOver',
      'releaseOutside',
      'release',
      'press',
      'initialize',
      'data',
      'construct',
      'keyPress',
      'dragOut'
      );
  var
    Ce: TSWFClipEvent;
  begin
    for Ce := Low(TSWFClipEvent) to High(TSWFClipEvent) do
      if ClipEventStr = ClipEventNameMap[Ce] then
      begin
        Result := Ce;
        Exit;
      end;
    raise EActionCompileError.CreateFmt(
      'Unknown clip event: %s in line %d',
      [ClipEventStr, SrcPos.Line]);
  end;

var
  EventNode: TPairNode;
  EventName: string;
  I: Integer;
begin
  if Kind = fekButton then
    for I := 0 to FEvents.Count - 1 do
    begin
      EventNode := FEvents[I] as TPairNode;
      EventName := St[(EventNode.First as TStrNode).StrId];
      Include(FFlashButtonEvents, ConvertButtonEvent(EventName));
      if EventNode.Second <> nil then
      begin
        Kind := fekKeyPress;
        FKeyCode := St[(EventNode.Second as TStrNode).StrId];
        Break;
      end;
    end
  else
    for I := 0 to FEvents.Count - 1 do
    begin
      EventNode := FEvents[I] as TPairNode;
      EventName := St[(EventNode.First as TStrNode).StrId];
      Include(FClipEvents, ConvertClipEvent(EventName));
      if EventNode.Second <> nil then
      begin
        Kind := fekKeyPress;
        FKeyCode := St[(EventNode.Second as TStrNode).StrId];
        Break;
      end;
    end;
end;

type
  AKeyCodeRec = Record
    Code: byte;
    Name: PChar;
  end;

function GetKeyCode(code: string): byte;
var il: integer;
const
  ACodes: array [0..24] of AKeyCodeRec = (
     (Code: 13;   Name: '<Enter>'),   // flash lite
     (Code: 14;   Name: '<Up>'),
     (Code: 15;   Name: '<Down>'),
     (Code: 1;    Name: '<Left>'),
     (Code: 2;    Name: '<Right>'),
     (Code: 16;   Name: '<PageUp>'),
     (Code: 17;   Name: '<PageDown>'),
     (Code: 8;    Name: 'Key.BACKSPACE'),  // up flash 6
     (Code: 20;    Name: 'Key.CAPSLOCK'),
     (Code: 17;    Name: 'Key.CONTROL'),
     (Code: 46;    Name: 'Key.DELETEKEY'),
     (Code: 40;    Name: 'Key.DOWN'),
     (Code: 35;    Name: 'Key.END'),
     (Code: 13;    Name: 'Key.ENTER'),
     (Code: 27;    Name: 'Key.ESCAPE'),
     (Code: 36;    Name: 'Key.HOME'),
     (Code: 45;    Name: 'Key.INSERT'),
     (Code: 37;    Name: 'Key.LEFT'),
     (Code: 34;    Name: 'Key.PGDN'),
     (Code: 33;    Name: 'Key.PGUP'),
     (Code: 39;    Name: 'Key.RIGHT'),
     (Code: 16;    Name: 'Key.SHIFT'),
     (Code: 32;    Name: 'Key.SPACE'),
     (Code: 9;     Name: 'Key.TAB'),
     (Code: 38;    Name: 'Key.UP')
     );
begin
  Result := 0;
  if Length(code) = 1
    then
      Result := Ord(code[1])
    else
    for il := 0 to 24 do
     if ACodes[il].Name = code then
       begin
         Result := ACodes[il].Code;
         Break;
       end;
end;

procedure TEventListNode.InitSwfCode;
var
  FlashButton: TFlashButton;
  PlaceObject: TFlashPlaceObject;
  ActionList: TSWFActionList;
  ButtonCondAction: TSWFButtonCondAction;
  ClipActionRecord: TSWFClipActionRecord;
begin
  case Kind of
    fekButton:
      begin
        FlashButton := Context.FlashButton;
        if FlashButton = nil then
        begin
          raise EActionCompileError.CreateFmt(
            'Invalid event handler type in line %d', [SrcPos.Line]);
        end;

        ActionList := FlashButton.AddCondAction(FFlashButtonEvents);
        Context.SwfCode := TFlashActionScript.Create(FlashButton.Owner,
          ActionList);
      end;

    fekClip:
      begin
        PlaceObject := Context.PlaceObject;
        if PlaceObject = nil then
        begin
          raise EActionCompileError.CreateFmt(
            'Invalid event handler type in line %d', [SrcPos.Line]);
        end;

        ActionList := PlaceObject.AddActionEvent(FClipEvents);
        Context.SwfCode := TFlashActionScript.Create(PlaceObject.Owner,
          ActionList);
      end;

    fekKeyPress:
      begin
        if Context.FlashButton <> nil then
        begin
          ButtonCondAction := Context.FlashButton.AddCondAction([]);
          ButtonCondAction.ID_Key := GetKeyCode(FKeyCode);
          Context.SwfCode := TFlashActionScript.Create(
            Context.FlashButton.Owner,
            ButtonCondAction);
        end
        else if Context.PlaceObject <> nil then
        begin
          ClipActionRecord := Context.PlaceObject.AddActionEvent([]);
          ClipActionRecord.KeyCode := GetKeyCode(FKeyCode);
          Context.SwfCode := TFlashActionScript.Create(
            Context.PlaceObject.Owner,
            ClipActionRecord);
        end
        else
          Assert(False);
      end;
  end;
end;

procedure TEventListNode.FreeSwfCode;
begin
  Context.SwfCode.Free;
  Context.SwfCode := nil;
end;

{ TProgramNode }

constructor TProgramNode.Create(AItem: TParseTreeNode);
begin
  inherited Create;
  FProgItems := TNodeList.Create(False);
  FIdentTable := Context.CurScope;
  Assert(FIdentTable.ScopeKind = skGlobal);
  Add(AItem);
{$IFDEF DEBUG}
  FIdentTable.DebugName := 'Program ';
{$ENDIF}
end;

procedure TProgramNode.Add(AItem: TParseTreeNode);
begin
  if AItem <> nil then
    FProgItems.Add(AItem);
end;

procedure TProgramNode.SetEvents(AEvents: TEventListNode);
begin
  FEvents := AEvents;
  FEvents.Compile;
end;

procedure TProgramNode.Compile;
var
  I: Integer;
begin
  if FEvents <> nil then
    FEvents.InitSwfCode;

{$IFDEF DEBUG}
  FIdentTable.WriteToListing;
{$ENDIF}

  for I := 0 to FProgItems.Count - 1 do
    FProgItems[I].Compile;

  if FEvents <> nil then
  begin
    WriteCmd(acConstantPool, Context.ConstantPool);
    FEvents.FreeSwfCode;
  end;
end;

function TProgramNode.FindClassDefNode: TClassDefNode;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FProgItems.Count - 1 do
    if FProgItems[I] is TClassDefNode then
    begin
      Result := FProgItems[I] as TClassDefNode;
      Exit;
    end;
end;

{ TClassBodyNode }

constructor TClassBodyNode.Create(AMember: TParseTreeNode);
begin
  inherited Create;
  FFieldList := TNodeList.Create(False);
  FMethodList := TNodeList.Create(False);
  Add(AMember);
end;

function TClassBodyNode.GetConstructor(AClassNameId: TStrId): TFuncDefNode;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FMethodList.Count - 1 do
    with FMethodList[I] as TFuncDefNode do
      if FFuncNameId = AClassNameId then
      begin
        Result := FMethodList[I] as TFuncDefNode;
        FMethodList.Remove(Result);
        Break;
      end;
end;

procedure TClassBodyNode.Add(AMember: TParseTreeNode);
begin
  if AMember <> nil then
  begin
    AMember.SetFlag(nfClassMember);
    if AMember is TVarDeclListNode then
      FFieldList.Add(AMember)
    else if AMember is TFuncDefNode then
      FMethodList.Add(AMember);
  end;
end;

procedure TClassBodyNode.Compile;
begin
  ;
end;

{ TClassImplListNode }

constructor TClassImplListNode.Create(AIntfName: TCompoundName);
begin
  inherited Create;
  FIntfList := TNodeList.Create(False);
  Add(AIntfName);
end;

procedure TClassImplListNode.Add(AIntfName: TCompoundName);
var
  IntfInfo: TClassInfo;
begin
  IntfInfo := Context.CurScope.FindClassIdent(AIntfName.Full);
  if IntfInfo = nil then
  begin
    raise EActionCompileError.CreateFmt(
      'Interface %s not found.', [St[AIntfName.Full]]);
  end;

  if IntfInfo.IdentId <> AIntfName.Full then
  begin
    // В фразе class_impl был использован алиас импорта
    // заменить алиас на полное имя класса.
    AIntfName := TCompoundName.Parse(IntfInfo.IdentId);
  end;

  with IntfInfo do
    // Пометить интерфейс как используемый.
    // Если он еще не откомпилирован, то будет откомпилирован.
    State := State + [cifUsed];

  FIntfList.Add(AIntfName);
end;

function TClassImplListNode.GetCount: Integer;
begin
  Result := FIntfList.Count;
end;

function TClassImplListNode.GetItem(I: Integer): TCompoundName;
begin
  Result := FIntfList[I] as TCompoundName;
end;

{ TClassDefNode }

constructor TClassDefNode.Create(AName, ASuperName: TCompoundName;
  AIdentTable: TIdentTable);
begin
  inherited Create;
  FName := AName;
  FSuperName := ASuperName;
  FIdentTable := AIdentTable;
end;

class procedure TClassDefNode.ProcessHeader(
  AName: TCompoundName; var ASuperName: TCompoundName);
var
  ClassInfo, SuperClassInfo: TClassInfo;
begin
  // Найти запись о базовом классе, если он есть
  SuperClassInfo := nil;
  if ASuperName <> nil then
  begin
    SuperClassInfo := Context.CurScope.FindClassIdent(ASuperName.Full);

    if SuperClassInfo = nil then
      raise EActionCompileError.CreateFmt(
        'Superclass %s not found.', [St[ASuperName.Full]]);

    if ASuperName.Full <> SuperClassInfo.IdentId then
    begin
      // В фразе class_super был использован алиас импорта
      // заменить алиас на полное имя класса.
      ASuperName := TCompoundName.Parse(SuperClassInfo.IdentId);
    end;

    with SuperClassInfo do
      // Пометить суперкласс как используемый.
      // Если он еще не откомпилирован, то будет откомпилирован.
      State := State + [cifUsed];
  end;

  // Открыть новую область видимости для класса и сохранить ссылку
  // в записи таблицы имен для этого класса (если ее еще нет)
  // Если класс ActionScript 2.0 объявлен во внешнем файле, то запись ClassInfo
  // для него уже создана
  ClassInfo := Context.CurScope.AddClassIdent(AName.Full);
  Context.OpenScope(skClass);
  ClassInfo.ClassDefTable := Context.CurScope;
  ClassInfo.ClassDefTable.SetFullClassName(AName);

  // Добавить в цепочку областей видимости класса его базовый класс
  if ASuperName <> nil then
  begin
    Assert(SuperClassInfo <> nil);
    Context.CurScope.SuperClass := SuperClassInfo.ClassDefTable;
  end;
end;

procedure TClassDefNode.CreatePackages;
// Метод строит код для проверки наличия всех пакетов и создания
// этих пакетов в случае необходимости.
var
  I: Integer;
  L1: TSWFOffsetMarker;
  L2: Integer;
begin
  WriteCmd(acPushConstant, St.GlobalStrId);
  WriteCmd(acGetVariable);
  WriteCmd(acStoreRegister, 1, '_global -> tmp reg');

  for I := 0 to Name.Count - 2 do
  begin
    WriteCmd(acPushConstant, Name[I]);
    WriteCmd(acGetMember);
    WriteCmd(acNot);
    WriteCmd(acNot);

    L2 := Context.GetNextLabel;
    L1 := (WriteCmd(acIf, L2) as TSWFActionIf).BranchOffsetMarker;

    WriteCmd(acPushRegister, 1, 'tmp package reg');
    WriteCmd(acPushConstant, Name[I]);
    WriteCmd(acPushInteger, 0);
    WriteCmd(acPushConstant, St.ObjectStrId);
    WriteCmd(acNewObject);
    WriteCmd(acSetMember);

    SwfCode.SetMarker(L1);
    WriteLabel(L2);

    WriteCmd(acPushRegister, 1, 'tmp package reg');
    WriteCmd(acPushConstant, Name[I]);
    WriteCmd(acGetMember);
    WriteCmd(acStoreRegister, 1, 'tmp package reg');
  end;
end;

function TClassDefNode.GetSuperTypesList: TStrIdArray;
begin
  if SuperName = nil then
    SetLength(Result, 0)
  else
  begin
    SetLength(Result, 1);
    Result[0] := SuperName.Full;
  end;
end;

procedure TClassDefNode.CheckSuperClassLink;
var
  SuperClassInfo: TClassInfo;
begin
  if (FSuperName <> nil) and (FIdentTable.SuperClass = nil) then
  begin
    SuperClassInfo := Context.ClassTable.FindClassIdent(FSuperName.Full);
    Assert(SuperClassInfo <> nil);
    FIdentTable.SuperClass := SuperClassInfo.ClassDefTable;
    Assert(FIdentTable.SuperClass <> nil);
  end;
end;

{ TClassImplNode }

constructor TClassImplNode.Create(AName, ASuperName: TCompoundName;
  AImplList: TClassImplListNode; ABody: TClassBodyNode);
begin
  inherited Create(AName, ASuperName, Context.CurScope);
  FBody := ABody;
  FImplList := AImplList;
  Assert(IdentTable.ScopeKind = skClass);
{$IFDEF DEBUG}
  IdentTable.DebugName := 'Class ' + St[Name.Full];
{$ENDIF}

  St.PrototypeStrId;

  // Найти функцию конструктор. В тело этой функции необходимо вставить
  // инициализацию членов класса.
  FConstructor := FBody.GetConstructor(Name.Last);
  if FConstructor = nil then
  begin
    // Конструктор не найден - создать пустой конструктор.
    Context.OpenScope(skLocal);
    FConstructor := TFuncDefNode.Create(
      Name.Last,
      TArgDeclListNode.Create,
      St.EmptyStrId,
      TStmtListNode.Create(nil));
    FConstructor.SetFlag(nfClassMember);
    Context.CloseScope;
  end;

  Context.CloseScope;
end;

procedure TClassImplNode.CreateConstructor;
begin
  WriteCmd(acPushConstant, Name.Last);
  WriteCmd(acGetMember);
  WriteCmd(acNot);
  WriteCmd(acNot);

  FEndClassLabel := Context.GetNextLabel;
  FEndClassMarker :=
    (WriteCmd(acIf, FEndClassLabel) as TSWFActionIf).BranchOffsetMarker;

  WriteCmd(acPushRegister, 1, 'tmp package reg');
  WriteCmd(acPushConstant, Name.Last);

  FConstructor.CompileConstructor(FBody.FFieldList, SuperName <> nil);

  WriteCmd(acStoreRegister, 1, 'tmp constructor object reg');
  WriteCmd(acSetMember);
end;

procedure TClassImplNode.Extends;
var
  I: Integer;
begin
  // Если есть суперкласс - выполнить связывание с суперклассом.
  if SuperName <> nil then
  begin
    WriteCmd(acPushRegister, 1, 'tmp constructor object reg');

    WriteCmd(acPushConstant, St.GlobalStrId);
    WriteCmd(acGetVariable);
    for I := 0 to FSuperName.Count - 1 do
    begin
      WriteCmd(acPushConstant, FSuperName[I]);
      WriteCmd(acGetMember);
    end;

    WriteCmd(acExtends);
  end;
end;

procedure TClassImplNode.ImplementsInterfaces;
var
  I, J: Integer;
begin
  if FImplList <> nil then
  begin
    for I := 0 to FImplList.Count - 1 do
    begin
      WriteCmd(acPushConstant, St.GlobalStrId);
      WriteCmd(acGetVariable);
      for J := 0 to FImplList[I].Count - 1 do
      begin
        WriteCmd(acPushConstant, FImplList[I][J]);
        WriteCmd(acGetMember);
      end;
    end;
    WriteCmd(acPushInteger, FImplList.Count);
    WriteCmd(acPushRegister, 1, 'tmp constructor object reg');
    WriteCmd(acImplementsOp);
  end;
end;

procedure TClassImplNode.CompileStaticMembers;
var
  I: Integer;
  Method: TFuncDefNode;
begin
  // Статические поля
  for I := 0 to FBody.FFieldList.Count - 1 do
    with FBody.FFieldList[I] as TVarDeclListNode do
    begin
      if FIsStaticFieldList then
        Compile;
    end;

  // Статические методы
  for I := 0 to FBody.FMethodList.Count - 1 do
  begin
    {
      Для каждого метода выполнить:
      ClassName.MethodName = MethodDef
      объект ClassName хранится в регистре 1
    }
    Method := FBody.FMethodList[I] as TFuncDefNode;
    if (Method.FuncIdentInfo <> nil)
      and (idStatic in Method.FuncIdentInfo.Flags) then
    begin
      WriteCmd(acPushRegister, 1, 'tmp constructor object reg');
      WriteCmd(acPushConstant, Method.MethodNameId);
      Method.Compile;
      WriteCmd(acSetMember);
    end;
  end;
end;

procedure TClassImplNode.Compile;
type
  TGetSetPair = record
    GetMethodName, SetMethodName: TStrId;
  end;
  PGetSetPair = ^TGetSetPair;

var
  GetSetPair: PGetSetPair;
  I: Integer;
  IterPair: PIntPtrPair;
  Method: TFuncDefNode;
  PropIter: IIntPtrIter;
  PropList: IIntPtrDict;
begin
{$IFDEF DEBUG}
  FIdentTable.WriteToListing;
{$ENDIF}

  // Создать иерархию пакетов.
  CreatePackages;
  // Создать функцию конструктор. Важно вызвать CreateConstructor сразу
  // после CreatePackages, т.к. код, сгенерированный CreatePackages оставляет
  // на вершине стека вычислений объект пакета, свойством которого является
  // конструктор.
  CreateConstructor;
  // Связать конструктор с конструктором суперкласса
  // Важно вызвать Extends срвзу после CreateConstructor.
  Extends;
  // Связать конструктор с конструкторами реализуемых интерфейсов
  ImplementsInterfaces;

  // Добавить в качестве свойств конструктора статические поля и методы класса.
  // При компиляции учесть, что регистр №1 содержит объект конструктор
  CompileStaticMembers;

  WriteCmd(acPushRegister, 1, 'tmp constructor object reg');
  WriteCmd(acPushConstant, St.PrototypeStrId);
  WriteCmd(acGetMember);
  WriteCmd(acStoreRegister, 1, 'tmp constructor.prototype object reg');
  WriteCmd(acPop);

  PropList := TIntPtrHash.Create(113);
  // Скомпилировать нестатические методы.
  for I := 0 to FBody.FMethodList.Count - 1 do
  begin
    Method := FBody.FMethodList[I] as TFuncDefNode;
    if (Method.FuncIdentInfo <> nil)
      and (idStatic in Method.FuncIdentInfo.Flags) then
    begin
      // Статический метод - пропускаем.
      Continue;
    end;

    {
      Для каждого метода выполнить:
      ClassName.prototype.MethodName = MethodDef
      объект ClassName.prototype хранится в регистре 1
    }

    WriteCmd(acPushRegister, 1, 'tmp constructor.prototype object reg');
    WriteCmd(acPushConstant, Method.MethodNameId);
    Method.Compile;
    WriteCmd(acSetMember);

    // Построение таблицы для связывания имен свойств с функциями
    // записи и чтения. см. Object.addProperty в ActionScript
    if nfGetProp in Method.Flags then
    begin
      GetSetPair := PropList[Method.FFuncNameId];
      if GetSetPair = nil then
      begin
        New(GetSetPair);
        GetSetPair.SetMethodName := St.EmptyStrId;
        PropList[Method.FFuncNameId] := GetSetPair;
      end;
      GetSetPair^.GetMethodName := Method.MethodNameId;
    end
    else if nfSetProp in Method.Flags then
    begin
      GetSetPair := PropList[Method.FFuncNameId];
      if GetSetPair = nil then
      begin
        New(GetSetPair);
        GetSetPair.GetMethodName := St.EmptyStrId;
        PropList[Method.FFuncNameId] := GetSetPair;
      end;
      GetSetPair^.SetMethodName := Method.MethodNameId;
    end;
  end;

  // для каждого свойства построить вызов constructor.prototype.addProperty
  PropIter := PropList.Iter;
  while PropIter.HasNext do
  begin
    IterPair := PropIter.Next;

    GetSetPair := IterPair.Value;
    if GetSetPair.SetMethodName = St.EmptyStrId then
      WriteCmd(acPushNull)
    else
    begin
      WriteCmd(acPushRegister, 1, 'tmp constructor.prototype object reg');
      WriteCmd(acPushConstant, GetSetPair.SetMethodName);
      WriteCmd(acGetMember);
    end;

    if GetSetPair.GetMethodName = St.EmptyStrId then
      WriteCmd(acPushNull)
    else
    begin
      WriteCmd(acPushRegister, 1, 'tmp constructor.prototype object reg');
      WriteCmd(acPushConstant, GetSetPair.GetMethodName);
      WriteCmd(acGetMember);
    end;

    WriteCmd(acPushConstant, IterPair^.Key);
    WriteCmd(acPushInteger, 3);
    WriteCmd(acPushRegister, 1, 'tmp constructor.prototype object reg');
    WriteCmd(acPushConstant, St.AddItem('addProperty'));
    WriteCmd(acCallMethod);
    WriteCmd(acPop);
    Dispose(GetSetPair);
  end;

  SwfCode.SetMarker(FEndClassMarker);
  WriteLabel(FEndClassLabel);
end;

function TClassImplNode.GetSuperTypesList: TStrIdArray;
var
  I: Integer;
begin
  if (SuperName = nil) and (ImplList = nil) then
  begin
    SetLength(Result, 0);
    Exit;
  end;

  if (SuperName <> nil) and (ImplList = nil) then
  begin
    SetLength(Result, 1);
    Result[0] := SuperName.Full;
    Exit;
  end;

  if (SuperName = nil) and (ImplList <> nil) then
  begin
    SetLength(Result, ImplList.Count);
    for I := 0 to ImplList.Count - 1 do
      Result[I] := ImplList[I].Full;
    Exit;
  end;

  SetLength(Result, ImplList.Count + 1);
  Result[0] := SuperName.Full;
  for I := 0 to ImplList.Count - 1 do
    Result[I + 1] := ImplList[I].Full;
end;

{ TClassIntfNode }

constructor TClassIntfNode.Create(AName, ASuperName: TCompoundName;
  ABody: TIntfBodyNode);
begin
  inherited Create(AName, ASuperName, Context.CurScope);
  FBody := ABody;
  Assert(IdentTable.ScopeKind = skClass);
{$IFDEF DEBUG}
  IdentTable.DebugName := 'Interface ' + St[Name.Full];
{$ENDIF}
  Context.CloseScope;
end;

procedure TClassIntfNode.Compile;
begin
  // Создать иерархию пакетов.
  CreatePackages;
  // Создать функцию конструктор. Важно вызвать CreateConstructor сразу
  // после CreatePackages, т.к. код, сгенерированный CreatePackages оставляет
  // на вершине стека вычислений объект пакета, свойством которого является
  // конструктор.
  CreateConstructor;
  // Связать конструктор с конструктором суперкласса
  // Важно вызвать Extends сразу после CreateConstructor.
  Extends;

  SwfCode.SetMarker(FEndClassMarker);
  WriteLabel(FEndClassLabel);
end;

procedure TClassIntfNode.CreateConstructor;
var
  EndFuncMarker: TSWFOffsetMarker;
  DefFunc: TSWFActionDefineFunction;
begin
  WriteCmd(acPushConstant, Name.Last);
  WriteCmd(acGetMember);
  WriteCmd(acNot);
  WriteCmd(acNot);

  FEndClassLabel := Context.GetNextLabel;
  FEndClassMarker :=
    (WriteCmd(acIf, FEndClassLabel) as TSWFActionIf).BranchOffsetMarker;

  WriteCmd(acPushRegister, 1, 'tmp package reg');
  WriteCmd(acPushConstant, Name.Last);

  // Создать пустую анонимную функцию - конструктор для интерфейса
  DefFunc := WriteCmd(acDefineFunction, St.EmptyStrId, nil, 0) as
    TSWFActionDefineFunction;
  EndFuncMarker := DefFunc.CodeSizeMarker;
  WriteCmd(acPushUndefined);
  WriteCmd(acReturn);
  SwfCode.SetMarker(EndFuncMarker);
  WriteCmd(acEndFunction, St.EmptyStrId);

  WriteCmd(acStoreRegister, 1, 'tmp constructor object reg');
  WriteCmd(acSetMember);
end;

procedure TClassIntfNode.Extends;
var
  I: Integer;
begin
  // Если есть суперинтерфейс - выполнить связывание с суперинтерфейсом.
  if SuperName <> nil then
  begin
    WriteCmd(acPushRegister, 1, 'tmp constructor object reg');

    // Положить количество реализуемых интерфейсов на стек.
    WriteCmd(acPushInteger, 1);

    // Положить суперинтерфейс на стек.
    WriteCmd(acPushConstant, St.GlobalStrId);
    WriteCmd(acGetVariable);
    for I := 0 to FSuperName.Count - 1 do
    begin
      WriteCmd(acPushConstant, FSuperName[I]);
      WriteCmd(acGetMember);
    end;

    WriteCmd(acImplementsOp);
  end;
end;

{ TImportNode }

constructor TImportNode.Create(AName: TCompoundName);
begin
  inherited Create;
  FName := AName;
end;

procedure TImportNode.ImportClass;
var
  ClassInfo: TClassInfo;
begin
  // Добавить простое имя класса в текущую область видимости.
  ClassInfo := Context.CurScope.FindClassIdent(FName.Full);
  if ClassInfo = nil then
  begin
    raise EActionCompileError.CreateFmt('Class %s not found.',
      [St[FName.Full]]);
  end;
  Context.CurScope.AddClassAlias(FName.Last, ClassInfo);
end;

procedure TImportNode.ImportPackage;
label
  NextClass;
var
  ClassTable: TClassTable;
  I, J: Integer;
  ClassName: TCompoundName;
begin
  ClassTable := Context.ClassTable;
  for I := 0 to ClassTable.Items.Count - 1 do
  begin
    ClassName := TCompoundName.Parse(ClassTable.Items[I].IdentId);
    if (FName.Count + 1) <> ClassName.Count then
      Continue;
    for J := 0 to FName.Count - 1 do
      if UpperCase(St[FName[J]]) <> UpperCase(St[ClassName[J]]) then
        goto NextClass;
    // Добавить простое имя класса в текущую область видимости.
    Context.CurScope.AddClassAlias(ClassName.Last,
      ClassTable.Items[I] as TClassInfo);
    NextClass:
  end;
end;

procedure TImportNode.Compile;
begin
end;

initialization
  Randomize;

end.


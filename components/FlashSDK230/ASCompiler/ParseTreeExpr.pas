//*******************************************************//
//                                                       //
//                      DelphiFlash.com                  //
//         Copyright (c) 2004-2007 FeatherySoft, Inc.    //
//                    info@delphiflash.com               //
//                                                       //
//*******************************************************//

//  Description:  ActionScript Compiler for Flash level
//  Last update:  19 may 2007
unit ParseTreeExpr;

interface

uses
  SysUtils, Classes, Contnrs, StrTbl, IdentTbl, ParseTreeBase;

type
  TNumberNode = class(TParseTreeNode)
  private
    FNumber: Double;
  public
    constructor Create(ANumber: Double);
    procedure Compile; override;
  end;

  TStrNode = class(TParseTreeNode)
  private
    FStrId: TStrId;
  public
    constructor CreateString(AStrId: TStrId);
    constructor CreateIdent(AIdentId: TStrId);
    procedure Compile; override;
    property StrId: TStrId read FStrId;
  end;

  TFl4VarPath = record
    FullStr: string;
    VarPathStr: string;
    PropIdx: Integer;
  end;

  TLvalueNode = class(TParseTreeNode)
  private
    FFl4VarPath: TFl4VarPath;
    FObjRef: TParseTreeNode;
    FExpr: TParseTreeNode;
    FIdentInfo: TIdentInfo;
    FScope: TIdentTable;
    FIsResolved: Boolean;
    procedure ResolveIdent;
    procedure CompileVariable;
    procedure CompileVarPath;
  public
    constructor Create(AIdentId: TStrId; AScope: TIdentTable);
      overload;
    constructor Create(AObjRef: TParseTreeNode; AIdentId: TStrId);
      overload;
    constructor Create(AObjRef: TParseTreeNode; AExpr: TParseTreeNode);
      overload;
    constructor CreateFl4VarPath(APath: TStrId);
    function IsRegisterVariable: Boolean;
    function GetCompoundName: TCompoundName;
    procedure Compile; override;
    procedure GetLvalue;
    procedure SetLvalue;
    property ObjRef: TParseTreeNode read FObjRef;
  end;

  TAssignNode = class(TParseTreeNode)
  private
    FLvalue: TLvalueNode;
    FExpr: TParseTreeNode;
    FOp: Word;
    FScope: TIdentTable;
  public
    constructor Create(ALvalue: TLvalueNode; AExpr: TParseTreeNode;
      AOp: Word);
    procedure Compile; override;
  end;

  TBinOpNode = class(TParseTreeNode)
  private
    FBinOp: Word;
    FLeftArg, FRightArg: TParseTreeNode;
  public
    constructor Create(ABinOp: Char; ALeftArg, ARightArg: TParseTreeNode);
      overload;
    constructor Create(ABinOp: Word; ALeftArg, ARightArg: TParseTreeNode);
      overload;
    procedure Compile; override;
  end;

  TUnOpNode = class(TParseTreeNode)
  private
    FUnOp: Word;
    FArg: TParseTreeNode;
  public
    constructor Create(AUnOp: Char; AArg: TParseTreeNode); overload;
    constructor Create(AUnOp: Word; AArg: TParseTreeNode); overload;
    procedure Compile; override;
  end;

  TExprListNode = class(TParseTreeNode)
  private
    FExprList: INodeList;
  public
    constructor Create(AExpr: TParseTreeNode);
    procedure Add(AExpr: TParseTreeNode);
    procedure Compile; override;
    property ExprList: INodeList read FExprList;
  end;

  TFuncCallNode = class(TParseTreeNode)
  private
    FObjRef: TParseTreeNode;
    FFuncNameId: TStrId;
    FArgs: TExprListNode;
    FClassNameInfo: TClassInfo;
    FFuncNameInfo: TIdentInfo;
    FScope: TIdentTable;
    FIsResolved: Boolean;
    procedure ResolveFuncName;
    procedure CompileFuncCall;
    function CompileBuiltIn: Boolean;
    function CompileCastOp: Boolean;
  public
    constructor Create(AFuncNameId: TStrId; AArgs: TExprListNode);
      overload;
    constructor Create(AObjRef: TParseTreeNode; AMethodNameId: TStrId;
      AArgs: TExprListNode); overload;
    procedure Compile; override;
    procedure CheckUsedClass;
  end;

implementation

uses
  Variants, Math, SWFConst, SWFObjects, ActionCompiler, ActionCompilerYacc{, JclDebug};

const
  StdPropNameList: array[0..21] of string = (
    '_x',
    '_y',
    '_xscale',
    '_yscale',
    '_currentframe',
    '_totalframes',
    '_alpha',
    '_visible',
    '_width',
    '_height',
    '_rotation',
    '_target',
    '_framesloaded',
    '_name',
    '_droptarget',
    '_url',
    '_highquality',
    '_focusrect',
    '_soundbuftime',
    '_quality',
    '_xmouse',
    '_ymouse'
    );

function GetStdPropIdx(APropName: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to 21 do
    if LowerCase(APropName) = StdPropNameList[I] then
    begin
      Result := I;
      Break;
    end;
end;

{ TNumberNode }

constructor TNumberNode.Create(ANumber: Double);
begin
  inherited Create;
  FNumber := ANumber;
end;

procedure TNumberNode.Compile;
begin
  if not (nfDiscardResult in Flags) then
  begin
    if FNumber <> Trunc(FNumber) then
      WriteCmd(acPushDouble, FNumber)
    else
      WriteCmd(acPushInteger, FNumber);
  end;
end;

{ TStrNode }

constructor TStrNode.CreateString(AStrId: TStrId);
begin
  inherited Create;
  FStrId := AStrId;
end;

constructor TStrNode.CreateIdent(AIdentId: TStrId);
begin
  inherited Create;
  FStrId := AIdentId;
end;

procedure TStrNode.Compile;
begin
  if not (nfDiscardResult in Flags) then
  begin
    case FStrId of
      UndefinedStrId:
        WriteCmd(acPushUndefined);
      NullStrId:
        WriteCmd(acPushNull);
      TrueStrId:
        WriteCmd(acPushBoolean, 1);
      FalseStrId:
        WriteCmd(acPushBoolean, 0);
    else
      WriteCmd(acPushConstant, FStrId);
    end;
  end;
end;

{ TLvalueNode }

constructor TLvalueNode.Create(AIdentId: TStrId; AScope: TIdentTable);
var
  FullClassName: TCompoundName;
  I: Integer;
begin
  inherited Create;
  FObjRef := nil;
  FExpr := TStrNode.CreateIdent(AIdentId);
  FScope := AScope;

  // Попытка разрешить имя на первом проходе.
  if AIdentId = St.ThisStrId then
  begin
    FIsResolved := True;
    FScope.SetPreloadFlag(pfThis);
  end
  else if AIdentId = St.SuperStrId then
  begin
    FIsResolved := True;
    FScope.SetPreloadFlag(pfSuper);
  end
  else if AIdentId = St.ArgumentsStrId then
  begin
    FIsResolved := True;
    FScope.SetPreloadFlag(pfArguments);
  end;

  // Искать объявление имени в текущей области видимости
  FIdentInfo := FScope.FindIdent(AIdentId, []);
  if FIdentInfo = nil then
  begin
    // В текущей области видимости имя не найдено. Искать в охватывающей.
    FIdentInfo := FScope.FindIdent(AIdentId, [fioInParent, fioInSuperClass]);
    if (FIdentInfo <> nil) and (FIdentInfo.ScopeKind = skLocal) then
    begin
      // Имя найдено в охватывающей локальной области видимости.
      // Запретить для него использование регистров.
      FIdentInfo.RegisterNum := -1;
    end;
  end;

  // Проверка на использование имени класса.
  if (FIdentInfo <> nil) and (FIdentInfo is TClassInfo) then
    with TClassInfo(FIdentInfo) do
    begin
      State := State + [cifUsed];
      if AIdentId <> IdentId then
      begin
        // Использован алиас класса, при генерации кода необходимо
        // использовать полное имя класса Package1.Package2.ClassName
        FullClassName := TCompoundName.Parse(IdentId);
        Assert(FullClassName.Full = IdentId);
        // Построить корректный префикс FObjRef = Package1.Package2
        // для данного использования имени.
        FObjRef := TLvalueNode.Create(FullClassName[0], Context.CurScope);
        for I := 1 to FullClassName.Count - 2 do
          FObjRef := TLvalueNode.Create(FObjRef, FullClassName[I]);
      end;
    end;
end;

constructor TLvalueNode.Create(AObjRef: TParseTreeNode; AIdentId: TStrId);
begin
  inherited Create;
  FObjRef := AObjRef;
  FExpr := TStrNode.CreateIdent(AIdentId);
end;

constructor TLvalueNode.Create(AObjRef: TParseTreeNode; AExpr: TParseTreeNode);
begin
  inherited Create;
  FObjRef := AObjRef;
  FExpr := AExpr;
end;

constructor TLvalueNode.CreateFl4VarPath(APath: TStrId);
var
  I: Integer;
begin
  inherited Create;
  FObjRef := nil;
  FExpr := nil;
  with FFl4VarPath do
  begin
    FullStr := St[APath];
    I := Pos(':', FullStr);
    Assert(I > 0);
    VarPathStr := Copy(FullStr, 1, I - 1);
    PropIdx := GetStdPropIdx(Copy(FullStr, I + 1, MaxInt));
  end;
  FIsResolved := True;
end;

procedure TLvalueNode.ResolveIdent;
var
  VarNameId: TStrId;
  IdentInfo2: TIdentInfo;
  FullClassName: TCompoundName;
  I: Integer;
begin
  if (FObjRef <> nil) or FIsResolved or not (FExpr is TStrNode) then
    Exit;

  if (FIdentInfo = nil) or (FIdentInfo.ScopeKind = skGlobal) then
  begin
    // Если на первом проходе объявление имени не найдено или
    // имя найдено на глобальном уровне, то надо повторить поиск
    // начиная с ближайшей области skClass
    VarNameId := (FExpr as TStrNode).FStrId;
    case FScope.ScopeKind of
      skClass:
        IdentInfo2 := FScope.FindIdent(
          VarNameId, [fioInParent, fioInSuperClass]);
      skLocal:
        begin
          Assert(FScope.Parent <> nil);
          IdentInfo2 := FScope.Parent.FindIdent(
            VarNameId, [fioInParent, fioInSuperClass]);
        end;
    else
      IdentInfo2 := nil;
    end;

    if (IdentInfo2 <> nil) and (IdentInfo2.ScopeKind = skClass) then
      // Найденное объявление уровня класса перекрывает глобальное.
      FIdentInfo := IdentInfo2;
  end;

  if (FIdentInfo <> nil) and (FIdentInfo.ScopeKind = skClass) then
  begin
    if not (idStatic in FIdentInfo.Flags) then
      // Нестатические поля класса относятся к объекту this
      FObjRef := TLvalueNode.Create(St.ThisStrId, FScope)
    else
    begin
      // Для статического поля класса необходимо использовать
      // полное имя класса с использованием имени пакета
      Assert(FIdentInfo.Owner.FullClassName <> nil);
      FullClassName := FIdentInfo.Owner.FullClassName;
      // Построить корректный префикс FObjRef = Package1.Package2.ClassName
      // для данного использования имени.
      FObjRef := TLvalueNode.Create(FullClassName[0], FScope);
      for I := 1 to FullClassName.Count - 1 do
        FObjRef := TLvalueNode.Create(FObjRef, FullClassName[I]);
    end;
  end;

  FIsResolved := True;
end;

procedure TLvalueNode.CompileVariable;
begin
  if nfDiscardResult in Flags then
    Exit;

  if IsRegisterVariable then
  begin
    // регистровая переменная
    if not (nfReference in Flags) then
      WriteCmd(acPushRegister, FIdentInfo.RegisterNum, St[FIdentInfo.IdentId]);
  end
  else
  begin
    // Именованная переменная
    FExpr.Compile;
    if not (nfReference in Flags) then
      WriteCmd(acGetVariable);
  end;
end;

procedure TLvalueNode.CompileVarPath;
begin
  if nfDiscardResult in Flags then
    Exit;

  if FFl4VarPath.PropIdx < 0 then
  begin
    // Генерируем вызов GetVariable
    WriteCmd(acPushString, FFl4VarPath.FullStr);
    if not (nfReference in Flags) then
      WriteCmd(acGetVariable);
  end
  else
  begin
    // Генерируем вызов GetProperty
    WriteCmd(acPushString, FFl4VarPath.VarPathStr);
    WriteCmd(acPushInteger, FFl4VarPath.PropIdx);
    if not (nfReference in Flags) then
      WriteCmd(acGetProperty);
  end;
end;

function TLvalueNode.IsRegisterVariable: Boolean;
begin
  Result := (FObjRef = nil) and (FIdentInfo <> nil)
    and (FIdentInfo.RegisterNum > 0);
end;

function TLvalueNode.GetCompoundName: TCompoundName;
var
  ExprStrId: TStrId;
begin
  // Если данный узел относится к конструкции A.B.C
  // то будет возвращен объект TCompoundName для такой конструкции.
  // Иначе nil.
  Result := nil;
  if FExpr is TStrNode then
  begin
    ExprStrId := (FExpr as TStrNode).StrId;
    if FObjRef = nil then
      Result := TCompoundName.Create(ExprStrId)
    else if FObjRef is TLvalueNode then
    begin
      Result := (FObjRef as TLvalueNode).GetCompoundName;
      if Result <> nil then
        Result.Add(ExprStrId);
    end;
  end;  
end;

procedure TLvalueNode.Compile;
var
  DotExpr: TCompoundName;

  procedure ParseDotExpr(DotExprStr: string);
  var
    Item: string;
    List: array[1..25] of string;
    I, ListSize: Integer;
  begin
{$RANGECHECKS ON}
    ListSize := 0;
    Item := StrToken2(DotExprStr, '.');
    while Item <> '' do
    begin
      Inc(ListSize);
      List[ListSize] := Item;
      Item := StrToken2(DotExprStr, '.');
    end;

    if LowerCase(List[1]) = '_root' then
      FFl4VarPath.FullStr := '/'
    else if LowerCase(List[1]) = '_parent' then
      FFl4VarPath.FullStr := '..'
    else
      FFl4VarPath.FullStr := List[1];

    for I := 2 to ListSize - 1 do
      if FFl4VarPath.FullStr = '/' then
        FFl4VarPath.FullStr := '/' + List[I]
      else
        FFl4VarPath.FullStr := FFl4VarPath.FullStr + '/' + List[I];

    FFl4VarPath.FullStr := FFl4VarPath.FullStr + ':' + List[ListSize];
{$RANGECHECKS OFF}
    with FFl4VarPath do
    begin
      I := Pos(':', FullStr);
      Assert(I > 0);
      VarPathStr := Copy(FullStr, 1, I - 1);
      PropIdx := GetStdPropIdx(Copy(FullStr, I + 1, MaxInt));
    end;
    FIsResolved := True;
  end;

begin
  if FFl4VarPath.FullStr <> '' then
  begin
    // Lvalue - переменная или свойство с использованием синтаксиса
    // Flash4 /A/B:prop или /C/D:var
    CompileVarPath;
  end
  else
  begin
    ResolveIdent;
    if FObjRef = nil then
      // Variable
      CompileVariable
    else if not (coFlashLite in Context.CompileOptions) then
    begin
      // Member
      FObjRef.Compile;
      FExpr.Compile;
      if not (nfReference in Flags) then
        WriteCmd(acGetMember);
      CheckDiscardResult;
    end
    else
    begin
      // Member
      // Преобразовать из нотации A.B.C в /A/B:C
      DotExpr := GetCompoundName;
      Assert(DotExpr <> nil);
      ParseDotExpr(St[DotExpr.Full]);
      CompileVarPath;
    end;
  end;
end;

procedure TLvalueNode.GetLvalue;
begin
  if FFl4VarPath.FullStr <> '' then
  begin
    if FFl4VarPath.PropIdx < 0 then
      WriteCmd(acGetVariable)
    else
      WriteCmd(acGetProperty);
  end
  else
  begin
    ResolveIdent;
    if FObjRef <> nil then
      WriteCmd(acGetMember)
    else
    begin
      if IsRegisterVariable then
        // регистровая переменная
        WriteCmd(acPushRegister, FIdentInfo.RegisterNum, St[FIdentInfo.IdentId])
      else
        // Именованная переменная
        WriteCmd(acGetVariable);
    end;
  end;
end;

procedure TLvalueNode.SetLvalue;
begin
  if FFl4VarPath.FullStr <> '' then
  begin
    if FFl4VarPath.PropIdx < 0 then
      WriteCmd(acSetVariable)
    else
      WriteCmd(acSetProperty);
  end
  else
  begin
    ResolveIdent;
    if FObjRef <> nil then
      WriteCmd(acSetMember)
    else
    begin
      if IsRegisterVariable then
      begin
        // регистровая переменная
        with FIdentInfo do
          WriteCmd(acStoreRegister, RegisterNum, St[IdentId]);
        WriteCmd(acPop);
      end
      else
        // Именованная переменная
        WriteCmd(acSetVariable);
    end;
  end;
end;

{ TAssignNode }

constructor TAssignNode.Create(ALvalue: TLvalueNode; AExpr: TParseTreeNode;
  AOp: Word);
begin
  inherited Create;
  FLvalue := ALvalue;
  FExpr := AExpr;
  FOp := AOp;
  FLvalue.SetFlag(nfReference);
  FScope := Context.CurScope;
end;

procedure TAssignNode.Compile;
var
  AddCmd: TActionCommand;
{$IFDEF DEBUG}
  StackMarker: Integer;
{$ENDIF}
begin
{$IFDEF DEBUG}
  StackMarker := 0;
  if nfDiscardResult in Flags then
    StackMarker := Context.MarkStack;
{$ENDIF}

  if not (coFlashLite in Context.CompileOptions) then
    AddCmd := acAdd2
  else
    AddCmd := acAdd;

  case FOp of
    opAssign:
      begin
        // Поместить ссылку на стек
        FLvalue.Compile;
        // Вычислить значение выражения
        FExpr.Compile;
        // Выполнить присваивание
        if nfDiscardResult in Flags then
          FLvalue.SetLvalue
        else
        begin
          if not (coFlashLite in Context.CompileOptions) then
          begin
            WriteCmd(acStoreRegister, FScope.AssignTmpRegister, '_tmp_');
            FLvalue.SetLvalue;
            WriteCmd(acPushRegister, FScope.AssignTmpRegister, '_tmp_');
          end
          else
          begin
            FLvalue.SetLvalue;
            FLvalue.Compile;
            FLvalue.GetLvalue;
          end;
        end;
      end;

    INCR, DECR:
      if not (coFlashLite in Context.CompileOptions) then
      begin
        // Поместить ссылку на стек
        FLvalue.Compile;
        // Поместить ссылку на стек и получить значение.
        FLvalue.Compile;
        FLvalue.GetLvalue;

        // Если требуется значение операции присваивания - сохранить ее
        // Случай постфиксной оперции
        if not (nfDiscardResult in Flags) and (nfPostfix in Flags) then
          WriteCmd(acStoreRegister, FScope.AssignTmpRegister, '_tmp_');

        if FOp = INCR then
          WriteCmd(acIncrement)
        else
          WriteCmd(acDecrement);

        // Если требуется значение операции присваивания - сохранить ее
        // Случай префиксной оперции
        if not (nfDiscardResult in Flags) and not (nfPostfix in Flags) then
          WriteCmd(acStoreRegister, FScope.AssignTmpRegister, '_tmp_');

        // Выполнить присваивание.
        FLvalue.SetLvalue;

        if not (nfDiscardResult in Flags) then
          WriteCmd(acPushRegister, FScope.AssignTmpRegister, '_tmp_');
      end
      else
      begin
        if not (nfDiscardResult in Flags) and (nfPostfix in Flags) then
        begin
          // Разместить на стеке текущее значение Lvalue
          // Это значение будет результатом постфиксной оперции ++ или --
          FLvalue.Compile;
          FLvalue.GetLvalue;
        end;

        // Поместить ссылку на стек
        FLvalue.Compile;
        // Поместить ссылку на стек и получить значение.
        FLvalue.Compile;
        FLvalue.GetLvalue;
        // Поместить на стек 1
        WriteCmd(acPushString, '1');

        if FOp = INCR then
          WriteCmd(acAdd)
        else
          WriteCmd(acSubtract);

        // Выполнить присваивание
        FLvalue.SetLvalue;

        if not (nfDiscardResult in Flags) and not (nfPostfix in Flags) then
        begin
          // Выложить текущее значение Lvalue на стек
          // Это значение является результатом префиксной операции ++ или --
          FLvalue.Compile;
          FLvalue.GetLvalue;
        end;
      end;

    opAssignAdd, opAssignSub, opAssignMult, opAssignDiv,
    opAssignBitAnd, opAssignBitXor, opAssignBitOr,
    opAssignLShift, opAssignSRShift, opAssignURShift:
      begin
        // Поместить ссылку на стек
        FLvalue.Compile;
        // Поместить ссылку на стек и получить значение.
        FLvalue.Compile;
        FLvalue.GetLvalue;
        // Получить значение выражения
        FExpr.Compile;
        // Выполнить операцию
        case FOp of
          opAssignAdd:
            WriteCmd(AddCmd);
          opAssignSub:
            WriteCmd(acSubtract);
          opAssignMult:
            WriteCmd(acMultiply);
          opAssignDiv:
            WriteCmd(acDivide);
          opAssignBitAnd:
            WriteCmd(acBitAnd);
          opAssignBitXor:
            WriteCmd(acBitXor);
          opAssignBitOr:
            WriteCmd(acBitOr);
          opAssignLShift:
            WriteCmd(acBitLShift);
          opAssignSRShift:
            WriteCmd(acBitRShift);
          opAssignURShift:
            WriteCmd(acBitURShift);
        end;

        if nfDiscardResult in Flags then
          // Выполнить присваивание
          FLvalue.SetLvalue
        else
        begin
          if not (coFlashLite in Context.CompileOptions) then
          begin
            // Сохранить значение
            WriteCmd(acStoreRegister, FScope.AssignTmpRegister, '_tmp_');
            // Выполнить присваивание
            FLvalue.SetLvalue;
            // Вернуть значение выражения присваивания.
            WriteCmd(acPushRegister, FScope.AssignTmpRegister, '_tmp_');
          end
          else
          begin
            // Выполнить присваивание
            FLvalue.SetLvalue;
            // Выложить значение на стек
            FLvalue.Compile;
            FLvalue.GetLvalue;
          end;
        end;
      end;

    opAssignModulo:
      if not (coFlashLite in Context.CompileOptions) then
      begin
        FLvalue.Compile;
        FLvalue.Compile;
        FLvalue.GetLvalue;
        FExpr.Compile;
        WriteCmd(acModulo);
        if nfDiscardResult in Flags then
          FLvalue.SetLvalue
        else
        begin
          WriteCmd(acStoreRegister, FScope.AssignTmpRegister, '_tmp_');
          FLvalue.SetLvalue;
          WriteCmd(acPushRegister, FScope.AssignTmpRegister, '_tmp_');
        end;
      end
      else
      begin
        // Поместить на стек ссылку Lvalue
        FLvalue.Compile;
        // Вычислить значение Lvalue % Expr по формуле для FlashLite
        // A % B = A - int(A / B) * B
        FLvalue.Compile;
        FLvalue.GetLvalue;
        FLvalue.Compile;
        FLvalue.GetLvalue;
        FExpr.Compile;
        WriteCmd(acDivide);
        WriteCmd(acToInteger);
        FExpr.Compile;
        WriteCmd(acMultiply);
        WriteCmd(acSubtract);
        // Выполнить присваивание
        FLvalue.SetLvalue;
        if not (nfDiscardResult in Flags) then
        begin
          FLvalue.Compile;
          FLvalue.GetLvalue;  
        end;
      end;
  end;
{$IFDEF DEBUG}
  if nfDiscardResult in Flags then
    Context.CheckStack(StackMarker, 'TAssignNode error.');
{$ENDIF}
end;

{ TBinOpNode }

constructor TBinOpNode.Create(
  ABinOp: Char;
  ALeftArg, ARightArg: TParseTreeNode);
begin
  inherited Create;
  FBinOp := Ord(ABinOp);
  FLeftArg := ALeftArg;
  FRightArg := ARightArg;
end;

constructor TBinOpNode.Create(
  ABinOp: Word;
  ALeftArg, ARightArg: TParseTreeNode);
var
  FullClassName: TCompoundName;
  I: Integer;
  IdentId: TStrId;
  IdentInfo: TIdentInfo;
  ClassInfo: TClassInfo absolute IdentInfo;
  RightLvalue: TLvalueNode;
begin
  inherited Create;
  FBinOp := ABinOp;
  FLeftArg := ALeftArg;
  FRightArg := ARightArg;

  if (FBinOp = INSTANCEOF) and (FRightArg is TLvalueNode) then
  begin
    // Проверит правый аргумент.
    // Не является ли он идентификатором
    // импортированного оператором import класса.
    RightLvalue := FRightArg as TLvalueNode;
    if (RightLvalue.FObjRef = nil) and (RightLvalue.FExpr is TStrNode)then
    begin
      IdentId := (RightLvalue.FExpr as TStrNode).StrId;
      IdentInfo := Context.CurScope.FindIdent(
        IdentId, [fioInParent, fioInSuperClass]);
      if IdentInfo is TClassInfo then
      begin
        // 1. Пометить класс TIdentInfo как используемый
        ClassInfo.State := ClassInfo.State + [cifUsed];
        // 2. Изменить RightLvalue.FObjRef так, чтобы он представлял
        // полное имя класса - Package1.Package2.ClassName
        FullClassName := TCompoundName.Parse(IdentInfo.IdentId);
        if FullClassName.Count > 1 then
        begin
          // RightLvalue.FObjRef изменяем только если класс входит в пакет
          // т.е. имя класса имеет хотя бы один префикс.
          RightLvalue.FObjRef := TLvalueNode.Create(
            FullClassName[0], Context.CurScope);
          for I := 1 to FullClassName.Count - 2 do
          begin
            RightLvalue.FObjRef := TLvalueNode.Create(
              RightLvalue.FObjRef, FullClassName[I]);
          end;
        end;
      end;
    end;
  end;
end;

procedure TBinOpNode.Compile;

  procedure CompileAnd;
  var
    L1: TSWFOffsetMarker;
    L2: Integer;
  begin
    FLeftArg.Compile;
    if not (coFlashLite in Context.CompileOptions) then
      WriteCmd(acPushDuplicate)
    else
      FLeftArg.Compile;
    WriteCmd(acNot);

    L2 := Context.GetNextLabel;
    with WriteCmd(acIf, L2) as TSWFActionIf do
      L1 := BranchOffsetMarker;

    WriteCmd(acPop);
    FRightArg.Compile;

    WriteLabel(L2);
    SwfCode.SetMarker(L1);
  end;

  procedure CompileOr;
  var
    L1: TSWFOffsetMarker;
    L2: Integer;
  begin
    FLeftArg.Compile;
    if not (coFlashLite in Context.CompileOptions) then
      WriteCmd(acPushDuplicate)
    else
      FLeftArg.Compile;

    L2 := Context.GetNextLabel;
    with WriteCmd(acIf, L2) as TSWFActionIf do
      L1 := BranchOffsetMarker;

    WriteCmd(acPop);
    FRightArg.Compile;

    WriteLabel(L2);
    SwfCode.SetMarker(L1);
  end;

  procedure CompileModulo;
  begin
    if not (coFlashLite in Context.CompileOptions) then
    begin
      FLeftArg.Compile;
      FRightArg.Compile;
      WriteCmd(acModulo);
    end
    else
    begin
      FLeftArg.Compile;
      FLeftArg.Compile;
      FRightArg.Compile;
      WriteCmd(acDivide);
      WriteCmd(acToInteger);
      FRightArg.Compile;
      WriteCmd(acMultiply);
      WriteCmd(acSubtract);       
    end;
  end;

var
  AddCmd, EqualsCmd, LessCmd, StrictEqualsCmd: TActionCommand;

begin
  if coFlashLite in Context.CompileOptions then
  begin
    AddCmd := acAdd;
    EqualsCmd := acEquals;
    LessCmd := acLess;
    StrictEqualsCmd := acEquals;
  end
  else
  begin
    AddCmd := acAdd2;
    EqualsCmd := acEquals2;
    LessCmd := acLess2;
    StrictEqualsCmd := acStrictEquals;
  end;

  case FBinOp of
    LAND:
      CompileAnd;
    LOR:
      CompileOr;
    Ord('%'):
      CompileModulo;
  else
    FLeftArg.Compile;
    FRightArg.Compile;
    case FBinOp of
      Ord('+'):
        WriteCmd(AddCmd);
      Ord('-'):
        WriteCmd(acSubtract);
      Ord('*'):
        WriteCmd(acMultiply);
      Ord('/'):
        WriteCmd(acDivide);
      EQ:
        WriteCmd(EqualsCmd);
      SEQ:
        WriteCmd(StrictEqualsCmd);
      NE:
        begin
          WriteCmd(EqualsCmd);
          WriteCmd(acNot);
        end;
      NSEQ:
        begin
          WriteCmd(StrictEqualsCmd);
          WriteCmd(acNot);
        end;
      Ord('<'):
        WriteCmd(LessCmd);
      GE:
        begin
          WriteCmd(LessCmd);
          WriteCmd(acNot);
        end;
      LSHIFT:
        WriteCmd(acBitLShift);
      SRSHIFT:
        WriteCmd(acBitRShift);
      URSHIFT:
        WriteCmd(acBitURShift);
      BAND:
        WriteCmd(acBitAnd);
      BXOR:
        WriteCmd(acBitXor);
      BOR:
        WriteCmd(acBitOr);
      INSTANCEOF:
        WriteCmd(acInstanceOf);
      STR_ADD:
        WriteCmd(acStringAdd);
      STR_EQ:
        WriteCmd(acStringEquals);
      STR_NE:
        begin
          WriteCmd(acStringEquals);
          WriteCmd(acNot);
        end;
      STR_LT:
        WriteCmd(acStringLess);
      STR_GE:
        begin
          WriteCmd(acStringLess);
          WriteCmd(acNot);
        end;
    end;
  end;
  CheckDiscardResult;
end;

{ TUnOpNode }

constructor TUnOpNode.Create(AUnOp: Char; AArg: TParseTreeNode);
begin
  inherited Create;
  FUnOp := Ord(AUnOp);
  FArg := AArg;
end;

constructor TUnOpNode.Create(AUnOp: Word; AArg: TParseTreeNode);
begin
  inherited Create;
  FUnOp := AUnOp;
  FArg := AArg;
end;

procedure TUnOpNode.Compile;
begin
  case FUnOp of
    Ord('-'):
      begin
        WriteCmd(acPushInteger, 0);
        FArg.Compile;
        WriteCmd(acSubtract);
      end;

    Ord('~'):
      begin
        FArg.Compile;
        WriteCmd(acPushInteger, $FFFFFFFF);
        WriteCmd(acBitXor);
      end;

    LNOT:
      begin
        FArg.Compile;
        WriteCmd(acNot);
      end;

    KW_DELETE:
      begin
        if not (FArg is TLvalueNode) then
        begin
          FArg.Compile;
          WriteCmd(acDelete2)
        end
        else
          with FArg as TLvalueNode do
          begin
            SetFlag(nfReference);
            Compile;
            if FObjRef = nil then
              WriteCmd(acDelete2)
            else
              WriteCmd(acDelete);
          end;
      end;

    KW_TYPEOF:
      begin
        FArg.Compile;
        WriteCmd(acTypeOf);
      end;

    KW_VOID:
      begin
        FArg.Compile;
        WriteCmd(acPop);
        WriteCmd(acPushUndefined);
      end;
  end;
  CheckDiscardResult;
end;

{ TExprListNode }

constructor TExprListNode.Create(AExpr: TParseTreeNode);
begin
  inherited Create;
  FExprList := TNodeList.Create(False);
  Add(AExpr);
end;

procedure TExprListNode.Add(AExpr: TParseTreeNode);
begin
  if AExpr <> nil then
    FExprList.Add(AExpr);
end;

procedure TExprListNode.Compile;
var
  I: Integer;
begin
  if nfCommaExpr in Flags then
  begin
    for I := 0 to FExprList.Count - 2 do
      with FExprList[I] do
      begin
        SetFlag(nfDiscardResult);
        Compile;
      end;
    with FExprList[FExprList.Count - 1] do
    begin
      if nfDiscardResult in Self.Flags then
        SetFlag(nfDiscardResult);
      Compile;
    end;
  end
  else
  begin
    for I := FExprList.Count - 1 downto 0 do
      FExprList[I].Compile;

    if nfInitObject in Flags then
    begin
      WriteCmd(acPushInteger, FExprList.Count div 2);
      WriteCmd(acInitObject);
      CheckDiscardResult;
    end
    else if nfInitArray in Flags then
    begin
      WriteCmd(acPushInteger, FExprList.Count);
      WriteCmd(acInitArray);
      CheckDiscardResult;
    end
    else
      WriteCmd(acPushInteger, FExprList.Count);
  end;
end;

{ TFuncCallNode }

constructor TFuncCallNode.Create(AFuncNameId: TStrId; AArgs: TExprListNode);
var
  FullClassName: TCompoundName;
  I: Integer;
begin
  inherited Create;
  FObjRef := nil;
  FFuncNameId := AFuncNameId;
  FArgs := AArgs;
  // Попытка разрешить имя функции на первом проходе.
  FScope := Context.CurScope;
  if AFuncNameId = St.SuperStrId then
  begin
    FIsResolved := True;
    FScope.SetPreloadFlag(pfSuper);
    FScope.ImplicitSuperCall := False;
  end;
  // Проверка на использование имени класса.
  FFuncNameInfo := FScope.FindIdent(AFuncNameId, [fioInParent,
    fioInSuperClass]);
  if (FFuncNameInfo <> nil) and (FFuncNameInfo is TClassInfo) then
    with TClassInfo(FFuncNameInfo) do
    begin
      State := State + [cifUsed];
      if FFuncNameId <> IdentId then
      begin
        // Использован алиас класса, при генерации кода необходимо
        // использовать полное имя класса Package1.Package2.ClassName
        FullClassName := TCompoundName.Parse(IdentId);
        Assert(FullClassName.Full = IdentId);
        // Построить корректный префикс FObjRef = Package1.Package2
        // для данного использования имени.
        FObjRef := TLvalueNode.Create(FullClassName[0], Context.CurScope);
        for I := 1 to FullClassName.Count - 2 do
          FObjRef := TLvalueNode.Create(FObjRef, FullClassName[I]);
      end;
    end;
end;

constructor TFuncCallNode.Create(AObjRef: TParseTreeNode;
  AMethodNameId: TStrId; AArgs: TExprListNode);
var
  FullClassName: TCompoundName;
begin
  inherited Create;
  FObjRef := AObjRef;
  FFuncNameId := AMethodNameId;
  FArgs := AArgs;

  if FObjRef is TLvalueNode then
  begin
    FullClassName := (FObjRef as TLvalueNode).GetCompoundName;
    if FullClassName <> nil then
    begin
      FullClassName.Add(FFuncNameId);
      FClassNameInfo := Context.CurScope.FindClassIdent(FullClassName.Full);
      if FClassNameInfo <> nil then
        FClassNameInfo.State := FClassNameInfo.State + [cifUsed];
    end;
  end;
end;

procedure TFuncCallNode.ResolveFuncName;
var
  FFuncNameInfo2: TIdentInfo;
  FullClassName: TCompoundName;
  I: Integer;
begin
  if (FObjRef <> nil) or FIsResolved then
    Exit;

  if (FFuncNameInfo = nil) or (FFuncNameInfo.ScopeKind = skGlobal) then
  begin
    // Если на первом проходе объявление имени не найдено или
    // имя найдено на глобальном уровне, то надо повторить поиск
    // начиная с ближайшей области skClass
    case FScope.ScopeKind of
      skClass:
        FFuncNameInfo2 := FScope.FindIdent(
          FFuncNameId, [fioInParent, fioInSuperClass]);
      skLocal:
        begin
          Assert(FScope.Parent <> nil);
          FFuncNameInfo2 := FScope.Parent.FindIdent(
            FFuncNameId, [fioInParent, fioInSuperClass]);
        end;
    else
      FFuncNameInfo2 := nil;
    end;

    if (FFuncNameInfo2 <> nil) and (FFuncNameInfo2.ScopeKind = skClass) then
      FFuncNameInfo := FFuncNameInfo2;
  end;

  if (FFuncNameInfo <> nil) and (FFuncNameInfo.ScopeKind = skClass) then
  begin
    if not (idStatic in FFuncNameInfo.Flags) then
      // Нестатические поля класса относятся к объекту this
      FObjRef := TLvalueNode.Create(St.ThisStrId, FScope)
    else
    begin
      // Для статического поля класса необходимо использовать
      // полное имя класса с использованием имени пакета
      Assert(FFuncNameInfo.Owner.FullClassName <> nil);
      FullClassName := FFuncNameInfo.Owner.FullClassName;
      // Построить корректный префикс FObjRef = Package1.Package2.ClassName
      // для данного использования имени.
      FObjRef := TLvalueNode.Create(FullClassName[0], FScope);
      for I := 1 to FullClassName.Count - 1 do
        FObjRef := TLvalueNode.Create(FObjRef, FullClassName[I]);
    end;
  end;

  FIsResolved := True;
end;

procedure TFuncCallNode.CompileFuncCall;
var
  LcFuncName: string;
begin
  LcFuncName := LowerCase(St[FFuncNameId]);
  if nfNew in Flags then
  begin
    if LcFuncName = 'array' then
      WriteCmd(acInitArray)
    else if (FFuncNameInfo <> nil) and (FFuncNameInfo.RegisterNum > 0) then
    begin
      // Вызов функции через локальную переменную
      WriteCmd(acPushRegister, FFuncNameInfo.RegisterNum, St[FFuncNameId]);
      WriteCmd(acPushUndefined);
      WriteCmd(acNewMethod);
    end
    else
    begin
      // Вызов функции по имени
      WriteCmd(acPushConstant, FFuncNameId);
      WriteCmd(acNewObject);
    end
  end
  else
  begin
    if LcFuncName = 'super' then
    begin
      Assert((FFuncNameInfo <> nil) and (FFuncNameInfo.RegisterNum > 0));
      WriteCmd(acPushRegister, FFuncNameInfo.RegisterNum, 'super');
      WriteCmd(acPushUndefined);
      WriteCmd(acCallMethod);
    end
    else if (FFuncNameInfo <> nil) and (FFuncNameInfo.RegisterNum > 0) then
    begin
      // Вызов функции через локальную переменную
      WriteCmd(acPushRegister, FFuncNameInfo.RegisterNum, St[FFuncNameId]);
      WriteCmd(acPushUndefined);
      WriteCmd(acCallMethod);
    end
    else
    begin
      WriteCmd(acPushConstant, FFuncNameId);
      WriteCmd(acCallFunction);
    end;
  end;
end;

function TFuncCallNode.CompileBuiltIn: Boolean;
var
  LcFuncName: string;
  PropName, GetUrlMethod: string;
  PropIdx: Integer;
  IntArgValue: Integer;
  GetUrl2Params, FSCommandParams: Variant;
  I: Integer;

  procedure CheckArgCount(Required: Integer);
  begin
    if FArgs.ExprList.Count <> Required then
      raise EActionCompileError.CreateFmt(
        'Invalid parameters count in "%s" in line %d'#10 +
        'Requires %d parameters, actual - %d.',
        [St[FFuncNameId], SrcPos.Line, Required, FArgs.ExprList.Count]);
  end;

begin
  if FObjRef <> nil then
  begin
    Result := False;
    Exit;
  end;

  Result := True;
  LcFuncName := LowerCase(St[FFuncNameId]);
  if LcFuncName = 'length' then
  begin
    CheckArgCount(1);
    FArgs.ExprList[0].Compile;
    WriteCmd(acStringLength);
  end
  else if LcFuncName = 'int' then
  begin
    CheckArgCount(1);
    FArgs.ExprList[0].Compile;
    WriteCmd(acToInteger);
  end
  else if LcFuncName = 'random' then
  begin
    CheckArgCount(1);
    FArgs.ExprList[0].Compile;
    WriteCmd(acRandomNumber);
  end
  else if LcFuncName = 'call' then
  begin
    CheckArgCount(1);
    FArgs.ExprList[0].Compile;
    WriteCmd(acCall);
    // Инструкция ActionCall не заносит на стек возвращаемое значение.
    // Генерация вызовов функций всегда подразумевает возвращаемое значение на
    // стеке. Эмулировать возвращаемое значение Undefined.
    WriteCmd(acPushUndefined);
  end
  else if LcFuncName = 'chr' then
  begin
    CheckArgCount(1);
    FArgs.ExprList[0].Compile;
    WriteCmd(acAsciiToChar);
  end
  else if LcFuncName = 'ord' then
  begin
    CheckArgCount(1);
    FArgs.ExprList[0].Compile;
    WriteCmd(acCharToAscii);
  end
  else if LcFuncName = 'substring' then
  begin
    CheckArgCount(3);
    FArgs.ExprList[0].Compile;
    FArgs.ExprList[1].Compile;
    FArgs.ExprList[2].Compile;
    WriteCmd(acStringExtract);
  end
  else if LcFuncName = 'mbord' then
  begin
    CheckArgCount(1);
    FArgs.ExprList[0].Compile;
    WriteCmd(acMBCharToAscii);
  end
  else if LcFuncName = 'mbchr' then
  begin
    CheckArgCount(1);
    FArgs.ExprList[0].Compile;
    WriteCmd(acMBAsciiToChar);
  end
  else if LcFuncName = 'mblength' then
  begin
    CheckArgCount(1);
    FArgs.ExprList[0].Compile;
    WriteCmd(acMBStringLength);
  end
  else if (LcFuncName = 'startdrag') then
  begin
    case FArgs.ExprList.Count of
      1:
        begin
          WriteCmd(acPushInteger, 0);
          WriteCmd(acPushInteger, 0);
          FArgs.ExprList[0].Compile;
          WriteCmd(acStartDrag);
        end;

      2:
        begin
          WriteCmd(acPushInteger, 0);
          FArgs.ExprList[1].Compile;
          FArgs.ExprList[0].Compile;
          WriteCmd(acStartDrag);
        end;

      6:
        begin
          FArgs.ExprList[2].Compile;
          FArgs.ExprList[3].Compile;
          FArgs.ExprList[4].Compile;
          FArgs.ExprList[5].Compile;
          WriteCmd(acPushInteger, 1);
          FArgs.ExprList[1].Compile;
          FArgs.ExprList[0].Compile;
          WriteCmd(acStartDrag);
        end;

    else
      raise EActionCompileError.CreateFmt(
        'Invalid parameters list in "startDrag" in line %d'#10 +
        '"startDrag" requires 1 (target), 2 (target+lock) or ' +
        '6 (target+lock+constraint) parameters',
        [SrcPos.Line]);
    end;
    WriteCmd(acPushUndefined); // смотри Call
  end
  else if LcFuncName = 'stopdrag' then
  begin
    CheckArgCount(0);
    WriteCmd(acEndDrag);
    WriteCmd(acPushUndefined); // смотри Call
  end
  else if LcFuncName = 'number' then
  begin
    CheckArgCount(1);
    FArgs.ExprList[0].Compile;
    WriteCmd(acToNumber);
  end
  else if LcFuncName = 'string' then
  begin
    CheckArgCount(1);
    FArgs.ExprList[0].Compile;
    WriteCmd(acToString);
  end
  else if LcFuncName = 'gettimer' then
  begin
    CheckArgCount(0);
    WriteCmd(acGetTime);
  end
  else if LcFuncName = 'getproperty' then
  begin
    // getProperty ------------------------------------------------------------
    CheckArgCount(2);
    if not (FArgs.ExprList[1] is TLvalueNode) or
      not ((FArgs.ExprList[1] as TLvalueNode).FExpr is TStrNode) then
    begin
      raise EActionCompileError.CreateFmt(
        'Invalid parameters list in "getProperty" in line %d',
        [SrcPos.Line]);
    end;

    with (FArgs.ExprList[1] as TLvalueNode).FExpr as TStrNode do
      PropName := LowerCase(St[StrId]);
    PropIdx := GetStdPropIdx(PropName);
    if PropIdx = -1 then
    begin
      raise EActionCompileError.CreateFmt(
        'Invalid property name in "getProperty" in line %d',
        [SrcPos.Line]);
    end;
    FArgs.ExprList[0].Compile;
    WriteCmd(acPushInteger, PropIdx);
    WriteCmd(acGetProperty);
  end
  else if LcFuncName = 'setproperty' then
  begin
    // setProperty ------------------------------------------------------------
    CheckArgCount(3);
    if not (FArgs.ExprList[1] is TLvalueNode) or
      not ((FArgs.ExprList[1] as TLvalueNode).FExpr is TStrNode) then
    begin
      raise EActionCompileError.CreateFmt(
        'Invalid parameters list in "setProperty" in line %d',
        [SrcPos.Line]);
    end;

    with (FArgs.ExprList[1] as TLvalueNode).FExpr as TStrNode do
      PropName := LowerCase(St[StrId]);
    PropIdx := GetStdPropIdx(PropName);
    if PropIdx = -1 then
    begin
      raise EActionCompileError.CreateFmt(
        'Invalid property name in "getProperty" in line %d',
        [SrcPos.Line]);
    end;
    FArgs.ExprList[0].Compile;
    WriteCmd(acPushInteger, PropIdx);
    FArgs.ExprList[2].Compile;
    WriteCmd(acSetProperty);
    WriteCmd(acPushUndefined); // смотри Call
  end
  else if LcFuncName = 'geturl' then
  begin
    // getURL -----------------------------------------------------------------
    case FArgs.ExprList.Count of
      1:
        begin
          FArgs.ExprList[0].Compile;
          WriteCmd(acPushString, St.EmptyStrId);
          WriteCmd(acGetUrl2, VarArrayOf([False, False, 0]));
        end;

      2:
        begin
          FArgs.ExprList[0].Compile;
          FArgs.ExprList[1].Compile;
          WriteCmd(acGetUrl2, VarArrayOf([False, False, 0]));
        end;

      3:
        begin
          FArgs.ExprList[0].Compile;
          FArgs.ExprList[1].Compile;

          if not (FArgs.ExprList[2] is TStrNode) then
          begin
            raise EActionCompileError.CreateFmt(
              'Invalid parameters 3 in "getUrl" in line %d',
              [SrcPos.Line]);
          end;

          with FArgs.ExprList[2] as TStrNode do
            GetUrlMethod := LowerCase(St[StrId]);

          if GetUrlMethod = 'get' then
            WriteCmd(acGetUrl2, VarArrayOf([False, False, 1]))
          else
            WriteCmd(acGetUrl2, VarArrayOf([False, False, 2]));
        end;
    else
      raise EActionCompileError.CreateFmt(
        'Invalid parameters list in "getUrl" in line %d'#10 +
        '"getUrl" requires 1, 2 or 3 parameters',
        [SrcPos.Line]);
    end;
    WriteCmd(acPushUndefined); // смотри Call
  end
  else if (LcFuncName = 'loadmovie') or (LcFuncName = 'loadmovienum') then
  begin
    // loadMovie, loadMovieNum ------------------------------------------------
    case FArgs.ExprList.Count of
      2:
        GetUrl2Params := VarArrayOf([True, False, 0]);
      3:
        begin
          if not (FArgs.ExprList[2] is TStrNode) then
          begin
            raise EActionCompileError.CreateFmt(
              'Invalid parameters 3 in "loadMovie" in line %d',
              [SrcPos.Line]);
          end;

          with FArgs.ExprList[2] as TStrNode do
            GetUrlMethod := LowerCase(St[StrId]);

          if GetUrlMethod = 'get' then
            GetUrl2Params := VarArrayOf([True, False, 1])
          else
            GetUrl2Params := VarArrayOf([True, False, 2]);
        end;
    else
      raise EActionCompileError.CreateFmt(
        'Invalid parameters list in "loadMovie" in line %d'#10 +
        '"loadMovie" requires 2 or 3 parameters',
        [SrcPos.Line]);
    end;

    FArgs.ExprList[0].Compile;
    if LcFuncName = 'loadmovie' then
      FArgs.ExprList[1].Compile
    else
    begin
      if not (FArgs.ExprList[1] is TNumberNode) then
      begin
        raise EActionCompileError.CreateFmt(
          'Invalid parameters 2 in "loadMovieNum" in line %d',
          [SrcPos.Line]);
      end;

      WriteCmd(
        acPushString,
        '_level' + IntToStr(Trunc(TNumberNode(FArgs.ExprList[1]).FNumber)));
    end;

    WriteCmd(acGetUrl2, GetUrl2Params);
    WriteCmd(acPushUndefined); // смотри Call
  end
  else if (LcFuncName = 'loadvariables')
    or (LcFuncName = 'loadvariablesnum') then
  begin
    // loadVariables, loadVariablesNum ----------------------------------------
    case FArgs.ExprList.Count of
      2:
        GetUrl2Params := VarArrayOf([True, True, 0]);
      3:
        begin
          if not (FArgs.ExprList[2] is TStrNode) then
          begin
            raise EActionCompileError.CreateFmt(
              'Invalid parameters 3 in "loadMovie" in line %d',
              [SrcPos.Line]);
          end;

          with FArgs.ExprList[2] as TStrNode do
            GetUrlMethod := LowerCase(St[StrId]);

          if GetUrlMethod = 'get' then
            GetUrl2Params := VarArrayOf([True, True, 1])
          else
            GetUrl2Params := VarArrayOf([True, True, 2]);
        end;
    else
      raise EActionCompileError.CreateFmt(
        'Invalid parameters list in "loadVariables" in line %d'#10 +
        '"loadVariables" requires 2 or 3 parameters',
        [SrcPos.Line]);
    end;

    FArgs.ExprList[0].Compile;
    if LcFuncName = 'loadvariables' then
      FArgs.ExprList[1].Compile
    else
    begin
      if not (FArgs.ExprList[1] is TNumberNode) then
      begin
        raise EActionCompileError.CreateFmt(
          'Invalid parameters 2 in "loadVariablesNum" in line %d',
          [SrcPos.Line]);
      end;

      WriteCmd(
        acPushString,
        '_level' + IntToStr(Trunc(TNumberNode(FArgs.ExprList[1]).FNumber)));
    end;

    WriteCmd(acGetUrl2, GetUrl2Params);
    WriteCmd(acPushUndefined); // смотри Call
  end
  else if LcFuncName = 'duplicatemovieclip' then
  begin
    CheckArgCount(3);
    FArgs.ExprList[0].Compile;
    FArgs.ExprList[1].Compile;
    FArgs.ExprList[2].Compile;
    WriteCmd(acCloneSprite);
    WriteCmd(acPushUndefined); // смотри Call
  end
  else if LcFuncName = 'removemovieclip' then
  begin
    CheckArgCount(1);
    FArgs.ExprList[0].Compile;
    WriteCmd(acRemoveSprite);
    WriteCmd(acPushUndefined); // смотри Call
  end
  else if LcFuncName = 'play' then
  begin
    CheckArgCount(0);
    WriteCmd(acPlay);
    WriteCmd(acPushUndefined); // смотри Call
  end
  else if LcFuncName = 'stop' then
  begin
    CheckArgCount(0);
    WriteCmd(acStop);
    WriteCmd(acPushUndefined); // смотри Call
  end
  else if LcFuncName = 'nextframe' then
  begin
    CheckArgCount(0);
    WriteCmd(acNextFrame);
    WriteCmd(acPushUndefined); // смотри Call
  end
  else if LcFuncName = 'prevframe' then
  begin
    CheckArgCount(0);
    WriteCmd(acPreviousFrame);
    WriteCmd(acPushUndefined); // смотри Call
  end
  else if LcFuncName = 'stopallsounds' then
  begin
    CheckArgCount(0);
    WriteCmd(acStopSounds);
    WriteCmd(acPushUndefined); // смотри Call
  end
  else if (LcFuncName = 'gotoandplay') or (LcFuncName = 'gotoandstop') then
  begin
    if Context.Movie.Version > SWFVer4 then
    begin
      TParseTreeNode(FArgs.ExprList[0]).Compile;
      WriteCmd(acGotoFrame2, LcFuncName = 'gotoandplay');    
    end else
    begin
    case FArgs.ExprList.Count of
      1:
        begin
          if FArgs.ExprList[0] is TNumberNode then
          begin
            IntArgValue := Trunc(TNumberNode(FArgs.ExprList[0]).FNumber) - 1;
            WriteCmd(acGotoFrame, IntArgValue);
          end;
        end;
      2:
        begin
          IntArgValue := 0;
          if FArgs.ExprList[1] is TNumberNode then
            IntArgValue := Trunc(TNumberNode(FArgs.ExprList[1]).FNumber) - 1;
          WriteCmd(acGotoFrame, IntArgValue);
        end;
    else
      raise EActionCompileError.CreateFmt(
        'Invalid parameters list in "gotoAndPlay" in line %d'#10 +
        '"getUrl" requires 1 or 2 parameters',
        [SrcPos.Line]);
    end;

    if LcFuncName = 'gotoandplay' then
      WriteCmd(acPlay);

    WriteCmd(acPushUndefined); // См. Call
    end;
  end
  else if LcFuncName = 'set' then
  begin
    CheckArgCount(2);
    FArgs.FExprList[0].Compile;
    FArgs.FExprList[1].Compile;
    WriteCmd(acSetVariable);
  end
  else if (LcFuncName = 'unloadmovie')
    or (LcFuncName = 'unloadmovienum') then
  begin
    CheckArgCount(1);
    WriteCmd(acPushString, '');

    if LcFuncName = 'unloadmovie' then
      FArgs.ExprList[1].Compile
    else
    begin
      if not (FArgs.ExprList[1] is TNumberNode) then
      begin
        raise EActionCompileError.CreateFmt(
          'Invalid parameters 2 in "unloadMovieNum" in line %d',
          [SrcPos.Line]);
      end;

      WriteCmd(
        acPushString,
        '_level' + IntToStr(Trunc(TNumberNode(FArgs.ExprList[1]).FNumber)));
    end;

    WriteCmd(acGetUrl2, VarArrayOf([True, False, 0]));
    WriteCmd(acPushUndefined); // смотри Call
  end
  else if LcFuncName = 'fscommand' then
  begin
    CheckArgCount(2);
    if not (FArgs.ExprList[0] is TStrNode) then
    begin
      raise EActionCompileError.CreateFmt(
        'Invalid parameters 1 in "fscommand" in line %d',
        [SrcPos.Line]);
    end;

    if not (FArgs.ExprList[1] is TStrNode) then
    begin
      raise EActionCompileError.CreateFmt(
        'Invalid parameters 2 in "fscommand" in line %d',
        [SrcPos.Line]);
    end;

    FSCommandParams := VarArrayOf(['', '']);
    FSCommandParams[0] := St[TStrNode(FArgs.ExprList[0]).StrId];
    FSCommandParams[1] := St[TStrNode(FArgs.ExprList[1]).StrId];
    WriteCmd(acFSCommand, FSCommandParams);
  end
  else if LcFuncName = 'fscommand2' then
  begin
    if FArgs.ExprList.Count = 0 then
    begin
      raise EActionCompileError.CreateFmt(
        'Invalid parameters list in "fscommand2" in line %d'#10,
        [SrcPos.Line]);
    end;

    for I := FArgs.ExprList.Count - 1 downto 0 do
      FArgs.ExprList[I].Compile;
    WriteCmd(acPushInteger, FArgs.ExprList.Count);
    WriteCmd(acFSCommand2);
  end
  else
    Result := False;
end;

function TFuncCallNode.CompileCastOp: Boolean;
var
  FullClassName: TCompoundName;
  I: Integer;
  IntfInfo: TClassInfo;
begin
  Result := False;

  if not (nfNew in Flags) then
  begin
    IntfInfo := nil;
    if (FFuncNameInfo <> nil) and (FFuncNameInfo is TClassInfo) then
      IntfInfo := FFuncNameInfo as TClassInfo
    else if FClassNameInfo <> nil then
      IntfInfo := FClassNameInfo;

    if IntfInfo <> nil then
    begin
      if FArgs.ExprList.Count <> 1 then
      begin
        raise EActionCompileError.CreateFmt(
          'Invalid cast operation in line %d'#10 +
          'Requires 1 parameter.',
          [SrcPos.Line]);
      end;

      // Занести на стек объект-конструктор интерфейса
      FullClassName := TCompoundName.Parse(IntfInfo.IdentId);
      WriteCmd(acPushConstant, St.GlobalStrId);
      WriteCmd(acGetVariable);
      for I := 0 to FullClassName.Count - 1 do
      begin
        WriteCmd(acPushConstant, FullClassName[I]);
        WriteCmd(acGetMember);
      end;

      // Занести на стек аргумент Cast-операции
      FArgs.ExprList[0].Compile;
      WriteCmd(acCastOp);

      Result := True;
    end;
  end;
end;

procedure TFuncCallNode.Compile;
begin
  if not CompileBuiltIn and not CompileCastOp then
  begin
    ResolveFuncName;
    FArgs.Compile;
    if FObjRef = nil then
      // Вызов функции
      CompileFuncCall
    else
    begin
      // Вызов метода.
      FObjRef.Compile;
      WriteCmd(acPushConstant, FFuncNameId);
      if nfNew in Flags then
        WriteCmd(acNewMethod)
      else
        WriteCmd(acCallMethod);
    end;
  end;
  CheckDiscardResult;
end;

procedure TFuncCallNode.CheckUsedClass;
var
  NewClassName: TCompoundName;
  NewClassInfo: TClassInfo;
begin
  Assert(nfNew in Flags);
  if FObjRef is TLvalueNode then
  begin
    // Попытаться найти класс с составным именем ObjRef.MethodName
    // Если такой класс будет найден - пометить его как используемый(cifUsed).
    NewClassName := (FObjRef as TLvalueNode).GetCompoundName;
    if NewClassName <> nil then
    begin
      NewClassName.Add(FFuncNameId);
      NewClassInfo := Context.CurScope.FindClassIdent(NewClassName.Full);
      if NewClassInfo <> nil then
        with NewClassInfo do
          State := State + [cifUsed];
    end;
  end;
end;

end.


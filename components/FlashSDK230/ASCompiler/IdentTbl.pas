//*******************************************************//
//                                                       //
//                      DelphiFlash.com                  //
//         Copyright (c) 2004-2007 FeatherySoft, Inc.    //
//                    info@delphiflash.com               //
//                                                       //
//*******************************************************//

//  Description:  ActionScript Compiler for Flash level
//  Last update:  22 mar 2007
unit IdentTbl;

interface

uses
  SysUtils, Classes, StrTbl, ObjVec, ParseTreeBase, ConstPool;

type
  TScopeKind = (skLocal, skClass, skGlobal);
  {
    Допустимая иерархия областей видимости:
    ------------------------------
    skGlobal(TProgramNode)            Action или AS-файл
        skLocal(TFuncDefNode)         функция внутри Action
          skLocal(TFuncDefNode)       функция, вложенная в другую функцию.
        skClass(TClassDefNode)        класс внутри Action или AS-файла
            skLocal(TFuncDefNode)     метод внутри класса
            skClass(TClassDefNode)    производный класс
    ------------------------------
  }

  TBaseIdentTable = class;
  TIdentTable = class;

  TIdentFlag = (idVar, idFunc, idStatic, idPublic, idPrivate);
  TIdentFlags = set of TIdentFlag;

  TIdentInfo = class(TObject)
    IdentId, TypeNameId: TStrId;
    ScopeKind: TScopeKind;
    RegisterNum: Integer;
    Flags: TIdentFlags;
    Owner: TBaseIdentTable;
    constructor Create(AIdentId: TStrId; AScopeKind: TScopeKind;
      ATypeNameId: TStrId);
  end;

  TCompileUnit = class(TObject)
  private
    FParseTreeRoot: TParseTreeNode;
    FCompileTarget: TObject;
    FNodeFreeList: INodeList;
    FConstantPool: TConstantPool;
  public
    constructor Create(ACompileTarget: TObject);
    destructor Destroy; override;
    procedure AddToFreeList(AObject: TObject);
    property ParseTreeRoot: TParseTreeNode
      read FParseTreeRoot write FParseTreeRoot;
    property CompileTarget: TObject read FCompileTarget;
    property ConstantPool: TConstantPool read FConstantPool;
  end;

  TClassInfoFlag = (cifUsed, cifCodeGenerated, cifIntrinsic);
  TClassInfoFlags = set of TClassInfoFlag;
  TSuperClassNames = array of TStrId;

  TClassInfo = class(TIdentInfo)
  private
    FClassDefTable: TIdentTable;
    FSourceFile: string;
    FState: TClassInfoFlags;
    FCompileUnit: TCompileUnit;
  public
    destructor Destroy; override;
    function GetSuperTypesList: TStrIdArray;
    procedure CheckSuperClassLink;
    property ClassDefTable: TIdentTable read FClassDefTable write
      FClassDefTable;
    property SourceFile: string read FSourceFile;
    property State: TClassInfoFlags read FState write FState;
    property CompileUnit: TCompileUnit read FCompileUnit write FCompileUnit;
  end;

  TAliasInfo = class(TIdentInfo)
  private
    FRefClassInfo: TClassInfo;
  public
    property RefClassInfo: TClassInfo read FRefClassInfo;
  end;

  TItemRef = TIdentInfo;

{$INCLUDE ObjVec.inc}

  TPreloadFlag = (pfThis, pfSuper, pfArguments);
  TPreloadFlags = set of TPreloadFlag;
  TFindIdentOption = (fioInParent, fioInSuperClass);
  TFindIdentOptions = set of TFindIdentOption;

  TBaseIdentTable = class(TObject)
  private
    FItems: IVector;
    FScopeKind: TScopeKind;

    // FParent - охватывающая область видимости
    FParent: TBaseIdentTable;
    // FSuperClass - область видимости базового класса.
    // Только для FScopeKind = skClass
    FSuperClass: TBaseIdentTable;
    // FFullClassName - полное имя класса, к которому относится
    // данная таблица имен. Только для FScopeKind = skClass
    FFullClassName: TCompoundName;

  protected
    function EqualsIdent(Ident1, Ident2: TStrId): Boolean; virtual;

  public
    constructor Create(AParent: TBaseIdentTable; AScopeKind: TScopeKind);

    function AddIdent(AIdentId: TStrId; ATypeNameId: TStrId = -1): TIdentInfo;
    function AddClassIdent(AIdentId: TStrId): TClassInfo;
    procedure AddClassAlias(AIdentId: TStrId; AClassInfo: TClassInfo);

    function FindIdent(
      AIdentId: TStrId; AOptions: TFindIdentOptions): TIdentInfo;
    function FindClassIdent(
      AIdentId: TStrId): TClassInfo;

    procedure SetFullClassName(AFullClassName: TCompoundName);

    property Items: IVector read FItems;
    property ScopeKind: TScopeKind read FScopeKind;
    property Parent: TBaseIdentTable read FParent write FParent;
    property SuperClass: TBaseIdentTable read FSuperClass write FSuperClass;
    property FullClassName: TCompoundName read FFullClassName;

{$IFDEF DEBUG}
  public
    DebugName: string;
    procedure WriteToListing; virtual;
{$ENDIF}
  end;

  TIdentTable = class(TBaseIdentTable)
  private
    // Назначение регистров. Только skLocal
    FAssignTmpRegister: Integer;
    FPreloadFlags: TPreloadFlags;
    FThisIdentInfo, FSuperIdentInfo, FArgumentsIdentInfo: TIdentInfo;
    FRegisterCount: Integer;
    FImplicitSuperCall: Boolean;

  public
    constructor Create(AParent: TBaseIdentTable; AScopeKind: TScopeKind);

    procedure SetPreloadFlag(AFlag: TPreloadFlag);
    procedure AssignRegisters;

    property PreloadFlags: TPreloadFlags read FPreloadFlags;
    property RegisterCount: Integer read FRegisterCount;
    property ImplicitSuperCall: Boolean
      read FImplicitSuperCall write FImplicitSuperCall;
    property AssignTmpRegister: Integer read FAssignTmpRegister;

{$IFDEF DEBUG}
  public
    procedure WriteToListing; override;
{$ENDIF}
  end;

  TClassTable = class(TBaseIdentTable)
  protected
    function EqualsIdent(Ident1, Ident2: TStrId): Boolean; override;

  public
    procedure LoadFromPackage(PackagePath: string; PackagePrefix: string = '');

{$IFDEF DEBUG}
  public
    procedure WriteToListing; override;
{$ENDIF}
  end;

implementation

uses
  GUtils, ParseTreeDecl, ActionCompiler, SWFConst, StdClassName;

{$DEFINE IMPL}

{$INCLUDE ObjVec.inc}

{ TIdentInfo }

constructor TIdentInfo.Create(AIdentId: TStrId; AScopeKind: TScopeKind;
  ATypeNameId: TStrId);
begin
  inherited Create;
  IdentId := AIdentId;
  ScopeKind := AScopeKind;
  TypeNameId := ATypeNameId;
end;

{ TCompileUnit }

constructor TCompileUnit.Create(ACompileTarget: TObject);
begin
  inherited Create;
  FCompileTarget := ACompileTarget;
  FNodeFreeList := TNodeList.Create(True);
  FConstantPool := TConstantPool.Create;
end;

destructor TCompileUnit.Destroy;
begin
  FreeAndNil(FConstantPool);
  inherited Destroy;
end;

procedure TCompileUnit.AddToFreeList(AObject: TObject);
begin
  FNodeFreeList.Add(AObject);
end;

{ TClassInfo }

destructor TClassInfo.Destroy;
begin
  FreeAndNil(FCompileUnit);
  inherited Destroy;
end;

function TClassInfo.GetSuperTypesList: TStrIdArray;
var
  ClassDefNode: TClassDefNode;
begin
  Assert(CompileUnit.ParseTreeRoot is TProgramNode);
  ClassDefNode := TProgramNode(CompileUnit.ParseTreeRoot).FindClassDefNode;
  Assert(ClassDefNode <> nil);
  Result := ClassDefNode.GetSuperTypesList;
end;

procedure TClassInfo.CheckSuperClassLink;
var
  ClassDefNode: TClassDefNode;
begin
  {
    В ситуации, когда на первом проходе компиляции при обработке производного
    класса базовый класс еще не обработан и таблица имен для него не существует,
    связь таблиц имен производного и базового классов отсутствует.
    Перед вторым проходом необходимо установить эту связь.
  }
  Assert(CompileUnit.ParseTreeRoot is TProgramNode);
  ClassDefNode := TProgramNode(CompileUnit.ParseTreeRoot).FindClassDefNode;
  Assert(ClassDefNode <> nil);
  ClassDefNode.CheckSuperClassLink;
end;

{ TBaseIdentTable }

constructor TBaseIdentTable.Create(AParent: TBaseIdentTable;
  AScopeKind: TScopeKind);
begin
  inherited Create;
  FItems := TVector.Create(True);
  FParent := AParent;
  FSuperClass := nil;
  FScopeKind := AScopeKind;
end;

function TBaseIdentTable.EqualsIdent(Ident1, Ident2: TStrId): Boolean;
begin
  Result := (Ident1 = Ident2);
end;

function TBaseIdentTable.AddIdent(AIdentId: TStrId;
  ATypeNameId: TStrId): TIdentInfo;
begin
  FItems.Add(TIdentInfo.Create(AIdentId, ScopeKind, ATypeNameId));
  Result := FItems[FItems.Count - 1];
  Result.Owner := Self;
end;

function TBaseIdentTable.AddClassIdent(AIdentId: TStrId): TClassInfo;
begin
  // Классы ActionScript 2.0 могут присутствовать в таблице имен только
  // в одном экземпляре. Имена таких классов не могут быть перекрыты.
  Result := FindClassIdent(AIdentId);
  if Result = nil then
  begin
    FItems.Add(TClassInfo.Create(AIdentId, ScopeKind, -1));
    Result := FItems[FItems.Count - 1] as TClassInfo;
    Result.Owner := Self;
  end;
end;

procedure TBaseIdentTable.AddClassAlias(AIdentId: TStrId;
  AClassInfo: TClassInfo);
var
  AliasInfo: TAliasInfo;
begin
  // При импортировании класса ( import Package1.Package2.ClassName; )
  // в текущей области видимости создается алиас для данного класса.
  AliasInfo := TAliasInfo.Create(AIdentId, ScopeKind, -1);
  AliasInfo.FRefClassInfo := AClassInfo;
  FItems.Add(AliasInfo);
  AliasInfo.Owner := Self;
end;

function TBaseIdentTable.FindIdent(
  AIdentId: TStrId; AOptions: TFindIdentOptions): TIdentInfo;
var
  I: Integer;
begin
  Result := nil;
  for I := FItems.Count - 1 downto 0 do
    with FItems[I] do
      if EqualsIdent(IdentId, AIdentId) then
      begin
        Result := FItems[I];
        if Result is TAliasInfo then
          Result := TAliasInfo(Result).RefClassInfo;
        Exit;
      end;

  if (fioInSuperClass in AOptions) and (FSuperClass <> nil) then
  begin
    Assert(FScopeKind = skClass);
    Result := FSuperClass.FindIdent(AIdentId, [fioInSuperClass]);
  end;

  if (Result = nil) and (fioInParent in AOptions) and (FParent <> nil) then
    Result := FParent.FindIdent(AIdentId, AOptions);
end;

function TBaseIdentTable.FindClassIdent(AIdentId: TStrId): TClassInfo;
var
  I: Integer;
begin
  Result := nil;
  for I := FItems.Count - 1 downto 0 do
    with FItems[I] do
      if EqualsIdent(IdentId, AIdentId) then
      begin
        if FItems[I] is TClassInfo then
        begin
          Result := FItems[I] as TClassInfo;
          Exit;
        end;

        if FItems[I] is TAliasInfo then
        begin
          Result := TAliasInfo(FItems[I]).RefClassInfo;
          Exit;
        end;
      end;

  if FParent <> nil then
    Result := FParent.FindClassIdent(AIdentId);
end;

procedure TBaseIdentTable.SetFullClassName(AFullClassName: TCompoundName);
begin
  Assert(ScopeKind = skClass);
  FFullClassName := AFullClassName; 
end;

{$IFDEF DEBUG}

procedure TBaseIdentTable.WriteToListing;
begin

end;
{$ENDIF}

{ TIdentTable }

constructor TIdentTable.Create(AParent: TBaseIdentTable; AScopeKind:
  TScopeKind);
begin
  inherited Create(AParent, AScopeKind);
  Context.AddToFreeList(Self);

  FAssignTmpRegister := 0;
  FRegisterCount := 1;
  FImplicitSuperCall := True;
end;

procedure TIdentTable.SetPreloadFlag(AFlag: TPreloadFlag);
begin
  if not (AFlag in PreloadFlags) then
  begin
    case AFlag of
      pfThis:
        begin
          FThisIdentInfo := AddIdent(St.ThisStrId, St.EmptyStrId);
          Include(FThisIdentInfo.Flags, idVar);
        end;
      pfSuper:
        begin
          FSuperIdentInfo := AddIdent(St.SuperStrId, St.EmptyStrId);
          Include(FSuperIdentInfo.Flags, idVar);
        end;
      pfArguments:
        begin
          FArgumentsIdentInfo := AddIdent(St.ArgumentsStrId, St.EmptyStrId);
          Include(FArgumentsIdentInfo.Flags, idVar);
        end;
    end;
    Include(FPreloadFlags, AFlag);
  end;
end;

procedure TIdentTable.AssignRegisters;
var
  I, J: Integer;
begin
  Assert(ScopeKind = skLocal);

  if pfThis in PreloadFlags then
  begin
    FThisIdentInfo.RegisterNum := FRegisterCount;
    Inc(FRegisterCount);
  end;

  if pfArguments in PreloadFlags then
  begin
    FArgumentsIdentInfo.RegisterNum := FRegisterCount;
    Inc(FRegisterCount);
  end;

  if pfSuper in PreloadFlags then
  begin
    FSuperIdentInfo.RegisterNum := FRegisterCount;
    Inc(FRegisterCount);
  end;

  if coLocalVarToRegister in Context.CompileOptions then
  begin
    for I := 0 to FItems.Count - 1 do
      if (FItems[I] <> FThisIdentInfo)
        and (FItems[I] <> FArgumentsIdentInfo)
        and (FItems[I] <> FSuperIdentInfo)
        and (FItems[I].RegisterNum = 0) then
      begin
        // Попробовать найти текущий идентификатор среди тех, для которых уже
        // назначен регистр. В случае повторного объявления идентификатора
        // использовать один и тот же регистр.
        for J := 0 to I - 1 do
          if (FItems[J].IdentId = FItems[I].IdentId) and
            (FItems[J].RegisterNum > 0) then
          begin
            FItems[I].RegisterNum := FItems[J].RegisterNum;
            Break;
          end;
        if FItems[I].RegisterNum = 0 then
        begin
          FItems[I].RegisterNum := FRegisterCount;
          Inc(FRegisterCount);
          if FRegisterCount > 254 then
            Break;
        end;    
      end;
  end;
end;

{$IFDEF DEBUG}

procedure TIdentTable.WriteToListing;
var
  IdentTableStr: string;
  I: Integer;
  IdentId: TStrId;
  Scope: string;
  IdentKind: string;
begin
  IdentTableStr := #13#10'  IdentTable ' + DebugName;
  if (Parent <> nil) and (Parent is TIdentTable) then
    IdentTableStr := IdentTableStr + ' parent ' + TIdentTable(Parent).DebugName;

  IdentTableStr := IdentTableStr + #13#10;

  if ImplicitSuperCall then
    IdentTableStr := IdentTableStr + '    ImpicitSuperCall True'#13#10
  else
    IdentTableStr := IdentTableStr + '    ImpicitSuperCall False'#13#10;

  for I := 0 to Items.Count - 1 do
  begin
    IdentId := Items[I].IdentId;

    case Items[I].ScopeKind of
      skLocal: Scope := 'local ';
      skClass: Scope := 'class ';
      skGlobal: Scope := 'global';
    else
      Scope := '?     ';
    end;

    if idVar in Items[I].Flags then
      IdentKind := 'var '
    else if idFunc in Items[I].Flags then
      IdentKind := 'func'
    else
      IdentKind := '    ';

    if Items[I].RegisterNum = 0 then
      IdentTableStr := IdentTableStr + Format('       - %s %s %s'#13#10,
        [Scope, IdentKind, St[IdentId]])
    else
      IdentTableStr := IdentTableStr + Format('    %4d %s %s %s'#13#10,
        [Items[I].RegisterNum, Scope, IdentKind, St[IdentId]]);
  end;
  IdentTableStr := IdentTableStr +
    '  End IdentTable ' + DebugName + #13#10#13#10;

  Context.Listing.Write(PChar(IdentTableStr)^, Length(IdentTableStr));
end;
{$ENDIF}

{ TClassTable }

function TClassTable.EqualsIdent(Ident1, Ident2: TStrId): Boolean;
begin
  Result := UpperCase(St[Ident1]) = UpperCase(St[Ident2]);
end;

procedure TClassTable.LoadFromPackage(PackagePath: string; PackagePrefix: string);
var
  SearchRec: TSearchRec;
  ClassInfo: TClassInfo;
  ClassName, PackageName: string;
  ClassNameId: TStrId;
begin
  if PackagePrefix = CompoundNameDelimiter then PackagePrefix := '';
  PackagePath := IncludeTrailingPathDelimiter(PackagePath);
  if FindFirst(PackagePath + '*.as', 0, SearchRec) = 0 then
    repeat
      if (SearchRec.Attr and faDirectory) <> 0 then
        Continue;
      ClassName := Copy(SearchRec.Name, 1, Length(SearchRec.Name) - 3);
//      if not IsStandartClassName(PackagePrefix + ClassName) then
      begin
        ClassNameId := St.AddItem(PackagePrefix + ClassName);
        ClassInfo := AddClassIdent(ClassNameId);
        ClassInfo.FSourceFile := PackagePath + SearchRec.Name;
        if IsStandartClassName(PackagePrefix + ClassName) then
          ClassInfo.State := [cifIntrinsic];
        Context.AddIncludePath(PackagePath);
      end;

    until FindNext(SearchRec) <> 0;

  if FindFirst(PackagePath + '*.*', faDirectory, SearchRec) = 0 then
    repeat
//      PackageName := SearchRec.Name;
//      if (PackageName = '.') or (PackageName = '..') then
//        Continue;
//      LoadFromPackage(
//        PackagePath + PackageName,
//        PackagePrefix + PackageName + CompoundNameDelimiter);

      if (SearchRec.Name = '.') or (SearchRec.Name = '..') or
         ((Uppercase(SearchRec.Name) = 'FP7') and (Context.Movie.Version <> SWFVer7)) or
         ((Uppercase(SearchRec.Name) = 'FP9') and (Context.Movie.Version <> SWFVer9)) or
         ((Uppercase(SearchRec.Name) = 'FP8') and (Context.Movie.Version < SWFVer8))
      then
        Continue;


      if (Uppercase(SearchRec.Name) = 'FP7') or
         (Uppercase(SearchRec.Name) = 'FP8') or
         (Uppercase(SearchRec.Name) = 'FP9')
         then PackageName := ''
         else PackageName := SearchRec.Name;

      LoadFromPackage(PackagePath + SearchRec.Name,
                      PackagePrefix + PackageName + CompoundNameDelimiter);
    until FindNext(SearchRec) <> 0;
end;

{$IFDEF DEBUG}

procedure TClassTable.WriteToListing;
var
  IdentTableStr, UseStr: string;
  I: Integer;
  IdentId: TStrId;
begin
  IdentTableStr := '  ClassTable '#13#10;

  for I := 0 to Items.Count - 1 do
  begin
    IdentId := Items[I].IdentId;
    with Items[I] as TClassInfo do
      if cifUsed in State then
        UseStr := '+'
      else
        UseStr := ' ';
    IdentTableStr := IdentTableStr + Format('       %s %s'#13#10,
      [UseStr, St[IdentId]]);
  end;
  IdentTableStr := IdentTableStr + '  End ClassTable '#13#10;

  Context.Listing.Write(PChar(IdentTableStr)^, Length(IdentTableStr));
end;
{$ENDIF}

end.


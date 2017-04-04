unit ParseTreeBase;

interface

uses
  SysUtils, Classes, ObjVec, StrTbl;

const
  CompoundNameDelimiter = '.';  

type
  EActionCompileError = class(Exception);

  TNodeFlag = (nfDiscardResult, nfReference, nfNew, nfInitObject, nfInitArray,
    nfDoWhile, nfPostfix, nfCommaExpr, nfClassMember, nfGetProp, nfSetProp);

  TNodeFlags = set of TNodeFlag;

  TSourcePos = record
    FileName: string;
    Line, Col: Integer;
  end;

  TParseTreeNode = class(TObject)
  private
    FFlags: TNodeFlags;
    FSrcPos: TSourcePos;
  protected
    procedure CheckDiscardResult;
  public
    procedure AfterConstruction; override;
    procedure Compile; virtual;
    procedure SetFlag(Flag: TNodeFlag);
    property Flags: TNodeFlags read FFlags;
    property SrcPos: TSourcePos read FSrcPos write FSrcPos;
  end;

  TPairNode = class(TParseTreeNode)
  public
    First, Second: TParseTreeNode;
  end;

  TSourcePosNode = class(TParseTreeNode)
  public
    Value: TSourcePos;
  end;

  TItemRef = TParseTreeNode;

{$INCLUDE ObjVec.inc}

  INodeList = IVector;
  TNodeList = TVector;

  TCompoundName = class(TParseTreeNode)
  private
    FItems: array of TStrId;
    FLen: Integer;
    FFull: TStrId;
    function GetFull: TStrId;
    function GetLast: TStrId;
    function GetCount: Integer;
    function GetItem(I: Integer): TStrId;
  public
    constructor Create(AIdent: TStrId);
    constructor Parse(AIdent: TStrId); 
    procedure Add(AIdent: TStrId);
    property Full: TStrId read GetFull;
    property Last: TStrId read GetLast;
    property Items[I: Integer]: TStrId read GetItem; default;
    property Count: Integer read GetCount;
  end;

function StrToken2(var Str: string; const Separators: string): string;  

implementation

uses
  GUtils, ActionCompiler;

{$DEFINE IMPL}

{$INCLUDE ObjVec.inc}  

{ TParseTreeNode }

procedure TParseTreeNode.AfterConstruction;
begin
  inherited AfterConstruction;
  Context.AddToFreeList(Self);
  {
    Вызов AddToFreeList нельзя поместить в конструктор базового класса,
    так как в конструкторе производного класса уже после вызова конструктора
    базового класса и добавления объекта в список FreeList может произойти
    исключение. В такой ситуации автоматически вызывается деструктор и
    объект разрушается, но ссылка на него остается в FreeList. При освобождении
    FreeList будет произведена попытка уничножить несуществующий объект.
  }
end;

procedure TParseTreeNode.Compile;
begin
end;

procedure TParseTreeNode.SetFlag(Flag: TNodeFlag);
begin
  FFlags := FFlags + [Flag];
end;

procedure TParseTreeNode.CheckDiscardResult;
begin
  if nfDiscardResult in Flags then
    WriteCmd(acPop);
end;

{ TCompoundName }

function StrToken2(var Str: string; const Separators: string): string;
var
  L, I, J: Integer;
begin
  L := Length(Str);
  I := 1;
  while (I <= L) and (Pos(Str[I], Separators) > 0) do
    Inc(I);
  if I > L then
  begin
    Str := '';
    Result := '';
  end
  else
  begin
    J := I + 1;
    while (J <= L) and (Pos(Str[J], Separators) = 0) do
      Inc(J);
    Result := Copy(Str, I, J - I);
    Str := Copy(Str, J, L);
  end;
end;

constructor TCompoundName.Create(AIdent: TStrId);
begin
  inherited Create;
  SetLength(FItems, 4);
  FFull := -1;
  Add(AIdent);
end;

constructor TCompoundName.Parse(AIdent: TStrId);
var
  IdentStr, ItemStr: string;
begin
  inherited Create;
  SetLength(FItems, 4);
  FFull := -1;

  IdentStr := St[AIdent];
  ItemStr := StrToken2(IdentStr, CompoundNameDelimiter);
  if ItemStr = '' then
    Add(AIdent)
  else
    repeat
      Add(St.AddItem(ItemStr));
      ItemStr := StrToken2(IdentStr, CompoundNameDelimiter);
    until ItemStr = '';
end;

procedure TCompoundName.Add(AIdent: TStrId);
begin
  if FLen = Length(FItems) then
    SetLength(FItems, FLen + 4);
  FItems[FLen] := AIdent;
  Inc(FLen);
end;

function TCompoundName.GetFull: TStrId;
var
  FullStr: string;
  I: Integer;
begin
  if FFull = -1 then
  begin
    FullStr := St[FItems[0]];
    for I := 1 to FLen - 1 do
      FullStr := FullStr + CompoundNameDelimiter + St[FItems[I]];
    FFull := St.AddItem(FullStr);
  end;
  Result := FFull;
end;

function TCompoundName.GetLast: TStrId;
begin
  Result := FItems[FLen - 1];
end;

function TCompoundName.GetCount: Integer;
begin
  Result := FLen;
end;

function TCompoundName.GetItem(I: Integer): TStrId;
begin
  Assert((I >= 0) and (I < Count));
  Result := FItems[I];
end;

end.

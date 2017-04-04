
{$UNDEF  ITEM_REF_IS_PTR}
{$DEFINE ITEM_FREE_FUNC}
{$UNDEF  CMP_FUNC}
{$DEFINE VECTOR_ENABLE_MOVE}

unit ObjVec;

interface

type
  TItem = TObject;

{$INCLUDE Vector.inc}

  IBaseObjectVector = IBaseVector;

  TBaseObjectVector = class(TBaseVector)
  private
    FIsOwner: Boolean;
  public
    constructor Create(AIsOwner: Boolean = True);
    function GetIsOwner: Boolean;
    procedure SetIsOwner(Value: Boolean);
    property IsOwner: Boolean read GetIsOwner write SetIsOwner;
  end;

  IObjectVector = interface(IBaseObjectVector)
    function  GetAt(I: Integer): TObject;
    procedure SetAt(I: Integer; const Item: TObject);
    function Peek: TObject;
    function GetIsOwner: Boolean;
    procedure SetIsOwner(Value: Boolean);
    property Items[I: Integer]: TObject read GetAt write SetAt; default;
    property IsOwner: Boolean read GetIsOwner write SetIsOwner;
  end;

  TObjectVector = class(TBaseObjectVector, IObjectVector)
  public
    function  GetAt(I: Integer): TObject;
    procedure SetAt(I: Integer; const Item: TObject);
    function Peek: TObject;
    property Items[I: Integer]: TObject read GetAt write SetAt; default;
  end;

implementation

{$DEFINE IMPL}

uses
  SysUtils, GUtils;

procedure ItemFree(var Item: TItem; BaseVector: TBaseVector);
begin
  if TBaseObjectVector(BaseVector).IsOwner then
    FreeAndNil(Item);
end;

constructor TBaseObjectVector.Create(AIsOwner: Boolean = True);
begin
  inherited Create;
  FIsOwner := AIsOwner;
end;

function TBaseObjectVector.GetIsOwner: Boolean;
begin
  Result := FIsOwner;
end;

procedure TBaseObjectVector.SetIsOwner(Value: Boolean);
begin
  FIsOwner := Value;
end;

{$include Vector.inc}

function TObjectVector.GetAt(I: Integer): TObject;
begin
  CheckIndex(I);
  Result := FData[I];
end;

function TObjectVector.Peek: TObject;
begin
  if Count <= 0 then
    raise EVectorRangeError.CreateFmt(
      '%s: Invalid Peek call. Vector is empty.', [Self.ClassName]);
  Result := FData[Count - 1];
end;

procedure TObjectVector.SetAt(I: Integer; const Item: TObject);
begin
  CheckIndex(I);
  if (Item <> FData[I]) and IsOwner then
    FreeAndNil(FData[I]);
  FData[I] := Item;
end;


end.


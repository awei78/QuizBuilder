{$undef ITEM_REF_IS_PTR}
{$undef ITEM_FREE_FUNC}
{$undef CMP_FUNC}
{$define VECTOR_ENABLE_MOVE}

unit ConstPool;

interface

uses
  SysUtils, StrTbl;

type
  TItem = TStrId;

{$INCLUDE Vector.inc}

  TConstantPool = class(TObject)
  private
    FItems: IVector;
    function GetConstant(StrId: TStrId): Integer;
  public
    constructor Create;
    property Constants[StrId: TStrId]: Integer read GetConstant; default;
    property Items: IVector read FItems;
  end;

implementation

uses
  GUtils;

{$DEFINE IMPL}

{$INCLUDE Vector.inc}


{ TConstantPool }

constructor TConstantPool.Create;
begin
  inherited Create;
  FItems := TVector.Create;
end;

function TConstantPool.GetConstant(StrId: TStrId): Integer;
var
  I: Integer;
begin
  for I := 0 to FItems.Count - 1 do
    if FItems[I] = StrId then
    begin
      Result := I;
      Exit;
    end;
  FItems.Add(StrId);
  Result := FItems.Count - 1; 
end;

end.


{$if not Defined(IMPL) }

  IVector = interface(IBaseObjectVector)
    function  GetAt(I: Integer): TItemRef;
    procedure SetAt(I: Integer; const Item: TItemRef);
    function Peek: TItemRef;
    function GetIsOwner: Boolean;
    procedure SetIsOwner(Value: Boolean);
    property Items[I: Integer]: TItemRef read GetAt write SetAt; default;
    property IsOwner: Boolean read GetIsOwner write SetIsOwner;
  end;

  TVector = class(TBaseObjectVector, IVector)     
  public
    function  GetAt(I: Integer): TItemRef;
    procedure SetAt(I: Integer; const Item: TItemRef);
    function Peek: TItemRef;
    property Items[I: Integer]: TItemRef read GetAt write SetAt; default;
  end;

{$else}

function TVector.GetAt(I: Integer): TItemRef;
begin
  CheckIndex(I);
  Result := FData[I] as TItemRef;
end;

function TVector.Peek: TItemRef;
begin
  if Count <= 0 then
    raise EVectorRangeError.CreateFmt(
      '%s: Invalid Peek call. Vector is empty.', [Self.ClassName]);
  Result := FData[Count - 1] as TItemRef;
end;

procedure TVector.SetAt(I: Integer; const Item: TItemRef);
begin
  CheckIndex(I);
  if (Item <> FData[I]) and IsOwner then
    FreeAndNil(FData[I]);
  FData[I] := Item;
end;

{$ifend}

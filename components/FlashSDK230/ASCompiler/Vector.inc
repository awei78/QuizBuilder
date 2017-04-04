
{$IF not Defined(IMPL)}

{$IFDEF ITEM_REF_IS_PTR}
  TItemRef = ^TItem;
{$ELSE}
  TItemRef = TItem;
{$ENDIF}

  TVectorCmpFunc = function(const Item1, Item2: TItem): Integer;

  TVectorSearchObj = class(TObject)
    function Cmp(const Item: TItem): Integer; virtual; abstract;
  end;

  TDataArrayType = array of TItem;

  IBaseVector = interface(IInterface)
    function  GetData: TDataArrayType;
    function  GetCount: Integer;
    function  GetCapacity: Integer;
    procedure SetCapacity(NewCapacity: Integer);
    procedure Clear;
    procedure Add(const Item: TItem);
    procedure Push(const Item: TItem);
    procedure Pop;
    procedure Insert(I: Integer; const Item: TItem);
    procedure Delete(I: Integer);
    procedure Remove(const Item: TItem);
    procedure Swap(I1, I2: Integer);
    function  IndexOf(const Item: TItem): Integer;
    procedure Sort(CmpFunc: TVectorCmpFunc);
    function  BinSearch(SearchObj: TVectorSearchObj): Integer;
    property Count: Integer read GetCount;
    property Capacity: Integer read GetCapacity write SetCapacity;
    property Data: TDataArrayType read GetData;
  end;

  TBaseVector = class(TInterfacedObject)
  protected
    FData: TDataArrayType;
    FCount: Integer;

    procedure CheckIndex(I: Integer);
    procedure Expand;
    procedure QuickSort(L, R: Integer; Cmp: TVectorCmpFunc);

  public
    constructor Create;
    destructor Destroy; override;

    function  GetData: TDataArrayType;
    function  GetCount: Integer;
    function  GetCapacity: Integer;
    procedure SetCapacity(NewCapacity: Integer);

    procedure Clear; virtual;
    procedure Add(const Item: TItem);
    procedure Push(const Item: TItem);
    procedure Pop;
    procedure Insert(I: Integer; const Item: TItem);
    procedure Delete(I: Integer);
    procedure Remove(const Item: TItem);
    procedure Swap(I1, I2: Integer);

    function  IndexOf(const Item: TItem): Integer;
    procedure Sort(CmpFunc: TVectorCmpFunc);
    function  BinSearch(SearchObj: TVectorSearchObj): Integer;

    property Count: Integer read GetCount;
    property Capacity: Integer read GetCapacity write SetCapacity;
    property Data: TDataArrayType read GetData;
  end;

  IVector = interface(IBaseVector)
    function  GetAt(I: Integer): TItemRef;
    procedure SetAt(I: Integer; const Item: TItemRef);
    function Peek: TItemRef;
    procedure Assign(Src: IVector); overload;
    procedure Assign(const Src: array of TItem); overload;
    property Items[I: Integer]: TItemRef read GetAt write SetAt; default;
  end;

  TVector = class(TBaseVector, IVector)
  public
    function  GetAt(I: Integer): TItemRef;
    procedure SetAt(I: Integer; const Item: TItemRef);
    function Peek: TItemRef;
    procedure Assign(Src: IVector); overload;
    procedure Assign(const Src: array of TItem); overload;
    property Items[I: Integer]: TItemRef read GetAt write SetAt; default;
  end;

{$ELSE}

const
  ItemSize = SizeOf(TItem);

procedure TBaseVector.CheckIndex(I: Integer);
var
  E: EVectorRangeError;
begin
  if (I < 0) or (I >= Count) then begin
    E := EVectorRangeError.CreateFmt(
      '%s: bounds check error. Incorrect index = %d',
      [Self.ClassName, I]);
    E.ErrInd := I;
    raise E;
  end;
end;

procedure TBaseVector.Expand;
var
  L, D: Integer;
begin
  L := Length(FData);
  if L > 64 then
    D := L div 4
  else if L > 8 then
    D := 16
  else
    D := 4;
  SetLength(FData, L + D);
end;

constructor TBaseVector.Create;
begin
  inherited Create;
  FCount := 0;
  SetLength(FData, 4);
end;

destructor TBaseVector.Destroy;
begin
  Clear;
  inherited Destroy;
end;

function TBaseVector.GetData: TDataArrayType;
begin
  Result := FData;
end;

function TBaseVector.GetCount: Integer;
begin
  Result := FCount;
end;

function TBaseVector.GetCapacity: Integer;
begin
  Result := Length(FData);
end;

procedure TBaseVector.SetCapacity(NewCapacity: Integer);
begin
  if NewCapacity > Length(FData) then
    SetLength(FData, NewCapacity);
end;

{$IFDEF ITEM_FREE_FUNC}
procedure TBaseVector.Clear;
var
  J: Integer;
begin
  for J := 0 to FCount - 1 do
    ItemFree(FData[J], Self);
  FCount := 0;
end;
{$ELSE}
procedure TBaseVector.Clear;
begin
  FCount := 0;
end;
{$ENDIF}

procedure TBaseVector.Add(const Item: TItem);
begin
  if FCount = Length(FData) then
    Expand;
  FData[FCount] := Item;
  Inc(FCount);
end;

procedure TBaseVector.Push(const Item: TItem);
begin
  Add(Item);
end;

procedure TBaseVector.Pop;
begin
  if Count <= 0 then
    raise EVectorRangeError.CreateFmt(
      '%s: Invalid Pop call. Vector is empty.', [Self.ClassName]);
  Delete(Count - 1);
end;

procedure TBaseVector.Insert(I: Integer; const Item: TItem);
{$IFNDEF VECTOR_ENABLE_MOVE}
var
  J: Integer;
{$ENDIF}
begin
  if I = FCount then
    Add(Item)
  else
  begin
    CheckIndex(I);
    if FCount = Length(FData) then
      Expand;
{$IFDEF VECTOR_ENABLE_MOVE}
    Move(FData[I], FData[I + 1], (FCount - I) * ItemSize);
{$ELSE}
    for J := FCount downto I + 1 do
      FData[J] := FData[J - 1];
{$ENDIF}
    FData[I] := Item;
    Inc(FCount);
  end;
end;

procedure TBaseVector.Delete(I: Integer);
{$IFNDEF VECTOR_ENABLE_MOVE}
var
  J: Integer;
{$ENDIF}
begin
  CheckIndex(I);

{$IFDEF ITEM_FREE_FUNC}
  ItemFree(FData[I], Self);
{$ENDIF}

{$IFDEF VECTOR_ENABLE_MOVE}
  Move(FData[I + 1], FData[I],  (FCount - 1 - I) * ItemSize);
{$ELSE}
  for J := I + 1 to FCount - 1 do
    FData[J - 1] := FData[J];
{$ENDIF}

  Dec(FCount);
end;

procedure TBaseVector.Remove(const Item: TItem);
var
  DelInd: Integer;
begin
  DelInd := IndexOf(Item);
  if DelInd <> NF_IND then
    Delete(DelInd);
end;

procedure TBaseVector.Swap(I1, I2: Integer);
var
  Tmp: TItem;
begin
  CheckIndex(I1);
  CheckIndex(I2);
  Tmp := FData[I1];
  FData[I1] := FData[I2];
  FData[I2] := Tmp;
end;

function TBaseVector.IndexOf(const Item: TItem): Integer;
var
  J: Integer;
begin
  Result := NF_IND;
  for J := 0 to FCount - 1 do
{$IFDEF CMP_FUNC}
    if ItemCmp(FData[J], Item) = 0 then
{$ELSE}
    if FData[J] = Item then
{$ENDIF}
    begin
      Result := J;
      Exit;
    end;
end;

procedure TBaseVector.QuickSort(L, R: Integer; Cmp: TVectorCmpFunc);
var
  T, M: TItem;
  I, J: Integer;
begin
  while L < R do
  begin
    M := FData[(L + R) div 2];
    I := L;
    J := R;
    repeat
      while Cmp(FData[I], M) < 0 do
        Inc(I);

      while Cmp(FData[J], M) > 0 do
        Dec(J);

      if I <= J then
      begin
        T := FData[I];
        FData[I] := FData[J];
        FData[J] := T;

        Inc(I);
        Dec(J);
      end;
    until I > J;

    if (J - L) < (R - I) then
    begin
      QuickSort(L, J, Cmp);
      L := I;
    end
    else
    begin
      QuickSort(I, R, Cmp);
      R := J;
    end;
  end;
end;

procedure TBaseVector.Sort(CmpFunc: TVectorCmpFunc);
begin
  if Assigned(CmpFunc) then
    QuickSort(0, Count - 1, CmpFunc);
end;

function TBaseVector.BinSearch(SearchObj: TVectorSearchObj): Integer;
var
  R, L, M, S: Integer;
begin
  Result := NF_IND;
  if (FCount = 0) then
    Exit;
    
  L := 0;
  M := 0;
  R := FCount;

  repeat
    S := SearchObj.Cmp(FData[M]);
    if S = 0 then
    begin
      // Find first item
      while (M > 0) and (SearchObj.Cmp(FData[M - 1]) = 0) do
        Dec(M);
      Result := M;
      Exit;
    end;

    if S < 0 then
      R := M  // SearchObj < FData[M]
    else
      L := M; // SearchObj > FData[M]
    M := (L + R) div 2;
  until L >= R - 1;
  
  Result := NF_IND;
end;

function TVector.GetAt(I: Integer): TItemRef;
begin
  CheckIndex(I);
{$IFDEF ITEM_REF_IS_PTR}
  Result := @FData[I];
{$ELSE}
  Result := FData[I];
{$ENDIF}
end;

procedure TVector.SetAt(I: Integer; const Item: TItemRef);
begin
  CheckIndex(I);

{$IFDEF ITEM_FREE_FUNC}
  ItemFree(FData[I], Self);
{$ENDIF}

{$IFDEF ITEM_REF_IS_PTR}
  FData[I] := Item^;
{$ELSE}
  FData[I] := Item;
{$ENDIF}
end;

function TVector.Peek: TItemRef;
begin
  if Count <= 0 then
    raise EVectorRangeError.CreateFmt(
      '%s: Invalid Peek call. Vector is empty.', [Self.ClassName]);

{$IFDEF ITEM_REF_IS_PTR}
  Result := @FData[Count - 1];
{$ELSE}
  Result := FData[Count - 1];
{$ENDIF}
end;

procedure TVector.Assign(Src: IVector);
var
  SrcData: TDataArrayType;
begin
  SrcData := Src.GetData;
  if FData <> SrcData then
  begin
    Clear;
    FCount := Src.Count;
    FData := Copy(SrcData, 0, FCount);
  end;
end;

procedure TVector.Assign(const Src: array of TItem);
{$IFNDEF VECTOR_ENABLE_MOVE}
var
  I: Integer;
{$ENDIF}
begin
  Clear;
  FCount := High(Src) + 1;
  SetLength(FData, FCount);
{$IFDEF VECTOR_ENABLE_MOVE}
  Move(Src[0], FData[0], FCount * ItemSize);
{$ELSE}
  for I := 0 to FCount - 1 do
    FData[I] := Src[I];
{$ENDIF}
end;

{$IFEND}

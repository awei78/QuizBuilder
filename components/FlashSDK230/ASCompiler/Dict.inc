{$IF not Defined(IMPL)}

{$IFDEF VALUE_REF_IS_PTR}
  TValueRef = ^ TValue;
{$ELSE}
  TValueRef = TValue;
{$ENDIF}

  PPair = ^TPair;
  TPair = record
    Key: TKey;
    Value: TValue;
  end;

  IIter = interface(IInterface)
    function HasNext: Boolean;
    function Next: PPair;
  end;

  IDict = interface(IInterface)
    function  GetItem(const Key: TKey): TValueRef;
    procedure SetItem(const Key: TKey; const Value: TValueRef);
    function  Find(const Key: TKey): PPair;
    function  Get(const Key: TKey): PPair;
    function  Exists(const Key: TKey): Boolean;
    procedure Remove(const Key: TKey);
    function  IsEmpty: Boolean;
    function  Count: Integer;
    procedure Clear;
    procedure Assign(Src: IIter);
    function  Iter: IIter;
    property Items[const Key: TKey]: TValueRef read GetItem write SetItem; default;
  end;

  TDict = class(TInterfacedObject, IDict)
  protected
    FCount: Integer;
    FStrictItemMode: Boolean;
  public
    function  GetItem(const Key: TKey): TValueRef;
    procedure SetItem(const Key: TKey; const Value: TValueRef);
    function  Find(const Key: TKey): PPair; virtual; abstract;
    function  Get(const Key: TKey): PPair; virtual; abstract;
    function  Exists(const Key: TKey): Boolean;
    procedure Remove(const Key: TKey); virtual; abstract;
    function  IsEmpty: Boolean;
    function  Count: Integer;
    procedure Clear; virtual; abstract;
    procedure Assign(Src: IIter);
    function  Iter: IIter; virtual; abstract;
    property Items[const Key: TKey]: TValueRef read GetItem write SetItem; default;
  end;

  PHashItem = ^THashItem;
  THashItem = record
    Pair: TPair;
    Next: PHashItem;
  end;

  THashData = array of PHashItem;

  IHash = interface(IDict)
    function  GetData: THashData;
    function  GetCapacity: Integer;
    procedure SetCapacity(NewCapacity: Integer);
{$IFDEF HASH_STATISTIC}
    function GetMaxPairCount: Integer;
{$ENDIF}
    property Capacity: Integer read GetCapacity write SetCapacity;
  end;

  THash = class(TDict, IHash)
  private
    FData: THashData;
{$IFDEF HASH_STATISTIC}
    FPairCount: array of Integer;
    FMaxPairCount: Integer;
{$ENDIF}
  public
    constructor Create(Sz: Integer; StrictItemMode: Boolean = False);
    destructor Destroy; override;
    function  GetData: THashData;
    function  Find(const Key: TKey): PPair; override;
    function  Get(const Key: TKey): PPair; override;
    procedure Remove(const Key: TKey); override;
    procedure Clear; override;
    function  Iter: IIter; override;
    function  GetCapacity: Integer;
    procedure SetCapacity(NewCapacity: Integer);
{$IFDEF HASH_STATISTIC}
    function GetMaxPairCount: Integer;
{$ENDIF}
    property Capacity: Integer read GetCapacity write SetCapacity;
  end;

  PTreeNode = ^TTreeNode;
  TTreeNode = record
    Pair: TPair;
    Parent, Left, Right: PTreeNode;
    Color: TRbNodeColor;
  end;

  IRbTree = interface(IDict)
    function GetData: PTreeNode;
  end;

  TRbTree = class(TDict, IRbTree)
  private
    FRoot: PTreeNode;
    procedure RotateRight(N: PTreeNode);
    procedure RotateLeft(N: PTreeNode);
    procedure FixAfterInsert(N: PTreeNode);
    procedure Swap(N1, N2: PTreeNode);
    procedure FixAfterRemove(N: PTreeNode; IsLeft: Boolean);
  public
    destructor Destroy; override;
    function GetData: PTreeNode;
    function Find(const Key: TKey): PPair; override;
    function Get(const Key: TKey): PPair; override;
    procedure Remove(const Key: TKey); override;
    procedure Clear; override;
    function  Iter: IIter; override;
  end;

{$ELSE}

type
  THashIter = class(TInterfacedObject, IIter)
  private
    FHash: THash;
    FInd, FSize: Integer;
    FCur: PHashItem;
  public
    constructor Create(AHash: THash);
    destructor Destroy; override;
    function HasNext: Boolean;
    function Next: PPair;
  end;

  TRbTreeIter = class(TInterfacedObject, IIter)
  private
    FTree: TRbTree;
    FCur: PTreeNode;
  public
    constructor Create(ATree: TRbTree);
    destructor Destroy; override;
    function HasNext: Boolean;
    function Next: PPair;
  end;

function TDict.GetItem(const Key: TKey): TValueRef;
var
  Pair: PPair;
begin
  if not FStrictItemMode then
    Pair := Get(Key)
  else
  begin
    Pair := Find(Key);
    if Pair = nil then
      raise EDictKeyNotFound.Create('TDict.GetItem: Key not found.');
  end;

{$IFDEF VALUE_REF_IS_PTR}
  Result := @Pair.Value;
{$ELSE}
  Result := Pair.Value;
{$ENDIF}
end;

procedure TDict.SetItem(const Key: TKey; const Value: TValueRef);
var
  Pair: PPair;
begin
  Pair := Get(Key);
{$IFDEF VALUE_REF_IS_PTR}
  Pair.Value := Value^;
{$ELSE}
  Pair.Value := Value
{$ENDIF}
end;

function TDict.Exists(const Key: TKey): Boolean;
begin
  Result := Find(Key) <> nil;
end;

function TDict.IsEmpty: Boolean;
begin
  Result := (FCount = 0);
end;

function TDict.Count: Integer;
begin
  Result := FCount;
end;

procedure TDict.Assign(Src: IIter);
var
  SrcPair, DstPair: PPair;
begin
  Clear;
  while Src.HasNext do
  begin
    SrcPair := Src.Next;
    DstPair := Get(SrcPair.Key);
    DstPair.Value := SrcPair.Value;
  end;
end;

constructor THash.Create(Sz: Integer; StrictItemMode: Boolean);
begin
  inherited Create;
  Assert(Sz > 0);
  SetLength(FData, Sz);
  FillChar(FData[0], Sz * SizeOf(FData[0]), 0);
  FStrictItemMode := StrictItemMode;
{$IFDEF HASH_STATISTIC}
  SetLength(FPairCount, Sz);
  FillChar(FPairCount[0], Sz * SizeOf(FPairCount[0]), 0);
{$ENDIF}
end;

destructor THash.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure THash.Clear;
var
  I: Integer;
  Item: PHashItem;
begin
  for I := 0 to Length(FData) - 1 do
    while FData[I] <> nil do
    begin
      Item := FData[I];
      FData[I] := Item.Next;
{$IFDEF PAIR_FREE_FUNC}
      PairFree(Item.Pair);
{$ENDIF}
      Dispose(Item);
    end;
  FCount := 0;
{$IFDEF HASH_STATISTIC}
  FillChar(FPairCount[0], Sz * SizeOf(FPairCount[0]), 0);
{$ENDIF}
end;

function THash.Find(const Key: TKey): PPair;
var
  Item: PHashItem;
begin
  Item := FData[HashCode(Key) mod Cardinal(Length(FData))];
{$IFDEF CMP_FUNC}
  while (Item <> nil) and not KeyEqual(Key, Item.Pair.Key) do
    Item := Item.Next;
{$ELSE}
  while (Item <> nil) and (Key <> Item.Pair.Key) do
    Item := Item.Next;
{$ENDIF}
  Result := PPair(Item);
end;

function THash.Get(const Key: TKey): PPair;
var
  I: Cardinal;
  Item: PHashItem;
begin
  Result := Find(Key);
  if Result = nil then
  begin
    I := HashCode(Key) mod Cardinal(Length(FData));
    New(Item);
    with Item^ do begin
      Pair.Key := Key;
      Pair.Value := DefaultValue;
      Next := FData[I];
    end;
    FData[I] := Item;
    Inc(FCount);
    Result := PPair(Item);
{$IFDEF HASH_STATISTIC}
    Inc(FPairCount[I]);
    if FPairCount[I] > FMaxPairCount then
      FMaxPairCount := FPairCount[I];
{$ENDIF}
  end;
end;

procedure THash.Remove(const Key: TKey);
var
  I: Cardinal;
  Prev, Cur: PHashItem;
begin
  I := HashCode(Key) mod Cardinal(Length(FData));
  Cur := FData[I];
  Prev := nil;

{$IFDEF CMP_FUNC}
  while (Cur <> nil) and not KeyEqual(Key, Cur.Pair.Key) do
{$ELSE}
  while (Cur <> nil) and (Key <> Cur.Pair.Key) do
{$ENDIF}
  begin
    Prev := Cur;
    Cur := Cur.Next;
  end;

  if Cur <> nil then
  begin
    if Prev = nil then
      FData[I] := Cur.Next
    else
      Prev.Next := Cur.Next;

{$IFDEF PAIR_FREE_FUNC}
    PairFree(Cur.Pair);
{$ENDIF}

    Dispose(Cur);
    Dec(FCount);

{$IFDEF HASH_STATISTIC}
    Dec(FPairCount[I]);
{$ENDIF}
  end;
end;

function THash.Iter: IIter;
begin
  Result := THashIter.Create(Self);
end;

function THash.GetData: THashData;
begin
  Result := FData;
end;

function THash.GetCapacity: Integer;
begin
  Result := Length(FData);
end;

procedure THash.SetCapacity(NewCapacity: Integer);
var
  NewList: THashData;
  I, J, OldCapacity: Integer;
  Item: PHashItem;
begin
  Assert(NewCapacity > 0);
  SetLength(NewList, NewCapacity);
  FillChar(NewList[0], NewCapacity * SizeOf(NewList[0]), 0);
  FCount := 0;
{$IFDEF HASH_STATISTIC}
  SetLength(FPairCount, NewCapacity);
  FillChar(FPairCount[0], NewCapacity * SizeOf(FPairCount[0]), 0);
{$ENDIF}

  I := 0;
  OldCapacity := Capacity;
  repeat
    while (I < OldCapacity) and (FData[I] = nil) do
      Inc(I);

    if I < OldCapacity then
      while FData[I] <> nil do
      begin
        Item := FData[I];
        FData[I] := FData[I].Next;
        J := HashCode(Item.Pair.Key) mod Cardinal(NewCapacity);
        Item.Next := NewList[J];
        NewList[J] := Item;
        Inc(FCount);
{$IFDEF HASH_STATISTIC}
        Inc(FPairCount[J]);
        if FPairCount[J] > FMaxPairCount then
          FMaxPairCount := FPairCount[J];
{$ENDIF}
      end;
  until I = OldCapacity;

  FData := NewList;
end;

{$IFDEF HASH_STATISTIC}
function THash.GetMaxPairCount: Integer;
begin
  Result := FMaxPairCount;
end;
{$ENDIF}

constructor THashIter.Create(AHash: THash);
begin
  inherited Create;
  FHash := AHash;
  FHash._AddRef;
  FSize := Length(FHash.FData);
  FCur := FHash.FData[FInd];
  while (FCur = nil) and (FInd < FSize) do
  begin
    Inc(FInd);
    if FInd < FSize then
      FCur := FHash.FData[FInd];
  end;
end;

destructor THashIter.Destroy;
begin
  FHash._Release;
  inherited Destroy;
end;

function THashIter.HasNext: Boolean;
begin
  Result := FCur <> nil;
end;

function THashIter.Next: PPair;
begin
  Result := PPair(FCur);
  if FCur <> nil then
  begin
    FCur := FCur.Next;
    while (FCur = nil) and (FInd < FSize) do
    begin
      Inc(FInd);
      if (FInd < FSize) then
        FCur := FHash.FData[FInd];
    end;
  end;
end;

function TRbTree.GetData: PTreeNode;
begin
  Result := FRoot;
end;

function TRbTree.Find(const Key: TKey): PPair;
var
  N: PTreeNode;
begin
  N := FRoot;
{$IFDEF CMP_FUNC}
  while (N <> nil) and not KeyEqual(Key, N.Pair.Key) do
  begin
    if KeyLess(Key, N.Pair.Key) then
      N := N.Left
    else
      N := N.Right;
  end;
{$ELSE}
  while (N <> nil) and (Key <> N.Pair.Key) do
  begin
    if Key < N.Pair.Key then
      N := N.Left
    else
      N := N.Right;
  end;
{$ENDIF}
  Result := PPair(N);
end;

function NodeColor(N: PTreeNode): TRbNodeColor;
begin
  Result := ncBlack;
  if N <> nil then
    Result := N.Color;
end;

function Sibling(N: PTreeNode): PTreeNode;
var
  P: PTreeNode;
begin
  P := N.Parent;
  Assert(P <> nil);
  if N = P.Left then
    Result := P.Right
  else
    Result := P.Left;
end;

procedure TRbTree.RotateRight(N: PTreeNode);
var
  P, L, LR: PTreeNode;
begin
  Assert((N <> nil) and (N.Left <> nil));

  P := N.Parent;
  L := N.Left;
  LR := L.Right;

  L.Parent := P;
  L.Right := N;

  N.Parent := L;
  N.Left := LR;

  if LR <> nil then
    LR.Parent := N;

  if P = nil then
    FRoot := L
  else
  begin
    if N = P.Left then
      P.Left := L
    else
      P.Right := L;
  end;
end;

procedure TRbTree.RotateLeft(N: PTreeNode);
var
  P, R, RL: PTreeNode;
begin
  Assert((N <> nil) and (N.Right <> nil));

  P := N.Parent;
  R := N.Right;
  RL := R.Left;

  R.Parent := N.Parent;
  R.Left := N;

  N.Parent := R;
  N.Right := RL;

  if RL <> nil then
    RL.Parent := N;

  if P = nil then
    FRoot := R
  else
  begin
    if N = P.Left then
      P.Left := R
    else
      P.Right := R;
  end;
end;

procedure TRbTree.FixAfterInsert(N: PTreeNode);
var
  P, S, PP: PTreeNode;
begin
  P := N.Parent;
  while (P <> nil) and (P.Color = ncRed) do
  begin
    PP := P.Parent;
    Assert(PP <> nil);
    S := Sibling(P);
    if NodeColor(S) = ncRed then
    begin
      P.Color := ncBlack;
      S.Color := ncBlack;
      PP.Color := ncRed;
      N := PP;
      P := N.Parent;
    end
    else
    begin
      PP.Color := ncRed;
      if P = PP.Left then
      begin
        if N = P.Left then
          P.Color := ncBlack
        else
        begin
          N.Color := ncBlack;
          RotateLeft(P);
        end;
        RotateRight(PP);
      end
      else
      begin
        if N = P.Right then
          P.Color := ncBlack
        else
        begin
          N.Color := ncBlack;
          RotateRight(P);
        end;
        RotateLeft(PP);
      end;
      Break;
    end;
  end;
end;

function TRbTree.Get(const Key: TKey): PPair;
var
  N: PTreeNode;

  function NewNode(P: PTreeNode; const K: TKey): PTreeNode;
  begin
    New(Result);
    with Result^ do
    begin
      Parent := P;
      Left := nil;
      Right := nil;
      Color := ncRed;
      Pair.Key := K;
      Pair.Value := DefaultValue;
    end;
  end;

begin
  if FRoot = nil then
  begin
    FRoot := NewNode(nil, Key);
    Result := PPair(FRoot);
    Inc(FCount);
  end
  else
  begin
    Result := nil;
    N := FRoot;
    repeat
{$IFNDEF CMP_FUNC}
      if Key = N.Pair.Key then
{$ELSE}
      if KeyEqual(Key, N.Pair.Key) then
{$ENDIF}
      begin
        Result := PPair(N);
      end
{$IFNDEF CMP_FUNC}
      else if Key < N.Pair.Key then
{$ELSE}
      else if KeyLess(Key, N.Pair.Key) then
{$ENDIF}
      begin
        if N.Left <> nil then
          N := N.Left
        else
        begin
          N.Left := NewNode(N, Key);
          Result := PPair(N.Left);
          FixAfterInsert(N.Left);
          Inc(FCount);
        end
      end
      else
      begin
        if N.Right <> nil then
          N := N.Right
        else
        begin
          N.Right := NewNode(N, Key);
          Result := PPair(N.Right);
          FixAfterInsert(N.Right);
          Inc(FCount);
        end;
      end;
    until Result <> nil;
  end;
  FRoot.Color := ncBlack;
end;

procedure TRbTree.Swap(N1, N2: PTreeNode);
var
  Tmp: TPair;
begin
  Tmp := N1.Pair;
  N1.Pair := N2.Pair;
  N2.Pair := Tmp;
end;

procedure TRbTree.FixAfterRemove(N: PTreeNode; IsLeft: Boolean);

  procedure LeftFix;
  var
    C: PTreeNode;
  begin
    if NodeColor(N.Left) = ncRed then
    begin
      N.Left.Color := ncBlack;
      N := nil;
    end
    else
    begin
      C := N.Right;
      Assert(C <> nil);
      if C.Color = ncRed then
      begin
        RotateLeft(N);
        C.Color := ncBlack;
        N.Color := ncRed;
      end
      else
      begin
        if (NodeColor(C.Left) = ncBlack) and
           (NodeColor(C.Right) = ncBlack) then
        begin
          C.Color := ncRed;
          if N.Parent <> nil then
            IsLeft := (N = N.Parent.Left);
          N := N.Parent;
        end
        else if NodeColor(C.Left) = ncBlack then
        begin
          RotateLeft(N);
          C.Right.Color := N.Color;
          N := nil;
        end
        else
        begin
          RotateRight(C);
          RotateLeft(N);
          N.Parent.Color := N.Color;
          N.Color := ncBlack;
          N := nil;
        end;
      end;
    end;
  end;

  procedure RightFix;
  var
    C: PTreeNode;
  begin
    if NodeColor(N.Right) = ncRed then
    begin
      N.Right.Color := ncBlack;
      N := nil;
    end
    else
    begin
      C := N.Left;
      Assert(C <> nil);
      if C.Color = ncRed then
      begin
        RotateRight(N);
        C.Color := ncBlack;
        N.Color := ncRed;
      end
      else
      begin
        if (NodeColor(C.Left) = ncBlack) and
           (NodeColor(C.Right) = ncBlack) then
        begin
          C.Color := ncRed;
          if N.Parent <> nil then
            IsLeft := (N = N.Parent.Left);
          N := N.Parent;
        end
        else if NodeColor(C.Right) = ncBlack then
        begin
          RotateRight(N);
          C.Left.Color := N.Color;
          N := nil;
        end
        else
        begin
          RotateLeft(C);
          RotateRight(N);
          N.Parent.Color := N.Color;
          N.Color := ncBlack;
          N := nil;
        end;
      end;
    end;
  end;

begin
  while N <> nil do
    if IsLeft then
      LeftFix
    else
      RightFix;
end;

procedure TRbTree.Remove(const Key: TKey);
var
  N, P, C, Tmp: PTreeNode;
  IsLeft: Boolean;
begin
  N := PTreeNode(Find(Key));
  if N = nil then
    Exit;

  if (N.Left <> nil) and (N.Right <> nil) then
  begin
    Tmp := N.Left;
    while Tmp.Right <> nil do
      Tmp := Tmp.Right;
    Swap(N, Tmp);
    N := Tmp;
  end;
  Tmp := N;
  Assert((N.Left = nil) or (N.Right = nil));

  P := N.Parent;
  if P = nil then
  begin
    if N.Left <> nil then
      FRoot := N.Left
    else if N.Right <> nil then
      FRoot := N.Right
    else
      FRoot := nil;
  end
  else
  begin
    if N.Left <> nil then
      C := N.Left
    else if N.Right <> nil then
      C := N.Right
    else
      C := nil;
    if C <> nil then
      C.Parent := P;
    if N = P.Left then
    begin
      P.Left := C;
      IsLeft := True;
    end
    else
    begin
      P.Right := C;
      IsLeft := False;
    end;
    if N.Color = ncBlack then
      FixAfterRemove(P, IsLeft);
  end;

{$IFDEF PAIR_FREE_FUNC}
  PairFree(Tmp.Pair);
{$ENDIF}
  Dispose(Tmp);
  Dec(FCount);

  if FRoot <> nil then
  begin
    FRoot.Color := ncBlack;
    FRoot.Parent := nil;
  end;
end;

procedure TRbTree.Clear;

  procedure DisposeNode(P: PTreeNode);
  begin
    if P <> nil then
    begin
      DisposeNode(P.Left);
      DisposeNode(P.Right);
{$IFDEF PAIR_FREE_FUNC}
      PairFree(P.Pair);
{$ENDIF}
      Dispose(P);
    end;
  end;

begin
  DisposeNode(FRoot);
  FRoot := nil;
  FCount := 0;
end;

destructor TRbTree.Destroy;
begin
  Clear;
  inherited;
end;

function TRbTree.Iter: IIter;
begin
  Result := TRbTreeIter.Create(Self); 
end;

constructor TRbTreeIter.Create(ATree: TRbTree);
begin
  inherited Create;
  FTree := ATree;
  FTree._AddRef;
  FCur := FTree.FRoot;
  if FCur <> nil then
    while FCur.Left <> nil do
      FCur := FCur.Left;
end;

destructor TRbTreeIter.Destroy;
begin
  FTree._Release;
  inherited Destroy;
end;

function TRbTreeIter.HasNext: Boolean;
begin
  Result := (FCur <> nil);
end;

function TRbTreeIter.Next: PPair;
begin
  Result := PPair(FCur);
  if FCur <> nil then
  begin
    if FCur.Right = nil then
    begin
      while (FCur.Parent <> nil) and (FCur = FCur.Parent.Right) do
        FCur := FCur.Parent;
      FCur := FCur.Parent;
    end
    else
    begin
      FCur := FCur.Right;
      while FCur.Left <> nil do
        FCur := FCur.Left;
    end;
  end;
end;

{$IFEND}

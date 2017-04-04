
{$undef ITEM_REF_IS_PTR}
{$undef ITEM_FREE_FUNC}
{$undef CMP_FUNC}
{$undef VECTOR_ENABLE_MOVE}

unit StrVec;

interface

uses
  Classes;

type
  TItem = String;

{$include Vector.inc}

  IStrVector = interface(IVector)
    procedure Assign(Src: TStrings); overload;
    function Clone: IStrVector;
    procedure ToStrings(Dst: TStrings);
  end;

  TStrVector = class(TVector, IStrVector)
    procedure Assign(Src: TStrings); overload;
    function Clone: IStrVector;
    procedure ToStrings(Dst: TStrings);
  end;

function Join(Vec: IStrVector; const Separator: String): String;
function Split(const Str: String; const Delim: String): IStrVector;
procedure Cat(Vec: IStrVector; const Str: String); overload;
procedure Cat(const Str: String; Vec: IStrVector); overload;
procedure Cat(V1, V2: IStrVector); overload;
procedure Fmt(Vec: IStrVector; const FmtStr: String);
function StrToken2(var Str: string; const Separators: string): string;

implementation

{$define IMPL}

uses
  SysUtils, GUtils;

{$include Vector.inc}

procedure TStrVector.Assign(Src: TStrings);
var
  i: Integer;
begin
  Clear;
  Capacity := Src.Count;
  for i := 0 to Src.Count - 1 do
    Add(Src[i]);
end;

procedure TStrVector.ToStrings(Dst: TStrings);
var
  i: Integer;
begin
  Dst.Clear;
  for i := 0 to Count - 1 do
    Dst.Add(Items[i]);
end;

function TStrVector.Clone: IStrVector;
var
  V: TStrVector;
begin
  V := TStrVector.Create;
  V.Assign(Self);
  Result := V;  
end;

function Join(Vec: IStrVector; const Separator: String): String;
var
  i: Integer;
begin
  if Vec.Count = 0 then
    Result := ''
  else begin
    Result := Vec[0];
    for i := 1 to Vec.Count - 1 do
      Result := Result + Separator + Vec[i];
  end;
end;

function Split(const Str: String; const Delim: String): IStrVector;
var
  DelimTable: packed array [Char] of Boolean;
  i, s, f, l: Integer;
begin
  Result := TStrVector.Create;
  if Str = '' then
    Exit;
  FillChar(DelimTable, SizeOf(DelimTable), 0);
  for i := 1 to Length(Delim) do
    DelimTable[Delim[i]] := True;
  s := 1;
  l := Length(Str);
  while True do begin
    while DelimTable[Str[s]] and (s <= l) do
      Inc(s);
    if s > l then
      Break;
    f := s + 1;
    while not DelimTable[Str[f]] and (f <= l) do
      Inc(f);
    Result.Add(Copy(Str, s, f - s));
    if f > l then
      Break;
    s := f + 1;
  end;
end;

procedure Cat(Vec: IStrVector; const Str: String);
var
  i: Integer;
begin
  for i := 0 to Vec.Count - 1 do
    Vec[i] := Vec[i] + Str;
end;

procedure Cat(const Str: String; Vec: IStrVector);
var
  i: Integer;
begin
  for i := 0 to Vec.Count - 1 do
    Vec[i] := Str + Vec[i];
end;

procedure Cat(V1, V2: IStrVector);
var
  i: Integer;
begin
  Assert(V1.Count = V2.Count);
  for i := 0 to V1.Count - 1 do
    V1[i] := V1[i] + V2[i];
end;

procedure Fmt(Vec: IStrVector; const FmtStr: String);
var
  i: Integer;
begin
  for i := 0 to Vec.Count - 1 do
    Vec[i] := Format(FmtStr, [Vec[i]]);
end;

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

end.





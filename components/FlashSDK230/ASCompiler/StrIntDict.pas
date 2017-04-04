
{$undef  PAIR_FREE_FUNC}
{$define CMP_FUNC}
{$undef  VALUE_REF_IS_PTR}

unit StrIntDict;

interface

uses
  GUtils;

type
  TKey = String;
  TValue = Integer;

{$include Dict.inc}

  PStrIntPair = PPair;
  IStrIntIter = IIter;
  IStrIntDict = IDict;
  IStrIntHash = IHash;
  TStrIntHash = THash;
  TStrIntTree = TRbTree;

implementation

{$define IMPL}

uses
  SysUtils;

var
  DefaultValue: TValue = 0;

function HashCode(S: TKey): Cardinal;
var
  I: Integer;
begin
  S := UpperCase(S);
  Result := 0;
  for I := 1 to Length(S) do
    Inc( Result, Ord( S[I] ) * ( 1 shl (I mod 4 * 8) ) );
end;

function KeyEqual(S1, S2: TKey): Boolean;
begin
  Result := UpperCase(S1) = UpperCase(S2);
end;

function KeyLess(S1, S2: TKey): Boolean;
begin
  Result := UpperCase(S1) < UpperCase(S2);
end;

{$include Dict.inc}

end.





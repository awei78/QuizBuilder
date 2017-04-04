 
{$undef PAIR_FREE_FUNC}
{$undef CMP_FUNC}
{$undef VALUE_REF_IS_PTR}

unit IntPtrDict;

interface

uses
  GUtils;

type
  TKey = Integer;
  TValue = Pointer;

{$include Dict.inc}

  PIntPtrPair = PPair;
  IIntPtrIter = IIter;
  IIntPtrDict = IDict;
  IIntPtrHash = IHash;
  TIntPtrHash = THash;
  TIntPtrTree = TRbTree;

implementation

{$define IMPL}

uses
  SysUtils;

var
  DefaultValue: TValue = nil;

function HashCode(V: TKey): Cardinal;
begin
  Result := V;
end;

{$include Dict.inc}

end.


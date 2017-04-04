unit StrTbl;

interface

uses
  SysUtils, StrVec, StrIntDictCS;

type
  TStrId = type Integer;
  TStrIdArray = array of TStrId;

  TStringTable = class(TObject)
  private
    FItems: IStrVector;
    FIndex: IStrIntDict;
    function GetItem(Id: TStrId): string;
    function GetCount: Integer;
    procedure AddDefaults;
  public
    constructor Create;
    function AddItem(S: string): TStrId;
    procedure Clear;
    function EmptyStrId: TStrId;
    function PrototypeStrId: TStrId;
    function ThisStrId: TStrId;
    function SuperStrId: TStrId;
    function ArgumentsStrId: TStrId;
    function GlobalStrId: TStrId;
    function ObjectStrId: TStrId;
    property Items[Id: TStrId]: string read GetItem; default;
    property Count: Integer read GetCount;
  end;

const
  UndefinedStrId = -1;
  NullStrId = -2;
  FalseStrId = -3;
  TrueStrId = -4;

implementation

{ TStringTable }

constructor TStringTable.Create;
begin
  inherited Create;
  FItems := TStrVector.Create;
  FIndex := TStrIntHash.Create(113);
  AddDefaults;
end;

procedure TStringTable.AddDefaults;
begin
  AddItem('');
  AddItem('this');
  AddItem('prototype');
  AddItem('super');
  AddItem('arguments');
  AddItem('_global');
  AddItem('Object');
end;

function TStringTable.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TStringTable.GetItem(Id: TStrId): string;
begin
  Result := FItems[Id];
end;

function TStringTable.AddItem(S: string): TStrId;
var
  Pair: StrIntDictCS.PPair;
begin
  Pair := FIndex.Find(S);
  if Pair <> nil then
    Result := Pair^.Value
  else
  begin
    Result := FItems.Count;
    FIndex[S] := Result;
    FItems.Add(S);
  end;
end;

procedure TStringTable.Clear;
begin
  FItems.Clear;
  FIndex.Clear;
  AddDefaults;
end;

function TStringTable.EmptyStrId: TStrId;
begin
  Result := AddItem('');
end;

function TStringTable.PrototypeStrId: TStrId;
begin
  Result := AddItem('prototype');
end;

function TStringTable.ThisStrId: TStrId;
begin
  Result := AddItem('this');
end;

function TStringTable.SuperStrId: TStrId;
begin
  Result := AddItem('super');
end;

function TStringTable.ArgumentsStrId: TStrId;
begin
  Result := AddItem('arguments');
end;

function TStringTable.GlobalStrId: TStrId;
begin
  Result := AddItem('_global');
end;

function TStringTable.ObjectStrId: TStrId;
begin
  Result := AddItem('Object');
end;

end.

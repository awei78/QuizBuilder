unit IncSrc;

interface

uses
  SysUtils, Classes, ObjVec;

type
  TSrcLineLengths = array [0 .. 99] of Word;

  TSourceState = class(TObject)
  private
    FLexInput: TStream;
    FLexLineno, FLexColno: Integer;
    FFileName: string;
    FSrcLineLengths: TSrcLineLengths;
  public
    constructor Create(ALexInput: TStream; ALexLineno, ALexColno: Integer;
      const ASrcLineLengths: TSrcLineLengths; AFileName: string);
    property LexInput: TStream read FLexInput;
    property LexLineno: Integer read FLexLineno;
    property LexColno: Integer read FLexColno;
    property FileName: string read FFileName;
    property SrcLineLengths: TSrcLineLengths read FSrcLineLengths;
  end;

  TItemRef = TSourceState;

{$INCLUDE ObjVec.inc}

  IIncludeSourceStack = IVector;
  TIncludeSourceStack = TVector;

procedure ClearSrcLineLengths(var A: TSrcLineLengths);

implementation

uses
  GUtils;

{$DEFINE IMPL}

{$INCLUDE ObjVec.inc}

{ TIncludeSource }

constructor TSourceState.Create(
  ALexInput: TStream;
  ALexLineno, ALexColno: Integer;
  const ASrcLineLengths: TSrcLineLengths;
  AFileName: string);
begin
  inherited Create;
  FLexInput := ALexInput;
  FLexLineno := ALexLineno;
  FLexColno := ALexColno;
  FSrcLineLengths := ASrcLineLengths;
  FFileName := AFileName;
end;

procedure ClearSrcLineLengths(var A: TSrcLineLengths);
var
  I: Integer;
begin
  for I := Low(TSrcLineLengths) to High(TSrcLineLengths) do
    A[I] := 0;
end;

end.

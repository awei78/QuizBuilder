//*******************************************************//
//                                                       //
//                      DelphiFlash.com                  //
//         Copyright (c) 2004-2008 FeatherySoft, Inc.    //
//                    info@delphiflash.com               //
//                                                       //
//*******************************************************//

//  Description: tool functions for reading and makeing SWF file
//  Last update:  15 mar 2008

{$I defines.inc}

unit SWFTools;
interface
 Uses Windows, SysUtils, Classes, SWFConst, Contnrs,
{$IFDEF ExternalUTF}
    Unicode,
{$ENDIF}
  graphics;

type
// =================== TBitsEngine ====================
 TBitsEngine = class
   BitsStream: TStream;
   LastByte, LastBitCount: byte;

   Constructor Create(bs: TStream);

   Procedure FlushLastByte(write: boolean = true);
   Procedure WriteBits(Data: longword; Size: byte); overload;
   Procedure WriteBits(Data: longint; Size: byte); overload;
   Procedure WriteBits(Data: word; Size: byte); overload;
   Procedure WriteBits(Data: byte; Size: byte); overload;
   Procedure WriteBit(b: boolean);
   procedure WriteByte(b: byte);
   procedure Write2Byte(w: word);
   Procedure Write4byte(dw: longword);
   Procedure WriteRect(r: recRect); overload;
   Procedure WriteRect(r: TRect); overload;
   Procedure WriteColor(c: recRGB); overload;
   Procedure WriteColor(c: recRGBA); overload;
   procedure WriteSingle(s: single);
   procedure WriteFloat(s: single);
   Procedure WriteWord(w: word);
   Procedure WriteSwapWord(w:word);
   Procedure WriteDWord(dw: dword);
   Procedure WriteString(s: ansiString; NullEnd: boolean = true; U: boolean = false);
   Procedure WriteUTF8String(s: PChar; L: Integer; NullEnd: boolean = true);
   Procedure WriteMatrix(m: recMatrix);
   Procedure WriteColorTransform(ct: recColorTransform);
   procedure WriteEncodedU32(Data: DWord);
   procedure WriteStdDouble(d: double);
   procedure WriteEncodedString(s: ansistring);

   function GetBits(n:integer):dword;
   function GetSBits(n: integer): LongInt;
   function ReadByte: byte;
   function ReadBytes(n: byte): DWord;
   function ReadWord: word;
   function ReadSwapWord: word;
   function ReadDWord: DWord;
   function ReadDouble: double;
   function ReadStdDouble: double;
   function ReadRect:TRect;
   function ReadRGB:recRGB;
   function ReadRGBA:recRGBA;
   function ReadSingle: single;
   function ReadFloat: single;
   function ReadMatrix: recMATRIX;
   function ReadColorTransform(UseA: boolean = true): recColorTransform;
   function ReadFloat16: single;
   function ReadString(len: byte): string; overload;
   function ReadString: ansiString; overload;
   function ReadLongString(Encoded32Method: boolean = false): ansiString;
   function ReadEncodedU32: DWord;
 end;

 function GetBitsCount(Value: LongWord): byte; overload;
 function GetBitsCount(Value: LongInt; add: byte): byte; overload;
 function MaxValue(A, B, C, D: longint): longword; overload;
 function MaxValue(A, B: longint): longword; overload;
 Function CheckBit(w: word; n: byte): boolean;

 Function WordToSingle(w: word): single;
 Function SingleToWord(s: single): word;

 function SWFRGB(r, g, b: byte):recRGB; overload;
 function SWFRGB(c: tColor):recRGB; overload;
 function SWFRGBA(r, g, b, a: byte):recRGBA; overload;
 function SWFRGBA(c: tColor; A:byte = 255):recRGBA; overload;
 function SWFRGBA(c: recRGB; A:byte = 255):recRGBA; overload;
 function SWFRGBA(c: recRGBA; A:byte = 255):recRGBA; overload;
 Function WithoutA(c: recRGBA): recRGB;
 Function AddAlphaValue(c: recRGBA; A: Smallint): recRGBA;

 Function SWFRectToRect(r: recRect; Convert: boolean = true): TRect;
 Function RectToSWFRect(r: tRect; Convert: boolean = true): recRect;

 Function IntToSingle(w: LongInt): single;
 Function SingleToInt(s: single): LongInt;

 Function MakeMatrix(hasScale, hasSkew: boolean;
                     ScaleX, ScaleY, SkewX, SkewY, TranslateX, TranslateY: longint): recMatrix;
 Procedure MatrixSetTranslate(var M: recMatrix; X, Y: longint);
 Procedure MatrixSetScale(var M: recMatrix; ScaleX, ScaleY: single);
 Procedure MatrixSetSkew(var M: recMatrix; SkewX, SkewY: single);
 Function SwapColorChannels(Color: longint): longint;

 Function MakeColorTransform(hasADD: boolean; addR, addG, addB, addA: Smallint;
                             hasMULT: boolean; multR, multG, multB, multA: Smallint;
                             hasAlpha: boolean): recColorTransform;

 function GetCubicPoint(P0, P1, P2, P3: longint; t: single): double;
//================== Region Data converter ========================

function NormalizeRect(R: TRect):TRect;

{$IFDEF VER130}  // Delphi 5
function Sign(const AValue: Double): shortint;
{$ENDIF}

implementation
{$IFNDEF VER130}
uses Types;
{$ENDIF}

function NormalizeRect(R: TRect):TRect;
begin
  if r.Left > r.Right then
  begin result.Left:=r.Right; result.Right:=r.Left; end
  else begin result.Left:=r.Left; result.Right:=r.Right; end;

  if r.Top > r.Bottom then
  begin result.Top:=r.Bottom; result.Bottom:=r.Top; end
  else begin result.Top:=r.Top; result.Bottom:=r.Bottom; end;
end;

function GetBitsCount(Value: LongWord): byte;
var
  n: longword;
  il: byte;
begin
  Result := 0;
  if longint(Value) < 0 then result := 32 else
  if (Value > 0) then
    begin
     n := 1;
     for il := 1 to 32 do begin
       n := n shl 1;
       if (n > Value) then
         begin
           Result := il;
           Break;
         end;
     end;
    end;
end;

function GetBitsCount(Value: LongInt; add: byte): byte;
var
  n: longword;
begin
  if Value=0 then result:=0 {+ add} else
   begin
    n := Abs(Value);
    Result := GetBitsCount(n) + add;
   end;
end;


function MaxValue(A, B, C, D: longint): longword;
var
  _a, _b, _c, _d: longint;
begin
  _a := abs(A);
  _b := abs(B);
  _c := abs(C);
  _d := abs(D);

  if (_a > _b) then
    if (_a>_c) then
      if (_a>_d)
      then Result := _a
      else  Result := _d
    else
      if (_c>_d)
      then Result := _c
      else Result := _d
  else
    if (_b>_c) then
      if (_b>_d)
      then Result := _b
      else Result := _d
    else
      if (_c>_d)
      then Result := _c
      else Result := _d;
end;

function MaxValue(A, B: longint): longword;
var
  _a, _b: longint;
begin
  _a := abs(A);
  _b := abs(B);
  if (_a > _b) then Result := _a else Result := _b;
end;

Function CheckBit(w: word; n: byte): boolean;
begin
 Result := ((W shr (n-1)) and 1) = 1;
end;

// =================== TBitsEngine ====================
Constructor TBitsEngine.Create(bs: tStream);
begin
  inherited Create;
  BitsStream := bs;
  LastByte := 0;
  LastBitCount := 0;
end;

// --- function for write datas for stream

Procedure TBitsEngine.FlushLastByte(write: boolean);
begin
 if LastBitCount>0 then
  begin
   if write then WriteBits(LongWord(0), 8 - LastBitCount);
   LastByte := 0;
   LastBitCount := 0;
  end;
end;

procedure TBitsEngine.WriteBits(Data: longword; Size: byte);
 type
     T4B = array[0..3] of byte;

 var
     tmpDW: longword;
     tmp4b: T4B absolute tmpDW;

     cwbyte, totalBits, il: byte;
     endBits: byte;
begin
 if Size = 0 then Exit;

 // clear bits at the left if negative
 tmpDW := Data shl (32-size) shr (32-size);

 totalBits := LastBitCount + Size;
 cwbyte := (totalBits) div 8;
 if cwbyte = 0 then  // if empty byte
  begin
    LastByte := (LastByte shl Size) or tmpDW;
    LastBitCount := totalBits;
  end else
  begin
    endBits := totalBits mod 8;
    if endBits = 0 then // is full
     begin
       tmpDW := tmpDW + (LastByte shl Size);
       LastByte := 0;
       LastBitCount := 0;
     end else // rest
     begin
       tmpDW := LastByte shl (Size - endBits) + (tmpDW shr endBits);
       LastBitCount := endBits;
       LastByte := byte(Data shl (8-endBits)) shr (8-endBits);
     end;

    for il := cwbyte downto 1 do
      BitsStream.Write(tmp4b[il-1], 1);
  end;
end;

Procedure TBitsEngine.WriteBits(Data: longint; Size: byte);
begin
  WriteBits(LongWord(Data), Size);
end;

Procedure TBitsEngine.WriteBits(Data: word; Size: byte);
begin
  WriteBits(LongWord(Data), Size);
end;

Procedure TBitsEngine.WriteBits(Data: byte; Size: byte);
begin
  WriteBits(LongWord(Data), Size);
end;

Procedure TBitsEngine.WriteBit(b: boolean);
begin
 WriteBits(longword(b), 1);
end;

procedure TBitsEngine.WriteByte(b: byte);
begin
 if LastBitCount = 0 then BitsStream.Write(b, 1)
   else WriteBits(b, 8);
end;

procedure TBitsEngine.Write2Byte(w: word);
begin
  WriteBits(w, 16);
end;

procedure TBitsEngine.WriteSingle(s: single);
 var LW: LongInt;
begin
  LW := SingleToInt(s);
  WriteDWord(LW);
end;

procedure TBitsEngine.WriteFloat(s: single);
 var LW: LongWord;
begin
  Move(S, LW, 4);
  WriteDWord(LW);
end;

Procedure TBitsEngine.WriteWord(w:word);
begin
 FlushLastByte;
 BitsStream.Write(w, 2);
end;

Procedure TBitsEngine.WriteSwapWord(w:word);
begin
 FlushLastByte;
 WriteByte(HiByte(W));
 WriteByte(LoByte(W));
end;

Procedure TBitsEngine.WriteDWord(dw: dword);
begin
 FlushLastByte;
 BitsStream.Write(dw, 4);
end;

procedure TBitsEngine.WriteEncodedString(s: ansistring);
  var SLen, il: word;
begin
  SLen := length(s);
  WriteEncodedU32(SLen);
  if SLen > 0 then
    for il := 1 to SLen do Writebyte(byte(S[il]));
end;

procedure TBitsEngine.WriteEncodedU32(Data: DWord);
  var AByte: array [0..3] of byte absolute Data;
      il, Max: byte;
begin
  if Data = 0 then WriteByte(0)
  else
  begin
    Max := 3;
    while (Max > 0) and (Abyte[Max] = 0) do dec(Max);
    for il := 0 to Max do
    begin
      WriteBit((il < Max) or ((GetBitsCount(AByte[il]) + il) > 7));
      WriteBits(AByte[il], 8 - il - 1);
      if il > 0 then WriteBits(byte(AByte[il - 1] shr (8 - il)), il);
    end;
    if ((GetBitsCount(Data) + Max) > ((Max + 1) * 7)) and
       ((AByte[Max] shr (8 - Max - 1)) > 0) then
         WriteByte(byte(AByte[Max] shr (8 - Max - 1)));
  end;
end;

Procedure TBitsEngine.Write4byte(dw: longword);
begin
 FlushLastByte;
 BitsStream.Write(dw, 4);
end;

Procedure TBitsEngine.WriteColor(c: recRGB);
begin
 with BitsStream do
  begin
   Write(c.r, 1);
   Write(c.g, 1);
   Write(c.b, 1);
  end;
end;

Procedure TBitsEngine.WriteColor(c: recRGBA);
begin
 with BitsStream do
  begin
   Write(c.r, 1);
   Write(c.g, 1);
   Write(c.b, 1);
   Write(c.a, 1);
  end;
end;

Procedure TBitsEngine.WriteRect(r: recRect);
 var nBits: byte;
begin
  nBits := GetBitsCount(MaxValue(r.Xmin, r.Xmax, r.Ymin, r.Ymax), 1);
  WriteBits(nBits, 5);
  WriteBits(r.Xmin, nBits);
  WriteBits(r.Xmax, nBits);
  WriteBits(r.Ymin, nBits);
  WriteBits(r.Ymax, nBits);
  FlushLastByte;
end;

Procedure TBitsEngine.WriteRect(r: tRect);
begin
  WriteRect(RectToSWFRect(r, false));
end;

procedure TBitsEngine.WriteStdDouble(d: double);
begin
  BitsStream.Write(d, 8);
end;

Procedure TBitsEngine.WriteString(s: ansiString; NullEnd: boolean = true; U: boolean = false);
 var il, len: integer;
     tmpS: ansiString;
begin
 if U then
   begin
     tmpS := AnsiToUTF8(s);
     len := Length(tmpS);
     if len>0 then
       For il := 1 to len do WriteByte(Ord(tmpS[il]));
   end else
   begin
     len := Length(s);
     if len>0 then
       For il := 1 to len do Writebyte(byte(s[il]));
   end;
  if NullEnd then WriteByte(0);
end;

Procedure TBitsEngine.WriteUTF8String(s: PChar; L: Integer; NullEnd: boolean = true);
var
  il: Integer;
begin
  if L>0 then
     For il := 0 to L-1 do Writebyte(byte(S[il]));
  if NullEnd then Writebyte(0);
end;

Procedure TBitsEngine.WriteMatrix(m: recMatrix);
 var nBits: byte;
begin
  WriteBit(m.hasScale);
  if m.hasScale then
    begin
     nBits := GetBitsCount(MaxValue(m.ScaleX, m.ScaleY), 1);
     WriteBits(nBits, 5);
     WriteBits(m.ScaleX, nBits);
     WriteBits(m.ScaleY, nBits);
    end;

  WriteBit(m.hasSkew);
  if m.hasSkew then
    begin
     nBits := GetBitsCount(MaxValue(m.SkewX, m.SkewY), 1);
     WriteBits(nBits, 5);
     WriteBits(m.SkewY, nBits);
     WriteBits(m.SkewX, nBits);
    end;

  nBits := GetBitsCount(MaxValue(m.TranslateX, m.TranslateY), 1);
  WriteBits(nBits, 5);
  if nBits>0 then
   begin
    WriteBits(m.TranslateX, nBits);
    WriteBits(m.TranslateY, nBits);
   end;
  FlushLastByte;
end;

Procedure TBitsEngine.WriteColorTransform(ct: recColorTransform);
 var n1, n2: byte;
begin
 With ct do
  begin
   if hasADD then n1 := GetBitsCount(MaxValue(addR, addG, addB, addA * byte(hasAlpha)),1) else n1 := 0;
   if hasMULT then n2 := GetBitsCount(MaxValue(multR, multG, multB, multA * byte(hasAlpha)),1) else n2 := 0;
   if n1 < n2 then n1 := n2;
   WriteBit(hasADD);
   WriteBit(hasMULT);
   if hasADD or hasMult then
     begin
       WriteBits(n1, 4);

       if hasMult then
        begin
         WriteBits(multR, n1);
         WriteBits(multG, n1);
         WriteBits(multB, n1);
         if hasAlpha then WriteBits(multA, n1);
        end;

       if hasAdd then
        begin
         WriteBits(addR, n1);
         WriteBits(addG, n1);
         WriteBits(addB, n1);
         if hasAlpha then WriteBits(addA, n1);
        end;
      end;
  end;
 FlushLastByte;
end;

function TBitsEngine.ReadString(len: byte): string;
 var ACH: array [0..255] of char;
begin
 BitsStream.Read(ACH, len);
 ACH[len] := #0;
 Result := string(ACH);
end;

function TBitsEngine.ReadString: ansiString;
 var ch: char;
begin
 Result := '';
 Repeat
   ch := Char(ReadByte);
   if ch<>#0 then Result := Result + ch;
 until ch = #0;
end;

function TBitsEngine.ReadLongString(Encoded32Method: boolean = false): ansiString;
 var C, il: word;
begin
  if Encoded32Method
    then C := ReadEncodedU32
    else C := ReadSwapWord;
  Result := '';
  if C > 0 then
   begin
     if C > 255
      then
       for il := 1 to C do
        Result := Result + Char(ReadByte)
      else
        Result := ReadString(C);
   end;
end;

function TBitsEngine.ReadByte: byte;
begin
  BitsStream.Read(Result, 1);
end;

function TBitsEngine.ReadWord: word;
begin
  BitsStream.Read(Result, 2);
end;

function TBitsEngine.ReadSwapWord: word;
begin
  BitsStream.Read(Result, 2);
  Result := (Result and $FF) shl 8 + Result shr 8;
end;

function TBitsEngine.ReadBytes(n: byte): DWord;
begin
  Result := 0;
  if n > 4 then n := 4; 
  BitsStream.Read(Result, n);
end;

function TBitsEngine.ReadDouble: double;
 var d: Double;
     AB: array [0..7] of byte absolute d;
     il: byte;
begin
  d := 0;
  for il := 7 downto 4 do ab[il] := ReadByte;
  for il := 0 to 3 do ab[il] := ReadByte;
  Result := d;
end;

function TBitsEngine.ReadStdDouble: double;
begin
  BitsStream.Read(Result, 8);
end;

function TBitsEngine.ReadDWord: dword;
begin
  BitsStream.Read(Result, 4);
end;

function TBitsEngine.ReadEncodedU32: DWord;
 var b, il: byte;
begin
  il := 0;
  Result := 0;
  while il < 5 do
  begin
    b := ReadByte;
    Result := Result + (b and $7f) shl (il * 7);
    if CheckBit(b, 8) then inc(il) else il := 5;
  end;
end;

function TBitsEngine.ReadSingle: single;
 var LW: longInt;
begin
  BitsStream.Read(LW, 4);
  result := IntToSingle(LW);
end;

function TBitsEngine.ReadFloat: single;
 var LW: longWord;
begin
  BitsStream.Read(LW, 4);
  Move(LW, Result, 4);
end;

function TBitsEngine.GetBits(n:integer):dword;
 var s:integer;
begin
  Result:=0;
  if n > 0 then
    begin
    {
      if LastBitCount = 0 then
       begin
         LastByte := ReadByte; // Get the next buffer
         LastBitCount := 8;
       end;  }

      Repeat
        s:= n - LastBitCount;
        if (s>0) then
          begin       // Consume the entire buffer
            Result:=Result or (lastByte shl s);
            n:=n - LastBitCount;
            LastByte := ReadByte; // Get the next buffer
            LastBitCount := 8;
          end;
      Until S<=0;

      Result := Result or (lastByte shr -s);
      LastBitCount := LastBitCount - n;
      lastByte := lastByte and ($ff shr (8 - LastBitCount)); // mask off the consumed bits
    end;
end;

function TBitsEngine.ReadRect:tRect;
 var nBits:byte;
begin
  nBits := GetBits(5);
  Result.Left   := GetSBits(nBits);
  Result.Right  := GetSBits(nBits);
  Result.Top    := GetSBits(nBits);
  Result.Bottom := GetSBits(nBits);
  FlushLastByte(false);
end;

function TBitsEngine.GetSBits(n: integer): LongInt; // Get n bits from the string with sign extension
begin
  Result:= GetBits(n);
  // Is the number negative
  if (Result and (1 shl (n - 1) ) )<>0 then // Yes. Extend the sign.
     Result:=Result or (-1 shl n);
end;

Function TBitsEngine.ReadRGB:recRGB;
begin
 With BitsStream do
  begin
   Read(Result.R, 1);
   Read(Result.G, 1);
   Read(Result.B, 1);
  end;
end;

Function TBitsEngine.ReadRGBA:recRGBA;
begin
 With BitsStream do
  begin
   Read(Result.R, 1);
   Read(Result.G, 1);
   Read(Result.B, 1);
   Read(Result.A, 1);
  end;
end;

function TBitsEngine.ReadMatrix: recMATRIX;
 var nbits:byte;
begin
 FillChar(Result, SizeOf(Result), 0);
 Result.hasScale:=GetBits(1) = 1;
 if Result.hasScale then
   begin
     nbits := GetBits(5);
     Result.ScaleX := GetSBits(nBits);
     Result.ScaleY := GetSBits(nBits);
   end;

 Result.hasSkew:=GetBits(1) = 1;
 if Result.hasSkew then
   begin
     nbits := GetBits(5);
     Result.SkewY := GetSBits(nBits);
     Result.SkewX := GetSBits(nBits);
   end;

  nbits := GetBits(5);
  Result.TranslateX := GetSBits(nBits);
  Result.TranslateY := GetSBits(nBits);
  FlushLastByte(false);
end;

function TBitsEngine.ReadColorTransform(UseA: boolean = true): recColorTransform;
 var nbits:byte;
begin
 Result.hasADD := GetBits(1) = 1;
 Result.hasMult := GetBits(1) = 1;
 Result.hasAlpha := UseA;
 if Result.hasADD or Result.hasMult then
  begin
   nbits := GetBits(4);
   if Result.hasMULT then
    begin
      Result.multR := GetSBits(nBits);
      Result.multG := GetSBits(nBits);
      Result.multB := GetSBits(nBits);
      if UseA then Result.multA := GetSBits(nBits);
    end;
   if Result.hasADD then
    begin
      Result.addR := GetSBits(nBits);
      Result.addG := GetSBits(nBits);
      Result.addB := GetSBits(nBits);
      if UseA then Result.addA := GetSBits(nBits);
    end;
  end;
  FlushLastByte(false);
end;

function TBitsEngine.ReadFloat16: single;
 var W: Word;
     L: LongWord;
begin
  BitsStream.Read(W, 2);
  if W = 0 then Result := 0 else
    begin
     L := (W and $FC00) shl 16 + (W and $3FF) shl 7;
     Move(L, Result, 4);
    end;
end;

// =======================================================

Function WordToSingle(w: word): single;
begin
 Result := W shr 8 + (W and $FF) / ($FF+1);
end;

Function SingleToWord(s: single): word;
begin
 Result := trunc(s) shl 8 + Round(Frac(s) * ($FF+1));
end;

function SWFRGB(r, g, b: byte):recRGB;
begin
 Result.R := r;
 Result.G := g;
 Result.B := b;
end;

function SWFRGB(c: tColor):recRGB;
begin
  C := ColorToRGB(C);
  Result := SWFRGB (GetRValue(ColorToRGB(c)), GetGValue(ColorToRGB(c)), GetBValue(ColorToRGB(c)));
end;

function SWFRGBA(r, g, b, a: byte):recRGBA;
begin
 Result.R := r;
 Result.G := g;
 Result.B := b;
 Result.A := a;
end;

function SWFRGBA(c: TColor; A:byte = 255):recRGBA;
begin
 Result.R := GetRValue(ColorToRGB(c));
 Result.G := GetGValue(ColorToRGB(c));
 Result.B := GetBValue(ColorToRGB(c));
 Result.A := A;
end;

function SWFRGBA(c: recRGB; A:byte):recRGBA;
begin
 Result.R := c.r;
 Result.G := c.g;
 Result.B := c.b;
 Result.A := A;
end;

function SWFRGBA(c: recRGBA; A:byte = 255):recRGBA;
begin
 Result := c;
 Result.A := A;
end;

Function WithoutA(c: recRGBA): recRGB;
begin
 result := SWFRGB (c.R, c.G, c.B);
end;

Function AddAlphaValue(c: recRGBA; A: Smallint): recRGBA;
begin
 if (C.A + A) > 255 then C.A := 255 else
  if (C.A + A) < 0 then C.A := 0 else C.A := C.A + A;
end;

// Convering px <=> twips если Convert = true
Function SWFRectToRect(r: recRect; Convert: boolean = true): tRect;
begin
  With Result do
   begin
    Left   := r.Xmin;
    Right  := r.Xmax;
    Top    := r.Ymin;
    Bottom := r.Ymax;
   end;

 if Convert then
  With Result do
   begin
    Left   := Left div TWIPS;
    Right  := Right div TWIPS;
    Top    := Top div TWIPS;
    Bottom := Bottom div TWIPS;
   end;
end;

Function RectToSWFRect(r: tRect; Convert: boolean = true): recRect;
begin
 if r.Left<r.Right then
  begin
   Result.Xmin := r.Left;
   Result.Xmax := r.Right;
  end else
  begin
   Result.Xmin := r.Right;
   Result.Xmax := r.Left;
  end;

 if r.Top<r.Bottom then
  begin
   Result.Ymin := r.Top;
   Result.Ymax := r.Bottom;
  end else
  begin
   Result.Ymin := r.Bottom;
   Result.Ymax := r.Top;
  end;

 if Convert then
  With Result do
   begin
    Xmin := Xmin * TWIPS;
    Xmax := Xmax * TWIPS;
    Ymin := Ymin * TWIPS;
    Ymax := Ymax * TWIPS;
   end;
end;

//  flash used 16.16 bit
Function IntToSingle(w: longInt): single;
begin
// Result := W shr 16 + (W and $FFFF) / ($FFFF+1);
   Result :=  W / specFixed;
end;

Function SingleToInt(s: single): longInt;
begin
 Result :=  Trunc(s * specFixed);
// Result := trunc(s) shl 16 + Round(Frac(s) * ($FFFF + 1));
//  Move(s, Result, 4);
end;

Function MakeMatrix(hasScale, hasSkew: boolean;
                     ScaleX, ScaleY, SkewX, SkewY, TranslateX, TranslateY: longint): recMatrix;
begin
  Result.ScaleX := ScaleX;
  Result.ScaleY := ScaleY;
  Result.SkewX := SkewX;
  Result.SkewY := SkewY;
  Result.TranslateX := TranslateX;
  Result.TranslateY := TranslateY;
  Result.hasScale := hasScale;
  Result.hasSkew := hasSkew;
end;

Procedure MatrixSetTranslate(var M: recMatrix; X, Y: longint);
begin
  M.TranslateX := X;
  M.TranslateY := Y;
end;

Procedure MatrixSetScale(var M: recMatrix; ScaleX, ScaleY: single);
begin
  M.hasScale := true;
  M.ScaleX := SingleToInt(ScaleX);
  M.ScaleY := SingleToInt(ScaleY);
end;

Procedure MatrixSetSkew(var M: recMatrix; SkewX, SkewY: single);
begin
  M.hasSkew := true;
  M.SkewX := SingleToInt(SkewX);
  M.SkewY := SingleToInt(SkewY);
end;

Function SwapColorChannels(Color: longint): longint;
begin
  Result := (Color and $ff) shl 16 + (Color and $ff00) + (Color and $ff0000) shr 16; 
end;

Function MakeColorTransform(hasADD: boolean; addR, addG, addB, addA: Smallint;
                             hasMULT: boolean; multR, multG, multB, multA: Smallint;
                             hasAlpha: boolean): recColorTransform;
begin
  Result.hasADD := hasADD;
  Result.addR := addR;
  Result.addG := addG;
  Result.addB := addB;
  Result.addA := addA;
  Result.hasMULT := hasMULT;
  Result.multR := multR;
  Result.multG := multG;
  Result.multB := multB;
  Result.multA := multA;
  Result.hasAlpha := hasAlpha;
end;

function GetCubicPoint(P0, P1, P2, P3: Longint; t: single): double;
 var t2, b, g: double;
begin
// P(t) = P0*(1-t)^3 + P1*3*t*(1-t)^2 + P2*3*t^2*(1-t) + P3*t^3
  t2 := t * t;
  g := 3 * (P1 - P0);
	b := 3 * (P2 - P1) - g;
	Result := (P3 - P0 - b - g) * t2*t + b * t2 + g * t + P0;
end;

{$IFDEF VER130}  // Delphi 5
function Sign(const AValue: Double): shortint;
begin
if ((PInt64(@AValue)^ and $7FFFFFFFFFFFFFFF) = $0000000000000000) then
   Result := 0
  else if ((PInt64(@AValue)^ and $8000000000000000) = $8000000000000000) then
   Result := -1
  else
   Result := 1;
end;
{$ENDIF}

end.

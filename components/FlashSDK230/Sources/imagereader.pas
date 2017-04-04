//*******************************************************//
//                                                       //
//                      DelphiFlash.com                  //
//         Copyright (c) 2004-2007 FeatherySoft, Inc.    //
//                    info@delphiflash.com               //
//                                                       //
//*******************************************************//

//  Description:  Image routines
//  Last update:  28 mar 2007
unit ImageReader;

interface

uses Windows, Classes;

type

  PFColor =^TFColor;
  TFColor = packed record
    b,g,r: Byte;
  end;

  PFColorA =^TFColorA;
  TFColorA = packed record
    case Integer of
      0: (i: DWord);
      1: (c: TFColor);
      2: (hi,lo: Word);
      3: (b,g,r,a: Byte);
    end;

  PFColorTable =^TFColorTable;
  TFColorTable = array[Byte]of TFColorA;

  PFPackedColorTable =^TFPackedColorTable;
  TFPackedColorTable = array[Byte]of TFColor;

  TLines    = array[Word]of Pointer;  PLines    =^TLines;
  TLine8    = array[Word]of Byte;     PLine8    =^TLine8;
  TLine16   = array[Word]of Word;     PLine16   =^TLine16;
  TLine24   = array[Word]of TFColor;  PLine24   =^TLine24;
  TLine32   = array[Word]of TFColorA; PLine32   =^TLine32;
  TPixels8  = array[Word]of PLine8;   PPixels8  =^TPixels8;
  TPixels16 = array[Word]of PLine16;  PPixels16 =^TPixels16;
  TPixels24 = array[Word]of PLine24;  PPixels24 =^TPixels24;
  TPixels32 = array[Word]of PLine32;  PPixels32 =^TPixels32;

  PBMInfo =^TBMInfo;
  TBMInfo = packed record
    Header: TBitmapInfoHeader;
    case Integer of
      0: (Colors: TFColorTable);
      1: (RMask,GMask,BMask: DWord);
    end;

  TBMPReader = class
  private
    Info:      TBMInfo;      // bitmap information
    FreeDC:     Boolean; // default true, free GDI surface on destroy
    FreeBits:   Boolean; // default true, free Bits on destroy (non GDI only)
    FreeHandle: Boolean;
    FTransparentIndex: integer;
    procedure SetTransparentIndex(const Value: integer); // default true, free GDI handle on destroy
    function GetBMask: DWord;
    function GetGMask: DWord;
    function GetRMask: DWord;
    procedure SetBMask(const Value: DWord);
    procedure SetGMask(const Value: DWord);
    procedure SetRMask(const Value: DWord); 
    
    function GetClrUsed: DWord;
    procedure SetClrUsed(const Value: DWord);
    function GetSizeImage: DWord;
    procedure SetSizeImage(const Value: DWord); 
    function GetCompression: DWord;
    procedure SetCompression(const Value: DWord);
    function GetBpp: Word;
    procedure SetBpp(const Value: Word);
    function GetHeight: Integer;
    procedure SetHeight(const Value: Integer);
    function GetWidth: Integer;
    procedure SetWidth(const Value: Integer);
  protected
    procedure PrepareAlphaTables(bmHeader: TBitmapInfoHeader);
  public
    DC:    HDC;
    Handle: HBITMAP; // current DIB in hDC

    BWidth:    Integer;      // number of bytes per scanline
    AbsHeight: Integer;      // number of scanlines in bitmap
    Gap:       Integer;      // number of pad bytes at end of scanline
    Bits:      PLine8;       // typed pointer to bits
    Colors:    PFColorTable; // typed pointer to color table


    Bpb,Bpg,Bpr:    Byte; // bits per channel (only 16 & 32bpp)
    BShr,GShr,RShr: Byte; // (B shr BShr)or(G shr GShr shl GShl)or
    BShl,GShl,RShl: Byte; // (R shr RShr shl RShl) = 16bit/32bit pixel

    Scanlines:  PLines;    // typed pointer to array of scanline offsets
    Pixels8:    PPixels8;  // typed scanlines - Pixels8[y,x]:  Byte
    Pixels16:   PPixels16; // typed scanlines - Pixels16[y,x]: Word
    Pixels24:   PPixels24; // typed scanlines - Pixels24[y,x]: TFColor
    Pixels32:   PPixels32; // typed scanlines - Pixels32[y,x]: TFColorA

    constructor Create;
    destructor Destroy; override;
    procedure FreeHandles;
    procedure Assign(Bmp:TBMPReader);

    // use these for debugging or reference (these don't belong in long loops)
    procedure SetPixel(y,x:Integer;c:TFColor);
    procedure SetPixelB(y,x:Integer;c:Byte);
    function GetPixel(y,x:Integer):TFColor;
    function GetPixelB(y,x:Integer):Byte;
    property Pixels[y,x:Integer]:TFColor read GetPixel write SetPixel;
    property PixelsB[y,x:Integer]:Byte read GetPixelB write SetPixelB;

    property Width: Integer read GetWidth write SetWidth;
    property Height: Integer read GetHeight write SetHeight;
    property Bpp: Word read GetBpp write SetBpp;
    property Compression: DWord read GetCompression write SetCompression;
    property SizeImage: DWord read GetSizeImage write SetSizeImage;
    property ClrUsed: DWord read GetClrUsed write SetClrUsed;
    property RMask: DWord read GetRMask write SetRMask;
    property GMask: DWord read GetGMask write SetGMask;
    property BMask: DWord read GetBMask write SetBMask;

    // initializers
    procedure SetSize(fWidth,fHeight:Integer;fBpp:Byte);
    procedure SetSizeEx(fWidth, fHeight: Integer; fBpp, fBpr, fBpg, fBpb: Byte);
    procedure SetSizeIndirect(bmInfo: TBMInfo);
    procedure SetInterface(fBits: Pointer; fWidth, fHeight: Integer; fBpp, fBpr, fBpg, fBpb: Byte);
    procedure SetInterfaceIndirect(fBits:Pointer;bmInfo:TBMInfo);
    procedure MakeCopy(Bmp:TBMPReader;CopyBits:Boolean);
    procedure LoadFromHandle(hBmp:HBITMAP);
    procedure LoadFromFile(FileName:string);
    procedure LoadFromStream(stream: TStream);
    procedure LoadFromRes(hInst:HINST;ResID,ResType:PChar);

    // blitting methods
    procedure UpdateColors;
    property TransparentIndex: integer read FTransparentIndex write SetTransparentIndex;

    // utilities
    procedure Clear(c:TFColor);
    procedure ClearB(c:DWord);
    procedure SaveToFile(FileName:string);
    procedure SaveToStream(stream: TStream);
    procedure CopyRect(Src:TBMPReader; x,y, w,h, sx,sy:Integer);
    procedure ShiftColors(i1,i2,Amount:Integer);
  end;


function CreateDIB(fDC:HDC;bmInfo:PBMInfo;iColor:DWord;var Bits:PLine8;hSection,dwOffset:DWord):HBITMAP; stdcall;

Function LoadHeaderFromFile(FileName:string): TBMInfo;

procedure SetAlphaChannel(Bmp, Alpha: TBMPReader);
procedure FillAlpha(Bmp: TBMPReader; Alpha: byte);
procedure FillAlphaNoSrc(Bmp: TBMPReader; Alpha: byte);
function IsInitAlpha(Bmp: TBMPReader): boolean;
procedure MultiplyAlpha(Bmp:TBMPReader);
procedure SwapChannels(Bmp:TBMPReader);
procedure FillMem(Mem:Pointer;Size,Value:Integer);
procedure Clear(Bmp:TBMPReader;c:TFColor);
procedure ClearB(Bmp:TBMPReader;c:DWord);
procedure DecodeRLE4(Bmp:TBMPReader;Data:Pointer);
procedure DecodeRLE8(Bmp:TBMPReader;Data:Pointer);

function  ClosestColor(Pal:PFColorTable;Max:Integer;c:TFColor):Byte;
function  LoadHeader(Data:Pointer; var bmInfo:TBMInfo):Integer;
function  PackedDIB(Bmp:TBMPReader):Pointer;
function  CountColors(Bmp:TBMPReader):DWord;

procedure IntToMask(Bpr,Bpg,Bpb:DWord;var RMsk,GMsk,BMsk:DWord);
procedure MaskToInt(RMsk,GMsk,BMsk:DWord;var Bpr,Bpg,Bpb:DWord);
function  UnpackColorTable(Table:TFPackedColorTable):TFColorTable;
function  PackColorTable(Table:TFColorTable):TFPackedColorTable;
function  FRGB(r,g,b:Byte):TFColor;
function  FRGBA(r,g,b,a:Byte):TFColorA;
function  ColorToInt(c:TFColor):DWord;
function  ColorToIntA(c:TFColorA):DWord;
function  IntToColor(i:DWord):TFColor;
function  IntToColorA(i:DWord):TFColorA;
function  Scale8(i,n:Integer):Integer;
function  Get16Bpg:Byte;

Function isSupportImageFormat(fn: string): boolean;

procedure GetJPGSize(const sFile: string; var wWidth, wHeight: word);
//procedure GetPNGSize(const sFile: string; var wWidth, wHeight: word);
//procedure GetGIFSize(const sGIFFile: string; var wWidth, wHeight: word);

implementation

Uses SysUtils;


function CreateDIB; external 'gdi32.dll' name 'CreateDIBSection';

function ReadMWord(f: TFileStream): word;

type
  TMotorolaWord = record
  case byte of
  0: (Value: word);
  1: (Byte1, Byte2: byte);
end;

var
  MW: TMotorolaWord;
begin
{It would probably be better to just read these two bytes in normally and
then do a small ASM routine to swap them. But we aren't talking about
reading entire files, so I doubt the performance gain would be worth the trouble.}
  f.Read(MW.Byte2, SizeOf(Byte));
  f.Read(MW.Byte1, SizeOf(Byte));
  Result := MW.Value;
end;


procedure GetJPGSize(const sFile: string; var wWidth, wHeight: word);
const
  ValidSig : array[0..1] of byte = ($FF, $D8);
  Parameterless = [$01, $D0, $D1, $D2, $D3, $D4, $D5, $D6, $D7];
var
  Sig: array[0..1] of byte;
  f: TFileStream;
  x: integer;
  Seg: byte;
  Dummy: array[0..15] of byte;
  Len: word;
  ReadLen: LongInt;
begin
  FillChar(Sig, SizeOf(Sig), #0);
  f := TFileStream.Create(sFile, fmOpenRead+fmShareDenyWrite);
  try
    ReadLen := f.Read(Sig[0], SizeOf(Sig));
    for x := Low(Sig) to High(Sig) do
    if Sig[x] <> ValidSig[x] then ReadLen := 0;
    if ReadLen > 0 then begin
      ReadLen := f.Read(Seg, 1);
      while (Seg = $FF) and (ReadLen > 0) do begin
        ReadLen := f.Read(Seg, 1);
        if Seg <> $FF then begin
          if (Seg = $C0) or (Seg = $C1) then begin
            ReadLen := f.Read(Dummy[0], 3); { don't need these bytes }
            wHeight := ReadMWord(f);
            wWidth := ReadMWord(f);
          end else begin
            if not (Seg in Parameterless) then begin
              Len := ReadMWord(f);
              f.Seek(Len-2, 1);
              f.Read(Seg, 1);
            end else
              Seg := $FF; { Fake it to keep looping. }
            end;
          end;
        end;
      end;
  finally
    f.Free;
  end;
end;


Function isSupportImageFormat(fn: string): boolean;
  var Ext: string;
begin
  Ext := UpperCase(ExtractFileExt(fn));
  Result := (Ext = '.BMP') or (Ext = '.JPG') or (Ext = '.JPEG');
end;

constructor TBMPReader.Create;
begin
  inherited Create;
  Bits := nil;
  Scanlines := nil;
  FTransparentIndex := -1;
  FillChar(Info, SizeOf(Info),0);
  Info.Header.biSize := SizeOf(TBitmapInfoHeader);
  Info.Header.biPlanes := 1;
  Colors := @Info.Colors;
end;

destructor TBMPReader.Destroy;
begin
  FreeHandles;
  inherited Destroy;
end;

procedure TBMPReader.FreeHandles;
begin
  if (DC <> 0) and FreeDC then DeleteDC(DC);
  if (Handle <> 0) and FreeHandle then DeleteObject(Handle);
  if (Scanlines <> nil) then ReallocMem(Scanlines, 0);
  if (Bits <> nil) and FreeBits then ReallocMem(Bits, 0);
end;

procedure TBMPReader.Assign(Bmp:TBMPReader);
begin
  FreeHandles;

  DC := Bmp.DC;
  Handle:=Bmp.Handle;       BWidth:=Bmp.BWidth;
  AbsHeight:=Bmp.AbsHeight; Gap:=Bmp.Gap;
  Bits:=Bmp.Bits;           Colors^:=Bmp.Colors^;
  Info:=Bmp.Info;           BShr:=Bmp.BShr;
  GShr:=Bmp.GShr;           GShl:=Bmp.GShl;
  RShr:=Bmp.RShr;           RShl:=Bmp.RShl;
  Bpr:=Bmp.Bpr;             Bpg:=Bmp.Bpg;
  Bpb:=Bmp.Bpb;             Scanlines:=Bmp.Scanlines;
  Pixels8:=Bmp.Pixels8;     Pixels16:=Bmp.Pixels16;
  Pixels24:=Bmp.Pixels24;   Pixels32:=Bmp.Pixels32;
  FreeDC:=Bmp.FreeDC;
  FreeBits:=Bmp.FreeBits;   FreeHandle:=Bmp.FreeHandle;

  Bmp.FreeDC:=False;
  Bmp.FreeHandle:=False;
  Bmp.Scanlines:=nil;
  Bmp.FreeBits:=False;
  Bmp.Free;
end;

procedure TBMPReader.SetPixel(y,x:Integer;c:TFColor);
begin
  case Bpp of
    1,4,8: PixelsB[y,x]:=ClosestColor(Colors,(1 shl Bpp)-1,c);
    16: Pixels16[y,x]:=
          c.r shr RShr shl RShl or
          c.g shr GShr shl GShl or
          c.b shr BShr;
    24: Pixels24[y,x]:=c;
    32: if Compression=0 then Pixels32[y,x].c:=c else
        Pixels32[y,x].i:=
          c.r shr RShr shl RShl or
          c.g shr GShr shl GShl or
          c.b shr BShr;
  end;
end;

procedure TBMPReader.SetPixelB(y,x:Integer;c:Byte);
var
  mo: Byte;
  pb: PByte;
begin
  case Bpp of
    1:
    begin
      c:=c and 1;
      mo:=(x and 7)xor 7;
      pb:=@Pixels8[y,x shr 3];
      pb^:=pb^ and(not(1 shl mo))or(c shl mo);
    end;
    4:
    begin
      c:=c and 15;
      pb:=@Pixels8[y,x shr 1];
      if(x and 1)=0 then pb^:=(pb^and $0F)or(c shl 4)else pb^:=(pb^and $F0)or c;
    end;
    8: Pixels8[y,x]:=c;
  end;
end;

function TBMPReader.GetBMask: DWord;
begin
  Result := Info.BMask;
end;

procedure TBMPReader.SetRMask(const Value: DWord);
begin
  Info.RMask := Value;
end;

function TBMPReader.GetBpp: Word;
begin
  Result := Info.Header.biBitCount;
end;

function TBMPReader.GetClrUsed: DWord;
begin
 Result := Info.Header.biClrUsed
end;

function TBMPReader.GetCompression: DWord;
begin
  Result := Info.Header.biCompression
end;

function TBMPReader.GetGMask: DWord;
begin
  Result := Info.GMask;
end;

function TBMPReader.GetHeight: Integer;
begin
  Result := Info.Header.biHeight;
end;

function TBMPReader.GetPixel(y,x:Integer):TFColor;
var
  w: Word;
  d: DWord;
begin
  case Bpp of
    1,4,8: Result:=Colors[PixelsB[y,x]].c;
    16:
    begin
      w:=Pixels16[y,x];
      Result.b:=Scale8(w and BMask,Bpb);
      Result.g:=Scale8(w and GMask shr GShl,Bpg);
      Result.r:=Scale8(w and RMask shr RShl,Bpr);
    end;
    24: Result:=Pixels24[y,x];
    32:
    if Compression=0 then Result:=Pixels32[y,x].c else
    begin
      d:=Pixels32[y,x].i;
      Result.b:=Scale8(d and BMask,Bpb);
      Result.g:=Scale8(d and GMask shr GShl,Bpg);
      Result.r:=Scale8(d and RMask shr RShl,Bpr);
    end;
  end;
end;

function TBMPReader.GetPixelB(y,x:Integer):Byte;
var
  mo: Byte;
begin
  case Bpp of
    1:
    begin
      mo := (x and 7)xor 7;
      Result := Pixels8[y, x shr 3] and (1 shl mo) shr mo;
    end;
    4: if (x and 1) = 0 then Result := Pixels8[y,x shr 1] shr 4 else Result:=Pixels8[y,x shr 1] and 15;
    8: Result:=Pixels8[y,x];
    else Result:=0;
  end;
end;

function TBMPReader.GetRMask: DWord;
begin
  Result := Info.RMask;
end;

function TBMPReader.GetSizeImage: DWord;
begin
  Result := Info.Header.biSizeImage;
end;

procedure TBMPReader.SetWidth(const Value: Integer);
begin
  Info.Header.biWidth := Value;
end;

procedure TBMPReader.SetSize(fWidth,fHeight:Integer;fBpp:Byte);
begin
  SetInterface(nil,fWidth,fHeight,fBpp,0,0,0);
end;

procedure TBMPReader.SetSizeEx(fWidth,fHeight:Integer;fBpp,fBpr,fBpg,fBpb:Byte);
begin
  SetInterface(nil,fWidth,fHeight,fBpp,fBpr,fBpg,fBpb);
end;

procedure TBMPReader.SetSizeImage(const Value: DWord);
begin
  Info.Header.biSizeImage := Value;
end;

procedure TBMPReader.SetSizeIndirect(bmInfo: TBMInfo);
var
  r, g, b: DWord;
begin
  if bmInfo.Header.biCompression in [1, 2] then
    if (bmInfo.RMask <> 0) or (bmInfo.GMask <> 0) or (bmInfo.BMask <> 0)then
      bmInfo.Header.biCompression := 3 else bmInfo.Header.biCompression := 0;
  if (bmInfo.Header.biBitCount in [16, 32]) and (bmInfo.Header.biCompression = 3) then
    MaskToInt(bmInfo.RMask, bmInfo.GMask, bmInfo.BMask, r, g, b) else
  begin
    r:=0;
    g:=0;
    b:=0;
  end;

  FTransparentIndex := -1;
  if bmInfo.Header.biBitCount <= 8 then
    Colors^ := bmInfo.Colors;
  PrepareAlphaTables(bmInfo.Header);
  SetInterface(nil, bmInfo.Header.biWidth, bmInfo.Header.biHeight, bmInfo.Header.biBitCount, r, g, b);
end;

procedure TBMPReader.SetTransparentIndex(const Value: integer);
begin
  if (BPP <= 8) and (FTransparentIndex <> Value) then
    begin
      Colors[FTransparentIndex].A := $FF;
      FTransparentIndex := Value;
      Colors[FTransparentIndex].A := 0;
    end;
end;

function TBMPReader.GetWidth: Integer;
begin
  Result := Info.Header.biWidth;
end;

procedure TBMPReader.SetBMask(const Value: DWord);
begin
  Info.BMask := Value;
end;

procedure TBMPReader.SetBpp(const Value: Word);
begin
  Info.Header.biBitCount := Value;
end;

procedure TBMPReader.SetClrUsed(const Value: DWord);
begin
  Info.Header.biClrUsed := Value;
end;

procedure TBMPReader.SetCompression(const Value: DWord);
begin
  Info.Header.biCompression := Value;
end;

procedure TBMPReader.SetGMask(const Value: DWord);
begin
  Info.GMask := Value;
end;

procedure TBMPReader.SetHeight(const Value: Integer);
begin
  Info.Header.biHeight := Value; 
end;

procedure TBMPReader.SetInterface(fBits: Pointer; fWidth, fHeight: Integer;
                                  fBpp, fBpr, fBpg, fBpb: Byte);
var
  x, il: Integer;
  sDC: Windows.HDC;
begin

  if fBpp=0 then
  begin
    sDC:=GetDC(0);
    fBpp:=GetDeviceCaps(sDC, BITSPIXEL);
    ReleaseDC(0,sDC);
    if fBpp=16 then
    begin
      fBpr:=5;
      fBpg:=Get16Bpg;
      fBpb:=5;
    end else if fBpp=32 then
    begin
      fBpr:=8;
      fBpg:=8;
      fBpb:=8;
    end;
  end;

  if (fBpr = 0) and (fBpg = 0) and (fBpb = 0) then
  begin
    Compression:=0;
    if fBpp=16 then
    begin
      fBpr:=5;
      fBpg:=5;
      fBpb:=5;
    end else if fBpp=32 then
    begin
      fBpr:=8;
      fBpg:=8;
      fBpb:=8;
    end;
  end else Compression:=3;

  if( fBpp=16) or (fBpp=32) then IntToMask(fBpr, fBpg, fBpb, Info.RMask, Info.GMask, Info.BMask);

  if((fBits=nil) and (fWidth=Width) and (fHeight=Height) and (fBpp=Bpp) and
     (fBpr=Bpr) and (fBpg=Bpg) and (fBpb=Bpb)) and (DC<>0) then Exit;

  Width:=fWidth;            Height:=fHeight;
  AbsHeight:=Abs(fHeight);  Bpp:=fBpp;
  Bpr:=fBpr;                Bpg:=fBpg;
  Bpb:=fBpb;                GShl:=Bpb;
  RShl:=Bpb+Bpg;

  if Bpb<8 then BShr:=8-Bpb else BShr:=0;
  if Bpg<8 then GShr:=8-Bpg else GShr:=0;
  if Bpr<8 then RShr:=8-Bpr else RShr:=0;

  case Bpp of
    1:
    begin
      x:=(Width+7)and -8;
      BWidth:=((x+31)and -32)shr 3;
      Gap:=BWidth-(x shr 3);
    end;
    4:
    begin
      x:=((Width shl 2)+7)and -8;
      BWidth:=((x+31)and -32)shr 3;
      Gap:=BWidth-(x shr 3);
    end;
    8:
    begin
      BWidth:=(((Width shl 3)+31)and -32)shr 3;
      Gap:=BWidth-Width;
    end;
    16:
    begin
      BWidth:=(((Width shl 4)+31)and -32)shr 3;
      Gap:=BWidth-(Width shl 1);
    end;
    24:
    begin
      BWidth:=(((Width*24)+31)and -32)shr 3;
      Gap:=BWidth-((Width shl 1)+Width);
    end;
    32:
    begin
      BWidth:=(((Width shl 5)+31)and -32)shr 3;
      Gap:=0;
    end;
  end;

  SizeImage := AbsHeight * BWidth;

  if (fBits<>nil) then Bits := fBits else
  begin
    if (DC<>0) and FreeDC then DeleteDC(DC);
    if (Handle<>0) and FreeHandle then DeleteObject(Handle);

    if (Bits <> nil) and FreeBits then ReallocMem(Bits, 0);
    Handle := CreateDIB(0, @Info, 0, Bits, 0, 0);
    DC := CreateCompatibleDC(0);
    SelectObject(DC, Handle);
    FreeBits := False;
    FreeDC := True;
    FreeHandle := True;
  end;

  ReallocMem(Scanlines, AbsHeight shl 2);
  Pixels8 := Pointer(Scanlines);
  Pixels16 := Pointer(Scanlines);
  Pixels24 := Pointer(Scanlines);
  Pixels32 := Pointer(Scanlines);

  if AbsHeight>0 then
  begin
    x := Integer(Bits);
    for il:=0 to AbsHeight-1 do
    begin
      Scanlines[il] := Ptr(x);
      Inc(x, BWidth);
    end;
  end;
end;

procedure TBMPReader.SetInterfaceIndirect(fBits: Pointer; bmInfo: TBMInfo);
var
  r, g, b: DWord;
begin
  With bmInfo.Header do
   begin
     if biCompression in [1, 2] then
       if (bmInfo.RMask<>0) or (bmInfo.GMask<>0) or (bmInfo.BMask<>0) then
         biCompression := 3 else biCompression := 0;
     if (biBitCount in [16, 32]) and (biCompression = 3) then
       MaskToInt(bmInfo.RMask, bmInfo.GMask, bmInfo.BMask, r, g, b) else
     begin
       r:=0; g:=0; b:=0;
     end;
     if biBitCount<=8 then Colors^:=bmInfo.Colors;
   end;
  SetInterface(fBits, bmInfo.Header.biWidth, bmInfo.Header.biHeight, bmInfo.Header.biBitCount, r, g, b);
end;

procedure TBMPReader.MakeCopy(Bmp: TBMPReader; CopyBits: Boolean);
begin
  SetSizeIndirect(Bmp.Info);
  if CopyBits then Move(Bmp.Bits^, Bits^, SizeImage);
end;

procedure TBMPReader.PrepareAlphaTables(bmHeader: TBitmapInfoHeader);
var
  il, maxCheck: integer;
  NeedFillAlpha, is0, is255: boolean;
begin
  FTransparentIndex := -1;
  if bmHeader.biBitCount <= 8 then
    begin
      if bmHeader.biBitCount = 8 then
        begin
          is0 := false;
          is255 := false;
          if bmHeader.biClrUsed > 0 then maxCheck := bmHeader.biClrUsed - 1
            else maxCheck := $FF;
          for il := 0 to maxCheck do
            begin
              if Colors[il].A = $FF then is255 := true else
                if Colors[il].A = 0 then is0 := true;
            end;
          NeedFillAlpha := (is0 and not is255);
          if is0 and is255 then
            for il := 0 to $FF do
              if Colors[il].A = 0 then
                begin
                  FTransparentIndex := il;
                  Break;
                end;
        end else
          NeedFillAlpha := true;
      if NeedFillAlpha then
        for il := 0 to (1 shl bmHeader.biBitCount) - 1 do
          Colors[il].A := $FF;
    end;
end;

procedure TBMPReader.LoadFromHandle(hBmp:HBITMAP);
var
  dsInfo: TDIBSection;
begin
  if GetObject(hBmp,SizeOf(dsInfo),@dsInfo)=84 then
  begin
    SetSizeIndirect(PBMInfo(@dsInfo.dsBmih)^);
    if dsInfo.dsBmih.biCompression = 1 then DecodeRLE8(Self,dsInfo.dsBm.bmBits)
    else if dsInfo.dsBmih.biCompression = 2 then DecodeRLE4(Self,dsInfo.dsBm.bmBits)
    else Move(dsInfo.dsBm.bmBits^, Bits^, dsInfo.dsBmih.biSizeImage);
    if Bpp <= 8 then
    begin
      GetDIBits(DC, hBmp, 0, 0, nil, PBitmapInfo(@Info)^, 0);
      UpdateColors;
      PrepareAlphaTables(Info.Header);
    end;
  end else
  begin
    SetSize(dsInfo.dsBm.bmWidth, dsInfo.dsBm.bmHeight, 0);
    GetDIBits(DC, hBmp, 0, AbsHeight, Bits, PBitmapInfo(@Info)^, 0);
    if Bpp <= 8 then
      begin
        UpdateColors;
        PrepareAlphaTables(Info.Header);
      end;
  end;
end;

procedure TBMPReader.LoadFromFile(FileName: string);
var
  FS : TFileStream;
begin
   FS := TFileStream.Create(FileName, fmOpenRead + fmShareDenyWrite);
   LoadFromStream(FS);
   FS.Free;
end;

procedure TBMPReader.LoadFromStream(stream: TStream);
var
  Buffer: Pointer;
  bmInfo: TBMInfo;
  fBits, xSize: DWord;
begin
  xSize := stream.size;
  if xSize > 1078 then xSize := 1078;
  GetMem(Buffer, 1078);
  stream.read(Buffer^, xSize);
  fBits := LoadHeader(Buffer, bmInfo);
  SetSizeIndirect(bmInfo);
  stream.Seek(fBits - xSize, soFromCurrent);
  if bmInfo.Header.biCompression in [1, 2] then xSize := PDWord(Integer(Buffer)+2)^ - fBits
   else
    if (stream.size - fBits) > SizeImage then xSize := SizeImage else xSize := stream.size - fBits;
  if bmInfo.Header.biCompression in [0, 3] then stream.read(Bits^, xSize) else
   begin
    ReAllocMem(Buffer, xSize);
    stream.read(Buffer^, xSize);
    if bmInfo.Header.biCompression=1 then DecodeRLE8(Self, Buffer) else DecodeRLE4(Self, Buffer);
   end;
  FreeMem(Buffer);
end;

Function LoadHeaderFromFile(FileName:string): TBMInfo;
var
  Buffer: Pointer;
  hFile: Windows.HFILE;
  xSize, fSize, i: DWord;
begin
  hFile := CreateFile(PChar(FileName),GENERIC_READ,FILE_SHARE_READ,nil,OPEN_EXISTING,0,0);
  fSize := GetFileSize(hFile,nil);
  xSize := fSize;
  if xSize > 1078 then xSize :=1078;
  GetMem(Buffer, 1078);
  ReadFile(hFile, Buffer^, xSize, i, nil);
  LoadHeader(Buffer, Result);
  CloseHandle(hFile);
  FreeMem(Buffer);
end;

procedure TBMPReader.LoadFromRes(hInst: HINST; ResID, ResType: PChar);
var
  pMem: Pointer;
  bmInfo: TBMInfo;
  fSize,fBits: DWord;
begin
  pMem := LockResource(LoadResource(hInst, FindResource(hInst, ResID, ResType)));
  if pMem<>nil then
  begin
    fBits := LoadHeader(pMem,bmInfo);
    fSize := PDWord(pMem)^-DWord(fBits);
    SetSizeIndirect(bmInfo);
    if SizeImage < fSize then fSize := SizeImage;
    if bmInfo.Header.biCompression=1 then DecodeRLE8(Self, Ptr(DWord(pMem) + fBits))
      else
      if bmInfo.Header.biCompression=2 then DecodeRLE4(Self, Ptr(DWord(pMem) + fBits))
       else Move(Ptr(DWord(pMem)+fBits)^,Bits^,fSize);
  end;
end;

procedure TBMPReader.UpdateColors;
begin
  SetDIBColorTable(DC, 0, 1 shl Bpp, Colors^);
end;


procedure TBMPReader.Clear(c:TFColor);
begin
  ImageReader.Clear(Self, c);
end;

procedure TBMPReader.ClearB(c:DWord);
begin
  ImageReader.ClearB(Self,c);
end;

procedure TBMPReader.SaveToFile(FileName:string);
var
  FS: TFileStream;
begin
  if fileExists(FileName) then DeleteFile(FileName);
  FS := TFileStream.Create(FileName, fmCreate);
  SaveToStream(FS);
  FS.Free;
end;

procedure TBMPReader.SaveToStream(stream: TStream);
 var
  cSize: DWord;
  fHead: TBitmapFileHeader;
begin
  if Info.Header.biClrUsed<>0
    then cSize := (Info.Header.biClrUsed shl 2)
    else if Info.Header.biCompression=BI_BITFIELDS then cSize := 12
      else if Bpp <= 8 then cSize := (1 shl Bpp) shl 2
        else cSize := 0;

  fHead.bfType := $4D42;
  fHead.bfOffBits := 54 + cSize;
  fHead.bfSize := fHead.bfOffBits + SizeImage;
  stream.Write(fHead, SizeOf(fHead));
  stream.Write(Info,cSize+40);
  stream.WriteBuffer(Bits^, SizeImage);
end;

procedure TBMPReader.CopyRect(Src:TBMPReader;x,y,w,h,sx,sy:Integer);
var
  iy,pc,sc,b: Integer;
begin
  if Height>0 then y:=AbsHeight-h-y;
  if Src.Height>0 then sy:=Src.Height-h-sy;

  if x<0 then
  begin
    Dec(sx,x);
    Inc(w,x);
    x:=0;
  end;

  if y<0 then
  begin
    Dec(sy,y);
    Inc(h,y);
    y:=0;
  end;

  if sx<0 then
  begin
    Dec(x,sx);
    Inc(w,sx);
    sx:=0;
  end;

  if sy<0 then
  begin
    Dec(y,sy);
    Inc(h,sy);
    sy:=0;
  end;

  if(sx<Src.Width)and(sy<Src.AbsHeight)and(x<Width)and(y<AbsHeight)then
  begin

    if w+sx>=Src.Width then w:=Src.Width-sx;
    if h+sy>=Src.AbsHeight then h:=Src.AbsHeight-sy;
    if w+x>=Width then w:=Width-x;
    if h+y>=AbsHeight then h:=AbsHeight-y;

    if (Bpp <= 8) and (Bpp=Src.Bpp) then
      Move(Src.Colors^, Colors^, SizeOf(TFColorTable));

    if(Bpp>=8)and(Bpp=Src.Bpp)then
    begin

      b:=w;
      case Bpp of
        16:
        begin
          b:=w shl 1;
          x:=x shl 1;
          sx:=sx shl 1;
        end;
        24:
        begin
          b:=w*3;
          x:=x*3;
          sx:=sx*3;
        end;
        32:
        begin
          b:=w shl 2;
          x:=x shl 2;
          sx:=sx shl 2;
        end;
      end;

      pc:=Integer(Scanlines[y])+x;
      sc:=Integer(Src.Scanlines[sy])+sx;

      for iy:=0 to h-1 do
      begin
        Move(Ptr(sc)^,Ptr(pc)^,b);
        Inc(pc,BWidth);
        Inc(sc,Src.BWidth);
      end;

    end else
    begin
      for iy:=0 to h-1 do
      for b:=0 to w-1 do
        Pixels[y+iy,x+b]:=Src.Pixels[sy+iy,sx+b];
    end;

  end;
end;

procedure TBMPReader.ShiftColors(i1, i2, Amount: Integer);
var
  p: PFColorTable;
  i: Integer;
begin
  i:= i2 - i1;
  if (Amount < i) and (Amount > 0) then
  begin
    GetMem(p, i shl 2);
    Move(Colors[i1], p[0], i shl 2);
    Move(p[0], Colors[i1 + Amount], (i - Amount) shl 2);
    Move(p[i - Amount], Colors[i1], Amount shl 2);
    FreeMem(p);
  end;
  if DC <> 0 then UpdateColors;
end;

////////////////////////////////////////////////////////////////////////////////

procedure SetAlphaChannel(Bmp, Alpha: TBMPReader);
var
  pb: PByte;
  pc: PFColorA;
  x,y: Integer;
begin
  pb := Pointer(Alpha.Bits);
  pc := Pointer(Bmp.Bits);
  for y := 0 to Alpha.AbsHeight - 1 do
  begin
    for x := 0 to Alpha.Width - 1 do
    begin
      pc^.a := pb^;
      Inc(pc);
      Inc(pb);
    end;
    pc := Ptr(Integer(pc) + Bmp.Gap);
    Inc(pb, Alpha.Gap);
  end;
end;

procedure FillAlpha(Bmp: TBMPReader; Alpha: byte);
var
  pc: PFColorA;
  x,y: Integer;
begin
  pc := Pointer(Bmp.Bits);
  for y := 0 to Bmp.AbsHeight - 1 do
  begin
    for x := 0 to Bmp.Width - 1 do
    begin
      pc^.a := Alpha;
      Inc(pc);
    end;
    pc := Ptr(Integer(pc) + Bmp.Gap);
  end;
end;

procedure FillAlphaNoSrc(Bmp: TBMPReader; Alpha: byte);
var
  pc: PFColorA;
  x,y: Integer;
begin
  pc := Pointer(Bmp.Bits);
  for y := 0 to Bmp.AbsHeight - 1 do
  begin
    for x := 0 to Bmp.Width - 1 do
    begin
      if (pc^.r > 0) or (pc^.g > 0) or (pc^.b > 0)
        then pc^.a := Alpha
        else pc^.a := 0;
      Inc(pc);
    end;
    pc := Ptr(Integer(pc) + Bmp.Gap);
  end;
end;

function IsInitAlpha(Bmp: TBMPReader): boolean;
var
  pc: PFColorA;
  x,y: Integer;
begin
  pc := Pointer(Bmp.Bits);
  Result := false;
  for y := 0 to Bmp.AbsHeight - 1 do
  begin
    for x := 0 to Bmp.Width - 1 do
    begin
      Result := pc^.a > 0;
      if Result then Exit;
      Inc(pc);
    end;
    pc := Ptr(Integer(pc) + Bmp.Gap);
  end;
end;

procedure MultiplyAlpha(Bmp:TBMPReader);
var
  pc: PFColorA;
  x,y,i: Integer;
begin
  pc:=Pointer(Bmp.Bits);
  for y:=0 to Bmp.AbsHeight-1 do
  begin
    for x:=0 to Bmp.Width-1 do
    begin
      i:=pc.a;
      if i=0 then
      begin
        pc.b:=0;
        pc.g:=0;
        pc.r:=0;
      end else if i<255 then
      begin
        pc.b:=(pc.b*i)shr 8;
        pc.g:=(pc.g*i)shr 8;
        pc.r:=(pc.r*i)shr 8;
      end;
      Inc(pc);
    end;
    pc:=Ptr(Integer(pc)+Bmp.Gap);
  end;
end;

procedure SwapChannels24(Bmp:TBMPReader);
var
  pc: PFColor;
  x,y,z: Integer;
begin
  pc:=Pointer(Bmp.Bits);
  for y:=0 to Bmp.AbsHeight-1 do
  begin
    for x:=0 to Bmp.Width-1 do
    begin
      z:=pc.r;
      pc.r:=pc.b;
      pc.b:=z;
      Inc(pc);
    end;
    pc:=Ptr(Integer(pc)+Bmp.Gap);
  end;
end;

procedure SwapChannels32(Bmp:TBMPReader);
var
  pc: PFColorA;
  x,y,z: Integer;
begin
  pc:=Pointer(Bmp.Bits);
  for y:=0 to Bmp.AbsHeight-1 do
  begin
    for x:=0 to Bmp.Width-1 do
    begin
      z:=pc.r;
      pc.r:=pc.b;
      pc.b:=z;
      Inc(pc);
    end;
    pc:=Ptr(Integer(pc)+Bmp.Gap);
  end;
end;

procedure SwapChannels(Bmp:TBMPReader);
begin
  case Bmp.Bpp of
    24: SwapChannels24(Bmp);
    32: SwapChannels32(Bmp);
  end;
end;

procedure FillMem(Mem:Pointer;Size,Value:Integer);
asm
  push edi
  push ebx

  mov ebx,edx
  mov edi,eax
  mov eax,ecx
  mov ecx,edx
  shr ecx,2
  jz  @word
  rep stosd

  @word:
  mov ecx,ebx
  and ecx,2
  jz  @byte
  mov [edi],ax
  add edi,2

  @byte:
  mov ecx,ebx
  and ecx,1
  jz  @exit
  mov [edi],al

  @exit:
  pop ebx
  pop edi
end;

procedure Clear(Bmp:TBMPReader;c:TFColor);
begin
  case Bmp.Bpp of
    1,4,8: ClearB(Bmp,ClosestColor(Bmp.Colors,(1 shl Bmp.Bpp)-1,c));
    16: ClearB(Bmp,c.r shr Bmp.RShr shl Bmp.RShl or
          c.g shr Bmp.GShr shl Bmp.GShl or
          c.b shr Bmp.BShr);
    24: ClearB(Bmp,PDWord(@c)^);
    32: if Bmp.Compression = 0 then ClearB(Bmp,PDWord(@c)^) else
        ClearB(Bmp,c.r shr Bmp.RShr shl Bmp.RShl or
          c.g shr Bmp.GShr shl Bmp.GShl or
          c.b shr Bmp.BShr);
  end;
end;

procedure ClearB(Bmp:TBMPReader;c:DWord);
var
  i: Integer;
  pc: PFColor;
begin
  if(Bmp.Bpp=1)and(c=1)then c:=15;
  if Bmp.Bpp<=4 then c:=c or c shl 4;
  if Bmp.Bpp<=8 then
  begin
    c:=c or c shl 8;
    c:=c or c shl 16;
  end else if Bmp.Bpp=16 then c:=c or c shl 16;
  if Bmp.Bpp=24 then
  begin
    pc:=Pointer(Bmp.Bits);
    for i:=0 to Bmp.Width-1 do
    begin
      pc^:=PFColor(@c)^;
      Inc(pc);
    end;
    for i:=1 to Bmp.AbsHeight-1 do
      Move(Bmp.Bits^,Bmp.Scanlines[i]^,Bmp.BWidth-Bmp.Gap);
  end else
  begin
    if Bmp.SizeImage <> 0 then FillMem(Bmp.Bits, Bmp.SizeImage, c) else
      for i:=0 to Bmp.AbsHeight-1 do
        FillMem(Bmp.Scanlines[i],Bmp.BWidth-Bmp.Gap,c);
  end;
end;

procedure DecodeRLE4(Bmp:TBMPReader;Data:Pointer);
  procedure OddMove(Src,Dst:PByte;Size:Integer);
  begin
    if Size=0 then Exit;
    repeat
      Dst^:=(Dst^ and $F0)or(Src^ shr 4);
      Inc(Dst);
      Dst^:=(Dst^ and $0F)or(Src^ shl 4);
      Inc(Src);
      Dec(Size);
    until Size=0;
  end;
  procedure OddFill(Mem:PByte;Size,Value:Integer);
  begin
    Value:=(Value shr 4)or(Value shl 4);
    Mem^:=(Mem^ and $F0)or(Value and $0F);
    Inc(Mem);
    if Size>1 then FillChar(Mem^,Size,Value);
    Mem^:=(Mem^ and $0F)or(Value and $F0);
  end;
var
  pb: PByte;
  x,y,z,i: Integer;
begin
  pb:=Data; x:=0; y:=0;
  while y<Bmp.AbsHeight do
  begin
    if pb^=0 then
    begin
      Inc(pb);
      z:=pb^;
      case pb^ of
        0: begin
             Inc(y);
             x:=0;
           end;
        1: Break;
        2: begin
             Inc(pb); Inc(x,pb^);
             Inc(pb); Inc(y,pb^);
           end;
        else
        begin
          Inc(pb);
          i:=(z+1)shr 1;
          if(z and 2)=2 then Inc(i);
          if((x and 1)=1)and(x+i<Bmp.Width)then
            OddMove(pb,@Bmp.Pixels8[y,x shr 1],i)
          else
            Move(pb^,Bmp.Pixels8[y,x shr 1],i);
          Inc(pb,i-1);
          Inc(x,z);
        end;
      end;
    end else
    begin
      z:=pb^;
      Inc(pb);
      if((x and 1)=1)and(x+z<Bmp.Width)then
        OddFill(@Bmp.Pixels8[y,x shr 1],z shr 1,pb^)
      else
        FillChar(Bmp.Pixels8[y,x shr 1],z shr 1,pb^);
      Inc(x,z);
    end;
    Inc(pb);
  end;
end;

procedure DecodeRLE8(Bmp:TBMPReader;Data:Pointer);
var
  pb: PByte;
  x,y,z,i,s: Integer;
begin
  pb:=Data; y:=0; x:=0;
  while y<Bmp.AbsHeight do
  begin
    if pb^=0 then
    begin
      Inc(pb);
      case pb^ of
        0: begin
             Inc(y);
             x:=0;
           end;
        1: Break;
        2: begin
             Inc(pb); Inc(x,pb^);
             Inc(pb); Inc(y,pb^);
           end;
        else
        begin
          i:=pb^;
          s:=(i+1)and(not 1);
          z:=s-1;
          Inc(pb);
          if x+s>Bmp.Width then s:=Bmp.Width-x;
          Move(pb^,Bmp.Pixels8[y,x],s);
          Inc(pb,z);
          Inc(x,i);
        end;
      end;
    end else
    begin
      i:=pb^; Inc(pb);
      if i+x>Bmp.Width then i:=Bmp.Width-x;
      FillChar(Bmp.Pixels8[y,x],i,pb^);
      Inc(x,i);
    end;
    Inc(pb);
  end;
end;

procedure FillColors(Pal:PFColorTable;i1,i2,nKeys:Integer;Keys:PLine24);
var
  pc: PFColorA;
  c1,c2: TFColor;
  i,n,cs,w1,w2,x,ii: Integer;
begin
  i:=0;
  n:=i2-i1;
  Dec(nKeys);
  ii:=(nKeys shl 16)div n;
  pc:=@Pal[i1];
  for x:=0 to n-1 do
  begin
    cs:=i shr 16;
    c1:=Keys[cs];
    if cs<nKeys then Inc(cs);
    c2:=Keys[cs];
    w1:=((not i)and $FFFF)+1;
    w2:=i and $FFFF;
    if(w1<(ii-w1))then pc.c:=c2 else
    if(w2<(ii-w2))then pc.c:=c1 else
    begin
      pc.b:=((c1.b*w1)+(c2.b*w2))shr 16;
      pc.g:=((c1.g*w1)+(c2.g*w2))shr 16;
      pc.r:=((c1.r*w1)+(c2.r*w2))shr 16;
    end;
    Inc(i,ii);
    Inc(pc);
  end;
  pc.c:=c2;
end;

function ClosestColor(Pal:PFColorTable;Max:Integer;c:TFColor):Byte;
var
  n: Byte;
  pc: PFColorA;
  i,x,d: Integer;
begin
  x:=765; n:=0;
  pc:=Pointer(Pal);
  for i:=0 to Max do
  begin
    if pc.b>c.b then d:=pc.b-c.b else d:=c.b-pc.b;
    if pc.g>c.g then Inc(d,pc.g-c.g) else Inc(d,c.g-pc.g);
    if pc.r>c.r then Inc(d,pc.r-c.r) else Inc(d,c.r-pc.r);
    if d<x then
    begin
      x:=d;
      n:=i;
    end;
    Inc(pc);
  end;
  Result:=n;
end;

function LoadHeader(Data:Pointer; var bmInfo:TBMInfo):Integer;
var
  i: Integer;
begin
  if PDWord(Ptr(Integer(Data)+14))^ = 40 then
    Move(Ptr(Integer(Data)+14)^, bmInfo, SizeOf(bmInfo))
  else
   if PDWord(Ptr(Integer(Data)+14))^ = 12 then
    with PBitmapCoreInfo(Ptr(Integer(Data)+14))^ do
    begin
      FillChar(bmInfo, SizeOf(bmInfo), 0);
      bmInfo.Header.biWidth := bmciHeader.bcWidth;
      bmInfo.Header.biHeight := bmciHeader.bcHeight;
      bmInfo.Header.biBitCount := bmciHeader.bcBitCount;
      if bmciHeader.bcBitCount <= 8 then
      for i:=0 to (1 shl bmciHeader.bcBitCount)-1 do
        bmInfo.Colors[i] := PFColorA(@bmciColors[i])^;
    end;
  Result:=PDWord(Ptr(Integer(Data)+10))^;
end;

function PackedDIB(Bmp:TBMPReader):Pointer;
var
  i: DWord;
begin
  if Bmp.Bpp <= 8 then i := 40 + ((1 shl Bmp.Bpp) shl 2) else
  if (((Bmp.Bpp = 16) or (Bmp.Bpp = 32)) and (Bmp.Compression =3 )) then i:=52 else i:=40;
  GetMem(Result, Bmp.SizeImage + i);
  Move(Bmp.Info, Result^,i);
  Move(Bmp.Bits^, Ptr(DWord(Result)+i)^, Bmp.SizeImage);
end;

function Count1(Bmp:TBMPReader):Integer;
var
  pb: PByte;
  w,c,x,y: Integer;
begin
  Result:=2;
  pb:=Pointer(Bmp.Bits); c:=pb^;
  if(c<>0)and(c<>255)then Exit;
  w:=(Bmp.Width div 8)-1;
  for y:=0 to Bmp.AbsHeight-1 do
  begin
    for x:=0 to w do
    begin
      if pb^<>c then Exit;
      Inc(pb);
    end;
    Inc(pb,Bmp.Gap);
  end;
  Result:=1;
end;

function Count4(Bmp:TBMPReader):Integer;
var
  I,J: Integer;
  pb,pc: PByte;
  x,y,w: Integer;
  Check: array[0..15]of Byte;
begin
  Result:=0;
  FillChar(Check,SizeOf(Check),0);
  pb:=Pointer(Bmp.Bits);
  w:=(Bmp.Width div 2)-1;
  for y:=0 to Bmp.AbsHeight-1 do
  begin
    for x:=0 to w do
    begin
      pc:=@Check[pb^ shr 4];
      if pc^=0 then
      begin
        Inc(Result);
        pc^:=1;
      end;
      pc:=@Check[pb^ and 15];
      if pc^=0 then
      begin
        Inc(Result);
        pc^:=1;
      end;
      if Result=16 then Exit;
      Inc(pb);
    end;
    Inc(pb,Bmp.Gap);
  end;

  x:=0; y:=0; w:=w*Bmp.AbsHeight-1;

  for I := 0 to Result - 1 do
  begin
    while check[x]=0 do inc(x);
    if x<>y then
    begin
      Bmp.Colors[y]:=Bmp.Colors[x];
      pb:=Pointer(Bmp.Bits);
      for J := 0 to w do    // Iterate
      begin
        if x=(pb^ shr 4) then pb^:=(pb^ and 15) or (y shl 4);
        if x=(pb^ and 15) then pb^:=(pb^ and $f0) or y;
        inc(pb);
      end;    // for  J
    end;
    inc(x); inc(y);
  end;    // for   I

end;

function Count8(Bmp:TBMPReader):Integer;
var
  x,y: Integer;
  I,J : Integer;
  pb: PByte;
  Check: array[Byte]of Byte;
begin
  Result:=0;
  FillChar(Check,SizeOf(Check),0);
  pb:=Pointer(Bmp.Bits);
  for y:=0 to Bmp.AbsHeight-1 do
  begin
    for x:=0 to Bmp.Width-1 do
    begin
//      pc:=@Check[pb^];
      if Check[pb^] = 0 then
      begin
        Inc(Result);
        Check[pb^] := 1;
      end;
      if Result=256 then Exit;
      Inc(pb);
    end;
    Inc(pb,Bmp.Gap);
  end;

  if (Result = 1) and (Check[0] = 0) and (Check[1] = 1) then
    begin
      Result := 2;
      exit; // bug monobrush
    end;

  j := 0;
  for I := 0 to 255 do
   if Check[i] = 0 then inc(J) else Check[i] := J;

  if J > 0 then
    begin
      pb:=Pointer(Bmp.Bits);
      for y:=0 to Bmp.AbsHeight-1 do
      begin
        for x:=0 to Bmp.Width-1 do
        begin
          if Check[pb^] > 0 then pb^ := pb^ - Check[pb^];
          Inc(pb);
        end;
        Inc(pb,Bmp.Gap);
      end;

      for I := 1 to 255 do
       if Check[i] > 0 then
         Bmp.Colors[i - Check[i]] := Bmp.Colors[i];
    end;

end;

function Count16(Bmp:TBMPReader):Integer;
var
  pw: PWord;
  pc: PByte;
  x,y: Integer;
  Check: array[Word]of Byte;
begin
  Result:=0;
  FillChar(Check,SizeOf(Check),0);
  pw:=Pointer(Bmp.Bits);
  for y:=0 to Bmp.AbsHeight-1 do
  begin
    for x:=0 to Bmp.Width-1 do
    begin
      pc:=@Check[pw^];
      if pc^=0 then
      begin
        Inc(Result);
        pc^:=1;
      end;
      Inc(pw);
    end;
    pw:=Ptr(Integer(pw)+Bmp.Gap);
  end;
end;

function Count24(Bmp:TBMPReader):Integer;
type
  PCheck =^TCheck;
  TCheck = array[Byte,Byte,0..31]of Byte;
var
  pb: PByte;
  pc: PFColor;
  Check: PCheck;
  x,y,c: Integer;
begin
  Result:=0;
  New(Check);
  FillChar(Check^,SizeOf(TCheck),0);
  pc:=Pointer(Bmp.Bits);
  for y:=0 to Bmp.AbsHeight-1 do
  begin
    for x:=0 to Bmp.Width-1 do
    begin
      pb:=@Check[pc.r,pc.g,pc.b shr 3];
      c:=1 shl(pc.b and 7);
      if(c and pb^)=0 then
      begin
        Inc(Result);
        pb^:=pb^ or c;
      end;
      Inc(pc);
    end;
    pc:=Ptr(Integer(pc)+Bmp.Gap);
  end;
  Dispose(Check);
end;

function Count32(Bmp:TBMPReader):Integer;
type
  PCheck =^TCheck;
  TCheck = array[Byte,Byte,0..31]of Byte;
var
  pb: PByte;
  pc: PFColorA;
  i,c: Integer;
  Check: PCheck;
begin
  Result:=0;
  New(Check);
  FillChar(Check^,SizeOf(TCheck),0);
  pc:=Pointer(Bmp.Bits);
  for i:=0 to (Bmp.SizeImage shr 2)-1 do
  begin
    pb:=@Check[pc.r,pc.g,pc.b shr 3];
    c:=1 shl(pc.b and 7);
    if(c and pb^)=0 then
    begin
      Inc(Result);
      pb^:=pb^ or c;
    end;
    Inc(pc);
  end;
  Dispose(Check);
end;

function CountColors(Bmp:TBMPReader):DWord;
begin
  case Bmp.Bpp of
    1:  Result:=Count1(Bmp);
    4:  Result:=Count4(Bmp);
    8:  Result:=Count8(Bmp);
    16: Result:=Count16(Bmp);
    24: Result:=Count24(Bmp);
    32: Result:=Count32(Bmp);
    else Result:=0;
  end;
end;

procedure IntToMask(Bpr,Bpg,Bpb:DWord;var RMsk,GMsk,BMsk:DWord);
begin
  BMsk:=(1 shl Bpb)-1;
  GMsk:=((1 shl(Bpb+Bpg))-1)and not BMsk;
  if(Bpr+Bpg+Bpb)=32 then RMsk:=$FFFFFFFF else RMsk:=(1 shl(Bpr+Bpb+Bpg))-1;
  RMsk:=RMsk and not(BMsk or GMsk);
end;

procedure MaskToInt(RMsk,GMsk,BMsk:DWord;var Bpr,Bpg,Bpb:DWord);
  function CountBits(i:DWord):DWord;
  asm
    bsr edx,eax
    bsf ecx,eax
    sub edx,ecx
    inc edx
    mov eax,edx
  end;
begin
  Bpb:=CountBits(BMsk);
  Bpg:=CountBits(GMsk);
  Bpr:=CountBits(RMsk);
end;

function UnpackColorTable(Table:TFPackedColorTable):TFColorTable;
var
  i: Integer;
begin
  for i:=0 to 255 do
    Result[i].c:=Table[i];
end;

function PackColorTable(Table:TFColorTable):TFPackedColorTable;
var
  i: Integer;
begin
  for i:=0 to 255 do
    Result[i]:=Table[i].c;
end;

function FRGB(r,g,b:Byte):TFColor;
begin
  Result.b:=b;
  Result.g:=g;
  Result.r:=r;
end;

function FRGBA(r,g,b,a:Byte):TFColorA;
begin
  Result.b:=b;
  Result.g:=g;
  Result.r:=r;
  Result.a:=a;
end;

function ColorToInt(c:TFColor):DWord;
begin
  Result:=c.b shl 16 or c.g shl 8 or c.r;
end;

function ColorToIntA(c:TFColorA):DWord;
begin
  Result:=c.b shl 24 or c.g shl 16 or c.r shl 8 or c.a;
end;

function IntToColor(i:DWord):TFColor;
begin
  Result.b:=i shr 16;
  Result.g:=i shr 8;
  Result.r:=i;
end;

function IntToColorA(i:DWord):TFColorA;
begin
  Result.a:=i shr 24;
  Result.b:=i shr 16;
  Result.g:=i shr 8;
  Result.r:=i;
end;

function Scale8(i,n:Integer):Integer;
begin // Result:=(i*255)div([1 shl n]-1);
  case n of
    1: if Boolean(i) then Result:=255 else Result:=0;
    2: Result:=(i shl 6)or(i shl 4)or(i shl 2)or i;
    3: Result:=(i shl 5)or(i shl 2)or(i shr 1);
    4: Result:=(i shl 4)or i;
    5: Result:=(i shl 3)or(i shr 2);
    6: Result:=(i shl 2)or(i shr 4);
    7: Result:=(i shl 1)or(i shr 6);
    else Result:=i;
  end;
end;

function Get16Bpg:Byte;
var
  c: DWord;
  hBM: HBITMAP;
  sDC,bDC: Windows.HDC;
begin
  sDC:=GetDC(0);
  bDC:=CreateCompatibleDC(sDC);
  hBM:=CreateCompatibleBitmap(sDC,1,1);
  SelectObject(bDC,hBM);
  SetPixel(bDC,0,0,RGB(0,100,0));
  c:=GetPixel(bDC,0,0);
  DeleteDC(bDC);
  DeleteObject(hBM);
  ReleaseDC(0,sDC);
  if GetGValue(c)>=100 then Result:=6 else Result:=5;
end;

initialization


finalization


end.

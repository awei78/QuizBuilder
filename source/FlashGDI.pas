//*******************************************************//
//                                                       //
//                      DelphiFlash.com                  //
//              Copyright (c) 2004 FeatherySoft, Inc.    //
//                    info@delphiflash.com               //
//                                                       //
//*******************************************************//

//  Description: GDI+ adapting for Delphi SWF SWK
//  Last update: 2 jun 2005

unit FlashGDI;

interface

uses Windows, ActiveX, Classes, FlashObjects;

procedure LoadCustomImageProcedure(sender: TFlashImage; FileName: string);

{============================== GDI+ function ==============================}
type
  TGPStatus = (Ok, GenericError, InvalidParameter, OutOfMemory, ObjectBusy, InsufficientBuffer,
    NotImplemented, Win32Error, WrongState, Aborted, FileNotFound, ValueOverflow, AccessDenied,
    UnknownImageFormat, FontFamilyNotFound, FontStyleNotFound, NotTrueTypeFont, UnsupportedGdiplusVersion,
    GdiplusNotInitialized, PropertyNotFound, PropertyNotSupported);


  TGdiplusStartupInput = packed record
    GdiplusVersion: Cardinal;
    DebugEventCallback: Pointer;
    SuppressBackgroundThread: boolean;
    SuppressExternalCodecs: boolean;
  end;
  PGdiplusStartupInput = ^TGdiplusStartupInput;

  TImageCodecInfo = packed record
    Clsid: TGUID;
    FormatID: TGUID;
    CodecName: PWideChar;
    DllName: PWideChar;
    FormatDescription: PWideChar;
    FilenameExtension: PWideChar;
    MimeType: PWideChar;
    Flags: DWORD;
    Version: DWORD;
    SigCount: DWORD;
    SigSize: DWORD;
    SigPattern: PBYTE;
    SigMask: PBYTE;
  end;
  PImageCodecInfo = ^TImageCodecInfo;
var
  token: DWord;

procedure InitGDIPlus;
function GdiplusStartup(out token: DWORD; const input: PGdiplusStartupInput;
  output: pointer): TGPStatus; stdcall;
procedure GdiplusShutdown(token: DWORD); stdcall;
function GdipLoadImageFromFileICM(filename: PWideChar; out image: Pointer): TGPStatus; stdcall;
function GdipGetImageEncodersSize(out numEncoders: DWord; out size: DWord): TGPStatus; stdcall;
function GdipGetImageEncoders(numEncoders: DWord; size: DWord; encoders: PImageCodecInfo): TGPStatus; stdcall;
function GdipSaveImageToStream(image: Pointer; stream: IStream; clsidEncoder: PGUID;
  encoderParams: Pointer): TGPStatus; stdcall;
function GdipDisposeImage(image: Pointer): TGPStatus; stdcall;

implementation

{============================== GDI+ function ==============================}
const
  GdiPlusLib = 'gdiplus.dll';

var
  DefStartup: TGdiplusStartupInput;

function GdiplusStartup; external GdiPlusLib name 'GdiplusStartup';
procedure GdiplusShutdown; external GdiPlusLib name 'GdiplusShutdown';
function GdipLoadImageFromFileICM; external GdiPlusLib name 'GdipLoadImageFromFileICM';
function GdipGetImageEncodersSize; external GdiPlusLib name 'GdipGetImageEncodersSize';
function GdipGetImageEncoders; external GdiPlusLib name 'GdipGetImageEncoders';
function GdipSaveImageToStream; external GdiPlusLib name 'GdipSaveImageToStream';
function GdipDisposeImage; external GdiPlusLib name 'GdipDisposeImage';


function GetEncoderClsid(format: string; var pClsid: TGUID): integer;
var
  num, size, il: DWord;
  ImageCodecInfo: PImageCodecInfo;
type
  ArrIMgInf = array of TImageCodecInfo;
begin
  num := 0; // number of image encoders
  size := 0; // size of the image encoder array in bytes
  result := -1;

  GdipGetImageEncodersSize(num, size);
  if (size = 0) then exit;

  GetMem(ImageCodecInfo, size);

  if GdipGetImageEncoders(num, size, ImageCodecInfo) = Ok then
    for il := 0 to num - 1 do
    begin
      if (ArrIMgInf(ImageCodecInfo)[il].MimeType = format) then
      begin
        pClsid := ArrIMgInf(ImageCodecInfo)[il].Clsid;
        result := il;
        Break;
      end;
    end;

  FreeMem(ImageCodecInfo, size);
end;

procedure InitGDIPlus;
begin
  DefStartup.GdiplusVersion := 1;
  DefStartup.DebugEventCallback := nil;
  DefStartup.SuppressBackgroundThread := False;
  DefStartup.SuppressExternalCodecs := False;

  if GdiPlusStartup(token, @DefStartup, nil) = Ok then
    LoadCustomImageProc := LoadCustomImageProcedure;
end;

{===========================================================================}

procedure LoadCustomImageProcedure(sender: TFlashImage; FileName: string);
var
  EncoderID: TGUID;
  Mem: TMemoryStream;
  Adapt: TStreamAdapter;
  SrcImage: Pointer;
begin
  Mem := TMemoryStream.Create;
  Adapt := TStreamAdapter.Create(Mem);
  SrcImage := nil;
  try
    GdipLoadImageFromFileICM(PWideChar(WideString(FileName)), SrcImage);
    if GetEncoderClsid('image/bmp', EncoderID) > -1 then
      if GdipSaveImageToStream(SrcImage, (Adapt as IStream), @EncoderID, nil) = Ok then
      begin
        Mem.Position := 0;
        Sender.LoadDataFromStream(Mem);
      end;
  finally
    if SrcImage <> nil then GdipDisposeImage(SrcImage);
    Mem.Free;
  end;
end;

initialization
  InitGDIPlus;

finalization
  GdiPlusShutdown(token);

end.
d.

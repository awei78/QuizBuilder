//*******************************************************//
//                                                       //
//                      DelphiFlash.com                  //
//         Copyright (c) 2004-2008 FeatherySoft, Inc.    //
//                    info@delphiflash.com               //
//                                                       //
//*******************************************************//

//  Description:  Tools for read sound info
//  Last update:  9 mar 2008

unit SoundReader;
interface
Uses Windows, Classes, SysUtils, mmSystem, SWFTools, MPEGAudio;

const                            { Constants for wave format identifier }
  WAVE_FORMAT_PCM = $0001;   { Windows PCM }
  WAVE_FORMAT_G723_ADPCM = $0014;   { Antex ADPCM }
  WAVE_FORMAT_ANTEX_ADPCME = $0033;   { Antex ADPCME }
  WAVE_FORMAT_G721_ADPCM = $0040;   { Antex ADPCM }
  WAVE_FORMAT_APTX = $0025;   { Audio Processing Technology }
  WAVE_FORMAT_AUDIOFILE_AF36 = $0024;   { Audiofile, Inc. }
  WAVE_FORMAT_AUDIOFILE_AF10 = $0026;   { Audiofile, Inc. }
  WAVE_FORMAT_CONTROL_RES_VQLPC = $0034;   { Control Resources Limited }
  WAVE_FORMAT_CONTROL_RES_CR10 = $0037;   { Control Resources Limited }
  WAVE_FORMAT_CREATIVE_ADPCM = $0200;   { Creative ADPCM }
  WAVE_FORMAT_DOLBY_AC2 = $0030;   { Dolby Laboratories }
  WAVE_FORMAT_DSPGROUP_TRUESPEECH = $0022;   { DSP Group, Inc }
  WAVE_FORMAT_DIGISTD = $0015;   { DSP Solutions, Inc. }
  WAVE_FORMAT_DIGIFIX = $0016;   { DSP Solutions, Inc. }
  WAVE_FORMAT_DIGIREAL = $0035;   { DSP Solutions, Inc. }
  WAVE_FORMAT_DIGIADPCM = $0036;   { DSP Solutions ADPCM }
  WAVE_FORMAT_ECHOSC1 = $0023;   { Echo Speech Corporation }
  WAVE_FORMAT_FM_TOWNS_SND = $0300;   { Fujitsu Corp. }
  WAVE_FORMAT_IBM_CVSD = $0005;   { IBM Corporation }
  WAVE_FORMAT_OLIGSM = $1000;   { Ing C. Olivetti & C., S.p.A. }
  WAVE_FORMAT_OLIADPCM = $1001;   { Ing C. Olivetti & C., S.p.A. }
  WAVE_FORMAT_OLICELP = $1002;   { Ing C. Olivetti & C., S.p.A. }
  WAVE_FORMAT_OLISBC = $1003;   { Ing C. Olivetti & C., S.p.A. }
  WAVE_FORMAT_OLIOPR = $1004;   { Ing C. Olivetti & C., S.p.A. }
  WAVE_FORMAT_IMA_ADPCM = $0011;   { Intel ADPCM }
  WAVE_FORMAT_DVI_ADPCM = $0011;   { Intel ADPCM }
  WAVE_FORMAT_UNKNOWN = $0000;
  WAVE_FORMAT_ADPCM = $0002;   { Microsoft ADPCM }
  WAVE_FORMAT_ALAW = $0006;   { Microsoft Corporation }
  WAVE_FORMAT_MULAW = $0007;   { Microsoft Corporation }
  WAVE_FORMAT_GSM610 = $0031;   { Microsoft Corporation }
  WAVE_FORMAT_MPEG = $0050;   { Microsoft Corporation }
  WAVE_FORMAT_MPEG_L3 = $0055;
  WAVE_FORMAT_NMS_VBXADPCM = $0038;   { Natural MicroSystems ADPCM }
  WAVE_FORMAT_OKI_ADPCM = $0010;   { OKI ADPCM }
  WAVE_FORMAT_SIERRA_ADPCM = $0013;   { Sierra ADPCM }
  WAVE_FORMAT_SONARC = $0021;   { Speech Compression }
  WAVE_FORMAT_MEDIASPACE_ADPCM = $0012;   { Videologic ADPCM }
  WAVE_FORMAT_YAMAHA_ADPCM = $0020;   { Yamaha ADPCM }

  WAVE_FORMAT_MP3 = $0150;

  MSADPCM_NUM_COEF = 7;

type
  TADPCMCoef = packed record
    Coef1, Coef2: SmallInt;
  end;
  TADPCMCoefSet = Array[0..MSADPCM_NUM_COEF-1] of TADPCMCoef;
  PADPCMCoefSet = ^TADPCMCoefSet;

type
 TChunkInfo= record
  Start, Len: longint;
 end;

TWaveHeader = record
  WaveFormat: Word;         { format type }
  Channels: Word;          { number of channels (i.e. mono, stereo, etc.) }
  SamplesPerSec: DWORD;  { sample rate }
  BitsPerSample: Word;   { number of bits per sample of mono data }
  Samples : longint;
end;

TWaveFormat_ADPCM = packed record
  wFormatTag: Word;         { format type }
  nChannels: Word;          { number of channels (i.e. mono, stereo,
                              etc.) }
  nSamplesPerSec: Longint;  { sample rate }
  nAvgBytesPerSec: Longint; { for buffer estimation }
  nBlockAlign: Word;        { block size of data }
  { --- Addition for TWaveFormat --- }
  wBitsPerSample: Word;
  cbSize: Word;  { SizeOf(wSamplesPerBlock..Predictors. For PCM
                   factorial }
  { --- Additional data for ADPCM ------- }
  wSamplesPerBlock: SmallInt;
  wNumCoef: SmallInt;  { const 7 }
  CoefSet: TADPCMCoefSet; { Also for Mono Coef1,Coef2 }
end;

TMP3Info = record
  SamplesPerFrame: word;   // samples per frame
  FrameLength: word; // byte per frame
  FrameCount: word;
  BitsPerSec: word;
end;

TWaveReader = class (TObject)
private
  FMP3: TMPEGAudio;
  FDuration: double;
  FWaveData: TStream;
  function GetMPEGAudio: TMPEGAudio;
  procedure SetMPEGAudio(const Value: TMPEGAudio);
    procedure SetWaveData(const Value: TStream);
protected
  FFileName: string;
  ADInfo: TWaveFormat_ADPCM;
  UnCompressBuf: TMemoryStream;
  ReadSeek, SkipSample: longint;
  procedure ReadFormatInfo(H: THandle);
  procedure CheckMP3(nativ: boolean);
  procedure CheckMP3Stream(Src: TStream; nativ: boolean);
  property MP3: TMPEGAudio read GetMPEGAudio write SetMPEGAudio;
public
  WaveHeader: TWaveHeader;
  FormatInfo, DataInfo: TChunkInfo;
  MP3Info: TMP3Info;
  constructor Create (fn: string);
  constructor CreateFromStream(Src: TMemoryStream; isMP3: boolean);
  destructor Destroy; override;
  function WriteMP3Block(Dest: TBitsEngine; Start: longint; Count: word; loop: boolean): longint; //return new frame number
  procedure WriteBlock(Dest: TBitsEngine; SamplesCount: longint; bits: byte; loop: boolean);
  function WriteReCompress(Dest: TBitsEngine; Src: TStream; Size: longint; bits: byte; isContine: boolean): boolean;
  procedure WriteToStream(Dest: TBitsEngine; bits: byte);
  procedure WriteUncompressBlock(Dest: TBitsEngine; Size: longint; bits: byte; loop: boolean);
  property Duration: double read FDuration write FDuration; // sec
  property WaveData: TStream read FWaveData write SetWaveData;
end;


Function isSupportSoundFormat(fn: string):boolean;
procedure WriteCompressWave(dest: TBitsEngine; src: TStream; Size: longint; bits: byte; src16, stereo,
                            continue, single: boolean);

const
  SndRates: array [0..3] of word = (5512, 11025, 22050, 44100);

  { Table for samples per frame}
  MPEG_SAMPLES_FRAME: array [0..3, 0..2] of Word =
   ((576, 1152, 384),                                   { For MPEG 2.5 }
    (0, 0, 0),                                          { Reserved }
    (576, 1152, 384),                                   { For MPEG 2 }
    (1152, 1152, 384));                                 { For MPEG 1 }

//         384, 1152, 1152}, /* MPEG-1   */
//         384, 1152, 576} /* MPEG-2(.5) */


(*
Sample Rate  |  48000   24000   12000
             |  44100   22050   11025
             |  32000   16000    8000
-------------+-----------------------
Layer I      |    384     384     384
Layer II     |   1152    1152    1152
Layer III    |   1152     576     576
*)


implementation

//Uses MPEGaudio{, MPGTools};

const
  IndexTable2: array[0..1] of integer = (-1, 2);
  IndexTable3: array[0..3] of integer = (-1, -1, 2, 4);
  IndexTable4: array[0..7] of integer = (-1, -1, -1, -1, 2, 4, 6, 8);
  IndexTable5: array[0..15] of integer =(-1, -1, -1, -1, -1, -1, -1, -1, 1, 2, 4, 6, 8, 10, 13, 16);

  StepSizeTable: array[0..88] of Integer = (
    7, 8, 9, 10, 11, 12, 13, 14, 16, 17,
    19, 21, 23, 25, 28, 31, 34, 37, 41, 45,
    50, 55, 60, 66, 73, 80, 88, 97, 107, 118,
    130, 143, 157, 173, 190, 209, 230, 253, 279, 307,
    337, 371, 408, 449, 494, 544, 598, 658, 724, 796,
    876, 963, 1060, 1166, 1282, 1411, 1552, 1707, 1878, 2066,
    2272, 2499, 2749, 3024, 3327, 3660, 4026, 4428, 4871, 5358,
    5894, 6484, 7132, 7845, 8630, 9493, 10442, 11487, 12635, 13899,
    15289, 16818, 18500, 20350, 22385, 24623, 27086, 29794, 32767
  );

  MSADPCM_adapt : array[0..15] of Word = (230, 230, 230, 230,
                                              307, 409, 512, 614,
                                              768, 614, 512, 409,
                                              307, 230, 230, 230);

type
  TWaveFormat_MPEG = packed record
    wf: tWAVEFORMATEX;
    fwHeadLayer: WORD;
    dwHeadBitrate: DWORD;
    fwHeadMode: WORD ;
    fwHeadModeExt: WORD ;
    wHeadEmphasis: WORD ;
    fwHeadFlags: WORD ;
    dwPTSLow: DWORD ;
    dwPTSHigh: DWORD ;
   end;

function isSupportSoundFormat(fn: string):boolean;
 var  f_ext: string[5];
      MP3: TMPEGAudio;
      FS: tFileStream;
      W: word;
begin
  Result := false;
  f_ext := UpperCase(ExtractfileExt(fn));
//  f_ext := '.MP3';
  if f_ext = '.MP3' then
    begin
      MP3:= TMPEGAudio.Create;
      Result := MP3.isMP3File(fn);
//      MP3.Free;
    end else
  if f_ext = '.WAV'  then
  begin
    FS:=tFileStream.Create(fn, fmOpenRead + fmShareDenyWrite);
    FS.Position := 20;
    FS.Read(W, 2);
    FS.Free;
    case W of
      WAVE_FORMAT_PCM,
      WAVE_FORMAT_ADPCM: Result := true;
      WAVE_FORMAT_MPEG,
      WAVE_FORMAT_MPEG_L3:
        begin
          MP3:= TMPEGAudio.Create;
          MP3.ReadFromFile(fn);
          Result := MP3.FirstFrame.Found;
//      MP3.FileName := fn;
//      MP3.IsValid;
//          MP3.Free;
        end;
     else Result := false;
    end;
  end;
end;

constructor TWaveReader.Create (fn: string);
var
  H: THandle;
  f_ext: string[5];
begin
 FFileName := fn;
 if FFileName = '' then Exit;

 f_ext := UpperCase(ExtractfileExt(fn));

 if f_ext = '.MP3' then
   begin
    WaveData := TFileStream.Create(FN, fmOpenRead + fmShareDenyWrite);
    CheckMP3Stream(WaveData, true);
   end else
 if f_ext = '.WAV'  then
 begin
   H := mmioOpen(PChar(fn), nil, MMIO_READ);
   if H > 0 then
     begin
       ReadFormatInfo(H);
       mmioClose(H, 0);
       if WaveHeader.WaveFormat in [WAVE_FORMAT_PCM, WAVE_FORMAT_ADPCM] then
         begin
           ReadSeek := 0;
           SkipSample := 0;
           UnCompressBuf := TMemoryStream.Create;
           WaveData := TFileStream.Create(FN, fmOpenRead + fmShareDenyWrite);
           WaveData.Position := DataInfo.Start;
         end;
     end;
 end;
end;

constructor TWaveReader.CreateFromStream(Src: TMemoryStream; isMP3: boolean);
 var H: THandle;
     Info: TMMIOInfo;
begin
  if isMP3 then
  begin
    CheckMP3Stream(Src, true);
  end else
  begin
    FillChar(Info, SizeOf(Info), 0);
    Info.pchBuffer := Src.Memory;
    Info.cchBuffer := Src.Size;
    info.fccIOProc := FOURCC_MEM;
    H := mmioOpen(nil, @Info, MMIO_READWRITE);
    if H > 0 then
      begin
        ReadFormatInfo(H);
        mmioClose(H, 0);
        if WaveHeader.WaveFormat in [WAVE_FORMAT_PCM, WAVE_FORMAT_ADPCM] then
         begin
           ReadSeek := 0;
           SkipSample := 0;
           UnCompressBuf := TMemoryStream.Create;
           WaveData := Src;
           WaveData.Position := DataInfo.Start;
         end;
      end;
  end;
end;

procedure TWaveReader.ReadFormatInfo(H: THandle);
var
  mmckinfoParent: TMMCKInfo;
  mmckinfoSubchunk: TMMCKInfo;
  Buff: array [0..255] of byte;

  VF1: TPCMWaveFormat absolute Buff;
  VF2: TWaveFormat_ADPCM absolute Buff;
  VF4: TWaveFormatEx absolute Buff;

begin
  mmckinfoParent.fccType := mmioStringToFOURCC('WAVE', MMIO_TOUPPER);
  if (mmioDescend(H, PMMCKINFO(@mmckinfoParent), nil, MMIO_FINDRIFF) <> 0) then Exit;

  mmckinfoSubchunk.ckid := mmioStringToFOURCC('fmt ', 0);
  mmioDescend(H, @mmckinfoSubchunk, @mmckinfoParent, MMIO_FINDCHUNK);
//    WaveHeader.Fixed1 := mmckinfoSubchunk.cksize;

  FormatInfo.Start := mmckinfoSubchunk.dwDataOffset;
  FormatInfo.Len := mmckinfoSubchunk.cksize;

  mmioAscend(H, @mmckinfoSubchunk, 0);

  mmckinfoSubchunk.ckid := mmioStringToFOURCC('data', 0);
  mmioDescend(H, @mmckinfoSubchunk, @mmckinfoParent, MMIO_FINDCHUNK);

  DataInfo.Start := mmckinfoSubchunk.dwDataOffset;
  DataInfo.Len := mmckinfoSubchunk.cksize;

  mmioSeek(H, FormatInfo.Start, 0);
  mmioRead(H, @Buff, FormatInfo.Len);

  Move(Buff, WaveHeader.WaveFormat, 2);

  case WaveHeader.WaveFormat of
   WAVE_FORMAT_PCM:
       begin
        WaveHeader.Channels := VF1.wf.nChannels;
        WaveHeader.SamplesPerSec := VF1.wf.nSamplesPerSec;
        WaveHeader.BitsPerSample := VF1.wBitsPerSample;
        WaveHeader.Samples := (DataInfo.Len * 8) div (WaveHeader.BitsPerSample * WaveHeader.Channels);
       end;
   WAVE_FORMAT_ADPCM:
       begin
        ADInfo := VF2;
        WaveHeader.Channels := VF2.nChannels;
        WaveHeader.SamplesPerSec := VF2.nSamplesPerSec;
        WaveHeader.BitsPerSample := VF2.wBitsPerSample;
        WaveHeader.Samples := Trunc(VF2.wSamplesPerBlock * DataInfo.Len / VF2.nBlockAlign) - 2;
       end;
   WAVE_FORMAT_MPEG,
   WAVE_FORMAT_MPEG_L3:
       begin
         if FFileName <> '' then CheckMP3(false);
       end;
   else
    begin
        WaveHeader.Channels := VF4.nChannels;
        WaveHeader.SamplesPerSec := VF4.nSamplesPerSec;
        WaveHeader.BitsPerSample := VF4.wBitsPerSample;
        WaveHeader.Samples := (DataInfo.Len * 8) div (WaveHeader.BitsPerSample * WaveHeader.Channels);
    end;
  end;
  if Duration = 0 then
    Duration := WaveHeader.Samples / WaveHeader.SamplesPerSec;
end;

procedure TWaveReader.SetMPEGAudio(const Value: TMPEGAudio);
begin
  if Assigned(FMP3) then FMP3.Free;
  FMP3 := Value;
end;

procedure TWaveReader.SetWaveData(const Value: TStream);
begin
  if Assigned(FWaveData) then FWaveData.Free;
  FWaveData := Value;
end;

destructor TWaveReader.Destroy;
begin
//  mmioClose(FHandle, 0);
  if Assigned(FMP3) then FMP3.Free;
  if Assigned(FWaveData) and (FWaveData is TFileStream) then FWaveData.Free;
  if Assigned(UnCompressBuf) then UnCompressBuf.Free;
  inherited;
end;

function TWaveReader.GetMPEGAudio: TMPEGAudio;
begin
  if not Assigned(FMP3) then FMP3 := TMPEGAudio.Create;
  result := FMP3;
end;

procedure TWaveReader.CheckMP3(nativ:boolean);
 var
   F: TFileStream;
begin
   F := TFileStream.Create(FFileName, fmOpenRead + fmShareDenyWrite);
   CheckMP3Stream(F, nativ);
   F.Free;
end;

procedure TWaveReader.CheckMP3Stream(Src: TStream; nativ: boolean);
begin
 MP3 := TMPEGAudio.Create;
 MP3.ReadFromStream(Src);
 if Nativ then
   begin
    WaveHeader.WaveFormat := WAVE_FORMAT_MP3;
    DataInfo.Start := MP3.FirstFrame.Position + MP3.ID3v2.Size;
    DataInfo.Len := MP3.FileLength - DataInfo.Start - MP3.ID3v1.Size;
   end;
 WaveHeader.Channels := byte(not (MP3.FirstFrame.ModeID = MPEG_CM_MONO)) + 1;
 WaveHeader.SamplesPerSec := MP3.SampleRate;
 WaveHeader.BitsPerSample := 16;
 WaveHeader.Samples := Round(MP3.SampleRate * MP3.Duration);
 MP3Info.FrameLength := MP3.FirstFrame.Size;
 MP3Info.FrameCount := MP3.FrameCount;
 MP3Info.BitsPerSec := MP3.BitRate;
 MP3Info.SamplesPerFrame := MPEG_SAMPLES_FRAME[MP3.FirstFrame.VersionID, MP3.FirstFrame.SampleRateID];
 if (MP3Info.FrameLength * MP3Info.FrameCount ) > MP3.FileLength then
   MP3Info.FrameCount := MP3.FileLength div MP3Info.FrameLength;
 Duration := MP3.Duration;
// MP3.Free;
end;

procedure CheckSmallInt(var value: longint);
begin
  if value > 32767 then value :=  32767 else
  if value < -32768 then value := -32768;
end;

{$IFDEF VER130}
type 
  TIntegerArray = array of integer;
  PIntegerArray = ^TIntegerArray;
{$ENDIF}

procedure WriteCompressWave(dest: TBitsEngine; src: TStream; Size: longint; bits: byte; src16, stereo,
                            continue, single: boolean);
  var sign, step, delta, vpdiff: integer;
      PArray: PIntegerArray;
      bSize, iDiff, k: longint;
      nSamples: longint;
      iChn, cChn: byte;
      ValPred, Val: array [0..1] of longint;
      Index: array [0..1] of smallint;

 function ReadSample: SmallInt;
   var W: word;
       B: Byte;
 begin
   if src16 then
     begin
       src.Read(W, 2);
       Result := smallint(W);
       Dec(bSize, 2);
     end else
     begin
       src.Read(B, 1);
       Result := smallint((B - 128) shl 8);
       Dec(bSize);
     end;
 end;

begin
  if not continue then
    dest.WriteBits(bits - 2, 2);
  case bits of
    2: PArray := @IndexTable2;
    3: PArray := @IndexTable3;
    4: PArray := @IndexTable4;
    5: PArray := @IndexTable5;
  end;
  nSamples := 0;
  cChn := 1 + byte(Stereo);
  bSize := Size;

    while bSize > 0 do
    begin
      if (nSamples and $fff) = 0 then
      begin
        ValPred[0] := ReadSample;
        if Stereo then ValPred[1] := ReadSample;
        Val[0] := ReadSample;
        if Stereo then Val[1] := ReadSample;

        for iChn := 0 to cChn - 1 do
        begin
          dest.WriteBits(ValPred[iChn], 16);
          iDiff := abs(Val[iChn] - ValPred[iChn]);
          Index[iChn] := 0;
          while ((Index[iChn] < 63) and (StepSizeTable[Index[iChn]] < iDiff)) do Inc(Index[iChn]);
          dest.WriteBits(Index[iChn], 6);
        end;

        ValPred[0] := Val[0];
        if Stereo then ValPred[1] := Val[1];
      end else
      begin

        if ((nSamples-1) and $fff) > 0 then
          begin
            Val[0] := ReadSample;
            if Stereo then Val[1] := ReadSample;
          end;

        for iChn := 0 to cChn - 1 do
        begin
          iDiff := Val[iChn] - ValPred[iChn];
          if (iDiff < 0) then
          begin
            sign := 1 shl (bits - 1);
            iDiff := -iDiff;
          end
          else sign := 0;

          delta := 0;
          step := StepSizeTable[Index[iChn]];
          VPDiff := step shr (bits-1);
          k := bits - 2;
          while k >= 0 do
          begin
            if (iDiff >= step) then
            begin
              delta := delta or (1 shl k);
              VPDiff := VPDiff + step;
              iDiff := iDiff - step;
            end;
            dec(k);
            step := step shr 1;
          end;


          if (sign = 0)
            then Inc(ValPred[iChn], vpdiff)
            else Dec(ValPred[iChn], vpdiff);

          CheckSmallInt(ValPred[iChn]);

          inc(Index[iChn], PArray^[delta]);
          if (Index[iChn] < 0 ) then Index[iChn] := 0
            else if (index[iChn] > 88) then index[iChn] := 88;
          delta := delta or sign;

          dest.WriteBits(delta, bits);
        end;
      end;
      inc(nSamples);
    end;

  if single then dest.FlushLastByte();
end;

procedure TWaveReader.WriteBlock(Dest: TBitsEngine; SamplesCount: Integer; bits: byte; loop: boolean);
var
  Decoded, dSize, UnSize, il, Unclaimed, SavedSamples: longint;
  buffer: TMemoryStream;
  isContine, NoLastBlock: boolean;
  sBits, Zero: Byte;
begin
  if (bits = 0) or (bits > ADInfo.wBitsPerSample)
    then sBits := ADInfo.wBitsPerSample
    else sBits := bits;

  buffer := TMemoryStream.Create;
  buffer.SetSize(ADInfo.nBlockAlign);

  Decoded := SkipSample;
  SavedSamples := 0;
  isContine := false;
  NoLastBlock := true;

  while (Decoded <= SamplesCount) and (ReadSeek < (DataInfo.Start + DataInfo.Len)) do
  begin
    if (ReadSeek + ADInfo.nBlockAlign) > (DataInfo.Start + DataInfo.Len) then
      begin
        dSize := (DataInfo.Len + DataInfo.Start) - ReadSeek;
        inc(Decoded, trunc(dSize * ADInfo.wSamplesPerBlock / ADInfo.nBlockAlign));
        NoLastBlock := false;
        // last block contain bad saplases :|
      end else
      begin
        dSize := ADInfo.nBlockAlign;
        inc(Decoded, ADInfo.wSamplesPerBlock);
      end;

    if NoLastBlock then
      begin
        buffer.Position := 0;
        //mmioRead(FHandle, buffer.Memory, dSize);
        buffer.CopyFrom(WaveData, dSize);
        buffer.Position := 0;

        if WriteReCompress(Dest, buffer, dSize, sBits, isContine) then
          begin
            inc(SavedSamples, $1000);
            isContine := true;
          end;
      end;
    inc(ReadSeek, dSize);
  end;

  Unclaimed := 0;
  UnSize := 0;
  if (UnCompressBuf.Position > 0) or (not isContine) then
   begin
     UnSize := (SamplesCount - SavedSamples) * 2 * ADInfo.nChannels {- 2 - 2 * (ADInfo.nChannels -1)};
     Unclaimed := UnCompressBuf.Position - UnSize;
     if Unclaimed < 0 then
       begin
         if loop then
         begin
           ReadSeek := DataInfo.Start;
           WaveData.Seek(ReadSeek, 0);
           //mmioSeek(FHandle, ReadSeek, 0);

           SkipSample := UnCompressBuf.Position div (2 * ADInfo.nChannels);
           WriteBlock(Dest, SamplesCount - SkipSample, bits, loop)
         end else
         begin
           Zero := 0;
           for il := 1 to -Unclaimed do UnCompressBuf.Write(Zero, 1);
         end;
       end;

     if (Unclaimed >= 0) or ((Unclaimed < 0) and (not loop)) then
     begin
       UnCompressBuf.Position := 0;
       WriteCompressWave(Dest, UnCompressBuf, UnSize, sBits, true, ADInfo.nChannels=2, isContine, true);
     end;
   end;

  if Unclaimed > 0 then
    begin
      SkipSample := Decoded - SamplesCount;
      buffer.SetSize(Unclaimed);
      buffer.Position := 0;
      UnCompressBuf.Position := UnSize;
      buffer.CopyFrom(UnCompressBuf, Unclaimed);
      UnCompressBuf.LoadFromStream(buffer);
    end else
  if not loop then
    begin
      SkipSample := 0;
      UnCompressBuf.Position := 0;
    end;

  buffer.Free;
end;

function TWaveReader.WriteMP3Block(Dest: TBitsEngine; Start: longint; Count: word; loop: boolean): longint;
  var il, i0, delta: word;
begin
  Result := Start;
  il := 0;
  while il < Count do
  begin
    if Result < MP3.FrameCount then
    begin
      if MP3.FrameInfo[Result].isSound then
      begin
        WaveData.Position := MP3.FrameInfo[Result].Position;
        with MP3.FrameInfo[Result] do
        if (Position + Size) < WaveData.Size
          then
            Dest.BitsStream.CopyFrom(WaveData, Size)
          else
          begin
            Dest.BitsStream.CopyFrom(WaveData, WaveData.Size - Position);
            delta := Size - (WaveData.Size - Position);
            for i0 := 1 to delta do Dest.WriteByte(0);
          end;
        inc(il);
      end;
      Inc(Result);
    end else
    begin
      if loop then Result := 0
        else
        begin
          delta := (Count - il) * MP3Info.FrameLength;
          for i0 := 1 to delta do Dest.WriteByte(0);
          il := Count;
        end;
    end;

  end;

end;

function TWaveReader.WriteReCompress(Dest: TBitsEngine; Src: TStream; Size: Integer;
            bits: byte; isContine: boolean): boolean;
var
  aiSamp1, aiSamp2,
  aiCoef1, aiCoef2,
  aiDelta: array[0..1] of Smallint;
  iInput, iNextInput: Smallint;
  iChn, nChn, n: byte;
  be: TBitsEngine;
  isFirst: boolean;
  il, UnSize, decSample, sSize: longint;
begin
  Result := false;
  be := TBitsEngine.Create(Src);
  UnSize := $2000 * ADInfo.nChannels;
  nChn := ADInfo.nChannels;
  if Size = 0 then sSize := Src.Size else sSize := Size;
  
  for iChn := 0 to nChn - 1 do
  begin
    n := be.ReadByte;
    aiCoef1[iChn] := ADInfo.CoefSet[n].Coef1;
    aiCoef2[iChn] := ADInfo.CoefSet[n].Coef2;
  end;

  for iChn := 0 to nChn - 1 do aiDelta[iChn]:= smallint(be.ReadWord);
  for iChn := 0 to nChn - 1 do aiSamp1[iChn]:= smallint(be.ReadWord);
  for iChn := 0 to nChn - 1 do aiSamp2[iChn]:= smallint(be.ReadWord);

  for iChn := 0 to nChn - 1 do UnCompressBuf.Write(aiSamp2[iChn], 2);
  for iChn := 0 to nChn - 1 do UnCompressBuf.Write(aiSamp1[iChn], 2);

  isFirst := True;
  il := 1;
  while il <= (ADInfo.wSamplesPerBlock - 2) do
    begin
      inc(il);
      for iChn := 0 to nChn - 1 do
      begin
        if isFirst then
          begin
            if (Src.Size > Src.Position) then
            begin
              iNextInput := be.ReadByte;
//              iInput := iNextInput shr 4;
//              iNextInput := byte(iNextInput) shl 12 shr 12;
              asm
                mov     ax, iNextInput
                cbw
                sar     ax,4
                mov     iInput, ax
                mov     ax, iNextInput
                sal     ax, 12
                sar     ax, 12
                mov     iNextInput, ax
              end;
            end;

            isFirst := False;
          end else
          begin
            iInput := iNextInput;
            isFirst := True;
          end;


        decSample := aiDelta[iChn];
        aiDelta[iChn] := (decSample * MSADPCM_adapt[iInput and $0f]) div 256;
        if aiDelta[iChn] < 16 then aiDelta[iChn] := 16;
        decSample := (decSample * iInput) +
                       ((LongInt(aiSamp1[iChn])*aiCoef1[iChn])+
                        (LongInt(aiSamp2[iChn])*aiCoef2[iChn])) div 256;

        CheckSmallInt(decSample);
        aiSamp2[iChn] := aiSamp1[iChn];
        aiSamp1[iChn] := decSample;

        UnCompressBuf.Write(smallint(decSample), 2);

        if (UnCompressBuf.Position = UnSize) then
          begin
            UnCompressBuf.Position := 0;
            WriteCompressWave(Dest, UnCompressBuf, UnSize, bits, true, ADInfo.nChannels=2,
               isContine, false);
            isContine := true;
            Result := true;
            UnCompressBuf.Position := 0;
          end;

      end;
      if (Src.Position = sSize) and isFirst then
         il := ADInfo.wSamplesPerBlock; // for break
    end;
  be.Free;
end;

procedure TWaveReader.WriteToStream(Dest: TBitsEngine; bits: byte);
var
  buffer: TMemoryStream;
  bSize, dSize, UnSize: longint;
  sBits: byte;
  isContine: boolean;
begin
  if (bits = 0) or (bits > ADInfo.wBitsPerSample)
    then sBits := ADInfo.wBitsPerSample
    else sBits := bits;

  buffer := TMemoryStream.Create;
  buffer.SetSize(ADInfo.nBlockAlign);

  UnSize := $2000 * ADInfo.nChannels;
  UnCompressBuf.SetSize(UnSize);

  bSize := DataInfo.Len;

  isContine := false;
  while bSize > 0 do
  begin
    if bSize >= ADInfo.nBlockAlign then dSize := ADInfo.nBlockAlign
      else
      begin
        dSize := bSize;
        buffer.SetSize(dSize);
      end;

    buffer.Position := 0;
//    mmioRead(FHandle, buffer.Memory, dSize);
    buffer.CopyFrom(WaveData, dSize);
    buffer.Position := 0;
     
    isContine := WriteReCompress(Dest, buffer, 0{dSize}, sBits, isContine) or isContine;
    Dec(bSize, dSize);
  end;

  if UnCompressBuf.Position > 0 then
   begin
     UnSize := UnCompressBuf.Position;
     UnCompressBuf.Position := 0;
     WriteCompressWave(Dest, UnCompressBuf, UnSize, sBits, true, ADInfo.nChannels=2, isContine, true);
   end;

  buffer.Free;
end;

procedure TWaveReader.WriteUncompressBlock;
 var sSize, il: longint;
     Zero: byte; 
begin
  sSize := 0;
  while sSize < Size do
  begin
    if (WaveData.Position + Size) > (DataInfo.Start + DataInfo.Len) then
    begin
      sSize := (DataInfo.Start + DataInfo.Len) - WaveData.Position;
    end else
    begin
      sSize := Size;
    end;

    if bits = 0
      then Dest.BitsStream.CopyFrom(WaveData, sSize)
      else
      begin
        if sSize = Size then
          WriteCompressWave(Dest, WaveData, Size, bits, WaveHeader.BitsPerSample = 16,
                            WaveHeader.Channels = 2, false, true);
      end;

    if sSize < Size then
      begin
        if bits = 0 then
        begin
          if Loop then
            begin
              WaveData.Position := DataInfo.Start;
              Dest.BitsStream.CopyFrom(WaveData, Size - sSize);
            end else
            begin
              for il := 1 to Size - sSize do
                Dest.WriteByte(0);
            end;
        end else
        begin
          UnCompressBuf.SetSize(Size);
          UnCompressBuf.Position := 0;
          UnCompressBuf.CopyFrom(WaveData, sSize);
          if loop then
            begin
              WaveData.Position := DataInfo.Start;
              UnCompressBuf.CopyFrom(WaveData, Size - sSize);
            end else
            begin
              for il := 1 to Size - sSize do
                UnCompressBuf.Write(Zero, 1);
            end;
          UnCompressBuf.Position := 0;
          WriteCompressWave(Dest, UnCompressBuf, UnCompressBuf.Size, bits, WaveHeader.BitsPerSample = 16,
                            WaveHeader.Channels = 2, false, true);
        end;
        sSize := Size;
      end;
  end;
end;

end.

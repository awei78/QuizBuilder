//*******************************************************//
//                                                       //
//                      DelphiFlash.com                  //
//         Copyright (c) 2004-2008 FeatherySoft, Inc.    //
//                    info@delphiflash.com               //
//                                                       //
//*******************************************************//

//  Description: tool functions for reading FLV files
//  Last update:  14 feb 2008

unit FLV;
interface
 Uses Windows, Classes, Contnrs,
{$IFNDEF VER130}
  Types,
{$ENDIF}
 SWFTools;

 type
  TVHeader = record
    CodecInfo: Byte;
    FrameCount: Word;
    KeyFrame: boolean;
    XDim: Word;
    YDim: Word;
  end;

  TSHeader = class(TObject)
  private
    SoundInfo: byte;
    function GetIs16bit: boolean;
    function GetSoundRate: byte;
    procedure SetSoundFormat(const Value: byte);
    function GetIsStereo: boolean;
    function GetSoundFormat: byte;
  public
    MP3Frame: Cardinal;
    property Is16Bit: boolean read  GetIs16bit;
    property IsStereo: boolean read GetIsStereo;
    property SoundFormat: byte read GetSoundFormat write SetSoundFormat;
    property SoundRate: byte read GetSoundRate;
  end;

  TVFrame = class (TObject)
  private
    FLen: LongInt;
    FStart: LongInt;
    FInVideoPos: longint;
    procedure SetLen(const Value: LongInt);
  public
    property Len: LongInt read FLen write SetLen;
    property Start: LongInt read FStart write FStart;
    property InVideoPos: longint read FInVideoPos;
  end;

  TFLVDataType =
      (dtNumber, dtBoolean, dtString, dtObject, dtMovieClip, dtNull, dtUndefined,
       dtReference, dtECMAArray, dtStrictArray, dtDate, dtLongString);
  TFLVDataInfoType =
      (fdiDuration, fdiLastTimeStamp, fdiLastKeyFrameTimeStamp, fdiWidth, fdiHeight,
       fdiVideoDataRate, fdiAudioDataRate, fdiFrameRate, fdiCreationDate,
       fdiFileSize, fdiVideoSize, fdiAudioSize, fdiDatasize, fdiMetaDataCreator,
       fdiMetaDataDate, fdiVideoCodecID, fdiAudioCodecID, fdiAudioDelay,
       fdiCanSeekToEnd, fdiKeyFrames);

  TFLVCustomData = class (TObject)
  private
    FName: ansistring;
    FDataType: TFLVDataType;
  public
    function AsInteger: integer; virtual; abstract;
    procedure ReadFromStream(be: TBitsEngine); virtual; 
    property VariableName: ansistring read FName write FName;
    property DataType: TFLVDataType read FDataType write FDataType;
  end;

  TFLVDataNumber = class (TFLVCustomData)
  private
    FValue: double;
    procedure SetValue(const Val: double);
  public
    constructor Create;
    function AsInteger: integer; override;
    procedure ReadFromStream(be: TBitsEngine); override;
    property Value: double read FValue write SetValue;
  end;

  TFLVDataBoolean = class (TFLVCustomData)
  private
    FValue: boolean;
    procedure SetValue(const Val: boolean);
  public
    constructor Create;
    function AsInteger: integer; override;
    procedure ReadFromStream(be: TBitsEngine); override;
    property Value: boolean read FValue write SetValue;
  end;    

  TFLVDataWord = class (TFLVCustomData)
  private
    FValue: Word;
    procedure SetValue(const Val: Word);
  public
    constructor Create;
    function AsInteger: integer; override;
    procedure ReadFromStream(be: TBitsEngine); override;
    property Value: Word read FValue write SetValue;  
  end;    
  
  TFLVDataDate = class (TFLVCustomData)
  private
    FValue: TDateTime;
    FLocalDateTimeOffset: single;
    procedure SetValue(const Val: TDateTime);
  public
    constructor Create;
    procedure ReadFromStream(be: TBitsEngine); override;
    property Value: TDateTime read FValue write SetValue;  
    property LocalDateTimeOffset: single read FLocalDateTimeOffset write FLocalDateTimeOffset;
  end;    
  
  TFLVDataString = class (TFLVCustomData)
  private
    FValue: ansistring;
    procedure SetString(const Val: ansistring);
  public
    constructor Create;
    function AsInteger: integer; override;
    procedure ReadFromStream(be: TBitsEngine); override;
    property Value: ansistring read FValue write SetString;
  end;

  TFLVDataECMAArray = class (TFLVCustomData)
  private
    FList: TObjectList;
    StartPosition, SectionSize: Longint;
    function GetFLVCustomData(ind: integer): TFLVCustomData;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure ReadFromStream(be: TBitsEngine); override;
    property Variable[index: integer]: TFLVCustomData read GetFLVCustomData;
  end;

  TFLVKeyFramesObjectData = class (TFLVCustomData)
  private
    FTimes: Pointer;
    FPosition: Pointer;
    FKeyFrameCount: integer;
    function GetPosition(index: integer): longint;
    procedure SetPosition(index: integer; const Value: longint);
    procedure SetTimes(index: integer; const Value: double);
    procedure SetKeyFrameCount(const Value: integer);
    function GetTimes(index: integer): double;
  public
    constructor Create; virtual;
    destructor Destroy; override; 
    procedure ReadFromStream(be: TBitsEngine); override;
    property KeyFrameCount: integer read FKeyFrameCount write SetKeyFrameCount;
    property Times[index: integer]: double read GetTimes write SetTimes;
    property Positions[index: integer]: longint read GetPosition write SetPosition;
  end;

  TFLVonMetaData = class (TFLVDataECMAArray)
  public
    function GetInfo(fdi: TFLVDataInfoType): TFLVCustomData;
    procedure ReadFromStream(be: TBitsEngine); override;
    property ObjectName: ansistring read FName write FName;
  end;


  TFLVData = class (TObject)
  private
    FFPS: word;
    FData: TStream;
    FFileName: string;
    FFrames: TObjectList;
    FSound: TObjectList;
    FHeader: TVHeader;
    FSoundHeader: TSHeader;
    SelfDestroy: Boolean;

    DataObject: TFLVonMetaData;
    FVideoPresent: boolean;
    FSoundPresent: boolean;
    FKeyFrameCount: longint;
    function GetSoundHeader: TSHeader;

    function GetFrameCount: Word;
    function GetFrameFromList(index: LongInt): TVFrame;
    function GetSoundExist: boolean;
    function GetSoundCount: Cardinal;
  public
    constructor Create(Fn: String);
    destructor Destroy; override;
    procedure Parse;
    function GetSoundFromList(index: Cardinal): TVFrame;
    property Data: TStream read FData write FData;
    property FileName: string read FFileName write FFileName;
    property Frame[index: LongInt]: TVFrame read GetFrameFromList;
    property FrameCount: Word read GetFrameCount;
    property Header: TVHeader read FHeader;
    property SoundExist: boolean read GetSoundExist;
    property KeyFrameCount: longint read FKeyFrameCount;
    property SoundPresent: boolean read FSoundPresent;
    property VideoPresent: boolean read FVideoPresent;
    property SoundCount: Cardinal read GetSoundCount;
    property SoundHeader: TSHeader read GetSoundHeader;
    property FPS:Word read FFPS;
  end;

implementation

Uses SysUtils, SWFConst, SWFStrings;

// ************ FLVObject ***********

{
********************* TFLVData *************************************
}
constructor TFLVData.Create(Fn: String);
begin
  inherited Create;
  FFileName := Fn;
  FFrames := TObjectList.Create;
  if Fn = '' then
      SelfDestroy := false
   else
   begin
     FData := TFileStream.Create(fn, fmOpenRead or fmShareDenyWrite);
     SelfDestroy := true;
     Parse;
   end;
end;

destructor TFLVData.Destroy;
begin
  if SelfDestroy then FData.Free;
  FFrames.Free;
  if Assigned(FSoundHeader) then FreeAndNil(FSoundHeader);
  if Assigned(FSound) then FreeAndNil(FSound);
  if Assigned(DataObject) then FreeAndNil(DataObject);

  inherited Destroy;
end;

function TFLVData.GetFrameCount: Word;
begin
  Result := FFrames.Count;
end;

function TFLVData.GetSoundCount:Cardinal;
begin
  if FSound = nil then result := 0
   else Result := FSound.Count;
end;

function TFLVData.GetSoundExist: boolean;
begin
  Result:= (FSoundHeader <> nil) or (FSound <> nil);
end;

function TFLVData.GetFrameFromList(index: LongInt): TVFrame;
begin
  Result := TVFrame(FFrames.Items[index]);
end;

function TFLVData.GetSoundFromList(index: Cardinal): TVFrame;
begin
  Result := TVFrame(FSound.Items[index mod FSound.Count]);
end;

function TFLVData.GetSoundHeader: TSHeader;
begin
  if FSoundHeader = nil then FSoundHeader := TSHeader.Create;
  Result := FSoundHeader;
end;

procedure TFLVData.Parse;
var
  BS: TBitsEngine;
  NewSound, NewFrame: TVFrame;
  TagType: byte;
  Frame, PrevFPS, SumFPS, l, SectionSize: Cardinal;
  IgnoreAudio: boolean;
//  Buff: array [0.. 29] of byte;
begin
   BS:=TBitsEngine.Create(Data);
   Data.Position := 0;
   PrevFPS := 0; SumFPS := 0;

  //  ******* FLV Header *******
   l:= BS.ReadBytes(3);
   if not (l = $564C46) then Exit;           // File Signature
   l:= BS.ReadByte;
   if not (l = $01) then Exit;               // Version
   l:= BS.ReadByte;

   FVideoPresent := CheckBit(l, 1);
   FSoundPresent := CheckBit(l, 3);
//   if not ((l AND 1) = $01) then Exit;       // Type Flag
                                             // 01-Video 04-Audio
   l:= BS.GetBits(32);                         // Reserved    == $09
   if l > 9 then Data.Seek(l - 9, 1);
   Frame:= 0;
   FKeyFrameCount := 0;
   IgnoreAudio := false;
  // ******** FLV Tag Parsing *******
   l:= BS.GetBits(32);                       // Prev TagSize
   Repeat
      TagType := BS.ReadByte;
                                              // 8-Audio    9-Video  18-script data
      Case TagType of
        8:begin
          SectionSize := BS.GetBits(24);        // Size Section
//         l := bs.GetBits(24);
//         if l >= 0 then
//           Data.Seek(-3, 1);

          if not IgnoreAudio and (SectionSize > 0) then
           begin  // SOUND
             Data.Seek(7, 1);
             if FSoundHeader = nil then
             begin
               FSound:=TObjectList.Create;
               Data.Read(SoundHeader.SoundInfo, 1);
//               if true{SectionSize > 0} then
//                 begin
////
//                   Data.Read(SoundHeader.SoundInfo, 1);
//                 end else
//               if (DataObject<>nil) then
//                 begin
//                   if (DataObject.GetInfo(fdiAudioCodecID)<>nil) then
//                     SoundHeader.SoundFormat := DataObject.GetInfo(fdiAudioCodecID).AsInteger;
//                 end;

               case SoundHeader.SoundFormat of
                 snd_MP3:
                  begin
                    SoundHeader.MP3Frame:=BS.GetBits(32);
                    Data.Seek(- 5, 1);
                  end;
                 snd_Nellymoser: 
                    Data.Seek(- 1, 1);
                 else
                   IgnoreAudio := true;
               end;
//               Data.Seek(- 1, 1);
             end;
             if IgnoreAudio then
               begin
                 FreeAndNil(FSound);
               end else
               begin
                 NewSound := TVFrame.Create;
                 NewSound.Len := SectionSize-1;
                 NewSound.Start := Data.Position+1;
                 NewSound.FInVideoPos := Frame;
                 FSound.Add(NewSound);
               end;
             Data.Seek(-7, 1);
           end;
        end;
        9: begin  // VIDEO
             If not boolean(Frame) Then
             begin
               Data.Seek(10, 1);
               l:=BS.ReadByte;                 // Codec+FrameType
               FHeader.CodecInfo:= l and $0f;
               FHeader.KeyFrame:= boolean(l shr 4);
               if FHeader.KeyFrame then inc(FKeyFrameCount);
               case FHeader.CodecInfo of
               codecSorenson:
                begin
                 Data.Seek(2, 1);
                 l:=BS.GetBits(17);                 // Picture Size
                 l:= l and 7;
                 Case l of
                 0: begin                          // Custom 1 byte
                    FHeader.XDim := BS.GetBits(8);
                    FHeader.YDim := BS.GetBits(8);
                    l:=BS.GetBits(23); end;
                 1: begin                          // Custom 2 byte
                    FHeader.XDim:=BS.GetBits(16);
                    FHeader.YDim:=BS.GetBits(16);
                    l:=BS.GetBits(7); end;
                 2: begin                          // CIF (352x288)
                    Data.Seek(2, 1);
                    FHeader.XDim:=352;
                    FHeader.YDim:=288;
                    l:=BS.GetBits(23); end;
                 3: begin                          // QCIF (176x144)
                    Data.Seek(2, 1);
                    FHeader.XDim:=176;
                    FHeader.YDim:=144;
                    l:=BS.GetBits(23); end;
                 4: begin                          // SQCIF (128x96)
                    Data.Seek(2, 1);
                    FHeader.XDim:=128;
                    FHeader.YDim:=96;
                    l:=BS.GetBits(23); end;
                 5: begin                          // 320x240
                    Data.Seek(2, 1);
                    FHeader.XDim:=320;
                    FHeader.YDim:=240;
                    l:=BS.GetBits(23); end;
                 6: begin                          // 160x120
                    Data.Seek(2, 1);
                    FHeader.XDim:=160;
                    FHeader.YDim:=120;
                    l:=BS.GetBits(23); end;
                 7: begin
                    l:=BS.GetBits(23);      // reserved
                    Data.Seek(2, 1); end;
                 end;
                 Data.Seek(-20, 1);
                end;

               codecScreenVideo:
                begin                              // ScreenCodec
                 FHeader.XDim:=bs.GetBits(16) and $0FFF;
                 FHeader.YDim:=bs.GetBits(16) and $0FFF;
                 Data.Seek(-15, 1);
                end;

               codecVP6:
                begin
                 if (DataObject <> nil) then
                  begin
                    if (DataObject.GetInfo(fdiWidth)<>nil) then
                      FHeader.XDim:= DataObject.GetInfo(fdiWidth).AsInteger;
                    if (DataObject.GetInfo(fdiHeight)<>nil) then
                      FHeader.YDim:= DataObject.GetInfo(fdiHeight).AsInteger;
                   end else
                   begin
                     Data.Seek(3, 1);

                     FHeader.YDim:= bs.ReadByte * 16;
                     FHeader.XDim:= bs.ReadByte * 16;

                     Data.Seek(-5, 1);

                   end;
                  Data.Seek(-11, 1);
                end;
              end;
             end;
             NewFrame:= TVFrame.Create;
             FFrames.Add(NewFrame);
             SectionSize := BS.GetBits(24);
             NewFrame.Start:= Data.Position + 8;
             if (NewFrame.Start + SectionSize) > Data.Size then
               SectionSize := Data.Size - NewFrame.Start;
             NewFrame.Len := SectionSize;

             l:=bs.GetBits(24);
             SumFPS := SumFPS + l - PrevFPS;
             PrevFPS := l;
             Data.Seek(-3, 1);
             inc(Frame);
           end;
        18: begin // script data
             SectionSize:= BS.GetBits(24);
             Data.Seek(7, 1);
             DataObject := TFLVonMetaData.Create;
             DataObject.SectionSize := SectionSize;
             DataObject.ReadFromStream(bs);
             Data.Position := DataObject.StartPosition - 7;
           end
           else
           begin
             SectionSize:= BS.GetBits(24);
           end;

        end;
        Data.Seek(SectionSize + 11, 1);
  Until Data.Position >= Data.Size;

    FHeader.FrameCount := Frame;
    if SumFPS = 0 then FFPS := 11
      else
       begin
         l := Round((10000*(Frame-1)/SumFPS));
         FFPS:=SingleToWord(l/10);
       end;
    BS.Free;
end;

{ TVFrame }

procedure TVFrame.SetLen(const Value: LongInt);
begin
  if Value < 0 then FLen := 0
    else FLen := Value;
end;

{ TFLVonMetaData }

function TFLVonMetaData.GetInfo(fdi: TFLVDataInfoType): TFLVCustomData;
 var il: integer;
begin
  Result := nil;
  if FList.Count > 0 then
    for il := 0 to FList.Count - 1 do
      if lowercase(Variable[il].FName) = sc_FLVMetaData[byte(fdi)] then
        Result := Variable[il];
end;

procedure TFLVonMetaData.ReadFromStream(be: TBitsEngine);
begin
  StartPosition := be.BitsStream.Position;
  if 2 = be.ReadByte then // marker = 2
  begin
  ObjectName := be.ReadLongString;
  if ObjectName = 'onMetaData' then
  begin
    DataType := TFLVDataType(be.ReadByte);
    if DataType = dtECMAArray then
     inherited;
  end;
  end;
end;

{ TFLVDataECMAArray }

constructor TFLVDataECMAArray.Create;
begin
  DataType := dtECMAArray; 
  FList := TObjectList.Create;
end;

destructor TFLVDataECMAArray.Destroy;
begin
  FList.Free;
  inherited;
end;

function TFLVDataECMAArray.GetFLVCustomData(ind: integer): TFLVCustomData;
begin
  Result := TFLVCustomData(FList[ind]);
end;

procedure TFLVDataECMAArray.ReadFromStream(be: TBitsEngine);
  var dtype: TFLVDataType;
      dName: ansistring;
      i, Count, readsize: longint;
      CData: TFLVCustomData;
begin
  Count := be.GetBits(32);
  if Count = 0 then 
     Count := 10000;
  I := 0;   
  while I < Count do
    begin
      dName := be.ReadLongString;
      dtype := TFLVDataType(be.ReadByte);
      CData := nil;
      case dtype of
        dtNumber:
          CData := TFLVDataNumber.Create;
        dtBoolean:
          CData := TFLVDataBoolean.Create;
        dtReference:
          CData := TFLVDataWord.Create;
        dtDate:
          CData := TFLVDataDate.Create;
        dtString, dtLongString, dtMovieClip: 
          CData := TFLVDataString.Create;
        dtObject:
         if dName = 'keyframes' then
          CData := TFLVKeyFramesObjectData.Create;
      end;
      if CData = nil then I := Count else
        begin
          CData.VariableName := dName;
          CData.ReadFromStream(be);
          FList.Add(CData);
          inc(I);
        end;
      if (I < Count) then
        begin
           readsize := be.BitsStream.Position - StartPosition;
           if (SectionSize - readsize) <= 3 then
             Count := I;
        end;
    end;
end;

{ TFLVDataString }
function TFLVDataString.AsInteger: integer;
begin
  Result := StrToIntDef(FValue, 0);
end;

constructor TFLVDataString.Create;
begin
  DataType := dtString;
end;

procedure TFLVDataString.ReadFromStream(be: TBitsEngine);
begin
  Value := be.ReadLongString;
end;

procedure TFLVDataString.SetString(const Val: ansistring);
begin
  FValue := Val;
end;

{ TFLVDataNumber }

function TFLVDataNumber.AsInteger: integer;
begin
  Result := Round(FValue);
end;

constructor TFLVDataNumber.Create;
begin
  DataType := dtNumber;
end;

procedure TFLVDataNumber.ReadFromStream(be: TBitsEngine);
begin
  FValue := be.ReadDouble;
end;

procedure TFLVDataNumber.SetValue(const Val: double);
begin
  FValue := Val;
end;

{ TFLVDataBoolean }

function TFLVDataBoolean.AsInteger: integer;
begin
  Result := Byte(FValue);
end;

constructor TFLVDataBoolean.Create;
begin
  DataType := dtBoolean;
end;

procedure TFLVDataBoolean.ReadFromStream(be: TBitsEngine);
begin
 FValue := Boolean(be.ReadByte);
end;

procedure TFLVDataBoolean.SetValue(const Val: boolean);
begin
  FValue := Val;
end;

{ TFLVDataWord }

function TFLVDataWord.AsInteger: integer;
begin
  Result := integer(FValue);
end;

constructor TFLVDataWord.Create;
begin
  DataType := dtReference;  
end;

procedure TFLVDataWord.ReadFromStream(be: TBitsEngine);
begin
  FValue :=  be.ReadWord;
end;

procedure TFLVDataWord.SetValue(const Val: Word);
begin
  FValue := Val;  
end;

{ TFLVDataDate }

constructor TFLVDataDate.Create;
begin
  DataType := dtDate;
end;

procedure TFLVDataDate.ReadFromStream(be: TBitsEngine);
begin
  be.BitsStream.Read(FValue, 8);
  LocalDateTimeOffset := be.ReadSingle;
end;

procedure TFLVDataDate.SetValue(const Val: TDateTime);
begin
 FValue := Val;
end;

{ TSHeader }

function TSHeader.GetIs16bit: boolean;
begin
  Result := CheckBit(SoundInfo, 2);
end;

function TSHeader.GetIsStereo: boolean;
begin
  Result := CheckBit(SoundInfo, 1);
end;

function TSHeader.GetSoundFormat: byte;
begin
  Result := SoundInfo shr 4;
end;

function TSHeader.GetSoundRate: byte;
begin
  Result := (SoundInfo shr 2) and 3;
end;

procedure TSHeader.SetSoundFormat(const Value: byte);
begin
  SoundInfo := (SoundInfo and 15) + Byte(Value shl 4) ;
end;

{ TFLVCustomData }

procedure TFLVCustomData.ReadFromStream(be: TBitsEngine);
begin
 // empty
end;

{ TFLVObjectData }

constructor TFLVKeyFramesObjectData.Create;
begin
  DataType := dtObject;
  FTimes := nil;
  FPosition := nil;
end;

destructor TFLVKeyFramesObjectData.Destroy;
begin
  KeyFrameCount := 0;
  inherited;
end;

function TFLVKeyFramesObjectData.GetPosition(index: integer): longint;
 var PL: PLongint;
begin
  PL := FPosition;
  if index > 0 then Inc(PL);
  Result := PL^;
end;

function TFLVKeyFramesObjectData.GetTimes(index: integer): double;
 var PD: PDouble;
begin
  PD := FTimes;
  if index > 0 then Inc(PD);
  Result := PD^;
end;

procedure TFLVKeyFramesObjectData.ReadFromStream(be: TBitsEngine);
 var stt: string;

  procedure ReadArray(aname: string);
   var iframe: longint;
  begin
   if aname = 'filepositions' then
    begin
     iframe := 0;
     while iframe < KeyFrameCount do
       begin
         Positions[iframe] := Round(be.ReadDouble);
         inc(iframe);
         if iframe < KeyFrameCount then be.ReadByte;
       end;
    end else
   if aname = 'times' then
    begin
     iframe := 0;
     while iframe < KeyFrameCount do
       begin
         Times[iframe] :=  be.ReadDouble;
         inc(iframe);
         if iframe < KeyFrameCount then be.ReadByte;

       end;
    end;
  end;
begin
  stt := be.ReadLongString;
  be.ReadDWord;
  KeyFrameCount := be.ReadWord;
  ReadArray(stt);

  stt := be.ReadLongString;
  be.ReadDWord;
  if be.ReadWord <= KeyFrameCount then
    ReadArray(stt);
end;

procedure TFLVKeyFramesObjectData.SetKeyFrameCount(const Value: integer);
begin
 if Value <> FKeyFrameCount then
  begin
  if FKeyFrameCount > 0 then
    begin
      FreeMem(FTimes);
      FreeMem(FPosition);
    end;
  FKeyFrameCount := Value;
  if Value > 0 then
    begin
      GetMem(FTimes, 8 * Value);
      GetMem(FPosition, 4 * Value);
    end;
  end;
end;

procedure TFLVKeyFramesObjectData.SetPosition(index: integer; const Value: longint);
 var
    PL: PLongint;
begin
  PL := FTimes;
  if index > 0 then Inc(PL);
  PL^ := Value;
end;

procedure TFLVKeyFramesObjectData.SetTimes(index: integer; const Value: double);
 var
    PD: PDouble;
begin
  PD := FTimes;
  if index > 0 then Inc(PD);
  PD^ := Value;
end;

end.


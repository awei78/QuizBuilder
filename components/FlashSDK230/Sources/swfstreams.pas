//*******************************************************//
//                                                       //
//                      DelphiFlash.com                  //
//        Copyright (c) 2004-2008 FeatherySoft, Inc.     //
//                    info@delphiflash.com               //
//                                                       //
//*******************************************************//

//  Description:  Streams for reading and writing of SWF file
//  Last update:  12 mar 2008
{$I defines.inc}

unit SWFStreams;
interface
Uses Windows, Classes, SysUtils,
  SWFConst, Contnrs, SWFObjects;

type

  TSWFTagInfo = class (TObject)
    BodySize: LongInt;
    FramePlace: Word;
    isLongSize: Boolean;
    Position: LongInt;
    SubTags: TObjectList;
    selfDestroy: boolean;
    SWFObject: TSWFObject;
    TagID: Word;
    constructor Create(ID: word; automake: boolean = true);
    destructor Destroy; override;
    function GetFullSize: LongInt;
  end;

  TBasedSWFStream = class;

  TProgressWorkType = (pwtReadStream, pwtMakeStream, pwtCompressStream, pwtLoadXML, pwtParseXML, pwtSaveXML);
  TSWFProgressEvent = procedure (sender: TBasedSWFStream; Percent: byte; WT: TProgressWorkType) of object;
  TSWFParseTagBodyEvent = procedure (sender: TSWFTagInfo; var Parse: boolean) of object;
  TSWFProcessTagEvent = procedure (sender: TSWFObject; var Process: boolean) of object;
  TSWFRenameObjectEvent = procedure (sender: TSWFObject; var newname: string) of object;
// ================== TBasedSWFStream =========================
  TBasedSWFStream = class (TObject)
  private
    FBodyStream: TStream;
    SelfBodyStream: boolean;
    FCompressed: Boolean;
    FMultCoord: Byte;
    FOnProgress: TSWFProgressEvent;
    FSystemCoord: TSWFSystemCoord;
    function GetBodyStream: TStream;
    function GetFPS: Single;
    function GetHeight: Integer;
    function GetSWFRect: TRect;
    function GetWidth: Integer;
    procedure SetBodyStream(Src: TStream);
    procedure SetCompressed(compr: Boolean);
    procedure SetFPS(v: Single);
    procedure SetHeight(Value: Integer);
    procedure SetSystemCoord(v: TSWFSystemCoord);
    procedure SetVersion(v: Byte);
    procedure SetWidth(Value: Integer);
    procedure OnProgressCompress(sender: TObject);
  protected
    procedure DoChangeHeader; virtual;
  public
    SWFHeader: TSWFHeader;
    constructor Create; overload; virtual;
    constructor Create(XMin, YMin, XMax, YMax: integer; fps: single; sc: TSWFSystemCoord = scTwips); overload; virtual;
    destructor Destroy; override;
    function FramePos(num: word): longint; virtual; abstract;
    function GetHeaderSize: Integer;
    procedure MakeStream; virtual; abstract;
    procedure MoveResource(ToFrame, StartFrom, EndFrom: integer); virtual; abstract;
    procedure SaveToFile(fn: string);
    procedure SaveToStream(Stream: TStream);
    procedure SetSWFRect(v: TRect);
    procedure WriteHeader(stream: TStream; part: TSWFHeaderPart = hpAll);
    property BodyStream: TStream read GetBodyStream write SetBodyStream;
    property Compressed: Boolean read FCompressed write SetCompressed;
    property FPS: Single read GetFPS write SetFPS;
    property FramesCount: Word read SWFHeader.FramesCount;
    property Height: Integer read GetHeight write SetHeight;
    property MovieRect: TRect read GetSWFRect write SWFHeader.MovieRect;
    property MultCoord: Byte read FMultCoord write FMultCoord;
    property SystemCoord: TSWFSystemCoord read FSystemCoord write SetSystemCoord;
    property Version: Byte read SWFHeader.Version write SetVersion;
    property Width: Integer read GetWidth write SetWidth;
    property OnProgress: TSWFProgressEvent read FOnProgress write FOnProgress;
  end;

  TSWFStreamReader = class (TBasedSWFStream)
  private
    FIsSWF: Boolean;
    FOnParseTagBody: TSWFParseTagBodyEvent;
    FOnRenameObject: TSWFRenameObjectEvent;
    FOnRenumberTag: TSWFProcessTagEvent;
    FTagList: TObjectList;
    function GetTagInfo(index: word): TSWFTagInfo;
  public
    constructor Create(fn: string); overload;
    constructor Create(stream: TStream); overload;
    destructor Destroy; override;
    function CheckSWF(stest: TStream): Boolean;
    procedure DeleteTagByID(Place, Obj: boolean; ID: word);
    procedure DeleteTagByName(Place, Obj: boolean; name: string);
    function FindIDFromName(name: string): word;
    function FindObjectFromID(ID: word): TSWFObject;
    function FindObjectFromName(name: string): TSWFObject;
    function FindPlaceFromID(ID: word): TSWFPlaceObject;
    function FindPlaceFromName(name: string): TSWFPlaceObject2;
    function FindTagFromID(ID: word): longint;
    function FindTagFromObject(Obj: TSWFObject): longint;
    function FindTagFromName(name: string): longint;
    function FramePos(num: word): longint; override;
    function GetMinVersion: Byte;
    procedure LoadFromFile(fn: string);
    procedure LoadFromStream(stream: TStream);
    function LoadHeader(src: TStream; part: TSWFHeaderPart = hpAll): Integer;
    procedure MakeStream; override;
    procedure MoveResource(ToFrame, StartFrom, EndFrom: integer); override;
    procedure ReadBody(ParseTagData, ParseActionData: boolean);
    procedure Rename(prefix: string);
    function Renumber(start: word): Word;
    property IsSWF: Boolean read FIsSWF;
    property OnParseTagBody: TSWFParseTagBodyEvent read FOnParseTagBody write FOnParseTagBody;
    property OnRenameObject: TSWFRenameObjectEvent read FOnRenameObject write FOnRenameObject;
    property OnRenumberTag: TSWFProcessTagEvent read FOnRenumberTag write FOnRenumberTag;
    property TagInfo[index: word]: TSWFTagInfo read GetTagInfo;
    property TagList: TObjectList read FTagList;
  end;

implementation

Uses
       SWFTools, Zlib, Math;

//===============  TBasedSWFStream  ========================
{
****************************************************** TBasedSWFStream ******************************************************
}
constructor TBasedSWFStream.Create;
begin
  inherited Create;
  SWFHeader.Version := 5; // default Version
  SystemCoord := scTwips;
end;

constructor TBasedSWFStream.Create(XMin, YMin, XMax, YMax: integer; fps: single; sc: TSWFSystemCoord = scTwips);
begin
  inherited Create;
  SystemCoord := sc;
  SWFHeader.Version := 5; // default Version
  SWFHeader.MovieRect := rect(XMin * MultCoord, YMin * MultCoord, XMax * MultCoord, YMax * MultCoord);
  SetFPS(fps);
end;

destructor TBasedSWFStream.Destroy;
begin
  if Assigned(FBodyStream) and SelfBodyStream then FBodyStream.Free;
  inherited;
end;

procedure TBasedSWFStream.DoChangeHeader;
begin
 // empty
end;

function TBasedSWFStream.GetBodyStream: TStream;
begin
  if not Assigned(FBodyStream) then
    begin
      FBodyStream := TMemoryStream.Create;
      SelfBodyStream := true;
    end;
  Result := FBodyStream;
end;

function TBasedSWFStream.GetFPS: Single;
begin
  Result:=WordToSingle(SWFHeader.FPS);
end;

function TBasedSWFStream.GetHeaderSize: Integer;
begin
  With SWFHeader.MovieRect do
   Result := 12 + Ceil((5 + 4*GetBitsCount(SWFTools.MaxValue(left, top, right, bottom), 1)) / 8);
end;

function TBasedSWFStream.GetHeight: Integer;
begin
  Result := (SWFHeader.MovieRect.Bottom - SWFHeader.MovieRect.Top) div MultCoord;
end;

function TBasedSWFStream.GetSWFRect: TRect;
begin
  Result := Rect(SWFHeader.MovieRect.Left div MultCoord,
                 SWFHeader.MovieRect.Top div MultCoord,
                 SWFHeader.MovieRect.Right div MultCoord,
                 SWFHeader.MovieRect.Bottom div MultCoord);
end;

function TBasedSWFStream.GetWidth: Integer;
begin
  Result := (SWFHeader.MovieRect.Right - SWFHeader.MovieRect.Left) div MultCoord;
end;

procedure TBasedSWFStream.SetBodyStream(Src: TStream);
begin
  if (SelfBodyStream) then
    FreeAndNil(FBodyStream);
  FBodyStream := Src;
  SelfBodyStream := false;
end;

procedure TBasedSWFStream.SaveToFile(fn: string);
var
  fs: TFileStream;
begin
  if fileExists(fn) then DeleteFile(fn);
  try // added by Mironichev
    fs := TFileStream.Create(fn, fmCreate);
    SaveToStream(fs);
  finally // added by Mironichev
    fs.Free;
  end;
end;

procedure TBasedSWFStream.SaveToStream(Stream: TStream);
var
  CS: TCompressionStream;
begin
  SWFHeader.FileSize := GetHeaderSize + BodyStream.Size;

  BodyStream.Position:= 0;
  if Compressed then
   begin
     SWFHeader.SIGN:=SWFSignCompress;
     if SWFHeader.Version < SWFVer6 then SWFHeader.Version := SWFVer6;
     WriteHeader(Stream, hp1);
     CS := TCompressionStream.Create(clDefault, Stream);
     CS.OnProgress := OnProgressCompress;
     WriteHeader(CS, hp2);
     CS.CopyFrom(BodyStream, BodyStream.Size);
     CS.Free;
   end
   else
   begin
     SWFHeader.SIGN := SWFSign;
     WriteHeader(Stream);
     Stream.CopyFrom(BodyStream, BodyStream.Size);
   end;

end;

procedure TBasedSWFStream.SetCompressed(compr: Boolean);
begin
  FCompressed := compr;
  if Compressed and (Version < SWFVer6) then SWFHeader.Version := SWFVer6;
  DoChangeHeader;
end;

procedure TBasedSWFStream.OnProgressCompress(sender: TObject);
begin
  if Assigned(FOnProgress) then
    FOnProgress(self, Round(TStream(Sender).Position / (BodyStream.Size - 22)  * 100), pwtCompressStream);
end;

procedure TBasedSWFStream.SetFPS(v: Single);
begin
  SWFHeader.FPS := SingleToWord(v);
  DoChangeHeader;
end;

procedure TBasedSWFStream.SetHeight(Value: Integer);
begin
  SWFHeader.MovieRect.Bottom := SWFHeader.MovieRect.Top + Value * MultCoord;
  DoChangeHeader;
end;

procedure TBasedSWFStream.SetSWFRect(v: TRect);
begin
  SWFHeader.MovieRect := Rect(v.Left * MultCoord, v.Top * MultCoord,
                              v.Right * MultCoord, v.Bottom * MultCoord);
  DoChangeHeader;
end;

procedure TBasedSWFStream.SetSystemCoord(v: TSWFSystemCoord);
begin
  if v = scTwips then MultCoord := 1 else MultCoord := 20;
  fSystemCoord := v;
end;

procedure TBasedSWFStream.SetVersion(v: Byte);
begin
  if Compressed and (v < SWFVer6) then SWFHeader.Version := SWFVer6
    else SWFHeader.Version := v;
  DoChangeHeader;  
end;

procedure TBasedSWFStream.SetWidth(Value: Integer);
begin
  SWFHeader.MovieRect.Right := SWFHeader.MovieRect.Left + Value * MultCoord;
  DoChangeHeader;
end;

procedure TBasedSWFStream.WriteHeader(stream: TStream; part: TSWFHeaderPart = hpAll);
var
  BE: TBitsEngine;
begin
  if part in [hpAll, hp1] then stream.Write(SWFHeader, SizeOfhp1);
  if part in [hpAll, hp2] then
    begin
      BE:=TBitsEngine.Create(stream);
      BE.WriteRect(SWFHeader.MovieRect);
      BE.Free;
      stream.Write(SWFheader.FPS, 2);
      stream.Write(SWFheader.FramesCount, 2);
    end;
end;

{
******************************************************** TSWFTagInfo ********************************************************
}
constructor TSWFTagInfo.Create(ID: word; automake: boolean = true);
begin
  inherited Create;
  TagID := ID;
  selfDestroy := true;
  if automake then
      SWFObject := GenerateSWFObject(ID);
  if ID in [tagDefineSprite] then SubTags := TObjectList.Create;
end;

destructor TSWFTagInfo.Destroy;
begin
  if selfDestroy and Assigned(SWFObject) then SWFObject.Free;
  if SubTags<>nil then SubTags.Free;
  inherited;
end;

function TSWFTagInfo.GetFullSize: LongInt;
begin
  Result := BodySize + 2 + Byte(isLongSize) * 4;
end;


//===============  TSWFStreamReader  ========================

{
***************************************************** TSWFStreamReader ******************************************************
}
constructor TSWFStreamReader.Create(fn: string);
begin
  inherited Create;
  fTagList := TObjectList.Create;
  if fn <> '' then LoadFromFile(fn);
end;

constructor TSWFStreamReader.Create(stream: TStream);
begin
  inherited Create;
  fTagList := TObjectList.Create;
  LoadFromStream(stream);
end;

destructor TSWFStreamReader.Destroy;
begin
  fTagList.Free;
  inherited;
end;

function TSWFStreamReader.CheckSWF(stest: TStream): Boolean;
var
  Sign: array [0..2] of char;
begin
  result := false;
  if stest.Size > 3 then
   begin
    stest.Seek(0, 0);
    stest.Read(Sign, 3);
    if (SWFSign = Sign) or (SWFSignCompress = Sign) then
     begin
       result := true;
       fCompressed := SWFSignCompress = Sign;
     end;
   end;
  fisSWF := result;
end;

procedure TSWFStreamReader.DeleteTagByID(Place, obj: boolean; ID: word);
 var il, il2, iTag: longint;
begin
  if FTagList.Count = 0 then exit;
  if obj then
    begin
     iTag := FindTagFromID(ID);
     FTagList.Delete(iTag);
     Place := true;
    end;

  if Place then
   begin
     il := 0;
     while il < FTagList.Count  do
      begin
       Case TagInfo[il].TagID of
        tagPlaceObject, tagPlaceObject2, tagPlaceObject3:
          if ID = TSWFBasedPlaceObject(TagInfo[il].SWFObject).CharacterId then
            begin
              FTagList.Delete(il);
              dec(il);
            end;

        tagDefineSprite:
          with TSWFDefineSprite(TagInfo[il].SWFObject) do
           if ControlTags.Count > 0 then
            begin
              il2 := 0;
              while il2 < ControlTags.Count do
               case TSWFObject(ControlTags[il2]).TagID of
                tagPlaceObject, tagPlaceObject2, tagPlaceObject3:
                 begin
                  TagInfo[il].SubTags.Delete(il2);
                  ControlTags.Delete(il2);
                  dec(il2);
                 end;
               end;
            end;

       end;
       inc(il);
      end;
   end;
end;

procedure TSWFStreamReader.DeleteTagByName(Place, Obj: boolean; name: string);
var
  il, il2, iTag: longint;
  PO: TSWFPlaceObject2;
  isend: boolean;
begin

  if FTagList.Count = 0 then exit;
  isend := false;
  if fTagList.Count = 0 then exit;
  For il := 0 to fTagList.Count - 1 do
   begin
    Case TagInfo[il].TagID of
      tagPlaceObject2, tagPlaceObject3:
        begin
          PO := TSWFPlaceObject2(TagInfo[il].SWFObject);
          if name = PO.Name then
            begin
              iTag := FindTagFromID(PO.CharacterId);
              if obj then
                FTagList.Delete(iTag);
              if obj or Place then
                FTagList.Delete(il - byte(il > iTag)* byte(obj));
              Break;
            end;
        end;

      tagExportAssets:
       if obj then
        with TSWFExportAssets(TagInfo[il].SWFObject) do
         if Assets.Count > 0 then
           begin
             il2 := Assets.Count - 1;
             iTag := 0;
             while il2 >= 0 do
             begin
               if Assets[il2] = name then
                begin
                  iTag := FindTagFromID(Longint(Assets.Objects[il2]));
                  if iTag > -1 then
                   begin
                     FTagList.Delete(iTag);
                     Assets.Delete(il2);
                     isend := true;
                     Break;
                   end;
                end;
                dec(il2);
             end;
             if Assets.Count = 0 then FTagList.Delete(il - byte(il > iTag));
             if isend then Break;
           end;
    end;
   end;
end;

function TSWFStreamReader.FindIDFromName(name: string): word;
var
  il, il2: Word;
  PO: TSWFPlaceObject2;
begin
  Result := 0;
  if fTagList.Count = 0 then exit;
  For il := 0 to fTagList.Count - 1 do
   begin
    Case TagInfo[il].TagID of
      tagDefineSprite:
        with TSWFDefineSprite(TagInfo[il].SWFObject) do
         if ControlTags.Count > 0 then
         begin
          for il2 := 0 to ControlTags.Count - 1 do
           if TSWFObject(ControlTags[il2]).TagID in [tagPlaceObject2, tagPlaceObject3] then
             begin
               PO := TSWFPlaceObject2(ControlTags[il2]);
               if PO.PlaceFlagHasName and PO.PlaceFlagHasCharacter and (name = PO.Name) then
               begin
                 Result := PO.CharacterId;
                 Break;
               end;
             end;
          if Result > 0 then Break;
         end;

      tagPlaceObject2, tagPlaceObject3:
        begin
          if name = TSWFPlaceObject2(TagInfo[il].SWFObject).Name then
            begin
              Result := TSWFPlaceObject2(TagInfo[il].SWFObject).CharacterId;
              Break;
            end;
        end;

      tagExportAssets:
        with TSWFExportAssets(TagInfo[il].SWFObject) do
         if Assets.Count > 0 then
           begin
             for il2 := 0 to Assets.Count - 1 do
              if Assets[il2] = name then
                begin
                  Result := Longint(Assets.Objects[il2]);
                  Break;
                end;
             if Result > 0 then Break;
           end;
    end;
   end;
end;

function TSWFStreamReader.FindObjectFromID(ID: word): TSWFObject;
var
  il: LongInt;
begin
  il := FindTagFromID(ID);
  if il = -1 then Result := nil else Result := TagInfo[il].SWFObject;
end;

function TSWFStreamReader.FindTagFromID(ID: word): longint;
var
  il, il2: LongInt;
begin
  Result := -1;
  if FTagList.Count = 0 then exit;
  For il := 0 to FTagList.Count - 1 do
   begin
    Case TagInfo[il].TagID of
      tagDefineShape, tagDefineShape2, tagDefineShape3, tagDefineShape4:
        if TSWFDefineShape(TagInfo[il].SWFObject).ShapeId = ID then
          Result := il;

      tagDefineMorphShape, tagDefineMorphShape2:
        if TSWFDefineMorphShape(TagInfo[il].SWFObject).CharacterID = ID then
          Result := il;

      tagDefineBits, tagDefineBitsJPEG2, tagDefineBitsJPEG3,
      tagDefineBitsLossless, tagDefineBitsLossless2 :
        if TSWFImageTag(TagInfo[il].SWFObject).CharacterID = ID then
          Result := il;

      tagDefineFont, tagDefineFont2, tagDefineFont3:
        if TSWFDefineFont(TagInfo[il].SWFObject).FontID = ID then
          Result := il;

      tagDefineFontInfo2:
        if TSWFDefineFontInfo2(TagInfo[il].SWFObject).FontID = ID then
          Result := il;

      tagDefineText, tagDefineText2:
        if TSWFDefineText(TagInfo[il].SWFObject).CharacterID = ID then
          Result := il;

      tagDefineEditText:
        if TSWFDefineEditText(TagInfo[il].SWFObject).CharacterID = ID then
          Result := il;

      tagDefineSound:
        if TSWFDefineSound(TagInfo[il].SWFObject).SoundId = ID then
          Result := il;

      tagDefineButton, tagDefineButton2:
        if TSWFDefineButton(TagInfo[il].SWFObject).ButtonId = ID then
          Result := il;

      tagDefineSprite:
        if TSWFDefineSprite(TagInfo[il].SWFObject).SpriteID = ID then
          Result := il;

      tagDefineVideoStream:
        if TSWFDefineVideoStream(TagInfo[il].SWFObject).CharacterID = ID then
          Result := il;

      tagImportAssets:
        with TSWFImportAssets(TagInfo[il].SWFObject) do
         if Assets.Count > 0 then
          for il2 := 0 to Assets.Count - 1 do
           if Longint(Assets.Objects[il2]) = ID then
             begin
               Result := il;
               Break;
             end;
    end;
    if Result > -1 then Break;
   end;
end;

function TSWFStreamReader.FindObjectFromName(name: string): TSWFObject;
var
  il, il2: Word;
  PO: TSWFPlaceObject2;
begin
  Result := nil;
  if fTagList.Count = 0 then exit;
  For il := 0 to fTagList.Count - 1 do
   begin
    Case TagInfo[il].TagID of
      tagDefineSprite:
        with TSWFDefineSprite(TagInfo[il].SWFObject) do
         if ControlTags.Count > 0 then
         begin
          for il2 := 0 to ControlTags.Count - 1 do
           if TSWFObject(ControlTags[il2]).TagID in [tagPlaceObject2, tagPlaceObject3] then
             begin
               PO := TSWFPlaceObject2(ControlTags[il2]);
               if PO.PlaceFlagHasName and PO.PlaceFlagHasCharacter and (name = PO.Name) then
               begin
                 Result := FindObjectFromID(PO.CharacterId);
                 if Result <> nil then Break;
               end;
             end;
          if Result <> nil then Break;
         end;

      tagPlaceObject2, tagPlaceObject3:
        begin
          if name = TSWFPlaceObject2(TagInfo[il].SWFObject).Name then
            begin
              Result := FindObjectFromID(TSWFPlaceObject2(TagInfo[il].SWFObject).CharacterId);
              if Result <> nil then Break;
            end;
        end;

      tagExportAssets:
        with TSWFExportAssets(TagInfo[il].SWFObject) do
         if Assets.Count > 0 then
           begin
             for il2 := 0 to Assets.Count - 1 do
              if Assets[il2] = name then
                begin
                  Result := FindObjectFromID(Longint(Assets.Objects[il2]));
                  if Result <> nil then Break;
                end;
           end;
    end;
   end;
end;

function TSWFStreamReader.FindPlaceFromID(ID: word): TSWFPlaceObject;
var
  il, il2: Word;
  PO: TSWFPlaceObject2;
begin
  Result := nil;
  if fTagList.Count = 0 then exit;
  For il := 0 to fTagList.Count - 1 do
    Case TagInfo[il].TagID of
      tagDefineSprite:
        with TSWFDefineSprite(TagInfo[il].SWFObject) do
        if ControlTags.Count > 0 then
        begin
          for il2 := 0 to ControlTags.Count - 1 do
           if TSWFObject(ControlTags[il2]).TagID in [tagPlaceObject2, tagPlaceObject3] then
           begin
             PO := TSWFPlaceObject2(ControlTags[il2]);
             if PO.PlaceFlagHasCharacter and (ID = PO.CharacterID) then
             begin
               Result := TSWFPlaceObject(PO);
               Break;
             end;
           end;
          if Result <> nil then Break;
        end;

      tagPlaceObject2, tagPlaceObject3:
        begin
          PO := TSWFPlaceObject2(TagInfo[il].SWFObject);
          if PO.PlaceFlagHasCharacter and (PO.CharacterId = ID) then
          begin
            Result := TSWFPlaceObject(PO);
            Break;
          end;
        end;
    end;
end;

function TSWFStreamReader.FindPlaceFromName(name: string): TSWFPlaceObject2;
var
  il, il2: Word;
  PO: TSWFPlaceObject2;
begin
  Result := nil;
  if fTagList.Count = 0 then exit;
  For il := 0 to fTagList.Count - 1 do
    Case TagInfo[il].TagID of
      tagDefineSprite:
        with TSWFDefineSprite(TagInfo[il].SWFObject) do
         if ControlTags.Count > 0 then
         begin
          for il2 := 0 to ControlTags.Count - 1 do
           if TSWFObject(ControlTags[il2]).TagID in [tagPlaceObject2, tagPlaceObject3] then
             begin
               PO := TSWFPlaceObject2(ControlTags[il2]);
               if name = PO.Name then
               begin
                 Result := PO;
                 Break;
               end;
             end;
          if Result <> nil then Break;
         end;

      tagPlaceObject2, tagPlaceObject3:
        begin
          PO := TSWFPlaceObject2(TagInfo[il].SWFObject);
          if name = PO.Name then
          begin
            Result := PO;
            Break;
          end;
        end;
    end;
end;

function TSWFStreamReader.FindTagFromObject(obj: TSWFObject): longint;
 var il: longint;
begin
 Result := -1;
 for il := 0 to TagList.Count - 1 do
  if obj = TagInfo[il].SWFObject then
   begin
     Result := il;
     Break;
   end;
end;

function TSWFStreamReader.FramePos(num: word): longint;
  var il, cur: longint;
begin
 cur := 0;
 Result := 0;
 if (num = 0) or (TagList.Count = 0) then Exit;
 Result := -1;
 for il := 0 to TagList.Count - 1 do
   if TagInfo[il].TagID = tagShowFrame then
     begin
       inc(cur);
       if num = cur then
         begin
           Result := il;
           Break;
         end;
     end;
 if Result = -1 then Result := TagList.Count - 1;
end;

function TSWFStreamReader.FindTagFromName(name: string): longint;
var
  il, il2: Word;
  PO: TSWFPlaceObject2;
begin
  Result := -1;
  if fTagList.Count = 0 then exit;
  For il := 0 to fTagList.Count - 1 do
   begin
    Case TagInfo[il].TagID of
      tagDefineSprite:
        with TSWFDefineSprite(TagInfo[il].SWFObject) do
         if ControlTags.Count > 0 then
         begin
          for il2 := 0 to ControlTags.Count - 1 do
           if TSWFObject(ControlTags[il2]).TagID in [tagPlaceObject2, tagPlaceObject3] then
             begin
               PO := TSWFPlaceObject2(ControlTags[il2]);
               if PO.PlaceFlagHasName and PO.PlaceFlagHasCharacter and (name = PO.Name) then
               begin
                 Result := FindTagFromID(PO.CharacterId);
                 if Result > -1 then Break;
               end;
             end;
          if Result > -1 then Break;
         end;

      tagPlaceObject2, tagPlaceObject3:
        begin
          if name = TSWFPlaceObject2(TagInfo[il].SWFObject).Name then
            begin
              Result := FindTagFromID(TSWFPlaceObject2(TagInfo[il].SWFObject).CharacterId);
              if Result > -1 then Break;
            end;
        end;

      tagExportAssets:
        with TSWFExportAssets(TagInfo[il].SWFObject) do
         if Assets.Count > 0 then
           begin
             for il2 := 0 to Assets.Count - 1 do
              if Assets[il2] = name then
                begin
                  Result := FindTagFromID(Longint(Assets.Objects[il2]));
                  if Result > -1 then Break;
                end;
           end;
    end;
   end;
end;

function TSWFStreamReader.GetMinVersion: Byte;
var
  il: Integer;
  SWFObject: TSWFObject;
begin
  Result := 1;
  if fTagList.Count = 0 then exit;
  for il:=0 to fTagList.Count - 1 do
   begin
     SWFObject := TSWFTagInfo(fTagList.Items[il]).SWFObject;
     if (SWFObject<>nil) and (Result < SWFObject.MinVersion) then
       Result := SWFObject.MinVersion;
   end;
end;

function TSWFStreamReader.GetTagInfo(index: word): TSWFTagInfo;
begin
  Result := TSWFTagInfo(TagList[index]);
end;

procedure TSWFStreamReader.LoadFromFile(fn: string);
var
  fs: TFileStream;
begin
  fs:= TFileStream.Create(fn, fmOpenRead);
  LoadFromStream(fs);
  fs.Free;
end;

procedure TSWFStreamReader.LoadFromStream(stream: TStream);
var
  ZStream: TDeCompressionStream;
  tmpMem: TMemoryStream;
begin
  if CheckSWF(stream) then
   begin
     stream.Position:=0;
     if fCompressed then
     begin
       LoadHeader(stream, hp1);
       ZStream := TDeCompressionStream.Create(stream);
       try
         tmpMem := TMemoryStream.Create;
         tmpMem.CopyFrom(ZStream, SWFHeader.FileSize - SizeOfhp1);
         tmpMem.Position := 0;
         LoadHeader(tmpMem, hp2);
         BodyStream.CopyFrom(tmpMem, tmpMem.Size - tmpMem.Position);
         tmpMem.Free;
       finally
         ZStream.free;
       end;
     end else
     begin
       LoadHeader(stream);
       BodyStream.CopyFrom(stream, stream.size - stream.Position);
     end;
   end;
end;

function TSWFStreamReader.LoadHeader(src: TStream; part: TSWFHeaderPart = hpAll): Integer;
var
  BE: TBitsEngine;
begin
  Result := src.Position;
  if part in [hpAll, hp1] then src.Read(SWFHeader, SizeOfhp1);
  if part in [hpAll, hp2] then
    begin
      BE:=TBitsEngine.Create(src);
      SWFHeader.MovieRect := BE.ReadRect;
      SWFHeader.FPS := BE.ReadWord;
      SWFHeader.FramesCount := BE.ReadWord;
      BE.Free;
    end;
  Result := src.Position - Result;
end;

procedure TSWFStreamReader.MakeStream;
var
  NewBody: TMemoryStream;
  il: LongInt;
  BE: TBitsEngine;
begin
  NewBody := TMemoryStream.Create;
  BE := TBitsEngine.Create(NewBody);
  if TagList.Count > 0 then
    for il := 0 to TagList.Count - 1 do
      begin
        if Assigned(FOnProgress) then FOnProgress(self, Round((il+1)/TagList.Count*100), pwtMakeStream);
        if TagInfo[il].SWFObject = nil then
           begin
             BodyStream.Position := TagInfo[il].Position;
             NewBody.CopyFrom(BodyStream, TagInfo[il].GetFullSize);
           end else TagInfo[il].SWFObject.WriteToStream(BE);
      end;
  BodyStream := NewBody;
  SelfBodyStream := true;
  BE.Free;
end;

procedure TSWFStreamReader.MoveResource(ToFrame, StartFrom, EndFrom: integer);
  var il, iDelta, iTo, iStart, iEnd: longint;
begin
  if ToFrame > StartFrom then ToFrame := StartFrom;
  if EndFrom = -1 then EndFrom := FramesCount else
    if (EndFrom = 0) or (EndFrom < StartFrom) then EndFrom := StartFrom;
  iDelta := 0;
  iTo := FramePos(ToFrame);
  if TagInfo[iTo].TagID = tagShowFrame then inc(iTo);
  if ToFrame = StartFrom
    then iStart := iTo + 1
    else iStart := FramePos(StartFrom) + 1;
  iEnd := FramePos(EndFrom + 1);
  if TagInfo[iEnd].TagID = tagShowFrame then dec(iEnd);

  if iStart < iEnd  then
   for il := iStart to iEnd do
     if TagInfo[il].TagID in [tagDefineBits,
        tagJPEGTables, tagDefineBitsJPEG2, tagDefineBitsJPEG3,
        tagDefineBitsLossless, tagDefineBitsLossless2,
        tagDefineFont, tagDefineFont2, tagDefineFont3, tagDefineSound]
         then
         begin
           TagList.Move(il, iTo + iDelta);
           inc(iDelta);
         end;
end;

procedure TSWFStreamReader.ReadBody(ParseTagData, ParseActionData: boolean);
var
  SWFTag, SWFSubTag: TSWFTagInfo;
  Obj: TSWFObject;
  TmpW: Word;
  CFrame, il: Word;
  BE: TBitsEngine;
  M1Pos, BodyPos: LongInt;
  ET: TSWFByteCodeTag;
  ParseBody: Boolean;
  SndRoot: byte;
begin
  CFrame := 1;
  if fTagList.Count > 0 then fTagList.Clear;
  BodyStream.Position := 0;
  BE:= TBitsEngine.Create(BodyStream);
  SndRoot := 0;
{$IFDEF UNREGISTRED}
  ParseActionData := false;
{$ENDIF}
  While BodyStream.Position < BodyStream.Size do
   begin
    if Assigned(FOnProgress) then FOnProgress(self, Round(BodyStream.Position / BodyStream.Size * 100), pwtReadStream);
    BodyStream.Read(TmpW, 2);
  
    SWFTag := TSWFTagInfo.Create(TmpW shr 6, false);
  
    SWFTag.Position := BodyStream.Position-2;
    SWFTag.BodySize := (TmpW and $3f);
    if SWFTag.BodySize = $3f then
      begin
        SWFTag.isLongSize:=true;
        BodyStream.Read(SWFTag.BodySize, 4);
      end else SWFTag.isLongSize := false;
    SWFTag.FramePlace := CFrame;
    if SWFTag.TagID = 1 then inc(CFrame);
  
    fTagList.Add(SWFTag);
  
    if ParseTagData then
      begin
       if Assigned(FOnParseTagBody) then
         begin
           ParseBody := true;
           FOnParseTagBody(SWFTag, ParseBody);
           if ParseBody then
             SWFTag.SWFObject := GenerateSWFObject(SWFTag.TagID);
         end else SWFTag.SWFObject := GenerateSWFObject(SWFTag.TagID);
      end;

    if (SWFTag.BodySize>0) and (SWFTag.SWFObject<>nil) then
      begin
       case SWFTag.SWFObject.TagID of
        tagPlaceObject2, tagPlaceObject3:
          with TSWFPlaceObject2(SWFTag.SWFObject) do
            begin
              SWFVersion := Version;
              ParseActions := ParseActionData;
            end;
        tagDefineButton, tagDefineButton2:
           TSWFBasedButton(SWFTag.SWFObject).ParseActions := ParseActionData;
        tagDefineSprite:
          with (TSWFDefineSprite(SWFTag.SWFObject)) do
            begin
              SWFVersion := Version;
              ParseActions := ParseActionData;
            end;
        tagSoundStreamBlock:
           TSWFSoundStreamBlock(SWFTag.SWFObject).StreamSoundCompression := SndRoot;
        tagDefineFont2, tagDefineFont3:
           TSWFDefineFont2(SWFTag.SWFObject).SWFVersion := Version;
        tagDefineFontInfo:
           TSWFDefineFontInfo(SWFTag.SWFObject).SWFVersion := Version;
        tagDoAction, tagDoInitAction:
          TSWFDoAction(SWFTag.SWFObject).ParseActions := ParseActionData;
        tagDoABC:
           TSWFDoABC(SWFTag.SWFObject).ParseActions := ParseActionData;
       end;
  
       M1Pos := BodyStream.Position;
       BodyPos := M1Pos;
       SWFTag.SWFObject.BodySize := SWFTag.BodySize;
       try
         SWFTag.SWFObject.ReadFromStream(BE);
       except
         on E: Exception do
          begin
           ET := TSWFByteCodeTag.Create;
           ET.Text := E.Message;
           ET.TagIDFrom := SWFTag.TagID;
           ET.BodySize := SWFTag.BodySize;
           SWFTag.SWFObject.Free;
           SWFTag.SWFObject := ET;
           SWFTag.TagID := ET.TagId;
          end;
       end;

       case SWFTag.SWFObject.TagID of
         tagSoundStreamHead, tagSoundStreamHead2:
           SndRoot := TSWFSoundStreamHead(SWFTag.SWFObject).StreamSoundCompression;

         tagDefineSprite:
          With TSWFDefineSprite(SWFTag.SWFObject) do
          begin
            for il:=0 to ControlTags.Count - 1 do
             begin
               Obj := TSWFObject(ControlTags[il]);
               SWFSubTag := TSWFTagInfo.Create(Obj.TagID, false);
               SWFSubTag.SWFObject := Obj;
               SWFSubTag.selfDestroy := false;
               SWFSubTag.BodySize := Obj.BodySize;
               SWFSubTag.Position := M1Pos;
               inc(M1Pos, Obj.GetFullSize);
               SWFTag.SubTags.Add(SWFSubTag);
             end;
          end;
       end;
       
       if BodyStream.Position <> (BodyPos + SWFTag.BodySize) then
         begin
          BodyStream.Position := (BodyPos + SWFTag.BodySize);
         end;
      end else
      begin
         BodyStream.Position := BodyStream.Position + SWFTag.BodySize;
      end;
   end;
  BE.Free;
end;

procedure TSWFStreamReader.Rename(prefix: string);
var
  il, il2: Integer;
  newname: string;
  CT: TSWFObject;
begin
  if fTagList.Count = 0 then exit;
  For il := 0 to fTagList.Count - 1 do
   begin
    if TagInfo[il].SWFObject <> nil then
    Case TagInfo[il].TagID of
      tagDefineSprite:
        with TSWFDefineSprite(TagInfo[il].SWFObject) do
         if ControlTags.Count > 0 then
         begin
          for il2 := 0 to ControlTags.Count - 1 do
          begin
            CT := TSWFObject(ControlTags[il2]);
            if (CT.TagID in [tagPlaceObject2, tagPlaceObject3]) and TSWFPlaceObject2(CT).PlaceFlagHasName then
              begin
                newname := prefix + TSWFPlaceObject2(CT).Name;
                if Assigned(OnRenameObject) then OnRenameObject(TSWFPlaceObject2(CT), newname);
                TSWFPlaceObject2(CT).Name := newname;
              end;
          end;
         end;
  
      tagPlaceObject2, tagPlaceObject3:
       with TSWFPlaceObject2(TagInfo[il].SWFObject) do
        if PlaceFlagHasName then
        begin
          newname := prefix + Name;
          if Assigned(OnRenameObject) then OnRenameObject(TagInfo[il].SWFObject, newname);
          Name := newname;
        end;
  
      tagExportAssets:
        with TSWFExportAssets(TagInfo[il].SWFObject) do
         if Assets.Count > 0 then
          for il2 := 0 to Assets.Count - 1 do
            begin
              newname := prefix + Assets[il2];
              if Assigned(OnRenameObject) then OnRenameObject(TagInfo[il].SWFObject, newname);
              Assets[il2] := newname;
            end;
    end;
   end;
  
end;

function TSWFStreamReader.Renumber(start: word): Word;
var
  il, il2, il3, NewInd: LongInt;
  ListID: TList;
  Process: Boolean;
  SCR: TSWFStyleChangeRecord;
begin
  Result := start;
  if TagList.Count = 0 then Exit;
  
  ListID := TList.Create;
  for il := 0 to TagList.Count - 1 do
   With TagInfo[il] do
    begin
      Process := SWFObject <> nil;
      if Process and Assigned(FOnRenumberTag) then OnRenumberTag(SWFObject, Process);
      if Process then
      Case TagID of
         tagDefineShape, tagDefineShape2, tagDefineShape3, tagDefineShape4:
           with TSWFDefineShape(SWFObject) do
             ShapeId := start + ListID.Add(Pointer(Longint(ShapeId)));
  
         tagDefineMorphShape, tagDefineMorphShape2:
           with TSWFDefineMorphShape(SWFObject) do
             CharacterID := start + ListID.Add(Pointer(Longint(CharacterID)));
  
         tagDefineBits, tagDefineBitsJPEG2, tagDefineBitsJPEG3,
         tagDefineBitsLossless, tagDefineBitsLossless2:
           with TSWFImageTag(SWFObject) do
             CharacterID := start + ListID.Add(Pointer(Longint(CharacterID)));
  
         tagDefineFont, tagDefineFont2, tagDefineFont3:
           with TSWFDefineFont(SWFObject) do
             FontID := start + ListID.Add(Pointer(Longint(FontID)));
  
         tagDefineText, tagDefineText2:
           with TSWFDefineText(SWFObject) do
             CharacterID := start + ListID.Add(Pointer(Longint(CharacterID)));
  
         tagDefineEditText:
           with TSWFDefineEditText(SWFObject) do
             CharacterID := start + ListID.Add(Pointer(Longint(CharacterID)));
  
         tagDefineSound:
           with TSWFDefineSound(SWFObject) do
             SoundId := start + ListID.Add(Pointer(Longint(SoundId)));
  
         tagDefineButton, tagDefineButton2:
           with TSWFDefineButton(SWFObject) do
             ButtonId := start + ListID.Add(Pointer(Longint(ButtonId)));
  
         tagDefineSprite:
           with TSWFDefineSprite(SWFObject) do
             SpriteID := start + ListID.Add(Pointer(Longint(SpriteID)));
  
         tagDefineVideoStream:
           with TSWFDefineVideoStream(SWFObject) do
             CharacterID := start + ListID.Add(Pointer(Longint(CharacterID)));
  
         tagImportAssets, tagImportAssets2:
           with TSWFImportAssets(SWFObject) do
            if Assets.Count > 0 then
             for il2 := 0 to Assets.Count - 1 do
              begin
                ListID.Add(Assets.Objects[il2]);
                Assets.Objects[il2] := Pointer(Longint(start + ListID.Count - 1));
              end;
      end;
    end;
  
  for il := 0 to TagList.Count - 1 do
   With TagInfo[il] do
    Case TagID of
       tagExportAssets:
         with TSWFExportAssets(SWFObject) do
          if Assets.Count > 0 then
           for il2 := 0 to Assets.Count - 1 do
             begin
               NewInd := ListID.IndexOf(Assets.Objects[il2]);
               if NewInd > -1 then
                 Assets.Objects[il2] :=  Pointer(Longint(start + NewInd));
             end;

       tagDoInitAction:
         with TSWFDoInitAction(SWFObject) do
           begin
             NewInd := ListID.IndexOf(Pointer(Longint(SpriteID)));
             if NewInd > -1 then SpriteID := start + NewInd;
           end;

       tagPlaceObject:
         with TSWFPlaceObject(SWFObject) do
           begin
             NewInd := ListID.IndexOf(Pointer(Longint(CharacterId)));
             if NewInd > -1 then CharacterId := start + NewInd;
           end;

       tagPlaceObject2, tagPlaceObject3:
         with TSWFPlaceObject2(SWFObject) do
          if PlaceFlagHasCharacter then
            begin
             NewInd := ListID.IndexOf(Pointer(Longint(CharacterId)));
             if NewInd > -1 then CharacterId := start + NewInd;
            end;

       tagRemoveObject:
          with TSWFRemoveObject(SWFObject) do
           begin
             NewInd := ListID.IndexOf(Pointer(Longint(CharacterId)));
             if NewInd > -1 then CharacterId := start + NewInd;
           end;

       tagDefineFontInfo, tagDefineFontInfo2:
         with TSWFDefineFontInfo(SWFObject) do
          begin
           NewInd := ListID.IndexOf(Pointer(Longint(FontID)));
           if NewInd > -1 then FontID := start + NewInd;
          end;

       tagDefineText, tagDefineText2:
         with TSWFDefineText(SWFObject) do
          if TextRecords.Count > 0 then
           for il2 := 0 to TextRecords.Count - 1 do
            if TextRecord[il2].StyleFlagsHasFont then
             begin
              NewInd := ListID.IndexOf(Pointer(Longint(TextRecord[il2].FontID)));
              if NewInd > -1 then TextRecord[il2].FontID := start + NewInd;
             end;

       tagDefineEditText:
         with TSWFDefineEditText(SWFObject) do
          begin
           NewInd := ListID.IndexOf(Pointer(Longint(FontID)));
           if NewInd > -1 then FontID := start + NewInd;
          end;

       tagDefineFontAlignZones:
         with TSWFDefineFontAlignZones(SWFObject) do
          begin
            NewInd := ListID.IndexOf(Pointer(Longint(FontID)));
            if NewInd > -1 then FontID := start + NewInd;
          end;

       tagCSMTextSettings:
         with TSWFCSMTextSettings(SWFObject) do
          begin
            NewInd := ListID.IndexOf(Pointer(Longint(TextID)));
            if NewInd > -1 then TextID := start + NewInd;
          end;

       tagStartSound:
         with TSWFStartSound(SWFObject) do
          begin
           NewInd := ListID.IndexOf(Pointer(Longint(SoundID)));
           if NewInd > -1 then SoundID := start + NewInd;
          end;
  
       tagDefineButton, tagDefineButton2:
         with TSWFBasedButton(SWFObject) do
          if ButtonRecords.Count > 0 then
           for il2 := 0 to ButtonRecords.Count - 1 do
            begin
             NewInd := ListID.IndexOf(Pointer(Longint(ButtonRecord[il2].CharacterID)));
             if NewInd > -1 then ButtonRecord[il2].CharacterID := start + NewInd;
            end;
  
       tagDefineButtonSound:
         with TSWFDefineButtonSound(SWFObject) do
          begin
           NewInd := ListID.IndexOf(Pointer(Longint(ButtonId)));
           if NewInd > -1 then ButtonId := start + NewInd;
           if HasIdleToOverUp then
             begin
              NewInd := ListID.IndexOf(Pointer(Longint(SndIdleToOverUp.SoundId)));
              if NewInd > -1 then SndIdleToOverUp.SoundId := start + NewInd;
             end;
           if HasOverDownToOverUp then
             begin
              NewInd := ListID.IndexOf(Pointer(Longint(SndOverDownToOverUp.SoundId)));
              if NewInd > -1 then SndOverDownToOverUp.SoundId := start + NewInd;
             end;
           if HasOverUpToIdle then
             begin
              NewInd := ListID.IndexOf(Pointer(Longint(SndOverUpToIdle.SoundId)));
              if NewInd > -1 then SndOverUpToIdle.SoundId := start + NewInd;
             end;
           if HasOverUpToOverDown then
             begin
              NewInd := ListID.IndexOf(Pointer(Longint(SndOverUpToOverDown.SoundId)));
              if NewInd > -1 then SndOverUpToOverDown.SoundId := start + NewInd;
             end;
          end;
  
       tagDefineButtonCxform:
         with TSWFDefineButtonCxform(SWFObject) do
          begin
           NewInd := ListID.IndexOf(Pointer(Longint(ButtonId)));
           if NewInd > -1 then ButtonId := start + NewInd;
          end;
  
       tagVideoFrame:
         with TSWFVideoFrame(SWFObject) do
          begin
           NewInd := ListID.IndexOf(Pointer(Longint(StreamID)));
           if NewInd > -1 then StreamID := start + NewInd;
          end;
  
       tagDefineSprite:
         with TSWFDefineSprite(SWFObject) do
          for il2 := 0 to ControlTags.Count - 1 do
           case ControlTag[il2].TagID of
            tagPlaceObject:
              with TSWFPlaceObject(ControlTag[il2]) do
               begin
                NewInd := ListID.IndexOf(Pointer(Longint(CharacterId)));
                if NewInd > -1 then CharacterId := start + NewInd;
               end;

            tagPlaceObject2, tagPlaceObject3:
              with TSWFPlaceObject2(ControlTag[il2]) do
               if PlaceFlagHasCharacter then
                begin
                 NewInd := ListID.IndexOf(Pointer(Longint(CharacterId)));
                 if NewInd > -1 then CharacterId := start + NewInd;
                end;
  
            tagStartSound:
              with TSWFStartSound(ControlTag[il2]) do
               begin
                NewInd := ListID.IndexOf(Pointer(Longint(SoundID)));
                if NewInd > -1 then SoundID := start + NewInd;
               end;

            tagRemoveObject:
               with TSWFRemoveObject(ControlTag[il2]) do
               begin
                 NewInd := ListID.IndexOf(Pointer(Longint(CharacterId)));
                 if NewInd > -1 then CharacterId := start + NewInd;
               end;

            tagVideoFrame:
              with TSWFVideoFrame(ControlTag[il2]) do
              begin
                NewInd := ListID.IndexOf(Pointer(Longint(StreamID)));
                if NewInd > -1 then StreamID := start + NewInd;
              end;

           end;
  
       tagDefineShape, tagDefineShape2, tagDefineShape3, tagDefineShape4:
         with TSWFDefineShape(SWFObject) do
          begin
           if FillStyles.Count > 0 then
            for il2 := 0 to FillStyles.Count - 1 do
             if TSWFFillStyle(FillStyles[il2]).SWFFillType in
                [SWFFillTileBitmap, SWFFillClipBitmap, SWFFillNonSmoothTileBitmap, SWFFillNonSmoothClipBitmap] then
              with TSWFImageFill(FillStyles[il2]) do
               begin
                NewInd := ListID.IndexOf(Pointer(Longint(ImageID)));
                if NewInd > -1 then ImageID := start + NewInd;
               end;

           if Edges.Count > 0 then
            for il3 := 0 to Edges.Count - 1 do
             if (EdgeRecord[il3].ShapeRecType = StyleChangeRecord) then
              begin
                SCR := TSWFStyleChangeRecord(Edges[il3]);
                if SCR.StateNewStyles then
                  for il2 := 0 to SCR.NewFillStyles.Count - 1 do
                    if TSWFFillStyle(SCR.NewFillStyles[il2]).SWFFillType in
                       [SWFFillTileBitmap, SWFFillClipBitmap, SWFFillNonSmoothTileBitmap, SWFFillNonSmoothClipBitmap] then
                     with TSWFImageFill(SCR.NewFillStyles[il2]) do
                      begin
                       NewInd := ListID.IndexOf(Pointer(Longint(ImageID)));
                       if NewInd > -1 then ImageID := start + NewInd;
                      end;
                     end;
          end;

       tagDefineMorphShape:
         with TSWFDefineMorphShape(SWFObject) do
          if MorphFillStyles.Count > 0 then
           for il2 := 0 to MorphFillStyles.Count - 1 do
            if TSWFMorphFillStyle(MorphFillStyles[il2]).SWFFillType in
               [SWFFillTileBitmap, SWFFillClipBitmap, SWFFillNonSmoothTileBitmap, SWFFillNonSmoothClipBitmap] then
             with TSWFMorphImageFill(MorphFillStyles[il2]) do
              begin
               NewInd := ListID.IndexOf(Pointer(Longint(ImageID)));
               if NewInd > -1 then ImageID := start + NewInd;
              end;
    end;
  
  Result := start + ListID.Count;
  ListID.Free;
end;



end.

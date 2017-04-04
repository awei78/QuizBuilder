{ *************************************************************************** }
{                                                                             }
{ Audio Tools Library (Freeware)                                              }
{ Class TMPEGaudio - for manipulating with MPEG audio file information        }
{                                                                             }
{ Uses:                                                                       }
{   - Class TID3v1                                                            }
{   - Class TID3v2                                                            }
{                                                                             }
{ Copyright (c) 2001 by Jurgen Faul                                           }
{ E-mail: jfaul@gmx.de                                                        }
{ http://jfaul.de/atl                                                         }
{                                                                             }
{ Version 1.0 (31 August 2001)                                                }
{   - Support for MPEG audio (versions 1, 2, 2.5, layers I, II, III)          }
{   - Support for Xing & FhG VBR                                              }
{   - Ability to guess audio encoder (Xing, FhG, LAME, Blade, GoGo, Shine)    }
{   - Class TID3v1: reading & writing support for ID3v1.x tags                }
{   - Class TID3v2: reading support for ID3v2.3.x tags                        }
{                                                                             }
{ 11 mar 2007  - Add ReadFromStream mathod by DelphiFlash.com                 }
{ 10 mar 2008  - some bugs fixed                                              }
{                                                                             }
{ *************************************************************************** }

unit MPEGaudio;

interface

uses
  Windows, Classes, SysUtils, Contnrs;

const
  { Table for bit rates }
  MPEG_BIT_RATE: array [0..3, 0..3, 0..15] of Word =
    (
    { For MPEG 2.5 }
    ((0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    (0, 8, 16, 24, 32, 40, 48, 56, 64, 80, 96, 112, 128, 144, 160, 0),
    (0, 8, 16, 24, 32, 40, 48, 56, 64, 80, 96, 112, 128, 144, 160, 0),
    (0, 32, 48, 56, 64, 80, 96, 112, 128, 144, 160, 176, 192, 224, 256, 0)),
    { Reserved }
    ((0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)),
    { For MPEG 2 }
    ((0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    (0, 8, 16, 24, 32, 40, 48, 56, 64, 80, 96, 112, 128, 144, 160, 0),
    (0, 8, 16, 24, 32, 40, 48, 56, 64, 80, 96, 112, 128, 144, 160, 0),
    (0, 32, 48, 56, 64, 80, 96, 112, 128, 144, 160, 176, 192, 224, 256, 0)),
    { For MPEG 1 }
    ((0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    (0, 32, 40, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320, 0),
    (0, 32, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320, 384, 0),
    (0, 32, 64, 96, 128, 160, 192, 224, 256, 288, 320, 352, 384, 416, 448, 0))
    );

  { Sample rate codes }
  MPEG_SAMPLE_RATE_LEVEL_3 = 0;                                     { Level 3 }
  MPEG_SAMPLE_RATE_LEVEL_2 = 1;                                     { Level 2 }
  MPEG_SAMPLE_RATE_LEVEL_1 = 2;                                     { Level 1 }
  MPEG_SAMPLE_RATE_UNKNOWN = 3;                               { Unknown value }

  { Table for sample rates }
  MPEG_SAMPLE_RATE: array [0..3, 0..3] of Word =
    (
    (11025, 12000, 8000, 0),                                   { For MPEG 2.5 }
    (0, 0, 0, 0),                                                  { Reserved }
    (22050, 24000, 16000, 0),                                    { For MPEG 2 }
    (44100, 48000, 32000, 0)                                     { For MPEG 1 }
    );

  { VBR header ID for Xing/FhG }
  VBR_ID_XING = 'Xing';                                         { Xing VBR ID }
  VBR_ID_FHG = 'VBRI';                                           { FhG VBR ID }
  VBR_ID_INFO = 'Info';

  { MPEG version codes }
  MPEG_VERSION_2_5 = 0;                                            { MPEG 2.5 }
  MPEG_VERSION_UNKNOWN = 1;                                 { Unknown version }
  MPEG_VERSION_2 = 2;                                                { MPEG 2 }
  MPEG_VERSION_1 = 3;                                                { MPEG 1 }

  { MPEG version names }
  MPEG_VERSION: array [0..3] of string =
    ('MPEG 2.5', 'MPEG ?', 'MPEG 2', 'MPEG 1');

  { MPEG layer codes }
  MPEG_LAYER_UNKNOWN = 0;                                     { Unknown layer }
  MPEG_LAYER_III = 1;                                             { Layer III }
  MPEG_LAYER_II = 2;                                               { Layer II }
  MPEG_LAYER_I = 3;                                                 { Layer I }

  { MPEG layer names }
  MPEG_LAYER: array [0..3] of string =
    ('Layer ?', 'Layer III', 'Layer II', 'Layer I');

  { Channel mode codes }
  MPEG_CM_STEREO = 0;                                                { Stereo }
  MPEG_CM_JOINT_STEREO = 1;                                    { Joint Stereo }
  MPEG_CM_DUAL_CHANNEL = 2;                                    { Dual Channel }
  MPEG_CM_MONO = 3;                                                    { Mono }
  MPEG_CM_UNKNOWN = 4;                                         { Unknown mode }

  { Channel mode names }
  MPEG_CM_MODE: array [0..4] of string =
    ('Stereo', 'Joint Stereo', 'Dual Channel', 'Mono', 'Unknown');

  { Extension mode codes (for Joint Stereo) }
  MPEG_CM_EXTENSION_OFF = 0;                        { IS and MS modes set off }
  MPEG_CM_EXTENSION_IS = 1;                             { Only IS mode set on }
  MPEG_CM_EXTENSION_MS = 2;                             { Only MS mode set on }
  MPEG_CM_EXTENSION_ON = 3;                          { IS and MS modes set on }
  MPEG_CM_EXTENSION_UNKNOWN = 4;                     { Unknown extension mode }

  { Emphasis mode codes }
  MPEG_EMPHASIS_NONE = 0;                                              { None }
  MPEG_EMPHASIS_5015 = 1;                                          { 50/15 ms }
  MPEG_EMPHASIS_UNKNOWN = 2;                               { Unknown emphasis }
  MPEG_EMPHASIS_CCIT = 3;                                         { CCIT J.17 }

  { Emphasis names }
  MPEG_EMPHASIS: array [0..3] of string =
    ('None', '50/15 ms', 'Unknown', 'CCIT J.17');

  { Encoder codes }
  MPEG_ENCODER_UNKNOWN = 0;                                 { Unknown encoder }
  MPEG_ENCODER_XING = 1;                                               { Xing }
  MPEG_ENCODER_FHG = 2;                                                 { FhG }
  MPEG_ENCODER_LAME = 3;                                               { LAME }
  MPEG_ENCODER_BLADE = 4;                                             { Blade }
  MPEG_ENCODER_GOGO = 5;                                               { GoGo }
  MPEG_ENCODER_SHINE = 6;                                             { Shine }

  { Encoder names }
  MPEG_ENCODER: array [0..6] of string =
    ('Unknown', 'Xing', 'FhG', 'LAME', 'Blade', 'GoGo', 'Shine');

  TAG_VERSION_1_0 = 1;                                { Index for ID3v1.0 tag }
  TAG_VERSION_1_1 = 2;                                { Index for ID3v1.1 tag }
  TAG_VERSION_2_3 = 3;                               { Code for ID3v2.3.0 tag }

  { Max. number of supported tag frames }
  ID3V2_FRAME_COUNT = 7;

  { Names of supported tag frames }
  ID3V2_FRAME: array [1..ID3V2_FRAME_COUNT] of string =
    ('TIT2', 'TPE1', 'TALB', 'TRCK', 'TYER', 'TCON', 'COMM');

  MAX_MUSIC_GENRES = 148;                       { Max. number of music genres }
  DEFAULT_GENRE = 255;                              { Index for default genre }

var
  MusicGenre: array [0..MAX_MUSIC_GENRES - 1] of PChar =        { Genre names }
    ({ Standard genres }
     'Blues', 'Classic Rock', 'Country', 'Dance', 'Disco', 'Funk', 'Grunge', 'Hip-Hop', 'Jazz', 'Metal',
     'New Age',  'Oldies', 'Other', 'Pop', 'R&B', 'Rap', 'Reggae', 'Rock', 'Techno', 'Industrial',
     'Alternative', 'Ska', 'Death Metal', 'Pranks', 'Soundtrack', 'Euro-Techno', 'Ambient', 'Trip-Hop',
     'Vocal', 'Jazz+Funk', 'Fusion', 'Trance', 'Classical', 'Instrumental', 'Acid', 'House', 'Game',
     'Sound Clip', 'Gospel', 'Noise', 'AlternRock', 'Bass', 'Soul', 'Punk', 'Space', 'Meditative',
     'Instrumental Pop', 'Instrumental Rock', 'Ethnic', 'Gothic', 'Darkwave', 'Techno-Industrial',
     'Electronic', 'Pop-Folk', 'Eurodance', 'Dream', 'Southern Rock', 'Comedy', 'Cult', 'Gangsta',
     'Top 40', 'Christian Rap', 'Pop/Funk', 'Jungle', 'Native American', 'Cabaret', 'New Wave',
     'Psychadelic', 'Rave', 'Showtunes', 'Trailer', 'Lo-Fi', 'Tribal', 'Acid Punk', 'Acid Jazz',
     'Polka', 'Retro', 'Musical', 'Rock & Roll', 'Hard Rock',
     { Extended genres }
     'Folk', 'Folk-Rock', 'National Folk', 'Swing', 'Fast Fusion', 'Bebob', 'Latin', 'Revival',
     'Celtic', 'Bluegrass', 'Avantgarde', 'Gothic Rock', 'Progessive Rock', 'Psychedelic Rock',
     'Symphonic Rock', 'Slow Rock', 'Big Band', 'Chorus', 'Easy Listening', 'Acoustic', 'Humour',
     'Speech', 'Chanson', 'Opera', 'Chamber Music', 'Sonata', 'Symphony', 'Booty Bass', 'Primus',
     'Porn Groove', 'Satire', 'Slow Jam', 'Club', 'Tango', 'Samba', 'Folklore', 'Ballad', 'Power Ballad',
     'Rhythmic Soul', 'Freestyle', 'Duet', 'Punk Rock', 'Drum Solo', 'A capella', 'Euro-House',
     'Dance Hall', 'Goa', 'Drum & Bass', 'Club-House', 'Hardcore', 'Terror', 'Indie', 'BritPop',
     'Negerpunk', 'Polsk Punk', 'Beat', 'Christian Gangsta Rap', 'Heavy Metal', 'Black Metal',
     'Crossover', 'Contemporary Christian', 'Christian Rock', 'Merengue', 'Salsa', 'Trash Metal',
     'Anime', 'JPop', 'Synthpop');

type
  { Used in TID3v1 class }
  String04 = string[4];                          { String with max. 4 symbols }
  String30 = string[30];                        { String with max. 30 symbols }


  { Xing/FhG VBR header data }
  VBRData = record
    Found: Boolean;                                { True if VBR header found }
    ID: array [1..4] of Char;                   { Header ID: "Xing" or "VBRI" }
    Frames: longint;                                 { Total number of frames }
    Bytes: longint;                                   { Total number of bytes }
    Scale: Byte;                                         { VBR scale (1..100) }
    VendorID: array [1..8] of Char;                  { Vendor ID (if present) }
  end;

  { MPEG frame header data}
  FrameData = record
    Found: Boolean;                                     { True if frame found }
    Position: Integer;                           { Frame position in the file }
    Size: Word;                                          { Frame size (bytes) }
    Empty: Boolean;                       { True if no significant frame data }
    Data: array [1..4] of Byte;                 { The whole frame header data }
    VersionID: Byte;                                        { MPEG version ID }
    LayerID: Byte;                                            { MPEG layer ID }
    ProtectionBit: Boolean;                        { True if protected by CRC }
    BitRateID: Word;                                            { Bit rate ID }
    SampleRateID: Word;                                      { Sample rate ID }
    PaddingBit: Boolean;                               { True if frame padded }
    PrivateBit: Boolean;                                  { Extra information }
    ModeID: Byte;                                           { Channel mode ID }
    ModeExtensionID: Byte;             { Mode extension ID (for Joint Stereo) }
    CopyrightBit: Boolean;                        { True if audio copyrighted }
    OriginalBit: Boolean;                            { True if original media }
    EmphasisID: Byte;                                           { Emphasis ID }
  end;

  { Real structure of ID3v1 tag }
  TagID3v1 = record
    Header: array [1..3] of Char;                { Tag header - must be "TAG" }
    Title: array [1..30] of Char;                                { Title data }
    Artist: array [1..30] of Char;                              { Artist data }
    Album: array [1..30] of Char;                                { Album data }
    Year: array [1..4] of Char;                                   { Year data }
    Comment: array [1..30] of Char;                            { Comment data }
    Genre: Byte;                                                 { Genre data }
  end;

    { ID3v2 header data - for internal use }
  TagID3v2 = record
    { Real structure of ID3v2 header }
    ID: array [1..3] of Char;                                  { Always "ID3" }
    Version: Byte;                                           { Version number }
    Revision: Byte;                                         { Revision number }
    Flags: Byte;                                               { Flags of tag }
    Size: array [1..4] of Byte;                   { Tag size excluding header }
    { Extended data }
    FileSize: Integer;                                    { File size (bytes) }
    Frame: array [1..ID3V2_FRAME_COUNT] of string;  { Information from frames }
  end;

  TID3v1 = class(TObject)
    private
      { Private declarations }
      FExists: Boolean;
      FVersionID: Byte;
      FTitle: String30;
      FArtist: String30;
      FAlbum: String30;
      FYear: String04;
      FComment: String30;
      FTrack: Byte;
      FGenreID: Byte;
    FSize: longint;
      procedure FSetTitle(const NewTitle: String30);
      procedure FSetArtist(const NewArtist: String30);
      procedure FSetAlbum(const NewAlbum: String30);
      procedure FSetYear(const NewYear: String04);
      procedure FSetComment(const NewComment: String30);
      procedure FSetTrack(const NewTrack: Byte);
      procedure FSetGenreID(const NewGenreID: Byte);
      function FGetGenre: string;
    public
      { Public declarations }
      constructor Create;                                     { Create object }
      procedure ResetData;                                   { Reset all data }
      function ReadFromFile(const FileName: string): Boolean;      { Load tag }
      function ReadFromStream(Src: TStream): Boolean;
      property Size: longint read FSize;
      property Exists: Boolean read FExists;              { True if tag found }
      property VersionID: Byte read FVersionID;                { Version code }
      property Title: String30 read FTitle write FSetTitle;      { Song title }
      property Artist: String30 read FArtist write FSetArtist;  { Artist name }
      property Album: String30 read FAlbum write FSetAlbum;      { Album name }
      property Year: String04 read FYear write FSetYear;               { Year }
      property Comment: String30 read FComment write FSetComment;   { Comment }
      property Track: Byte read FTrack write FSetTrack;        { Track number }
      property GenreID: Byte read FGenreID write FSetGenreID;    { Genre code }
      property Genre: string read FGetGenre;                     { Genre name }
  end;

  
  TID3v2 = class(TObject)
    private
      { Private declarations }
      FExists: Boolean;
      FVersionID: Byte;
      FSize: Integer;
      FTitle: string;
      FArtist: string;
      FAlbum: string;
      FTrack: Byte;
      FYear: string;
      FGenre: string;
      FComment: string;
    public
      { Public declarations }
      constructor Create;                                     { Create object }
      procedure ResetData;                                   { Reset all data }
      function ReadFromStream(Src: TStream): boolean;
      function ReadFromFile(const FileName: string): Boolean;      { Load tag }
      property Exists: Boolean read FExists;              { True if tag found }
      property VersionID: Byte read FVersionID;                { Version code }
      property Size: Integer read FSize;                     { Total tag size }
      property Title: string read FTitle;                        { Song title }
      property Artist: string read FArtist;                     { Artist name }
      property Album: string read FAlbum;                        { Album name }
      property Track: Byte read FTrack;                        { Track number }
      property Year: string read FYear;                                { Year }
      property Genre: string read FGenre;                        { Genre name }
      property Comment: string read FComment;                       { Comment }
  end;

  TMP3FrameInfo = class (TObject)
  private
    FPosition: longint;
    FSize: Word;
    FisSound: boolean;
    FHeader: DWord;
  public
    property Header: DWord read FHeader write FHeader;
    property Position: longint read FPosition write FPosition;
    property Size: Word read FSize write FSize;
    property isSound: boolean read FisSound write FisSound;
  end;

  { Class TMPEGaudio }
  TMPEGaudio = class(TObject)
    private
      { Private declarations }
      FFramesPos: TObjectList;
      FFileLength: Integer;
      FWaveHeader: Boolean;
      FVBR: VBRData;
      FFrame: FrameData;
      FID3v1: TID3v1;
      FID3v2: TID3v2;
    FSoundFrameCount: longint;
      procedure FResetData;
      function FGetVersion: string;
      function FGetLayer: string;
      function FGetBitRate: Word;
      function FGetSampleRate: Word;
      function FGetChannelMode: string;
      function FGetEmphasis: string;
      function FGetFrames: Integer;
      function FGetDuration: Double;
      function FGetVBREncoderID: Byte;
      function FGetCBREncoderID: Byte;
      function FGetEncoderID: Byte;
      function FGetEncoder: string;
      function FGetValid: Boolean;
    function GetMP3FrameInfo(index: Integer): TMP3FrameInfo;
    protected
      procedure EnumFrames(Src: TStream);
    public
      SkipCount: integer;
      { Public declarations }
      constructor Create;                                     { Create object }
      destructor Destroy; override;                          { Destroy object }
      function ReadFromFile(const FileName: string): Boolean;     { Load data }
      function ReadFromStream(Src: TStream): boolean;
      function isMP3File(const FileName: string): Boolean;   {check MP3 format}
      property FileLength: Integer read FFileLength;    { File length (bytes) }
      property FrameInfo[index: longint]: TMP3FrameInfo read GetMP3FrameInfo;
      property VBR: VBRData read FVBR;                      { VBR header data }
      property FirstFrame: FrameData read FFrame;         { Frame header data }
      property ID3v1: TID3v1 read FID3v1;                    { ID3v1 tag data }
      property ID3v2: TID3v2 read FID3v2;                    { ID3v2 tag data }
      property Version: string read FGetVersion;          { MPEG version name }
      property Layer: string read FGetLayer;                { MPEG layer name }
      property BitRate: Word read FGetBitRate;            { Bit rate (kbit/s) }
      property SampleRate: Word read FGetSampleRate;       { Sample rate (hz) }
      property ChannelMode: string read FGetChannelMode;  { Channel mode name }
      property Emphasis: string read FGetEmphasis;            { Emphasis name }
      property FrameCount: longint read FGetFrames;  { Total number of frames }
      property SoundFrameCount: longint read FSoundFrameCount;
      property Duration: Double read FGetDuration;      { Song duration (sec) }
      property EncoderID: Byte read FGetEncoderID;       { Guessed encoder ID }
      property Encoder: string read FGetEncoder;       { Guessed encoder name }
      property Valid: Boolean read FGetValid;       { True if MPEG file valid }
  end;

  procedure DecodeHeader(const HeaderData: array of Byte; var Frame: FrameData);
  function GetFrameLength(const Frame: FrameData): Word;

implementation
type
  MP3FrameHeader = record
    ID: array [1..4] of Char;                                      { Frame ID }
    Size: Integer;                                    { Size excluding header }
    Flags: Word;                                                      { Flags }
  end;

const
  { Limitation constants }
  MAX_MPEG_FRAME_LENGTH = 1729;                      { Max. MPEG frame length }
  MIN_MPEG_BIT_RATE = 8;                                { Min. bit rate value }
  MAX_MPEG_BIT_RATE = 448;                              { Max. bit rate value }
  MIN_ALLOWED_DURATION = 0.1;                      { Min. song duration value }

  { VBR Vendor ID strings }
  VBR_VENDOR_ID_LAME = 'LAME';                                     { For LAME }
  VBR_VENDOR_ID_GOGO_NEW = 'GOGO';                           { For GoGo (New) }
  VBR_VENDOR_ID_GOGO_OLD = 'MPGE';                           { For GoGo (Old) }

  VBR_Lame_Track = 'UUUU';
{ ********************* Auxiliary functions & procedures ******************** }

function WaveHeaderPresent(const Index: Integer; Data: array of Byte): Boolean;
begin
  { Check for WAV header }
  Result :=
    (Chr(Data[Index + 8]) = 'W') and
    (Chr(Data[Index + 9]) = 'A') and
    (Chr(Data[Index + 10]) = 'V') and
    (Chr(Data[Index + 11]) = 'E');
end;

{ --------------------------------------------------------------------------- }

function IsFrameHeader(const HeaderData: array of Byte): Boolean;
begin
  { Check for valid frame header }
  if ((HeaderData[0] and $FF) <> $FF) or
    ((HeaderData[1] and $E0) <> $E0) or
    (((HeaderData[1] shr 3) and 3) = 1) or
    (((HeaderData[1] shr 1) and 3) = 0) or
    ((HeaderData[2] and $F0) = $F0) or
    ((HeaderData[2] and $F0) = 0) or
    (((HeaderData[2] shr 2) and 3) = 3) or
    ((HeaderData[3] and 3) = 2) then
    Result := false
  else
    Result := true;
end;

{ --------------------------------------------------------------------------- }

procedure DecodeHeader(const HeaderData: array of Byte; var Frame: FrameData);
begin
  { Decode frame header data }
  Move(HeaderData, Frame.Data, SizeOf(Frame.Data));
  Frame.VersionID := (HeaderData[1] shr 3) and 3;
  Frame.LayerID := (HeaderData[1] shr 1) and 3;
  Frame.ProtectionBit := (HeaderData[1] and 1) <> 1;
  Frame.BitRateID := HeaderData[2] shr 4;
  Frame.SampleRateID := (HeaderData[2] shr 2) and 3;
  Frame.PaddingBit := ((HeaderData[2] shr 1) and 1) = 1;
  Frame.PrivateBit := (HeaderData[2] and 1) = 1;
  Frame.ModeID := (HeaderData[3] shr 6) and 3;
  Frame.ModeExtensionID := (HeaderData[3] shr 4) and 3;
  Frame.CopyrightBit := ((HeaderData[3] shr 3) and 1) = 1;
  Frame.OriginalBit := ((HeaderData[3] shr 2) and 1) = 1;
  Frame.EmphasisID := HeaderData[3] and 3;
end;

{ --------------------------------------------------------------------------- }

function ValidFrameAt(const Index: Word; Data: array of Byte): Boolean;
var
  HeaderData: array [1..4] of Byte;
begin
  { Check for frame at given position }
  HeaderData[1] := Data[Index];
  HeaderData[2] := Data[Index + 1];
  HeaderData[3] := Data[Index + 2];
  HeaderData[4] := Data[Index + 3];
  if IsFrameHeader(HeaderData) then Result := true
  else Result := false;
end;

{ --------------------------------------------------------------------------- }

function GetCoefficient(const Frame: FrameData): Byte;
begin
  { Get frame coefficient }
  if Frame.VersionID = MPEG_VERSION_1 then
    if Frame.LayerID = MPEG_LAYER_I then Result := 48
    else Result := 144
  else
    if Frame.LayerID = MPEG_LAYER_I then Result := 24
    else Result := 72;
end;

{ --------------------------------------------------------------------------- }

function GetBitRate(const Frame: FrameData): Word;
begin
  { Get bit rate }
  Result := MPEG_BIT_RATE[Frame.VersionID, Frame.LayerID, Frame.BitRateID];
end;

{ --------------------------------------------------------------------------- }

function GetSampleRate(const Frame: FrameData): Word;
begin
  { Get sample rate }
  Result := MPEG_SAMPLE_RATE[Frame.VersionID, Frame.SampleRateID];
end;

{ --------------------------------------------------------------------------- }

function GetPadding(const Frame: FrameData): Byte;
begin
  { Get frame padding }
  if Frame.PaddingBit then
    if Frame.LayerID = MPEG_LAYER_I then Result := 4
    else Result := 1
  else Result := 0;
end;

{ --------------------------------------------------------------------------- }

function GetFrameLength(const Frame: FrameData): Word;
var
  Coefficient, BitRate, SampleRate, Padding: Word;
begin
  { Calculate MPEG frame length }

  Coefficient := GetCoefficient(Frame);
  BitRate := GetBitRate(Frame);
  SampleRate := GetSampleRate(Frame);
  Padding := GetPadding(Frame);
  Result := Trunc(Coefficient * BitRate * 1000 / SampleRate) + Padding;
  
{  if Frame.LayerID = MPEG_LAYER_I then
    Result := Trunc((12 * BitRate * 1000 / SampleRate + Padding) * 4)
    else
    Result := trunc(144 * BitRate * 1000 / SampleRate) + Padding;
}

end;

{ --------------------------------------------------------------------------- }

function FrameIsEmpty(const Index: Word; Data: array of Byte): Boolean;
begin
  { Get true if frame has no significant data }
  Result :=
    (Data[Index] = 0) and
    (Data[Index + 1] = 0) and
    (Data[Index + 2] = 0) and
    (Data[Index + 3] = 0) and
    (Data[Index + 4] = 0) and
    (Data[Index + 5] = 0);
end;

{ --------------------------------------------------------------------------- }

function GetXingInfo(const Index: Word; Data: array of Byte): VBRData;
begin
  { Extract Xing VBR info at given position }
  FillChar(Result, SizeOf(Result), 0);
  Result.Found := true;
  Result.ID := VBR_ID_XING;
  Result.Frames := Data[Index + 8] shl 24 + Data[Index + 9] shl 16 +
                   Data[Index + 10] shl 8 + Data[Index + 11];
  Result.Bytes :=  Data[Index + 12] shl 24 + Data[Index + 13] shl 16 +
                   Data[Index + 14]  shl 8 + Data[Index + 15];
  Result.Scale := Data[Index + 119];
  { Encoder ID can be not present }
  Result.VendorID[1] := Chr(Data[Index + 120]);
  Result.VendorID[2] := Chr(Data[Index + 121]);
  Result.VendorID[3] := Chr(Data[Index + 122]);
  Result.VendorID[4] := Chr(Data[Index + 123]);
  Result.VendorID[5] := Chr(Data[Index + 124]);
  Result.VendorID[6] := Chr(Data[Index + 125]);
  Result.VendorID[7] := Chr(Data[Index + 126]);
  Result.VendorID[8] := Chr(Data[Index + 127]);
end;

{ --------------------------------------------------------------------------- }

function GetFhGInfo(const Index: Word; Data: array of Byte): VBRData;
begin
  { Extract FhG VBR info at given position }
  FillChar(Result, SizeOf(Result), 0);
  Result.Found := true;
  Result.ID := VBR_ID_FHG;
  Result.Scale :=  Data[Index + 9];
  Result.Bytes :=  Data[Index + 10] shl 24 + Data[Index + 11] shl 16 +
                   Data[Index + 12] shl 8  + Data[Index + 13];
  Result.Frames := Data[Index + 14] shl 24 + Data[Index + 15] shl 16 +
                   Data[Index + 16] shl 8  + Data[Index + 17];
end;

{ --------------------------------------------------------------------------- }

function GetVbrInfo(const Index: Word; Data: array of Byte): VBRData;
var
  PSize: PLongint;
  PPos: PByte absolute PSize;
  Flags: byte;
begin
  FillChar(Result, SizeOf(Result), 0);
  Result.Found := true;
  Result.ID := VBR_ID_INFO;
  Flags := Data[Index + 7];
  if (Flags and 1) = 1 then
    Result.Frames := Data[Index + 8] shl 24 + Data[Index + 9] shl 16 +
                     Data[Index + 10] shl 8  + Data[Index + 11];
  if (Flags and 2) = 2 then
    Result.Bytes :=  Data[Index + 12] shl 24 + Data[Index + 13] shl 16 +
                     Data[Index + 14] shl 8  + Data[Index + 15];
  if (Flags and 8) = 8 then
    Result.Scale := Data[Index + 119];
end;
{ --------------------------------------------------------------------------- }

function FindVBR(const Index: Word; Data: array of Byte): VBRData;
begin
  { Check for VBR header at given position }
  FillChar(Result, SizeOf(Result), 0);
  if Chr(Data[Index]) +
    Chr(Data[Index + 1]) +
    Chr(Data[Index + 2]) +
    Chr(Data[Index + 3]) = VBR_ID_XING then Result := GetXingInfo(Index, Data);
  if Chr(Data[Index]) +
    Chr(Data[Index + 1]) +
    Chr(Data[Index + 2]) +
    Chr(Data[Index + 3]) = VBR_ID_FHG then Result := GetFhGInfo(Index, Data);
  if Chr(Data[Index]) +
    Chr(Data[Index + 1]) +
    Chr(Data[Index + 2]) +
    Chr(Data[Index + 3]) = VBR_ID_INFO then Result := GetVbrInfo(Index, Data);

end;

{ --------------------------------------------------------------------------- }

function GetVBRDeviation(const Frame: FrameData): Byte;
begin
  { Calculate VBR deviation }
  if Frame.VersionID = MPEG_VERSION_1 then
    if Frame.ModeID <> MPEG_CM_MONO then Result := 36
    else Result := 21
  else
    if Frame.ModeID <> MPEG_CM_MONO then Result := 21
    else Result := 13;
end;

{ --------------------------------------------------------------------------- }

function FindFrame(const Data: array of Byte; var VBR: VBRData): FrameData;
var
  HeaderData: array [1..4] of Byte;
  Iterator: Integer;
//  isDecode: boolean;
begin
  { Search for valid frame }
  FillChar(Result, SizeOf(Result), 0);
  Move(Data, HeaderData, SizeOf(HeaderData));

  for Iterator := 0 to SizeOf(Data) - MAX_MPEG_FRAME_LENGTH do
  begin
    { Decode data if frame header found }
    if IsFrameHeader(HeaderData) then
    begin
      DecodeHeader(HeaderData, Result);
//      if not isDecode then
//      begin
//        DecodeHeader(HeaderData, Result);
//        isDecode := true;
//        Result.Found := true;
//        Result.Size := GetFrameLength(Result);
//        Result.Empty := FrameIsEmpty(Iterator + SizeOf(HeaderData), Data);
//      end;

      { Check for next frame and try to find VBR header }
      if ValidFrameAt(Iterator + GetFrameLength(Result), Data) then
      begin
        Result.Found := true;
        Result.Position := Iterator;
        Result.Size := GetFrameLength(Result);
        Result.Empty := FrameIsEmpty(Iterator + SizeOf(HeaderData), Data);
        VBR := FindVBR(Iterator + GetVBRDeviation(Result), Data);
        break;
      end;
    end;
    { Prepare next data block }
    HeaderData[1] := HeaderData[2];
    HeaderData[2] := HeaderData[3];
    HeaderData[3] := HeaderData[4];
    HeaderData[4] := Data[Iterator + SizeOf(HeaderData)];
  end;
end;

{ --------------------------------------------------------------------------- }

function GetTrack(const TrackString: string): Byte;
var
  Index, Value, Code: Integer;
begin
  { Extract track from string }
  Index := Pos('/', TrackString);
  if Index = 0 then Val(Trim(TrackString), Value, Code)
  else Val(Copy(Trim(TrackString), 1, Index), Value, Code);
  if Code = 0 then Result := Value
  else Result := 0;
end;


{ ********************** Private functions & procedures ********************* }

procedure TMPEGaudio.FResetData;
begin
  { Reset all variables }
  FFileLength := 0;
  FillChar(FVBR, SizeOf(FVBR), 0);
  FillChar(FFrame, SizeOf(FFrame), 0);
  FFrame.VersionID := MPEG_VERSION_UNKNOWN;
  FFrame.SampleRateID := MPEG_SAMPLE_RATE_UNKNOWN;
  FFrame.ModeID := MPEG_CM_UNKNOWN;
  FFrame.ModeExtensionID := MPEG_CM_EXTENSION_UNKNOWN;
  FFrame.EmphasisID := MPEG_EMPHASIS_UNKNOWN;
  FID3v1.ResetData;
  FID3v2.ResetData;
end;

function TMPEGaudio.GetMP3FrameInfo(index: longint): TMP3FrameInfo;
begin
  result := TMP3FrameInfo(FFramesPos[index]);
end;

function TMPEGaudio.isMP3File(const FileName: string): Boolean;
var
  F: TFileStream;
  Data: array [1..MAX_MPEG_FRAME_LENGTH * 2] of Byte;
begin
  F := TFileStream.Create(FileName, fmOpenRead + fmShareDenyWrite);
  Result := false;
  FResetData;
  if (FID3v1.ReadFromStream(F)) and (FID3v2.ReadFromStream(F)) then
  begin
    F.Position := FID3v2.Size;
    F.Read(Data, SizeOf(Data));
    FWaveHeader := WaveHeaderPresent(FID3v2.Size, Data);
    FFrame := FindFrame(Data, FVBR);
    Result := FFrame.Found;
  end;
  F.Free;
end;

{ --------------------------------------------------------------------------- }

function TMPEGaudio.FGetVersion: string;
begin
  { Get MPEG version name }
  Result := MPEG_VERSION[FFrame.VersionID];
end;

{ --------------------------------------------------------------------------- }

function TMPEGaudio.FGetLayer: string;
begin
  { Get MPEG layer name }
  Result := MPEG_LAYER[FFrame.LayerID];
end;

{ --------------------------------------------------------------------------- }

function TMPEGaudio.FGetBitRate: Word;
begin
  { Get bit rate, calculate average bit rate if VBR header found }
  if (FVBR.Found) and (FVBR.Frames > 0) then
    Result := Round((FVBR.Bytes / FVBR.Frames - GetPadding(FFrame)) *
      GetSampleRate(FFrame) / GetCoefficient(FFrame) / 1000)
  else
    Result := GetBitRate(FFrame);
end;

{ --------------------------------------------------------------------------- }

function TMPEGaudio.FGetSampleRate: Word;
begin
  { Get sample rate }
  Result := GetSampleRate(FFrame);
end;

{ --------------------------------------------------------------------------- }

function TMPEGaudio.FGetChannelMode: string;
begin
  { Get channel mode name }
  Result := MPEG_CM_MODE[FFrame.ModeID];
end;

{ --------------------------------------------------------------------------- }

function TMPEGaudio.FGetEmphasis: string;
begin
  { Get emphasis name }
  Result := MPEG_EMPHASIS[FFrame.EmphasisID];
end;

{ --------------------------------------------------------------------------- }

function TMPEGaudio.FGetFrames: LongInt;
begin
  { Get total number of frames, calculate if VBR header not found }
  if FFramesPos.Count > 0 then
    Result := FFramesPos.Count else
  if FVBR.Found then
    Result := FVBR.Frames
  else
    Result := (FFileLength - FID3v2.Size - FFrame.Position) div
      GetFrameLength(FFrame);
end;

{ --------------------------------------------------------------------------- }

function TMPEGaudio.FGetDuration: Double;
begin
  { Calculate song duration }
  if FFrame.Found then
    if (FVBR.Found) and (FVBR.Frames > 0) then
      Result := FVBR.Frames * GetCoefficient(FFrame) * 8 /
        GetSampleRate(FFrame)
    else
      Result := (FFileLength - FID3v2.Size - FFrame.Position) * 8 /
        GetBitRate(FFrame) / 1000
  else
    Result := 0;
end;

{ --------------------------------------------------------------------------- }

function TMPEGaudio.FGetVBREncoderID: Byte;
begin
  { Guess VBR encoder and get ID }
  Result := 0;
  if Copy(FVBR.VendorID, 1, 4) = VBR_VENDOR_ID_LAME then
    Result := MPEG_ENCODER_LAME;
  if Copy(FVBR.VendorID, 1, 4) = VBR_VENDOR_ID_GOGO_NEW then
    Result := MPEG_ENCODER_GOGO;
  if Copy(FVBR.VendorID, 1, 4) = VBR_VENDOR_ID_GOGO_OLD then
    Result := MPEG_ENCODER_GOGO;
  if (FVBR.ID = VBR_ID_XING) and
    (Copy(FVBR.VendorID, 1, 4) <> VBR_VENDOR_ID_LAME) and
    (Copy(FVBR.VendorID, 1, 4) <> VBR_VENDOR_ID_GOGO_NEW) and
    (Copy(FVBR.VendorID, 1, 4) <> VBR_VENDOR_ID_GOGO_OLD) then
    Result := MPEG_ENCODER_XING;
  if FVBR.ID = VBR_ID_FHG then
    Result := MPEG_ENCODER_FHG;
end;

{ --------------------------------------------------------------------------- }

function TMPEGaudio.FGetCBREncoderID: Byte;
begin
  { Guess CBR encoder and get ID }
  Result := 0;
  if (FFrame.OriginalBit) and
    (FFrame.ProtectionBit) then
    Result := MPEG_ENCODER_LAME;
  if (FFrame.ModeID = MPEG_CM_JOINT_STEREO) and
    (not FFrame.CopyrightBit) and
    (not FFrame.OriginalBit) then
    Result := MPEG_ENCODER_FHG;
  if (GetBitRate(FFrame) <= 112) and
    (FFrame.ModeID = MPEG_CM_STEREO) then
    Result := MPEG_ENCODER_BLADE;
  if (FFrame.CopyrightBit) and
    (FFrame.OriginalBit) and
    (not FFrame.ProtectionBit) then
    Result := MPEG_ENCODER_XING;
  if (FFrame.Empty) and
    (FFrame.OriginalBit) then
    Result := MPEG_ENCODER_XING;
  if (FWaveHeader) then
    Result := MPEG_ENCODER_FHG;
  if (FFrame.ModeID = MPEG_CM_DUAL_CHANNEL) and
    (FFrame.ProtectionBit) then
    Result := MPEG_ENCODER_SHINE;
end;

{ --------------------------------------------------------------------------- }

function TMPEGaudio.FGetEncoderID: Byte;
begin
  { Get guessed encoder ID }
  if FFrame.Found then
    if FVBR.Found then Result := FGetVBREncoderID
    else Result := FGetCBREncoderID
  else
    Result := 0;
end;

{ --------------------------------------------------------------------------- }

function TMPEGaudio.FGetEncoder: string;
begin
  { Get guessed encoder name }
  Result := MPEG_ENCODER[FGetEncoderID];
  if (FVBR.Found) and
    (FGetEncoderID = MPEG_ENCODER_LAME) and
    (FVBR.VendorID[5] in ['0'..'9']) and
    (FVBR.VendorID[6] = '.') and
    (FVBR.VendorID[7] in ['0'..'9']) and
    (FVBR.VendorID[8] in ['0'..'9']) then
    Result :=
      Result + #32 +
      FVBR.VendorID[5] +
      FVBR.VendorID[6] +
      FVBR.VendorID[7] +
      FVBR.VendorID[8];
end;

{ --------------------------------------------------------------------------- }

function TMPEGaudio.FGetValid: Boolean;
begin
  { Check for right MPEG file data }
  Result :=
    (FFrame.Found) and
    (FGetBitRate >= MIN_MPEG_BIT_RATE) and
    (FGetBitRate <= MAX_MPEG_BIT_RATE) and
    (FGetDuration >= MIN_ALLOWED_DURATION);
end;

{ ********************** Public functions & procedures ********************** }

constructor TMPEGaudio.Create;
begin
  inherited;
  FID3v1 := TID3v1.Create;
  FID3v2 := TID3v2.Create;
  FResetData;
  FFramesPos := TObjectList.Create;
end;

{ --------------------------------------------------------------------------- }

destructor TMPEGaudio.Destroy;
begin
  FFramesPos.Free;
  FID3v1.Free;
  FID3v2.Free;
  inherited;
end;

{ --------------------------------------------------------------------------- }

function TMPEGaudio.ReadFromFile(const FileName: string): Boolean;
var
  F: TFileStream;
begin
  F := TFileStream.Create(FileName, fmOpenRead + fmShareDenyWrite);
  Result := ReadFromStream(F);
  F.Free;
end;

function TMPEGaudio.ReadFromStream(Src: TStream): boolean;
var
  Data: array [1..MAX_MPEG_FRAME_LENGTH * 2] of Byte;
begin
  Result := false;
  FResetData;
  if (FID3v1.ReadFromStream(Src)) and (FID3v2.ReadFromStream(Src)) then
    try
      { Open file, read first block of data and search for a frame }
      FFileLength := Src.Size;
      Src.Position := FID3v2.Size;
      Src.Read(Data, SizeOf(Data));
//      BlockRead(SourceFile, Data, SizeOf(Data), Transferred);
      FWaveHeader := WaveHeaderPresent(FID3v2.Size, Data);
      FFrame := FindFrame(Data, FVBR);
      { Try to search in the middle if no frame at the beginning found }
      if (not FFrame.Found) {and (Transferred = SizeOf(Data))} then
      begin
        Src.Position := (FFileLength - FID3v2.Size) div 2;
        Src.Read(Data, SizeOf(Data));
        FFrame := FindFrame(Data, FVBR);
      end;
      Result := true;
      if FFrame.Found then
        EnumFrames(Src);
    except
    end;
  if not FFrame.Found then FResetData;
end;

procedure TMPEGaudio.EnumFrames(Src: TStream);
 var HeaderData: array [1..4] of Byte;
     DW: dword absolute HeaderData;
     CFrame: FrameData;
     FI: TMP3FrameInfo;
     vbrflag: array [0..3] of char;
begin
  CFrame := FirstFrame;
  FSoundFrameCount := 0;
  CFrame.Position := FirstFrame.Position + ID3v2.Size;
  Src.Position := CFrame.Position;
  while (Src.Position + ID3v1.Size) < Src.Size do
  begin
    Src.Read(HeaderData, 4);
    if IsFrameHeader(HeaderData) then
    begin
      FI := TMP3FrameInfo.Create;
      FI.Header := DW;
      FI.Position := Src.Position - 4;
      DecodeHeader(HeaderData, CFrame);
      FI.Size := GetFrameLength(CFrame);
      Src.Seek(32, 1);
      Src.Read(vbrflag, 4);
      FI.isSound := not((vbrflag = VBR_ID_INFO) or (vbrflag = VBR_Lame_Track) or
                        (vbrflag = VBR_ID_XING) or (vbrflag = MPEG_ENCODER[3]));
      if FI.isSound then inc(FSoundFrameCount);
      FFramesPos.Add(FI);
      Src.Position := FI.Position + Fi.Size;
    end else
      Src.Position := Src.Size;
  end;
end;

function GetTagVersion(const TagData: TagID3v1): Byte;
begin
  Result := TAG_VERSION_1_0;
  { Terms for ID3v1.1 }
  if ((TagData.Comment[29] = #0) and (TagData.Comment[30] <> #0)) or
    ((TagData.Comment[29] = #32) and (TagData.Comment[30] <> #32)) then
    Result := TAG_VERSION_1_1;
end;

function Swap32(const Figure: Integer): Integer;
var
  ByteArray: array [1..4] of Byte absolute Figure;
begin
  { Swap 4 bytes }
  Result :=
    ByteArray[1] * $100000000 +
    ByteArray[2] * $10000 +
    ByteArray[3] * $100 +
    ByteArray[4];
end;

{ ********************** TID3v1  ********************* }

constructor TID3v1.Create;
begin
  inherited;
  ResetData;
end;

{ --------------------------------------------------------------------------- }

procedure TID3v1.ResetData;
begin
  FExists := false;
  FVersionID := TAG_VERSION_1_0;
  FTitle := '';
  FArtist := '';
  FAlbum := '';
  FYear := '';
  FComment := '';
  FTrack := 0;
  FGenreID := DEFAULT_GENRE;
end;

{ --------------------------------------------------------------------------- }

function TID3v1.ReadFromFile(const FileName: string): Boolean;
 var
   F: TFileStream;
begin
  F := TFileStream.Create(FileName, fmOpenRead + fmShareDenyWrite);
  Result := ReadFromStream(F);
  F.Free;
end;

{ --------------------------------------------------------------------------- }

function TID3v1.ReadFromStream(Src: TStream): Boolean;
 var
   TagData: TagID3v1;
begin
  Result := true;
  Src.Position := Src.Size - 128;
  Src.Read(TagData, 128);
  FSize := 0;
  if (TagData.Header = 'TAG') then
  begin
    FSize := 128;
    FExists := true;
    FVersionID := GetTagVersion(TagData);
    { Fill properties with tag data }
    FTitle := TrimRight(TagData.Title);
    FArtist := TrimRight(TagData.Artist);
    FAlbum := TrimRight(TagData.Album);
    FYear := TrimRight(TagData.Year);
    if FVersionID = TAG_VERSION_1_0 then
      FComment := TrimRight(TagData.Comment)
    else
    begin
      FComment := TrimRight(Copy(TagData.Comment, 1, 28));
      FTrack := Ord(TagData.Comment[30]);
    end;
    FGenreID := TagData.Genre;
    Result := true;
  end;
end;

procedure TID3v1.FSetTitle(const NewTitle: String30);
begin
  FTitle := TrimRight(NewTitle);
end;

{ --------------------------------------------------------------------------- }

procedure TID3v1.FSetArtist(const NewArtist: String30);
begin
  FArtist := TrimRight(NewArtist);
end;

{ --------------------------------------------------------------------------- }

procedure TID3v1.FSetAlbum(const NewAlbum: String30);
begin
  FAlbum := TrimRight(NewAlbum);
end;

{ --------------------------------------------------------------------------- }

procedure TID3v1.FSetYear(const NewYear: String04);
begin
  FYear := TrimRight(NewYear);
end;

{ --------------------------------------------------------------------------- }

procedure TID3v1.FSetComment(const NewComment: String30);
begin
  FComment := TrimRight(NewComment);
end;

{ --------------------------------------------------------------------------- }

procedure TID3v1.FSetTrack(const NewTrack: Byte);
begin
  FTrack := NewTrack;
end;

{ --------------------------------------------------------------------------- }

procedure TID3v1.FSetGenreID(const NewGenreID: Byte);
begin
  if NewGenreID >= MAX_MUSIC_GENRES
    then FGenreID := MAX_MUSIC_GENRES - 1
    else FGenreID := NewGenreID;
end;

{ --------------------------------------------------------------------------- }

function TID3v1.FGetGenre: string;
begin
  Result := '';
  { Return an empty string if the current GenreID is not valid }
  if FGenreID in [0..MAX_MUSIC_GENRES - 1] then Result := MusicGenre[FGenreID];
end;


{ ********************************** TID3v2 ******************************** }

constructor TID3v2.Create;
begin
  inherited;
  ResetData;
end;

{ --------------------------------------------------------------------------- }

procedure TID3v2.ResetData;
begin
  FExists := false;
  FVersionID := 0;
  FSize := 0;
  FTitle := '';
  FArtist := '';
  FAlbum := '';
  FTrack := 0;
  FYear := '';
  FGenre := '';
  FComment := '';
end;

{ --------------------------------------------------------------------------- }

function TID3v2.ReadFromFile(const FileName: string): Boolean;
var
  F: TFileStream;
begin
  F := TFileStream.Create(FileName, fmOpenRead + fmShareDenyWrite);
  Result := ReadFromStream(F);
  F.Free;
end;

function TID3v2.ReadFromStream(Src: TStream): boolean;
var
  TagData: TagID3v2;
  Frame: MP3FrameHeader;
  DataPosition: longint;
  Data: array [1..250] of Char;
  Iterator: Byte;
begin
  ResetData;
  Result := true;
  Src.Position := 0;
  Src.Read(TagData, 10);
  if TagData.ID = 'ID3' then
  begin
    FExists := true;
    TagData.FileSize := Src.Size;
    { Fill properties with header data }
    FVersionID := TagData.Version;
    FSize := TagData.Size[1] * $200000 + TagData.Size[2] * $4000 + TagData.Size[3] * $80 + TagData.Size[4] + 10;
    if FSize > TagData.FileSize then FSize := 0;;
    { Get information from frames if version supported }
    if (FVersionID = TAG_VERSION_2_3) and (FSize > 0) then
    begin
      while (Src.Position < FSize) and (Src.Position < Src.Size) do
      begin
        FillChar(Data, SizeOf(Data), 0);

        Src.Read(Frame, 10);

        DataPosition := Src.Position;
        Src.Read(Data, Swap32(Frame.Size) mod SizeOf(Data));

        for Iterator := 1 to ID3V2_FRAME_COUNT do
          if ID3V2_FRAME[Iterator] = Frame.ID then TagData.Frame[Iterator] := Data;

        Src.Seek(DataPosition + Swap32(Frame.Size), 0);
      end;

      { Fill properties with data from frames }
      FTitle := Trim(TagData.Frame[1]);
      FArtist := Trim(TagData.Frame[2]);
      FAlbum := Trim(TagData.Frame[3]);
      FTrack := GetTrack(TagData.Frame[4]);
      FYear := Trim(TagData.Frame[5]);
      FGenre := Trim(TagData.Frame[6]);
      if Pos(')', FGenre) > 0 then Delete(FGenre, 1, LastDelimiter(')', FGenre));
      FComment := Trim(Copy(TagData.Frame[7], 5, Length(TagData.Frame[7]) - 4));
    end;
  end;
end;

{ TMP3FrameInfo }


end.

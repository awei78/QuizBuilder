//*******************************************************//
//                                                       //
//                      DelphiFlash.com                  //
//         Copyright (c) 2004-2007 FeatherySoft, Inc.    //
//                    info@delphiflash.com               //
//                                                       //
//*******************************************************//

//  Description: text constants indicated of SWF vocabulary
//  Last update:  10 jan 2007

unit SWFStrings;
interface
 Uses Windows, SysUtils, Classes, SWFConst;

{ for XML}
const
 sc_SWF = 'SWF';
 sc_Flash = 'Flash';
 sc_FPS = 'FPS';
 sc_Version = 'Version';
 sc_SysCoord = 'SystemCoord';
 sc_Compressed = 'Compressed';
 sc_Pix = 'Pix';
 sc_Twips = 'Twips';
 sc_Color = 'Color';
 sc_BGColor = 'BgColor';
 sc_Name = 'Name';
 sc_isAnchor = 'isAnchor';
 sc_Hash = 'Hash';
 sc_Object = 'Object';
 sc_ID = 'ID';
 sc_URL = 'URL';
 sc_MaxRecursionDepth = 'MaxRecursionDepth';
 sc_ScriptTimeoutSeconds = 'ScriptTimeoutSeconds';
 sc_Depth = 'Depth';
 sc_RemoveDepth = 'Remove' + sc_Depth;
 sc_TabIndex = 'TabIndex';
 sc_Ratio = 'Ratio';
 sc_Actions = 'Actions';
 sc_InitActions = 'Init' + sc_Actions;
 sc_ClipDepth = 'Clip' + sc_Depth;
 sc_Fill = 'Fill';
 sc_Style = 'Style';
 sc_Styles = sc_Style + 's';
 sc_FillStyles = sc_Fill +sc_Styles;
 sc_LineStyles = 'Line' + sc_Styles;
 sc_New = 'New';
 sc_NewLineStyles = sc_New + sc_LineStyles;
 sc_NewFillStyles = sc_New + sc_FillStyles;
 sc_Width = 'Width';
 sc_Height = 'Height';
 sc_Item = 'Item';
 sc_Gradient = 'Gradient';
 sc_Edges = 'Edges';
 sc_End = 'End';
 sc_MoveTo = 'MoveTo';
 sc_Curve = 'Curve';
 sc_Line = 'Line';
 sc_LineTo = 'LineTo';
 sc_MoveDelta = 'MoveDelta';
 sc_CurveTo = 'CurveTo';
 sc_LineDelta = 'LineDelta';
 sc_CloseShape = 'CloseShape';
 sc_Rectangle = 'Rectangle';
 sc_RoundRect = 'RoundRect';
 sc_Radius = 'Radius';
 sc_Ellipse = 'Ellipse';
 sc_Circle = 'Circle';
 sc_Ring = 'Ring';
 sc_Center = 'Center';
 sc_Pie = 'Pie';
 sc_StartAngle = 'StartAngle';
 sc_EndAngle = 'EndAngle';
 sc_Arc = 'Arc';
 sc_Closed = 'Closed';
 sc_ClockWise = 'ClockWise';
 sc_Diamond = 'Diamond';
 sc_Star ='Star';
 sc_R1 = 'R1';
 sc_R2 = 'R2';
 sc_NumberOfPoints = 'Points';
 sc_CubicBezier = 'CubicBezier';
 sc_Polyline = 'Polyline';
 sc_Polygon = 'Polygon';
 sc_PolyBezier = 'PolyBezier';
 sc_Point = 'Point';
 sc_Mirror = 'Mirror';
 sc_Horz = 'Horz';
 sc_Vert = 'Vert';
 sc_OffsetEdges = 'OffsetEdges';
 sc_X0 = 'X0';
 sc_Square = 'Square';
 sc_Side = 'Side';

 sc_StyleChange = 'StyleChange';
 sc_Anchor = 'Anchor';
 sc_Control = 'Control';
 sc_Glyph = 'Glyph';
 sc_Num = 'Num';
 sc_FontFlagsSmallText = 'SmallText';
 sc_FontFlagsShiftJIS ='ShiftJIS';
 sc_FontFlagsANSI = 'ANSI';
 sc_FontFlagsItalic = 'Italic';
 sc_FontFlagsBold = 'Bold';
 sc_Code = 'Code';
 sc_FontFlagsWideCodes = 'Wide'+sc_Code+'s';
 sc_LanguageCode = 'LanguageCode';
 sc_FontAscent = 'Ascent';
 sc_FontDescent = 'Descent';
 sc_FontLeading = 'Leading';
 sc_Advance = 'Advance';
 sc_Kerning = 'Kerning';
 sc_FontKerningCode = sc_Kerning + sc_Code;
 sc_FontKerningAdjustment = sc_Kerning +'Adjustment'; 
 sc_Index = 'Index';
 sc_Type = 'Type';
 sc_Font = 'Font';
 sc_FontCopyright = 'Copyright';
 sc_FontId = sc_Font + sc_ID;
 sc_TextRecord = 'TextRecord';
 sc_AutoSize = 'AutoSize';
 sc_WordWrap = 'WordWrap';
 sc_Multiline = 'Multiline';
 sc_Password = 'Password';
 sc_ReadOnly = 'ReadOnly';
 sc_NoSelect = 'NoSelect';
 sc_Border = 'Border';
 sc_HTML = 'HTML';
 sc_UseOutlines = 'UseOutlines';
 sc_MaxLength = 'MaxLength';
 sc_Layout = 'Layout';
 sc_Align = 'Align';
 sc_LeftMargin = 'LeftMargin';
 sc_Value = 'Value';
 sc_Variable = 'Variable';
 sc_AVarType: array [0..10] of pchar =
     ('str', 'float', 'null', 'undef', 'reg', 'bool', 'double',
      'int', 'const8', 'const16', 'def');
 sc_RightMargin = 'RightMargin';
 sc_Indent = 'Indent';
 sc_Leading = 'Leading';
 sc_SoundFormat = 'SoundFormat';
 sc_SoundRate = 'SoundRate';
 sc_SoundSize = 'SoundSize';
 sc_SoundType = 'SoundType';
 sc_SampleCount = 'SampleCount';
 sc_SoundCompression = 'SoundCompression';
 sc_SeekSamples = 'SeekSamples';
 sc_Data = 'Data';
 sc_AlphaData = 'AlphaData';
 sc_SyncStop = 'SyncStop';
 sc_SyncNoMultiple = 'SyncNoMultiple';
 sc_LoopCount = 'LoopCount';
 sc_InPoint = 'InPoint';
 sc_OutPoint = 'OutPoint';
 sc_Envelope = 'Envelope';
 sc_Pos44 = 'Pos44';
 sc_LeftLevel = 'LeftLevel';
 sc_RightLevel = 'RightLevel';
 sc_Playback = 'Playback';
 sc_Stream = 'Stream';
 sc_LatencySeek = 'LatencySeek';
 sc_ButtonRecord = 'ButtonRecord';
 sc_State = 'State';
 sc_TrackAsMenu = 'TrackAsMenu';
 sc_OverUpToIdle = 'OverUpToIdle';
 sc_IdleToOverUp = 'IdleToOverUp';
 sc_OverUpToOverDown = 'OverUpToOverDown';
 sc_OverDownToOverUp = 'OverDownToOverUp';
 sc_BitmapFormat = 'BitmapFormat';
 sc_BitmapColorTableSize = 'BitmapColorTableSize';
 sc_Start = 'Start';
 sc_StartShape = 'StartShape';
 sc_EndShape = 'EndShape';
 sc_StartColor = 'StartColor';
 sc_EndColor = 'EndColor';
 sc_StartWidth = sc_Start + sc_Width;
 sc_EndWidth = sc_End + sc_Width;
 sc_StartMatrix = sc_Start + 'Matrix';
 sc_EndMatrix = sc_End + 'Matrix';
 sc_Label = 'Label';
 sc_Frame = 'Frame';
 sc_FrameNum = sc_Frame+'Num';
 sc_Target = 'Target';
 sc_SkipCount = 'SkipCount';
 sc_TargetName = 'TargetName';
 sc_SendVarsMethod = 'Method';
 sc_LoadTargetFlag = 'LoadTargetFlag';
 sc_LoadVariablesFlag = 'LoadVariablesFlag';
 sc_PlayFlag = 'PlayFlag';
 sc_Scene = 'Scene';
 sc_SceneBias = sc_Scene+'Bias';
 sc_Register = 'Register';
 sc_RegisterNumber = 'RegisterNumber';
 sc_RegisterCount = 'RegisterCount';
 sc_PreloadParentFlag = 'PreloadParent';
 sc_PreloadRootFlag = 'PreloadRoot';
 sc_SuppressSuperFlag = 'SuppressSuper';
 sc_PreloadSuperFlag = 'PreloadSuper';
 sc_SuppressArgumentsFlag = 'SuppressArguments';
 sc_PreloadArgumentsFlag = 'PreloadArguments';
 sc_SuppressThisFlag = 'SuppressThis';
 sc_PreloadThisFlag = 'PreloadThis';
 sc_PreloadGlobalFlag = 'PreloadGlobal';
 sc_Catch = 'Catch';
 sc_TryLabel = 'TryLabel';
 sc_CatchLabel = 'CatchLabel';
 sc_FinallyLabel = 'FinallyLabel';
 sc_Event = 'Event';
 sc_KeyCode = 'KeyCode';
 sc_Offset = 'Offset';
 sc_APostMethod: array [0..2] of pchar = ('', 'GET', 'POST');
 sc_AClipEvents: array[TSWFClipEvent] of pchar =
        ('KeyUp', 'KeyDown', 'MouseUp', 'MouseDown', 'MouseMove', 'Unload',
                   'EnterFrame', 'Load', 'DragOver', 'RollOut', 'RollOver',
                   'ReleaseOutside', 'Release', 'Press', 'Initialize', 'Data',
                   'Construct', 'KeyPress', 'DragOut');
 sc_AStateTransition: array [TSWFStateTransition] of pchar =
        ('IdleToOverUp', 'OverUpToIdle', 'OverUpToOverDown', 'OverDownToOverUp',
         'OutDownToOverDown', 'OverDownToOutDown', 'OutDownToIdle',
         'IdleToOverDown', 'OverDownToIdle');
 sc_NumFrames = 'NumFrames';
 sc_VideoFlagsDeblocking = 'VideoFlagsDeblocking';
 sc_VideoFlagsSmoothing = 'VideoFlagsSmoothing';
 sc_CodecID = 'Codec';

 sc_Repeat = 'Repeat';
 sc_Time = 'Time';
 sc_IDStr = 'IDStr';
 sc_XMin = 'XMin';
 sc_XMax = 'XMax';
 sc_YMin = 'YMin';
 sc_YMax = 'YMax';
  sc_Matrix = 'Matrix';
  sc_Scale = 'Scale';
  sc_Skew = 'Skew';
  sc_Translate = 'Translate';
  sc_Add = 'Add';
  sc_Mult = 'Mult';
  sc_ColorTransform = 'ColorTransform';
  sc_Alpha = 'Alpha';
  sc_EventActions = 'EventActions';
  sc_File = 'File';
  sc_CodeType = 'CodeType';
  sc_lpImage = 'image';
  sc_lpSound = 'sound';
  sc_lpVideo = 'video';
  sc_lpFont = 'font';
  sc_lpActions = 'actions';
  sc_lpNotIdentified = 'notident';
  sc_FileType = 'FileType';
  sc_XML = 'XML';
  sc_bytecode = 'bytecode';
  sc_AC = 'AC';

 sc_RadialGradient = 'RadialGradient';
 sc_LinearGradient = 'LinearGradient';
 sc_SolidColor = 'SolidColor';
 sc_Angle = 'Angle';
 sc_AlphaColor = 'AlphaColor';
 sc_AlphaFile = 'AlphaFile';
 sc_AlphaIndex = 'AlphaIndex';
 sc_ImageFill = 'ImageFill';
 sc_LineStyle = 'LineStyle';
 sc_Ext = 'Ext';
 sc_Device = 'Device';
 sc_FontSize = 'Size';
 sc_EncodingType = 'EncodingType';
 sc_SWFFormat = 'SWFFormat';
 sc_DynamicText = 'Dynamic';
 sc_CharSpacing = 'CharSpacing';
 sc_FontIDStr = 'FontIDStr';
 sc_AsBackground = 'AsBackground';
 sc_SndPress = 'SndPress';
 sc_SndRelease = 'SndRelease';
 sc_SndRollOut = 'SndRollOut';
 sc_SndRollOver = 'SndRollOver';
 sc_Renum = 'Renum';

 sc_HasMetadata = 'HasMetadata';
 sc_UseNetwork = 'UseNetwork';
 sc_AFilterNames: array [0..7] of PChar =
    ('DropShadow','Blur','Glow','Bevel','GradientGlow','Convolution','ColorMatrix','GradientBevel');
 sc_BlendMode = 'BlendMode';
 sc_CacheAsBitmap = 'CacheAsBitmap';
 sc_HasImage = 'HasImage';
 sc_ClassName = 'ClassName';
 sc_HasClassName = 'Has'+sc_ClassName;
 sc_Filters = 'Filters';
 sc_Passes = 'Passes';
 sc_BlurX = 'BlurX';
 sc_BlurY = 'BlurY';
 sc_Bias = 'Bias';
 sc_Clamp = 'Clamp';
 sc_Divisor = 'Divisor';
 sc_PreserveAlpha = 'PreserveAlpha';
 sc_Distance = 'Distance';
 sc_Strength = 'Strength';
 sc_InnerShadow = 'InnerShadow';
 sc_Knockout = 'Knockout';
 sc_CompositeSource = 'CompositeSource';
 sc_OnTop = 'OnTop';
 sc_InnerGlow = 'InnerGlow';
 sc_NumColors = 'NumColors';
 sc_AQuality: array [0..2] of pchar = ('Low', 'Medium', 'High');
 sc_UsesNonScalingStrokes = 'UsesNonScalingStrokes';
 sc_UsesScalingStrokes = 'UsesScalingStrokes';
 sc_FocalPoint = 'FocalPoint';
 sc_InterpolationMode = 'InterpolationMode';
 sc_SpreadMode = 'SpreadMode';
 sc_HasFillFlag = 'HasFillFlag';
 sc_CapStyle = 'CapStyle';
 sc_StartCapStyle = 'Start'+sc_CapStyle;
 sc_EndCapStyle = 'End'+sc_CapStyle;
 sc_JoinStyle = 'JoinStyle';
 sc_NoClose = 'NoClose';
 sc_NoHScaleFlag = 'NoHScaleFlag';
 sc_NoVScaleFlag = 'NoVScaleFlag';
 sc_PixelHintingFlag = 'PixelHintingFlag';
 sc_MiterLimitFactor = 'MiterLimitFactor';
 sc_CSMTableHint = 'CSMTableHint';
 sc_ZoneRecord = 'ZoneRecord';
 sc_NumZoneData = 'NumZoneData';
 sc_MaskX = 'MaskX';
 sc_MaskY = 'MaskY';
 sc_Range = 'Range';
 sc_UseFlashType = 'UseFlashType';
 sc_GridFit = 'GridFit';
 sc_Thickness = 'Thickness';
 sc_Sharpness = 'Sharpness';
 sc_ButtonHasBlendMode = 'Has' + sc_BlendMode;
 sc_ButtonHasFilterList = 'Has' + sc_Filters;
 sc_Brightness = 'Brightness';
 sc_Contrast = 'Contrast';
 sc_Saturation = 'Saturation';
 sc_Hue = 'Hue';
 sc_WaveCompressBit = 'WaveCompressBit';
 sc_LazyInitializeFlag = 'LazyInitializeFlag';
 sc_int = 'Int';
 sc_uint = 'UInt';
 sc_double = 'Double';
 sc_Strings = 'Strings';
 sc_NameSpace = 'NameSpace';
 sc_NameSpaceSET = sc_NameSpace+ 'SET';
 sc_Kind = 'Kind';
 sc_Multiname = 'Multiname';
 sc_Method = 'Method';
 sc_Methods = sc_Method + 's';
 sc_ReturnType = 'ReturnType';
 sc_Param = 'Param';
 sc_NeedArguments = 'NeedArguments';
 sc_NeedActivation = 'NeedActivation';
 sc_NeedRest = 'NeedRest';
 sc_SetDxns = 'SetDxns';
 sc_Option = 'Option';
 sc_Metadata = 'Metadata';
 sc_MetadataInfo = sc_Metadata+'Info';
 sc_Key = 'Key';
 sc_Trait = 'Trait';
 sc_Instance = 'Instance';
 sc_Instances = sc_Instance + 's';
 sc_SuperName = 'SuperName';
 sc_ProtectedNs = 'ProtectedNs';
 sc_Init = 'Init';
 sc_Iinit = 'Iinit';
 sc_Class = 'Class';
 sc_ClassFinal = sc_Class + 'Final';
 sc_ClassInterface = sc_Class + 'Interface';
 sc_ClassProtectedNs = sc_Class + 'ProtectedNs';
 sc_ClassSealed = sc_Class + 'Sealed';
 sc_Classes = 'Classes';
 sc_TraitType = 'TraitType';
 sc_IsFinal = 'IsFinal';
 sc_SpecID = 'SpecID';
 sc_VIndex = 'VIndex';
 sc_VKind = 'VKind';
 sc_IsOverride = 'IsOverride';
 sc_Script = 'Script';
 sc_Scripts = sc_Script + 's';
 sc_MethodBodies = 'MethodBodies';
 sc_MethodBody = 'MethodBody';
 sc_MaxStack = 'MaxStack';
 sc_LocalCount = 'LocalCount';
 sc_InitScopeDepth = 'InitScopeDepth';
 sc_MaxScopeDepth = 'MaxScopeDepth';
 sc_Exception = 'Exception';
 sc_From = 'From';
 sc_To = 'To';
 sc_ExcType = 'ExcType';
 sc_VarName = 'VarName';
 sc_ConstantPool = 'ConstantPool';
 
 sc_FLVMetaData: array [0..19] of PChar = ('duration', 'lasttimestamp', 'lastkeyframetimestamp', 'width', 'height',
    'videodatarate', 'audiodatarate', 'framerate', 'creationdate', 'filesize', 'videosize', 'audiosize', 'datasize',
    'metadatacreator', 'metadatadate', 'videocodecid', 'audiocodecid', 'audiodelay', 'canseektoend', 'keyframes');

 sc_ProductId = 'ProductId';
 sc_Edition = 'Edition';
 sc_BuildNumber = 'BuildNumber';
 sc_Date = 'Date';
 sc_Interfaces = 'Interfaces';

 function StringFromArray(n: integer; Arr: array of string): string; overload;
 function StringFromArray(nn: array of integer; Arr: array of string): string; overload;
 function StringPosInArray(s: string; Arr: array of string): integer;
 function PCharPosInArray(s: pchar; Arr: array of pchar): integer;

 Function GetTagName(ID: word): string;
 Function GetTagID(name: string): integer;
 Function GetActionName(ID: word; prefix: boolean = true): string;
 Function GetInstructionName(ID: byte; prefix: string = ''): string; // for AVM2
 Function GetActionID(name: string): integer;
 function GetClipEventFlagsName(EF: TSWFClipEvents):string;
 function GetButtonEventFlagsName(EF: TSWFStateTransitions): string;
 Function GetFilterFromName(s: string): TSWFFilterID;
 function GetFillTypeName(FT: TSWFFillType; prefix: boolean = true): string;
 function GetFillTypeFromName(s: string): TSWFFillType;

implementation

function StringFromArray(n: integer; Arr: array of string): string;
begin
  result := Arr[n];
end;

function StringPosInArray(s: string; Arr: array of string): integer;
 var il:integer;
begin
 Result := -1;
 for il := 0 to High(Arr) do
  if AnsiSameText(s, Arr[il]) then
   begin
    Result := il;
    Break;
   end;
end;

function PCharPosInArray(s: pchar; Arr: array of pchar): integer;
 var il:integer;
begin
 result := -1;
 for il := 0 to High(Arr) do
  if AnsiSameText(s, Arr[il]) then
   begin
    Result := il;
    Break;
   end;
end;

function StringFromArray(nn: array of integer; Arr: array of string): string;
 var il: integer;
begin
  Result := '';
  if (High(nn)-Low(nn) + 1) > 0 then
   for il := Low(nn) to High(nn) do
    if Result = '' then Result := Arr[il] else Result := Result + ', ' + Arr[il];
end;

type
  ATagRec = Record
   ID: word;
   Name: PChar;
  end;

const

 ATagCount = 65;
 ATags: array [0..ATagCount - 1] of ATagRec = (
    (ID: tagShowFrame;           Name: 'ShowFrame'),
    (ID: tagDefineShape;         Name: 'DefineShape'),
    (ID: tagDefineShape2;        Name: 'DefineShape2'),
    (ID: tagDefineShape3;        Name: 'DefineShape3'),
    (ID: tagPlaceObject2;        Name: 'PlaceObject2'),
    (ID: tagRemoveObject2;       Name: 'RemoveObject2'),
    (ID: tagPlaceObject;         Name: 'PlaceObject'),
    (ID: tagRemoveObject;        Name: 'RemoveObject'),
    (ID: tagDoAction;            Name: 'DoAction'),
    (ID: tagDefineBits;          Name: 'DefineBits'),
    (ID: tagDefineButton;        Name: 'DefineButton'),
    (ID: tagJPEGTables;          Name: 'JPEGTables'),
    (ID: tagDefineFont;          Name: 'DefineFont'),
    (ID: tagDefineText;          Name: 'DefineText'),
    (ID: tagDefineFontInfo;      Name: 'DefineFontInfo'),
    (ID: tagDefineFontInfo2;     Name: 'DefineFontInfo2'),
    (ID: tagDefineSound;         Name: 'DefineSound'),
    (ID: tagStartSound;          Name: 'StartSound'),
    (ID: tagDefineButtonSound;   Name: 'DefineButtonSound'),
    (ID: tagSoundStreamHead;     Name: 'SoundStreamHead'),
    (ID: tagSoundStreamBlock;    Name: 'SoundStreamBlock'),
    (ID: tagDefineBitsLossless;  Name: 'DefineBitsLossless'),
    (ID: tagDefineBitsJPEG2;     Name: 'DefineBitsJPEG2'),
    (ID: tagDefineButtonCxform;  Name: 'DefineButtonCxform'),
    (ID: tagDefineText2;         Name: 'DefineText2'),
    (ID: tagDefineButton2;       Name: 'DefineButton2'),
    (ID: tagDefineBitsJPEG3;     Name: 'DefineBitsJPEG3'),
    (ID: tagDefineBitsLossless2; Name: 'DefineBitsLossless2'),
    (ID: tagDefineEditText;      Name: 'DefineEditText'),
    (ID: tagDefineSprite;        Name: 'DefineSprite'),
    (ID: tagNameCharacter;       Name: 'NameCharacter'),
    (ID: tagFrameLabel;          Name: 'FrameLabel'),
    (ID: tagSoundStreamHead2;    Name: 'SoundStreamHead2'),
    (ID: tagDefineMorphShape;    Name: 'DefineMorphShape'),
    (ID: tagDefineFont2;         Name: 'DefineFont2'),
    (ID: tagExportAssets;        Name: 'ExportAssets'),
    (ID: tagImportAssets;        Name: 'ImportAssets'),
    (ID: tagDoInitAction;        Name: 'DoInitAction'),
    (ID: tagDefineVideoStream;   Name: 'DefineVideoStream'),
    (ID: tagVideoFrame;          Name: 'VideoFrame'),
    (ID: tagEnd;                 Name: 'End'),
    (ID: tagProtect;             Name: 'Protect'),
    (ID: tagSetBackgroundColor;  Name: 'SetBackgroundColor'),
    (ID: tagEnableDebugger;      Name: 'EnableDebugger'),
    (ID: tagEnableDebugger2;     Name: 'EnableDebugger2'),
    (ID: tagScriptLimits;        Name: 'ScriptLimits'),
    (ID: tagSetTabIndex;         Name: 'SetTabIndex'),

    (ID: tagDefineShape4;        Name: 'DefineShape4'),
    (ID: tagFileAttributes;      Name: 'FileAttributes'),
    (ID: tagPlaceObject3;        Name: 'PlaceObject3'),
    (ID: tagImportAssets2;       Name: 'ImportAssets2'),
    (ID: tagDefineFontAlignZones;Name: 'DefineFontAlignZones'),
    (ID: tagCSMTextSettings;     Name: 'CSMTextSettings'),
    (ID: tagDefineFont3;         Name: 'DefineFont3'),
    (ID: tagMetadata;            Name: 'Metadata'),
    (ID: tagDefineScalingGrid;   Name: 'DefineScalingGrid'),
    (ID: tagDefineMorphShape2;   Name: 'DefineMorphShape2'),
    (ID: tagProductInfo;         Name: 'ProductInfo'),

    (ID: tagDoABC;               Name: 'DoABC'),
    (ID: tagSymbolClass;         Name: 'SymbolClass'),
    (ID: tagStartSound2;         Name: 'StartSound2'),
    (ID: tagDefineBinaryData;    Name: 'DefineBinaryData'),
    (ID: tagDefineFontName;      Name: 'DefineFontName'),
    (ID: tagDefineSceneAndFrameLabelData; Name: 'DefineSceneAndFrameLabelData'),
    (ID: tagErrorTag;            Name: 'Error Tag')
    );

Function GetTagName(ID: word): string;
 var il: integer;
begin
 Result := '';
 for il := 0 to ATagCount - 1 do
  if ATags[il].ID = ID then
    begin
      Result := ATags[il].Name;
      Break;
    end;
 if Result = '' then Result := 'Unknown ' + IntToStr(ID);
end;

Function GetTagID(name: string): integer;
 var il: integer;
begin
 Result := -1;
 for il := 0 to ATagCount - 1 do
  if AnsiSameText(ATags[il].Name, name) then
    begin
      Result := ATags[il].ID;
      Break;
    end;
 if (Result = -1) and (Pos('tag', name) = 1) then
   try
     Result := StrToInt(Copy(name, 4, 255));
   except
     Result := -1;
   end;
   
 if (Result = tagErrorTag) then Result := -1;
end;

const
 AActCount = 102;
 AActions: array [0..AActCount - 1] of ATagRec = (
// SWF 3
   (ID: ActionPlay;            Name: 'Play'),
   (ID: ActionStop;            Name: 'Stop'),
   (ID: ActionNextFrame;       Name: 'NextFrame'),
   (ID: ActionPreviousFrame;   Name: 'PreviousFrame'),
   (ID: ActionGotoFrame;       Name: 'GotoFrame'),
   (ID: ActionGoToLabel;       Name: 'GoToLabel'),
   (ID: ActionWaitForFrame;    Name: 'WaitForFrame'),
   (ID: ActionGetURL;          Name: 'GetURL'),
   (ID: ActionStopSounds;      Name: 'StopSounds'),
   (ID: ActionToggleQuality;   Name: 'ToggleQuality'),
   (ID: ActionSetTarget;       Name: 'SetTarget'),
//SWF 4
   (ID: ActionAdd;             Name: 'Add'),
   (ID: ActionDivide;          Name: 'Divide'),
   (ID: ActionMultiply;        Name: 'Multiply'),
   (ID: ActionSubtract;        Name: 'Subtract'),
   (ID: ActionEquals;          Name: 'Equals'),
   (ID: ActionLess;            Name: 'Less'),
   (ID: ActionAnd;             Name: 'And'),
   (ID: ActionNot;             Name: 'Not'),
   (ID: ActionOr;              Name: 'Or'),
   (ID: ActionStringAdd;       Name: 'StringAdd'),
   (ID: ActionStringEquals;    Name: 'StringEquals'),
   (ID: ActionStringExtract;   Name: 'StringExtract'),
   (ID: ActionStringLength;    Name: 'StringLength'),
   (ID: ActionMBStringExtract; Name: 'MBStringExtract'),
   (ID: ActionMBStringLength;  Name: 'MBStringLength'),
   (ID: ActionStringLess;      Name: 'StringLess'),
   (ID: ActionPop;             Name: 'Pop'),
   (ID: ActionPush;            Name: 'Push'),
   (ID: ActionAsciiToChar;     Name: 'AsciiToChar'),
   (ID: ActionCharToAscii;     Name: 'CharToAscii'),
   (ID: ActionToInteger;       Name: 'ToInteger'),
   (ID: ActionMBAsciiToChar;   Name: 'MBAsciiToChar'),
   (ID: ActionMBCharToAscii;   Name: 'MBCharToAscii'),
   (ID: ActionCall;            Name: 'Call'),
   (ID: ActionIf;              Name: 'If'),
   (ID: ActionJump;            Name: 'Jump'),
   (ID: ActionGetVariable;     Name: 'GetVariable'),
   (ID: ActionSetVariable;     Name: 'SetVariable'),
   (ID: ActionGetURL2;         Name: 'GetURL2'),
   (ID: ActionGetProperty;     Name: 'GetProperty'),
   (ID: ActionGotoFrame2;      Name: 'GotoFrame2'),
   (ID: ActionRemoveSprite;    Name: 'RemoveSprite'),
   (ID: ActionSetProperty;     Name: 'SetProperty'),
   (ID: ActionSetTarget2;      Name: 'SetTarget2'),
   (ID: ActionStartDrag;       Name: 'StartDrag'),
   (ID: ActionWaitForFrame2;   Name: 'WaitForFrame2'),
   (ID: ActionCloneSprite;     Name: 'CloneSprite'),
   (ID: ActionEndDrag;         Name: 'EndDrag'),
   (ID: ActionGetTime;         Name: 'GetTime'),
   (ID: ActionRandomNumber;    Name: 'RandomNumber'),
   (ID: ActionTrace;           Name: 'Trace'),
   (ID: ActionFSCommand2;      Name: 'FSCommand2'),
//SWF 5
   (ID: ActionCallFunction;    Name: 'CallFunction'),
   (ID: ActionCallMethod;      Name: 'CallMethod'),
   (ID: ActionConstantPool;    Name: 'ConstantPool'),
   (ID: ActionDefineFunction;  Name: 'DefineFunction'),
   (ID: ActionDefineLocal;     Name: 'DefineLocal'),
   (ID: ActionDefineLocal2;    Name: 'DefineLocal2'),
   (ID: ActionDelete;          Name: 'Delete'),
   (ID: ActionDelete2;         Name: 'Delete2'),
   (ID: ActionEnumerate;       Name: 'Enumerate'),
   (ID: ActionEquals2;         Name: 'Equals2'),
   (ID: ActionGetMember;       Name: 'GetMember'),
   (ID: ActionInitArray;       Name: 'InitArray'),
   (ID: ActionInitObject;      Name: 'InitObject'),
   (ID: ActionNewMethod;       Name: 'NewMethod'),
   (ID: ActionNewObject;       Name: 'NewObject'),
   (ID: ActionSetMember;       Name: 'SetMember'),
   (ID: ActionTargetPath;      Name: 'TargetPath'),
   (ID: ActionWith;            Name: 'With'),
   (ID: ActionToNumber;        Name: 'ToNumber'),
   (ID: ActionToString;        Name: 'ToString'),
   (ID: ActionTypeOf;          Name: 'TypeOf'),
   (ID: ActionAdd2;            Name: 'Add2'),
   (ID: ActionLess2;           Name: 'Less2'),
   (ID: ActionModulo;          Name: 'Modulo'),
   (ID: ActionBitAnd;          Name: 'BitAnd'),
   (ID: ActionBitLShift;       Name: 'BitLShift'),
   (ID: ActionBitOr;           Name: 'BitOr'),
   (ID: ActionBitRShift;       Name: 'BitRShift'),
   (ID: ActionBitURShift;      Name: 'BitURShift'),
   (ID: ActionBitXor;          Name: 'BitXor'),
   (ID: ActionDecrement;       Name: 'Decrement'),
   (ID: ActionIncrement;       Name: 'Increment'),
   (ID: ActionPushDuplicate;   Name: 'PushDuplicate'),
   (ID: ActionReturn;          Name: 'Return'),
   (ID: ActionStackSwap;       Name: 'StackSwap'),
   (ID: ActionStoreRegister;   Name: 'StoreRegister'),
//SWF 6
   (ID: ActionInstanceOf;      Name: 'InstanceOf'),
   (ID: ActionEnumerate2;      Name: 'Enumerate2'),
   (ID: ActionStrictEquals;    Name: 'StrictEquals'),
   (ID: ActionGreater;         Name: 'Greater'),
   (ID: ActionStringGreater;   Name: 'StringGreater'),
//SWF 7
   (ID: ActionDefineFunction2; Name: 'DefineFunction2'),
   (ID: ActionExtends;         Name: 'Extends'),
   (ID: ActionCastOp;          Name: 'CastOp'),
   (ID: ActionImplementsOp;    Name: 'ImplementsOp'),
   (ID: ActionTry;             Name: 'Try'),
   (ID: ActionThrow;           Name: 'Throw'),
   (ID: ActionByteCode;        Name: 'ByteCode'),
   (ID: actionOffsetWork;      Name: 'Offset marker (only for work)')
   );

Function GetActionName(ID: word; prefix: boolean = true): string;
  var il: integer;
begin
 Result := '';
 for il := 0 to AActCount - 1 do
  if AActions[il].ID = ID then
    begin
      Result := AActions[il].Name;
      Break;
    end;
 if Result = '' then Result := 'Unknown ' + IntToStr(ID) else
   if prefix and (ID <> actionOffsetWork) then
     Result := 'Action' + Result;
end;

Function GetActionID(name: string): integer;
 var il: integer;
begin
 Result := -1;
 if AnsiSameText(sc_Offset, name) then Result := actionOffsetWork else
  begin
   for il := 0 to AActCount - 1 do
    if AnsiSameText(AActions[il].Name, name) then
      begin
        Result := AActions[il].ID;
        Break;
      end;
  end;
end;

function GetButtonEventFlagsName(EF: TSWFStateTransitions): string;
begin
 if IdleToOverUp in EF then result := 'OnRollOverActions, ' else result := '';
 if OverUpToIdle in EF then result := result + 'OnRollOutActions, ';
 if OverUpToOverDown in EF then result := result + 'OnPressActions, ';
 if OverDownToOverUp in EF then result := result + 'OnReleaseActions, ';
 if OutDownToOverDown in EF then result := result + 'OnDragOverActions, ';
 if OverDownToOutDown in EF then result := result + 'OnDragOutActions, ';
 if OutDownToIdle in EF then result := result + 'OnReleaseOutsideActions, ';
 if IdleToOverDown in EF then result := result + 'OnMenuDragOverActions, ';
 if OverDownToIdle in EF then result := result + 'OnMenuDragOutActions, ';

 if Result<>'' then Delete(Result, Length(Result)-1, 2);
end;

function GetClipEventFlagsName(EF: TSWFClipEvents):string;
begin
  if ceKeyUp in EF then result := 'OnKeyUp, ' else result := '';
  if ceKeyDown in EF then result := result + 'OnKeyDown, ';
  if ceMouseUp in EF then result := result + 'OnMouseUp, ';
  if ceMouseDown in EF then result := result + 'OnMouseDown, ';
  if ceMouseMove in EF then result := result + 'OnMouseMove, ';
  if ceUnload in EF then result := result + 'OnUnload, ';
  if ceEnterFrame in EF then result := result + 'OnEnterFrame, ';
  if ceLoad in EF then result := result + 'OnLoad, ';
  if ceDragOver in EF then result := result + 'OnDragOver, ';
  if ceRollOut in EF then result := result + 'OnRollOut, ';
  if ceRollOver in EF then result := result + 'OnRollOver, ';
  if ceReleaseOutside in EF then result := result + 'OnReleaseOutside, ';
  if ceRelease in EF then result := result + 'OnRelease, ';
  if cePress in EF then result := result + 'OnPress, ';
  if ceInitialize in EF then result := result + 'OnInitialize, ';
  if ceData in EF then result := result + 'OnData, ';
  if ceConstruct in EF then result := result + 'OnConstruct, ';
  if ceKeyPress in EF then result := result + 'OnKeyPress, ';
  if ceDragOut in EF then result := result + 'OnDragOut, ';

  if Result<>'' then Delete(Result, Length(Result)-1, 2);
end;

Function GetFilterFromName(s: string): TSWFFilterID;
 var il: byte;
begin
 Result := fidDropShadow;
 for il := 0 to 7 do
   if AnsiSameText(sc_AFilterNames[il], S) then Result := TSWFFilterID(il);
end;

Function GetFillTypeName(FT: TSWFFillType; prefix: boolean = true): string;
begin
  Case FT of
    SWFFillSolid: Result := 'Solid';
    SWFFillLinearGradient: Result := 'LinearGradient';
    SWFFillRadialGradient: Result := 'RadialGradient';
    SWFFillFocalGradient: Result := 'FocalGradient';
    SWFFillTileBitmap: Result := 'TileBitmap';
    SWFFillClipBitmap: Result := 'ClipBitmap';
    SWFFillNonSmoothTileBitmap: Result := 'NonSmoothTileBitmap';
    SWFFillNonSmoothClipBitmap: Result := 'NonSmoothClipBitmap';
  end;
  if prefix then Result := 'SWFFill' + Result;
end;

function GetFillTypeFromName(s: string): TSWFFillType;
begin
  if AnsiSameText(S, 'Solid') then Result := SWFFillSolid else
  if AnsiSameText(S, 'LinearGradient') then Result := SWFFillLinearGradient else
  if AnsiSameText(S, 'RadialGradient') then Result := SWFFillRadialGradient else
  if AnsiSameText(S, 'FocalGradient') then Result := SWFFillFocalGradient else
  if AnsiSameText(S, 'TileBitmap') then Result := SWFFillTileBitmap else
  if AnsiSameText(S, 'ClipBitmap') then Result := SWFFillClipBitmap else
  if AnsiSameText(S, 'NonSmoothTileBitmap') then Result := SWFFillNonSmoothTileBitmap else
  if AnsiSameText(S, 'NonSmoothClipBitmap') then Result := SWFFillNonSmoothClipBitmap
   else Result := SWFFillSolid;
end;

const
 AInstructCount = 158;
 AInstrucs: array [0..AInstructCount - 1] of ATagRec = (
  (ID: opBkpt;            Name: 'Bkpt'),
  (ID: opNop;             Name: 'Nop'),
	(ID: opThrow;           Name: 'Throw'),
	(ID: opGetSuper;        Name: 'GetSuper'),
	(ID: opSetSuper;        Name: 'SetSuper'),
	(ID: opDxns;            Name: 'Dxns'),
	(ID: opDxnsLate;        Name: 'DxnsLate'),
	(ID: opKill;            Name: 'Kill'),
	(ID: opLabel;           Name: 'Label'),
	(ID: opIfNlt;           Name: 'IfNlt'),
	(ID: opIfNle;           Name: 'IfNle'),
	(ID: opIfNgt;           Name: 'IfNgt'),
	(ID: opIfNge;           Name: 'IfNge'),
	(ID: opJump;            Name: 'Jump'),
	(ID: opIfTrue;          Name: 'IfTrue'),
	(ID: opIfFalse;         Name: 'IfFalse'),
	(ID: opIfEq;            Name: 'IfEq'),
	(ID: opIfNe;            Name: 'IfNe'),
	(ID: opIfLt;            Name: 'IfLt'),
	(ID: opIfLe;            Name: 'IfLe'),
	(ID: opIfGt;            Name: 'IfGt'),
	(ID: opIfGe;            Name: 'IfGe'),
	(ID: opIfStrictEq;      Name: 'IfStrictEq'),
	(ID: opIfStrictNe;      Name: 'IfStrictNe'),
	(ID: opLookupSwitch;    Name: 'LookupSwitch'),
	(ID: opPushWith;        Name: 'PushWith'),
	(ID: opPopScope;        Name: 'PopScope'),
	(ID: opNextName;        Name: 'NextName'),
	(ID: opHasNext;         Name: 'HasNext'),
	(ID: opPushNull;        Name: 'PushNull'),
	(ID: opPushUndefined;   Name: 'PushUndefined'),
	(ID: opPushConstant;    Name: 'PushConstant'),
	(ID: opNextValue;       Name: 'NextValue'),
	(ID: opPushByte;        Name: 'PushByte'),
	(ID: opPushShort;       Name: 'PushShort'),
	(ID: opPushTrue;        Name: 'PushTrue'),
	(ID: opPushFalse;       Name: 'PushFalse'),
	(ID: opPushNan;         Name: 'PushNan'),
	(ID: opPop;             Name: 'Pop'),
	(ID: opDup;             Name: 'Dup'),
	(ID: opSwap;            Name: 'Swap'),
	(ID: opPushString;      Name: 'PushString'),
	(ID: opPushInt;         Name: 'PushInt'),
	(ID: opPushUInt;        Name: 'PushUInt'),
	(ID: opPushDouble;      Name: 'PushDouble'),
	(ID: opPushScope;       Name: 'PushScope'),
	(ID: opPushNameSpace;   Name: 'PushNameSpace'),
	(ID: opHasNext2;        Name: 'HasNext2'),
	(ID: opNewFunction;     Name: 'NewFunction'),
	(ID: opCall;            Name: 'Call'),
	(ID: opConstruct;       Name: 'Construct'),
	(ID: opCallMethod;      Name: 'CallMethod'),
	(ID: opCallStatic;      Name: 'CallStatic'),
	(ID: opCallSuper;       Name: 'CallSuper'),
	(ID: opCallProperty;    Name: 'CallProperty'),
	(ID: opReturnVoid;      Name: 'ReturnVoid'),
	(ID: opReturnValue;     Name: 'ReturnValue'),
	(ID: opConstructSuper;  Name: 'ConstructSuper'),
	(ID: opConstructProp;   Name: 'ConstructProp'),
	(ID: opCallSuperId;     Name: 'CallSuperId'),
	(ID: opCallPropLex;     Name: 'CallPropLex'),
	(ID: opCallInterface;   Name: 'CallInterface'),
	(ID: opCallSuperVoid;   Name: 'CallSuperVoid'),
	(ID: opCallPropVoid;    Name: 'CallPropVoid'),
	(ID: opNewObject;       Name: 'NewObject'),
	(ID: opNewArray;        Name: 'NewArray'),
	(ID: opNewActivation;   Name: 'NewActivation'),
	(ID: opNewClass;        Name: 'NewClass'),
	(ID: opGetDescendants;  Name: 'GetDescendants'),
	(ID: opNewCatch;        Name: 'NewCatch'),
	(ID: opFindPropStrict;  Name: 'FindPropStrict'),
	(ID: opFindProperty;    Name: 'FindProperty'),
	(ID: opFindDef;         Name: 'FindDef'),
	(ID: opGetLex;          Name: 'GetLex'),
	(ID: opSetProperty;     Name: 'SetProperty'),
	(ID: opGetLocal;        Name: 'GetLocal'),
	(ID: opSetLocal;        Name: 'SetLocal'),
	(ID: opGetGlobalScope;  Name: 'GetGlobalScope'),
	(ID: opGetScopeObject;  Name: 'GetScopeObject'),
	(ID: opGetProperty;     Name: 'GetProperty'),
	(ID: opGetPropertyLate; Name: 'GetPropertyLate'),
	(ID: opInitProperty;    Name: 'InitProperty'),
	(ID: opSetPropertyLate; Name: 'SetPropertyLate'),
	(ID: opDeleteProperty;  Name: 'DeleteProperty'),
	(ID: opDeletePropertyLate; Name: 'DeletePropertyLate'),
	(ID: opGetSlot;         Name: 'GetSlot'),
	(ID: opSetSlot;         Name: 'SetSlot'),
	(ID: opGetGlobalSlot;   Name: 'GetGlobalSlot'),
	(ID: opSetGlobalSlot;   Name: 'SetGlobalSlot'),
	(ID: opConvert_s;       Name: 'Convert_s'),
	(ID: opEsc_xelem;       Name: 'Esc_xelem'),
	(ID: opEsc_xattr;       Name: 'Esc_xattr'),
	(ID: opConvert_i;       Name: 'Convert_i'),
	(ID: opConvert_u;       Name: 'Convert_u'),
	(ID: opConvert_d;       Name: 'Convert_d'),
	(ID: opConvert_b;       Name: 'Convert_b'),
	(ID: opConvert_o;       Name: 'Convert_o'),
	(ID: opCoerce;          Name: 'Coerce'),
	(ID: opCoerce_b;        Name: 'Coerce_b'),
	(ID: opCoerce_a;        Name: 'Coerce_a'),
	(ID: opCoerce_i;        Name: 'Coerce_i'),
	(ID: opCoerce_d;        Name: 'Coerce_d'),
	(ID: opCoerce_s;        Name: 'Coerce_s'),
	(ID: opAsType;          Name: 'AsType'),
	(ID: opAsTypeLate;      Name: 'AsTypeLate'),
	(ID: opCoerce_u;        Name: 'Coerce_u'),
	(ID: opCoerce_o;        Name: 'Coerce_o'),
	(ID: opNegate;          Name: 'Negate'),
	(ID: opIncrement;       Name: 'Increment'),
	(ID: opIncLocal;        Name: 'IncLocal'),
	(ID: opDecrement;       Name: 'Decrement'),
	(ID: opDecLocal;        Name: 'DecLocal'),
	(ID: opTypeOf;          Name: 'TypeOf'),
	(ID: opNot;             Name: 'Not'),
	(ID: opBitNot;          Name: 'BitNot'),
	(ID: opConcat;          Name: 'Concat'),
	(ID: opAdd_d;           Name: 'Add_d'),
	(ID: opAdd;             Name: 'Add'),
	(ID: opSubTract;        Name: 'SubTract'),
	(ID: opMultiply;        Name: 'Multiply'),
	(ID: opDivide;          Name: 'Divide'),
	(ID: opModulo;          Name: 'Modulo'),
	(ID: opLShift;          Name: 'LShift'),
	(ID: opRShift;          Name: 'RShift'),
	(ID: opURShift;         Name: 'URShift'),
	(ID: opBitAnd;          Name: 'BitAnd'),
	(ID: opBitOr;           Name: 'BitOr'),
	(ID: opBitXor;          Name: 'BitXor'),
	(ID: opEquals;          Name: 'Equals'),
	(ID: opStrictEquals;    Name: 'StrictEquals'),
	(ID: opLessThan;        Name: 'LessThan'),
	(ID: opLessEquals;      Name: 'LessEquals'),
	(ID: opGreaterThan;     Name: 'GreaterThan'),
	(ID: opGreaterEquals;   Name: 'GreaterEquals'),
	(ID: opInstanceOf;      Name: 'InstanceOf'),
	(ID: opIsType;          Name: 'IsType'),
	(ID: opIsTypeLate;      Name: 'IsTypeLate'),
	(ID: opIn;              Name: 'In'),
	(ID: opIncrement_i;     Name: 'Increment_i'),
	(ID: opDecrement_i;     Name: 'Decrement_i'),
	(ID: opInclocal_i;      Name: 'Inclocal_i'),
	(ID: opDeclocal_i;      Name: 'Declocal_i'),
	(ID: opNegate_i;        Name: 'Negate_i'),
	(ID: opAdd_i;           Name: 'Add_i'),
	(ID: opSubtract_i;      Name: 'Subtract_i'),
	(ID: opMultiply_i;      Name: 'Multiply_i'),
	(ID: opGetLocal0;       Name: 'GetLocal0'),
	(ID: opGetLocal1;       Name: 'GetLocal1'),
	(ID: opGetLocal2;       Name: 'GetLocal2'),
	(ID: opGetLocal3;       Name: 'GetLocal3'),
	(ID: opSetLocal0;       Name: 'SetLocal0'),
	(ID: opSetLocal1;       Name: 'SetLocal1'),
	(ID: opSetLocal2;       Name: 'SetLocal2'),
	(ID: opSetLocal3;       Name: 'SetLocal3'),
	(ID: opDebug;           Name: 'Debug'),
	(ID: opDebugLine;       Name: 'DebugLine'),
	(ID: opDebugFile;       Name: 'DebugFile'),
	(ID: opBkptLine;        Name: 'BkptLine')
 );

Function GetInstructionName(ID: byte; prefix: string = ''): string;
  var il: integer;
begin
 Result := '';
 for il := 0 to AInstructCount - 1 do
  if AInstrucs[il].ID = ID then
    begin
      Result := AInstrucs[il].Name;
      Break;
    end;
 if Result = '' then Result := '$' + IntToHex(ID, 2) else
   if prefix <> '' then
     Result := prefix + Result;
end;

end.

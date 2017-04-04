//*******************************************************//
//                                                       //
//                      DelphiFlash.com                  //
//         Copyright (c) 2004-2008 FeatherySoft, Inc.    //
//                    info@delphiflash.com               //
//                                                       //
//*******************************************************//

//  Description:  SWF constants
//  Last update:  12 mar 2008

unit SWFConst;

interface

Uses Windows;

const
 SDKVer = '2.3';

 SWFLevel = 0;
 FlashLevel = 1;

 SWFVer1 = 1;
 SWFVer2 = 2;
 SWFVer3 = 3;
 SWFVer4 = 4;
 SWFVer5 = 5;
 SWFVer6 = 6;
 SWFVer7 = 7;
 SWFVer8 = 8;
 SWFVer9 = 9;

 SWFSign = 'FWS';
 SWFSignCompress = 'CWS';

 TWIPS = 20;
 
type

 TSWFHeader = packed record
   SIGN: array [0..2] of Char;
   Version: byte;
   FileSize: Longint;
   MovieRect: TRect;
   FPS: word;
   FramesCount: word;
 end;

  TSWFSystemCoord = (scTwips, scPix);
  TSWFHeaderPart = (hpAll, hp1, hp2);

const
  SizeOfhp1 = 8;

type
  recRect = packed record
    Xmin, Xmax, Ymin, Ymax: longint;
  end;

  recRGB = record
   R, G, B : Byte;
  end;

  recRGBA = record
   R, G, B, A : Byte;
  end;
  // A = $ff - full color

  recMATRIX = record
   hasScale, hasSkew: boolean;
   ScaleX, ScaleY,
   SkewX, SkewY,   // some Skew0, Skew1
   TranslateX, TranslateY: longint;
  end;

  recColorTransform = record
   addR, addG, addB, addA,
   multR, multG, multB, multA: Smallint;
   hasADD, hasMULT, hasAlpha: boolean;
  end;
  CXFORMWITHALPHA = recColorTransform;

  TCharSets = set of char;
const

  UppercaseChars : TCharSets = ['A'..'Z'];
  LowercaseChars : TCharSets = ['a'..'z'];
  PunctuationChars : TCharSets = ['~','@','#','!','%','&','*','(',')','-','+','<','>',
                                  '{','}','[',']',':',';',',','.','|','/','\','?','''','"'];
  NumberChars : TCharSets = ['0'..'9'];
  AllEnglishChars : TCharSets = [#32..#127];
  AllChars : TCharSets = [#32..#255];


  SWFLangNone = 0;
  SWFLangLatin = 1;
  SWFLangJapanese = 2;
  SWFLangKorean = 3;
  SWFLangSChinese = 4;
  SWFLangTChinese = 5;

  encodeANSI = 0;
  encodeShiftJIS = 1;
  encodeUnicode = 2;

// for  Get/SetProperty
  fpPosX           = 0;
  fpPosY           = 1;
  fpScaleX         = 2;
  fpScaleY         = 3;
  fpCurFrame       = 4;  // read only
  fpTotalframes    = 5;  // read only
  fpAlpha          = 6;
  fpVisible        = 7;
  fpWidth          = 8;  // read only
  fpHeight         = 9;  // read only
  fpRotate         = 10;
  fpTarget         = 11;
  fpLastFrameLoaded= 12;
  fpName           = 13;
  fpDropTarget     = 14;
  fpURL            = 15;
  fpHighQuality 	 = 16;	// global
  fpFocusRect 	   = 17;	// global
  fpSoundBufferTime= 18;	// global
  fpQuality        = 19;
  fpXMouse         = 20;
  fpYMouse         = 21;

  SWFFillSolid 	 = $00;
  SWFFillLinearGradient = $10;
  SWFFillRadialGradient = $12;
  SWFFillFocalGradient = $13;
  SWFFillTileBitmap = $40;
  SWFFillClipBitmap = $41;
  SWFFillNonSmoothTileBitmap = $42;
  SWFFillNonSmoothClipBitmap = $43;

type
  TSWFFillType = SWFFillSolid..SWFFillNonSmoothClipBitmap;
  TFillImageMode = (fmClip, fmFit, fmTile);
  TStyleChangeMode = (scmFirst, scmLast);
  TShapeRecType = (EndShapeRecord, StyleChangeRecord, StraightEdgeRecord, CurvedEdgeRecord);
  TSWFValueType = (vtString, vtFloat, vtNull, vtUndefined, vtRegister, vtBoolean, vtDouble,
                vtInteger, vtConstant8, vtConstant16, vtDefault);
  // vtDefault - non flash type, only for works

  TSWFButtonState = (bsUp, bsDown, bsOver, bsHitTest);
  TSWFButtonStates = set of TSWFButtonState;
  TSWFStateTransition = (IdleToOverUp, OverUpToIdle, OverUpToOverDown, OverDownToOverUp, OutDownToOverDown,
                      OverDownToOutDown, OutDownToIdle, IdleToOverDown, OverDownToIdle);
  TSWFStateTransitions = set of TSWFStateTransition;
  TSWFClipEvent = (ceKeyUp, ceKeyDown, ceMouseUp, ceMouseDown, ceMouseMove, ceUnload,
                   ceEnterFrame, ceLoad, ceDragOver, ceRollOut, ceRollOver,
                   ceReleaseOutside, ceRelease, cePress, ceInitialize, ceData,
                   ceConstruct, ceKeyPress, ceDragOut);
  TSWFClipEvents = set of TSWFClipEvent;

  TCompileOption = (coLocalVarToRegister, coDefineFunction2, coFlashLite);
  TCompileOptions = set of TCompileOption;

const
  SWFButtonStateAll: TSWFButtonStates = [bsUp..bsHitTest];

  fvUndefined = 'FlashVar_undefined';
  fvNull = 'FlashVar_null';

  //  Text align
  taLeft    = 0;
  taRight  	= 1;
  taCenter	= 2;
  taJustify	= 3;

type
  TSWFTextAlign = taLeft..taJustify;

  //SpreadMode
const
  smPad = 0;
  smReflect = 1;
  smRepeat = 2;

type
  TSWFSpreadMode = smPad..smRepeat;

  //InterpolationMode
const
  imNormalRGB = 0;
  imLinearRGB = 1;

type
  TSWFInterpolationMode = imNormalRGB..imLinearRGB;

// === BlendMode ===
const
  bmNone = 0;
  bmNormal = 1;
  bmLayer = 2;
  bmMultiply = 3;
  bmScreen = 4;
  bmLighten = 5;
  bmDarken = 6;
  bmDifference = 7;
  bmAdd = 8;
  bmSubtract = 9;
  bmInvert = 10;
  bmAlpha = 11;
  bmErase = 12;
  bmOverlay = 13;
  bmHardlight = 14;

type
  TSWFBlendMode = bmNone..bmHardlight;

// ===  Filter ID  ===
const
  fidDropShadow = 0;
  fidBlur = 1;
  fidGlow = 2;
  fidBevel = 3;
  fidGradientGlow = 4;
  fidConvolution = 5;
  fidColorMatrix = 6;
  fidGradientBevel = 7;

type
  TSWFFilterID = fidDropShadow..fidGradientBevel;

const
  BMP_8bit = 3;
  BMP_15bit = 4;
  BMP_24bit = 5;
  BMP_32bit = BMP_24bit; // only for DefineBitsLossless2
  BMP_32bitWork = 1;

// === Passes type ===
  pasLow = 1;
  pasMedium = 2;
  pasHigh = 3;

// === Video codec id ====
  codecSorenson = 2;
  codecScreenVideo = 3;
  codecVP6 = 4;
  codecAlphaVP6 = 5;
  codecScreenVideo2 = 6;

  GradientSizeXY = $8000;
  specFixed = $FFFF + 1;
  specFixed2//: int64 = $FFFFFFFF + 1;
             =         $100000000;
  //IEEEMask = $FFFFFFFFFFFFFFFF;

  // GetURL2 SendVarsMethod
  svmNone	= 0;
  svmGET 	= 1;
  svmPOST	= 2;

// ============  Control tags ========================
  tagEnd    		   = 0;
  tagShowFrame 	   = 1;
  tagSetBackgroundColor = 9;
  tagFrameLabel	   = 43;
  tagProtect		   = 24;
  tagExportAssets  = 56;
  tagImportAssets  = 57;
  tagScriptLimits  = 65;
  tagSetTabIndex   = 66;

  tagEnableDebugger  = 58;
  tagEnableDebugger2 = 64;
  tagExtDebuggerInfo = 63; // non officially
  tagProductInfo     = 41; // non officially

// ============  Shape tags ==========================
  tagDefineShape	 = 2;
  tagRemoveObject  = 5;
  tagPlaceObject 	 = 4;

  tagDefineBits 	  = 6;
  tagJPEGTables 	  = 8;
  tagDefineBitsLossless  = 20;
  tagDefineBitsLossless2 = 36;
  tagDefineBitsJPEG2 = 21;
  tagDefineBitsJPEG3 = 35;

  tagDefineShape2	 = 22;
  tagDefineShape3	 = 32;
  tagPlaceObject2	 = 26;
  tagRemoveObject2 = 28;

  tagDefineMorphShape	= 46;

  tagDefineSprite	  = 39;
  tagNameCharacter	= 40; // undocumented

// ===================== SOUND ===========================
  Snd5k  = 0;
  Snd11k = 1;
  Snd22k = 2;
  Snd44k = 3;

  snd_PCM = 0;
  snd_ADPCM = 1;
  snd_MP3 = 2;
  snd_PCM_LE = 3;
  snd_NellymoserMono = 5;
  snd_Nellymoser = 6;

  tagDefineSound  = 14;
  tagStartSound	  = 15;
  tagSoundStreamHead	 = 18;
  tagSoundStreamBlock  = 19;
  tagSoundStreamHead2	 = 45;

  tagDefineButtonSound = 17;

// ===================== Font ==============================
  tagDefineFont	= 10;
  tagDefineText	= 11;
  tagDefineFontInfo	= 13;
  tagDefineText2	 = 33;
  tagDefineFont2	= 48;
  tagDefineFontInfo2	= 62;
  tagDefineEditText = 37;

// ===================== Buttons ===========================
  tagDefineButton  = 7;
  tagDefineButton2 = 34;

  tagDefineButtonCxform  = 23;

   //Key Codes
  ID_KEY_LEFT		  = $01;
  ID_KEY_RIGHT		  = $02;
  ID_KEY_HOME		  = $03;
  ID_KEY_END		  = $04;
  ID_KEY_INSERT		  = $05;
  ID_KEY_DELETE		  = $06;
  ID_KEY_CLEAR		  = $07;
  ID_KEY_BACKSPACE	  = $08;
  ID_KEY_ENTER		  = $0D;
  ID_KEY_UP		  = $0E;
  ID_KEY_DOWN		  = $0F;
  ID_KEY_PAGE_UP	  = $10;
  ID_KEY_PAGE_DOWN	  = $11;
  ID_KEY_TAB		  = $12;
  ID_KEY_ESCAPE		  = $13;

// ===================== Action tags =======================
  tagDoAction		      = 12;
  tagDoInitAction     = 59;

  actionGotoFrame	    = $81;
  actionNextFrame	    = $04;
  actionPreviousFrame = $05;
  actionPlay	      	= $06;
  actionStop	      	= $07;
  actionToggleQuality = $08;
  actionStopSounds	  = $09;

  actionSetTarget     = $8B;
  actionGetURL	    	= $83;
  actionGotoLabel	    = $8C;
  actionWaitForFrame	= $8A;

  actionPush	        = $96;
  actionPop           = $17;
  actionGotoFrame2	= $9F;
  actionGetVariable = $1C;
  actionSetVariable	= $1D;

  actionAdd		= $0A;
  actionSubtract	= $0B;
  actionMultiply	= $0C;
  actionDivide		= $0D;
  actionEquals		= $0E;
  actionLess		= $0F;
  actionAnd		= $10;
  actionOr		= $11;
  actionNot		= $12;
  actionStringEquals	= $13;
  actionStringLength	= $14;
  actionStringAdd	= $21;
  actionStringExtract  = $15;
  actionStringLess	= $29;
  actionMBStringLength = $31;
  actionMBStringExtract= $35;
  actionToInteger	= $18;
  actionCharToAscii	= $32;
  actionAsciiToChar	= $33;
  actionMBCharToAscii  = $36;
  actionMBAsciiToChar  = $37;
  actionJump		= $99;
  actionIf		= $9D;
  actionCall		= $9E;
  actionGetURL2	= $9A;
  actionSetTarget2	= $20;
  actionGetProperty    = $22;
  actionSetProperty    = $23;
  actionCloneSprite    = $24;
  actionRemoveSprite   = $25;
  actionStartDrag	= $27;
  actionEndDrag	= $28;
  actionWaitForFrame2  = $8D;
  actionRandomNumber   = $30;
  actionTrace          = $26;
  actionGetTime        = $34;

  actionFSCommand2     = $2D; // undocumented for Flash Lite 1.1

  actionCallFunction   = $3D;
  actionCallMethod     = $52;
  actionConstantPool   = $88;
  actionDefineFunction = $9B;
  actionDefineLocal    = $3C;
  actionDefineLocal2   = $41;
  actionDelete         = $3A;
  actionDelete2        = $3B;
  actionEnumerate      = $46;
  actionEquals2        = $49;
  actionGetMember      = $4E;
  actionInitArray      = $42;
  actionInitObject     = $43;
  actionNewMethod      = $53;
  actionNewObject      = $40;
  actionSetMember      = $4F;
  actionTargetPath     = $45;
  actionWith           = $94;
  actionToNumber       = $4A;
  actionToString       = $4B;
  actionTypeOf         = $44;
  actionAdd2           = $47;
  actionLess2          = $48;
  actionModulo         = $3F;
  actionBitAnd         = $60;
  actionBitLShift      = $63;
  actionBitOr          = $61;
  actionBitRShift      = $64;
  actionBitURShift     = $65;
  actionBitXor         = $62;
  actionDecrement      = $51;
  actionIncrement      = $50;
  actionPushDuplicate  = $4C;
  actionReturn         = $3E;
  actionStackSwap      = $4D;
  actionStoreRegister  = $87;
  actionInstanceOf     = $54;
  actionEnumerate2     = $55;
  actionStrictEquals   = $66;
  actionGreater        = $67;
  actionStringGreater  = $68;
  actionDefineFunction2= $8E;
  actionExtends        = $69;
  actionCastOp         = $2B;
  actionImplementsOp   = $2C;
  actionTry            = $8F;
  actionThrow          = $2A;

  actionByteCode       = $FE; // no nativ action

  actionOffsetWork     = $FF; // no nativ action

//  ==================  AS3 ====================
// kind for NameSpace
  kNamespace          = $08;
  kPackageNamespace   = $16;
  kPackageInternalNs  = $17;
  kProtectedNamespace = $18;
  kExplicitNamespace  = $19;
  kStaticProtectedNs  = $1A;
  kPrivateNs          = $05;

// Multiname Kind
  mkQName       = $07;
  mkQNameA      = $0D;
  mkRTQName     = $0F;
  mkRTQNameA    = $10;
  mkRTQNameL    = $11;
  mkRTQNameLA   = $12;
  mkMultiname   = $09;
  mkMultinameA  = $0E;
  mkMultinameL  = $1B;
  mkMultinameLA = $1C;

// method flag
  NEED_ARGUMENTS =  $01;
  NEED_ACTIVATION = $02;
  NEED_REST       = $04;
  HAS_OPTIONAL    = $08;
  SET_DXNS        = $40;
  HAS_PARAM_NAMES = $80;

// constant kind for Options
  CONSTANT_Int                = $03;
  CONSTANT_UInt               = $04;
  CONSTANT_Double             = $06;
  CONSTANT_Utf8               = $01;
  CONSTANT_True               = $0B;
  CONSTANT_False              = $0A;
  CONSTANT_Null               = $0C;
  CONSTANT_Undefined          = $00;
  CONSTANT_Namespace          = $08;
  CONSTANT_PackageNamespace   = $16;
  CONSTANT_PackageInternalNs  = $17;
  CONSTANT_ProtectedNamespace = $18;
  CONSTANT_ExplicitNamespace  = $19;
  CONSTANT_StaticProtectedNs  = $1A;
  CONSTANT_PrivateNs          = $05;

// constant kind for Instance
  CONSTANT_ClassSealed        = $01;
  CONSTANT_ClassFinal         = $02;
  CONSTANT_ClassInterface     = $04;
  CONSTANT_ClassProtectedNs   = $08;

// trait types
  Trait_Slot     = 0;
  Trait_Method   = 1;
  Trait_Getter   = 2;
  Trait_Setter   = 3;
  Trait_Class    = 4;
  Trait_Function = 5;
  Trait_Const    = 6;

// AVM2 instructions

	opBkpt = $01;
	opNop = $02;
	opThrow = $03;
	opGetsuper = $04;
	opSetsuper = $05;
	opDxns = $06;
	opDxnslate = $07;
	opKill = $08;
	opLabel = $09;
	opIfnlt = $0C;
	opIfnle = $0D;
	opIfngt = $0E;
	opIfnge = $0F;
	opJump = $10;
	opIftrue = $11;
	opIffalse = $12;
	opIfeq = $13;
	opIfne = $14;
	opIflt = $15;
	opIfle = $16;
	opIfgt = $17;
	opIfge = $18;
	opIfstricteq = $19;
	opIfstrictne = $1A;
	opLookupswitch = $1B;
	opPushwith = $1C;
	opPopscope = $1D;
	opNextname = $1E;
	opHasnext = $1F;
	opPushnull = $20;
	opPushundefined = $21;
	opPushconstant = $22;
	opNextvalue = $23;
	opPushbyte = $24;
	opPushshort = $25;
	opPushtrue = $26;
	opPushfalse = $27;
	opPushnan = $28;
	opPop = $29;
	opDup = $2A;
	opSwap = $2B;
	opPushstring = $2C;
	opPushint = $2D;
	opPushuint = $2E;
	opPushdouble = $2F;
	opPushscope = $30;
	opPushnamespace = $31;
	opHasnext2 = $32;
	opNewfunction = $40;
	opCall = $41;
	opConstruct = $42;
	opCallmethod = $43;
	opCallstatic = $44;
	opCallsuper = $45;
	opCallproperty = $46;
	opReturnvoid = $47;
	opReturnvalue = $48;
	opConstructsuper = $49;
	opConstructprop = $4A;
	opCallsuperid = $4B;
	opCallproplex = $4C;
	opCallinterface = $4D;
	opCallsupervoid = $4E;
	opCallpropvoid = $4F;
	opNewobject = $55;
	opNewarray = $56;
	opNewactivation = $57;
	opNewclass = $58;
	opGetdescendants = $59;
	opNewcatch = $5A;
	opFindpropstrict = $5D;
	opFindproperty = $5E;
	opFinddef = $5F;
	opGetlex = $60;
	opSetproperty = $61;
	opGetlocal = $62;
	opSetlocal = $63;
	opGetglobalscope = $64;
	opGetscopeobject = $65;
	opGetproperty = $66;
	opGetpropertylate = $67;
	opInitproperty = $68;
	opSetpropertylate = $69;
	opDeleteproperty = $6A;
	opDeletepropertylate = $6B;
	opGetslot = $6C;
	opSetslot = $6D;
	opGetglobalslot = $6E;
	opSetglobalslot = $6F;
	opConvert_s = $70;
	opEsc_xelem = $71;
	opEsc_xattr = $72;
	opConvert_i = $73;
	opConvert_u = $74;
	opConvert_d = $75;
	opConvert_b = $76;
	opConvert_o = $77;
	opCoerce = $80;
	opCoerce_b = $81;
	opCoerce_a = $82;
	opCoerce_i = $83;
	opCoerce_d = $84;
	opCoerce_s = $85;
	opAstype = $86;
	opAstypelate = $87;
	opCoerce_u = $88;
	opCoerce_o = $89;
	opNegate = $90;
	opIncrement = $91;
	opInclocal = $92;
	opDecrement = $93;
	opDeclocal = $94;
	opTypeof = $95;
	opNot = $96;
	opBitnot = $97;
	opConcat = $9A;
	opAdd_d = $9B;
	opAdd = $A0;
	opSubtract = $A1;
	opMultiply = $A2;
	opDivide = $A3;
	opModulo = $A4;
	opLshift = $A5;
	opRshift = $A6;
	opUrshift = $A7;
	opBitand = $A8;
	opBitor = $A9;
	opBitxor = $AA;
	opEquals = $AB;
	opStrictequals = $AC;
	opLessthan = $AD;
	opLessequals = $AE;
	opGreaterthan = $AF;
	opGreaterequals = $B0;
	opInstanceof = $B1;
	opIstype = $B2;
	opIstypelate = $B3;
	opIn = $B4;
	opIncrement_i = $C0;
	opDecrement_i = $C1;
	opInclocal_i = $C2;
	opDeclocal_i = $C3;
	opNegate_i = $C4;
	opAdd_i = $C5;
	opSubtract_i = $C6;
	opMultiply_i = $C7;
	opGetlocal0 = $D0;
	opGetlocal1 = $D1;
	opGetlocal2 = $D2;
	opGetlocal3 = $D3;
	opSetlocal0 = $D4;
	opSetlocal1 = $D5;
	opSetlocal2 = $D6;
	opSetlocal3 = $D7;
	opDebug = $EF;
	opDebugline = $F0;
	opDebugfile = $F1;
	opBkptline = $F2;


//  ================  VIDEO  ===================
 // tagDefineVideo	  = 38;
  tagDefineVideoStream = 60;
  tagVideoFrame = 61;

  tagErrorTag = $F0; // no nativ tag

// ================ Flash 8 tags ===================
  tagFileAttributes    = $45;
  tagMetadata          = $4D;
  tagDefineScalingGrid = $4E;
  tagImportAssets2     = $47;
  
  tagDefineShape4      = $53;
  tagPlaceObject3      = $46;
  tagDefineMorphShape2 = $54;

  tagDefineFontAlignZones = $49;
  tagCSMTextSettings      = $4A;

  tagDefineFont3       = $4B;

// ================ Flash 9 tags ===================
  tagSymbolClass      = 76;
  tagDoABC            = 82;
  tagDefineSceneAndFrameLabelData = 86;
  tagDefineBinaryData = 87;
  tagDefineFontName   = 88;
  tagStartSound2      = 89;


// ==================== RecRGBA colors =========================
const
 cswfBlack: recRGBA =  (r:   0; g:   0; b:   0; a: 255);
 cswfMaroon: recRGBA = (r: 128; g:   0; b:   0; a: 255);
 cswfGreen: recRGBA =  (r:   0; g: 128; b:   0; a: 255);
 cswfOlive: recRGBA =  (r: 128; g: 128; b:   0; a: 255);
 cswfNavy: recRGBA  =  (r:   0; g:   0; b: 128; a: 255);
 cswfPurple: recRGBA = (r: 128; g:   0; b: 128; a: 255);
 cswfTeal: recRGBA  =  (r:   0; g: 128; b: 128; a: 255);
 cswfGray: recRGBA  =  (r: 128; g: 128; b: 128; a: 255);
 cswfSilver: recRGBA = (r: 192; g: 192; b: 192; a: 255);
 cswfRed: recRGBA   =  (r: 255; g:   0; b:   0; a: 255);
 cswfLime: recRGBA  =  (r:   0; g: 255; b:   0; a: 255);
 cswfYellow: recRGBA = (r: 255; g: 255; b:   0; a: 255);
 cswfBlue: recRGBA  =  (r:   0; g:   0; b: 255; a: 255);
 cswfFuchsia: recRGBA =(r: 255; g:   0; b: 255; a: 255);
 cswfWhite: recRGBA =  (r: 255; g: 255; b: 255; a: 255);
 cswfLtGray: recRGBA = (r: 192; g: 192; b: 192; a: 255);
 cswfDkGray: recRGBA = (r: 128; g: 128; b: 128; a: 255);

 cswfTransparent: recRGBA = (r:   0; g:   0; b:   0; a:   0);
 cswfMoneyGreen: recRGBA =  (r: 192; g: 220; b: 192; a: 255);
 cswfSkyBlue: recRGBA =     (r: 166; g: 202; b: 240; a: 255);
 cswfCream: recRGBA =       (r: 255; g: 251; b: 240; a: 255);
 cswfMedGray: recRGBA =     (r: 160; g: 160; b: 164; a: 255);

 cswfGray100:recRGBA = (r:   0; g:   0; b:   0; a: 255);
 cswfGray90: recRGBA = (r:  25; g:  25; b:  25; a: 255);
 cswfGray80: recRGBA = (r:  51; g:  51; b:  51; a: 255);
 cswfGray70: recRGBA = (r:  76; g:  76; b:  76; a: 255);
 cswfGray60: recRGBA = (r: 102; g: 102; b: 102; a: 255);
 cswfGray50: recRGBA = (r: 128; g: 128; b: 128; a: 255);
 cswfGray40: recRGBA = (r: 153; g: 153; b: 153; a: 255);
 cswfGray30: recRGBA = (r: 178; g: 178; b: 178; a: 255);
 cswfGray20: recRGBA = (r: 204; g: 204; b: 204; a: 255);
 cswfGray10: recRGBA = (r: 229; g: 229; b: 229; a: 255);
 cswfGray0:  recRGBA = (r: 255; g: 255; b: 255; a: 255);
                            {
var
 GlobalMultCoord: byte = 1;
                           }
implementation

end.

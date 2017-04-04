//*******************************************************//
//                                                       //
//                      DelphiFlash.com                  //
//         Copyright (c) 2004-2007 FeatherySoft, Inc.    //
//                    info@delphiflash.com               //
//                                                       //
//*******************************************************//
// Description: directives for source code compatibility
//              with different versions of Delphi

{$IFDEF VER130}
// Delphi 5
   {$DEFINE ExternalUTF}
{$ENDIF}


{$IFDEF VER140}
// Delphi 6
  {$DEFINE VARIANTS}
{$ENDIF}


{$IFDEF VER150}
// Delphi 7
  {$DEFINE VARIANTS}
{$ENDIF}

{$IFDEF VER170}
// Delphi 2005
  {$DEFINE VARIANTS}
{$ENDIF}

{$IFDEF VER180}
// Delphi 2006
  {$DEFINE VARIANTS}
{$ENDIF}

{$IFDEF VER185}
// Delphi 2007
  {$DEFINE VARIANTS}
{$ENDIF}

// Defines necessity of use JPEG.pas
// it uses for automatic converting
// from Progressive to non progressive JPEG
{$DEFINE DelphiJPEG}

// XML support start from Delphi 6
{$IFDEF VARIANTS}
  {..$DEFINE XMLSupport}
{$ENDIF}

// Include ActionScript compiler engine
{$DEFINE ASCompiler}


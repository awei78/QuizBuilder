//*******************************************************//
//                                                       //
//                      DelphiFlash.com                  //
//         Copyright (c) 2004-2005 FeatherySoft, Inc.    //
//                    info@delphiflash.com               //
//                                                       //
//*******************************************************//

//  Description:  Font reading functions
//  Last update:  21 sep 2006
unit FontReader;
interface
Uses Windows, Classes, SWFObjects, FlashObjects;

const EMS = 1024;

Procedure ReadFontMetric(Font: TFlashFont);
Procedure FillCharInfo(DC: HDC; FChar: TFlashChar);
Procedure GetCharOutlines(DC: HDC; code: word; Shape: TFlashEdges);
Function MakeLogFont(Font: TFlashFont): TLogFont;

implementation

Uses SysUtils, SWFConst;

var fLogFont: TLogFont;
function gdEnumFontsProc(var LogFont: TLogFont; var TextMetric: TTextMetric; FontType: Integer; Data: Pointer): Integer; {export;} stdcall;
begin
 fLogFont := LogFont;
 result := 0;
end;

Function MakeLogFont(Font: TFlashFont): TLogFont;
 var ach: array [0..128] of char;
     DC: HDC;
begin
 StrPCopy(ach, Font.Name);
 DC:=GetDC(0);
 FillChar(fLogFont, SizeOf(fLogFont), 0);
 fLogFont.lfCharSet := Font.FontCharset;
 EnumFonts(DC, ach, @gdEnumFontsProc, nil);
 ReleaseDC(0, DC);
 if fLogFont.lfFaceName = '' then StrPCopy(fLogFont.lfFaceName, Font.Name);
 
 Result := fLogFont;
 with fLogFont do
   begin
     lfHeight := - EMS;
     lfWidth := 0;
     lfEscapement := 0;
     lfOrientation := 0;
 //    lfCharset := Font.FontCharset;
     if Font.Bold then lfWeight := FW_Bold else lfWeight := FW_Normal;
     lfItalic := Byte(Font.Italic);
     lfUnderline := 0;
     lfStrikeOut := 0;
     if Font.AntiAlias then lfQuality := ANTIALIASED_QUALITY
      else lfQuality := NONANTIALIASED_QUALITY;

//     lfOutPrecision := OUT_DEFAULT_PRECIS;
//     lfClipPrecision := CLIP_DEFAULT_PRECIS;
//     lfPitchAndFamily := DEFAULT_PITCH;
   end;
 Result := fLogFont;
end;

{..$DEFINE ExMetrics}
Procedure ReadFontMetric(Font: TFlashFont);
 var FDC, HF, OldF: THandle;

{$IFDEF ExMetrics}
     L: longint;
     OM: POutlineTextmetric;
{$ELSE}
     TM: TTextmetric;
{$ENDIF}
begin
 FDC := CreateCompatibleDC(0);
 if Font.FontInfo.lfFaceName = ''
   then
     HF := CreateFontIndirect(MakeLogFont(Font))
   else
     HF := CreateFontIndirect(Font.FontInfo);
 OldF := SelectObject(FDC, HF);

{$IFDEF ExMetrics}
 l := GetOutlineTextMetrics(FDC, 0, nil);
 GetMem(OM, L);
 GetOutlineTextMetrics(FDC, L, OM);
 Font.Ascent := OM.otmTextMetrics.tmAscent;
 Font.Descent := OM.otmTextMetrics.tmDescent;
 Font.Leading := OM.otmTextMetrics.tmInternalLeading;
 //OM.otmsStrikeoutSize;
 FreeMem(OM, L);
{$ELSE}
 GetTextMetrics(FDC, TM);
 Font.Ascent := TM.tmAscent;
 Font.Descent := TM.tmDescent;
 Font.Leading := TM.tmInternalLeading;
{$ENDIF}

 DeleteObject(SelectObject(FDC, OldF));
 DeleteDC(FDC);
end;

Procedure FillCharInfo(DC: HDC; FChar: TFlashChar);
 var ABC: TABC;
begin
 FChar.ShapeInit := true;

 GetCharOutlines(DC, FChar.WideCode, FChar.Edges);
 GetCharABCWidthsW(DC, FChar.WideCode, FChar.WideCode, ABC);
 With FChar do
  begin
   GlyphAdvance := ABC.abcA + integer(ABC.abcB) + ABC.abcC;

{..$DEFINE Kerning}
{$IFDEF Kerning}
   // Kerning table is not used now in Flash Player
   // I don't no wot this for
   Kerning.FontKerningAdjustment := ABC.abcB;
   Kerning.FontKerningCode1 := ABC.abcA;
   Kerning.FontKerningCode2 := ABC.abcC;
{$ENDIF}
  end;

end;

Function GetFixed(v: TFixed): Longint;
begin
  if V.fract > 0 then Result := Round(V.value + V.fract / specFixed)
    else Result := V.value;
end;

Procedure GetCharOutlines(DC: HDC; code: word; Shape: TFlashEdges);
 var
     M2: TMAT2;
     GM: TGlyphMetrics;
     Mem: TMemoryStream;
     Header: TTPolygonHeader;
     L: Longint;
     pcSize: integer;
     LType, PCount: word;
     pB, pC, p1: TPointFX;
begin
// |1,0|
// |0,1|
 M2.eM11.value := 1; M2.eM11.fract := 1;
 M2.eM12.value := 0; M2.eM12.fract := 1;
 M2.eM21.value := 0; M2.eM21.fract := 1;
 M2.eM22.value := 1; M2.eM22.fract := 1;
 FillChar(GM, SizeOf(GM), 0);

 L := GetGlyphOutlineW(DC, Code, GGO_NATIVE, GM, 0, nil, M2);

// if not Shape.NoStyles then
//   begin
 //   Shape.SetShapeBound(0, - GM.gmBlackBoxY, GM.gmBlackBoxX, 0);
//   end;

 if L > 0 then
   begin
     Mem := TMemoryStream.Create;
     Mem.SetSize(L);
     GetGlyphOutlineW(DC, Code, GGO_NATIVE, GM, L, Mem.Memory, M2);
     While Mem.Position < Mem.Size do
       begin
         Mem.Read(Header, sizeOf(Header));
         Shape.MoveTo(GetFixed(Header.pfxStart.x){.value}, GetFixed(Header.pfxStart.y){.value});
         pcSize := Header.cb - SizeOf(Header);
         While pcSize > 0 do
          begin
            Mem.Read(LType, 2);
            Mem.Read(pCount, 2);
            Dec(pcSize, 4);
            Case LType of
             TT_PRIM_LINE:
              While pCount > 0 do
               begin
                 Mem.Read(pB, SizeOf(pB));
                 Shape.LineTo(GetFixed(pB.X), GetFixed(pB.Y));
                 Dec(pCount);
                 Dec(pcSize, SizeOf(pB));
               end;
             TT_PRIM_QSPLINE:
               begin
                 Mem.Read(pB, SizeOf(pB));
                 Dec(pCount);
                 Dec(pcSize, SizeOf(pB));
                 While pCount > 0 do
                  begin
                     Mem.Read(p1, SizeOf(p1));
                     Dec(pCount);
                     Dec(pcSize, SizeOf(p1));
                     pC := p1;
                     if pCount > 0 then
                       begin
                         pC.X.value := Round((pC.x.value + pB.x.value + (pC.x.fract + pB.x.fract)/ specFixed) / 2);
                         pC.Y.value := Round((pC.y.value + pB.y.value + (pC.y.fract + pB.y.fract)/ specFixed) / 2);
                         pc.x.fract := 0;
                         pc.y.fract := 0;
                       end;
                     Shape.CurveTo(GetFixed(pB.x), GetFixed(pB.y), pC.x.value, pC.y.value);
                     pB := p1;

                   end;
               end;
            end;
          end;
         Shape.CloseShape;
       end;
     Shape.MakeMirror(false, true);
     Mem.Free;
   end;
end;

end.

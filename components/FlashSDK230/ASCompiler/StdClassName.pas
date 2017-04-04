//*******************************************************//
//                                                       //
//                      DelphiFlash.com                  //
//         Copyright (c) 2004-2007 FeatherySoft, Inc.    //
//                    info@delphiflash.com               //
//                                                       //
//*******************************************************//

//  Description:  Standart ActionScript classes name
//  Last update:  7 jun 2007

Unit StdClassName;
interface
uses Windows, SysUtils;

function IsStandartClassName(Name: string): boolean;

implementation

const
  StdNamesCount = 75;
  AStdNames : array [0..StdNamesCount - 1] of PChar = (
// root
   'toplevel',

//FP7
   'Accessibility',
   'Array',
   'AsBroadcaster',
   'Boolean',
   'Button',
   'Camera',
   'Color',
   'ContextMenu',
   'ContextMenuItem',
   'CustomActions',
   'Date',
   'Enumeration',
   'Error',
   'File',
   'FontName',
   'Function',
   'FunctionArguments',
   'Key',
   'LoadVars',
   'LocalConnection',
   'Math',
   'Microphone',
   'Mouse',
   'MovieClip',
   'MovieClipLoader',
   'NetConnection',
   'NetStream',
   'Number',
   'Object',
   'ObjectID',
   'PrintJob',
   'Selection',
   'SharedObject',
   'Sound',
   'Stage',
   'String',
   'System',
   'System.capabilities',
   'System.security',
   'TextField',
   'TextField.StyleSheet',
   'TextFormat',
   'TextSnapshot',
   'URI',
   'Video',
   'XML',
   'XMLNode',
   'XMLSocket',
   'XMLUI',

//fp8
   'flash.display.BitmapData',
   'flash.external.ExternalInterface',
   'flash.filters.BevelFilter',
   'flash.filters.BitmapFilter',
   'flash.filters.BlurFilter',
   'flash.filters.ColorMatrixFilter',
   'flash.filters.ConvolutionFilter',
   'flash.filters.DisplacementMapFilter',
   'flash.filters.DropShadowFilter',
   'flash.filters.GlowFilter',
   'flash.filters.GradientBevelFilter',
   'flash.filters.GradientGlowFilter',
   'flash.geom.ColorTransform',
   'flash.geom.Matrix',
   'flash.geom.Point',
   'flash.geom.Rectangle',
   'flash.geom.Transform',
   'flash.net.FileReference',
   'flash.net.FileReferenceList',
   'flash.text.TextRenderer',
   'System.IME',

// not classes
   'mx.core.ComponentVersion',
   'mx.video.ComponentVersion',
   'mx.video.MediaComponentVersion',
   'mx.transitions.Version'

//fp9
   { no unique classes }
   );


function IsStandartClassName(Name: string): boolean;
var
  il: integer;
begin
  Result := false;
  for il := 0 to StdNamesCount - 1 do
    if lowercase(Name) = lowercase(AStdNames[il]) then
    begin
      Result := true;
      Break;
    end;
end;

end.
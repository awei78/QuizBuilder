unit IdentTblVec;

interface

uses
  ObjVec, IdentTbl;

type
  TItemRef = TBaseIdentTable;

{$INCLUDE ObjVec.inc}

  IScopeList = IVector;
  TScopeList = TVector;

implementation

uses
  SysUtils, GUtils;

{$DEFINE IMPL}

{$INCLUDE ObjVec.inc}

end.

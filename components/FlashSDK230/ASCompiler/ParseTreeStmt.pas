//*******************************************************//
//                                                       //
//                      DelphiFlash.com                  //
//         Copyright (c) 2004-2007 FeatherySoft, Inc.    //
//                    info@delphiflash.com               //
//                                                       //
//*******************************************************//

//  Description:  ActionScript Compiler for Flash level
//  Last update:  22 mar 2007
unit ParseTreeStmt;

interface

uses
  SysUtils, Classes, Contnrs, ObjVec, StrTbl, IdentTbl, ParseTreeBase,
  ParseTreeExpr, SWFConst, FlashObjects, SWFObjects;

type
  TStmtListNode = class(TParseTreeNode)
  private
    FStmtList: INodeList;
  public
    constructor Create(AStmt: TParseTreeNode);
    procedure Add(AStmt: TParseTreeNode);
    procedure Compile; override;
  end;

  TNullStmtNode = class(TParseTreeNode)
  public
    procedure Compile; override;
  end;

  TListingStmtNode = class(TParseTreeNode)
  private
    FLineNum: Integer;
    FComment: string;
  public
    constructor Create(AComment: string);
    procedure Compile; override;
    property LineNum: Integer read FLineNum;
    property Comment: string read FComment;
  end;

  TIfStmtNode = class(TParseTreeNode)
  private
    FCondExpr, FThenBlock, FElseBlock: TParseTreeNode;
  public
    constructor Create(ACondExpr, AThenBlock, AElseBlock: TParseTreeNode);
    procedure Compile; override;
  end;

  TSwitchCaseNode = class(TParseTreeNode)
  private
    FExpr, FStmtList: TParseTreeNode;
    FStartMarker: TSWFOffsetMarker;
    FStartLabel: Integer;
  public
    constructor Create(AExpr, AStmtList: TParseTreeNode);
    procedure Compile; override;
  end;

  TSwitchCaseListNode = class(TParseTreeNode)
  private
    FCaseList: INodeList;
  public
    constructor Create(ACase: TSwitchCaseNode);
    procedure Add(ACase: TSwitchCaseNode);
    procedure Compile; override;
  end;

  TSwitchStmtNode = class(TParseTreeNode)
  private
    FExpr: TParseTreeNode;
    FCaseListNode: TSwitchCaseListNode;
    FStartLabel: Integer;
    FStartMarker: TSWFOffsetMarker;
    FBreakMarkerList: IObjectVector;
    FBreakLabel: Integer;
  public
    constructor Create(AExpr: TParseTreeNode;
      ACaseListNode: TSwitchCaseListNode);
    procedure Compile; override;
    property BreakMarkerList: IObjectVector read FBreakMarkerList;
  end;

  TWaitForFrameNode = class(TParseTreeNode)
  private
    FFrame: Word;
    FBody: TParseTreeNode;
  public
    constructor Create(AFrame: Double; ABody: TParseTreeNode);
    procedure Compile; override;
  end;

  TLoopStmtNode = class(TParseTreeNode)
  protected
    FCondExpr, FLoopBody: TParseTreeNode;
    FContinueMarker: TSWFOffsetMarker;
    FBreakMarkerList: IObjectVector;
    FBreakLabel, FContinueLabel: Integer;
    procedure CompileBody;
  public
    constructor Create(ACondExpr, ALoopBody: TParseTreeNode);
    procedure Compile; override;
    property LoopBody: TParseTreeNode read FLoopBody write FLoopBody;
    property BreakMarkerList: IObjectVector read FBreakMarkerList;
    property ContinueMarker: TSWFOffsetMarker read FContinueMarker;
  end;

  TForStmtNode = class(TLoopStmtNode)
  private
    FLoopInit: TParseTreeNode;
    FLoopUpdate: TParseTreeNode;
  public
    constructor Create(ALoopInit, ACondExpr, ALoopUpdate: TParseTreeNode);
    procedure Compile; override;
  end;

  TForInStmtNode = class(TLoopStmtNode)
  private
    FVarNameId: TStrId;
    FVarInfo: TIdentInfo;
    FObjExpr: TParseTreeNode;
  public
    constructor Create(AVarNameId: TStrId; AObjExpr: TParseTreeNode);
    procedure Compile; override;
  end;

  TBreakStmtNode = class(TParseTreeNode)
  public
    procedure Compile; override;
  end;

  TContinueStmtNode = class(TParseTreeNode)
  public
    procedure Compile; override;
  end;

  TReturnStmtNode = class(TParseTreeNode)
  private
    FExpr: TParseTreeNode;
  public
    constructor Create(AExpr: TParseTreeNode);
    procedure Compile; override;
  end;

  TWithStmtNode = class(TParseTreeNode)
  private
    FObjRef: TParseTreeNode;
    FBody: TParseTreeNode;
  public
    constructor Create(AObjRef, ABody: TParseTreeNode);
    procedure Compile; override;
  end;

  TSetTargetNode = class(TParseTreeNode)
  private
    FTarget: TParseTreeNode;
    FBody: TParseTreeNode;
  public
    constructor Create(ATarget, ABody: TParseTreeNode);
    procedure Compile; override;
  end;

  TCatchNode = class(TParseTreeNode)
  private
    FNameId, FTypeNameId: TStrId;
    FBody: TParseTreeNode;
  public
    constructor Create(ANameId, ATypeNameId: TStrId; ABody: TParseTreeNode);
    property NameId: TStrId read FNameId;
    property TypeNameId: TStrId read FTypeNameId;
    property Body: TParseTreeNode read FBody;
  end;

  TTryStmtNode = class(TParseTreeNode)
  private
    FBody: TParseTreeNode;
    FCatch: TCatchNode;
    FFinally: TParseTreeNode;
  public
    constructor Create(ABody: TParseTreeNode; ACatch: TCatchNode;
      AFinally: TParseTreeNode);
    procedure Compile; override;
  end;

  TThrowStmtNode = class(TParseTreeNode)
  private
    FExpr: TParseTreeNode;
  public
    constructor Create(AExpr: TParseTreeNode);
    procedure Compile; override;
  end;

implementation

uses
  LexLib, ActionCompiler;

{ TStmtListNode }

constructor TStmtListNode.Create(AStmt: TParseTreeNode);
begin
  inherited Create;
  FStmtList := TNodeList.Create(False);
  Add(AStmt);
end;

procedure TStmtListNode.Add(AStmt: TParseTreeNode);
begin
  if AStmt <> nil then
    FStmtList.Add(AStmt);
end;

procedure TStmtListNode.Compile;
var
  I: Integer;
begin
  for I := 0 to FStmtList.Count - 1 do
    (FStmtList[I] as TParseTreeNode).Compile;
end;

{ TNullStmtNode }

procedure TNullStmtNode.Compile;
begin
end;

{ TListingStmt }

constructor TListingStmtNode.Create(AComment: string);
begin
  inherited Create;
  FLineNum := yylineno;
  FComment := Copy(AComment, 4, 255);
end;

procedure TListingStmtNode.Compile;
begin
  WriteCmd(acListing, Integer(Self));
end;

{ TIfStmtNode }

constructor TIfStmtNode.Create(ACondExpr, AThenBlock,
  AElseBlock: TParseTreeNode);
begin
  inherited Create;
  FCondExpr := ACondExpr;
  FThenBlock := AThenBlock;
  FElseBlock := AElseBlock;
end;

procedure TIfStmtNode.Compile;
var
  L1, L2: TSWFOffsetMarker;
  L3, L4: Integer;
begin
  {
    if (CondExpr) StmttThen else StmttElse
    ------------------------------------
    CondExpr
    If L1
    StmttElse
    Jump L2
    L1:
    StmtThen
    L2:
  }

  FCondExpr.Compile;

  L3 := Context.GetNextLabel;
  L1 := (WriteCmd(acIf, L3) as TSWFActionIf).BranchOffsetMarker;

  if FElseBlock <> nil then
    FElseBlock.Compile;

  L4 := Context.GetNextLabel;
  L2 := (WriteCmd(acJump, L4) as TSWFActionJump).BranchOffsetMarker;

  SwfCode.SetMarker(L1);
  WriteLabel(L3);

  FThenBlock.Compile;

  SwfCode.SetMarker(L2);
  WriteLabel(L4);

  CheckDiscardResult;
end;

{ TSwitchCaseNode }

constructor TSwitchCaseNode.Create(AExpr, AStmtList: TParseTreeNode);
begin
  inherited Create;
  FExpr := AExpr;
  FStmtList := AStmtList;
end;

procedure TSwitchCaseNode.Compile;
begin
  FStartLabel := Context.GetNextLabel;
  FStartMarker := SwfCode.SetMarker;
  WriteLabel(FStartLabel);
  if FStmtList <> nil then
    FStmtList.Compile;
end;

{ TSwitchCaseListNode }

constructor TSwitchCaseListNode.Create(ACase: TSwitchCaseNode);
begin
  inherited Create;
  FCaseList := TNodeList.Create(False);
  Add(ACase);
end;

procedure TSwitchCaseListNode.Add(ACase: TSwitchCaseNode);
begin
  if ACase <> nil then
    FCaseList.Add(ACase);
end;

procedure TSwitchCaseListNode.Compile;
var
  I: Integer;
  FCase: TObject;
begin
  // Поместить default в конец списка
  for I := 0 to FCaseList.Count - 1 do
    with FCaseList[I] as TSwitchCaseNode do
      if FExpr = nil then
      begin
        FCase := FCaseList[I];
        FCaseList.Delete(I);
        FCaseList.Add(FCase);
        Break;
      end;

  { Поcтроить блок
    L1:
    stmt_list1
    L2:
    stmt_list2
    .....
    LN:
    stmt_listN
    L(N+1):
    default_stmt_list
  }
  for I := 0 to FCaseList.Count - 1 do
    with FCaseList[I] as TSwitchCaseNode do
      Compile;
end;

{ TSwitchStmtNode }

constructor TSwitchStmtNode.Create(AExpr: TParseTreeNode;
  ACaseListNode: TSwitchCaseListNode);
begin
  inherited Create;
  FExpr := AExpr;
  FCaseListNode := ACaseListNode;
  FBreakMarkerList := TObjectVector.Create(False);
end;

procedure TSwitchStmtNode.Compile;
var
  CaseList: INodeList;
  I: Integer;
begin
  if FCaseListNode = nil then
    FExpr.Compile
  else if coFlashLite in Context.CompileOptions then
  begin
    Context.OpenSwitchStmt(Self);
    FBreakLabel := Context.GetNextLabel;
    FStartLabel := Context.GetNextLabel;
    with WriteCmd(acJump, FStartLabel) as TSWFActionJump do
      FStartMarker := BranchOffsetMarker;
    FCaseListNode.Compile;

    with WriteCmd(acJump, FBreakLabel) as TSWFActionJump do
      BreakMarkerList.Add(BranchOffsetMarker);

    WriteLabel(FStartLabel);
    SwfCode.SetMarker(FStartMarker);

    CaseList := FCaseListNode.FCaseList;

    for I := 0 to CaseList.Count - 1 do
      with CaseList[I] as TSwitchCaseNode do
        if FExpr <> nil then
        begin
          Self.FExpr.Compile;
          FExpr.Compile;
          WriteCmd(acEquals);
          with WriteCmd(acIf, FStartLabel) as TSWFActionIf do
            BranchOffsetMarker := FStartMarker;
        end
        else
        begin
          with WriteCmd(acJump, FStartLabel) as TSWFActionJump do
            BranchOffsetMarker := FStartMarker;
        end;

    WriteLabel(FBreakLabel);
    for I := 0 to BreakMarkerList.Count - 1 do
      SwfCode.SetMarker(BreakMarkerList[I] as TSWFOffsetMarker);

    Context.CloseSwitchStmt;
  end
  else
  begin
    Context.OpenSwitchStmt(Self);
    FBreakLabel := Context.GetNextLabel;
    FStartLabel := Context.GetNextLabel;
    with WriteCmd(acJump, FStartLabel) as TSWFActionJump do
      FStartMarker := BranchOffsetMarker;
    FCaseListNode.Compile;

    with WriteCmd(acJump, FBreakLabel) as TSWFActionJump do
      BreakMarkerList.Add(BranchOffsetMarker);

    WriteLabel(FStartLabel);
    SwfCode.SetMarker(FStartMarker);

    FExpr.Compile; // это значение снимает со стека Pop в конце этого блока.
    CaseList := FCaseListNode.FCaseList;

    for I := 0 to CaseList.Count - 1 do
      with CaseList[I] as TSwitchCaseNode do
        if FExpr <> nil then
        begin
          WriteCmd(acPushDuplicate);
          FExpr.Compile;
          WriteCmd(acEquals2);
          with WriteCmd(acIf, FStartLabel) as TSWFActionIf do
            BranchOffsetMarker := FStartMarker;
        end
        else
        begin
          with WriteCmd(acJump, FStartLabel) as TSWFActionJump do
            BranchOffsetMarker := FStartMarker;
        end;

    WriteLabel(FBreakLabel);
    for I := 0 to BreakMarkerList.Count - 1 do
      SwfCode.SetMarker(BreakMarkerList[I] as TSWFOffsetMarker);

    WriteCmd(acPop);
    Context.CloseSwitchStmt;
  end;
end;

{ TWaitForFrameNode }

constructor TWaitForFrameNode.Create(AFrame: Double; ABody: TParseTreeNode);
begin
  inherited Create;
  FFrame := Trunc(AFrame);
  FBody := ABody;
end;

procedure TWaitForFrameNode.Compile;
var
  ActionWaitForFrame: TSWFActionWaitForFrame;
  Start: Integer;
begin
  SwfCode.WaitForFrame(FFrame, 0);
  ActionWaitForFrame := SwfCode.ActionList.Last as TSWFActionWaitForFrame;
  Start := SwfCode.ActionList.Count;
  FBody.Compile;
  if SwfCode.ActionList.Count - Start > 255 then
  begin
    raise EComponentError.Create(
      'ActionWaitForFrame: invalid SkipCount parameter.');
  end;
  ActionWaitForFrame.SkipCount := SwfCode.ActionList.Count - Start;
end;

{ TLoopStmtNode }

constructor TLoopStmtNode.Create(ACondExpr, ALoopBody: TParseTreeNode);
begin
  inherited Create;
  FCondExpr := ACondExpr;
  FLoopBody := ALoopBody;
  FBreakMarkerList := TObjectVector.Create(False);
end;

procedure TLoopStmtNode.CompileBody;
begin
  if FLoopBody <> nil then
    FLoopBody.Compile;
end;

procedure TLoopStmtNode.Compile;
var
  I: Integer;
  StartLabel: Integer;
  StartMarker: TSWFOffsetMarker;
begin
  {
    while        do while
    -----        --------
    L1:          Jump S
    CondExpr     L1:
    Not          CondExpr
    If L2        Not
    LoopBody     If L2
    Jump L1      S:
    L2:          LoopBody
    -----        Jump L1
                 L2:
                 --------
  }
  StartLabel := 0;
  StartMarker := nil;

  FBreakLabel := Context.GetNextLabel;
  FContinueLabel := Context.GetNextLabel;
  Context.OpenLoopStmt(Self);

  if nfDoWhile in Flags then
  begin
    StartLabel := Context.GetNextLabel;
    with WriteCmd(acJump, StartLabel) as TSWFActionJump do
      StartMarker := BranchOffsetMarker;
  end;

  FContinueMarker := SwfCode.SetMarker;
  WriteLabel(FContinueLabel);

  FCondExpr.Compile;
  WriteCmd(acNot);

  BreakMarkerList.Add(
    (WriteCmd(acIf, FBreakLabel) as TSWFActionIf).BranchOffsetMarker);

  if nfDoWhile in Flags then
  begin
    WriteLabel(StartLabel);
    SwfCode.SetMarker(StartMarker);
  end;

  CompileBody;

  with WriteCmd(acJump, FContinueLabel) as TSWFActionJump do
    BranchOffsetMarker := ContinueMarker;

  for I := 0 to FBreakMarkerList.Count - 1 do
    SwfCode.SetMarker(FBreakMarkerList[I] as TSWFOffsetMarker);

  Context.CloseLoopStmt;
end;

{ TForStmtNode }

constructor TForStmtNode.Create(ALoopInit, ACondExpr,
  ALoopUpdate: TParseTreeNode);
begin
  inherited Create(ACondExpr, nil);
  FLoopInit := ALoopInit;
  FLoopUpdate := ALoopUpdate;
end;

procedure TForStmtNode.Compile;
var
  StartLabel: Integer;
  StartMarker: TSWFOffsetMarker;
  I: Integer;
begin
  {
    for (init; cond_expr; updae) body
    -----
    init
    Jump Start
  Continue:
    update
  Start:
    CondExpr
    Not
    If Break
    LoopBody
    Jump Continue
  Break:
    -----
  }
  if FLoopInit <> nil then
    FLoopInit.Compile;

  StartLabel := Context.GetNextLabel;
  with WriteCmd(acJump, StartLabel) as TSWFActionJump do
    StartMarker := BranchOffsetMarker;

  FBreakLabel := Context.GetNextLabel;
  FContinueLabel := Context.GetNextLabel;
  Context.OpenLoopStmt(Self);

  FContinueMarker := SwfCode.SetMarker;
  WriteLabel(FContinueLabel);

  if FLoopUpdate <> nil then
    FLoopUpdate.Compile;

  WriteLabel(StartLabel);
  SwfCode.SetMarker(StartMarker);

  if FCondExpr <> nil then
  begin
    FCondExpr.Compile;
    WriteCmd(acNot);
    with WriteCmd(acIf, FBreakLabel) as TSWFActionIf do
      BreakMarkerList.Add(BranchOffsetMarker);
  end;

  CompileBody;
  with WriteCmd(acJump, FContinueLabel) as TSWFActionJump do
    BranchOffsetMarker := ContinueMarker;

  for I := 0 to FBreakMarkerList.Count - 1 do
    SwfCode.SetMarker(FBreakMarkerList[I] as TSWFOffsetMarker);

  Context.CloseLoopStmt;
end;

{ TForInStmtNode }

constructor TForInStmtNode.Create(AVarNameId: TStrId; AObjExpr: TParseTreeNode);
begin
  inherited Create(nil, nil);
  FVarNameId := AVarNameId;
  FObjExpr := AObjExpr;
  FVarInfo := Context.CurScope.AddIdent(AVarNameId);
  Include(FVarInfo.Flags, idVar);
end;

procedure TForInStmtNode.Compile;
var
  I: Integer;
  ClearMarker: TSWFOffsetMarker;
{$IFDEF DEBUG}
  StackMarker: Integer;
{$ENDIF}
begin
{$IFDEF DEBUG}
  StackMarker := Context.MarkStack;
{$ENDIF}

  if FVarInfo.RegisterNum <= 0 then
  begin
    // Управляющая переменная цикла - именованная переменная.
    // Выполнить DefineLocal
    WriteCmd(acPushConstant, FVarNameId);
    WriteCmd(acDefineLocal2);
  end;

  FObjExpr.Compile;
  WriteCmd(acEnumerate2);

  FBreakLabel := Context.GetNextLabel;
  FContinueLabel := Context.GetNextLabel;
  Context.OpenLoopStmt(Self);

  FContinueMarker := SwfCode.SetMarker;
  WriteLabel(FContinueLabel);

  WriteCmd(acPushDuplicate);
  WriteCmd(acPushNull);
  WriteCmd(acEquals2);
  with WriteCmd(acIf, FBreakLabel) as TSWFActionIf do
    BreakMarkerList.Add(BranchOffsetMarker);

  if FVarInfo.RegisterNum <= 0 then
  begin
    WriteCmd(acPushConstant, FVarNameId);
    WriteCmd(acStackSwap);
    WriteCmd(acSetVariable);
  end
  else
  begin
    WriteCmd(acStoreRegister, FVarInfo.RegisterNum, St[FVarNameId]);
    WriteCmd(acPop);
  end;

  CompileBody;

  with WriteCmd(acJump, FContinueLabel) as TSWFActionJump do
    BranchOffsetMarker := ContinueMarker;

  WriteLabel(FBreakLabel);
  for I := 0 to FBreakMarkerList.Count - 1 do
    SwfCode.SetMarker(FBreakMarkerList[I] as TSWFOffsetMarker);
  ClearMarker := SwfCode.SetMarker;

  WriteCmd(acPushNull);
  WriteCmd(acEquals2);
  WriteCmd(acNot);
  with WriteCmd(acIf, FBreakLabel) as TSWFActionIf do
    BranchOffsetMarker := ClearMarker;

  Context.CloseLoopStmt;

{$IFDEF DEBUG}
  Context.CheckStack(StackMarker, 'TForInStmtNode error.');
{$ENDIF}
end;

{ TBreakStmtNode }

procedure TBreakStmtNode.Compile;
begin
  if Context.LoopStmt <> nil then
    with Context.LoopStmt do
    begin
      BreakMarkerList.Add(
        (WriteCmd(acJump, FBreakLabel) as TSWFActionJump).BranchOffsetMarker);
    end
  else if Context.SwitchStmt <> nil then
    with Context.SwitchStmt do
    begin
      BreakMarkerList.Add(
        (WriteCmd(acJump, FBreakLabel) as TSWFActionJump).BranchOffsetMarker);
    end;
end;

{ TContinueStmtNode }

procedure TContinueStmtNode.Compile;
begin
  if Context.LoopStmt <> nil then
    with Context.LoopStmt do
      with WriteCmd(acJump, FContinueLabel) as TSWFActionJump do
        BranchOffsetMarker := ContinueMarker;
end;

{ TReturnStmtNode }

constructor TReturnStmtNode.Create(AExpr: TParseTreeNode);
begin
  inherited Create;
  FExpr := AExpr;
end;

procedure TReturnStmtNode.Compile;
begin
  if FExpr <> nil then
    FExpr.Compile
  else
    WriteCmd(acPushUndefined);
  WriteCmd(acReturn);
end;

{ TSetTargetNode }

constructor TSetTargetNode.Create(ATarget, ABody: TParseTreeNode);
begin
  inherited Create;
  FTarget := ATarget;
  FBody := ABody;
end;

procedure TSetTargetNode.Compile;
begin
  FTarget.Compile;
  WriteCmd(acSetTarget2);
  if FBody <> nil then
    FBody.Compile;
  WriteCmd(acPushConstant, St.EmptyStrId);
  WriteCmd(acSetTarget2);
end;

{ TWithStmtNode }

constructor TWithStmtNode.Create(AObjRef, ABody: TParseTreeNode);
begin
  inherited Create;
  FObjRef := AObjRef;
  FBody := ABody;
end;

procedure TWithStmtNode.Compile;
var
  EndWithMarker: TSWFOffsetMarker;
  EndWithLabel: Integer;
begin
  EndWithLabel := Context.GetNextLabel;
  FObjRef.Compile;
  with WriteCmd(acWith, EndWithLabel) as TSWFActionWith do
    EndWithMarker := SizeMarker;

  FBody.Compile;

  WriteLabel(EndWithLabel);
  SwfCode.SetMarker(EndWithMarker);
end;

{ TCatchNode }

constructor TCatchNode.Create(ANameId, ATypeNameId: TStrId;
  ABody: TParseTreeNode);
begin
  inherited Create;
  FNameId := ANameId;
  FTypeNameId := ATypeNameId;
  FBody := ABody;
end;

{ TTryStmtNode }

constructor TTryStmtNode.Create(ABody: TParseTreeNode; ACatch: TCatchNode;
  AFinally: TParseTreeNode);
begin
  inherited Create;
  FBody := ABody;
  FCatch := ACatch;
  FFinally := AFinally;
end;

procedure TTryStmtNode.Compile;
var
  TryLabel, CatchLabel, FinallyLabel: Integer;
  TryMarker, CatchMarker, FinallyMarker: TSWFOffsetMarker;
  ActionTry: TSWFActionTry;
begin
  TryLabel := Context.GetNextLabel;

  if FCatch <> nil then
    CatchLabel := Context.GetNextLabel
  else
    CatchLabel := 0;

  if FFinally <> nil then
    FinallyLabel := Context.GetNextLabel
  else
    FinallyLabel := 0;

  ActionTry := WriteCmd(acTry, Format(' %d %d %d',
    [TryLabel, CatchLabel, FinallyLabel])) as TSWFActionTry;

  TryMarker := ActionTry.TrySizeMarker;
  FBody.Compile;
  SwfCode.SetMarker(TryMarker);
  WriteLabel(TryLabel);

  if FCatch = nil then
    ActionTry.CatchBlockFlag := False
  else
  begin
    ActionTry.CatchBlockFlag := True;
    ActionTry.CatchInRegisterFlag := False;
    ActionTry.CatchName := St[FCatch.NameId];
    CatchMarker := ActionTry.CatchSizeMarker;
    if FCatch.Body <> nil then
      FCatch.Body.Compile;
    SwfCode.SetMarker(CatchMarker);
    WriteLabel(CatchLabel);
  end;

  if FFinally = nil then
    ActionTry.FinallyBlockFlag := False
  else
  begin
    ActionTry.FinallyBlockFlag := True;
    FinallyMarker := ActionTry.FinallySizeMarker;
    FFinally.Compile;
    SwfCode.SetMarker(FinallyMarker);
    WriteLabel(FinallyLabel);
  end;
end;

{ TThrowStmtNode }

constructor TThrowStmtNode.Create(AExpr: TParseTreeNode);
begin
  inherited Create;
  FExpr := AExpr;
end;

procedure TThrowStmtNode.Compile;
begin
  FExpr.Compile;
  WriteCmd(acThrow);
end;

end.


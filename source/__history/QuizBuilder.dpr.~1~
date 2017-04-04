program QuizBuilder;

uses
  Windows,
  Messages,
  SysUtils,
  Forms,
  FlashGDI in 'FlashGDI.pas',
  md5 in 'md5.pas',
  CtrlsEx in 'CtrlsEx.pas',
  Menus in 'Menus.pas',
  Quiz in 'Quiz.pas',
  uGlobal in 'uGlobal.pas',
  uWord in 'uWord.pas',
  uSplash in 'uSplash.pas' {frmSplash},
  uMain in 'uMain.pas' {frmMain},
  uBase in 'uBase.pas' {frmBase},
  uProp in 'uProp.pas' {frmProp},
  uParam in 'uParam.pas' {frmParam},
  uPublish in 'uPublish.pas' {frmPublish},
  uQues in 'uQues.pas' {frmQues},
  uPlayer in 'uPlayer.pas' {frmPlayer},
  uHotSpot in 'uHotSpot.pas' {fraHotspot: TFrame},
  uReg in 'uReg.pas' {frmReg},
  uAbout in 'uAbout.pas' {frmAbout},
  uProgress in 'uProgress.pas' {frmProgress},
  uChart in 'uChart.pas' {frmChart},
  uByType in 'uByType.pas' {frmByType},
  uEditTopic in 'uEditTopic.pas' {frmEditTopic};

{$R *.res}

//系统初始化，创建公用对象
procedure InitApp;
begin
  App := TApp.Create;
  QuizObj := TQuizObj.Create;
end;

//系统结束，释放公用对象
procedure ExitApp;
begin
  QuizObj.Free;
  App.Free;  
end;

var
  hApp, hMain: THandle;

begin
  //只运行一个实例
  hApp := FindWindow('TApplication', '秋风试题大师');
  if hApp <> 0 then
  begin
    hMain := FindWindow('TfrmMain', nil);
    if hMain <> 0 then
    begin
      if IsIconic(hMain) then ShowWindow(hMain, SW_RESTORE);
      //这里置前hApp，是因为MainForm前有模式窗口时，仍然是MainForm激活的问题
      SetForegroundWindow(hApp);
      //传递外部工程
      if (ParamCount > 0) and FileExists(ParamStr(1)) and (ExtractFileExt(ParamStr(1)) = '.aqb') then
        PostMessage(hMain, WM_OUTERPROJ, 0, GlobalAddAtom(PAnsiChar(ParamStr(1))));
      Exit;
    end;
  end;

  InitProc := @InitApp;
  ExitProc := @ExitApp;
  Application.Initialize;
  Application.Title := '秋风试题大师';
  if QuizObj.QuizSet.ShowSplash then ShowSplash();
  //为解决显示frmSplash时，主窗体最后一次为最大化时不能显示为最大化的问题
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.


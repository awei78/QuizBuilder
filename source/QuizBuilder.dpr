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

//ϵͳ��ʼ�����������ö���
procedure InitApp;
begin
  App := TApp.Create;
  QuizObj := TQuizObj.Create;
end;

//ϵͳ�������ͷŹ��ö���
procedure ExitApp;
begin
  QuizObj.Free;
  App.Free;  
end;

var
  hApp, hMain: THandle;

begin
  //ֻ����һ��ʵ��
  hApp := FindWindow('TApplication', '��������ʦ');
  if hApp <> 0 then
  begin
    hMain := FindWindow('TfrmMain', nil);
    if hMain <> 0 then
    begin
      if IsIconic(hMain) then ShowWindow(hMain, SW_RESTORE);
      //������ǰhApp������ΪMainFormǰ��ģʽ����ʱ����Ȼ��MainForm���������
      SetForegroundWindow(hApp);
      //�����ⲿ����
      if (ParamCount > 0) and FileExists(ParamStr(1)) and (ExtractFileExt(ParamStr(1)) = '.aqb') then
        PostMessage(hMain, WM_OUTERPROJ, 0, GlobalAddAtom(PAnsiChar(ParamStr(1))));
      Exit;
    end;
  end;

  InitProc := @InitApp;
  ExitProc := @ExitApp;
  Application.Initialize;
  Application.Title := '��������ʦ';
  if QuizObj.QuizSet.ShowSplash then ShowSplash();
  //Ϊ�����ʾfrmSplashʱ�����������һ��Ϊ���ʱ������ʾΪ��󻯵�����
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.


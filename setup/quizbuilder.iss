; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

[Setup]
AppName=秋风试题大师
AppVerName=秋风试题大师 v{code:GetVersionString}
AppPublisher=秋风软件工作室
AppPublisherURL=http://www.awindsoft.net
AppSupportURL=http://www.awindsoft.net
AppUpdatesURL=http://www.awindsoft.net
DefaultDirName={pf}\QuizBuilder
DefaultGroupName=秋风试题大师
LicenseFile=..\bin\license.txt
VersionInfoVersion=1.3.6.17
OutputDir=.
OutputBaseFilename=quizbuilder
;SetupIconFile=..\ico\install.ico
Compression=lzma
SolidCompression=yes
ChangesAssociations=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Messages]
english.BeveledLabel=秋风软件

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: checkablealone

[Files]
Source: "..\bin\QuizBuilder.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\bin\help.chm"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\bin\AWQuiz.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\bin\GDIPlus.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\bin\Viewer.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\bin\scorm12\*"; DestDir: "{app}\scorm12"; Flags: ignoreversion
Source: "..\bin\scorm2004\*"; DestDir: "{app}\scorm2004"; Flags: ignoreversion
Source: "..\bin\samples\*"; DestDir: "{app}\samples"; Flags: ignoreversion recursesubdirs createallsubdirs

; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Registry]
Root: HKCR; Subkey: ".aqb"; ValueType: string; ValueData: "aqbFile"; Flags: uninsdeletekey; Permissions: users-full
Root: HKCR; Subkey: "aqbFile"; Flags: uninsdeletekey; Permissions: users-full
Root: HKCR; Subkey: "aqbFile\DefaultIcon"; ValueType: string; ValueData: "{app}\QuizBuilder.exe,1"
Root: HKCR; Subkey: "aqbFile\shell\open\command"; ValueType: string; ValueData: """{app}\QuizBuilder.exe"" ""%1"""
Root: HKCU; Subkey: "Software\QuizBuilder"; Flags: uninsdeletekey

[Dirs]
Name: "{app}"

[Icons]
Name: "{group}\试题大师"; Filename: "{app}\QuizBuilder.exe";
Name: "{group}\帮助"; Filename: "{app}\help.chm"
Name: "{group}\{cm:ProgramOnTheWeb,秋风软件}"; Filename: "http://www.awindsoft.net"
Name: "{group}\{cm:UninstallProgram,试题大师}"; Filename: "{uninstallexe}"
Name: "{userdesktop}\秋风试题大师"; Filename: "{app}\QuizBuilder.exe"; Tasks: desktopicon

;清除注册表项
[Registry]
Root: HKCU; Subkey: "Software\QuizBuilder"; Flags: uninsdeletekey

[Run]
Filename: "{app}\QuizBuilder.exe"; Description: "{cm:LaunchProgram,秋风试题大师}"; Flags: nowait postinstall skipifsilent

[Code]

function GetVersionString(Param: String): String;
begin
  //为安装及卸载编译，写当前版本号
  Result := '1.3.6.17';
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  ErrorCode: Integer;
begin
  if CurStep = ssPostInstall then
    ShellExec('', 'http://www.awindsoft.net/reg.asp?act=install&pid=0&ver=' + GetVersionString(''), '', '', SW_SHOW, ewNoWait, ErrorCode);
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  ErrorCode: Integer;
begin
  if CurUninstallStep = usPostUninstall then
    ShellExec('', 'http://www.awindsoft.net/reg.asp?act=uninstall&pid=0&ver=' + GetVersionString(''), '', '', SW_SHOW, ewNoWait, ErrorCode);
end;

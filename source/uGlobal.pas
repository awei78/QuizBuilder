unit uGlobal;

interface

uses
  Windows, Forms, SysUtils, StrUtils, Variants, Classes, Graphics, Registry,
  Menus, Quiz, jpeg, PngImage, GifImage, ShlObj, ShellAPI, ActiveX, FlashObjects;

const
  APP_CAPTION      = '秋风试题大师';
  AW_HOMEPAGE      = 'http://www.awindsoft.net';
  HH_DISPLAY_TOPIC = $0000;
  QUIZ_TEMPLET     = 'templet.swf';
  MAX_QUES_COUNT   = 15;

type
  TRegType = (rtNone, rtTrial, rtUnReged);
  TApp = class
  private
    FCaption: string;
    FPath: string;
    FTmpPath: string;
    FTmpJpg: string;
    FExeName: string;
    FRegistry: TRegistry;
    FWindowState: TWindowState;
    FShowCount: Boolean;
    //注册信息
    FRegMail: string;
    FRegCode: string;
    function GetVersion: string;
    function GetRegType: TRegType;
    procedure GetTemplet;
    //注册aqb文件类型
    procedure RegAqbFile;
    //写Flash播放器信任文件
    procedure WriteFlashTrustFile;
    //从注册表读值
    procedure LoadFromReg;
  public
    constructor Create;
    destructor Destroy; override;

    //存入注册表...开启public是因为要在reg窗体即时写入注册表
    procedure SaveToReg;
    //加载最近试题列表
    procedure LoadRecentDocs(AMenuItem: TMenuItem; MenuItemClick: TNotifyEvent);
    //存储最近试题列表
    procedure SaveRecentDocs;
    property Caption: string read FCaption;
    property Path: string read FPath;
    property TmpPath: string read FTmpPath;
    property TmpJpg: string read FTmpJpg;
    property ExeName: string read FExeName;
    property Version: string read GetVersion;
    property WindowState: TWindowState read FWindowState write FWindowState;
    property ShowCount: Boolean read FShowCount write FShowCount;
    //版本类型
    property RegType: TRegType read GetRegType;
    property RegMail: string read FRegMail write FRegMail;
    property RegCode: string read FRegCode write FRegCode;
  end;

resourcestring
  sAqbFiler  = '试题工程文件 (*.aqb)|*.aqb';
  sXlsFilter = 'Microsoft Excel 文件(*.xls; *.xlsx)|*.xls;*.xlsx';

//获取图片大小
function GetImageSize(const AImgFile: string): TSize;
//处理图片
function DealImage(const AImgFile: string; AMaxWidth: Integer = 640;
  AMaxHeight: Integer = 480): Boolean;
//是否是可处理的图片
function GetDealImgStr(const AImgFile: string): string;
//获取图片流
function GetImageStream(AImgFile: string): TStream;
//Delphi之Color转换为Flash之Color
function GetColorStr(AColor: TColor): WideString;
//选择文件夹
function SelectDirectory(Handle: HWND; const Caption, DefaultDir: string;
  out Directory: string): Boolean;
function BoolToLowerStr(AValue: Boolean): string;
//清空文件夹
function DeleteDirectory(const AFolder: string): Boolean;
//复制文件夹
function CopyFolder(const AFrom, ATo: string): Boolean;
//是否可以再添加
function GetCanAdd(AHandle: Integer): Boolean;
//调用dll...以检测注册情况及初始化影片
//检测注册码是否正确
function CheckRegCode(const AKey, ACode: string): Boolean; export; stdcall;
//生成FlashMovie
function BuildMovie(const AWidth, AHeight: Integer; const AFps: Integer = 12): TFlashMovie; stdcall;
//调用帮助文件
function HtmlHelp(hwd: THandle; pszFile: string; uCommand, dwData: Integer): Integer; stdcall;

var
  App: TApp;

implementation

const
  DLL_NAME = 'AWQuiz.dll';

function CheckRegCode; stdcall; external DLL_NAME name 'Autumn';
function BuildMovie; stdcall; external DLL_NAME name 'Wind';
function HtmlHelp; stdcall; external 'HHCtrl.ocx' name 'HtmlHelpA';

//获取图片大小
function GetImageSize(const AImgFile: string): TSize;
var
  pic: TPicture;
begin
  Result.cx := 0;
  Result.cy := 0;
  if not FileExists(AImgFile) then Exit;

  pic := TPicture.Create;
  try
    pic.LoadFromFile(AImgFile);
    Result.cx := pic.Width;
    Result.cy := pic.Height;
  finally
    pic.Free;
  end;
end;

//处理图片
function DealImage(const AImgFile: string; AMaxWidth, AMaxHeight: Integer): Boolean;
var
  pic: TPicture;
  bmp: TBitmap;
  jpg: TJPEGImage;
  fScale: Single;
  iWidth, iHeight: Integer;
begin
  Result := False;
  if not FileExists(AImgFile) then Exit;

  pic := TPicture.Create;
  bmp := TBitmap.Create;
  jpg := TJPEGImage.Create;
  try
    try
      pic.LoadFromFile(AImgFile);
      if (pic.Width > AMaxWidth) or (pic.Height > AMaxHeight) then
      begin
        fScale := AMaxHeight / AMaxWidth;

        if (pic.Height / pic.Width) > fScale then
        begin
          iWidth := Round(pic.Width * AMaxHeight / pic.Height);
          iHeight := AMaxHeight;
        end
        else
        begin
          iWidth := AMaxWidth;
          iHeight := Round(pic.Height * AMaxWidth / pic.Width);
        end;
      end
      else
      begin
        iWidth := pic.Width;
        iHeight := pic.Height;
      end;
      bmp.PixelFormat := pf24bit;
      bmp.Width := iWidth;
      bmp.Height := iHeight;
      bmp.Canvas.StretchDraw(Rect(0, 0, iWidth, iHeight), pic.Graphic);

      jpg.Assign(bmp);
      jpg.SaveToFile(App.TmpJpg);
      Result := True;
    except
      Result := False;
    end;
  finally
    pic.Free;
    bmp.Free;
    jpg.Free;
  end;
end;

function GetDealImgStr(const AImgFile: string): string;
var
  sExt: string;
begin
  sExt := LowerCase(ExtractFileExt(AImgFile));
  if (Pos(sExt, '.swf.gif.jpg') = 0) then
    Result := ChangeFileExt(AImgFile, '.jpg')
  else Result := AImgFile;
end;

function GetImageStream(AImgFile: string): TStream;
var
  jpg: TJPEGImage;
begin
  jpg := TJPEGImage.Create;
  try
    jpg.LoadFromFile(AImgFile);
    Result := TMemoryStream.Create;
    jpg.SaveToStream(Result);
  finally
    jpg.Free;
  end;
end;

function GetColorStr(AColor: TColor): WideString;
begin
  Result := '0x' + IntToHex(GetRValue(AColor), 2) + IntToHex(GetGValue(AColor), 2) + IntToHex(GetBValue(AColor), 2);
end;

function SelectDirectory(Handle: HWND; const Caption, DefaultDir: string;
  out Directory: string): Boolean;

  function BrowseCallBackProc(Wnd: HWND; uMsg: UINT; lParam, lpData: LPARAM): Integer stdcall;
  begin
    if uMsg = BFFM_INITIALIZED then
      Result := SendMessage(Wnd, BFFM_SETSELECTION, Ord(TRUE), lpData)
    else Result := 1;
  end;

var
  bi: _browseinfoA;
  pid: PItemIDList;
  buf: array[0..MAX_PATH - 1] of Char;
begin
  Directory := DefaultDir;
  FillChar(bi, SizeOf(BROWSEINFO), 0);
  bi.hWndOwner := Handle;
  bi.iImage := 0;
  bi.lParam := 1;
  bi.lpfn := nil;
  bi.lpszTitle := PAnsiChar(Caption);
  bi.ulFlags := BIF_RETURNONLYFSDIRS;
  bi.lpfn := @BrowseCallBackProc;
  bi.lParam := Integer(PAnsiChar(DefaultDir));
  pid := SHBrowseForFolder(bi);
  Result := pid <> nil;
  if Result and SHGetPathFromIDList(pid, buf) then
  begin
    Directory := StrPas(buf);
    if Directory[Length(Directory)] <> '\' then Directory := Directory + '\';
  end;
end;

function BoolToLowerStr(AValue: Boolean): string;
begin
  Result := LowerCase(BoolToStr(AValue, True));
end;

function DeleteDirectory(const AFolder: string): Boolean;
var
  fo: TSHFILEOPSTRUCT;
begin
  FillChar(fo, SizeOf(fo), 0);
  with fo do
  begin
    Wnd := 0;
    wFunc := FO_DELETE;
    pFrom := PChar(AFolder + #0);
    pTo := #0;
    fFlags := FOF_NOCONFIRMATION + FOF_SILENT;
  end;

  Result := SHFileOperation(fo) = 0;
end;

function CopyFolder(const AFrom, ATo: string): Boolean;
Var
  fo: TSHFileOpStruct;
begin
  with fo do
  begin
    Wnd := 0;
    wFunc := FO_Copy;
    pFrom := PAnsiChar(AFrom + #0);
    pTo := PAnsiChar(ATo + #0);
    fFlags := FOF_NOCONFIRMATION or FOF_SILENT;
  end;

  Result := ShFileOperation(fo) = 0;
end;


{ TApp }

constructor TApp.Create;
begin
  CoInitialize(nil);
  SetWindowLong(Application.Handle, GWL_EXSTYLE, GetWindowLong(Application.Handle, GWL_EXSTYLE) or not WS_EX_APPWINDOW);

  FCaption := APP_CAPTION;
  FPath := ExtractFilePath(Application.ExeName);
  FTmpPath := ExtractFilePath(Application.ExeName) + 'temp\';
  FTmpJpg := FTmpPath + 'tmp.jpg';
  if not DirectoryExists(FTmpPath) then ForceDirectories(FTmpPath);
  FExeName := Application.ExeName;
  FWindowState := wsMaximized;
  FRegistry := TRegistry.Create;
  FRegistry.RootKey := HKEY_CURRENT_USER;

  LoadFromReg();
  //释放播放器模板
  GetTemplet;
  //注册aqb文件
  RegAqbFile;
  //写Flash信任文件
  WriteFlashTrustFile;
end;

destructor TApp.Destroy;
begin
  SaveToReg();

  FRegistry.Free;
  WinExec(PAnsiChar('cmd.exe /c rmdir /s/q "' + FTmpPath + '"'), SW_HIDE);
  CoUninitialize();
  inherited Destroy;
end;

procedure TApp.LoadFromReg;
begin
  with FRegistry do
  begin
    if not KeyExists(QUIZ_KEY_NAME) then Exit;

    OpenKey(QUIZ_KEY_NAME, False);
    if ValueExists('WindowState') then FWindowState := TWindowState(ReadInteger('WindowState'));
    if FWindowState = wsMinimized then FWindowState := wsNormal;
    if ValueExists('ShowCount') then FShowCount := ReadBool('ShowCount');
    if RegType = rtTrial then
    begin
      if ValueExists('RegMail') then DeleteValue('RegMail');
      if ValueExists('RegCode') then DeleteValue('RegCode');
    end
    else
    begin
      if ValueExists('RegMail') then FRegMail := ReadString('RegMail');
      if ValueExists('RegCode') then FRegCode := ReadString('RegCode');
    end;

    CloseKey();
  end;
end;

procedure TApp.SaveToReg;
begin
  with FRegistry do
  begin
    if not OpenKey(QUIZ_KEY_NAME, True) then Exit;

    WriteInteger('WindowState', Ord(FWindowState));
    WriteBool('ShowCount', FShowCount);
    if RegType <> rtTrial then
    begin
      WriteString('RegMail', FRegMail);
      WriteString('RegCode', FRegCode);
    end;

    CloseKey();
  end;
end;

function TApp.GetVersion: string;
var
  InfoSize, Wnd: DWORD;
  VerBuf: Pointer;
  szName: array[0..MAX_PATH - 1] of Char;
  Value: Pointer;
  Len: UINT;
  TransString: string;
begin
  InfoSize := GetFileVersionInfoSize(PChar(FExeName), Wnd);
  if InfoSize <> 0 then
  begin
    GetMem(VerBuf, InfoSize);
    try
      if GetFileVersionInfo(PChar(FExeName), Wnd, InfoSize, VerBuf) then
      begin
        Value :=nil;
        VerQueryValue(VerBuf, '\VarFileInfo\Translation', Value, Len);
        if Value <> nil then TransString := IntToHex(MakeLong(HiWord(Longint(Value^)), LoWord(Longint(Value^))), 8);
        Result := '';
        StrPCopy(szName, '\StringFileInfo\'+Transstring+'\FileVersion');  //ProductVersion: 产品版本
        if VerQueryValue(VerBuf, szName, Value, Len) then Result := StrPas(PChar(Value));
      end;
    finally
      FreeMem(VerBuf);
    end;
  end;
end;

function TApp.GetRegType: TRegType;
begin
{$IFDEF _TRIAL}
  Result := rtTrial;
{$ELSE}
  if CheckRegCode(FRegMail, FRegCode) then
    Result := rtNone
  else Result := rtUnReged;
{$ENDIF}
end;

procedure TApp.GetTemplet;
var
  h: HMODULE;
  Stream: TResourceStream;
begin
  h := LoadLibrary('AWQuiz.dll');
  try
    Stream := TResourceStream.Create(h, 'templet', 'SWF');
    Stream.SaveToFile(FTmpPath + QUIZ_TEMPLET);
    Stream.Free;
  finally
    FreeLibrary(h);
  end;
end;

//注册aqb文件类型
procedure TApp.RegAqbFile;
var
  reg: TRegistry;
begin
  reg := TRegistry.Create;
  reg.RootKey := HKEY_CLASSES_ROOT;
  try
    if reg.KeyExists('.aqb') then Exit;

    reg.OpenKey('.aqb', True);
    reg.WriteString('', 'aqbFile');
    reg.CloseKey();

    reg.OpenKey('aqbFile\DefaultIcon', True);
    reg.WriteString('', Application.ExeName + ',1');
    reg.CloseKey();

    reg.OpenKey('aqbFile\shell\open\command', True);
    reg.WriteString('', '"' + Application.ExeName + '" "%1"');
    reg.CloseKey();
  finally
    reg.Free;
  end;
end;

procedure TApp.WriteFlashTrustFile;
  function GetSystemPath: string;
  var
    buf: array [0..MAX_PATH - 1] of Char;
  begin
    GetSystemDirectory(buf, MAX_PATH);
    Result := StrPas(buf) + '\';
  end;

var
  sTrustFile, sSystemPath: string;
  sl: TStrings;
  Drives: set of 0..25;
  Drive: Integer;
  DrivePath: string;
begin
  sSystemPath := GetSystemPath;
  sTrustFile := sSystemPath + 'Macromed\Flash\FlashPlayerTrust\AW_TrustFile.cfg';
  if FileExists(sTrustFile) then Exit;

  if not DirectoryExists(sSystemPath + 'Macromed\Flash\FlashPlayerTrust\') then ForceDirectories(sSystemPath + 'Macromed\Flash\FlashPlayerTrust\');
  sl := TStringList.Create;
  sl.Append('# 秋风试题大师之Flash Player安全信任文件');
  try
    DWORD(Drives) := GetLogicalDrives;
    for Drive := 0 to 25 do
      if Drive in Drives then
      begin
        DrivePath := Char(Ord('A') + Drive) + ':';
        if GetDriveType(PAnsiChar(DrivePath)) = DRIVE_FIXED then
          sl.Append(DrivePath + '\');
      end;

    try
      sl.SaveToFile(sTrustFile);
    except
      //do nothing
    end;
  finally
    sl.Free;
  end;
end;

function GetCanAdd(AHandle: Integer): Boolean;
begin
  if (App.RegType <> rtNone) and (QuizObj.QuesList.Count >= MAX_QUES_COUNT) then
  begin
    Result := False;
    if App.RegType = rtTrial then
      MessageBox(AHandle, PAnsiChar('试用版只能添加' + IntToStr(MAX_QUES_COUNT) + '条试题，您已不能再添加'), '提示', MB_OK + MB_ICONINFORMATION)
    else MessageBox(AHandle, PAnsiChar('未注册版只能添加' + IntToStr(MAX_QUES_COUNT) + '条试题，您已不能再添加'), '提示', MB_OK + MB_ICONINFORMATION);
  end
  else Result := True;
end;

procedure TApp.LoadRecentDocs(AMenuItem: TMenuItem; MenuItemClick: TNotifyEvent);
var
  sl: TStrings;
  i: Integer;
  mi: TMenuItem;
  sProj: string;
begin
  if not FRegistry.KeyExists(QUIZ_KEY_NAME + '\RecentDocs') then Exit;

  //删除原有值
  for i := AMenuItem.Count - 1 downto 0 do
    if Pos('miQuiz', AMenuItem.Items[i].Name) <> 0 then
      AMenuItem.Items[i].Free;

  sl := TStringList.Create;
  try
    //有ReadOnly后，其后所用到的赋值都会错误，故不用
    //FRegistry.OpenKeyReadOnly(QUIZ_KEY_NAME + '\RecentDocs');
    FRegistry.OpenKey(QUIZ_KEY_NAME + '\RecentDocs', False);
    FRegistry.GetValueNames(sl);

    if sl.Count > 0 then
    begin
      for i := 0 to sl.Count - 1 do
      begin
        sProj := FRegistry.ReadString(IntToStr(i + 1));
        if not FileExists(sProj) then Continue;

        mi := TMenuItem.Create(AMenuItem);
        mi.Name := 'miQuiz' + IntToStr(i + 1);
        mi.Caption := sProj;
        mi.OnClick := MenuItemClick;
        AMenuItem.Insert(AMenuItem.Count - 1, mi);
      end;

      //插入分隔条
      mi := TMenuItem.Create(AMenuItem);
      mi.Caption := '-';
      AMenuItem.Insert(AMenuItem.Count - 1, mi);
    end;
    FRegistry.CloseKey();
  finally
    sl.Free;
  end;
end;

procedure TApp.SaveRecentDocs;
var
  sl: TStrings;
  i, Count: Integer;
  sProj: string;
begin
  if not FileExists(QuizObj.ProjPath) or (LowerCase(ExtractFileExt(QuizObj.ProjPath)) <> '.aqb') then Exit;
  if not FRegistry.OpenKey(QUIZ_KEY_NAME + '\RecentDocs', True) then Exit;

  sl := TStringList.Create;
  try
    FRegistry.GetValueNames(sl);
    Count := sl.Count;
    sl.Clear;
    sl.Append(QuizObj.ProjPath);

    //载入原始值...
    for i := 0 to Count - 1 do
      if FRegistry.ValueExists(IntToStr(i + 1)) then
      begin
        sProj := FRegistry.ReadString(IntToStr(i + 1));
        if sl.IndexOf(sProj) = -1 then sl.Append(FRegistry.ReadString(IntToStr(i + 1)));
      end;

    //存入新值
    for i := 0 to sl.Count - 1 do
    begin
      if i = QUIZ_MAX_LIST then Break;

      FRegistry.WriteString(IntToStr(i + 1), sl[i]);
    end;
    FRegistry.CloseKey();
  finally
    sl.Free;
  end;
end;

end.

unit uQuiz;

interface

uses
  Windows, SysUtils, Classes, Registry, FlashObjects, SWFConst, md5;

const
  QUIZ_KEY_NAME = 'Software\QuizBuilder';
  //'我就是門 凡從我進來的 必然得救 並且出入得草吃'
  QUIZ_REG_SEED = '105|109|89|104|101|98|132|-17|-69|82|77|42|95|105|109|122|-24|28|136|80|95|-69|76|115|99|86|80|94|89|99|-69|28|-26|98|109|78|145|99|134|80|94|77|120|78|111';

//检测是否注册成功
function Autumn(const AKey, ACode: string): Boolean; export; stdcall;
//创建一个影片对象
function Wind(const AWidth, AHeight: Integer; const AFps: Integer = 12): TFlashMovie; export; stdcall;

implementation

function CodeToStr(const ACode: string): string;
var
  sl: TStrings;
  i: Integer;
begin
  //获取seed...
  sl := TStringList.Create;
  try
    ExtractStrings(['|'], [], PAnsiChar(ACode), sl);
    for i := 0 to sl.Count - 1 do
      Result := Result + Char(StrToInt(sl[i]) + 101);
  finally
    sl.Free;
  end;
end;

function Autumn(const AKey, ACode: string): Boolean;
  function GetMidCode(const s: string): string;
  var
    sMid: string;
    i: Integer;
  begin
    sMid := UpperCase(MD5Print(MD5String(s)));
    for i := 1 to Length(sMid) do
      if i Mod 8 = 0 then Result := Result + sMid[i];
  end;

var
  s, sCode, sSeed: string;
  i: Integer;
begin
  if (AKey = '') or (ACode = '') then
  begin
    Result := False;
    Exit;
  end;

  s := UpperCase(MD5Print(MD5String('780927+' + AKey + '+790621')));
  for i := 1 to Length(s) do
    if not Odd(i) then sCode := sCode + s[i];

  sSeed := CodeToStr(QUIZ_REG_SEED);
  sCode := Copy(sCode, 1, 8) + GetMidCode(sSeed + AKey + sSeed) + Copy(sCode, 9, 8);
  Result := sCode = ACode;
end;

function Wind(const AWidth, AHeight, AFps: Integer): TFlashMovie;
var
  sMail, sCode: string;
  reg: TRegistry;
begin
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CURRENT_USER;
    reg.OpenKey(QUIZ_KEY_NAME, True);
    if reg.ValueExists('RegMail') then sMail := reg.ReadString('RegMail');
    if reg.ValueExists('RegCode') then sCode := reg.ReadString('RegCode');
  finally
    reg.Free;
  end;

  Result := TFlashMovie.Create(0, 0, AWidth, AHeight, 12, scPix);
  with Result do
  begin
    Version := 8;
    Compressed := False;

    //用Flash SDK原始方法写入as，避免与Compile方法冲突
    with FrameActions do
    begin
      Push(['_global'], [vtString]);
      GetVariable;
      Push(['g_trialVer', not Autumn(sMail, sCode)], [vtString, vtBoolean]);
      SetMember;

      Stop;
    end;
  end;
end;

end.

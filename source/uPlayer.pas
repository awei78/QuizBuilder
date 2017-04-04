{******
  �� Ԫ��uPlayer.pas
  �� �ߣ�������
  �� �ڣ�2007-6-1
  ˵ �������������õ�Ԫ
  �� �£�2008-4-4ʵ����ɫ������ͼƬ���ù��ܡ�
  ע �⣺��LoadMovie(-1, ...)֮��������ShockwaveFlash������EmbedMovie := True���� 
******}

unit uPlayer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uBase, StdCtrls, Buttons, ExtCtrls, Quiz, ComCtrls, OleCtrls,
  ShockwaveFlashObjects_TLB, Grids, RzGrids, CtrlsEx, RzButton, RzRadChk,
  jpeg, ExtDlgs, Mask, RzEdit, RzBtnEdt, ActnList, MPlayer, RzSpnEdt;

type
  TfrmPlayer = class(TfrmBase)
    pcPlayer: TPageControl;
    tsPlayer: TTabSheet;
    tsAuthor: TTabSheet;
    tsText: TTabSheet;
    sf: TShockwaveFlash;
    cbTopic: TCheckBox;
    cbTitle: TCheckBox;
    cbTime: TCheckBox;
    cbPoint: TCheckBox;
    cbLevel: TCheckBox;
    cbTools: TCheckBox;
    cbData: TCheckBox;
    cbMail: TCheckBox;
    cbAudio: TCheckBox;
    cbInfo: TCheckBox;
    cbPrev: TCheckBox;
    cbNext: TCheckBox;
    cbList: TCheckBox;
    lblName: TLabel;
    lblMail: TLabel;
    lblUrl: TLabel;
    lblDes: TLabel;
    edtName: TEdit;
    edtMail: TEdit;
    edtUrl: TEdit;
    meoDes: TMemo;
    sgText: TRzStringGrid;
    tsColor: TTabSheet;
    lblBack: TLabel;
    lblBarClr: TLabel;
    cbBack: TColorBox;
    cbBar: TColorBox;
    lblCrt: TLabel;
    cbCrt: TColorBox;
    lblErr: TLabel;
    cbErr: TColorBox;
    lblTopic: TLabel;
    cbTopicClr: TColorBox;
    cbImage: TRzCheckBox;
    pnlImg: TPanel;
    imgBack: TImage;
    btnAddImg: TSpeedButton;
    btnDelImg: TSpeedButton;
    odBack: TOpenPictureDialog;
    tsSound: TTabSheet;
    cbBackSound: TRzCheckBox;
    Bevel4: TBevel;
    beSound: TRzButtonEdit;
    lblSound: TLabel;
    pnlAct: TPanel;
    btnPlay: TSpeedButton;
    btnPause: TSpeedButton;
    btnStop: TSpeedButton;
    btnDelete: TSpeedButton;
    cbLoop: TCheckBox;
    alSound: TActionList;
    actPlay: TAction;
    actPause: TAction;
    actStop: TAction;
    actDelete: TAction;
    mpSound: TMediaPlayer;
    cbType: TCheckBox;
    Bevel1: TBevel;
    cbEventSound: TRzCheckBox;
    pnlEvent: TPanel;
    lblCrtA: TLabel;
    beCrt: TRzButtonEdit;
    lblErrA: TLabel;
    beErr: TRzButtonEdit;
    lblTryA: TLabel;
    beTry: TRzButtonEdit;
    lblPassA: TLabel;
    bePass: TRzButtonEdit;
    lblFailA: TLabel;
    beFail: TRzButtonEdit;
    Bevel2: TBevel;
    cbWaterMark: TRzCheckBox;
    lblText: TLabel;
    edtText: TEdit;
    lblLink: TLabel;
    edtLink: TEdit;
    lblAlpha: TLabel;
    seAlpha: TRzSpinEdit;
    procedure CheckBoxClick(Sender: TObject);
    procedure ColorBoxChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure pcPlayerChange(Sender: TObject);
    procedure cbImageClick(Sender: TObject);
    procedure seAlphaChange(Sender: TObject);
    procedure btnAddImgClick(Sender: TObject);
    procedure btnDelImgClick(Sender: TObject);
    procedure imgBackDblClick(Sender: TObject);
    procedure cbBackSoundClick(Sender: TObject);
    procedure beSoundButtonClick(Sender: TObject);
    procedure beSoundChange(Sender: TObject);
    procedure sgTextKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure sgTextSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure actPlayExecute(Sender: TObject);
    procedure actPauseExecute(Sender: TObject);
    procedure actStopExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure mpSoundNotify(Sender: TObject);
    procedure cbEventSoundClick(Sender: TObject);
    procedure ButtonEditClick(Sender: TObject);
    procedure cbWaterMarkClick(Sender: TObject);
  private
    { Private declarations }
    FPlayer: TPlayer;
    procedure InitStringList;
    procedure OnMessage(var Msg: TMsg; var Handled: Boolean);
  protected
    procedure LoadData; override;
    procedure SaveData; override;
    procedure ResetData; override;
    //�������
    function CheckData: Boolean; override;  
    //����ͼƬ
    procedure LoadImage(const AImage: string);
    procedure UnLoadImage;
  public
    { Public declarations }
  end;

var
  frmPlayer: TfrmPlayer;

function ShowPlayer(APlayer: TPlayer): Boolean;

implementation

uses SWFConst, uGlobal;

const
  {INFO_ALL    = '���� 2 / 8 \ 10�� \ �м�';
  INFO_POINT  = '���� 2 / 8 \ 10��';
  INFO_LEVEL  = '���� 2 / 8 \ �м�';
  INFO_NO_ALL = '���� 2 / 8';}

  INFO_ALL          = '���� 2 / 8 \ ��ѡ�� \ 10�� \ �м�';
  INFO_TYPE_POINT   = '���� 2 / 8 \ ��ѡ�� \ 10��';
  INFO_TYPE_LEVEL   = '���� 2 / 8 \ ��ѡ�� \ �м�';
  INFO_POINT_LEVEL  = '���� 2 / 8 \ 10�� \ �м�';
  INFO_TYPE         = '���� 2 / 8 \ ��ѡ��';
  INFO_POINT        = '���� 2 / 8 \ 10��';
  INFO_LEVEL        = '���� 2 / 8 \ �м�';
  INFO_NO_ALL       = '���� 2 / 8';


{$R *.dfm}

function ShowPlayer(APlayer: TPlayer): Boolean;
begin
  with TfrmPlayer.Create(Application.MainForm) do
  begin
    try
      Application.OnMessage := OnMessage;
      FPlayer := APlayer;
      QuizObj.ImageList.GetIcon(5, Icon);
      LoadData();
      Result := ShowModal = mrOk;
    finally
      Free;
      Application.OnMessage := nil;
    end;
  end;
end;

{ TfrmPlayer }

procedure TfrmPlayer.InitStringList;
var
  i: Integer;
begin
  with sgText do
  begin
    //���
    ColWidths[0] := 20;
    ColWidths[1] := 163;
    ColWidths[2] := 245;

    RowCount := 68;
    Cells[1, 0] := '����';
    Cells[2, 0] := '�Զ�����Ϣ';
    for i := 0 to sgText.RowCount - 1 do
      Cells[0, i + 1] := IntToStr(i + 1);

    //��ʼ��������
    Cells[1, 1] := 'ȫ�����Ų˵�';
    Cells[1, 2] := '�����ߴ�˵�';
    Cells[1, 3] := '��������';
    Cells[1, 4] := '����ָʾ';
    Cells[1, 5] := '����ָʾ';
    Cells[1, 6] := '��ʼ��ť����';
    Cells[1, 7] := '����';
    Cells[1, 8] := '�ָ���';
    Cells[1, 9] := '��ֵ�ı�';
    Cells[1, 10] := '������Ϣ�ı�';
    Cells[1, 11] := '��ȷ';
    Cells[1, 12] := '����';
    Cells[1, 13] := '�������˺�';
    Cells[1, 14] := '�������ʼ�';
    Cells[1, 15] := '��¼�ʺ�';
    Cells[1, 16] := '�ύ��ť';
    Cells[1, 17] := '�鿴�����ť';
    Cells[1, 18] := '���ⰴť';
    Cells[1, 19] := '���ⰴť';
    Cells[1, 20] := '���԰�ť';
    Cells[1, 21] := '�����ť';
    Cells[1, 22] := '��ɰ�ť';
    Cells[1, 23] := 'ȷ����ť';
    Cells[1, 24] := '�ǰ�ť';
    Cells[1, 25] := '��ť';
    Cells[1, 26] := 'ʣ��ʱ��ָʾ';
    Cells[1, 27] := '��Ŀ�б�';
    Cells[1, 28] := '���Խ���ı�';
    Cells[1, 29] := '���Ե÷��ı�';
    Cells[1, 30] := 'ͨ�������ı�';
    Cells[1, 31] := '�����ܷ��ı�';
    Cells[1, 32] := '���������ı�';
    Cells[1, 33] := '���������ı�';
    Cells[1, 34] := '���������ı�';
    Cells[1, 35] := '�����ʾ�ı�';
    Cells[1, 36] := '���˺���ʾ';
    Cells[1, 37] := '�������ʾ';
    Cells[1, 38] := 'δ�����ʾ';
    Cells[1, 39] := '�鿴�����ʾ';
    Cells[1, 40] := '����ʱ�޵���ʾ';
    Cells[1, 41] := '�����ɽ��ܴ�';
    Cells[1, 42] := '�����ο���';
    Cells[1, 43] := '�����ټ�����ʾ';
    Cells[1, 44] := '���׼�';
    Cells[1, 45] := '����';
    Cells[1, 46] := '�м�';
    Cells[1, 47] := '�߼�';
    Cells[1, 48] := '����';
    Cells[1, 49] := '���ͽ�����������ݿ���ʾ';
    Cells[1, 50] := '���ͽ����������������ʾ';
    Cells[1, 51] := '��/�ر�������ʾ';
    //������Ϣ����
    Cells[1, 52] := '������Ϣ��ʾ';
    Cells[1, 53] := '�����ı�';
    Cells[1, 54] := '�ʼ��ı�';
    Cells[1, 55] := '��ҳ�ı�';
    Cells[1, 56] := '�����ı�';
    //���Ͳ���
    Cells[1, 57] := '�ط���������ʾ';
    Cells[1, 58] := '�ط����ʼ���ʾ';
    Cells[1, 59] := '���ӷ�����ʧ����ʾ';
    //��¼����
    Cells[1, 60] := '�����˺�';
    Cells[1, 61] := '��������';
    Cells[1, 62] := '��¼��ť';
    Cells[1, 63] := '���������ʾ';
    Cells[1, 64] := '�˺Ż����������ʾ';
    //��ҳ����
    Cells[1, 65] := '��վ������ʾ';
    Cells[1, 66] := '����������ʾ';
    //����ʾ����
    Cells[1, 67] := '���趨����ʾ����������ʾ��';
    //�����ı�
    for i := 0 to FPlayer.Texts.Count - 1 do
      Cells[2, i + 1] := FPlayer.Texts[i];
  end;
end;

procedure TfrmPlayer.OnMessage(var Msg: TMsg; var Handled: Boolean);
begin
  Handled := (Msg.message = WM_RBUTTONDOWN) and (Msg.hwnd = sf.Handle);
end;

procedure TfrmPlayer.CheckBoxClick(Sender: TObject);
var
  sVisible, sInfo: string;
  i, Tag: Integer;
  fDataX, fMailX, fAudioX, fInfoX: Double;
begin
  if not (Sender is TCheckBox) then Exit;

  //��������ʽ���
  if TCheckBox(Sender).Checked then
    sVisible := '1'
  else sVisible := '0';
  cbTitle.Enabled := cbTopic.Checked;
  cbTime.Enabled  := cbTopic.Checked;
  cbType.Enabled  := cbTopic.Checked;
  cbPoint.Enabled := cbTopic.Checked;
  cbLevel.Enabled := cbTopic.Checked;
  cbTools.Enabled := cbTopic.Checked;
  cbData.Enabled  := cbTopic.Checked and cbTools.Checked;
  cbMail.Enabled  := cbTopic.Checked and cbTools.Checked;
  cbAudio.Enabled := cbTopic.Checked and cbTools.Checked;
  cbInfo.Enabled  := cbTopic.Checked and cbTools.Checked;

  Tag := TCheckBox(Sender).Tag;
  case Tag of
    0:
    begin
      if TCheckBox(Sender).Checked then
      begin
        sf.GotoFrame(0);
        //�ش�������
        for i := 0 to tsPlayer.ControlCount - 1 do
          if tsPlayer.Controls[i] is TCheckBox then
          begin
            if TCheckBox(tsPlayer.Controls[i]).Tag = 0 then Continue;
            TCheckBox(tsPlayer.Controls[i]).OnClick(tsPlayer.Controls[i]);
          end;
      end
      else sf.GotoFrame(1);
    end;
    1: sf.TSetProperty('txt_title', fpVisible, sVisible);
    2: sf.TSetProperty('mc_time', fpVisible, sVisible);
    3, 4, 5:
    begin
      if cbType.Checked and cbPoint.Checked and cbLevel.Checked then
        sInfo := INFO_ALL
      else if cbType.Checked and cbPoint.Checked then
        sInfo := INFO_TYPE_POINT
      else if cbType.Checked and cbLevel.Checked then
        sInfo := INFO_TYPE_LEVEL
      else if cbPoint.Checked and cbLevel.Checked then
        sInfo := INFO_POINT_LEVEL
      else if cbType.Checked then
        sInfo := INFO_TYPE
      else if cbPoint.Checked then
        sInfo := INFO_POINT
      else if cbLevel.Checked then
        sInfo := INFO_LEVEL
      else sInfo := INFO_NO_ALL;

      sf.SetVariable('mc_top.cap', sInfo);
    end;
    6: sf.TSetProperty('mc_top.mc_tool', fpVisible, sVisible);
    //��̬���������λ��
    7, 8, 9, 10:
    begin
      //|----------------------------|
      //| data | mail | audio | info |
      //|----------------------------|
      // 0      36     67.7    100.3
      fInfoX := 100.3;
      if cbInfo.Checked then
      begin
        fAudioX := fInfoX - 32.6;
        sf.TSetProperty('mc_top.mc_tool.btn_info', fpVisible, '1');
      end
      else
      begin
        fAudioX := fInfoX;
        sf.TSetProperty('mc_top.mc_tool.btn_info', fpVisible, '0');
      end;
      if cbAudio.Checked then
      begin
        fMailX := fAudioX - 31.7;
        sf.TSetProperty('mc_top.mc_tool.btn_audio', fpVisible, '1');
      end
      else
      begin
        fMailX := fAudioX;
        sf.TSetProperty('mc_top.mc_tool.btn_audio', fpVisible, '0');
      end;
      if cbMail.Checked then
      begin
        //�˴���Ϊ-36������Ϊ0��Ӧ��û�н�������
        fDataX := fMailX - 35;
        sf.TSetProperty('mc_top.mc_tool.btn_mail', fpVisible, '1');
      end
      else
      begin
        fDataX := fMailX;
        sf.TSetProperty('mc_top.mc_tool.btn_mail', fpVisible, '0');
      end;
      if cbData.Checked then
        sf.TSetProperty('mc_top.mc_tool.btn_data', fpVisible, '1')
      else sf.TSetProperty('mc_top.mc_tool.btn_data', fpVisible, '0');

      //λ���趨
      sf.TSetProperty('mc_top.mc_tool.btn_data', fpPosX, FormatFloat('#.##', fDataX));
      sf.TSetProperty('mc_top.mc_tool.btn_mail', fpPosX, FormatFloat('#.##', fMailX));
      sf.TSetProperty('mc_top.mc_tool.btn_audio', fpPosX, FormatFloat('#.##', fAudioX));
      sf.TSetProperty('mc_top.mc_tool.btn_info', fpPosX, FormatFloat('#.##', fInfoX));
    end;
    11: sf.TSetProperty('mc_prev', fpVisible, sVisible);
    12: sf.TSetProperty('mc_next', fpVisible, sVisible);
    13: sf.TSetProperty('btn_list', fpVisible, sVisible);
  end;
end;

procedure TfrmPlayer.LoadData;
begin
  //���ز�����
  sf.Movie := App.TmpPath + QUIZ_TEMPLET;

  with FPlayer do
  begin
    //������
    with PlayerSet do
    begin
      cbTopic.Checked := ShowTopic;
      cbTitle.Checked := ShowTitle;
      cbTime.Checked := ShowTime;
      cbType.Checked := ShowType;
      cbPoint.Checked := ShowPoint;
      cbLevel.Checked := ShowLevel;
      cbTools.Checked := ShowTool;
      cbData.Checked := ShowData;
      cbMail.Checked := ShowMail;
      cbAudio.Checked := ShowAudio;
      cbInfo.Checked := ShowAuthor;
      cbPrev.Checked := ShowPrev;
      cbNext.Checked := ShowNext;
      cbList.Checked := ShowList;
    end;
    //��ɫ����
    with ColorSet do
    begin
      cbBack.Selected := BackColor;
      cbTopicClr.Selected := TitleColor;
      cbBar.Selected := BarColor;
      cbCrt.Selected := CrtColor;
      cbErr.Selected := ErrColor;
      cbBack.OnChange(cbBack);
      cbImage.Checked := BackImage.Enabled;
      imgBack.Image := BackImage.Image;
      seAlpha.Value := BackImage.Alpha;
      if BackImage.Enabled then LoadImage(BackImage.Image);
    end;
    //��������
    with BackSound do
    begin
      cbBackSound.Checked := Enabled;
      cbBackSound.OnClick(cbBackSound);
      beSound.Text := SndFile;
      beSound.OnChange(beSound);
      cbLoop.Checked := LoopPlay;
    end;
    with EventSound do
    begin
      cbEventSound.Checked := Enabled;
      cbEventSound.OnClick(cbEventSound);
      beCrt.Text := SndCrt;
      beErr.Text := SndErr;
      beTry.Text := SndTry;
      bePass.Text := SndPass;
      beFail.Text := SndFail;
    end;
    //������Ϣ
    with AuthorSet do
    begin
      edtName.Text := Name;
      edtMail.Text := Mail;
      edtUrl.Text := Url;
      meoDes.Text := Des;
    end;
    //ˮӡ
    cbWaterMark.Enabled := App.RegType = rtNone;
    cbWaterMark.Checked := not cbWaterMark.Enabled or WaterMark.Enabled;
    cbWaterMark.OnClick(cbWaterMark);
    if App.RegType <> rtNone then
    begin
      if App.RegType = rtTrial then
        edtText.Text := '��������ʦ ���ð�'
      else edtText.Text := '��������ʦ δע���';
      edtLink.Text := 'http://www.awindsoft.net';
    end
    else
      with WaterMark do
      begin
        edtText.Text := Text;
        edtLink.Text := Link;
      end;
  end;

  InitStringList();
  //��������͸�����Ա��������Label����ʾ������
  cbImage.Transparent := True;
  cbBackSound.Transparent := True;
  cbEventSound.Transparent := True;
  cbWatermark.Transparent := True;
end;

procedure TfrmPlayer.SaveData;
var
  i: Integer;
begin
  with FPlayer do
  begin
    with PlayerSet do
    begin
      ShowTopic := cbTopic.Checked;
      ShowTitle := cbTitle.Checked;
      ShowTime := cbTime.Checked;
      ShowType := cbType.Checked;
      ShowPoint := cbPoint.Checked;
      ShowLevel := cbLevel.Checked;
      ShowTool := cbTools.Checked;
      ShowData := cbData.Checked;
      ShowMail := cbMail.Checked;
      ShowAudio := cbAudio.Checked;
      ShowAuthor := cbInfo.Checked;
      ShowPrev := cbPrev.Checked;
      ShowNext := cbNext.Checked;
      ShowList := cbList.Checked;
    end;

    with ColorSet do
    begin
      BackColor := cbBack.Selected;
      TitleColor := cbTopicClr.Selected;
      BarColor := cbBar.Selected;
      CrtColor := cbCrt.Selected;
      ErrColor := cbErr.Selected;
      BackImage.Enabled := cbImage.Checked;
      BackImage.Image := imgBack.Image;
      BackImage.Alpha := seAlpha.IntValue;
    end;

    with BackSound do
    begin
      Enabled := cbBackSound.Checked;
      SndFile := beSound.Text;
      LoopPlay := cbLoop.Checked;
    end;
    with EventSound do
    begin
      Enabled := cbEventSound.Checked;
      SndCrt := beCrt.Text;
      SndErr := beErr.Text;
      SndTry := beTry.Text;
      SndPass := bePass.Text;
      SndFail := beFail.Text;
    end;

    with AuthorSet do
    begin
      Name := edtName.Text;
      Mail := edtMail.Text;
      Url := edtUrl.Text;
      Des := meoDes.Text;
    end;
    with WaterMark do
    begin
      Enabled := cbWaterMark.Checked;
      Text := edtText.Text;
      Link := edtLink.Text;
    end;

    //�������ַ���
    Texts.Clear;
    for i := 0 to sgText.RowCount - 1 do
      Texts.Append(sgText.Cells[2, i + 1]);
    
    SaveToReg();
  end;
end;

procedure TfrmPlayer.ResetData;
var
  i: Integer;
begin
  case pcPlayer.ActivePageIndex of
    0: //����������
    begin
      for i := 0 to tsPlayer.ControlCount - 1 do
        if tsPlayer.Controls[i] is TCheckBox then
        begin
          TCheckBox(tsPlayer.Controls[i]).Checked := True;
          if TCheckBox(tsPlayer.Controls[i]).Tag = 3 then TCheckBox(tsPlayer.Controls[i]).Checked := False;
        end;
    end;
    1: //��ɫ����
    begin
      cbBack.Selected := clWhite;
      cbTopicClr.Selected := $00333333;
      cbBar.Selected := $00B99D7F;
      cbCrt.Selected := $00008000;
      cbErr.Selected := $00000080;
      cbBack.OnChange(cbBack);
      cbImage.Checked := False;
      imgBack.Image := '';
      seAlpha.Value := 0;
      UnLoadImage();
    end;
    2: //��������
    begin
      cbBackSound.Checked := False;
      beSound.Text := '';
      cbLoop.Checked := False;

      cbEventSound.Checked := False;
      beCrt.Text := '';
      beErr.Text := '';
      beTry.Text := '';
      bePass.Text := '';
      beFail.Text := '';
    end;
    3: //������Ϣ&ˮӡ
    begin
      edtName.Text := '';
      edtMail.Text := '@';
      edtUrl.Text := 'http://';
      meoDes.Text := '';
      if cbWaterMark.Enabled then
      begin
        cbWaterMark.Checked := False;
        edtText.Text := '';
        edtLink.Text := 'http://';
      end;
    end;
    4: //�������ַ���
      sgText.Cols[2].Text := '�Զ�����Ϣ' + #13#10 + FPlayer.GetTexts;
  end;
end;

function TfrmPlayer.CheckData: Boolean;
begin
  Result := False;
  if cbWaterMark.Checked and (Trim(edtText.Text) = '') then
  begin
    pcPlayer.ActivePageIndex := 3;
    MessageBox(Handle, PAnsiChar('��������Ҫ���õ�ˮӡ�ı���'), '��ʾ', MB_OK + MB_ICONINFORMATION);
    edtText.SetFocus;
    Exit;
  end;

  Result := inherited CheckData();
end;

procedure TfrmPlayer.LoadImage(const AImage: string);
const
  IMG_WIDTH = 480;
  IMG_HEIGHT = 360;
var
  pic: TPicture;
  bmp: TBitmap;
  jpg: TJPEGImage;
  Rect: TRect;
  fScale: Double;
begin
  if not FileExists(AImage) then Exit;

  pic := TPicture.Create;
  bmp := TBitmap.Create;
  jpg := TJPEGImage.Create;
  try
    pic.LoadFromFile(AImage);
    bmp.PixelFormat := pf24bit;
    bmp.Canvas.Brush.Color := cbBack.Selected;
    bmp.Width := IMG_WIDTH;
    bmp.Height := IMG_HEIGHT;

    fScale := pic.Height / pic.Width;
    if fScale = IMG_HEIGHT / IMG_WIDTH then
      Rect := Classes.Rect(0, 0, IMG_WIDTH, IMG_HEIGHT)
    else if fScale > IMG_HEIGHT / IMG_WIDTH then
    begin
      fScale := IMG_HEIGHT / pic.Height;
      Rect := Classes.Rect(Round((IMG_WIDTH - pic.Width * fScale) / 2), 0, Round((IMG_WIDTH - pic.Width * fScale) / 2 + pic.Width * fScale), IMG_HEIGHT)
    end
    else
    begin
      fScale := IMG_WIDTH / pic.Width;
      Rect := Classes.Rect(0, Round((IMG_HEIGHT - pic.Height * fScale) / 2), IMG_WIDTH, Round((IMG_HEIGHT - pic.Height * fScale) / 2 + pic.Height * fScale));
    end;

    bmp.Canvas.StretchDraw(Rect, pic.Graphic);
    jpg.Assign(bmp);
    jpg.SaveToFile(App.TmpJpg);
    //sf.TSetProperty('_root.mc_back.back', fpVisible, '0');
    sf.TSetProperty('_root.mc_back.back', fpAlpha, seAlpha.Text);
    sf.LoadMovie(-1, App.TmpJpg);
  finally
    pic.Free;
    bmp.Free;
    jpg.Free;
  end;
end;

procedure TfrmPlayer.UnLoadImage;
begin
  sf.LoadMovie(-1, '');
  sf.TSetProperty('_root.mc_back.back', fpAlpha, '100');
end;

procedure TfrmPlayer.FormShow(Sender: TObject);
begin
  inherited;
  pcPlayer.ActivePageIndex := 0;
  cbTopic.SetFocus;
  pcPlayer.ActivePageIndex := FPlayer.PageIndex;
  pcPlayer.OnChange(pcPlayer);
end;

procedure TfrmPlayer.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  if FPlayer.PageIndex <> pcPlayer.ActivePageIndex then FPlayer.PageIndex := pcPlayer.ActivePageIndex;
end;

procedure TfrmPlayer.pcPlayerChange(Sender: TObject);
begin
  case pcPlayer.ActivePageIndex of
    0:
    begin
      HelpHtml := 'player_set.html';
      if sf.Parent <> tsPlayer then sf.Parent := tsPlayer;
      cbTopic.SetFocus;
    end;
    1:
    begin
      HelpHtml := 'player_color.html';
      if sf.Parent <> tsColor then sf.Parent := tsColor;
    end;
    2:
    begin
      if cbBackSound.Checked then beSound.OnChange(beSound);
      HelpHtml := 'player_sound.html';
    end;
    3: HelpHtml := 'player_author.html';
    4:
    begin
      HelpHtml := 'player_text.html';
      sgText.TabStops[1] := False;
      sgText.Col := 2;
      sgText.Row := 1;
    end;
  end;
end;    

procedure TfrmPlayer.ColorBoxChange(Sender: TObject);
begin
  sf.SetVariable('clrBack', GetColorStr(cbBack.Selected));
  sf.SetVariable('clrTitle', GetColorStr(cbTopicClr.Selected));
  sf.SetVariable('clrBar', GetColorStr(cbBar.Selected));

  sf.TCallFrame('_root', 0);
  if (Sender = cbBack) and cbImage.Checked and FileExists(imgBack.Image) then LoadImage(imgBack.Image);
end;

procedure TfrmPlayer.cbImageClick(Sender: TObject);
begin
  btnAddImg.Enabled := cbImage.Checked;
  btnDelImg.Enabled := cbImage.Checked;
  imgBack.Enabled := cbImage.Checked;
  lblAlpha.Enabled := cbImage.Checked;
  seAlpha.Enabled := cbImage.Checked;
  if cbImage.Checked then
    LoadImage(imgBack.Image)
  else UnLoadImage();
end;

procedure TfrmPlayer.seAlphaChange(Sender: TObject);
begin
  sf.TSetProperty('_root.mc_back.back', fpAlpha, seAlpha.Text);
end;

procedure TfrmPlayer.btnAddImgClick(Sender: TObject);
begin
  if odBack.Execute then
  begin
    imgBack.Image := odBack.FileName;
    LoadImage(odBack.FileName);
  end;
end;

procedure TfrmPlayer.btnDelImgClick(Sender: TObject);
begin
  imgBack.Image := '';
  pnlImg.Caption := 'û��ͼƬ';
  UnLoadImage();
end;

procedure TfrmPlayer.imgBackDblClick(Sender: TObject);
begin
  btnAddImg.OnClick(btnAddImg);
end;

procedure TfrmPlayer.cbBackSoundClick(Sender: TObject);
begin
  lblSound.Enabled := cbBackSound.Checked;
  beSound.Enabled := lblSound.Enabled;
  pnlAct.Enabled := lblSound.Enabled;
  cbLoop.Enabled := lblSound.Enabled;
  beSound.OnChange(beSound);
end;

procedure TfrmPlayer.ButtonEditClick(Sender: TObject);
var
  od: TOpenDialog;
begin
  od := TOpenDialog.Create(Self);

  try
    od.Filter := '֧�ֵ���Ƶ�ļ�(*.mp3; *.wav)|*.mp3;*.wav';
    if od.Execute then
    begin
      TRzButtonEdit(Sender).Text := od.FileName;
      if (Sender = beSound) and actPlay.Enabled then actPlay.OnExecute(actPlay);
    end;
  finally
    od.Free;
  end;
end;

procedure TfrmPlayer.beSoundButtonClick(Sender: TObject);
begin
  ButtonEditClick(Sender);
end;

procedure TfrmPlayer.beSoundChange(Sender: TObject);
begin
  if actStop.Enabled then actStop.OnExecute(actStop);
  actPlay.Enabled := cbBackSound.Checked and FileExists(beSound.Text) and (Pos(ExtractFileExt(beSound.Text), '.mp3.wav') > 0);
  btnPlay.BringToFront;
  actStop.Enabled := False;
  actDelete.Enabled := cbBackSound.Checked;

  btnPlay.Enabled := actPlay.Enabled;
  btnPause.Enabled := actPause.Enabled;
  btnStop.Enabled := actStop.Enabled;
  btnDelete.Enabled := actDelete.Enabled;

  if actPlay.Enabled then mpSound.FileName := beSound.Text;
end;

procedure TfrmPlayer.sgTextKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then PostMessage(sgText.Handle, WM_KEYDOWN, VK_TAB, 0);
  if (Key = VK_TAB) and (sgText.Row = sgText.RowCount - 1) then btnOK.SetFocus;
end;

procedure TfrmPlayer.sgTextSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  if ACol = 2 then
    sgText.Options := sgText.Options + [goEditing, goAlwaysShowEditor]
  else sgText.Options := sgText.Options - [goEditing, goAlwaysShowEditor];
end;

procedure TfrmPlayer.actPlayExecute(Sender: TObject);
begin
  if mpSound.Mode = mpPaused then
    mpSound.Resume
  else
  begin
    mpSound.Open;
    mpSound.Play;
  end;

  btnPause.BringToFront;
  actStop.Enabled := True;
end;

procedure TfrmPlayer.actPauseExecute(Sender: TObject);
begin
  mpSound.Pause;
  btnPlay.BringToFront;
end;

procedure TfrmPlayer.actStopExecute(Sender: TObject);
begin
  if not FileExists(mpSound.FileName) then Exit;

  mpSound.Stop;
  btnPlay.BringToFront;
  actStop.Enabled := False;
end;

procedure TfrmPlayer.actDeleteExecute(Sender: TObject);
begin
  beSound.Text := '';
end;

procedure TfrmPlayer.mpSoundNotify(Sender: TObject);
begin
  if (mpSound.Position = mpSound.Length) and (mpSound.NotifyValue = nvSuccessful) and actStop.Enabled then
  begin
    actStop.OnExecute(actStop);
    if cbLoop.Checked then actPlay.OnExecute(actPlay);
  end;
end;

procedure TfrmPlayer.cbEventSoundClick(Sender: TObject);
begin
  pnlEvent.Enabled := cbEventSound.Checked;
end;

procedure TfrmPlayer.cbWaterMarkClick(Sender: TObject);
begin
  lblText.Enabled := cbWaterMark.Checked and cbWaterMark.Enabled;
  edtText.Enabled := lblText.Enabled;
  lblLink.Enabled := lblText.Enabled;
  edtLink.Enabled := lblText.Enabled;
end;

end.

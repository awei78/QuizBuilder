{******
  单 元：uHotSpot.pas
  作 者：刘景威
  日 期：2007-11-25
  说 明：热点题单元
  更 新：
******}

unit uHotSpot;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, Buttons, ExtCtrls, PngImage;

type
  //鼠标在指示区的位置
  TMousePosition = (mpNone, mpLeft, mpTop, mpRight, mpBottom, mpTopLeft, mpTopRight,
    mpBottomLeft, mpBottomRight, mpMiddle);

  TShape = class(ExtCtrls.TShape)
  protected
    procedure Paint; override;
  end;

  TfraHotspot = class(TFrame)
    sbImg: TScrollBox;
    img: TImage;
    imgHot: TImage;
    spRect: TShape;
    procedure imgClick(Sender: TObject);
    procedure imgMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure imgMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure imgMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure spRectMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure spRectMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure spRectMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sbImgCanResize(Sender: TObject; var NewWidth,
      NewHeight: Integer; var Resize: Boolean);
  private
    { Private declarations }
    FImage: string;
    FEdit: Boolean;
    FIsDown: Boolean;
    FOldX: Integer;
    FOldY: Integer;
    FHPos: Integer;
    FVPos: Integer;
    FImgSize: TSize;
    FMousePosition: TMousePosition;
    procedure SetImage(Value: string);
    procedure SetEdit(Value: Boolean);
    procedure SetHotPos(const AScale: Single); overload;
    procedure SetImageInRect;
  public
    { Public declarations }
    procedure SetImageToOri;
    procedure SetImageToFit;
    procedure SetHotPos(const ARect: TRect); overload;
  published
    property Image: string read FImage write SetImage;
    property Edit: Boolean read FEdit write SetEdit;
  end;

implementation

uses uGlobal;

//热点鼠标感应宽度
const
  PRECISION = 4;
  MIN_SIZE  = 8;
  IMG_WIDTH = 377;
  IMG_HEIGHT = 189;

{$R *.dfm}

{ TfraHotspot }

procedure TfraHotspot.SetImage(Value: string);
begin
  if not FileExists(Value) then Exit;

  if FImage <> Value then
  begin
    FImage := Value;
    FImgSize := GetImageSize(Value);
    img.Picture.LoadFromFile(Value);
    if not FEdit then sbImg.SetFocus;

    spRect.Visible := False;
    imgHot.Visible := False;

    //限制越界滚动
    sbImg.HorzScrollBar.Range := img.Width;
    sbImg.VertScrollBar.Range := img.Height;
    sbImg.HorzScrollBar.Position := 0;
    sbImg.VertScrollBar.Position := 0;
  end;
end;

procedure TfraHotspot.SetEdit(Value: Boolean);
begin
  if FEdit <> Value then FEdit := Value;
  
  spRect.Visible := Value;
  imgHot.Visible := Value;
end;

procedure TfraHotspot.SetHotPos(const AScale: Single);
begin
  sbImg.HorzScrollBar.Position := 0;
  sbImg.VertScrollBar.Position := 0;
  spRect.Left := Round(spRect.Left * AScale);
  spRect.Top := Round(spRect.Top * AScale);
  spRect.Width := Round(spRect.Width * AScale);
  spRect.Height := Round(spRect.Height * AScale);

  SetImageInRect();
end;

procedure TfraHotspot.SetHotPos(const ARect: TRect);
begin
  spRect.Visible := True;
  imgHot.Visible := True;
  spRect.Left := ARect.Left;
  spRect.Top := ARect.Top;
  spRect.Width := ARect.Right;
  spRect.Height := ARect.Bottom;

  SetImageInRect();
end;

procedure TfraHotspot.SetImageInRect;
begin
  imgHot.Left := spRect.Left;
  imgHot.Top := spRect.Top;
  imgHot.Width := spRect.Width;
  imgHot.Height := spRect.Height;
end;

procedure TfraHotspot.imgClick(Sender: TObject);
begin
  SetFocus();
end;

procedure TfraHotspot.SetImageToOri;
begin
  //重设热点位置及大小
  if not img.AutoSize and spRect.Visible then
  begin
    if FImgSize.cy / FImgSize.cx > IMG_HEIGHT / IMG_WIDTH then
      SetHotPos(FImgSize.cy / IMG_HEIGHT)
    else SetHotPos(FImgSize.cx / IMG_WIDTH);
  end;

  Align := alNone;
  sbImg.Align := alNone;
  if TForm(Parent.Parent.Parent).Active then sbImg.SetFocus;
  img.Align := alNone;
  img.AutoSize := True;

  //限制越界滚动
  sbImg.HorzScrollBar.Range := img.Width;
  sbImg.VertScrollBar.Range := img.Height;
  sbImg.HorzScrollBar.Position := FHPos;
  sbImg.VertScrollBar.Position := FVPos;
end;

procedure TfraHotspot.SetImageToFit;
begin
  FHPos := sbImg.HorzScrollBar.Position;
  FVPos := sbImg.VertScrollBar.Position;
  //重设热点位置及大小
  if img.AutoSize and spRect.Visible then
  begin
    if FImgSize.cy / FImgSize.cx > IMG_HEIGHT / IMG_WIDTH then
      SetHotPos(IMG_HEIGHT / FImgSize.cy)
    else SetHotPos(IMG_WIDTH / FImgSize.cx);
  end;

  Align := alClient;
  sbImg.Align := alClient;
  if TForm(Parent.Parent.Parent).Active then sbImg.SetFocus;
  img.AutoSize := False;
  img.Stretch := True;
  img.Proportional := True;

  //设置Image尺寸
  if FImgSize.cy / FImgSize.cx > IMG_HEIGHT / IMG_WIDTH then
  begin
    img.Width := Round(FImgSize.cx * IMG_HEIGHT / FImgSize.cy);
    img.Height := IMG_HEIGHT;
  end
  else
  begin
    img.Width := IMG_WIDTH;
    img.Height := Round(FImgSize.cy * IMG_WIDTH / FImgSize.cx);
  end;

  //限制越界滚动
  sbImg.HorzScrollBar.Range := img.Width;
  sbImg.VertScrollBar.Range := img.Height;
end;

procedure TfraHotspot.imgMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FIsDown := True;
  FOldX := X;
  FOldY := Y;
end;

procedure TfraHotspot.imgMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if not FIsDown then Exit;

  if X < 0 then X := 0;
  if X > img.Width then X := img.Width;
  if Y < 0 then Y := 0;
  if Y > img.Height then Y := img.Height;
  //显示热点
  if (Abs(X - FOldX) > 0) and (Abs(Y - FOldY) > 0) then
  begin
    spRect.Visible := True;
    imgHot.Visible := True;
    if X > FOldX then
      spRect.Left := FOldX
    else spRect.Left := X;
    if Y > FOldY then
      spRect.Top := FOldY
    else spRect.Top := Y;
    spRect.Left := spRect.Left - sbImg.HorzScrollBar.Position;
    spRect.Top := spRect.Top - sbImg.VertScrollBar.Position;

    spRect.Width := Abs(X - FOldX);
    spRect.Height := Abs(Y - FOldY);

    SetImageInRect();
  end;
end;

procedure TfraHotspot.imgMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FIsDown := False;
end;

procedure TfraHotspot.spRectMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FOldX := X;
  FOldY := Y;

  //设置鼠标位置
  case spRect.Cursor of
    crSizeNWSE:
      if X <= PRECISION then
        FMousePosition := mpTopLeft
      else FMousePosition := mpBottomRight;
    crSizeNESW:
      if X <= PRECISION then
        FMousePosition := mpBottomLeft
      else FMousePosition := mpTopRight;
    crSizeWE:
      if X <= PRECISION then
        FMousePosition := mpLeft
      else FMousePosition := mpRight;
    crSizeNS:
      if Y <= PRECISION then
        FMousePosition := mpTop
      else FMousePosition := mpBottom;
    crSizeAll: FMousePosition := mpMiddle;
  end;
end;

procedure TfraHotspot.spRectMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  //TForm(Parent.Parent.Parent).Caption := Format('hpos: %d; vpos: %d', [sbImg.HorzScrollBar.Position, sbImg.VertScrollBar.Position]);

  if FMousePosition = mpNone then
  begin
    //左上角、右下角
    if (X <= PRECISION) and (Y <= PRECISION) or (X >= spRect.Width - PRECISION) and (Y >= spRect.Height - PRECISION) then
      spRect.Cursor := crSizeNWSE
    //左上角、右上角
    else if (X <= PRECISION) and (Y >= spRect.Height - PRECISION) or (X >= spRect.Width - PRECISION) and (Y <= PRECISION) then
      spRect.Cursor := crSizeNESW
    //左部、右部
    else if (X <= PRECISION) or (X >= spRect.Width - PRECISION) then
      spRect.Cursor := crSizeWE
    //上部、下部
    else if (Y <= PRECISION) or (Y >= spRect.Height - PRECISION) then
      spRect.Cursor := crSizeNS
    else spRect.Cursor := crSizeAll;
  end;

  //改变大小或移动...
  //左部
  if FMousePosition in [mpTopLeft, mpLeft, mpBottomLeft] then
  begin
    if spRect.Left + X < - sbImg.HorzScrollBar.Position then X := - sbImg.HorzScrollBar.Position - spRect.Left;
    if spRect.Width - X < MIN_SIZE then X := spRect.Width - MIN_SIZE;

    spRect.Left := spRect.Left + X;
    spRect.Width := spRect.Width - X;
  end;
  //上部
  if FMousePosition in [mpTopLeft, mpTop, mpTopRight] then
  begin
    if spRect.Top + Y < - sbImg.VertScrollBar.Position then Y := - sbImg.VertScrollBar.Position - spRect.Top;
    if spRect.Height - Y < MIN_SIZE then Y := spRect.Height - MIN_SIZE;

    spRect.Top := spRect.Top + Y;
    spRect.Height := spRect.Height - Y;
  end;
  //右部
  if FMousePosition in [mpTopRight, mpRight, mpBottomRight] then
  begin
    if X < MIN_SIZE then X := MIN_SIZE;
    if X > img.Width - sbImg.VertScrollBar.Position - spRect.Left then X := img.Width - sbImg.VertScrollBar.Position - spRect.Left;
    spRect.Width := X;
  end;
  //下部
  if FMousePosition in [mpBottomLeft, mpBottom, mpBottomRight] then
  begin
    if Y < MIN_SIZE then Y := MIN_SIZE;
    if Y > img.Height - sbImg.VertScrollBar.Position - spRect.Top then Y := img.Height - sbImg.VertScrollBar.Position - spRect.Top;
    spRect.Height := Y;
  end;
  //中间，移动
  if FMousePosition = mpMiddle then
  begin
    spRect.Left := spRect.Left + X - FOldX;
    spRect.Top := spRect.Top + Y - FOldY;
    if spRect.Left < - sbImg.HorzScrollBar.Position then spRect.Left := - sbImg.HorzScrollBar.Position;
    if spRect.Left > img.Width - sbImg.HorzScrollBar.Position - spRect.Width then spRect.Left := img.Width - sbImg.HorzScrollBar.Position - spRect.Width;
    if spRect.Top < - sbImg.VertScrollBar.Position then spRect.Top := - sbImg.VertScrollBar.Position;
    if spRect.Top > img.Height - sbImg.VertScrollBar.Position - spRect.Height then spRect.Top := img.Height - sbImg.VertScrollBar.Position - spRect.Height;

    //自动滚动
    if spRect.Left < 0 then sbImg.HorzScrollBar.Position := sbImg.HorzScrollBar.Position + spRect.Left;
    if spRect.Left > sbImg.Width - spRect.Width then sbImg.HorzScrollBar.Position := sbImg.HorzScrollBar.Position + spRect.Left - spRect.Width;
    if spRect.Top < 0 then sbImg.VertScrollBar.Position := sbImg.VertScrollBar.Position + spRect.Top;
    if spRect.Top > sbImg.Height - spRect.Height then sbImg.VertScrollBar.Position := sbImg.VertScrollBar.Position + spRect.Top - spRect.Height;
  end;

  //图片跟随移动
  SetImageInRect();
end;

procedure TfraHotspot.spRectMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FMousePosition := mpNone;
  if TForm(Parent.Parent.Parent).Active then sbImg.SetFocus;
end;

procedure TfraHotspot.sbImgCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
  if TForm(Parent.Parent.Parent).Active then sbImg.SetFocus;
end;

{ TShape }

procedure TShape.Paint;
begin
  inherited;

  //画8个边界小矩形
  with Canvas do
  begin
    Pen.Style := psSolid;
    Rectangle(0, 0, 4, 4);
    Rectangle(Round(Width / 2) - 2, 0, Round(Width / 2) + 2, 4);
    Rectangle(Width- 4, 0, Width, 4);
    Rectangle(0, Round(Height / 2) - 2, 4, Round(Height / 2) + 2);
    Rectangle(Width - 4, Round(Height / 2) - 2, Width, Round(Height / 2) + 2);
    Rectangle(0, Height - 4, 4, Height);
    Rectangle(Round(Width / 2) - 2, Height - 4, Round(Width / 2) + 2, Height);
    Rectangle(Width - 4, Height - 4, Width, Height);
  end;
end;

end.

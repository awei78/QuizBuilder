inherited frmChart: TfrmChart
  Left = 192
  Top = 177
  Caption = #35797#39064#20998#24067#22270#34920#32479#35745
  ClientHeight = 446
  ClientWidth = 632
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 12
  inherited bvl: TBevel
    Top = 410
    Width = 632
  end
  inherited imgHelp: TImage
    Top = 419
  end
  inherited btnOK: TBitBtn
    Left = 382
    Top = 418
  end
  inherited btnReset: TBitBtn
    Left = 463
    Top = 418
  end
  inherited btnCancel: TBitBtn
    Left = 544
    Top = 418
  end
  object chtQuiz: TChart
    Left = 0
    Top = 0
    Width = 632
    Height = 446
    AllowPanning = pmNone
    AllowZoom = False
    BackWall.Brush.Color = clWhite
    BackWall.Brush.Style = bsClear
    BackWall.Pen.Visible = False
    LeftWall.Brush.Color = clWhite
    Title.Text.Strings = (
      #39064#22411#20998#24067#32479#35745)
    AxisVisible = False
    ClipPoints = False
    Frame.Visible = False
    ScaleLastPage = False
    View3DOptions.Elevation = 315
    View3DOptions.Orthogonal = False
    View3DOptions.Perspective = 0
    View3DOptions.Rotation = 360
    View3DWalls = False
    Align = alClient
    TabOrder = 3
    object Series1: TPieSeries
      Marks.ArrowLength = 8
      Marks.Style = smsLabelPercent
      Marks.Visible = True
      SeriesColor = clRed
      Circled = True
      OtherSlice.Text = 'Other'
      PieValues.DateTime = False
      PieValues.Name = 'Pie'
      PieValues.Multiplier = 1.000000000000000000
      PieValues.Order = loNone
    end
  end
end

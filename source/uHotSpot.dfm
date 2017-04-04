object fraHotspot: TfraHotspot
  Left = 0
  Top = 0
  Width = 320
  Height = 240
  AutoSize = True
  TabOrder = 0
  object sbImg: TScrollBox
    Left = 0
    Top = 0
    Width = 320
    Height = 240
    TabOrder = 0
    OnCanResize = sbImgCanResize
    object img: TImage
      Left = 0
      Top = 0
      Width = 316
      Height = 236
      AutoSize = True
      OnClick = imgClick
      OnMouseDown = imgMouseDown
      OnMouseMove = imgMouseMove
      OnMouseUp = imgMouseUp
    end
    object imgHot: TImage
      Left = 224
      Top = 8
      Width = 80
      Height = 60
      Picture.Data = {
        0A54504E474F626A65637489504E470D0A1A0A0000000D494844520000005000
        00003C0806000000F1273D8C000000097048597300000B1300000B1301009A9C
        180000000467414D410000B18E7CFB51930000008D4944415478DAEDD0410100
        200C00A1AD99FD4B6907EF0B11D8997B866F2BB01118098C044602238191C048
        6024301218098C044602238191C0486024301218098C044602238191C0486024
        301218098C044602238191C0486024301218098C044602238191C04860243012
        18098C044602238191C0486024301218098C044602238191C048602430121809
        8C1E537C4B0103A98E200000000049454E44AE426082}
      Stretch = True
    end
    object spRect: TShape
      Left = 136
      Top = 8
      Width = 80
      Height = 60
      Cursor = crSizeAll
      Brush.Style = bsClear
      Pen.Color = clRed
      Pen.Style = psDot
      OnMouseDown = spRectMouseDown
      OnMouseMove = spRectMouseMove
      OnMouseUp = spRectMouseUp
    end
  end
end

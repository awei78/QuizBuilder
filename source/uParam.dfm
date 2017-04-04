inherited frmParam: TfrmParam
  Caption = #21442#25968#35774#32622
  ClientHeight = 307
  ClientWidth = 455
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 12
  inherited bvl: TBevel
    Top = 269
    Width = 455
  end
  inherited imgHelp: TImage
    Left = 20
    Top = 279
  end
  object Bevel7: TBevel [2]
    Left = 88
    Top = 18
    Width = 353
    Height = 1
    Shape = bsTopLine
  end
  object lblFont: TLabel [3]
    Left = 12
    Top = 12
    Width = 72
    Height = 12
    Caption = #35797#39064#23383#20307#35774#32622
    Font.Charset = ANSI_CHARSET
    Font.Color = 13977088
    Font.Height = -12
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
    Transparent = True
  end
  object lblSizeT: TLabel [4]
    Left = 146
    Top = 32
    Width = 36
    Height = 12
    Caption = #22823#23567#65306
  end
  object lblColorT: TLabel [5]
    Left = 250
    Top = 32
    Width = 36
    Height = 12
    Caption = #39068#33394#65306
  end
  object lblTopicF: TLabel [6]
    Left = 24
    Top = 32
    Width = 60
    Height = 12
    Caption = #39064#30446#23383#20307#65306
  end
  object lblSizeA: TLabel [7]
    Left = 146
    Top = 56
    Width = 36
    Height = 12
    Caption = #22823#23567#65306
  end
  object lblColorA: TLabel [8]
    Left = 250
    Top = 56
    Width = 36
    Height = 12
    Caption = #39068#33394#65306
  end
  object lblAnsF: TLabel [9]
    Left = 24
    Top = 56
    Width = 60
    Height = 12
    Caption = #31572#26696#23383#20307#65306
  end
  object Bevel1: TBevel [10]
    Left = 76
    Top = 86
    Width = 365
    Height = 1
    Shape = bsTopLine
  end
  object lblDefSet: TLabel [11]
    Left = 12
    Top = 80
    Width = 60
    Height = 12
    Caption = #40664#35748#20540#35774#32622
    Font.Charset = ANSI_CHARSET
    Font.Color = 13977088
    Font.Height = -12
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
    Transparent = True
  end
  object lblPoint: TLabel [12]
    Left = 24
    Top = 100
    Width = 60
    Height = 12
    Caption = #27599#39064#20998#25968#65306
  end
  object lblTimes: TLabel [13]
    Left = 169
    Top = 100
    Width = 60
    Height = 12
    Caption = #23581#35797#27425#25968#65306
  end
  object lblFeed: TLabel [14]
    Left = 24
    Top = 122
    Width = 48
    Height = 12
    Caption = #21453#39304#20449#24687
  end
  object lblCrt: TLabel [15]
    Left = 48
    Top = 142
    Width = 36
    Height = 12
    Caption = #27491#30830#65306
  end
  object Bevel2: TBevel [16]
    Left = 76
    Top = 128
    Width = 365
    Height = 1
    Shape = bsTopLine
  end
  object lblErr: TLabel [17]
    Left = 250
    Top = 142
    Width = 36
    Height = 12
    Caption = #38169#35823#65306
  end
  object lblLevel: TLabel [18]
    Left = 315
    Top = 100
    Width = 60
    Height = 12
    Caption = #38590#24230#32423#21035#65306
    Transparent = True
  end
  object Bevel3: TBevel [19]
    Left = 88
    Top = 215
    Width = 353
    Height = 1
    Shape = bsTopLine
  end
  object lblSet: TLabel [20]
    Left = 12
    Top = 209
    Width = 72
    Height = 12
    Caption = #20854#23427#21442#25968#35774#32622
    Font.Charset = ANSI_CHARSET
    Font.Color = 13977088
    Font.Height = -12
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
    Transparent = True
  end
  inherited btnOK: TBitBtn
    Left = 205
    Top = 278
    Caption = #30830#23450
    TabOrder = 19
  end
  inherited btnReset: TBitBtn
    Left = 286
    Top = 278
    Caption = #37325#32622'(&R)'
    TabOrder = 20
  end
  inherited btnCancel: TBitBtn
    Left = 367
    Top = 278
    Caption = #21462#28040
    TabOrder = 21
  end
  object edtSizeT: TEdit
    Left = 184
    Top = 28
    Width = 26
    Height = 20
    ReadOnly = True
    TabOrder = 0
    Text = '12'
  end
  object udT: TUpDown
    Left = 210
    Top = 28
    Width = 16
    Height = 20
    Associate = edtSizeT
    Min = 8
    Max = 24
    Position = 12
    TabOrder = 1
  end
  object cbTopic: TColorBox
    Left = 288
    Top = 28
    Width = 75
    Height = 20
    AutoDropDown = True
    Style = [cbStandardColors, cbIncludeDefault, cbCustomColor, cbPrettyNames]
    ItemHeight = 14
    TabOrder = 2
  end
  object edtSizeA: TEdit
    Left = 184
    Top = 52
    Width = 26
    Height = 20
    ReadOnly = True
    TabOrder = 4
    Text = '12'
  end
  object udA: TUpDown
    Left = 210
    Top = 52
    Width = 16
    Height = 20
    Associate = edtSizeA
    Min = 8
    Max = 24
    Position = 12
    TabOrder = 5
  end
  object cbAnswer: TColorBox
    Left = 288
    Top = 52
    Width = 75
    Height = 20
    AutoDropDown = True
    Style = [cbStandardColors, cbIncludeDefault, cbCustomColor, cbPrettyNames]
    ItemHeight = 14
    TabOrder = 6
  end
  object edtPoint: TEdit
    Left = 86
    Top = 96
    Width = 34
    Height = 20
    ReadOnly = True
    TabOrder = 8
    Text = '10'
  end
  object udPoint: TUpDown
    Left = 120
    Top = 96
    Width = 16
    Height = 20
    Associate = edtPoint
    Position = 10
    TabOrder = 9
  end
  object edtAttempts: TEdit
    Left = 231
    Top = 96
    Width = 34
    Height = 20
    ReadOnly = True
    TabOrder = 10
    Text = '1'
  end
  object udAttempts: TUpDown
    Left = 265
    Top = 96
    Width = 17
    Height = 20
    Associate = edtAttempts
    Min = 1
    Max = 9
    Position = 1
    TabOrder = 11
  end
  object meoCrt: TMemo
    Left = 86
    Top = 138
    Width = 139
    Height = 41
    Font.Charset = ANSI_CHARSET
    Font.Color = clGreen
    Font.Height = -12
    Font.Name = #23435#20307
    Font.Style = []
    Lines.Strings = (
      #24685#21916#24744#65292#31572#23545#20102)
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 13
  end
  object meoErr: TMemo
    Left = 288
    Top = 138
    Width = 139
    Height = 41
    Font.Charset = ANSI_CHARSET
    Font.Color = clRed
    Font.Height = -12
    Font.Name = #23435#20307
    Font.Style = []
    Lines.Strings = (
      #24744#31572#38169#20102)
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 14
  end
  object cbLevel: TComboBox
    Left = 377
    Top = 96
    Width = 50
    Height = 20
    Style = csDropDownList
    ItemHeight = 12
    ItemIndex = 2
    TabOrder = 12
    Text = #20013#32423
    Items.Strings = (
      #23481#26131
      #21021#32423
      #20013#32423
      #39640#32423
      #22256#38590)
  end
  object cbSplash: TCheckBox
    Left = 250
    Top = 223
    Width = 94
    Height = 17
    Caption = #26174#31034#21551#21160#31383#20307
    Checked = True
    State = cbChecked
    TabOrder = 17
  end
  object btnApplayAll: TBitBtn
    Left = 86
    Top = 182
    Width = 99
    Height = 20
    Cursor = crHandPoint
    Caption = #24212#29992#21040#25152#26377#35797#39064
    TabOrder = 15
    OnClick = btnApplayAllClick
  end
  object cbBoldT: TCheckBox
    Left = 387
    Top = 30
    Width = 46
    Height = 17
    Caption = #31895#20307
    TabOrder = 3
  end
  object cbBoldA: TCheckBox
    Left = 387
    Top = 54
    Width = 46
    Height = 17
    Caption = #31895#20307
    TabOrder = 7
  end
  object cbShowIcon: TCheckBox
    Left = 24
    Top = 223
    Width = 142
    Height = 17
    Caption = #35797#39064#21015#34920#26174#31034#39064#22411#22270#26631
    Checked = True
    State = cbChecked
    TabOrder = 16
  end
  object cbSetAudio: TCheckBox
    Left = 24
    Top = 242
    Width = 166
    Height = 17
    Caption = #35797#39064#31383#20307#20801#35768#35774#32622#35797#39064#22768#38899
    TabOrder = 18
  end
end

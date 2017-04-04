inherited frmProp: TfrmProp
  Left = 264
  Top = 194
  Caption = #35797#39064#23646#24615
  ClientHeight = 329
  ClientWidth = 480
  OldCreateOrder = True
  OnClose = FormClose
  OnShow = FormShow
  DesignSize = (
    480
    329)
  PixelsPerInch = 96
  TextHeight = 12
  inherited bvl: TBevel
    Top = 291
    Width = 480
  end
  inherited imgHelp: TImage
    Top = 301
  end
  inherited btnReset: TBitBtn [2]
    Left = 312
    Top = 300
    Caption = #37325#32622'(&R)'
    TabOrder = 2
  end
  inherited btnOK: TBitBtn [3]
    Left = 231
    Top = 300
    Caption = #30830#23450
    TabOrder = 1
  end
  inherited btnCancel: TBitBtn
    Left = 393
    Top = 300
    Caption = #21462#28040
    TabOrder = 3
  end
  object pcProp: TPageControl
    Left = 8
    Top = 8
    Width = 466
    Height = 277
    ActivePage = tsInfo
    TabOrder = 0
    OnChange = pcPropChange
    object tsInfo: TTabSheet
      Caption = #35797#39064#20449#24687
      object lblTopic: TLabel
        Left = 20
        Top = 24
        Width = 36
        Height = 12
        Caption = #20027#39064#65306
      end
      object lblId: TLabel
        Left = 318
        Top = 24
        Width = 36
        Height = 12
        Caption = #32534#21495#65306
      end
      object Bevel1: TBevel
        Left = 103
        Top = 54
        Width = 344
        Height = 1
        Shape = bsTopLine
      end
      object lblInfo: TLabel
        Left = 20
        Top = 67
        Width = 36
        Height = 12
        Caption = #31616#20171#65306
      end
      object lblImg: TLabel
        Left = 20
        Top = 152
        Width = 36
        Height = 12
        Caption = #22270#29255#65306
      end
      object btnAdd: TSpeedButton
        Left = 186
        Top = 151
        Width = 19
        Height = 19
        Cursor = crHandPoint
        Hint = #21152#20837#22270#29255
        Glyph.Data = {
          76010000424D7601000000000000760000002800000020000000100000000100
          04000000000000010000120B0000120B00001000000000000000000000000000
          8000008000000080800080000000800080008080000080808000C0C0C0000000
          FF00C0C0C00000FFFF00FF000000C0C0C000FFFF0000FFFFFF00555555555555
          5555555555555555555555555555555555555555555555555555555555555555
          5555555555555555555555555544455555555555557775555555555555424555
          5555555555787555555555555542455555555555557875555555555555424555
          5555555555787555555555444442444445555577777877777555554222222222
          4555557888888888755555444442444445555577777877777555555555424555
          5555555555787555555555555542455555555555557875555555555555424555
          5555555555787555555555555544455555555555557775555555555555555555
          5555555555555555555555555555555555555555555555555555}
        NumGlyphs = 2
        OnClick = btnAddClick
      end
      object btnDel: TSpeedButton
        Left = 186
        Top = 175
        Width = 19
        Height = 19
        Cursor = crHandPoint
        Hint = #28165#31354#22270#29255
        Glyph.Data = {
          76010000424D7601000000000000760000002800000020000000100000000100
          04000000000000010000120B0000120B00001000000000000000000000000000
          8000008000000080800080000000800080008080000080808000C0C0C0000000
          FF00C0C0C00000FFFF00FF000000C0C0C000FFFF0000FFFFFF00555555555555
          5555555555555555555555555555555555555555555555555555555555555555
          5555555555555555555555555555555555555555555555555555555555555555
          5555555555555555555555555555555555555555555555555555555555555555
          5555555555555555555555444444444445555577777777777555554222222222
          4555557888888888755555444444444445555577777777777555555555555555
          5555555555555555555555555555555555555555555555555555555555555555
          5555555555555555555555555555555555555555555555555555555555555555
          5555555555555555555555555555555555555555555555555555}
        NumGlyphs = 2
        OnClick = btnDelClick
      end
      object lblUser: TLabel
        Left = 258
        Top = 152
        Width = 96
        Height = 12
        Caption = #27979#35797#32773#20449#24687#35774#32622#65306
      end
      object Bevel2: TBevel
        Left = 356
        Top = 189
        Width = 91
        Height = 1
        Shape = bsTopLine
      end
      object lblTitle: TLabel
        Left = 8
        Top = 4
        Width = 60
        Height = 12
        Caption = #20027#39064#19982#32534#21495
        Font.Charset = ANSI_CHARSET
        Font.Color = 13977088
        Font.Height = -12
        Font.Name = #23435#20307
        Font.Style = []
        ParentFont = False
        Transparent = True
      end
      object Bevel11: TBevel
        Left = 73
        Top = 10
        Width = 374
        Height = 1
        Shape = bsTopLine
      end
      object edtTopic: TEdit
        Left = 58
        Top = 20
        Width = 243
        Height = 20
        TabOrder = 0
      end
      object edtId: TEdit
        Left = 356
        Top = 20
        Width = 82
        Height = 20
        TabOrder = 1
      end
      object cbInfo: TRzCheckBox
        Left = 8
        Top = 46
        Width = 94
        Height = 17
        AlignmentVertical = avBottom
        Caption = #26174#31034#31616#20171#39029#38754
        Checked = True
        Font.Charset = ANSI_CHARSET
        Font.Color = 13977088
        Font.Height = -12
        Font.Name = #23435#20307
        Font.Style = []
        ParentFont = False
        State = cbChecked
        TabOrder = 2
        OnClick = cbInfoClick
      end
      object meoInfo: TMemo
        Left = 58
        Top = 64
        Width = 380
        Height = 83
        ScrollBars = ssVertical
        TabOrder = 3
      end
      object pnlImg: TPanel
        Left = 57
        Top = 151
        Width = 123
        Height = 92
        BevelInner = bvLowered
        Caption = #27809#26377#22270#29255
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -16
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold, fsItalic]
        ParentFont = False
        TabOrder = 4
        object imgQuiz: TImage
          Left = 1
          Top = 1
          Width = 122
          Height = 91
          Center = True
          Proportional = True
          Stretch = True
          OnDblClick = imgQuizDblClick
        end
      end
      object cbName: TCheckBox
        Left = 356
        Top = 149
        Width = 70
        Height = 17
        Caption = #26174#31034#24080#21495
        Checked = True
        State = cbChecked
        TabOrder = 5
        OnClick = cbNameClick
      end
      object cbMail: TCheckBox
        Left = 356
        Top = 168
        Width = 70
        Height = 17
        Caption = #26174#31034#37038#20214
        Checked = True
        State = cbChecked
        TabOrder = 6
      end
      object cbBlankName: TCheckBox
        Left = 356
        Top = 194
        Width = 82
        Height = 17
        Caption = #20801#35768#31354#24080#21495
        Checked = True
        State = cbChecked
        TabOrder = 7
      end
    end
    object tsSet: TTabSheet
      Caption = #35797#39064#35774#32622
      ImageIndex = 2
      object Bevel7: TBevel
        Left = 85
        Top = 10
        Width = 362
        Height = 1
        Shape = bsTopLine
      end
      object lblAnsMode: TLabel
        Left = 8
        Top = 4
        Width = 72
        Height = 12
        Caption = #31572#26696#25552#20132#27169#24335
        Font.Charset = ANSI_CHARSET
        Font.Color = 13977088
        Font.Height = -12
        Font.Name = #23435#20307
        Font.Style = []
        ParentFont = False
        Transparent = True
      end
      object lblPassTime: TLabel
        Left = 8
        Top = 41
        Width = 72
        Height = 12
        Caption = #36890#36807#29575#19982#26102#38480
        Font.Charset = ANSI_CHARSET
        Font.Color = 13977088
        Font.Height = -12
        Font.Name = #23435#20307
        Font.Style = []
        ParentFont = False
        Transparent = True
      end
      object Bevel8: TBevel
        Left = 85
        Top = 47
        Width = 362
        Height = 1
        Shape = bsTopLine
      end
      object lblPassSet: TLabel
        Left = 20
        Top = 61
        Width = 72
        Height = 12
        Caption = #36890#36807#29575#35774#32622#65306
      end
      object lblPer: TLabel
        Left = 148
        Top = 61
        Width = 6
        Height = 12
        Caption = '%'
      end
      object lblMinute: TLabel
        Left = 332
        Top = 61
        Width = 12
        Height = 12
        Caption = #20998
      end
      object lblSec: TLabel
        Left = 380
        Top = 61
        Width = 12
        Height = 12
        Caption = #31186
      end
      object lblOthers: TLabel
        Left = 8
        Top = 146
        Width = 48
        Height = 12
        Caption = #20854#23427#35774#32622
        Font.Charset = ANSI_CHARSET
        Font.Color = 13977088
        Font.Height = -12
        Font.Name = #23435#20307
        Font.Style = []
        ParentFont = False
        Transparent = True
      end
      object Bevel10: TBevel
        Left = 61
        Top = 152
        Width = 386
        Height = 1
        Shape = bsTopLine
      end
      object Bevel12: TBevel
        Left = 79
        Top = 91
        Width = 368
        Height = 1
        Shape = bsTopLine
      end
      object pnlAns: TPanel
        Left = 20
        Top = 18
        Width = 285
        Height = 17
        AutoSize = True
        BevelOuter = bvNone
        TabOrder = 0
        object rbOne: TRadioButton
          Left = 0
          Top = 0
          Width = 105
          Height = 17
          Caption = #19968#27425#25552#20132#19968#39064
          Checked = True
          TabOrder = 0
          TabStop = True
        end
        object rbAll: TRadioButton
          Left = 204
          Top = 0
          Width = 81
          Height = 17
          Caption = #20840#37096#25552#20132
          TabOrder = 1
        end
      end
      object edtPass: TEdit
        Left = 94
        Top = 57
        Width = 34
        Height = 20
        ReadOnly = True
        TabOrder = 1
        Text = '60'
      end
      object udPassRate: TUpDown
        Left = 128
        Top = 57
        Width = 16
        Height = 20
        Associate = edtPass
        Position = 60
        TabOrder = 2
      end
      object cbTime: TCheckBox
        Left = 224
        Top = 59
        Width = 77
        Height = 17
        Caption = #31572#39064#26102#38480#65306
        Checked = True
        State = cbChecked
        TabOrder = 3
        OnClick = cbTimeClick
      end
      object edtMinute: TEdit
        Left = 302
        Top = 57
        Width = 26
        Height = 20
        MaxLength = 3
        TabOrder = 4
        Text = '5'
        OnKeyPress = EditKeyPress
      end
      object edtSecond: TEdit
        Left = 350
        Top = 57
        Width = 26
        Height = 20
        MaxLength = 2
        TabOrder = 5
        Text = '0'
        OnKeyPress = EditKeyPress
      end
      object cbRndAns: TCheckBox
        Left = 224
        Top = 160
        Width = 94
        Height = 17
        Caption = #31572#26696#38543#26426#25490#21015
        Checked = True
        State = cbChecked
        TabOrder = 9
      end
      object cbRndQues: TRzCheckBox
        Left = 8
        Top = 83
        Width = 70
        Height = 17
        AlignmentVertical = avBottom
        Caption = #38543#26426#25277#39064
        Font.Charset = ANSI_CHARSET
        Font.Color = 13977088
        Font.Height = -12
        Font.Name = #23435#20307
        Font.Style = []
        ParentFont = False
        State = cbUnchecked
        TabOrder = 6
        OnClick = cbRndQuesClick
      end
      object cbShowAns: TCheckBox
        Left = 20
        Top = 179
        Width = 130
        Height = 17
        Caption = #31572#39064#21518#26174#31034#27491#30830#31572#26696
        Checked = True
        State = cbChecked
        TabOrder = 10
      end
      object cbView: TCheckBox
        Left = 224
        Top = 179
        Width = 130
        Height = 17
        Caption = #20570#23436#21518#20801#35768#27983#35272#35797#39064
        Checked = True
        State = cbChecked
        TabOrder = 11
      end
      object pnlRnd: TPanel
        Left = 16
        Top = 101
        Width = 354
        Height = 39
        AutoSize = True
        BevelOuter = bvNone
        TabOrder = 7
        object cbQuesCount: TComboBox
          Left = 90
          Top = 0
          Width = 49
          Height = 20
          Style = csDropDownList
          ItemHeight = 12
          ItemIndex = 0
          TabOrder = 1
          Text = #20840#37096
          Items.Strings = (
            #20840#37096)
        end
        object cbRunRnd: TCheckBox
          Left = 0
          Top = 22
          Width = 82
          Height = 17
          Caption = #36816#34892#26102#38543#26426
          TabOrder = 4
          OnClick = cbRndQuesClick
        end
        object rbQuiz: TRadioButton
          Left = 0
          Top = 2
          Width = 88
          Height = 17
          Caption = #25353#35797#39064#25277#39064#65306
          Checked = True
          TabOrder = 0
          TabStop = True
          OnClick = rbQuizClick
        end
        object rbType: TRadioButton
          Left = 208
          Top = 2
          Width = 88
          Height = 17
          Caption = #25353#39064#22411#25277#39064#65306
          TabOrder = 2
          OnClick = rbTypeClick
        end
        object btnSet: TButton
          Left = 297
          Top = 0
          Width = 57
          Height = 20
          Caption = #35774#32622'...'
          TabOrder = 3
          OnClick = btnSetClick
        end
      end
      object cbQuesNo: TCheckBox
        Left = 20
        Top = 160
        Width = 94
        Height = 17
        Caption = #26174#31034#35797#39064#32534#21495
        Checked = True
        State = cbChecked
        TabOrder = 8
      end
    end
    object tsResult: TTabSheet
      Caption = #32467#26524#35774#32622
      ImageIndex = 1
      object Bevel3: TBevel
        Left = 175
        Top = 12
        Width = 272
        Height = 1
        Shape = bsTopLine
      end
      object lblPass: TLabel
        Left = 20
        Top = 24
        Width = 36
        Height = 12
        Caption = #36890#36807#65306
      end
      object lblFail: TLabel
        Left = 241
        Top = 24
        Width = 36
        Height = 12
        Caption = #22833#36133#65306
      end
      object Bevel4: TBevel
        Left = 127
        Top = 77
        Width = 320
        Height = 1
        Shape = bsTopLine
      end
      object lblUrl: TLabel
        Left = 20
        Top = 91
        Width = 36
        Height = 12
        Caption = #32593#22336#65306
      end
      object Bevel5: TBevel
        Left = 115
        Top = 121
        Width = 332
        Height = 1
        Shape = bsTopLine
      end
      object lblMail: TLabel
        Left = 20
        Top = 135
        Width = 60
        Height = 12
        Caption = #37038#20214#22320#22336#65306
      end
      object lblMailUrl: TLabel
        Left = 20
        Top = 159
        Width = 60
        Height = 12
        Caption = #36716#21457#32593#22336#65306
      end
      object Bevel6: TBevel
        Left = 109
        Top = 189
        Width = 338
        Height = 1
        Shape = bsTopLine
      end
      object lblFilnish: TLabel
        Left = 8
        Top = 183
        Width = 96
        Height = 12
        Caption = #27979#35797#32467#26463#21518#30340#25805#20316
        Font.Charset = ANSI_CHARSET
        Font.Color = 13977088
        Font.Height = -12
        Font.Name = #23435#20307
        Font.Style = []
        ParentFont = False
        Transparent = True
      end
      object lblOnPass: TLabel
        Left = 20
        Top = 203
        Width = 36
        Height = 12
        Caption = #36890#36807#65306
      end
      object lblOnFail: TLabel
        Left = 20
        Top = 227
        Width = 36
        Height = 12
        Caption = #22833#36133#65306
      end
      object cbShow: TRzCheckBox
        Left = 8
        Top = 4
        Width = 166
        Height = 17
        AlignmentVertical = avBottom
        Caption = #26174#31034#20998#25968#21450#36890#36807#12289#22833#36133#20449#24687
        Checked = True
        Font.Charset = ANSI_CHARSET
        Font.Color = 13977088
        Font.Height = -12
        Font.Name = #23435#20307
        Font.Style = []
        ParentFont = False
        State = cbChecked
        TabOrder = 0
        OnClick = cbShowClick
      end
      object meoPass: TMemo
        Left = 58
        Top = 22
        Width = 163
        Height = 41
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGreen
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        Lines.Strings = (
          #24685#21916#65292#24744#36890#36807#20102)
        ParentFont = False
        ScrollBars = ssVertical
        TabOrder = 1
      end
      object meoFail: TMemo
        Left = 275
        Top = 22
        Width = 163
        Height = 41
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        Lines.Strings = (
          #24744#27809#26377#36890#36807)
        ParentFont = False
        ScrollBars = ssVertical
        TabOrder = 2
      end
      object cbPostWeb: TRzCheckBox
        Left = 8
        Top = 69
        Width = 118
        Height = 17
        AlignmentVertical = avBottom
        Caption = #21457#36865#21040#32593#32476#25968#25454#24211
        Checked = True
        Font.Charset = ANSI_CHARSET
        Font.Color = 13977088
        Font.Height = -12
        Font.Name = #23435#20307
        Font.Style = []
        ParentFont = False
        State = cbChecked
        TabOrder = 3
        OnClick = cbPostWebClick
      end
      object edtUrl: TEdit
        Left = 58
        Top = 87
        Width = 247
        Height = 20
        TabOrder = 4
        Text = 'http://www.ausoft.net/quiz/get.asp'
      end
      object pnlWeb: TPanel
        Left = 311
        Top = 86
        Width = 120
        Height = 21
        BevelInner = bvLowered
        TabOrder = 5
        object rbWebM: TRadioButton
          Left = 8
          Top = 3
          Width = 49
          Height = 17
          Caption = #25163#21160
          Checked = True
          TabOrder = 0
          TabStop = True
        end
        object rbWebA: TRadioButton
          Left = 64
          Top = 3
          Width = 49
          Height = 17
          Caption = #33258#21160
          TabOrder = 1
        end
      end
      object cbPostMail: TRzCheckBox
        Left = 8
        Top = 113
        Width = 106
        Height = 17
        AlignmentVertical = avBottom
        Caption = #21457#36865#21040#30005#23376#37038#20214
        Font.Charset = ANSI_CHARSET
        Font.Color = 13977088
        Font.Height = -12
        Font.Name = #23435#20307
        Font.Style = []
        ParentFont = False
        State = cbUnchecked
        TabOrder = 6
        OnClick = cbPostMailClick
      end
      object edtMail: TEdit
        Left = 82
        Top = 131
        Width = 223
        Height = 20
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = #23435#20307
        Font.Style = []
        ParentFont = False
        TabOrder = 7
        Text = '@'
      end
      object pnlMail: TPanel
        Left = 311
        Top = 130
        Width = 120
        Height = 21
        BevelInner = bvLowered
        TabOrder = 8
        object rbMailM: TRadioButton
          Left = 8
          Top = 3
          Width = 49
          Height = 17
          Caption = #25163#21160
          Checked = True
          TabOrder = 0
          TabStop = True
        end
        object rbMailA: TRadioButton
          Left = 64
          Top = 3
          Width = 49
          Height = 17
          Caption = #33258#21160
          TabOrder = 1
        end
      end
      object edtMailUrl: TEdit
        Left = 82
        Top = 155
        Width = 350
        Height = 20
        TabOrder = 9
        Text = 'http://www.ausoft.net/quiz/mail.asp'
      end
      object cbPass: TComboBox
        Left = 58
        Top = 199
        Width = 73
        Height = 20
        Style = csDropDownList
        ItemHeight = 12
        ItemIndex = 0
        TabOrder = 10
        Text = #20851#38381
        OnChange = cbPassChange
        Items.Strings = (
          #20851#38381
          #36339#21040#39029#38754)
      end
      object cbFail: TComboBox
        Left = 58
        Top = 223
        Width = 73
        Height = 20
        Style = csDropDownList
        ItemHeight = 12
        ItemIndex = 0
        TabOrder = 11
        Text = #20851#38381
        OnChange = cbFailChange
        Items.Strings = (
          #20851#38381
          #36339#21040#39029#38754)
      end
      object edtPUrl: TEdit
        Left = 136
        Top = 199
        Width = 302
        Height = 20
        TabOrder = 12
        Text = 'http://'
      end
      object edtFUrl: TEdit
        Left = 136
        Top = 223
        Width = 302
        Height = 20
        TabOrder = 13
        Text = 'http://'
      end
    end
    object tsProtect: TTabSheet
      Caption = #35797#39064#20445#25252
      ImageIndex = 3
      object Bevel9: TBevel
        Left = 79
        Top = 12
        Width = 368
        Height = 1
        Shape = bsTopLine
      end
      object Bevel13: TBevel
        Left = 79
        Top = 97
        Width = 368
        Height = 1
        Shape = bsTopLine
      end
      object lblLimitUrl: TLabel
        Left = 20
        Top = 111
        Width = 60
        Height = 12
        Caption = #38480#21046#32593#22336#65306
      end
      object Bevel14: TBevel
        Left = 79
        Top = 141
        Width = 368
        Height = 1
        Shape = bsTopLine
      end
      object lblStart: TLabel
        Left = 20
        Top = 155
        Width = 60
        Height = 12
        Caption = #24320#22987#26085#26399#65306
      end
      object lblEnd: TLabel
        Left = 224
        Top = 155
        Width = 60
        Height = 12
        Caption = #32467#26463#26085#26399#65306
      end
      object cbPwd: TRzCheckBox
        Left = 8
        Top = 4
        Width = 70
        Height = 17
        AlignmentVertical = avBottom
        Caption = #23494#30721#20445#25252
        Font.Charset = ANSI_CHARSET
        Font.Color = 13977088
        Font.Height = -12
        Font.Name = #23435#20307
        Font.Style = []
        ParentFont = False
        State = cbUnchecked
        TabOrder = 0
        OnClick = cbPwdClick
      end
      object pnlPwd: TPanel
        Left = 20
        Top = 22
        Width = 418
        Height = 63
        AutoSize = True
        BevelOuter = bvNone
        TabOrder = 1
        object rbPwd: TRadioButton
          Left = 0
          Top = 2
          Width = 77
          Height = 17
          Caption = #23494#30721#39564#35777#65306
          Checked = True
          TabOrder = 0
          TabStop = True
          OnClick = rbPwdClick
        end
        object rbWeb: TRadioButton
          Left = 0
          Top = 26
          Width = 77
          Height = 17
          Caption = #32593#39029#39564#35777#65306
          TabOrder = 2
          OnClick = rbWebClick
        end
        object edtPwd: TEdit
          Left = 78
          Top = 0
          Width = 81
          Height = 20
          TabOrder = 1
        end
        object edtWeb: TEdit
          Left = 78
          Top = 24
          Width = 340
          Height = 20
          TabOrder = 3
          Text = 'http://'
        end
        object cbAllow: TRzCheckBox
          Left = 16
          Top = 46
          Width = 190
          Height = 17
          AlignmentVertical = avBottom
          Caption = #20801#35768#27979#35797#32773#25913#21464#20256#20837#30340#29992#25143#36134#21495
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = #23435#20307
          Font.Style = []
          ParentFont = False
          State = cbUnchecked
          TabOrder = 4
        end
      end
      object cbWebLimit: TRzCheckBox
        Left = 8
        Top = 89
        Width = 70
        Height = 17
        AlignmentVertical = avBottom
        Caption = #32593#39029#38480#21046
        Font.Charset = ANSI_CHARSET
        Font.Color = 13977088
        Font.Height = -12
        Font.Name = #23435#20307
        Font.Style = []
        ParentFont = False
        State = cbUnchecked
        TabOrder = 2
        OnClick = cbWebLimitClick
      end
      object edtLimitUrl: TEdit
        Left = 82
        Top = 107
        Width = 356
        Height = 20
        TabOrder = 3
        Text = 'http://'
      end
      object cbTerm: TRzCheckBox
        Left = 8
        Top = 133
        Width = 70
        Height = 17
        AlignmentVertical = avBottom
        Caption = #26377#25928#26102#26399
        Font.Charset = ANSI_CHARSET
        Font.Color = 13977088
        Font.Height = -12
        Font.Name = #23435#20307
        Font.Style = []
        ParentFont = False
        State = cbUnchecked
        TabOrder = 4
        OnClick = cbTermClick
      end
      object dtStart: TDateTimePicker
        Left = 82
        Top = 151
        Width = 97
        Height = 20
        Date = 39402.879228877320000000
        Time = 39402.879228877320000000
        TabOrder = 5
        OnCloseUp = dtStartCloseUp
        OnChange = dtStartChange
      end
      object dtEnd: TDateTimePicker
        Left = 286
        Top = 151
        Width = 97
        Height = 20
        Date = 39402.879228877320000000
        Time = 39402.879228877320000000
        TabOrder = 6
        OnCloseUp = dtEndCloseUp
        OnChange = dtEndChange
      end
    end
  end
  object odQuiz: TOpenDialog
    Filter = 
      'All (*.jpg;*.jpeg;*.bmp;*.png;*.gif;*.emf;*.wmf)|*.jpg;*.jpeg;*.' +
      'bmp;*.png;*.gif;*.emf;*.wmf;*swf|JPEG Image File (*.jpg;*jpeg)|*' +
      '.jpg;*jpeg|Bitmaps (*.bmp)|*.bmp|GIF Image (*.gif)|*.gif|Portabl' +
      'e Network Graphics (*.png)|*.png|Enhanced Metafiles (*.emf)|*.em' +
      'f|Metafiles (*.wmf)|*.wmf|Flash Movie (*.swf)|*.swf'
    Left = 196
    Top = 239
  end
end

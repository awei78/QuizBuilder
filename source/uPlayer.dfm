inherited frmPlayer: TfrmPlayer
  Caption = #25773#25918#22120#35774#32622
  ClientHeight = 329
  ClientWidth = 487
  OldCreateOrder = True
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 12
  inherited bvl: TBevel
    Top = 293
    Width = 487
  end
  inherited imgHelp: TImage
    Top = 302
  end
  inherited btnOK: TBitBtn
    Left = 237
    Top = 301
    Caption = #30830#23450
    TabOrder = 1
  end
  inherited btnReset: TBitBtn
    Left = 318
    Top = 301
    Caption = #37325#32622'(&R)'
    TabOrder = 2
  end
  inherited btnCancel: TBitBtn
    Left = 399
    Top = 301
    Caption = #21462#28040
    TabOrder = 3
  end
  object pcPlayer: TPageControl
    Left = 8
    Top = 8
    Width = 473
    Height = 277
    ActivePage = tsPlayer
    TabOrder = 0
    OnChange = pcPlayerChange
    object tsPlayer: TTabSheet
      Caption = #25773#25918#22120#35774#32622
      object sf: TShockwaveFlash
        Left = 134
        Top = 4
        Width = 320
        Height = 240
        TabOrder = 0
        ControlData = {
          675566550009000013210000CE18000008000200000000000800040000002000
          00000800040000002000000008000E000000570069006E0064006F0077000000
          0800060000002D00310000000800060000002D003100000008000A0000004800
          690067006800000008000200000000000800060000002D003100000008000000
          00000800020000000000080010000000530068006F00770041006C006C000000
          0800040000003000000008000400000030000000080002000000000008000000
          000008000200000000000D000000000000000000000000000000000008000400
          0000310000000800040000003000000008000000000008000400000030000000
          08000800000061006C006C00000008000C000000660061006C00730065000000}
      end
      object cbTopic: TCheckBox
        Left = 8
        Top = 4
        Width = 81
        Height = 17
        Caption = #20027#39064#21306
        Checked = True
        State = cbChecked
        TabOrder = 1
        OnClick = CheckBoxClick
      end
      object cbTitle: TCheckBox
        Tag = 1
        Left = 24
        Top = 21
        Width = 81
        Height = 17
        Caption = #27979#39564#26631#39064
        Checked = True
        State = cbChecked
        TabOrder = 2
        OnClick = CheckBoxClick
      end
      object cbTime: TCheckBox
        Tag = 2
        Left = 24
        Top = 38
        Width = 81
        Height = 17
        Caption = #20570#39064#26102#38388
        Checked = True
        State = cbChecked
        TabOrder = 3
        OnClick = CheckBoxClick
      end
      object cbPoint: TCheckBox
        Tag = 4
        Left = 24
        Top = 72
        Width = 81
        Height = 17
        Caption = #20998#25968
        Checked = True
        State = cbChecked
        TabOrder = 5
        OnClick = CheckBoxClick
      end
      object cbLevel: TCheckBox
        Tag = 5
        Left = 24
        Top = 89
        Width = 81
        Height = 17
        Caption = #32423#21035
        Checked = True
        State = cbChecked
        TabOrder = 6
        OnClick = CheckBoxClick
      end
      object cbTools: TCheckBox
        Tag = 6
        Left = 24
        Top = 106
        Width = 81
        Height = 17
        Caption = #24037#20855#26465
        Checked = True
        State = cbChecked
        TabOrder = 7
        OnClick = CheckBoxClick
      end
      object cbData: TCheckBox
        Tag = 7
        Left = 40
        Top = 123
        Width = 81
        Height = 17
        Caption = #25968#25454#21457#36865
        Checked = True
        State = cbChecked
        TabOrder = 8
        OnClick = CheckBoxClick
      end
      object cbMail: TCheckBox
        Tag = 8
        Left = 40
        Top = 140
        Width = 81
        Height = 17
        Caption = #37038#20214#21457#36865
        Checked = True
        State = cbChecked
        TabOrder = 9
        OnClick = CheckBoxClick
      end
      object cbAudio: TCheckBox
        Tag = 9
        Left = 40
        Top = 157
        Width = 81
        Height = 17
        Caption = #22768#38899#25511#21046
        Checked = True
        State = cbChecked
        TabOrder = 10
        OnClick = CheckBoxClick
      end
      object cbInfo: TCheckBox
        Tag = 10
        Left = 40
        Top = 174
        Width = 81
        Height = 17
        Caption = #20316#32773#20449#24687
        Checked = True
        State = cbChecked
        TabOrder = 11
        OnClick = CheckBoxClick
      end
      object cbPrev: TCheckBox
        Tag = 11
        Left = 8
        Top = 191
        Width = 81
        Height = 17
        Caption = #19978#39064
        Checked = True
        State = cbChecked
        TabOrder = 12
        OnClick = CheckBoxClick
      end
      object cbNext: TCheckBox
        Tag = 12
        Left = 8
        Top = 208
        Width = 81
        Height = 17
        Caption = #19979#39064
        Checked = True
        State = cbChecked
        TabOrder = 13
        OnClick = CheckBoxClick
      end
      object cbList: TCheckBox
        Tag = 13
        Left = 8
        Top = 225
        Width = 81
        Height = 17
        Caption = #39064#30446#21015#34920
        Checked = True
        State = cbChecked
        TabOrder = 14
        OnClick = CheckBoxClick
      end
      object cbType: TCheckBox
        Tag = 3
        Left = 24
        Top = 55
        Width = 81
        Height = 17
        Caption = #39064#22411
        TabOrder = 4
        OnClick = CheckBoxClick
      end
    end
    object tsColor: TTabSheet
      Caption = #39068#33394#35774#32622
      ImageIndex = 3
      object lblBack: TLabel
        Left = 8
        Top = 8
        Width = 48
        Height = 12
        Caption = #32972'  '#26223#65306
      end
      object lblBarClr: TLabel
        Left = 8
        Top = 54
        Width = 48
        Height = 12
        Caption = #20449#24687#26465#65306
      end
      object lblCrt: TLabel
        Left = 8
        Top = 77
        Width = 48
        Height = 12
        Caption = #31572'  '#23545#65306
      end
      object lblErr: TLabel
        Left = 8
        Top = 100
        Width = 48
        Height = 12
        Caption = #31572'  '#38169#65306
      end
      object lblTopic: TLabel
        Left = 8
        Top = 31
        Width = 48
        Height = 12
        Caption = #20027'  '#39064#65306
      end
      object btnAddImg: TSpeedButton
        Left = 83
        Top = 119
        Width = 17
        Height = 17
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
        OnClick = btnAddImgClick
      end
      object btnDelImg: TSpeedButton
        Left = 104
        Top = 119
        Width = 17
        Height = 17
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
        OnClick = btnDelImgClick
      end
      object lblAlpha: TLabel
        Left = 8
        Top = 228
        Width = 72
        Height = 12
        Caption = #22270#29255#36879#26126#24230#65306
      end
      object cbBack: TColorBox
        Left = 58
        Top = 4
        Width = 65
        Height = 20
        AutoDropDown = True
        Style = [cbStandardColors, cbIncludeDefault, cbCustomColor, cbPrettyNames]
        ItemHeight = 14
        TabOrder = 0
        OnChange = ColorBoxChange
      end
      object cbBar: TColorBox
        Left = 58
        Top = 50
        Width = 65
        Height = 20
        AutoDropDown = True
        Style = [cbStandardColors, cbIncludeDefault, cbCustomColor, cbPrettyNames]
        ItemHeight = 14
        TabOrder = 2
        OnChange = ColorBoxChange
      end
      object cbCrt: TColorBox
        Left = 58
        Top = 73
        Width = 65
        Height = 20
        AutoDropDown = True
        Style = [cbStandardColors, cbIncludeDefault, cbCustomColor, cbPrettyNames]
        ItemHeight = 14
        TabOrder = 3
        OnChange = ColorBoxChange
      end
      object cbErr: TColorBox
        Left = 58
        Top = 96
        Width = 65
        Height = 20
        AutoDropDown = True
        Style = [cbStandardColors, cbIncludeDefault, cbCustomColor, cbPrettyNames]
        ItemHeight = 14
        TabOrder = 4
        OnChange = ColorBoxChange
      end
      object cbTopicClr: TColorBox
        Left = 58
        Top = 27
        Width = 65
        Height = 20
        AutoDropDown = True
        Style = [cbStandardColors, cbIncludeDefault, cbCustomColor, cbPrettyNames]
        ItemHeight = 14
        TabOrder = 1
        OnChange = ColorBoxChange
      end
      object cbImage: TRzCheckBox
        Left = 8
        Top = 120
        Width = 69
        Height = 16
        AlignmentVertical = avBottom
        Caption = #32972#26223#22270#29255
        Checked = True
        Font.Charset = ANSI_CHARSET
        Font.Color = 13977088
        Font.Height = -12
        Font.Name = #23435#20307
        Font.Style = []
        ParentFont = False
        State = cbChecked
        TabOrder = 5
        OnClick = cbImageClick
      end
      object pnlImg: TPanel
        Left = 8
        Top = 137
        Width = 114
        Height = 85
        BevelInner = bvLowered
        Caption = #27809#26377#22270#29255
        Ctl3D = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -17
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold, fsItalic]
        ParentCtl3D = False
        ParentFont = False
        TabOrder = 6
        object imgBack: TImage
          Left = 1
          Top = 1
          Width = 113
          Height = 84
          Center = True
          Proportional = True
          Stretch = True
          OnDblClick = imgBackDblClick
        end
      end
      object seAlpha: TRzSpinEdit
        Left = 85
        Top = 225
        Width = 37
        Height = 20
        TabOrder = 7
        OnChange = seAlphaChange
      end
    end
    object tsSound: TTabSheet
      Caption = #22768#38899#35774#32622
      ImageIndex = 4
      object Bevel4: TBevel
        Left = 80
        Top = 12
        Width = 374
        Height = 1
        Shape = bsTopLine
      end
      object lblSound: TLabel
        Left = 20
        Top = 26
        Width = 36
        Height = 12
        Caption = #25991#20214#65306
      end
      object Bevel1: TBevel
        Left = 80
        Top = 75
        Width = 374
        Height = 1
        Shape = bsTopLine
      end
      object cbBackSound: TRzCheckBox
        Left = 8
        Top = 4
        Width = 70
        Height = 17
        AlignmentVertical = avBottom
        Caption = #32972#26223#22768#38899
        Checked = True
        Font.Charset = ANSI_CHARSET
        Font.Color = 13977088
        Font.Height = -12
        Font.Name = #23435#20307
        Font.Style = []
        ParentFont = False
        State = cbChecked
        TabOrder = 0
        OnClick = cbBackSoundClick
      end
      object beSound: TRzButtonEdit
        Left = 58
        Top = 22
        Width = 295
        Height = 20
        TabOrder = 1
        OnChange = beSoundChange
        OnButtonClick = beSoundButtonClick
      end
      object pnlAct: TPanel
        Left = 363
        Top = 21
        Width = 77
        Height = 22
        AutoSize = True
        BevelOuter = bvNone
        TabOrder = 2
        object btnPause: TSpeedButton
          Left = 0
          Top = 0
          Width = 23
          Height = 22
          Cursor = crHandPoint
          Action = actPause
          Glyph.Data = {
            36060000424D3606000000000000360400002800000020000000100000000100
            08000000000000020000530B0000530B00000001000000000000000000003300
            00006600000099000000CC000000FF0000000033000033330000663300009933
            0000CC330000FF33000000660000336600006666000099660000CC660000FF66
            000000990000339900006699000099990000CC990000FF99000000CC000033CC
            000066CC000099CC0000CCCC0000FFCC000000FF000033FF000066FF000099FF
            0000CCFF0000FFFF000000003300330033006600330099003300CC003300FF00
            330000333300333333006633330099333300CC333300FF333300006633003366
            33006666330099663300CC663300FF6633000099330033993300669933009999
            3300CC993300FF99330000CC330033CC330066CC330099CC3300CCCC3300FFCC
            330000FF330033FF330066FF330099FF3300CCFF3300FFFF3300000066003300
            66006600660099006600CC006600FF0066000033660033336600663366009933
            6600CC336600FF33660000666600336666006666660099666600CC666600FF66
            660000996600339966006699660099996600CC996600FF99660000CC660033CC
            660066CC660099CC6600CCCC6600FFCC660000FF660033FF660066FF660099FF
            6600CCFF6600FFFF660000009900330099006600990099009900CC009900FF00
            990000339900333399006633990099339900CC339900FF339900006699003366
            99006666990099669900CC669900FF6699000099990033999900669999009999
            9900CC999900FF99990000CC990033CC990066CC990099CC9900CCCC9900FFCC
            990000FF990033FF990066FF990099FF9900CCFF9900FFFF99000000CC003300
            CC006600CC009900CC00CC00CC00FF00CC000033CC003333CC006633CC009933
            CC00CC33CC00FF33CC000066CC003366CC006666CC009966CC00CC66CC00FF66
            CC000099CC003399CC006699CC009999CC00CC99CC00FF99CC0000CCCC0033CC
            CC0066CCCC0099CCCC00CCCCCC00FFCCCC0000FFCC0033FFCC0066FFCC0099FF
            CC00CCFFCC00FFFFCC000000FF003300FF006600FF009900FF00CC00FF00FF00
            FF000033FF003333FF006633FF009933FF00CC33FF00FF33FF000066FF003366
            FF006666FF009966FF00CC66FF00FF66FF000099FF003399FF006699FF009999
            FF00CC99FF00FF99FF0000CCFF0033CCFF0066CCFF0099CCFF00CCCCFF00FFCC
            FF0000FFFF0033FFFF0066FFFF0099FFFF00CCFFFF00FFFFFF00000080000080
            000000808000800000008000800080800000C0C0C00080808000191919004C4C
            4C00B2B2B200E5E5E500C8AC2800E0CC6600F2EABF00B59B2400D8E9EC009933
            6600D075A300ECC6D900646F710099A8AC00E2EFF10000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000B9B9B9B9B9B9
            B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9
            B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9
            B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B99C4E4E
            4EB9B99C4E4E4EB9B9B9B9B9B981818181B9B981818181B9B9B9B9B9B99CC6C6
            4EB9B99CC6C64EB9B9B9B9B9B981ACAC81B9B981ACAC81B9B9B9B9B9B99CC6C6
            4EB9B99CC6C64EB9B9B9B9B9B981ACAC81B9B981ACAC81B9B9B9B9B9B99CCCCC
            4EB9B99CCCCC4EB9B9B9B9B9B981ACAC81B9B981ACAC81B9B9B9B9B9B99CCCCC
            4EB9B99CCCCC4EB9B9B9B9B9B981ACAC81B9B981ACAC81B9B9B9B9B9B99CCCCC
            4EB9B99CCCCC4EB9B9B9B9B9B981ACAC81B9B981ACAC81B9B9B9B9B9B99CD3CC
            4EB9B99CD3CC4EB9B9B9B9B9B981ACAC81B9B981ACAC81B9B9B9B9B9B99CD3CC
            4EB9B99CD3CC4EB9B9B9B9B9B981ACAC81B9B981ACAC81B9B9B9B9B9B99CD4D4
            4EB9B99CD4D44EB9B9B9B9B9B981ACAC81B9B981ACAC81B9B9B9B9B9B99C9C9C
            9CB9B99C9C9C9CB9B9B9B9B9B981818181B9B981818181B9B9B9B9B9B9B9B9B9
            B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9
            B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9
            B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9}
          NumGlyphs = 2
        end
        object btnPlay: TSpeedButton
          Left = 0
          Top = 0
          Width = 23
          Height = 22
          Cursor = crHandPoint
          Action = actPlay
          Glyph.Data = {
            36060000424D3606000000000000360400002800000020000000100000000100
            08000000000000020000530B0000530B00000001000000000000000000003300
            00006600000099000000CC000000FF0000000033000033330000663300009933
            0000CC330000FF33000000660000336600006666000099660000CC660000FF66
            000000990000339900006699000099990000CC990000FF99000000CC000033CC
            000066CC000099CC0000CCCC0000FFCC000000FF000033FF000066FF000099FF
            0000CCFF0000FFFF000000003300330033006600330099003300CC003300FF00
            330000333300333333006633330099333300CC333300FF333300006633003366
            33006666330099663300CC663300FF6633000099330033993300669933009999
            3300CC993300FF99330000CC330033CC330066CC330099CC3300CCCC3300FFCC
            330000FF330033FF330066FF330099FF3300CCFF3300FFFF3300000066003300
            66006600660099006600CC006600FF0066000033660033336600663366009933
            6600CC336600FF33660000666600336666006666660099666600CC666600FF66
            660000996600339966006699660099996600CC996600FF99660000CC660033CC
            660066CC660099CC6600CCCC6600FFCC660000FF660033FF660066FF660099FF
            6600CCFF6600FFFF660000009900330099006600990099009900CC009900FF00
            990000339900333399006633990099339900CC339900FF339900006699003366
            99006666990099669900CC669900FF6699000099990033999900669999009999
            9900CC999900FF99990000CC990033CC990066CC990099CC9900CCCC9900FFCC
            990000FF990033FF990066FF990099FF9900CCFF9900FFFF99000000CC003300
            CC006600CC009900CC00CC00CC00FF00CC000033CC003333CC006633CC009933
            CC00CC33CC00FF33CC000066CC003366CC006666CC009966CC00CC66CC00FF66
            CC000099CC003399CC006699CC009999CC00CC99CC00FF99CC0000CCCC0033CC
            CC0066CCCC0099CCCC00CCCCCC00FFCCCC0000FFCC0033FFCC0066FFCC0099FF
            CC00CCFFCC00FFFFCC000000FF003300FF006600FF009900FF00CC00FF00FF00
            FF000033FF003333FF006633FF009933FF00CC33FF00FF33FF000066FF003366
            FF006666FF009966FF00CC66FF00FF66FF000099FF003399FF006699FF009999
            FF00CC99FF00FF99FF0000CCFF0033CCFF0066CCFF0099CCFF00CCCCFF00FFCC
            FF0000FFFF0033FFFF0066FFFF0099FFFF00CCFFFF00FFFFFF00000080000080
            000000808000800000008000800080800000C0C0C00080808000191919004C4C
            4C00B2B2B200E5E5E500C8AC2800E0CC6600F2EABF00B59B2400D8E9EC009933
            6600D075A300ECC6D900646F710099A8AC00E2EFF10000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000B9B9B9B9B9B9
            B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9
            B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9
            B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B912
            31B9B9B9B9B9B9B9B9B9B9B9B9B9B981DFB9B9B9B9B9B9B9B9B9B9B9B9B9B912
            6231B9B9B9B9B9B9B9B9B9B9B9B9B981ACDFB9B9B9B9B9B9B9B9B9B9B9B9B912
            866231B9B9B9B9B9B9B9B9B9B9B9B981ACACDFB9B9B9B9B9B9B9B9B9B9B9B912
            86868631B9B9B9B9B9B9B9B9B9B9B981ACACACDFB9B9B9B9B9B9B9B9B9B9B912
            8C86868631B9B9B9B9B9B9B9B9B9B981ACACACACDFB9B9B9B9B9B9B9B9B9B937
            B1868686B131B9B9B9B9B9B9B9B9B981ACACACACACDFB9B9B9B9B9B9B9B9B912
            B18C8CB112B9B9B9B9B9B9B9B9B9B981ACACACAC81B9B9B9B9B9B9B9B9B9B912
            B18CB112B9B9B9B9B9B9B9B9B9B9B981ACACAC81B9B9B9B9B9B9B9B9B9B9B912
            B1B112B9B9B9B9B9B9B9B9B9B9B9B981ACAC81B9B9B9B9B9B9B9B9B9B9B9B912
            B112B9B9B9B9B9B9B9B9B9B9B9B9B981AC81B9B9B9B9B9B9B9B9B9B9B9B9B912
            12B9B9B9B9B9B9B9B9B9B9B9B9B9B98181B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9
            B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9
            B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9}
          NumGlyphs = 2
        end
        object btnStop: TSpeedButton
          Left = 27
          Top = 0
          Width = 23
          Height = 22
          Cursor = crHandPoint
          Action = actStop
          Glyph.Data = {
            36060000424D3606000000000000360400002800000020000000100000000100
            08000000000000020000430B0000430B00000001000000000000000000003300
            00006600000099000000CC000000FF0000000033000033330000663300009933
            0000CC330000FF33000000660000336600006666000099660000CC660000FF66
            000000990000339900006699000099990000CC990000FF99000000CC000033CC
            000066CC000099CC0000CCCC0000FFCC000000FF000033FF000066FF000099FF
            0000CCFF0000FFFF000000003300330033006600330099003300CC003300FF00
            330000333300333333006633330099333300CC333300FF333300006633003366
            33006666330099663300CC663300FF6633000099330033993300669933009999
            3300CC993300FF99330000CC330033CC330066CC330099CC3300CCCC3300FFCC
            330000FF330033FF330066FF330099FF3300CCFF3300FFFF3300000066003300
            66006600660099006600CC006600FF0066000033660033336600663366009933
            6600CC336600FF33660000666600336666006666660099666600CC666600FF66
            660000996600339966006699660099996600CC996600FF99660000CC660033CC
            660066CC660099CC6600CCCC6600FFCC660000FF660033FF660066FF660099FF
            6600CCFF6600FFFF660000009900330099006600990099009900CC009900FF00
            990000339900333399006633990099339900CC339900FF339900006699003366
            99006666990099669900CC669900FF6699000099990033999900669999009999
            9900CC999900FF99990000CC990033CC990066CC990099CC9900CCCC9900FFCC
            990000FF990033FF990066FF990099FF9900CCFF9900FFFF99000000CC003300
            CC006600CC009900CC00CC00CC00FF00CC000033CC003333CC006633CC009933
            CC00CC33CC00FF33CC000066CC003366CC006666CC009966CC00CC66CC00FF66
            CC000099CC003399CC006699CC009999CC00CC99CC00FF99CC0000CCCC0033CC
            CC0066CCCC0099CCCC00CCCCCC00FFCCCC0000FFCC0033FFCC0066FFCC0099FF
            CC00CCFFCC00FFFFCC000000FF003300FF006600FF009900FF00CC00FF00FF00
            FF000033FF003333FF006633FF009933FF00CC33FF00FF33FF000066FF003366
            FF006666FF009966FF00CC66FF00FF66FF000099FF003399FF006699FF009999
            FF00CC99FF00FF99FF0000CCFF0033CCFF0066CCFF0099CCFF00CCCCFF00FFCC
            FF0000FFFF0033FFFF0066FFFF0099FFFF00CCFFFF00FFFFFF00000080000080
            000000808000800000008000800080800000C0C0C00080808000191919004C4C
            4C00B2B2B200E5E5E500C8AC2800E0CC6600F2EABF00B59B2400D8E9EC009933
            6600D075A300ECC6D900646F710099A8AC00E2EFF10000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000B9B9B9B9B9B9
            B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9
            B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9
            B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9904848
            48484848484848B9B9B9B9B9B981DFDFDFDFDFDFDFDFDFB9B9B9B9B9B990BBB4
            B4B4B4B4B4B448B9B9B9B9B9B981ACACACACACACACACDFB9B9B9B9B9B990C1B4
            B4B4B4B4B4B448B9B9B9B9B9B981ACACACACACACACACDFB9B9B9B9B9B990C2BB
            BBBBBBBBBBBB48B9B9B9B9B9B981ACACACACACACACACDFB9B9B9B9B9B990C8BB
            BBBBBBBBBBBB48B9B9B9B9B9B981ACACACACACACACACDFB9B9B9B9B9B990C9BB
            BBBBBBBBBBBB48B9B9B9B9B9B981ACACACACACACACACDFB9B9B9B9B9B990C9C1
            C1C1C1C1C1C148B9B9B9B9B9B981ACACACACACACACACDFB9B9B9B9B9B990C9C2
            C2C2C2C2C2C248B9B9B9B9B9B981ACACACACACACACACDFB9B9B9B9B9B990C9C9
            C9C9C9C9C9C948B9B9B9B9B9B981ACACACACACACACACDFB9B9B9B9B9B9909090
            90909090909090B9B9B9B9B9B981818181818181818181B9B9B9B9B9B9B9B9B9
            B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9
            B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9
            B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9}
          NumGlyphs = 2
        end
        object btnDelete: TSpeedButton
          Left = 54
          Top = 0
          Width = 23
          Height = 22
          Cursor = crHandPoint
          Action = actDelete
          Glyph.Data = {
            36060000424D3606000000000000360400002800000020000000100000000100
            08000000000000020000630E0000630E00000001000000000000000000003300
            00006600000099000000CC000000FF0000000033000033330000663300009933
            0000CC330000FF33000000660000336600006666000099660000CC660000FF66
            000000990000339900006699000099990000CC990000FF99000000CC000033CC
            000066CC000099CC0000CCCC0000FFCC000000FF000033FF000066FF000099FF
            0000CCFF0000FFFF000000003300330033006600330099003300CC003300FF00
            330000333300333333006633330099333300CC333300FF333300006633003366
            33006666330099663300CC663300FF6633000099330033993300669933009999
            3300CC993300FF99330000CC330033CC330066CC330099CC3300CCCC3300FFCC
            330000FF330033FF330066FF330099FF3300CCFF3300FFFF3300000066003300
            66006600660099006600CC006600FF0066000033660033336600663366009933
            6600CC336600FF33660000666600336666006666660099666600CC666600FF66
            660000996600339966006699660099996600CC996600FF99660000CC660033CC
            660066CC660099CC6600CCCC6600FFCC660000FF660033FF660066FF660099FF
            6600CCFF6600FFFF660000009900330099006600990099009900CC009900FF00
            990000339900333399006633990099339900CC339900FF339900006699003366
            99006666990099669900CC669900FF6699000099990033999900669999009999
            9900CC999900FF99990000CC990033CC990066CC990099CC9900CCCC9900FFCC
            990000FF990033FF990066FF990099FF9900CCFF9900FFFF99000000CC003300
            CC006600CC009900CC00CC00CC00FF00CC000033CC003333CC006633CC009933
            CC00CC33CC00FF33CC000066CC003366CC006666CC009966CC00CC66CC00FF66
            CC000099CC003399CC006699CC009999CC00CC99CC00FF99CC0000CCCC0033CC
            CC0066CCCC0099CCCC00CCCCCC00FFCCCC0000FFCC0033FFCC0066FFCC0099FF
            CC00CCFFCC00FFFFCC000000FF003300FF006600FF009900FF00CC00FF00FF00
            FF000033FF003333FF006633FF009933FF00CC33FF00FF33FF000066FF003366
            FF006666FF009966FF00CC66FF00FF66FF000099FF003399FF006699FF009999
            FF00CC99FF00FF99FF0000CCFF0033CCFF0066CCFF0099CCFF00CCCCFF00FFCC
            FF0000FFFF0033FFFF0066FFFF0099FFFF00CCFFFF00FFFFFF00000080000080
            000000808000800000008000800080800000C0C0C00080808000191919004C4C
            4C00B2B2B200E5E5E500C8AC2800E0CC6600F2EABF00B59B2400D8E9EC009933
            6600D075A300ECC6D900646F710099A8AC00E2EFF10000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000B9B9B9B9B9B9
            B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B96CB9B9
            B9B9B9B9B9B9B9B9B4B9B9B9B981B9B9B9B9B9B9B9B9B9B9ACB9B9B997B46CB9
            B9B9B9B9B9B9B9B9B9B9B9B981AC81B9B9B9B9B9B9B9B9B9B9B9B9B997C7B46C
            B9B9B9B9B9B9B9B4B9B9B9B981E3AC81B9B9B9B9B9B9B9ACB9B9B9B9B997C090
            B9B9B9B9B9B9B4B9B9B9B9B9B981E381B9B9B9B9B9B9ACB9B9B9B9B9B9B990B4
            6CB9B9B9B9B46CB9B9B9B9B9B9B981AC81B9B9B9B9AC81B9B9B9B9B9B9B9B990
            B46CB9B9B46CB9B9B9B9B9B9B9B9B981AC81B9B9AC81B9B9B9B9B9B9B9B9B9B9
            90B46CB46CB9B9B9B9B9B9B9B9B9B9B981AC81AC81B9B9B9B9B9B9B9B9B9B9B9
            B990B46CB9B9B9B9B9B9B9B9B9B9B9B9B981AC81B9B9B9B9B9B9B9B9B9B9B9B9
            90B46C906CB9B9B9B9B9B9B9B9B9B9B981AC818181B9B9B9B9B9B9B9B9B9B990
            B46CB9B9906CB9B9B9B9B9B9B9B9B981AC81B9B98181B9B9B9B9B9B9B990B4B4
            6CB9B9B9B9906CB9B9B9B9B9B981ACAC81B9B9B9B98181B9B9B9B9B990C7B46C
            B9B9B9B9B9B9906CB9B9B9B981E3AC81B9B9B9B9B9B98181B9B9B9B97A907AB9
            B9B9B9B9B9B9B9B990B9B9B9AC81ACB9B9B9B9B9B9B9B9B981B9B9B9B9B9B9B9
            B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9
            B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9B9}
          NumGlyphs = 2
        end
      end
      object cbLoop: TCheckBox
        Left = 20
        Top = 46
        Width = 70
        Height = 17
        Caption = #24490#29615#25773#25918
        TabOrder = 3
      end
      object mpSound: TMediaPlayer
        Left = 200
        Top = 48
        Width = 253
        Height = 22
        Visible = False
        TabOrder = 4
        OnNotify = mpSoundNotify
      end
      object cbEventSound: TRzCheckBox
        Left = 8
        Top = 67
        Width = 70
        Height = 17
        AlignmentVertical = avBottom
        Caption = #20107#20214#22768#38899
        Checked = True
        Font.Charset = ANSI_CHARSET
        Font.Color = 13977088
        Font.Height = -12
        Font.Name = #23435#20307
        Font.Style = []
        ParentFont = False
        State = cbChecked
        TabOrder = 5
        OnClick = cbEventSoundClick
      end
      object pnlEvent: TPanel
        Left = 20
        Top = 85
        Width = 333
        Height = 116
        AutoSize = True
        BevelOuter = bvNone
        TabOrder = 6
        object lblCrtA: TLabel
          Left = 0
          Top = 4
          Width = 60
          Height = 12
          Caption = #35797#39064#31572#23545#65306
        end
        object lblErrA: TLabel
          Left = 0
          Top = 28
          Width = 60
          Height = 12
          Caption = #35797#39064#31572#38169#65306
        end
        object lblTryA: TLabel
          Left = 0
          Top = 52
          Width = 60
          Height = 12
          Caption = #35797#39064#37325#35797#65306
        end
        object lblPassA: TLabel
          Left = 0
          Top = 76
          Width = 60
          Height = 12
          Caption = #27979#35797#36890#36807#65306
        end
        object lblFailA: TLabel
          Left = 0
          Top = 100
          Width = 60
          Height = 12
          Caption = #27979#35797#22833#36133#65306
        end
        object beCrt: TRzButtonEdit
          Left = 62
          Top = 0
          Width = 271
          Height = 20
          TabOrder = 0
          OnButtonClick = ButtonEditClick
        end
        object beErr: TRzButtonEdit
          Left = 62
          Top = 24
          Width = 271
          Height = 20
          TabOrder = 1
          OnButtonClick = ButtonEditClick
        end
        object beTry: TRzButtonEdit
          Left = 62
          Top = 48
          Width = 271
          Height = 20
          TabOrder = 2
          OnButtonClick = ButtonEditClick
        end
        object bePass: TRzButtonEdit
          Left = 62
          Top = 72
          Width = 271
          Height = 20
          TabOrder = 3
          OnButtonClick = ButtonEditClick
        end
        object beFail: TRzButtonEdit
          Left = 62
          Top = 96
          Width = 271
          Height = 20
          TabOrder = 4
          OnButtonClick = ButtonEditClick
        end
      end
    end
    object tsAuthor: TTabSheet
      Caption = #20316#32773'&&'#27700#21360
      ImageIndex = 2
      object lblName: TLabel
        Left = 8
        Top = 8
        Width = 36
        Height = 12
        Caption = #22995#21517#65306
      end
      object lblMail: TLabel
        Left = 8
        Top = 32
        Width = 36
        Height = 12
        Caption = #37038#20214#65306
      end
      object lblUrl: TLabel
        Left = 8
        Top = 56
        Width = 36
        Height = 12
        Caption = #20027#39029#65306
      end
      object lblDes: TLabel
        Left = 8
        Top = 80
        Width = 36
        Height = 12
        Caption = #25551#36848#65306
      end
      object Bevel2: TBevel
        Left = 56
        Top = 163
        Width = 398
        Height = 1
        Shape = bsTopLine
      end
      object lblText: TLabel
        Left = 20
        Top = 176
        Width = 36
        Height = 12
        Caption = #25991#26412#65306
      end
      object lblLink: TLabel
        Left = 20
        Top = 200
        Width = 36
        Height = 12
        Caption = #38142#25509#65306
      end
      object edtName: TEdit
        Left = 46
        Top = 4
        Width = 121
        Height = 20
        TabOrder = 0
      end
      object edtMail: TEdit
        Left = 46
        Top = 28
        Width = 121
        Height = 20
        TabOrder = 1
        Text = '@'
      end
      object edtUrl: TEdit
        Left = 46
        Top = 52
        Width = 331
        Height = 20
        TabOrder = 2
        Text = 'http://'
      end
      object meoDes: TMemo
        Left = 46
        Top = 76
        Width = 331
        Height = 73
        TabOrder = 3
      end
      object cbWaterMark: TRzCheckBox
        Left = 8
        Top = 155
        Width = 46
        Height = 17
        AlignmentVertical = avBottom
        Caption = #27700#21360
        Checked = True
        Font.Charset = ANSI_CHARSET
        Font.Color = 13977088
        Font.Height = -12
        Font.Name = #23435#20307
        Font.Style = []
        ParentFont = False
        State = cbChecked
        TabOrder = 4
        OnClick = cbWaterMarkClick
      end
      object edtText: TEdit
        Left = 58
        Top = 172
        Width = 319
        Height = 20
        TabOrder = 5
      end
      object edtLink: TEdit
        Left = 58
        Top = 196
        Width = 319
        Height = 20
        TabOrder = 6
        Text = 'http://'
      end
    end
    object tsText: TTabSheet
      Caption = #23383#31526#20018#35774#32622
      ImageIndex = 1
      object sgText: TRzStringGrid
        Left = 8
        Top = 4
        Width = 450
        Height = 240
        ColCount = 3
        Ctl3D = False
        DefaultRowHeight = 16
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goTabs, goAlwaysShowEditor]
        ParentCtl3D = False
        ScrollBars = ssVertical
        TabOrder = 0
        OnKeyDown = sgTextKeyDown
        OnSelectCell = sgTextSelectCell
        RowHeights = (
          16
          16
          16
          16
          16)
      end
    end
  end
  object odBack: TOpenPictureDialog
    Filter = 
      'All (*.jpg;*.jpeg;*.bmp;*.png;*.gif;*.emf;*.wmf)|*.jpg;*.jpeg;*.' +
      'bmp;*.png;*.gif;*.emf;*.wmf|JPEG Image File (*.jpg;*jpeg)|*.jpg;' +
      '*jpeg|Bitmaps (*.bmp)|*.bmp|GIF Image (*.gif)|*.gif|Portable Net' +
      'work Graphics (*.png)|*.png|Enhanced Metafiles (*.emf)|*.emf|Met' +
      'afiles (*.wmf)|*.wmf'
    Left = 448
  end
  object alSound: TActionList
    Left = 420
    Top = 65535
    object actPlay: TAction
      Hint = #25773#25918
      OnExecute = actPlayExecute
    end
    object actPause: TAction
      Hint = #26242#20572
      OnExecute = actPauseExecute
    end
    object actStop: TAction
      Hint = #20572#27490
      OnExecute = actStopExecute
    end
    object actDelete: TAction
      Hint = #21024#38500
      OnExecute = actDeleteExecute
    end
  end
end

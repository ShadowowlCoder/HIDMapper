object HIDMapping: THIDMapping
  Left = 0
  Top = 0
  Caption = 'HID Mappings Editor'
  ClientHeight = 599
  ClientWidth = 518
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter3: TSplitter
    Left = 0
    Top = 228
    Width = 518
    Height = 3
    Cursor = crVSplit
    Align = alTop
    Beveled = True
    ResizeStyle = rsUpdate
    ExplicitTop = 225
    ExplicitWidth = 256
  end
  object pnMapList: TPanel
    Left = 0
    Top = 0
    Width = 518
    Height = 228
    Align = alTop
    BevelOuter = bvNone
    Constraints.MaxHeight = 599
    Constraints.MinHeight = 70
    TabOrder = 0
    DesignSize = (
      518
      228)
    object lbMapList: TLabel
      Left = 5
      Top = 3
      Width = 61
      Height = 13
      Caption = '&Key map list:'
      FocusControl = MapList
    end
    object MapList: TListBox
      Left = 2
      Top = 17
      Width = 516
      Height = 210
      Anchors = [akLeft, akTop, akRight, akBottom]
      ItemHeight = 13
      TabOrder = 0
      OnClick = MapListClick
    end
  end
  object pnKey: TPanel
    Left = 0
    Top = 231
    Width = 518
    Height = 368
    Align = alClient
    BevelOuter = bvNone
    Constraints.MinHeight = 166
    TabOrder = 1
    DesignSize = (
      518
      368)
    object lbTests: TLabel
      Left = 3
      Top = 102
      Width = 30
      Height = 13
      Caption = 'Tests:'
    end
    object lIndex: TLabel
      Left = 3
      Top = 51
      Width = 32
      Height = 13
      Caption = '&Index:'
      FocusControl = eIndex
    end
    object lKeys: TLabel
      Left = 3
      Top = 73
      Width = 22
      Height = 13
      Caption = 'K&ey:'
      FocusControl = eKeys
    end
    object lMask: TLabel
      Left = 95
      Top = 51
      Width = 28
      Height = 13
      Caption = '&Mask:'
      FocusControl = eMask
    end
    object lName: TLabel
      Left = 3
      Top = 29
      Width = 31
      Height = 13
      Caption = '&Name:'
      FocusControl = eName
    end
    object lType: TLabel
      Left = 172
      Top = 51
      Width = 28
      Height = 13
      Caption = '&Type:'
      FocusControl = cbType
    end
    object lValue: TLabel
      Left = 252
      Top = 51
      Width = 30
      Height = 13
      Caption = '&Value:'
      FocusControl = eValue
    end
    object bbtAdd: TBitBtn
      Left = 50
      Top = 1
      Width = 25
      Height = 25
      Hint = 'Add (fill at least Name field)'
      Caption = '+'
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      OnClick = bbtAddClick
      NumGlyphs = 2
    end
    object bbtApply: TBitBtn
      Left = 76
      Top = 1
      Width = 25
      Height = 25
      Hint = 'Apply'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      OnClick = bbtApplyClick
      Glyph.Data = {
        DE010000424DDE01000000000000760000002800000024000000120000000100
        0400000000006801000000000000000000001000000000000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
        3333333333333333333333330000333333333333333333333333F33333333333
        00003333344333333333333333388F3333333333000033334224333333333333
        338338F3333333330000333422224333333333333833338F3333333300003342
        222224333333333383333338F3333333000034222A22224333333338F338F333
        8F33333300003222A3A2224333333338F3838F338F33333300003A2A333A2224
        33333338F83338F338F33333000033A33333A222433333338333338F338F3333
        0000333333333A222433333333333338F338F33300003333333333A222433333
        333333338F338F33000033333333333A222433333333333338F338F300003333
        33333333A222433333333333338F338F00003333333333333A22433333333333
        3338F38F000033333333333333A223333333333333338F830000333333333333
        333A333333333333333338330000333333333333333333333333333333333333
        0000}
      NumGlyphs = 2
    end
    object bbtGuess: TBitBtn
      Left = 130
      Top = 1
      Width = 25
      Height = 25
      Hint = 'Discover mask (HID device must be selected)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
      OnClick = bbtGuessClick
      Glyph.Data = {
        DE010000424DDE01000000000000760000002800000024000000120000000100
        0400000000006801000000000000000000001000000000000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333336633
        3333333333333FF3333333330000333333364463333333333333388F33333333
        00003333333E66433333333333338F38F3333333000033333333E66333333333
        33338FF8F3333333000033333333333333333333333338833333333300003333
        3333446333333333333333FF3333333300003333333666433333333333333888
        F333333300003333333E66433333333333338F38F333333300003333333E6664
        3333333333338F38F3333333000033333333E6664333333333338F338F333333
        0000333333333E6664333333333338F338F3333300003333344333E666433333
        333F338F338F3333000033336664333E664333333388F338F338F33300003333
        E66644466643333338F38FFF8338F333000033333E6666666663333338F33888
        3338F3330000333333EE666666333333338FF33333383333000033333333EEEE
        E333333333388FFFFF8333330000333333333333333333333333388888333333
        0000}
      NumGlyphs = 2
    end
    object bbtRemove: TBitBtn
      Left = 103
      Top = 1
      Width = 25
      Height = 25
      Hint = 'Remove'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      OnClick = bbtRemoveClick
      Glyph.Data = {
        DE010000424DDE01000000000000760000002800000024000000120000000100
        0400000000006801000000000000000000001000000000000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
        333333333333333333333333000033338833333333333333333F333333333333
        0000333911833333983333333388F333333F3333000033391118333911833333
        38F38F333F88F33300003339111183911118333338F338F3F8338F3300003333
        911118111118333338F3338F833338F3000033333911111111833333338F3338
        3333F8330000333333911111183333333338F333333F83330000333333311111
        8333333333338F3333383333000033333339111183333333333338F333833333
        00003333339111118333333333333833338F3333000033333911181118333333
        33338333338F333300003333911183911183333333383338F338F33300003333
        9118333911183333338F33838F338F33000033333913333391113333338FF833
        38F338F300003333333333333919333333388333338FFF830000333333333333
        3333333333333333333888330000333333333333333333333333333333333333
        0000}
      NumGlyphs = 2
    end
    object btTest: TButton
      Left = 50
      Top = 97
      Width = 75
      Height = 25
      Caption = 'Test keys'
      TabOrder = 10
      OnClick = btTestClick
    end
    object cbType: TComboBox
      Left = 204
      Top = 48
      Width = 40
      Height = 21
      Hint = 'Compare type'
      ItemHeight = 13
      ItemIndex = 0
      ParentShowHint = False
      ShowHint = True
      TabOrder = 7
      Text = 'B'
      Items.Strings = (
        'B'
        '='
        '>'
        '<')
    end
    object eIndex: TEdit
      Left = 50
      Top = 48
      Width = 40
      Height = 21
      Hint = 'Index of masked report byte'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 5
    end
    object eKeys: TEdit
      Left = 50
      Top = 70
      Width = 468
      Height = 21
      Hint = 'Key sequence'
      Anchors = [akLeft, akTop, akRight]
      Color = clMenu
      ParentShowHint = False
      ReadOnly = True
      ShowHint = True
      TabOrder = 9
      OnKeyDown = eKeysKeyDown
    end
    object eMask: TEdit
      Left = 127
      Top = 48
      Width = 40
      Height = 21
      Hint = 'Hexadecimal 2 digit number'
      MaxLength = 2
      ParentShowHint = False
      ShowHint = True
      TabOrder = 6
    end
    object eName: TEdit
      Left = 50
      Top = 26
      Width = 468
      Height = 21
      Hint = 'Name of key mapping'
      Anchors = [akLeft, akTop, akRight]
      ParentShowHint = False
      ShowHint = True
      TabOrder = 4
      OnChange = eNameChange
    end
    object eTest: TMemo
      Left = 3
      Top = 128
      Width = 516
      Height = 238
      Hint = 'Test field for mappings'
      Anchors = [akLeft, akTop, akRight, akBottom]
      ParentShowHint = False
      ShowHint = True
      TabOrder = 11
    end
    object eValue: TEdit
      Left = 284
      Top = 48
      Width = 40
      Height = 21
      Hint = 'Hexadecimal 2 digit number'
      MaxLength = 2
      ParentShowHint = False
      ShowHint = True
      TabOrder = 8
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 424
    Top = 80
  end
end

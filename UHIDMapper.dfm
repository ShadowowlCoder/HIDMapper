object HIDM: THIDM
  Left = 0
  Top = 0
  Caption = 'HID Mapper'
  ClientHeight = 481
  ClientWidth = 707
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
  object Splitter2: TSplitter
    Left = 369
    Top = 0
    Height = 481
    Beveled = True
    ResizeStyle = rsUpdate
    ExplicitLeft = 385
    ExplicitTop = 19
  end
  object pnLeft: TPanel
    Left = 0
    Top = 0
    Width = 369
    Height = 481
    Align = alLeft
    BevelOuter = bvNone
    Constraints.MaxWidth = 700
    TabOrder = 0
    object Splitter1: TSplitter
      Left = 0
      Top = 228
      Width = 369
      Height = 3
      Cursor = crVSplit
      Align = alTop
      Beveled = True
      ResizeStyle = rsUpdate
      ExplicitLeft = -6
      ExplicitTop = 230
      ExplicitWidth = 514
    end
    object pnDevice: TPanel
      Left = 0
      Top = 0
      Width = 369
      Height = 228
      Align = alTop
      BevelOuter = bvNone
      Constraints.MaxHeight = 695
      Constraints.MinHeight = 93
      TabOrder = 0
      DesignSize = (
        369
        228)
      object lbDeviceList: TLabel
        Left = 3
        Top = 3
        Width = 52
        Height = 13
        Caption = '&Device list:'
        FocusControl = DevListBox
      end
      object lbVID_PID: TLabel
        Left = 3
        Top = 209
        Width = 50
        Height = 13
        Anchors = [akLeft, akBottom]
        Caption = 'Device ID:'
        FocusControl = DevVID_PID
      end
      object DevListBox: TListBox
        Left = 0
        Top = 17
        Width = 368
        Height = 187
        Hint = 'Devices List'
        Anchors = [akLeft, akTop, akRight, akBottom]
        ItemHeight = 13
        TabOrder = 0
        OnClick = DevListBoxClick
      end
      object DevVID_PID: TEdit
        Left = 80
        Top = 206
        Width = 288
        Height = 21
        Hint = 'Device IDs'
        Anchors = [akLeft, akRight, akBottom]
        ReadOnly = True
        TabOrder = 1
      end
    end
    object pnIni: TPanel
      Left = 0
      Top = 231
      Width = 369
      Height = 250
      Align = alClient
      BevelOuter = bvNone
      Constraints.MinHeight = 70
      TabOrder = 1
      DesignSize = (
        369
        250)
      object lbIni: TLabel
        Left = 3
        Top = 8
        Width = 50
        Height = 13
        Caption = '&Profile list:'
        FocusControl = IniScList
      end
      object IniScList: TListBox
        Left = -2
        Top = 27
        Width = 368
        Height = 222
        Hint = 'Profiles list'
        Anchors = [akLeft, akTop, akRight, akBottom]
        ItemHeight = 13
        TabOrder = 5
        OnClick = IniScListClick
      end
      object bbtAddProfile: TBitBtn
        Left = 78
        Top = 2
        Width = 25
        Height = 25
        Hint = 'Adds new Profile for Device'
        Caption = '+'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -17
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 0
        OnClick = bbtAddProfileClick
      end
      object bbtEditProfile: TBitBtn
        Left = 127
        Top = 2
        Width = 25
        Height = 25
        Hint = 'Edits Profile Keys'
        Caption = 'E'
        Enabled = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -17
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 2
        OnClick = bbtEditProfileClick
      end
      object bbtActivateProfile: TBitBtn
        Left = 153
        Top = 2
        Width = 25
        Height = 25
        Hint = 'Activates Profile'
        Caption = 'A'
        Enabled = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -17
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 3
        OnClick = bbtActivateProfileClick
      end
      object bbtRemoveProfile: TBitBtn
        Left = 103
        Top = 2
        Width = 25
        Height = 25
        Hint = 'Removes Profile'
        Enabled = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -17
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        OnClick = bbtRemoveProfileClick
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
      object bbtDeactivateProfile: TBitBtn
        Left = 178
        Top = 2
        Width = 25
        Height = 25
        Hint = 'Deactivates current Profile'
        Caption = 'D'
        Enabled = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -17
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 4
        OnClick = bbtDeactivateProfileClick
      end
    end
  end
  object pnRight: TPanel
    Left = 372
    Top = 0
    Width = 335
    Height = 481
    Align = alClient
    BevelOuter = bvNone
    Constraints.MinWidth = 324
    TabOrder = 1
    DesignSize = (
      335
      481)
    object lbActiveScripts: TLabel
      Left = 3
      Top = 3
      Width = 72
      Height = 13
      Caption = 'Active Profiles:'
    end
    object ActiveScriptsList: TListBox
      Left = 0
      Top = 17
      Width = 334
      Height = 462
      Anchors = [akLeft, akTop, akRight, akBottom]
      ItemHeight = 13
      TabOrder = 0
    end
  end
  object HidCtl: TJvHidDeviceController
    OnEnumerate = HidCtlEnumerate
    OnDeviceChange = HidCtlDeviceChange
    Left = 88
  end
  object TrayIcon: TTrayIcon
    Hint = 'HID Mapper'
    Icon.Data = {
      0000010001002020100001000400E80200001600000028000000200000004000
      0000010004000000000080020000000000000000000010000000000000000000
      000000008000008000000080800080000000800080008080000080808000C0C0
      C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF000000
      0000000000000000000000000000088000000880880000880880000000000800
      0000080080000080080000000000080000000800800000800800000000000800
      0000080080088880080088880000080000000800800000000800000080000800
      0000080080000000080000000800080008880800800000800800000800000800
      0800880080000080080000080000080080000800000800800800000800000800
      0000000000008800080088880000080000000000000000000800000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000080000000000000000000000000000000800000000000000
      0000000008000000000000000000000000000000800000000800000000000000
      0000000800000000080000000000080000000008000000000008080000008000
      0000000800000000000800080000000000000000000000000000000008000000
      0000000000000000000000000008000000000000000000000000000008008000
      0000800000000000000800080000080000008000000080000008080000000000
      0000080000008000000000000000000000000080000000000000000000000000
      0000000000008000000000000000000000000000000080000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FFFF9F93C9FF8F81C0FF8F81C0FF8F80000F8F8000078F8000038881C0E38801
      C0E38008C0E3830C0803878E1807CFCF3C0FFFFFFFFFFFFFF9FFFFFFF8FFFFF8
      007FFFF1F8FFFFE3F9FF9FE7FE3F0FE7FE0F0000000300000000000000030F3F
      FE0F9F1F3E3FFF8F1FFFFFC00FFFFFFF1FFFFFFF3FFFFFFFFFFFFFFFFFFF}
    PopupMenu = TrayIconMenu
    Visible = True
    Left = 120
  end
  object TrayIconMenu: TPopupMenu
    Left = 152
    object N1: TMenuItem
      Caption = '-'
    end
    object OpenMainWindow: TMenuItem
      Caption = 'Open main window'
      OnClick = OpenMainWindowClick
    end
    object CloseHIDMapper: TMenuItem
      Caption = 'Close HID Mapper'
      OnClick = CloseHIDMapperClick
    end
  end
end

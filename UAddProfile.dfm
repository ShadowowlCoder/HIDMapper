object AddProfile: TAddProfile
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Add Profile'
  ClientHeight = 87
  ClientWidth = 387
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  DesignSize = (
    387
    87)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 59
    Height = 13
    Caption = 'Profile name'
  end
  object edProfileName: TEdit
    Left = 8
    Top = 24
    Width = 371
    Height = 21
    Hint = 'Name of key mapping'
    Anchors = [akLeft, akTop, akRight]
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    ExplicitWidth = 379
  end
  object btOk: TButton
    Left = 223
    Top = 53
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    TabOrder = 1
    ExplicitLeft = 231
    ExplicitTop = 51
  end
  object btCancel: TButton
    Left = 304
    Top = 53
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
    ExplicitLeft = 312
    ExplicitTop = 51
  end
end

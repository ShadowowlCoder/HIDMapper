object AddProfile: TAddProfile
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Add Profile'
  ClientHeight = 85
  ClientWidth = 395
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  DesignSize = (
    395
    85)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 59
    Height = 13
    Caption = 'Profile name'
  end
  object eProfileName: TEdit
    Left = 8
    Top = 24
    Width = 379
    Height = 21
    Hint = 'Name of key mapping'
    Anchors = [akLeft, akTop, akRight]
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    ExplicitWidth = 369
  end
  object bOk: TButton
    Left = 231
    Top = 51
    Width = 75
    Height = 25
    Caption = 'Ok'
    ModalResult = 1
    TabOrder = 1
  end
  object bCancel: TButton
    Left = 312
    Top = 51
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
end

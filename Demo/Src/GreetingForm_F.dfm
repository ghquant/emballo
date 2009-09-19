object GreetingForm: TGreetingForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Greeting demo'
  ClientHeight = 96
  ClientWidth = 222
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
  object Label1: TLabel
    Left = 34
    Top = 27
    Width = 51
    Height = 13
    Caption = 'Your name'
  end
  object edName: TEdit
    Left = 91
    Top = 24
    Width = 97
    Height = 21
    TabOrder = 0
    Text = 'Emballo'
  end
  object Button1: TButton
    Left = 34
    Top = 46
    Width = 154
    Height = 25
    Caption = 'Greeting'
    TabOrder = 1
    OnClick = Button1Click
  end
end

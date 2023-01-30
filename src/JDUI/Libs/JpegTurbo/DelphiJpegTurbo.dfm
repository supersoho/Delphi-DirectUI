object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 725
  ClientWidth = 892
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
  object Image1: TImage
    Left = 8
    Top = 8
    Width = 105
    Height = 105
    Stretch = True
  end
  object Image2: TImage
    Left = 119
    Top = 8
    Width = 105
    Height = 105
    Stretch = True
  end
  object Image3: TImage
    Left = 230
    Top = 8
    Width = 105
    Height = 105
    Stretch = True
  end
  object Image4: TImage
    Left = 344
    Top = 8
    Width = 105
    Height = 105
    Stretch = True
  end
  object Image5: TImage
    Left = 455
    Top = 8
    Width = 105
    Height = 105
    Stretch = True
  end
  object Image6: TImage
    Left = 566
    Top = 8
    Width = 105
    Height = 105
    Stretch = True
  end
  object Image7: TImage
    Left = 8
    Top = 150
    Width = 507
    Height = 547
    AutoSize = True
  end
  object Button1: TButton
    Left = 8
    Top = 119
    Width = 216
    Height = 25
    Caption = 'Mono Thread'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 230
    Top = 119
    Width = 219
    Height = 25
    Caption = 'Multi Thread'
    TabOrder = 1
    OnClick = Button2Click
  end
  object CheckBox1: TCheckBox
    Left = 677
    Top = 119
    Width = 97
    Height = 17
    Caption = 'Stop'
    TabOrder = 2
  end
  object Button3: TButton
    Left = 455
    Top = 119
    Width = 216
    Height = 25
    Caption = 'Multi Thread MJPEG'
    TabOrder = 3
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 677
    Top = 8
    Width = 105
    Height = 82
    Caption = 'Concat'
    TabOrder = 4
    OnClick = Button4Click
  end
  object ProgressBar1: TProgressBar
    Left = 677
    Top = 96
    Width = 105
    Height = 17
    TabOrder = 5
  end
  object RxSpinEdit1: TSpinEdit
    Left = 688
    Top = 127
    Width = 121
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 6
    Value = 0
  end
  object loadjpg: TButton
    Left = 521
    Top = 167
    Width = 216
    Height = 25
    Caption = 'loadjpg'
    TabOrder = 7
    OnClick = loadjpgClick
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 8
    Top = 8
  end
end

object frMain: TfrMain
  Left = 0
  Top = 0
  Caption = 'UDP-Chat'
  ClientHeight = 368
  ClientWidth = 604
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -10
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 12
  object splSettings: TSplitter
    Left = 459
    Top = 0
    Width = 5
    Height = 368
    Align = alRight
    ExplicitLeft = 377
    ExplicitHeight = 229
  end
  object gbSettings: TGroupBox
    Left = 464
    Top = 0
    Width = 140
    Height = 368
    Align = alRight
    Caption = 'Settings'
    TabOrder = 0
    object lMyPort: TLabel
      Left = 2
      Top = 14
      Width = 136
      Height = 12
      Align = alTop
      Caption = 'My port'
      ExplicitWidth = 36
    end
    object lPortToConnect: TLabel
      Left = 2
      Top = 46
      Width = 136
      Height = 12
      Align = alTop
      Caption = 'Port to connect'
      ExplicitWidth = 70
    end
    object lAddressToConnect: TLabel
      Left = 2
      Top = 78
      Width = 136
      Height = 12
      Align = alTop
      Caption = 'Adress to connect'
      ExplicitWidth = 81
    end
    object btConnect: TButton
      Left = 2
      Top = 345
      Width = 136
      Height = 21
      Align = alBottom
      Caption = 'Connect'
      TabOrder = 0
      OnClick = btConnectClick
    end
    object eMyPort: TEdit
      Left = 2
      Top = 26
      Width = 136
      Height = 20
      Align = alTop
      NumbersOnly = True
      TabOrder = 1
      Text = '10000'
    end
    object ePortToConnect: TEdit
      Left = 2
      Top = 58
      Width = 136
      Height = 20
      Align = alTop
      NumbersOnly = True
      TabOrder = 2
      Text = '10000'
    end
    object eAddressToConnect: TEdit
      Left = 2
      Top = 90
      Width = 136
      Height = 20
      Align = alTop
      TabOrder = 3
      Text = '127.0.0.1'
    end
  end
  object gbMessages: TGroupBox
    Left = 0
    Top = 0
    Width = 459
    Height = 368
    Align = alClient
    Caption = 'Messages'
    TabOrder = 1
    object Splitter1: TSplitter
      Left = 2
      Top = 302
      Width = 455
      Height = 5
      Cursor = crVSplit
      Align = alBottom
      ExplicitLeft = 1
      ExplicitTop = 41
      ExplicitWidth = 415
    end
    object btSend: TButton
      Left = 2
      Top = 345
      Width = 455
      Height = 21
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Align = alBottom
      Caption = 'Send message'
      TabOrder = 0
      OnClick = btSendClick
    end
    object mMyMsg: TMemo
      Left = 2
      Top = 307
      Width = 455
      Height = 38
      Align = alBottom
      TabOrder = 1
    end
    object reCommonMsg: TRichEdit
      Left = 2
      Top = 14
      Width = 455
      Height = 288
      Align = alClient
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -10
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      Zoom = 100
    end
  end
end

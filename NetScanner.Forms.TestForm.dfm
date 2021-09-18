object Form1: TForm1
  Left = 0
  Top = 0
  Caption = #1057#1082#1072#1085#1080#1088#1086#1074#1072#1085#1080#1077' '#1089#1077#1090#1080
  ClientHeight = 353
  ClientWidth = 734
  Color = clBtnFace
  Constraints.MinHeight = 384
  Constraints.MinWidth = 644
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  DesignSize = (
    734
    353)
  PixelsPerInch = 96
  TextHeight = 13
  object Label3: TLabel
    Left = 192
    Top = 49
    Width = 44
    Height = 13
    Anchors = [akTop]
    Caption = 'IP-'#1072#1076#1088#1077#1089
  end
  object Label4: TLabel
    Left = 205
    Top = 78
    Width = 31
    Height = 13
    Anchors = [akTop]
    Caption = #1052#1072#1089#1082#1072
  end
  object Numbers: TLabel
    Left = 8
    Top = 325
    Width = 288
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = #1042#1089#1077#1075#1086' '#1089#1082#1072#1085#1080#1088#1086#1074#1072#1090#1100': 0, '#1087#1088#1086#1089#1082#1072#1085#1080#1088#1086#1074#1072#1085#1085#1086': 0, '#1086#1089#1090#1072#1083#1086#1089#1100': 0.'
    ExplicitTop = 322
  end
  object ScanningResult: TListView
    Left = 8
    Top = 104
    Width = 718
    Height = 210
    Anchors = [akLeft, akTop, akRight, akBottom]
    Columns = <
      item
        Caption = 'IP-'#1072#1076#1088#1077#1089
        Width = 95
      end
      item
        Caption = #1053#1072#1079#1074#1072#1085#1080#1077' '#1091#1089#1090#1088#1086#1081#1089#1090#1074#1072
        Width = 120
      end
      item
        Caption = 'MAC-'#1072#1076#1088#1077#1089
        Width = 120
      end
      item
        Caption = #1053#1072#1079#1074#1072#1085#1080#1077' '#1072#1076#1072#1087#1090#1077#1088#1072' '#1091#1089#1090#1088#1086#1081#1089#1090#1074#1072
        Width = 130
      end
      item
        Caption = #1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1100#1089#1082#1086#1077' '#1080#1084#1103' '#1091#1089#1090#1088#1086#1081#1089#1090#1074#1072
        Width = 135
      end>
    TabOrder = 0
    ViewStyle = vsReport
  end
  object gbAddrRange: TGroupBox
    Left = 8
    Top = 25
    Width = 169
    Height = 73
    Caption = #1044#1080#1072#1087#1072#1079#1086#1085' '#1072#1076#1088#1077#1089#1086#1074':'
    TabOrder = 1
    object Label1: TLabel
      Left = 8
      Top = 24
      Width = 18
      Height = 13
      Caption = #1054#1090':'
    end
    object Label2: TLabel
      Left = 8
      Top = 48
      Width = 18
      Height = 13
      Caption = #1044#1086':'
    end
    object IPFrom: TEdit
      Left = 32
      Top = 21
      Width = 121
      Height = 21
      TabOrder = 0
      Text = '192.168.1.1'
    end
    object IPTo: TEdit
      Left = 32
      Top = 48
      Width = 121
      Height = 21
      TabOrder = 1
      Text = '192.168.1.4'
    end
  end
  object RadioRange: TRadioButton
    Left = 8
    Top = 8
    Width = 113
    Height = 17
    Caption = #1044#1080#1072#1087#1072#1079#1086#1085
    Checked = True
    TabOrder = 2
    TabStop = True
  end
  object RadioMask: TRadioButton
    Left = 192
    Top = 8
    Width = 113
    Height = 17
    Anchors = [akTop]
    Caption = #1052#1072#1089#1082#1072
    TabOrder = 3
  end
  object RadioGuid: TRadioButton
    Left = 370
    Top = 8
    Width = 113
    Height = 17
    Anchors = [akTop, akRight]
    Caption = 'GUID'
    TabOrder = 4
  end
  object IPAddress: TEdit
    Left = 242
    Top = 46
    Width = 121
    Height = 21
    Anchors = [akTop]
    TabOrder = 5
    Text = '192.168.1.1'
  end
  object Mask: TEdit
    Left = 242
    Top = 73
    Width = 121
    Height = 21
    Anchors = [akTop]
    TabOrder = 6
    Text = '255.255.0.0'
  end
  object GUID: TEdit
    Left = 369
    Top = 46
    Width = 240
    Height = 21
    Anchors = [akTop, akRight]
    TabOrder = 7
    Text = '{3D2536D3-F1AA-43F2-8A58-15478E052EFA}'
  end
  object scanbutton: TButton
    Left = 486
    Top = 320
    Width = 78
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1057#1082#1072#1085#1080#1088#1086#1074#1072#1090#1100
    TabOrder = 8
    OnClick = scanbuttonClick
  end
  object UpdataResults: TButton
    Left = 486
    Top = 73
    Width = 121
    Height = 25
    Anchors = [akTop, akRight]
    Caption = #1054#1073#1085#1086#1074#1080#1090#1100' '#1088#1077#1079#1091#1083#1100#1090#1072#1090
    TabOrder = 9
    OnClick = UpdataResultsClick
  end
  object Pause: TButton
    Left = 570
    Top = 320
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1055#1072#1091#1079#1072
    TabOrder = 10
    OnClick = PauseClick
  end
  object Stop: TButton
    Left = 651
    Top = 320
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1054#1089#1090#1072#1085#1086#1074#1080#1090#1100
    TabOrder = 11
    OnClick = StopClick
  end
  object AddressList: TMemo
    Left = 622
    Top = 31
    Width = 104
    Height = 67
    Lines.Strings = (
      '192.168.1.1'
      '192.168.1.2'
      '192.168.1.4')
    TabOrder = 12
  end
  object RadioAddressList: TRadioButton
    Left = 623
    Top = 8
    Width = 103
    Height = 17
    Caption = #1057#1087#1080#1089#1086#1082
    TabOrder = 13
  end
end

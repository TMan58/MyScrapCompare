object dlgMyCompareMain: TdlgMyCompareMain
  Left = 349
  Top = 136
  Caption = 'MyScrap Compare Utility'
  ClientHeight = 601
  ClientWidth = 864
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 420
    Top = 0
    Width = 5
    Height = 540
    ExplicitHeight = 545
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 540
    Width = 864
    Height = 61
    Align = alBottom
    TabOrder = 0
    object btnCompare: TButton
      Left = 5
      Top = 9
      Width = 75
      Height = 25
      Caption = '&Compare'
      TabOrder = 0
      OnClick = btnCompareClick
    end
    object btnLeftPaste: TButton
      Left = 96
      Top = 9
      Width = 75
      Height = 25
      Caption = '&Left Paste'
      TabOrder = 1
      OnClick = btnLeftPasteClick
    end
    object btnRightPaste: TButton
      Left = 184
      Top = 9
      Width = 75
      Height = 25
      Caption = '&Right Paste'
      TabOrder = 2
      OnClick = btnRightPasteClick
    end
    object StatusBar1: TStatusBar
      Left = 1
      Top = 41
      Width = 862
      Height = 19
      Panels = <>
    end
  end
  object pnlLeft: TPanel
    Left = 0
    Top = 0
    Width = 420
    Height = 540
    Align = alLeft
    TabOrder = 1
    object edLeft: TMemo
      Left = 1
      Top = 33
      Width = 418
      Height = 506
      Align = alClient
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Style = []
      Lines.Strings = (
        'Memo1')
      ParentFont = False
      ScrollBars = ssBoth
      TabOrder = 0
    end
    object pnlLeftTop: TPanel
      Left = 1
      Top = 1
      Width = 418
      Height = 32
      Align = alTop
      BevelInner = bvLowered
      TabOrder = 1
      DesignSize = (
        418
        32)
      object edLeftFilename: TEdit
        Left = 4
        Top = 4
        Width = 409
        Height = 21
        Hint = 'Enter a unique name if opening a new compare utility'
        Anchors = [akLeft, akTop, akRight]
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
      end
    end
  end
  object pnlRight: TPanel
    Left = 425
    Top = 0
    Width = 439
    Height = 540
    Align = alClient
    TabOrder = 2
    object edRight: TMemo
      Left = 1
      Top = 33
      Width = 437
      Height = 506
      Align = alClient
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Style = []
      Lines.Strings = (
        'Memo2')
      ParentFont = False
      ScrollBars = ssBoth
      TabOrder = 0
    end
    object Panel1: TPanel
      Left = 1
      Top = 1
      Width = 437
      Height = 32
      Align = alTop
      BevelInner = bvLowered
      TabOrder = 1
      DesignSize = (
        437
        32)
      object edRightFilename: TEdit
        Left = 4
        Top = 4
        Width = 433
        Height = 21
        Hint = 'Enter a unique name if opening a new compare utility'
        Anchors = [akLeft, akTop, akRight]
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
      end
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 457
    Top = 545
  end
end

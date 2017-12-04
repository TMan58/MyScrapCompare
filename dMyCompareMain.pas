unit dMyCompareMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, WindUtl;

type
  TdlgMyCompareMain = class(TForm)
    pnlBottom: TPanel;
    pnlLeft: TPanel;
    Splitter1: TSplitter;
    pnlRight: TPanel;
    edLeft: TMemo;
    edRight: TMemo;
    btnCompare: TButton;
    btnLeftPaste: TButton;
    btnRightPaste: TButton;
    OpenDialog1: TOpenDialog;
    StatusBar1: TStatusBar;
    pnlLeftTop: TPanel;
    edLeftFilename: TEdit;
    Panel1: TPanel;
    edRightFilename: TEdit;
    procedure btnCompareClick(Sender: TObject);
    procedure btnLeftPasteClick(Sender: TObject);
    procedure btnRightPasteClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ShowHint(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure SetStatusBar(const S: String);
    //procedure SetStatus(const S: String);
  private
    { Private declarations }
    bDebug: Boolean;
    FExternalCompare: String;
    FCmdLine: String;
    FAdditionalCmdLineOption: String;
    FNCWindowName: String;
    FNCClassName: String;
    FLeftFilename: String;
    FRightFilename: String;
    lstDeleteFiles: TStringList;
    lstWindowInfo: TWindowInfoList;
    procedure CloseWindowsList(var lstWindowInfo: TWindowInfoList);
  public
    { Public declarations }
    property sStatus: String write SetStatusBar;
  end;

var
  dlgMyCompareMain: TdlgMyCompareMain;

implementation

{$R *.dfm}
uses
  Clipbrd, IniFiles, ShellAPI;
procedure TdlgMyCompareMain.btnCompareClick(Sender: TObject);
var
  sTemp: String;
  sTempDir: String;
  sTempLeft, sTempRight: String;
  sLeft, sRight: String;
  procedure OpenNC;
  begin
    sTemp := Format(FCmdLine, [sTempLeft, sTempRight]);
    if (Length(Trim(FAdditionalCmdLineOption))>0) then
      sTemp := Format('%s %s', [FAdditionalCmdLineOption, sTemp]);
    OutputDebugString(pChar(sTemp));
    StatusBar1.SimpleText := sTemp;
    ShellExecute(Handle, 'open', pAnsiChar(FExternalCompare), pAnsiChar(sTemp), nil, SW_SHOWNORMAL);
  end;
begin
  if (Length(FExternalCompare)=0) OR (NOT FileExists(FExternalCompare)) then
  begin
    if (Length(OpenDialog1.InitialDir) = 0) OR (NOT DirectoryExists(OpenDialog1.InitialDir)) then
      OpenDialog1.InitialDir := ExtractFileDir(Application.Exename);
    OpenDialog1.Title := 'Browse for Compare Utility';
    if OpenDialog1.Execute then
    begin
      FExternalCompare := OpenDialog1.Filename;
      //InputQuery('Enter Command line for Editor', 'CommandLine', FExternalEditor);
    end;
  end;
  if Length(FExternalCompare) > 0 then
  begin
    sTempDir := Format('%sTemp\', [IncludeTrailingBackslash(ExtractFilePath(Application.ExeName))]);
    if NOT ForceDirectories(sTempDir) then
    begin
      MessageDlg('Could not create directory: '+sTempDir, mtError, [mbOk], 0);
      exit;
    end;
    sLeft := Format('%s%s', [sTempdir, FLeftFilename]);
    sRight := Format('%s%s', [sTempDir, FRightFilename]);

    sTempLeft := sLeft; //Format('%s%s', [sTempdir, edLeftFilename.Text]);
    lstDeleteFiles.Add(sTempLeft);
    edLeft.Lines.SaveToFile(sTempLeft);
    sTempRight := sRight; //Format('%s%s', [sTempDir, edRightFilename.Text]);
    lstDeleteFiles.Add(sTempRight);
    edRight.Lines.SaveToFile(sTempRight);
    lstWindowInfo.Clear;
    CloseWindowsList(lstWindowInfo);
    if lstWindowInfo.Count = 0 then
      OpenNC;
  end;

end;

procedure TdlgMyCompareMain.btnLeftPasteClick(Sender: TObject);
begin
  if NOT Clipboard.HasFormat(CF_TEXT) then
  begin
    ShowMessage('The Clipboard does not contain text');
    exit;
  end;
  edLeft.Lines.Text := Clipboard.AsText;
end;

procedure TdlgMyCompareMain.btnRightPasteClick(Sender: TObject);
begin
  if NOT Clipboard.HasFormat(CF_TEXT) then
  begin
    ShowMessage('The Clipboard does not contain text');
    exit;
  end;
  edRight.Lines.Text := Clipboard.AsText;
end;

procedure TdlgMyCompareMain.FormCreate(Sender: TObject);
var
  fIni: TIniFile;
begin
  FNCWindowName := '';// 'Norton File Compare';
  FNCClassName := ''; //'Afx:400000:b:10013:6:1e1159';
  FLeftFilename := 'Left.txt';
  FRightFilename := 'Right.txt';
  FCmdLine :='"%s" "%s"';
  fIni := TIniFile.Create(ChangeFileExt(Application.exename, '.ini'));
  bDebug := False; //fIni.ReadBool('Debug', 'Enable', True);
  FExternalCompare :=  fIni.ReadString('External Compare Utility', 'ExeName', '');
  FCmdLine := fIni.ReadString('External Compare Utility', 'CmdLine', FCmdLine);
  // seems to loose them when reading...
  if ((Pos('"', FCmdLine)>0) AND (Pos('"', FCmdLine)>1)) then
      FCmdLine := Format('"%s"', [FCmdLine]);

  FAdditionalCmdLineOption := Fini.ReadString('External Compare Utility', 'AdditionalCmdLineOption', FAdditionalCmdLineOption);
//  FNCWindowName := fini.ReadString('External Compare Utility', 'WindowName', FNCWindowName);
//  FNCClassName := fIni.ReadString('External Compare Utility', 'ClassName', FNCClassName);
  FLeftFilename := fIni.ReadString('External Compare Utility', 'LeftFilename', FLeftFilename);
  FRightFilename := fIni.ReadString('External Compare Utility', 'RightFilename', FRightFilename);
  FreeAndNil(fIni);
  lstWindowInfo := TWindowInfoList.Create;
  lstDeleteFiles := TStringList.Create;
  lstDeleteFiles.Duplicates := dupIgnore;
  lstDeleteFiles.Sorted := True;
  edLeft.Clear;
  edRight.Clear;
  edLeftFilename.Text := FLeftFilename;
  edRightFilename.Text := FRightFilename;
end;

procedure TdlgMyCompareMain.FormDestroy(Sender: TObject);
var
  fIni: TIniFile;
begin
  fIni := TIniFile.Create(ChangeFileExt(Application.exename, '.ini'));
  // Not used // fIni.WriteBool('Debug', 'Enable', bDebug);
  fIni.WriteString('External Compare Utility', 'ExeName', FExternalCompare);
 // if (Length(Trim(FCmdLine))=0) then
    fIni.WriteString('External Compare Utility', 'CmdLine', FCmdLine);
  if (Length(Trim(FAdditionalCmdLineOption))=0) then // don't write it back will lose parentheses
    fIni.WriteString('External Compare Utility', 'AdditionalCmdLineOption', FAdditionalCmdLineOption);
  fIni.WriteString('External Compare Utility', 'LeftFilename', FLeftFilename);
  fIni.WriteString('External Compare Utility', 'RightFilename', FRightFilename);
  FreeAndNil(fIni);
end;

procedure TdlgMyCompareMain.ShowHint(Sender: TObject);
begin
  StatusBar1.SimpleText := Application.Hint;
  Application.ProcessMessages;
end;
{
procedure TdlgMyCompareMain.SetStatus(const S: String);
begin
//  Memo2.Lines.Add(S);
  Application.ProcessMessages;
  if bDebug then
    OutputdebugString(pChar(s));
end;
}
procedure TdlgMyCompareMain.SetStatusBar(const S: String);
begin
  StatusBar1.SimpleText := S;
  Application.ProcessMessages;
  if bDebug then
    OutputdebugString(pChar(s));
end;


procedure TdlgMyCompareMain.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
  procedure MyCloseAll;
  var
    t: Integer;
  begin
    for t:=0 to Pred(lstWindowInfo.Count) do
    begin
      PostMessage(lstWindowInfo.hHandle[t], WM_CLOSE, 0, 0);
    end;
  end;
  {procedure MyQueryClose;
  var
    t: Integer;
  begin
    for t:=0 to Pred(lstWindowInfo.Count) do
    begin
      if MessageDlg(Format('Close: %s', [lstWindowInfo.sWindowName[t]]), mtConfirmation, [mbYes, mbNo], 0) = mrYes then
        PostMessage(lstWindowInfo.hHandle[t], WM_MyClose, 0, 0);
    end;
  end;}
var
  t: Integer;
  bCloseNC: Boolean;
begin
  bCloseNC := True;
  CanClose :=  MessageDlg('Are you sure you want to close MyScrapCompare Utility?', mtConfirmation, [mbYes, mbNo], 0)=mrYes;
  if CanClose then
  begin
    lstWindowInfo.Clear;
    CloseWindowsList(lstWindowInfo);
    if lstWindowInfo.Count > 0 then
    begin
      bCloseNC := MessageDlg('Close Compare Utility?', mtConfirmation, [mbYes, mbNo], 0) = mrYes;
      if bCloseNC then
        MyCloseAll
    end;
    FreeAndNil(lstWindowInfo);
    if bCloseNC AND Assigned(lstDeleteFiles) then
      for t:=0 to Pred(lstDeleteFiles.Count) do
        DeleteFile(lstDeleteFiles.Strings[t]);
    FreeAndNil(lstDeleteFiles);
  end;
end;

procedure TdlgMyCompareMain.CloseWindowsList(var lstWindowInfo: TWindowInfoList);
var
  t: Integer;
  sWTemp, sCTemp: String;
begin

  if (Length(FNCWindowName)=0) then exit;
  if (Length(FNCClassName)=0) then exit;

  MyEnumAllWindows(lstWindowInfo);
  for t:=Pred(lstWindowInfo.Count) downto 0 do
  begin
    if Handle = lstWindowInfo.hHandle[t] then
    begin
      lstWindowInfo.Delete(t);
      continue;
    end;
    sWTemp := lstWindowInfo.sWindowName[t];
    sStatus := sWTemp;
    if CompareText(FNCWindowName, sWTemp) <> 0 then
    begin
      lstWindowInfo.Delete(t);
      sStatus := 'Deleted';
      continue;
    end;
    sCTemp := lstWindowInfo.sClassName[t];
    sStatus := sCTemp;
//    if CompareText(FNCClassName, sCTemp) <> 0 then
    if (Pos('Afx:', sCTemp)<>1) AND (CompareText(FNCWindowName, sWTemp) <> 0) then
    begin
      lstWindowInfo.Delete(t);
      sStatus := 'Deleted';
    end;
  end;
end;

end.

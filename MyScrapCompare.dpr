program MyScrapCompare;

uses
  Forms,
  dMyCompareMain in 'dMyCompareMain.pas' {dlgMyCompareMain};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TdlgMyCompareMain, dlgMyCompareMain);
  Application.Run;
end.

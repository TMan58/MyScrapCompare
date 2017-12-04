unit WindUtl;

interface
uses
  Classes, Contnrs, Windows;

Type
  TOWindowInfo = Class
      FHandle: THandle;
      FWindowName: String;
      FClassName: String;
      FWindowText: String;
      bChildWindow: Boolean;
      FParentWindow: String;
    Constructor Create(Handle: THandle; const WindowName, ClassName, WindowText: String); overload;
    constructor CreateChild( Handle: THandle;
                             const WindowName, ClassName, WindowText: String;
                             const IsChildWindow: Boolean;
                             const ParentWindow: String); overload;
    constructor Create; overload;
    procedure Assign(Source: TOWindowInfo);
    function GetDisplayInfo: String;
    Destructor Destroy; Override;
    property sDisplayInfo: String read GetDisplayInfo;
  end;
type
  TWindowInfoList = Class(TObjectList)
      bGetWindowText: Boolean;
      bIncludeId: Boolean;
      sGetWindowName: String;
      sGetClassName: String;
      bGetChildWindows: Boolean;
    constructor Create;
    function GetHandle(iIndex: Integer): THandle;
    function GetWindowName(iIndex: Integer): String;
    function GetClassName(iIndex: Integer): String;
    function GetWindowText(iIndex: Integer): String;
    function GetDisplayInfo(iIndex: Integer): String;
    function GetWindowInfoObject(iIndex: Integer): TOWindowInfo;
    property hHandle[iIndex: integer]: THandle read GetHandle;
    property sWindowName[iIndex: integer]: String read GetWindowName;
    property sClassName[iIndex: integer]: String read GetClassName;
    property sWindowText[iIndex: Integer]: String read GetWindowText;
    property sDisplayInfo[iIndex: Integer]: String read GetDisplayInfo;
    property OWindowInfo[iIndex: Integer]: TOWindowInfo read GetWindowInfoObject;
  end;

Procedure MyEnumAllWindows(lstWindowInfo: TWindowInfoList);

function MyEnumWinProc(Handle: HWnd; {lParam: LParam): Bool; //} lstWindowInfo: TWindowInfoList): Boolean stdCall;
function MyEnumChildWinProc(Handle: HWnd; lstWindowInfo: TWindowInfoList): Boolean stdCall;

implementation
uses
  Forms, SysUtils;

Constructor TOWindowInfo.Create(Handle: THandle; const WindowName, ClassName, WindowText: String);
Begin
  Inherited Create;
  FHandle := Handle;
  FWindowName := WindowName;
  FClassName := ClassName;
  FWindowText := WindowText;
end;

constructor TOWindowInfo.CreateChild(Handle: THandle;
                                     const WindowName, ClassName, WindowText: String;
                                     const IsChildWindow: Boolean;
                                     const ParentWindow: String);
begin
  Create(Handle, WindowName, ClassName, WindowText);
  bChildWindow := IsChildWindow;
  FParentWindow := ParentWindow;
end;

constructor TOWindowInfo.Create;
begin
  Inherited Create;
end;

procedure TOWindowInfo.Assign(Source: TOWindowInfo);
begin
  FHandle := Source.FHandle;
  FWindowName := Source.FWindowName;
  FClassName := Source.FCLassName;
  FWindowText := Source.FWindowText;
  bChildWindow := Source.bChildWindow;
  FParentWindow := Source.FParentWindow;
end;

Destructor TOWindowInfo.Destroy;
Begin
  Inherited Destroy;
end;

constructor TWindowInfoList.Create;
begin
  inherited;
  OwnsObjects := True;
end;

function TOWindowInfo.GetDisplayInfo: String;
//var
  //OWindowInfo: TOWindowInfo;
begin

  if Length(FWindowName) > 0 then
    result := FWindowName
  else
    result := '';
  if Length(result) > 0 then
  begin
    if Length(FWindowText) > 0 then
      result := Format('%s - [%s] "%s"', [FWindowName, FClassName, FWindowText])
    else
      result := Format('%s - [%s]', [FWindowName, FClassName])
  end
  else
    result := Format('[%s]', [FClassName]);
  if bChildWindow then
    result := Format('< %s > - "%s"', [FParentWindow, result]);
end;



function TWindowInfoList.GetHandle(iIndex: Integer): THandle;
begin
  result := (Items[iIndex] as TOWindowInfo).FHandle;
end;

function TWindowInfoList.GetWindowName(iIndex: Integer): String;
begin
  result := (Items[iIndex] as TOWindowInfo).FWindowName;
end;

function TWindowInfoList.GetClassName(iIndex: Integer): String;
begin
  result := (Items[iIndex] as TOWindowInfo).FClassName;
end;

function TWindowInfoList.GetWindowText(iIndex: Integer): String;
begin
  result := (Items[iIndex] as TOWindowInfo).FWindowText;
end;

function TWindowInfoList.GetDisplayInfo(iIndex: Integer): String;
begin
  result := (Items[iIndex] as TOWindowInfo).GetDisplayInfo;

{
  OWindowInfo := (Items[iIndex] as TOWindowInfo);
  if Length(OWindowInfo.FWindowName) > 0 then
    result := OWindowInfo.FWindowName
  else
    result := '';
  if Length(result) > 0 then
    result := Format('%s - [%s]', [OWindowInfo.FWindowName, OWindowInfo.FClassName])
  else
    result := Format('[%s]', [OWindowInfo.FClassName]);
}
end;

function TWindowInfoList.GetWindowInfoObject(iIndex: Integer): TOWindowInfo;
begin
  result := Items[iIndex] as TOWindowInfo;
end;

function MyEnumChildWinProc(Handle: HWnd; lstWindowInfo: TWindowInfoList): Boolean;
Var
  szName, szClass: Array[0..1023] of Char;
  liIndex: LongInt;
  liDlgItem: LongInt;
  szText: Array[0..1023] of Char;
  liTextLen: LongInt;
  sText: String;
  sTemp: String;
  iTemp: Integer;
  bOk: Boolean;
  liIndexValue: LongInt;
Begin
  Result := True;
  {AHandle := Handle; }{AHandle := GetWindow(Handle, GW_OWNER);}
  if GetWindowText(Handle, szName, SizeOf(szName)) = 0 then //<> 0 then
  Begin
    //exit;
    StrPCopy(szName, 'No Child Name');
    //lstActiveWindows.AddObject(StrPas(szTemp), TOHandle.Create(Handle));
  end;

  if GetClassName(Handle, szClass, SizeOf(szClass)) = 0 then
  begin
    exit;
    StrPCopy(szClass, 'No Class');
  end;
  //lstActiveWindows.AddObject(StrPas(szName)+' - ['+StrPas(szClass)+']', TOHandle.Create(Handle));
  sText := '';
  if lstWindowInfo.bGetWindowText then //AND (Length(lstWindowInfo.sGetWindowName)>0) then
  begin
    bOk := False;
    sTemp := lstWindowInfo.sGetWindowName;
    if Length(Trim(sTemp)) > 0 then
      bOk := CompareText(sTemp, StrPas(szName)) = 0;
    //else
      //bOk := True;
    if bOk then {1}
    begin
      sTemp := lstWindowInfo.sGetClassName;
      if Length(Trim(sTemp)) > 0 then
        bOk := CompareText(sTemp, StrPas(szClass)) = 0
      else
        bOk := False;
      if bOk then {2}
      begin
        sText := '';
        liIndexValue := 0;
        for liIndex :=-1000000 to 10000000 do
        begin
          Inc(liIndexValue);
          liDlgItem := GetDlgItem(Handle, liIndex);
          if liDlgItem <> 0 then
          begin
            liTextLen := GetDlgItemText(Handle, liIndex, szText, SizeOf(szText));
            if liTextLen > 0 then
            begin
              if lstWindowInfo.bIncludeId then
              begin
                if Length(sText) > 0 then
                  sText := Format('%s, [%d]"%s"', [sText, liIndex, StrPas(szText)])
                else
                  sText := Format('[%d]"%s"', [liIndex, StrPas(szText)]);
              end
              else
              begin
                if Length(sText) > 0 then
                  sText := Format('%s, "%s"', [sText, StrPas(szText)])
                else
                  sText := Format('"%s"', [StrPas(szText)]);
              end;
            end; // if liTextLen > 0 then
          end; // if liDlgItem <> 0 then
        end; // for liIndex :=0 to 100000 do
        if Length(sText) = 0 then
          sText := '[No text found...]'+IntToStr(liIndexValue);
      end; // if bOk then {2}...
    end; // if bOk then {1}...
  end; // if lstWindowInfo.bGetWindowText then
  iTemp := Pred(lstWindowInfo.Count);
  sTemp := lstWindowInfo.sDisplayInfo[iTemp];
  if Length(stemp) = 0 then
    sTemp := 'No Parent';
  lstWindowInfo.Add(TOWindowInfo.CreateChild( Handle, StrPas(szName), StrPas(szClass), sText, True, sTemp));

  //Application.ProcessMessages; //MyProcessMessages;
  if lstWindowInfo.bGetChildWindows then
    EnumChildWindows(Handle, @MyEnumChildWinProc, LongInt(lstWindowInfo));
  //Application.ProcessMessages; //MyProcessMessages;

end; //function MyEnumChildWinProc(Handle: HWnd; {lParam: LParam): Bool; //} lstWindowInfo: TWindowInfoList): Boolean;













function MyEnumWinProc(Handle: HWnd; {lParam: LParam): Bool; //} lstWindowInfo: TWindowInfoList): Boolean;
Var
  szName, szClass: Array[0..1023] of Char;
  liIndex: LongInt;
  liDlgItem: LongInt;
  szText: Array[0..1023] of Char;
  liTextLen: LongInt;
  sText: String;
  sTemp: String;
  bOk: Boolean;
  liIndexValue: LongInt;
Begin
  Result := True;
  {AHandle := Handle; }{AHandle := GetWindow(Handle, GW_OWNER);}
  if GetWindowText(Handle, szName, SizeOf(szName)) = 0 then //<> 0 then
  Begin
    //exit;
    StrPCopy(szName, 'No Name');
    //lstActiveWindows.AddObject(StrPas(szTemp), TOHandle.Create(Handle));
  end;

  if GetClassName(Handle, szClass, SizeOf(szClass)) = 0 then
  begin
    exit;
    StrPCopy(szClass, 'No Class');
  end;
  //lstActiveWindows.AddObject(StrPas(szName)+' - ['+StrPas(szClass)+']', TOHandle.Create(Handle));
  sText := '';
  if lstWindowInfo.bGetWindowText then
  begin
    bOk := False;
    sTemp := lstWindowInfo.sGetWindowName;
    if Length(Trim(sTemp)) > 0 then
      bOk := CompareText(sTemp, StrPas(szName)) = 0;
    //else
      //bOk := True;
    if bOk then {1}
    begin
      sTemp := lstWindowInfo.sGetClassName;
      if Length(Trim(sTemp)) > 0 then
        bOk := CompareText(sTemp, StrPas(szClass)) = 0
      else
        bOk := False;
      if bOk then {2}
      begin
        sText := '';
        liIndexValue := 0;
        for liIndex :=-1000000 to 10000000 do
        begin
          Inc(liIndexValue);
          liDlgItem := GetDlgItem(Handle, liIndex);
          if liDlgItem <> 0 then
          begin
            liTextLen := GetDlgItemText(Handle, liIndex, szText, SizeOf(szText));
            if liTextLen > 0 then
            begin
              if lstWindowInfo.bIncludeId then
              begin
                if Length(sText) > 0 then
                  sText := Format('%s, [%d]"%s"', [sText, liIndex, StrPas(szText)])
                else
                  sText := Format('[%d]"%s"', [liIndex, StrPas(szText)]);
              end
              else
              begin
                if Length(sText) > 0 then
                  sText := Format('%s, "%s"', [sText, StrPas(szText)])
                else
                  sText := Format('"%s"', [StrPas(szText)]);
              end;
            end; // if liTextLen > 0 then
          end; // if liDlgItem <> 0 then
        end; // for liIndex :=0 to 100000 do
        if Length(sText) = 0 then
          sText := '[No text found...]'+IntToStr(liIndexValue);
      end; // if bOk then {2}...
    end; // if bOk then {1}...
  end; // if lstWindowInfo.bGetWindowText then
  lstWindowInfo.Add(TOWindowInfo.Create(Handle, StrPas(szName), StrPas(szClass), sText));

  Application.ProcessMessages; //MyProcessMessages;

  if lstWindowInfo.bGetChildWindows then
    EnumChildWindows(Handle, @MyEnumChildWinProc, LongInt(lstWindowInfo));
    Application.ProcessMessages; //MyProcessMessages;

end; //function MyEnumWinProc(Handle: HWnd; {lParam: LParam): Bool; //} lstWindowInfo: TWindowInfoList): Boolean;

Procedure MyEnumAllWindows(lstWindowInfo: TWindowInfoList);
Begin
//  lstActiveWindows := AlstActiveWindows;
  lstWindowInfo.Clear;
  EnumWindows(@MyEnumWinProc, {0); // }LongInt(lstWindowInfo));
end;

end.

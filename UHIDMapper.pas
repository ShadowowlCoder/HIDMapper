unit UHIDMapper;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, JvHidControllerClass, IniFiles, StdCtrls, ComCtrls,
  ShellApi, Mask, Buttons, ExtCtrls, UHIDMapping;

const
  WM_NOTIFYICON  = WM_USER+345;
  // typy masek
  M_BINARNA = 'B';
  // maski ca³kowite, sprawdzaj¹ce ca³y bajt
  M_ROWNA = '=';
  M_WIEKSZA = '>';
  M_MNIEJSZA = '<';

type
  THIDM = class(TForm)
    HidCtl: TJvHidDeviceController;
    DevListBox: TListBox;
    DevVID_PID: TEdit;
    IniScList: TListBox;
    pnDevice: TPanel;
    Splitter1: TSplitter;
    lbDeviceList: TLabel;
    lbVID_PID: TLabel;
    pnIni: TPanel;
    lbIni: TLabel;
    pnLeft: TPanel;
    pnRight: TPanel;
    Splitter2: TSplitter;
    lbActiveScripts: TLabel;
    ActiveScriptsList: TListBox;
    bbtAddScript: TBitBtn;
    bbtEditScript: TBitBtn;
    bbtActivateScript: TBitBtn;
    bbtRemoveScript: TBitBtn;
    bbtDeactivate: TBitBtn;
    procedure HidDeviceData(HidDev: TJvHidDevice;
      ReportID: Byte; const Data: Pointer; Size: Word);
    procedure FormCreate(Sender: TObject);
    procedure HidCtlDeviceChange(Sender: TObject);
    function HidCtlEnumerate(HidDev: TJvHidDevice; const Idx: Integer): Boolean;
    procedure IniScListClick(Sender: TObject);
    procedure bbtAddScriptClick(Sender: TObject);
    procedure bbtEditScriptClick(Sender: TObject);
    procedure bbtActivateScriptClick(Sender: TObject);
    procedure bbtRemoveScriptClick(Sender: TObject);
    procedure DevListBoxClick(Sender: TObject);
    procedure bbtDeactivateClick(Sender: TObject);
  private
    a_IniFile: TMemIniFile;
    CurrentMapping: TMapping;
    HMainIcon: HICON; // ikona aplikacji w trayu
    tnid: TNotifyIconData; // dane ikony aplikacji w trayu
    function DeviceName(HidDev: TJvHidDevice): string;
    function DeviceVendorID(HidDev: TJvHidDevice): string;
    function DeviceProductID(HidDev: TJvHidDevice): string;
    procedure CMClickIcon(var msg: TMessage); message WM_NOTIFYICON;
    procedure MinimizeClick(Sender:TObject);
    procedure RestoreWindow; // przywrócenie okna aplikacji
    procedure DeviceStart(HidDev: TJvHidDevice);
    procedure DeviceStop(HidDev: TJvHidDevice);
    procedure SetCurrentMapping;
  end;

var
  HIDM: THIDM;

implementation

{$R *.dfm}

const
  INI_FILE = 'HIDMapper.ini';

procedure THIDM.bbtActivateScriptClick(Sender: TObject);
begin
  // stop reader thread
  ActiveScriptsList.Clear;
  if Assigned(CurrentMapping.Device) then
    DeviceStop(CurrentMapping.Device);
  if (DevListBox.Items.Count > 0) and (DevListBox.ItemIndex >= 0) then
  begin
    SetCurrentMapping;
    DeviceStart(CurrentMapping.Device);
    ActiveScriptsList.AddItem(
      DevListBox.Items[DevListBox.ItemIndex]+' '+
      IniScList.Items[IniScList.ItemIndex],
      nil);
  end;
  bbtDeactivate.Enabled:=True;
end;

procedure THIDM.bbtAddScriptClick(Sender: TObject);
begin
  // dodanie nowego skryptu
end;

procedure THIDM.bbtDeactivateClick(Sender: TObject);
begin
  ActiveScriptsList.Clear;
  if Assigned(CurrentMapping.Device) then
    DeviceStop(CurrentMapping.Device);
  bbtDeactivate.Enabled:=False;
end;

procedure THIDM.bbtEditScriptClick(Sender: TObject);
var
  s,s1,s2: String;
  i: Integer;
  DevActive: boolean;
  ScriptActive: boolean;
begin
  DevActive:=False;
  ScriptActive:=False;
  if (DevListBox.Items.Count>0)and(DevListBox.ItemIndex>=0) then
    DevActive:=(CurrentMapping.Device=TJvHidDevice(DevListBox.Items.Objects[DevListBox.ItemIndex]));
  if (IniScList.Items.Count>0)and(IniScList.ItemIndex>=0) then
    ScriptActive:=(CurrentMapping.Script=IniScList.Items[IniScList.ItemIndex]);
  if (DevListBox.Items.Count>0)and(DevListBox.ItemIndex>=0) then
    HIDMapping.SetGuessDevice(TJvHidDevice(DevListBox.Items.Objects[DevListBox.ItemIndex]))
  else
    HIDMapping.SetGuessDevice(nil);
  HIDMapping.KeysChanged:=False;
  HIDMapping.ShowModal;
  if HidMapping.KeysChanged then
  begin
    if DevActive and ScriptActive then
      DeviceStop(CurrentMapping.Device);
    with HidMapping do
    begin
      s:=IniScList.Items[IniScList.ItemIndex];
      if a_IniFile.SectionExists(s) then
        a_IniFile.EraseSection(s);
      if a_nmaps>0 then
      begin
        if a_VID<>'' then
          a_IniFile.WriteString(s,'VID',a_VID);
        if a_PID<>'' then
          a_IniFile.WriteString(s,'PID',a_PID);
        a_IniFile.WriteInteger(s,'nmaps',a_nmaps);
        for i := 0 to a_nmaps-1 do
        begin
          s1:=IntToStr(i+1);
          a_IniFile.WriteString(s,'name'+s1,a_KeyMap[i].name);
          s2:=IntToStr(a_KeyMap[i].index)+' '+IntToHex(a_KeyMap[i].mask,2)+' '+
                       a_KeyMap[i].mtype;
          if a_KeyMap[i].mtype<>'B' then
            s2:=s2+IntToStr(a_KeyMap[i].value);
          a_IniFile.WriteString(s,'mask'+s1,s2);
          a_IniFile.WriteString(s,'key'+s1,a_KeyMap[i].keys);
        end;
      end;
    end;
    if DevActive and ScriptActive then
    begin
      SetCurrentMapping;
      DeviceStart(CurrentMapping.Device);
    end;
  end;
end;

procedure THIDM.bbtRemoveScriptClick(Sender: TObject);
begin
  // usuniêcie skryptu
  if Application.MessageBox('Are you really want to remove this script?',
                            'Removing script',MB_YESNO)=IDYES then
  begin

  end;
end;

procedure THIDM.CMClickIcon(var msg: TMessage);
begin
  case msg.lparam of
    WM_LBUTTONUP, WM_LBUTTONDBLCLK :
    {WM_BUTTONDOWN may cause next Icon to activate if this icon is deleted -
        (Icons shift left and left neighbor will be under mouse at ButtonUp time)}
    begin
      RestoreWindow;
    end;
  end;
end;

function THIDM.DeviceName(HidDev: TJvHidDevice): string;
begin
  if HidDev.ProductName <> '' then
    Result := HidDev.ProductName
  else
    Result := Format('Device VID=%.4x PID=%.4x',
      [HidDev.Attributes.VendorID, HidDev.Attributes.ProductID]);
  if HidDev.SerialNumber <> '' then
    Result := Result + Format(' (Serial=%s)', [HidDev.SerialNumber]);
end;

function THIDM.DeviceProductID(HidDev: TJvHidDevice): string;
begin
  Result := Format('PID_%.4x', [HidDev.Attributes.ProductID]);
end;

procedure THIDM.DeviceStart(HidDev: TJvHidDevice);
begin
  // start reader thread
  HidDev.OnData := HidDeviceData;
end;

procedure THIDM.DeviceStop(HidDev: TJvHidDevice);
begin
  // sop reader thread
  HidDev.OnData := nil;
end;

function THIDM.DeviceVendorID(HidDev: TJvHidDevice): string;
begin
  Result := Format('VID_%.4x', [HidDev.Attributes.VendorID]);
end;

procedure THIDM.DevListBoxClick(Sender: TObject);
var
  HidDev: TJvHidDevice;
begin
  HidDev:=TJvHidDevice(DevListBox.Items.Objects[DevListBox.ItemIndex]);
  DevVID_PID.Text:= DeviceVendorID(HidDev) + '&' + DeviceProductID(HidDev);
  bbtActivateScript.Enabled:=(DevListBox.ItemIndex>=0)and(IniScList.ItemIndex>=0)
end;

procedure THIDM.FormCreate(Sender: TObject);
begin
  a_IniFile:=TMemIniFile.Create(INI_FILE);
  if not FileExists(INI_FILE) then
    Application.Terminate;
  a_IniFile.ReadSections(IniScList.Items);

  HMainIcon                := LoadIcon(MainInstance, 'MAINICON');

  Shell_NotifyIcon(NIM_DELETE, @tnid);

  tnid.cbSize              := sizeof(TNotifyIconData);
  tnid.Wnd                 := handle;
  tnid.uID                 := 123;
  tnid.uFlags              := NIF_MESSAGE or NIF_ICON or NIF_TIP;
  tnid.uCallbackMessage    := WM_NOTIFYICON;
  tnid.hIcon               := HMainIcon;
  tnid.szTip               := 'HID Mapper';

  Application.OnMinimize:= MinimizeClick;
end;

procedure THIDM.HidCtlDeviceChange(Sender: TObject);
var
  Dev: TJvHidDevice;
  I, N: Integer;
  s,s1: String;
begin
  s:='';
  s1:='';
  for I := 0 to DevListBox.Items.Count - 1 do
  begin
    Dev := TJvHidDevice(DevListBox.Items.Objects[I]);
    if (CurrentMapping.Device<>nil)and(Dev=CurrentMapping.Device) then
    begin
      // zatrzymanie obs³ugi wybranego urz¹dzenia i zapamiêtanie go
      s:=DeviceVendorID(Dev) + '&' + DeviceProductID(Dev);
      DeviceStop(Dev);
    end;
    Dev.Free;
  end;
  DevListBox.ItemIndex:=-1;
  DevListBox.Items.Clear;

  DevVID_PID.Text:='';
  while HidCtl.CheckOut(Dev) do
  begin
    N := DevListBox.Items.Add(DeviceName(Dev));
    Dev.NumInputBuffers := 128;
    Dev.NumOverlappedBuffers := 128;
    DevListBox.Items.Objects[N] := Dev;
    // automatyczne podpiêcie tego samego urz¹dzenia co przed zmian¹
    s1:=DeviceVendorID(Dev) + '&' + DeviceProductID(Dev);
    if (s<>'')and(s=s1) then
    begin
      DevListBox.ItemIndex:=DevListBox.Items.Count-1;
      DeviceStart(Dev);
    end;
  end;
  // jak nie wybrano urz¹dzenia i jest tylko jedno urz¹dzenie to
  // od razu je wybieramy
  if (DevListBox.ItemIndex=-1)and(DevListBox.Items.Count=1) then
  begin
    DevListBox.ItemIndex:=0;
    DevListBoxClick(Self);
  end;
end;

procedure THIDM.HidDeviceData(HidDev: TJvHidDevice;
  ReportID: Byte; const Data: Pointer; Size: Word);
var
  i: Integer;
  v_b: byte;
  v_Time1, v_Time2: longint;
begin
  
  // topimy wyj¹tek
  try
    // nie mo¿emy sprawdzaæ d³ugoœci tabeli, bo mo¿e byæ ona w trakcie
    // ³adowania danych, trzeba kontrolowaæ iloœæ mapowañ
    if (CurrentMapping.nmaps>0)and
       (CurrentMapping.VID<>'')and(CurrentMapping.VID=DeviceVendorID(HidDev))and
       (((CurrentMapping.PID<>'')and(CurrentMapping.PID=DeviceProductID(HidDev)))or
        (CurrentMapping.PID='')) then
      for i := 0 to CurrentMapping.nmaps - 1 do
        if CurrentMapping.KeyMap[i].index<Size then
        begin
          // najpierw wybieramy odpowiedni bajt z raportu i go maskujemy
          v_b:=byte(PChar(Data)[CurrentMapping.KeyMap[i].index]) and
               CurrentMapping.KeyMap[i].mask;
          // a potem w zale¿noœci od metody porównania sprawdzamy z
          // podan¹ wartoœci¹
          if ((CurrentMapping.KeyMap[i].mtype=M_BINARNA)and(v_b>0))or
             ((CurrentMapping.KeyMap[i].mtype=M_ROWNA)and(v_b=CurrentMapping.KeyMap[i].value))or
             ((CurrentMapping.KeyMap[i].mtype=M_MNIEJSZA)and(v_b<CurrentMapping.KeyMap[i].value))or
             ((CurrentMapping.KeyMap[i].mtype=M_WIEKSZA)and(v_b>CurrentMapping.KeyMap[i].value)) then
            HIDMapping.SendKeys(CurrentMapping.KeyMap[i].keys);
        end;
  except
  end;
end;

procedure THIDM.IniScListClick(Sender: TObject);
var
  s: String;
  i, vMaps: Integer;
begin
  bbtActivateScript.Enabled:=(DevListBox.ItemIndex>=0)and(IniScList.ItemIndex>=0);
  if (IniScList.Items.Count > 0) and (IniScList.ItemIndex >= 0) then
  begin
    bbtRemoveScript.Enabled:=True;
    with HIDMapping do
    begin
      bbtEditScript.Enabled:=True;
      // blokujemy dostêp do tablicy mapowania poprzez wyzerowanie liczby
      // mapowañ
      a_nmaps:=0;
      s:=IniScList.Items[IniScList.ItemIndex];
      MapList.Items.Clear;
      a_VID:=a_IniFile.ReadString(s,'VID','');
      a_PID:=a_IniFile.ReadString(s,'PID','');
      // odczytujemy now¹ iloœæ mapowañ z pliku, ale jeszcze jej
      // nie ustawiamy w klasie, nale¿y to zrobiæ po wgraniu wszystkich
      // mapowañ.
      vMaps:=a_IniFile.ReadInteger(s,'nmaps',0);
      SetLength(a_KeyMap,vMaps);
      if vMaps>0 then
      begin
        for i := 0 to vMaps-1 do
          AddMappingFromIni(a_IniFile,s,i);
        MapList.ItemIndex:=0;
        MapListClick(Self);
        a_nmaps:=vMaps;
      end
      else
      begin
        eName.Text:='';
        eIndex.Text:='0';
        eMask.Text:='00';
        cbType.Text:='B';
        eValue.Text:='00';
        eKeys.Text:='';
        eTest.Text:='';
      end;
    end;
  end
  else
  begin
    bbtRemoveScript.Enabled:=False;
    bbtEditScript.Enabled:=False;
    bbtActivateScript.Enabled:=False;
  end;
end;

procedure THIDM.MinimizeClick(Sender: TObject);
begin
  Shell_NotifyIcon(NIM_Add, @tnid);
  Hide;
  if IsWindowVisible(Application.Handle) then
    ShowWindow(Application.Handle, SW_HIDE);
end;

procedure THIDM.RestoreWindow;
begin
  Shell_NotifyIcon(NIM_Delete, @tnid);
  Application.Restore;
  {restore the application}
  if WindowState = wsMinimized then
    WindowState := wsNormal;
  {Reset minimized state}
  Visible := true;
  Application.BringToFront;
  SetForegroundWindow(Application.Handle);
  {Force form to the foreground }
  ShowWindowAsync(Handle, SW_SHOW);
end;

procedure THIDM.SetCurrentMapping;
var
  i: Integer;
begin
  if (DevListBox.Items.Count>0)and(DevListBox.ItemIndex>=0) then
    CurrentMapping.Device:=TJvHidDevice(DevListBox.Items.Objects[DevListBox.ItemIndex]);
  if (IniScList.Items.Count>0)and(IniScList.ItemIndex>=0) then
    CurrentMapping.Script:=IniScList.Items[IniScList.ItemIndex];
  with HidMapping do
  begin
    CurrentMapping.VID:=a_VID;
    CurrentMapping.PID:=a_PID;
    CurrentMapping.nmaps:=a_nmaps;
    SetLength(CurrentMapping.KeyMap,a_nmaps+1);
    for i := 0 to a_nmaps - 1 do
    begin
      CurrentMapping.KeyMap[i].mtype:=a_KeyMap[i].mtype;
      CurrentMapping.KeyMap[i].name:=a_KeyMap[i].name;
      CurrentMapping.KeyMap[i].index:=a_KeyMap[i].index;
      CurrentMapping.KeyMap[i].mask:=a_KeyMap[i].mask;
      CurrentMapping.KeyMap[i].value:=a_KeyMap[i].value;
      CurrentMapping.KeyMap[i].keys:=a_KeyMap[i].keys;
    end;
  end;
end;

function THIDM.HidCtlEnumerate(HidDev: TJvHidDevice;
  const Idx: Integer): Boolean;
var
  N: Integer;
  Dev: TJvHidDevice;
begin
  N := DevListBox.Items.Add(DeviceName(HidDev));
  HidCtl.CheckOutByIndex(Dev, Idx);
  Dev.NumInputBuffers := 128;
  Dev.NumOverlappedBuffers := 128;
  DevListBox.Items.Objects[N] := Dev;
  Result := True;
end;

end.

unit UHIDMapper;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, JvHidControllerClass, IniFiles, StdCtrls, ComCtrls,
  ShellApi, Mask, Buttons, ExtCtrls, UHIDMapping, UAddProfile, JvComponentBase,
  Menus;

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
    bbtAddProfile: TBitBtn;
    bbtEditProfile: TBitBtn;
    bbtActivateProfile: TBitBtn;
    bbtRemoveProfile: TBitBtn;
    bbtDeactivateProfile: TBitBtn;
    TrayIcon: TTrayIcon;
    TrayIconMenu: TPopupMenu;
    OpenMainWindow: TMenuItem;
    CloseHIDMapper: TMenuItem;
    N1: TMenuItem;
    procedure ProfileClick(Sender: TObject);
    procedure CloseHIDMapperClick(Sender: TObject);
    procedure OpenMainWindowClick(Sender: TObject);
    procedure HidDeviceData(HidDev: TJvHidDevice;
      ReportID: Byte; const Data: Pointer; Size: Word);
    procedure FormCreate(Sender: TObject);
    procedure HidCtlDeviceChange(Sender: TObject);
    function HidCtlEnumerate(HidDev: TJvHidDevice; const Idx: Integer): Boolean;
    procedure IniScListClick(Sender: TObject);
    procedure bbtAddProfileClick(Sender: TObject);
    procedure bbtEditProfileClick(Sender: TObject);
    procedure bbtActivateProfileClick(Sender: TObject);
    procedure bbtRemoveProfileClick(Sender: TObject);
    procedure DevListBoxClick(Sender: TObject);
    procedure bbtDeactivateProfileClick(Sender: TObject);
  private
    a_IniFile: TIniFile;
    CurrentMapping: TMapping;

    procedure ActivateProfile(AHIDDevice: TJvHidDevice; AProfile: String);
    procedure DeactivateProfile;
    function DeviceName(HidDev: TJvHidDevice): string;
    function DeviceVendorID(HidDev: TJvHidDevice): string;
    function DeviceProductID(HidDev: TJvHidDevice): string;
    procedure DeviceStart(HidDev: TJvHidDevice);
    procedure DeviceStop(HidDev: TJvHidDevice);
    procedure SetCurrentMapping(AHIDDevice: TJvHidDevice; AProfile: String);
  end;

var
  HIDM: THIDM;

implementation

{$R *.dfm}

const
  INI_FILE = 'HIDMapper.ini';

procedure THIDM.ActivateProfile(AHIDDevice: TJvHidDevice; AProfile: String);
begin
  // stop reader thread
  ActiveScriptsList.Clear;
  if Assigned(CurrentMapping.Device) then
  DeviceStop(AHIDDevice);
  SetCurrentMapping(AHIDDevice, AProfile);
  DeviceStart(AHIDDevice);
  ActiveScriptsList.AddItem(DeviceName(AHIDDevice) + ' ' + AProfile, nil);
  bbtDeactivateProfile.Enabled := True;
end;

procedure THIDM.DeactivateProfile;
begin
  ActiveScriptsList.Clear;
  if Assigned(CurrentMapping.Device) then
    DeviceStop(CurrentMapping.Device);
  bbtDeactivateProfile.Enabled := False;
end;

procedure THIDM.bbtActivateProfileClick(Sender: TObject);
begin
  ActivateProfile(TJvHidDevice(DevListBox.Items.Objects[DevListBox.ItemIndex]), IniScList.Items[IniScList.ItemIndex]);
end;

procedure THIDM.bbtDeactivateProfileClick(Sender: TObject);
begin
  DeactivateProfile;
end;

procedure THIDM.bbtAddProfileClick(Sender: TObject);
begin
  // Add new Profile
  AddProfile.eProfileName.Text := EmptyStr;
  if (AddProfile.ShowModal = mrOK) and (AddProfile.eProfileName.Text <> EmptyStr) then
  begin
    IniScList.Items.Add(AddProfile.eProfileName.Text);
    a_IniFile.WriteInteger(AddProfile.eProfileName.Text, 'nmaps', 0);
  end;
end;

procedure THIDM.bbtEditProfileClick(Sender: TObject);
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
  HIDMapping.KeysChanged := False;
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
      if a_nmaps > 0 then
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
      SetCurrentMapping(CurrentMapping.Device, CurrentMapping.Script);
      DeviceStart(CurrentMapping.Device);
    end;
  end;
end;

procedure THIDM.bbtRemoveProfileClick(Sender: TObject);
begin
  // Remove script
  if Application.MessageBox('Are you really want to remove this script?',
                            'Removing script', MB_YESNO) = IDYES then
  begin
      if a_IniFile.SectionExists(IniScList.Items[IniScList.ItemIndex]) then
      begin
        a_IniFile.EraseSection(IniScList.Items[IniScList.ItemIndex]);
        IniScList.DeleteSelected;
      end;
  end;
end;

procedure THIDM.CloseHIDMapperClick(Sender: TObject);
begin
  Application.Terminate;
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

  TrayIconMenu.Items.Find(DeviceName(CurrentMapping.Device)).Find(CurrentMapping.Script).Checked := True;
end;

procedure THIDM.DeviceStop(HidDev: TJvHidDevice);
begin
  // stop reader thread
  HidDev.OnData := nil;
  TrayIconMenu.Items.Find(DeviceName(CurrentMapping.Device)).Find(CurrentMapping.Script).Checked := False;
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
  bbtActivateProfile.Enabled := (DevListBox.ItemIndex>=0) and (IniScList.ItemIndex>=0);
end;

procedure THIDM.FormCreate(Sender: TObject);
begin
  a_IniFile := TIniFile.Create(ChangeFileExt(Application.ExeName, '.INI'));
  if not FileExists(ChangeFileExt(Application.ExeName, '.INI')) then
    Application.Terminate;
  a_IniFile.ReadSections(IniScList.Items);
end;

procedure THIDM.HidCtlDeviceChange(Sender: TObject);
var
  Dev: TJvHidDevice;
  I, N, J: Integer;
  s,s1: String;
  ProfileItem: TMenuItem;
  HIDDeviceItem: TMenuItem;
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
  //Clear Tray Icon menu items
  while TrayIconMenu.Items[0].Caption <> '-' do
      TrayIconMenu.Items[0].Free;

  DevVID_PID.Text := '';
  while HidCtl.CheckOut(Dev) do
  begin
    if DevListBox.Items.IndexOf(DeviceName(Dev)) = - 1 then
    begin
      N := DevListBox.Items.Add(DeviceName(Dev));
      HIDDeviceItem := TMenuItem.Create(TrayIconMenu);
      HIDDeviceItem.Caption := DeviceName(Dev);
      TrayIconMenu.Items.Insert(0, HIDDeviceItem);
      
      for J := 0 to  IniScList.Items.Count - 1 do
      begin
        ProfileItem := TMenuItem.Create(HIDDeviceItem);
        ProfileItem.Caption := IniScList.Items[J];
        ProfileItem.OnClick := ProfileClick;
        HIDDeviceItem.Add(ProfileItem);
      end;
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
  I: Integer;
  v_b: Byte;
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
  I: Integer;
  vMaps: Integer;
begin

  bbtActivateProfile.Enabled:=(DevListBox.ItemIndex>=0)and(IniScList.ItemIndex>=0);
  if (IniScList.Items.Count > 0) and (IniScList.ItemIndex >= 0) then
  begin
    bbtRemoveProfile.Enabled := True;
    with HIDMapping do
    begin
      bbtEditProfile.Enabled := True;
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
        for i := 0 to vMaps - 1 do
          AddMappingFromIni(a_IniFile, s, I);
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
    bbtRemoveProfile.Enabled := False;
    bbtEditProfile.Enabled := False;
    bbtActivateProfile.Enabled := False;
  end;
end;

procedure THIDM.OpenMainWindowClick(Sender: TObject);
begin
  Application.Restore;
end;

procedure THIDM.ProfileClick(Sender: TObject);
begin
  if Sender is TMenuItem then
  begin
    if TMenuItem(Sender).Checked then
    begin
      DeactivateProfile;
      TMenuItem(Sender).Checked := False;
    end
    else
    begin
      ActivateProfile(TJvHidDevice(DevListBox.Items.Objects[DevListBox.Items.IndexOf(StripHotkey(TMenuItem(Sender).Parent.Caption))]), TMenuItem(Sender).Caption);
      TMenuItem(Sender).Checked := True;
    end;
  end;
end;

procedure THIDM.SetCurrentMapping(AHIDDevice: TJvHidDevice; AProfile: String);
var
  I: Integer;
begin
  CurrentMapping.Device := AHIDDevice;
  CurrentMapping.Script := AProfile;
  with HIDMapping do
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

function THIDM.HidCtlEnumerate(HidDev: TJvHidDevice; const Idx: Integer): Boolean;
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

unit UHIDMapping;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, IniFiles, JvHidControllerClass, Menus;

type
  TKeyMap = record
    mtype: char;
    name: String;
    index: Integer;
    mask: byte;
    value: byte;
    keys: String;
  end;

  TMapping = record
    Script: String;
    Device: TJvHidDevice;
    VID: String;
    PID: String;
    nmaps: Integer;
    KeyMap: array of TKeyMap;
  end;

  TKeyCode = record
    code: Integer;
    name: String;
  end;

  THIDMapping = class(TForm)
    pnMapList: TPanel;
    lbMapList: TLabel;
    MapList: TListBox;
    Splitter3: TSplitter;
    pnKey: TPanel;
    lbTests: TLabel;
    lIndex: TLabel;
    lKeys: TLabel;
    lMask: TLabel;
    lName: TLabel;
    lType: TLabel;
    lValue: TLabel;
    bbtAdd: TBitBtn;
    bbtApply: TBitBtn;
    bbtGuess: TBitBtn;
    bbtRemove: TBitBtn;
    btTest: TButton;
    cbType: TComboBox;
    eIndex: TEdit;
    eKeys: TEdit;
    eMask: TEdit;
    eName: TEdit;
    eTest: TMemo;
    eValue: TEdit;
    procedure eKeysKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure bbtAddClick(Sender: TObject);
    procedure bbtApplyClick(Sender: TObject);
    procedure bbtRemoveClick(Sender: TObject);
    procedure MapListClick(Sender: TObject);
    procedure bbtGuessClick(Sender: TObject);
    procedure HidDeviceDataGuess(HidDev: TJvHidDevice;
      ReportID: Byte; const Data: Pointer; Size: Word);
    procedure btTestClick(Sender: TObject);
    procedure eNameChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    a_GuessString: String;
    a_GuessData: TJvHidDataEvent;
    a_GuessDevice: TJvHidDevice;
    a_GuessInProgress: Boolean;
    a_KeysChanged: Boolean;
  public
    a_VID: String;
    a_PID: String;
    a_nmaps: Integer;
    a_KeyMap: array of TKeyMap;
    procedure AddMappingFromIni(p_IniFile: TCustomIniFile; pName:String; pIndex: Integer);
    procedure SetMappingFromGUI(pIndex: Integer);
    procedure SendKeys(Keys: String);
    procedure SetGuessDevice(p_GuessDevice: TJvHidDevice);
    property KeysChanged: Boolean read a_KeysChanged write a_KeysChanged;
  end;

var
  HIDMapping: THIDMapping;

const

  CODE_TABLE: array[1..26] of TKeyCode = (
    (code: VK_RETURN;     name:'{ENTER}';),
    (code: VK_ESCAPE;     name:'{ESC}';),
    (code: VK_LEFT;       name:'{LEFT}';),
    (code: VK_RIGHT;      name:'{RIGHT}';),
    (code: VK_UP;         name:'{UP}';),
    (code: VK_DOWN;       name:'{DOWN}';),
    (code: VK_TAB;        name:'{TAB}';),
    (code: VK_MENU;       name:'{MENU}';),
    (code: VK_HOME;       name:'{HOME}';),
    (code: VK_END;        name:'{END}';),
    (code: VK_PRIOR;      name:'{PGUP}';),
    (code: VK_NEXT;       name:'{PGDOWN}';),
    (code: VK_INSERT;     name:'{INSERT}';),
    (code: VK_DELETE;     name:'{DELETE}';),
    (code: VK_F1;         name:'{F1}';),
    (code: VK_F2;         name:'{F2}';),
    (code: VK_F3;         name:'{F3}';),
    (code: VK_F4;         name:'{F4}';),
    (code: VK_F5;         name:'{F5}';),
    (code: VK_F6;         name:'{F6}';),
    (code: VK_F7;         name:'{F7}';),
    (code: VK_F8;         name:'{F8}';),
    (code: VK_F9;         name:'{F9}';),
    (code: VK_F10;        name:'{F10}';),
    (code: VK_F11;        name:'{F11}';),
    (code: VK_F12;        name:'{F12}';)
  );

implementation

{$R *.dfm}

{ THIDMapping }

procedure THIDMapping.AddMappingFromIni(p_IniFile: TCustomIniFile; pName: String; pIndex: Integer);
var
  s1, s2: String;
begin
  s1:=IntToStr(pIndex+1);
  a_KeyMap[pIndex].name:=p_IniFile.ReadString(pName,'name'+s1,s1);
  // Format linii maski jest nastêpuj¹cy:
  // maskX=I MM T V
  // gdzie:
  //  X - numer mapowania
  //  I - indeks bajtu w raporcie zerowym
  //  MM - maska heksadecymalna bajtu
  //  T - typ porównania:
  //      B - binarny
  //      = - wartoœæ musi byæ równa V
  //      > - wartoœæ musi byæ wiêksza od V
  //      < - wartoœæ musi byæ mniejsza od V
  s2:=p_IniFile.ReadString(pName,'mask'+s1,'0 00 B'); // domyœlnie nie powinno siê w ogóle odpaliæ
  // zabezpieczenie
  if Pos(' ',s2)=0 then s2:=s2+' ';
  a_KeyMap[pIndex].index:=StrToInt(Copy(s2,1,Pos(' ',s2)-1));
  s2:=Copy(s2,Pos(' ',s2)+1,Length(s2));
  // zabezpieczenie
  while Copy(s2,1,1)=' ' do
    s2:=Copy(s2,2,Length(s2)-1);
  if s2='' then s2:='00 ';
  if Pos(' ',s2)=0 then s2:=s2+' ';
  a_KeyMap[pIndex].mask:=StrToInt('$'+LowerCase(Copy(s2,1,Pos(' ',s2)-1)));
  s2:=Copy(s2,Pos(' ',s2)+1,Length(s2));
  // zabezpieczenie
  while Copy(s2,1,1)=' ' do
    s2:=Copy(s2,2,Length(s2)-1);
  if s2='' then s2:='B';
  a_KeyMap[pIndex].mtype:=s2[1];
  s2:=Copy(s2,2,Length(s2)-1);
  while Copy(s2,1,1)=' ' do
    s2:=Copy(s2,2,Length(s2)-1);
  if s2='' then s2:='0';
  a_KeyMap[pIndex].value:=StrToInt(s2);
  a_KeyMap[pIndex].keys:=p_IniFile.ReadString(pName,'key'+s1,'');
  MapList.Items.Add(a_KeyMap[pIndex].name);
end;

procedure THIDMapping.bbtAddClick(Sender: TObject);
begin
  if eName.Text<>'' then
  begin
    // najpierw dodajemy do tabeli a dopiero na koñcu zwiêkszamy
    // licznik elementów
    SetLength(a_KeyMap,a_nmaps+1);
    SetMappingFromGUI(a_nmaps);
    MapList.Items.Add(a_KeyMap[a_nmaps].name);
    Inc(a_nmaps);
  end;
end;

procedure THIDMapping.bbtApplyClick(Sender: TObject);
begin
  a_nmaps:=0;
  if (MapList.Items.Count>0) and (MapList.ItemIndex>=0) then
  begin
    SetMappingFromGUI(MapList.ItemIndex);
    MapList.Items[MapList.ItemIndex]:=eName.Text;
    a_nmaps:=MapList.Items.Count;
  end;
  a_KeysChanged:=True;
end;

procedure THIDMapping.bbtGuessClick(Sender: TObject);
var
  b: Boolean;
begin
  if not a_GuessInProgress then
  begin
    a_GuessInProgress:=True;
    a_GuessData:=a_GuessDevice.OnData;
    cbType.Text:='B';
    eValue.Text:='00';
    eTest.Text:='Click ? again to stop guessing.'+sLineBreak+
                'Reports:'+sLineBreak;
    a_GuessDevice.OnData:=HidDeviceDataGuess;
    Application.MessageBox('Test your HID device.'+sLineBreak+
                           'Click several times one button.'+sLineBreak+
                           'Click ? again to stop guessing the mask.',
                           'Test keys of selected HID device',
                           MB_OK);
  end
  else
  begin
    a_GuessInProgress:=False;
    a_GuessDevice.OnData:=a_GuessData;
  end;
  b:=not a_GuessInProgress;
  MapList.Enabled:=b;
  bbtAdd.Enabled:=b;
  bbtApply.Enabled:=b;
  bbtRemove.Enabled:=b;
  btTest.Enabled:=b;
  eTest.Enabled:=b;
  cbType.Enabled:=b;
  eValue.Enabled:=b;
  eIndex.Enabled:=b;
  eMask.Enabled:=b;
end;

procedure THIDMapping.bbtRemoveClick(Sender: TObject);
var
  i, vI: Integer;
begin
  vI:=MapList.ItemIndex;
  if (MapList.Items.Count>0) and (vI>=0) then
  begin
    a_nmaps:=0;
    if vI<MapList.Items.Count-1 then
    for i := vI to MapList.Items.Count - 2 do
    begin
      a_KeyMap[i].name:=a_KeyMap[i+1].name;
      a_KeyMap[i].index:=a_KeyMap[i+1].index;
      a_KeyMap[i].mask:=a_KeyMap[i+1].mask;
      a_KeyMap[i].mtype:=a_KeyMap[i+1].mtype;
      a_KeyMap[i].value:=a_KeyMap[i+1].value;
      a_KeyMap[i].keys:=a_KeyMap[i+1].keys;
    end;
    MapList.Items.Delete(vI);
    if vI+1>MapList.Items.Count then
      MapList.ItemIndex:=MapList.Items.Count-1
    else
      MapList.ItemIndex:=vI;
    a_nmaps:=MapList.Items.Count;
    MapListClick(Self);
  end;
end;

procedure THIDMapping.btTestClick(Sender: TObject);
begin
  if (MapList.Items.Count>0) and (MapList.ItemIndex>=0) then
    if eKeys.Text<>'' then
    begin
      eTest.Text:='';
      eTest.SetFocus;
      SendKeys(eKeys.Text);
    end;
end;

procedure THIDMapping.eKeysKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  I: Integer;
begin
  I := -1;
  repeat
    I := I + 1;
  until (I = Length(CODE_TABLE)) or (CODE_TABLE[I].Code = Key);
  if I <> Length(CODE_TABLE) then
    eKeys.Text := eKeys.Text + CODE_TABLE[I].name;
end;

procedure THIDMapping.eNameChange(Sender: TObject);
begin
  bbtAdd.Enabled:=(eName.Text<>'');
end;

procedure THIDMapping.FormCreate(Sender: TObject);
begin
  a_GuessInProgress := False;
end;

procedure THIDMapping.HidDeviceDataGuess(HidDev: TJvHidDevice; ReportID: Byte;
  const Data: Pointer; Size: Word);
var
  s,s1,s2: String;
  i: Integer;
  v_b: byte;
begin
  // topimy wyj¹tek
  s:='';
  try
    for i := 0 to Size - 1 do
    begin
      v_b:=byte(PChar(Data)[i]);
      if s<>'' then
        s:=s+' ';
      s:=s+IntToHex(v_b,2);
    end;
  except
  end;
  if Length(s)=Length(a_GuessString) then
  begin
    // porównujemy ci¹gi bajt po bajcie
    i:=1;
    while (i<=Length(s))and(a_GuessString[i]=s[i]) do
      Inc(i);
    // jest jakaœ ró¿nica
    if i<=Length(s) then
    begin
      s1:=s[i];
      s2:=a_GuessString[i];
      if (i=1)or(s[i-1]=' ') then
      begin
        s1:=s1+s[i+1];
        s2:=s2+a_GuessString[i+1];
      end;
      if (i=Length(s))or(s[i+1]=' ') then
      begin
        s1:=s[i-1]+s1;
        s2:=a_GuessString[i-1]+s2;
      end;
      v_b:=(StrToInt('$'+LowerCase(s1))xor StrToInt('$'+LowerCase(s2)));
      eIndex.Text:=IntToStr(i div 3);
      eMask.Text:=IntToHex(v_b,2);
    end;
  end;
  eTest.Text:='Click ? again to stop guessing.'+sLineBreak+
              'Reports:'+sLineBreak+s+sLineBreak+a_GuessString;
  a_GuessString:=s;
end;

procedure THIDMapping.MapListClick(Sender: TObject);
begin
  if (MapList.Items.Count > 0) and (MapList.ItemIndex >= 0) then
  begin
    eName.Text:=a_KeyMap[MapList.ItemIndex].name;
    eIndex.Text:=IntToStr(a_KeyMap[MapList.ItemIndex].index);
    eMask.Text:=IntToHex(a_KeyMap[MapList.ItemIndex].mask,2);
    cbType.Text:=a_KeyMap[MapList.ItemIndex].mtype;
    eValue.Text:=IntToHex(a_KeyMap[MapList.ItemIndex].value,2);
    eKeys.Text:=a_KeyMap[MapList.ItemIndex].keys;
  end;
end;

procedure THIDMapping.SendKeys(Keys: String);
var
  i: Integer;
  w: word;
  s: String;
  b: Boolean;
begin
  if (Length(Keys)>0) then
  begin
    s:=Keys;
    while Length(s)>0 do
    begin
      b:=False;
      for i := 1 to Length(CODE_TABLE) do
        if (not b)and(CODE_TABLE[i].name=copy(s,1,Length(CODE_TABLE[i].name))) then
        begin
          keybd_event(CODE_TABLE[i].code,0,0,0);
          keybd_event(CODE_TABLE[i].code,0,KEYEVENTF_KEYUP,0);
          s:=Copy(s,length(CODE_TABLE[i].name)+1,Length(s));
          b:=True;
        end;
      if not b then
      begin
        w:=VkKeyScan(s[1]);
        if Hi(w) and 1>0 then keybd_event(VK_SHIFT,0,0,0);
        if Hi(w) and 2>0 then keybd_event(VK_CONTROL,0,0,0);
        keybd_event(Lo(w),Hi(w),0,0);
        keybd_event(Lo(w),Hi(w),KEYEVENTF_KEYUP,0);
        if Hi(w) and 2>0 then keybd_event(VK_CONTROL,0,KEYEVENTF_KEYUP,0);
        if Hi(w) and 1>0 then keybd_event(VK_SHIFT,0,KEYEVENTF_KEYUP,0);
        s:=Copy(s,2,length(s)-1);
      end;
    end;
  end;
end;

procedure THIDMapping.SetGuessDevice(p_GuessDevice: TJvHidDevice);
begin
  if a_GuessDevice<>p_GuessDevice then
    a_GuessDevice:=p_GuessDevice;
  bbtGuess.Enabled:=(a_GuessDevice<>nil);
end;

procedure THIDMapping.SetMappingFromGUI(pIndex: Integer);
var
  i: Integer;
begin
  // wartoœæ domyœlna nazwy to numer mapowania
  if eName.Text='' then
    eName.Text:=IntToStr(pIndex+1);
  a_KeyMap[pIndex].name:=eName.Text;
  // wartoœæ domyœlna indeksu to 0
  if not TryStrToInt(eIndex.Text,a_KeyMap[pIndex].index) then
  begin
    eIndex.Text:='0';
    a_KeyMap[pIndex].index:=0;
  end;
  // wartoœæ domyœlna maski to 00
  if TryStrToInt('$'+LowerCase(eMask.Text),i) then
    a_KeyMap[pIndex].mask:=StrToInt('$'+LowerCase(eMask.Text))
  else
  begin
    eMask.Text:='00';
    a_KeyMap[pIndex].mask:=0;
  end;
  // poniewa¿ kontrolka nie pozwala na przypisanie pustej wartoœci
  // wiêc nie ma potrzeby ustawiania wartoœci domyœlnej
  a_KeyMap[pIndex].mtype:=cbType.Text[1];
  // wartoœci mo¿e nie byæ wcale ale jak jest to jeden bajt
  // zapisany heksadecymalnie
  if (eValue.Text<>'')and(TryStrToInt('$'+LowerCase(eValue.Text),i)) then
    a_KeyMap[pIndex].value:=StrToInt('$'+LowerCase(eValue.Text))
  else
  begin
    eValue.Text:='00';
    a_KeyMap[pIndex].value:=0;
  end;
  // klawisze wpisujemy takie jakie s¹
  a_KeyMap[pIndex].keys:=eKeys.Text;
end;

end.

program HIDMapper;

uses
  Forms,
  UHIDMapper in 'UHIDMapper.pas' {HIDM},
  UHIDMapping in 'UHIDMapping.pas' {HIDMapping},
  UAddProfile in 'UAddProfile.pas' {AddProfile};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'HID Mapper';
  Application.CreateForm(THIDM, HIDM);
  Application.CreateForm(THIDMapping, HIDMapping);
  Application.CreateForm(TAddProfile, AddProfile);
  Application.Run;
end.

program HIDMapper;

uses
  Forms,
  UHIDMapper in 'UHIDMapper.pas' {HIDM},
  UHIDMapping in 'UHIDMapping.pas' {HIDMapping};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(THIDM, HIDM);
  Application.CreateForm(THIDMapping, HIDMapping);
  Application.Run;
end.

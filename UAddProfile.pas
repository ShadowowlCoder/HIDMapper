unit UAddProfile;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TAddProfile = class(TForm)
    edProfileName: TEdit;
    Label1: TLabel;
    btOk: TButton;
    btCancel: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AddProfile: TAddProfile;

implementation

{$R *.dfm}

end.

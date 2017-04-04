unit uProgress;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls;

type
  TfrmProgress = class(TForm)
    lblDis: TLabel;
    pbDis: TProgressBar;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmProgress: TfrmProgress;

implementation

{$R *.dfm}

end.

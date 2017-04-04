unit uSplash;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls;

type
  TfrmSplash = class(TForm)
    img: TImage;
    lblCopy: TLabel;
    tmr: TTimer;
    lblVer: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure tmrTimer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function ShowSplash: Boolean;

implementation

uses uGlobal;

{$R *.dfm}

function ShowSplash: Boolean;
begin
  with TfrmSplash.Create(Application) do
    try
      Result := ShowModal() = mrOk;
    finally
      Free;
    end;
end;

{ TfrmSplash }

procedure TfrmSplash.FormCreate(Sender: TObject);
begin
  lblVer.Caption := 'v' + App.Version;
end;

procedure TfrmSplash.tmrTimer(Sender: TObject);
begin
  ModalResult := mrOk;
end;

end.

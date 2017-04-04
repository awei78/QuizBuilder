unit uEditTopic;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uBase, StdCtrls, Buttons, ExtCtrls;

type
  TfrmEditTopic = class(TfrmBase)
    meoTopic: TMemo;
  private
    { Private declarations }
    FMemo: TMemo;
  protected
    procedure ResetData; override;
  public
    { Public declarations }
  end;

function ShowEditTopic(AMemo: TMemo): Boolean;

implementation

{$R *.dfm}

function ShowEditTopic(AMemo: TMemo): Boolean;
begin
  with TfrmEditTopic.Create(Application.MainForm) do
  begin
    imgHelp.Visible := False;
    try
      FMemo := AMemo;
      meoTopic.Text := AMemo.Text;
      Result := ShowModal() = mrOk;
      if Result then AMemo.Text := meoTopic.Text;
    finally
      Free;
    end;
  end;

end;

{ TfrmEditTopic }

procedure TfrmEditTopic.ResetData;
begin
  inherited;
  meoTopic.Text := FMemo.Text;
end;

end.

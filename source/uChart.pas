unit uChart;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, uBase, StdCtrls, Buttons, ExtCtrls, TeEngine, Series,
  TeeProcs, Chart;

type
  TfrmChart = class(TfrmBase)
    chtQuiz: TChart;
    Series1: TPieSeries;
  private
    { Private declarations }
    FTreeView: TTreeView;
    procedure MakeChart;
  protected
    procedure InitData; override;
    procedure LoadData; override;
  public
    { Public declarations }
  end;

var
  frmChart: TfrmChart;

function ShowChart(ATreeView: TTreeView): Boolean;

implementation

uses Quiz;

{$R *.dfm}

function ShowChart(ATreeView: TTreeView): Boolean;
begin
  with TfrmChart.Create(Application.MainForm) do
  begin
    FTreeView := ATreeView;
    try
      InitData();
      LoadData();
      Result := ShowModal() = mrOk;
    finally
      Free;
    end;
  end;
end;

{ TfrmChart }

procedure TfrmChart.InitData;
begin
  QuizObj.ImageList.GetIcon(33, Icon);
  bvl.Visible := False;
  imgHelp.Visible := bvl.Visible;
  btnOk.Visible := bvl.Visible;
  btnReset.Visible := bvl.Visible;
  btnCancel.Visible :=bvl.Visible;
end;

procedure TfrmChart.LoadData;
begin
  MakeChart();
end;

procedure TfrmChart.MakeChart;
var
  Root: TTreeNode;
  i: Integer;
  sXValue: string;
begin
  Root := FTreeView.TopItem;
  chtQuiz.Series[0].Clear;
  chtQuiz.Title.Text.Text := QuizObj.QuizProp.QuizTopic + ' - 题型分布统计';

  for i := 0 to Root.Count - 1 do
  begin
    if Pos('[', Root.Item[i].Text) = 0 then
      sXValue := Root.Item[i].Text
    else sXValue := Copy(Root.Item[i].Text, 1, Pos('[', Root.Item[i].Text) - 1);
    chtQuiz.Series[0].Add(QuizObj.GetQuesCount(TQuesType(i)), sXValue);
  end;
end;

end.

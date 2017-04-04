{******
  �� Ԫ��uWord.pas
  �� �ߣ�������
  �� �ڣ�2008-3-3
  ˵ ��������Word�ĵ�
  �� �£�
******}

unit uWord;

interface

uses
  Windows, Messages, SysUtils, Classes, Variants, ComObj, Forms, Graphics, Quiz,
  WordXP, OfficeXP;

type
  //��ʾ������Ϣ֮�ص�����ԭ��
  TWord = class
  private
    FOwner: TPublish;
    FQuizObj: TQuizObj;
    FWordApp: OleVariant;
    FDocument: OleVariant;
    FRange: OleVariant;
    FTable: OleVariant;

    //д��Ϣ
    function BuildInfo: Boolean;
    //д����
    function BuildQues: Boolean;
    //����Word�ĵ�
    function BuildWord: Boolean;
  public
    constructor Create(AOwner: TPublish);
    destructor Destroy; override;

    function Execute: Boolean;
  end;

implementation

uses uGlobal;

{ TWord }

constructor TWord.Create(AOwner: TPublish);
begin
  FOwner := AOwner;
  FQuizObj := AOwner.QuizObj;
end;

destructor TWord.Destroy;
begin
  if not VarIsNull(FWordApp) then
  begin
    FWordApp.Quit;
    FWordApp := Unassigned;
  end;

  inherited Destroy;
end;

function TWord.BuildInfo: Boolean;
begin
  Result := True;
  if not FQuizObj.QuizProp.ShowInfo then
  begin
    with FQuizObj.QuizProp do
    begin
      FRange := FDocument.Range;
      //���
      if QuizID <> '' then
      begin
        FTable := FDocument.Tables.Add(FRange, 1, 2);
        FTable.Columns.Item(1).Width := 302;
        FTable.Columns.Item(2).Width := 124;
      end
      else FTable := FDocument.Tables.Add(FRange, 1, 1);
      //�߿�
      FTable.Borders.InsideLineStyle := wdLineStyleSingle;
      FTable.Borders.InsideColor := wdColorGray35;
      FTable.Borders.OutsideLineStyle := wdLineStyleSingle;
      FTable.Borders.OutsideColor := wdColorGray35;
      //����
      FRange := FTable.Cell(1, 1).Range;
      FRange.Bold := msoTrue;
      FRange.Text := QuizTopic;

      //ID
      if QuizID <> '' then
      begin
        FRange := FTable.Cell(1, 2).Range;
        FRange.Text := QuizID;
      end;
    end;

    Exit;
  end;

  //Cell��Row��Col���Ǵ�1, 1��ʼ��
  //Ĭ�Ͽ��Ϊ426����֪��ʲô��λ���ֺ�Ĭ��Ϊ10
  try
    with FQuizObj.QuizProp do
    begin
      FRange := FDocument.Range;
      //���
      if FileExists(QuizImage) then
      begin
        FTable := FDocument.Tables.Add(FRange, 1, 2);
        FTable.Columns.Item(1).Width := 302;
        FTable.Columns.Item(2).Width := 124;
      end
      else FTable := FDocument.Tables.Add(FRange, 1, 1);
      //�߿�
      FTable.Borders.InsideLineStyle := wdLineStyleSingle;
      FTable.Borders.InsideColor := wdColorGray35;
      FTable.Borders.OutsideLineStyle := wdLineStyleSingle;
      FTable.Borders.OutsideColor := wdColorGray35;
      //����
      FRange := FTable.Cell(1, 1).Range;
      FRange.Font.Name := 'Microsoft Sans Serif';
      FRange.Bold := msoTrue;
      FRange.Text := QuizTopic;
      //���
      FRange.InsertAfter(#13#10);
      FRange.InsertParagraphAfter;
      FRange := FRange.Paragraphs.Last.Range;
      FRange.Bold := False;
      if Trim(QuizInfo) <> '' then FRange.Text := '  ' + QuizInfo;
      //������
      if ShowName or ShowMail then
      begin
        //������ָ��һ�β��С���
        FRange := FTable.Cell(1, 1).Range;
        FRange.InsertAfter(#13#10 + #13#10);
        FRange.InsertParagraphAfter;
        FRange := FRange.Paragraphs.Last.Range;
        if ShowName and ShowMail then
          FRange.Text := '�ʺţ�__________________    �ʼ���__________________'
        else if ShowName then
          FRange.Text := '�˺ţ�____________________'
        else FRange.Text := '�ʼ���____________________';
      end;
      //ͼƬ
      if FileExists(QuizImage) and DealImage(QuizImage, 160, 120) then
        FTable.Cell(1, 2).Range.InlineShapes.AddPicture(App.TmpJpg, msoFalse, msoTrue);

      Result := True;
    end;
  except
    Result := False;
  end;
end;

function TWord.BuildQues: Boolean;
  function GetTypeImage(AType: TQuesType): Boolean;
  var
    bmp: TBitmap;
  begin
    Result := True;
    if FileExists(App.TmpPath + IntToStr(Ord(AType)) + '.bmp') then Exit;

    bmp := TBitmap.Create;
    try
      Result := FQuizObj.ImageList.GetBitmap(Ord(AType) + 8, bmp);
      if Result then bmp.SaveToFile(App.TmpPath + IntToStr(Ord(AType)) + '.bmp');
    finally
      bmp.Free;
    end;
  end;

type
  TArray = Array of Integer;

  function GetRndArray(ALength: Integer): TArray;
  var
    sCur: string;
    sl: TStrings;
  begin
    SetLength(Result, ALength);

    sl := TStringList.Create;
    try
      Randomize();
      while sl.Count < ALength do
      begin
        sCur := IntToStr(Random(ALength));
        if sl.IndexOf(sCur) = -1 then
        begin
          sl.Append(sCur);
          Result[sl.Count - 1] := StrToInt(sCur);
        end;
      end;
    finally
      sl.Free;
    end;
  end;

const
  ARR_SIGN: array[0..8] of string = ('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I');

var
  HasImage: Boolean;
  sCap, sAns: string;

  procedure DealQues(AQuesObj: TQuesBase; AIndex: Integer; AQuesIndex: string);
    procedure AddSignShape(AHotImage: OleVariant; AQuesHot: TQuesHot);
    const
      IMG_WIDTH = 377;
      IMG_HEIGHT = 189;
    var
      vSign: OleVariant;
      pic: TPicture;
      fFitScale, fScale, fLeft, fTop, fWidth, fHeight: Single;
      OffsetX, OffsetY: Integer;
    begin
      pic := TPicture.Create;
      try
        pic.LoadFromFile(AQuesHot.HotImage);
        if TQuesHot(AQuesObj).ImgFit then
        begin
          if (pic.Height / pic.Width) > IMG_HEIGHT / IMG_WIDTH then
            fFitScale := pic.Height / IMG_HEIGHT
          else fFitScale := pic.Width / IMG_WIDTH;

          OffsetX := Round(TQuesHot(AQuesObj).HotRect.Left * fFitScale);
          OffsetY := Round(TQuesHot(AQuesObj).HotRect.Top * fFitScale);
        end
        else
        begin
          fFitScale := 1;
          OffsetX := Round(TQuesHot(AQuesObj).HPos + TQuesHot(AQuesObj).HotRect.Left);
          OffsetY := Round(TQuesHot(AQuesObj).VPos + TQuesHot(AQuesObj).HotRect.Top);
        end;

        if (pic.Width > 320) or (pic.Height > 240) then
        begin
          //������Ҫ����...
          if (pic.Height / pic.Width) > 3 / 4 then
            fScale := 240 / pic.Height
          else fScale := 320 / pic.Width;
        end
        else fScale := 1;
        //����->��
        fScale := fScale * 3 / 4;   

        //��λ��
        fLeft := AHotImage.Range.Information[wdHorizontalPositionRelativeToPage] + OffsetX * fScale;
        fTop := AHotImage.Range.Information[wdVerticalPositionRelativeToPage] + OffsetY * fScale;
        fTop := fTop + 4;
        fWidth := AQuesHot.HotRect.Right * fFitScale * fScale;
        fHeight := AQuesHot.HotRect.Bottom * fFitScale * fScale;

        //��궨λ���˴����Խ�������ٵ�һҳ��ָʾͼ��λ�ô��������
        AHotImage.Select;
        //��ͼ��
        vSign := FDocument.Shapes.AddShape(msoShapeRectangle, fLeft, fTop, fWidth, fHeight);
        //vSign.Select;
        vSign.Fill.Visible := msoTrue;
        vSign.Fill.ForeColor.RGB := RGB(0, 0, 255);
        vSign.Fill.Transparency := 0.75;
        vSign.Line.Weight := 0.75;
        vSign.Line.DashStyle := msoLineDash;
        vSign.Line.Style := msoLineSingle;
        vSign.Line.ForeColor.RGB := RGB(255, 0, 0);
        vSign.Line.Visible := msoTrue;
        vSign.Line.Visible := msoTrue;
      finally
        pic.Free;
      end; 
    end;

  var
    j, AnsIndex: Integer;
    AddRow: Boolean;
    slMatch: TStrings;
    ArrRnd: TArray;
    QuesRange: OleVariant;
    QuesTable: OleVariant;
    HotImage: OleVariant;
  begin
    //��š���Ŀ��ͼƬ
    FTable.Cell(AIndex + 2, 1).Range.Text := AQuesIndex;
    //����ͼ
    if GetTypeImage(AQuesObj._Type) then
    begin
      FTable.Cell(AIndex + 2, 1).Range.InsertParagraphAfter;
      FTable.Cell(AIndex + 2, 1).Range.Paragraphs.Last.Range.InlineShapes.AddPicture(App.TmpPath + IntToStr(Ord(AQuesObj._Type)) + '.bmp', msoFalse, msoTrue);
    end;
    if AQuesObj._Type <> qtScene then
      FTable.Cell(AIndex + 2, 2).Range.Text := Trim(AQuesObj.Topic) + '  (' + FloatToStr(AQuesObj.Points) + FQuizObj.Player.Texts[5] + ')'
    else FTable.Cell(AIndex + 2, 2).Range.Text := Trim(AQuesObj.Topic);
    FTable.Cell(AIndex + 2, 2).Range.Font.Name := 'Microsoft Sans Serif';
    FTable.Cell(AIndex + 2, 2).Range.Font.Size := FQuizObj.QuizSet.FontSetT.Size - 1.5;
    if AQuesObj._Type <> qtScene then
      FTable.Cell(AIndex + 2, 2).Range.Font.Color := FQuizObj.QuizSet.FontSetT.Color
    else FTable.Cell(AIndex + 2, 2).Range.Font.Color := $000066FF;
    FTable.Cell(AIndex + 2, 2).Range.Bold := FQuizObj.QuizSet.FontSetT.Bold;
    if FileExists(AQuesObj.Image) and DealImage(AQuesObj.Image, 160, 120) then
    begin
      FTable.Cell(AIndex + 2, 3).Range.InlineShapes.AddPicture(App.TmpJpg, msoFalse, msoTrue);
      FTable.Cell(AIndex + 2, 3).Range.Paragraphs.Format.Alignment := wdAlignParagraphCenter;
    end;

    FTable.Cell(AIndex + 2, 2).Range.InsertParagraphAfter;
    QuesRange := FTable.Cell(AIndex + 2, 2).Range.Paragraphs.Last.Range;
    QuesRange.Bold := msoFalse;
    QuesRange.Font.Name := 'Microsoft Sans Serif';
    QuesRange.Font.Size := FQuizObj.QuizSet.FontSetA.Size - 1.5;
    if AQuesObj._Type <> qtScene then
      QuesRange.Font.Color := FQuizObj.QuizSet.FontSetA.Color
    else QuesRange.Font.Color := $000066FF;
    QuesRange.Font.Bold := FQuizObj.QuizSet.FontSetA.Bold;
    if AQuesObj._Type <> qtHotSpot then QuesRange.InsertAfter(#13#10);
    //��������Ҫ���
    if AQuesObj._Type in [qtJudge, qtSingle, qtMulti, qtMatch, qtSeque] then
      //���Ϊ260.2���ȼ�1�У�
      QuesTable := FTable.Cell(AIndex + 2, 2).Range.Tables.Add(QuesRange, 1, 2);

    AddRow := False;
    sCap := '��';
    sAns := '';
    //����ÿ��...
    case AQuesObj._Type of
      qtJudge, qtSingle, qtMulti:
      begin
        QuesTable.Columns.Item(1).Width := 20;
        if HasImage then
          QuesTable.Columns.Item(2).Width := 239
        else QuesTable.Columns.Item(2).Width := 363;

        //���
        SetLength(ArrRnd, 0);

        if FQuizObj.QuizProp.RndAnswer then
          ArrRnd := GetRndArray(TQuesObj(AQuesObj).Answers.Count);
        for j := 0 to TQuesObj(AQuesObj).Answers.Count - 1 do
        begin
          if FQuizObj.QuizProp.RndAnswer then
          begin
            if Trim(TQuesObj(AQuesObj).Answers.ValueFromIndex[ArrRnd[j]]) = '' then
              Continue;
          end
          else if Trim(TQuesObj(AQuesObj).Answers.ValueFromIndex[j]) = '' then Continue;

          if AddRow then QuesTable.Rows.Add;
          AddRow := True;
          if not FQuizObj.QuizProp.RndAnswer then
            AnsIndex := j
          else AnsIndex := ArrRnd[j];

          //�˶�Ϊ�Ϸ�ʽ��ģ��ؼ�ģ��
          (*if AQuesObj._Type <> qtMulti then
          begin
            if FQuizObj.Publish.ShowAnswer and (TQuesObj(AQuesObj).Answers.Names[AnsIndex] = 'True') then
              QuesTable.Cell(QuesTable.Rows.Count, 1).Range.Text := '��'
            else QuesTable.Cell(QuesTable.Rows.Count, 1).Range.Text := '��';
          end
          else
          begin
            if FQuizObj.Publish.ShowAnswer and (TQuesObj(AQuesObj).Answers.Names[AnsIndex] = 'True') then
              QuesTable.Cell(QuesTable.Rows.Count, 1).Range.Text := '��'
            else QuesTable.Cell(QuesTable.Rows.Count, 1).Range.Text := '��';
          end;*)
          //�˶Σ�Ϊ��ģʽ
          if FQuizObj.Publish.ShowAnswer and (TQuesObj(AQuesObj).Answers.Names[AnsIndex] = 'True') then
          begin
            if sAns = '' then
              sAns := ARR_SIGN[j]
            else sAns := sAns + '��' + ARR_SIGN[j];
          end;
          QuesTable.Cell(QuesTable.Rows.Count, 1).Range.Text := ARR_SIGN[j];

          if not AQuesObj.FeedAns then
            QuesTable.Cell(QuesTable.Rows.Count, 2).Range.Text := TQuesObj(AQuesObj).Answers.ValueFromIndex[AnsIndex]
          else if AQuesObj._Type = qtSingle then
            QuesTable.Cell(QuesTable.Rows.Count, 2).Range.Text := AQuesObj.GetAnswer(TQuesObj(AQuesObj).Answers.ValueFromIndex[AnsIndex]);
        end;
      end;
      qtBlank:
      begin
        QuesRange.Text := '________________________________';
        if FQuizObj.Publish.ShowAnswer then
        begin
          QuesRange.Text := QuesRange.Text + '';
          sCap := '�ɽ��ܴ�';
          for j := 0 to TQuesObj(AQuesObj).Answers.Count - 1 do
          begin
            if Trim(TQuesObj(AQuesObj).Answers[j]) = '' then Continue;

            if FQuizObj.Publish.ShowAnswer then
            begin
              if sAns = '' then
                sAns := TQuesObj(AQuesObj).Answers[j]
              else sAns := sAns + '|' + TQuesObj(AQuesObj).Answers[j];
            end;
          end;
        end;
      end;
      qtMatch:
      begin
        if HasImage then
        begin
          QuesTable.Columns.Item(1).Width := 129;
          QuesTable.Columns.Item(2).Width := 129;
        end
        else
        begin
          QuesTable.Columns.Item(1).Width := 191;
          QuesTable.Columns.Item(2).Width := 191;
        end;

        //��Ϊ�д𰸶�Ӧ��ϵ�������ر���һ��
        slMatch := TStringList.Create;
        try
          for j := 0 to TQuesObj(AQuesObj).Answers.Count - 1 do
          begin
            if Trim(TQuesObj(AQuesObj).Answers.ValueFromIndex[j]) = '' then Continue;
            slMatch.Append(TQuesObj(AQuesObj).Answers[j]);
          end;

          ArrRnd := GetRndArray(slMatch.Count);
          for j := 0 to slMatch.Count - 1 do
          begin
            if j > 0 then QuesTable.Rows.Add;
            QuesTable.Cell(QuesTable.Rows.Count, 1).Range.Text := StringReplace(slMatch.Names[j], '$+$', '=', [rfReplaceAll]);
            QuesTable.Cell(QuesTable.Rows.Count, 2).Range.Text := slMatch.ValueFromIndex[ArrRnd[j]];

            if FQuizObj.Publish.ShowAnswer then
            begin
              if sAns = '' then
                sAns := StringReplace(slMatch.Names[j], '$+$', '=', [rfReplaceAll]) + '->' + slMatch.ValueFromIndex[j]
              else sAns := sAns + '��' + StringReplace(slMatch.Names[j], '$+$', '=', [rfReplaceAll]) + '->' + slMatch.ValueFromIndex[j];
            end;
          end;
        finally
          slMatch.Free;
        end;
      end;
      qtSeque:
      begin
        QuesTable.Columns.Item(1).Width := 20;
        if HasImage then
          QuesTable.Columns.Item(2).Width := 239
        else QuesTable.Columns.Item(2).Width := 363;

        //���
        ArrRnd := GetRndArray(TQuesObj(AQuesObj).Answers.Count);
        for j := 0 to TQuesObj(AQuesObj).Answers.Count - 1 do
        begin
          if Trim(TQuesObj(AQuesObj).Answers[ArrRnd[j]]) = '' then Continue;

          if AddRow then QuesTable.Rows.Add;
          AddRow := True;
          QuesTable.Cell(QuesTable.Rows.Count, 1).Range.Text := IntToStr(j + 1);
          QuesTable.Cell(QuesTable.Rows.Count, 2).Range.Text := TQuesObj(AQuesObj).Answers[ArrRnd[j]];
          if FQuizObj.Publish.ShowAnswer then
          begin
            if sAns = '' then
              sAns := IntToStr(ArrRnd[j] + 1)
            else sAns := sAns + '��' + IntToStr(ArrRnd[j] + 1);
          end;
        end;
      end;
      qtHotSpot:
      begin
        if DealImage(TQuesHot(AQuesObj).HotImage, 320, 240) then
        begin
          HotImage := QuesRange.InlineShapes.AddPicture(App.TmpJpg, msoFalse, msoTrue);
          //��ʾ�𰸣��ر���
         if FQuizObj.Publish.ShowAnswer then
          begin
            AddSignShape(HotImage, TQuesHot(AQuesObj));

            sAns := 'ͼ�е���ɫ����';
          end;
        end;
      end;
      qtEssay:
      begin
        QuesRange.Text :=                  '_______________________________';
        QuesRange.Text := QuesRange.Text + '_______________________________';
        QuesRange.Text := QuesRange.Text + '_______________________________';
        QuesRange.Text := QuesRange.Text + '_______________________________';
        if FQuizObj.Publish.ShowAnswer then
        begin
          QuesRange.Text := QuesRange.Text + '';
          sCap := '�ο���';
          sAns := Trim(TQuesObj(AQuesObj).Answers.Text);
        end;
      end;
      qtScene:
        QuesRange.Text := Trim(TQuesObj(AQuesObj).Answers.Text);
    end;
    if FQuizObj.Publish.ShowAnswer and (AQuesObj._Type <> qtScene) then
    begin
      FTable.Cell(AIndex + 2, 2).Range.InsertParagraphAfter;
      QuesRange := FTable.Cell(AIndex + 2, 2).Range.Paragraphs.Last.Range;
      QuesRange.Bold := msoFalse;
      QuesRange.Font.Name := 'Microsoft Sans Serif';
      QuesRange.Font.Size := 11;
      QuesRange.Font.Color := wdColorGreen;
      QuesRange.Text := sCap + '��' + sAns;
    end;
  end;

var
  i, iCur, iQuesCount: Integer;
  sRndIds: string;
  QuesObj: TQuesBase;
begin
  Result := False;
  if FQuizObj.QuesList.Count = 0 then Exit;

  try
    //����
    FDocument.Range.InsertParagraphAfter;
    FRange := FDocument.Paragraphs.Last.Range;

    HasImage := False;
    with FQuizObj, FOwner do
    begin
      if QuizProp.RndQues.Enabled and (RndCount > 0) and (RndCount < (QuesList.Count - GetQuesCount(qtScene))) then
      begin
        sRndIds := FOwner.RndIds;
        iQuesCount := FOwner.RndCount;
        //�Ƿ��������ͼƬ
        for i := 0 to QuesList.Count - 1 do
        begin
          if Pos(Format(',%d,', [i]), sRndIds) = 0 then Continue;

          QuesObj := QuesList.Items[i];
          if FileExists(QuesObj.Image) then
          begin
            HasImage := True;
            Break;
          end;
        end;
      end
      else
      begin
        iQuesCount := QuesList.Count;

        //�Ƿ��������ͼƬ
        for i := 0 to QuesList.Count - 1 do
        begin
          QuesObj := QuesList.Items[i];
          if FileExists(QuesObj.Image) then
          begin
            HasImage := True;
            Break;
          end;
        end;
      end;
      
      if HasImage then
      begin
        FTable := FDocument.Tables.Add(FRange, iQuesCount + 1, 3);
        FTable.Columns.Item(1).Width := 32;
        FTable.Columns.Item(2).Width := 270;
        FTable.Columns.Item(3).Width := 124;
        FTable.Cell(1, 1).Range.Text := '���';
        FTable.Cell(1, 2).Range.Text := '����';
        FTable.Cell(1, 3).Range.Text := 'ͼƬ';
      end
      else
      begin
        FTable := FDocument.Tables.Add(FRange, iQuesCount + 1, 2);
        FTable.Columns.Item(1).Width := 32;
        FTable.Columns.Item(2).Width := 394;
        FTable.Cell(1, 1).Range.Text := '���';
        FTable.Cell(1, 2).Range.Text := '����';
      end;
      FTable.Rows.Item(1).Range.Bold := msoTrue;
      //�߿�
      FTable.Borders.InsideLineStyle := wdLineStyleSingle;
      FTable.Borders.InsideColor := wdColorGray35;
      FTable.Borders.OutsideLineStyle := wdLineStyleSingle;
      FTable.Borders.OutsideColor := wdColorGray35;
      //��һ�б���
      FTable.Rows.Item(1).Shading.BackgroundPatternColor := wdColorGray20;

      //�Ƿ���������Ҳ���������������������������ȫ��
      if QuizProp.RndQues.Enabled and (RndCount > 0) and (RndCount < (QuesList.Count - GetQuesCount(qtScene))) then
      begin
        iCur := 0;
        //ÿ��...
        for i := 0 to QuesList.Count - 1 do
        begin
          //ȡ��ת��
          if FOwner.Cancel then Abort;
          if Pos(Format(',%d,', [i]), sRndIds) = 0 then Continue;
          //����ָʾ
          if Assigned(FOwner.DisProgress) then FOwner.DisProgress(iCur + 1, FOwner.RndCount);
          DealQues(QuesList[i], iCur, IntToStr(iCur + 1));
          Inc(iCur);
        end;
      end
      else
      begin
        //Ϊ���������Ͷ�����
        iCur := 0;
        for i := 0 to QuesList.Count - 1 do
        begin
          //����ָʾ
          if Assigned(FOwner.DisProgress) then FOwner.DisProgress(i + 1, QuesList.Count);

          
          if FQuizObj.QuesList.Items[i]._Type <> qtScene then
          begin
            DealQues(FQuizObj.QuesList.Items[i], i, IntToStr(iCur + 1));
            Inc(iCur);
          end
          else DealQues(FQuizObj.QuesList.Items[i], i, '');
        end;
      end;
    end;

    Result := True;
  except
    Result := False;
  end;
end;

function TWord.BuildWord: Boolean;
var
  WordFile: OleVariant;
begin
  Result := False;
  if not BuildInfo then Exit;
  if not BuildQues then Exit;

  //����
  WordFile := FOwner.Folder + FOwner.Title + '.doc';
  with FQuizObj.QuizProp.PwdSet do
  begin
    if Enabled and (_Type = pstPwd) then
      FDocument.SaveAs(WordFile, wdFormatDocument, False, Password)
    else FDocument.SaveAs(WordFile);
  end;

  Result := True;
end;

function TWord.Execute: Boolean;
begin
  Result := False;
  try
    FWordApp := GetActiveOleObject('Word.Application');
  except
    try
      FWordApp := CreateOleObject('Word.Application');
    except
      MessageBox(FOwner.Handle, '����Word�ĵ�ʧ�ܣ����ļ�����ǰ�װMicrosoft Word����', '��ʾ', MB_OK + MB_ICONINFORMATION);
      FWordApp := Null;
      Exit;
    end;
  end;

  //�������й���
  FWordApp.Caption := FOwner.Title;
  FDocument := FWordApp.Documents.Add;
  //������Ϣ
  with FQuizObj.Player do
  begin
    FDocument.BuiltInDocumentProperties(wdPropertyAuthor) := AuthorSet.Name;
    FDocument.BuiltInDocumentProperties(wdPropertyCompany) := 'AWindSoft';
    FDocument.BuiltInDocumentProperties(wdPropertyComments) := AuthorSet.Des;
    FDocument.BuiltInDocumentProperties(wdPropertyHyperlinkBase) := AuthorSet.Url;
  end;
  FDocument.Saved := msoTrue;
  Result := BuildWord;
end;

end.

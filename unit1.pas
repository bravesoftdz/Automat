unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Grids,
  StdCtrls, ExtCtrls;

type

  MyStates = (U, T00, T01, T02, T03, T20, T10, T11, T31, T30, T21,
    C00, C01, C10, C11, T100, T110, T120, T130, T101, T111, T121, T131,
    S, S0, S00, S01, S000, S1, S10, S11);
  { TMainForm }

  TMainForm = class(TForm)
    StartAutomat: TButton;
    Pause: TButton;
    DrawGridStates: TDrawGrid;
    DrawGridState: TDrawGrid;
    ColCountLabel: TLabel;
    RowCountLabel: TLabel;
    LabelForState: TLabel;
    LabelForGeneration: TLabel;
    LabelForPopulation: TLabel;
    Start: TTimer;
    EnterColCountAndRowCount: TButton;
    DrawGridAutomat: TDrawGrid;
    EditForColCount: TEdit;
    EditForRowCount: TEdit;
    procedure StartAutomatClick(Sender: TObject);
    procedure PauseClick(Sender: TObject);
    procedure DrawGridAutomatDrawCell(Sender: TObject; aCol, aRow: integer;
      aRect: TRect; aState: TGridDrawState);
    procedure DrawGridAutomatMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure DrawGridStatesDrawCell(Sender: TObject; aCol, aRow: integer;
      aRect: TRect; aState: TGridDrawState);
    procedure DrawGridStatesMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure DrawGridStateDrawCell(Sender: TObject; aCol, aRow: integer;
      aRect: TRect; aState: TGridDrawState);
    procedure DrawGridStateMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure EditForColCountChange(Sender: TObject);
    procedure EditForColCountKeyPress(Sender: TObject; var Key: char);
    procedure EditForRowCountChange(Sender: TObject);
    procedure EditForRowCountKeyPress(Sender: TObject; var Key: char);
    procedure FormCreate(Sender: TObject);
    procedure StartTimer(Sender: TObject);
    procedure EnterColCountAndRowCountClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  MainForm: TMainForm;
  DrawGridStates: TDrawGrid;
  BitmapStates: array [1..29] of TBitmap;
  NumberState, CountGeneration: integer;
  Buf: TBitmap;
  aC, aR, aC1, aR1, x, y, i, j, CountPopulation: integer;
  Field: array [0..28, 0..28] of MyStates;
  Field2: array [0..28, 0..28] of MyStates;
  Field3: array [0..28, 0..28] of boolean;
  Field4: array [0..28, 0..28] of boolean;
  Field5: array [0..28, 0..28] of boolean;
  Picture: array [0..28, 0..28] of TBitmap;
  Transition, check, check2, check3, check4, check5, check6, check7,
  check8, check9: boolean;
  path: string;

implementation

{$R *.lfm}

{ TMainForm }

{****p* AutomatFonNeuman/FormCreate
* DESCRIPTION
* Процедура создания формы.
* Используется для предварительной загрузки картинок состояний в объект TBitmap для последующего их отображения в таблице "Состояния".
* SOURCE
*}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  path := ExtractFileDir(Application.ExeName);
  for NumberState := 1 to 29 do
  begin
    BitmapStates[NumberState] := TBitmap.Create;
    BitmapStates[NumberState].LoadFromFile(path + '\icons\' +
      IntToStr(NumberState) + '.bmp');
  end;
end;

{*****}

{****p* AutomatFonNeuman/StartTimer
* DESCRIPTION
* Процедура старта таймера.
* Используется для описания правил перехода между состояниями автомата.
* SOURCE
*}

procedure TMainForm.StartTimer(Sender: TObject);
var
  f, g: integer;
begin
  for f := 0 to x - 1 do
    for g := 0 to y - 1 do
    begin
      Field2[f, g] := Field[f, g];
    end;
  for f := 0 to x - 1 do
    for g := 0 to y - 1 do
    begin
      if (Field[f, g] = U) then
      begin
        if f <> 28 then
          if (Field[f + 1, g] = T21) then
          begin
            Field5[f, g] := True;
            Field2[f + 1, g] := T20;
            Picture[f + 1, g] := BitmapStates[3];
            Inc(CountPopulation);
          end;
        if f <> 28 then
          if (Field[f + 1, g] = T121) then
          begin
            Field5[f, g] := True;
            Field2[f + 1, g] := T120;
            Picture[f + 1, g] := BitmapStates[14];
            Inc(CountPopulation);
          end;
        if f <> 0 then
          if (Field[f - 1, g] = T01) then
          begin
            Field5[f, g] := True;
            Field2[f - 1, g] := T00;
            Picture[f - 1, g] := BitmapStates[5];
            Inc(CountPopulation);
          end;
        if f <> 0 then
          if (Field[f - 1, g] = T101) then
          begin
            Field5[f, g] := True;
            Field2[f - 1, g] := T100;
            Picture[f - 1, g] := BitmapStates[15];
            Inc(CountPopulation);
          end;
        if g <> 0 then
          if (Field[f, g - 1] = T31) then
          begin
            Field5[f, g] := True;
            Field2[f, g - 1] := T30;
            Picture[f, g - 1] := BitmapStates[1];
            Inc(CountPopulation);
          end;
        if g <> 0 then
          if (Field[f, g - 1] = T131) then
          begin
            Field5[f, g] := True;
            Field2[f, g - 1] := T130;
            Picture[f, g - 1] := BitmapStates[13];
            Inc(CountPopulation);
          end;
        if g <> 28 then
          if (Field[f, g + 1] = T11) then
          begin
            Field5[f, g] := True;
            Field2[f, g + 1] := T10;
            Picture[f, g + 1] := BitmapStates[7];
            Inc(CountPopulation);
          end;
        if g <> 28 then
          if (Field[f, g + 1] = T111) then
          begin
            Field5[f, g] := True;
            Field2[f, g + 1] := T110;
            Picture[f, g + 1] := BitmapStates[16];
            Inc(CountPopulation);
          end;
      end
      else
      if (Field[f, g] = S) then
      begin
        if f <> 0 then
          if (Field[f - 1, g] = T01) then
          begin
            check9 := True;
            Field5[f, g] := True;
            Field2[f - 1, g] := T00;
            Picture[f - 1, g] := BitmapStates[5];
          end;
        if f <> 0 then
          if (Field[f - 1, g] = T101) then
          begin
            check9 := True;
            Field5[f, g] := True;
            Field2[f - 1, g] := T100;
            Picture[f - 1, g] := BitmapStates[15];
          end;
        if (Field[f + 1, g] = T21) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f + 1, g] := T20;
          Picture[f + 1, g] := BitmapStates[3];
        end;
        if (Field[f + 1, g] = T121) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f + 1, g] := T120;
          Picture[f + 1, g] := BitmapStates[14];
        end;
        if g <> 0 then
          if (Field[f, g - 1] = T31) then
          begin
            check9 := True;
            Field5[f, g] := True;
            Field2[f, g - 1] := T30;
            Picture[f, g - 1] := BitmapStates[1];
          end;
        if g <> 0 then
          if (Field[f, g - 1] = T131) then
          begin
            check9 := True;
            Field5[f, g] := True;
            Field2[f, g - 1] := T130;
            Picture[f, g - 1] := BitmapStates[13];
          end;
        if (Field[f, g + 1] = T11) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f, g + 1] := T10;
          Picture[f, g + 1] := BitmapStates[7];
        end;
        if (Field[f, g + 1] = T111) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f, g + 1] := T110;
          Picture[f, g + 1] := BitmapStates[16];
        end;
        if (check9 = False) then
        begin
          Field2[f, g] := S0;
          Picture[f, g] := BitmapStates[23];
        end;
        check9 := False;
      end
      else
      if (Field[f, g] = S0) then
      begin
        if f <> 0 then
          if (Field[f - 1, g] = T01) then
          begin
            check9 := True;
            Field5[f, g] := True;
            Field2[f - 1, g] := T00;
            Picture[f - 1, g] := BitmapStates[5];
          end;
        if f <> 0 then
          if (Field[f - 1, g] = T101) then
          begin
            check9 := True;
            Field5[f, g] := True;
            Field2[f - 1, g] := T100;
            Picture[f - 1, g] := BitmapStates[15];
          end;
        if f <> 28 then
          if (Field[f + 1, g] = T21) then
          begin
            check9 := True;
            Field5[f, g] := True;
            Field2[f + 1, g] := T20;
            Picture[f + 1, g] := BitmapStates[3];
          end;
        if f <> 28 then
          if (Field[f + 1, g] = T121) then
          begin
            check9 := True;
            Field5[f, g] := True;
            Field2[f + 1, g] := T120;
            Picture[f + 1, g] := BitmapStates[14];
          end;
        if g <> 0 then
          if (Field[f, g - 1] = T31) then
          begin
            check9 := True;
            Field5[f, g] := True;
            Field2[f, g - 1] := T30;
            Picture[f, g - 1] := BitmapStates[1];
          end;
        if g <> 0 then
          if (Field[f, g - 1] = T131) then
          begin
            check9 := True;
            Field5[f, g] := True;
            Field2[f, g - 1] := T130;
            Picture[f, g - 1] := BitmapStates[13];
          end;
        if g <> 28 then
          if (Field[f, g + 1] = T11) then
          begin
            check9 := True;
            Field5[f, g] := True;
            Field2[f, g + 1] := T10;
            Picture[f, g + 1] := BitmapStates[7];
          end;
        if g <> 28 then
          if (Field[f, g + 1] = T111) then
          begin
            check9 := True;
            Field5[f, g] := True;
            Field2[f, g + 1] := T110;
            Picture[f, g + 1] := BitmapStates[16];
          end;
        if (check9 = False) then
        begin
          Field2[f, g] := S00;
          Picture[f, g] := BitmapStates[25];
        end;
        check9 := False;
      end
      else
      if (Field[f, g] = S00) then
      begin
        if (Field[f - 1, g] = T01) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f - 1, g] := T00;
          Picture[f - 1, g] := BitmapStates[5];
        end;
        if (Field[f - 1, g] = T101) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f - 1, g] := T100;
          Picture[f - 1, g] := BitmapStates[15];
        end;
        if (Field[f + 1, g] = T21) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f + 1, g] := T20;
          Picture[f + 1, g] := BitmapStates[3];
        end;
        if (Field[f + 1, g] = T121) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f + 1, g] := T120;
          Picture[f + 1, g] := BitmapStates[14];
        end;
        if (Field[f, g - 1] = T31) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f, g - 1] := T30;
          Picture[f, g - 1] := BitmapStates[1];
        end;
        if (Field[f, g - 1] = T131) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f, g - 1] := T130;
          Picture[f, g - 1] := BitmapStates[13];
        end;
        if (Field[f, g + 1] = T11) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f, g + 1] := T10;
          Picture[f, g + 1] := BitmapStates[7];
        end;
        if (Field[f, g + 1] = T111) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f, g + 1] := T110;
          Picture[f, g + 1] := BitmapStates[16];
        end;
        if (check9 = False) then
        begin
          Field2[f, g] := S000;
          Picture[f, g] := BitmapStates[29];
        end;
        check9 := False;
      end
      else
      if (Field[f, g] = S1) then
      begin
        if (Field[f - 1, g] = T01) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f - 1, g] := T00;
          Picture[f - 1, g] := BitmapStates[5];
        end;
        if (Field[f - 1, g] = T101) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f - 1, g] := T100;
          Picture[f - 1, g] := BitmapStates[15];
        end;
        if (Field[f + 1, g] = T21) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f + 1, g] := T20;
          Picture[f + 1, g] := BitmapStates[3];
        end;
        if (Field[f + 1, g] = T121) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f + 1, g] := T120;
          Picture[f + 1, g] := BitmapStates[14];
        end;
        if (Field[f, g - 1] = T31) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f, g - 1] := T30;
          Picture[f, g - 1] := BitmapStates[1];
        end;
        if (Field[f, g - 1] = T131) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f, g - 1] := T130;
          Picture[f, g - 1] := BitmapStates[13];
        end;
        if (Field[f, g + 1] = T11) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f, g + 1] := T10;
          Picture[f, g + 1] := BitmapStates[7];
        end;
        if (Field[f, g + 1] = T111) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f, g + 1] := T110;
          Picture[f, g + 1] := BitmapStates[16];
        end;
        if (check9 = False) then
        begin
          Field2[f, g] := S10;
          Picture[f, g] := BitmapStates[27];
        end;
        check9 := False;
      end
      else
      if (Field[f, g] = S000) then
      begin
        if (Field[f - 1, g] = T01) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f - 1, g] := T00;
          Picture[f - 1, g] := BitmapStates[5];
        end;
        if (Field[f - 1, g] = T101) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f - 1, g] := T100;
          Picture[f - 1, g] := BitmapStates[15];
        end;
        if (Field[f + 1, g] = T21) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f + 1, g] := T20;
          Picture[f + 1, g] := BitmapStates[3];
        end;
        if (Field[f + 1, g] = T121) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f + 1, g] := T120;
          Picture[f + 1, g] := BitmapStates[14];
        end;
        if (Field[f, g - 1] = T31) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f, g - 1] := T30;
          Picture[f, g - 1] := BitmapStates[1];
        end;
        if (Field[f, g - 1] = T131) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f, g - 1] := T130;
          Picture[f, g - 1] := BitmapStates[13];
        end;
        if (Field[f, g + 1] = T11) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f, g + 1] := T10;
          Picture[f, g + 1] := BitmapStates[7];
        end;
        if (Field[f, g + 1] = T111) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f, g + 1] := T110;
          Picture[f, g + 1] := BitmapStates[16];
        end;
        if (check9 = False) then
        begin
          Field2[f, g] := T00;
          Picture[f, g] := BitmapStates[5];
        end;
        check9 := False;
      end
      else
      if (Field[f, g] = S01) then
      begin
        if (Field[f - 1, g] = T01) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f - 1, g] := T00;
          Picture[f - 1, g] := BitmapStates[5];
        end;
        if (Field[f - 1, g] = T101) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f - 1, g] := T100;
          Picture[f - 1, g] := BitmapStates[15];
        end;
        if (Field[f + 1, g] = T21) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f + 1, g] := T20;
          Picture[f + 1, g] := BitmapStates[3];
        end;
        if (Field[f + 1, g] = T121) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f + 1, g] := T120;
          Picture[f + 1, g] := BitmapStates[14];
        end;
        if (Field[f, g - 1] = T31) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f, g - 1] := T30;
          Picture[f, g - 1] := BitmapStates[1];
        end;
        if (Field[f, g - 1] = T131) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f, g - 1] := T130;
          Picture[f, g - 1] := BitmapStates[13];
        end;
        if (Field[f, g + 1] = T11) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f, g + 1] := T10;
          Picture[f, g + 1] := BitmapStates[7];
        end;
        if (Field[f, g + 1] = T111) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f, g + 1] := T110;
          Picture[f, g + 1] := BitmapStates[16];
        end;
        if (check9 = False) then
        begin
          Field2[f, g] := T30;
          Picture[f, g] := BitmapStates[1];
        end;
        check9 := False;
      end
      else
      if (Field[f, g] = S10) then
      begin
        if (Field[f - 1, g] = T01) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f - 1, g] := T00;
          Picture[f - 1, g] := BitmapStates[5];
        end;
        if (Field[f - 1, g] = T101) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f - 1, g] := T100;
          Picture[f - 1, g] := BitmapStates[15];
        end;
        if (Field[f + 1, g] = T21) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f + 1, g] := T20;
          Picture[f + 1, g] := BitmapStates[3];
        end;
        if (Field[f + 1, g] = T121) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f + 1, g] := T120;
          Picture[f + 1, g] := BitmapStates[14];
        end;
        if (Field[f, g - 1] = T31) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f, g - 1] := T30;
          Picture[f, g - 1] := BitmapStates[1];
        end;
        if (Field[f, g - 1] = T131) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f, g - 1] := T130;
          Picture[f, g - 1] := BitmapStates[13];
        end;
        if (Field[f, g + 1] = T11) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f, g + 1] := T10;
          Picture[f, g + 1] := BitmapStates[7];
        end;
        if (Field[f, g + 1] = T111) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f, g + 1] := T110;
          Picture[f, g + 1] := BitmapStates[16];
        end;
        if (check9 = False) then
        begin
          Field2[f, g] := T110;
          Picture[f, g] := BitmapStates[16];
        end;
        check9 := False;
      end
      else
      if (Field[f, g] = S11) then
      begin
        if (Field[f - 1, g] = T01) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f - 1, g] := T00;
          Picture[f - 1, g] := BitmapStates[5];
        end;
        if (Field[f - 1, g] = T101) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f - 1, g] := T100;
          Picture[f - 1, g] := BitmapStates[15];
        end;
        if (Field[f + 1, g] = T21) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f + 1, g] := T20;
          Picture[f + 1, g] := BitmapStates[3];
        end;
        if (Field[f + 1, g] = T121) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f + 1, g] := T120;
          Picture[f + 1, g] := BitmapStates[14];
        end;
        if (Field[f, g - 1] = T31) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f, g - 1] := T30;
          Picture[f, g - 1] := BitmapStates[1];
        end;
        if (Field[f, g - 1] = T131) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f, g - 1] := T130;
          Picture[f, g - 1] := BitmapStates[13];
        end;
        if (Field[f, g + 1] = T11) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f, g + 1] := T10;
          Picture[f, g + 1] := BitmapStates[7];
        end;
        if (Field[f, g + 1] = T111) then
        begin
          check9 := True;
          Field5[f, g] := True;
          Field2[f, g + 1] := T110;
          Picture[f, g + 1] := BitmapStates[16];
        end;
        if (check9 = False) then
        begin
          Field2[f, g] := T130;
          Picture[f, g] := BitmapStates[13];
        end;
        check9 := False;
      end;
      if (Field[f, g] = C00) then
      begin
        if (Field[f, g - 1] = T131) then
        begin
          Field2[f, g] := U;
          Picture[f, g] := BitmapStates[21];
          Field2[f, g - 1] := T130;
          Picture[f, g - 1] := BitmapStates[13];
        end;
        if (Field[f, g + 1] = T111) then
        begin
          Field2[f, g] := U;
          Picture[f, g] := BitmapStates[21];
          Field2[f, g + 1] := T110;
          Picture[f, g + 1] := BitmapStates[16];
        end;
        if (Field[f + 1, g] = T121) then
        begin
          Field2[f, g] := U;
          Picture[f, g] := BitmapStates[21];
          Field2[f + 1, g] := T120;
          Picture[f + 1, g] := BitmapStates[14];
        end;
        if (Field[f - 1, g] = T101) then
        begin
          Field2[f, g] := U;
          Picture[f, g] := BitmapStates[21];
          Field2[f - 1, g] := T100;
          Picture[f - 1, g] := BitmapStates[15];
        end;
        if (Field[f, g + 1] = T10) and (Field[f, g - 1] = T31) then
        begin
          Field2[f, g - 1] := T30;
          Picture[f, g - 1] := BitmapStates[1];
        end
        else
        if (Field[f + 1, g] = T20) and (Field[f, g - 1] = T31) then
        begin
          Field2[f, g - 1] := T30;
          Picture[f, g - 1] := BitmapStates[1];
        end
        else
        if (Field[f - 1, g] = T00) and (Field[f, g - 1] = T31) then
        begin
          Field2[f, g - 1] := T30;
          Picture[f, g - 1] := BitmapStates[1];
        end
        else
        if (Field[f, g - 1] = T31) then
        begin
          Field2[f, g - 1] := T30;
          Picture[f, g - 1] := BitmapStates[1];
          check3 := True;
        end;
        if (Field[f, g + 1] = T10) and (Field[f + 1, g] = T21) then
        begin
          Field2[f + 1, g] := T20;
          Picture[f + 1, g] := BitmapStates[3];
        end
        else
        if (Field[f, g - 1] = T30) and (Field[f + 1, g] = T21) then
        begin
          Field2[f + 1, g] := T20;
          Picture[f + 1, g] := BitmapStates[3];
        end
        else
        if (Field[f - 1, g] = T00) and (Field[f + 1, g] = T21) then
        begin
          Field2[f + 1, g] := T20;
          Picture[f + 1, g] := BitmapStates[3];
        end
        else
        if (Field[f + 1, g] = T21) then
        begin
          Field2[f + 1, g] := T20;
          Picture[f + 1, g] := BitmapStates[3];
          check3 := True;
        end;
        if (Field[f - 1, g] = T01) and (Field[f, g + 1] = T10) then
        begin
          Field2[f - 1, g] := T00;
          Picture[f - 1, g] := BitmapStates[5];
        end
        else
        if (Field[f - 1, g] = T01) and (Field[f + 1, g] = T20) then
        begin
          Field2[f - 1, g] := T00;
          Picture[f - 1, g] := BitmapStates[5];
        end
        else
        if (Field[f - 1, g] = T01) and (Field[f, g - 1] = T30) then
        begin
          Field2[f - 1, g] := T00;
          Picture[f - 1, g] := BitmapStates[5];
        end
        else
        if (Field[f - 1, g] = T01) then
        begin
          Field2[f - 1, g] := T00;
          Picture[f - 1, g] := BitmapStates[5];
          check3 := True;
        end;
        if (Field[f, g + 1] = T11) and (Field[f + 1, g] = T20) then
        begin
          Field2[f, g + 1] := T10;
          Picture[f, g + 1] := BitmapStates[7];
        end
        else
        if (Field[f, g + 1] = T11) and (Field[f, g - 1] = T30) then
        begin
          Field2[f, g + 1] := T10;
          Picture[f, g + 1] := BitmapStates[7];
        end
        else
        if (Field[f, g + 1] = T11) and (Field[f - 1, g] = T00) then
        begin
          Field2[f, g + 1] := T10;
          Picture[f, g + 1] := BitmapStates[7];
        end
        else
        if (Field[f, g + 1] = T11) then
        begin
          Field2[f, g + 1] := T10;
          Picture[f, g + 1] := BitmapStates[7];
          check3 := True;
        end;
        if (check3 = True) then
        begin
          Field2[f, g] := C01;
          Picture[f, g] := BitmapStates[10];
          check3 := False;
        end;
      end
      else
      if (Field[f, g] = C01) then
      begin
        if (Field[f, g - 1] = T131) then
        begin
          check8 := True;
          Field2[f, g - 1] := T130;
          Picture[f, g - 1] := BitmapStates[13];
        end;
        if (Field[f, g + 1] = T111) then
        begin
          check8 := True;
          Field2[f, g + 1] := T110;
          Picture[f, g + 1] := BitmapStates[16];
        end;
        if (Field[f + 1, g] = T121) then
        begin
          check8 := True;
          Field2[f + 1, g] := T120;
          Picture[f + 1, g] := BitmapStates[14];
        end;
        if (Field[f - 1, g] = T101) then
        begin
          check8 := True;
          Field2[f - 1, g] := T100;
          Picture[f - 1, g] := BitmapStates[15];
        end;
        if (Field[f, g + 1] = T10) and (Field[f - 1, g] = T01) then
        begin
          Field2[f - 1, g] := T00;
          Picture[f - 1, g] := BitmapStates[5];
        end
        else
        if (Field[f + 1, g] = T20) and (Field[f - 1, g] = T01) then
        begin
          Field2[f - 1, g] := T00;
          Picture[f - 1, g] := BitmapStates[5];
        end
        else
        if (Field[f, g - 1] = T30) and (Field[f - 1, g] = T01) then
        begin
          Field2[f - 1, g] := T00;
          Picture[f - 1, g] := BitmapStates[5];
        end
        else
        if (Field[f - 1, g] = T01) then
        begin
          Field2[f - 1, g] := T00;
          Picture[f - 1, g] := BitmapStates[5];
          check4 := True;
        end;
        if (Field[f, g + 1] = T10) and (Field[f, g - 1] = T31) then
        begin
          Field2[f, g - 1] := T30;
          Picture[f, g - 1] := BitmapStates[1];
        end
        else
        if (Field[f + 1, g] = T20) and (Field[f, g - 1] = T31) then
        begin
          Field2[f, g - 1] := T30;
          Picture[f, g - 1] := BitmapStates[1];
        end
        else
        if (Field[f - 1, g] = T00) and (Field[f, g - 1] = T31) then
        begin
          Field2[f, g - 1] := T30;
          Picture[f, g - 1] := BitmapStates[1];
        end
        else
        if (Field[f, g - 1] = T31) then
        begin
          Field2[f, g - 1] := T30;
          Picture[f, g - 1] := BitmapStates[1];
          check4 := True;
        end;
        if (Field[f, g + 1] = T10) and (Field[f + 1, g] = T21) then
        begin
          Field2[f + 1, g] := T20;
          Picture[f + 1, g] := BitmapStates[3];
        end
        else
        if (Field[f, g - 1] = T30) and (Field[f + 1, g] = T21) then
        begin
          Field2[f + 1, g] := T20;
          Picture[f + 1, g] := BitmapStates[3];
        end
        else
        if (Field[f - 1, g] = T00) and (Field[f + 1, g] = T21) then
        begin
          Field2[f + 1, g] := T20;
          Picture[f + 1, g] := BitmapStates[3];
        end
        else
        if (Field[f + 1, g] = T21) then
        begin
          Field2[f + 1, g] := T20;
          Picture[f + 1, g] := BitmapStates[3];
          check4 := True;
        end;
        if (Field[f + 1, g] = T20) and (Field[f, g + 1] = T11) then
        begin
          Field2[f, g + 1] := T10;
          Picture[f, g + 1] := BitmapStates[7];
        end
        else
        if (Field[f, g - 1] = T30) and (Field[f, g + 1] = T11) then
        begin
          Field2[f, g + 1] := T10;
          Picture[f, g + 1] := BitmapStates[7];
        end
        else
        if (Field[f - 1, g] = T00) and (Field[f, g + 1] = T11) then
        begin
          Field2[f, g + 1] := T10;
          Picture[f, g + 1] := BitmapStates[7];
        end
        else
        if (Field[f, g + 1] = T11) then
        begin
          Field2[f, g + 1] := T10;
          Picture[f, g + 1] := BitmapStates[7];
          check4 := True;
        end;
        if (check4 = False) then
        begin
          Field2[f, g] := C10;
          Picture[f, g] := BitmapStates[11];
        end;
        if (check4 = True) then
        begin
          Field2[f, g] := C11;
          Picture[f, g] := BitmapStates[12];
          check4 := False;
        end;
        if (check8 = True) then
        begin
          Field2[f, g] := U;
          Picture[f, g] := BitmapStates[21];
          check8 := False;
        end;
      end
      else
      if (Field[f, g] = C10) then
      begin
        if (Field[f, g - 1] = T131) then
        begin
          Field2[f, g - 1] := T130;
          Picture[f, g - 1] := BitmapStates[13];
          check6 := True;
        end;
        if (Field[f, g + 1] = T111) then
        begin
          Field2[f, g + 1] := T110;
          Picture[f, g + 1] := BitmapStates[16];
          check6 := True;
        end;
        if (Field[f + 1, g] = T121) then
        begin
          Field2[f + 1, g] := T120;
          Picture[f + 1, g] := BitmapStates[14];
          check6 := True;
        end;
        if (Field[f - 1, g] = T101) then
        begin
          Field2[f - 1, g] := T100;
          Picture[f - 1, g] := BitmapStates[15];
          check6 := True;
        end;
        if (Field[f, g + 1] = T10) and (Field[f - 1, g] = T01) then
        begin
          Field2[f - 1, g] := T00;
          Picture[f - 1, g] := BitmapStates[5];
        end
        else
        if (Field[f + 1, g] = T20) and (Field[f - 1, g] = T01) then
        begin
          Field2[f - 1, g] := T00;
          Picture[f - 1, g] := BitmapStates[5];
        end
        else
        if (Field[f, g - 1] = T30) and (Field[f - 1, g] = T01) then
        begin
          Field2[f - 1, g] := T00;
          Picture[f - 1, g] := BitmapStates[5];
        end
        else
        if (Field[f - 1, g] = T01) then
        begin
          Field2[f - 1, g] := T00;
          Picture[f - 1, g] := BitmapStates[5];
          check5 := True;
        end;
        if (Field[f - 1, g] = T20) or (Field[f - 1, g] = T21) then
        begin
          Field3[f - 1, g] := True;
        end;
        if (Field[f - 1, g] = T10) or (Field[f - 1, g] = T11) then
        begin
          Field3[f - 1, g] := True;
        end;
        if (Field[f - 1, g] = T30) or (Field[f - 1, g] = T31) then
        begin
          Field3[f - 1, g] := True;
        end;
        if (Field[f - 1, g] = T120) or (Field[f - 1, g] = T121) then
        begin
          Field3[f - 1, g] := True;
        end;
        if (Field[f - 1, g] = T110) or (Field[f - 1, g] = T111) then
        begin
          Field3[f - 1, g] := True;
        end;
        if (Field[f - 1, g] = T130) or (Field[f - 1, g] = T131) then
        begin
          Field3[f - 1, g] := True;
        end;
        if (Field[f, g + 1] = T10) and (Field[f + 1, g] = T21) then
        begin
          Field2[f + 1, g] := T20;
          Picture[f + 1, g] := BitmapStates[3];
        end
        else
        if (Field[f, g - 1] = T30) and (Field[f + 1, g] = T21) then
        begin
          Field2[f + 1, g] := T20;
          Picture[f + 1, g] := BitmapStates[3];
        end
        else
        if (Field[f - 1, g] = T00) and (Field[f + 1, g] = T21) then
        begin
          Field2[f + 1, g] := T20;
          Picture[f + 1, g] := BitmapStates[3];
        end
        else
        if (Field[f + 1, g] = T21) then
        begin
          Field2[f + 1, g] := T20;
          Picture[f + 1, g] := BitmapStates[3];
          check5 := True;
        end;
        if (Field[f + 1, g] = T00) or (Field[f + 1, g] = T01) then
        begin
          Field3[f + 1, g] := True;
        end;
        if (Field[f + 1, g] = T10) or (Field[f + 1, g] = T11) then
        begin
          Field3[f + 1, g] := True;
        end;
        if (Field[f + 1, g] = T30) or (Field[f + 1, g] = T31) then
        begin
          Field3[f + 1, g] := True;
        end;
        if (Field[f + 1, g] = T100) or (Field[f + 1, g] = T101) then
        begin
          Field3[f + 1, g] := True;
        end;
        if (Field[f + 1, g] = T110) or (Field[f + 1, g] = T111) then
        begin
          Field3[f + 1, g] := True;
        end;
        if (Field[f + 1, g] = T130) or (Field[f + 1, g] = T131) then
        begin
          Field3[f + 1, g] := True;
        end;
        if (Field[f, g + 1] = T10) and (Field[f, g - 1] = T31) then
        begin
          Field2[f, g - 1] := T30;
          Picture[f, g - 1] := BitmapStates[1];
        end
        else
        if (Field[f + 1, g] = T20) and (Field[f, g - 1] = T31) then
        begin
          Field2[f, g - 1] := T30;
          Picture[f, g - 1] := BitmapStates[1];
        end
        else
        if (Field[f - 1, g] = T00) and (Field[f, g - 1] = T31) then
        begin
          Field2[f, g - 1] := T30;
          Picture[f, g - 1] := BitmapStates[1];
        end
        else
        if (Field[f, g - 1] = T31) then
        begin
          Field2[f, g - 1] := T30;
          Picture[f, g - 1] := BitmapStates[1];
          check5 := True;
        end;
        if (Field[f, g - 1] = T10) or (Field[f, g - 1] = T11) then
        begin
          Field3[f, g - 1] := True;
        end;
        if (Field[f, g - 1] = T20) or (Field[f, g - 1] = T21) then
        begin
          Field3[f, g - 1] := True;
        end;
        if (Field[f, g - 1] = T00) or (Field[f, g - 1] = T01) then
        begin
          Field3[f, g - 1] := True;
        end;
        if (Field[f, g - 1] = T110) or (Field[f, g - 1] = T111) then
        begin
          Field3[f, g - 1] := True;
        end;
        if (Field[f, g - 1] = T120) or (Field[f, g - 1] = T121) then
        begin
          Field3[f, g - 1] := True;
        end;
        if (Field[f, g - 1] = T100) or (Field[f, g - 1] = T101) then
        begin
          Field3[f, g - 1] := True;
        end;
        if (Field[f + 1, g] = T20) and (Field[f, g + 1] = T11) then
        begin
          Field2[f, g + 1] := T10;
          Picture[f, g + 1] := BitmapStates[7];
        end
        else
        if (Field[f, g - 1] = T30) and (Field[f, g + 1] = T11) then
        begin
          Field2[f, g + 1] := T10;
          Picture[f, g + 1] := BitmapStates[7];
        end
        else
        if (Field[f - 1, g] = T00) and (Field[f, g + 1] = T11) then
        begin
          Field2[f, g + 1] := T10;
          Picture[f, g + 1] := BitmapStates[7];
        end
        else
        if (Field[f, g + 1] = T11) then
        begin
          Field2[f, g + 1] := T10;
          Picture[f, g + 1] := BitmapStates[7];
          check5 := True;
        end;
        if (Field[f, g + 1] = T30) or (Field[f, g + 1] = T31) then
        begin
          Field3[f, g + 1] := True;
        end;
        if (Field[f, g + 1] = T20) or (Field[f, g + 1] = T21) then
        begin
          Field3[f, g + 1] := True;
        end;
        if (Field[f, g + 1] = T00) or (Field[f, g + 1] = T01) then
        begin
          Field3[f, g + 1] := True;
        end;
        if (Field[f, g + 1] = T130) or (Field[f, g + 1] = T131) then
        begin
          Field3[f, g + 1] := True;
        end;
        if (Field[f, g + 1] = T120) or (Field[f, g + 1] = T121) then
        begin
          Field3[f, g + 1] := True;
        end;
        if (Field[f, g + 1] = T100) or (Field[f, g + 1] = T101) then
        begin
          Field3[f, g + 1] := True;
        end;
        if (check5 = False) then
        begin
          Field2[f, g] := C00;
          Picture[f, g] := BitmapStates[9];
        end;
        if (check5 = True) then
        begin
          Field2[f, g] := C01;
          Picture[f, g] := BitmapStates[10];
          check5 := False;
        end;
        if (check6 = True) then
        begin
          Field2[f, g] := U;
          Picture[f, g] := BitmapStates[21];
          check6 := False;
        end;
      end
      else
      if (Field[f, g] = C11) then
      begin
        if (Field[f, g - 1] = T131) then
        begin
          Field2[f, g - 1] := T130;
          Picture[f, g - 1] := BitmapStates[13];
          check7 := True;
        end;
        if (Field[f, g + 1] = T111) then
        begin
          Field2[f, g + 1] := T110;
          Picture[f, g + 1] := BitmapStates[16];
          check7 := True;
        end;
        if (Field[f - 1, g] = T101) then
        begin
          Field2[f - 1, g] := T100;
          Picture[f - 1, g] := BitmapStates[15];
          check7 := True;
        end;
        if (Field[f + 1, g] = T121) then
        begin
          Field2[f + 1, g] := T120;
          Picture[f + 1, g] := BitmapStates[14];
          check7 := True;
        end;
        if (Field[f, g + 1] = T10) and (Field[f - 1, g] = T01) then
        begin
          Field2[f - 1, g] := T00;
          Picture[f - 1, g] := BitmapStates[5];
          Field2[f, g] := C10;
          Picture[f, g] := BitmapStates[11];
        end
        else
        if (Field[f + 1, g] = T20) and (Field[f - 1, g] = T01) then
        begin
          Field2[f - 1, g] := T00;
          Picture[f - 1, g] := BitmapStates[5];
          Field2[f, g] := C10;
          Picture[f, g] := BitmapStates[11];
        end
        else
        if (Field[f, g - 1] = T30) and (Field[f - 1, g] = T01) then
        begin
          Field2[f - 1, g] := T00;
          Picture[f - 1, g] := BitmapStates[5];
          Field2[f, g] := C10;
          Picture[f, g] := BitmapStates[11];
        end
        else
        if (Field[f - 1, g] = T01) then
        begin
          Field2[f - 1, g] := T00;
          Picture[f - 1, g] := BitmapStates[5];
          check := True;
        end;
        if (Field[f - 1, g] = T20) or (Field[f - 1, g] = T21) then
        begin
          Field3[f - 1, g] := True;
        end;
        if (Field[f - 1, g] = T10) or (Field[f - 1, g] = T11) then
        begin
          Field3[f - 1, g] := True;
        end;
        if (Field[f - 1, g] = T30) or (Field[f - 1, g] = T31) then
        begin
          Field3[f - 1, g] := True;
        end;
        if (Field[f - 1, g] = T120) or (Field[f - 1, g] = T121) then
        begin
          Field3[f - 1, g] := True;
        end;
        if (Field[f - 1, g] = T110) or (Field[f - 1, g] = T111) then
        begin
          Field3[f - 1, g] := True;
        end;
        if (Field[f - 1, g] = T130) or (Field[f - 1, g] = T131) then
        begin
          Field3[f - 1, g] := True;
        end;
        if (Field[f, g + 1] = T10) and (Field[f, g - 1] = T31) then
        begin
          Field2[f, g - 1] := T30;
          Picture[f, g - 1] := BitmapStates[1];
          Field2[f, g] := C10;
          Picture[f, g] := BitmapStates[11];
        end
        else
        if (Field[f + 1, g] = T20) and (Field[f, g - 1] = T31) then
        begin
          Field2[f, g - 1] := T30;
          Picture[f, g - 1] := BitmapStates[1];
          Field2[f, g] := C10;
          Picture[f, g] := BitmapStates[11];
        end
        else
        if (Field[f - 1, g] = T00) and (Field[f, g - 1] = T31) then
        begin
          Field2[f, g - 1] := T30;
          Picture[f, g - 1] := BitmapStates[1];
          Field2[f, g] := C10;
          Picture[f, g] := BitmapStates[11];
        end
        else
        if (Field[f, g - 1] = T31) then
        begin
          Field2[f, g - 1] := T30;
          Picture[f, g - 1] := BitmapStates[1];
          check := True;
        end;
        if (Field[f, g - 1] = T10) or (Field[f, g - 1] = T11) then
        begin
          Field3[f, g - 1] := True;
        end;
        if (Field[f, g - 1] = T20) or (Field[f, g - 1] = T21) then
        begin
          Field3[f, g - 1] := True;
        end;
        if (Field[f, g - 1] = T00) or (Field[f, g - 1] = T01) then
        begin
          Field3[f, g - 1] := True;
        end;
        if (Field[f, g - 1] = T110) or (Field[f, g - 1] = T111) then
        begin
          Field3[f, g - 1] := True;
        end;
        if (Field[f, g - 1] = T120) or (Field[f, g - 1] = T121) then
        begin
          Field3[f, g - 1] := True;
        end;
        if (Field[f, g - 1] = T100) or (Field[f, g - 1] = T101) then
        begin
          Field3[f, g - 1] := True;
        end;
        if (Field[f, g + 1] = T10) and (Field[f + 1, g] = T21) then
        begin
          Field2[f + 1, g] := T20;
          Picture[f + 1, g] := BitmapStates[3];
          Field2[f, g] := C10;
          Picture[f, g] := BitmapStates[11];
        end
        else
        if (Field[f, g - 1] = T30) and (Field[f + 1, g] = T21) then
        begin
          Field2[f + 1, g] := T20;
          Picture[f + 1, g] := BitmapStates[3];
          Field2[f, g] := C10;
          Picture[f, g] := BitmapStates[11];
        end
        else
        if (Field[f - 1, g] = T00) and (Field[f + 1, g] = T21) then
        begin
          Field2[f + 1, g] := T20;
          Picture[f + 1, g] := BitmapStates[3];
          Field2[f, g] := C10;
          Picture[f, g] := BitmapStates[11];
        end
        else
        if (Field[f + 1, g] = T21) then
        begin
          Field2[f + 1, g] := T20;
          Picture[f + 1, g] := BitmapStates[3];
          check := True;
        end;
        if (Field[f + 1, g] = T00) or (Field[f + 1, g] = T01) then
        begin
          Field3[f + 1, g] := True;
        end;
        if (Field[f + 1, g] = T10) or (Field[f + 1, g] = T11) then
        begin
          Field3[f + 1, g] := True;
        end;
        if (Field[f + 1, g] = T30) or (Field[f + 1, g] = T31) then
        begin
          Field3[f + 1, g] := True;
        end;
        if (Field[f + 1, g] = T100) or (Field[f + 1, g] = T101) then
        begin
          Field3[f + 1, g] := True;
        end;
        if (Field[f + 1, g] = T110) or (Field[f + 1, g] = T111) then
        begin
          Field3[f + 1, g] := True;
        end;
        if (Field[f + 1, g] = T130) or (Field[f + 1, g] = T131) then
        begin
          Field3[f + 1, g] := True;
        end;
        if (Field[f + 1, g] = T20) and (Field[f, g + 1] = T11) then
        begin
          Field2[f, g + 1] := T10;
          Picture[f, g + 1] := BitmapStates[7];
          Field2[f, g] := C10;
          Picture[f, g] := BitmapStates[11];
        end
        else
        if (Field[f, g - 1] = T30) and (Field[f, g + 1] = T11) then
        begin
          Field2[f, g + 1] := T10;
          Picture[f, g + 1] := BitmapStates[7];
          Field2[f, g] := C10;
          Picture[f, g] := BitmapStates[11];
        end
        else
        if (Field[f - 1, g] = T00) and (Field[f, g + 1] = T11) then
        begin
          Field2[f, g + 1] := T10;
          Picture[f, g + 1] := BitmapStates[7];
          Field2[f, g] := C10;
          Picture[f, g] := BitmapStates[11];
        end
        else
        if (Field[f, g + 1] = T11) then
        begin
          Field2[f, g + 1] := T10;
          Picture[f, g + 1] := BitmapStates[7];
          check := True;
        end;
        if (Field[f, g + 1] = T30) or (Field[f, g + 1] = T31) then
        begin
          Field3[f, g + 1] := True;
        end;
        if (Field[f, g + 1] = T00) or (Field[f, g + 1] = T01) then
        begin
          Field3[f, g + 1] := True;
        end;
        if (Field[f, g + 1] = T20) or (Field[f, g + 1] = T21) then
        begin
          Field3[f, g + 1] := True;
        end;
        if (Field[f, g + 1] = T130) or (Field[f, g + 1] = T131) then
        begin
          Field3[f, g + 1] := True;
        end;
        if (Field[f, g + 1] = T100) or (Field[f, g + 1] = T101) then
        begin
          Field3[f, g + 1] := True;
        end;
        if (Field[f, g + 1] = T120) or (Field[f, g + 1] = T121) then
        begin
          Field3[f, g + 1] := True;
        end;
        if (check2 = False) then
        begin
          Field2[f, g] := C10;
          Picture[f, g] := BitmapStates[11];
        end;
        if (check = True) then
        begin
          Field2[f, g] := C11;
          Picture[f, g] := BitmapStates[12];
          check := False;
          check2 := False;
        end;
        if (check7 = True) then
        begin
          Field2[f, g] := U;
          Picture[f, g] := BitmapStates[21];
          check7 := False;
        end;
      end;
      if (Field[f, g] = T11) and (Field[f, g - 1] = T10) or
        (Field[f, g] = T11) and (Field[f, g - 1] = T11) then
      begin
        Field3[f, g - 1] := True;
        Field2[f, g] := T10;
        Picture[f, g] := BitmapStates[7];
      end
      else
      if (Field[f, g] = T31) and (Field[f, g + 1] = T30) or
        (Field[f, g] = T31) and (Field[f, g + 1] = T31) then
      begin
        Field3[f, g + 1] := True;
        Field2[f, g] := T30;
        Picture[f, g] := BitmapStates[1];
      end
      else
      if (Field[f, g] = T01) and (Field[f + 1, g] = T00) or
        (Field[f, g] = T01) and (Field[f + 1, g] = T01) then
      begin
        Field3[f + 1, g] := True;
        Field2[f, g] := T00;
        Picture[f, g] := BitmapStates[5];
      end
      else
      if (Field[f, g] = T21) and (Field[f - 1, g] = T20) or
        (Field[f, g] = T21) and (Field[f - 1, g] = T21) then
      begin
        Field3[f - 1, g] := True;
        Field2[f, g] := T20;
        Picture[f, g] := BitmapStates[3];
      end
      else
      if (Field[f, g] = T01) and (Field[f + 1, g] = T10) or
        (Field[f, g] = T01) and (Field[f + 1, g] = T11) then
      begin
        Field3[f + 1, g] := True;
        Field2[f, g] := T00;
        Picture[f, g] := BitmapStates[5];
      end
      else
      if (Field[f, g] = T01) and (Field[f + 1, g] = T30) or
        (Field[f, g] = T01) and (Field[f + 1, g] = T31) then
      begin
        Field3[f + 1, g] := True;
        Field2[f, g] := T00;
        Picture[f, g] := BitmapStates[5];
      end
      else
      if (Field[f, g] = T21) and (Field[f - 1, g] = T10) or
        (Field[f, g] = T21) and (Field[f - 1, g] = T11) then
      begin
        Field3[f - 1, g] := True;
        Field2[f, g] := T20;
        Picture[f, g] := BitmapStates[3];
      end
      else
      if (Field[f, g] = T21) and (Field[f - 1, g] = T30) or
        (Field[f, g] = T21) and (Field[f - 1, g] = T31) then
      begin
        Field3[f - 1, g] := True;
        Field2[f, g] := T20;
        Picture[f, g] := BitmapStates[3];
      end
      else
      if (Field[f, g] = T11) and (Field[f, g - 1] = T20) or
        (Field[f, g] = T11) and (Field[f, g - 1] = T21) then
      begin
        Field3[f, g - 1] := True;
        Field2[f, g] := T10;
        Picture[f, g] := BitmapStates[7];
      end
      else
      if (Field[f, g] = T11) and (Field[f, g - 1] = T00) or
        (Field[f, g] = T11) and (Field[f, g - 1] = T01) then
      begin
        Field3[f, g - 1] := True;
        Field2[f, g] := T10;
        Picture[f, g] := BitmapStates[7];
      end
      else
      if (Field[f, g] = T31) and (Field[f, g + 1] = T00) or
        (Field[f, g] = T31) and (Field[f, g + 1] = T01) then
      begin
        Field3[f, g + 1] := True;
        Field2[f, g] := T30;
        Picture[f, g] := BitmapStates[1];
      end
      else
      if (Field[f, g] = T31) and (Field[f, g + 1] = T20) or
        (Field[f, g] = T31) and (Field[f, g + 1] = T21) then
      begin
        Field3[f, g + 1] := True;
        Field2[f, g] := T30;
        Picture[f, g] := BitmapStates[1];
      end
      else
      if (Field[f, g] = T31) and (Field[f, g + 1] = T10) then
      begin
        Field2[f, g] := T30;
        Picture[f, g] := BitmapStates[1];
      end
      else
      if (Field[f, g] = T11) and (Field[f, g - 1] = T30) then
      begin
        Field2[f, g] := T10;
        Picture[f, g] := BitmapStates[7];
      end
      else
      if (Field[f, g] = T31) and (Field[f, g + 1] = T11) then
      begin
        Field2[f, g] := T30;
        Picture[f, g] := BitmapStates[1];
        Field2[f, g + 1] := T10;
        Picture[f, g + 1] := BitmapStates[7];
      end
      else
      if (Field[f, g] = T21) and (Field[f - 1, g] = T01) then
      begin
        Field2[f, g] := T20;
        Picture[f, g] := BitmapStates[3];
        Field[f - 1, g] := T00;
        Picture[f - 1, g] := BitmapStates[5];
      end
      else
      if (Field[f, g] = T21) and (Field[f - 1, g] = T00) then
      begin
        Field2[f, g] := T20;
        Picture[f, g] := BitmapStates[3];
      end
      else
      if (Field[f, g] = T01) and (Field[f + 1, g] = T20) then
      begin
        Field2[f, g] := T00;
        Picture[f, g] := BitmapStates[5];
      end
      else
      if (Field[f, g] = T01) and (Field[f + 1, g] = T101) or
        (Field[f, g] = T01) and (Field[f + 1, g] = T111) or
        (Field[f, g] = T01) and (Field[f + 1, g] = T121) or (Field[f, g] = T01) and
        (Field[f + 1, g] = T131) then
      begin
        Field4[f + 1, g] := True;
        Field2[f, g] := T00;
        Picture[f, g] := BitmapStates[5];
      end
      else
      if (Field[f, g] = T21) and (Field[f - 1, g] = T101) or
        (Field[f, g] = T21) and (Field[f - 1, g] = T121) or
        (Field[f, g] = T21) and (Field[f - 1, g] = T111) or (Field[f, g] = T21) and
        (Field[f - 1, g] = T131) then
      begin
        Field4[f - 1, g] := True;
        Field2[f, g] := T20;
        Picture[f, g] := BitmapStates[3];
      end
      else
      if (Field[f, g] = T11) and (Field[f, g - 1] = T111) or
        (Field[f, g] = T11) and (Field[f, g - 1] = T101) or
        (Field[f, g] = T11) and (Field[f, g - 1] = T121) or (Field[f, g] = T11) and
        (Field[f, g - 1] = T131) then
      begin
        Field4[f, g - 1] := True;
        Field2[f, g] := T10;
        Picture[f, g] := BitmapStates[7];
      end
      else
      if (Field[f, g] = T31) and (Field[f, g + 1] = T131) or
        (Field[f, g] = T31) and (Field[f, g + 1] = T111) or
        (Field[f, g] = T31) and (Field[f, g + 1] = T101) or (Field[f, g] = T31) and
        (Field[f, g + 1] = T121) then
      begin
        Field4[f, g + 1] := True;
        Field2[f, g] := T30;
        Picture[f, g] := BitmapStates[1];
      end
      else
      if (Field[f, g] = T01) and (Field[f + 1, g] = T100) or
        (Field[f, g] = T01) and (Field[f + 1, g] = T110) or
        (Field[f, g] = T01) and (Field[f + 1, g] = T120) or (Field[f, g] = T01) and
        (Field[f + 1, g] = T130) then
      begin
        Field2[f + 1, g] := U;
        Picture[f + 1, g] := BitmapStates[21];
        Field2[f, g] := T00;
        Picture[f, g] := BitmapStates[5];
      end
      else
      if (Field[f, g] = T21) and (Field[f - 1, g] = T120) or
        (Field[f, g] = T21) and (Field[f - 1, g] = T100) or
        (Field[f, g] = T21) and (Field[f - 1, g] = T110) or (Field[f, g] = T21) and
        (Field[f - 1, g] = T130) then
      begin
        Field2[f - 1, g] := U;
        Picture[f - 1, g] := BitmapStates[21];
        Field2[f, g] := T20;
        Picture[f, g] := BitmapStates[3];
      end
      else
      if (Field[f, g] = T11) and (Field[f, g - 1] = T110) or
        (Field[f, g] = T11) and (Field[f, g - 1] = T100) or
        (Field[f, g] = T11) and (Field[f, g - 1] = T120) or (Field[f, g] = T11) and
        (Field[f, g - 1] = T130) then
      begin
        Field2[f, g - 1] := U;
        Picture[f, g - 1] := BitmapStates[21];
        Field2[f, g] := T10;
        Picture[f, g] := BitmapStates[7];
      end
      else
      if (Field[f, g] = T31) and (Field[f, g + 1] = T130) or
        (Field[f, g] = T31) and (Field[f, g + 1] = T110) or
        (Field[f, g] = T31) and (Field[f, g + 1] = T100) or (Field[f, g] = T31) and
        (Field[f, g + 1] = T120) then
      begin
        Field2[f, g + 1] := U;
        Picture[f, g + 1] := BitmapStates[21];
        Field2[f, g] := T30;
        Picture[f, g] := BitmapStates[1];
      end
      else
      if (Field[f, g] = T101) and (Field[f + 1, g] = T100) or
        (Field[f, g] = T101) and (Field[f + 1, g] = T101) then
      begin
        Field3[f + 1, g] := True;
        Field2[f, g] := T100;
        Picture[f, g] := BitmapStates[15];
      end
      else
      if (Field[f, g] = T101) and (Field[f + 1, g] = T110) or
        (Field[f, g] = T101) and (Field[f + 1, g] = T111) then
      begin
        Field3[f + 1, g] := True;
        Field2[f, g] := T100;
        Picture[f, g] := BitmapStates[15];
      end
      else
      if (Field[f, g] = T101) and (Field[f + 1, g] = T130) or
        (Field[f, g] = T101) and (Field[f + 1, g] = T131) then
      begin
        Field3[f + 1, g] := True;
        Field2[f, g] := T100;
        Picture[f, g] := BitmapStates[15];
      end
      else
      if (Field[f, g] = T121) and (Field[f - 1, g] = T120) or
        (Field[f, g] = T121) and (Field[f - 1, g] = T121) then
      begin
        Field3[f - 1, g] := True;
        Field2[f, g] := T120;
        Picture[f, g] := BitmapStates[14];
      end
      else
      if (Field[f, g] = T121) and (Field[f - 1, g] = T110) or
        (Field[f, g] = T121) and (Field[f - 1, g] = T111) then
      begin
        Field3[f - 1, g] := True;
        Field2[f, g] := T120;
        Picture[f, g] := BitmapStates[14];
      end
      else
      if (Field[f, g] = T121) and (Field[f - 1, g] = T130) or
        (Field[f, g] = T121) and (Field[f - 1, g] = T131) then
      begin
        Field3[f - 1, g] := True;
        Field2[f, g] := T120;
        Picture[f, g] := BitmapStates[14];
      end
      else
      if (Field[f, g] = T111) and (Field[f, g - 1] = T100) or
        (Field[f, g] = T111) and (Field[f, g - 1] = T101) then
      begin
        Field3[f, g - 1] := True;
        Field2[f, g] := T110;
        Picture[f, g] := BitmapStates[16];
      end
      else
      if (Field[f, g] = T111) and (Field[f, g - 1] = T120) or
        (Field[f, g] = T111) and (Field[f, g - 1] = T121) then
      begin
        Field3[f, g - 1] := True;
        Field2[f, g] := T110;
        Picture[f, g] := BitmapStates[16];
      end
      else
      if (Field[f, g] = T111) and (Field[f, g - 1] = T110) or
        (Field[f, g] = T111) and (Field[f, g - 1] = T111) then
      begin
        Field3[f, g - 1] := True;
        Field2[f, g] := T110;
        Picture[f, g] := BitmapStates[16];
      end
      else
      if (Field[f, g] = T131) and (Field[f, g + 1] = T130) or
        (Field[f, g] = T131) and (Field[f, g + 1] = T131) then
      begin
        Field3[f, g + 1] := True;
        Field2[f, g] := T130;
        Picture[f, g] := BitmapStates[13];
      end
      else
      if (Field[f, g] = T131) and (Field[f, g + 1] = T100) or
        (Field[f, g] = T131) and (Field[f, g + 1] = T101) then
      begin
        Field3[f, g + 1] := True;
        Field2[f, g] := T130;
        Picture[f, g] := BitmapStates[13];
      end
      else
      if (Field[f, g] = T131) and (Field[f, g + 1] = T120) or
        (Field[f, g] = T131) and (Field[f, g + 1] = T121) then
      begin
        Field3[f, g + 1] := True;
        Field2[f, g] := T130;
        Picture[f, g] := BitmapStates[13];
      end
      else
      if (Field[f, g] = T101) and (Field[f + 1, g] = T120) then
      begin
        Field2[f, g] := T100;
        Picture[f, g] := BitmapStates[15];
      end
      else
      if (Field[f, g] = T121) and (Field[f - 1, g] = T100) then
      begin
        Field2[f, g] := T120;
        Picture[f, g] := BitmapStates[14];
      end
      else
      if (Field[f, g] = T111) and (Field[f, g - 1] = T130) then
      begin
        Field2[f, g] := T110;
        Picture[f, g] := BitmapStates[16];
      end
      else
      if (Field[f, g] = T131) and (Field[f, g + 1] = T110) then
      begin
        Field2[f, g] := T130;
        Picture[f, g] := BitmapStates[13];
      end
      else
      if (Field[f, g] = T111) and (Field[f, g - 1] = T131) then
      begin
        Field2[f, g] := T110;
        Picture[f, g] := BitmapStates[16];
        Field2[f, g - 1] := T130;
        Picture[f, g - 1] := BitmapStates[13];
      end
      else
      if (Field[f, g] = T101) and (Field[f + 1, g] = T121) then
      begin
        Field2[f, g] := T100;
        Picture[f, g] := BitmapStates[15];
        Field2[f + 1, g] := T120;
        Picture[f + 1, g] := BitmapStates[14];
      end
      else
      if (Field[f, g] = T101) and (Field[f + 1, g] = T01) or
        (Field[f, g] = T101) and (Field[f + 1, g] = T11) or
        (Field[f, g] = T101) and (Field[f + 1, g] = T31) or (Field[f, g] = T101) and
        (Field[f + 1, g] = T21) then
      begin
        Field4[f + 1, g] := True;
        Field2[f, g] := T100;
        Picture[f, g] := BitmapStates[15];
      end
      else
      if (Field[f, g] = T131) and (Field[f, g + 1] = T01) or
        (Field[f, g] = T131) and (Field[f, g + 1] = T21) or
        (Field[f, g] = T131) and (Field[f, g + 1] = T11) or (Field[f, g] = T131) and
        (Field[f, g + 1] = T31) then
      begin
        Field4[f, g + 1] := True;
        Field2[f, g] := T130;
        Picture[f, g] := BitmapStates[13];
      end
      else
      if (Field[f, g] = T111) and (Field[f, g - 1] = T11) or
        (Field[f, g] = T111) and (Field[f, g - 1] = T01) or
        (Field[f, g] = T111) and (Field[f, g - 1] = T31) or (Field[f, g] = T111) and
        (Field[f, g - 1] = T21) then
      begin
        Field4[f, g - 1] := True;
        Field2[f, g] := T110;
        Picture[f, g] := BitmapStates[16];
      end
      else
      if (Field[f, g] = T121) and (Field[f - 1, g] = T21) or
        (Field[f, g] = T121) and (Field[f - 1, g] = T11) or
        (Field[f, g] = T121) and (Field[f - 1, g] = T31) or (Field[f, g] = T121) and
        (Field[f - 1, g] = T01) then
      begin
        Field4[f - 1, g] := True;
        Field2[f, g] := T120;
        Picture[f, g] := BitmapStates[14];
      end
      else
      if (Field[f, g] = T101) and (Field[f + 1, g] = T00) or
        (Field[f, g] = T101) and (Field[f + 1, g] = T10) or
        (Field[f, g] = T101) and (Field[f + 1, g] = T30) or (Field[f, g] = T101) and
        (Field[f + 1, g] = T20) then
      begin
        Field2[f + 1, g] := U;
        Picture[f + 1, g] := BitmapStates[21];
        Field2[f, g] := T100;
        Picture[f, g] := BitmapStates[15];
        Dec(CountPopulation);
      end
      else
      if (Field[f, g] = T131) and (Field[f, g + 1] = T00) or
        (Field[f, g] = T131) and (Field[f, g + 1] = T20) or
        (Field[f, g] = T131) and (Field[f, g + 1] = T10) or (Field[f, g] = T131) and
        (Field[f, g + 1] = T30) then
      begin
        Field2[f, g + 1] := U;
        Picture[f, g + 1] := BitmapStates[21];
        Field2[f, g] := T130;
        Picture[f, g] := BitmapStates[13];
        Dec(CountPopulation);
      end
      else
      if (Field[f, g] = T111) and (Field[f, g - 1] = T10) or
        (Field[f, g] = T111) and (Field[f, g - 1] = T00) or
        (Field[f, g] = T111) and (Field[f, g - 1] = T30) or (Field[f, g] = T111) and
        (Field[f, g - 1] = T20) then
      begin
        Field2[f, g - 1] := U;
        Picture[f, g - 1] := BitmapStates[21];
        Field2[f, g] := T110;
        Picture[f, g] := BitmapStates[16];
        Dec(CountPopulation);
      end
      else
      if (Field[f, g] = T121) and (Field[f - 1, g] = T20) or
        (Field[f, g] = T121) and (Field[f - 1, g] = T10) or
        (Field[f, g] = T121) and (Field[f - 1, g] = T30) or (Field[f, g] = T121) and
        (Field[f - 1, g] = T00) then
      begin
        Field2[f - 1, g] := U;
        Picture[f - 1, g] := BitmapStates[21];
        Field[f, g] := T120;
        Picture[f, g] := BitmapStates[14];
        Dec(CountPopulation);
      end;
    end;
  for f := 0 to x - 1 do
    for g := 0 to y - 1 do
    begin
      Field[f, g] := Field2[f, g];
    end;
  for f := 0 to x - 1 do
    for g := 0 to y - 1 do
    begin
      if (Field3[f, g] = True) then
      begin
        if (Field[f, g] = T00) then
        begin
          Field[f, g] := T01;
          Picture[f, g] := BitmapStates[6];
        end;
        if (Field[f, g] = T30) then
        begin
          Field[f, g] := T31;
          Picture[f, g] := BitmapStates[2];
        end;
        if (Field[f, g] = T10) then
        begin
          Field[f, g] := T11;
          Picture[f, g] := BitmapStates[8];
        end;
        if (Field[f, g] = T20) then
        begin
          Field[f, g] := T21;
          Picture[f, g] := BitmapStates[4];
        end;
        if (Field[f, g] = T100) then
        begin
          Field[f, g] := T101;
          Picture[f, g] := BitmapStates[19];
        end;
        if (Field[f, g] = T110) then
        begin
          Field[f, g] := T111;
          Picture[f, g] := BitmapStates[20];
        end;
        if (Field[f, g] = T130) then
        begin
          Field[f, g] := T131;
          Picture[f, g] := BitmapStates[17];
        end;
        if (Field[f, g] = T120) then
        begin
          Field[f, g] := T121;
          Picture[f, g] := BitmapStates[18];
        end;
      end;
      Field3[f, g] := False;
    end;
  for f := 0 to x - 1 do
    for g := 0 to y - 1 do
    begin
      if (Field4[f, g] = True) then
      begin
        if (Field[f, g] = T00) or (Field[f, g] = T10) or (Field[f, g] = T30) or
          (Field[f, g] = T20) then
        begin
          Field[f, g] := U;
          Picture[f, g] := BitmapStates[21];
        end;
        if (Field[f, g] = T100) or (Field[f, g] = T110) or (Field[f, g] = T120) or
          (Field[f, g] = T130) then
        begin
          Field[f, g] := U;
          Picture[f, g] := BitmapStates[21];
        end;
      end;
      Field4[f, g] := False;
    end;
  for f := 0 to x - 1 do
    for g := 0 to y - 1 do
    begin
      if (Field5[f, g] = True) then
      begin
        if (Field[f, g] = U) then
        begin
          Field[f, g] := S;
          Picture[f, g] := BitmapStates[22];
        end
        else
        if (Field[f, g] = S) then
        begin
          Field[f, g] := S1;
          Picture[f, g] := BitmapStates[24];
        end
        else
        if (Field[f, g] = S000) then
        begin
          Field[f, g] := T10;
          Picture[f, g] := BitmapStates[7];
        end
        else
        if (Field[f, g] = S00) then
        begin
          Field[f, g] := T20;
          Picture[f, g] := BitmapStates[3];
        end
        else
        if (Field[f, g] = S0) then
        begin
          Field[f, g] := S01;
          Picture[f, g] := BitmapStates[26];
        end
        else
        if (Field[f, g] = S01) then
        begin
          Field[f, g] := T100;
          Picture[f, g] := BitmapStates[15];
        end
        else
        if (Field[f, g] = S1) then
        begin
          Field[f, g] := S11;
          Picture[f, g] := BitmapStates[28];
        end
        else
        if (Field[f, g] = S10) then
        begin
          Field[f, g] := T120;
          Picture[f, g] := BitmapStates[14];
        end
        else
        if (Field[f, g] = S11) then
        begin
          Field[f, g] := C00;
          Picture[f, g] := BitmapStates[9];
        end;
      end;
      Field5[f, g] := False;
    end;
  DrawGridAutomat.Invalidate;
  Inc(CountGeneration);
  LabelForGeneration.Caption := 'Поколение = ' + IntToStr(CountGeneration);
  LabelForPopulation.Caption := 'Население = ' + IntToStr(CountPopulation);
end;

{*****}

{****p* AutomatFonNeuman/DrawGridStatesDrawCell
* DESCRIPTION
* Процедура отрисовки состояний.
* Используется для отрисовки состояний в таблице "Состояния".
* SOURCE
*}

procedure TMainForm.DrawGridStatesDrawCell(Sender: TObject; aCol, aRow: integer;
  aRect: TRect; aState: TGridDrawState);
begin
  DrawGridStates.Canvas.Draw(5, 5, BitmapStates[1]);
  DrawGridStates.Canvas.Draw(5, 35, BitmapStates[2]);
  DrawGridStates.Canvas.Draw(5, 65, BitmapStates[3]);
  DrawGridStates.Canvas.Draw(5, 95, BitmapStates[4]);
  DrawGridStates.Canvas.Draw(35, 5, BitmapStates[5]);
  DrawGridStates.Canvas.Draw(35, 35, BitmapStates[6]);
  DrawGridStates.Canvas.Draw(35, 65, BitmapStates[7]);
  DrawGridStates.Canvas.Draw(35, 95, BitmapStates[8]);
  DrawGridStates.Canvas.Draw(65, 5, BitmapStates[9]);
  DrawGridStates.Canvas.Draw(65, 35, BitmapStates[10]);
  DrawGridStates.Canvas.Draw(65, 65, BitmapStates[11]);
  DrawGridStates.Canvas.Draw(65, 95, BitmapStates[12]);
  DrawGridStates.Canvas.Draw(95, 5, BitmapStates[13]);
  DrawGridStates.Canvas.Draw(95, 35, BitmapStates[14]);
  DrawGridStates.Canvas.Draw(95, 65, BitmapStates[15]);
  DrawGridStates.Canvas.Draw(95, 95, BitmapStates[16]);
  DrawGridStates.Canvas.Draw(125, 5, BitmapStates[17]);
  DrawGridStates.Canvas.Draw(125, 35, BitmapStates[18]);
  DrawGridStates.Canvas.Draw(125, 65, BitmapStates[19]);
  DrawGridStates.Canvas.Draw(125, 95, BitmapStates[20]);
  DrawGridStates.Canvas.Draw(155, 5, BitmapStates[21]);
  DrawGridStates.Canvas.Draw(155, 35, BitmapStates[22]);
  DrawGridStates.Canvas.Draw(155, 65, BitmapStates[23]);
  DrawGridStates.Canvas.Draw(155, 95, BitmapStates[24]);
  DrawGridStates.Canvas.Draw(185, 5, BitmapStates[25]);
  DrawGridStates.Canvas.Draw(185, 35, BitmapStates[26]);
  DrawGridStates.Canvas.Draw(185, 65, BitmapStates[27]);
  DrawGridStates.Canvas.Draw(185, 95, BitmapStates[28]);
end;

{*****}

{****p* AutomatFonNeuman/DrawGridAutomatMouseUp
* DESCRIPTION
* Процедура заполнения клетки состоянием.
* Используется для того, чтобы после нажатия на определенную клетку на поле переместить туда выбранное состояние из таблицы "Состояния".
* SOURCE
*}

procedure TMainForm.DrawGridAutomatMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
begin
  if (Transition = True) then
  begin
    DrawGridAutomat.MouseToCell(X, Y, aC1, aR1);
    Picture[aC1, aR1] := Buf;
    if (Buf = BitmapStates[1]) then
    begin
      if (Field[aC1, aR1] <> U) then
        Field[aC1, aR1] := T30
      else
      begin
        Field[aC1, aR1] := T30;
        Inc(CountPopulation);
      end;
    end
    else
    if (Buf = BitmapStates[5]) then
    begin
      if (Field[aC1, aR1] <> U) then
        Field[aC1, aR1] := T00
      else
      begin
        Field[aC1, aR1] := T00;
        Inc(CountPopulation);
      end;
    end
    else
    if (Buf = BitmapStates[7]) then
    begin
      if (Field[aC1, aR1] <> U) then
        Field[aC1, aR1] := T10
      else
      begin
        Field[aC1, aR1] := T10;
        Inc(CountPopulation);
      end;
    end
    else
    if (Buf = BitmapStates[8]) then
    begin
      if (Field[aC1, aR1] <> U) then
        Field[aC1, aR1] := T11
      else
      begin
        Field[aC1, aR1] := T11;
        Inc(CountPopulation);
      end;
    end
    else
    if (Buf = BitmapStates[2]) then
    begin
      if (Field[aC1, aR1] <> U) then
        Field[aC1, aR1] := T31
      else
      begin
        Field[aC1, aR1] := T31;
        Inc(CountPopulation);
      end;
    end
    else
    if (Buf = BitmapStates[6]) then
    begin
      if (Field[aC1, aR1] <> U) then
        Field[aC1, aR1] := T01
      else
      begin
        Field[aC1, aR1] := T01;
        Inc(CountPopulation);
      end;
    end
    else
    if (Buf = BitmapStates[3]) then
    begin
      if (Field[aC1, aR1] <> U) then
        Field[aC1, aR1] := T20
      else
      begin
        Field[aC1, aR1] := T20;
        Inc(CountPopulation);
      end;
    end
    else
    if (Buf = BitmapStates[4]) then
    begin
      if (Field[aC1, aR1] <> U) then
        Field[aC1, aR1] := T21
      else
      begin
        Field[aC1, aR1] := T21;
        Inc(CountPopulation);
      end;
    end
    else
    if (Buf = BitmapStates[9]) then
    begin
      if (Field[aC1, aR1] <> U) then
        Field[aC1, aR1] := C00
      else
      begin
        Field[aC1, aR1] := C00;
        Inc(CountPopulation);
      end;
    end
    else
    if (Buf = BitmapStates[10]) then
    begin
      if (Field[aC1, aR1] <> U) then
        Field[aC1, aR1] := C01
      else
      begin
        Field[aC1, aR1] := C01;
        Inc(CountPopulation);
      end;
    end
    else
    if (Buf = BitmapStates[11]) then
    begin
      if (Field[aC1, aR1] <> U) then
        Field[aC1, aR1] := C10
      else
      begin
        Field[aC1, aR1] := C10;
        Inc(CountPopulation);
      end;
    end
    else
    if (Buf = BitmapStates[12]) then
    begin
      if (Field[aC1, aR1] <> U) then
        Field[aC1, aR1] := C11
      else
      begin
        Field[aC1, aR1] := C11;
        Inc(CountPopulation);
      end;
    end
    else
    if (Buf = BitmapStates[13]) then
    begin
      if (Field[aC1, aR1] <> U) then
        Field[aC1, aR1] := T130
      else
      begin
        Field[aC1, aR1] := T130;
        Inc(CountPopulation);
      end;
    end
    else
    if (Buf = BitmapStates[14]) then
    begin
      if (Field[aC1, aR1] <> U) then
        Field[aC1, aR1] := T120
      else
      begin
        Field[aC1, aR1] := T120;
        Inc(CountPopulation);
      end;
    end
    else
    if (Buf = BitmapStates[15]) then
    begin
      if (Field[aC1, aR1] <> U) then
        Field[aC1, aR1] := T100
      else
      begin
        Field[aC1, aR1] := T100;
        Inc(CountPopulation);
      end;
    end
    else
    if (Buf = BitmapStates[16]) then
    begin
      if (Field[aC1, aR1] <> U) then
        Field[aC1, aR1] := T110
      else
      begin
        Field[aC1, aR1] := T110;
        Inc(CountPopulation);
      end;
    end
    else
    if (Buf = BitmapStates[17]) then
    begin
      if (Field[aC1, aR1] <> U) then
        Field[aC1, aR1] := T131
      else
      begin
        Field[aC1, aR1] := T131;
        Inc(CountPopulation);
      end;
    end
    else
    if (Buf = BitmapStates[18]) then
    begin
      if (Field[aC1, aR1] <> U) then
        Field[aC1, aR1] := T121
      else
      begin
        Field[aC1, aR1] := T121;
        Inc(CountPopulation);
      end;
    end
    else
    if (Buf = BitmapStates[19]) then
    begin
      if (Field[aC1, aR1] <> U) then
        Field[aC1, aR1] := T101
      else
      begin
        Field[aC1, aR1] := T101;
        Inc(CountPopulation);
      end;
    end
    else
    if (Buf = BitmapStates[20]) then
    begin
      if (Field[aC1, aR1] <> U) then
        Field[aC1, aR1] := T111
      else
      begin
        Field[aC1, aR1] := T111;
        Inc(CountPopulation);
      end;
    end
    else
    if (Buf = BitmapStates[21]) then
    begin
      if (Field[aC1, aR1] <> U) then
      begin
        Dec(CountPopulation);
      end;
      Field[aC1, aR1] := U;
    end
    else
    if (Buf = BitmapStates[22]) then
    begin
      if (Field[aC1, aR1] <> U) then
        Field[aC1, aR1] := S
      else
      begin
        Field[aC1, aR1] := S;
        Inc(CountPopulation);
      end;
    end
    else
    if (Buf = BitmapStates[23]) then
    begin
      if (Field[aC1, aR1] <> U) then
        Field[aC1, aR1] := S0
      else
      begin
        Field[aC1, aR1] := S0;
        Inc(CountPopulation);
      end;
    end
    else
    if (Buf = BitmapStates[24]) then
    begin
      if (Field[aC1, aR1] <> U) then
        Field[aC1, aR1] := S1
      else
      begin
        Field[aC1, aR1] := S1;
        Inc(CountPopulation);
      end;
    end
    else
    if (Buf = BitmapStates[25]) then
    begin
      if (Field[aC1, aR1] <> U) then
        Field[aC1, aR1] := S00
      else
      begin
        Field[aC1, aR1] := S00;
        Inc(CountPopulation);
      end;
    end
    else
    if (Buf = BitmapStates[26]) then
    begin
      if (Field[aC1, aR1] <> U) then
        Field[aC1, aR1] := S01
      else
      begin
        Field[aC1, aR1] := S01;
        Inc(CountPopulation);
      end;
    end
    else
    if (Buf = BitmapStates[27]) then
    begin
      if (Field[aC1, aR1] <> U) then
        Field[aC1, aR1] := S10
      else
      begin
        Field[aC1, aR1] := S10;
        Inc(CountPopulation);
      end;
    end
    else
    if (Buf = BitmapStates[28]) then
    begin
      if (Field[aC1, aR1] <> U) then
        Field[aC1, aR1] := S11
      else
      begin
        Field[aC1, aR1] := S11;
        Inc(CountPopulation);
      end;
    end
    else
    if (Buf = BitmapStates[29]) then
    begin
      if (Field[aC1, aR1] <> U) then
        Field[aC1, aR1] := S000
      else
      begin
        Field[aC1, aR1] := S000;
        Inc(CountPopulation);
      end;
    end;
    Transition := False;
    LabelForPopulation.Caption := 'Население = ' + IntToStr(CountPopulation);
  end;
end;

{*****}

{****p* AutomatFonNeuman/DrawGridAutomatDrawCell
* DESCRIPTION
* Процедура заполнения клетки состоянием.
* Используется для того, чтобы после нажатия на определенную клетку на поле переместить туда выбранное состояние из таблицы "Состояния".
* SOURCE
*}

procedure TMainForm.DrawGridAutomatDrawCell(Sender: TObject;
  aCol, aRow: integer; aRect: TRect; aState: TGridDrawState);
begin
  DrawGridAutomat.Canvas.StretchDraw(MainForm.DrawGridAutomat.CellRect(aCol, aRow),
    Picture[aCol, aRow]);
end;

{*****}

{****p* AutomatFonNeuman/DrawGridAutomatClick
* DESCRIPTION
* Процедура запуска автомата.
* Используется для того, что запустить процедуру StartTimer.
* SOURCE
*}

procedure TMainForm.StartAutomatClick(Sender: TObject);
begin
  Start.Enabled := True;
  Pause.Enabled := True;
  StartAutomat.Enabled := False;
  EnterColCountAndRowCount.Enabled := False;
  EditForColCount.Enabled := False;
  EditForRowCount.Enabled := False;
end;

{*****}

{****p* AutomatFonNeuman/PauseClick
* DESCRIPTION
* Процедура остановки автомата.
* Используется для того, чтобы поставить процедуру StartTimer и автомат на паузу.
* SOURCE
*}

procedure TMainForm.PauseClick(Sender: TObject);
begin
  Start.Enabled := False;
  Pause.Enabled := False;
  StartAutomat.Enabled := True;
  EnterColCountAndRowCount.Enabled := True;
  EditForColCount.Enabled := True;
  EditForRowCount.Enabled := True;
end;

{*****}

{****p* AutomatFonNeuman/DrawGridStatesMouseUp
* DESCRIPTION
* Процедура перемещения состояния из таблицы "Состояния" в буфер.
* Используется для того, чтобы поместить выбранное состояние из таблицы в буфер для последующего его перемещения на поле.
* SOURCE
*}

procedure TMainForm.DrawGridStatesMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  Buf := TBitmap.Create;
  DrawGridStates.MouseToCell(X, Y, aC, aR);
  if (aC = 1) and (aR = 0) then
  begin
    Buf := BitmapStates[5];
  end;
  if (aC = 0) and (aR = 0) then
  begin
    Buf := BitmapStates[1];
  end;
  if (aC = 0) and (aR = 1) then
  begin
    Buf := BitmapStates[2];
  end;
  if (aC = 0) and (aR = 2) then
  begin
    Buf := BitmapStates[3];
  end;
  if (aC = 0) and (aR = 3) then
  begin
    Buf := BitmapStates[4];
  end;
  if (aC = 1) and (aR = 2) then
  begin
    Buf := BitmapStates[7];
  end;
  if (aC = 1) and (aR = 3) then
  begin
    Buf := BitmapStates[8];
  end;
  if (aC = 1) and (aR = 1) then
  begin
    Buf := BitmapStates[6];
  end;
  if (aC = 2) and (aR = 0) then
  begin
    Buf := BitmapStates[9];
  end;
  if (aC = 2) and (aR = 1) then
  begin
    Buf := BitmapStates[10];
  end;
  if (aC = 2) and (aR = 2) then
  begin
    Buf := BitmapStates[11];
  end;
  if (aC = 2) and (aR = 3) then
  begin
    Buf := BitmapStates[12];
  end;
  if (aC = 3) and (aR = 0) then
  begin
    Buf := BitmapStates[13];
  end;
  if (aC = 3) and (aR = 1) then
  begin
    Buf := BitmapStates[14];
  end;
  if (aC = 3) and (aR = 2) then
  begin
    Buf := BitmapStates[15];
  end;
  if (aC = 3) and (aR = 3) then
  begin
    Buf := BitmapStates[16];
  end;
  if (aC = 4) and (aR = 0) then
  begin
    Buf := BitmapStates[17];
  end;
  if (aC = 4) and (aR = 1) then
  begin
    Buf := BitmapStates[18];
  end;
  if (aC = 4) and (aR = 2) then
  begin
    Buf := BitmapStates[19];
  end;
  if (aC = 4) and (aR = 3) then
  begin
    Buf := BitmapStates[20];
  end;
  if (aC = 5) and (aR = 0) then
  begin
    Buf := BitmapStates[21];
  end;
  if (aC = 5) and (aR = 1) then
  begin
    Buf := BitmapStates[22];
  end;
  if (aC = 5) and (aR = 2) then
  begin
    Buf := BitmapStates[23];
  end;
  if (aC = 5) and (aR = 3) then
  begin
    Buf := BitmapStates[24];
  end;
  if (aC = 6) and (aR = 0) then
  begin
    Buf := BitmapStates[25];
  end;
  if (aC = 6) and (aR = 1) then
  begin
    Buf := BitmapStates[26];
  end;
  if (aC = 6) and (aR = 2) then
  begin
    Buf := BitmapStates[27];
  end;
  if (aC = 6) and (aR = 3) then
  begin
    Buf := BitmapStates[28];
  end;
  Transition := True;
end;

{*****}

{****p* AutomatFonNeuman/DrawGridStateDrawCell
* DESCRIPTION
* Процедура отображения состояния в таблице "Состояния".
* Используется для того, чтобы отобразить состояние.
* SOURCE
*}

procedure TMainForm.DrawGridStateDrawCell(Sender: TObject; aCol, aRow: integer;
  aRect: TRect; aState: TGridDrawState);
begin
  DrawGridState.Canvas.Draw(5, 5, BitmapStates[29]);
end;

{*****}

{****p* AutomatFonNeuman/DrawGridStateMouseUp
* DESCRIPTION
* Процедура перемещения в состояния в буфер.
* Используется для того, чтобы поместить состояние из таблицы в буфер.
* SOURCE
*}

procedure TMainForm.DrawGridStateMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  Buf := TBitmap.Create;
  DrawGridStates.MouseToCell(X, Y, aC, aR);
  if (aC = 0) and (aR = 0) then
  begin
    Buf := BitmapStates[29];
  end;
  Transition := True;
end;

{*****}

{****p* AutomatFonNeuman/EditForColCountChange
* DESCRIPTION
* Процедура проверки заполнения на пустоту.
* Используется для того, чтобы последовательно заполнять поля ввода.
* SOURCE
*}

procedure TMainForm.EditForColCountChange(Sender: TObject);
begin
  if EditForColCount.Text = '' then
  begin
    EnterColCountAndRowCount.Enabled := False;
    EditForRowCount.Enabled := False;
    EditForRowCount.Text := '';
  end
  else
    EditForRowCount.Enabled := True;
end;

{*****}

{****p* AutomatFonNeuman/EditForColCountKeyPress
* DESCRIPTION
* Процедура проверки заполнения поля числами.
* Используется для того, чтобы в поле можно было вводить только числа.
* SOURCE
*}

procedure TMainForm.EditForColCountKeyPress(Sender: TObject; var Key: char);
begin
  case key of
    '0'..'9': key := key;
    #8: key := key;
    else
      key := #0;
      ShowMessage('Неправильный ввод');
  end;
end;

{*****}

{****p* AutomatFonNeuman/EditForRowCountChange
* DESCRIPTION
* Процедура проверки заполнения на пустоту.
* Используется для того, чтобы последовательно заполнять поля ввода.
* SOURCE
*}

procedure TMainForm.EditForRowCountChange(Sender: TObject);
begin
  if EditForRowCount.Text = '' then
    EnterColCountAndRowCount.Enabled := False
  else
    EnterColCountAndRowCount.Enabled := True;
end;

{*****}

{****p* AutomatFonNeuman/EditForRowCountKeyPress
* DESCRIPTION
* Процедура проверки заполнения поля числами.
* Используется для того, чтобы в поле можно было вводить только числа.
* SOURCE
*}

procedure TMainForm.EditForRowCountKeyPress(Sender: TObject; var Key: char);
begin
  case key of
    '0'..'9': key := key;
    #8: key := key;
    else
      key := #0;
      ShowMessage('Неправильный ввод');
  end;
end;

{*****}

{****p* AutomatFonNeuman/EnterColCountAndRowCountClick
* DESCRIPTION
* Процедура заполнения поля.
* Используется для того, чтобы заполнить поле количеством клеток в длину и ширину, которые указаны в полях для ввода.
* SOURCE
*}

procedure TMainForm.EnterColCountAndRowCountClick(Sender: TObject);
begin
  check9 := False;
  check8 := False;
  check7 := False;
  check6 := False;
  check5 := False;
  check4 := False;
  check3 := False;
  check2 := False;
  check := False;
  CountPopulation := 0;
  LabelForPopulation.Caption := 'Население = ' + IntToStr(CountPopulation);
  CountGeneration := 0;
  LabelForGeneration.Caption := 'Поколение = ' + IntToStr(CountGeneration);
  StartAutomat.Enabled := True;
  x := StrToInt(EditForColCount.Text);
  y := StrToInt(EditForRowCount.Text);
  if (x = 0) or (y = 0) then
  begin
    ShowMessage('Ошибка ввода');
    DrawGridAutomat.ColCount := 0;
    DrawGridAutomat.RowCount := 0;
    DrawGridAutomat.Enabled := False;
    DrawGridStates.Enabled := False;
    StartAutomat.Enabled := False;
    EditForColCount.Text := '';
    EditForRowCount.Text := '';
    exit;
  end;
  if (x > 29) or (y > 29) then
  begin
    ShowMessage('Размеры поля слишком больши! Длина и высота не должна превышать 29 клеток');
    DrawGridAutomat.ColCount := 0;
    DrawGridAutomat.RowCount := 0;
  end
  else
  begin
    DrawGridAutomat.ColCount := x;
    DrawGridAutomat.RowCount := y;
    DrawGridAutomat.Enabled := True;
    DrawGridStates.Enabled := True;
    DrawGridState.Enabled := True;
    StartAutomat.Enabled := True;
    for i := 0 to x - 1 do
      for j := 0 to y - 1 do
      begin
        Picture[i, j] := TBitmap.Create;
        Picture[i, j] := BitmapStates[21];
        Field[i, j] := U;
        Field2[i, j] := U;
        Field3[i, j] := False;
        Field4[i, j] := False;
        Field5[i, j] := False;
      end;
    DrawGridAutomat.Invalidate;
  end;
  Transition := False;
end;

end.

{*****}

unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  LCLType;

type

  { TForm1 }
  snakeArrayType = array of array of integer;
  variantArrayType = array of Variant;
  TForm1 = class(TForm)
    Button1: TButton;
    Image1: TImage;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure spawnNewFood();
    procedure UpdatePixels();
  private

  public

  end;

var
  Form1: TForm1;
  snake: snakeArrayType;
  snakePixels: array of TRect;
  food: array[0..1] of integer;

implementation
{$R *.lfm}
{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
begin
   writeln('game started');
   spawnNewFood();
   Image1.Visible:=true;
   Button1.Visible:=false;
   Label1.Visible:=false;

   SetLength(snakePixels, 3);
   SetLength(snake, 3, 2);
   snake[0][0] := 5;
   snake[0][1] := 2;

   snake[1][0] := 6;
   snake[1][1] := 2;

   snake[2][0] := 7;
   snake[2][1] := 2;

   UpdatePixels();
end;


procedure TForm1.UpdatePixels();
var
  i,j : Integer;
  MyRect: TShape;
begin
  for i := 0 to Length(snake) - 1 do
  begin
    MyRect := TShape.Create(Self);
    with MyRect do
    begin
      Shape:=stRectangle;
      Color:=clRed;
      Height := 30;
      Width := 30;
      Parent := Self;
      Left := snake[i][0] * 30;
      Top := snake[i][1] * 30;
    end;

  end;
end;

function AppendToArray(const Item: Variant; var ArrayToModify: variantArrayType): variantArrayType;
begin
   SetLength(ArrayToModify, Length(ArrayToModify) + 1);
   ArrayToModify[Length(ArrayToModify) - 1] := Item;
   AppendToArray := ArrayToModify;
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
  );
begin
  WriteLn(key);
  key := 0;

  //Move Snake





end;

procedure TForm1.spawnNewFood();
begin
  randomize();
  food[0] := random(10);
  food[1] := random(10);
  Image1.Left:=food[0] * 30;
  Image1.Top:=food[1] * 30;
end;

end.


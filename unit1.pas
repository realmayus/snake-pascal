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
    Timer1: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure spawnNewFood();
    procedure Timer1Timer(Sender: TObject);
    procedure UpdatePixels();
    procedure PrependItem(var snakeArray: snakeArrayType; const item: Variant);
    procedure DebugSnake();
  private

  public

  end;

var
  Form1: TForm1;
  snake: snakeArrayType;
  snakePixels: array of TShape;
  food: array[0..1] of integer;
  currentAction: string;  //'down', 'up', 'left', 'right'

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
   Timer1.Enabled:=true;
end;


procedure TForm1.PrependItem(var snakeArray: snakeArrayType; const item: Variant);
var tempArray: snakeArrayType;
  i: Integer;
begin
  SetLength(tempArray, Length(snakeArray) + 1);
  tempArray[0] := item;
  for i := Low(snakeArray) to High(snakeArray) do
      tempArray[1+i] := snakeArray[i];
  SetLength(snakeArray, Length(snakeArray) + 1);
  snakeArray := tempArray;
end;

procedure TForm1.UpdatePixels();
var
  i: Integer;
  MyRect: TShape;
begin
  WriteLn('Start UpdatePixels');
  for i := 0 to Length(snake) - 1 do
  begin
    MyRect := TShape.Create(Self);
    with MyRect do
    begin
      Shape:=stRectangle;
      Height := 30;
      Width := 30;
      Parent := Self;
      Left := snake[i][0] * 30;
      Top := snake[i][1] * 30;
    end;

  end;
  SetLength(snakePixels, length(snakepixels) + 1);
  snakepixels[length(snakePixels) - 1] := MyRect;
  Writeln('End UpdatePixels');
end;


procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
  );
begin
  if key = 40 then
  begin
    currentAction:='down';
  end
  else if key = 37 then
  begin
    currentAction:='left';
  end
  else if key = 39 then
  begin
    currentaction := 'right';
  end
  else if key = 38 then
  begin
    currentAction := 'up';
  end
  else
  begin
    currentAction := 'down';
  end;

  writeln(currentAction);
  key := 0;
end;

procedure TForm1.spawnNewFood();
begin
  randomize();
  food[0] := random(10);
  food[1] := random(10);
  Image1.Left:=food[0] * 30;
  Image1.Top:=food[1] * 30;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var newPos: array of integer;
begin
   Writeln('Start Timer');
   SetLength(newPos, 2);
   newPos[0] := 0;
   newPos[1] := 0;
   writeln(currentAction);
   if currentAction = 'right' then
   begin
      newPos[0] := snake[0][0] + 1;
      newPos[1] := snake[0][1];
   end
   else if currentAction = 'left' then
   begin
      newPos[0] := snake[0][0] - 1;
      newPos[1] := snake[0][1];
   end
   else if currentAction = 'up' then
   begin
      newPos[0] := snake[0][0];
      newPos[1] := snake[0][1] - 1;
   end
   else if currentAction = 'down' then
   begin
      newPos[0] := snake[0][0];
      newPos[1] := snake[0][1] + 1;
   end
   else
   begin
      newPos[0] := snake[0][0];
      newPos[1] := snake[0][1] + 1;
   end;
   //InsertX(snake, 0, newPos);
   PrependItem(snake, newPos);
   UpdatePixels();
   DebugSnake();
   WriteLn('End Timer');
end;

procedure TForm1.DebugSnake();
var i,j: Integer;
begin
   for i := 0 to length(snake) -1 do
   begin
     Write(i, ' ');
   end;
   WriteLn('.');
   for i := 0 to length(snake) -1 do
   begin
     Write('--');
   end;
   WriteLn('.');
   for i := 0 to length(snake) -1 do
   begin
     Write(snake[i][0], ' ');
   end;
   WriteLn('.');
   for i := 0 to length(snake) -1 do
   begin
     Write(snake[i][1], ' ');
   end;
   WriteLn('.');
   WriteLn('.');
   WriteLn('.');
end;

end.


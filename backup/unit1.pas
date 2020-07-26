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
    ScoreLabel: TLabel;
    Timer1: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure spawnNewFood();
    procedure Timer1Timer(Sender: TObject);
    procedure UpdatePixels();
    procedure PrependItem(var snakeArray: snakeArrayType; const item: Variant);
    procedure DebugSnake();
    procedure DeleteX(var A: snakeArrayType; const Index: Cardinal);
    procedure ClearRectangles();
    function IsHeadInTail(const Head: array of integer; const Tail: snakeArrayType): boolean;
  private

  public

  end;

var
  Form1: TForm1;
  snake: snakeArrayType;
  snakePixels: array of TShape;
  food: array[0..1] of integer;
  score: integer;
  currentAction: string;  //'down', 'up', 'left', 'right'
implementation
{$R *.lfm}
{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
begin
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



   UpdatePixels();
   Timer1.Enabled:=true;
   ScoreLabel.Visible:=True;
   ScoreLabel.Caption:='Score: 0';
end;


procedure TForm1.PrependItem(var snakeArray: snakeArrayType; const item: Variant);
var tempArray: snakeArrayType;
  i: Integer;
begin
  SetLength(tempArray, Length(snakeArray) + 1);
  tempArray[0] := item;
  for i := Low(snakeArray) to High(snakeArray) do
      tempArray[i + 1] := snakeArray[i];
  SetLength(snakeArray, Length(snakeArray) + 1);
  snakeArray := tempArray;
end;

procedure TForm1.ClearRectangles();
var
  i: integer;
begin
  for i := self.ComponentCount - 1 downto 0 do
  begin
   if self.Components[i] is TShape then
      self.Components[i].Free;
  end;
end;

procedure TForm1.UpdatePixels();
var
  i: Integer;
  MyRect: TShape;
begin
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

  Image1.Left:=food[0] * 30;
  Image1.Top:=food[1] * 30;
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
end;

procedure TForm1.DeleteX(var A: snakeArrayType; const Index: Cardinal);
var
  ALength: Cardinal;
  i: Cardinal;
begin
  ALength := Length(A);
  Assert(ALength > 0);
  Assert(Index < ALength);
  for i := Index + 1 to ALength - 1 do
    A[i - 1] := A[i];
  SetLength(A, ALength - 1);
end;

function TForm1.IsHeadInTail(const Head: array of integer;
  const Tail: snakeArrayType): boolean;
var
  i: integer;
begin
  for i := 1 to High(Tail) do
    if (Head[0] = Tail[i][0]) and (Head[1] = Tail[i][1]) then
      Exit(true);
  Result := false;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var newPos: array of integer;
  reply: integer;
begin
   reply := -5;
   SetLength(newPos, 2);
   newPos[0] := 0;
   newPos[1] := 0;
   writeln(currentAction);
   if currentAction = 'right' then
   begin
      if snake[0][0] = 10 then
      begin
        newPos[0] := 0;
      end
      else
      begin
        newPos[0] := snake[0][0] + 1;
      end;
      newPos[1] := snake[0][1];
   end
   else if currentAction = 'left' then
   begin
      if snake[0][0] = 0 then
      begin
        newPos[0] := 10;
      end
      else
      begin
        newPos[0] := snake[0][0] - 1;
      end;
      newPos[1] := snake[0][1];
   end
   else if currentAction = 'up' then
   begin
      newPos[0] := snake[0][0];
      if snake[0][1] = 0 then
      begin
         newPos[1] := 10;
      end
      else
      begin
         newPos[1] := snake[0][1] - 1;
      end;
   end
   else if currentAction = 'down' then
   begin
      newPos[0] := snake[0][0];
      if snake[0][1] = 10 then
      begin
         newPos[1] := 0;
      end
      else
      begin
         newPos[1] := snake[0][1] + 1;
      end;
   end
   else
   begin
     newPos[0] := snake[0][0];
      if snake[0][1] = 10 then
      begin
         newPos[1] := 0;
      end
      else
      begin
         newPos[1] := snake[0][1] + 1;
      end;
   end;

   PrependItem(snake, newPos);

   if (newPos[0] = food[0]) and (newPos[1] = food[1]) then
   begin
      WriteLn('Ate food!');
      score := score + 1;
      scoreLabel.Caption := 'Score: ' + IntToStr(score);
      spawnNewFood();
   end
   else
   begin
      DeleteX(snake, length(snake) - 1);
      ClearRectangles();
   end;

   if IsHeadInTail(newPos, snake) and (length(snake) >= 5) then
   begin
      Form1.Visible:=false;
      Timer1.Enabled:=false;
      reply := Application.MessageBox(PChar('You lose. Score: ' + IntToStr(score)), PChar('Game over'),MB_ICONINFORMATION);
      halt(0);
   end;

   UpdatePixels();
   //DebugSnake();

   Timer1.Interval:= 150 - ((Round(length(snake)/5 + length(snake)/10)) mod 120);
end;

procedure TForm1.DebugSnake();
var i: Integer;
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


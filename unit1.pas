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


// "Spiel start"-Knopf wurde gelickt
procedure TForm1.Button1Click(Sender: TObject);
begin
   spawnNewFood();              //Position des Apfels zufällig festlegen
   Image1.Visible:=true;        //Apfel sichtbar machen (ist auf Startbildschirm versteckt)
   Button1.Visible:=false;      //"Spiel starten"-Knopf unsichtbar machen
   Label1.Visible:=false;       //Titel text unsichtbar machen

   //Es gibt zwei Arrays, 'snakePixels' und 'snake'

   //snakePixels beeinhaltet die tatsächlichen Rechtecke, aus denen die Snake visuell aufgebaut ist.
   //Dies wird gemacht, damit diese nicht durch Garbage Collection verloren gehen
   //(d.h. damit Pascal nicht denkt, die Rechtecksobjekte werden nicht mehr
   //gebraucht und "entsorgt" sie, um Arbeitsspeicher zu sparen.

   //'snake' ist ein zweidimensionales Array, das die einzelnen Punkte auf dem Bildschirm abspeichert.
   //Vorstellen kann man es sich anhand einer Tabelle:  ("Pixel" nenne ich hier die einzelnen Abschnitte der Schlange.)
   // | Pixel 1 | Pixel 2 | Pixel 3 | Pixel 4 | ..
   // | ======= | ======= | ======= | ======= |
   // | xPos: 5 | xPos: 6 | xPos: 7 | xPos: 8 |  xPos = Position auf der X-Achse
   // | ------- | ------- | ------- | ------- |
   // | yPos: 2 | yPos: 2 | yPos: 2 | yPos: 2 |  yPos = Position auf der Y-Achse

   //Dabei ist zu beachten, dass im Gegensatz zum Koordinatensystem bei zunehmender Y-Position der Punkt *nach unten* anstelle nach oben geht.
   //Arrays starten bei dem Index 0.

   SetLength(snakePixels, 3);   //Länge des Arrays festlegen, damit Pascal weiß, wieviel Arbeitsspeicher reserviert werden soll

   SetLength(snake, 3, 2);      // siehe oben, aber diesmal 3 spalten und 2 zeilen in der Tabelle

   // Startpositionen der einzelnen Pixel festlegen:
   snake[0][0] := 5;  //X-Position des 0. Pixels festlegen auf 5
   snake[0][1] := 2;  //Y-Position des 0. Pixels festlegen auf 2

   snake[1][0] := 6;  //X-Position des 1. Pixels festlegen auf 6
   snake[1][1] := 2;  //X-Position des 1. Pixels festlegen auf 2



   UpdatePixels();    //Methode aufrufen, die die Pixel dem Fenster hinzufügt
   Timer1.Enabled:=true;   //Den Timer einschalten (Dieser ist dazu da, damit sich die Schlange in Zeitintervallen weiterbewegt.)
   ScoreLabel.Visible:=True;   //Den Text, der den Spielstand anzeigt, sichtbar machen
   ScoreLabel.Caption:='Score: 0';   // Spielstand auf '0' setzen
end;


//Prozedur, die alle Elemente im Snake-Array durchgeht und diese im Fenster mit Hilfe von Rechtecken darstellt
procedure TForm1.UpdatePixels();
var
  i: Integer;
  MyRect: TShape;
begin
  for i := 0 to Length(snake) - 1 do  //Alle Einträge im Snake-Array durchgehen
  begin
    MyRect := TShape.Create(Self);   //Jeweils ein Rechteck erstellen
    with MyRect do  //...mit folgenden Eigenschaften:
    begin
      Shape:=stRectangle;  //Form: Rechteck
      Height := 30;    //Höhe: 30px (Fenster ist 300x300px groß, demnach gibt es ein 10x10 Raster, in der sich die Snake bewegen kann.
      Width := 30;    //Breite: 30px
      Parent := Self;   //Übergeordnetes Element: die derzeitige Klasse, welche das Fenster selbst ist (deshalb 'self')
      Left := snake[i][0] * 30;  //Koordinaten des Rechtecks: Punkt im array * 30 (10x10 Raster)
      Top := snake[i][1] * 30;
    end;

  end;
  SetLength(snakePixels, length(snakepixels) + 1);
  snakepixels[length(snakePixels) - 1] := MyRect;    //Rechteck dem snakePixels Array hinzufügen, um eine mögliche Garbage Collection zu verhindern (siehe oben)

  Image1.Left:=food[0] * 30;   //Koordinaten des Apfel-Bilds setzen
  Image1.Top:=food[1] * 30;
end;

//Prozedur, die in einer Variable hinterlegt, in welche Richtung die Snake gehen soll
//Dies wird durch die jeweilige Pfeiltaste ermittelt.
procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
  );
begin
  if key = 40 then  //Pfeiltaste nach unten hat den Tastencode 40 usw.
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
  key := 0;  //Die Key-Variable muss auf 0 gesetzt werden, um dem Betriebssystem zu sagen,
             //dass der Tastendruck bearbeitet wurde. Dies muss getan werden, um einen "Ding!"-Ton zu verhinden,
             //den Betriebssysteme gerne abspielen, wenn eine Tasteneingabe nicht erkannt wurde.
end;

//Prozedur zum Generieren von neuen Koordinaten des Apfels. Dieser wird dann beim nächsten mal,
//bei dem UpdatePixels() aufgerufen wird, an der jeweiligen Stelle gezeichnet.
procedure TForm1.spawnNewFood();
begin
  randomize();
  food[0] := random(10);  //x-Position des Apfels zufällig bestimmen
  food[1] := random(10);  //y-Position des Apfels zufällig bestimmen
end;


//Wird aufgerufen, wenn der Timer "tickt", d.h. jedes mal, wenn das Zeitintervall erreicht ist.
procedure TForm1.Timer1Timer(Sender: TObject);
var newPos: array of integer;
  reply: integer;
begin
   SetLength(newPos, 2);  //Neue Position des snake-kopfs
   newPos[0] := 0;  //standardmäßig auf (0, 0) setzen
   newPos[1] := 0;
   if currentAction = 'right' then   //Pfeiltaste nach rechts wurde gedrückt
   begin
      if snake[0][0] = 10 then
      begin
        newPos[0] := 0;   //Kopf am anderen Bildschirmrand wieder ansetzen, falls Snake die Grenze überschritten hat
      end
      else
      begin
        newPos[0] := snake[0][0] + 1;  //Kopf um einen Pixel nach rechts verschieben
      end;
      newPos[1] := snake[0][1];
   end
   else if currentAction = 'left' then  //Pfeiltaste nach links wurde gedrückt
   begin
      if snake[0][0] = 0 then
      begin
        newPos[0] := 10;      //Kopf am anderen Bildschirmrand wieder ansetzen, falls Snake die Grenze überschritten hat
      end
      else
      begin
        newPos[0] := snake[0][0] - 1;  //Kopf um einen Pixel nach links verschieben
      end;
      newPos[1] := snake[0][1];
   end
   else if currentAction = 'up' then   //Pfeiltaste nach oben wurde gedrückt
   begin
      newPos[0] := snake[0][0];
      if snake[0][1] = 0 then
      begin
         newPos[1] := 10;     //Kopf am anderen Bildschirmrand wieder ansetzen, falls Snake die Grenze überschritten hat
      end
      else
      begin
         newPos[1] := snake[0][1] - 1;  //Kopf um einen Pixel nach oben verschieben
      end;
   end
   else if currentAction = 'down' then  //Pfeiltaste nach unten wurde gedrückt
   begin
      newPos[0] := snake[0][0];
      if snake[0][1] = 10 then
      begin
         newPos[1] := 0;  //Kopf am anderen Bildschirmrand wieder ansetzen, falls Snake die Grenze überschritten hat
      end
      else
      begin
         newPos[1] := snake[0][1] + 1;  //Kopf um einen Pixel nach unten verschieben
      end;
   end
   else   //siehe "Pfeiltaste nach unten gedrückt", dies tritt nur ein, wenn keine Taste gedrückt wurde, Snake geht dann nach unten
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

   PrependItem(snake, newPos);  //Neue Kopfposition dem Array voransetzen

   if (newPos[0] = food[0]) and (newPos[1] = food[1]) then  //Falls Snake-Kopf "im Apfel ist"..
   begin
      score := score + 1;  //... Spielstand erhöhen
      scoreLabel.Caption := 'Score: ' + IntToStr(score);  //...Spielstand-text aktualisieren
      spawnNewFood();  //.. neuen Apfel generieren
   end
   else  //Falls kein Apfel gegessen wurde, Snake um ein Rechteck kleiner machen (wir haben eben ja eins hinzugefügt)
   begin
      DeleteX(snake, length(snake) - 1);    //Aus dem snake-Array das letzte Element entfernen
      ClearRectangles();   // Alle Rechtecke im Fenster entfernen
   end;

   if IsHeadInTail(newPos, snake) and (length(snake) >= 5) then  //Falls der Kopf der Snake ihren Schwanz berührt..
   begin
      Form1.Visible:=false;  //.. Fenster unsichtbar machen
      Timer1.Enabled:=false;  //..Spielschleife/Timer anhalten
      reply := Application.MessageBox(PChar('You lose. Score: ' + IntToStr(score)), PChar('Game over'),MB_ICONINFORMATION);  // Info anzeigen
      halt(0);   //Programm nach klick auf OK schließen
   end;

   UpdatePixels(); //Rechtecke aktualisieren

   Timer1.Interval:= 150 - ((Round(length(snake)/5 + length(snake)/10)) mod 120);  //Das zeitintervall der Spielschleife je nach Snake-länge reduzieren, um das Spiel spannender zu machen
end;

// Diese Prozedur entfernt alle Rechtecke im Fenster, damit neue gezeichnet werden können
procedure TForm1.ClearRectangles();
var
  i: integer;
begin
  for i := self.ComponentCount - 1 downto 0 do  //Durch alle Komponenten im fenster durchgehen
  begin
   if self.Components[i] is TShape then   //Wenn die derzeitige Komponente vom Typ 'TShape' ist (was ein Rechteck ist), diese vom Fenster entfernen
      self.Components[i].Free;
  end;
end;

//Prozedur zum Herausfinden, ob der Kopf der Snake ihren Schwanz berührt
function TForm1.IsHeadInTail(const Head: array of integer;
  const Tail: snakeArrayType): boolean;
var
  i: integer;
begin
  for i := 1 to High(Tail) do   //Alle Elemente (mit Ausnahme des Kopfes an Stelle 0) durchgehen...
    if (Head[0] = Tail[i][0]) and (Head[1] = Tail[i][1]) then //... und schauen, ob die Koordinaten den des Kopfes entsprechen.
      Exit(true);  //Falls ja, "True" als Rückgabewert zurückgeben
  Result := false;
end;

//Prozedur zum Entfernen eines Elements an beliebiger Stelle in einem Array  (recht kompliziert, muss man nicht verstehen)
procedure TForm1.DeleteX(var A: snakeArrayType; const Index: Cardinal);
var
  ALength: Cardinal;
  i: Cardinal;
begin
  ALength := Length(A);
  Assert(ALength > 0);  //Wir gehen davon aus, dass die länge des Arrays größer als 0 ist
  Assert(Index < ALength);  //und, dass der Index, der aus dem snake-Array entfernt werden soll im SnakeArray enthalten ist
  for i := Index + 1 to ALength - 1 do  //Alle elemente im SnakeArray ab dem Index durchgehen
    A[i - 1] := A[i];   //und alle um eine Stelle nach links verschieben (da dort ja "Platz wird"
  SetLength(A, ALength - 1);  //Länge des Arrays um 1 reduzieren
end;

// Diese Prozedur fügt eine Koordinate im Snake-Array am *Anfang* hinzu  (Recht kompliziert, muss man nicht verstehen)
procedure TForm1.PrependItem(var snakeArray: snakeArrayType; const item: Variant);
var tempArray: snakeArrayType;
  i: Integer;
begin
  SetLength(tempArray, Length(snakeArray) + 1); //Länge des temporären Arrays um eins größer machen als die des snake-Arrays
  tempArray[0] := item;  //An erster Stelle das Element, dass vorangestellt werden soll, dem temporären Array hinzufügen
  for i := Low(snakeArray) to High(snakeArray) do  //Alle Elemente im Snake-Array durchgehen...
      tempArray[i + 1] := snakeArray[i];  //... und diese dem temporären Array hinzufügen
  SetLength(snakeArray, Length(snakeArray) + 1);  //die länge des Arrays, das verändert werden soll (das Snake-Array) um 1 erhöhen
  snakeArray := tempArray;  //das SnakeArray hat nun dieselben Elemente wie das temporäre Array
end;


end.


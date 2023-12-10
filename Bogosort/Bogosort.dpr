program Bogosort;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils;

const n = 5;

var arr :array[0..n] of integer;
    i, buff, element :integer;
    flag :boolean;

begin
  Randomize;
  for i := 0 to n do readln(arr[i]);
  flag := true;
  while flag do
  begin
    for i := 0 to n do
    begin
      buff := random(n+1);
      element := arr[i];
      arr[i] := arr[buff];
      arr[buff] := element;
      writeln('sort');
    end;
    flag := false;
    for i := n downto 1 do if arr[i] < arr[i-1] then flag := true;
  end;
  for i := 0 to n do write(arr[i], ' ');
  readln;
end.

//GG
//No Way



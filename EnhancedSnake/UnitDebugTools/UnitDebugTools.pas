unit UnitDebugTools;

interface

uses
  Windows, UnitVisualization;

procedure ShowCurrentScreenBufferInfo; stdcall;
procedure DebugMenuInterface(CurrDifficulty, CurrGameMode :PWideChar); stdcall;

implementation

procedure ShowCurrentScreenBufferInfo;
begin
  GetHandle;
  GetCurrentScreenBufferInfo;
  writeln;
  writeln('Screen Buffer Size: ', ScreenBufferInfo.dwSize.X, ' ', ScreenBufferInfo.dwSize.Y);
  writeln('Maximum Size: ', ScreenBufferInfo.dwMaximumWindowSize.X, ' ', ScreenBufferInfo.dwMaximumWindowSize.Y);
  writeln('Window Rect: ', ScreenBufferInfo.srWindow.Left, ' ',ScreenBufferInfo.srWindow.Top, ' ', ScreenBufferInfo.srWindow.Right, ' ', ScreenBufferInfo.srWindow.Bottom);
  writeln('Largest Window Size: ', GetLargestConsoleWindowSize(hStdOut).X, ' ', GetLargestConsoleWindowSize(hStdOut).Y);
end;

procedure DebugMenuInterface(CurrDifficulty, CurrGameMode :PWideChar);
begin
  ClearScreen;
  writeln('Difficulty: ', CurrDifficulty);
  writeln('GameMode: ', CurrGameMode);
end;

end.

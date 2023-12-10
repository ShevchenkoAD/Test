﻿unit UnitVisualization;

interface

uses
  Windows, UnitErrorHandler, UnitGameMechanics;

var hStdOut, hStdIn :tHandle;
    ScreenBufferInfo :CONSOLE_SCREEN_BUFFER_INFO;

procedure GetHandle;                                        stdcall;
procedure GetCurrentScreenBufferInfo;                       stdcall;
procedure ClearScreen;                                      stdcall;
procedure SetOldMode;                                       stdcall;
procedure MenuInitialization;                               stdcall;
procedure MenuStartingFrame;                                stdcall;
procedure MenuNewFrame(TextDifficulty, TextGameMode :byte); stdcall;
procedure MainGameInitialization;                           stdcall;
procedure MainGameNewFrame;                                 stdcall;
procedure GameEndInitialization;                            stdcall;
procedure GameEndStartingFrame;                             stdcall;

implementation

const UTF_8 = 65001;
      MenuInMode      = ENABLE_WINDOW_INPUT;
      MenuOutMode     = ENABLE_WRAP_AT_EOL_OUTPUT or ENABLE_PROCESSED_OUTPUT;
      MainGameInMode  = ENABLE_WINDOW_INPUT;
      MainGameOutMode = ENABLE_WRAP_AT_EOL_OUTPUT or ENABLE_PROCESSED_OUTPUT;
      GameOverInMode  = ENABLE_WINDOW_INPUT;
      GameOverOutMode = ENABLE_WRAP_AT_EOL_OUTPUT or ENABLE_PROCESSED_OUTPUT;
      MenuScreenSizeX    = 94;
      MenuScreenSizeY    = 29;
      GameEndScreenSizeX = 94;
      GameEndScreenSizeY = 29;
      MenuCursorSize           = 100;
      MenuCursorVisibility     = True;
      MainGameCursorSize       = 1;
      MainGameCursorVisibility = False;
      GameEndCursorSize        = 1;
      GameEndCursorVisibility  = False;

type TTab = (tabMenu, tabMainGame, tabGameEnd);

var oldOutMode, oldInMode: LongWord;
    CurrentTab :TTab;
    FlagRepeatOnce :boolean = False;

procedure GetHandle;
begin
  hStdOut := GetStdHandle(STD_OUTPUT_HANDLE);
  if hStdOut = INVALID_HANDLE_VALUE then ShowError('STD_OUTPUT_HANDLE');

  hStdIn := GetSTDHandle(STD_INPUT_HANDLE);
  if hStdIn = INVALID_HANDLE_VALUE  then ShowError('STD_INPUT_HANDLE');
end;

procedure GetOldMode;
begin
  if hStdOut = 0 then GetHandle;
  if not GetConsoleMode(hStdOut, OldOutMode) then ShowError('GET_OLD_MODE_OUTPUT');
  if not GetConsoleMode(hStdIn, OldInMode)   then ShowError('GET_OLD_MODE_INPUT');
end;

procedure SetOldMode;
begin
  if hStdOut = 0 then GetHandle;
  if not SetConsoleMode(hStdOut, OldOutMode) then ShowError('SET_OLD_MODE_OUTPUT');
  if not SetConsoleMode(hStdIn, OldInMode)   then ShowError('SET_OLD_MODE_INPUT');
end;

procedure SetNewMode;
var CurrOutMode, CurrInMode :LongWord;
begin
  if (hStdOut = 0) or (hStdIn = 0) then GetHandle;
  case CurrentTab of
    tabMenu:
    begin
      CurrOutMode := MenuOutMode;
      CurrInMode  := MenuInMode;
    end;
    tabMainGame:
    begin
      CurrOutMode := MainGameOutMode;
      CurrInMode  := MainGameInMode;
    end;
    tabGameEnd:
    begin
      CurrOutMode := GameOverOutMode;
      CurrInMode  := GameOverInMode;
    end;
  end;
  if not SetConsoleMode(hStdOut, CurrOutMode) then ShowError('SET_CURRENT_MODE_OUTPUT');
  if not SetConsoleMode(hStdIn, CurrInMode)   then ShowError('SET_CURRENT_MODE_INPUT');
end;

procedure SetTabTitle;
var TabTitle :PWideChar;
begin
  case CurrentTab of
    tabMenu:     TabTitle := 'EnhancedSnake\Menu';
    tabMainGame: TabTitle := 'EnhancedSnake\MainGame';
    tabGameEnd: TabTitle  := 'EnhancedSnake\GameEnd';
  end;
  if not SetConsoleTitle(TabTitle) then ShowError('SET_TAB_TITLE');
end;

procedure GetCurrentScreenBufferInfo;
begin
  if hStdOut = 0 then GetHandle;
  if not GetConsoleScreenBufferInfo(hStdOut, ScreenBufferInfo) then ShowError('GET_SCREEN_BUFFER_INFO');
end;

procedure ClearScreen;
var ConsoleSize, NumWritten :LongWord;
    Origin : Coord;
begin
  if hStdOut = 0 then GetHandle;
  GetCurrentScreenBufferInfo;
  ConsoleSize := ScreenBufferInfo.dwSize.X * ScreenBufferInfo.dwSize.Y;
  Origin.X := 0;
  Origin.Y := 0;
  if not FillConsoleOutputCharacter(hStdOut, ' ', ConsoleSize, Origin, NumWritten) then ShowError('CLEAR_SCREEN');
  if not FillConsoleOutputAttribute(hStdOut, ScreenBufferInfo.wAttributes, ConsoleSize, Origin, NumWritten) then ShowError('CLEAR_SCREEN');
  if not SetConsoleCursorPosition(hStdOut, Origin) then ShowError('CLEAR_SCREEN');
end;

procedure ClearScreenAttribute;
var ConsoleSize, NumWritten :LongWord;
    ClearCoord : Coord;
    ClearAttributes :LongWord;
    Counter :byte;
begin
  if hStdOut = 0 then GetHandle;
  ClearAttributes := FOREGROUND_RED or FOREGROUND_GREEN or FOREGROUND_BLUE;

  for Counter := 0 to SnakeLength-1 do
  begin
    ClearCoord.X := Snake[Counter, 1]*2;
    ClearCoord.Y := Snake[Counter, 2];
    if not WriteConsoleOutputAttribute(hStdOut, @ClearAttributes, 2, ClearCoord, NumWritten) then ShowError('CLEAR_SCREEN_ATTRIBUTES');
  end;

  ClearCoord.X := LostCell[1]*2;
  ClearCoord.Y := LostCell[2];
  if not WriteConsoleOutputAttribute(hStdOut, @ClearAttributes, 2, ClearCoord, NumWritten) then ShowError('CLEAR_SCREEN_ATTRIBUTES');

  if FlagFruit then
  begin
    ClearCoord.X := Fruit[1]*2;
    ClearCoord.Y := Fruit[2];
    if not WriteConsoleOutputAttribute(hStdOut, @ClearAttributes, 2, ClearCoord, NumWritten) then ShowError('CLEAR_SCREEN_ATTRIBUTES');
  end;
end;

procedure MenuInitialization;
var CurrScreenCoord :COORD;
    CurrWindowPosition :SMALL_RECT;
    CurrCursorInfo :CONSOLE_CURSOR_INFO;
begin
  SetConsoleOutputCP(UTF_8);
  if hStdOut = 0 then GetHandle;
  GetOldMode;
  CurrentTab := tabMenu;
  SetNewMode;
  SetTabTitle;

  GetCurrentScreenBufferInfo;

  CurrWindowPosition.Left := 0;
  CurrWindowPosition.Top  := 0;
  CurrWindowPosition.Right  := MenuScreenSizeX-1;
  CurrWindowPosition.Bottom := MenuScreenSizeY-1;
  if not SetConsoleWindowInfo(hStdOut, True, CurrWindowPosition) then ShowError('MENU_INITIALIZATION');

  CurrScreenCoord.X := MenuScreenSizeX;
  CurrScreenCoord.Y := MenuScreenSizeY;
  if not SetConsoleScreenBufferSize(hStdOut, CurrScreenCoord) then ShowError('MENU_INITIALIZATION');

  CurrCursorInfo.dwSize   := MenuCursorSize;
  CurrCursorInfo.bVisible := MenuCursorVisibility;
  if not SetConsoleCursorInfo(hStdOut, CurrCursorInfo) then ShowError('MENU_INITIALIZATION');
end;

procedure MenuStartingFrame;
var StartingCursorPosition :COORD;
    AttributeCoord :COORD;
    RowCount, NumberAttr :LongWord;
    TextAttribute :word;
begin
  if hStdOut = 0 then GetHandle;
  StartingCursorPosition.X := 0;
  StartingCursorPosition.Y := 0;
  if not SetConsoleCursorPosition(hStdOut, StartingCursorPosition) then ShowError('MENU_STARTING_FRAME');
  writeln('╔═══════════════════════════════════════════════════════════════════════════════════════════╗');
  writeln('║     ╔═      ╗  ╔══════   ╔          ╗        ╔═════      ╔╗       ╔╗    ╔╗    ╔══════     ║');
  writeln('║     ║ ╚     ║  ║         ║          ║       ╔           ╔  ╗     ╔  ╗  ╔  ╗   ║           ║');
  writeln('║     ║  ╚    ║  ╠═════    ╚          ╝      ╔           ╔    ╗    ║   ╚╝   ║   ╠═════      ║');
  writeln('║     ║   ╚   ║  ║          ║   ╔╗   ║       ╚     ══╗  ╔══════╗  ╔          ╗  ║           ║');
  writeln('║     ║    ╚  ║  ║          ╚  ╔  ╗  ╝        ╚      ║  ║      ║  ║          ║  ║           ║');
  writeln('║     ╚     ╚═╝  ╚══════     ╚═    ═╝          ╚════╝   ╚      ╝  ╚          ╝  ╚══════     ║');
  writeln('╠═══════════════════════════════════════════════════════════════════════════════════════════╣');
  writeln('║                                                                                           ║');
  writeln('║  Choose Difficulty:                                                                       ║');
  writeln('║   1. Easy.                        Half   Speed.                                           ║');
  writeln('║   2. Medium.                      Full   Speed.                                           ║');
  writeln('║   3. Hard.                        Double Speed.                                           ║');
  writeln('║                                                                                           ║');
  writeln('║  Choose Game Mode:                                                                        ║');
  writeln('║   1. Small Field.                 5*5.                                                    ║');
  writeln('║   2. Normal Field.                10*10.                                                  ║');
  writeln('║   3. Large Field with Obstacles.  15*15.                                                  ║');
  writeln('║                                                                                           ║');
  writeln('║  Current Difficulty: None.                                                                ║');
  writeln('║  Current Game Mode:  None.                                                                ║');
  writeln('║  Confirm Selection...                                                                     ║');
  writeln('║                                                                                           ║');
  writeln('╠═════════════════════════════════╗                                                         ║');
  writeln('║ Controls:                       ║                                                         ║');
  writeln('║  Arrows - Move Cursor or Snake. ║                                                         ║');
  writeln('║  Enter - Choose Option.         ║                                                         ║');
  writeln('║  P - Pause.         Esc - Exit. ║                            Developed by Shevchenko A.D. ║');
  write  ('╚═════════════════════════════════╩═════════════════════════════════════════════════════════╝');

  AttributeCoord.X := 7;
  for RowCount := 10 to 12 do
  begin
    case RowCount of
      10:
      begin
        AttributeCoord.Y := RowCount;
        textAttribute    := FOREGROUND_GREEN;
        if not WriteConsoleOutputAttribute(hStdOut, @TextAttribute, 1, AttributeCoord, NumberAttr) then ShowError('MENU_STARTING_FRAME');
      end;
      11:
      begin
        AttributeCoord.Y := RowCount;
        textAttribute    := FOREGROUND_GREEN or FOREGROUND_RED;
        if not WriteConsoleOutputAttribute(hStdOut, @TextAttribute, 1, AttributeCoord, NumberAttr) then ShowError('MENU_STARTING_FRAME');
      end;
      12:
      begin
        AttributeCoord.Y := RowCount;
        textAttribute    := FOREGROUND_RED;
        if not WriteConsoleOutputAttribute(hStdOut, @TextAttribute, 1, AttributeCoord, NumberAttr) then ShowError('MENU_STARTING_FRAME');
      end;
    end;
  end;

  StartingCursorPosition.X := 3;
  StartingCursorPosition.Y := 9;
  if not SetConsoleCursorPosition(hStdOut, StartingCursorPosition) then ShowError('MENU_STARTING_FRAME');
end;

procedure MenuNewFrame(TextDifficulty, TextGameMode :byte);
var OriginalCursorPosition, WriteCoord :Coord;
    TextDif, TextGM :string[7];
begin
  if hStdOut = 0 then GetHandle;
  GetCurrentScreenBufferInfo;
  case TextDifficulty of
  1:   TextDif := 'Easy.  ';
  2:   TextDif := 'Medium.';
  3:   TextDif := 'Hard.  ';
  else TextDif := 'None.  ';
  end;

  case TextGameMode of
  1:   TextGm := 'Small. ';
  2:   TextGm := 'Normal.';
  3:   TextGm := 'Large. ';
  else TextGm := 'None.  ';
  end;

  OriginalCursorPosition.X := ScreenBufferInfo.dwCursorPosition.X;
  OriginalCursorPosition.Y := ScreenBufferInfo.dwCursorPosition.Y;

  WriteCoord.X := 0;
  WriteCoord.Y := 19;
  if not SetConsoleCursorPosition(hStdOut, WriteCoord) then ShowError('MENU_NEW_FRAME');
  Write('║  Current Difficulty: ', TextDif, '                                                              ║');

  WriteCoord.X := 0;
  WriteCoord.Y := 20;
  if not SetConsoleCursorPosition(hStdOut, WriteCoord) then ShowError('MENU_NEW_FRAME');
  Write('║  Current Game Mode:  ', TextGM, '                                                              ║');

  if not SetConsoleCursorPosition(hStdOut, OriginalCursorPosition) then ShowError('MENU_NEW_FRAME');
end;

procedure MainGameInitialization;
var CurrScreenCoord :COORD;
    CurrWindowPosition :SMALL_RECT;
    CurrCursorInfo :CONSOLE_CURSOR_INFO;
    RowCount, ColumnCount: byte;
begin
  SetConsoleOutputCP(UTF_8);
  if hStdOut = 0 then GetHandle;
  CurrentTab := tabMainGame;
  SetNewMode;
  SetTabTitle;

  CurrWindowPosition.Left   := 0;
  CurrWindowPosition.Top    := 0;
  CurrWindowPosition.Right  := 39;
  CurrWindowPosition.Bottom := 19;
  if not SetConsoleWindowInfo(hStdOut, True, CurrWindowPosition) then ShowError('MAIN_GAME_INITIALIZATION');

  CurrScreenCoord.X := 40;
  CurrScreenCoord.Y := 20;
  if not SetConsoleScreenBufferSize(hStdOut, CurrScreenCoord) then ShowError('MAIN_GAME_INITIALIZATION');

  CurrCursorInfo.dwSize   := MainGameCursorSize;
  CurrCursorInfo.bVisible := MainGameCursorVisibility;
  if not SetConsoleCursorInfo(hStdOut, CurrCursorInfo) then ShowError('MAIN_GAME_INITIALIZATION');

  for RowCount := 0 to FieldLength-1 do
  begin
    for ColumnCount := 0 to FieldLength-1 do write(#$2b1b);
    writeln;
  end;
end;

procedure MainGameNewFrame;
var CellCoord :Coord;
    RowCount, ColumnCount, Counter: byte;
    NumberAttr :cardinal;
begin
  if hStdOut = 0 then GetHandle;
  ClearScreenAttribute;

  for Counter := 0 to SnakeLength-1 do
  begin
    CellCoord.X := Snake[Counter, 1]*2;
    CellCoord.Y := Snake[Counter, 2];
    if (Counter = 0) or (Counter = SnakeLength-1) then
    begin
      if not WriteConsoleOutputAttribute(hStdOut, @SnakeHeadTailColour, 2, CellCoord, NumberAttr) then ShowError('MAIN_GAME_NEW_FRAME');
    end
    else
    begin
      if not WriteConsoleOutputAttribute(hStdOut, @SnakeBodyColour, 2, CellCoord, NumberAttr) then ShowError('MAIN_GAME_NEW_FRAME');
    end;
  end;

  if FlagFruit then
  begin
    CellCoord.X := Fruit[1]*2;
    CellCoord.Y := Fruit[2];
    if not WriteConsoleOutputAttribute(hStdOut, @FruitColour, 2, CellCoord, NumberAttr) then ShowError('MAIN_GAME_NEW_FRAME');
  end;

  if not FlagRepeatOnce and FlagObstacles then
  begin
    for RowCount := 0 to FieldLength-1 do
    begin
      for ColumnCount := 0 to FieldLength-1 do
      begin
        if CurrentObstacleSet[RowCount, ColumnCount] = 1 then
        begin
          CellCoord.X := ColumnCount*2;
          CellCoord.Y := RowCount;
          if not WriteConsoleOutputAttribute(hStdOut, @ObstacleColour, 2, CellCoord, NumberAttr) then ShowError('MAIN_GAME_NEW_FRAME');
        end;
      end;
    end;
    FlagRepeatOnce := True;
  end;

  CellCoord.X := 0;
  CellCoord.Y := FieldLength;
  if not SetConsoleCursorPosition(hStdOut, CellCoord) then ShowError('MAIN_GAME_NEW_FRAME');
  writeln('Current Speed: ', CurrentSpeed, '    ');
  writeln('Current TickCount: ', TickCount, '    ');
  write('Current State: ');
  if FlagPause then writeln('Paused')
  else writeln('Active');
  write('Score: ', CurrentScore, '    ');
end;

procedure GameEndInitialization;
var CurrScreenCoord :COORD;
    CurrWindowPosition :SMALL_RECT;
    CurrCursorInfo :CONSOLE_CURSOR_INFO;
begin
  SetConsoleOutputCP(UTF_8);
  if hStdOut = 0 then GetHandle;
  CurrentTab := tabGameEnd;
  SetNewMode;
  SetTabTitle;

  GetCurrentScreenBufferInfo;

  CurrScreenCoord.X := GameEndScreenSizeX;
  CurrScreenCoord.Y := GameEndScreenSizeY;
  if not SetConsoleScreenBufferSize(hStdOut, CurrScreenCoord) then ShowError('GAME_END_INITIALIZATION');

  CurrWindowPosition.Left := 0;
  CurrWindowPosition.Top  := 0;
  CurrWindowPosition.Right  := GameEndScreenSizeX-1;
  CurrWindowPosition.Bottom := GameEndScreenSizeY-1;
  if not SetConsoleWindowInfo(hStdOut, True, CurrWindowPosition) then ShowError('GAME_END_INITIALIZATION');

  CurrCursorInfo.dwSize   := GameEndCursorSize;
  CurrCursorInfo.bVisible := GameEndCursorVisibility;
  if not SetConsoleCursorInfo(hStdOut, CurrCursorInfo) then ShowError('GAME_END_INITIALIZATION');
end;

procedure GameEndStartingFrame;
var StartingCursorPosition :COORD;
    RowCount, NumberAttr :LongWord;
    TextAttribute, ConsoleSize :Word;
    NumWritten :Cardinal;
begin
  if hStdOut = 0 then GetHandle;
  StartingCursorPosition.X := 0;
  StartingCursorPosition.Y := 0;
  if not SetConsoleCursorPosition(hStdOut, StartingCursorPosition) then ShowError('GAME_END_STARTING_FRAME');

  if FlagWin then
  begin
    writeln('╔═══════════════════════════════════════════════════════════════════════════════════════════╗');
    writeln('║                   ╔          ╗  ╔═══╦═══╗  ╔═      ╗   ╔╦╦╗  ╔╦╦╗  ╔╦╦╗                   ║');
    writeln('║                   ║          ║      ║      ║ ╚     ║   ╠╬╬╣  ╠╬╬╣  ╠╬╬╣                   ║');
    writeln('║                   ╚          ╝      ║      ║  ╚    ║   ╠╬╬╣  ╠╬╬╣  ╠╬╬╣                   ║');
    writeln('║                    ║   ╔╗   ║       ║      ║   ╚   ║    ╠╣    ╠╣    ╠╣                    ║');
    writeln('║                    ╚  ╔  ╗  ╝       ║      ║    ╚  ║    ╚╝    ╚╝    ╚╝                    ║');
    writeln('║                     ╚═    ═╝    ╚═══╩═══╝  ╚     ╚═╝    ╚╝    ╚╝    ╚╝                    ║');
    writeln('╚═══════════════════════════════════════════════════════════════════════════════════════════╝');
    TextAttribute := BACKGROUND_GREEN;
  end;

  if FlagCollision then
  begin
    writeln('╔═══════════════════════════════════════════════════════════════════════════════════════════╗');
    writeln('║                 ╔════╗    ╔══════     ╔╗     ╔════╗    ╔╦╦╗  ╔╦╦╗  ╔╦╦╗                   ║');
    writeln('║                 ║     ╗   ║          ╔  ╗    ║     ╗   ╠╬╬╣  ╠╬╬╣  ╠╬╬╣                   ║');
    writeln('║                 ║      ╗  ╠═════    ╔    ╗   ║      ╗  ╠╬╬╣  ╠╬╬╣  ╠╬╬╣                   ║');
    writeln('║                 ║      ╝  ║        ╔══════╗  ║      ╝   ╠╣    ╠╣    ╠╣                    ║');
    writeln('║                 ║     ╝   ║        ║      ║  ║     ╝    ╚╝    ╚╝    ╚╝                    ║');
    writeln('║                 ╚════╝    ╚══════  ╚      ╝  ╚════╝     ╚╝    ╚╝    ╚╝                    ║');
    writeln('╚═══════════════════════════════════════════════════════════════════════════════════════════╝');
    TextAttribute := BACKGROUND_RED;
  end;

  writeln;
  writeln('Your Settings: ');

  write(' Difficulty: ');
  case SpeedCap of
  50: writeln('Easy.   ');
  30: writeln('Medium. ');
  20: writeln('Hard.   ');
  end;

  write(' Game Mode:  ');
  case FieldLength of
  5:  writeln('Small.  ');
  10: writeln('Normal. ');
  15: writeln('Large.  ');
  end;

  writeln;
  writeln('Your Results:');
  writeln(' MovesMade: ', MovesMade);
  writeln(' Score:     ', CurrentScore);

  if hStdOut = 0 then GetHandle;
  GetCurrentScreenBufferInfo;
  ConsoleSize := ScreenBufferInfo.dwSize.X * 8;
  StartingCursorPosition.X := 0;
  StartingCursorPosition.Y := 0;
  if not FillConsoleOutputAttribute(hStdOut, TextAttribute, ConsoleSize, StartingCursorPosition, NumWritten) then ShowError('GAME_END_STARTING_FRAME');
end;

end.

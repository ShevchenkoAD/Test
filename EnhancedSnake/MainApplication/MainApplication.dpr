﻿program MainApplication;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  Windows,
  UnitVisualization in '..\UnitVisualization\UnitVisualization.pas',
  UnitInterface     in '..\UnitInterface\UnitInterface.pas',
  UnitGameMechanics in '..\UnitGameMechanics\UnitGameMechanics.pas',
  UnitErrorHandler  in '..\UnitErrorHandler\UnitErrorHandler.pas';

begin
  MenuInterface;
  ClearScreen;
  MainGameInterface;
  ClearScreen;
  GameEndInterface;
  readln;
  SetOldMode;
end.

//Hahh so stupid
//NOOOO


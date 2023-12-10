program Laba7Part1;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils;

type tString = String[255];

const SPACE :tString = ' ';

var OriginalString, StringCase1, StringCase2 :tString;


procedure DeleteExtraSeparator(var StringX :tString; Separator :tString);
var DoubleSeparator :tString;
    Counter :Integer;
begin
  Counter := 1;
  while (Counter <= Length(StringX)) and (StringX[Counter] = Separator) do Inc(Counter);

  Delete(StringX, 1, Counter - 1);

  Counter := Length(StringX);
  while (Counter >= 1) and (StringX[Counter] = Separator) do Dec(Counter);

  Delete(StringX, Counter + 1, Length(StringX) - Counter + 1);

  DoubleSeparator := Concat(Separator, Separator);

  while Pos(DoubleSeparator, StringX) <> 0 do
  begin
    Delete(StringX, Pos(DoubleSeparator, StringX), 1);
  end;
end;

procedure DeleteLastSubString(var StringX :tString; Separator :tString);
var LastSubString :tString;
    LastSubStringLength, Counter :Integer;
begin
  LastSubStringLength := 0;
  Counter := Length(StringX);

  while (Counter <> 0) and (StringX[Counter] <> Separator) do
  begin
    Dec(Counter);
    Inc(LastSubStringLength);
  end;

  Inc(Counter);

  LastSubString := Concat(Copy(StringX, Counter, LastSubStringLength), Separator);
  Inc(LastSubStringLength);

  Delete(StringX, Counter, LastSubStringLength);

  while Pos(LastSubString, StringX) = 1 do
    Delete(StringX, 1, LastSubStringLength);

  LastSubString := Concat(Separator, LastSubString);

  while Pos(LastSubString, StringX) <> 0 do
    Delete(StringX, Pos(LastSubString, StringX) + 1, LastSubStringLength);
end;

procedure FindInversion(var StringX :tString; Separator :tString);
var SubString1, SubString2 :tString;
    SubStringLength1, SubStringLength2, OverallCounter, Counter, InversionCounter :Integer;
    FlagIsInversion :Boolean;
begin
  OverallCounter := Length(StringX);
  
  while OverallCounter >= 1 do
  begin
    SubStringLength1 := 1;

    while StringX[SubStringLength1] <> Separator do
    begin
      Inc(SubStringLength1);
      Dec(OverallCounter);
    end;

    Dec(OverallCounter);
    Dec(SubStringLength1);
    SubString1 := Copy(StringX, 1, SubStringLength1);
    Delete(StringX, 1, SubStringLength1 + 1);

    Counter := 1;
    InversionCounter := 0;
    
    while Counter <= OverallCounter do
    begin
      SubStringLength2 := 0;

      while StringX[Counter+SubStringLength2] <> Separator do Inc(SubStringLength2);

      SubString2 := Copy(StringX, Counter, SubStringLength2);

      FlagIsInversion := True;

      if SubStringLength1 = SubStringLength2 then
      begin
        for var i := 1 to SubStringLength1 do
        begin
          if Pos(SubString1[i], SubString2) <> 0 then Delete(SubString2, Pos(SubString1[i], SubString2), 1)
          else FlagIsInversion := False;
        end;
      end
      else FlagIsInversion := False;

      if FlagIsInversion then
      begin
        SubString1 := Concat(SubString1, Separator);
        Insert(SubString1, StringX, Length(StringX) + 10);
        
        SubString2 := Copy(StringX, Counter, SubStringLength2);
        Delete(StringX, Counter, SubStringLength2 + 1);
        SubString1 := SubString2;
        
        Dec(OverallCounter, SubStringLength1 + 1);
        Inc(InversionCounter);
      end
      else Inc(Counter, SubStringLength2 + 1);
    end;

    if InversionCounter <> 0 then
    begin
      SubString1 := Concat(SubString1, Separator);
      Insert(SubString1, StringX, Length(StringX) + 10);
    end;
  end;
end;

function SortByVowelPercentage(StringX :tString; Separator :tString): tString;
const LATIN_VOWEL :tString = 'aeiouyAEIOUY';
type  SubStringInfo = array[1..3] of integer; 
var SubString, StringResult :tString;
    SubStringLength, Counter, VowelCounter, MinVowelPercentage, MinIndex, WordCount :Integer;
    Temp :SubStringInfo;
    arrSubStringInfo :array[1..255] of SubStringInfo;
begin
  Counter := 1;
  WordCount := 0;
  StringResult := '';
  
  while Counter <= Length(StringX) do
  begin
    SubStringLength := 0;

    while StringX[Counter+SubStringLength] <> Separator do Inc(SubStringLength);
    
    SubString := Copy(StringX, Counter, SubStringLength);

    Inc(WordCount);

    arrSubStringInfo[WordCount, 1] := Counter;
    arrSubStringInfo[WordCount, 2] := SubStringLength + 1;

    VowelCounter := 0;
    
    for var i := 1 to SubStringLength do
    if Pos(SubString[i], LATIN_VOWEL) <> 0 then Inc(VowelCounter);

    VowelCounter := Trunc((VowelCounter/SubStringLength)*100);

    arrSubStringInfo[WordCount, 3] := VowelCounter;
      
    Inc(Counter, SubStringLength + 1);
  end;

  for var j := 1 to WordCount do
  begin
    MinVowelPercentage := arrSubStringInfo[j, 3];
    MinIndex := j;
    
    for var k := j to WordCount do
    begin
      if arrSubStringInfo[k, 3] <= MinVowelPercentage then
      begin
        MinVowelPercentage := arrSubStringInfo[k, 3];
        MinIndex := k;
      end;
    end;
  
    Temp := arrSubStringInfo[j];
    arrSubStringInfo[j] := arrSubStringInfo[MinIndex];
    arrSubStringInfo[MinIndex] := Temp; 
  end;

  for var q := WordCount downto 1 do
  begin
    Insert(Copy(StringX, arrSubStringInfo[q,1], arrSubStringInfo[q,2]), StringResult, 1);
  end;

  Result := StringResult;
end;


begin
  writeln('Input string:');
  readln(OriginalString);

  StringCase1 := OriginalString;
  DeleteExtraSeparator(StringCase1, SPACE);
  if StringCase1 <> '' then
  begin
    DeleteLastSubstring(StringCase1, SPACE);
//    writeln(StringCase1);
    FindInversion(StringCase1, SPACE);
  end;
  writeln('Case1: ');
  if (StringCase1 <> '') then writeln(StringCase1)
  else writeln('No suitable words.');


  StringCase2 := OriginalString;
  DeleteExtraSeparator(StringCase2, SPACE);
  if StringCase2 <> '' then
  begin
    DeleteLastSubstring(StringCase2, SPACE);
//  writeln(StringCase2);
    StringCase2 := SortByVowelPercentage(StringCase2, SPACE);
  end;

  writeln('Case2: ');
  if (StringCase2 <> '') then  writeln(StringCase2)
  else writeln('No suitable words.');

  readln;
end.

//             gfgdfgd                
//gffghgf             
//    gfgfgf    haha  nanan   gg gg   hahah  hahangnngn haha
//gffg nbnb haha gfgf haha
//     haha hahanbnbn nnnbbaahh haha jkli lijk hah nbnb ahh ahh haha
//haha bgbg ggbb bbgg gbgb haha  
//
//I live in a house near the mountains. I have two brothers and one sister, and I was born last. My father teaches mathematics, and my mother is a nurse at a big hospital. My brothers are very smart and work hard in school. My sister is a nervous girl, but she is very kind. My grandmother also lives with us. She came from Italy when I was two years old. She has grown old, but she is still very strong. She cooks the best food!
//
//I wanted to send an email update to you let you know how things have been going during my semester abroad here in Málaga, Spain. I've already been here for six weeks, and I feel like I am finally adapting to the culture. I'm also speaking the language more fluently.
//
//  lebb ellb thmon   haha house bell lecture ouesh  haha lleb ha     month my may mi ma haha hsoue  hah  haha      

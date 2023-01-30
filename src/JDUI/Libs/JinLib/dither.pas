unit dither;
interface
uses
  Windows, Vcl.Graphics;
type
  PRGBColor = ^TARGBColor;
  TARGBColor = record
    B, G, R, A: Byte;
  end;
  PByte = ^Byte;
  LColor = record
    Color, Times: Integer;
  end;

procedure Trueto256(SBitmap: TBitMap; var DBitMap: TBitMap);
procedure TrueColorTo256bit(SBitmap: PRGBColor; Width, Height: Integer; DBitMap: TBitMap);

implementation

var
  ColorCount: array[0..4096] of LColor; //为记录颜色使用频率的数组
  ColorTable: array[0..4096] of Byte; // 为记录颜色索引值的数组

//统计颜色使用频率
//Download by http://www.codefans.net
procedure CountColor(BitMap: TBitMap; var ClrCount: array of LColor);
var
  Ptr: PRGBColor;
  i, j: Integer;
  CIndex: Integer;
begin
  for i := 0 to 4096 do // 初始化ColorCount数组
  begin
    ClrCount[i].Color := i;
    ClrCount[i].Times := 0;
  end;

  with BitMap do
    for i := 0 to (Height - 1) do
    begin
      Ptr := ScanLine[i];
      for j := 0 to (Width - 1) do
      begin //取 R、G、B三种颜色的前4位组成12位，共4096种颜色
        CIndex := (Ptr.R and $0F0) shl 4;
        CIndex := CIndex + (Ptr.G and $0F0);
        CIndex := CIndex + ((Ptr.B and $0F0) shr 4);
        Inc(ClrCount[CIndex].Times, 1); //计算颜色的使用次数
        Inc(Ptr);
      end;
    end;
end; //procedure CountColor
procedure CountColor2(BitMap: PRGBColor; Width, Height: Integer; var ClrCount: array of LColor);
var
  Ptr: PRGBColor;
  i, j: Integer;
  CIndex: Integer;
begin
  for i := 0 to 4096 do // 初始化ColorCount数组
  begin
    ClrCount[i].Color := i;
    ClrCount[i].Times := 0;
  end;

  Ptr := BitMap;
    for i := 0 to (Height - 1) do
    begin
      for j := 0 to (Width - 1) do
      begin //取 R、G、B三种颜色的前4位组成12位，共4096种颜色
        CIndex := (Ptr.R and $0F0) shl 4;
        CIndex := CIndex + (Ptr.G and $0F0);
        CIndex := CIndex + ((Ptr.B and $0F0) shr 4);
        Inc(ClrCount[CIndex].Times, 1); //计算颜色的使用次数
        Inc(Ptr);
      end;
    end;
end; //procedure CountColor

// 清除使用次数为 0 的颜色数据,返回值为当前图像中颜色的种类

function Delzero(var ClrCount: array of LColor): Integer;
var i, CIndex: Integer;
begin
  CIndex := 0;
  for i := 0 to 4096 do
  begin
    if (ClrCount[i].Times <> 0) then
    begin
      ClrCount[CIndex] := ClrCount[i];
      ClrCount[i].Times := 0;
      Inc(CIndex);
    end;
  end;
  Result := CIndex;
end; //function Delzero

// 快速排序， 将各种颜色 按使用的频率排序(Hight -- Low )

procedure Sort(var A: array of LColor; Top: Integer);

  procedure QuickSort(var A: array of LColor; iLo, iHi: Integer);
  var
    Lo, Hi, Mid: Integer;
    Temp: LColor;
  begin
    Lo := iLo;
    Hi := iHi;
    Mid := A[(Lo + Hi) div 2].Times;
    repeat
      while A[Lo].Times > Mid do Inc(Lo);
      while A[Hi].Times < Mid do Dec(Hi);
      if Lo <= Hi then
      begin
        Temp := A[Lo];
        A[Lo] := A[Hi];
        A[Hi] := Temp;
        Inc(Lo);
        Dec(Hi);
      end;
    until Lo > Hi;
    if Hi > iLo then QuickSort(A, iLo, Hi);
    if Lo < iHi then QuickSort(A, Lo, iHi);
  end;

begin
  QuickSort(A, Low(A), Top);
end;

// 构建调色表

function BuildColorTable(var ClrCount: array of LColor;
  var Pal: PLogPalette): HPalette;
var i: Integer;
begin
  Pal.palVersion := $300;
  Pal.palNumEntries := 256;
  for i := 0 to 255 do
  begin
    Pal.palPalEntry[i].peRed := ((ClrCount[i].Color and $0F00) shr 4) + 7;
    Pal.palPalEntry[i].peGreen := (ClrCount[i].Color and $0F0) + 7;
    Pal.palPalEntry[i].peBlue := ((ClrCount[i].Color and $00F) shl 4) + 7;
    pal.palPalEntry[i].peFlags := 0;
  end;
  Result := CreatePalette(Pal^);
end;


//根据统计的信息调整图像中的颜色， 将不常用的颜色用常用的颜色代替

procedure AdjustColor(ClrNumber: Integer; ClrCount: array of LColor);
var i, C, Error, m: Integer;
  CIndex: Byte;
begin
//  for i := 0 to 4096 do ColorTable[i] := 0;
  for i := 0 to 255 do
    ColorTable[ClrCount[i].Color] := i;

  for i := 256 to ClrNumber do
  begin
    Error := 10000;
    CIndex := 0;
    C := ClrCount[i].Color;
    for m := 0 to 255 do
      if abs(ClrCount[m].Color - C) < Error then
      begin
        Error := abs(ClrCount[m].Color - C);
        CIndex := m;
      end;
    ColorTable[ClrCount[i].Color] := CIndex;
  end;
end; //procedure AdjustColor

procedure Trueto256(SBitmap: TBitMap; var DBitMap: TBitMap);
var
  Pal: PLogPalette;
  i, j, t, ColorNumber: integer;
  SPtr: PRGBColor;
  DPtr: PByte;
begin
  if (SBitMap.Empty) then
    Exit;

  CountColor(SBitMap, ColorCount); //统计颜色的使用频率
  ColorNumber := DelZero(ColorCount); //去处不使用的颜色
  Sort(ColorCount, ColorNumber); // 将颜色按使用频率排序
  AdjustColor(ColorNumber, ColorCount);

  with DBitMap do
  begin
    PixelFormat := pf8bit;
    SBitMap.PixelFormat := pf32bit;
    Width := SBitMap.Width;
    Height := SBitMap.Height;

    GetMem(pal, sizeof(TLogPalette) + sizeof(TPaletteEntry) * 255);
    BuildColorTable(ColorCount, Pal);
    Palette := BuildColorTable(ColorCount, Pal); // Set DBitMap.Palette
    FreeMem(pal);

    for i := 0 to (Height - 1) do
    begin
      SPtr := SBitMap.ScanLine[i];
      DPtr := ScanLine[i];
      for j := 0 to (Width - 1) do
      begin
        t := (SPtr.R and $0F0) shl 4;
        t := t + (SPtr.G and $0F0);
        t := t + ((SPtr.B and $0F0) shr 4);
        DPtr^ := ColorTable[t];
        Inc(SPtr);
        Inc(DPtr);
      end;
    end;

  end;
end; //procedure Convert
procedure TrueColorTo256bit(SBitmap: PRGBColor; Width, Height: Integer; DBitMap: TBitMap);
var
  Pal: PLogPalette;
  i, j, t, X, Y, ColorNumber: integer;
  SPtr, SPtr2: PRGBColor;
  DPtr: PByte;
  p, p1, P2: PRGBColor;
begin
  CountColor2(SBitMap, Width, Height, ColorCount); //统计颜色的使用频率
  ColorNumber := DelZero(ColorCount); //去处不使用的颜色
  Sort(ColorCount, ColorNumber); // 将颜色按使用频率排序
  AdjustColor(ColorNumber, ColorCount);

  DBitMap.PixelFormat := pf8bit;
  DBitMap.Width := Width;
  DBitMap.Height := Height;

  GetMem(pal, sizeof(TLogPalette) + sizeof(TPaletteEntry) * 255);
  BuildColorTable(ColorCount, Pal);
  DBitMap.Palette := BuildColorTable(ColorCount, Pal); // Set DBitMap.Palette
  FreeMem(pal);

  DPtr := DBitMap.ScanLine[DBitMap.Height - 1];
  p := SBitmap;
  Inc(dword(p), (DBitMap.Height - 1) * DBitMap.Width * 4);
  for y := 0 to DBitMap.Height - 1 do
  begin
    P2 := P;
    for x := 0 to DBitMap.Width - 1 do
    begin
      t := (P2.R and $0F0) shl 4;
      t := t + (P2.G and $0F0);
      t := t + ((P2.B and $0F0) shr 4);
      DPtr^ := ColorTable[t];
      Inc(P2);
      Inc(DPtr);
    end;
    Dec(dword(p), Width * 4);
  end;
    {
    SPtr := SBitmap;
    Inc(SPtr, (Height - 1) * Width * 4);
    DPtr := DBitMap.ScanLine[Height - 1];
    for i := 0 to (Height - 1) do
    begin
      SPtr2 := SPtr;
      for j := 0 to (Width - 1) do
      begin
        t := (SPtr2.R and $0F0) shl 4;
        t := t + (SPtr2.G and $0F0);
        t := t + ((SPtr2.B and $0F0) shr 4);
        DPtr^ := ColorTable[t];
        Inc(SPtr2);
        Inc(DPtr);
      end;
      Dec(SPtr, Width * 4);
    end;
    }
end; //procedure Convert

end.


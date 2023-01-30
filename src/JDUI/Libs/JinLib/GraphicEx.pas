unit GraphicEx;

// GraphicEx -
//   This unit is an extension of Graphics.pas, in order to
//   import other graphic files than those Delphi allows.
//   Currently supported image file types are:
//     - TIFF images (*.tif; *.tiff)
//       * uncompressed
//       * LZW compressed
//     - SGI black & white images (*.bw)
//     - SGI RGB images (*.rgb)
//     - Autodesk CEL files (*.cel)
//     - Autodesk PIC files (*.pic)
//     - Truevision images (*.tga; *.vst; *.icb; *.vda; *.win)
//       * uncompressed
//       * RLE compressed
//
//   Additionally, there are some support routines to stretch images.
//
// version - 3.3
// last change : 01. November 1999
//
// Note: PCX import is not yet finished. The library provides mainly load support for
//       the listed image formats but will be enhanced in the future to save those types too.
//
// (c) Copyright 1999, Dipl. Ing. Mike Lischke (public@lischke-online.de)

{$R-}

interface

uses
  Windows, Classes, ExtCtrls, Graphics, SysUtils, JPEG, GraphicCompression;

type
  // *.bw, *.rgb (SGI) images
  PCardinalVector = ^TCardinalVector;
  TCardinalVector = array[0..0] of Cardinal;
  TSGIGraphic = class(TBitmap)
  private
    FStartPosition: Cardinal;
    FRowStart,
    FRowSize: PCardinalVector;   // actually start and length of a line
    FRowBuffer: Pointer;        // buffer to hold one line while loading
    FImageType: Word;
    function InitStructures(Stream: TStream): Cardinal;
    procedure GetRow(Stream: TStream; Buffer: Pointer; Line, Component: Cardinal);
  public
    procedure LoadFromStream(Stream: TStream); override;
  end;

  // *.cel, *.pic images
  TAutodeskGraphic = class(TBitmap)
  public
    procedure LoadFromStream(Stream: TStream); override;
  end;

  // *.tif, *.tiff images
  PCardinal = ^Cardinal;
  TTIFFGraphic = class(TBitmap)
  private
    FIFD: TObject;
    FInternalPalette: Integer;
    procedure Depredict1(StartPtr: Pointer; Count: Cardinal);
    procedure Depredict3(StartPtr: Pointer; Count: Cardinal);
    procedure Depredict4(StartPtr: Pointer; Count: Cardinal);
    procedure ScrambleBitmapPalette(BPS: Byte; Mode: Integer; BMPInfo: PBitmapInfo);
    procedure ScramblePalette(BPS: Byte; Mode: Integer);
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure SaveToTifFile(FileName: String; Compressing: Boolean);
    procedure SaveToTifFileSLZW(FileName: String; SmoothRange: TSmoothRange);
    procedure LoadFromStream(Stream: TStream); override;
    // override inherited SaveToStream method...
    procedure SaveToStream(Stream: TStream); overload; override;
    // ...and introduce new SaveToStream method with an additional parameter
    procedure SaveToStream(Stream: TStream; Compressed: Boolean); reintroduce; overload;
  end;

  // *.tga; *.vst; *.icb; *.vda; *.win
  TTargaGraphic = class(TBitmap)
  private
    FImageID: String;
   public
    procedure LoadFromResourceName(Instance: THandle; const ResName: String);
    procedure LoadFromResourceID(Instance: THandle; ResID: Integer);
    procedure LoadFromStream(Stream: TStream); override;
    // override inherited SaveToStream method...
    procedure SaveToStream(Stream: TStream); overload; override;
    // ...and introduce new SaveToStream method with an additional parameter
    procedure SaveToStream(Stream: TStream; Compressed: Boolean); reintroduce; overload;

    property ImageID: String read FImageID write FImageID;
  end;

  TPCXGraphic = class(TBitmap)
   public
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
  end;

  TResamplingFilter = (sfBox, sfTriangle, sfHermite, sfBell, sfSpline, sfLanczos3, sfMitchell);

// Resampling support routines
procedure Stretch(NewWidth, NewHeight: Cardinal; Filter: TResamplingFilter; Radius: Single; Source, Target: TBitmap); overload;
procedure Stretch(NewWidth, NewHeight: Cardinal; Filter: TResamplingFilter; Radius: Single; Source: TBitmap); overload;

//----------------------------------------------------------------------------------------------------------------------

implementation

uses
  Consts, Dialogs, Math, ClipBrd;

type
  // resampling support types
  TRGBInt = record
   R, G, B: Integer;
  end;

  PRGB = ^TRGB;
  TRGB = packed record
   B, G, R: Byte;
  end;

  PPixelArray = ^TPixelArray;
  TPixelArray = array[0..0] of TRGB;

  TFilterFunction = function(Value: Single): Single;

  // contributor for a Pixel
  PContributor = ^TContributor;
  TContributor = record
   Weight: Integer; // Pixel Weight 
   Pixel: Integer; // Source Pixel
  end;

  TContributors = array of TContributor;

  // list of source pixels contributing to a destination pixel
  TContributorEntry = record
   N: Integer;
   Contributors: TContributors;
  end;

  TContributorList = array of TContributorEntry;

const
  DefaultFilterRadius: array[TResamplingFilter] of Single = (0.5, 1, 1, 1.5, 2, 3, 2);

threadvar // globally used cache for current image (speeds up resampling about 10%)
  CurrentLineR: array of Integer;
  CurrentLineG: array of Integer;
  CurrentLineB: array of Integer;

//----------------- helper functions -----------------------------------------------------------------------------------

function IntToByte(Value: Integer): Byte;

begin
  if Value < 0 then Result :=  0
               else
    if Value > 255 then Result := 255
                   else Result := Value;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure SwapRGB2BGR(P: Pointer; Count: Cardinal); assembler;

// reorders a stream of "Count" RGB values to BGR (or vice versa)
// EAX contains P and EDX Count

asm
              MOV ECX, EDX
              MOV EDX, EAX
@@1:          MOV AL, [EDX]
              XCHG AL, [EDX + 2]
              MOV [EDX], AL
              ADD EDX, 3
              DEC ECX
              JNZ @@1
end;

//----------------------------------------------------------------------------------------------------------------------

procedure SwapRGBA2BGRA(P: Pointer; Count: Cardinal);

// reorders a stream of "Count" RGBA values to BGRA (or vice versa)
// EAX contains P and EDX Count

asm
              MOV ECX, EDX
              MOV EDX, EAX
@@1:          MOV AL, [EDX]
              XCHG AL, [EDX + 2]
              MOV [EDX], AL
              ADD EDX, 4
              DEC ECX
              JNZ @@1
end;

//----------------- filter functions for stretching --------------------------------------------------------------------

function HermiteFilter(Value: Single): Single;

// f(t) = 2|t|^3 - 3|t|^2 + 1, -1 <= t <= 1

begin
  if Value < 0 then Value := -Value;
  if Value < 1 then Result := (2 * Value - 3) * Sqr(Value) + 1
               else Result := 0;
end;

//----------------------------------------------------------------------------------------------------------------------

function BoxFilter(Value: Single): Single;

// This filter is also known as 'nearest neighbour' Filter.

begin
  if (Value > -0.5) and (Value <= 0.5) then Result := 1
                                       else Result := 0;
end;

//----------------------------------------------------------------------------------------------------------------------

function TriangleFilter(Value: Single): Single;

// aka 'linear' or 'bilinear' filter

begin
  if Value < 0 then Value := -Value;
  if Value < 1 then Result := 1 - Value
               else Result := 0;
end;

//----------------------------------------------------------------------------------------------------------------------

function BellFilter(Value: Single): Single;

begin
  if Value < 0 then Value := -Value;
  if Value < 0.5 then Result := 0.75 - Sqr(Value)
                 else
    if Value < 1.5 then
    begin
      Value := Value - 1.5;
      Result := 0.5 * Sqr(Value);
    end
    else Result := 0;
end;

//----------------------------------------------------------------------------------------------------------------------

function SplineFilter(Value: Single): Single;

// B-spline filter

var
  Temp: Single;

begin
  if Value < 0 then Value := -Value;
  if Value < 1 then
  begin
    Temp := Sqr(Value);
    Result := 0.5 * Temp * Value - Temp + 2 / 3;
  end
  else
    if Value < 2 then
    begin
      Value := 2 - Value;
      Result := Sqr(Value) * Value / 6;
    end
    else Result := 0;
end;

//----------------------------------------------------------------------------------------------------------------------

function Lanczos3Filter(Value: Single): Single;

  //--------------- local function --------------------------------------------

  function SinC(Value: Single): Single;

  begin
    if Value <> 0 then
    begin
      Value := Value * Pi;
      Result := Sin(Value) / Value;
    end
    else Result := 1;
  end;

  //---------------------------------------------------------------------------

begin
  if Value < 0 then Value := -Value;
  if Value < 3 then Result := SinC(Value) * SinC(Value / 3)
               else Result := 0;
end;

//----------------------------------------------------------------------------------------------------------------------

function MitchellFilter(Value: Single): Single;

const
  B = 1 / 3;
  C = 1 / 3;

var Temp: Single;

begin
  if Value < 0 then Value := -Value;
  Temp := Sqr(Value);
  if Value < 1 then
  begin
    Value := (((12 - 9 * B - 6 * C) * (Value * Temp))
             + ((-18 + 12 * B + 6 * C) * Temp)
             + (6 - 2 * B));
    Result := Value / 6;
  end
  else
    if Value < 2 then
    begin
      Value := (((-B - 6 * C) * (Value * Temp))
               + ((6 * B + 30 * C) * Temp)
               + ((-12 * B - 48 * C) * Value)
               + (8 * B + 24 * C));
      Result := Value / 6;
    end
    else Result := 0;
end;

//----------------------------------------------------------------------------------------------------------------------

const FilterList: array[TResamplingFilter] of TFilterFunction =
        (BoxFilter,
         TriangleFilter,
         HermiteFilter,
         BellFilter,
         SplineFilter,
         Lanczos3Filter,
         MitchellFilter);

//----------------------------------------------------------------------------------------------------------------------

procedure FillLineChache(N, Delta: Integer; Line: Pointer);

var
  I: Integer;
  Run: PRGB;

begin
  Run := Line;
  for I := 0 to N - 1 do
  begin
    CurrentLineR[I] := Run.R;
    CurrentLineG[I] := Run.G;
    CurrentLineB[I] := Run.B;
    Inc(PByte(Run), Delta);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function ApplyContributors(N: Integer; Contributors: TContributors): TRGB;

var
  J: Integer;
  RGB: TRGBInt;
  Weight: Integer;
  Pixel: Cardinal;
  Contr: ^TContributor;
    
begin
  RGB.R := 0;
  RGB.G := 0;
  RGB.B := 0;
  Contr := @Contributors[0];
  for J := 0 to N - 1 do
  begin
    Weight := Contr.Weight;
    Pixel := Contr.Pixel;
    Inc(RGB.r, CurrentLineR[Pixel] * Weight);
    Inc(RGB.g, CurrentLineG[Pixel] * Weight);
    Inc(RGB.b, CurrentLineB[Pixel] * Weight);

    Inc(Contr);
  end;

  Result.R := IntToByte(RGB.R div 256);
  Result.G := IntToByte(RGB.G div 256);
  Result.B := IntToByte(RGB.B div 256);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure DoStretch(Filter: TFilterFunction; Radius: Single; Source, Target: TBitmap);

// This is the actual scaling routine. Target must be allocated already with sufficient size. Source must
// contain valid data, Radius must not be 0 and Filter must not be nil.

var
  ScaleX,
  ScaleY: Single;  // Zoom scale factors
  I, J,
  K, N: Integer; // Loop variables
  Center: Single; // Filter calculation variables
  Width: Single;
  Weight: Integer;  // Filter calculation variables
  Left,
  Right: Integer; // Filter calculation variables
  Work: TBitmap;
  ContributorList: TContributorList;
  SourceLine,
  DestLine: PPixelArray;
  DestPixel: PRGB;
  Delta,
  DestDelta: Integer;
  SourceHeight,
  SourceWidth,
  TargetHeight,
  TargetWidth: Integer;

begin
  // shortcut variables
  SourceHeight := Source.Height;
  SourceWidth := Source.Width;
  TargetHeight := Target.Height;
  TargetWidth := Target.Width;
  // create intermediate image to hold horizontal zoom
  Work := TBitmap.Create;
  try
    Work.PixelFormat := pf24Bit;
    Work.Height := SourceHeight;
    Work.Width := TargetWidth;
    if SourceWidth = 1 then ScaleX :=  TargetWidth / SourceWidth
                       else ScaleX :=  (TargetWidth - 1) / (SourceWidth - 1);
    if SourceHeight = 1 then ScaleY :=  TargetHeight / SourceHeight
                        else ScaleY :=  (TargetHeight - 1) / (SourceHeight - 1);

    // pre-calculate filter contributions for a row
    SetLength(ContributorList, TargetWidth);
    // horizontal sub-sampling
    if ScaleX < 1 then
    begin
      // scales from bigger to smaller Width
      Width := Radius / ScaleX;
      for I := 0 to TargetWidth - 1 do
      begin
        ContributorList[I].N := 0;
        SetLength(ContributorList[I].Contributors, Trunc(2 * Width + 1));
        Center := I / ScaleX;
        Left := Floor(Center - Width);
        Right := Ceil(Center + Width);
        for J := Left to Right do
        begin
          Weight := Round(Filter((Center - J) * ScaleX) * ScaleX * 256);
          if Weight <> 0 then
          begin
            if J < 0 then N := -J
                     else
              if J >= SourceWidth then N := SourceWidth - J + SourceWidth - 1
                                  else N := J;
            K := ContributorList[I].N;
            Inc(ContributorList[I].N);
            ContributorList[I].Contributors[K].Pixel := N;
            ContributorList[I].Contributors[K].Weight := Weight;
          end;
        end;
      end;
    end
    else
    begin
      // horizontal super-sampling
      // scales from smaller to bigger Width
      for I := 0 to TargetWidth - 1 do
      begin
        ContributorList[I].N := 0;
        SetLength(ContributorList[I].Contributors, Trunc(2 * Radius + 1));
        Center := I / ScaleX;
        Left := Floor(Center - Radius);
        Right := Ceil(Center + Radius);
        for J := Left to Right do
        begin
          Weight := Round(Filter(Center - J) * 256);
          if Weight <> 0 then
          begin
            if J < 0 then N := -J
                     else
             if J >= SourceWidth then N := SourceWidth - J + SourceWidth - 1
                                 else N := J;
            K := ContributorList[I].N;
            Inc(ContributorList[I].N);
            ContributorList[I].Contributors[K].Pixel := N;
            ContributorList[I].Contributors[K].Weight := Weight;
          end;
        end;
      end;
    end;

    // now apply filter to sample horizontally from Src to Work
    SetLength(CurrentLineR, SourceWidth);
    SetLength(CurrentLineG, SourceWidth);
    SetLength(CurrentLineB, SourceWidth);
    for K := 0 to SourceHeight - 1 do
    begin
      SourceLine := Source.ScanLine[K];
      FillLineChache(SourceWidth, 3, SourceLine);
      DestPixel := Work.ScanLine[K];
      for I := 0 to TargetWidth - 1 do
        with ContributorList[I] do
        begin
          DestPixel^ := ApplyContributors(N, ContributorList[I].Contributors);
          // move on to next column
          Inc(DestPixel);
        end;
    end;

    // free the memory allocated for horizontal filter weights, since we need the stucture again
    for I := 0 to TargetWidth - 1 do ContributorList[I].Contributors := nil;
    ContributorList := nil;

    // pre-calculate filter contributions for a column
    SetLength(ContributorList, TargetHeight);
    // vertical sub-sampling
    if ScaleY < 1 then
    begin
      // scales from bigger to smaller height
      Width := Radius / ScaleY;
      for I := 0 to TargetHeight - 1 do
      begin
        ContributorList[I].N := 0;
        SetLength(ContributorList[I].Contributors, Trunc(2 * Width + 1));
        Center := I / ScaleY;
        Left := Floor(Center - Width);
        Right := Ceil(Center + Width);
        for J := Left to Right do
        begin
          Weight := Round(Filter((Center - J) * ScaleY) * ScaleY * 256);
          if Weight <> 0 then
          begin
            if J < 0 then N := -J
                     else
              if J >= SourceHeight then N := SourceHeight - J + SourceHeight - 1
                                   else N := J;
            K := ContributorList[I].N;
            Inc(ContributorList[I].N);
            ContributorList[I].Contributors[K].Pixel := N;
            ContributorList[I].Contributors[K].Weight := Weight;
          end;
        end;
      end
    end
    else
    begin
      // vertical super-sampling
      // scales from smaller to bigger height
      for I := 0 to TargetHeight - 1 do
      begin
        ContributorList[I].N := 0;
        SetLength(ContributorList[I].Contributors, Trunc(2 * Radius + 1));
        Center := I / ScaleY;
        Left := Floor(Center - Radius);
        Right := Ceil(Center + Radius);
        for J := Left to Right do
        begin
          Weight := Round(Filter(Center - J) * 256);
          if Weight <> 0 then
          begin
            if J < 0 then N := -J
                     else
              if J >= SourceHeight then N := SourceHeight - J + SourceHeight - 1
                                   else N := J;
            K := ContributorList[I].N;
            Inc(ContributorList[I].N);
            ContributorList[I].Contributors[K].Pixel := N;
            ContributorList[I].Contributors[K].Weight := Weight;
          end;
        end;
      end;
    end;

    // apply filter to sample vertically from Work to Target
    SetLength(CurrentLineR, SourceHeight);
    SetLength(CurrentLineG, SourceHeight);
    SetLength(CurrentLineB, SourceHeight);


    SourceLine := Work.ScanLine[0];
    Delta := Integer(Work.ScanLine[1]) - Integer(SourceLine);
    DestLine := Target.ScanLine[0];
    DestDelta := Integer(Target.ScanLine[1]) - Integer(DestLine);
    for K := 0 to TargetWidth - 1 do
    begin
      DestPixel := Pointer(DestLine);
      FillLineChache(SourceHeight, Delta, SourceLine);
      for I := 0 to TargetHeight - 1 do
        with ContributorList[I] do
        begin
          DestPixel^ := ApplyContributors(N, ContributorList[I].Contributors);
          Inc(Integer(DestPixel), DestDelta);
        end;
      Inc(SourceLine);
      Inc(DestLine);
    end;

    // free the memory allocated for vertical filter weights
    for I := 0 to TargetHeight - 1 do ContributorList[I].Contributors := nil;
    // this one is done automatically on exit, but is here for completeness
    ContributorList := nil;

  finally
    Work.Free;
    CurrentLineR := nil;
    CurrentLineG := nil;
    CurrentLineB := nil;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure Stretch(NewWidth, NewHeight: Cardinal; Filter: TResamplingFilter; Radius: Single; Source, Target: TBitmap);

// Scales the source bitmap to the given size (NewWidth, NewHeight) and stores the Result in Target.
// Filter describes the filter function to be applied and Radius the size of the filter area.
// Is Radius = 0 then the recommended filter area will be used (see DefaultFilterRadius).

begin
  if Radius = 0 then Radius := DefaultFilterRadius[Filter];
  Target.FreeImage;
  Target.PixelFormat := pf24Bit;
  Target.Width := NewWidth;
  Target.Height := NewHeight;
  Source.PixelFormat := pf24Bit;
  DoStretch(FilterList[Filter], Radius, Source, Target);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure Stretch(NewWidth, NewHeight: Cardinal; Filter: TResamplingFilter; Radius: Single; Source: TBitmap);

var
  Target: TBitmap;

begin
  if Radius = 0 then Radius := DefaultFilterRadius[Filter];
  Target := TBitmap.Create;
  try
    Target.PixelFormat := pf24Bit;
    Target.Width := NewWidth;
    Target.Height := NewHeight;
    Source.PixelFormat := pf24Bit;
    DoStretch(FilterList[Filter], Radius, Source, Target);
    Source.Assign(Target);
  finally
    Target.Free;
  end;
end;

//----------------- TAutodeskGraphic -----------------------------------------------------------------------------------

procedure TAutodeskGraphic.LoadFromStream(Stream: TStream);

type
  TFileHeader = packed record
    Width,
    Height,
    XCoord,
    YCoord: Word;
    Depth,
    Compress: Byte;
    DataSize: Cardinal;
    Reserved: array[0..15] of Byte;
  end;

var
  FileID: Word;
  FileHeader: TFileHeader;
  LogPalette: TMaxLogPalette;
  I: Integer;

begin
  with Stream do
  begin
    Read(FileID, 2);
    if FileID <> $9119 then raise Exception.Create('Cannot load image. Only old style Autodesk images are supported.')
                       else
    begin
      // read image dimensions
      Read(FileHeader, SizeOf(FileHeader));
      // read palette entries and create a palette
      FillChar(LogPalette, SizeOf(LogPalette), 0);
      LogPalette.palVersion := $300;
      LogPalette.palNumEntries := 256;
      for I := 0 to 255 do
      begin
        Read(LogPalette.palPalEntry[I], 3);
        LogPalette.palPalEntry[I].peBlue := LogPalette.palPalEntry[I].peBlue shl 2;
        LogPalette.palPalEntry[I].peGreen := LogPalette.palPalEntry[I].peGreen shl 2;
        LogPalette.palPalEntry[I].peRed := LogPalette.palPalEntry[I].peRed shl 2;
      end;

      // setup bitmap properties
      PixelFormat := pf8Bit;
      Palette := CreatePalette(PLogPalette(@LogPalette)^);
      Width := FileHeader.Width;
      Height := FIleHeader.Height;
      // finally read image data
      for I := 0 to Height - 1 do
        Read(Scanline[I]^, FileHeader.Width);
    end;
  end;
end;

//----------------- TSGIGraphic ----------------------------------------------------------------------------------------

procedure TSGIGraphic.GetRow(Stream: TStream; Buffer: Pointer; Line, Component: Cardinal);

var
  Source,
  Target: PByte;
  Pixel: Byte;
  Count: Cardinal;

begin
  with Stream do
    // compressed image?
    if (FImageType and $FF00) = $0100 then
    begin
      Position := FStartPosition + FRowStart[Line + Component * Cardinal(Height)];
      Read(FRowBuffer^, FRowSize[Line + Component * Cardinal(Height)]);
      Source := FRowBuffer;
      Target := Buffer;
      while True do
      begin
        Pixel := Source^;
        Inc(Source);
        Count := Pixel and $7F;
        if Count = 0 then Break;

        if (Pixel and $80) <> 0 then
          while Count > 0 do
          begin
            Target^ := Source^;
            Inc(Target);
            Inc(Source);
            Dec(Count);
          end
        else
        begin
          Pixel := Source^;
          Inc(Source);
          while Count > 0 do
          begin
            Target^ := Pixel;
            Inc(Target);
            Dec(Count);
          end;
        end;
      end;
    end
    else
    begin
      // no, not a compressed image, so just read the bytes
      Stream.Position := FStartPosition + 512 + (Line * Cardinal(Width)) + (Component * Cardinal(Width) * Cardinal(Height));
      Stream.Read(Buffer^, Width);
    end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure SwapShort(P: PWord; Count: Cardinal);

begin
  while Count > 0 do
  begin
    P^ := Swap(P^);
    Inc(P);
    Dec(Count);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure SwapLong(P: PInteger; Count: Cardinal);

begin
  while Count > 0 do
  begin
    P^ := Swap(LoWord(P^)) shl 16 + Swap(HiWord(P^));
    Inc(P);
    Dec(Count);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TSGIGraphic.InitStructures(Stream: TStream): Cardinal;

// allocates memory for row positions and sizes buffers and returns type of image
// 4 - RGBA
// 3 - RGB
// else - 256 gray values

var
  Count: Cardinal;

  ImageRec: packed record
    Magic,
    ImageType,
    Dim,
    XSize,            // width of image
    YSize,            // height of image
    ZSize: Word;      // number of planes in image (3 for RGB etc.)
  end;

begin
  Result := 0; // shut up compiler...
  with Stream do
  try
    Read(ImageRec, 12);
    FImageType := ImageRec.ImageType;

    // SGI images are stored in big endian style, so we need to swap all bytes in the header
    SwapShort(@ImageRec.Magic, 6);
    GetMem(FRowBuffer, ImageRec.XSize * 256);

    if (FImageType and $FF00) = $0100 then
    begin
      Count := ImageRec.YSize * ImageRec.ZSize * SizeOf(Cardinal);
      GetMem(FRowStart, Count);
      GetMem(FRowSize, Count);
      Stream.Position := FStartPosition + 512;
      // read line starts and sizes from stream
      Read(FRowStart^, Count);
      SwapLong(PInteger(FRowStart), Count div SizeOf(Cardinal));
      Read(FRowSize^, Count);
      SwapLong(PInteger(FRowSize), Count div SizeOf(Cardinal));
    end;
    Result := ImageRec.ZSize;
    Width := ImageRec.XSize;
    Height := ImageRec.YSize;
  except
    if Assigned(FRowBuffer) then FreeMem(FRowBuffer);
    if Assigned(FRowStart) then FreeMem(FRowStart);
    if Assigned(FRowSize) then FreeMem(FRowSize);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TSGIGraphic.LoadFromStream(Stream: TStream);

var
  X, Y,
  ImageType: Integer;
  RedBuffer,
  GreenBuffer,
  BlueBuffer,
  AlphaBuffer,
  R, G, B, A,
  Target: PByte;
  LogPalette: TMaxLogPalette;

begin
  // keep start position for seek operations
  FStartPosition := Stream.Position;
  // allocate memory and do endian to endian conversion
  ImageType := InitStructures(Stream);
  // read lines and put it into the bitmap
  case ImageType of
    4: // RGBA image
      begin
        PixelFormat := pf32Bit;
        GetMem(RedBuffer, Width);
        GetMem(GreenBuffer, Width);
        GetMem(BlueBuffer, Width);
        GetMem(AlphaBuffer, Width);
        for  Y := 0 to Height - 1 do
        begin
          GetRow(Stream, RedBuffer, Y, 0);
          GetRow(Stream, GreenBuffer, Y, 1);
          GetRow(Stream, BlueBuffer, Y, 2);
          GetRow(Stream, AlphaBuffer, Y, 3);
          Target := ScanLine[Height - Y - 1];
          R := RedBuffer;
          G := GreenBuffer;
          B := BlueBuffer;
          A := AlphaBuffer;
          // convert single component buffers into a scanline (note: Windows bitmaps are in
          // format BGRA)
          for X := 0 to Width - 1 do
          begin
            Target^ := B^;
            Inc(Target);
            Inc(B);
            Target^ := G^;
            Inc(Target);
            Inc(G);
            Target^ := R^;
            Inc(Target);
            Inc(R);
            Target^ := A^;
            Inc(Target);
            Inc(A);
          end;
        end;
        FreeMem(RedBuffer);
        FreeMem(GreenBuffer);
        FreeMem(BlueBuffer);
        FreeMem(AlphaBuffer);
      end;
    3: // RGB image
      begin
        PixelFormat := pf24Bit;
        GetMem(RedBuffer, Width);
        GetMem(GreenBuffer, Width);
        GetMem(BlueBuffer, Width);
        for  Y := 0 to Height - 1 do
        begin
          GetRow(Stream, RedBuffer, Y, 0);
          GetRow(Stream, GreenBuffer, Y, 1);
          GetRow(Stream, BlueBuffer, Y, 2);
          Target := ScanLine[Height - Y - 1];
          R := RedBuffer;
          G := GreenBuffer;
          B := BlueBuffer;
          // convert single component buffers into a scanline (note: Windows bitmaps are in
          // format BGR)
          for X := 0 to Width - 1 do
          begin
            Target^ := B^;
            Inc(Target);
            Inc(B);
            Target^ := G^;
            Inc(Target);
            Inc(G);
            Target^ := R^;
            Inc(Target);
            Inc(R);
          end;
        end;
        FreeMem(RedBuffer);
        FreeMem(GreenBuffer);
        FreeMem(BlueBuffer);
      end;
  else
    // any other format is interpreted as being 256 gray scales
    PixelFormat := pf8Bit;
    FillChar(LogPalette, SizeOf(LogPalette), 0);
    LogPalette.palVersion := $300;
    LogPalette.palNumEntries := 256;
    for Y := 0 to 255 do
    begin
      LogPalette.palPalEntry[Y].peBlue := Y;
      LogPalette.palPalEntry[Y].peGreen := Y;
      LogPalette.palPalEntry[Y].peRed := Y;
    end;

    // setup bitmap properties
    Palette := CreatePalette(PLogPalette(@LogPalette)^);
    for  Y := 0 to Height - 1 do
      GetRow(Stream, ScanLine[Height - Y - 1], Y, 0);
  end;

  // free all other intermediate data
  if Assigned(FRowBuffer) then FreeMem(FRowBuffer);
  FRowBuffer := nil;
  if Assigned(FRowStart) then FreeMem(FRowStart);
  FRowStart := nil;
  if Assigned(FRowSize) then FreeMem(FRowSize);
  FRowSize := nil;
  if Assigned(FRowBuffer) then FreeMem(FRowBuffer);
  FRowBuffer := nil;
end;

//----------------- TTIFFGraphic ---------------------------------------------------------------------------------------

const // TIFF tags
  TIFFTAG_SUBFILETYPE = 254;                     // subfile data descriptor
    FILETYPE_REDUCEDIMAGE = $1;                  // reduced resolution version
    FILETYPE_PAGE = $2;                          // one page of many
    FILETYPE_MASK = $4;                          // transparency mask
  TIFFTAG_OSUBFILETYPE = 255;                    // kind of data in subfile (obsolete by revision 5.0)
    OFILETYPE_IMAGE = 1;                         // full resolution image data
    OFILETYPE_REDUCEDIMAGE = 2;                  // reduced size image data
    OFILETYPE_PAGE = 3;                          // one page of many
  TIFFTAG_IMAGEWIDTH = 256;                      // image width in pixels
  TIFFTAG_IMAGELENGTH = 257;                     // image height in pixels
  TIFFTAG_BITSPERSAMPLE = 258;                   // bits per channel (sample)
  TIFFTAG_COMPRESSION = 259;                     // data compression technique
    COMPRESSION_NONE = 1;                        // dump mode
    COMPRESSION_CCITTRLE = 2;                    // CCITT modified Huffman RLE
    COMPRESSION_CCITTFAX3 = 3;                   // CCITT Group 3 fax encoding
    COMPRESSION_CCITTFAX4 = 4;                   // CCITT Group 4 fax encoding
    COMPRESSION_LZW = 5;                         // Lempel-Ziv & Welch
    COMPRESSION_OJPEG = 6;                       // 6.0 JPEG
    COMPRESSION_JPEG = 7;                        // JPEG DCT compression
    COMPRESSION_NEXT = 32766;                    // next 2-bit RLE
    COMPRESSION_CCITTRLEW = 32771;               // #1 w/ Word alignment
    COMPRESSION_PACKBITS = 32773;                // Macintosh RLE
    COMPRESSION_THUNDERSCAN = 32809;             // ThunderScan RLE
    // codes 32895-32898 are reserved for ANSI IT8 TIFF/IT <dkelly@etsinc.com)
    COMPRESSION_IT8CTPAD = 32895;                // IT8 CT w/padding
    COMPRESSION_IT8LW = 32896;                   // IT8 Linework RLE
    COMPRESSION_IT8MP = 32897;                   // IT8 Monochrome picture
    COMPRESSION_IT8BL = 32898;                   // IT8 Binary line art
    // compression codes 32908-32911 are reserved for Pixar
    COMPRESSION_PIXARFILM = 32908;               // Pixar companded 10bit LZW
    COMPRESSION_PIXARLOG = 32909;                // Pixar companded 11bit ZIP
    COMPRESSION_DEFLATE = 32946;                 // Deflate compression
    // compression code 32947 is reserved for Oceana Matrix <dev@oceana.com>
    COMPRESSION_DCS = 32947;                     // Kodak DCS encoding
    COMPRESSION_JBIG = 34661;                    // ISO JBIG
  TIFFTAG_PHOTOMETRIC = 262;                     // photometric interpretation
    PHOTOMETRIC_MINISWHITE = 0;                  // min value is white
    PHOTOMETRIC_MINISBLACK = 1;                  // min value is black
    PHOTOMETRIC_RGB = 2;                         // RGB color model
    PHOTOMETRIC_PALETTE = 3;                     // color map indexed
    PHOTOMETRIC_MASK = 4;                        // holdout mask
    PHOTOMETRIC_SEPARATED = 5;                   // color separations
    PHOTOMETRIC_YCBCR = 6;                       // CCIR 601
    PHOTOMETRIC_CIELAB = 8;                      // 1976 CIE L*a*b*
  TIFFTAG_THRESHHOLDING = 263;                   // thresholding used on data (obsolete by revision 5.0)
    THRESHHOLD_BILEVEL = 1;                      // b&w art scan
    THRESHHOLD_HALFTONE = 2;                     // or dithered scan
    THRESHHOLD_ERRORDIFFUSE = 3;                 // usually floyd-steinberg
  TIFFTAG_CELLWIDTH = 264;                       // dithering matrix width (obsolete by revision 5.0)
  TIFFTAG_CELLLENGTH = 265;                      // dithering matrix height (obsolete by revision 5.0)
  TIFFTAG_FILLORDER = 266;                       // data order within a Byte
    FILLORDER_MSB2LSB = 1;                       // most significant -> least
    FILLORDER_LSB2MSB = 2;                       // least significant -> most
  TIFFTAG_DOCUMENTNAME = 269;                    // name of doc. image is from
  TIFFTAG_IMAGEDESCRIPTION = 270;                // info about image
  TIFFTAG_MAKE = 271;                            // scanner manufacturer name
  TIFFTAG_MODEL = 272;                           // scanner model name/number
  TIFFTAG_STRIPOFFSETS = 273;                    // FOffsets to data strips
  TIFFTAG_ORIENTATION = 274;                     // image FOrientation (obsolete by revision 5.0)
    ORIENTATION_TOPLEFT = 1;                     // row 0 top, col 0 lhs
    ORIENTATION_TOPRIGHT = 2;                    // row 0 top, col 0 rhs
    ORIENTATION_BOTRIGHT = 3;                    // row 0 bottom, col 0 rhs
    ORIENTATION_BOTLEFT = 4;                     // row 0 bottom, col 0 lhs
    ORIENTATION_LEFTTOP = 5;                     // row 0 lhs, col 0 top
    ORIENTATION_RIGHTTOP = 6;                    // row 0 rhs, col 0 top
    ORIENTATION_RIGHTBOT = 7;                    // row 0 rhs, col 0 bottom
    ORIENTATION_LEFTBOT = 8;                     // row 0 lhs, col 0 bottom
  TIFFTAG_SAMPLESPERPIXEL = 277;                 // samples per pixel
  TIFFTAG_ROWSPERSTRIP = 278;                    // rows per strip of data
  TIFFTAG_STRIPBYTECOUNTS = 279;                 // bytes counts for strips
  TIFFTAG_MINSAMPLEVALUE = 280;                  // minimum sample value (obsolete by revision 5.0)
  TIFFTAG_MAXSAMPLEVALUE = 281;                  // maximum sample value (obsolete by revision 5.0)
  TIFFTAG_XRESOLUTION = 282;                     // pixels/resolution in x
  TIFFTAG_YRESOLUTION = 283;                     // pixels/resolution in y
  TIFFTAG_PLANARCONFIG = 284;                    // storage organization
    PLANARCONFIG_CONTIG = 1;                     // single image plane
    PLANARCONFIG_SEPARATE = 2;                   // separate planes of data
  TIFFTAG_PAGENAME = 285;                        // page name image is from
  TIFFTAG_XPOSITION = 286;                       // x page Offset of image lhs
  TIFFTAG_YPOSITION = 287;                       // y page Offset of image lhs
  TIFFTAG_FREEOFFSETS = 288;                     // Byte Offset to free block (obsolete by revision 5.0)
  TIFFTAG_FREEBYTECOUNTS = 289;                  // sizes of free blocks (obsolete by revision 5.0)
  TIFFTAG_GRAYRESPONSEUNIT = 290;                // gray scale curve accuracy
    GRAYRESPONSEUNIT_10S = 1;                    // tenths of a unit
    GRAYRESPONSEUNIT_100S = 2;                   // hundredths of a unit
    GRAYRESPONSEUNIT_1000S = 3;                  // thousandths of a unit
    GRAYRESPONSEUNIT_10000S = 4;                 // ten-thousandths of a unit
    GRAYRESPONSEUNIT_100000S = 5;                // hundred-thousandths
  TIFFTAG_GRAYRESPONSECURVE = 291;               // gray scale response curve
  TIFFTAG_GROUP3OPTIONS = 292;                   // 32 flag bits
    GROUP3OPT_2DENCODING = $1;                   // 2-dimensional coding
    GROUP3OPT_UNCOMPRESSED = $2;                 // data not compressed
    GROUP3OPT_FILLBITS = $4;                     // fill to byte boundary
  TIFFTAG_GROUP4OPTIONS = 293;                   // 32 flag bits
    GROUP4OPT_UNCOMPRESSED = $2;                 // data not compressed
  TIFFTAG_RESOLUTIONUNIT = 296;                  // units of resolutions
    RESUNIT_NONE = 1;                            // no meaningful units
    RESUNIT_INCH = 2;                            // english
    RESUNIT_CENTIMETER = 3;                      // metric
  TIFFTAG_PAGENUMBER = 297;                      // page numbers of multi-page
  TIFFTAG_COLORRESPONSEUNIT = 300;               // color curve accuracy
    COLORRESPONSEUNIT_10S = 1;                   // tenths of a unit
    COLORRESPONSEUNIT_100S = 2;                  // hundredths of a unit
    COLORRESPONSEUNIT_1000S = 3;                 // thousandths of a unit
    COLORRESPONSEUNIT_10000S = 4;                // ten-thousandths of a unit
    COLORRESPONSEUNIT_100000S = 5;               // hundred-thousandths
  TIFFTAG_TRANSFERFUNCTION = 301;                // colorimetry info
  TIFFTAG_SOFTWARE = 305;                        // name & release
  TIFFTAG_DATETIME = 306;                        // creation date and time
  TIFFTAG_ARTIST = 315;                          // creator of image
  TIFFTAG_HOSTCOMPUTER = 316;                    // machine where created
  TIFFTAG_PREDICTOR = 317;                       // FPrediction scheme w/ LZW
  TIFFTAG_WHITEPOINT = 318;                      // image white point
  TIFFTAG_PRIMARYCHROMATICITIES = 319;           // primary chromaticities
  TIFFTAG_COLORMAP = 320;                        // RGB map for pallette image
  TIFFTAG_HALFTONEHINTS = 321;                   // highlight+shadow info
  TIFFTAG_TILEWIDTH = 322;                       // rows/data tile
  TIFFTAG_TILELENGTH = 323;                      // cols/data tile
  TIFFTAG_TILEOFFSETS = 324;                     // FOffsets to data tiles
  TIFFTAG_TILEBYTECOUNTS = 325;                  // Byte counts for tiles
  TIFFTAG_BADFAXLINES = 326;                     // lines w/ wrong pixel count
  TIFFTAG_CLEANFAXDATA = 327;                    // regenerated line info
    CLEANFAXDATA_CLEAN = 0;                      // no errors detected
    CLEANFAXDATA_REGENERATED = 1;                // receiver regenerated lines
    CLEANFAXDATA_UNCLEAN = 2;                    // uncorrected errors exist
  TIFFTAG_CONSECUTIVEBADFAXLINES = 328;          // max consecutive bad lines
  TIFFTAG_SUBIFD = 330;                          // subimage descriptors
  TIFFTAG_INKSET = 332;                          // inks in separated image
    INKSET_CMYK = 1;                             // cyan-magenta-yellow-black
  TIFFTAG_INKNAMES = 333;                        // ascii names of inks
  TIFFTAG_DOTRANGE = 336;                        // 0% and 100% dot codes
  TIFFTAG_TARGETPRINTER = 337;                   // separation target
  TIFFTAG_EXTRASAMPLES = 338;                    // info about extra samples
    EXTRASAMPLE_UNSPECIFIED = 0;                 // unspecified data
    EXTRASAMPLE_ASSOCALPHA = 1;                  // associated alpha data
    EXTRASAMPLE_UNASSALPHA = 2;                  // unassociated alpha data
  TIFFTAG_SAMPLEFORMAT = 339;                    // data sample format
    SAMPLEFORMAT_UINT = 1;                       // unsigned integer data
    SAMPLEFORMAT_INT = 2;                        // signed integer data
    SAMPLEFORMAT_IEEEFP = 3;                     // IEEE floating point data
    SAMPLEFORMAT_VOID = 4;                       // untyped data
  TIFFTAG_SMINSAMPLEVALUE = 340;                 // variable MinSampleValue
  TIFFTAG_SMAXSAMPLEVALUE = 341;                 // variable MaxSampleValue
  TIFFTAG_JPEGTABLES = 347;                      // JPEG table stream

  // Tags 512-521 are obsoleted by Technical Note #2 which specifies a revised JPEG-in-TIFF scheme.

  TIFFTAG_JPEGPROC = 512;                        // JPEG processing algorithm
    JPEGPROC_BASELINE = 1;                       // baseline sequential
    JPEGPROC_LOSSLESS = 14;                      // Huffman coded lossless
  TIFFTAG_JPEGIFOFFSET = 513;                    // Pointer to SOI marker
  TIFFTAG_JPEGIFBYTECOUNT = 514;                 // JFIF stream length
  TIFFTAG_JPEGRESTARTINTERVAL = 515;             // restart interval length
  TIFFTAG_JPEGLOSSLESSPREDICTORS = 517;          // lossless proc predictor
  TIFFTAG_JPEGPOINTTRANSFORM = 518;              // lossless point transform
  TIFFTAG_JPEGQTABLES = 519;                     // Q matrice FOffsets
  TIFFTAG_JPEGDCTABLES = 520;                    // DCT table FOffsets
  TIFFTAG_JPEGACTABLES = 521;                    // AC coefficient FOffsets
  TIFFTAG_YCBCRCOEFFICIENTS = 529;               // RGB -> YCbCr transform
  TIFFTAG_YCBCRSUBSAMPLING = 530;                // YCbCr subsampling factors
  TIFFTAG_YCBCRPOSITIONING = 531;                // subsample positioning
    YCBCRPOSITION_CENTERED = 1;                  // as in PostScript Level 2
    YCBCRPOSITION_COSITED = 2;                   // as in CCIR 601-1
  TIFFTAG_REFERENCEBLACKWHITE = 532;             // colorimetry info
  // tags 32952-32956 are private tags registered to Island Graphics
  TIFFTAG_REFPTS = 32953;                        // image reference points
  TIFFTAG_REGIONTACKPOINT = 32954;               // region-xform tack point
  TIFFTAG_REGIONWARPCORNERS = 32955;             // warp quadrilateral
  TIFFTAG_REGIONAFFINE = 32956;                  // affine transformation mat
  // tags 32995-32999 are private tags registered to SGI
  TIFFTAG_MATTEING = 32995;                      // use ExtraSamples
  TIFFTAG_DATATYPE = 32996;                      // use SampleFormat
  TIFFTAG_IMAGEDEPTH = 32997;                    // z depth of image
  TIFFTAG_TILEDEPTH = 32998;                     // z depth/data tile

  // tags 33300-33309 are private tags registered to Pixar
  //
  // TIFFTAG_PIXAR_IMAGEFULLWIDTH and TIFFTAG_PIXAR_IMAGEFULLLENGTH
  // are set when an image has been cropped out of a larger image.
  // They reflect the size of the original uncropped image.
  // The TIFFTAG_XPOSITION and TIFFTAG_YPOSITION can be used
  // to determine the position of the smaller image in the larger one.

  TIFFTAG_PIXAR_IMAGEFULLWIDTH = 33300;          // full image size in x
  TIFFTAG_PIXAR_IMAGEFULLLENGTH = 33301;         // full image size in y
  // tag 33405 is a private tag registered to Eastman Kodak
  TIFFTAG_WRITERSERIALNUMBER = 33405;            // device serial number
  // tag 33432 is listed in the 6.0 spec w/ unknown ownership
  TIFFTAG_COPYRIGHT = 33432;                     // copyright string
  // 34016-34029 are reserved for ANSI IT8 TIFF/IT <dkelly@etsinc.com)
  TIFFTAG_IT8SITE = 34016;                       // site name
  TIFFTAG_IT8COLORSEQUENCE = 34017;              // color seq. [RGB,CMYK,etc]
  TIFFTAG_IT8HEADER = 34018;                     // DDES Header
  TIFFTAG_IT8RASTERPADDING = 34019;              // raster scanline padding
  TIFFTAG_IT8BITSPERRUNLENGTH = 34020;           // # of bits in short run
  TIFFTAG_IT8BITSPEREXTENDEDRUNLENGTH = 34021;   // # of bits in long run
  TIFFTAG_IT8COLORTABLE = 34022;                 // LW colortable
  TIFFTAG_IT8IMAGECOLORINDICATOR = 34023;        // BP/BL image color switch
  TIFFTAG_IT8BKGCOLORINDICATOR = 34024;          // BP/BL bg color switch
  TIFFTAG_IT8IMAGECOLORVALUE = 34025;            // BP/BL image color value
  TIFFTAG_IT8BKGCOLORVALUE = 34026;              // BP/BL bg color value
  TIFFTAG_IT8PIXELINTENSITYRANGE = 34027;        // MP pixel intensity value
  TIFFTAG_IT8TRANSPARENCYINDICATOR = 34028;      // HC transparency switch
  TIFFTAG_IT8COLORCHARACTERIZATION = 34029;      // color character. table
  // tags 34232-34236 are private tags registered to Texas Instruments
  TIFFTAG_FRAMECOUNT = 34232;                    // Sequence Frame Count
  // tag 34750 is a private tag registered to Pixel Magic
  TIFFTAG_JBIGOPTIONS = 34750;                   // JBIG options
  // tags 34908-34914 are private tags registered to SGI
  TIFFTAG_FAXRECVPARAMS = 34908;                 // encoded class 2 ses. parms
  TIFFTAG_FAXSUBADDRESS = 34909;                 // received SubAddr string
  TIFFTAG_FAXRECVTIME = 34910;                   // receive time (secs)
  // tag 65535 is an undefined tag used by Eastman Kodak
  TIFFTAG_DCSHUESHIFTVALUES = 65535;             // hue shift correction data

  // The following are ``pseudo tags'' that can be used to control codec-specific functionality.
  // These tags are not written to file.  Note that these values start at $FFFF + 1 so that they'll
  // never collide with Aldus-assigned tags.

  TIFFTAG_FAXMODE = 65536;                       // Group 3/4 format control
    FAXMODE_CLASSIC = $0000;                     // default, include RTC
    FAXMODE_NORTC = $0001;                       // no RTC at end of data
    FAXMODE_NOEOL = $0002;                       // no EOL code at end of row
    FAXMODE_BYTEALIGN = $0004;                   // Byte align row
    FAXMODE_WORDALIGN = $0008;                   // Word align row
    FAXMODE_CLASSF = FAXMODE_NORTC;              // TIFF class F
  TIFFTAG_JPEGQUALITY = 65537;                   // compression quality level
  // Note: quality level is on the IJG 0-100 scale.  Default value is 75
  TIFFTAG_JPEGCOLORMODE = 65538;                 // Auto RGB<=>YCbCr convert?
    JPEGCOLORMODE_RAW = $0000;                   // no conversion (default)
    JPEGCOLORMODE_RGB = $0001;                   // do auto conversion
  TIFFTAG_JPEGTABLESMODE = 65539;                // What to put in JPEGTables
    JPEGTABLESMODE_QUANT = $0001;                // include quantization tbls
    JPEGTABLESMODE_HUFF = $0002;                 // include Huffman tbls
  // Note: default is JPEGTABLESMODE_QUANT or JPEGTABLESMODE_HUFF
  TIFFTAG_FAXFILLFUNC = 65540;                   // G3/G4 fill function
  TIFFTAG_PIXARLOGDATAFMT = 65549;               // PixarLogCodec I/O data sz
    PIXARLOGDATAFMT_8BIT = 0;                    // regular u_char samples
    PIXARLOGDATAFMT_8BITABGR = 1;                // ABGR-order u_chars
    PIXARLOGDATAFMT_11BITLOG = 2;                // 11-bit log-encoded (raw)
    PIXARLOGDATAFMT_12BITPICIO = 3;              // as per PICIO (1.0==2048)
    PIXARLOGDATAFMT_16BIT = 4;                   // signed short samples
    PIXARLOGDATAFMT_FLOAT = 5;                   // IEEE float samples
  // 65550-65556 are allocated to Oceana Matrix <dev@oceana.com>
  TIFFTAG_DCSIMAGERTYPE = 65550;                 // imager model & filter
  DCSIMAGERMODEL_M3 = 0;                         // M3 chip (1280 x 1024)
  DCSIMAGERMODEL_M5 = 1;                         // M5 chip (1536 x 1024)
  DCSIMAGERMODEL_M6 = 2;                         // M6 chip (3072 x 2048)
  DCSIMAGERFILTER_IR = 0;                        // infrared filter
  DCSIMAGERFILTER_MONO = 1;                      // monochrome filter
  DCSIMAGERFILTER_CFA = 2;                       // color filter array
  DCSIMAGERFILTER_OTHER = 3;                     // other filter
  TIFFTAG_DCSINTERPMODE = 65551;                 // interpolation mode
  DCSINTERPMODE_NORMAL = $0;                     // whole image, default
  DCSINTERPMODE_PREVIEW = $1;                    // preview of image (384x256)
  TIFFTAG_DCSBALANCEARRAY = 65552;               // color balance values
  TIFFTAG_DCSCORRECTMATRIX = 65553;              // color correction values
  TIFFTAG_DCSGAMMA = 65554;                      // gamma value
  TIFFTAG_DCSTOESHOULDERPTS = 65555;             // toe & shoulder points
  TIFFTAG_DCSCALIBRATIONFD = 65556;              // calibration file desc
  // Note: quality level is on the ZLIB 1-9 scale. Default value is -1
  TIFFTAG_ZIPQUALITY = 65557;                    // compression quality level
  TIFFTAG_PIXARLOGQUALITY = 65558;               // PixarLog uses same scale

  // TIFF data types
  TIFF_NOTYPE = 0;                               // placeholder
  TIFF_BYTE = 1;                                 // 8-bit unsigned integer
  TIFF_ASCII = 2;                                // 8-bit bytes w/ last byte null
  TIFF_SHORT = 3;                                // 16-bit unsigned integer
  TIFF_LONG = 4;                                 // 32-bit unsigned integer
  TIFF_RATIONAL = 5;                             // 64-bit unsigned fraction
  TIFF_SBYTE = 6;                                // 8-bit signed integer
  TIFF_UNDEFINED = 7;                            // 8-bit untyped data
  TIFF_SSHORT = 8;                               // 16-bit signed integer
  TIFF_SLONG = 9;                                // 32-bit signed integer
  TIFF_SRATIONAL = 10;                           // 64-bit signed fraction
  TIFF_FLOAT = 11;                               // 32-bit IEEE floating point
  TIFF_DOUBLE = 12;                              // 64-bit IEEE floating point

  TIFF_BIGENDIAN = $4D4D;
  TIFF_LITTLEENDIAN = $4949;

  TIFF_VERSION = 42;
  
type
  TTag = record
    TagType,
    DataType: Word;
    DataLength,
    DataOrPointer: Cardinal;
  end;

  PTagSet = ^TTagSet;
  TTagSet = array[0..999] of TTag;

  POffsets =^TOffsets;
  TOffsets = array [0..0] of Cardinal;

  PByteCounts = POffsets;

  TIFD = class(TObject)
  private
    FVirtualPalette: Pointer;
    FPaletteCreated: Boolean;
    FPaletteSize: Cardinal;
    FFileHead: Pointer;
    FTags: PTagSet;
    FTagCount: Word;
    FNextIFD: Cardinal;
    FWidth: Word;
    FLength: Word;
    FBitsPerSample: Word;
    FBitsPerPixel: Word;
    FStripOffsets: Cardinal;
    FCompression: Word;
    FStripCount: Cardinal;
    FRowsPerStrip: Cardinal;
    FSamplesPerPixel: Word;
    FFillOrder: Byte;
    FOrientation: Byte;
    FPlanarConfiguration: Word;
    FColorMap: Cardinal;
    FStripByteCounts: Cardinal;
    FPhotometricInterpretation: Byte;
    FCompBits: Byte;
    FOffsets: POffSets;
    FByteCounts: PByteCounts;
    FPrediction: Boolean;
    function IncAddress(const Addr: Pointer; Shift: Integer): Pointer;
    function TagType(TagIndex: Byte): Word;
    function TagData(TagIndex: Byte): Cardinal;
    function TagPointer(TagIndex: Byte): Cardinal;
    function DataType(TagIndex: Byte): Word;
    function DataFieldLength(TagIndex: Byte): Cardinal;
    function GetTagIndex(TagCode: Word): Byte;
    function GetStripCount: Cardinal;
  protected
    procedure ReadInit(VirtFile: Pointer; Shift: Integer);
    procedure WriteInit(Source: TBitmap; Compressing: Boolean);
  public
    constructor ReadCreate(VirtFile: Pointer; Shift: Integer);
    constructor WriteCreate(Source: TBitmap; Compressing: Boolean);
    constructor CreateFromStream(Stream: TStream);
    destructor Destroy; override;

    function GetColor(ColorIndex: Word; RGBFlag: Byte): Byte;
    procedure InitFromStream(Stream: TStream);
  end;

//----------------- TIFD (TIF support class) ---------------------------------------------------------------------------

function TIFD.IncAddress(const Addr: Pointer; Shift: Integer): Pointer;

begin
  Result := Addr;
  Inc(Integer(Result), Shift);
end;

//----------------------------------------------------------------------------------------------------------------------

function TIFD.TagType(TagIndex: Byte): Word;

begin
  if TagIndex > (FTagCount - 1) then Result := 0
                                else Result := FTags[TagIndex].TagType;
end;

//----------------------------------------------------------------------------------------------------------------------

function TIFD.TagData(TagIndex: Byte): Cardinal;

var
  P: ^Cardinal;

begin
  if TagIndex > FTagCount - 1 then Result := 0
                              else
  begin
    Result := FTags[TagIndex].DataOrPointer;
    if DataFieldLength(TagIndex) > 1 then
    begin
      P := IncAddress(FFileHead, Result);
      Result := P^;
    end;
    case DataType(TagIndex) of
      TIFF_BYTE:
        Result := Byte(Result);
      TIFF_SHORT:
        Result := Word(Result);
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TIFD.TagPointer(TagIndex: Byte): Cardinal;

begin
  if TagIndex > (FTagCount - 1) then Result := 0
                                else Result := FTags[TagIndex].DataOrPointer;
end;

//----------------------------------------------------------------------------------------------------------------------

function TIFD.DataType(TagIndex: Byte): Word;

begin
  if TagIndex > (FTagCount - 1) then Result := 0
                                else Result := FTags[TagIndex].DataType;
end;

//----------------------------------------------------------------------------------------------------------------------

function TIFD.DataFieldLength(TagIndex: Byte): Cardinal;

begin
  if TagIndex > (FTagCount - 1) then Result := 0
                                else Result := FTags[TagIndex].DataLength;
end;

//----------------------------------------------------------------------------------------------------------------------

function TIFD.GetTagIndex(TagCode: Word): Byte;

var
  I: Byte;

begin
  Result := FTagCount;
  I := 0;
  while (TagType(I) <> TagCode) and (I < FTagCount - 1) do Inc(I);
  if TagType(I) = TagCode then Result := I;
end;

//----------------------------------------------------------------------------------------------------------------------

function TIFD.GetStripCount: Cardinal;

var
  TagIndex: Byte;
  
begin
  TagIndex := GetTagIndex(TIFFTAG_STRIPOFFSETS);
  if TagIndex < FTagCount then Result := DataFieldLength(TagIndex)
                          else Result := 0;
end;

//----------------------------------------------------------------------------------------------------------------------

function TIFD.GetColor(ColorIndex: Word; RGBFlag: Byte): Byte;

const
  MaxItensity = 256;

var
  P: PWord;

begin
  P := IncAddress(FVirtualPalette, 2 * RGBFlag * MaxItensity + 2 * ColorIndex);
  Result := Round(Sqrt(P^ + 1)) - 1;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TIFD.ReadInit(VirtFile: Pointer; Shift: Integer);

var
  PTagCount: PWord;
  PTag: ^TTag;
  P: PCardinal;
  I: Word;

begin
  FFileHead := VirtFile;
  PTagCount := IncAddress(FFileHead, Shift);
  FTagCount := PTagCount^;
  GetMem(FTags, 12 * FTagCount);
  PTag := IncAddress(PTagCount, 2);
  for I := 0 to FTagCount - 1 do
  begin
    FTags[I] := PTag^;
    PTag := IncAddress(PTag, 12);
    case TagType(I) of
      TIFFTAG_IMAGEWIDTH:
        FWidth := TagData(I);
      TIFFTAG_IMAGELENGTH:
        FLength := TagData(I);
      TIFFTAG_BITSPERSAMPLE:
        FBitsPerSample := TagData(I);
      TIFFTAG_COMPRESSION:
        FCompression := TagData(I);
      TIFFTAG_PHOTOMETRIC:
        FPhotometricInterpretation := TagData(I);
      TIFFTAG_FILLORDER:
        FFillOrder := TagData(I);
      TIFFTAG_STRIPOFFSETS:
        FStripOffsets := TagPointer(I);
      TIFFTAG_ORIENTATION:
        FOrientation := TagData(I);
      TIFFTAG_SAMPLESPERPIXEL:
        FSamplesPerPixel := TagData(I);
      TIFFTAG_ROWSPERSTRIP:
        FRowsPerStrip := TagData(I);
      TIFFTAG_STRIPBYTECOUNTS:
        FStripByteCounts := TagPointer(I);
      TIFFTAG_PLANARCONFIG:
        FPlanarConfiguration := TagData(I);
      TIFFTAG_PREDICTOR:
        FPrediction := TagData(I) = 2;
      TIFFTAG_COLORMAP:
        begin
          FColorMap := TagPointer(I);
          FVirtualPalette := IncAddress(FFileHead, FColorMap);
        end;
    end;
  end;
  P := Pointer(PTag);
  FNextIFD := P^;
  if FOrientation = 0 then FOrientation := 1;
  if FFillOrder = 0 then FFillOrder := 1;
  FBitsPerPixel := FSamplesPerPixel * FBitsPerSample;
  FStripCount := GetStripCount;
  GetMem(FOffsets, FStripCount * SizeOf(TOffsets));
  GetMem(FByteCounts, FStripCount * SizeOf(TOffsets));
  if FStripCount > 1 then
    for I := 0 to FStripCount - 1 do
    begin
      P := IncAddress(FFileHead, FStripOffsets + I * SizeOf(TOffsets));
      FOffsets[I] := P^;
      P := IncAddress(FFileHead, FStripByteCounts + I * SizeOf(TOffsets));
      FByteCounts[I] := P^;
    end
    else
    begin
      FOffsets[0] := FStripOffsets;
      FByteCounts[0] := FStripByteCounts;
    end;
    
  FStripOffsets := FOffsets[0];
  FStripByteCounts := FByteCounts[0];
  FCompBits := (FWidth * FBitsPerSample) mod 8;
  FreeMem(FTags, 12 * FTagCount);
  FTagCount := 0;
end;

//----------------------------------------------------------------------------------------------------------------------

constructor TIFD.ReadCreate(VirtFile: Pointer; Shift: Integer);

begin
  inherited Create;
  FTagCount := 0;
  ReadInit(VirtFile, Shift);
  FPaletteCreated := False;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TIFD.WriteInit(Source: TBitmap; Compressing: Boolean);

var
  I: Word;
  ImageSize: Cardinal;
  StripSize: Cardinal;

begin
  FTagCount := 14;
  GetMem(FTags, SizeOf(TTag) * FTagCount);
  with FTags[0] do
  begin
    TagType := TIFFTAG_SUBFILETYPE;
    DataType := TIFF_SHORT;
    DataLength := 1;
    DataOrPointer := 0;
  end;
  with FTags[1] do
  begin
    TagType := TIFFTAG_IMAGEWIDTH;
    DataType := TIFF_SHORT;
    DataLength := 1;
    DataOrPointer := Source.Width;
    FWidth := DataOrPointer;
  end;
  with FTags[2] do
  begin
    TagType := TIFFTAG_IMAGELENGTH;
    DataType := TIFF_SHORT;
    DataLength := 1;
    DataOrPointer := Source.Height;
    FLength := DataOrPointer;
  end;
  with FTags[3] do
  begin
    TagType := TIFFTAG_BITSPERSAMPLE;
    DataType := TIFF_SHORT;
    DataLength := 1;
    case Source.PixelFormat of
      pf1bit:
        begin
          DataOrPointer := 1;
          FBitsPerSample := 1;
        end;
      pf4bit:
        begin
          DataOrPointer := 4;
          FBitsPerSample := 4;
        end;
      pf8bit,
      pf16bit,
      pf24bit:
        begin
          DataOrPointer := 8;
          FBitsPerSample := 8;
        end;
    end;
  end;
  with FTags[4] do
  begin
    TagType := TIFFTAG_COMPRESSION;
    DataType := TIFF_SHORT;
    DataLength := 1;
    if Compressing then
    begin
      DataOrPointer := COMPRESSION_LZW;
      FCompression := COMPRESSION_LZW;
    end
    else
    begin
      DataOrPointer := COMPRESSION_NONE;
      FCompression := COMPRESSION_NONE;
    end;
  end;
  with FTags[5] do
  begin
    TagType := TIFFTAG_PHOTOMETRIC;
    DataType := TIFF_SHORT;
    DataLength := 1;
    case Source.PixelFormat of
      pf1bit:
        begin
          DataOrPointer := PHOTOMETRIC_MINISWHITE;
          FPhotometricInterpretation := 1;
        end;
      pf4bit,
      pf8bit:
        begin
          DataOrPointer := PHOTOMETRIC_MINISBLACK;
          FPhotometricInterpretation := 1;
        end;
      else
      begin
        DataOrPointer := PHOTOMETRIC_RGB;
        FPhotometricInterpretation := 2;
      end;
    end;
  end;
  if FPhotometricInterpretation in [0, 1] then FBitsPerPixel := FBitsPerSample
                                          else FBitsPerPixel := 3 * FBitsPerSample;
  ImageSize := ((FWidth * FBitsPerPixel + 7) div 8) * FLength;
  StripSize := ($8000 div ((FWidth * FBitsPerPixel + 7) div 8)) * ((FWidth * FBitsPerPixel + 7) div 8);
  if StripSize < ((FWidth * FBitsPerPixel + 7) div 8) then StripSize := ((FWidth * FBitsPerPixel + 7) div 8);
  if StripSize > ImageSize then StripSize := ImageSize;
  with FTags[6] do
  begin
    TagType := TIFFTAG_FILLORDER;
    DataType := TIFF_SHORT;
    DataLength := 1;
    DataOrPointer := FILLORDER_MSB2LSB;
    FFillOrder := 1;
  end;
  with FTags[7] do
  begin
    TagType := TIFFTAG_STRIPOFFSETS;
    DataType := TIFF_LONG;
    DataLength := (ImageSize div StripSize) + 1;
    if (ImageSize mod StripSize) = 0 then DataLength := DataLength - 1;
    FStripCount := DataLength;
    DataOrPointer := 182;
    FStripOffsets := 182;
  end;
  with FTags[8] do
  begin
    TagType := TIFFTAG_ORIENTATION;
    DataType := TIFF_SHORT;
    DataLength := 1;
    DataOrPointer := ORIENTATION_TOPLEFT;
    FOrientation := 1;
  end;
  with FTags[9] do
  begin
    TagType := TIFFTAG_SAMPLESPERPIXEL;
    DataType := TIFF_SHORT;
    DataLength := 1;
    if FPhotometricInterpretation in [0, 1] then
    begin
      DataOrPointer := 1;
      FSamplesPerPixel := 1;
    end
    else
    begin
      DataOrPointer := 3;
      FSamplesPerPixel := 3;
    end;
  end;
  with FTags[10] do
  begin
    TagType := TIFFTAG_ROWSPERSTRIP;
    DataType := 3;
    DataLength := 1;
    DataOrPointer := StripSize div ((FWidth * FBitsPerPixel + 7) div 8);
    if DataOrPointer > Cardinal(Source.Height) then DataOrPointer := Source.Height;
    FRowsPerStrip := DataOrPointer;
  end;
  with FTags[11] do
  begin
    TagType := TIFFTAG_STRIPBYTECOUNTS;
    DataType := TIFF_LONG;
    DataLength := FStripCount;
    if DataLength > 1 then
    begin
      DataOrPointer := 182 + 4 * FStripCount;
      FStripByteCounts := DataOrPointer;
    end
    else
    begin
      DataOrPointer := StripSize;
      FStripByteCounts := DataOrPointer;
    end;
  end;
  with FTags[12] do
  begin
    TagType := TIFFTAG_PLANARCONFIG;
    DataType := TIFF_SHORT;
    DataLength := 1;
    DataOrPointer := PLANARCONFIG_CONTIG;
    FPlanarConfiguration := 1;
  end;
  with FTags[13] do
  begin
    TagType := TIFFTAG_PREDICTOR;
    DataType := TIFF_SHORT;
    DataLength := 1;
    DataOrPointer := 1;
    FPrediction := False;
  end;

  GetMem(FOffsets, FStripCount * SizeOf(TOffsets));
  GetMem(FByteCounts, FStripCount * SizeOf(TOffsets));
  if FStripCount > 1 then
  begin
    for I := 0 to FStripCount - 2 do
    begin
      FOffsets[I] := 182 + 8 * FStripCount + I * StripSize;
      FByteCounts[I] := StripSize;
    end;
    I := FStripCount - 1;
    FOffsets[I] := 182 + 8 * FStripCount + I * StripSize;
    FByteCounts[I] := ImageSize - StripSize * (FStripCount - 1);
  end
  else
  begin
    FOffsets[0] := 182;
    FByteCounts[0] := ImageSize;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

constructor TIFD.WriteCreate(Source: TBitmap; Compressing: Boolean);

begin
  inherited Create;
  WriteInit(Source, Compressing);
  FPaletteCreated := False;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TIFD.InitFromStream(Stream: TStream);

var
  Dummy: Cardinal;
  Shift: Cardinal;
  I: Word;

begin
  FPaletteCreated := False;
  Stream.ReadBuffer(Dummy, 4);
  Stream.ReadBuffer(Shift, 4);
  Stream.Position := Shift;
  Stream.ReadBuffer(FTagCount, 2);
  GetMem(FTags, 12 * FTagCount);
  Stream.Position := Shift + 2;
  Stream.ReadBuffer(FTags^, 12 * FTagCount);
  for I := 0 to FTagCount - 1 do
  begin
    case TagType(I) of
      TIFFTAG_IMAGEWIDTH:
        FWidth := TagData(I);
      TIFFTAG_IMAGELENGTH:
        FLength := TagData(I);
      TIFFTAG_BITSPERSAMPLE:
        if FTags[I].DataLength > 1 then
        begin
            Stream.Position := FTags[I].DataOrPointer;
            Stream.ReadBuffer(Dummy, 4);
            FBitsPerSample := Dummy;
        end
        else FBitsPerSample := Word(FTags[I].DataOrPointer);
      TIFFTAG_COMPRESSION:
        FCompression := TagData(I);
      TIFFTAG_PHOTOMETRIC:
        FPhotometricInterpretation := TagData(I);
      TIFFTAG_FILLORDER:
        FFillOrder := TagData(I);
      TIFFTAG_STRIPOFFSETS:
        FStripOffsets := TagPointer(I);
      TIFFTAG_ORIENTATION:
        FOrientation := TagData(I);
      TIFFTAG_SAMPLESPERPIXEL:
        FSamplesPerPixel := TagData(I);
      TIFFTAG_ROWSPERSTRIP:
        FRowsPerStrip := TagData(I);
      TIFFTAG_STRIPBYTECOUNTS:
        FStripByteCounts := TagPointer(I);
      TIFFTAG_PLANARCONFIG:
        FPlanarConfiguration := TagData(I);
      TIFFTAG_PREDICTOR:
        FPrediction := TagData(I) = 2;
      TIFFTAG_COLORMAP:
        begin
          FColorMap := TagPointer(I);
          FPaletteSize := DataFieldLength(I);
          GetMem(FVirtualPalette, 2 * FPaletteSize);
          Stream.Position := FColorMap;
          Stream.ReadBuffer(FVirtualPalette^ , 2 * FPaletteSize);
          FPaletteCreated := True;
        end;
    end;
  end;
  
  Stream.Position := Shift + 2 + 12 * FTagCount;
  Stream.ReadBuffer(FNextIFD, 4);
  if FOrientation = 0 then FOrientation := 1;
  if FFillOrder = 0 then FFillOrder := 1;
  FBitsPerPixel := FSamplesPerPixel * FBitsPerSample;
  FStripCount := GetStripCount;
  GetMem(FOffsets, FStripCount * SizeOf(TOffsets));
  GetMem(FByteCounts, FStripCount * SizeOf(TOffsets));
  if FStripCount > 1 then
  begin
    Stream.Position := FStripOffsets;
    Stream.ReadBuffer(FOffsets^, 4 * FStripCount);
    Stream.Position := FStripByteCounts;
    Stream.ReadBuffer(FByteCounts^, 4 * FStripCount);
  end
  else
  begin
    FOffsets[0] := FStripOffsets;
    FByteCounts[0] := FStripByteCounts;
  end;
  FStripOffsets := FOffsets[0];
  FStripByteCounts := FByteCounts[0];
  FCompBits := (FWidth * FBitsPerSample) mod 8;
  FreeMem(FTags);
  FTagCount := 0;
end;

//----------------------------------------------------------------------------------------------------------------------

constructor TIFD.CreateFromStream(Stream: TStream);

begin
  inherited Create;
  InitFromStream(Stream);
end;

//----------------------------------------------------------------------------------------------------------------------

destructor TIFD.Destroy;

begin
  if FTagCount > 0 then FreeMem(FTags);
  begin
    FreeMem(FOffsets);
    FreeMem(FByteCounts);
  end;
  if FPaletteCreated then FreeMem(FVirtualPalette);
  inherited Destroy;
end;

//----------------- TIFFGraphic (main TIF class) -----------------------------------------------------------------------

constructor TTIFFGraphic.Create;

begin
  inherited Create;
  PixelFormat := pf24bit;
  FInternalPalette := Palette;
end;

//----------------------------------------------------------------------------------------------------------------------

destructor TTIFFGraphic.Destroy;

begin
  inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TTIFFGraphic.Depredict1(StartPtr: Pointer; Count: Cardinal); assembler;

// EAX contains Self referenece, EDX StartPtr and ECX Count (note: these registers don't need to
// be saved and can freely be used)

asm
@@1:               MOV  AL, [EDX]
                   ADD  [EDX + 1], AL
                   INC EDX
                   DEC ECX
                   JNZ @@1
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TTIFFGraphic.Depredict3(StartPtr: Pointer; Count: Cardinal); assembler;

// EAX contains Self referenece, EDX StartPtr and ECX Count

asm
                   MOV EAX, ECX
                   SHL ECX, 1
                   ADD ECX, EAX         // 3 * Count
@@1:               MOV  AL, [EDX]
                   ADD  [EDX + 3], AL
                   INC EDX
                   DEC ECX
                   JNZ @@1
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TTIFFGraphic.Depredict4(StartPtr: Pointer; Count: Cardinal); assembler;

// EAX contains Self referenece, EDX StartPtr and ECX Count

asm
                   SHL ECX, 2          // 4 * Count
@@1:               MOV  AL, [EDX]
                   ADD  [EDX + 4], AL
                   INC EDX
                   DEC ECX
                   JNZ @@1
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TTIFFGraphic.LoadFromStream(Stream: TStream);

var
  StripSize,
  RowSize: Cardinal;
  I, J, PaletteCount: Cardinal;
  ScanLines: Integer;
  BMPInfo: PBitmapInfo;
  BitmapBits,
  StartData,
  CurrDecoding: Pointer;
  Decoder: TLZW;

begin
  Self.FreeImage;
  Height := 1;
  Width := 1;
  ScanLines := 0;

  FIFD := TIFD.CreateFromStream(Stream);
  Monochrome := TIFD(FIFD).FPhotometricInterpretation in [0, 1];
  case TIFD(FIFD).FBitsPerPixel of
    1,
    4,
    8:
      PaletteCount := 1 shl TIFD(FIFD).FBitsPerPixel;
    16,
    32:
      PaletteCount := 3;
  else PaletteCount := 0;
  end;
  GetMem(BMPInfo, SizeOf(TBitmapInfoHeader) + PaletteCount * SizeOf(TRGBQuad));

  try
    with TIFD(FIFD), BMPInfo.bmiHeader do
    begin
      biSize := SizeOf(TBitmapInfoHeader);
      biWidth := TIFD(FIFD).FWidth;
      biHeight := -TIFD(FIFD).FLength; // we want a top-dwon image
      biPlanes := 1;
      biCompression := BI_RGB;
      biSizeImage := 0;
      biXPelsPerMeter := 0;
      biYPelsPerMeter := 0;
      biBitCount := FBitsPerPixel;
      biClrUsed := 0;
      biClrImportant := 0;
    end;

    case TIFD(FIFD).FBitsPerPixel of
      1:
        begin
          PixelFormat :=  pf1bit;
          ScrambleBitmapPalette(TIFD(FIFD).FBitsPerPixel, TIFD(FIFD).FPhotometricInterpretation, BMPInfo);
       end;
      4:
        begin
          PixelFormat :=  pf4bit;
          ScrambleBitmapPalette(TIFD(FIFD).FBitsPerPixel, TIFD(FIFD).FPhotometricInterpretation, BMPInfo);
        end;
      8:
        begin
          PixelFormat :=  pf8bit;
          ScrambleBitmapPalette(TIFD(FIFD).FBitsPerPixel, TIFD(FIFD).FPhotometricInterpretation, BMPInfo);
        end;
      24:
        PixelFormat :=  pf24bit;
      32:
        PixelFormat :=  pf32bit;
    end;
  
    Width := TIFD(FIFD).FWidth;
    Height := TIFD(FIFD).FLength;
    RowSize := (TIFD(FIFD).FBitsPerPixel * Width + 7) div 8;
    case TIFD(FIFD).FCompression of
      COMPRESSION_NONE:
        begin
          ScanLines := 0;
          for J := 0 to TIFD(FIFD).FStripCount - 1 do
          begin
            if J < TIFD(FIFD).FStripCount - 1 then
              StripSize := TIFD(FIFD).FRowsPerStrip * RowSize
                                              else
              StripSize := (Cardinal(Height) - TIFD(FIFD).FRowsPerStrip * (TIFD(FIFD).FStripCount - 1)) * RowSize;

            GetMem(BitmapBits, StripSize);
            StartData := BitmapBits;
            Stream.Position := TIFD(FIFD).FOffsets[J];
            Stream.ReadBuffer(BitmapBits^, StripSize);
            case TIFD(FIFD).FBitsPerPixel of
              24:
                begin
                  if J < TIFD(FIFD).FStripCount - 1 then
                    SwapRGB2BGR(BitmapBits, Cardinal(Width) * TIFD(FIFD).FRowsPerStrip)
                                                    else
                    SwapRGB2BGR(BitmapBits, Cardinal(Width) * (Cardinal(Height) -
                                           TIFD(FIFD).FRowsPerStrip * (TIFD(FIFD).FStripCount - 1)));
                  I := TIFD(FIFD).FRowsPerStrip * J;
                  while (I <= Cardinal(Height - 1)) and (I div TIFD(FIFD).FRowsPerStrip <= J) do
                  begin
                    ScanLines := ScanLines + SetDIBitsToDevice(Canvas.Handle, 0, I, Width, 1, 0, 1, 1, 1,
                                                               BitmapBits, BMPInfo^, DIB_RGB_COLORS);
                    Inc(PByte(BitmapBits), RowSize);
                    Inc(I);
                  end;
                end;
              32:
                begin
                  if J < TIFD(FIFD).FStripCount - 1 then
                    SwapRGBA2BGRA(BitmapBits, Cardinal(Width) * TIFD(FIFD).FRowsPerStrip)
                                                    else
                    SwapRGBA2BGRA(BitmapBits, Cardinal(Width) * (Cardinal(Height) -
                                              TIFD(FIFD).FRowsPerStrip * (TIFD(FIFD).FStripCount - 1)));
                    I := TIFD(FIFD).FRowsPerStrip*J;
                    while (I <= Cardinal(Height - 1)) and (I div TIFD(FIFD).FRowsPerStrip <= J) do
                    begin
                      ScanLines :=  ScanLines + SetDIBitsToDevice(Canvas.Handle, 0, I, Width, 1, 0, 1, 1, 1,
                                                                  BitmapBits, BMPInfo^, DIB_RGB_COLORS);
                      Inc(PByte(BitmapBits), RowSize);
                      Inc(I);
                    end;
                 end;
            else
              begin
                I := TIFD(FIFD).FRowsPerStrip * J;
                while (I <= Cardinal(Height - 1)) and (I div TIFD(FIFD).FRowsPerStrip <= J) do
                begin
                  ScanLines :=  ScanLines + SetDIBitsToDevice(Canvas.Handle, 0, I, Width, 1, 0, 1, 1, 1,
                                                              BitmapBits, BMPInfo^, DIB_RGB_COLORS);
                  Inc(PByte(BitmapBits), RowSize);
                  Inc(I);
                end;
              end;
            end;
            FreeMem(StartData);
          end;
        end;
      COMPRESSION_CCITTRLE:
         raise Exception.Create('TIF: CCITT modified Huffman RLE compression not supported');
      COMPRESSION_CCITTFAX3:
       raise Exception.Create('TIF: CCITT Group 3 fax encoding compression not supported');
      COMPRESSION_CCITTFAX4:
        raise Exception.Create('TIF: CCITT Group 4 fax encoding compression not supported');
      COMPRESSION_LZW:
        begin
          ScanLines := 0;
          Decoder := TLZW.Create;
          for J := 0 to TIFD(FIFD).FStripCount - 1 do
          begin
            if J < TIFD(FIFD).FStripCount - 1 then
              GetMem(BitmapBits, TIFD(FIFD).FRowsPerStrip * RowSize)
                                              else
              GetMem(BitmapBits,(Cardinal(Height) - TIFD(FIFD).FRowsPerStrip * (TIFD(FIFD).FStripCount - 1)) * RowSize);
            CurrDecoding := BitmapBits;
            GetMem(StartData, TIFD(FIFD).FByteCounts[J]);
            Stream.Position := TIFD(FIFD).FOffsets[J];
            Stream.ReadBuffer(StartData^, TIFD(FIFD).FByteCounts[J]);
            Decoder.DecodeLZW(StartData, CurrDecoding);
            FreeMem(StartData);

            StartData := BitmapBits;
            case TIFD(FIFD).FBitsPerPixel of
              24:
                begin
                  if J < TIFD(FIFD).FStripCount - 1 then
                    SwapRGB2BGR(BitmapBits, Cardinal(Width) * TIFD(FIFD).FRowsPerStrip)
                                                    else
                    SwapRGB2BGR(BitmapBits, Cardinal(Width) * (Cardinal(Height) -
                                            TIFD(FIFD).FRowsPerStrip * (TIFD(FIFD).FStripCount - 1)));
                  I := TIFD(FIFD).FRowsPerStrip * J;
                  while (I <= Cardinal(Height - 1)) and (I div TIFD(FIFD).FRowsPerStrip <= J) do
                  begin
                    if TIFD(FIFD).FPrediction then Depredict3(BitmapBits, Width - 1);
                    ScanLines :=  ScanLines + SetDIBitsToDevice(Canvas.Handle, 0, I, Width, 1, 0, 1, 1, 1,
                                                                BitmapBits, BMPInfo^, DIB_RGB_COLORS);
                    Inc(PByte(BitmapBits), RowSize);
                    Inc(I);
                  end;
                end;
              32:
                begin
                  if J < TIFD(FIFD).FStripCount - 1 then
                    SwapRGBA2BGRA(BitmapBits, Cardinal(Width) * TIFD(FIFD).FRowsPerStrip)
                                                    else
                    SwapRGBA2BGRA(BitmapBits, Cardinal(Width) * (Cardinal(Height) - TIFD(FIFD).FRowsPerStrip * J));
                  I := TIFD(FIFD).FRowsPerStrip * J;
                  while (I <= Cardinal(Height - 1)) and (I div TIFD(FIFD).FRowsPerStrip <= J) do
                  begin
                    if TIFD(FIFD).FPrediction then Depredict4(BitmapBits, Width - 1);
                    ScanLines :=  ScanLines + SetDIBitsToDevice(Canvas.Handle, 0, I, Width, 1, 0, 1, 1, 1,
                                                                BitmapBits, BMPInfo^, DIB_RGB_COLORS);
                    Inc(PByte(BitmapBits), RowSize);
                    Inc(I);
                  end;
                end;
              else
                begin
                  I := TIFD(FIFD).FRowsPerStrip * J;
                  while (I <= Cardinal(Height - 1)) and (I div TIFD(FIFD).FRowsPerStrip <= J) do
                  begin
                    if TIFD(FIFD).FPrediction then Depredict1(BitmapBits, Width - 1);
                    ScanLines :=  ScanLines +  SetDIBitsToDevice(Canvas.Handle, 0, I, Width, 1, 0, 1, 1, 1,
                                                                 BitmapBits, BMPInfo^, DIB_RGB_COLORS);
                    Inc(PByte(BitmapBits), RowSize);
                    Inc(I);
                  end;
                end;
            end;
            FreeMem(StartData);
          end;
          Decoder.Free;
        end;
      COMPRESSION_OJPEG:
        raise Exception.Create('TIF: 6.0 JPEG compression not supported');
      COMPRESSION_JPEG:
        raise Exception.Create('TIF: JPEG DCT compression compression not supported');
      COMPRESSION_NEXT:
        raise Exception.Create('TIF: NEXT 2-bit RLE compression not supported');
      COMPRESSION_CCITTRLEW:
        raise Exception.Create('TIF: #1 w/ Word alignment compression not supported');
      COMPRESSION_PACKBITS:
        raise Exception.Create('TIF: Macintosh RLE compression not supported');
      COMPRESSION_THUNDERSCAN:
        raise Exception.Create('TIF: ThunderScan RLE compression not supported');
      COMPRESSION_IT8CTPAD:
        raise Exception.Create('TIF: IT8 CT w/padding compression not supported');
      COMPRESSION_IT8LW:
        raise Exception.Create('TIF: IT8 Linework RLE compression not supported');
      COMPRESSION_IT8MP:
        raise Exception.Create('TIF: IT8 Monochrome picture compression not supported');
      COMPRESSION_IT8BL:
        raise Exception.Create('TIF: IT8 Binary line art compression not supported');
      COMPRESSION_PIXARFILM:
        raise Exception.Create('TIF: Pixar companded 10bit LZW compression not supported');
      COMPRESSION_PIXARLOG:
        raise Exception.Create('TIF: Pixar companded 11bit ZIP compression not supported');
      COMPRESSION_DEFLATE:
        raise Exception.Create('TIF: Deflate compression not supported');
      COMPRESSION_DCS:
        raise Exception.Create('TIF: Kodak DCS encoding compression not supported');
      COMPRESSION_JBIG:
        raise Exception.Create('TIF: ISO JBIG compression not supported');
    end;

    if (TIFD(FIFD).FPhotometricInterpretation  = 3) or (TIFD(FIFD).FBitsPerPixel = 32) then
    begin
      PixelFormat := pf24bit;
      Palette := FInternalPalette;
    end;
    if ScanLines < Height then ShowMessage('TIF: Corrupt file');
  finally
    FreeMem(BMPInfo);
    TIFD(FIFD).Free;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TTIFFGraphic.SaveToStream(Stream: TStream);

begin
  SaveToStream(Stream, True);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TTIFFGraphic.SaveToStream(Stream: TStream; Compressed: Boolean);

var
  Dummy: Cardinal;
  I, J: Word;
  Offset: Cardinal;
  BMPInfo: PBitmapInfo;
  Buffer,
  BufHead,
  CodeBuffer: Pointer;
  PaletteCount: Word;
  Usage: Integer;
  Encoder: TLZW;
  BCounts: Cardinal;
  offOffset,
  bcOffset,
  TagOffset,
  RowSize:DWord;

begin
  Offset := 0;
  offOffset := 0;
  bcOffset := 0;
  FIFD := TIFD.WriteCreate(Self, Compressed);
  Dummy := TIFF_LITTLEENDIAN;
  Stream.WriteBuffer(Dummy, 2);
  Inc(Offset, 2);
  Dummy := TIFF_VERSION;
  Stream.WriteBuffer(Dummy, 2);
  Inc(Offset, 2);
  Dummy := 8;
  Stream.WriteBuffer(Dummy, 4);
  Inc(Offset, 4);
  Dummy := TIFD(FIFD).FTagCount;
  Stream.WriteBuffer(Dummy, 2);
  Inc(Offset, 2);
  TagOffset := Offset;
  Stream.WriteBuffer(TIFD(FIFD).FTags^, 12 * TIFD(FIFD).FTagCount);
  Inc(Offset, 12 * TIFD(FIFD).FTagCount);
  Dummy := 0;
  Stream.WriteBuffer(Dummy, 4);
  Inc(Offset, 4);
  
  if TIFD(FIFD).FStripCount > 1 then
  begin
    offOffset := Offset;
    Stream.WriteBuffer(TIFD(FIFD).FOffsets^, 4 * TIFD(FIFD).FStripCount);
    Inc(Offset, 4 * TIFD(FIFD).FStripCount);
    bcOffSet := Offset;
    Stream.WriteBuffer(TIFD(FIFD).FByteCounts^, 4 * TIFD(FIFD).FStripCount);
  end;

  case TIFD(FIFD).FBitsPerPixel of
    1:
      PaletteCount := 2;
    4:
      PaletteCount := 16;
    8:
      PaletteCount := 256;
    16,
    32:
      PaletteCount := 3;
  else
    PaletteCount := 0;
  end;

  if TIFD(FIFD).FBitsPerPixel = 1 then GetMem(BMPInfo, SizeOf(TBitMapInfoHeader) + PaletteCount * SizeOf(TRGBQuad))
                                  else GetMem(BMPInfo, SizeOf(TBitMapInfoHeader) + 2 * PaletteCount);

  with TIFD(FIFD), BMPInfo.bmiHeader do
  begin
    biSize := SizeOf(TBitMapInfoHeader);
    biWidth := Width;
    biHeight := -FLength;
    biPlanes := 1;
    biCompression := 0;
    biSizeImage := 0;
    biXPelsPerMeter := 0;
    biYPelsPerMeter := 0;
    biBitCount := FBitsPerPixel;
    biClrUsed := 0;
    biClrImportant := 0;
  end;

  case TIFD(FIFD).FBitsPerPixel of
    1:
      ScrambleBitmapPalette(TIFD(FIFD).FBitsPerPixel, TIFD(FIFD).FPhotometricInterpretation, BMPInfo);
    4:
      ScramblePalette(TIFD(FIFD).FBitsPerPixel, TIFD(FIFD).FPhotometricInterpretation);
    8:
      ScramblePalette(TIFD(FIFD).FBitsPerPixel, TIFD(FIFD).FPhotometricInterpretation);
  end;
  if TIFD(FIFD).FBitsPerPixel in [1, 24] then Usage := DIB_RGB_COLORS
                                         else Usage := DIB_PAL_COLORS;
  RowSize := (TIFD(FIFD).FBitsPerPixel * Width + 7) div 8;

  for J := 0 to TIFD(FIFD).FStripCount - 1 do
  begin
    I := TIFD(FIFD).FRowsPerStrip * J;
    BCounts := TIFD(FIFD).FByteCounts[J];
    Buffer := AllocMem(BCounts);
    BufHead := Buffer;
    while (I <= Height - 1) and (I div TIFD(FIFD).FRowsPerStrip <= J) do
    begin
      GetDIBits(Canvas.Handle, Handle, Height - I - 1, 1, Buffer, BMPInfo^, Usage);
      Inc(PByte(Buffer), RowSize);
      Inc(I);
    end;
    Buffer := BufHead;

    if TIFD(FIFD).FBitsPerPixel = 24 then
    begin
      if J < TIFD(FIFD).FStripCount - 1 then
        SwapRGB2BGR(Buffer, Cardinal(Width) * TIFD(FIFD).FRowsPerStrip)
                                        else
        SwapRGB2BGR(Buffer, Cardinal(Width) * (Cardinal(Height) -
                            TIFD(FIFD).FRowsPerStrip * (TIFD(FIFD).FStripCount - 1)));
    end;

    if Compressed then
    begin
      Encoder := TLZW.Create;
      BCounts := TIFD(FIFD).FByteCounts[J];
      CodeBuffer := AllocMem((3 * BCounts) div 2);
      Encoder.EncodeLZW(Buffer, CodeBuffer, TIFD(FIFD).FByteCounts[J]);
      if J < TIFD(FIFD).FStripCount - 1 then
        TIFD(FIFD).FOffsets^[J + 1] :=  TIFD(FIFD).FOffsets[J] + TIFD(FIFD).FByteCounts[J];
      Stream.Position := TIFD(FIFD).FOffsets[J];
      Stream.WriteBuffer(CodeBuffer^, TIFD(FIFD).FByteCounts[J]);
      if Odd(TIFD(FIFD).FOffsets[J] + TIFD(FIFD).FByteCounts[J]) then
      begin
        Dummy := 0;
        Stream.WriteBuffer(Dummy, 1);
        If J < TIFD(FIFD).FStripCount - 1 then TIFD(FIFD).FOffsets[J + 1] :=  TIFD(FIFD).FOffsets[J + 1] + 1;
      end;
      FreeMem(CodeBuffer);
      Encoder.Free;
    end
    else
    begin
      Stream.Position := TIFD(FIFD).FOffsets[J];
      Stream.WriteBuffer(Buffer^, TIFD(FIFD).FByteCounts[J]);
    end;
    FreeMem(Buffer);
  end;

  if Compressed then
  begin
    if TIFD(FIFD).FStripCount > 1 Then
    begin
      Stream.Position := offOffset;
      Stream.WriteBuffer(TIFD(FIFD).FOffsets^, 4 * TIFD(FIFD).FStripCount);
      Stream.Position := bcOffSet;
      Stream.WriteBuffer(TIFD(FIFD).FByteCounts^, 4 * TIFD(FIFD).FStripCount);
    end
    else
    begin
      TIFD(FIFD).FTags[11].DataOrPointer := TIFD(FIFD).FByteCounts[0];
      Stream.Position := TagOffset;
      Stream.WriteBuffer(TIFD(FIFD).FTags^, 12 * TIFD(FIFD).FTagCount);
    end;
  end;

  FreeMem(BMPInfo);
  FIFD.Free;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TTIFFGraphic.SaveToTifFile(FileName: String; Compressing: Boolean);

begin

end;

//----------------------------------------------------------------------------------------------------------------------

procedure TTIFFGraphic.SaveToTifFileSLZW(FileName: String; SmoothRange: TSmoothRange);

begin

end;

//----------------------------------------------------------------------------------------------------------------------

procedure TTIFFGraphic.ScrambleBitmapPalette(BPS: Byte; Mode: Integer; BMPInfo: PBitmapInfo);

var
  Pal: PLogPalette;
  hpal: HPALETTE;
  I: Integer;
  EntryCount: Word;
  
begin
  case BPS of
    1:
      EntryCount := 1;
    4:
      EntryCount := 15;
    8:
      EntryCount := 255;
    32:
      EntryCount := 3;
  else
    EntryCount := 0;
  end;
  GetMem(Pal, SizeOf(TLogPalette) + SizeOf(TPaletteEntry) * EntryCount);
  try
    Pal.palVersion := $300;
    Pal.palNumEntries := 1 + EntryCount;
    case BPS of
      1:
        case Mode of
          0:
            begin
              for I := 0 to EntryCount do
              begin
                Pal.palPalEntry[I].peRed := 255 * I;
                Pal.palPalEntry[I].peGreen  := 255 * I;
                Pal.palPalEntry[I].peBlue := 255 * I;
                Pal.palPalEntry[I].peFlags := 0;
              end;
              with BMPInfo.bmiColors[0] do
              begin
                rgbBlue := 255;
                rgbGreen := 255;
                rgbRed := 255;
                rgbReserved := 0;
              end;
              I := 1;
              with BMPInfo.bmiColors[I] do
              begin
                rgbBlue := 0;
                rgbGreen := 0;
                rgbRed := 0;
                rgbReserved := 0;
              end;
            end;
        else
          begin
            for I := 0 to EntryCount do
            begin
              Pal.palPalEntry[I].peRed := 255 * (1 - I);
              Pal.palPalEntry[I].peGreen  := 255 * (1 - I);
              Pal.palPalEntry[I].peBlue := 255 * (1 - I);
              Pal.palPalEntry[I].peFlags := 0;
            end;
            I := 1;
            with BMPInfo.bmiColors[I] do
            begin
              rgbBlue := 255;
              rgbGreen := 255;
              rgbRed := 255;
              rgbReserved := 0;
            end;
            with BMPInfo.bmiColors[0] do
            begin
              rgbBlue := 0;
              rgbGreen := 0;
              rgbRed := 0;
              rgbReserved := 0;
            end;
          end;
        end;
      4:
        case Mode of
          0:
            begin
              for I := 0 to EntryCount do
              begin
                Pal.palPalEntry[EntryCount - I].peRed  := 16 * I;
                Pal.palPalEntry[EntryCount - I].peGreen  := 16 * I;
                Pal.palPalEntry[EntryCount - I].peBlue  := 16 * I;
                Pal.palPalEntry[EntryCount - I].peFlags := 0;
                with BMPInfo.bmiColors[EntryCount - I] do
                begin
                  rgbBlue := 16 * (I + 1) - 1;
                  rgbGreen := 16 * (I + 1) - 1;
                  rgbRed := 16 * (I + 1) - 1;
                  rgbReserved := 0;
                end;
              end;
            end;
          1:
            begin
              for I := 0 to EntryCount do
              begin
                Pal.palPalEntry[I].peRed  := 16 * I;
                Pal.palPalEntry[I].peGreen  := 16 * I;
                Pal.palPalEntry[I].peBlue  := 16 * I;
                Pal.palPalEntry[I].peFlags := 0;
                with BMPInfo.bmiColors[I] do
                begin
                  rgbBlue := 16 * (I + 1) - 1;
                  rgbGreen := 16 * (I + 1) - 1;
                  rgbRed := 16 * (I + 1) - 1;
                  rgbReserved := 0;
                end;
              end;
            end;
        end;
      8:
        case Mode  of
          0:
            for I :=  0 to EntryCount do
            begin
              Pal.palPalEntry[EntryCount - I].peRed := I;
              Pal.palPalEntry[EntryCount - I].peGreen := I;
              Pal.palPalEntry[EntryCount - I].peBlue := I;
              Pal.palPalEntry[EntryCount - I].peFlags := 0;
              with BMPInfo.bmiColors[EntryCount - I] do
              begin
                rgbBlue := I;
                rgbGreen := I;
                rgbRed := I;
                rgbReserved := 0;
              end;
            end;
          1:
            for I :=  0 to EntryCount do
            begin
              Pal.palPalEntry[I].peRed := I;
              Pal.palPalEntry[I].peGreen := I;
              Pal.palPalEntry[I].peBlue := I;
              Pal.palPalEntry[I].peFlags := 0;
              with BMPInfo.bmiColors[I] do
              begin
                rgbBlue := I;
                rgbGreen := I;
                rgbRed := I;
                rgbReserved := 0;
              end;
            end;
          3:
            for I := 0 to EntryCount do
            begin
              Pal.palPalEntry[I].peRed := TIFD(FIFD).GetColor(I, 0);
              Pal.palPalEntry[I].peGreen := TIFD(FIFD).GetColor(I, 1);
              Pal.palPalEntry[I].peBlue := TIFD(FIFD).GetColor(I, 2);
              Pal.palPalEntry[I].peFlags := 0;
              with BMPInfo.bmiColors[I] do
              begin
                rgbBlue := Pal.palPalEntry[I].peBlue;
                rgbGreen := Pal.palPalEntry[I].peGreen;
                rgbRed := Pal.palPalEntry[I].peRed;
                rgbReserved := 0;
              end;
            end;
        end;
      32 :
        begin
          Cardinal(BMPInfo.bmiColors[0]) := $FF;
          I := 1;
          Cardinal(BMPInfo.bmiColors[I]) := $FF00;
          I := 2;
          Cardinal(BMPInfo.bmiColors[I]) := $FF0000;
        end;
    end;
    if BPS <> 32 then
    begin
      hpal := CreatePalette(Pal^);
      if hpal <> 0 then Palette := hpal;
    end;
  finally
    FreeMem(Pal);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TTIFFGraphic.ScramblePalette(BPS: Byte; Mode: Integer);

var
  pal: PLogPalette;
  hpal: HPALETTE;
  I: Integer;
  EntryCount: Word;
  
begin
  case BPS of
    1:
      EntryCount := 1;
    4:
      EntryCount := 15;
    8:
      EntryCount := 255;
    32:
      EntryCount := 3;
  else
    EntryCount := 0;
  end;

  GetMem(Pal, SizeOf(TLogPalette) + SizeOf(TPaletteEntry) * EntryCount);
  try
    pal.palVersion := $300;
    pal.palNumEntries := 1 + EntryCount;
    case BPS of
      1:
        case Mode of
          0:
            for I := 0 to EntryCount do
            begin
              pal.palPalEntry[I].peRed := 255 * I;
              pal.palPalEntry[I].peGreen := 255 * I;
              pal.palPalEntry[I].peBlue := 255 * I;
              pal.palPalEntry[I].peFlags := 0;
            end;
        else
          for I := 0 to EntryCount do
          begin
            pal.palPalEntry[I].peRed := 255 * (1 - I);
            pal.palPalEntry[I].peGreen := 255 * (1 - I);
            pal.palPalEntry[I].peBlue := 255 * (1 - I);
            pal.palPalEntry[I].peFlags := 0;
          end;
        end;
      4:
        case Mode of
          0:
            for I := 0 to EntryCount do
            begin
              pal.palPalEntry[EntryCount - I].peRed := 16 * I;
              pal.palPalEntry[EntryCount - I].peGreen := 16 * I;
              pal.palPalEntry[EntryCount - I].peBlue := 16 * I;
              pal.palPalEntry[EntryCount - I].peFlags := 0;
            end;
          1:
            for I := 0 to EntryCount do
            begin
              pal.palPalEntry[I].peRed := 16 * I;
              pal.palPalEntry[I].peGreen := 16 * I;
              pal.palPalEntry[I].peBlue := 16 * I;
              pal.palPalEntry[I].peFlags := 0;
            end;
        end;
      8:
        case Mode of
          0:
            for I :=  0 to EntryCount do
            begin
              pal.palPalEntry[EntryCount - I].peRed := I;
              pal.palPalEntry[EntryCount  -I].peGreen := I;
              pal.palPalEntry[EntryCount - I].peBlue := I;
              pal.palPalEntry[EntryCount - I].peFlags := 0;
            end;
          1:
            for I :=  0 to EntryCount do
            begin
              pal.palPalEntry[I].peRed := I;
              pal.palPalEntry[I].peGreen := I;
              pal.palPalEntry[I].peBlue := I;
              pal.palPalEntry[I].peFlags := 0;
            end;
          3:
            for I := 0 to EntryCount do
            begin
              pal.palPalEntry[I].peRed := TIFD(FIFD).GetColor(I, 0);
              pal.palPalEntry[I].peGreen := TIFD(FIFD).GetColor(I, 1);
              pal.palPalEntry[I].peBlue :=  TIFD(FIFD).GetColor(I, 2);
              pal.palPalEntry[I].peFlags := 0;
            end;
        end;
    end;

    if BPS <> 32 then
    begin
      hpal := CreatePalette(Pal^);
      if hpal <> 0 then Palette := hpal;
    end;
  finally
    FreeMem(Pal);
  end;
end;

//----------------- TTargaGraphic --------------------------------------------------------------------------------------

//  FILE STRUCTURE FOR THE ORIGINAL TRUEVISION TGA FILE
//	  FIELD 1 :	NUMBER OF CHARACTERS IN ID FIELD (1 BYTES)
//	  FIELD 2 :	COLOR MAP TYPE (1 BYTES)
//	  FIELD 3 :	IMAGE TYPE CODE (1 BYTES)
//					= 0	NO IMAGE DATA INCLUDED
//					= 1	UNCOMPRESSED, COLOR-MAPPED IMAGE
//					= 2	UNCOMPRESSED, TRUE-COLOR IMAGE
//					= 3	UNCOMPRESSED, BLACK AND WHITE IMAGE
//					= 9	RUN-LENGTH ENCODED COLOR-MAPPED IMAGE
//					= 10 RUN-LENGTH ENCODED TRUE-COLOR IMAGE
//					= 11 RUN-LENGTH ENCODED BLACK AND WHITE IMAGE
//	  FIELD 4 :	COLOR MAP SPECIFICATION	(5 BYTES)
//				4.1 : COLOR MAP ORIGIN (2 BYTES)
//				4.2 : COLOR MAP LENGTH (2 BYTES)
//				4.3 : COLOR MAP ENTRY SIZE (1 BYTES)
//	  FIELD 5 :	IMAGE SPECIFICATION (10 BYTES)
//				5.1 : X-ORIGIN OF IMAGE (2 BYTES)
//				5.2 : Y-ORIGIN OF IMAGE (2 BYTES)
//				5.3 : WIDTH OF IMAGE (2 BYTES)
//				5.4 : HEIGHT OF IMAGE (2 BYTES)
//				5.5 : IMAGE PIXEL SIZE (1 BYTE)
//				5.6 : IMAGE DESCRIPTOR BYTE (1 BYTE)
//                                    bit 0..3: attribute bits per pixel
//                                    bit 4..5: image orientation:
//                                              0: bottom left
//                                              1: bottom right
//                                              2: top left
//                                              3: top right
//                                    bit 6..7: interleaved flag
//                                              0: two way (even-odd) interleave (e.g. IBM Graphics Card Adapter), obsolete
//                                              1: four way interleave (e.g. AT&T 6300 High Resolution), obsolete
//	  FIELD 6 :	IMAGE ID FIELD (LENGTH SPECIFIED BY FIELD 1)
//	  FIELD 7 :	COLOR MAP DATA (BIT WIDTH SPECIFIED BY FIELD 4.3 AND
//				NUMBER OF COLOR MAP ENTRIES SPECIFIED IN FIELD 4.2)
//	  FIELD 8 :	IMAGE DATA FIELD (WIDTH AND HEIGHT SPECIFIED IN FIELD 5.3 AND 5.4)

const
  TARGA_NO_COLORMAP = 0;
  TARGA_COLORMAP = 1;

  TARGA_EMPTY_IMAGE = 0;
  TARGA_INDEXED_IMAGE = 1;
  TARGA_TRUECOLOR_IMAGE = 2;
  TARGA_BW_IMAGE = 3;
  TARGA_INDEXED_RLE_IMAGE = 9;
  TARGA_TRUECOLOR_RLE_IMAGE = 10;
  TARGA_BW_RLE_IMAGE = 11;

type
  TTargaHeader = packed record
    IDLength,
    ColorMapType,
    ImageType: Byte;
    ColorMapOrigin,
    ColorMapSize: Word;
    ColorMapEntrySize: Byte;
    XOrigin, YOrigin,
    Width, Height: Word;
    PixelSize: Byte;
    ImageDescriptor: Byte;
  end;


//----------------------------------------------------------------------------------------------------------------------

procedure TTargaGraphic.LoadFromResourceName(Instance: THandle; const ResName: String);

var
  Stream: TResourceStream;

begin
  Stream := TResourceStream.Create(Instance, ResName, RT_RCDATA);
  try
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TTargaGraphic.LoadFromResourceID(Instance: THandle; ResID: Integer);

var
  Stream: TResourceStream;
  
begin
  Stream := TResourceStream.CreateFromID(Instance, ResID, RT_RCDATA);
  try
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TTargaGraphic.LoadFromStream(Stream: TStream);

var
  RLEBuffer: Pointer;
  I: Integer;
  LineSize: Integer;
  LineBuffer: Pointer;
  ReadLength: Integer;
  LogPalette: TMaxLogPalette;
  Temp: Byte;
  Color16: Word;
  Header: TTargaHeader;
//  FlipH, ml: need to implement horizontal flipping of image
  FlipV: Boolean;

begin
  Stream.Read(Header, SizeOf(Header));
  // mirror image so that the leftmost pixel becomes rightmost
//  FlipH := (Header.ImageDescriptor and $10) <> 0;
  // mirror image so that the topmost pixel becomes bottommost
  FlipV := (Header.ImageDescriptor and $20) <> 0;
  Header.ImageDescriptor := Header.ImageDescriptor and $F;
  if Header.IDLength > 0 then
  begin
    SetLength(FImageID, Header.IDLength);
    Stream.Read(FImageID[1], Header.IDLength);
  end
  else FImageID := '';

  case Header.PixelSize of
    8:
      PixelFormat := pf8Bit;
    15,
    16: // actually, 16 bit are meant being 15 bit
      PixelFormat := pf15Bit;
    24:
      PixelFormat := pf24Bit;
    32:
      PixelFormat := pf32Bit;
  end;

  if (Header.ColorMapType = 1) or (Header.ImageType in [TARGA_BW_IMAGE, TARGA_BW_RLE_IMAGE]) then
  begin
    // read palette entries and create a palette
    FillChar(LogPalette, SizeOf(LogPalette), 0);
    with LogPalette do
    begin
      palVersion := $300;
      palNumEntries := Header.ColorMapSize;

      if Header.ImageType in [TARGA_BW_IMAGE, TARGA_BW_RLE_IMAGE] then
      begin
        palNumEntries := 256;
        // black&white images implicitely use a grey scale ramp
        for I := 0 to 255 do
        begin
          palPalEntry[I].peBlue := I;
          palPalEntry[I].peGreen := I;
          palPalEntry[I].peRed := I;
        end;
      end
      else
        case Header.ColorMapEntrySize of
          32:
            for I := 0 to Header.ColorMapSize - 1 do
            begin
              Stream.Read(palPalEntry[I].peBlue, 1);
              Stream.Read(palPalEntry[I].peGreen, 1);
              Stream.Read(palPalEntry[I].peRed, 1);
              Stream.Read(Temp, 1); // ignore alpha value
            end;
          24:
            for I := 0 to Header.ColorMapSize - 1 do
            begin
              Stream.Read(palPalEntry[I].peBlue, 1);
              Stream.Read(palPalEntry[I].peGreen, 1);
              Stream.Read(palPalEntry[I].peRed, 1);
            end;
        else
          // 15 and 16 bits per color map entry (handle both like 555 color format
          // but make 8 bit from 5 bit per color component)
          for I := 0 to Header.ColorMapSize - 1 do
          begin
            Stream.Read(Color16, 2);
            palPalEntry[I].peBlue := (Color16 and $1F) shl 3;
            palPalEntry[I].peGreen := (Color16 and $3E0) shr 2;
            palPalEntry[I].peRed := (Color16 and $7C00) shr 7;
          end;
        end;
    end;
    Palette := CreatePalette(PLogPalette(@LogPalette)^);
  end;

  Width := Header.Width;
  Height := Header.Height;
  LineSize := Width * (Header.PixelSize div 8);

  case Header.ImageType of
    TARGA_EMPTY_IMAGE: ;
      // nothing to do here
    TARGA_BW_IMAGE,
    TARGA_INDEXED_IMAGE,
    TARGA_TRUECOLOR_IMAGE:
      begin
        for I := 0 to Height - 1 do
        begin
          if FlipV then LineBuffer := ScanLine[I]
                   else LineBuffer := ScanLine[Header.Height - (I + 1)];
          if Stream.Read(LineBuffer^, LineSize) <> LineSize then raise Exception.Create('Targa: invalid image');
        end;
      end;
    TARGA_BW_RLE_IMAGE,
    TARGA_INDEXED_RLE_IMAGE,
    TARGA_TRUECOLOR_RLE_IMAGE:
      begin
        RLEBuffer := Allocmem(2 * LineSize);
        for I := 0 to Height - 1 do
        begin
          if FlipV then LineBuffer := ScanLine[I]
                    else LineBuffer := ScanLine[Header.Height - (I + 1)];
          ReadLength := Stream.Read(RLEBuffer^, 2 * LineSize);
          Stream.Position := Stream.Position - ReadLength + DecodeRLE(RLEBuffer, LineBuffer, LineSize, Header.PixelSize);
        end;
        FreeMem(RLEBuffer);
      end;
    end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TTargaGraphic.SaveToStream(Stream: TStream);

begin                   
  SaveToStream(Stream, True);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TTargaGraphic.SaveToStream(Stream: TStream; Compressed: Boolean);

// The format of the image to be saved depends on the current properties of the bitmap not
// on the values which may be set in the header during a former load.

var
  RLEBuffer: Pointer;
  I: Integer;
  LineSize: Integer;
  WriteLength: Integer;
  LogPalette: TMaxLogPalette;
  BPP: Byte;
  Header: TTargaHeader;

begin
  // prepare color depth
  case PixelFormat of
    pf1Bit,
    pf4Bit:
      if MessageDlg('Targa image: 1 or 4 bit color depth not allowed. Convert to 256 colors?',
                     mtWarning, mbOKCancel, 0) = idOK then
      begin
        PixelFormat := pf8Bit;
        BPP := 1;
      end
      else Exit;
    pf8Bit:
      BPP := 1;
    pf15Bit,
    pf16Bit:
      BPP := 2;
    pf24Bit:
      BPP := 3;
    pf32Bit:
      BPP := 4;
  else
    BPP := GetDeviceCaps(Canvas.Handle, BITSPIXEL) div 8;
  end;

  if not Empty then
  begin
    with Header do
    begin
      IDLength := Length(FImageID);
      if BPP = 1 then ColorMapType := 1
                 else ColorMapType := 0;
      if not Compressed then
        // can't distinct between a B&W and an color indexed image here, so I use always the latter
        if BPP = 1 then ImageType := TARGA_INDEXED_IMAGE
                   else ImageType := TARGA_TRUECOLOR_IMAGE
                        else
        if BPP = 1 then ImageType := TARGA_INDEXED_RLE_IMAGE
                   else ImageType := TARGA_TRUECOLOR_RLE_IMAGE;

      ColorMapOrigin := 0;
      // always save entire palette
      ColorMapSize := 256;
      // always save complete color information
      ColorMapEntrySize := 24;
      XOrigin := 0;
      YOrigin := 0;
      Width := Self.Width;
      Height := Self.Height;
      PixelSize := BPP shl 3;
      // if the image is a bottom-up DIB then indicate this in the image descriptor
      if Cardinal(Scanline[0]) > Cardinal(Scanline[1]) then ImageDescriptor := $20
                                                       else ImageDescriptor := 0;
    end;
  
    Stream.Write(Header, SizeOf(Header));
    if Header.IDLength > 0 then Stream.Write(FImageID[1], Header.IDLength);

    // store color palette if necessary
    if Header.ColorMapType = 1 then
      with LogPalette do
      begin
        // read palette entries
        GetPaletteEntries(Palette, 0, 256, palPalEntry);
        for I := 0 to 255 do
        begin
          Stream.Write(palPalEntry[I].peBlue, 1);
          Stream.Write(palPalEntry[I].peGreen, 1);
          Stream.Write(palPalEntry[I].peRed, 1);
        end;
      end;

    LineSize := Width * (Header.PixelSize div 8);

    // finally write image data
    if Compressed then
    begin
      RLEBuffer := AllocMem(2 * LineSize);
      for I := 0 to Height - 1 do
      begin
        WriteLength := EncodeRLE(ScanLine[I], RLEBuffer, Width, BPP);
        if Stream.Write(RLEBuffer^, WriteLength) <> WriteLength then
          raise Exception.Create('Targa: could not write image data');
      end;
      FreeMem(RLEBuffer);
    end
    else
    begin
      for I := 0 to Height - 1 do
        if Stream.Write(ScanLine[I]^, LineSize) <> LineSize then
          raise Exception.Create('Targa: could not write image data');
    end;
  end;
end;

//----------------- TPCXGraphic ----------------------------------------------------------------------------------------

type
  TPCXHeader = record
    Maker: Byte;
    Version: Byte;
    Encoding: Byte;
    BPP: Byte;
    Xmn, Ymn,
    Xmx, Ymx,
    HRes, VRes: SmallInt;
    CMap: array[0..15] of TRGBTriple;
    Reserved,
    NPlanes: Byte;
    NBpl,
    PalType: SmallInt;
  end;

//----------------------------------------------------------------------------------------------------------------------

procedure TPCXGraphic.LoadFromStream(Stream: TStream);

var
  Header: TPCXHeader;
  
begin
  Stream.Read(Header, SizeOf(Header));
  with Header do
  begin
    if Maker <> $0A then Exit;
    if (BPP = 8) and (NPlanes = 1) then PixelFormat := pf8Bit
    	                           else
      if (BPP = 1) and (NPlanes = 4) then PixelFormat := pf4Bit
      	                             else Exit;

    Height := Ymx - Ymn + 1;
    Width := Xmx - Xmn + 1;

  end;
  //DecodeStream(Stream, FHeader, Image) = 1 then
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TPCXGraphic.SaveToStream(Stream: TStream);

begin

end;

//----------------------------------------------------------------------------------------------------------------------

initialization
  TPicture.RegisterFileFormat('bw', 'SGI black/white images', TSGIGraphic);
  TPicture.RegisterFileFormat('rgb', 'SGI true color images', TSGIGraphic);
  TPicture.RegisterFileFormat('cel', 'Autodesk images', TAutodeskGraphic);
  TPicture.RegisterFileFormat('pic', 'Autodesk images', TAutodeskGraphic);
  TPicture.RegisterFileFormat('tif', 'TIFF images', TTIFFGraphic);
  TPicture.RegisterFileFormat('tiff', 'TIFF images', TTIFFGraphic);
  TPicture.RegisterFileFormat('tga', 'Truevision images', TTargaGraphic);
  TPicture.RegisterFileFormat('vst', 'Truevision images', TTargaGraphic);;
  TPicture.RegisterFileFormat('icb', 'Truevision images', TTargaGraphic);
  TPicture.RegisterFileFormat('vda', 'Truevision images', TTargaGraphic);
  TPicture.RegisterFileFormat('win', 'Truevision images', TTargaGraphic);
  //TPicture.RegisterFileFormat('pcx', 'PCX images', TPCXGraphic);
finalization
  TPicture.UnregisterGraphicClass(TSGIGraphic);
  TPicture.UnregisterGraphicClass(TSGIGraphic);
  TPicture.UnregisterGraphicClass(TAutodeskGraphic);
  TPicture.UnregisterGraphicClass(TTIFFGraphic);
  TPicture.UnregisterGraphicClass(TTargaGraphic);
end.

unit pqConvolution;

{By Patrick Quinn. July 2002.
  patrick@thequinns.worldonline.co.uk

Based on the G32_WConvolution unit by Vladimir Vasilyev
   http://www.gamedev.narod.ru
   W-develop@mtu-net.ru
   Vladimir@tometric.ru
who based his unit on: Harm's example of a 3 x 3 convolution
using 24-bit bitmaps and scanline
 http://www.users.uswest.net/~sharman1/
 sharman1@uswest.net

The major differences:
  I use PixelPtr rather than scanline, gives a slight increase (12%) in speed.
  I have added an array of array of constants for the different filters, makes
  programming easier.

Additional filters from Ender Wiggin's excellent article,
'Elementary Digital Filtering' at
http://www.gamedev.net/reference/programming/features/edf/default.asp

 }

interface

uses
  GR32;

type
  // Indexes 0..8 are the convolution coefficients
  // Index 9 is the normalization constant
  TConvolutionKernel = array[0..9] of Integer;

  // for 'type safe' versions
  TConvolutionFilter = (cfNone,
                        // Low pass filters
                        cfLPAverage,
                        cfLP1,
                        cfLP2,
                        cfLP3,
                        cfLPGaussian,
                        // High pass filters
                        cfHPMeanRemoval,
                        cfHP1,
                        cfHP2,
                        cfHP3,
                        // Shift and difference edge enhancement
                        cfHorizCDE,
                        cfVertCDE,
                        cfHorizVertCDE,
                        // Laplacian filters
                        cfLaplacian1,
                        cfLaplacian2,
                        cfLaplacian3,
                        cfDiagLaplace,
                        cfHorizLaplace,
                        cfVertLaplace,
                        // Gradient directional filters
                        cfEastGradDir,
                        cfSouthEastGradDir,
                        cfSouthGradDir,
                        cfSouthWestGradDir,
                        cfWestGradDir,
                        cfNorthWestGradDir,
                        cfNorthGradDir,
                        cfNorthEastGradDir,
                        // Embossing effects
                        cfEastEmboss,
                        cfSouthEastEmboss,
                        cfSouthEmboss,
                        cfSouthWestEmboss,
                        cfWestEmboss,
                        cfNorthWestEmboss,
                        cfNorthEmboss,
                        cfNorthEastEmboss,
                        // Sobel edge detection and contour filters
                        cfHorizSobelContour,
                        cfVertSobelContour,
                        cfHorizPrewitt,
                        cfVertPrewitt,
                        // Other filters
                        cfSharpen,
                        cfSoften,
                        cfSoftenLess,
                        cfColorEmboss);

procedure ShowMaxColor(Dst, Src1, Src2: TBitmap32);

// wrapper for using KERNEL_ARRAY constant with G32_WConvolution
procedure ApplyWConvolution(Bitmap32: TBitmap32; const Kernel: array of Integer);

procedure ApplyConvolution  (Dst, Src: TBitmap32; const Kernel: array of Integer);  overload;
procedure ApplyConvolution  (Bitmap32: TBitmap32; const Kernel: array of Integer);  overload;

//  type safe versions
procedure ApplyConvolution(Dst, Src: TBitmap32;  const ConvolutionFilter: TConvolutionFilter); overload;
procedure ApplyConvolution(Bitmap32: TBitmap32;  const ConvolutionFilter: TConvolutionFilter); overload;

// the following are so far just for testing
// apply a convolution then color subtract it from the original, etc
procedure SobelFilter(Dst, Src: TBitmap32; const UsePrewitt: Boolean = False);
procedure ColorSubtract(Dst, Src: TBitmap32);
procedure ColorAdd(Dst, Src: TBitmap32);
procedure ColorAverage(Dst, Src: TBitmap32);
procedure MaxColor(Dst, Src: TBitmap32);
procedure MinColor(Dst, Src: TBitmap32);
procedure Combine(Dst, Src1, Src2: TBitmap32; const Weight: TColor32);

const
  // the array with all the filters...
  KERNEL_ARRAY: array [0..42]  of TConvolutionKernel = (
    (0, 0, 0, 0, 1, 0, 0, 0, 0, 1), {0: Doesn't do anything}
    {*** Low pass filters ***}
    ( 1,  1,  1,  1,  1,  1,  1,  1,  1,  9), {1: Average}
    ( 1,  1,  1,  1,  2,  1,  1,  1,  1, 10), {2: LP1}
    ( 1,  1,  1,  1,  4,  1,  1,  1,  1, 12), {3: LP2}
    ( 1,  1,  1,  1, 12,  1,  1,  1,  1, 20), {4: LP3}
    ( 1,  2,  1,  2,  4,  2,  1,  2,  1, 16), {5: Gaussian}
    {*** High pass filters ***}
    (-1, -1, -1, -1,  9, -1, -1, -1, -1,  1), {6: Mean removal}
    ( 0, -1,  0, -1,  5, -1,  0, -1,  0,  1), {7: HP1}
    ( 1, -2,  1, -2,  5, -2,  1, -2,  1,  1), {8: HP2}
    ( 0, -1,  0, -1, 20, -1,  0, -1,  0, 16), {9: HP3}
    {*** Edge enhancment and detection filters ***}
    {*** Shift and difference edge enhancement ***}
    ( 0, -1,  0,  0,  1,  0,  0,  0,  0,  1), {10: Horizontal}
    ( 0,  0,  0, -1,  1,  0,  0,  0,  0,  1), {11: Vertical}
    (-1,  0,  0,  0,  1,  0,  0,  0,  0,  1), {12: Horizontal/Vertical}
    {*** Laplacian filters ***}
    ( 0, -1,  0, -1,  4, -1,  0, -1,  0,  1), {13: LAPL1}
    (-1, -1, -1, -1,  8, -1, -1, -1, -1,  1), {14: LAPL2}
    ( 1, -2,  1, -2,  4, -2,  1, -2,  1,  1), {15: LAPL3}
    (-1,  0, -1,  0,  4,  0, -1,  0, -1,  1), {16: Diagonal Laplace}
    ( 0, -1,  0,  0,  2,  0,  0, -1,  0,  1), {17: Horizontal Laplace}
    ( 0,  0,  0, -1,  2, -1,  0,  0,  0,  1), {18: Vertical Laplace}
    {** Gradient directional filters ***}
    (-1,  1,  1, -1, -2,  1, -1,  1,  1,  1), {19: East}
    (-1, -1,  1, -1, -2,  1,  1,  1,  1,  1), {20: South east}
    (-1, -1, -1,  1, -2,  1,  1,  1,  1,  1), {21: South}
    ( 1, -1, -1,  1, -2, -1,  1,  1,  1,  1), {22: South west}
    ( 1,  1, -1,  1, -2, -1,  1,  1, -1,  1), {23: West}
    ( 1,  1,  1,  1, -2,  1,  1, -1, -1,  1), {24: North west}
    ( 1,  1,  1,  1, -2,  1, -1, -1, -1,  1), {25: North}
    ( 1,  1,  1, -1, -2,  1, -1, -1,  1,  1), {26: North east}
    {*** Embossing effects ***}
    (-1,  0,  1, -1,  1,  1, -1,  0,  1,  1), {27: East}
    (-1, -1,  0, -1,  1,  1,  0,  1,  1,  1), {28: South East}
    (-1, -1, -1,  0,  1,  0,  1,  1,  1,  1), {29: South}
    ( 0, -1, -1,  1,  1, -1,  1,  1,  0,  1), {30: South West}
    ( 1,  0, -1,  1,  1, -1,  1,  0, -1,  1), {31: West}
    ( 1,  1,  0,  1,  1, -1,  0, -1, -1,  1), {32: North West}
    ( 1,  1,  1,  0,  1,  0, -1, -1, -1,  1), {33: North}
    ( 0,  1,  1, -1,  1,  1, -1, -1,  0,  1), {34: North East}
    {*** Sobel edge detection and contour filters ***}
    ( 1,  2,  1,  0,  0,  0, -1, -2, -1,  1), {35: Horizontal Sobel}
    ( 1,  0, -1,  2,  0, -2,  1,  0, -1,  1), {36: Vertical Sobel}
    (-1, -1, -1,  0,  0,  0,  1,  1,  1,  1), {37: Horizontal Prewitt}
    ( 1,  0, -1,  1,  0, -1,  1,  0, -1,  1), {38: Vertical Prewitt}
    {*** Other filters ***}
    (-1, -1, -1, -1, 16, -1, -1, -1, -1,  8), {39: Sharpen}
    ( 2,  2,  2,  2,  0,  2,  2,  2,  2, 16), {40: Soften}
    ( 0,  1,  0,  1,  2,  1,  0,  1,  0,  6), {41: Soften less}
    ( 1,  0,  1,  0,  0,  0,  1,  0, -2,  1)  {42: Color emboss}
          );

  // Filter constants, to pull from array
  NONE = 0;
  LP_AVERAGE = 1;
  LP1 = 2;
  LP2 = 3;
  LP3 = 4;
  GAUSSIAN = 5;
  MEAN_REMOVAL = 6;
  HP1 = 7;
  HP2 = 8;
  HP3 = 9;
  HORIZ_EDGE = 10;
  VERT_EDGE = 11;
  HORIZ_VERT_EDGE = 12;
  LAPL1 = 13;
  LAPL2 = 14;
  LAPL3 = 15;
  DIAG_LAPL = 16;
  HORIZ_LAPLACE = 17;
  VERT_LAPLACE = 18;
  EAST_GRAD_DIRECTIONAL = 19;
  SOUTH_EAST_GRAD_DIRECTIONAL = 20;
  SOUTH_GRAD_DIRECTIONAL = 21;
  SOUTH_WEST_GRAD_DIRECTIONAL = 22;
  WEST_GRAD_DIRECTIONAL = 23;
  NORTH_WEST_GRAD_DIRECTIONAL = 24;
  NORTH_GRAD_DIRECTIONAL = 25;
  NORTH_EAST_DIRECTIONAL = 26;
  EAST_EMBOSS = 27;
  SOUTH_EAST_EMBOSS = 28;
  SOUTH_EMBOSS = 29;
  SOUTH_WEST_EMBOSS = 30;
  WEST_EMBOSS = 31;
  NORTH_WEST_EMBOSS = 32;
  NORTH_EMBOSS = 33;
  NORTH_EAST_EMBOSS = 34;
  HORIZ_SOBEL = 35;
  VERT_SOBEL = 36;
  HORIZ_PREWITT = 37;
  VERT_PREWITT = 38;
  SHARPEN = 39;
  SOFTEN = 40;
  SOFTEN_LESS = 41;
  COLOR_EMBOSS = 42;

  // use this to fill a combo box
  CONVOLUTION_FILTERNAMES: array[0..42] of string =
    ('No filtering',
    'Average Low pass',
    'LP1 low pass',
    'LP2 low pass',
    'LP3 low pass',
    'Gaussian low pass',
    'Mean removal high pass',
    'HP1 high pass',
    'HP2 high pass',
    'HP3 high pass',
    'Horiz shift/difference edge enhance',
    'Vert shif/difference edge enhance',
    'Horiz/Vert shif/difference edge enhance',
    'Laplacian 1 edge enhance',
    'Laplacian 2 edge enhance',
    'Laplacian 3 edge enhance',
    'Diagonal Laplacian edge enhance',
    'Horiz Laplace edge enhance',
    'Vert Laplace edge enhance',
    'East gradient directional',
    'South-east gradient directional',
    'South gradient directional',
    'South-west gradient directional',
    'West gradient directional',
    'North-west gradient directional',
    'North gradient directional',
    'North-east gradient directional',
    'East emboss',
    'South-east emboss',
    'South emboss',
    'South-west emboss',
    'West emboss',
    'North-west emboss',
    'North emboss',
    'North-east emboss',
    'Horiz Sobel contour',
    'Vert Sobel contour',
    'Horiz Prewitt',
    'Vert Prewitt',
    'Sharpen',
    'Soften',
    'Soften less',
    'Color emboss'
    );





implementation

uses
  G32_WConvolution, GR32_Blend;

(*
procedure ApplyConvolution(Dst, Src: TBitmap32; const Kernel: array of Integer);
var
  i, x, y: Integer;
  PixelArray: array[0..8] of PColor32;
  DstPixel: PColor32;
  C, R, G, B: Integer;
  Rc, Gc, Bc: Cardinal;
begin
  Dst.Assign(Src);
  with Src do
    for y := 1 to Height - 2 do begin
      PixelArray[0] := PixelPtr[0, y - 1];
      PixelArray[1] := PixelPtr[1, y - 1];
      PixelArray[2] := PixelPtr[2, y - 1];
      PixelArray[3] := PixelPtr[0, y];
      PixelArray[4] := PixelPtr[1, y];
      PixelArray[5] := PixelPtr[2, y];
      PixelArray[6] := PixelPtr[0, y + 1];
      PixelArray[7] := PixelPtr[1, y + 1];
      PixelArray[8] := PixelPtr[2, y + 1];
      DstPixel := Dst.PixelPtr[0, y];
      for x := 1 to Width - 2 do begin
        R := 0;
        G := 0;
        B := 0;
        for i := 0 to 8 do begin
          C := PixelArray[i]^;
          R := R + ((C and $00FF0000) shr 16) * Kernel[i];
          G := G + ((C and $0000FF00) shr 8) * Kernel[i];
          B := B + ( C and $000000FF) * Kernel[i];
        end;
        R := R div Kernel[9];
        G := G div Kernel[9];
        B := B div Kernel[9];
        if R > 255 then Rc := 255
        else if R < 0 then Rc := 0
        else Rc := R;
        if G > 255 then Gc := 255
        else if G < 0 then Gc := 0
        else Gc := G;
        if B > 255 then Bc := 255
        else if B < 0 then Bc := 0
        else Bc := B;
        DstPixel^ := $FF000000 + Rc shl 16 + Gc shl 8 + Bc;
        //Dst.PixelPtr[x, y]^ := $FF000000 + Rc shl 16 + Gc shl 8 + Bc;
        for i := 0 to 8 do
          Inc(PixelArray[i]);
        Inc(DstPixel);
      end;
    end;
end;
*)


procedure ApplyConvolution(Dst, Src: TBitmap32; const Kernel: array of Integer);
var
  i, x_, y    : Integer;
  PixelArray : array[0..8] of PColor32;
  DstPixel   : PColor32;
  C, R, G, B : Integer;
  Rc, Gc, Bc : Cardinal;
begin
  Dst.Assign(Src);
  with Src do
    for y := 1 to Height - 2 do begin
      PixelArray[0] := PixelPtr[0, y - 1];
      PixelArray[1] := PixelPtr[1, y - 1];
      PixelArray[2] := PixelPtr[2, y - 1];
      PixelArray[3] := PixelPtr[0, y];
      PixelArray[4] := PixelPtr[1, y];
      PixelArray[5] := PixelPtr[2, y];
      PixelArray[6] := PixelPtr[0, y + 1];
      PixelArray[7] := PixelPtr[1, y + 1];
      PixelArray[8] := PixelPtr[2, y + 1];
      DstPixel := Dst.PixelPtr[1, y];

      for x_ := 1 to Width - 2 do begin
        R := 0;
        G := 0;
        B := 0;
        for i := 0 to 8 do begin
          C := PixelArray[i]^;
          R := R + ((C and $00FF0000) shr 16) * Kernel[i];
          G := G + ((C and $0000FF00) shr 8) * Kernel[i];
          B := B + ( C and $000000FF) * Kernel[i];
        end;
        R := R div Kernel[9];
        G := G div Kernel[9];
        B := B div Kernel[9];

        if R > 255 then Rc := 255
        else if R < 0 then Rc := 0
        else Rc := R;
        if G > 255 then Gc := 255
        else if G < 0 then Gc := 0
        else Gc := G;
        if B > 255 then Bc := 255
        else if B < 0 then Bc := 0
        else Bc := B;
        DstPixel^ := $FF000000 + Rc shl 16 + Gc shl 8 + Bc;

        for i := 0 to 8 do
          Inc(PixelArray[i]);
        Inc(DstPixel);
      end;
    end;
end;



procedure ApplyConvolution
  (Bitmap32: TBitmap32; const Kernel: array of Integer);
var
  Temp: TBitmap32;
begin
  Temp := TBitmap32.Create;
  try
    Temp.Assign(Bitmap32);
    ApplyConvolution(Bitmap32, Temp, Kernel);
  finally
    Temp.Free;
  end;
end;

//  type safe versions
procedure ApplyConvolution(Bitmap32: TBitmap32;
  const ConvolutionFilter: TConvolutionFilter);
var
  Temp: TBitmap32;
begin
  Temp := TBitmap32.Create;
  try
    Temp.Assign(Bitmap32);
    ApplyConvolution(Bitmap32, Temp, ConvolutionFilter);
  finally
    Temp.Free;
  end;
end;

procedure ApplyConvolution(Dst, Src: TBitmap32;
  const ConvolutionFilter: TConvolutionFilter);
begin
  case ConvolutionFilter of
    cfNone: Exit;
    cfLPAverage: ApplyConvolution(Dst, Src, KERNEL_ARRAY[LP_AVERAGE]);
    cfLP1: ApplyConvolution(Dst, Src, KERNEL_ARRAY[LP1]);
    cfLP2: ApplyConvolution(Dst, Src, KERNEL_ARRAY[LP2]);
    cfLP3: ApplyConvolution(Dst, Src, KERNEL_ARRAY[LP3]);
    cfLPGaussian: ApplyConvolution(Dst, Src, KERNEL_ARRAY[GAUSSIAN]);
    cfHPMeanRemoval: ApplyConvolution(Dst, Src, KERNEL_ARRAY[MEAN_REMOVAL]);
    cfHP1: ApplyConvolution(Dst, Src, KERNEL_ARRAY[HP1]);
    cfHP2: ApplyConvolution(Dst, Src, KERNEL_ARRAY[HP2]);
    cfHP3: ApplyConvolution(Dst, Src, KERNEL_ARRAY[HP3]);
    cfHorizCDE: ApplyConvolution(Dst, Src, KERNEL_ARRAY[HORIZ_EDGE]);
    cfVertCDE: ApplyConvolution(Dst, Src, KERNEL_ARRAY[VERT_EDGE]);
    cfHorizVertCDE: ApplyConvolution(Dst, Src, KERNEL_ARRAY[HORIZ_VERT_EDGE]);
    cfLaplacian1: ApplyConvolution(Dst, Src, KERNEL_ARRAY[LAPL1]);
    cfLaplacian2: ApplyConvolution(Dst, Src, KERNEL_ARRAY[LAPL2]);
    cfLaplacian3: ApplyConvolution(Dst, Src, KERNEL_ARRAY[LAPL3]);
    cfDiagLaplace: ApplyConvolution(Dst, Src, KERNEL_ARRAY[DIAG_LAPL]);
    cfHorizLaplace: ApplyConvolution(Dst, Src, KERNEL_ARRAY[HORIZ_LAPLACE]);
    cfVertLaplace: ApplyConvolution(Dst, Src, KERNEL_ARRAY[VERT_LAPLACE]);
    cfEastGradDir:
      ApplyConvolution(Dst, Src, KERNEL_ARRAY[EAST_GRAD_DIRECTIONAL]);
    cfSouthEastGradDir:
      ApplyConvolution(Dst, Src, KERNEL_ARRAY[SOUTH_EAST_GRAD_DIRECTIONAL]);
    cfSouthGradDir:
      ApplyConvolution(Dst, Src, KERNEL_ARRAY[SOUTH_GRAD_DIRECTIONAL]);
    cfSouthWestGradDir:
      ApplyConvolution(Dst, Src, KERNEL_ARRAY[SOUTH_WEST_GRAD_DIRECTIONAL]);
    cfWestGradDir:
      ApplyConvolution(Dst, Src, KERNEL_ARRAY[WEST_GRAD_DIRECTIONAL]);
    cfNorthWestGradDir:
      ApplyConvolution(Dst, Src, KERNEL_ARRAY[NORTH_WEST_GRAD_DIRECTIONAL]);
    cfNorthGradDir:
      ApplyConvolution(Dst, Src, KERNEL_ARRAY[NORTH_GRAD_DIRECTIONAL]);
    cfNorthEastGradDir:
      ApplyConvolution(Dst, Src, KERNEL_ARRAY[NORTH_EAST_DIRECTIONAL]);
    cfEastEmboss: ApplyConvolution(Dst, Src, KERNEL_ARRAY[EAST_EMBOSS]);
    cfSouthEastEmboss:
      ApplyConvolution(Dst, Src, KERNEL_ARRAY[SOUTH_EAST_EMBOSS]);
    cfSouthEmboss: ApplyConvolution(Dst, Src, KERNEL_ARRAY[SOUTH_EMBOSS]);
    cfSouthWestEmboss:
      ApplyConvolution(Dst, Src, KERNEL_ARRAY[SOUTH_WEST_EMBOSS]);
    cfWestEmboss: ApplyConvolution(Dst, Src, KERNEL_ARRAY[WEST_EMBOSS]);
    cfNorthWestEmboss:
      ApplyConvolution(Dst, Src, KERNEL_ARRAY[NORTH_WEST_EMBOSS]);
    cfNorthEmboss: ApplyConvolution(Dst, Src, KERNEL_ARRAY[NORTH_EMBOSS]);
    cfNorthEastEmboss:
      ApplyConvolution(Dst, Src, KERNEL_ARRAY[NORTH_EAST_EMBOSS]);
    cfHorizSobelContour: ApplyConvolution(Dst, Src, KERNEL_ARRAY[HORIZ_SOBEL]);
    cfVertSobelContour: ApplyConvolution(Dst, Src, KERNEL_ARRAY[VERT_SOBEL]);
    cfHorizPrewitt: ApplyConvolution(Dst, Src, KERNEL_ARRAY[HORIZ_PREWITT]);
    cfVertPrewitt: ApplyConvolution(Dst, Src, KERNEL_ARRAY[VERT_PREWITT]);
    cfSharpen: ApplyConvolution(Dst, Src, KERNEL_ARRAY[SHARPEN]);
    cfSoften: ApplyConvolution(Dst, Src, KERNEL_ARRAY[SOFTEN]);
    cfSoftenLess: ApplyConvolution(Dst, Src, KERNEL_ARRAY[SOFTEN_LESS]);
    cfColorEmboss: ApplyConvolution(Dst, Src, KERNEL_ARRAY[COLOR_EMBOSS]);
  end;
end;

// wrapper for using KERNEL_ARRAY constant with G32_WConvolution
procedure ApplyWConvolution(Bitmap32: TBitmap32; const Kernel: array of Integer);
var
  KArray: array[0..8] of integer;
  i: Integer;
begin
  for i := 0 to 8 do
    KArray[i] := Kernel[i];
  ConvolveI(KArray, Kernel[9], Bitmap32);
end;

// the following are so far just for testing

procedure ShowMaxColor(Dst, Src1, Src2: TBitmap32);
var
  x, y: Integer;
  Src1PCol, Src2PCol, DstPCol: PColor32;
begin


  if (Src1.Width <> Src2.Width) or (Src1.Height <> Src2.Height) then
    Exit;
  Dst.SetSizeFrom(Src1);
  for y := 0 to Src1.Height - 1 do begin
    Src1PCol := Src1.PixelPtr[0, y];
    Src2PCol := Src2.PixelPtr[0, y];
    DstPCol := Dst.PixelPtr[0, y];
    for x := 0 to Src1.Width -1 do begin
      {if (Src1PCol^) < AlphaComponent(Src2PCol^) then
        DstPCol^ := Src1PCol^
      else DstPCol^ := Src2PCol^;   }
      DstPCol^ := ColorMax(Src1PCol^, Src2PCol^);

      Inc(Src1PCol);
      Inc(Src2PCol);
      Inc(DstPCol);
    end;
  end;
  //EMMS;
end;

procedure SobelFilter(Dst, Src: TBitmap32; const UsePrewitt: Boolean = False);
  function ProcessColor(const HVal, VVal: Cardinal): Cardinal;
  var
    i: Integer;
  begin
    i := Round(Sqrt((HVal * HVal) + (VVal * VVal)));
    if i < 0 then i := 0
    else if i > 255 then i := 255;
    Result := i;
  end;
var
  H, V: TBitmap32;
  i: Integer;
  DstPColor, HPColor, VPColor: PColor32;
  HRedVal, HGreenVal, HBlueVal, VRedVal, VGreenVal, VBlueVal,
  RedVal, GreenVal, BlueVal: Cardinal;
  HColor, VColor: TColor32;
begin
  V := nil;
  H := TBitmap32.Create;
  try
    V := TBitmap32.Create;
    H.Assign(Src);
    V.Assign(Src);
    Dst.SetSizeFrom(Src);
    if UsePrewitt then begin
      ApplyConvolution(H, KERNEL_ARRAY[HORIZ_PREWITT]);
      ApplyConvolution(V, KERNEL_ARRAY[VERT_PREWITT]);
    end else begin
      ApplyConvolution(H, KERNEL_ARRAY[HORIZ_SOBEL]);
      ApplyConvolution(V, KERNEL_ARRAY[VERT_SOBEL]);
    end;
    DstPColor := @Dst.Bits[0];
    HPColor := @H.Bits[0];
    VPColor := @V.Bits[0];
    for i := 0 to Src.Width * Src.Height - 1 do  begin
      // seperate colors
      HColor := HPColor^;

      HRedVal := HColor and $00FF0000;
      HRedVal := HRedVal shr 16;

      HGreenVal := HColor and $0000FF00;
      HGreenVAl := HGreenVal shr 8;

      HBlueVal := HColor and $000000FF;

      VColor := VPColor^;

      VRedVal := VColor and $00FF0000;
      VRedVal := VRedVal shr 16;

      VGreenVal := VColor and $0000FF00;
      VGreenVAl := VGreenVal shr 8;

      VBlueVal := VColor and $000000FF;
      
      // take square root of sum of squares
      RedVal := ProcessColor(HRedVal, VRedVal);
      GreenVal := ProcessColor(HGreenVal, VGreenVal);
      BlueVal := ProcessColor(HBlueVal, VBlueVal);
      DstPColor^ := $FF000000 + RedVal shl 16 + GreenVal shl 8 + BlueVal;
      Inc(DstPColor);
      Inc(HPColor);
      Inc(VPColor);
    end;
  finally
    V.Free;
    H.Free;
  end;
end;

procedure ColorSubtract(Dst, Src: TBitmap32);
  function SubtractColor(const Orig, Filtered: Cardinal): Integer;
  begin
    Result := Orig - Filtered;
    if Result < 0 then Result := 0;
  end;
var
  i: Integer;
  DstPColor, SrcPColor: PColor32;
  R, G, B, RO, RF, GO, GF, BO, BF: Cardinal;
begin
  Dst.BeginUpdate;
  try
    if (Src.Width <> Dst.Width) or (Src.Height <> Dst.Height) then Exit;
    DstPColor := @Dst.Bits[0];
    SrcPColor := @Src.Bits[0];
    for i := 0 to Src.Width * Src.Height - 1 do  begin
      RO := SrcPColor^;
      RO := (RO and $00FF0000) shr 16;
      GO := SrcPColor^;
      GO := (GO and $0000FF00) shr 8;
      BO := SrcPColor^;
      BO := BO and $000000FF;
      RF := DstPColor^;
      RF := (RF and $00FF0000) shr 16;
      GF := DstPColor^;
      GF := (GF and $0000FF00) shr 8;
      BF := DstPColor^;
      BF := BF and $000000FF;
      R := SubtractColor(RO, RF);
      G := SubtractColor(GO, GF);
      B := SubtractColor(BO, BF);
      DstPColor^ := $FF000000 + R shl 16 + G shl 8 + B;
      Inc(DstPColor);
      Inc(SrcPColor)
    end;
  finally
    with Dst do begin
      EndUpdate;
      Changed;
    end;
  end;
end;

procedure ColorAverage(Dst, Src: TBitmap32);
var
  i: Integer;
  DstPColor, SrcPColor: PColor32;
  R, G, B, RO, RF, GO, GF, BO, BF: Cardinal;
begin
  Dst.BeginUpdate;
  try
    if (Src.Width <> Dst.Width) or (Src.Height <> Dst.Height) then Exit;
    DstPColor := @Dst.Bits[0];
    SrcPColor := @Src.Bits[0];
    for i := 0 to Src.Width * Src.Height - 1 do  begin
      RO := SrcPColor^;
      RO := (RO and $00FF0000) shr 16;
      GO := SrcPColor^;
      GO := (GO and $0000FF00) shr 8;
      BO := SrcPColor^;
      BO := BO and $000000FF;
      RF := DstPColor^;
      RF := (RF and $00FF0000) shr 16;
      GF := DstPColor^;
      GF := (GF and $0000FF00) shr 8;
      BF := DstPColor^;
      BF := BF and $000000FF;
      R := (RO + RF) div 2;
      G := (GO + GF) div 2;
      B := (BO + BF) div 2;
      DstPColor^ := $FF000000 + R shl 16 + G shl 8 + B;
      Inc(DstPColor);
      Inc(SrcPColor)
    end;
  finally
    with Dst do begin
      EndUpdate;
      Changed;
    end;
  end;
end;

procedure ColorAdd(Dst, Src: TBitmap32);
  function AddColor(const A, B: Cardinal): Integer;
  begin
    Result := A + B;
    if Result > 255 then Result := 255;
  end;
var
  i: Integer;
  DstPColor, SrcPColor: PColor32;
  R, G, B, RO, RF, GO, GF, BO, BF: Cardinal;
begin
  Dst.BeginUpdate;
  try
    if (Src.Width <> Dst.Width) or (Src.Height <> Dst.Height) then Exit;
    DstPColor := @Dst.Bits[0];
    SrcPColor := @Src.Bits[0];
    for i := 0 to Src.Width * Src.Height - 1 do  begin
      RO := SrcPColor^;
      RO := (RO and $00FF0000) shr 16;
      GO := SrcPColor^;
      GO := (GO and $0000FF00) shr 8;
      BO := SrcPColor^;
      BO := BO and $000000FF;
      RF := DstPColor^;
      RF := (RF and $00FF0000) shr 16;
      GF := DstPColor^;
      GF := (GF and $0000FF00) shr 8;
      BF := DstPColor^;
      BF := BF and $000000FF;
      R := AddColor(RO, RF);
      G := AddColor(GO, GF);
      B := AddColor(BO, BF);
      DstPColor^ := $FF000000 + R shl 16 + G shl 8 + B;
      Inc(DstPColor);
      Inc(SrcPColor)
    end;
  finally
    with Dst do begin
      EndUpdate;
      Changed;
    end;
  end;
end;

procedure MaxColor(Dst, Src: TBitmap32);
var
  i: Integer;
  DstPColor, SrcPColor: PColor32;
  R, G, B, RO, RF, GO, GF, BO, BF: Cardinal;
begin
  Dst.BeginUpdate;
  try
    if (Src.Width <> Dst.Width) or (Src.Height <> Dst.Height) then Exit;
    DstPColor := @Dst.Bits[0];
    SrcPColor := @Src.Bits[0];
    for i := 0 to Src.Width * Src.Height - 1 do  begin
      RO := SrcPColor^;
      RO := (RO and $00FF0000) shr 16;
      GO := SrcPColor^;
      GO := (GO and $0000FF00) shr 8;
      BO := SrcPColor^;
      BO := BO and $000000FF;
      RF := DstPColor^;
      RF := (RF and $00FF0000) shr 16;
      GF := DstPColor^;
      GF := (GF and $0000FF00) shr 8;
      BF := DstPColor^;
      BF := BF and $000000FF;
      if RO > RF then R := RO else R := RF;
      if GO > GF then G := GO else G := GF;
      if BO > BF then B := BO else B := BF;
      DstPColor^ := $FF000000 + R shl 16 + G shl 8 + B;
      Inc(DstPColor);
      Inc(SrcPColor)
    end;
  finally
    with Dst do begin
      EndUpdate;
      Changed;
    end;
  end;
end;

procedure MinColor(Dst, Src: TBitmap32);
var
  i: Integer;
  DstPColor, SrcPColor: PColor32;
  R, G, B, RO, RF, GO, GF, BO, BF: Cardinal;
begin
  Dst.BeginUpdate;
  try
    if (Src.Width <> Dst.Width) or (Src.Height <> Dst.Height) then Exit;
    DstPColor := @Dst.Bits[0];
    SrcPColor := @Src.Bits[0];
    for i := 0 to Src.Width * Src.Height - 1 do  begin
      RO := SrcPColor^;
      RO := (RO and $00FF0000) shr 16;
      GO := SrcPColor^;
      GO := (GO and $0000FF00) shr 8;
      BO := SrcPColor^;
      BO := BO and $000000FF;
      RF := DstPColor^;
      RF := (RF and $00FF0000) shr 16;
      GF := DstPColor^;
      GF := (GF and $0000FF00) shr 8;
      BF := DstPColor^;
      BF := BF and $000000FF;
      if RO > RF then R := RF else R := RO;
      if GO > GF then G := GF else G := GO;
      if BO > BF then B := BF else B := BO;
      DstPColor^ := $FF000000 + R shl 16 + G shl 8 + B;
      Inc(DstPColor);
      Inc(SrcPColor)
    end;
  finally
    with Dst do begin
      EndUpdate;
      Changed;
    end;
  end;
end;

procedure Combine(Dst, Src1, Src2: TBitmap32; const Weight: TColor32);
var
  i: Integer;
  DstPColor, Src1PColor, Src2PColor: PColor32;
begin
  if (Src1.Width <> Src2.Width) or (Src1.Height <> Src2.Height) then Exit;
  Dst.SetSizeFrom(Src1);
  DstPColor := @Dst.Bits[0];
  Src1PColor := @Src1.Bits[0];
  Src2PColor := @Src2.Bits[0];
  for i := 0 to Src1.Width * Src1.Height - 1 do  begin
    DstPColor^ := CombineReg(Src1PColor^, Src2PColor^, Weight);
    EMMS;
    Inc(DstPColor);
    Inc(Src1PColor);
    Inc(Src2PColor);
  end;
  Dst.Changed;
end;

end.

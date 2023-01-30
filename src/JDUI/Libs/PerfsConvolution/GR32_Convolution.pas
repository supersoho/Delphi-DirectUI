unit GR32_Convolution;
{
  Matrix based convolution filters for GR32.

 Contributors :
  Antti Lukats (antti AT case2000.com),
  Patrick Quinn (patrick AT thequinns.worldonline.co.uk),
  Vladimir Vasilyev (Vladimir AT tometric.ru),
  Marc Lafon (marc.lafon AT free.fr).

 Version 1.0 (November 2005).
   - functions for convolution with 5x5 and 7x7 matrix.
   - dual implementation MMX and non MMX.
   - special optimized function for most commons convolutions (blur, sharpen, etc.)
   - diferents implementations for normalized and not normalized matrix
     (divide operation does not exist in MMX)


TODO :
  - MMX implementation of 7x7 kernel convolutions.


 Based on :

 - G32_Convolution unit by Antti Lukats (antti AT case2000.com)

 - pqGR32_Convolution unit by Patrick Quinn. July 2002.
  patrick AT thequinns.worldonline.co.uk
  He has added an array of array of constants for the different filters, makes
  programming easier.
  Additional filters from Ender Wiggin's excellent article,
  'Elementary Digital Filtering' at
  http://www.gamedev.net/reference/programming/features/edf/default.asp

 - G32_WConvolution unit by Vladimir Vasilyev
   http://www.gamedev.narod.ru
   W-develop AT mtu-net.ru
   Vladimir AT tometric.ru
 who based his unit on: Harm's example of a 3 x 3 convolution
 using 24-bit bitmaps and scanline
  http://www.users.uswest.net/~sharman1/
  sharman1 AT uswest.net

  see also :
  An introduction to Digital Image Processing
  by Frédéric Patin
  http://www.gamedev.net/reference/programming/features/imageproc/


 ***** BEGIN LICENSE BLOCK *****

 Version: MPL 1.1

 The contents of this file are subject to the Mozilla Public License Version
 1.1 (the "License"); you may not use this file except in compliance with
 the License. You may obtain a copy of the License at
 http://www.mozilla.org/MPL/

 Software distributed under the License is distributed on an "AS IS" basis,
 WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 for the specific language governing rights and limitations under the
 License.

 ***** END LICENSE BLOCK *****

}

interface


uses
  GR32,GR32_Blend;


type
  // 3x3 Indexes 0..8 are the convolution coefficients, Index 9 is the normalization constant
  TConvolutionKernel3x3 = array[0..9] of Integer;
  TConvolutionKernel5x5 = array[0..25] of Integer;
  TConvolutionKernel7x7 = array[0..49] of Integer;



{ 7x7 Convolution Kernels }
  TConvolutionFilter3x3 = (cfNone,
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
                          cfColorEmboss,
                          cfEmbossMore, // <-- new filters
                          cfEmboss,
                          cfEmbossHorz,
                          cfEmbossVert);

procedure ApplyConvolution3x3(Dst, Src: TBitmap32;const ConvolutionFilter: TConvolutionFilter3x3;bias:integer=0); overload;
procedure ApplyConvolution3x3(Bitmap32: TBitmap32;const ConvolutionFilter: TConvolutionFilter3x3;bias:integer=0); overload;
procedure ApplyConvolution3x3(Dst, Src: TBitmap32;const Kernel: array of Integer;bias:integer=0);  overload;
procedure ApplyConvolution3x3(Bitmap32: TBitmap32;const Kernel: array of Integer;bias:integer=0);  overload;


{ 5x5 Convolution Kernels }
type
  TConvolutionFilter5x5 = (cf5None,
                           cf5GaussianBlur,
                           cf5HorzEdges,
                           cf5VertEdges,
                           cf5Laplace,
                           cf5HPMeanRemoval,
                           cf5Emboss);

procedure ApplyConvolution5x5(Dst, Src: TBitmap32;const ConvolutionFilter: TConvolutionFilter5x5;bias:integer=0); overload;
procedure ApplyConvolution5x5(Bitmap32: TBitmap32;const ConvolutionFilter: TConvolutionFilter5x5;bias:integer=0); overload;
procedure ApplyConvolution5x5(Dst, Src: TBitmap32;const Kernel: array of Integer;bias:integer=0);  overload;
procedure ApplyConvolution5x5(Bitmap32: TBitmap32;const Kernel: array of Integer;bias:integer=0);  overload;


{ 7x7 Convolution Kernels }
type
  TConvolutionFilter7x7 = (cf7None);

procedure ApplyConvolution7x7(Dst, Src: TBitmap32;const ConvolutionFilter: TConvolutionFilter7x7;bias:integer=0); overload;
procedure ApplyConvolution7x7(Bitmap32: TBitmap32;const ConvolutionFilter: TConvolutionFilter7x7;bias:integer=0); overload;
procedure ApplyConvolution7x7(Dst, Src: TBitmap32;const Kernel: array of Integer;bias:integer=0);  overload;
procedure ApplyConvolution7x7(Bitmap32: TBitmap32;const Kernel: array of Integer;bias:integer=0);  overload;


{ Optimization of most used kernels ... }
type
  TConvolutionOperation=procedure(Dst, Src: TBitmap32);

var
  GaussianBlur : TConvolutionOperation;
  Sharpness : TConvolutionOperation; { HP1 kernel equivalent }

procedure GaussianBlurEx(Bitmap32: TBitmap32);
procedure SharpnessEx(Bitmap32: TBitmap32);


{ Apply some ColorOperation (see GR32_Blend.pas) on every pixels of Src1
  and Src2. Dst can be one of the sources. Src1.Width*Src1.Height need to be
  equal to Src2.Width*Src2.Height but the bitmaps sizes don't really need to be
  the same.
  After the operation Dst has the same size than Src1. }
procedure ColorOperation(Dst, Src1, Src2: TBitmap32;ColorOp:TBlendReg);


{ Simple bitmap filter functions, they use a 2x2 sampling and test differences
  between the point[X,Y] and the result of ColorOp(Point[X+1,Y],Point[X,Y+1]) }
procedure EdgeFilterUp(Bitmap:TBitmap32;threshold,ColorBack:TColor32;ColorOp:TBlendReg);
procedure EdgeFilterDown(Bitmap:TBitmap32;threshold,ColorBack:TColor32;ColorOp:TBlendReg);
procedure EdgeFilter(Bitmap:TBitmap32;thresholdUP,thresholdDOWN,ColorBack:TColor32;ColorOp:TBlendReg);


{ Special Color Arithmetic operation }
{ Theses function does not return a TColor32 but the distance between the two
  parameters, }
var
  ColorHypot2:TBlendReg; { return the square of Hypot }
  ColorAbsNorm:TBlendReg;{ return the sum of absolute differences }


implementation

uses GR32_System,GR32_MathAddons;

const
  // the array with all the filters...
  KERNEL3X3_ARRAY: array [TConvolutionFilter3x3]  of TConvolutionKernel3x3 = (
    (0, 0, 0,
     0, 1, 0,
     0, 0, 0, 1), {0: Doesn't do anything}

    {*** Low pass filters ***}
    ( 1,  1,  1,
      1,  1,  1,
      1,  1,  1,  9), {1: Average}

    ( 1,  1,  1,
      1,  2,  1,
      1,  1,  1, 10), {2: LP1}

    ( 1,  1,  1,
      1,  4,  1,
      1,  1,  1, 12), {3: LP2}

    ( 1,  1,  1,
      1, 12,  1,
      1,  1,  1, 20), {4: LP3}

    ( 1,  2,  1,
      2,  4,  2,
      1,  2,  1, 16), {5: Gaussian}

    {*** High pass filters ***}
    (-1, -1, -1,
     -1,  9, -1,
     -1, -1, -1,  1), {6: Mean removal}

    ( 0, -1,  0,
     -1,  5, -1,
      0, -1,  0,  1), {7: HP1}

    ( 1, -2,  1,
     -2,  5, -2,
      1, -2,  1,  1), {8: HP2}

    ( 0, -1,  0,
     -1, 20, -1,
      0, -1,  0, 16), {9: HP3}

    {*** Edge enhancment and detection filters ***}
    {*** Shift and difference edge enhancement ***}
    ( 0, -1,  0,
      0,  1,  0,
      0,  0,  0,  1), {10: Horizontal}

    ( 0,  0,  0,
     -1,  1,  0,
      0,  0,  0,  1), {11: Vertical}

    (-1,  0,  0,
      0,  1,  0,
      0,  0,  0,  1), {12: Horizontal/Vertical}

    {*** Laplacian filters ***}
    ( 0, -1,  0,
     -1,  4, -1,
      0, -1,  0,  1), {13: LAPL1}

    (-1, -1, -1,
     -1,  8, -1,
     -1, -1, -1,  1), {14: LAPL2}

    ( 1, -2,  1,
     -2,  4, -2,
      1, -2,  1,  1), {15: LAPL3}

    (-1,  0, -1,
      0,  4,  0,
     -1,  0, -1,  1), {16: Diagonal Laplace}

    ( 0, -1,  0,
      0,  2,  0,
      0, -1,  0,  1), {17: Horizontal Laplace}

    ( 0,  0,  0,
     -1,  2, -1,
      0,  0,  0,  1), {18: Vertical Laplace}

    {** Gradient directional filters ***}
    (-1,  1,  1,
     -1, -2,  1,
     -1,  1,  1,  1), {19: East}

    (-1, -1,  1,
     -1, -2,  1,
      1,  1,  1,  1), {20: South east}

    (-1, -1, -1,
      1, -2,  1,
      1,  1,  1,  1), {21: South}

    ( 1, -1, -1,
      1, -2, -1,
      1,  1,  1,  1), {22: South west}

    ( 1,  1, -1,
      1, -2, -1,
      1,  1, -1,  1), {23: West}

    ( 1,  1,  1,
      1, -2,  1,
      1, -1, -1,  1), {24: North west}

    ( 1,  1,  1,
      1, -2,  1,
     -1, -1, -1,  1), {25: North}

    ( 1,  1,  1,
     -1, -2,  1,
     -1, -1,  1,  1), {26: North east}

    {*** Embossing effects ***}
    (-1,  0,  1,
     -1,  1,  1,
     -1,  0,  1,  1), {27: East}

    (-1, -1,  0,
     -1,  1,  1,
      0,  1,  1,  1), {28: South East}

    (-1, -1, -1,
      0,  1,  0,
      1,  1,  1,  1), {29: South}

    ( 0, -1, -1,
      1,  1, -1,
      1,  1,  0,  1), {30: South West}

    ( 1,  0, -1,
      1,  1, -1,
      1,  0, -1,  1), {31: West}

    ( 1,  1,  0,
      1,  1, -1,
      0, -1, -1,  1), {32: North West}

    ( 1,  1,  1,
      0,  1,  0,
     -1, -1, -1,  1), {33: North}

    ( 0,  1,  1,
     -1,  1,  1,
     -1, -1,  0,  1), {34: North East}

    {*** Sobel edge detection and contour filters ***}
    ( 1,  2,  1,
      0,  0,  0,
     -1, -2, -1,  1), {35: Horizontal Sobel}

    ( 1,  0, -1,
      2,  0, -2,
      1,  0, -1,  1), {36: Vertical Sobel}

    (-1, -1, -1,
      0,  0,  0,
      1,  1,  1,  1), {37: Horizontal Prewitt}

    ( 1,  0, -1,
      1,  0, -1,
      1,  0, -1,  1), {38: Vertical Prewitt}

    {*** Other filters ***}
    (-1, -1, -1,
     -1, 16, -1,
     -1, -1, -1,  8), {39: Sharpen}

    ( 2,  2,  2,
      2,  0,  2,
      2,  2,  2, 16), {40: Soften}

    ( 0,  1,  0,
      1,  2,  1,
      0,  1,  0,  6), {41: Soften less}

    ( 1,  0,  1,
      0,  0,  0,
      1,  0, -2,  1), {42: Color emboss}

    ( 1,  1, -1,
      1,  1, -1,
      1, -1, -1,  1), {43: Emboss More}

    ( 1,  1, -1,
      1,  3, -1,
      1, -1, -1,  3), {44: Emboss}

    ( 1,  1,  1,
      0,  1,  0,
     -1, -1, -1,  1), {45: Emboss Horizontal}

    ( 1,  0, -1,
      1,  1, -1,
      1,  0, -1,  1) {46: Emboss Vertical}
  );

  KERNEL5X5_ARRAY: array [TConvolutionFilter5x5]  of TConvolutionKernel5x5 = (
    (0,0,0,0,0,
     0,0,0,0,0,
     0,0,1,0,0,
     0,0,0,0,0,
     0,0,0,0,0, 1),      {0: Doesn't do anything}

    (1, 4, 6, 4,1,
     4,16,24,16,4,
     6,24,36,24,6,
     4,16,24,16,4,
     1, 4, 6, 4,1, 256),   {1: Gaussian Blur }

    (-1,-1,-1,-1,-1,
     -2,-2,-2,-2,-2,
      0, 0, 0, 0, 0,
      2, 2, 2, 2, 2,
      1, 1, 1, 1, 1, 1), {2: Horizontal Edge }

    (-1,-2,0,-2,-1,
     -1,-2,0,-2,-1,
     -1,-2,0,-2,-1,
     -1,-2,0,-2,-1,
     -1,-2,0,-2,-1, 1),   {3: Vertical Edge }

    (-1,-3,-4,-3,-1,
     -3, 0, 6, 0,-3,
     -4, 6,20, 6,-4,
     -3, 0, 6, 0,-3,
     -1,-3,-4,-3,-1, 1), {4: Laplace }

    (-1,-1,-1,-1,-1,
     -1,-1,-1,-1,-1,
     -1,-1,24,-1,-1,
     -1,-1,-1,-1,-1,
     -1,-1,-1,-1,-1, 1), {5: HPass}

    (-1, 0,0,0,0,
      0,-2,0,0,0,
      0, 0,4,0,0,
      0, 0,0,0,0,
      0, 0,0,0,0, 1)    {6: Emboss}
   );

  KERNEL7X7_ARRAY: array [TConvolutionFilter7x7]  of TConvolutionKernel7x7 = (
    (0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,
     0,0,0,1,0,0,0,
     0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,
     0,0,0,0,0,0,0, 1) {0: Doesn't do anything}
  );

type
  TMMXRegister = packed record
  case Integer of
    0: (B0,B1,B2,B3,B4,B5,B6,B7: Byte);
    1: (W0,W1,W2,W3: Word);
    2: (I0,I1: Cardinal);
  end;

  TInternalApplyConvolutionPower = procedure(Dst, Src: TBitmap32; const Kernel: array of Integer;power,bias:integer);
  TInternalApplyConvolution = procedure(Dst, Src: TBitmap32; const Kernel: array of Integer;bias:integer);
  TInternalApplyConvolutionNormal = procedure(Dst, Src: TBitmap32; const Kernel: array of Integer);


var
  InternalApplyConvolution3x3:TInternalApplyConvolution;
  InternalApplyConvolution5x5:TInternalApplyConvolution;
  InternalApplyConvolution7x7:TInternalApplyConvolution;
  InternalApplyConvolution3x3Normal:TInternalApplyConvolutionNormal;
  InternalApplyConvolution5x5Normal:TInternalApplyConvolutionNormal;
//  InternalApplyConvolution7x7Normal:TInternalApplyConvolutionNormal;
  InternalApplyConvolution3x3Power:TInternalApplyConvolutionPower;
  InternalApplyConvolution5x5Power:TInternalApplyConvolutionPower;
//  InternalApplyConvolution7x7Power:TInternalApplyConvolutionPower;

procedure ApplyConvolution3x3(Dst, Src: TBitmap32;const Kernel: array of Integer;bias:integer=0);  overload;
var
  p:integer;
begin
  if (bias = 0) and (Kernel[9] = 1) then
    InternalApplyConvolution3x3Normal(Dst,Src,Kernel)
  else
  begin
    p := maxBitSet(Kernel[9]);
    if p = minBitSet(Kernel[9]) then // The factor is a power of 2.
      InternalApplyConvolution3x3Power(Dst,Src,Kernel,p,bias)
    else
      InternalApplyConvolution3x3(Dst,Src,Kernel,bias);
  end;
end;

procedure ApplyConvolution3x3(Bitmap32: TBitmap32;const Kernel: array of Integer;bias:integer=0);  overload;
var
  Temp: TBitmap32;
begin
  Temp := TBitmap32.Create;
  try
    Temp.Assign(Bitmap32);
    ApplyConvolution3x3(Bitmap32, Temp,Kernel,bias);
  finally
    Temp.Free;
  end;
end;

procedure ApplyConvolution3x3(Dst, Src: TBitmap32;const ConvolutionFilter: TConvolutionFilter3x3;bias:integer=0); overload;
begin
  ApplyConvolution3x3(Dst,Src,KERNEL3X3_ARRAY[ConvolutionFilter],bias);
end;

procedure ApplyConvolution3x3(Bitmap32: TBitmap32;const ConvolutionFilter: TConvolutionFilter3x3;bias:integer=0); overload;
begin
  ApplyConvolution3x3(Bitmap32,KERNEL3X3_ARRAY[ConvolutionFilter],bias);
end;


procedure ApplyConvolution5x5(Dst, Src: TBitmap32;const Kernel: array of Integer;bias:integer=0);  overload;
var
  p:integer;
begin
  if (bias = 0) and (Kernel[25] = 1) then
    InternalApplyConvolution5x5Normal(Dst,Src,Kernel)
  else
  begin
    p := maxBitSet(Kernel[25]);
    if p = minBitSet(Kernel[25]) then // The factor is a power of 2.
      InternalApplyConvolution5x5Power(Dst,Src,Kernel,p,bias)
    else
      InternalApplyConvolution5x5(Dst,Src,Kernel,bias);
  end;
end;

procedure ApplyConvolution5x5(Bitmap32: TBitmap32;const Kernel: array of Integer;bias:integer=0);  overload;
var
  Temp: TBitmap32;
begin
  Temp := TBitmap32.Create;
  try
    Temp.Assign(Bitmap32);
    ApplyConvolution5x5(Bitmap32, Temp,Kernel,bias);
  finally
    Temp.Free;
  end;
end;

procedure ApplyConvolution5x5(Dst, Src: TBitmap32;const ConvolutionFilter: TConvolutionFilter5x5;bias:integer=0); overload;
begin
  ApplyConvolution5x5(Dst,Src,KERNEL5X5_ARRAY[ConvolutionFilter],bias);
end;

procedure ApplyConvolution5x5(Bitmap32: TBitmap32;const ConvolutionFilter: TConvolutionFilter5x5;bias:integer=0); overload;
begin
  ApplyConvolution5x5(Bitmap32,KERNEL5X5_ARRAY[ConvolutionFilter],bias);
end;


procedure ApplyConvolution7x7(Dst, Src: TBitmap32;const Kernel: array of Integer;bias:integer=0);  overload;
begin
//  if (bias = 0) and (Kernel[9] = 1) then
//    InternalApplyConvolution7x7Normal(Dst,Src,Kernel)
//  else
    InternalApplyConvolution7x7(Dst,Src,Kernel,bias);
end;

procedure ApplyConvolution7x7(Bitmap32: TBitmap32;const Kernel: array of Integer;bias:integer=0);  overload;
var
  Temp: TBitmap32;
begin
  Temp := TBitmap32.Create;
  try
    Temp.Assign(Bitmap32);
    ApplyConvolution7x7(Bitmap32, Temp,Kernel,bias);
  finally
    Temp.Free;
  end;
end;

procedure ApplyConvolution7x7(Dst, Src: TBitmap32;const ConvolutionFilter: TConvolutionFilter7x7;bias:integer=0); overload;
begin
  ApplyConvolution7x7(Dst,Src,KERNEL7X7_ARRAY[ConvolutionFilter],bias);
end;

procedure ApplyConvolution7x7(Bitmap32: TBitmap32;const ConvolutionFilter: TConvolutionFilter7x7;bias:integer=0); overload;
begin
  ApplyConvolution7x7(Bitmap32,KERNEL7X7_ARRAY[ConvolutionFilter],bias);
end;


procedure ColorOperation(Dst, Src1, Src2: TBitmap32;ColorOp:TBlendReg);
var
  i: Integer;
begin
  if Length(Src1.Bits^) <> Length(Src2.Bits^) then
    Exit;
  if (Dst <> Src1) and (Dst <> Src2) then
    Dst.SetSizeFrom(Src1);
  for i := 0 to High(Src1.Bits^) do
    Dst.Bits^[i] := ColorOp(Src1.Bits^[i], Src2.Bits^[i]);
  EMMS;
  Dst.Changed;
end;

procedure EdgeFilterUp(Bitmap:TBitmap32;threshold,ColorBack:TColor32;ColorOp:TBlendReg);
var
  i,j:integer;
  Src1,Src0,Src2:PColor32;
begin
  Src0 := Bitmap.PixelPtr[0,0];
  Src1 := Bitmap.PixelPtr[1,0];
  Src2 := Bitmap.PixelPtr[0,1];
  with Bitmap do
    for j := 0 to Height - 2 do
    begin
      for i := 0 to Width - 2 do
      begin
        if (ColorOp(Src1^,Src0^) < threshold) and
           (ColorOp(Src2^,Src0^) < threshold) then
          Src0^ := ColorBack;
        Inc(Src0);
        Inc(Src1);
        Inc(Src2);
      end;
      Inc(Src0);
      Inc(Src1);
      Inc(Src2);
    end;
  EMMS;
  Bitmap.Changed;
end;

procedure EdgeFilterDown(Bitmap:TBitmap32;threshold,ColorBack:TColor32;ColorOp:TBlendReg);
var
  i,j:integer;
  Src1,Src0,Src2:PColor32;
begin
  Src0 := Bitmap.PixelPtr[0,0];
  Src1 := Bitmap.PixelPtr[1,0];
  Src2 := Bitmap.PixelPtr[0,1];
  with Bitmap do
    for j := 0 to Height - 2 do
    begin
      for i := 0 to Width - 2 do
      begin
        if (ColorOp(Src1^,Src0^) > threshold) and
           (ColorOp(Src2^,Src0^) > threshold) then
          Src0^ := ColorBack;
        Inc(Src0);
        Inc(Src1);
        Inc(Src2);
      end;
      Inc(Src0);
      Inc(Src1);
      Inc(Src2);
    end;
  EMMS;
  Bitmap.Changed;
end;

procedure EdgeFilter(Bitmap:TBitmap32;thresholdUp,thresholdDOWN,ColorBack:TColor32;ColorOp:TBlendReg);
var
  i,j:integer;
  Src1,Src0,Src2:PColor32;
  C1,C2:TColor32;
begin
  Src0 := Bitmap.PixelPtr[0,0];
  Src1 := Bitmap.PixelPtr[1,0];
  Src2 := Bitmap.PixelPtr[0,1];
  with Bitmap do
    for j := 0 to Height - 2 do
    begin
      for i := 0 to Width - 2 do
      begin
        C1 := ColorOp(Src1^,Src0^);
        C2 := ColorOp(Src2^,Src0^);
        if ((C1 > thresholdDOWN) and
            (C1 > thresholdDOWN)) or
           ((C2 < thresholdUP) and
            (C2 < thresholdUP)) then
          Src0^ := ColorBack;
        Inc(Src0);
        Inc(Src1);
        Inc(Src2);
      end;
      Inc(Src0);
      Inc(Src1);
      Inc(Src2);
    end;
  EMMS;
  Bitmap.Changed;
end;

procedure SetMMX_W(Var R: TMMXRegister; Value: integer);
begin
  R.W0 := word(Value);
  R.W1 := word(Value);
  R.W2 := word(Value);
  R.W3 := word(Value);
end;

procedure SharpnessEx(Bitmap32: TBitmap32);
var
  Temp: TBitmap32;
begin
  Temp := TBitmap32.Create;
  try
    Temp.Assign(Bitmap32);
    GaussianBlur(Bitmap32, Temp);
  finally
    Temp.Free;
  end;
end;

procedure _Sharpness(Dst, Src: TBitmap32);
var
  i, x, y: Integer;
  PixelArray: array[0..4] of PColor32;
  DstPixel: PColor32;
  C, A, R, G, B: Integer;
begin
  Dst.Assign(Src);
  if (Src.Width < 3) or (Src.Height < 3) then
    Exit;
  with Src do
  begin
    PixelArray[0] := PixelPtr[1, 0];
    PixelArray[1] := PixelPtr[0, 1];
    PixelArray[2] := PixelPtr[1, 1];
    PixelArray[3] := PixelPtr[2, 1];
    PixelArray[4] := PixelPtr[1, 2];
  end;
  DstPixel := Dst.PixelPtr[1, 1];
  for y := 1 to Src.Height - 2 do
  begin
    for x := 1 to Src.Width - 2 do
    begin
// Matrix = ( 0, -1,  0, -1,  5, -1,  0, -1,  0) {7: HP1}
      C := PixelArray[2]^;
      Inc(PixelArray[2]);
      A := ((C and $FF000000) shr 24) * 5;
      R := ((C and $00FF0000) shr 16) * 5;
      G := ((C and $0000FF00) shr 8) * 5;
      B := ( C and $000000FF) * 5;
      Inc(PixelArray[0]);
      C := PixelArray[0]^;
      Dec(A, (C and $FF000000) shr 24);
      Dec(R, (C and $00FF0000) shr 16);
      Dec(G, (C and $0000FF00) shr 8);
      Dec(B,  C and $000000FF);
      Inc(PixelArray[1]);
      C := PixelArray[1]^;
      Dec(A, (C and $FF000000) shr 24);
      Dec(R, (C and $00FF0000) shr 16);
      Dec(G, (C and $0000FF00) shr 8);
      Dec(B,  C and $000000FF);
      Inc(PixelArray[3]);
      C := PixelArray[3]^;
      Dec(A, (C and $FF000000) shr 24);
      Dec(R, (C and $00FF0000) shr 16);
      Dec(G, (C and $0000FF00) shr 8);
      Dec(B,  C and $000000FF);
      Inc(PixelArray[4]);
      C := PixelArray[4]^;
      Dec(A, (C and $FF000000) shr 24);
      if A > 255 then A := 255
      else if A < 0 then A := 0;
      Dec(R, (C and $00FF0000) shr 16);
      if R > 255 then R := 255
      else if R < 0 then R := 0;
      Dec(G, (C and $0000FF00) shr 8);
      if G > 255 then G := 255
      else if G < 0 then G := 0;
      Dec(B,  C and $000000FF);
      if B > 255 then B := 255
      else if B < 0 then B := 0;
      DstPixel^ := (Cardinal(A) shl 24) or (Cardinal(R) shl 16) or (Cardinal(G) shl 8) or Cardinal(B);
      Inc(DstPixel);
    end;
    for i := 0 to 4 do //next line
      Inc(PixelArray[i],2);
    Inc(DstPixel,2);
  end;
end;

procedure M_Sharpness(Dst, Src: TBitmap32);
const
  MMX5DWORD : int64 = $0005000500050005;
var
  I,J: Integer;
  DCP,A2,B2,C2: PColor32;
begin
  Dst.Assign(Src);
  if (Src.Width < 3) or (Src.Height < 3) then
    Exit;
  asm
      pxor      mm0, mm0    // Const 0
      movq      mm2, MMX5DWORD // Factor 5
  end;
  DCP := Dst.PixelPtr[1,1];
  with Src do
  begin
    A2 := PixelPtr[1,0];
    B2 := PixelPtr[1,1];
    C2 := PixelPtr[1,2];
  end;
  for J := 1 to Src.Height - 2 do
  begin
    for I := 1 to Src.Width - 2 do
    begin
      asm
// Matrix = ( 0, -1,  0, -1,  5, -1,  0, -1,  0) {7: HP1}
    // Center first
      mov       eax, DWORD Ptr [B2]
      movd      mm7, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm7, mm0    // B-W low byte == $00
      pmullw    mm7, mm2    // Mult *5

    // Process B Row
      sub       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      psubusw   mm7, mm1    // sub

      add       eax, $08
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      psubusw   mm7, mm1    // sub

    // Process A Row
      mov       eax, DWORD Ptr [A2]
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      psubusw   mm7, mm1    // sub

    // Process C Row
      mov       eax, DWORD Ptr [C2]
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      psubusw   mm7, mm1    // sub

      packuswb  mm7,mm7
      mov       eax, DWORD Ptr [DCP]
      movd      [eax], mm7
      end;
      Inc(DCP);
      Inc(A2);
      Inc(B2);
      Inc(C2);
    end;
    Inc(DCP,2);
    Inc(A2,2);
    Inc(B2,2);
    Inc(C2,2);
  end;
  asm
    EMMS;
  end;
  Dst.Changed;
end;


procedure GaussianBlurEx(Bitmap32: TBitmap32);
var
  Temp: TBitmap32;
begin
  Temp := TBitmap32.Create;
  try
    Temp.Assign(Bitmap32);
    GaussianBlur(Bitmap32, Temp);
  finally
    Temp.Free;
  end;
end;

procedure _GaussianBlur(Dst, Src: TBitmap32);
var
  i, x, y: Integer;
  PixelArray: array[0..8] of PColor32;
  DstPixel: PColor32;
  C, A, R, G, B: Integer;
begin
  Dst.Assign(Src);
  if (Src.Width < 3) or (Src.Height < 3) then
    Exit;
  with Src do
  begin
    PixelArray[0] := PixelPtr[0, 0];
    PixelArray[1] := PixelPtr[1, 0];
    PixelArray[2] := PixelPtr[2, 0];
    PixelArray[3] := PixelPtr[0, 1];
    PixelArray[4] := PixelPtr[1, 1];
    PixelArray[5] := PixelPtr[2, 1];
    PixelArray[6] := PixelPtr[0, 2];
    PixelArray[7] := PixelPtr[1, 2];
    PixelArray[8] := PixelPtr[2, 2];
  end;
  DstPixel := Dst.PixelPtr[1, 1];
  for y := 1 to Src.Height - 2 do
  begin
    for x := 1 to Src.Width - 2 do
    begin
// matrix = ( 1, 2, 1,  2, 4, 2,  1, 2, 1), Normalization = 16
      C := PixelArray[0]^;
      Inc(PixelArray[0]);
      A := ((C and $FF000000) shr 24);
      R := ((C and $00FF0000) shr 16);
      G := ((C and $0000FF00) shr 8);
      B := ( C and $000000FF);
      C := PixelArray[1]^;
      Inc(PixelArray[1]);
      Inc(A, ((C and $FF000000) shr 24) shl 1);
      Inc(R, ((C and $00FF0000) shr 16) shl 1);
      Inc(G, ((C and $0000FF00) shr 8) shl 1);
      Inc(B, ( C and $000000FF) shl 1);
      C := PixelArray[2]^;
      Inc(PixelArray[2]);
      Inc(A, ((C and $FF000000) shr 24));
      Inc(R, ((C and $00FF0000) shr 16));
      Inc(G, ((C and $0000FF00) shr 8));
      Inc(B, ( C and $000000FF));
      C := PixelArray[3]^;
      Inc(PixelArray[3]);
      Inc(A, ((C and $FF000000) shr 24) shl 1);
      Inc(R, ((C and $00FF0000) shr 16) shl 1);
      Inc(G, ((C and $0000FF00) shr 8) shl 1);
      Inc(B, ( C and $000000FF) shl 1);
      C := PixelArray[4]^;
      Inc(PixelArray[4]);
      Inc(A, ((C and $FF000000) shr 24) shl 2);
      Inc(R, ((C and $00FF0000) shr 16) shl 2);
      Inc(G, ((C and $0000FF00) shr 8) shl 2);
      Inc(B, ( C and $000000FF) shl 2);
      C := PixelArray[5]^;
      Inc(PixelArray[5]);
      Inc(A, ((C and $FF000000) shr 24) shl 1);
      Inc(R, ((C and $00FF0000) shr 16) shl 1);
      Inc(G, ((C and $0000FF00) shr 8) shl 1);
      Inc(B, ( C and $000000FF) shl 1);
      C := PixelArray[6]^;
      Inc(PixelArray[6]);
      Inc(A, ((C and $FF000000) shr 24));
      Inc(R, ((C and $00FF0000) shr 16));
      Inc(G, ((C and $0000FF00) shr 8));
      Inc(B, ( C and $000000FF));
      C := PixelArray[7]^;
      Inc(PixelArray[7]);
      Inc(A, ((C and $FF000000) shr 24) shl 1);
      Inc(R, ((C and $00FF0000) shr 16) shl 1);
      Inc(G, ((C and $0000FF00) shr 8) shl 1);
      Inc(B, ( C and $000000FF) shl 1);
      C := PixelArray[8]^;
      Inc(PixelArray[8]);
      Inc(A, ((C and $FF000000) shr 24));
      A := A shr 4;
      if A > 255 then A := 255
      else if A < 0 then A := 0;
      Inc(R, ((C and $00FF0000) shr 16));
      R := R shr 4;
      if R > 255 then R := 255
      else if R < 0 then R := 0;
      Inc(G, ((C and $0000FF00) shr 8));
      G := G shr 4;
      if G > 255 then G := 255
      else if G < 0 then G := 0;
      Inc(B, ( C and $000000FF));
      B := B shr 4;
      if B > 255 then B := 255
      else if B < 0 then B := 0;
      DstPixel^ := (Cardinal(A) shl 24) or (Cardinal(R) shl 16) or (Cardinal(G) shl 8) or Cardinal(B);
      Inc(DstPixel);
    end;
    for i := 0 to 8 do //next line
      Inc(PixelArray[i],2);
    Inc(DstPixel,2);
  end;
end;

procedure M_GaussianBlur(Dst, Src: TBitmap32);
const
  MMX2DWORD : int64 = $0002000200020002;
  MMX4DWORD : int64 = $0004000400040004;
var
  I,J: Integer;
  DCP,A1,B1,C1: PColor32;
begin
  Dst.Assign(Src);
  if (Src.Width < 3) or (Src.Height < 3) then
    Exit;
  asm
      pxor      mm0, mm0    // Const 0
      movq      mm2, MMX2DWORD // Factor 2
      movq      mm4, MMX4DWORD // Factor 4
  end;
  DCP := Dst.PixelPtr[1,1];
  with Src do
  begin
    A1 := PixelPtr[0,0];
    B1 := PixelPtr[0,1];
    C1 := PixelPtr[0,2];
  end;
  for J := 1 to Src.Height - 2 do
  begin
    for I := 1 to Src.Width - 2 do
    begin
      asm
// matrix = ( 1, 2, 1,  2, 4, 2,  1, 2, 1), Normalization = 16
    // Process A Row
      mov       eax, DWORD Ptr [A1]
      movd      mm7, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm7, mm0    // B-W low byte == $00

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      pmullw    mm1, mm2    // Mult *2
      paddsw    mm7, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      paddsw    mm7, mm1    // Add

      // Process B Row
      mov       eax, DWORD Ptr [B1]
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      pmullw    mm1, mm2    // Mult * 2
      paddsw    mm7, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      pmullw    mm1, mm4    // Mult *4
      paddsw    mm7, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      pmullw    mm1, mm2    // Mult * 2
      paddsw    mm7, mm1    // Add

      // Process C Row
      mov       eax, DWORD Ptr [C1]
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      paddsw    mm7, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      pmullw    mm1, mm2    // Mult
      paddsw    mm7, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      paddsw    mm7, mm1    // Add

      psrlw     mm7, 4      // Div 16
      packuswb  mm7,mm7
      mov       eax, DWORD Ptr [DCP]
      movd      [eax], mm7
      end;
      Inc(DCP);
      Inc(A1);
      Inc(B1);
      Inc(C1);
    end;
    Inc(DCP,2);
    Inc(A1,2);
    Inc(B1,2);
    Inc(C1,2);
  end;
  asm
    EMMS;
  end;
  Dst.Changed;
end;


procedure InternalApplyConvolution3x3MMXpower(Dst, Src: TBitmap32; const Kernel: array of Integer;power,bias:integer);
var
  I,J: Integer;
  DCP,A1,B1,C1: PColor32;
  powerQ:Int64;
  mvA1, mvA2, mvA3, mvB1 ,mvB2 ,mvB3, mvC1, mvC2, mvC3: TMMXRegister;
begin
  Dst.Assign(Src);
  if (Src.Width < 3) or (Src.Height < 3) then
    Exit;
  SetMMX_W(mvC3, bias);
  powerQ := power;
  asm
      pxor      mm0, mm0    // Const 0
      movq      mm2, [mvC3] // bias
  end;
  SetMMX_W(mvA1, Kernel[0]);
  SetMMX_W(mvA2, Kernel[1]);
  SetMMX_W(mvA3, Kernel[2]);
  SetMMX_W(mvB1, Kernel[3]);
  SetMMX_W(mvB2, Kernel[4]);
  SetMMX_W(mvB3, Kernel[5]);
  SetMMX_W(mvC1, Kernel[6]);
  SetMMX_W(mvC2, Kernel[7]);
  SetMMX_W(mvC3, Kernel[8]);
  DCP := Dst.PixelPtr[1,1];
  with Src do
  begin
    A1 := PixelPtr[0,0];
    B1 := PixelPtr[0,1];
    C1 := PixelPtr[0,2];
  end;
  for J := 1 to Src.Height - 2 do
  begin
    for I := 1 to Src.Width - 2 do
    begin
      asm
    // Process A Row
      mov       eax, DWORD Ptr [A1]
      movd      mm7, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm7, mm0    // B-W low byte == $00
      pmullw    mm7, [mvA1]    // Mult

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      pmullw    mm1, [mvA2]    // Mult
      paddsw    mm7, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      pmullw    mm1, [mvA3]    // Mult
      paddsw    mm7, mm1    // Add

      // Process B Row
      mov       eax, DWORD Ptr [B1]
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      pmullw    mm1, [mvB1]    // Mult
      paddsw    mm7, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      pmullw    mm1, [mvB2]    // Mult
      paddsw    mm7, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      pmullw    mm1, [mvB3]    // Mult
      paddsw    mm7, mm1    // Add

      // Process C Row
      mov       eax, DWORD Ptr [C1]
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      pmullw    mm1, [mvC1]    // Mult
      paddsw    mm7, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      pmullw    mm1, [mvC2]    // Mult
      paddsw    mm7, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      pmullw    mm1, [mvC3]    // Mult
      paddsw    mm7, mm1    // Add

      psrlw     mm7, QWORD Ptr [powerQ] // Div 2^power
// general division by Normalization number... not applicable with MMX ops... not efficient !
{     push      EBX
      mov       EBX, N
      PEXTRW    EAX, mm7, 3
//      CDQ
      xor  EDX,EDX
      div       EBX
      PINSRW    mm7, EAX, 3
      PEXTRW    EAX, mm7, 2
//      CDQ
      xor  EDX,EDX
      div       EBX
      PINSRW    mm7, EAX, 2
      PEXTRW    EAX, mm7, 1
//      CDQ
      xor  EDX,EDX
      div       EBX
      PINSRW    mm7, EAX, 1
      PEXTRW    EAX, mm7, 0
//      CDQ
      xor  EDX,EDX
      div       EBX
      PINSRW    mm7, EAX, 0
      pop       EBX
}
      paddsw    mm7, mm2    // Add Bias
      packuswb  mm7,mm7
      mov       eax, DWORD Ptr [DCP]
      movd      [eax], mm7
      end;
      Inc(DCP);
      Inc(A1);
      Inc(B1);
      Inc(C1);
    end;
    Inc(DCP,2);
    Inc(A1,2);
    Inc(B1,2);
    Inc(C1,2);
  end;
  asm
    EMMS;
  end;
  Dst.Changed;
end;

procedure InternalApplyConvolution3x3MMXNormal(Dst, Src: TBitmap32; const Kernel: array of Integer);
var
  I,J: Integer;
  DCP,A1,B1,C1: PColor32;
  mvA1, mvA2, mvA3, mvB1 ,mvB2 ,mvB3, mvC1, mvC2, mvC3: TMMXRegister;
begin
  Dst.Assign(Src);
  if (Src.Width < 3) or (Src.Height < 3) then
    Exit;
  asm
      pxor      mm0, mm0    // Const 0
  end;
  SetMMX_W(mvA1, Kernel[0]);
  SetMMX_W(mvA2, Kernel[1]);
  SetMMX_W(mvA3, Kernel[2]);
  SetMMX_W(mvB1, Kernel[3]);
  SetMMX_W(mvB2, Kernel[4]);
  SetMMX_W(mvB3, Kernel[5]);
  SetMMX_W(mvC1, Kernel[6]);
  SetMMX_W(mvC2, Kernel[7]);
  SetMMX_W(mvC3, Kernel[8]);
  DCP := Dst.PixelPtr[1,1];
  with Src do
  begin
    A1 := PixelPtr[0,0];
    B1 := PixelPtr[0,1];
    C1 := PixelPtr[0,2];
  end;
  for J := 1 to Src.Height - 2 do
  begin
    for I := 1 to Src.Width - 2 do
    begin
      asm
    // Process A Row
      mov       eax, DWORD Ptr [A1]
      movd      mm7, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm7, mm0    // B-W low byte == $00
      movq      mm2, [mvA1] // Load Filter mm2
      pmullw    mm7, mm2    // Mult

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      movq      mm2, [mvA2] // Load Filter mm2
      pmullw    mm1, mm2    // Mult
      paddsw    mm7, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      movq      mm2, [mvA3] // Load Filter mm2
      pmullw    mm1, mm2    // Mult
      paddsw    mm7, mm1    // Add

      // Process B Row
      mov       eax, DWORD Ptr [B1]
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      movq      mm2, [mvB1] // Load Filter mm2
      pmullw    mm1, mm2    // Mult
      paddsw    mm7, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      movq      mm2, [mvB2] // Load Filter mm2
      pmullw    mm1, mm2    // Mult
      paddsw    mm7, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      movq      mm2, [mvB3] // Load Filter mm2
      pmullw    mm1, mm2    // Mult
      paddsw    mm7, mm1    // Add

      // Process C Row
      mov       eax, DWORD Ptr [C1]
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      movq      mm2, [mvC1] // Load Filter mm2
      pmullw    mm1, mm2    // Mult
      paddsw    mm7, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      movq      mm2, [mvC2] // Load Filter mm2
      pmullw    mm1, mm2    // Mult
      paddsw    mm7, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      movq      mm2, [mvC3] // Load Filter mm2
      pmullw    mm1, mm2    // Mult
      paddsw    mm7, mm1    // Add

      packuswb  mm7,mm7
      mov       eax, DWORD Ptr [DCP]
      movd      [eax], mm7
      end;
      Inc(DCP);
      Inc(A1);
      Inc(B1);
      Inc(C1);
    end;
    Inc(DCP,2);
    Inc(A1,2);
    Inc(B1,2);
    Inc(C1,2);
  end;
  asm
    EMMS;
  end;
  Dst.Changed;
end;

procedure InternalApplyConvolution3x3PixelPtr(Dst, Src: TBitmap32; const Kernel: array of Integer;bias:integer);
var
  i, x, y: Integer;
  PixelArray: array[0..8] of PColor32;
  DstPixel: PColor32;
  C, A, R, G, B: Integer;
begin
  Dst.Assign(Src);
  if (Src.Width < 3) or (Src.Height < 3) then
    Exit;
  with Src do
  begin
    PixelArray[0] := PixelPtr[0, 0];
    PixelArray[1] := PixelPtr[1, 0];
    PixelArray[2] := PixelPtr[2, 0];
    PixelArray[3] := PixelPtr[0, 1];
    PixelArray[4] := PixelPtr[1, 1];
    PixelArray[5] := PixelPtr[2, 1];
    PixelArray[6] := PixelPtr[0, 2];
    PixelArray[7] := PixelPtr[1, 2];
    PixelArray[8] := PixelPtr[2, 2];
  end;
  DstPixel := Dst.PixelPtr[1, 1];
  for y := 1 to Src.Height - 2 do
  begin
    for x := 1 to Src.Width - 2 do
    begin
      C := PixelArray[0]^;
      Inc(PixelArray[0]);
      A := Integer((C and $FF000000) shr 24) * Kernel[0];
      R := Integer((C and $00FF0000) shr 16) * Kernel[0];
      G := Integer((C and $0000FF00) shr 8) * Kernel[0];
      B := Integer( C and $000000FF) * Kernel[0];
      for i := 1 to 8 do
      begin
        C := PixelArray[i]^;
        Inc(PixelArray[i]);
        Inc(A, Integer((C and $FF000000) shr 24) * Kernel[i]);
        Inc(R, Integer((C and $00FF0000) shr 16) * Kernel[i]);
        Inc(G, Integer((C and $0000FF00) shr 8) * Kernel[i]);
        Inc(B, Integer( C and $000000FF) * Kernel[i]);
      end;
      A := (A div Kernel[9]) + bias;
      R := (R div Kernel[9]) + bias;
      G := (G div Kernel[9]) + bias;
      B := (B div Kernel[9]) + bias;
      if A > 255 then A := 255
      else if A < 0 then A := 0;
      if R > 255 then R := 255
      else if R < 0 then R := 0;
      if G > 255 then G := 255
      else if G < 0 then G := 0;
      if B > 255 then B := 255
      else if B < 0 then B := 0;
      DstPixel^ := (Cardinal(A) shl 24) or (Cardinal(R) shl 16) or (Cardinal(G) shl 8) or Cardinal(B);
      Inc(DstPixel);
    end;
    for i := 0 to 8 do //next line
      Inc(PixelArray[i],2);
    Inc(DstPixel,2);
  end;
end;

procedure InternalApplyConvolution3x3PixelPtrPower(Dst, Src: TBitmap32; const Kernel: array of Integer;power,bias:integer);
var
  i, x, y: Integer;
  PixelArray: array[0..8] of PColor32;
  DstPixel: PColor32;
  C, A, R, G, B: Integer;
begin
  Dst.Assign(Src);
  if (Src.Width < 3) or (Src.Height < 3) then
    Exit;
  with Src do
  begin
    PixelArray[0] := PixelPtr[0, 0];
    PixelArray[1] := PixelPtr[1, 0];
    PixelArray[2] := PixelPtr[2, 0];
    PixelArray[3] := PixelPtr[0, 1];
    PixelArray[4] := PixelPtr[1, 1];
    PixelArray[5] := PixelPtr[2, 1];
    PixelArray[6] := PixelPtr[0, 2];
    PixelArray[7] := PixelPtr[1, 2];
    PixelArray[8] := PixelPtr[2, 2];
  end;
  DstPixel := Dst.PixelPtr[1, 1];
  for y := 1 to Src.Height - 2 do
  begin
    for x := 1 to Src.Width - 2 do
    begin
      C := PixelArray[0]^;
      Inc(PixelArray[0]);
      A := Integer((C and $FF000000) shr 24) * Kernel[0];
      R := Integer((C and $00FF0000) shr 16) * Kernel[0];
      G := Integer((C and $0000FF00) shr 8) * Kernel[0];
      B := Integer( C and $000000FF) * Kernel[0];
      for i := 1 to 8 do
      begin
        C := PixelArray[i]^;
        Inc(PixelArray[i]);
        Inc(A, Integer((C and $FF000000) shr 24) * Kernel[i]);
        Inc(R, Integer((C and $00FF0000) shr 16) * Kernel[i]);
        Inc(G, Integer((C and $0000FF00) shr 8) * Kernel[i]);
        Inc(B, Integer( C and $000000FF) * Kernel[i]);
      end;
      A := (A shr power) + bias;
      R := (R shr power) + bias;
      G := (G shr power) + bias;
      B := (B shr power) + bias;
      if A > 255 then A := 255
      else if A < 0 then A := 0;
      if R > 255 then R := 255
      else if R < 0 then R := 0;
      if G > 255 then G := 255
      else if G < 0 then G := 0;
      if B > 255 then B := 255
      else if B < 0 then B := 0;
      DstPixel^ := (Cardinal(A) shl 24) or (Cardinal(R) shl 16) or (Cardinal(G) shl 8) or Cardinal(B);
      Inc(DstPixel);
    end;
    for i := 0 to 8 do //next line
      Inc(PixelArray[i],2);
    Inc(DstPixel,2);
  end;
end;

procedure InternalApplyConvolution3x3PixelPtrNormal(Dst, Src: TBitmap32; const Kernel: array of Integer);
var
  i, x, y: Integer;
  PixelArray: array[0..8] of PColor32;
  DstPixel: PColor32;
  C, A, R, G, B: Integer;
begin
  Dst.Assign(Src);
  if (Src.Width < 3) or (Src.Height < 3) then
    Exit;
  with Src do
  begin
    PixelArray[0] := PixelPtr[0, 0];
    PixelArray[1] := PixelPtr[1, 0];
    PixelArray[2] := PixelPtr[2, 0];
    PixelArray[3] := PixelPtr[0, 1];
    PixelArray[4] := PixelPtr[1, 1];
    PixelArray[5] := PixelPtr[2, 1];
    PixelArray[6] := PixelPtr[0, 2];
    PixelArray[7] := PixelPtr[1, 2];
    PixelArray[8] := PixelPtr[2, 2];
  end;
  DstPixel := Dst.PixelPtr[1, 1];
  for y := 1 to Src.Height - 2 do
  begin
    for x := 1 to Src.Width - 2 do
    begin
      C := PixelArray[0]^;
      Inc(PixelArray[0]);
      A := Integer((C and $FF000000) shr 24) * Kernel[0];
      R := Integer((C and $00FF0000) shr 16) * Kernel[0];
      G := Integer((C and $0000FF00) shr 8) * Kernel[0];
      B := Integer( C and $000000FF) * Kernel[0];
      for i := 1 to 8 do
      begin
        C := PixelArray[i]^;
        Inc(PixelArray[i]);
        Inc(A, Integer((C and $FF000000) shr 24) * Kernel[i]);
        Inc(R, Integer((C and $00FF0000) shr 16) * Kernel[i]);
        Inc(G, Integer((C and $0000FF00) shr 8) * Kernel[i]);
        Inc(B, Integer( C and $000000FF) * Kernel[i]);
      end;
      if A > 255 then A := 255
      else if A < 0 then A := 0;
      if R > 255 then R := 255
      else if R < 0 then R := 0;
      if G > 255 then G := 255
      else if G < 0 then G := 0;
      if B > 255 then B := 255
      else if B < 0 then B := 0;
      DstPixel^ := (Cardinal(A) shl 24) or (Cardinal(R) shl 16) or (Cardinal(G) shl 8) or Cardinal(B);
      Inc(DstPixel);
    end;
    for i := 0 to 8 do //next line
      Inc(PixelArray[i],2);
    Inc(DstPixel,2);
  end;
end;


procedure InternalApplyConvolution5x5MMXPower(Dst, Src: TBitmap32; const Kernel: array of Integer;power,bias:integer);
var
  I,J: Integer;
  powerQ:Int64;
  DCP,
  A1,  B1,  C1,  D1,  E1: PColor32;
  mvA1,mvA2,mvA3,mvA4,mvA5,
  mvB1,mvB2,mvB3,mvB4,mvB5,
  mvC1,mvC2,mvC3,mvC4,mvC5,
  mvD1,mvD2,mvD3,mvD4,mvD5,
  mvE1,mvE2,mvE3,mvE4,mvE5: TMMXRegister;
begin
  Dst.Assign(Src);
  if (Src.Width < 5) or (Src.Height < 5) then
    Exit;
  powerQ := power;
  SetMMX_W(mvA2, bias);
  asm
      pxor      mm0, mm0    // Const 0
      movq      mm4, [mvA2] // bias
  end;
  SetMMX_W(mvA1, Kernel[0]);
  SetMMX_W(mvA2, Kernel[1]);
  SetMMX_W(mvA3, Kernel[2]);
  SetMMX_W(mvA4, Kernel[3]);
  SetMMX_W(mvA5, Kernel[4]);
  SetMMX_W(mvB1, Kernel[5]);
  SetMMX_W(mvB2, Kernel[6]);
  SetMMX_W(mvB3, Kernel[7]);
  SetMMX_W(mvB4, Kernel[8]);
  SetMMX_W(mvB5, Kernel[9]);
  SetMMX_W(mvC1, Kernel[10]);
  SetMMX_W(mvC2, Kernel[11]);
  SetMMX_W(mvC3, Kernel[12]);
  SetMMX_W(mvC4, Kernel[13]);
  SetMMX_W(mvC5, Kernel[14]);
  SetMMX_W(mvD1, Kernel[15]);
  SetMMX_W(mvD2, Kernel[16]);
  SetMMX_W(mvD3, Kernel[17]);
  SetMMX_W(mvD4, Kernel[18]);
  SetMMX_W(mvD5, Kernel[19]);
  SetMMX_W(mvE1, Kernel[20]);
  SetMMX_W(mvE2, Kernel[21]);
  SetMMX_W(mvE3, Kernel[22]);
  SetMMX_W(mvE4, Kernel[23]);
  SetMMX_W(mvE5, Kernel[24]);
  DCP := Dst.PixelPtr[2,2];
  with Src do
  begin
    A1 := PixelPtr[0,0];
    B1 := PixelPtr[0,1];
    C1 := PixelPtr[0,2];
    D1 := PixelPtr[0,3];
    E1 := PixelPtr[0,4];
  end;
  for J := 2 to Src.Height - 3 do
  begin
    for I := 2 to Src.Width - 3 do
    begin
      asm
   // Process A Row
      mov       eax, DWORD Ptr [A1]
      movd      mm7, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm7, mm0    // B-W low byte == $00
      pmullw    mm7, [mvA1]    // Mult

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      pmullw    mm1, [mvA2]    // Mult
      paddsw    mm7, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      pmullw    mm1, [mvA3]    // Mult
      paddsw    mm7, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      pmullw    mm1, [mvA4]    // Mult
      paddsw    mm7, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      pmullw    mm1, [mvA5]    // Mult
      paddsw    mm7, mm1    // Add
      psrlw     mm7, QWORD Ptr [powerQ] // Div 2^power

    // Process B Row
      mov       eax, DWORD Ptr [B1]
      movd      mm3, DWORD Ptr [eax]   // Load Source mm3
      punpcklbw mm3, mm0    // B-W low byte == $00
      pmullw    mm3, [mvB1]    // Mult

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      pmullw    mm1, [mvB2]    // Mult
      paddsw    mm3, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      pmullw    mm1, [mvB3]    // Mult
      paddsw    mm3, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      pmullw    mm1, [mvB4]    // Mult
      paddsw    mm3, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      pmullw    mm1, [mvB5]    // Mult
      paddsw    mm3, mm1    // Add
      psrlw     mm3, QWORD Ptr [powerQ] // Div 2^power
      paddsw    mm7, mm3    // Add

    // Process C Row
      mov       eax, DWORD Ptr [C1]
      movd      mm3, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm3, mm0    // B-W low byte == $00
      pmullw    mm3, [mvC1]    // Mult

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      pmullw    mm1, [mvC2]    // Mult
      paddsw    mm3, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      pmullw    mm1, [mvC3]    // Mult
      paddsw    mm3, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      pmullw    mm1, [mvC4]    // Mult
      paddsw    mm3, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      pmullw    mm1, [mvC5]    // Mult
      paddsw    mm3, mm1    // Add
      psrlw     mm3, QWORD Ptr [powerQ] // Div 2^power
      paddsw    mm7, mm3    // Add

    // Process D Row
      mov       eax, DWORD Ptr [D1]
      movd      mm3, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm3, mm0    // B-W low byte == $00
      pmullw    mm3, [mvD1]    // Mult

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      pmullw    mm1, [mvD2]    // Mult
      paddsw    mm3, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      pmullw    mm1, [mvD3]    // Mult
      paddsw    mm3, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      pmullw    mm1, [mvD4]    // Mult
      paddsw    mm3, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      pmullw    mm1, [mvD5]    // Mult
      paddsw    mm3, mm1    // Add
      psrlw     mm3, QWORD Ptr [powerQ] // Div 2^power
      paddsw    mm7, mm3    // Add

    // Process E Row
      mov       eax, DWORD Ptr [E1]
      movd      mm3, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm3, mm0    // B-W low byte == $00
      pmullw    mm3, [mvE1]    // Mult

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      pmullw    mm1, [mvE2]    // Mult
      paddsw    mm3, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      pmullw    mm1, [mvE3]    // Mult
      paddsw    mm3, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      pmullw    mm1, [mvE4]    // Mult
      paddsw    mm3, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      pmullw    mm1, [mvE5]    // Mult
      paddsw    mm3, mm1    // Add
      psrlw     mm3, QWORD Ptr [powerQ] // Div 2^power
      paddsw    mm7, mm3    // Add

      paddsw    mm7, mm4    // Add Bias
      packuswb  mm7, mm7
      mov       eax, DWORD Ptr [DCP]
      movd      [eax], mm7
      end;
      Inc(DCP);
      Inc(A1);
      Inc(B1);
      Inc(C1);
      Inc(D1);
      Inc(E1);
    end;
    Inc(DCP,4);
    Inc(A1,4);
    Inc(B1,4);
    Inc(C1,4);
    Inc(D1,4);
    Inc(E1,4);
  end;
  asm
    EMMS;
  end;
  Dst.Changed;
end;

procedure InternalApplyConvolution5x5MMXNormal(Dst, Src: TBitmap32; const Kernel: array of Integer);
{ Warning: this version should not work properlly if one of the factor is too big
  or if the sum goes over the Word size limitation. See the above implementation
  to solve this problem. (this version is nearly 1.5 times faster than the correct one) }
var
  I,J: Integer;
  DCP,  A1,  B1,  C1,  D1,  E1: PColor32;
  mvA1,mvA2,mvA3,mvA4,mvA5,
  mvB1,mvB2,mvB3,mvB4,mvB5,
  mvC1,mvC2,mvC3,mvC4,mvC5,
  mvD1,mvD2,mvD3,mvD4,mvD5,
  mvE1,mvE2,mvE3,mvE4,mvE5: TMMXRegister;
begin
  Dst.Assign(Src);
  if (Src.Width < 5) or (Src.Height < 5) then
    Exit;
  asm
      pxor      mm0, mm0    // Const 0
  end;
  SetMMX_W(mvA1, Kernel[0]);
  SetMMX_W(mvA2, Kernel[1]);
  SetMMX_W(mvA3, Kernel[2]);
  SetMMX_W(mvA4, Kernel[3]);
  SetMMX_W(mvA5, Kernel[4]);
  SetMMX_W(mvB1, Kernel[5]);
  SetMMX_W(mvB2, Kernel[6]);
  SetMMX_W(mvB3, Kernel[7]);
  SetMMX_W(mvB4, Kernel[8]);
  SetMMX_W(mvB5, Kernel[9]);
  SetMMX_W(mvC1, Kernel[10]);
  SetMMX_W(mvC2, Kernel[11]);
  SetMMX_W(mvC3, Kernel[12]);
  SetMMX_W(mvC4, Kernel[13]);
  SetMMX_W(mvC5, Kernel[14]);
  SetMMX_W(mvD1, Kernel[15]);
  SetMMX_W(mvD2, Kernel[16]);
  SetMMX_W(mvD3, Kernel[17]);
  SetMMX_W(mvD4, Kernel[18]);
  SetMMX_W(mvD5, Kernel[19]);
  SetMMX_W(mvE1, Kernel[20]);
  SetMMX_W(mvE2, Kernel[21]);
  SetMMX_W(mvE3, Kernel[22]);
  SetMMX_W(mvE4, Kernel[23]);
  SetMMX_W(mvE5, Kernel[24]);
  DCP := Dst.PixelPtr[2,2];
  with Src do
  begin
    A1 := PixelPtr[0,0];
    B1 := PixelPtr[0,1];
    C1 := PixelPtr[0,2];
    D1 := PixelPtr[0,3];
    E1 := PixelPtr[0,4];
  end;
  for J := 2 to Src.Height - 3 do
  begin
    for I := 2 to Src.Width - 3 do
    begin
      asm
    // Process A Row
      mov       eax, DWORD Ptr [A1]
      movd      mm7, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm7, mm0    // B-W low byte == $00
      movq      mm2, [mvA1] // Load Filter mm2
      pmullw    mm7, mm2    // Mult

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      movq      mm2, [mvA2] // Load Filter mm2
      pmullw    mm1, mm2    // Mult
      paddsw    mm7, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      movq      mm2, [mvA3] // Load Filter mm2
      pmullw    mm1, mm2    // Mult
      paddsw    mm7, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      movq      mm2, [mvA4] // Load Filter mm2
      pmullw    mm1, mm2    // Mult
      paddsw    mm7, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      movq      mm2, [mvA5] // Load Filter mm2
      pmullw    mm1, mm2    // Mult
      paddsw    mm7, mm1    // Add

      // Process B Row
      mov       eax, DWORD Ptr [B1]
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      movq      mm2, [mvB1] // Load Filter mm2
      pmullw    mm1, mm2    // Mult
      paddsw    mm7, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      movq      mm2, [mvB2] // Load Filter mm2
      pmullw    mm1, mm2    // Mult
      paddsw    mm7, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      movq      mm2, [mvB3] // Load Filter mm2
      pmullw    mm1, mm2    // Mult
      paddsw    mm7, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      movq      mm2, [mvB4] // Load Filter mm2
      pmullw    mm1, mm2    // Mult
      paddsw    mm7, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      movq      mm2, [mvB5] // Load Filter mm2
      pmullw    mm1, mm2    // Mult
      paddsw    mm7, mm1    // Add

      // Process C Row
      mov       eax, DWORD Ptr [C1]
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      movq      mm2, [mvC1] // Load Filter mm2
      pmullw    mm1, mm2    // Mult
      paddsw    mm7, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      movq      mm2, [mvC2] // Load Filter mm2
      pmullw    mm1, mm2    // Mult
      paddsw    mm7, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      movq      mm2, [mvC3] // Load Filter mm2
      pmullw    mm1, mm2    // Mult
      paddsw    mm7, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      movq      mm2, [mvC4] // Load Filter mm2
      pmullw    mm1, mm2    // Mult
      paddsw    mm7, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      movq      mm2, [mvC5] // Load Filter mm2
      pmullw    mm1, mm2    // Mult
      paddsw    mm7, mm1    // Add

      // Process D Row
      mov       eax, DWORD Ptr [D1]
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      movq      mm2, [mvD1] // Load Filter mm2
      pmullw    mm1, mm2    // Mult
      paddsw    mm7, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      movq      mm2, [mvD2] // Load Filter mm2
      pmullw    mm1, mm2    // Mult
      paddsw    mm7, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      movq      mm2, [mvD3] // Load Filter mm2
      pmullw    mm1, mm2    // Mult
      paddsw    mm7, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      movq      mm2, [mvD4] // Load Filter mm2
      pmullw    mm1, mm2    // Mult
      paddsw    mm7, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      movq      mm2, [mvD5] // Load Filter mm2
      pmullw    mm1, mm2    // Mult
      paddsw    mm7, mm1    // Add

      // Process C Row
      mov       eax, DWORD Ptr [E1]
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      movq      mm2, [mvE1] // Load Filter mm2
      pmullw    mm1, mm2    // Mult
      paddsw    mm7, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      movq      mm2, [mvE2] // Load Filter mm2
      pmullw    mm1, mm2    // Mult
      paddsw    mm7, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      movq      mm2, [mvE3] // Load Filter mm2
      pmullw    mm1, mm2    // Mult
      paddsw    mm7, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      movq      mm2, [mvE4] // Load Filter mm2
      pmullw    mm1, mm2    // Mult
      paddsw    mm7, mm1    // Add

      add       eax, $04
      movd      mm1, DWORD Ptr [eax]   // Load Source mm1
      punpcklbw mm1, mm0    // B-W low byte == $00
      movq      mm2, [mvE5] // Load Filter mm2
      pmullw    mm1, mm2    // Mult
      paddsw    mm7, mm1    // Add

      packuswb  mm7,mm7
      mov       eax, DWORD Ptr [DCP]
      movd      [eax], mm7
      end;
      Inc(DCP);
      Inc(A1);
      Inc(B1);
      Inc(C1);
      Inc(D1);
      Inc(E1);
    end;
    Inc(DCP,4);
    Inc(A1,4);
    Inc(B1,4);
    Inc(C1,4);
    Inc(D1,4);
    Inc(E1,4);
  end;
  asm
    EMMS;
  end;
  Dst.Changed;
end;

procedure InternalApplyConvolution5x5PixelPtr(Dst, Src: TBitmap32; const Kernel: array of Integer;bias:integer);
var
  i, x, y: Integer;
  PixelArray: array[0..24] of PColor32;
  DstPixel: PColor32;
  C, A, R, G, B: Integer;
begin
  Dst.Assign(Src);
  if (Src.Width < 5) or (Src.Height < 5) then
    Exit;
  with Src do
  begin
    PixelArray[0] := PixelPtr[0, 0];  PixelArray[1] := PixelPtr[1, 0];
    PixelArray[2] := PixelPtr[2, 0];  PixelArray[3] := PixelPtr[3, 0];  PixelArray[4] := PixelPtr[4, 0];
    PixelArray[5] := PixelPtr[0, 1];  PixelArray[6] := PixelPtr[1, 1];
    PixelArray[7] := PixelPtr[2, 1];  PixelArray[8] := PixelPtr[3, 1];  PixelArray[9] := PixelPtr[4, 1];
    PixelArray[10]:= PixelPtr[0, 2]; PixelArray[11] := PixelPtr[1, 2];
    PixelArray[12]:= PixelPtr[2, 2]; PixelArray[13] := PixelPtr[3, 2]; PixelArray[14] := PixelPtr[4,2];
    PixelArray[15]:= PixelPtr[0, 3]; PixelArray[16] := PixelPtr[1, 3];
    PixelArray[17]:= PixelPtr[2, 3]; PixelArray[18] := PixelPtr[3, 3]; PixelArray[19] := PixelPtr[4,3];
    PixelArray[20]:= PixelPtr[0, 4]; PixelArray[21] := PixelPtr[1, 4];
    PixelArray[22]:= PixelPtr[2, 4]; PixelArray[23] := PixelPtr[3, 4]; PixelArray[24] := PixelPtr[4,4];
  end;
  DstPixel := Dst.PixelPtr[2, 2];
  for y := 2 to Src.Height - 3 do
  begin
    for x := 2 to Src.Width - 3 do
    begin
      C := PixelArray[0]^;
      Inc(PixelArray[0]);
      A := Integer((C and $FF000000) shr 24) * Kernel[0];
      R := Integer((C and $00FF0000) shr 16) * Kernel[0];
      G := Integer((C and $0000FF00) shr 8) * Kernel[0];
      B := Integer( C and $000000FF) * Kernel[0];
      for i := 1 to 24 do
      begin
        C := PixelArray[i]^;
        Inc(PixelArray[i]);
        Inc(A, Integer((C and $FF000000) shr 24) * Kernel[i]);
        Inc(R, Integer((C and $00FF0000) shr 16) * Kernel[i]);
        Inc(G, Integer((C and $0000FF00) shr 8) * Kernel[i]);
        Inc(B, Integer( C and $000000FF) * Kernel[i]);
      end;
      A := (A div Kernel[9]) + bias;
      R := (R div Kernel[9]) + bias;
      G := (G div Kernel[9]) + bias;
      B := (B div Kernel[9]) + bias;
      if A > 255 then A := 255
      else if A < 0 then A := 0;
      if R > 255 then R := 255
      else if R < 0 then R := 0;
      if G > 255 then G := 255
      else if G < 0 then G := 0;
      if B > 255 then B := 255
      else if B < 0 then B := 0;
      DstPixel^ := (Cardinal(A) shl 24) or (Cardinal(R) shl 16) or (Cardinal(G) shl 8) or Cardinal(B);
      Inc(DstPixel);
    end;
    for i := 0 to 24 do //next line
      Inc(PixelArray[i],4);
    Inc(DstPixel,4);
  end;
end;

procedure InternalApplyConvolution5x5PixelPtrPower(Dst, Src: TBitmap32; const Kernel: array of Integer;power,bias:integer);
var
  i, x, y: Integer;
  PixelArray: array[0..24] of PColor32;
  DstPixel: PColor32;
  C, A, R, G, B: Integer;
begin
  Dst.Assign(Src);
  if (Src.Width < 5) or (Src.Height < 5) then
    Exit;
  with Src do
  begin
    PixelArray[0] := PixelPtr[0, 0];  PixelArray[1] := PixelPtr[1, 0];
    PixelArray[2] := PixelPtr[2, 0];  PixelArray[3] := PixelPtr[3, 0];  PixelArray[4] := PixelPtr[4, 0];
    PixelArray[5] := PixelPtr[0, 1];  PixelArray[6] := PixelPtr[1, 1];
    PixelArray[7] := PixelPtr[2, 1];  PixelArray[8] := PixelPtr[3, 1];  PixelArray[9] := PixelPtr[4, 1];
    PixelArray[10]:= PixelPtr[0, 2]; PixelArray[11] := PixelPtr[1, 2];
    PixelArray[12]:= PixelPtr[2, 2]; PixelArray[13] := PixelPtr[3, 2]; PixelArray[14] := PixelPtr[4,2];
    PixelArray[15]:= PixelPtr[0, 3]; PixelArray[16] := PixelPtr[1, 3];
    PixelArray[17]:= PixelPtr[2, 3]; PixelArray[18] := PixelPtr[3, 3]; PixelArray[19] := PixelPtr[4,3];
    PixelArray[20]:= PixelPtr[0, 4]; PixelArray[21] := PixelPtr[1, 4];
    PixelArray[22]:= PixelPtr[2, 4]; PixelArray[23] := PixelPtr[3, 4]; PixelArray[24] := PixelPtr[4,4];
  end;
  DstPixel := Dst.PixelPtr[2, 2];
  for y := 2 to Src.Height - 3 do
  begin
    for x := 2 to Src.Width - 3 do
    begin
      C := PixelArray[0]^;
      Inc(PixelArray[0]);
      A := Integer((C and $FF000000) shr 24) * Kernel[0];
      R := Integer((C and $00FF0000) shr 16) * Kernel[0];
      G := Integer((C and $0000FF00) shr 8) * Kernel[0];
      B := Integer( C and $000000FF) * Kernel[0];
      for i := 1 to 24 do
      begin
        C := PixelArray[i]^;
        Inc(PixelArray[i]);
        Inc(A, Integer((C and $FF000000) shr 24) * Kernel[i]);
        Inc(R, Integer((C and $00FF0000) shr 16) * Kernel[i]);
        Inc(G, Integer((C and $0000FF00) shr 8) * Kernel[i]);
        Inc(B, Integer( C and $000000FF) * Kernel[i]);
      end;
      A := (A shr power) + bias;
      R := (R shr power) + bias;
      G := (G shr power) + bias;
      B := (B shr power) + bias;
      if A > 255 then A := 255
      else if A < 0 then A := 0;
      if R > 255 then R := 255
      else if R < 0 then R := 0;
      if G > 255 then G := 255
      else if G < 0 then G := 0;
      if B > 255 then B := 255
      else if B < 0 then B := 0;
      DstPixel^ := (Cardinal(A) shl 24) or (Cardinal(R) shl 16) or (Cardinal(G) shl 8) or Cardinal(B);
      Inc(DstPixel);
    end;
    for i := 0 to 24 do //next line
      Inc(PixelArray[i],4);
    Inc(DstPixel,4);
  end;
end;

procedure InternalApplyConvolution5x5PixelPtrNormal(Dst, Src: TBitmap32; const Kernel: array of Integer);
var
  i, x, y: Integer;
  PixelArray: array[0..24] of PColor32;
  DstPixel: PColor32;
  C, A, R, G, B: Integer;
begin
  Dst.Assign(Src);
  if (Src.Width < 5) or (Src.Height < 5) then
    Exit;
  with Src do
  begin
    PixelArray[0] := PixelPtr[0, 0];  PixelArray[1] := PixelPtr[1, 0];
    PixelArray[2] := PixelPtr[2, 0];  PixelArray[3] := PixelPtr[3, 0];  PixelArray[4] := PixelPtr[4, 0];
    PixelArray[5] := PixelPtr[0, 1];  PixelArray[6] := PixelPtr[1, 1];
    PixelArray[7] := PixelPtr[2, 1];  PixelArray[8] := PixelPtr[3, 1];  PixelArray[9] := PixelPtr[4, 1];
    PixelArray[10]:= PixelPtr[0, 2]; PixelArray[11] := PixelPtr[1, 2];
    PixelArray[12]:= PixelPtr[2, 2]; PixelArray[13] := PixelPtr[3, 2]; PixelArray[14] := PixelPtr[4,2];
    PixelArray[15]:= PixelPtr[0, 3]; PixelArray[16] := PixelPtr[1, 3];
    PixelArray[17]:= PixelPtr[2, 3]; PixelArray[18] := PixelPtr[3, 3]; PixelArray[19] := PixelPtr[4,3];
    PixelArray[20]:= PixelPtr[0, 4]; PixelArray[21] := PixelPtr[1, 4];
    PixelArray[22]:= PixelPtr[2, 4]; PixelArray[23] := PixelPtr[3, 4]; PixelArray[24] := PixelPtr[4,4];
  end;
  DstPixel := Dst.PixelPtr[2, 2];
  for y := 2 to Src.Height - 3 do
  begin
    for x := 2 to Src.Width - 3 do
    begin
      C := PixelArray[0]^;
      Inc(PixelArray[0]);
      A := Integer((C and $FF000000) shr 24) * Kernel[0];
      R := Integer((C and $00FF0000) shr 16) * Kernel[0];
      G := Integer((C and $0000FF00) shr 8) * Kernel[0];
      B := Integer( C and $000000FF) * Kernel[0];
      for i := 1 to 24 do
      begin
        C := PixelArray[i]^;
        Inc(PixelArray[i]);
        Inc(A, Integer((C and $FF000000) shr 24) * Kernel[i]);
        Inc(R, Integer((C and $00FF0000) shr 16) * Kernel[i]);
        Inc(G, Integer((C and $0000FF00) shr 8) * Kernel[i]);
        Inc(B, Integer( C and $000000FF) * Kernel[i]);
      end;
      if A > 255 then A := 255
      else if A < 0 then A := 0;
      if R > 255 then R := 255
      else if R < 0 then R := 0;
      if G > 255 then G := 255
      else if G < 0 then G := 0;
      if B > 255 then B := 255
      else if B < 0 then B := 0;
      DstPixel^ := (Cardinal(A) shl 24) or (Cardinal(R) shl 16) or (Cardinal(G) shl 8) or Cardinal(B);
      Inc(DstPixel);
    end;
    for i := 0 to 24 do //next line
      Inc(PixelArray[i],4);
    Inc(DstPixel,4);
  end;
end;


procedure InternalApplyConvolution7x7PixelPtr(Dst, Src: TBitmap32; const Kernel: array of Integer;bias:integer);
var
  i, x, y: Integer;
  PixelArray: array[0..48] of PColor32;
  DstPixel: PColor32;
  C, A, R, G, B: Integer;
begin
  Dst.Assign(Src);
  if (Src.Width < 7) or (Src.Height < 7) then
    Exit;
    i := 0;
  with Src do
    for y := 0 to 6 do
      for x := 0 to 6 do
      begin
        PixelArray[i] := PixelPtr[x, y];
        inc(i);
      end;
  DstPixel := Dst.PixelPtr[3, 3];
  for y := 3 to Src.Height - 4 do
  begin
    for x := 3 to Src.Width - 4 do
    begin
      C := PixelArray[0]^;
      Inc(PixelArray[0]);
      A := Integer((C and $FF000000) shr 24) * Kernel[0];
      R := Integer((C and $00FF0000) shr 16) * Kernel[0];
      G := Integer((C and $0000FF00) shr 8) * Kernel[0];
      B := Integer( C and $000000FF) * Kernel[0];
      for i := 1 to 48 do
      begin
        C := PixelArray[i]^;
        Inc(PixelArray[i]);
        Inc(A, Integer((C and $FF000000) shr 24) * Kernel[i]);
        Inc(R, Integer((C and $00FF0000) shr 16) * Kernel[i]);
        Inc(G, Integer((C and $0000FF00) shr 8) * Kernel[i]);
        Inc(B, Integer( C and $000000FF) * Kernel[i]);
      end;
      A := (A div Kernel[49]) + bias;
      R := (R div Kernel[49]) + bias;
      G := (G div Kernel[49]) + bias;
      B := (B div Kernel[49]) + bias;
      if A > 255 then A := 255
      else if A < 0 then A := 0;
      if R > 255 then R := 255
      else if R < 0 then R := 0;
      if G > 255 then G := 255
      else if G < 0 then G := 0;
      if B > 255 then B := 255
      else if B < 0 then B := 0;
      DstPixel^ := (Cardinal(A) shl 24) or (Cardinal(R) shl 16) or (Cardinal(G) shl 8) or Cardinal(B);
      Inc(DstPixel);
    end;
    for i := 0 to 48 do //next line
      Inc(PixelArray[i],6);
    Inc(DstPixel,6);
  end;
end;
function _ColorHypot2(C1, C2: TColor32): TColor32;
var
  r1, g1, b1, a1: TColor32;
  r2, g2, b2, a2: TColor32;
begin
  a1 := C1 shr 24;
  r1 := (C1 and $00FF0000) shr 16;
  g1 := (C1 and $0000FF00) shr 8;
  b1 := C1 and $000000FF;

  a2 := C2 shr 24;
  r2 := (C2 and $00FF0000) shr 16;
  g2 := (C2 and $0000FF00) shr 8;
  b2 := C2 and $000000FF;

  a1 := (a2 - a1);
  r1 := (r2 - r1);
  g1 := (g2 - g1);
  b1 := (b2 - b1);

  Result := a1 * a1 + r1 * r1 + g1 * g1 + b1 * b1;
end;


function M_ColorHypot2(C1, C2: TColor32): TColor32;
// 10% faster...
asm
    MOVD      MM0,EAX
    MOVD      MM1,EDX
    MOVQ      MM2,MM0
    PSUBUSB   MM0,MM1
    PSUBUSB   MM1,MM2
    POR       MM0,MM1
    PXOR      MM2,MM2
    PUNPCKLBW MM0,MM2
    PMULLW    MM0,MM0
    PEXTRW    EAX,MM0,3
    PUSH      EDX
    PEXTRW    EDX,MM0,2
    ADD       EAX,EDX
    PEXTRW    EDX,MM0,1
    ADD       EAX,EDX
    PEXTRW    EDX,MM0,0
    ADD       EAX,EDX
    POP       EDX
end;

function _ColorAbsNorm(C1, C2: TColor32): TColor32;
var
  r1, g1, b1, a1: TColor32;
  r2, g2, b2, a2: TColor32;
begin
  a1 := C1 shr 24;
  r1 := (C1 and $00FF0000) shr 16;
  g1 := (C1 and $0000FF00) shr 8;
  b1 := C1 and $000000FF;

  a2 := C2 shr 24;
  r2 := (C2 and $00FF0000) shr 16;
  g2 := (C2 and $0000FF00) shr 8;
  b2 := C2 and $000000FF;

  Result := abs(a2 - a1) + abs(r2 - r1) + abs(g2 - g1) + abs(b2 - b1);
end;


function M_ColorAbsNorm(C1, C2: TColor32): TColor32;
// 4 times faster...
asm
    MOVD      MM0,EAX
    MOVD      MM1,EDX
    PSADBW    MM0,MM1
    MOVD      EAX,MM0
end;

initialization
  if HasMMX then
  begin
    InternalApplyConvolution3x3 := InternalApplyConvolution3x3PixelPtr;
    InternalApplyConvolution5x5 := InternalApplyConvolution5x5PixelPtr;
    InternalApplyConvolution7x7 := InternalApplyConvolution7x7PixelPtr;
    InternalApplyConvolution3x3Power := InternalApplyConvolution3x3MMXPower;
    InternalApplyConvolution5x5Power := InternalApplyConvolution5x5MMXPower;
//    InternalApplyConvolution7x7Power := InternalApplyConvolution7x7MMXPower;
    InternalApplyConvolution3x3Normal := InternalApplyConvolution3x3MMXNormal;
    InternalApplyConvolution5x5Normal := InternalApplyConvolution5x5MMXNormal;
//    InternalApplyConvolution7x7Normal := InternalApplyConvolution7x7MMXNormal;
    ColorHypot2 := M_ColorHypot2;
    ColorAbsNorm := M_ColorAbsNorm;
    GaussianBlur := M_GaussianBlur;
    Sharpness := M_Sharpness;
  end
  else
  begin
    InternalApplyConvolution3x3 := InternalApplyConvolution3x3PixelPtr;
    InternalApplyConvolution5x5 := InternalApplyConvolution5x5PixelPtr;
    InternalApplyConvolution7x7 := InternalApplyConvolution7x7PixelPtr;
    InternalApplyConvolution3x3Power := InternalApplyConvolution3x3PixelPtrPower;
    InternalApplyConvolution5x5Power := InternalApplyConvolution5x5PixelPtrPower;
//    InternalApplyConvolution7x7Power := InternalApplyConvolution7x7PixelPtrPower;
    InternalApplyConvolution3x3Normal := InternalApplyConvolution3x3PixelPtrNormal;
    InternalApplyConvolution5x5Normal := InternalApplyConvolution5x5PixelPtrNormal;
//    InternalApplyConvolution7x7Normal := InternalApplyConvolution7x7PixelPtrNormal;
    ColorHypot2 := _ColorHypot2;
    ColorAbsNorm := _ColorAbsNorm;
    GaussianBlur := _GaussianBlur;
    Sharpness := _Sharpness;
  end;
end.

{ Some Warping Transformations.

  Code converted from :

  Image warping / distortion
    Written by Paul Bourke
        December 2002

  http://astronomy.swin.edu.au/~pbourke/projection/imagewarp
  see this web page for details, C implementation and screenshoot.


  Version 1.2 (19 nov 2005)
  - Cylindrical projections added.

  Version 1.1 (07 nov 2005)
  - TWideLensWarpTransformation was inversed.

  Version 1.0 (01 nov 2005)
  original version.



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
unit GR32_TransformsWarp;

interface

{$I GR32.inc}

uses
  {$IFDEF CLX}
  Qt, Types, {$IFDEF LINUX}Libc, {$ENDIF}
  {$ELSE}
  Windows,
  {$ENDIF}
  SysUtils, Classes, GR32, GR32_Transforms;



type
  { This is an abstract transformation used to apply a transformation in a
    normal system, i.e. the coordinate (X,Y) passed to the ReverseWarp and Warp methods
    varry form -1 to 1 that ever this the bitmap size. To do soo the source rect is
    taken as bounds of the Destination bitmap }
  TCustomWarpTransformation = class(TTransformation)
  private
    CenterX,CenterY:single;
    ScaleX,ScaleY:single;
  protected
    SrcWidth,SrcHeight:single;
   { Convert back the normal coordinate X,Y. (X and Y range is [-1,1]) }
    procedure ReverseWarp(var X, Y: Single); virtual; abstract;
   { Convert the normal coordinate X,Y. (X and Y range is [-1,1]) }
    procedure Warp(var X, Y: Single); virtual; abstract;
    procedure PrepareTransform; override;
    procedure ReverseTransformFloat(DstX, DstY: Single; out SrcX, SrcY: Single); override;
    procedure TransformFloat(SrcX, SrcY: Single; out DstX, DstY: Single); override;
  end;

  TWarpTransformationClass = class of TCustomWarpTransformation;

  { Square root radial function }
  TSqrRadialWarpTransformation = class(TCustomWarpTransformation)
  protected
    procedure ReverseWarp(var X, Y: Single); override;
    procedure Warp(var X, Y: Single); override;
  end;

  { arcsin radial function }
  TInvSinRadialWarpTransformation = class(TCustomWarpTransformation)
  protected
    procedure ReverseWarp(var X, Y: Single); override;
    procedure Warp(var X, Y: Single); override;
  end;

  { sin radial function }
  TSinRadialWarpTransformation = class(TCustomWarpTransformation)
  protected
    procedure ReverseWarp(var X, Y: Single); override;
    procedure Warp(var X, Y: Single); override;
  end;

  { radial to a power function }
  TPowerWarpTransformation = class(TCustomWarpTransformation)
  private
    FPower: Single;
    procedure SetPower(const Value: Single);
  protected
    procedure ReverseWarp(var X, Y: Single); override;
    procedure Warp(var X, Y: Single); override;
  public
    constructor Create; virtual;
  published
    property PowerCoef:Single read FPower write SetPower;
  end;

  { sin function cartesian function }
  TSinWarpTransformation = class(TCustomWarpTransformation)
  protected
    procedure ReverseWarp(var X, Y: Single); override;
    procedure Warp(var X, Y: Single); override;
  end;

  { Square cartesian function
    Includes quadrant preserving }
  TSquareWarpTransformation = class(TCustomWarpTransformation)
  protected
    procedure ReverseWarp(var X, Y: Single); override;
    procedure Warp(var X, Y: Single); override;
  end;

  { arc sine cartesian function }
  TInvSinCartesianWarpTransformation = class(TCustomWarpTransformation)
  protected
    procedure ReverseWarp(var X, Y: Single); override;
    procedure Warp(var X, Y: Single); override;
  end;

  { (1-ar^2) cartesian function }
  TRadialSquareWarpTransformation = class(TCustomWarpTransformation)
  private
    FParam,FParam1,FParam2:Single;
    procedure SetParam(const Value: Single);
  protected
    procedure ReverseWarp(var X, Y: Single); override;
    procedure Warp(var X, Y: Single); override;
    procedure PrepareTransform; override;
  published
    property Param:Single read FParam write SetParam;
  end;

  { Method by H. Farid and A.C. Popescu
    Used for modest lens with good fit }
  TModestLensWarpTransformation = class(TCustomWarpTransformation)
  private
    FParam:Single;
    procedure SetParam(const Value: Single);
  protected
    procedure ReverseWarp(var X, Y: Single); override;
    procedure Warp(var X, Y: Single); override;
  published
    property Param:Single read FParam write SetParam;
  end;

  { Logarithmic relationship
    eg: fitted to test pattern with 2 parameters }
  TLogWarpTransformation = class(TCustomWarpTransformation)
  private
    FParam: Single;
    FPowerCoef: Single;
    procedure SetParam(const Value: Single);
    procedure SetPowerCoef(const Value: Single);
  protected
    procedure ReverseWarp(var X, Y: Single); override;
    procedure Warp(var X, Y: Single); override;
  public
    constructor Create; virtual;
  published
    property Param:Single read FParam write SetParam;
    property PowerCoef:Single read FPowerCoef write SetPowerCoef;
  end;

  { General third order polynomial
    eg: fitted to test pattern with 3 parameters }
  TPoly3WarpTransformation = class(TCustomWarpTransformation)
  private
    FCoef3Order: Single;
    FCoef1Order: Single;
    FCoef2Order: Single;
    procedure SetCoef1Order(const Value: Single);
    procedure SetCoef2Order(const Value: Single);
    procedure SetCoef3Order(const Value: Single);
  protected
    procedure ReverseWarp(var X, Y: Single); override;
    procedure Warp(var X, Y: Single); override;
  public
    constructor Create; virtual;
  published
    property Coef1Order:Single read FCoef1Order write SetCoef1Order;
    property Coef2Order:Single read FCoef2Order write SetCoef2Order;
    property Coef3Order:Single read FCoef3Order write SetCoef3Order;
  end;

  { Janez Pers, Stanislav Kovacic
    Alternative Model of Radial Distortion in Wide-Angle Lenses
    Single parameter model }
  TWideLensWarpTransformation = class(TCustomWarpTransformation)
  private
    FParam: Single;
    FParam1: Single;
    FParam2: Single;
    procedure SetParam(const Value: Single);
  protected
    procedure PrepareTransform; override;
    procedure ReverseWarp(var X, Y: Single); override;
    procedure Warp(var X, Y: Single); override;
  public
    constructor Create; virtual;
  published
    property Param:Single read FParam write SetParam;
  end;

  TCylindricalHWarpTransformation = class(TCustomWarpTransformation)
  private
    FFocal: Single;
    procedure SetFocal(const Value: Single);
  protected
    procedure ReverseWarp(var X, Y: Single); override;
  public
    constructor Create; virtual;
  published
    property Focal:Single read FFocal write SetFocal;
  end;

  TCylindricalVWarpTransformation = class(TCustomWarpTransformation)
  private
    FFocal: Single;
    procedure SetFocal(const Value: Single);
  protected
    procedure ReverseWarp(var X, Y: Single); override;
  public
    constructor Create; virtual;
  published
    property Focal:Single read FFocal write SetFocal;
  end;

implementation

uses
  GR32_Math,GR32_MathAddons;

{ TCustomWarpTransformation }

procedure TCustomWarpTransformation.PrepareTransform;
begin
  with SrcRect do
  begin
    CenterX := (Left + Right) / 2;
    CenterY := (Top + Bottom) / 2;
    SrcWidth := (Right - Left) / 2;
    SrcHeight := (Bottom - Top) / 2;
    ScaleX := 1 / SrcWidth;
    ScaleY := 1 / SrcHeight;
  end;
  TransformValid := true;
end;

procedure TCustomWarpTransformation.ReverseTransformFloat(DstX,DstY: Single; out SrcX, SrcY: Single);
begin
  // Change coordinates in an normal system: x and y range [-1,1]
  DstX := (DstX - CenterX) * ScaleX;
  DstY := (DstY - CenterY) * ScaleY;
  ReverseWarp(DstX,DstY);
  SrcX := CenterX + SrcWidth * DstX;
  SrcY := CenterY + SrcHeight * DstY;
end;

procedure TCustomWarpTransformation.TransformFloat(SrcX, SrcY: Single;out DstX, DstY: Single);
begin
  // Change coordinates in an normal system: x and y range [-1,1]
  SrcX := (SrcX - CenterX) * ScaleX;
  SrcY := (SrcY - CenterY) * ScaleY;
  Warp(SrcX,SrcY);
  DstX := CenterX + SrcWidth * SrcX;
  DstY := CenterY + SrcHeight * SrcY;
end;

{ TSqrRadialWarpTransformation }

procedure TSqrRadialWarpTransformation.ReverseWarp(var X, Y: Single);
begin
  CartesianToPolar(X,Y,X,Y);
  X := Sqrt(X);
  PolarToCartesian(X,Y,X,Y);
end;

procedure TSqrRadialWarpTransformation.Warp(var X, Y: Single);
begin
  CartesianToPolar(X,Y,X,Y);
  X := X*X; // To Test !?!?
  PolarToCartesian(X,Y,X,Y);
end;

{ TArcSinRadialWarpTransformation }

procedure TInvSinRadialWarpTransformation.ReverseWarp(var X, Y: Single);
begin
  CartesianToPolar(X,Y,X,Y);
  if (X >= -1) and (X <= 1) then
    X := ArcSin(X) * InvHalfPIS;
  PolarToCartesian(X,Y,X,Y);
end;

procedure TInvSinRadialWarpTransformation.Warp(var X, Y: Single);
begin
  CartesianToPolar(X,Y,X,Y);
  X := Sin(X * HalfPIS);
  PolarToCartesian(X,Y,X,Y);
end;

{ TSinRadialWarpTransformation }

procedure TSinRadialWarpTransformation.ReverseWarp(var X, Y: Single);
begin
  CartesianToPolar(X,Y,X,Y);
  X := Sin(X * HalfPIS);
  PolarToCartesian(X,Y,X,Y);
end;

procedure TSinRadialWarpTransformation.Warp(var X, Y: Single);
begin
  CartesianToPolar(X,Y,X,Y);
  if (X >= -1) and (X <= 1) then
    X := ArcSin(X) * InvHalfPIS;
  PolarToCartesian(X,Y,X,Y);
end;

{ TPowerWarpTransformation }

constructor TPowerWarpTransformation.Create;
begin
  inherited Create;
  FPower := 1.5;
end;

procedure TPowerWarpTransformation.ReverseWarp(var X, Y: Single);
begin
  CartesianToPolar(X,Y,X,Y);
  X := Power(X,FPower);
  PolarToCartesian(X,Y,X,Y);
end;

procedure TPowerWarpTransformation.SetPower(const Value: Single);
begin
  if (FPower <> Value) and (Value <> 0) then
  begin
    FPower := Value;
  end;
end;

procedure TPowerWarpTransformation.Warp(var X, Y: Single);
begin
  CartesianToPolar(X,Y,X,Y);
  X := Power(X,-FPower);
  PolarToCartesian(X,Y,X,Y);
end;

{ TSinWarpTransformation }

procedure TSinWarpTransformation.ReverseWarp(var X, Y: Single);
begin
  X := sin(HalfPIS * X);
  Y := sin(HalfPIS * Y);
end;

procedure TSinWarpTransformation.Warp(var X, Y: Single);
begin
  X := ArcSin(InvHalfPIS * X);
  Y := ArcSin(InvHalfPIS * Y);
end;

{ TSquareWarpTransformation }

procedure TSquareWarpTransformation.ReverseWarp(var X, Y: Single);
begin
  X := X * X * sign(X);
  Y := Y * Y * sign(Y);
end;

procedure TSquareWarpTransformation.Warp(var X, Y: Single);
begin
  X := sqrt(X) * sign(X);
  Y := sqrt(Y) * sign(Y);
end;

{ TInvSinCartesianWarpTransformation }

procedure TInvSinCartesianWarpTransformation.ReverseWarp(var X, Y: Single);
begin
  X := ArcSin(X) * InvHalfPIS;
  Y := ArcSin(Y) * InvHalfPIS;
end;

procedure TInvSinCartesianWarpTransformation.Warp(var X, Y: Single);
begin
  X := Sin(X * HalfPIS);
  Y := Sin(Y * HalfPIS);
end;

{ TRadialSquareWarpTransformation }

procedure TRadialSquareWarpTransformation.PrepareTransform;
begin
  FParam1 := 1 / (1 - FParam);
  FParam2 := - FParam / (1 - FParam);
  inherited;
end;

procedure TRadialSquareWarpTransformation.ReverseWarp(var X, Y: Single);
var
  z:single;
begin
  z := FParam1 + (FParam2 * (X*X + Y*Y));
  X := X * z;
  Y := Y * z;
end;

procedure TRadialSquareWarpTransformation.SetParam(const Value: Single);
begin
  if (FParam <> Value) and (Value <> 1) then
  begin
    FParam := Value;
    TransformValid := False;
  end;
end;

procedure TRadialSquareWarpTransformation.Warp(var X, Y: Single);
begin
// Not Implemented...
end;

{ TModestLensWarpTransformation }

procedure TModestLensWarpTransformation.ReverseWarp(var X, Y: Single);
var
  Denom,xtmp,ytmp:Single;
begin
  Denom := 1 - FParam * (X*X + Y*Y);
  xtmp := X / Denom;
  ytmp := Y / Denom;
  if (xtmp <= -1) or (xtmp >= 1) or (ytmp <= -1) or (ytmp >= 1) then
  begin
    X := -1;
    Y := -1;
    Exit;
  end;
  Denom := 1 - Denom * (xtmp*xtmp + ytmp*ytmp);
  if abs(Denom) < 0.000001 then
  begin
    X := -1;
    Y := -1;
    Exit;
  end;
  X := X / Denom;
  Y := Y / Denom;
end;

procedure TModestLensWarpTransformation.SetParam(const Value: Single);
begin
  if (FParam <> Value) and (abs(Value) < 1) then
  begin
    FParam := Value;
  end;
end;

procedure TModestLensWarpTransformation.Warp(var X, Y: Single);
begin
// Not Implemented
end;

{ TLogWarpTransformation }

constructor TLogWarpTransformation.Create;
begin
  inherited Create;
  FParam := 0.05;
  FPowerCoef := 1.25;
end;

procedure TLogWarpTransformation.ReverseWarp(var X, Y: Single);
begin
  CartesianToPolar(X,Y,X,Y);
  X := FParam * power(10.0,FPowerCoef * X) - FParam;
  PolarToCartesian(X,Y,X,Y);
end;

procedure TLogWarpTransformation.SetParam(const Value: Single);
begin
  if (FParam <> Value) and (Value <> 0) then
  begin
    FParam := Value;
  end;
end;

procedure TLogWarpTransformation.SetPowerCoef(const Value: Single);
begin
  if (FPowerCoef <> Value) and (Value <> 0) then
  begin
    FPowerCoef := Value;
  end;
end;

procedure TLogWarpTransformation.Warp(var X, Y: Single);
begin
// Not Implemented
end;

{ TPoly3WarpTransformation }

constructor TPoly3WarpTransformation.Create;
begin
  inherited Create;
  FCoef3Order := 1;
  FCoef1Order := 1;
  FCoef2Order := 1;
end;

procedure TPoly3WarpTransformation.ReverseWarp(var X, Y: Single);
var
  r2:single;
begin
  r2 := X*X + Y*Y;
  Y := ArcTan2(Y,X);
  X := sqrt(r2);
  PolarToCartesian(FCoef3Order * r2 * X + FCoef2Order * r2 + FCoef1Order * X, Y, X, Y);
end;

procedure TPoly3WarpTransformation.SetCoef1Order(const Value: Single);
begin
  FCoef1Order := Value;
end;

procedure TPoly3WarpTransformation.SetCoef2Order(const Value: Single);
begin
  FCoef2Order := Value;
end;

procedure TPoly3WarpTransformation.SetCoef3Order(const Value: Single);
begin
  FCoef3Order := Value;
end;

procedure TPoly3WarpTransformation.Warp(var X, Y: Single);
begin
// Not implemented
end;

{ TWideLensWarpTransformation }

constructor TWideLensWarpTransformation.Create;
begin
  inherited Create;
  FParam := 0.3;
end;

procedure TWideLensWarpTransformation.PrepareTransform;
begin
  FParam1 := 0.5 * FParam;
  FParam2 :=  1 / FParam;
  inherited;
end;

procedure TWideLensWarpTransformation.ReverseWarp(var X, Y: Single);
{ ...simplification...
  r = -0.5*p*(exp(-2*r/p)-1) / exp(-r/p)
  r = -0.5*p*(exp(-2*r/p)-1) * exp(r/p)
  r = -0.5*p*[ (exp(-2*r/p) * exp(r/p) - exp(r/p) ]
  r = -0.5*p*[ exp(-2*r/p + r/p) - exp(r/p) ]
  r = -0.5*p*[ exp(-r/p) - exp(r/p) ]
  r = -0.5*p*[ 1/exp(r/p) - exp(r/p) ]
  r =  0.5*p*[ exp(r/p) - 1/exp(r/p) ]
}
begin
  CartesianToPolar(X,Y,X,Y);
  X := exp(X * FParam2);
  X := FParam1 * (X - (1 / X));
  PolarToCartesian(X,Y,X,Y);
end;

procedure TWideLensWarpTransformation.SetParam(const Value: Single);
begin
  if (FParam <> Value) and (abs(Value) > 0.000001) then
  begin
    FParam := Value;
    TransformValid := False;
  end;
end;

procedure TWideLensWarpTransformation.Warp(var X, Y: Single);
begin
// Not Implemented
end;

{ TCylindricalHWarpTransformation }

constructor TCylindricalHWarpTransformation.Create;
begin
  inherited Create;
  FFocal := 1;
end;

procedure TCylindricalHWarpTransformation.ReverseWarp(var X, Y: Single);
var
  sY,cY:Single;
begin
  SinCos(Y*HalfPIS,sY,cY);
  if cY <> 0 then
  begin
    Y := -X / cY;
    X := -FFocal * sY / cY;
  end;
end;

procedure TCylindricalHWarpTransformation.SetFocal(const Value: Single);
begin
  if (FFocal <> Value) and (Value <> 0) then
  begin
    FFocal := Value;
  end;
end;

{ TCylindricalVWarpTransformation }

constructor TCylindricalVWarpTransformation.Create;
begin
  inherited Create;
  FFocal := 1;
end;

procedure TCylindricalVWarpTransformation.ReverseWarp(var X, Y: Single);
var
  sX,cX:Single;
begin
  SinCos(X*HalfPIS,sX,cX);
  if cX <> 0 then
  begin
    X := -Y / cX;
    Y := -FFocal * sX / cX;
  end;
end;

procedure TCylindricalVWarpTransformation.SetFocal(const Value: Single);
begin
  if (FFocal <> Value) and (Value <> 0) then
  begin
    FFocal := Value;
  end;
end;

end.

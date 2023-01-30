unit GR32_TransformsEx;

{ Implement some specifics Transformations

  Contributors:
  Marc LAFON (marc.lafon AT free.fr)

  Version 0.1 (01 nov 2005)
  - TSphereTransformation : spherical projection




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
  Windows, SysUtils, Classes,
  GR32, GR32_Blend, GR32_VectorMaps, GR32_Rasterizers, GR32_Transforms;

type
  { Transform a map (planisphere) into a Spherical projection. }
  TSphereTransformation = class(TTransformation)
  private
    FMapWidth,FMapHeight: Single;
    FSquareRay: Single;
    FCenterY: Single;
    FCenterX: Single;
    FRay: Single;
    FLongitude: Single;
    FLattitude: Single;
    FLattitudeSin,FLattitudeCos: Single;
    FLattitudeSinInvRay,FLattitudeCosInvRay: Single;
    FSrcRectTop,FSrcRectLeft:Single;
    procedure SetCenterX(const Value: Single);
    procedure SetCenterY(const Value: Single);
    procedure SetLattitude(const Value: Single);
    procedure SetLongitude(const Value: Single);
    procedure SetRay(const Value: Single);
  protected
    procedure PrepareTransform; override;
    procedure ReverseTransformFloat(DstX, DstY: Single; out SrcX, SrcY: Single); override;
  public
    constructor Create; virtual;
    function GetTransformedBounds(const ASrcRect: TFloatRect): TRect; overload; override;
   { Return True if the (X,Y) point is in the Sphere projection }
    function IsInSphere(CartesianX,CartesianY:Single):boolean;
   { Transform (X,Y) coordinate as Lattitude and Longitude coordinates in the Sphere }
    function SphericalCoordinate(CartesianX,CartesianY:Single):TFloatPoint;
   { Transform Longitude and Lattitude coordinates (X,Y) into their screen projection.
     return false il this point is on visible face. }
    function ScreenCoordinate(var X,Y:Single):boolean;
   { Change the Source Size }
    procedure SetSourceSize(width,height:single);
  published
   { X coordinate Center of the Sphere in the Destination Bitmap }
    property CenterX:Single read FCenterX write SetCenterX;
   { Y coordinate Center of the Sphere in the Destination Bitmap }
    property CenterY:Single read FCenterY write SetCenterY;
   { Ray of the Sphere in the Destination Bitmap }
    property Ray:Single read FRay write SetRay;
   { Rotation of the Sphere (Y axe rotation angle) }
    property Lattitude:Single read FLattitude write SetLattitude;
   { Rotation of the Sphere (X axe rotation angle) }
    property Longitude:Single read FLongitude write SetLongitude;
  end;


implementation

uses GR32_Math,GR32_MathAddons;

{ TSphereTransformation }
constructor TSphereTransformation.Create;
begin
  inherited;
  FCenterY := 0;
  FCenterX := 0;
  FRay := 1;
  FLongitude := 0;
  FLattitude := 0;
end;

function TSphereTransformation.GetTransformedBounds(const ASrcRect: TFloatRect): TRect;
begin
  { There is not direct relation between sourceRect and DestRect !
    During transformation process this TRect will be clipped. }
  with Result do
  begin
    Left := Round(FCenterX - FRay);
    Top := Round(FCenterY - FRay);
    Bottom := Round(FCenterY + FRay);
    Right := Round(FCenterX + FRay);
  end;
end;

function TSphereTransformation.IsInSphere(CartesianX, CartesianY: Single): boolean;
begin
  if not TransformValid then
    PrepareTransform;
  CartesianX := CartesianX - FCenterX;
  CartesianY := CartesianY - FCenterY;
  Result := FSquareRay >= (CartesianX * CartesianX + CartesianY * CartesianY);
end;

procedure TSphereTransformation.PrepareTransform;
begin
  { invariants during transformation }
  with SrcRect do
  begin
    FMapWidth := (Right - Left -1) / (2 * PI);
    FMapHeight := (Bottom - Top -1) / PI;
  end;
  FSquareRay := FRay * FRay;
  Modulo2PI(FLongitude);
  SinCos(FLattitude,FLattitudeSin,FLattitudeCos);
  FLattitudeSinInvRay := -FLattitudeSin / FRay;
  FLattitudeCosInvRay := FLattitudeCos / FRay;
  FSrcRectTop := SrcRect.Top;
  FSrcRectLeft := SrcRect.Left;
  TransformValid := True; // !!! The transformation is now valid
end;

procedure TSphereTransformation.ReverseTransformFloat(DstX, DstY: Single;
  out SrcX, SrcY: Single);
{var
  x:Single;
begin
// screen projection on sphere
  DstX := DstX - FCenterX; // = Y
  DstY := FCenterY - DstY; // = Z
  x := DstX * DstX + DstY * DstY;
  if (FSquareRay < x) then // not projetable in the sphere.
  begin
    SrcX := -1;
    SrcY := -1;
    Exit;
  end;
  x := sqrt(FSquareRay - x);
// apply rotations
  DstX := Arctan2(DstX,x * FLattitudeCos + DstY * FLattitudeSin) + FLongitude; // Lon
  if DstX > PI2S then
    DstX := DstX - PI2S
  else if DstX < 0 then
    DstX := DstX + PI2S;
//  DstY := ArcCos(DstY * FLattitudeCosInvRay - x * FLattitudeSinInvRay);
// Map projection
  SrcX := DstX * FMapWidth + SrcRect.Left;// TODO Ajouter le bord du SrcRect !!!
  SrcY := ArcCos(DstY * FLattitudeCosInvRay + x * FLattitudeSinInvRay) * FMapHeight + SrcRect.top;// TODO Ajouter le bord du SrcRect !!!
end;
{}{Assembler version (FPU) ... 4% faster on a P4 }
asm
// screen projection on sphere
//  DstX := DstX - FCenterX; // = Y
    fld   DstX               // DstX
    fsub  [eax].FCenterX // DstX'
//  DstY := FCenterY - DstY; // = Z
    fld   [eax].FCenterY // FCenterY | DstX'
    fsub  DstY               // DstY'    | DstX'
//  x := DstX * DstX + DstY * DstY;
    fld   st(0)                    // Z    | Z    | Y
    fmul  st(0),st(1)              // ZZ   | Z    | Y
    fld   st(2)                    // Y    | ZZ   | Z   | Y
    fmul  st(0),st(3)
    faddp                          // X'   | Z    | Y
//  if (FSquareRay < x) then // not projetable in the sphere.
    fld [eax].FSquareRay
    fcomi st(0),st(1) // st(0) < st(1)
    jnbe   @@1
    fstp  st(0)
    fstp  st(0)
    fstp  st(0)
    fstp  st(0)
//    SrcX := -1;
    mov   [SrcX],$bf800000
//    SrcY := -1;
    mov   [SrcY],$bf800000
//    Exit;
    jmp @@fin
@@1:
//  x := sqrt(FSquareRay - x);
    fsubrp
    fsqrt                          // X    | Z    | Y
// apply rotations
//  DstX := Arctan2(Y,X * FLattitudeCos + Z * FLattitudeSin) + FLongitude; // Lon
    fxch  st(2)                   // Y     | Z    | Y
    fld   st(2)                   // X     | Y    | Z    | X
    fmul  [eax].FLattitudeCos
    fld   st(2)                   // Z     | Xx.  | Y    | Z    | X
    fmul  [eax].FLattitudeSin     // Zx.   | Xx.  | Y    | Z    | X
    faddp                         // Xx+Zx | Y    | Z    | X
    fpatan
    fadd  [eax].FLongitude  // DstX  | Z    | X
//  if DstX > PI2S then
    fldpi
    fadd  st(0),st(0)       // 2PI   | DstX | Z    | X
    fcomi st(0),st(1) // st(0) < st(1)
    jnb   @@test2
//    DstX := DstX - PI2S
    fsubp st(1),st(0)
    jmp   @@testfin
//  else if DstX < 0 then
@@test2:
    fldz
    fcomip st(0),st(2) // st(0) < st(2)
    jb @@test3
//    DstX := DstX + PI2S;
    faddp
    jmp   @@testfin
@@test3:
    fstp  st(0)
@@testfin:
// Map projection
//  SrcX := DstX * FMapWidth;
    fmul  [eax].FMapWidth
    FADD  [eax].FSrcRectLeft
    fstp  dword ptr [SrcX]// Z    | X
//  SrcY := ArcCos(Z * FLattitudeCosInvRay + x * FLattitudeSinInvRay) * FMapHeight;
    fmul  [eax].FLattitudeCosInvRay
    fxch
    fmul  [eax].FLattitudeSinInvRay
    faddp
    FLD1                 // 1      | X
    FLD   ST(1)          // X      | 1      | X
    FMUL  ST(0),ST(0)    // X²     | 1      | X
    FSUBP ST(1),ST(0)    // 1 - X² | X
    FABS                 //<- avoid rounding errors...
    FSQRT                // sqrt(.)| X
    FXCH  st(1)
    FPATAN               // result |
    fmul  [eax].FMapHeight
    FADD  [eax].FSrcRectTop
    fstp  dword ptr [SrcY]
@@fin:
    fwait
end;{}

function TSphereTransformation.ScreenCoordinate(var X, Y: Single): boolean;
var
  sinLon,cosLon,sinlat,cosLat:Single;
begin
  if not TransformValid then
    PrepareTransform;
  sincos(X-FLongitude,sinLon,cosLon);
  sincos(Y,sinLat,cosLat);
  Result := sinLat * cosLon * FLattitudeCos >= cosLat * FLattitudeSin;
  if Result then
  begin
    X := Fray * sinLat * sinLon + FCenterX;
    Y := FCenterY - FRay * (sinLat * cosLon * FLattitudeSin + cosLat * FLattitudeCos);
  end;
end;

procedure TSphereTransformation.SetCenterX(const Value: Single);
begin
  if FCenterX <> Value then
  begin
    FCenterX := Value;
    TransformValid := False;
  end;
end;

procedure TSphereTransformation.SetCenterY(const Value: Single);
begin
  if FCenterY <> Value then
  begin
    FCenterY := Value;
    TransformValid := False;
  end;
end;

procedure TSphereTransformation.SetLattitude(const Value: Single);
begin
  if FLattitude <> Value then
  begin
    FLattitude := Value;
    TransformValid := False;
  end;
end;

procedure TSphereTransformation.SetLongitude(const Value: Single);
begin
  if FLongitude <> Value then
  begin
    FLongitude := Value;
    TransformValid := False;
  end;
end;

procedure TSphereTransformation.SetRay(const Value: Single);
begin
  if (Value > 0) and (FRay <> Value) then
  begin
    FRay := Value;
    TransformValid := False;
  end;
end;

procedure TSphereTransformation.SetSourceSize(width, height: single);
begin
  with SrcRect do
  begin
    Left := 0;
    Top := 0;
    Right := Width;
    Bottom := Height;
  end;
  TransformValid := False;
end;

function TSphereTransformation.SphericalCoordinate(CartesianX,CartesianY: Single): TFloatPoint;
var
  x:Single;
begin
  if not TransformValid then
    PrepareTransform;
// screen projection on sphere
  CartesianX := CartesianX - FCenterX; // = Y
  CartesianY := FCenterY - CartesianY; // = Z
  x := CartesianX * CartesianX + CartesianY * CartesianY;
  if (FSquareRay < x) then // not projetable in the sphere.
  begin
    Result.X := 0;
    Result.Y := 0;
    Exit;
  end;
  x := sqrt(FSquareRay - x);
// apply rotations
  Result.X := Arctan2(CartesianX,x * FLattitudeCos + CartesianY * FLattitudeSin) + FLongitude; // Lon
  if Result.X > PI2S then
    Result.X := Result.X - PI2S
  else if Result.X < 0 then
    Result.X := Result.X + PI2S;
  Result.Y := ArcCos(CartesianY * FLattitudeCosInvRay + x * FLattitudeSinInvRay) - HalfPIS;
end;

end.

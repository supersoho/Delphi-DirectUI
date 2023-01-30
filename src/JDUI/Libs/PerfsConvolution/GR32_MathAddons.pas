unit GR32_MathAddons;
{
 Single Arithmetic optimized functions.

 Most of theses function come from Math.pas and are just aligned with Singles
 parameters. Theses kind of simples operations can give a non negligeable
 perfomance gain (approx. 20%).

Version 1.2 (19 nov 2005) Contributor Marc LAFON.
 - maxBitSet and minBitSet functions added

Version 1.1 (09 oct 2005)
 - Sign added
 - ArcCos added
 - Min added
 - Convex added

Version 1.0 (08 oct 2005)
 - some part of this code come from the Fast Code Project
   http://www.fastcodeproject.org/


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
  Windows, Messages, SysUtils, Classes, Graphics,
  GR32;

const
{ PI constants }
  HalfPIS : Single = 1.5707963267948966192313216916398;     // = PI/2
  PIS : Single = 3.1415926535897932384626433832795;         //
  PI2S : Single = 6.283185307179586476925286766559;         // = 2 * PI
  InvPIS : Single = 0.31830988618379067153776752674503;     // = 1 / PI
  Inv2PIS : Single = 0.15915494309189533576888376337251;    // = 1 / 2PI
  InvSqrPIS : Single = 0.10132118364233777144387946320973;  // = 1 / PI²
  InvHalfPIS : Single = 0.63661977236758134307553505349006;     // = PI/2



{ Trigonomic functions }


function Tan(const X: Single): Single;
function Cotan(const X: Single): Single;           { 1 / tan(X), X <> 0 }
function Secant(const X: Single): Single;          { 1 / cos(X) }
function Cosecant(const X: Single): Single;        { 1 / sin(X) }
function Hypot(const X, Y: Single): Single;        { Sqrt(X**2 + Y**2) }

function ArcSin(const X: Single): Single;
function ArcCos(const X: Single): Single;

{ ArcTan2 calculates ArcTan(Y/X), and returns an angle in the correct quadrant.
  IN: |Y| < 2^64, |X| < 2^64, X <> 0   OUT: [-PI..PI] radians }
function ArcTan2(const Y, X: Single): Single;

{ Conversion between Degree and Radian }
function DegToRad(const Degrees: Single): Single; { Radians := Degrees * PI / 180}
function RadToDeg(const Radians: Single): Single; { Degrees := Radians * 180 / PI }
procedure DegToRadP(var Angle: Single);
procedure RadToDegP(var Angle: Single);

{ Modulo for Singles (faster than direct implementation),
  doesn't work with large numbers.}
procedure Modulo(var Value:single;const Modul:Single); {Result is between -Modul/2 and +Modul/2}
procedure Modulo2PIN(var Angle:single);  {Result is between -Pi an PI }
procedure Modulo2PI(var Angle:single); {Result is between 0 and 2PI }

{ Convinience method to switch between Cartesian and Polar coordinates systems }
procedure CartesianToPolar(const X, Y: Single;var Ray,Phi:Single);
procedure PolarToCartesian(const Ray,Phi:Single;var X, Y: Single);


{ Exponent and Power operations }


{ Result := X * (2^P) }
function Ldexp(const X: Single; const P: Integer): Single;

{ Calculate the center of the segment [P1,P2] }
function MidPoint(const P1, P2: TFloatPoint): TFloatPoint;

{ Integer power, result = Base^Exponent }
function IntPower(Base: Single; Exponent: Integer): Single;

{ Approximate SqrT(x) = exp(ln(x)*0.5)
  Tests: Bads result on P4 }
function SqrtEx(const x:single):single;

{ Fastcode challenge imported implemenation :
 Author:            Dennis Kjaer Christensen
 Date:              31/12 2003
 Optimized for:     Blended
 Instructionset(s): IA32 + FCOMI + SSE
 see http://www.fastcodeproject.org  for details.
 }
function Power(const Base, Exponent: Single): Single;



{ Array operations }

{}
function Sum(const Data: TArrayOfSingle): Single;

{}
function Mean(const Data: TArrayOfSingle): Single;

{ Determine if the given polygon (N points) is convex. }
function Convex(const Polygon:TArrayOfFloatPoint):boolean; overload;



{ Misc. }

function Min(const A, B: Single) : Single;
function Max(const A, B: Single) : Single;
function Sign(const AValue: Single): Integer;


{Convert a TPoint array into a TFloatPointArray }

function PointArrayToFloatArray(const points:array of TPoint):TArrayOfFloatPoint;


{ The FPU controlword controls the precision and rounding mode. The precision
  control word bits only affect the result of the following instructions: FADD,
  FADDP, FSUB, FSUBP, FSUBR, FMUL, FMULP, FDIV, FDIVP, FDIVR, FDIVRP and FSQRT.
  Setting the precision on the lowest acceptable precision has a dramatic impact
  on speed.
  The default precision is extended, and this can in most cases by changed to
  double. The single precision setting should be used carefully and only where
  speed is extremely important. (Dennis Kjær Christensen, Coding for Speed in
  Delphi) }
procedure SinglePrecision;
procedure DoublePrecision;
procedure ExtendedPrecision;


{ Bit manipulations }

{ Return the more significient bit of X set to 1 }
function maxBitSet(X: Cardinal): Integer;
{ Return the less significient bit of X set to 1 }
function minBitSet(X: Cardinal): Integer;
{Note: Uses this two functions to test if X is an power of 2, this is true
 if and only if maxBitSet(X) = minBitSet(X) }

implementation

//uses GR32_Math;

function maxBitSet(X: Cardinal): Integer;
asm
  bsr   eax,X
end;

function minBitSet(X: Cardinal): Integer;
asm
  bsf   eax,X
end;

// FastCode Challenge
function Max(const A, B : Single) : Single;
asm
 fld     A
 fld     B
 fcomi   st(0), st(1)
 fcmovb  st(0), st(1)
 ffree   st(1)
end;

// FastCode Challenge
function Min(const A, B : Single) : Single;
asm
 fld     A
 fld     B
 fcomi   st(0), st(1)
 fcmovnb st(0), st(1)
 ffree   st(1)
end;

{same speed as math.sign(Double)}
function Sign(const AValue: Single): Integer;
begin
  if ((PInteger(@AValue)^ and $7FFFFFFF) = $00000000) then
    Result := 0
  else if ((PInteger(@AValue)^ and $80000000) = $80000000) then
    Result := -1
  else
    Result := 1;
end;

procedure SinglePrecision;
begin
  Set8087CW(Default8087CW and $FCFF);
end;

procedure DoublePrecision;
begin
  Set8087CW((Default8087CW and $FCFF) or $0200);
end;

procedure ExtendedPrecision;
begin
  Set8087CW(Default8087CW or $0300);
end;


function Ldexp(const X: Single; const P: Integer): Single;
  { Result := X * (2^P) }
asm
        PUSH    EAX
        FILD    dword ptr [ESP]
        FLD     X
        FSCALE
        POP     EAX
        FSTP    ST(1)
        FWAIT
end;


// gain 3% on direct implementation :
//    Value := (Value / Modul);
//    Value := (Value - Trunc(Value)) * Modul;
procedure Modulo(var Value:single;const Modul:Single);
asm
        FLD     Modul
        FLD     DWORD ptr [Value]
        FPREM1
        FSTP    DWORD ptr [Value]    // Modulo...
        FSTP    ST(0)                // POP the rest
        FWAIT
end;

// same speed as above (maybe 1 or 2% faster)
procedure Modulo2PIN(var Angle:single);
asm
        FLDPI
        FADD    ST,ST
        FLD     DWORD ptr [Angle]
        FPREM1
        FSTP    DWORD ptr [Angle]    // Modulo...
        FSTP    ST(0)                // POP the rest (PI)
        FWAIT
end;

// gain 20%, pentium pro and above
procedure Modulo2PI(var Angle:single);
asm
        FLDPI
        FADD    ST,ST               // 2PI
        FLD     DWORD ptr [Angle]
        FPREM                       // calc Modulo
        FLDZ
        FCOMIP  ST,ST(1)            // Compare 0 and Modulo (+pop 0)
        JNB     @@1                 // if Modulo >= 0 then
        FSTP    DWORD ptr [Angle]   //  return Modulo...
        FSTP    ST(0)               //  POP the rest (2PI)
        JMP     @@2
@@1:    FADDP                       // add Modulo and Rest (2PI)
        FSTP    DWORD ptr [Angle]   // Modulo+2PI...
@@2:    FWAIT
end;

function MidPoint(const P1, P2: TFloatPoint): TFloatPoint;
const
  half : single = 0.5;
begin
  Result.X:= (P2.X + P1.X) * half;
  Result.Y:= (P2.Y + P1.Y) * half;
end;

function Tan(const X: Single): Single;
{  Tan := Sin(X) / Cos(X) }
asm
        FLD    X
        FPTAN
        FSTP   ST(0)      { FPTAN pushes 1.0 after result }
end;

function CoTan(const X: Single): Single;
{ CoTan := Cos(X) / Sin(X) = 1 / Tan(X) }
asm
        FLD   X
        FPTAN
        FDIVRP
        FWAIT
end;

function Secant(const X: Single): Single;
{ Secant := 1 / Cos(X) }
asm
        FLD   X
        FCOS
        FLD1
        FDIVRP
        FWAIT
end;

function Cosecant(const X: Single): Single;
{ Cosecant := 1 / Sin(X) }
asm
        FLD   X
        FSIN
        FLD1
        FDIVRP
        FWAIT
end;


{For Pentium Pro or greater only}
function Hypot(const X, Y: Single): Single;
{ formula: Sqrt(X*X + Y*Y)
  implemented as:  |Y|*Sqrt(1+Sqr(X/Y)), |X| < |Y| for greater precision
var
  Temp: Extended;
begin
  X := Abs(X);
  Y := Abs(Y);
  if X > Y then
  begin
    Temp := X;
    X := Y;
    Y := Temp;
  end;
  if X = 0 then
    Result := Y
  else         // Y > X, X <> 0, so Y > 0
    Result := Y * Sqrt(1 + Sqr(X/Y));
end;
}
asm
        FLD     Y
        FABS
        FLD     X
        FABS
        FCOMI   ST,ST(1)  // Compare X et Y
        JBE     @@1        // if ST > ST(1) then swap
        FXCH    ST(1)      // put larger number in ST(1)
@@1:    FLDZ
        FCOMIP  ST,ST(1)    // Compare 0 et X  (+pop 0)
        JNZ      @@2
        FSTP    ST         // eat ST(0)
        JMP     @@3
@@2:    FDIV    ST,ST(1)   // ST := ST / ST(1)
        FMUL    ST,ST      // ST := ST * ST
        FLD1
        FADD               // ST := ST + 1
        FSQRT              // ST := Sqrt(ST)
        FMUL               // ST(1) := ST * ST(1); Pop ST
@@3:    FWAIT
end;

function ArcSin(const X: Single): Single;
asm
//  Result := ArcTan2(X, Sqrt(1 - X * X))
        FLD     X              // X      |
        FLD1                   // 1      | X
        FLD     ST(1)          // X      | 1      | X
        FMUL    ST(0),ST(0)    // X²     | 1      | X
        FSUBP   ST(1),ST(0)    // 1 - X² | X
        FSQRT                  // sqrt(.)| X
        FPATAN                 // result |
        FWAIT
end;

function ArcCos(const X: Single): Single;
asm
//  Result := ArcTan2(Sqrt(1 - X * X), X)
        FLD     X              // X      |
        FLD1                   // 1      | X
        FLD     ST(1)          // X      | 1      | X
        FMUL    ST(0),ST(0)    // X²     | 1      | X
        FSUBP   ST(1),ST(0)    // 1 - X² | X
        FSQRT                  // sqrt(.)| X
        FXCH
        FPATAN                 // result |
        FWAIT
end;

function ArcTan2(const Y, X: Single): Single;
asm
        FLD     Y
        FLD     X
        FPATAN
        FWAIT
end;

function Sum(const Data: TArrayOfSingle): Single;
asm  // IN: EAX = ptr to Data, EDX = High(Data) = Count - 1
     // Uses 4 accumulators to minimize read-after-write delays and loop overhead
     // 5 clocks per loop, 4 items per loop = 1.2 clocks per item
       FLDZ
       MOV      ECX, EDX
       FLD      ST(0)
       AND      EDX, not 3
       FLD      ST(0)
       AND      ECX, 3
       FLD      ST(0)
       SHL      EDX, 2      // count * sizeof(Single) = count * 4
       JMP      @Vector.Pointer[ECX*4]
@Vector:
       DD @@1
       DD @@2
       DD @@3
       DD @@4
@@4:   FADD     dword ptr [EAX+EDX+12]    // 1
       FXCH     ST(3)                     // 0
@@3:   FADD     dword ptr [EAX+EDX+8]     // 1
       FXCH     ST(2)                     // 0
@@2:   FADD     dword ptr [EAX+EDX+4]     // 1
       FXCH     ST(1)                     // 0
@@1:   FADD     dword ptr [EAX+EDX]       // 1
       FXCH     ST(2)                     // 0
       SUB      EDX, 16
       JNS      @@4
       FADDP    ST(3),ST                  // ST(3) := ST + ST(3); Pop ST
       FADD                               // ST(1) := ST + ST(1); Pop ST
       FADD                               // ST(1) := ST + ST(1); Pop ST
       FWAIT
end;

function Mean(const Data: TArrayOfSingle): Single;
begin
  Result := Sum(Data) / Length(Data);
end;

const
  DegPerRad: Single        = 57.295779513082320876798154814105;
  RadPerDeg: Single        = 0.017453292519943295769236907684886;


function DegToRad(const Degrees: Single): Single;  { Radians := Degrees * PI / 180}
begin
  Result := Degrees * RadPerDeg;
end;

function RadToDeg(const Radians: Single): Single;  { Degrees := Radians * 180 / PI }
begin
  Result := Radians * DegPerRad;
end;

procedure DegToRadP(var Angle: Single);
begin
  Angle := Angle * RadPerDeg;
end;

procedure RadToDegP(var Angle: Single);
begin
  Angle := Angle * DegPerRad;
end;

function IntPower(Base: Single; Exponent: Integer): single; register;
asm
     mov     ecx, eax
     cdq
     fld1                      { Result := 1 }
     xor     eax, edx
     sub     eax, edx          { eax := Abs(Exponent) }
     jz      @@3
     fld     Base
     jmp     @@2
@@1: fmul    ST, ST            { X := Base * Base }
@@2: shr     eax,1
     jnc     @@1
     fmul    ST(1),ST          { Result := Result * X }
     jnz     @@1
     fstp    st                { pop X from FPU stack }
     cmp     ecx, 0
     jge     @@3
     fld1
     fdivrp                    { Result := 1 / Result }
@@3: fwait
end;


// Fast Math... approximative function results
const
  ln2 = 0.693147181;
  sqrln2 = ln2 * ln2;
  fmask = $800000; // =2^23 to account for the 23 bits in the mantissa
  fexpE : single = sqrln2 / fmask;
  fexpD : single=1-sqrln2*sqrln2/4;
  flnA : single = ln2/fmask;
  flnM = (sqrln2/fmask)/(1-sqrln2*sqrln2/16);
  flnD:single=-(fmask*flnM)*(fmask*flnM)/4;
  flnE:single=flnM;
  fsqrtA:single=0.5 * fmask/ln2;

function SqrtEx(const x:single):single;
// exp(ln(x)*0.5)
asm
  mov eax, dword ptr x
  sub eax, $40000000-fmask
  mov dword ptr x, eax
  fild dword ptr x
  fld flnA
  fmul
  and eax, fmask-1  // get the remainder
  sub eax, fmask/2      // make middle =0
  mov dword ptr x, eax
  fild dword ptr x
  fld flnE
  fmul                 // factor=(r*fexpE)^2 + fexpD
  fmul st(0),st(0)
  fld flnD
  fadd
  fsub                // add to initial solution
  fld fsqrtA           // 0.5* fexpA
  fmul
  fistp dword ptr [x]
  mov eax,dword ptr [x]
  add eax,$40000000-fmask
  mov dword ptr [x],eax
  fld dword ptr [x]
  and eax, fmask-1  // get the remainder
  sub eax, fmask/2      // make middle =0
  mov dword ptr [x],eax
  fild dword ptr [x]    // load remainder
  fld fexpE
  fmul                 // factor=(r*fexpE)^2 + fexpD
  fmul st(0),st(0)
  fld fexpD
  fadd
  fmul                // multiply by initial solution
end;

function PointArrayToFloatArray(const points:array of TPoint):TArrayOfFloatPoint;
var
  i:integer;
begin
  SetLength(result,Length(points));
  for i := Low(points) to High(points) do
    with Result[i - Low(points)] do
    begin
      X := points[i].X;
      Y := points[i].Y;
    end;
end;

/// Todo optimise with SIMD instructions...
function Convex(const Polygon:TArrayOfFloatPoint):boolean;
var
  i,o,oi:integer;
begin
  if Length(Polygon) < 3 then
  begin
    Result := False;
    Exit;
  end;
  with Polygon[0] do
    o := -sign((Polygon[2].x - x) * (Polygon[1].y - y) - (Polygon[1].x - x) * (Polygon[2].y - y));
  for i := 1 to Length(Polygon) - 3 do
  begin
    with Polygon[i] do
      oi := sign((Polygon[i+2].x - x) * (Polygon[i+1].y - y) - (Polygon[i+1].x - x) * (Polygon[i+2].y - y));
    if (o = 0) then
      o := -oi
    else if (o = oi) then
    begin
      Result := False;
      Exit;
    end;
  end;
  with Polygon[Length(Polygon) -2] do
    oi := sign((Polygon[0].x - x) * (Polygon[Length(Polygon) -1].y - y) - (Polygon[Length(Polygon) -1].x - x) * (Polygon[0].y - y));
  if (o = 0) then
    o := -oi
  else if (o = oi) then
  begin
    Result := False;
    Exit;
  end;
  with Polygon[Length(Polygon) -1] do
    oi := sign((Polygon[1].x - x) * (Polygon[0].y - y) - (Polygon[0].x - x) * (Polygon[1].y - y));
  Result := o <> oi;
end;


procedure CartesianToPolar(const X, Y: Single;var Ray, Phi: Single);
begin
  phi := ArcTan2(Y,X);
  Ray := Hypot(X,Y);
end;

procedure PolarToCartesian(const Ray,Phi: Single;var X, Y: Single);
{var
  FSin,FCos:single;
begin
 SinCos(phi,FSin,FCos);
 Y := Ray * FSin;
 X := Ray * FCos;
end;}
asm
   FLD Ray
   FLD  phi
   FSINCOS
   FMUL ST(0),ST(2)
   FSTP DWORD PTR [X]    // cosine
   FMULP
   FSTP DWORD PTR [Y]    // sine
end;

//Author:            Dennis Kjaer Christensen
//Date:              31/12 2003
//Optimized for:     Blended
//Instructionset(s): IA32 + FCOMI + SSE
function Power(const Base, Exponent: Single): Single;
const
 MAXINTFP : Extended = $7fffffff;

asm
   sub    esp,$14
   //if (Abs(Exponent) <= MaxInt) then
   fld    MAXINTFP
   fld    Exponent
   fld    st(0)
   fabs
   fcomip st(0),st(2)
   ffree  st(1)
   jae    @IfEnd1
   //Y := Round(Exponent);
   fld    st(0)
   frndint
   fcomip st(0),st(1)
   ffree  st(0)
   jnz    @IfEnd2
   //Result := IntPowerDKCIA32_4e(Base, Y)
   //if Base = 0 then
   fldz
   fld    Base
   fcomi  st(0),st(1)
   jnz    @IntPowIfEnd2
   //if Exponent = 0 then
   cvtss2si ecx,Exponent
   test   ecx,ecx
   jnz    @IntPowElse2
   //ResultX := 1
   ffree  st(1)
   ffree  st(0)
   fld1
   mov    esp,ebp
   pop    ebp
   ret    $8
   //jmp    @Exit
 @IntPowElse2 :
   //ResultX := 0;
   fxch   st(1)
   ffree  st(1)
   mov    esp,ebp
   pop    ebp
   ret    $8
   //jmp    @Exit
 @IntPowIfEnd2 :
   //else if Exponent = 0 then
   cvtss2si ecx,Exponent
   test   ecx,ecx
   jnz    @IntPowElseIf2
   //ResultX := 1
   ffree  st(1)
   ffree  st(0)
   fld1
   mov    esp,ebp
   pop    ebp
   ret    $8
   //jmp    @Exit
 @IntPowElseIf2 :
   //else if Exponent = 1 then
   cmp    ecx,1
   jnz    @IntPowElseIf3
   //ResultX := Base
   ffree  st(1)
   mov    esp,ebp
   pop    ebp
   ret    $8
   //jmp    @Exit
 @IntPowElseIf3 :
   //else if Exponent = 2 then
   cmp    ecx,2
   jnz    @IntPowElseIf4
   //ResultX := Base * Base
   ffree  st(1)
   fmul   st(0),st(0)
   mov    esp,ebp
   pop    ebp
   ret    $8
   //jmp    @Exit
 @IntPowElseIf4 :
   //else if Exponent > 2 then
   cmp    ecx,2
   jle    @IntPowElseIf5
   ffree  st(1)
   //ResultX2 := 1;
   fld1
   //ResultX := Base;
   fxch   st(1)
   mov    eax,ecx
   //I := 2;
   mov    edx,2
   //I2 := Exponent;
 @IntPowRepeat1Start :
   //I2 := I2 shr 1;
   shr    ecx,1
   jnc    @IntPowIfEnd8
   //ResultX2 := ResultX2 * ResultX;
   fmul   st(1),st(0)
 @IntPowIfEnd8 :
   //ResultX := ResultX * ResultX;
   fmul   st(0),st(0)
   //I := I * 2;
   add    edx,edx
   //until(I > Exponent);
   cmp    eax,edx
   jnl    @IntPowRepeat1Start
   //ResultX := ResultX * ResultX2;
   fmulp  st(1),st(0)
   mov    esp,ebp
   pop    ebp
   ret    $8
   //jmp    @Exit
 @IntPowElseIf5 :
   //else if Exponent = -1 then
   cmp    ecx,-1
   jnz    @IntPowElseIf6
   ffree  st(1)
   //ResultX := 1/Base
   fld1
   fdivrp st(1),st(0)
   mov    esp,ebp
   pop    ebp
   ret    $8
   //jmp    @Exit
 @IntPowElseIf6 :
   //else if Exponent = -2 then
   cmp    ecx,-2
   jnz    @IntPowElse7
   //ResultX := 1/(Base*Base)
   ffree  st(1)
   fmul   st(0),st(0)
   fld1
   fdivrp
   mov    esp,ebp
   pop    ebp
   ret    $8
   //jmp    @Exit
 @IntPowElse7 :
   ffree  st(1)
   //else //if Exponent < -2 then
   //I2 := -Exponent;
   mov    eax,ecx
   neg    eax
   mov    edx,eax
   //I := 2;
   mov    ecx,2
   //ResultX2 := 1;
   fld1
   //ResultX := Base;
   fxch   st(1)
 @IntPowRepeat2Start :
   //I2 := I2 shr 1;
   shr    eax,1
   jnc    @IntPowIfEnd7
   //ResultX2 := ResultX2 * ResultX;
   fmul   st(1),st(0)
 @IntPowIfEnd7 :
   //ResultX := ResultX * ResultX;
   fmul   st(0),st(0)
   //I := I * 2;
   add    ecx,ecx
   //until(I > -Exponent);
   cmp    ecx,edx
   jle    @IntPowRepeat2Start
   //ResultX := ResultX * ResultX2;
   fmulp  st(1),st(0)
   //ResultX := 1 / ResultX;
   fld1
   fdivr
   mov    esp,ebp
   pop    ebp
   ret    $8
   //jmp    @Exit
 @IfEnd2 :
   //Result := Exp(Exponent * Ln(Base))
   fld    Base
   fldln2
   fxch   st(1)
   fyl2x
   fld    Exponent
   fmulp
   fldl2e
   fmulp
   fld    st(0)
   frndint
   fsub   st(1),st(0)
   fxch   st(1)
   f2xm1
   fld1
   faddp
   fscale
   ffree  st(1)
   mov    esp,ebp
   pop    ebp
   ret    $8
   //jmp    @Exit
 @IfEnd1 :
   //if (Exponent > 0) and (Base <> 0) then
   fldz
   fcomip st(0),st(1)
   fld    Base
   jbe    @IfEnd3
   fldz
   fcomip st(0),st(1)
   jz     @IfEnd3
   //Result := Exp(Exponent * Ln(Base))
   fldln2
   fxch   st(1)
   fyl2x
   fmul   st(0), st(1)
   ffree  st(1)
   fldl2e
   fmulp
   fld    st(0)
   frndint
   fsub   st(1),st(0)
   fxch   st(1)
   f2xm1
   fld1
   faddp
   fscale
   ffree  st(1)
   mov    esp,ebp
   pop    ebp
   ret    $8
   //jmp    @Exit
 @IfEnd3 :
   //else if Base = 0 then
   fldz
   fcomip st(0),st(1)
   jnz    @ElseIfEnd4
   //Result := 0
   ffree  st(1)
   mov    esp,ebp
   pop    ebp
   ret    $8
   //jmp    @Exit
 @ElseIfEnd4 :
   //Result := Exp(Exponent * Ln(Base))
   fldln2
   fxch   st(1)
   fyl2x
   fmul   st(0),st(1)
   ffree  st(1)
   fldl2e
   fmulp
   fld    st(0)
   frndint
   fsub   st(1),st(0)
   fxch   st(1)
   f2xm1
   fld1
   faddp
   fscale
   ffree  st(1)
 //@Exit :
   wait
   mov    esp,ebp
end;

end.

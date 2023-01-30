unit GR32_GausianBlur;

(* BEGIN LICENSE BLOCK *********************************************************
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is GR32_GausianBlur. The Original Code is a translation
 * of Java Source Code written by Mario Klingemann <mario@quasimondo.com>,
 * http://incubator.quasimondo.com. The Original Code was translated to Delphi
 * Source Code by Angus Johnson (with Mario's permission) and has been slightly
 * modified to incorporate blurring of alpha bytes too.
 * Copyright (C) 2009 Mario Klingemann. All Rights Reserved.
 *
 * The Original Code was converted to Delphi by Angus Johnson.
 *
 * Version 1.0 (Last updated 19-Sep-09)
 *
 * END LICENSE BLOCK **********************************************************)

interface

{$WARN UNSAFE_TYPE OFF}
{$WARN UNSAFE_CAST OFF}

uses
  Windows, Types, SysUtils, classes, Math, GR32;

type
  TGausianBlur = class
  public
    radius    : integer;
    kernelSize: integer;
    kernel    : array of integer;
    mult      : array of array of integer;
    constructor Create(radius: integer);
    procedure SetRadius(radius: integer);
    procedure Execute(bitmap: TBitmap32; x, y, w, h: integer);
  end;

implementation

constructor TGausianBlur.Create(radius: integer);
begin
  setRadius(radius);
end;

procedure TGausianBlur.SetRadius(radius: integer);
var
  i,j,radiusi: integer;
begin
  radius := min(max(1,radius),248);
  if (self.radius = radius) then exit;
  self.radius := radius;
  kernelSize := 1 +radius*2;
  setlength(kernel, kernelSize);
  setlength(mult, kernelSize);
  for i := 0 to high(mult) do setlength(mult[i], 256);
  for i := 1 to radius -1 do
  begin
    radiusi := radius-i;
    kernel[radiusi] := radiusi*radiusi;
    kernel[radius+i] := kernel[radiusi];
    for j := 0 to 255 do
    begin
      mult[radiusi][j] := kernel[radiusi]*j;
      mult[radius+i][j] := mult[radiusi][j];
    end;
  end;
  kernel[radius] := radius*radius;
  for j :=0 to 255 do
    mult[radius][j] := kernel[radius]*j;
end;

procedure TGausianBlur.Execute(bitmap: TBitmap32; x, y, w, h: integer);
var
  sum,ca,cr,cg,cb,k: integer;
  pixel,i,xl,yl,yi,ym,riw: integer;
  iw,wh,p,q: integer;
  pix: PColor32Array;
  ri: TColor32Entry;
  a,r,g,b, a2,r2,g2,b2: array of integer;
begin
  pix := bitmap.bits;
  iw := bitmap.width;
  wh := iw * bitmap.height;
  setlength(a, wh);
  setlength(r, wh);
  setlength(g, wh);
  setlength(b, wh);

  for i := 0 to wh -1 do
  begin
    {$R-}
    ri := TColor32Entry(pix[i]);
    {$R+}
    a[i] := ri.A;
    r[i] := ri.R;
    g[i] := ri.G;
    b[i] := ri.B;
  end;

  setlength(a2, wh);
  setlength(r2, wh);
  setlength(g2, wh);
  setlength(b2, wh);

  x := max(0,x);
  y := max(0,y);
  w := x+w -max(0,(x+w) -iw);
  h := y+h -max(0,(y+h) -bitmap.height);
  yi := y*iw;

  for yl := y to h-1 do
  begin
    for xl := x to w-1 do
    begin
      cb := 0; cg := 0; cr := 0; ca := 0; sum:= 0;
      q := xl - radius;
      for i :=0 to kernelSize-1 do
      begin
        p := q+i;
        if (p >= x) and (p < w) then
        begin
          inc(p, yi);
          inc(ca, mult[i][a[p]]);
          inc(cr, mult[i][r[p]]);
          inc(cg, mult[i][g[p]]);
          inc(cb, mult[i][b[p]]);
          inc(sum, kernel[i]);
        end;
      end;
      q := yi+xl;
      a2[q] := ca div sum;
      r2[q] := cr div sum;
      g2[q] := cg div sum;
      b2[q] := cb div sum;
    end;
    inc(yi, iw);
  end;

  yi := y*iw;
  for yl :=y to h -1 do
  begin
    ym := yl -radius;
    riw := ym*iw;
    for xl := x to w -1 do
    begin
      cb := 0; cg := 0; cr := 0; ca := 0; sum := 0;
      q := ym;
      p := xl +riw;
      for i := 0 to kernelSize -1 do
      begin
        if (q < h) and (q >= y) then
        begin
          inc(ca, mult[i][a2[p]]);
          inc(cr, mult[i][r2[p]]);
          inc(cg, mult[i][g2[p]]);
          inc(cb, mult[i][b2[p]]);
          inc(sum, kernel[i]);
        end;
        inc(q);
        inc(p, iw);
      end;
    {$R-}
      TColor32Entry(pix[xl+yi]).ARGB := cardinal((ca div sum) shl 24 or
        (cr div sum) shl 16 or (cg div sum) shl 8 or (cb div sum));
    {$R+}
    end;
    inc(yi, iw);
  end;
end;


end.

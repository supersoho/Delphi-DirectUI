unit GR32_StackBlur;

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
 * The Original Code is GR32_StackBlur. The Original Code is a translation
 * of Java Source Code written by Mario Klingemann <mario@quasimondo.com>,
 * http://incubator.quasimondo.com. The Original Code was translated to Delphi
 * Source Code by Angus Johnson (with Mario's permission) and has been slightly
 * modified to incorporate blurring of alpha bytes too.
 * Copyright (C) 2009 Mario Klingemann. All Rights Reserved.
 *
 * Version 1.0 (Last updated 19-Sep-09)
 *
 * END LICENSE BLOCK **********************************************************)

interface

{$WARN UNSAFE_TYPE OFF}

uses
  Windows, Types, SysUtils, classes, Math, GR32;

type
  TStackBlur = class
  public
    radius    : integer;
    constructor Create(radius: integer);
    procedure Execute(bitmap: TBitmap32);
  end;

implementation

type
  TInt3Array = array[0..2] of integer;
  PInt3Array = ^TInt3Array;

constructor TStackBlur.Create(radius: integer);
begin
  self.radius := min(max(1,radius),40);
end;

procedure TStackBlur.Execute(bitmap: TBitmap32);
var
  i, w, h, wm, hm, wh, diam, q1, q2: integer;
  asum, rsum, gsum, bsum, x1, y1, yp, yi, yw: integer;
  pix: PColor32Array;
  p, p1, p2: TColor32Entry;
  a, r, g, b, vmin, vmax, dv: array of integer;
begin
  pix := bitmap.bits;
  w := bitmap.width;
  h := bitmap.height;
  wm := w -1;
  hm := h -1;
  wh := w * h;
  diam := radius+radius+1;
  setlength(a, wh);
  setlength(r, wh);
  setlength(g, wh);
  setlength(b, wh);
  setlength(vmin, max(w,h));
  setlength(vmax, max(w,h));
  setlength(dv, 256*diam);
  for i :=0 to 256*diam -1 do dv[i] := (i div diam);

  yw := 0;
  yi := 0;

  for y1 := 0 to h -1 do
  begin
    asum := 0; rsum := 0; gsum := 0; bsum := 0;
    for i := -radius to radius do
    begin
      {$R-}
      p.ARGB := pix[yi + min(wm, max(i,0))];
      {$R+}
      inc(asum, p.A);
      inc(rsum, p.R);
      inc(gsum, p.G);
      inc(bsum, p.B);
    end;
    for x1 := 0 to w -1 do
    begin
      a[yi] := dv[asum];
      r[yi] := dv[rsum];
      g[yi] := dv[gsum];
      b[yi] := dv[bsum];

      if (y1 = 0) then
      begin
        vmin[x1] := min(x1+radius+1, wm);
        vmax[x1] := max(x1-radius, 0);
      end;

      {$R-}
      p1.ARGB := pix[yw +vmin[x1]];
      p2.ARGB := pix[yw +vmax[x1]];
      {$R+}

      inc(asum, p1.A - p2.A);
      inc(rsum, p1.R - p2.R);
      inc(gsum, p1.G - p2.G);
      inc(bsum, p1.B - p2.B);
      inc(yi);
    end;
    inc(yw, w);
  end;

  for x1 :=0 to w -1 do
  begin
    asum := 0; rsum := 0; gsum := 0; bsum := 0;
    yp := -radius*w;
    for i := -radius to radius do
    begin
      yi := max(0, yp) +x1;
      inc(asum, a[yi]);
      inc(rsum, r[yi]);
      inc(gsum, g[yi]);
      inc(bsum, b[yi]);
      inc(yp, w);
    end;
    yi := x1;
    for y1 := 0 to h -1 do
    begin
      {$R-}
      pix[yi] := cardinal((dv[asum] shl 24) or
        (dv[rsum] shl 16) or (dv[gsum] shl 8) or dv[bsum]);
      {$R+}
      if (x1 = 0) then
      begin
        vmin[y1] := min(y1 +radius +1, hm) *w;
        vmax[y1] := max(y1 -radius,0) *w;
      end;
      q1 := x1 +vmin[y1];
      q2 := x1 +vmax[y1];

      inc(asum, a[q1]-a[q2]);
      inc(rsum, r[q1]-r[q2]);
      inc(gsum, g[q1]-g[q2]);
      inc(bsum, b[q1]-b[q2]);

      inc(yi, w);
    end;
  end;

end;

end.

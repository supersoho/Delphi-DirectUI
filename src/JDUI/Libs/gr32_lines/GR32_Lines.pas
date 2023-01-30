unit GR32_Lines;

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
 * The Original Code is GR32_Lines for Graphics32
 *
 * The Initial Developer of the Original Code is
 * Angus Johnson <angus@angusj.com>.
 *
 * Portions created by the Initial Developer are Copyright (C) 2008-2010
 * the Initial Developer. All Rights Reserved.
 *
 * Acknowledgements:
 * The Grow algorithm is derived from TPolygon32.Grow in the GR32_Polygons unit.
 * The mitering, bevelling and rounding functions contained in Grow are based on
 * code from Mattias Andersson's GR32_VectorUtils unit in VPR ...
 * http://vpr.sourceforge.net/
 *
 * Version 3.93 (Last updated 17-Nov-2010)
 *
 * END LICENSE BLOCK **********************************************************)

interface

{$I GR32.inc}
{$IFDEF COMPILER7}
{$WARN UNSAFE_CODE OFF}
{$ENDIF}

{.$DEFINE GR32_PolygonsEx}
//nb: if you uncomment DEFINE GR32_PolygonsEx here,
//    make sure you also do the same in GR32_Misc.

uses
  Windows, Classes, SysUtils, Math,
  GR32, GR32_LowLevel, GR32_Blend, GR32_Transforms,
{$IFDEF GR32_PolygonsEx}
  GR32_PolygonsEx, GR32_VPR,
{$ENDIF}
  GR32_Math, GR32_Polygons, GR32_Misc;

type

  TJoinStyle = (jsBevelled, jsRounded, jsMitered);
  TEndStyle = (esSquared, esRounded, esClosed, esButt);
  TQuadrant = (First, Second, Third, Forth);
  TArrowHeadStyle = (asNone, asThreePoint,
    asFourPoint, asSquare, asDiamond, asCircle, asCustom);
  THitTestResult = (htNone, htStartArrow, htEndArrow, htLine);

  TCustomArrowHeadProc = function(tipPt, tailPt: TFixedPoint;
    HeadSize, PenWidth: single;
    ArrowHeadStyle: TArrowHeadStyle): TArrayOfFixedPoint of Object;
  TColorProc = function(frac: single): TColor32;

  TLine32 = class;
  TArrowHead = class;

  //TArrowPen: property of TArrowHead class
  TArrowPen = class
  private
    fOwnerArrowHead: TArrowHead;
    fColor: TColor32;
    fWidth: single;
    procedure SetWidth(value: single);
  public
    constructor Create(owner: TArrowHead);
    property Color: TColor32 read fColor write fColor;
    property Width: single read fWidth write SetWidth;
  end;

  //TArrowHead: property of TLine32 class
  TArrowHead = class
  private
    fOwnerLine32: TLine32;
    fIsStartArrow: boolean;
    fStyle: TArrowHeadStyle;
    fSize: single;
    fColor: TColor32;
    fCustomProc: TCustomArrowHeadProc;
    fPen: TArrowPen;
    fTipPoint: TFixedPoint;
    fBasePoint: TFixedPoint;
    fBaseIdx: integer;
    procedure SetSize(value: single);
    procedure SetStyle(value: TArrowHeadStyle);
    procedure SetCustomProc(value: TCustomArrowHeadProc);
    procedure Draw(bitmap: TBitmap32);
  protected
    function IsNeeded: boolean;
    function GetTipAndBase: boolean;
    property Base: TFixedPoint read fBasePoint;
    property BaseIdx: integer read fBaseIdx;
  public
    constructor Create(owner: TLine32; IsStartArrow: boolean);
    destructor Destroy; override;
    function GetPoints: TArrayOfFixedPoint;
    //OutlinePoints - ie for hittesting (nb already includes pen width)
    function OutlinePoints(delta: single): TArrayOfFixedPoint;

    property Color: TColor32 read fColor write fColor;
    property Style: TArrowHeadStyle read fStyle write SetStyle;
    property Size: single read fSize write SetSize;
    property Pen: TArrowPen read fPen;
    property CustomProc: TCustomArrowHeadProc
      read fCustomProc write SetCustomProc;
  end;

  //TLine32: encapsulates drawing of lines of varying widths and styles.
  //It includes properties to select line join and line end styles,
  //various arrow ends, and ways to fill lines with gradient colors and
  //bitmap patterns.
  TLine32 = class
  private
    fLinePoints     : TArrayOfFixedPoint;
    fLeftPoints     : TArrayOfFixedPoint;
    fRightPoints    : TArrayOfFixedPoint;
    fPolygon32      : {$IFDEF GR32_PolygonsEx} TPolygon32Ex; {$ELSE} TPolygon32; {$ENDIF}
    fStartArrow     : TArrowHead;
    fEndArrow       : TArrowHead;
    fLineWidth      : single;
    fEndStyle       : TEndStyle;
    fFillMode       : TPolyFillMode;
    fMiterLimit     : single;
    fJoinStyle      : TJoinStyle;
    procedure Build;
    procedure SetWidth(value: single);
    procedure SetMiterLimit(value: single);
    procedure SetJoinStyle(value: TJoinStyle);
    procedure SetEndStyle(value: TEndStyle);
    procedure DrawArrows(bitmap: TBitmap32);
    procedure DrawGradientHorz(bitmap: TBitmap32; penWidth: single;
      const colors: array of TColor32; edgeColor: TColor32 = $00000000);
    procedure DrawGradientVert(bitmap: TBitmap32; penWidth: single;
      const colors: array of TColor32; edgeColor: TColor32 = $00000000);
    {$IFNDEF GR32_PolygonsEx}
    function GetAntialiasMode: TAntialiasMode;
    procedure SetAntialiasMode(aaMode: TAntialiasMode);
    {$ENDIF}
  protected
    procedure ForceRebuild;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear;
    procedure SetPoints(const pts: array of TFixedPoint);
    function AddPoints(const newPts: array of TFixedPoint;
      ToEnd: boolean = true): cardinal; overload;
    function AddPoints(var startPt: TFixedPoint; count: integer;
      ToEnd: boolean = true): cardinal; overload;
    procedure DeletePoints(count: integer; FromEnd: boolean = true);

    //draw a solid line (nb: edgeColor if used will be of width 1 px)
    //nb: if you want to draw lines with edges wider than 1 px then use GetOutline().
    procedure Draw(bitmap: TBitmap32; penWidth: single; color: TColor32; edgeColor: TColor32 = $00000000); overload;
    //draw a line using a bitmap pattern ...
    procedure Draw(bitmap: TBitmap32; penWidth: single; pattern: TBitmap32; edgeColor: TColor32 = $00000000); overload;
    //draw a line using a TCustomPolygonFiller filler ...
    procedure Draw(bitmap: TBitmap32; penWidth: single; filler: TCustomPolygonFiller; edgeColor: TColor32 = $00000000); overload;
    //draw a stippled line ...
    procedure Draw(bitmap: TBitmap32; penWidth: single; colors: array of TColor32); overload;
    procedure Draw(bitmap: TBitmap32; penWidth: single; colors: array of TColor32; StippleStep: single); overload;
    //another (new) draw stippled line method ...
    procedure Draw(bitmap: TBitmap32; penWidth: single;
      dashPattern: TArrayOfFloat; color: TColor32; edgeColor: TColor32 = $00000000); overload;

    //draw a line using a color gradient at the specified angle ...
    procedure DrawGradient(bitmap: TBitmap32; penWidth: single;
      const colors: array of TColor32;
      angle_degrees: integer; edgeColor: TColor32 = $00000000);

    //GetOutline() gets an array of points that represent the outline of the
    //line at the specified line width.
    //When penWidth = 0 the existing width will be used to execute the method.
    function GetOutline(penWidth: single = 0): TArrayOfFixedPoint;
    //GetOuterEdge() gets an array of points that represents the outer edge
    //of the current 'closed' line points (polygon) at the specified line width.
    //When penWidth = 0 the existing width will be used to execute the method.
    //nb: GetOuterEdge assumes a convex polygon (otherwise may get inner edge)
    function GetOuterEdge(penWidth: single = 0): TArrayOfFixedPoint;
    //GetInnerEdge() gets an array of points that represents the inner edge
    //of the current 'closed' line points (polygon) at the specified line width.
    //When penWidth = 0 the existing width will be used to execute the method.
    //nb: GetInnerEdge assumes a convex polygon (otherwise may get outer edge)
    function GetInnerEdge(penWidth: single = 0): TArrayOfFixedPoint;

    function GetLeftPoints: TArrayOfFixedPoint;
    function GetRightPoints: TArrayOfFixedPoint;

    //When width = 0 the previous line width will be used to execute the method.
    function GetBoundsFixedRect(penWidth: single = 0): TFixedRect;
    function GetBoundsRect(penWidth: single = 0): TRect;

    procedure Transform(matrix : TFloatMatrix);
    procedure Translate(dx,dy: TFloat);
    procedure Scale(dx,dy: TFloat);
    procedure Rotate(origin: TFloatPoint; radians: single);

    //DoHitTest() returns whether the point is inside the line (or arrows)
    //When width = 0 the previous line width will be used to execute the method.
    function DoHitTest(pt: TFixedPoint; penWidth: single = 0): THitTestResult;

    function Points: TArrayOfFixedPoint;
    function GetArrowTruncatedPoints: TArrayOfFixedPoint;

    {$IFNDEF GR32_PolygonsEx}
    property  AntialiasMode: TAntialiasMode read
      GetAntialiasMode write SetAntialiasMode default am16times;
    {$ENDIF}
    property ArrowStart: TArrowHead read fStartArrow;
    property ArrowEnd: TArrowHead read fEndArrow;
    property EndStyle: TEndStyle read fEndStyle write SetEndStyle;
    property FillMode: TPolyFillMode read fFillMode write fFillMode;
    property JoinStyle: TJoinStyle read fJoinStyle write SetJoinStyle;
    property LineWidth: single read fLineWidth write SetWidth;
    //MiterLimit: used when JoinStyle = jsMitered and indicates
    //the maximum allowed miter distance (default = 2; 0 = fully bevelled).
    property MiterLimit: single read fMiterLimit write SetMiterLimit;
  end;

////////////////////////////////////////////////////////////////////////////////
// Helper polyline functions ...
////////////////////////////////////////////////////////////////////////////////

function InflatePoints(const pts: TArrayOfFixedPoint;
  delta: single; closed: boolean): TArrayOfFixedPoint; overload;
function InflatePoints(const polyPts: TArrayOfArrayOfFixedPoint;
  delta: single; closed: boolean): TArrayOfArrayOfFixedPoint; overload;
function InflatePoints(const pts: TArrayOfFloatPoint;
  delta: single; closed: boolean): TArrayOfFloatPoint; overload;
function InflatePoints(const polyPts: TArrayOfArrayOfFloatPoint;
  delta: single; closed: boolean): TArrayOfArrayOfFloatPoint; overload;

////////////////////////////////////////////////////////////////////////////////
// Helper drawing functions ...
////////////////////////////////////////////////////////////////////////////////

procedure SimpleLine(bitmap: TBitmap32; const pts: array of TFixedPoint;
  color: TColor32; width: single; closed: boolean = false); overload;

procedure SimpleLine(bitmap: TBitmap32; const ppts: TArrayOfArrayOfFixedPoint;
  color: TColor32; width: single; closed: boolean); overload;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

implementation

type

  TGrowBase = class
  private
  protected
    procedure AddLeft(idx: integer; const pt: TFixedPoint); virtual; abstract;
    procedure AddRight(idx: integer; const pt: TFixedPoint); virtual; abstract;
    procedure OnStart; virtual;
    procedure OnFinish; virtual;
  public
    procedure Grow(const pts: array of TFixedPoint; lineWidth: single;
      joinStyle: TJoinStyle; miterLimit: single; isClosed: boolean);
  end;

  TGrow = class(TGrowBase)
  private
    fLeftPts, fRightPts: PArrayOfFixedPoint;
    leftLen, leftBuffLen, rightLen, rightBuffLen: integer;
    buffSizeIncrement: integer;
  protected
    procedure AddLeft(idx: integer; const pt: TFixedPoint); override;
    procedure AddRight(idx: integer; const pt: TFixedPoint); override;
    procedure OnFinish; override;
  public
    constructor Create(LeftPts, RightPts: PArrayOfFixedPoint); virtual;
  end;

  PStippleItem = ^TStippleItem;
  TStippleItem = record
    left: TArrayOfFixedPoint;
    right: TArrayOfFixedPoint;
  end;

  TStippledGrow = class(TGrow)
  private
    fCurrentIndex: integer;
    fList: TList;
    function GetItem(index: integer): PStippleItem;
  protected
    procedure AddLeft(idx: integer; const pt: TFixedPoint); override;
    procedure AddRight(idx: integer; const pt: TFixedPoint); override;
    procedure OnStart; override;
  public
    constructor Create(LeftPts, RightPts: PArrayOfFixedPoint); override;
    destructor Destroy; override;
    procedure Clear;
    function Count: integer;
    property Item[index: integer]: PStippleItem read GetItem;
  end;

//------------------------------------------------------------------------------
// Miscellaneous helper functions
//------------------------------------------------------------------------------

procedure SimpleLine(bitmap: TBitmap32; const pts: array of TFixedPoint;
  color: TColor32; width: single; closed: boolean = false);
var
  i, len: integer;
  ppts: TArrayOfArrayOfFixedPoint;
begin
  len := length(pts);
  if len = 0 then exit;
  setlength(ppts,1);
  setlength(ppts[0],len);
  for i := 0 to len -1 do ppts[0][i] := pts[i];
  SimpleLine(bitmap, ppts, color, width, closed);
end;
//------------------------------------------------------------------------------

procedure SimpleLine(bitmap: TBitmap32; const ppts: TArrayOfArrayOfFixedPoint;
  color: TColor32; width: single; closed: boolean); overload;
var
  i: integer;
begin
  if width < 1.5 then
    SimpleLine(bitmap, ppts, color, closed)
  else
    with TLine32.Create do
    try
      if closed then EndStyle := esClosed else EndStyle := esRounded;
      JoinStyle := jsRounded;
      for i := 0 to high(ppts) do
      begin
        SetPoints(ppts[i]);
        Draw(bitmap,width,color);
      end;
    finally
      free;
    end;
end;
//------------------------------------------------------------------------------

//BuildArc is for internal use for TLine32.Grow. (Otherwise use GetArcPoints.)
function BuildArc(const pt: TFloatPoint; a1, a2, r: TFloat): TArrayOfFixedPoint;
const
  MINSTEPS = 6;
var
  I, N: Integer;
  a, da, dx, dy: TFloat;
  Steps: Integer;
begin
  Steps := Max(MINSTEPS, Round(Sqrt(Abs(r)) * Abs(a2 - a1)));
  SetLength(Result, Steps);
  N := Steps - 1;
  da := (a2 - a1) / N;
  a := a1;
  for I := 0 to N do
  begin
    SinCos(a, r, dy, dx);
    Result[I].X := Fixed(pt.X + dx);
    Result[I].Y := Fixed(pt.Y + dy);
    a := a + da;
  end;
end;
//------------------------------------------------------------------------------

//OutlineClosedPoints() is a simple routine used for drawing arrow heads that
//gets the outline of a 'closed' point array (and without bevelling etc)
function OutlineClosedPoints(const pts: array of TFixedPoint;
  lineWidth: single; PerimeterPointsOnly: boolean = false): TArrayOfFixedPoint;
var
  leftPoints, rightPoints: TArrayOfFixedPoint;
begin
  result := nil;
  //build leftPoints and rightPoints arrays ...
  with TGrow.Create(@leftPoints, @rightPoints) do
  try
    Grow(pts, lineWidth, jsMitered, 4, true);
  finally
    free;
  end;

  if PerimeterPointsOnly then
  begin
    if IsClockwise(leftPoints) then
      result := Copy(leftPoints, 0, length(leftPoints)) else
      result := Copy(rightPoints, 0, length(rightPoints));
  end else
  begin
    rightPoints := ReversePoints(rightPoints);
    setLength(result, length(leftPoints) + length(rightPoints));
    move(leftPoints[0], result[0], length(leftPoints)* sizeof(TFixedPoint));
    move(rightPoints[0], result[length(leftPoints)],
      length(rightPoints)* sizeof(TFixedPoint));
  end;
end;
//------------------------------------------------------------------------------

function InflatePoints(const pts: TArrayOfFixedPoint;
  delta: single; closed: boolean): TArrayOfFixedPoint;
var
  polyPts: TArrayOfArrayOfFixedPoint;
begin
  setlength(polyPts, 1);
  polyPts[0] := pts;
  result := InflatePoints(polyPts, delta, closed)[0];
end;
//------------------------------------------------------------------------------

function InflatePoints(const polyPts: TArrayOfArrayOfFixedPoint;
  delta: single; closed: boolean): TArrayOfArrayOfFixedPoint;
var
  i: integer;
begin
  result := polyPts;
  if (delta = 0) or (length(polyPts) = 0) then exit;

  //assumes clockwise orientation for closed outer polygons and
  //counter-clockwise orientation for closed inner (hole) polygons ...
  with TLine32.Create do
  try
    if closed then
      EndStyle := esClosed else
      EndStyle := esRounded;
     JoinStyle := jsRounded;
    LineWidth := abs(delta);
    setlength(result, length(polyPts));
    for i := 0 to high(polyPts) do
    begin
      SetPoints(polyPts[i]);
      if not closed then result[i] := GetOutline
      else if delta < 0 then result[i] := GetRightPoints
      else result[i] := GetLeftPoints;
    end;
  finally
    free;
  end;
end;
//------------------------------------------------------------------------------

function InflatePoints(const pts: TArrayOfFloatPoint;
  delta: single; closed: boolean): TArrayOfFloatPoint;
var
  polyPts: TArrayOfArrayOfFixedPoint;
begin
  setlength(polyPts, 1);
  polyPts[0] := FixedPoints(pts);
  polyPts := InflatePoints(polyPts, delta, closed);
  result := FloatPoints(polyPts[0]);
end;
//------------------------------------------------------------------------------

function InflatePoints(const polyPts: TArrayOfArrayOfFloatPoint;
  delta: single; closed: boolean): TArrayOfArrayOfFloatPoint; overload;
var
  ppts: TArrayOfArrayOfFixedPoint;
begin
  ppts := FixedPoints(polyPts);
  ppts := InflatePoints(ppts, delta, closed);
  result := FloatPoints(ppts);
end;
//------------------------------------------------------------------------------

function BuildDashedLine(const pts: TArrayOfFixedPoint;
  dashes: TArrayOfFloat; closed: Boolean = false;
  dashOffset: TFloat = 0; lineWidth: TFloat = 1): TArrayOfArrayOfFixedPoint;
var
  i, j, dashIndex, len1, len2: Integer;
  epsilon, offset, minDash, maxDash, v: TFloat;

  procedure AddPoint(X, Y: TFixed);
  var
    k: Integer;
  begin
    k := Length(Result[j]);
    SetLength(Result[j], k + 1);
    Result[j][k].X := X;
    Result[j][k].Y := Y;
  end;

  procedure DashLine(const p1, p2: TFixedPoint);
  var
    dx, dy, d: TFloat;
  begin
    dx := (p2.X - p1.X)*FixedToFloat;
    dy := (p2.Y - p1.Y)*FixedToFloat;
    d := Math.Hypot(dx, dy);
    if d = 0 then exit;
    dx := dx / d;
    dy := dy / d;
    offset := offset + d;
    while offset > dashOffset do
    begin
      v := offset - dashOffset;
      AddPoint(p2.X - Fixed(v * dx), p2.Y - Fixed(v * dy));
      dashIndex := (dashIndex + 1) mod len2;
      dashOffset := dashOffset + dashes[dashIndex];
      if Odd(dashIndex) then
      begin
        Inc(j);
        SetLength(Result, j + 1);
      end;
    end;
    if not Odd(dashIndex) then AddPoint(p2.X, p2.Y);
  end;

  function SamePoint(const p1, p2: TFixedPoint): boolean;
  begin
    result := (abs(p1.X - p2.X) < epsilon*FixedOne) and
      (abs(p1.Y - p2.Y) < epsilon*FixedOne);
  end;

begin
  v := 0;
  epsilon := lineWidth / 2;
  if epsilon < 0.00001 then epsilon := 0.00001;

  len2 := Length(dashes);
  if odd(len2) then
  begin
    setlength(dashes, len2 *2);
    move(dashes[0], dashes[len2], len2 * sizeof(TFloat));
    len2 := len2 *2;
  end;
  minDash := dashes[0];
  maxDash := dashes[0];
  for i := 1 to len2 -1 do
  begin
    if dashes[i] > maxDash then maxDash := dashes[i]
    else if dashes[i] < minDash then minDash := dashes[i];
  end;

  len1 := Length(pts);
  //ensure all dashArray values are positive ...
  for i := 0 to len2 -1 do if dashes[0] <= 0 then v := 1;
  if (v <> 0) or (len2 < 2) or (len1 < 2) then
  begin
    setlength(result, 1);
    result[0] := pts;
    exit;
  end;

  for i := 0 to len2 -1 do v := v + dashes[i];
  dashOffset := dashes[0] - dashOffset;
  while dashOffset < 0 do dashOffset := dashOffset + v;
  while dashOffset >= v do dashOffset := dashOffset - v;

  dashIndex := 0;
  while dashOffset - dashes[dashIndex] > 0 do
  begin
    dashOffset := dashOffset - dashes[dashIndex];
    Inc(dashIndex);
  end;

  j := 0;
  offset := 0;
  SetLength(Result, 1);
  if not Odd(dashIndex) then AddPoint(pts[0].X, pts[0].Y);
  for i := 1 to len1 -1 do
    DashLine(pts[i-1], pts[i]);

  if closed then
  begin
    if not SamePoint(pts[0], pts[len1 -1]) then
      DashLine(pts[len1 -1], pts[0]);
    i := high(result);
    if Length(Result[i]) = 0 then
    begin
      SetLength(Result, i);
      dec(i);
    end;
    if SamePoint(result[i][high(result[i])], result[0][0]) then
    begin
      len1 := length(result[0]);
      len2 := length(result[i]);
      //join the 2 segments ...
      setlength(result[0], len1 + len2 -1);
      move(result[0][0], result[0][len2 -1], len1 * sizeof(TFixedPoint));
      move(result[i][0], result[0][0], (len2 -1) * sizeof(TFixedPoint));
      SetLength(result, i);
    end;
  end;
  i := high(result);
  if Length(Result[i]) = 0 then SetLength(Result, i);
end;
//------------------------------------------------------------------------------

function SegmentIntersect(const p1, p2, p3, p4: TFixedPoint;
  out IntersectPoint: TFixedPoint): boolean;
var
  m1,b1,m2,b2: TFloat;
begin
  result := false;
  if (p2.X = p1.X) then
  begin
    if (p4.X = p3.X) then exit; //parallel lines
    m2 := (p4.Y - p3.Y)/(p4.X - p3.X);
    b2 := p3.Y - m2 * p3.X;
    IntersectPoint.X := p1.X;
    IntersectPoint.Y := round(m2*p1.X + b2);
    result := (IntersectPoint.Y < p2.Y) = (IntersectPoint.Y > p1.Y);
  end
  else if (p4.X = p3.X) then
  begin
    m1 := (p2.Y - p1.Y)/(p2.X - p1.X);
    b1 := p1.Y - m1 * p1.X;
    IntersectPoint.X := p3.X;
    IntersectPoint.Y := round(m1*p3.X + b1);
    result := (IntersectPoint.Y < p3.Y) = (IntersectPoint.Y > p4.Y);
  end else
  begin
    m1 := (p2.Y - p1.Y)/(p2.X - p1.X);
    b1 := p1.Y - m1 * p1.X;
    m2 := (p4.Y - p3.Y)/(p4.X - p3.X);
    b2 := p3.Y - m2 * p3.X;
    if m1 = m2 then exit; //parallel lines
    IntersectPoint.X := round((b2 - b1)/(m1 - m2));
    IntersectPoint.Y := round(m1 * IntersectPoint.X + b1);
    result := ((IntersectPoint.X < p2.X) = (IntersectPoint.X > p1.X));
  end;
end;
//------------------------------------------------------------------------------

type
  TAngleType = (atParallel, atConvex, atConcave);

function GetAngleType(const normal1, normal2: TFloatPoint): TAngleType;
var
  val: TFloat;
begin
  val := normal1.X*normal2.Y-normal2.X*normal1.Y;;
  if val < 0 then result := atConcave
  else if val > 0 then result := atConvex
  else result := atParallel;
end;
//------------------------------------------------------------------------------

function GrowDashedLine(const lines: TArrayOfArrayOfFixedPoint;
  width: TFloat): TArrayOfArrayOfFixedPoint;
var
  i, j, highL: integer;
  lPts, rPts: TArrayOfFixedPoint;
  normals: TArrayOfFloatPoint;
  pt1: TFixedPoint;
  angleType: TAngleType;
begin
  width := abs(width)/2;
  setlength(result, length(lines));
  for i := 0 to high(lines) do
  begin
    highL := high(lines[i]);
    if highL < 1 then
    begin
      result[i] := nil;
      continue;
    end;
    setlength(lPts, highL*2);
    setlength(rPts, highL*2);

    lPts[0] := lines[i][0];
    rPts[0]  := lines[i][0];
    lPts[highL*2-1] := lines[i][highL];
    rPts[highL*2-1]  := lines[i][highL];
    for j := 1 to highL-1 do
    begin
      lPts[j*2-1] := lines[i][j];
      lPts[j*2]   := lines[i][j];
      rPts[j*2-1]  := lines[i][j];
      rPts[j*2]    := lines[i][j];
    end;
    setlength(normals, highL);
    for j := 0 to highL -1 do
      normals[j] := GetUnitNormal(lines[i][j],lines[i][j+1]);

    //offset the first and last points ...
    with normals[0] do OffsetPoint(lPts[0], X*width, Y*width);
    with normals[0] do OffsetPoint(rPts[0], -X*width, -Y*width);
    with normals[highL-1] do OffsetPoint(lPts[highL*2-1], X*width, Y*width);
    with normals[highL-1] do OffsetPoint(rPts[highL*2-1], -X*width, -Y*width);

    for j := 1 to highL-1 do
    begin
      angleType := GetAngleType(normals[j-1], normals[j]);

      with normals[j-1] do OffsetPoint(lPts[j*2-1], X*width, Y*width);
      with normals[j]   do OffsetPoint(lPts[j*2], X*width, Y*width);

      if angleType = atConcave then
      begin
        if SegmentIntersect(lPts[j*2-2],lPts[j*2-1],lPts[j*2],lPts[j*2+1], pt1) then
        begin
          lPts[j*2-1] := pt1;
          lPts[j*2]   := pt1;
        end
        //the angle is too narrow for segments to intersect ...
        else if (highL = 2) and
          SegmentIntersect(lPts[0],rPts[0],rPts[3],lPts[3], pt1) then
        begin
          lPts[0] := pt1;
          lPts[1] := pt1;
          lPts[2] := pt1;
          lPts[3] := pt1;
        end else
        begin
          if ((pt1.X >= lPts[j*2-2].X) = (pt1.X <= lPts[j*2-1].X)) and
            ((pt1.Y >= lPts[j*2-2].Y) = (pt1.Y <= lPts[j*2-1].Y)) then
              lPts[j*2-1] := pt1 else
              lPts[j*2-1] := lPts[j*2-2];
          if ((pt1.X >= lPts[j*2].X) = (pt1.X <= lPts[j*2+1].X)) and
            ((pt1.Y >= lPts[j*2].Y) = (pt1.Y <= lPts[j*2+1].Y)) then
              lPts[j*2] := pt1 else
              lPts[j*2] := lPts[j*2-1];
        end;
      end;

      with normals[j-1] do OffsetPoint(rPts[j*2-1], -X*width, -Y*width);
      with normals[j] do OffsetPoint(rPts[j*2], -X*width, -Y*width);

      if angleType = atConvex then
      begin
        if SegmentIntersect(rPts[j*2-2],rPts[j*2-1],rPts[j*2],rPts[j*2+1],pt1) then
        begin
          rPts[j*2-1] := pt1;
          rPts[j*2]   := pt1;
        end
        //the angle is too narrow for segments to intersect ...
        else if (highL = 2) and
          SegmentIntersect(lPts[0],rPts[0],rPts[3],lPts[3],pt1) then
        begin
          rPts[0] := pt1;
          rPts[1] := pt1;
          rPts[2] := pt1;
          rPts[3] := pt1;
        end else
        begin
          if ((pt1.X > rPts[j*2-2].X) = (pt1.X < rPts[j*2-1].X)) and
            ((pt1.Y > rPts[j*2-2].Y) = (pt1.Y < rPts[j*2-1].Y)) then
              rPts[j*2-1] := pt1 else
              rPts[j*2-1] := rPts[j*2-2];
          if ((pt1.X > rPts[j*2].X) = (pt1.X < rPts[j*2+1].X)) and
            ((pt1.Y > rPts[j*2].Y) = (pt1.Y < rPts[j*2+1].Y)) then
              rPts[j*2] := pt1 else
              rPts[j*2] := rPts[j*2-1];
        end;
      end;
    end;
    setlength(result[i], highL*4);
    move(lPts[0], result[i][0], highL*2 *sizeof(TFixedPoint));
    for j := 0 to highL*2 -1 do
      result[i][highL*4-1 -j] := rPts[j];
  end;
end;

//------------------------------------------------------------------------------
// TGrowBase methods ...
//------------------------------------------------------------------------------

procedure TGrowBase.Grow(const pts: array of TFixedPoint; lineWidth: single;
  joinStyle: TJoinStyle; miterLimit: single; isClosed: boolean);
var
  I, prevI, nextI, highI: cardinal;
  halfLW, RMin: single;
  P: TFloatPoint;
  normals: TArrayOfFloatPoint;
  normalA, normalB: TFloatPoint;
  firstLeftPt, firstRightPt: boolean;
  closedLeft, closedRight: TFixedPoint;

  //todo - better bevelling (ie bevelling up to miterlimit)

  procedure DoAddLeft(const pt: TFixedPoint);
  begin
    if firstLeftPt then
    begin
      firstLeftPt := false;
      closedLeft := pt;
    end;
    AddLeft(I, pt);
  end;

  procedure DoAddRight(const pt: TFixedPoint);
  begin
    if firstRightPt then
    begin
      firstRightPt := false;
      closedRight := pt;
    end;
    AddRight(I, pt);
  end;

  function GetPerpendicularPt(const pt: TFixedPoint;
     const normal: TFloatPoint; dist: single): TFixedPoint; overload;
  begin
    with FloatPoint(pt) do
      result := FixedPoint(X + normal.X * dist, Y + normal.Y * dist);
  end;

  function GetPerpendicularPt(const pt, normal:
    TFloatPoint; dist: single): TFixedPoint; overload;
  begin
    result := FixedPoint(pt.X + normal.X * dist, pt.Y + normal.Y * dist);
  end;

  function GetVectorPt(const pt: TFixedPoint;
     const normal: TFloatPoint; dist: single): TFixedPoint;
  begin
    //nb: undoes the 'normal' before applying dist to pt ...
    with FloatPoint(pt) do
      result := FixedPoint(X - normal.Y * dist, Y + normal.X * dist);
  end;

  procedure AddLeftMiter(const N1, N2: TFloatPoint; dist: single);
  var
    R, L1, L2: single;
    angleIsConcave: boolean;
    pt, NextP, PrevP: TFixedPoint;
  begin
    //(N1.X * N2.Y - N2.X * N1.Y) == unit normal "cross product" == sin(angle)
    //http://en.wikipedia.org/wiki/Cross_product  
    //used here to find if an angle is greater than or less than 180?
    angleIsConcave := (N1.X * N2.Y - N2.X * N1.Y) * dist < 0;
    //(N1.X * N2.X + N1.Y * N2.Y) == unit normal "dot product" == cos(angle)
    //http://en.wikipedia.org/wiki/Dot_product
    //R = 1 + cos(angle). 0 <= R <= 2.
    //R --> 0 as angle --> -180?or as angle --> 180?
    R := 1 + (N1.X*N2.X + N1.Y*N2.Y);
    if angleIsConcave and (R <> 0) then
    begin
      //Sometimes an inner miter can 'pop out' between the lines constructing
      //the miter. This happens when the angle between those lines is narrow
      //and those lines are short relative to their widths. The code below tests
      //for and fixes proposed miter points that are further from the current
      //point than either of the adjacent points used to construct the miter ...
      NextP := GetPerpendicularPt(pts[NextI], normals[I], dist);
      PrevP := GetPerpendicularPt(pts[PrevI], normals[PrevI], dist);
      //it's a few less CPU cycles to get squared distances ...
      L1 := SquaredDistBetweenPoints(PrevP, pts[I]);
      L2 := SquaredDistBetweenPoints(NextP, pts[I]);
      R := dist / R;
      pt := FixedPoint(P.X + (N1.X+N2.X)*R, P.Y + (N1.Y+N2.Y)*R);
      R := SquaredDistBetweenPoints(pt, pts[I]);
      //This extra code better manages acutely angled miters so that an
      //outline of the line is more accurately drawn ...
      if (R > L1) and (L1 <= L2) then
      begin
        if (L1 = L2) then exit;
        //to get here the prior line is shorter than the following one so ...
        //using the length of the prior line (L1), find the point on the
        //following line that's L1 distant from the angle point, then from that
        //point find the point that's perpendicular ?linewidth (dist).
        L1 := DistBetweenPoints(pts[PrevI], pts[I]);
        pt := GetVectorPt(pts[I], N2, L1);
        DoAddLeft(GetPerpendicularPt(pt, N2, dist));
      end
      else if (R > L2) then
      begin
        L2 := DistBetweenPoints(pts[NextI], pts[I]);
        pt := GetVectorPt(pts[I], N1, -L2);
        DoAddLeft(GetPerpendicularPt(pt, N1, dist));
      end else
        DoAddLeft(pt);
    end
    else if (R < RMin) then
    begin
      DoAddLeft(GetPerpendicularPt(P, N1, dist));
      DoAddLeft(GetPerpendicularPt(P, N2, dist));
    end else
    begin
      R := dist / R;
      pt := FixedPoint(P.X + (N1.X+N2.X)*R, P.Y + (N1.Y+N2.Y)*R);
      DoAddLeft(pt);
    end;
  end;

  procedure AddRightMiter(const N1, N2: TFloatPoint; dist: single);
  var
    R, L1, L2: single;
    angleIsConcave: boolean;
    pt, NextP, PrevP: TFixedPoint;
  begin
    angleIsConcave := (N1.X * N2.Y - N2.X * N1.Y) * dist < 0;
    //R --> 0 as angle --> -180?and as angle --> 180?
    R := 1 + N1.X*N2.X + N1.Y*N2.Y;
    if angleIsConcave and (R <> 0) then
    begin
      NextP := GetPerpendicularPt(pts[NextI], normals[I], dist);
      PrevP := GetPerpendicularPt(pts[PrevI], normals[PrevI], dist);
      L1 := SquaredDistBetweenPoints(PrevP, pts[I]);
      L2 := SquaredDistBetweenPoints(NextP, pts[I]);
      R := dist / R;
      pt := FixedPoint(P.X + (N1.X+N2.X)*R, P.Y + (N1.Y+N2.Y)*R);
      R := SquaredDistBetweenPoints(pt, pts[I]);
      if (R > L1) and (L1 <= L2) then
      begin
        L1 := DistBetweenPoints(pts[PrevI], pts[I]);
        pt := GetVectorPt(pts[I], N2, L1);
        DoAddRight(GetPerpendicularPt(pt, N2, dist));
      end
      else if (R > L2) then
      begin
        L2 := DistBetweenPoints(pts[NextI], pts[I]);
        pt := GetVectorPt(pts[I], N1, -L2);
        DoAddRight(GetPerpendicularPt(pt, N1, dist));
      end else
        DoAddRight(pt);
    end
    else if (R < RMin) then
    begin
      DoAddRight(GetPerpendicularPt(P, N1, dist));
      DoAddRight(GetPerpendicularPt(P, N2, dist));
    end else
    begin
      R := dist / R;
      pt := FixedPoint(P.X + (N1.X+N2.X)*R, P.Y + (N1.Y+N2.Y)*R);
      DoAddRight(pt);
    end;
  end;

  procedure AddLeftBevel(const N1, N2: TFloatPoint; dist: single);
  var
    angleIsConcave: boolean;
  begin
    angleIsConcave := (N1.X * N2.Y - N2.X * N1.Y) * dist < 0;
    if not angleIsConcave then
    begin
      DoAddLeft(GetPerpendicularPt(P, N1, dist));
      DoAddLeft(GetPerpendicularPt(P, N2, dist));
    end
    else
      AddLeftMiter(N1, N2, dist);
  end;

  procedure AddRightBevel(const N1, N2: TFloatPoint; dist: single);
  var
    angleIsConcave: boolean;
  begin
    angleIsConcave := (N1.X * N2.Y - N2.X * N1.Y) * dist < 0;
    if not angleIsConcave then
    begin
      DoAddRight(GetPerpendicularPt(P, N1, dist));
      DoAddRight(GetPerpendicularPt(P, N2, dist));
    end
    else
      AddRightMiter(N1, N2, dist);
  end;

  procedure AddLeftRound(const N1, N2: TFloatPoint; dist: single);
  var
    angleIsConcave: boolean;
    a1, a2: TFloat;
    arc: TArrayOfFixedPoint;
    J: integer;
  begin
    angleIsConcave := (N1.X*N2.Y - N2.X*N1.Y) * dist < 0;
    if not angleIsConcave then
    begin
      a1 := ArcTan2(N1.Y, N1.X);
      a2 := ArcTan2(N2.Y, N2.X);
      if a2 = a1 then exit //ie parallel line
      else if a2 < a1 then a2 := a2 + rad360;
      arc := BuildArc(P, a1, a2, dist);
      for J := 0 to high(arc) do DoAddLeft(arc[J]);
    end else
      AddLeftMiter(N1, N2, dist);
  end;

  procedure AddRightRound(const N1, N2: TFloatPoint; dist: single);
  var
    angleIsConcave: boolean;
    a1, a2: TFloat;
    arc: TArrayOfFixedPoint;
    J: integer;
  begin
    angleIsConcave := (N1.X*N2.Y - N2.X*N1.Y) * dist < 0;
    if not angleIsConcave then
    begin
      a1 := ArcTan2(N1.Y, N1.X);
      a2 := ArcTan2(N2.Y, N2.X);
      if a2 = a1 then exit //ie parallel line
      else if a2 > a1 then a2 := a2 - rad360;
      arc := BuildArc(P, a1, a2, dist);
      for J := 0 to high(arc) do DoAddRight(arc[J]);
    end else
      AddRightMiter(N1, N2, dist);
  end;

begin
  if (length(pts) < 2) or (LineWidth < 1) then exit;
  isClosed := isClosed and (length(pts) > 2);

  OnStart;

  //for 'closed' lines we need to save the first points ...
  firstLeftPt := true;
  firstRightPt := true;

  halfLW := LineWidth/2;
  if miterLimit < 1 then
  begin
    miterLimit := 1;
    if joinStyle = jsMitered then joinStyle := jsBevelled;
  end;
  RMin := 2/sqr(miterLimit); //val == max relative distance of join pt from pt

  //make Normals ...
  highI := high(pts);
  if isClosed and IsDuplicatePoint(pts[0], pts[highI]) then dec(highI);
  setLength(normals, highI +1);
  for I := 0 to highI -1 do
    normals[I] := GetUnitNormal(pts[I],pts[I+1]);
  normals[highI] := GetUnitNormal(pts[highI],pts[0]);

  if isClosed then
    PrevI := HighI else
    PrevI := 0;

  for I := 0 to HighI do
  begin
    normalA := normals[PrevI];
    P := FloatPoint(pts[I]);

    if ((I = 0) or (I = highI)) and not isClosed then
    begin 
      DoAddLeft(GetPerpendicularPt(P, normalA, halfLW));
      DoAddRight(GetPerpendicularPt(P, normalA, -halfLW));
      continue;
    end;

    if i = highI then
      nextI := 0 else
      nextI := i+1;

    normalB := normals[I];
    case JoinStyle of
      jsBevelled:
        begin
          AddLeftBevel(normalA, normalB, halfLW);
          AddRightBevel(normalA, normalB, -halfLW);
        end;
      jsMitered:
        begin
          AddLeftMiter(normalA, normalB, halfLW);
          AddRightMiter(normalA, normalB, -halfLW);
        end;
      jsRounded:
        begin
          AddLeftRound(normalA, normalB, halfLW);
          AddRightRound(normalA, normalB, -halfLW);
        end;
    end;
    PrevI := I;
  end;

  if isClosed then
  begin
      DoAddLeft(closedLeft);
      DoAddRight(closedRight);
  end;

  OnFinish;
end;
//------------------------------------------------------------------------------

procedure TGrowBase.OnStart;
begin
end;
//------------------------------------------------------------------------------

procedure TGrowBase.OnFinish;
begin
end;


//------------------------------------------------------------------------------
// TGrow methods ...
//------------------------------------------------------------------------------

constructor TGrow.Create(LeftPts, RightPts: PArrayOfFixedPoint);
begin
  inherited Create;
  fLeftPts := LeftPts;
  fRightPts := RightPts;
  buffSizeIncrement := 128;
  //this allows TGrow to append to LeftPts & RightPts ...
  leftLen := length(fLeftPts^);
  leftBuffLen := leftLen;
  rightLen := Length(fRightPts^);
  rightBuffLen := rightLen;
end;
//------------------------------------------------------------------------------

procedure TGrow.AddLeft(idx: integer; const pt: TFixedPoint);
begin
  if leftLen >= leftBuffLen then
  begin
    inc(leftBuffLen, buffSizeIncrement);
    setLength(fLeftPts^, leftBuffLen);
  end;
  fLeftPts^[leftLen] := pt;
  inc(leftLen);
end;
//------------------------------------------------------------------------------

procedure TGrow.AddRight(idx: integer; const pt: TFixedPoint);
begin
  if rightLen >= rightBuffLen then
  begin
    inc(rightBuffLen, buffSizeIncrement);
    setLength(fRightPts^, rightBuffLen);
  end;
  fRightPts^[rightLen] := pt;
  inc(rightLen);
end;
//------------------------------------------------------------------------------

procedure TGrow.OnFinish;
begin
  //trim excess buffers ...
  setLength(fLeftPts^, leftLen);
  setLength(fRightPts^, rightLen);
end;

//------------------------------------------------------------------------------
// TStippledGrow methods ...
//------------------------------------------------------------------------------

constructor TStippledGrow.Create(LeftPts, RightPts: PArrayOfFixedPoint);
begin
  inherited;
  fList := TList.Create;
end;
//------------------------------------------------------------------------------

destructor TStippledGrow.Destroy;
begin
  Clear;
  fList.free;
  inherited;
end;
//------------------------------------------------------------------------------

procedure TStippledGrow.Clear;
var
  i: integer;
begin
  for i := 0 to fList.Count -1 do Dispose(PStippleItem(fList[i]));
  fList.clear;
end;
//------------------------------------------------------------------------------

function TStippledGrow.Count: integer;
begin
  result := fList.Count;
end;
//------------------------------------------------------------------------------

function TStippledGrow.GetItem(index: integer): PStippleItem;
begin
  if (index < 0) or (index >= fList.Count) then
    raise Exception.Create('TStippledGrow.GetItem range error');
  result := PStippleItem(fList[index]);
end;
//------------------------------------------------------------------------------

procedure TStippledGrow.AddLeft(idx: integer; const pt: TFixedPoint);
var
  len: integer;
  stippleItem: PStippleItem;
begin
  inherited;
  if idx <> fCurrentIndex then
  begin
    fCurrentIndex := idx;
    New(stippleItem);
    fList.Add(stippleItem);
  end else
    stippleItem := PStippleItem(fList[fList.count -1]);
  len := length(stippleItem.left);
  setLength(stippleItem.left, len+1);
  stippleItem.left[len] := pt;
end;
//------------------------------------------------------------------------------

procedure TStippledGrow.AddRight(idx: integer; const pt: TFixedPoint);
var
  len: integer;
  stippleItem: PStippleItem;
begin
  inherited;
  if idx <> fCurrentIndex then
  begin
    fCurrentIndex := idx;
    New(stippleItem);
    fList.Add(stippleItem);
  end else
    stippleItem := PStippleItem(fList[fList.count -1]);
  len := length(stippleItem.right);
  setLength(stippleItem.right, len+1);
  stippleItem.right[len] := pt;
end;
//------------------------------------------------------------------------------

procedure TStippledGrow.OnStart;
begin
  fCurrentIndex := -1;
  Clear;
end;

//------------------------------------------------------------------------------
// TArrowPen methods ...
//------------------------------------------------------------------------------

constructor TArrowPen.Create(owner: TArrowHead);
begin
  fOwnerArrowHead := owner;
  fColor := clBlack32;
  fWidth  := 1;
end;
//------------------------------------------------------------------------------

procedure TArrowPen.SetWidth(value: single);
begin
  Constrain(value, 1, 10);
  if value = fWidth then exit;
  fWidth := value;
  fOwnerArrowHead.fOwnerLine32.ForceRebuild;
end;

//------------------------------------------------------------------------------
// TArrowHead methods ...
//------------------------------------------------------------------------------

constructor TArrowHead.Create(owner: TLine32; IsStartArrow: boolean);
begin
  fOwnerLine32 := owner;
  fIsStartArrow := IsStartArrow;
  fStyle := asNone;
  fSize := 12;
  fColor := clWhite32;
  fPen := TArrowPen.Create(self);
end;
//------------------------------------------------------------------------------

destructor TArrowHead.Destroy;
begin
  fPen.Free;
  inherited;
end;
//------------------------------------------------------------------------------

procedure TArrowHead.SetSize(value: single);
begin
  Constrain(value, 1, 50);
  if value = fSize then exit;
  fSize := value;
  fOwnerLine32.ForceRebuild;
end;
//------------------------------------------------------------------------------

procedure TArrowHead.SetStyle(value: TArrowHeadStyle);
begin
  if (value = fStyle) then exit;
  fStyle := value;
  fOwnerLine32.ForceRebuild;
end;
//------------------------------------------------------------------------------

procedure TArrowHead.SetCustomProc(value: TCustomArrowHeadProc);
begin
  fCustomProc := value;
  if not assigned(value) and (fStyle = asCustom) then fStyle := asNone;
  fOwnerLine32.ForceRebuild;
end;
//------------------------------------------------------------------------------

function TArrowHead.IsNeeded: boolean;
begin
  with fOwnerLine32 do
    result := ((length(fLinePoints) >= 2) and (fEndStyle <> esClosed)) and
    ((Style in [asThreePoint,asFourPoint,asSquare,asDiamond,asCircle]) or
    ((Style = asCustom) and assigned(fCustomProc)));
end;
//------------------------------------------------------------------------------

function TArrowHead.GetTipAndBase: boolean;
var
  endI: integer;
  totalDist, cumulativeDist: single;
begin
  cumulativeDist := 0;
  totalDist := Size + Pen.Width;
  with fOwnerLine32 do
  begin
    endI := high(fLinePoints);
    if endI < 0 then
      fTipPoint := FixedPoint(0,0)
    else if fIsStartArrow then
    begin
      fTipPoint := fLinePoints[0];
      fBaseIdx := 0;
    end else
    begin
      fTipPoint := fLinePoints[endI];
      fBaseIdx := endI;
    end;
    fBasePoint := fTipPoint;

    result := IsNeeded;
    if not result then exit;

    if fIsStartArrow then
    begin
      //find the last point still covered by the arrow ...
      while (fBaseIdx < endI -1) do
      begin
        cumulativeDist := cumulativeDist +
          DistBetweenPoints(fLinePoints[fBaseIdx], fLinePoints[fBaseIdx+1]);
        if cumulativeDist > totalDist then break;
        inc(fBaseIdx);
      end;
      //now, use the angle between the arrow tip point and the first point in
      //the line not covered by the arrow to derive the base point ...
      fBasePoint := GetPointAtAngleFromPoint(fLinePoints[0], totalDist,
        GetAngleOfPt2FromPt1(fLinePoints[0], fLinePoints[fBaseIdx+1]));
    end else
    begin
      while (fBaseIdx > 1) do
      begin
        cumulativeDist := cumulativeDist +
          DistBetweenPoints(fLinePoints[fBaseIdx], fLinePoints[fBaseIdx-1]);
        if cumulativeDist > totalDist then break;
        dec(fBaseIdx);
      end;
      fBasePoint := GetPointAtAngleFromPoint(fLinePoints[endI], totalDist,
        GetAngleOfPt2FromPt1(fLinePoints[endI], fLinePoints[fBaseIdx-1]));
    end;
  end;
end;
//------------------------------------------------------------------------------

//GetArrowHeadPoints: used by TArrowHead.GetPoints to draw specific arrow head styles
function GetArrowHeadPoints(tipPt, tailPt: TFixedPoint; HeadSize, PenWidth: single;
  ArrowHeadStyle: TArrowHeadStyle): TArrayOfFixedPoint;
var
  angle, d: single;
  floatPt: TFloatPoint;
  fr: TFloatRect;
const
  CosThirty    = 0.86602540;
  TanSixty     = 1.73205081;
begin
  result := nil;
  angle := GetAngleOfPt2FromPt1(tipPt,tailPt); //angle to tail
  case ArrowHeadStyle of
    asThreePoint:
      begin
        setLength(result,3);
        d := HeadSize/TanSixty;
        result[0] := GetPointAtAngleFromPoint(tailPt, d, angle + rad90);
        result[1] := tipPt;
        result[2] := GetPointAtAngleFromPoint(tailPt, d, angle - rad90);
      end;
    asFourPoint:
      begin
        setLength(result,4);
        d := HeadSize/TanSixty;
        result[0] := tailPt;
        result[1] := GetPointAtAngleFromPoint(tailPt, d, angle + rad60);
        result[2] := tipPt;
        result[3] := GetPointAtAngleFromPoint(tailPt, d, angle - rad60);
      end;
    asDiamond:
      begin
        setLength(result,5);
        d := (HeadSize/2)/CosThirty;
        result[0] := GetPointAtAngleFromPoint(tailPt, (PenWidth-1)/2, angle - rad90);
        result[1] := GetPointAtAngleFromPoint(tailPt, d, angle - rad180 + rad30);
        result[2] := tipPt;
        result[3] := GetPointAtAngleFromPoint(tailPt, d, angle - rad180 - rad30);
        result[4] := GetPointAtAngleFromPoint(tailPt, (PenWidth-1)/2, angle + rad90);
      end;
    asSquare:
      begin
        setLength(result,4);
        floatPt := FloatPoint(MidPoint(tipPt,tailPt));
        d := HeadSize/2;
        result[0] := FixedPoint(floatPt.X-d, floatPt.Y-d) ;
        result[1] := FixedPoint(floatPt.X+d, floatPt.Y-d) ;
        result[2] := FixedPoint(floatPt.X+d, floatPt.Y+d) ;
        result[3] := FixedPoint(floatPt.X-d, floatPt.Y+d) ;
      end;
    asCircle:
      begin
        d := HeadSize/2;
        with FloatPoint(MidPoint(tipPt,tailPt)) do
          fr := FloatRect(X-d,Y-d,X+d,Y+d);
        result := GetEllipsePoints(fr);
      end;
  end;
end;
//------------------------------------------------------------------------------

function TArrowHead.GetPoints: TArrayOfFixedPoint;
begin
  result := nil;
  if GetTipAndBase then
    case Style of
      asThreePoint, asFourPoint, asSquare, asDiamond, asCircle:
        result := GetArrowHeadPoints(fTipPoint, fBasePoint,
          Size, fOwnerLine32.fLineWidth, Style);
      asCustom:
        if assigned(CustomProc) then
          result := CustomProc(fTipPoint, fBasePoint,
            Size, fOwnerLine32.fLineWidth, Style);
    end;
end;
//------------------------------------------------------------------------------

function TArrowHead.OutlinePoints(delta: single): TArrayOfFixedPoint;
var
  pts: TArrayOfFixedPoint;
begin
  pts := GetPoints;
  if length(pts) > 0 then
    result := OutlineClosedPoints(pts, pen.fWidth+delta, true);
end;
//------------------------------------------------------------------------------

procedure TArrowHead.Draw(bitmap: TBitmap32);
var
  pts: TArrayOfFixedPoint;
begin
  if (Style = asNone) or (Size < 4) or not assigned(bitmap) then exit;
  pts := GetPoints;
  if length(pts) = 0 then exit;

  with fOwnerLine32.fPolygon32 do
  begin
    Clear;
    AddPoints(pts[0],length(pts));
    FillMode := pfWinding;
    DrawFill(bitmap, Color);
    if Pen.fWidth < SingleLineLimit then
      DrawEdge(bitmap, Pen.Color)
    else
    begin
      pts := OutlineClosedPoints(pts, Pen.fWidth);
      Clear;
      if pts = nil then exit;
      AddPoints(pts[0],length(pts));
      DrawFill(bitmap, Pen.Color);
    end;
  end;
end;

//------------------------------------------------------------------------------
// TLine32 methods ...
//------------------------------------------------------------------------------

constructor TLine32.Create;
begin
  FillMode := pfWinding;

  fPolygon32 := {$IFDEF GR32_PolygonsEx} TPolygon32Ex. {$ELSE} TPolygon32. {$ENDIF} Create;
  fPolygon32.Closed := true;
  fPolygon32.Antialiased := true;
  fPolygon32.AntialiasMode := am16times;

  fLineWidth := 1;
  fMiterLimit := 2;
  EndStyle := esButt;
  fJoinStyle := jsBevelled;

  fStartArrow := TArrowHead.Create(self, true);
  fEndArrow := TArrowHead.Create(self, false);
end;
//------------------------------------------------------------------------------

destructor TLine32.Destroy;
begin
  Clear;
  fStartArrow.Free;
  fEndArrow.Free;
  fPolygon32.Free;
  inherited;
end;
//------------------------------------------------------------------------------

{$IFNDEF GR32_PolygonsEx}
function TLine32.GetAntialiasMode: TAntialiasMode;
begin
  result := fPolygon32.AntialiasMode;
end;
//------------------------------------------------------------------------------

procedure TLine32.SetAntialiasMode(aaMode: TAntialiasMode);
begin
  fPolygon32.AntialiasMode := aaMode;
end;
//------------------------------------------------------------------------------
{$ENDIF}

procedure TLine32.ForceRebuild;
begin
  fLeftPoints := nil;
  fRightPoints := nil;
end;
//------------------------------------------------------------------------------

procedure TLine32.Clear;
begin
  fLinePoints := nil;
  fLeftPoints := nil;
  fRightPoints := nil;
end;
//------------------------------------------------------------------------------

procedure TLine32.SetPoints(const pts: array of TFixedPoint);
var
  i, cnt: integer;
begin
  Clear;
  cnt := 0;
  setLength(fLinePoints, length(pts));
  for i := 0 to High(pts) do
  begin
    //ignore duplicate points which otherwise can create artefacts ...
    if (cnt > 0) and IsDuplicatePoint(pts[i], fLinePoints[cnt-1]) then continue;
    fLinePoints[cnt] := pts[i];
    inc(cnt);
  end;
  setLength(fLinePoints, cnt);
end;
//------------------------------------------------------------------------------

function TLine32.AddPoints(const newPts: array of TFixedPoint;
  ToEnd: boolean = true): cardinal;
var
  i, bottom, top, len, cnt, cnt2: integer;
  pt: TFixedPoint;
begin
  len := length(fLinePoints);
  if len = 0 then
  begin
    SetPoints(newPts);
    result := length(fLinePoints);
    exit;
  end;

  result := 0;
  bottom := 0;
  top := high(NewPts);
  ForceRebuild;

  //skip any adjacent duplicates ...
  if ToEnd then
  begin
    Pt := fLinePoints[len -1];
    while (bottom <= top) and IsDuplicatePoint(newPts[bottom], Pt) do inc(bottom);
    if bottom > top then exit;
    setLength(fLinePoints, len + top - bottom +1);
    cnt := len;
    for i := bottom to top do
      if IsDuplicatePoint(newPts[i], fLinePoints[cnt-1]) then
        continue
      else
      begin
        fLinePoints[cnt] := newPts[i];
        inc(cnt);
        inc(result);
      end;
      setLength(fLinePoints, cnt);
  end else
  begin
    Pt := fLinePoints[0];
    while (top >= bottom) and IsDuplicatePoint(newPts[top], Pt) do dec(top);
    if bottom > top then exit;
    cnt := top - bottom +1;
    setLength(fLinePoints, len + cnt);
    //make room for the new points at the beginning of the array ...
    move(fLinePoints[0],fLinePoints[cnt], len * sizeof(TFixedPoint));
    //now add the new points ...
    cnt2 := 0;
    for i := bottom to top do
    begin
      if (cnt2 > 0) and IsDuplicatePoint(newPts[i], fLinePoints[cnt2 -1]) then
      begin
        continue;
      end else
      begin
        fLinePoints[cnt2] := newPts[i];
        inc(cnt2);
        inc(result);
      end;
      if cnt2 < cnt then
      begin
        move(fLinePoints[cnt], fLinePoints[cnt2], len * sizeof(TFixedPoint));
        setLength(fLinePoints, length(fLinePoints) - (cnt - cnt2));
      end;
    end;
  end;
end;
//------------------------------------------------------------------------------

function TLine32.AddPoints(var startPt: TFixedPoint; count: integer;
  ToEnd: boolean = true): cardinal;
var
  i: integer;
  newPts: array of TFixedPoint;
begin
  result := 0;
  if count <= 0 then exit;
  setlength(newPts, count);
  {$R-}
  for i := 0 to count - 1 do
    newPts[i] := PFixedPointArray(@startPt)[i];
  result := AddPoints(newPts, ToEnd);
  {$R+}
end;
//------------------------------------------------------------------------------

procedure TLine32.DeletePoints(count: integer; FromEnd: boolean = true);
var
  len: integer;
begin
  len := length(fLinePoints);
  if count >= len then
  begin
    clear;
    exit;
  end;

  ForceRebuild;
  if not FromEnd then
    move(fLinePoints[count], fLinePoints[0], (len - count) * sizeof(TFixedPoint));
  setLength(fLinePoints, len - count);
end;
//------------------------------------------------------------------------------

function TLine32.GetBoundsRect(penWidth: single = 0): TRect;
begin
  result := MakeRect(GetBoundsFixedRect(penWidth),rrOutside);
end;
//------------------------------------------------------------------------------

function TLine32.GetBoundsFixedRect(penWidth: single = 0): TFixedRect;
var
  fpa: TArrayOfFixedPoint;
begin
  fpa := GetOuterEdge(penWidth);
  result := gr32_misc.GetBoundsFixedRect(fpa);
end;
//------------------------------------------------------------------------------

procedure TLine32.Translate(dx,dy: TFloat);
var
  i: integer;
  delta: TFixedPoint;
begin
  ForceRebuild;
  delta := FixedPoint(dx,dy);
  for i := 0 to high(fLinePoints) do
    with fLinePoints[i] do
    begin
      X := X + delta.X;
      Y := Y + delta.Y;
    end;
end;
//------------------------------------------------------------------------------

procedure TLine32.Scale(dx,dy: TFloat);
var
  i: integer;
begin
  ForceRebuild;
  for i := 0 to high(fLinePoints) do
    with fLinePoints[i] do
    begin
      X := round(X * dx);
      Y := round(Y * dy);
    end;
end;
//------------------------------------------------------------------------------

procedure TLine32.Rotate(origin: TFloatPoint; radians: single);
var
  i: integer;
  orig, tmp: TFixedPoint;
  cosAng, sinAng: single;
begin
  ForceRebuild;
  //rotates in an anticlockwise direction if radians > 0;
  Math.sincos(radians, sinAng, cosAng);
  orig := FixedPoint(origin);
  for i := 0 to high(fLinePoints) do
    with fLinePoints[i] do
    begin
      tmp.X := X - orig.X;
      tmp.Y := Y - orig.Y;
      X := round((tmp.X * cosAng) + (tmp.Y * sinAng) + orig.X);
      Y := round((tmp.Y * cosAng) - (tmp.X * sinAng) + orig.Y);
    end;
end;
//------------------------------------------------------------------------------

procedure TLine32.Transform(matrix : TFloatMatrix);
var
  i : integer;
  mx, my : single;
begin
  ForceRebuild;
  for i := 0 to high(fLinePoints) do
    with fLinePoints[i] do
    begin
      mx := X *FixedToFloat;
      my := Y *FixedToFloat;
      X := round((mx*matrix[0,0] + my*matrix[1,0] + matrix[2,0])*FixedOne);
      Y := round((mx*matrix[0,1] + my*matrix[1,1] + matrix[2,1])*FixedOne);
    end;
end;
//------------------------------------------------------------------------------

function TLine32.GetArrowTruncatedPoints: TArrayOfFixedPoint;
var
  len: integer;
begin
  //Returns the line points trimmed to accommodate any arrows.
  //Lines needs to be trimmed in case arrow fills are semi-transparent.
  result := nil;
  if length(fLinePoints) = 0 then exit;

  fStartArrow.GetTipAndBase;
  fEndArrow.GetTipAndBase;
  len := fEndArrow.BaseIdx - fStartArrow.BaseIdx +1;
  result := Copy(fLinePoints, fStartArrow.BaseIdx, len);
  result[0] := fStartArrow.Base;
  result[len-1] := fEndArrow.Base;
end;
//------------------------------------------------------------------------------

procedure TLine32.DrawArrows(bitmap: TBitmap32);
begin
  if (fStartArrow.Style <> asNone) then fStartArrow.Draw(bitmap);
  if (fEndArrow.Style <> asNone) then fEndArrow.Draw(bitmap);
end;
//------------------------------------------------------------------------------

procedure TLine32.Draw(bitmap: TBitmap32; penWidth: single;
  color: TColor32; edgeColor: TColor32 = $00000000);
var
  pts: TArrayOfFixedPoint;
begin
  if not assigned(bitmap) or (length(fLinePoints) < 2) then exit;

  pts := GetOutline(penWidth);
  if length(pts) = 0 then exit;
  fPolygon32.Clear;
  fPolygon32.AddPoints(pts[0],length(pts));
  fPolygon32.FillMode := self.FillMode;
  fPolygon32.DrawFill(bitmap, color);

  if AlphaComponent(edgeColor) <> $0 then
  begin
    if EndStyle = esClosed then
    begin
      SimpleLine(bitmap, fRightPoints, edgeColor, true);
      SimpleLine(bitmap, fLeftPoints, edgeColor, true);
    end
    else
      fPolygon32.DrawEdge(bitmap,edgeColor);
  end;
  DrawArrows(bitmap);
end;
//------------------------------------------------------------------------------

procedure TLine32.Draw(bitmap: TBitmap32; penWidth: single;
  pattern: TBitmap32; edgeColor: TColor32 = $00000000);
var
  filler: TBitmapPolygonFiller;
  pts: TArrayOfFixedPoint;
begin
  if not assigned(bitmap) or not assigned(pattern) or (length(fLinePoints) < 2) then exit;

  filler := TBitmapPolygonFiller.Create;
  try
    filler.Pattern := pattern;
    fPolygon32.Clear;
    pts := GetOutline(penWidth);
    if length(pts) = 0 then exit;
    fPolygon32.AddPoints(pts[0],length(pts));
    fPolygon32.FillMode := self.FillMode;
    fPolygon32.DrawFill(bitmap,filler);
  finally
    filler.Free;
  end;

  if AlphaComponent(edgeColor) <> $0 then
  begin
    if EndStyle = esClosed then
    begin
      SimpleLine(bitmap, GetRightPoints, edgeColor, true);
      SimpleLine(bitmap, GetLeftPoints, edgeColor, true);
    end
    else
      fPolygon32.DrawEdge(bitmap,edgeColor);
  end;
  DrawArrows(bitmap);
end;
//------------------------------------------------------------------------------

procedure TLine32.Draw(bitmap: TBitmap32; penWidth: single;
  filler: TCustomPolygonFiller; edgeColor: TColor32 = $00000000);
var
  pts: TArrayOfFixedPoint;
begin
  if not assigned(bitmap) or not assigned(filler) or (length(fLinePoints) < 2) then exit;
  fPolygon32.Clear;
  pts := GetOutline(penWidth);
  if length(pts) = 0 then exit;
  fPolygon32.AddPoints(pts[0],length(pts));
  fPolygon32.FillMode := self.FillMode;
  fPolygon32.DrawFill(bitmap, filler);

  if AlphaComponent(edgeColor) <> $0 then
  begin
    if EndStyle = esClosed then
    begin
      SimpleLine(bitmap, GetRightPoints, edgeColor, true);
      SimpleLine(bitmap, GetLeftPoints, edgeColor, true);
    end
    else
      fPolygon32.DrawEdge(bitmap, edgeColor);
  end;
  DrawArrows(bitmap);
end;
//------------------------------------------------------------------------------

procedure TLine32.Draw(bitmap: TBitmap32; penWidth: single; colors: array of TColor32);
begin
  Draw(bitmap, penWidth, colors, -2); //nb: StippleStep < -1 ==> use current stipplestep
end;
//------------------------------------------------------------------------------

procedure TLine32.Draw(bitmap: TBitmap32; penWidth: single;
  colors: array of TColor32; StippleStep: single);
var
  pts: TArrayOfFixedPoint;
  I, J, linesCounter, linesSubCounter: integer;
  stippleColor: TColor32;
  stipCntr, stipOffX, stipOffY: single;
  tl, tr, bl, br, pt: TFixedPoint;
  endPt: TFixedPoint;
  roundEndPts: TArrayOfFixedPoint;
  angle, SavedStippleStep: single;

  procedure StippleFill(topLeft, topRight, bottomLeft, bottomRight: TFixedPoint;
    count: integer; stipOffsetX, stipOffsetY: single);
  var
    j: integer;
    dx1,dy1,dx2,dy2: single;
    lineangle, sinAng, cosAng, stipOffset: single;
  begin
    if (count < 1) then exit;
    lineAngle := GetAngleOfPt2FromPt1(topLeft, topRight);
    Math.SinCos(lineAngle, sinAng, cosAng);
    stipCntr := stipCntr +
      (stipOffsetX*cosAng-stipOffsetY*sinAng)*FixedToFloat*bitmap.StippleStep;

    dx1 := (bottomLeft.X - topLeft.X)/count;
    dy1 := (bottomLeft.Y - topLeft.Y)/count;
    dx2 := (bottomRight.X - topRight.X)/count;
    dy2 := (bottomRight.Y - topRight.Y)/count;
    stipOffset := (dy1*sinAng - dx1*cosAng)*FixedToFloat*bitmap.StippleStep;

    //draw multiple parallel stippled lines to fill out a line segment ...
    for j := 0 to count-1 do
    begin
      bitmap.StippleCounter := stipCntr - (j* stipOffset);
      bitmap.MoveToX(Round(topLeft.X + (j*dx1)),
        Round(topLeft.Y + (j*dy1)));
      bitmap.LineToXSP(Round(topRight.X + (j*dx2)),
        Round(topRight.Y + (j*dy2)));
    end;
  end;

begin
  if not assigned(bitmap) or (length(fLinePoints) < 2) then exit;
  if penWidth > 0 then SetWidth(penWidth);

  bitmap.SetStipple(colors);
  SavedStippleStep := bitmap.StippleStep;
  //constrain: -1 <= StippleStep <= 1; for values < -1 use current StippleStep
  if StippleStep >= -1.0 then
  begin
    if StippleStep > 1 then StippleStep := 1;
    bitmap.StippleStep := StippleStep;
  end;
  linesCounter := round(fLineWidth);
  stippleColor := bitmap.GetStippleColor; //used for round end caps

  pts := GetArrowTruncatedPoints;

  with TStippledGrow.create(@fLeftPoints, @fRightPoints) do
  try
    Grow(pts, fLineWidth, jsBevelled, MiterLimit, EndStyle = esClosed);
    for I := 1 to count -1 do
    begin
      stipCntr := bitmap.stipplecounter;
      linesSubCounter := linesCounter;

      with item[I]^ do
      begin
        If (left = nil) or (right = nil) then break;
        tr := Left[0];
        br := Right[0];
      end;
      with item[I-1]^ do
      begin
        tl := Left[high(Left)];
        bl := Right[high(Right)];
        stipOffX := 0;
        stipOffY := 0;

        if length(Left) > 1 then
        begin
          J := round(DistOfPointFromLine(Left[0], tl, tr, false));
          pt.X := round(tr.X + j/linesCounter* (br.X- tr.X));
          pt.Y := round(tr.Y + j/linesCounter* (br.Y- tr.Y));
          StippleFill(tl, tr, Left[0], pt, j, 0 ,0);
          stipOffX := (Left[0].X - tl.X);
          stipOffY := (Left[0].Y - tl.Y);
          tl := Left[0];
          tr := pt;
          dec(linesSubCounter,j);
        end
        else if length(Right) > 1 then
        begin
          j := round(DistOfPointFromLine(Right[0], bl, br, false));
          pt.X := round(br.X + j/linesCounter* (tr.X- br.X));
          pt.Y := round(br.Y + j/linesCounter* (tr.Y- br.Y));
          StippleFill(Right[0], pt, bl, br, j, 0 ,0);
          stipOffX := (tl.X - Right[0].X);
          stipOffY := (tl.Y - Right[0].Y);
          bl := Right[0];
          br := pt;
          dec(linesSubCounter,j);
        end;
      end;
      StippleFill(tl, tr, bl, br, linesSubCounter, stipOffX, stipOffY);
    end;

    //add rounded ends if needed ...
    if (EndStyle = esRounded) and (fLineWidth > 5) then
    begin
      if not fStartArrow.IsNeeded then
      begin
        endPt := pts[0];
        with item[0]^ do angle := - GetAngleOfPt2FromPt1(left[0], right[0]);
        roundEndPts := BuildArc(FloatPoint(endPt),angle,angle+rad180, penWidth/2 -0.5);
        fPolygon32.Clear;
        fPolygon32.AddPoints(roundEndPts[0],length(roundEndPts));
        fPolygon32.DrawFill(bitmap, stippleColor);
      end;
      if not fEndArrow.IsNeeded then
      begin
        endPt := pts[high(pts)];
        with item[count-1]^ do angle := - GetAngleOfPt2FromPt1(right[0], left[0]);
        roundEndPts := BuildArc(FloatPoint(endPt),angle,angle+rad180, penWidth/2 -0.5);
        fPolygon32.Clear;
        fPolygon32.AddPoints(roundEndPts[0],length(roundEndPts));
        fPolygon32.DrawFill(bitmap, stippleColor);
      end;
    end;

  finally
    free;
  end;
  if StippleStep >= -1 then
    bitmap.StippleStep := SavedStippleStep;
  DrawArrows(bitmap);
end;
//------------------------------------------------------------------------------

procedure TLine32.Draw(bitmap: TBitmap32; penWidth: single;
  dashPattern: TArrayOfFloat; color: TColor32; edgeColor: TColor32 = $00000000);
var
  pts: TArrayOfFixedPoint;
  ppts: TArrayOfArrayOfFixedPoint;
  i: integer;
begin
  if not assigned(bitmap) or (length(fLinePoints) < 2) then exit;
  if penWidth > 0 then SetWidth(penWidth);
  pts := GetArrowTruncatedPoints;
  if length(dashPattern) > 1 then
  begin
    ppts := BuildDashedLine(pts,dashPattern, fEndStyle = esClosed, 0, fLineWidth);
  end else
  begin
    setlength(ppts, 1);
    ppts[0] := pts;
  end;
  if fLineWidth > 1.05 then
  begin
    ppts := GrowDashedLine(ppts, fLineWidth);
    fPolygon32.FillMode := self.FillMode;
    for i := 0 to high(ppts) do
    begin
      fPolygon32.Clear;
      fPolygon32.AddPoints(ppts[i][0],length(ppts[i]));
      fPolygon32.DrawFill(bitmap, color);
      if edgeColor <> $00000000 then
        fPolygon32.DrawEdge(bitmap, edgeColor);
    end;
  end else
    SimpleLine(bitmap, ppts, color, fLineWidth, false);

  DrawArrows(bitmap);
end;
//------------------------------------------------------------------------------

procedure TLine32.DrawGradientHorz(bitmap: TBitmap32; penWidth: single;
  const colors: array of TColor32; edgeColor: TColor32 = $00000000);
var
  i, j: integer;
  dx: single;
  p: TArrayOfColor32;
  p2: PColor32Array;
  rec: TRect;
  bmp: TBitmap32;
begin
  rec := GetBoundsRect(penWidth);
  with rec do if (right = left) or (top = bottom) then exit;
  bmp := TBitmap32.Create;
  try
    bmp.Width := bitmap.Width;
    bmp.Height := bitmap.Height;
    bmp.DrawMode := dmBlend;
    bmp.CombineMode := cmMerge;
    setlength(p, bmp.Width);
    {$R-}
    dx := 1/(rec.Right-rec.Left);
    for i := max(rec.Left,0) to min(rec.Right,bmp.Width) -1 do
      p[i] := GetColor(colors, (i-rec.Left)*dx);
    for j := max(rec.Top,0) to min(rec.Bottom,bmp.Height) -1 do
    begin
      p2 := bmp.ScanLine[j];
      for i := max(rec.Left,0) to min(rec.Right,bmp.Width) -1 do
        p2[i] := p[i];
    end;
    {$R+}
    Draw(bitmap, fLineWidth, bmp, edgeColor);
  finally
    bmp.Free;
  end;
end;
//------------------------------------------------------------------------------

procedure TLine32.DrawGradientVert(bitmap: TBitmap32; penWidth: single;
  const colors: array of TColor32; edgeColor: TColor32 = $00000000);
var
  i, j: integer;
  dy: single;
  c: TColor32;
  p2: PColor32Array;
  rec: TRect;
  bmp: TBitmap32;
begin
  rec := GetBoundsRect(penWidth);
  with rec do if (right = left) or (top = bottom) then exit;
  bmp := TBitmap32.Create;
  try
    bmp.Width := bitmap.Width;
    bmp.Height := bitmap.Height;
    bmp.DrawMode := dmBlend;
    bmp.CombineMode := cmMerge;
    {$R-}
    dy := 1/(rec.Bottom-rec.top);
    for j := max(rec.Top,0) to min(rec.Bottom, bmp.Height) -1 do
    begin
      p2 := bmp.ScanLine[j];
      c := GetColor(colors, (j-rec.Top)*dy);
      for i := max(rec.Left,0) to min(rec.Right, bmp.Width) -1 do p2[i] := c;
    end;
    {$R+}
    Draw(bitmap, fLineWidth, bmp,edgeColor);
  finally
    bmp.Free;
  end;
end;
//------------------------------------------------------------------------------

procedure TLine32.DrawGradient(bitmap: TBitmap32; penWidth: single;
  const colors: array of TColor32; angle_degrees: integer; edgeColor: TColor32 = $00000000);
var
  bmp, bmp2: TBitmap32;
  rec, rec2, rec3: TRect;
  rec3_offset, rec3_diff: TPoint;
  AT: TAffineTransformation;
  rotatedPts: TArrayOfFixedPoint;
  rotPoint: TFloatPoint;
  i, j, len: integer;
  angle_radians, dx: single;
  src,dst: PColor32;
  reverseColors: array of TColor32;
  pts: TArrayOfFixedPoint;
begin
  len := length(colors);
  if not assigned(bitmap) or (Length(fLinePoints) < 2) or (len = 0) then exit;
  angle_radians := angle_degrees*DegToRad;

  if NearlyMatch(angle_radians, 0, 5*rad01) then
  begin
    DrawGradientHorz(bitmap, penWidth, colors, edgeColor);
    exit;
  end
  else if NearlyMatch(angle_radians, rad180, 5*rad01) then
  begin
    setLength(reverseColors, len);
    for i := 0 to len -1 do reverseColors[i] := colors[len-1-i];
    DrawGradientHorz(bitmap, penWidth, reverseColors, edgeColor);
    exit;
  end
  else if NearlyMatch(angle_radians, rad90, 5*rad01) then
  begin
    setLength(reverseColors, len);
    for i := 0 to len -1 do reverseColors[i] := colors[len-1-i];
    DrawGradientVert(bitmap, penWidth, reverseColors, edgeColor);
    exit;
  end
  else if NearlyMatch(angle_radians, rad270, 5*rad01) then
  begin
    DrawGradientVert(bitmap, penWidth, colors, edgeColor);
    exit;
  end;

  pts := GetOuterEdge(penWidth);
  rec := gr32_misc.GetBoundsRect(pts);
  if (rec.Right = rec.Left) or (rec.Bottom = rec.Top) then exit;
  with rec do
    rotPoint := FloatPoint((left+right)/2,(top+bottom)/2);
  rotatedPts := rotatePoints(pts, FixedPoint(rotPoint), -angle_radians);
  rec2 := gr32_misc.GetBoundsRect(rotatedPts);
  inflateRect(rec2,1,1);
  rec3 := rec2;
  if rec3.Left > rec.Left then rec3.Left := rec.Left;
  if rec3.Top > rec.Top then rec3.Top := rec.Top;
  if rec3.Right < rec.Right then rec3.Right := rec.Right;
  if rec3.Bottom < rec.Bottom then rec3.Bottom := rec.Bottom;

  rec3_offset := Point(rec3.Left, rec3.Top);
  rec3_diff := Point(rec2.Left - rec3.Left, rec2.Top - rec3.Top);
  offsetRect(rec3, -rec3.Left, -rec3.Top);
  offsetPoint(rotPoint, -rec2.Left, -rec2.Top);
  offsetRect(rec2, -rec2.Left, -rec2.Top);


  bmp := TBitmap32.Create;
  bmp2 := TBitmap32.Create;
  try
    bmp.DrawMode := dmBlend;
    bmp.CombineMode := cmMerge;
    bmp.SetSize(rec2.right,rec2.bottom);

    bmp2.SetSize(rec3.right,rec3.bottom);

    //create the gradient color pattern ...
    {$R-}
    dx := 1/bmp.Width;
    src := @bmp.bits[0];
    for i := 0 to bmp.Width -1 do
    begin
      src^ := GetColor(colors, i*dx);
      inc(src);
    end;
    for i := 1 to bmp.Height -1 do
    begin
      src := @bmp.bits[0];
      dst := @bmp.bits[i*bmp.Width];
      for j := 0 to bmp.Width -1 do
      begin
        dst^ := src^;
        inc(src);
        inc(dst);
      end;
    end;
    {$R+}

    //rotate the color pattern onto bmp2 ...
    AT := TAffineTransformation.Create;
    try
      AT.SrcRect := FloatRect(rec2);
      AT.Rotate(rotPoint.X, rotPoint.Y, angle_degrees);
      AT.Translate(rec3_diff.X, rec3_diff.Y);
      GR32_Transforms.Transform(bmp2, bmp, AT);
    finally
      AT.free;
    end;

    //almost there ... now copy the rotated color pattern onto bmp
    //at the required location for the pattern ...
    bmp.SetSize(rec3_offset.X + rec3.Right, rec3_offset.Y + rec3.Bottom);
    bmp2.DrawTo(bmp,rec3_offset.X,rec3_offset.Y);

    Draw(bitmap, fLineWidth, bmp, edgeColor);
  finally
    bmp.Free; bmp2.Free;
  end;
end;
//------------------------------------------------------------------------------

function TLine32.GetLeftPoints: TArrayOfFixedPoint;
begin
  if fLeftPoints = nil then Build;
  result := fLeftPoints;
end;
//------------------------------------------------------------------------------

function TLine32.GetRightPoints: TArrayOfFixedPoint;
begin
  if fRightPoints = nil then Build;
  result := fRightPoints;
end;
//------------------------------------------------------------------------------

function TLine32.Points: TArrayOfFixedPoint;
begin
  result := fLinePoints;
end;
//------------------------------------------------------------------------------

function TLine32.GetOutline(penWidth: single = 0): TArrayOfFixedPoint;
var
  highPts : integer;
  N              : TFloatPoint;
  a1, a2, halfLW : single;
  startPts       : TArrayOfFixedPoint;
  endPts         : TArrayOfFixedPoint;
  reversedPts    : TArrayOfFixedPoint;
begin
  if penWidth > 0 then SetWidth(penWidth);
  Build;
  if (length(fLeftPoints) = 0) and (length(fRightPoints) = 0) then exit;
  startPts := nil;
  endPts := nil;
  if not fStartArrow.IsNeeded then
  begin
    N := GetUnitNormal(fLinePoints[1],fLinePoints[0]);
    halfLW := fLineWidth/2;
    if (fEndStyle = esRounded) then
    begin
      a1 := ArcTan2(N.Y, N.X);
      a2 := ArcTan2(-N.Y, -N.X);
      if a2 < a1 then a2 := a2 + rad360;
      startPts :=
        BuildArc(FloatPoint(fLinePoints[0]), a1, a2, halfLW);
    end else if (fEndStyle = esSquared) then
    begin
      SetLength(startPts, 2);
      startPts[0].X := fLinePoints[0].X + Fixed((N.X - N.Y) * halfLW);
      startPts[0].Y := fLinePoints[0].Y + Fixed((N.Y + N.X) * halfLW);
      startPts[1].X := fLinePoints[0].X - Fixed((N.X + N.Y) * halfLW);
      startPts[1].Y := fLinePoints[0].Y - Fixed((N.Y - N.X) * halfLW);
    end;
  end;
  if not fEndArrow.IsNeeded then
  begin
    highPts := high(fLinePoints);
    N := GetUnitNormal(fLinePoints[highPts-1], fLinePoints[highPts]);
    halfLW := fLineWidth/2;
    if (fEndStyle = esRounded) then
    begin
      a1 := ArcTan2(N.Y, N.X);
      a2 := ArcTan2(-N.Y, -N.X);
      if a2 < a1 then a2 := a2 + rad360;
      endPts :=
        BuildArc(FloatPoint(fLinePoints[highPts]), a1, a2, halfLW);
    end else if (fEndStyle = esSquared) then
    begin
      SetLength(endPts, 2);
      endPts[0].X := fLinePoints[highPts].X + Fixed((N.X - N.Y) * halfLW);
      endPts[0].Y := fLinePoints[highPts].Y + Fixed((N.Y + N.X) * halfLW);
      endPts[1].X := fLinePoints[highPts].X - Fixed((N.X + N.Y) * halfLW);
      endPts[1].Y := fLinePoints[highPts].Y - Fixed((N.Y - N.X) * halfLW);
    end;
  end;
  setLength(result, length(fLeftPoints) + length(fRightPoints) +
    length(startPts) + length(endPts));

  if startPts <> nil then
    move(startPts[0],result[0], length(startPts) * sizeof(TFixedPoint));
  move(fLeftPoints[0],result[length(startPts)],
    length(fLeftPoints) * sizeof(TFixedPoint));
  if endPts <> nil then
    move(endPts[0],result[length(startPts)+length(fLeftPoints)],
      length(endPts) * sizeof(TFixedPoint));
  reversedPts := ReversePoints(fRightPoints);
  move(reversedPts[0], result[length(startPts)+length(fLeftPoints)+length(endPts)],
    length(reversedPts) * sizeof(TFixedPoint));
end;
//------------------------------------------------------------------------------

function TLine32.GetOuterEdge(penWidth: single = 0): TArrayOfFixedPoint;
var
  len: integer;
begin
  if penWidth > 0 then SetWidth(penWidth);
  if (EndStyle = esClosed) and (length(fLinePoints) > 2) then
  begin
    if IsClockwise(Points) then
      result := GetLeftPoints else
      result := GetRightPoints;
    len := length(result);
    if (len < 3) or IsDuplicatePoint(result[0], result[len-1]) then exit;
    SetLength(result, len +1);
    result[len].X := result[0].X;
    result[len].Y := result[0].Y;
  end else
    result := GetOutline;
end;
//------------------------------------------------------------------------------

function TLine32.GetInnerEdge(penWidth: single = 0): TArrayOfFixedPoint;
var
  len: integer;
begin
  if penWidth > 0 then SetWidth(penWidth);
  if (EndStyle = esClosed) and (length(fLinePoints) > 2) then
  begin
    if IsClockwise(Points) then
      result := GetRightPoints else
      result := GetLeftPoints;
    len := length(result);
    if (len < 3) or IsDuplicatePoint(result[0], result[len-1]) then exit;
    SetLength(result, len +1);
    result[len].X := result[0].X;
    result[len].Y := result[0].Y;
  end else
    result := GetOutline;
end;
//------------------------------------------------------------------------------

procedure TLine32.SetWidth(value: single);
begin
  Constrain(value, 1, 50);
  if value = fLineWidth then exit;
  fLineWidth := value;
  ForceRebuild;
end;
//------------------------------------------------------------------------------

procedure TLine32.SetMiterLimit(value: single);
begin
  if value = fMiterLimit then exit;
  fMiterLimit := Constrain(value, 0, 40);
  ForceRebuild;
end;
//------------------------------------------------------------------------------

procedure TLine32.SetJoinStyle(value: TJoinStyle);
begin
  if value = fJoinStyle then exit;
  fJoinStyle := value;
  ForceRebuild;
end;
//------------------------------------------------------------------------------

procedure TLine32.SetEndStyle(value: TEndStyle);
begin
  if value = fEndStyle then exit;
  fEndStyle := value;
  if fEndStyle = esClosed then
  begin
    ArrowStart.fStyle := asNone;
    ArrowEnd.fStyle := asNone;
  end;
  ForceRebuild;
end;
//------------------------------------------------------------------------------

function TLine32.DoHitTest(pt: TFixedPoint; penWidth: single = 0): THitTestResult;
var
  lineOutline: TArrayOfFixedPoint;
  arrowOutline: TArrayOfFixedPoint;
begin
  result := htNone;
  if length(fLinePoints) < 2 then exit;
  lineOutline := GetOutline(penWidth);
  if length(lineOutline) = 0 then exit;
  arrowOutline := fEndArrow.OutlinePoints(0);
  if (Length(arrowOutline) > 0) and PtInPolygon(pt,arrowOutline) then
    result := htEndArrow
  else
  begin
    arrowOutline := fStartArrow.OutlinePoints(0);
    if (Length(arrowOutline) > 0) and PtInPolygon(pt,arrowOutline) then
      result := htStartArrow
    else if PtInPolygon(pt,lineOutline) then
      result := htLine;
  end;
end;
//------------------------------------------------------------------------------

procedure TLine32.Build;
var
  pts: TArrayOfFixedPoint;
begin
  if (fLeftPoints <> nil) or (fRightPoints <> nil) or //ie do only once
    (length(fLinePoints) < 2) or (fLineWidth < 1) then exit;

  pts := GetArrowTruncatedPoints;

  //now get the left and right 'grow' points (ie outline minus end caps) ...
  with TGrow.create(@fLeftPoints, @fRightPoints) do
  try
    Grow(pts, fLineWidth, JoinStyle, MiterLimit, EndStyle = esClosed);
  finally
    free;
  end;
end;
//------------------------------------------------------------------------------

end.

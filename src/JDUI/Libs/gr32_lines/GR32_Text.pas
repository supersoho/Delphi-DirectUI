unit GR32_Text;

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
 * The Original Code is Graphics32
 * The Initial Developer of the Original Code is Alex A. Denisov
 * Portions created by the Initial Developer are Copyright (C) 2000-2007
 * the Initial Developer. All Rights Reserved.
 *
 * The Initial Developer of the code in GR32_Text.pas is Angus Johnson
 * <angus@angusj.com>. GR32_Text.pas code is Copyright (C) 2009-2010.
 * All Rights Reserved.
 *
 * Acknowledgements:
 * Sub-pixel rendering based on code provided by Akaiten <akaiten@mail.ru>
 * TLCDDistributionLut class provided by Akaiten and is based on code from
 * Maxim Shemanarev.
 *
 * Version 3.92 (Last updated 10-Nov-2010)
 *
 *  The TText32 class renders text using the Windows API function
 *  GetGlyphOutline(). This requires TrueType fonts.
 *
 * More info on fonts -
 *   http://www.w3.org/TR/CSS2/fonts.html#emsq
 *   http://msdn.microsoft.com/en-us/library/dd162755(VS.85).aspx
 *
 * END LICENSE BLOCK **********************************************************)

interface

{.$DEFINE GR32_PolygonsEx}

{$I GR32.inc}

{$IFDEF COMPILER7}
{$WARN UNSAFE_CODE OFF}
{$WARN UNSAFE_TYPE OFF}
{$WARN UNSAFE_CAST OFF}
{$ENDIF}


{$IFDEF MSWINDOWS}  //numerous Windows API dependencies

uses
  Windows, Classes, SysUtils, Math, Graphics, Types, GR32, GR32_LowLevel,
{$IFDEF GR32_PolygonsEx}
  GR32_PolygonsEx, GR32_VPR,
{$ENDIF}
  GR32_Blend, GR32_Math, GR32_Polygons, GR32_Transforms, GR32_Misc, GR32_Lines;

type
  TAlignH = (aLeft, aRight, aCenter, aJustify);
  TAlignV = (aBottom, aMiddle, aTop);

  TFloatSize = record
    sx: single;
    sy: single;
  end;

  //Often glyph outlines require more than one line to define them, so each
  //glyph is defined by a two dimentional array - TArrayOfArrayOfFixedPoint.
  //Therefore outlines of multiple glyphs require three dimentional arrays ...
  //TArrayOfArrayOfArrayOfFixedPoint = array of TArrayOfArrayOfFixedPoint;

{$IFNDEF UNICODE}
  UnicodeString = WideString;
{$ENDIF}

  TGlyphInfo = record
    cached: boolean;
    metrics: TGlyphMetrics;
    pts: TArrayOfArrayOfFixedPoint;
  end;

  TTrueTypeFontClass = class of TTrueTypeFont;

  //*TTrueTypeFont: This class provides access to true-type font data,
  //*primarily glyph outlines (encapsulating the Windows API function
  //*GetGlyphOutline), but also retrieves TTextMetric and TOutlineTextmetric
  //*information. Descendant classes also perform caching of glyph outline data.
  TTrueTypeFont = class(TPersistent)
  private
    fFont: TFont;
    fMemDC: HDC;
    fOldFntHdl: HFont;
    fHinted: boolean;
    fFlushed: boolean;
    function GetFontName: TFontName;
    procedure SetFontName(const aFontName: TFontName);
    function GetHeight: integer;
    procedure SetHeight(aHeight: integer);
    function GetSize: integer;
    procedure SetSize(aSize: integer);
    function GetStyle: TFontStyles;
    procedure SetStyle(aStyle: TFontStyles);
    function GetCharSet: TFontCharset;
    procedure SetCharSet(aCharSet: TFontCharset);
    procedure SetHinted(value: boolean);
  protected
    property MemDC: HDC read fMemDC;
  public
    constructor Create; overload; virtual;
    constructor Create(aFont: TFont); overload; virtual;
    constructor Create(const aFontName: TFontName; aHeight: integer = 14;
      aStyle: TFontStyles = []; aCharSet: TFontCharset = 0); overload; virtual; 
    destructor Destroy; override;
    class function IsValidTTFont(font: TFont): boolean;
    function Lock: boolean;
    function IsLocked: boolean;
    procedure Unlock;
    procedure Assign(Source: TPersistent); override;
    function GetGlyphInfo(wc: wideChar; out gm: TGlyphMetrics;
      out polyPts: TArrayOfArrayOfFixedPoint): boolean; virtual;
    function GetTextMetrics(out tm: TTextMetric): boolean;
    function GetOutlineTextMetrics(out otm: TOutlineTextmetric): boolean;
    procedure Flush;

    property Flushed: boolean read fFlushed write fFlushed;
    property FontName: TFontName read GetFontName write SetFontName;
    property Height: integer read GetHeight write SetHeight;
    property Size: integer read GetSize write SetSize;
    property CharSet: TFontCharset read GetCharSet write SetCharSet;
    property Style: TFontStyles read GetStyle write SetStyle;
    //*'Hinting' can marginally improve the drawing clarity of unrotated,
    //*unskewed text when sub-pixel font smoothing is applied. Default = disabled
    property Hinted: boolean read fHinted write SetHinted;
  end;

  //*TTrueTypeFontAnsiCache: Descendant class of TTrueTypeFont that caches glyph
  //*information for ANSI characters between 32 to 127 providing a small
  //*improvement in performance.
  TTrueTypeFontAnsiCache = class(TTrueTypeFont)
  private
    fGlyphInfo: array [32 ..127] of TGlyphInfo;
  public
    function GetGlyphInfo(wc: wideChar; out gm: TGlyphMetrics;
      out polyPts: TArrayOfArrayOfFixedPoint): boolean; override;
  end;

  //*TText32: Class that greatly simplifies the drawing of true-type text, and
  //*the application of various transformations (scaling, skewing and rotating)
  //*and text alignments.
  TText32 = class
  private
    fTmpBmp           : TBitmap32;
    fLCDDraw          : boolean;
    fAngle            : integer;
    fSkew             : TFloatSize;
    fScale            : TFloatSize;
    fTranslate        : TFloatSize;
    fPadding          : single;
    fInverted         : boolean;
    fMirrored         : boolean;
    fCurrentPos       : TFixedPoint;
    fGlyphMatrix      : TMat2;
    fCurrentPosMatrix : TMat2;
    fUnrotatedMatrix  : TMat2;
    procedure SetInverted(value: boolean);
    procedure SetMirrored(value: boolean);
    procedure SetAngle(value: integer);
    procedure SetScaleX(value: single);
    procedure SetScaleY(value: single);
    procedure SetSkewX(value: single);
    procedure SetSkewY(value: single);
    procedure SetPadding(value: single);
    procedure PrepareMatrices;
    procedure DrawInternal(bitmap: TBitmap32; const text: UnicodeString;
      ttFont: TTrueTypeFont; color: TColor32);
    procedure DrawInternalLCD(bitmap: TBitmap32; const text: UnicodeString;
      ttFont: TTrueTypeFont; color: TColor32);
    function GetCurrentPos: TFixedPoint;
    procedure SetCurrentPos(newPos: TFixedPoint);
 protected
    procedure GetTextMetrics(const text: UnicodeString;
      ttFont: TTrueTypeFont; const InsertionPt: TFixedPoint;
      out NextInsertionPt: TFixedPoint; out BoundsRect: TFixedRect);
    procedure GetDrawInfo(const text: UnicodeString;
      ttFont: TTrueTypeFont; const InsertionPt: TFloatPoint;
      out NextInsertionPt: TFloatPoint;
      out polyPolyPts: TArrayOfArrayOfArrayOfFixedPoint);
  public
    constructor Create;
    destructor Destroy; override;

    //*GetTextFixedRect: bounding rectangle with all transformations applied
    function GetTextFixedRect(X, Y: single; const text: UnicodeString;
      ttFont: TTrueTypeFont): TFixedRect;
    //*GetTextHeight: text height with all transformations applied
    function GetTextHeight(const text: UnicodeString;
      ttFont: TTrueTypeFont): single;
    //*GetTextWidth: text width with all transformations applied
    function GetTextWidth(const text: UnicodeString;
      ttFont: TTrueTypeFont): single;
    function CountCharsThatFit(X, Y: single; const text: UnicodeString;
      ttFont: TTrueTypeFont;
      const boundsRect: TFloatRect; forceWordBreak: boolean = false): integer;

    procedure Draw(bitmap: TBitmap32; X, Y: single; const text: UnicodeString;
      ttFont: TTrueTypeFont; color: TColor32); overload;
    //*Draw: without X & Y parameters specified draws 'text' at CurrentPos ...
    procedure Draw(bitmap: TBitmap32; const text: UnicodeString;
      ttFont: TTrueTypeFont; color: TColor32); overload;

    //*Draw: text along a path. Text is always drawn on the 'left' side of the
    //*path relative to the path's direction. So if the path is constructed from
    //*left to right, the text will be drawn above the path.
    procedure Draw(bitmap: TBitmap32; const path: array of TFixedPoint;
      const text: UnicodeString; ttFont: TTrueTypeFont; color: TColor32;
      alignH: TAlignH = aCenter; alignV: TAlignV = aMiddle;
      offsetFromLine: single = 0); overload;

    //*Draw: text that wraps within a bounding rectangle ...
    procedure Draw(bitmap: TBitmap32; const boundsRect: TFloatRect;
      const text: UnicodeString; ttFont: TTrueTypeFont; color: TColor32;
      alignH: TAlignH; alignV: TAlignV; forceWordBreak: boolean = false); overload;

    //*GetEx: Similar to 'Get' but returns each glyph individually using a
    //*multi-dimentional array (TArrayOfArrayOfArrayOfFixedPoint) which
    //*allows the user to draw each glyph individually.
    function GetEx(const boundsRect: TFloatRect;
      const text: UnicodeString; ttFont: TTrueTypeFont; alignH: TAlignH; alignV: TAlignV;
      forceWordBreak: boolean = false): TArrayOfArrayOfArrayOfFixedPoint; overload;

    //*DrawAndOutline: method to outline text with pen widths greater than 1px.
    procedure DrawAndOutline(bitmap: TBitmap32; X, Y: single;
      const text: UnicodeString; ttFont: TTrueTypeFont;
      outlinePenWidth: single; outlineColor, fillColor: TColor32);

    function Get(X, Y: single; const text: UnicodeString;
      ttFont: TTrueTypeFont;
      out NextInsertionPt: TFloatPoint): TArrayOfArrayOfFixedPoint; overload;

    function GetEx(X, Y: single; const text: UnicodeString;
      ttFont: TTrueTypeFont;
      out NextInsertionPt: TFloatPoint): TArrayOfArrayOfArrayOfFixedPoint; overload;

    //*Text is subtly distorted to fit the specified path.
    //*If rotateTextToPath = true, the tops of glyphs are stretched at path
    //*convexes and compressed at path concaves. This avoids unsightly spreading
    //*and bunching of glyphs at path convexes and concaves respectively that
    //*occurs when glyphs are simply rotated along the path.
    //*If rotateTextToPath = false, then each glyph is distorted (without
    //*rotation) to follow the path.
    function Get(const path: array of TFixedPoint; const text: UnicodeString;
      ttFont: TTrueTypeFont; alignH: TAlignH; alignV: TAlignV;
      rotateTextToPath: boolean;
      offsetFromLine: single = 0): TArrayOfArrayOfFixedPoint; overload;

    //*Text is subtly distorted to fit the specified path.
    //*If rotateTextToPath = true, the tops of glyphs are stretched at path
    //*convexes and compressed at path concaves. This avoids unsightly spreading
    //*and bunching of glyphs at path convexes and concaves respectively that
    //*occurs when glyphs are simply rotated along the path.
    //*If rotateTextToPath = false, then each glyph is distorted (without
    //*rotation) to follow the path.
    function GetEx(const path: array of TFixedPoint; const text: UnicodeString;
      ttFont: TTrueTypeFont; alignH: TAlignH; alignV: TAlignV;
      rotateTextToPath: boolean;
      offsetFromLine: single = 0): TArrayOfArrayOfArrayOfFixedPoint; overload;

    //*This method assumes that the font adhers to convention(#) by drawing
    //*outer glyph outlines clockwise and inner outlines (or 'holes' like the
    //*middle of an 'O') anti-clockwise.
    //*(#)see http://www.microsoft.com/typography/ProductionGuidelines.mspx
    function GetInflated(X, Y, delta: single;
      const text: UnicodeString; ttFont: TTrueTypeFont;
      out NextInsertionPt: TFloatPoint): TArrayOfArrayOfFixedPoint;

    //*This method assumes that the font adhers to convention(#) by drawing
    //*outer glyph outlines clockwise and inner outlines (or 'holes' like the
    //*middle of an 'O') anti-clockwise.
    //*(#)see http://www.microsoft.com/typography/ProductionGuidelines.mspx
    function GetInflatedEx(X, Y, delta: single;
      const text: UnicodeString; ttFont: TTrueTypeFont;
      out NextInsertionPt: TFloatPoint): TArrayOfArrayOfArrayOfFixedPoint;

    function GetBetweenPaths(
      const bottomCurve, topCurve: TArrayOfFixedPoint; const text: UnicodeString;
      ttFont: TTrueTypeFont): TArrayOfArrayOfFixedPoint;

    function GetBetweenPathsEx(
      const bottomCurve, topCurve: TArrayOfFixedPoint; const text: UnicodeString;
      ttFont: TTrueTypeFont): TArrayOfArrayOfArrayOfFixedPoint;

    procedure Scale(sx, sy: single);
    procedure Skew(sx, sy: single);
    procedure Translate(dx, dy: TFloat);
    procedure ClearTransformations; //including angle

    property Angle: integer read fAngle write SetAngle;
    property ScaleX: single read fScale.sx write SetScaleX;
    property ScaleY: single read fScale.sy write SetScaleY;
    property SkewX: single read fSkew.sx write SetSkewX;
    property SkewY: single read fSkew.sy write SetSkewY;
    property TranslateX: single read fTranslate.sx write fTranslate.sx;
    property TranslateY: single read fTranslate.sy write fTranslate.sy;

    //CurrentPos: internally updates after every Draw method
    property CurrentPos: TFixedPoint read GetCurrentPos write SetCurrentPos;
    //LCDDraw: subpixel antialiasing for much smoother text on LCD displays
    //(see http://www.grc.com/cttech.htm for more info on this)
    property LCDDraw: boolean read fLCDDraw write fLCDDraw;
    //Inverted - flips text vertically
    property Inverted: boolean read fInverted write SetInverted;
    //Mirrored - flips text horizontally
    property Mirrored: boolean read fMirrored write SetMirrored;
    //Spacing - extra space between each character
    property Spacing: single read fPadding write SetPadding;
  end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

var
  TrueTypeFontClass: TTrueTypeFontClass = TTrueTypeFontAnsiCache;

  //*Text32LCDDrawDefault: when set to true LCD sub-pixel antialiasing
  //*will be enabled by default whenever a Text32 object is created.
  //*Suggest setting with -> SystemParametersInfo(SPI_GETFONTSMOOTHING, ...)
  Text32LCDDrawDefault: boolean = false;

const
  identity_mat2: TMat2 =
    (eM11:(fract: 0; value:1); eM12:(fract: 0; value:0);
     eM21:(fract: 0; value:0); eM22:(fract: 0; value:1));

  vert_flip_mat2: TMat2 =
    (eM11:(fract: 0; value:1); eM12:(fract: 0; value: 0);
     eM21:(fract: 0; value:0); eM22:(fract: 0; value: -1));

  horz_flip_mat2: TMat2 =
    (eM11:(fract: 0; value: -1); eM12:(fract: 0; value: 0);
     eM21:(fract: 0; value: 0); eM22:(fract: 0; value: -1));

//*ScaleMat2: Matrix scale transformation using Windows TMat2 record structure
procedure ScaleMat2(var mat: TMat2; const sx, sy: single);
//*SkewMat2: Matrix skew transformation using Windows TMat2 record structure
procedure SkewMat2(var mat: TMat2; const fx, fy: single);
//*RotateMat2: Matrix rotate transformation using Windows TMat2 record structure
procedure RotateMat2(var mat: TMat2; const angle_radians: single);

//*GetTTFontCharInfo: calls the Windows API GetGlyphOutlineW and processes the
//*raw info into a TArrayOfArrayOfFixedPoint that contains the glyph outline.
function GetTTFontCharInfo(MemDC: HDC; wc: wideChar; dx, dy: single;
  mat2: TMat2; Hinted: boolean;
  out gm: TGlyphMetrics; out polyPts: TArrayOfArrayOfFixedPoint): boolean;

//*GetTTFontCharMetrics: calls the Windows API GetGlyphOutlineW and simply
//*returns a TGlyphMetrics record without the glyph outline.
function GetTTFontCharMetrics(MemDC: HDC; wc: wideChar; dx, dy: single;
  mat2: TMat2; out gm: TGlyphMetrics): boolean;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

function FloatSize(sx, sy: single): TFloatSize;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

//*SimpleText: This procedure is ideal for text that doesn't require any
//*special formatting, and where DrawMode = dmBlend (ie where canvas.textout()
//*can't be used).
procedure SimpleText(bmp: TBitmap32; font: TFont; X, Y: integer;
  const widetext: widestring; color: TColor32);

//*SimpleTextLCD: While similar to SimpleText, SimpleTextLCD usually draws text
//*a little clearer and therefore is usually a little easier to read, especially
//*at smaller font sizes. However unlike SimpleText it requires a TrueType font.
procedure SimpleTextLCD(bmp: TBitmap32; font: TFont; X, Y: integer;
  const wideText: UnicodeString; color: TColor32);
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

procedure LCDPolygonSmoothing(bitmap, tmpBitmap: TBitmap32;
  ppts: TArrayOfArrayOfArrayOfFixedPoint;
  TextColor: TColor32; BkColor: TColor32 = $0);


{$ENDIF} //MSWINDOWS

implementation

{$IFDEF MSWINDOWS}

{$IFNDEF UNICODE}
type
  PByte = PAnsiChar;
{$ENDIF}

const
  GGO_UNHINTED    = $100;
  GGO_BEZIER      = $3;
  TT_PRIM_CSPLINE = $3;

  SPACE: wideChar = ' ';
  LF   : wideChar = #10;
  CR   : wideChar = #13;

type
  TLCDDistributionLut = class
  private
    FPrimary,
    FSecondary,
    FTertiary: array [0..255] of byte;
    function GetPrimary(Index: integer): byte;
    function GetSecondary(Index: integer): byte;
    function GetTertiary(Index: integer): byte;
  public
    constructor Create;
    property Primary[Index: integer]: byte read GetPrimary;
    property Secondary[Index: integer]: byte read GetSecondary;
    property Tertiary[Index: integer]: byte read GetTertiary;
  end;

var
  //This 'look up table' only needs to be a singleton object ...
  lut: TLCDDistributionLut;

//------------------------------------------------------------------------------
// TLCDDistributionLut methods ...
//------------------------------------------------------------------------------

constructor TLCDDistributionLut.Create;
const
  Prim      = 1;
  Second    = 0.1;
  Tert      = 0.01;
var
  norm: double;
  i: integer;
begin
  norm := 1 / (Prim + 2*Second + 2*Tert);
  for i := 0 to 255 do
  begin
    FPrimary[i] := Floor(Prim * norm * i);
    FSecondary[i] := Floor(Second * norm * i);
    FTertiary[i] := Floor(Tert * norm * i);
  end;
end;
//------------------------------------------------------------------------------

function TLCDDistributionLut.GetPrimary(Index: integer): byte;
begin
  Result := FPrimary[Index];
end;
//------------------------------------------------------------------------------

function TLCDDistributionLut.GetSecondary(Index: integer): byte;
begin
  Result := FSecondary[Index];
end;
//------------------------------------------------------------------------------

function TLCDDistributionLut.GetTertiary(Index: integer): byte;
begin
  Result := FTertiary[Index];
end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

procedure TransformPolyPoints(mat: TMat2; translate: TFixedPoint;
  var pts: TArrayOfArrayOfFixedPoint);
var
  i,j: integer;
  tmp: TFixed;
begin
  for i := 0 to high(pts) do for j := 0 to high(pts[i]) do
    with pts[i][j] do
    begin
      tmp := FixedMul(X,TFixed(mat.eM11))+ FixedMul(Y,TFixed(mat.eM21)) +translate.X;
      Y   := FixedMul(X,TFixed(mat.eM12))+ FixedMul(Y,TFixed(mat.eM22)) +translate.Y;
      pts[i][j].X := tmp;
    end;
end;
//------------------------------------------------------------------------------

procedure TransformPoint(mat: TMat2; var pt: TFloatPoint);
var
  tmp: single;
begin
  with pt do
  begin
    tmp := X*TFixed(mat.eM11)*FixedToFloat + Y*TFixed(mat.eM21)*FixedToFloat;
    Y   := X*TFixed(mat.eM12)*FixedToFloat + Y*TFixed(mat.eM22)*FixedToFloat;
    pt.X := tmp;
  end;
end;
//------------------------------------------------------------------------------

procedure SkewPolyPoints(var pts: TArrayOfArrayOfFixedPoint;
  originY: TFixed; sx, sy: single);
var
  i,j: integer;
begin
  for i := 0 to length(pts) -1 do
    for j := 0 to length(pts[i]) -1 do
      with pts[i][j] do
      begin
        X := round(X + (Y - originY)*sx);
        Y := round(Y + X*sy);
      end;
end;
//------------------------------------------------------------------------------

function FloatSize(sx, sy: single): TFloatSize;
begin
  result.sx := sx;
  result.sy := sy;
end;
//------------------------------------------------------------------------------

function MultMat2(const M1, M2: tMat2) : tmat2;
var
  m1em11, m1em12, m1em21, m1em22,
  m2em11, m2em12, m2em21, m2em22 : single;
begin
  m1em11 := GR32.TFixed(m1.eM11)*FixedToFloat;
  m1em12 := GR32.TFixed(m1.eM12)*FixedToFloat;
  m1em21 := GR32.TFixed(m1.eM21)*FixedToFloat;
  m1em22 := GR32.TFixed(m1.eM22)*FixedToFloat;

  m2em11 := GR32.TFixed(m2.eM11)*FixedToFloat;
  m2em12 := GR32.TFixed(m2.eM12)*FixedToFloat;
  m2em21 := GR32.TFixed(m2.eM21)*FixedToFloat;
  m2em22 := GR32.TFixed(m2.eM22)*FixedToFloat;

  GR32.TFixed(Result.eM11) := trunc((m1em11*m2em11 +  m1em21*m2em12)*FixedOne);
  GR32.TFixed(Result.eM12) := trunc((m1em12*m2em11 +  m1em22*m2em12)*FixedOne);
  GR32.TFixed(Result.eM21) := trunc((m1em11*m2em21 +  m1em21*m2em22)*FixedOne);
  GR32.TFixed(Result.eM22) := trunc((m1em12*m2em21 +  m1em22*m2em22)*FixedOne);
end;
//------------------------------------------------------------------------------

procedure ScaleMat2(var mat: TMat2; const sx, sy: single);
var
  tmp: TMat2;
begin
  tmp := identity_mat2;
  GR32.TFixed(tmp.eM11) := Fixed(sx);
  GR32.TFixed(tmp.eM22) := Fixed(sy);
  mat := MultMat2(tmp, mat);
end;
//------------------------------------------------------------------------------

procedure SkewMat2(var mat: TMat2; const fx, fy: single);
var
  tmp: TMat2;
begin
  tmp := identity_mat2;
  GR32.TFixed(tmp.eM21) := Fixed(fx);
  GR32.TFixed(tmp.eM12) := Fixed(fy);
  mat := MultMat2(tmp, mat);
end;
//------------------------------------------------------------------------------

procedure RotateMat2(var mat: TMat2; const angle_radians: single);
var
  cosAng, sinAng: single;
  tmp: TMat2;
begin
  Math.sincos(angle_radians, sinAng, cosAng);
  GR32.TFixed(tmp.eM11) := trunc(cosAng*FixedOne);
  GR32.TFixed(tmp.eM21) := trunc(sinAng*FixedOne);
  GR32.TFixed(tmp.eM12) := trunc(-sinAng*FixedOne);
  GR32.TFixed(tmp.eM22) := trunc(cosAng*FixedOne);
  mat := MultMat2(tmp, mat);
end;
//------------------------------------------------------------------------------

function OffsetPoint(const pt: windows.TPointfx; const dx,dy: single): GR32.TFixedPoint;
begin
 result := TFixedPoint(pt);
 result.X := result.X + Fixed(dx);
 result.Y := result.Y + Fixed(dy);
end;
//------------------------------------------------------------------------------

function StripCRs(const widetext: widestring): widestring;
var
  i: integer;
begin
  result := widetext;
  i := pos(#13, widetext);
  while i <> 0 do
  begin
    delete(result,i,1);
    i := pos(#13, widetext);
  end;
end;
//------------------------------------------------------------------------------

procedure ParseFontCharInfo(info, endInfo: PByte; dx, dy: single;
  out polyPts: TArrayOfArrayOfFixedPoint);
var
  tmpCurvePts: TArrayOfFixedPoint;
  i, polyCnt, ptCnt, ptCntTot: integer;
  endContour:  PByte;
begin
  polyCnt := -1;
  while Info < endInfo do
  begin
    with PTTPolygonHeader(info)^ do
    begin
      if dwType <> TT_POLYGON_TYPE then
        raise Exception.Create('GetGlyphOutline() error - wrong header type');
      endContour := info + cb;
      inc(info, SizeOf(TTTPolygonHeader));
      inc(polyCnt);
      setLength(polyPts, polyCnt +1);
      setlength(polyPts[polyCnt],1);
      polyPts[polyCnt][0] := OffsetPoint(pfxStart, dx, dy);
      ptCntTot := 1;
    end;
    while info < endContour do
    begin
      with PTTPolyCurve(info)^ do
      begin
        ptCnt := cpfx;
        inc(info, SizeOf(Word)*2);
        case wType of
          TT_PRIM_LINE:
            begin
              setlength(polyPts[polyCnt], ptCntTot + ptCnt);
              for i := 0 to ptCnt -1 do
              begin
                polyPts[polyCnt][ptCntTot+i] :=
                  OffsetPoint(PPointfx(info)^, dx, dy);
                inc(info, sizeOf(TPointfx));
              end;
            end;
          TT_PRIM_QSPLINE: //http://support.microsoft.com/kb/q87115/
            begin
              //tmpCurvePts is used for the QSPLINE control points ...
              setLength(tmpCurvePts, ptCnt+1);
              //must include the previous point in the QSPLINE ...
              tmpCurvePts[0] := polyPts[polyCnt][ptCntTot-1];
              for i := 1 to ptCnt do
              begin
                tmpCurvePts[i] := OffsetPoint(PPointfx(info)^, dx, dy);
                inc(info, sizeOf(TPointfx));
              end;
              tmpCurvePts := GetQSplinePoints(tmpCurvePts);
              ptCnt := length(tmpCurvePts)-1;//nb: first point already added
              setlength(polyPts[polyCnt], ptCntTot + ptCnt);
              move(tmpCurvePts[1],
                polyPts[polyCnt][ptCntTot], ptCnt*sizeOf(TFixedPoint));
            end;
          TT_PRIM_CSPLINE:
            begin
              //tmpCurvePts is used for the CSPLINE control points ...
              setLength(tmpCurvePts, ptCnt+1);
              //must include the previous point in the CSPLINE ...
              tmpCurvePts[0] := polyPts[polyCnt][ptCntTot-1];
              for i := 1 to ptCnt do
              begin
                tmpCurvePts[i] := OffsetPoint(PPointfx(info)^, dx, dy);
                inc(info, sizeOf(TPointfx));
              end;
              tmpCurvePts := GetCBezierPoints(tmpCurvePts);
              ptCnt := length(tmpCurvePts)-1;//nb: first point already added
              setlength(polyPts[polyCnt], ptCntTot + ptCnt);
              move(tmpCurvePts[1],
                polyPts[polyCnt][ptCntTot], ptCnt*sizeOf(TFixedPoint));
            end;
          else raise
            Exception.Create('GetGlyphOutline() error - wrong curve type');
        end;
        inc(ptCntTot, ptCnt);
      end;
    end;
  end;
end;
//------------------------------------------------------------------------------

function GetMemoryDeviceContext(font: TFont;
  out MemDC: HDC; out oldFntHdl: HFont): boolean;
begin
  result := false;
  if not assigned(font) then exit;
  memDC := windows.CreateCompatibleDC(0);
  if memDC = 0 then exit;
  oldFntHdl := windows.SelectObject(memDC, font.Handle);
  result := oldFntHdl <> 0;
  if not result then DeleteDC(memDC);
end;
//------------------------------------------------------------------------------

procedure DeleteMemoryDeviceContext(MemDC: HDC; oldFntHdl: HFont);
begin
  windows.SelectObject(memDC, oldFntHdl);
  DeleteDC(memDC);
end;
//------------------------------------------------------------------------------

function GetTTFontCharInfo(MemDC: HDC; wc: wideChar; dx, dy: single;
  mat2: TMat2; Hinted: boolean;
  out gm: TGlyphMetrics; out polyPts: TArrayOfArrayOfFixedPoint): boolean;
var
  size: DWord;
  info, startInfo:  PByte;
const
  hintBool: array[boolean] of UINT = (GGO_UNHINTED, 0);
begin
  startInfo := nil;
  size := windows.GetGlyphOutlineW(memDC,
    cardinal(wc), GGO_NATIVE or hintBool[Hinted], gm, 0, nil, mat2);
  result := (size <> GDI_ERROR);
  if not result or (size = 0) then exit;
  GetMem(info, size);
  try
    startInfo := info;
    if windows.GetGlyphOutlineW(memDC, cardinal(wc),
      GGO_NATIVE or hintBool[Hinted], gm, size, info, mat2) <> GDI_ERROR then
        ParseFontCharInfo(info, info + size, dx, dy, polyPts) else
        result := false;
  finally
    FreeMem(startInfo);
  end;
end;
//------------------------------------------------------------------------------

function GetTTFontCharMetrics(MemDC: HDC; wc: wideChar; dx, dy: single;
  mat2: TMat2; out gm: TGlyphMetrics): boolean;
begin
  result := windows.GetGlyphOutlineW(MemDC, cardinal(wc),
    GGO_METRICS, gm, 0, nil, mat2) <> GDI_ERROR;
end;
//------------------------------------------------------------------------------

//Font smoothing based on an LCD's RGB left-to-right sub-pixel alignment ...
procedure LCDPolygonSmoothing(bitmap, tmpBitmap: TBitmap32;
  ppts: TArrayOfArrayOfArrayOfFixedPoint;
  TextColor: TColor32; BkColor: TColor32 = $0);
var
  i,j,k,m,lft,rt,dx,dy: integer;
  pos: TFloatPoint;
  r: TRect;
  rec: TFixedRect;
  srcEntry, destEntry: PColor32Entry;
  v: byte;
  A,B,txtClr: TColor32Entry;
  tmpBitmapWasAssigned: boolean;
{$IFDEF GR32_PolygonsEx}
  ppts2: TArrayOfArrayOfFloatPoint;
{$ENDIF}
begin
  if not assigned(bitmap) then exit;

  tmpBitmapWasAssigned := assigned(tmpBitmap);
  if not tmpBitmapWasAssigned then tmpBitmap := TBitmap32.Create;
  try
    //stretch points times 3 along the X axis to prepare for sub-pixel
    //antialiasing and also get the boundsrect of these stretched points ...
    rec.Left := Fixed(32767); rec.Right := Fixed(-32767);
    rec.Top := Fixed(32767); rec.Bottom := Fixed(-32767);
    for i := 0 to high(ppts) do
      for j := 0 to high(ppts[i]) do
        for k := 0 to high(ppts[i][j]) do
          with ppts[i][j][k] do
          begin
            //scale X * 3 ...
            X := X *3;
            //update boundsrect ...
            if X < rec.left then rec.left := X;
            if X > rec.right then rec.right := X;
            if Y < rec.top then rec.top := Y;
            if Y > rec.bottom then rec.bottom := Y;
          end;

    if rec.left > rec.Right then exit; //ie nothing to draw

    r := MakeRect(rec, rrOutside);
    gr32.InflateRect(r,2,1);

    OffsetPolyPolyPoints(ppts, -r.Left, -r.Top);
    dx := r.Left;
    dy := r.Top;
    gr32.OffsetRect(r,-dx,-dy);

    //nb: The background needs to be opaque to apply sub-pixel coloring because
    //the algorithm needs both background and foreground colors. However if the
    //background isn't opaque we'll just apply alpha anti-aliasing instead.

    tmpBitmap.SetSize(r.Right, r.Bottom);
    tmpBitmap.Clear;

    for i := 0 to high(ppts) do
    begin
      //draw the stretched polygon onto tmpBmp (white pen on black here)
      {$IFDEF GR32_PolygonsEx}
      ppts2 := MakeArrayOfArrayOfFloatPoints(ppts[i]);
      PolyPolygonFS(tmpBitmap, ppts2, clWhite32, pfWinding);
      {$ELSE}
      PolyPolygonXS(tmpBitmap, ppts[i], clWhite32, pfWinding);
      {$ENDIF}
    end;

    //now apply sub-pixel coloring to tmpBmp ...
    for i := 0 to r.Bottom - 1 do
    begin
      srcEntry := PColor32Entry(tmpBitmap.ScanLine[i]);
      destEntry := srcEntry;

      m := 1;
      A.ARGB := clBlack32;
      B.ARGB := clBlack32;

      for j := 0 to r.Right - 1 do
      begin
        v := srcEntry.R;
        if (m = 0) then
        begin
          Inc(A.R, lut.Tertiary[v]);
          Inc(A.G, lut.Secondary[v]);
          Inc(A.B, lut.Primary[v]);
          Inc(B.R, lut.Secondary[v]);
          Inc(B.G, lut.Tertiary[v]);
          Inc(m);
        end
        else if (m = 1) then
        begin
          Inc(A.G, lut.Tertiary[v]);
          Inc(A.B, lut.Secondary[v]);
          Inc(B.R, lut.Primary[v]);
          Inc(B.G, lut.Secondary[v]);
          Inc(B.B, lut.Tertiary[v]);
          Inc(m);
        end else
        begin
          Inc(A.B, lut.Tertiary[v]);
          Inc(B.R, lut.Secondary[v]);
          Inc(B.G, lut.Primary[v]);
          Inc(B.B, lut.Secondary[v]);

          destEntry^ := A;
          inc(destEntry);
          destEntry^ := B;
          A := B;
          B.ARGB := clBlack32;
          Inc(B.R, lut.Tertiary[v]);
          m := 0;
        end;
        inc(srcEntry);
      end;
      inc(destEntry);
      destEntry^ := B;
    end;

    dx := dx div 3;
    if dx = 0 then dx := 1;
    //now blend onto bitmap ...
    if AlphaComponent(BkColor) <> $0 then BkColor := BkColor or $FF000000;
    txtClr.ARGB := textColor;

    lft := max(0,-dx);
    rt := min(r.Right div 3 +1, bitmap.Width -dx -1);
    for i := max(0,-dy) to min(r.Bottom - 1, bitmap.Height -dy -1) do
    begin
      srcEntry := PColor32Entry(tmpBitmap.ScanLine[i]);
      destEntry := PColor32Entry(bitmap.ScanLine[dy + i]);
      inc(srcEntry, lft);
      inc(destEntry,dx + lft);
      for j := 0 to rt -lft do
      begin
        if srcEntry.ARGB <> clBlack32 then
        begin
          A := destEntry^;
          //if the anti-alias byte is opaque or close to it, do
          //sub-pixel anti-aliasing, otherwise do alpha channel anti-aliasing
          if (A.A < 255) then
            if (bitmap.DrawMode = dmOpaque) or (A.A >= $CC) then A.A := 255
            else if BkColor <> $0 then A.ARGB := BkColor;

          if (A.A = 255) then
          begin
            //do sub-pixel anti-aliasing ...
            A.R := (A.R shl 16 + (txtClr.R - A.R)*(srcEntry.R * txtClr.A)) shr 16;
            A.G := (A.G shl 16 + (txtClr.G - A.G)*(srcEntry.G * txtClr.A)) shr 16;
            A.B := (A.B shl 16 + (txtClr.B - A.B)*(srcEntry.B * txtClr.A)) shr 16;
            destEntry^ := A;
          end else
          begin
            //do alpha channel anti-aliasing ...
            A.R := txtClr.R;
            A.G := txtClr.G;
            A.B := txtClr.B;
            A.A := Intensity(srcEntry.ARGB)* txtClr.A shr 8;
            if bitmap.CombineMode = cmBlend then
              BlendMem(A.ARGB, destEntry.ARGB) else
              MergeMem(A.ARGB, destEntry.ARGB);
          end;
        end;
        inc(srcEntry);
        inc(destEntry);
      end;
    end;
    EMMS;
  finally
    if not tmpBitmapWasAssigned then tmpBitmap.Free;
  end;
end;

//------------------------------------------------------------------------------
// TTrueTypeFont methods
//------------------------------------------------------------------------------

constructor TTrueTypeFont.Create;
begin
  fFont := TFont.Create;
  fFont.Name := 'Arial';
  fFont.Height := 18;
  fFont.Style := [];
  fFont.Charset := 0;
end;
//------------------------------------------------------------------------------


constructor TTrueTypeFont.Create(aFont: TFont);
begin
  Create;
  if not assigned(aFont) then exit;
  if IsValidTTFont(aFont) then fFont.Name := aFont.Name;
  fFont.Height := aFont.Height;
  fFont.Style := aFont.Style;
  fFont.Charset := aFont.Charset;
end;
//------------------------------------------------------------------------------

constructor TTrueTypeFont.Create(const aFontName: TFontName;
      aHeight: integer; aStyle: TFontStyles; aCharSet: TFontCharset);
begin
  Create;
  fFont.Name := aFontName;
  if not IsValidTTFont(fFont) then fFont.Name := 'Arial';
  fFont.Height := aHeight;
  fFont.Style := aStyle;
  fFont.Charset := aCharSet;
end;
//------------------------------------------------------------------------------

destructor TTrueTypeFont.Destroy;
begin
  if IsLocked then
    DeleteMemoryDeviceContext(fMemDC, fOldFntHdl); //just in case
  fFont.Free;
end;
//------------------------------------------------------------------------------

class function TTrueTypeFont.IsValidTTFont(font: TFont): boolean;
var
  memDC: HDC;
  oldFontHdl: HFont;
  gm: TGlyphMetrics;
  mat2: TMat2;
begin
  result := false;
  if not assigned(font) then exit;
  memDC := windows.CreateCompatibleDC(0);
  oldFontHdl := windows.SelectObject(memDC, Font.Handle);
  if oldFontHdl <> 0 then
  begin
    mat2 := identity_mat2;
    result := windows.GetGlyphOutlineW(memDC,
      $21, GGO_METRICS, gm, 0, nil, mat2) <> GDI_ERROR;
    windows.SelectObject(memDC, oldFontHdl);
  end;
  windows.DeleteDC(memDC);
end;
//------------------------------------------------------------------------------

function TTrueTypeFont.IsLocked: boolean;
begin
  result := fOldFntHdl <> 0;
end;
//------------------------------------------------------------------------------

function TTrueTypeFont.Lock: boolean;
begin
  result := not IsLocked;
  if not result then exit;
  result := GetMemoryDeviceContext(fFont, fMemDC, fOldFntHdl);
end;
//------------------------------------------------------------------------------

procedure TTrueTypeFont.Unlock;
begin
  if IsLocked then
    DeleteMemoryDeviceContext(fMemDC, fOldFntHdl);
  fMemDC := 0;
  fOldFntHdl := 0;
end;
//------------------------------------------------------------------------------

procedure TTrueTypeFont.Flush;
begin
  fFlushed := true;
end;
//------------------------------------------------------------------------------

function TTrueTypeFont.GetFontName: TFontName;
begin
  result := fFont.Name;
end;
//------------------------------------------------------------------------------

procedure TTrueTypeFont.SetFontName(const aFontName: TFontName);
var
  oldFontName: TFontName;
begin
  oldFontName := fFont.Name;
  if SameText(aFontName, oldFontName) then exit;
  fFont.Name := aFontName;
  if not IsValidTTFont(fFont) then fFont.Name := oldFontName;
  Flush;
end;
//------------------------------------------------------------------------------

function TTrueTypeFont.GetHeight: integer;
begin
  result := fFont.Height;
end;
//------------------------------------------------------------------------------

procedure TTrueTypeFont.SetHeight(aHeight: integer);
begin
  if fFont.Height = aHeight then exit;
  fFont.Height := aHeight;
  Flush;
end;
//------------------------------------------------------------------------------

function TTrueTypeFont.GetSize: integer;
begin
  result := fFont.Size;
end;
//------------------------------------------------------------------------------

procedure TTrueTypeFont.SetSize(aSize: integer);
begin
  if fFont.Size = aSize then exit;
  fFont.Size := aSize;
  Flush;
end;
//------------------------------------------------------------------------------

function TTrueTypeFont.GetStyle: TFontStyles;
begin
  result := fFont.Style;
end;
//------------------------------------------------------------------------------

procedure TTrueTypeFont.SetStyle(aStyle: TFontStyles);
begin
  if fFont.Style = aStyle then exit;
  fFont.Style := aStyle;
  Flush;
end;
//------------------------------------------------------------------------------

function TTrueTypeFont.GetCharSet: TFontCharset;
begin
  result := fFont.Charset;
end;
//------------------------------------------------------------------------------

procedure TTrueTypeFont.SetCharSet(aCharSet: TFontCharset);
begin
  if fFont.Charset = aCharset then exit;
  fFont.Charset := aCharset;
  Flush;
end;
//------------------------------------------------------------------------------

procedure TTrueTypeFont.SetHinted(value: boolean);
begin
  if fHinted = value then exit;
  fHinted := value;
  Flush;
end;
//------------------------------------------------------------------------------

procedure TTrueTypeFont.Assign(Source: TPersistent);
begin
  if IsLocked then exit;
  if (Source is TFont) and IsValidTTFont(TFont(Source)) then
    with TFont(Source) do
    begin
      fFlushed := true;
      fFont.Name := Name;
      fFont.Height := Height;
      fFont.Style := Style;
      fFont.Charset := CharSet;
    end
  else if Source is TTrueTypeFont then
    with TTrueTypeFont(Source) do
    begin
      self.fFlushed := true;
      self.fFont.Name := FontName;
      self.fFont.Height := Height;
      self.fFont.Style := Style;
      self.fFont.Charset := CharSet;
    end else
      inherited;
end;
//------------------------------------------------------------------------------

function TTrueTypeFont.GetGlyphInfo(wc: wideChar; out gm: TGlyphMetrics;
  out polyPts: TArrayOfArrayOfFixedPoint): boolean;
begin
  result := IsLocked;
  if not result then exit;
  result := GetTTFontCharInfo(fMemDC,wc,0,0,vert_flip_mat2,fHinted,gm,polyPts);
end;
//------------------------------------------------------------------------------

function TTrueTypeFont.GetTextMetrics(out tm: TTextMetric): boolean;
var
  wasUnlocked: boolean;
begin
  wasUnlocked := Lock;
  try
    result := windows.GetTextMetrics(fMemDC, tm);
  finally
    if wasUnlocked then UnLock;
  end;
end;
//------------------------------------------------------------------------------

function TTrueTypeFont.GetOutlineTextMetrics(out otm: TOutlineTextmetric): boolean;
var
  wasUnlocked: boolean;
begin
  wasUnlocked := Lock;
  try
    otm.otmSize := sizeof(TOutlineTextmetric);
    result :=
      windows.GetOutlineTextMetrics(fMemDC, sizeof(TOutlineTextmetric), @otm) <> 0;
  finally
    if wasUnlocked then UnLock;
  end;
end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

function TTrueTypeFontAnsiCache.GetGlyphInfo(wc: wideChar;
  out gm: TGlyphMetrics; out polyPts: TArrayOfArrayOfFixedPoint): boolean;
var
  i: integer;
begin
  result := IsLocked;
  if not result then exit;

  if Flushed then
  begin
    for i := low(fGlyphInfo) to high(fGlyphInfo) do
      fGlyphInfo[i].cached := false;
    Flushed := false;
  end;

  if ord(wc) in [32..127] then
    with fGlyphInfo[ord(wc)] do
    begin
      if cached then
      begin
        gm := metrics;
        polyPts := CopyPolyPoints(pts);
        result := true;
      end else
      begin
        cached :=
          GetTTFontCharInfo(MemDC,wc,0,0,vert_flip_mat2,Hinted,metrics,pts);
        result := cached;
        if not result then exit;
        gm := metrics;
        polyPts := CopyPolyPoints(pts);
      end;
    end
  else
    result := GetTTFontCharInfo(MemDC,wc,0,0,vert_flip_mat2,Hinted,gm,polyPts);
end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

constructor TText32.Create;
begin
  fTmpBmp := TBitmap32.Create;
  fScale.sx := 1;
  fScale.sy := 1;
  fLCDDraw := Text32LCDDrawDefault;
end;
//------------------------------------------------------------------------------

destructor TText32.Destroy;
begin
  fTmpBmp.Free;
  inherited;
end;
//------------------------------------------------------------------------------

procedure TText32.SetInverted(value: boolean);
begin
  if fInverted = value then exit;
  fInverted := value;
end;
//------------------------------------------------------------------------------

procedure TText32.SetMirrored(value: boolean);
begin
  if fMirrored = value then exit;
  fMirrored := value;
end;
//------------------------------------------------------------------------------

procedure TText32.SetAngle(value: integer);
begin
  value := value mod 360;
  if value > 180 then value := value - 360
  else if value < -180 then value := value + 360;
  fAngle := value;
end;
//------------------------------------------------------------------------------

procedure TText32.Skew(sx, sy: single);
begin
  SetSkewX(sx);
  SetSkewY(sy);
end;
//------------------------------------------------------------------------------

procedure TText32.SetSkewX(value: single);
begin
  if value < -2 then value := -2 else if value > 2 then value := 2;
  fSkew.sx := value;
end;
//------------------------------------------------------------------------------

procedure TText32.SetSkewY(value: single);
begin
  if value < -20 then value := -20 else if value > 20 then value := 20;
  fSkew.sy := value;
end;
//------------------------------------------------------------------------------

procedure TText32.Scale(sx, sy: single);
begin
  SetScaleX(sx);
  SetScaleY(sy);
end;
//------------------------------------------------------------------------------

procedure TText32.SetScaleX(value: single);
begin
  if value < 0.001 then value := 0.001
  else if value > 200 then value := 200;
  fScale.sx := value;
end;
//------------------------------------------------------------------------------

procedure TText32.SetScaleY(value: single);
begin
  if value < 0.001 then value := 0.001
  else if value > 200 then value := 200;
  fScale.sy := value;
end;
//------------------------------------------------------------------------------

procedure TText32.Translate(dx, dy: TFloat);
begin
  fTranslate.sx := dx;
  fTranslate.sy := dy;
end;
//------------------------------------------------------------------------------

procedure TText32.ClearTransformations;
begin
  fTranslate.sx := 0;
  fTranslate.sy := 0;
  fSkew.sx := 0;
  fSkew.sy := 0;
  fScale.sx := 1;
  fScale.sy := 1;
  fMirrored := false;
  fInverted := false;
  fAngle := 0;
end;
//------------------------------------------------------------------------------

procedure TText32.SetPadding(value: single);
begin
  if value < -5 then value := -5
  else if value > 20 then value := 20;
  fPadding := value;
end;
//------------------------------------------------------------------------------

function TText32.GetTextFixedRect(X, Y: single;
  const text: UnicodeString; ttFont: TTrueTypeFont): TFixedRect;
var
  pt: TFixedPoint;
begin
  pt := FixedPoint(0,0);
  GetTextMetrics(text, ttFont, FixedPoint(X,Y), pt, result);
end;
//------------------------------------------------------------------------------

function TText32.GetTextHeight(const text: UnicodeString;
  ttFont: TTrueTypeFont): single;
begin
  with GetTextFixedRect(0, 0, text, ttFont) do
    result := (Bottom - Top) *FixedToFloat;
end;
//------------------------------------------------------------------------------

function TText32.GetTextWidth(const text: UnicodeString;
  ttFont: TTrueTypeFont): single;
begin
  with GetTextFixedRect(0,0,text,ttFont) do
    result := (Right - Left) *FixedToFloat;
end;
//------------------------------------------------------------------------------

procedure TText32.Draw(bitmap: TBitmap32; const boundsRect: TFloatRect;
  const text: UnicodeString; ttFont: TTrueTypeFont; color: TColor32;
  alignH: TAlignH; alignV: TAlignV; forceWordBreak: boolean = false);
var
  i: integer;
  ppts: TArrayOfArrayOfArrayOfFixedPoint;
{$IFDEF GR32_PolygonsEx}
  ppts2: TArrayOfArrayOfFloatPoint;
{$ENDIF}
begin
  ppts := GetEx(boundsRect, text, ttFont, alignH, alignV, forceWordBreak);
  if fLCDDraw then
    LCDPolygonSmoothing(bitmap, fTmpBmp, ppts, color)
  else
{$IFDEF GR32_PolygonsEx}
    for i := 0 to high(ppts) do
    begin
      ppts2 := MakeArrayOfArrayOfFloatPoints(ppts[i]);
      PolyPolygonFS(bitmap, ppts2, color, pfWinding);
    end;
{$ELSE}
    for i := 0 to high(ppts) do
      PolyPolygonXS(bitmap, ppts[i], color, pfWinding);
{$ENDIF}
end;
//------------------------------------------------------------------------------

{$WARNINGS OFF} //prevents a warning about a potentially unassigned result.
function TText32.GetEx(const boundsRect: TFloatRect;
  const text: UnicodeString; ttFont: TTrueTypeFont; alignH: TAlignH;
  alignV: TAlignV; forceWordBreak: boolean = false): TArrayOfArrayOfArrayOfFixedPoint;
var
  i, j, k, len, cntChrsThatFit, spcCnt, lineCnt, lineHeight, maxLines, savedAngle: integer;
  theText, theLine: UnicodeString;
  lineWidth, descenderSpace, yPos, savedSkewY: single;
  spaceWidth, spaceChrPadding, lastSpaceChrPadding: single;
  origin: TFixedPoint;
  pt: TFloatPoint;
  a, adjustedLeft: single;
  textBeforeLineFeed: boolean;
  cp: TFixedPoint;
  tm: TTextMetric;

  procedure GetAdjustedLeft;
  begin
    //adjust Left to compensate for skewing etc ...
    adjustedLeft :=
      GetTextFixedRect(0,0, theText[1], ttFont).Left *FixedToFloat;;
    if adjustedLeft < 0 then
      adjustedLeft := boundsRect.Left - adjustedLeft else
      adjustedLeft := boundsRect.Left;
    //and to help text to look just a tiny bit better ...
    adjustedLeft := Round(adjustedLeft);
  end;

begin
  //nb: this method requires horizontal text ...
  savedAngle := fAngle;
  savedSkewY := fSkew.sy;
  fAngle := 0;
  fSkew.sy := 0;
  try
    ttFont.GetTextMetrics(tm);
    lineHeight := round((tm.tmHeight+tm.tmExternalLeading) * fScale.sy);
    descenderSpace := tm.tmDescent * fScale.sy;
    maxLines :=
      trunc((boundsRect.Bottom - boundsRect.Top - descenderSpace)/lineHeight);

    //text is *much* clearer when the baseline is set to an integer ...
    yPos := round(boundsRect.Top + lineHeight -descenderSpace);
    //for vertical alignment, calculate the number of lines to be displayed ...
    if alignV <> aTop then
    begin
      theText := StripCRs(trim(text));
      lineCnt := 0;
      textBeforeLineFeed := false;
      while length(theText) > 0 do
      begin
        if (lineCnt > maxLines) then break;
        if (yPos+descenderSpace > boundsRect.Bottom) then
        begin
          lineCnt := maxLines+1;
          break;
        end;
        GetAdjustedLeft;
        cntChrsThatFit := CountCharsThatFit(adjustedLeft, yPos,
          theText, ttFont, boundsRect, forceWordBreak);
        if cntChrsThatFit = 0 then
        begin
          lineCnt := maxLines+1;
          break;
        end;
        if (cntChrsThatFit = 1) and (theText[1] = LF) then
        begin
          if textBeforeLineFeed then yPos := yPos - lineHeight
          else inc(lineCnt);
          textBeforeLineFeed := false;
        end else
        begin
          textBeforeLineFeed := true;
          inc(lineCnt);
        end;
        while theText[cntChrsThatFit+1] = SPACE do inc(cntChrsThatFit);
        delete(theText,1,cntChrsThatFit);
        yPos := yPos + lineHeight;
      end;
      //now adjust starting the yPos based on the number of displayed lines ...
      yPos := boundsRect.Top + lineHeight -descenderSpace;
      if lineCnt <= maxLines then
        case alignV of
          aMiddle: yPos := boundsRect.Top + (lineHeight - descenderSpace) +
            (boundsRect.Bottom -boundsRect.Top - lineCnt*lineHeight)/2;
          aBottom:
            yPos := boundsRect.Bottom -1 - descenderSpace - (lineCnt-1)*lineHeight;
        end;
      //text is *much* clearer when the baseline is set to an integer ...
      yPos := round(yPos);
    end;

    textBeforeLineFeed := false;
    theText := StripCRs(trim(text));
    len := length(theText);
    spaceWidth := GetTextWidth(' ', ttFont);
    while len > 0 do
    begin
      if yPos+ descenderSpace > boundsRect.Bottom then break;
      GetAdjustedLeft;
      cntChrsThatFit := CountCharsThatFit(adjustedLeft, yPos,
        theText, ttFont, boundsRect, forceWordBreak);
      if cntChrsThatFit = 0 then
        break
      else if (cntChrsThatFit = 1) and (theText[1] = LF) then
      begin
        delete(theText,1,1);
        dec(len);
        if not textBeforeLineFeed then
          yPos := yPos + lineHeight;
        textBeforeLineFeed := false;
        continue;
      end;
      textBeforeLineFeed := true;

      //ie trim any trailing spaces in 'theLine' ...
      while theText[cntChrsThatFit] = SPACE do dec(cntChrsThatFit);
      theLine := copy(theText, 1, cntChrsThatFit);

      case alignH of
        aLeft:
          begin
            i := length(result);
            setlength(result, i+1);
            result[i] := Get(adjustedLeft, yPos, theLine, ttFont, pt);
          end;
        aRight:
          begin
            lineWidth := GetTextWidth(theLine, ttFont);
            i := length(result);
            setlength(result, i+1);
            result[i] := Get(boundsRect.Right - lineWidth, yPos, theLine, ttFont, pt);
          end;
        aCenter:
          begin
            lineWidth := GetTextWidth(theLine, ttFont);
            i := length(result);
            setlength(result, i+1);
            with boundsRect do
              result[i] := Get(adjustedLeft + (Right - Left - lineWidth)/2,
                yPos, theLine, ttFont, pt);
          end;
        aJustify:
          begin
            lineWidth := GetTextWidth(theLine, ttFont);
            //count no. spaces in theLine ...
            spcCnt := 0;
            for i := 1 to length(theLine) do if theLine[i] = ' ' then inc(spcCnt);
            j := cntChrsThatFit+1;
            while (j < len) and (theText[j] = SPACE) do inc(j);
            if (spcCnt = 0) or (cntChrsThatFit = len) or (theText[j] = LF) then
            begin
              i := length(result);
              setlength(result, i+1);
              result[i] := Get(adjustedLeft, yPos, theLine, ttFont, pt);
            end else
            begin
              with boundsRect do
              begin
                spaceChrPadding := round((Right - Left - lineWidth)/spcCnt);
                lastSpaceChrPadding := spaceChrPadding -
                  (spaceChrPadding*spcCnt - (Right - Left - lineWidth));
              end;
              pt := FloatPoint(adjustedLeft, yPos);

              //break up 'theLine' into words so there's less work for Draw ...
              j := length(theLine);
              while j > 0 do
              begin
                i := 1;
                while (i < j) and (theLine[i+1] <> SPACE) do inc(i);
                k := length(result);
                setlength(result, k+1);
                result[k] := Get(pt.X, pt.Y, copy(theLine,1,i), ttFont, pt);
                inc(i);
                while (i <= j) and (theLine[i] = SPACE) do
                begin
                  dec(spcCnt);
                  if spcCnt = 1 then
                    pt.X := pt.X + spaceWidth + lastSpaceChrPadding else
                    pt.X := pt.X + spaceWidth + spaceChrPadding;
                  inc(i);
                end;
                delete(theLine,1,i-1);
                j := length(theLine);
              end;
            end;
          end;
      end;
      while theText[cntChrsThatFit+1] = SPACE do inc(cntChrsThatFit);
      delete(theText,1,cntChrsThatFit);
      dec(len, cntChrsThatFit);
      yPos := yPos + lineHeight;
    end;
  finally
    fAngle := savedAngle;
    fSkew.sy := savedSkewY;
  end;

  if (fAngle <> 0) and assigned(result) then
  begin
    a := Angle*DegToRad;
    with boundsRect do origin := FixedPoint((Left+right)/2, (top+bottom)/2);
    for i := 0 to high(result) do
      for j := 0 to high(result[i]) do
        result[i][j] := RotatePoints(result[i][j], origin, a);
  end;
end;
//------------------------------------------------------------------------------
{$WARNINGS ON}
function TText32.CountCharsThatFit(X, Y: single; const text: UnicodeString;
  ttFont: TTrueTypeFont;
  const boundsRect: TFloatRect; forceWordBreak: boolean = false): integer;
var
  i,j,len: integer;
  thisWord: UnicodeString;
  ip, nextIp: TFixedPoint;
  rec, boundsRec: TFixedRect;
begin
  result := 0;
  len := length(text);
  if len = 0 then exit;
  j := 1;
  //nb: Character outlines can sometimes (and regularly with skewing)
  //begin a fraction of a pixel before X. If the first glyph's outline in
  //'text' does overlap X when X = boundRect.left then this method could
  //return 0 because the glyph doesn't strictly fit within boundRect. Hence ...
  if X-1 <= boundsRect.Left then X := X +1;
  ip := FixedPoint(X,Y);
  boundsRec := FixedRect(boundsRect);
  if not FixedPtInRect(boundsRec, ip) then exit;

  if text[1] = LF then
  begin
    result := 1;
    exit;
  end;

  while j <= len do
  begin
    i := j;
    //try to break the text on a word break ...
    while (j <= len) and (text[j] = SPACE) do inc(j); //ignore leading spaces
    if (j > len) then break
    else if (text[j] = LF) then break
    else while (j <= len) and (text[j] > SPACE) do inc(j); //find trailing space
    thisWord := copy(text, i, j - i);
    GetTextMetrics(thisWord, ttFont, ip, nextIp, rec);
    if (rec.Left+1 < boundsRec.Left) or (rec.Right > boundsRec.Right) or
      (rec.Top < boundsRec.Top) or (rec.Bottom > boundsRec.Bottom) then
    begin
      //if at least one word fits then quit ...
      if (result > 0) or ForceWordBreak then exit;
      //since a whole word doesn't fit, find the max no. chars that do ...
      j := 1;
      while j <= len do
      begin
        thisWord := copy(text, 1, j);
        GetTextMetrics(thisWord, ttFont, ip, nextIp, rec);
        if (rec.Left < boundsRec.Left) or (rec.Right > boundsRec.Right) or
           (rec.Top < boundsRec.Top) or (rec.Bottom > boundsRec.Bottom) then
             exit;
        result := j;
        inc(j);
      end;
      exit;
    end;
    result := j -1;
    ip := nextIp;
  end;
end;
//------------------------------------------------------------------------------

procedure TText32.PrepareMatrices;
begin
  fGlyphMatrix := identity_mat2;
  if mirrored then fGlyphMatrix.eM11.value := -1;
  if inverted then fGlyphMatrix.eM22.value := -1;
  fCurrentPosMatrix := fGlyphMatrix;
  if (fScale.sx <> 1) or (fScale.sy <> 1) then
    ScaleMat2(fGlyphMatrix, fScale.sx, fScale.sy);
  if (fScale.sx <> 1) then
    ScaleMat2(fCurrentPosMatrix, fScale.sx, 1);
  fUnrotatedMatrix := fGlyphMatrix;
  if (fSkew.sx <> 0) or (fSkew.sy <> 0) then
  begin
    SkewMat2(fGlyphMatrix, fSkew.sx, fSkew.sy);
    if (fSkew.sx <> 0) then SkewMat2(fUnrotatedMatrix, fSkew.sx, 0);
    if (fSkew.sy <> 0) then SkewMat2(fCurrentPosMatrix, 0, -fSkew.sy);
  end;
  if (fAngle <> 0) then
  begin
    RotateMat2(fGlyphMatrix, fAngle * degToRad);
    RotateMat2(fCurrentPosMatrix, -fAngle * degToRad);
  end;
end;
//------------------------------------------------------------------------------

procedure TText32.GetTextMetrics(const text: UnicodeString;
  ttFont: TTrueTypeFont; const InsertionPt: TFixedPoint;
  out NextInsertionPt: TFixedPoint; out BoundsRect: TFixedRect);
var
  i, len: integer;
  p: TFloatPoint;
  gm: TGlyphMetrics;
  fixedRec2: TFixedRect;
  tmpPolyPts: TArrayOfArrayOfFixedPoint;
begin
  NextInsertionPt.X := InsertionPt.X + Fixed(fTranslate.sx);
  NextInsertionPt.Y := InsertionPt.Y + Fixed(fTranslate.sy);
  with NextInsertionPt do BoundsRect := FixedRect(X,Y,X,Y);
  len := length(text);
  if (len = 0) or not assigned(ttFont) then exit;
  PrepareMatrices;

  if not ttFont.Lock then exit;
  try
    for i := 1 to len do
    begin
      //get each untransformed glyph ...
      if not ttFont.GetGlyphInfo(text[i], gm, tmpPolyPts) then break;

      if length(tmpPolyPts) = 0 then //ie if a space
      begin
        setlength(tmpPolyPts,1);
        setlength(tmpPolyPts[0],2);
        tmpPolyPts[0][0] := FixedPoint(0,0);
        tmpPolyPts[0][1] := FixedPoint(gm.gmCellIncX, 0);
      end;

      //do matrix transformations ...
      TransformPolyPoints(fGlyphMatrix, NextInsertionPt, tmpPolyPts);

      //enlarge BoundsRect to fit the glyph ...
      fixedRec2 := GetBoundsFixedRect(tmpPolyPts);
      BoundsRect := GetRectUnion(BoundsRect, fixedRec2);

      //finally update the current position ...
      p := FloatPoint(gm.gmCellIncX + fPadding, gm.gmCellIncY);
      TransformPoint(fCurrentPosMatrix, p);
      NextInsertionPt.X := NextInsertionPt.X + Fixed(p.X);
      NextInsertionPt.Y := NextInsertionPt.Y - Fixed(p.Y);
    end;
  finally
    ttFont.Unlock;
  end;
end;
//------------------------------------------------------------------------------

procedure TText32.GetDrawInfo(const text: UnicodeString;
  ttFont: TTrueTypeFont; const InsertionPt: TFloatPoint;
  out NextInsertionPt: TFloatPoint; out polyPolyPts: TArrayOfArrayOfArrayOfFixedPoint);
var
  i,len: integer;
  gm: TGlyphMetrics;
  cp, p: TFloatPoint;
begin
  if (text = '') or not assigned(ttFont) then exit;
  PrepareMatrices;

  //cp := FloatPoint(InsertionPt.X+ fTranslate.sx, InsertionPt.Y + fTranslate.sy);

  //note: text is clearest when derived using integer coordinates...
  cp := FloatPoint(round(InsertionPt.X+ fTranslate.sx),
    round(InsertionPt.Y + fTranslate.sy));

  if not ttFont.Lock then exit;
  try
    len := length(text);
    setlength(polyPolyPts, len);
    for i := 0 to len-1 do
    begin
      //first, get each untransformed glyph ...
      if not ttFont.GetGlyphInfo(text[i+1], gm, polyPolyPts[i]) then break;

      //do matrix transformations ...
      TransformPolyPoints(fGlyphMatrix, FixedPoint(cp), polyPolyPts[i]);

      //update the current position ...
      p := FloatPoint(gm.gmCellIncX + fPadding, gm.gmCellIncY);
      TransformPoint(fCurrentPosMatrix, p);

      cp.X := cp.X + p.X;
      cp.Y := cp.Y - p.Y;
    end;
  finally
    ttFont.UnLock;
  end;
  NextInsertionPt.X := cp.X - fTranslate.sx;
  NextInsertionPt.Y := cp.Y - fTranslate.sy;
end;
//------------------------------------------------------------------------------

procedure TText32.DrawInternal(bitmap: TBitmap32; const text: UnicodeString;
  ttFont: TTrueTypeFont; color: TColor32);
var
  i: integer;
  fontCacheAssigned: boolean;
  ppts: TArrayOfArrayOfArrayOfFixedPoint;
  pos: TFloatPoint;
{$IFDEF GR32_PolygonsEx}
  ppts2: TArrayOfArrayOfFloatPoint;
{$ENDIF}
begin
  if text = '' then exit;
  fontCacheAssigned := assigned(ttFont);
  if not fontCacheAssigned then
    ttFont := TTrueTypeFont.Create(bitmap.Font);
  try
    GetDrawInfo(text, ttFont, FloatPoint(fCurrentPos), pos, ppts);
    for i := 0 to high(ppts) do
    begin
      {$IFDEF GR32_PolygonsEx}
      ppts2 := MakeArrayOfArrayOfFloatPoints(ppts[i]);
      PolyPolygonFS(bitmap, ppts2, color, pfWinding);
      {$ELSE}
      PolyPolygonXS(bitmap, ppts[i], color, pfWinding);
      {$ENDIF}
    end;
    fCurrentPos := FixedPoint(pos);
  finally
    if not fontCacheAssigned then ttFont.Free;
  end;
end;
//------------------------------------------------------------------------------

procedure TText32.DrawInternalLCD(bitmap: TBitmap32; const text: UnicodeString;
  ttFont: TTrueTypeFont; color: TColor32);
var
  fontCacheAssigned: boolean;
  pos: TFloatPoint;
  ppts: TArrayOfArrayOfArrayOfFixedPoint;
begin
  if text = '' then exit;
  fontCacheAssigned := assigned(ttFont);
  if not fontCacheAssigned then
    ttFont := TTrueTypeFont.Create(bitmap.Font);
  try
    GetDrawInfo(text, ttFont, FloatPoint(fCurrentPos), pos, ppts);
    LCDPolygonSmoothing(bitmap, fTmpBmp, ppts, color);
    fCurrentPos := FixedPoint(pos);
  finally
    if not fontCacheAssigned then ttFont.Free;
  end;
end;
//------------------------------------------------------------------------------

procedure TText32.Draw(bitmap: TBitmap32; const text: UnicodeString;
  ttFont: TTrueTypeFont; color: TColor32);
begin
  if fLCDDraw then
    DrawInternalLCD(bitmap, text, ttFont, color) else
    DrawInternal(bitmap, text, ttFont, color);
end;
//------------------------------------------------------------------------------

procedure TText32.Draw(bitmap: TBitmap32; X, Y: single;
  const text: UnicodeString; ttFont: TTrueTypeFont; color: TColor32);
begin
  SetCurrentPos(FixedPoint(X, Y));
  if fLCDDraw then
    DrawInternalLCD(bitmap, text, ttFont, color) else
    DrawInternal(bitmap, text, ttFont, color);
end;
//------------------------------------------------------------------------------

procedure TText32.Draw(bitmap: TBitmap32; const path: array of TFixedPoint;
  const text: UnicodeString; ttFont: TTrueTypeFont; color: TColor32;
  alignH: TAlignH = aCenter; alignV: TAlignV = aMiddle; offsetFromLine: single = 0);
var
  i: integer;
  glyphPts: TArrayOfArrayOfArrayOfFixedPoint;
{$IFDEF GR32_PolygonsEx}
  ppts2: TArrayOfArrayOfFloatPoint;
{$ENDIF}
begin
  if text = '' then exit;
  glyphPts := GetEx(path, text, ttFont, alignH, alignV, true, offsetFromLine);
  if fLCDDraw then
    LCDPolygonSmoothing(bitmap, fTmpBmp, glyphPts, color)
  else
    for i := 0 to high(glyphPts) do
      {$IFDEF GR32_PolygonsEx}
      ppts2 := MakeArrayOfArrayOfFloatPoints(glyphPts[i]);
      PolyPolygonFS(bitmap, ppts2, color, pfWinding);
      {$ELSE}
      PolyPolygonXS(bitmap, glyphPts[i], color, pfWinding);
      {$ENDIF}
end;
//------------------------------------------------------------------------------

procedure TText32.DrawAndOutline(bitmap: TBitmap32; X, Y: single;
  const text: UnicodeString; ttFont: TTrueTypeFont;
  outlinePenWidth: single; outlineColor, fillColor: TColor32);
var
  i,j: integer;
  ppts: TArrayOfArrayOfArrayOfFixedPoint;
  NextInsertionPt: TFloatPoint;
{$IFDEF GR32_PolygonsEx}
  ppts2: TArrayOfArrayOfFloatPoint;
{$ENDIF}
begin
  if text = '' then exit;
  ppts := GetEx(X, Y, text, ttFont, NextInsertionPt);

  if AlphaComponent(fillColor) > 0 then
  begin
    for i := 0 to high(ppts) do
      {$IFDEF GR32_PolygonsEx}
      ppts2 := MakeArrayOfArrayOfFloatPoints(ppts[i]);
      PolyPolygonFS(bitmap, ppts2, fillColor, pfWinding);
      {$ELSE}
      PolyPolygonXS(bitmap, ppts[i], fillColor, pfWinding);
      {$ENDIF}
  end;

  with TLine32.Create do
  try
    EndStyle := esClosed;
    for i := 0 to high(ppts) do
      for j := 0 to high(ppts[i]) do
      begin
        SetPoints(ppts[i][j]);
        Draw(bitmap, outlinePenWidth, outlineColor);
      end;
  finally
    free;
  end;
end;
//------------------------------------------------------------------------------

function TText32.Get(const path: array of TFixedPoint;
  const text: UnicodeString; ttFont: TTrueTypeFont; alignH: TAlignH;
  alignV: TAlignV; rotateTextToPath:
  boolean; offsetFromLine: single = 0): TArrayOfArrayOfFixedPoint;
var
  i: integer;
  tmp: TArrayOfArrayOfArrayOfFixedPoint;
begin
  result := nil;
  tmp := GetEx(path, text, ttFont, alignH, alignV, rotateTextToPath, offsetFromLine);
  for i := 0 to high(tmp) do
    ConcatenatePolyPoints(result, tmp[i]);
end;
//------------------------------------------------------------------------------

function TText32.GetEx(const path: array of TFixedPoint;
  const text: UnicodeString; ttFont: TTrueTypeFont; alignH: TAlignH;
  alignV: TAlignV; rotateTextToPath: boolean;
  offsetFromLine: single = 0): TArrayOfArrayOfArrayOfFixedPoint;
var
  i, j, k, chrCnt, startChrIdx, endChrIdx: integer;
  rec, tmpRec: TFixedRect;
  pathLen, dy: single;
  cumulDists: array of single;
  normals: array of TFloatPoint;
  nextOffset, xOffset: single;
  gm: TGlyphMetrics;
  thePath: TArrayOfFixedPoint;

  procedure TransformPt(var pt: TFixedPoint);
  var
    i,highI: Integer;
    X, Y, dx, dist: single;
    pathPt: TFixedPoint;
  begin
    if alignH = aJustify then
      X := pt.X*FixedToFloat * pathLen /(rec.Right*FixedToFloat) else
      X := (pt.X+xOffset)*FixedToFloat;
    i := 0;
    highI := high(thePath);
    while (i < highI) and (X > cumulDists[i+1]) do inc(i);
    dx := (X - cumulDists[i])/(cumulDists[i+1]-cumulDists[i]);
    pathPt.X := thePath[i].X + Round(dx *(thePath[i+1].X - thePath[i].X));
    pathPt.Y := thePath[i].Y + Round(dx *(thePath[i+1].Y - thePath[i].Y));
    if rotateTextToPath then
    begin
      dist := -pt.Y;
      //the strictly 'correct' positions for rotated points is to use
      //normal[i], but this can badly distort text passing over line joins.
      //To lessen this distortion it's worth graduating angle changes for
      //points close to joins (ie within a pixel or two of a join) ...
      if ((1-dx)*(cumulDists[i+1]-cumulDists[i]) < 2) then
      begin
        X := (1-dx)*normals[i].X + dx*normals[i+1].X;
        Y := (1-dx)*normals[i].Y + dx*normals[i+1].Y;
        pt.X := pathPt.X + round(X *dist);
        pt.Y := pathPt.Y + round(Y *dist);
      end else
      begin
        pt.X := pathPt.X + round(normals[i].X *dist);
        pt.Y := pathPt.Y + round(normals[i].Y *dist);
      end;
    end else
    begin
      pt.X := pathPt.X;
      pt.Y := pathPt.Y + pt.Y;
    end;
  end;

begin
  result := nil;
  chrCnt := length(text);
  //it's important to strip duplicate points otherwise normals are buggy ...
  thePath := StripDuplicatePoints(path);
  if (chrCnt = 0) or (length(thePath) < 2) then exit;

  setLength(cumulDists, length(thePath));
  setLength(normals, length(thePath));
  cumulDists[0] := 0;
  pathLen := 0;
  for i := 1 to high(thePath) do
  begin
    pathLen := pathLen + DistBetweenPoints(thePath[i-1], thePath[i]);
    cumulDists[i] := pathLen;
    normals[i-1] := GetUnitNormal(thePath[i-1], thePath[i]);
  end;
  i := high(thePath);
  normals[i] := normals[i-1];

  nextOffset := 0;
  PrepareMatrices;

  case alignV of
    aBottom: dy := GetTextFixedRect(0,0,text,ttFont).bottom*FixedToFloat;
    aTop   : dy := GetTextFixedRect(0,0,text,ttFont).top*FixedToFloat -4;
    else dy := 0;
  end;
  dy := dy + offsetFromLine +2;

  if not ttFont.Lock then exit;
  try
    setlength(result, chrCnt);
    for i := 0 to chrCnt-1 do
    begin
      //get each untransformed glyph ...
      if not ttFont.GetGlyphInfo(text[i+1], gm, result[i]) then break;

      //do matrix transformations ...
      TransformPolyPoints(fUnrotatedMatrix, FixedPoint(0,-dy), result[i]);

      //1. horizontally offset each set of glyph points and also
      //2. get the height and width of the text ...
      if i = 0 then
      begin
        rec := GetBoundsFixedRect(result[i]);
        nextOffset := gm.gmCellIncX*fScale.sx + fPadding;
      end else
      begin
        OffsetPolyPoints(result[i], nextOffset, 0);
        tmpRec := GetBoundsFixedRect(result[i]);
        rec := GetRectUnion(rec, tmpRec);
        nextOffset := nextOffset + gm.gmCellIncX*fScale.sx + fPadding;
        if (i = chrCnt -1) and (text[chrCnt] = #32) then
          rec.Right := Fixed(nextOffset);
      end;

    end;
  finally
    ttFont.UnLock;
  end;

  if (rec.Left = rec.Right) or (rec.Top = rec.Bottom) then exit;

  case alignH of
    aCenter : xOffset := Fixed(pathLen/2) - (rec.Right - rec.Left)/2;
    aRight: xOffset := Fixed(pathLen) - (rec.Right - rec.Left);
    else xOffset := -rec.Left;
  end;

  //now trim any characters from result that won't fit on the path ...
  startChrIdx := 0;
  endChrIdx := chrCnt -1;
  if alignH <> aJustify then
  begin
    while (endChrIdx >= 0) and
      (xOffset + GetBoundsFixedRect(result[endChrIdx]).Right >
        Fixed(pathLen)) do dec(endChrIdx);
    while (startChrIdx <= endChrIdx) and
      (xOffset + GetBoundsFixedRect(result[startChrIdx]).Left < 0) do
        inc(startChrIdx);
  end;
  if startChrIdx > 0 then
  begin
    for i := startChrIdx to endChrIdx do
      result[i-startChrIdx] := CopyPolyPoints(result[i]);
    setlength(result, endChrIdx-startChrIdx+1);
  end
  else if endChrIdx < chrCnt -1 then
    setlength(result, endChrIdx+1);

  //finally, transform the points ...
  for i := 0 to high(result) do
    for j := 0 to high(result[i]) do
      for k := 0 to high(result[i][j]) do
        TransformPt(result[i][j][k]);
end;
//------------------------------------------------------------------------------

function TText32.GetBetweenPaths(
  const bottomCurve, topCurve: TArrayOfFixedPoint; const text: UnicodeString;
  ttFont: TTrueTypeFont): TArrayOfArrayOfFixedPoint;
var
  i: integer;
  tmp: TArrayOfArrayOfArrayOfFixedPoint;
begin
  result := nil;
  tmp := GetBetweenPathsEx(bottomCurve, topCurve, text, ttFont);
  for i := 0 to high(tmp) do
    ConcatenatePolyPoints(result, tmp[i]);
end;
//------------------------------------------------------------------------------

function TText32.GetBetweenPathsEx(
  const bottomCurve, topCurve: TArrayOfFixedPoint; const text: UnicodeString;
  ttFont: TTrueTypeFont): TArrayOfArrayOfArrayOfFixedPoint;
var
  i, j, k, chrCnt: integer;
  rec, tmpRec: TFixedRect;
  textRec: TFloatRect;
  bCurve, tCurve: TArrayOfFloatPoint;
  bottomCurveLen, topCurveLen: single;
  bottomDistances, topDistances: array of single;
  nextOffset: single;
  gm: TGlyphMetrics;

  procedure TransformPt(var pt: TFixedPoint);
  var
    I, H: Integer;
    X, Y, fx, dx, dy, r: TFloat;
    topPt, bottomPt: TFloatPoint;
  begin

    X := pt.X*FixedToFloat / textRec.Right;
    Y := (pt.Y*FixedToFloat - textRec.Top) / (textRec.Bottom - textRec.Top);

    fx := X * topCurveLen;
    I := 1;
    H := High(topDistances);
    while (topDistances[I] < fx) and (I < H) do Inc(I);
    if abs(topDistances[I] - topDistances[I - 1]) < 0.01 then
      r := 0 else
      r := (topDistances[I] - fx) / (topDistances[I] - topDistances[I - 1]);
    dx := (tCurve[I - 1].X - tCurve[I].X);
    dy := (tCurve[I - 1].Y - tCurve[I].Y);
    topPt.X := tCurve[I].X + r * dx;
    topPt.Y := tCurve[I].Y + r * dy;

    fx := X * bottomCurveLen;
    I := 1;
    H := High(bottomDistances);
    while (bottomDistances[I] < fx) and (I < H) do Inc(I);
    if abs(bottomDistances[I] - bottomDistances[I - 1]) < 0.01 then
      r := 0 else
      r := (bottomDistances[I] - fx) / (bottomDistances[I] - bottomDistances[I - 1]);
    dx := (bCurve[I - 1].X - bCurve[I].X);
    dy := (bCurve[I - 1].Y - bCurve[I].Y);
    bottomPt.X := bCurve[I].X + r * dx;
    bottomPt.Y := bCurve[I].Y + r * dy;

    pt.X := Fixed(topPt.X + Y * (bottomPt.X - topPt.X));
    pt.Y := Fixed(topPt.Y + Y * (bottomPt.Y - topPt.Y));
  end;

begin
  result := nil;
  if (length(bottomCurve) < 2) or (length(topCurve) < 2) then exit;

  //get the lengths of both the bottom and top curves ...
  setLength(bottomDistances, length(bottomCurve));
  setLength(bCurve, length(bottomCurve));
  bottomDistances[0] := 0;
  bCurve[0] := FloatPoint(bottomCurve[0]);
  bottomCurveLen := 0;
  for i := 1 to high(bottomCurve) do
  begin
    bottomCurveLen := bottomCurveLen +
      DistBetweenPoints(bottomCurve[i-1], bottomCurve[i]);
    bottomDistances[i] := bottomCurveLen;
    bCurve[i] := FloatPoint(bottomCurve[i]);
  end;
  setLength(topDistances, length(topCurve));
  setLength(tCurve, length(topCurve));
  topDistances[0] := 0;
  tCurve[0] := FloatPoint(topCurve[0]);
  topCurveLen := 0;
  for i := 1 to high(topCurve) do
  begin
    topCurveLen := topCurveLen + DistBetweenPoints(topCurve[i-1], topCurve[i]);
    topDistances[i] := topCurveLen;
    tCurve[i] := FloatPoint(topCurve[i]);
  end;

  chrCnt := length(text);
  if chrCnt = 0 then exit;

  nextOffset := 0;
  PrepareMatrices;

  if not ttFont.Lock then exit;
  try
    setlength(result, chrCnt);
    for i := 0 to chrCnt-1 do
    begin
      //get each untransformed glyph ...
      if not ttFont.GetGlyphInfo(text[i+1], gm, result[i]) then break;

      //do matrix transformations ...
      TransformPolyPoints(fUnrotatedMatrix, FixedPoint(0,0), result[i]);

      //1. horizontally offset each set of glyph points and also
      //2. get the height and width of the text ...
      if i = 0 then
      begin
        rec := GetBoundsFixedRect(result[i]);
        nextOffset := gm.gmCellIncX*fScale.sx + fPadding;
      end else
      begin
        OffsetPolyPoints(result[i], nextOffset, 0);
        tmpRec := GetBoundsFixedRect(result[i]);
        rec := GetRectUnion(rec, tmpRec);
        nextOffset := nextOffset + gm.gmCellIncX*fScale.sx + fPadding;
        if (i = chrCnt -1) and (text[chrCnt] = #32) then
          rec.Right := Fixed(nextOffset);
      end;

    end;
  finally
    ttFont.UnLock;
  end;

  if (rec.Left = rec.Right) or (rec.Top = rec.Bottom) then exit;
  textRec := FloatRect(rec);
  
  for i := 0 to high(result) do
    for j := 0 to high(result[i]) do
      for k := 0 to high(result[i][j]) do
        TransformPt(result[i][j][k]);
end;
//------------------------------------------------------------------------------

function TText32.GetCurrentPos: TFixedPoint;
begin
  result := fCurrentPos;
end;
//------------------------------------------------------------------------------

procedure TText32.SetCurrentPos(newPos: TFixedPoint);
begin
  fCurrentPos := newPos;
end;
//------------------------------------------------------------------------------

function TText32.Get(X, Y: single; const text: UnicodeString;
  ttFont: TTrueTypeFont;
  out NextInsertionPt: TFloatPoint): TArrayOfArrayOfFixedPoint;
var
  i: integer;
  tmp: TArrayOfArrayOfArrayOfFixedPoint;
begin
  result := nil;
  tmp := GetEx(X, Y, text, ttFont, NextInsertionPt);
  for i := 0 to high(tmp) do
    ConcatenatePolyPoints(result, tmp[i]);
end;
//------------------------------------------------------------------------------

function TText32.GetEx(X, Y: single;
  const text: UnicodeString; ttFont: TTrueTypeFont;
  out NextInsertionPt: TFloatPoint): TArrayOfArrayOfArrayOfFixedPoint;
begin
  GetDrawInfo(text, ttFont, FloatPoint(X, Y), NextInsertionPt, result);
end;
//------------------------------------------------------------------------------

function TText32.GetInflated(X, Y, delta: single;
  const text: UnicodeString; ttFont: TTrueTypeFont;
  out NextInsertionPt: TFloatPoint): TArrayOfArrayOfFixedPoint;
var
  i: integer;
  tmp: TArrayOfArrayOfArrayOfFixedPoint;
begin
  result := nil;
  tmp := GetInflatedEx(X, Y, delta, text, ttFont, NextInsertionPt);
  for i := 0 to high(tmp) do
    ConcatenatePolyPoints(result, tmp[i]);
end;
//------------------------------------------------------------------------------

function TText32.GetInflatedEx(X, Y, delta: single;
  const text: UnicodeString; ttFont: TTrueTypeFont;
  out NextInsertionPt: TFloatPoint): TArrayOfArrayOfArrayOfFixedPoint;
var
  i,j,highI: integer;
begin
  result := GetEx(X, Y, text, ttFont, NextInsertionPt);
  highI := high(result);
  if (highI < 0) or (delta = 0) then exit;

  with TLine32.Create do
  try
    EndStyle := esClosed;
    LineWidth := abs(delta);
    for i := 0 to highI do
    begin
      for j := 0 to high(result[i]) do
      begin
        SetPoints(result[i][j]);
        //nb: Properly constucted TrueType fonts should draw glyph outlines in
        //a clockwise direction and glyph 'holes' in an anti-clockwise direction
        if delta < 0 then
          result[i][j] := GetRightPoints else
          result[i][j] := GetLeftPoints;
      end;
    end;
  finally
    free;
  end;
end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

procedure SimpleText(bmp: TBitmap32; font: TFont; X, Y: integer;
  const widetext: widestring; color: TColor32);
var
  a: byte;
  sz: TSize;
  Src, Dst: PColor32;
  i: integer;
  b: TBitmap32;
begin
  b := TBitmap32.Create;
  try
    b.Width := bmp.Width;
    b.Height := bmp.Height;
    b.Clear($FFFFFFFF);
    b.DrawMode := dmOpaque;
    if assigned(font) then
      b.Canvas.Font.Assign(font) else
      b.Canvas.Font.Assign(bmp.font);
    b.Canvas.Font.Color := clBlack;

    with b.Canvas do
    begin
      if CanvasOrientation = coRightToLeft then
      begin
        GetTextExtentPoint32W(Handle, PWideChar(widetext), Length(widetext), sz);
        Inc(X, sz.cx + 1);
      end;
      ExtTextOutW(Handle, X, Y, TextFlags,
        nil, PWideChar(widetext), Length(widetext), nil);
    end;

    Src := PColor32(b.Bits);
    Dst := PColor32(bmp.Bits);
    for i := 0 to bmp.Width*bmp.Height -1 do
    begin
      if Src^ <> $FFFFFFFF then
      begin
        //a := Src^ and $FF;     //this isn't great with white text on black
        //a := Intensity(Src^);  //nor is this
        a := (((Src^ shr 16) and $FF)+((Src^ shr 8) and $FF)+(Src^ and $FF)) div 3;
        if a < $F8 then BlendMemEx(Color, Dst^, 255-a);
      end;
      inc(Src);
      inc(Dst);
    end;
    EMMS;
  finally
    b.Free;
  end;
end;
//------------------------------------------------------------------------------

procedure SimpleTextLCD(bmp: TBitmap32; font: TFont; X, Y: integer;
  const wideText: UnicodeString; color: TColor32);
var
  i,w: integer;
  text32: TText32;
  ttf: TTrueTypeFont;
  pos: TFloatPoint;
  ppts: TArrayOfArrayOfArrayOfFixedPoint;
  tm: TTextMetric;
  otm: TOutlineTextmetric;
begin
  if assigned(font) and not TTrueTypeFont.IsValidTTFont(font) then exit;
  if (bmp.Empty) or (Length(wideText) = 0) then Exit;

  if not assigned(font) then font := bmp.Font;

  text32 := TText32.Create;
  ttf := TrueTypeFontClass.Create(font);
  try
    //one of the few places where 'hinting' can marginally improve things ...
    ttf.Hinted := true;
    text32.GetDrawInfo(wideText, ttf, FloatPoint(X,Y), pos, ppts);
    LCDPolygonSmoothing(bmp, nil, ppts, color);

    // Underline support
    if (fsUnderline in font.Style) then
    begin
      if ttf.GetOutlineTextMetrics(otm) then
      begin
        ttf.GetTextMetrics(tm);
        text32.ClearTransformations;
        w := round(text32.GetTextWidth(wideText, ttf));
        i := tm.tmAscent -
          otm.otmsUnderscorePosition - otm.otmsUnderscoreSize div 2;
        bmp.FillRect(X, Y+i, X+w, Y+i + otm.otmsUnderscoreSize, color);
      end;
    end;

  finally
    ttf.Free;
    text32.Free;
  end;
end;
//------------------------------------------------------------------------------

initialization
  lut := TLCDDistributionLut.Create;

finalization
  lut.Free;

{$ENDIF} //MSWINDOWS

end.



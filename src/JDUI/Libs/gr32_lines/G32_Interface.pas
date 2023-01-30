unit G32_Interface;
{
  DEFINE rus = my native russian
  DEFINE eng = my poor english
}

{$I GR32.INC}
{$I G32i.inc}

//----------------------------------------------------------------------------------}
//
//  rus :  модуль содержит полезняшк??удобства для библиотеки GR32 (www.g32.org)
//
//  eng :  some usefull routines and additional buildups to GR32 library (www.g32.org)
//         that extends its drawning feature:
//         - true type font drawning (antialised) (angled and transformed);
//         - Bezier Curve (qubic and quadric);
//         - text fitted in Bezier-curve;
//         - arc- pie- segment- figure ( elliptic and rotated, transformed);
//         - ellipse and rotated ellipse;
//         - rounded polygones;
//         - cardinal splines;
//
//  compiler: Delphi 6.0; Delphi 5.0;
//
//  author: Roman Gudchenko(c)  roma@goodok.ru
//
//  first published in 13.01.2002
//  last updated in  06.06.2002
//
{------------------------------------------------------------------------------------}



{
 history
 -------
 version 0.16
    1. Added new function to TCB-spline plotting
    2. Added new functions to draw custom transformed figures (arc, pie, ellipse );
      So, for example,  if you want to draw many figures with constant rotation
      angle you can precalculate affine transformation matrix.
      This function names EllipseT, ArcET, PieET, SegET;

 version 0.15  (2.06.2002)

    1. bug fixed in proc.  CalculateRoundsArc
    2. Added new functions for cardinal splines plotting:
       gCardinalSpline
       gPolyCardianalSpline
    3. Added function for drawning point as symbol (gDrawSymol)
    4. Some speed optimization of BuildGlyphPolygon procedure was made;

 version 0.14  (29.05.2002)
    1. some speed optimizations of tBitmap.Polygone and tBitmap.RenderTextEx have been made
       by Alexander Muylaert [amuylaert_gelein@hotmail.com]; they are replace those part of code
       marked  $DEFINE G32i_ver013

    2. I have implemented gPolygoneRounded and gPolyPolygoneRounded routines wich
       draw curves based on polygone with rounds.

 version 0.13  (27.05.2002)

   1. Added  functions to draw arc- pie- and segment figures;
      all of those figures can draw as elliptic and rotated (including rotated ellipse);
   2. I have tried to implement to draw rounded polygone by it work only for convex one;
      (i will reform youself soon - just correct proc. CalculateRoundsArc)
   3. Now you can to know curve length and position and tangent of any point at curve;
      you can apply drawning routines to tBitmap32 not only my tBitmap32Ex, exclude
      RenderFittedText routines

 version 0.12  (20.05.2002)

    i don't remember

}


interface

uses GR32, GR32_Polygons, Graphics, Windows, Classes, GR32_Transforms;


{ --- defines and types ---}

{ tPolygonDrawOptions }

  { end: this type usefull to point draw method for control quality and speed }

  {eng: use pdoFloat to draw really antialised poligones, and
        pdoFilling to draw antialised filled poligones and curves  }
const
  pdoAntialising = 1; { eng: simple antialising }
  pdoFloat       = 2 or pdoAntialising;
  pdoFilling     = 4;
  pdoFastFilling = 8 or pdoFilling or pdoFloat; { not precisely and quality but fast }

type
  tPolygonDrawOptions = longint;

{ rus: коэффициэнты, опреде?ющие качество аппроксимаци?кривых }
{ eng: quality of curve approximation }
const
   { eng: for qubic bezier curve }
   Bezier3SegmentMinLengthInPixel : word = 8;{ rus: минимально?значение условной длин?рогульки кубической кривой Bezier,
                                                че?меньше те?точнее апроксимируется кривульк?}

   Bezier3SegmentMinLengthInPixelSQR : word = 64;
   { eng: for qubic bezier curve to site fitted text}
   Bezier3SegmentMinLengthInPixel_2 : word = 8; {точность аппроксимаци?кривой пр?расположении на не?текста }

   { eng: for quadric bezier curve   }
   Bezier2SegmentMinLengthInPixel : word = 8; { rus: минимально?значение условной длин?рогульки квадратичной кривой Bezier,
                                                че?меньше те?точнее апроксимируется кривульк?}
   FittedText_SpacingFactor : double = 1.1;

   eps_Fixed : GR32.tFixed = 100;

  { -- pice of mathematics -- }

  {$IFNDEF DELPHI6}
  function Cosecant(const X: Extended): Extended;

  type
    TValueSign = -1..1;

  const
    NegativeValue = Low(TValueSign);
    ZeroValue = 0;
    PositiveValue = High(TValueSign);

  function Sign(const AValue: Integer): TValueSign; overload;
  function Sign(const AValue: Int64): TValueSign; overload;
  function Sign(const AValue: Double): TValueSign; overload;
  {$ENDIF}


  {-- some precalculated constant: -- }
  const

    div65536        = 0.0000152587890625;    { 1/65536}
    HalfPixel       = 32768;
    PixelInFixed    = 65536;

    Pi              = 3.14159265358979323846;               { Pi }
    Pi2             = 6.28318530717958647693;               { 2*Pi }
    PIDIV2          = 1.57079632679489661923;               { Pi/2 }
    PIDIV4          = 0.785398163397448309615;              { Pi/4 }


    Ratio3 : double         =  1/3;
    Ratio2div3 : double     =  2/3;
    Ratio6 : double         =  1/6;


    EllipseToCurveCoeff_4    = 0.26521648984;
    EllipseToCurveCoeff_2    = 0.53043297968;
    EllipseToCurveCoeff_2inv = 0.46956702032; { 1 - EllipseToCurveCoeff_2}




const
  Identity_mat2 : tmat2 = ( eM11 : (fract : 0; value : 1);
                            eM12 : (fract : 0; value : 0);
                            eM21 : (fract : 0; value : 0);
                            eM22 : (fract : 0; value : 1); );

  VertFlip_mat2 : tmat2 = ( eM11 : (fract :  0; value : 1);
                            eM12 : (fract :  0; value : 0);
                            eM21 : (fract :  0; value : 0);
                            eM22 : (fract :  0; value : -1); );

  { преобразование G32 матриц??Win32 API матриц?преобразован? }
  { convertation g32 float matrix to win32 API matrix }
  function FloatMatrixToMat2(const xMat : tFloatmatrix) : TMAT2;

  { other convertation functions }

  function WinFixToFixed(x : _FIXED) : GR32.TFixed;
  function FixedToWinFix(x : GR32.TFixed) : _Fixed;

  {$IFNDEF OPTIMIZE_CALLFUNCTIONS}
  function FloatToWinFix(x : single) : _FIXED;
  function WinFixToFloat(x : _Fixed) : double;
  {$ENDIF}

  { rus: некоторы?полезняшк?  }
  function FixedRect(const xR : tRect) : tFixedRect; overload;
  function FixedRect(const xLeft, xTop, xRight, xBottom : GR32.tFixed) : tFixedRect; overload;
  function IsNullRect(const xR : tFixedRect) : boolean;

  function Mdl(X, Y : integer) : integer; assembler; register;{ eng: average of couple }
  function MiddleLine(const p1, p2 : tFixedPoint) : tFixedPoint; overload;
  function PointsAreEqual(const p1, p2 : GR32.tFixedPoint) : boolean;
  function Distance(const p1, p2 :GR32.tFixedPoint) : GR32.tFixed; overload;{ расстояни?межд?точкам?}
  function Distance(const p1x, p1y, p2x, p2y : double) : double; overload;{ расстояни?межд?точкам?}
  function SqrDistance(const p1, p2 :GR32.tFixedPoint) : GR32.tFixed; { квадра?расстояни?межд?точкам?}
  function Norm1(const x1, y1, x2, y2: integer) : integer; overload;
  function Norm1(const p1, p2 : tFixedPoint) : GR32.tFixed; overload;
  procedure RotateArrayOfFixedPoint(var xPoints : TArrayOfFixedPoint; const xCenter : tFixedPoint; const xAngle : double);
  procedure TransformArrayOfFixedPoint(var xPoints : TArrayOfFixedPoint; const xAT : TFloatMatrix);
  { --all valuations asume then segment a very small (about Bezier3SegmentMinLengthInPixel size )}
  { qubic bezier segment conditional length in norm2 ( more exacttly of all other, but slower) }
  function SegmentConditionalLengthQ3N2(const p1, p2, p3, p4 : tFixedPoint) : GR32.tFixed; { оценка длин?сегмента кубической кривой}
  { qadric bezier segment conditional length in norm1 (supremum valuation) }
  function SegmentConditionalLengthQ2N1Sup(const x0, x1, x2 : tFixedPoint) : GR32.tFixed;
  { qadric bezier segment conditional length in norm2 (supremum valuation) }
  function SegmentConditionalLengthQ2N2Sup(const x0, x1, x2 : tFixedPoint) : GR32.tFixed;
  { qubic bezier segment conditional length in norm1 (supremum valuation) }
  function SegmentConditionalLengthQ3N1Sup(const x0, x1, x2, x3 : tFixedPoint) : GR32.tFixed;
  { qubic bezier segment conditional length in norm2 (supremum valuation) }
  function SegmentConditionalLengthQ3N2Sup(const x0, x1, x2, x3 : tFixedPoint) : GR32.tFixed;
  { qubic bezier segment conditional curvatre in norm1 }
  function SegmentConditionalCurvatureQ2(const x0, x1, x2 : tFixedPoint) :GR32.tFixed;
  { return position and tangent valuations of point, sited on xLength among segment - just interpolation of line}
  procedure gGetPointPositionValuationAtSegment(const p1, p2 : GR32.tFixedPoint;
                                               const xLength : GR32.tFixed;
                                               out xPathX, xPathY: GR32.tFixed;
                                               out xAngle : double);

  { return qubic bezier length with curve approximation }
  function gGetCurveLength(const xCurve: tArrayOfFixedPoint) : GR32.tFixed;


  { return position and tangent of point, sited on xLength among curve }
  procedure gGetPointAtCurve(const xCurve: tArrayOfFixedPoint;
                            const xLength : GR32.tFixed;
                            out xPathX, xPathY : GR32.tFixed; out xAngle : double
                            );

  { return position and tangent of point, sited on xLength among curve for massive calling to don't approximate curve every time }
  function gGetPointAtCurveEx(const xStartSegmentInd : integer;
                              const xStartLength : GR32.tFixed;
                              const xCurve: tArrayOfFixedPoint;
                              const xLength : GR32.tFixed;
                              out xPathX, xPathY : GR32.tFixed; out xAngle : double;
                              const xApproxNeed : boolean = true
                              ):integer;


{ -- following functions realized for using  directly on TBitmap32, not tBitmap32Ex  -- }

  {}
type
  tSymbolKind = (skCircle,
                 skSquare,
                 skTriangle,
                 skPlus,     { + }
                 skX,        { x }
                 skStar      { * }
                 );


  procedure gDrawSymbol(xBitmap : tBitmap32;
                        const xP      : GR32.tFixedPoint;
                        const xSymbol : tSymbolKind;
                        const xSize   : GR32.tFixed;
                        const xColor  : tColor32;
                        const xOptions : tPolygonDrawOptions);


  procedure gDrawSymbols(xBitmap : tBitmap32;
                         const xPoints : tArrayOfFixedPoint;
                         const xSymbol : tSymbolKind;
                         const xSize   : GR32.tFixed;
                         const xColor  : tColor32;
                         const xOptions : tPolygonDrawOptions);
  { just call one of GR32.Poligon function according options }
  procedure gPolygon(Bitmap: TBitmap32;
                     const Points: TArrayOfFixedPoint;
                     const Color: TColor32;
                     const Options : tPolygonDrawOptions;
                     const Closed: Boolean;
                     const FillMode: TPolyFillMode = pfAlternate);

  { just call one of GR32.Poligon function according options }
  procedure gPolyPolygon(Bitmap: TBitmap32;
                     const Points: TArrayOfArrayOfFixedPoint;
                     const Color: TColor32;
                     const Options : tPolygonDrawOptions;
                     const Closed: Boolean;
                     const FillMode: TPolyFillMode = pfAlternate);

  procedure gPolyBezier(Bitmap: TBitmap32;
                       const Points: TArrayOfFixedPoint;
                       const Color: TColor32;
                       const Options : tPolygonDrawOptions;
                       const Closed: Boolean;
                       const FillMode: TPolyFillMode = pfAlternate);



  procedure gPolyPolyBezier(Bitmap: TBitmap32;
                     const Points: TArrayOfArrayOfFixedPoint;
                     const Color: TColor32;
                     const Options : tPolygonDrawOptions;
                     const Closed: Boolean;
                     const FillMode: TPolyFillMode = pfAlternate);

  { build and draw curve wich implement rounded polygone based
    on xPoints polygone with round radius }
  procedure gPolygonRounded(xBitmap: TBitmap32;
                     const xPoints: TArrayOfFixedPoint;
                     const xRadius : GR32.tFixed;
                     const xColor: TColor32;
                     const xOptions : tPolygonDrawOptions;
                     const xClosed: Boolean;
                     const xFillMode: TPolyFillMode = pfAlternate);

  procedure gPolyPolygonRounded(xBitmap: TBitmap32;
                     const xPoints: TArrayOfArrayOfFixedPoint;
                     const xRadius : GR32.tFixed;
                     const xColor: TColor32;
                     const xOptions : tPolygonDrawOptions;
                     const xClosed: Boolean;
                     const xFillMode: TPolyFillMode = pfAlternate);

  { fill all bitmap with xColor exept xRect area }
  procedure gRectangleHole(xBitmap : tBitmap32;
                           const xRect : tFixedRect;
                           const xColor : tColor32;
                           const xOptions : tPolygonDrawOptions);

  { draw simple ellipse }
  procedure gEllipse(xBitmap : tBitmap32;
                     const xRect : TFixedRect;
                     const xColor: TColor32;
                     const xOptions : tPolygonDrawOptions = pdoFloat);

  { draw rotated ellipse }
  procedure gEllipseRotated(xBitmap : tBitmap32;
                            const xCenter : tFixedPoint;
                            const xA, xB : GR32.tFixed; { if xAngle = 0 then A <-> width and xB <-> Height }
                            const xAngle : double;      { value in radians }
                            const xColor : tColor32;
                            const xOptions : tPolygonDrawOptions = pdoFloat);

  { draw transformed ellipse with xAT affine tranformation matrix }
  procedure gEllipseT(xBitmap : tBitmap32;
                            const xCenter : tFixedPoint;
                            const xA, xB : GR32.tFixed; { if xAngle = 0 then A <-> width and xB <-> Height }
                            const xAT : TFloatMatrix;  { affine transformation matrix }
                            const xColor : tColor32;
                            const xOptions : tPolygonDrawOptions = pdoFloat);

  { TODO : procedure gEllipseTransformed }

  { draw arc; if xOptions = Fill then arc becames filled segment }
  procedure gArc(xBitmap : tBitmap32;
                 const xCenter : tFixedPoint;
                 const xR : GR32.tFixed;
                 const xStartAngle, xEndAngle : double;
                 const xColor : tColor32;
                 const xOptions : tPolygonDrawOptions = pdoFloat);

  { draw elliptic arc }
  procedure gArcElliptic(xBitmap : tBitmap32;
                         const xCenter : tFixedPoint;
                         const xA, xB : GR32.tFixed;
                         const xStartAngle, xEndAngle : double; { values in radians }
                         const xColor : tColor32;
                         const xOptions : tPolygonDrawOptions = pdoFloat);

  { draw elliptic and rotated arc }
  procedure gArcER(xBitmap : tBitmap32;
                         const xCenter : tFixedPoint;
                         const xA, xB : GR32.tFixed;
                         const xStartAngle, xEndAngle : double; { values in radians }
                         const xRotAngle : double;
                         const xColor : tColor32;
                         const xOptions : tPolygonDrawOptions = pdoFloat);

  { draw elliptic and transformed arc }
  procedure gArcET(xBitmap : tBitmap32;
                         const xCenter : tFixedPoint;
                         const xA, xB : GR32.tFixed;
                         const xStartAngle, xEndAngle : double; { values in radians }
                         const xAT : TFloatMatrix; { affine transformation matrix }
                         const xColor : tColor32;
                         const xOptions : tPolygonDrawOptions = pdoFloat);


  { TODO : procedure gArcEllipticeTransformed }

  { draw segment; segment is closed Arc }
  procedure gSegment(xBitmap : tBitmap32;
                 const xCenter : tFixedPoint;
                 const xR : GR32.tFixed;
                 const xStartAngle, xEndAngle : double;
                 const xColor : tColor32;
                 const xOptions : tPolygonDrawOptions = pdoFloat);
  { draw elliptic segment }
  procedure gSegmentElliptic(xBitmap : tBitmap32;
                         const xCenter : tFixedPoint;
                         const xA, xB : GR32.tFixed;
                         const xStartAngle, xEndAngle : double; { values in radians }
                         const xColor : tColor32;
                         const xOptions : tPolygonDrawOptions = pdoFloat);

  { draw elliptic and rotated segment for monsters }
  procedure gSegmentER(xBitmap : tBitmap32;
                         const xCenter : tFixedPoint;
                         const xA, xB : GR32.tFixed;
                         const xStartAngle, xEndAngle : double; { values in radians }
                         const xRotAngle : double;
                         const xColor : tColor32;
                         const xOptions : tPolygonDrawOptions = pdoFloat);

  { draw elliptic and transformed segment }
  procedure gSegmentET(xBitmap : tBitmap32;
                         const xCenter : tFixedPoint;
                         const xA, xB : GR32.tFixed;
                         const xStartAngle, xEndAngle : double; { values in radians }
                         const xAT : TFloatMatrix; { affine transformation matrix }
                         const xColor : tColor32;
                         const xOptions : tPolygonDrawOptions = pdoFloat);




  { draw pie - figure ; pie-figure is arc connected with center }
  procedure gPie(xBitmap : tBitmap32;
                 const xCenter : tFixedPoint;
                 const xR : GR32.tFixed;
                 const xStartAngle, xEndAngle : double;
                 const xColor : tColor32;
                 const xOptions : tPolygonDrawOptions = pdoFloat);

  procedure gPieElliptic(xBitmap : tBitmap32;
                         const xCenter : tFixedPoint;
                         const xA, xB : GR32.tFixed;
                         const xStartAngle, xEndAngle : double;
                         const xColor : tColor32;
                         const xOptions : tPolygonDrawOptions = pdoFloat);

  { draw elliptic rotated pie }
  procedure gPieER(xBitmap : tBitmap32;
                         const xCenter : tFixedPoint;
                         const xA, xB : GR32.tFixed;
                         const xStartAngle, xEndAngle : double; { values in radians }
                         const xRotAngle : double;
                         const xColor : tColor32;
                         const xOptions : tPolygonDrawOptions = pdoFloat);


  { draw elliptic and transformed pie }
  procedure gPieET(xBitmap : tBitmap32;
                         const xCenter : tFixedPoint;
                         const xA, xB : GR32.tFixed;
                         const xStartAngle, xEndAngle : double; { values in radians }
                         const xAT : TFloatMatrix; { affine transformation matrix }
                         const xColor : tColor32;
                         const xOptions : tPolygonDrawOptions = pdoFloat);

  { TODO : procedure gPieET  }


  { draw rounded rectangle }
  procedure gRectangleRounded(xBitmap : tBitmap32;
                                     const xRect : TFixedRect;
                                     const xR    : GR32.TFixed;
                                     const xColor : tColor32;
                                     const xOptions : tPolygonDrawOptions = pdoFloat);

  { draw rounded and rotated rectangle }
  procedure gRectangleRR(xBitmap : tBitmap32;
                         const xCenter : tFixedPoint;
                         const xA, xB : GR32.tFixed;
                         const xR     : GR32.tFixed;
                         const xAngle : double;
                         const xColor : tColor32;
                         const xOptions : tPolygonDrawOptions = pdoFloat);


  { build bezier curve to realize cardinal spline based on xPoints;
    if xTension = 1, simple poligone produced;
    if xTension = 0, common spline prodused;
  }
  procedure gCardinalSpline(xBitmap : tBitmap32;
                            const xPoints : tArrayOfFixedPoint;
                            const xTension : double;
                            const xColor : tColor32;
                            const xClosed : boolean;
                            const xOptions : tPolygonDrawOptions = pdoFloat);

  procedure gPolyCardinalSpline(xBitmap : tBitmap32;
                            const xPoints : tArrayOfArrayOfFixedPoint;
                            const xTension : double;
                            const xColor : tColor32;
                            const xClosed : boolean;
                            const xOptions : tPolygonDrawOptions = pdoFloat);
                            
  { build and draw qubic bezier curve to realize common TCB spline based ib xPoints;
    if xContinuity and xBias equals zero then TCB spline becomes cardinal spline }
  procedure gTCBSpline(xBitmap : tBitmap32;
                            const xPoints : tArrayOfFixedPoint;
                            const xTension : double;
                            const xContinuity : double;
                            const xBias : double;
                            const xColor : tColor32;
                            const xClosed : boolean;
                            const xOptions : tPolygonDrawOptions = pdoFloat);

  procedure gPolyTCBSpline(xBitmap : tBitmap32;
                            const xPoints : tArrayOfArrayOfFixedPoint;
                            const xTension : double;
                            const xContinuity : double;
                            const xBias : double;
                            const xColor : tColor32;
                            const xClosed : boolean;
                            const xOptions : tPolygonDrawOptions = pdoFloat);




  { TODO : LoadRectangleRounded  }
  { Load segments of bezier curve;
    in coommon case segments count can be greater then 2:
    dA = xEndAngle - xStartAngle;
    if dA = 0 then zero ;
    if 0 < dA <= pi then 1
    if pi < dA <=2pi then 2 and so on.
    }

  procedure LoadArcCurve(const xCenter : tFixedPoint;
                        const xA, xB : GR32.tFixed;
                        const xStartAngle, xEndAngle : double; { values in radians }
                        var yPP : TArrayOfFixedPoint);


  { Load segment of bezier curve witch round p1-p2-p3 andle with radius xR}
  { asumed that p1 point alway in yPP, we shuld add p21, p22 and two control point }
  procedure LoadRoundsCurve(const p1, p2, p3 : tFixedPoint;
                          const xR : GR32.tFixed;
                          var yPP : TArrayOfFixedPoint;
                          const xAddLast : boolean = true);

  { calculate arc parameters with radius xR in angle bases on p1-p2-p3 points}
  procedure CalculateRoundsArc(const p1, p2, p3 : tFixedPoint;
                             const xR : GR32.tFixed;
                             out p21, p22 : tFixedPoint; // end points of arc
                             out yC : tFixedPoint;       // center of arc
                             out yStartAngle, yEndAngle :double);

{ TBitmap32Ex }

{ rus: оболочка вокруг класса  tBitmap32, чтоб?независить от будущи?изменени??библиотеке }
{ end: wrapper around tBitmap32, to don't depend on future versions g32 lib. }


type

  TBitmap32Ex = class(tBitmap32)
  private
    fFont_e31 : Single;
    fFont_e32 : Single;
    fLastSumLength : GR32.tFixed; { послед?я найденная длин?сегмента }
    function GetCanvas: tCanvas;
  protected
    fDrawOrign : tFixedPoint;
    fCanvas    : tCanvas;
    fFontMat2  : tMat2;
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure Polygon(const Points: TArrayOfFixedPoint;
                      const Color: TColor32;
                      const Options : tPolygonDrawOptions;
                      const Closed: Boolean;
                      const FillMode: TPolyFillMode = pfAlternate);
    procedure PolyBezier(const Points: TArrayOfFixedPoint;
                         const Color: TColor32;
                         const Options : tPolygonDrawOptions;
                         const Closed: Boolean;
                         const FillMode: TPolyFillMode = pfAlternate);

    procedure Ellipse(const xRect : tFixedRect;
                      const xColor: tColor32;
                      const xOptions : tPolygonDrawOptions = pdoFloat);
    procedure EllipseRotated(const xCenter : tFixedPoint;
                             const xA, xB : GR32.tFixed;
                             const xAngle : double;
                             const xColor : tColor32;
                             const xOptions : tPolygonDrawOptions = pdoFloat);

    procedure Arc(const xCenter : tFixedPoint;
                  const xR : GR32.tFixed;
                  const  xStartAngle, xEndAngle : double;
                  const  xColor : tColor32;
                  const  xOptions : tPolygonDrawOptions = pdoFloat);
    procedure ArcElliptic(const xCenter : tFixedPoint;
                          const xA, xB : GR32.tFixed;
                          const  xStartAngle, xEndAngle : double;
                          const  xColor : tColor32;
                          const  xOptions : tPolygonDrawOptions = pdoFloat);

    procedure Pie(const xCenter : tFixedPoint;
                  const xR : GR32.tFixed;
                  const  xStartAngle, xEndAngle : double;
                  const  xColor : tColor32;
                  const  xOptions : tPolygonDrawOptions = pdoFloat);
    procedure PieElliptic(const xCenter : tFixedPoint;
                          const   xA, xB : GR32.tFixed;
                          const  xStartAngle, xEndAngle : double;
                          const  xColor : tColor32;
                          const xOptions : tPolygonDrawOptions = pdoFloat);

    procedure Segment(const xCenter : tFixedPoint;
                      const xR : GR32.tFixed;
                      const  xStartAngle, xEndAngle : double;
                      const  xColor : tColor32;
                      const  xOptions : tPolygonDrawOptions = pdoFloat);
    procedure SegmentElliptic(const xCenter : tFixedPoint;
                              const xA, xB : GR32.tFixed;
                              const xStartAngle, xEndAngle : double;
                              const  xColor : tColor32;
                              const  xOptions : tPolygonDrawOptions = pdoFloat);



    { rus: рисовани?инверсии прямоугольник?( закрашивание всей област?цветом, кром?прямоугольник?}
    { eng. fill all bitmap area with xColor except xRect (like window) }
    procedure RectangleHole(const xRect : tFixedRect;
                            const  xColor : TColor32;
                            const  xOptions : tPolygonDrawOptions); overload;
    procedure RectangleHole(const xRect : tRect;
                             const  xColor : TColor32;
                             const  xOptions : tPolygonDrawOptions); overload;

    procedure PolyPolygon(const Points : TArrayOfArrayOfFixedPoint;
                          const Color : tColor32;
                          const Options : tPolygonDrawOptions;
                          const Closed: Boolean;
                          const FillMode: TPolyFillMode = pfAlternate);
    procedure PolyPolyBezier(const Points : TArrayOfArrayOfFixedPoint;
                             const Color : tColor32;
                             const Options : tPolygonDrawOptions;
                             const Closed: Boolean;
                             const FillMode: TPolyFillMode = pfAlternate);

    { rus: рисует один символ шрифта установленог??Font ?указанно?позици? }
    { eng : draw glyph of one symbol of current font in position (xLeft, yTop) }
    procedure  DrawGlyph(const xCharCode : longword;
                         const xLeft, yTop : GR32.tFixed;
                         const xColor : tColor32;
                         const xOptions : tPolygonDrawOptions);

    { прорисовка текста текущи?шрифто? xLeft, yTop - позиция левого _нижнего_угла }
    { eng: render text with current font and symbols transform}
    procedure RenderTextEx(const xLeft, yBottom: GR32.tFixed;
                           const xText: string;
                           const xColor : tColor32;
                           const xOptions : tPolygonDrawOptions);

    function GetPointAtCurve(const xStartSegmentInd : integer;
                             const xCurve: tArrayOfFixedPoint;
                             const xLength : GR32.tFixed;
                             out xPathX, xPathY : GR32.tFixed; out xAngle : double;
                             const xApproxNeed : boolean = true  ): integer;
    { rus: прорисовка текста вдол?кривой xPath}
    { eng: text rendering along curve }
    procedure RenderFittedText(const xText : string;
                               const  xColor : tColor32;
                               const xOptions : tPolygonDrawOptions;
                               const xPath : tArrayOfFixedPoint);

    { rus: установк?матриц?преобразован? символов шритва (таки?образо?можн?управлять наклоном ?масштабированием шрифта)  }
    { eng: setting symbols transformation matrix to cntrol it's rotations etc}
    function SelectFontMat2(const xValue : tMat2) : tMat2;
    function SelectFontTransform(const xValue : tFloatMatrix) : tFloatMatrix; { столбе?свободны?членов игнориуется }

    { TODO : DrawComplexCurve - на будуще? для прорисовки кривых, сост?щи?ка?из прямы?отрезков та??из кривых }
    { eng : true canvas }
    property Canvas : tCanvas read GetCanvas;
    { eng : orign of viewport for extended functions (Polygone, PolyBezie etc }
    property DrawOrign : tFixedPoint read fDrawOrign write fDrawOrign;  { смещение систем?координа?(!) только пр?использовани?новы?функци?}
  end;



implementation

  uses Sysutils, Math,  GR32_LowLevel;

  {$IFNDEF DELPHI6}
     {$I Delphi6Math.inc}
  {$ENDIF}


  function FixedRect(const xR : tRect) : tFixedRect;
  begin
    result.Left := GR32.fixed(xR.left);
    result.Right := GR32.fixed(xR.right);
    result.Top := GR32.fixed(xR.top);
    result.Bottom := GR32.fixed(xR.bottom);
  end;

  function FixedRect(const xLeft, xTop, xRight, xBottom : GR32.tFixed) : tFixedRect;
  begin
    result.Left := xLeft;
    result.Right := xRight;
    result.Top := xTop;
    result.Bottom := xBottom;
  end;

  function IsNullRect(const xR : tFixedRect) : boolean;
  begin
    result := (xR.Left = 0) and (xR.Top = 0) and (xR.Right = 0) and (xR.Bottom = 0);
  end;

  {$IFNDEF OPTIMIZE_CALLFUNCTIONS}
  function FloatToWinFix(x : single) : _FIXED;
  begin
    result := _Fixed(GR32.tFixed(trunc(x * 65536)));
  end;

  function WinFixToFloat(x : _Fixed) : double;
  begin
    { result := GR32.tFixed(x)/65536; }
    result := div65536 * GR32.tFixed(x);
  end;
  {$ENDIF}

  function WinFixToFixed(x : _FIXED) : GR32.TFixed;
  begin
    result := GR32.TFixed(x);
  end;

  function FixedToWinFix(x : GR32.TFixed) : _Fixed;
  begin
    result := _Fixed(x);
  end;


  { преобразование G32 матриц??Win32 API матриц?преобразован? }
  function  FloatMatrixToMat2(const xMat : tFloatMatrix) : TMAT2;
  begin
  {$IFDEF OPTIMIZE_CALLFUNCTIONS}
    result.eM11 := _Fixed(GR32.tFixed(trunc(xMat[0,0] * 65536)));
    result.eM21 := _Fixed(GR32.tFixed(trunc(xMat[1,0] * 65536)));
    result.eM12 := _Fixed(GR32.tFixed(trunc(xMat[0,1] * 65536)));
    result.eM22 := _Fixed(GR32.tFixed(trunc(xMat[1,1] * 65536)));
  {$ELSE}
    result.eM11 := FloatToWinFix(xMat[0,0]);
    result.eM21 := FloatToWinFix(xMat[1,0]);
    result.eM12 := FloatToWinFix(xMat[0,1]);
    result.eM22 := FloatToWinFix(xMat[1,1]);
  {$ENDIF}


  end;

  function Mat2ToFloatMatrix(xMat : tMat2) : tFloatMatrix;
  begin
    {$IFDEF OPTIMIZE_CALLFUNCTIONS}
      result[0,0] := div65536 * GR32.tFixed(xMat.eM11);
      result[1,0] := div65536 * GR32.tFixed(xMat.eM21);
      result[0,1] := div65536 * GR32.tFixed(xMat.eM12);
      result[1,1] := div65536 * GR32.tFixed(xMat.eM22);
    {$ELSE}
      result[0,0] := WinFixToFloat(xMat.eM11);
      result[1,0] := WinFixToFloat(xMat.eM21);
      result[0,1] := WinFixToFloat(xMat.eM12);
      result[1,1] := WinFixToFloat(xMat.eM22);
    {$ENDIF}

  end;

  {получени?матриц?преобразованя поворота }
  function GetRotatedMat2(xAngle : double) : tMat2;
  var
    S, C : single;
  begin
    S := Sin(xAngle); C := Cos(xAngle);
    {$IFDEF OPTIMIZE_CALLFUNCTIONS}
      result.eM11 := _Fixed(GR32.tFixed(trunc(C * 65536)));
      result.eM21 := _Fixed(GR32.tFixed(trunc(S * 65536)));
      result.eM12 := _Fixed(GR32.tFixed(trunc(-S * 65536)));
      result.eM22 := _Fixed(GR32.tFixed(trunc(C * 65536)));
    {$ELSE}
      result.eM11 := FloatToWinFix(C);
      result.eM21 := FloatToWinFix(S);
      result.eM12 := FloatToWinFix(-S);
      result.eM22 := FloatToWinFix(C);
    {$ENDIF}
  end;

  function MultMat2(const M1, M2: tMat2) : tmat2;
  var
    m1_00, m1_01, m1_10, m1_11,
    m2_00, m2_01, m2_10, m2_11 : double;
  begin
    {$IFDEF OPTIMIZE_CALLFUNCTIONS}
      m1_00 := div65536 * GR32.tFixed(m1.eM11);
      m1_01 := div65536 * GR32.tFixed(m1.eM12);
      m1_10 := div65536 * GR32.tFixed(m1.eM21);
      m1_11 := div65536 * GR32.tFixed(m1.eM22);

      m2_00 := div65536 * GR32.tFixed(m2.eM11);
      m2_01 := div65536 * GR32.tFixed(m2.eM12);
      m2_10 := div65536 * GR32.tFixed(m2.eM21);
      m2_11 := div65536 * GR32.tFixed(m2.eM22);

      Result.eM11 := _Fixed(GR32.tFixed(trunc((m1_00 * m2_00 +  m1_10 * m2_01) * 65536)));
      Result.eM12 := _Fixed(GR32.tFixed(trunc((m1_01 * m2_00 +  m1_11 * m2_01) * 65536)));
      Result.eM21 := _Fixed(GR32.tFixed(trunc((m1_00 * m2_10 +  m1_10 * m2_11) * 65536)));
      Result.eM22 := _Fixed(GR32.tFixed(trunc((m1_01 * m2_10 +  m1_11 * m2_11) * 65536)));
    {$ELSE}
      m1_00 := WinFixToFloat(m1.eM11);
      m1_01 := WinFixToFloat(m1.eM12);
      m1_10 := WinFixToFloat(m1.eM21);
      m1_11 := WinFixToFloat(m1.eM22);

      m2_00 := WinFixToFloat(m2.eM11);
      m2_01 := WinFixToFloat(m2.eM12);
      m2_10 := WinFixToFloat(m2.eM21);
      m2_11 := WinFixToFloat(m2.eM22);

      Result.eM11 :=  FloatToWinFix(m1_00 * m2_00 +  m1_10 * m2_01);
      Result.eM12 :=  FloatToWinFix(m1_01 * m2_00 +  m1_11 * m2_01);
      Result.eM21 :=  FloatToWinFix(m1_00 * m2_10 +  m1_10 * m2_11);
      Result.eM22 :=  FloatToWinFix(m1_01 * m2_10 +  m1_11 * m2_11);
    {$ENDIF}
  end;

  function DetMat2(xMat : tMat2): Single;
  begin
    {$IFDEF OPTIMIZE_CALLFUNCTIONS}
    Result := div65536 * GR32.tFixed(xMat.eM11) * div65536 * GR32.tFixed(xMat.eM22)
            - div65536 * GR32.tFixed(xMat.eM12) * div65536 * GR32.tFixed(xMat.eM21);
    {$ELSE}
    Result := WinFixToFloat(xMat.eM11) * WinFixToFloat(xMat.eM22) - WinFixToFloat(xMat.eM12) * WinFixToFloat(xMat.eM21);
    {$ENDIF}
  end;

  function Mdl(X, Y : integer) : integer;
  asm
    mov eax, x  { result := (x + y) div 2; }
    add eax, y
    sar eax, 1
  end;

  function Norm1(const x1, y1, x2, y2: integer) : integer;
  begin
    result := abs(y2 - y1) + abs(x2 - x1);
  end;

  function Norm1(const p1, p2 : tFixedPoint) : GR32.tFixed;
  begin
    result := abs(p2.y - p1.y) + abs(p2.x - p1.x);
  end;

  function MiddleLine(const p1, p2 : tFixedPoint) : tFixedPoint;
  begin
    result.x := (p1.x + p2.x) div 2;
    result.y := (p1.y + p2.y) div 2;
  end;

  function PointsAreEqual(const p1, p2 : GR32.tFixedPoint) : boolean;
  begin
    result := (p1.x = p2.x) and (p1.y = p2.y);
  end;

  function Distance(const p1, p2 :GR32.tFixedPoint) : GR32.tFixed; { расстояни?межд?точкам?}
  begin
    result := round(hypot(p2.x - p1.x, p2.y - p1.y));
  end;

  function Distance(const p1x, p1y, p2x, p2y :double) : double; { расстояни?межд?точкам?}
  begin
    result := hypot(p2x - p1x, p2y - p1y);
  end;

  function SqrDistance(const p1, p2 :GR32.tFixedPoint) : GR32.tFixed; { квадра?расстояни?межд?точкам?}
  begin
    result := sqr(p2.x - p1.x) + sqr(p2.y - p1.y);
  end;

  procedure RotateArrayOfFixedPoint(var xPoints : TArrayOfFixedPoint; const xCenter : tFixedPoint; const xAngle : double);
  var
   vSin, vCos: extended;
   d : GR32.tFixedPoint;
   i : integer;
  begin
   SinCos(xAngle, vSin, vCos);
   for i := Low(xPoints) to High(xPoints) do
     begin
     d.x:=(xPoints[i].x - xCenter.x);
     d.y:=(xPoints[i].y - xCenter.y);
     xPoints[i].x := round(d.x*vCos + d.y*vSin + xCenter.x);
     xPoints[i].y := round(d.y*vCos - d.x*vSin + xCenter.y);
     end;
  end;

  { transformation on points array according affine transform matrix xAT }
  procedure TransformArrayOfFixedPoint(var xPoints : TArrayOfFixedPoint; const xAT : TFloatMatrix);
  var
    i : integer;
    x, y : single;
  begin
    for i := Low(xPoints) to High(xPoints) do
       begin
       x := xPoints[i].x*div65536;
       y := xPoints[i].y*div65536;
       xPoints[i].x := round((x*xAT[0,0] + y*xAT[1,0] + xAT[2,0])*65536);
       xPoints[i].y := round((x*xAT[0,1] + y*xAT[1,1] + xAT[2,1])*65536);
       end;
  end;



 { оценка длин?сегмента кубической кривой }
 function SegmentConditionalLengthQ3N2(const p1, p2, p3, p4 : tFixedPoint) : GR32.tFixed;
 begin
   { rus: считае? чт?истинн? длин?сегмента находится гд?то межд?LowValuation ?TopValuation}
   { eng: consider, than real length is larger them  LowValuation and smoller TopValuation}
   result := (Distance(p1, p2) + Distance(p2, p3) + Distance(p3, p4) + Distance(p1, p4)) div 2;
 end;


  { qadric bezier segment conditional length in norm1 (supremum valuation) }
  function SegmentConditionalLengthQ2N1Sup(const x0, x1, x2 : tFixedPoint) : GR32.tFixed;
  begin
   { result := norm1(x0, x1)  + norm1(x1, x2); }
   result := abs(x0.X - x1.x) + abs(x0.Y - x1.Y) +
             abs(x1.X - x2.x) + abs(x1.Y - x2.Y);
  end;

  { qadric bezier segment conditional length in norm2 (supremum valuation) }
  function SegmentConditionalLengthQ2N2Sup(const x0, x1, x2 : tFixedPoint) : GR32.tFixed;
  begin
   { result := Distance(x0, x1)  + Distance(x1, x2); }
   result := round(hypot(x0.X - x1.x, x0.Y - x1.Y) +
             hypot(x1.X - x2.x, x1.Y - x2.Y));
  end;

  { qubic bezier segment conditional length in norm1 (supremum valuation) }
  function SegmentConditionalLengthQ3N1Sup(const x0, x1, x2, x3 : tFixedPoint) : GR32.tFixed;
  begin
  { result := norma(x0, x1)  + norma(x1, x2) + norma(x2, x3); }
  result := abs(x0.X - x1.x) + abs(x0.Y - x1.Y) +
            abs(x1.X - x2.x) + abs(x1.Y - x2.Y) +
            abs(x2.X - x3.x) + abs(x2.Y - x3.Y);
  end;

  { qubic bezier segment conditional length in norm2 (supremum valuation) }
  function SegmentConditionalLengthQ3N2Sup(const x0, x1, x2, x3 : tFixedPoint) : GR32.tFixed;
  begin
  { result := Distance(x0, x1)  + Distance(x1, x2) + Distance(x2, x3); }
  result := round(hypot(x0.X - x1.x, x0.Y - x1.Y) +
            hypot(x1.X - x2.x, x1.Y - x2.Y) +
            hypot(x2.X - x3.x, x2.Y - x3.Y) );
  end;

  { qubic bezier segment conditional curvatre in norm1 }
  function SegmentConditionalCurvatureQ2(const x0, x1, x2 : tFixedPoint) :GR32.tFixed;
  begin
   result := SegmentConditionalLengthQ2N1Sup(x0, x1, x2);
  end;

{ two functions to incapsulate points adding to ArrayOfFixedPoint  one by one -
 for optimization in future if will need}
procedure AFP_AddPoint(var vPP : TArrayOfFixedPoint; const p : tFixedPoint);
var
  L : integer;
begin
  L := Length(vPP);
  SetLength(vPP,  L + 1);
  vPP[L] := p;
end;

procedure AFP_AddPoint2(var vPP : TArrayOfFixedPoint; const p1, p2 : tFixedPoint);
var
  L : integer;
begin
  L := Length(vPP);
  SetLength(vPP,  L + 2);
  vPP[L] := p1;
  vPP[L+1] := p2;
end;

procedure gRectangleHole(xBitmap : tBitmap32;
                           const xRect : tFixedRect;
                           const xColor : tColor32;
                           const xOptions : tPolygonDrawOptions);
var
  PP : TArrayOfArrayOfFixedPoint;

  function point(const x, y : GR32.tFixed) : tFixedPoint;
  begin
    result.x := x;
    result.y := y;
  end;
begin
  SetLength(PP, 2);
  Setlength(PP[0], 4);
  Setlength(PP[1], 4);

  PP[0, 0] := point(GR32.Fixed(-1), GR32.Fixed(-1));
  PP[0, 1] := point(GR32.Fixed(xBitmap.Width + 1), GR32.Fixed(-1));
  PP[0, 2] := point(GR32.Fixed(xBitmap.Width + 1), GR32.Fixed(xBitmap.Height + 1));
  PP[0, 3] := point(GR32.Fixed(-1), GR32.Fixed(xBitmap.Height + 1));

  PP[1, 0] := xRect.TopLeft;
  PP[1, 1] := point(xRect.Right, xRect.Top);
  PP[1, 2] := xRect.BottomRight;
  PP[1, 3] := point(xRect.left, xRect.Bottom);

  gPolyPolygon(xBitmap, PP, xColor, xOptions, true);

  PP := nil;
end;

{ draw simple ellipse }
procedure gEllipse(xBitmap : tBitmap32;
                   const xRect : TFixedRect;
                   const xColor: TColor32;
                   const xOptions : tPolygonDrawOptions = pdoFloat);
var
  PP : TArrayOfFixedPoint;
  dy, dx : integer;
  C      : tFixedPoint; // цент?
begin
  { rus: аппроксимируем эллипс четырь? узлами,
    хо? на само?деле можн??двумя - та?просто удобне?}
  { eng: approximate ellipse with four curve }

  c := MiddleLine(xRect.TopLeft, xRect.BottomRight);

  dx := trunc((xRect.Right - xRect.Left)*EllipseToCurveCoeff_4);
  dy := trunc((xRect.Bottom - xRect.Top)*EllipseToCurveCoeff_4);
  SetLength(PP, 3*4 + 1);

  PP[0].x := xRect.Left;    PP[0].y := c.Y;
  PP[1].x := xRect.Left;    PP[1].y := c.Y - dy;
  PP[2].x := c.x - dx;      PP[2].y := xRect.Top;
  PP[3].x := c.x;           PP[3].y := xRect.Top;
  PP[4].x := c.x + dx;      PP[4].y := xRect.Top;
  PP[5].x := xRect.Right;   PP[5].y := PP[1].y;
  PP[6].x := xRect.Right;   PP[6].y := c.Y;
  PP[7].x := xRect.Right;   PP[7].y := c.Y + dy;
  PP[8].x := PP[4].x;       PP[8].y :=  xRect.Bottom;
  PP[9].x := c.x;           PP[9].y := xRect.Bottom;
  PP[10].x := PP[2].x;      PP[10].y:= xRect.Bottom;
  PP[11].x := xRect.Left;   PP[11].y:= PP[7].y;
  PP[12].x := xRect.Left;   PP[12].y:= c.Y;

  gPolyBezier(xBitmap, PP, xColor, xOptions, true);
  PP := nil;
end;


procedure LoadEllipseCurve(const xCenter : tFixedPoint;
                           const xA, xB : GR32.tFixed;  { if xAngle = 0 then A <-> width and xB <-> Height }
                           var yPP : TArrayOfFixedPoint);
var
  dy, dx : integer;
  A, B : GR32.tFixed;
begin
  dx := trunc(xA*EllipseToCurveCoeff_4);
  dy := trunc(xB*EllipseToCurveCoeff_4);
  A := xA div 2;
  B := xB div 2;
  SetLength(yPP, Length(yPP) + 3*4 + 1);
  yPP[0].x := xCenter.x - A;     yPP[0].y := xCenter.Y;
  yPP[1].x := yPP[0].x;          yPP[1].y := xCenter.Y - dy;
  yPP[2].x := xCenter.x - dx;    yPP[2].y := xCenter.Y - B;
  yPP[3].x := xCenter.x;         yPP[3].y := yPP[2].y;
  yPP[4].x := xCenter.x + dx;    yPP[4].y := yPP[2].y;
  yPP[5].x := xCenter.x + A;     yPP[5].y := xCenter.Y - dy;
  yPP[6].x := yPP[5].x;          yPP[6].y := xCenter.Y;
  yPP[7].x := yPP[5].x;          yPP[7].y := xCenter.Y + dy;
  yPP[8].x := xCenter.x + dx;    yPP[8].y := xCenter.Y + B;
  yPP[9].x := xCenter.x;         yPP[9].y := yPP[8].y;
  yPP[10].x := xCenter.x - dx;   yPP[10].y:= yPP[8].y;
  yPP[11].x := yPP[0].x;         yPP[11].y:= xCenter.Y + dy;
  yPP[12].x := yPP[0].x;         yPP[12].y:= xCenter.Y;

end;

{ draw rotated ellipse }
procedure gEllipseRotated(xBitmap : tBitmap32;
                          const xCenter : tFixedPoint;
                          const xA, xB : GR32.tFixed;  { if xAngle = 0 then A <-> width and xB <-> Height }
                          const xAngle : double;       { value in radians }
                          const xColor : tColor32;
                          const xOptions : tPolygonDrawOptions = pdoFloat);
var
  PP : TArrayOfFixedPoint;
begin
  { now, rotate vector PP on  xAngle }
  LoadEllipseCurve(xCenter, xA, xB, PP);
  RotateArrayOfFixedPoint(PP, xCenter, xAngle);

  gPolyBezier(xBitmap, PP, xColor, xOptions, true);
  PP := nil;
end;

procedure gEllipseT(xBitmap : tBitmap32;
                            const xCenter : tFixedPoint;
                            const xA, xB : GR32.tFixed; { if xAngle = 0 then A <-> width and xB <-> Height }
                            const xAT : TFloatMatrix;
                            const xColor : tColor32;
                            const xOptions : tPolygonDrawOptions = pdoFloat);
var
  PP : TArrayOfFixedPoint;
begin
  LoadEllipseCurve(xCenter, xA, xB, PP);
  { now, rotate vector PP on  xAngle }
  TransformArrayOfFixedPoint(PP, xAT);

  gPolyBezier(xBitmap, PP, xColor, xOptions, true);
  PP := nil;
end;


procedure LoadArcCurve(const xCenter : tFixedPoint;
                        const xA, xB : GR32.tFixed;
                        const xStartAngle, xEndAngle : double; { values in radians }
                        var yPP : TArrayOfFixedPoint);
var
  SinA, CosA, SinB, CosB, SinD, CosD : extended;
  dAngle : double;
  bcp : double;
  StartIndex : integer;
begin
  { calculation formulas based on http://www.stillhq.com/ctpfaq/2002/03/c1088.html#AEN1144 }

  dAngle := xEndAngle - xStartAngle;

  { if valuation of arc length is verty small then exit;
   //  formula: length for circle (angle = 2pi) is 2*pi*R
       so length for ellipse ~ angle*(R1+R2)/2 }
  if abs(dAngle)*(xA+xB) < eps_Fixed then
    begin
    exit;
    end;

  if abs(dAngle) >= pi then
    begin
    { DONE : split on two angles }
    LoadArcCurve(xCenter, xA, xB, xStartAngle, xStartAngle + 0.5*dAngle, yPP);
    LoadArcCurve(xCenter, xA, xB, xStartAngle + 0.5*dAngle, xEndAngle, yPP);
    exit;
    end;

  SinCos(xStartAngle, SinA, CosA);
  SinCos(xEndAngle, SinB, CosB);
  SinCos(dAngle*0.5, SinD, CosD);

  bcp := 4.0/3 * (1 - cosD)/SinD;

  StartIndex := Length(yPP);
  if StartIndex = 0 then
    begin
    SetLength(yPP, StartIndex + 4);

    yPP[StartIndex].x := xCenter.x + round(xA*CosA);
    yPP[StartIndex].y := xCenter.y - round(xB*SinA);
    end
  else
    begin
    SetLength(yPP, StartIndex + 3);
    dec(StartIndex);
    end;

  yPP[StartIndex + 1].x := xCenter.x + round(xA*(CosA - bcp*SinA));
  yPP[StartIndex + 1].y := xCenter.y - round(xB*(SinA + bcp*CosA));
  yPP[StartIndex + 2].x := xCenter.x + round(xA*(CosB + bcp*SinB));
  yPP[StartIndex + 2].y := xCenter.y - round(xB*(SinB - bcp*CosB));
  yPP[StartIndex + 3].x := xCenter.x + round(xA*CosB);
  yPP[StartIndex + 3].y := xCenter.y - round(xB*SinB);
end;

procedure gArc(xBitmap : tBitmap32;
               const xCenter : tFixedPoint;
               const xR : GR32.tFixed;
               const xStartAngle, xEndAngle : double;
               const xColor : tColor32;
               const xOptions : tPolygonDrawOptions = pdoFloat);
begin
  gArcElliptic(xBitmap, xCenter, xR, xR, xStartAngle, xEndAngle, xColor, xOptions);
end;

procedure gArcElliptic(xBitmap : tBitmap32;
                       const xCenter : tFixedPoint;
                       const xA, xB : GR32.tFixed;
                       const xStartAngle, xEndAngle : double; { values in radians +- pi }
                       const xColor : tColor32;
                       const xOptions : tPolygonDrawOptions = pdoFloat);
var
  PP : TArrayOfFixedPoint;
begin
  SetLength(PP, 0);
  LoadArcCurve(xCenter, xA, xB, xStartAngle, xEndAngle, PP);
  gPolyBezier(xBitmap, PP, xColor, xOptions, false);
  PP := nil;
end;

{ draw elliptic and rotated arc }
procedure gArcER(xBitmap : tBitmap32;
                         const xCenter : tFixedPoint;
                         const xA, xB : GR32.tFixed;
                         const xStartAngle, xEndAngle : double; { values in radians }
                         const xRotAngle : double;
                         const xColor : tColor32;
                         const xOptions : tPolygonDrawOptions = pdoFloat);
var
  PP : TArrayOfFixedPoint;
begin
  SetLength(PP, 0);
  LoadArcCurve(xCenter, xA, xB, xStartAngle, xEndAngle, PP);
  RotateArrayOfFixedPoint(PP, xCenter, xRotAngle);
  gPolyBezier(xBitmap, PP, xColor, xOptions, false);
  PP := nil;
end;

{ draw elliptic and transformed arc }
procedure gArcET(xBitmap : tBitmap32;
                         const xCenter : tFixedPoint;
                         const xA, xB : GR32.tFixed;
                         const xStartAngle, xEndAngle : double; { values in radians }
                         const xAT : TFloatMatrix; { affine transformation matrix }
                         const xColor : tColor32;
                         const xOptions : tPolygonDrawOptions = pdoFloat);
var
  PP : TArrayOfFixedPoint;
begin
  SetLength(PP, 0);
  LoadArcCurve(xCenter, xA, xB, xStartAngle, xEndAngle, PP);
  TransformArrayOfFixedPoint(PP, xAT);
  gPolyBezier(xBitmap, PP, xColor, xOptions, false);
  PP := nil;
end;


procedure gSegment(xBitmap : tBitmap32;
                 const xCenter : tFixedPoint;
                 const xR : GR32.tFixed;
                 const xStartAngle, xEndAngle : double;
                 const xColor : tColor32;
                 const xOptions : tPolygonDrawOptions = pdoFloat);
begin
  gSegmentElliptic(xBitmap, xCenter, xR, xR, xStartAngle, xEndAngle, xColor, xOptions);
end;


procedure gSegmentElliptic(xBitmap : tBitmap32;
                       const xCenter : tFixedPoint;
                       const xA, xB : GR32.tFixed;
                       const xStartAngle, xEndAngle : double; { values in radians }
                       const xColor : tColor32;
                       const xOptions : tPolygonDrawOptions = pdoFloat);
var
  PP : TArrayOfFixedPoint;
begin
  SetLength(PP, 0);
  LoadArcCurve(xCenter, xA, xB, xStartAngle, xEndAngle, PP);
  gPolyBezier(xBitmap, PP, xColor, xOptions, true);
  PP := nil;
end;

{ draw elliptic and rotated segment for monsters }
procedure gSegmentER(xBitmap : tBitmap32;
                         const xCenter : tFixedPoint;
                         const xA, xB : GR32.tFixed;
                         const xStartAngle, xEndAngle : double; { values in radians }
                         const xRotAngle : double;
                         const xColor : tColor32;
                         const xOptions : tPolygonDrawOptions = pdoFloat);
var
  PP : TArrayOfFixedPoint;
begin
  SetLength(PP, 0);
  LoadArcCurve(xCenter, xA, xB, xStartAngle, xEndAngle, PP);
  RotateArrayOfFixedPoint(PP, xCenter, xRotAngle);
  gPolyBezier(xBitmap, PP, xColor, xOptions, true);
  PP := nil;
end;

{ draw elliptic and transformed segment }
 procedure gSegmentET(xBitmap : tBitmap32;
                         const xCenter : tFixedPoint;
                         const xA, xB : GR32.tFixed;
                         const xStartAngle, xEndAngle : double; { values in radians }
                         const xAT : TFloatMatrix; { affine transformation matrix }
                         const xColor : tColor32;
                         const xOptions : tPolygonDrawOptions = pdoFloat);
var
  PP : TArrayOfFixedPoint;
begin
  SetLength(PP, 0);
  LoadArcCurve(xCenter, xA, xB, xStartAngle, xEndAngle, PP);
  TransformArrayOfFixedPoint(PP,xAT);
  gPolyBezier(xBitmap, PP, xColor, xOptions, true);
  PP := nil;
end;

procedure gPie(xBitmap : tBitmap32;
               const xCenter : tFixedPoint;
               const xR : GR32.tFixed;
               const xStartAngle, xEndAngle : double;
               const xColor : tColor32;
               const xOptions : tPolygonDrawOptions = pdoFloat);
begin
  gPieElliptic(xBitmap, xCenter, xR, xR, xStartAngle, xEndAngle, xColor, xOptions);
end;

procedure gPieElliptic(xBitmap : tBitmap32;
                       const xCenter : tFixedPoint;
                       const xA, xB : GR32.tFixed;
                       const xStartAngle, xEndAngle : double; { values in radians }
                       const xColor : tColor32;
                       const xOptions : tPolygonDrawOptions = pdoFloat);
var
  PP : TArrayOfFixedPoint;
  L  : integer;
begin
  SetLength(PP, 0);
  LoadArcCurve(xCenter, xA, xB, xStartAngle, xEndAngle, PP);

  { connect with center }
  L := Length(PP);
  SetLength(PP, L + 3);
  PP[L] := PP[L-1];
  PP[L + 1]  := xCenter;
  PP[L + 2 ] := xCenter;

  gPolyBezier(xBitmap, PP, xColor, xOptions, true);

  PP := nil;
end;

{ draw elliptic rotated pie }
procedure gPieER(xBitmap : tBitmap32;
                         const xCenter : tFixedPoint;
                         const xA, xB : GR32.tFixed;
                         const xStartAngle, xEndAngle : double; { values in radians }
                         const xRotAngle : double;
                         const xColor : tColor32;
                         const xOptions : tPolygonDrawOptions = pdoFloat);
var
  PP : TArrayOfFixedPoint;
  L  : integer;
begin
  { calculation formulas based on http://www.stillhq.com/ctpfaq/2002/03/c1088.html#AEN1144 }
  SetLength(PP, 0);
  LoadArcCurve(xCenter, xA, xB, xStartAngle, xEndAngle, PP);

  { connect with center }
  L := Length(PP);
  SetLength(PP, L + 3);
  PP[L] := PP[L-1];
  PP[L + 1]  := xCenter;
  PP[L + 2 ] := xCenter;

  RotateArrayOfFixedPoint(PP, xCenter, xRotAngle);
  gPolyBezier(xBitmap, PP, xColor, xOptions, true);

  PP := nil;
end;

{ draw elliptic and transformed pie }
procedure gPieET(xBitmap : tBitmap32;
                         const xCenter : tFixedPoint;
                         const xA, xB : GR32.tFixed;
                         const xStartAngle, xEndAngle : double; { values in radians }
                         const xAT : TFloatMatrix; { affine transformation matrix }
                         const xColor : tColor32;
                         const xOptions : tPolygonDrawOptions = pdoFloat);
var
  PP : TArrayOfFixedPoint;
  L  : integer;
begin
  { calculation formulas based on http://www.stillhq.com/ctpfaq/2002/03/c1088.html#AEN1144 }
  SetLength(PP, 0);
  LoadArcCurve(xCenter, xA, xB, xStartAngle, xEndAngle, PP);

  { connect with center }
  L := Length(PP);
  SetLength(PP, L + 3);
  PP[L] := PP[L-1];
  PP[L + 1]  := xCenter;
  PP[L + 2 ] := xCenter;

  TransformArrayOfFixedPoint(PP, xAT);
  gPolyBezier(xBitmap, PP, xColor, xOptions, true);

  PP := nil;
end;


{ draw rounded rectangle }
procedure gRectangleRounded(xBitmap : tBitmap32;
                            const xRect : TFixedRect;
                            const xR    : GR32.TFixed;
                            const xColor : tColor32;
                            const  xOptions : tPolygonDrawOptions = pdoFloat);

var
  PP : tArrayOfFixedPoint;
  dR : GR32.TFixed;
begin
  dR := round(EllipseToCurveCoeff_2inv*xR);

  SetLength(PP, 22);

  PP[0].x := xRect.Right - xR;    PP[0].y := xRect.Top;
  PP[1].x := xRect.Right - dR;    PP[1].y := xRect.Top;
  PP[2].x := xRect.Right;         PP[2].y := xRect.Top + dR;
  PP[3].x := xRect.Right;         PP[3].y := xRect.Top + xR;
  PP[4].x := xRect.Right;         PP[4].y := pp[3].y;

  PP[5].x := xRect.Right;         PP[5].y := xRect.Bottom  - xR;
  PP[6].x := xRect.Right;         PP[6].y := PP[5].y;
  PP[7].x := xRect.Right;         PP[7].y := xRect.Bottom  - dR;
  PP[8].x := PP[1].x;             PP[8].y := xRect.Bottom;
  PP[9].x := PP[0].x;             PP[9].y := xRect.Bottom;
  PP[10].x := PP[0].x;            PP[10].y := xRect.Bottom;


  PP[11].x := xRect.Left + xR;  PP[11].y := xRect.Bottom;
  PP[12].x := PP[11].x;         PP[12].y := xRect.Bottom;
  PP[13].x := xRect.Left + dR;  PP[13].y := xRect.Bottom;
  PP[14].x := xRect.Left;       PP[14].y := PP[7].y;
  PP[15].x := xRect.Left;       PP[15].y := PP[5].y;
  PP[16].x := xRect.Left;       PP[16].y := PP[5].y;

  PP[17].x := xRect.Left;       PP[17].y := PP[3].y;
  PP[18].x := xRect.Left;       PP[18].y := PP[3].y;
  PP[19].x := xRect.Left;       PP[19].y := PP[2].y;
  PP[20].x := PP[13].x;         PP[20].y := xRect.Top;
  PP[21].x := PP[11].x;         PP[21].y := xRect.Top;

  gPolyBezier(xBitmap, PP, xColor, xOptions, true);
  PP := nil;
end;

{ draw rounded and rotated rectangle }
procedure gRectangleRR(xBitmap : tBitmap32;
                         const xCenter : tFixedPoint;
                         const xA, xB : GR32.tFixed;
                         const xR     : GR32.tFixed;
                         const xAngle : double;
                         const xColor : tColor32;
                         const xOptions : tPolygonDrawOptions = pdoFloat);
var
  PP : tArrayOfFixedPoint;
  dR : GR32.TFixed;
  vRect : tFixedRect;
begin
  dR := round(EllipseToCurveCoeff_2inv*xR);

  vRect := G32_Interface.FixedRect(xCenter.x - xA, xCenter.y - xB, xCenter.x + xA, xCEnter.y + xB);

  SetLength(PP, 22);

  PP[0].x := vRect.Right - xR;    PP[0].y := vRect.Top;
  PP[1].x := vRect.Right - dR;    PP[1].y := vRect.Top;
  PP[2].x := vRect.Right;         PP[2].y := vRect.Top + dR;
  PP[3].x := vRect.Right;         PP[3].y := vRect.Top + xR;
  PP[4].x := vRect.Right;         PP[4].y := pp[3].y;

  PP[5].x := vRect.Right;         PP[5].y := vRect.Bottom  - xR;
  PP[6].x := vRect.Right;         PP[6].y := PP[5].y;
  PP[7].x := vRect.Right;         PP[7].y := vRect.Bottom  - dR;
  PP[8].x := PP[1].x;             PP[8].y := vRect.Bottom;
  PP[9].x := PP[0].x;             PP[9].y := vRect.Bottom;
  PP[10].x := PP[0].x;            PP[10].y := vRect.Bottom;

  PP[11].x := vRect.Left + xR;  PP[11].y := vRect.Bottom;
  PP[12].x := PP[11].x;         PP[12].y := vRect.Bottom;
  PP[13].x := vRect.Left + dR;  PP[13].y := vRect.Bottom;
  PP[14].x := vRect.Left;       PP[14].y := PP[7].y;
  PP[15].x := vRect.Left;       PP[15].y := PP[5].y;
  PP[16].x := vRect.Left;       PP[16].y := PP[5].y;

  PP[17].x := vRect.Left;       PP[17].y := PP[3].y;
  PP[18].x := vRect.Left;       PP[18].y := PP[3].y;
  PP[19].x := vRect.Left;       PP[19].y := PP[2].y;
  PP[20].x := PP[13].x;         PP[20].y := vRect.Top;
  PP[21].x := PP[11].x;         PP[21].y := vRect.Top;

  RotateArrayOfFixedPoint(PP, xCenter, xAngle);
  gPolyBezier(xBitmap, PP, xColor, xOptions, true);
  PP := nil;
end;


procedure BuildCardinalSplineCurve(xPoints : tArrayOfFixedPoint;
                                   const xTension : double;
                                   const xClosed : boolean;
                                   out yPP : tArrayOfFixedPoint);
var
  N : integer;
  i : integer;
  ind : integer;
  K : double;
begin
  N := Length(xPoints);
  if N < 3 then exit;

  { curve segment points  formula :
      b0 := P[n]
      b1 := b0 + (1-t)*(p[n+1] - p[n-1])/6;
      b2 := b3 - (1-t)*(p[n+2] - p[n])/6;
      b3 := p[n+1]
    }
  K := (1-xTension)*Ratio6;

  if xClosed then SetLength(yPP, N*3 + 1)
             else SetLength(yPP, (N - 1)*3 + 1);


    { -- load first segment :}
    yPP[0] := xPoints[0];
    if xClosed then
      begin
      { if i = 0 then i - 1 = N - 1}
      yPP[1].x := yPP[0].x + round(K*(xPoints[1].x - xPoints[N-1].x));
      yPP[1].y := yPP[0].y + round(K*(xPoints[1].y - xPoints[N-1].y));
      end
    else
      begin
      yPP[1] := xPoints[0];  // for free ends
      end;
    yPP[3] := xPoints[1];
    yPP[2].x := yPP[3].x - round(K*(xPoints[2].x - xPoints[0].x));
    yPP[2].y := yPP[3].y - round(K*(xPoints[2].y - xPoints[0].y));
    { -- laod inner segments :}
    for i := 1 to N - 3 do
      begin
      ind := 3*i;
      { yPP[i] already assigned }

      yPP[ind + 1].x := yPP[ind].x + round(K*(xPoints[i+1].x - xPoints[i-1].x));
      yPP[ind + 1].y := yPP[ind].y + round(K*(xPoints[i+1].y - xPoints[i-1].y));
      yPP[ind + 2].x := xPoints[i+1].x - round(K*(xPoints[i+2].x - xPoints[i].x));
      yPP[ind + 2].y := xPoints[i+1].y - round(K*(xPoints[i+2].y - xPoints[i].y));
      yPP[ind + 3] := xPoints[i+1];
      end;
    { -- load last segment : }
    ind := 3*(N-2);
    { yPP[ind] := xPoints[N-2]; already assigned }
    yPP[ind + 1].x := yPP[ind].x + round(K*(xPoints[N-1].x - xPoints[N-3].x));
    yPP[ind + 1].y := yPP[ind].y + round(K*(xPoints[N-1].y - xPoints[N-3].y));
    if xClosed then
      begin
      {if i = n - 2 then i + 2 = 0}
      yPP[ind + 2].x := xPoints[N-1].x - round(K*(xPoints[0].x - xPoints[N-2].x));
      yPP[ind + 2].y := xPoints[N-1].y - round(K*(xPoints[0].y - xPoints[N-2].y));
      end
    else
      begin
      yPP[ind + 2] := xPoints[n-1];
      end;
    yPP[ind + 3] := xPoints[n-1];

    { now, if closed connect first and last points by curve segments }
    if xClosed   then
      begin
      ind := 3*(N-1);
      yPP[ind + 1].x := yPP[ind].x + round(K*(xPoints[0].x - xPoints[N-2].x));
      yPP[ind + 1].y := yPP[ind].y + round(K*(xPoints[0].y - xPoints[N-2].y));
      yPP[ind + 2].x := xPoints[0].x - round(K*(xPoints[1].x - xPoints[N-1].x));
      yPP[ind + 2].y := xPoints[0].y - round(K*(xPoints[1].y - xPoints[N-1].y));
      yPP[ind + 3] := xPoints[0];
      end;


end;

(*procedure BuildNormalizedCardinalSplineCurve(xPoints : tArrayOfFixedPoint;
                                   const xTension : double;
                                   const xClosed : boolean;
                                   out yPP : tArrayOfFixedPoint);
var
  N : integer;
  i : integer;
  ind : integer;
  K : double;
  L : double;
  L1 : double;
  L2 : double;
begin
  N := Length(xPoints);
  if N < 3 then exit;

  { curve segment points  formula :
      b0 := P[n]
      b1 := b0 + (1-t)*(p[n+1] - p[n-1])/6;
      b2 := b3 - (1-t)*(p[n+2] - p[n])/6;
      b3 := p[n+1]
    }
  K := (1-xTension)*Ratio6;

  if xClosed then SetLength(yPP, N*3 + 1)
             else SetLength(yPP, (N - 1)*3 + 1);


    { -- load first segment :}
    yPP[0] := xPoints[0];
    if xClosed then
      begin
      { if i = 0 then i - 1 = N - 1}
      yPP[1].x := yPP[0].x + round(K*(xPoints[1].x - xPoints[N-1].x));
      yPP[1].y := yPP[0].y + round(K*(xPoints[1].y - xPoints[N-1].y));
      end
    else
      begin
      yPP[1] := xPoints[0];  // for free ends
      end;
    yPP[3] := xPoints[1];
    yPP[2].x := yPP[3].x - round(K*(xPoints[2].x - xPoints[0].x));
    yPP[2].y := yPP[3].y - round(K*(xPoints[2].y - xPoints[0].y));
    { -- laod inner segments :}
    for i := 1 to N - 3 do
      begin
      ind := 3*i;
      { yPP[i] already assigned }
      L := Distance(xPoints[i], xPoints[i+1]);
      L1 := Distance(xPoints[i-1], xPoints[i+1]);
      L2 := Distance(xPoints[i], xPoints[i+2]);
      yPP[ind + 1].x := yPP[ind].x + round(K*(xPoints[i+1].x - xPoints[i-1].x)*L/L1);
      yPP[ind + 1].y := yPP[ind].y + round(K*(xPoints[i+1].y - xPoints[i-1].y)*L/L1);
      yPP[ind + 2].x := xPoints[i+1].x - round(K*(xPoints[i+2].x - xPoints[i].x)*L/L2);
      yPP[ind + 2].y := xPoints[i+1].y - round(K*(xPoints[i+2].y - xPoints[i].y)*L/L2);
      yPP[ind + 3] := xPoints[i+1];
      end;
    { -- load last segment : }
    ind := 3*(N-2);
    { yPP[ind] := xPoints[N-2]; already assigned }
    yPP[ind + 1].x := yPP[ind].x + round(K*(xPoints[N-1].x - xPoints[N-3].x));
    yPP[ind + 1].y := yPP[ind].y + round(K*(xPoints[N-1].y - xPoints[N-3].y));
    if xClosed then
      begin
      {if i = n - 2 then i + 2 = 0}
      yPP[ind + 2].x := xPoints[N-1].x - round(K*(xPoints[0].x - xPoints[N-2].x));
      yPP[ind + 2].y := xPoints[N-1].y - round(K*(xPoints[0].y - xPoints[N-2].y));
      end
    else
      begin
      yPP[ind + 2] := xPoints[n-1];
      end;
    yPP[ind + 3] := xPoints[n-1];

    { now, if closed connect first and last points by curve segments }
    if xClosed   then
      begin
      ind := 3*(N-1);
      yPP[ind + 1].x := yPP[ind].x + round(K*(xPoints[0].x - xPoints[N-2].x));
      yPP[ind + 1].y := yPP[ind].y + round(K*(xPoints[0].y - xPoints[N-2].y));
      yPP[ind + 2].x := xPoints[0].x - round(K*(xPoints[1].x - xPoints[N-1].x));
      yPP[ind + 2].y := xPoints[0].y - round(K*(xPoints[1].y - xPoints[N-1].y));
      yPP[ind + 3] := xPoints[0];
      end;
end;
*)
procedure gCardinalSpline(xBitmap : tBitmap32;
                            const xPoints : tArrayOfFixedPoint;
                            const xTension : double;
                            const xColor : tColor32;
                            const xClosed : boolean;
                            const xOptions : tPolygonDrawOptions = pdoFloat);
var
  PP : tArrayOfFixedPoint;
begin
  BuildCardinalSplineCurve(xPoints, xTension, xClosed, PP);
  gPolyBezier(xBitmap, PP, xColor, xOptions, xClosed);
  PP := nil;
end;

procedure gPolyCardinalSpline(xBitmap : tBitmap32;
                            const xPoints : tArrayOfArrayOfFixedPoint;
                            const xTension : double;
                            const xColor : tColor32;
                            const xClosed : boolean;
                            const xOptions : tPolygonDrawOptions = pdoFloat);
var
  i : integer;
  PP : tArrayOfArrayOfFixedPoint;
begin
  SetLength(PP, Length(xPoints));
  for i := 0 to Length(xPoints) - 1 do
    begin
    BuildCardinalSplineCurve(xPoints[i], xTension, xClosed, PP[i]);
    end;
  gPolyPolyBezier(xBitmap, PP, xColor, xOptions, xClosed);
  PP := nil;
end;

procedure BuildTCBSplineCurve(xPoints : tArrayOfFixedPoint;
                              const xTension : double;
                              const xContinuity : double;
                              const xBias : double;
                              const xClosed : boolean;
                              out yPP : tArrayOfFixedPoint);
var
  N : integer;
  i : integer;
  ind : integer;
  K   : double;
  Kmc : double;
  Kpc : double;
  Kmb : double;
  Kpb : double;
  k11, k12, k21, k22 : double;

begin
  N := Length(xPoints);
  if N < 3 then exit;

  { curve segment points  formula :
   --------------
      b0 := P[n]
      b1 := b0 + (1-t)*[ (1+b)(1-c)(P[n] - P[n-1]) + (1-b)(1+c)(P[n+1]-P[n]) ]/6;
      b2 := b3 - (1-t)*[ (1+b)(1+c)(P[n+1] - P[n]) + (1-b)(1-c)(P[n+2]-P[n+1]) ] /6;
      b3 := p[n+1]
  }
    K := (1-xTension)*Ratio6;
    Kmc := 1 - xContinuity; // minus c
    Kpc := 1 + xContinuity; // plus c
    Kmb := 1 - xBias; // minus b
    Kpb := 1 + xBias; // plus b

    k11 := k*Kpb*Kmc;
    K12 := k*Kmb*Kpc;
    k21 := k*Kpb*Kpc;
    K22 := k*Kmb*Kmc;
  {
    b1 := b0 + (k11 * (p[n] - p[n-1]) + k12 * (p[n+1] - p[n])
    b2 := b3 - (k21 * (p[n+1] - p[n]) + k22 * (p[n+2] - p[n+1])
  }

   if xClosed then SetLength(yPP, N*3 + 1)
              else SetLength(yPP, (N - 1)*3 + 1);


    { -- load first segment :}
    yPP[0] := xPoints[0];
    if xClosed then
      begin
      yPP[1].x := yPP[0].x + round(K11*(xPoints[0].x - xPoints[N-1].x) + K12*(xPoints[1].x - xPoints[0].x));
      yPP[1].y := yPP[0].y + round(K11*(xPoints[0].y - xPoints[N-1].y) + K12*(xPoints[1].y - xPoints[0].y));
      end
    else
      begin
      yPP[1] := xPoints[0];
      end;
    yPP[3] := xPoints[1];
    yPP[2].x := yPP[3].x - round(K21*(xPoints[1].x - xPoints[0].x) + k22*(xPoints[2].x - xPoints[1].x));
    yPP[2].y := yPP[3].y - round(K21*(xPoints[1].y - xPoints[0].y) + k22*(xPoints[2].y - xPoints[1].y));
    { -- laod inner segments :}
    for i := 1 to N - 3 do
      begin
      ind := 3*i;
      yPP[ind + 1].x := yPP[ind].x + round(K11*(xPoints[i].x - xPoints[i-1].x) + K12*(xPoints[i+1].x - xPoints[i].x));
      yPP[ind + 1].y := yPP[ind].y + round(K11*(xPoints[i].y - xPoints[i-1].y) + K12*(xPoints[i+1].y - xPoints[i].y));
      yPP[ind + 2].x := xPoints[i+1].x - round(K21*(xPoints[i+1].x - xPoints[i].x) + k22*(xPoints[i+2].x - xPoints[i+1].x));
      yPP[ind + 2].y := xPoints[i+1].y - round(K21*(xPoints[i+1].y - xPoints[i].y) + k22*(xPoints[i+2].y - xPoints[i+1].y));
      yPP[ind + 3] := xPoints[i+1];
      end;
    { -- load last segment : }
    ind := 3*(N-2);
    { yPP[ind] := xPoints[N-2]; already assigned ; i = N -2}
    yPP[ind + 1].x := yPP[ind].x + round(K11*(xPoints[N-2].x - xPoints[N-3].x) + K12*(xPoints[N-1].x - xPoints[N-2].x));
    yPP[ind + 1].y := yPP[ind].y + round(K11*(xPoints[N-2].y - xPoints[N-3].y) + K12*(xPoints[N-1].y - xPoints[N-2].y));
    if xClosed then
      begin
      {if i = n - 2 then i + 2 = 0}
      yPP[ind + 2].x := xPoints[N-1].x - round(K21*(xPoints[N-1].x - xPoints[N-2].x) + k22*(xPoints[0].x - xPoints[N-1].x));
      yPP[ind + 2].y := xPoints[N-1].y - round(K21*(xPoints[N-1].y - xPoints[N-2].y) + k22*(xPoints[0].y - xPoints[N-1].y));
      end
    else
      begin
      yPP[ind + 2] := xPoints[n-1];
      end;
    yPP[ind + 3] := xPoints[n-1];

    { now, if closed connect first and last points by curve segments }
    if xClosed   then
      begin
      ind := 3*(N-1);
      yPP[ind + 1].x := yPP[ind].x + round(K11*(xPoints[N-1].x - xPoints[N-2].x) + K12*(xPoints[0].x - xPoints[N-1].x));
      yPP[ind + 1].y := yPP[ind].y + round(K11*(xPoints[N-1].y - xPoints[N-2].y) + K12*(xPoints[0].y - xPoints[N-1].y));
      yPP[ind + 2].x := xPoints[0].x - round(K21*(xPoints[0].x - xPoints[N-1].x) + k22*(xPoints[1].x - xPoints[0].x));
      yPP[ind + 2].y := xPoints[0].y - round(K21*(xPoints[0].y - xPoints[N-1].y) + k22*(xPoints[1].y - xPoints[0].y));
      yPP[ind + 3] := xPoints[0];
      end;
end;



procedure gTCBSpline(xBitmap : tBitmap32;
                          const xPoints : tArrayOfFixedPoint;
                          const xTension : double;
                          const xContinuity : double;
                          const xBias : double;
                          const xColor : tColor32;
                          const xClosed : boolean;
                          const xOptions : tPolygonDrawOptions = pdoFloat);
var
  PP : tArrayOfFixedPoint;
begin
  BuildTCBSplineCurve(xPoints, xTension, xContinuity, xBias, xClosed, PP);
  gPolyBezier(xBitmap, PP, xColor, xOptions, xClosed);
  PP := nil;
end;

procedure gPolyTCBSpline(xBitmap : tBitmap32;
                          const xPoints : tArrayOfArrayOfFixedPoint;
                          const xTension : double;
                          const xContinuity : double;
                          const xBias : double;
                          const xColor : tColor32;
                          const xClosed : boolean;
                          const xOptions : tPolygonDrawOptions = pdoFloat);
var
  i : integer;
  PP : tArrayOfArrayOfFixedPoint;
begin
  SetLength(PP, Length(xPoints));
  for i := 0 to Length(xPoints) - 1 do
    begin
    BuildTCBSplineCurve(xPoints[i], xTension, xContinuity, xBias, xClosed, PP[i]);
    end;
  gPolyPolyBezier(xBitmap, PP, xColor, xOptions, xClosed);
  PP := nil;
end;

procedure CalculateRoundsArc(const p1, p2, p3 : tFixedPoint;
                             const xR : GR32.tFixed;
                             out p21, p22 : tFixedPoint; // end points of arc
                             out yC : tFixedPoint;       // center of arc
                             out yStartAngle, yEndAngle :double);
var
  d  : double; { distance from p2 to p21 = distance from p2 to p22 }
  f  : double; { distance from p2 to yC - center }
  A, B, C : double; { angles }
  SinB, SinC, CosB, CosC : extended;
  SinAB, CosAB : extended;

  CB : double;
  SignCB : TValueSign;
  absCB : double;
begin
  {we must remember, that y axes inverted}
  if PointsAreEqual(p1, p2) or PointsAreEqual(p2, p3) or PointsAreEqual(p1,p3) then
    begin
    yStartAngle := 0;
    yEndAngle := 0;
    p21 := p2; p22 := p2; yC := p2;
    exit;
    end;

  B := arctan2(p2.Y - p3.Y, p3.x - p2.X);
  C := arctan2(p2.Y - p1.Y, p1.x - p2.X);

  if (C < 0)  then C  := pi2 + C;
  if (B < 0)  then  B := pi2 + B;

  CB := C - B;
  SignCB := Math.Sign(CB);
  AbsCB  := abs(CB);

  A := 0.5*(C + B); // биссектрис??сторну меньшего угла
  if absCB > pi then
    begin
    if A >= pi then A := A - pi
    else A := pi + A;
    end;

  d := abs(xR*Cotan(A-B));
  f := abs(xR*Cosecant(A-B));

  SinCos(B, SinB, CosB);
  SinCos(C, SinC, CosC);
  SinCos(A, SinAB, CosAB);

  p21.x := p2.x + round(d*CosC); p21.y := p2.y - round(d*SinC);
  p22.x := p2.x + round(d*CosB); p22.y := p2.y - round(d*SinB);
  yC.x := p2.x  + round(f*CosAB); yC.y := p2.y - round(f*SinAB);

  if absCB < pi then
    begin
    yStartAngle := C + SignCB*PIdiv2;
    yEndAngle   := yStartAngle + SignCB*(pi - absCB);
    end
  else
    begin
    yStartAngle := C - SignCB*PIdiv2;
    yEndAngle   := yStartAngle + SignCB*(pi - absCB);
    end;
end;


{ asumed that p1 point alway in yPP, we shuld add p21, p22 and two control point }
procedure LoadRoundsCurve(const p1, p2, p3 : tFixedPoint;
                          const xR : GR32.tFixed;
                          var yPP : TArrayOfFixedPoint;
                          const xAddLast : boolean = true);
var
  p21, p22, vC : tFixedPoint;
  vStartAngle, vEndAngle : double;

  SI : integer; // start index
begin
  SI := Length(yPP);

  if PointsAreEqual(p1, p2) then
    begin
    { DONE : Treat this situation }
    AFP_AddPoint(yPP, p1);
    exit;
    end;

  if  PointsAreEqual(p2, p3) then
    begin
    { DONE : Treat this situation }
    AFP_AddPoint2(yPP, p2, p2);
    exit;
    end;
  CalculateRoundsArc(p1, p2, p3, xR, p21, p22, vC, vStartAngle, vEndAngle);
  if SI = 0 then
    begin
    AFP_AddPoint(yPP, p21);
    end
  else
    begin
    AFP_AddPoint2(yPP, p21, p21);
    end;

  LoadArcCurve(vC, xR, xR, vStartAngle, vEndAngle, yPP);

  if xAddLast then
    begin
    AFP_AddPoint(yPP, p22);
    end;
end;

procedure gDrawSymbol(xBitmap : tBitmap32;
                      const xP      : GR32.tFixedPoint;
                      const xSymbol : tSymbolKind;
                      const xSize   : GR32.tFixed;
                      const xColor  : tColor32;
                      const xOptions : tPolygonDrawOptions);
var
  xRect : tFixedRect;
  PP  : TArrayOfFixedPoint;
begin
  xRect.Left := xP.x - xSize ; xRect.Top := xP.y - xSize;
  xRect.Right := xP.x + xSize; xRect.Bottom := xP.y + xSize;

  case xSymbol of
    skCircle:
      begin
      gEllipse(xBitmap, xRect, xColor, xOptions);
      end;
    skSquare:
      begin
      SetLength(PP, 4);
      PP[0] := xRect.TopLeft;
      PP[1].x := xRect.Right;  PP[1].y := xRect.Top;
      PP[2] := xRect.BottomRight;
      PP[3].x := xRect.Left;  PP[3].y := xRect.Bottom;
      gPolygon(xBitmap, PP, xColor, xOptions, true);
      end;
    skTriangle:
      begin
      SetLength(PP, 3);
      PP[0].x := xRect.Left; PP[0].y := xRect.Bottom;
      PP[1].x := xP.x; PP[1].y := xRect.Top;
      PP[2].x := xRect.Right; PP[2].y := xRect.Bottom;
      gPolygon(xBitmap, PP, xColor, xOptions, true);
      end;
    skPlus:
      begin
      xBitmap.LineXS(xRect.Left, xP.y - HalfPixel,  xRect.Right, xP.y - HalfPixel, xColor);
      xBitmap.LineXS(xP.x - HalfPixel, xRect.Top,   xP.x - HalfPixel,  xRect.Bottom, xColor)
      end;
    skX:
      begin
      xBitmap.LineXS(xRect.Left +  PixelInFixed, xRect.Top +  PixelInFixed,
                     xRect.Right, xRect.Bottom, xColor);
      xBitmap.LineXS(xRect.Left + PixelInFixed, xRect.Bottom - PixelInFixed,
                     xRect.Right, xRect.Top , xColor);
      end;
    skStar:
      begin
      xBitmap.LineXS(xRect.Left +  PixelInFixed, xRect.Top +  PixelInFixed,
                     xRect.Right, xRect.Bottom, xColor);
      xBitmap.LineXS(xRect.Left + PixelInFixed, xRect.Bottom - PixelInFixed,
                     xRect.Right, xRect.Top , xColor);
      xBitmap.LineXS(xP.x, xRect.Top + PixelInFixed,   xP.x,  xRect.Bottom + PixelInFixed, xColor);
      end;
  end;
end;

procedure gDrawSymbols(xBitmap : tBitmap32;
                        const  xPoints : tArrayOfFixedPoint;
                        const  xSymbol : tSymbolKind;
                        const  xSize   : GR32.tFixed;
                        const  xColor  : tColor32;
                        const  xOptions : tPolygonDrawOptions);
var
  i : integer;
begin
  for i := 0 to Length(xPoints) - 1 do
    begin
    gDrawSymbol(xBitmap, xPoints[i], xSymbol, xSize, xColor, xOptions);
    end;
end;

procedure gPolygon(Bitmap: TBitmap32;
                   const Points: TArrayOfFixedPoint;
                   const Color: TColor32;
                   const Options : tPolygonDrawOptions;
                   const Closed: Boolean;
                   const FillMode: TPolyFillMode = pfAlternate);
begin
        if (Options and  pdoFloat)  = pdoFloat then
        begin
        { автоматическ?- Antialiasing }
        if ByteBool(Options and pdoFilling) then
          begin
          if (Options and  pdoFastFilling) = pdoFastFilling then
            begin
            PolygonTS(Bitmap, Points,   Color, FillMode); // rus: заполнение бе?сглаживания
                                                          // eng: fill without antialising
            PolylineXS(Bitmap, Points,   Color, true); // rus: границ?со сглаживанием
                                                       // eng: border with antialising
            end
          else
            begin
            PolygonXS(Bitmap, Points, Color, FillMode);
            end;
          end
        else
          begin
          PolylineXS(Bitmap, Points, Color, Closed);
          end
        end
      else
        begin
        { rus: используем целочисленну?арифметику }
        { eng: use integer-based methods }
        if ByteBool(Options and pdoAntialising) then
          begin
          if ByteBool(Options and pdoFilling) then PolygonXS(Bitmap, Points, Color, FillMode) //?автоматическ?включаем дробну?арифметику
                                      else PolylineAS(Bitmap, Points,   Color, Closed)
          end
        else
          begin
          if ByteBool(Options and pdoFilling) then PolygonTS(Bitmap, Points, Color, FillMode)
                                      else PolylineTS(Bitmap, Points,   Color, Closed);
          end
        end;
end;

procedure gPolyPolygon(Bitmap: TBitmap32;
                   const Points: TArrayOfArrayOfFixedPoint;
                   const Color: TColor32;
                   const Options : tPolygonDrawOptions;
                   const Closed: Boolean;
                   const FillMode: TPolyFillMode = pfAlternate);
begin
        if (Options and  pdoFloat)  = pdoFloat then
        begin
        { rus: автоматическ?- Antialiasing }
        if ByteBool(Options and pdoFilling) then
          begin
          if (Options and  pdoFastFilling) = pdoFastFilling then
            begin
            PolyPolygonTS(Bitmap, Points,   Color, FillMode); // rus: заполнение бе?сглаживания
            PolyPolylineXS(Bitmap, Points,   Color, true);    // rus: границ?со сглаживанием
            end
          else
            begin
            PolyPolygonXS(Bitmap, Points, Color, FillMode);
            end;
          end
        else
          begin
          PolyPolylineXS(Bitmap, Points, Color, Closed);
          end
        end
      else
        begin
          { rus: используем целочисленну?арифметику }
        if ByteBool(Options and pdoAntialising) then
          begin
          if ByteBool(Options and pdoFilling) then PolyPolygonXS(Bitmap, Points, Color, FillMode) //?автоматическ?включаем дробну?арифметику
                                      else PolyPolylineAS(Bitmap, Points,   Color, Closed)
          end
        else
          begin
          if ByteBool(Options and pdoFilling) then PolyPolygonTS(Bitmap, Points, Color, FillMode)
                                      else PolyPolylineTS(Bitmap, Points,   Color, Closed);
          end
        end;
end;


type
   tRelyativeRgn = (rrLeft, rrRight, rrTop, rrBottom, rrInside);
 { rus: относительно?положени?}
 { eng: relyative situation .. }

{.. on rectangle }
function GetRelRgn(const xP: tFixedPoint; const xR : TFixedRect) : tRelyativeRgn;
begin
  { rus: приорите?- по правой границ?(наиболее вероятной) }
  { eng: right side is most probable side}
  if (xP.x > xR.Right) then
     begin
     result := rrRight; exit;
     end;
  if (xP.y > xR.Bottom ) then
     begin
     result := rrBottom;
     exit;
     end;
  if (xP.x < xR.Left) then
     begin
     result := rrLeft;
     exit;
     end;
  if (xP.y < xR.Top) then
     begin
     result := rrTop;
     exit;
     end;
  result := rrInside
end;



{ rus: возвращает true, если доподлин?известно, чт?точк?нахо?тся за пределам?прямоугольник?
  условное правил?(достаточно?правил?:
  ломанн? лежи?за пределам?прямоугольник?  если вс?ее точк?нахо?тся по одну сторон?прямоугольник?
  например, вс?сниз?
 }

 { eng: return true, if surely kbowns all points lays out of rectangle
 }

function ClipPolyOutside(const xPoints : TArrayOfFixedPoint; const xR : TFixedRect) : boolean;
var
  OldRgn : tRelyativeRgn;
  i : integer;
begin
  result := true;
  if Length(xPoints) = 0 then exit;

  OldRgn := GetRelRgn(xPoints[0], xR);

  if (OldRgn = rrInside) then
    begin
    result := false;
    exit;
    end;

  if Length(xPoints) = 1 then exit;  { OldRgn <> rrInside }

  for i := 1 to Length(xPoints) - 1 do
    begin
    if OldRgn <> GetRelRgn(xPoints[i], xR) then
      begin
      result := false;
      exit;
      end;
    end;
end;

function ClipRectOutside(const p0, p1, p2, p3 : tFixedPoint; const xR : TFixedRect) : boolean; overload;
var
  OldRgn : tRelyativeRgn;
begin
  result := true;

  OldRgn := GetRelRgn(p0, xR);

  if (OldRgn = rrInside) then
    begin
    result := false;
    exit;
    end;

  result := (OldRgn = GetRelRgn(p1, xR)) and (OldRgn = GetRelRgn(p2, xR)) and (OldRgn = GetRelRgn(p3, xR));
end;

{ возвращает true, если доподлин?известно, чт?точк?нахо?тся за пределам?прямоульник?}
function ClipRectOutside(const p0, p1, p2 : tFixedPoint; const xR : TFixedRect) : boolean; overload;
var
  OldRgn : tRelyativeRgn;
begin
  result := true;

  OldRgn := GetRelRgn(p0, xR);

  if (OldRgn = rrInside) then
    begin
    result := false;
    exit;
    end;

  result := (OldRgn = GetRelRgn(p1, xR)) and (OldRgn = GetRelRgn(p2, xR));
end;


{
  CurvePoints -  список точе?аппроксимирующий кубическую кривую безъ?пр?вызове функци?LoadApproxCurve;
                 чтоб?выде?ть каждый ра?необходимуя па?ть сделан глобальным для моду? ?реализован?
                 интерфейсные фунции СP_xxx
}

{  eng:   СurvePoints - is a storage of linear approximation of qubic Bezier curve
}

const
  { rus: начально?количество точе??прирощение }
  MaxCurvePointsCount  = 512;
var
  CurvePoints : TArrayOfFixedPoint; {array of TFixedPoint;}       { глобальный список точе? чт?бы не выде?ть па?ть кажы?ра?}

  CurvePointsCount : integer;

  function g32i_GetCurvePointsCount : integer;
  begin
    result := CurvePointsCount;
  end;

  function g32i_GetCurvePointsMaxCount : integer;
  begin
    result := Length(CurvePoints);
  end;

  { eng: pretends only ! }
  { делаем ви? чт?очищае?точк?}
  procedure CP_Clear;
  begin
    CurvePointsCount := 0;
  end;

  procedure CP_Dispose;
  begin
    CP_Clear;
    SetLength(CurvePoints, 0);
  end;

  { добавляем точк?}
  procedure CP_Add(const p : tFixedPoint);
  begin
    {rus: бе?проверки переполнен?! }
    {eng:  !!! without overflow cheking !!! }
    CurvePoints[CurvePointsCount] := p;
    inc(CurvePointsCount);
  end;


{ rus: подготовка списка точе?кривой
  формируе?список точе?ломанной, аппроксимирующей кривую Безь?
  ?учётом видимост?(xClipRect) ?минимально?длин?кривой }

{ eng: Prepare list of points approximating  qubuce Bezier curve with clipping }

procedure BuildApproxCurve(const xPoints: TArrayOfFixedPoint;
                               const xMinSegmentLength : GR32.tFixed;
                               const xClipRect : tFixedRect
                               );
var
  i : integer;

  { разбивае?сегмен?x0, x1, x2, x3  на необходимо?количество ра? заполняя список СurvePoints[CurvePointsCount]
    функция рекурсивная
    условия: x0 - уж?добавленый узел
             x1, x2 - управляющие точк? которы?буду?либо добавлен? либо на основани?которы?буду?вычеслин?другие
             x3 - узел, которы??любо?случае буде?добавлен

   }
  { function is recoursive
    conditional:
    x0 - already added node
    x1, x2 are control points of segments, that can my added
    x3 - node, than should be added
    }
  procedure BreakSegment(const p0, p1, p2, p3 : tFixedPoint; xNeedClip : boolean);
  var
    p11, p21, p31, p22, p32, p33 : tFixedPoint;
  begin
       { если сегмен?вырожденны?ил?мы достигли предел?па?ти, то заканчивае?}
       { if segment is singular - no need to break  }
       if ((p0.x = p1.x) and (p0.y = p1.y) and (p2.x = p3.x) and (p2.y = p3.y)) then
         begin
          {$IFDEF OOPTIMIZE_CALLFUNCTIONS_CP_ADD}
            CurvePoints[CurvePointsCount] := p1;
            CurvePoints[CurvePointsCount+1] := p2;
            CurvePoints[CurvePointsCount+2] := p3;
            inc(CurvePointsCount, 3);
          {$ELSE}
            CP_Add(p1); CP_Add(p2); CP_Add(p3);
          {$ENDIF}
            exit;
         end;
      { if segment is out of clipping rect - no need break}
      if xNeedClip and ClipRectOutside(p0, p1, p2, p3, xClipRect) then
        begin
         { разбиват?не нужн?}
         {$IFDEF OPTIMIZE_CALLFUNCTIONS_CP_ADD}
            CurvePoints[CurvePointsCount] := p1;
            CurvePoints[CurvePointsCount+1] := p2;
            CurvePoints[CurvePointsCount+2] := p3;
            inc(CurvePointsCount, 3);
         {$ELSE}
           CP_Add(p1); CP_Add(p2); CP_Add(p3);
         {$ENDIF}
         exit;
        end;

      { если точк?заканчиваются, то нужн?подрастить множеств?точе?}
      { if need  - grow points list }
      if (CurvePointsCount >=  Length(CurvePoints) div 2 - 4) then    // ! div 2 - посколку функция рекурсивная
        begin
          try
            SetLength(CurvePoints, MaxCurvePointsCount + length(CurvePoints));
          except
           {$IFDEF OPTIMIZE_CALLFUNCTIONS_CP_ADD}
            CurvePoints[CurvePointsCount] := p1;
            CurvePoints[CurvePointsCount+1] := p2;
            CurvePoints[CurvePointsCount+2] := p3;
            inc(CurvePointsCount, 3);
          {$ELSE}
            CP_Add(p1); CP_Add(p2); CP_Add(p3); { ? може?вс?таки следуе?продолжать }
           {$ENDIF}
            exit;
          end
        end;

        { rus: 1. вычисляем положени?нового узла ?ещ?четырё?управляющих точе?}
        { end: 1. calculate situation of new one node and new four control poits of new two segment }
        {$IFDEF OPTIMIZE_CALLFUNCTIONS_MDL}
          p11.x := (p1.x + p0.x) div 2;          p11.y := (p1.y + p0.y) div 2;
          p21.x := (p2.x + p1.x) div 2;          p21.y := (p2.y + p1.y) div 2;

          p31.x := (p3.x + p2.x) div 2;          p31.y := (p3.y + p2.y) div 2;
          p22.x := (p11.x + p21.x) div 2;        p22.y := (p11.y + p21.y) div 2;
          p32.x := (p21.x + p31.x) div 2;        p32.y := (p21.y + p31.y) div 2;

          p33.x := (p22.x + p32.x) div 2;          p33.y := (p22.y + p32.y) div 2;
        {$ELSE}
          p11 := MiddleLine(p1, p0);      { 1я управляющ? точк?первог?нового сегмента }
          p21 := MiddleLine(p2, p1 );

          p31 := MiddleLine(p3 ,p2 );     { 2я управляющ? точк?второг?нового сегмента }
          p22 := MiddleLine(p11 , p21 );  { 2я управляющ? точк?первог?нового сегмента }
          p32 := MiddleLine(p21 , p31 );  { 1я управляющ? точк?второг?нового сегмента }
          { new node }
          p33 := MiddleLine(p22 , p32);   { эт?новы?узел, которы?дели?текущи?сегмен?на дв?новы?}
        {$ENDIF}

        { буде?разбиват?сегмен?до те?по?пока условн? длин?сегмента не снизит? до требуемо?}
        { will break until conditional length of segment is too large  }
        if SegmentConditionalLengthQ3N1Sup(p0, p11, p22, p33) > xMinSegmentLength then
           begin
           BreakSegment(p0, p11, p22, p33, xNeedClip)
           end
        else
          begin
          { новы?сегмен?}
          {$IFDEF OPTIMIZE_CALLFUNCTIONS_CP_ADD}
            CurvePoints[CurvePointsCount] := p11;
            CurvePoints[CurvePointsCount+1] := p22;
            CurvePoints[CurvePointsCount+2] := p33;
            inc(CurvePointsCount, 3);
          {$ELSE}
            CP_Add(p11);
            CP_Add(p22);
            CP_Add(p33);
          {$ENDIF}
          end;
        { p33 - новы?узел ; ут? p33 уж?добавлен }
        { p33 - new nodes - already added }
        if SegmentConditionalLengthQ3N1Sup(p33, p32, p31, p3) > xMinSegmentLength then
          begin
          BreakSegment(p33, p32, p31, p3, xNeedClip)
          end
        else
          begin
          {$IFDEF OPTIMIZE_CALLFUNCTIONS_CP_ADD}
            CurvePoints[CurvePointsCount] := p32;
            CurvePoints[CurvePointsCount+1] := p31;
            CurvePoints[CurvePointsCount+2] := p3;
            inc(CurvePointsCount, 3);
          {$ELSE}
            CP_Add(p32);
            CP_Add(p31);
            CP_Add(p3);
          {$ENDIF}
          end
  end;

begin
   CP_Clear;
   if Length(xPoints) = 0 then exit;

      i := 0;
      CP_Add(xPoints[0]);
      while i  <= Length(xPoints) - 4 do
        begin
        {для каждог?из сегменто?: }
        { (i) - узел1, (i+1) - 1я управляющ? точк? (i+2) - 2я управляющ? точк? (i+3) - cледующий узел   }
        BreakSegment(xPoints[i], xPoints[i+1], xPoints[i+2], xPoints[i+3], not IsNullRect(xClipRect));
        inc(i, 3);
        end;
end;

procedure gPolyBezier(Bitmap: TBitmap32;
                       const Points: TArrayOfFixedPoint;
                       const Color: TColor32;
                       const Options : tPolygonDrawOptions;
                       const Closed: Boolean;
                       const FillMode: TPolyFillMode = pfAlternate);

var
  PP : TArrayOfFixedPoint;
  i  : integer;
  PPCount : integer;
begin

  if (Length(Points) <= 1) or ((Length(Points) - 1) mod 3 <> 0) then exit;

  { TODO : на само?деле - неправильный алгоритм - поскольк?крив? може?попадать ?област?отображения, даже когд?вс?её
    точк?лежа?за пределам?}
  { eng: it's not truth algorithm for clipping, because even all points are out of clipping rect then is not means than
  any part of curve is invisible }
  if ClipPolyOutside(Points, GR32.FixedRect(rect(0, 0, Bitmap.Width, Bitmap.Height))) then exit;

  { rus: теперь строим точк?полинома получившей? кривой }
  BuildApproxCurve(Points,  Bezier3SegmentMinLengthInPixel shl 16, G32_Interface.FixedRect(rect(0, 0, Bitmap.Width, Bitmap.Height)));

  { rus: удаляем управляющие точк?}
  { eng: delete control points }
  PPCount := (CurvePointsCount - 1) div 3 + 1;
  SetLength(PP, PPCount);
  for i := 0 to PPCount - 1 do
    begin
    PP[i] := CurvePoints[3*i];
    end;

  gPolygon(Bitmap,
           PP,
           Color,
           Options,
           Closed,
           FillMode);
end;

procedure gPolyPolyBezier(Bitmap: TBitmap32;
                     const Points: TArrayOfArrayOfFixedPoint;
                     const Color: TColor32;
                     const Options : tPolygonDrawOptions;
                     const Closed: Boolean;
                     const FillMode: TPolyFillMode = pfAlternate);

var
  PP : TArrayOfArrayofFixedPoint;
  i, j  : integer;
  PPCount : integer;
begin
  SetLength(PP, Length(Points));

  for j := 0 to Length(Points) - 1 do
    begin
    if (Length(Points[j]) <= 1) or ((Length(Points[j]) - 1) mod 3 <> 0) then continue;

    { eng: clipping... }
    if ClipPolyOutside(Points[j], G32_Interface.FixedRect(rect(0, 0, Bitmap.Width, Bitmap.Height))) then exit;

    { rus: теперь строим точк?полинома получившей? кривой }
    { eng: aproximate... }
    BuildApproxCurve(Points[j],  Bezier3SegmentMinLengthInPixel shl 16, G32_Interface.FixedRect(rect(0, 0, Bitmap.Width, Bitmap.Height)));

    { rus: удаляем управляющие точк?}
    { eng: delete control points.. }
    PPCount := (CurvePointsCount - 1) div 3 + 1;
    SetLength(PP[j], PPCount);
    for i := 0 to PPCount - 1 do
      begin
      PP[j, i] := CurvePoints[3*i];
      end;
    end;

  {eng: display...}
  gPolyPolygon(Bitmap,
           PP,
           Color,
           Options,
           Closed,
           FillMode);
end;


procedure LoadRoundedPolygonAsCurve(const Points: TArrayOfFixedPoint;
                             const Radius : GR32.tFixed;
                             const Closed : boolean;
                             var yPP : TArrayOfFixedPoint);
var
  i : integer;
  N : integer;
begin
  N := Length(Points);

  SetLength(yPP, 0);

  if N <= 2 then
    begin
    if N <= 1 then exit;
    AFP_AddPoint2(yPP, Points[0], Points[0]);
    AFP_AddPoint2(yPP, Points[1], Points[1]);
    exit;
    end;

  if not Closed then  AFP_AddPoint2(yPP, Points[0], Points[0]);

  for i := 0 to N-3 do
      begin
      { вызывая ?первый ра? процедур?добавляет дв?точк?p21, но нужн?её вообще-то удалит?}
      LoadRoundsCurve(Points[i], Points[i+1], Points[i+2], Radius, yPP);
      end;

 if not Closed then
    AFP_AddPoint2(yPP, Points[N-1], Points[N-1])
 else
    begin
      LoadRoundsCurve(Points[N-2], Points[N-1], Points[0], Radius, yPP);
      if not PointsAreEqual(Points[N-1], Points[0]) then
        LoadRoundsCurve(Points[N-1], Points[0], Points[1], Radius, yPP, false);
    end;
end;


procedure gPolygonRounded(xBitmap: TBitmap32;
                     const xPoints: TArrayOfFixedPoint;
                     const xRadius : GR32.tFixed;
                     const xColor: TColor32;
                     const xOptions : tPolygonDrawOptions;
                     const xClosed: Boolean;
                     const xFillMode: TPolyFillMode = pfAlternate);
var
  vPP : TArrayOfFixedPoint;
begin
  LoadRoundedPolygonAsCurve(xPoints, xRadius, xClosed, vPP);

  gPolyBezier(xBitmap, vPP, xColor, xOptions, false, xFillMode);
  vPP := nil;
end;

procedure gPolyPolygonRounded(xBitmap: TBitmap32;
                     const xPoints: TArrayOfArrayOfFixedPoint;
                     const xRadius : GR32.tFixed;
                     const xColor: TColor32;
                     const xOptions : tPolygonDrawOptions;
                     const xClosed: Boolean;
                     const xFillMode: TPolyFillMode = pfAlternate);
var
  vPP : TArrayOfArrayOfFixedPoint;
  i   : integer;
  L   : integer;
begin
  L := Length(xPoints);
  SetLength(vPP, L);
  for i := 0 to  L - 1 do
    begin
    LoadRoundedPolygonAsCurve(xPoints[i], xRadius, xClosed, vPP[i]);
    end;
  gPolyPolyBezier(xBitmap, vPP, xColor, xOptions, xClosed, xFillMode);
  vPP := nil;
end;

{
  rus: GlyphPolygon -  список точе?аппроксимирующий  контур символ? пр?вызове функци?BuildGlyphPolyPolygon;
                 чтоб?выде?ть каждый ра?необходимуя па?ть сделан глобальным для моду? ?реализован?
                 интерфейсные фунции PathPoints
}

type
    TFXPArray = array[0..0] of TPOINTFX;
    PFXPArray = ^TFXPArray;

{$IFDEF OPTIMIZE_GLYPHPOLYGONE_STORAGE}
var
    GlyphPolygonPP : TArrayOfArrayOfFixedPoint;
    GPPointCount  : TArrayOfInteger; // sizes
    GP_Count : integer; // current sizes of GPPointCounts

    function GetGlyphPolygon : TArrayOfArrayOfFixedPoint;
    var
      i,j : integer;
    begin
      SetLength(result, GP_Count);
      for i := 0 to GP_Count - 1 do
        begin
        SetLength(result[i], GPPointCount[i]);
        for j := 0  to GPPointCount[i] - 1 do result[i, j] := GlyphPolygonPP[i, j];
        end;
    end;

    procedure GlyphPolygone_Clear;
    var i : integer;
    begin
      for i := 0 to GP_Count - 1 do GPPointCount[i]:= 0;
      GP_Count := 1;
    end;

    procedure GlyphPolygone_NewLine;
    begin
      inc(GP_Count);
      if GP_Count > Length(GPPointCount) then
        begin
        SetLength(GPPointCount,   GP_Count);
        SetLength(GlyphPolygonPP, GP_Count);
        end;
      GPPointCount[GP_Count - 1] := 0;
    end;

    procedure GlyphPolygone_Add(const xP : tFixedPoint);
    begin
      inc(GPPointCount[GP_Count - 1]);
      if GPPointCount[GP_Count - 1] > Length(GlyphPolygonPP[GP_Count - 1]) then
        SetLength(GlyphPolygonPP[GP_Count - 1], 2*GPPointCount[GP_Count - 1]);
      GlyphPolygonPP[GP_Count - 1, GPPointCount[GP_Count - 1] - 1] := xP;
    end;

    procedure GlyphPolygone_Add2(const xP1, xP2 : tFixedPoint);
    begin
      inc(GPPointCount[GP_Count - 1], 2);
      if GPPointCount[GP_Count - 1] > Length(GlyphPolygonPP[GP_Count - 1]) then
        SetLength(GlyphPolygonPP[GP_Count - 1], 2*GPPointCount[GP_Count - 1]);
      GlyphPolygonPP[GP_Count - 1, GPPointCount[GP_Count - 1] - 2] := xP1;
      GlyphPolygonPP[GP_Count - 1, GPPointCount[GP_Count - 1] - 1] := xP2;
    end;
{$ELSE}
var
  GlyphPolygon : TPolygon32; { PointsContainer }

{$ENDIF}

{ rus : загрузка аппроксимированных контуров символ?из буфера }
procedure BuildGlyphPolygon(xBufPtr :  PTTPolygonHeader;     {  rus : указател?на буфе? которы?содержит информацию ?начертании символ?}
                            const xBufSize : integer;              {  rus : размер буфера }
                            const xMinSegmentLength : GR32.tFixed; { rus :указывае?минимальну?условн? кривизна (ил?длин? сегмента до которого нужн?разбиват?}
                            const xLeft, yTop : GR32.tFixed;       { rus :для указан? положения символ? инач?мы не сможет определить област?отсечения }
                            const xGM : TGLYPHMETRICS;             { rus :для указан? размер??смещен?символ?относительно базово?лини????}
                            const xCliptRect : GR32.tFixedRect);   { rus :указывае?прямоугольник отсечения }


var
   pc : PTTPolyCurve;
   ps, p1, p2 : TFixedPoint;
   ofs, ofs2, pcSize : LongInt;
   done : boolean;
   i : LongInt;
   pfxA, pfxB, pfXC : TFixedPoint;
   lpAPFX : PFXPArray;
   polyN  : LongInt;
   pcType : LongInt;


  { rus: разбивае?сегмен?p0, p1, p2  на необходимо?количество ра? заполняя список СurvePoints[CurvePointsCount]
    функция рекурсивная
    условия: x0 - уж?добавленый узел   (!)
             p1 - управляющие точк? которы?буду?добавлен?
             p2 - узел, которы??любо?случае буде?добавлен

   }

  procedure BreakSegment(const p0, p1, p2 : tFixedPoint);
  var
    p21, p3, p22 : tFixedPoint;
  begin

       { rus: если сегмен?вырожденны?ил?мы достигли предел?па?ти, то заканчивае?}
       if PointsAreEqual(p0, p1) or PointsAreEqual(p1, p2) then
         begin
         { rus: разбиват?не нужн?}
         {$IFDEF OPTIMIZE_GLYPHPOLYGONE_STORAGE}
           GlyphPolygone_Add2(p1, p2);
           //GlyphPolygone_Add(p1); GlyphPolygone_Add(p2);
         {$ELSE}
           GlyphPolygon.Add(p1); GlyphPolygon.Add(p2);
         {$ENDIF}
         exit;
         end;

      if ClipRectOutside(p0, p1, p2, xCliptRect) then
        begin
         { rus: разбиват?не нужн?}
         {$IFDEF OPTIMIZE_GLYPHPOLYGONE_STORAGE}
           //GlyphPolygone_Add(p1); GlyphPolygone_Add(p2);
           GlyphPolygone_Add2(p1, p2);
         {$ELSE}
           GlyphPolygon.Add(p1); GlyphPolygon.Add(p2);
         {$ENDIF}
         exit;
        end;

        {$IFDEF OPTIMIZE_CALLFUNCTIONS_MDL}
          p21.x := (p1.x + p0.x) div 2;          p21.y := (p1.y + p0.y) div 2;
          p22.x := (p2.x + p1.x) div 2;          p22.y := (p2.y + p1.y) div 2;
          p3.x := (p21.x + p22.x) div 2;         p3.y := (p21.y + p22.y) div 2;
        {$ELSE}
          p21 := MiddleLine(p1, p0); {rus:  новая управляющ? точк?перового нового сегмента p0-p21-p3}
          p22 := MiddleLine(p2, p1); { rus: новая управляющ? точк?второг?нового сегмента p3 - p22 - p2}
          p3  := MiddleLine(p21, p22);
        {$ENDIF}

        { rus: буде?разбиват?сегмен?до те?по?пока условн? длин?(ил?кривизна) сегмента не снизит? до требуемо?}
        if SegmentConditionalLengthQ2N1Sup(p0, p21, p3) > xMinSegmentLength then
           begin
           BreakSegment(p0, p21, p3)
           end
        else
          begin
          { rus: новы?сегмен?}
          {$IFDEF OPTIMIZE_GLYPHPOLYGONE_STORAGE}
           //GlyphPolygone_Add(p21); GlyphPolygone_Add(p3);
           GlyphPolygone_Add2(p21, p3);
         {$ELSE}
           GlyphPolygon.Add(p21); GlyphPolygon.Add(p3);
         {$ENDIF}
          end;
        { rus: p33 - новы?узел ; ут? p33 уж?добавлен }
        if SegmentConditionalLengthQ2N1Sup(p3, p22,  p2) > xMinSegmentLength then
          begin
          BreakSegment(p3, p22, p2)
          end
        else
          begin
         {$IFDEF OPTIMIZE_GLYPHPOLYGONE_STORAGE}
           //GlyphPolygone_Add(p22); GlyphPolygone_Add(p2);
           GlyphPolygone_Add2(p22, p2);
         {$ELSE}
           GlyphPolygon.Add(p22); GlyphPolygon.Add(p2);
         {$ENDIF}
          end
  end;

  function xWinFixToG32(const x : _FIXED) : GR32.TFixed;
  begin
     result := X.value*$10000 + x.fract + xLeft;
  end;

  function yWinFixToG32(const y : _FIXED) : GR32.TFixed;
  begin
   result := + y.value* $10000 + y.fract + yTop;
  end;

begin
  {$IFDEF OPTIMIZE_GLYPHPOLYGONE_STORAGE}
     GlyphPolygone_Clear;
  {$ELSE}
     GlyphPolygon.Clear;
  {$ENDIF}
     done := false;
     ofs := 0;
     polyN := 0;

     while not Done do
      begin
           ps.X := xWinFixToG32( xBufPtr^.pfxStart.X );
           ps.Y := yWinFixToG32( xBufPtr^.pfxStart.Y );
           pcSize := xBufPtr^.cb - SizeOf(TTTPOLYGONHEADER);          // rus: размер, которы?занимает список кривых/полиномо?
           pChar(pc) := pChar(xBufPtr) + SizeOf(TTTPOLYGONHEADER);    // rus: pc -  указтель на текущу?структур?TTPOLYCURVE
           ofs2 := 0;                                                 // rus: смещение относительно начала списка кривых/полиномо?

           p2 := ps;
           if polyN <> 0 then
             begin
              {$IFDEF OPTIMIZE_GLYPHPOLYGONE_STORAGE}
                 GlyphPolygone_NewLine;
              {$ELSE}
                 GlyphPolygon.NewLine;
              {$ENDIF}

             end;
              {$IFDEF OPTIMIZE_GLYPHPOLYGONE_STORAGE}
                 GlyphPolygone_Add(p2);
              {$ELSE}
                 GlyphPolygon.Add(p2);
              {$ENDIF}

           { rus: пока не прочитал?весь буфе?}
           while not Done and (ofs2 < pcSize) do
            begin
            {rus:  дале?следуе?структур?TTPOLYCURVE:
              wType word - ти?(сплайн/ломанн?)
              cpfx  word - количество точе?
              apfx  - массив точе?
            }
                 pcType := pc^.wType;
                 case pcType of
                   TT_PRIM_LINE:
                      begin
                           lpAPFX := @pc^.apfx[0];
                           for i := 0 to pc^.cpfx-1 do
                            begin
                                 p1 := p2;
                                 p2.X := xWinFixToG32(lpAPFX^[i].X);
                                 p2.Y := yWinFixToG32(lpAPFX^[i].Y);
                                 if not PointsAreEqual( p1, p2 )  then
                                 {$IFDEF OPTIMIZE_GLYPHPOLYGONE_STORAGE}
                                   GlyphPolygone_Add(p2);
                                {$ELSE}
                                   GlyphPolygon.Add(p2);
                                {$ENDIF}
                            end;
                      end;
                    TT_PRIM_QSPLINE:
                      begin
                           lpAPFX := @pc^.apfx[0];
                           pfxA := p2;
                           for i := 0 to pc^.cpfx-2 do
                            begin
                                 pfxB.X := xWinFixToG32(lpAPFX^[i].X);
                                 pfxB.Y := yWinFixToG32(lpAPFX^[i].Y);
                                 if i < pc^.cpfx-2 then
                                  begin
                                       pfxC.X := xWinFixToG32(lpAPFX^[i+1].X);
                                       pfxC.Y := yWinFixToG32(lpAPFX^[i+1].Y);
                                       pfxC.X := (pfxC.X + pfxB.X) div 2;
                                       pfxC.Y := (pfxC.Y + pfxB.Y) div 2;
                                  end else
                                   begin
                                        pfxC.X := xWinFixToG32(lpAPFX^[i+1].X);
                                        pfxC.Y := yWinFixToG32(lpAPFX^[i+1].Y);
                                   end;
                                 BreakSegment(pfxA, pfxB, pfxC);
                                 pfxA := pfxC;
                            end;
                           p2 := pfxC;
                      end;
                  end;
                 ofs2 := ofs2 + SizeOf(TTTPOLYCURVE) + (pc^.cpfx-1)*SizeOf(TPOINTFX);
                 pChar(pc) := pChar(pc) + SizeOf(TTTPOLYCURVE) + (pc^.cpfx-1)*SizeOf(TPOINTFX);
            end;
           if not Done then
            begin
                 p1 := p2;
                 p2 := ps;
                 ofs := ofs + pcSize + SizeOf(TTTPOLYGONHEADER);
                 Done := (ofs >= (xBufSize - SizeOf(TTTPolygonHeader))) ;
                 if (not PointsAreEqual( p1, p2 )) then
                  {$IFDEF OPTIMIZE_GLYPHPOLYGONE_STORAGE}
                     GlyphPolygone_Add(p2);
                  {$ELSE}
                     GlyphPolygon.Add(p2);
                  {$ENDIF}
                 pChar(xBufPtr) := pChar(pc);
                 inc( polyN );
        end;
      end;
   { TODO : удалит?управляющие точк?}
   { eng: TODO : remove control points }
end;

{ TBitmap32Ex }

constructor TBitmap32Ex.Create;
begin
  inherited Create;

  fCanvas := tCanvas.Create;
  fCanvas.Handle := Self.Handle;

  fDrawOrign.x := 0; fDrawOrign.y := 0;

  fFontMat2 := VertFlip_mat2;
  fLastSumLength := 0;

  Font.Size := 24;
  Font.Name := 'Tahoma';
  Font.Color := clBlack;
  Font.Style := [fsBold];
  UpdateFont;
end;

destructor TBitmap32Ex.Destroy;
begin
  fCanvas.Free;
  inherited Destroy;
end;

{ rus: рисует один символ шрифта установленог??Font ?указанно?позици? }
procedure TBitmap32Ex.DrawGlyph(const xCharCode : longword;
                                const xLeft, yTop: GR32.tFixed;
                                const xColor : tColor32;
                                const xOptions : tPolygonDrawOptions);
var
   Res, bufSize : LongInt;
   bufPtr, buf  : PTTPolygonHeader;
   dc : hDC;
   gm : TGLYPHMETRICS; // rus: информац? ?расположении букв?

   fUnicode : boolean; // rus: признвак уникодовской букв?
begin
     { rus: --- I. получить glyph-bufer  символ??помощь?GetGlyphOutline для шрифта fFont }
     UpdateFont;  { устанавливае??текущи?контекст текущи шриф?}
     dc := Self.handle; { для удобства ?исключен? путанниц?}

     FUNICODE := false;

     if not FUNICODE then  bufSize := GetGlyphOutline( dc ,xCharCode,GGO_NATIVE,gm,0,nil,fFontMat2 )
                     else  bufSize := GetGlyphOutlineW( dc,xCharCode,GGO_NATIVE,gm,0,nil,fFontMat2 ) ;
     if (bufSize = GDI_ERROR) or (bufSize = 0) then exit;


     bufPtr := AllocMem( bufSize );
     buf := bufPtr;
     if not FUNICODE then  Res := GetGlyphOutline( dc, xCharCode,GGO_NATIVE,gm,bufSize, pchar(buf),fFontMat2 )
                     else Res := GetGlyphOutlineW( dc, xCharCode,GGO_NATIVE,gm,bufSize, pchar(buf),fFontMat2 );

     if (res = GDI_ERROR) or (buf^.dwType <> TT_POLYGON_TYPE) then
      begin
           FreeMem( bufPtr );
           Exit;
      end;

    BuildGlyphPolygon(bufPtr, { указател?на буфе? которы?содержит информацию ?начертании символ?}
                          bufSize, { размер буфера }
                          Bezier2SegmentMinLengthInPixel  shl 16,   { указывае?минимальну?условн? кривизна (ил?длин? сегмента до которого нужн?разбиват?}
                          xLeft, yTop,          { для указан? положения символ? инач?мы не сможет определить област?отсечения }
                          gm,                             { для указан? размер??смещен?символ?относительно базово?лини????}
                          G32_Interface.FixedRect(fDrawOrign.x, fDrawOrign.y, GR32.Fixed(Self.Width) + fDrawOrign.x, GR32.Fixed(Self.Height) + fDrawOrign.y));   { указывае?прямоугольник отсечения }

    FreeMem( bufPtr );

   {rus:  --- III. отобразить контур ?указанно?позици? }
   {$IFDEF OPTIMIZE_GLYPHPOLYGONE_STORAGE}
      gPolyPolygon(Self, GetGlyphPolygon, xColor, xOptions, true);
   {$ELSE}
      gPolyPolygon(Self, GlyphPolygon.Points, xColor, xOptions, true);
   {$ENDIF}


end;

procedure TBitmap32Ex.RenderTextEx(const xLeft, yBottom: GR32.tFixed;
                                   const xText: string;
                                   const xColor : tColor32;
                                   const xOptions : tPolygonDrawOptions);
var
   vShift : GR32.tFixedPoint;

   Res, bufSize : LongInt;
   bufPtr, buf  : PTTPolygonHeader;
   gm1, gm : TGLYPHMETRICS; // rus: информац? ?расположении букв?

   fUnicode : boolean; // rus: признвак уникодовской букв?
   i : integer;
   vCharCode : longword;
   vQuality : integer;
   vTextLength : integer;

   BufCap : integer;
begin
  {  --- rus: I. получить glyph-bufer  символ??помощь?GetGlyphOutline для шрифта fFont }

     SelectObject(Handle, Font.Handle);
     { TODO : rus: следуе?проверит?являет? ли  xChar^ Unicode'ой буквой,
     ?помощь?GetFontUnicodeRanges  ?установить  FUNICODE }

     vShift := FixedPoint(0, 0);
     vTextLength := length(xText);

     if vTextLength > 0 then try
       BufCap := 1024;
       GetMem(BufPtr, BufCap);
       for i := 1 to  vTextLength do begin
         vCharCode := ord(xText[i]);

         FUNICODE := false;
         {Alexander Muylaert : Strange thing here, has it any use???}
         if not FUNICODE then  bufSize := GetGlyphOutline( Handle ,vCharCode, GGO_NATIVE,gm1,0,nil,fFontMat2 {VertFlip_mat2})
                         else  bufSize := GetGlyphOutlineW(Handle,vCharCode, GGO_NATIVE,gm1,0,nil,fFontMat2 {VertFlip_mat2}) ;
         if (bufSize = 0) then begin
          vShift.x := vShift.x + GR32.Fixed(gm1.gmCellIncX);
          vShift.y := vShift.y - GR32.Fixed(gm1.gmCellIncY);
          continue;
         end;

          if BufSize > BufCap then begin
            ReAllocMem(BufPtr, BufSize);
            BufCap := BufSize;
          end;
          buf := bufPtr;
          if not FUNICODE then Res := GetGlyphOutline( Handle, vCharCode,GGO_NATIVE,gm,bufSize, pchar(buf),fFontMat2{VertFlip_mat2} )
                           else Res := GetGlyphOutlineW( Handle, vCharCode,GGO_NATIVE,gm,bufSize, pchar(buf),fFontMat2{VertFlip_mat2} );
          if (res = GDI_ERROR) or (buf^.dwType <> TT_POLYGON_TYPE) then continue;

         { --- rus: II. cформироват? tArrayOfArrayOfFixed,  содержащий
               список ломанных, аппроксимирующий контур }
          vQuality := (Bezier2SegmentMinLengthInPixel  shl 16);

          BuildGlyphPolygon(bufPtr, { указател?на буфе? которы?содержит информацию ?начертании символ?}
                                bufSize, { размер буфера }
                                vQuality,   { указывае?минимальну?условн? кривизна (ил?длин? сегмента до которого нужн?разбиват?}
                                xLeft + vShift.x, yBottom +  vShift.y, { для указан? положения символ? инач?мы не сможем определить област?отсечения }
                                gm1, { для указан? размер??смещен?символ?относительно базово?лини????}
                                G32_Interface.FixedRect(fDrawOrign.x,
                                          fDrawOrign.y,
                                          GR32.Fixed(Self.Width) + fDrawOrign.x,
                                          GR32.Fixed(Self.Height) + fDrawOrign.y));   { указывае?прямоугольник отсечения }

         vShift.x := vShift.x + GR32.Fixed(gm1.gmCellIncX*FittedText_SpacingFactor);
         vShift.y := vShift.y - GR32.Fixed(gm1.gmCellIncY);

        { --- rus: III. отобразить контур ?указанно?позици? }
       {$IFDEF OPTIMIZE_GLYPHPOLYGONE_STORAGE}
          PolyPolygon(GetGlyphPolygon, xColor, xOptions, true);
       {$ELSE}
          PolyPolygon(GlyphPolygon.Points, xColor, xOptions, true);
       {$ENDIF}

       end;
    finally
      FreeMem(BufPtr);
    end;
end;


{возвращает длин?кривой}
function gGetCurveLength(const xCurve: tArrayOfFixedPoint) : GR32.tFixed;
var
  vSegLength : GR32.tFixed;
  p1, p2, p3, p4 : tFixedPoint;
  iSeg : integer;
begin
  if (Length(xCurve) <= 1) or ((Length(xCurve) - 1) mod 3 <> 0)  then
      begin
      raise exception.CreateFmt('G32_Interface.GetCurveLength error : Invalidate qubic curve segment points count [%d]; must be four ', [Length(xCurve)]);
      exit;
      end;


  BuildApproxCurve(xCurve, Bezier3SegmentMinLengthInPixel shl 16,
                   G32_Interface.FixedRect(0, 0, 0, 0));
  {ут? Крив? находится ?массив? CurvePoints : array of TFixedPoint количество - CurvePointsCount, меньше ил?равн?размер?самого массива}

  result := 0;
  {2. оценивае?сегмен??нутр?которого находится точк?}
  for iSeg := 0 to (CurvePointsCount - 1) div 3 - 1 do
    begin
    { точк?сегмента : }
    p1 := CurvePoints[3*iSeg];
    p2 := CurvePoints[3*iSeg + 1];
    p3 := CurvePoints[3*iSeg + 2];
    p4 := CurvePoints[3*iSeg + 3];
    vSegLength := SegmentConditionalLengthQ3N2(p1, p2, p3, p4);
    inc(result, vSegLength);
    end;

end;


procedure gGetPointPositionValuationAtSegment(const p1, p2 : GR32.tFixedPoint;
                                             const xLength : GR32.tFixed;
                                             out xPathX, xPathY: GR32.tFixed;
                                             out xAngle : double);
var
  dl : double;
begin
  if not PointsAreEqual(p1, p2) then
    begin
    dL := xLength/Distance(p1, p2);
    { interpolation : }
    xPathX := p1.x + round(dl*(p2.x - p1.x));
    xPathY := p1.y + round(dl*(p2.y - p1.y));

    if (p2.x = p1.x) then
      begin
      if (p2.y  < p1.y) then xAngle := PiDiv4 else xAngle := - PiDiv4;
      end
    else
      begin
      xAngle := ArcTan2(p2.y - p1.y, p2.x - p1.x);
      end;
    end
  else
    begin
    xPathX := p1.x;
    xPathY := p1.y;
    xAngle := 0;
    end;
  { TODO : угол касательно?можн?вычислит?точн?разбив отрезк?соединяющие узлы ?управляющие точк?попола?}
end;


function gGetPointAtCurveEx(const xStartSegmentInd : integer;
                            const xStartLength : GR32.tFixed;
                            const xCurve: tArrayOfFixedPoint;
                            const xLength : GR32.tFixed;
                            out xPathX, xPathY : GR32.tFixed; out xAngle : double;
                            const xApproxNeed : boolean = true
                            ):integer;

var
 iSeg : integer;
 p1, p2, p3, p4 : tFixedPoint;
 vSumLength : GR32.tFixed; { cуммарн? длин?сегмента }
 vSegLength : GR32.tFixed; { длин?cегмент?}
begin

  if (Length(xCurve) <= 1) or ((Length(xCurve) - 1) mod 3 <> 0)  then
    begin
    raise exception.CreateFmt('G32_Interface.GetPointAtCurve error : Invalidate qubic curve segment points count [%d]; must be four ', [Length(xCurve)]);
    exit;
    end;

  if xApproxNeed then
  {1. аппроксимируем кривую }
  {eng: 1.approx curve }
  BuildApproxCurve(xCurve, Bezier3SegmentMinLengthInPixel_2 shl 16,
                   G32_Interface.FixedRect(0, 0, 0, 0));

  {ут? Крив? находится ?массив? CurvePoints : array of TFixedPoint количество - CurvePointsCount, меньше ил?равн?размер?самого массива}
  {conditional: Curve is placed in CurvePoints array }

  if xStartSegmentInd <> 0 then vSumLength := xStartLength
                        else
                          begin
                          vSumLength := 0;
                          end;
  result := xStartSegmentInd;
  iSeg := xStartSegmentInd;
  while iSeg < (CurvePointsCount - 1) div 3 do
  {2. оценивае?сегмен?внутри которого находится точк?}
  {2. find segment which point belong to}
    begin
    { точк?сегмента : }
    p1 := CurvePoints[3*iSeg];
    p2 := CurvePoints[3*iSeg + 1];
    p3 := CurvePoints[3*iSeg + 2];
    p4 := CurvePoints[3*iSeg + 3];
    vSegLength := SegmentConditionalLengthQ3N2(p1, p2, p3, p4);
    if  (vSumLength <= xLength) and (vSumLength + vSegLength >= xLength ) then
      begin
      break;
      end;
    inc(vSumLength, vSegLength);
    inc(ISeg);
    end;

  {ут? iSeg - указывае?на начало сегмента (p1, p2, p3, p4) }

  {3. find point situation inside segment }
  gGetPointPositionValuationAtSegment(p1, p4, xLength - vSumLength, xPathX, xPathY, xAngle);

  result := iSeg;
end;

procedure gGetPointAtCurve(const xCurve: tArrayOfFixedPoint;
                          const xLength : GR32.tFixed;
                          out xPathX, xPathY : GR32.tFixed; out xAngle : double
                          );
begin
  gGetPointAtCurveEx(0, 0, xCurve, xLength, xPathX, xPathY, xAngle, true);
end;


{возвразает положени?точк?на расстояни?xLength вдол?кривой, ?угол наклон?касательно?}
{прим.  чтоб?избежать аппроксимаци одно??то?же кривой, можн?её заране?аппроксимировать вызвав функци?BuildApproxCurve
  возвращает индекс сегмента, ?которо?лежи?точк?для уж?аппроксимированной кривой
}
function TBitmap32Ex.GetPointAtCurve( const xStartSegmentInd : integer;
                                      const xCurve: tArrayOfFixedPoint;
                                      const  xLength : GR32.tFixed;
                                      out xPathX, xPathY : GR32.tFixed;
                                      out xAngle : double;
                                      const xApproxNeed : boolean = true
                                        ) : integer;

var
 iSeg : integer;
 p1, p2, p3, p4 : tFixedPoint;
 vSumLength : GR32.tFixed; { cуммарн? длин?сегмента }
 vSegLength : GR32.tFixed; { длин?cегмент?}
begin

  if (Length(xCurve) <= 1) or ((Length(xCurve) - 1) mod 3 <> 0)  then
    begin
    raise exception.CreateFmt('G32_Interface.GetPointAtCurve error : Invalidate qubic curve segment points count [%d]; must be four ', [Length(xCurve)]);
    exit;
    end;

  if xApproxNeed then
  {1. аппроксимируем кривую }
  {eng: 1.approx curve }
  BuildApproxCurve(xCurve, Bezier3SegmentMinLengthInPixel_2 shl 16,
                   G32_Interface.FixedRect(fDrawOrign.x, fDrawOrign.y, GR32.Fixed(Self.Width) + fDrawOrign.x, GR32.Fixed(Self.Height) + fDrawOrign.y));

  {ут? Крив? находится ?массив? CurvePoints : array of TFixedPoint количество - CurvePointsCount, меньше ил?равн?размер?самого массива}
  {conditional: Curve is placed in CurvePoints array }

  if xStartSegmentInd <> 0 then vSumLength := fLastSumLength
                        else
                          begin
                          vSumLength := 0;
                          fLastSumLength := 0;
                          end;
  result := xStartSegmentInd;
  iSeg := xStartSegmentInd;
  while iSeg < (CurvePointsCount - 1) div 3 do
  {2. оценивае?сегмен?внутри которого находится точк?}
  {2. find segment which point belong to}
    begin
    { точк?сегмента : }
    p1 := CurvePoints[3*iSeg];
    p2 := CurvePoints[3*iSeg + 1];
    p3 := CurvePoints[3*iSeg + 2];
    p4 := CurvePoints[3*iSeg + 3];
    vSegLength := SegmentConditionalLengthQ3N2(p1, p2, p3, p4);
    if  (vSumLength <= xLength) and (vSumLength + vSegLength >= xLength ) then
      begin
      break;
      end;
    inc(vSumLength, vSegLength);
    inc(ISeg);
    end;

  {ут? iSeg - указывае?на начало сегмента (p1, p2, p3, p4) }
  {3. оценивае?положени?точк?внутри сегмента:}
  {3. find point situation inside segment }

  gGetPointPositionValuationAtSegment(p1, p4, xLength - vSumLength, xPathX, xPathY, xAngle);

  result := iSeg;
  fLastSumLength := vSumLength;
end;

{ прорисовка текста вдол?кривой xPath}
procedure TBitmap32Ex.RenderFittedText(const xText : string;
                                       const xColor : tColor32;
                                       const xOptions : tPolygonDrawOptions;
                                       const xPath : tArrayOfFixedPoint);
var
   Res, bufSize : LongInt;
   bufPtr, buf  : PTTPolygonHeader;
   gm1, gm : TGLYPHMETRICS; // rus: информац? ?расположении букв?

   fUnicode : boolean; // rus: призна?уникодовской букв?
   i : integer;
   vCharCode : longword;

   PathX, PathY : GR32.tFixed; { положени?точк?}
   vTangent : double; { угол касательно?}

   vFontMat2 : tMat2;

   vQuality  : integer; { качество аппроксимаци?- минимальная условн? длин?сегмента }
   vCurveLength : GR32.tFixed;

   vLastSegment : integer;
   vLengthShift : GR32.tFixed;

   vApproxedPath : tArrayOfFixedPoint; { апроксимированная крив? }

   procedure GrowLengthShift(const dX , dY : GR32.tFixed);
   begin
     { dL^2  = dx^2 + dy^2}
     vLengthShift := vLengthShift + GR32.Fixed(sqrt(sqr(div65536*dX) + sqr(div65536*dy))*FittedText_SpacingFactor);
   end;
begin
  {подразумевае? чт?xPath - один сегмен?}
  if (Length(xPath) <= 1) or ((Length(xPath) - 1) mod 3 <> 0) then
  begin
    raise exception.CreateFmt('G32_Interface.Render fitted text error : Invalidate qubic curve segment points count [%d]; must be four ', [Length(xPath)]);
    exit;
  end;

  if ClipPolyOutside(xPath, G32_Interface.FixedRect(fDrawOrign.x, fDrawOrign.y, GR32.Fixed(Self.Width) + fDrawOrign.x, GR32.Fixed(Self.Height)+ fDrawOrign.y)) then exit;

     vCurveLength := gGetCurveLength(xPath);

 {  --- rus: I. получить glyph-bufer  символ??помощь?GetGlyphOutline для шрифта fFont }
     UpdateFont;  { устанавливае??текущи?контекст текущи шриф?}
     SelectObject(Handle, Font.Handle);

     { TODO : rus: следуе?проверит?являет? ли  xChar^ Unicode'ой буквой, ?помощь?GetFontUnicodeRanges
              ?установить  FUNICODE }
     { preprocess approximation: }
     BuildApproxCurve(xPath, Bezier3SegmentMinLengthInPixel_2 shl 16, G32_Interface.FixedRect(0, 0, 0, 0));
     SetLength(vApproxedPath, CurvePointsCount);
     for i := 0 to High(vApproxedPath) do vApproxedPath[i] := CurvePoints[i];

     vLengthShift := 0;
     vLastSegment := 0;
     for i := 1 to length(xText) do
       begin
       vCharCode := ord(xText[i]);


       FUNICODE := false;

       { rus: получаем ?gm1  метрик?текста вдол?прямо?}
       { eng: set to gm1 glyph metrics along line using  fFontMat2}
       if not FUNICODE then  bufSize := GetGlyphOutline( Handle ,vCharCode,GGO_NATIVE,gm1,0,nil, fFontMat2)
                       else  bufSize := GetGlyphOutlineW( Handle,vCharCode,GGO_NATIVE,gm1,0,nil, fFontMat2);
       if (bufSize = 0) then
        begin
        GrowLengthShift(GR32.Fixed(gm1.gmCellIncX), GR32.Fixed(gm1.gmCellIncY));
        continue;
        end;

       { если текс?уж? выглядывает за лини? то не рисуем ег?}
       if (vLengthShift < 0) or (vCurveLength < vLengthShift) then    break;

       { чтоб?не аппроксимировать каждый ра? подставляем уж?аппроксиммированну?СurvePoints }
       vLastSegment := GetPointAtCurve(vLastSegment, vApproxedPath, vLengthShift, PathX, PathY, vTangent, false);

       { rus:теперь следуе?довернут?матриц?fFontMat2, на угол касательно??кривой }
       { либо просто построит? нову?матриц?vFontMat2 }

       { eng: now combine font transformation with rotation accroding the path tangent }

       vFontMat2 := GetRotatedMat2(vTangent);
       vFontMat2 := MultMat2(fFontMat2, vFontMat2);

       { for correct using GetGlyphOutline  call this function with new vFontMat2
         ( in other case GetGlyphOutline return -1 when font small)
       }
       if not FUNICODE then  bufSize := GetGlyphOutline( Handle, vCharCode,GGO_NATIVE,gm,0,nil, vFontMat2)
                       else  bufSize := GetGlyphOutlineW( Handle, vCharCode,GGO_NATIVE,gm,0,nil, vFontMat2);
       if (bufSize = 0) then
        begin
        GrowLengthShift(GR32.Fixed(gm1.gmCellIncX), GR32.Fixed(gm1.gmCellIncY));
        continue;
        end;


       if abs(DetMat2(vFontMat2)) > 0.01 then { на всяки?случай }
         begin
           try
             bufPtr := AllocMem( bufSize );
             buf := bufPtr;
             if not FUNICODE then Res := GetGlyphOutline( Handle, vCharCode,GGO_NATIVE,gm,bufSize, pchar(buf),vFontMat2 )
                             else Res := GetGlyphOutlineW( Handle, vCharCode,GGO_NATIVE,gm,bufSize, pchar(buf),vFontMat2 );

           { опреде?ем траекторию }
           { eng: define thraectory ; 1.1 - coeff. control spacing }
           GrowLengthShift(GR32.Fixed(gm1.gmCellIncX), GR32.Fixed(gm1.gmCellIncY));

             if (res = GDI_ERROR) (*or (res <> bufSize) or (buf^.dwType <> TT_POLYGON_TYPE) *)then
              begin
                FreeMem(bufPtr);
                BufPtr := nil; {!!! }
                continue;
              end;

            vQuality := (Bezier2SegmentMinLengthInPixel  shl 16);
            { --- rus: II. cформироват? tArrayOfArrayOfFixed,  содержащий список ломанных, аппроксимирующий контур }

            BuildGlyphPolygon(bufPtr, { указател?на буфе? которы?содержит информацию ?начертании символ?}
                                  res, { размер буфера }
                                  vQuality,   { указывае?минимальну?условн? кривизна (ил?длин? сегмента до которого нужн?разбиват?}
                                  PathX, PathY,  { для указан? положения символ? инач?мы не сможем определить област?отсечения }
                                  gm,            { для указан? размер??смещен?символ?относительно базово?лини????}
                                  G32_Interface.FixedRect(fDrawOrign.x, fDrawOrign.y, GR32.Fixed(Self.Width) + fDrawOrign.x, GR32.Fixed(Self.Height) + fDrawOrign.y));   { указывае?прямоугольник отсечения }
          { --- rus: III. отобразить контур ?указанно?позици? }
          { eng: display glyph}
          {$IFDEF OPTIMIZE_GLYPHPOLYGONE_STORAGE}
              PolyPolygon(GetGlyphPolygon, xColor, xOptions, true);
           {$ELSE}
              PolyPolygon(GlyphPolygon.Points, xColor, xOptions, true);
           {$ENDIF}
         finally
           FreeMem( bufPtr);
           bufPtr := nil;
         end;
       end;
     end;

  vApproxedPath := nil;
end;

{ установк?матриц?преобразован? символов шритва (таки?образо?можн?управлять наклоном ?масштабированием шрифта)  }
function TBitmap32Ex.SelectFontMat2(const xValue : tMat2) : tMat2;
begin
  result := fFontMat2;
  fFontMat2 := xValue;
end;

function TBitmap32Ex.SelectFontTransform(const xValue : tFloatMatrix) : tFloatMatrix; { столбе?свободны?членов игнориуется }
begin
  result[2,0] := fFont_e31;
  result[2,1] := fFont_e32;

  SelectFontMat2(FloatMatrixToMat2(xValue));

  fFont_e31 := xValue[2,0];
  fFont_e31 := xValue[2,1];
end;

function TBitmap32Ex.GetCanvas: tCanvas;
begin
  fCanvas.Handle := Self.Handle;  {!! обязательно следуе?обновить, поскольк?значение ме?ет? }
  result := fCanvas;
end;

procedure TBitmap32Ex.PolyBezier(const Points: TArrayOfFixedPoint;
  const Color: TColor32; const Options: tPolygonDrawOptions; const Closed: Boolean;
  const FillMode: TPolyFillMode);
var
  i : integer;
begin
  for i := 0 to Length(Points) - 1 do
    begin
    Points[i].x := Points[i].x - fDrawOrign.x;
    Points[i].y := Points[i].y - fDrawOrign.y;
    end;

  gPolyBezier(Self, Points, Color, Options, Closed, FillMode);
end;

{ rus: рисовани?эллипс?}
procedure TBitmap32Ex.Ellipse(const xRect : tFixedRect;
                              const xColor: tColor32;
                              const xOptions : tPolygonDrawOptions);
begin
  gEllipse(Self, xRect, xColor, xOptions);
end;


procedure TBitmap32Ex.Arc(const xCenter : tFixedPoint;
                          const xR : GR32.tFixed;
                          const xStartAngle, xEndAngle : double;
                          const xColor : tColor32;
                          const xOptions : tPolygonDrawOptions = pdoFloat);
begin
  gArc(Self, xCenter, xR, xStartAngle, xEndAngle, xColor, xOptions);
end;

procedure TBitmap32Ex.ArcElliptic(const xCenter : tFixedPoint;
                                  const  xA, xB : GR32.tFixed;
                                  const xStartAngle, xEndAngle : double;
                                  const xColor : tColor32;
                                  const xOptions : tPolygonDrawOptions = pdoFloat);
begin
  gArcElliptic(Self, xCenter, xA, xB, xStartAngle, xEndAngle, xColor, xOptions);
end;

{ drawing rotated ellipse; angle value must be in radians }
procedure TBitmap32Ex.EllipseRotated(const xCenter : tFixedPoint;
                                     const  xA, xB : GR32.tFixed;
                                     const xAngle : double;
                                     const xColor : tColor32;
                                     const xOptions : tPolygonDrawOptions = pdoFloat);
begin
  gEllipseRotated(Self, xCenter, xA, xB, xAngle, xColor, xOptions);
end;

procedure TBitmap32Ex.Pie(const xCenter : tFixedPoint;
                          const xR : GR32.tFixed;
                          const xStartAngle, xEndAngle : double;
                          const xColor : tColor32;
                          const xOptions : tPolygonDrawOptions = pdoFloat);
begin
  gPie(Self, xCenter, xR, xStartAngle, xEndAngle, xColor, xOptions);
end;

procedure TBitmap32Ex.PieElliptic(const xCenter : tFixedPoint;
                                  const xA, xB : GR32.tFixed;
                                  const xStartAngle, xEndAngle : double;
                                  const xColor : tColor32;
                                  const xOptions : tPolygonDrawOptions = pdoFloat);
begin
  gPieElliptic(Self, xCenter, xA, xB, xStartAngle, xEndAngle, xColor, xOptions);
end;

procedure TBitmap32Ex.Segment(const xCenter : tFixedPoint;
                          const xR : GR32.tFixed;
                          const xStartAngle, xEndAngle : double;
                          const xColor : tColor32;
                          const xOptions : tPolygonDrawOptions = pdoFloat);
begin
  gSegment(Self, xCenter, xR, xStartAngle, xEndAngle, xColor, xOptions);
end;

procedure TBitmap32Ex.SegmentElliptic(const xCenter : tFixedPoint;
                                      const xA, xB : GR32.tFixed;
                                      const xStartAngle, xEndAngle : double;
                                      const xColor : tColor32;
                                      const xOptions : tPolygonDrawOptions = pdoFloat);
begin
  gSegmentElliptic(Self, xCenter, xA, xB, xStartAngle, xEndAngle, xColor, xOptions);
end;




procedure TBitmap32Ex.RectangleHole(const xRect : tFixedRect;
                                    const xColor : TColor32;
                                    const xOptions : tPolygonDrawOptions);
begin
  gRectangleHole(Self, xRect, xColor, xOptions);
end;

procedure TBitmap32Ex.RectangleHole(const xRect : tRect;
                                    const xColor : TColor32;
                                    const  xOptions : tPolygonDrawOptions);
begin
  RectangleHole(G32_Interface.FixedRect(xRect), xColor, xOptions);
end;

procedure TBitmap32Ex.Polygon(const Points: TArrayOfFixedPoint;
                              const Color: TColor32;
                              const Options: tPolygonDrawOptions;
                              const  Closed: Boolean;
                              const FillMode: TPolyFillMode);
var
  i : integer;
begin

  for i := 0 to Length(Points) - 1 do
    begin
    Points[i].x := Points[i].x - fDrawOrign.x;
    Points[i].y := Points[i].y - fDrawOrign.y;
    end;
  gPolygon(Self, Points, Color, Options, Closed, FillMode);
  for i := 0 to Length(Points) - 1 do
    begin
    Points[i].x := Points[i].x + fDrawOrign.x;
    Points[i].y := Points[i].y + fDrawOrign.y;
    end;
end;

procedure TBitmap32Ex.PolyPolygon(
  const Points: TArrayOfArrayOfFixedPoint; const Color: tColor32;
  const Options: tPolygonDrawOptions; const Closed: Boolean; const FillMode: TPolyFillMode);
var
  i, j : integer;
  xPoints : tArrayOfFixedPoint;
begin
  if (fDrawOrign.X = 0) and (fDrawOrign.Y = 0) then begin
    gPolyPolygon(Self, Points, Color, Options, Closed, FillMode);
  end else if fDrawOrign.X = 0 then begin
    for i := 0 to Length(Points) - 1 do begin
      xPoints := Points[i];
      for j := 0 to Length(xPoints) - 1 do begin
        xPoints[j].y := xPoints[j].y - fDrawOrign.y;
      end;
    end;
    gPolyPolygon(Self, Points, Color, Options, Closed, FillMode);
    for i := 0 to Length(Points) - 1 do begin
      xPoints := Points[i];
      for j := 0 to Length(xPoints) - 1 do begin
        xPoints[j].y := xPoints[j].y + fDrawOrign.y;
      end;
    end;
  end else if fDrawOrign.Y = 0 then begin
    for i := 0 to Length(Points) - 1 do begin
      xPoints := Points[i];
      for j := 0 to Length(xPoints) - 1 do begin
        xPoints[j].X := xPoints[j].X - fDrawOrign.X;
      end;
    end;
    gPolyPolygon(Self, Points, Color, Options, Closed, FillMode);
    for i := 0 to Length(Points) - 1 do begin
      xPoints := Points[i];
      for j := 0 to Length(xPoints) - 1 do begin
        xPoints[j].X := xPoints[j].X + fDrawOrign.X;
      end;
    end;
  end else if (fDrawOrign.X <> 0) and (fDrawOrign.Y <> 0) then begin
    for i := 0 to Length(Points) - 1 do begin
      xPoints := Points[i];
      for j := 0 to Length(xPoints) - 1 do begin
        xPoints[j].x := xPoints[j].x - fDrawOrign.x;
        xPoints[j].y := xPoints[j].y - fDrawOrign.y;
      end;
    end;

    gPolyPolygon(Self, Points, Color, Options, Closed, FillMode);

    for i := 0 to Length(Points) - 1 do begin
      xPoints := Points[i];
      for j := 0 to Length(xPoints) - 1 do begin
        xPoints[j].x := xPoints[j].x + fDrawOrign.x;
        xPoints[j].y := xPoints[j].y + fDrawOrign.y;
      end;
    end;
  end;
end;


procedure TBitmap32Ex.PolyPolyBezier(const Points : TArrayOfArrayOfFixedPoint; const Color : tColor32;
                                     const Options : tPolygonDrawOptions;
                     const Closed: Boolean; const FillMode: TPolyFillMode = pfAlternate);
var
  i, j : integer;
  xPoints : tArrayOfFixedPoint;
begin
  for i := 0 to Length(Points) - 1 do
    begin
    xPoints := Points[i];
      for j := 0 to Length(xPoints) - 1 do
        begin
        xPoints[j].x := xPoints[j].x - fDrawOrign.x;
        xPoints[j].y := xPoints[j].y - fDrawOrign.y;
        end;
    end;

    gPolyPolyBezier(Self, Points, Color, Options, Closed, FillMode);
    
    for i := 0 to Length(Points) - 1 do
    begin
    xPoints := Points[i];
      for j := 0 to Length(xPoints) - 1 do
        begin
        xPoints[j].x := xPoints[j].x + fDrawOrign.x;
        xPoints[j].y := xPoints[j].y + fDrawOrign.y;
        end;
    end;
end;

initialization

  CP_Clear;
  SetLength(CurvePoints, MaxCurvePointsCount);

{$IFDEF OPTIMIZE_GLYPHPOLYGONE_STORAGE}
  GlyphPolygone_Clear;
  SetLength(GlyphPolygonPP, 1);
  SetLength(GPPointCount , 1);
  GP_Count := 1;

{$ELSE}
  GlyphPolygon := TPolygon32.Create;
{$ENDIF}

finalization

  {$IFDEF OPTIMIZE_GLYPHPOLYGONE_STORAGE}
  {$ELSE}

   GlyphPolygon.Free;
  {$ENDIF}

end.

unit GdipExport;

(**************************************************************************\
*
* 2003年，湖北省公安县统计局 毛泽发 于大连
*
* Module Name:
*
*   GdiplusInit.h, GdiplusMem.h, GdiplusFlat.h
*
* Abstract:
*
*   GDI+ Private Memory Management APIs
*
**************************************************************************)
interface

uses
  WinApi.Windows, WinApi.ActiveX, GdipTypes;//, DirectDraw;

// GDI+ initialization. Must not be called from DllMain - can cause deadlock.
//
// Must be called before GDI+ API's or constructors are used.
//
// token  - may not be NULL - accepts a token to be passed in the corresponding
//          GdiplusShutdown call.
// input  - may not be NULL
// output - may be NULL only if input->SuppressBackgroundThread is FALSE.

function GdiplusStartup(var token: DWORD;
      const input: PGdiplusStartupInput;
      output: PGdiplusStartupOutput): TStatus; stdcall;
{$EXTERNALSYM GdiplusStartup}
// GDI+ termination. Must be called before GDI+ is unloaded.
// Must not be called from DllMain - can cause deadlock.
//
// GDI+ API's may not be called after GdiplusShutdown. Pay careful attention
// to GDI+ object destructors.

procedure GdiplusShutdown(token: DWORD); stdcall;
{$EXTERNALSYM GdiplusShutdown}

function GdipAlloc(size: ULONG): Pointer; stdcall;
{$EXTERNALSYM GdipAlloc}
procedure GdipFree(ptr: Pointer); stdcall;
{$EXTERNALSYM GdipFree}


function GdipCreatePath(brushMode: TFillMode; var path: GpPath): TStatus; stdcall;
{$EXTERNALSYM GdipCreatePath}
function GdipCreatePath2(const v1: PPointF; const v2: PByte; v3: INT;
     v4: TFillMode; var path: GpPath): TStatus; stdcall;
{$EXTERNALSYM GdipCreatePath2}
function GdipCreatePath2I(const v1: PPoint; const v2: PByte; v3: INT;
     v4: TFillMode; var path: GpPath): TStatus; stdcall;
{$EXTERNALSYM GdipCreatePath2I}
function GdipClonePath(path: GpPath; var clonePath: GpPath): TStatus; stdcall;
{$EXTERNALSYM GdipClonePath}
function GdipDeletePath(path: GpPath): TStatus; stdcall;
{$EXTERNALSYM GdipDeletePath}
function GdipResetPath(path: GpPath): TStatus; stdcall;
{$EXTERNALSYM GdipResetPath}
function GdipGetPointCount(path: GpPath; var count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipGetPointCount}
function GdipGetPathTypes(path: GpPath; types: PByte; count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipGetPathTypes}
function GdipGetPathPoints(v1: GpPath; points: PPointF; count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipGetPathPoints}
function GdipGetPathPointsI(v1: GpPath; points: PPoint; count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipGetPathPointsI}
function GdipGetPathFillMode(path: GpPath; var fillmode: TFillMode): TStatus; stdcall;
{$EXTERNALSYM GdipGetPathFillMode}
function GdipSetPathFillMode(path: GpPath; fillmode: TFillMode): TStatus; stdcall;
{$EXTERNALSYM GdipSetPathFillMode}
function GdipGetPathData(path: GpPath; pathData: GpPathData): TStatus; stdcall;
{$EXTERNALSYM GdipGetPathData}
function GdipStartPathFigure(path: GpPath): TStatus; stdcall;
{$EXTERNALSYM GdipStartPathFigure}
function GdipClosePathFigure(path: GpPath): TStatus; stdcall;
{$EXTERNALSYM GdipClosePathFigure}
function GdipClosePathFigures(path: GpPath): TStatus; stdcall;
{$EXTERNALSYM GdipClosePathFigures}
function GdipSetPathMarker(path: GpPath): TStatus; stdcall;
{$EXTERNALSYM GdipSetPathMarker}
function GdipClearPathMarkers(path: GpPath): TStatus; stdcall;
{$EXTERNALSYM GdipClearPathMarkers}
function GdipReversePath(path: GpPath): TStatus; stdcall;
{$EXTERNALSYM GdipReversePath}
function GdipGetPathLastPoint(path: GpPath; lastPoint: PPointF): TStatus; stdcall;
{$EXTERNALSYM GdipGetPathLastPoint}
function GdipAddPathLine(path: GpPath; x1: TREAL; y1: TREAL;
     x2: TREAL; y2: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipAddPathLine}
function GdipAddPathLine2(path: GpPath; const points: PPointF;
     count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipAddPathLine2}
function GdipAddPathArc(path: GpPath; x: TREAL; y: TREAL; width: TREAL; height: TREAL;
     startAngle: TREAL; sweepAngle: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipAddPathArc}
function GdipAddPathBezier(path: GpPath; x1: TREAL; y1: TREAL; x2: TREAL; y2: TREAL;
     x3: TREAL; y3: TREAL; x4: TREAL; y4: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipAddPathBezier}
function GdipAddPathBeziers(path: GpPath; const points: PPointF;
     count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipAddPathBeziers}
function GdipAddPathCurve(path: GpPath; const points: PPointF;
     count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipAddPathCurve}
function GdipAddPathCurve2(path: GpPath; const points: PPointF;
     count: INT; tension: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipAddPathCurve2}
function GdipAddPathCurve3(path: GpPath; const points: PPointF; count: INT;
     offset: INT; numberOfSegments: INT; tension: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipAddPathCurve3}
function GdipAddPathClosedCurve(path: GpPath; const points: PPointF;
     count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipAddPathClosedCurve}
function GdipAddPathClosedCurve2(path: GpPath; const points: PPointF;
     count: INT; tension: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipAddPathClosedCurve2}
function GdipAddPathRectangle(path: GpPath; x: TREAL; y: TREAL;
     width: TREAL; height: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipAddPathRectangle}
function GdipAddPathRectangles(path: GpPath; const rects: PRectF;
     count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipAddPathRectangles}
function GdipAddPathEllipse(path: GpPath; x: TREAL; y: TREAL;
     width: TREAL; height: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipAddPathEllipse}
function GdipAddPathPie(path: GpPath; x: TREAL; y: TREAL; width: TREAL; height: TREAL;
     startAngle: TREAL; sweepAngle: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipAddPathPie}
function GdipAddPathPolygon(path: GpPath; const points: PPointF;
     count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipAddPathPolygon}
function GdipAddPathPath(path: GpPath; const addingPath: GpPath;
     connect: BOOL): TStatus; stdcall;
{$EXTERNALSYM GdipAddPathPath}
function GdipAddPathString(path: GpPath; const str: PWCHAR; length: INT; const family: GpFontFamily; style: INT;
     emSize: TREAL; const layoutRect: PRectF; const format: GpStringFormat): TStatus; stdcall;
{$EXTERNALSYM GdipAddPathString}
function GdipAddPathStringI(path: GpPath; const str: PWCHAR; length: INT; const family: GpFontFamily;
     style: INT; emSize: TREAL; const layoutRect: PRect; const format: GpStringFormat): TStatus; stdcall;
{$EXTERNALSYM GdipAddPathStringI}
function GdipAddPathLineI(path: GpPath; x1: INT;
     y1: INT; x2: INT; y2: INT): TStatus; stdcall;
{$EXTERNALSYM GdipAddPathLineI}
function GdipAddPathLine2I(path: GpPath; const points: PPoint;
     count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipAddPathLine2I}
function GdipAddPathArcI(path: GpPath; x: INT; y: INT; width: INT; height: INT;
     startAngle: TREAL; sweepAngle: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipAddPathArcI}
function GdipAddPathBezierI(path: GpPath; x1: INT; y1: INT; x2: INT;
     y2: INT; x3: INT; y3: INT; x4: INT; y4: INT): TStatus; stdcall;
{$EXTERNALSYM GdipAddPathBezierI}
function GdipAddPathBeziersI(path: GpPath; const points: PPoint;
     count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipAddPathBeziersI}
function GdipAddPathCurveI(path: GpPath; const points: PPoint;
     count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipAddPathCurveI}
function GdipAddPathCurve2I(path: GpPath; const points: PPoint;
     count: INT; tension: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipAddPathCurve2I}
function GdipAddPathCurve3I(path: GpPath; const points: PPoint; count: INT;
     offset: INT; numberOfSegments: INT; tension: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipAddPathCurve3I}
function GdipAddPathClosedCurveI(path: GpPath; const points: PPoint;
     count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipAddPathClosedCurveI}
function GdipAddPathClosedCurve2I(path: GpPath; const points: PPoint;
     count: INT; tension: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipAddPathClosedCurve2I}
function GdipAddPathRectangleI(path: GpPath; x: INT;
     y: INT; width: INT; height: INT): TStatus; stdcall;
{$EXTERNALSYM GdipAddPathRectangleI}
function GdipAddPathRectanglesI(path: GpPath; const rects: PRect;
     count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipAddPathRectanglesI}
function GdipAddPathEllipseI(path: GpPath; x: INT; y: INT;
     width: INT; height: INT): TStatus; stdcall;
{$EXTERNALSYM GdipAddPathEllipseI}
function GdipAddPathPieI(path: GpPath; x: INT; y: INT; width: INT; height: INT;
     startAngle: TREAL; sweepAngle: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipAddPathPieI}
function GdipAddPathPolygonI(path: GpPath; const points: PPoint;
     count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipAddPathPolygonI}
function GdipFlattenPath(path: GpPath; matrix: GpMatrix;
     flatness: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipFlattenPath}
function GdipWindingModeOutline(path: GpPath; matrix: GpMatrix;
     flatness: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipWindingModeOutline}
function GdipWidenPath(nativePath: GpPath; pen: GpPen;
     matrix: GpMatrix; flatness: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipWidenPath}
function GdipWarpPath(path: GpPath; matrix: GpMatrix; const points: PPointF; count: INT; srcx: TREAL; srcy: TREAL;
     srcwidth: TREAL; srcheight: TREAL; warpMode: TWarpMode; flatness: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipWarpPath}
function GdipTransformPath(path: GpPath; matrix: GpMatrix): TStatus; stdcall;
{$EXTERNALSYM GdipTransformPath}
function GdipGetPathWorldBounds(path: GpPath; bounds: PRectF;
     const matrix: GpMatrix; const pen: GpPen): TStatus; stdcall;
{$EXTERNALSYM GdipGetPathWorldBounds}
function GdipGetPathWorldBoundsI(path: GpPath; bounds: PRect;
     const matrix: GpMatrix; const pen: GpPen): TStatus; stdcall;
{$EXTERNALSYM GdipGetPathWorldBoundsI}
function GdipIsVisiblePathPoint(path: GpPath; x: TREAL; y: TREAL;
     graphics: GpGraphics; var result: BOOL): TStatus; stdcall;
{$EXTERNALSYM GdipIsVisiblePathPoint}
function GdipIsVisiblePathPointI(path: GpPath; x: INT; y: INT;
     graphics: GpGraphics; var result: BOOL): TStatus; stdcall;
{$EXTERNALSYM GdipIsVisiblePathPointI}
function GdipIsOutlineVisiblePathPoint(path: GpPath; x: TREAL; y: TREAL;
     pen: GpPen; graphics: GpGraphics; var result: BOOL): TStatus; stdcall;
{$EXTERNALSYM GdipIsOutlineVisiblePathPoint}
function GdipIsOutlineVisiblePathPointI(path: GpPath; x: INT; y: INT; pen: GpPen;
     graphics: GpGraphics; var result: BOOL): TStatus; stdcall;
{$EXTERNALSYM GdipIsOutlineVisiblePathPointI}
function GdipCreatePathIter(var iterator: GpPathIterator;
     path: GpPath): TStatus; stdcall;
{$EXTERNALSYM GdipCreatePathIter}
function GdipDeletePathIter(iterator: GpPathIterator): TStatus; stdcall;
{$EXTERNALSYM GdipDeletePathIter}
function GdipPathIterNextSubpath(iterator: GpPathIterator; var resultCount: INT;
     var startIndex: INT; var endIndex: INT; var isClosed: BOOL): TStatus; stdcall;
{$EXTERNALSYM GdipPathIterNextSubpath}
function GdipPathIterNextSubpathPath(iterator: GpPathIterator; var resultCount: INT;
     path: GpPath; var isClosed: BOOL): TStatus; stdcall;
{$EXTERNALSYM GdipPathIterNextSubpathPath}
function GdipPathIterNextPathType(iterator: GpPathIterator; var resultCount: INT;
     pathType: PByte; var startIndex: INT; var endIndex: INT): TStatus; stdcall;
{$EXTERNALSYM GdipPathIterNextPathType}
function GdipPathIterNextMarker(iterator: GpPathIterator; var resultCount: INT;
     var startIndex: INT; var endIndex: INT): TStatus; stdcall;
{$EXTERNALSYM GdipPathIterNextMarker}
function GdipPathIterNextMarkerPath(iterator: GpPathIterator;
     var resultCount: INT; path: GpPath): TStatus; stdcall;
{$EXTERNALSYM GdipPathIterNextMarkerPath}
function GdipPathIterGetCount(iterator: GpPathIterator;
     var count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipPathIterGetCount}
function GdipPathIterGetSubpathCount(iterator: GpPathIterator;
     var count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipPathIterGetSubpathCount}
function GdipPathIterIsValid(iterator: GpPathIterator;
     var valid: BOOL): TStatus; stdcall;
{$EXTERNALSYM GdipPathIterIsValid}
function GdipPathIterHasCurve(iterator: GpPathIterator;
     var hasCurve: BOOL): TStatus; stdcall;
{$EXTERNALSYM GdipPathIterHasCurve}
function GdipPathIterRewind(iterator: GpPathIterator): TStatus; stdcall;
{$EXTERNALSYM GdipPathIterRewind}
function GdipPathIterEnumerate(iterator: GpPathIterator; var resultCount: INT;
     points: PPointF; types: PByte; count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipPathIterEnumerate}
function GdipPathIterCopyData(iterator: GpPathIterator; var resultCount: INT; points: PPointF;
     types: PByte; startIndex: INT; endIndex: INT): TStatus; stdcall;
{$EXTERNALSYM GdipPathIterCopyData}
function GdipCreateMatrix(var matrix: GpMatrix): TStatus; stdcall;
{$EXTERNALSYM GdipCreateMatrix}
function GdipCreateMatrix2(m11: TREAL; m12: TREAL; m21: TREAL; m22: TREAL;
     dx: TREAL; dy: TREAL; var matrix: GpMatrix): TStatus; stdcall;
{$EXTERNALSYM GdipCreateMatrix2}
function GdipCreateMatrix3(const rect: PRectF; const dstplg: PPointF;
     var matrix: GpMatrix): TStatus; stdcall;
{$EXTERNALSYM GdipCreateMatrix3}
function GdipCreateMatrix3I(const rect: PRect; const dstplg: PPoint;
     var matrix: GpMatrix): TStatus; stdcall;
{$EXTERNALSYM GdipCreateMatrix3I}
function GdipCloneMatrix(matrix: GpMatrix; var cloneMatrix: GpMatrix): TStatus; stdcall;
{$EXTERNALSYM GdipCloneMatrix}
function GdipDeleteMatrix(matrix: GpMatrix): TStatus; stdcall;
{$EXTERNALSYM GdipDeleteMatrix}
function GdipSetMatrixElements(matrix: GpMatrix; m11: TREAL; m12: TREAL;
     m21: TREAL; m22: TREAL; dx: TREAL; dy: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipSetMatrixElements}
function GdipMultiplyMatrix(matrix: GpMatrix; matrix2: GpMatrix;
     order: TMatrixOrder): TStatus; stdcall;
{$EXTERNALSYM GdipMultiplyMatrix}
function GdipTranslateMatrix(matrix: GpMatrix; offsetX: TREAL;
     offsetY: TREAL; order: TMatrixOrder): TStatus; stdcall;
{$EXTERNALSYM GdipTranslateMatrix}
function GdipScaleMatrix(matrix: GpMatrix; scaleX: TREAL;
     scaleY: TREAL; order: TMatrixOrder): TStatus; stdcall;
{$EXTERNALSYM GdipScaleMatrix}
function GdipRotateMatrix(matrix: GpMatrix; angle: TREAL;
     order: TMatrixOrder): TStatus; stdcall;
{$EXTERNALSYM GdipRotateMatrix}
function GdipShearMatrix(matrix: GpMatrix; shearX: TREAL;
     shearY: TREAL; order: TMatrixOrder): TStatus; stdcall;
{$EXTERNALSYM GdipShearMatrix}
function GdipInvertMatrix(matrix: GpMatrix): TStatus; stdcall;
{$EXTERNALSYM GdipInvertMatrix}
function GdipTransformMatrixPoints(matrix: GpMatrix;
     pts: PPointF; count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipTransformMatrixPoints}
function GdipTransformMatrixPointsI(matrix: GpMatrix;
     pts: PPoint; count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipTransformMatrixPointsI}
function GdipVectorTransformMatrixPoints(matrix: GpMatrix;
     pts: PPointF; count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipVectorTransformMatrixPoints}
function GdipVectorTransformMatrixPointsI(matrix: GpMatrix;
     pts: PPoint; count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipVectorTransformMatrixPointsI}
function GdipGetMatrixElements(const matrix: GpMatrix;
     matrixOut: PREAL): TStatus; stdcall;
{$EXTERNALSYM GdipGetMatrixElements}
function GdipIsMatrixInvertible(const matrix: GpMatrix;
     var result: BOOL): TStatus; stdcall;
{$EXTERNALSYM GdipIsMatrixInvertible}
function GdipIsMatrixIdentity(const matrix: GpMatrix;
     var result: BOOL): TStatus; stdcall;
{$EXTERNALSYM GdipIsMatrixIdentity}
function GdipIsMatrixEqual(const matrix: GpMatrix; const matrix2: GpMatrix;
     var result: BOOL): TStatus; stdcall;
{$EXTERNALSYM GdipIsMatrixEqual}
function GdipCreateRegion(var region: GpRegion): TStatus; stdcall;
{$EXTERNALSYM GdipCreateRegion}
function GdipCreateRegionRect(const rect: PRectF;
     var region: GpRegion): TStatus; stdcall;
{$EXTERNALSYM GdipCreateRegionRect}
function GdipCreateRegionRectI(const rect: PRect;
     var region: GpRegion): TStatus; stdcall;
{$EXTERNALSYM GdipCreateRegionRectI}
function GdipCreateRegionPath(path: GpPath; var region: GpRegion): TStatus; stdcall;
{$EXTERNALSYM GdipCreateRegionPath}
function GdipCreateRegionRgnData(const regionData: PByte;
     size: INT; var region: GpRegion): TStatus; stdcall;
{$EXTERNALSYM GdipCreateRegionRgnData}
function GdipCreateRegionHrgn(hRgn: HRGN; var region: GpRegion): TStatus; stdcall;
{$EXTERNALSYM GdipCreateRegionHrgn}
function GdipCloneRegion(region: GpRegion; var cloneRegion: GpRegion): TStatus; stdcall;
{$EXTERNALSYM GdipCloneRegion}
function GdipDeleteRegion(region: GpRegion): TStatus; stdcall;
{$EXTERNALSYM GdipDeleteRegion}
function GdipSetInfinite(region: GpRegion): TStatus; stdcall;
{$EXTERNALSYM GdipSetInfinite}
function GdipSetEmpty(region: GpRegion): TStatus; stdcall;
{$EXTERNALSYM GdipSetEmpty}
function GdipCombineRegionRect(region: GpRegion; const rect: PRectF;
     combineMode: TCombineMode): TStatus; stdcall;
{$EXTERNALSYM GdipCombineRegionRect}
function GdipCombineRegionRectI(region: GpRegion; const rect: PRect;
     combineMode: TCombineMode): TStatus; stdcall;
{$EXTERNALSYM GdipCombineRegionRectI}
function GdipCombineRegionPath(region: GpRegion; path: GpPath;
     combineMode: TCombineMode): TStatus; stdcall;
{$EXTERNALSYM GdipCombineRegionPath}
function GdipCombineRegionRegion(region: GpRegion; region2: GpRegion;
     combineMode: TCombineMode): TStatus; stdcall;
{$EXTERNALSYM GdipCombineRegionRegion}
function GdipTranslateRegion(region: GpRegion; dx: TREAL; dy: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipTranslateRegion}
function GdipTranslateRegionI(region: GpRegion; dx: INT; dy: INT): TStatus; stdcall;
{$EXTERNALSYM GdipTranslateRegionI}
function GdipTransformRegion(region: GpRegion; matrix: GpMatrix): TStatus; stdcall;
{$EXTERNALSYM GdipTransformRegion}
function GdipGetRegionBounds(region: GpRegion; graphics: GpGraphics;
     rect: PRectF): TStatus; stdcall;
{$EXTERNALSYM GdipGetRegionBounds}
function GdipGetRegionBoundsI(region: GpRegion; graphics: GpGraphics;
     rect: PRect): TStatus; stdcall;
{$EXTERNALSYM GdipGetRegionBoundsI}
function GdipGetRegionHRgn(region: GpRegion; graphics: GpGraphics;
     var hRgn: HRGN): TStatus; stdcall;
{$EXTERNALSYM GdipGetRegionHRgn}
function GdipIsEmptyRegion(region: GpRegion; graphics: GpGraphics;
     var result: BOOL): TStatus; stdcall;
{$EXTERNALSYM GdipIsEmptyRegion}
function GdipIsInfiniteRegion(region: GpRegion; graphics: GpGraphics;
     var result: BOOL): TStatus; stdcall;
{$EXTERNALSYM GdipIsInfiniteRegion}
function GdipIsEqualRegion(region: GpRegion; region2: GpRegion;
     graphics: GpGraphics; var result: BOOL): TStatus; stdcall;
{$EXTERNALSYM GdipIsEqualRegion}
function GdipGetRegionDataSize(region: GpRegion; var bufferSize: INT): TStatus; stdcall;
{$EXTERNALSYM GdipGetRegionDataSize}
function GdipGetRegionData(region: GpRegion; buffer: PByte;
     bufferSize: INT; sizeFilled: PUINT): TStatus; stdcall;
{$EXTERNALSYM GdipGetRegionData}
function GdipIsVisibleRegionPoint(region: GpRegion; x: TREAL; y: TREAL;
     graphics: GpGraphics; var result: BOOL): TStatus; stdcall;
{$EXTERNALSYM GdipIsVisibleRegionPoint}
function GdipIsVisibleRegionPointI(region: GpRegion; x: INT; y: INT;
     graphics: GpGraphics; var result: BOOL): TStatus; stdcall;
{$EXTERNALSYM GdipIsVisibleRegionPointI}
function GdipIsVisibleRegionRect(region: GpRegion; x: TREAL; y: TREAL; width: TREAL;
     height: TREAL; graphics: GpGraphics; var result: BOOL): TStatus; stdcall;
{$EXTERNALSYM GdipIsVisibleRegionRect}
function GdipIsVisibleRegionRectI(region: GpRegion; x: INT; y: INT; width: INT;
     height: INT; graphics: GpGraphics; var result: BOOL): TStatus; stdcall;
{$EXTERNALSYM GdipIsVisibleRegionRectI}
function GdipGetRegionScansCount(region: GpRegion; var count: INT;
     matrix: GpMatrix): TStatus; stdcall;
{$EXTERNALSYM GdipGetRegionScansCount}
function GdipGetRegionScans(region: GpRegion; rects: PRectF;
     var count: INT; matrix: GpMatrix): TStatus; stdcall;
{$EXTERNALSYM GdipGetRegionScans}
function GdipGetRegionScansI(region: GpRegion; rects: PRect;
     var count: INT; matrix: GpMatrix): TStatus; stdcall;
{$EXTERNALSYM GdipGetRegionScansI}
function GdipCloneBrush(brush: GpBrush; var cloneBrush: GpBrush): TStatus; stdcall;
{$EXTERNALSYM GdipCloneBrush}
function GdipDeleteBrush(brush: GpBrush): TStatus; stdcall;
{$EXTERNALSYM GdipDeleteBrush}
function GdipGetBrushType(brush: GpBrush; var btype: TBrushType): TStatus; stdcall;
{$EXTERNALSYM GdipGetBrushType}
function GdipCreateHatchBrush(hatchstyle: THatchStyle; forecol: TARGB;
     backcol: TARGB; var brush: GpHatch): TStatus; stdcall;
{$EXTERNALSYM GdipCreateHatchBrush}
function GdipGetHatchStyle(brush: GpHatch; var hatchstyle: THatchStyle): TStatus; stdcall;
{$EXTERNALSYM GdipGetHatchStyle}
function GdipGetHatchForegroundColor(brush: GpHatch; forecol: PARGB): TStatus; stdcall;
{$EXTERNALSYM GdipGetHatchForegroundColor}
function GdipGetHatchBackgroundColor(brush: GpHatch; backcol: PARGB): TStatus; stdcall;
{$EXTERNALSYM GdipGetHatchBackgroundColor}
function GdipCreateTexture(image: GpImage; wrapmode: TWrapMode;
     var texture: GpTexture): TStatus; stdcall;
{$EXTERNALSYM GdipCreateTexture}
function GdipCreateTexture2(image: GpImage; wrapmode: TWrapMode; x: TREAL; y: TREAL;
     width: TREAL; height: TREAL; var texture: GpTexture): TStatus; stdcall;
{$EXTERNALSYM GdipCreateTexture2}
function GdipCreateTextureIA(image: GpImage; const imageAttributes: GpImageAttributes; x: TREAL;
     y: TREAL; width: TREAL; height: TREAL; var texture: GpTexture): TStatus; stdcall;
{$EXTERNALSYM GdipCreateTextureIA}
function GdipCreateTexture2I(image: GpImage; wrapmode: TWrapMode; x: INT; y: INT;
     width: INT; height: INT; var texture: GpTexture): TStatus; stdcall;
{$EXTERNALSYM GdipCreateTexture2I}
function GdipCreateTextureIAI(image: GpImage; const imageAttributes: GpImageAttributes;
     x: INT; y: INT; width: INT; height: INT; var texture: GpTexture): TStatus; stdcall;
{$EXTERNALSYM GdipCreateTextureIAI}
function GdipGetTextureTransform(brush: GpTexture; matrix: GpMatrix): TStatus; stdcall;
{$EXTERNALSYM GdipGetTextureTransform}
function GdipSetTextureTransform(brush: GpTexture;
     const matrix: GpMatrix): TStatus; stdcall;
{$EXTERNALSYM GdipSetTextureTransform}
function GdipResetTextureTransform(brush: GpTexture): TStatus; stdcall;
{$EXTERNALSYM GdipResetTextureTransform}
function GdipMultiplyTextureTransform(brush: GpTexture; const matrix: GpMatrix;
     order: TMatrixOrder): TStatus; stdcall;
{$EXTERNALSYM GdipMultiplyTextureTransform}
function GdipTranslateTextureTransform(brush: GpTexture; dx: TREAL;
     dy: TREAL; order: TMatrixOrder): TStatus; stdcall;
{$EXTERNALSYM GdipTranslateTextureTransform}
function GdipScaleTextureTransform(brush: GpTexture; sx: TREAL;
     sy: TREAL; order: TMatrixOrder): TStatus; stdcall;
{$EXTERNALSYM GdipScaleTextureTransform}
function GdipRotateTextureTransform(brush: GpTexture; angle: TREAL;
     order: TMatrixOrder): TStatus; stdcall;
{$EXTERNALSYM GdipRotateTextureTransform}
function GdipSetTextureWrapMode(brush: GpTexture;
     wrapmode: TWrapMode): TStatus; stdcall;
{$EXTERNALSYM GdipSetTextureWrapMode}
function GdipGetTextureWrapMode(brush: GpTexture;
     var wrapmode: TWrapMode): TStatus; stdcall;
{$EXTERNALSYM GdipGetTextureWrapMode}
function GdipGetTextureImage(brush: GpTexture; var image: GpImage): TStatus; stdcall;
{$EXTERNALSYM GdipGetTextureImage}
function GdipCreateSolidFill(color: TARGB; var brush: GpSolidFill): TStatus; stdcall;
{$EXTERNALSYM GdipCreateSolidFill}
function GdipSetSolidFillColor(brush: GpSolidFill; color: TARGB): TStatus; stdcall;
{$EXTERNALSYM GdipSetSolidFillColor}
function GdipGetSolidFillColor(brush: GpSolidFill; color: PARGB): TStatus; stdcall;
{$EXTERNALSYM GdipGetSolidFillColor}
function GdipCreateLineBrush(const point1: PPointF; const point2: PPointF; color1: TARGB;
     color2: TARGB; wrapMode: TWrapMode; var lineGradient: GpLineGradient): TStatus; stdcall;
{$EXTERNALSYM GdipCreateLineBrush}
function GdipCreateLineBrushI(const point1: PPoint; const point2: PPoint; color1: TARGB;
     color2: TARGB; wrapMode: TWrapMode; var lineGradient: GpLineGradient): TStatus; stdcall;
{$EXTERNALSYM GdipCreateLineBrushI}
function GdipCreateLineBrushFromRect(const rect: PRectF; color1: TARGB; color2: TARGB; mode: TLinearGradientMode;
     wrapMode: TWrapMode; var lineGradient: GpLineGradient): TStatus; stdcall;
{$EXTERNALSYM GdipCreateLineBrushFromRect}
function GdipCreateLineBrushFromRectI(const rect: PRect; color1: TARGB; color2: TARGB; mode: TLinearGradientMode;
     wrapMode: TWrapMode; var lineGradient: GpLineGradient): TStatus; stdcall;
{$EXTERNALSYM GdipCreateLineBrushFromRectI}
function GdipCreateLineBrushFromRectWithAngle(const rect: PRectF; color1: TARGB; color2: TARGB; angle: TREAL;
     isAngleScalable: BOOL; wrapMode: TWrapMode; var lineGradient: GpLineGradient): TStatus; stdcall;
{$EXTERNALSYM GdipCreateLineBrushFromRectWithAngle}
function GdipCreateLineBrushFromRectWithAngleI(const rect: PRect; color1: TARGB; color2: TARGB; angle: TREAL;
     isAngleScalable: BOOL; wrapMode: TWrapMode; var lineGradient: GpLineGradient): TStatus; stdcall;
{$EXTERNALSYM GdipCreateLineBrushFromRectWithAngleI}
function GdipSetLineColors(brush: GpLineGradient;
     color1: TARGB; color2: TARGB): TStatus; stdcall;
{$EXTERNALSYM GdipSetLineColors}
function GdipGetLineColors(brush: GpLineGradient; colors: PARGB): TStatus; stdcall;
{$EXTERNALSYM GdipGetLineColors}
function GdipGetLineRect(brush: GpLineGradient; rect: PRectF): TStatus; stdcall;
{$EXTERNALSYM GdipGetLineRect}
function GdipGetLineRectI(brush: GpLineGradient; rect: PRect): TStatus; stdcall;
{$EXTERNALSYM GdipGetLineRectI}
function GdipSetLineGammaCorrection(brush: GpLineGradient;
     useGammaCorrection: BOOL): TStatus; stdcall;
{$EXTERNALSYM GdipSetLineGammaCorrection}
function GdipGetLineGammaCorrection(brush: GpLineGradient;
     var useGammaCorrection: BOOL): TStatus; stdcall;
{$EXTERNALSYM GdipGetLineGammaCorrection}
function GdipGetLineBlendCount(brush: GpLineGradient; var count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipGetLineBlendCount}
function GdipGetLineBlend(brush: GpLineGradient; blend: PREAL;
     positions: PREAL; count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipGetLineBlend}
function GdipSetLineBlend(brush: GpLineGradient; const blend: PREAL;
     const positions: PREAL; count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipSetLineBlend}
function GdipGetLinePresetBlendCount(brush: GpLineGradient;
     var count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipGetLinePresetBlendCount}
function GdipGetLinePresetBlend(brush: GpLineGradient; blend: PARGB;
     positions: PREAL; count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipGetLinePresetBlend}
function GdipSetLinePresetBlend(brush: GpLineGradient; const blend: PARGB;
     const positions: PREAL; count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipSetLinePresetBlend}
function GdipSetLineSigmaBlend(brush: GpLineGradient;
     focus: TREAL; scale: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipSetLineSigmaBlend}
function GdipSetLineLinearBlend(brush: GpLineGradient;
     focus: TREAL; scale: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipSetLineLinearBlend}
function GdipSetLineWrapMode(brush: GpLineGradient;
     wrapmode: TWrapMode): TStatus; stdcall;
{$EXTERNALSYM GdipSetLineWrapMode}
function GdipGetLineWrapMode(brush: GpLineGradient;
     var wrapmode: TWrapMode): TStatus; stdcall;
{$EXTERNALSYM GdipGetLineWrapMode}
function GdipGetLineTransform(brush: GpLineGradient; matrix: GpMatrix): TStatus; stdcall;
{$EXTERNALSYM GdipGetLineTransform}
function GdipSetLineTransform(brush: GpLineGradient;
     const matrix: GpMatrix): TStatus; stdcall;
{$EXTERNALSYM GdipSetLineTransform}
function GdipResetLineTransform(brush: GpLineGradient): TStatus; stdcall;
{$EXTERNALSYM GdipResetLineTransform}
function GdipMultiplyLineTransform(brush: GpLineGradient; const matrix: GpMatrix;
     order: TMatrixOrder): TStatus; stdcall;
{$EXTERNALSYM GdipMultiplyLineTransform}
function GdipTranslateLineTransform(brush: GpLineGradient; dx: TREAL;
     dy: TREAL; order: TMatrixOrder): TStatus; stdcall;
{$EXTERNALSYM GdipTranslateLineTransform}
function GdipScaleLineTransform(brush: GpLineGradient; sx: TREAL;
     sy: TREAL; order: TMatrixOrder): TStatus; stdcall;
{$EXTERNALSYM GdipScaleLineTransform}
function GdipRotateLineTransform(brush: GpLineGradient;
     angle: TREAL; order: TMatrixOrder): TStatus; stdcall;
{$EXTERNALSYM GdipRotateLineTransform}
function GdipCreatePathGradient(const points: PPointF; count: INT; wrapMode: TWrapMode;
     var polyGradient: GpPathGradient): TStatus; stdcall;
{$EXTERNALSYM GdipCreatePathGradient}
function GdipCreatePathGradientI(const points: PPoint; count: INT; wrapMode: TWrapMode;
     var polyGradient: GpPathGradient): TStatus; stdcall;
{$EXTERNALSYM GdipCreatePathGradientI}
function GdipCreatePathGradientFromPath(const path: GpPath;
     var polyGradient: GpPathGradient): TStatus; stdcall;
{$EXTERNALSYM GdipCreatePathGradientFromPath}
function GdipGetPathGradientCenterColor(brush: GpPathGradient;
     colors: PARGB): TStatus; stdcall;
{$EXTERNALSYM GdipGetPathGradientCenterColor}
function GdipSetPathGradientCenterColor(brush: GpPathGradient;
     colors: TARGB): TStatus; stdcall;
{$EXTERNALSYM GdipSetPathGradientCenterColor}
function GdipGetPathGradientSurroundColorsWithCount(brush: GpPathGradient;
     color: PARGB; var count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipGetPathGradientSurroundColorsWithCount}
function GdipSetPathGradientSurroundColorsWithCount(brush: GpPathGradient;
     const color: PARGB; var count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipSetPathGradientSurroundColorsWithCount}
function GdipGetPathGradientPath(brush: GpPathGradient; path: GpPath): TStatus; stdcall;
{$EXTERNALSYM GdipGetPathGradientPath}
function GdipSetPathGradientPath(brush: GpPathGradient;
     const path: GpPath): TStatus; stdcall;
{$EXTERNALSYM GdipSetPathGradientPath}
function GdipGetPathGradientCenterPoint(brush: GpPathGradient;
     points: PPointF): TStatus; stdcall;
{$EXTERNALSYM GdipGetPathGradientCenterPoint}
function GdipGetPathGradientCenterPointI(brush: GpPathGradient;
     points: PPoint): TStatus; stdcall;
{$EXTERNALSYM GdipGetPathGradientCenterPointI}
function GdipSetPathGradientCenterPoint(brush: GpPathGradient;
     const points: PPointF): TStatus; stdcall;
{$EXTERNALSYM GdipSetPathGradientCenterPoint}
function GdipSetPathGradientCenterPointI(brush: GpPathGradient;
     const points: PPoint): TStatus; stdcall;
{$EXTERNALSYM GdipSetPathGradientCenterPointI}
function GdipGetPathGradientRect(brush: GpPathGradient; rect: PRectF): TStatus; stdcall;
{$EXTERNALSYM GdipGetPathGradientRect}
function GdipGetPathGradientRectI(brush: GpPathGradient; rect: PRect): TStatus; stdcall;
{$EXTERNALSYM GdipGetPathGradientRectI}
function GdipGetPathGradientPointCount(brush: GpPathGradient;
     var count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipGetPathGradientPointCount}
function GdipGetPathGradientSurroundColorCount(brush: GpPathGradient;
     var count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipGetPathGradientSurroundColorCount}
function GdipSetPathGradientGammaCorrection(brush: GpPathGradient;
     useGammaCorrection: BOOL): TStatus; stdcall;
{$EXTERNALSYM GdipSetPathGradientGammaCorrection}
function GdipGetPathGradientGammaCorrection(brush: GpPathGradient;
     var useGammaCorrection: BOOL): TStatus; stdcall;
{$EXTERNALSYM GdipGetPathGradientGammaCorrection}
function GdipGetPathGradientBlendCount(brush: GpPathGradient;
     var count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipGetPathGradientBlendCount}
function GdipGetPathGradientBlend(brush: GpPathGradient; blend: PREAL;
     positions: PREAL; count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipGetPathGradientBlend}
function GdipSetPathGradientBlend(brush: GpPathGradient; const blend: PREAL;
     const positions: PREAL; count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipSetPathGradientBlend}
function GdipGetPathGradientPresetBlendCount(brush: GpPathGradient;
     var count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipGetPathGradientPresetBlendCount}
function GdipGetPathGradientPresetBlend(brush: GpPathGradient; blend: PARGB;
     positions: PREAL; count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipGetPathGradientPresetBlend}
function GdipSetPathGradientPresetBlend(brush: GpPathGradient; const blend: PARGB;
     const positions: PREAL; count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipSetPathGradientPresetBlend}
function GdipSetPathGradientSigmaBlend(brush: GpPathGradient;
     focus: TREAL; scale: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipSetPathGradientSigmaBlend}
function GdipSetPathGradientLinearBlend(brush: GpPathGradient;
     focus: TREAL; scale: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipSetPathGradientLinearBlend}
function GdipGetPathGradientWrapMode(brush: GpPathGradient;
     var wrapmode: TWrapMode): TStatus; stdcall;
{$EXTERNALSYM GdipGetPathGradientWrapMode}
function GdipSetPathGradientWrapMode(brush: GpPathGradient;
     wrapmode: TWrapMode): TStatus; stdcall;
{$EXTERNALSYM GdipSetPathGradientWrapMode}
function GdipGetPathGradientTransform(brush: GpPathGradient;
     matrix: GpMatrix): TStatus; stdcall;
{$EXTERNALSYM GdipGetPathGradientTransform}
function GdipSetPathGradientTransform(brush: GpPathGradient;
     matrix: GpMatrix): TStatus; stdcall;
{$EXTERNALSYM GdipSetPathGradientTransform}
function GdipResetPathGradientTransform(brush: GpPathGradient): TStatus; stdcall;
{$EXTERNALSYM GdipResetPathGradientTransform}
function GdipMultiplyPathGradientTransform(brush: GpPathGradient;
     const matrix: GpMatrix; order: TMatrixOrder): TStatus; stdcall;
{$EXTERNALSYM GdipMultiplyPathGradientTransform}
function GdipTranslatePathGradientTransform(brush: GpPathGradient;
     dx: TREAL; dy: TREAL; order: TMatrixOrder): TStatus; stdcall;
{$EXTERNALSYM GdipTranslatePathGradientTransform}
function GdipScalePathGradientTransform(brush: GpPathGradient; sx: TREAL;
     sy: TREAL; order: TMatrixOrder): TStatus; stdcall;
{$EXTERNALSYM GdipScalePathGradientTransform}
function GdipRotatePathGradientTransform(brush: GpPathGradient;
     angle: TREAL; order: TMatrixOrder): TStatus; stdcall;
{$EXTERNALSYM GdipRotatePathGradientTransform}
function GdipGetPathGradientFocusScales(brush: GpPathGradient;
     var xScale: TREAL; var yScale: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipGetPathGradientFocusScales}
function GdipSetPathGradientFocusScales(brush: GpPathGradient;
     xScale: TREAL; yScale: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipSetPathGradientFocusScales}
function GdipCreatePen1(color: TARGB; width: TREAL;
     _unit: TUnit; var pen: GpPen): TStatus; stdcall;
{$EXTERNALSYM GdipCreatePen1}
function GdipCreatePen2(brush: GpBrush; width: TREAL;
     _unit: TUnit; var pen: GpPen): TStatus; stdcall;
{$EXTERNALSYM GdipCreatePen2}
function GdipClonePen(pen: GpPen; var clonepen: GpPen): TStatus; stdcall;
{$EXTERNALSYM GdipClonePen}
function GdipDeletePen(pen: GpPen): TStatus; stdcall;
{$EXTERNALSYM GdipDeletePen}
function GdipSetPenWidth(pen: GpPen; width: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipSetPenWidth}
function GdipGetPenWidth(pen: GpPen; var width: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipGetPenWidth}
function GdipSetPenUnit(pen: GpPen; _unit: TUnit): TStatus; stdcall;
{$EXTERNALSYM GdipSetPenUnit}
function GdipGetPenUnit(pen: GpPen; var _unit: TUnit): TStatus; stdcall;
{$EXTERNALSYM GdipGetPenUnit}
function GdipSetPenLineCap197819(pen: GpPen; startCap: TLineCap;
     endCap: TLineCap; dashCap: TDashCap): TStatus; stdcall;
{$EXTERNALSYM GdipSetPenLineCap197819}
function GdipSetPenStartCap(pen: GpPen; startCap: TLineCap): TStatus; stdcall;
{$EXTERNALSYM GdipSetPenStartCap}
function GdipSetPenEndCap(pen: GpPen; endCap: TLineCap): TStatus; stdcall;
{$EXTERNALSYM GdipSetPenEndCap}
function GdipSetPenDashCap197819(pen: GpPen; dashCap: TDashCap): TStatus; stdcall;
{$EXTERNALSYM GdipSetPenDashCap197819}
function GdipGetPenStartCap(pen: GpPen; var startCap: TLineCap): TStatus; stdcall;
{$EXTERNALSYM GdipGetPenStartCap}
function GdipGetPenEndCap(pen: GpPen; var endCap: TLineCap): TStatus; stdcall;
{$EXTERNALSYM GdipGetPenEndCap}
function GdipGetPenDashCap197819(pen: GpPen; var dashCap: TDashCap): TStatus; stdcall;
{$EXTERNALSYM GdipGetPenDashCap197819}
function GdipSetPenLineJoin(pen: GpPen; lineJoin: TLineJoin): TStatus; stdcall;
{$EXTERNALSYM GdipSetPenLineJoin}
function GdipGetPenLineJoin(pen: GpPen; var lineJoin: TLineJoin): TStatus; stdcall;
{$EXTERNALSYM GdipGetPenLineJoin}
function GdipSetPenCustomStartCap(pen: GpPen; customCap: GpCustomLineCap): TStatus; stdcall;
{$EXTERNALSYM GdipSetPenCustomStartCap}
function GdipGetPenCustomStartCap(pen: GpPen; var customCap: GpCustomLineCap): TStatus; stdcall;
{$EXTERNALSYM GdipGetPenCustomStartCap}
function GdipSetPenCustomEndCap(pen: GpPen; customCap: GpCustomLineCap): TStatus; stdcall;
{$EXTERNALSYM GdipSetPenCustomEndCap}
function GdipGetPenCustomEndCap(pen: GpPen; var customCap: GpCustomLineCap): TStatus; stdcall;
{$EXTERNALSYM GdipGetPenCustomEndCap}
function GdipSetPenMiterLimit(pen: GpPen; miterLimit: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipSetPenMiterLimit}
function GdipGetPenMiterLimit(pen: GpPen; var miterLimit: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipGetPenMiterLimit}
function GdipSetPenMode(pen: GpPen; penMode: TPenAlignment): TStatus; stdcall;
{$EXTERNALSYM GdipSetPenMode}
function GdipGetPenMode(pen: GpPen; var penMode: TPenAlignment): TStatus; stdcall;
{$EXTERNALSYM GdipGetPenMode}
function GdipSetPenTransform(pen: GpPen; matrix: GpMatrix): TStatus; stdcall;
{$EXTERNALSYM GdipSetPenTransform}
function GdipGetPenTransform(pen: GpPen; matrix: GpMatrix): TStatus; stdcall;
{$EXTERNALSYM GdipGetPenTransform}
function GdipResetPenTransform(pen: GpPen): TStatus; stdcall;
{$EXTERNALSYM GdipResetPenTransform}
function GdipMultiplyPenTransform(pen: GpPen; const matrix: GpMatrix;
     order: TMatrixOrder): TStatus; stdcall;
{$EXTERNALSYM GdipMultiplyPenTransform}
function GdipTranslatePenTransform(pen: GpPen; dx: TREAL;
     dy: TREAL; order: TMatrixOrder): TStatus; stdcall;
{$EXTERNALSYM GdipTranslatePenTransform}
function GdipScalePenTransform(pen: GpPen; sx: TREAL;
     sy: TREAL; order: TMatrixOrder): TStatus; stdcall;
{$EXTERNALSYM GdipScalePenTransform}
function GdipRotatePenTransform(pen: GpPen; angle: TREAL;
     order: TMatrixOrder): TStatus; stdcall;
{$EXTERNALSYM GdipRotatePenTransform}
function GdipSetPenColor(pen: GpPen; TARGB: TARGB): TStatus; stdcall;
{$EXTERNALSYM GdipSetPenColor}
function GdipGetPenColor(pen: GpPen; TARGB: PARGB): TStatus; stdcall;
{$EXTERNALSYM GdipGetPenColor}
function GdipSetPenBrushFill(pen: GpPen; brush: GpBrush): TStatus; stdcall;
{$EXTERNALSYM GdipSetPenBrushFill}
function GdipGetPenBrushFill(pen: GpPen; var brush: GpBrush): TStatus; stdcall;
{$EXTERNALSYM GdipGetPenBrushFill}
function GdipGetPenFillType(pen: GpPen; var ptype: TPenType): TStatus; stdcall;
{$EXTERNALSYM GdipGetPenFillType}
function GdipGetPenDashStyle(pen: GpPen; var dashstyle: TDashStyle): TStatus; stdcall;
{$EXTERNALSYM GdipGetPenDashStyle}
function GdipSetPenDashStyle(pen: GpPen; dashstyle: TDashStyle): TStatus; stdcall;
{$EXTERNALSYM GdipSetPenDashStyle}
function GdipGetPenDashOffset(pen: GpPen; var offset: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipGetPenDashOffset}
function GdipSetPenDashOffset(pen: GpPen; offset: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipSetPenDashOffset}
function GdipGetPenDashCount(pen: GpPen; var count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipGetPenDashCount}
function GdipSetPenDashArray(pen: GpPen; const dash: PREAL;
     count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipSetPenDashArray}
function GdipGetPenDashArray(pen: GpPen; dash: PREAL; count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipGetPenDashArray}
function GdipGetPenCompoundCount(pen: GpPen; var count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipGetPenCompoundCount}
function GdipSetPenCompoundArray(pen: GpPen; const dash: PREAL;
     count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipSetPenCompoundArray}
function GdipGetPenCompoundArray(pen: GpPen; dash: PREAL; count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipGetPenCompoundArray}
function GdipCreateCustomLineCap(fillPath: GpPath; strokePath: GpPath; baseCap: TLineCap;
     baseInset: TREAL; var customCap: GpCustomLineCap): TStatus; stdcall;
{$EXTERNALSYM GdipCreateCustomLineCap}
function GdipDeleteCustomLineCap(customCap: GpCustomLineCap): TStatus; stdcall;
{$EXTERNALSYM GdipDeleteCustomLineCap}
function GdipCloneCustomLineCap(customCap: GpCustomLineCap;
     var clonedCap: GpCustomLineCap): TStatus; stdcall;
{$EXTERNALSYM GdipCloneCustomLineCap}
function GdipGetCustomLineCapType(customCap: GpCustomLineCap;
     var capType: TCustomLineCapType): TStatus; stdcall;
{$EXTERNALSYM GdipGetCustomLineCapType}
function GdipSetCustomLineCapStrokeCaps(customCap: GpCustomLineCap;
     startCap: TLineCap; endCap: TLineCap): TStatus; stdcall;
{$EXTERNALSYM GdipSetCustomLineCapStrokeCaps}
function GdipGetCustomLineCapStrokeCaps(customCap: GpCustomLineCap;
     var startCap: TLineCap; var endCap: TLineCap): TStatus; stdcall;
{$EXTERNALSYM GdipGetCustomLineCapStrokeCaps}
function GdipSetCustomLineCapStrokeJoin(customCap: GpCustomLineCap;
     lineJoin: TLineJoin): TStatus; stdcall;
{$EXTERNALSYM GdipSetCustomLineCapStrokeJoin}
function GdipGetCustomLineCapStrokeJoin(customCap: GpCustomLineCap;
     var lineJoin: TLineJoin): TStatus; stdcall;
{$EXTERNALSYM GdipGetCustomLineCapStrokeJoin}
function GdipSetCustomLineCapBaseCap(customCap: GpCustomLineCap;
     baseCap: TLineCap): TStatus; stdcall;
{$EXTERNALSYM GdipSetCustomLineCapBaseCap}
function GdipGetCustomLineCapBaseCap(customCap: GpCustomLineCap;
     var baseCap: TLineCap): TStatus; stdcall;
{$EXTERNALSYM GdipGetCustomLineCapBaseCap}
function GdipSetCustomLineCapBaseInset(customCap: GpCustomLineCap;
     inset: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipSetCustomLineCapBaseInset}
function GdipGetCustomLineCapBaseInset(customCap: GpCustomLineCap;
     var inset: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipGetCustomLineCapBaseInset}
function GdipSetCustomLineCapWidthScale(customCap: GpCustomLineCap;
     widthScale: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipSetCustomLineCapWidthScale}
function GdipGetCustomLineCapWidthScale(customCap: GpCustomLineCap;
     var widthScale: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipGetCustomLineCapWidthScale}
function GdipCreateAdjustableArrowCap(height: TREAL; width: TREAL;
     isFilled: BOOL; var cap: GpAdjustableArrowCap): TStatus; stdcall;
{$EXTERNALSYM GdipCreateAdjustableArrowCap}
function GdipSetAdjustableArrowCapHeight(cap: GpAdjustableArrowCap;
     height: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipSetAdjustableArrowCapHeight}
function GdipGetAdjustableArrowCapHeight(cap: GpAdjustableArrowCap;
     var height: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipGetAdjustableArrowCapHeight}
function GdipSetAdjustableArrowCapWidth(cap: GpAdjustableArrowCap;
     width: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipSetAdjustableArrowCapWidth}
function GdipGetAdjustableArrowCapWidth(cap: GpAdjustableArrowCap;
     var width: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipGetAdjustableArrowCapWidth}
function GdipSetAdjustableArrowCapMiddleInset(cap: GpAdjustableArrowCap;
     middleInset: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipSetAdjustableArrowCapMiddleInset}
function GdipGetAdjustableArrowCapMiddleInset(cap: GpAdjustableArrowCap;
     var middleInset: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipGetAdjustableArrowCapMiddleInset}
function GdipSetAdjustableArrowCapFillState(cap: GpAdjustableArrowCap;
     fillState: BOOL): TStatus; stdcall;
{$EXTERNALSYM GdipSetAdjustableArrowCapFillState}
function GdipGetAdjustableArrowCapFillState(cap: GpAdjustableArrowCap;
     var fillState: BOOL): TStatus; stdcall;
{$EXTERNALSYM GdipGetAdjustableArrowCapFillState}
function GdipLoadImageFromStream(stream: ISTREAM; var image: GpImage): TStatus; stdcall;
{$EXTERNALSYM GdipLoadImageFromStream}
function GdipLoadImageFromFile(const filename: PWCHAR;
     var image: GpImage): TStatus; stdcall;
{$EXTERNALSYM GdipLoadImageFromFile}
function GdipLoadImageFromStreamICM(stream: ISTREAM;
     var image: GpImage): TStatus; stdcall;
{$EXTERNALSYM GdipLoadImageFromStreamICM}
function GdipLoadImageFromFileICM(const filename: PWCHAR;
     var image: GpImage): TStatus; stdcall;
{$EXTERNALSYM GdipLoadImageFromFileICM}
function GdipCloneImage(image: GpImage; var cloneImage: GpImage): TStatus; stdcall;
{$EXTERNALSYM GdipCloneImage}
function GdipDisposeImage(image: GpImage): TStatus; stdcall;
{$EXTERNALSYM GdipDisposeImage}
function GdipSaveImageToFile(image: GpImage; const filename: PWCHAR; const clsidEncoder: PGUID;
     const encoderParams: PEncoderParameters): TStatus; stdcall;
{$EXTERNALSYM GdipSaveImageToFile}
function GdipSaveImageToStream(image: GpImage; stream: ISTREAM; const clsidEncoder: PGUID;
     const encoderParams: PEncoderParameters): TStatus; stdcall;
{$EXTERNALSYM GdipSaveImageToStream}
function GdipSaveAdd(image: GpImage; const encoderParams: PEncoderParameters): TStatus; stdcall;
{$EXTERNALSYM GdipSaveAdd}
function GdipSaveAddImage(image: GpImage; newImage: GpImage;
     const encoderParams: PEncoderParameters): TStatus; stdcall;
{$EXTERNALSYM GdipSaveAddImage}
function GdipGetImageGraphicsContext(image: GpImage;
     var graphics: GpGraphics): TStatus; stdcall;
{$EXTERNALSYM GdipGetImageGraphicsContext}
function GdipGetImageBounds(image: GpImage; srcRect: PRectF;
     var srcUnit: TUnit): TStatus; stdcall;
{$EXTERNALSYM GdipGetImageBounds}
function GdipGetImageDimension(image: GpImage; var width: TREAL;
     var height: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipGetImageDimension}
function GdipGetImageType(image: GpImage; var itype: TImageType): TStatus; stdcall;
{$EXTERNALSYM GdipGetImageType}
function GdipGetImageWidth(image: GpImage; var width: INT): TStatus; stdcall;
{$EXTERNALSYM GdipGetImageWidth}
function GdipGetImageHeight(image: GpImage; var height: INT): TStatus; stdcall;
{$EXTERNALSYM GdipGetImageHeight}
function GdipGetImageHorizontalResolution(image: GpImage;
     var resolution: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipGetImageHorizontalResolution}
function GdipGetImageVerticalResolution(image: GpImage;
     var resolution: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipGetImageVerticalResolution}
function GdipGetImageFlags(image: GpImage; var flags: INT): TStatus; stdcall;
{$EXTERNALSYM GdipGetImageFlags}
function GdipGetImageRawFormat(image: GpImage; format: PGUID): TStatus; stdcall;
{$EXTERNALSYM GdipGetImageRawFormat}
function GdipGetImagePixelFormat(image: GpImage;
     var format: TPixelFormat): TStatus; stdcall;
{$EXTERNALSYM GdipGetImagePixelFormat}
function GdipGetImageThumbnail(image: GpImage; thumbWidth: INT; thumbHeight: INT; var thumbImage: GpImage;
     callback: TGetThumbnailImageAbort; callbackData: Pointer): TStatus; stdcall;
{$EXTERNALSYM GdipGetImageThumbnail}
function GdipGetEncoderParameterListSize(image: GpImage; const clsidEncoder: PGUID;
     var size: INT): TStatus; stdcall;
{$EXTERNALSYM GdipGetEncoderParameterListSize}
function GdipGetEncoderParameterList(image: GpImage; const clsidEncoder: PGUID;
     size: INT; buffer: PEncoderParameters): TStatus; stdcall;
{$EXTERNALSYM GdipGetEncoderParameterList}
function GdipImageGetFrameDimensionsCount(image: GpImage;
     var count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipImageGetFrameDimensionsCount}
function GdipImageGetFrameDimensionsList(image: GpImage;
     dimensionIDs: PGUID; count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipImageGetFrameDimensionsList}
function GdipImageGetFrameCount(image: GpImage; const dimensionID: PGUID;
     var count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipImageGetFrameCount}
function GdipImageSelectActiveFrame(image: GpImage; const dimensionID: PGUID;
     frameIndex: INT): TStatus; stdcall;
{$EXTERNALSYM GdipImageSelectActiveFrame}
function GdipImageRotateFlip(image: GpImage; rfType: TRotateFlipType): TStatus; stdcall;
{$EXTERNALSYM GdipImageRotateFlip}
function GdipGetImagePalette(image: GpImage; palette: PColorPalette;
     size: INT): TStatus; stdcall;
{$EXTERNALSYM GdipGetImagePalette}
function GdipSetImagePalette(image: GpImage; const palette: PColorPalette): TStatus; stdcall;
{$EXTERNALSYM GdipSetImagePalette}
function GdipGetImagePaletteSize(image: GpImage; var size: INT): TStatus; stdcall;
{$EXTERNALSYM GdipGetImagePaletteSize}
function GdipGetPropertyCount(image: GpImage; var numOfProperty: INT): TStatus; stdcall;
{$EXTERNALSYM GdipGetPropertyCount}
function GdipGetPropertyIdList(image: GpImage; numOfProperty: INT;
     list: PPROPID): TStatus; stdcall;
{$EXTERNALSYM GdipGetPropertyIdList}
function GdipGetPropertyItemSize(image: GpImage; propId: PROPID;
     var size: INT): TStatus; stdcall;
{$EXTERNALSYM GdipGetPropertyItemSize}
function GdipGetPropertyItem(image: GpImage; propId: PROPID;
     propSize: INT; buffer: PPropertyItem): TStatus; stdcall;
{$EXTERNALSYM GdipGetPropertyItem}
function GdipGetPropertySize(image: GpImage; var totalBufferSize: INT;
     var numProperties: INT): TStatus; stdcall;
{$EXTERNALSYM GdipGetPropertySize}
function GdipGetAllPropertyItems(image: GpImage; totalBufferSize: INT;
     numProperties: INT; allItems: PPropertyItem): TStatus; stdcall;
{$EXTERNALSYM GdipGetAllPropertyItems}
function GdipRemovePropertyItem(image: GpImage; propId: PROPID): TStatus; stdcall;
{$EXTERNALSYM GdipRemovePropertyItem}
function GdipSetPropertyItem(image: GpImage; const item: PPropertyItem): TStatus; stdcall;
{$EXTERNALSYM GdipSetPropertyItem}
function GdipImageForceValidation(image: GpImage): TStatus; stdcall;
{$EXTERNALSYM GdipImageForceValidation}
function GdipCreateBitmapFromStream(stream: ISTREAM;
     var bitmap: GpBitmap): TStatus; stdcall;
{$EXTERNALSYM GdipCreateBitmapFromStream}
function GdipCreateBitmapFromFile(const filename: PWCHAR;
     var bitmap: GpBitmap): TStatus; stdcall;
{$EXTERNALSYM GdipCreateBitmapFromFile}
function GdipCreateBitmapFromStreamICM(stream: ISTREAM;
     var bitmap: GpBitmap): TStatus; stdcall;
{$EXTERNALSYM GdipCreateBitmapFromStreamICM}
function GdipCreateBitmapFromFileICM(const filename: PWCHAR;
     var bitmap: GpBitmap): TStatus; stdcall;
{$EXTERNALSYM GdipCreateBitmapFromFileICM}
function GdipCreateBitmapFromScan0(width: INT; height: INT; stride: INT; format: TPixelFormat;
     scan0: PByte; var bitmap: GpBitmap): TStatus; stdcall;
{$EXTERNALSYM GdipCreateBitmapFromScan0}
function GdipCreateBitmapFromGraphics(width: INT; height: INT;
     target: GpGraphics; var bitmap: GpBitmap): TStatus; stdcall;
{$EXTERNALSYM GdipCreateBitmapFromGraphics}
function GdipCreateBitmapFromDirectDrawSurface(surface: GpDirectDrawSurface7;
     var bitmap: GpBitmap): TStatus; stdcall;
{$EXTERNALSYM GdipCreateBitmapFromDirectDrawSurface}
function GdipCreateBitmapFromGdiDib(const gdiBitmapInfo: PBitmapInfo;
     gdiBitmapData: Pointer; var bitmap: GpBitmap): TStatus; stdcall;
{$EXTERNALSYM GdipCreateBitmapFromGdiDib}
function GdipCreateBitmapFromHBITMAP(hbm: HBITMAP; hpal: HPALETTE;
     var bitmap: GpBitmap): TStatus; stdcall;
{$EXTERNALSYM GdipCreateBitmapFromHBITMAP}
function GdipCreateHBITMAPFromBitmap(bitmap: GpBitmap; var hbmReturn: HBITMAP;
     background: TARGB): TStatus; stdcall;
{$EXTERNALSYM GdipCreateHBITMAPFromBitmap}
function GdipCreateBitmapFromHICON(hicon: HICON; var bitmap: GpBitmap): TStatus; stdcall;
{$EXTERNALSYM GdipCreateBitmapFromHICON}
function GdipCreateHICONFromBitmap(bitmap: GpBitmap;
     var hbmReturn: HICON): TStatus; stdcall;
{$EXTERNALSYM GdipCreateHICONFromBitmap}
function GdipCreateBitmapFromResource(hInstance: HMODULE; const lpBitmapName: PWCHAR;
     var bitmap: GpBitmap): TStatus; stdcall;
{$EXTERNALSYM GdipCreateBitmapFromResource}
function GdipCloneBitmapArea(x: TREAL; y: TREAL; width: TREAL; height: TREAL; format: TPixelFormat;
     srcBitmap: GpBitmap; var dstBitmap: GpBitmap): TStatus; stdcall;
{$EXTERNALSYM GdipCloneBitmapArea}
function GdipCloneBitmapAreaI(x: INT; y: INT; width: INT; height: INT; format: TPixelFormat;
     srcBitmap: GpBitmap; var dstBitmap: GpBitmap): TStatus; stdcall;
{$EXTERNALSYM GdipCloneBitmapAreaI}
function GdipBitmapLockBits(bitmap: GpBitmap; const rect: PRect; flags: INT;
     format: TPixelFormat; lockedBitmapData: PBitmapData): TStatus; stdcall;
{$EXTERNALSYM GdipBitmapLockBits}
function GdipBitmapUnlockBits(bitmap: GpBitmap; lockedBitmapData: PBitmapData): TStatus; stdcall;
{$EXTERNALSYM GdipBitmapUnlockBits}
function GdipBitmapGetPixel(bitmap: GpBitmap; x: INT;
     y: INT; color: PARGB): TStatus; stdcall;
{$EXTERNALSYM GdipBitmapGetPixel}
function GdipBitmapSetPixel(bitmap: GpBitmap; x: INT;
     y: INT; color: TARGB): TStatus; stdcall;
{$EXTERNALSYM GdipBitmapSetPixel}
function GdipBitmapSetResolution(bitmap: GpBitmap;
     xdpi: TREAL; ydpi: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipBitmapSetResolution}
function GdipCreateImageAttributes(var imageattr: GpImageAttributes): TStatus; stdcall;
{$EXTERNALSYM GdipCreateImageAttributes}
function GdipCloneImageAttributes(const imageattr: GpImageAttributes;
     var cloneImageattr: GpImageAttributes): TStatus; stdcall;
{$EXTERNALSYM GdipCloneImageAttributes}
function GdipDisposeImageAttributes(imageattr: GpImageAttributes): TStatus; stdcall;
{$EXTERNALSYM GdipDisposeImageAttributes}
function GdipSetImageAttributesToIdentity(imageattr: GpImageAttributes;
     itype: TColorAdjustType): TStatus; stdcall;
{$EXTERNALSYM GdipSetImageAttributesToIdentity}
function GdipResetImageAttributes(imageattr: GpImageAttributes;
     itype: TColorAdjustType): TStatus; stdcall;
{$EXTERNALSYM GdipResetImageAttributes}
function GdipSetImageAttributesColorMatrix(imageattr: GpImageAttributes; itype: TColorAdjustType; enableFlag: BOOL;
     const colorMatrix: PColorMatrix; const grayMatrix: PColorMatrix; flags: TColorMatrixFlags): TStatus; stdcall;
{$EXTERNALSYM GdipSetImageAttributesColorMatrix}
function GdipSetImageAttributesThreshold(imageattr: GpImageAttributes; itype: TColorAdjustType;
     enableFlag: BOOL; threshold: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipSetImageAttributesThreshold}
function GdipSetImageAttributesGamma(imageattr: GpImageAttributes; itype: TColorAdjustType;
     enableFlag: BOOL; gamma: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipSetImageAttributesGamma}
function GdipSetImageAttributesNoOp(imageattr: GpImageAttributes;
     itype: TColorAdjustType; enableFlag: BOOL): TStatus; stdcall;
{$EXTERNALSYM GdipSetImageAttributesNoOp}
function GdipSetImageAttributesColorKeys(imageattr: GpImageAttributes; itype: TColorAdjustType;
     enableFlag: BOOL; colorLow: TARGB; colorHigh: TARGB): TStatus; stdcall;
{$EXTERNALSYM GdipSetImageAttributesColorKeys}
function GdipSetImageAttributesOutputChannel(imageattr: GpImageAttributes; itype: TColorAdjustType;
     enableFlag: BOOL; channelFlags: TColorChannelFlags): TStatus; stdcall;
{$EXTERNALSYM GdipSetImageAttributesOutputChannel}
function GdipSetImageAttributesOutputChannelColorProfile(imageattr: GpImageAttributes; itype: TColorAdjustType;
     enableFlag: BOOL; const colorProfileFilename: PWCHAR): TStatus; stdcall;
{$EXTERNALSYM GdipSetImageAttributesOutputChannelColorProfile}
function GdipSetImageAttributesRemapTable(imageattr: GpImageAttributes; itype: TColorAdjustType;
     enableFlag: BOOL; mapSize: INT; const map: PColorMap): TStatus; stdcall;
{$EXTERNALSYM GdipSetImageAttributesRemapTable}
function GdipSetImageAttributesWrapMode(imageAttr: GpImageAttributes;
     wrap: TWrapMode; TARGB: TARGB; clamp: BOOL): TStatus; stdcall;
{$EXTERNALSYM GdipSetImageAttributesWrapMode}
function GdipSetImageAttributesICMMode(imageAttr: GpImageAttributes;
     on_: BOOL): TStatus; stdcall;
{$EXTERNALSYM GdipSetImageAttributesICMMode}
function GdipGetImageAttributesAdjustedPalette(imageAttr: GpImageAttributes; colorPalette: PColorPalette;
     colorAdjustType: TColorAdjustType): TStatus; stdcall;
{$EXTERNALSYM GdipGetImageAttributesAdjustedPalette}
function GdipFlush(graphics: GpGraphics; intention: TFlushIntention): TStatus; stdcall;
{$EXTERNALSYM GdipFlush}
function GdipCreateFromHDC(hdc: HDC; var graphics: GpGraphics): TStatus; stdcall;
{$EXTERNALSYM GdipCreateFromHDC}
function GdipCreateFromHDC2(hdc: HDC; hDevice: THANDLE;
     var graphics: GpGraphics): TStatus; stdcall;
{$EXTERNALSYM GdipCreateFromHDC2}
function GdipCreateFromHWND(hwnd: HWND; var graphics: GpGraphics): TStatus; stdcall;
{$EXTERNALSYM GdipCreateFromHWND}
function GdipCreateFromHWNDICM(hwnd: HWND; var graphics: GpGraphics): TStatus; stdcall;
{$EXTERNALSYM GdipCreateFromHWNDICM}
function GdipDeleteGraphics(graphics: GpGraphics): TStatus; stdcall;
{$EXTERNALSYM GdipDeleteGraphics}
function GdipGetDC(graphics: GpGraphics; var hdc: HDC): TStatus; stdcall;
{$EXTERNALSYM GdipGetDC}
function GdipReleaseDC(graphics: GpGraphics; hdc: HDC): TStatus; stdcall;
{$EXTERNALSYM GdipReleaseDC}
function GdipSetCompositingMode(graphics: GpGraphics; compositingMode: TCompositingMode): TStatus; stdcall;
{$EXTERNALSYM GdipSetCompositingMode}
function GdipGetCompositingMode(graphics: GpGraphics; var compositingMode: TCompositingMode): TStatus; stdcall;
{$EXTERNALSYM GdipGetCompositingMode}
function GdipSetRenderingOrigin(graphics: GpGraphics; x: INT; y: INT): TStatus; stdcall;
{$EXTERNALSYM GdipSetRenderingOrigin}
function GdipGetRenderingOrigin(graphics: GpGraphics;
     var x: INT; var y: INT): TStatus; stdcall;
{$EXTERNALSYM GdipGetRenderingOrigin}
function GdipSetCompositingQuality(graphics: GpGraphics; compositingQuality: TCompositingQuality): TStatus; stdcall;
{$EXTERNALSYM GdipSetCompositingQuality}
function GdipGetCompositingQuality(graphics: GpGraphics; var compositingQuality: TCompositingQuality): TStatus; stdcall;
{$EXTERNALSYM GdipGetCompositingQuality}
function GdipSetSmoothingMode(graphics: GpGraphics;
     smoothingMode: TSmoothingMode): TStatus; stdcall;
{$EXTERNALSYM GdipSetSmoothingMode}
function GdipGetSmoothingMode(graphics: GpGraphics; var smoothingMode: TSmoothingMode): TStatus; stdcall;
{$EXTERNALSYM GdipGetSmoothingMode}
function GdipSetPixelOffsetMode(graphics: GpGraphics; pixelOffsetMode: TPixelOffsetMode): TStatus; stdcall;
{$EXTERNALSYM GdipSetPixelOffsetMode}
function GdipGetPixelOffsetMode(graphics: GpGraphics; var pixelOffsetMode: TPixelOffsetMode): TStatus; stdcall;
{$EXTERNALSYM GdipGetPixelOffsetMode}
function GdipSetTextRenderingHint(graphics: GpGraphics;
     mode: TTextRenderingHint): TStatus; stdcall;
{$EXTERNALSYM GdipSetTextRenderingHint}
function GdipGetTextRenderingHint(graphics: GpGraphics;
     var mode: TTextRenderingHint): TStatus; stdcall;
{$EXTERNALSYM GdipGetTextRenderingHint}
function GdipSetTextContrast(graphics: GpGraphics; contrast: INT): TStatus; stdcall;
{$EXTERNALSYM GdipSetTextContrast}
function GdipGetTextContrast(graphics: GpGraphics; var contrast: INT): TStatus; stdcall;
{$EXTERNALSYM GdipGetTextContrast}
function GdipSetInterpolationMode(graphics: GpGraphics; interpolationMode: TInterpolationMode): TStatus; stdcall;
{$EXTERNALSYM GdipSetInterpolationMode}
function GdipGetInterpolationMode(graphics: GpGraphics; var interpolationMode: TInterpolationMode): TStatus; stdcall;
{$EXTERNALSYM GdipGetInterpolationMode}
function GdipSetWorldTransform(graphics: GpGraphics; matrix: GpMatrix): TStatus; stdcall;
{$EXTERNALSYM GdipSetWorldTransform}
function GdipResetWorldTransform(graphics: GpGraphics): TStatus; stdcall;
{$EXTERNALSYM GdipResetWorldTransform}
function GdipMultiplyWorldTransform(graphics: GpGraphics; const matrix: GpMatrix;
     order: TMatrixOrder): TStatus; stdcall;
{$EXTERNALSYM GdipMultiplyWorldTransform}
function GdipTranslateWorldTransform(graphics: GpGraphics; dx: TREAL;
     dy: TREAL; order: TMatrixOrder): TStatus; stdcall;
{$EXTERNALSYM GdipTranslateWorldTransform}
function GdipScaleWorldTransform(graphics: GpGraphics; sx: TREAL;
     sy: TREAL; order: TMatrixOrder): TStatus; stdcall;
{$EXTERNALSYM GdipScaleWorldTransform}
function GdipRotateWorldTransform(graphics: GpGraphics;
     angle: TREAL; order: TMatrixOrder): TStatus; stdcall;
{$EXTERNALSYM GdipRotateWorldTransform}
function GdipGetWorldTransform(graphics: GpGraphics; matrix: GpMatrix): TStatus; stdcall;
{$EXTERNALSYM GdipGetWorldTransform}
function GdipResetPageTransform(graphics: GpGraphics): TStatus; stdcall;
{$EXTERNALSYM GdipResetPageTransform}
function GdipGetPageUnit(graphics: GpGraphics; var unit_: TUnit): TStatus; stdcall;
{$EXTERNALSYM GdipGetPageUnit}
function GdipGetPageScale(graphics: GpGraphics; var scale: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipGetPageScale}
function GdipSetPageUnit(graphics: GpGraphics; unit_: TUnit): TStatus; stdcall;
{$EXTERNALSYM GdipSetPageUnit}
function GdipSetPageScale(graphics: GpGraphics; scale: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipSetPageScale}
function GdipGetDpiX(graphics: GpGraphics; var dpi: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipGetDpiX}
function GdipGetDpiY(graphics: GpGraphics; var dpi: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipGetDpiY}
function GdipTransformPoints(graphics: GpGraphics; destSpace: TCoordinateSpace;
     srcSpace: TCoordinateSpace; points: PPointF; count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipTransformPoints}
function GdipTransformPointsI(graphics: GpGraphics; destSpace: TCoordinateSpace;
     srcSpace: TCoordinateSpace; points: PPoint; count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipTransformPointsI}
function GdipGetNearestColor(graphics: GpGraphics; color: PARGB): TStatus; stdcall;
{$EXTERNALSYM GdipGetNearestColor}
function GdipCreateHalftonePalette: HPALETTE; stdcall;
{$EXTERNALSYM GdipCreateHalftonePalette}
function GdipDrawLine(graphics: GpGraphics; pen: GpPen; x1: TREAL;
     y1: TREAL; x2: TREAL; y2: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipDrawLine}
function GdipDrawLineI(graphics: GpGraphics; pen: GpPen;
     x1: INT; y1: INT; x2: INT; y2: INT): TStatus; stdcall;
{$EXTERNALSYM GdipDrawLineI}
function GdipDrawLines(graphics: GpGraphics; pen: GpPen;
     const points: PPointF; count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipDrawLines}
function GdipDrawLinesI(graphics: GpGraphics; pen: GpPen;
     const points: PPoint; count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipDrawLinesI}
function GdipDrawArc(graphics: GpGraphics; pen: GpPen; x: TREAL; y: TREAL; width: TREAL;
     height: TREAL; startAngle: TREAL; sweepAngle: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipDrawArc}
function GdipDrawArcI(graphics: GpGraphics; pen: GpPen; x: INT; y: INT; width: INT;
     height: INT; startAngle: TREAL; sweepAngle: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipDrawArcI}
function GdipDrawBezier(graphics: GpGraphics; pen: GpPen; x1: TREAL; y1: TREAL; x2: TREAL;
     y2: TREAL; x3: TREAL; y3: TREAL; x4: TREAL; y4: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipDrawBezier}
function GdipDrawBezierI(graphics: GpGraphics; pen: GpPen; x1: INT; y1: INT;
     x2: INT; y2: INT; x3: INT; y3: INT; x4: INT; y4: INT): TStatus; stdcall;
{$EXTERNALSYM GdipDrawBezierI}
function GdipDrawBeziers(graphics: GpGraphics; pen: GpPen;
     const points: PPointF; count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipDrawBeziers}
function GdipDrawBeziersI(graphics: GpGraphics; pen: GpPen;
     const points: PPoint; count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipDrawBeziersI}
function GdipDrawRectangle(graphics: GpGraphics; pen: GpPen; x: TREAL;
     y: TREAL; width: TREAL; height: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipDrawRectangle}
function GdipDrawRectangleI(graphics: GpGraphics; pen: GpPen;
     x: INT; y: INT; width: INT; height: INT): TStatus; stdcall;
{$EXTERNALSYM GdipDrawRectangleI}
function GdipDrawRectangles(graphics: GpGraphics; pen: GpPen;
     const rects: PRectF; count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipDrawRectangles}
function GdipDrawRectanglesI(graphics: GpGraphics; pen: GpPen;
     const rects: PRect; count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipDrawRectanglesI}
function GdipDrawEllipse(graphics: GpGraphics; pen: GpPen; x: TREAL;
     y: TREAL; width: TREAL; height: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipDrawEllipse}
function GdipDrawEllipseI(graphics: GpGraphics; pen: GpPen; x: INT;
     y: INT; width: INT; height: INT): TStatus; stdcall;
{$EXTERNALSYM GdipDrawEllipseI}
function GdipDrawPie(graphics: GpGraphics; pen: GpPen; x: TREAL; y: TREAL; width: TREAL;
     height: TREAL; startAngle: TREAL; sweepAngle: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipDrawPie}
function GdipDrawPieI(graphics: GpGraphics; pen: GpPen; x: INT; y: INT; width: INT;
     height: INT; startAngle: TREAL; sweepAngle: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipDrawPieI}
function GdipDrawPolygon(graphics: GpGraphics; pen: GpPen;
     const points: PPointF; count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipDrawPolygon}
function GdipDrawPolygonI(graphics: GpGraphics; pen: GpPen;
     const points: PPoint; count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipDrawPolygonI}
function GdipDrawPath(graphics: GpGraphics; pen: GpPen; path: GpPath): TStatus; stdcall;
{$EXTERNALSYM GdipDrawPath}
function GdipDrawCurve(graphics: GpGraphics; pen: GpPen;
     const points: PPointF; count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipDrawCurve}
function GdipDrawCurveI(graphics: GpGraphics; pen: GpPen;
     const points: PPoint; count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipDrawCurveI}
function GdipDrawCurve2(graphics: GpGraphics; pen: GpPen; const points: PPointF;
     count: INT; tension: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipDrawCurve2}
function GdipDrawCurve2I(graphics: GpGraphics; pen: GpPen; const points: PPoint;
     count: INT; tension: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipDrawCurve2I}
function GdipDrawCurve3(graphics: GpGraphics; pen: GpPen; const points: PPointF; count: INT;
     offset: INT; numberOfSegments: INT; tension: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipDrawCurve3}
function GdipDrawCurve3I(graphics: GpGraphics; pen: GpPen; const points: PPoint; count: INT;
     offset: INT; numberOfSegments: INT; tension: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipDrawCurve3I}
function GdipDrawClosedCurve(graphics: GpGraphics; pen: GpPen;
     const points: PPointF; count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipDrawClosedCurve}
function GdipDrawClosedCurveI(graphics: GpGraphics; pen: GpPen;
     const points: PPoint; count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipDrawClosedCurveI}
function GdipDrawClosedCurve2(graphics: GpGraphics; pen: GpPen; const points: PPointF;
     count: INT; tension: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipDrawClosedCurve2}
function GdipDrawClosedCurve2I(graphics: GpGraphics; pen: GpPen; const points: PPoint;
     count: INT; tension: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipDrawClosedCurve2I}
function GdipGraphicsClear(graphics: GpGraphics; color: TARGB): TStatus; stdcall;
{$EXTERNALSYM GdipGraphicsClear}
function GdipFillRectangle(graphics: GpGraphics; brush: GpBrush; x: TREAL;
     y: TREAL; width: TREAL; height: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipFillRectangle}
function GdipFillRectangleI(graphics: GpGraphics; brush: GpBrush;
     x: INT; y: INT; width: INT; height: INT): TStatus; stdcall;
{$EXTERNALSYM GdipFillRectangleI}
function GdipFillRectangles(graphics: GpGraphics; brush: GpBrush;
     const rects: PRectF; count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipFillRectangles}
function GdipFillRectanglesI(graphics: GpGraphics; brush: GpBrush;
     const rects: PRect; count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipFillRectanglesI}
function GdipFillPolygon(graphics: GpGraphics; brush: GpBrush; const points: PPointF;
     count: INT; fillMode: TFillMode): TStatus; stdcall;
{$EXTERNALSYM GdipFillPolygon}
function GdipFillPolygonI(graphics: GpGraphics; brush: GpBrush; const points: PPoint;
     count: INT; fillMode: TFillMode): TStatus; stdcall;
{$EXTERNALSYM GdipFillPolygonI}
function GdipFillPolygon2(graphics: GpGraphics; brush: GpBrush;
     const points: PPointF; count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipFillPolygon2}
function GdipFillPolygon2I(graphics: GpGraphics; brush: GpBrush;
     const points: PPoint; count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipFillPolygon2I}
function GdipFillEllipse(graphics: GpGraphics; brush: GpBrush; x: TREAL;
     y: TREAL; width: TREAL; height: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipFillEllipse}
function GdipFillEllipseI(graphics: GpGraphics; brush: GpBrush;
     x: INT; y: INT; width: INT; height: INT): TStatus; stdcall;
{$EXTERNALSYM GdipFillEllipseI}
function GdipFillPie(graphics: GpGraphics; brush: GpBrush; x: TREAL; y: TREAL; width: TREAL;
     height: TREAL; startAngle: TREAL; sweepAngle: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipFillPie}
function GdipFillPieI(graphics: GpGraphics; brush: GpBrush; x: INT; y: INT; width: INT;
     height: INT; startAngle: TREAL; sweepAngle: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipFillPieI}
function GdipFillPath(graphics: GpGraphics; brush: GpBrush;
     path: GpPath): TStatus; stdcall;
{$EXTERNALSYM GdipFillPath}
function GdipFillClosedCurve(graphics: GpGraphics; brush: GpBrush;
     const points: PPointF; count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipFillClosedCurve}
function GdipFillClosedCurveI(graphics: GpGraphics; brush: GpBrush;
     const points: PPoint; count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipFillClosedCurveI}
function GdipFillClosedCurve2(graphics: GpGraphics; brush: GpBrush; const points: PPointF;
     count: INT; tension: TREAL; fillMode: TFillMode): TStatus; stdcall;
{$EXTERNALSYM GdipFillClosedCurve2}
function GdipFillClosedCurve2I(graphics: GpGraphics; brush: GpBrush; const points: PPoint;
     count: INT; tension: TREAL; fillMode: TFillMode): TStatus; stdcall;
{$EXTERNALSYM GdipFillClosedCurve2I}
function GdipFillRegion(graphics: GpGraphics; brush: GpBrush;
     region: GpRegion): TStatus; stdcall;
{$EXTERNALSYM GdipFillRegion}
function GdipDrawImage(graphics: GpGraphics; image: GpImage;
     x: TREAL; y: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipDrawImage}
function GdipDrawImageI(graphics: GpGraphics; image: GpImage;
     x: INT; y: INT): TStatus; stdcall;
{$EXTERNALSYM GdipDrawImageI}
function GdipDrawImageRect(graphics: GpGraphics; image: GpImage; x: TREAL;
     y: TREAL; width: TREAL; height: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipDrawImageRect}
function GdipDrawImageRectI(graphics: GpGraphics; image: GpImage;
     x: INT; y: INT; width: INT; height: INT): TStatus; stdcall;
{$EXTERNALSYM GdipDrawImageRectI}
function GdipDrawImagePoints(graphics: GpGraphics; image: GpImage;
     const dstpoints: PPointF; count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipDrawImagePoints}
function GdipDrawImagePointsI(graphics: GpGraphics; image: GpImage;
     const dstpoints: PPoint; count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipDrawImagePointsI}
function GdipDrawImagePointRect(graphics: GpGraphics; image: GpImage; x: TREAL; y: TREAL; srcx: TREAL;
     srcy: TREAL; srcwidth: TREAL; srcheight: TREAL; srcUnit: TUnit): TStatus; stdcall;
{$EXTERNALSYM GdipDrawImagePointRect}
function GdipDrawImagePointRectI(graphics: GpGraphics; image: GpImage; x: INT; y: INT; srcx: INT;
     srcy: INT; srcwidth: INT; srcheight: INT; srcUnit: TUnit): TStatus; stdcall;
{$EXTERNALSYM GdipDrawImagePointRectI}
function GdipDrawImageRectRect(graphics: GpGraphics; image: GpImage; dstx: TREAL; dsty: TREAL; dstwidth: TREAL; dstheight: TREAL; srcx: TREAL; srcy: TREAL; srcwidth: TREAL;
     srcheight: TREAL; srcUnit: TUnit; const imageAttributes: GpImageAttributes; callback: TDrawImageAbort; callbackData: Pointer): TStatus; stdcall;
{$EXTERNALSYM GdipDrawImageRectRect}
function GdipDrawImageRectRectI(graphics: GpGraphics; image: GpImage; dstx: INT; dsty: INT; dstwidth: INT; dstheight: INT; srcx: INT; srcy: INT; srcwidth: INT;
     srcheight: INT; srcUnit: TUnit; const imageAttributes: GpImageAttributes; callback: TDrawImageAbort; callbackData: Pointer): TStatus; stdcall;
{$EXTERNALSYM GdipDrawImageRectRectI}
function GdipDrawImagePointsRect(graphics: GpGraphics; image: GpImage; const points: PPointF; count: INT; srcx: TREAL; srcy: TREAL; srcwidth: TREAL;
     srcheight: TREAL; srcUnit: TUnit; const imageAttributes: GpImageAttributes; callback: TDrawImageAbort; callbackData: Pointer): TStatus; stdcall;
{$EXTERNALSYM GdipDrawImagePointsRect}
function GdipDrawImagePointsRectI(graphics: GpGraphics; image: GpImage; const points: PPoint; count: INT; srcx: INT; srcy: INT; srcwidth: INT; srcheight: INT;
     srcUnit: TUnit; const imageAttributes: GpImageAttributes; callback: TDrawImageAbort; callbackData: Pointer): TStatus; stdcall;
{$EXTERNALSYM GdipDrawImagePointsRectI}
function GdipEnumerateMetafileDestPoint(graphics: GpGraphics; const metafile: GpMetafile; const destPoint: PPointF; callback: TEnumerateMetafileProc;
     callbackData: Pointer; const imageAttributes: GpImageAttributes): TStatus; stdcall;
{$EXTERNALSYM GdipEnumerateMetafileDestPoint}
function GdipEnumerateMetafileDestPointI(graphics: GpGraphics; const metafile: GpMetafile; const destPoint: PPoint; callback: TEnumerateMetafileProc;
     callbackData: Pointer; const imageAttributes: GpImageAttributes): TStatus; stdcall;
{$EXTERNALSYM GdipEnumerateMetafileDestPointI}
function GdipEnumerateMetafileDestRect(graphics: GpGraphics; const metafile: GpMetafile; const destRect: PRectF; callback: TEnumerateMetafileProc;
     callbackData: Pointer; const imageAttributes: GpImageAttributes): TStatus; stdcall;
{$EXTERNALSYM GdipEnumerateMetafileDestRect}
function GdipEnumerateMetafileDestRectI(graphics: GpGraphics; const metafile: GpMetafile; const destRect: PRect; callback: TEnumerateMetafileProc;
     callbackData: Pointer; const imageAttributes: GpImageAttributes): TStatus; stdcall;
{$EXTERNALSYM GdipEnumerateMetafileDestRectI}
function GdipEnumerateMetafileDestPoints(graphics: GpGraphics; const metafile: GpMetafile; const destPoints: PPointF; count: INT;
     callback: TEnumerateMetafileProc; callbackData: Pointer; const imageAttributes: GpImageAttributes): TStatus; stdcall;
{$EXTERNALSYM GdipEnumerateMetafileDestPoints}
function GdipEnumerateMetafileDestPointsI(graphics: GpGraphics; const metafile: GpMetafile; const destPoints: PPoint; count: INT;
     callback: TEnumerateMetafileProc; callbackData: Pointer; const imageAttributes: GpImageAttributes): TStatus; stdcall;
{$EXTERNALSYM GdipEnumerateMetafileDestPointsI}
function GdipEnumerateMetafileSrcRectDestPoint(graphics: GpGraphics; const metafile: GpMetafile; const destPoint: PPointF; const srcRect: PRectF;
     srcUnit: TUnit; callback: TEnumerateMetafileProc; callbackData: Pointer; const imageAttributes: GpImageAttributes): TStatus; stdcall;
{$EXTERNALSYM GdipEnumerateMetafileSrcRectDestPoint}
function GdipEnumerateMetafileSrcRectDestPointI(graphics: GpGraphics; const metafile: GpMetafile; const destPoint: PPoint; const srcRect: PRect;
     srcUnit: TUnit; callback: TEnumerateMetafileProc; callbackData: Pointer; const imageAttributes: GpImageAttributes): TStatus; stdcall;
{$EXTERNALSYM GdipEnumerateMetafileSrcRectDestPointI}
function GdipEnumerateMetafileSrcRectDestRect(graphics: GpGraphics; const metafile: GpMetafile; const destRect: PRectF; const srcRect: PRectF;
     srcUnit: TUnit; callback: TEnumerateMetafileProc; callbackData: Pointer; const imageAttributes: GpImageAttributes): TStatus; stdcall;
{$EXTERNALSYM GdipEnumerateMetafileSrcRectDestRect}
function GdipEnumerateMetafileSrcRectDestRectI(graphics: GpGraphics; const metafile: GpMetafile; const destRect: PRect; const srcRect: PRect;
     srcUnit: TUnit; callback: TEnumerateMetafileProc; callbackData: Pointer; const imageAttributes: GpImageAttributes): TStatus; stdcall;
{$EXTERNALSYM GdipEnumerateMetafileSrcRectDestRectI}
function GdipEnumerateMetafileSrcRectDestPoints(graphics: GpGraphics; const metafile: GpMetafile; const destPoints: PPointF; count: INT; const srcRect: PRectF;
     srcUnit: TUnit; callback: TEnumerateMetafileProc; callbackData: Pointer; const imageAttributes: GpImageAttributes): TStatus; stdcall;
{$EXTERNALSYM GdipEnumerateMetafileSrcRectDestPoints}
function GdipEnumerateMetafileSrcRectDestPointsI(graphics: GpGraphics; const metafile: GpMetafile; const destPoints: PPoint; count: INT; const srcRect: PRect;
     srcUnit: TUnit; callback: TEnumerateMetafileProc; callbackData: Pointer; const imageAttributes: GpImageAttributes): TStatus; stdcall;
{$EXTERNALSYM GdipEnumerateMetafileSrcRectDestPointsI}
function GdipPlayMetafileRecord(const metafile: GpMetafile; recordType: TEmfPlusRecordType;
     flags: INT; dataSize: INT; const data: PByte): TStatus; stdcall;
{$EXTERNALSYM GdipPlayMetafileRecord}
function GdipSetClipGraphics(graphics: GpGraphics; srcgraphics: GpGraphics;
     combineMode: TCombineMode): TStatus; stdcall;
{$EXTERNALSYM GdipSetClipGraphics}
function GdipSetClipRect(graphics: GpGraphics; x: TREAL; y: TREAL; width: TREAL;
     height: TREAL; combineMode: TCombineMode): TStatus; stdcall;
{$EXTERNALSYM GdipSetClipRect}
function GdipSetClipRectI(graphics: GpGraphics; x: INT; y: INT; width: INT;
     height: INT; combineMode: TCombineMode): TStatus; stdcall;
{$EXTERNALSYM GdipSetClipRectI}
function GdipSetClipPath(graphics: GpGraphics; path: GpPath;
     combineMode: TCombineMode): TStatus; stdcall;
{$EXTERNALSYM GdipSetClipPath}
function GdipSetClipRegion(graphics: GpGraphics; region: GpRegion;
     combineMode: TCombineMode): TStatus; stdcall;
{$EXTERNALSYM GdipSetClipRegion}
function GdipSetClipHrgn(graphics: GpGraphics; hRgn: HRGN;
     combineMode: TCombineMode): TStatus; stdcall;
{$EXTERNALSYM GdipSetClipHrgn}
function GdipResetClip(graphics: GpGraphics): TStatus; stdcall;
{$EXTERNALSYM GdipResetClip}
function GdipTranslateClip(graphics: GpGraphics; dx: TREAL; dy: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipTranslateClip}
function GdipTranslateClipI(graphics: GpGraphics; dx: INT; dy: INT): TStatus; stdcall;
{$EXTERNALSYM GdipTranslateClipI}
function GdipGetClip(graphics: GpGraphics; region: GpRegion): TStatus; stdcall;
{$EXTERNALSYM GdipGetClip}
function GdipGetClipBounds(graphics: GpGraphics; rect: PRectF): TStatus; stdcall;
{$EXTERNALSYM GdipGetClipBounds}
function GdipGetClipBoundsI(graphics: GpGraphics; rect: PRect): TStatus; stdcall;
{$EXTERNALSYM GdipGetClipBoundsI}
function GdipIsClipEmpty(graphics: GpGraphics; var result: BOOL): TStatus; stdcall;
{$EXTERNALSYM GdipIsClipEmpty}
function GdipGetVisibleClipBounds(graphics: GpGraphics; rect: PRectF): TStatus; stdcall;
{$EXTERNALSYM GdipGetVisibleClipBounds}
function GdipGetVisibleClipBoundsI(graphics: GpGraphics; rect: PRect): TStatus; stdcall;
{$EXTERNALSYM GdipGetVisibleClipBoundsI}
function GdipIsVisibleClipEmpty(graphics: GpGraphics;
     var result: BOOL): TStatus; stdcall;
{$EXTERNALSYM GdipIsVisibleClipEmpty}
function GdipIsVisiblePoint(graphics: GpGraphics; x: TREAL;
     y: TREAL; var result: BOOL): TStatus; stdcall;
{$EXTERNALSYM GdipIsVisiblePoint}
function GdipIsVisiblePointI(graphics: GpGraphics; x: INT;
     y: INT; var result: BOOL): TStatus; stdcall;
{$EXTERNALSYM GdipIsVisiblePointI}
function GdipIsVisibleRect(graphics: GpGraphics; x: TREAL; y: TREAL;
     width: TREAL; height: TREAL; var result: BOOL): TStatus; stdcall;
{$EXTERNALSYM GdipIsVisibleRect}
function GdipIsVisibleRectI(graphics: GpGraphics; x: INT; y: INT;
     width: INT; height: INT; var result: BOOL): TStatus; stdcall;
{$EXTERNALSYM GdipIsVisibleRectI}
function GdipSaveGraphics(graphics: GpGraphics;
     var state: TGraphicsState): TStatus; stdcall;
{$EXTERNALSYM GdipSaveGraphics}
function GdipRestoreGraphics(graphics: GpGraphics;
     state: TGraphicsState): TStatus; stdcall;
{$EXTERNALSYM GdipRestoreGraphics}
function GdipBeginContainer(graphics: GpGraphics; const dstrect: PRectF; const srcrect: PRectF;
     unit_: TUnit; var state: TGraphicsContainer): TStatus; stdcall;
{$EXTERNALSYM GdipBeginContainer}
function GdipBeginContainerI(graphics: GpGraphics; const dstrect: PRect; const srcrect: PRect;
     unit_: TUnit; var state: TGraphicsContainer): TStatus; stdcall;
{$EXTERNALSYM GdipBeginContainerI}
function GdipBeginContainer2(graphics: GpGraphics;
     var state: TGraphicsContainer): TStatus; stdcall;
{$EXTERNALSYM GdipBeginContainer2}
function GdipEndContainer(graphics: GpGraphics;
     state: TGraphicsContainer): TStatus; stdcall;
{$EXTERNALSYM GdipEndContainer}
function GdipGetMetafileHeaderFromWmf(hWmf: HMETAFILE; const wmfPlaceableFileHeader: PWmfPlaceableFileHeader;
     header: TMetafileHeader): TStatus; stdcall;
{$EXTERNALSYM GdipGetMetafileHeaderFromWmf}
function GdipGetMetafileHeaderFromEmf(hEmf: HENHMETAFILE;
     header: TMetafileHeader): TStatus; stdcall;
{$EXTERNALSYM GdipGetMetafileHeaderFromEmf}
function GdipGetMetafileHeaderFromFile(const filename: PWCHAR;
     header: TMetafileHeader): TStatus; stdcall;
{$EXTERNALSYM GdipGetMetafileHeaderFromFile}
function GdipGetMetafileHeaderFromStream(stream: ISTREAM;
     header: TMetafileHeader): TStatus; stdcall;
{$EXTERNALSYM GdipGetMetafileHeaderFromStream}
function GdipGetMetafileHeaderFromMetafile(metafile: GpMetafile;
     header: TMetafileHeader): TStatus; stdcall;
{$EXTERNALSYM GdipGetMetafileHeaderFromMetafile}
function GdipGetHemfFromMetafile(metafile: GpMetafile;
     var hEmf: HENHMETAFILE): TStatus; stdcall;
{$EXTERNALSYM GdipGetHemfFromMetafile}
function GdipCreateStreamOnFile(const filename: PWCHAR;
     access: INT; var stream: ISTREAM): TStatus; stdcall;
{$EXTERNALSYM GdipCreateStreamOnFile}
function GdipCreateMetafileFromWmf(hWmf: HMETAFILE; deleteWmf: BOOL; const wmfPlaceableFileHeader: PWmfPlaceableFileHeader;
     var metafile: GpMetafile): TStatus; stdcall;
{$EXTERNALSYM GdipCreateMetafileFromWmf}
function GdipCreateMetafileFromEmf(hEmf: HENHMETAFILE; deleteEmf: BOOL;
     var metafile: GpMetafile): TStatus; stdcall;
{$EXTERNALSYM GdipCreateMetafileFromEmf}
function GdipCreateMetafileFromFile(const fileName: PWCHAR;
     var metafile: GpMetafile): TStatus; stdcall;
{$EXTERNALSYM GdipCreateMetafileFromFile}
function GdipCreateMetafileFromWmfFile(const fileName: PWCHAR; const wmfPlaceableFileHeader: PWmfPlaceableFileHeader;
     var metafile: GpMetafile): TStatus; stdcall;
{$EXTERNALSYM GdipCreateMetafileFromWmfFile}
function GdipCreateMetafileFromStream(stream: ISTREAM;
     var metafile: GpMetafile): TStatus; stdcall;
{$EXTERNALSYM GdipCreateMetafileFromStream}
function GdipRecordMetafile(referenceHdc: HDC; mtype: TEmfType; const frameRect: PRectF; frameUnit: TMetafileFrameUnit;
     const description: PWCHAR; var metafile: GpMetafile): TStatus; stdcall;
{$EXTERNALSYM GdipRecordMetafile}
function GdipRecordMetafileI(referenceHdc: HDC; mtype: TEmfType; const frameRect: PRect; frameUnit: TMetafileFrameUnit;
     const description: PWCHAR; var metafile: GpMetafile): TStatus; stdcall;
{$EXTERNALSYM GdipRecordMetafileI}
function GdipRecordMetafileFileName(const fileName: PWCHAR; referenceHdc: HDC; mtype: TEmfType; const frameRect: PRectF;
     frameUnit: TMetafileFrameUnit; const description: PWCHAR; var metafile: GpMetafile): TStatus; stdcall;
{$EXTERNALSYM GdipRecordMetafileFileName}
function GdipRecordMetafileFileNameI(const fileName: PWCHAR; referenceHdc: HDC; mtype: TEmfType; const frameRect: PRect;
     frameUnit: TMetafileFrameUnit; const description: PWCHAR; var metafile: GpMetafile): TStatus; stdcall;
{$EXTERNALSYM GdipRecordMetafileFileNameI}
function GdipRecordMetafileStream(stream: ISTREAM; referenceHdc: HDC; mtype: TEmfType; const frameRect: PRectF;
     frameUnit: TMetafileFrameUnit; const description: PWCHAR; var metafile: GpMetafile): TStatus; stdcall;
{$EXTERNALSYM GdipRecordMetafileStream}
function GdipRecordMetafileStreamI(stream: ISTREAM; referenceHdc: HDC; mtype: TEmfType; const frameRect: PRect;
     frameUnit: TMetafileFrameUnit; const description: PWCHAR; var metafile: GpMetafile): TStatus; stdcall;
{$EXTERNALSYM GdipRecordMetafileStreamI}
function GdipSetMetafileDownLevelRasterizationLimit(metafile: GpMetafile;
     metafileRasterizationLimitDpi: INT): TStatus; stdcall;
{$EXTERNALSYM GdipSetMetafileDownLevelRasterizationLimit}
function GdipGetMetafileDownLevelRasterizationLimit(const metafile: GpMetafile;
     var metafileRasterizationLimitDpi: INT): TStatus; stdcall;
{$EXTERNALSYM GdipGetMetafileDownLevelRasterizationLimit}
function GdipGetImageDecodersSize(var numDecoders: INT;
     var size: INT): TStatus; stdcall;
{$EXTERNALSYM GdipGetImageDecodersSize}
function GdipGetImageDecoders(numDecoders: INT; size: INT;
     decoders: PImageCodecInfo): TStatus; stdcall;
{$EXTERNALSYM GdipGetImageDecoders}
function GdipGetImageEncodersSize(var numEncoders: INT;
     var size: INT): TStatus; stdcall;
{$EXTERNALSYM GdipGetImageEncodersSize}
function GdipGetImageEncoders(numEncoders: INT; size: INT;
     encoders: PImageCodecInfo): TStatus; stdcall;
{$EXTERNALSYM GdipGetImageEncoders}
function GdipComment(graphics: GpGraphics; sizeData: INT;
     const data: PByte): TStatus; stdcall;
{$EXTERNALSYM GdipComment}
function GdipCreateFontFamilyFromName(const name: PWCHAR; fontCollection: GpFontCollection;
     var FontFamily: GpFontFamily): TStatus; stdcall;
{$EXTERNALSYM GdipCreateFontFamilyFromName}
function GdipDeleteFontFamily(FontFamily: GpFontFamily): TStatus; stdcall;
{$EXTERNALSYM GdipDeleteFontFamily}
function GdipCloneFontFamily(FontFamily: GpFontFamily; var clonedFontFamily: GpFontFamily): TStatus; stdcall;
{$EXTERNALSYM GdipCloneFontFamily}
function GdipGetGenericFontFamilySansSerif(var nativeFamily: GpFontFamily): TStatus; stdcall;
{$EXTERNALSYM GdipGetGenericFontFamilySansSerif}
function GdipGetGenericFontFamilySerif(var nativeFamily: GpFontFamily): TStatus; stdcall;
{$EXTERNALSYM GdipGetGenericFontFamilySerif}
function GdipGetGenericFontFamilyMonospace(var nativeFamily: GpFontFamily): TStatus; stdcall;
{$EXTERNALSYM GdipGetGenericFontFamilyMonospace}
function GdipGetFamilyName(const family: GpFontFamily; name: PWCHAR;
     language: LANGID): TStatus; stdcall;
{$EXTERNALSYM GdipGetFamilyName}
function GdipIsStyleAvailable(const family: GpFontFamily; style: INT;
     var IsStyleAvailable: BOOL): TStatus; stdcall;
{$EXTERNALSYM GdipIsStyleAvailable}
function GdipFontCollectionEnumerable(fontCollection: GpFontCollection;
     graphics: GpGraphics; var numFound: INT): TStatus; stdcall;
{$EXTERNALSYM GdipFontCollectionEnumerable}
function GdipFontCollectionEnumerate(fontCollection: GpFontCollection; numSought: INT;
     gpfamilies: array of GpFontFamily; var numFound: INT; graphics: GpGraphics): TStatus; stdcall;
{$EXTERNALSYM GdipFontCollectionEnumerate}
function GdipGetEmHeight(const family: GpFontFamily; style: INT;
     var EmHeight: UINT16): TStatus; stdcall;
{$EXTERNALSYM GdipGetEmHeight}
function GdipGetCellAscent(const family: GpFontFamily; style: INT;
     var CellAscent: UINT16): TStatus; stdcall;
{$EXTERNALSYM GdipGetCellAscent}
function GdipGetCellDescent(const family: GpFontFamily; style: INT;
     var CellDescent: UINT16): TStatus; stdcall;
{$EXTERNALSYM GdipGetCellDescent}
function GdipGetLineSpacing(const family: GpFontFamily; style: INT;
     var LineSpacing: UINT16): TStatus; stdcall;
{$EXTERNALSYM GdipGetLineSpacing}
function GdipCreateFontFromDC(hdc: HDC; var font: GpFont): TStatus; stdcall;
{$EXTERNALSYM GdipCreateFontFromDC}
function GdipCreateFontFromLogfontA(hdc: HDC; const logfont: PLOGFONTA;
     var font: GpFont): TStatus; stdcall;
{$EXTERNALSYM GdipCreateFontFromLogfontA}
function GdipCreateFontFromLogfontW(hdc: HDC; const logfont: PLOGFONTW;
     var font: GpFont): TStatus; stdcall;
{$EXTERNALSYM GdipCreateFontFromLogfontW}
function GdipCreateFont(const fontFamily: GpFontFamily; emSize: TREAL;
     style: INT; unit_: TUnit; var font: GpFont): TStatus; stdcall;
{$EXTERNALSYM GdipCreateFont}
function GdipCloneFont(font: GpFont; var cloneFont: GpFont): TStatus; stdcall;
{$EXTERNALSYM GdipCloneFont}
function GdipDeleteFont(font: GpFont): TStatus; stdcall;
{$EXTERNALSYM GdipDeleteFont}
function GdipGetFamily(font: GpFont; var family: GpFontFamily): TStatus; stdcall;
{$EXTERNALSYM GdipGetFamily}
function GdipGetFontStyle(font: GpFont; var style: INT): TStatus; stdcall;
{$EXTERNALSYM GdipGetFontStyle}
function GdipGetFontSize(font: GpFont; var size: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipGetFontSize}
function GdipGetFontUnit(font: GpFont; var unit_: TUnit): TStatus; stdcall;
{$EXTERNALSYM GdipGetFontUnit}
function GdipGetFontHeight(const font: GpFont; const graphics: GpGraphics;
     var height: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipGetFontHeight}
function GdipGetFontHeightGivenDPI(const font: GpFont;
     dpi: TREAL; var height: TREAL): TStatus; stdcall;
{$EXTERNALSYM GdipGetFontHeightGivenDPI}
function GdipGetLogFontA(font: GpFont; graphics: GpGraphics;
     logfontA: PLOGFONTA): TStatus; stdcall;
{$EXTERNALSYM GdipGetLogFontA}
function GdipGetLogFontW(font: GpFont; graphics: GpGraphics;
     logfontW: PLOGFONTW): TStatus; stdcall;
{$EXTERNALSYM GdipGetLogFontW}
function GdipNewInstalledFontCollection(var fontCollection: GpFontCollection): TStatus; stdcall;
{$EXTERNALSYM GdipNewInstalledFontCollection}
function GdipNewPrivateFontCollection(var fontCollection: GpFontCollection): TStatus; stdcall;
{$EXTERNALSYM GdipNewPrivateFontCollection}
function GdipDeletePrivateFontCollection(var fontCollection: GpFontCollection): TStatus; stdcall;
{$EXTERNALSYM GdipDeletePrivateFontCollection}
function GdipGetFontCollectionFamilyCount(fontCollection: GpFontCollection;
     var numFound: INT): TStatus; stdcall;
{$EXTERNALSYM GdipGetFontCollectionFamilyCount}
function GdipGetFontCollectionFamilyList(fontCollection: GpFontCollection; numSought: INT;
     gpfamilies: GpFontFamily; var numFound: INT): TStatus; stdcall;
{$EXTERNALSYM GdipGetFontCollectionFamilyList}
function GdipPrivateAddFontFile(fontCollection: GpFontCollection;
     const filename: PWCHAR): TStatus; stdcall;
{$EXTERNALSYM GdipPrivateAddFontFile}
function GdipPrivateAddMemoryFont(fontCollection: GpFontCollection;
     const memory: Pointer; length: INT): TStatus; stdcall;
{$EXTERNALSYM GdipPrivateAddMemoryFont}
function GdipDrawString(graphics: GpGraphics; const str: PWCHAR; length: INT; const font: GpFont; const layoutRect: PRectF;
     const stringFormat: GpStringFormat; const brush: GpBrush): TStatus; stdcall;
{$EXTERNALSYM GdipDrawString}
function GdipMeasureString(graphics: GpGraphics; const str: PWCHAR; length: INT;
     const font: GpFont; const layoutRect: PRectF; const stringFormat: GpStringFormat;
     boundingBox: PRectF; codepointsFitted, linesFilled: PInteger): TStatus; stdcall;
{$EXTERNALSYM GdipMeasureString}
function GdipMeasureCharacterRanges(graphics: GpGraphics; const str: PWCHAR;
    length: INT; const font: GpFont; const layoutRect: PRectF;
    const stringFormat: GpStringFormat; regionCount: INT; const regions: GpRegion): TStatus; stdcall;
{$EXTERNALSYM GdipMeasureCharacterRanges}
function GdipDrawDriverString(graphics: GpGraphics; const text: PUINT16;
    length: INT; const font: GpFont; const brush: GpBrush;
    const positions: PPointF; flags: INT; const matrix: GpMatrix): TStatus; stdcall;
{$EXTERNALSYM GdipDrawDriverString}
function GdipMeasureDriverString(graphics: GpGraphics; const text: PUINT16; length: INT; const font: GpFont;
     const positions: PPointF; flags: INT; const matrix: GpMatrix; boundingBox: PRectF): TStatus; stdcall;
{$EXTERNALSYM GdipMeasureDriverString}
function GdipCreateStringFormat(formatAttributes: INT; language: LANGID;
     var format: GpStringFormat): TStatus; stdcall;
{$EXTERNALSYM GdipCreateStringFormat}
function GdipStringFormatGetGenericDefault(var format: GpStringFormat): TStatus; stdcall;
{$EXTERNALSYM GdipStringFormatGetGenericDefault}
function GdipStringFormatGetGenericTypographic(var format: GpStringFormat): TStatus; stdcall;
{$EXTERNALSYM GdipStringFormatGetGenericTypographic}
function GdipDeleteStringFormat(format: GpStringFormat): TStatus; stdcall;
{$EXTERNALSYM GdipDeleteStringFormat}
function GdipCloneStringFormat(const format: GpStringFormat;
     var newFormat: GpStringFormat): TStatus; stdcall;
{$EXTERNALSYM GdipCloneStringFormat}
function GdipSetStringFormatFlags(format: GpStringFormat; flags: INT): TStatus; stdcall;
{$EXTERNALSYM GdipSetStringFormatFlags}
function GdipGetStringFormatFlags(const format: GpStringFormat;
     var flags: INT): TStatus; stdcall;
{$EXTERNALSYM GdipGetStringFormatFlags}
function GdipSetStringFormatAlign(format: GpStringFormat;
     align: TStringAlignment): TStatus; stdcall;
{$EXTERNALSYM GdipSetStringFormatAlign}
function GdipGetStringFormatAlign(const format: GpStringFormat;
     var align: TStringAlignment): TStatus; stdcall;
{$EXTERNALSYM GdipGetStringFormatAlign}
function GdipSetStringFormatLineAlign(format: GpStringFormat;
     align: TStringAlignment): TStatus; stdcall;
{$EXTERNALSYM GdipSetStringFormatLineAlign}
function GdipGetStringFormatLineAlign(const format: GpStringFormat;
     var align: TStringAlignment): TStatus; stdcall;
{$EXTERNALSYM GdipGetStringFormatLineAlign}
function GdipSetStringFormatTrimming(format: GpStringFormat;
     trimming: TStringTrimming): TStatus; stdcall;
{$EXTERNALSYM GdipSetStringFormatTrimming}
function GdipGetStringFormatTrimming(const format: GpStringFormat;
     var trimming: TStringTrimming): TStatus; stdcall;
{$EXTERNALSYM GdipGetStringFormatTrimming}
function GdipSetStringFormatHotkeyPrefix(format: GpStringFormat;
     hotkeyPrefix: INT): TStatus; stdcall;
{$EXTERNALSYM GdipSetStringFormatHotkeyPrefix}
function GdipGetStringFormatHotkeyPrefix(const format: GpStringFormat;
     var hotkeyPrefix: THotkeyPrefix): TStatus; stdcall;
{$EXTERNALSYM GdipGetStringFormatHotkeyPrefix}
function GdipSetStringFormatTabStops(format: GpStringFormat; firstTabOffset: TREAL;
     count: INT; const tabStops: PREAL): TStatus; stdcall;
{$EXTERNALSYM GdipSetStringFormatTabStops}
function GdipGetStringFormatTabStops(const format: GpStringFormat; count: INT;
     var firstTabOffset: TREAL; tabStops: PREAL): TStatus; stdcall;
{$EXTERNALSYM GdipGetStringFormatTabStops}
function GdipGetStringFormatTabStopCount(const format: GpStringFormat;
     var count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipGetStringFormatTabStopCount}
function GdipSetStringFormatDigitSubstitution(format: GpStringFormat; language: LANGID;
     substitute: TStringDigitSubstitute): TStatus; stdcall;
{$EXTERNALSYM GdipSetStringFormatDigitSubstitution}
function GdipGetStringFormatDigitSubstitution(const format: GpStringFormat; var language: LANGID;
     var substitute: TStringDigitSubstitute): TStatus; stdcall;
{$EXTERNALSYM GdipGetStringFormatDigitSubstitution}
function GdipGetStringFormatMeasurableCharacterRangeCount(const format: GpStringFormat;
     var count: INT): TStatus; stdcall;
{$EXTERNALSYM GdipGetStringFormatMeasurableCharacterRangeCount}
function GdipSetStringFormatMeasurableCharacterRanges(format: GpStringFormat;
     rangeCount: INT; const ranges: PCharacterRange): TStatus; stdcall;
{$EXTERNALSYM GdipSetStringFormatMeasurableCharacterRanges}
function GdipCreateCachedBitmap(bitmap: GpBitmap; graphics: GpGraphics;
     var cachedBitmap: GpCachedBitmap): TStatus; stdcall;
{$EXTERNALSYM GdipCreateCachedBitmap}
function GdipDeleteCachedBitmap(cachedBitmap: GpCachedBitmap): TStatus; stdcall;
{$EXTERNALSYM GdipDeleteCachedBitmap}
function GdipDrawCachedBitmap(graphics: GpGraphics; cachedBitmap: GpCachedBitmap;
     x: INT; y: INT): TStatus; stdcall;
{$EXTERNALSYM GdipDrawCachedBitmap}
function GdipEmfToWmfBits(hemf: HENHMETAFILE; cbData16: INT; pData16: PBYTE;
     iMapMode: INT; eFlags: INT): TStatus; stdcall;
{$EXTERNALSYM GdipEmfToWmfBits}

implementation

function GdiplusStartup; external gpdll name 'GdiplusStartup' Delayed;
procedure GdiplusShutdown; external gpdll name 'GdiplusShutdown' Delayed;

function GdipAlloc; external gpdll name 'GdipAlloc' Delayed;
procedure GdipFree; external gpdll name 'GdipFree' Delayed;

function GdipCreatePath; external gpdll name 'GdipCreatePath' Delayed;
function GdipCreatePath2; external gpdll name 'GdipCreatePath2' Delayed;
function GdipCreatePath2I; external gpdll name 'GdipCreatePath2I' Delayed;
function GdipClonePath; external gpdll name 'GdipClonePath' Delayed;
function GdipDeletePath; external gpdll name 'GdipDeletePath' Delayed;
function GdipResetPath; external gpdll name 'GdipResetPath' Delayed;
function GdipGetPointCount; external gpdll name 'GdipGetPointCount' Delayed;
function GdipGetPathTypes; external gpdll name 'GdipGetPathTypes' Delayed;
function GdipGetPathPoints; external gpdll name 'GdipGetPathPoints' Delayed;
function GdipGetPathPointsI; external gpdll name 'GdipGetPathPointsI' Delayed;
function GdipGetPathFillMode; external gpdll name 'GdipGetPathFillMode' Delayed;
function GdipSetPathFillMode; external gpdll name 'GdipSetPathFillMode' Delayed;
function GdipGetPathData; external gpdll name 'GdipGetPathData' Delayed;
function GdipStartPathFigure; external gpdll name 'GdipStartPathFigure' Delayed;
function GdipClosePathFigure; external gpdll name 'GdipClosePathFigure' Delayed;
function GdipClosePathFigures; external gpdll name 'GdipClosePathFigures' Delayed;
function GdipSetPathMarker; external gpdll name 'GdipSetPathMarker' Delayed;
function GdipClearPathMarkers; external gpdll name 'GdipClearPathMarkers' Delayed;
function GdipReversePath; external gpdll name 'GdipReversePath' Delayed;
function GdipGetPathLastPoint; external gpdll name 'GdipGetPathLastPoint' Delayed;
function GdipAddPathLine; external gpdll name 'GdipAddPathLine' Delayed;
function GdipAddPathLine2; external gpdll name 'GdipAddPathLine2' Delayed;
function GdipAddPathArc; external gpdll name 'GdipAddPathArc' Delayed;
function GdipAddPathBezier; external gpdll name 'GdipAddPathBezier' Delayed;
function GdipAddPathBeziers; external gpdll name 'GdipAddPathBeziers' Delayed;
function GdipAddPathCurve; external gpdll name 'GdipAddPathCurve' Delayed;
function GdipAddPathCurve2; external gpdll name 'GdipAddPathCurve2' Delayed;
function GdipAddPathCurve3; external gpdll name 'GdipAddPathCurve3' Delayed;
function GdipAddPathClosedCurve; external gpdll name 'GdipAddPathClosedCurve' Delayed;
function GdipAddPathClosedCurve2; external gpdll name 'GdipAddPathClosedCurve2' Delayed;
function GdipAddPathRectangle; external gpdll name 'GdipAddPathRectangle' Delayed;
function GdipAddPathRectangles; external gpdll name 'GdipAddPathRectangles' Delayed;
function GdipAddPathEllipse; external gpdll name 'GdipAddPathEllipse' Delayed;
function GdipAddPathPie; external gpdll name 'GdipAddPathPie' Delayed;
function GdipAddPathPolygon; external gpdll name 'GdipAddPathPolygon' Delayed;
function GdipAddPathPath; external gpdll name 'GdipAddPathPath' Delayed;
function GdipAddPathString; external gpdll name 'GdipAddPathString' Delayed;
function GdipAddPathStringI; external gpdll name 'GdipAddPathStringI' Delayed;
function GdipAddPathLineI; external gpdll name 'GdipAddPathLineI' Delayed;
function GdipAddPathLine2I; external gpdll name 'GdipAddPathLine2I' Delayed;
function GdipAddPathArcI; external gpdll name 'GdipAddPathArcI' Delayed;
function GdipAddPathBezierI; external gpdll name 'GdipAddPathBezierI' Delayed;
function GdipAddPathBeziersI; external gpdll name 'GdipAddPathBeziersI' Delayed;
function GdipAddPathCurveI; external gpdll name 'GdipAddPathCurveI' Delayed;
function GdipAddPathCurve2I; external gpdll name 'GdipAddPathCurve2I' Delayed;
function GdipAddPathCurve3I; external gpdll name 'GdipAddPathCurve3I' Delayed;
function GdipAddPathClosedCurveI; external gpdll name 'GdipAddPathClosedCurveI' Delayed;
function GdipAddPathClosedCurve2I; external gpdll name 'GdipAddPathClosedCurve2I' Delayed;
function GdipAddPathRectangleI; external gpdll name 'GdipAddPathRectangleI' Delayed;
function GdipAddPathRectanglesI; external gpdll name 'GdipAddPathRectanglesI' Delayed;
function GdipAddPathEllipseI; external gpdll name 'GdipAddPathEllipseI' Delayed;
function GdipAddPathPieI; external gpdll name 'GdipAddPathPieI' Delayed;
function GdipAddPathPolygonI; external gpdll name 'GdipAddPathPolygonI' Delayed;
function GdipFlattenPath; external gpdll name 'GdipFlattenPath' Delayed;
function GdipWindingModeOutline; external gpdll name 'GdipWindingModeOutline' Delayed;
function GdipWidenPath; external gpdll name 'GdipWidenPath' Delayed;
function GdipWarpPath; external gpdll name 'GdipWarpPath' Delayed;
function GdipTransformPath; external gpdll name 'GdipTransformPath' Delayed;
function GdipGetPathWorldBounds; external gpdll name 'GdipGetPathWorldBounds' Delayed;
function GdipGetPathWorldBoundsI; external gpdll name 'GdipGetPathWorldBoundsI' Delayed;
function GdipIsVisiblePathPoint; external gpdll name 'GdipIsVisiblePathPoint' Delayed;
function GdipIsVisiblePathPointI; external gpdll name 'GdipIsVisiblePathPointI' Delayed;
function GdipIsOutlineVisiblePathPoint; external gpdll name 'GdipIsOutlineVisiblePathPoint' Delayed;
function GdipIsOutlineVisiblePathPointI; external gpdll name 'GdipIsOutlineVisiblePathPointI' Delayed;
function GdipCreatePathIter; external gpdll name 'GdipCreatePathIter' Delayed;
function GdipDeletePathIter; external gpdll name 'GdipDeletePathIter' Delayed;
function GdipPathIterNextSubpath; external gpdll name 'GdipPathIterNextSubpath' Delayed;
function GdipPathIterNextSubpathPath; external gpdll name 'GdipPathIterNextSubpathPath' Delayed;
function GdipPathIterNextPathType; external gpdll name 'GdipPathIterNextPathType' Delayed;
function GdipPathIterNextMarker; external gpdll name 'GdipPathIterNextMarker' Delayed;
function GdipPathIterNextMarkerPath; external gpdll name 'GdipPathIterNextMarkerPath' Delayed;
function GdipPathIterGetCount; external gpdll name 'GdipPathIterGetCount' Delayed;
function GdipPathIterGetSubpathCount; external gpdll name 'GdipPathIterGetSubpathCount' Delayed;
function GdipPathIterIsValid; external gpdll name 'GdipPathIterIsValid' Delayed;
function GdipPathIterHasCurve; external gpdll name 'GdipPathIterHasCurve' Delayed;
function GdipPathIterRewind; external gpdll name 'GdipPathIterRewind' Delayed;
function GdipPathIterEnumerate; external gpdll name 'GdipPathIterEnumerate' Delayed;
function GdipPathIterCopyData; external gpdll name 'GdipPathIterCopyData' Delayed;
function GdipCreateMatrix; external gpdll name 'GdipCreateMatrix' Delayed;
function GdipCreateMatrix2; external gpdll name 'GdipCreateMatrix2' Delayed;
function GdipCreateMatrix3; external gpdll name 'GdipCreateMatrix3' Delayed;
function GdipCreateMatrix3I; external gpdll name 'GdipCreateMatrix3I' Delayed;
function GdipCloneMatrix; external gpdll name 'GdipCloneMatrix' Delayed;
function GdipDeleteMatrix; external gpdll name 'GdipDeleteMatrix' Delayed;
function GdipSetMatrixElements; external gpdll name 'GdipSetMatrixElements' Delayed;
function GdipMultiplyMatrix; external gpdll name 'GdipMultiplyMatrix' Delayed;
function GdipTranslateMatrix; external gpdll name 'GdipTranslateMatrix' Delayed;
function GdipScaleMatrix; external gpdll name 'GdipScaleMatrix' Delayed;
function GdipRotateMatrix; external gpdll name 'GdipRotateMatrix' Delayed;
function GdipShearMatrix; external gpdll name 'GdipShearMatrix' Delayed;
function GdipInvertMatrix; external gpdll name 'GdipInvertMatrix' Delayed;
function GdipTransformMatrixPoints; external gpdll name 'GdipTransformMatrixPoints' Delayed;
function GdipTransformMatrixPointsI; external gpdll name 'GdipTransformMatrixPointsI' Delayed;
function GdipVectorTransformMatrixPoints; external gpdll name 'GdipVectorTransformMatrixPoints' Delayed;
function GdipVectorTransformMatrixPointsI; external gpdll name 'GdipVectorTransformMatrixPointsI' Delayed;
function GdipGetMatrixElements; external gpdll name 'GdipGetMatrixElements' Delayed;
function GdipIsMatrixInvertible; external gpdll name 'GdipIsMatrixInvertible' Delayed;
function GdipIsMatrixIdentity; external gpdll name 'GdipIsMatrixIdentity' Delayed;
function GdipIsMatrixEqual; external gpdll name 'GdipIsMatrixEqual' Delayed;
function GdipCreateRegion; external gpdll name 'GdipCreateRegion' Delayed;
function GdipCreateRegionRect; external gpdll name 'GdipCreateRegionRect' Delayed;
function GdipCreateRegionRectI; external gpdll name 'GdipCreateRegionRectI' Delayed;
function GdipCreateRegionPath; external gpdll name 'GdipCreateRegionPath' Delayed;
function GdipCreateRegionRgnData; external gpdll name 'GdipCreateRegionRgnData' Delayed;
function GdipCreateRegionHrgn; external gpdll name 'GdipCreateRegionHrgn' Delayed;
function GdipCloneRegion; external gpdll name 'GdipCloneRegion' Delayed;
function GdipDeleteRegion; external gpdll name 'GdipDeleteRegion' Delayed;
function GdipSetInfinite; external gpdll name 'GdipSetInfinite' Delayed;
function GdipSetEmpty; external gpdll name 'GdipSetEmpty' Delayed;
function GdipCombineRegionRect; external gpdll name 'GdipCombineRegionRect' Delayed;
function GdipCombineRegionRectI; external gpdll name 'GdipCombineRegionRectI' Delayed;
function GdipCombineRegionPath; external gpdll name 'GdipCombineRegionPath' Delayed;
function GdipCombineRegionRegion; external gpdll name 'GdipCombineRegionRegion' Delayed;
function GdipTranslateRegion; external gpdll name 'GdipTranslateRegion' Delayed;
function GdipTranslateRegionI; external gpdll name 'GdipTranslateRegionI' Delayed;
function GdipTransformRegion; external gpdll name 'GdipTransformRegion' Delayed;
function GdipGetRegionBounds; external gpdll name 'GdipGetRegionBounds' Delayed;
function GdipGetRegionBoundsI; external gpdll name 'GdipGetRegionBoundsI' Delayed;
function GdipGetRegionHRgn; external gpdll name 'GdipGetRegionHRgn' Delayed;
function GdipIsEmptyRegion; external gpdll name 'GdipIsEmptyRegion' Delayed;
function GdipIsInfiniteRegion; external gpdll name 'GdipIsInfiniteRegion' Delayed;
function GdipIsEqualRegion; external gpdll name 'GdipIsEqualRegion' Delayed;
function GdipGetRegionDataSize; external gpdll name 'GdipGetRegionDataSize' Delayed;
function GdipGetRegionData; external gpdll name 'GdipGetRegionData' Delayed;
function GdipIsVisibleRegionPoint; external gpdll name 'GdipIsVisibleRegionPoint' Delayed;
function GdipIsVisibleRegionPointI; external gpdll name 'GdipIsVisibleRegionPointI' Delayed;
function GdipIsVisibleRegionRect; external gpdll name 'GdipIsVisibleRegionRect' Delayed;
function GdipIsVisibleRegionRectI; external gpdll name 'GdipIsVisibleRegionRectI' Delayed;
function GdipGetRegionScansCount; external gpdll name 'GdipGetRegionScansCount' Delayed;
function GdipGetRegionScans; external gpdll name 'GdipGetRegionScans' Delayed;
function GdipGetRegionScansI; external gpdll name 'GdipGetRegionScansI' Delayed;
function GdipCloneBrush; external gpdll name 'GdipCloneBrush' Delayed;
function GdipDeleteBrush; external gpdll name 'GdipDeleteBrush' Delayed;
function GdipGetBrushType; external gpdll name 'GdipGetBrushType' Delayed;
function GdipCreateHatchBrush; external gpdll name 'GdipCreateHatchBrush' Delayed;
function GdipGetHatchStyle; external gpdll name 'GdipGetHatchStyle' Delayed;
function GdipGetHatchForegroundColor; external gpdll name 'GdipGetHatchForegroundColor' Delayed;
function GdipGetHatchBackgroundColor; external gpdll name 'GdipGetHatchBackgroundColor' Delayed;
function GdipCreateTexture; external gpdll name 'GdipCreateTexture' Delayed;
function GdipCreateTexture2; external gpdll name 'GdipCreateTexture2' Delayed;
function GdipCreateTextureIA; external gpdll name 'GdipCreateTextureIA' Delayed;
function GdipCreateTexture2I; external gpdll name 'GdipCreateTexture2I' Delayed;
function GdipCreateTextureIAI; external gpdll name 'GdipCreateTextureIAI' Delayed;
function GdipGetTextureTransform; external gpdll name 'GdipGetTextureTransform' Delayed;
function GdipSetTextureTransform; external gpdll name 'GdipSetTextureTransform' Delayed;
function GdipResetTextureTransform; external gpdll name 'GdipResetTextureTransform' Delayed;
function GdipMultiplyTextureTransform; external gpdll name 'GdipMultiplyTextureTransform' Delayed;
function GdipTranslateTextureTransform; external gpdll name 'GdipTranslateTextureTransform' Delayed;
function GdipScaleTextureTransform; external gpdll name 'GdipScaleTextureTransform' Delayed;
function GdipRotateTextureTransform; external gpdll name 'GdipRotateTextureTransform' Delayed;
function GdipSetTextureWrapMode; external gpdll name 'GdipSetTextureWrapMode' Delayed;
function GdipGetTextureWrapMode; external gpdll name 'GdipGetTextureWrapMode' Delayed;
function GdipGetTextureImage; external gpdll name 'GdipGetTextureImage' Delayed;
function GdipCreateSolidFill; external gpdll name 'GdipCreateSolidFill' Delayed;
function GdipSetSolidFillColor; external gpdll name 'GdipSetSolidFillColor' Delayed;
function GdipGetSolidFillColor; external gpdll name 'GdipGetSolidFillColor' Delayed;
function GdipCreateLineBrush; external gpdll name 'GdipCreateLineBrush' Delayed;
function GdipCreateLineBrushI; external gpdll name 'GdipCreateLineBrushI' Delayed;
function GdipCreateLineBrushFromRect; external gpdll name 'GdipCreateLineBrushFromRect' Delayed;
function GdipCreateLineBrushFromRectI; external gpdll name 'GdipCreateLineBrushFromRectI' Delayed;
function GdipCreateLineBrushFromRectWithAngle; external gpdll name 'GdipCreateLineBrushFromRectWithAngle' Delayed;
function GdipCreateLineBrushFromRectWithAngleI; external gpdll name 'GdipCreateLineBrushFromRectWithAngleI' Delayed;
function GdipSetLineColors; external gpdll name 'GdipSetLineColors' Delayed;
function GdipGetLineColors; external gpdll name 'GdipGetLineColors' Delayed;
function GdipGetLineRect; external gpdll name 'GdipGetLineRect' Delayed;
function GdipGetLineRectI; external gpdll name 'GdipGetLineRectI' Delayed;
function GdipSetLineGammaCorrection; external gpdll name 'GdipSetLineGammaCorrection' Delayed;
function GdipGetLineGammaCorrection; external gpdll name 'GdipGetLineGammaCorrection' Delayed;
function GdipGetLineBlendCount; external gpdll name 'GdipGetLineBlendCount' Delayed;
function GdipGetLineBlend; external gpdll name 'GdipGetLineBlend' Delayed;
function GdipSetLineBlend; external gpdll name 'GdipSetLineBlend' Delayed;
function GdipGetLinePresetBlendCount; external gpdll name 'GdipGetLinePresetBlendCount' Delayed;
function GdipGetLinePresetBlend; external gpdll name 'GdipGetLinePresetBlend' Delayed;
function GdipSetLinePresetBlend; external gpdll name 'GdipSetLinePresetBlend' Delayed;
function GdipSetLineSigmaBlend; external gpdll name 'GdipSetLineSigmaBlend' Delayed;
function GdipSetLineLinearBlend; external gpdll name 'GdipSetLineLinearBlend' Delayed;
function GdipSetLineWrapMode; external gpdll name 'GdipSetLineWrapMode' Delayed;
function GdipGetLineWrapMode; external gpdll name 'GdipGetLineWrapMode' Delayed;
function GdipGetLineTransform; external gpdll name 'GdipGetLineTransform' Delayed;
function GdipSetLineTransform; external gpdll name 'GdipSetLineTransform' Delayed;
function GdipResetLineTransform; external gpdll name 'GdipResetLineTransform' Delayed;
function GdipMultiplyLineTransform; external gpdll name 'GdipMultiplyLineTransform' Delayed;
function GdipTranslateLineTransform; external gpdll name 'GdipTranslateLineTransform' Delayed;
function GdipScaleLineTransform; external gpdll name 'GdipScaleLineTransform' Delayed;
function GdipRotateLineTransform; external gpdll name 'GdipRotateLineTransform' Delayed;
function GdipCreatePathGradient; external gpdll name 'GdipCreatePathGradient' Delayed;
function GdipCreatePathGradientI; external gpdll name 'GdipCreatePathGradientI' Delayed;
function GdipCreatePathGradientFromPath; external gpdll name 'GdipCreatePathGradientFromPath' Delayed;
function GdipGetPathGradientCenterColor; external gpdll name 'GdipGetPathGradientCenterColor' Delayed;
function GdipSetPathGradientCenterColor; external gpdll name 'GdipSetPathGradientCenterColor' Delayed;
function GdipGetPathGradientSurroundColorsWithCount; external gpdll name 'GdipGetPathGradientSurroundColorsWithCount' Delayed;
function GdipSetPathGradientSurroundColorsWithCount; external gpdll name 'GdipSetPathGradientSurroundColorsWithCount' Delayed;
function GdipGetPathGradientPath; external gpdll name 'GdipGetPathGradientPath' Delayed;
function GdipSetPathGradientPath; external gpdll name 'GdipSetPathGradientPath' Delayed;
function GdipGetPathGradientCenterPoint; external gpdll name 'GdipGetPathGradientCenterPoint' Delayed;
function GdipGetPathGradientCenterPointI; external gpdll name 'GdipGetPathGradientCenterPointI' Delayed;
function GdipSetPathGradientCenterPoint; external gpdll name 'GdipSetPathGradientCenterPoint' Delayed;
function GdipSetPathGradientCenterPointI; external gpdll name 'GdipSetPathGradientCenterPointI' Delayed;
function GdipGetPathGradientRect; external gpdll name 'GdipGetPathGradientRect' Delayed;
function GdipGetPathGradientRectI; external gpdll name 'GdipGetPathGradientRectI' Delayed;
function GdipGetPathGradientPointCount; external gpdll name 'GdipGetPathGradientPointCount' Delayed;
function GdipGetPathGradientSurroundColorCount; external gpdll name 'GdipGetPathGradientSurroundColorCount' Delayed;
function GdipSetPathGradientGammaCorrection; external gpdll name 'GdipSetPathGradientGammaCorrection' Delayed;
function GdipGetPathGradientGammaCorrection; external gpdll name 'GdipGetPathGradientGammaCorrection' Delayed;
function GdipGetPathGradientBlendCount; external gpdll name 'GdipGetPathGradientBlendCount' Delayed;
function GdipGetPathGradientBlend; external gpdll name 'GdipGetPathGradientBlend' Delayed;
function GdipSetPathGradientBlend; external gpdll name 'GdipSetPathGradientBlend' Delayed;
function GdipGetPathGradientPresetBlendCount; external gpdll name 'GdipGetPathGradientPresetBlendCount' Delayed;
function GdipGetPathGradientPresetBlend; external gpdll name 'GdipGetPathGradientPresetBlend' Delayed;
function GdipSetPathGradientPresetBlend; external gpdll name 'GdipSetPathGradientPresetBlend' Delayed;
function GdipSetPathGradientSigmaBlend; external gpdll name 'GdipSetPathGradientSigmaBlend' Delayed;
function GdipSetPathGradientLinearBlend; external gpdll name 'GdipSetPathGradientLinearBlend' Delayed;
function GdipGetPathGradientWrapMode; external gpdll name 'GdipGetPathGradientWrapMode' Delayed;
function GdipSetPathGradientWrapMode; external gpdll name 'GdipSetPathGradientWrapMode' Delayed;
function GdipGetPathGradientTransform; external gpdll name 'GdipGetPathGradientTransform' Delayed;
function GdipSetPathGradientTransform; external gpdll name 'GdipSetPathGradientTransform' Delayed;
function GdipResetPathGradientTransform; external gpdll name 'GdipResetPathGradientTransform' Delayed;
function GdipMultiplyPathGradientTransform; external gpdll name 'GdipMultiplyPathGradientTransform' Delayed;
function GdipTranslatePathGradientTransform; external gpdll name 'GdipTranslatePathGradientTransform' Delayed;
function GdipScalePathGradientTransform; external gpdll name 'GdipScalePathGradientTransform' Delayed;
function GdipRotatePathGradientTransform; external gpdll name 'GdipRotatePathGradientTransform' Delayed;
function GdipGetPathGradientFocusScales; external gpdll name 'GdipGetPathGradientFocusScales' Delayed;
function GdipSetPathGradientFocusScales; external gpdll name 'GdipSetPathGradientFocusScales' Delayed;
function GdipCreatePen1; external gpdll name 'GdipCreatePen1' Delayed;
function GdipCreatePen2; external gpdll name 'GdipCreatePen2' Delayed;
function GdipClonePen; external gpdll name 'GdipClonePen' Delayed;
function GdipDeletePen; external gpdll name 'GdipDeletePen' Delayed;
function GdipSetPenWidth; external gpdll name 'GdipSetPenWidth' Delayed;
function GdipGetPenWidth; external gpdll name 'GdipGetPenWidth' Delayed;
function GdipSetPenUnit; external gpdll name 'GdipSetPenUnit' Delayed;
function GdipGetPenUnit; external gpdll name 'GdipGetPenUnit' Delayed;
function GdipSetPenLineCap197819; external gpdll name 'GdipSetPenLineCap197819' Delayed;
function GdipSetPenStartCap; external gpdll name 'GdipSetPenStartCap' Delayed;
function GdipSetPenEndCap; external gpdll name 'GdipSetPenEndCap' Delayed;
function GdipSetPenDashCap197819; external gpdll name 'GdipSetPenDashCap197819' Delayed;
function GdipGetPenStartCap; external gpdll name 'GdipGetPenStartCap' Delayed;
function GdipGetPenEndCap; external gpdll name 'GdipGetPenEndCap' Delayed;
function GdipGetPenDashCap197819; external gpdll name 'GdipGetPenDashCap197819' Delayed;
function GdipSetPenLineJoin; external gpdll name 'GdipSetPenLineJoin' Delayed;
function GdipGetPenLineJoin; external gpdll name 'GdipGetPenLineJoin' Delayed;
function GdipSetPenCustomStartCap; external gpdll name 'GdipSetPenCustomStartCap' Delayed;
function GdipGetPenCustomStartCap; external gpdll name 'GdipGetPenCustomStartCap' Delayed;
function GdipSetPenCustomEndCap; external gpdll name 'GdipSetPenCustomEndCap' Delayed;
function GdipGetPenCustomEndCap; external gpdll name 'GdipGetPenCustomEndCap' Delayed;
function GdipSetPenMiterLimit; external gpdll name 'GdipSetPenMiterLimit' Delayed;
function GdipGetPenMiterLimit; external gpdll name 'GdipGetPenMiterLimit' Delayed;
function GdipSetPenMode; external gpdll name 'GdipSetPenMode' Delayed;
function GdipGetPenMode; external gpdll name 'GdipGetPenMode' Delayed;
function GdipSetPenTransform; external gpdll name 'GdipSetPenTransform' Delayed;
function GdipGetPenTransform; external gpdll name 'GdipGetPenTransform' Delayed;
function GdipResetPenTransform; external gpdll name 'GdipResetPenTransform' Delayed;
function GdipMultiplyPenTransform; external gpdll name 'GdipMultiplyPenTransform' Delayed;
function GdipTranslatePenTransform; external gpdll name 'GdipTranslatePenTransform' Delayed;
function GdipScalePenTransform; external gpdll name 'GdipScalePenTransform' Delayed;
function GdipRotatePenTransform; external gpdll name 'GdipRotatePenTransform' Delayed;
function GdipSetPenColor; external gpdll name 'GdipSetPenColor' Delayed;
function GdipGetPenColor; external gpdll name 'GdipGetPenColor' Delayed;
function GdipSetPenBrushFill; external gpdll name 'GdipSetPenBrushFill' Delayed;
function GdipGetPenBrushFill; external gpdll name 'GdipGetPenBrushFill' Delayed;
function GdipGetPenFillType; external gpdll name 'GdipGetPenFillType' Delayed;
function GdipGetPenDashStyle; external gpdll name 'GdipGetPenDashStyle' Delayed;
function GdipSetPenDashStyle; external gpdll name 'GdipSetPenDashStyle' Delayed;
function GdipGetPenDashOffset; external gpdll name 'GdipGetPenDashOffset' Delayed;
function GdipSetPenDashOffset; external gpdll name 'GdipSetPenDashOffset' Delayed;
function GdipGetPenDashCount; external gpdll name 'GdipGetPenDashCount' Delayed;
function GdipSetPenDashArray; external gpdll name 'GdipSetPenDashArray' Delayed;
function GdipGetPenDashArray; external gpdll name 'GdipGetPenDashArray' Delayed;
function GdipGetPenCompoundCount; external gpdll name 'GdipGetPenCompoundCount' Delayed;
function GdipSetPenCompoundArray; external gpdll name 'GdipSetPenCompoundArray' Delayed;
function GdipGetPenCompoundArray; external gpdll name 'GdipGetPenCompoundArray' Delayed;
function GdipCreateCustomLineCap; external gpdll name 'GdipCreateCustomLineCap' Delayed;
function GdipDeleteCustomLineCap; external gpdll name 'GdipDeleteCustomLineCap' Delayed;
function GdipCloneCustomLineCap; external gpdll name 'GdipCloneCustomLineCap' Delayed;
function GdipGetCustomLineCapType; external gpdll name 'GdipGetCustomLineCapType' Delayed;
function GdipSetCustomLineCapStrokeCaps; external gpdll name 'GdipSetCustomLineCapStrokeCaps' Delayed;
function GdipGetCustomLineCapStrokeCaps; external gpdll name 'GdipGetCustomLineCapStrokeCaps' Delayed;
function GdipSetCustomLineCapStrokeJoin; external gpdll name 'GdipSetCustomLineCapStrokeJoin' Delayed;
function GdipGetCustomLineCapStrokeJoin; external gpdll name 'GdipGetCustomLineCapStrokeJoin' Delayed;
function GdipSetCustomLineCapBaseCap; external gpdll name 'GdipSetCustomLineCapBaseCap' Delayed;
function GdipGetCustomLineCapBaseCap; external gpdll name 'GdipGetCustomLineCapBaseCap' Delayed;
function GdipSetCustomLineCapBaseInset; external gpdll name 'GdipSetCustomLineCapBaseInset' Delayed;
function GdipGetCustomLineCapBaseInset; external gpdll name 'GdipGetCustomLineCapBaseInset' Delayed;
function GdipSetCustomLineCapWidthScale; external gpdll name 'GdipSetCustomLineCapWidthScale' Delayed;
function GdipGetCustomLineCapWidthScale; external gpdll name 'GdipGetCustomLineCapWidthScale' Delayed;
function GdipCreateAdjustableArrowCap; external gpdll name 'GdipCreateAdjustableArrowCap' Delayed;
function GdipSetAdjustableArrowCapHeight; external gpdll name 'GdipSetAdjustableArrowCapHeight' Delayed;
function GdipGetAdjustableArrowCapHeight; external gpdll name 'GdipGetAdjustableArrowCapHeight' Delayed;
function GdipSetAdjustableArrowCapWidth; external gpdll name 'GdipSetAdjustableArrowCapWidth' Delayed;
function GdipGetAdjustableArrowCapWidth; external gpdll name 'GdipGetAdjustableArrowCapWidth' Delayed;
function GdipSetAdjustableArrowCapMiddleInset; external gpdll name 'GdipSetAdjustableArrowCapMiddleInset' Delayed;
function GdipGetAdjustableArrowCapMiddleInset; external gpdll name 'GdipGetAdjustableArrowCapMiddleInset' Delayed;
function GdipSetAdjustableArrowCapFillState; external gpdll name 'GdipSetAdjustableArrowCapFillState' Delayed;
function GdipGetAdjustableArrowCapFillState; external gpdll name 'GdipGetAdjustableArrowCapFillState' Delayed;
function GdipLoadImageFromStream; external gpdll name 'GdipLoadImageFromStream' Delayed;
function GdipLoadImageFromFile; external gpdll name 'GdipLoadImageFromFile' Delayed;
function GdipLoadImageFromStreamICM; external gpdll name 'GdipLoadImageFromStreamICM' Delayed;
function GdipLoadImageFromFileICM; external gpdll name 'GdipLoadImageFromFileICM' Delayed;
function GdipCloneImage; external gpdll name 'GdipCloneImage' Delayed;
function GdipDisposeImage; external gpdll name 'GdipDisposeImage' Delayed;
function GdipSaveImageToFile; external gpdll name 'GdipSaveImageToFile' Delayed;
function GdipSaveImageToStream; external gpdll name 'GdipSaveImageToStream' Delayed;
function GdipSaveAdd; external gpdll name 'GdipSaveAdd' Delayed;
function GdipSaveAddImage; external gpdll name 'GdipSaveAddImage' Delayed;
function GdipGetImageGraphicsContext; external gpdll name 'GdipGetImageGraphicsContext' Delayed;
function GdipGetImageBounds; external gpdll name 'GdipGetImageBounds' Delayed;
function GdipGetImageDimension; external gpdll name 'GdipGetImageDimension' Delayed;
function GdipGetImageType; external gpdll name 'GdipGetImageType' Delayed;
function GdipGetImageWidth; external gpdll name 'GdipGetImageWidth' Delayed;
function GdipGetImageHeight; external gpdll name 'GdipGetImageHeight' Delayed;
function GdipGetImageHorizontalResolution; external gpdll name 'GdipGetImageHorizontalResolution' Delayed;
function GdipGetImageVerticalResolution; external gpdll name 'GdipGetImageVerticalResolution' Delayed;
function GdipGetImageFlags; external gpdll name 'GdipGetImageFlags' Delayed;
function GdipGetImageRawFormat; external gpdll name 'GdipGetImageRawFormat' Delayed;
function GdipGetImagePixelFormat; external gpdll name 'GdipGetImagePixelFormat' Delayed;
function GdipGetImageThumbnail; external gpdll name 'GdipGetImageThumbnail' Delayed;
function GdipGetEncoderParameterListSize; external gpdll name 'GdipGetEncoderParameterListSize' Delayed;
function GdipGetEncoderParameterList; external gpdll name 'GdipGetEncoderParameterList' Delayed;
function GdipImageGetFrameDimensionsCount; external gpdll name 'GdipImageGetFrameDimensionsCount' Delayed;
function GdipImageGetFrameDimensionsList; external gpdll name 'GdipImageGetFrameDimensionsList' Delayed;
function GdipImageGetFrameCount; external gpdll name 'GdipImageGetFrameCount' Delayed;
function GdipImageSelectActiveFrame; external gpdll name 'GdipImageSelectActiveFrame' Delayed;
function GdipImageRotateFlip; external gpdll name 'GdipImageRotateFlip' Delayed;
function GdipGetImagePalette; external gpdll name 'GdipGetImagePalette' Delayed;
function GdipSetImagePalette; external gpdll name 'GdipSetImagePalette' Delayed;
function GdipGetImagePaletteSize; external gpdll name 'GdipGetImagePaletteSize' Delayed;
function GdipGetPropertyCount; external gpdll name 'GdipGetPropertyCount' Delayed;
function GdipGetPropertyIdList; external gpdll name 'GdipGetPropertyIdList' Delayed;
function GdipGetPropertyItemSize; external gpdll name 'GdipGetPropertyItemSize' Delayed;
function GdipGetPropertyItem; external gpdll name 'GdipGetPropertyItem' Delayed;
function GdipGetPropertySize; external gpdll name 'GdipGetPropertySize' Delayed;
function GdipGetAllPropertyItems; external gpdll name 'GdipGetAllPropertyItems' Delayed;
function GdipRemovePropertyItem; external gpdll name 'GdipRemovePropertyItem' Delayed;
function GdipSetPropertyItem; external gpdll name 'GdipSetPropertyItem' Delayed;
function GdipImageForceValidation; external gpdll name 'GdipImageForceValidation' Delayed;
function GdipCreateBitmapFromStream; external gpdll name 'GdipCreateBitmapFromStream' Delayed;
function GdipCreateBitmapFromFile; external gpdll name 'GdipCreateBitmapFromFile' Delayed;
function GdipCreateBitmapFromStreamICM; external gpdll name 'GdipCreateBitmapFromStreamICM' Delayed;
function GdipCreateBitmapFromFileICM; external gpdll name 'GdipCreateBitmapFromFileICM' Delayed;
function GdipCreateBitmapFromScan0; external gpdll name 'GdipCreateBitmapFromScan0' Delayed;
function GdipCreateBitmapFromGraphics; external gpdll name 'GdipCreateBitmapFromGraphics' Delayed;
function GdipCreateBitmapFromDirectDrawSurface; external gpdll name 'GdipCreateBitmapFromDirectDrawSurface' Delayed;
function GdipCreateBitmapFromGdiDib; external gpdll name 'GdipCreateBitmapFromGdiDib' Delayed;
function GdipCreateBitmapFromHBITMAP; external gpdll name 'GdipCreateBitmapFromHBITMAP' Delayed;
function GdipCreateHBITMAPFromBitmap; external gpdll name 'GdipCreateHBITMAPFromBitmap' Delayed;
function GdipCreateBitmapFromHICON; external gpdll name 'GdipCreateBitmapFromHICON' Delayed;
function GdipCreateHICONFromBitmap; external gpdll name 'GdipCreateHICONFromBitmap' Delayed;
function GdipCreateBitmapFromResource; external gpdll name 'GdipCreateBitmapFromResource' Delayed;
function GdipCloneBitmapArea; external gpdll name 'GdipCloneBitmapArea' Delayed;
function GdipCloneBitmapAreaI; external gpdll name 'GdipCloneBitmapAreaI' Delayed;
function GdipBitmapLockBits; external gpdll name 'GdipBitmapLockBits' Delayed;
function GdipBitmapUnlockBits; external gpdll name 'GdipBitmapUnlockBits' Delayed;
function GdipBitmapGetPixel; external gpdll name 'GdipBitmapGetPixel' Delayed;
function GdipBitmapSetPixel; external gpdll name 'GdipBitmapSetPixel' Delayed;
function GdipBitmapSetResolution; external gpdll name 'GdipBitmapSetResolution' Delayed;
function GdipCreateImageAttributes; external gpdll name 'GdipCreateImageAttributes' Delayed;
function GdipCloneImageAttributes; external gpdll name 'GdipCloneImageAttributes' Delayed;
function GdipDisposeImageAttributes; external gpdll name 'GdipDisposeImageAttributes' Delayed;
function GdipSetImageAttributesToIdentity; external gpdll name 'GdipSetImageAttributesToIdentity' Delayed;
function GdipResetImageAttributes; external gpdll name 'GdipResetImageAttributes' Delayed;
function GdipSetImageAttributesColorMatrix; external gpdll name 'GdipSetImageAttributesColorMatrix' Delayed;
function GdipSetImageAttributesThreshold; external gpdll name 'GdipSetImageAttributesThreshold' Delayed;
function GdipSetImageAttributesGamma; external gpdll name 'GdipSetImageAttributesGamma' Delayed;
function GdipSetImageAttributesNoOp; external gpdll name 'GdipSetImageAttributesNoOp' Delayed;
function GdipSetImageAttributesColorKeys; external gpdll name 'GdipSetImageAttributesColorKeys' Delayed;
function GdipSetImageAttributesOutputChannel; external gpdll name 'GdipSetImageAttributesOutputChannel' Delayed;
function GdipSetImageAttributesOutputChannelColorProfile; external gpdll name 'GdipSetImageAttributesOutputChannelColorProfile' Delayed;
function GdipSetImageAttributesRemapTable; external gpdll name 'GdipSetImageAttributesRemapTable' Delayed;
function GdipSetImageAttributesWrapMode; external gpdll name 'GdipSetImageAttributesWrapMode' Delayed;
function GdipSetImageAttributesICMMode; external gpdll name 'GdipSetImageAttributesICMMode' Delayed;
function GdipGetImageAttributesAdjustedPalette; external gpdll name 'GdipGetImageAttributesAdjustedPalette' Delayed;
function GdipFlush; external gpdll name 'GdipFlush' Delayed;
function GdipCreateFromHDC; external gpdll name 'GdipCreateFromHDC' Delayed;
function GdipCreateFromHDC2; external gpdll name 'GdipCreateFromHDC2' Delayed;
function GdipCreateFromHWND; external gpdll name 'GdipCreateFromHWND' Delayed;
function GdipCreateFromHWNDICM; external gpdll name 'GdipCreateFromHWNDICM' Delayed;
function GdipDeleteGraphics; external gpdll name 'GdipDeleteGraphics' Delayed;
function GdipGetDC; external gpdll name 'GdipGetDC' Delayed;
function GdipReleaseDC; external gpdll name 'GdipReleaseDC' Delayed;
function GdipSetCompositingMode; external gpdll name 'GdipSetCompositingMode' Delayed;
function GdipGetCompositingMode; external gpdll name 'GdipGetCompositingMode' Delayed;
function GdipSetRenderingOrigin; external gpdll name 'GdipSetRenderingOrigin' Delayed;
function GdipGetRenderingOrigin; external gpdll name 'GdipGetRenderingOrigin' Delayed;
function GdipSetCompositingQuality; external gpdll name 'GdipSetCompositingQuality' Delayed;
function GdipGetCompositingQuality; external gpdll name 'GdipGetCompositingQuality' Delayed;
function GdipSetSmoothingMode; external gpdll name 'GdipSetSmoothingMode' Delayed;
function GdipGetSmoothingMode; external gpdll name 'GdipGetSmoothingMode' Delayed;
function GdipSetPixelOffsetMode; external gpdll name 'GdipSetPixelOffsetMode' Delayed;
function GdipGetPixelOffsetMode; external gpdll name 'GdipGetPixelOffsetMode' Delayed;
function GdipSetTextRenderingHint; external gpdll name 'GdipSetTextRenderingHint' Delayed;
function GdipGetTextRenderingHint; external gpdll name 'GdipGetTextRenderingHint' Delayed;
function GdipSetTextContrast; external gpdll name 'GdipSetTextContrast' Delayed;
function GdipGetTextContrast; external gpdll name 'GdipGetTextContrast' Delayed;
function GdipSetInterpolationMode; external gpdll name 'GdipSetInterpolationMode' Delayed;
function GdipGetInterpolationMode; external gpdll name 'GdipGetInterpolationMode' Delayed;
function GdipSetWorldTransform; external gpdll name 'GdipSetWorldTransform' Delayed;
function GdipResetWorldTransform; external gpdll name 'GdipResetWorldTransform' Delayed;
function GdipMultiplyWorldTransform; external gpdll name 'GdipMultiplyWorldTransform' Delayed;
function GdipTranslateWorldTransform; external gpdll name 'GdipTranslateWorldTransform' Delayed;
function GdipScaleWorldTransform; external gpdll name 'GdipScaleWorldTransform' Delayed;
function GdipRotateWorldTransform; external gpdll name 'GdipRotateWorldTransform' Delayed;
function GdipGetWorldTransform; external gpdll name 'GdipGetWorldTransform' Delayed;
function GdipResetPageTransform; external gpdll name 'GdipResetPageTransform' Delayed;
function GdipGetPageUnit; external gpdll name 'GdipGetPageUnit' Delayed;
function GdipGetPageScale; external gpdll name 'GdipGetPageScale' Delayed;
function GdipSetPageUnit; external gpdll name 'GdipSetPageUnit' Delayed;
function GdipSetPageScale; external gpdll name 'GdipSetPageScale' Delayed;
function GdipGetDpiX; external gpdll name 'GdipGetDpiX' Delayed;
function GdipGetDpiY; external gpdll name 'GdipGetDpiY' Delayed;
function GdipTransformPoints; external gpdll name 'GdipTransformPoints' Delayed;
function GdipTransformPointsI; external gpdll name 'GdipTransformPointsI' Delayed;
function GdipGetNearestColor; external gpdll name 'GdipGetNearestColor' Delayed;
function GdipCreateHalftonePalette; external gpdll name 'GdipCreateHalftonePalette' Delayed;
function GdipDrawLine; external gpdll name 'GdipDrawLine' Delayed;
function GdipDrawLineI; external gpdll name 'GdipDrawLineI' Delayed;
function GdipDrawLines; external gpdll name 'GdipDrawLines' Delayed;
function GdipDrawLinesI; external gpdll name 'GdipDrawLinesI' Delayed;
function GdipDrawArc; external gpdll name 'GdipDrawArc' Delayed;
function GdipDrawArcI; external gpdll name 'GdipDrawArcI' Delayed;
function GdipDrawBezier; external gpdll name 'GdipDrawBezier' Delayed;
function GdipDrawBezierI; external gpdll name 'GdipDrawBezierI' Delayed;
function GdipDrawBeziers; external gpdll name 'GdipDrawBeziers' Delayed;
function GdipDrawBeziersI; external gpdll name 'GdipDrawBeziersI' Delayed;
function GdipDrawRectangle; external gpdll name 'GdipDrawRectangle' Delayed;
function GdipDrawRectangleI; external gpdll name 'GdipDrawRectangleI' Delayed;
function GdipDrawRectangles; external gpdll name 'GdipDrawRectangles' Delayed;
function GdipDrawRectanglesI; external gpdll name 'GdipDrawRectanglesI' Delayed;
function GdipDrawEllipse; external gpdll name 'GdipDrawEllipse' Delayed;
function GdipDrawEllipseI; external gpdll name 'GdipDrawEllipseI' Delayed;
function GdipDrawPie; external gpdll name 'GdipDrawPie' Delayed;
function GdipDrawPieI; external gpdll name 'GdipDrawPieI' Delayed;
function GdipDrawPolygon; external gpdll name 'GdipDrawPolygon' Delayed;
function GdipDrawPolygonI; external gpdll name 'GdipDrawPolygonI' Delayed;
function GdipDrawPath; external gpdll name 'GdipDrawPath' Delayed;
function GdipDrawCurve; external gpdll name 'GdipDrawCurve' Delayed;
function GdipDrawCurveI; external gpdll name 'GdipDrawCurveI' Delayed;
function GdipDrawCurve2; external gpdll name 'GdipDrawCurve2' Delayed;
function GdipDrawCurve2I; external gpdll name 'GdipDrawCurve2I' Delayed;
function GdipDrawCurve3; external gpdll name 'GdipDrawCurve3' Delayed;
function GdipDrawCurve3I; external gpdll name 'GdipDrawCurve3I' Delayed;
function GdipDrawClosedCurve; external gpdll name 'GdipDrawClosedCurve' Delayed;
function GdipDrawClosedCurveI; external gpdll name 'GdipDrawClosedCurveI' Delayed;
function GdipDrawClosedCurve2; external gpdll name 'GdipDrawClosedCurve2' Delayed;
function GdipDrawClosedCurve2I; external gpdll name 'GdipDrawClosedCurve2I' Delayed;
function GdipGraphicsClear; external gpdll name 'GdipGraphicsClear' Delayed;
function GdipFillRectangle; external gpdll name 'GdipFillRectangle' Delayed;
function GdipFillRectangleI; external gpdll name 'GdipFillRectangleI' Delayed;
function GdipFillRectangles; external gpdll name 'GdipFillRectangles' Delayed;
function GdipFillRectanglesI; external gpdll name 'GdipFillRectanglesI' Delayed;
function GdipFillPolygon; external gpdll name 'GdipFillPolygon' Delayed;
function GdipFillPolygonI; external gpdll name 'GdipFillPolygonI' Delayed;
function GdipFillPolygon2; external gpdll name 'GdipFillPolygon2' Delayed;
function GdipFillPolygon2I; external gpdll name 'GdipFillPolygon2I' Delayed;
function GdipFillEllipse; external gpdll name 'GdipFillEllipse' Delayed;
function GdipFillEllipseI; external gpdll name 'GdipFillEllipseI' Delayed;
function GdipFillPie; external gpdll name 'GdipFillPie' Delayed;
function GdipFillPieI; external gpdll name 'GdipFillPieI' Delayed;
function GdipFillPath; external gpdll name 'GdipFillPath' Delayed;
function GdipFillClosedCurve; external gpdll name 'GdipFillClosedCurve' Delayed;
function GdipFillClosedCurveI; external gpdll name 'GdipFillClosedCurveI' Delayed;
function GdipFillClosedCurve2; external gpdll name 'GdipFillClosedCurve2' Delayed;
function GdipFillClosedCurve2I; external gpdll name 'GdipFillClosedCurve2I' Delayed;
function GdipFillRegion; external gpdll name 'GdipFillRegion' Delayed;
function GdipDrawImage; external gpdll name 'GdipDrawImage' Delayed;
function GdipDrawImageI; external gpdll name 'GdipDrawImageI' Delayed;
function GdipDrawImageRect; external gpdll name 'GdipDrawImageRect' Delayed;
function GdipDrawImageRectI; external gpdll name 'GdipDrawImageRectI' Delayed;
function GdipDrawImagePoints; external gpdll name 'GdipDrawImagePoints' Delayed;
function GdipDrawImagePointsI; external gpdll name 'GdipDrawImagePointsI' Delayed;
function GdipDrawImagePointRect; external gpdll name 'GdipDrawImagePointRect' Delayed;
function GdipDrawImagePointRectI; external gpdll name 'GdipDrawImagePointRectI' Delayed;
function GdipDrawImageRectRect; external gpdll name 'GdipDrawImageRectRect' Delayed;
function GdipDrawImageRectRectI; external gpdll name 'GdipDrawImageRectRectI' Delayed;
function GdipDrawImagePointsRect; external gpdll name 'GdipDrawImagePointsRect' Delayed;
function GdipDrawImagePointsRectI; external gpdll name 'GdipDrawImagePointsRectI' Delayed;
function GdipEnumerateMetafileDestPoint; external gpdll name 'GdipEnumerateMetafileDestPoint' Delayed;
function GdipEnumerateMetafileDestPointI; external gpdll name 'GdipEnumerateMetafileDestPointI' Delayed;
function GdipEnumerateMetafileDestRect; external gpdll name 'GdipEnumerateMetafileDestRect' Delayed;
function GdipEnumerateMetafileDestRectI; external gpdll name 'GdipEnumerateMetafileDestRectI' Delayed;
function GdipEnumerateMetafileDestPoints; external gpdll name 'GdipEnumerateMetafileDestPoints' Delayed;
function GdipEnumerateMetafileDestPointsI; external gpdll name 'GdipEnumerateMetafileDestPointsI' Delayed;
function GdipEnumerateMetafileSrcRectDestPoint; external gpdll name 'GdipEnumerateMetafileSrcRectDestPoint' Delayed;
function GdipEnumerateMetafileSrcRectDestPointI; external gpdll name 'GdipEnumerateMetafileSrcRectDestPointI' Delayed;
function GdipEnumerateMetafileSrcRectDestRect; external gpdll name 'GdipEnumerateMetafileSrcRectDestRect' Delayed;
function GdipEnumerateMetafileSrcRectDestRectI; external gpdll name 'GdipEnumerateMetafileSrcRectDestRectI' Delayed;
function GdipEnumerateMetafileSrcRectDestPoints; external gpdll name 'GdipEnumerateMetafileSrcRectDestPoints' Delayed;
function GdipEnumerateMetafileSrcRectDestPointsI; external gpdll name 'GdipEnumerateMetafileSrcRectDestPointsI' Delayed;
function GdipPlayMetafileRecord; external gpdll name 'GdipPlayMetafileRecord' Delayed;
function GdipSetClipGraphics; external gpdll name 'GdipSetClipGraphics' Delayed;
function GdipSetClipRect; external gpdll name 'GdipSetClipRect' Delayed;
function GdipSetClipRectI; external gpdll name 'GdipSetClipRectI' Delayed;
function GdipSetClipPath; external gpdll name 'GdipSetClipPath' Delayed;
function GdipSetClipRegion; external gpdll name 'GdipSetClipRegion' Delayed;
function GdipSetClipHrgn; external gpdll name 'GdipSetClipHrgn' Delayed;
function GdipResetClip; external gpdll name 'GdipResetClip' Delayed;
function GdipTranslateClip; external gpdll name 'GdipTranslateClip' Delayed;
function GdipTranslateClipI; external gpdll name 'GdipTranslateClipI' Delayed;
function GdipGetClip; external gpdll name 'GdipGetClip' Delayed;
function GdipGetClipBounds; external gpdll name 'GdipGetClipBounds' Delayed;
function GdipGetClipBoundsI; external gpdll name 'GdipGetClipBoundsI' Delayed;
function GdipIsClipEmpty; external gpdll name 'GdipIsClipEmpty' Delayed;
function GdipGetVisibleClipBounds; external gpdll name 'GdipGetVisibleClipBounds' Delayed;
function GdipGetVisibleClipBoundsI; external gpdll name 'GdipGetVisibleClipBoundsI' Delayed;
function GdipIsVisibleClipEmpty; external gpdll name 'GdipIsVisibleClipEmpty' Delayed;
function GdipIsVisiblePoint; external gpdll name 'GdipIsVisiblePoint' Delayed;
function GdipIsVisiblePointI; external gpdll name 'GdipIsVisiblePointI' Delayed;
function GdipIsVisibleRect; external gpdll name 'GdipIsVisibleRect' Delayed;
function GdipIsVisibleRectI; external gpdll name 'GdipIsVisibleRectI' Delayed;
function GdipSaveGraphics; external gpdll name 'GdipSaveGraphics' Delayed;
function GdipRestoreGraphics; external gpdll name 'GdipRestoreGraphics' Delayed;
function GdipBeginContainer; external gpdll name 'GdipBeginContainer' Delayed;
function GdipBeginContainerI; external gpdll name 'GdipBeginContainerI' Delayed;
function GdipBeginContainer2; external gpdll name 'GdipBeginContainer2' Delayed;
function GdipEndContainer; external gpdll name 'GdipEndContainer' Delayed;
function GdipGetMetafileHeaderFromWmf; external gpdll name 'GdipGetMetafileHeaderFromWmf' Delayed;
function GdipGetMetafileHeaderFromEmf; external gpdll name 'GdipGetMetafileHeaderFromEmf' Delayed;
function GdipGetMetafileHeaderFromFile; external gpdll name 'GdipGetMetafileHeaderFromFile' Delayed;
function GdipGetMetafileHeaderFromStream; external gpdll name 'GdipGetMetafileHeaderFromStream' Delayed;
function GdipGetMetafileHeaderFromMetafile; external gpdll name 'GdipGetMetafileHeaderFromMetafile' Delayed;
function GdipGetHemfFromMetafile; external gpdll name 'GdipGetHemfFromMetafile' Delayed;
function GdipCreateStreamOnFile; external gpdll name 'GdipCreateStreamOnFile' Delayed;
function GdipCreateMetafileFromWmf; external gpdll name 'GdipCreateMetafileFromWmf' Delayed;
function GdipCreateMetafileFromEmf; external gpdll name 'GdipCreateMetafileFromEmf' Delayed;
function GdipCreateMetafileFromFile; external gpdll name 'GdipCreateMetafileFromFile' Delayed;
function GdipCreateMetafileFromWmfFile; external gpdll name 'GdipCreateMetafileFromWmfFile' Delayed;
function GdipCreateMetafileFromStream; external gpdll name 'GdipCreateMetafileFromStream' Delayed;
function GdipRecordMetafile; external gpdll name 'GdipRecordMetafile' Delayed;
function GdipRecordMetafileI; external gpdll name 'GdipRecordMetafileI' Delayed;
function GdipRecordMetafileFileName; external gpdll name 'GdipRecordMetafileFileName' Delayed;
function GdipRecordMetafileFileNameI; external gpdll name 'GdipRecordMetafileFileNameI' Delayed;
function GdipRecordMetafileStream; external gpdll name 'GdipRecordMetafileStream' Delayed;
function GdipRecordMetafileStreamI; external gpdll name 'GdipRecordMetafileStreamI' Delayed;
function GdipSetMetafileDownLevelRasterizationLimit; external gpdll name 'GdipSetMetafileDownLevelRasterizationLimit' Delayed;
function GdipGetMetafileDownLevelRasterizationLimit; external gpdll name 'GdipGetMetafileDownLevelRasterizationLimit' Delayed;
function GdipGetImageDecodersSize; external gpdll name 'GdipGetImageDecodersSize' Delayed;
function GdipGetImageDecoders; external gpdll name 'GdipGetImageDecoders' Delayed;
function GdipGetImageEncodersSize; external gpdll name 'GdipGetImageEncodersSize' Delayed;
function GdipGetImageEncoders; external gpdll name 'GdipGetImageEncoders' Delayed;
function GdipComment; external gpdll name 'GdipComment' Delayed;
function GdipCreateFontFamilyFromName; external gpdll name 'GdipCreateFontFamilyFromName' Delayed;
function GdipDeleteFontFamily; external gpdll name 'GdipDeleteFontFamily' Delayed;
function GdipCloneFontFamily; external gpdll name 'GdipCloneFontFamily' Delayed;
function GdipGetGenericFontFamilySansSerif; external gpdll name 'GdipGetGenericFontFamilySansSerif' Delayed;
function GdipGetGenericFontFamilySerif; external gpdll name 'GdipGetGenericFontFamilySerif' Delayed;
function GdipGetGenericFontFamilyMonospace; external gpdll name 'GdipGetGenericFontFamilyMonospace' Delayed;
function GdipGetFamilyName; external gpdll name 'GdipGetFamilyName' Delayed;
function GdipIsStyleAvailable; external gpdll name 'GdipIsStyleAvailable' Delayed;
function GdipFontCollectionEnumerable; external gpdll name 'GdipFontCollectionEnumerable' Delayed;
function GdipFontCollectionEnumerate; external gpdll name 'GdipFontCollectionEnumerate' Delayed;
function GdipGetEmHeight; external gpdll name 'GdipGetEmHeight' Delayed;
function GdipGetCellAscent; external gpdll name 'GdipGetCellAscent' Delayed;
function GdipGetCellDescent; external gpdll name 'GdipGetCellDescent' Delayed;
function GdipGetLineSpacing; external gpdll name 'GdipGetLineSpacing' Delayed;
function GdipCreateFontFromDC; external gpdll name 'GdipCreateFontFromDC' Delayed;
function GdipCreateFontFromLogfontA; external gpdll name 'GdipCreateFontFromLogfontA' Delayed;
function GdipCreateFontFromLogfontW; external gpdll name 'GdipCreateFontFromLogfontW' Delayed;
function GdipCreateFont; external gpdll name 'GdipCreateFont' Delayed;
function GdipCloneFont; external gpdll name 'GdipCloneFont' Delayed;
function GdipDeleteFont; external gpdll name 'GdipDeleteFont' Delayed;
function GdipGetFamily; external gpdll name 'GdipGetFamily' Delayed;
function GdipGetFontStyle; external gpdll name 'GdipGetFontStyle' Delayed;
function GdipGetFontSize; external gpdll name 'GdipGetFontSize' Delayed;
function GdipGetFontUnit; external gpdll name 'GdipGetFontUnit' Delayed;
function GdipGetFontHeight; external gpdll name 'GdipGetFontHeight' Delayed;
function GdipGetFontHeightGivenDPI; external gpdll name 'GdipGetFontHeightGivenDPI' Delayed;
function GdipGetLogFontA; external gpdll name 'GdipGetLogFontA' Delayed;
function GdipGetLogFontW; external gpdll name 'GdipGetLogFontW' Delayed;
function GdipNewInstalledFontCollection; external gpdll name 'GdipNewInstalledFontCollection' Delayed;
function GdipNewPrivateFontCollection; external gpdll name 'GdipNewPrivateFontCollection' Delayed;
function GdipDeletePrivateFontCollection; external gpdll name 'GdipDeletePrivateFontCollection' Delayed;
function GdipGetFontCollectionFamilyCount; external gpdll name 'GdipGetFontCollectionFamilyCount' Delayed;
function GdipGetFontCollectionFamilyList; external gpdll name 'GdipGetFontCollectionFamilyList' Delayed;
function GdipPrivateAddFontFile; external gpdll name 'GdipPrivateAddFontFile' Delayed;
function GdipPrivateAddMemoryFont; external gpdll name 'GdipPrivateAddMemoryFont' Delayed;
function GdipDrawString; external gpdll name 'GdipDrawString' Delayed;
function GdipMeasureString; external gpdll name 'GdipMeasureString' Delayed;
function GdipMeasureCharacterRanges; external gpdll name 'GdipMeasureCharacterRanges' Delayed;
function GdipDrawDriverString; external gpdll name 'GdipDrawDriverString' Delayed;
function GdipMeasureDriverString; external gpdll name 'GdipMeasureDriverString' Delayed;
function GdipCreateStringFormat; external gpdll name 'GdipCreateStringFormat' Delayed;
function GdipStringFormatGetGenericDefault; external gpdll name 'GdipStringFormatGetGenericDefault' Delayed;
function GdipStringFormatGetGenericTypographic; external gpdll name 'GdipStringFormatGetGenericTypographic' Delayed;
function GdipDeleteStringFormat; external gpdll name 'GdipDeleteStringFormat' Delayed;
function GdipCloneStringFormat; external gpdll name 'GdipCloneStringFormat' Delayed;
function GdipSetStringFormatFlags; external gpdll name 'GdipSetStringFormatFlags' Delayed;
function GdipGetStringFormatFlags; external gpdll name 'GdipGetStringFormatFlags' Delayed;
function GdipSetStringFormatAlign; external gpdll name 'GdipSetStringFormatAlign' Delayed;
function GdipGetStringFormatAlign; external gpdll name 'GdipGetStringFormatAlign' Delayed;
function GdipSetStringFormatLineAlign; external gpdll name 'GdipSetStringFormatLineAlign' Delayed;
function GdipGetStringFormatLineAlign; external gpdll name 'GdipGetStringFormatLineAlign' Delayed;
function GdipSetStringFormatTrimming; external gpdll name 'GdipSetStringFormatTrimming' Delayed;
function GdipGetStringFormatTrimming; external gpdll name 'GdipGetStringFormatTrimming' Delayed;
function GdipSetStringFormatHotkeyPrefix; external gpdll name 'GdipSetStringFormatHotkeyPrefix' Delayed;
function GdipGetStringFormatHotkeyPrefix; external gpdll name 'GdipGetStringFormatHotkeyPrefix' Delayed;
function GdipSetStringFormatTabStops; external gpdll name 'GdipSetStringFormatTabStops' Delayed;
function GdipGetStringFormatTabStops; external gpdll name 'GdipGetStringFormatTabStops' Delayed;
function GdipGetStringFormatTabStopCount; external gpdll name 'GdipGetStringFormatTabStopCount' Delayed;
function GdipSetStringFormatDigitSubstitution; external gpdll name 'GdipSetStringFormatDigitSubstitution' Delayed;
function GdipGetStringFormatDigitSubstitution; external gpdll name 'GdipGetStringFormatDigitSubstitution' Delayed;
function GdipGetStringFormatMeasurableCharacterRangeCount; external gpdll name 'GdipGetStringFormatMeasurableCharacterRangeCount' Delayed;
function GdipSetStringFormatMeasurableCharacterRanges; external gpdll name 'GdipSetStringFormatMeasurableCharacterRanges' Delayed;
function GdipCreateCachedBitmap; external gpdll name 'GdipCreateCachedBitmap' Delayed;
function GdipDeleteCachedBitmap; external gpdll name 'GdipDeleteCachedBitmap' Delayed;
function GdipDrawCachedBitmap; external gpdll name 'GdipDrawCachedBitmap' Delayed;
function GdipEmfToWmfBits; external gpdll name 'GdipEmfToWmfBits' Delayed;

var
   StartupInput: TGDIPlusStartupInput;
   gdiplusToken: ULONG;

procedure InitGDIP;
begin
  StartupInput.DebugEventCallback := nil;
  StartupInput.SuppressBackgroundThread := false;
  StartupInput.SuppressExternalCodecs   := false;
  StartupInput.GdiplusVersion := 1;
  // Initialize GDI+
  GdiplusStartup(gdiplusToken, @StartupInput, nil);
end;

procedure FreeGDIP;
begin
  GdiplusShutdown(gdiplusToken);
end;

initialization
  InitGDIP;

finalization
  FreeGDIP;

end.






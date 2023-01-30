unit GdipTypes;

(**************************************************************************\
*
* 2003年，湖北省公安县统计局 毛泽发 于大连
*
* Module Name:
*
*   GdiplusEnums.h, GdiplusTypes.h, GdiplusGpStubs.h, GdiplusPixelFormats
*   GdiplusColor.h, GdiplusColorMatrix.h, gdiplusimaging.h, gdiplusmetaheader.h
*
* Abstract:
*
*   GDI+ Types
*
**************************************************************************)
{$ALIGN ON}
{$MINENUMSIZE 4}
interface

uses
  WinApi.Windows, SysUtils, Classes, WinApi.ActiveX;
//--------------------------------------------------------------------------
// Default bezier flattening tolerance in device pixels.
//--------------------------------------------------------------------------

const FlatnessDefault = 1.0/4.0;

type
//  {$I 'WTypeP_C.inc'}
  INT16   = Smallint;
  PINT16  = PSmallint;
  UINT16  = Word;
  PUINT16 = PWord;
  UINT32  = DWORD;
  PINT32  = PDWord;
//--------------------------------------------------------------------------
// Graphics and Container State cookies
//--------------------------------------------------------------------------

  TGraphicsState = UINT;

  TGraphicsContainer = UINT;

//--------------------------------------------------------------------------
// Fill mode constants
//--------------------------------------------------------------------------

  TFillMode = (FillModeAlternate, // 交替填充模式
               FillModeWinding    // 环绕填充模式
               );

//--------------------------------------------------------------------------
// Quality mode constants
//--------------------------------------------------------------------------

  TQualityMode = (
    QualityModeInvalid   = -1,
    QualityModeDefault   = 0,
    QualityModeLow       = 1,   // Best performance
    QualityModeHigh      = 2    // Best rendering quality
  );

//--------------------------------------------------------------------------
// Alpha Compositing mode constants
// Alpha 合成方式
//--------------------------------------------------------------------------

  TCompositingMode = (CompositingModeSourceOver,   // 与背景色混合。 混合程度由呈现的颜色的 alpha 成分确定。
                      CompositingModeSourceCopy);  // 改写背景色
//--------------------------------------------------------------------------
// Alpha Compositing quality constants
// Alpha 合成质量
//--------------------------------------------------------------------------

  TCompositingQuality = (
    CompositingQualityInvalid          = Integer(QualityModeInvalid), // 无效质量
    CompositingQualityDefault          = Integer(QualityModeDefault), // 默认质量
    CompositingQualityHighSpeed        = Integer(QualityModeLow),     // 高速度、低质量
    CompositingQualityHighQuality      = Integer(QualityModeHigh),    // 高质量、低速度复合
    CompositingQualityGammaCorrected,                                 // 使用伽玛修正
    CompositingQualityAssumeLinear                                    // 假定线性值
  );
//--------------------------------------------------------------------------
// Unit constants
//--------------------------------------------------------------------------

  TUnit = (
    UnitWorld,      // 0 -- 将全局单位指定为度量单位。
    UnitDisplay,    // 1 -- 将 1/75 英寸指定为度量单位。
    UnitPixel,      // 2 -- 将设备像素指定为度量单位。
    UnitPoint,      // 3 -- 将打印机点（1/72 英寸）指定为度量单位。.
    UnitInch,       // 4 -- 将英寸指定为度量单位
    UnitDocument,   // 5 -- 将文档单位（1/300 英寸）指定为度量单位。
    UnitMillimeter  // 6 -- 将毫米指定为度量单位。
  );
//--------------------------------------------------------------------------
// MetafileFrameUnit
//
// The frameRect for creating a metafile can be specified in any of these
// units.  There is an extra frame unit value (MetafileFrameUnitGdi) so
// that units can be supplied in the same units that GDI expects for
// frame rects -- these units are in .01 (1/100ths) millimeter units
// as defined by GDI.
//--------------------------------------------------------------------------

  TMetafileFrameUnit = (
    MetafileFrameUnitPixel      = Integer(UnitPixel),
    MetafileFrameUnitPoint      = Integer(UnitPoint),
    MetafileFrameUnitInch       = Integer(UnitInch),
    MetafileFrameUnitDocument   = Integer(UnitDocument),
    MetafileFrameUnitMillimeter = Integer(UnitMillimeter),
    MetafileFrameUnitGdi                        // GDI compatible .01 MM units
  );
//--------------------------------------------------------------------------
// Coordinate space identifiers
//--------------------------------------------------------------------------

  TCoordinateSpace = (CoordinateSpaceWorld,  // 指定全局坐标上下文中的坐标。
                      CoordinateSpacePage,   // 指定页坐标上下文中的坐标。由 Graphics.PageUnit 属性定义
                      CoordinateSpaceDevice  // 指定设备坐标上下文中的坐标。
                      );
//--------------------------------------------------------------------------
// Various wrap modes for brushes
//--------------------------------------------------------------------------

  TWrapMode = (WrapModeTile,       // 平铺渐变或纹理。
               WrapModeTileFlipX,  // 水平反转纹理或渐变，然后平铺该纹理或渐变。
               WrapModeTileFlipY,  // 垂直反转纹理或渐变，然后平铺该纹理或渐变。
               WrapModeTileFlipXY, // 水平和垂直反转纹理或渐变，然后平铺该纹理或渐变。
               WrapModeClamp       // 将纹理和渐变向对象边界拉拢。
               );
//--------------------------------------------------------------------------
// Various hatch styles
//--------------------------------------------------------------------------

  THatchStyle = (
    HatchStyleHorizontal,                   // 0
    HatchStyleVertical,                     // 1
    HatchStyleForwardDiagonal,              // 2
    HatchStyleBackwardDiagonal,             // 3
    HatchStyleCross,                        // 4
    HatchStyleDiagonalCross,                // 5
    HatchStyle05Percent,                    // 6
    HatchStyle10Percent,                    // 7
    HatchStyle20Percent,                    // 8
    HatchStyle25Percent,                    // 9
    HatchStyle30Percent,                    // 10
    HatchStyle40Percent,                    // 11
    HatchStyle50Percent,                    // 12
    HatchStyle60Percent,                    // 13
    HatchStyle70Percent,                    // 14
    HatchStyle75Percent,                    // 15
    HatchStyle80Percent,                    // 16
    HatchStyle90Percent,                    // 17
    HatchStyleLightDownwardDiagonal,        // 18
    HatchStyleLightUpwardDiagonal,          // 19
    HatchStyleDarkDownwardDiagonal,         // 20
    HatchStyleDarkUpwardDiagonal,           // 21
    HatchStyleWideDownwardDiagonal,         // 22
    HatchStyleWideUpwardDiagonal,           // 23
    HatchStyleLightVertical,                // 24
    HatchStyleLightHorizontal,              // 25
    HatchStyleNarrowVertical,               // 26
    HatchStyleNarrowHorizontal,             // 27
    HatchStyleDarkVertical,                 // 28
    HatchStyleDarkHorizontal,               // 29
    HatchStyleDashedDownwardDiagonal,       // 30
    HatchStyleDashedUpwardDiagonal,         // 31
    HatchStyleDashedHorizontal,             // 32
    HatchStyleDashedVertical,               // 33
    HatchStyleSmallConfetti,                // 34
    HatchStyleLargeConfetti,                // 35
    HatchStyleZigZag,                       // 36
    HatchStyleWave,                         // 37
    HatchStyleDiagonalBrick,                // 38
    HatchStyleHorizontalBrick,              // 39
    HatchStyleWeave,                        // 40
    HatchStylePlaid,                        // 41
    HatchStyleDivot,                        // 42
    HatchStyleDottedGrid,                   // 43
    HatchStyleDottedDiamond,                // 44
    HatchStyleShingle,                      // 45
    HatchStyleTrellis,                      // 46
    HatchStyleSphere,                       // 47
    HatchStyleSmallGrid,                    // 48
    HatchStyleSmallCheckerBoard,            // 49
    HatchStyleLargeCheckerBoard,            // 50
    HatchStyleOutlinedDiamond,              // 51
    HatchStyleSolidDiamond                 // 52
{
    HatchStyleTotal,
    HatchStyleLargeGrid = HatchStyleCross,  // 4

    HatchStyleMin       = HatchStyleHorizontal,
    HatchStyleMax       = HatchStyleTotal - 1
}
  );
//--------------------------------------------------------------------------
// Dash style constants
//--------------------------------------------------------------------------

  TDashStyle = (DashStyleSolid, DashStyleDash, DashStyleDot,
                DashStyleDashDot, DashStyleDashDotDot, DashStyleCustom);
//--------------------------------------------------------------------------
// Dash cap constants
//--------------------------------------------------------------------------

  TDashCap = (
    DashCapFlat             = 0,
    DashCapRound            = 2,
    DashCapTriangle         = 3
  );
//--------------------------------------------------------------------------
// Line cap constants (only the lowest 8 bits are used).
//--------------------------------------------------------------------------

  TLineCap = (
    LineCapFlat             = 0,   // 平线帽。
    LineCapSquare           = 1,   // 方线帽。
    LineCapRound            = 2,   // 圆线帽
    LineCapTriangle         = 3,   // 三角线帽。
    LineCapNoAnchor         = $10, // 没有锚。
    LineCapSquareAnchor     = $11, // 方锚头帽
    LineCapRoundAnchor      = $12, // 圆锚头帽。
    LineCapDiamondAnchor    = $13, // 菱形锚头帽。
    LineCapArrowAnchor      = $14, // 箭头状锚头帽
    LineCapCustom           = $ff, // 自定义线帽。
    LineCapAnchorMask       = $f0  // 用于检查线帽是否为锚头帽的掩码。
  );
//--------------------------------------------------------------------------
// Custom Line cap type constants
//--------------------------------------------------------------------------

  TCustomLineCapType = (
    CustomLineCapTypeDefault         = 0,
    CustomLineCapTypeAdjustableArrow = 1
  );
//--------------------------------------------------------------------------
// Line join constants
//--------------------------------------------------------------------------

  TLineJoin = (
    LineJoinMiter        = 0, // 斜联接。这将产生一个锐角或切除角
    LineJoinBevel        = 1, // 成斜角的联接。这将产生一个斜角。
    LineJoinRound        = 2, // 圆形联接。这将在两条线之间产生平滑的圆弧。
    LineJoinMiterClipped = 3  // 斜联接。这将产生一个锐角或斜角，
  );
//--------------------------------------------------------------------------
// Path point types (only the lowest 8 bits are used.)
//  The lowest 3 bits are interpreted as point type
//  The higher 5 bits are reserved for flags.
//--------------------------------------------------------------------------
const
    PathPointTypeStart           = 0;    // 指定 Path 的起始点。
    PathPointTypeLine            = 1;    // 指定直线段。
    PathPointTypeBezier          = 3;    // 指定默认的贝塞尔曲线。
    PathPointTypePathTypeMask    = $07;  // 指定掩码点
    PathPointTypeDashMode        = $10;  // 指定对应线段为虚线。
    PathPointTypePathMarker      = $20;  // 指定路径标记。
    PathPointTypeCloseSubpath    = $80;  // 指定子路径的终结点。

    // Path types used for advanced path.

    PathPointTypeBezier3    = 3;          // 指定立方贝塞尔曲线。

//--------------------------------------------------------------------------
// WarpMode constants
//--------------------------------------------------------------------------
type
  TWarpMode = (WarpModePerspective, // 透视环绕。
               WarpModeBilinear     // 双线性环绕。
               );
//--------------------------------------------------------------------------
// LineGradient Mode
//--------------------------------------------------------------------------

  TLinearGradientMode = (
    LinearGradientModeHorizontal,         // 指定从左到右的渐变。
    LinearGradientModeVertical,           // 指定从上到下的渐变。
    LinearGradientModeForwardDiagonal,    // 指定从左上到右下的渐变。
    LinearGradientModeBackwardDiagonal    // 指定从右上到左下的渐变。
  );
//--------------------------------------------------------------------------
// Region Comine Modes
//--------------------------------------------------------------------------

  TCombineMode = (
    CombineModeReplace,     // 一个剪辑区域被另一个剪辑区域替代
    CombineModeIntersect,   // 通过采用两个剪辑区域的交集组合两个剪辑区域
    CombineModeUnion,       // 通过采用两个剪辑区域的联合组合两个剪辑区域
    CombineModeXor,         // 通过只采纳单独由其中一个区域（而非两个区域一起）包括的范围来组合两个剪辑区域
    CombineModeExclude,     // 从现有区域中排除新区域
    CombineModeComplement   // 从新区域中排除现有区域
  );
//--------------------------------------------------------------------------
 // Image types
//--------------------------------------------------------------------------

  TImageType = (ImageTypeUnknown, ImageTypeBitmap, ImageTypeMetafile);

//--------------------------------------------------------------------------
// Interpolation modes
//--------------------------------------------------------------------------

  TInterpolationMode = (
    InterpolationModeInvalid          = Integer(QualityModeInvalid),// 无效
    InterpolationModeDefault          = Integer(QualityModeDefault),// 默认模式
    InterpolationModeLowQuality       = Integer(QualityModeLow),    // 低质量插值法
    InterpolationModeHighQuality      = Integer(QualityModeHigh),   // 高质量插值法
    InterpolationModeBilinear,                                      // 双线性插值法
    InterpolationModeBicubic,                                       // 双三次插值法
    InterpolationModeNearestNeighbor,                               // 最临近插值法
    InterpolationModeHighQualityBilinear,                           // 高质量双线性插值法
    InterpolationModeHighQualityBicubic                             // 高质量双三次插值法
  );
//--------------------------------------------------------------------------
// Pen types
//--------------------------------------------------------------------------

  TPenAlignment = (
    PenAlignmentCenter       = 0,   // 以理论的线条为中心
    PenAlignmentInset        = 1    // 定位于理论的线条内
  );
//--------------------------------------------------------------------------
// Brush types
//--------------------------------------------------------------------------

  TBrushType = (
    BrushTypeSolidColor       = 0,
    BrushTypeHatchFill        = 1,
    BrushTypeTextureFill      = 2,
    BrushTypePathGradient     = 3,
    BrushTypeLinearGradient   = 4
  );
//--------------------------------------------------------------------------
// Pen's Fill types
//--------------------------------------------------------------------------

  TPenType = (
   PenTypeSolidColor       = Integer(BrushTypeSolidColor),
   PenTypeHatchFill        = Integer(BrushTypeHatchFill),
   PenTypeTextureFill      = Integer(BrushTypeTextureFill),
   PenTypePathGradient     = Integer(BrushTypePathGradient),
   PenTypeLinearGradient   = Integer(BrushTypeLinearGradient),
   PenTypeUnknown          = -1
  );
//--------------------------------------------------------------------------
// Matrix Order
//--------------------------------------------------------------------------

  TMatrixOrder = (
    MatrixOrderPrepend    = 0,  // 在旧操作前应用新操作。
    MatrixOrderAppend     = 1   // 在旧操作后应用新操作。
  );
//--------------------------------------------------------------------------
// Generic font families
//--------------------------------------------------------------------------

  TGenericFontFamily = (GenericFontFamilySerif, GenericFontFamilySansSerif,
                        GenericFontFamilyMonospace);

//--------------------------------------------------------------------------
// FontStyle: face types and common styles
//--------------------------------------------------------------------------

const
    FontStyleRegular    = 0;    // 常规
    FontStyleBold       = 1;    // 粗体
    FontStyleItalic     = 2;    // 斜体
    FontStyleBoldItalic = 3;    // 粗斜体
    FontStyleUnderline  = 4;    // 下划线
    FontStyleStrikeout  = 8;    // 删除线

//---------------------------------------------------------------------------
// Smoothing Mode 指定是否将平滑处理（消除锯齿）应用于直线、曲线和已填充区域的边缘。
//---------------------------------------------------------------------------
type
  TSmoothingMode = (
    SmoothingModeInvalid     = Integer(QualityModeInvalid), // 无效模式
    SmoothingModeDefault     = Integer(QualityModeDefault), // 默认模式
    SmoothingModeHighSpeed   = Integer(QualityModeLow),     // 高速度、低质量
    SmoothingModeHighQuality = Integer(QualityModeHigh),    // 高质量、低速度
    SmoothingModeNone,                                      // 不消除锯齿
    SmoothingModeAntiAlias                                  // 消除锯齿
  );
//---------------------------------------------------------------------------
// Pixel Format Mode
//---------------------------------------------------------------------------

  TPixelOffsetMode = (
    PixelOffsetModeInvalid     = Integer(QualityModeInvalid),// 无效
    PixelOffsetModeDefault     = Integer(QualityModeDefault),// 默认
    PixelOffsetModeHighSpeed   = Integer(QualityModeLow),    // 高速度、低质量
    PixelOffsetModeHighQuality = Integer(QualityModeHigh),   // 高质量、低速度
    PixelOffsetModeNone,    // 没有任何像素偏移
    PixelOffsetModeHalf     // 像素在水平和垂直距离上均偏移 -.5 个单位，以进行高速锯齿消除
  );
//---------------------------------------------------------------------------
// Text Rendering Hint
//---------------------------------------------------------------------------

  TTextRenderingHint = (
    TextRenderingHintSystemDefault = 0,            // 为系统选择的所有字体修匀设置来绘制文本。
    TextRenderingHintSingleBitPerPixelGridFit,     // 改善字符在主干和弯曲部分的外观
    TextRenderingHintSingleBitPerPixel,            // 使用标志符号位图来绘制字符。不使用提示。
    TextRenderingHintAntiAliasGridFit,             // 质量较佳，但同时会增加性能成本
    TextRenderingHintAntiAlias,                    // 质量较佳但速度较慢
    TextRenderingHintClearTypeGridFit              // 质量最高的设置。用于利用 ClearType 字体功能
  );
//---------------------------------------------------------------------------
// Metafile Types
//---------------------------------------------------------------------------

  TMetafileType = (
    MetafileTypeInvalid,            // Invalid metafile
    MetafileTypeWmf,                // Standard WMF
    MetafileTypeWmfPlaceable,       // Placeable WMF
    MetafileTypeEmf,                // EMF (not EMF+)
    MetafileTypeEmfPlusOnly,        // EMF+ without dual, down-level records
    MetafileTypeEmfPlusDual         // EMF+ with dual, down-level records
  );

//---------------------------------------------------------------------------
// Specifies the type of EMF to record
//---------------------------------------------------------------------------

  TEmfType = (
    EmfTypeEmfOnly     = Integer(MetafileTypeEmf),         // no EMF+, only EMF
    EmfTypeEmfPlusOnly = Integer(MetafileTypeEmfPlusOnly), // no EMF, only EMF+
    EmfTypeEmfPlusDual = Integer(MetafileTypeEmfPlusDual)  // both EMF+ and EMF
  );
//---------------------------------------------------------------------------
// EMF+ Persistent object types
//---------------------------------------------------------------------------

  TObjectType = (
    ObjectTypeInvalid,
    ObjectTypeBrush,
    ObjectTypePen,
    ObjectTypePath,
    ObjectTypeRegion,
    ObjectTypeImage,
    ObjectTypeFont,
    ObjectTypeStringFormat,
    ObjectTypeImageAttributes,
    ObjectTypeCustomLineCap,

    ObjectTypeMax = ObjectTypeCustomLineCap,
    ObjectTypeMin = ObjectTypeBrush
  );

  function ObjectTypeIsValid(AType: TObjectType): BOOL;

//---------------------------------------------------------------------------
// EMF+ Records
//---------------------------------------------------------------------------

// We have to change the WMF record numbers so that they don't conflict with
// the EMF and EMF+ record numbers.

const
  GDIP_EMFPLUS_RECORD_BASE       = $00004000;
  {$EXTERNALSYM GDIP_EMFPLUS_RECORD_BASE}
  GDIP_WMF_RECORD_BASE           = $00010000;
  {$EXTERNALSYM GDIP_WMF_RECORD_BASE}
  function GDIP_EMFPLUS_RECORD_TO_WMF(n: Integer): Integer;
  function GDIP_IS_WMF_RECORDTYPE(n: Integer): BOOL;

type
  TEmfPlusRecordType = (
   // Since we have to enumerate GDI records right along with GDI+ records,
   // We list all the GDI records here so that they can be part of the
   // same enumeration type which is used in the enumeration callback.

    WmfRecordTypeSetBkColor              = (GDIP_WMF_RECORD_BASE or META_SETBKCOLOR),
    WmfRecordTypeSetBkMode               = (GDIP_WMF_RECORD_BASE or META_SETBKMODE),
    WmfRecordTypeSetMapMode              = (GDIP_WMF_RECORD_BASE or META_SETMAPMODE),
    WmfRecordTypeSetROP2                 = (GDIP_WMF_RECORD_BASE or META_SETROP2),
    WmfRecordTypeSetRelAbs               = (GDIP_WMF_RECORD_BASE or META_SETRELABS),
    WmfRecordTypeSetPolyFillMode         = (GDIP_WMF_RECORD_BASE or META_SETPOLYFILLMODE),
    WmfRecordTypeSetStretchBltMode       = (GDIP_WMF_RECORD_BASE or META_SETSTRETCHBLTMODE),
    WmfRecordTypeSetTextCharExtra        = (GDIP_WMF_RECORD_BASE or META_SETTEXTCHAREXTRA),
    WmfRecordTypeSetTextColor            = (GDIP_WMF_RECORD_BASE or META_SETTEXTCOLOR),
    WmfRecordTypeSetTextJustification    = (GDIP_WMF_RECORD_BASE or META_SETTEXTJUSTIFICATION),
    WmfRecordTypeSetWindowOrg            = (GDIP_WMF_RECORD_BASE or META_SETWINDOWORG),
    WmfRecordTypeSetWindowExt            = (GDIP_WMF_RECORD_BASE or META_SETWINDOWEXT),
    WmfRecordTypeSetViewportOrg          = (GDIP_WMF_RECORD_BASE or META_SETVIEWPORTORG),
    WmfRecordTypeSetViewportExt          = (GDIP_WMF_RECORD_BASE or META_SETVIEWPORTEXT),
    WmfRecordTypeOffsetWindowOrg         = (GDIP_WMF_RECORD_BASE or META_OFFSETWINDOWORG),
    WmfRecordTypeScaleWindowExt          = (GDIP_WMF_RECORD_BASE or META_SCALEWINDOWEXT),
    WmfRecordTypeOffsetViewportOrg       = (GDIP_WMF_RECORD_BASE or META_OFFSETVIEWPORTORG),
    WmfRecordTypeScaleViewportExt        = (GDIP_WMF_RECORD_BASE or META_SCALEVIEWPORTEXT),
    WmfRecordTypeLineTo                  = (GDIP_WMF_RECORD_BASE or META_LINETO),
    WmfRecordTypeMoveTo                  = (GDIP_WMF_RECORD_BASE or META_MOVETO),
    WmfRecordTypeExcludeClipRect         = (GDIP_WMF_RECORD_BASE or META_EXCLUDECLIPRECT),
    WmfRecordTypeIntersectClipRect       = (GDIP_WMF_RECORD_BASE or META_INTERSECTCLIPRECT),
    WmfRecordTypeArc                     = (GDIP_WMF_RECORD_BASE or META_ARC),
    WmfRecordTypeEllipse                 = (GDIP_WMF_RECORD_BASE or META_ELLIPSE),
    WmfRecordTypeFloodFill               = (GDIP_WMF_RECORD_BASE or META_FLOODFILL),
    WmfRecordTypePie                     = (GDIP_WMF_RECORD_BASE or META_PIE),
    WmfRecordTypeRectangle               = (GDIP_WMF_RECORD_BASE or META_RECTANGLE),
    WmfRecordTypeRoundRect               = (GDIP_WMF_RECORD_BASE or META_ROUNDRECT),
    WmfRecordTypePatBlt                  = (GDIP_WMF_RECORD_BASE or META_PATBLT),
    WmfRecordTypeSaveDC                  = (GDIP_WMF_RECORD_BASE or META_SAVEDC),
    WmfRecordTypeSetPixel                = (GDIP_WMF_RECORD_BASE or META_SETPIXEL),
    WmfRecordTypeOffsetClipRgn           = (GDIP_WMF_RECORD_BASE or META_OFFSETCLIPRGN),
    WmfRecordTypeTextOut                 = (GDIP_WMF_RECORD_BASE or META_TEXTOUT),
    WmfRecordTypeBitBlt                  = (GDIP_WMF_RECORD_BASE or META_BITBLT),
    WmfRecordTypeStretchBlt              = (GDIP_WMF_RECORD_BASE or META_STRETCHBLT),
    WmfRecordTypePolygon                 = (GDIP_WMF_RECORD_BASE or META_POLYGON),
    WmfRecordTypePolyline                = (GDIP_WMF_RECORD_BASE or META_POLYLINE),
    WmfRecordTypeEscape                  = (GDIP_WMF_RECORD_BASE or META_ESCAPE),
    WmfRecordTypeRestoreDC               = (GDIP_WMF_RECORD_BASE or META_RESTOREDC),
    WmfRecordTypeFillRegion              = (GDIP_WMF_RECORD_BASE or META_FILLREGION),
    WmfRecordTypeFrameRegion             = (GDIP_WMF_RECORD_BASE or META_FRAMEREGION),
    WmfRecordTypeInvertRegion            = (GDIP_WMF_RECORD_BASE or META_INVERTREGION),
    WmfRecordTypePaintRegion             = (GDIP_WMF_RECORD_BASE or META_PAINTREGION),
    WmfRecordTypeSelectClipRegion        = (GDIP_WMF_RECORD_BASE or META_SELECTCLIPREGION),
    WmfRecordTypeSelectObject            = (GDIP_WMF_RECORD_BASE or META_SELECTOBJECT),
    WmfRecordTypeSetTextAlign            = (GDIP_WMF_RECORD_BASE or META_SETTEXTALIGN),
    WmfRecordTypeDrawText                = (GDIP_WMF_RECORD_BASE or $062F),  // META_DRAWTEXT
    WmfRecordTypeChord                   = (GDIP_WMF_RECORD_BASE or META_CHORD),
    WmfRecordTypeSetMapperFlags          = (GDIP_WMF_RECORD_BASE or META_SETMAPPERFLAGS),
    WmfRecordTypeExtTextOut              = (GDIP_WMF_RECORD_BASE or META_EXTTEXTOUT),
    WmfRecordTypeSetDIBToDev             = (GDIP_WMF_RECORD_BASE or META_SETDIBTODEV),
    WmfRecordTypeSelectPalette           = (GDIP_WMF_RECORD_BASE or META_SELECTPALETTE),
    WmfRecordTypeRealizePalette          = (GDIP_WMF_RECORD_BASE or META_REALIZEPALETTE),
    WmfRecordTypeAnimatePalette          = (GDIP_WMF_RECORD_BASE or META_ANIMATEPALETTE),
    WmfRecordTypeSetPalEntries           = (GDIP_WMF_RECORD_BASE or META_SETPALENTRIES),
    WmfRecordTypePolyPolygon             = (GDIP_WMF_RECORD_BASE or META_POLYPOLYGON),
    WmfRecordTypeResizePalette           = (GDIP_WMF_RECORD_BASE or META_RESIZEPALETTE),
    WmfRecordTypeDIBBitBlt               = (GDIP_WMF_RECORD_BASE or META_DIBBITBLT),
    WmfRecordTypeDIBStretchBlt           = (GDIP_WMF_RECORD_BASE or META_DIBSTRETCHBLT),
    WmfRecordTypeDIBCreatePatternBrush   = (GDIP_WMF_RECORD_BASE or META_DIBCREATEPATTERNBRUSH),
    WmfRecordTypeStretchDIB              = (GDIP_WMF_RECORD_BASE or META_STRETCHDIB),
    WmfRecordTypeExtFloodFill            = (GDIP_WMF_RECORD_BASE or META_EXTFLOODFILL),
    WmfRecordTypeSetLayout               = (GDIP_WMF_RECORD_BASE or $0149),  // META_SETLAYOUT
    WmfRecordTypeResetDC                 = (GDIP_WMF_RECORD_BASE or $014C),  // META_RESETDC
    WmfRecordTypeStartDoc                = (GDIP_WMF_RECORD_BASE or $014D),  // META_STARTDOC
    WmfRecordTypeStartPage               = (GDIP_WMF_RECORD_BASE or $004F),  // META_STARTPAGE
    WmfRecordTypeEndPage                 = (GDIP_WMF_RECORD_BASE or $0050),  // META_ENDPAGE
    WmfRecordTypeAbortDoc                = (GDIP_WMF_RECORD_BASE or $0052),  // META_ABORTDOC
    WmfRecordTypeEndDoc                  = (GDIP_WMF_RECORD_BASE or $005E),  // META_ENDDOC
    WmfRecordTypeDeleteObject            = (GDIP_WMF_RECORD_BASE or META_DELETEOBJECT),
    WmfRecordTypeCreatePalette           = (GDIP_WMF_RECORD_BASE or META_CREATEPALETTE),
    WmfRecordTypeCreateBrush             = (GDIP_WMF_RECORD_BASE or $00F8),  // META_CREATEBRUSH
    WmfRecordTypeCreatePatternBrush      = (GDIP_WMF_RECORD_BASE or META_CREATEPATTERNBRUSH),
    WmfRecordTypeCreatePenIndirect       = (GDIP_WMF_RECORD_BASE or META_CREATEPENINDIRECT),
    WmfRecordTypeCreateFontIndirect      = (GDIP_WMF_RECORD_BASE or META_CREATEFONTINDIRECT),
    WmfRecordTypeCreateBrushIndirect     = (GDIP_WMF_RECORD_BASE or META_CREATEBRUSHINDIRECT),
    WmfRecordTypeCreateBitmapIndirect    = (GDIP_WMF_RECORD_BASE or $02FD),  // META_CREATEBITMAPINDIRECT
    WmfRecordTypeCreateBitmap            = (GDIP_WMF_RECORD_BASE or $06FE),  // META_CREATEBITMAP
    WmfRecordTypeCreateRegion            = (GDIP_WMF_RECORD_BASE or META_CREATEREGION),

    EmfRecordTypeHeader                  = EMR_HEADER,
    EmfRecordTypePolyBezier              = EMR_POLYBEZIER,
    EmfRecordTypePolygon                 = EMR_POLYGON,
    EmfRecordTypePolyline                = EMR_POLYLINE,
    EmfRecordTypePolyBezierTo            = EMR_POLYBEZIERTO,
    EmfRecordTypePolyLineTo              = EMR_POLYLINETO,
    EmfRecordTypePolyPolyline            = EMR_POLYPOLYLINE,
    EmfRecordTypePolyPolygon             = EMR_POLYPOLYGON,
    EmfRecordTypeSetWindowExtEx          = EMR_SETWINDOWEXTEX,
    EmfRecordTypeSetWindowOrgEx          = EMR_SETWINDOWORGEX,
    EmfRecordTypeSetViewportExtEx        = EMR_SETVIEWPORTEXTEX,
    EmfRecordTypeSetViewportOrgEx        = EMR_SETVIEWPORTORGEX,
    EmfRecordTypeSetBrushOrgEx           = EMR_SETBRUSHORGEX,
    EmfRecordTypeEOF                     = EMR_EOF,
    EmfRecordTypeSetPixelV               = EMR_SETPIXELV,
    EmfRecordTypeSetMapperFlags          = EMR_SETMAPPERFLAGS,
    EmfRecordTypeSetMapMode              = EMR_SETMAPMODE,
    EmfRecordTypeSetBkMode               = EMR_SETBKMODE,
    EmfRecordTypeSetPolyFillMode         = EMR_SETPOLYFILLMODE,
    EmfRecordTypeSetROP2                 = EMR_SETROP2,
    EmfRecordTypeSetStretchBltMode       = EMR_SETSTRETCHBLTMODE,
    EmfRecordTypeSetTextAlign            = EMR_SETTEXTALIGN,
    EmfRecordTypeSetColorAdjustment      = EMR_SETCOLORADJUSTMENT,
    EmfRecordTypeSetTextColor            = EMR_SETTEXTCOLOR,
    EmfRecordTypeSetBkColor              = EMR_SETBKCOLOR,
    EmfRecordTypeOffsetClipRgn           = EMR_OFFSETCLIPRGN,
    EmfRecordTypeMoveToEx                = EMR_MOVETOEX,
    EmfRecordTypeSetMetaRgn              = EMR_SETMETARGN,
    EmfRecordTypeExcludeClipRect         = EMR_EXCLUDECLIPRECT,
    EmfRecordTypeIntersectClipRect       = EMR_INTERSECTCLIPRECT,
    EmfRecordTypeScaleViewportExtEx      = EMR_SCALEVIEWPORTEXTEX,
    EmfRecordTypeScaleWindowExtEx        = EMR_SCALEWINDOWEXTEX,
    EmfRecordTypeSaveDC                  = EMR_SAVEDC,
    EmfRecordTypeRestoreDC               = EMR_RESTOREDC,
    EmfRecordTypeSetWorldTransform       = EMR_SETWORLDTRANSFORM,
    EmfRecordTypeModifyWorldTransform    = EMR_MODIFYWORLDTRANSFORM,
    EmfRecordTypeSelectObject            = EMR_SELECTOBJECT,
    EmfRecordTypeCreatePen               = EMR_CREATEPEN,
    EmfRecordTypeCreateBrushIndirect     = EMR_CREATEBRUSHINDIRECT,
    EmfRecordTypeDeleteObject            = EMR_DELETEOBJECT,
    EmfRecordTypeAngleArc                = EMR_ANGLEARC,
    EmfRecordTypeEllipse                 = EMR_ELLIPSE,
    EmfRecordTypeRectangle               = EMR_RECTANGLE,
    EmfRecordTypeRoundRect               = EMR_ROUNDRECT,
    EmfRecordTypeArc                     = EMR_ARC,
    EmfRecordTypeChord                   = EMR_CHORD,
    EmfRecordTypePie                     = EMR_PIE,
    EmfRecordTypeSelectPalette           = EMR_SELECTPALETTE,
    EmfRecordTypeCreatePalette           = EMR_CREATEPALETTE,
    EmfRecordTypeSetPaletteEntries       = EMR_SETPALETTEENTRIES,
    EmfRecordTypeResizePalette           = EMR_RESIZEPALETTE,
    EmfRecordTypeRealizePalette          = EMR_REALIZEPALETTE,
    EmfRecordTypeExtFloodFill            = EMR_EXTFLOODFILL,
    EmfRecordTypeLineTo                  = EMR_LINETO,
    EmfRecordTypeArcTo                   = EMR_ARCTO,
    EmfRecordTypePolyDraw                = EMR_POLYDRAW,
    EmfRecordTypeSetArcDirection         = EMR_SETARCDIRECTION,
    EmfRecordTypeSetMiterLimit           = EMR_SETMITERLIMIT,
    EmfRecordTypeBeginPath               = EMR_BEGINPATH,
    EmfRecordTypeEndPath                 = EMR_ENDPATH,
    EmfRecordTypeCloseFigure             = EMR_CLOSEFIGURE,
    EmfRecordTypeFillPath                = EMR_FILLPATH,
    EmfRecordTypeStrokeAndFillPath       = EMR_STROKEANDFILLPATH,
    EmfRecordTypeStrokePath              = EMR_STROKEPATH,
    EmfRecordTypeFlattenPath             = EMR_FLATTENPATH,
    EmfRecordTypeWidenPath               = EMR_WIDENPATH,
    EmfRecordTypeSelectClipPath          = EMR_SELECTCLIPPATH,
    EmfRecordTypeAbortPath               = EMR_ABORTPATH,
    EmfRecordTypeReserved_069            = 69,  // Not Used
    EmfRecordTypeGdiComment              = EMR_GDICOMMENT,
    EmfRecordTypeFillRgn                 = EMR_FILLRGN,
    EmfRecordTypeFrameRgn                = EMR_FRAMERGN,
    EmfRecordTypeInvertRgn               = EMR_INVERTRGN,
    EmfRecordTypePaintRgn                = EMR_PAINTRGN,
    EmfRecordTypeExtSelectClipRgn        = EMR_EXTSELECTCLIPRGN,
    EmfRecordTypeBitBlt                  = EMR_BITBLT,
    EmfRecordTypeStretchBlt              = EMR_STRETCHBLT,
    EmfRecordTypeMaskBlt                 = EMR_MASKBLT,
    EmfRecordTypePlgBlt                  = EMR_PLGBLT,
    EmfRecordTypeSetDIBitsToDevice       = EMR_SETDIBITSTODEVICE,
    EmfRecordTypeStretchDIBits           = EMR_STRETCHDIBITS,
    EmfRecordTypeExtCreateFontIndirect   = EMR_EXTCREATEFONTINDIRECTW,
    EmfRecordTypeExtTextOutA             = EMR_EXTTEXTOUTA,
    EmfRecordTypeExtTextOutW             = EMR_EXTTEXTOUTW,
    EmfRecordTypePolyBezier16            = EMR_POLYBEZIER16,
    EmfRecordTypePolygon16               = EMR_POLYGON16,
    EmfRecordTypePolyline16              = EMR_POLYLINE16,
    EmfRecordTypePolyBezierTo16          = EMR_POLYBEZIERTO16,
    EmfRecordTypePolylineTo16            = EMR_POLYLINETO16,
    EmfRecordTypePolyPolyline16          = EMR_POLYPOLYLINE16,
    EmfRecordTypePolyPolygon16           = EMR_POLYPOLYGON16,
    EmfRecordTypePolyDraw16              = EMR_POLYDRAW16,
    EmfRecordTypeCreateMonoBrush         = EMR_CREATEMONOBRUSH,
    EmfRecordTypeCreateDIBPatternBrushPt = EMR_CREATEDIBPATTERNBRUSHPT,
    EmfRecordTypeExtCreatePen            = EMR_EXTCREATEPEN,
    EmfRecordTypePolyTextOutA            = EMR_POLYTEXTOUTA,
    EmfRecordTypePolyTextOutW            = EMR_POLYTEXTOUTW,
    EmfRecordTypeSetICMMode              = 98,  // EMR_SETICMMODE,
    EmfRecordTypeCreateColorSpace        = 99,  // EMR_CREATECOLORSPACE,
    EmfRecordTypeSetColorSpace           = 100, // EMR_SETCOLORSPACE,
    EmfRecordTypeDeleteColorSpace        = 101, // EMR_DELETECOLORSPACE,
    EmfRecordTypeGLSRecord               = 102, // EMR_GLSRECORD,
    EmfRecordTypeGLSBoundedRecord        = 103, // EMR_GLSBOUNDEDRECORD,
    EmfRecordTypePixelFormat             = 104, // EMR_PIXELFORMAT,
    EmfRecordTypeDrawEscape              = 105, // EMR_RESERVED_105,
    EmfRecordTypeExtEscape               = 106, // EMR_RESERVED_106,
    EmfRecordTypeStartDoc                = 107, // EMR_RESERVED_107,
    EmfRecordTypeSmallTextOut            = 108, // EMR_RESERVED_108,
    EmfRecordTypeForceUFIMapping         = 109, // EMR_RESERVED_109,
    EmfRecordTypeNamedEscape             = 110, // EMR_RESERVED_110,
    EmfRecordTypeColorCorrectPalette     = 111, // EMR_COLORCORRECTPALETTE,
    EmfRecordTypeSetICMProfileA          = 112, // EMR_SETICMPROFILEA,
    EmfRecordTypeSetICMProfileW          = 113, // EMR_SETICMPROFILEW,
    EmfRecordTypeAlphaBlend              = 114, // EMR_ALPHABLEND,
    EmfRecordTypeSetLayout               = 115, // EMR_SETLAYOUT,
    EmfRecordTypeTransparentBlt          = 116, // EMR_TRANSPARENTBLT,
    EmfRecordTypeReserved_117            = 117, // Not Used
    EmfRecordTypeGradientFill            = 118, // EMR_GRADIENTFILL,
    EmfRecordTypeSetLinkedUFIs           = 119, // EMR_RESERVED_119,
    EmfRecordTypeSetTextJustification    = 120, // EMR_RESERVED_120,
    EmfRecordTypeColorMatchToTargetW     = 121, // EMR_COLORMATCHTOTARGETW,
    EmfRecordTypeCreateColorSpaceW       = 122, // EMR_CREATECOLORSPACEW,
    EmfRecordTypeMax                     = 122,
    EmfRecordTypeMin                     = 1,

    // That is the END of the GDI EMF records.

    // Now we start the list of EMF+ records.  We leave quite
    // a bit of room here for the addition of any new GDI
    // records that may be added later.

    EmfPlusRecordTypeInvalid = GDIP_EMFPLUS_RECORD_BASE,
    EmfPlusRecordTypeHeader,
    EmfPlusRecordTypeEndOfFile,

    EmfPlusRecordTypeComment,

    EmfPlusRecordTypeGetDC,

    EmfPlusRecordTypeMultiFormatStart,
    EmfPlusRecordTypeMultiFormatSection,
    EmfPlusRecordTypeMultiFormatEnd,

    // For all persistent objects

    EmfPlusRecordTypeObject,

    // Drawing Records

    EmfPlusRecordTypeClear,
    EmfPlusRecordTypeFillRects,
    EmfPlusRecordTypeDrawRects,
    EmfPlusRecordTypeFillPolygon,
    EmfPlusRecordTypeDrawLines,
    EmfPlusRecordTypeFillEllipse,
    EmfPlusRecordTypeDrawEllipse,
    EmfPlusRecordTypeFillPie,
    EmfPlusRecordTypeDrawPie,
    EmfPlusRecordTypeDrawArc,
    EmfPlusRecordTypeFillRegion,
    EmfPlusRecordTypeFillPath,
    EmfPlusRecordTypeDrawPath,
    EmfPlusRecordTypeFillClosedCurve,
    EmfPlusRecordTypeDrawClosedCurve,
    EmfPlusRecordTypeDrawCurve,
    EmfPlusRecordTypeDrawBeziers,
    EmfPlusRecordTypeDrawImage,
    EmfPlusRecordTypeDrawImagePoints,
    EmfPlusRecordTypeDrawString,

    // Graphics State Records

    EmfPlusRecordTypeSetRenderingOrigin,
    EmfPlusRecordTypeSetAntiAliasMode,
    EmfPlusRecordTypeSetTextRenderingHint,
    EmfPlusRecordTypeSetTextContrast,
    EmfPlusRecordTypeSetInterpolationMode,
    EmfPlusRecordTypeSetPixelOffsetMode,
    EmfPlusRecordTypeSetCompositingMode,
    EmfPlusRecordTypeSetCompositingQuality,
    EmfPlusRecordTypeSave,
    EmfPlusRecordTypeRestore,
    EmfPlusRecordTypeBeginContainer,
    EmfPlusRecordTypeBeginContainerNoParams,
    EmfPlusRecordTypeEndContainer,
    EmfPlusRecordTypeSetWorldTransform,
    EmfPlusRecordTypeResetWorldTransform,
    EmfPlusRecordTypeMultiplyWorldTransform,
    EmfPlusRecordTypeTranslateWorldTransform,
    EmfPlusRecordTypeScaleWorldTransform,
    EmfPlusRecordTypeRotateWorldTransform,
    EmfPlusRecordTypeSetPageTransform,
    EmfPlusRecordTypeResetClip,
    EmfPlusRecordTypeSetClipRect,
    EmfPlusRecordTypeSetClipPath,
    EmfPlusRecordTypeSetClipRegion,
    EmfPlusRecordTypeOffsetClip,

    EmfPlusRecordTypeDrawDriverString,

    EmfPlusRecordTotal,

    EmfPlusRecordTypeMax = EmfPlusRecordTotal-1,
    EmfPlusRecordTypeMin = EmfPlusRecordTypeHeader
  );

  function GDIP_WMF_RECORD_TO_EMFPLUS(n: Integer): TEmfPlusRecordType;

//---------------------------------------------------------------------------
// StringFormatFlags
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
// String format flags
//
//  DirectionRightToLeft          - For horizontal text, the reading order is
//                                  right to left. This value is called
//                                  the base embedding level by the Unicode
//                                  bidirectional engine.
//                                  For vertical text, columns are read from
//                                  right to left.
//                                  By default, horizontal or vertical text is
//                                  read from left to right.
//
//  DirectionVertical             - Individual lines of text are vertical. In
//                                  each line, characters progress from top to
//                                  bottom.
//                                  By default, lines of text are horizontal,
//                                  each new line below the previous line.
//
//  NoFitBlackBox                 - Allows parts of glyphs to overhang the
//                                  bounding rectangle.
//                                  By default glyphs are first aligned
//                                  inside the margines, then any glyphs which
//                                  still overhang the bounding box are
//                                  repositioned to avoid any overhang.
//                                  For example when an italic
//                                  lower case letter f in a font such as
//                                  Garamond is aligned at the far left of a
//                                  rectangle, the lower part of the f will
//                                  reach slightly further left than the left
//                                  edge of the rectangle. Setting this flag
//                                  will ensure the character aligns visually
//                                  with the lines above and below, but may
//                                  cause some pixels outside the formatting
//                                  rectangle to be clipped or painted.
//
//  DisplayFormatControl          - Causes control characters such as the
//                                  left-to-right mark to be shown in the
//                                  output with a representative glyph.
//
//  NoFontFallback                - Disables fallback to alternate fonts for
//                                  characters not supported in the requested
//                                  font. Any missing characters will be
//                                  be displayed with the fonts missing glyph,
//                                  usually an open square.
//
//  NoWrap                        - Disables wrapping of text between lines
//                                  when formatting within a rectangle.
//                                  NoWrap is implied when a point is passed
//                                  instead of a rectangle, or when the
//                                  specified rectangle has a zero line length.
//
//  NoClip                        - By default text is clipped to the
//                                  formatting rectangle. Setting NoClip
//                                  allows overhanging pixels to affect the
//                                  device outside the formatting rectangle.
//                                  Pixels at the end of the line may be
//                                  affected if the glyphs overhang their
//                                  cells, and either the NoFitBlackBox flag
//                                  has been set, or the glyph extends to far
//                                  to be fitted.
//                                  Pixels above/before the first line or
//                                  below/after the last line may be affected
//                                  if the glyphs extend beyond their cell
//                                  ascent / descent. This can occur rarely
//                                  with unusual diacritic mark combinations.

//---------------------------------------------------------------------------

const
    StringFormatFlagsDirectionRightToLeft        = $00000001; // 文本从右到左排列
    StringFormatFlagsDirectionVertical           = $00000002; // 文本垂直排列
    StringFormatFlagsNoFitBlackBox               = $00000004; // 任何标志符号的任何部分都不突出边框
    StringFormatFlagsDisplayFormatControl        = $00000020; // 控制字符随具有代表性的标志符号一起显示在输出中
    StringFormatFlagsNoFontFallback              = $00000400; // 缺失的字符都用缺失标志符号的字体显示
    // 在默认情况下，MeasureString 方法返回的边框都将排除每一行结尾处的空格。
    // 设置此标记以便在测定时将空格包括进去。
    StringFormatFlagsMeasureTrailingSpaces       = $00000800;
    StringFormatFlagsNoWrap                      = $00001000; // 在矩形中进行格式化时禁用文本换行
    StringFormatFlagsLineLimit                   = $00002000; // 确保看到的都是整行
    // 允许显示标志符号的伸出部分和延伸到边框外的未换行文本
    StringFormatFlagsNoClip                      = $00004000;

//---------------------------------------------------------------------------
// StringTrimming
//---------------------------------------------------------------------------
type
  TStringTrimming  = (
    StringTrimmingNone              = 0, // 不进行任何修整
    StringTrimmingCharacter         = 1, // 将文本修整成最接近的字符
    StringTrimmingWord              = 2, // 将文本修整成最接近的单词
    StringTrimmingEllipsisCharacter = 3, // 将文本修整成最接近的字符，并在行的末尾插入一个省略号。
    StringTrimmingEllipsisWord      = 4, // 将文本修整成最接近的单词，并在行的末尾插入一个省略号
    StringTrimmingEllipsisPath      = 5  // 中心从被修整的行移除并用省略号替换
  );
//---------------------------------------------------------------------------
// National language digit substitution
//---------------------------------------------------------------------------

  TStringDigitSubstitute = (
    StringDigitSubstituteUser        = 0, // 指定用户定义的替换方案。
    StringDigitSubstituteNone        = 1, // 指定禁用替换。
    StringDigitSubstituteNational    = 2, // 指定与用户区域设置的正式国家/地区语言相对应的替换数字位。
    StringDigitSubstituteTraditional = 3  // 指定与用户的本机脚本或语言相对应的替换数字位
  );
//---------------------------------------------------------------------------
// Hotkey prefix interpretation
//---------------------------------------------------------------------------

  THotkeyPrefix = (
    HotkeyPrefixNone        = 0,
    HotkeyPrefixShow        = 1,
    HotkeyPrefixHide        = 2
  );
//---------------------------------------------------------------------------
// String alignment flags
//---------------------------------------------------------------------------

  TStringAlignment = (
    // 在左到右布局中，远端位置是右。在右到左布局中，远端位置是左。
    StringAlignmentNear   = 0, // 文本近端对齐
    StringAlignmentCenter = 1, // 文本居中对齐
    StringAlignmentFar    = 2  // 文本远端对齐
  );
//---------------------------------------------------------------------------
// DriverStringOptions
//---------------------------------------------------------------------------

  TDriverStringOptions = (
    DriverStringOptionsCmapLookup             = 1,
    DriverStringOptionsVertical               = 2,
    DriverStringOptionsRealizedAdvance        = 4,
    DriverStringOptionsLimitSubpixel          = 8
  );

//---------------------------------------------------------------------------
// Flush Intention flags
//---------------------------------------------------------------------------

  TFlushIntention = (
    FlushIntentionFlush = 0,        // 立即刷新所有图形操作的堆栈
    FlushIntentionSync = 1          // 尽快执行堆栈上的所有图形操作。这将同步图形状态。
  );
//---------------------------------------------------------------------------
// Image encoder parameter related types
//---------------------------------------------------------------------------

  TEncoderParameterValueType = (
    EncoderParameterValueTypeByte           = 1,    // 数组中的每个值都是 8 位无符号整数
    EncoderParameterValueTypeASCII          = 2,    // 一个空终止的 ASCII 字符串,
                                                    // NumberOfValues 包括 NULL 结束符在内的字符串长度
    EncoderParameterValueTypeShort          = 3,    // 数组中的每个值都是 16 位无符号整数
    EncoderParameterValueTypeLong           = 4,    // 数组中的每个值都是 32 位无符号整数
    EncoderParameterValueTypeRational       = 5,    // 数组中的每一个值都是一对 32 位无符号整数,
                                                    // 每一对都表示一个分数,
                                                    // 第一个整数是分子，第二个整数是分母.
    EncoderParameterValueTypeLongRange      = 6,    // 数组中的每一个值都是一对 32 位无符号整数,
                                                    // 每一对都表示一个数字区域.
    EncoderParameterValueTypeUndefined      = 7,    // 值的数组是没有定义数据类型的字节的数组
    EncoderParameterValueTypeRationalRange  = 8     // 数组中的每一个值都是一组四个 32 位无符号整数,
                                                    // 前两个整数表示一个分数，后两个整数表示第二个分数,
                                                    // 这两个分数表示一个有理数区域,
                                                    // 第一个分数是该区域中最小的有理数,
                                                    // 第二个分数是该区域中最大的有理数.
  );

//---------------------------------------------------------------------------
// Image encoder value types
//---------------------------------------------------------------------------

  TEncoderValue = (
    EncoderValueColorTypeCMYK,
    EncoderValueColorTypeYCCK,
    EncoderValueCompressionLZW,          // LZW 压缩方案。可以作为属于压缩类别的参数传递到 TIFF 编码器。
    EncoderValueCompressionCCITT3,       // CCITT3 压缩方案。可以作为属于压缩类别的参数传递到 TIFF 编码器。
    EncoderValueCompressionCCITT4,       // CCITT4 压缩方案。可以作为属于压缩类别的参数传递到 TIFF 编码器。
    EncoderValueCompressionRle,          // RLE 压缩方案。可以作为属于压缩类别的参数传递到 TIFF 编码器。
    EncoderValueCompressionNone,         // 不指定压缩。可以作为属于压缩类别的参数传递到 TIFF 编码器。
    EncoderValueScanMethodInterlaced,
    EncoderValueScanMethodNonInterlaced,
    EncoderValueVersionGif87,
    EncoderValueVersionGif89,
    EncoderValueRenderProgressive,
    EncoderValueRenderNonProgressive,
    EncoderValueTransformRotate90,       // 图像将围绕其中心沿顺时针方向旋转 90 度。可以作为属于转换类别的参数传递到 JPEG 编码器
    EncoderValueTransformRotate180,      // 图像围绕其中心旋转 180 度。可以作为属于转换类别的参数传递到 JPEG 编码器。
    EncoderValueTransformRotate270,      // 图像围绕其中心沿顺时针方向旋转 270 度。可以作为属于转换类别的参数传递到 JPEG 编码器
    EncoderValueTransformFlipHorizontal, // 图像水平翻转。可以作为属于转换类别的参数传递到 JPEG 编码器。
    EncoderValueTransformFlipVertical,   // 图像垂直翻转。可以作为属于转换类别的参数传递到 JPEG 编码器。
    EncoderValueMultiFrame,              // 图像有多于 1 帧（页面）。可以作为属于保存标志类别的参数传递到 TIFF 编码器
    EncoderValueLastFrame,               // 指定多帧图像中的最后一帧。可以作为属于保存标志类别的参数传递到 TIFF 编码器。
    EncoderValueFlush,                   // 应关闭一个多帧文件或流。可以作为属于保存标志类别的参数传递到 TIFF 编码器
    EncoderValueFrameDimensionTime,
    EncoderValueFrameDimensionResolution,
    EncoderValueFrameDimensionPage       // 将一帧添加到图像的页面维度。可以作为属于保存标志类别的参数传递到 TIFF 编码器。
  );

//---------------------------------------------------------------------------
// Conversion of Emf To WMF Bits flags
//---------------------------------------------------------------------------

  TEmfToWmfBitsFlags = (
    EmfToWmfBitsFlagsDefault          = $00000000,
    EmfToWmfBitsFlagsEmbedEmf         = $00000001,
    EmfToWmfBitsFlagsIncludePlaceable = $00000002,
    EmfToWmfBitsFlagsNoXORClip        = $00000004
  );

//--------------------------------------------------------------------------
// Callback functions
//--------------------------------------------------------------------------
type
  TImageAbort = function: BOOL; stdcall;
  TDrawImageAbort = TImageAbort;
  TGetThumbnailImageAbort = TImageAbort;

// Callback for EnumerateMetafile methods.  The parameters are:

//      recordType      WMF, EMF, or EMF+ record type
//      flags           (always 0 for WMF/EMF records)
//      dataSize        size of the record data (in bytes), or 0 if no data
//      data            pointer to the record data, or NULL if no data
//      callbackData    pointer to callbackData, if any

// This method can then call Metafile::PlayRecord to play the
// record that was just enumerated.  If this method  returns
// FALSE, the enumeration process is aborted.  Otherwise, it continues.

  TEnumerateMetafileProc = function(v1: TEmfPlusRecordType;
      v2, v3: UINT; const v4: PByte; v5: Pointer): BOOL; stdcall;

//--------------------------------------------------------------------------
// Primitive data types
//
// NOTE:
//  Types already defined in standard header files:
//      INT8
//      UINT8
//      INT16
//      UINT16
//      INT32
//      UINT32
//      INT64
//      UINT64
//
//  Avoid using the following types:
//      LONG - use INT
//      ULONG - use UINT
//      DWORD - use UINT32
//--------------------------------------------------------------------------

const
  REAL_MAX           = 3.402823466e+38;        // FLT_MAX;
  {$EXTERNALSYM REAL_MAX}
  REAL_MIN           = 1.17549435E-38;         // FLT_MIN;
  {$EXTERNALSYM REAL_MIN}
  REAL_TOLERANCE     = (REAL_MIN * 100);
  {$EXTERNALSYM REAL_TOLERANCE}
  REAL_EPSILON       = 1.192092896e-07;        // FLT_EPSILON
  {$EXTERNALSYM REAL_EPSILON}
  gpdll             = 'GdiPlusNew.dll';
   
//--------------------------------------------------------------------------
// Forward declarations of common classes
//--------------------------------------------------------------------------

type
  PREAL = PSingle;
  TREAL = Single;
  INT   = LongInt;

//--------------------------------------------------------------------------
// Status return values from GDI+ methods
//--------------------------------------------------------------------------

  TStatus = (
    Ok = 0,
    GenericError = 1,
    InvalidParameter = 2,
    OutOfMemory = 3,
    ObjectBusy = 4,
    InsufficientBuffer = 5,
    NotImplemented = 6,
    Win32Error = 7,
    WrongState = 8,
    Aborted = 9,
    FileNotFound = 10,
    ValueOverflow = 11,
    AccessDenied = 12,
    UnknownImageFormat = 13,
    FontFamilyNotFound = 14,
    FontStyleNotFound = 15,
    NotTrueTypeFont = 16,
    UnsupportedGdiplusVersion = 17,
    GdiplusNotInitialized = 18,
    PropertyNotFound = 19,
    PropertyNotSupported = 20
  );

// 注：C++的SizeF, Size, PointF, Point, RectF, Rect，TCharacterRange
// 是class类型，// 为了操作方便，改为record类型，原class类型函数改为pascal函数

//--------------------------------------------------------------------------
// Represents a dimension in a 2D coordinate system (floating-point coordinates)
//--------------------------------------------------------------------------

  PSizeF = ^TSizeF;
  TSizeF = packed record
    Width: TREAL;
    Height: TREAL;
  end;
//--------------------------------------------------------------------------
// Represents a dimension in a 2D coordinate system (integer coordinates)
//--------------------------------------------------------------------------

  PSize = ^TSize;
  TSize = packed record
    Width: INT;
    Height: INT;
  end;
//--------------------------------------------------------------------------
// Represents a location in a 2D coordinate system (floating-point coordinates)
//--------------------------------------------------------------------------

  PPointF = ^TPointF;
  TPointF = packed record
    X, Y: TREAL;
  end;
//--------------------------------------------------------------------------
// Represents a location in a 2D coordinate system (integer coordinates)
//--------------------------------------------------------------------------

  PPoint = ^TPoint;
  TPoint = packed record
    X, Y: INT;
  end;
//--------------------------------------------------------------------------
// Represents a rectangle in a 2D coordinate system (floating-point coordinates)
//--------------------------------------------------------------------------

  PRectF = ^TRectF;
  TRectF = packed record
    case Integer of
      0: (X, Y, Width, Height: TREAL);
      1: (Point: TPointF; Size: TSizeF);
  end;
//--------------------------------------------------------------------------
// Represents a rectangle in a 2D coordinate system (integer coordinates)
//--------------------------------------------------------------------------

  PRect = ^TRect;
  TRect = packed record
    case Integer of
      0: (X, Y, Width, Height: INT);
      1: (Point: TPoint; Size: TSize);
  end;

  TCharacterRange = packed record
    First: INT;     // 字符串中此 CharacterRange 的第一个字符的位置
    Length: INT;    // 此 CharacterRange 中的位置数
  end;
  PCharacterRange = ^TCharacterRange;

//---------------------------------------------------------------------------
// Private GDI+ classes for internal type checking
//---------------------------------------------------------------------------

  GpNative = Pointer;
  GpGraphics = GpNative;
  GpBrush = GpNative;
  GpTexture = GpNative;
  GpSolidFill = GpNative;
  GpLineGradient = GpNative;
  GpPathGradient = GpNative;
  GpHatch = GpNative;
  GpPen = GpNative;
  GpCustomLineCap = GpNative;
  GpAdjustableArrowCap = GpNative;
  GpImage = GpNative;
  GpBitmap = GpNative;
  GpMetafile = GpNative;
  GpImageAttributes = GpNative;
  GpPath = GpNative;
  GpRegion = GpNative;
  GpPathIterator = GpNative;
  GpFontFamily = GpNative;
  GpFont = GpNative;
  GpStringFormat = GpNative;
  GpFontCollection = GpNative;
  GpInstalledFontCollection = GpNative;
  GpPrivateFontCollection = GpNative;
  GpCachedBitmap = GpNative;
  GpMatrix = GpNative;
  GpPathData = Pointer;
  GpDirectDrawSurface7 = Pointer;
type
  DWORDLONG         = int64;
  TARGB             = {type }DWORD;
  PARGB             = ^DWORD;
  TARGB64            = DWORDLONG;
  PARGB64            = ^DWORDLONG;
  TPixelFormat       = INT;

const
    PaletteFlagsHasAlpha    = $0001; // 颜色值包含 alpha 信息
    PaletteFlagsGrayScale   = $0002; // 颜色是灰度值
    PaletteFlagsHalftone    = $0004; // 颜色是半色调值。
    
type
  TColorPalette = packed record
    Flags: UINT;                  // 解释颜色数组中的颜色信息的值
    Count: UINT;                  // Number of color entries
    Entries: array[0..0] of TARGB; // 获取ARGB颜色的数组
  end;
  PColorPalette = ^TColorPalette;

const
  ALPHA_SHIFT       = 24;
  RED_SHIFT         = 16;
  GREEN_SHIFT       = 8;
  BLUE_SHIFT        = 0;
  ALPHA_MASK        = (TARGB($ff) shl ALPHA_SHIFT);

// In-memory pixel data formats:
// bits 0-7 = format index
// bits 8-15 = pixel size (in bits)
// bits 16-23 = flags
// bits 24-31 = reserved

  PixelFormatIndexed        = $00010000; // Indexes into a palette
  PixelFormatGDI            = $00020000; // 像素数据包含 GDI 颜色。
  PixelFormatAlpha          = $00040000; // 像素数据包含没有进行过自左乘的 alpha 值。
  PixelFormatPAlpha         = $00080000; // 像素格式包含自左乘的 alpha 值。
  PixelFormatExtended       = $00100000; // Extended color 16 bits/channel
  PixelFormatCanonical      = $00200000;

  PixelFormatUndefined      = 0;
  PixelFormatDontCare       = 0;
  // 像素格式为 1 位，并指定它使用索引颜色。因此颜色表中有两种颜色。
  PixelFormat1bppIndexed    = (1 or (1 shl 8) or PixelFormatIndexed or PixelFormatGDI);
  // 像素格式为 4 位而且已创建索引。
  PixelFormat4bppIndexed    = (2 or (4 shl 8) or PixelFormatIndexed or PixelFormatGDI);
  // 像素格式为 8 位而且已创建索引。因此颜色表中有 256 种颜色。
  PixelFormat8bppIndexed    = (3 or (8 shl 8) or PixelFormatIndexed or PixelFormatGDI);
  // 像素格式为 16 位。该颜色信息指定 65536 种灰色调。
  PixelFormat16bppGrayScale = (4 or (16 shl 8) or PixelFormatExtended);
  // 像素格式为 16 位；红色、绿色和蓝色分量各使用 5 位。剩余的 1 位未使用。
  PixelFormat16bppRGB555    = (5 or (16 shl 8) or PixelFormatGDI);
  // 像素格式为 16 位；红色分量使用 5 位，绿色分量使用 6 位，蓝色分量使用 5 位。
  PixelFormat16bppRGB565    = (6 or (16 shl 8) or PixelFormatGDI);
  // 像素格式 16 位。该颜色信息指定 32,768 种色调，红色、绿色和蓝色分量各使用 5 位，1 位为 alpha。
  PixelFormat16bppARGB1555  = (7 or (16 shl 8) or PixelFormatAlpha or PixelFormatGDI);
  // 像素格式为 24 位；红色、绿色和蓝色分量各使用 8 位。
  PixelFormat24bppRGB       = (8 or (24 shl 8) or PixelFormatGDI);
  // 像素格式为 32 位；红色、绿色和蓝色分量各使用 8 位。剩余的 8 位未使用。
  PixelFormat32bppRGB       = (9 or (32 shl 8) or PixelFormatGDI);
  // 像素格式为 32 位；alpha、红色、绿色和蓝色分量各使用 8 位。
  PixelFormat32bppARGB      = (10 or (32 shl 8) or PixelFormatAlpha or PixelFormatGDI or PixelFormatCanonical);
  // 像素格式为 32 位；alpha、红色、绿色和蓝色分量各使用 8 位。根据 alpha 分量，对红色、绿色和蓝色分量进行自左乘。
  PixelFormat32bppPARGB     = (11 or (32 shl 8) or PixelFormatAlpha or PixelFormatPAlpha or PixelFormatGDI);
  // 像素格式为 48 位；红色、绿色和蓝色分量各使用 16 位。
  PixelFormat48bppRGB       = (12 or (48 shl 8) or PixelFormatExtended);
  // 像素格式为 64 位；alpha、红色、绿色和蓝色分量各使用 16 位。
  PixelFormat64bppARGB      = (13 or (64 shl 8) or PixelFormatAlpha or PixelFormatCanonical or PixelFormatExtended);
  // 像素格式为 64 位；alpha、红色、绿色和蓝色分量各使用 16 位。根据 alpha 分量，对红色、绿色和蓝色分量进行自左乘。
  PixelFormat64bppPARGB     = (14 or (64 shl 8) or PixelFormatAlpha or PixelFormatPAlpha or PixelFormatExtended);
  PixelFormatMax            = 15;
// 返回指定的像素格式的颜色深度（像素的位数）。
function GetPixelFormatSize(pixfmt: TPixelFormat): UINT;
// 像素格式是否索引颜色
function IsIndexedPixelFormat(pixfmt: TPixelFormat): BOOL;
// 像素格式是否包含 alpha 信息。
function IsAlphaPixelFormat(pixfmt: TPixelFormat): BOOL;
// 像素格式是否为扩展格式。
function IsExtendedPixelFormat(pixfmt: TPixelFormat): BOOL;

//--------------------------------------------------------------------------
// Determine if the Pixel Format is Canonical format:
//   PixelFormat32bppARGB
//   PixelFormat32bppPARGB
//   PixelFormat64bppARGB
//   PixelFormat64bppPARGB
//--------------------------------------------------------------------------

function IsCanonicalPixelFormat(pixfmt: TPixelFormat): BOOL;

type
//----------------------------------------------------------------------------
// Color mode
//----------------------------------------------------------------------------

  TColorMode = (ColorModeARGB32, ColorModeARGB64);

//----------------------------------------------------------------------------
// Color Channel flags
//----------------------------------------------------------------------------

  TColorChannelFlags = (ColorChannelFlagsC,   // 青色通道。
                        ColorChannelFlagsM,   // 洋红色通道。
                        ColorChannelFlagsY,   // 黄色通道。
                        ColorChannelFlagsK,   // 黑色通道。
                        ColorChannelFlagsLast // 该元素指定不更改上次选定的颜色通道。
                        );
  {$NODEFINE TColorChannelFlags}
//----------------------------------------------------------------------------
// Color
//----------------------------------------------------------------------------

const
  AlphaShift             = 24;
  RedShift               = 16;
  GreenShift             = 8;
  BlueShift              = 0;

  AlphaMask              = $ff000000;
  RedMask                = $00ff0000;
  GreenMask              = $0000ff00;
  BlueMask               = $000000ff;

type
//----------------------------------------------------------------------------
// Color matrix
//----------------------------------------------------------------------------

  TColorMatrix = array[0..4, 0..4] of TREAL;
  PColorMatrix = ^TColorMatrix;
//----------------------------------------------------------------------------
// Color Matrix flags
//----------------------------------------------------------------------------

  TColorMatrixFlags = (ColorMatrixFlagsDefault,  // 调整所有的颜色值（包括灰色底纹）。
                       ColorMatrixFlagsSkipGrays,// 调整颜色但不调整灰色底纹。
                       ColorMatrixFlagsAltGray
                       );
//----------------------------------------------------------------------------
// Color Adjust Type
//----------------------------------------------------------------------------

  TColorAdjustType = (ColorAdjustTypeDefault,  // 自身没有颜色调整信息的所有 GDI+ 对象所使用的颜色调整信息。
                      ColorAdjustTypeBitmap,   // TBitmap 对象的颜色调整信息。
                      ColorAdjustTypeBrush,    // TBrush 对象的颜色调整信息。
                      ColorAdjustTypePen,      // TPen 对象的颜色调整信息。
                      ColorAdjustTypeText,     // 文本的颜色调整信息。
                      ColorAdjustTypeCount,    // 指定的类型的数目。
                      ColorAdjustTypeAny      
  );
//----------------------------------------------------------------------------
// Color Map
//----------------------------------------------------------------------------

  TColorMap = packed record
    oldColor: TARGB;
    newColor: TARGB;
  end;
  PColorMap = ^TColorMap;

const
  ImageFormatUndefined : TGUID = '{b96b3ca9-0728-11d3-9d7b-0000f81ef32e}';
  {$EXTERNALSYM ImageFormatUndefined}
  ImageFormatMemoryBMP : TGUID = '{b96b3caa-0728-11d3-9d7b-0000f81ef32e}';
  {$EXTERNALSYM ImageFormatMemoryBMP}
  ImageFormatBMP       : TGUID = '{b96b3cab-0728-11d3-9d7b-0000f81ef32e}';
  {$EXTERNALSYM ImageFormatBMP}
  ImageFormatEMF       : TGUID = '{b96b3cac-0728-11d3-9d7b-0000f81ef32e}';
  {$EXTERNALSYM ImageFormatEMF}
  ImageFormatWMF       : TGUID = '{b96b3cad-0728-11d3-9d7b-0000f81ef32e}';
  {$EXTERNALSYM ImageFormatWMF}
  ImageFormatJPEG      : TGUID = '{b96b3cae-0728-11d3-9d7b-0000f81ef32e}';
  {$EXTERNALSYM ImageFormatJPEG}
  ImageFormatPNG       : TGUID = '{b96b3caf-0728-11d3-9d7b-0000f81ef32e}';
  {$EXTERNALSYM ImageFormatPNG}
  ImageFormatGIF       : TGUID = '{b96b3cb0-0728-11d3-9d7b-0000f81ef32e}';
  {$EXTERNALSYM ImageFormatGIF}
  ImageFormatTIFF      : TGUID = '{b96b3cb1-0728-11d3-9d7b-0000f81ef32e}';
  {$EXTERNALSYM ImageFormatTIFF}
  ImageFormatEXIF      : TGUID = '{b96b3cb2-0728-11d3-9d7b-0000f81ef32e}';
  {$EXTERNALSYM ImageFormatEXIF}
  ImageFormatIcon      : TGUID = '{b96b3cb5-0728-11d3-9d7b-0000f81ef32e}';
  {$EXTERNALSYM ImageFormatIcon}

//---------------------------------------------------------------------------
// Predefined multi-frame dimension IDs
//---------------------------------------------------------------------------

  FrameDimensionTime       : TGUID = '{6aedbd6d-3fb5-418a-83a6-7f45229dc872}';
  {$EXTERNALSYM FrameDimensionTime}
  FrameDimensionResolution : TGUID = '{84236f7b-3bd3-428f-8dab-4ea1439ca315}';
  {$EXTERNALSYM FrameDimensionResolution}
  FrameDimensionPage       : TGUID = '{7462dc86-6180-4c7e-8e3f-ee7333a7a483}';
  {$EXTERNALSYM FrameDimensionPage}

//---------------------------------------------------------------------------
// Property sets
//---------------------------------------------------------------------------

  FormatIDImageInformation : TGUID = '{e5836cbe-5eef-4f1d-acde-ae4c43b608ce}';
  {$EXTERNALSYM FormatIDImageInformation}
  FormatIDJpegAppHeaders   : TGUID = '{1c4afdcd-6177-43cf-abc7-5f51af39ee85}';
  {$EXTERNALSYM FormatIDJpegAppHeaders}

//---------------------------------------------------------------------------
// Encoder parameter sets  图像编码器参数类别设置
//---------------------------------------------------------------------------

  EncoderCompression      : TGUID = '{e09d739d-ccd4-44ee-8eba-3fbf8be4fc58}'; // 压缩
  {$EXTERNALSYM EncoderCompression}
  EncoderColorDepth       : TGUID = '{66087055-ad66-4c7c-9a18-38a2310b8337}'; // 颜色深度
  {$EXTERNALSYM EncoderColorDepth}
  EncoderScanMethod       : TGUID = '{3a4e2661-3109-4e56-8536-42c156e7dcfa}'; // 扫描方法
  {$EXTERNALSYM EncoderScanMethod}
  EncoderVersion          : TGUID = '{24d18c76-814a-41a4-bf53-1c219cccf797}'; // 版本
  {$EXTERNALSYM EncoderVersion}
  EncoderRenderMethod     : TGUID = '{6d42c53a-229a-4825-8bb7-5c99e2b9a8b8}'; // 呈现方法
  {$EXTERNALSYM EncoderRenderMethod}
  EncoderQuality          : TGUID = '{1d5be4b5-fa4a-452d-9cdd-5db35105e7eb}'; // 质量
  {$EXTERNALSYM EncoderQuality}
  EncoderTransformation   : TGUID = '{8d0eb2d1-a58e-4ea8-aa14-108074b7b6f9}'; // 转换
  {$EXTERNALSYM EncoderTransformation}
  EncoderLuminanceTable   : TGUID = '{edb33bce-0266-4a77-b904-27216099e717}'; // 亮度表
  {$EXTERNALSYM EncoderLuminanceTable}
  EncoderChrominanceTable : TGUID = '{f2e455dc-09b3-4316-8260-676ada32481c}'; // 色度表
  {$EXTERNALSYM EncoderChrominanceTable}
  EncoderSaveFlag         : TGUID = '{292266fc-ac40-47bf-8cfc-a85b89a655de}'; // 保存标志
  {$EXTERNALSYM EncoderSaveFlag}
  
  CodecIImageBytes        : TGUID = '{025d1823-6c7d-447b-bbdb-a3cbc3dfa2fc}';
  {$EXTERNALSYM CodecIImageBytes}

type
  IImageBytes = Interface(IUnknown)
    ['{025D1823-6C7D-447B-BBDB-A3CBC3DFA2FC}']
    // Return total number of bytes in the IStream
    function CountBytes(var pcb: UINT): HResult; stdcall;
    // Locks "cb" bytes, starting from "ulOffset" in the stream, and returns the
    // pointer to the beginning of the locked memory chunk in "ppvBytes"
    function LockBytes(cb: UINT; ulOffset: ULONG; var ppvBytes: pointer): HResult; stdcall;
    // Unlocks "cb" bytes, pointed by "pvBytes", starting from "ulOffset" in the
    // stream
    function UnlockBytes(pvBytes: pointer; cb: UINT; ulOffset: ULONG): HResult; stdcall;
  end;
  {$EXTERNALSYM IImageBytes}

//--------------------------------------------------------------------------
// ImageCodecInfo structure 已安装的图像编码解码器的所有相关信息
//--------------------------------------------------------------------------

  TImageCodecInfo = packed record
    Clsid: TGUID;              // 能识别特定编码解码器的 GUID。
    FormatID: TGUID;           // 识别编码解码器格式的 GUID
    CodecName: PWCHAR;         // 编码解码器名称的字符串
    DllName: PWCHAR;           // 存放编码解码器的 DLL 的路径名字符串
    FormatDescription: PWCHAR; // 描述编码解码器的文件格式的字符串。
    FilenameExtension: PWCHAR; // 编码解码器中使用的文件扩展名的字符串
    MimeType: PWCHAR;          // 编码解码器的多用途网际邮件扩充协议 (MIME) 类型的字符串
    Flags: DWORD;              // 有关编码解码器的其他信息(ImageCodecFlags若干标志的组合)
    Version: DWORD;            // 编码解码器的版本号
    SigCount: DWORD;
    SigSize: DWORD;
    SigPattern: PByte;         // 表示编码解码器签名的二维字节数组
    SigMask: PByte;            // 用作筛选器的二维字节数组
  end;
  PImageCodecInfo = ^TImageCodecInfo;

//--------------------------------------------------------------------------
// Information flags about image codecs
//--------------------------------------------------------------------------

  TImageCodecFlags = (
    ImageCodecFlagsEncoder            = $00000001,
    ImageCodecFlagsDecoder            = $00000002,
    ImageCodecFlagsSupportBitmap      = $00000004,
    ImageCodecFlagsSupportVector      = $00000008,
    ImageCodecFlagsSeekableEncode     = $00000010,
    ImageCodecFlagsBlockingDecode     = $00000020,

    ImageCodecFlagsBuiltin            = $00010000,
    ImageCodecFlagsSystem             = $00020000,
    ImageCodecFlagsUser               = $00040000
  );

//---------------------------------------------------------------------------
// Access modes used when calling Image::LockBits
//---------------------------------------------------------------------------

  TImageLockMode = (
    ImageLockModeRead        = $0001,
    ImageLockModeWrite       = $0002,
    ImageLockModeUserInputBuf= $0004
  );
//---------------------------------------------------------------------------
// Information about image pixel data
//---------------------------------------------------------------------------

  TBitmapData = packed record   // 位图图像的属性
    Width: UINT;                // 像素宽度。也可以看作是一个扫描行中的像素数。
    Height: UINT;               // 像素高度。也称作扫描行数。
    Stride: INT;                // 跨距宽度（也称为扫描宽度）。
    PixelFormat: TPixelFormat;  // 像素信息的格式
    Scan0: Pointer;             // 第一个像素数据的地址。也可以看成位图中的第一个扫描行
    Reserved: UINT;             // 保留
  end;
  PBitmapData = ^TBitmapData;

//---------------------------------------------------------------------------
// Image flags
//---------------------------------------------------------------------------

  TImageFlags = (
    ImageFlagsNone                = 0,

    // Low-word: shared with SINKFLAG_x

    ImageFlagsScalable            = $0001,
    ImageFlagsHasAlpha            = $0002,
    ImageFlagsHasTranslucent      = $0004,
    ImageFlagsPartiallyScalable   = $0008,

    // Low-word: color space definition

    ImageFlagsColorSpaceRGB       = $0010,
    ImageFlagsColorSpaceCMYK      = $0020,
    ImageFlagsColorSpaceGRAY      = $0040,
    ImageFlagsColorSpaceYCBCR     = $0080,
    ImageFlagsColorSpaceYCCK      = $0100,

    // Low-word: image size info

    ImageFlagsHasRealDPI          = $1000,
    ImageFlagsHasRealPixelSize    = $2000,

    // High-word

    ImageFlagsReadOnly            = $00010000,
    ImageFlagsCaching             = $00020000
  );

  TRotateFlipType = (
    RotateNoneFlipNone = 0,      // 指定不进行旋转和翻转
    Rotate90FlipNone   = 1,      // 指定不进行翻转的 90 度旋转。
    Rotate180FlipNone  = 2,      // 指定不进行翻转的 180 度旋转。
    Rotate270FlipNone  = 3,      // 指定不进行翻转的 270 度旋转。

    RotateNoneFlipX    = 4,      // 指定水平翻转。
    Rotate90FlipX      = 5,      // 指定水平翻转的 90 度旋转。
    Rotate180FlipX     = 6,      // 指定水平翻转的 180 度旋转。
    Rotate270FlipX     = 7,      // 指定水平翻转的 270 度旋转。

    RotateNoneFlipY    = Rotate180FlipX,  // 指定垂直翻转
    Rotate90FlipY      = Rotate270FlipX,  // 指定垂直翻转的 90 度旋转。
    Rotate180FlipY     = RotateNoneFlipX, // 指定垂直翻转的 180 度旋转。
    Rotate270FlipY     = Rotate90FlipX,   // 指定垂直翻转的 270 度旋转。

    RotateNoneFlipXY   = Rotate180FlipNone,  // 指定没有水平和垂直翻转的旋转
    Rotate90FlipXY     = Rotate270FlipNone,  // 指定水平翻转和垂直翻转的 90 度旋转。
    Rotate180FlipXY    = RotateNoneFlipNone, // 指定水平翻转和垂直翻转的 180 度旋转。
    Rotate270FlipXY    = Rotate90FlipNone    // 指定水平翻转和垂直翻转的 270 度旋转。
  );
//---------------------------------------------------------------------------
// Encoder Parameter structure
//---------------------------------------------------------------------------
  TEncoderParameter = packed record
    Guid: TGUID;                           // GUID of the parameter
    NumberOfValues: ULONG;                 // Number of the parameter values
    ValueType: TEncoderParameterValueType; // Value type, like ValueTypeLONG  etc.
    Value: Pointer;                        // A pointer to the parameter values
  end;
  PEncoderParameter = ^TEncoderParameter;

//---------------------------------------------------------------------------
// Encoder Parameters structure
//---------------------------------------------------------------------------
  TEncoderParameters = Packed record
    Count: UINT;                      // Number of parameters in this structure
    Parameter: array[0..0] of TEncoderParameter;  // Parameter values
  end;
  PEncoderParameters = ^TEncoderParameters;

//---------------------------------------------------------------------------
// Property Item
//---------------------------------------------------------------------------
  TPropertyItem = record
    id: PROPID;                 // 属性的 ID
    length: ULONG;              // Value 的长度（以字节为单位）。
    atype: WORD;                // Value 的数据类型: PropertyTagTypeXXXX
    value: Pointer;             // 属性项的值
  end;
  PPropertyItem = ^TPropertyItem;

const
  PropertyTagTypeByte        = 1;
  {$EXTERNALSYM PropertyTagTypeByte}
  PropertyTagTypeASCII       = 2;
  {$EXTERNALSYM PropertyTagTypeASCII}
  PropertyTagTypeShort       = 3;
  {$EXTERNALSYM PropertyTagTypeShort}
  PropertyTagTypeLong        = 4;
  {$EXTERNALSYM PropertyTagTypeLong}
  PropertyTagTypeRational    = 5;
  {$EXTERNALSYM PropertyTagTypeRational}
  PropertyTagTypeUndefined   = 7;
  {$EXTERNALSYM PropertyTagTypeUndefined}
  PropertyTagTypeSLONG       = 9;
  {$EXTERNALSYM PropertyTagTypeSLONG}
  PropertyTagTypeSRational  = 10;
  {$EXTERNALSYM PropertyTagTypeSRational}
  PropertyTagExifIFD             = $8769;
  {$EXTERNALSYM PropertyTagExifIFD}
  PropertyTagGpsIFD              = $8825;
  {$EXTERNALSYM PropertyTagGpsIFD}
  PropertyTagNewSubfileType      = $00FE;
  {$EXTERNALSYM PropertyTagNewSubfileType}
  PropertyTagSubfileType         = $00FF;
  {$EXTERNALSYM PropertyTagSubfileType}
  PropertyTagImageWidth          = $0100;
  {$EXTERNALSYM PropertyTagImageWidth}
  PropertyTagImageHeight         = $0101;
  {$EXTERNALSYM PropertyTagImageHeight}
  PropertyTagBitsPerSample       = $0102;
  {$EXTERNALSYM PropertyTagBitsPerSample}
  PropertyTagCompression         = $0103;
  {$EXTERNALSYM PropertyTagCompression}
  PropertyTagPhotometricInterp   = $0106;
  {$EXTERNALSYM PropertyTagPhotometricInterp}
  PropertyTagThreshHolding       = $0107;
  {$EXTERNALSYM PropertyTagThreshHolding}
  PropertyTagCellWidth           = $0108;
  {$EXTERNALSYM PropertyTagCellWidth}
  PropertyTagCellHeight          = $0109;
  {$EXTERNALSYM PropertyTagCellHeight}
  PropertyTagFillOrder           = $010A;
  {$EXTERNALSYM PropertyTagFillOrder}
  PropertyTagDocumentName        = $010D;
  {$EXTERNALSYM PropertyTagDocumentName}
  PropertyTagImageDescription    = $010E;
  {$EXTERNALSYM PropertyTagImageDescription}
  PropertyTagEquipMake           = $010F;
  {$EXTERNALSYM PropertyTagEquipMake}
  PropertyTagEquipModel          = $0110;
  {$EXTERNALSYM PropertyTagEquipModel}
  PropertyTagStripOffsets        = $0111;
  {$EXTERNALSYM PropertyTagStripOffsets}
  PropertyTagOrientation         = $0112;
  {$EXTERNALSYM PropertyTagOrientation}
  PropertyTagSamplesPerPixel     = $0115;
  {$EXTERNALSYM PropertyTagSamplesPerPixel}
  PropertyTagRowsPerStrip        = $0116;
  {$EXTERNALSYM PropertyTagRowsPerStrip}
  PropertyTagStripBytesCount     = $0117;
  {$EXTERNALSYM PropertyTagStripBytesCount}
  PropertyTagMinSampleValue      = $0118;
  {$EXTERNALSYM PropertyTagMinSampleValue}
  PropertyTagMaxSampleValue      = $0119;
  {$EXTERNALSYM PropertyTagMaxSampleValue}
  PropertyTagXResolution         = $011A;   // Image resolution in width direction
  {$EXTERNALSYM PropertyTagXResolution}
  PropertyTagYResolution         = $011B;   // Image resolution in height direction
  {$EXTERNALSYM PropertyTagYResolution}
  PropertyTagPlanarConfig        = $011C;   // Image data arrangement
  {$EXTERNALSYM PropertyTagPlanarConfig}
  PropertyTagPageName            = $011D;
  {$EXTERNALSYM PropertyTagPageName}
  PropertyTagXPosition           = $011E;
  {$EXTERNALSYM PropertyTagXPosition}
  PropertyTagYPosition           = $011F;
  {$EXTERNALSYM PropertyTagYPosition}
  PropertyTagFreeOffset          = $0120;
  {$EXTERNALSYM PropertyTagFreeOffset}
  PropertyTagFreeByteCounts      = $0121;
  {$EXTERNALSYM PropertyTagFreeByteCounts}
  PropertyTagGrayResponseUnit    = $0122;
  {$EXTERNALSYM PropertyTagGrayResponseUnit}
  PropertyTagGrayResponseCurve   = $0123;
  {$EXTERNALSYM PropertyTagGrayResponseCurve}
  PropertyTagT4Option            = $0124;
  {$EXTERNALSYM PropertyTagT4Option}
  PropertyTagT6Option            = $0125;
  {$EXTERNALSYM PropertyTagT6Option}
  PropertyTagResolutionUnit      = $0128;   // Unit of X and Y resolution
  {$EXTERNALSYM PropertyTagResolutionUnit}
  PropertyTagPageNumber          = $0129;
  {$EXTERNALSYM PropertyTagPageNumber}
  PropertyTagTransferFuncition   = $012D;
  {$EXTERNALSYM PropertyTagTransferFuncition}
  PropertyTagSoftwareUsed        = $0131;
  {$EXTERNALSYM PropertyTagSoftwareUsed}
  PropertyTagDateTime            = $0132;
  {$EXTERNALSYM PropertyTagDateTime}
  PropertyTagArtist              = $013B;
  {$EXTERNALSYM PropertyTagArtist}
  PropertyTagHostComputer        = $013C;
  {$EXTERNALSYM PropertyTagHostComputer}
  PropertyTagPredictor           = $013D;
  {$EXTERNALSYM PropertyTagPredictor}
  PropertyTagWhitePoint          = $013E;
  {$EXTERNALSYM PropertyTagWhitePoint}
  PropertyTagPrimaryChromaticities = $013F;
  {$EXTERNALSYM PropertyTagPrimaryChromaticities}
  PropertyTagColorMap            = $0140;
  {$EXTERNALSYM PropertyTagColorMap}
  PropertyTagHalftoneHints       = $0141;
  {$EXTERNALSYM PropertyTagHalftoneHints}
  PropertyTagTileWidth           = $0142;
  {$EXTERNALSYM PropertyTagTileWidth}
  PropertyTagTileLength          = $0143;
  {$EXTERNALSYM PropertyTagTileLength}
  PropertyTagTileOffset          = $0144;
  {$EXTERNALSYM PropertyTagTileOffset}
  PropertyTagTileByteCounts      = $0145;
  {$EXTERNALSYM PropertyTagTileByteCounts}
  PropertyTagInkSet              = $014C;
  {$EXTERNALSYM PropertyTagInkSet}
  PropertyTagInkNames            = $014D;
  {$EXTERNALSYM PropertyTagInkNames}
  PropertyTagNumberOfInks        = $014E;
  {$EXTERNALSYM PropertyTagNumberOfInks}
  PropertyTagDotRange            = $0150;
  {$EXTERNALSYM PropertyTagDotRange}
  PropertyTagTargetPrinter       = $0151;
  {$EXTERNALSYM PropertyTagTargetPrinter}
  PropertyTagExtraSamples        = $0152;
  {$EXTERNALSYM PropertyTagExtraSamples}
  PropertyTagSampleFormat        = $0153;
  {$EXTERNALSYM PropertyTagSampleFormat}
  PropertyTagSMinSampleValue     = $0154;
  {$EXTERNALSYM PropertyTagSMinSampleValue}
  PropertyTagSMaxSampleValue     = $0155;
  {$EXTERNALSYM PropertyTagSMaxSampleValue}
  PropertyTagTransferRange       = $0156;
  {$EXTERNALSYM PropertyTagTransferRange}
  PropertyTagJPEGProc            = $0200;
  {$EXTERNALSYM PropertyTagJPEGProc}
  PropertyTagJPEGInterFormat     = $0201;
  {$EXTERNALSYM PropertyTagJPEGInterFormat}
  PropertyTagJPEGInterLength     = $0202;
  {$EXTERNALSYM PropertyTagJPEGInterLength}
  PropertyTagJPEGRestartInterval = $0203;
  {$EXTERNALSYM PropertyTagJPEGRestartInterval}
  PropertyTagJPEGLosslessPredictors  = $0205;
  {$EXTERNALSYM PropertyTagJPEGLosslessPredictors}
  PropertyTagJPEGPointTransforms     = $0206;
  {$EXTERNALSYM PropertyTagJPEGPointTransforms}
  PropertyTagJPEGQTables         = $0207;
  {$EXTERNALSYM PropertyTagJPEGQTables}
  PropertyTagJPEGDCTables        = $0208;
  {$EXTERNALSYM PropertyTagJPEGDCTables}
  PropertyTagJPEGACTables        = $0209;
  {$EXTERNALSYM PropertyTagJPEGACTables}
  PropertyTagYCbCrCoefficients   = $0211;
  {$EXTERNALSYM PropertyTagYCbCrCoefficients}
  PropertyTagYCbCrSubsampling    = $0212;
  {$EXTERNALSYM PropertyTagYCbCrSubsampling}
  PropertyTagYCbCrPositioning    = $0213;
  {$EXTERNALSYM PropertyTagYCbCrPositioning}
  PropertyTagREFBlackWhite       = $0214;
  {$EXTERNALSYM PropertyTagREFBlackWhite}
  PropertyTagICCProfile          = $8773;   // This TAG is defined by ICC
  {$EXTERNALSYM PropertyTagICCProfile}
  PropertyTagGamma               = $0301;
  {$EXTERNALSYM PropertyTagGamma}
  PropertyTagICCProfileDescriptor = $0302;
  {$EXTERNALSYM PropertyTagICCProfileDescriptor}
  PropertyTagSRGBRenderingIntent = $0303;
  {$EXTERNALSYM PropertyTagSRGBRenderingIntent}
  PropertyTagImageTitle          = $0320;
  {$EXTERNALSYM PropertyTagImageTitle}
  PropertyTagCopyright           = $8298;
  {$EXTERNALSYM PropertyTagCopyright}
  PropertyTagResolutionXUnit           = $5001;
  {$EXTERNALSYM PropertyTagResolutionXUnit}
  PropertyTagResolutionYUnit           = $5002;
  {$EXTERNALSYM PropertyTagResolutionYUnit}
  PropertyTagResolutionXLengthUnit     = $5003;
  {$EXTERNALSYM PropertyTagResolutionXLengthUnit}
  PropertyTagResolutionYLengthUnit     = $5004;
  {$EXTERNALSYM PropertyTagResolutionYLengthUnit}
  PropertyTagPrintFlags                = $5005;
  {$EXTERNALSYM PropertyTagPrintFlags}
  PropertyTagPrintFlagsVersion         = $5006;
  {$EXTERNALSYM PropertyTagPrintFlagsVersion}
  PropertyTagPrintFlagsCrop            = $5007;
  {$EXTERNALSYM PropertyTagPrintFlagsCrop}
  PropertyTagPrintFlagsBleedWidth      = $5008;
  {$EXTERNALSYM PropertyTagPrintFlagsBleedWidth}
  PropertyTagPrintFlagsBleedWidthScale = $5009;
  {$EXTERNALSYM PropertyTagPrintFlagsBleedWidthScale}
  PropertyTagHalftoneLPI               = $500A;
  {$EXTERNALSYM PropertyTagHalftoneLPI}
  PropertyTagHalftoneLPIUnit           = $500B;
  {$EXTERNALSYM PropertyTagHalftoneLPIUnit}
  PropertyTagHalftoneDegree            = $500C;
  {$EXTERNALSYM PropertyTagHalftoneDegree}
  PropertyTagHalftoneShape             = $500D;
  {$EXTERNALSYM PropertyTagHalftoneShape}
  PropertyTagHalftoneMisc              = $500E;
  {$EXTERNALSYM PropertyTagHalftoneMisc}
  PropertyTagHalftoneScreen            = $500F;
  {$EXTERNALSYM PropertyTagHalftoneScreen}
  PropertyTagJPEGQuality               = $5010;
  {$EXTERNALSYM PropertyTagJPEGQuality}
  PropertyTagGridSize                  = $5011;
  {$EXTERNALSYM PropertyTagGridSize}
  PropertyTagThumbnailFormat           = $5012;  // 1 = JPEG, 0 = RAW RGB
  {$EXTERNALSYM PropertyTagThumbnailFormat}
  PropertyTagThumbnailWidth            = $5013;
  {$EXTERNALSYM PropertyTagThumbnailWidth}
  PropertyTagThumbnailHeight           = $5014;
  {$EXTERNALSYM PropertyTagThumbnailHeight}
  PropertyTagThumbnailColorDepth       = $5015;
  {$EXTERNALSYM PropertyTagThumbnailColorDepth}
  PropertyTagThumbnailPlanes           = $5016;
  {$EXTERNALSYM PropertyTagThumbnailPlanes}
  PropertyTagThumbnailRawBytes         = $5017;
  {$EXTERNALSYM PropertyTagThumbnailRawBytes}
  PropertyTagThumbnailSize             = $5018;
  {$EXTERNALSYM PropertyTagThumbnailSize}
  PropertyTagThumbnailCompressedSize   = $5019;
  {$EXTERNALSYM PropertyTagThumbnailCompressedSize}
  PropertyTagColorTransferFunction     = $501A;
  {$EXTERNALSYM PropertyTagColorTransferFunction}
  PropertyTagThumbnailData             = $501B; // RAW thumbnail bits in
  {$EXTERNALSYM PropertyTagThumbnailData}
  PropertyTagThumbnailImageWidth       = $5020;  // Thumbnail width
  {$EXTERNALSYM PropertyTagThumbnailImageWidth}
  PropertyTagThumbnailImageHeight      = $5021;  // Thumbnail height
  {$EXTERNALSYM PropertyTagThumbnailImageHeight}
  PropertyTagThumbnailBitsPerSample    = $5022;  // Number of bits per
  {$EXTERNALSYM PropertyTagThumbnailBitsPerSample}
  PropertyTagThumbnailCompression      = $5023;  // Compression Scheme
  {$EXTERNALSYM PropertyTagThumbnailCompression}
  PropertyTagThumbnailPhotometricInterp = $5024; // Pixel composition
  {$EXTERNALSYM PropertyTagThumbnailPhotometricInterp}
  PropertyTagThumbnailImageDescription = $5025;  // Image Tile
  {$EXTERNALSYM PropertyTagThumbnailImageDescription}
  PropertyTagThumbnailEquipMake        = $5026;  // Manufacturer of Image
  {$EXTERNALSYM PropertyTagThumbnailEquipMake}
  PropertyTagThumbnailEquipModel       = $5027;  // Model of Image input
  {$EXTERNALSYM PropertyTagThumbnailEquipModel}
  PropertyTagThumbnailStripOffsets     = $5028;  // Image data location
  {$EXTERNALSYM PropertyTagThumbnailStripOffsets}
  PropertyTagThumbnailOrientation      = $5029;  // Orientation of image
  {$EXTERNALSYM PropertyTagThumbnailOrientation}
  PropertyTagThumbnailSamplesPerPixel  = $502A;  // Number of components
  {$EXTERNALSYM PropertyTagThumbnailSamplesPerPixel}
  PropertyTagThumbnailRowsPerStrip     = $502B;  // Number of rows per strip
  {$EXTERNALSYM PropertyTagThumbnailRowsPerStrip}
  PropertyTagThumbnailStripBytesCount  = $502C;  // Bytes per compressed
  {$EXTERNALSYM PropertyTagThumbnailStripBytesCount}
  PropertyTagThumbnailResolutionX      = $502D;  // Resolution in width
  {$EXTERNALSYM PropertyTagThumbnailResolutionX}
  PropertyTagThumbnailResolutionY      = $502E;  // Resolution in height
  {$EXTERNALSYM PropertyTagThumbnailResolutionY}
  PropertyTagThumbnailPlanarConfig     = $502F;  // Image data arrangement
  {$EXTERNALSYM PropertyTagThumbnailPlanarConfig}
  PropertyTagThumbnailResolutionUnit   = $5030;  // Unit of X and Y
  {$EXTERNALSYM PropertyTagThumbnailResolutionUnit}
  PropertyTagThumbnailTransferFunction = $5031;  // Transfer function
  {$EXTERNALSYM PropertyTagThumbnailTransferFunction}
  PropertyTagThumbnailSoftwareUsed     = $5032;  // Software used
  {$EXTERNALSYM PropertyTagThumbnailSoftwareUsed}
  PropertyTagThumbnailDateTime         = $5033;  // File change date and
  {$EXTERNALSYM PropertyTagThumbnailDateTime}
  PropertyTagThumbnailArtist           = $5034;  // Person who created the
  {$EXTERNALSYM PropertyTagThumbnailArtist}
  PropertyTagThumbnailWhitePoint       = $5035;  // White point chromaticity
  {$EXTERNALSYM PropertyTagThumbnailWhitePoint}
  PropertyTagThumbnailPrimaryChromaticities = $5036; 
  {$EXTERNALSYM PropertyTagThumbnailPrimaryChromaticities}
  PropertyTagThumbnailYCbCrCoefficients = $5037; // Color space transforma-
  {$EXTERNALSYM PropertyTagThumbnailYCbCrCoefficients}
  PropertyTagThumbnailYCbCrSubsampling = $5038;  // Subsampling ratio of Y
  {$EXTERNALSYM PropertyTagThumbnailYCbCrSubsampling}
  PropertyTagThumbnailYCbCrPositioning = $5039;  // Y and C position
  {$EXTERNALSYM PropertyTagThumbnailYCbCrPositioning}
  PropertyTagThumbnailRefBlackWhite    = $503A;  // Pair of black and white
  {$EXTERNALSYM PropertyTagThumbnailRefBlackWhite}
  PropertyTagThumbnailCopyRight        = $503B;  // CopyRight holder
  {$EXTERNALSYM PropertyTagThumbnailCopyRight}
  PropertyTagLuminanceTable            = $5090;
  {$EXTERNALSYM PropertyTagLuminanceTable}
  PropertyTagChrominanceTable          = $5091;
  {$EXTERNALSYM PropertyTagChrominanceTable}
  PropertyTagFrameDelay                = $5100;
  {$EXTERNALSYM PropertyTagFrameDelay}
  PropertyTagLoopCount                 = $5101;
  {$EXTERNALSYM PropertyTagLoopCount}
  PropertyTagPixelUnit         = $5110;  // Unit specifier for pixel/unit
  {$EXTERNALSYM PropertyTagPixelUnit}
  PropertyTagPixelPerUnitX     = $5111;  // Pixels per unit in X
  {$EXTERNALSYM PropertyTagPixelPerUnitX}
  PropertyTagPixelPerUnitY     = $5112;  // Pixels per unit in Y
  {$EXTERNALSYM PropertyTagPixelPerUnitY}
  PropertyTagPaletteHistogram  = $5113;  // Palette histogram
  {$EXTERNALSYM PropertyTagPaletteHistogram}
  PropertyTagExifExposureTime  = $829A;
  {$EXTERNALSYM PropertyTagExifExposureTime}
  PropertyTagExifFNumber       = $829D;
  {$EXTERNALSYM PropertyTagExifFNumber}
  PropertyTagExifExposureProg  = $8822;
  {$EXTERNALSYM PropertyTagExifExposureProg}
  PropertyTagExifSpectralSense = $8824;
  {$EXTERNALSYM PropertyTagExifSpectralSense}
  PropertyTagExifISOSpeed      = $8827;
  {$EXTERNALSYM PropertyTagExifISOSpeed}
  PropertyTagExifOECF          = $8828;
  {$EXTERNALSYM PropertyTagExifOECF}
  PropertyTagExifVer            = $9000;
  {$EXTERNALSYM PropertyTagExifVer}
  PropertyTagExifDTOrig         = $9003; // Date & time of original
  {$EXTERNALSYM PropertyTagExifDTOrig}
  PropertyTagExifDTDigitized    = $9004; // Date & time of digital data generation
  {$EXTERNALSYM PropertyTagExifDTDigitized}
  PropertyTagExifCompConfig     = $9101;
  {$EXTERNALSYM PropertyTagExifCompConfig}
  PropertyTagExifCompBPP        = $9102;
  {$EXTERNALSYM PropertyTagExifCompBPP}
  PropertyTagExifShutterSpeed   = $9201;
  {$EXTERNALSYM PropertyTagExifShutterSpeed}
  PropertyTagExifAperture       = $9202;
  {$EXTERNALSYM PropertyTagExifAperture}
  PropertyTagExifBrightness     = $9203;
  {$EXTERNALSYM PropertyTagExifBrightness}
  PropertyTagExifExposureBias   = $9204;
  {$EXTERNALSYM PropertyTagExifExposureBias}
  PropertyTagExifMaxAperture    = $9205;
  {$EXTERNALSYM PropertyTagExifMaxAperture}
  PropertyTagExifSubjectDist    = $9206;
  {$EXTERNALSYM PropertyTagExifSubjectDist}
  PropertyTagExifMeteringMode   = $9207;
  {$EXTERNALSYM PropertyTagExifMeteringMode}
  PropertyTagExifLightSource    = $9208;
  {$EXTERNALSYM PropertyTagExifLightSource}
  PropertyTagExifFlash          = $9209;
  {$EXTERNALSYM PropertyTagExifFlash}
  PropertyTagExifFocalLength    = $920A;
  {$EXTERNALSYM PropertyTagExifFocalLength}
  PropertyTagExifMakerNote      = $927C;
  {$EXTERNALSYM PropertyTagExifMakerNote}
  PropertyTagExifUserComment    = $9286;
  {$EXTERNALSYM PropertyTagExifUserComment}
  PropertyTagExifDTSubsec       = $9290;  // Date & Time subseconds
  {$EXTERNALSYM PropertyTagExifDTSubsec}
  PropertyTagExifDTOrigSS       = $9291;  // Date & Time original subseconds
  {$EXTERNALSYM PropertyTagExifDTOrigSS}
  PropertyTagExifDTDigSS        = $9292;  // Date & TIme digitized subseconds
  {$EXTERNALSYM PropertyTagExifDTDigSS}
  PropertyTagExifFPXVer         = $A000;
  {$EXTERNALSYM PropertyTagExifFPXVer}
  PropertyTagExifColorSpace     = $A001;
  {$EXTERNALSYM PropertyTagExifColorSpace}
  PropertyTagExifPixXDim        = $A002;
  {$EXTERNALSYM PropertyTagExifPixXDim}
  PropertyTagExifPixYDim        = $A003;
  {$EXTERNALSYM PropertyTagExifPixYDim}
  PropertyTagExifRelatedWav     = $A004;  // related sound file
  {$EXTERNALSYM PropertyTagExifRelatedWav}
  PropertyTagExifInterop        = $A005;
  {$EXTERNALSYM PropertyTagExifInterop}
  PropertyTagExifFlashEnergy    = $A20B;
  {$EXTERNALSYM PropertyTagExifFlashEnergy}
  PropertyTagExifSpatialFR      = $A20C;  // Spatial Frequency Response
  {$EXTERNALSYM PropertyTagExifSpatialFR}
  PropertyTagExifFocalXRes      = $A20E;  // Focal Plane X Resolution
  {$EXTERNALSYM PropertyTagExifFocalXRes}
  PropertyTagExifFocalYRes      = $A20F;  // Focal Plane Y Resolution
  {$EXTERNALSYM PropertyTagExifFocalYRes}
  PropertyTagExifFocalResUnit   = $A210;  // Focal Plane Resolution Unit
  {$EXTERNALSYM PropertyTagExifFocalResUnit}
  PropertyTagExifSubjectLoc     = $A214;
  {$EXTERNALSYM PropertyTagExifSubjectLoc}
  PropertyTagExifExposureIndex  = $A215;
  {$EXTERNALSYM PropertyTagExifExposureIndex}
  PropertyTagExifSensingMethod  = $A217;
  {$EXTERNALSYM PropertyTagExifSensingMethod}
  PropertyTagExifFileSource     = $A300;
  {$EXTERNALSYM PropertyTagExifFileSource}
  PropertyTagExifSceneType      = $A301;
  {$EXTERNALSYM PropertyTagExifSceneType}
  PropertyTagExifCfaPattern     = $A302;
  {$EXTERNALSYM PropertyTagExifCfaPattern}
  PropertyTagGpsVer             = $0000;
  {$EXTERNALSYM PropertyTagGpsVer}
  PropertyTagGpsLatitudeRef     = $0001;
  {$EXTERNALSYM PropertyTagGpsLatitudeRef}
  PropertyTagGpsLatitude        = $0002;
  {$EXTERNALSYM PropertyTagGpsLatitude}
  PropertyTagGpsLongitudeRef    = $0003;
  {$EXTERNALSYM PropertyTagGpsLongitudeRef}
  PropertyTagGpsLongitude       = $0004;
  {$EXTERNALSYM PropertyTagGpsLongitude}
  PropertyTagGpsAltitudeRef     = $0005;
  {$EXTERNALSYM PropertyTagGpsAltitudeRef}
  PropertyTagGpsAltitude        = $0006;
  {$EXTERNALSYM PropertyTagGpsAltitude}
  PropertyTagGpsGpsTime         = $0007;
  {$EXTERNALSYM PropertyTagGpsGpsTime}
  PropertyTagGpsGpsSatellites   = $0008;
  {$EXTERNALSYM PropertyTagGpsGpsSatellites}
  PropertyTagGpsGpsStatus       = $0009;
  {$EXTERNALSYM PropertyTagGpsGpsStatus}
  PropertyTagGpsGpsMeasureMode  = $00A;
  {$EXTERNALSYM PropertyTagGpsGpsMeasureMode}
  PropertyTagGpsGpsDop          = $000B;  // Measurement precision
  {$EXTERNALSYM PropertyTagGpsGpsDop}
  PropertyTagGpsSpeedRef        = $000C;
  {$EXTERNALSYM PropertyTagGpsSpeedRef}
  PropertyTagGpsSpeed           = $000D;
  {$EXTERNALSYM PropertyTagGpsSpeed}
  PropertyTagGpsTrackRef        = $000E;
  {$EXTERNALSYM PropertyTagGpsTrackRef}
  PropertyTagGpsTrack           = $000F;
  {$EXTERNALSYM PropertyTagGpsTrack}
  PropertyTagGpsImgDirRef       = $0010;
  {$EXTERNALSYM PropertyTagGpsImgDirRef}
  PropertyTagGpsImgDir          = $0011;
  {$EXTERNALSYM PropertyTagGpsImgDir}
  PropertyTagGpsMapDatum        = $0012;
  {$EXTERNALSYM PropertyTagGpsMapDatum}
  PropertyTagGpsDestLatRef      = $0013;
  {$EXTERNALSYM PropertyTagGpsDestLatRef}
  PropertyTagGpsDestLat         = $0014;
  {$EXTERNALSYM PropertyTagGpsDestLat}
  PropertyTagGpsDestLongRef     = $0015;
  {$EXTERNALSYM PropertyTagGpsDestLongRef}
  PropertyTagGpsDestLong        = $0016;
  {$EXTERNALSYM PropertyTagGpsDestLong}
  PropertyTagGpsDestBearRef     = $0017;
  {$EXTERNALSYM PropertyTagGpsDestBearRef}
  PropertyTagGpsDestBear        = $0018;
  {$EXTERNALSYM PropertyTagGpsDestBear}
  PropertyTagGpsDestDistRef     = $0019;
  {$EXTERNALSYM PropertyTagGpsDestDistRef}
  PropertyTagGpsDestDist        = $001A;
  {$EXTERNALSYM PropertyTagGpsDestDist}

type
  TENHMETAHEADER3 = packed record
    iType: DWORD;              // Record type EMR_HEADER
    nSize: DWORD;              // Record size in bytes.  This may be greater
                               // than the sizeof(ENHMETAHEADER).
    rclBounds: WinApi.Windows.TRect;  // Inclusive-inclusive bounds in device units
    rclFrame: WinApi.Windows.TRect;   // Inclusive-inclusive Picture Frame .01mm unit

    dSignature: DWORD;         // Signature.  Must be ENHMETA_SIGNATURE.
    nVersion: DWORD;           // Version number
    nBytes: DWORD;             // Size of the metafile in bytes
    nRecords: DWORD;           // Number of records in the metafile
    nHandles: WORD;            // Number of handles in the handle table
                               // Handle index zero is reserved.
    sReserved: WORD;           // Reserved.  Must be zero.
    nDescription: DWORD;       // Number of chars in the unicode desc string
                               // This is 0 if there is no description string
    offDescription: DWORD;     // Offset to the metafile description record.
                               // This is 0 if there is no description string
    nPalEntries: DWORD;        // Number of entries in the metafile palette.
    szlDevice: WinApi.Windows.TSize;  // Size of the reference device in pels
    szlMillimeters: WinApi.Windows.TSize; // Size of the reference device in millimeters
  end;
  PENHMETAHEADER3 = ^TENHMETAHEADER3;

// Placeable WMFs

// Placeable Metafiles were created as a non-standard way of specifying how 
// a metafile is mapped and scaled on an output device.
// Placeable metafiles are quite wide-spread, but not directly supported by
// the Windows API. To playback a placeable metafile using the Windows API,
// you will first need to strip the placeable metafile header from the file.
// This is typically performed by copying the metafile to a temporary file
// starting at file offset 22 (0x16). The contents of the temporary file may
// then be used as input to the Windows GetMetaFile(), PlayMetaFile(),
// CopyMetaFile(), etc. GDI functions.

// Each placeable metafile begins with a 22-byte header,
//  followed by a standard metafile:

  TPWMFRect16 = packed record
    Left: INT16;
    Top: INT16;
    Right: INT16;
    Bottom: INT16;
  end;
  PPWMFRect16 = ^TPWMFRect16;

  TWmfPlaceableFileHeader = packed record
    Key: UINT32;              // GDIP_WMF_PLACEABLEKEY,指示存在可放置的图元文件头。
    Hmf: INT16;               // 内存中图元文件的句柄。
    BoundingBox: TPWMFRect16; // 输出设备上图元文件图像的边框
    Inch: INT16;              // 每英寸的缇数。
    Reserved: UINT32;         // 保留
    Checksum: INT16;          // 文件头中前 10 个 WORD 的校验和值。
  end;
  PWmfPlaceableFileHeader = ^TWmfPlaceableFileHeader;

// Key contains a special identification value that indicates the presence
// of a placeable metafile header and is always 0x9AC6CDD7.

// Handle is used to stored the handle of the metafile in memory. When written
// to disk, this field is not used and will always contains the value 0.

// Left, Top, Right, and Bottom contain the coordinates of the upper-left
// and lower-right corners of the image on the output device. These are
// measured in twips.

// A twip (meaning "twentieth of a point") is the logical unit of measurement
// used in Windows Metafiles. A twip is equal to 1/1440 of an inch. Thus 720
// twips equal 1/2 inch, while 32,768 twips is 22.75 inches.

// Inch contains the number of twips per inch used to represent the image.
// Normally, there are 1440 twips per inch; however, this number may be
// changed to scale the image. A value of 720 indicates that the image is
// double its normal size, or scaled to a factor of 2:1. A value of 360
// indicates a scale of 4:1, while a value of 2880 indicates that the image
// is scaled down in size by a factor of two. A value of 1440 indicates
// a 1:1 scale ratio.

// Reserved is not used and is always set to 0.

// Checksum contains a checksum value for the previous 10 WORDs in the header.
// This value can be used in an attempt to detect if the metafile has become
// corrupted. The checksum is calculated by XORing each WORD value to an
// initial value of 0.

// If the metafile was recorded with a reference Hdc that was a display.
const
  GDIP_EMFPLUSFLAGS_DISPLAY      = $00000001;
  {$EXTERNALSYM GDIP_EMFPLUSFLAGS_DISPLAY}
type
  TMetafileHeader = packed class
  public
    mType: TMetafileType;
    Size: UINT;               // Size of the metafile (in bytes)
    Version: UINT;            // EMF+, EMF, or WMF version
    EmfPlusFlags: UINT;
    DpiX: TREAL;
    DpiY: TREAL;
    X: INT;                  // Bounds in device units
    Y: INT;
    Width: INT;
    Height: INT;
    Header: record
    case Integer of
      0: (WmfHeader: TMETAHEADER);
      1: (EmfHeader: TENHMETAHEADER3);
    end;
    EmfPlusHeaderSize: INT;  // size of the EMF+ header in file
    LogicalDpiX: INT;        // Logical Dpi of reference Hdc
    LogicalDpiY: INT;        // usually valid only for EMF+
  public
    procedure GetBounds (var rc: TRect);
    // Is it any type of WMF (standard or Placeable Metafile)?
    function IsWmf: BOOL;
    // Is this an Placeable Metafile?
    function IsWmfPlaceable: BOOL;
    // Is this an EMF (not an EMF+)?
    function IsEmf: BOOL;
    // Is this an EMF or EMF+ file?
    function IsEmfOrEmfPlus: BOOL;
    // Is this an EMF+ file?
    function IsEmfPlus: BOOL;
    // Is this an EMF+ dual (has dual, down-level records) file?
    function IsEmfPlusDual: BOOL;
    // Is this an EMF+ only (no dual records) file?
    function IsEmfPlusOnly: BOOL;
    // If it's an EMF+ file, was it recorded against a display Hdc?
    function IsDisplay: BOOL;
    // Get the WMF header of the metafile (if it is a WMF)
    function GetWmfHeader: PMETAHEADER;
    // Get the EMF header of the metafile (if it is an EMF)
    function GetEmfHeader: PENHMETAHEADER3;

    property GetType: TMetafileType read mType;
    property GetMetafileSize: UINT read Size;
    // If IsEmfPlus, this is the EMF+ version; else it is the WMF or EMF ver
    property GetVersion: UINT read Version;
    // Get the EMF+ flags associated with the metafile
    property GetEmfPlusFlags: UINT read EmfPlusFlags;
    property GetDpiX: TREAL read DpiX;
    property GetDpiY: TREAL read DpiY;
  end;

  EGdiplusException = class(Exception)
  private
    FGdipError: TStatus;
    function GetGdipErrorString: string;
  public
    constructor CreateStatus(Status: TStatus);
    property GdipError: TStatus read FGdipError;
    property GdipErrorString: string read GetGdipErrorString;
  end;
  
type
  TDebugEventLevel = (DebugEventLevelFatal, DebugEventLevelWarning);

// Callback function that GDI+ can call, on debug builds, for assertions
// and warnings.

  TDebugEventProc = procedure(Level: TDebugEventLevel; aMessage: PChar); stdcall;

// Notification functions which the user must call appropriately if
// "SuppressBackgroundThread" (below) is set.

  TNotificationHookProc = function(var token: DWORD): TStatus; stdcall;
  TNotificationUnhookProc = procedure(token: DWORD); stdcall;

// Input structure for GdiplusStartup()

  PGdiplusStartupInput = ^TGdiplusStartupInput;
  TGdiplusStartupInput = packed record
    GdiplusVersion: INT;                // Must be 1
    DebugEventCallback: TDebugEventProc; // Ignored on free builds
    SuppressBackgroundThread: BOOL;      // FALSE unless you're prepared to call
                                         // the hook/unhook functions properly
    SuppressExternalCodecs: BOOL;        // FALSE unless you want GDI+ only to use
                                         // its internal image codecs.
  end;

// Output structure for GdiplusStartup()

  PGdiplusStartupOutput = ^TGdiplusStartupOutput;
  TGdiplusStartupOutput = packed record
    // The following 2 fields are NULL if SuppressBackgroundThread is FALSE.
    // Otherwise, they are functions which must be called appropriately to
    // replace the background thread.
    //
    // These should be called on the application's main message loop - i.e.
    // a message loop which is active for the lifetime of GDI+.
    // "NotificationHook" should be called before starting the loop,
    // and "NotificationUnhook" should be called after the loop ends.

    NotificationHook: TNotificationHookProc;
    NotificationUnhook: TNotificationUnhookProc;
  end;

function MakeGdiplusStartupInput(
           debugEventCallback: TDebugEventProc = nil;
           suppressBackgroundThread: BOOL = FALSE;
           suppressExternalCodecs: BOOL = FALSE): TGdiplusStartupInput;

implementation

uses Math;

const
  ErrorStr: array[1..20] of string = (
      'GenericError',
      'InvalidParameter',
      'OutOfMemory',
      'ObjectBusy',
      'InsufficientBuffer',
      'NotImplemented',
      'Win32Error',
      'WrongState',
      'Aborted',
      'FileNotFound',
      'ValueOverflow',
      'AccessDenied',
      'UnknownImageFormat',
      'FontFamilyNotFound',
      'FontStyleNotFound',
      'NotTrueTypeFont',
      'UnsupportedGdiplusVersion',
      'GdiplusNotInitialized',
      'PropertyNotFound',
      'PropertyNotSupported'
      );

function ObjectTypeIsValid(AType: TObjectType): BOOL;
begin
  Result := ((AType >= ObjectTypeMin) and (AType <= ObjectTypeMax));
end;

function GDIP_WMF_RECORD_TO_EMFPLUS(n: Integer): TEmfPlusRecordType;
begin
  Result := TEmfPlusRecordType(n or GDIP_WMF_RECORD_BASE);
end;

function GDIP_EMFPLUS_RECORD_TO_WMF(n: Integer): Integer;
begin
  Result := n and (not GDIP_WMF_RECORD_BASE);
end;

function GDIP_IS_WMF_RECORDTYPE(n: Integer): BOOL;
begin
  Result := (n and GDIP_WMF_RECORD_BASE) <> 0;
end;

function GetPixelFormatSize(pixfmt: TPixelFormat): UINT;
begin
  Result := (pixfmt shr 8) and $ff;
end;

function IsIndexedPixelFormat(pixfmt: TPixelFormat): BOOL;
begin
  Result := (pixfmt and PixelFormatIndexed) <> 0;
end;

function IsAlphaPixelFormat(pixfmt: TPixelFormat): BOOL;
begin
  Result := (pixfmt and PixelFormatAlpha) <> 0;
end;

function IsExtendedPixelFormat(pixfmt: TPixelFormat): BOOL;
begin
  Result := (pixfmt and PixelFormatExtended) <> 0;
end;

function IsCanonicalPixelFormat(pixfmt: TPixelFormat): BOOL;
begin
  Result := (pixfmt and PixelFormatCanonical) <> 0;
end;

{ TMetafileHeader }

procedure TMetafileHeader.GetBounds(var rc: TRect);
begin
  rc.X := X;
  rc.Y := Y;
  rc.Width := Width;
  rc.Height := Height;
end;

function TMetafileHeader.GetEmfHeader: PENHMETAHEADER3;
begin
  if IsEmfOrEmfPlus then Result := @Header.EmfHeader
  else Result := nil;
end;

function TMetafileHeader.GetWmfHeader: PMETAHEADER;
begin
  if IsWmf then Result := @Header.WmfHeader
  else Result := nil;
end;

function TMetafileHeader.IsDisplay: BOOL;
begin
  Result := IsEmfPlus and
                ((EmfPlusFlags and GDIP_EMFPLUSFLAGS_DISPLAY) <> 0);
end;

function TMetafileHeader.IsEmf: BOOL;
begin
  Result := mType = MetafileTypeEmf;
end;

function TMetafileHeader.IsEmfOrEmfPlus: BOOL;
begin
  Result := mType >= MetafileTypeEmf;
end;

function TMetafileHeader.IsEmfPlus: BOOL;
begin
  Result := mType >= MetafileTypeEmfPlusOnly;
end;

function TMetafileHeader.IsEmfPlusDual: BOOL;
begin
  Result := mType = MetafileTypeEmfPlusDual;
end;

function TMetafileHeader.IsEmfPlusOnly: BOOL;
begin
  Result := mType = MetafileTypeEmfPlusOnly;
end;

function TMetafileHeader.IsWmf: BOOL;
begin
  Result := (mType = MetafileTypeWmf) or (mType = MetafileTypeWmfPlaceable);
end;

function TMetafileHeader.IsWmfPlaceable: BOOL;
begin
  Result := mType = MetafileTypeWmfPlaceable;
end;

{ EGdiplusException }

constructor EGdiplusException.CreateStatus(Status: TStatus);
begin
  FGdipError := Status;
  inherited Create('Gdiplus Error: ' + GdipErrorString);
end;

function EGdiplusException.GetGdipErrorString: string;
begin
   Result := ErrorStr[Integer(FGdipError)];
end;

function MakeGdiplusStartupInput(debugEventCallback: TDebugEventProc;
    suppressBackgroundThread: BOOL; suppressExternalCodecs: BOOL): TGdiplusStartupInput;
begin
  Result.GdiplusVersion := 1;
  Result.DebugEventCallback := debugEventCallback;
  Result.SuppressBackgroundThread := suppressBackgroundThread;
  Result.SuppressExternalCodecs := suppressExternalCodecs;
end;

end.










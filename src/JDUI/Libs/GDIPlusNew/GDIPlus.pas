unit Gdiplus;

(***************************************************************************\
*
* 2003年，湖北省公安县统计局 毛泽发 于大连
*
* Module Name:
*
*   Gdiplus.pas
*
* Abstract:
*
*   GDI+ class
*
* 注：原始数据类型定义在GdipTypes.pas中，为了Delphi习惯，常用的已经在本模块重新
*     定义。要使用某些特殊的枚举、记录、常量或过程必须包含GdipTypes.pas文件
*
**************************************************************************)

//{$ALIGN OFF}
//{$MINENUMSIZE 1}
interface

uses
  SysUtils, WinApi.ActiveX, Classes, Vcl.Graphics, WinApi.Windows, GdipTypes;

 // Known Color
const
  kcAliceBlue            = $FFF0F8FF;
  kcAntiqueWhite         = $FFFAEBD7;
  kcAqua                 = $FF00FFFF;
  kcAquamarine           = $FF7FFFD4;
  kcAzure                = $FFF0FFFF;
  kcBeige                = $FFF5F5DC;
  kcBisque               = $FFFFE4C4;
  kcBlack                = $FF000000;
  kcBlanchedAlmond       = $FFFFEBCD;
  kcBlue                 = $FF0000FF;
  kcBlueViolet           = $FF8A2BE2;
  kcBrown                = $FFA52A2A;
  kcBurlyWood            = $FFDEB887;
  kcCadetBlue            = $FF5F9EA0;
  kcChartreuse           = $FF7FFF00;
  kcChocolate            = $FFD2691E;
  kcCoral                = $FFFF7F50;
  kcCornflowerBlue       = $FF6495ED;
  kcCornsilk             = $FFFFF8DC;
  kcCrimson              = $FFDC143C;
  kcCyan                 = $FF00FFFF;
  kcDarkBlue             = $FF00008B;
  kcDarkCyan             = $FF008B8B;
  kcDarkGoldenrod        = $FFB8860B;
  kcDarkGray             = $FFA9A9A9;
  kcDarkGreen            = $FF006400;
  kcDarkKhaki            = $FFBDB76B;
  kcDarkMagenta          = $FF8B008B;
  kcDarkOliveGreen       = $FF556B2F;
  kcDarkOrange           = $FFFF8C00;
  kcDarkOrchid           = $FF9932CC;
  kcDarkRed              = $FF8B0000;
  kcDarkSalmon           = $FFE9967A;
  kcDarkSeaGreen         = $FF8FBC8B;
  kcDarkSlateBlue        = $FF483D8B;
  kcDarkSlateGray        = $FF2F4F4F;
  kcDarkTurquoise        = $FF00CED1;
  kcDarkViolet           = $FF9400D3;
  kcDeepPink             = $FFFF1493;
  kcDeepSkyBlue          = $FF00BFFF;
  kcDimGray              = $FF696969;
  kcDodgerBlue           = $FF1E90FF;
  kcFirebrick            = $FFB22222;
  kcFloralWhite          = $FFFFFAF0;
  kcForestGreen          = $FF228B22;
  kcFuchsia              = $FFFF00FF;
  kcGainsboro            = $FFDCDCDC;
  kcGhostWhite           = $FFF8F8FF;
  kcGold                 = $FFFFD700;
  kcGoldenrod            = $FFDAA520;
  kcGray                 = $FF808080;
  kcGreen                = $FF008000;
  kcGreenYellow          = $FFADFF2F;
  kcHoneydew             = $FFF0FFF0;
  kcHotPink              = $FFFF69B4;
  kcIndianRed            = $FFCD5C5C;
  kcIndigo               = $FF4B0082;
  kcIvory                = $FFFFFFF0;
  kcKhaki                = $FFF0E68C;
  kcLavender             = $FFE6E6FA;
  kcLavenderBlush        = $FFFFF0F5;
  kcLawnGreen            = $FF7CFC00;
  kcLemonChiffon         = $FFFFFACD;
  kcLightBlue            = $FFADD8E6;
  kcLightCoral           = $FFF08080;
  kcLightCyan            = $FFE0FFFF;
  kcLightGoldenrodYellow = $FFFAFAD2;
  kcLightGray            = $FFD3D3D3;
  kcLightGreen           = $FF90EE90;
  kcLightPink            = $FFFFB6C1;
  kcLightSalmon          = $FFFFA07A;
  kcLightSeaGreen        = $FF20B2AA;
  kcLightSkyBlue         = $FF87CEFA;
  kcLightSlateGray       = $FF778899;
  kcLightSteelBlue       = $FFB0C4DE;
  kcLightYellow          = $FFFFFFE0;
  kcLime                 = $FF00FF00;
  kcLimeGreen            = $FF32CD32;
  kcLinen                = $FFFAF0E6;
  kcMagenta              = $FFFF00FF;
  kcMaroon               = $FF800000;
  kcMediumAquamarine     = $FF66CDAA;
  kcMediumBlue           = $FF0000CD;
  kcMediumOrchid         = $FFBA55D3;
  kcMediumPurple         = $FF9370DB;
  kcMediumSeaGreen       = $FF3CB371;
  kcMediumSlateBlue      = $FF7B68EE;
  kcMediumSpringGreen    = $FF00FA9A;
  kcMediumTurquoise      = $FF48D1CC;
  kcMediumVioletRed      = $FFC71585;
  kcMidnightBlue         = $FF191970;
  kcMintCream            = $FFF5FFFA;
  kcMistyRose            = $FFFFE4E1;
  kcMoccasin             = $FFFFE4B5;
  kcNavajoWhite          = $FFFFDEAD;
  kcNavy                 = $FF000080;
  kcOldLace              = $FFFDF5E6;
  kcOlive                = $FF808000;
  kcOliveDrab            = $FF6B8E23;
  kcOrange               = $FFFFA500;
  kcOrangeRed            = $FFFF4500;
  kcOrchid               = $FFDA70D6;
  kcPaleGoldenrod        = $FFEEE8AA;
  kcPaleGreen            = $FF98FB98;
  kcPaleTurquoise        = $FFAFEEEE;
  kcPaleVioletRed        = $FFDB7093;
  kcPapayaWhip           = $FFFFEFD5;
  kcPeachPuff            = $FFFFDAB9;
  kcPeru                 = $FFCD853F;
  kcPink                 = $FFFFC0CB;
  kcPlum                 = $FFDDA0DD;
  kcPowderBlue           = $FFB0E0E6;
  kcPurple               = $FF800080;
  kcRed                  = $FFFF0000;
  kcRosyBrown            = $FFBC8F8F;
  kcRoyalBlue            = $FF4169E1;
  kcSaddleBrown          = $FF8B4513;
  kcSalmon               = $FFFA8072;
  kcSandyBrown           = $FFF4A460;
  kcSeaGreen             = $FF2E8B57;
  kcSeaShell             = $FFFFF5EE;
  kcSienna               = $FFA0522D;
  kcSilver               = $FFC0C0C0;
  kcSkyBlue              = $FF87CEEB;
  kcSlateBlue            = $FF6A5ACD;
  kcSlateGray            = $FF708090;
  kcSnow                 = $FFFFFAFA;
  kcSpringGreen          = $FF00FF7F;
  kcSteelBlue            = $FF4682B4;
  kcTan                  = $FFD2B48C;
  kcTeal                 = $FF008080;
  kcThistle              = $FFD8BFD8;
  kcTomato               = $FFFF6347;
  kcTransparent          = $00FFFFFF;
  kcTurquoise            = $FF40E0D0;
  kcViolet               = $FFEE82EE;
  kcWheat                = $FFF5DEB3;
  kcWhite                = $FFFFFFFF;
  kcWhiteSmoke           = $FFF5F5F5;
  kcYellow               = $FFFFFF00;
  kcYellowGreen          = $FF9ACD32;

type
  EGdiplusException = GdipTypes.EGdiplusException;

  TREAL = GdipTypes.TREAL;
  TARGB = GdipTypes.TARGB;
  PARGB = GdipTypes.PARGB;
  TGpPoint = GdipTypes.TPoint;
  PGpPoint = GdipTypes.PPoint;
  TGpPointF = GdipTypes.TPointF;
  PGpPointF = GdipTypes.PPointF;
  TGpSize = GdipTypes.TSize;
  PGpSize = GdipTypes.PSize;
  TGpSizeF = GdipTypes.TSizeF;
  PGpSizeF = GdipTypes.PSizeF;
  TGpRect = GdipTypes.TRect;
  PGpRect = GdipTypes.PRect;
  TGpRectF = GdipTypes.TRectF;
  PGpRectF = GdipTypes.PRectF;

//--------------------------------------------------------------------------
// TGdiplusBase
//--------------------------------------------------------------------------

  TCloneAPI = function(Native: GpNative; var clone: GpNative): TStatus; stdcall;

  TGdiplusBase = class(TObject)
  private
    FNative: GpNative;
  protected
    constructor CreateClone(SrcNative: GpNative; clonefunc: TCloneAPI = nil);
    property Native: GpNative read FNative write FNative;
  public
    constructor Create;
    class function NewInstance: TObject; override;
    procedure FreeInstance; override;
  end;

  TGpGraphics = class;
  TGpGraphicsPath = class;
  TGpFontCollection = class;

//--------------------------------------------------------------------------
// 封装表示几何变形的 3 x 2 仿射矩阵。
// 备注: 3 x 2 矩阵在第一列包含 x 值，在第二列包含 y 值，在第三列包含 w 值。
//--------------------------------------------------------------------------

  TMatrixElements = packed record
    case Integer of
      0: (Elements: array[0..5] of  Single);
      1: (m11, m12, m21, m22, dx, dy: Single);
  end;

  PMatrixElements = ^TMatrixElements;

  TMatrixOrder = (moPrepend, moAppend);

  TGpMatrix = class(TGdiplusBase)
  private
    function GetElements: TMatrixElements;
    procedure SetElements(const Value: TMatrixElements);
    function GetOffsetX: Single;
    function GetOffsetY: Single;
    function GetIdentity: Boolean;
    function GetInvertible: Boolean;
  public
    // 将 Matrix 类的一个新实例初始化为单位矩阵。. Elements = 1,0,0,1,0,0
    constructor Create; overload;
    // 使用指定的元素初始化 Matrix 类的新实例。
    constructor Create(m11, m12, m21, m22, dx, dy: Single); overload;
    // 将 Matrix 类的一个新实例初始化为指定矩形和点数组定义的几何变形。dstplg 由三个 Point 结构构成的数组
    constructor Create(rect: TGpRectF; dstplg: array of TGpPointF); overload;
    constructor Create(rect: TGpRect; dstplg: array of TGpPoint); overload;
    destructor Destroy; override;
    function Clone: TGpMatrix;
    // 重置此 Matrix 对象以具有单位矩阵的元素。
    procedure Reset;
    // 按指定的顺序将此 Matrix 对象与在 matrix 参数中指定的矩阵相乘。
    procedure Multiply(const matrix: TGpMatrix; order: TMatrixOrder = moPrepend);
    // 通过预先计算转换向量将指定的转换向量应用到此 Matrix 对象。
    procedure Translate(offsetX, offsetY: Single; order: TMatrixOrder = moPrepend);
    // 使用指定的顺序将指定的缩放向量（scaleX 和 scaleY）应用到此 Matrix 对象。
    procedure Scale(scaleX, scaleY: Single; order: TMatrixOrder = moPrepend);
    // 应用 angle 参数中指定的顺时针旋转量，为此 Matrix 对象沿原点（X,Y 坐标）旋转。
    procedure Rotate(angle: Single; order: TMatrixOrder = moPrepend);
    // 通过预先计算旋转，将沿指定点的顺时针旋转应用到该 Matrix 对象。
    procedure RotateAt(angle: Single; const center: TGpPointF; order: TMatrixOrder = moPrepend);
    // 按指定的顺序将指定的切变向量应用到此 Matrix 对象。
    procedure Shear(shearX, shearY: Single; order: TMatrixOrder = moPrepend);
    // 如果此 Matrix 对象是可逆转的，则逆转该对象。
    procedure Invert;
    // 对指定的点数组应用此 Matrix 对象所表示的几何变形。
    procedure TransformPoints(pts: array of TGpPointF); overload;
    procedure TransformPoints(pts: array of TGpPoint); overload;
    // 只将该 Matrix 对象的伸缩和旋转成分应用到指定的点数组。
    procedure TransformVectors(pts: array of TGpPointF); overload;
    procedure TransformVectors(pts: array of TGpPoint); overload;
    function Equals(const matrix: TGpMatrix): Boolean;
      {$IF RTLVersion >= 20}reintroduce; overload;{$IFEND}
    // 获取一个值，该值指示此 Matrix 对象是否是可逆转的。
    property IsInvertible: Boolean read GetInvertible;
    // 获取一个值，该值指示此 Matrix 对象是否是单位矩阵。
    property IsIdentity: Boolean read GetIdentity;
    // 获取或设置该 Matrix 对象的元素。
    property Elements: TMatrixElements read GetElements write SetElements;
    // 获取此 Matrix 对象的 x 转换值（dx 值，或第三行、第一列中的元素）。
    property OffsetX: Single read GetOffsetX;
    // 获取此 Matrix 的 y 转换值（dy 值，或第三行、第二列中的元素）。
    property OffsetY: Single read GetOffsetY;
  end;

//--------------------------------------------------------------------------
// TRegion
//--------------------------------------------------------------------------

  TGpRegion = class(TGdiplusBase)
  private
    function GetDataSize: Integer;
  public
    // 用无限内部初始化新 Region 对象。
    constructor Create; overload;
    // 从指定的 Rect 结构初始化新 Region 对象。
    constructor Create(rect: TGpRectF);  overload;
    constructor Create(rect: TGpRect); overload;
    // 从指定的 Rect 结构初始化新 Region 对象。
    constructor Create(path: TGpGraphicsPath); overload;
    // 用现有的 Region 对象的内部数据创建一个新 Region 对象。
    // regionData 包含Region对象内部数据的缓冲区，一般通过GetData获得
    constructor Create(regionData: array of Byte); overload;
    // 用指定的现有 GDI 区域的句柄初始化新 Region 对象。
    constructor Create(hrgn: HRGN); overload;
    class function FromHRGN(hrgn: HRGN): TGpRegion;
    destructor Destroy; override;
    function Clone: TGpRegion;
    // 将此 Region 对象初始化为无限内部。
    procedure MakeInfinite;
    // 将此 Region 对象初始化为空内部。
    procedure MakeEmpty;

    // 返回 RegionData，它表示用于描述此 Region 结构或对象的信息。
    procedure GetData(var buffer: array of Byte; sizeFilled: PLongWord = nil);
    // 将此 Region 对象更新为其自身与指定结构或对象的交集。
    procedure Intersect(const rect: TGpRect); overload;
    procedure Intersect(const rect: TGpRectF); overload;
    procedure Intersect(path: TGpGraphicsPath); overload;
    procedure Intersect(region: TGpRegion); overload;
    // 将此 Region 对象更新为其自身与指定结构或对象的并集。
    procedure Union(const rect: TGpRect); overload;
    procedure Union(const rect: TGpRectF); overload;
    procedure Union(path: TGpGraphicsPath); overload;
    procedure Union(region: TGpRegion); overload;
    // 将此 Region 对象更新为其自身与指定结构或对象的并集减去这两者的交集
    procedure Xor_(const rect: TGpRect); overload;
    procedure Xor_(const rect: TGpRectF); overload;
    procedure Xor_(path: TGpGraphicsPath); overload;
    procedure Xor_(region: TGpRegion); overload;
    // 将此 Region 对象更新为仅包含其内部与指定结构或对象不相交的部分。
    procedure Exclude(const rect: TGpRect); overload;
    procedure Exclude(const rect: TGpRectF); overload;
    procedure Exclude(path: TGpGraphicsPath); overload;
    procedure Exclude(region: TGpRegion); overload;
    // 将此 Region 对象更新为指定结构或者对象中与此 Region 对象不相交的部分。
    procedure Complement(const rect: TGpRect); overload;
    procedure Complement(const rect: TGpRectF); overload;
    procedure Complement(path: TGpGraphicsPath); overload;
    procedure Complement(region: TGpRegion); overload;
    // 使此 Region 对象的坐标偏移指定的量。
    procedure Translate(dx, dy: Single); overload;
    procedure Translate(dx, dy: Integer); overload;
    // 用指定的 Matrix 对象变换此 Region 对象。
    procedure Transform(matrix: TGpMatrix);
    // 获取一个矩形结构，该矩形形成 Graphics 对象的绘制表面上此 Region 对象的边界。
    procedure GetBounds(var rect: TGpRect; const g: TGpGraphics); overload;
    procedure GetBounds(var rect: TGpRectF; const g: TGpGraphics); overload;
    // 返回指定图形上下文中此 Region 对象的 Windows GDI 句柄。
    function GetHRGN(g: TGpGraphics): HRGN;
    // 测试此 Region 对象在指定的绘制表面 g 上是否空的内部
    function IsEmpty(g: TGpGraphics): Boolean;
    // 测试此 Region 对象在指定的绘制表面上是否无限内部。
    function IsInfinite(g: TGpGraphics): Boolean;
    // 测试指定的坐标是否包含在此 Region 对象内。
    function IsVisible(x, y: Integer; g: TGpGraphics = nil): Boolean; overload;
    function IsVisible(const point: TGpPoint; g: TGpGraphics = nil): Boolean; overload;
    function IsVisible(x, y: Single; g: TGpGraphics = nil): Boolean; overload;
    function IsVisible(const point: TGpPointF; g: TGpGraphics = nil): Boolean; overload;
    function IsVisible(x, y, width, height: Integer; g: TGpGraphics = nil): Boolean; overload;
    function IsVisible(const rect: TGpRect; g: TGpGraphics = nil): Boolean; overload;
    function IsVisible(x, y, width, height: Single; g: TGpGraphics = nil): Boolean; overload;
    function IsVisible(const rect: TGpRectF; g: TGpGraphics = nil): Boolean; overload;

    function Equals(region: TGpRegion; g: TGpGraphics): Boolean;
      {$IF RTLVersion >= 20}reintroduce; overload;{$IFEND}
    function GetRegionScansCount(matrix: TGpMatrix): Integer;
    // 获取与此 Region 对象近似的 RectF 结构的数组。返回数组元素个数
    function GetRegionScans(matrix: TGpMatrix; var rects: array of TGpRectF): Integer; overload;
    function GetRegionScans(matrix: TGpMatrix; var rects: array of TGpRect): Integer; overload;
    // 返回描述 Region 对象信息缓冲区的长度
    property DataSize: Integer read GetDataSize;
  end;

//--------------------------------------------------------------------------
// TFontFamily
//--------------------------------------------------------------------------

  TGpFontFamily = class(TGdiplusBase)
  public
    constructor Create; overload;
    constructor Create(name: WideString; fontCollection: TGpFontCollection = nil); overload;
    destructor Destroy; override;
    class function GenericSansSerif: TGpFontFamily;
    class function GenericSerif: TGpFontFamily;
    class function GenericMonospace: TGpFontFamily;
    // 用指定的语言返回此 FontFamily 对象的名称。
    function GetFamilyName(language: LANGID = 0): WideString;
    function Clone: TGpFontFamily;
    // FontFamily 对象是否有效
    function IsAvailable: Boolean;
    // 指示指定的 FontStyle 枚举是否有效。
    function IsStyleAvailable(style: TFontStyles): Boolean;
    // 获取指定样式的 em 方形的高度，采用字体设计单位。
    function GetEmHeight(style: TFontStyles): Word;
    // 返回指定样式的 FontFamily 对象的单元格上升
    function GetCellAscent(style: TFontStyles): Word;
    // 返回指定样式的 FontFamily 对象的单元格下降
    function GetCellDescent(style: TFontStyles): Word;
    // 返回指定样式的 FontFamily 对象的行距
    function GetLineSpacing(style: TFontStyles): Word;
  end;

//--------------------------------------------------------------------------
// TFont
//--------------------------------------------------------------------------
  TUnit = (utWorld, utDisplay, utPixel, utPoint, utInch, utDocument, utMillimeter);

  TGpFont = class(TGdiplusBase)
  private
    function GetSize: Single;
    function GetStyle: TFontStyles;
    function GetUnit: TUnit;
    function GetName: WideString;
  public
    // 从设备上下文的指定 Windows 句柄创建 Font 对象。
    // DC 参数必须包含其中选定字体的设备上下文的句柄。
    // 此方法不能用于从 GDI+ Graphics 对象获得的 hdc，因为此 hdc 没有选定的字体。
    constructor Create(DC: HDC); overload;
    constructor Create(DC: HDC; logfont: PLOGFONTA); overload;
    constructor Create(DC: HDC; logfont: PLOGFONTW); overload;
    constructor Create(DC: HDC; font: HFONT); overload;
    constructor Create(family: TGpFontFamily; emSize: Single;
                       style: TFontStyles = [];
                       unit_: TUnit = utPoint);  overload;
    constructor Create(familyName: WideString; emSize: Single;
                       style: TFontStyles = [];
                       unit_: TUnit = utPoint;
                       fontCollection: TGpFontCollection = nil); overload;
    destructor Destroy; override;
    function GetLogFontA(g: TGpGraphics): TLogFontA;
    function GetLogFontW(g: TGpGraphics): TLogFontW;
    function Clone: TGpFont;
    function IsAvailable: Boolean;
    // 采用指定的 Graphics 对象的当前单位，返回此字体的行距。
    function GetHeight(graphics: TGpGraphics): Single; overload;
    // 当用指定的垂直分辨率绘制到设备时返回此 Font 对象的高度，以像素为单位。
    // 行距是两个连续文本行的基线之间的垂直距离。
    // 因此，行距包括行间的空白空间及字符本身的高度。
    function GetHeight(dpi: Single): Single; overload;
    // 获取此 Font 对象的字形信息。
    procedure GetFamily(family: TGpFontFamily);
    // 获取采用这个 Font 对象的单位测量出的、这个 Font 对象的全身大小
    property Size: Single read GetSize;
    property Style: TFontStyles read GetStyle;
    property FontUnit: TUnit read GetUnit;
    property Name: WideString read GetName;
  end;

//--------------------------------------------------------------------------
// Font Collection
//--------------------------------------------------------------------------

  TGpFontCollection = class(TGdiplusBase)
  public
    function GetFamilyCount: Integer;
    function GetFamilies(var gpfamilies: array of TGpFontFamily): Integer;
  end;

  TGpInstalledFontCollection = class(TGpFontCollection) // 表示安装在系统上的字体。
  public
    constructor Create;
  end;

  TGpPrivateFontCollection = class(TGpFontCollection)
  public
    constructor Create; 
    destructor Destroy; override;
    procedure AddFontFile(const filename: WideString);
    procedure AddMemoryFont(const memory: Pointer; length: Integer);
  end;

//--------------------------------------------------------------------------
// TImageAttributes 对象包含有关在呈现时如何操作位图和图元文件颜色的信息。
//  维护多个颜色调整设置，包括颜色调整矩阵、灰度调整矩阵、伽玛校正值、
//  颜色映射表和颜色阈值。呈现过程中，可以对颜色进行校正、调暗、调亮或删除等等。
//--------------------------------------------------------------------------
  TColorMap = GdipTypes.TColorMap;
  PColorMap = GdipTypes.PColorMap;
  TColorMatrix = GdipTypes.TColorMatrix;
  PColorMatrix = GdipTypes.PColorMatrix;

  TColorAdjustType = (ctDefault, ctBitmap, ctBrush, ctPen, ctText, ctCount, ctAny);
  // 用同样的颜色调整矩阵调整所有颜色值（包括灰色底纹）, 不调整灰色底纹, 调整灰色底纹
  TColorMatrixFlags = (cfDefault, cfSkipGrays, cfAltGray);
  TColorChannelFlags = (ccfC, ccfM, ccfY, ccfK, ccfLast);
  TWrapMode = (wmTile, wmTileFlipX, wmTileFlipY, wmTileFlipXY, wmClamp);

  TGpImageAttributes = class(TGdiplusBase)
  public
    constructor Create;
    destructor Destroy; override;
    function Clone: TGpImageAttributes;
    procedure SetToIdentity(caType: TColorAdjustType = ctDefault);
    procedure Reset(caType: TColorAdjustType = ctDefault);
    // 为指定类别设置颜色调整矩阵。
    procedure SetColorMatrix(const colorMatrix: TColorMatrix;
               mode: TColorMatrixFlags = cfDefault;
               catype:  TColorAdjustType = ctDefault);
    // 清除指定类别的颜色调整矩阵。
    procedure ClearColorMatrix(caType: TColorAdjustType = ctDefault);
    // 为指定类别设置颜色调整矩阵和灰度调整矩阵。
    procedure SetColorMatrices(const colorMatrix, grayMatrix: TColorMatrix;
                  mode: TColorMatrixFlags = cfDefault;
                  catype: TColorAdjustType = ctDefault);
    procedure ClearColorMatrices(catype: TColorAdjustType = ctDefault);
    // 为指定类别设置阈值。
    // threshold: 0.0 到 1.0 之间的阈值.指定每种颜色成分的分界点。假定阈值设置为 0.7，
    // 并且假定当前所呈现的颜色中的红色、绿色和蓝色成分分别为 230、50 和 220。
    // 红色成分 230 大于 0.7x255，因此，红色成分将更改为 255（全亮度）。
    // 绿色成分 50 小于 0.7x255，因此，绿色成分将更改为 0。
    // 蓝色成分 220 大于 0.7x255，因此，蓝色成分将更改为 255
    procedure SetThreshold(threshold: Single; catype: TColorAdjustType = ctDefault);
    // 为指定类别清除阈值。
    procedure ClearThreshold(catype: TColorAdjustType = ctDefault);
    // 为指定类别设置伽玛值。gamma 伽玛校正值。典型的伽玛值在 1.0 到 2.2 之间；
    // 但在某些情况下，0.1 到 5.0 范围内的值也很有用。
    procedure SetGamma(gamma: Single; catype: TColorAdjustType = ctDefault);
    // 禁用伽玛校正。
    procedure ClearGamma(catype: TColorAdjustType = ctDefault);
    // 为指定类别关闭颜色调整。可以调用 ClearNoOp 恢复在 SetNoOp 调用前已存在的颜色调整设置。
    procedure SetNoOp(catype: TColorAdjustType = ctDefault);
    procedure ClearNoOp(catype: TColorAdjustType = ctDefault);
    // 为指定类别设置色键（透明范围）。只要颜色成分处于高低色键范围内，该颜色就会成为透明的。
    // colorLow 低色键值; colorHigh 高色键值
    procedure SetColorKey(const colorLow, colorHigh: TARGB; catype: TColorAdjustType = ctDefault);
    // 为指定类别清除色键（透明范围）。
    procedure ClearColorKey(catype: TColorAdjustType = ctDefault);
    // 为指定类别设置 CMYK 输出通道。flags: 指定输出通道。
    procedure SetOutputChannel(channelFlags: TColorChannelFlags; catype: TColorAdjustType = ctDefault);
    // 为指定类别清除 CMYK 输出通道设置。
    procedure ClearOutputChannel(catype: TColorAdjustType = ctDefault);
    // 为指定类别设置输出通道颜色配置文件
    procedure SetOutputChannelColorProfile(const colorProfileFilename: WideString;
                 catype: TColorAdjustType = ctDefault);
    // 为指定类别清除输出通道颜色配置文件设置。
    procedure ClearOutputChannelColorProfile(catype: TColorAdjustType = ctDefault);
    // 为指定类别设置颜色重新映射表。
    procedure SetRemapTable(const map: array of TColorMap; catype: TColorAdjustType = ctDefault);
    // 清除颜色重新映射表。
    procedure ClearRemapTable(catype: TColorAdjustType = ctDefault);
    // 为画刷类别设置颜色重新映射表。map: TColorMap数组。
    procedure SetBrushRemapTable(const map: array of TColorMap);
    // 清除画刷颜色重新映射表。
    procedure ClearBrushRemapTable;
    // 设置环绕模式和颜色，用于决定如何将纹理平铺到一个形状上，或平铺到形状的边界上。
    // 当纹理小于它所填充的形状时，纹理在该形状上平铺以填满该形状。
    // mode 重复的图像副本平铺区域的方式; color 指定呈现图像外部的像素的颜色。
    procedure SetWrapMode(wrap: TWrapMode; const color: TARGB); overload;
    procedure SetWrapMode(wrap: TWrapMode); overload;
    // 根据指定类别的调整设置，调整调色板中的颜色。
    // ColorPalette，在输入时包含要调整的调色板，在输出时包含已调整的调色板
    // ColorAdjustType 枚举的元素，它指定其调整设置将应用于调色板的类别。
    procedure GetAdjustedPalette(ColorPalette: PColorPalette; colorAdjustType: TColorAdjustType);
  end;

//--------------------------------------------------------------------------
// Abstract base class for Image and Metafile
//--------------------------------------------------------------------------

  TDrawImageAbort = GdipTypes.TDrawImageAbort;
  TGetThumbnailImageAbort = GdipTypes.TGetThumbnailImageAbort;

  TImageFlags = GdipTypes.TImageFlags;
  TColorPalette = GdipTypes.TColorPalette;
  PColorPalette = GdipTypes.PColorPalette;
  TImageType = (itUnknown, itBitmap, itMetafile);
  TEncoderParameter = GdipTypes.TEncoderParameter;
  PEncoderParameter = GdipTypes.PEncoderParameter;
  TEncoderParameters = GdipTypes.TEncoderParameters;
  PEncoderParameters = GdipTypes.PEncoderParameters;
  TPropertyItem = GdipTypes.TPropertyItem;
  PPropertyItem = GdipTypes.PPropertyItem;
  TRotateFlipType = (rfNone, rfNone90, rfNone180, rfNone270, rfXNone, rfX90, rfX180, rfX270,
                     rfYNone = rfX180, rfY90 = rfX270, rfY180 = rfXNone, rfY270 = rfX90,
                     rfXYNone = rfNone180, rfXY90 = rfNone270, rfXY180 = rfNone, rfXY270 = rfNone90);
  TPixelFormat = (pfNone, pf1bppIndexed, pf4bppIndexed, pf8bppIndexed, pf16bppGrayScale,
                  pf16bppRGB555, pf16bppRGB565, pf16bppARGB1555, pf24bppRGB,
                  pf32bppRGB, pf32bppARGB, pf32bppPARGB, pf48bppRGB,
                  pf64bppARGB, pf64bppPARGB);

  TGpImage = class(TGdiplusBase)
  private
    FPalette: PColorPalette;
    function GetFlags: TImageFlags;
    function GetHeight: Integer;
    function GetHorizontalResolution: Single;
    function GetPaletteSize: Integer;
    function GetPhysicalDimension: TGpSizeF;
    function GetRawFormat: TGUID;
    function GetType: TImageType;
    function GetVerticalResolution: Single;
    function GetWidth: Integer;
    function GetPixelFormat: TPixelFormat;
    function GetFrameDimensionsCount: Integer;
    function GetPropertyCount: Integer;
    function GetPropertySize: Integer;
    function GetPalette: PColorPalette;
    procedure SetPalette(const palette: PColorPalette);
  public
    // 使用该文件中的嵌入颜色管理信息，从指定的文件创建 Image 对象。
    constructor Create(const filename: WideString; useEmbeddedColorManagement: Boolean = False); overload;
    class function FromFile(const filename: WideString; useEmbeddedColorManagement: Boolean = False): TGpImage;
    // 使用指定的数据流中嵌入的颜色管理信息，从该数据流创建 Image 对象。
    constructor Create(stream: IStream; useEmbeddedColorManagement: Boolean = False); overload;
    class function FromStream(stream: IStream; useEmbeddedColorManagement: Boolean = False): TGpImage;
    destructor Destroy; override;
    function Clone: TGpImage; virtual;
    // 将此图像以指定的格式保存到指定的文件中
    // 注：通过文件名建立的Image，因文件处于引用状态，直接覆盖保存会出错
    procedure Save(const filename: WideString; const clsidEncoder: TCLSID;
        const encoderParams: PEncoderParameters = nil); overload;
    // 将此图像以指定的格式保存到指定的流中。
    procedure Save(stream: IStream; const clsidEncoder: TCLSID;
        const encoderParams: PEncoderParameters = nil); overload;
    // 在上一 Save 方法调用所指定的文件或流内添加一帧。
    procedure SaveAdd(const encoderParams: PEncoderParameters); overload;
    procedure SaveAdd(newImage: TGpImage; const encoderParams: PEncoderParameters); overload;
    // 以指定的单位获取此 Image 对象的矩形
    procedure GetBounds(var srcRect: TGpRectF; var srcUnit: TUnit);
    // 返回此 Image 对象的缩略图。使用后必须Free
    function GetThumbnailImage(thumbWidth, thumbHeight: Integer;
        callback:TGetThumbnailImageAbort = nil; callbackData: Pointer = nil): TGpImage;
    // 获取 GUID 的数组，这些 GUID 表示 Image 对象中帧的维度。
    procedure GetFrameDimensionsList(dimensionIDs: PGUID; Count: Integer);
    // 返回指定维度的帧数。
    function GetFrameCount(const dimensionID: TGUID): Integer;
    // 选择由维度和索引指定的帧。
    procedure SelectActiveFrame(const dimensionID: TGUID; frameIndex: Integer);
    // 此方法旋转、翻转或者同时旋转和翻转 Image 对象。
    procedure RotateFlip(rotateFlipType: TRotateFlipType);
    // 获取存储于 Image 对象中的属性项的 ID。list长度不小于PropertyCount
    procedure GetPropertyIdList(numOfProperty: Integer; list: PPropID);
    // 获取propID所指属性项的长度，包括TPropertyItem长度和其value所指的长度
    function GetPropertyItemSize(propId: PROPID): Integer;
    // 获取propID所指属性项，buffer的长度应不小于GetPropertyItemSize
    procedure GetPropertyItem(propId: PROPID; buffer: PPropertyItem);
    // 获取全部属性项，alItems的长度必须不小于PropertySize
    procedure GetAllPropertyItems(allItems: PPropertyItem);
    // 从Image中移去propID所指的属性项
    procedure RemovePropertyItem(propId: PROPID);
    // 设置属性项
    procedure SetPropertyItem(const item: TPropertyItem);
    // 返回有关指定的图像编码器所支持的参数的信息的长度（字节数）
    function GetEncoderParameterListSize(const clsidEncoder: TCLSID): Integer;
    // 返回有关指定的图像编码器所支持的参数的信息。
    procedure GetEncoderParameterList(const clsidEncoder: TCLSID; size: Integer;
                                      buffer: PEncoderParameters);
    // 返回指定的像素格式的颜色深度（像素的位数）。
    class function GetPixelFormatSize(Format: TPixelFormat): Integer;

    // 获取此 Image 对象的属性标记
    property Flags: TImageFlags read GetFlags;
    // 获取此 Image 对象的高度。
    property Height: Integer read GetHeight;
    // 获取此 Image 对象的水平分辨率（以“像素/英寸”为单位）。
    property HorizontalResolution: Single read GetHorizontalResolution;
    // 获取此图像的宽度和高度。
    property PhysicalDimension: TGpSizeF read GetPhysicalDimension;
    // 获取此 Image 对象的格式。
    property RawFormat: TGUID read GetRawFormat;
    // 获取 Image 对象的类型
    property ImageType: TImageType read GetType;
    // 获取此 Image 对象的垂直分辨率（以“像素/英寸”为单位）。
    property VerticalResolution: Single read GetVerticalResolution;
    // 获取此 Image 对象的宽度。
    property Width: Integer read GetWidth;
    // 获取此 Image 对象的像素格式。
    property PixelFormat: TPixelFormat read GetPixelFormat;
    property FrameDimensionsCount: Integer read GetFrameDimensionsCount;
    // 获取存储于 Image 对象中的属性个数
    property PropertyCount: Integer read GetPropertyCount;
    // 获取存储于 Image 对象中的全部属性项的长度，包括TpropertyItem.value所指的字节数
    property PropertySize: Integer read GetPropertySize;
    // 获取调色板的长度
    property PaletteSize: Integer read GetPaletteSize;
    // 获取或设置用于此 Image 对象的调色板。
    property Palette: PColorPalette read GetPalette write SetPalette;
  end;

  TBitmapData = GdipTypes.TBitmapData;
  PBitmapData = GdipTypes.PBitmapData;
  TImageLockMode = (imRead, imWrite, imUserInputBuf);
  TImageLockModes = set of TImageLockMode;

  TGpBitmap = class(TGpImage)
  private
    function GetPixel(x, y: Integer): TARGB;
    procedure SetPixel(x, y: Integer; const Value: TARGB);
  public
    constructor Create(const filename: WideString;
                       useEmbeddedColorManagement: Boolean = False); overload;
    constructor Create(stream: IStream; useEmbeddedColorManagement: Boolean = False); overload;
    constructor Create(width, height, stride: Integer; // stride 像素数据流中行的内存大小
                       format: TPixelFormat; scan0: Pointer); overload;
    constructor Create(width, height: Integer;
                       format: TPixelFormat = pf32bppARGB); overload;
    constructor Create(width, height: Integer; target: TGpGraphics); overload;
//    constructor Create(surface: GpDirectDrawSurface7); overload;
    constructor Create(const gdiBitmapInfo: TBITMAPINFO; gdiBitmapData: Pointer); overload;
    constructor Create(hbm: HBITMAP; hpal: HPALETTE); overload;
    constructor Create(icon: HICON); overload;
    constructor Create(hInstance: HMODULE; const bitmapName: WideString); overload;

    class function FromFile(const filename: WideString;
                       useEmbeddedColorManagement: Boolean = False): TGpBitmap;
    class function FromStream(stream: IStream;
                       useEmbeddedColorManagement: Boolean = False): TGpBitmap;
    // 由于IDirectDrawSurface7极少用到，这里用GpDirectDrawSurface7=Pointer替代，
    // 避免包含一个庞大的单元。真正用到时，用Pointer强制转换即可
    class function FromDirectDrawSurface7(surface: GpDirectDrawSurface7): TGpBitmap;
    class function FromBITMAPINFO(const gdiBitmapInfo: TBITMAPINFO;
                                  gdiBitmapData: Pointer): TGpBitmap;
    class function FromHBITMAP(hbm: HBITMAP; hpal: HPALETTE): TGpBitmap;
    class function FromHICON(icon: HICON): TGpBitmap;
    class function FromResource(hInstance: HMODULE; const bitmapName: WideString): TGpBitmap;

    function Clone(const rect: TGpRect; format: TPixelFormat): TGpBitmap; reintroduce; overload;
    function Clone(x, y, width, height: Integer; format: TPixelFormat): TGpBitmap; reintroduce; overload;
    function Clone(const rect: TGpRectF; format: TPixelFormat): TGpBitmap; reintroduce; overload;
    function Clone(x, y, width, height: Single; format: TPixelFormat): TGpBitmap; reintroduce; overload;
    // 将 Bitmap 对象锁定到系统内存中。参数 rect: 它指定要锁定的 Bitmap 部分。
    // flags: ImageLockMode 枚举，它指定 Bitmap 对象的访问级别（读和写）。
    // format: Bitmap 对象的数据格式
    function LockBits(const rect: TGpRect; flags: TImageLockModes; format: TPixelFormat): TBitmapData;
    // 从系统内存解锁 Bitmap。
    procedure UnlockBits(var lockedBitmapData: TBitmapData);
    // 设置此 Bitmap 的分辨率。
    procedure SetResolution(xdpi, ydpi: Single);
    // 用此 Bitmap 对象创建并返回 GDI 位图对象。colorBackground指定背景色。
    // 如果位图完全不透明，则忽略此参数。应调用 DeleteObject 释放 GDI 位图对象
    function GetHBITMAP(colorBackground: TARGB): HBITMAP;
    // 返回图标的句柄。
    function GetHICON: HICON;
    // 获取或设置 Bitmap 对象中指定像素的颜色。
    property Pixels[x, y: Integer]: TARGB read GetPixel write SetPixel;
  end;

  TENHMETAHEADER3 = GdipTypes.TENHMETAHEADER3;
  PENHMETAHEADER3 = GdipTypes.PENHMETAHEADER3;
  TWmfPlaceableFileHeader = GdipTypes.TWmfPlaceableFileHeader;
  PWmfPlaceableFileHeader = GdipTypes.PWmfPlaceableFileHeader;
  TMetafileHeader = GdipTypes.TMetafileHeader;

  TEmfType = (etOnly, etPlusOnly, etPlusDual);
  TMetafileFrameUnit = (muPixel = 2, muUnitPoint, muInch, muDocument, muMillimeter, muGdi);
  TEmfToWmfBitsFlag = (ewEmbedEmf, ewIncludePlaceable, ewNoXORClip);
  TEmfToWmfBitsFlags = set of TEmfToWmfBitsFlag;

  TGpMetafile = class(TGpImage)
  public
    // 从指定的句柄和 WmfPlaceableFileHeader 对象初始化 Metafile 类的新实例。
    // deleteWmf: 确定删除 Metafile 对象时是否删除新 Metafile 对象的句柄，
    constructor Create(hWmf: HMETAFILE; wmfPlaceableFileHeader: TWmfPlaceableFileHeader;
                       deleteWmf: Boolean = False); overload;
    // 从指定的增强型图元文件的句柄初始化 Metafile 类的新实例。
    // // deleteEmf: 确定删除 Metafile 对象时是否删除新 Metafile 对象的句柄
    constructor Create(hEmf: HENHMETAFILE; deleteEmf: Boolean = False); overload;
    // 从指定的文件名初始化 Metafile 类的新实例。
    constructor Create(filename: WideString); overload;

    // Playback a WMF metafile from a file.

    constructor Create(filename: WideString;
             wmfPlaceableFileHeader: TWmfPlaceableFileHeader); overload;
    constructor Create(stream: IStream); overload;

    // Record a metafile to memory.

    constructor Create(referenceHdc: HDC; type_: TEmfType = etPlusDual;
                       description: PWChar = nil); overload;

    // Record a metafile to memory.

    constructor Create(referenceHdc: HDC; frameRect: TGpRectF;
                  frameUnit: TMetafileFrameUnit = muGdi;
                  type_: TEmfType = etPlusDual;
                  description: PWChar = nil); overload;

    // Record a metafile to memory.

    constructor Create(referenceHdc: HDC; frameRect: TGpRect;
                  frameUnit: TMetafileFrameUnit = muGdi;
                  type_: TEmfType = etPlusDual;
                  description: PWChar = nil); overload;
    constructor Create(fileName: WideString; referenceHdc: HDC;
                  type_: TEmfType = etPlusDual;
                  description: PWChar = nil); overload;
    constructor Create(fileName: WideString; referenceHdc: HDC; frameRect: TGpRectF;
                       frameUnit: TMetafileFrameUnit = muGdi;
                       type_: TEmfType = etPlusDual;
                       description: PWChar = nil); overload;
    constructor Create(fileName: WideString; referenceHdc: HDC; frameRect: TGpRect;
                       frameUnit: TMetafileFrameUnit = muGdi;
                       type_: TEmfType = etPlusDual;
                       description: PWChar = nil); overload;
    constructor Create(stream: IStream; referenceHdc: HDC;
                  type_: TEmfType = etPlusDual;
                  description: PWChar = nil); overload;
    constructor Create(stream: IStream; referenceHdc: HDC; frameRect: TGpRectF;
                       frameUnit: TMetafileFrameUnit = muGdi;
                       type_: TEmfType = etPlusDual;
                       description: PWChar = nil); overload;
    constructor Create(stream: IStream; referenceHdc: HDC; frameRect: TGpRect;
                       frameUnit: TMetafileFrameUnit = muGdi;
                       type_: TEmfType = etPlusDual;
                       description: PWChar = nil); overload;
    // 获取与此 Metafile 对象关联的 MetafileHeader 对象
    class procedure GetMetafileHeader(hWmf: HMETAFILE;
                       const wmfPlaceableFileHeader: TWmfPlaceableFileHeader; header: TMetafileHeader); overload;
    class procedure GetMetafileHeader(hEmf: HENHMETAFILE; header: TMetafileHeader); overload;
    class procedure GetMetafileHeader(const filename: WideString; header: TMetafileHeader); overload;
    class procedure GetMetafileHeader(stream: IStream; header: TMetafileHeader); overload;
    procedure GetMetafileHeader(header: TMetafileHeader); overload;

    // Once this method is called, the Metafile object is in an invalid state
    // and can no longer be used.  It is the responsiblity of the caller to
    // invoke DeleteEnhMetaFile to delete this hEmf.
    // 返回增强型 Metafile 对象的 Windows 句柄。
    function GetHENHMETAFILE: HENHMETAFILE;
    // 播放单个图元文件记录。
    // recordType:指定正在播放的图元文件记录的类型。flags: 指定记录属性的标志集。
    // dataSize: 记录数据中的字节数。 data: 包含记录数据的字节数组。
    procedure PlayRecord(recordType: TEmfPlusRecordType;
                         flags, dataSize: Integer; const data: PByte);

    // If you're using a printer HDC for the metafile, but you want the
    // metafile rasterized at screen resolution, then use this API to set
    // the rasterization dpi of the metafile to the screen resolution,
    // e.g. 96 dpi or 120 dpi.

    procedure SetDownLevelRasterizationLimit(metafileRasterizationLimitDpi: Integer);
    function GetDownLevelRasterizationLimit: Integer;
    class procedure EmfToWmfBits(hemf: HENHMETAFILE; cbData16: Integer;
                       pData16: PByte; iMapMode: Integer = MM_ANISOTROPIC;
                       eFlags: TEmfToWmfBitsFlags = []);
  end;

  TGpCachedBitmap = class(TGdiplusBase)
  public
    constructor Create(bitmap: TGpBitmap; graphics: TGpGraphics);
    destructor Destroy; override;
  end;

(*******************************************************************************
*   线帽用在直线的起始和结束处，或用在由 GDI+ Pen 对象绘制的曲线处。
*    GDI+ 支持几种预定义的线帽样式，并且还允许用户定义自己的线帽样式。
*   该类用于创建自定义线帽样式。
*******************************************************************************)

  TLineCap = (lcFlat, lcSquare, lcRound, lcTriangle, lcNoAnchor = $10, lcSquareAnchor = $11,
    lcRoundAnchor = $12, lcDiamondAnchor = $13, lcArrowAnchor = $14, lcAnchorMask = $f0, lcCustom = $ff);
  TCustomLineCapType = (ltDefault, ltAdjustableArrow);
  TLineJoin = (ljMiter, ljBevel, ljRound, ljMiterClipped);

  TGpCustomLineCap = class(TGdiplusBase)
  private
    function GetBaseCap: TLineCap;
    procedure SetBaseCap(baseCap: TLineCap);
    function GetBaseInset: Single;
    procedure SetBaseInset(inset: Single);
    function GetStrokeJoin: TLineJoin;
    procedure SetStrokeJoin(lineJoin: TLineJoin);
    function GetWidthScale: Single;
    procedure SetWidthScale(widthScale: Single);
  public
    // 通过指定的轮廓、填充和嵌入从指定的现有 LineCap 枚举初始化 CustomLineCap 类的新实例。
    // fillPath: 自定义线帽填充内容的对象；strokePath: 自定义线帽轮廓的对象。
    // baseCap: 将从其创建自定义线帽的线帽。baseInset: 线帽和直线之间的距离。
    constructor Create(fillPath, strokePath: TGpGraphicsPath;
        baseCap: TLineCap = lcFlat; baseInset: Single = 0);
    destructor Destroy; override;
    function Clone: TGpCustomLineCap;
    // 设置用于构成此自定义线帽的起始直线和结束直线相同的线帽。
    procedure SetStrokeCap(strokeCap: TLineCap);
    // 获取用于构成此自定义线帽的起始直线和结束直线的线帽。
    procedure GetStrokeCaps(var startCap, endCap: TLineCap);
    // 设置用于构成此自定义线帽的起始直线和结束直线的线帽。
    procedure SetStrokeCaps(startCap, endCap: TLineCap);
    // 获取或设置该 CustomLineCap 所基于的 LineCap 枚举。
    property BaseCap: TLineCap read GetBaseCap write SetBaseCap;
    // 获取或设置线帽和直线之间的距离。
    property BaseInset: Single read GetBaseInset write SetBaseInset;
    // 获取或设置 LineJoin 枚举，该枚举确定如何联接构成此 CustomLineCap 对象的直线。
    property StrokeJoin: TLineJoin read GetStrokeJoin write SetStrokeJoin;
    // 获取或设置相对于 Pen 对象的宽度此 CustomLineCap 类对象的缩放量。
    property WidthScale: Single read GetWidthScale write SetWidthScale;
  end;

  TGpAdjustableArrowCap = class(TGpCustomLineCap)
  private
    function GetFillState: Boolean;
    function GetHeight: Single;
    function GetMiddleInset: Single;
    function GetWidth: Single;
    procedure SetFillState(const Value: Boolean);
    procedure SetHeight(const Value: Single);
    procedure SetMiddleInset(const Value: Single);
    procedure SetWidth(const Value: Single);
  public
    // 使用指定的宽度、高度新实例。箭头端帽是否填充取决于传递给 isFilled 参数的参数。
    constructor Create(width, height: Single; isFilled: Boolean = True);
    // 获取或设置箭头帽的高度。
    property Height: Single read GetHeight write SetHeight;
    // 获取或设置箭头帽的宽度。
    property Width: Single read GetWidth write SetWidth;
    // 获取或设置箭头帽的轮廓和填充之间单位的数目。
    property MiddleInset: Single read GetMiddleInset write SetMiddleInset;
    // 获取或设置是否填充箭头帽。
    property Filled: Boolean read GetFillState write SetFillState;
  end;

  TBrushType = (btSolidColor, btHatchFill, btTextureFill, btPathGradient, btLinearGradient);

  // Bursh 的抽象基类
  TGpBrush = class(TGdiplusBase)
  private
    function GetType: TBrushType;
  public
    destructor Destroy; override;
    function Clone: TGpBrush; virtual;
    // 返回Brush类型
    property BrushType: TBrushType read GetType;
  end;

//--------------------------------------------------------------------------
// Solid Fill Brush Object  单色画刷
//--------------------------------------------------------------------------

  TGpSolidBrush  = class(TGpBrush)
  private
    function GetColor: TARGB;
    procedure SetColor(const color: TARGB);
  public
    // 初始化指定颜色的新 SolidBrush 对象。
    constructor Create(color: TARGB);
    // 获取或设置此 SolidBrush 对象的颜色。
    property Color: TARGB read GetColor write SetColor;
  end;

//--------------------------------------------------------------------------
// Texture Brush Fill Object  图像画刷
//--------------------------------------------------------------------------

  TGpTextureBrush = class(TGpBrush)
  private
    procedure SetWrapMode(wrapMode: TWrapMode);
    function GetWrapMode: TWrapMode;
    function GetImage: TGpImage;
  public
    // 初始化使用指定的图像和自动换行模式的新 TextureBrush 对象。
    constructor Create(image: TGpImage; wrapMode:
                       TWrapMode = wmTile); overload;
    // 初始化使用指定图像、自动换行模式和尺寸建立新 TextureBrush 对象。
    constructor Create(image: TGpImage; wrapMode: TWrapMode; dstRect: TGpRectF); overload;
    constructor Create(image: TGpImage; wrapMode: TWrapMode; dstRect: TGpRect); overload;
    constructor Create(image: TGpImage; wrapMode: TWrapMode;
                       dstX, dstY, dstWidth, dstHeight: Single); overload;
    constructor Create(image: TGpImage; wrapMode: TWrapMode;
                       dstX, dstY, dstWidth, dstHeight: Integer); overload;
    // 初始化使用指定的图像、矩形尺寸和图像属性的新 TextureBrush 对象。
    constructor Create(image: TGpImage; dstRect: TGpRectF;
                       imageAttributes: TGpImageAttributes = nil); overload;
    constructor Create(image: TGpImage; dstRect: TGpRect;
                       imageAttributes: TGpImageAttributes = nil); overload;

    // 获取或设置 Matrix 对象，它为与此 TextureBrush 对象关联的图像定义局部几何变换。
    procedure GetTransform(matrix: TGpMatrix);
    procedure SetTransform(const matrix: TGpMatrix);
    // 将此 TextureBrush 对象的 Transform 属性重置为单位矩阵。
    procedure ResetTransform;
    // 以指定顺序将表示 TextureBrush 对象的局部几何变换的 Matrix 对象乘以指定的 Matrix 对象。
    procedure MultiplyTransform(matrix: TGpMatrix; order: TMatrixOrder  = moPrepend);
    // 以指定顺序将此 TextureBrush 对象的局部几何变换平移指定的尺寸。
    procedure TranslateTransform(dx, dy: Single; order: TMatrixOrder = moPrepend);
    // 以指定顺序将此 TextureBrush 对象的局部几何变换缩放指定的量。
    procedure ScaleTransform(sx, sy: Single; order: TMatrixOrder = moPrepend);
    // 将此 TextureBrush 对象的局部几何变换旋转指定的角度。
    procedure RotateTransform(angle: Single; order: TMatrixOrder = moPrepend);

    // 获取与此 TextureBrush 对象关联的 Image 对象。必须Free
    property Image: TGpImage read GetImage;
    // 获取或设置 WrapMode 枚举，它指示此 TextureBrush 对象的换行模式
    property WrapMode: TWrapMode read GetWrapMode write SetWrapMode;
  end;

//--------------------------------------------------------------------------
// 该类封装双色渐变和自定义多色渐变。
// 所有渐变都是沿由矩形的宽度或两个点指定的直线定义的。
// 默认情况下，双色渐变是沿指定直线从起始色到结束色的均匀水平线性混合。
// 使用 Blend 类、SetSigmaBellShape 方法或 SetBlendTriangularShape 方法
// 自定义混合图案。通过在构造函数中指定 LinearGradientMode 枚举或角度自定义渐变的方向。
// 使用 InterpolationColors 属性创建多色渐变。
// Transform 属性指定应用到渐变的局部几何变形。
//--------------------------------------------------------------------------

  TLinearGradientMode = (
    lmHorizontal,         // 指定从左到右的渐变。
    lmVertical,           // 指定从上到下的渐变。
    lmForwardDiagonal,    // 指定从左上到右下的渐变。
    lmBackwardDiagonal    // 指定从右上到左下的渐变。
  );

  TGpLinearGradientBrush = class(TGpBrush)
  private
    function GetWrapMode: TWrapMode;
    procedure SetWrapMode(wrapMode: TWrapMode);
    procedure SetGammaCorrection(useGammaCorrection: Boolean);
    function GetGammaCorrection: Boolean;
    function GetBlendCount: Integer;
    function GetInterpolationColorCount: Integer;
    function GetRectangleF: TGpRectF;
    function GetRectangle: TGpRect;
  public
    // 使用指定的点和颜色初始化 LinearGradientBrush 类的新实例。
    constructor Create(point1, point2: TGpPointF; color1, color2: TARGB); overload;
    constructor Create(point1, point2: TGpPoint; color1, color2: TARGB); overload;
    // 根据一个矩形、起始颜色和结束颜色以及方向，创建 LinearGradientBrush 类的新实例。
    constructor Create(rect: TGpRectF; color1, color2: TARGB;
                  mode: TLinearGradientMode = lmHorizontal); overload;
    constructor Create(rect: TGpRect; color1, color2: TARGB;
                  mode: TLinearGradientMode = lmHorizontal); overload;
    // 根据矩形、起始颜色和结束颜色以及方向角度，创建 LinearGradientBrush 类的新实例。
    // isAngleScalable:指定角度是否受 LinearGradientBrush 关联的变形所影响
    constructor Create(rect: TGpRectF; color1, color2: TARGB;
                       angle: Single; isAngleScalable: Boolean = False); overload;
    constructor Create(rect: TGpRect; color1, color2: TARGB;
                       angle: Single; isAngleScalable: Boolean = False); overload;
    // 获取或设置渐变的起始色和结束色。
    procedure GetLinearColors(var color1, color2: TARGB);
    procedure SetLinearColors(color1, color2: TARGB);
    // 获取或设置 Blend，它指定为渐变定义自定义过渡的位置和因子。对双色渐变有效
    // blendFactors：用于渐变的混合因子数组，混合因子表示相应位置结束色占起始色的比率。
    // blendPositions：渐变的混合位置的数组，这些位置是介于 0 到 1 之间的值，
    // 最左边必须为0，最右边必须为1
    procedure SetBlend(const blendFactors, blendPositions: array of Single);
    function GetBlend(var blendFactors, blendPositions: array of Single): Integer;
    // 获取或设置一个定义多色线性渐变的 ColorBlend。
    // presetColors:沿渐变的相应位置处使用的颜色的颜色数组。
    // blendPositions:沿渐变线的位置，这些位置是介于 0 到 1 之间的值，
    // 最左边必须为0，最右边必须为1
    procedure SetInterpolationColors(const presetColors: array of TARGB;
                                     const blendPositions: array of Single);
    function GetInterpolationColors(var presetColors: array of TARGB;
                                    var blendPositions: array of Single): Integer;
    // 创建基于钟形曲线的渐变过渡过程。
    // focus: 0 - 1，指定渐变中心（渐变中只由结束色构成的点）。
    // scale: 0 - 1, 指定颜色从 focus 过渡的规模(程度)。
    procedure SetBlendBellShape(focus: Single; scale: Single = 1.0);
    // 创建一个从中心色向两端单个颜色线性过渡的线性渐变过程。
    procedure SetBlendTriangularShape(focus: Single; scale: Single = 1.0);
    // 获取或设置一个 Matrix 对象，该对象为此 LinearGradientBrush 对象定义局部几何变形。
    procedure SetTransform(const matrix: TGpMatrix);
    procedure GetTransform(matrix: TGpMatrix);
    // 将 Transform 属性重置为相同。
    procedure ResetTransform;
    // 通过指定的 Matrix，将LinearGradientBrush 的局部几何变形的 Matrix 对象与该指定的 Matrix 相乘。
    procedure MultiplyTransform(const matrix: TGpMatrix; order: TMatrixOrder = moPrepend);
    // 将局部几何变形转换指定的尺寸。该方法将预先计算对变形的转换。
    procedure TranslateTransform(dx, dy: Single; order: TMatrixOrder = moPrepend);
    // 将局部几何变形缩放指定数量。该方法预先计算对变形的缩放矩阵。
    procedure ScaleTransform(sx, sy: Single; order: TMatrixOrder = moPrepend);
    // 将局部几何变形旋转指定大小。该方法预先计算对变形的旋转。
    procedure RotateTransform(angle: Single; order: TMatrixOrder = moPrepend);
    // 获取定义渐变的起始点和终结点的矩形区域。
    property RectangleF: TGpRectF read GetRectangleF;
    property Rectangle: TGpRect read GetRectangle;
    // 获取或设置 WrapMode 枚举，它指示该 LinearGradientBrush 的环绕模式。
    property WrapMode: TWrapMode read GetWrapMode write SetWrapMode;
    // 获取或设置一个值，该值指示是否为该 LinearGradientBrush 对象启用伽玛修正。
    property GammaCorrection: Boolean read GetGammaCorrection write SetGammaCorrection;
    property BlendCount: Integer read GetBlendCount;
    property InterpolationColorCount: Integer read GetInterpolationColorCount;
  end;

//--------------------------------------------------------------------------
// Hatch Brush Object 用阴影样式、前景色和背景色定义矩形画笔。
//--------------------------------------------------------------------------

  THatchStyle = (hsHorizontal, hsVertical, hsForwardDiagonal, hsBackwardDiagonal,
    hsCross, hsDiagonalCross, hs05Percent, hs10Percent, hs20Percent, hs25Percent,
    hs30Percent, hs40Percent, hs50Percent, hs60Percent, hs70Percent, hs75Percent,
    hs80Percent, hs90Percent, hsLightDownwardDiagonal, hsLightUpwardDiagonal,
    hsDarkDownwardDiagonal, hsDarkUpwardDiagonal, hsWideDownwardDiagonal,
    hsWideUpwardDiagonal, hsLightVertical, hsLightHorizontal, hsNarrowVertical,
    hsNarrowHorizontal, hsDarkVertical, hsDarkHorizontal, hsDashedDownwardDiagonal,
    hsDashedUpwardDiagonal, hsDashedHorizontal, hsDashedVertical, hsSmallConfetti,
    hsLargeConfetti, hsZigZag, hsWave, hsDiagonalBrick, hsHorizontalBrick,
    hsWeave, hsPlaid, hsDivot, hsDottedGrid, hsDottedDiamond, hsShingle,                      
    hsTrellis, hsSphere, hsSmallGrid, hsSmallCheckerBoard, hsLargeCheckerBoard,
    hsOutlinedDiamond, hsSolidDiamond);

  TGpHatchBrush = class(TGpBrush)
  private
    function GetBackgroundColor: TARGB;
    function GetForegroundColor: TARGB;
    function GetHatchStyle: THatchStyle;
  public
    // 使用指定的 HatchStyle 枚举、前景色和背景色初始化 HatchBrush 类的新实例。
    constructor Create(hatchStyle: THatchStyle; foreColor: TARGB; backColor: TARGB = kcBlack);
    // 获取此 HatchBrush 对象绘制的阴影线条的颜色。
    property ForegroundColor: TARGB read GetForegroundColor;
    // 获取此 HatchBrush 对象绘制的阴影线条间空间的颜色
    property BackgroundColor: TARGB read GetBackgroundColor;
    // 获取此 HatchBrush 对象的阴影样式。
    property HatchStyle: THatchStyle read GetHatchStyle;
  end;

//--------------------------------------------------------------------------
// Path Gradient Brush 通过渐变填充 GraphicsPath 对象的内部
//--------------------------------------------------------------------------

  TGpPathGradientBrush = class(TGpBrush)
  private
    function GetCenterColor: TARGB;
    procedure SetCenterColor(const color: TARGB);
    function GetPointCount: Integer;
    function GetSurroundColorCount: Integer;
    procedure SetGammaCorrection(useGammaCorrection: Boolean);
    function GetGammaCorrection: Boolean;
    function GetBlendCount: Integer;
    function GetWrapMode: TWrapMode;
    procedure SetWrapMode(wrapMode: TWrapMode);
    function GetCenterPoint: TGpPointF;
    function GetCenterPointI: TGpPoint;
    function GetRectangle: TGpRectF;
    function GetRectangleI: TGpRect;
    procedure SetCenterPoint(const Value: TGpPointF);
    procedure SetCenterPointI(const Value: TGpPoint);
    function GetFocusScales: TGpPointF;
    procedure SetFocusScales(const Value: TGpPointF);
    function GetInterpolationColorCount: Integer;
  public
    // 使用指定的点和环绕模式初始化 PathGradientBrush 类的新实例。
    constructor Create(points: array of TGpPointF;
                       wrapMode: TWrapMode  = wmClamp); overload;
    constructor Create(points: array of TGpPoint;
                       wrapMode: TWrapMode  = wmClamp); overload;
    // 使用指定的路径初始化 PathGradientBrush 类的新实例。
    constructor Create(path: TGpGraphicsPath); overload;
    // 获取或设置与此 PathGradientBrush 对象填充的路径中的点相对应的颜色的数组。
    // 返回实际获取或设置的数组元素个数
    function GetSurroundColors(var colors: array of TARGB): Integer;
    procedure SetSurroundColors(colors: array of TARGB);
    // 获取或设置 Blend，它指定为渐变定义自定义过渡的位置和因子。
    function GetBlend(var blendFactors, blendPositions: array of Single): Integer;
    procedure SetBlend(blendFactors, blendPositions: array of Single);
    // 获取或设置一个定义多色线性渐变的 ColorBlend 对象。
    procedure SetInterpolationColors(presetColors: array of TARGB;
                                     blendPositions: array of Single);
    function GetInterpolationColors(var presetColors: array of TARGB;
                                    var blendPositions: array of Single): Integer;
    // 创建基于钟形曲线的渐变过渡过程。
    procedure SetBlendBellShape(focus: Single; scale: Single = 1.0);
    // 创建一个从中心色向周围色线性过渡的渐变过程。
    // focus: 介于 0 和 1 之间的一个值，它指定沿路径中心到路径边界的任意半径向上中心色亮度最高的位置。
    // scale: 介于 0 和 1 之间的一个值，它指定与边界色混合的中心色的最高亮度。
    procedure SetBlendTriangularShape(focus: Single; scale: Single = 1.0);
    // 获取或设置一个 Matrix 对象，该对象为此 PathGradientBrush 对象定义局部几何变形。
    procedure GetTransform(matrix: TGpMatrix);
    procedure SetTransform(const matrix: TGpMatrix);
    // 将 Transform 属性重置为相同。
    procedure ResetTransform;
    // 通过指定的 Matrix，将PathGradientBrush的局部几何变形的 Matrix 对象与该指定的 Matrix 相乘。
    procedure MultiplyTransform(const matrix: TGpMatrix; order: TMatrixOrder  = moPrepend);
    // 按指定的顺序向局部几何变形应用指定的转换。
    procedure TranslateTransform(dx, dy: Single; order: TMatrixOrder = moPrepend);
    // 将局部几何变形以指定顺序缩放指定数量。
    procedure ScaleTransform(sx, sy: Single; order: TMatrixOrder = moPrepend);
    // 以指定顺序将局部几何变形旋转指定量。
    procedure RotateTransform(angle: Single; order: TMatrixOrder = moPrepend);

    procedure GetGraphicsPath(path: TGpGraphicsPath);
    procedure SetGraphicsPath(const path: TGpGraphicsPath);
    // 获取此 PathGradientBrush 对象的边框。
    property Rectangle: TGpRectF read GetRectangle;
    property RectangleI: TGpRect read GetRectangleI;
    // 获取或设置一个 WrapMode 枚举，它指示此 PathGradientBrush 对象的环绕模式。
    property WrapMode: TWrapMode read GetWrapMode write SetWrapMode;
    property GammaCorrection: Boolean read GetGammaCorrection write SetGammaCorrection;
    property BlendCount: Integer read GetBlendCount;
    property PointCount: Integer read GetPointCount;
    property SurroundColorCount: Integer read GetSurroundColorCount;
    // 获取或设置路径渐变的中心处的颜色。
    property CenterColor: TARGB read GetCenterColor write SetCenterColor;
    // 获取或设置路径渐变的中心点。
    property CenterPoint: TGpPointF read GetCenterPoint write SetCenterPoint;
    property CenterPointI: TGpPoint read GetCenterPointI write SetCenterPointI;
    // 获取或设置渐变过渡的焦点。
    property FocusScales: TGpPointF read GetFocusScales write SetFocusScales;
    property InterpolationColorCount: Integer read GetInterpolationColorCount;
  end;

//--------------------------------------------------------------------------
// Pen class
//--------------------------------------------------------------------------

  TPenAlignment = (paCenter, paInset);
  TDashCap = (dcFlat, dcRound = 2, dcTriangle);
  TDashStyle = (dsSolid, dsDash, dsDot, dsDashDot, dsDashDotDot, dsCustom);
  TPenType = (ptSolidColor, ptHatchFill, ptTextureFill, ptPathGradient, ptLinearGradient);

  TGpPen = class(TGdiplusBase)
  private
    function GetBrush: TGpBrush;
    procedure SetBrush(const brush: TGpBrush);
    function GetAlignment: TPenAlignment;
    procedure SetAlignment(penAlignment: TPenAlignment);
    function GetColor: TARGB;
    procedure SetColor(const color: TARGB);
    function GetDashCap: TDashCap;
    function GetDashOffset: Single;
    function GetDashStyle: TDashStyle;
    function GetEndCap: TLineCap;
    function GetLineJoin: TLineJoin;
    function GetMiterLimit: Single;
    function GetPenType: TPenType;
    function GetStartCap: TLineCap;
    function GetWidth: Single;
    procedure SetDashCap(dashCap: TDashCap);
    procedure SetDashOffset(dashOffset: Single);
    procedure SetDashStyle(dashStyle: TDashStyle);
    procedure SetEndCap(endCap: TLineCap);
    procedure SetLineJoin(lineJoin: TLineJoin);
    procedure SetMiterLimit(miterLimit: Single);
    procedure SetStartCap(startCap: TLineCap);
    procedure SetWidth(width: Single);
    function GetDashPatternCount: Integer;
    function GetCompoundArrayCount: Integer;
  public
    constructor Create(const color: TARGB; width: Single = 1.0); overload;
    constructor Create(brush: TGpBrush; width: Single = 1.0); overload;
    destructor Destroy; override;
    function Clone: TGpPen;
    // 设置用于确定帽样式的值，此样式用于结束通过此 Pen 对象绘制的直线。
    procedure SetLineCap(startCap, endCap: TLineCap; dashCap: TDashCap);
    // 获取或设置在通过此 Pen 对象绘制的直线起点要使用的自定义帽。
    procedure SetCustomStartCap(const customCap: TGpCustomLineCap);
    procedure GetCustomStartCap(customCap: TGpCustomLineCap);
    // 获取或设置在通过此 Pen 对象绘制的直线终点要使用的自定义帽。
    procedure SetCustomEndCap(const customCap: TGpCustomLineCap);
    procedure GetCustomEndCap(customCap: TGpCustomLineCap);
    // 获取或设置此 Pen 对象的几何变换。
    procedure SetTransform(const matrix: TGpMatrix);
    procedure GetTransform(matrix: TGpMatrix);
    // 将此 Pen 对象的几何变换矩阵重置为单位矩阵。
    procedure ResetTransform;
    // 用指定的 Matrix 乘以此 Pen 对象的变换矩阵。
    procedure MultiplyTransform(const matrix: TGpMatrix; order: TMatrixOrder = moPrepend);
    // 将局部几何变换平移指定尺寸。
    procedure TranslateTransform(dx, dy: Single; order: TMatrixOrder = moPrepend);
    // 将局部几何变换缩放指定的量。
    procedure ScaleTransform(sx, sy: Single; order: TMatrixOrder = moPrepend);
    // 将局部几何变换旋转指定角度。
    procedure RotateTransform(angle: Single; order: TMatrixOrder = moPrepend);
    // 获取或设置自定义的短划线和空白区域的数组。
    procedure SetDashPattern(const dashArray: array of Single);
    function GetDashPattern(var dashArray: array of Single): Integer;
    // 获取或设置用于指定复合钢笔的数组值。复合钢笔绘制由平行直线和空白区域组成的复合直线。
    // compoundArray用于指定复合数组的实数组。该数组中的元素必须按升序排列，不能小于 0，也不能大于 1。
    procedure SetCompoundArray(compoundArray: array of Single);
    function GetCompoundArray(var compoundArray: array of Single): Integer;

    property CompoundArrayCount: Integer read GetCompoundArrayCount;
    property DashPatternCount: Integer read GetDashPatternCount;
    // 获取用此 Pen 对象绘制的直线的样式。
    property PenType: TPenType read GetPenType;
    // 获取或设置用在短划线终点的帽样式，这些短划线构成通过此 Pen 对象绘制的虚线。
    // 如果 Pen 对象的 Pen.Alignment 属性设置为 PenAlignment.Inset，
    // 则不要将此属性设置为 DashCapTriangle。
    property DashCap: TDashCap read GetDashCap write SetDashCap;
    // 获取或设置用于通过此 Pen 对象绘制的虚线的样式。
    property DashStyle: TDashStyle read GetDashStyle write SetDashStyle;
    // 获取或设置直线的起点到短划线图案起始处的距离。
    property DashOffset: Single read GetDashOffset write SetDashOffset;
    // 获取或设置用在通过此 Pen 对象绘制的直线起点或终点的帽样式。
    property StartCap: TLineCap read GetStartCap write SetStartCap;
    property EndCap: TLineCap read GetEndCap write SetEndCap;
    // 获取或设置通过此 Pen 对象绘制的两条连续直线终点之间的联接样式。
    property LineJoin: TLineJoin read GetLineJoin write SetLineJoin;
    // 获取或设置斜接角上联接宽度的限制。
    property MiterLimit: Single read GetMiterLimit write SetMiterLimit;
    property Width: Single read GetWidth write SetWidth;
    // 获取或设置用于确定此 Pen 对象的属性的 Brush 对象。返回的TBrush必须释放
    property Brush: TGpBrush read GetBrush write SetBrush;
    // 获取或设置此 Pen 对象的对齐方式。
    property Alignment: TPenAlignment read GetAlignment write SetAlignment;
    property Color: TARGB read GetColor write SetColor;
  end;

  TStringDigitSubstitute = (ssUser, ssNone, ssNational, ssTraditional);
  TStringAlignment = (saNear, saCenter, saFar);
  THotkeyPrefix = (hpNone, hpShow, hpHide);

  TStringFormatFlag = (sfDirectionRightToLeft, sfDirectionVertical, sfNoFitBlackBox,
    sfDisplayFormatControl = 5, sfNoFontFallback = 10, sfMeasureTrailingSpaces,
    sfNoWrap, sfLineLimit, sfNoClip);
  TStringFormatFlags = set of TStringFormatFlag;
  TStringTrimming  = (stNone, stCharacter, stWord, stEllipsisCharacter,
    stEllipsisWord, stEllipsisPath);

  TCharacterRange = GdipTypes.TCharacterRange;

  TGpStringFormat = class(TGdiplusBase)
  private
    function GetTabStopCount: Integer;
    function GetDigitSubstitutionLanguage: LANGID;
    function GetDigitSubstitutionMethod: TStringDigitSubstitute;
    function GetMeasurableCharacterRangeCount: Integer;
    function GetAlignment: TStringAlignment;
    function GetFormatFlags: TStringFormatFlags;
    function GetHotkeyPrefix: THotkeyPrefix;
    function GetLineAlignment: TStringAlignment;
    function GetTrimming: TStringTrimming;
    procedure SetAlignment(align: TStringAlignment);
    procedure SetFormatFlags(flags: TStringFormatFlags);
    procedure SetHotkeyPrefix(hotkeyPrefix: THotkeyPrefix);
    procedure SetLineAlignment(align: TStringAlignment);
    procedure SetTrimming(trimming: TStringTrimming);
  public
    // 用指定的 StringFormatFlags 枚举和语言初始化新的 StringFormat 对象。
    constructor Create(formatFlags: TStringFormatFlags = []; language: LANGID = LANG_NEUTRAL); overload;
    // 从指定的现有 StringFormat 对象初始化新 StringFormat 对象
    constructor Create(format: TGpStringFormat); overload;
    // 获取一般的默认 StringFormat 对象。
    class function GenericDefault: TGpStringFormat;
    // 获取一般的版式 StringFormat 对象。
    class function GenericTypographic: TGpStringFormat;
    function Clone: TGpStringFormat;
    destructor Destroy; override;
    // 获取或设置制表位。firstTabOffset: 文本行开头和第一个制表位之间的空格数。
    // tabStops: 制表位之间的距离（以空格数表示）的数组
    procedure SetTabStops(firstTabOffset: Single; tabStops: array of Single);
    function GetTabStops(var firstTabOffset: Single; var tabStops: array of Single): Integer;
    // 指定用本地数字替换西方数字时使用的语言和方法。
    procedure SetDigitSubstitution(language: LANGID; substitute: TStringDigitSubstitute);
    // 指定 CharacterRange 结构的数组，这些结构表示通过调用 Graphics.MeasureCharacterRanges
    // 方法来测定的字符的范围。
    procedure SetMeasurableCharacterRanges(const ranges: array of TCharacterRange);

    property TabStopCount: Integer read GetTabStopCount;
    // 获取用本地数字替换西方数字时使用的语言。
    property DigitSubstitutionLanguage: LANGID read GetDigitSubstitutionLanguage;
    // 获取要用于数字替换的方法。
    property DigitSubstitutionMethod: TStringDigitSubstitute read GetDigitSubstitutionMethod;
    property MeasurableCharacterRangeCount: Integer read GetMeasurableCharacterRangeCount;
    // 获取或设置文本对齐方式的信息。
    property Alignment: TStringAlignment read GetAlignment write SetAlignment;
    // 获取或设置包含格式化信息的 StringFormatFlags 枚举。
    property FormatFlags: TStringFormatFlags read GetFormatFlags write SetFormatFlags;
    // 获取或设置此 StringFormat 对象的 HotkeyPrefix 对象
    property HotkeyPrefix: THotkeyPrefix read GetHotkeyPrefix write SetHotkeyPrefix;
    // 获取或设置行的对齐方式
    property LineAlignment: TStringAlignment read GetLineAlignment write SetLineAlignment;
    // 获取或设置绘制的文本超出布局矩形的边缘时被剪裁的方式
    property Trimming: TStringTrimming read GetTrimming write SetTrimming;
  end;
  // 缺省（空）为psStart
  TPathPointType  = ({ptStart, }ptLine, ptBezier, ptTypeMask, ptDashMode = 4, ptPathMarker, ptCloseSubpath = 7, ptBezier3 = ptBezier);
  TPathPointTypes = set of TPathPointType;
  PPathPointTypes = ^TPathPointTypes;
  TWarpMode = (wmPerspective, wmBilinear);

  TPathData = packed record
    Count: Integer;
    Points: array of TGpPointF;
    Types: array of TPathPointTypes;
  end;

  TGpGraphicsPath = class(TGdiplusBase)
  private
    function GetFillMode: Vcl.Graphics.TFillMode;
    procedure SetFillMode(fillMode: Vcl.Graphics.TFillMode);
    function GetLastPoint: TGpPointF;
    function GetPointCount: Integer;
    function GetPathData: TPathData;
  public
    constructor Create(fillMode: Vcl.Graphics.TFillMode = fmAlternate); overload;
    constructor Create(points: array of TGpPointF; types: array of TPathPointTypes;
                           fillMode: Vcl.Graphics.TFillMode  = fmAlternate); overload;
    constructor Create(points: array of TGpPoint; types: array of TPathPointTypes;
                           fillMode: Vcl.Graphics.TFillMode  = fmAlternate); overload;

    destructor Destroy; override;
    function Clone: TGpGraphicsPath;
    // 向此 GraphicsPath 对象追加一条线段。
    procedure AddLine(const pt1, pt2: TGpPointF); overload;
    procedure AddLine(x1, y1, x2, y2: Single); overload;
    procedure AddLine(const pt1, pt2: TGpPoint); overload;
    procedure AddLine(x1, y1, x2, y2: Integer); overload;
    // 向此 GraphicsPath 对象末尾追加一系列相互连接的线段。
    procedure AddLines(const points: array of TGpPointF); overload;
    procedure AddLines(const points: array of TGpPoint); overload;
    // 向当前图形追加一段椭圆弧。
    procedure AddArc(const rect: TGpRectF; startAngle, sweepAngle: Single); overload;
    procedure AddArc(x, y, width, height, startAngle, sweepAngle: Single); overload;
    procedure AddArc(const rect: TGpRect; startAngle, sweepAngle: Single); overload;
    procedure AddArc(x, y, width, height: Integer; startAngle, sweepAngle: Single); overload;
    // 在当前图形中添加一段立方贝塞尔曲线。
    procedure AddBezier(const pt1, pt2, pt3, pt4: TGpPointF); overload;
    procedure AddBezier(x1, y1, x2, y2, x3, y3, x4, y4: Single); overload;
    procedure AddBezier(const pt1, pt2, pt3, pt4: TGpPoint); overload;
    procedure AddBezier(x1, y1, x2, y2, x3, y3, x4, y4: Integer); overload;
    // 在当前图形中添加一系列相互连接的立方贝塞尔曲线。
    procedure AddBeziers(const points: array of TGpPointF); overload;
    procedure AddBeziers(const points: array of TGpPoint); overload;
    // 向当前图形添加一段样条曲线。由于曲线经过数组中的每个点，因此使用基数样条曲线。
    procedure AddCurve(const points: array of TGpPointF); overload;
    procedure AddCurve(const points: array of TGpPointF; tension: Single); overload;
    procedure AddCurve(const points: array of TGpPointF;
                       offset, numberOfSegments: Integer; tension: Single); overload;
    procedure AddCurve(const points: array of TGpPoint); overload;
    procedure AddCurve(const points: array of TGpPoint; tension: Single); overload;
    procedure AddCurve(const points: array of TGpPoint;
                       offset, numberOfSegments: Integer; tension: Single); overload;
    // 向此路径添加一个闭合曲线。由于曲线经过数组中的每个点，因此使用基数样条曲线。
    procedure AddClosedCurve(const points: array of TGpPointF); overload;
    procedure AddClosedCurve(const points: array of TGpPointF; tension: Single); overload;
    procedure AddClosedCurve(const points: array of TGpPoint); overload;
    procedure AddClosedCurve(const points: array of TGpPoint; tension: Single); overload;
    // 向此路径添加一个矩形。
    procedure AddRectangle(const rect: TGpRectF); overload;
    procedure AddRectangle(x, y, Width, Height: Single); overload;
    procedure AddRectangle(const rect: TGpRect); overload;
    procedure AddRectangle(x, y, Width, Height: Integer); overload;
    // 向此路径添加一系列矩形。
    procedure AddRectangles(const rects: array of TGpRectF); overload;
    procedure AddRectangles(const rects: array of TGpRect); overload;
    // 向当前路径添加一个椭圆。
    procedure AddEllipse(const rect: TGpRectF); overload;
    procedure AddEllipse(x, y, Width, Height: Single); overload;
    procedure AddEllipse(const rect: TGpRect); overload;
    procedure AddEllipse(x, y, Width, Height: Integer); overload;
    // 向此路径添加一个扇形轮廓。
    procedure AddPie(const rect: TGpRectF; startAngle, sweepAngle: Single); overload;
    procedure AddPie(x, y, Width, Height, startAngle, sweepAngle: Single); overload;
    procedure AddPie(const rect: TGpRect; startAngle, sweepAngle: Single); overload;
    procedure AddPie(x, y, Width, Height: Integer; startAngle, sweepAngle: Single); overload;
    // 向此路径添加多边形。
    procedure AddPolygon(const points: array of TGpPointF); overload;
    procedure AddPolygon(const points: array of TGpPoint); overload;
    // 将指定的 GraphicsPath 对象追加到该路径。
    procedure AddPath(const addingPath: TGpGraphicsPath; connect: Boolean);
    // 向此路径添加文本字符串。
    procedure AddString(const str: WideString; const family: TGpFontFamily;
                        style: TFontStyles; emSize: Single;  // World units
                        const origin: TGpPointF; const format: TGpStringFormat); overload;
    procedure AddString(const str: WideString; const family: TGpFontFamily;
                        style: TFontStyles; emSize: Single;  // World units
                        const layoutRect: TGpRectF; const format: TGpStringFormat); overload;
    procedure AddString(const str: WideString; const family: TGpFontFamily;
                        style: TFontStyles; emSize: Single;  // World units
                        const origin: TGpPoint; const format: TGpStringFormat); overload;
    procedure AddString(const str: WideString; const family: TGpFontFamily;
                        style: TFontStyles; emSize: Single;  // World units
                        const layoutRect: TGpRect; const format: TGpStringFormat); overload;

    // 清空 PathPoints 和 PathTypes 数组并将 FillMode 设置为 Alternate。
    procedure Reset;
    // 开始一个子路经(新图形，与前面图形点断开(如有))。后面添加到路径的所有点都包括在此子路经中。
    // 子路径使您可以将一个路径分成几个部分并使用 TGraphicsPathIterator类来循环访问这些子路径。
    procedure StartFigure;
    // 与StartFigure对应，闭合当前子路经图形并开始新的图形，与后面添加到路径的所有点断开。
    procedure CloseFigure;
    // 闭合此路径中所有开放的图形并开始一个新图形。即调用多次StartFigure后，一次性闭合
    procedure CloseAllFigures;
    // 在此 GraphicsPath 对象上设置标记。用来分隔各组子路径。在路径的两个标记间可含有一个或多个子路径。
    procedure SetMarker;
    // 清除此路径的所有标记。
    procedure ClearMarkers;
    // 反转此 GraphicsPath 对象的 PathPoints 数组中各点的顺序。
    procedure Reverse;
    // 将变形矩阵应用到此 GraphicsPath 对象。
    procedure Transform(const matrix: TGpMatrix);

    // 返回由指定的 Matrix 对象对当前路径进行变形并且用指定的 Pen 对象绘制该路径时，
    // 限定此 GraphicsPath 对象的矩形
    procedure GetBounds(var bounds: TGpRectF; const matrix: TGpMatrix  = nil;
                        const pen: TGpPen = nil); overload;
    procedure GetBounds(var bounds: TGpRect; const matrix: TGpMatrix  = nil;
                        const pen: TGpPen = nil); overload;
    // 将此 GraphicsPath 对象中的各段曲线转换成相连的线段序列。
    // 参数 matrix在展平前对 GraphicsPath 进行变形的 Matrix 对象。
    // flatness 曲线和其展平的近似直线之间的最大允许误差。
    // 值 0.25 是默认值。降低该展平值将增加近似直线中线段的数目。
    procedure Flatten(const matrix: TGpMatrix = nil; flatness: Single = FlatnessDefault);
    // 在用指定的画笔绘制此路径时，用包含所填充区域的曲线代替此 GraphicsPath 对象。
    // 此方法围绕此 GraphicsPath 对象内的原始线条创建一个轮廓，
    // 已有线条和新轮廓间的距离等于调用 Widen 时所用 Pen 对象的宽度。
    // 如果希望填充线条之间的空间，必须使用 FillPath 对象而不是 DrawPath 对象。
    // pen:指定路径原始轮廓和此方法创建的新轮廓之间的宽度。
    // matrix:指定扩展前应用于路径的变形。flatness: 指定曲线展平的值
    procedure Widen(const pen: TGpPen; const matrix: TGpMatrix = nil;
                    flatness: Single = FlatnessDefault);
    //
    procedure Outline(const matrix: TGpMatrix = nil; flatness: Single = FlatnessDefault);
    // 对此 GraphicsPath 对象应用由一个矩形和一个平行四边形定义的扭曲变形。
    // destPoints:它们定义由 srcRect 定义的矩形将变形到的平行四边形。
    // 该数组可以包含三个或四个元素。如果包含三个元素，则平行四边形右下角位置的点从前三个点导出。
    // srcRect:它表示将变形为 destPoints 定义的平行四边形的矩形。
    // matrix: 指定将应用于路径的几何变形的 Matrix 对象。
    // warpMode: 指定此扭曲操作是使用透视模式还是双线性模式。
    // flatness: 介于 0 到 1 之间的值，它指定如何展平最终路径。有关更多信息，请参见 Flatten 方法。
    procedure Warp(const destPoints: array of TGpPointF;
                  const srcRect: TGpRectF; const matrix: TGpMatrix = nil;
                  warpMode: TWarpMode  = wmPerspective;
                  flatness: Single = FlatnessDefault);
    procedure GetPathPoints(var points: array of TGpPoint); overload;
    procedure GetPathPoints(var points: array of TGpPointF); overload;
    procedure GetPathTypes(var types: array of TPathPointTypes);
    // 测试指定点是否包含在此 GraphicsPath 对象内。
    function IsVisible(const point: TGpPointF; const g: TGpGraphics = nil): Boolean; overload;
    function IsVisible(x, y: Single; const g: TGpGraphics = nil): Boolean; overload;
    function IsVisible(const point: TGpPoint;
                       const g: TGpGraphics = nil): Boolean; overload;
    function IsVisible(x, y: Integer; const g: TGpGraphics = nil): Boolean; overload;
    // 测试当使用指定的 Pen 对象和 Graphics 对象绘制 GraphicsPath 对象时，
    // 指定坐标点是否包含在路经的轮廓内
    function IsOutlineVisible(const point: TGpPointF; const pen: TGpPen;
                              const g: TGpGraphics = nil): Boolean; overload;
    function IsOutlineVisible(x, y: Single; const pen: TGpPen;
                              const g: TGpGraphics = nil): Boolean; overload;
    function IsOutlineVisible(const point: TGpPoint; const pen: TGpPen;
                              const g: TGpGraphics = nil): Boolean; overload;
    function IsOutlineVisible(x, y: Integer; const pen: TGpPen;
                              const g: TGpGraphics = nil): Boolean; overload;
    // 获取或设置一个 FillMode 枚举，它确定此 GraphicsPath 对象中的形状的内部如何填充。
    property FillMode: Vcl.Graphics.TFillMode read GetFillMode write SetFillMode;
    // 获取此 GraphicsPath 对象的 PathPoints 数组中的最后的点。
    property LastPoint: TGpPointF read GetLastPoint;
    property PointCount: Integer read GetPointCount;
    // 获取一个 PathData 对象，它封装此 GraphicsPath 对象的点 (points) 和类型 (types) 的数组。
    // 不必释放TPathData对象
    property PathData: TPathData read GetPathData;
  end;

//--------------------------------------------------------------------------
// GraphisPathIterator class
// 提供循环访问 GraphicsPath 对象中的子路径并测试每一子路径中包含的形状类型的能力。
//--------------------------------------------------------------------------

  TGpGraphicsPathIterator = class(TGdiplusBase)
  private
    function GetCount: Integer;
    function GetSubpathCount: Integer;
  public
    constructor Create(path: TGpGraphicsPath);
    destructor Destroy; override;
    // 移到路径中的下一子路径。下一子路径的起始索引和结束索引包含在输出参数中。
    // isClosed当前子路径是否是闭合的,返回关联的路径中子路径的数目。
    function NextSubpath(var startIndex, endIndex: Integer;
                         var isClosed: Boolean): Integer; overload;
    // 从关联路径获取下一图形（子路径）到path。isClosed当前子路径是否是闭合的,返回子路径中的数据点的数目
    function NextSubpath(const path: TGpGraphicsPath;
                         var isClosed: Boolean): Integer; overload;
    // 获取全部具有相同类型的下一组数据点的起始索引和结束索引。
    function NextPathType(var pathType: TPathPointTypes; var startIndex, endIndex: Integer): Integer;
    // 增加到路径中的下一个标记并且通过输出参数返回起始和结束索引。返回此标记和下一标记间的点数
    function NextMarker(var startIndex, endIndex: Integer): Integer; overload;
    // 增加到其路径中的下一标记，并将当前标记和下一标记（或路径结尾）之间包含的
    // 所有点复制到 GraphicsPath 对象，返回此标记和下一标记间的点数
    function NextMarker(const path: TGpGraphicsPath): Integer; overload;
    // 指示与此 GraphicsPathIterator 对象关联的路径是否包含曲线。
    function HasCurve: Boolean;
    // 重绕到其关联路径的起始处。
    procedure Rewind;
    // 复制关联的 GraphicsPath 对象的 PathPoints 和 PathTypes 属性，返回复制的点数
    function Enumerate(var points: array of TGpPointF; var types: array of TPathPointTypes): Integer;
    // 复制关联的 GraphicsPath 对象的 PathPoints 和 PathTypes 属性，返回复制的点数
    // startIndex和endIndex点的起始和结束索引
    function CopyData(var points: array of TGpPointF; var types: array of TPathPointTypes;
                      startIndex, endIndex: Integer): Integer;
    // 获取路径中点的数目。
    property Count: Integer read GetCount;
    // 获取路径中子路径的数目。
    property SubpathCount: Integer read GetSubpathCount;
  end;

  TEnumerateMetafileProc = GdipTypes.TEnumerateMetafileProc;
  TGraphicsState = GdipTypes.TGraphicsState;
  TGraphicsContainer = GdipTypes. TGraphicsContainer;

  TCompositingMode = (cmSourceOver, cmSourceCopy);
  TCompositingQuality = (cqDefault, cqHighSpeed, cqHighQuality, cqGammaCorrected, cqAssumeLinear);
  TTextRenderingHint = (thSystemDefault, thSingleBitPerPixelGridFit,
    thSingleBitPerPixel, thAntiAliasGridFit, thAntiAlias, thClearTypeGridFit);
  TInterpolationMode = (imDefault, imLowQuality, imHighQuality, imBilinear,
    imBicubic, imNearestNeighbor, imHighQualityBilinear, imHighQualityBicubic);
  TSmoothingMode = (smDefault, smHighSpeed, smHighQuality, smNone, smAntiAlias);
  TPixelOffsetMode = (pmDefault, pmHighSpeed, pmHighQuality, pmNone, pmHalf);
  TFlushIntention = (fiFlush, fiSync);
  TCoordinateSpace = (csWorld, csPage, csDevice);
  TCombineMode = (cmReplace, cmIntersect, cmUnion, cmXor, cmExclude, cmComplement);

  TGpGraphics = class(TGdiplusBase)
  private
    procedure SetCompositingMode(compositingMode: TCompositingMode);
    function GetCompositingMode: TCompositingMode;
    procedure SetCompositingQuality(compositingQuality: TCompositingQuality);
    function GetCompositingQuality: TCompositingQuality;
    procedure SetTextRenderingHint(newMode: TTextRenderingHint);
    function  GetTextRenderingHint: TTextRenderingHint;
    procedure SetTextContrast(contrast: Integer);
    function GetTextContrast: Integer;
    function GetInterpolationMode: TInterpolationMode;
    procedure SetInterpolationMode(interpolationMode: TInterpolationMode);
    function GetSmoothingMode: TSmoothingMode;
    procedure SetSmoothingMode(smoothingMode: TSmoothingMode);
    function GetPixelOffsetMode: TPixelOffsetMode;
    procedure SetPixelOffsetMode(pixelOffsetMode: TPixelOffsetMode);
    procedure SetPageUnit(unit_: TUnit);
    procedure SetPageScale(scale: Single);
    function GetPageUnit: TUnit;
    function GetPageScale: Single;
    function GetDpiX: Single;
    function GetDpiY: Single;
    function GetRenderingOrigin: TGpPoint;
    procedure SetRenderingOrigin(const Value: TGpPoint);
  public
    // 从设备上下文的指定句柄创建新的 Graphics 对象。
    constructor Create(hdc: HDC); overload;
    class function FromHDC(hdc: HDC): TGpGraphics; overload;
    // 从设备上下文的指定句柄和设备的句柄创建新的 Graphics 对象。
    // 设备句柄通常用于查询特定打印机功能
    constructor Create(hdc: HDC; hdevice: THANDLE); overload;
    class function FromHDC(hdc: HDC; hdevice: THANDLE): TGpGraphics; overload;
    // 从窗口的指定句柄创建新的 Graphics 对象。
    constructor Create(hwnd: HWND; icm: Boolean); overload;
    class function FromHWND(hwnd: HWND; icm: Boolean = False): TGpGraphics;
    // 从指定的 Image 对象创建新 Graphics 对象。
    constructor Create(image: TGpImage); overload;
    class function FromImage(image: TGpImage): TGpGraphics;
    destructor Destroy; override;
    // 用此方法强制执行所有挂起的图形操作，按照指定，等待或者不等待，在操作完成之前返回
    procedure Flush(intention: TFlushIntention  = fiFlush);

    //------------------------------------------------------------------------
    // GDI Interop methods
    //------------------------------------------------------------------------

    // 获取关联的设备上下文的句柄。必须与ReleaseHDC方法成对使用
    // 由于未选择字体，句柄对 Font.Create(Hdc) 方法进行调用将会失败。
    function GetHDC: HDC;
    // 释放通过以前 GetHdc 方法的调用获得的设备上下文句柄。
    procedure ReleaseHDC(hdc: HDC);
    // 获取或设置此 Graphics 对象的全局变换。
    procedure GetTransform(matrix: TGpMatrix);
    procedure SetTransform(const matrix: TGpMatrix);
    // 将此对象的全局变换矩阵重置为单位矩阵。
    procedure ResetTransform;
    // 以指定顺序将此 Graphics 对象的全局变换乘以指定的 Matrix 对象。
    procedure MultiplyTransform(const matrix: TGpMatrix; order: TMatrixOrder = moPrepend);
    // 以指定顺序将指定平移应用到此 Graphics 对象的变换矩阵。
    procedure TranslateTransform(dx, dy: Single; order: TMatrixOrder = moPrepend);
    // 以指定顺序将指定的缩放操作应用到此 Graphics 对象的变换矩阵。
    procedure ScaleTransform(sx, sy: Single; order: TMatrixOrder = moPrepend);
    // 以指定顺序将指定旋转应用到此 Graphics 对象的变换矩阵。
    procedure RotateTransform(angle: Single; order: TMatrixOrder = moPrepend);
    // 使用此对象的当前全局变换和页变换，将点数组从一个坐标空间转换到另一个坐标空间。
    procedure TransformPoints(destSpace, srcSpace: TCoordinateSpace;
                              pts: array of TGpPointF); overload;
    procedure TransformPoints(destSpace, srcSpace: TCoordinateSpace;
                              pts: array of TGpPoint); overload;

    //------------------------------------------------------------------------
    // GetNearestColor (for <= 8bpp surfaces).  Note: Alpha is ignored.
    // 当低于或等于8位环境时，获取与指定的 Color 结构最接近的颜色。
    //------------------------------------------------------------------------

    function GetNearestColor(Color: TARGB): TARGB;

    // 绘制一条连接由坐标对指定的两个点的线条。
    procedure DrawLine(const pen: TGpPen; x1, y1, x2, y2: Single); overload;
    procedure DrawLine(const pen: TGpPen; pt1, pt2: TGpPointF); overload;
    procedure DrawLine(const pen: TGpPen; x1, y1, x2, y2: Integer); overload;
    procedure DrawLine(const pen: TGpPen; pt1, pt2: TGpPoint); overload;
    // 绘制一系列连接一组 Point 结构的线段。
    procedure DrawLines(const pen: TGpPen; const points: array of TGpPointF); overload;
    procedure DrawLines(const pen: TGpPen; const points: array of TGpPoint); overload;
    // 绘制一段弧线，它表示由一对坐标、宽度和高度指定的椭圆部分。
    // 其中：startAngle 从 x 轴到弧线的起始点沿顺时针方向度量的角（以度为单位）。
    // sweepAngle 从 startAngle 参数到弧线的结束点沿顺时针方向度量的角（以度为单位）。
    procedure DrawArc(const pen: TGpPen; x, y, width, height: Single;
                      startAngle, sweepAngle: Single); overload;
    procedure DrawArc(const pen: TGpPen; const rect: TGpRectF;
                      startAngle, sweepAngle: Single); overload;
    procedure DrawArc(const pen: TGpPen; x, y, width, height: Integer;
                      startAngle, sweepAngle: Single); overload;
    procedure DrawArc(const pen: TGpPen; const rect: TGpRect;
                      startAngle, sweepAngle: Single); overload;
    // 绘制由 4 个 Point 结构定义的贝塞尔样条。
    procedure DrawBezier(const pen: TGpPen; x1, y1, x2, y2, x3, y3, x4, y4: Single); overload;
    procedure DrawBezier(const pen: TGpPen; const pt1, pt2, pt3, pt4: TGpPointF); overload;
    procedure DrawBezier(const pen: TGpPen; x1, y1, x2, y2, x3, y3, x4, y4: Integer); overload;
    procedure DrawBezier(const pen: TGpPen; const pt1, pt2, pt3, pt4: TGpPoint); overload;
    // 用 Point 结构数组绘制一系列贝塞尔样条。
    procedure DrawBeziers(const pen: TGpPen; const points: array of TGpPointF); overload;
    procedure DrawBeziers(const pen: TGpPen; const points: array of TGpPoint); overload;
    // 绘制由坐标对、宽度和高度指定的矩形。
    procedure DrawRectangle(const pen: TGpPen; const rect: TGpRectF); overload;
    procedure DrawRectangle(const pen: TGpPen; x, y, width, height: Single); overload;
    procedure DrawRectangle(const pen: TGpPen; const rect: TGpRect); overload;
    procedure DrawRectangle(const pen: TGpPen; x, y, width, height: Integer); overload;
    // 绘制一系列由 Rectangle 结构指定的矩形。
    procedure DrawRectangles(const pen: TGpPen; const rects: array of TGpRectF); overload;
    procedure DrawRectangles(const pen: TGpPen; const rects: array of TGpRect); overload;
    // 绘制一个由边框（该边框由一对坐标、高度和宽度指定）定义的椭圆。
    procedure DrawEllipse(const pen: TGpPen; const rect: TGpRectF); overload;
    procedure DrawEllipse(const pen: TGpPen; x, y, width, height: Single); overload;
    procedure DrawEllipse(const pen: TGpPen; const rect: TGpRect); overload;
    procedure DrawEllipse(const pen: TGpPen; x, y, width, height: Integer); overload;
    // 绘制一个扇形，该扇形由一个坐标对、宽度和高度以及两条射线所指定的椭圆定义。
    procedure DrawPie(const pen: TGpPen; const rect: TGpRectF;
                      startAngle, sweepAngle: Single); overload;
    procedure DrawPie(const pen: TGpPen; x, y, width, height: Single;
                      startAngle, sweepAngle: Single); overload;
    procedure DrawPie(const pen: TGpPen; const rect: TGpRect;
                      startAngle, sweepAngle: Single); overload;
    procedure DrawPie(const pen: TGpPen; x, y, width, height: Integer;
                      startAngle, sweepAngle: Single); overload;
    // 绘制由一组 Point 结构定义的多边形。
    procedure DrawPolygon(const pen: TGpPen; const points: array of TGpPointF); overload;
    procedure DrawPolygon(const pen: TGpPen; const points: array of TGpPoint); overload;
    // 绘制 GraphicsPath 对象
    procedure DrawPath(const pen: TGpPen; const path: TGpGraphicsPath);
    // 绘制经过一组指定的 Point 结构的基数样条。
    // 其中：offset: 从 points 参数数组中的第一个元素到曲线中起始点的偏移量。
    // numberOfSegments: 起始点之后要包含在曲线中的段数。
    // tension: 大于或等于 0.0 的值，该值指定曲线的张力。
    procedure DrawCurve(const pen: TGpPen; const points: array of TGpPointF); overload;
    procedure DrawCurve(const pen: TGpPen; const points: array of TGpPointF; tension: Single); overload;
    procedure DrawCurve(const pen: TGpPen; const points: array of TGpPointF;
                        offset, numberOfSegments: Integer; tension: Single = 0.5); overload;
    procedure DrawCurve(const pen: TGpPen; const points: array of TGpPoint); overload;
    procedure DrawCurve(const pen: TGpPen; const points: array of TGpPoint; tension: Single); overload;
    procedure DrawCurve(const pen: TGpPen; const points: array of TGpPoint;
                        offset, numberOfSegments: Integer; tension: Single = 0.5); overload;
    // 绘制由 Point 结构的数组定义的闭合基数样条。
    procedure DrawClosedCurve(const pen: TGpPen; const points: array of TGpPointF); overload;
    procedure DrawClosedCurve(const pen: TGpPen; const points: array of TGpPointF; tension: Single); overload;
    procedure DrawClosedCurve(const pen: TGpPen; const points: array of TGpPoint); overload;
    procedure DrawClosedCurve(const pen: TGpPen; const points: array of TGpPoint; tension: Single); overload;

    // 清除整个绘图面并以指定背景色填充。
    procedure Clear(const color: TARGB);
    // 填充由一对坐标、一个宽度和一个高度指定的矩形的内部。
    procedure FillRectangle(const brush: TGpBrush; const rect: TGpRectF); overload;
    procedure FillRectangle(const brush: TGpBrush; x, y, width, height: Single); overload;
    procedure FillRectangle(const brush: TGpBrush; const rect: TGpRect); overload;
    procedure FillRectangle(const brush: TGpBrush; x, y, width, height: Integer); overload;
    // 填充由 Rectangle 结构指定的一系列矩形的内部。
    procedure FillRectangles(const brush: TGpBrush; const rects: array of TGpRectF); overload;
    procedure FillRectangles(const brush: TGpBrush; const rects: array of TGpRect); overload;
    // 填充 Point 结构指定的点数组所定义的多边形的内部。
    procedure FillPolygon(const brush: TGpBrush; const points: array of TGpPointF;
                          fillMode: Vcl.Graphics.TFillMode = fmAlternate); overload;
    procedure FillPolygon(const brush: TGpBrush; const points: array of TGpPoint;
                          fillMode: Vcl.Graphics.TFillMode = fmAlternate); overload;
    // 填充边框所定义的椭圆的内部，该边框由一对坐标、一个宽度和一个高度指定。
    procedure FillEllipse(const brush: TGpBrush; const rect: TGpRectF); overload;
    procedure FillEllipse(const brush: TGpBrush; x, y, width, height: Single); overload;
    procedure FillEllipse(const brush: TGpBrush; const rect: TGpRect); overload;
    procedure FillEllipse(const brush: TGpBrush; x, y, width, height: Integer); overload;
    // 填充由一对坐标、一个宽度、一个高度以及两条射线指定的椭圆所定义的扇形区的内部。
    procedure FillPie(const brush: TGpBrush; const rect: TGpRectF;
                      startAngle, sweepAngle: Single); overload;
    procedure FillPie(const brush: TGpBrush; x, y, width, height: Single;
                      startAngle, sweepAngle: Single); overload;
    procedure FillPie(const brush: TGpBrush; const rect: TGpRect;
                      startAngle, sweepAngle: Single); overload;
    procedure FillPie(const brush: TGpBrush; x, y, width, height: Integer;
                      startAngle, sweepAngle: Single); overload;
    // 填充 GraphicsPath 对象的内部。
    procedure FillPath(const brush: TGpBrush; const path: TGpGraphicsPath);
    // 填充由 Point 结构数组定义的闭合基数样条曲线的内部。
    procedure FillClosedCurve(const brush: TGpBrush; const points: array of TGpPointF); overload;
    procedure FillClosedCurve(const brush: TGpBrush; const points: array of TGpPointF;
                              fillMode: Vcl.Graphics.TFillMode; tension: Single = 0.5); overload;
    procedure FillClosedCurve(const brush: TGpBrush; const points: array of TGpPoint); overload;
    procedure FillClosedCurve(const brush: TGpBrush; const points: array of TGpPoint;
                              fillMode: Vcl.Graphics.TFillMode; tension: Single = 0.5); overload;
    // 填充 Region 对象的内部。
    procedure FillRegion(const brush: TGpBrush; const region: TGpRegion);
    // 使用指定 StringFormat 对象的格式化属性，
    // 用指定的 Brush 和 Font 对象在指定的坐标点或矩形绘制指定的文本字符串。
    procedure DrawString(const str: WideString; const font: TGpFont;
                         const brush: TGpBrush; const layoutRect: TGpRectF;
                         const format: TGpStringFormat = nil); overload;
    procedure DrawString(const str: WideString; const font: TGpFont;
                         const brush: TGpBrush; x, y: Single;
                         const format: TGpStringFormat = nil); overload;
    procedure DrawString(const str: WideString; const font: TGpFont;
                         const brush: TGpBrush; const origin: TGpPointF;
                         const format: TGpStringFormat = nil); overload;
    // 测量用指定的 Font 对象绘制并用指定的 StringFormat 对象格式化的指定字符串。
    // 返回绘制文本所占用的矩形空间
    function MeasureString(const str: WideString; const font: TGpFont;
                           const layoutArea: TGpSizeF;
                           const format: TGpStringFormat = nil;
                           codepointsFitted: PInteger = nil;
                           linesFilled: PInteger = nil): TGpRectF; overload;
    function MeasureString(const str: WideString; const font: TGpFont;
                           const layoutRect: TGpRectF;
                           const format: TGpStringFormat = nil): TGpRectF; overload;
    function MeasureString(const str: WideString; const font: TGpFont;
                           const origin: TGpPointF;
                           const format: TGpStringFormat = nil): TGpRectF; overload;
    function MeasureString(const str: WideString;
                           const font: TGpFont; width: Integer = 0;
                           const format: TGpStringFormat = nil): TGpRectF; overload;
    // 获取 Region 对象的数组，其中每个对象将字符位置的范围限定在指定字符串内。
    procedure MeasureCharacterRanges(const str: WideString; const font: TGpFont;
                         const layoutRect: TGpRectF; const format: TGpStringFormat;
                         const regions: array of TGpRegion);
    procedure DrawDriverString(const text: PUINT16; length: Integer;
                               const font: TGpFont; const brush: TGpBrush;
                               const positions: PGpPointF; flags: Integer;
                               const matrix: TGpMatrix);
    function MeasureDriverString(const text: PUINT16; length: Integer;
                                  const font: TGpFont; const positions: PGpPointF;
                                  flags: Integer; const matrix: TGpMatrix): TGpRectF;

    // Draw a cached bitmap on this graphics destination offset by
    // x, y. Note this will fail with WrongState if the CachedBitmap
    // native format differs from this Graphics.

    procedure DrawCachedBitmap(cb: TGpCachedBitmap; x, y: Integer);
    // 在指定位置并且按原始大小绘制指定的 Image 对象。
    procedure DrawImage(image: TGpImage; const point: TGpPointF); overload;
    procedure DrawImage(image: TGpImage; x, y: Single); overload;
    procedure DrawImage(image: TGpImage; const point: TGpPoint); overload;
    procedure DrawImage(image: TGpImage; x, y: Integer); overload;
    // 在指定位置并且按指定大小绘制指定的 Image 对象。
    procedure DrawImage(image: TGpImage; const rect: TGpRectF); overload;
    procedure DrawImage(image: TGpImage; const rect: TGpRect); overload;
    procedure DrawImage(image: TGpImage; x, y, width, height: Integer); overload;
    procedure DrawImage(image: TGpImage; x, y, width, height: Single); overload;
    // Affine Draw Image
    // destPoints.length = 3: rect => parallelogram
    //     destPoints[0] <=> top-left corner of the source rectangle
    //     destPoints[1] <=> top-right corner
    //     destPoints[2] <=> bottom-left corner
    // destPoints.length = 4: rect => quad
    //     destPoints[3] <=> bottom-right corner
    // 在指定位置并且按指定形状和大小绘制指定的 Image 对象。
    // destPoinrs: 由三个或四个矩形结构组成的数组，定义一个平行四边形。
    procedure DrawImage(image: TGpImage; const destPoints: array of TGpPointF); overload;
    procedure DrawImage(image: TGpImage; const destPoints: array of TGpPoint); overload;
    // 在指定的位置绘制图像的一部分。srcUnit: srcRect 参数所用的度量单位
    procedure DrawImage(image: TGpImage; x, y, srcx, srcy,
                        srcwidth, srcheight: Single; srcUnit: TUnit); overload;
    procedure DrawImage(image: TGpImage; x, y, srcx, srcy,
                        srcwidth, srcheight: Integer; srcUnit: TUnit); overload;
    procedure DrawImage(image: TGpImage; x, y: Single; srcRect: TGpRectF; srcUnit: TUnit); overload;
    procedure DrawImage(image: TGpImage; x, y: Integer; srcRect: TGpRect; srcUnit: TUnit); overload;
    // 在指定位置并且按指定大小绘制指定的 Image 对象的指定部分。
    // 其中 callback  为回调函数，以检查是否根据应用程序确定的条件停止绘图
    // callbackData 回调函数附加数据指针
    procedure DrawImage(image: TGpImage; const destRect: TGpRectF;
                        srcx, srcy, srcwidth, srcheight: Single;
                        srcUnit: TUnit; const imageAttributes: TGpImageAttributes = nil;
                        callback: TDrawImageAbort = nil;
                        callbackData: Pointer = nil); overload;
    procedure DrawImage(image: TGpImage; const destRect: TGpRect;
                        srcx, srcy, srcwidth, srcheight: Integer;
                        srcUnit: TUnit; const imageAttributes: TGpImageAttributes = nil;
                        callback: TDrawImageAbort = nil;
                        callbackData: Pointer = nil); overload;
    // 在指定位置并且按指定大小绘制指定的 Image 对象的指定部分。
    // // destPoinrs: 由三个或四个矩形结构组成的数组，定义一个平行四边形。
    procedure DrawImage(image: TGpImage; const destPoints: array of TGpPointF;
                        srcx, srcy, srcwidth, srcheight: Single;
                        srcUnit: TUnit; const imageAttributes: TGpImageAttributes = nil;
                        callback: TDrawImageAbort = nil;
                        callbackData: Pointer = nil); overload;
    procedure DrawImage(image: TGpImage; const destPoints: array of TGpPoint;
                        srcx, srcy, srcwidth, srcheight: Integer;
                        srcUnit: TUnit; const imageAttributes: TGpImageAttributes = nil;
                        callback: TDrawImageAbort = nil;
                        callbackData: Pointer = nil); overload;

    // The following methods are for playing an EMF+ to a graphics
    // via the enumeration interface.  Each record of the EMF+ is
    // sent to the callback (along with the callbackData).  Then
    // the callback can invoke the Metafile::PlayRecord method
    // to play the particular record.
    // 将指定 Metafile 对象中的记录逐个发送到回调方法以在指定的点处显示。
    procedure EnumerateMetafile(const metafile: TGpMetafile;
                                const destPoint: TGpPointF;
                                callback: TEnumerateMetafileProc;
                                callbackData: Pointer = nil;
                                const imageAttributes: TGpImageAttributes = nil); overload;
    procedure EnumerateMetafile(const metafile: TGpMetafile;
                                const destPoint: TGpPoint;
                                callback: TEnumerateMetafileProc;
                                callbackData: Pointer = nil;
                                const imageAttributes: TGpImageAttributes = nil); overload;
    procedure EnumerateMetafile(const metafile: TGpMetafile;
                                const destRect: TGpRectF;
                                callback: TEnumerateMetafileProc;
                                callbackData: Pointer = nil;
                                const imageAttributes: TGpImageAttributes = nil); overload;
    procedure EnumerateMetafile(const metafile: TGpMetafile;
                                const destRect: TGpRect;
                                callback: TEnumerateMetafileProc;
                                callbackData: Pointer = nil;
                                const imageAttributes: TGpImageAttributes = nil); overload;
    procedure EnumerateMetafile(const metafile: TGpMetafile;
                                const destPoints: array of TGpPointF;
                                callback: TEnumerateMetafileProc;
                                callbackData: Pointer = nil;
                                const imageAttributes: TGpImageAttributes = nil); overload;
    procedure EnumerateMetafile(const metafile: TGpMetafile;
                                const destPoints: array of TGpPoint;
                                callback: TEnumerateMetafileProc;
                                callbackData: Pointer = nil;
                                const imageAttributes: TGpImageAttributes = nil); overload;
    procedure EnumerateMetafile(const metafile: TGpMetafile; const destPoint: TGpPointF;
                                const srcRect: TGpRectF; srcUnit: TUnit;
                                callback: TEnumerateMetafileProc;
                                callbackData: Pointer = nil;
                                const imageAttributes: TGpImageAttributes = nil); overload;
    procedure EnumerateMetafile(const metafile: TGpMetafile; const destPoint: TGpPoint;
                                const srcRect: TGpRect; srcUnit: TUnit;
                                callback: TEnumerateMetafileProc;
                                callbackData: Pointer = nil;
                                const imageAttributes: TGpImageAttributes = nil); overload;
    procedure EnumerateMetafile(const metafile: TGpMetafile; const destRect: TGpRectF;
                                const srcRect: TGpRectF; srcUnit: TUnit;
                                callback: TEnumerateMetafileProc;
                                callbackData: Pointer = nil;
                                const imageAttributes: TGpImageAttributes = nil); overload;
    procedure EnumerateMetafile(const metafile: TGpMetafile; const destRect: TGpRect;
                                const srcRect: TGpRect; srcUnit: TUnit;
                                callback: TEnumerateMetafileProc;
                                callbackData: Pointer = nil;
                                const imageAttributes: TGpImageAttributes = nil); overload;
    procedure EnumerateMetafile(const metafile: TGpMetafile;
                                const destPoints: array of TGpPointF;
                                const srcRect: TGpRectF; srcUnit: TUnit;
                                callback: TEnumerateMetafileProc;
                                callbackData: Pointer = nil;
                                const imageAttributes: TGpImageAttributes = nil); overload;
    procedure EnumerateMetafile(const metafile: TGpMetafile;
                                const destPoints: array of TGpPoint;
                                const srcRect: TGpRect; srcUnit: TUnit;
                                callback: TEnumerateMetafileProc;
                                callbackData: Pointer = nil;
                                const imageAttributes: TGpImageAttributes = nil); overload;
    // 将剪辑区域设置为当前剪辑区域和指定的 TGpGraphics 对象的 Clip 属性指定的组合操作的结果。
    procedure SetClip(const g: TGpGraphics; combineMode: TCombineMode = cmReplace); overload;
    // 将此剪辑区域设置为当前剪辑区域与 Rectangle 结构所指定矩形的组合结果。
    procedure SetClip(const rect: TGpRectF; combineMode: TCombineMode = cmReplace); overload;
    procedure SetClip(const rect: TGpRect; combineMode: TCombineMode = cmReplace); overload;
    // 将剪辑区域设置为当前剪辑区域与指定 GraphicsPath 对象的组合结果。
    procedure SetClip(const path: TGpGraphicsPath; combineMode: TCombineMode = cmReplace); overload;
    // 将剪辑区域设置为当前剪辑区域与指定 Region 对象的组合结果。
    procedure SetClip(const region: TGpRegion; combineMode: TCombineMode = cmReplace); overload;

    // This is different than the other SetClip methods because it assumes
    // that the HRGN is already in device units, so it doesn't transform
    // the coordinates in the HRGN.
    procedure SetClip(hRgn: HRGN; combineMode: TCombineMode = cmReplace); overload;
    // 将剪辑区域更新为当前剪辑区域与指定结构或对象的交集。
    procedure IntersectClip(const rect: TGpRectF); overload;
    procedure IntersectClip(const rect: TGpRect); overload;
    procedure IntersectClip(const region: TGpRegion); overload;
    // 更新此剪辑区域，以排除矩形或区域结构所指定的区域。
    procedure ExcludeClip(const rect: TGpRectF); overload;
    procedure ExcludeClip(const rect: TGpRect); overload;
    procedure ExcludeClip(const region: TGpRegion); overload;
    // 将剪辑区域重置为无限区域。
    procedure ResetClip;
    // 将剪辑区域沿水平方向和垂直方向平移指定的量。
    procedure TranslateClip(dx, dy: Single); overload;
    procedure TranslateClip(dx, dy: Integer); overload;
    // 获取 Region 对象，该对象限定此 Graphics 对象的绘图区域。
    procedure GetClip(region: TGpRegion);
    // 获取一个 Rect 结构，该结构限定此 Graphics 对象的剪辑区域。
    procedure GetClipBounds(var rect: TGpRectF); overload;
    procedure GetClipBounds(var rect: TGpRect); overload;
    // 获取一个值，该值指示此 Graphics 对象的剪辑区域是否为空。
    function IsClipEmpty: Boolean;
    // 获取此 Graphics 对象的可见剪辑区域的边框。
    procedure GetVisibleClipBounds(var rect: TGpRectF); overload;
    procedure GetVisibleClipBounds(var rect: TGpRect); overload;
    // 获取一个值，该值指示此 Graphics 对象的可见剪辑区域是否为空。
    function IsVisibleClipEmpty: Boolean;
    // 指示指定的坐标或矩形是否包含在此 Graphics 对象的可见剪辑区域内。
    function IsVisible(x, y: Integer): Boolean; overload;
    function IsVisible(const point: TGpPoint): Boolean; overload;
    function IsVisible(x, y, width, height: Integer): Boolean; overload;
    function IsVisible(const rect: TGpRect): Boolean; overload;
    function IsVisible(x, y: Single): Boolean; overload;
    function IsVisible(const point: TGpPointF): Boolean; overload;
    function IsVisible(x, y, width, height: Single): Boolean; overload;
    function IsVisible(const rect: TGpRectF): Boolean; overload;
    // 保存对象的当前状态，并用 TGraphicsState 对象标识保存的状态
    // 返回的 GraphicsState 对象只能向 Restore 方法传递一次
    function Save: TGraphicsState;
    // 将对象的状态还原到 GraphicsState 对象表示的状态。
    procedure Restore(gstate: TGraphicsState );
    // 保存具有此对象当前状态的图形容器，然后打开并使用新的图形容器。
    function  BeginContainer(const dstrect, srcrect: TGpRectF;
                             unit_: TUnit): TGraphicsContainer; overload;
    function  BeginContainer(const dstrect, srcrect: TGpRect;
                             unit_: TUnit): TGraphicsContainer; overload;
    function  BeginContainer: TGraphicsContainer; overload;
    // 关闭当前图形容器，并将对象的状态还原到通过调用 BeginContainer 方法保存的状态。
    procedure EndContainer(state: TGraphicsContainer);

    // Only valid when recording metafiles.
    // 向当前 Metafile 对象添加注释。参数：数据缓冲区及其长度
    procedure AddMetafileComment(const data: PBYTE; sizeData: Integer);
    // 获取当前 Windows 的半色调调色板的句柄。
    // 目的是，在显示器使用每像素 8 位时，使 GDI+ 能够产生更好质量的半色调。
    class function GetHalftonePalette: HPALETTE;

    // 为抵色处理和阴影画笔获取或设置呈现原点。
    // 属性指定 Point 结构，该结构表示 8 位/像素和 16 位/像素抵色处理的抵色原点，
    // 还用于设置阴影画笔的原点。
    property RenderingOrigin: TGpPoint read GetRenderingOrigin write SetRenderingOrigin;
    // 获取或设置如何将合成图像绘制到此 Graphics 对象。
    property CompositingMode: TCompositingMode read GetCompositingMode write SetCompositingMode;
    // 获取或设置绘制到此 Graphics 对象的合成图像的呈现质量。
    property CompositingQuality: TCompositingQuality read GetCompositingQuality write SetCompositingQuality;
    // 获取或设置与对象关联的文本的呈现模式。文本呈现提示指定文本是否以 Antialias 形式呈现
    property TextRenderingHint: TTextRenderingHint read GetTextRenderingHint write SetTextRenderingHint;
    // 获取或设置呈现文本的伽玛纠正值。用于呈现 Antialias 和 ClearType 文本的伽玛纠正值。
    // 伽玛纠正值必须介于 0 和 12 之间。默认值为 4。
    property TextContrast: Integer read GetTextContrast write SetTextContrast;
    // 获取或设置与对象关联的插补模式。
    property InterpolationMode: TInterpolationMode read GetInterpolationMode write SetInterpolationMode;
    // 获取或设置此对象的呈现质量。平滑模式不影响使用路径渐变画笔填充的区域
    // SmoothingMode 属性不影响文本。若要设置文本呈现质量，请使用 TextRenderingHint 枚举
    property SmoothingMode: TSmoothingMode read GetSmoothingMode write SetSmoothingMode;
    // 获取或设置一个值，该值指定在呈现此 Graphics 对象的过程中像素如何偏移
    property PixelOffsetMode: TPixelOffsetMode read GetPixelOffsetMode write SetPixelOffsetMode;
    // 获取或设置用于此 Graphics 对象中的页坐标的度量单位。
    property PageUnit: TUnit read GetPageUnit write SetPageUnit;
    // 获取或设置此 Graphics 对象的全局单位和页单位之间的比例。
    property PageScale: Single read GetPageScale write SetPageScale;
    // 获取此 Graphics 对象的水平分辨率（以每英寸点数表示）。
    property DpiX: Single read GetDpiX;
    // 获取此 Graphics 对象的垂直分辨率（以每英寸点数表示）。
    property DpiY: Single read GetDpiY;
  end;

  TPens = class
  private
    FPen: TGpPen;
    FColor: TARGB;
    FWidth: Single;
//    function GetDefinePen(const Index: TARGB): TGpPen;
    function GetPen(AColor: TARGB; AWidth: Single): TGpPen;
    function GetDefinePen(const Index: Integer): TGpPen;
  public
    constructor Create;
    destructor Destroy; override;

    property Pen[AColor: TARGB; AWidth: Single]: TGpPen read GetPen; default;
    property AliceBlue: TGpPen Index kcAliceBlue read GetDefinePen;
    property AntiqueWhite: TGpPen Index kcAntiqueWhite read GetDefinePen;
    property Aqua: TGpPen Index kcAqua read GetDefinePen;
    property Aquamarine: TGpPen Index kcAquamarine read GetDefinePen;
    property Azure: TGpPen Index kcAzure read GetDefinePen;
    property Beige: TGpPen Index kcBeige read GetDefinePen;
    property Bisque: TGpPen Index kcBisque read GetDefinePen;
    property Black: TGpPen Index kcBlack read GetDefinePen;
    property BlanchedAlmond: TGpPen Index kcBlanchedAlmond read GetDefinePen;
    property Blue: TGpPen Index kcBlue read GetDefinePen;
    property BlueViolet: TGpPen Index kcBlueViolet read GetDefinePen;
    property Brown: TGpPen Index kcBrown read GetDefinePen;
    property BurlyWood: TGpPen Index kcBurlyWood read GetDefinePen;
    property CadetBlue: TGpPen Index kcCadetBlue read GetDefinePen;
    property Chartreuse: TGpPen Index kcChartreuse read GetDefinePen;
    property Chocolate: TGpPen Index kcChocolate read GetDefinePen;
    property Coral: TGpPen Index kcCoral read GetDefinePen;
    property CornflowerBlue: TGpPen Index kcCornflowerBlue read GetDefinePen;
    property Cornsilk: TGpPen Index kcCornsilk read GetDefinePen;
    property Crimson: TGpPen Index kcCrimson read GetDefinePen;
    property Cyan: TGpPen Index kcCyan read GetDefinePen;
    property DarkBlue: TGpPen Index kcDarkBlue read GetDefinePen;
    property DarkCyan: TGpPen Index kcDarkCyan read GetDefinePen;
    property DarkGoldenrod: TGpPen Index kcDarkGoldenrod read GetDefinePen;
    property DarkGray: TGpPen Index kcDarkGray read GetDefinePen;
    property DarkGreen: TGpPen Index kcDarkGreen read GetDefinePen;
    property DarkKhaki: TGpPen Index kcDarkKhaki read GetDefinePen;
    property DarkMagenta: TGpPen Index kcDarkMagenta read GetDefinePen;
    property DarkOliveGreen: TGpPen Index kcDarkOliveGreen read GetDefinePen;
    property DarkOrange: TGpPen Index kcDarkOrange read GetDefinePen;
    property DarkOrchid: TGpPen Index kcDarkOrchid read GetDefinePen;
    property DarkRed: TGpPen Index kcDarkRed read GetDefinePen;
    property DarkSalmon: TGpPen Index kcDarkSalmon read GetDefinePen;
    property DarkSeaGreen: TGpPen Index kcDarkSeaGreen read GetDefinePen;
    property DarkSlateBlue: TGpPen Index kcDarkSlateBlue read GetDefinePen;
    property DarkSlateGray: TGpPen Index kcDarkSlateGray read GetDefinePen;
    property DarkTurquoise: TGpPen Index kcDarkTurquoise read GetDefinePen;
    property DarkViolet: TGpPen Index kcDarkViolet read GetDefinePen;
    property DeepPink: TGpPen Index kcDeepPink read GetDefinePen;
    property DeepSkyBlue: TGpPen Index kcDeepSkyBlue read GetDefinePen;
    property DimGray: TGpPen Index kcDimGray read GetDefinePen;
    property DodgerBlue: TGpPen Index kcDodgerBlue read GetDefinePen;
    property Firebrick: TGpPen Index kcFirebrick read GetDefinePen;
    property FloralWhite: TGpPen Index kcFloralWhite read GetDefinePen;
    property ForestGreen: TGpPen Index kcForestGreen read GetDefinePen;
    property Fuchsia: TGpPen Index kcFuchsia read GetDefinePen;
    property Gainsboro: TGpPen Index kcGainsboro read GetDefinePen;
    property GhostWhite: TGpPen Index kcGhostWhite read GetDefinePen;
    property Gold: TGpPen Index kcGold read GetDefinePen;
    property Goldenrod: TGpPen Index kcGoldenrod read GetDefinePen;
    property Gray: TGpPen Index kcGray read GetDefinePen;
    property Green: TGpPen Index kcGreen read GetDefinePen;
    property GreenYellow: TGpPen Index kcGreenYellow read GetDefinePen;
    property Honeydew: TGpPen Index kcHoneydew read GetDefinePen;
    property HotPink: TGpPen Index kcHotPink read GetDefinePen;
    property IndianRed: TGpPen Index kcIndianRed read GetDefinePen;
    property Indigo: TGpPen Index kcIndigo read GetDefinePen;
    property Ivory: TGpPen Index kcIvory read GetDefinePen;
    property Khaki: TGpPen Index kcKhaki read GetDefinePen;
    property Lavender: TGpPen Index kcLavender read GetDefinePen;
    property LavenderBlush: TGpPen Index kcLavenderBlush read GetDefinePen;
    property LawnGreen: TGpPen Index kcLawnGreen read GetDefinePen;
    property LemonChiffon: TGpPen Index kcLemonChiffon read GetDefinePen;
    property LightBlue: TGpPen Index kcLightBlue read GetDefinePen;
    property LightCoral: TGpPen Index kcLightCoral read GetDefinePen;
    property LightCyan: TGpPen Index kcLightCyan read GetDefinePen;
    property LightGoldenrodYellow: TGpPen Index kcLightGoldenrodYellow read GetDefinePen;
    property LightGray: TGpPen Index kcLightGray read GetDefinePen;
    property LightGreen: TGpPen Index kcLightGreen read GetDefinePen;
    property LightPink: TGpPen Index kcLightPink read GetDefinePen;
    property LightSalmon: TGpPen Index kcLightSalmon read GetDefinePen;
    property LightSeaGreen: TGpPen Index kcLightSeaGreen read GetDefinePen;
    property LightSkyBlue: TGpPen Index kcLightSkyBlue read GetDefinePen;
    property LightSlateGray: TGpPen Index kcLightSlateGray read GetDefinePen;
    property LightSteelBlue: TGpPen Index kcLightSteelBlue read GetDefinePen;
    property LightYellow: TGpPen Index kcLightYellow read GetDefinePen;
    property Lime: TGpPen Index kcLime read GetDefinePen;
    property LimeGreen: TGpPen Index kcLimeGreen read GetDefinePen;
    property Linen: TGpPen Index kcLinen read GetDefinePen;
    property Magenta: TGpPen Index kcMagenta read GetDefinePen;
    property Maroon: TGpPen Index kcMaroon read GetDefinePen;
    property MediumAquamarine: TGpPen Index kcMediumAquamarine read GetDefinePen;
    property MediumBlue: TGpPen Index kcMediumBlue read GetDefinePen;
    property MediumOrchid: TGpPen Index kcMediumOrchid read GetDefinePen;
    property MediumPurple: TGpPen Index kcMediumPurple read GetDefinePen;
    property MediumSeaGreen: TGpPen Index kcMediumSeaGreen read GetDefinePen;
    property MediumSlateBlue: TGpPen Index kcMediumSlateBlue read GetDefinePen;
    property MediumSpringGreen: TGpPen Index kcMediumSpringGreen read GetDefinePen;
    property MediumTurquoise: TGpPen Index kcMediumTurquoise read GetDefinePen;
    property MediumVioletRed: TGpPen Index kcMediumVioletRed read GetDefinePen;
    property MidnightBlue: TGpPen Index kcMidnightBlue read GetDefinePen;
    property MintCream: TGpPen Index kcMintCream read GetDefinePen;
    property MistyRose: TGpPen Index kcMistyRose read GetDefinePen;
    property Moccasin: TGpPen Index kcMoccasin read GetDefinePen;
    property NavajoWhite: TGpPen Index kcNavajoWhite read GetDefinePen;
    property Navy: TGpPen Index kcNavy read GetDefinePen;
    property OldLace: TGpPen Index kcOldLace read GetDefinePen;
    property Olive: TGpPen Index kcOlive read GetDefinePen;
    property OliveDrab: TGpPen Index kcOliveDrab read GetDefinePen;
    property Orange: TGpPen Index kcOrange read GetDefinePen;
    property OrangeRed: TGpPen Index kcOrangeRed read GetDefinePen;
    property Orchid: TGpPen Index kcOrchid read GetDefinePen;
    property PaleGoldenrod: TGpPen Index kcPaleGoldenrod read GetDefinePen;
    property PaleGreen: TGpPen Index kcPaleGreen read GetDefinePen;
    property PaleTurquoise: TGpPen Index kcPaleTurquoise read GetDefinePen;
    property PaleVioletRed: TGpPen Index kcPaleVioletRed read GetDefinePen;
    property PapayaWhip: TGpPen Index kcPapayaWhip read GetDefinePen;
    property PeachPuff: TGpPen Index kcPeachPuff read GetDefinePen;
    property Peru: TGpPen Index kcPeru read GetDefinePen;
    property Pink: TGpPen Index kcPink read GetDefinePen;
    property Plum: TGpPen Index kcPlum read GetDefinePen;
    property PowderBlue: TGpPen Index kcPowderBlue read GetDefinePen;
    property Purple: TGpPen Index kcPurple read GetDefinePen;
    property Red: TGpPen Index kcRed read GetDefinePen;
    property RosyBrown: TGpPen Index kcRosyBrown read GetDefinePen;
    property RoyalBlue: TGpPen Index kcRoyalBlue read GetDefinePen;
    property SaddleBrown: TGpPen Index kcSaddleBrown read GetDefinePen;
    property Salmon: TGpPen Index kcSalmon read GetDefinePen;
    property SandyBrown: TGpPen Index kcSandyBrown read GetDefinePen;
    property SeaGreen: TGpPen Index kcSeaGreen read GetDefinePen;
    property SeaShell: TGpPen Index kcSeaShell read GetDefinePen;
    property Sienna: TGpPen Index kcSienna read GetDefinePen;
    property Silver: TGpPen Index kcSilver read GetDefinePen;
    property SkyBlue: TGpPen Index kcSkyBlue read GetDefinePen;
    property SlateBlue: TGpPen Index kcSlateBlue read GetDefinePen;
    property SlateGray: TGpPen Index kcSlateGray read GetDefinePen;
    property Snow: TGpPen Index kcSnow read GetDefinePen;
    property SpringGreen: TGpPen Index kcSpringGreen read GetDefinePen;
    property SteelBlue: TGpPen Index kcSteelBlue read GetDefinePen;
    property Tan: TGpPen Index kcTan read GetDefinePen;
    property Teal: TGpPen Index kcTeal read GetDefinePen;
    property Thistle: TGpPen Index kcThistle read GetDefinePen;
    property Tomato: TGpPen Index kcTomato read GetDefinePen;
    property Transparent: TGpPen Index kcTransparent read GetDefinePen;
    property Turquoise: TGpPen Index kcTurquoise read GetDefinePen;
    property Violet: TGpPen Index kcViolet read GetDefinePen;
    property Wheat: TGpPen Index kcWheat read GetDefinePen;
    property White: TGpPen Index kcWhite read GetDefinePen;
    property WhiteSmoke: TGpPen Index kcWhiteSmoke read GetDefinePen;
    property Yellow: TGpPen Index kcYellow read GetDefinePen;
    property YellowGreen: TGpPen Index kcYellowGreen read GetDefinePen;
  end;

  TBrushs = class
  private
    FBrush: TGpBrush;
    FColor: TARGB;
    function GetDefineBrush(const Index: Integer): TGpBrush;
    function GetBrush(AColor: TARGB): TGpBrush;
  public
    constructor Create;
    destructor Destroy; override;

    property Brush[AColor: TARGB]: TGpBrush read GetBrush; default;
    property AliceBlue: TGpBrush Index kcAliceBlue read GetDefineBrush;
    property AntiqueWhite: TGpBrush Index kcAntiqueWhite read GetDefineBrush;
    property Aqua: TGpBrush Index kcAqua read GetDefineBrush;
    property Aquamarine: TGpBrush Index kcAquamarine read GetDefineBrush;
    property Azure: TGpBrush Index kcAzure read GetDefineBrush;
    property Beige: TGpBrush Index kcBeige read GetDefineBrush;
    property Bisque: TGpBrush Index kcBisque read GetDefineBrush;
    property Black: TGpBrush Index kcBlack read GetDefineBrush;
    property BlanchedAlmond: TGpBrush Index kcBlanchedAlmond read GetDefineBrush;
    property Blue: TGpBrush Index kcBlue read GetDefineBrush;
    property BlueViolet: TGpBrush Index kcBlueViolet read GetDefineBrush;
    property Brown: TGpBrush Index kcBrown read GetDefineBrush;
    property BurlyWood: TGpBrush Index kcBurlyWood read GetDefineBrush;
    property CadetBlue: TGpBrush Index kcCadetBlue read GetDefineBrush;
    property Chartreuse: TGpBrush Index kcChartreuse read GetDefineBrush;
    property Chocolate: TGpBrush Index kcChocolate read GetDefineBrush;
    property Coral: TGpBrush Index kcCoral read GetDefineBrush;
    property CornflowerBlue: TGpBrush Index kcCornflowerBlue read GetDefineBrush;
    property Cornsilk: TGpBrush Index kcCornsilk read GetDefineBrush;
    property Crimson: TGpBrush Index kcCrimson read GetDefineBrush;
    property Cyan: TGpBrush Index kcCyan read GetDefineBrush;
    property DarkBlue: TGpBrush Index kcDarkBlue read GetDefineBrush;
    property DarkCyan: TGpBrush Index kcDarkCyan read GetDefineBrush;
    property DarkGoldenrod: TGpBrush Index kcDarkGoldenrod read GetDefineBrush;
    property DarkGray: TGpBrush Index kcDarkGray read GetDefineBrush;
    property DarkGreen: TGpBrush Index kcDarkGreen read GetDefineBrush;
    property DarkKhaki: TGpBrush Index kcDarkKhaki read GetDefineBrush;
    property DarkMagenta: TGpBrush Index kcDarkMagenta read GetDefineBrush;
    property DarkOliveGreen: TGpBrush Index kcDarkOliveGreen read GetDefineBrush;
    property DarkOrange: TGpBrush Index kcDarkOrange read GetDefineBrush;
    property DarkOrchid: TGpBrush Index kcDarkOrchid read GetDefineBrush;
    property DarkRed: TGpBrush Index kcDarkRed read GetDefineBrush;
    property DarkSalmon: TGpBrush Index kcDarkSalmon read GetDefineBrush;
    property DarkSeaGreen: TGpBrush Index kcDarkSeaGreen read GetDefineBrush;
    property DarkSlateBlue: TGpBrush Index kcDarkSlateBlue read GetDefineBrush;
    property DarkSlateGray: TGpBrush Index kcDarkSlateGray read GetDefineBrush;
    property DarkTurquoise: TGpBrush Index kcDarkTurquoise read GetDefineBrush;
    property DarkViolet: TGpBrush Index kcDarkViolet read GetDefineBrush;
    property DeepPink: TGpBrush Index kcDeepPink read GetDefineBrush;
    property DeepSkyBlue: TGpBrush Index kcDeepSkyBlue read GetDefineBrush;
    property DimGray: TGpBrush Index kcDimGray read GetDefineBrush;
    property DodgerBlue: TGpBrush Index kcDodgerBlue read GetDefineBrush;
    property Firebrick: TGpBrush Index kcFirebrick read GetDefineBrush;
    property FloralWhite: TGpBrush Index kcFloralWhite read GetDefineBrush;
    property ForestGreen: TGpBrush Index kcForestGreen read GetDefineBrush;
    property Fuchsia: TGpBrush Index kcFuchsia read GetDefineBrush;
    property Gainsboro: TGpBrush Index kcGainsboro read GetDefineBrush;
    property GhostWhite: TGpBrush Index kcGhostWhite read GetDefineBrush;
    property Gold: TGpBrush Index kcGold read GetDefineBrush;
    property Goldenrod: TGpBrush Index kcGoldenrod read GetDefineBrush;
    property Gray: TGpBrush Index kcGray read GetDefineBrush;
    property Green: TGpBrush Index kcGreen read GetDefineBrush;
    property GreenYellow: TGpBrush Index kcGreenYellow read GetDefineBrush;
    property Honeydew: TGpBrush Index kcHoneydew read GetDefineBrush;
    property HotPink: TGpBrush Index kcHotPink read GetDefineBrush;
    property IndianRed: TGpBrush Index kcIndianRed read GetDefineBrush;
    property Indigo: TGpBrush Index kcIndigo read GetDefineBrush;
    property Ivory: TGpBrush Index kcIvory read GetDefineBrush;
    property Khaki: TGpBrush Index kcKhaki read GetDefineBrush;
    property Lavender: TGpBrush Index kcLavender read GetDefineBrush;
    property LavenderBlush: TGpBrush Index kcLavenderBlush read GetDefineBrush;
    property LawnGreen: TGpBrush Index kcLawnGreen read GetDefineBrush;
    property LemonChiffon: TGpBrush Index kcLemonChiffon read GetDefineBrush;
    property LightBlue: TGpBrush Index kcLightBlue read GetDefineBrush;
    property LightCoral: TGpBrush Index kcLightCoral read GetDefineBrush;
    property LightCyan: TGpBrush Index kcLightCyan read GetDefineBrush;
    property LightGoldenrodYellow: TGpBrush Index kcLightGoldenrodYellow read GetDefineBrush;
    property LightGray: TGpBrush Index kcLightGray read GetDefineBrush;
    property LightGreen: TGpBrush Index kcLightGreen read GetDefineBrush;
    property LightPink: TGpBrush Index kcLightPink read GetDefineBrush;
    property LightSalmon: TGpBrush Index kcLightSalmon read GetDefineBrush;
    property LightSeaGreen: TGpBrush Index kcLightSeaGreen read GetDefineBrush;
    property LightSkyBlue: TGpBrush Index kcLightSkyBlue read GetDefineBrush;
    property LightSlateGray: TGpBrush Index kcLightSlateGray read GetDefineBrush;
    property LightSteelBlue: TGpBrush Index kcLightSteelBlue read GetDefineBrush;
    property LightYellow: TGpBrush Index kcLightYellow read GetDefineBrush;
    property Lime: TGpBrush Index kcLime read GetDefineBrush;
    property LimeGreen: TGpBrush Index kcLimeGreen read GetDefineBrush;
    property Linen: TGpBrush Index kcLinen read GetDefineBrush;
    property Magenta: TGpBrush Index kcMagenta read GetDefineBrush;
    property Maroon: TGpBrush Index kcMaroon read GetDefineBrush;
    property MediumAquamarine: TGpBrush Index kcMediumAquamarine read GetDefineBrush;
    property MediumBlue: TGpBrush Index kcMediumBlue read GetDefineBrush;
    property MediumOrchid: TGpBrush Index kcMediumOrchid read GetDefineBrush;
    property MediumPurple: TGpBrush Index kcMediumPurple read GetDefineBrush;
    property MediumSeaGreen: TGpBrush Index kcMediumSeaGreen read GetDefineBrush;
    property MediumSlateBlue: TGpBrush Index kcMediumSlateBlue read GetDefineBrush;
    property MediumSpringGreen: TGpBrush Index kcMediumSpringGreen read GetDefineBrush;
    property MediumTurquoise: TGpBrush Index kcMediumTurquoise read GetDefineBrush;
    property MediumVioletRed: TGpBrush Index kcMediumVioletRed read GetDefineBrush;
    property MidnightBlue: TGpBrush Index kcMidnightBlue read GetDefineBrush;
    property MintCream: TGpBrush Index kcMintCream read GetDefineBrush;
    property MistyRose: TGpBrush Index kcMistyRose read GetDefineBrush;
    property Moccasin: TGpBrush Index kcMoccasin read GetDefineBrush;
    property NavajoWhite: TGpBrush Index kcNavajoWhite read GetDefineBrush;
    property Navy: TGpBrush Index kcNavy read GetDefineBrush;
    property OldLace: TGpBrush Index kcOldLace read GetDefineBrush;
    property Olive: TGpBrush Index kcOlive read GetDefineBrush;
    property OliveDrab: TGpBrush Index kcOliveDrab read GetDefineBrush;
    property Orange: TGpBrush Index kcOrange read GetDefineBrush;
    property OrangeRed: TGpBrush Index kcOrangeRed read GetDefineBrush;
    property Orchid: TGpBrush Index kcOrchid read GetDefineBrush;
    property PaleGoldenrod: TGpBrush Index kcPaleGoldenrod read GetDefineBrush;
    property PaleGreen: TGpBrush Index kcPaleGreen read GetDefineBrush;
    property PaleTurquoise: TGpBrush Index kcPaleTurquoise read GetDefineBrush;
    property PaleVioletRed: TGpBrush Index kcPaleVioletRed read GetDefineBrush;
    property PapayaWhip: TGpBrush Index kcPapayaWhip read GetDefineBrush;
    property PeachPuff: TGpBrush Index kcPeachPuff read GetDefineBrush;
    property Peru: TGpBrush Index kcPeru read GetDefineBrush;
    property Pink: TGpBrush Index kcPink read GetDefineBrush;
    property Plum: TGpBrush Index kcPlum read GetDefineBrush;
    property PowderBlue: TGpBrush Index kcPowderBlue read GetDefineBrush;
    property Purple: TGpBrush Index kcPurple read GetDefineBrush;
    property Red: TGpBrush Index kcRed read GetDefineBrush;
    property RosyBrown: TGpBrush Index kcRosyBrown read GetDefineBrush;
    property RoyalBlue: TGpBrush Index kcRoyalBlue read GetDefineBrush;
    property SaddleBrown: TGpBrush Index kcSaddleBrown read GetDefineBrush;
    property Salmon: TGpBrush Index kcSalmon read GetDefineBrush;
    property SandyBrown: TGpBrush Index kcSandyBrown read GetDefineBrush;
    property SeaGreen: TGpBrush Index kcSeaGreen read GetDefineBrush;
    property SeaShell: TGpBrush Index kcSeaShell read GetDefineBrush;
    property Sienna: TGpBrush Index kcSienna read GetDefineBrush;
    property Silver: TGpBrush Index kcSilver read GetDefineBrush;
    property SkyBlue: TGpBrush Index kcSkyBlue read GetDefineBrush;
    property SlateBlue: TGpBrush Index kcSlateBlue read GetDefineBrush;
    property SlateGray: TGpBrush Index kcSlateGray read GetDefineBrush;
    property Snow: TGpBrush Index kcSnow read GetDefineBrush;
    property SpringGreen: TGpBrush Index kcSpringGreen read GetDefineBrush;
    property SteelBlue: TGpBrush Index kcSteelBlue read GetDefineBrush;
    property Tan: TGpBrush Index kcTan read GetDefineBrush;
    property Teal: TGpBrush Index kcTeal read GetDefineBrush;
    property Thistle: TGpBrush Index kcThistle read GetDefineBrush;
    property Tomato: TGpBrush Index kcTomato read GetDefineBrush;
    property Transparent: TGpBrush Index kcTransparent read GetDefineBrush;
    property Turquoise: TGpBrush Index kcTurquoise read GetDefineBrush;
    property Violet: TGpBrush Index kcViolet read GetDefineBrush;
    property Wheat: TGpBrush Index kcWheat read GetDefineBrush;
    property White: TGpBrush Index kcWhite read GetDefineBrush;
    property WhiteSmoke: TGpBrush Index kcWhiteSmoke read GetDefineBrush;
    property Yellow: TGpBrush Index kcYellow read GetDefineBrush;
    property YellowGreen: TGpBrush Index kcYellowGreen read GetDefineBrush;
  end;

function Pens: TPens;
function Brushs: TBrushs;

type
  TImageCodecInfo = GdipTypes.TImageCodecInfo;
  PImageCodecInfo = GdipTypes.PImageCodecInfo;

function ARGBToString(Argb: TARGB): string;
function StringToARGB(const S: string; Alpha: BYTE = 255): TARGB;
procedure GetARGBValues(Proc: TGetStrProc);
function ARGBToIdent(Argb: Longint; var Ident: string): Boolean;
function IdentToARGB(const Ident: string; var Argb: Longint): Boolean;

function ARGB(r, g, b: BYTE): TARGB; overload;
function ARGB(a, r, g, b: BYTE): TARGB; overload;
function ARGB(a: Byte; Argb: TARGB): TARGB; overload;

function ARGBToCOLORREF(Argb: TARGB): Longint;
function ARGBToColor(Argb: TARGB): Vcl.Graphics.TColor;
function ARGBFromCOLORREF(Rgb: Longint): TARGB; overload;
function ARGBFromCOLORREF(Alpha: Byte; Rgb: Longint): TARGB; overload;
function ARGBFromTColor(Color: Vcl.Graphics.TColor): TARGB; overload;
function ARGBFromTColor(Alpha: Byte; Color: Vcl.Graphics.TColor): TARGB; overload;

function GpSize(const Width, Height: TREAL): TGpSizeF; overload;
function GpSize(const Width, Height: Integer): TGpSize; overload;

function GpPoint(const x, y: TREAL): TGpPointF; overload;
function GpPoint(const x, y: Integer): TGpPoint; overload;
function GpPoint(const pt: WinApi.Windows.TPoint): TGpPoint; overload;

function GpRect(const x, y, Width, Height: TREAL): TGpRectF; overload;
function GpRect(const pt: TGpPointF; const sz: TGpSizeF): TGpRectF; overload;
function GpRect(const x, y, Width, Height: INT): TGpRect; overload;
function GpRect(const pt: TGpPoint; const sz: TGpSize): TGpRect; overload;
function GpRect(const r: WinApi.Windows.TRect): TGpRect; overload;
// 是否空
function Empty(const sz: TGpSizeF): Boolean; overload;
function Empty(const sz: TGpSize): Boolean; overload;
// 相等
function Equals(const sz1, sz2: TGpSizeF): Boolean; overload;
function Equals(const sz1, sz2: TGpSize): Boolean; overload;
function Equals(const pt1, pt2: TGpPointF): Boolean; overload;
function Equals(const pt1, pt2: TGpPoint): Boolean; overload;
function Equals(const rc1, rc2: TGpRectF): Boolean; overload;
function Equals(const rc1, rc2: TGpRect): Boolean; overload;
// 包含
function Contains(const rc: TGpRectF; const pt: TGpPointF): Boolean; overload;
function Contains(const rc: TGpRect; const pt: TGpPoint): Boolean; overload;
function Contains(const rc: TGpRectF; const x, y: TREAL): Boolean; overload;
function Contains(const rc: TGpRect; const x, y: INT): Boolean; overload;
function Contains(const rc, rc2: TGpRectF): Boolean; overload;
function Contains(const rc, rc2: TGpRect): Boolean; overload;
// 扩展
procedure Inflate(var rc: TGpRectF; const dx, dy: TREAL); overload;
procedure Inflate(var rc: TGpRect; const dx, dy: INT); overload;
procedure Inflate(var rc: TGpRectF; const point: TGpPointF); overload;
procedure Inflate(var rc: TGpRect; const point: TGpPoint); overload;
// 取两个区域交集到dest
function Intersect(var dest: TGpRectF; const a, b: TGpRectF): Boolean; overload;
function Intersect(var dest: TGpRect; const a, b: TGpRect): Boolean; overload;
function Intersect(var dest: TGpRectF; const rc: TGpRectF): Boolean; overload;
function Intersect(var dest: TGpRect; const rc: TGpRect): Boolean; overload;
// 相交
function IntersectsWith(const rc1, rc2: TGpRectF): Boolean; overload;
function IntersectsWith(const rc1, rc2: TGpRect): Boolean; overload;
// 是否空区域
function IsEmptyArea(const rc: TGpRectF): Boolean; overload;
function IsEmptyArea(const rc: TGpRect): Boolean; overload;
// 移动区域
procedure Offset(var p: TGpPointF; const dx, dy: TREAL); overload;
procedure Offset(var p: TGpPoint; const dx, dy: INT); overload;
procedure Offset(var rc: TGpRectF; const dx, dy: TREAL); overload;
procedure Offset(var rc: TGpRect; const dx, dy: INT); overload;
procedure Offset(var rc: TGpRectF; const point: TGpPointF); overload;
procedure Offset(var rc: TGpRect; const point: TGpPoint); overload;
// 取两个区域并集到dest
function Union(var dest: TGpRectF; const a, b: TGpRectF): Boolean; overload;
function Union(var dest: TGpRect; const a, b: TGpRect): Boolean; overload;
function Union(var dest: TGpRectF; const rc: TGpRectF): Boolean; overload;
function Union(var dest: TGpRect; const rc: TGpRect): Boolean; overload;
//--------------------------------------------------------------------------
// Codec Management APIs
//--------------------------------------------------------------------------

function GetImageDecodersSize(var numDecoders, size: Integer): TStatus;
function GetImageDecoders(numDecoders, size: Integer; decoders: PImageCodecInfo): TStatus;
function GetImageEncodersSize(var numEncoders, size: Integer): TStatus;
function GetImageEncoders(numEncoders, size: Integer; encoders: PImageCodecInfo): TStatus;
function GetEncoderClsid(format: WideString; var Clsid: TGUID): Boolean;

implementation

uses GdipExport;

type
  ResValue = packed record
    case Integer of
      0: (rBOOL: BOOL);
      1: (rINT: Integer);
      2: (rCOLOR: TARGB);
      3: (rPOINTER: Pointer);
      4: (rBYTE: Byte);
    end;

  TGdipGenerics = class
  private
    FGenericObject: array[1..5] of TGdiplusBase;
  public
    procedure GenericNil(Item: TGdiplusBase);
    property GenericSansSerifFontFamily: TGdiplusBase read FGenericObject[1] write FGenericObject[1];
    property GenericSerifFontFamily: TGdiplusBase read FGenericObject[2] write FGenericObject[2];
    property GenericMonospaceFontFamily: TGdiplusBase read FGenericObject[3] write FGenericObject[3];
    property GenericTypographicStringFormatBuffer: TGdiplusBase read FGenericObject[4] write FGenericObject[4];
    property GenericDefaultStringFormatBuffer: TGdiplusBase read FGenericObject[5] write FGenericObject[5];
  end;

{ TGdipGenerics }

procedure TGdipGenerics.GenericNil(Item: TGdiplusBase);
var
  I: Integer;
begin
  for I := 1 to 5 do
    if Item = FGenericObject[I] then
    begin
      FGenericObject[I] := nil;
      Break;
    end;
end;

const
{$WARNINGS OFF}
  KnownColors: array[0..140] of TIdentMapEntry = (
    (Value: kcAliceBlue; Name: 'kcAliceBlue'),
    (Value: kcAntiqueWhite; Name: 'kcAntiqueWhite'),
    (Value: kcAqua; Name: 'kcAqua'),
    (Value: kcAquamarine; Name: 'kcAquamarine'),
    (Value: kcAzure; Name: 'kcAzure'),
    (Value: kcBeige; Name: 'kcBeige'),
    (Value: kcBisque; Name: 'kcBisque'),
    (Value: kcBlack; Name: 'kcBlack'),
    (Value: kcBlanchedAlmond; Name: 'kcBlanchedAlmond'),
    (Value: kcBlue; Name: 'kcBlue'),
    (Value: kcBlueViolet; Name: 'kcBlueViolet'),
    (Value: kcBrown; Name: 'kcBrown'),
    (Value: kcBurlyWood; Name: 'kcBurlyWood'),
    (Value: kcCadetBlue; Name: 'kcCadetBlue'),
    (Value: kcChartreuse; Name: 'kcChartreuse'),
    (Value: kcChocolate; Name: 'kcChocolate'),
    (Value: kcCoral; Name: 'kcCoral'),
    (Value: kcCornflowerBlue; Name: 'kcCornflowerBlue'),
    (Value: kcCornsilk; Name: 'kcCornsilk'),
    (Value: kcCrimson; Name: 'kcCrimson'),
    (Value: kcCyan; Name: 'kcCyan'),
    (Value: kcDarkBlue; Name: 'kcDarkBlue'),
    (Value: kcDarkCyan; Name: 'kcDarkCyan'),
    (Value: kcDarkGoldenrod; Name: 'kcDarkGoldenrod'),
    (Value: kcDarkGray; Name: 'kcDarkGray'),
    (Value: kcDarkGreen; Name: 'kcDarkGreen'),
    (Value: kcDarkKhaki; Name: 'kcDarkKhaki'),
    (Value: kcDarkMagenta; Name: 'kcDarkMagenta'),
    (Value: kcDarkOliveGreen; Name: 'kcDarkOliveGreen'),
    (Value: kcDarkOrange; Name: 'kcDarkOrange'),
    (Value: kcDarkOrchid; Name: 'kcDarkOrchid'),
    (Value: kcDarkRed; Name: 'kcDarkRed'),
    (Value: kcDarkSalmon; Name: 'kcDarkSalmon'),
    (Value: kcDarkSeaGreen; Name: 'kcDarkSeaGreen'),
    (Value: kcDarkSlateBlue; Name: 'kcDarkSlateBlue'),
    (Value: kcDarkSlateGray; Name: 'kcDarkSlateGray'),
    (Value: kcDarkTurquoise; Name: 'kcDarkTurquoise'),
    (Value: kcDarkViolet; Name: 'kcDarkViolet'),
    (Value: kcDeepPink; Name: 'kcDeepPink'),
    (Value: kcDeepSkyBlue; Name: 'kcDeepSkyBlue'),
    (Value: kcDimGray; Name: 'kcDimGray'),
    (Value: kcDodgerBlue; Name: 'kcDodgerBlue'),
    (Value: kcFirebrick; Name: 'kcFirebrick'),
    (Value: kcFloralWhite; Name: 'kcFloralWhite'),
    (Value: kcForestGreen; Name: 'kcForestGreen'),
    (Value: kcFuchsia; Name: 'kcFuchsia'),
    (Value: kcGainsboro; Name: 'kcGainsboro'),
    (Value: kcGhostWhite; Name: 'kcGhostWhite'),
    (Value: kcGold; Name: 'kcGold'),
    (Value: kcGoldenrod; Name: 'kcGoldenrod'),
    (Value: kcGray; Name: 'kcGray'),
    (Value: kcGreen; Name: 'kcGreen'),
    (Value: kcGreenYellow; Name: 'kcGreenYellow'),
    (Value: kcHoneydew; Name: 'kcHoneydew'),
    (Value: kcHotPink; Name: 'kcHotPink'),
    (Value: kcIndianRed; Name: 'kcIndianRed'),
    (Value: kcIndigo; Name: 'kcIndigo'),
    (Value: kcIvory; Name: 'kcIvory'),
    (Value: kcKhaki; Name: 'kcKhaki'),
    (Value: kcLavender; Name: 'kcLavender'),
    (Value: kcLavenderBlush; Name: 'kcLavenderBlush'),
    (Value: kcLawnGreen; Name: 'kcLawnGreen'),
    (Value: kcLemonChiffon; Name: 'kcLemonChiffon'),
    (Value: kcLightBlue; Name: 'kcLightBlue'),
    (Value: kcLightCoral; Name: 'kcLightCoral'),
    (Value: kcLightCyan; Name: 'kcLightCyan'),
    (Value: kcLightGoldenrodYellow; Name: 'kcLightGoldenrodYellow'),
    (Value: kcLightGray; Name: 'kcLightGray'),
    (Value: kcLightGreen; Name: 'kcLightGreen'),
    (Value: kcLightPink; Name: 'kcLightPink'),
    (Value: kcLightSalmon; Name: 'kcLightSalmon'),
    (Value: kcLightSeaGreen; Name: 'kcLightSeaGreen'),
    (Value: kcLightSkyBlue; Name: 'kcLightSkyBlue'),
    (Value: kcLightSlateGray; Name: 'kcLightSlateGray'),
    (Value: kcLightSteelBlue; Name: 'kcLightSteelBlue'),
    (Value: kcLightYellow; Name: 'kcLightYellow'),
    (Value: kcLime; Name: 'kcLime'),
    (Value: kcLimeGreen; Name: 'kcLimeGreen'),
    (Value: kcLinen; Name: 'kcLinen'),
    (Value: kcMagenta; Name: 'kcMagenta'),
    (Value: kcMaroon; Name: 'kcMaroon'),
    (Value: kcMediumAquamarine; Name: 'kcMediumAquamarine'),
    (Value: kcMediumBlue; Name: 'kcMediumBlue'),
    (Value: kcMediumOrchid; Name: 'kcMediumOrchid'),
    (Value: kcMediumPurple; Name: 'kcMediumPurple'),
    (Value: kcMediumSeaGreen; Name: 'kcMediumSeaGreen'),
    (Value: kcMediumSlateBlue; Name: 'kcMediumSlateBlue'),
    (Value: kcMediumSpringGreen; Name: 'kcMediumSpringGreen'),
    (Value: kcMediumTurquoise; Name: 'kcMediumTurquoise'),
    (Value: kcMediumVioletRed; Name: 'kcMediumVioletRed'),
    (Value: kcMidnightBlue; Name: 'kcMidnightBlue'),
    (Value: kcMintCream; Name: 'kcMintCream'),
    (Value: kcMistyRose; Name: 'kcMistyRose'),
    (Value: kcMoccasin; Name: 'kcMoccasin'),
    (Value: kcNavajoWhite; Name: 'kcNavajoWhite'),
    (Value: kcNavy; Name: 'kcNavy'),
    (Value: kcOldLace; Name: 'kcOldLace'),
    (Value: kcOlive; Name: 'kcOlive'),
    (Value: kcOliveDrab; Name: 'kcOliveDrab'),
    (Value: kcOrange; Name: 'kcOrange'),
    (Value: kcOrangeRed; Name: 'kcOrangeRed'),
    (Value: kcOrchid; Name: 'kcOrchid'),
    (Value: kcPaleGoldenrod; Name: 'kcPaleGoldenrod'),
    (Value: kcPaleGreen; Name: 'kcPaleGreen'),
    (Value: kcPaleTurquoise; Name: 'kcPaleTurquoise'),
    (Value: kcPaleVioletRed; Name: 'kcPaleVioletRed'),
    (Value: kcPapayaWhip; Name: 'kcPapayaWhip'),
    (Value: kcPeachPuff; Name: 'kcPeachPuff'),
    (Value: kcPeru; Name: 'kcPeru'),
    (Value: kcPink; Name: 'kcPink'),
    (Value: kcPlum; Name: 'kcPlum'),
    (Value: kcPowderBlue; Name: 'kcPowderBlue'),
    (Value: kcPurple; Name: 'kcPurple'),
    (Value: kcRed; Name: 'kcRed'),
    (Value: kcRosyBrown; Name: 'kcRosyBrown'),
    (Value: kcRoyalBlue; Name: 'kcRoyalBlue'),
    (Value: kcSaddleBrown; Name: 'kcSaddleBrown'),
    (Value: kcSalmon; Name: 'kcSalmon'),
    (Value: kcSandyBrown; Name: 'kcSandyBrown'),
    (Value: kcSeaGreen; Name: 'kcSeaGreen'),
    (Value: kcSeaShell; Name: 'kcSeaShell'),
    (Value: kcSienna; Name: 'kcSienna'),
    (Value: kcSilver; Name: 'kcSilver'),
    (Value: kcSkyBlue; Name: 'kcSkyBlue'),
    (Value: kcSlateBlue; Name: 'kcSlateBlue'),
    (Value: kcSlateGray; Name: 'kcSlateGray'),
    (Value: kcSnow; Name: 'kcSnow'),
    (Value: kcSpringGreen; Name: 'kcSpringGreen'),
    (Value: kcSteelBlue; Name: 'kcSteelBlue'),
    (Value: kcTan; Name: 'kcTan'),
    (Value: kcTeal; Name: 'kcTeal'),
    (Value: kcThistle; Name: 'kcThistle'),
    (Value: kcTomato; Name: 'kcTomato'),
    (Value: kcTransparent; Name: 'kcTransparent'),
    (Value: kcTurquoise; Name: 'kcTurquoise'),
    (Value: kcViolet; Name: 'kcViolet'),
    (Value: kcWheat; Name: 'kcWheat'),
    (Value: kcWhite; Name: 'kcWhite'),
    (Value: kcWhiteSmoke; Name: 'kcWhiteSmoke'),
    (Value: kcYellow; Name: 'kcYellow'),
    (Value: kcYellowGreen; Name: 'kcYellowGreen')
  );
{$WARNINGS ON}

var
  GdiplusStartupInput: TGdiplusStartupInput;
  gdipToken: DWord;
  FGdipGenerics: TGdipGenerics;
  FPens: TPens;
  FBrushs: TBrushs;
  RV: ResValue;

procedure CheckStatus(Status: TStatus);
begin
  if Status <> Ok then
    raise EGdiplusException.CreateStatus(Status);
end;

function ObjectNative(GpObject: TGdiplusBase): GpNative;
begin
  if Assigned(GpObject) then Result := GpObject.Native
  else Result := nil;
end;

{ TGdiplusBase }

constructor TGdiplusBase.Create;
begin
  CheckStatus(NotImplemented);
end;

constructor TGdiplusBase.CreateClone(SrcNative: GpNative; clonefunc: TCloneAPI);
begin
  if Assigned(clonefunc) then
    CheckStatus(cloneFunc(SrcNative, FNative))
  else FNative := SrcNative;
end;

procedure TGdiplusBase.FreeInstance;
begin
  CleanupInstance;
  GdipFree(Self);
end;

class function TGdiplusBase.NewInstance: TObject;
begin
  Result := InitInstance(GdipAlloc(ULONG(instanceSize)));
end;

{ TGpMatrix }

function TGpMatrix.Clone: TGpMatrix;
begin
  Result := TGpMatrix.CreateClone(Native, @GdipCloneMatrix);
end;

constructor TGpMatrix.Create(m11, m12, m21, m22, dx, dy: Single);
begin
  CheckStatus(GdipCreateMatrix2(m11, m12, m21, m22, dx, dy, FNative));
end;

constructor TGpMatrix.Create;
begin
  CheckStatus(GdipCreateMatrix(FNative));
end;

constructor TGpMatrix.Create(rect: TGpRect; dstplg: array of TGpPoint);
begin
  CheckStatus(GdipCreateMatrix3I(@rect, @dstplg, FNative));
end;

constructor TGpMatrix.Create(rect: TGpRectF; dstplg: array of TGpPointF);
begin
  CheckStatus(GdipCreateMatrix3(@rect, @dstplg, FNative));
end;

destructor TGpMatrix.Destroy;
begin
  GdipDeleteMatrix(Native);
end;

function TGpMatrix.Equals(const matrix: TGpMatrix): Boolean;
begin
  CheckStatus(GdipIsMatrixEqual(Native, matrix.Native, RV.rBOOL));
  Result := RV.rBOOL;
end;

function TGpMatrix.GetElements: TMatrixElements;
begin
  CheckStatus(GdipGetMatrixElements(Native, @Result.Elements));
end;

function TGpMatrix.GetIdentity: Boolean;
begin
  CheckStatus(GdipIsMatrixIdentity(Native, RV.rBOOL));
  Result := RV.rBOOL;
end;

function TGpMatrix.GetInvertible: Boolean;
begin
  CheckStatus(GdipIsMatrixInvertible(Native, RV.rBOOL));
  Result := RV.rBOOL;
end;

function TGpMatrix.GetOffsetX: Single;
begin
  Result := Elements.dx;
end;

function TGpMatrix.GetOffsetY: Single;
begin
  Result := Elements.dy;
end;

procedure TGpMatrix.Invert;
begin
 CheckStatus(GdipInvertMatrix(Native));
end;

procedure TGpMatrix.Multiply(const matrix: TGpMatrix; order: TMatrixOrder);
begin
  CheckStatus(GdipMultiplyMatrix(Native, matrix.Native, GdipTypes.TMatrixOrder(order)));
end;

procedure TGpMatrix.Reset;
begin
  CheckStatus(GdipSetMatrixElements(Native, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0));
end;

procedure TGpMatrix.Rotate(angle: Single; order: TMatrixOrder);
begin
  CheckStatus(GdipRotateMatrix(Native, angle, GdipTypes.TMatrixOrder(order)));
end;

procedure TGpMatrix.RotateAt(angle: Single; const center: TGpPointF; order: TMatrixOrder);
begin
  if order = moPrepend then
  begin
    CheckStatus(GdipTranslateMatrix(Native, center.X, center.Y, GdipTypes.TMatrixOrder(order)));
    CheckStatus(GdipRotateMatrix(Native, angle, GdipTypes.TMatrixOrder(order)));
    CheckStatus(GdipTranslateMatrix(Native, -center.X, -center.Y, GdipTypes.TMatrixOrder(order)));
  end else
  begin
    CheckStatus(GdipTranslateMatrix(Native, -center.X, -center.Y, GdipTypes.TMatrixOrder(order)));
    CheckStatus(GdipRotateMatrix(Native, angle, GdipTypes.TMatrixOrder(order)));
    CheckStatus(GdipTranslateMatrix(Native, center.X, center.Y, GdipTypes.TMatrixOrder(order)));
  end;
end;

procedure TGpMatrix.Scale(scaleX, scaleY: Single; order: TMatrixOrder);
begin
  CheckStatus(GdipScaleMatrix(Native, scaleX, scaleY, GdipTypes.TMatrixOrder(order)));
end;

procedure TGpMatrix.SetElements(const Value: TMatrixElements);
begin
  CheckStatus(GdipSetMatrixElements(Native, Value.m11, Value.m12, Value.m21,
                                    Value.m22, Value.dx, Value.dy));
end;

procedure TGpMatrix.Shear(shearX, shearY: Single; order: TMatrixOrder);
begin
  CheckStatus(GdipShearMatrix(Native, shearX, shearY, GdipTypes.TMatrixOrder(order)));
end;

procedure TGpMatrix.TransformPoints(pts: array of TGpPointF);
begin
  CheckStatus(GdipTransformMatrixPoints(Native, @pts, Length(pts)));
end;

procedure TGpMatrix.TransformPoints(pts: array of TGpPoint);
begin
  CheckStatus(GdipTransformMatrixPointsI(Native, @pts, Length(pts)));
end;

procedure TGpMatrix.TransformVectors(pts: array of TGpPoint);
begin
  CheckStatus(GdipVectorTransformMatrixPointsI(Native, @pts, Length(pts)));
end;

procedure TGpMatrix.TransformVectors(pts: array of TGpPointF);
begin
  CheckStatus(GdipVectorTransformMatrixPoints(Native, @pts, Length(pts)));
end;

procedure TGpMatrix.Translate(offsetX, offsetY: Single; order: TMatrixOrder);
begin
  CheckStatus(GdipTranslateMatrix(Native, offsetX, offsetY, GdipTypes.TMatrixOrder(order)));
end;

{ TGpRegion }

function TGpRegion.Clone: TGpRegion;
begin
  Result := TGpRegion.CreateClone(Native, @GdipCloneRegion);
end;

procedure TGpRegion.Complement(const rect: TGpRectF);
begin
  CheckStatus(GdipCombineRegionRect(Native, @rect, CombineModeComplement));
end;

procedure TGpRegion.Complement(const rect: TGpRect);
begin
  CheckStatus(GdipCombineRegionRectI(Native, @rect, CombineModeComplement));
end;

procedure TGpRegion.Complement(path: TGpGraphicsPath);
begin
  CheckStatus(GdipCombineRegionPath(Native, path.Native, CombineModeComplement));
end;

procedure TGpRegion.Complement(region: TGpRegion);
begin
  CheckStatus(GdipCombineRegionRegion(Native, region.Native, CombineModeComplement));
end;

constructor TGpRegion.Create(rect: TGpRect);
begin
  CheckStatus(GdipCreateRegionRectI(@rect, FNative));
end;

constructor TGpRegion.Create(path: TGpGraphicsPath);
begin
  CheckStatus(GdipCreateRegionPath(path.Native, FNative));
end;

constructor TGpRegion.Create;
begin
  CheckStatus(GdipCreateRegion(FNative));
end;

constructor TGpRegion.Create(rect: TGpRectF);
begin
  CheckStatus(GdipCreateRegionRect(@rect, FNative));
end;

constructor TGpRegion.Create(hrgn: HRGN);
begin
  CheckStatus(GdipCreateRegionHrgn(hRgn, FNative));
end;

constructor TGpRegion.Create(regionData: array of Byte);
begin
  CheckStatus(GdipCreateRegionRgnData(@regionData, Length(regionData), FNative));
end;

destructor TGpRegion.Destroy;
begin
  GdipDeleteRegion(Native);
end;

function TGpRegion.Equals(region: TGpRegion; g: TGpGraphics): Boolean;
begin
  CheckStatus(GdipIsEqualRegion(Native, region.Native, g.Native, RV.rBOOL));
  Result := Rv.rBOOL;
end;

procedure TGpRegion.Exclude(const rect: TGpRect);
begin
  CheckStatus(GdipCombineRegionRectI(Native, @rect, CombineModeExclude));
end;

procedure TGpRegion.Exclude(const rect: TGpRectF);
begin
  CheckStatus(GdipCombineRegionRect(Native, @rect, CombineModeExclude));
end;

procedure TGpRegion.Exclude(region: TGpRegion);
begin
  CheckStatus(GdipCombineRegionRegion(Native, region.Native, CombineModeExclude));
end;

procedure TGpRegion.Exclude(path: TGpGraphicsPath);
begin
  CheckStatus(GdipCombineRegionPath(Native, path.Native, CombineModeExclude))
end;

class function TGpRegion.FromHRGN(hrgn: HRGN): TGpRegion;
begin
  Result := TGpRegion.Create(hrgn);
end;

procedure TGpRegion.GetBounds(var rect: TGpRectF; const g: TGpGraphics);
begin
  CheckStatus(GdipGetRegionBounds(Native, g.Native, @rect));
end;

procedure TGpRegion.GetBounds(var rect: TGpRect; const g: TGpGraphics);
begin
  CheckStatus(GdipGetRegionBoundsI(Native, g.Native, @rect));
end;

procedure TGpRegion.GetData(var buffer: array of Byte; sizeFilled: PLongWord);
begin
  CheckStatus(GdipGetRegionData(Native, @buffer, Length(buffer), PUINT(sizeFilled)));
end;

function TGpRegion.GetDataSize: Integer;
begin
  Result := 0;
  CheckStatus(GdipGetRegionDataSize(Native, Result));
end;

function TGpRegion.GetHRGN(g: TGpGraphics): HRGN;
begin
  CheckStatus(GdipGetRegionHRgn(Native, g.Native, Result));
end;

function TGpRegion.GetRegionScans(matrix: TGpMatrix; var rects: array of TGpRect): Integer;
begin
  CheckStatus(GdipGetRegionScansI(Native, @rects, Result, matrix.Native));
end;

function TGpRegion.GetRegionScans(matrix: TGpMatrix; var rects: array of TGpRectF): Integer;
begin
  CheckStatus(GdipGetRegionScans(Native, @rects, Result, matrix.Native));
end;

function TGpRegion.GetRegionScansCount(matrix: TGpMatrix): Integer;
begin
  Result := 0;
  CheckStatus(GdipGetRegionScansCount(Native, Result, matrix.Native));
end;

procedure TGpRegion.Intersect(path: TGpGraphicsPath);
begin
  CheckStatus(GdipCombineRegionPath(Native, path.Native, CombineModeIntersect));
end;

procedure TGpRegion.Intersect(const rect: TGpRectF);
begin
  CheckStatus(GdipCombineRegionRect(Native, @rect, CombineModeIntersect));
end;

procedure TGpRegion.Intersect(const rect: TGpRect);
begin
  CheckStatus(GdipCombineRegionRectI(Native, @rect, CombineModeIntersect));
end;

procedure TGpRegion.Intersect(region: TGpRegion);
begin
  CheckStatus(GdipCombineRegionRegion(Native, region.Native, CombineModeIntersect));
end;

function TGpRegion.IsEmpty(g: TGpGraphics): Boolean;
begin
  CheckStatus(GdipIsEmptyRegion(Native, g.Native, RV.rBOOL));
  Result := RV.rBOOL;
end;

function TGpRegion.IsInfinite(g: TGpGraphics): Boolean;
begin
  CheckStatus(GdipIsInfiniteRegion(Native, g.Native, RV.rBOOL));
  Result := RV.rBOOL;
end;

function TGpRegion.IsVisible(const rect: TGpRect; g: TGpGraphics): Boolean;
begin
  CheckStatus(GdipIsVisibleRegionRectI(Native, rect.X, rect.Y, rect.Width,
                                       rect.Height, ObjectNative(g), RV.rBOOL));
  Result := RV.rBOOL;
end;

function TGpRegion.IsVisible(x, y, width, height: Integer; g: TGpGraphics): Boolean;
begin
  Result := IsVisible(GpRect(x, y, width, height), g);
end;

function TGpRegion.IsVisible(const rect: TGpRectF; g: TGpGraphics): Boolean;
begin
  CheckStatus(GdipIsVisibleRegionRect(Native, rect.X, rect.Y, rect.Width,
                                      rect.Height, ObjectNative(g), RV.rBOOL));
  Result := RV.rBOOL;
end;

function TGpRegion.IsVisible(x, y, width, height: Single; g: TGpGraphics): Boolean;
begin
  Result := IsVisible(GpRect(x, y, width, height), g);
end;

function TGpRegion.IsVisible(const point: TGpPoint; g: TGpGraphics): Boolean;
begin
  CheckStatus(GdipIsVisibleRegionPointI(Native, point.X, point.Y,
                                        ObjectNative(g), RV.rBOOL));
  Result := RV.rBOOL;
end;

function TGpRegion.IsVisible(x, y: Integer; g: TGpGraphics): Boolean;
begin
  Result := IsVisible(GpPoint(x, y), g);
end;

function TGpRegion.IsVisible(const point: TGpPointF; g: TGpGraphics): Boolean;
begin
  CheckStatus(GdipIsVisibleRegionPoint(Native, point.X, point.Y,
                                       ObjectNative(g), RV.rBOOL));
  Result := RV.rBOOL;
end;

function TGpRegion.IsVisible(x, y: Single; g: TGpGraphics): Boolean;
begin
  Result := IsVisible(GpPoint(x, y), g);
end;

procedure TGpRegion.MakeEmpty;
begin
  CheckStatus(GdipSetEmpty(Native));
end;

procedure TGpRegion.MakeInfinite;
begin
  CheckStatus(GdipSetInfinite(Native));
end;

procedure TGpRegion.Transform(matrix: TGpMatrix);
begin
  CheckStatus(GdipTransformRegion(Native, matrix.Native));
end;

procedure TGpRegion.Translate(dx, dy: Single);
begin
  CheckStatus(GdipTranslateRegion(Native, dx, dy));
end;

procedure TGpRegion.Translate(dx, dy: Integer);
begin
  CheckStatus(GdipTranslateRegionI(Native, dx, dy));
end;

procedure TGpRegion.Union(const rect: TGpRectF);
begin
  CheckStatus(GdipCombineRegionRect(Native, @rect, CombineModeUnion));
end;

procedure TGpRegion.Union(const rect: TGpRect);
begin
  CheckStatus(GdipCombineRegionRectI(Native, @rect, CombineModeUnion));
end;

procedure TGpRegion.Union(path: TGpGraphicsPath);
begin
  CheckStatus(GdipCombineRegionPath(Native, path.Native, CombineModeUnion));
end;

procedure TGpRegion.Union(region: TGpRegion);
begin
  CheckStatus(GdipCombineRegionRegion(Native, region.Native, CombineModeUnion));
end;

procedure TGpRegion.Xor_(path: TGpGraphicsPath);
begin
  CheckStatus(GdipCombineRegionPath(Native, path.Native, CombineModeXor));
end;

procedure TGpRegion.Xor_(region: TGpRegion);
begin
  CheckStatus(GdipCombineRegionRegion(Native, region.Native, CombineModeXor));
end;

procedure TGpRegion.Xor_(const rect: TGpRect);
begin
  CheckStatus(GdipCombineRegionRectI(Native, @rect, CombineModeXor));
end;

procedure TGpRegion.Xor_(const rect: TGpRectF);
begin
  CheckStatus(GdipCombineRegionRect(Native, @rect, CombineModeXor));
end;

type
  TGenericFamily = class(TGpFontFamily)
  public
    procedure FreeInstance; override;
  end;

{ TGenericFamily }

procedure TGenericFamily.FreeInstance;
begin
  FGdipGenerics.GenericNil(Self);
  inherited;
end;

{ TGpFontFamily }

function TGpFontFamily.Clone: TGpFontFamily;
begin
  Result := TGpFontFamily.CreateClone(Native, @GdipCloneFontFamily);
end;

constructor TGpFontFamily.Create(name: WideString; fontCollection: TGpFontCollection);
begin
  CheckStatus(GdipCreateFontFamilyFromName(PWChar(name),
                       ObjectNative(fontCollection), FNative));
end;

constructor TGpFontFamily.Create;
begin

end;

destructor TGpFontFamily.Destroy;
begin
  GdipDeleteFontFamily(Native);
end;

class function TGpFontFamily.GenericMonospace: TGpFontFamily;
begin
  if FGdipGenerics.GenericMonospaceFontFamily = nil then
  begin
    FGdipGenerics.GenericMonospaceFontFamily := TGenericFamily.Create;
    GdipGetGenericFontFamilyMonospace(FGdipGenerics.GenericMonospaceFontFamily.FNative);
  end;
  Result := FGdipGenerics.GenericMonospaceFontFamily as TGpFontFamily;
end;

class function TGpFontFamily.GenericSansSerif: TGpFontFamily;
begin
  if FGdipGenerics.GenericSansSerifFontFamily = nil then
  begin
    FGdipGenerics.GenericSansSerifFontFamily := TGenericFamily.Create;
    GdipGetGenericFontFamilySansSerif(FGdipGenerics.GenericSansSerifFontFamily.FNative);
  end;
  Result := FGdipGenerics.GenericSansSerifFontFamily as TGpFontFamily;
end;

class function TGpFontFamily.GenericSerif: TGpFontFamily;
begin
  if FGdipGenerics.GenericSerifFontFamily = nil then
  begin
    FGdipGenerics.GenericSerifFontFamily := TGenericFamily.Create;
    GdipGetGenericFontFamilySerif(FGdipGenerics.GenericSerifFontFamily.FNative);
  end;
  Result := FGdipGenerics.GenericSerifFontFamily as TGpFontFamily;
end;

function TGpFontFamily.GetCellAscent(style: TFontStyles): Word;
begin
  CheckStatus(GdipGetCellAscent(Native, {FontStyleToInt}Byte(style), Result));
end;

function TGpFontFamily.GetCellDescent(style: TFontStyles): Word;
begin
  CheckStatus(GdipGetCellDescent(Native, Byte(style), Result));
end;

function TGpFontFamily.GetEmHeight(style: TFontStyles): Word;
begin
  CheckStatus(GdipGetEmHeight(Native, Byte(style), Result));
end;

function TGpFontFamily.GetFamilyName(language: LANGID): WideString;
var
  str: array[0..LF_FACESIZE - 1] of WideChar;
begin
  CheckStatus(GdipGetFamilyName(Native, @str, language));
  Result := str;
end;

function TGpFontFamily.GetLineSpacing(style: TFontStyles): Word;
begin
  CheckStatus(GdipGetLineSpacing(Native, Byte(style), Result));
end;

function TGpFontFamily.IsAvailable: Boolean;
begin
  Result := Native <> nil;
end;

function TGpFontFamily.IsStyleAvailable(style: TFontStyles): Boolean;
begin
  CheckStatus(GdipIsStyleAvailable(Native, Byte(style), RV.rBOOL));
  Result := RV.rBOOL;
end;

{ TGpFont }

function TGpFont.Clone: TGpFont;
begin
  Result := TGpFont.CreateClone(Native, @GdipCloneFont);
end;

constructor TGpFont.Create(DC: HDC; font: HFONT);
var
  lf: TLogFontA;
begin
  if (WinApi.Windows.HFONT(font) <> 0) and (GetObjectA(WinApi.Windows.HGDIOBJ(font), sizeof(TLogFontA), @lf) <> 0) then
    CheckStatus(GdipCreateFontFromLogfontA(DC, @lf, FNative))
  else
    CheckStatus(GdipCreateFontFromDC(DC, FNative));
end;

constructor TGpFont.Create(DC: HDC; logfont: PLOGFONTW);
begin
  if logfont <> nil then
    CheckStatus(GdipCreateFontFromLogfontW(DC, logfont, FNative))
  else
    CheckStatus(GdipCreateFontFromDC(DC, FNative));
end;

constructor TGpFont.Create(DC: HDC);
begin
  CheckStatus(GdipCreateFontFromDC(DC, FNative));
end;

constructor TGpFont.Create(DC: HDC; logfont: PLOGFONTA);
begin
  if logfont <> nil then
    CheckStatus(GdipCreateFontFromLogfontA(DC, logfont, FNative))
  else
    CheckStatus(GdipCreateFontFromDC(DC, FNative));
end;

constructor TGpFont.Create(family: TGpFontFamily; emSize: Single;
  style: TFontStyles; unit_: TUnit);
begin
  CheckStatus(GdipCreateFont(ObjectNative(family), emSize, Byte(style), GdipTypes.TUnit(unit_), FNative));
end;

constructor TGpFont.Create(familyName: WideString; emSize: Single;
  style: TFontStyles; unit_: TUnit; fontCollection: TGpFontCollection);
var
  nativeFamily: GpFontFamily;
  Status: TStatus;
  IsFree: Boolean;
  procedure CreateFont;
  begin
    if Status <> Ok then
      nativeFamily := TGpFontFamily.GenericSansSerif.Native;
    if Assigned(nativeFamily) then
      Status := GdipCreateFont(nativeFamily, emSize, Byte(style), GdipTypes.TUnit(unit_), FNative);
  end;
begin
  Status := GdipCreateFontFamilyFromName(PWChar(familyName), ObjectNative(fontCollection), nativeFamily);
  IsFree := Status = Ok;
  CreateFont;
  if Status <> Ok then
    CreateFont;
  if IsFree then
    GdipDeleteFontFamily(nativeFamily)
  else CheckStatus(Status);
end;

destructor TGpFont.Destroy;
begin
  GdipDeleteFont(Native);
end;

procedure TGpFont.GetFamily(family: TGpFontFamily);
begin
  if family = nil then CheckStatus(InvalidParameter);
  CheckStatus(GdipGetFamily(Native, family.FNative));
end;

function TGpFont.GetHeight(dpi: Single): Single;
begin
  CheckStatus(GdipGetFontHeightGivenDPI(Native, dpi, Result));
end;

function TGpFont.GetHeight(graphics: TGpGraphics): Single;
begin
  CheckStatus(GdipGetFontHeight(Native, ObjectNative(graphics), Result));
end;

function TGpFont.GetLogFontA(g: TGpGraphics): TLogFontA;
begin
  CheckStatus(GdipGetLogFontA(Native, ObjectNative(g), @Result));
end;

function TGpFont.GetLogFontW(g: TGpGraphics): TLogFontW;
begin
  CheckStatus(GdipGetLogFontW(Native, ObjectNative(g), @Result));
end;

function TGpFont.GetName: WideString;
var
  str: array[0..LF_FACESIZE - 1] of WideChar;
begin
  GdipGetFamily(Native, RV.rPOINTER);
  CheckStatus(GdipGetFamilyName(RV.rPOINTER, @str, 0));
  Result := str;
end;

function TGpFont.GetSize: Single;
begin
  CheckStatus(GdipGetFontSize(Native, Result));
end;

function TGpFont.GetStyle: TFontStyles;
begin
  CheckStatus(GdipGetFontStyle(Native, RV.rINT));
  Result := TFontStyles(Byte(RV.rINT));
end;

function TGpFont.GetUnit: TUnit;
begin
   CheckStatus(GdipGetFontUnit(Native, GdipTypes.TUnit(RV.rINT)));
   Result := TUnit(RV.rINT);
end;

function TGpFont.IsAvailable: Boolean;
begin
  Result := Assigned(Native);
end;

{ TGpFontCollection }

function TGpFontCollection.GetFamilies(var gpfamilies: array of TGpFontFamily): Integer;
var
  nativeFamilyList: array of GpFontFamily;
  i, numSought: Integer;
begin
  numSought := GetFamilyCount;
  if (numSought <= 0) or (Length(gpfamilies) = 0) then
    CheckStatus(InvalidParameter);
  Result := 0;
  SetLength(nativeFamilyList, numSought);
  CheckStatus(GdipGetFontCollectionFamilyList(Native, numSought, nativeFamilyList, Result));
  for i := 0 to Result - 1 do
    GdipCloneFontFamily(nativeFamilyList[i], gpfamilies[i].FNative);
end;

function TGpFontCollection.GetFamilyCount: Integer;
begin
  CheckStatus(GdipGetFontCollectionFamilyCount(Native, Result));
end;

{ TGpInstalledFontCollection }

constructor TGpInstalledFontCollection.Create;
begin
  CheckStatus(GdipNewInstalledFontCollection(FNative));
end;

{ TGpPrivateFontCollection }

procedure TGpPrivateFontCollection.AddFontFile(const filename: WideString);
begin
  CheckStatus(GdipPrivateAddFontFile(Native, PWideChar(filename)));
end;

procedure TGpPrivateFontCollection.AddMemoryFont(const memory: Pointer; length: Integer);
begin
  CheckStatus(GdipPrivateAddMemoryFont(Native, memory, length));
end;

constructor TGpPrivateFontCollection.Create;
begin
  CheckStatus(GdipNewPrivateFontCollection(FNative));
end;

destructor TGpPrivateFontCollection.Destroy;
begin
  GdipDeletePrivateFontCollection(FNative);
end;

{ TGpImageAttributes }

procedure TGpImageAttributes.ClearBrushRemapTable;
begin
  ClearRemapTable(ctBrush);
end;

procedure TGpImageAttributes.ClearColorKey(catype: TColorAdjustType);
begin
  CheckStatus(GdipSetImageAttributesColorKeys(Native,
      GdipTypes.TColorAdjustType(catype), False, 0, 0));
end;

procedure TGpImageAttributes.ClearColorMatrices(catype: TColorAdjustType);
begin
  CheckStatus(GdipSetImageAttributesColorMatrix(Native, GdipTypes.TColorAdjustType(catype),
                          false, nil, nil, ColorMatrixFlagsDefault));
end;

procedure TGpImageAttributes.ClearColorMatrix(caType: TColorAdjustType);
begin
  CheckStatus(GdipSetImageAttributesColorMatrix(Native, GdipTypes.TColorAdjustType(catype),
                          false, nil, nil, ColorMatrixFlagsDefault));
end;

procedure TGpImageAttributes.ClearGamma(catype: TColorAdjustType);
begin
  CheckStatus(GdipSetImageAttributesGamma(Native, GdipTypes.TColorAdjustType(catype), False, 0.0));
end;

procedure TGpImageAttributes.ClearNoOp(catype: TColorAdjustType);
begin
  CheckStatus(GdipSetImageAttributesNoOp(Native, GdipTypes.TColorAdjustType(catype), False));
end;

procedure TGpImageAttributes.ClearOutputChannel(catype: TColorAdjustType);
begin
  CheckStatus(GdipSetImageAttributesOutputChannel(Native, GdipTypes.TColorAdjustType(catype),
                              False, ColorChannelFlagsLast));
end;

procedure TGpImageAttributes.ClearOutputChannelColorProfile(catype: TColorAdjustType);
begin
  CheckStatus(GdipSetImageAttributesOutputChannelColorProfile(
                          Native, GdipTypes.TColorAdjustType(catype), False, nil));
end;

procedure TGpImageAttributes.ClearRemapTable(catype: TColorAdjustType);
begin
  CheckStatus(GdipSetImageAttributesRemapTable(Native,
       GdipTypes.TColorAdjustType(catype), False, 0, nil));
end;

procedure TGpImageAttributes.ClearThreshold(catype: TColorAdjustType);
begin
  CheckStatus(GdipSetImageAttributesThreshold(Native, GdipTypes.TColorAdjustType(catype), False, 0.0));
end;

function TGpImageAttributes.Clone: TGpImageAttributes;
begin
  Result := TGpImageAttributes.CreateClone(Native, @GdipCloneImageAttributes);
end;

constructor TGpImageAttributes.Create;
begin
  CheckStatus(GdipCreateImageAttributes(FNative));
end;

destructor TGpImageAttributes.Destroy;
begin
  GdipDisposeImageAttributes(Native);
end;

procedure TGpImageAttributes.GetAdjustedPalette(ColorPalette: PColorPalette;
  colorAdjustType: TColorAdjustType);
begin
  CheckStatus(GdipGetImageAttributesAdjustedPalette(
              Native, ColorPalette, GdipTypes.TColorAdjustType(colorAdjustType)));
end;

procedure TGpImageAttributes.Reset(caType: TColorAdjustType);
begin
  CheckStatus(GdipResetImageAttributes(Native, GdipTypes.TColorAdjustType(catype)));
end;

procedure TGpImageAttributes.SetBrushRemapTable(const map: array of TColorMap);
begin
  SetRemapTable(map, ctBrush);
end;

procedure TGpImageAttributes.SetColorKey(const colorLow, colorHigh: TARGB;
  catype: TColorAdjustType);
begin
  CheckStatus(GdipSetImageAttributesColorKeys(Native, GdipTypes.TColorAdjustType(catype),
                         True, colorLow, colorHigh));
end;

procedure TGpImageAttributes.SetColorMatrices(const colorMatrix, grayMatrix: TColorMatrix;
  mode: TColorMatrixFlags; catype: TColorAdjustType);
begin
  CheckStatus(GdipSetImageAttributesColorMatrix(Native, GdipTypes.TColorAdjustType(catype),
                True, @colorMatrix, @grayMatrix, GdipTypes.TColorMatrixFlags(mode)));
end;

procedure TGpImageAttributes.SetColorMatrix(const colorMatrix: TColorMatrix;
  mode: TColorMatrixFlags; catype: TColorAdjustType);
begin
  CheckStatus(GdipSetImageAttributesColorMatrix(Native, GdipTypes.TColorAdjustType(catype),
                          True, @colorMatrix, nil, GdipTypes.TColorMatrixFlags(mode)));
end;

procedure TGpImageAttributes.SetGamma(gamma: Single; catype: TColorAdjustType);
begin
  CheckStatus(GdipSetImageAttributesGamma(Native, GdipTypes.TColorAdjustType(catype), True, gamma));
end;

procedure TGpImageAttributes.SetNoOp(catype: TColorAdjustType);
begin
  CheckStatus(GdipSetImageAttributesNoOp(Native, GdipTypes.TColorAdjustType(catype), True));
end;

procedure TGpImageAttributes.SetOutputChannel(
  channelFlags: TColorChannelFlags; catype: TColorAdjustType);
begin
  CheckStatus(GdipSetImageAttributesOutputChannel(Native,
              GdipTypes.TColorAdjustType(catype), True, GdipTypes.TColorChannelFlags(channelFlags)));
end;

procedure TGpImageAttributes.SetOutputChannelColorProfile(
  const colorProfileFilename: WideString; catype: TColorAdjustType);
begin
  CheckStatus(GdipSetImageAttributesOutputChannelColorProfile(
              Native, GdipTypes.TColorAdjustType(catype), True, PWideChar(colorProfileFilename)));
end;

procedure TGpImageAttributes.SetRemapTable(const map: array of TColorMap; catype: TColorAdjustType);
begin
  CheckStatus(GdipSetImageAttributesRemapTable(Native,
      GdipTypes.TColorAdjustType(catype), True, Length(map), @map));
end;

procedure TGpImageAttributes.SetThreshold(threshold: Single; catype: TColorAdjustType);
begin
  CheckStatus(GdipSetImageAttributesThreshold(Native, GdipTypes.TColorAdjustType(catype), True, threshold));
end;

procedure TGpImageAttributes.SetToIdentity(caType: TColorAdjustType);
begin
  CheckStatus(GdipSetImageAttributesToIdentity(Native, GdipTypes.TColorAdjustType(catype)));
end;

procedure TGpImageAttributes.SetWrapMode(wrap: TWrapMode; const color: TARGB);
begin
  CheckStatus(GdipSetImageAttributesWrapMode(Native, GdipTypes.TWrapMode(wrap), color, False));
end;

procedure TGpImageAttributes.SetWrapMode(wrap: TWrapMode);
begin
  SetWrapMode(wrap, kcBlack);
end;

{ TGpImage }

const
  PixFormat: array[TPixelFormat] of Integer = (
    PixelFormatUndefined,
    PixelFormat1bppIndexed,
    PixelFormat4bppIndexed,
    PixelFormat8bppIndexed,
    PixelFormat16bppGrayScale,
    PixelFormat16bppRGB555,
    PixelFormat16bppRGB565,
    PixelFormat16bppARGB1555,
    PixelFormat24bppRGB,
    PixelFormat32bppRGB,
    PixelFormat32bppARGB,
    PixelFormat32bppPARGB,
    PixelFormat48bppRGB,
    PixelFormat64bppARGB,
    PixelFormat64bppPARGB
  );

function TGpImage.Clone: TGpImage;
begin
  Result := TGpImage.CreateClone(Native, @GdipCloneImage);
end;

constructor TGpImage.Create(stream: IStream; useEmbeddedColorManagement: Boolean);
begin
  if useEmbeddedColorManagement then
    CheckStatus(GdipLoadImageFromStreamICM(stream, FNative))
  else
    CheckStatus(GdipLoadImageFromStream(stream, FNative));
end;

constructor TGpImage.Create(const filename: WideString; useEmbeddedColorManagement: Boolean);
begin
  if useEmbeddedColorManagement then
    CheckStatus(GdipLoadImageFromFileICM(PWideChar(filename), FNative))
  else
    CheckStatus(GdipLoadImageFromFile(PWideChar(filename), FNative));
end;

destructor TGpImage.Destroy;
begin
  if Assigned(FPalette) then
    FreeMem(FPalette);
  GdipDisposeImage(Native);
end;

class function TGpImage.FromFile(const filename: WideString;
  useEmbeddedColorManagement: Boolean): TGpImage;
begin
  Result := TGpImage.Create(filename, useEmbeddedColorManagement);
end;

class function TGpImage.FromStream(stream: IStream;
  useEmbeddedColorManagement: Boolean): TGpImage;
begin
  Result := TGpImage.Create(stream, useEmbeddedColorManagement);
end;

procedure TGpImage.GetAllPropertyItems(allItems: PPropertyItem);
begin
  CheckStatus(GdipGetAllPropertyItems(Native, PropertySize, PropertyCount, allItems));
end;

procedure TGpImage.GetBounds(var srcRect: TGpRectF; var srcUnit: TUnit);
begin
  CheckStatus(GdipGetImageBounds(Native, @srcRect, GdipTypes.TUnit(RV.rINT)));
  srcUnit := TUnit(RV.rINT);
end;

procedure TGpImage.GetEncoderParameterList(const clsidEncoder: TCLSID;
  size: Integer; buffer: PEncoderParameters);
begin
  CheckStatus(GdipGetEncoderParameterList(Native, @clsidEncoder, size, buffer));
end;

function TGpImage.GetEncoderParameterListSize(const clsidEncoder: TCLSID): Integer;
begin
  CheckStatus(GdipGetEncoderParameterListSize(Native, @clsidEncoder, Result));
end;

function TGpImage.GetFlags: TImageFlags;
begin
  CheckStatus(GdipGetImageFlags(Native, Integer(Result)));
end;

function TGpImage.GetFrameCount(const dimensionID: TGUID): Integer;
begin
  CheckStatus(GdipImageGetFrameCount(Native, @dimensionID, Result));
end;

function TGpImage.GetFrameDimensionsCount: Integer;
begin
  CheckStatus(GdipImageGetFrameDimensionsCount(Native, Result));
end;

procedure TGpImage.GetFrameDimensionsList(dimensionIDs: PGUID; Count: Integer);
begin
  CheckStatus(GdipImageGetFrameDimensionsList(Native, dimensionIDs, Count));
end;

function TGpImage.GetHeight: Integer;
begin
  CheckStatus(GdipGetImageHeight(Native, Result));
end;

function TGpImage.GetHorizontalResolution: Single;
begin
  CheckStatus(GdipGetImageHorizontalResolution(Native, Result));
end;

function TGpImage.GetPalette: PColorPalette;
var
  Size: Integer;
begin
  if not Assigned(FPalette) then
  begin
    Size := PaletteSize;
    GetMem(FPalette, Size);
    CheckStatus(GdipGetImagePalette(Native, FPalette, Size));
  end;
  Result := FPalette;
end;

function TGpImage.GetPaletteSize: Integer;
begin
  CheckStatus(GdipGetImagePaletteSize(Native, Result));
end;

function TGpImage.GetPhysicalDimension: TGpSizeF;
begin
  CheckStatus(GdipGetImageDimension(Native, Result.Width, Result.Height));
end;

function TGpImage.GetPixelFormat: TPixelFormat;
var
  I: TPixelFormat;
begin
  CheckStatus(GdipGetImagePixelFormat(Native, RV.rINT));
  for I := High(TPixelFormat) downto Low(TPixelFormat) do
    if RV.rINT = PixFormat[I] then
    begin
      Result := I;
      Exit;
    end;
  Result := pfNone;
end;

class function TGpImage.GetPixelFormatSize(Format: TPixelFormat): Integer;
begin
    Result := (PixFormat[Format] shr 8) and $ff;
end;

function TGpImage.GetPropertyCount: Integer;
begin
  CheckStatus(GdipGetPropertyCount(Native, Result));
end;

procedure TGpImage.GetPropertyIdList(numOfProperty: Integer; list: PPropID);
begin
  CheckStatus(GdipGetPropertyIdList(Native, numOfProperty, list));
end;

procedure TGpImage.GetPropertyItem(propId: PROPID; buffer: PPropertyItem);
begin
  CheckStatus(GdipGetPropertyItem(Native, propId,
                                  GetPropertyItemSize(propId), buffer));
end;

function TGpImage.GetPropertyItemSize(propId: PROPID): Integer;
begin
  CheckStatus(GdipGetPropertyItemSize(Native, propId, Result));
end;

function TGpImage.GetPropertySize: Integer;
begin
  CheckStatus(GdipGetPropertySize(Native, Result, RV.rINT));
end;

function TGpImage.GetRawFormat: TGUID;
begin
  CheckStatus(GdipGetImageRawFormat(Native, @Result));
end;

function TGpImage.GetThumbnailImage(thumbWidth, thumbHeight: Integer;
  callback: TGetThumbnailImageAbort; callbackData: Pointer): TGpImage;
begin
  CheckStatus(GdipGetImageThumbnail(Native, thumbWidth, thumbHeight,
                                    RV.rPOINTER, callback, callbackData));
  Result := TGpImage.CreateClone(RV.rPOINTER);
end;

function TGpImage.GetType: TImageType;
begin
  CheckStatus(GdipGetImageType(Native, GdipTypes.TImageType(RV.rINT)));
  Result := TImageType(RV.rINT);
end;

function TGpImage.GetVerticalResolution: Single;
begin
  CheckStatus(GdipGetImageVerticalResolution(Native, Result));
end;

function TGpImage.GetWidth: Integer;
begin
  CheckStatus(GdipGetImageWidth(Native, Result));
end;

procedure TGpImage.RemovePropertyItem(propId: PROPID);
begin
  CheckStatus(GdipRemovePropertyItem(Native, propId));
end;

procedure TGpImage.RotateFlip(rotateFlipType: TRotateFlipType);
begin
  CheckStatus(GdipImageRotateFlip(Native, GdipTypes.TRotateFlipType(rotateFlipType)));
end;

procedure TGpImage.Save(stream: IStream; const clsidEncoder: TCLSID;
  const encoderParams: PEncoderParameters);
begin
  CheckStatus(GdipSaveImageToStream(Native, stream, @clsidEncoder, encoderParams));
end;

procedure TGpImage.Save(const filename: WideString;
  const clsidEncoder: TCLSID; const encoderParams: PEncoderParameters);
begin
  CheckStatus(GdipSaveImageToFile(Native, PWideChar(filename),
                                          @clsidEncoder, encoderParams));
end;

procedure TGpImage.SaveAdd(const encoderParams: PEncoderParameters);
begin
  CheckStatus(GdipSaveAdd(Native, encoderParams));
end;

procedure TGpImage.SaveAdd(newImage: TGpImage; const encoderParams: PEncoderParameters);
begin
  CheckStatus(GdipSaveAddImage(Native, newImage.Native, encoderParams));
end;

procedure TGpImage.SelectActiveFrame(const dimensionID: TGUID; frameIndex: Integer);
begin
  CheckStatus(GdipImageSelectActiveFrame(Native, @dimensionID, frameIndex));
end;

procedure TGpImage.SetPalette(const palette: PColorPalette);
begin
  CheckStatus(GdipSetImagePalette(Native, palette));
  if Assigned(FPalette) then
  begin
    FreeMem(FPalette);
    FPalette := nil;
  end;
end;

procedure TGpImage.SetPropertyItem(const item: TPropertyItem);
begin
  CheckStatus(GdipSetPropertyItem(Native, @item));
end;

{ TGpBitmap }

function TGpBitmap.Clone(x, y, width, height: Integer; format: TPixelFormat): TGpBitmap;
begin
  CheckStatus(GdipCloneBitmapAreaI(x, y, width, height, PixFormat[format], Native, RV.rPOINTER));
  Result := TGpBitmap.CreateClone(rV.rPOINTER);
end;

function TGpBitmap.Clone(const rect: TGpRect; format: TPixelFormat): TGpBitmap;
begin
  Result := Clone(rect.X, rect.Y, rect.Width, rect.Height, format);
end;

function TGpBitmap.Clone(const rect: TGpRectF; format: TPixelFormat): TGpBitmap;
begin
  Result := Clone(rect.X, rect.Y, rect.Width, rect.Height, format);
end;

function TGpBitmap.Clone(x, y, width, height: Single; format: TPixelFormat): TGpBitmap;
begin
  CheckStatus(GdipCloneBitmapArea(x, y, width, height, PixFormat[format], Native, RV.rPOINTER));
  Result := TGpBitmap.CreateClone(RV.rPOINTER);
end;

constructor TGpBitmap.Create(width, height: Integer; format: TPixelFormat);
begin
  CheckStatus(GdipCreateBitmapFromScan0(width, height, 0, PixFormat[format], nil, FNative));
end;

constructor TGpBitmap.Create(width, height: Integer; target: TGpGraphics);
begin
  CheckStatus(GdipCreateBitmapFromGraphics(width, height, target.Native, FNative));
end;

constructor TGpBitmap.Create(width, height, stride: Integer; format: TPixelFormat; scan0: Pointer);
begin
  CheckStatus(GdipCreateBitmapFromScan0(width, height, stride, PixFormat[format], scan0, FNative));
end;

constructor TGpBitmap.Create(const filename: WideString; useEmbeddedColorManagement: Boolean);
begin
  if useEmbeddedColorManagement then
    CheckStatus(GdipCreateBitmapFromFileICM(PWideChar(filename), FNative))
  else
    CheckStatus(GdipCreateBitmapFromFile(PWideChar(filename), FNative));
end;

constructor TGpBitmap.Create(stream: IStream; useEmbeddedColorManagement: Boolean);
begin
  if useEmbeddedColorManagement then
    CheckStatus(GdipCreateBitmapFromStreamICM(stream, FNative))
  else
    CheckStatus(GdipCreateBitmapFromStream(stream, FNative));
end;
{
constructor TGpBitmap.Create(surface: GpDirectDrawSurface7);
begin
  CheckStatus(GdipCreateBitmapFromDirectDrawSurface(surface, FNative));
end;
}
constructor TGpBitmap.Create(icon: HICON);
begin
  CheckStatus(GdipCreateBitmapFromHICON(icon, FNative));
end;

constructor TGpBitmap.Create(hInstance: HMODULE; const bitmapName: WideString);
begin
  CheckStatus(GdipCreateBitmapFromResource(hInstance, PWideChar(bitmapName), FNative));
end;

constructor TGpBitmap.Create(const gdiBitmapInfo: TBITMAPINFO; gdiBitmapData: Pointer);
begin
  CheckStatus(GdipCreateBitmapFromGdiDib(@gdiBitmapInfo, gdiBitmapData, FNative));
end;

constructor TGpBitmap.Create(hbm: HBITMAP; hpal: HPALETTE);
begin
  CheckStatus(GdipCreateBitmapFromHBITMAP(hbm, hpal, FNative));
end;

class function TGpBitmap.FromBITMAPINFO(const gdiBitmapInfo: TBITMAPINFO;
  gdiBitmapData: Pointer): TGpBitmap;
begin
  Result := TGpBitmap.Create(gdiBitmapInfo, gdiBitmapData);
end;

class function TGpBitmap.FromDirectDrawSurface7(surface: GpDirectDrawSurface7): TGpBitmap;
begin
  Result := TGpBitmap.Create;
  GdipCreateBitmapFromDirectDrawSurface(surface, Result.FNative);
end;

class function TGpBitmap.FromFile(const filename: WideString;
  useEmbeddedColorManagement: Boolean): TGpBitmap;
begin
  Result := TGpBitmap.Create(filename, useEmbeddedColorManagement);
end;

class function TGpBitmap.FromHBITMAP(hbm: HBITMAP; hpal: HPALETTE): TGpBitmap;
begin
  Result := TGpBitmap.Create(hbm, hpal);
end;

class function TGpBitmap.FromHICON(icon: HICON): TGpBitmap;
begin
  Result := TGpBitmap.Create(icon);
end;

class function TGpBitmap.FromResource(hInstance: HMODULE; const bitmapName: WideString): TGpBitmap;
begin
  Result := TGpBitmap.Create(hInstance, bitmapname);
end;

class function TGpBitmap.FromStream(stream: IStream; useEmbeddedColorManagement: Boolean): TGpBitmap;
begin
  Result := TGpBitmap.Create(stream, useEmbeddedColorManagement);
end;

function TGpBitmap.GetHBITMAP(colorBackground: TARGB): HBITMAP;
begin
  CheckStatus(GdipCreateHBITMAPFromBitmap(Native, Result, colorBackground));
end;

function TGpBitmap.GetHICON: HICON;
begin
  CheckStatus(GdipCreateHICONFromBitmap(Native, Result));
end;

function TGpBitmap.GetPixel(x, y: Integer): TARGB;
begin
  CheckStatus(GdipBitmapGetPixel(Native, x, y, @Result));
end;

function TGpBitmap.LockBits(const rect: TGpRect; flags: TImageLockModes; format: TPixelFormat): TBitmapData;
begin
  CheckStatus(GdipBitmapLockBits(Native, @rect, Byte(flags),
                                         PixFormat[format], @Result));
end;

procedure TGpBitmap.SetPixel(x, y: Integer; const Value: TARGB);
begin
  CheckStatus(GdipBitmapSetPixel(Native, x, y, Value));
end;

procedure TGpBitmap.SetResolution(xdpi, ydpi: Single);
begin
  CheckStatus(GdipBitmapSetResolution(Native, xdpi, ydpi));
end;

procedure TGpBitmap.UnlockBits(var lockedBitmapData: TBitmapData);
begin
  CheckStatus(GdipBitmapUnlockBits(Native, @lockedBitmapData));
end;

{ TGpMetafile }

constructor TGpMetafile.Create(filename: WideString;
  wmfPlaceableFileHeader: TWmfPlaceableFileHeader);
begin
  CheckStatus(GdipCreateMetafileFromWmfFile(PWChar(filename),
                               @wmfPlaceableFileHeader, FNative));
end;

constructor TGpMetafile.Create(stream: IStream);
begin
  CheckStatus(GdipCreateMetafileFromStream(stream, FNative));
end;

constructor TGpMetafile.Create(referenceHdc: HDC; type_: TEmfType; description: PWChar);
begin
  CheckStatus(GdipRecordMetafile(referenceHdc, GdipTypes.TEmfType(type_), nil,
                MetafileFrameUnitGdi, description, FNative));
end;

constructor TGpMetafile.Create(filename: WideString);
begin
  CheckStatus(GdipCreateMetafileFromFile(PWChar(filename), FNative));
end;

constructor TGpMetafile.Create(hWmf: HMETAFILE;
  wmfPlaceableFileHeader: TWmfPlaceableFileHeader; deleteWmf: Boolean);
begin
  CheckStatus(GdipCreateMetafileFromWmf(hWmf, deleteWmf,
                                @wmfPlaceableFileHeader, FNative));
end;

constructor TGpMetafile.Create(hEmf: HENHMETAFILE; deleteEmf: Boolean);
begin
  CheckStatus(GdipCreateMetafileFromEmf(hEmf, deleteEmf, FNative));
end;

constructor TGpMetafile.Create(referenceHdc: HDC; frameRect: TGpRectF;
  frameUnit: TMetafileFrameUnit; type_: TEmfType; description: PWChar);
begin
  CheckStatus(GdipRecordMetafile(referenceHdc, GdipTypes.TEmfType(type_), @frameRect,
                                 GdipTypes.TMetafileFrameUnit(frameUnit), description, FNative));
end;

constructor TGpMetafile.Create(stream: IStream; referenceHdc: HDC;
  type_: TEmfType; description: PWChar);
begin
  CheckStatus(GdipRecordMetafileStream(stream, referenceHdc, GdipTypes.TEmfType(type_),
                   nil, MetafileFrameUnitGdi, description, FNative));
end;

constructor TGpMetafile.Create(stream: IStream; referenceHdc: HDC;
  frameRect: TGpRectF; frameUnit: TMetafileFrameUnit; type_: TEmfType;
  description: PWChar);
begin
  CheckStatus(GdipRecordMetafileStream(stream, referenceHdc,  GdipTypes.TEmfType(type_),
                @frameRect, GdipTypes.TMetafileFrameUnit(frameUnit), description, FNative));
end;

constructor TGpMetafile.Create(stream: IStream; referenceHdc: HDC;
  frameRect: TGpRect; frameUnit: TMetafileFrameUnit; type_: TEmfType;
  description: PWChar);
begin
  CheckStatus(GdipRecordMetafileStreamI(stream, referenceHdc, GdipTypes.TEmfType(type_),
                  @frameRect, GdipTypes.TMetafileFrameUnit(frameUnit), description, FNative));
end;

constructor TGpMetafile.Create(fileName: WideString; referenceHdc: HDC;
  frameRect: TGpRect; frameUnit: TMetafileFrameUnit; type_: TEmfType;
  description: PWChar);
begin
  CheckStatus(GdipRecordMetafileFileNameI(PWChar(fileName), referenceHdc,  GdipTypes.TEmfType(type_),
                  @frameRect, GdipTypes.TMetafileFrameUnit(frameUnit), description, FNative));
end;

constructor TGpMetafile.Create(referenceHdc: HDC; frameRect: TGpRect;
  frameUnit: TMetafileFrameUnit; type_: TEmfType; description: PWChar);
begin
  CheckStatus(GdipRecordMetafileI(referenceHdc, GdipTypes.TEmfType(type_), @frameRect,
                        GdipTypes.TMetafileFrameUnit(frameUnit), description, FNative));
end;

constructor TGpMetafile.Create(fileName: WideString; referenceHdc: HDC;
  type_: TEmfType; description: PWChar);
begin
  CheckStatus(GdipRecordMetafileFileName(PWChar(fileName), referenceHdc, GdipTypes.TEmfType(type_),
                  nil, MetafileFrameUnitGdi, description, FNative));
end;

constructor TGpMetafile.Create(fileName: WideString; referenceHdc: HDC;
  frameRect: TGpRectF; frameUnit: TMetafileFrameUnit; type_: TEmfType;
  description: PWChar);
begin
  CheckStatus(GdipRecordMetafileFileName(PWChar(fileName), referenceHdc, GdipTypes.TEmfType(type_),
                  @frameRect, GdipTypes.TMetafileFrameUnit(frameUnit), description, FNative));
end;

class procedure TGpMetafile.EmfToWmfBits(hemf: HENHMETAFILE; cbData16: Integer;
  pData16: PByte; iMapMode: Integer; eFlags: TEmfToWmfBitsFlags);
begin
  CheckStatus(GdipEmfToWmfBits(hemf, cbData16, pData16, iMapMode, Byte(eFlags)));
end;

function TGpMetafile.GetDownLevelRasterizationLimit: Integer;
begin
  CheckStatus(GdipGetMetafileDownLevelRasterizationLimit(Native, Result));
end;

function TGpMetafile.GetHENHMETAFILE: HENHMETAFILE;
begin
  CheckStatus(GdipGetHemfFromMetafile(Native, Result));
end;

class procedure TGpMetafile.GetMetafileHeader(const filename: WideString; header: TMetafileHeader);
begin
  CheckStatus(GdipGetMetafileHeaderFromFile(PWChar(filename), header));
end;

class procedure TGpMetafile.GetMetafileHeader(hEmf: HENHMETAFILE; header: TMetafileHeader);
begin
  CheckStatus(GdipGetMetafileHeaderFromEmf(hEmf, header));
end;

class procedure TGpMetafile.GetMetafileHeader(hWmf: HMETAFILE;
  const wmfPlaceableFileHeader: TWmfPlaceableFileHeader; header: TMetafileHeader);
begin
  CheckStatus(GdipGetMetafileHeaderFromWmf(hWmf, @wmfPlaceableFileHeader, header));
end;

class procedure TGpMetafile.GetMetafileHeader(stream: IStream; header: TMetafileHeader);
begin
  CheckStatus(GdipGetMetafileHeaderFromStream(stream, header));
end;

procedure TGpMetafile.GetMetafileHeader(header: TMetafileHeader);
begin
  CheckStatus(GdipGetMetafileHeaderFromMetafile(Native, header));
end;

procedure TGpMetafile.PlayRecord(recordType: TEmfPlusRecordType; flags,
  dataSize: Integer; const data: PByte);
begin
  CheckStatus(GdipPlayMetafileRecord(Native, recordType, flags, dataSize, data));
end;

procedure TGpMetafile.SetDownLevelRasterizationLimit(metafileRasterizationLimitDpi: Integer);
begin
  CheckStatus(GdipSetMetafileDownLevelRasterizationLimit(
                                Native, metafileRasterizationLimitDpi));
end;

{ TGpCachedBitmap }

constructor TGpCachedBitmap.Create(bitmap: TGpBitmap; graphics: TGpGraphics);
begin
  CheckStatus(GdipCreateCachedBitmap(bitmap.Native, graphics.Native, FNative));
end;

destructor TGpCachedBitmap.Destroy;
begin
  GdipDeleteCachedBitmap(Native);
end;

{ TGpCustomLineCap }

function TGpCustomLineCap.Clone: TGpCustomLineCap;
begin
  Result := TGpCustomLineCap.CreateClone(Native, @GdipCloneCustomLineCap);
end;

constructor TGpCustomLineCap.Create(fillPath, strokePath: TGpGraphicsPath;
  baseCap: TLineCap; baseInset: Single);
begin
  CheckStatus(GdipCreateCustomLineCap(ObjectNative(fillPath),
                  ObjectNative(strokePath), GdipTypes.TLineCap(baseCap), baseInset, FNative));
end;

destructor TGpCustomLineCap.Destroy;
begin
  GdipDeleteCustomLineCap(Native);
end;

function TGpCustomLineCap.GetBaseCap: TLineCap;
begin
  CheckStatus(GdipGetCustomLineCapBaseCap(Native, GdipTypes.TLineCap(RV.rINT)));
  Result := TLineCap(RV.rINT);
end;

function TGpCustomLineCap.GetBaseInset: Single;
begin
  CheckStatus(GdipGetCustomLineCapBaseInset(Native, Result));
end;

procedure TGpCustomLineCap.GetStrokeCaps(var startCap, endCap: TLineCap);
var
  s, e: GdipTypes.TLineCap;
begin
  CheckStatus(GdipGetCustomLineCapStrokeCaps(Native, s, e));
  startCap := TLineCap(s);
  endCap := TLineCap(e);
end;                                      

function TGpCustomLineCap.GetStrokeJoin: TLineJoin;
begin
  CheckStatus(GdipGetCustomLineCapStrokeJoin(Native, GdipTypes.TLineJoin(RV.rINT)));
  Result := TLineJoin(RV.rINT);
end;

function TGpCustomLineCap.GetWidthScale: Single;
begin
  CheckStatus(GdipGetCustomLineCapWidthScale(Native, Result));
end;

procedure TGpCustomLineCap.SetBaseCap(baseCap: TLineCap);
begin
  CheckStatus(GdipSetCustomLineCapBaseCap(Native, GdipTypes.TLineCap(baseCap)));
end;

procedure TGpCustomLineCap.SetBaseInset(inset: Single);
begin
  CheckStatus(GdipSetCustomLineCapBaseInset(Native, inset));
end;

procedure TGpCustomLineCap.SetStrokeCap(strokeCap: TLineCap);
begin
  SetStrokeCaps(strokeCap, strokeCap);
end;

procedure TGpCustomLineCap.SetStrokeCaps(startCap, endCap: TLineCap);
begin
  CheckStatus(GdipSetCustomLineCapStrokeCaps(Native, GdipTypes.TLineCap(StartCap), GdipTypes.TLineCap(EndCap)));
end;

procedure TGpCustomLineCap.SetStrokeJoin(lineJoin: TLineJoin);
begin
  CheckStatus(GdipSetCustomLineCapStrokeJoin(Native, GdipTypes.TLineJoin(lineJoin)));
end;

procedure TGpCustomLineCap.SetWidthScale(widthScale: Single);
begin
  CheckStatus(GdipSetCustomLineCapWidthScale(Native, widthScale));
end;

{ TGpAdjustableArrowCap }

constructor TGpAdjustableArrowCap.Create(width, height: Single; isFilled: Boolean);
begin
  CheckStatus(GdipCreateAdjustableArrowCap(height, width, isFilled, FNative));
end;

function TGpAdjustableArrowCap.GetFillState: Boolean;
begin
  CheckStatus(GdipGetAdjustableArrowCapFillState(Native, RV.rBOOL));
  Result := RV.rBOOL;
end;

function TGpAdjustableArrowCap.GetHeight: Single;
begin
  CheckStatus(GdipGetAdjustableArrowCapHeight(Native, Result));
end;

function TGpAdjustableArrowCap.GetMiddleInset: Single;
begin
  CheckStatus(GdipGetAdjustableArrowCapMiddleInset(Native, Result));
end;

function TGpAdjustableArrowCap.GetWidth: Single;
begin
  CheckStatus(GdipGetAdjustableArrowCapWidth(Native, Result));
end;

procedure TGpAdjustableArrowCap.SetFillState(const Value: Boolean);
begin
  CheckStatus(GdipSetAdjustableArrowCapFillState(Native, Value));
end;

procedure TGpAdjustableArrowCap.SetHeight(const Value: Single);
begin
  CheckStatus(GdipSetAdjustableArrowCapHeight(Native, Value));
end;

procedure TGpAdjustableArrowCap.SetMiddleInset(const Value: Single);
begin
  CheckStatus(GdipSetAdjustableArrowCapMiddleInset(Native, Value));
end;

procedure TGpAdjustableArrowCap.SetWidth(const Value: Single);
begin
  CheckStatus(GdipSetAdjustableArrowCapWidth(Native, Value));
end;

{ TGpBrush }

function TGpBrush.Clone: TGpBrush;
begin
  Result := TGpBrush.CreateClone(Native, @GdipCloneBrush);
end;

destructor TGpBrush.Destroy;
begin
  GdipDeleteBrush(Native);
  FNative := nil;
end;

function TGpBrush.GetType: TBrushType;
begin
  CheckStatus(GdipGetBrushType(Native, GdipTypes.TBrushType(RV.rINT)));
  Result := TBrushType(RV.rINT);
end;

{ TGpSolidBrush }

constructor TGpSolidBrush.Create(color: TARGB);
begin
  CheckStatus(GdipCreateSolidFill(color, FNative));
end;

function TGpSolidBrush.GetColor: TARGB;
begin
  CheckStatus(GdipGetSolidFillColor(Native, @Result));
end;

procedure TGpSolidBrush.SetColor(const color: TARGB);
begin
  CheckStatus(GdipSetSolidFillColor(Native, color));
end;

{ TGpTextureBrush }

constructor TGpTextureBrush.Create(image: TGpImage; dstRect: TGpRect;
  imageAttributes: TGpImageAttributes);
begin
  CheckStatus(GdipCreateTextureIAI(image.Native, ObjectNative(imageAttributes),
                  dstRect.X, dstRect.Y, dstRect.Width, dstRect.Height, FNative));
end;

constructor TGpTextureBrush.Create(image: TGpImage; wrapMode: TWrapMode; dstX,
  dstY, dstWidth, dstHeight: Single);
begin
  CheckStatus(GdipCreateTexture2(image.Native, GdipTypes.TWrapMode(wrapMode),
                                 dstX, dstY, dstWidth, dstHeight, FNative));
end;

constructor TGpTextureBrush.Create(image: TGpImage; wrapMode: TWrapMode;
  dstRect: TGpRect);
begin
  CheckStatus(GdipCreateTexture2I(image.Native, GdipTypes.TWrapMode(wrapMode), dstRect.X, dstRect.Y,
                                  dstRect.Width, dstRect.Height, FNative));
end;

constructor TGpTextureBrush.Create(image: TGpImage; wrapMode: TWrapMode);
begin
  CheckStatus(GdipCreateTexture(image.Native, GdipTypes.TWrapMode(wrapMode), FNative));
end;

constructor TGpTextureBrush.Create(image: TGpImage; dstRect: TGpRectF;
  imageAttributes: TGpImageAttributes);
begin
  CheckStatus(GdipCreateTextureIA(image.Native, ObjectNative(imageAttributes),
                  dstRect.X, dstRect.Y, dstRect.Width, dstRect.Height, FNative));
end;

constructor TGpTextureBrush.Create(image: TGpImage; wrapMode: TWrapMode;
  dstRect: TGpRectF);
begin
  CheckStatus(GdipCreateTexture2(image.Native, GdipTypes.TWrapMode(wrapMode), dstRect.X, dstRect.Y,
                                   dstRect.Width, dstRect.Height, FNative));
end;

constructor TGpTextureBrush.Create(image: TGpImage; wrapMode: TWrapMode; dstX,
  dstY, dstWidth, dstHeight: Integer);
begin
  CheckStatus(GdipCreateTexture2I(image.Native, GdipTypes.TWrapMode(wrapMode),
                                  dstX, dstY, dstWidth, dstHeight, FNative));
end;

function TGpTextureBrush.GetImage: TGpImage;
begin
  CheckStatus(GdipGetTextureImage(Native, RV.rPOINTER));
  Result := TGpImage.CreateClone(RV.rPOINTER);
end;

procedure TGpTextureBrush.GetTransform(matrix: TGpMatrix);
begin
  CheckStatus(GdipGetTextureTransform(Native, matrix.Native));
end;

function TGpTextureBrush.GetWrapMode: TWrapMode;
begin
  CheckStatus(GdipGetTextureWrapMode(Native, GdipTypes.TWrapMode(RV.rINT)));
  Result := TWrapMode(RV.rINT);
end;

procedure TGpTextureBrush.MultiplyTransform(matrix: TGpMatrix; order: TMatrixOrder);
begin
  CheckStatus(GdipMultiplyTextureTransform(Native, matrix.Native, GdipTypes.TMatrixOrder(order)))
end;

procedure TGpTextureBrush.ResetTransform;
begin
  CheckStatus(GdipResetTextureTransform(Native));
end;

procedure TGpTextureBrush.RotateTransform(angle: Single; order: TMatrixOrder);
begin
  CheckStatus(GdipRotateTextureTransform(Native, angle, GdipTypes.TMatrixOrder(order)));
end;

procedure TGpTextureBrush.ScaleTransform(sx, sy: Single; order: TMatrixOrder);
begin
  CheckStatus(GdipScaleTextureTransform(Native, sx, sy, GdipTypes.TMatrixOrder(order)));
end;

procedure TGpTextureBrush.SetTransform(const matrix: TGpMatrix);
begin
  CheckStatus(GdipSetTextureTransform(Native, matrix.Native));
end;

procedure TGpTextureBrush.SetWrapMode(wrapMode: TWrapMode);
begin
  CheckStatus(GdipSetTextureWrapMode(Native, GdipTypes.TWrapMode(wrapMode)));
end;

procedure TGpTextureBrush.TranslateTransform(dx, dy: Single; order: TMatrixOrder);
begin
  CheckStatus(GdipTranslateTextureTransform(Native, dx, dy, GdipTypes.TMatrixOrder(order)));
end;

{ TGpLinearGradientBrush }

constructor TGpLinearGradientBrush.Create(rect: TGpRectF; color1,
  color2: TARGB; mode: TLinearGradientMode);
begin
  CheckStatus(GdipCreateLineBrushFromRect(@rect, color1, color2,
      GdipTypes.TLinearGradientMode(mode), WrapModeTile, FNative));
end;

constructor TGpLinearGradientBrush.Create(rect: TGpRect; color1,
  color2: TARGB; mode: TLinearGradientMode);
begin
  CheckStatus(GdipCreateLineBrushFromRectI(@rect, color1, color2,
      GdipTypes.TLinearGradientMode(mode), WrapModeTile, FNative));
end;

constructor TGpLinearGradientBrush.Create(rect: TGpRectF; color1,
  color2: TARGB; angle: Single; isAngleScalable: Boolean);
begin
  CheckStatus(GdipCreateLineBrushFromRectWithAngle(@rect, color1, color2,
                              angle, isAngleScalable, WrapModeTile, FNative));
end;

constructor TGpLinearGradientBrush.Create(point1, point2: TGpPointF; color1, color2: TARGB);
begin
  CheckStatus(GdipCreateLineBrush(@point1, @point2, color1, color2, WrapModeTile, FNative));
end;

constructor TGpLinearGradientBrush.Create(point1, point2: TGpPoint; color1, color2: TARGB);
begin
  CheckStatus(GdipCreateLineBrushI(@point1, @point2, color1, color2, WrapModeTile, FNative));
end;

constructor TGpLinearGradientBrush.Create(rect: TGpRect; color1,
  color2: TARGB; angle: Single; isAngleScalable: Boolean);
begin
  CheckStatus(GdipCreateLineBrushFromRectWithAngleI(@rect, color1, color2,
                              angle, isAngleScalable, WrapModeTile, FNative));
end;

function TGpLinearGradientBrush.GetBlend(var blendFactors, blendPositions: array of Single): Integer;
begin
  Result := BlendCount;
  if (Length(blendFactors) < Result) or (Length(blendPositions) < Result) then
    CheckStatus(InvalidParameter);
  CheckStatus(GdipGetLineBlend(Native, @blendFactors, @blendPositions, Result));
end;

function TGpLinearGradientBrush.GetBlendCount: Integer;
begin
  CheckStatus(GdipGetLineBlendCount(Native, Result));
end;

function TGpLinearGradientBrush.GetGammaCorrection: Boolean;
begin
  CheckStatus(GdipGetLineGammaCorrection(Native, RV.rBOOL));
  Result := RV.rBOOL;
end;

function TGpLinearGradientBrush.GetInterpolationColorCount: Integer;
begin
  CheckStatus(GdipGetLinePresetBlendCount(Native, Result));
end;

function TGpLinearGradientBrush.GetInterpolationColors(var presetColors: array of TARGB;
  var blendPositions: array of Single): Integer;
begin
  Result := InterpolationColorCount;
  if (Length(presetColors) < Result) or (Length(blendPositions) < Result) then
    CheckStatus(InvalidParameter);
  CheckStatus(GdipGetLinePresetBlend(Native, @presetColors, @blendPositions, Result));
end;

procedure TGpLinearGradientBrush.GetLinearColors(var color1, color2: TARGB);
var
  colors: array[0..1] of TARGB;
begin
  CheckStatus(GdipGetLineColors(Native, @colors));
  color1 := colors[0];
  color2 := colors[1];
end;

function TGpLinearGradientBrush.GetRectangleF: TGpRectF;
begin
  CheckStatus(GdipGetLineRect(Native, @Result));
end;

function TGpLinearGradientBrush.GetRectangle: TGpRect;
begin
  CheckStatus(GdipGetLineRectI(Native, @Result));
end;

procedure TGpLinearGradientBrush.GetTransform(matrix: TGpMatrix);
begin
  CheckStatus(GdipGetLineTransform(Native, matrix.Native));
end;

function TGpLinearGradientBrush.GetWrapMode: TWrapMode;
begin
  CheckStatus(GdipGetLineWrapMode(Native, GdipTypes.TWrapMode(RV.rINT)));
  Result := TWrapMode(RV.rINT);
end;

procedure TGpLinearGradientBrush.MultiplyTransform(const matrix: TGpMatrix; order: TMatrixOrder);
begin
  CheckStatus(GdipMultiplyLineTransform(Native, matrix.Native, GdipTypes.TMatrixOrder(order)));
end;

procedure TGpLinearGradientBrush.ResetTransform;
begin
  CheckStatus(GdipResetLineTransform(Native));
end;

procedure TGpLinearGradientBrush.RotateTransform(angle: Single; order: TMatrixOrder);
begin
  CheckStatus(GdipRotateLineTransform(Native, angle, GdipTypes.TMatrixOrder(order)));
end;

procedure TGpLinearGradientBrush.ScaleTransform(sx, sy: Single; order: TMatrixOrder);
begin
  CheckStatus(GdipScaleLineTransform(Native, sx, sy, GdipTypes.TMatrixOrder(order)));
end;

procedure TGpLinearGradientBrush.SetBlend(const blendFactors, blendPositions: array of Single);
begin
  CheckStatus(GdipSetLineBlend(Native, @blendFactors, @blendPositions, Length(blendFactors)));
end;

procedure TGpLinearGradientBrush.SetBlendBellShape(focus, scale: Single);
begin
  CheckStatus(GdipSetLineSigmaBlend(Native, focus, scale));
end;

procedure TGpLinearGradientBrush.SetBlendTriangularShape(focus, scale: Single);
begin
  CheckStatus(GdipSetLineLinearBlend(Native, focus, scale));
end;

procedure TGpLinearGradientBrush.SetGammaCorrection(useGammaCorrection: Boolean);
begin
  CheckStatus(GdipSetLineGammaCorrection(Native, useGammaCorrection));
end;

procedure TGpLinearGradientBrush.SetInterpolationColors(const presetColors: array of TARGB;
  const blendPositions: array of Single);
begin
  CheckStatus(GdipSetLinePresetBlend(Native, @presetColors, @blendPositions, Length(presetColors)));
end;

procedure TGpLinearGradientBrush.SetLinearColors(color1, color2: TARGB);
begin
  CheckStatus(GdipSetLineColors(Native, color1, color2));
end;

procedure TGpLinearGradientBrush.SetTransform(const matrix: TGpMatrix);
begin
  CheckStatus(GdipSetLineTransform(Native, matrix.Native));
end;

procedure TGpLinearGradientBrush.SetWrapMode(wrapMode: TWrapMode);
begin
  CheckStatus(GdipSetLineWrapMode(Native, GdipTypes.TWrapMode(wrapMode)));
end;

procedure TGpLinearGradientBrush.TranslateTransform(dx, dy: Single; order: TMatrixOrder);
begin
  CheckStatus(GdipTranslateLineTransform(Native, dx, dy, GdipTypes.TMatrixOrder(order)));
end;

{ TGpHatchBrush }

constructor TGpHatchBrush.Create(hatchStyle: THatchStyle; foreColor, backColor: TARGB);
begin
  CheckStatus(GdipCreateHatchBrush(GdipTypes.THatchStyle(hatchStyle), foreColor, backColor, FNative));
end;

function TGpHatchBrush.GetBackgroundColor: TARGB;
begin
  CheckStatus(GdipGetHatchBackgroundColor(Native, @Result));
end;

function TGpHatchBrush.GetForegroundColor: TARGB;
begin
  CheckStatus(GdipGetHatchForegroundColor(Native, @Result));
end;

function TGpHatchBrush.GetHatchStyle: THatchStyle;
begin
  CheckStatus(GdipGetHatchStyle(Native, GdipTypes.THatchStyle(RV.rINT)));
  Result := THatchStyle(RV.rINT);
end;

{ TGpPathGradientBrush }

constructor TGpPathGradientBrush.Create(points: array of TGpPoint; wrapMode: TWrapMode);
begin
  CheckStatus(GdipCreatePathGradientI(@points, Length(points), GdipTypes.TWrapMode(wrapMode), FNative));
end;

constructor TGpPathGradientBrush.Create(path: TGpGraphicsPath);
begin
  CheckStatus(GdipCreatePathGradientFromPath(path.Native, FNative));
end;

constructor TGpPathGradientBrush.Create(points: array of TGpPointF; wrapMode: TWrapMode);
begin
  CheckStatus(GdipCreatePathGradient(@points, Length(points), GdipTypes.TWrapMode(wrapMode), FNative));
end;

function TGpPathGradientBrush.GetBlend(var blendFactors, blendPositions: array of Single): Integer;
begin
  Result := BlendCount;
  if (Length(blendFactors) < Result) or (Length(blendPositions) < Result) then
    CheckStatus(InvalidParameter);
  CheckStatus(GdipGetPathGradientBlend(Native, @blendFactors, @blendPositions, Result));
end;

function TGpPathGradientBrush.GetBlendCount: Integer;
begin
  CheckStatus(GdipGetPathGradientBlendCount(Native, Result));
end;

function TGpPathGradientBrush.GetCenterColor: TARGB;
begin
  CheckStatus(GdipGetPathGradientCenterColor(Native, @Result));
end;

function TGpPathGradientBrush.GetCenterPoint: TGpPointF;
begin
  CheckStatus(GdipGetPathGradientCenterPoint(Native, @Result));
end;

function TGpPathGradientBrush.GetCenterPointI: TGpPoint;
begin
  CheckStatus(GdipGetPathGradientCenterPointI(Native, @Result));
end;

function TGpPathGradientBrush.GetFocusScales: TGpPointF;
begin
  CheckStatus(GdipGetPathGradientFocusScales(Native, Result.X, Result.Y));
end;

function TGpPathGradientBrush.GetGammaCorrection: Boolean;
begin
  CheckStatus(GdipGetPathGradientGammaCorrection(Native,RV.rBOOL));
  Result := RV.rBOOL;
end;

procedure TGpPathGradientBrush.GetGraphicsPath(path: TGpGraphicsPath);
begin
  CheckStatus(GdipGetPathGradientPath(Native, path.Native));
end;

function TGpPathGradientBrush.GetInterpolationColorCount: Integer;
begin
  CheckStatus(GdipGetPathGradientPresetBlendCount(Native, Result));
end;

function TGpPathGradientBrush.GetInterpolationColors(var presetColors: array of TARGB;
  var blendPositions: array of Single): Integer;
begin
  Result := InterpolationColorCount;
  if (Length(presetColors) < Result) or (Length(blendPositions) < Result) then
    CheckStatus(InvalidParameter);
  CheckStatus(GdipGetPathGradientPresetBlend(Native, @presetColors, @blendPositions, Result));
end;

function TGpPathGradientBrush.GetPointCount: Integer;
begin
  CheckStatus(GdipGetPathGradientPointCount(Native, Result));
end;

function TGpPathGradientBrush.GetRectangle: TGpRectF;
begin
  CheckStatus(GdipGetPathGradientRect(Native, @Result));
end;

function TGpPathGradientBrush.GetRectangleI: TGpRect;
begin
   CheckStatus(GdipGetPathGradientRectI(Native, @Result));
end;

function TGpPathGradientBrush.GetSurroundColorCount: Integer;
begin
  CheckStatus(GdipGetPathGradientSurroundColorCount(Native, Result));
end;

function TGpPathGradientBrush.GetSurroundColors(var colors: array of TARGB): Integer;
begin
  Result := GetSurroundColorCount;
  if Length(colors) < Result then
    CheckStatus(InvalidParameter);
  CheckStatus(GdipGetPathGradientSurroundColorsWithCount(Native, @colors, Result));
end;

procedure TGpPathGradientBrush.GetTransform(matrix: TGpMatrix);
begin
  CheckStatus(GdipGetPathGradientTransform(Native, matrix.Native));
end;

function TGpPathGradientBrush.GetWrapMode: TWrapMode;
begin
  CheckStatus(GdipGetPathGradientWrapMode(Native, GdipTypes.TWrapMode(RV.rINT)));
  Result := TWrapMode(RV.rINT);
end;

procedure TGpPathGradientBrush.MultiplyTransform(const matrix: TGpMatrix; order: TMatrixOrder);
begin
  CheckStatus(GdipMultiplyPathGradientTransform(Native, matrix.Native, GdipTypes.TMatrixOrder(order)));
end;

procedure TGpPathGradientBrush.ResetTransform;
begin
  CheckStatus(GdipResetPathGradientTransform(Native));
end;

procedure TGpPathGradientBrush.RotateTransform(angle: Single; order: TMatrixOrder);
begin
  CheckStatus(GdipRotatePathGradientTransform(Native, angle, GdipTypes.TMatrixOrder(order)));
end;

procedure TGpPathGradientBrush.ScaleTransform(sx, sy: Single; order: TMatrixOrder);
begin
  CheckStatus(GdipScalePathGradientTransform(Native, sx, sy, GdipTypes.TMatrixOrder(order)));
end;

procedure TGpPathGradientBrush.SetBlend(blendFactors, blendPositions: array of Single);
var
  count: Integer;
begin
  count := Length(blendFactors);
  if Length(blendPositions) < count then
    count := Length(blendPositions);
  if count <= 0 then CheckStatus(InvalidParameter);
  CheckStatus(GdipSetPathGradientBlend(Native, @blendFactors,
                                 @blendPositions, Length(blendFactors)));
end;

procedure TGpPathGradientBrush.SetBlendBellShape(focus, scale: Single);
begin
  CheckStatus(GdipSetPathGradientSigmaBlend(Native, focus, scale));
end;

procedure TGpPathGradientBrush.SetBlendTriangularShape(focus, scale: Single);
begin
  CheckStatus(GdipSetPathGradientLinearBlend(Native, focus, scale));
end;

procedure TGpPathGradientBrush.SetCenterColor(const color: TARGB);
begin
  CheckStatus(GdipSetPathGradientCenterColor(Native, color));
end;

procedure TGpPathGradientBrush.SetCenterPoint(const Value: TGpPointF);
begin
  CheckStatus(GdipSetPathGradientCenterPoint(Native, @Value));
end;

procedure TGpPathGradientBrush.SetCenterPointI(const Value: TGpPoint);
begin
  CheckStatus(GdipSetPathGradientCenterPointI(Native, @Value));
end;

procedure TGpPathGradientBrush.SetFocusScales(const Value: TGpPointF);
begin
  CheckStatus(GdipSetPathGradientFocusScales(Native, Value.X, Value.Y));
end;

procedure TGpPathGradientBrush.SetGammaCorrection(useGammaCorrection: Boolean);
begin
  CheckStatus(GdipSetPathGradientGammaCorrection(Native, useGammaCorrection));
end;

procedure TGpPathGradientBrush.SetGraphicsPath(const path: TGpGraphicsPath);
begin
  CheckStatus(GdipSetPathGradientPath(Native, path.Native));
end;

procedure TGpPathGradientBrush.SetInterpolationColors(presetColors: array of TARGB;
  blendPositions: array of Single);
var
  count: Integer;
begin
  count := Length(presetColors);
  if Length(blendPositions) < count then
    count := Length(blendPositions);
  if count <= 0 then CheckStatus(InvalidParameter);
  CheckStatus(GdipSetPathGradientPresetBlend(Native,
                              @presetColors, @blendPositions, count));
end;

procedure TGpPathGradientBrush.SetSurroundColors(colors: array of TARGB);
begin
  RV.rINT := GetPointCount;
  if (Length(colors) > RV.rINT) or (RV.rINT <= 0) then  //
    CheckStatus(InvalidParameter);
  RV.rINT := Length(colors);
  CheckStatus(GdipSetPathGradientSurroundColorsWithCount(Native, @colors, RV.rINT));
end;

procedure TGpPathGradientBrush.SetTransform(const matrix: TGpMatrix);
begin
  CheckStatus(GdipSetPathGradientTransform(Native, matrix.Native));
end;

procedure TGpPathGradientBrush.SetWrapMode(wrapMode: TWrapMode);
begin
  CheckStatus(GdipSetPathGradientWrapMode(Native, GdipTypes.TWrapMode(wrapMode)));
end;

procedure TGpPathGradientBrush.TranslateTransform(dx, dy: Single; order: TMatrixOrder);
begin
  CheckStatus(GdipTranslatePathGradientTransform(Native, dx, dy, GdipTypes.TMatrixOrder(order)));
end;

{ TGpPen }

function TGpPen.Clone: TGpPen;
begin
  Result := TGpPen.CreateClone(Native, @GdipClonePen);
end;

constructor TGpPen.Create(brush: TGpBrush; width: Single);
begin
  CheckStatus(GdipCreatePen2(brush.Native, width, UnitWorld, FNative));
end;

constructor TGpPen.Create(const color: TARGB; width: Single);
begin
  CheckStatus(GdipCreatePen1(color, width, UnitWorld, FNative));
end;

destructor TGpPen.Destroy;
begin
  GdipDeletePen(Native);
end;

function TGpPen.GetAlignment: TPenAlignment;
begin
  CheckStatus(GdipGetPenMode(Native, GdipTypes.TPenAlignment(RV.rINT)));
  Result := TPenAlignment(RV.rINT);
end;

function TGpPen.GetBrush: TGpBrush;
begin
    CheckStatus(GdipGetPenBrushFill(Native, RV.rPOINTER));
    case PenType of
      ptSolidColor: Result := TGpSolidBrush.CreateClone(RV.rPOINTER);
      ptHatchFill: Result := TGpHatchBrush.CreateClone(RV.rPOINTER);
      ptTextureFill: Result := TGpTextureBrush.CreateClone(RV.rPOINTER);
      ptPathGradient: Result := TGpPathGradientBrush.CreateClone(RV.rPOINTER);
      ptLinearGradient: Result := TGpLinearGradientBrush.CreateClone(RV.rPOINTER);
    else
      Result := nil;
    end;
end;

function TGpPen.GetColor: TARGB;
begin
  if PenType <> ptSolidColor then CheckStatus(WrongState);
  CheckStatus(GdipGetPenColor(Native, @Result));
end;

function TGpPen.GetCompoundArray(var compoundArray: array of Single): Integer;
begin
  Result := CompoundArrayCount;
  if Length(compoundArray) < Result then
    CheckStatus(InvalidParameter);
  CheckStatus(GdipGetPenCompoundArray(Native, @compoundArray, Result));
end;

function TGpPen.GetCompoundArrayCount: Integer;
begin
  CheckStatus(GdipGetPenCompoundCount(Native, Result));
end;

procedure TGpPen.GetCustomEndCap(customCap: TGpCustomLineCap);
begin
  CheckStatus(GdipGetPenCustomEndCap(Native, customCap.FNative));
end;

procedure TGpPen.GetCustomStartCap(customCap: TGpCustomLineCap);
begin
  CheckStatus(GdipGetPenCustomStartCap(Native, customCap.FNative));
end;

function TGpPen.GetDashCap: TDashCap;
begin
  CheckStatus(GdipGetPenDashCap197819(Native, GdipTypes.TDashCap(RV.rINT)));
  Result := TDashCap(RV.rINT);
end;

function TGpPen.GetDashOffset: Single;
begin
  CheckStatus(GdipGetPenDashOffset(Native, Result));
end;

function TGpPen.GetDashPattern(var dashArray: array of Single): Integer;
begin
  Result := DashPatternCount;
  if Length(dashArray) < Result then CheckStatus(InvalidParameter);
  CheckStatus(GdipGetPenDashArray(Native, @dashArray, Result));
end;

function TGpPen.GetDashPatternCount: Integer;
begin
  CheckStatus(GdipGetPenDashCount(Native, Result));
end;

function TGpPen.GetDashStyle: TDashStyle;
begin
  CheckStatus(GdipGetPenDashStyle(Native, GdipTypes.TDashStyle(RV.rINT)));
  Result := TDashStyle(RV.rINT);
end;

function TGpPen.GetEndCap: TLineCap;
begin
  CheckStatus(GdipGetPenEndCap(Native, GdipTypes.TLineCap(RV.rINT)));
  Result := TLineCap(RV.rINT);
end;

function TGpPen.GetLineJoin: TLineJoin;
begin
  CheckStatus(GdipGetPenLineJoin(Native, GdipTypes.TLineJoin(RV.rINT)));
  Result := TLineJoin(RV.rINT);
end;

function TGpPen.GetMiterLimit: Single;
begin
  CheckStatus(GdipGetPenMiterLimit(Native, Result));
end;

function TGpPen.GetPenType: TPenType;
begin
  CheckStatus(GdipGetPenFillType(Native, GdipTypes.TPenType(RV.rINT)));
  Result := TPenType(RV.rINT);
end;

function TGpPen.GetStartCap: TLineCap;
begin
  CheckStatus(GdipGetPenStartCap(Native, GdipTypes.TLineCap(RV.rINT)));
  Result := TLineCap(RV.rINT);
end;

procedure TGpPen.GetTransform(matrix: TGpMatrix);
begin
  CheckStatus(GdipGetPenTransform(Native, matrix.Native));
end;

function TGpPen.GetWidth: Single;
begin
  CheckStatus(GdipGetPenWidth(Native, Result));
end;

procedure TGpPen.MultiplyTransform(const matrix: TGpMatrix; order: TMatrixOrder);
begin
  CheckStatus(GdipMultiplyPenTransform(Native, matrix.Native, GdipTypes.TMatrixOrder(order)));
end;

procedure TGpPen.ResetTransform;
begin
   CheckStatus(GdipResetPenTransform(Native));
end;

procedure TGpPen.RotateTransform(angle: Single; order: TMatrixOrder);
begin
  CheckStatus(GdipRotatePenTransform(Native, angle, GdipTypes.TMatrixOrder(order)));
end;

procedure TGpPen.ScaleTransform(sx, sy: Single; order: TMatrixOrder);
begin
  CheckStatus(GdipScalePenTransform(Native, sx, sy, GdipTypes.TMatrixOrder(order)));
end;

procedure TGpPen.SetAlignment(penAlignment: TPenAlignment);
begin
  CheckStatus(GdipSetPenMode(Native, GdipTypes.TPenAlignment(penAlignment)));
end;

procedure TGpPen.SetBrush(const brush: TGpBrush);
begin
  CheckStatus(GdipSetPenBrushFill(Native, brush.Native));
end;

procedure TGpPen.SetColor(const color: TARGB);
begin
  CheckStatus(GdipSetPenColor(Native, color));
end;

procedure TGpPen.SetCompoundArray(compoundArray: array of Single);
begin
  CheckStatus(GdipSetPenCompoundArray(Native, @compoundArray, Length(compoundArray)));
end;

procedure TGpPen.SetCustomEndCap(const customCap: TGpCustomLineCap);
begin
  CheckStatus(GdipSetPenCustomEndCap(Native, ObjectNative(customCap)));
end;

procedure TGpPen.SetCustomStartCap(const customCap: TGpCustomLineCap);
begin
  CheckStatus(GdipSetPenCustomStartCap(Native, ObjectNative(customCap)));
end;

procedure TGpPen.SetDashCap(dashCap: TDashCap);
begin
  CheckStatus(GdipSetPenDashCap197819(Native, GdipTypes.TDashCap(dashCap)));
end;

procedure TGpPen.SetDashOffset(dashOffset: Single);
begin
  CheckStatus(GdipSetPenDashOffset(Native, dashOffset));
end;

procedure TGpPen.SetDashPattern(const dashArray: array of Single);
begin
  CheckStatus(GdipSetPenDashArray(Native, @dashArray, Length(dashArray)));
end;

procedure TGpPen.SetDashStyle(dashStyle: TDashStyle);
begin
  CheckStatus(GdipSetPenDashStyle(Native, GdipTypes.TDashStyle(dashStyle)));
end;

procedure TGpPen.SetEndCap(endCap: TLineCap);
begin
  CheckStatus(GdipSetPenEndCap(Native, GdipTypes.TLineCap(endCap)));
end;

procedure TGpPen.SetLineCap(startCap, endCap: TLineCap; dashCap: TDashCap);
begin
  CheckStatus(GdipSetPenLineCap197819(Native, GdipTypes.TLineCap(startCap),
        GdipTypes.TLineCap(endCap), GdipTypes.TDashCap(dashCap)));
end;

procedure TGpPen.SetLineJoin(lineJoin: TLineJoin);
begin
  CheckStatus(GdipSetPenLineJoin(Native, GdipTypes.TLineJoin(lineJoin)));
end;

procedure TGpPen.SetMiterLimit(miterLimit: Single);
begin
  CheckStatus(GdipSetPenMiterLimit(Native, miterLimit));
end;

procedure TGpPen.SetStartCap(startCap: TLineCap);
begin
  CheckStatus(GdipSetPenStartCap(Native, GdipTypes.TLineCap(startCap)));
end;

procedure TGpPen.SetTransform(const matrix: TGpMatrix);
begin
  CheckStatus(GdipSetPenTransform(Native, matrix.Native));
end;

procedure TGpPen.SetWidth(width: Single);
begin
  CheckStatus(GdipSetPenWidth(Native, width));
end;

procedure TGpPen.TranslateTransform(dx, dy: Single; order: TMatrixOrder);
begin
  CheckStatus(GdipTranslatePenTransform(Native, dx, dy, GdipTypes.TMatrixOrder(order)));
end;

type
  TGenericStringFormat = class(TGpStringFormat)
  public
    constructor Create;
    procedure FreeInstance; override;
  end;

{ TGenericStringFormat }

constructor TGenericStringFormat.Create;
begin

end;

procedure TGenericStringFormat.FreeInstance;
begin
  FGdipGenerics.GenericNil(Self);
  inherited;
end;

{ TGpStringFormat }

function TGpStringFormat.Clone: TGpStringFormat;
begin
  Result := TGpStringFormat.CreateClone(Native, @GdipCloneStringFormat);
end;

constructor TGpStringFormat.Create(format: TGpStringFormat);
begin
  CheckStatus(GdipCloneStringFormat(ObjectNative(format), FNative));
end;

constructor TGpStringFormat.Create(formatFlags: TStringFormatFlags; language: LANGID);
begin
  CheckStatus(GdipCreateStringFormat(Word(formatFlags), language, FNative));
end;

destructor TGpStringFormat.Destroy;
begin
  GdipDeleteStringFormat(Native);
end;

class function TGpStringFormat.GenericDefault: TGpStringFormat;
begin
  if FGdipGenerics.GenericDefaultStringFormatBuffer = nil then
  begin
    FGdipGenerics.GenericDefaultStringFormatBuffer := TGenericStringFormat.Create;
    GdipStringFormatGetGenericDefault(FGdipGenerics.GenericDefaultStringFormatBuffer.FNative);
  end;
  Result := FGdipGenerics.GenericDefaultStringFormatBuffer as TGpStringFormat;
end;

class function TGpStringFormat.GenericTypographic: TGpStringFormat;
begin
  if FGdipGenerics.GenericTypographicStringFormatBuffer = nil then
  begin
    FGdipGenerics.GenericTypographicStringFormatBuffer := TGenericStringFormat.Create;
    GdipStringFormatGetGenericTypographic(FGdipGenerics.GenericTypographicStringFormatBuffer.FNative);
  end;
  Result := FGdipGenerics.GenericTypographicStringFormatBuffer as TGpStringFormat;
end;

function TGpStringFormat.GetAlignment: TStringAlignment;
begin
  CheckStatus(GdipGetStringFormatAlign(Native, GdipTypes.TStringAlignment(RV.rINT)));
  Result := TStringAlignment(RV.rINT);
end;

function TGpStringFormat.GetDigitSubstitutionLanguage: LANGID;
begin
  CheckStatus(GdipGetStringFormatDigitSubstitution(Native, Result, GdipTypes.TStringDigitSubstitute(RV.rINT)));
end;

function TGpStringFormat.GetDigitSubstitutionMethod: TStringDigitSubstitute;
var
  v: LANGID;
begin
  CheckStatus(GdipGetStringFormatDigitSubstitution(Native, v, GdipTypes.TStringDigitSubstitute(RV.rINT)));
  Result := TStringDigitSubstitute(RV.rINT);
end;

function TGpStringFormat.GetFormatFlags: TStringFormatFlags;
begin
  CheckStatus(GdipGetStringFormatFlags(Native, RV.rINT));
  Result := TStringFormatFlags(Word(RV.rINT));
end;

function TGpStringFormat.GetHotkeyPrefix: THotkeyPrefix;
begin
  CheckStatus(GdipGetStringFormatHotkeyPrefix(Native, GdipTypes.THotkeyPrefix(RV.rINT)));
  Result := THotkeyPrefix(RV.rINT);
end;

function TGpStringFormat.GetLineAlignment: TStringAlignment;
begin
  CheckStatus(GdipGetStringFormatLineAlign(Native, GdipTypes.TStringAlignment(RV.rINT)));
  Result := TStringAlignment(RV.rINT);
end;

function TGpStringFormat.GetMeasurableCharacterRangeCount: Integer;
begin
  CheckStatus(GdipGetStringFormatMeasurableCharacterRangeCount(Native, Result));
end;

function TGpStringFormat.GetTabStopCount: Integer;
begin
  CheckStatus(GdipGetStringFormatTabStopCount(Native, Result));
end;

function TGpStringFormat.GetTabStops(var firstTabOffset: Single;
  var tabStops: array of Single): Integer;
begin
  Result := TabStopCount;
  if Length(tabStops) < Result then
    CheckStatus(InvalidParameter);
  CheckStatus(GdipGetStringFormatTabStops(Native, Result, firstTabOffset, @tabStops));
end;

function TGpStringFormat.GetTrimming: TStringTrimming;
begin
  CheckStatus(GdipGetStringFormatTrimming(Native, GdipTypes.TStringTrimming(RV.rINT)));
  Result := TStringTrimming(RV.rINT);
end;

procedure TGpStringFormat.SetAlignment(align: TStringAlignment);
begin
  CheckStatus(GdipSetStringFormatAlign(Native, GdipTypes.TStringAlignment(align)));
end;

procedure TGpStringFormat.SetDigitSubstitution(language: LANGID;
  substitute: TStringDigitSubstitute);
begin
  CheckStatus(GdipSetStringFormatDigitSubstitution(Native, language, GdipTypes.TStringDigitSubstitute(substitute)));
end;

procedure TGpStringFormat.SetFormatFlags(flags: TStringFormatFlags);
begin
  CheckStatus(GdipSetStringFormatFlags(Native, Word(flags)));
end;

procedure TGpStringFormat.SetHotkeyPrefix(hotkeyPrefix: THotkeyPrefix);
begin
  CheckStatus(GdipSetStringFormatHotkeyPrefix(Native, Integer(hotkeyPrefix)));
end;

procedure TGpStringFormat.SetLineAlignment(align: TStringAlignment);
begin
  CheckStatus(GdipSetStringFormatLineAlign(Native, GdipTypes.TStringAlignment(align)));
end;

procedure TGpStringFormat.SetMeasurableCharacterRanges(const ranges: array of TCharacterRange);
begin
  CheckStatus(GdipSetStringFormatMeasurableCharacterRanges(Native, Length(ranges), @ranges));
end;

procedure TGpStringFormat.SetTabStops(firstTabOffset: Single; tabStops: array of Single);
begin
  CheckStatus(GdipSetStringFormatTabStops(Native, firstTabOffset, Length(tabStops), @tabStops));
end;

procedure TGpStringFormat.SetTrimming(trimming: TStringTrimming);
begin
  CheckStatus(GdipSetStringFormatTrimming(Native, GdipTypes.TStringTrimming(trimming)));
end;

{ TGpGraphicsPath }

procedure PathTypeEncode(ts: PPathPointTypes; count: Integer);
asm
  mov   ecx, eax
@@1:
  dec   edx
  js    @@5
  mov   al, [ecx]
  test  al, 4
  jz    @@2
  or    al, 3
  jmp   @@3
@@2:
  test  al, 2
  jz    @@4
  or    al, 1
@@3:
  mov   [ecx], al
@@4:
  inc   ecx
  jmp   @@1
@@5:
end;

procedure TGpGraphicsPath.AddArc(x, y, width, height, startAngle, sweepAngle: Single);
begin
  CheckStatus(GdipAddPathArc(Native, x, y, width, height, startAngle, sweepAngle));
end;

procedure TGpGraphicsPath.AddArc(const rect: TGpRectF; startAngle, sweepAngle: Single);
begin
  AddArc(rect.X, rect.Y, rect.Width, rect.Height, startAngle, sweepAngle);
end;

procedure TGpGraphicsPath.AddArc(x, y, width, height: Integer; startAngle, sweepAngle: Single);
begin
  CheckStatus(GdipAddPathArcI(Native, x, y, width, height, startAngle, sweepAngle));
end;

procedure TGpGraphicsPath.AddArc(const rect: TGpRect; startAngle, sweepAngle: Single);
begin
  AddArc(rect.X, rect.Y, rect.Width, rect.Height, startAngle, sweepAngle);
end;

procedure TGpGraphicsPath.AddBezier(x1, y1, x2, y2, x3, y3, x4, y4: Integer);
begin
  CheckStatus(GdipAddPathBezierI(Native, x1, y1, x2, y2, x3, y3, x4, y4));
end;

procedure TGpGraphicsPath.AddBezier(const pt1, pt2, pt3, pt4: TGpPoint);
begin
  AddBezier(pt1.X, pt1.Y, pt2.X, pt2.Y, pt3.X, pt3.Y, pt4.X, pt4.Y);
end;

procedure TGpGraphicsPath.AddBezier(const pt1, pt2, pt3, pt4: TGpPointF);
begin
  AddBezier(pt1.X, pt1.Y, pt2.X, pt2.Y, pt3.X, pt3.Y, pt4.X, pt4.Y);
end;

procedure TGpGraphicsPath.AddBezier(x1, y1, x2, y2, x3, y3, x4, y4: Single);
begin
  CheckStatus(GdipAddPathBezier(Native, x1, y1, x2, y2, x3, y3, x4, y4));
end;

procedure TGpGraphicsPath.AddBeziers(const points: array of TGpPointF);
begin
  CheckStatus(GdipAddPathBeziers(Native, @points, Length(points)));
end;

procedure TGpGraphicsPath.AddBeziers(const points: array of TGpPoint);
begin
  CheckStatus(GdipAddPathBeziersI(Native, @points, Length(points)));
end;

procedure TGpGraphicsPath.AddClosedCurve(const points: array of TGpPoint);
begin
  CheckStatus(GdipAddPathClosedCurveI(Native, @points, Length(points)));
end;

procedure TGpGraphicsPath.AddClosedCurve(const points: array of TGpPoint; tension: Single);
begin
  CheckStatus(GdipAddPathClosedCurve2I(Native, @points, Length(points), tension));
end;

procedure TGpGraphicsPath.AddClosedCurve(const points: array of TGpPointF);
begin
  CheckStatus(GdipAddPathClosedCurve(Native, @points, Length(points)));
end;

procedure TGpGraphicsPath.AddClosedCurve(const points: array of TGpPointF; tension: Single);
begin
  CheckStatus(GdipAddPathClosedCurve2(Native, @points, Length(points), tension));
end;

procedure TGpGraphicsPath.AddCurve(const points: array of TGpPoint);
begin
  CheckStatus(GdipAddPathCurveI(Native, @points, Length(points)));
end;

procedure TGpGraphicsPath.AddCurve(const points: array of TGpPoint; tension: Single);
begin
  CheckStatus(GdipAddPathCurve2I(Native, @points, Length(points), tension));
end;

procedure TGpGraphicsPath.AddCurve(const points: array of TGpPoint;
  offset, numberOfSegments: Integer; tension: Single);
begin
  CheckStatus(GdipAddPathCurve3I(Native, @points, Length(points), offset, numberOfSegments, tension));
end;

procedure TGpGraphicsPath.AddCurve(const points: array of TGpPointF);
begin
  CheckStatus(GdipAddPathCurve(Native, @points, Length(points)));
end;

procedure TGpGraphicsPath.AddCurve(const points: array of TGpPointF; tension: Single);
begin
  CheckStatus(GdipAddPathCurve2(Native, @points, Length(points), tension));
end;

procedure TGpGraphicsPath.AddCurve(const points: array of TGpPointF;
  offset, numberOfSegments: Integer; tension: Single);
begin
  CheckStatus(GdipAddPathCurve3(Native, @points, Length(points), offset, numberOfSegments, tension));
end;

procedure TGpGraphicsPath.AddEllipse(const rect: TGpRect);
begin
  AddEllipse(rect.X, rect.Y, rect.Width, rect.Height);
end;

procedure TGpGraphicsPath.AddEllipse(x, y, Width, Height: Single);
begin
  CheckStatus(GdipAddPathEllipse(Native, x, y, width, height));
end;

procedure TGpGraphicsPath.AddEllipse(const rect: TGpRectF);
begin
  AddEllipse(rect.X, rect.Y, rect.Width, rect.Height);
end;

procedure TGpGraphicsPath.AddEllipse(x, y, Width, Height: Integer);
begin
  CheckStatus(GdipAddPathEllipseI(Native, x, y, width, height));
end;

procedure TGpGraphicsPath.AddLine(x1, y1, x2, y2: Integer);
begin
  CheckStatus(GdipAddPathLineI(Native, x1, y1, x2, y2));
end;

procedure TGpGraphicsPath.AddLine(const pt1, pt2: TGpPoint);
begin
  AddLine(pt1.X, pt1.Y, pt2.X, pt2.Y);
end;

procedure TGpGraphicsPath.AddLine(const pt1, pt2: TGpPointF);
begin
  AddLine(pt1.X, pt1.Y, pt2.X, pt2.Y);
end;

procedure TGpGraphicsPath.AddLine(x1, y1, x2, y2: Single);
begin
  CheckStatus(GdipAddPathLine(Native, x1, y1, x2, y2));
end;

procedure TGpGraphicsPath.AddLines(const points: array of TGpPoint);
begin
  CheckStatus(GdipAddPathLine2I(Native, @points, Length(points)));
end;

procedure TGpGraphicsPath.AddLines(const points: array of TGpPointF);
begin
  CheckStatus(GdipAddPathLine2(Native, @points, Length(points)));
end;

procedure TGpGraphicsPath.AddPath(const addingPath: TGpGraphicsPath; connect: Boolean);
begin
  CheckStatus(GdipAddPathPath(Native, ObjectNative(addingPath), connect));
end;

procedure TGpGraphicsPath.AddPie(const rect: TGpRect; startAngle, sweepAngle: Single);
begin
  AddPie(rect.X, rect.Y, rect.Width, rect.Height, startAngle, sweepAngle);
end;

procedure TGpGraphicsPath.AddPie(x, y, Width, Height: Integer; startAngle, sweepAngle: Single);
begin
  CheckStatus(GdipAddPathPieI(Native, x, y, width, height, startAngle, sweepAngle));
end;

procedure TGpGraphicsPath.AddPie(const rect: TGpRectF; startAngle, sweepAngle: Single);
begin
  AddPie(rect.X, rect.Y, rect.Width, rect.Height, startAngle, sweepAngle);
end;

procedure TGpGraphicsPath.AddPie(x, y, Width, Height, startAngle, sweepAngle: Single);
begin
  CheckStatus(GdipAddPathPie(Native, x, y, width, height, startAngle, sweepAngle));
end;

procedure TGpGraphicsPath.AddPolygon(const points: array of TGpPoint);
begin
  CheckStatus(GdipAddPathPolygonI(Native, @points, Length(points)));
end;

procedure TGpGraphicsPath.AddPolygon(const points: array of TGpPointF);
begin
  CheckStatus(GdipAddPathPolygon(Native, @points, Length(points)));
end;

procedure TGpGraphicsPath.AddRectangle(const rect: TGpRect);
begin
  AddRectangle(rect.X, rect.Y, rect.Width, rect.Height);
end;

procedure TGpGraphicsPath.AddRectangle(const rect: TGpRectF);
begin
  AddRectangle(rect.X, rect.Y, rect.Width, rect.Height);
end;

procedure TGpGraphicsPath.AddRectangle(x, y, Width, Height: Single);
begin
  CheckStatus(GdipAddPathRectangle(Native, x, y, Width, Height));
end;

procedure TGpGraphicsPath.AddRectangle(x, y, Width, Height: Integer);
begin
  CheckStatus(GdipAddPathRectangleI(Native, x, y, Width, Height));
end;

procedure TGpGraphicsPath.AddRectangles(const rects: array of TGpRect);
begin
  CheckStatus(GdipAddPathRectanglesI(Native, @rects, Length(rects)));
end;

procedure TGpGraphicsPath.AddRectangles(const rects: array of TGpRectF);
begin
  CheckStatus(GdipAddPathRectangles(Native, @rects, Length(rects)));
end;

procedure TGpGraphicsPath.AddString(const str: WideString;
  const family: TGpFontFamily; style: TFontStyles; emSize: Single;
  const origin: TGpPoint; const format: TGpStringFormat);
var
  r: TGpRect;
begin
  r := GpRect(origin.X, origin.Y, 0, 0);
  CheckStatus(GdipAddPathStringI(Native, PWChar(str), Length(str),
              ObjectNative(family), Byte(style), emSize, @r, ObjectNative(format)));
end;

procedure TGpGraphicsPath.AddString(const str: WideString;
  const family: TGpFontFamily; style: TFontStyles; emSize: Single;
  const layoutRect: TGpRect; const format: TGpStringFormat);
begin
  CheckStatus(GdipAddPathStringI(Native, PWChar(str), Length(str),
              ObjectNative(family), Byte(style), emSize, @layoutRect, ObjectNative(format)));
end;

procedure TGpGraphicsPath.AddString(const str: WideString;
  const family: TGpFontFamily; style: TFontStyles; emSize: Single;
  const origin: TGpPointF; const format: TGpStringFormat);
var
  r: TGpRectF;
begin
  r := GpRect(origin.X, origin.Y, 0, 0);
  CheckStatus(GdipAddPathString(Native, PWChar(str), Length(str),
              ObjectNative(family), Byte(style), emSize, @r, ObjectNative(format)));
end;

procedure TGpGraphicsPath.AddString(const str: WideString;
  const family: TGpFontFamily; style: TFontStyles; emSize: Single;
  const layoutRect: TGpRectF; const format: TGpStringFormat);
begin
  CheckStatus(GdipAddPathString(Native, PWChar(str), Length(str),
              ObjectNative(family), Byte(style), emSize, @layoutRect, ObjectNative(format)));
end;

procedure TGpGraphicsPath.ClearMarkers;
begin
  CheckStatus(GdipClearPathMarkers(Native));
end;

function TGpGraphicsPath.Clone: TGpGraphicsPath;
begin
  Result := TGpGraphicsPath.CreateClone(Native, @GdipClonePath);
end;

procedure TGpGraphicsPath.CloseAllFigures;
begin
  CheckStatus(GdipClosePathFigures(Native));
end;

procedure TGpGraphicsPath.CloseFigure;
begin
  CheckStatus(GdipClosePathFigure(Native));
end;

constructor TGpGraphicsPath.Create(points: array of TGpPointF;
  types: array of TPathPointTypes; fillMode: Vcl.Graphics.TFillMode);
var
  count: Integer;
begin
  count := Length(points);
  if (count = 0) or (count > Length(types)) then
    CheckStatus(InvalidParameter);
  PathTypeEncode(@types, count);
  CheckStatus(GdipCreatePath2(@points, @types, count, GdipTypes.TFillMode(fillMode), FNative));
end;

constructor TGpGraphicsPath.Create(points: array of TGpPoint;
  types: array of TPathPointTypes; fillMode: Vcl.Graphics.TFillMode);
var
  count: Integer;
begin
  count := Length(points);
  if (count = 0) or (count > Length(types)) then
    CheckStatus(InvalidParameter);
  PathTypeEncode(@types, count);
  CheckStatus(GdipCreatePath2I(@points, @types, count, GdipTypes.TFillMode(fillMode), FNative));
end;

constructor TGpGraphicsPath.Create(fillMode: Vcl.Graphics.TFillMode);
begin
  CheckStatus(GdipCreatePath(GdipTypes.TFillMode(fillMode), FNative));
end;
{
constructor TGpGraphicsPath.Create(points: PGpPointF; types: PPathPointTypes;
  count: Integer; fillMode: Graphics.TFillMode);
begin
  CheckStatus(GdipCreatePath2(points, PByte(types), count, GdipTypes.TFillMode(fillMode), FNative));
end;

constructor TGpGraphicsPath.Create(points: PGpPoint; types: PPathPointTypes;
  count: Integer; fillMode: Graphics.TFillMode);
begin
  CheckStatus(GdipCreatePath2I(points, PByte(types), count, GdipTypes.TFillMode(fillMode), FNative));
end;
}
destructor TGpGraphicsPath.Destroy;
begin
  GdipDeletePath(Native);
end;

procedure TGpGraphicsPath.Flatten(const matrix: TGpMatrix; flatness: Single);
begin
  CheckStatus(GdipFlattenPath(Native, ObjectNative(matrix), flatness));
end;

procedure TGpGraphicsPath.GetBounds(var bounds: TGpRect; const matrix: TGpMatrix; const pen: TGpPen);
begin
  CheckStatus(GdipGetPathWorldBoundsI(Native, @bounds,
                            ObjectNative(matrix), ObjectNative(pen)));
end;

procedure TGpGraphicsPath.GetBounds(var bounds: TGpRectF; const matrix: TGpMatrix; const pen: TGpPen);
begin
  CheckStatus(GdipGetPathWorldBounds(Native, @bounds,
                         ObjectNative(matrix), ObjectNative(pen)));
end;

function TGpGraphicsPath.GetFillMode: Vcl.Graphics.TFillMode;
begin
  CheckStatus(GdipGetPathFillMode(Native, GdipTypes.TFillMode(RV.rINT)));
  Result := Vcl.Graphics.TFillMode(RV.rINT);
end;

function TGpGraphicsPath.GetLastPoint: TGpPointF;
begin
  CheckStatus(GdipGetPathLastPoint(Native, @Result));
end;

function TGpGraphicsPath.GetPathData: TPathData;
begin
  Result.Count := PointCount;
  if Result.Count = 0 then Exit;
  SetLength(Result.Points, Result.Count);
  SetLength(Result.Types, Result.Count);
  GetPathPoints(Result.Points);
  GetPathTypes(Result.Types);
end;

procedure TGpGraphicsPath.GetPathPoints(var points: array of TGpPoint);
begin
  CheckStatus(GdipGetPathPointsI(Native, @points, PointCount));
end;

procedure TGpGraphicsPath.GetPathPoints(var points: array of TGpPointF);
begin
  CheckStatus(GdipGetPathPoints(Native, @points, PointCount));
end;

procedure TGpGraphicsPath.GetPathTypes(var types: array of TPathPointTypes);
var
  ts: PByte;
begin
  ts := PByte(@types);
  CheckStatus(GdipGetPathTypes(Native, ts, PointCount));
end;

function TGpGraphicsPath.GetPointCount: Integer;
begin
  CheckStatus(GdipGetPointCount(Native, Result));
end;

function TGpGraphicsPath.IsOutlineVisible(const point: TGpPoint;
  const pen: TGpPen; const g: TGpGraphics): Boolean;
begin
  Result := IsOutlineVisible(point.X, point.Y, pen, g);
end;

function TGpGraphicsPath.IsOutlineVisible(x, y: Integer; const pen: TGpPen;
  const g: TGpGraphics): Boolean;
begin
  CheckStatus(GdipIsOutlineVisiblePathPointI(Native, x, y,
                           ObjectNative(pen), ObjectNative(g), RV.rBOOL));
  Result := RV.rBOOL;
end;

function TGpGraphicsPath.IsOutlineVisible(x, y: Single; const pen: TGpPen;
  const g: TGpGraphics): Boolean;
begin
  CheckStatus(GdipIsOutlineVisiblePathPoint(Native, x, y,
                           ObjectNative(pen), ObjectNative(g), RV.rBOOL));
  Result := RV.rBOOL;
end;

function TGpGraphicsPath.IsOutlineVisible(const point: TGpPointF;
  const pen: TGpPen; const g: TGpGraphics): Boolean;
begin
  Result := IsOutlineVisible(point.X, point.Y, pen, g);
end;

function TGpGraphicsPath.IsVisible(x, y: Single; const g: TGpGraphics): Boolean;
begin
  CheckStatus(GdipIsVisiblePathPoint(Native, x, y, ObjectNative(g), RV.rBOOL));
  Result := RV.rBOOL;
end;

function TGpGraphicsPath.IsVisible(x, y: Integer; const g: TGpGraphics): Boolean;
begin
  CheckStatus(GdipIsVisiblePathPointI(Native, x, y, ObjectNative(g), RV.rBOOL));
  Result := RV.rBOOL;
end;

function TGpGraphicsPath.IsVisible(const point: TGpPointF; const g: TGpGraphics): Boolean;
begin
  Result := IsVisible(point.X, point.Y, g);
end;

function TGpGraphicsPath.IsVisible(const point: TGpPoint; const g: TGpGraphics): Boolean;
begin
  Result := IsVisible(point.X, point.Y, g);
end;

procedure TGpGraphicsPath.Outline(const matrix: TGpMatrix; flatness: Single);
begin
  CheckStatus(GdipWindingModeOutline(Native, ObjectNative(matrix), flatness));
end;

procedure TGpGraphicsPath.Reset;
begin
  CheckStatus(GdipResetPath(Native));
end;

procedure TGpGraphicsPath.Reverse;
begin
  CheckStatus(GdipReversePath(Native));
end;

procedure TGpGraphicsPath.SetFillMode(fillMode: Vcl.Graphics.TFillMode);
begin
  CheckStatus(GdipSetPathFillMode(Native, GdipTypes.TFillMode(fillMode)));
end;

procedure TGpGraphicsPath.SetMarker;
begin
  CheckStatus(GdipSetPathMarker(Native));
end;

procedure TGpGraphicsPath.StartFigure;
begin
  CheckStatus(GdipStartPathFigure(Native));
end;

procedure TGpGraphicsPath.Transform(const matrix: TGpMatrix);
begin
  CheckStatus(GdipTransformPath(Native, matrix.Native));
end;

procedure TGpGraphicsPath.Warp(const destPoints: array of TGpPointF;
  const srcRect: TGpRectF; const matrix: TGpMatrix; warpMode: TWarpMode; flatness: Single);
begin
  CheckStatus(GdipWarpPath(Native, ObjectNative(matrix), @destPoints,
                           Length(destPoints), srcRect.X,  srcRect.Y,
                           srcRect.Width, srcRect.Height, GdipTypes.TWarpMode(warpMode), flatness));
end;

procedure TGpGraphicsPath.Widen(const pen: TGpPen; const matrix: TGpMatrix; flatness: Single);
begin
  CheckStatus(GdipWidenPath(Native, pen.Native, ObjectNative(matrix), flatness));
end;

{ TGpGraphicsPathIterator }

function TGpGraphicsPathIterator.CopyData(var points: array of TGpPointF;
  var types: array of TPathPointTypes; startIndex, endIndex: Integer): Integer;
var
  ts: PByte;
begin
  ts := PByte(@types);
  CheckStatus(GdipPathIterCopyData(Native, Result, @points, ts, startIndex, endIndex));
end;

constructor TGpGraphicsPathIterator.Create(path: TGpGraphicsPath);
begin
  CheckStatus(GdipCreatePathIter(FNative, ObjectNative(path)));
end;

destructor TGpGraphicsPathIterator.Destroy;
begin
  GdipDeletePathIter(Native);
end;

function TGpGraphicsPathIterator.Enumerate(var points: array of TGpPointF;
  var types: array of TPathPointTypes): Integer;
var
  ts: PByte;
begin
  ts := PByte(@types);
  CheckStatus(GdipPathIterEnumerate(Native, Result, @points, ts, Length(points)));
end;

function TGpGraphicsPathIterator.GetCount: Integer;
begin
  CheckStatus(GdipPathIterGetCount(Native, Result));
end;

function TGpGraphicsPathIterator.GetSubpathCount: Integer;
begin
  CheckStatus(GdipPathIterGetSubpathCount(Native, Result));
end;

function TGpGraphicsPathIterator.HasCurve: Boolean;
begin
  CheckStatus(GdipPathIterHasCurve(Native, RV.rBOOL));
  Result := RV.rBOOL;
end;

function TGpGraphicsPathIterator.NextMarker(var startIndex, endIndex: Integer): Integer;
begin
  CheckStatus(GdipPathIterNextMarker(Native, Result, startIndex, endIndex));
end;

function TGpGraphicsPathIterator.NextMarker(const path: TGpGraphicsPath): Integer;
begin
  CheckStatus(GdipPathIterNextMarkerPath(Native, Result, ObjectNative(path)));
end;

function TGpGraphicsPathIterator.NextPathType(var pathType: TPathPointTypes;
  var startIndex, endIndex: Integer): Integer;
begin
  CheckStatus(GdipPathIterNextPathType(Native, Result, @RV.rBYTE, startIndex, endIndex));
  pathType := TPathPointTypes(RV.rBYTE);
end;

function TGpGraphicsPathIterator.NextSubpath(var startIndex,
  endIndex: Integer; var isClosed: Boolean): Integer;
begin
  CheckStatus(GdipPathIterNextSubpath(Native, Result, startIndex, endIndex, RV.rBOOL));
  isClosed := RV.rBOOL;
end;

function TGpGraphicsPathIterator.NextSubpath(const path: TGpGraphicsPath;
  var isClosed: Boolean): Integer;
begin
  CheckStatus(GdipPathIterNextSubpathPath(Native, Result, ObjectNative(path), RV.rBOOL));
  isClosed := RV.rBOOL;
end;

procedure TGpGraphicsPathIterator.Rewind;
begin
  CheckStatus(GdipPathIterRewind(Native));
end;

{ TGpGraphics }

procedure TGpGraphics.AddMetafileComment(const data: PBYTE; sizeData: Integer);
begin
  CheckStatus(GdipComment(Native, sizeData, data));
end;

function TGpGraphics.BeginContainer: TGraphicsContainer;
begin
  CheckStatus(GdipBeginContainer2(Native, Result));
end;

function TGpGraphics.BeginContainer(const dstrect, srcrect: TGpRectF;
  unit_: TUnit): TGraphicsContainer;
begin
  CheckStatus(GdipBeginContainer(Native, @dstrect, @srcrect, GdipTypes.TUnit(unit_), Result));
end;

function TGpGraphics.BeginContainer(const dstrect, srcrect: TGpRect;
  unit_: TUnit): TGraphicsContainer;
begin
  CheckStatus(GdipBeginContainerI(Native, @dstrect, @srcrect, GdipTypes.TUnit(unit_), Result));
end;

procedure TGpGraphics.Clear(const color: TARGB);
begin
  CheckStatus(GdipGraphicsClear(Native, color));
end;

constructor TGpGraphics.Create(hwnd: HWND; icm: Boolean);
begin
  if icm then
    CheckStatus(GdipCreateFromHWNDICM(hwnd, FNative))
  else
    CheckStatus(GdipCreateFromHWND(hwnd, FNative));
end;

constructor TGpGraphics.Create(image: TGpImage);
begin
  if not Assigned(image) then CheckStatus(InvalidParameter);
  CheckStatus(GdipGetImageGraphicsContext(image.Native, FNative));
end;

constructor TGpGraphics.Create(hdc: HDC);
begin
  CheckStatus(GdipCreateFromHDC(hdc, FNative));
end;

constructor TGpGraphics.Create(hdc: HDC; hdevice: THANDLE);
begin
  CheckStatus(GdipCreateFromHDC2(hdc, hdevice, FNative));
end;

destructor TGpGraphics.Destroy;
begin
  GdipDeleteGraphics(Native);
end;

procedure TGpGraphics.DrawArc(const pen: TGpPen; const rect: TGpRectF;
  startAngle, sweepAngle: Single);
begin
  DrawArc(pen, rect.X, rect.Y, rect.Width, rect.Height, startAngle, sweepAngle);
end;

procedure TGpGraphics.DrawArc(const pen: TGpPen; x, y, width, height,
  startAngle, sweepAngle: Single);
begin
  CheckStatus(GdipDrawArc(Native, pen.Native, x, y, width, height, startAngle, sweepAngle));
end;

procedure TGpGraphics.DrawArc(const pen: TGpPen; const rect: TGpRect; startAngle, sweepAngle: Single);
begin
  DrawArc(pen, rect.X, rect.Y, rect.Width, rect.Height, startAngle, sweepAngle);
end;

procedure TGpGraphics.DrawArc(const pen: TGpPen; x, y, width, height: Integer;
  startAngle, sweepAngle: Single);
begin
  CheckStatus(GdipDrawArcI(Native, pen.Native, x, y, width, height, startAngle, sweepAngle));
end;

procedure TGpGraphics.DrawBezier(const pen: TGpPen; const pt1, pt2, pt3, pt4: TGpPointF);
begin
  DrawBezier(pen, pt1.X, pt1.Y, pt2.X, pt2.Y, pt3.X, pt3.Y, pt4.X, pt4.Y);
end;

procedure TGpGraphics.DrawBezier(const pen: TGpPen; x1, y1, x2, y2, x3, y3, x4, y4: Single);
begin
  CheckStatus(GdipDrawBezier(Native, pen.Native, x1, y1, x2, y2, x3, y3, x4, y4));
end;

procedure TGpGraphics.DrawBezier(const pen: TGpPen; x1, y1, x2, y2, x3, y3, x4, y4: Integer);
begin
  CheckStatus(GdipDrawBezierI(Native, pen.Native, x1, y1, x2, y2, x3, y3, x4, y4));
end;

procedure TGpGraphics.DrawBezier(const pen: TGpPen; const pt1, pt2, pt3, pt4: TGpPoint);
begin
  DrawBezier(pen, pt1.X, pt1.Y, pt2.X, pt2.Y, pt3.X, pt3.Y, pt4.X, pt4.Y);
end;

procedure TGpGraphics.DrawBeziers(const pen: TGpPen; const points: array of TGpPointF);
begin
  CheckStatus(GdipDrawBeziers(Native, pen.Native, @points, Length(points)));
end;

procedure TGpGraphics.DrawBeziers(const pen: TGpPen; const points: array of TGpPoint);
begin
  CheckStatus(GdipDrawBeziersI(Native, pen.Native, @points, Length(points)));
end;

procedure TGpGraphics.DrawCachedBitmap(cb: TGpCachedBitmap; x, y: Integer);
begin
  CheckStatus(GdipDrawCachedBitmap(Native, cb.Native, x, y));
end;

procedure TGpGraphics.DrawClosedCurve(const pen: TGpPen; const points: array of TGpPointF);
begin
  CheckStatus(GdipDrawClosedCurve(Native, pen.Native, @points, Length(points)));
end;

procedure TGpGraphics.DrawClosedCurve(const pen: TGpPen; const points: array of TGpPointF;
  tension: Single);
begin
  CheckStatus(GdipDrawClosedCurve2(Native, pen.Native, @points, Length(points), tension));
end;

procedure TGpGraphics.DrawClosedCurve(const pen: TGpPen; const points: array of TGpPoint);
begin
  CheckStatus(GdipDrawClosedCurveI(Native, pen.Native, @points, Length(points)));
end;

procedure TGpGraphics.DrawClosedCurve(const pen: TGpPen; const points: array of TGpPoint;
  tension: Single);
begin
  CheckStatus(GdipDrawClosedCurve2I(Native, pen.Native, @points, Length(points), tension));
end;

procedure TGpGraphics.DrawCurve(const pen: TGpPen; const points: array of TGpPointF; tension: Single);
begin
  CheckStatus(GdipDrawCurve2(Native, pen.Native, @points, Length(points), tension));
end;

procedure TGpGraphics.DrawCurve(const pen: TGpPen; const points: array of TGpPoint; tension: Single);
begin
  CheckStatus(GdipDrawCurve2I(Native, pen.Native, @points, Length(points), tension));
end;

procedure TGpGraphics.DrawCurve(const pen: TGpPen; const points: array of TGpPointF;
  offset, numberOfSegments: Integer; tension: Single);
begin
  CheckStatus(GdipDrawCurve3(Native, pen.Native, @points, Length(points),
                             offset, numberOfSegments, tension));
end;

procedure TGpGraphics.DrawCurve(const pen: TGpPen; const points: array of TGpPoint;
  offset, numberOfSegments: Integer; tension: Single);
begin
  CheckStatus(GdipDrawCurve3I(Native, pen.Native, @points, Length(points),
                              offset, numberOfSegments, tension));
end;

procedure TGpGraphics.DrawCurve(const pen: TGpPen; const points: array of TGpPoint);
begin
  CheckStatus(GdipDrawCurveI(Native, pen.Native, @points, Length(points)));
end;

procedure TGpGraphics.DrawCurve(const pen: TGpPen; const points: array of TGpPointF);
begin
  CheckStatus(GdipDrawCurve(Native, pen.Native, @points, Length(points)));
end;

procedure TGpGraphics.DrawDriverString(const text: PUINT16; length: Integer;
  const font: TGpFont; const brush: TGpBrush; const positions: PGpPointF;
  flags: Integer; const matrix: TGpMatrix);
begin
  CheckStatus(GdipDrawDriverString(Native, text, length,
              ObjectNative(font), ObjectNative(brush),
              positions, flags, ObjectNative(matrix)));
end;

procedure TGpGraphics.DrawEllipse(const pen: TGpPen; x, y, width, height: Single);
begin
  CheckStatus(GdipDrawEllipse(Native, pen.Native, x, y, width, height));
end;

procedure TGpGraphics.DrawEllipse(const pen: TGpPen; const rect: TGpRect);
begin
  DrawEllipse(pen, rect.X, rect.Y, rect.Width, rect.Height);
end;

procedure TGpGraphics.DrawEllipse(const pen: TGpPen; x, y, width, height: Integer);
begin
  CheckStatus(GdipDrawEllipseI(Native, pen.Native, x, y, width, height));
end;

procedure TGpGraphics.DrawEllipse(const pen: TGpPen; const rect: TGpRectF);
begin
  DrawEllipse(pen, rect.X, rect.Y, rect.Width, rect.Height);
end;

procedure TGpGraphics.DrawImage(image: TGpImage; const destRect: TGpRect; srcx,
  srcy, srcwidth, srcheight: Integer; srcUnit: TUnit;
  const imageAttributes: TGpImageAttributes; callback: TDrawImageAbort;
  callbackData: Pointer);
begin
  CheckStatus(GdipDrawImageRectRectI(Native, ObjectNative(image),
                  destRect.X, destRect.Y, destRect.Width, destRect.Height,
                  srcx, srcy, srcwidth, srcheight, GdipTypes.TUnit(srcUnit),
                  ObjectNative(imageAttributes), callback, callbackData));
end;

procedure TGpGraphics.DrawImage(image: TGpImage; const destPoints: array of TGpPoint;
  srcx, srcy, srcwidth, srcheight: Integer; srcUnit: TUnit;
  const imageAttributes: TGpImageAttributes; callback: TDrawImageAbort;
  callbackData: Pointer);
begin
  CheckStatus(GdipDrawImagePointsRectI(Native, ObjectNative(image),
                  @destPoints, Length(DestPoints), srcx, srcy, srcwidth, srcheight,
                  GdipTypes.TUnit(srcUnit), ObjectNative(imageAttributes), callback, callbackData));
end;

procedure TGpGraphics.DrawImage(image: TGpImage; const destPoints: array of TGpPoint);
var
  count: Integer;
begin
  count := Length(destPoints);
  if (count <> 3) and (count <> 4) then
    CheckStatus(InvalidParameter);
  CheckStatus(GdipDrawImagePointsI(Native, ObjectNative(image), @destPoints, count));
end;

procedure TGpGraphics.DrawImage(image: TGpImage; x, y: Single; srcRect: TGpRectF; srcUnit: TUnit);
begin
  CheckStatus(GdipDrawImagePointRect(Native, ObjectNative(image),
                  x, y, srcRect.X, srcRect.Y, srcRect.Width, srcRect.Height, GdipTypes.TUnit(srcUnit)));
end;

procedure TGpGraphics.DrawImage(image: TGpImage; x, y: Integer; srcRect: TGpRect; srcUnit: TUnit);
begin
  CheckStatus(GdipDrawImagePointRectI(Native, ObjectNative(image),
                  x, y, srcRect.X, srcRect.Y, srcRect.Width, srcRect.Height, GdipTypes.TUnit(srcUnit)));
end;

procedure TGpGraphics.DrawImage(image: TGpImage; x, y, srcx, srcy, srcwidth,
  srcheight: Integer; srcUnit: TUnit);
begin
  CheckStatus(GdipDrawImagePointRectI(Native, ObjectNative(image),
                  x, y, srcx, srcy, srcwidth, srcheight, GdipTypes.TUnit(srcUnit)));
end;

procedure TGpGraphics.DrawImage(image: TGpImage; x, y, srcx, srcy, srcwidth,
  srcheight: Single; srcUnit: TUnit);
begin
  CheckStatus(GdipDrawImagePointRect(Native, ObjectNative(image),
                  x, y, srcx, srcy, srcwidth, srcheight, GdipTypes.TUnit(srcUnit)));
end;

procedure TGpGraphics.DrawImage(image: TGpImage; const destRect: TGpRectF; srcx,
  srcy, srcwidth, srcheight: Single; srcUnit: TUnit;
  const imageAttributes: TGpImageAttributes; callback: TDrawImageAbort;
  callbackData: Pointer);
begin
  CheckStatus(GdipDrawImageRectRect(Native, ObjectNative(image),
                  destRect.X, destRect.Y, destRect.Width, destRect.Height,
                  srcx, srcy, srcwidth, srcheight, GdipTypes.TUnit(srcUnit),
                  ObjectNative(imageAttributes), callback, callbackData));
end;

procedure TGpGraphics.DrawImage(image: TGpImage; const destPoints: array of TGpPointF;
  srcx, srcy, srcwidth, srcheight: Single; srcUnit: TUnit;
  const imageAttributes: TGpImageAttributes; callback: TDrawImageAbort;
  callbackData: Pointer);
begin
  CheckStatus(GdipDrawImagePointsRect(Native, ObjectNative(image), @destPoints,
                  Length(destPoints), srcx, srcy, srcwidth, srcheight, GdipTypes.TUnit(srcUnit),
                  ObjectNative(imageAttributes), callback, callbackData));
end;

procedure TGpGraphics.DrawImage(image: TGpImage; const destPoints: array of TGpPointF);
var
  count: Integer;
begin
  count := Length(destPoints);
  if (count <> 3) and (count <> 4) then
    CheckStatus(InvalidParameter);
  CheckStatus(GdipDrawImagePoints(Native, ObjectNative(image), @destPoints, count));
end;

procedure TGpGraphics.DrawImage(image: TGpImage; const point: TGpPoint);
begin
  DrawImage(image, point.X, point.Y);
end;

procedure TGpGraphics.DrawImage(image: TGpImage; x, y: Integer);
begin
  CheckStatus(GdipDrawImageI(Native, ObjectNative(image), x, y));
end;

procedure TGpGraphics.DrawImage(image: TGpImage; const rect: TGpRect);
begin
  DrawImage(image, rect.X, rect.Y, rect.Width, rect.Height);
end;

procedure TGpGraphics.DrawImage(image: TGpImage; x, y, width, height: Single);
begin
  CheckStatus(GdipDrawImageRect(Native, ObjectNative(image), x, y, width, height));
end;

procedure TGpGraphics.DrawImage(image: TGpImage; const point: TGpPointF);
begin
  DrawImage(image, point.X, point.Y);
end;

procedure TGpGraphics.DrawImage(image: TGpImage; x, y: Single);
begin
  CheckStatus(GdipDrawImage(Native, ObjectNative(image), x, y));
end;

procedure TGpGraphics.DrawImage(image: TGpImage; const rect: TGpRectF);
begin
  DrawImage(image, rect.X, rect.Y, rect.Width, rect.Height);
end;

procedure TGpGraphics.DrawImage(image: TGpImage; x, y, width, height: Integer);
begin
  CheckStatus(GdipDrawImageRectI(Native, ObjectNative(image), x, y, width, height));
end;

procedure TGpGraphics.DrawLine(const pen: TGpPen; x1, y1, x2, y2: Single);
begin
  CheckStatus(GdipDrawLine(Native, pen.Native, x1, y1, x2, y2));
end;

procedure TGpGraphics.DrawLine(const pen: TGpPen; pt1, pt2: TGpPointF);
begin
  DrawLine(pen, pt1.X, pt1.Y, pt2.X, pt2.Y);
end;

procedure TGpGraphics.DrawLine(const pen: TGpPen; pt1, pt2: TGpPoint);
begin
  DrawLine(pen, pt1.X, pt1.Y, pt2.X, pt2.Y);
end;

procedure TGpGraphics.DrawLine(const pen: TGpPen; x1, y1, x2, y2: Integer);
begin
  CheckStatus(GdipDrawLineI(Native, pen.Native, x1, y1, x2, y2));
end;

procedure TGpGraphics.DrawLines(const pen: TGpPen; const points: array of TGpPointF);
begin
  CheckStatus(GdipDrawLines(Native, pen.Native, @points, Length(points)));
end;

procedure TGpGraphics.DrawLines(const pen: TGpPen; const points: array of TGpPoint);
begin
  CheckStatus(GdipDrawLinesI(Native, pen.Native, @points, Length(points)));
end;

procedure TGpGraphics.DrawPath(const pen: TGpPen; const path: TGpGraphicsPath);
begin
  CheckStatus(GdipDrawPath(Native, ObjectNative(pen), ObjectNative(path)));
end;

procedure TGpGraphics.DrawPie(const pen: TGpPen; const rect: TGpRect; startAngle,
  sweepAngle: Single);
begin
  DrawPie(pen, rect.X, rect.Y, rect.Width, rect.Height, startAngle, sweepAngle);
end;

procedure TGpGraphics.DrawPie(const pen: TGpPen; x, y, width, height: Integer;
  startAngle, sweepAngle: Single);
begin
  CheckStatus(GdipDrawPieI(Native, pen.Native, x, y,
                           width, height, startAngle, sweepAngle));
end;

procedure TGpGraphics.DrawPie(const pen: TGpPen; x, y, width, height,
  startAngle, sweepAngle: Single);
begin
  CheckStatus(GdipDrawPie(Native, pen.Native, x, y,
                          width, height, startAngle, sweepAngle));
end;

procedure TGpGraphics.DrawPie(const pen: TGpPen; const rect: TGpRectF;
  startAngle, sweepAngle: Single);
begin
  DrawPie(pen, rect.X, rect.Y, rect.Width, rect.Height, startAngle, sweepAngle);
end;

procedure TGpGraphics.DrawPolygon(const pen: TGpPen; const points: array of TGpPointF);
begin
  CheckStatus(GdipDrawPolygon(Native, pen.Native, @points, Length(points)));
end;

procedure TGpGraphics.DrawPolygon(const pen: TGpPen; const points: array of TGpPoint);
begin
  CheckStatus(GdipDrawPolygonI(Native, pen.Native, @points, Length(points)));
end;

procedure TGpGraphics.DrawRectangle(const pen: TGpPen; const rect: TGpRectF);
begin
  DrawRectangle(pen, rect.X, rect.Y, rect.Width, rect.Height);
end;

procedure TGpGraphics.DrawRectangle(const pen: TGpPen; x, y, width, height: Single);
begin
  CheckStatus(GdipDrawRectangle(Native, pen.Native, x, y, width, height));
end;

procedure TGpGraphics.DrawRectangle(const pen: TGpPen; const rect: TGpRect);
begin
  DrawRectangle(pen, rect.X, rect.Y, rect.Width, rect.Height);
end;

procedure TGpGraphics.DrawRectangle(const pen: TGpPen; x, y, width, height: Integer);
begin
  CheckStatus(GdipDrawRectangleI(Native, pen.Native, x, y, width, height));
end;

procedure TGpGraphics.DrawRectangles(const pen: TGpPen; const rects: array of TGpRect);
begin
  CheckStatus(GdipDrawRectanglesI(Native, pen.Native, @rects, Length(rects)));
end;

procedure TGpGraphics.DrawRectangles(const pen: TGpPen; const rects: array of TGpRectF);
begin
  CheckStatus(GdipDrawRectangles(Native, pen.Native, @rects, Length(rects)));
end;

procedure TGpGraphics.DrawString(const str: WideString; const font: TGpFont;
  const brush: TGpBrush; const origin: TGpPointF; const format: TGpStringFormat);
var
  r: TGpRectF;
begin
  r := GpRect(origin.X, origin.Y, 0.0, 0.0);
  CheckStatus(GdipDrawString(Native, PWChar(str), Length(str), ObjectNative(font),
                             @r, ObjectNative(format), ObjectNative(brush)));
end;

procedure TGpGraphics.DrawString(const str: WideString; const font: TGpFont;
  const brush: TGpBrush; const layoutRect: TGpRectF; const format: TGpStringFormat);

begin
  CheckStatus(GdipDrawString(Native, PWChar(str), Length(str),
                             ObjectNative(font), @layoutRect,
                             ObjectNative(format), ObjectNative(brush)));
end;

procedure TGpGraphics.DrawString(const str: WideString; const font: TGpFont;
  const brush: TGpBrush; x, y: Single; const format: TGpStringFormat);
var
  r: TGpRectF;
begin
  r := GpRect(x, y, 0.0, 0.0);
  CheckStatus(GdipDrawString(Native, PWChar(str), Length(str), ObjectNative(font),
                             @r, ObjectNative(format), ObjectNative(brush)));
end;

procedure TGpGraphics.EndContainer(state: TGraphicsContainer);
begin
  CheckStatus(GdipEndContainer(Native, state));
end;

procedure TGpGraphics.EnumerateMetafile(const metafile: TGpMetafile;
  const destPoint: TGpPoint; const srcRect: TGpRect; srcUnit: TUnit;
  callback: TEnumerateMetafileProc; callbackData: Pointer;
  const imageAttributes: TGpImageAttributes);
begin
  CheckStatus(GdipEnumerateMetafileSrcRectDestPointI(
                  Native, ObjectNative(metafile), @destPoint, @srcRect,
                  GdipTypes.TUnit(srcUnit), callback, callbackData, ObjectNative(imageAttributes)));
end;

procedure TGpGraphics.EnumerateMetafile(const metafile: TGpMetafile;
  const destPoint: TGpPointF; const srcRect: TGpRectF; srcUnit: TUnit;
  callback: TEnumerateMetafileProc; callbackData: Pointer;
  const imageAttributes: TGpImageAttributes);
begin
  CheckStatus(GdipEnumerateMetafileSrcRectDestPoint(
                  Native, ObjectNative(metafile), @destPoint, @srcRect,
                  GdipTypes.TUnit(srcUnit), callback, callbackData, ObjectNative(imageAttributes)));

end;

procedure TGpGraphics.EnumerateMetafile(const metafile: TGpMetafile;
  const destPoints: array of TGpPoint;
  callback: TEnumerateMetafileProc; callbackData: Pointer;
  const imageAttributes: TGpImageAttributes);
begin
  CheckStatus(GdipEnumerateMetafileDestPointsI(
                  Native, ObjectNative(metafile), @destPoints, Length(destPoints),
                  callback, callbackData, ObjectNative(imageAttributes)));
end;

procedure TGpGraphics.EnumerateMetafile(const metafile: TGpMetafile;
  const destRect, srcRect: TGpRectF; srcUnit: TUnit;
  callback: TEnumerateMetafileProc; callbackData: Pointer;
  const imageAttributes: TGpImageAttributes);
begin
  CheckStatus(GdipEnumerateMetafileSrcRectDestRect(
                  Native, ObjectNative(metafile), @destRect, @srcRect,
                  GdipTypes.TUnit(srcUnit), callback, callbackData, ObjectNative(imageAttributes)));
end;

procedure TGpGraphics.EnumerateMetafile(const metafile: TGpMetafile;
  const destPoints: array of TGpPoint; const srcRect: TGpRect;
  srcUnit: TUnit; callback: TEnumerateMetafileProc; callbackData: Pointer;
  const imageAttributes: TGpImageAttributes);
begin
  CheckStatus(GdipEnumerateMetafileSrcRectDestPointsI(
                  Native, ObjectNative(metafile), @destPoints, Length(destPoints),
                  @srcRect, GdipTypes.TUnit(srcUnit), callback, callbackData, ObjectNative(imageAttributes)));
end;

procedure TGpGraphics.EnumerateMetafile(const metafile: TGpMetafile;
  const destPoints: array of TGpPointF; const srcRect: TGpRectF;
  srcUnit: TUnit; callback: TEnumerateMetafileProc; callbackData: Pointer;
  const imageAttributes: TGpImageAttributes);
begin
  CheckStatus(GdipEnumerateMetafileSrcRectDestPoints(
                  Native, ObjectNative(metafile), @destPoints, Length(destPoints),
                  @srcRect, GdipTypes.TUnit(srcUnit), callback, callbackData, ObjectNative(imageAttributes)));
end;

procedure TGpGraphics.EnumerateMetafile(const metafile: TGpMetafile;
  const destRect, srcRect: TGpRect; srcUnit: TUnit;
  callback: TEnumerateMetafileProc; callbackData: Pointer;
  const imageAttributes: TGpImageAttributes);
begin
  CheckStatus(GdipEnumerateMetafileSrcRectDestRectI(
                    Native, ObjectNative(metafile), @destRect, @srcRect,
                    GdipTypes.TUnit(srcUnit), callback, callbackData, ObjectNative(imageAttributes)));
end;

procedure TGpGraphics.EnumerateMetafile(const metafile: TGpMetafile;
  const destPoints: array of TGpPointF;
  callback: TEnumerateMetafileProc; callbackData: Pointer;
  const imageAttributes: TGpImageAttributes);
begin
  CheckStatus(GdipEnumerateMetafileDestPoints(
                    Native, ObjectNative(metafile), @destPoints, Length(destPoints),
                    callback, callbackData, ObjectNative(imageAttributes)));
end;

procedure TGpGraphics.EnumerateMetafile(const metafile: TGpMetafile;
  const destPoint: TGpPoint; callback: TEnumerateMetafileProc;
  callbackData: Pointer; const imageAttributes: TGpImageAttributes);
begin
  CheckStatus(GdipEnumerateMetafileDestPointI(
                    Native, ObjectNative(metafile), @destPoint,
                    callback, callbackData, ObjectNative(imageAttributes)));
end;

procedure TGpGraphics.EnumerateMetafile(const metafile: TGpMetafile;
  const destPoint: TGpPointF; callback: TEnumerateMetafileProc;
  callbackData: Pointer; const imageAttributes: TGpImageAttributes);
begin
  CheckStatus(GdipEnumerateMetafileDestPoint(
                    Native, ObjectNative(metafile), @destPoint,
                    callback, callbackData, ObjectNative(imageAttributes)));
end;

procedure TGpGraphics.EnumerateMetafile(const metafile: TGpMetafile;
  const destRect: TGpRect; callback: TEnumerateMetafileProc;
  callbackData: Pointer; const imageAttributes: TGpImageAttributes);
begin
  CheckStatus(GdipEnumerateMetafileDestRectI(Native, ObjectNative(metafile),
                    @destRect, callback, callbackData, ObjectNative(imageAttributes)));
end;

procedure TGpGraphics.EnumerateMetafile(const metafile: TGpMetafile;
  const destRect: TGpRectF; callback: TEnumerateMetafileProc;
  callbackData: Pointer; const imageAttributes: TGpImageAttributes);
begin
  CheckStatus(GdipEnumerateMetafileDestRect(Native, ObjectNative(metafile),
                    @destRect, callback, callbackData, ObjectNative(imageAttributes)));
end;

procedure TGpGraphics.ExcludeClip(const rect: TGpRect);
begin
  CheckStatus(GdipSetClipRectI(Native, rect.X, rect.Y,
                               rect.Width, rect.Height, CombineModeExclude));
end;

procedure TGpGraphics.ExcludeClip(const rect: TGpRectF);
begin
  CheckStatus(GdipSetClipRect(Native, rect.X, rect.Y,
                               rect.Width, rect.Height, CombineModeExclude));
end;

procedure TGpGraphics.ExcludeClip(const region: TGpRegion);
begin
  CheckStatus(GdipSetClipRegion(Native, region.Native, CombineModeExclude));
end;

procedure TGpGraphics.FillClosedCurve(const brush: TGpBrush; const points: array of TGpPoint);
begin
  CheckStatus(GdipFillClosedCurveI(Native, brush.Native, @points, Length(points)));
end;

procedure TGpGraphics.FillClosedCurve(const brush: TGpBrush;
  const points: array of TGpPoint; fillMode: Vcl.Graphics.TFillMode; tension: Single);
begin
  CheckStatus(GdipFillClosedCurve2I(Native, brush.Native,
                                    @points, Length(points), tension, GdipTypes.TFillMode(fillMode)));
end;

procedure TGpGraphics.FillClosedCurve(const brush: TGpBrush; const points: array of TGpPointF);
begin
  CheckStatus(GdipFillClosedCurve(Native, brush.Native, @points, Length(points)));
end;

procedure TGpGraphics.FillClosedCurve(const brush: TGpBrush;
  const points: array of TGpPointF; fillMode: Vcl.Graphics.TFillMode; tension: Single);
begin
  CheckStatus(GdipFillClosedCurve2(Native, brush.Native,
                                   @points, Length(points), tension, GdipTypes.TFillMode(fillMode)));
end;

procedure TGpGraphics.FillEllipse(const brush: TGpBrush; const rect: TGpRectF);
begin
  FillEllipse(brush, rect.X, rect.Y, rect.Width, rect.Height);
end;

procedure TGpGraphics.FillEllipse(const brush: TGpBrush; x, y, width, height: Integer);
begin
  CheckStatus(GdipFillEllipseI(Native, brush.Native, x, y, width, height));
end;

procedure TGpGraphics.FillEllipse(const brush: TGpBrush; const rect: TGpRect);
begin
  FillEllipse(brush, rect.X, rect.Y, rect.Width, rect.Height);
end;

procedure TGpGraphics.FillEllipse(const brush: TGpBrush; x, y, width, height: Single);
begin
  CheckStatus(GdipFillEllipse(Native, brush.Native, x, y, width, height));
end;

procedure TGpGraphics.FillPath(const brush: TGpBrush; const path: TGpGraphicsPath);
begin
  CheckStatus(GdipFillPath(Native, brush.Native, path.Native));
end;

procedure TGpGraphics.FillPie(const brush: TGpBrush; const rect: TGpRect;
  startAngle, sweepAngle: Single);
begin
  FillPie(brush, rect.X, rect.Y, rect.Width, rect.Height, startAngle, sweepAngle);
end;

procedure TGpGraphics.FillPie(const brush: TGpBrush; x, y, width, height,
  startAngle, sweepAngle: Single);
begin
  CheckStatus(GdipFillPie(Native, brush.Native, x, y,
                          width, height, startAngle, sweepAngle));
end;

procedure TGpGraphics.FillPie(const brush: TGpBrush; const rect: TGpRectF;
  startAngle, sweepAngle: Single);
begin
  FillPie(brush, rect.X, rect.Y, rect.Width, rect.Height, startAngle, sweepAngle);
end;

procedure TGpGraphics.FillPie(const brush: TGpBrush; x, y, width,
  height: Integer; startAngle, sweepAngle: Single);
begin
  CheckStatus(GdipFillPieI(Native, brush.Native,
                           x, y, width, height, startAngle, sweepAngle));
end;

procedure TGpGraphics.FillPolygon(const brush: TGpBrush; const points: array of TGpPointF;
  fillMode: Vcl.Graphics.TFillMode);
begin
  CheckStatus(GdipFillPolygon(Native, brush.Native, @points, Length(points), GdipTypes.TFillMode(fillMode)));
end;

procedure TGpGraphics.FillPolygon(const brush: TGpBrush; const points: array of TGpPoint;
  fillMode: Vcl.Graphics.TFillMode);
begin
  CheckStatus(GdipFillPolygonI(Native, brush.Native, @points, Length(points), GdipTypes.TFillMode(fillMode)));
end;

procedure TGpGraphics.FillRectangle(const brush: TGpBrush; x, y, width, height: Integer);
begin
  CheckStatus(GdipFillRectangleI(Native, brush.Native, x, y, width, height));
end;

procedure TGpGraphics.FillRectangle(const brush: TGpBrush; const rect: TGpRect);
begin
  FillRectangle(brush, rect.X, rect.Y, rect.Width, rect.Height);
end;

procedure TGpGraphics.FillRectangle(const brush: TGpBrush; const rect: TGpRectF);
begin
  FillRectangle(brush, rect.X, rect.Y, rect.Width, rect.Height);
end;

procedure TGpGraphics.FillRectangle(const brush: TGpBrush; x, y, width, height: Single);
begin
  CheckStatus(GdipFillRectangle(Native, brush.Native, x, y, width, height));
end;

procedure TGpGraphics.FillRectangles(const brush: TGpBrush; const rects: array of TGpRect);
begin
  CheckStatus(GdipFillRectanglesI(Native, brush.Native, @rects, Length(rects)));
end;

procedure TGpGraphics.FillRectangles(const brush: TGpBrush; const rects: array of TGpRectF);
begin
  CheckStatus(GdipFillRectangles(Native, brush.Native, @rects, Length(rects)));
end;

procedure TGpGraphics.FillRegion(const brush: TGpBrush; const region: TGpRegion);
begin
  CheckStatus(GdipFillRegion(Native, brush.Native, region.Native));
end;

procedure TGpGraphics.Flush(intention: TFlushIntention);
begin
  GdipFlush(Native, GdipTypes.TFlushIntention(intention));
end;

class function TGpGraphics.FromHDC(hdc: HDC): TGpGraphics;
begin
  Result := TGpGraphics.Create(hdc);
end;

class function TGpGraphics.FromHDC(hdc: HDC; hdevice: THANDLE): TGpGraphics;
begin
  Result := TGpGraphics.Create(hdc, hdevice);
end;

class function TGpGraphics.FromHWND(hwnd: HWND; icm: Boolean): TGpGraphics;
begin
  Result := TGpGraphics.Create(hwnd, icm);
end;

class function TGpGraphics.FromImage(image: TGpImage): TGpGraphics;
begin
  Result := TGpGraphics.Create(image);
end;

procedure TGpGraphics.GetClip(region: TGpRegion);
begin
  CheckStatus(GdipGetClip(Native, region.Native));
end;

procedure TGpGraphics.GetClipBounds(var rect: TGpRectF);
begin
  CheckStatus(GdipGetClipBounds(Native, @rect));
end;

procedure TGpGraphics.GetClipBounds(var rect: TGpRect);
begin
  CheckStatus(GdipGetClipBoundsI(Native, @rect));
end;

function TGpGraphics.GetCompositingMode: TCompositingMode;
begin
  CheckStatus(GdipGetCompositingMode(Native, GdipTYpes.TCompositingMode(RV.rINT)));
  Result := TCompositingMode(RV.rINT);
end;

function TGpGraphics.GetCompositingQuality: TCompositingQuality;
begin
  CheckStatus(GdipGetCompositingQuality(Native, GdipTypes.TCompositingQuality(RV.rINT)));
  Result := TCompositingQuality(RV.rINT);
end;

function TGpGraphics.GetDpiX: Single;
begin
  CheckStatus(GdipGetDpiX(Native, Result));
end;

function TGpGraphics.GetDpiY: Single;
begin
  CheckStatus(GdipGetDpiY(Native, Result));
end;

class function TGpGraphics.GetHalftonePalette: HPALETTE;
begin
  Result := GdipCreateHalftonePalette;
end;

function TGpGraphics.GetHDC: HDC;
begin
  CheckStatus(GdipGetDC(Native, Result));
end;

function TGpGraphics.GetInterpolationMode: TInterpolationMode;
begin
  CheckStatus(GdipGetInterpolationMode(Native, GdipTypes.TInterpolationMode(RV.rINT)));
  Result := TInterpolationMode(RV.rINT);
end;

function TGpGraphics.GetNearestColor(Color: TARGB): TARGB;
begin
  Result := Color;
  CheckStatus(GdipGetNearestColor(Native, @Result));
end;

function TGpGraphics.GetPageScale: Single;
begin
  CheckStatus(GdipGetPageScale(Native, Result));
end;

function TGpGraphics.GetPageUnit: TUnit;
begin
  CheckStatus(GdipGetPageUnit(Native, GdipTypes.TUnit(RV.rINT)));
  Result := TUnit(RV.rINT);
end;

function TGpGraphics.GetPixelOffsetMode: TPixelOffsetMode;
begin
  CheckStatus(GdipGetPixelOffsetMode(Native, GdipTypes.TPixelOffsetMode(RV.rINT)));
  Result := TPixelOffsetMode(RV.rINT);
end;

function TGpGraphics.GetRenderingOrigin: TGpPoint;
begin
  CheckStatus(GdipGetRenderingOrigin(Native, Result.X, Result.Y));
end;

function TGpGraphics.GetSmoothingMode: TSmoothingMode;
begin
  CheckStatus(GdipGetSmoothingMode(Native, GdipTypes.TSmoothingMode(RV.rINT)));
  Result := TSmoothingMode(RV.rINT);
end;

function TGpGraphics.GetTextContrast: Integer;
begin
  CheckStatus(GdipGetTextContrast(Native, Result));
end;

function TGpGraphics.GetTextRenderingHint: TTextRenderingHint;
begin
  CheckStatus(GdipGetTextRenderingHint(Native, GdipTypes.TTextRenderingHint(RV.rINT)));
  Result := TTextRenderingHint(RV.rINT);
end;

procedure TGpGraphics.GetTransform(matrix: TGpMatrix);
begin
  CheckStatus(GdipGetWorldTransform(Native, matrix.Native));
end;

procedure TGpGraphics.GetVisibleClipBounds(var rect: TGpRectF);
begin
  CheckStatus(GdipGetVisibleClipBounds(Native, @rect));
end;

procedure TGpGraphics.GetVisibleClipBounds(var rect: TGpRect);
begin
  CheckStatus(GdipGetVisibleClipBoundsI(Native, @rect));
end;

procedure TGpGraphics.IntersectClip(const rect: TGpRect);
begin
  CheckStatus(GdipSetClipRectI(Native, rect.X, rect.Y,
                               rect.Width, rect.Height, CombineModeIntersect));
end;

procedure TGpGraphics.IntersectClip(const region: TGpRegion);
begin
  CheckStatus(GdipSetClipRegion(Native, region.Native, CombineModeIntersect));
end;

procedure TGpGraphics.IntersectClip(const rect: TGpRectF);
begin
  CheckStatus(GdipSetClipRect(Native, rect.X, rect.Y,
                              rect.Width, rect.Height, CombineModeIntersect));
end;

function TGpGraphics.IsClipEmpty: Boolean;
begin
  CheckStatus(GdipIsClipEmpty(Native, RV.rBOOL));
  Result := RV.rBOOL;
end;

function TGpGraphics.IsVisible(x, y, width, height: Integer): Boolean;
begin
  Result := IsVisible(GpRect(x, y, width, height));
end;

function TGpGraphics.IsVisible(const rect: TGpRect): Boolean;
begin
  CheckStatus(GdipIsVisibleRectI(Native, rect.X, rect.Y,
                                 rect.Width, rect.Height, RV.rBOOL));
  Result := RV.rBOOL;
end;

function TGpGraphics.IsVisible(x, y: Integer): Boolean;
begin
  Result := IsVisible(GpPoint(x,y));
end;

function TGpGraphics.IsVisible(const point: TGpPoint): Boolean;
begin
  CheckStatus(GdipIsVisiblePointI(Native, point.X, point.Y, RV.rBOOL));
  Result := RV.rBOOL;
end;

function TGpGraphics.IsVisible(x, y: Single): Boolean;
begin
  Result := IsVisible(GpPoint(x, y));
end;

function TGpGraphics.IsVisible(const rect: TGpRectF): Boolean;
begin
  CheckStatus(GdipIsVisibleRect(Native, rect.X, rect.Y,
                                rect.Width, rect.Height, RV.rBOOL));
  Result := RV.rBOOL;
end;

function TGpGraphics.IsVisible(x, y, width, height: Single): Boolean;
begin
  Result := IsVisible(GpRect(x, y, width, height));
end;

function TGpGraphics.IsVisible(const point: TGpPointF): Boolean;
begin
  CheckStatus(GdipIsVisiblePoint(Native, point.X, point.Y, RV.rBOOL));
  Result := RV.rBOOL;
end;

function TGpGraphics.IsVisibleClipEmpty: Boolean;
begin
  CheckStatus(GdipIsVisibleClipEmpty(Native, RV.rBOOL));
  Result := RV.rBOOL;
end;

procedure TGpGraphics.MeasureCharacterRanges(const str: WideString;
  const font: TGpFont; const layoutRect: TGpRectF; const format: TGpStringFormat;
  const regions: array of TGpRegion);
type
  RegionArray = array of GpRegion;
var
  nativeRegions: ^GpRegion;
  i, regionCount: Integer;
begin
  regionCount := Length(regions);
  if regionCount = 0 then CheckStatus(InvalidParameter);
  GetMem(nativeRegions, regionCount * Sizeof(GpRegion));
  try
    for i := 0 to regionCount - 1 do
      RegionArray(nativeRegions)[i] := regions[i].Native;
    CheckStatus(GdipMeasureCharacterRanges(Native, PWChar(str),
                  length(str), ObjectNative(font), @layoutRect,
                  ObjectNative(format), regionCount, nativeRegions));
  finally
    FreeMem(nativeRegions, regionCount * Sizeof(GpRegion));
  end;
end;

function TGpGraphics.MeasureDriverString(const text: PUINT16;
  length: Integer; const font: TGpFont; const positions: PGpPointF;
  flags: Integer; const matrix: TGpMatrix): TGpRectF;
begin
  CheckStatus(GdipMeasureDriverString(Native, text, length, ObjectNative(font),
                  positions, flags, ObjectNative(matrix), @Result));
end;

function TGpGraphics.MeasureString(const str: WideString; const font: TGpFont;
  const layoutArea: TGpSizeF; const format: TGpStringFormat;
  codepointsFitted, linesFilled: PInteger): TGpRectF;
var
  r: TGpRectF;
begin
  r := GpRect(0.0, 0.0, layoutArea.Width, layoutArea.Height);
  CheckStatus(GdipMeasureString(Native, PWChar(str), Length(str),
                  ObjectNative(font), @r, ObjectNative(format),
                  @Result, codepointsFitted, linesFilled));
end;

function TGpGraphics.MeasureString(const str: WideString; const font: TGpFont;
  const origin: TGpPointF; const format: TGpStringFormat): TGpRectF;
var
  r: TGpRectF;
begin
  r := GpRect(origin.X, origin.Y, 0.0, 0.0);
  CheckStatus(GdipMeasureString(Native, PWChar(str), Length(str),
                  ObjectNative(font), @r, ObjectNative(format),
                  @Result, nil, nil));
end;

function TGpGraphics.MeasureString(const str: WideString; const font: TGpFont;
  width: Integer; const format: TGpStringFormat): TGpRectF;
var
  r: TGpRectF;
begin
  r := GpRect(0.0, 0.0, width, 0.0);
  CheckStatus(GdipMeasureString(Native, PWChar(str), Length(str), ObjectNative(font),
                  @r, ObjectNative(format), @Result, nil, nil));
end;

function TGpGraphics.MeasureString(const str: WideString; const font: TGpFont;
  const layoutRect: TGpRectF; const format: TGpStringFormat): TGpRectF;
begin
  CheckStatus(GdipMeasureString(Native, PWChar(str), Length(str),
                  ObjectNative(font), @layoutRect,
                  ObjectNative(format), @Result, nil, nil));
end;

procedure TGpGraphics.MultiplyTransform(const matrix: TGpMatrix; order: TMatrixOrder);
begin
  CheckStatus(GdipMultiplyWorldTransform(Native, matrix.Native, GdipTypes.TMatrixOrder(order)));
end;

procedure TGpGraphics.ReleaseHDC(hdc: HDC);
begin
  CheckStatus(GdipReleaseDC(Native, hdc));
end;

procedure TGpGraphics.ResetClip;
begin
  CheckStatus(GdipResetClip(Native));
end;

procedure TGpGraphics.ResetTransform;
begin
  CheckStatus(GdipResetWorldTransform(Native));
end;

procedure TGpGraphics.Restore(gstate: TGraphicsState);
begin
  CheckStatus(GdipRestoreGraphics(Native, gstate));
end;

procedure TGpGraphics.RotateTransform(angle: Single; order: TMatrixOrder);
begin
  CheckStatus(GdipRotateWorldTransform(Native, angle, GdipTypes.TMatrixOrder(order)));
end;

function TGpGraphics.Save: TGraphicsState;
begin
  CheckStatus(GdipSaveGraphics(Native, Result));
end;

procedure TGpGraphics.ScaleTransform(sx, sy: Single; order: TMatrixOrder);
begin
  CheckStatus(GdipScaleWorldTransform(Native, sx, sy, GdipTypes.TMatrixOrder(order)));
end;

procedure TGpGraphics.SetClip(const path: TGpGraphicsPath; combineMode: TCombineMode);
begin
  CheckStatus(GdipSetClipPath(Native, path.Native, GdipTypes.TCombineMode(combineMode)));
end;

procedure TGpGraphics.SetClip(const rect: TGpRect; combineMode: TCombineMode);
begin
  CheckStatus(GdipSetClipRectI(Native, rect.X, rect.Y,
                               rect.Width, rect.Height, GdipTypes.TCombineMode(combineMode)));
end;

procedure TGpGraphics.SetClip(hRgn: HRGN; combineMode: TCombineMode);
begin
  CheckStatus(GdipSetClipHrgn(Native, hRgn, GdipTypes.TCombineMode(combineMode)));
end;

procedure TGpGraphics.SetClip(const region: TGpRegion; combineMode: TCombineMode);
begin
  CheckStatus(GdipSetClipRegion(Native, region.Native, GdipTypes.TCombineMode(combineMode)));
end;

procedure TGpGraphics.SetClip(const g: TGpGraphics; combineMode: TCombineMode);
begin
  CheckStatus(GdipSetClipGraphics(Native, g.Native, GdipTypes.TCombineMode(combineMode)));
end;

procedure TGpGraphics.SetClip(const rect: TGpRectF; combineMode: TCombineMode);
begin
  CheckStatus(GdipSetClipRect(Native, rect.X, rect.Y,
                              rect.Width, rect.Height, GdipTypes.TCombineMode(combineMode)));
end;

procedure TGpGraphics.SetCompositingMode(compositingMode: TCompositingMode);
begin
  CheckStatus(GdipSetCompositingMode(Native, GdipTypes.TCompositingMode(compositingMode)));
end;

procedure TGpGraphics.SetCompositingQuality(compositingQuality: TCompositingQuality);
begin
  CheckStatus(GdipSetCompositingQuality(Native, GdipTypes.TCompositingQuality(compositingQuality)));
end;

procedure TGpGraphics.SetInterpolationMode(interpolationMode: TInterpolationMode);
begin
  CheckStatus(GdipSetInterpolationMode(Native, GdipTypes.TInterpolationMode(interpolationMode)));
end;

procedure TGpGraphics.SetPageScale(scale: Single);
begin
  CheckStatus(GdipSetPageScale(Native, scale));
end;

procedure TGpGraphics.SetPageUnit(unit_: TUnit);
begin
  CheckStatus(GdipSetPageUnit(Native, GdipTypes.TUnit(unit_)));
end;

procedure TGpGraphics.SetPixelOffsetMode(pixelOffsetMode: TPixelOffsetMode);
begin
  CheckStatus(GdipSetPixelOffsetMode(Native, GdipTypes.TPixelOffsetMode(pixelOffsetMode)));
end;
{
procedure TGpGraphics.SetRenderingOrigin(x, y: Integer);
begin
  CheckStatus(GdipSetRenderingOrigin(Native, x, y));
end;
}
procedure TGpGraphics.SetRenderingOrigin(const Value: TGpPoint);
begin
  CheckStatus(GdipSetRenderingOrigin(Native, Value.X, Value.Y));
end;

procedure TGpGraphics.SetSmoothingMode(smoothingMode: TSmoothingMode);
begin
  CheckStatus(GdipSetSmoothingMode(Native, GdipTypes.TSmoothingMode(smoothingMode)));
end;

procedure TGpGraphics.SetTextContrast(contrast: Integer);
begin
  CheckStatus(GdipSetTextContrast(Native, contrast));
end;

procedure TGpGraphics.SetTextRenderingHint(newMode: TTextRenderingHint);
begin
  CheckStatus(GdipSetTextRenderingHint(Native, GdipTypes. TTextRenderingHint(newMode)));
end;

procedure TGpGraphics.SetTransform(const matrix: TGpMatrix);
begin
  CheckStatus(GdipSetWorldTransform(Native, matrix.Native));
end;

procedure TGpGraphics.TransformPoints(destSpace, srcSpace: TCoordinateSpace; pts: array of TGpPoint);
begin
  CheckStatus(GdipTransformPointsI(Native, GdipTypes.TCoordinateSpace(destSpace),
      GdipTypes.TCoordinateSpace(srcSpace), @pts, Length(pts)));
end;

procedure TGpGraphics.TransformPoints(destSpace, srcSpace: TCoordinateSpace; pts: array of TGpPointF);
begin
  CheckStatus(GdipTransformPoints(Native, GdipTypes.TCoordinateSpace(destSpace),
      GdipTypes.TCoordinateSpace(srcSpace), @pts, Length(pts)));
end;

procedure TGpGraphics.TranslateClip(dx, dy: Integer);
begin
  CheckStatus(GdipTranslateClipI(Native, dx, dy));
end;

procedure TGpGraphics.TranslateClip(dx, dy: Single);
begin
  CheckStatus(GdipTranslateClip(Native, dx, dy));
end;

procedure TGpGraphics.TranslateTransform(dx, dy: Single; order: TMatrixOrder);
begin
  CheckStatus(GdipTranslateWorldTransform(Native, dx, dy, GdipTypes.TMatrixOrder(order)));
end;

{ TPens }

constructor TPens.Create;
begin
  FColor := kcBlack;
  FWidth := 1.0;
  FPen := TGpPen.Create(FColor);
end;

destructor TPens.Destroy;
begin
  FPen.Free;
end;
{
function TPens.GetDefinePen(const Index: TARGB): TGpPen;
begin
  Result := GetPen(ARGB(Index), 1.0);
end;
}
function TPens.GetDefinePen(const Index: Integer): TGpPen;
begin
  Result := GetPen(Index, 1.0);
end;

function TPens.GetPen(AColor: TARGB; AWidth: Single): TGpPen;
begin
  if FColor <> AColor then
  begin
    FColor := AColor;
    GdipSetPenColor(FPen.Native, FColor);
  end;
  if FWidth <> AWidth then
  begin
    FWidth := AWidth;
    GdipSetPenWidth(FPen.Native, FWidth);
  end;
  Result := FPen;
end;

{ TBrushs }

constructor TBrushs.Create;
begin
  FColor := kcBlack;
  FBrush := TGpSolidBrush.Create(FColor);
end;

destructor TBrushs.Destroy;
begin
  FBrush.Free;
  inherited;
end;

function TBrushs.GetBrush(AColor: TARGB): TGpBrush;
begin
  if FColor <> AColor then
  begin
    FColor := AColor;
    GdipSetSolidFillColor(FBrush.Native, FColor);
  end;
  Result := FBrush;
end;

function TBrushs.GetDefineBrush(const Index: Integer): TGpBrush;
begin
  Result := GetBrush(Index);
end;

function Pens: TPens;
begin
  Result := FPens;
end;

function Brushs: TBrushs;
begin
  Result := FBrushs;
end;

{ TARGB }

function ARGB(a, r, g, b: BYTE): TARGB;
asm
  shl   eax, AlphaShift
  shl   edx, RedShift
  and   edx, RedMask
  or    eax, edx
  shl   ecx, GreenShift
  and   ecx, GreenMask
  or    eax, ecx
  mov   dl, b
  and   edx, BlueMask
  or    eax, edx
end;

function ARGB(r, g, b: BYTE): TARGB;
begin
  Result := ARGB(255, r, g, b);
end;

function ARGB(a: Byte; Argb: TARGB): TARGB;
asm
  shl   eax, AlphaShift
  and   edx, 0FFFFFFh
  or    eax, edx
end;

function ARGBToString(Argb: TARGB): string;
begin
  if not ARGBToIdent(Argb, Result) then
    FmtStr(Result, '%s%.8x', [HexDisplayPrefix, Argb]);
end;

function StringToARGB(const S: string; Alpha: BYTE): TARGB;
begin
  if not IdentToARGB(S, Longint(Result)) then
    Result := TARGB(StrToInt(S));
  if Alpha <> 255 then
    Result := ARGB(Alpha, Result);
end;

procedure GetARGBValues(Proc: TGetStrProc);
var
  I: Integer;
begin
  for I := Low(KnownColors) to High(KnownColors) do Proc(KnownColors[I].Name);
end;

function ARGBToIdent(Argb: Longint; var Ident: string): Boolean;
begin
  Result := IntToIdent(Argb, Ident, KnownColors);
end;

function IdentToARGB(const Ident: string; var Argb: Longint): Boolean;
begin
  Result := IdentToInt(Ident, Argb, KnownColors);
end;

function ARGBToCOLORREF(Argb: TARGB): Longint;
asm
  bswap eax
  shr   eax, 8
end;

function ARGBToColor(Argb: TARGB): Vcl.Graphics.TColor;
asm
  bswap eax
  shr   eax, 8
end;

function ARGBFromCOLORREF(Alpha: Byte; Rgb: Longint): TARGB;
asm
  shl   eax, AlphaShift
  bswap edx
  shr   edx, 8
  or    eax, edx
{
  Result := ((Rgb and $0000FF) shl $10) or
             (Rgb and $00FF00) or
            ((Rgb and $FF0000) shr $10) or
            (TARGB(Alpha) shl AlphaShift);
}
end;

function ARGBFromCOLORREF(Rgb: Longint): TARGB;
asm
  bswap eax
  shr   eax, 8
  or    eax, 0ff000000h
end;

function ARGBFromTColor(Alpha: Byte; Color: Vcl.Graphics.TColor): TARGB;
begin
  if Color < 0 then
    Color := GetSysColor(Color and $000000FF);
  Result := ARGBFromCOLORREF(Alpha, Color);
end;

function ARGBFromTColor(Color: Vcl.Graphics.TColor): TARGB;
begin
  Result := ARGBFromTColor(255, Color);
end;

{ TGpSize }

function GpSize(const Width, Height: TREAL): TGpSizeF;
begin
  Result.Width := Width;
  Result.Height := Height;
end;

function GpSize(const Width, Height: Integer): TGpSize;
begin
  Result.Width := Width;
  Result.Height := Height;
end;

function Empty(const sz: TGpSizeF): Boolean;
begin
  Result := (sz.Width = 0.0) and (sz.Height = 0.0);
end;

function Empty(const sz: TGpSize): Boolean;
begin
  Result := (sz.Width = 0) and (sz.Height = 0);
end;

function Equals(const sz1, sz2: TGpSizeF): Boolean;
begin
  Result := (sz1.Width = sz2.Width) and (sz1.Height = sz2.Height);
end;

function Equals(const sz1, sz2: TGpSize): Boolean;
begin
  Result := (sz1.Width = sz2.Width) and (sz1.Height = sz2.Height);
end;

{ TGpPoint }

function GpPoint(const x, y: TREAL): TGpPointF;
begin
  Result.X := x;
  Result.Y := y;
end;

function GpPoint(const x, y: Integer): TGpPoint;
begin
  Result.X := x;
  Result.Y := y;
end;

function GpPoint(const pt: WinApi.Windows.TPoint): TGpPoint;
begin
  Result := TGpPoint(pt);
end;

function Equals(const pt1, pt2: TGpPointF): Boolean;
begin
  Result := (pt1.X = pt2.X) and (pt1.Y = pt2.Y);
end;

function Equals(const pt1, pt2: TGpPoint): Boolean;
begin
  Result := (pt1.X = pt2.X) and (pt1.Y = pt2.Y);
end;

{ TGpRect }

function GpRect(const x, y, Width, Height: TREAL): TGpRectF;
begin
  Result.X := x;
  Result.Y := y;
  Result.Width := Width;
  Result.Height := Height;
end;

function GpRect(const pt: TGpPointF; const sz: TGpSizeF): TGpRectF;
begin
  Result.Point := pt;
  Result.Size := sz;
end;

function GpRect(const x, y, Width, Height: INT): TGpRect;
begin
  Result.X := x;
  Result.Y := y;
  Result.Width := Width;
  Result.Height := Height;
end;

function GpRect(const pt: TGpPoint; const sz: TGpSize): TGpRect;
begin
  Result.Point := pt;
  Result.Size := sz;
end;

function GpRect(const r: WinApi.Windows.TRect): TGpRect;
begin
  Result.X := r.Left;
  Result.Y := r.Top;
  Result.Width := r.Right - r.Left;
  Result.Height := r.Bottom - r.Top;
end;

function Min(const A, B: Integer): Integer; overload;
begin
  if A < B then
    Result := A
  else
    Result := B;
end;

function Min(const A, B: Single): Single; overload;
begin
  if A < B then
    Result := A
  else
    Result := B;
end;

function Max(const A, B: Integer): Integer; overload;
begin
  if A > B then
    Result := A
  else
    Result := B;
end;

function Max(const A, B: Single): Single; overload;
begin
  if A > B then
    Result := A
  else
    Result := B;
end;

function Contains(const rc: TGpRectF; const pt: TGpPointF): Boolean;
begin
  Result := Contains(rc, pt.X, pt.Y);
end;

function Contains(const rc: TGpRectF; const x, y: TREAL): Boolean;
begin
  Result := (x >= rc.X) and (x < rc.X + rc.Width) and
            (y >= rc.Y) and (y < rc.Y + rc.Height);
end;

function Contains(const rc, rc2: TGpRectF): Boolean;
begin
  Result := (rc.X <= rc2.X) and (rc.X + rc.Width >= rc2.X + rc2.Width) and
            (rc.Y <= rc2.Y) and (rc.Y + rc.Height >= rc2.Y + rc2.Height);
end;

function Contains(const rc: TGpRect; const pt: TGpPoint): Boolean;
begin
  Result := Contains(rc, pt.X, pt.Y);
end;

function Contains(const rc: TGpRect; const x, y: INT): Boolean;
begin
  Result := (x >= rc.X) and (x < rc.X + rc.Width) and
            (y >= rc.Y) and (y < rc.Y + rc.Height);
end;

function Contains(const rc, rc2: TGpRect): Boolean;
begin
  Result := (rc.X <= rc2.X) and (rc.X + rc.Width >= rc2.X + rc2.Width) and
            (rc.Y <= rc2.Y) and (rc.Y + rc.Height >= rc2.Y + rc2.Height);
end;

function Equals(const rc1, rc2: TGpRectF): Boolean;
begin
  Result := (rc1.X = rc2.X) and (rc1.Y = rc2.Y) and
      (rc1.Width = rc2.Width) and (rc1.Height = rc2.Height);
end;

function Equals(const rc1, rc2: TGpRect): Boolean;
begin
  Result := (rc1.X = rc2.X) and (rc1.Y = rc2.Y) and
      (rc1.Width = rc2.Width) and (rc1.Height = rc2.Height);
end;

procedure Inflate(var rc: TGpRectF; const dx, dy: TREAL);
begin
 rc.X := rc.X - dx;
 rc.Y := rc.Y - dy;
 rc.Width := rc.Width + 2 * dx;
 rc.Height := rc.Height + 2 * dy;
end;

procedure Inflate(var rc: TGpRectF; const point: TGpPointF);
begin
  Inflate(rc, point.X, point.Y);
end;

procedure Inflate(var rc: TGpRect; const dx, dy: INT);
begin
 rc.X := rc.X - dx;
 rc.Y := rc.Y - dy;
 rc.Width := rc.Width + 2 * dx;
 rc.Height := rc.Height + 2 * dy;
end;

procedure Inflate(var rc: TGpRect; const point: TGpPoint);
begin
  Inflate(rc, point.X, point.Y);
end;

function Intersect(var dest: TGpRectF; const a, b: TGpRectF): Boolean;
begin
  dest.Width := Min(a.X + a.Width, b.X + b.Width);
  dest.Height := Min(a.Y + a.Height, b.Y + b.Height);
  dest.X := Max(a.X, b.X);
  dest.Y := Max(a.Y, b.Y);
  dest.Width := dest.Width - dest.X;
  dest.Height := dest.Height - dest.Y;
  Result := not IsEmptyArea(dest);
end;

function Intersect(var dest: TGpRectF; const rc: TGpRectF): Boolean;
begin
  Result := Intersect(dest, dest, rc);
end;

function Intersect(var dest: TGpRect; const a, b: TGpRect): Boolean;
begin
  dest.Width := Min(a.X + a.Width, b.X + b.Width);
  dest.Height := Min(a.Y + a.Height, b.Y + b.Height);
  dest.X := Max(a.X, b.X);
  dest.Y := Max(a.Y, b.Y);
  Dec(dest.Width, dest.X);
  Dec(dest.Height, dest.Y);
  Result := not IsEmptyArea(dest);
end;

function Intersect(var dest: TGpRect; const rc: TGpRect): Boolean;
begin
  Result := Intersect(dest, dest, rc);
end;

function IntersectsWith(const rc1, rc2: TGpRectF): Boolean;
begin
  Result := (rc1.X  < rc2.X + rc2.Width) and
            (rc1.Y  < rc2.Y + rc2.Height) and
            (rc1.X + rc1.Width > rc2.X) and
            (rc1.Y + rc2.Height > rc2.Y);
end;

function IntersectsWith(const rc1, rc2: TGpRect): Boolean;
begin
  Result := (rc1.X < rc2.X + rc2.Width) and
            (rc1.Y < rc2.Y + rc2.Height) and
            (rc1.X + rc1.Width > rc2.X) and
            (rc1.Y + rc2.Height > rc2.Y);
end;

function IsEmptyArea(const rc: TGpRectF): Boolean;
begin
  Result := (rc.Width <= REAL_EPSILON) or (rc.Height <= REAL_EPSILON);
end;

function IsEmptyArea(const rc: TGpRect): Boolean;
begin
  Result := (rc.Width <= 0) or (rc.Height <= 0);
end;
procedure Offset(var p: TGpPointF; const dx, dy: TREAL);
begin
  p.X := p.X + dx;
  p.Y := p.Y + dy;
end;

procedure Offset(var p: TGpPoint; const dx, dy: INT);
begin
  Inc(p.X, dx);
  Inc(p.Y, dy);
end;

procedure Offset(var rc: TGpRectF; const dx, dy: TREAL);
begin
  rc.X := rc.X + dx;
  rc.Y := rc.Y + dy;
end;

procedure Offset(var rc: TGpRectF; const point: TGpPointF);
begin
  Offset(rc, point.X, point.Y);
end;

procedure Offset(var rc: TGpRect; const dx, dy: INT);
begin
  rc.X := rc.X + dx;
  rc.Y := rc.Y + dy;
end;

procedure Offset(var rc: TGpRect; const point: TGpPoint);
begin
  Offset(rc, point.X, point.Y);
end;

function Union(var dest: TGpRectF; const a, b: TGpRectF): Boolean;
begin
  dest.Width := Max(a.X + a.Width, b.X + b.Width);
  dest.Height := Max(a.Y + a.Height, b.Y + b.Height);
  dest.X := Min(a.X, b.X);
  dest.Y := Min(a.Y, b.Y);
  dest.Width := dest.Width - dest.X;
  dest.Height := dest.Height - dest.Y;
  Result := not IsEmptyArea(dest);
end;

function Union(var dest: TGpRect; const a, b: TGpRect): Boolean;
begin
  dest.Width := Max(a.X + a.Width, b.X + b.Width);
  dest.Height := Max(a.Y + a.Height, b.Y + b.Height);
  dest.X := Min(a.X, b.X);
  dest.Y := Min(a.Y, b.Y);
  Dec(dest.Width, dest.X);
  Dec(dest.Height, dest.Y);
  Result := not IsEmptyArea(dest);
end;

function Union(var dest: TGpRectF; const rc: TGpRectF): Boolean;
begin
  Result := Union(dest, dest, rc);
end;

function Union(var dest: TGpRect; const rc: TGpRect): Boolean;
begin
  Result := Union(dest, dest, rc);
end;

function GetImageDecodersSize(var numDecoders, size: Integer): TStatus;
begin
  Result := GdipGetImageDecodersSize(numDecoders, size);
end;

function GetImageDecoders(numDecoders, size: Integer;
                          decoders: PImageCodecInfo): TStatus;
begin
  Result := GdipGetImageDecoders(numDecoders, size, decoders);
end;

function GetImageEncodersSize(var numEncoders, size: Integer): TStatus;
begin
  Result := GdipGetImageEncodersSize(numEncoders, size);
end;

function GetImageEncoders(numEncoders, size: Integer;
                          encoders: PImageCodecInfo): TStatus;
begin
  Result := GdipGetImageEncoders(numEncoders, size, encoders);
end;

function GetEncoderClsid(format: WideString; var Clsid: TGUID): Boolean;
var
  num, size, i: Integer;
  ImageCodecInfo: PImageCodecInfo;
type
  InfoArray = array of TImageCodecInfo;
begin
  num  := 0;
  size := 0; 
  Result := False;

  GetImageEncodersSize(num, size);
  if (size = 0) then exit;

  GetMem(ImageCodecInfo, size);
  try
    GetImageEncoders(num, size, ImageCodecInfo);
    i := 0;
    while (i < num) and (CompareText(InfoArray(ImageCodecInfo)[i].MimeType, format) <> 0) do
      Inc(i);
    Result := i < num;
    if Result then
      Clsid := InfoArray(ImageCodecInfo)[i].Clsid;
  finally
    FreeMem(ImageCodecInfo, size);
  end;
end;

{$IFDEF USE_GDIPLUS}
initialization
begin
  GdiplusStartupInput := MakeGdiplusStartupInput;
  GdiplusStartup(gdipToken, @GdiplusStartupInput, nil);
  FGdipGenerics := TGdipGenerics.Create;
  FPens := TPens.Create;
  FBrushs := TBrushs.Create;
end;
finalization
begin
  FBrushs.Free;
  FPens.Free;
  FGdipGenerics.Free;
  GdiplusShutdown(gdipToken);
end;
{$ENDIF}

end.






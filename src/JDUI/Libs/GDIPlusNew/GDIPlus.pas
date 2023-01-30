unit Gdiplus;

(***************************************************************************\
*
* 2003�꣬����ʡ������ͳ�ƾ� ë�� �ڴ���
*
* Module Name:
*
*   Gdiplus.pas
*
* Abstract:
*
*   GDI+ class
*
* ע��ԭʼ�������Ͷ�����GdipTypes.pas�У�Ϊ��Delphiϰ�ߣ����õ��Ѿ��ڱ�ģ������
*     ���塣Ҫʹ��ĳЩ�����ö�١���¼����������̱������GdipTypes.pas�ļ�
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
// ��װ��ʾ���α��ε� 3 x 2 �������
// ��ע: 3 x 2 �����ڵ�һ�а��� x ֵ���ڵڶ��а��� y ֵ���ڵ����а��� w ֵ��
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
    // �� Matrix ���һ����ʵ����ʼ��Ϊ��λ����. Elements = 1,0,0,1,0,0
    constructor Create; overload;
    // ʹ��ָ����Ԫ�س�ʼ�� Matrix �����ʵ����
    constructor Create(m11, m12, m21, m22, dx, dy: Single); overload;
    // �� Matrix ���һ����ʵ����ʼ��Ϊָ�����κ͵����鶨��ļ��α��Ρ�dstplg ������ Point �ṹ���ɵ�����
    constructor Create(rect: TGpRectF; dstplg: array of TGpPointF); overload;
    constructor Create(rect: TGpRect; dstplg: array of TGpPoint); overload;
    destructor Destroy; override;
    function Clone: TGpMatrix;
    // ���ô� Matrix �����Ծ��е�λ�����Ԫ�ء�
    procedure Reset;
    // ��ָ����˳�򽫴� Matrix �������� matrix ������ָ���ľ�����ˡ�
    procedure Multiply(const matrix: TGpMatrix; order: TMatrixOrder = moPrepend);
    // ͨ��Ԥ�ȼ���ת��������ָ����ת������Ӧ�õ��� Matrix ����
    procedure Translate(offsetX, offsetY: Single; order: TMatrixOrder = moPrepend);
    // ʹ��ָ����˳��ָ��������������scaleX �� scaleY��Ӧ�õ��� Matrix ����
    procedure Scale(scaleX, scaleY: Single; order: TMatrixOrder = moPrepend);
    // Ӧ�� angle ������ָ����˳ʱ����ת����Ϊ�� Matrix ������ԭ�㣨X,Y ���꣩��ת��
    procedure Rotate(angle: Single; order: TMatrixOrder = moPrepend);
    // ͨ��Ԥ�ȼ�����ת������ָ�����˳ʱ����תӦ�õ��� Matrix ����
    procedure RotateAt(angle: Single; const center: TGpPointF; order: TMatrixOrder = moPrepend);
    // ��ָ����˳��ָ�����б�����Ӧ�õ��� Matrix ����
    procedure Shear(shearX, shearY: Single; order: TMatrixOrder = moPrepend);
    // ����� Matrix �����ǿ���ת�ģ�����ת�ö���
    procedure Invert;
    // ��ָ���ĵ�����Ӧ�ô� Matrix ��������ʾ�ļ��α��Ρ�
    procedure TransformPoints(pts: array of TGpPointF); overload;
    procedure TransformPoints(pts: array of TGpPoint); overload;
    // ֻ���� Matrix �������������ת�ɷ�Ӧ�õ�ָ���ĵ����顣
    procedure TransformVectors(pts: array of TGpPointF); overload;
    procedure TransformVectors(pts: array of TGpPoint); overload;
    function Equals(const matrix: TGpMatrix): Boolean;
      {$IF RTLVersion >= 20}reintroduce; overload;{$IFEND}
    // ��ȡһ��ֵ����ֵָʾ�� Matrix �����Ƿ��ǿ���ת�ġ�
    property IsInvertible: Boolean read GetInvertible;
    // ��ȡһ��ֵ����ֵָʾ�� Matrix �����Ƿ��ǵ�λ����
    property IsIdentity: Boolean read GetIdentity;
    // ��ȡ�����ø� Matrix �����Ԫ�ء�
    property Elements: TMatrixElements read GetElements write SetElements;
    // ��ȡ�� Matrix ����� x ת��ֵ��dx ֵ��������С���һ���е�Ԫ�أ���
    property OffsetX: Single read GetOffsetX;
    // ��ȡ�� Matrix �� y ת��ֵ��dy ֵ��������С��ڶ����е�Ԫ�أ���
    property OffsetY: Single read GetOffsetY;
  end;

//--------------------------------------------------------------------------
// TRegion
//--------------------------------------------------------------------------

  TGpRegion = class(TGdiplusBase)
  private
    function GetDataSize: Integer;
  public
    // �������ڲ���ʼ���� Region ����
    constructor Create; overload;
    // ��ָ���� Rect �ṹ��ʼ���� Region ����
    constructor Create(rect: TGpRectF);  overload;
    constructor Create(rect: TGpRect); overload;
    // ��ָ���� Rect �ṹ��ʼ���� Region ����
    constructor Create(path: TGpGraphicsPath); overload;
    // �����е� Region ������ڲ����ݴ���һ���� Region ����
    // regionData ����Region�����ڲ����ݵĻ�������һ��ͨ��GetData���
    constructor Create(regionData: array of Byte); overload;
    // ��ָ�������� GDI ����ľ����ʼ���� Region ����
    constructor Create(hrgn: HRGN); overload;
    class function FromHRGN(hrgn: HRGN): TGpRegion;
    destructor Destroy; override;
    function Clone: TGpRegion;
    // ���� Region �����ʼ��Ϊ�����ڲ���
    procedure MakeInfinite;
    // ���� Region �����ʼ��Ϊ���ڲ���
    procedure MakeEmpty;

    // ���� RegionData������ʾ���������� Region �ṹ��������Ϣ��
    procedure GetData(var buffer: array of Byte; sizeFilled: PLongWord = nil);
    // ���� Region �������Ϊ��������ָ���ṹ�����Ľ�����
    procedure Intersect(const rect: TGpRect); overload;
    procedure Intersect(const rect: TGpRectF); overload;
    procedure Intersect(path: TGpGraphicsPath); overload;
    procedure Intersect(region: TGpRegion); overload;
    // ���� Region �������Ϊ��������ָ���ṹ�����Ĳ�����
    procedure Union(const rect: TGpRect); overload;
    procedure Union(const rect: TGpRectF); overload;
    procedure Union(path: TGpGraphicsPath); overload;
    procedure Union(region: TGpRegion); overload;
    // ���� Region �������Ϊ��������ָ���ṹ�����Ĳ�����ȥ�����ߵĽ���
    procedure Xor_(const rect: TGpRect); overload;
    procedure Xor_(const rect: TGpRectF); overload;
    procedure Xor_(path: TGpGraphicsPath); overload;
    procedure Xor_(region: TGpRegion); overload;
    // ���� Region �������Ϊ���������ڲ���ָ���ṹ������ཻ�Ĳ��֡�
    procedure Exclude(const rect: TGpRect); overload;
    procedure Exclude(const rect: TGpRectF); overload;
    procedure Exclude(path: TGpGraphicsPath); overload;
    procedure Exclude(region: TGpRegion); overload;
    // ���� Region �������Ϊָ���ṹ���߶�������� Region �����ཻ�Ĳ��֡�
    procedure Complement(const rect: TGpRect); overload;
    procedure Complement(const rect: TGpRectF); overload;
    procedure Complement(path: TGpGraphicsPath); overload;
    procedure Complement(region: TGpRegion); overload;
    // ʹ�� Region ���������ƫ��ָ��������
    procedure Translate(dx, dy: Single); overload;
    procedure Translate(dx, dy: Integer); overload;
    // ��ָ���� Matrix ����任�� Region ����
    procedure Transform(matrix: TGpMatrix);
    // ��ȡһ�����νṹ���þ����γ� Graphics ����Ļ��Ʊ����ϴ� Region ����ı߽硣
    procedure GetBounds(var rect: TGpRect; const g: TGpGraphics); overload;
    procedure GetBounds(var rect: TGpRectF; const g: TGpGraphics); overload;
    // ����ָ��ͼ���������д� Region ����� Windows GDI �����
    function GetHRGN(g: TGpGraphics): HRGN;
    // ���Դ� Region ������ָ���Ļ��Ʊ��� g ���Ƿ�յ��ڲ�
    function IsEmpty(g: TGpGraphics): Boolean;
    // ���Դ� Region ������ָ���Ļ��Ʊ������Ƿ������ڲ���
    function IsInfinite(g: TGpGraphics): Boolean;
    // ����ָ���������Ƿ�����ڴ� Region �����ڡ�
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
    // ��ȡ��� Region ������Ƶ� RectF �ṹ�����顣��������Ԫ�ظ���
    function GetRegionScans(matrix: TGpMatrix; var rects: array of TGpRectF): Integer; overload;
    function GetRegionScans(matrix: TGpMatrix; var rects: array of TGpRect): Integer; overload;
    // �������� Region ������Ϣ�������ĳ���
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
    // ��ָ�������Է��ش� FontFamily ��������ơ�
    function GetFamilyName(language: LANGID = 0): WideString;
    function Clone: TGpFontFamily;
    // FontFamily �����Ƿ���Ч
    function IsAvailable: Boolean;
    // ָʾָ���� FontStyle ö���Ƿ���Ч��
    function IsStyleAvailable(style: TFontStyles): Boolean;
    // ��ȡָ����ʽ�� em ���εĸ߶ȣ�����������Ƶ�λ��
    function GetEmHeight(style: TFontStyles): Word;
    // ����ָ����ʽ�� FontFamily ����ĵ�Ԫ������
    function GetCellAscent(style: TFontStyles): Word;
    // ����ָ����ʽ�� FontFamily ����ĵ�Ԫ���½�
    function GetCellDescent(style: TFontStyles): Word;
    // ����ָ����ʽ�� FontFamily ������о�
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
    // ���豸�����ĵ�ָ�� Windows ������� Font ����
    // DC ���������������ѡ��������豸�����ĵľ����
    // �˷����������ڴ� GDI+ Graphics �����õ� hdc����Ϊ�� hdc û��ѡ�������塣
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
    // ����ָ���� Graphics ����ĵ�ǰ��λ�����ش�������оࡣ
    function GetHeight(graphics: TGpGraphics): Single; overload;
    // ����ָ���Ĵ�ֱ�ֱ��ʻ��Ƶ��豸ʱ���ش� Font ����ĸ߶ȣ�������Ϊ��λ��
    // �о������������ı��еĻ���֮��Ĵ�ֱ���롣
    // ��ˣ��о�����м�Ŀհ׿ռ估�ַ�����ĸ߶ȡ�
    function GetHeight(dpi: Single): Single; overload;
    // ��ȡ�� Font �����������Ϣ��
    procedure GetFamily(family: TGpFontFamily);
    // ��ȡ������� Font ����ĵ�λ�������ġ���� Font �����ȫ���С
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

  TGpInstalledFontCollection = class(TGpFontCollection) // ��ʾ��װ��ϵͳ�ϵ����塣
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
// TImageAttributes ��������й��ڳ���ʱ��β���λͼ��ͼԪ�ļ���ɫ����Ϣ��
//  ά�������ɫ�������ã�������ɫ�������󡢻Ҷȵ�������٤��У��ֵ��
//  ��ɫӳ������ɫ��ֵ�����ֹ����У����Զ���ɫ����У����������������ɾ���ȵȡ�
//--------------------------------------------------------------------------
  TColorMap = GdipTypes.TColorMap;
  PColorMap = GdipTypes.PColorMap;
  TColorMatrix = GdipTypes.TColorMatrix;
  PColorMatrix = GdipTypes.PColorMatrix;

  TColorAdjustType = (ctDefault, ctBitmap, ctBrush, ctPen, ctText, ctCount, ctAny);
  // ��ͬ������ɫ�����������������ɫֵ��������ɫ���ƣ�, ��������ɫ����, ������ɫ����
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
    // Ϊָ�����������ɫ��������
    procedure SetColorMatrix(const colorMatrix: TColorMatrix;
               mode: TColorMatrixFlags = cfDefault;
               catype:  TColorAdjustType = ctDefault);
    // ���ָ��������ɫ��������
    procedure ClearColorMatrix(caType: TColorAdjustType = ctDefault);
    // Ϊָ�����������ɫ��������ͻҶȵ�������
    procedure SetColorMatrices(const colorMatrix, grayMatrix: TColorMatrix;
                  mode: TColorMatrixFlags = cfDefault;
                  catype: TColorAdjustType = ctDefault);
    procedure ClearColorMatrices(catype: TColorAdjustType = ctDefault);
    // Ϊָ�����������ֵ��
    // threshold: 0.0 �� 1.0 ֮�����ֵ.ָ��ÿ����ɫ�ɷֵķֽ�㡣�ٶ���ֵ����Ϊ 0.7��
    // ���Ҽٶ���ǰ�����ֵ���ɫ�еĺ�ɫ����ɫ����ɫ�ɷֱַ�Ϊ 230��50 �� 220��
    // ��ɫ�ɷ� 230 ���� 0.7x255����ˣ���ɫ�ɷֽ�����Ϊ 255��ȫ���ȣ���
    // ��ɫ�ɷ� 50 С�� 0.7x255����ˣ���ɫ�ɷֽ�����Ϊ 0��
    // ��ɫ�ɷ� 220 ���� 0.7x255����ˣ���ɫ�ɷֽ�����Ϊ 255
    procedure SetThreshold(threshold: Single; catype: TColorAdjustType = ctDefault);
    // Ϊָ����������ֵ��
    procedure ClearThreshold(catype: TColorAdjustType = ctDefault);
    // Ϊָ���������٤��ֵ��gamma ٤��У��ֵ�����͵�٤��ֵ�� 1.0 �� 2.2 ֮�䣻
    // ����ĳЩ����£�0.1 �� 5.0 ��Χ�ڵ�ֵҲ�����á�
    procedure SetGamma(gamma: Single; catype: TColorAdjustType = ctDefault);
    // ����٤��У����
    procedure ClearGamma(catype: TColorAdjustType = ctDefault);
    // Ϊָ�����ر���ɫ���������Ե��� ClearNoOp �ָ��� SetNoOp ����ǰ�Ѵ��ڵ���ɫ�������á�
    procedure SetNoOp(catype: TColorAdjustType = ctDefault);
    procedure ClearNoOp(catype: TColorAdjustType = ctDefault);
    // Ϊָ���������ɫ����͸����Χ����ֻҪ��ɫ�ɷִ��ڸߵ�ɫ����Χ�ڣ�����ɫ�ͻ��Ϊ͸���ġ�
    // colorLow ��ɫ��ֵ; colorHigh ��ɫ��ֵ
    procedure SetColorKey(const colorLow, colorHigh: TARGB; catype: TColorAdjustType = ctDefault);
    // Ϊָ��������ɫ����͸����Χ����
    procedure ClearColorKey(catype: TColorAdjustType = ctDefault);
    // Ϊָ��������� CMYK ���ͨ����flags: ָ�����ͨ����
    procedure SetOutputChannel(channelFlags: TColorChannelFlags; catype: TColorAdjustType = ctDefault);
    // Ϊָ�������� CMYK ���ͨ�����á�
    procedure ClearOutputChannel(catype: TColorAdjustType = ctDefault);
    // Ϊָ������������ͨ����ɫ�����ļ�
    procedure SetOutputChannelColorProfile(const colorProfileFilename: WideString;
                 catype: TColorAdjustType = ctDefault);
    // Ϊָ�����������ͨ����ɫ�����ļ����á�
    procedure ClearOutputChannelColorProfile(catype: TColorAdjustType = ctDefault);
    // Ϊָ�����������ɫ����ӳ���
    procedure SetRemapTable(const map: array of TColorMap; catype: TColorAdjustType = ctDefault);
    // �����ɫ����ӳ���
    procedure ClearRemapTable(catype: TColorAdjustType = ctDefault);
    // Ϊ��ˢ���������ɫ����ӳ���map: TColorMap���顣
    procedure SetBrushRemapTable(const map: array of TColorMap);
    // �����ˢ��ɫ����ӳ���
    procedure ClearBrushRemapTable;
    // ���û���ģʽ����ɫ�����ھ�����ν�����ƽ�̵�һ����״�ϣ���ƽ�̵���״�ı߽��ϡ�
    // ������С������������״ʱ�������ڸ���״��ƽ������������״��
    // mode �ظ���ͼ�񸱱�ƽ������ķ�ʽ; color ָ������ͼ���ⲿ�����ص���ɫ��
    procedure SetWrapMode(wrap: TWrapMode; const color: TARGB); overload;
    procedure SetWrapMode(wrap: TWrapMode); overload;
    // ����ָ�����ĵ������ã�������ɫ���е���ɫ��
    // ColorPalette��������ʱ����Ҫ�����ĵ�ɫ�壬�����ʱ�����ѵ����ĵ�ɫ��
    // ColorAdjustType ö�ٵ�Ԫ�أ���ָ����������ý�Ӧ���ڵ�ɫ������
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
    // ʹ�ø��ļ��е�Ƕ����ɫ������Ϣ����ָ�����ļ����� Image ����
    constructor Create(const filename: WideString; useEmbeddedColorManagement: Boolean = False); overload;
    class function FromFile(const filename: WideString; useEmbeddedColorManagement: Boolean = False): TGpImage;
    // ʹ��ָ������������Ƕ�����ɫ������Ϣ���Ӹ����������� Image ����
    constructor Create(stream: IStream; useEmbeddedColorManagement: Boolean = False); overload;
    class function FromStream(stream: IStream; useEmbeddedColorManagement: Boolean = False): TGpImage;
    destructor Destroy; override;
    function Clone: TGpImage; virtual;
    // ����ͼ����ָ���ĸ�ʽ���浽ָ�����ļ���
    // ע��ͨ���ļ���������Image�����ļ���������״̬��ֱ�Ӹ��Ǳ�������
    procedure Save(const filename: WideString; const clsidEncoder: TCLSID;
        const encoderParams: PEncoderParameters = nil); overload;
    // ����ͼ����ָ���ĸ�ʽ���浽ָ�������С�
    procedure Save(stream: IStream; const clsidEncoder: TCLSID;
        const encoderParams: PEncoderParameters = nil); overload;
    // ����һ Save ����������ָ�����ļ����������һ֡��
    procedure SaveAdd(const encoderParams: PEncoderParameters); overload;
    procedure SaveAdd(newImage: TGpImage; const encoderParams: PEncoderParameters); overload;
    // ��ָ���ĵ�λ��ȡ�� Image ����ľ���
    procedure GetBounds(var srcRect: TGpRectF; var srcUnit: TUnit);
    // ���ش� Image ���������ͼ��ʹ�ú����Free
    function GetThumbnailImage(thumbWidth, thumbHeight: Integer;
        callback:TGetThumbnailImageAbort = nil; callbackData: Pointer = nil): TGpImage;
    // ��ȡ GUID �����飬��Щ GUID ��ʾ Image ������֡��ά�ȡ�
    procedure GetFrameDimensionsList(dimensionIDs: PGUID; Count: Integer);
    // ����ָ��ά�ȵ�֡����
    function GetFrameCount(const dimensionID: TGUID): Integer;
    // ѡ����ά�Ⱥ�����ָ����֡��
    procedure SelectActiveFrame(const dimensionID: TGUID; frameIndex: Integer);
    // �˷�����ת����ת����ͬʱ��ת�ͷ�ת Image ����
    procedure RotateFlip(rotateFlipType: TRotateFlipType);
    // ��ȡ�洢�� Image �����е�������� ID��list���Ȳ�С��PropertyCount
    procedure GetPropertyIdList(numOfProperty: Integer; list: PPropID);
    // ��ȡpropID��ָ������ĳ��ȣ�����TPropertyItem���Ⱥ���value��ָ�ĳ���
    function GetPropertyItemSize(propId: PROPID): Integer;
    // ��ȡpropID��ָ�����buffer�ĳ���Ӧ��С��GetPropertyItemSize
    procedure GetPropertyItem(propId: PROPID; buffer: PPropertyItem);
    // ��ȡȫ�������alItems�ĳ��ȱ��벻С��PropertySize
    procedure GetAllPropertyItems(allItems: PPropertyItem);
    // ��Image����ȥpropID��ָ��������
    procedure RemovePropertyItem(propId: PROPID);
    // ����������
    procedure SetPropertyItem(const item: TPropertyItem);
    // �����й�ָ����ͼ���������֧�ֵĲ�������Ϣ�ĳ��ȣ��ֽ�����
    function GetEncoderParameterListSize(const clsidEncoder: TCLSID): Integer;
    // �����й�ָ����ͼ���������֧�ֵĲ�������Ϣ��
    procedure GetEncoderParameterList(const clsidEncoder: TCLSID; size: Integer;
                                      buffer: PEncoderParameters);
    // ����ָ�������ظ�ʽ����ɫ��ȣ����ص�λ������
    class function GetPixelFormatSize(Format: TPixelFormat): Integer;

    // ��ȡ�� Image ��������Ա��
    property Flags: TImageFlags read GetFlags;
    // ��ȡ�� Image ����ĸ߶ȡ�
    property Height: Integer read GetHeight;
    // ��ȡ�� Image �����ˮƽ�ֱ��ʣ��ԡ�����/Ӣ�硱Ϊ��λ����
    property HorizontalResolution: Single read GetHorizontalResolution;
    // ��ȡ��ͼ��Ŀ�Ⱥ͸߶ȡ�
    property PhysicalDimension: TGpSizeF read GetPhysicalDimension;
    // ��ȡ�� Image ����ĸ�ʽ��
    property RawFormat: TGUID read GetRawFormat;
    // ��ȡ Image ���������
    property ImageType: TImageType read GetType;
    // ��ȡ�� Image ����Ĵ�ֱ�ֱ��ʣ��ԡ�����/Ӣ�硱Ϊ��λ����
    property VerticalResolution: Single read GetVerticalResolution;
    // ��ȡ�� Image ����Ŀ�ȡ�
    property Width: Integer read GetWidth;
    // ��ȡ�� Image ��������ظ�ʽ��
    property PixelFormat: TPixelFormat read GetPixelFormat;
    property FrameDimensionsCount: Integer read GetFrameDimensionsCount;
    // ��ȡ�洢�� Image �����е����Ը���
    property PropertyCount: Integer read GetPropertyCount;
    // ��ȡ�洢�� Image �����е�ȫ��������ĳ��ȣ�����TpropertyItem.value��ָ���ֽ���
    property PropertySize: Integer read GetPropertySize;
    // ��ȡ��ɫ��ĳ���
    property PaletteSize: Integer read GetPaletteSize;
    // ��ȡ���������ڴ� Image ����ĵ�ɫ�塣
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
    constructor Create(width, height, stride: Integer; // stride �������������е��ڴ��С
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
    // ����IDirectDrawSurface7�����õ���������GpDirectDrawSurface7=Pointer�����
    // �������һ���Ӵ�ĵ�Ԫ�������õ�ʱ����Pointerǿ��ת������
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
    // �� Bitmap ����������ϵͳ�ڴ��С����� rect: ��ָ��Ҫ������ Bitmap ���֡�
    // flags: ImageLockMode ö�٣���ָ�� Bitmap ����ķ��ʼ��𣨶���д����
    // format: Bitmap ��������ݸ�ʽ
    function LockBits(const rect: TGpRect; flags: TImageLockModes; format: TPixelFormat): TBitmapData;
    // ��ϵͳ�ڴ���� Bitmap��
    procedure UnlockBits(var lockedBitmapData: TBitmapData);
    // ���ô� Bitmap �ķֱ��ʡ�
    procedure SetResolution(xdpi, ydpi: Single);
    // �ô� Bitmap ���󴴽������� GDI λͼ����colorBackgroundָ������ɫ��
    // ���λͼ��ȫ��͸��������Դ˲�����Ӧ���� DeleteObject �ͷ� GDI λͼ����
    function GetHBITMAP(colorBackground: TARGB): HBITMAP;
    // ����ͼ��ľ����
    function GetHICON: HICON;
    // ��ȡ������ Bitmap ������ָ�����ص���ɫ��
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
    // ��ָ���ľ���� WmfPlaceableFileHeader �����ʼ�� Metafile �����ʵ����
    // deleteWmf: ȷ��ɾ�� Metafile ����ʱ�Ƿ�ɾ���� Metafile ����ľ����
    constructor Create(hWmf: HMETAFILE; wmfPlaceableFileHeader: TWmfPlaceableFileHeader;
                       deleteWmf: Boolean = False); overload;
    // ��ָ������ǿ��ͼԪ�ļ��ľ����ʼ�� Metafile �����ʵ����
    // // deleteEmf: ȷ��ɾ�� Metafile ����ʱ�Ƿ�ɾ���� Metafile ����ľ��
    constructor Create(hEmf: HENHMETAFILE; deleteEmf: Boolean = False); overload;
    // ��ָ�����ļ�����ʼ�� Metafile �����ʵ����
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
    // ��ȡ��� Metafile ��������� MetafileHeader ����
    class procedure GetMetafileHeader(hWmf: HMETAFILE;
                       const wmfPlaceableFileHeader: TWmfPlaceableFileHeader; header: TMetafileHeader); overload;
    class procedure GetMetafileHeader(hEmf: HENHMETAFILE; header: TMetafileHeader); overload;
    class procedure GetMetafileHeader(const filename: WideString; header: TMetafileHeader); overload;
    class procedure GetMetafileHeader(stream: IStream; header: TMetafileHeader); overload;
    procedure GetMetafileHeader(header: TMetafileHeader); overload;

    // Once this method is called, the Metafile object is in an invalid state
    // and can no longer be used.  It is the responsiblity of the caller to
    // invoke DeleteEnhMetaFile to delete this hEmf.
    // ������ǿ�� Metafile ����� Windows �����
    function GetHENHMETAFILE: HENHMETAFILE;
    // ���ŵ���ͼԪ�ļ���¼��
    // recordType:ָ�����ڲ��ŵ�ͼԪ�ļ���¼�����͡�flags: ָ����¼���Եı�־����
    // dataSize: ��¼�����е��ֽ����� data: ������¼���ݵ��ֽ����顣
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
*   ��ñ����ֱ�ߵ���ʼ�ͽ��������������� GDI+ Pen ������Ƶ����ߴ���
*    GDI+ ֧�ּ���Ԥ�������ñ��ʽ�����һ������û������Լ�����ñ��ʽ��
*   �������ڴ����Զ�����ñ��ʽ��
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
    // ͨ��ָ��������������Ƕ���ָ�������� LineCap ö�ٳ�ʼ�� CustomLineCap �����ʵ����
    // fillPath: �Զ�����ñ������ݵĶ���strokePath: �Զ�����ñ�����Ķ���
    // baseCap: �����䴴���Զ�����ñ����ñ��baseInset: ��ñ��ֱ��֮��ľ��롣
    constructor Create(fillPath, strokePath: TGpGraphicsPath;
        baseCap: TLineCap = lcFlat; baseInset: Single = 0);
    destructor Destroy; override;
    function Clone: TGpCustomLineCap;
    // �������ڹ��ɴ��Զ�����ñ����ʼֱ�ߺͽ���ֱ����ͬ����ñ��
    procedure SetStrokeCap(strokeCap: TLineCap);
    // ��ȡ���ڹ��ɴ��Զ�����ñ����ʼֱ�ߺͽ���ֱ�ߵ���ñ��
    procedure GetStrokeCaps(var startCap, endCap: TLineCap);
    // �������ڹ��ɴ��Զ�����ñ����ʼֱ�ߺͽ���ֱ�ߵ���ñ��
    procedure SetStrokeCaps(startCap, endCap: TLineCap);
    // ��ȡ�����ø� CustomLineCap �����ڵ� LineCap ö�١�
    property BaseCap: TLineCap read GetBaseCap write SetBaseCap;
    // ��ȡ��������ñ��ֱ��֮��ľ��롣
    property BaseInset: Single read GetBaseInset write SetBaseInset;
    // ��ȡ������ LineJoin ö�٣���ö��ȷ��������ӹ��ɴ� CustomLineCap �����ֱ�ߡ�
    property StrokeJoin: TLineJoin read GetStrokeJoin write SetStrokeJoin;
    // ��ȡ����������� Pen ����Ŀ�ȴ� CustomLineCap ��������������
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
    // ʹ��ָ���Ŀ�ȡ��߶���ʵ������ͷ��ñ�Ƿ����ȡ���ڴ��ݸ� isFilled �����Ĳ�����
    constructor Create(width, height: Single; isFilled: Boolean = True);
    // ��ȡ�����ü�ͷñ�ĸ߶ȡ�
    property Height: Single read GetHeight write SetHeight;
    // ��ȡ�����ü�ͷñ�Ŀ�ȡ�
    property Width: Single read GetWidth write SetWidth;
    // ��ȡ�����ü�ͷñ�����������֮�䵥λ����Ŀ��
    property MiddleInset: Single read GetMiddleInset write SetMiddleInset;
    // ��ȡ�������Ƿ�����ͷñ��
    property Filled: Boolean read GetFillState write SetFillState;
  end;

  TBrushType = (btSolidColor, btHatchFill, btTextureFill, btPathGradient, btLinearGradient);

  // Bursh �ĳ������
  TGpBrush = class(TGdiplusBase)
  private
    function GetType: TBrushType;
  public
    destructor Destroy; override;
    function Clone: TGpBrush; virtual;
    // ����Brush����
    property BrushType: TBrushType read GetType;
  end;

//--------------------------------------------------------------------------
// Solid Fill Brush Object  ��ɫ��ˢ
//--------------------------------------------------------------------------

  TGpSolidBrush  = class(TGpBrush)
  private
    function GetColor: TARGB;
    procedure SetColor(const color: TARGB);
  public
    // ��ʼ��ָ����ɫ���� SolidBrush ����
    constructor Create(color: TARGB);
    // ��ȡ�����ô� SolidBrush �������ɫ��
    property Color: TARGB read GetColor write SetColor;
  end;

//--------------------------------------------------------------------------
// Texture Brush Fill Object  ͼ��ˢ
//--------------------------------------------------------------------------

  TGpTextureBrush = class(TGpBrush)
  private
    procedure SetWrapMode(wrapMode: TWrapMode);
    function GetWrapMode: TWrapMode;
    function GetImage: TGpImage;
  public
    // ��ʼ��ʹ��ָ����ͼ����Զ�����ģʽ���� TextureBrush ����
    constructor Create(image: TGpImage; wrapMode:
                       TWrapMode = wmTile); overload;
    // ��ʼ��ʹ��ָ��ͼ���Զ�����ģʽ�ͳߴ罨���� TextureBrush ����
    constructor Create(image: TGpImage; wrapMode: TWrapMode; dstRect: TGpRectF); overload;
    constructor Create(image: TGpImage; wrapMode: TWrapMode; dstRect: TGpRect); overload;
    constructor Create(image: TGpImage; wrapMode: TWrapMode;
                       dstX, dstY, dstWidth, dstHeight: Single); overload;
    constructor Create(image: TGpImage; wrapMode: TWrapMode;
                       dstX, dstY, dstWidth, dstHeight: Integer); overload;
    // ��ʼ��ʹ��ָ����ͼ�񡢾��γߴ��ͼ�����Ե��� TextureBrush ����
    constructor Create(image: TGpImage; dstRect: TGpRectF;
                       imageAttributes: TGpImageAttributes = nil); overload;
    constructor Create(image: TGpImage; dstRect: TGpRect;
                       imageAttributes: TGpImageAttributes = nil); overload;

    // ��ȡ������ Matrix ������Ϊ��� TextureBrush ���������ͼ����ֲ����α任��
    procedure GetTransform(matrix: TGpMatrix);
    procedure SetTransform(const matrix: TGpMatrix);
    // ���� TextureBrush ����� Transform ��������Ϊ��λ����
    procedure ResetTransform;
    // ��ָ��˳�򽫱�ʾ TextureBrush ����ľֲ����α任�� Matrix �������ָ���� Matrix ����
    procedure MultiplyTransform(matrix: TGpMatrix; order: TMatrixOrder  = moPrepend);
    // ��ָ��˳�򽫴� TextureBrush ����ľֲ����α任ƽ��ָ���ĳߴ硣
    procedure TranslateTransform(dx, dy: Single; order: TMatrixOrder = moPrepend);
    // ��ָ��˳�򽫴� TextureBrush ����ľֲ����α任����ָ��������
    procedure ScaleTransform(sx, sy: Single; order: TMatrixOrder = moPrepend);
    // ���� TextureBrush ����ľֲ����α任��תָ���ĽǶȡ�
    procedure RotateTransform(angle: Single; order: TMatrixOrder = moPrepend);

    // ��ȡ��� TextureBrush ��������� Image ���󡣱���Free
    property Image: TGpImage read GetImage;
    // ��ȡ������ WrapMode ö�٣���ָʾ�� TextureBrush ����Ļ���ģʽ
    property WrapMode: TWrapMode read GetWrapMode write SetWrapMode;
  end;

//--------------------------------------------------------------------------
// �����װ˫ɫ������Զ����ɫ���䡣
// ���н��䶼�����ɾ��εĿ�Ȼ�������ָ����ֱ�߶���ġ�
// Ĭ������£�˫ɫ��������ָ��ֱ�ߴ���ʼɫ������ɫ�ľ���ˮƽ���Ի�ϡ�
// ʹ�� Blend �ࡢSetSigmaBellShape ������ SetBlendTriangularShape ����
// �Զ�����ͼ����ͨ���ڹ��캯����ָ�� LinearGradientMode ö�ٻ�Ƕ��Զ��彥��ķ���
// ʹ�� InterpolationColors ���Դ�����ɫ���䡣
// Transform ����ָ��Ӧ�õ�����ľֲ����α��Ρ�
//--------------------------------------------------------------------------

  TLinearGradientMode = (
    lmHorizontal,         // ָ�������ҵĽ��䡣
    lmVertical,           // ָ�����ϵ��µĽ��䡣
    lmForwardDiagonal,    // ָ�������ϵ����µĽ��䡣
    lmBackwardDiagonal    // ָ�������ϵ����µĽ��䡣
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
    // ʹ��ָ���ĵ����ɫ��ʼ�� LinearGradientBrush �����ʵ����
    constructor Create(point1, point2: TGpPointF; color1, color2: TARGB); overload;
    constructor Create(point1, point2: TGpPoint; color1, color2: TARGB); overload;
    // ����һ�����Ρ���ʼ��ɫ�ͽ�����ɫ�Լ����򣬴��� LinearGradientBrush �����ʵ����
    constructor Create(rect: TGpRectF; color1, color2: TARGB;
                  mode: TLinearGradientMode = lmHorizontal); overload;
    constructor Create(rect: TGpRect; color1, color2: TARGB;
                  mode: TLinearGradientMode = lmHorizontal); overload;
    // ���ݾ��Ρ���ʼ��ɫ�ͽ�����ɫ�Լ�����Ƕȣ����� LinearGradientBrush �����ʵ����
    // isAngleScalable:ָ���Ƕ��Ƿ��� LinearGradientBrush �����ı�����Ӱ��
    constructor Create(rect: TGpRectF; color1, color2: TARGB;
                       angle: Single; isAngleScalable: Boolean = False); overload;
    constructor Create(rect: TGpRect; color1, color2: TARGB;
                       angle: Single; isAngleScalable: Boolean = False); overload;
    // ��ȡ�����ý������ʼɫ�ͽ���ɫ��
    procedure GetLinearColors(var color1, color2: TARGB);
    procedure SetLinearColors(color1, color2: TARGB);
    // ��ȡ������ Blend����ָ��Ϊ���䶨���Զ�����ɵ�λ�ú����ӡ���˫ɫ������Ч
    // blendFactors�����ڽ���Ļ���������飬������ӱ�ʾ��Ӧλ�ý���ɫռ��ʼɫ�ı��ʡ�
    // blendPositions������Ļ��λ�õ����飬��Щλ���ǽ��� 0 �� 1 ֮���ֵ��
    // ����߱���Ϊ0�����ұ߱���Ϊ1
    procedure SetBlend(const blendFactors, blendPositions: array of Single);
    function GetBlend(var blendFactors, blendPositions: array of Single): Integer;
    // ��ȡ������һ�������ɫ���Խ���� ColorBlend��
    // presetColors:�ؽ������Ӧλ�ô�ʹ�õ���ɫ����ɫ���顣
    // blendPositions:�ؽ����ߵ�λ�ã���Щλ���ǽ��� 0 �� 1 ֮���ֵ��
    // ����߱���Ϊ0�����ұ߱���Ϊ1
    procedure SetInterpolationColors(const presetColors: array of TARGB;
                                     const blendPositions: array of Single);
    function GetInterpolationColors(var presetColors: array of TARGB;
                                    var blendPositions: array of Single): Integer;
    // ���������������ߵĽ�����ɹ��̡�
    // focus: 0 - 1��ָ���������ģ�������ֻ�ɽ���ɫ���ɵĵ㣩��
    // scale: 0 - 1, ָ����ɫ�� focus ���ɵĹ�ģ(�̶�)��
    procedure SetBlendBellShape(focus: Single; scale: Single = 1.0);
    // ����һ��������ɫ�����˵�����ɫ���Թ��ɵ����Խ�����̡�
    procedure SetBlendTriangularShape(focus: Single; scale: Single = 1.0);
    // ��ȡ������һ�� Matrix ���󣬸ö���Ϊ�� LinearGradientBrush ������ֲ����α��Ρ�
    procedure SetTransform(const matrix: TGpMatrix);
    procedure GetTransform(matrix: TGpMatrix);
    // �� Transform ��������Ϊ��ͬ��
    procedure ResetTransform;
    // ͨ��ָ���� Matrix����LinearGradientBrush �ľֲ����α��ε� Matrix �������ָ���� Matrix ��ˡ�
    procedure MultiplyTransform(const matrix: TGpMatrix; order: TMatrixOrder = moPrepend);
    // ���ֲ����α���ת��ָ���ĳߴ硣�÷�����Ԥ�ȼ���Ա��ε�ת����
    procedure TranslateTransform(dx, dy: Single; order: TMatrixOrder = moPrepend);
    // ���ֲ����α�������ָ���������÷���Ԥ�ȼ���Ա��ε����ž���
    procedure ScaleTransform(sx, sy: Single; order: TMatrixOrder = moPrepend);
    // ���ֲ����α�����תָ����С���÷���Ԥ�ȼ���Ա��ε���ת��
    procedure RotateTransform(angle: Single; order: TMatrixOrder = moPrepend);
    // ��ȡ���彥�����ʼ����ս��ľ�������
    property RectangleF: TGpRectF read GetRectangleF;
    property Rectangle: TGpRect read GetRectangle;
    // ��ȡ������ WrapMode ö�٣���ָʾ�� LinearGradientBrush �Ļ���ģʽ��
    property WrapMode: TWrapMode read GetWrapMode write SetWrapMode;
    // ��ȡ������һ��ֵ����ֵָʾ�Ƿ�Ϊ�� LinearGradientBrush ��������٤��������
    property GammaCorrection: Boolean read GetGammaCorrection write SetGammaCorrection;
    property BlendCount: Integer read GetBlendCount;
    property InterpolationColorCount: Integer read GetInterpolationColorCount;
  end;

//--------------------------------------------------------------------------
// Hatch Brush Object ����Ӱ��ʽ��ǰ��ɫ�ͱ���ɫ������λ��ʡ�
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
    // ʹ��ָ���� HatchStyle ö�١�ǰ��ɫ�ͱ���ɫ��ʼ�� HatchBrush �����ʵ����
    constructor Create(hatchStyle: THatchStyle; foreColor: TARGB; backColor: TARGB = kcBlack);
    // ��ȡ�� HatchBrush ������Ƶ���Ӱ��������ɫ��
    property ForegroundColor: TARGB read GetForegroundColor;
    // ��ȡ�� HatchBrush ������Ƶ���Ӱ������ռ����ɫ
    property BackgroundColor: TARGB read GetBackgroundColor;
    // ��ȡ�� HatchBrush �������Ӱ��ʽ��
    property HatchStyle: THatchStyle read GetHatchStyle;
  end;

//--------------------------------------------------------------------------
// Path Gradient Brush ͨ��������� GraphicsPath ������ڲ�
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
    // ʹ��ָ���ĵ�ͻ���ģʽ��ʼ�� PathGradientBrush �����ʵ����
    constructor Create(points: array of TGpPointF;
                       wrapMode: TWrapMode  = wmClamp); overload;
    constructor Create(points: array of TGpPoint;
                       wrapMode: TWrapMode  = wmClamp); overload;
    // ʹ��ָ����·����ʼ�� PathGradientBrush �����ʵ����
    constructor Create(path: TGpGraphicsPath); overload;
    // ��ȡ��������� PathGradientBrush ��������·���еĵ����Ӧ����ɫ�����顣
    // ����ʵ�ʻ�ȡ�����õ�����Ԫ�ظ���
    function GetSurroundColors(var colors: array of TARGB): Integer;
    procedure SetSurroundColors(colors: array of TARGB);
    // ��ȡ������ Blend����ָ��Ϊ���䶨���Զ�����ɵ�λ�ú����ӡ�
    function GetBlend(var blendFactors, blendPositions: array of Single): Integer;
    procedure SetBlend(blendFactors, blendPositions: array of Single);
    // ��ȡ������һ�������ɫ���Խ���� ColorBlend ����
    procedure SetInterpolationColors(presetColors: array of TARGB;
                                     blendPositions: array of Single);
    function GetInterpolationColors(var presetColors: array of TARGB;
                                    var blendPositions: array of Single): Integer;
    // ���������������ߵĽ�����ɹ��̡�
    procedure SetBlendBellShape(focus: Single; scale: Single = 1.0);
    // ����һ��������ɫ����Χɫ���Թ��ɵĽ�����̡�
    // focus: ���� 0 �� 1 ֮���һ��ֵ����ָ����·�����ĵ�·���߽������뾶��������ɫ������ߵ�λ�á�
    // scale: ���� 0 �� 1 ֮���һ��ֵ����ָ����߽�ɫ��ϵ�����ɫ��������ȡ�
    procedure SetBlendTriangularShape(focus: Single; scale: Single = 1.0);
    // ��ȡ������һ�� Matrix ���󣬸ö���Ϊ�� PathGradientBrush ������ֲ����α��Ρ�
    procedure GetTransform(matrix: TGpMatrix);
    procedure SetTransform(const matrix: TGpMatrix);
    // �� Transform ��������Ϊ��ͬ��
    procedure ResetTransform;
    // ͨ��ָ���� Matrix����PathGradientBrush�ľֲ����α��ε� Matrix �������ָ���� Matrix ��ˡ�
    procedure MultiplyTransform(const matrix: TGpMatrix; order: TMatrixOrder  = moPrepend);
    // ��ָ����˳����ֲ����α���Ӧ��ָ����ת����
    procedure TranslateTransform(dx, dy: Single; order: TMatrixOrder = moPrepend);
    // ���ֲ����α�����ָ��˳������ָ��������
    procedure ScaleTransform(sx, sy: Single; order: TMatrixOrder = moPrepend);
    // ��ָ��˳�򽫾ֲ����α�����תָ������
    procedure RotateTransform(angle: Single; order: TMatrixOrder = moPrepend);

    procedure GetGraphicsPath(path: TGpGraphicsPath);
    procedure SetGraphicsPath(const path: TGpGraphicsPath);
    // ��ȡ�� PathGradientBrush ����ı߿�
    property Rectangle: TGpRectF read GetRectangle;
    property RectangleI: TGpRect read GetRectangleI;
    // ��ȡ������һ�� WrapMode ö�٣���ָʾ�� PathGradientBrush ����Ļ���ģʽ��
    property WrapMode: TWrapMode read GetWrapMode write SetWrapMode;
    property GammaCorrection: Boolean read GetGammaCorrection write SetGammaCorrection;
    property BlendCount: Integer read GetBlendCount;
    property PointCount: Integer read GetPointCount;
    property SurroundColorCount: Integer read GetSurroundColorCount;
    // ��ȡ������·����������Ĵ�����ɫ��
    property CenterColor: TARGB read GetCenterColor write SetCenterColor;
    // ��ȡ������·����������ĵ㡣
    property CenterPoint: TGpPointF read GetCenterPoint write SetCenterPoint;
    property CenterPointI: TGpPoint read GetCenterPointI write SetCenterPointI;
    // ��ȡ�����ý�����ɵĽ��㡣
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
    // ��������ȷ��ñ��ʽ��ֵ������ʽ���ڽ���ͨ���� Pen ������Ƶ�ֱ�ߡ�
    procedure SetLineCap(startCap, endCap: TLineCap; dashCap: TDashCap);
    // ��ȡ��������ͨ���� Pen ������Ƶ�ֱ�����Ҫʹ�õ��Զ���ñ��
    procedure SetCustomStartCap(const customCap: TGpCustomLineCap);
    procedure GetCustomStartCap(customCap: TGpCustomLineCap);
    // ��ȡ��������ͨ���� Pen ������Ƶ�ֱ���յ�Ҫʹ�õ��Զ���ñ��
    procedure SetCustomEndCap(const customCap: TGpCustomLineCap);
    procedure GetCustomEndCap(customCap: TGpCustomLineCap);
    // ��ȡ�����ô� Pen ����ļ��α任��
    procedure SetTransform(const matrix: TGpMatrix);
    procedure GetTransform(matrix: TGpMatrix);
    // ���� Pen ����ļ��α任��������Ϊ��λ����
    procedure ResetTransform;
    // ��ָ���� Matrix ���Դ� Pen ����ı任����
    procedure MultiplyTransform(const matrix: TGpMatrix; order: TMatrixOrder = moPrepend);
    // ���ֲ����α任ƽ��ָ���ߴ硣
    procedure TranslateTransform(dx, dy: Single; order: TMatrixOrder = moPrepend);
    // ���ֲ����α任����ָ��������
    procedure ScaleTransform(sx, sy: Single; order: TMatrixOrder = moPrepend);
    // ���ֲ����α任��תָ���Ƕȡ�
    procedure RotateTransform(angle: Single; order: TMatrixOrder = moPrepend);
    // ��ȡ�������Զ���Ķ̻��ߺͿհ���������顣
    procedure SetDashPattern(const dashArray: array of Single);
    function GetDashPattern(var dashArray: array of Single): Integer;
    // ��ȡ����������ָ�����ϸֱʵ�����ֵ�����ϸֱʻ�����ƽ��ֱ�ߺͿհ�������ɵĸ���ֱ�ߡ�
    // compoundArray����ָ�����������ʵ���顣�������е�Ԫ�ر��밴�������У�����С�� 0��Ҳ���ܴ��� 1��
    procedure SetCompoundArray(compoundArray: array of Single);
    function GetCompoundArray(var compoundArray: array of Single): Integer;

    property CompoundArrayCount: Integer read GetCompoundArrayCount;
    property DashPatternCount: Integer read GetDashPatternCount;
    // ��ȡ�ô� Pen ������Ƶ�ֱ�ߵ���ʽ��
    property PenType: TPenType read GetPenType;
    // ��ȡ���������ڶ̻����յ��ñ��ʽ����Щ�̻��߹���ͨ���� Pen ������Ƶ����ߡ�
    // ��� Pen ����� Pen.Alignment ��������Ϊ PenAlignment.Inset��
    // ��Ҫ������������Ϊ DashCapTriangle��
    property DashCap: TDashCap read GetDashCap write SetDashCap;
    // ��ȡ����������ͨ���� Pen ������Ƶ����ߵ���ʽ��
    property DashStyle: TDashStyle read GetDashStyle write SetDashStyle;
    // ��ȡ������ֱ�ߵ���㵽�̻���ͼ����ʼ���ľ��롣
    property DashOffset: Single read GetDashOffset write SetDashOffset;
    // ��ȡ����������ͨ���� Pen ������Ƶ�ֱ�������յ��ñ��ʽ��
    property StartCap: TLineCap read GetStartCap write SetStartCap;
    property EndCap: TLineCap read GetEndCap write SetEndCap;
    // ��ȡ������ͨ���� Pen ������Ƶ���������ֱ���յ�֮���������ʽ��
    property LineJoin: TLineJoin read GetLineJoin write SetLineJoin;
    // ��ȡ������б�ӽ������ӿ�ȵ����ơ�
    property MiterLimit: Single read GetMiterLimit write SetMiterLimit;
    property Width: Single read GetWidth write SetWidth;
    // ��ȡ����������ȷ���� Pen ��������Ե� Brush ���󡣷��ص�TBrush�����ͷ�
    property Brush: TGpBrush read GetBrush write SetBrush;
    // ��ȡ�����ô� Pen ����Ķ��뷽ʽ��
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
    // ��ָ���� StringFormatFlags ö�ٺ����Գ�ʼ���µ� StringFormat ����
    constructor Create(formatFlags: TStringFormatFlags = []; language: LANGID = LANG_NEUTRAL); overload;
    // ��ָ�������� StringFormat �����ʼ���� StringFormat ����
    constructor Create(format: TGpStringFormat); overload;
    // ��ȡһ���Ĭ�� StringFormat ����
    class function GenericDefault: TGpStringFormat;
    // ��ȡһ��İ�ʽ StringFormat ����
    class function GenericTypographic: TGpStringFormat;
    function Clone: TGpStringFormat;
    destructor Destroy; override;
    // ��ȡ�������Ʊ�λ��firstTabOffset: �ı��п�ͷ�͵�һ���Ʊ�λ֮��Ŀո�����
    // tabStops: �Ʊ�λ֮��ľ��루�Կո�����ʾ��������
    procedure SetTabStops(firstTabOffset: Single; tabStops: array of Single);
    function GetTabStops(var firstTabOffset: Single; var tabStops: array of Single): Integer;
    // ָ���ñ��������滻��������ʱʹ�õ����Ժͷ�����
    procedure SetDigitSubstitution(language: LANGID; substitute: TStringDigitSubstitute);
    // ָ�� CharacterRange �ṹ�����飬��Щ�ṹ��ʾͨ������ Graphics.MeasureCharacterRanges
    // �������ⶨ���ַ��ķ�Χ��
    procedure SetMeasurableCharacterRanges(const ranges: array of TCharacterRange);

    property TabStopCount: Integer read GetTabStopCount;
    // ��ȡ�ñ��������滻��������ʱʹ�õ����ԡ�
    property DigitSubstitutionLanguage: LANGID read GetDigitSubstitutionLanguage;
    // ��ȡҪ���������滻�ķ�����
    property DigitSubstitutionMethod: TStringDigitSubstitute read GetDigitSubstitutionMethod;
    property MeasurableCharacterRangeCount: Integer read GetMeasurableCharacterRangeCount;
    // ��ȡ�������ı����뷽ʽ����Ϣ��
    property Alignment: TStringAlignment read GetAlignment write SetAlignment;
    // ��ȡ�����ð�����ʽ����Ϣ�� StringFormatFlags ö�١�
    property FormatFlags: TStringFormatFlags read GetFormatFlags write SetFormatFlags;
    // ��ȡ�����ô� StringFormat ����� HotkeyPrefix ����
    property HotkeyPrefix: THotkeyPrefix read GetHotkeyPrefix write SetHotkeyPrefix;
    // ��ȡ�������еĶ��뷽ʽ
    property LineAlignment: TStringAlignment read GetLineAlignment write SetLineAlignment;
    // ��ȡ�����û��Ƶ��ı��������־��εı�Եʱ�����õķ�ʽ
    property Trimming: TStringTrimming read GetTrimming write SetTrimming;
  end;
  // ȱʡ���գ�ΪpsStart
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
    // ��� GraphicsPath ����׷��һ���߶Ρ�
    procedure AddLine(const pt1, pt2: TGpPointF); overload;
    procedure AddLine(x1, y1, x2, y2: Single); overload;
    procedure AddLine(const pt1, pt2: TGpPoint); overload;
    procedure AddLine(x1, y1, x2, y2: Integer); overload;
    // ��� GraphicsPath ����ĩβ׷��һϵ���໥���ӵ��߶Ρ�
    procedure AddLines(const points: array of TGpPointF); overload;
    procedure AddLines(const points: array of TGpPoint); overload;
    // ��ǰͼ��׷��һ����Բ����
    procedure AddArc(const rect: TGpRectF; startAngle, sweepAngle: Single); overload;
    procedure AddArc(x, y, width, height, startAngle, sweepAngle: Single); overload;
    procedure AddArc(const rect: TGpRect; startAngle, sweepAngle: Single); overload;
    procedure AddArc(x, y, width, height: Integer; startAngle, sweepAngle: Single); overload;
    // �ڵ�ǰͼ�������һ���������������ߡ�
    procedure AddBezier(const pt1, pt2, pt3, pt4: TGpPointF); overload;
    procedure AddBezier(x1, y1, x2, y2, x3, y3, x4, y4: Single); overload;
    procedure AddBezier(const pt1, pt2, pt3, pt4: TGpPoint); overload;
    procedure AddBezier(x1, y1, x2, y2, x3, y3, x4, y4: Integer); overload;
    // �ڵ�ǰͼ�������һϵ���໥���ӵ��������������ߡ�
    procedure AddBeziers(const points: array of TGpPointF); overload;
    procedure AddBeziers(const points: array of TGpPoint); overload;
    // ��ǰͼ�����һ���������ߡ��������߾��������е�ÿ���㣬���ʹ�û����������ߡ�
    procedure AddCurve(const points: array of TGpPointF); overload;
    procedure AddCurve(const points: array of TGpPointF; tension: Single); overload;
    procedure AddCurve(const points: array of TGpPointF;
                       offset, numberOfSegments: Integer; tension: Single); overload;
    procedure AddCurve(const points: array of TGpPoint); overload;
    procedure AddCurve(const points: array of TGpPoint; tension: Single); overload;
    procedure AddCurve(const points: array of TGpPoint;
                       offset, numberOfSegments: Integer; tension: Single); overload;
    // ���·�����һ���պ����ߡ��������߾��������е�ÿ���㣬���ʹ�û����������ߡ�
    procedure AddClosedCurve(const points: array of TGpPointF); overload;
    procedure AddClosedCurve(const points: array of TGpPointF; tension: Single); overload;
    procedure AddClosedCurve(const points: array of TGpPoint); overload;
    procedure AddClosedCurve(const points: array of TGpPoint; tension: Single); overload;
    // ���·�����һ�����Ρ�
    procedure AddRectangle(const rect: TGpRectF); overload;
    procedure AddRectangle(x, y, Width, Height: Single); overload;
    procedure AddRectangle(const rect: TGpRect); overload;
    procedure AddRectangle(x, y, Width, Height: Integer); overload;
    // ���·�����һϵ�о��Ρ�
    procedure AddRectangles(const rects: array of TGpRectF); overload;
    procedure AddRectangles(const rects: array of TGpRect); overload;
    // ��ǰ·�����һ����Բ��
    procedure AddEllipse(const rect: TGpRectF); overload;
    procedure AddEllipse(x, y, Width, Height: Single); overload;
    procedure AddEllipse(const rect: TGpRect); overload;
    procedure AddEllipse(x, y, Width, Height: Integer); overload;
    // ���·�����һ������������
    procedure AddPie(const rect: TGpRectF; startAngle, sweepAngle: Single); overload;
    procedure AddPie(x, y, Width, Height, startAngle, sweepAngle: Single); overload;
    procedure AddPie(const rect: TGpRect; startAngle, sweepAngle: Single); overload;
    procedure AddPie(x, y, Width, Height: Integer; startAngle, sweepAngle: Single); overload;
    // ���·����Ӷ���Ρ�
    procedure AddPolygon(const points: array of TGpPointF); overload;
    procedure AddPolygon(const points: array of TGpPoint); overload;
    // ��ָ���� GraphicsPath ����׷�ӵ���·����
    procedure AddPath(const addingPath: TGpGraphicsPath; connect: Boolean);
    // ���·������ı��ַ�����
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

    // ��� PathPoints �� PathTypes ���鲢�� FillMode ����Ϊ Alternate��
    procedure Reset;
    // ��ʼһ����·��(��ͼ�Σ���ǰ��ͼ�ε�Ͽ�(����))��������ӵ�·�������е㶼�����ڴ���·���С�
    // ��·��ʹ�����Խ�һ��·���ֳɼ������ֲ�ʹ�� TGraphicsPathIterator����ѭ��������Щ��·����
    procedure StartFigure;
    // ��StartFigure��Ӧ���պϵ�ǰ��·��ͼ�β���ʼ�µ�ͼ�Σ��������ӵ�·�������е�Ͽ���
    procedure CloseFigure;
    // �պϴ�·�������п��ŵ�ͼ�β���ʼһ����ͼ�Ρ������ö��StartFigure��һ���Ապ�
    procedure CloseAllFigures;
    // �ڴ� GraphicsPath ���������ñ�ǡ������ָ�������·������·����������Ǽ�ɺ���һ��������·����
    procedure SetMarker;
    // �����·�������б�ǡ�
    procedure ClearMarkers;
    // ��ת�� GraphicsPath ����� PathPoints �����и����˳��
    procedure Reverse;
    // �����ξ���Ӧ�õ��� GraphicsPath ����
    procedure Transform(const matrix: TGpMatrix);

    // ������ָ���� Matrix ����Ե�ǰ·�����б��β�����ָ���� Pen ������Ƹ�·��ʱ��
    // �޶��� GraphicsPath ����ľ���
    procedure GetBounds(var bounds: TGpRectF; const matrix: TGpMatrix  = nil;
                        const pen: TGpPen = nil); overload;
    procedure GetBounds(var bounds: TGpRect; const matrix: TGpMatrix  = nil;
                        const pen: TGpPen = nil); overload;
    // ���� GraphicsPath �����еĸ�������ת�����������߶����С�
    // ���� matrix��չƽǰ�� GraphicsPath ���б��ε� Matrix ����
    // flatness ���ߺ���չƽ�Ľ���ֱ��֮������������
    // ֵ 0.25 ��Ĭ��ֵ�����͸�չƽֵ�����ӽ���ֱ�����߶ε���Ŀ��
    procedure Flatten(const matrix: TGpMatrix = nil; flatness: Single = FlatnessDefault);
    // ����ָ���Ļ��ʻ��ƴ�·��ʱ���ð����������������ߴ���� GraphicsPath ����
    // �˷���Χ�ƴ� GraphicsPath �����ڵ�ԭʼ��������һ��������
    // ������������������ľ�����ڵ��� Widen ʱ���� Pen ����Ŀ�ȡ�
    // ���ϣ���������֮��Ŀռ䣬����ʹ�� FillPath ��������� DrawPath ����
    // pen:ָ��·��ԭʼ�����ʹ˷���������������֮��Ŀ�ȡ�
    // matrix:ָ����չǰӦ����·���ı��Ρ�flatness: ָ������չƽ��ֵ
    procedure Widen(const pen: TGpPen; const matrix: TGpMatrix = nil;
                    flatness: Single = FlatnessDefault);
    //
    procedure Outline(const matrix: TGpMatrix = nil; flatness: Single = FlatnessDefault);
    // �Դ� GraphicsPath ����Ӧ����һ�����κ�һ��ƽ���ı��ζ����Ť�����Ρ�
    // destPoints:���Ƕ����� srcRect ����ľ��ν����ε���ƽ���ı��Ρ�
    // ��������԰����������ĸ�Ԫ�ء������������Ԫ�أ���ƽ���ı������½�λ�õĵ��ǰ�����㵼����
    // srcRect:����ʾ������Ϊ destPoints �����ƽ���ı��εľ��Ρ�
    // matrix: ָ����Ӧ����·���ļ��α��ε� Matrix ����
    // warpMode: ָ����Ť��������ʹ��͸��ģʽ����˫����ģʽ��
    // flatness: ���� 0 �� 1 ֮���ֵ����ָ�����չƽ����·�����йظ�����Ϣ����μ� Flatten ������
    procedure Warp(const destPoints: array of TGpPointF;
                  const srcRect: TGpRectF; const matrix: TGpMatrix = nil;
                  warpMode: TWarpMode  = wmPerspective;
                  flatness: Single = FlatnessDefault);
    procedure GetPathPoints(var points: array of TGpPoint); overload;
    procedure GetPathPoints(var points: array of TGpPointF); overload;
    procedure GetPathTypes(var types: array of TPathPointTypes);
    // ����ָ�����Ƿ�����ڴ� GraphicsPath �����ڡ�
    function IsVisible(const point: TGpPointF; const g: TGpGraphics = nil): Boolean; overload;
    function IsVisible(x, y: Single; const g: TGpGraphics = nil): Boolean; overload;
    function IsVisible(const point: TGpPoint;
                       const g: TGpGraphics = nil): Boolean; overload;
    function IsVisible(x, y: Integer; const g: TGpGraphics = nil): Boolean; overload;
    // ���Ե�ʹ��ָ���� Pen ����� Graphics ������� GraphicsPath ����ʱ��
    // ָ��������Ƿ������·����������
    function IsOutlineVisible(const point: TGpPointF; const pen: TGpPen;
                              const g: TGpGraphics = nil): Boolean; overload;
    function IsOutlineVisible(x, y: Single; const pen: TGpPen;
                              const g: TGpGraphics = nil): Boolean; overload;
    function IsOutlineVisible(const point: TGpPoint; const pen: TGpPen;
                              const g: TGpGraphics = nil): Boolean; overload;
    function IsOutlineVisible(x, y: Integer; const pen: TGpPen;
                              const g: TGpGraphics = nil): Boolean; overload;
    // ��ȡ������һ�� FillMode ö�٣���ȷ���� GraphicsPath �����е���״���ڲ������䡣
    property FillMode: Vcl.Graphics.TFillMode read GetFillMode write SetFillMode;
    // ��ȡ�� GraphicsPath ����� PathPoints �����е����ĵ㡣
    property LastPoint: TGpPointF read GetLastPoint;
    property PointCount: Integer read GetPointCount;
    // ��ȡһ�� PathData ��������װ�� GraphicsPath ����ĵ� (points) ������ (types) �����顣
    // �����ͷ�TPathData����
    property PathData: TPathData read GetPathData;
  end;

//--------------------------------------------------------------------------
// GraphisPathIterator class
// �ṩѭ������ GraphicsPath �����е���·��������ÿһ��·���а�������״���͵�������
//--------------------------------------------------------------------------

  TGpGraphicsPathIterator = class(TGdiplusBase)
  private
    function GetCount: Integer;
    function GetSubpathCount: Integer;
  public
    constructor Create(path: TGpGraphicsPath);
    destructor Destroy; override;
    // �Ƶ�·���е���һ��·������һ��·������ʼ�����ͽ���������������������С�
    // isClosed��ǰ��·���Ƿ��Ǳպϵ�,���ع�����·������·������Ŀ��
    function NextSubpath(var startIndex, endIndex: Integer;
                         var isClosed: Boolean): Integer; overload;
    // �ӹ���·����ȡ��һͼ�Σ���·������path��isClosed��ǰ��·���Ƿ��Ǳպϵ�,������·���е����ݵ����Ŀ
    function NextSubpath(const path: TGpGraphicsPath;
                         var isClosed: Boolean): Integer; overload;
    // ��ȡȫ��������ͬ���͵���һ�����ݵ����ʼ�����ͽ���������
    function NextPathType(var pathType: TPathPointTypes; var startIndex, endIndex: Integer): Integer;
    // ���ӵ�·���е���һ����ǲ���ͨ���������������ʼ�ͽ������������ش˱�Ǻ���һ��Ǽ�ĵ���
    function NextMarker(var startIndex, endIndex: Integer): Integer; overload;
    // ���ӵ���·���е���һ��ǣ�������ǰ��Ǻ���һ��ǣ���·����β��֮�������
    // ���е㸴�Ƶ� GraphicsPath ���󣬷��ش˱�Ǻ���һ��Ǽ�ĵ���
    function NextMarker(const path: TGpGraphicsPath): Integer; overload;
    // ָʾ��� GraphicsPathIterator ���������·���Ƿ�������ߡ�
    function HasCurve: Boolean;
    // ���Ƶ������·������ʼ����
    procedure Rewind;
    // ���ƹ����� GraphicsPath ����� PathPoints �� PathTypes ���ԣ����ظ��Ƶĵ���
    function Enumerate(var points: array of TGpPointF; var types: array of TPathPointTypes): Integer;
    // ���ƹ����� GraphicsPath ����� PathPoints �� PathTypes ���ԣ����ظ��Ƶĵ���
    // startIndex��endIndex�����ʼ�ͽ�������
    function CopyData(var points: array of TGpPointF; var types: array of TPathPointTypes;
                      startIndex, endIndex: Integer): Integer;
    // ��ȡ·���е����Ŀ��
    property Count: Integer read GetCount;
    // ��ȡ·������·������Ŀ��
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
    // ���豸�����ĵ�ָ����������µ� Graphics ����
    constructor Create(hdc: HDC); overload;
    class function FromHDC(hdc: HDC): TGpGraphics; overload;
    // ���豸�����ĵ�ָ��������豸�ľ�������µ� Graphics ����
    // �豸���ͨ�����ڲ�ѯ�ض���ӡ������
    constructor Create(hdc: HDC; hdevice: THANDLE); overload;
    class function FromHDC(hdc: HDC; hdevice: THANDLE): TGpGraphics; overload;
    // �Ӵ��ڵ�ָ����������µ� Graphics ����
    constructor Create(hwnd: HWND; icm: Boolean); overload;
    class function FromHWND(hwnd: HWND; icm: Boolean = False): TGpGraphics;
    // ��ָ���� Image ���󴴽��� Graphics ����
    constructor Create(image: TGpImage); overload;
    class function FromImage(image: TGpImage): TGpGraphics;
    destructor Destroy; override;
    // �ô˷���ǿ��ִ�����й����ͼ�β���������ָ�����ȴ����߲��ȴ����ڲ������֮ǰ����
    procedure Flush(intention: TFlushIntention  = fiFlush);

    //------------------------------------------------------------------------
    // GDI Interop methods
    //------------------------------------------------------------------------

    // ��ȡ�������豸�����ĵľ����������ReleaseHDC�����ɶ�ʹ��
    // ����δѡ�����壬����� Font.Create(Hdc) �������е��ý���ʧ�ܡ�
    function GetHDC: HDC;
    // �ͷ�ͨ����ǰ GetHdc �����ĵ��û�õ��豸�����ľ����
    procedure ReleaseHDC(hdc: HDC);
    // ��ȡ�����ô� Graphics �����ȫ�ֱ任��
    procedure GetTransform(matrix: TGpMatrix);
    procedure SetTransform(const matrix: TGpMatrix);
    // ���˶����ȫ�ֱ任��������Ϊ��λ����
    procedure ResetTransform;
    // ��ָ��˳�򽫴� Graphics �����ȫ�ֱ任����ָ���� Matrix ����
    procedure MultiplyTransform(const matrix: TGpMatrix; order: TMatrixOrder = moPrepend);
    // ��ָ��˳��ָ��ƽ��Ӧ�õ��� Graphics ����ı任����
    procedure TranslateTransform(dx, dy: Single; order: TMatrixOrder = moPrepend);
    // ��ָ��˳��ָ�������Ų���Ӧ�õ��� Graphics ����ı任����
    procedure ScaleTransform(sx, sy: Single; order: TMatrixOrder = moPrepend);
    // ��ָ��˳��ָ����תӦ�õ��� Graphics ����ı任����
    procedure RotateTransform(angle: Single; order: TMatrixOrder = moPrepend);
    // ʹ�ô˶���ĵ�ǰȫ�ֱ任��ҳ�任�����������һ������ռ�ת������һ������ռ䡣
    procedure TransformPoints(destSpace, srcSpace: TCoordinateSpace;
                              pts: array of TGpPointF); overload;
    procedure TransformPoints(destSpace, srcSpace: TCoordinateSpace;
                              pts: array of TGpPoint); overload;

    //------------------------------------------------------------------------
    // GetNearestColor (for <= 8bpp surfaces).  Note: Alpha is ignored.
    // �����ڻ����8λ����ʱ����ȡ��ָ���� Color �ṹ��ӽ�����ɫ��
    //------------------------------------------------------------------------

    function GetNearestColor(Color: TARGB): TARGB;

    // ����һ�������������ָ�����������������
    procedure DrawLine(const pen: TGpPen; x1, y1, x2, y2: Single); overload;
    procedure DrawLine(const pen: TGpPen; pt1, pt2: TGpPointF); overload;
    procedure DrawLine(const pen: TGpPen; x1, y1, x2, y2: Integer); overload;
    procedure DrawLine(const pen: TGpPen; pt1, pt2: TGpPoint); overload;
    // ����һϵ������һ�� Point �ṹ���߶Ρ�
    procedure DrawLines(const pen: TGpPen; const points: array of TGpPointF); overload;
    procedure DrawLines(const pen: TGpPen; const points: array of TGpPoint); overload;
    // ����һ�λ��ߣ�����ʾ��һ�����ꡢ��Ⱥ͸߶�ָ������Բ���֡�
    // ���У�startAngle �� x �ᵽ���ߵ���ʼ����˳ʱ�뷽������Ľǣ��Զ�Ϊ��λ����
    // sweepAngle �� startAngle ���������ߵĽ�������˳ʱ�뷽������Ľǣ��Զ�Ϊ��λ����
    procedure DrawArc(const pen: TGpPen; x, y, width, height: Single;
                      startAngle, sweepAngle: Single); overload;
    procedure DrawArc(const pen: TGpPen; const rect: TGpRectF;
                      startAngle, sweepAngle: Single); overload;
    procedure DrawArc(const pen: TGpPen; x, y, width, height: Integer;
                      startAngle, sweepAngle: Single); overload;
    procedure DrawArc(const pen: TGpPen; const rect: TGpRect;
                      startAngle, sweepAngle: Single); overload;
    // ������ 4 �� Point �ṹ����ı�����������
    procedure DrawBezier(const pen: TGpPen; x1, y1, x2, y2, x3, y3, x4, y4: Single); overload;
    procedure DrawBezier(const pen: TGpPen; const pt1, pt2, pt3, pt4: TGpPointF); overload;
    procedure DrawBezier(const pen: TGpPen; x1, y1, x2, y2, x3, y3, x4, y4: Integer); overload;
    procedure DrawBezier(const pen: TGpPen; const pt1, pt2, pt3, pt4: TGpPoint); overload;
    // �� Point �ṹ�������һϵ�б�����������
    procedure DrawBeziers(const pen: TGpPen; const points: array of TGpPointF); overload;
    procedure DrawBeziers(const pen: TGpPen; const points: array of TGpPoint); overload;
    // ����������ԡ���Ⱥ͸߶�ָ���ľ��Ρ�
    procedure DrawRectangle(const pen: TGpPen; const rect: TGpRectF); overload;
    procedure DrawRectangle(const pen: TGpPen; x, y, width, height: Single); overload;
    procedure DrawRectangle(const pen: TGpPen; const rect: TGpRect); overload;
    procedure DrawRectangle(const pen: TGpPen; x, y, width, height: Integer); overload;
    // ����һϵ���� Rectangle �ṹָ���ľ��Ρ�
    procedure DrawRectangles(const pen: TGpPen; const rects: array of TGpRectF); overload;
    procedure DrawRectangles(const pen: TGpPen; const rects: array of TGpRect); overload;
    // ����һ���ɱ߿򣨸ñ߿���һ�����ꡢ�߶ȺͿ��ָ�����������Բ��
    procedure DrawEllipse(const pen: TGpPen; const rect: TGpRectF); overload;
    procedure DrawEllipse(const pen: TGpPen; x, y, width, height: Single); overload;
    procedure DrawEllipse(const pen: TGpPen; const rect: TGpRect); overload;
    procedure DrawEllipse(const pen: TGpPen; x, y, width, height: Integer); overload;
    // ����һ�����Σ���������һ������ԡ���Ⱥ͸߶��Լ�����������ָ������Բ���塣
    procedure DrawPie(const pen: TGpPen; const rect: TGpRectF;
                      startAngle, sweepAngle: Single); overload;
    procedure DrawPie(const pen: TGpPen; x, y, width, height: Single;
                      startAngle, sweepAngle: Single); overload;
    procedure DrawPie(const pen: TGpPen; const rect: TGpRect;
                      startAngle, sweepAngle: Single); overload;
    procedure DrawPie(const pen: TGpPen; x, y, width, height: Integer;
                      startAngle, sweepAngle: Single); overload;
    // ������һ�� Point �ṹ����Ķ���Ρ�
    procedure DrawPolygon(const pen: TGpPen; const points: array of TGpPointF); overload;
    procedure DrawPolygon(const pen: TGpPen; const points: array of TGpPoint); overload;
    // ���� GraphicsPath ����
    procedure DrawPath(const pen: TGpPen; const path: TGpGraphicsPath);
    // ���ƾ���һ��ָ���� Point �ṹ�Ļ���������
    // ���У�offset: �� points ���������еĵ�һ��Ԫ�ص���������ʼ���ƫ������
    // numberOfSegments: ��ʼ��֮��Ҫ�����������еĶ�����
    // tension: ���ڻ���� 0.0 ��ֵ����ֵָ�����ߵ�������
    procedure DrawCurve(const pen: TGpPen; const points: array of TGpPointF); overload;
    procedure DrawCurve(const pen: TGpPen; const points: array of TGpPointF; tension: Single); overload;
    procedure DrawCurve(const pen: TGpPen; const points: array of TGpPointF;
                        offset, numberOfSegments: Integer; tension: Single = 0.5); overload;
    procedure DrawCurve(const pen: TGpPen; const points: array of TGpPoint); overload;
    procedure DrawCurve(const pen: TGpPen; const points: array of TGpPoint; tension: Single); overload;
    procedure DrawCurve(const pen: TGpPen; const points: array of TGpPoint;
                        offset, numberOfSegments: Integer; tension: Single = 0.5); overload;
    // ������ Point �ṹ�����鶨��ıպϻ���������
    procedure DrawClosedCurve(const pen: TGpPen; const points: array of TGpPointF); overload;
    procedure DrawClosedCurve(const pen: TGpPen; const points: array of TGpPointF; tension: Single); overload;
    procedure DrawClosedCurve(const pen: TGpPen; const points: array of TGpPoint); overload;
    procedure DrawClosedCurve(const pen: TGpPen; const points: array of TGpPoint; tension: Single); overload;

    // ���������ͼ�沢��ָ������ɫ��䡣
    procedure Clear(const color: TARGB);
    // �����һ�����ꡢһ����Ⱥ�һ���߶�ָ���ľ��ε��ڲ���
    procedure FillRectangle(const brush: TGpBrush; const rect: TGpRectF); overload;
    procedure FillRectangle(const brush: TGpBrush; x, y, width, height: Single); overload;
    procedure FillRectangle(const brush: TGpBrush; const rect: TGpRect); overload;
    procedure FillRectangle(const brush: TGpBrush; x, y, width, height: Integer); overload;
    // ����� Rectangle �ṹָ����һϵ�о��ε��ڲ���
    procedure FillRectangles(const brush: TGpBrush; const rects: array of TGpRectF); overload;
    procedure FillRectangles(const brush: TGpBrush; const rects: array of TGpRect); overload;
    // ��� Point �ṹָ���ĵ�����������Ķ���ε��ڲ���
    procedure FillPolygon(const brush: TGpBrush; const points: array of TGpPointF;
                          fillMode: Vcl.Graphics.TFillMode = fmAlternate); overload;
    procedure FillPolygon(const brush: TGpBrush; const points: array of TGpPoint;
                          fillMode: Vcl.Graphics.TFillMode = fmAlternate); overload;
    // ���߿����������Բ���ڲ����ñ߿���һ�����ꡢһ����Ⱥ�һ���߶�ָ����
    procedure FillEllipse(const brush: TGpBrush; const rect: TGpRectF); overload;
    procedure FillEllipse(const brush: TGpBrush; x, y, width, height: Single); overload;
    procedure FillEllipse(const brush: TGpBrush; const rect: TGpRect); overload;
    procedure FillEllipse(const brush: TGpBrush; x, y, width, height: Integer); overload;
    // �����һ�����ꡢһ����ȡ�һ���߶��Լ���������ָ������Բ����������������ڲ���
    procedure FillPie(const brush: TGpBrush; const rect: TGpRectF;
                      startAngle, sweepAngle: Single); overload;
    procedure FillPie(const brush: TGpBrush; x, y, width, height: Single;
                      startAngle, sweepAngle: Single); overload;
    procedure FillPie(const brush: TGpBrush; const rect: TGpRect;
                      startAngle, sweepAngle: Single); overload;
    procedure FillPie(const brush: TGpBrush; x, y, width, height: Integer;
                      startAngle, sweepAngle: Single); overload;
    // ��� GraphicsPath ������ڲ���
    procedure FillPath(const brush: TGpBrush; const path: TGpGraphicsPath);
    // ����� Point �ṹ���鶨��ıպϻ����������ߵ��ڲ���
    procedure FillClosedCurve(const brush: TGpBrush; const points: array of TGpPointF); overload;
    procedure FillClosedCurve(const brush: TGpBrush; const points: array of TGpPointF;
                              fillMode: Vcl.Graphics.TFillMode; tension: Single = 0.5); overload;
    procedure FillClosedCurve(const brush: TGpBrush; const points: array of TGpPoint); overload;
    procedure FillClosedCurve(const brush: TGpBrush; const points: array of TGpPoint;
                              fillMode: Vcl.Graphics.TFillMode; tension: Single = 0.5); overload;
    // ��� Region ������ڲ���
    procedure FillRegion(const brush: TGpBrush; const region: TGpRegion);
    // ʹ��ָ�� StringFormat ����ĸ�ʽ�����ԣ�
    // ��ָ���� Brush �� Font ������ָ������������λ���ָ�����ı��ַ�����
    procedure DrawString(const str: WideString; const font: TGpFont;
                         const brush: TGpBrush; const layoutRect: TGpRectF;
                         const format: TGpStringFormat = nil); overload;
    procedure DrawString(const str: WideString; const font: TGpFont;
                         const brush: TGpBrush; x, y: Single;
                         const format: TGpStringFormat = nil); overload;
    procedure DrawString(const str: WideString; const font: TGpFont;
                         const brush: TGpBrush; const origin: TGpPointF;
                         const format: TGpStringFormat = nil); overload;
    // ������ָ���� Font ������Ʋ���ָ���� StringFormat �����ʽ����ָ���ַ�����
    // ���ػ����ı���ռ�õľ��οռ�
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
    // ��ȡ Region ��������飬����ÿ�������ַ�λ�õķ�Χ�޶���ָ���ַ����ڡ�
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
    // ��ָ��λ�ò��Ұ�ԭʼ��С����ָ���� Image ����
    procedure DrawImage(image: TGpImage; const point: TGpPointF); overload;
    procedure DrawImage(image: TGpImage; x, y: Single); overload;
    procedure DrawImage(image: TGpImage; const point: TGpPoint); overload;
    procedure DrawImage(image: TGpImage; x, y: Integer); overload;
    // ��ָ��λ�ò��Ұ�ָ����С����ָ���� Image ����
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
    // ��ָ��λ�ò��Ұ�ָ����״�ʹ�С����ָ���� Image ����
    // destPoinrs: ���������ĸ����νṹ��ɵ����飬����һ��ƽ���ı��Ρ�
    procedure DrawImage(image: TGpImage; const destPoints: array of TGpPointF); overload;
    procedure DrawImage(image: TGpImage; const destPoints: array of TGpPoint); overload;
    // ��ָ����λ�û���ͼ���һ���֡�srcUnit: srcRect �������õĶ�����λ
    procedure DrawImage(image: TGpImage; x, y, srcx, srcy,
                        srcwidth, srcheight: Single; srcUnit: TUnit); overload;
    procedure DrawImage(image: TGpImage; x, y, srcx, srcy,
                        srcwidth, srcheight: Integer; srcUnit: TUnit); overload;
    procedure DrawImage(image: TGpImage; x, y: Single; srcRect: TGpRectF; srcUnit: TUnit); overload;
    procedure DrawImage(image: TGpImage; x, y: Integer; srcRect: TGpRect; srcUnit: TUnit); overload;
    // ��ָ��λ�ò��Ұ�ָ����С����ָ���� Image �����ָ�����֡�
    // ���� callback  Ϊ�ص��������Լ���Ƿ����Ӧ�ó���ȷ��������ֹͣ��ͼ
    // callbackData �ص�������������ָ��
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
    // ��ָ��λ�ò��Ұ�ָ����С����ָ���� Image �����ָ�����֡�
    // // destPoinrs: ���������ĸ����νṹ��ɵ����飬����һ��ƽ���ı��Ρ�
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
    // ��ָ�� Metafile �����еļ�¼������͵��ص���������ָ���ĵ㴦��ʾ��
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
    // ��������������Ϊ��ǰ���������ָ���� TGpGraphics ����� Clip ����ָ������ϲ����Ľ����
    procedure SetClip(const g: TGpGraphics; combineMode: TCombineMode = cmReplace); overload;
    // ���˼�����������Ϊ��ǰ���������� Rectangle �ṹ��ָ�����ε���Ͻ����
    procedure SetClip(const rect: TGpRectF; combineMode: TCombineMode = cmReplace); overload;
    procedure SetClip(const rect: TGpRect; combineMode: TCombineMode = cmReplace); overload;
    // ��������������Ϊ��ǰ����������ָ�� GraphicsPath �������Ͻ����
    procedure SetClip(const path: TGpGraphicsPath; combineMode: TCombineMode = cmReplace); overload;
    // ��������������Ϊ��ǰ����������ָ�� Region �������Ͻ����
    procedure SetClip(const region: TGpRegion; combineMode: TCombineMode = cmReplace); overload;

    // This is different than the other SetClip methods because it assumes
    // that the HRGN is already in device units, so it doesn't transform
    // the coordinates in the HRGN.
    procedure SetClip(hRgn: HRGN; combineMode: TCombineMode = cmReplace); overload;
    // �������������Ϊ��ǰ����������ָ���ṹ�����Ľ�����
    procedure IntersectClip(const rect: TGpRectF); overload;
    procedure IntersectClip(const rect: TGpRect); overload;
    procedure IntersectClip(const region: TGpRegion); overload;
    // ���´˼����������ų����λ�����ṹ��ָ��������
    procedure ExcludeClip(const rect: TGpRectF); overload;
    procedure ExcludeClip(const rect: TGpRect); overload;
    procedure ExcludeClip(const region: TGpRegion); overload;
    // ��������������Ϊ��������
    procedure ResetClip;
    // ������������ˮƽ����ʹ�ֱ����ƽ��ָ��������
    procedure TranslateClip(dx, dy: Single); overload;
    procedure TranslateClip(dx, dy: Integer); overload;
    // ��ȡ Region ���󣬸ö����޶��� Graphics ����Ļ�ͼ����
    procedure GetClip(region: TGpRegion);
    // ��ȡһ�� Rect �ṹ���ýṹ�޶��� Graphics ����ļ�������
    procedure GetClipBounds(var rect: TGpRectF); overload;
    procedure GetClipBounds(var rect: TGpRect); overload;
    // ��ȡһ��ֵ����ֵָʾ�� Graphics ����ļ��������Ƿ�Ϊ�ա�
    function IsClipEmpty: Boolean;
    // ��ȡ�� Graphics ����Ŀɼ���������ı߿�
    procedure GetVisibleClipBounds(var rect: TGpRectF); overload;
    procedure GetVisibleClipBounds(var rect: TGpRect); overload;
    // ��ȡһ��ֵ����ֵָʾ�� Graphics ����Ŀɼ����������Ƿ�Ϊ�ա�
    function IsVisibleClipEmpty: Boolean;
    // ָʾָ�������������Ƿ�����ڴ� Graphics ����Ŀɼ����������ڡ�
    function IsVisible(x, y: Integer): Boolean; overload;
    function IsVisible(const point: TGpPoint): Boolean; overload;
    function IsVisible(x, y, width, height: Integer): Boolean; overload;
    function IsVisible(const rect: TGpRect): Boolean; overload;
    function IsVisible(x, y: Single): Boolean; overload;
    function IsVisible(const point: TGpPointF): Boolean; overload;
    function IsVisible(x, y, width, height: Single): Boolean; overload;
    function IsVisible(const rect: TGpRectF): Boolean; overload;
    // �������ĵ�ǰ״̬������ TGraphicsState �����ʶ�����״̬
    // ���ص� GraphicsState ����ֻ���� Restore ��������һ��
    function Save: TGraphicsState;
    // �������״̬��ԭ�� GraphicsState �����ʾ��״̬��
    procedure Restore(gstate: TGraphicsState );
    // ������д˶���ǰ״̬��ͼ��������Ȼ��򿪲�ʹ���µ�ͼ��������
    function  BeginContainer(const dstrect, srcrect: TGpRectF;
                             unit_: TUnit): TGraphicsContainer; overload;
    function  BeginContainer(const dstrect, srcrect: TGpRect;
                             unit_: TUnit): TGraphicsContainer; overload;
    function  BeginContainer: TGraphicsContainer; overload;
    // �رյ�ǰͼ�����������������״̬��ԭ��ͨ������ BeginContainer ���������״̬��
    procedure EndContainer(state: TGraphicsContainer);

    // Only valid when recording metafiles.
    // ��ǰ Metafile �������ע�͡����������ݻ��������䳤��
    procedure AddMetafileComment(const data: PBYTE; sizeData: Integer);
    // ��ȡ��ǰ Windows �İ�ɫ����ɫ��ľ����
    // Ŀ���ǣ�����ʾ��ʹ��ÿ���� 8 λʱ��ʹ GDI+ �ܹ��������������İ�ɫ����
    class function GetHalftonePalette: HPALETTE;

    // Ϊ��ɫ�������Ӱ���ʻ�ȡ�����ó���ԭ�㡣
    // ����ָ�� Point �ṹ���ýṹ��ʾ 8 λ/���غ� 16 λ/���ص�ɫ����ĵ�ɫԭ�㣬
    // ������������Ӱ���ʵ�ԭ�㡣
    property RenderingOrigin: TGpPoint read GetRenderingOrigin write SetRenderingOrigin;
    // ��ȡ��������ν��ϳ�ͼ����Ƶ��� Graphics ����
    property CompositingMode: TCompositingMode read GetCompositingMode write SetCompositingMode;
    // ��ȡ�����û��Ƶ��� Graphics ����ĺϳ�ͼ��ĳ���������
    property CompositingQuality: TCompositingQuality read GetCompositingQuality write SetCompositingQuality;
    // ��ȡ�����������������ı��ĳ���ģʽ���ı�������ʾָ���ı��Ƿ��� Antialias ��ʽ����
    property TextRenderingHint: TTextRenderingHint read GetTextRenderingHint write SetTextRenderingHint;
    // ��ȡ�����ó����ı���٤�����ֵ�����ڳ��� Antialias �� ClearType �ı���٤�����ֵ��
    // ٤�����ֵ������� 0 �� 12 ֮�䡣Ĭ��ֵΪ 4��
    property TextContrast: Integer read GetTextContrast write SetTextContrast;
    // ��ȡ���������������Ĳ岹ģʽ��
    property InterpolationMode: TInterpolationMode read GetInterpolationMode write SetInterpolationMode;
    // ��ȡ�����ô˶���ĳ���������ƽ��ģʽ��Ӱ��ʹ��·�����仭����������
    // SmoothingMode ���Բ�Ӱ���ı�����Ҫ�����ı�������������ʹ�� TextRenderingHint ö��
    property SmoothingMode: TSmoothingMode read GetSmoothingMode write SetSmoothingMode;
    // ��ȡ������һ��ֵ����ֵָ���ڳ��ִ� Graphics ����Ĺ������������ƫ��
    property PixelOffsetMode: TPixelOffsetMode read GetPixelOffsetMode write SetPixelOffsetMode;
    // ��ȡ���������ڴ� Graphics �����е�ҳ����Ķ�����λ��
    property PageUnit: TUnit read GetPageUnit write SetPageUnit;
    // ��ȡ�����ô� Graphics �����ȫ�ֵ�λ��ҳ��λ֮��ı�����
    property PageScale: Single read GetPageScale write SetPageScale;
    // ��ȡ�� Graphics �����ˮƽ�ֱ��ʣ���ÿӢ�������ʾ����
    property DpiX: Single read GetDpiX;
    // ��ȡ�� Graphics ����Ĵ�ֱ�ֱ��ʣ���ÿӢ�������ʾ����
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
// �Ƿ��
function Empty(const sz: TGpSizeF): Boolean; overload;
function Empty(const sz: TGpSize): Boolean; overload;
// ���
function Equals(const sz1, sz2: TGpSizeF): Boolean; overload;
function Equals(const sz1, sz2: TGpSize): Boolean; overload;
function Equals(const pt1, pt2: TGpPointF): Boolean; overload;
function Equals(const pt1, pt2: TGpPoint): Boolean; overload;
function Equals(const rc1, rc2: TGpRectF): Boolean; overload;
function Equals(const rc1, rc2: TGpRect): Boolean; overload;
// ����
function Contains(const rc: TGpRectF; const pt: TGpPointF): Boolean; overload;
function Contains(const rc: TGpRect; const pt: TGpPoint): Boolean; overload;
function Contains(const rc: TGpRectF; const x, y: TREAL): Boolean; overload;
function Contains(const rc: TGpRect; const x, y: INT): Boolean; overload;
function Contains(const rc, rc2: TGpRectF): Boolean; overload;
function Contains(const rc, rc2: TGpRect): Boolean; overload;
// ��չ
procedure Inflate(var rc: TGpRectF; const dx, dy: TREAL); overload;
procedure Inflate(var rc: TGpRect; const dx, dy: INT); overload;
procedure Inflate(var rc: TGpRectF; const point: TGpPointF); overload;
procedure Inflate(var rc: TGpRect; const point: TGpPoint); overload;
// ȡ�������򽻼���dest
function Intersect(var dest: TGpRectF; const a, b: TGpRectF): Boolean; overload;
function Intersect(var dest: TGpRect; const a, b: TGpRect): Boolean; overload;
function Intersect(var dest: TGpRectF; const rc: TGpRectF): Boolean; overload;
function Intersect(var dest: TGpRect; const rc: TGpRect): Boolean; overload;
// �ཻ
function IntersectsWith(const rc1, rc2: TGpRectF): Boolean; overload;
function IntersectsWith(const rc1, rc2: TGpRect): Boolean; overload;
// �Ƿ������
function IsEmptyArea(const rc: TGpRectF): Boolean; overload;
function IsEmptyArea(const rc: TGpRect): Boolean; overload;
// �ƶ�����
procedure Offset(var p: TGpPointF; const dx, dy: TREAL); overload;
procedure Offset(var p: TGpPoint; const dx, dy: INT); overload;
procedure Offset(var rc: TGpRectF; const dx, dy: TREAL); overload;
procedure Offset(var rc: TGpRect; const dx, dy: INT); overload;
procedure Offset(var rc: TGpRectF; const point: TGpPointF); overload;
procedure Offset(var rc: TGpRect; const point: TGpPoint); overload;
// ȡ�������򲢼���dest
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





